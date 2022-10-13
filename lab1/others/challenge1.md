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



既然我们已经知道问题要求我们实现什么了，那不会做怎么办，百度一下就行，首先看看切换特权等级需要什么？

First需要TSS。TSS是什么？任务状态段，一块位于内存中的结构体而已。TSS有什么用？保存不同特权等级的栈段选择子和栈顶指针（切换特权需要切换栈，这是我们必须知道的）。ucore其实在`kern/mm/pmm.c`已经帮我们实现TSS结构了，我们知道有这个东西就行。

代表选择子和特权级的常量已经定义好在`kern/mm/memlayout.h`中。

### 从内核态切换到用户态

直接来到`trap.c`看看当中断号代表从内核态切换到用户态该怎么做。

说实话，看不懂答案，所以自己重新改了一下。（没有多高级，只是改成正常人能看懂的样子）。

    case T_SWITCH_TOU:
            if (tf->tf_cs != USER_CS) {
                tf->tf_cs = USER_CS;//把cs特权位改成user
                tf->tf_ds = td->tf_es = tf->tf_ss=tf->tf_gs=tf->tf_fs=USER_DS;//更新ds,es,ss,gs,fs
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

因为从内核态发生中断不压入`SS、ESP`，所以在中断前手动压入`SS、ESP`，就是我们的`lab1_switch_to_user`函数。

由于我们比不进行特权切换的中断多push了`SS、ESP`，为了在切换为应用态后，保存原有堆栈结构不变，确保程序正确运行，栈顶的位置应该被恢复到中断发生前的位置。SS、ESP是通过push指令压栈的，压入SS后，ESP的值已经上移了4个字节，所以在`trap_dispatch`需要修改tf->tf\_esp，将ESP下移4字节。

最后为了保证在用户态下也能使用I/O，将IOPL降低到了ring 3。到这里我们能给出`trap_dispatch`的代码了。

    static void
    lab1_switch_to_user(void) {
        //LAB1 CHALLENGE 1 : TODO
    	__asm__ __volatile__ (
    		"pushl %%eax \n"
    		"pushl %%esp \n"
    		"int %0 \n"
    		:
    		:"i" (T_SWITCH_TOU)
    	);
    }

### 从用户态到内核态

在用户态发生中断时堆栈会从用户栈切换到内核栈，并压入SS、ESP。同理，在篡改内核堆栈后IRET返回时会误认为没有特权级转换发生，不会把SS、ESP弹出，因此从用户态切换到内核态时需要手动弹出SS、ESP。

    case T_SWITCH_TOK:
    		if(tf->tf_cs != KERNEL_CS) {
    			tf->tf_cs = KERNEL_CS;
    			tf->tf_ss = tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_fs = KERNEL_DS;
    			tf->tf_eflags &= ~FL_IOPL_MASK;
    		}
    		break;

<!---->

    static void
    lab1_switch_to_kernel(void) {
    	__asm__ __volatile__ (
    		"int %0 \n"
    		"popl %%esp \n"
    		:
    		:"i" (T_SWITCH_TOK)
    	);
    }

