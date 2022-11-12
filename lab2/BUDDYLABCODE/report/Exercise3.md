## 释放某虚地址所在的页并取消对应二级页表项的映射

参考链接：

[(49条消息) 操作系统实验ucore lab2_裕东方的博客-CSDN博客](https://blog.csdn.net/yyd19981117/article/details/86692154?ops_request_misc={"request_id"%3A"166648868916782414926884"%2C"scm"%3A"20140713.130102334.."}&request_id=166648868916782414926884&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~top_positive~default-2-86692154-null-null.article_score_rank_blog&utm_term=ucore lab2&spm=1018.2226.3001.4450)

[清华大学操作系统课程 ucore Lab2 物理内存管理 实验报告 - 简书 (jianshu.com)](https://www.jianshu.com/p/abbe81dfe016)

### 练习要求	

当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在kern/mm/pmm.c中的page_remove_pte函数。

### 具体实现

```
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
   	if (*ptep & PTE_P) {
        struct Page *page = pte2page(*ptep);
        if (page_ref_dec(page) == 0) {
            free_page(page);
        }
        *ptep = 0;
        tlb_invalidate(pgdir, la)
    }
}
```

下面对这段代码进行详细解释：

**首先是参数，从左至右：**

对于第一个参数pgdir和第三个参数ptep一起介绍，参看mmlayout和defs两个头文件可以知道，pde_t和pte_t本质上都是32位的无符号整数

```
//mmlayout.h
typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

//defs.h
typedef uint32_t uintptr_t;
typedef unsigned int uint32_t;
```

pde_t全称为"page directory entry"，即一级页表的表项；pte_t全称为"page table entry"，即二级页表的表项

第二个参数是一个32位无符号整形的线性地址la

进入函数，首先进行if判断，即确认这个页是存在的，*ptep即得到ptep地址所存储的pte_t类型的页表项，将这一页表项和PTE_P进行按位与（本质上就是判断最后一位是否是1，是1代表存在）。PTE_P是页表项标记位中的一位，表示是否存在，它和其他标志位一起定义在mmu.h中：

```
/* page table/directory entry flags */
#define PTE_P           0x001         // Present
#define PTE_W           0x002         // Writeable
#define PTE_U           0x004         // User
#define PTE_PWT         0x008         // Write-Through
#define PTE_PCD         0x010         // Cache-Disable
#define PTE_A           0x020         // Accessed
#define PTE_D           0x040         // Dirty
#define PTE_PS          0x080         // Page Size
#define PTE_MBZ         0x180         // Bits must be zero
#define PTE_AVAIL       0xE00         // Available for                                             // software use
// The PTE_AVAIL bits aren't used by the kernel or interpreted by the hardware, so user processes are allowed to set them arbitrarily.

#define PTE_USER        (PTE_U | PTE_W | PTE_P)
```

如果这个页存在，那么使用pte2page获取其物理地址。pte2page函数在pmm.h中定义如下：

```
static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_P)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}
```

最后一行的pa2page函数在pmm.h中定义如下：

```
static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa)];
}
```

即给定一个页表项，如果不存在，就报错；否则就通过PTE_ADDR（见下）得到页表项在页表中的地址（即将PTE32位的低12位置0）：

```
#define PTE_ADDR(pte)   ((uintptr_t)(pte) & ~0xFFF)
```

```
// page number field of address
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)

#define PTXSHIFT        12    // offset of PTX in a linear                                 // address
```

然后通过PPN宏（见上）将这个地址右移12位得到20位地址，这个应该代表的是页的索引（即第几个页），判断这个索引是否比总页数多，多则报错，否则返回pages数组中的第PPN(PTE_ADDR(pte))个Page。对于线性地址的各部分结构如下：

```
// A linear address 'la' has a three-part structure as follows:
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/

// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),use PGADDR(PDX(la), PTX(la), PGOFF(la)).
```

于是，我们就通过pte2page得到了*ptep页表项对应的物理内存页page。下面解释一下page_ref_dec函数。

page_ref_dec定义在pmm.h中：

```
static inline int
page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
```

可以看出来，这个函数试探一下当前这个页被引用的次数，如果只被上一级（二级页表）引用了一次，那么减一以后就是0，页和对应的二级页表都可以直接被释放（将二级页表置0是取消映射，这里直接调用free_page，free_page应该是练习1的内容）；反之，如果还有更多的页表应用了它，那就不能释放掉这个页，但是取消对应二级页表项的映射，也就是把映射的入口（传入的二级页表）置0（即*ptep = 0;语句），之后调用了tlb_invalidate函数：

```
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
        invlpg((void *)la);
    }
}
```

这里面的rcr3和invlpg函数定义在x86.h中：

```
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
```

**这两个函数没太看懂。。。**

（网上的解释是：刷新TLB，保证TLB中的缓存不会有错误的映射关系）



#### 回答问题：

1）数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

存在对应关系：由于页表项中存放着对应的物理页的物理地址，因此可以通过这个物理地址来获取到对应到的Page数组的对应项，具体做法为将物理地址除以一个页的大小，然后乘上一个Page结构的大小获得偏移量，使用偏移量加上Page数组的基地址皆可以或得到对应Page项的地址；

2）如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

由于在完全启动了ucore之后，虚拟地址和线性地址相等，都等于物理地址加上0xc0000000，如果需要虚拟地址和物理地址相等，可以考虑更新gdt，更新段映射，使得virtual address = linear address - 0xc0000000，这样的话就可以实现virtual address = physical address；

