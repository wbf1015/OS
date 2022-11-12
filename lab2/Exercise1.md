## Exercise1

[(31条消息) 操作系统实验ucore lab2_裕东方的博客-CSDN博客](https://blog.csdn.net/yyd19981117/article/details/86692154?ops_request_misc=%7B%22request%5Fid%22%3A%22166648868916782414926884%22%2C%22scm%22%3A%2220140713.130102334..%22%7D&request_id=166648868916782414926884&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~top_positive~default-2-86692154-null-null.article_score_rank_blog&utm_term=ucore lab2&spm=1018.2226.3001.4450)

关于ucore中页表管理的结构看上面这个链接和实验指导书就够了，大概首先得知道页表和真正的物理内存页在内存的结构是什么样的。

对应`Page`数据结构和真实物理页的认知：`Page`只是用来管理内存页的，`Page`并不是真正的物理内存页，至于如何通过`Page`找到真正的物理页内存地址，似乎是通过一个函数包装了一下，因为是简单物理地址的映射，但我没找到这个函数，可能你们后面会用。下面这个函数就很好解释了内存里`Page`数据结构和真实空闲内存的分别。

```
/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
	//在BootLoader阶段获得的e820map，描述内存分布结构
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    //maxpa指向了空闲内存的最高地址
    if (maxpa > KMEMSIZE) {
        maxpa = KMEMSIZE;
    }

    extern char end[];
	//npage说明当前内存下，最多有多少个物理页
    npage = maxpa / PGSIZE;
    //地址取整，pages取PGSIZE整数倍，保证页的结构完整
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
	//防治初始化时page被分配了，所以都设置为reserved
    for (i = 0; i < npage; i ++) {
        SetPageReserved(pages + i);
    }
	//freemem就是指向空闲内存，即内存中空闲物理页的最低地址
	//sizeof(struct Page) * npage的意思就是，我要维护这么多内存页
	//需要花多少内存空间的Page结构（页表）来维护
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
	
	//再一次遍历物理内存，用于初始化页表结构
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        if (memmap->map[i].type == E820_ARM) {
            if (begin < freemem) {
                begin = freemem;
            }
            if (end > KMEMSIZE) {
                end = KMEMSIZE;
            }
            if (begin < end) {
                begin = ROUNDUP(begin, PGSIZE);
                end = ROUNDDOWN(end, PGSIZE);
                if (begin < end) {
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
```

然后Exercise1代码集中在`kern/mm/default_pmm.c`里。

```
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
```

这两个宏定义的作用是，拿到空闲链表和空闲页的个数。

然后在`default_init`中初始化空闲链表。

```
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

初始化页表。由于内存空间是一大块一大块的，而我们用页表格式管理，需要每一块大内存的第一个页表维护整个大内存块的空间、分配，所以只需要把第一个页表的`property`字段设为整个内存块共有的页数。然后记得需要在空闲链表加入这个页表即可，并增加我们的空闲页数。

```
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}
```

alloc分配内存空间。如果需要的页数大于空闲页数，那么不可能有一块连续内存空间给他，所以直接`return NULL`.后面需要遍历链表找到连续的内存空间进行分配，详见代码注释。

```
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    //开始遍历空闲链表
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
    	//找到当前链表指向的页表，如果这个内存页数大于我们需要的页数，则直接从这个内存块取n页
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            SetPageReserved(page);
            break;
        }
    }
    if (page != NULL) {
        //list_del(&(page->page_link));
        if (page->property > n) {
        	//因为我们取了n页，内存块可能还有部分内存页，需要当前内存块头偏移n个`Page`位置就是
        	//内存块剩下的页组成新的内存块结构，新的页头描述这个小内存块
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);//记得做这步，把property设为1，否则出错
            //ClearPageReserved(p);
            //往空闲链表里加入这个新的小内存
            list_add(&free_list, &(p->page_link));
    }
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

free释放内存。

```
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    //首先遍历页表，把flags全部置0，并将ref清0，说明此时没有逻辑地址引用这块内存
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    //同样的道理，我释放了n页，那么个n页形成新的一个大一点的内存块，我们需要设置这个内存块的第一个
    //页表描述内存块里有多少个页
    base->property = n;
    SetPageProperty(base);
    //遍历空闲链表，目的找到有没有地址空间是连在一起的内存块，把他们合并
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        le = list_next(le);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    //遍历空闲链表，因为空闲链表是从高到低排序的
    //只需要遍历找打第一个地址比他高的，把释放的内存插入到他前面就行
    le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
}
```

最后`make qemu`运行应该只能运行到check_alloc_page()，之后会因为别的练习没完成报错似乎，不知道是不是这个原因。