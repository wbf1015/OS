## Challenge1

`扩展proj4,增加syscall功能，即增加一用户态函数（可执行一特定系统调用：获得时钟计数值），当内核初始完毕后，可从内核态返回到用户态的函数，而用户态的函数又通过系统调用得到内核态的服务。`

由于challenge流程题目已经给定，我们就照着题目要求找到我们需要修改的地方看看它的需求是什么。根据指导手册需求，我们知道需要我们完成的其实就是kernel\_init初始化kernel完成后需要执行的switch函数。

    lab1_switch_test(void) {
        lab1_print_cur_status();
        cprintf("+++ switch to  user  mode +++\n");
        lab1_switch_to_user();
        lab1_print_cur_status();
        cprintf("+++ switch to kernel mode +++\n");
        lab1_switch_to_kernel();
        lab1_print_cur_status();
    }

根据函数的名字，我们很轻松的知道，这个函数的流程是：

1.  打印当前寄存器（cs,es,ds,ss）的值
2.  从内核态切换到用户态
3.  打印寄存器
4.  从用户态切换回内核态
5.  打印寄存器

这个challenge需要我们完成的就是实现`如果在内核态和用户态直接切换`，所以看不懂题目不要紧，我们直接对这两个具体问题分析。

既然我们已经知道问题要求我们实现什么了，那不会做怎么办，百度一下就行，首先看看中断需要我们做什么？

First需要TSS。TSS是什么？任务状态段，一块位于内存中的结构体而已，一个任务由两部分构成：任务执行的空间和TSS（Task-State Segment）。而任务执行的空间则由：代码段（Code Segment）、数据段（一个或者多个）（Data Segment）、栈段（Stack Segment）组成。TSS存储了处理器管理任务所需要的信息（也就是把寄存器里面的内容都保存下来）。TSS有什么用？保存不同特权等级的栈段选择子和栈顶指针（切换特权需要切换栈，这是我们必须知道的）。ucore其实在`kern/mm/pmm.c`已经帮我们实现TSS结构了，我们知道有这个东西就行。

代表选择子和特权级的常量已经定义好在`kern/mm/memlayout.h`中。

*   若CPU在内核态执行时进行中断，特权级并无变化，直接在内核栈进行中断处理，不涉及栈的变化，trapframe的SS、ESP不会由cpu自动压入、也不会弹出，不会使用。
*   若中断涉及特权级的变换，中断的执行也会进行栈的切换。在保护模式下，若CPU在用户态执行时产生了中断，由于中断处理程序是内核态，即CPL从3变为0，特权级进行了提升。内核栈的地址会被初始化在TSS的SS0、ESP0中，当从用户态切换到内核态时，CPU从TSS中得到SS0、ESP0，切换到内核栈，并会在内核栈压入用户栈的SS、ESP。
*   当处于内核态的中断处理程序执行完毕后，恢复现场，执行IRET指令中断返回，从内核栈中弹出用户程序中断点的cs时，特权级会从高特权级变为低特权级，CPL从0变为3，也即从内核态切换回用户态，同时会弹出开始保存在内核栈的用户栈SS、ESP，也即完成了从内核栈到用户栈的转换。

### 从内核态切换到用户态

如何引发从内核态切换到用户态的软中断？

在`trap.h`中已经定义了内核态切换到用户态的中断号`T_SWITCH_TOU`，即`trap_switch_to_user`的缩写。有了这个之后，我们可以直接引发该中断。但直接引发中断有一个问题。引发中断时CPU会将寄存器内的一些状态保存到栈中，但有一个例外，就是SS与ESP寄存器。在内核态引发的中断会将SS与ESP寄存器的值保存到TSS(Task State Segment)中，而用户态的SS与ESP寄存器的值则会正常保存到栈中，那么问题来了：该怎样做才能使得特权级可以正常切换呢？

答案就是：引发中断前，在栈中预留给SS和ESP的位置，然后在中断的处理过程中为其赋正确的值，中断处理结束后即可正常进入用户态。

    static void
    lab1_switch_to_user(void) {
        //LAB1 CHALLENGE 1 : TODO
    	__asm__ __volatile__ (
    		"sub $8 %%esp \n"
    		"int %0 \n"
    		"movl %%ebp %%esp"
    		:
    		:"i" (T_SWITCH_TOU)
    	);
    }

直接来到`trap.c`看看当中断号代表从内核态切换到用户态该怎么做。

说实话，看不懂答案，所以自己重新改了一下。（没有多高级，只是改成正常人能看懂的样子）。

    case T_SWITCH_TOU:
            if (tf->tf_cs != USER_CS) {
                tf->tf_cs = USER_CS;//把cs特权位改成user
                tf->tf_ds = td->tf_es = tf->tf_ss=USER_DS;//更新ds,es,ss,gs,fs
    			//待会你就知道为什么加4了
                tf->tf_esp += 4;
    		
                // set eflags, make sure ucore can use io under user mode.
                // if CPL > IOPL, then cpu will generate a general protection.
                tf->tf_eflags |= FL_IOPL_MASK;
            }
            break;

中断发生时会有大量的寄存器被保存到栈上，在执行IRET指令时恢复保存的寄存器。特权级的切换就利用了这个原理，在中断处理过程中篡改相应的寄存器，欺骗IRET指令将这些值保存到寄存器中。当我们将堆栈中的CS的特权位设置为ring 3时，IRET会误认为中断是从ring 3发生的，执行时弹出SS、ESP。

利用IRET指令执行的特性，只需要手动地将内核堆栈布局设置为发生了特权级转换时的布局，将特权位修改为DPL\_USER，保持切换前后的EIP、ESP不变，IRET执行后就可以切换为应用态。

![image](https://img1.imgtp.com/2022/10/12/Dm7tsAJG.png)

（看懂这张图就懂了，说白了，就是在把ring 0改成ring 3前往栈里塞了ESP、SS，IRET更新寄存器时就会把SS和ESP给更新了）。

因为从内核态发生中断不压入`SS、ESP`，所以在中断前手动压入`SS、ESP`，就是我们的`lab1_switch_to_user`函数。由于我们比不进行特权切换的中断多push了`SS、ESP`，为了在切换为USER后，保存原有堆栈结构不变，程序正确运行，栈顶的位置应该被恢复到中断压栈前的位置。SS、ESP是通过push指令压栈的，压入SS后，ESP的值已经上移了4个字节，所以在`trap_dispatch`需要修改tf->tf\_esp，将ESP向上移4字节。这么做导致trapframe里的ESP还是正常的内核态调用中断前内核栈的栈顶。

最后为了保证在用户态下也能使用I/O，将IOPL降低到了ring 3。到这里我们能给出`trap_dispatch`的代码了。

### 从用户态到内核态

指令在用户态执行时，也会进行中断处理，如时钟中断。但是中断处理程序都是在内核态，在执行过程中需要将用户栈转换为内核栈。具体做法是从TSS（任务状态段）中读取ss0、esp0作为内核栈地址，将ss设为ss0、esp设为esp0，同时自动压入用户栈的ss、esp，作为trapframe结构一部分，待中断返回时，再从内核栈转为用户栈。

TSS存储在GDT中，同时有一个TR的寄存器记录TSS段的起始地址。ucore中只使用一个全局的TSS，作用仅为进行中断时cpu找到内核栈的ss、esp，以便切换执行。stack0即为临时的内核栈，当在用户态执行时进行中断，将切换到stack0堆栈进行执行。

    static void
    gdt_init(void) {
        // Setup a TSS so that we can get the right stack when we trap from
        // user to the kernel. But not safe here, it's only a temporary value,
        // it will be set to KSTACKTOP in lab2.
        ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
        ts.ts_ss0 = KERNEL_DS;

        // initialize the TSS filed of the gdt
        gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
        gdt[SEG_TSS].sd_s = 0;

        // reload all segment registers
        lgdt(&gdt_pd);

        // load the TSS
        ltr(GD_TSS);
    }

用户态切换为内核态相当于内核态的中断处理程序返回为内核态的过程。

当用户态进入内核态时，压入用户栈的ss、esp，在中断处理程序中切换cs为内核代码段、ds和es为内核数据段，因为每次进程从用户态陷入内核的时候得到的内核栈都是空的，直接将%ebp的值赋给%esp。

    case T_SWITCH_TOK:
    		if(tf->tf_cs != KERNEL_CS) {
    			tf->tf_cs = KERNEL_CS;
    			tf->tf_ds = tf->tf_es = KERNEL_DS;
    			tf->tf_eflags &= ~FL_IOPL_MASK;
    		}
    		break;



    static void
    lab1_switch_to_kernel(void) {
    	__asm__ __volatile__ (
    		"int %0 \n"
    		"movl %%ebp %%esp \n"
    		:
    		:"i" (T_SWITCH_TOK)
    	);
    }

## Challenge2

拓展练习2使用的技术与拓展练习1相同，通过篡改堆栈来欺骗IRET实现希望实现的功能。

我们先试试最简单粗暴的方法，嵌套式的中断，如下：

    case IRQ_OFFSET + IRQ_KBD:
            c = cons_getc();
            cprintf("kbd [%03d] %c\n", c, c);
            switch(c){
            case '0':
                if(!trap_in_kernel(tf)){
                    cprintf("switch to kernel\n");
                    asm volatile(
                        "int %0 \n"
                        "popl %%esp \n" 
                        :
                        :"i"(T_SWITCH_TOK)
                    );
                }
                break;
            case '3':
                if(trap_in_kernel(tf)){
                    cprintf("swtich to user\n");
                    __asm__ __volatile__ (
                        "pushl %%eax \n"
                        "pushl %%esp \n"
                        "int %0 \n"
                        :
                        :"i" (T_SWITCH_TOU)
                    );
                    cprintf("123\n");
                }
                break;
            }
            break;

意思就是检测到键盘输入‘0’或‘3’引发的中断时，我们直接在这个中断处理过程中触发自己设定的`k2u or u2k`中断，很遗憾这么做是失败的。

换个思路，最没有脑子的想法就是，我在触发键盘中断前或处理完成后，我多触发一个切换特权的中断。这么做看起来似乎有点道理，反正用户看不出来我是什么时候切换的。那就上手吧，但是我们遇到第一个问题很快就难住我们了，是从哪里读取的字符呢？好吧，我们甚至找半天找不到哪里触发的读入字符中断。我们就只能乖乖的做了。

拓展练习1是在某个特定的函数中切换特权级，给了我们足够的空间去篡改、修复堆栈。但是在拓展练习2中，中断可以在任何时候发生，即只要我们按下键盘上的‘0’或‘3’，就立刻触发特权切换，我们没有在中断处理前或中断处理返回后修改堆栈的机会，所有的操作都必须要在中断处理的过程中完成。

### 从内核态切换到用户态

按照拓展练习1中的思路，在中断发生前要手动压入SS、ESP，但在这里中断可以在任意时刻发生，没有机会提前压入SS、ESP，所以实现从内核态切换到用户态的关键就是如何在中断处理过程补齐8个字节。到这里我终于知道challenge1的参考答案是在干什么了。

    static inline __attribute__((always_inline)) void switch_to_user(struct trapframe *tf) {
        if (tf->tf_cs != USER_CS) {
            switchk2u = *tf;

            switchk2u.tf_cs = USER_CS;
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
        
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
        
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
    }

首先是定义了一个新的trapframe对象`switchk2u`，它的成员变量初始值和tf一样。为了进入USER特权，我们需要将switchk2u的cs特权修改为USER，并且将ds、es、ss段寄存器都修改的USER\_DS。接下来到了最重要的一步，我们怎么找到进入USER态的ESP。

回想一下我在challenge1给出的那张图吧（回去看看吧），在kernel特权下进入中断，ESP、SS是不会被压栈的，在challenge1中我们为了实现从kernel特权进入user特权手动压栈压入了esp，然后在cs特权被中断处理修改为USER后会pop出ESP从而成功利用IRET指令修改了ESP的值。这里我们为了在中断处理阶段实现同样的功能，我们显然要做到同样的功能，怎么办？直接让switchk2u的tf\_esp变成正确的ESP位置，其他的再说吧。

希望你能记住我们在内核态中断时是怎么压栈的，是将一个trapframe压入栈来保存状态信息。tf指向的是trapframe的起始地址，`trapframe+sizeof(struct trapframe)`指向压入trapframe前的栈顶。这里为什么需要减8？可以说-8是因为为了模仿用户态压栈时多压入的SS、ESP，自然ESP被抬高了八个字节，但其实不-8也是对的。

最后那个一堆指针看不懂是吧，来让我们想想，tf是什么？是trapframe的头的地址，指针\*tf-1是什么？是为什么在中断时压入栈的ESP（在\_\_alltraps里），作为trap函数的参数入栈，现在我们想修改这个tf但我们不能直接修改整个栈，怎么办？让这个ESP指向别的trapframe呗。就是我们新声明的switchk2u，这样IRET指令执行后就会进入我们新的用户栈里执行。

### 从用户态切换到内核态

同理上述内容。需要注意的是，切换到内核态后，栈中便不存在ESP与SS寄存器的值了。尽管`trapframe`中仍旧存在`tf_esp`与`tf_ss`，但其指向的是栈内未知的数据，不对其进行修改就会一切正常。

switchu2k指向哪里？由于中断在内核态的栈结构比用户态的栈结构少八个字节（最高位的SS、ESP），我们将switchu2k修改到正确的内存空间。然后利用memmove函数从tf拷贝除了高八字节的内容到switchu2k指向的内存空间。最后那个指针的操作同理。

    static inline __attribute__((always_inline)) void switch_to_kernel(struct trapframe *tf) {
        if (tf->tf_cs != KERNEL_CS) {
            tf->tf_cs = KERNEL_CS;
            tf->tf_ds = tf->tf_es = KERNEL_DS;
            tf->tf_eflags &= ~FL_IOPL_MASK;
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));

            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
    }

在我们最后Challenge2实现里，只需要调用这两个内联函数就好了。（为什么内联？让栈结构简单一点）

    case IRQ_OFFSET + IRQ_KBD:
            c = cons_getc();
            cprintf("kbd [%03d] %c\n", c, c);
             if (c == '0'&&!trap_in_kernel(tf)) {
            //切换为内核态
            switch_to_kernel(tf);
            print_trapframe(tf);
            } else if (c == '3'&&(trap_in_kernel(tf))) {
            //切换为用户态
            switch_to_user(tf);
            print_trapframe(tf);
            }
            break;

