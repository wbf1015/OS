LAB2实验说明：

实验一、default_pmm.c

在这个实验中主要是要完成一个first-fit算法的实现，这个算法的大体含义就是用一个双向链表维护很多空闲块，并且返回第一个找到的可以满足要求的空闲块，所谓的满足要求就是这个空闲块的物理内存的大小比需要的内存大小要大就可以。

需要修改的文件：mm/default_pmm.c

（1）文件首先定义了一个free_area_t，它维护了一个双向链表

```C++
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;

//上面的list_entry_t其实是一个list_entry
    typedef struct list_entry list_entry_t;//定义在list.h 相当于给list_entry起了个新名字

//别看这里好像说明都没有，只有一个前后指针，实际上这个list_entry是一个Page的元素
struct list_entry {
    struct list_entry *prev, *next; //list_entry的定义，包括一个前面的指针一个后面的指针
};


```

（2）default_init函数  

```c++
static void
default_init(void) {
    list_init(&free_list);  //初始化链表，让他的前后指针都指向自己
    nr_free = 0;			//还没有页数
}
```

（3）default_init_memap函数：这个函数的作用就是初始化一段内存空间并把它加入到双向链表中（其实这么说可能不太准确，因为双向链表的类实际上实在page中）

```c++
static void
default_init_memmap(struct Page *base, size_t n) {//插入一个块，这个块可能由很多页组成
    assert(n > 0); //插入的页数必须大于零
    struct Page *p = base;		//base就是这些块开始的那个页
    for (; p != base + n; p ++) {
        assert(PageReserved(p));  //必须保证这些页都是被系统保留的页，下面会有专门的专题来说为什么这里必须是被系统保留的页
        p->flags = p->property = 0; //把property都置0
        set_page_ref(p, 0);     //还没有其他的页表引用这块物理内存
    }
    base->property = n;       //更改初始页的property
    SetPageProperty(base);		//更改初始页的属性值
    nr_free += n;				//根据页数进行累加，这是代表着那个全局的空页数有多少，要和前面那个base->property区分一下
    list_add(&free_list, &(base->page_link));    //把新的块加入到已有的双向链表中
}

//首先来看Page的定义 定义在memlayout.h中
/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as phyical address.
 * */
//一个page就描述了一个物理内存的页

//ref表示了有多少虚拟页引用了这个物理内存页

//flags记录这个物理页的状态，查看flags的定义：
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
//如果reserved是1就说明这个也是被内核所占有的，其他人不能分配
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.
//如果这一位是1，说明这个页是某一个连续块的块首，并且它还没被分配，可以用于分配。如果他是零就有两种可能：第一，他是一个块首页但是它已经被分配了或者它根本就不是一个块首页。

//然后就是一些改变或者获得状态位的函数：
//set就是置位 clear就是清楚 test就是检验，具体的函数实现在atomic.h可以查看
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

//property 这里我觉得注释给的不太明确，这个property就代表着以该页为页首的块有几页，如果不是块首页根本就直接是0

//最后这个list_entry_t就是代表着那个维护空闲块的双向链表
struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};


```

（4）defualt_alloc_pages函数：分配一个大小为n的页

```c++
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);//我要确保我分配的页数必须是个正数
    if (n > nr_free) {//如果我这个双向链表中所有的页数加起来都不如n大的话那肯定分配失败，返回一个NULL就好了
        return NULL;
    }
    struct Page *page = NULL;//用来保存我最后返回的那个内存块的第一页
    //开始遍历空闲链表
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {//只要最后没有遍历回来就一直遍历
    	//找到当前链表指向的页表，如果这个内存页数大于我们需要的页数，则直接从这个内存块取n页
        struct Page *p = le2page(le, page_link);//这句话的意思就是，我遍历只能拿到一个list_entry这个变量的东西，但是我想要的是一个Page，所以我需要调用这个函数帮我实现转换
        if (p->property >= n) {
            page = p;
            //SetPageReserved(page);
            break;
        }
    }
    //如果找到了，才做下面的操作
    if (page != NULL) {
 		//有一种可能就是会剩下几个页，那么就需要重新组织剩余的空页
        if (page->property > n) {
        	//因为我们取了n页，内存块可能还有部分内存页，需要当前内存块头偏移n个`Page`位置就是
        	//内存块剩下的页组成新的内存块结构，新的页头描述这个小内存块
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);//记得做这步，把property设为1，表示我是这个块的首页并且可以被分配
            //往空闲链表里加入这个新的小内存
            list_add(&free_list, &(p->page_link));
    }
        list_del(&(page->page_link));//删除掉原来的块
        nr_free -= n;//整个链表保存的页也减少了
        ClearPageProperty(page);//原来的首页不能再被分配了
    }
    return page;
}

//le2page其实就是把list_entry变成page的函数，它也是调用了to_struct函数来完成的
// convert list entry to page
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/* 在defs.h中可以找到
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member 指向的就是嵌入其他对象的那个对象，也就是member
 * @type:   the type of the struct this is embedded in 被嵌入的那个对象的类是啥
 * @member: the name of the member within the struct，就是他在被嵌入的对象里的名字叫啥
 * */
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))

```

（5）default_free_pages函数

```c++
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);//首先要保证我们要释放的页数必须大于0
    struct Page *p = base;
    //首先遍历页表，把flags全部置0，并将ref清0，说明此时没有逻辑地址引用这块内存
    for (; p != base + n; p ++) {
        //如果pagereserved是1说明是给内核预留的页，我们不能free掉，同理没有被分配的页或者不是块首的页也不能被free
        assert(!PageReserved(p) && !PageProperty(p));
        //先把所有的标志位都置零
        p->flags = 0;
        //把物理内存释放了，所以没有虚拟地址会再指向它
        set_page_ref(p, 0);
    }
    //同样的道理，我释放了n页，那么个n页形成新的一个大一点的内存块，我们需要设置这个内存块的第一个
    //设置它后面跟了n个页并且目前可以被分配
    base->property = n;
    SetPageProperty(base);
    //遍历空闲链表，目的找到有没有地址空间是连在一起的内存块，把他们合并
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        //同理把le转换成page
        p = le2page(le, page_link);
        le = list_next(le);
        //意思就是如果我这个base块的结尾正好和块p的开头连在一起了，那就说明可以合并
        //这个就是基于base向后合并
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        //这个就是基于base向前合并
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            //注意这里也要删掉p因为后面我们会对base完成插入，如果不删除相当于插了两次
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    //遍历空闲链表，因为空闲链表是from low to high（见实验指导书153页）
    //只需要遍历找打第一个地址比他高的，把释放的内存插入到他前面就行
    le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            //必须保证不能合并的
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    //把第二个参数插入到第一个参数的前面
    list_add_before(le, &(base->page_link));
}

/* *
 * list_add_before - add a new entry
 * @listelm:    list head to add before
 * @elm:        new entry to be added
 *
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
}
```

实验二、pmm.c getpte函数

这个实验要干的一件事就是我给你一个虚拟地址，你把这个虚拟地址对应的二级页表项拿出来，如果这个虚拟地址还不存在一个二级页表那就分配一个。

```C++
pde_t *pdep = &pgdir[PDX(la)];
    if (!(*pdep & PTE_P)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
```

(1) pde_t*是什么

```c++
//按照命名规则的理解，pde_t*是一个二级页表的指针实际上我们通过逐层推进找到它的定义：
typedef uintptr_t pde_t;
typedef uint32_t uintptr_t;
typedef unsigned int uint32_t;
//果不其虽然，这个pde_t实际上就代表这一个32bits的地址
```

（2）pgdir是什么

```C++
//the kernel virtual base address of PDT
//上面是代码注释中对参数的解释
//在实验指导书164页对这个pgdir的解释如下：
//注意：pgdir实际不是表项，而是一级页表本身。实际上应该新定义一个类型pgd_t来表示一级页表本身
//如果还不理解没关系，先看下一个东西
//如果你已经理解了PDX，那么你就对pgdir[PDX(la)]这样的写法不陌生了
//也就是说，pgdir就是一级页表，我用一级页表的索引去里面找二级页表。
```

（3）PDX是什么

```C++
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).
//这些都是mmu.h中的注释，什么意思呢，就是ucore使用的二级页表，通过一个虚拟地址的前十位来索引一级页表，用中间十位索引二级页表，最后的十二位作为偏移寻找一个页里面的具体字节。
// page directory index
//那么PDX是用来干什么的呢，就是用来提取出一级页表索引的
#define PDX(la) ((((uintptr_t)(la)) >> PDXSHIFT) & 0x3FF)
#define PDXSHIFT        22                      // offset of PDX in a linear address
//看明白了吗，也就是说把一个虚拟地址右移22位是不是就只剩高10位了？再把它与001111111111进行与，那么就剩什么了？其实就剩原来的高10位本身了。
```

（4）PTE_P是什么

```C++
//到此为止，我们已经拿到了二级页表，但我们需要的是二级页表项，所以我们还需要做一次映射，但在做映射之前需要检查这个页表是否存在，怎么检查呢？就是用PTE_P
/* page table/directory entry flags */
#define PTE_P           0x001                   // Present
//上面的注释可以在mmu.h中找到，所以一个简单的与操作就可以判定该页表是否合法
```

（5）page2pa是什么

```c++
//先说结论，这个函数的功能是获得Page管理的物理页的物理地址
//page2pa的具体函数在pmm.h中实现，可以看到，该函数将一个地址左移了12位
//page就是我们刚刚传入的新被分配的页的地址
static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages;
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}
#define PGSHIFT         12                      // log2(PGSIZE)

//于是，还是要补充那个alloc_page是什么，毕竟新获得的这个Page就是alloc出来的。不难看出，默认在这里只分配一页
#define alloc_page() alloc_pages(1)
//下面是alloc_pages的具体实现，还是通过调用pmm_manager来实现的内存分配
struct Page *
alloc_pages(size_t n) {
    struct Page *page=NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag);
    return page;
}

//那么，减数pages是什么呢？
// virtual address of physicall page array
struct Page *pages;

//减数pages是一个虚拟地址，我们查看他的赋值过程
pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
//参照实验指导书第150页，和这里一模一样，由于bootloader加载ucore的结束地址（用全局指针变量end记录）以上的空间没有被使用，所以我们可以把end按页大小为边界去整后，作为管理页级物理内存空间所需的Page结构的内存空间
//所以说你看懂它是干什么的了吗
//pages指向了内存中第一个Page的虚拟地址，然后我又拿到了一个Page，我用page-pages就得到了page在pages中的偏移，这个偏移就是物理页的页号，然后我把它左移十二位就能得到物理地址
```

（6）KADDR是什么？

```c++
//kaddr其实就是把物理空间转换为内核虚拟空间的函数，问了助教，内核虚拟空间的意思就是，你已经知道了一个物理地址，但是你在写程序的时候没办法直接操作物理地址，必须要把他转为虚拟地址，这个函数就是起到的这个作用。，但是在内核通过物理地址转虚拟地址和在外部通过虚拟地址转物理地址的方式是不一样的，在内核中可以通过简单的算术运算来获得物理地址，但是在进程中需要顺着table一路找过来。
/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
#define KADDR(pa) ({                                                    \
            uintptr_t __m_pa = (pa);                                    \
            size_t __m_ppn = PPN(__m_pa);                               \
            if (__m_ppn >= npage) {                                     \
                panic("KADDR called with invalid pa %08lx", __m_pa);    \
            }                                                           \
            (void *) (__m_pa + KERNBASE);                               \
        })
#define KERNBASE            0xC0000000

//如果看过实验指导书到这里应该就不陌生了，这是说明东西呢？就是ucore中虚拟地址和物理地址的映射关系，具体可以查看实验指导书第162页
```

（6）PTE_U PTE_W PTE_P是什么

```c++
*pdep = pa | PTE_U | PTE_W | PTE_P;
//在mmu.h中他们的作用分别是：存在 用户可写 用户可读
#define PTE_P           0x001                   // Present
#define PTE_W           0x002                   // Writeable
#define PTE_U           0x004                   // User
//只有当一级二级页表的项都设置了用户写权限后，用户才能对对应的物理地址进行读写。 所以我们可以在一级页表先给用户写权限，再在二级页表上面根据需要限制用户的权限，对物理页进行保护
```

(7)简而言之：最后返回了个啥：

```c++
//从里向外看，第一步先获取了页表或者的入口地址：把最后面的12位全部置零
// address in page table or page directory entry
#define PTE_ADDR(pte)   ((uintptr_t)(pte) & ~0xFFF)
#define PDE_ADDR(pde)   PTE_ADDR(pde)
//然后获得这个东西的物理地址
//最后再使用一个指针指向这个地址，所以说最后拿到的是虚拟地址。
//利用这个页表的虚拟地址，就可以使用传入的虚拟地址的中间10位进行索引并取出对应的页表项了
// page table index
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x3FF)
#define PTXSHIFT        12                      // offset of PTX in a linear address
```

实验三：释放某虚地址所在的页并取消对应二级页表项的映射

```c++
if (*ptep & PTE_P) {
        struct Page *page = pte2page(*ptep);
        if (page_ref_dec(page) == 0) {
            free_page(page);
        }
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }
```

（1）pte2page是什么

```c++
//定义在pmm.h中，最后也是反悔了这个PTE_ADDR,在实验二中涉及到了，就是返回了页目录项或者页表的入口地址，也就是把低12位置零。
static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_P)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}
```

（2）page_ref_dec是什么？

```c++
//这个函数不难理解，就是把引用次数减一。
static inline int
page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
```

（3）如何理解下面这段代码：

```c++
if (page_ref_dec(page) == 0) {
            free_page(page);
   }
*ptep = 0;
//如果这个页表已经没有人引用了，就把他释放掉
//如果还有人在引用，那没关系，至少我需要清理二级页表，因为我已经绝对不再引用它了，怎么清除呢？就是把该页表的地址置0，二级页表不能再去寻找它了，但它并不影响其他页目录表对这个页表的引用。
```

（4）tlb_invalidate是什么

```c++
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
        //还记得CR3是说明吗？可以查看实验指导书第158页，他就指向了页目录表的基地址，而pgdir是什么呢？可以看一下实验二中的说明，他其实也就是页目录表，所以这一步就是为了判断被修改的页目录表究竟是不是现在的进程在被使用的那个页目录表
        invlpg((void *)la);
    }
}

//由于我们释放了一些进程正在使用的页表，所以说我们需要刷新tlb，保证tlb不会残留被释放的地址
static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
    return cr3;
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
}
//这里函数的目的就是取消va对应物理页之间的关联，相当于刷新TLB，每次我们调整虚拟页和物理页之间的映射关系的时候，我们都要刷新TLB，调用这个函数或invlpg汇编指令 .因为tlb直接保存了虚拟页和物理页之间的关系，所以当我们释放虚拟页的时候必须调整tlb
```

在上面的过程中我们有一个问题没有解决，就是关于init_memmap中的问题，为什么那个页要是保留的，这个问题需要从内存探测讲起。

一个基本的概念就是一开始操作系统是不知道计算机的物理内存是怎么分布的，于是需要BIOS中断来完成这个工作（在实模式下完成）于是BIOS通过系统内存映射地址描述符格式来表示系统物理内存布局

```c++
Offset    Size     Description
00h       8字节     base address               #系统内存块基地址
08h       8字节     length in bytes            #系统内存大小
10h       4字节     type of address range      #内存类型
```

用这样的格式来描述可用的计算机内存，其中type的取值是如下之一，表示不同内存块的不同性质

```
Values for System Memory Map address type:
#内存，是可以留给操作系统的
01h  memory, available to OS
#保留的，不能留给操作系统
02h  reserved, not available (e.g. system ROM, memory-mapped device)  
# ACPI表示高级配置和电源管理接口
03h  ACPI Reclaim Memory (usable by OS after reading ACPI tables)
04h  ACPI NVS Memory (OS is required to save this memory between NVS sessions)
othernot defined yet -- treat as Reserved
```

BIOS会将得到的信息写入内存es:di，保存地址范围描述符结构的缓冲区就是e820map，他的定义如下：

```C++
struct e820map {
    int nr_map;
        struct {
            long long addr;
            long long size;
            long type;
        } map[E820MAX];
};
//常数值是已经定义好的20，是其中的实体个数
#define E820MAX             20      // number of entries in E820MAP
```

探测的代码也在下面贴出来了，

```C++
probe_memory:
//对0x8000处的32位单元清零,即给位于0x8000处的
//struct e820map的成员变量nr_map清零
movl $0, 0x8000
xorl %ebx, %ebx
//表示设置调用INT 15h BIOS中断后，BIOS返回的映射地址描述符的起始地址
movw $0x8004, %di
start_probe:
movl $0xE820, %eax // INT 15的中断调用参数
//设置地址范围描述符的大小为20字节，其大小等于struct e820map的成员变量map的大小
movl $20, %ecx
//设置edx为534D4150h (即4个ASCII字符“SMAP”)，这是一个约定
movl $SMAP, %edx
//调用int 0x15中断，要求BIOS返回一个用地址范围描述符表示的内存段信息
int $0x15
//如果eflags的CF位为0，则表示还有内存段需要探测
jnc cont
//探测有问题，结束探测
movw $12345, 0x8000
jmp finish_probe
cont:
//设置下一个BIOS返回的映射地址描述符的起始地址
addw $20, %di
//递增struct e820map的成员变量nr_map
incl 0x8000
//如果INT0x15返回的ebx为零，表示探测结束，否则继续探测
cmpl $0, %ebx
jnz start_probe
finish_probe:
```

上面的代码我也没看太懂，但有一件事很重要就是BIOS探测出来的结果存在了0x8000,之后page_init函数会来这里找e820map来完成对机器的物理内存管理。

管不了那么多了，直接来看pmm.c中page_init的代码：

```c++
//这玩意定义的就是上面我们说的type of address range 
#define E820_ARM            1       // address range memory
#define E820_ARR            2       // address range reserved
/* All physical memory mapped at this address */
#define KERNBASE            0xC0000000
#define KMEMSIZE            0x38000000                  // the maximum amount of physical memory
#define KERNTOP             (KERNBASE + KMEMSIZE)
//首先，这是第一段代码
//这一行的意思就是去找BIOS写好的那个结构，当然毫无疑问的，0x8000当然要从kernelBase开始算起，当然，这个东西是虚拟地址
struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
//遍历每一个探测到的计算机内存块
    for (i = 0; i < memmap->nr_map; i ++) {
        //找到起始地址和终止地址
        //其实需要注意的一点就是在做内存探测时候还没有虚拟地址，所以探测到的每一个地址都是物理地址，都是从0开始的物理地址，这一点不要弄错了
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        //如果这个内存块的类型是操作系统可用的，就查一下，我最多能使用的地址空间变了没有
        if (memmap->map[i].type == E820_ARM) {
            //这两个是啥意思我解释下，就是如果有更大的end说明有更大的maxpa，因为探测出的都是物理地址，没有做虚拟映射，所以end和maxpa实际上是一致的。而第二个判断根据助教的意思就是如果begin的大小超过了KMEMSIZE是不会有映射的，因为更高的地址是不可用的。
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
//设定了一个上界，不能超过KMEMSIZE。因为maxpa的概念是我最多能用的物理地址是多少所以他的上线就设在KMEMSIZE
//注意理解kmemsize的含义，他的含义是我最多能使用的kernel的大小是多少，而不是最后的地址是多少
    if (maxpa > KMEMSIZE) {
        maxpa = KMEMSIZE;
    }
// “end”表示BSS段的结束地址,如果你忘记了BSS段的位置的话可以去看一看实验指导手册第152页的图片
    extern char end[];
//算一下要管理这么大的空闲需要多少页
    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
//然后把所有操作系统能管的内存全部置成reserved
//到这里似乎能够回答那个问题了，看吧，所有操作系统能用的页全都被置成reserved了，所以你在分配它的时候才要把他解开。
    for (i = 0; i < npage; i ++) {
        SetPageReserved(pages + i);
    }
```

```c++
//第二阶段
//先计算一个从pages开始能留给其他进程分配的内存空间，这个空间并不是从end开始就可以，而是还要跑去存储管理物理页的Page所占的空间，剩下的才能留给其他进程使用
uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        if (memmap->map[i].type == E820_ARM) {
            //这个就很好理解了，要分配的物理页不能低于freePages
            if (begin < freemem) {
                begin = freemem;
            }
            //同理最大也不能超过KMEMSIZE
            if (end > KMEMSIZE) {
                end = KMEMSIZE;
            }
            //在这中间的块都是可以分配的，使用init_memmap进行分配，在这个时候这些页都还是reserved的状态，所以你知道为什么这个函数里面要有保证所有的页都是reserved的断言了吧，这样这些页就可以被当成分配给进程的物理页了
            if (begin < end) {
                begin = ROUNDUP(begin, PGSIZE);
                end = ROUNDDOWN(end, PGSIZE);
                if (begin < end) {
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
```

然后再说一下这两张图的关系：这张图片表示的一个机器的内存空间的物理地址！！！什么ucore里的0xc0000000在这里都不好用，因为这个就是实打实的物理地址

[![76ffca442da6ac060319e3c6508391b.png](https://i.postimg.cc/nhyMFYM7/76ffca442da6ac060319e3c6508391b.png)](https://postimg.cc/w1k9FNXT)

这张图片的含义就是虚拟地址了，我们可以简单的理解为下面这张图里的0XC0000000就代表着上面图里的0x00000000，下图中的内核空间就对应着上面图中的从0x00000000到实际物理内存空间结束地址

![4ab7303c8a692bb764078be195678b5.png](https://i.postimg.cc/ryHT2yDR/4ab7303c8a692bb764078be195678b5.png)

[](https://postimg.cc/Bt2kx0cJ)



