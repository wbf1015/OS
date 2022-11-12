#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

free_buddy_t buddy_s;
#define buddy_array (buddy_s.free_array) //链表数组
#define max_order (buddy_s.max_order) //最大的层数
#define nr_free (buddy_s.nr_free) //剩余的空闲块

extern ppn_t first_ppn;

static int IS_POWER_OF_2(size_t n) {
    if (n & (n - 1)) { 
        return 0;
    }
    else {
        return 1;
    }
}

static unsigned int getOrderOf2(size_t n) {
    unsigned int order = 0;
    while (n >> 1) {
        n >>= 1;
        order ++;
    }
    return order;
}

static size_t ROUNDDOWN2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res>>1; 
    }
    else {
        return n;
    }
}

static size_t ROUNDUP2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res; 
    }
    else {
        return n;
    }
}

//在测试的时候使用，打印buddy array
static void
show_buddy_array(void) {
    cprintf("[!]BS: Printing buddy array:\n");
    for (int i = 0;i < max_order + 1;i ++) {
        cprintf("%d layer: ", i);
        list_entry_t *le = &(buddy_array[i]);
        while ((le = list_next(le)) != &(buddy_array[i])) {
            struct Page *p = le2page(le, page_link);
            cprintf("%d ", 1 << (p->property));
        }
        cprintf("\n");
    }
    cprintf("---------------------------\n");
    return;
}

/*
 *  初始化buddy结构体
 */
buddy_init(void) {
    for (int i = 0;i < MAX_BUDDY_ORDER+1;i ++){
        list_init(buddy_array + i); 
    }
    max_order = 0;
    nr_free = 0;
    cprintf("buddy system init success\n");
    return;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    size_t pnum;
    unsigned int order;
    pnum = ROUNDDOWN2(n);       // 将页数向下取整为2的幂
    
    //for debug
    //pnum = 8;
    order = getOrderOf2(pnum);   // 求出页数对应的2的幂
    //cprintf("[!]BS: AVA Page num after rounding down to powers of 2: %d = 2^%d\n", pnum, order);

    struct Page *p = base;
    // 初始化pages数组中范围内的每个Page
    for (; p != base + pnum; p ++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = -1;   // 全部初始化为非头页
        set_page_ref(p, 0);
    }

    max_order = order>max_order?order:max_order;
    nr_free += pnum;

    //cprintf("max_order is :%d,nr_free is :%d\n",max_order,nr_free);
    list_add(&(buddy_array[order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块——16384,的头页
    base->property = order;                       // 将第一页base的property设为最大块的2幂

    //cprintf("buddy mem init success\n");
    return;
}   

/*
 *  buddy_split：分裂指定阶的物理块
 *  参数：
 *  n： 指定的阶
 *  默认分裂数组中第n条链表的第一块
 */
static void buddy_split(size_t n) {
    assert(n > 0 && n <= max_order);
    assert(!list_empty(&(buddy_array[n])));
    //cprintf("[!]BS: SPLITTING!\n");
    struct Page *page_left;
    struct Page *page_right;

    page_left = le2page(list_next(&(buddy_array[n])), page_link);
    page_right = page_left + (1 << (n - 1));
    page_left->property = n - 1;
    page_right->property = n - 1;

    list_del(list_next(&(buddy_array[n])));
    list_add(&(buddy_array[n-1]), &(page_left->page_link));
    list_add(&(page_left->page_link), &(page_right->page_link));

    return;
}

/*
 *  buddy_alloc_pages：分配指定大小的物理块
 *  参数：
 *  n： 指定物理块的大小（页）
 */
static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }

    struct Page *page = NULL;
    size_t pnum = ROUNDUP2(n);  
    size_t order = getOrderOf2(pnum);
    //cprintf("[!]BS: Allocating %d-->%d = 2^%d pages ...\n", n, pnum, order);
    //cprintf("[!]BS: Buddy array before ALLOC:\n");
    //show_buddy_array();

// 若order对应的链表中含有空闲块，则直接分配
find:
    if (!list_empty(&(buddy_array[order]))) {
        page = le2page(list_next(&(buddy_array[order])), page_link);
        list_del(list_next(&(buddy_array[order])));
        SetPageProperty(page); // 将分配块的头页设置为已被占用
        //cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
        //show_buddy_array();
        goto done; 
    }

//buddy_array[order] is empty,go to top array to split
    for (int i = order + 1;i < max_order + 1;i ++) {
        if (!list_empty(&(buddy_array[i]))) {
            buddy_split(i);
            //cprintf("[!]BS: Buddy array after SPLITT:\n");
            //show_buddy_array();
            goto find;
        }
    }

done:
    nr_free -= pnum;
    //cprintf("[!]BS: nr_free: %d\n", nr_free);
    //cprintf("---------------------------\n");
    return page;
}

/*
 *  获取以page页为头页的块的伙伴块
 */
static struct Page*
buddy_get_buddy(struct Page *page) {
    unsigned int order = page->property;
    unsigned int buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn)); // first_ppn是在ppm.c中新声明的全局变量，表示第一个可分配物理内存页的下标
    //cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
    if (buddy_ppn > page2ppn(page)) {
        return page + (buddy_ppn - page2ppn(page));
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
    }
 
}

/*
 *  buddy_free_pages：分配指定大小的物理块
 *  参数：
 *  base：所释放物理块的头页
 *  n： 所释放物理块的的大小（页）
 */
static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned int pnum = 1 << (base->property);
    assert(ROUNDUP2(n) == pnum);
    //cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
    
    struct Page* left_block = base;
    struct Page *buddy = NULL;
    struct Page* tmp = NULL;
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
    //cprintf("[!]BS: add to list\n");
    //show_buddy_array();
    buddy = buddy_get_buddy(left_block);

    //cprintf("array 0:%d,%d\n",buddy_array[0].next,buddy_array[0].next->next);
    //cprintf("left_block:%d,buddy:%d\n",&left_block->page_link,&buddy->page_link);

    while (!PageProperty(buddy) && left_block->property < max_order) {
        //make sure that free the buddy,so left_block must be at lower address
        if ((uint32_t)left_block > (uint32_t)buddy) {
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        buddy->property = -1;
        
        list_del(&(buddy->page_link)); 
        list_del(&(left_block->page_link));
        
        left_block->property += 1;
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
        buddy = buddy_get_buddy(left_block);
    }
    //cprintf("[!]BS: Buddy array after FREE:\n");
    ClearPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;
    //show_buddy_array();
    //cprintf("[!]BS: nr_free: %d\n", nr_free);
    
    return;
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}//返回还剩多少页可以分


static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("alloc 3*1 page\n");
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    show_buddy_array();

    cprintf("free 3*1 page\n");
    free_page(p0);
    free_page(p1);
    free_page(p2);
    show_buddy_array();

    cprintf("alloc 4,2,1 page\n");
    assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(2)) != NULL);
    assert((p2 = alloc_pages(1)) != NULL);
    show_buddy_array();

    cprintf("free 4,2,1 page\n");
    free_pages(p0, 4);
    free_pages(p1, 2);
    free_pages(p2, 1);
    show_buddy_array();

    cprintf("free 2*3 page\n");
    assert((p0 = alloc_pages(3)) != NULL);
    assert((p1 = alloc_pages(3)) != NULL);
    show_buddy_array();
    
    cprintf("free 2*3 page\n");
    free_pages(p0, 3);
    free_pages(p1, 3);
    show_buddy_array();
}
static void
buddy_check(void) {
    basic_check();
}   
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};