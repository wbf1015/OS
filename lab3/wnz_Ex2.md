## Ex2 实现FIFO算法

在Lab3中实现的页换出并没有设计内核线程、用户进程，只是简单实现page、block、frame的换出换入。

为了实现页替换算法，在`Page`结构体定义上添加了一个成员变量：

```
list_entry_t pra_page_link;     // used for pra (page replace algorithm)
```

在FIFO算法中用一个双向链表将可以被换出的`Page`连接起来，链表最前面的`Page`是最新换入到内存的页。所以FIFO算法要做的就是，维护这个双向链表，每次有一个页可以被换出时就插入链表最前面；当需要换出页时，就把链表最后一个页换出去。

**注意，在这里实现的换入换出FIFO策略，都只是对`mm_struct`这个结构体里维护的一个双向链表结构，对一些被虚拟地址映射到的页进行策略替换，如果被换入就是插入双向链表、被换出就是从双向链表中删除，而对实际物理页和磁盘帧的换入传出在`swap.c`的`swap_out和swap_in`实现。**

**插入一个可以被换出的页：**

```c++
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
}
```

(不懂为什么要传入这么多参数，可能是别的替换策略要用？)

其实要做的就是`list_add(head, entry);`这个而已，就是为了将这个换入的页加入双向链表最前面，即`head->next`指向`entry`。

这样就简单的实现了FIFO的页换入。**什么时候需要换入？**只有发生`do_pagefault`（页中断），并且找到一个`pte`指向`swappable`的页，调用`swap_in()`，将磁盘中内容换入，然后`_fifo_map_swappableFIFO`记录该`page`。

**换出一个页：**

```c++
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le=head->prev;
     assert(head!=le);
     struct Page *p=le2page(le,pra_page_link);
     list_del(le);
     *ptr_page=p; 
     return 0;
}
```

和从头部插入相反，换出一个页就是将链表尾部的页删除，然后按照注释要求，将参数中的`*ptr_page`置为被换出的页的地址。