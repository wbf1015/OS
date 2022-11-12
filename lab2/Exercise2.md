Exercise2

实验目的：补全函数，给一个虚拟地址，返回一个页表项

参数释意：

pgdir：其实就是一级页表本身（见实验指导书164）

la：需要被查找的线性地址

PT：逻辑值，表示是否需要创建页表。1表示需要，0表示不需要

需要了解的知识：除第一个概念外，其他应用到的知识均以代码出现先后排列

（一）

想要弄清楚第二个实验就要弄明白一下几个概念的区别：

PDT(页目录表)

PDE(页目录项)

PTT(页表)

PTE(页表项)

简而言之：页表保存页表项，页表项被映射到物理内存地址；页目录表保存页目录项，页目录项映射到页表。

（二）

pdt：unsigned int类型，是一级页表的表项，前十位

pte：unsigned int类型，是二级页表表项，中间十位

根据实验指导书164页我们应明确：

pgdir：实际不是表项，而是一级页表本身

uintptr_t：表示为线性地址，由于段式管理只做直接映射，所以它也是逻辑地址

(三)

PDX的作用是取出32位地址的前十位，获取他的一级页表表项

```c++
// page directory index pdxshift=22
#define PDX(la) ((((uintptr_t)(la)) >> PDXSHIFT) & 0x3FF)
```

（四）

PTE_P来表示这个页表已经存在了

```c
#define PTE_P           0x001                   // Present
```

（五）

```c++
set_page_ref		//设置引用次数
```

（六）

```c
page2pa(page)    			//设置物理地址
```

ps：转化的具体过程我也没看太明白，问了助教也没回

具体实现过程如下：首先定义一个pages变量，指向第一个我能分配给其他进程的4k空间

```c++
pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
```

首先调用page2ppn，计算出与所谓的可用空间“基址”的距离，由于所有的页都是4K为大小的，每一个页的起始地址的最后12位都是0，所以最后左移12位

```c++
static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages;
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}
```

（七）

KADDR返回二级页表所对应的线性地址

```c++
#define KADDR(pa) ({                                                    \
            uintptr_t __m_pa = (pa);                                    \
            size_t __m_ppn = PPN(__m_pa);                               \
            if (__m_ppn >= npage) {                                     \
                panic("KADDR called with invalid pa %08lx", __m_pa);    \
            }                                                           \
            (void *) (__m_pa + KERNBASE);                               \
        })

```

（八）控制位设置

```
PTE_P 0x001 表示物理内存页存在

PTE_W 0x002 表示物理内存页内容可写

PTE_U 0x004 表示可以读取对应地址的物理内存页内容
```

整体代码：

```c++
pde_t *pdep = &pgdir[PDX(la)];//获取页表
    if (!(*pdep & PTE_P)) {//如果页表不存在，尝试新建一个页表
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//如果不需要创建或者分配失败，返回null
            return NULL;
        }
        set_page_ref(page, 1);//第一次创建，只有一个引用
        uintptr_t pa = page2pa(page);//转换成物理地址
        memset(KADDR(pa), 0, PGSIZE);//将对应物理地址置零
        *pdep = pa | PTE_U | PTE_W | PTE_P;//设置控制位
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
	//KADDR(PDE_ADDR(*pdep)):这部分是由页目录项地址得到关联的页表物理地址， 再转成虚拟地址
    //PTX(la)：返回虚拟地址la的页表项索引
    //最后返回的是虚拟地址la对应的页表项入口地址
}
```

