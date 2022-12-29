LAB4 内核进程管理

第一部分：入门阶段，这部分基本是照抄的实验指导书。

对CPU的分时复用：

当一个程序加载到内存中运行时，首先通过ucore OS的内存管理子系统分配合适的空间，然后就需要考虑如何分时使用CPU来“并发”执行多个程序，让每个运行的程序（这里用线程或进程表示）“感到”它们各自拥有“自己”的CPU。

在本次实验中接触到的是内核线程的管理，首选对内核线程进行学习了解：

内核线程是一种特殊的进程，内核线程与用户进程的区别有两个：（1）内核线程只运行在内核态，但是用户进程会在在用户态和内核态交替运行。（2）所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间，而用户进程需要维护各自的用户内存空间

入门阶段之实验流程概述：

从内存空间占用情况这个角度上看，我们可以**把线程看作是一种共享内存空间的轻量级进程。**

为了实现内核线程，需要**设计管理线程的数据结构**，即**进程控制块**（在这里也可叫做线程控制块）。如果要让内核线程运行，我们首先要创建内核线程对应的进程控制块，还**需把这些进程控制块通过链表连在一起**，便于随时进行插入，删除和查找操作等进程管理事务。这个链表就是进程控制块链表。然后在**通过调度器（scheduler）来让不同的内核线程在不同的时间段占用CPU执行，实现对CPU的分时共享**

在kern_init函数中，当完成虚拟内存的初始化工作后，就调用了proc_init函数，这个函数完成了idleproc内核线程和initproc内核线程的创建或复制工作，这也是本次实验要完成的练习。**idleproc内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了**，如果有，马上让调度器选择那个内核线程执行（请参考cpu_idle函数的实现）。**所以idleproc内核线程是在ucore操作系统没有其他内核线程可执行的情况下才会被调用**。接着就是调用kernel_thread函数来创建initproc内核线程。initproc内核线程的工作就是显示“Hello World”，表明自己存在且能正常工作了。

调度器会在特定的调度点上执行调度，完成进程切换。**在lab4中，这个调度点就一处，即在cpu_idle函数中**，此函数如果发现**当前进程（也就是idleproc）的need_resched置为1**（在初始化idleproc的进程控制块时就置为1了），则调用schedule函数，完成进程调度和进程切换。进程调度的过程其实比较简单，就是在进程控制块链表中查找到一个“合适”的内核线程，**所谓“合适”就是指内核线程处于“PROC_RUNNABLE”状态**。在接下来的**switch_to函数(在后续有详细分析，有一定难度，需深入了解一下)完成具体的进程切换过程**。一旦切换成功，那么initproc内核线程就可以通过显示字符串来表明本次实验成功。

第二部分：涉及实验

首先，和Lab3很像，我们首先介绍一个非常重要的数据结构：进程控制块

```c++
struct proc_struct {
    enum proc_state state;                      // Process state 状态
    int pid;                                    // Process ID 进程ID
    int runs;                                   // the running times of Proces 执行了几次
    uintptr_t kstack;                           // Process kernel stack 栈的地址
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU? 为1则进行进程调度
    struct proc_struct *parent;                 // the parent process 父进程
    struct mm_struct *mm;                       // Process's memory management field mm结构
    struct context context;                     // Switch here to run process 上下文
    struct trapframe *tf;                       // Trap frame for current interrupt 当前中断的frame
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
extern struct proc_struct *idleproc, *initproc, *current;
```

根据实验手册的顺序介绍一下里面的重要成员变量：

● mm：**内存管理的信息**，包括内存映射列表、页表指针等。mm成员变量在lab3中用于虚存管理。但在实际OS中，**内核线程常驻内存，不需要考虑swap page问题**，在lab5中涉及到了用户进程，才考虑进程用户内存空间的swap page问题，mm才会发挥作用。所以在lab4中mm对于内核线程就没有用了，这样内核线程的proc_struct的成员变量mm=0是合理的。mm里有个很重要的项pgdir，记录的是该进程使用的一级页表的物理地址。由于*mm=NULL，所以在proc_struct数据结构中需要有一个代替pgdir项来记录页表起始地址，这就是proc_struct数据结构中的cr3成员变量。

```C++
//以防忘记，把Lab3中的mm_struct粘贴过来了，可以回忆一下
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    pde_t *pgdir;                  // the PDT of these vma
    int map_count;                 // the count of these vma
    void *sm_priv;                 // the private data for swap manager
};
```

也就是说，在Lab4中mm没有用，他被置为零，因为内核线程不可能被换到硬盘中，他永远在内存中。但是进程在做地址转换的时候需要一个指向一级页表物理地址的指针，本来这个东西在mm中提供，但由于内核进程没有，所以由cr3代替。

● state：进程所处的状态。进程的状态信息同样定义在proc.h中，他是一个枚举类型，总共有四种可能：未初始化、休眠、就绪、濒死

```c++
// process's state in his life cycle
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized
    PROC_SLEEPING,    // sleeping
    PROC_RUNNABLE,    // runnable(maybe running)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim（回收） his resource
};
```

● parent：用户进程的父进程（创建它的进程）。在所有进程中，只有一个进程没有父进程，就是内核创建的第一个内核线程idleproc。内核根据这个父子关系建立一个树形结构，用于维护一些特殊的操作，例如确定某个进程是否可以对另外一个进程进行某种操作等等。

idleproc内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了，如果有，马上让调度器选择那个内核线程执行

● context：进程的上下文，用于进程切换（参见switch.S）。在 uCore中，所有的进程在内核中也是相对独立的（例如独立的内核堆栈以及上下文等等）。**使用 context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。**实际利用context进行上下文切换的函数是在kern/process/switch.S中定义switch_to。（这个地方不太懂，后面还要重点问、重点看）

现在似乎明白了一点点，干脆在这里就把上下文切换的步骤进行一个较为详细的说明。我们还是首先来看一下函数栈的调用过程：

如果想要参考完整的博客的话可以参考一下这篇，写的还是比较完整的：[(1条消息) 调用函数时，栈的变化_Y_Hanxiao的博客-CSDN博客_函数调用栈的变化](https://blog.csdn.net/Y_Hanxiao/article/details/80505325)

当我们调用函数的时候，首先从右向左把参数压栈（这里博客写错了）然后压入返回地址也就是完成函数调用，这个时候调用者任务就完成了，马上进入被调用者函数

![](G:\code\OS\lab4\函数调用栈.png)

所以说现在的栈空间应该是这样分布的：

```
|to.context   |高地址  
|from.context |  
|ret address  |<---esp  
```

当进入switch函数后，首先将esp+4位置的值赋值给eax，这样eax就拿到了from的context结构，然后此时esp指向返回地址，也就是from进程的下一条指令的位置，于是直接pop，然后按照顺序完成所有上下文的保存

```
switch_to(&(from->context), &(to->context))
```

然后需要做的就是把to中的context赋值给真正的寄存器，也是一样的步骤，但是具体的区别就是之前把返回地址push进去，也就是to的context结构中的eip位置的值，这样就完成了上下文的切换。后面也是+4找到to的context的地址是因为pop了ret之后esp就指向第一个参数了，所以加四就可以了

然后注释里还说了就是为什么不保存eax会方便很多：问了lxz学长，解释是这样的：用一个通用寄存器直接指向二者的上下文结构汇很方便，如果连eax的值都需要保存就会麻烦一些。在这里简单的说了一下switch_to的实现，后面还会继续的说具体的上下文切换的全过程

```assembly
//不用保存所有的寄存器因为段寄存器在内核上下文中是一样的，保存通用寄存器这样就不用关心调用者保存这样的约束，但是不保存eax，因为这会简化切换上下文的工作。
// Saved registers for kernel context switches.
// Don't need to save all the %fs etc. segment registers,
// because they are constant across kernel contexts.
// Save all the regular registers so we don't need to care
// which are caller save, but not the return register %eax.
// (Not saving %eax just simplifies the switching code.)
// The layout of context must match code in switch.S.
struct context {
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};
```

switch_to代码：

```assembly
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
    movl %esp, 4(%eax)
    movl %ebx, 8(%eax)
    movl %ecx, 12(%eax)
    movl %edx, 16(%eax)
    movl %esi, 20(%eax)
    movl %edi, 24(%eax)
    movl %ebp, 28(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    movl 28(%eax), %ebp
    movl 24(%eax), %edi
    movl 20(%eax), %esi
    movl 16(%eax), %edx
    movl 12(%eax), %ecx
    movl 8(%eax), %ebx
    movl 4(%eax), %esp

    pushl 0(%eax)               # push eip

    ret


```

● tf：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，**中断帧记录了进程在被中断前的状态。**当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，**uCore 在内核栈上维护了 tf 的链，可以参考trap.c::trap函数做进一步的了解。**（不知道这个是在哪里维护的）

放一下trap.c中的代码：

```c++
static void
trap_dispatch(struct trapframe *tf) {
    char c;

    int ret;

    switch (tf->tf_trapno) {
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case IRQ_OFFSET + IRQ_TIMER:
#if 0
    LAB3 : If some page replacement algorithm(such as CLOCK PRA) need tick to change the priority of pages, 
    then you can add code here. 
#endif
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
        cprintf("serial [%03d] %c\n", c, c);
        break;
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
        cprintf("kbd [%03d] %c\n", c, c);
        break;
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}

/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}

```

● cr3: cr3 保存页表的物理地址，目的就是进程切换的时候方便直接使用 lcr3实现页表切换，避免每次都根据 mm 来计算 cr3。mm数据结构是用来实现用户空间的虚存管理的，但是内核线程没有用户空间，它执行的只是内核中的一小段代码（通常是一小段函数），所以它没有mm 结构，也就是NULL。**当某个进程是一个普通用户态进程的时候，PCB 中的 cr3 就是 mm中页表（pgdir）的物理地址**；而当它是内核线程的时候，**cr3 等于boot_cr3。而boot_cr3指向
了uCore启动时建立好的饿内核虚拟空间的页目录表首地址。**

● kstack:**每个线程都有一个内核栈，并且位于内核地址空间的不同位置**。**对于内核线程，该栈就是运行时的程序使用的栈；而对于普通进程，该栈是发生特权级改变的时候使保存被打断的硬件信息用的栈。**记住前面这句话，这句话非常重要，对于普通进程，这个内核里的栈就是在发生特权级转换时存储信息所使用的栈，uCore在创建进程时分配了 2 个连续的物理页（参见memlayout.h中KSTACKSIZE的定义）作为内核栈的空间。这个栈很小，所以内核中的代码应该尽可能的紧凑，并且避免在栈上分配大的数据结构，以免栈溢出，导致系统崩溃。**kstack记录了分配给该进程/线程的内核栈的位置。**主要作用有以下几点。首先，**当内核准备从一个进程切换到另一个的时候**，**需要根据kstack 的值正确的设置好 tss** （可以回顾一下在实验一中讲述的 tss 在中断处理过程中的作用），以便在进程切换以后再发生中断时能够使用正确的栈。其次，内核栈位于内核地址空间，并且是不共享的（每个线程都拥有自己的内核栈），因此不受到 mm的管理，当进程退出的时候，**内核能够根据 kstack 的值快速定位栈的位置并进行回收**。uCore 的这种内核栈的设计借鉴的是 linux 的方法（但由于内存管理实现的差异，它实现的远不如 linux 的灵活），它使得每个线程的内核栈在不同的位置，这样从某种程度上方便调试，但同时也使得内核对栈溢出变得十分不敏感，因为一旦发生溢出，它极可能污染内核中其它的数据使得内核崩溃**。如果能够通过页表，将所有进程的内核栈映射到固定的地址上去，能够避免这种问题，但又会使得进程切换过程中对栈的修改变得相当繁琐。感兴趣的同学可以参考 linux kernel 的代码对此进行尝试。（所以说kstack就是一个地址，去那个地址就能找到栈）

什么是TSS：[TSS (任务状态段)的作用及结构 - Gotogoo - 博客园 (cnblogs.com)](https://www.cnblogs.com/Gotogoo/p/5250622.html)

1.什么是TSS

　　TSS全称Task State Segment ，是操作系统在进行进程切换时保存进程现场信息的段

2.TSS什么时候用，有什么用

　　TSS在任务（进程）切换时起着重要的作用，通过它保存CPU中各寄存器的值，实现任务的挂起和恢复。

　　比如说，当CPU执行A进程的时间片用完，要切换到B进程时，CPU会先把当前寄存器里的值保存到A进程的TSS里（任务寄存器TR指向当前进程的TSS），比如CS，EIP，ESP，标志寄存器等等，然后挂起A进程。执行B进程。这样，在CPU下次执行A进程的时候，就可以从其TSS中取出，CPU就知道上一次A进程执行到了什么位置，执行状态等等，这样就恢复了上次A进程的执行现场。

![](G:\code\OS\lab4\TSS.png)

● static struct proc *current：**当前占用CPU且处于“运行”状态进程控制块指针**。通常这个变量是只读的，只有在进程切换的时候才进行修改，并且整个切换和修改过程需要保证操作的原子性，目前至少需要屏蔽中断。可以参考 switch_to 的实现。

● static list_entry_t hash_list[HASH_LIST_SIZE]：**所有进程控制块的哈希表**，proc_struct中的成员变量hash_link**将基于pid**链接入这个哈希表中。他的定义在proc.c中

● list_entry_t proc_list：所有进程控制块的双向线性列表，proc_struct中的成员变量list_link将链接入这个链表中。他的定义也在proc.c中，都在下面的代码中给出了

```c++
// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];
```

创建并执行内核线程：

整体概览：

**建立进程控制块**（proc.c中的alloc_proc函数）后，现在就可以**通过进程控制块来创建具体的进程/线程了**。首先，考虑最简单的内核线程，它通常只是内核中的一小段代码或者函数，没有自己的“专属”空间。这是由于在uCore OS启动后，已经对整个内核内存空间进行了管理，通过设置页表建立了内核虚拟空间（即boot_cr3指向的二级页表描述的空间）。**所以uCoreOS内核中的所有线程都不需要再建立各自的页表，只需共享这个内核虚拟空间就可以访问整个物理内存了**。从这个角度看，内核线程被uCore OS内核这个大“内核进程”所管理。

第一个实验：

首先，创建第 **0** 个内核线程 **idleproc**，内核中总是需要有一个线程是被第一个创建的，这个进程一般来说也会在OS中承担比较重要的作用。

在kern_init函数调用了proc_init函数。**proc_init函数启动了创建内核线程的步骤**。首先**当前的执行上下文（从kern_init 启动至今）就可以看成是uCore内核**（也可看做是内核进程）中的一个内核线程的上下文。为此，uCore通过给当前执行的上下文分配一个进程控制块以及对它进行相应初始化，将其打造成第0个内核线程 -- idleproc。具体步骤如下：

首先调用alloc_proc函数来通过kmalloc函数获得proc_struct结构的一块内存块-，作为第0个进程控制块。并把proc进行初步初始化（即把proc_struct中的各个成员变量清零）。但有些成员变量设置了特殊的值（这里是exercise1需要完成的步骤）

```c++
// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));//kmalloc函数回头还要好好看看，总之现在就知道他分配了一个内存区域
    if (proc != NULL) {//只要分配成功了
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        
     /*
       下面的代码需要重点关注三条语句,第一条设置了进程的状态为“初始”态，这表示进程已经 “出生”了，正在获取资源茁壮成长中；第二条语句设置了进程的pid为-1，这表示进程的“身份证号”还没有办好；第三条语句表明由于该内核线程在内核中运行，故采用为uCore内核已经建立的页表，即设置为在uCore内核页表的起始地址boot_cr3。后续实验中可进一步看出所有内核线程的内核虚地址空间（也包括物理地址空间）是相同的。既然内核线程共用一个映射内核空间的页表，这表示内核空间对所有内核线程都是“可见”的，所以更精确地说，这些内核线程都应该是从属于同一个唯一的“大内核进程”—uCore内核。
       */
        proc->state = PROC_UNINIT;//重点关注
        proc->pid = -1;//pid还未知
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));//初始化空间
        proc->tf = NULL;
        proc->cr3 = boot_cr3;//共享内核空间
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);//初始化空间
    }
    return proc;
}

```

我觉得现在就有必要说一下context和tf的区别是什么：

context作用：
进程的上下文，用于进程切换。主要保存了前一个进程的现场（各个寄存器的状态）。在uCore中，所有的进程在内核中也是相对独立的。使用context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用context进行上下文切换的函数是在kern/process/switch.S中定义switch_to。

tf：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链。

kmalloc相关函数的实现：（现在还不太明白）

```c++
//kmalloc函数的实现
void *
kmalloc(size_t size)
{
  return __kmalloc(size, 0);
}

//真正的malloc函数的实现，还没看懂
static void *__kmalloc(size_t size, gfp_t gfp)
{
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
	if (!bb)
		return 0;

	bb->order = find_order(size);
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);

	if (bb->pages) {
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
		bigblocks = bb;
		spin_unlock_irqrestore(&block_lock, flags);
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}
```

proc_init函数的实现，也就是kern_init函数调用的那个用来初始化内核进程的函数

```c++
// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
    int i;

    list_init(&proc_list);//进程双向链表初始化
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i); //初始化哈希表
    }

    if ((idleproc = alloc_proc()) == NULL) {//分配进程控制块
        panic("cannot alloc idleproc.\n");
    }
	//在alloc_proc中对idle的进程控制块进行了一些初始化，但是那些初始化有一些不太对，还需要进一步精确：
    /*
    需要注意前4条语句。第一条语句给了idleproc合法的身份证号--0，这名正言顺地表明了idleproc是第0个内核线程。通常可以通过pid的赋值来表示线程的创建和身份确定。“0”是第一个的表示方法是计算机领域所特有的，比如C语言定义的第一个数组元素的小标也是“0”。第二条语句改变了idleproc的状态，使得它从“出生”转到了“准备工作”，就差uCore调度它执行了。第三条语句设置了idleproc所使用的内核栈的起始地址。需要注意以后的其他线程的内核栈都需要通过分配获得，因为uCore启动时设置的内核栈直接分配给idleproc使用了。第四条很重要，因为uCore希望当前CPU应该做更有用的工作，而不是运行idleproc这个“无所事事”的内核线程，所以把idleproc->need_resched设置为“1”，结合idleproc的执行主体--cpu_idle函数的实现，可以清楚看出如果当前idleproc在执行，则只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。
    */
    idleproc->pid = 0;//idle是第零个进程
    idleproc->state = PROC_RUNNABLE;//可执行
    idleproc->kstack = (uintptr_t)bootstack;//分配给这个特殊的进程内核栈
    idleproc->need_resched = 1;//只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。
    set_proc_name(idleproc, "idle");//设置名字
    nr_process ++;//总进程数加一

    current = idleproc;//现在在执行的进程

    //到这里上面的代码完成了idle函数的初始化，下面初始化第一个有用的进程initproc，具体的实现方法就是调用kernel_theard函数
    int pid = kernel_thread(init_main, "Hello world!!", 0);//创建新的内核线程，但是只有输出字符串的作用
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);//查找线程
    set_proc_name(initproc, "init");//充值线程名称

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;//这个地方没看懂，还要再问问
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))
```

创建第一个线程init_proc

第0个内核线程**主要工作是完成内核中各个子系统的初始化**，然后就通过执行cpu_idle函数开始过退休生活了。所以uCore接下来还需创建其他进程来完成各种工作，但idleproc内核子线程自己不想做，于是就**通过调用kernel_thread函数创建了一个内核线程init_main**。在实验四中，这个子内核线程的工作就是输出一些字符串，然后就返回了（参看init_main函数）。**但在后续的实验中，init_main的工作就是创建特定的其他内核线程或用户进程**（实验五涉及）。下面我们来分析一下创建内核线程的函数kernel_thread：

```c++
//中断帧，这个看看就行了，在这个实验里好像也没啥大用
struct trapframe {
    struct pushregs tf_regs;
    uint16_t tf_gs;
    uint16_t tf_padding0;
    uint16_t tf_fs;
    uint16_t tf_padding1;
    uint16_t tf_es;
    uint16_t tf_padding2;
    uint16_t tf_ds;
    uint16_t tf_padding3;
    uint32_t tf_trapno;
    /* below here defined by x86 hardware */
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding5;
} __attribute__((packed));


// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
//这个函数创建了一个临时的中断帧，其中断帧的参数基本都来源于KERNEL的各个段的信息
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.tf_cs = KERNEL_CS;//代码段寄存器
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;//数据段
    tf.tf_regs.reg_ebx = (uint32_t)fn;//ebx为什么这么设置？，这个就是线程要执行的函数
    tf.tf_regs.reg_edx = (uint32_t)arg;//arg是啥，为什么能输入字符串？函数的参数
    tf.tf_eip = (uint32_t)kernel_thread_entry;//下一个执行的位置，注意这个tf结构的eip，这个eip才是能让initproc执行起来的那个eip。这里是需要明确的
    return do_fork(clone_flags | CLONE_VM, 0, &tf);//真正的创建进程
}
```

上面的kernel_thread函数采用了局部变量tf来放置保存内核线程的临时中断帧，**并把中断帧的指针传递给do_fork函数**，而do_fork函数会**调用copy_thread函数来在新创建的进程内核栈上专门给进程的中断帧分配一块空间**。

给中断帧分配完空间后，就需要构造新进程的中断帧，具体过程是：首先给tf进行清零初始化，并**设置中断帧的代码段（tf.tf_cs）和数据段**(tf.tf_ds/tf_es/tf_ss)为内核空间的段（KERNEL_CS/KERNEL_DS），这实际上也说明了initproc内核线程在内核空间中执行。这个tf结构就是给initproc用的，后面会更仔细说这个tf有什么用。**而initproc内核线程从哪里开始执行呢？tf.tf_eip的指出了是kernel_thread_entry（位于kern/process/entry.S中）**，kernel_thread_entry是entry.S中实现的汇编函数，它做的事情很简单：

从代码可以看出，kernel_thread_entry函数主要为内核线程的主体fn函数做了一个准备开始和结束运行的“壳”，并把函数fn的参数arg（保存在edx寄存器中）压栈，然后调用fn函数，把函数返回值eax寄存器内容压栈，调用do_exit函数退出线程执行。

所以他具体干的事情就是调用ebx寄存器保存的地址那个位置的函数，然后用edx做参数，这个kernel_theard函数中我们对tf的赋值是一致的

```assembly
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
    call *%ebx              # call fn

    pushl %eax              # save the return value of fn(arg)
    call do_exit            # call do_exit to terminate current thread
```

然后kernel_theard调用了do_fork，也就是Lab4-exercise2中需要实现的内容：

do_fork是创建线程的主要函数。kernel_thread函数通过调用do_fork函数最终完成了内核线程的创建工作。下面我们来分析一下do_fork函数的实现（练习2）。do_fork函数主要做了以下6件事情：

1. 分配并初始化进程控制块（alloc_proc函数）；

2. 分配并初始化内核栈（setup_stack函数）；

3. 根据clone_flag标志**复制或共享进程内存管理结构**（copy_mm函数）；

4. 设置进程在内核（将来也包括用户态）正常运行和调度所需的中断帧和执行上下文（copy_thread函数）；

5. 把设置好的进程控制块放入hash_list和proc_list两个全局进程链表中；

6. 自此，进程已经准备好执行了，把进程状态设置为“就绪”态；

7. 设置返回码为子进程的id号。

这里需要注意的是，**如果上述前3步执行没有成功，则需要做对应的出错处理，把相关已经占有的内存释放掉。**copy_mm函数目前只是把current->mm设置为NULL，这是由于目前在实验四中只能创建内核线程，**proc->mm描述的是进程用户态空间的情况，所以目前mm还用不上。**

```c++
/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;//没有多余的进程控制块了
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {//分配进程控制块失败
        goto fork_out;//分配失败，直接返回没有多余的控制块了
    }

    proc->parent = current;//父进程是当前进程

    if (setup_kstack(proc) != 0) {//分配内核栈空间
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);//完成中断栈以及上下文初始化

    bool intr_flag;
    local_intr_save(intr_flag);//这里也没懂
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list, &(proc->list_link));
        nr_process ++;
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);

    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

```

分配进程栈空间：

```c++
// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);//返回栈空间的内核虚拟地址
        return 0;
    }
    return -E_NO_MEM;
}

#define KSTACKPAGE          2                           // # of pages in kernel stack
```

copy_mm:。copy_mm函数目前只是把current->mm设置为NULL，这是由于目前在实验四中只能创建内核线程，proc->mm描述的是进程用户态空间的情况，所以目前mm还用不上,看的出来这个函数的目的就是设置当前进程控制块的mm结构

```c++
//根据clone_flag标志**复制或共享进程内存管理结构**
// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}
```

copy_theard:

此函数**首先在内核堆栈的顶部设置中断帧大小的一块栈空间**，并在此空间中拷贝在kernel_thread函数建立的临时中断帧的初始值，并进一步设置中断帧中的栈指针esp和标志寄存器eflags，特别是eflags设置了FL_IF标志，这表示此内核线程在执行过程中，能响应中断，打断当前的执行。执行到这步后，此进程的中断帧就建立好了

```c++
// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;
    proc->tf->tf_regs.reg_eax = 0;
    proc->tf->tf_esp = esp;//不用管这个，这个没用，因为没有发生特权级的转换
    proc->tf->tf_eflags |= FL_IF;

    proc->context.eip = (uintptr_t)forkret;
    proc->context.esp = (uintptr_t)(proc->tf);//所以说这个进程真正的esp在这里，由于没有切换特权级所以上面的tf上的esp，没有用，只有
}
```

对于initproc而言，它的中断帧如下所示：

```c++
//所在地址位置
initproc->tf= (proc->kstack+KSTACKSIZE) - sizeof (struct trapframe);//具体内容
initproc->tf.tf CS = KERNEL CS;
initproc->tf.tf ds = initproc->tf.tf es = initproc->tf.tf ss = KERNEL DS:
initproc->tf.tf_regs.reg_ebx = (uint32 t)init main;
initproc->tf.tf_regs.reg edx = (uint32 t) ADDRESS of "Helloworld!!"
initproc->tf.tf eip = (uint32 t)kernel thread entry;
initproc->tf.tf regs.reg_eax = 0;
initproc->tf.tf esp = esp;
initproc->tf.tf_eflags |= FL IF:
```

设置好中断帧后，最后就是设置initproc的进程上下文，（process context，也称执行现场）了。只有设置好执行现场后，一旦uCore调度器选择了initproc执行，就需要根据initproc-context中保存的执行现场来恢复initproc的执行。**这里设置了initproc的执行现场中主要的两个信息：上次停止执行时的下一条指令地址context.eip和上次停止执行时的堆栈地址context.esp。**其实initproc还没有执行过，所以这其实就是initproc实际执行的第一条指令地址和堆栈指针。可以看出，由于initproc的中断帧占用了实际给initproc分配的栈空间的顶部，所以initproc就只能把栈顶指针context.esp设置在initproc的中断帧的起始位置。根据context.eip的赋值，可以知道initproc实际开始执行的地方在forkret函数（主要完成do_fork函数返回的处理工作）处。至此，initproc内核线程已经做好准备执行了。

所以说，initproc函数的context的设置为forkret，forkret的执行会根据tf的一些内容重新更新寄存器，尤其是eip

然后是两个函数，这俩函数看起来像一对的，他们的作用也是相反的。我们来看看这几个函数的实现：这个地方问了问学长，可以理解为上锁，保证这一段代码是原子执行的。就像有些数据结构是要全局维护的，对这些结构进行操作，如果中间中断了被别的代码影响了的话，会影响本次的操作，这时就需要去给锁住

```c++
#define local_intr_save(x)      do { x = __intr_save(); } while (0) //我的理解这个就是如果现在允许中断就不允许中断
#define local_intr_restore(x)   __intr_restore(x);//反之这个就是如果现在不允许中断那就打开中断
#define FL_IF           0x00000200  // Interrupt Flag

static inline bool
__intr_save(void) {
    if (read_eflags() & FL_IF) {
        intr_disable();
        return 1; //从允许变成不允许
    }
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
        intr_enable();//允许中断
    }
}

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
    sti();
}

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
    cli();
}

```

最后是list_entry和hash_entry

```c++
// hash_proc - add proc into proc hash_list
//哈希链表算一下哈希值再连进去，proc list就直接连就好了 proc list 就是每一个进程连在一个双向链表中
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

 list_add(&proc_list, &(proc->list_link));
```

别忘了，要想让initproc执行还要把他叫醒，叫醒函数也很简单，只要他不是濒死的或者不是已经runnable就都可以叫醒

```c++
void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}
```

至此，理论上exercise2就完成了，但其实还差一部分，比如context和tf为什么都要使用？上面初始化initproc的时候为什么要初始化一个context还要初始化一个tf呢？想要回答这些问题就必须认真完成下面的代码阅读以及实验手册的阅读。

如何调度并执行内核线程 **initproc**？

在uCore执行完proc_init函数后，就创建好了两个内核线程：idleproc和initproc，这时uCore当前的执行现场就是idleproc，等到执行到init函数的最后一个函数cpu_idle之前，uCore的所有初始化工作就结束了，idleproc将通过执行cpu_idle函数让出CPU，给其它内核线程执行，具体过程如下：

首先，判断当前内核线程idleproc的need_resched是否不为0，回顾前面“创建第一个内核线程idleproc”中的描述，proc_init函数在初始化idleproc中，就把idleproc->need_resched置为1了，**所以会马上调用schedule函数找其他处于“就绪”态的进程执行。**

```c
// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}
```

然后还是先把schedule的代码给出来：

uCore在实验四中只实现了一个最简单的FIFO调度器，其核心就是schedule函数。它的执行逻辑很简单：

1．设置当前内核线程current->need_resched为0； 

2．在proc_list队列中查找下一个处于“就绪”态的线程或进程next； 

3．找到这样的进程后，就调用proc_run函数，保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换。

至此，新的进程next就开始执行了。由于在proc10中只有两个内核线程，且idleproc要让出

CPU给initproc执行，我们可以看到schedule函数通过查找proc_list进程队列，只能找到一个处于“就绪”态的initproc内核线程。并通过proc_run和进一步的switch_to函数完成两个执行现场的切换。

```c++
void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;//现在这个进程的赋值为0，也就是现在不需要调度
        last = (current == idleproc) ? &proc_list : &(current->list_link);//这句话用来判断现在这个进程是不是idle进程，如果是的话直接拿到proc_list从头开始找，如果不是的话就拿到当前进程从当前进程开始找
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {//感觉这个是保证找到的是正常的能用的进程，因为proclist实际上没有嵌入到任何一个进程中
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {//如果是准备就绪状态的话就选他执行
                    break;
                }
            }
        } while (le != last);//只要没找回来就一直找
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }//根本就没找到，那还是运行idle等着回来再找
        next->runs ++;//运行次数递增
        if (next != current) {
            proc_run(next);//执行这个进程
        }
    }
    local_intr_restore(intr_flag);//恢复中断
}

```

所以说最后要是想让进程执行起来还需要proc_run函数，这个函数的实现在下面：

具体的流程主要分为四步：

1. 让current指向next内核线程initproc；

2. 设置任务状态段ts中特权态0下的栈顶指针esp0为next内核线程initproc的内核栈的栈顶，即next->kstack + KSTACKSIZE ；

3. 设置CR3寄存器的值为next内核线程initproc的页目录表起始地址next->cr3，这实际上是完成进程间的页表切换；

4. 由switch_to函数完成具体的两个线程的执行现场切换，即切换各个寄存器，当switch_to函数执行完“ret”指令后，就切换到initproc执行了。

```c
// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {//要调度么，不能再启动当前的进程
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;//拿到两个进程的进程控制块
        local_intr_save(intr_flag);//保证操作的原子性
        {
            current = proc;
            load_esp0(next->kstack + KSTACKSIZE);//重置esp0寄存器，如果是cr3的中断的话会有用
            lcr3(next->cr3);//把cr3寄存器的值更新了
            switch_to(&(prev->context), &(next->context));//切换上下文
        }
        local_intr_restore(intr_flag);
    }
}
```

在第二步设置任务状态段ts中特权态0下的栈顶指针esp0的目的是建立好内核线程或将来用户线程在执行特权态切换（从特权态0<-->特权态3，或从特权态3<-->特权态3）时能够正确定位处于特权态0时进程的内核栈的栈顶，而这个**栈顶其实放了一个trapframe结构的内存空间**。如果是在特权态3发生了中断/异常/系统调用，则CPU会从特权态3-->特权态0，**且CPU从此栈顶（当前被打断进程的内核栈顶）开始压栈来保存被中断/异常/系统调用打断的用户态执创建并执行内核线程现场；**

如果是在特权态0发生了中断/异常/系统调用，则CPU会从从当前内核栈指针esp所指的位置开始压栈保存被中断/异常/系统调用打断的内核态执行现场。反之，当执行完对中断/异常/系统调用打断的处理后，最后会执行一个“iret”指令。在执行此指令之前，CPU的当前栈指针esp一定指向上次产生中断/异常/系统调用时CPU保存的被打断的指令地址CS和EIP，“iret”指令会根据ESP所指的保存的址CS和EIP恢复到上次被打断的地方继续执行。

在页表设置方面，**由于idleproc和initproc都是共用一个内核页表boot_cr3，所以此时第三步其实没用**，但考虑到以后的进程有各自的页表，其起始地址各不相同，只有完成页表切换，才能确保新的进程能够正常执行。

上面说完了中间两步，然后就说说这个switch_to语句，这个语句咱们在上面也写过，但是还是再看实验指导书说一遍，重复的就不在这里说了，直接说上面没说到的：

倒数第二条汇编指令“pushl 0(%eax)”其实把context中保存的下一个进程要执行的指令地址context.eip放到了堆栈顶，这样接下来执行最后一条指令“ret”时，会把栈顶的内容赋值给EIP寄存器，这样就切换到下一个进程执行了，即当前进程已经是下一创建并执行内核进程了。

uCore会执行进程切换，让initproc执行。在对initproc进行初始化时，设置了initproc->context.eip = (uintptr_t)forkret，这样，当执行switch_to函数并返回后，initproc将执行其实际上的执行入口地址forkret。而forkret会调用位于kern/trap/trapentry.S中的forkrets函数执行，具体代码如下：

```assembly
.globl __trapret
__trapret:
# restore registers from stack
popal
# restore %ds and %es
popl %es
popl %ds
# get rid of the trap number and error code
addl $0x8, %esp
iret

.globl forkrets
forkrets:
# set stack to this new process's trapframe
movl 4(%esp), %esp //把esp指向当前进程的中断帧
jmp __trapret
```

可以看出，forkrets函数首先把esp指向当前进程的中断帧，从_trapret开始执行到iret前，esp指向了current->tf.tf_eip，而如果此时执行的是initproc，**则current-tf.tf_eip=kernel_thread_entry，initproc->tf.tf_cs = KERNEL_CS**，**所以当执行完iret后，就开始在内核中执行kernel_thread_entry函数了**，而initproc->tf.tf_regs.reg_ebx = init_main，所以在kernl_thread_entry中执行“call %ebx”后，就开始执行initproc的主体了。Initprocde的主体函数很简单就是输出一段字符串，然后就返回到kernel_tread_entry函数，并进一步调用do_exit执行退出操作了。

我简单总结一下就是真正执行的在内核的第一条执行放在context里，然后context执行的其实是对do_fork设置的值的处理，而真正能够启动进程的eip还是保存在tf里面，这就需要用iret来完成。我感觉就是为了让内核的切换流程和用户态的进程切换流程一样才这么搞的。
