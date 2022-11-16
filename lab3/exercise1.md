LAB3练习一

看着还不错的blog：https://www.cnblogs.com/xiaoxiongcanguan/p/13854711.html

总体思路（主要内容为复制实验指导书）

本次实验主要完成ucore内核对虚拟内存的管理工作。其总体设计思路还是比较简单，即：

（1）首先完成初始化虚拟内存管理机制，即需要设置好哪些页需要放在物理内存中，哪些页不需要放在物理内存中，而是可被换出到硬盘上。这会涉及到：完善建立页表映射、页访问异常处理操作等函数实现。

（2）然后就执行一组访存测试，看看我们建立的页表项是否能够正确完成虚实地址映射，是否正确描述了虚拟内存页在物理内存中还是在硬盘上，是否能够正确把虚拟内存页在物理内存和硬盘之间进行传递，是否正确实现了页面替换算法等。

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

初始化的工作主要分为三步:**pmm_init()完成物理内存初始化（Lab2的内容）、pic_init和idt_init来初始化异常和终端（lab1内容）**

首先是初始化过程。参考ucore总控函数init的代码，可以看到在调用完成虚拟内存初始化的vmm_init函数之前，需要首先调用pmm_init函数完成物理内存的管理，这也是我们lab2已经完成的内容。接着是执行中断和异常相关的初始化工作，即调用pic_init函数和idt_init函数等，这些工作与lab1的中断异常初始化工作的内容是相同的。

在调用完idt_init函数之后，将进一步调用三个**lab3中才有的新函数vmm_init、ide_init和swap_init**。这三个函数涉及了本次实验中的两个练习。

**第一个函数vmm_init是检查我们的练习1是否正确实现了**。为了表述不在物理内存中的“合法”虚拟页，需要有数据结构来描述这样的页，为此ucore建立了**mm_struct和vma_struct数据结构**（接下来的小节中有进一步详细描述），假定我们已经描述好了这样的“合法”虚拟页，当ucore访问这些“合法”虚拟页时，会由于没有虚实地址映射而产生页访问异常。如果我们正确实现了练习1，则**do_pgfault函数会申请一个空闲物理页**，并建立好虚实映射关系，从而使得这样的“合法”虚拟页有实际的物理页帧对应。这样练习1就算完成了。

**ide_init和swap_init是为练习2准备的。**由于页面置换算法的实现存在对硬盘数据块的读写，所以ide_init就是完成对用于页换入换出的硬盘（简称swap硬盘）的初始化工作。完成ide_init函数后，ucore就可以对这个swap硬盘进行读写操作了。swap_init函数首先建立swap_manager，swap_manager是完成页面替换过程的主要功能模块，其中包含了页面置换算法的实现（具体内容可参考5小节）。然后会进一步调用执行check_swap函数在内核中分配一些页，模拟对这些页的访问，这会产生页访问异常。如果我们正确实现了练习2，就可通过do_pgfault来调用swap_map_swappable函数来查询这些页的访问情况并间接调用实现页面置换算法的相关函数，把“不常用”的页换出到磁盘上

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

接下来的内容会以我的叙述为主：

首先，先要知道练习1要干什么，就是要填写一个函数：do_pgfault

```c++
//看看注释是怎么说的，这个函数就是用来处理缺页异常的，也就是当cpu没有办法正常的将一个虚拟地址转换为物理地址的时候就会调用这个函数，至于为什么会无法正常转换我们稍后再说
//总是我们现在知道了exercise1就是要实现一个缺页异常处理函数
//do_pgfault - interrupt handler to process the page fault execption
```

那么接下来呢，我们还是要先从lab3中新定义的数据结构开始说起

第一个重要的数据结构：vma_struct

```c++
//从注释学习，这个数据结构描述了什么东西呢，这个数据结构描述了一块连续的虚拟地址空间，从vm_start直到vm_end，并且他总共有五个元素
//vm_mm:，指向一个比vma_struct更高的抽象层次的数据结构mm_struct，这里把一个mm_struct结构的变量简称为mm变量。这个数据结构表示了包含所有虚拟内存空间的共同属性,也是第二个重要的数据结构，这个都不太重要，后面会仔细说，请看代码中的注释，所有指向同一个vm_mm的vma_struct结构都使用同一张页目录表，也就是说（暂时的理解）所有4G虚拟空间（一个进程所能拥有的最大内存）都由一个vm_mm来作为保管
//vm_start和vm_end描述了一个连续地址的虚拟内存空间的起始位置和结束位置，这两个值都应该是PGSIZE对齐的，而且描述的是一个合理的地址空间范围（即严格确保 vm_start < vm_end的关系）；
//list_link是一个双向链表，按照从小到大的顺序把一系列用vma_struct表示的虚拟内存空间链接起来，并且还要求这些链起来的vma_struct应该是不相交的，即vma之间的地址空间无交集；
//vm_flags表示了这个虚拟内存空间的属性

// the virtual continuous memory area(vma), [vm_start, vm_end), 
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 
//定义于vmm.h
struct vma_struct {
    struct mm_struct *vm_mm; // the set of vma using the same PDT 
    uintptr_t vm_start;      // start addr of vma      
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint32_t vm_flags;       // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
};

//在接受lab2折磨之后对list_entry_t应该是不陌生了：就是一个嵌入式的对象，然后通过函数计算偏移地址来找到被嵌入对象的指针。
struct list_entry {
    struct list_entry *prev, *next;
};
typedef struct list_entry list_entry_t;

//flag的定义如下，分别代表可读可写可执行
#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

//学长的回复，加深理解：实际linux里面，每一个process都是有一个自己的mm_struct的，里面定义了很多东西，就包括指向它自己页目录表的指针，而同一个进程的不同线程，他们都共享这一个mm_struct
```

第二个重要数据结构：

```c++
//mmap_list是双向链表头，链接了所有属于同一页目录表的虚拟内存空间
//mmap_cache是指向当前正在使用的虚拟内存空间，由于操作系统执行的“局部性”原理，当前正在用到的虚拟内存空间在接下来的操作中可能还会用到，这时就不需要查链表，而是直接使用此指针就可找到下一次要用到的虚拟内存空间。由于mmap_cache 的引入，可使得 mm_struct 数据结构的查询加速 30% 以上。注意这里保存的是一个vma_struct类型，这个类型里可能存了好几个虚拟page，所以具有较强的局部性
//pgdir 所指向的就是 mm_struct数据结构所维护的页目录表。通过访问pgdir可以查找某虚拟地址对应的页表项是否存在以及页表项的属性等。
//map_count记录mmap_list 里面链接的 vma_struct的个数。
//sm_priv指向用来链接记录页访问情况的链表头，这建立了mm_struct和后续要讲到的swap_manager之间的联系。

// the control struct for a set of vma using the same PDT
//mm数据结构存储了所有使用同一个PDT（页目录表）的虚拟地址
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    pde_t *pgdir;                  // the PDT of these vma
    int map_count;                 // the count of these vma
    void *sm_priv;                   // the private data for swap manager
};
```

具体的结构示意图可以参考下面这张图片：mm_struct负责链接起使用一个PDT的vma_struct，而vma_struct则代表了一些从小到大排序的虚拟页，这些虚拟页因为都是4k大小对齐的，所以正好可以对应一个二级页表项，而每一个二级页表项都代表了一个物理页帧（也是4k）

![b7068b26de6af435ac080a66382ff11.png](https://img1.imgtp.com/2022/11/16/DK9LywWi.png)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

介绍完了基本的数据结构知识，我们可以将目光放在缺页处理函数函数上了，看一看缺页异常处理函数是怎样工作的：

实现虚存管理的一个关键是page fault异常处理，其过程中主要涉及到函数 -- do_pgfault的具体实现。比如，在程序的执行过程中由于某种原因（页框不存在/写只读页等）而使 CPU 无法最终访问到相应的物理内存单元，即**无法完成从虚拟地址到物理地址映射时，CPU 会产生一次页访问异常，从而需要进行相应的页访问异常的中断服务例程**。这个页访问异常处理的时机被操作系统充分利用来完成虚存管理，即实现“按需调页”/“页换入换出”处理的执行时机。当相关处理完成后，页访问异常服务例程会返回到产生异常的指令处重新执行，使得应用软件可以继续正常运行下去。

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

具体而言，当启动分页机制以后，**如果一条指令或数据的虚拟地址所对应的物理页框不在内存中或者访问的类型有错误（比如写一个只读页或用户态程序访问内核态的数据等），就会发生页访问异常**。产生页访问异常的原因主要有：

- 目标页帧不存在（页表项全为0，即**该线性地址与物理地址尚未建立映射或者已经撤销**)；
- **相应的物理页帧不在内存中**（页表项非空，但Present标志位=0，比如在swap分区或磁盘文件上)，这在本次实验中会出现，我们将在下面介绍换页机制实现时进一步讲解如何处理；
- **不满足访问权限**(此时页表项P标志=1，但低权限的程序试图访问高权限的地址空间，或者有程序试图写只读页面).

当出现上面情况之一，那么就会产生页面page fault（#PF）异常。**CPU会把产生异常的线性地址存储在CR2中，并且把表示页访问异常类型的值（简称页访问异常错误码，errorCode）保存在中断栈中。**

页访问异常错误码（errorcode）有32位。位0为１表示对应物理页不存在；位１为１表示写异常（比如写了只读页；位２为１表示访问权限异常（比如用户态程序访问内核空间的数据）也就分别代表了上面说的三种页访问异常出现的原因。

CR2是页故障线性地址寄存器，**保存最后一次出现页故障的全32位线性地址**。CR2用于发生页异常时报告出错信息。当发生页异常时，处理器把**引起页异常的线性地址保存在CR2中。**操作系统中对应的中断服务例程可以检查CR2的内容，从而**查出线性地址空间中的哪个页引起本次异常。**

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

产生页访问异常后，CPU硬件和软件都会做一些事情来应对此事。首先**页访问异常也是一种异常**，所以针对一般异常的硬件处理操作是必须要做的，即**CPU在当前内核栈保存当前被打断的程序现场**，即依次压入当前被打断程序使用的EFLAGS，CS，EIP，errorCode；由于页访问异常的中断号是0xE，**CPU把异常中断号0xE对应的中断服务例程的地址（vectors.S中的标号vector14处）加载到CS和EIP寄存器中，开始执行中断服务例程**。这时ucore开始处理异常中断，首先需要保存硬件没有保存的寄存器。在vectors.S中的标号vector14处先把中断号压入内核栈，然后再在trapentry.S中的标号__alltraps处把DS、ES和其他通用寄存器都压栈。自此，被打断的程序执行现场（context）被保存在内核栈中。

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

产生页访问异常后，**CPU把引起页访问异常的线性地址装到寄存器CR2中，并给出了出错码errorCode，说明了页访问异常的类型。ucore OS会把这个值保存在struct trapframe 中tf_err成员变量中。**而中断服务例程会调用页访问异常处理函数do_pgfault进行具体处理。这里的页访问异常处理是实现按需分页、页换入换出机制的关键之处。

ucore中do_pgfault函数是完成页访问异常处理的主要函数，它根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找**此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限，**如果在此范围内并且权限也正确，这认为这是一次合法访问，但没有建立虚实对应关系。所以需要分配一个空闲的内存页，并修改页表完成虚地址到物理地址的映射，刷新TLB，然后调用iret中断，返回到产生页访问异常的指令处重新执行此指令。如果该虚地址不在某VMA范围内，则认为是一次非法访问。

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

话不多说，基础知识都了解完了，直接看代码：

```c++
//page fault number 全局页异常处理数
volatile unsigned int pgfault_num=0;
/* do_pgfault - interrupt handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    //从mm所保存的合法虚拟页中找是否有线性地址addr，实际上是去mm所指向的一群vma结构中去找
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;//// 全局页异常处理数自增1
    //If the addr is in the range of a mm's vma?
    //没找到，或者找的的不符合规定
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    //check the error_code
    //根据errorcode进行不同的处理
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
            //访问的物理页存在，且发生了写异常（写了只读页）
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
            //访问的映射页表项不存在、且发生的是写异常
        if (!(vma->vm_flags & VM_WRITE)) {//对应的vma块映射的虚拟内存空间是不可写的,权限校验失败
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
            //bit0为1，bit1为0，访问的映射页表项存在，且发生的是读异常(可能是访问权限异常)
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
            //访问的映射页表项不存在，且发生的是读异常或者可执行异常（反正就是不能写）
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }
    //如果成功来到的这里，那么说明发生了缺页异常，想要读写或执行的权限正确，并且虚拟页也合法，只是他不在内存里，我们要把他换进来
    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    //// 构造需要设置的缺页页表项的perm权限 (为什么不设置读写权限呢？因为设置的是页表项的flag，而不是vma的flag)
    uint32_t perm = PTE_U;//用户态的
    if (vma->vm_flags & VM_WRITE) {
        perm |= PTE_W;//是否科协
    }
    addr = ROUNDDOWN(addr, PGSIZE);//向下取整拿一个页对齐的地址

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;//页表项
    /*LAB3 EXERCISE 1: YOUR CODE
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */
#if 0
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {//获得虚拟地址对应的一个页目录项，使用lab2-exercise2的函数，忘了可以回去看看
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    //如果物理地址根本不合法
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {//磁盘交换初始化是否完成
            struct Page *page=NULL;
            //// 将addr线性地址对应的物理页数据从磁盘交换到物理内存中(令Page指针指向交换成功后的物理页)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            //// 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系(perm标识这个二级页表的各个权限位)
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);
            //page数据结构中的新元素，是用于交换算法的，具体功能尚未得知，addr就是缺页发生的地址，如果能执行到这里的话就是想要访问的不在内存中的虚拟地址
            page->pra_vaddr = addr;
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
failed:
    return ret;
}
```

find_vma函数：

```c++
// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;//要返回的vma
    if (mm != NULL) {
        //先指向cache
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {//要找的vma不是cache，才要找，否则直接返回cache
                bool found = 0;//用来判断循环里是否找到
                list_entry_t *list = &(mm->mmap_list), *le = list;//找mm的list遍历所有vma
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {//找到了
                        found = 1;
                        break;
                    }
                }
                if (!found) {//如果没找到返回null
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;//更新cache
        }
    }
    return vma;
}

//le2vma其实和le2page什么的差别不大,也是使用偏移的地址进行转换的
#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)
/* *
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member
 * @type:   the type of the struct this is embedded in
 * @member: the name of the member within the struct
 * */
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))
```

页表项的flag，不要忘记咯

```c++
/* page table/directory entry flags */
#define PTE_P           0x001                   // Present
#define PTE_W           0x002                   // Writeable
#define PTE_U           0x004                   // User
#define PTE_PWT         0x008                   // Write-Through
#define PTE_PCD         0x010                   // Cache-Disable
#define PTE_A           0x020                   // Accessed
#define PTE_D           0x040                   // Dirty
#define PTE_PS          0x080                   // Page Size
#define PTE_MBZ         0x180                   // Bits must be zero
#define PTE_AVAIL       0xE00                   // Available for software use
```

swap_init_ok

```c++
//定义在swap.c中
volatile int swap_init_ok = 0;

//这个变量在swap_init（）函数中被初始化，我的理解是只有这个位为1才能够进行磁盘交换
int
swap_init(void)
{
     swapfs_init();

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
     int r = sm->init();
     
     if (r == 0)
     {
          swap_init_ok = 1;
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}

```

代表exercise1完成成功的截图：

![738a6a3dbb57005e122a2d3fbec2a05.png](https://img1.imgtp.com/2022/11/16/QGYSCX3u.png)

当然因为只做了exercise1，还有很多问题没有解决，我都写在下面了：

1、swap函数及其实现细节：

```c++
int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();//因为分配了一个物理内存页所以分配一个Page
     assert(result!=NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);//获取对应线性地址的页目录项
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
     *ptr_result=result;//返回对应于相应页目录项的page的指针
     return 0;
}

swapfs_read的实现：//就是这里没看懂
int
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}
```

page_insert函数

```c++
//page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
//与其说这个是让Page结构的物理地址和一个la对应，不如说将一个页目录表设置为对应la的物理地址
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);//获取对应线性地址的页目录项
    if (ptep == NULL) {
        return -E_NO_MEM;//不懂啥意思，也没定义，不管了
    }
    page_ref_inc(page);//page引用数加一，很好理解
    if (*ptep & PTE_P) {
        struct Page *p = pte2page(*ptep);//拿到对应pte所对应的物理页的page结构
        if (p == page) {//和传进来的相等，就减1，也就是说这个函数本来是想为一个页对应一个新的pte，但是到这里发现根本不用新对应，因为我想要对应的早就存在了，那就不用管了
            page_ref_dec(page);
        }
        else {
            page_remove_pte(pgdir, la, ptep);//lab2-exerciese3的代码，就是解除一个page和pte的映射关系
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;//将对应的页目录项的内容设置为page对应的物理地址
    tlb_invalidate(pgdir, la);//刷新tlb
    return 0;
}
//中间函数定义及实现：
static inline struct Page *
pte2page(pte_t pte) {//通过pte找page
    if (!(pte & PTE_P)) {//不存在
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));//清空后12位获得按4k对齐的页的地址
}
static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa)];//右移12位，当做索引拿page
}
```

swap_map_swappable函数

```c++
//在调用时swap_in的值为1
int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
}
//sm是swapmanager也就是交换管理器
static struct swap_manager *sm;
//但是具体他的swappable函数是在哪里实现的我也没找到，回头等把整个lab3都看完了再回来补充这一部分
```

