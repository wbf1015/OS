## Challenge1：实现识别dirty bit的extended clock页替换算法

### 算法描述

在LRU类算法中，选择淘汰一个页只考虑了它是否被访问过，但实际情况还需要考虑被淘汰的页面是否被修改过。这是因为淘汰修改过的页面需要写回磁盘，使得置换的代价大于未修改的页。因此，extended clock算法的思路增加了优先淘汰没有被修改的页的考量，从而减少磁盘操作的次数、提高效率。

由于extended clock算法需要同时考虑被淘汰的页是否被访问和是否被修改。因此每一页对应的pte中需要分别设置2个bit，一个引用位和一个修改位。当该页被访问时，MMU把引用位置1；当该页被写时，MMU把修改位置1。这样2个bit就存在4种情况：

- (0,0): 最近未使用也未被修改，首先选择淘汰此页
- (0,1): 最近未使用但被修改，其次选择淘汰此页
- (1,0): 最近使用但未被修改，再次选择淘汰此页
- (1,1): 最近未使用也未被修改，最后才选择淘汰此页

### 算法实现

在FIFO的基础上，实现swap_out_victim即可，同时其余函数沿用`FIFO`：

该函数查找一块可用于换出的物理页 即!PTE_A & !PTE_D（未使用未修改），最多只需要遍历三次：

- 第一次遍历链表查找 ，同时重置每一页的PTE_A（设置为未使用），为第二次遍历的条件进行铺垫
- 第二次遍历链表查找 ，同时重置每一页的PTE_D（设置为未修改），为第三次遍历的条件进行铺垫
- 第三次遍历链表查找，则肯定能找到未使用未修改的页

![image](https://s1.ax1x.com/2022/11/18/zuCtsI.png)

其中的PTE_A和PTE_D标志位在mmu.h中定义

然后直接在swap_fifo.c中添加如下代码即可，在使用extended clock算法时只需要把原来的`struct swap_manager swap_manager_fifo`注释并使用新的即可

```
static int
_extend_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
	//这几行和FIFO一样
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
        assert(head != NULL);
    assert(in_tick==0);

    // 三次遍历查找可换出的页
    for(int i = 0; i < 3; i++)
    {
        list_entry_t *le = head->prev;
        assert(head!=le);
        while(le != head)
        {
            struct Page *p = le2page(le, pra_page_link);
            pte_t* ptep = get_pte(mm->pgdir, p->pra_vaddr, 0);
            // 如果未使用且未修改，则直接分配
            if(!(*ptep & PTE_A) && !(*ptep & PTE_D))
            {
                list_del(le);
                assert(p !=NULL);
                *ptr_page = p;
                return 0;
            }
            // 如果在第一次查找中，访问到了一个已经使用过的PTE，则标记为未使用。
            if(i == 0)
                *ptep &= ~PTE_A;
            // 如果在第二次查找中，访问到了一个已修改过的PTE，则标记为未修改。
            else if(i == 1)
                *ptep &= ~PTE_D;

            le = le->prev;
            // 遍历了一回，肯定修改了标志位，所以要刷新TLB
            tlb_invalidate(mm->pgdir, le);
        }
    }
    // 按照前面的assert与if，不可能会执行到此处，所以return -1
    return -1;
}

struct swap_manager swap_manager_fifo =
{
     .name            = "extend_clock swap manager",
     .init            = &_fifo_init,
     .init_mm         = &_fifo_init_mm,
     .tick_event      = &_fifo_tick_event,
     .map_swappable   = &_fifo_map_swappable,
     .set_unswappable = &_fifo_set_unswappable,
     .swap_out_victim = &_extend_clock_swap_out_victim,
     .check_swap      = &_fifo_check_swap,
};
```

