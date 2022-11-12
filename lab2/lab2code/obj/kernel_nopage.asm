
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
void grade_backtrace(void);
static void lab1_switch_test(void);
static void lab1_print_cur_status(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  100041:	2d 36 9a 11 00       	sub    $0x119a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  100059:	e8 2e 62 00 00       	call   10628c <memset>

    cons_init();                // init the console
  10005e:	e8 2c 16 00 00       	call   10168f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f0 20 64 10 00 	movl   $0x106420,-0x10(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 3c 64 10 00 	movl   $0x10643c,(%esp)
  100078:	e8 1e 03 00 00       	call   10039b <cprintf>

    print_kerninfo();
  10007d:	e8 3c 08 00 00       	call   1008be <print_kerninfo>

    grade_backtrace();
  100082:	e8 ca 00 00 00       	call   100151 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100087:	e8 77 47 00 00       	call   104803 <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 7f 17 00 00       	call   101810 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 06 19 00 00       	call   10199c <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 53 0d 00 00       	call   100dee <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 ce 16 00 00       	call   10176e <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a0:	e8 ab 01 00 00       	call   100250 <lab1_switch_test>

    /* do nothing */
    long cnt = 0;
  1000a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
	if ((++cnt) % 10000000 == 0)
  1000ac:	ff 45 f4             	incl   -0xc(%ebp)
  1000af:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1000b2:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
  1000b7:	89 c8                	mov    %ecx,%eax
  1000b9:	f7 ea                	imul   %edx
  1000bb:	89 d0                	mov    %edx,%eax
  1000bd:	c1 f8 16             	sar    $0x16,%eax
  1000c0:	89 ca                	mov    %ecx,%edx
  1000c2:	c1 fa 1f             	sar    $0x1f,%edx
  1000c5:	29 d0                	sub    %edx,%eax
  1000c7:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
  1000cd:	89 c8                	mov    %ecx,%eax
  1000cf:	29 d0                	sub    %edx,%eax
  1000d1:	85 c0                	test   %eax,%eax
  1000d3:	75 d7                	jne    1000ac <kern_init+0x76>
	    lab1_print_cur_status();
  1000d5:	e8 9f 00 00 00       	call   100179 <lab1_print_cur_status>
	if ((++cnt) % 10000000 == 0)
  1000da:	eb d0                	jmp    1000ac <kern_init+0x76>

001000dc <grade_backtrace2>:
	}
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000dc:	55                   	push   %ebp
  1000dd:	89 e5                	mov    %esp,%ebp
  1000df:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000e9:	00 
  1000ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000f1:	00 
  1000f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000f9:	e8 0b 0c 00 00       	call   100d09 <mon_backtrace>
}
  1000fe:	90                   	nop
  1000ff:	89 ec                	mov    %ebp,%esp
  100101:	5d                   	pop    %ebp
  100102:	c3                   	ret    

00100103 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100103:	55                   	push   %ebp
  100104:	89 e5                	mov    %esp,%ebp
  100106:	83 ec 18             	sub    $0x18,%esp
  100109:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10010c:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  10010f:	8b 55 0c             	mov    0xc(%ebp),%edx
  100112:	8d 5d 08             	lea    0x8(%ebp),%ebx
  100115:	8b 45 08             	mov    0x8(%ebp),%eax
  100118:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10011c:	89 54 24 08          	mov    %edx,0x8(%esp)
  100120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100124:	89 04 24             	mov    %eax,(%esp)
  100127:	e8 b0 ff ff ff       	call   1000dc <grade_backtrace2>
}
  10012c:	90                   	nop
  10012d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100130:	89 ec                	mov    %ebp,%esp
  100132:	5d                   	pop    %ebp
  100133:	c3                   	ret    

00100134 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  100134:	55                   	push   %ebp
  100135:	89 e5                	mov    %esp,%ebp
  100137:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  10013a:	8b 45 10             	mov    0x10(%ebp),%eax
  10013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100141:	8b 45 08             	mov    0x8(%ebp),%eax
  100144:	89 04 24             	mov    %eax,(%esp)
  100147:	e8 b7 ff ff ff       	call   100103 <grade_backtrace1>
}
  10014c:	90                   	nop
  10014d:	89 ec                	mov    %ebp,%esp
  10014f:	5d                   	pop    %ebp
  100150:	c3                   	ret    

00100151 <grade_backtrace>:

void
grade_backtrace(void) {
  100151:	55                   	push   %ebp
  100152:	89 e5                	mov    %esp,%ebp
  100154:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100157:	b8 36 00 10 00       	mov    $0x100036,%eax
  10015c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100163:	ff 
  100164:	89 44 24 04          	mov    %eax,0x4(%esp)
  100168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10016f:	e8 c0 ff ff ff       	call   100134 <grade_backtrace0>
}
  100174:	90                   	nop
  100175:	89 ec                	mov    %ebp,%esp
  100177:	5d                   	pop    %ebp
  100178:	c3                   	ret    

00100179 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100179:	55                   	push   %ebp
  10017a:	89 e5                	mov    %esp,%ebp
  10017c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10017f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100182:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100185:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100188:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10018b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10018f:	83 e0 03             	and    $0x3,%eax
  100192:	89 c2                	mov    %eax,%edx
  100194:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 41 64 10 00 	movl   $0x106441,(%esp)
  1001a8:	e8 ee 01 00 00       	call   10039b <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  1001ad:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1001b1:	89 c2                	mov    %eax,%edx
  1001b3:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001b8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c0:	c7 04 24 4f 64 10 00 	movl   $0x10644f,(%esp)
  1001c7:	e8 cf 01 00 00       	call   10039b <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  1001cc:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  1001d0:	89 c2                	mov    %eax,%edx
  1001d2:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001df:	c7 04 24 5d 64 10 00 	movl   $0x10645d,(%esp)
  1001e6:	e8 b0 01 00 00       	call   10039b <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001eb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001ef:	89 c2                	mov    %eax,%edx
  1001f1:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001fe:	c7 04 24 6b 64 10 00 	movl   $0x10646b,(%esp)
  100205:	e8 91 01 00 00       	call   10039b <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10020a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10020e:	89 c2                	mov    %eax,%edx
  100210:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100215:	89 54 24 08          	mov    %edx,0x8(%esp)
  100219:	89 44 24 04          	mov    %eax,0x4(%esp)
  10021d:	c7 04 24 79 64 10 00 	movl   $0x106479,(%esp)
  100224:	e8 72 01 00 00       	call   10039b <cprintf>
    round ++;
  100229:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10022e:	40                   	inc    %eax
  10022f:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  100234:	90                   	nop
  100235:	89 ec                	mov    %ebp,%esp
  100237:	5d                   	pop    %ebp
  100238:	c3                   	ret    

00100239 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100239:	55                   	push   %ebp
  10023a:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	__asm__ __volatile__ (
  10023c:	83 ec 08             	sub    $0x8,%esp
  10023f:	cd 78                	int    $0x78
  100241:	89 ec                	mov    %ebp,%esp
		"int %0 \n"
        "movl %%ebp, %%esp\n"
		:
		:"i" (T_SWITCH_TOU)
	);
}
  100243:	90                   	nop
  100244:	5d                   	pop    %ebp
  100245:	c3                   	ret    

00100246 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100246:	55                   	push   %ebp
  100247:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
  100249:	cd 79                	int    $0x79
  10024b:	89 ec                	mov    %ebp,%esp
    	"int %0 \n"
    	"movl %%ebp,%%esp \n" 
    	:
    	:"i"(T_SWITCH_TOK)
    );
}
  10024d:	90                   	nop
  10024e:	5d                   	pop    %ebp
  10024f:	c3                   	ret    

00100250 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100250:	55                   	push   %ebp
  100251:	89 e5                	mov    %esp,%ebp
  100253:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100256:	e8 1e ff ff ff       	call   100179 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10025b:	c7 04 24 88 64 10 00 	movl   $0x106488,(%esp)
  100262:	e8 34 01 00 00       	call   10039b <cprintf>
    lab1_switch_to_user();
  100267:	e8 cd ff ff ff       	call   100239 <lab1_switch_to_user>
    lab1_print_cur_status();
  10026c:	e8 08 ff ff ff       	call   100179 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100271:	c7 04 24 a8 64 10 00 	movl   $0x1064a8,(%esp)
  100278:	e8 1e 01 00 00       	call   10039b <cprintf>
    lab1_switch_to_kernel();
  10027d:	e8 c4 ff ff ff       	call   100246 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100282:	e8 f2 fe ff ff       	call   100179 <lab1_print_cur_status>
}
  100287:	90                   	nop
  100288:	89 ec                	mov    %ebp,%esp
  10028a:	5d                   	pop    %ebp
  10028b:	c3                   	ret    

0010028c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10028c:	55                   	push   %ebp
  10028d:	89 e5                	mov    %esp,%ebp
  10028f:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100292:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100296:	74 13                	je     1002ab <readline+0x1f>
        cprintf("%s", prompt);
  100298:	8b 45 08             	mov    0x8(%ebp),%eax
  10029b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10029f:	c7 04 24 c7 64 10 00 	movl   $0x1064c7,(%esp)
  1002a6:	e8 f0 00 00 00       	call   10039b <cprintf>
    }
    int i = 0, c;
  1002ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  1002b2:	e8 73 01 00 00       	call   10042a <getchar>
  1002b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  1002ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1002be:	79 07                	jns    1002c7 <readline+0x3b>
            return NULL;
  1002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  1002c5:	eb 78                	jmp    10033f <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  1002c7:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  1002cb:	7e 28                	jle    1002f5 <readline+0x69>
  1002cd:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  1002d4:	7f 1f                	jg     1002f5 <readline+0x69>
            cputchar(c);
  1002d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d9:	89 04 24             	mov    %eax,(%esp)
  1002dc:	e8 e2 00 00 00       	call   1003c3 <cputchar>
            buf[i ++] = c;
  1002e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e4:	8d 50 01             	lea    0x1(%eax),%edx
  1002e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002ed:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1002f3:	eb 45                	jmp    10033a <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002f5:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002f9:	75 16                	jne    100311 <readline+0x85>
  1002fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ff:	7e 10                	jle    100311 <readline+0x85>
            cputchar(c);
  100301:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100304:	89 04 24             	mov    %eax,(%esp)
  100307:	e8 b7 00 00 00       	call   1003c3 <cputchar>
            i --;
  10030c:	ff 4d f4             	decl   -0xc(%ebp)
  10030f:	eb 29                	jmp    10033a <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  100311:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100315:	74 06                	je     10031d <readline+0x91>
  100317:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10031b:	75 95                	jne    1002b2 <readline+0x26>
            cputchar(c);
  10031d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100320:	89 04 24             	mov    %eax,(%esp)
  100323:	e8 9b 00 00 00       	call   1003c3 <cputchar>
            buf[i] = '\0';
  100328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10032b:	05 20 c0 11 00       	add    $0x11c020,%eax
  100330:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100333:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  100338:	eb 05                	jmp    10033f <readline+0xb3>
        c = getchar();
  10033a:	e9 73 ff ff ff       	jmp    1002b2 <readline+0x26>
        }
    }
}
  10033f:	89 ec                	mov    %ebp,%esp
  100341:	5d                   	pop    %ebp
  100342:	c3                   	ret    

00100343 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100343:	55                   	push   %ebp
  100344:	89 e5                	mov    %esp,%ebp
  100346:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100349:	8b 45 08             	mov    0x8(%ebp),%eax
  10034c:	89 04 24             	mov    %eax,(%esp)
  10034f:	e8 6a 13 00 00       	call   1016be <cons_putc>
    (*cnt) ++;
  100354:	8b 45 0c             	mov    0xc(%ebp),%eax
  100357:	8b 00                	mov    (%eax),%eax
  100359:	8d 50 01             	lea    0x1(%eax),%edx
  10035c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10035f:	89 10                	mov    %edx,(%eax)
}
  100361:	90                   	nop
  100362:	89 ec                	mov    %ebp,%esp
  100364:	5d                   	pop    %ebp
  100365:	c3                   	ret    

00100366 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100366:	55                   	push   %ebp
  100367:	89 e5                	mov    %esp,%ebp
  100369:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10036c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100373:	8b 45 0c             	mov    0xc(%ebp),%eax
  100376:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10037a:	8b 45 08             	mov    0x8(%ebp),%eax
  10037d:	89 44 24 08          	mov    %eax,0x8(%esp)
  100381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100384:	89 44 24 04          	mov    %eax,0x4(%esp)
  100388:	c7 04 24 43 03 10 00 	movl   $0x100343,(%esp)
  10038f:	e8 23 57 00 00       	call   105ab7 <vprintfmt>
    return cnt;
  100394:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100397:	89 ec                	mov    %ebp,%esp
  100399:	5d                   	pop    %ebp
  10039a:	c3                   	ret    

0010039b <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10039b:	55                   	push   %ebp
  10039c:	89 e5                	mov    %esp,%ebp
  10039e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1003a1:	8d 45 0c             	lea    0xc(%ebp),%eax
  1003a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1003a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b1:	89 04 24             	mov    %eax,(%esp)
  1003b4:	e8 ad ff ff ff       	call   100366 <vcprintf>
  1003b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003bf:	89 ec                	mov    %ebp,%esp
  1003c1:	5d                   	pop    %ebp
  1003c2:	c3                   	ret    

001003c3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1003c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1003cc:	89 04 24             	mov    %eax,(%esp)
  1003cf:	e8 ea 12 00 00       	call   1016be <cons_putc>
}
  1003d4:	90                   	nop
  1003d5:	89 ec                	mov    %ebp,%esp
  1003d7:	5d                   	pop    %ebp
  1003d8:	c3                   	ret    

001003d9 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1003d9:	55                   	push   %ebp
  1003da:	89 e5                	mov    %esp,%ebp
  1003dc:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1003df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003e6:	eb 13                	jmp    1003fb <cputs+0x22>
        cputch(c, &cnt);
  1003e8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003ec:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003f3:	89 04 24             	mov    %eax,(%esp)
  1003f6:	e8 48 ff ff ff       	call   100343 <cputch>
    while ((c = *str ++) != '\0') {
  1003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1003fe:	8d 50 01             	lea    0x1(%eax),%edx
  100401:	89 55 08             	mov    %edx,0x8(%ebp)
  100404:	0f b6 00             	movzbl (%eax),%eax
  100407:	88 45 f7             	mov    %al,-0x9(%ebp)
  10040a:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  10040e:	75 d8                	jne    1003e8 <cputs+0xf>
    }
    cputch('\n', &cnt);
  100410:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100413:	89 44 24 04          	mov    %eax,0x4(%esp)
  100417:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  10041e:	e8 20 ff ff ff       	call   100343 <cputch>
    return cnt;
  100423:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100426:	89 ec                	mov    %ebp,%esp
  100428:	5d                   	pop    %ebp
  100429:	c3                   	ret    

0010042a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10042a:	55                   	push   %ebp
  10042b:	89 e5                	mov    %esp,%ebp
  10042d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100430:	90                   	nop
  100431:	e8 c7 12 00 00       	call   1016fd <cons_getc>
  100436:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10043d:	74 f2                	je     100431 <getchar+0x7>
        /* do nothing */;
    return c;
  10043f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100442:	89 ec                	mov    %ebp,%esp
  100444:	5d                   	pop    %ebp
  100445:	c3                   	ret    

00100446 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100446:	55                   	push   %ebp
  100447:	89 e5                	mov    %esp,%ebp
  100449:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10044f:	8b 00                	mov    (%eax),%eax
  100451:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100454:	8b 45 10             	mov    0x10(%ebp),%eax
  100457:	8b 00                	mov    (%eax),%eax
  100459:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10045c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100463:	e9 ca 00 00 00       	jmp    100532 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100468:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10046b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10046e:	01 d0                	add    %edx,%eax
  100470:	89 c2                	mov    %eax,%edx
  100472:	c1 ea 1f             	shr    $0x1f,%edx
  100475:	01 d0                	add    %edx,%eax
  100477:	d1 f8                	sar    %eax
  100479:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10047c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10047f:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100482:	eb 03                	jmp    100487 <stab_binsearch+0x41>
            m --;
  100484:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10048a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10048d:	7c 1f                	jl     1004ae <stab_binsearch+0x68>
  10048f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100492:	89 d0                	mov    %edx,%eax
  100494:	01 c0                	add    %eax,%eax
  100496:	01 d0                	add    %edx,%eax
  100498:	c1 e0 02             	shl    $0x2,%eax
  10049b:	89 c2                	mov    %eax,%edx
  10049d:	8b 45 08             	mov    0x8(%ebp),%eax
  1004a0:	01 d0                	add    %edx,%eax
  1004a2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004a6:	0f b6 c0             	movzbl %al,%eax
  1004a9:	39 45 14             	cmp    %eax,0x14(%ebp)
  1004ac:	75 d6                	jne    100484 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  1004ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004b4:	7d 09                	jge    1004bf <stab_binsearch+0x79>
            l = true_m + 1;
  1004b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004b9:	40                   	inc    %eax
  1004ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  1004bd:	eb 73                	jmp    100532 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  1004bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  1004c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004c9:	89 d0                	mov    %edx,%eax
  1004cb:	01 c0                	add    %eax,%eax
  1004cd:	01 d0                	add    %edx,%eax
  1004cf:	c1 e0 02             	shl    $0x2,%eax
  1004d2:	89 c2                	mov    %eax,%edx
  1004d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d7:	01 d0                	add    %edx,%eax
  1004d9:	8b 40 08             	mov    0x8(%eax),%eax
  1004dc:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004df:	76 11                	jbe    1004f2 <stab_binsearch+0xac>
            *region_left = m;
  1004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e7:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004ec:	40                   	inc    %eax
  1004ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004f0:	eb 40                	jmp    100532 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004f5:	89 d0                	mov    %edx,%eax
  1004f7:	01 c0                	add    %eax,%eax
  1004f9:	01 d0                	add    %edx,%eax
  1004fb:	c1 e0 02             	shl    $0x2,%eax
  1004fe:	89 c2                	mov    %eax,%edx
  100500:	8b 45 08             	mov    0x8(%ebp),%eax
  100503:	01 d0                	add    %edx,%eax
  100505:	8b 40 08             	mov    0x8(%eax),%eax
  100508:	39 45 18             	cmp    %eax,0x18(%ebp)
  10050b:	73 14                	jae    100521 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10050d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100510:	8d 50 ff             	lea    -0x1(%eax),%edx
  100513:	8b 45 10             	mov    0x10(%ebp),%eax
  100516:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10051b:	48                   	dec    %eax
  10051c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10051f:	eb 11                	jmp    100532 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100521:	8b 45 0c             	mov    0xc(%ebp),%eax
  100524:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100527:	89 10                	mov    %edx,(%eax)
            l = m;
  100529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10052f:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  100532:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100535:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100538:	0f 8e 2a ff ff ff    	jle    100468 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  10053e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100542:	75 0f                	jne    100553 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 00                	mov    (%eax),%eax
  100549:	8d 50 ff             	lea    -0x1(%eax),%edx
  10054c:	8b 45 10             	mov    0x10(%ebp),%eax
  10054f:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  100551:	eb 3e                	jmp    100591 <stab_binsearch+0x14b>
        l = *region_right;
  100553:	8b 45 10             	mov    0x10(%ebp),%eax
  100556:	8b 00                	mov    (%eax),%eax
  100558:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  10055b:	eb 03                	jmp    100560 <stab_binsearch+0x11a>
  10055d:	ff 4d fc             	decl   -0x4(%ebp)
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	8b 00                	mov    (%eax),%eax
  100565:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100568:	7e 1f                	jle    100589 <stab_binsearch+0x143>
  10056a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10056d:	89 d0                	mov    %edx,%eax
  10056f:	01 c0                	add    %eax,%eax
  100571:	01 d0                	add    %edx,%eax
  100573:	c1 e0 02             	shl    $0x2,%eax
  100576:	89 c2                	mov    %eax,%edx
  100578:	8b 45 08             	mov    0x8(%ebp),%eax
  10057b:	01 d0                	add    %edx,%eax
  10057d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100581:	0f b6 c0             	movzbl %al,%eax
  100584:	39 45 14             	cmp    %eax,0x14(%ebp)
  100587:	75 d4                	jne    10055d <stab_binsearch+0x117>
        *region_left = l;
  100589:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10058f:	89 10                	mov    %edx,(%eax)
}
  100591:	90                   	nop
  100592:	89 ec                	mov    %ebp,%esp
  100594:	5d                   	pop    %ebp
  100595:	c3                   	ret    

00100596 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100596:	55                   	push   %ebp
  100597:	89 e5                	mov    %esp,%ebp
  100599:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10059c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10059f:	c7 00 cc 64 10 00    	movl   $0x1064cc,(%eax)
    info->eip_line = 0;
  1005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b2:	c7 40 08 cc 64 10 00 	movl   $0x1064cc,0x8(%eax)
    info->eip_fn_namelen = 9;
  1005b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005bc:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  1005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005c6:	8b 55 08             	mov    0x8(%ebp),%edx
  1005c9:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  1005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005cf:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  1005d6:	c7 45 f4 b0 77 10 00 	movl   $0x1077b0,-0xc(%ebp)
    stab_end = __STAB_END__;
  1005dd:	c7 45 f0 90 33 11 00 	movl   $0x113390,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  1005e4:	c7 45 ec 91 33 11 00 	movl   $0x113391,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005eb:	c7 45 e8 a4 69 11 00 	movl   $0x1169a4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005f8:	76 0b                	jbe    100605 <debuginfo_eip+0x6f>
  1005fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005fd:	48                   	dec    %eax
  1005fe:	0f b6 00             	movzbl (%eax),%eax
  100601:	84 c0                	test   %al,%al
  100603:	74 0a                	je     10060f <debuginfo_eip+0x79>
        return -1;
  100605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060a:	e9 ab 02 00 00       	jmp    1008ba <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10060f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100619:	2b 45 f4             	sub    -0xc(%ebp),%eax
  10061c:	c1 f8 02             	sar    $0x2,%eax
  10061f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100625:	48                   	dec    %eax
  100626:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100637:	00 
  100638:	8d 45 e0             	lea    -0x20(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 f5 fd ff ff       	call   100446 <stab_binsearch>
    if (lfile == 0)
  100651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100654:	85 c0                	test   %eax,%eax
  100656:	75 0a                	jne    100662 <debuginfo_eip+0xcc>
        return -1;
  100658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10065d:	e9 58 02 00 00       	jmp    1008ba <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100665:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100668:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10066e:	8b 45 08             	mov    0x8(%ebp),%eax
  100671:	89 44 24 10          	mov    %eax,0x10(%esp)
  100675:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10067c:	00 
  10067d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100680:	89 44 24 08          	mov    %eax,0x8(%esp)
  100684:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100687:	89 44 24 04          	mov    %eax,0x4(%esp)
  10068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068e:	89 04 24             	mov    %eax,(%esp)
  100691:	e8 b0 fd ff ff       	call   100446 <stab_binsearch>

    if (lfun <= rfun) {
  100696:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100699:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10069c:	39 c2                	cmp    %eax,%edx
  10069e:	7f 78                	jg     100718 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a3:	89 c2                	mov    %eax,%edx
  1006a5:	89 d0                	mov    %edx,%eax
  1006a7:	01 c0                	add    %eax,%eax
  1006a9:	01 d0                	add    %edx,%eax
  1006ab:	c1 e0 02             	shl    $0x2,%eax
  1006ae:	89 c2                	mov    %eax,%edx
  1006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b3:	01 d0                	add    %edx,%eax
  1006b5:	8b 10                	mov    (%eax),%edx
  1006b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006ba:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1006bd:	39 c2                	cmp    %eax,%edx
  1006bf:	73 22                	jae    1006e3 <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  1006c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c4:	89 c2                	mov    %eax,%edx
  1006c6:	89 d0                	mov    %edx,%eax
  1006c8:	01 c0                	add    %eax,%eax
  1006ca:	01 d0                	add    %edx,%eax
  1006cc:	c1 e0 02             	shl    $0x2,%eax
  1006cf:	89 c2                	mov    %eax,%edx
  1006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006d4:	01 d0                	add    %edx,%eax
  1006d6:	8b 10                	mov    (%eax),%edx
  1006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1006db:	01 c2                	add    %eax,%edx
  1006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1006e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006e6:	89 c2                	mov    %eax,%edx
  1006e8:	89 d0                	mov    %edx,%eax
  1006ea:	01 c0                	add    %eax,%eax
  1006ec:	01 d0                	add    %edx,%eax
  1006ee:	c1 e0 02             	shl    $0x2,%eax
  1006f1:	89 c2                	mov    %eax,%edx
  1006f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006f6:	01 d0                	add    %edx,%eax
  1006f8:	8b 50 08             	mov    0x8(%eax),%edx
  1006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fe:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100701:	8b 45 0c             	mov    0xc(%ebp),%eax
  100704:	8b 40 10             	mov    0x10(%eax),%eax
  100707:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10070a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10070d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100710:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100713:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100716:	eb 15                	jmp    10072d <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100718:	8b 45 0c             	mov    0xc(%ebp),%eax
  10071b:	8b 55 08             	mov    0x8(%ebp),%edx
  10071e:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100724:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10072a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10072d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100730:	8b 40 08             	mov    0x8(%eax),%eax
  100733:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10073a:	00 
  10073b:	89 04 24             	mov    %eax,(%esp)
  10073e:	e8 c1 59 00 00       	call   106104 <strfind>
  100743:	8b 55 0c             	mov    0xc(%ebp),%edx
  100746:	8b 4a 08             	mov    0x8(%edx),%ecx
  100749:	29 c8                	sub    %ecx,%eax
  10074b:	89 c2                	mov    %eax,%edx
  10074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100750:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100753:	8b 45 08             	mov    0x8(%ebp),%eax
  100756:	89 44 24 10          	mov    %eax,0x10(%esp)
  10075a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100761:	00 
  100762:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100765:	89 44 24 08          	mov    %eax,0x8(%esp)
  100769:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  10076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100773:	89 04 24             	mov    %eax,(%esp)
  100776:	e8 cb fc ff ff       	call   100446 <stab_binsearch>
    if (lline <= rline) {
  10077b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10077e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100781:	39 c2                	cmp    %eax,%edx
  100783:	7f 23                	jg     1007a8 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100785:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100788:	89 c2                	mov    %eax,%edx
  10078a:	89 d0                	mov    %edx,%eax
  10078c:	01 c0                	add    %eax,%eax
  10078e:	01 d0                	add    %edx,%eax
  100790:	c1 e0 02             	shl    $0x2,%eax
  100793:	89 c2                	mov    %eax,%edx
  100795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100798:	01 d0                	add    %edx,%eax
  10079a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a3:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007a6:	eb 11                	jmp    1007b9 <debuginfo_eip+0x223>
        return -1;
  1007a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007ad:	e9 08 01 00 00       	jmp    1008ba <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b5:	48                   	dec    %eax
  1007b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  1007b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007bf:	39 c2                	cmp    %eax,%edx
  1007c1:	7c 56                	jl     100819 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  1007c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	89 d0                	mov    %edx,%eax
  1007ca:	01 c0                	add    %eax,%eax
  1007cc:	01 d0                	add    %edx,%eax
  1007ce:	c1 e0 02             	shl    $0x2,%eax
  1007d1:	89 c2                	mov    %eax,%edx
  1007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007d6:	01 d0                	add    %edx,%eax
  1007d8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007dc:	3c 84                	cmp    $0x84,%al
  1007de:	74 39                	je     100819 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e3:	89 c2                	mov    %eax,%edx
  1007e5:	89 d0                	mov    %edx,%eax
  1007e7:	01 c0                	add    %eax,%eax
  1007e9:	01 d0                	add    %edx,%eax
  1007eb:	c1 e0 02             	shl    $0x2,%eax
  1007ee:	89 c2                	mov    %eax,%edx
  1007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f3:	01 d0                	add    %edx,%eax
  1007f5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007f9:	3c 64                	cmp    $0x64,%al
  1007fb:	75 b5                	jne    1007b2 <debuginfo_eip+0x21c>
  1007fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100800:	89 c2                	mov    %eax,%edx
  100802:	89 d0                	mov    %edx,%eax
  100804:	01 c0                	add    %eax,%eax
  100806:	01 d0                	add    %edx,%eax
  100808:	c1 e0 02             	shl    $0x2,%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	8b 40 08             	mov    0x8(%eax),%eax
  100815:	85 c0                	test   %eax,%eax
  100817:	74 99                	je     1007b2 <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100819:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10081c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10081f:	39 c2                	cmp    %eax,%edx
  100821:	7c 42                	jl     100865 <debuginfo_eip+0x2cf>
  100823:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100826:	89 c2                	mov    %eax,%edx
  100828:	89 d0                	mov    %edx,%eax
  10082a:	01 c0                	add    %eax,%eax
  10082c:	01 d0                	add    %edx,%eax
  10082e:	c1 e0 02             	shl    $0x2,%eax
  100831:	89 c2                	mov    %eax,%edx
  100833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100836:	01 d0                	add    %edx,%eax
  100838:	8b 10                	mov    (%eax),%edx
  10083a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10083d:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100840:	39 c2                	cmp    %eax,%edx
  100842:	73 21                	jae    100865 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100847:	89 c2                	mov    %eax,%edx
  100849:	89 d0                	mov    %edx,%eax
  10084b:	01 c0                	add    %eax,%eax
  10084d:	01 d0                	add    %edx,%eax
  10084f:	c1 e0 02             	shl    $0x2,%eax
  100852:	89 c2                	mov    %eax,%edx
  100854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100857:	01 d0                	add    %edx,%eax
  100859:	8b 10                	mov    (%eax),%edx
  10085b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10085e:	01 c2                	add    %eax,%edx
  100860:	8b 45 0c             	mov    0xc(%ebp),%eax
  100863:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100865:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100868:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10086b:	39 c2                	cmp    %eax,%edx
  10086d:	7d 46                	jge    1008b5 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10086f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100872:	40                   	inc    %eax
  100873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100876:	eb 16                	jmp    10088e <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100878:	8b 45 0c             	mov    0xc(%ebp),%eax
  10087b:	8b 40 14             	mov    0x14(%eax),%eax
  10087e:	8d 50 01             	lea    0x1(%eax),%edx
  100881:	8b 45 0c             	mov    0xc(%ebp),%eax
  100884:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100887:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10088a:	40                   	inc    %eax
  10088b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10088e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100891:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100894:	39 c2                	cmp    %eax,%edx
  100896:	7d 1d                	jge    1008b5 <debuginfo_eip+0x31f>
  100898:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089b:	89 c2                	mov    %eax,%edx
  10089d:	89 d0                	mov    %edx,%eax
  10089f:	01 c0                	add    %eax,%eax
  1008a1:	01 d0                	add    %edx,%eax
  1008a3:	c1 e0 02             	shl    $0x2,%eax
  1008a6:	89 c2                	mov    %eax,%edx
  1008a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ab:	01 d0                	add    %edx,%eax
  1008ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008b1:	3c a0                	cmp    $0xa0,%al
  1008b3:	74 c3                	je     100878 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  1008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1008ba:	89 ec                	mov    %ebp,%esp
  1008bc:	5d                   	pop    %ebp
  1008bd:	c3                   	ret    

001008be <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  1008be:	55                   	push   %ebp
  1008bf:	89 e5                	mov    %esp,%ebp
  1008c1:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  1008c4:	c7 04 24 d6 64 10 00 	movl   $0x1064d6,(%esp)
  1008cb:	e8 cb fa ff ff       	call   10039b <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  1008d0:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1008d7:	00 
  1008d8:	c7 04 24 ef 64 10 00 	movl   $0x1064ef,(%esp)
  1008df:	e8 b7 fa ff ff       	call   10039b <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008e4:	c7 44 24 04 18 64 10 	movl   $0x106418,0x4(%esp)
  1008eb:	00 
  1008ec:	c7 04 24 07 65 10 00 	movl   $0x106507,(%esp)
  1008f3:	e8 a3 fa ff ff       	call   10039b <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008f8:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008ff:	00 
  100900:	c7 04 24 1f 65 10 00 	movl   $0x10651f,(%esp)
  100907:	e8 8f fa ff ff       	call   10039b <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  10090c:	c7 44 24 04 8c cf 11 	movl   $0x11cf8c,0x4(%esp)
  100913:	00 
  100914:	c7 04 24 37 65 10 00 	movl   $0x106537,(%esp)
  10091b:	e8 7b fa ff ff       	call   10039b <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100920:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  100925:	2d 36 00 10 00       	sub    $0x100036,%eax
  10092a:	05 ff 03 00 00       	add    $0x3ff,%eax
  10092f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100935:	85 c0                	test   %eax,%eax
  100937:	0f 48 c2             	cmovs  %edx,%eax
  10093a:	c1 f8 0a             	sar    $0xa,%eax
  10093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100941:	c7 04 24 50 65 10 00 	movl   $0x106550,(%esp)
  100948:	e8 4e fa ff ff       	call   10039b <cprintf>
}
  10094d:	90                   	nop
  10094e:	89 ec                	mov    %ebp,%esp
  100950:	5d                   	pop    %ebp
  100951:	c3                   	ret    

00100952 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100952:	55                   	push   %ebp
  100953:	89 e5                	mov    %esp,%ebp
  100955:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10095b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100962:	8b 45 08             	mov    0x8(%ebp),%eax
  100965:	89 04 24             	mov    %eax,(%esp)
  100968:	e8 29 fc ff ff       	call   100596 <debuginfo_eip>
  10096d:	85 c0                	test   %eax,%eax
  10096f:	74 15                	je     100986 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100971:	8b 45 08             	mov    0x8(%ebp),%eax
  100974:	89 44 24 04          	mov    %eax,0x4(%esp)
  100978:	c7 04 24 7a 65 10 00 	movl   $0x10657a,(%esp)
  10097f:	e8 17 fa ff ff       	call   10039b <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100984:	eb 6c                	jmp    1009f2 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10098d:	eb 1b                	jmp    1009aa <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10098f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100995:	01 d0                	add    %edx,%eax
  100997:	0f b6 10             	movzbl (%eax),%edx
  10099a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009a3:	01 c8                	add    %ecx,%eax
  1009a5:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009a7:	ff 45 f4             	incl   -0xc(%ebp)
  1009aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009ad:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1009b0:	7c dd                	jl     10098f <print_debuginfo+0x3d>
        fnname[j] = '\0';
  1009b2:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  1009b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009bb:	01 d0                	add    %edx,%eax
  1009bd:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  1009c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  1009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1009c6:	29 d0                	sub    %edx,%eax
  1009c8:	89 c1                	mov    %eax,%ecx
  1009ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1009cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1009d0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1009d4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1009de:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009e6:	c7 04 24 96 65 10 00 	movl   $0x106596,(%esp)
  1009ed:	e8 a9 f9 ff ff       	call   10039b <cprintf>
}
  1009f2:	90                   	nop
  1009f3:	89 ec                	mov    %ebp,%esp
  1009f5:	5d                   	pop    %ebp
  1009f6:	c3                   	ret    

001009f7 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009f7:	55                   	push   %ebp
  1009f8:	89 e5                	mov    %esp,%ebp
  1009fa:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009fd:	8b 45 04             	mov    0x4(%ebp),%eax
  100a00:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a06:	89 ec                	mov    %ebp,%esp
  100a08:	5d                   	pop    %ebp
  100a09:	c3                   	ret    

00100a0a <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a0a:	55                   	push   %ebp
  100a0b:	89 e5                	mov    %esp,%ebp
  100a0d:	83 ec 48             	sub    $0x48,%esp
  100a10:	89 5d fc             	mov    %ebx,-0x4(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a13:	89 e8                	mov    %ebp,%eax
  100a15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp();
  100a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
  100a1e:	e8 d4 ff ff ff       	call   1009f7 <read_eip>
  100a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;   //这里有个细节问题，就是不能for int i，这里面的C标准似乎不允许
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  100a26:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a2d:	eb 7e                	jmp    100aad <print_stackframe+0xa3>
	{
		cprintf("ebp:0x%08x eip:0x%08x\n",ebp,eip);
  100a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3d:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  100a44:	e8 52 f9 ff ff       	call   10039b <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
  100a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a4c:	83 c0 08             	add    $0x8,%eax
  100a4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));//依次打印调用函数的参数1 2 3 4
  100a52:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a55:	83 c0 0c             	add    $0xc,%eax
  100a58:	8b 18                	mov    (%eax),%ebx
  100a5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a5d:	83 c0 08             	add    $0x8,%eax
  100a60:	8b 08                	mov    (%eax),%ecx
  100a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a65:	83 c0 04             	add    $0x4,%eax
  100a68:	8b 10                	mov    (%eax),%edx
  100a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a6d:	8b 00                	mov    (%eax),%eax
  100a6f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a73:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a77:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a7f:	c7 04 24 c0 65 10 00 	movl   $0x1065c0,(%esp)
  100a86:	e8 10 f9 ff ff       	call   10039b <cprintf>
 
 
    //因为使用的是栈数据结构，因此可以直接根据ebp就能读取到各个栈帧的地址和值，ebp+4处为返回地址，
    //ebp+8处为第一个参数值（最后一个入栈的参数值，对应32位系统），ebp-4处为第一个局部变量，ebp处为上一层 ebp 值。

		print_debuginfo(eip-1);
  100a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a8e:	48                   	dec    %eax
  100a8f:	89 04 24             	mov    %eax,(%esp)
  100a92:	e8 bb fe ff ff       	call   100952 <print_debuginfo>
		eip=((uint32_t *)ebp)[1];
  100a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a9a:	83 c0 04             	add    $0x4,%eax
  100a9d:	8b 00                	mov    (%eax),%eax
  100a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
  100aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aa5:	8b 00                	mov    (%eax),%eax
  100aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  100aaa:	ff 45 ec             	incl   -0x14(%ebp)
  100aad:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100ab1:	7f 0a                	jg     100abd <print_stackframe+0xb3>
  100ab3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100ab7:	0f 85 72 ff ff ff    	jne    100a2f <print_stackframe+0x25>
    }
}
  100abd:	90                   	nop
  100abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100ac1:	89 ec                	mov    %ebp,%esp
  100ac3:	5d                   	pop    %ebp
  100ac4:	c3                   	ret    

00100ac5 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100ac5:	55                   	push   %ebp
  100ac6:	89 e5                	mov    %esp,%ebp
  100ac8:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100acb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ad2:	eb 0c                	jmp    100ae0 <parse+0x1b>
            *buf ++ = '\0';
  100ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ad7:	8d 50 01             	lea    0x1(%eax),%edx
  100ada:	89 55 08             	mov    %edx,0x8(%ebp)
  100add:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae3:	0f b6 00             	movzbl (%eax),%eax
  100ae6:	84 c0                	test   %al,%al
  100ae8:	74 1d                	je     100b07 <parse+0x42>
  100aea:	8b 45 08             	mov    0x8(%ebp),%eax
  100aed:	0f b6 00             	movzbl (%eax),%eax
  100af0:	0f be c0             	movsbl %al,%eax
  100af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100af7:	c7 04 24 64 66 10 00 	movl   $0x106664,(%esp)
  100afe:	e8 cd 55 00 00       	call   1060d0 <strchr>
  100b03:	85 c0                	test   %eax,%eax
  100b05:	75 cd                	jne    100ad4 <parse+0xf>
        }
        if (*buf == '\0') {
  100b07:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0a:	0f b6 00             	movzbl (%eax),%eax
  100b0d:	84 c0                	test   %al,%al
  100b0f:	74 65                	je     100b76 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b11:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b15:	75 14                	jne    100b2b <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b17:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b1e:	00 
  100b1f:	c7 04 24 69 66 10 00 	movl   $0x106669,(%esp)
  100b26:	e8 70 f8 ff ff       	call   10039b <cprintf>
        }
        argv[argc ++] = buf;
  100b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b2e:	8d 50 01             	lea    0x1(%eax),%edx
  100b31:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b3e:	01 c2                	add    %eax,%edx
  100b40:	8b 45 08             	mov    0x8(%ebp),%eax
  100b43:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b45:	eb 03                	jmp    100b4a <parse+0x85>
            buf ++;
  100b47:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4d:	0f b6 00             	movzbl (%eax),%eax
  100b50:	84 c0                	test   %al,%al
  100b52:	74 8c                	je     100ae0 <parse+0x1b>
  100b54:	8b 45 08             	mov    0x8(%ebp),%eax
  100b57:	0f b6 00             	movzbl (%eax),%eax
  100b5a:	0f be c0             	movsbl %al,%eax
  100b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b61:	c7 04 24 64 66 10 00 	movl   $0x106664,(%esp)
  100b68:	e8 63 55 00 00       	call   1060d0 <strchr>
  100b6d:	85 c0                	test   %eax,%eax
  100b6f:	74 d6                	je     100b47 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b71:	e9 6a ff ff ff       	jmp    100ae0 <parse+0x1b>
            break;
  100b76:	90                   	nop
        }
    }
    return argc;
  100b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b7a:	89 ec                	mov    %ebp,%esp
  100b7c:	5d                   	pop    %ebp
  100b7d:	c3                   	ret    

00100b7e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b7e:	55                   	push   %ebp
  100b7f:	89 e5                	mov    %esp,%ebp
  100b81:	83 ec 68             	sub    $0x68,%esp
  100b84:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b87:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b91:	89 04 24             	mov    %eax,(%esp)
  100b94:	e8 2c ff ff ff       	call   100ac5 <parse>
  100b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100ba0:	75 0a                	jne    100bac <runcmd+0x2e>
        return 0;
  100ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  100ba7:	e9 83 00 00 00       	jmp    100c2f <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100bb3:	eb 5a                	jmp    100c0f <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100bb5:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100bb8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100bbb:	89 c8                	mov    %ecx,%eax
  100bbd:	01 c0                	add    %eax,%eax
  100bbf:	01 c8                	add    %ecx,%eax
  100bc1:	c1 e0 02             	shl    $0x2,%eax
  100bc4:	05 00 90 11 00       	add    $0x119000,%eax
  100bc9:	8b 00                	mov    (%eax),%eax
  100bcb:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bcf:	89 04 24             	mov    %eax,(%esp)
  100bd2:	e8 5d 54 00 00       	call   106034 <strcmp>
  100bd7:	85 c0                	test   %eax,%eax
  100bd9:	75 31                	jne    100c0c <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bde:	89 d0                	mov    %edx,%eax
  100be0:	01 c0                	add    %eax,%eax
  100be2:	01 d0                	add    %edx,%eax
  100be4:	c1 e0 02             	shl    $0x2,%eax
  100be7:	05 08 90 11 00       	add    $0x119008,%eax
  100bec:	8b 10                	mov    (%eax),%edx
  100bee:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bf1:	83 c0 04             	add    $0x4,%eax
  100bf4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bf7:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c05:	89 1c 24             	mov    %ebx,(%esp)
  100c08:	ff d2                	call   *%edx
  100c0a:	eb 23                	jmp    100c2f <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c0c:	ff 45 f4             	incl   -0xc(%ebp)
  100c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c12:	83 f8 02             	cmp    $0x2,%eax
  100c15:	76 9e                	jbe    100bb5 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c17:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c1e:	c7 04 24 87 66 10 00 	movl   $0x106687,(%esp)
  100c25:	e8 71 f7 ff ff       	call   10039b <cprintf>
    return 0;
  100c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100c32:	89 ec                	mov    %ebp,%esp
  100c34:	5d                   	pop    %ebp
  100c35:	c3                   	ret    

00100c36 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c36:	55                   	push   %ebp
  100c37:	89 e5                	mov    %esp,%ebp
  100c39:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c3c:	c7 04 24 a0 66 10 00 	movl   $0x1066a0,(%esp)
  100c43:	e8 53 f7 ff ff       	call   10039b <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c48:	c7 04 24 c8 66 10 00 	movl   $0x1066c8,(%esp)
  100c4f:	e8 47 f7 ff ff       	call   10039b <cprintf>

    if (tf != NULL) {
  100c54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c58:	74 0b                	je     100c65 <kmonitor+0x2f>
        print_trapframe(tf);
  100c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  100c5d:	89 04 24             	mov    %eax,(%esp)
  100c60:	e8 6e 0f 00 00       	call   101bd3 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c65:	c7 04 24 ed 66 10 00 	movl   $0x1066ed,(%esp)
  100c6c:	e8 1b f6 ff ff       	call   10028c <readline>
  100c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c78:	74 eb                	je     100c65 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  100c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c84:	89 04 24             	mov    %eax,(%esp)
  100c87:	e8 f2 fe ff ff       	call   100b7e <runcmd>
  100c8c:	85 c0                	test   %eax,%eax
  100c8e:	78 02                	js     100c92 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c90:	eb d3                	jmp    100c65 <kmonitor+0x2f>
                break;
  100c92:	90                   	nop
            }
        }
    }
}
  100c93:	90                   	nop
  100c94:	89 ec                	mov    %ebp,%esp
  100c96:	5d                   	pop    %ebp
  100c97:	c3                   	ret    

00100c98 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c98:	55                   	push   %ebp
  100c99:	89 e5                	mov    %esp,%ebp
  100c9b:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ca5:	eb 3d                	jmp    100ce4 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100ca7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100caa:	89 d0                	mov    %edx,%eax
  100cac:	01 c0                	add    %eax,%eax
  100cae:	01 d0                	add    %edx,%eax
  100cb0:	c1 e0 02             	shl    $0x2,%eax
  100cb3:	05 04 90 11 00       	add    $0x119004,%eax
  100cb8:	8b 10                	mov    (%eax),%edx
  100cba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100cbd:	89 c8                	mov    %ecx,%eax
  100cbf:	01 c0                	add    %eax,%eax
  100cc1:	01 c8                	add    %ecx,%eax
  100cc3:	c1 e0 02             	shl    $0x2,%eax
  100cc6:	05 00 90 11 00       	add    $0x119000,%eax
  100ccb:	8b 00                	mov    (%eax),%eax
  100ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
  100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cd5:	c7 04 24 f1 66 10 00 	movl   $0x1066f1,(%esp)
  100cdc:	e8 ba f6 ff ff       	call   10039b <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100ce1:	ff 45 f4             	incl   -0xc(%ebp)
  100ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ce7:	83 f8 02             	cmp    $0x2,%eax
  100cea:	76 bb                	jbe    100ca7 <mon_help+0xf>
    }
    return 0;
  100cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cf1:	89 ec                	mov    %ebp,%esp
  100cf3:	5d                   	pop    %ebp
  100cf4:	c3                   	ret    

00100cf5 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cf5:	55                   	push   %ebp
  100cf6:	89 e5                	mov    %esp,%ebp
  100cf8:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cfb:	e8 be fb ff ff       	call   1008be <print_kerninfo>
    return 0;
  100d00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d05:	89 ec                	mov    %ebp,%esp
  100d07:	5d                   	pop    %ebp
  100d08:	c3                   	ret    

00100d09 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d09:	55                   	push   %ebp
  100d0a:	89 e5                	mov    %esp,%ebp
  100d0c:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d0f:	e8 f6 fc ff ff       	call   100a0a <print_stackframe>
    return 0;
  100d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d19:	89 ec                	mov    %ebp,%esp
  100d1b:	5d                   	pop    %ebp
  100d1c:	c3                   	ret    

00100d1d <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100d1d:	55                   	push   %ebp
  100d1e:	89 e5                	mov    %esp,%ebp
  100d20:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100d23:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100d28:	85 c0                	test   %eax,%eax
  100d2a:	75 5b                	jne    100d87 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100d2c:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100d33:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d36:	8d 45 14             	lea    0x14(%ebp),%eax
  100d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d43:	8b 45 08             	mov    0x8(%ebp),%eax
  100d46:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d4a:	c7 04 24 fa 66 10 00 	movl   $0x1066fa,(%esp)
  100d51:	e8 45 f6 ff ff       	call   10039b <cprintf>
    vcprintf(fmt, ap);
  100d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  100d60:	89 04 24             	mov    %eax,(%esp)
  100d63:	e8 fe f5 ff ff       	call   100366 <vcprintf>
    cprintf("\n");
  100d68:	c7 04 24 16 67 10 00 	movl   $0x106716,(%esp)
  100d6f:	e8 27 f6 ff ff       	call   10039b <cprintf>
    
    cprintf("stack trackback:\n");
  100d74:	c7 04 24 18 67 10 00 	movl   $0x106718,(%esp)
  100d7b:	e8 1b f6 ff ff       	call   10039b <cprintf>
    print_stackframe();
  100d80:	e8 85 fc ff ff       	call   100a0a <print_stackframe>
  100d85:	eb 01                	jmp    100d88 <__panic+0x6b>
        goto panic_dead;
  100d87:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d88:	e8 e9 09 00 00       	call   101776 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d94:	e8 9d fe ff ff       	call   100c36 <kmonitor>
  100d99:	eb f2                	jmp    100d8d <__panic+0x70>

00100d9b <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d9b:	55                   	push   %ebp
  100d9c:	89 e5                	mov    %esp,%ebp
  100d9e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100da1:	8d 45 14             	lea    0x14(%ebp),%eax
  100da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100daa:	89 44 24 08          	mov    %eax,0x8(%esp)
  100dae:	8b 45 08             	mov    0x8(%ebp),%eax
  100db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100db5:	c7 04 24 2a 67 10 00 	movl   $0x10672a,(%esp)
  100dbc:	e8 da f5 ff ff       	call   10039b <cprintf>
    vcprintf(fmt, ap);
  100dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  100dcb:	89 04 24             	mov    %eax,(%esp)
  100dce:	e8 93 f5 ff ff       	call   100366 <vcprintf>
    cprintf("\n");
  100dd3:	c7 04 24 16 67 10 00 	movl   $0x106716,(%esp)
  100dda:	e8 bc f5 ff ff       	call   10039b <cprintf>
    va_end(ap);
}
  100ddf:	90                   	nop
  100de0:	89 ec                	mov    %ebp,%esp
  100de2:	5d                   	pop    %ebp
  100de3:	c3                   	ret    

00100de4 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100de4:	55                   	push   %ebp
  100de5:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100de7:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  100dec:	5d                   	pop    %ebp
  100ded:	c3                   	ret    

00100dee <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dee:	55                   	push   %ebp
  100def:	89 e5                	mov    %esp,%ebp
  100df1:	83 ec 28             	sub    $0x28,%esp
  100df4:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dfa:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dfe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e02:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100e06:	ee                   	out    %al,(%dx)
}
  100e07:	90                   	nop
  100e08:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100e0e:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e12:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e16:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e1a:	ee                   	out    %al,(%dx)
}
  100e1b:	90                   	nop
  100e1c:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e22:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e26:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e2a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e2e:	ee                   	out    %al,(%dx)
}
  100e2f:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e30:	c7 05 24 c4 11 00 00 	movl   $0x0,0x11c424
  100e37:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e3a:	c7 04 24 48 67 10 00 	movl   $0x106748,(%esp)
  100e41:	e8 55 f5 ff ff       	call   10039b <cprintf>
    pic_enable(IRQ_TIMER);
  100e46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e4d:	e8 89 09 00 00       	call   1017db <pic_enable>
}
  100e52:	90                   	nop
  100e53:	89 ec                	mov    %ebp,%esp
  100e55:	5d                   	pop    %ebp
  100e56:	c3                   	ret    

00100e57 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e57:	55                   	push   %ebp
  100e58:	89 e5                	mov    %esp,%ebp
  100e5a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e5d:	9c                   	pushf  
  100e5e:	58                   	pop    %eax
  100e5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e65:	25 00 02 00 00       	and    $0x200,%eax
  100e6a:	85 c0                	test   %eax,%eax
  100e6c:	74 0c                	je     100e7a <__intr_save+0x23>
        intr_disable();
  100e6e:	e8 03 09 00 00       	call   101776 <intr_disable>
        return 1;
  100e73:	b8 01 00 00 00       	mov    $0x1,%eax
  100e78:	eb 05                	jmp    100e7f <__intr_save+0x28>
    }
    return 0;
  100e7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e7f:	89 ec                	mov    %ebp,%esp
  100e81:	5d                   	pop    %ebp
  100e82:	c3                   	ret    

00100e83 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e83:	55                   	push   %ebp
  100e84:	89 e5                	mov    %esp,%ebp
  100e86:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e8d:	74 05                	je     100e94 <__intr_restore+0x11>
        intr_enable();
  100e8f:	e8 da 08 00 00       	call   10176e <intr_enable>
    }
}
  100e94:	90                   	nop
  100e95:	89 ec                	mov    %ebp,%esp
  100e97:	5d                   	pop    %ebp
  100e98:	c3                   	ret    

00100e99 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e99:	55                   	push   %ebp
  100e9a:	89 e5                	mov    %esp,%ebp
  100e9c:	83 ec 10             	sub    $0x10,%esp
  100e9f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ea5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ea9:	89 c2                	mov    %eax,%edx
  100eab:	ec                   	in     (%dx),%al
  100eac:	88 45 f1             	mov    %al,-0xf(%ebp)
  100eaf:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100eb5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100eb9:	89 c2                	mov    %eax,%edx
  100ebb:	ec                   	in     (%dx),%al
  100ebc:	88 45 f5             	mov    %al,-0xb(%ebp)
  100ebf:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100ec5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100ec9:	89 c2                	mov    %eax,%edx
  100ecb:	ec                   	in     (%dx),%al
  100ecc:	88 45 f9             	mov    %al,-0x7(%ebp)
  100ecf:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100ed5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100ed9:	89 c2                	mov    %eax,%edx
  100edb:	ec                   	in     (%dx),%al
  100edc:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100edf:	90                   	nop
  100ee0:	89 ec                	mov    %ebp,%esp
  100ee2:	5d                   	pop    %ebp
  100ee3:	c3                   	ret    

00100ee4 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ee4:	55                   	push   %ebp
  100ee5:	89 e5                	mov    %esp,%ebp
  100ee7:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100eea:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ef1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ef4:	0f b7 00             	movzwl (%eax),%eax
  100ef7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100efe:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100f03:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f06:	0f b7 00             	movzwl (%eax),%eax
  100f09:	0f b7 c0             	movzwl %ax,%eax
  100f0c:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100f11:	74 12                	je     100f25 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100f13:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100f1a:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100f21:	b4 03 
  100f23:	eb 13                	jmp    100f38 <cga_init+0x54>
    } else {
        *cp = was;
  100f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f28:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100f2c:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100f2f:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100f36:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100f38:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f3f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f43:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f47:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f4b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f4f:	ee                   	out    %al,(%dx)
}
  100f50:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f51:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f58:	40                   	inc    %eax
  100f59:	0f b7 c0             	movzwl %ax,%eax
  100f5c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f60:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f64:	89 c2                	mov    %eax,%edx
  100f66:	ec                   	in     (%dx),%al
  100f67:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f6a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f6e:	0f b6 c0             	movzbl %al,%eax
  100f71:	c1 e0 08             	shl    $0x8,%eax
  100f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f77:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f7e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f82:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f86:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f8a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f8e:	ee                   	out    %al,(%dx)
}
  100f8f:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f90:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f97:	40                   	inc    %eax
  100f98:	0f b7 c0             	movzwl %ax,%eax
  100f9b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f9f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fa3:	89 c2                	mov    %eax,%edx
  100fa5:	ec                   	in     (%dx),%al
  100fa6:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100fa9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100fad:	0f b6 c0             	movzbl %al,%eax
  100fb0:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100fb6:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100fbe:	0f b7 c0             	movzwl %ax,%eax
  100fc1:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100fc7:	90                   	nop
  100fc8:	89 ec                	mov    %ebp,%esp
  100fca:	5d                   	pop    %ebp
  100fcb:	c3                   	ret    

00100fcc <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100fcc:	55                   	push   %ebp
  100fcd:	89 e5                	mov    %esp,%ebp
  100fcf:	83 ec 48             	sub    $0x48,%esp
  100fd2:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100fd8:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fdc:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100fe0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
}
  100fe5:	90                   	nop
  100fe6:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100fec:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ff0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100ff4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100ff8:	ee                   	out    %al,(%dx)
}
  100ff9:	90                   	nop
  100ffa:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  101000:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101004:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101008:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10100c:	ee                   	out    %al,(%dx)
}
  10100d:	90                   	nop
  10100e:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  101014:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101018:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10101c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101020:	ee                   	out    %al,(%dx)
}
  101021:	90                   	nop
  101022:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  101028:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10102c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101030:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101034:	ee                   	out    %al,(%dx)
}
  101035:	90                   	nop
  101036:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  10103c:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101040:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101044:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101048:	ee                   	out    %al,(%dx)
}
  101049:	90                   	nop
  10104a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  101050:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101054:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101058:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10105c:	ee                   	out    %al,(%dx)
}
  10105d:	90                   	nop
  10105e:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101064:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101068:	89 c2                	mov    %eax,%edx
  10106a:	ec                   	in     (%dx),%al
  10106b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  10106e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101072:	3c ff                	cmp    $0xff,%al
  101074:	0f 95 c0             	setne  %al
  101077:	0f b6 c0             	movzbl %al,%eax
  10107a:	a3 48 c4 11 00       	mov    %eax,0x11c448
  10107f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101085:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101089:	89 c2                	mov    %eax,%edx
  10108b:	ec                   	in     (%dx),%al
  10108c:	88 45 f1             	mov    %al,-0xf(%ebp)
  10108f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101095:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101099:	89 c2                	mov    %eax,%edx
  10109b:	ec                   	in     (%dx),%al
  10109c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10109f:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1010a4:	85 c0                	test   %eax,%eax
  1010a6:	74 0c                	je     1010b4 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  1010a8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1010af:	e8 27 07 00 00       	call   1017db <pic_enable>
    }
}
  1010b4:	90                   	nop
  1010b5:	89 ec                	mov    %ebp,%esp
  1010b7:	5d                   	pop    %ebp
  1010b8:	c3                   	ret    

001010b9 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  1010b9:	55                   	push   %ebp
  1010ba:	89 e5                	mov    %esp,%ebp
  1010bc:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1010c6:	eb 08                	jmp    1010d0 <lpt_putc_sub+0x17>
        delay();
  1010c8:	e8 cc fd ff ff       	call   100e99 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010cd:	ff 45 fc             	incl   -0x4(%ebp)
  1010d0:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  1010d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1010da:	89 c2                	mov    %eax,%edx
  1010dc:	ec                   	in     (%dx),%al
  1010dd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1010e0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010e4:	84 c0                	test   %al,%al
  1010e6:	78 09                	js     1010f1 <lpt_putc_sub+0x38>
  1010e8:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010ef:	7e d7                	jle    1010c8 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f4:	0f b6 c0             	movzbl %al,%eax
  1010f7:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010fd:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101100:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101104:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101108:	ee                   	out    %al,(%dx)
}
  101109:	90                   	nop
  10110a:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101110:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101114:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101118:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10111c:	ee                   	out    %al,(%dx)
}
  10111d:	90                   	nop
  10111e:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101124:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101128:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10112c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101130:	ee                   	out    %al,(%dx)
}
  101131:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101132:	90                   	nop
  101133:	89 ec                	mov    %ebp,%esp
  101135:	5d                   	pop    %ebp
  101136:	c3                   	ret    

00101137 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101137:	55                   	push   %ebp
  101138:	89 e5                	mov    %esp,%ebp
  10113a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10113d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101141:	74 0d                	je     101150 <lpt_putc+0x19>
        lpt_putc_sub(c);
  101143:	8b 45 08             	mov    0x8(%ebp),%eax
  101146:	89 04 24             	mov    %eax,(%esp)
  101149:	e8 6b ff ff ff       	call   1010b9 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10114e:	eb 24                	jmp    101174 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  101150:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101157:	e8 5d ff ff ff       	call   1010b9 <lpt_putc_sub>
        lpt_putc_sub(' ');
  10115c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101163:	e8 51 ff ff ff       	call   1010b9 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101168:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10116f:	e8 45 ff ff ff       	call   1010b9 <lpt_putc_sub>
}
  101174:	90                   	nop
  101175:	89 ec                	mov    %ebp,%esp
  101177:	5d                   	pop    %ebp
  101178:	c3                   	ret    

00101179 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101179:	55                   	push   %ebp
  10117a:	89 e5                	mov    %esp,%ebp
  10117c:	83 ec 38             	sub    $0x38,%esp
  10117f:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  101182:	8b 45 08             	mov    0x8(%ebp),%eax
  101185:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10118a:	85 c0                	test   %eax,%eax
  10118c:	75 07                	jne    101195 <cga_putc+0x1c>
        c |= 0x0700;
  10118e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101195:	8b 45 08             	mov    0x8(%ebp),%eax
  101198:	0f b6 c0             	movzbl %al,%eax
  10119b:	83 f8 0d             	cmp    $0xd,%eax
  10119e:	74 72                	je     101212 <cga_putc+0x99>
  1011a0:	83 f8 0d             	cmp    $0xd,%eax
  1011a3:	0f 8f a3 00 00 00    	jg     10124c <cga_putc+0xd3>
  1011a9:	83 f8 08             	cmp    $0x8,%eax
  1011ac:	74 0a                	je     1011b8 <cga_putc+0x3f>
  1011ae:	83 f8 0a             	cmp    $0xa,%eax
  1011b1:	74 4c                	je     1011ff <cga_putc+0x86>
  1011b3:	e9 94 00 00 00       	jmp    10124c <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  1011b8:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011bf:	85 c0                	test   %eax,%eax
  1011c1:	0f 84 af 00 00 00    	je     101276 <cga_putc+0xfd>
            crt_pos --;
  1011c7:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011ce:	48                   	dec    %eax
  1011cf:	0f b7 c0             	movzwl %ax,%eax
  1011d2:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1011db:	98                   	cwtl   
  1011dc:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011e1:	98                   	cwtl   
  1011e2:	83 c8 20             	or     $0x20,%eax
  1011e5:	98                   	cwtl   
  1011e6:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011ec:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  1011f3:	01 d2                	add    %edx,%edx
  1011f5:	01 ca                	add    %ecx,%edx
  1011f7:	0f b7 c0             	movzwl %ax,%eax
  1011fa:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011fd:	eb 77                	jmp    101276 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011ff:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101206:	83 c0 50             	add    $0x50,%eax
  101209:	0f b7 c0             	movzwl %ax,%eax
  10120c:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101212:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  101219:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  101220:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101225:	89 c8                	mov    %ecx,%eax
  101227:	f7 e2                	mul    %edx
  101229:	c1 ea 06             	shr    $0x6,%edx
  10122c:	89 d0                	mov    %edx,%eax
  10122e:	c1 e0 02             	shl    $0x2,%eax
  101231:	01 d0                	add    %edx,%eax
  101233:	c1 e0 04             	shl    $0x4,%eax
  101236:	29 c1                	sub    %eax,%ecx
  101238:	89 ca                	mov    %ecx,%edx
  10123a:	0f b7 d2             	movzwl %dx,%edx
  10123d:	89 d8                	mov    %ebx,%eax
  10123f:	29 d0                	sub    %edx,%eax
  101241:	0f b7 c0             	movzwl %ax,%eax
  101244:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  10124a:	eb 2b                	jmp    101277 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10124c:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  101252:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101259:	8d 50 01             	lea    0x1(%eax),%edx
  10125c:	0f b7 d2             	movzwl %dx,%edx
  10125f:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  101266:	01 c0                	add    %eax,%eax
  101268:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10126b:	8b 45 08             	mov    0x8(%ebp),%eax
  10126e:	0f b7 c0             	movzwl %ax,%eax
  101271:	66 89 02             	mov    %ax,(%edx)
        break;
  101274:	eb 01                	jmp    101277 <cga_putc+0xfe>
        break;
  101276:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101277:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10127e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101283:	76 5e                	jbe    1012e3 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101285:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10128a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101290:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101295:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10129c:	00 
  10129d:	89 54 24 04          	mov    %edx,0x4(%esp)
  1012a1:	89 04 24             	mov    %eax,(%esp)
  1012a4:	e8 25 50 00 00       	call   1062ce <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012a9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1012b0:	eb 15                	jmp    1012c7 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  1012b2:	8b 15 40 c4 11 00    	mov    0x11c440,%edx
  1012b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1012bb:	01 c0                	add    %eax,%eax
  1012bd:	01 d0                	add    %edx,%eax
  1012bf:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012c4:	ff 45 f4             	incl   -0xc(%ebp)
  1012c7:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1012ce:	7e e2                	jle    1012b2 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  1012d0:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012d7:	83 e8 50             	sub    $0x50,%eax
  1012da:	0f b7 c0             	movzwl %ax,%eax
  1012dd:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012e3:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012ea:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012ee:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012f2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012f6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012fa:	ee                   	out    %al,(%dx)
}
  1012fb:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012fc:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101303:	c1 e8 08             	shr    $0x8,%eax
  101306:	0f b7 c0             	movzwl %ax,%eax
  101309:	0f b6 c0             	movzbl %al,%eax
  10130c:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101313:	42                   	inc    %edx
  101314:	0f b7 d2             	movzwl %dx,%edx
  101317:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10131b:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10131e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101322:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101326:	ee                   	out    %al,(%dx)
}
  101327:	90                   	nop
    outb(addr_6845, 15);
  101328:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  10132f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101333:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101337:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10133b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10133f:	ee                   	out    %al,(%dx)
}
  101340:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  101341:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101348:	0f b6 c0             	movzbl %al,%eax
  10134b:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101352:	42                   	inc    %edx
  101353:	0f b7 d2             	movzwl %dx,%edx
  101356:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  10135a:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10135d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101361:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101365:	ee                   	out    %al,(%dx)
}
  101366:	90                   	nop
}
  101367:	90                   	nop
  101368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10136b:	89 ec                	mov    %ebp,%esp
  10136d:	5d                   	pop    %ebp
  10136e:	c3                   	ret    

0010136f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10136f:	55                   	push   %ebp
  101370:	89 e5                	mov    %esp,%ebp
  101372:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101375:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10137c:	eb 08                	jmp    101386 <serial_putc_sub+0x17>
        delay();
  10137e:	e8 16 fb ff ff       	call   100e99 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101383:	ff 45 fc             	incl   -0x4(%ebp)
  101386:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10138c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101390:	89 c2                	mov    %eax,%edx
  101392:	ec                   	in     (%dx),%al
  101393:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101396:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10139a:	0f b6 c0             	movzbl %al,%eax
  10139d:	83 e0 20             	and    $0x20,%eax
  1013a0:	85 c0                	test   %eax,%eax
  1013a2:	75 09                	jne    1013ad <serial_putc_sub+0x3e>
  1013a4:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1013ab:	7e d1                	jle    10137e <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  1013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b0:	0f b6 c0             	movzbl %al,%eax
  1013b3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1013b9:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1013bc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1013c0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1013c4:	ee                   	out    %al,(%dx)
}
  1013c5:	90                   	nop
}
  1013c6:	90                   	nop
  1013c7:	89 ec                	mov    %ebp,%esp
  1013c9:	5d                   	pop    %ebp
  1013ca:	c3                   	ret    

001013cb <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1013cb:	55                   	push   %ebp
  1013cc:	89 e5                	mov    %esp,%ebp
  1013ce:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1013d1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1013d5:	74 0d                	je     1013e4 <serial_putc+0x19>
        serial_putc_sub(c);
  1013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1013da:	89 04 24             	mov    %eax,(%esp)
  1013dd:	e8 8d ff ff ff       	call   10136f <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1013e2:	eb 24                	jmp    101408 <serial_putc+0x3d>
        serial_putc_sub('\b');
  1013e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013eb:	e8 7f ff ff ff       	call   10136f <serial_putc_sub>
        serial_putc_sub(' ');
  1013f0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013f7:	e8 73 ff ff ff       	call   10136f <serial_putc_sub>
        serial_putc_sub('\b');
  1013fc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101403:	e8 67 ff ff ff       	call   10136f <serial_putc_sub>
}
  101408:	90                   	nop
  101409:	89 ec                	mov    %ebp,%esp
  10140b:	5d                   	pop    %ebp
  10140c:	c3                   	ret    

0010140d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10140d:	55                   	push   %ebp
  10140e:	89 e5                	mov    %esp,%ebp
  101410:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101413:	eb 33                	jmp    101448 <cons_intr+0x3b>
        if (c != 0) {
  101415:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101419:	74 2d                	je     101448 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10141b:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101420:	8d 50 01             	lea    0x1(%eax),%edx
  101423:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  101429:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10142c:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101432:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101437:	3d 00 02 00 00       	cmp    $0x200,%eax
  10143c:	75 0a                	jne    101448 <cons_intr+0x3b>
                cons.wpos = 0;
  10143e:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  101445:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101448:	8b 45 08             	mov    0x8(%ebp),%eax
  10144b:	ff d0                	call   *%eax
  10144d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101450:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101454:	75 bf                	jne    101415 <cons_intr+0x8>
            }
        }
    }
}
  101456:	90                   	nop
  101457:	90                   	nop
  101458:	89 ec                	mov    %ebp,%esp
  10145a:	5d                   	pop    %ebp
  10145b:	c3                   	ret    

0010145c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10145c:	55                   	push   %ebp
  10145d:	89 e5                	mov    %esp,%ebp
  10145f:	83 ec 10             	sub    $0x10,%esp
  101462:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101468:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10146c:	89 c2                	mov    %eax,%edx
  10146e:	ec                   	in     (%dx),%al
  10146f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101472:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101476:	0f b6 c0             	movzbl %al,%eax
  101479:	83 e0 01             	and    $0x1,%eax
  10147c:	85 c0                	test   %eax,%eax
  10147e:	75 07                	jne    101487 <serial_proc_data+0x2b>
        return -1;
  101480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101485:	eb 2a                	jmp    1014b1 <serial_proc_data+0x55>
  101487:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10148d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101491:	89 c2                	mov    %eax,%edx
  101493:	ec                   	in     (%dx),%al
  101494:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101497:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10149b:	0f b6 c0             	movzbl %al,%eax
  10149e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1014a1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1014a5:	75 07                	jne    1014ae <serial_proc_data+0x52>
        c = '\b';
  1014a7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1014ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1014b1:	89 ec                	mov    %ebp,%esp
  1014b3:	5d                   	pop    %ebp
  1014b4:	c3                   	ret    

001014b5 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1014b5:	55                   	push   %ebp
  1014b6:	89 e5                	mov    %esp,%ebp
  1014b8:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1014bb:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1014c0:	85 c0                	test   %eax,%eax
  1014c2:	74 0c                	je     1014d0 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1014c4:	c7 04 24 5c 14 10 00 	movl   $0x10145c,(%esp)
  1014cb:	e8 3d ff ff ff       	call   10140d <cons_intr>
    }
}
  1014d0:	90                   	nop
  1014d1:	89 ec                	mov    %ebp,%esp
  1014d3:	5d                   	pop    %ebp
  1014d4:	c3                   	ret    

001014d5 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1014d5:	55                   	push   %ebp
  1014d6:	89 e5                	mov    %esp,%ebp
  1014d8:	83 ec 38             	sub    $0x38,%esp
  1014db:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014e4:	89 c2                	mov    %eax,%edx
  1014e6:	ec                   	in     (%dx),%al
  1014e7:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014ee:	0f b6 c0             	movzbl %al,%eax
  1014f1:	83 e0 01             	and    $0x1,%eax
  1014f4:	85 c0                	test   %eax,%eax
  1014f6:	75 0a                	jne    101502 <kbd_proc_data+0x2d>
        return -1;
  1014f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014fd:	e9 56 01 00 00       	jmp    101658 <kbd_proc_data+0x183>
  101502:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101508:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10150b:	89 c2                	mov    %eax,%edx
  10150d:	ec                   	in     (%dx),%al
  10150e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101511:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101515:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101518:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10151c:	75 17                	jne    101535 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10151e:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101523:	83 c8 40             	or     $0x40,%eax
  101526:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  10152b:	b8 00 00 00 00       	mov    $0x0,%eax
  101530:	e9 23 01 00 00       	jmp    101658 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101539:	84 c0                	test   %al,%al
  10153b:	79 45                	jns    101582 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10153d:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101542:	83 e0 40             	and    $0x40,%eax
  101545:	85 c0                	test   %eax,%eax
  101547:	75 08                	jne    101551 <kbd_proc_data+0x7c>
  101549:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10154d:	24 7f                	and    $0x7f,%al
  10154f:	eb 04                	jmp    101555 <kbd_proc_data+0x80>
  101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101555:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101558:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10155c:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101563:	0c 40                	or     $0x40,%al
  101565:	0f b6 c0             	movzbl %al,%eax
  101568:	f7 d0                	not    %eax
  10156a:	89 c2                	mov    %eax,%edx
  10156c:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101571:	21 d0                	and    %edx,%eax
  101573:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  101578:	b8 00 00 00 00       	mov    $0x0,%eax
  10157d:	e9 d6 00 00 00       	jmp    101658 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101582:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101587:	83 e0 40             	and    $0x40,%eax
  10158a:	85 c0                	test   %eax,%eax
  10158c:	74 11                	je     10159f <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10158e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101592:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101597:	83 e0 bf             	and    $0xffffffbf,%eax
  10159a:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  10159f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a3:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  1015aa:	0f b6 d0             	movzbl %al,%edx
  1015ad:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015b2:	09 d0                	or     %edx,%eax
  1015b4:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  1015b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015bd:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  1015c4:	0f b6 d0             	movzbl %al,%edx
  1015c7:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015cc:	31 d0                	xor    %edx,%eax
  1015ce:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  1015d3:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015d8:	83 e0 03             	and    $0x3,%eax
  1015db:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  1015e2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015e6:	01 d0                	add    %edx,%eax
  1015e8:	0f b6 00             	movzbl (%eax),%eax
  1015eb:	0f b6 c0             	movzbl %al,%eax
  1015ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015f1:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015f6:	83 e0 08             	and    $0x8,%eax
  1015f9:	85 c0                	test   %eax,%eax
  1015fb:	74 22                	je     10161f <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015fd:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101601:	7e 0c                	jle    10160f <kbd_proc_data+0x13a>
  101603:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101607:	7f 06                	jg     10160f <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101609:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10160d:	eb 10                	jmp    10161f <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10160f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101613:	7e 0a                	jle    10161f <kbd_proc_data+0x14a>
  101615:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101619:	7f 04                	jg     10161f <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10161b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10161f:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101624:	f7 d0                	not    %eax
  101626:	83 e0 06             	and    $0x6,%eax
  101629:	85 c0                	test   %eax,%eax
  10162b:	75 28                	jne    101655 <kbd_proc_data+0x180>
  10162d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101634:	75 1f                	jne    101655 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101636:	c7 04 24 63 67 10 00 	movl   $0x106763,(%esp)
  10163d:	e8 59 ed ff ff       	call   10039b <cprintf>
  101642:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101648:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10164c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101650:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101653:	ee                   	out    %al,(%dx)
}
  101654:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101655:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101658:	89 ec                	mov    %ebp,%esp
  10165a:	5d                   	pop    %ebp
  10165b:	c3                   	ret    

0010165c <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10165c:	55                   	push   %ebp
  10165d:	89 e5                	mov    %esp,%ebp
  10165f:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101662:	c7 04 24 d5 14 10 00 	movl   $0x1014d5,(%esp)
  101669:	e8 9f fd ff ff       	call   10140d <cons_intr>
}
  10166e:	90                   	nop
  10166f:	89 ec                	mov    %ebp,%esp
  101671:	5d                   	pop    %ebp
  101672:	c3                   	ret    

00101673 <kbd_init>:

static void
kbd_init(void) {
  101673:	55                   	push   %ebp
  101674:	89 e5                	mov    %esp,%ebp
  101676:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101679:	e8 de ff ff ff       	call   10165c <kbd_intr>
    pic_enable(IRQ_KBD);
  10167e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101685:	e8 51 01 00 00       	call   1017db <pic_enable>
}
  10168a:	90                   	nop
  10168b:	89 ec                	mov    %ebp,%esp
  10168d:	5d                   	pop    %ebp
  10168e:	c3                   	ret    

0010168f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10168f:	55                   	push   %ebp
  101690:	89 e5                	mov    %esp,%ebp
  101692:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101695:	e8 4a f8 ff ff       	call   100ee4 <cga_init>
    serial_init();
  10169a:	e8 2d f9 ff ff       	call   100fcc <serial_init>
    kbd_init();
  10169f:	e8 cf ff ff ff       	call   101673 <kbd_init>
    if (!serial_exists) {
  1016a4:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1016a9:	85 c0                	test   %eax,%eax
  1016ab:	75 0c                	jne    1016b9 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1016ad:	c7 04 24 6f 67 10 00 	movl   $0x10676f,(%esp)
  1016b4:	e8 e2 ec ff ff       	call   10039b <cprintf>
    }
}
  1016b9:	90                   	nop
  1016ba:	89 ec                	mov    %ebp,%esp
  1016bc:	5d                   	pop    %ebp
  1016bd:	c3                   	ret    

001016be <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1016be:	55                   	push   %ebp
  1016bf:	89 e5                	mov    %esp,%ebp
  1016c1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  1016c4:	e8 8e f7 ff ff       	call   100e57 <__intr_save>
  1016c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  1016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1016cf:	89 04 24             	mov    %eax,(%esp)
  1016d2:	e8 60 fa ff ff       	call   101137 <lpt_putc>
        cga_putc(c);
  1016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1016da:	89 04 24             	mov    %eax,(%esp)
  1016dd:	e8 97 fa ff ff       	call   101179 <cga_putc>
        serial_putc(c);
  1016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1016e5:	89 04 24             	mov    %eax,(%esp)
  1016e8:	e8 de fc ff ff       	call   1013cb <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016f0:	89 04 24             	mov    %eax,(%esp)
  1016f3:	e8 8b f7 ff ff       	call   100e83 <__intr_restore>
}
  1016f8:	90                   	nop
  1016f9:	89 ec                	mov    %ebp,%esp
  1016fb:	5d                   	pop    %ebp
  1016fc:	c3                   	ret    

001016fd <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016fd:	55                   	push   %ebp
  1016fe:	89 e5                	mov    %esp,%ebp
  101700:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10170a:	e8 48 f7 ff ff       	call   100e57 <__intr_save>
  10170f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101712:	e8 9e fd ff ff       	call   1014b5 <serial_intr>
        kbd_intr();
  101717:	e8 40 ff ff ff       	call   10165c <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10171c:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  101722:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101727:	39 c2                	cmp    %eax,%edx
  101729:	74 31                	je     10175c <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10172b:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101730:	8d 50 01             	lea    0x1(%eax),%edx
  101733:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  101739:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  101740:	0f b6 c0             	movzbl %al,%eax
  101743:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101746:	a1 60 c6 11 00       	mov    0x11c660,%eax
  10174b:	3d 00 02 00 00       	cmp    $0x200,%eax
  101750:	75 0a                	jne    10175c <cons_getc+0x5f>
                cons.rpos = 0;
  101752:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  101759:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10175f:	89 04 24             	mov    %eax,(%esp)
  101762:	e8 1c f7 ff ff       	call   100e83 <__intr_restore>
    return c;
  101767:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10176a:	89 ec                	mov    %ebp,%esp
  10176c:	5d                   	pop    %ebp
  10176d:	c3                   	ret    

0010176e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10176e:	55                   	push   %ebp
  10176f:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101771:	fb                   	sti    
}
  101772:	90                   	nop
    sti();
}
  101773:	90                   	nop
  101774:	5d                   	pop    %ebp
  101775:	c3                   	ret    

00101776 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101776:	55                   	push   %ebp
  101777:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101779:	fa                   	cli    
}
  10177a:	90                   	nop
    cli();
}
  10177b:	90                   	nop
  10177c:	5d                   	pop    %ebp
  10177d:	c3                   	ret    

0010177e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10177e:	55                   	push   %ebp
  10177f:	89 e5                	mov    %esp,%ebp
  101781:	83 ec 14             	sub    $0x14,%esp
  101784:	8b 45 08             	mov    0x8(%ebp),%eax
  101787:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10178b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10178e:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  101794:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  101799:	85 c0                	test   %eax,%eax
  10179b:	74 39                	je     1017d6 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  10179d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1017a0:	0f b6 c0             	movzbl %al,%eax
  1017a3:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1017a9:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017ac:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017b0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017b4:	ee                   	out    %al,(%dx)
}
  1017b5:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  1017b6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1017ba:	c1 e8 08             	shr    $0x8,%eax
  1017bd:	0f b7 c0             	movzwl %ax,%eax
  1017c0:	0f b6 c0             	movzbl %al,%eax
  1017c3:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  1017c9:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017cc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017d0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017d4:	ee                   	out    %al,(%dx)
}
  1017d5:	90                   	nop
    }
}
  1017d6:	90                   	nop
  1017d7:	89 ec                	mov    %ebp,%esp
  1017d9:	5d                   	pop    %ebp
  1017da:	c3                   	ret    

001017db <pic_enable>:

void
pic_enable(unsigned int irq) {
  1017db:	55                   	push   %ebp
  1017dc:	89 e5                	mov    %esp,%ebp
  1017de:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1017e4:	ba 01 00 00 00       	mov    $0x1,%edx
  1017e9:	88 c1                	mov    %al,%cl
  1017eb:	d3 e2                	shl    %cl,%edx
  1017ed:	89 d0                	mov    %edx,%eax
  1017ef:	98                   	cwtl   
  1017f0:	f7 d0                	not    %eax
  1017f2:	0f bf d0             	movswl %ax,%edx
  1017f5:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1017fc:	98                   	cwtl   
  1017fd:	21 d0                	and    %edx,%eax
  1017ff:	98                   	cwtl   
  101800:	0f b7 c0             	movzwl %ax,%eax
  101803:	89 04 24             	mov    %eax,(%esp)
  101806:	e8 73 ff ff ff       	call   10177e <pic_setmask>
}
  10180b:	90                   	nop
  10180c:	89 ec                	mov    %ebp,%esp
  10180e:	5d                   	pop    %ebp
  10180f:	c3                   	ret    

00101810 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101810:	55                   	push   %ebp
  101811:	89 e5                	mov    %esp,%ebp
  101813:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101816:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  10181d:	00 00 00 
  101820:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101826:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10182a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10182e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101832:	ee                   	out    %al,(%dx)
}
  101833:	90                   	nop
  101834:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  10183a:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10183e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101842:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101846:	ee                   	out    %al,(%dx)
}
  101847:	90                   	nop
  101848:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10184e:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101852:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101856:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10185a:	ee                   	out    %al,(%dx)
}
  10185b:	90                   	nop
  10185c:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101862:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101866:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10186a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10186e:	ee                   	out    %al,(%dx)
}
  10186f:	90                   	nop
  101870:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101876:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10187a:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10187e:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101882:	ee                   	out    %al,(%dx)
}
  101883:	90                   	nop
  101884:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  10188a:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10188e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101892:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101896:	ee                   	out    %al,(%dx)
}
  101897:	90                   	nop
  101898:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  10189e:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018a2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1018a6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1018aa:	ee                   	out    %al,(%dx)
}
  1018ab:	90                   	nop
  1018ac:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1018b2:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018b6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1018ba:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1018be:	ee                   	out    %al,(%dx)
}
  1018bf:	90                   	nop
  1018c0:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1018c6:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ca:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1018ce:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1018d2:	ee                   	out    %al,(%dx)
}
  1018d3:	90                   	nop
  1018d4:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1018da:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018de:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1018e2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1018e6:	ee                   	out    %al,(%dx)
}
  1018e7:	90                   	nop
  1018e8:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018ee:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018f2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018f6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018fa:	ee                   	out    %al,(%dx)
}
  1018fb:	90                   	nop
  1018fc:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101902:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101906:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10190a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10190e:	ee                   	out    %al,(%dx)
}
  10190f:	90                   	nop
  101910:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101916:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10191a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10191e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101922:	ee                   	out    %al,(%dx)
}
  101923:	90                   	nop
  101924:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10192a:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10192e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101932:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101936:	ee                   	out    %al,(%dx)
}
  101937:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101938:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10193f:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101944:	74 0f                	je     101955 <pic_init+0x145>
        pic_setmask(irq_mask);
  101946:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10194d:	89 04 24             	mov    %eax,(%esp)
  101950:	e8 29 fe ff ff       	call   10177e <pic_setmask>
    }
}
  101955:	90                   	nop
  101956:	89 ec                	mov    %ebp,%esp
  101958:	5d                   	pop    %ebp
  101959:	c3                   	ret    

0010195a <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10195a:	55                   	push   %ebp
  10195b:	89 e5                	mov    %esp,%ebp
  10195d:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101960:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101967:	00 
  101968:	c7 04 24 a0 67 10 00 	movl   $0x1067a0,(%esp)
  10196f:	e8 27 ea ff ff       	call   10039b <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101974:	c7 04 24 aa 67 10 00 	movl   $0x1067aa,(%esp)
  10197b:	e8 1b ea ff ff       	call   10039b <cprintf>
    panic("EOT: kernel seems ok.");
  101980:	c7 44 24 08 b8 67 10 	movl   $0x1067b8,0x8(%esp)
  101987:	00 
  101988:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  10198f:	00 
  101990:	c7 04 24 ce 67 10 00 	movl   $0x1067ce,(%esp)
  101997:	e8 81 f3 ff ff       	call   100d1d <__panic>

0010199c <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10199c:	55                   	push   %ebp
  10199d:	89 e5                	mov    %esp,%ebp
  10199f:	83 ec 10             	sub    $0x10,%esp
      */
      extern uintptr_t __vectors[];

    //all gate DPL=0, so use DPL_KERNEL 
    int i;
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
  1019a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1019a9:	e9 c4 00 00 00       	jmp    101a72 <idt_init+0xd6>
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  1019ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b1:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  1019b8:	0f b7 d0             	movzwl %ax,%edx
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	66 89 14 c5 e0 c6 11 	mov    %dx,0x11c6e0(,%eax,8)
  1019c5:	00 
  1019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c9:	66 c7 04 c5 e2 c6 11 	movw   $0x8,0x11c6e2(,%eax,8)
  1019d0:	00 08 00 
  1019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d6:	0f b6 14 c5 e4 c6 11 	movzbl 0x11c6e4(,%eax,8),%edx
  1019dd:	00 
  1019de:	80 e2 e0             	and    $0xe0,%dl
  1019e1:	88 14 c5 e4 c6 11 00 	mov    %dl,0x11c6e4(,%eax,8)
  1019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019eb:	0f b6 14 c5 e4 c6 11 	movzbl 0x11c6e4(,%eax,8),%edx
  1019f2:	00 
  1019f3:	80 e2 1f             	and    $0x1f,%dl
  1019f6:	88 14 c5 e4 c6 11 00 	mov    %dl,0x11c6e4(,%eax,8)
  1019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a00:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  101a07:	00 
  101a08:	80 e2 f0             	and    $0xf0,%dl
  101a0b:	80 ca 0e             	or     $0xe,%dl
  101a0e:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a18:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  101a1f:	00 
  101a20:	80 e2 ef             	and    $0xef,%dl
  101a23:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a2d:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  101a34:	00 
  101a35:	80 e2 9f             	and    $0x9f,%dl
  101a38:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a42:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  101a49:	00 
  101a4a:	80 ca 80             	or     $0x80,%dl
  101a4d:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a57:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101a5e:	c1 e8 10             	shr    $0x10,%eax
  101a61:	0f b7 d0             	movzwl %ax,%edx
  101a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a67:	66 89 14 c5 e6 c6 11 	mov    %dx,0x11c6e6(,%eax,8)
  101a6e:	00 
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
  101a6f:	ff 45 fc             	incl   -0x4(%ebp)
  101a72:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a75:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a7a:	0f 86 2e ff ff ff    	jbe    1019ae <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL],1,KERNEL_CS,__vectors[T_SYSCALL],DPL_USER);
  101a80:	a1 e0 97 11 00       	mov    0x1197e0,%eax
  101a85:	0f b7 c0             	movzwl %ax,%eax
  101a88:	66 a3 e0 ca 11 00    	mov    %ax,0x11cae0
  101a8e:	66 c7 05 e2 ca 11 00 	movw   $0x8,0x11cae2
  101a95:	08 00 
  101a97:	0f b6 05 e4 ca 11 00 	movzbl 0x11cae4,%eax
  101a9e:	24 e0                	and    $0xe0,%al
  101aa0:	a2 e4 ca 11 00       	mov    %al,0x11cae4
  101aa5:	0f b6 05 e4 ca 11 00 	movzbl 0x11cae4,%eax
  101aac:	24 1f                	and    $0x1f,%al
  101aae:	a2 e4 ca 11 00       	mov    %al,0x11cae4
  101ab3:	0f b6 05 e5 ca 11 00 	movzbl 0x11cae5,%eax
  101aba:	0c 0f                	or     $0xf,%al
  101abc:	a2 e5 ca 11 00       	mov    %al,0x11cae5
  101ac1:	0f b6 05 e5 ca 11 00 	movzbl 0x11cae5,%eax
  101ac8:	24 ef                	and    $0xef,%al
  101aca:	a2 e5 ca 11 00       	mov    %al,0x11cae5
  101acf:	0f b6 05 e5 ca 11 00 	movzbl 0x11cae5,%eax
  101ad6:	0c 60                	or     $0x60,%al
  101ad8:	a2 e5 ca 11 00       	mov    %al,0x11cae5
  101add:	0f b6 05 e5 ca 11 00 	movzbl 0x11cae5,%eax
  101ae4:	0c 80                	or     $0x80,%al
  101ae6:	a2 e5 ca 11 00       	mov    %al,0x11cae5
  101aeb:	a1 e0 97 11 00       	mov    0x1197e0,%eax
  101af0:	c1 e8 10             	shr    $0x10,%eax
  101af3:	0f b7 c0             	movzwl %ax,%eax
  101af6:	66 a3 e6 ca 11 00    	mov    %ax,0x11cae6
    SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
  101afc:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101b01:	0f b7 c0             	movzwl %ax,%eax
  101b04:	66 a3 a8 ca 11 00    	mov    %ax,0x11caa8
  101b0a:	66 c7 05 aa ca 11 00 	movw   $0x8,0x11caaa
  101b11:	08 00 
  101b13:	0f b6 05 ac ca 11 00 	movzbl 0x11caac,%eax
  101b1a:	24 e0                	and    $0xe0,%al
  101b1c:	a2 ac ca 11 00       	mov    %al,0x11caac
  101b21:	0f b6 05 ac ca 11 00 	movzbl 0x11caac,%eax
  101b28:	24 1f                	and    $0x1f,%al
  101b2a:	a2 ac ca 11 00       	mov    %al,0x11caac
  101b2f:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101b36:	24 f0                	and    $0xf0,%al
  101b38:	0c 0e                	or     $0xe,%al
  101b3a:	a2 ad ca 11 00       	mov    %al,0x11caad
  101b3f:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101b46:	24 ef                	and    $0xef,%al
  101b48:	a2 ad ca 11 00       	mov    %al,0x11caad
  101b4d:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101b54:	0c 60                	or     $0x60,%al
  101b56:	a2 ad ca 11 00       	mov    %al,0x11caad
  101b5b:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101b62:	0c 80                	or     $0x80,%al
  101b64:	a2 ad ca 11 00       	mov    %al,0x11caad
  101b69:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101b6e:	c1 e8 10             	shr    $0x10,%eax
  101b71:	0f b7 c0             	movzwl %ax,%eax
  101b74:	66 a3 ae ca 11 00    	mov    %ax,0x11caae
  101b7a:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101b81:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b84:	0f 01 18             	lidtl  (%eax)
}
  101b87:	90                   	nop
    
    //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
  101b88:	90                   	nop
  101b89:	89 ec                	mov    %ebp,%esp
  101b8b:	5d                   	pop    %ebp
  101b8c:	c3                   	ret    

00101b8d <trapname>:

static const char *
trapname(int trapno) {
  101b8d:	55                   	push   %ebp
  101b8e:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101b90:	8b 45 08             	mov    0x8(%ebp),%eax
  101b93:	83 f8 13             	cmp    $0x13,%eax
  101b96:	77 0c                	ja     101ba4 <trapname+0x17>
        return excnames[trapno];
  101b98:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9b:	8b 04 85 20 6b 10 00 	mov    0x106b20(,%eax,4),%eax
  101ba2:	eb 18                	jmp    101bbc <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ba4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101ba8:	7e 0d                	jle    101bb7 <trapname+0x2a>
  101baa:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101bae:	7f 07                	jg     101bb7 <trapname+0x2a>
        return "Hardware Interrupt";
  101bb0:	b8 df 67 10 00       	mov    $0x1067df,%eax
  101bb5:	eb 05                	jmp    101bbc <trapname+0x2f>
    }
    return "(unknown trap)";
  101bb7:	b8 f2 67 10 00       	mov    $0x1067f2,%eax
}
  101bbc:	5d                   	pop    %ebp
  101bbd:	c3                   	ret    

00101bbe <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101bbe:	55                   	push   %ebp
  101bbf:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bc8:	83 f8 08             	cmp    $0x8,%eax
  101bcb:	0f 94 c0             	sete   %al
  101bce:	0f b6 c0             	movzbl %al,%eax
}
  101bd1:	5d                   	pop    %ebp
  101bd2:	c3                   	ret    

00101bd3 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101bd3:	55                   	push   %ebp
  101bd4:	89 e5                	mov    %esp,%ebp
  101bd6:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be0:	c7 04 24 33 68 10 00 	movl   $0x106833,(%esp)
  101be7:	e8 af e7 ff ff       	call   10039b <cprintf>
    print_regs(&tf->tf_regs);
  101bec:	8b 45 08             	mov    0x8(%ebp),%eax
  101bef:	89 04 24             	mov    %eax,(%esp)
  101bf2:	e8 8f 01 00 00       	call   101d86 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfa:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c02:	c7 04 24 44 68 10 00 	movl   $0x106844,(%esp)
  101c09:	e8 8d e7 ff ff       	call   10039b <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c11:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c19:	c7 04 24 57 68 10 00 	movl   $0x106857,(%esp)
  101c20:	e8 76 e7 ff ff       	call   10039b <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 6a 68 10 00 	movl   $0x10686a,(%esp)
  101c37:	e8 5f e7 ff ff       	call   10039b <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3f:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c47:	c7 04 24 7d 68 10 00 	movl   $0x10687d,(%esp)
  101c4e:	e8 48 e7 ff ff       	call   10039b <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101c53:	8b 45 08             	mov    0x8(%ebp),%eax
  101c56:	8b 40 30             	mov    0x30(%eax),%eax
  101c59:	89 04 24             	mov    %eax,(%esp)
  101c5c:	e8 2c ff ff ff       	call   101b8d <trapname>
  101c61:	8b 55 08             	mov    0x8(%ebp),%edx
  101c64:	8b 52 30             	mov    0x30(%edx),%edx
  101c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  101c6b:	89 54 24 04          	mov    %edx,0x4(%esp)
  101c6f:	c7 04 24 90 68 10 00 	movl   $0x106890,(%esp)
  101c76:	e8 20 e7 ff ff       	call   10039b <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7e:	8b 40 34             	mov    0x34(%eax),%eax
  101c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c85:	c7 04 24 a2 68 10 00 	movl   $0x1068a2,(%esp)
  101c8c:	e8 0a e7 ff ff       	call   10039b <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101c91:	8b 45 08             	mov    0x8(%ebp),%eax
  101c94:	8b 40 38             	mov    0x38(%eax),%eax
  101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9b:	c7 04 24 b1 68 10 00 	movl   $0x1068b1,(%esp)
  101ca2:	e8 f4 e6 ff ff       	call   10039b <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  101caa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb2:	c7 04 24 c0 68 10 00 	movl   $0x1068c0,(%esp)
  101cb9:	e8 dd e6 ff ff       	call   10039b <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc1:	8b 40 40             	mov    0x40(%eax),%eax
  101cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc8:	c7 04 24 d3 68 10 00 	movl   $0x1068d3,(%esp)
  101ccf:	e8 c7 e6 ff ff       	call   10039b <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101cd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101cdb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ce2:	eb 3d                	jmp    101d21 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce7:	8b 50 40             	mov    0x40(%eax),%edx
  101cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ced:	21 d0                	and    %edx,%eax
  101cef:	85 c0                	test   %eax,%eax
  101cf1:	74 28                	je     101d1b <print_trapframe+0x148>
  101cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cf6:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101cfd:	85 c0                	test   %eax,%eax
  101cff:	74 1a                	je     101d1b <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101d04:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0f:	c7 04 24 e2 68 10 00 	movl   $0x1068e2,(%esp)
  101d16:	e8 80 e6 ff ff       	call   10039b <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101d1b:	ff 45 f4             	incl   -0xc(%ebp)
  101d1e:	d1 65 f0             	shll   -0x10(%ebp)
  101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101d24:	83 f8 17             	cmp    $0x17,%eax
  101d27:	76 bb                	jbe    101ce4 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101d29:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2c:	8b 40 40             	mov    0x40(%eax),%eax
  101d2f:	c1 e8 0c             	shr    $0xc,%eax
  101d32:	83 e0 03             	and    $0x3,%eax
  101d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d39:	c7 04 24 e6 68 10 00 	movl   $0x1068e6,(%esp)
  101d40:	e8 56 e6 ff ff       	call   10039b <cprintf>

    if (!trap_in_kernel(tf)) {
  101d45:	8b 45 08             	mov    0x8(%ebp),%eax
  101d48:	89 04 24             	mov    %eax,(%esp)
  101d4b:	e8 6e fe ff ff       	call   101bbe <trap_in_kernel>
  101d50:	85 c0                	test   %eax,%eax
  101d52:	75 2d                	jne    101d81 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101d54:	8b 45 08             	mov    0x8(%ebp),%eax
  101d57:	8b 40 44             	mov    0x44(%eax),%eax
  101d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d5e:	c7 04 24 ef 68 10 00 	movl   $0x1068ef,(%esp)
  101d65:	e8 31 e6 ff ff       	call   10039b <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d75:	c7 04 24 fe 68 10 00 	movl   $0x1068fe,(%esp)
  101d7c:	e8 1a e6 ff ff       	call   10039b <cprintf>
    }
}
  101d81:	90                   	nop
  101d82:	89 ec                	mov    %ebp,%esp
  101d84:	5d                   	pop    %ebp
  101d85:	c3                   	ret    

00101d86 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101d86:	55                   	push   %ebp
  101d87:	89 e5                	mov    %esp,%ebp
  101d89:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8f:	8b 00                	mov    (%eax),%eax
  101d91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d95:	c7 04 24 11 69 10 00 	movl   $0x106911,(%esp)
  101d9c:	e8 fa e5 ff ff       	call   10039b <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101da1:	8b 45 08             	mov    0x8(%ebp),%eax
  101da4:	8b 40 04             	mov    0x4(%eax),%eax
  101da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dab:	c7 04 24 20 69 10 00 	movl   $0x106920,(%esp)
  101db2:	e8 e4 e5 ff ff       	call   10039b <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101db7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dba:	8b 40 08             	mov    0x8(%eax),%eax
  101dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dc1:	c7 04 24 2f 69 10 00 	movl   $0x10692f,(%esp)
  101dc8:	e8 ce e5 ff ff       	call   10039b <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd0:	8b 40 0c             	mov    0xc(%eax),%eax
  101dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dd7:	c7 04 24 3e 69 10 00 	movl   $0x10693e,(%esp)
  101dde:	e8 b8 e5 ff ff       	call   10039b <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101de3:	8b 45 08             	mov    0x8(%ebp),%eax
  101de6:	8b 40 10             	mov    0x10(%eax),%eax
  101de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ded:	c7 04 24 4d 69 10 00 	movl   $0x10694d,(%esp)
  101df4:	e8 a2 e5 ff ff       	call   10039b <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101df9:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfc:	8b 40 14             	mov    0x14(%eax),%eax
  101dff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e03:	c7 04 24 5c 69 10 00 	movl   $0x10695c,(%esp)
  101e0a:	e8 8c e5 ff ff       	call   10039b <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e12:	8b 40 18             	mov    0x18(%eax),%eax
  101e15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e19:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  101e20:	e8 76 e5 ff ff       	call   10039b <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101e25:	8b 45 08             	mov    0x8(%ebp),%eax
  101e28:	8b 40 1c             	mov    0x1c(%eax),%eax
  101e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e2f:	c7 04 24 7a 69 10 00 	movl   $0x10697a,(%esp)
  101e36:	e8 60 e5 ff ff       	call   10039b <cprintf>
}
  101e3b:	90                   	nop
  101e3c:	89 ec                	mov    %ebp,%esp
  101e3e:	5d                   	pop    %ebp
  101e3f:	c3                   	ret    

00101e40 <trap_dispatch>:



/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101e40:	55                   	push   %ebp
  101e41:	89 e5                	mov    %esp,%ebp
  101e43:	83 ec 38             	sub    $0x38,%esp
  101e46:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
  101e49:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4c:	8b 40 30             	mov    0x30(%eax),%eax
  101e4f:	83 f8 79             	cmp    $0x79,%eax
  101e52:	0f 84 ca 02 00 00    	je     102122 <trap_dispatch+0x2e2>
  101e58:	83 f8 79             	cmp    $0x79,%eax
  101e5b:	0f 87 41 03 00 00    	ja     1021a2 <trap_dispatch+0x362>
  101e61:	83 f8 78             	cmp    $0x78,%eax
  101e64:	0f 84 2b 02 00 00    	je     102095 <trap_dispatch+0x255>
  101e6a:	83 f8 78             	cmp    $0x78,%eax
  101e6d:	0f 87 2f 03 00 00    	ja     1021a2 <trap_dispatch+0x362>
  101e73:	83 f8 2f             	cmp    $0x2f,%eax
  101e76:	0f 87 26 03 00 00    	ja     1021a2 <trap_dispatch+0x362>
  101e7c:	83 f8 2e             	cmp    $0x2e,%eax
  101e7f:	0f 83 52 03 00 00    	jae    1021d7 <trap_dispatch+0x397>
  101e85:	83 f8 24             	cmp    $0x24,%eax
  101e88:	74 5e                	je     101ee8 <trap_dispatch+0xa8>
  101e8a:	83 f8 24             	cmp    $0x24,%eax
  101e8d:	0f 87 0f 03 00 00    	ja     1021a2 <trap_dispatch+0x362>
  101e93:	83 f8 20             	cmp    $0x20,%eax
  101e96:	74 0a                	je     101ea2 <trap_dispatch+0x62>
  101e98:	83 f8 21             	cmp    $0x21,%eax
  101e9b:	74 74                	je     101f11 <trap_dispatch+0xd1>
  101e9d:	e9 00 03 00 00       	jmp    1021a2 <trap_dispatch+0x362>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
  101ea2:	a1 24 c4 11 00       	mov    0x11c424,%eax
  101ea7:	40                   	inc    %eax
  101ea8:	a3 24 c4 11 00       	mov    %eax,0x11c424
        if(ticks%100==0){
  101ead:	8b 0d 24 c4 11 00    	mov    0x11c424,%ecx
  101eb3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101eb8:	89 c8                	mov    %ecx,%eax
  101eba:	f7 e2                	mul    %edx
  101ebc:	c1 ea 05             	shr    $0x5,%edx
  101ebf:	89 d0                	mov    %edx,%eax
  101ec1:	c1 e0 02             	shl    $0x2,%eax
  101ec4:	01 d0                	add    %edx,%eax
  101ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101ecd:	01 d0                	add    %edx,%eax
  101ecf:	c1 e0 02             	shl    $0x2,%eax
  101ed2:	29 c1                	sub    %eax,%ecx
  101ed4:	89 ca                	mov    %ecx,%edx
  101ed6:	85 d2                	test   %edx,%edx
  101ed8:	0f 85 fc 02 00 00    	jne    1021da <trap_dispatch+0x39a>
            print_ticks();
  101ede:	e8 77 fa ff ff       	call   10195a <print_ticks>
        }
        break;
  101ee3:	e9 f2 02 00 00       	jmp    1021da <trap_dispatch+0x39a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101ee8:	e8 10 f8 ff ff       	call   1016fd <cons_getc>
  101eed:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ef0:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ef4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ef8:	89 54 24 08          	mov    %edx,0x8(%esp)
  101efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f00:	c7 04 24 89 69 10 00 	movl   $0x106989,(%esp)
  101f07:	e8 8f e4 ff ff       	call   10039b <cprintf>
        break;
  101f0c:	e9 cd 02 00 00       	jmp    1021de <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101f11:	e8 e7 f7 ff ff       	call   1016fd <cons_getc>
  101f16:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101f19:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101f1d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101f21:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f29:	c7 04 24 9b 69 10 00 	movl   $0x10699b,(%esp)
  101f30:	e8 66 e4 ff ff       	call   10039b <cprintf>
        if (c == '0'&&!trap_in_kernel(tf)) {
  101f35:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101f39:	0f 85 a1 00 00 00    	jne    101fe0 <trap_dispatch+0x1a0>
  101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f42:	89 04 24             	mov    %eax,(%esp)
  101f45:	e8 74 fc ff ff       	call   101bbe <trap_in_kernel>
  101f4a:	85 c0                	test   %eax,%eax
  101f4c:	0f 85 8e 00 00 00    	jne    101fe0 <trap_dispatch+0x1a0>
  101f52:	8b 45 08             	mov    0x8(%ebp),%eax
  101f55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
  101f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f5f:	83 f8 08             	cmp    $0x8,%eax
  101f62:	74 6b                	je     101fcf <trap_dispatch+0x18f>
        tf->tf_cs = KERNEL_CS;
  101f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f67:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  101f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f70:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f79:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f80:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  101f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f87:	8b 40 40             	mov    0x40(%eax),%eax
  101f8a:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101f8f:	89 c2                	mov    %eax,%edx
  101f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f94:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f9a:	8b 40 44             	mov    0x44(%eax),%eax
  101f9d:	83 e8 44             	sub    $0x44,%eax
  101fa0:	a3 cc c6 11 00       	mov    %eax,0x11c6cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101fa5:	a1 cc c6 11 00       	mov    0x11c6cc,%eax
  101faa:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101fb1:	00 
  101fb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101fb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  101fb9:	89 04 24             	mov    %eax,(%esp)
  101fbc:	e8 0d 43 00 00       	call   1062ce <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101fc1:	8b 15 cc c6 11 00    	mov    0x11c6cc,%edx
  101fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101fca:	83 e8 04             	sub    $0x4,%eax
  101fcd:	89 10                	mov    %edx,(%eax)
}
  101fcf:	90                   	nop
        //切换为内核态
        switch_to_kernel(tf);
        print_trapframe(tf);
  101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  101fd3:	89 04 24             	mov    %eax,(%esp)
  101fd6:	e8 f8 fb ff ff       	call   101bd3 <print_trapframe>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
        //切换为用户态
        switch_to_user(tf);
        print_trapframe(tf);
        }
        break;
  101fdb:	e9 fd 01 00 00       	jmp    1021dd <trap_dispatch+0x39d>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
  101fe0:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101fe4:	0f 85 f3 01 00 00    	jne    1021dd <trap_dispatch+0x39d>
  101fea:	8b 45 08             	mov    0x8(%ebp),%eax
  101fed:	89 04 24             	mov    %eax,(%esp)
  101ff0:	e8 c9 fb ff ff       	call   101bbe <trap_in_kernel>
  101ff5:	85 c0                	test   %eax,%eax
  101ff7:	0f 84 e0 01 00 00    	je     1021dd <trap_dispatch+0x39d>
  101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  102000:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (tf->tf_cs != USER_CS) {
  102003:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102006:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10200a:	83 f8 1b             	cmp    $0x1b,%eax
  10200d:	74 75                	je     102084 <trap_dispatch+0x244>
        switchk2u = *tf;
  10200f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102012:	b8 4c 00 00 00       	mov    $0x4c,%eax
  102017:	83 e0 fc             	and    $0xfffffffc,%eax
  10201a:	89 c3                	mov    %eax,%ebx
  10201c:	b8 00 00 00 00       	mov    $0x0,%eax
  102021:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  102024:	89 90 80 c6 11 00    	mov    %edx,0x11c680(%eax)
  10202a:	83 c0 04             	add    $0x4,%eax
  10202d:	39 d8                	cmp    %ebx,%eax
  10202f:	72 f0                	jb     102021 <trap_dispatch+0x1e1>
        switchk2u.tf_cs = USER_CS;
  102031:	66 c7 05 bc c6 11 00 	movw   $0x1b,0x11c6bc
  102038:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  10203a:	66 c7 05 c8 c6 11 00 	movw   $0x23,0x11c6c8
  102041:	23 00 
  102043:	0f b7 05 c8 c6 11 00 	movzwl 0x11c6c8,%eax
  10204a:	66 a3 a8 c6 11 00    	mov    %ax,0x11c6a8
  102050:	0f b7 05 a8 c6 11 00 	movzwl 0x11c6a8,%eax
  102057:	66 a3 ac c6 11 00    	mov    %ax,0x11c6ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
  10205d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102060:	83 c0 4c             	add    $0x4c,%eax
  102063:	a3 c4 c6 11 00       	mov    %eax,0x11c6c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
  102068:	a1 c0 c6 11 00       	mov    0x11c6c0,%eax
  10206d:	0d 00 30 00 00       	or     $0x3000,%eax
  102072:	a3 c0 c6 11 00       	mov    %eax,0x11c6c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  102077:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10207a:	83 e8 04             	sub    $0x4,%eax
  10207d:	ba 80 c6 11 00       	mov    $0x11c680,%edx
  102082:	89 10                	mov    %edx,(%eax)
}
  102084:	90                   	nop
        print_trapframe(tf);
  102085:	8b 45 08             	mov    0x8(%ebp),%eax
  102088:	89 04 24             	mov    %eax,(%esp)
  10208b:	e8 43 fb ff ff       	call   101bd3 <print_trapframe>
        break;
  102090:	e9 48 01 00 00       	jmp    1021dd <trap_dispatch+0x39d>
  102095:	8b 45 08             	mov    0x8(%ebp),%eax
  102098:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (tf->tf_cs != USER_CS) {
  10209b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10209e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1020a2:	83 f8 1b             	cmp    $0x1b,%eax
  1020a5:	74 75                	je     10211c <trap_dispatch+0x2dc>
        switchk2u = *tf;
  1020a7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1020aa:	b8 4c 00 00 00       	mov    $0x4c,%eax
  1020af:	83 e0 fc             	and    $0xfffffffc,%eax
  1020b2:	89 c3                	mov    %eax,%ebx
  1020b4:	b8 00 00 00 00       	mov    $0x0,%eax
  1020b9:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  1020bc:	89 90 80 c6 11 00    	mov    %edx,0x11c680(%eax)
  1020c2:	83 c0 04             	add    $0x4,%eax
  1020c5:	39 d8                	cmp    %ebx,%eax
  1020c7:	72 f0                	jb     1020b9 <trap_dispatch+0x279>
        switchk2u.tf_cs = USER_CS;
  1020c9:	66 c7 05 bc c6 11 00 	movw   $0x1b,0x11c6bc
  1020d0:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  1020d2:	66 c7 05 c8 c6 11 00 	movw   $0x23,0x11c6c8
  1020d9:	23 00 
  1020db:	0f b7 05 c8 c6 11 00 	movzwl 0x11c6c8,%eax
  1020e2:	66 a3 a8 c6 11 00    	mov    %ax,0x11c6a8
  1020e8:	0f b7 05 a8 c6 11 00 	movzwl 0x11c6a8,%eax
  1020ef:	66 a3 ac c6 11 00    	mov    %ax,0x11c6ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
  1020f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1020f8:	83 c0 4c             	add    $0x4c,%eax
  1020fb:	a3 c4 c6 11 00       	mov    %eax,0x11c6c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
  102100:	a1 c0 c6 11 00       	mov    0x11c6c0,%eax
  102105:	0d 00 30 00 00       	or     $0x3000,%eax
  10210a:	a3 c0 c6 11 00       	mov    %eax,0x11c6c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  10210f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102112:	83 e8 04             	sub    $0x4,%eax
  102115:	ba 80 c6 11 00       	mov    $0x11c680,%edx
  10211a:	89 10                	mov    %edx,(%eax)
}
  10211c:	90                   	nop
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    	switch_to_user(tf);
    	break;
  10211d:	e9 bc 00 00 00       	jmp    1021de <trap_dispatch+0x39e>
  102122:	8b 45 08             	mov    0x8(%ebp),%eax
  102125:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
  102128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10212b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10212f:	83 f8 08             	cmp    $0x8,%eax
  102132:	74 6b                	je     10219f <trap_dispatch+0x35f>
        tf->tf_cs = KERNEL_CS;
  102134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102137:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  10213d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102140:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  102146:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102149:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  10214d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102150:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  102154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102157:	8b 40 40             	mov    0x40(%eax),%eax
  10215a:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  10215f:	89 c2                	mov    %eax,%edx
  102161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102164:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  102167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10216a:	8b 40 44             	mov    0x44(%eax),%eax
  10216d:	83 e8 44             	sub    $0x44,%eax
  102170:	a3 cc c6 11 00       	mov    %eax,0x11c6cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  102175:	a1 cc c6 11 00       	mov    0x11c6cc,%eax
  10217a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  102181:	00 
  102182:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102185:	89 54 24 04          	mov    %edx,0x4(%esp)
  102189:	89 04 24             	mov    %eax,(%esp)
  10218c:	e8 3d 41 00 00       	call   1062ce <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  102191:	8b 15 cc c6 11 00    	mov    0x11c6cc,%edx
  102197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10219a:	83 e8 04             	sub    $0x4,%eax
  10219d:	89 10                	mov    %edx,(%eax)
}
  10219f:	90                   	nop
    case T_SWITCH_TOK:
    	switch_to_kernel(tf);
        break;
  1021a0:	eb 3c                	jmp    1021de <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  1021a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1021a5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1021a9:	83 e0 03             	and    $0x3,%eax
  1021ac:	85 c0                	test   %eax,%eax
  1021ae:	75 2e                	jne    1021de <trap_dispatch+0x39e>
            print_trapframe(tf);
  1021b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1021b3:	89 04 24             	mov    %eax,(%esp)
  1021b6:	e8 18 fa ff ff       	call   101bd3 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  1021bb:	c7 44 24 08 aa 69 10 	movl   $0x1069aa,0x8(%esp)
  1021c2:	00 
  1021c3:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  1021ca:	00 
  1021cb:	c7 04 24 ce 67 10 00 	movl   $0x1067ce,(%esp)
  1021d2:	e8 46 eb ff ff       	call   100d1d <__panic>
        break;
  1021d7:	90                   	nop
  1021d8:	eb 04                	jmp    1021de <trap_dispatch+0x39e>
        break;
  1021da:	90                   	nop
  1021db:	eb 01                	jmp    1021de <trap_dispatch+0x39e>
        break;
  1021dd:	90                   	nop
        }
    }
}
  1021de:	90                   	nop
  1021df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1021e2:	89 ec                	mov    %ebp,%esp
  1021e4:	5d                   	pop    %ebp
  1021e5:	c3                   	ret    

001021e6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  1021e6:	55                   	push   %ebp
  1021e7:	89 e5                	mov    %esp,%ebp
  1021e9:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  1021ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1021ef:	89 04 24             	mov    %eax,(%esp)
  1021f2:	e8 49 fc ff ff       	call   101e40 <trap_dispatch>
}
  1021f7:	90                   	nop
  1021f8:	89 ec                	mov    %ebp,%esp
  1021fa:	5d                   	pop    %ebp
  1021fb:	c3                   	ret    

001021fc <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1021fc:	1e                   	push   %ds
    pushl %es
  1021fd:	06                   	push   %es
    pushl %fs
  1021fe:	0f a0                	push   %fs
    pushl %gs
  102200:	0f a8                	push   %gs
    pushal
  102202:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102203:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102208:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10220a:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10220c:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10220d:	e8 d4 ff ff ff       	call   1021e6 <trap>

    # pop the pushed stack pointer
    popl %esp
  102212:	5c                   	pop    %esp

00102213 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102213:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102214:	0f a9                	pop    %gs
    popl %fs
  102216:	0f a1                	pop    %fs
    popl %es
  102218:	07                   	pop    %es
    popl %ds
  102219:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10221a:	83 c4 08             	add    $0x8,%esp
    iret
  10221d:	cf                   	iret   

0010221e <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $0
  102220:	6a 00                	push   $0x0
  jmp __alltraps
  102222:	e9 d5 ff ff ff       	jmp    1021fc <__alltraps>

00102227 <vector1>:
.globl vector1
vector1:
  pushl $0
  102227:	6a 00                	push   $0x0
  pushl $1
  102229:	6a 01                	push   $0x1
  jmp __alltraps
  10222b:	e9 cc ff ff ff       	jmp    1021fc <__alltraps>

00102230 <vector2>:
.globl vector2
vector2:
  pushl $0
  102230:	6a 00                	push   $0x0
  pushl $2
  102232:	6a 02                	push   $0x2
  jmp __alltraps
  102234:	e9 c3 ff ff ff       	jmp    1021fc <__alltraps>

00102239 <vector3>:
.globl vector3
vector3:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $3
  10223b:	6a 03                	push   $0x3
  jmp __alltraps
  10223d:	e9 ba ff ff ff       	jmp    1021fc <__alltraps>

00102242 <vector4>:
.globl vector4
vector4:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $4
  102244:	6a 04                	push   $0x4
  jmp __alltraps
  102246:	e9 b1 ff ff ff       	jmp    1021fc <__alltraps>

0010224b <vector5>:
.globl vector5
vector5:
  pushl $0
  10224b:	6a 00                	push   $0x0
  pushl $5
  10224d:	6a 05                	push   $0x5
  jmp __alltraps
  10224f:	e9 a8 ff ff ff       	jmp    1021fc <__alltraps>

00102254 <vector6>:
.globl vector6
vector6:
  pushl $0
  102254:	6a 00                	push   $0x0
  pushl $6
  102256:	6a 06                	push   $0x6
  jmp __alltraps
  102258:	e9 9f ff ff ff       	jmp    1021fc <__alltraps>

0010225d <vector7>:
.globl vector7
vector7:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $7
  10225f:	6a 07                	push   $0x7
  jmp __alltraps
  102261:	e9 96 ff ff ff       	jmp    1021fc <__alltraps>

00102266 <vector8>:
.globl vector8
vector8:
  pushl $8
  102266:	6a 08                	push   $0x8
  jmp __alltraps
  102268:	e9 8f ff ff ff       	jmp    1021fc <__alltraps>

0010226d <vector9>:
.globl vector9
vector9:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $9
  10226f:	6a 09                	push   $0x9
  jmp __alltraps
  102271:	e9 86 ff ff ff       	jmp    1021fc <__alltraps>

00102276 <vector10>:
.globl vector10
vector10:
  pushl $10
  102276:	6a 0a                	push   $0xa
  jmp __alltraps
  102278:	e9 7f ff ff ff       	jmp    1021fc <__alltraps>

0010227d <vector11>:
.globl vector11
vector11:
  pushl $11
  10227d:	6a 0b                	push   $0xb
  jmp __alltraps
  10227f:	e9 78 ff ff ff       	jmp    1021fc <__alltraps>

00102284 <vector12>:
.globl vector12
vector12:
  pushl $12
  102284:	6a 0c                	push   $0xc
  jmp __alltraps
  102286:	e9 71 ff ff ff       	jmp    1021fc <__alltraps>

0010228b <vector13>:
.globl vector13
vector13:
  pushl $13
  10228b:	6a 0d                	push   $0xd
  jmp __alltraps
  10228d:	e9 6a ff ff ff       	jmp    1021fc <__alltraps>

00102292 <vector14>:
.globl vector14
vector14:
  pushl $14
  102292:	6a 0e                	push   $0xe
  jmp __alltraps
  102294:	e9 63 ff ff ff       	jmp    1021fc <__alltraps>

00102299 <vector15>:
.globl vector15
vector15:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $15
  10229b:	6a 0f                	push   $0xf
  jmp __alltraps
  10229d:	e9 5a ff ff ff       	jmp    1021fc <__alltraps>

001022a2 <vector16>:
.globl vector16
vector16:
  pushl $0
  1022a2:	6a 00                	push   $0x0
  pushl $16
  1022a4:	6a 10                	push   $0x10
  jmp __alltraps
  1022a6:	e9 51 ff ff ff       	jmp    1021fc <__alltraps>

001022ab <vector17>:
.globl vector17
vector17:
  pushl $17
  1022ab:	6a 11                	push   $0x11
  jmp __alltraps
  1022ad:	e9 4a ff ff ff       	jmp    1021fc <__alltraps>

001022b2 <vector18>:
.globl vector18
vector18:
  pushl $0
  1022b2:	6a 00                	push   $0x0
  pushl $18
  1022b4:	6a 12                	push   $0x12
  jmp __alltraps
  1022b6:	e9 41 ff ff ff       	jmp    1021fc <__alltraps>

001022bb <vector19>:
.globl vector19
vector19:
  pushl $0
  1022bb:	6a 00                	push   $0x0
  pushl $19
  1022bd:	6a 13                	push   $0x13
  jmp __alltraps
  1022bf:	e9 38 ff ff ff       	jmp    1021fc <__alltraps>

001022c4 <vector20>:
.globl vector20
vector20:
  pushl $0
  1022c4:	6a 00                	push   $0x0
  pushl $20
  1022c6:	6a 14                	push   $0x14
  jmp __alltraps
  1022c8:	e9 2f ff ff ff       	jmp    1021fc <__alltraps>

001022cd <vector21>:
.globl vector21
vector21:
  pushl $0
  1022cd:	6a 00                	push   $0x0
  pushl $21
  1022cf:	6a 15                	push   $0x15
  jmp __alltraps
  1022d1:	e9 26 ff ff ff       	jmp    1021fc <__alltraps>

001022d6 <vector22>:
.globl vector22
vector22:
  pushl $0
  1022d6:	6a 00                	push   $0x0
  pushl $22
  1022d8:	6a 16                	push   $0x16
  jmp __alltraps
  1022da:	e9 1d ff ff ff       	jmp    1021fc <__alltraps>

001022df <vector23>:
.globl vector23
vector23:
  pushl $0
  1022df:	6a 00                	push   $0x0
  pushl $23
  1022e1:	6a 17                	push   $0x17
  jmp __alltraps
  1022e3:	e9 14 ff ff ff       	jmp    1021fc <__alltraps>

001022e8 <vector24>:
.globl vector24
vector24:
  pushl $0
  1022e8:	6a 00                	push   $0x0
  pushl $24
  1022ea:	6a 18                	push   $0x18
  jmp __alltraps
  1022ec:	e9 0b ff ff ff       	jmp    1021fc <__alltraps>

001022f1 <vector25>:
.globl vector25
vector25:
  pushl $0
  1022f1:	6a 00                	push   $0x0
  pushl $25
  1022f3:	6a 19                	push   $0x19
  jmp __alltraps
  1022f5:	e9 02 ff ff ff       	jmp    1021fc <__alltraps>

001022fa <vector26>:
.globl vector26
vector26:
  pushl $0
  1022fa:	6a 00                	push   $0x0
  pushl $26
  1022fc:	6a 1a                	push   $0x1a
  jmp __alltraps
  1022fe:	e9 f9 fe ff ff       	jmp    1021fc <__alltraps>

00102303 <vector27>:
.globl vector27
vector27:
  pushl $0
  102303:	6a 00                	push   $0x0
  pushl $27
  102305:	6a 1b                	push   $0x1b
  jmp __alltraps
  102307:	e9 f0 fe ff ff       	jmp    1021fc <__alltraps>

0010230c <vector28>:
.globl vector28
vector28:
  pushl $0
  10230c:	6a 00                	push   $0x0
  pushl $28
  10230e:	6a 1c                	push   $0x1c
  jmp __alltraps
  102310:	e9 e7 fe ff ff       	jmp    1021fc <__alltraps>

00102315 <vector29>:
.globl vector29
vector29:
  pushl $0
  102315:	6a 00                	push   $0x0
  pushl $29
  102317:	6a 1d                	push   $0x1d
  jmp __alltraps
  102319:	e9 de fe ff ff       	jmp    1021fc <__alltraps>

0010231e <vector30>:
.globl vector30
vector30:
  pushl $0
  10231e:	6a 00                	push   $0x0
  pushl $30
  102320:	6a 1e                	push   $0x1e
  jmp __alltraps
  102322:	e9 d5 fe ff ff       	jmp    1021fc <__alltraps>

00102327 <vector31>:
.globl vector31
vector31:
  pushl $0
  102327:	6a 00                	push   $0x0
  pushl $31
  102329:	6a 1f                	push   $0x1f
  jmp __alltraps
  10232b:	e9 cc fe ff ff       	jmp    1021fc <__alltraps>

00102330 <vector32>:
.globl vector32
vector32:
  pushl $0
  102330:	6a 00                	push   $0x0
  pushl $32
  102332:	6a 20                	push   $0x20
  jmp __alltraps
  102334:	e9 c3 fe ff ff       	jmp    1021fc <__alltraps>

00102339 <vector33>:
.globl vector33
vector33:
  pushl $0
  102339:	6a 00                	push   $0x0
  pushl $33
  10233b:	6a 21                	push   $0x21
  jmp __alltraps
  10233d:	e9 ba fe ff ff       	jmp    1021fc <__alltraps>

00102342 <vector34>:
.globl vector34
vector34:
  pushl $0
  102342:	6a 00                	push   $0x0
  pushl $34
  102344:	6a 22                	push   $0x22
  jmp __alltraps
  102346:	e9 b1 fe ff ff       	jmp    1021fc <__alltraps>

0010234b <vector35>:
.globl vector35
vector35:
  pushl $0
  10234b:	6a 00                	push   $0x0
  pushl $35
  10234d:	6a 23                	push   $0x23
  jmp __alltraps
  10234f:	e9 a8 fe ff ff       	jmp    1021fc <__alltraps>

00102354 <vector36>:
.globl vector36
vector36:
  pushl $0
  102354:	6a 00                	push   $0x0
  pushl $36
  102356:	6a 24                	push   $0x24
  jmp __alltraps
  102358:	e9 9f fe ff ff       	jmp    1021fc <__alltraps>

0010235d <vector37>:
.globl vector37
vector37:
  pushl $0
  10235d:	6a 00                	push   $0x0
  pushl $37
  10235f:	6a 25                	push   $0x25
  jmp __alltraps
  102361:	e9 96 fe ff ff       	jmp    1021fc <__alltraps>

00102366 <vector38>:
.globl vector38
vector38:
  pushl $0
  102366:	6a 00                	push   $0x0
  pushl $38
  102368:	6a 26                	push   $0x26
  jmp __alltraps
  10236a:	e9 8d fe ff ff       	jmp    1021fc <__alltraps>

0010236f <vector39>:
.globl vector39
vector39:
  pushl $0
  10236f:	6a 00                	push   $0x0
  pushl $39
  102371:	6a 27                	push   $0x27
  jmp __alltraps
  102373:	e9 84 fe ff ff       	jmp    1021fc <__alltraps>

00102378 <vector40>:
.globl vector40
vector40:
  pushl $0
  102378:	6a 00                	push   $0x0
  pushl $40
  10237a:	6a 28                	push   $0x28
  jmp __alltraps
  10237c:	e9 7b fe ff ff       	jmp    1021fc <__alltraps>

00102381 <vector41>:
.globl vector41
vector41:
  pushl $0
  102381:	6a 00                	push   $0x0
  pushl $41
  102383:	6a 29                	push   $0x29
  jmp __alltraps
  102385:	e9 72 fe ff ff       	jmp    1021fc <__alltraps>

0010238a <vector42>:
.globl vector42
vector42:
  pushl $0
  10238a:	6a 00                	push   $0x0
  pushl $42
  10238c:	6a 2a                	push   $0x2a
  jmp __alltraps
  10238e:	e9 69 fe ff ff       	jmp    1021fc <__alltraps>

00102393 <vector43>:
.globl vector43
vector43:
  pushl $0
  102393:	6a 00                	push   $0x0
  pushl $43
  102395:	6a 2b                	push   $0x2b
  jmp __alltraps
  102397:	e9 60 fe ff ff       	jmp    1021fc <__alltraps>

0010239c <vector44>:
.globl vector44
vector44:
  pushl $0
  10239c:	6a 00                	push   $0x0
  pushl $44
  10239e:	6a 2c                	push   $0x2c
  jmp __alltraps
  1023a0:	e9 57 fe ff ff       	jmp    1021fc <__alltraps>

001023a5 <vector45>:
.globl vector45
vector45:
  pushl $0
  1023a5:	6a 00                	push   $0x0
  pushl $45
  1023a7:	6a 2d                	push   $0x2d
  jmp __alltraps
  1023a9:	e9 4e fe ff ff       	jmp    1021fc <__alltraps>

001023ae <vector46>:
.globl vector46
vector46:
  pushl $0
  1023ae:	6a 00                	push   $0x0
  pushl $46
  1023b0:	6a 2e                	push   $0x2e
  jmp __alltraps
  1023b2:	e9 45 fe ff ff       	jmp    1021fc <__alltraps>

001023b7 <vector47>:
.globl vector47
vector47:
  pushl $0
  1023b7:	6a 00                	push   $0x0
  pushl $47
  1023b9:	6a 2f                	push   $0x2f
  jmp __alltraps
  1023bb:	e9 3c fe ff ff       	jmp    1021fc <__alltraps>

001023c0 <vector48>:
.globl vector48
vector48:
  pushl $0
  1023c0:	6a 00                	push   $0x0
  pushl $48
  1023c2:	6a 30                	push   $0x30
  jmp __alltraps
  1023c4:	e9 33 fe ff ff       	jmp    1021fc <__alltraps>

001023c9 <vector49>:
.globl vector49
vector49:
  pushl $0
  1023c9:	6a 00                	push   $0x0
  pushl $49
  1023cb:	6a 31                	push   $0x31
  jmp __alltraps
  1023cd:	e9 2a fe ff ff       	jmp    1021fc <__alltraps>

001023d2 <vector50>:
.globl vector50
vector50:
  pushl $0
  1023d2:	6a 00                	push   $0x0
  pushl $50
  1023d4:	6a 32                	push   $0x32
  jmp __alltraps
  1023d6:	e9 21 fe ff ff       	jmp    1021fc <__alltraps>

001023db <vector51>:
.globl vector51
vector51:
  pushl $0
  1023db:	6a 00                	push   $0x0
  pushl $51
  1023dd:	6a 33                	push   $0x33
  jmp __alltraps
  1023df:	e9 18 fe ff ff       	jmp    1021fc <__alltraps>

001023e4 <vector52>:
.globl vector52
vector52:
  pushl $0
  1023e4:	6a 00                	push   $0x0
  pushl $52
  1023e6:	6a 34                	push   $0x34
  jmp __alltraps
  1023e8:	e9 0f fe ff ff       	jmp    1021fc <__alltraps>

001023ed <vector53>:
.globl vector53
vector53:
  pushl $0
  1023ed:	6a 00                	push   $0x0
  pushl $53
  1023ef:	6a 35                	push   $0x35
  jmp __alltraps
  1023f1:	e9 06 fe ff ff       	jmp    1021fc <__alltraps>

001023f6 <vector54>:
.globl vector54
vector54:
  pushl $0
  1023f6:	6a 00                	push   $0x0
  pushl $54
  1023f8:	6a 36                	push   $0x36
  jmp __alltraps
  1023fa:	e9 fd fd ff ff       	jmp    1021fc <__alltraps>

001023ff <vector55>:
.globl vector55
vector55:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $55
  102401:	6a 37                	push   $0x37
  jmp __alltraps
  102403:	e9 f4 fd ff ff       	jmp    1021fc <__alltraps>

00102408 <vector56>:
.globl vector56
vector56:
  pushl $0
  102408:	6a 00                	push   $0x0
  pushl $56
  10240a:	6a 38                	push   $0x38
  jmp __alltraps
  10240c:	e9 eb fd ff ff       	jmp    1021fc <__alltraps>

00102411 <vector57>:
.globl vector57
vector57:
  pushl $0
  102411:	6a 00                	push   $0x0
  pushl $57
  102413:	6a 39                	push   $0x39
  jmp __alltraps
  102415:	e9 e2 fd ff ff       	jmp    1021fc <__alltraps>

0010241a <vector58>:
.globl vector58
vector58:
  pushl $0
  10241a:	6a 00                	push   $0x0
  pushl $58
  10241c:	6a 3a                	push   $0x3a
  jmp __alltraps
  10241e:	e9 d9 fd ff ff       	jmp    1021fc <__alltraps>

00102423 <vector59>:
.globl vector59
vector59:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $59
  102425:	6a 3b                	push   $0x3b
  jmp __alltraps
  102427:	e9 d0 fd ff ff       	jmp    1021fc <__alltraps>

0010242c <vector60>:
.globl vector60
vector60:
  pushl $0
  10242c:	6a 00                	push   $0x0
  pushl $60
  10242e:	6a 3c                	push   $0x3c
  jmp __alltraps
  102430:	e9 c7 fd ff ff       	jmp    1021fc <__alltraps>

00102435 <vector61>:
.globl vector61
vector61:
  pushl $0
  102435:	6a 00                	push   $0x0
  pushl $61
  102437:	6a 3d                	push   $0x3d
  jmp __alltraps
  102439:	e9 be fd ff ff       	jmp    1021fc <__alltraps>

0010243e <vector62>:
.globl vector62
vector62:
  pushl $0
  10243e:	6a 00                	push   $0x0
  pushl $62
  102440:	6a 3e                	push   $0x3e
  jmp __alltraps
  102442:	e9 b5 fd ff ff       	jmp    1021fc <__alltraps>

00102447 <vector63>:
.globl vector63
vector63:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $63
  102449:	6a 3f                	push   $0x3f
  jmp __alltraps
  10244b:	e9 ac fd ff ff       	jmp    1021fc <__alltraps>

00102450 <vector64>:
.globl vector64
vector64:
  pushl $0
  102450:	6a 00                	push   $0x0
  pushl $64
  102452:	6a 40                	push   $0x40
  jmp __alltraps
  102454:	e9 a3 fd ff ff       	jmp    1021fc <__alltraps>

00102459 <vector65>:
.globl vector65
vector65:
  pushl $0
  102459:	6a 00                	push   $0x0
  pushl $65
  10245b:	6a 41                	push   $0x41
  jmp __alltraps
  10245d:	e9 9a fd ff ff       	jmp    1021fc <__alltraps>

00102462 <vector66>:
.globl vector66
vector66:
  pushl $0
  102462:	6a 00                	push   $0x0
  pushl $66
  102464:	6a 42                	push   $0x42
  jmp __alltraps
  102466:	e9 91 fd ff ff       	jmp    1021fc <__alltraps>

0010246b <vector67>:
.globl vector67
vector67:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $67
  10246d:	6a 43                	push   $0x43
  jmp __alltraps
  10246f:	e9 88 fd ff ff       	jmp    1021fc <__alltraps>

00102474 <vector68>:
.globl vector68
vector68:
  pushl $0
  102474:	6a 00                	push   $0x0
  pushl $68
  102476:	6a 44                	push   $0x44
  jmp __alltraps
  102478:	e9 7f fd ff ff       	jmp    1021fc <__alltraps>

0010247d <vector69>:
.globl vector69
vector69:
  pushl $0
  10247d:	6a 00                	push   $0x0
  pushl $69
  10247f:	6a 45                	push   $0x45
  jmp __alltraps
  102481:	e9 76 fd ff ff       	jmp    1021fc <__alltraps>

00102486 <vector70>:
.globl vector70
vector70:
  pushl $0
  102486:	6a 00                	push   $0x0
  pushl $70
  102488:	6a 46                	push   $0x46
  jmp __alltraps
  10248a:	e9 6d fd ff ff       	jmp    1021fc <__alltraps>

0010248f <vector71>:
.globl vector71
vector71:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $71
  102491:	6a 47                	push   $0x47
  jmp __alltraps
  102493:	e9 64 fd ff ff       	jmp    1021fc <__alltraps>

00102498 <vector72>:
.globl vector72
vector72:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $72
  10249a:	6a 48                	push   $0x48
  jmp __alltraps
  10249c:	e9 5b fd ff ff       	jmp    1021fc <__alltraps>

001024a1 <vector73>:
.globl vector73
vector73:
  pushl $0
  1024a1:	6a 00                	push   $0x0
  pushl $73
  1024a3:	6a 49                	push   $0x49
  jmp __alltraps
  1024a5:	e9 52 fd ff ff       	jmp    1021fc <__alltraps>

001024aa <vector74>:
.globl vector74
vector74:
  pushl $0
  1024aa:	6a 00                	push   $0x0
  pushl $74
  1024ac:	6a 4a                	push   $0x4a
  jmp __alltraps
  1024ae:	e9 49 fd ff ff       	jmp    1021fc <__alltraps>

001024b3 <vector75>:
.globl vector75
vector75:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $75
  1024b5:	6a 4b                	push   $0x4b
  jmp __alltraps
  1024b7:	e9 40 fd ff ff       	jmp    1021fc <__alltraps>

001024bc <vector76>:
.globl vector76
vector76:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $76
  1024be:	6a 4c                	push   $0x4c
  jmp __alltraps
  1024c0:	e9 37 fd ff ff       	jmp    1021fc <__alltraps>

001024c5 <vector77>:
.globl vector77
vector77:
  pushl $0
  1024c5:	6a 00                	push   $0x0
  pushl $77
  1024c7:	6a 4d                	push   $0x4d
  jmp __alltraps
  1024c9:	e9 2e fd ff ff       	jmp    1021fc <__alltraps>

001024ce <vector78>:
.globl vector78
vector78:
  pushl $0
  1024ce:	6a 00                	push   $0x0
  pushl $78
  1024d0:	6a 4e                	push   $0x4e
  jmp __alltraps
  1024d2:	e9 25 fd ff ff       	jmp    1021fc <__alltraps>

001024d7 <vector79>:
.globl vector79
vector79:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $79
  1024d9:	6a 4f                	push   $0x4f
  jmp __alltraps
  1024db:	e9 1c fd ff ff       	jmp    1021fc <__alltraps>

001024e0 <vector80>:
.globl vector80
vector80:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $80
  1024e2:	6a 50                	push   $0x50
  jmp __alltraps
  1024e4:	e9 13 fd ff ff       	jmp    1021fc <__alltraps>

001024e9 <vector81>:
.globl vector81
vector81:
  pushl $0
  1024e9:	6a 00                	push   $0x0
  pushl $81
  1024eb:	6a 51                	push   $0x51
  jmp __alltraps
  1024ed:	e9 0a fd ff ff       	jmp    1021fc <__alltraps>

001024f2 <vector82>:
.globl vector82
vector82:
  pushl $0
  1024f2:	6a 00                	push   $0x0
  pushl $82
  1024f4:	6a 52                	push   $0x52
  jmp __alltraps
  1024f6:	e9 01 fd ff ff       	jmp    1021fc <__alltraps>

001024fb <vector83>:
.globl vector83
vector83:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $83
  1024fd:	6a 53                	push   $0x53
  jmp __alltraps
  1024ff:	e9 f8 fc ff ff       	jmp    1021fc <__alltraps>

00102504 <vector84>:
.globl vector84
vector84:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $84
  102506:	6a 54                	push   $0x54
  jmp __alltraps
  102508:	e9 ef fc ff ff       	jmp    1021fc <__alltraps>

0010250d <vector85>:
.globl vector85
vector85:
  pushl $0
  10250d:	6a 00                	push   $0x0
  pushl $85
  10250f:	6a 55                	push   $0x55
  jmp __alltraps
  102511:	e9 e6 fc ff ff       	jmp    1021fc <__alltraps>

00102516 <vector86>:
.globl vector86
vector86:
  pushl $0
  102516:	6a 00                	push   $0x0
  pushl $86
  102518:	6a 56                	push   $0x56
  jmp __alltraps
  10251a:	e9 dd fc ff ff       	jmp    1021fc <__alltraps>

0010251f <vector87>:
.globl vector87
vector87:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $87
  102521:	6a 57                	push   $0x57
  jmp __alltraps
  102523:	e9 d4 fc ff ff       	jmp    1021fc <__alltraps>

00102528 <vector88>:
.globl vector88
vector88:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $88
  10252a:	6a 58                	push   $0x58
  jmp __alltraps
  10252c:	e9 cb fc ff ff       	jmp    1021fc <__alltraps>

00102531 <vector89>:
.globl vector89
vector89:
  pushl $0
  102531:	6a 00                	push   $0x0
  pushl $89
  102533:	6a 59                	push   $0x59
  jmp __alltraps
  102535:	e9 c2 fc ff ff       	jmp    1021fc <__alltraps>

0010253a <vector90>:
.globl vector90
vector90:
  pushl $0
  10253a:	6a 00                	push   $0x0
  pushl $90
  10253c:	6a 5a                	push   $0x5a
  jmp __alltraps
  10253e:	e9 b9 fc ff ff       	jmp    1021fc <__alltraps>

00102543 <vector91>:
.globl vector91
vector91:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $91
  102545:	6a 5b                	push   $0x5b
  jmp __alltraps
  102547:	e9 b0 fc ff ff       	jmp    1021fc <__alltraps>

0010254c <vector92>:
.globl vector92
vector92:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $92
  10254e:	6a 5c                	push   $0x5c
  jmp __alltraps
  102550:	e9 a7 fc ff ff       	jmp    1021fc <__alltraps>

00102555 <vector93>:
.globl vector93
vector93:
  pushl $0
  102555:	6a 00                	push   $0x0
  pushl $93
  102557:	6a 5d                	push   $0x5d
  jmp __alltraps
  102559:	e9 9e fc ff ff       	jmp    1021fc <__alltraps>

0010255e <vector94>:
.globl vector94
vector94:
  pushl $0
  10255e:	6a 00                	push   $0x0
  pushl $94
  102560:	6a 5e                	push   $0x5e
  jmp __alltraps
  102562:	e9 95 fc ff ff       	jmp    1021fc <__alltraps>

00102567 <vector95>:
.globl vector95
vector95:
  pushl $0
  102567:	6a 00                	push   $0x0
  pushl $95
  102569:	6a 5f                	push   $0x5f
  jmp __alltraps
  10256b:	e9 8c fc ff ff       	jmp    1021fc <__alltraps>

00102570 <vector96>:
.globl vector96
vector96:
  pushl $0
  102570:	6a 00                	push   $0x0
  pushl $96
  102572:	6a 60                	push   $0x60
  jmp __alltraps
  102574:	e9 83 fc ff ff       	jmp    1021fc <__alltraps>

00102579 <vector97>:
.globl vector97
vector97:
  pushl $0
  102579:	6a 00                	push   $0x0
  pushl $97
  10257b:	6a 61                	push   $0x61
  jmp __alltraps
  10257d:	e9 7a fc ff ff       	jmp    1021fc <__alltraps>

00102582 <vector98>:
.globl vector98
vector98:
  pushl $0
  102582:	6a 00                	push   $0x0
  pushl $98
  102584:	6a 62                	push   $0x62
  jmp __alltraps
  102586:	e9 71 fc ff ff       	jmp    1021fc <__alltraps>

0010258b <vector99>:
.globl vector99
vector99:
  pushl $0
  10258b:	6a 00                	push   $0x0
  pushl $99
  10258d:	6a 63                	push   $0x63
  jmp __alltraps
  10258f:	e9 68 fc ff ff       	jmp    1021fc <__alltraps>

00102594 <vector100>:
.globl vector100
vector100:
  pushl $0
  102594:	6a 00                	push   $0x0
  pushl $100
  102596:	6a 64                	push   $0x64
  jmp __alltraps
  102598:	e9 5f fc ff ff       	jmp    1021fc <__alltraps>

0010259d <vector101>:
.globl vector101
vector101:
  pushl $0
  10259d:	6a 00                	push   $0x0
  pushl $101
  10259f:	6a 65                	push   $0x65
  jmp __alltraps
  1025a1:	e9 56 fc ff ff       	jmp    1021fc <__alltraps>

001025a6 <vector102>:
.globl vector102
vector102:
  pushl $0
  1025a6:	6a 00                	push   $0x0
  pushl $102
  1025a8:	6a 66                	push   $0x66
  jmp __alltraps
  1025aa:	e9 4d fc ff ff       	jmp    1021fc <__alltraps>

001025af <vector103>:
.globl vector103
vector103:
  pushl $0
  1025af:	6a 00                	push   $0x0
  pushl $103
  1025b1:	6a 67                	push   $0x67
  jmp __alltraps
  1025b3:	e9 44 fc ff ff       	jmp    1021fc <__alltraps>

001025b8 <vector104>:
.globl vector104
vector104:
  pushl $0
  1025b8:	6a 00                	push   $0x0
  pushl $104
  1025ba:	6a 68                	push   $0x68
  jmp __alltraps
  1025bc:	e9 3b fc ff ff       	jmp    1021fc <__alltraps>

001025c1 <vector105>:
.globl vector105
vector105:
  pushl $0
  1025c1:	6a 00                	push   $0x0
  pushl $105
  1025c3:	6a 69                	push   $0x69
  jmp __alltraps
  1025c5:	e9 32 fc ff ff       	jmp    1021fc <__alltraps>

001025ca <vector106>:
.globl vector106
vector106:
  pushl $0
  1025ca:	6a 00                	push   $0x0
  pushl $106
  1025cc:	6a 6a                	push   $0x6a
  jmp __alltraps
  1025ce:	e9 29 fc ff ff       	jmp    1021fc <__alltraps>

001025d3 <vector107>:
.globl vector107
vector107:
  pushl $0
  1025d3:	6a 00                	push   $0x0
  pushl $107
  1025d5:	6a 6b                	push   $0x6b
  jmp __alltraps
  1025d7:	e9 20 fc ff ff       	jmp    1021fc <__alltraps>

001025dc <vector108>:
.globl vector108
vector108:
  pushl $0
  1025dc:	6a 00                	push   $0x0
  pushl $108
  1025de:	6a 6c                	push   $0x6c
  jmp __alltraps
  1025e0:	e9 17 fc ff ff       	jmp    1021fc <__alltraps>

001025e5 <vector109>:
.globl vector109
vector109:
  pushl $0
  1025e5:	6a 00                	push   $0x0
  pushl $109
  1025e7:	6a 6d                	push   $0x6d
  jmp __alltraps
  1025e9:	e9 0e fc ff ff       	jmp    1021fc <__alltraps>

001025ee <vector110>:
.globl vector110
vector110:
  pushl $0
  1025ee:	6a 00                	push   $0x0
  pushl $110
  1025f0:	6a 6e                	push   $0x6e
  jmp __alltraps
  1025f2:	e9 05 fc ff ff       	jmp    1021fc <__alltraps>

001025f7 <vector111>:
.globl vector111
vector111:
  pushl $0
  1025f7:	6a 00                	push   $0x0
  pushl $111
  1025f9:	6a 6f                	push   $0x6f
  jmp __alltraps
  1025fb:	e9 fc fb ff ff       	jmp    1021fc <__alltraps>

00102600 <vector112>:
.globl vector112
vector112:
  pushl $0
  102600:	6a 00                	push   $0x0
  pushl $112
  102602:	6a 70                	push   $0x70
  jmp __alltraps
  102604:	e9 f3 fb ff ff       	jmp    1021fc <__alltraps>

00102609 <vector113>:
.globl vector113
vector113:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $113
  10260b:	6a 71                	push   $0x71
  jmp __alltraps
  10260d:	e9 ea fb ff ff       	jmp    1021fc <__alltraps>

00102612 <vector114>:
.globl vector114
vector114:
  pushl $0
  102612:	6a 00                	push   $0x0
  pushl $114
  102614:	6a 72                	push   $0x72
  jmp __alltraps
  102616:	e9 e1 fb ff ff       	jmp    1021fc <__alltraps>

0010261b <vector115>:
.globl vector115
vector115:
  pushl $0
  10261b:	6a 00                	push   $0x0
  pushl $115
  10261d:	6a 73                	push   $0x73
  jmp __alltraps
  10261f:	e9 d8 fb ff ff       	jmp    1021fc <__alltraps>

00102624 <vector116>:
.globl vector116
vector116:
  pushl $0
  102624:	6a 00                	push   $0x0
  pushl $116
  102626:	6a 74                	push   $0x74
  jmp __alltraps
  102628:	e9 cf fb ff ff       	jmp    1021fc <__alltraps>

0010262d <vector117>:
.globl vector117
vector117:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $117
  10262f:	6a 75                	push   $0x75
  jmp __alltraps
  102631:	e9 c6 fb ff ff       	jmp    1021fc <__alltraps>

00102636 <vector118>:
.globl vector118
vector118:
  pushl $0
  102636:	6a 00                	push   $0x0
  pushl $118
  102638:	6a 76                	push   $0x76
  jmp __alltraps
  10263a:	e9 bd fb ff ff       	jmp    1021fc <__alltraps>

0010263f <vector119>:
.globl vector119
vector119:
  pushl $0
  10263f:	6a 00                	push   $0x0
  pushl $119
  102641:	6a 77                	push   $0x77
  jmp __alltraps
  102643:	e9 b4 fb ff ff       	jmp    1021fc <__alltraps>

00102648 <vector120>:
.globl vector120
vector120:
  pushl $0
  102648:	6a 00                	push   $0x0
  pushl $120
  10264a:	6a 78                	push   $0x78
  jmp __alltraps
  10264c:	e9 ab fb ff ff       	jmp    1021fc <__alltraps>

00102651 <vector121>:
.globl vector121
vector121:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $121
  102653:	6a 79                	push   $0x79
  jmp __alltraps
  102655:	e9 a2 fb ff ff       	jmp    1021fc <__alltraps>

0010265a <vector122>:
.globl vector122
vector122:
  pushl $0
  10265a:	6a 00                	push   $0x0
  pushl $122
  10265c:	6a 7a                	push   $0x7a
  jmp __alltraps
  10265e:	e9 99 fb ff ff       	jmp    1021fc <__alltraps>

00102663 <vector123>:
.globl vector123
vector123:
  pushl $0
  102663:	6a 00                	push   $0x0
  pushl $123
  102665:	6a 7b                	push   $0x7b
  jmp __alltraps
  102667:	e9 90 fb ff ff       	jmp    1021fc <__alltraps>

0010266c <vector124>:
.globl vector124
vector124:
  pushl $0
  10266c:	6a 00                	push   $0x0
  pushl $124
  10266e:	6a 7c                	push   $0x7c
  jmp __alltraps
  102670:	e9 87 fb ff ff       	jmp    1021fc <__alltraps>

00102675 <vector125>:
.globl vector125
vector125:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $125
  102677:	6a 7d                	push   $0x7d
  jmp __alltraps
  102679:	e9 7e fb ff ff       	jmp    1021fc <__alltraps>

0010267e <vector126>:
.globl vector126
vector126:
  pushl $0
  10267e:	6a 00                	push   $0x0
  pushl $126
  102680:	6a 7e                	push   $0x7e
  jmp __alltraps
  102682:	e9 75 fb ff ff       	jmp    1021fc <__alltraps>

00102687 <vector127>:
.globl vector127
vector127:
  pushl $0
  102687:	6a 00                	push   $0x0
  pushl $127
  102689:	6a 7f                	push   $0x7f
  jmp __alltraps
  10268b:	e9 6c fb ff ff       	jmp    1021fc <__alltraps>

00102690 <vector128>:
.globl vector128
vector128:
  pushl $0
  102690:	6a 00                	push   $0x0
  pushl $128
  102692:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102697:	e9 60 fb ff ff       	jmp    1021fc <__alltraps>

0010269c <vector129>:
.globl vector129
vector129:
  pushl $0
  10269c:	6a 00                	push   $0x0
  pushl $129
  10269e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1026a3:	e9 54 fb ff ff       	jmp    1021fc <__alltraps>

001026a8 <vector130>:
.globl vector130
vector130:
  pushl $0
  1026a8:	6a 00                	push   $0x0
  pushl $130
  1026aa:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1026af:	e9 48 fb ff ff       	jmp    1021fc <__alltraps>

001026b4 <vector131>:
.globl vector131
vector131:
  pushl $0
  1026b4:	6a 00                	push   $0x0
  pushl $131
  1026b6:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1026bb:	e9 3c fb ff ff       	jmp    1021fc <__alltraps>

001026c0 <vector132>:
.globl vector132
vector132:
  pushl $0
  1026c0:	6a 00                	push   $0x0
  pushl $132
  1026c2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1026c7:	e9 30 fb ff ff       	jmp    1021fc <__alltraps>

001026cc <vector133>:
.globl vector133
vector133:
  pushl $0
  1026cc:	6a 00                	push   $0x0
  pushl $133
  1026ce:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1026d3:	e9 24 fb ff ff       	jmp    1021fc <__alltraps>

001026d8 <vector134>:
.globl vector134
vector134:
  pushl $0
  1026d8:	6a 00                	push   $0x0
  pushl $134
  1026da:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1026df:	e9 18 fb ff ff       	jmp    1021fc <__alltraps>

001026e4 <vector135>:
.globl vector135
vector135:
  pushl $0
  1026e4:	6a 00                	push   $0x0
  pushl $135
  1026e6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1026eb:	e9 0c fb ff ff       	jmp    1021fc <__alltraps>

001026f0 <vector136>:
.globl vector136
vector136:
  pushl $0
  1026f0:	6a 00                	push   $0x0
  pushl $136
  1026f2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1026f7:	e9 00 fb ff ff       	jmp    1021fc <__alltraps>

001026fc <vector137>:
.globl vector137
vector137:
  pushl $0
  1026fc:	6a 00                	push   $0x0
  pushl $137
  1026fe:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102703:	e9 f4 fa ff ff       	jmp    1021fc <__alltraps>

00102708 <vector138>:
.globl vector138
vector138:
  pushl $0
  102708:	6a 00                	push   $0x0
  pushl $138
  10270a:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10270f:	e9 e8 fa ff ff       	jmp    1021fc <__alltraps>

00102714 <vector139>:
.globl vector139
vector139:
  pushl $0
  102714:	6a 00                	push   $0x0
  pushl $139
  102716:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10271b:	e9 dc fa ff ff       	jmp    1021fc <__alltraps>

00102720 <vector140>:
.globl vector140
vector140:
  pushl $0
  102720:	6a 00                	push   $0x0
  pushl $140
  102722:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102727:	e9 d0 fa ff ff       	jmp    1021fc <__alltraps>

0010272c <vector141>:
.globl vector141
vector141:
  pushl $0
  10272c:	6a 00                	push   $0x0
  pushl $141
  10272e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102733:	e9 c4 fa ff ff       	jmp    1021fc <__alltraps>

00102738 <vector142>:
.globl vector142
vector142:
  pushl $0
  102738:	6a 00                	push   $0x0
  pushl $142
  10273a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10273f:	e9 b8 fa ff ff       	jmp    1021fc <__alltraps>

00102744 <vector143>:
.globl vector143
vector143:
  pushl $0
  102744:	6a 00                	push   $0x0
  pushl $143
  102746:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10274b:	e9 ac fa ff ff       	jmp    1021fc <__alltraps>

00102750 <vector144>:
.globl vector144
vector144:
  pushl $0
  102750:	6a 00                	push   $0x0
  pushl $144
  102752:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102757:	e9 a0 fa ff ff       	jmp    1021fc <__alltraps>

0010275c <vector145>:
.globl vector145
vector145:
  pushl $0
  10275c:	6a 00                	push   $0x0
  pushl $145
  10275e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102763:	e9 94 fa ff ff       	jmp    1021fc <__alltraps>

00102768 <vector146>:
.globl vector146
vector146:
  pushl $0
  102768:	6a 00                	push   $0x0
  pushl $146
  10276a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10276f:	e9 88 fa ff ff       	jmp    1021fc <__alltraps>

00102774 <vector147>:
.globl vector147
vector147:
  pushl $0
  102774:	6a 00                	push   $0x0
  pushl $147
  102776:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10277b:	e9 7c fa ff ff       	jmp    1021fc <__alltraps>

00102780 <vector148>:
.globl vector148
vector148:
  pushl $0
  102780:	6a 00                	push   $0x0
  pushl $148
  102782:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102787:	e9 70 fa ff ff       	jmp    1021fc <__alltraps>

0010278c <vector149>:
.globl vector149
vector149:
  pushl $0
  10278c:	6a 00                	push   $0x0
  pushl $149
  10278e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102793:	e9 64 fa ff ff       	jmp    1021fc <__alltraps>

00102798 <vector150>:
.globl vector150
vector150:
  pushl $0
  102798:	6a 00                	push   $0x0
  pushl $150
  10279a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10279f:	e9 58 fa ff ff       	jmp    1021fc <__alltraps>

001027a4 <vector151>:
.globl vector151
vector151:
  pushl $0
  1027a4:	6a 00                	push   $0x0
  pushl $151
  1027a6:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1027ab:	e9 4c fa ff ff       	jmp    1021fc <__alltraps>

001027b0 <vector152>:
.globl vector152
vector152:
  pushl $0
  1027b0:	6a 00                	push   $0x0
  pushl $152
  1027b2:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1027b7:	e9 40 fa ff ff       	jmp    1021fc <__alltraps>

001027bc <vector153>:
.globl vector153
vector153:
  pushl $0
  1027bc:	6a 00                	push   $0x0
  pushl $153
  1027be:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1027c3:	e9 34 fa ff ff       	jmp    1021fc <__alltraps>

001027c8 <vector154>:
.globl vector154
vector154:
  pushl $0
  1027c8:	6a 00                	push   $0x0
  pushl $154
  1027ca:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1027cf:	e9 28 fa ff ff       	jmp    1021fc <__alltraps>

001027d4 <vector155>:
.globl vector155
vector155:
  pushl $0
  1027d4:	6a 00                	push   $0x0
  pushl $155
  1027d6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1027db:	e9 1c fa ff ff       	jmp    1021fc <__alltraps>

001027e0 <vector156>:
.globl vector156
vector156:
  pushl $0
  1027e0:	6a 00                	push   $0x0
  pushl $156
  1027e2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1027e7:	e9 10 fa ff ff       	jmp    1021fc <__alltraps>

001027ec <vector157>:
.globl vector157
vector157:
  pushl $0
  1027ec:	6a 00                	push   $0x0
  pushl $157
  1027ee:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1027f3:	e9 04 fa ff ff       	jmp    1021fc <__alltraps>

001027f8 <vector158>:
.globl vector158
vector158:
  pushl $0
  1027f8:	6a 00                	push   $0x0
  pushl $158
  1027fa:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1027ff:	e9 f8 f9 ff ff       	jmp    1021fc <__alltraps>

00102804 <vector159>:
.globl vector159
vector159:
  pushl $0
  102804:	6a 00                	push   $0x0
  pushl $159
  102806:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10280b:	e9 ec f9 ff ff       	jmp    1021fc <__alltraps>

00102810 <vector160>:
.globl vector160
vector160:
  pushl $0
  102810:	6a 00                	push   $0x0
  pushl $160
  102812:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102817:	e9 e0 f9 ff ff       	jmp    1021fc <__alltraps>

0010281c <vector161>:
.globl vector161
vector161:
  pushl $0
  10281c:	6a 00                	push   $0x0
  pushl $161
  10281e:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102823:	e9 d4 f9 ff ff       	jmp    1021fc <__alltraps>

00102828 <vector162>:
.globl vector162
vector162:
  pushl $0
  102828:	6a 00                	push   $0x0
  pushl $162
  10282a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10282f:	e9 c8 f9 ff ff       	jmp    1021fc <__alltraps>

00102834 <vector163>:
.globl vector163
vector163:
  pushl $0
  102834:	6a 00                	push   $0x0
  pushl $163
  102836:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10283b:	e9 bc f9 ff ff       	jmp    1021fc <__alltraps>

00102840 <vector164>:
.globl vector164
vector164:
  pushl $0
  102840:	6a 00                	push   $0x0
  pushl $164
  102842:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102847:	e9 b0 f9 ff ff       	jmp    1021fc <__alltraps>

0010284c <vector165>:
.globl vector165
vector165:
  pushl $0
  10284c:	6a 00                	push   $0x0
  pushl $165
  10284e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102853:	e9 a4 f9 ff ff       	jmp    1021fc <__alltraps>

00102858 <vector166>:
.globl vector166
vector166:
  pushl $0
  102858:	6a 00                	push   $0x0
  pushl $166
  10285a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10285f:	e9 98 f9 ff ff       	jmp    1021fc <__alltraps>

00102864 <vector167>:
.globl vector167
vector167:
  pushl $0
  102864:	6a 00                	push   $0x0
  pushl $167
  102866:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10286b:	e9 8c f9 ff ff       	jmp    1021fc <__alltraps>

00102870 <vector168>:
.globl vector168
vector168:
  pushl $0
  102870:	6a 00                	push   $0x0
  pushl $168
  102872:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102877:	e9 80 f9 ff ff       	jmp    1021fc <__alltraps>

0010287c <vector169>:
.globl vector169
vector169:
  pushl $0
  10287c:	6a 00                	push   $0x0
  pushl $169
  10287e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102883:	e9 74 f9 ff ff       	jmp    1021fc <__alltraps>

00102888 <vector170>:
.globl vector170
vector170:
  pushl $0
  102888:	6a 00                	push   $0x0
  pushl $170
  10288a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10288f:	e9 68 f9 ff ff       	jmp    1021fc <__alltraps>

00102894 <vector171>:
.globl vector171
vector171:
  pushl $0
  102894:	6a 00                	push   $0x0
  pushl $171
  102896:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10289b:	e9 5c f9 ff ff       	jmp    1021fc <__alltraps>

001028a0 <vector172>:
.globl vector172
vector172:
  pushl $0
  1028a0:	6a 00                	push   $0x0
  pushl $172
  1028a2:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1028a7:	e9 50 f9 ff ff       	jmp    1021fc <__alltraps>

001028ac <vector173>:
.globl vector173
vector173:
  pushl $0
  1028ac:	6a 00                	push   $0x0
  pushl $173
  1028ae:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1028b3:	e9 44 f9 ff ff       	jmp    1021fc <__alltraps>

001028b8 <vector174>:
.globl vector174
vector174:
  pushl $0
  1028b8:	6a 00                	push   $0x0
  pushl $174
  1028ba:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1028bf:	e9 38 f9 ff ff       	jmp    1021fc <__alltraps>

001028c4 <vector175>:
.globl vector175
vector175:
  pushl $0
  1028c4:	6a 00                	push   $0x0
  pushl $175
  1028c6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1028cb:	e9 2c f9 ff ff       	jmp    1021fc <__alltraps>

001028d0 <vector176>:
.globl vector176
vector176:
  pushl $0
  1028d0:	6a 00                	push   $0x0
  pushl $176
  1028d2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1028d7:	e9 20 f9 ff ff       	jmp    1021fc <__alltraps>

001028dc <vector177>:
.globl vector177
vector177:
  pushl $0
  1028dc:	6a 00                	push   $0x0
  pushl $177
  1028de:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1028e3:	e9 14 f9 ff ff       	jmp    1021fc <__alltraps>

001028e8 <vector178>:
.globl vector178
vector178:
  pushl $0
  1028e8:	6a 00                	push   $0x0
  pushl $178
  1028ea:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1028ef:	e9 08 f9 ff ff       	jmp    1021fc <__alltraps>

001028f4 <vector179>:
.globl vector179
vector179:
  pushl $0
  1028f4:	6a 00                	push   $0x0
  pushl $179
  1028f6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1028fb:	e9 fc f8 ff ff       	jmp    1021fc <__alltraps>

00102900 <vector180>:
.globl vector180
vector180:
  pushl $0
  102900:	6a 00                	push   $0x0
  pushl $180
  102902:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102907:	e9 f0 f8 ff ff       	jmp    1021fc <__alltraps>

0010290c <vector181>:
.globl vector181
vector181:
  pushl $0
  10290c:	6a 00                	push   $0x0
  pushl $181
  10290e:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102913:	e9 e4 f8 ff ff       	jmp    1021fc <__alltraps>

00102918 <vector182>:
.globl vector182
vector182:
  pushl $0
  102918:	6a 00                	push   $0x0
  pushl $182
  10291a:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10291f:	e9 d8 f8 ff ff       	jmp    1021fc <__alltraps>

00102924 <vector183>:
.globl vector183
vector183:
  pushl $0
  102924:	6a 00                	push   $0x0
  pushl $183
  102926:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10292b:	e9 cc f8 ff ff       	jmp    1021fc <__alltraps>

00102930 <vector184>:
.globl vector184
vector184:
  pushl $0
  102930:	6a 00                	push   $0x0
  pushl $184
  102932:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102937:	e9 c0 f8 ff ff       	jmp    1021fc <__alltraps>

0010293c <vector185>:
.globl vector185
vector185:
  pushl $0
  10293c:	6a 00                	push   $0x0
  pushl $185
  10293e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102943:	e9 b4 f8 ff ff       	jmp    1021fc <__alltraps>

00102948 <vector186>:
.globl vector186
vector186:
  pushl $0
  102948:	6a 00                	push   $0x0
  pushl $186
  10294a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10294f:	e9 a8 f8 ff ff       	jmp    1021fc <__alltraps>

00102954 <vector187>:
.globl vector187
vector187:
  pushl $0
  102954:	6a 00                	push   $0x0
  pushl $187
  102956:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10295b:	e9 9c f8 ff ff       	jmp    1021fc <__alltraps>

00102960 <vector188>:
.globl vector188
vector188:
  pushl $0
  102960:	6a 00                	push   $0x0
  pushl $188
  102962:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102967:	e9 90 f8 ff ff       	jmp    1021fc <__alltraps>

0010296c <vector189>:
.globl vector189
vector189:
  pushl $0
  10296c:	6a 00                	push   $0x0
  pushl $189
  10296e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102973:	e9 84 f8 ff ff       	jmp    1021fc <__alltraps>

00102978 <vector190>:
.globl vector190
vector190:
  pushl $0
  102978:	6a 00                	push   $0x0
  pushl $190
  10297a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10297f:	e9 78 f8 ff ff       	jmp    1021fc <__alltraps>

00102984 <vector191>:
.globl vector191
vector191:
  pushl $0
  102984:	6a 00                	push   $0x0
  pushl $191
  102986:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10298b:	e9 6c f8 ff ff       	jmp    1021fc <__alltraps>

00102990 <vector192>:
.globl vector192
vector192:
  pushl $0
  102990:	6a 00                	push   $0x0
  pushl $192
  102992:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102997:	e9 60 f8 ff ff       	jmp    1021fc <__alltraps>

0010299c <vector193>:
.globl vector193
vector193:
  pushl $0
  10299c:	6a 00                	push   $0x0
  pushl $193
  10299e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1029a3:	e9 54 f8 ff ff       	jmp    1021fc <__alltraps>

001029a8 <vector194>:
.globl vector194
vector194:
  pushl $0
  1029a8:	6a 00                	push   $0x0
  pushl $194
  1029aa:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1029af:	e9 48 f8 ff ff       	jmp    1021fc <__alltraps>

001029b4 <vector195>:
.globl vector195
vector195:
  pushl $0
  1029b4:	6a 00                	push   $0x0
  pushl $195
  1029b6:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1029bb:	e9 3c f8 ff ff       	jmp    1021fc <__alltraps>

001029c0 <vector196>:
.globl vector196
vector196:
  pushl $0
  1029c0:	6a 00                	push   $0x0
  pushl $196
  1029c2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1029c7:	e9 30 f8 ff ff       	jmp    1021fc <__alltraps>

001029cc <vector197>:
.globl vector197
vector197:
  pushl $0
  1029cc:	6a 00                	push   $0x0
  pushl $197
  1029ce:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1029d3:	e9 24 f8 ff ff       	jmp    1021fc <__alltraps>

001029d8 <vector198>:
.globl vector198
vector198:
  pushl $0
  1029d8:	6a 00                	push   $0x0
  pushl $198
  1029da:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1029df:	e9 18 f8 ff ff       	jmp    1021fc <__alltraps>

001029e4 <vector199>:
.globl vector199
vector199:
  pushl $0
  1029e4:	6a 00                	push   $0x0
  pushl $199
  1029e6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1029eb:	e9 0c f8 ff ff       	jmp    1021fc <__alltraps>

001029f0 <vector200>:
.globl vector200
vector200:
  pushl $0
  1029f0:	6a 00                	push   $0x0
  pushl $200
  1029f2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1029f7:	e9 00 f8 ff ff       	jmp    1021fc <__alltraps>

001029fc <vector201>:
.globl vector201
vector201:
  pushl $0
  1029fc:	6a 00                	push   $0x0
  pushl $201
  1029fe:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102a03:	e9 f4 f7 ff ff       	jmp    1021fc <__alltraps>

00102a08 <vector202>:
.globl vector202
vector202:
  pushl $0
  102a08:	6a 00                	push   $0x0
  pushl $202
  102a0a:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102a0f:	e9 e8 f7 ff ff       	jmp    1021fc <__alltraps>

00102a14 <vector203>:
.globl vector203
vector203:
  pushl $0
  102a14:	6a 00                	push   $0x0
  pushl $203
  102a16:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102a1b:	e9 dc f7 ff ff       	jmp    1021fc <__alltraps>

00102a20 <vector204>:
.globl vector204
vector204:
  pushl $0
  102a20:	6a 00                	push   $0x0
  pushl $204
  102a22:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102a27:	e9 d0 f7 ff ff       	jmp    1021fc <__alltraps>

00102a2c <vector205>:
.globl vector205
vector205:
  pushl $0
  102a2c:	6a 00                	push   $0x0
  pushl $205
  102a2e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102a33:	e9 c4 f7 ff ff       	jmp    1021fc <__alltraps>

00102a38 <vector206>:
.globl vector206
vector206:
  pushl $0
  102a38:	6a 00                	push   $0x0
  pushl $206
  102a3a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102a3f:	e9 b8 f7 ff ff       	jmp    1021fc <__alltraps>

00102a44 <vector207>:
.globl vector207
vector207:
  pushl $0
  102a44:	6a 00                	push   $0x0
  pushl $207
  102a46:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102a4b:	e9 ac f7 ff ff       	jmp    1021fc <__alltraps>

00102a50 <vector208>:
.globl vector208
vector208:
  pushl $0
  102a50:	6a 00                	push   $0x0
  pushl $208
  102a52:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102a57:	e9 a0 f7 ff ff       	jmp    1021fc <__alltraps>

00102a5c <vector209>:
.globl vector209
vector209:
  pushl $0
  102a5c:	6a 00                	push   $0x0
  pushl $209
  102a5e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102a63:	e9 94 f7 ff ff       	jmp    1021fc <__alltraps>

00102a68 <vector210>:
.globl vector210
vector210:
  pushl $0
  102a68:	6a 00                	push   $0x0
  pushl $210
  102a6a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102a6f:	e9 88 f7 ff ff       	jmp    1021fc <__alltraps>

00102a74 <vector211>:
.globl vector211
vector211:
  pushl $0
  102a74:	6a 00                	push   $0x0
  pushl $211
  102a76:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102a7b:	e9 7c f7 ff ff       	jmp    1021fc <__alltraps>

00102a80 <vector212>:
.globl vector212
vector212:
  pushl $0
  102a80:	6a 00                	push   $0x0
  pushl $212
  102a82:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102a87:	e9 70 f7 ff ff       	jmp    1021fc <__alltraps>

00102a8c <vector213>:
.globl vector213
vector213:
  pushl $0
  102a8c:	6a 00                	push   $0x0
  pushl $213
  102a8e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102a93:	e9 64 f7 ff ff       	jmp    1021fc <__alltraps>

00102a98 <vector214>:
.globl vector214
vector214:
  pushl $0
  102a98:	6a 00                	push   $0x0
  pushl $214
  102a9a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102a9f:	e9 58 f7 ff ff       	jmp    1021fc <__alltraps>

00102aa4 <vector215>:
.globl vector215
vector215:
  pushl $0
  102aa4:	6a 00                	push   $0x0
  pushl $215
  102aa6:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102aab:	e9 4c f7 ff ff       	jmp    1021fc <__alltraps>

00102ab0 <vector216>:
.globl vector216
vector216:
  pushl $0
  102ab0:	6a 00                	push   $0x0
  pushl $216
  102ab2:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102ab7:	e9 40 f7 ff ff       	jmp    1021fc <__alltraps>

00102abc <vector217>:
.globl vector217
vector217:
  pushl $0
  102abc:	6a 00                	push   $0x0
  pushl $217
  102abe:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102ac3:	e9 34 f7 ff ff       	jmp    1021fc <__alltraps>

00102ac8 <vector218>:
.globl vector218
vector218:
  pushl $0
  102ac8:	6a 00                	push   $0x0
  pushl $218
  102aca:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102acf:	e9 28 f7 ff ff       	jmp    1021fc <__alltraps>

00102ad4 <vector219>:
.globl vector219
vector219:
  pushl $0
  102ad4:	6a 00                	push   $0x0
  pushl $219
  102ad6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102adb:	e9 1c f7 ff ff       	jmp    1021fc <__alltraps>

00102ae0 <vector220>:
.globl vector220
vector220:
  pushl $0
  102ae0:	6a 00                	push   $0x0
  pushl $220
  102ae2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102ae7:	e9 10 f7 ff ff       	jmp    1021fc <__alltraps>

00102aec <vector221>:
.globl vector221
vector221:
  pushl $0
  102aec:	6a 00                	push   $0x0
  pushl $221
  102aee:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102af3:	e9 04 f7 ff ff       	jmp    1021fc <__alltraps>

00102af8 <vector222>:
.globl vector222
vector222:
  pushl $0
  102af8:	6a 00                	push   $0x0
  pushl $222
  102afa:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102aff:	e9 f8 f6 ff ff       	jmp    1021fc <__alltraps>

00102b04 <vector223>:
.globl vector223
vector223:
  pushl $0
  102b04:	6a 00                	push   $0x0
  pushl $223
  102b06:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102b0b:	e9 ec f6 ff ff       	jmp    1021fc <__alltraps>

00102b10 <vector224>:
.globl vector224
vector224:
  pushl $0
  102b10:	6a 00                	push   $0x0
  pushl $224
  102b12:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102b17:	e9 e0 f6 ff ff       	jmp    1021fc <__alltraps>

00102b1c <vector225>:
.globl vector225
vector225:
  pushl $0
  102b1c:	6a 00                	push   $0x0
  pushl $225
  102b1e:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102b23:	e9 d4 f6 ff ff       	jmp    1021fc <__alltraps>

00102b28 <vector226>:
.globl vector226
vector226:
  pushl $0
  102b28:	6a 00                	push   $0x0
  pushl $226
  102b2a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102b2f:	e9 c8 f6 ff ff       	jmp    1021fc <__alltraps>

00102b34 <vector227>:
.globl vector227
vector227:
  pushl $0
  102b34:	6a 00                	push   $0x0
  pushl $227
  102b36:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102b3b:	e9 bc f6 ff ff       	jmp    1021fc <__alltraps>

00102b40 <vector228>:
.globl vector228
vector228:
  pushl $0
  102b40:	6a 00                	push   $0x0
  pushl $228
  102b42:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102b47:	e9 b0 f6 ff ff       	jmp    1021fc <__alltraps>

00102b4c <vector229>:
.globl vector229
vector229:
  pushl $0
  102b4c:	6a 00                	push   $0x0
  pushl $229
  102b4e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102b53:	e9 a4 f6 ff ff       	jmp    1021fc <__alltraps>

00102b58 <vector230>:
.globl vector230
vector230:
  pushl $0
  102b58:	6a 00                	push   $0x0
  pushl $230
  102b5a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102b5f:	e9 98 f6 ff ff       	jmp    1021fc <__alltraps>

00102b64 <vector231>:
.globl vector231
vector231:
  pushl $0
  102b64:	6a 00                	push   $0x0
  pushl $231
  102b66:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102b6b:	e9 8c f6 ff ff       	jmp    1021fc <__alltraps>

00102b70 <vector232>:
.globl vector232
vector232:
  pushl $0
  102b70:	6a 00                	push   $0x0
  pushl $232
  102b72:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102b77:	e9 80 f6 ff ff       	jmp    1021fc <__alltraps>

00102b7c <vector233>:
.globl vector233
vector233:
  pushl $0
  102b7c:	6a 00                	push   $0x0
  pushl $233
  102b7e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102b83:	e9 74 f6 ff ff       	jmp    1021fc <__alltraps>

00102b88 <vector234>:
.globl vector234
vector234:
  pushl $0
  102b88:	6a 00                	push   $0x0
  pushl $234
  102b8a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102b8f:	e9 68 f6 ff ff       	jmp    1021fc <__alltraps>

00102b94 <vector235>:
.globl vector235
vector235:
  pushl $0
  102b94:	6a 00                	push   $0x0
  pushl $235
  102b96:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102b9b:	e9 5c f6 ff ff       	jmp    1021fc <__alltraps>

00102ba0 <vector236>:
.globl vector236
vector236:
  pushl $0
  102ba0:	6a 00                	push   $0x0
  pushl $236
  102ba2:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102ba7:	e9 50 f6 ff ff       	jmp    1021fc <__alltraps>

00102bac <vector237>:
.globl vector237
vector237:
  pushl $0
  102bac:	6a 00                	push   $0x0
  pushl $237
  102bae:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102bb3:	e9 44 f6 ff ff       	jmp    1021fc <__alltraps>

00102bb8 <vector238>:
.globl vector238
vector238:
  pushl $0
  102bb8:	6a 00                	push   $0x0
  pushl $238
  102bba:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102bbf:	e9 38 f6 ff ff       	jmp    1021fc <__alltraps>

00102bc4 <vector239>:
.globl vector239
vector239:
  pushl $0
  102bc4:	6a 00                	push   $0x0
  pushl $239
  102bc6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102bcb:	e9 2c f6 ff ff       	jmp    1021fc <__alltraps>

00102bd0 <vector240>:
.globl vector240
vector240:
  pushl $0
  102bd0:	6a 00                	push   $0x0
  pushl $240
  102bd2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102bd7:	e9 20 f6 ff ff       	jmp    1021fc <__alltraps>

00102bdc <vector241>:
.globl vector241
vector241:
  pushl $0
  102bdc:	6a 00                	push   $0x0
  pushl $241
  102bde:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102be3:	e9 14 f6 ff ff       	jmp    1021fc <__alltraps>

00102be8 <vector242>:
.globl vector242
vector242:
  pushl $0
  102be8:	6a 00                	push   $0x0
  pushl $242
  102bea:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102bef:	e9 08 f6 ff ff       	jmp    1021fc <__alltraps>

00102bf4 <vector243>:
.globl vector243
vector243:
  pushl $0
  102bf4:	6a 00                	push   $0x0
  pushl $243
  102bf6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102bfb:	e9 fc f5 ff ff       	jmp    1021fc <__alltraps>

00102c00 <vector244>:
.globl vector244
vector244:
  pushl $0
  102c00:	6a 00                	push   $0x0
  pushl $244
  102c02:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102c07:	e9 f0 f5 ff ff       	jmp    1021fc <__alltraps>

00102c0c <vector245>:
.globl vector245
vector245:
  pushl $0
  102c0c:	6a 00                	push   $0x0
  pushl $245
  102c0e:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102c13:	e9 e4 f5 ff ff       	jmp    1021fc <__alltraps>

00102c18 <vector246>:
.globl vector246
vector246:
  pushl $0
  102c18:	6a 00                	push   $0x0
  pushl $246
  102c1a:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102c1f:	e9 d8 f5 ff ff       	jmp    1021fc <__alltraps>

00102c24 <vector247>:
.globl vector247
vector247:
  pushl $0
  102c24:	6a 00                	push   $0x0
  pushl $247
  102c26:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102c2b:	e9 cc f5 ff ff       	jmp    1021fc <__alltraps>

00102c30 <vector248>:
.globl vector248
vector248:
  pushl $0
  102c30:	6a 00                	push   $0x0
  pushl $248
  102c32:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102c37:	e9 c0 f5 ff ff       	jmp    1021fc <__alltraps>

00102c3c <vector249>:
.globl vector249
vector249:
  pushl $0
  102c3c:	6a 00                	push   $0x0
  pushl $249
  102c3e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102c43:	e9 b4 f5 ff ff       	jmp    1021fc <__alltraps>

00102c48 <vector250>:
.globl vector250
vector250:
  pushl $0
  102c48:	6a 00                	push   $0x0
  pushl $250
  102c4a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102c4f:	e9 a8 f5 ff ff       	jmp    1021fc <__alltraps>

00102c54 <vector251>:
.globl vector251
vector251:
  pushl $0
  102c54:	6a 00                	push   $0x0
  pushl $251
  102c56:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102c5b:	e9 9c f5 ff ff       	jmp    1021fc <__alltraps>

00102c60 <vector252>:
.globl vector252
vector252:
  pushl $0
  102c60:	6a 00                	push   $0x0
  pushl $252
  102c62:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102c67:	e9 90 f5 ff ff       	jmp    1021fc <__alltraps>

00102c6c <vector253>:
.globl vector253
vector253:
  pushl $0
  102c6c:	6a 00                	push   $0x0
  pushl $253
  102c6e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102c73:	e9 84 f5 ff ff       	jmp    1021fc <__alltraps>

00102c78 <vector254>:
.globl vector254
vector254:
  pushl $0
  102c78:	6a 00                	push   $0x0
  pushl $254
  102c7a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102c7f:	e9 78 f5 ff ff       	jmp    1021fc <__alltraps>

00102c84 <vector255>:
.globl vector255
vector255:
  pushl $0
  102c84:	6a 00                	push   $0x0
  pushl $255
  102c86:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102c8b:	e9 6c f5 ff ff       	jmp    1021fc <__alltraps>

00102c90 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102c90:	55                   	push   %ebp
  102c91:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102c93:	8b 15 00 cf 11 00    	mov    0x11cf00,%edx
  102c99:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9c:	29 d0                	sub    %edx,%eax
  102c9e:	c1 f8 02             	sar    $0x2,%eax
  102ca1:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102ca7:	5d                   	pop    %ebp
  102ca8:	c3                   	ret    

00102ca9 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102ca9:	55                   	push   %ebp
  102caa:	89 e5                	mov    %esp,%ebp
  102cac:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102caf:	8b 45 08             	mov    0x8(%ebp),%eax
  102cb2:	89 04 24             	mov    %eax,(%esp)
  102cb5:	e8 d6 ff ff ff       	call   102c90 <page2ppn>
  102cba:	c1 e0 0c             	shl    $0xc,%eax
}
  102cbd:	89 ec                	mov    %ebp,%esp
  102cbf:	5d                   	pop    %ebp
  102cc0:	c3                   	ret    

00102cc1 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102cc1:	55                   	push   %ebp
  102cc2:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc7:	8b 00                	mov    (%eax),%eax
}
  102cc9:	5d                   	pop    %ebp
  102cca:	c3                   	ret    

00102ccb <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102ccb:	55                   	push   %ebp
  102ccc:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102cce:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cd4:	89 10                	mov    %edx,(%eax)
}
  102cd6:	90                   	nop
  102cd7:	5d                   	pop    %ebp
  102cd8:	c3                   	ret    

00102cd9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102cd9:	55                   	push   %ebp
  102cda:	89 e5                	mov    %esp,%ebp
  102cdc:	83 ec 10             	sub    $0x10,%esp
  102cdf:	c7 45 fc e0 ce 11 00 	movl   $0x11cee0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102ce6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ce9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102cec:	89 50 04             	mov    %edx,0x4(%eax)
  102cef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102cf2:	8b 50 04             	mov    0x4(%eax),%edx
  102cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102cf8:	89 10                	mov    %edx,(%eax)
}
  102cfa:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  102cfb:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  102d02:	00 00 00 
}
  102d05:	90                   	nop
  102d06:	89 ec                	mov    %ebp,%esp
  102d08:	5d                   	pop    %ebp
  102d09:	c3                   	ret    

00102d0a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102d0a:	55                   	push   %ebp
  102d0b:	89 e5                	mov    %esp,%ebp
  102d0d:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  102d10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d14:	75 24                	jne    102d3a <default_init_memmap+0x30>
  102d16:	c7 44 24 0c 70 6b 10 	movl   $0x106b70,0xc(%esp)
  102d1d:	00 
  102d1e:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  102d25:	00 
  102d26:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102d2d:	00 
  102d2e:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  102d35:	e8 e3 df ff ff       	call   100d1d <__panic>
    struct Page *p = base;
  102d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102d40:	eb 7d                	jmp    102dbf <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d45:	83 c0 04             	add    $0x4,%eax
  102d48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102d4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d55:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d58:	0f a3 10             	bt     %edx,(%eax)
  102d5b:	19 c0                	sbb    %eax,%eax
  102d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102d60:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d64:	0f 95 c0             	setne  %al
  102d67:	0f b6 c0             	movzbl %al,%eax
  102d6a:	85 c0                	test   %eax,%eax
  102d6c:	75 24                	jne    102d92 <default_init_memmap+0x88>
  102d6e:	c7 44 24 0c a1 6b 10 	movl   $0x106ba1,0xc(%esp)
  102d75:	00 
  102d76:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  102d7d:	00 
  102d7e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102d85:	00 
  102d86:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  102d8d:	e8 8b df ff ff       	call   100d1d <__panic>
        p->flags = p->property = 0;
  102d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d9f:	8b 50 08             	mov    0x8(%eax),%edx
  102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102da5:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102daf:	00 
  102db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102db3:	89 04 24             	mov    %eax,(%esp)
  102db6:	e8 10 ff ff ff       	call   102ccb <set_page_ref>
    for (; p != base + n; p ++) {
  102dbb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dc2:	89 d0                	mov    %edx,%eax
  102dc4:	c1 e0 02             	shl    $0x2,%eax
  102dc7:	01 d0                	add    %edx,%eax
  102dc9:	c1 e0 02             	shl    $0x2,%eax
  102dcc:	89 c2                	mov    %eax,%edx
  102dce:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd1:	01 d0                	add    %edx,%eax
  102dd3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102dd6:	0f 85 66 ff ff ff    	jne    102d42 <default_init_memmap+0x38>
    }
    base->property = n;
  102ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  102ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
  102de2:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102de5:	8b 45 08             	mov    0x8(%ebp),%eax
  102de8:	83 c0 04             	add    $0x4,%eax
  102deb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  102df2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102df5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102df8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102dfb:	0f ab 10             	bts    %edx,(%eax)
}
  102dfe:	90                   	nop
    nr_free += n;
  102dff:	8b 15 e8 ce 11 00    	mov    0x11cee8,%edx
  102e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e08:	01 d0                	add    %edx,%eax
  102e0a:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
    list_add(&free_list, &(base->page_link));
  102e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  102e12:	83 c0 0c             	add    $0xc,%eax
  102e15:	c7 45 e4 e0 ce 11 00 	movl   $0x11cee0,-0x1c(%ebp)
  102e1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e22:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e28:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e2e:	8b 40 04             	mov    0x4(%eax),%eax
  102e31:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102e34:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e37:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e3a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102e3d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102e40:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102e43:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e46:	89 10                	mov    %edx,(%eax)
  102e48:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102e4b:	8b 10                	mov    (%eax),%edx
  102e4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e50:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102e56:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102e59:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102e5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102e5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102e62:	89 10                	mov    %edx,(%eax)
}
  102e64:	90                   	nop
}
  102e65:	90                   	nop
}
  102e66:	90                   	nop
}
  102e67:	90                   	nop
  102e68:	89 ec                	mov    %ebp,%esp
  102e6a:	5d                   	pop    %ebp
  102e6b:	c3                   	ret    

00102e6c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102e6c:	55                   	push   %ebp
  102e6d:	89 e5                	mov    %esp,%ebp
  102e6f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102e72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102e76:	75 24                	jne    102e9c <default_alloc_pages+0x30>
  102e78:	c7 44 24 0c 70 6b 10 	movl   $0x106b70,0xc(%esp)
  102e7f:	00 
  102e80:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  102e87:	00 
  102e88:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102e8f:	00 
  102e90:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  102e97:	e8 81 de ff ff       	call   100d1d <__panic>
    if (n > nr_free) {
  102e9c:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  102ea1:	39 45 08             	cmp    %eax,0x8(%ebp)
  102ea4:	76 0a                	jbe    102eb0 <default_alloc_pages+0x44>
        return NULL;
  102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  102eab:	e9 4e 01 00 00       	jmp    102ffe <default_alloc_pages+0x192>
    }
    struct Page *page = NULL;
  102eb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    //开始遍历空闲链表
    list_entry_t *le = &free_list;
  102eb7:	c7 45 f0 e0 ce 11 00 	movl   $0x11cee0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102ebe:	eb 1c                	jmp    102edc <default_alloc_pages+0x70>
    	//找到当前链表指向的页表，如果这个内存页数大于我们需要的页数，则直接从这个内存块取n页
        struct Page *p = le2page(le, page_link);
  102ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec3:	83 e8 0c             	sub    $0xc,%eax
  102ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ecc:	8b 40 08             	mov    0x8(%eax),%eax
  102ecf:	39 45 08             	cmp    %eax,0x8(%ebp)
  102ed2:	77 08                	ja     102edc <default_alloc_pages+0x70>
            page = p;
  102ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            //SetPageReserved(page);
            break;
  102eda:	eb 18                	jmp    102ef4 <default_alloc_pages+0x88>
  102edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102edf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  102ee2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ee5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  102ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eeb:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  102ef2:	75 cc                	jne    102ec0 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  102ef4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102ef8:	0f 84 fd 00 00 00    	je     102ffb <default_alloc_pages+0x18f>
        //list_del(&(page->page_link));
        if (page->property > n) {
  102efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f01:	8b 40 08             	mov    0x8(%eax),%eax
  102f04:	39 45 08             	cmp    %eax,0x8(%ebp)
  102f07:	0f 83 9a 00 00 00    	jae    102fa7 <default_alloc_pages+0x13b>
        	//因为我们取了n页，内存块可能还有部分内存页，需要当前内存块头偏移n个`Page`位置就是
        	//内存块剩下的页组成新的内存块结构，新的页头描述这个小内存块
            struct Page *p = page + n;
  102f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  102f10:	89 d0                	mov    %edx,%eax
  102f12:	c1 e0 02             	shl    $0x2,%eax
  102f15:	01 d0                	add    %edx,%eax
  102f17:	c1 e0 02             	shl    $0x2,%eax
  102f1a:	89 c2                	mov    %eax,%edx
  102f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f1f:	01 d0                	add    %edx,%eax
  102f21:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f27:	8b 40 08             	mov    0x8(%eax),%eax
  102f2a:	2b 45 08             	sub    0x8(%ebp),%eax
  102f2d:	89 c2                	mov    %eax,%edx
  102f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f32:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);//记得做这步，把property设为1，否则出错
  102f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f38:	83 c0 04             	add    $0x4,%eax
  102f3b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102f42:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102f45:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102f48:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102f4b:	0f ab 10             	bts    %edx,(%eax)
}
  102f4e:	90                   	nop
            //ClearPageReserved(p);
            //往空闲链表里加入这个新的小内存
            list_add(&free_list, &(p->page_link));
  102f4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f52:	83 c0 0c             	add    $0xc,%eax
  102f55:	c7 45 e0 e0 ce 11 00 	movl   $0x11cee0,-0x20(%ebp)
  102f5c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f62:	89 45 d8             	mov    %eax,-0x28(%ebp)
  102f65:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102f68:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  102f6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f6e:	8b 40 04             	mov    0x4(%eax),%eax
  102f71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f74:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102f77:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102f7a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102f7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  102f80:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f83:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f86:	89 10                	mov    %edx,(%eax)
  102f88:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f8b:	8b 10                	mov    (%eax),%edx
  102f8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102f90:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102f93:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f96:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102f99:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f9f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102fa2:	89 10                	mov    %edx,(%eax)
}
  102fa4:	90                   	nop
}
  102fa5:	90                   	nop
}
  102fa6:	90                   	nop
    }
        list_del(&(page->page_link));
  102fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102faa:	83 c0 0c             	add    $0xc,%eax
  102fad:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102fb0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102fb3:	8b 40 04             	mov    0x4(%eax),%eax
  102fb6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102fb9:	8b 12                	mov    (%edx),%edx
  102fbb:	89 55 b0             	mov    %edx,-0x50(%ebp)
  102fbe:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102fc1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102fc4:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102fc7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102fca:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102fcd:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102fd0:	89 10                	mov    %edx,(%eax)
}
  102fd2:	90                   	nop
}
  102fd3:	90                   	nop
        nr_free -= n;
  102fd4:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  102fd9:	2b 45 08             	sub    0x8(%ebp),%eax
  102fdc:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
        ClearPageProperty(page);
  102fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fe4:	83 c0 04             	add    $0x4,%eax
  102fe7:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  102fee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ff1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ff4:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ff7:	0f b3 10             	btr    %edx,(%eax)
}
  102ffa:	90                   	nop
    }
    return page;
  102ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102ffe:	89 ec                	mov    %ebp,%esp
  103000:	5d                   	pop    %ebp
  103001:	c3                   	ret    

00103002 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  103002:	55                   	push   %ebp
  103003:	89 e5                	mov    %esp,%ebp
  103005:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  10300b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10300f:	75 24                	jne    103035 <default_free_pages+0x33>
  103011:	c7 44 24 0c 70 6b 10 	movl   $0x106b70,0xc(%esp)
  103018:	00 
  103019:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103020:	00 
  103021:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  103028:	00 
  103029:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103030:	e8 e8 dc ff ff       	call   100d1d <__panic>
    struct Page *p = base;
  103035:	8b 45 08             	mov    0x8(%ebp),%eax
  103038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //首先遍历页表，把flags全部置0，并将ref清0，说明此时没有逻辑地址引用这块内存
    for (; p != base + n; p ++) {
  10303b:	e9 9d 00 00 00       	jmp    1030dd <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103043:	83 c0 04             	add    $0x4,%eax
  103046:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10304d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103050:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103053:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103056:	0f a3 10             	bt     %edx,(%eax)
  103059:	19 c0                	sbb    %eax,%eax
  10305b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10305e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103062:	0f 95 c0             	setne  %al
  103065:	0f b6 c0             	movzbl %al,%eax
  103068:	85 c0                	test   %eax,%eax
  10306a:	75 2c                	jne    103098 <default_free_pages+0x96>
  10306c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10306f:	83 c0 04             	add    $0x4,%eax
  103072:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  103079:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10307c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10307f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103082:	0f a3 10             	bt     %edx,(%eax)
  103085:	19 c0                	sbb    %eax,%eax
  103087:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10308a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10308e:	0f 95 c0             	setne  %al
  103091:	0f b6 c0             	movzbl %al,%eax
  103094:	85 c0                	test   %eax,%eax
  103096:	74 24                	je     1030bc <default_free_pages+0xba>
  103098:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  10309f:	00 
  1030a0:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1030a7:	00 
  1030a8:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  1030af:	00 
  1030b0:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1030b7:	e8 61 dc ff ff       	call   100d1d <__panic>
        p->flags = 0;
  1030bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030bf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  1030c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1030cd:	00 
  1030ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030d1:	89 04 24             	mov    %eax,(%esp)
  1030d4:	e8 f2 fb ff ff       	call   102ccb <set_page_ref>
    for (; p != base + n; p ++) {
  1030d9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1030dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030e0:	89 d0                	mov    %edx,%eax
  1030e2:	c1 e0 02             	shl    $0x2,%eax
  1030e5:	01 d0                	add    %edx,%eax
  1030e7:	c1 e0 02             	shl    $0x2,%eax
  1030ea:	89 c2                	mov    %eax,%edx
  1030ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ef:	01 d0                	add    %edx,%eax
  1030f1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1030f4:	0f 85 46 ff ff ff    	jne    103040 <default_free_pages+0x3e>
    }
    //同样的道理，我释放了n页，那么个n页形成新的一个大一点的内存块，我们需要设置这个内存块的第一个
    //页表描述内存块里有多少个页
    base->property = n;
  1030fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  103100:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  103103:	8b 45 08             	mov    0x8(%ebp),%eax
  103106:	83 c0 04             	add    $0x4,%eax
  103109:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103110:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103113:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103116:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103119:	0f ab 10             	bts    %edx,(%eax)
}
  10311c:	90                   	nop
  10311d:	c7 45 d4 e0 ce 11 00 	movl   $0x11cee0,-0x2c(%ebp)
    return listelm->next;
  103124:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103127:	8b 40 04             	mov    0x4(%eax),%eax
    //遍历空闲链表，目的找到有没有地址空间是连在一起的内存块，把他们合并
    list_entry_t *le = list_next(&free_list);
  10312a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10312d:	e9 0e 01 00 00       	jmp    103240 <default_free_pages+0x23e>
        p = le2page(le, page_link);
  103132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103135:	83 e8 0c             	sub    $0xc,%eax
  103138:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10313b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10313e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103141:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103144:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  103147:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  10314a:	8b 45 08             	mov    0x8(%ebp),%eax
  10314d:	8b 50 08             	mov    0x8(%eax),%edx
  103150:	89 d0                	mov    %edx,%eax
  103152:	c1 e0 02             	shl    $0x2,%eax
  103155:	01 d0                	add    %edx,%eax
  103157:	c1 e0 02             	shl    $0x2,%eax
  10315a:	89 c2                	mov    %eax,%edx
  10315c:	8b 45 08             	mov    0x8(%ebp),%eax
  10315f:	01 d0                	add    %edx,%eax
  103161:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103164:	75 5d                	jne    1031c3 <default_free_pages+0x1c1>
            base->property += p->property;
  103166:	8b 45 08             	mov    0x8(%ebp),%eax
  103169:	8b 50 08             	mov    0x8(%eax),%edx
  10316c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10316f:	8b 40 08             	mov    0x8(%eax),%eax
  103172:	01 c2                	add    %eax,%edx
  103174:	8b 45 08             	mov    0x8(%ebp),%eax
  103177:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  10317a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10317d:	83 c0 04             	add    $0x4,%eax
  103180:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  103187:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10318a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10318d:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103190:	0f b3 10             	btr    %edx,(%eax)
}
  103193:	90                   	nop
            list_del(&(p->page_link));
  103194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103197:	83 c0 0c             	add    $0xc,%eax
  10319a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10319d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1031a0:	8b 40 04             	mov    0x4(%eax),%eax
  1031a3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1031a6:	8b 12                	mov    (%edx),%edx
  1031a8:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1031ab:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  1031ae:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1031b1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1031b4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1031b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1031ba:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1031bd:	89 10                	mov    %edx,(%eax)
}
  1031bf:	90                   	nop
}
  1031c0:	90                   	nop
  1031c1:	eb 7d                	jmp    103240 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
  1031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031c6:	8b 50 08             	mov    0x8(%eax),%edx
  1031c9:	89 d0                	mov    %edx,%eax
  1031cb:	c1 e0 02             	shl    $0x2,%eax
  1031ce:	01 d0                	add    %edx,%eax
  1031d0:	c1 e0 02             	shl    $0x2,%eax
  1031d3:	89 c2                	mov    %eax,%edx
  1031d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031d8:	01 d0                	add    %edx,%eax
  1031da:	39 45 08             	cmp    %eax,0x8(%ebp)
  1031dd:	75 61                	jne    103240 <default_free_pages+0x23e>
            p->property += base->property;
  1031df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031e2:	8b 50 08             	mov    0x8(%eax),%edx
  1031e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1031e8:	8b 40 08             	mov    0x8(%eax),%eax
  1031eb:	01 c2                	add    %eax,%edx
  1031ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031f0:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  1031f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1031f6:	83 c0 04             	add    $0x4,%eax
  1031f9:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  103200:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103203:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103206:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103209:	0f b3 10             	btr    %edx,(%eax)
}
  10320c:	90                   	nop
            base = p;
  10320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103210:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  103213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103216:	83 c0 0c             	add    $0xc,%eax
  103219:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  10321c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10321f:	8b 40 04             	mov    0x4(%eax),%eax
  103222:	8b 55 b0             	mov    -0x50(%ebp),%edx
  103225:	8b 12                	mov    (%edx),%edx
  103227:	89 55 ac             	mov    %edx,-0x54(%ebp)
  10322a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  10322d:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103230:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103233:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103236:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103239:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10323c:	89 10                	mov    %edx,(%eax)
}
  10323e:	90                   	nop
}
  10323f:	90                   	nop
    while (le != &free_list) {
  103240:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  103247:	0f 85 e5 fe ff ff    	jne    103132 <default_free_pages+0x130>
        }
    }
    nr_free += n;
  10324d:	8b 15 e8 ce 11 00    	mov    0x11cee8,%edx
  103253:	8b 45 0c             	mov    0xc(%ebp),%eax
  103256:	01 d0                	add    %edx,%eax
  103258:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
  10325d:	c7 45 9c e0 ce 11 00 	movl   $0x11cee0,-0x64(%ebp)
    return listelm->next;
  103264:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103267:	8b 40 04             	mov    0x4(%eax),%eax
    //遍历空闲链表，因为空闲链表是from low to high
    //只需要遍历找打第一个地址比他高的，把释放的内存插入到他前面就行
    le = list_next(&free_list);
  10326a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  10326d:	eb 74                	jmp    1032e3 <default_free_pages+0x2e1>
        p = le2page(le, page_link);
  10326f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103272:	83 e8 0c             	sub    $0xc,%eax
  103275:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  103278:	8b 45 08             	mov    0x8(%ebp),%eax
  10327b:	8b 50 08             	mov    0x8(%eax),%edx
  10327e:	89 d0                	mov    %edx,%eax
  103280:	c1 e0 02             	shl    $0x2,%eax
  103283:	01 d0                	add    %edx,%eax
  103285:	c1 e0 02             	shl    $0x2,%eax
  103288:	89 c2                	mov    %eax,%edx
  10328a:	8b 45 08             	mov    0x8(%ebp),%eax
  10328d:	01 d0                	add    %edx,%eax
  10328f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103292:	72 40                	jb     1032d4 <default_free_pages+0x2d2>
            assert(base + base->property != p);
  103294:	8b 45 08             	mov    0x8(%ebp),%eax
  103297:	8b 50 08             	mov    0x8(%eax),%edx
  10329a:	89 d0                	mov    %edx,%eax
  10329c:	c1 e0 02             	shl    $0x2,%eax
  10329f:	01 d0                	add    %edx,%eax
  1032a1:	c1 e0 02             	shl    $0x2,%eax
  1032a4:	89 c2                	mov    %eax,%edx
  1032a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1032a9:	01 d0                	add    %edx,%eax
  1032ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1032ae:	75 3e                	jne    1032ee <default_free_pages+0x2ec>
  1032b0:	c7 44 24 0c d9 6b 10 	movl   $0x106bd9,0xc(%esp)
  1032b7:	00 
  1032b8:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1032bf:	00 
  1032c0:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  1032c7:	00 
  1032c8:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1032cf:	e8 49 da ff ff       	call   100d1d <__panic>
  1032d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032d7:	89 45 98             	mov    %eax,-0x68(%ebp)
  1032da:	8b 45 98             	mov    -0x68(%ebp),%eax
  1032dd:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  1032e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1032e3:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  1032ea:	75 83                	jne    10326f <default_free_pages+0x26d>
  1032ec:	eb 01                	jmp    1032ef <default_free_pages+0x2ed>
            break;
  1032ee:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
  1032ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f2:	8d 50 0c             	lea    0xc(%eax),%edx
  1032f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032f8:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1032fb:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1032fe:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103301:	8b 00                	mov    (%eax),%eax
  103303:	8b 55 90             	mov    -0x70(%ebp),%edx
  103306:	89 55 8c             	mov    %edx,-0x74(%ebp)
  103309:	89 45 88             	mov    %eax,-0x78(%ebp)
  10330c:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10330f:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  103312:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103315:	8b 55 8c             	mov    -0x74(%ebp),%edx
  103318:	89 10                	mov    %edx,(%eax)
  10331a:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10331d:	8b 10                	mov    (%eax),%edx
  10331f:	8b 45 88             	mov    -0x78(%ebp),%eax
  103322:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103325:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103328:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10332b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10332e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103331:	8b 55 88             	mov    -0x78(%ebp),%edx
  103334:	89 10                	mov    %edx,(%eax)
}
  103336:	90                   	nop
}
  103337:	90                   	nop
}
  103338:	90                   	nop
  103339:	89 ec                	mov    %ebp,%esp
  10333b:	5d                   	pop    %ebp
  10333c:	c3                   	ret    

0010333d <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  10333d:	55                   	push   %ebp
  10333e:	89 e5                	mov    %esp,%ebp
    return nr_free;
  103340:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
}
  103345:	5d                   	pop    %ebp
  103346:	c3                   	ret    

00103347 <basic_check>:

static void
basic_check(void) {
  103347:	55                   	push   %ebp
  103348:	89 e5                	mov    %esp,%ebp
  10334a:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  10334d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103357:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10335a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10335d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  103360:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103367:	e8 ed 0e 00 00       	call   104259 <alloc_pages>
  10336c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10336f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103373:	75 24                	jne    103399 <basic_check+0x52>
  103375:	c7 44 24 0c f4 6b 10 	movl   $0x106bf4,0xc(%esp)
  10337c:	00 
  10337d:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103384:	00 
  103385:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  10338c:	00 
  10338d:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103394:	e8 84 d9 ff ff       	call   100d1d <__panic>
    assert((p1 = alloc_page()) != NULL);
  103399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033a0:	e8 b4 0e 00 00       	call   104259 <alloc_pages>
  1033a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1033ac:	75 24                	jne    1033d2 <basic_check+0x8b>
  1033ae:	c7 44 24 0c 10 6c 10 	movl   $0x106c10,0xc(%esp)
  1033b5:	00 
  1033b6:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1033bd:	00 
  1033be:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  1033c5:	00 
  1033c6:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1033cd:	e8 4b d9 ff ff       	call   100d1d <__panic>
    assert((p2 = alloc_page()) != NULL);
  1033d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033d9:	e8 7b 0e 00 00       	call   104259 <alloc_pages>
  1033de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033e5:	75 24                	jne    10340b <basic_check+0xc4>
  1033e7:	c7 44 24 0c 2c 6c 10 	movl   $0x106c2c,0xc(%esp)
  1033ee:	00 
  1033ef:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1033f6:	00 
  1033f7:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  1033fe:	00 
  1033ff:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103406:	e8 12 d9 ff ff       	call   100d1d <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  10340b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10340e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103411:	74 10                	je     103423 <basic_check+0xdc>
  103413:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103416:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103419:	74 08                	je     103423 <basic_check+0xdc>
  10341b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10341e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103421:	75 24                	jne    103447 <basic_check+0x100>
  103423:	c7 44 24 0c 48 6c 10 	movl   $0x106c48,0xc(%esp)
  10342a:	00 
  10342b:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103432:	00 
  103433:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  10343a:	00 
  10343b:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103442:	e8 d6 d8 ff ff       	call   100d1d <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103447:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10344a:	89 04 24             	mov    %eax,(%esp)
  10344d:	e8 6f f8 ff ff       	call   102cc1 <page_ref>
  103452:	85 c0                	test   %eax,%eax
  103454:	75 1e                	jne    103474 <basic_check+0x12d>
  103456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103459:	89 04 24             	mov    %eax,(%esp)
  10345c:	e8 60 f8 ff ff       	call   102cc1 <page_ref>
  103461:	85 c0                	test   %eax,%eax
  103463:	75 0f                	jne    103474 <basic_check+0x12d>
  103465:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103468:	89 04 24             	mov    %eax,(%esp)
  10346b:	e8 51 f8 ff ff       	call   102cc1 <page_ref>
  103470:	85 c0                	test   %eax,%eax
  103472:	74 24                	je     103498 <basic_check+0x151>
  103474:	c7 44 24 0c 6c 6c 10 	movl   $0x106c6c,0xc(%esp)
  10347b:	00 
  10347c:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103483:	00 
  103484:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10348b:	00 
  10348c:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103493:	e8 85 d8 ff ff       	call   100d1d <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103498:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10349b:	89 04 24             	mov    %eax,(%esp)
  10349e:	e8 06 f8 ff ff       	call   102ca9 <page2pa>
  1034a3:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  1034a9:	c1 e2 0c             	shl    $0xc,%edx
  1034ac:	39 d0                	cmp    %edx,%eax
  1034ae:	72 24                	jb     1034d4 <basic_check+0x18d>
  1034b0:	c7 44 24 0c a8 6c 10 	movl   $0x106ca8,0xc(%esp)
  1034b7:	00 
  1034b8:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1034bf:	00 
  1034c0:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  1034c7:	00 
  1034c8:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1034cf:	e8 49 d8 ff ff       	call   100d1d <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1034d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d7:	89 04 24             	mov    %eax,(%esp)
  1034da:	e8 ca f7 ff ff       	call   102ca9 <page2pa>
  1034df:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  1034e5:	c1 e2 0c             	shl    $0xc,%edx
  1034e8:	39 d0                	cmp    %edx,%eax
  1034ea:	72 24                	jb     103510 <basic_check+0x1c9>
  1034ec:	c7 44 24 0c c5 6c 10 	movl   $0x106cc5,0xc(%esp)
  1034f3:	00 
  1034f4:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1034fb:	00 
  1034fc:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  103503:	00 
  103504:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10350b:	e8 0d d8 ff ff       	call   100d1d <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  103510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103513:	89 04 24             	mov    %eax,(%esp)
  103516:	e8 8e f7 ff ff       	call   102ca9 <page2pa>
  10351b:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  103521:	c1 e2 0c             	shl    $0xc,%edx
  103524:	39 d0                	cmp    %edx,%eax
  103526:	72 24                	jb     10354c <basic_check+0x205>
  103528:	c7 44 24 0c e2 6c 10 	movl   $0x106ce2,0xc(%esp)
  10352f:	00 
  103530:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103537:	00 
  103538:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  10353f:	00 
  103540:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103547:	e8 d1 d7 ff ff       	call   100d1d <__panic>

    list_entry_t free_list_store = free_list;
  10354c:	a1 e0 ce 11 00       	mov    0x11cee0,%eax
  103551:	8b 15 e4 ce 11 00    	mov    0x11cee4,%edx
  103557:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10355a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10355d:	c7 45 dc e0 ce 11 00 	movl   $0x11cee0,-0x24(%ebp)
    elm->prev = elm->next = elm;
  103564:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10356a:	89 50 04             	mov    %edx,0x4(%eax)
  10356d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103570:	8b 50 04             	mov    0x4(%eax),%edx
  103573:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103576:	89 10                	mov    %edx,(%eax)
}
  103578:	90                   	nop
  103579:	c7 45 e0 e0 ce 11 00 	movl   $0x11cee0,-0x20(%ebp)
    return list->next == list;
  103580:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103583:	8b 40 04             	mov    0x4(%eax),%eax
  103586:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103589:	0f 94 c0             	sete   %al
  10358c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10358f:	85 c0                	test   %eax,%eax
  103591:	75 24                	jne    1035b7 <basic_check+0x270>
  103593:	c7 44 24 0c ff 6c 10 	movl   $0x106cff,0xc(%esp)
  10359a:	00 
  10359b:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1035a2:	00 
  1035a3:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  1035aa:	00 
  1035ab:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1035b2:	e8 66 d7 ff ff       	call   100d1d <__panic>

    unsigned int nr_free_store = nr_free;
  1035b7:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  1035bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1035bf:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  1035c6:	00 00 00 

    assert(alloc_page() == NULL);
  1035c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035d0:	e8 84 0c 00 00       	call   104259 <alloc_pages>
  1035d5:	85 c0                	test   %eax,%eax
  1035d7:	74 24                	je     1035fd <basic_check+0x2b6>
  1035d9:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  1035e0:	00 
  1035e1:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1035e8:	00 
  1035e9:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  1035f0:	00 
  1035f1:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1035f8:	e8 20 d7 ff ff       	call   100d1d <__panic>

    free_page(p0);
  1035fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103604:	00 
  103605:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103608:	89 04 24             	mov    %eax,(%esp)
  10360b:	e8 83 0c 00 00       	call   104293 <free_pages>
    free_page(p1);
  103610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103617:	00 
  103618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10361b:	89 04 24             	mov    %eax,(%esp)
  10361e:	e8 70 0c 00 00       	call   104293 <free_pages>
    free_page(p2);
  103623:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10362a:	00 
  10362b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10362e:	89 04 24             	mov    %eax,(%esp)
  103631:	e8 5d 0c 00 00       	call   104293 <free_pages>
    assert(nr_free == 3);
  103636:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  10363b:	83 f8 03             	cmp    $0x3,%eax
  10363e:	74 24                	je     103664 <basic_check+0x31d>
  103640:	c7 44 24 0c 2b 6d 10 	movl   $0x106d2b,0xc(%esp)
  103647:	00 
  103648:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  10364f:	00 
  103650:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103657:	00 
  103658:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10365f:	e8 b9 d6 ff ff       	call   100d1d <__panic>

    assert((p0 = alloc_page()) != NULL);
  103664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10366b:	e8 e9 0b 00 00       	call   104259 <alloc_pages>
  103670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103673:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103677:	75 24                	jne    10369d <basic_check+0x356>
  103679:	c7 44 24 0c f4 6b 10 	movl   $0x106bf4,0xc(%esp)
  103680:	00 
  103681:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103688:	00 
  103689:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  103690:	00 
  103691:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103698:	e8 80 d6 ff ff       	call   100d1d <__panic>
    assert((p1 = alloc_page()) != NULL);
  10369d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036a4:	e8 b0 0b 00 00       	call   104259 <alloc_pages>
  1036a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036b0:	75 24                	jne    1036d6 <basic_check+0x38f>
  1036b2:	c7 44 24 0c 10 6c 10 	movl   $0x106c10,0xc(%esp)
  1036b9:	00 
  1036ba:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1036c1:	00 
  1036c2:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  1036c9:	00 
  1036ca:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1036d1:	e8 47 d6 ff ff       	call   100d1d <__panic>
    assert((p2 = alloc_page()) != NULL);
  1036d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1036dd:	e8 77 0b 00 00       	call   104259 <alloc_pages>
  1036e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1036e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1036e9:	75 24                	jne    10370f <basic_check+0x3c8>
  1036eb:	c7 44 24 0c 2c 6c 10 	movl   $0x106c2c,0xc(%esp)
  1036f2:	00 
  1036f3:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1036fa:	00 
  1036fb:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  103702:	00 
  103703:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10370a:	e8 0e d6 ff ff       	call   100d1d <__panic>

    assert(alloc_page() == NULL);
  10370f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103716:	e8 3e 0b 00 00       	call   104259 <alloc_pages>
  10371b:	85 c0                	test   %eax,%eax
  10371d:	74 24                	je     103743 <basic_check+0x3fc>
  10371f:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  103726:	00 
  103727:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  10372e:	00 
  10372f:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  103736:	00 
  103737:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10373e:	e8 da d5 ff ff       	call   100d1d <__panic>

    free_page(p0);
  103743:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10374a:	00 
  10374b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10374e:	89 04 24             	mov    %eax,(%esp)
  103751:	e8 3d 0b 00 00       	call   104293 <free_pages>
  103756:	c7 45 d8 e0 ce 11 00 	movl   $0x11cee0,-0x28(%ebp)
  10375d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103760:	8b 40 04             	mov    0x4(%eax),%eax
  103763:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103766:	0f 94 c0             	sete   %al
  103769:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  10376c:	85 c0                	test   %eax,%eax
  10376e:	74 24                	je     103794 <basic_check+0x44d>
  103770:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  103777:	00 
  103778:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  10377f:	00 
  103780:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  103787:	00 
  103788:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10378f:	e8 89 d5 ff ff       	call   100d1d <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103794:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10379b:	e8 b9 0a 00 00       	call   104259 <alloc_pages>
  1037a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1037a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1037a9:	74 24                	je     1037cf <basic_check+0x488>
  1037ab:	c7 44 24 0c 50 6d 10 	movl   $0x106d50,0xc(%esp)
  1037b2:	00 
  1037b3:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1037ba:	00 
  1037bb:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
  1037c2:	00 
  1037c3:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1037ca:	e8 4e d5 ff ff       	call   100d1d <__panic>
    assert(alloc_page() == NULL);
  1037cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037d6:	e8 7e 0a 00 00       	call   104259 <alloc_pages>
  1037db:	85 c0                	test   %eax,%eax
  1037dd:	74 24                	je     103803 <basic_check+0x4bc>
  1037df:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  1037e6:	00 
  1037e7:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1037ee:	00 
  1037ef:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1037f6:	00 
  1037f7:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1037fe:	e8 1a d5 ff ff       	call   100d1d <__panic>

    assert(nr_free == 0);
  103803:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103808:	85 c0                	test   %eax,%eax
  10380a:	74 24                	je     103830 <basic_check+0x4e9>
  10380c:	c7 44 24 0c 69 6d 10 	movl   $0x106d69,0xc(%esp)
  103813:	00 
  103814:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  10381b:	00 
  10381c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  103823:	00 
  103824:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  10382b:	e8 ed d4 ff ff       	call   100d1d <__panic>
    free_list = free_list_store;
  103830:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103833:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103836:	a3 e0 ce 11 00       	mov    %eax,0x11cee0
  10383b:	89 15 e4 ce 11 00    	mov    %edx,0x11cee4
    nr_free = nr_free_store;
  103841:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103844:	a3 e8 ce 11 00       	mov    %eax,0x11cee8

    free_page(p);
  103849:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103850:	00 
  103851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103854:	89 04 24             	mov    %eax,(%esp)
  103857:	e8 37 0a 00 00       	call   104293 <free_pages>
    free_page(p1);
  10385c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103863:	00 
  103864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103867:	89 04 24             	mov    %eax,(%esp)
  10386a:	e8 24 0a 00 00       	call   104293 <free_pages>
    free_page(p2);
  10386f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103876:	00 
  103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10387a:	89 04 24             	mov    %eax,(%esp)
  10387d:	e8 11 0a 00 00       	call   104293 <free_pages>
}
  103882:	90                   	nop
  103883:	89 ec                	mov    %ebp,%esp
  103885:	5d                   	pop    %ebp
  103886:	c3                   	ret    

00103887 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103887:	55                   	push   %ebp
  103888:	89 e5                	mov    %esp,%ebp
  10388a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  103890:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103897:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  10389e:	c7 45 ec e0 ce 11 00 	movl   $0x11cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1038a5:	eb 6a                	jmp    103911 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  1038a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1038aa:	83 e8 0c             	sub    $0xc,%eax
  1038ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  1038b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1038b3:	83 c0 04             	add    $0x4,%eax
  1038b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1038bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1038c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1038c3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1038c6:	0f a3 10             	bt     %edx,(%eax)
  1038c9:	19 c0                	sbb    %eax,%eax
  1038cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1038ce:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1038d2:	0f 95 c0             	setne  %al
  1038d5:	0f b6 c0             	movzbl %al,%eax
  1038d8:	85 c0                	test   %eax,%eax
  1038da:	75 24                	jne    103900 <default_check+0x79>
  1038dc:	c7 44 24 0c 76 6d 10 	movl   $0x106d76,0xc(%esp)
  1038e3:	00 
  1038e4:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1038eb:	00 
  1038ec:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  1038f3:	00 
  1038f4:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1038fb:	e8 1d d4 ff ff       	call   100d1d <__panic>
        count ++, total += p->property;
  103900:	ff 45 f4             	incl   -0xc(%ebp)
  103903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103906:	8b 50 08             	mov    0x8(%eax),%edx
  103909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10390c:	01 d0                	add    %edx,%eax
  10390e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103911:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103914:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  103917:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10391a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10391d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103920:	81 7d ec e0 ce 11 00 	cmpl   $0x11cee0,-0x14(%ebp)
  103927:	0f 85 7a ff ff ff    	jne    1038a7 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  10392d:	e8 96 09 00 00       	call   1042c8 <nr_free_pages>
  103932:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103935:	39 d0                	cmp    %edx,%eax
  103937:	74 24                	je     10395d <default_check+0xd6>
  103939:	c7 44 24 0c 86 6d 10 	movl   $0x106d86,0xc(%esp)
  103940:	00 
  103941:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103948:	00 
  103949:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  103950:	00 
  103951:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103958:	e8 c0 d3 ff ff       	call   100d1d <__panic>

    basic_check();
  10395d:	e8 e5 f9 ff ff       	call   103347 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103962:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103969:	e8 eb 08 00 00       	call   104259 <alloc_pages>
  10396e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  103971:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103975:	75 24                	jne    10399b <default_check+0x114>
  103977:	c7 44 24 0c 9f 6d 10 	movl   $0x106d9f,0xc(%esp)
  10397e:	00 
  10397f:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103986:	00 
  103987:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  10398e:	00 
  10398f:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103996:	e8 82 d3 ff ff       	call   100d1d <__panic>
    assert(!PageProperty(p0));
  10399b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10399e:	83 c0 04             	add    $0x4,%eax
  1039a1:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1039a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1039ab:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1039ae:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1039b1:	0f a3 10             	bt     %edx,(%eax)
  1039b4:	19 c0                	sbb    %eax,%eax
  1039b6:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1039b9:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1039bd:	0f 95 c0             	setne  %al
  1039c0:	0f b6 c0             	movzbl %al,%eax
  1039c3:	85 c0                	test   %eax,%eax
  1039c5:	74 24                	je     1039eb <default_check+0x164>
  1039c7:	c7 44 24 0c aa 6d 10 	movl   $0x106daa,0xc(%esp)
  1039ce:	00 
  1039cf:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  1039d6:	00 
  1039d7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1039de:	00 
  1039df:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  1039e6:	e8 32 d3 ff ff       	call   100d1d <__panic>

    list_entry_t free_list_store = free_list;
  1039eb:	a1 e0 ce 11 00       	mov    0x11cee0,%eax
  1039f0:	8b 15 e4 ce 11 00    	mov    0x11cee4,%edx
  1039f6:	89 45 80             	mov    %eax,-0x80(%ebp)
  1039f9:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1039fc:	c7 45 b0 e0 ce 11 00 	movl   $0x11cee0,-0x50(%ebp)
    elm->prev = elm->next = elm;
  103a03:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103a06:	8b 55 b0             	mov    -0x50(%ebp),%edx
  103a09:	89 50 04             	mov    %edx,0x4(%eax)
  103a0c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103a0f:	8b 50 04             	mov    0x4(%eax),%edx
  103a12:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103a15:	89 10                	mov    %edx,(%eax)
}
  103a17:	90                   	nop
  103a18:	c7 45 b4 e0 ce 11 00 	movl   $0x11cee0,-0x4c(%ebp)
    return list->next == list;
  103a1f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103a22:	8b 40 04             	mov    0x4(%eax),%eax
  103a25:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  103a28:	0f 94 c0             	sete   %al
  103a2b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103a2e:	85 c0                	test   %eax,%eax
  103a30:	75 24                	jne    103a56 <default_check+0x1cf>
  103a32:	c7 44 24 0c ff 6c 10 	movl   $0x106cff,0xc(%esp)
  103a39:	00 
  103a3a:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103a41:	00 
  103a42:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  103a49:	00 
  103a4a:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103a51:	e8 c7 d2 ff ff       	call   100d1d <__panic>
    assert(alloc_page() == NULL);
  103a56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103a5d:	e8 f7 07 00 00       	call   104259 <alloc_pages>
  103a62:	85 c0                	test   %eax,%eax
  103a64:	74 24                	je     103a8a <default_check+0x203>
  103a66:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  103a6d:	00 
  103a6e:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103a75:	00 
  103a76:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  103a7d:	00 
  103a7e:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103a85:	e8 93 d2 ff ff       	call   100d1d <__panic>

    unsigned int nr_free_store = nr_free;
  103a8a:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  103a92:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  103a99:	00 00 00 

    free_pages(p0 + 2, 3);
  103a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a9f:	83 c0 28             	add    $0x28,%eax
  103aa2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103aa9:	00 
  103aaa:	89 04 24             	mov    %eax,(%esp)
  103aad:	e8 e1 07 00 00       	call   104293 <free_pages>
    assert(alloc_pages(4) == NULL);
  103ab2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  103ab9:	e8 9b 07 00 00       	call   104259 <alloc_pages>
  103abe:	85 c0                	test   %eax,%eax
  103ac0:	74 24                	je     103ae6 <default_check+0x25f>
  103ac2:	c7 44 24 0c bc 6d 10 	movl   $0x106dbc,0xc(%esp)
  103ac9:	00 
  103aca:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103ad1:	00 
  103ad2:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  103ad9:	00 
  103ada:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103ae1:	e8 37 d2 ff ff       	call   100d1d <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  103ae6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103ae9:	83 c0 28             	add    $0x28,%eax
  103aec:	83 c0 04             	add    $0x4,%eax
  103aef:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103af6:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103af9:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103afc:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103aff:	0f a3 10             	bt     %edx,(%eax)
  103b02:	19 c0                	sbb    %eax,%eax
  103b04:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103b07:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103b0b:	0f 95 c0             	setne  %al
  103b0e:	0f b6 c0             	movzbl %al,%eax
  103b11:	85 c0                	test   %eax,%eax
  103b13:	74 0e                	je     103b23 <default_check+0x29c>
  103b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103b18:	83 c0 28             	add    $0x28,%eax
  103b1b:	8b 40 08             	mov    0x8(%eax),%eax
  103b1e:	83 f8 03             	cmp    $0x3,%eax
  103b21:	74 24                	je     103b47 <default_check+0x2c0>
  103b23:	c7 44 24 0c d4 6d 10 	movl   $0x106dd4,0xc(%esp)
  103b2a:	00 
  103b2b:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103b32:	00 
  103b33:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  103b3a:	00 
  103b3b:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103b42:	e8 d6 d1 ff ff       	call   100d1d <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103b47:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103b4e:	e8 06 07 00 00       	call   104259 <alloc_pages>
  103b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103b56:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103b5a:	75 24                	jne    103b80 <default_check+0x2f9>
  103b5c:	c7 44 24 0c 00 6e 10 	movl   $0x106e00,0xc(%esp)
  103b63:	00 
  103b64:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103b6b:	00 
  103b6c:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  103b73:	00 
  103b74:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103b7b:	e8 9d d1 ff ff       	call   100d1d <__panic>
    assert(alloc_page() == NULL);
  103b80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b87:	e8 cd 06 00 00       	call   104259 <alloc_pages>
  103b8c:	85 c0                	test   %eax,%eax
  103b8e:	74 24                	je     103bb4 <default_check+0x32d>
  103b90:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  103b97:	00 
  103b98:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103b9f:	00 
  103ba0:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  103ba7:	00 
  103ba8:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103baf:	e8 69 d1 ff ff       	call   100d1d <__panic>
    assert(p0 + 2 == p1);
  103bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103bb7:	83 c0 28             	add    $0x28,%eax
  103bba:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103bbd:	74 24                	je     103be3 <default_check+0x35c>
  103bbf:	c7 44 24 0c 1e 6e 10 	movl   $0x106e1e,0xc(%esp)
  103bc6:	00 
  103bc7:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103bce:	00 
  103bcf:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  103bd6:	00 
  103bd7:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103bde:	e8 3a d1 ff ff       	call   100d1d <__panic>

    p2 = p0 + 1;
  103be3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103be6:	83 c0 14             	add    $0x14,%eax
  103be9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  103bec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103bf3:	00 
  103bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103bf7:	89 04 24             	mov    %eax,(%esp)
  103bfa:	e8 94 06 00 00       	call   104293 <free_pages>
    free_pages(p1, 3);
  103bff:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103c06:	00 
  103c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103c0a:	89 04 24             	mov    %eax,(%esp)
  103c0d:	e8 81 06 00 00       	call   104293 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  103c12:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103c15:	83 c0 04             	add    $0x4,%eax
  103c18:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103c1f:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103c22:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103c25:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103c28:	0f a3 10             	bt     %edx,(%eax)
  103c2b:	19 c0                	sbb    %eax,%eax
  103c2d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103c30:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103c34:	0f 95 c0             	setne  %al
  103c37:	0f b6 c0             	movzbl %al,%eax
  103c3a:	85 c0                	test   %eax,%eax
  103c3c:	74 0b                	je     103c49 <default_check+0x3c2>
  103c3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103c41:	8b 40 08             	mov    0x8(%eax),%eax
  103c44:	83 f8 01             	cmp    $0x1,%eax
  103c47:	74 24                	je     103c6d <default_check+0x3e6>
  103c49:	c7 44 24 0c 2c 6e 10 	movl   $0x106e2c,0xc(%esp)
  103c50:	00 
  103c51:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103c58:	00 
  103c59:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  103c60:	00 
  103c61:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103c68:	e8 b0 d0 ff ff       	call   100d1d <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103c6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103c70:	83 c0 04             	add    $0x4,%eax
  103c73:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103c7a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103c7d:	8b 45 90             	mov    -0x70(%ebp),%eax
  103c80:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103c83:	0f a3 10             	bt     %edx,(%eax)
  103c86:	19 c0                	sbb    %eax,%eax
  103c88:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103c8b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103c8f:	0f 95 c0             	setne  %al
  103c92:	0f b6 c0             	movzbl %al,%eax
  103c95:	85 c0                	test   %eax,%eax
  103c97:	74 0b                	je     103ca4 <default_check+0x41d>
  103c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103c9c:	8b 40 08             	mov    0x8(%eax),%eax
  103c9f:	83 f8 03             	cmp    $0x3,%eax
  103ca2:	74 24                	je     103cc8 <default_check+0x441>
  103ca4:	c7 44 24 0c 54 6e 10 	movl   $0x106e54,0xc(%esp)
  103cab:	00 
  103cac:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103cb3:	00 
  103cb4:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  103cbb:	00 
  103cbc:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103cc3:	e8 55 d0 ff ff       	call   100d1d <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103cc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ccf:	e8 85 05 00 00       	call   104259 <alloc_pages>
  103cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103cd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103cda:	83 e8 14             	sub    $0x14,%eax
  103cdd:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103ce0:	74 24                	je     103d06 <default_check+0x47f>
  103ce2:	c7 44 24 0c 7a 6e 10 	movl   $0x106e7a,0xc(%esp)
  103ce9:	00 
  103cea:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103cf1:	00 
  103cf2:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  103cf9:	00 
  103cfa:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103d01:	e8 17 d0 ff ff       	call   100d1d <__panic>
    free_page(p0);
  103d06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103d0d:	00 
  103d0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103d11:	89 04 24             	mov    %eax,(%esp)
  103d14:	e8 7a 05 00 00       	call   104293 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103d19:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103d20:	e8 34 05 00 00       	call   104259 <alloc_pages>
  103d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103d2b:	83 c0 14             	add    $0x14,%eax
  103d2e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103d31:	74 24                	je     103d57 <default_check+0x4d0>
  103d33:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  103d3a:	00 
  103d3b:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103d42:	00 
  103d43:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  103d4a:	00 
  103d4b:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103d52:	e8 c6 cf ff ff       	call   100d1d <__panic>

    free_pages(p0, 2);
  103d57:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103d5e:	00 
  103d5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103d62:	89 04 24             	mov    %eax,(%esp)
  103d65:	e8 29 05 00 00       	call   104293 <free_pages>
    free_page(p2);
  103d6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103d71:	00 
  103d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103d75:	89 04 24             	mov    %eax,(%esp)
  103d78:	e8 16 05 00 00       	call   104293 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103d7d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103d84:	e8 d0 04 00 00       	call   104259 <alloc_pages>
  103d89:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103d8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103d90:	75 24                	jne    103db6 <default_check+0x52f>
  103d92:	c7 44 24 0c b8 6e 10 	movl   $0x106eb8,0xc(%esp)
  103d99:	00 
  103d9a:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103da1:	00 
  103da2:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  103da9:	00 
  103daa:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103db1:	e8 67 cf ff ff       	call   100d1d <__panic>
    assert(alloc_page() == NULL);
  103db6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103dbd:	e8 97 04 00 00       	call   104259 <alloc_pages>
  103dc2:	85 c0                	test   %eax,%eax
  103dc4:	74 24                	je     103dea <default_check+0x563>
  103dc6:	c7 44 24 0c 16 6d 10 	movl   $0x106d16,0xc(%esp)
  103dcd:	00 
  103dce:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103dd5:	00 
  103dd6:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
  103ddd:	00 
  103dde:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103de5:	e8 33 cf ff ff       	call   100d1d <__panic>

    assert(nr_free == 0);
  103dea:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103def:	85 c0                	test   %eax,%eax
  103df1:	74 24                	je     103e17 <default_check+0x590>
  103df3:	c7 44 24 0c 69 6d 10 	movl   $0x106d69,0xc(%esp)
  103dfa:	00 
  103dfb:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103e02:	00 
  103e03:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  103e0a:	00 
  103e0b:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103e12:	e8 06 cf ff ff       	call   100d1d <__panic>
    nr_free = nr_free_store;
  103e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e1a:	a3 e8 ce 11 00       	mov    %eax,0x11cee8

    free_list = free_list_store;
  103e1f:	8b 45 80             	mov    -0x80(%ebp),%eax
  103e22:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103e25:	a3 e0 ce 11 00       	mov    %eax,0x11cee0
  103e2a:	89 15 e4 ce 11 00    	mov    %edx,0x11cee4
    free_pages(p0, 5);
  103e30:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103e37:	00 
  103e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103e3b:	89 04 24             	mov    %eax,(%esp)
  103e3e:	e8 50 04 00 00       	call   104293 <free_pages>

    le = &free_list;
  103e43:	c7 45 ec e0 ce 11 00 	movl   $0x11cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103e4a:	eb 5a                	jmp    103ea6 <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
  103e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e4f:	8b 40 04             	mov    0x4(%eax),%eax
  103e52:	8b 00                	mov    (%eax),%eax
  103e54:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103e57:	75 0d                	jne    103e66 <default_check+0x5df>
  103e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e5c:	8b 00                	mov    (%eax),%eax
  103e5e:	8b 40 04             	mov    0x4(%eax),%eax
  103e61:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103e64:	74 24                	je     103e8a <default_check+0x603>
  103e66:	c7 44 24 0c d8 6e 10 	movl   $0x106ed8,0xc(%esp)
  103e6d:	00 
  103e6e:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103e75:	00 
  103e76:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  103e7d:	00 
  103e7e:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103e85:	e8 93 ce ff ff       	call   100d1d <__panic>
        struct Page *p = le2page(le, page_link);
  103e8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e8d:	83 e8 0c             	sub    $0xc,%eax
  103e90:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103e93:	ff 4d f4             	decl   -0xc(%ebp)
  103e96:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103e99:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103e9c:	8b 48 08             	mov    0x8(%eax),%ecx
  103e9f:	89 d0                	mov    %edx,%eax
  103ea1:	29 c8                	sub    %ecx,%eax
  103ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ea6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ea9:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103eac:	8b 45 88             	mov    -0x78(%ebp),%eax
  103eaf:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103eb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103eb5:	81 7d ec e0 ce 11 00 	cmpl   $0x11cee0,-0x14(%ebp)
  103ebc:	75 8e                	jne    103e4c <default_check+0x5c5>
    }
    assert(count == 0);
  103ebe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103ec2:	74 24                	je     103ee8 <default_check+0x661>
  103ec4:	c7 44 24 0c 05 6f 10 	movl   $0x106f05,0xc(%esp)
  103ecb:	00 
  103ecc:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103ed3:	00 
  103ed4:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  103edb:	00 
  103edc:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103ee3:	e8 35 ce ff ff       	call   100d1d <__panic>
    assert(total == 0);
  103ee8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103eec:	74 24                	je     103f12 <default_check+0x68b>
  103eee:	c7 44 24 0c 10 6f 10 	movl   $0x106f10,0xc(%esp)
  103ef5:	00 
  103ef6:	c7 44 24 08 76 6b 10 	movl   $0x106b76,0x8(%esp)
  103efd:	00 
  103efe:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  103f05:	00 
  103f06:	c7 04 24 8b 6b 10 00 	movl   $0x106b8b,(%esp)
  103f0d:	e8 0b ce ff ff       	call   100d1d <__panic>
}
  103f12:	90                   	nop
  103f13:	89 ec                	mov    %ebp,%esp
  103f15:	5d                   	pop    %ebp
  103f16:	c3                   	ret    

00103f17 <page2ppn>:
page2ppn(struct Page *page) {
  103f17:	55                   	push   %ebp
  103f18:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103f1a:	8b 15 00 cf 11 00    	mov    0x11cf00,%edx
  103f20:	8b 45 08             	mov    0x8(%ebp),%eax
  103f23:	29 d0                	sub    %edx,%eax
  103f25:	c1 f8 02             	sar    $0x2,%eax
  103f28:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103f2e:	5d                   	pop    %ebp
  103f2f:	c3                   	ret    

00103f30 <page2pa>:
page2pa(struct Page *page) {
  103f30:	55                   	push   %ebp
  103f31:	89 e5                	mov    %esp,%ebp
  103f33:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103f36:	8b 45 08             	mov    0x8(%ebp),%eax
  103f39:	89 04 24             	mov    %eax,(%esp)
  103f3c:	e8 d6 ff ff ff       	call   103f17 <page2ppn>
  103f41:	c1 e0 0c             	shl    $0xc,%eax
}
  103f44:	89 ec                	mov    %ebp,%esp
  103f46:	5d                   	pop    %ebp
  103f47:	c3                   	ret    

00103f48 <pa2page>:
pa2page(uintptr_t pa) {
  103f48:	55                   	push   %ebp
  103f49:	89 e5                	mov    %esp,%ebp
  103f4b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  103f51:	c1 e8 0c             	shr    $0xc,%eax
  103f54:	89 c2                	mov    %eax,%edx
  103f56:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  103f5b:	39 c2                	cmp    %eax,%edx
  103f5d:	72 1c                	jb     103f7b <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103f5f:	c7 44 24 08 4c 6f 10 	movl   $0x106f4c,0x8(%esp)
  103f66:	00 
  103f67:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103f6e:	00 
  103f6f:	c7 04 24 6b 6f 10 00 	movl   $0x106f6b,(%esp)
  103f76:	e8 a2 cd ff ff       	call   100d1d <__panic>
    return &pages[PPN(pa)];
  103f7b:	8b 0d 00 cf 11 00    	mov    0x11cf00,%ecx
  103f81:	8b 45 08             	mov    0x8(%ebp),%eax
  103f84:	c1 e8 0c             	shr    $0xc,%eax
  103f87:	89 c2                	mov    %eax,%edx
  103f89:	89 d0                	mov    %edx,%eax
  103f8b:	c1 e0 02             	shl    $0x2,%eax
  103f8e:	01 d0                	add    %edx,%eax
  103f90:	c1 e0 02             	shl    $0x2,%eax
  103f93:	01 c8                	add    %ecx,%eax
}
  103f95:	89 ec                	mov    %ebp,%esp
  103f97:	5d                   	pop    %ebp
  103f98:	c3                   	ret    

00103f99 <page2kva>:
page2kva(struct Page *page) {
  103f99:	55                   	push   %ebp
  103f9a:	89 e5                	mov    %esp,%ebp
  103f9c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  103fa2:	89 04 24             	mov    %eax,(%esp)
  103fa5:	e8 86 ff ff ff       	call   103f30 <page2pa>
  103faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103fb0:	c1 e8 0c             	shr    $0xc,%eax
  103fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103fb6:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  103fbb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103fbe:	72 23                	jb     103fe3 <page2kva+0x4a>
  103fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103fc7:	c7 44 24 08 7c 6f 10 	movl   $0x106f7c,0x8(%esp)
  103fce:	00 
  103fcf:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103fd6:	00 
  103fd7:	c7 04 24 6b 6f 10 00 	movl   $0x106f6b,(%esp)
  103fde:	e8 3a cd ff ff       	call   100d1d <__panic>
  103fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103fe6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103feb:	89 ec                	mov    %ebp,%esp
  103fed:	5d                   	pop    %ebp
  103fee:	c3                   	ret    

00103fef <pte2page>:
pte2page(pte_t pte) {
  103fef:	55                   	push   %ebp
  103ff0:	89 e5                	mov    %esp,%ebp
  103ff2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  103ff8:	83 e0 01             	and    $0x1,%eax
  103ffb:	85 c0                	test   %eax,%eax
  103ffd:	75 1c                	jne    10401b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103fff:	c7 44 24 08 a0 6f 10 	movl   $0x106fa0,0x8(%esp)
  104006:	00 
  104007:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  10400e:	00 
  10400f:	c7 04 24 6b 6f 10 00 	movl   $0x106f6b,(%esp)
  104016:	e8 02 cd ff ff       	call   100d1d <__panic>
    return pa2page(PTE_ADDR(pte));
  10401b:	8b 45 08             	mov    0x8(%ebp),%eax
  10401e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104023:	89 04 24             	mov    %eax,(%esp)
  104026:	e8 1d ff ff ff       	call   103f48 <pa2page>
}
  10402b:	89 ec                	mov    %ebp,%esp
  10402d:	5d                   	pop    %ebp
  10402e:	c3                   	ret    

0010402f <pde2page>:
pde2page(pde_t pde) {
  10402f:	55                   	push   %ebp
  104030:	89 e5                	mov    %esp,%ebp
  104032:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  104035:	8b 45 08             	mov    0x8(%ebp),%eax
  104038:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10403d:	89 04 24             	mov    %eax,(%esp)
  104040:	e8 03 ff ff ff       	call   103f48 <pa2page>
}
  104045:	89 ec                	mov    %ebp,%esp
  104047:	5d                   	pop    %ebp
  104048:	c3                   	ret    

00104049 <page_ref>:
page_ref(struct Page *page) {
  104049:	55                   	push   %ebp
  10404a:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10404c:	8b 45 08             	mov    0x8(%ebp),%eax
  10404f:	8b 00                	mov    (%eax),%eax
}
  104051:	5d                   	pop    %ebp
  104052:	c3                   	ret    

00104053 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104053:	55                   	push   %ebp
  104054:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104056:	8b 45 08             	mov    0x8(%ebp),%eax
  104059:	8b 55 0c             	mov    0xc(%ebp),%edx
  10405c:	89 10                	mov    %edx,(%eax)
}
  10405e:	90                   	nop
  10405f:	5d                   	pop    %ebp
  104060:	c3                   	ret    

00104061 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  104061:	55                   	push   %ebp
  104062:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  104064:	8b 45 08             	mov    0x8(%ebp),%eax
  104067:	8b 00                	mov    (%eax),%eax
  104069:	8d 50 01             	lea    0x1(%eax),%edx
  10406c:	8b 45 08             	mov    0x8(%ebp),%eax
  10406f:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104071:	8b 45 08             	mov    0x8(%ebp),%eax
  104074:	8b 00                	mov    (%eax),%eax
}
  104076:	5d                   	pop    %ebp
  104077:	c3                   	ret    

00104078 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  104078:	55                   	push   %ebp
  104079:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  10407b:	8b 45 08             	mov    0x8(%ebp),%eax
  10407e:	8b 00                	mov    (%eax),%eax
  104080:	8d 50 ff             	lea    -0x1(%eax),%edx
  104083:	8b 45 08             	mov    0x8(%ebp),%eax
  104086:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104088:	8b 45 08             	mov    0x8(%ebp),%eax
  10408b:	8b 00                	mov    (%eax),%eax
}
  10408d:	5d                   	pop    %ebp
  10408e:	c3                   	ret    

0010408f <__intr_save>:
__intr_save(void) {
  10408f:	55                   	push   %ebp
  104090:	89 e5                	mov    %esp,%ebp
  104092:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  104095:	9c                   	pushf  
  104096:	58                   	pop    %eax
  104097:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  10409a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  10409d:	25 00 02 00 00       	and    $0x200,%eax
  1040a2:	85 c0                	test   %eax,%eax
  1040a4:	74 0c                	je     1040b2 <__intr_save+0x23>
        intr_disable();
  1040a6:	e8 cb d6 ff ff       	call   101776 <intr_disable>
        return 1;
  1040ab:	b8 01 00 00 00       	mov    $0x1,%eax
  1040b0:	eb 05                	jmp    1040b7 <__intr_save+0x28>
    return 0;
  1040b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1040b7:	89 ec                	mov    %ebp,%esp
  1040b9:	5d                   	pop    %ebp
  1040ba:	c3                   	ret    

001040bb <__intr_restore>:
__intr_restore(bool flag) {
  1040bb:	55                   	push   %ebp
  1040bc:	89 e5                	mov    %esp,%ebp
  1040be:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1040c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1040c5:	74 05                	je     1040cc <__intr_restore+0x11>
        intr_enable();
  1040c7:	e8 a2 d6 ff ff       	call   10176e <intr_enable>
}
  1040cc:	90                   	nop
  1040cd:	89 ec                	mov    %ebp,%esp
  1040cf:	5d                   	pop    %ebp
  1040d0:	c3                   	ret    

001040d1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1040d1:	55                   	push   %ebp
  1040d2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1040d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1040d7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1040da:	b8 23 00 00 00       	mov    $0x23,%eax
  1040df:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1040e1:	b8 23 00 00 00       	mov    $0x23,%eax
  1040e6:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1040e8:	b8 10 00 00 00       	mov    $0x10,%eax
  1040ed:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1040ef:	b8 10 00 00 00       	mov    $0x10,%eax
  1040f4:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1040f6:	b8 10 00 00 00       	mov    $0x10,%eax
  1040fb:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  1040fd:	ea 04 41 10 00 08 00 	ljmp   $0x8,$0x104104
}
  104104:	90                   	nop
  104105:	5d                   	pop    %ebp
  104106:	c3                   	ret    

00104107 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  104107:	55                   	push   %ebp
  104108:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  10410a:	8b 45 08             	mov    0x8(%ebp),%eax
  10410d:	a3 24 cf 11 00       	mov    %eax,0x11cf24
}
  104112:	90                   	nop
  104113:	5d                   	pop    %ebp
  104114:	c3                   	ret    

00104115 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  104115:	55                   	push   %ebp
  104116:	89 e5                	mov    %esp,%ebp
  104118:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  10411b:	b8 00 90 11 00       	mov    $0x119000,%eax
  104120:	89 04 24             	mov    %eax,(%esp)
  104123:	e8 df ff ff ff       	call   104107 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  104128:	66 c7 05 28 cf 11 00 	movw   $0x10,0x11cf28
  10412f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  104131:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  104138:	68 00 
  10413a:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  10413f:	0f b7 c0             	movzwl %ax,%eax
  104142:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  104148:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  10414d:	c1 e8 10             	shr    $0x10,%eax
  104150:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  104155:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10415c:	24 f0                	and    $0xf0,%al
  10415e:	0c 09                	or     $0x9,%al
  104160:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104165:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10416c:	24 ef                	and    $0xef,%al
  10416e:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104173:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  10417a:	24 9f                	and    $0x9f,%al
  10417c:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  104181:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  104188:	0c 80                	or     $0x80,%al
  10418a:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  10418f:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  104196:	24 f0                	and    $0xf0,%al
  104198:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  10419d:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1041a4:	24 ef                	and    $0xef,%al
  1041a6:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1041ab:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1041b2:	24 df                	and    $0xdf,%al
  1041b4:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1041b9:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1041c0:	0c 40                	or     $0x40,%al
  1041c2:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1041c7:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  1041ce:	24 7f                	and    $0x7f,%al
  1041d0:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  1041d5:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  1041da:	c1 e8 18             	shr    $0x18,%eax
  1041dd:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  1041e2:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  1041e9:	e8 e3 fe ff ff       	call   1040d1 <lgdt>
  1041ee:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  1041f4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  1041f8:	0f 00 d8             	ltr    %ax
}
  1041fb:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  1041fc:	90                   	nop
  1041fd:	89 ec                	mov    %ebp,%esp
  1041ff:	5d                   	pop    %ebp
  104200:	c3                   	ret    

00104201 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  104201:	55                   	push   %ebp
  104202:	89 e5                	mov    %esp,%ebp
  104204:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &buddy_pmm_manager;
    pmm_manager = &default_pmm_manager;
  104207:	c7 05 0c cf 11 00 30 	movl   $0x106f30,0x11cf0c
  10420e:	6f 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  104211:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104216:	8b 00                	mov    (%eax),%eax
  104218:	89 44 24 04          	mov    %eax,0x4(%esp)
  10421c:	c7 04 24 cc 6f 10 00 	movl   $0x106fcc,(%esp)
  104223:	e8 73 c1 ff ff       	call   10039b <cprintf>
    pmm_manager->init();
  104228:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  10422d:	8b 40 04             	mov    0x4(%eax),%eax
  104230:	ff d0                	call   *%eax
}
  104232:	90                   	nop
  104233:	89 ec                	mov    %ebp,%esp
  104235:	5d                   	pop    %ebp
  104236:	c3                   	ret    

00104237 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  104237:	55                   	push   %ebp
  104238:	89 e5                	mov    %esp,%ebp
  10423a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  10423d:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104242:	8b 40 08             	mov    0x8(%eax),%eax
  104245:	8b 55 0c             	mov    0xc(%ebp),%edx
  104248:	89 54 24 04          	mov    %edx,0x4(%esp)
  10424c:	8b 55 08             	mov    0x8(%ebp),%edx
  10424f:	89 14 24             	mov    %edx,(%esp)
  104252:	ff d0                	call   *%eax
}
  104254:	90                   	nop
  104255:	89 ec                	mov    %ebp,%esp
  104257:	5d                   	pop    %ebp
  104258:	c3                   	ret    

00104259 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  104259:	55                   	push   %ebp
  10425a:	89 e5                	mov    %esp,%ebp
  10425c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  10425f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  104266:	e8 24 fe ff ff       	call   10408f <__intr_save>
  10426b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  10426e:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104273:	8b 40 0c             	mov    0xc(%eax),%eax
  104276:	8b 55 08             	mov    0x8(%ebp),%edx
  104279:	89 14 24             	mov    %edx,(%esp)
  10427c:	ff d0                	call   *%eax
  10427e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  104281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104284:	89 04 24             	mov    %eax,(%esp)
  104287:	e8 2f fe ff ff       	call   1040bb <__intr_restore>
    return page;
  10428c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10428f:	89 ec                	mov    %ebp,%esp
  104291:	5d                   	pop    %ebp
  104292:	c3                   	ret    

00104293 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104293:	55                   	push   %ebp
  104294:	89 e5                	mov    %esp,%ebp
  104296:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  104299:	e8 f1 fd ff ff       	call   10408f <__intr_save>
  10429e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  1042a1:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  1042a6:	8b 40 10             	mov    0x10(%eax),%eax
  1042a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1042ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  1042b0:	8b 55 08             	mov    0x8(%ebp),%edx
  1042b3:	89 14 24             	mov    %edx,(%esp)
  1042b6:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  1042b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042bb:	89 04 24             	mov    %eax,(%esp)
  1042be:	e8 f8 fd ff ff       	call   1040bb <__intr_restore>
}
  1042c3:	90                   	nop
  1042c4:	89 ec                	mov    %ebp,%esp
  1042c6:	5d                   	pop    %ebp
  1042c7:	c3                   	ret    

001042c8 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  1042c8:	55                   	push   %ebp
  1042c9:	89 e5                	mov    %esp,%ebp
  1042cb:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  1042ce:	e8 bc fd ff ff       	call   10408f <__intr_save>
  1042d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  1042d6:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  1042db:	8b 40 14             	mov    0x14(%eax),%eax
  1042de:	ff d0                	call   *%eax
  1042e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  1042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042e6:	89 04 24             	mov    %eax,(%esp)
  1042e9:	e8 cd fd ff ff       	call   1040bb <__intr_restore>
    return ret;
  1042ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1042f1:	89 ec                	mov    %ebp,%esp
  1042f3:	5d                   	pop    %ebp
  1042f4:	c3                   	ret    

001042f5 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  1042f5:	55                   	push   %ebp
  1042f6:	89 e5                	mov    %esp,%ebp
  1042f8:	57                   	push   %edi
  1042f9:	56                   	push   %esi
  1042fa:	53                   	push   %ebx
  1042fb:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  104301:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  104308:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10430f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  104316:	c7 04 24 e3 6f 10 00 	movl   $0x106fe3,(%esp)
  10431d:	e8 79 c0 ff ff       	call   10039b <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104329:	e9 0c 01 00 00       	jmp    10443a <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10432e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104331:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104334:	89 d0                	mov    %edx,%eax
  104336:	c1 e0 02             	shl    $0x2,%eax
  104339:	01 d0                	add    %edx,%eax
  10433b:	c1 e0 02             	shl    $0x2,%eax
  10433e:	01 c8                	add    %ecx,%eax
  104340:	8b 50 08             	mov    0x8(%eax),%edx
  104343:	8b 40 04             	mov    0x4(%eax),%eax
  104346:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104349:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  10434c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10434f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104352:	89 d0                	mov    %edx,%eax
  104354:	c1 e0 02             	shl    $0x2,%eax
  104357:	01 d0                	add    %edx,%eax
  104359:	c1 e0 02             	shl    $0x2,%eax
  10435c:	01 c8                	add    %ecx,%eax
  10435e:	8b 48 0c             	mov    0xc(%eax),%ecx
  104361:	8b 58 10             	mov    0x10(%eax),%ebx
  104364:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104367:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10436a:	01 c8                	add    %ecx,%eax
  10436c:	11 da                	adc    %ebx,%edx
  10436e:	89 45 98             	mov    %eax,-0x68(%ebp)
  104371:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104374:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10437a:	89 d0                	mov    %edx,%eax
  10437c:	c1 e0 02             	shl    $0x2,%eax
  10437f:	01 d0                	add    %edx,%eax
  104381:	c1 e0 02             	shl    $0x2,%eax
  104384:	01 c8                	add    %ecx,%eax
  104386:	83 c0 14             	add    $0x14,%eax
  104389:	8b 00                	mov    (%eax),%eax
  10438b:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104391:	8b 45 98             	mov    -0x68(%ebp),%eax
  104394:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104397:	83 c0 ff             	add    $0xffffffff,%eax
  10439a:	83 d2 ff             	adc    $0xffffffff,%edx
  10439d:	89 c6                	mov    %eax,%esi
  10439f:	89 d7                	mov    %edx,%edi
  1043a1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1043a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043a7:	89 d0                	mov    %edx,%eax
  1043a9:	c1 e0 02             	shl    $0x2,%eax
  1043ac:	01 d0                	add    %edx,%eax
  1043ae:	c1 e0 02             	shl    $0x2,%eax
  1043b1:	01 c8                	add    %ecx,%eax
  1043b3:	8b 48 0c             	mov    0xc(%eax),%ecx
  1043b6:	8b 58 10             	mov    0x10(%eax),%ebx
  1043b9:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  1043bf:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  1043c3:	89 74 24 14          	mov    %esi,0x14(%esp)
  1043c7:	89 7c 24 18          	mov    %edi,0x18(%esp)
  1043cb:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1043ce:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1043d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  1043d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1043dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  1043e1:	c7 04 24 f0 6f 10 00 	movl   $0x106ff0,(%esp)
  1043e8:	e8 ae bf ff ff       	call   10039b <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  1043ed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1043f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043f3:	89 d0                	mov    %edx,%eax
  1043f5:	c1 e0 02             	shl    $0x2,%eax
  1043f8:	01 d0                	add    %edx,%eax
  1043fa:	c1 e0 02             	shl    $0x2,%eax
  1043fd:	01 c8                	add    %ecx,%eax
  1043ff:	83 c0 14             	add    $0x14,%eax
  104402:	8b 00                	mov    (%eax),%eax
  104404:	83 f8 01             	cmp    $0x1,%eax
  104407:	75 2e                	jne    104437 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  104409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10440c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10440f:	3b 45 98             	cmp    -0x68(%ebp),%eax
  104412:	89 d0                	mov    %edx,%eax
  104414:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  104417:	73 1e                	jae    104437 <page_init+0x142>
  104419:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  10441e:	b8 00 00 00 00       	mov    $0x0,%eax
  104423:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  104426:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  104429:	72 0c                	jb     104437 <page_init+0x142>
                maxpa = end;
  10442b:	8b 45 98             	mov    -0x68(%ebp),%eax
  10442e:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104434:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  104437:	ff 45 dc             	incl   -0x24(%ebp)
  10443a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10443d:	8b 00                	mov    (%eax),%eax
  10443f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104442:	0f 8c e6 fe ff ff    	jl     10432e <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104448:	ba 00 00 00 38       	mov    $0x38000000,%edx
  10444d:	b8 00 00 00 00       	mov    $0x0,%eax
  104452:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  104455:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  104458:	73 0e                	jae    104468 <page_init+0x173>
        maxpa = KMEMSIZE;
  10445a:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104461:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10446b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10446e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104472:	c1 ea 0c             	shr    $0xc,%edx
  104475:	a3 04 cf 11 00       	mov    %eax,0x11cf04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  10447a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  104481:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  104486:	8d 50 ff             	lea    -0x1(%eax),%edx
  104489:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10448c:	01 d0                	add    %edx,%eax
  10448e:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104491:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104494:	ba 00 00 00 00       	mov    $0x0,%edx
  104499:	f7 75 c0             	divl   -0x40(%ebp)
  10449c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10449f:	29 d0                	sub    %edx,%eax
  1044a1:	a3 00 cf 11 00       	mov    %eax,0x11cf00

    for (i = 0; i < npage; i ++) {
  1044a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1044ad:	eb 2f                	jmp    1044de <page_init+0x1e9>
        SetPageReserved(pages + i);
  1044af:	8b 0d 00 cf 11 00    	mov    0x11cf00,%ecx
  1044b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044b8:	89 d0                	mov    %edx,%eax
  1044ba:	c1 e0 02             	shl    $0x2,%eax
  1044bd:	01 d0                	add    %edx,%eax
  1044bf:	c1 e0 02             	shl    $0x2,%eax
  1044c2:	01 c8                	add    %ecx,%eax
  1044c4:	83 c0 04             	add    $0x4,%eax
  1044c7:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  1044ce:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1044d1:	8b 45 90             	mov    -0x70(%ebp),%eax
  1044d4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1044d7:	0f ab 10             	bts    %edx,(%eax)
}
  1044da:	90                   	nop
    for (i = 0; i < npage; i ++) {
  1044db:	ff 45 dc             	incl   -0x24(%ebp)
  1044de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044e1:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1044e6:	39 c2                	cmp    %eax,%edx
  1044e8:	72 c5                	jb     1044af <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  1044ea:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  1044f0:	89 d0                	mov    %edx,%eax
  1044f2:	c1 e0 02             	shl    $0x2,%eax
  1044f5:	01 d0                	add    %edx,%eax
  1044f7:	c1 e0 02             	shl    $0x2,%eax
  1044fa:	89 c2                	mov    %eax,%edx
  1044fc:	a1 00 cf 11 00       	mov    0x11cf00,%eax
  104501:	01 d0                	add    %edx,%eax
  104503:	89 45 b8             	mov    %eax,-0x48(%ebp)
  104506:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  10450d:	77 23                	ja     104532 <page_init+0x23d>
  10450f:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104516:	c7 44 24 08 20 70 10 	movl   $0x107020,0x8(%esp)
  10451d:	00 
  10451e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104525:	00 
  104526:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10452d:	e8 eb c7 ff ff       	call   100d1d <__panic>
  104532:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104535:	05 00 00 00 40       	add    $0x40000000,%eax
  10453a:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  10453d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104544:	e9 53 01 00 00       	jmp    10469c <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104549:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10454c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10454f:	89 d0                	mov    %edx,%eax
  104551:	c1 e0 02             	shl    $0x2,%eax
  104554:	01 d0                	add    %edx,%eax
  104556:	c1 e0 02             	shl    $0x2,%eax
  104559:	01 c8                	add    %ecx,%eax
  10455b:	8b 50 08             	mov    0x8(%eax),%edx
  10455e:	8b 40 04             	mov    0x4(%eax),%eax
  104561:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104564:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104567:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10456a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10456d:	89 d0                	mov    %edx,%eax
  10456f:	c1 e0 02             	shl    $0x2,%eax
  104572:	01 d0                	add    %edx,%eax
  104574:	c1 e0 02             	shl    $0x2,%eax
  104577:	01 c8                	add    %ecx,%eax
  104579:	8b 48 0c             	mov    0xc(%eax),%ecx
  10457c:	8b 58 10             	mov    0x10(%eax),%ebx
  10457f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104582:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104585:	01 c8                	add    %ecx,%eax
  104587:	11 da                	adc    %ebx,%edx
  104589:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10458c:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10458f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104592:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104595:	89 d0                	mov    %edx,%eax
  104597:	c1 e0 02             	shl    $0x2,%eax
  10459a:	01 d0                	add    %edx,%eax
  10459c:	c1 e0 02             	shl    $0x2,%eax
  10459f:	01 c8                	add    %ecx,%eax
  1045a1:	83 c0 14             	add    $0x14,%eax
  1045a4:	8b 00                	mov    (%eax),%eax
  1045a6:	83 f8 01             	cmp    $0x1,%eax
  1045a9:	0f 85 ea 00 00 00    	jne    104699 <page_init+0x3a4>
            if (begin < freemem) {
  1045af:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1045b2:	ba 00 00 00 00       	mov    $0x0,%edx
  1045b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1045ba:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1045bd:	19 d1                	sbb    %edx,%ecx
  1045bf:	73 0d                	jae    1045ce <page_init+0x2d9>
                begin = freemem;
  1045c1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1045c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1045c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1045ce:	ba 00 00 00 38       	mov    $0x38000000,%edx
  1045d3:	b8 00 00 00 00       	mov    $0x0,%eax
  1045d8:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  1045db:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1045de:	73 0e                	jae    1045ee <page_init+0x2f9>
                end = KMEMSIZE;
  1045e0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1045e7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1045ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1045f1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1045f4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1045f7:	89 d0                	mov    %edx,%eax
  1045f9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1045fc:	0f 83 97 00 00 00    	jae    104699 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  104602:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  104609:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10460c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10460f:	01 d0                	add    %edx,%eax
  104611:	48                   	dec    %eax
  104612:	89 45 ac             	mov    %eax,-0x54(%ebp)
  104615:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104618:	ba 00 00 00 00       	mov    $0x0,%edx
  10461d:	f7 75 b0             	divl   -0x50(%ebp)
  104620:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104623:	29 d0                	sub    %edx,%eax
  104625:	ba 00 00 00 00       	mov    $0x0,%edx
  10462a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10462d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104630:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104633:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104636:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104639:	ba 00 00 00 00       	mov    $0x0,%edx
  10463e:	89 c7                	mov    %eax,%edi
  104640:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104646:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104649:	89 d0                	mov    %edx,%eax
  10464b:	83 e0 00             	and    $0x0,%eax
  10464e:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104651:	8b 45 80             	mov    -0x80(%ebp),%eax
  104654:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104657:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10465a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  10465d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104660:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104663:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104666:	89 d0                	mov    %edx,%eax
  104668:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  10466b:	73 2c                	jae    104699 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10466d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104670:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104673:	2b 45 d0             	sub    -0x30(%ebp),%eax
  104676:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  104679:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10467d:	c1 ea 0c             	shr    $0xc,%edx
  104680:	89 c3                	mov    %eax,%ebx
  104682:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104685:	89 04 24             	mov    %eax,(%esp)
  104688:	e8 bb f8 ff ff       	call   103f48 <pa2page>
  10468d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104691:	89 04 24             	mov    %eax,(%esp)
  104694:	e8 9e fb ff ff       	call   104237 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  104699:	ff 45 dc             	incl   -0x24(%ebp)
  10469c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10469f:	8b 00                	mov    (%eax),%eax
  1046a1:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1046a4:	0f 8c 9f fe ff ff    	jl     104549 <page_init+0x254>
                }
            }
        }
    }
}
  1046aa:	90                   	nop
  1046ab:	90                   	nop
  1046ac:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1046b2:	5b                   	pop    %ebx
  1046b3:	5e                   	pop    %esi
  1046b4:	5f                   	pop    %edi
  1046b5:	5d                   	pop    %ebp
  1046b6:	c3                   	ret    

001046b7 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1046b7:	55                   	push   %ebp
  1046b8:	89 e5                	mov    %esp,%ebp
  1046ba:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1046bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046c0:	33 45 14             	xor    0x14(%ebp),%eax
  1046c3:	25 ff 0f 00 00       	and    $0xfff,%eax
  1046c8:	85 c0                	test   %eax,%eax
  1046ca:	74 24                	je     1046f0 <boot_map_segment+0x39>
  1046cc:	c7 44 24 0c 52 70 10 	movl   $0x107052,0xc(%esp)
  1046d3:	00 
  1046d4:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1046db:	00 
  1046dc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  1046e3:	00 
  1046e4:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1046eb:	e8 2d c6 ff ff       	call   100d1d <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1046f0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1046f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046fa:	25 ff 0f 00 00       	and    $0xfff,%eax
  1046ff:	89 c2                	mov    %eax,%edx
  104701:	8b 45 10             	mov    0x10(%ebp),%eax
  104704:	01 c2                	add    %eax,%edx
  104706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104709:	01 d0                	add    %edx,%eax
  10470b:	48                   	dec    %eax
  10470c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10470f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104712:	ba 00 00 00 00       	mov    $0x0,%edx
  104717:	f7 75 f0             	divl   -0x10(%ebp)
  10471a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10471d:	29 d0                	sub    %edx,%eax
  10471f:	c1 e8 0c             	shr    $0xc,%eax
  104722:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104725:	8b 45 0c             	mov    0xc(%ebp),%eax
  104728:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10472b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10472e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104733:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104736:	8b 45 14             	mov    0x14(%ebp),%eax
  104739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10473c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10473f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104744:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104747:	eb 68                	jmp    1047b1 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104749:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104750:	00 
  104751:	8b 45 0c             	mov    0xc(%ebp),%eax
  104754:	89 44 24 04          	mov    %eax,0x4(%esp)
  104758:	8b 45 08             	mov    0x8(%ebp),%eax
  10475b:	89 04 24             	mov    %eax,(%esp)
  10475e:	e8 88 01 00 00       	call   1048eb <get_pte>
  104763:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104766:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10476a:	75 24                	jne    104790 <boot_map_segment+0xd9>
  10476c:	c7 44 24 0c 7e 70 10 	movl   $0x10707e,0xc(%esp)
  104773:	00 
  104774:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10477b:	00 
  10477c:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104783:	00 
  104784:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10478b:	e8 8d c5 ff ff       	call   100d1d <__panic>
        *ptep = pa | PTE_P | perm;
  104790:	8b 45 14             	mov    0x14(%ebp),%eax
  104793:	0b 45 18             	or     0x18(%ebp),%eax
  104796:	83 c8 01             	or     $0x1,%eax
  104799:	89 c2                	mov    %eax,%edx
  10479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10479e:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1047a0:	ff 4d f4             	decl   -0xc(%ebp)
  1047a3:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1047aa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1047b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1047b5:	75 92                	jne    104749 <boot_map_segment+0x92>
    }
}
  1047b7:	90                   	nop
  1047b8:	90                   	nop
  1047b9:	89 ec                	mov    %ebp,%esp
  1047bb:	5d                   	pop    %ebp
  1047bc:	c3                   	ret    

001047bd <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1047bd:	55                   	push   %ebp
  1047be:	89 e5                	mov    %esp,%ebp
  1047c0:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1047c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047ca:	e8 8a fa ff ff       	call   104259 <alloc_pages>
  1047cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1047d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1047d6:	75 1c                	jne    1047f4 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1047d8:	c7 44 24 08 8b 70 10 	movl   $0x10708b,0x8(%esp)
  1047df:	00 
  1047e0:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  1047e7:	00 
  1047e8:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1047ef:	e8 29 c5 ff ff       	call   100d1d <__panic>
    }
    return page2kva(p);
  1047f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047f7:	89 04 24             	mov    %eax,(%esp)
  1047fa:	e8 9a f7 ff ff       	call   103f99 <page2kva>
}
  1047ff:	89 ec                	mov    %ebp,%esp
  104801:	5d                   	pop    %ebp
  104802:	c3                   	ret    

00104803 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  104803:	55                   	push   %ebp
  104804:	89 e5                	mov    %esp,%ebp
  104806:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104809:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10480e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104811:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104818:	77 23                	ja     10483d <pmm_init+0x3a>
  10481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10481d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104821:	c7 44 24 08 20 70 10 	movl   $0x107020,0x8(%esp)
  104828:	00 
  104829:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  104830:	00 
  104831:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104838:	e8 e0 c4 ff ff       	call   100d1d <__panic>
  10483d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104840:	05 00 00 00 40       	add    $0x40000000,%eax
  104845:	a3 08 cf 11 00       	mov    %eax,0x11cf08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10484a:	e8 b2 f9 ff ff       	call   104201 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10484f:	e8 a1 fa ff ff       	call   1042f5 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104854:	e8 ed 03 00 00       	call   104c46 <check_alloc_page>

    check_pgdir();
  104859:	e8 09 04 00 00       	call   104c67 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10485e:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104863:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104866:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10486d:	77 23                	ja     104892 <pmm_init+0x8f>
  10486f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104872:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104876:	c7 44 24 08 20 70 10 	movl   $0x107020,0x8(%esp)
  10487d:	00 
  10487e:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  104885:	00 
  104886:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10488d:	e8 8b c4 ff ff       	call   100d1d <__panic>
  104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104895:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10489b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1048a0:	05 ac 0f 00 00       	add    $0xfac,%eax
  1048a5:	83 ca 03             	or     $0x3,%edx
  1048a8:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1048aa:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1048af:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1048b6:	00 
  1048b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1048be:	00 
  1048bf:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1048c6:	38 
  1048c7:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1048ce:	c0 
  1048cf:	89 04 24             	mov    %eax,(%esp)
  1048d2:	e8 e0 fd ff ff       	call   1046b7 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1048d7:	e8 39 f8 ff ff       	call   104115 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1048dc:	e8 24 0a 00 00       	call   105305 <check_boot_pgdir>

    print_pgdir();
  1048e1:	e8 a1 0e 00 00       	call   105787 <print_pgdir>

}
  1048e6:	90                   	nop
  1048e7:	89 ec                	mov    %ebp,%esp
  1048e9:	5d                   	pop    %ebp
  1048ea:	c3                   	ret    

001048eb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1048eb:	55                   	push   %ebp
  1048ec:	89 e5                	mov    %esp,%ebp
  1048ee:	83 ec 38             	sub    $0x38,%esp
        }
        return NULL;          // (8) return page table entry
    #endif
    */
   
   pde_t *pdep = &pgdir[PDX(la)];
  1048f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048f4:	c1 e8 16             	shr    $0x16,%eax
  1048f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1048fe:	8b 45 08             	mov    0x8(%ebp),%eax
  104901:	01 d0                	add    %edx,%eax
  104903:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104909:	8b 00                	mov    (%eax),%eax
  10490b:	83 e0 01             	and    $0x1,%eax
  10490e:	85 c0                	test   %eax,%eax
  104910:	0f 85 af 00 00 00    	jne    1049c5 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  104916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10491a:	74 15                	je     104931 <get_pte+0x46>
  10491c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104923:	e8 31 f9 ff ff       	call   104259 <alloc_pages>
  104928:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10492b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10492f:	75 0a                	jne    10493b <get_pte+0x50>
            return NULL;
  104931:	b8 00 00 00 00       	mov    $0x0,%eax
  104936:	e9 e7 00 00 00       	jmp    104a22 <get_pte+0x137>
        }
        set_page_ref(page, 1);
  10493b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104942:	00 
  104943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104946:	89 04 24             	mov    %eax,(%esp)
  104949:	e8 05 f7 ff ff       	call   104053 <set_page_ref>
        uintptr_t pa = page2pa(page);
  10494e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104951:	89 04 24             	mov    %eax,(%esp)
  104954:	e8 d7 f5 ff ff       	call   103f30 <page2pa>
  104959:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  10495c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10495f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104962:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104965:	c1 e8 0c             	shr    $0xc,%eax
  104968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10496b:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104970:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  104973:	72 23                	jb     104998 <get_pte+0xad>
  104975:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10497c:	c7 44 24 08 7c 6f 10 	movl   $0x106f7c,0x8(%esp)
  104983:	00 
  104984:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
  10498b:	00 
  10498c:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104993:	e8 85 c3 ff ff       	call   100d1d <__panic>
  104998:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10499b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1049a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1049a7:	00 
  1049a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1049af:	00 
  1049b0:	89 04 24             	mov    %eax,(%esp)
  1049b3:	e8 d4 18 00 00       	call   10628c <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  1049b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049bb:	83 c8 07             	or     $0x7,%eax
  1049be:	89 c2                	mov    %eax,%edx
  1049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049c3:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049c8:	8b 00                	mov    (%eax),%eax
  1049ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1049cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1049d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1049d5:	c1 e8 0c             	shr    $0xc,%eax
  1049d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1049db:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1049e0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1049e3:	72 23                	jb     104a08 <get_pte+0x11d>
  1049e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1049e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049ec:	c7 44 24 08 7c 6f 10 	movl   $0x106f7c,0x8(%esp)
  1049f3:	00 
  1049f4:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
  1049fb:	00 
  1049fc:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104a03:	e8 15 c3 ff ff       	call   100d1d <__panic>
  104a08:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a0b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104a10:	89 c2                	mov    %eax,%edx
  104a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  104a15:	c1 e8 0c             	shr    $0xc,%eax
  104a18:	25 ff 03 00 00       	and    $0x3ff,%eax
  104a1d:	c1 e0 02             	shl    $0x2,%eax
  104a20:	01 d0                	add    %edx,%eax
}
  104a22:	89 ec                	mov    %ebp,%esp
  104a24:	5d                   	pop    %ebp
  104a25:	c3                   	ret    

00104a26 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104a26:	55                   	push   %ebp
  104a27:	89 e5                	mov    %esp,%ebp
  104a29:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104a2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a33:	00 
  104a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  104a3e:	89 04 24             	mov    %eax,(%esp)
  104a41:	e8 a5 fe ff ff       	call   1048eb <get_pte>
  104a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  104a49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104a4d:	74 08                	je     104a57 <get_page+0x31>
        *ptep_store = ptep;
  104a4f:	8b 45 10             	mov    0x10(%ebp),%eax
  104a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104a55:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104a57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104a5b:	74 1b                	je     104a78 <get_page+0x52>
  104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a60:	8b 00                	mov    (%eax),%eax
  104a62:	83 e0 01             	and    $0x1,%eax
  104a65:	85 c0                	test   %eax,%eax
  104a67:	74 0f                	je     104a78 <get_page+0x52>
        return pte2page(*ptep);
  104a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a6c:	8b 00                	mov    (%eax),%eax
  104a6e:	89 04 24             	mov    %eax,(%esp)
  104a71:	e8 79 f5 ff ff       	call   103fef <pte2page>
  104a76:	eb 05                	jmp    104a7d <get_page+0x57>
    }
    return NULL;
  104a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104a7d:	89 ec                	mov    %ebp,%esp
  104a7f:	5d                   	pop    %ebp
  104a80:	c3                   	ret    

00104a81 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104a81:	55                   	push   %ebp
  104a82:	89 e5                	mov    %esp,%ebp
  104a84:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
*/

   	if (*ptep & PTE_P) {
  104a87:	8b 45 10             	mov    0x10(%ebp),%eax
  104a8a:	8b 00                	mov    (%eax),%eax
  104a8c:	83 e0 01             	and    $0x1,%eax
  104a8f:	85 c0                	test   %eax,%eax
  104a91:	74 4d                	je     104ae0 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  104a93:	8b 45 10             	mov    0x10(%ebp),%eax
  104a96:	8b 00                	mov    (%eax),%eax
  104a98:	89 04 24             	mov    %eax,(%esp)
  104a9b:	e8 4f f5 ff ff       	call   103fef <pte2page>
  104aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104aa6:	89 04 24             	mov    %eax,(%esp)
  104aa9:	e8 ca f5 ff ff       	call   104078 <page_ref_dec>
  104aae:	85 c0                	test   %eax,%eax
  104ab0:	75 13                	jne    104ac5 <page_remove_pte+0x44>
            free_page(page);
  104ab2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ab9:	00 
  104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104abd:	89 04 24             	mov    %eax,(%esp)
  104ac0:	e8 ce f7 ff ff       	call   104293 <free_pages>
        }
        *ptep = 0;
  104ac5:	8b 45 10             	mov    0x10(%ebp),%eax
  104ac8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  104ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  104ad8:	89 04 24             	mov    %eax,(%esp)
  104adb:	e8 07 01 00 00       	call   104be7 <tlb_invalidate>
    }

}
  104ae0:	90                   	nop
  104ae1:	89 ec                	mov    %ebp,%esp
  104ae3:	5d                   	pop    %ebp
  104ae4:	c3                   	ret    

00104ae5 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104ae5:	55                   	push   %ebp
  104ae6:	89 e5                	mov    %esp,%ebp
  104ae8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104aeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104af2:	00 
  104af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  104af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  104afa:	8b 45 08             	mov    0x8(%ebp),%eax
  104afd:	89 04 24             	mov    %eax,(%esp)
  104b00:	e8 e6 fd ff ff       	call   1048eb <get_pte>
  104b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104b08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104b0c:	74 19                	je     104b27 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  104b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b11:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  104b1f:	89 04 24             	mov    %eax,(%esp)
  104b22:	e8 5a ff ff ff       	call   104a81 <page_remove_pte>
    }
}
  104b27:	90                   	nop
  104b28:	89 ec                	mov    %ebp,%esp
  104b2a:	5d                   	pop    %ebp
  104b2b:	c3                   	ret    

00104b2c <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104b2c:	55                   	push   %ebp
  104b2d:	89 e5                	mov    %esp,%ebp
  104b2f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104b32:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104b39:	00 
  104b3a:	8b 45 10             	mov    0x10(%ebp),%eax
  104b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b41:	8b 45 08             	mov    0x8(%ebp),%eax
  104b44:	89 04 24             	mov    %eax,(%esp)
  104b47:	e8 9f fd ff ff       	call   1048eb <get_pte>
  104b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104b4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104b53:	75 0a                	jne    104b5f <page_insert+0x33>
        return -E_NO_MEM;
  104b55:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  104b5a:	e9 84 00 00 00       	jmp    104be3 <page_insert+0xb7>
    }
    page_ref_inc(page);
  104b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b62:	89 04 24             	mov    %eax,(%esp)
  104b65:	e8 f7 f4 ff ff       	call   104061 <page_ref_inc>
    if (*ptep & PTE_P) {
  104b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b6d:	8b 00                	mov    (%eax),%eax
  104b6f:	83 e0 01             	and    $0x1,%eax
  104b72:	85 c0                	test   %eax,%eax
  104b74:	74 3e                	je     104bb4 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  104b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b79:	8b 00                	mov    (%eax),%eax
  104b7b:	89 04 24             	mov    %eax,(%esp)
  104b7e:	e8 6c f4 ff ff       	call   103fef <pte2page>
  104b83:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b89:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104b8c:	75 0d                	jne    104b9b <page_insert+0x6f>
            page_ref_dec(page);
  104b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b91:	89 04 24             	mov    %eax,(%esp)
  104b94:	e8 df f4 ff ff       	call   104078 <page_ref_dec>
  104b99:	eb 19                	jmp    104bb4 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  104ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  104ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  104bac:	89 04 24             	mov    %eax,(%esp)
  104baf:	e8 cd fe ff ff       	call   104a81 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  104bb7:	89 04 24             	mov    %eax,(%esp)
  104bba:	e8 71 f3 ff ff       	call   103f30 <page2pa>
  104bbf:	0b 45 14             	or     0x14(%ebp),%eax
  104bc2:	83 c8 01             	or     $0x1,%eax
  104bc5:	89 c2                	mov    %eax,%edx
  104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bca:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  104bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  104bd6:	89 04 24             	mov    %eax,(%esp)
  104bd9:	e8 09 00 00 00       	call   104be7 <tlb_invalidate>
    return 0;
  104bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104be3:	89 ec                	mov    %ebp,%esp
  104be5:	5d                   	pop    %ebp
  104be6:	c3                   	ret    

00104be7 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104be7:	55                   	push   %ebp
  104be8:	89 e5                	mov    %esp,%ebp
  104bea:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104bed:	0f 20 d8             	mov    %cr3,%eax
  104bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104bf3:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  104bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104bfc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104c03:	77 23                	ja     104c28 <tlb_invalidate+0x41>
  104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104c0c:	c7 44 24 08 20 70 10 	movl   $0x107020,0x8(%esp)
  104c13:	00 
  104c14:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  104c1b:	00 
  104c1c:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104c23:	e8 f5 c0 ff ff       	call   100d1d <__panic>
  104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c2b:	05 00 00 00 40       	add    $0x40000000,%eax
  104c30:	39 d0                	cmp    %edx,%eax
  104c32:	75 0d                	jne    104c41 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  104c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c3d:	0f 01 38             	invlpg (%eax)
}
  104c40:	90                   	nop
    }
}
  104c41:	90                   	nop
  104c42:	89 ec                	mov    %ebp,%esp
  104c44:	5d                   	pop    %ebp
  104c45:	c3                   	ret    

00104c46 <check_alloc_page>:

static void
check_alloc_page(void) {
  104c46:	55                   	push   %ebp
  104c47:	89 e5                	mov    %esp,%ebp
  104c49:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  104c4c:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104c51:	8b 40 18             	mov    0x18(%eax),%eax
  104c54:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104c56:	c7 04 24 a4 70 10 00 	movl   $0x1070a4,(%esp)
  104c5d:	e8 39 b7 ff ff       	call   10039b <cprintf>
}
  104c62:	90                   	nop
  104c63:	89 ec                	mov    %ebp,%esp
  104c65:	5d                   	pop    %ebp
  104c66:	c3                   	ret    

00104c67 <check_pgdir>:

static void
check_pgdir(void) {
  104c67:	55                   	push   %ebp
  104c68:	89 e5                	mov    %esp,%ebp
  104c6a:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104c6d:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104c72:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104c77:	76 24                	jbe    104c9d <check_pgdir+0x36>
  104c79:	c7 44 24 0c c3 70 10 	movl   $0x1070c3,0xc(%esp)
  104c80:	00 
  104c81:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104c88:	00 
  104c89:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  104c90:	00 
  104c91:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104c98:	e8 80 c0 ff ff       	call   100d1d <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104c9d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ca2:	85 c0                	test   %eax,%eax
  104ca4:	74 0e                	je     104cb4 <check_pgdir+0x4d>
  104ca6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cab:	25 ff 0f 00 00       	and    $0xfff,%eax
  104cb0:	85 c0                	test   %eax,%eax
  104cb2:	74 24                	je     104cd8 <check_pgdir+0x71>
  104cb4:	c7 44 24 0c e0 70 10 	movl   $0x1070e0,0xc(%esp)
  104cbb:	00 
  104cbc:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104cc3:	00 
  104cc4:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104ccb:	00 
  104ccc:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104cd3:	e8 45 c0 ff ff       	call   100d1d <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104cd8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ce4:	00 
  104ce5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104cec:	00 
  104ced:	89 04 24             	mov    %eax,(%esp)
  104cf0:	e8 31 fd ff ff       	call   104a26 <get_page>
  104cf5:	85 c0                	test   %eax,%eax
  104cf7:	74 24                	je     104d1d <check_pgdir+0xb6>
  104cf9:	c7 44 24 0c 18 71 10 	movl   $0x107118,0xc(%esp)
  104d00:	00 
  104d01:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104d08:	00 
  104d09:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  104d10:	00 
  104d11:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104d18:	e8 00 c0 ff ff       	call   100d1d <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104d1d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d24:	e8 30 f5 ff ff       	call   104259 <alloc_pages>
  104d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104d2c:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104d31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104d38:	00 
  104d39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104d40:	00 
  104d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d44:	89 54 24 04          	mov    %edx,0x4(%esp)
  104d48:	89 04 24             	mov    %eax,(%esp)
  104d4b:	e8 dc fd ff ff       	call   104b2c <page_insert>
  104d50:	85 c0                	test   %eax,%eax
  104d52:	74 24                	je     104d78 <check_pgdir+0x111>
  104d54:	c7 44 24 0c 40 71 10 	movl   $0x107140,0xc(%esp)
  104d5b:	00 
  104d5c:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104d63:	00 
  104d64:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104d6b:	00 
  104d6c:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104d73:	e8 a5 bf ff ff       	call   100d1d <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104d78:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104d7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104d84:	00 
  104d85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104d8c:	00 
  104d8d:	89 04 24             	mov    %eax,(%esp)
  104d90:	e8 56 fb ff ff       	call   1048eb <get_pte>
  104d95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104d9c:	75 24                	jne    104dc2 <check_pgdir+0x15b>
  104d9e:	c7 44 24 0c 6c 71 10 	movl   $0x10716c,0xc(%esp)
  104da5:	00 
  104da6:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104dad:	00 
  104dae:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104db5:	00 
  104db6:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104dbd:	e8 5b bf ff ff       	call   100d1d <__panic>
    assert(pte2page(*ptep) == p1);
  104dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dc5:	8b 00                	mov    (%eax),%eax
  104dc7:	89 04 24             	mov    %eax,(%esp)
  104dca:	e8 20 f2 ff ff       	call   103fef <pte2page>
  104dcf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104dd2:	74 24                	je     104df8 <check_pgdir+0x191>
  104dd4:	c7 44 24 0c 99 71 10 	movl   $0x107199,0xc(%esp)
  104ddb:	00 
  104ddc:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104de3:	00 
  104de4:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104deb:	00 
  104dec:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104df3:	e8 25 bf ff ff       	call   100d1d <__panic>
    assert(page_ref(p1) == 1);
  104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104dfb:	89 04 24             	mov    %eax,(%esp)
  104dfe:	e8 46 f2 ff ff       	call   104049 <page_ref>
  104e03:	83 f8 01             	cmp    $0x1,%eax
  104e06:	74 24                	je     104e2c <check_pgdir+0x1c5>
  104e08:	c7 44 24 0c af 71 10 	movl   $0x1071af,0xc(%esp)
  104e0f:	00 
  104e10:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104e17:	00 
  104e18:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  104e1f:	00 
  104e20:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104e27:	e8 f1 be ff ff       	call   100d1d <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104e2c:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104e31:	8b 00                	mov    (%eax),%eax
  104e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104e38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e3e:	c1 e8 0c             	shr    $0xc,%eax
  104e41:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104e44:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104e49:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104e4c:	72 23                	jb     104e71 <check_pgdir+0x20a>
  104e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104e55:	c7 44 24 08 7c 6f 10 	movl   $0x106f7c,0x8(%esp)
  104e5c:	00 
  104e5d:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104e64:	00 
  104e65:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104e6c:	e8 ac be ff ff       	call   100d1d <__panic>
  104e71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e74:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104e79:	83 c0 04             	add    $0x4,%eax
  104e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104e7f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104e84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104e8b:	00 
  104e8c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104e93:	00 
  104e94:	89 04 24             	mov    %eax,(%esp)
  104e97:	e8 4f fa ff ff       	call   1048eb <get_pte>
  104e9c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104e9f:	74 24                	je     104ec5 <check_pgdir+0x25e>
  104ea1:	c7 44 24 0c c4 71 10 	movl   $0x1071c4,0xc(%esp)
  104ea8:	00 
  104ea9:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104eb0:	00 
  104eb1:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104eb8:	00 
  104eb9:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104ec0:	e8 58 be ff ff       	call   100d1d <__panic>

    p2 = alloc_page();
  104ec5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ecc:	e8 88 f3 ff ff       	call   104259 <alloc_pages>
  104ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104ed4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ed9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104ee0:	00 
  104ee1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104ee8:	00 
  104ee9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104eec:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ef0:	89 04 24             	mov    %eax,(%esp)
  104ef3:	e8 34 fc ff ff       	call   104b2c <page_insert>
  104ef8:	85 c0                	test   %eax,%eax
  104efa:	74 24                	je     104f20 <check_pgdir+0x2b9>
  104efc:	c7 44 24 0c ec 71 10 	movl   $0x1071ec,0xc(%esp)
  104f03:	00 
  104f04:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104f0b:	00 
  104f0c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104f13:	00 
  104f14:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104f1b:	e8 fd bd ff ff       	call   100d1d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104f20:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104f2c:	00 
  104f2d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104f34:	00 
  104f35:	89 04 24             	mov    %eax,(%esp)
  104f38:	e8 ae f9 ff ff       	call   1048eb <get_pte>
  104f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104f40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104f44:	75 24                	jne    104f6a <check_pgdir+0x303>
  104f46:	c7 44 24 0c 24 72 10 	movl   $0x107224,0xc(%esp)
  104f4d:	00 
  104f4e:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104f55:	00 
  104f56:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  104f5d:	00 
  104f5e:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104f65:	e8 b3 bd ff ff       	call   100d1d <__panic>
    assert(*ptep & PTE_U);
  104f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f6d:	8b 00                	mov    (%eax),%eax
  104f6f:	83 e0 04             	and    $0x4,%eax
  104f72:	85 c0                	test   %eax,%eax
  104f74:	75 24                	jne    104f9a <check_pgdir+0x333>
  104f76:	c7 44 24 0c 54 72 10 	movl   $0x107254,0xc(%esp)
  104f7d:	00 
  104f7e:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104f85:	00 
  104f86:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104f8d:	00 
  104f8e:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104f95:	e8 83 bd ff ff       	call   100d1d <__panic>
    assert(*ptep & PTE_W);
  104f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f9d:	8b 00                	mov    (%eax),%eax
  104f9f:	83 e0 02             	and    $0x2,%eax
  104fa2:	85 c0                	test   %eax,%eax
  104fa4:	75 24                	jne    104fca <check_pgdir+0x363>
  104fa6:	c7 44 24 0c 62 72 10 	movl   $0x107262,0xc(%esp)
  104fad:	00 
  104fae:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104fb5:	00 
  104fb6:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104fbd:	00 
  104fbe:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104fc5:	e8 53 bd ff ff       	call   100d1d <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104fca:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104fcf:	8b 00                	mov    (%eax),%eax
  104fd1:	83 e0 04             	and    $0x4,%eax
  104fd4:	85 c0                	test   %eax,%eax
  104fd6:	75 24                	jne    104ffc <check_pgdir+0x395>
  104fd8:	c7 44 24 0c 70 72 10 	movl   $0x107270,0xc(%esp)
  104fdf:	00 
  104fe0:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  104fe7:	00 
  104fe8:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104fef:	00 
  104ff0:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  104ff7:	e8 21 bd ff ff       	call   100d1d <__panic>
    assert(page_ref(p2) == 1);
  104ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fff:	89 04 24             	mov    %eax,(%esp)
  105002:	e8 42 f0 ff ff       	call   104049 <page_ref>
  105007:	83 f8 01             	cmp    $0x1,%eax
  10500a:	74 24                	je     105030 <check_pgdir+0x3c9>
  10500c:	c7 44 24 0c 86 72 10 	movl   $0x107286,0xc(%esp)
  105013:	00 
  105014:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10501b:	00 
  10501c:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  105023:	00 
  105024:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10502b:	e8 ed bc ff ff       	call   100d1d <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  105030:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10503c:	00 
  10503d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105044:	00 
  105045:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105048:	89 54 24 04          	mov    %edx,0x4(%esp)
  10504c:	89 04 24             	mov    %eax,(%esp)
  10504f:	e8 d8 fa ff ff       	call   104b2c <page_insert>
  105054:	85 c0                	test   %eax,%eax
  105056:	74 24                	je     10507c <check_pgdir+0x415>
  105058:	c7 44 24 0c 98 72 10 	movl   $0x107298,0xc(%esp)
  10505f:	00 
  105060:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105067:	00 
  105068:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  10506f:	00 
  105070:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105077:	e8 a1 bc ff ff       	call   100d1d <__panic>
    assert(page_ref(p1) == 2);
  10507c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10507f:	89 04 24             	mov    %eax,(%esp)
  105082:	e8 c2 ef ff ff       	call   104049 <page_ref>
  105087:	83 f8 02             	cmp    $0x2,%eax
  10508a:	74 24                	je     1050b0 <check_pgdir+0x449>
  10508c:	c7 44 24 0c c4 72 10 	movl   $0x1072c4,0xc(%esp)
  105093:	00 
  105094:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10509b:	00 
  10509c:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  1050a3:	00 
  1050a4:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1050ab:	e8 6d bc ff ff       	call   100d1d <__panic>
    assert(page_ref(p2) == 0);
  1050b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050b3:	89 04 24             	mov    %eax,(%esp)
  1050b6:	e8 8e ef ff ff       	call   104049 <page_ref>
  1050bb:	85 c0                	test   %eax,%eax
  1050bd:	74 24                	je     1050e3 <check_pgdir+0x47c>
  1050bf:	c7 44 24 0c d6 72 10 	movl   $0x1072d6,0xc(%esp)
  1050c6:	00 
  1050c7:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1050ce:	00 
  1050cf:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  1050d6:	00 
  1050d7:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1050de:	e8 3a bc ff ff       	call   100d1d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  1050e3:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1050ef:	00 
  1050f0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1050f7:	00 
  1050f8:	89 04 24             	mov    %eax,(%esp)
  1050fb:	e8 eb f7 ff ff       	call   1048eb <get_pte>
  105100:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105103:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105107:	75 24                	jne    10512d <check_pgdir+0x4c6>
  105109:	c7 44 24 0c 24 72 10 	movl   $0x107224,0xc(%esp)
  105110:	00 
  105111:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105118:	00 
  105119:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  105120:	00 
  105121:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105128:	e8 f0 bb ff ff       	call   100d1d <__panic>
    assert(pte2page(*ptep) == p1);
  10512d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105130:	8b 00                	mov    (%eax),%eax
  105132:	89 04 24             	mov    %eax,(%esp)
  105135:	e8 b5 ee ff ff       	call   103fef <pte2page>
  10513a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10513d:	74 24                	je     105163 <check_pgdir+0x4fc>
  10513f:	c7 44 24 0c 99 71 10 	movl   $0x107199,0xc(%esp)
  105146:	00 
  105147:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10514e:	00 
  10514f:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  105156:	00 
  105157:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10515e:	e8 ba bb ff ff       	call   100d1d <__panic>
    assert((*ptep & PTE_U) == 0);
  105163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105166:	8b 00                	mov    (%eax),%eax
  105168:	83 e0 04             	and    $0x4,%eax
  10516b:	85 c0                	test   %eax,%eax
  10516d:	74 24                	je     105193 <check_pgdir+0x52c>
  10516f:	c7 44 24 0c e8 72 10 	movl   $0x1072e8,0xc(%esp)
  105176:	00 
  105177:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10517e:	00 
  10517f:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  105186:	00 
  105187:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10518e:	e8 8a bb ff ff       	call   100d1d <__panic>

    page_remove(boot_pgdir, 0x0);
  105193:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10519f:	00 
  1051a0:	89 04 24             	mov    %eax,(%esp)
  1051a3:	e8 3d f9 ff ff       	call   104ae5 <page_remove>
    assert(page_ref(p1) == 1);
  1051a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1051ab:	89 04 24             	mov    %eax,(%esp)
  1051ae:	e8 96 ee ff ff       	call   104049 <page_ref>
  1051b3:	83 f8 01             	cmp    $0x1,%eax
  1051b6:	74 24                	je     1051dc <check_pgdir+0x575>
  1051b8:	c7 44 24 0c af 71 10 	movl   $0x1071af,0xc(%esp)
  1051bf:	00 
  1051c0:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1051c7:	00 
  1051c8:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  1051cf:	00 
  1051d0:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1051d7:	e8 41 bb ff ff       	call   100d1d <__panic>
    assert(page_ref(p2) == 0);
  1051dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1051df:	89 04 24             	mov    %eax,(%esp)
  1051e2:	e8 62 ee ff ff       	call   104049 <page_ref>
  1051e7:	85 c0                	test   %eax,%eax
  1051e9:	74 24                	je     10520f <check_pgdir+0x5a8>
  1051eb:	c7 44 24 0c d6 72 10 	movl   $0x1072d6,0xc(%esp)
  1051f2:	00 
  1051f3:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1051fa:	00 
  1051fb:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  105202:	00 
  105203:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10520a:	e8 0e bb ff ff       	call   100d1d <__panic>

    page_remove(boot_pgdir, PGSIZE);
  10520f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105214:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10521b:	00 
  10521c:	89 04 24             	mov    %eax,(%esp)
  10521f:	e8 c1 f8 ff ff       	call   104ae5 <page_remove>
    assert(page_ref(p1) == 0);
  105224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105227:	89 04 24             	mov    %eax,(%esp)
  10522a:	e8 1a ee ff ff       	call   104049 <page_ref>
  10522f:	85 c0                	test   %eax,%eax
  105231:	74 24                	je     105257 <check_pgdir+0x5f0>
  105233:	c7 44 24 0c fd 72 10 	movl   $0x1072fd,0xc(%esp)
  10523a:	00 
  10523b:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105242:	00 
  105243:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  10524a:	00 
  10524b:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105252:	e8 c6 ba ff ff       	call   100d1d <__panic>
    assert(page_ref(p2) == 0);
  105257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10525a:	89 04 24             	mov    %eax,(%esp)
  10525d:	e8 e7 ed ff ff       	call   104049 <page_ref>
  105262:	85 c0                	test   %eax,%eax
  105264:	74 24                	je     10528a <check_pgdir+0x623>
  105266:	c7 44 24 0c d6 72 10 	movl   $0x1072d6,0xc(%esp)
  10526d:	00 
  10526e:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105275:	00 
  105276:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  10527d:	00 
  10527e:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105285:	e8 93 ba ff ff       	call   100d1d <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  10528a:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10528f:	8b 00                	mov    (%eax),%eax
  105291:	89 04 24             	mov    %eax,(%esp)
  105294:	e8 96 ed ff ff       	call   10402f <pde2page>
  105299:	89 04 24             	mov    %eax,(%esp)
  10529c:	e8 a8 ed ff ff       	call   104049 <page_ref>
  1052a1:	83 f8 01             	cmp    $0x1,%eax
  1052a4:	74 24                	je     1052ca <check_pgdir+0x663>
  1052a6:	c7 44 24 0c 10 73 10 	movl   $0x107310,0xc(%esp)
  1052ad:	00 
  1052ae:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1052b5:	00 
  1052b6:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  1052bd:	00 
  1052be:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1052c5:	e8 53 ba ff ff       	call   100d1d <__panic>
    free_page(pde2page(boot_pgdir[0]));
  1052ca:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1052cf:	8b 00                	mov    (%eax),%eax
  1052d1:	89 04 24             	mov    %eax,(%esp)
  1052d4:	e8 56 ed ff ff       	call   10402f <pde2page>
  1052d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052e0:	00 
  1052e1:	89 04 24             	mov    %eax,(%esp)
  1052e4:	e8 aa ef ff ff       	call   104293 <free_pages>
    boot_pgdir[0] = 0;
  1052e9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1052ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  1052f4:	c7 04 24 37 73 10 00 	movl   $0x107337,(%esp)
  1052fb:	e8 9b b0 ff ff       	call   10039b <cprintf>
}
  105300:	90                   	nop
  105301:	89 ec                	mov    %ebp,%esp
  105303:	5d                   	pop    %ebp
  105304:	c3                   	ret    

00105305 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  105305:	55                   	push   %ebp
  105306:	89 e5                	mov    %esp,%ebp
  105308:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  10530b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105312:	e9 ca 00 00 00       	jmp    1053e1 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  105317:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10531a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10531d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105320:	c1 e8 0c             	shr    $0xc,%eax
  105323:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105326:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  10532b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10532e:	72 23                	jb     105353 <check_boot_pgdir+0x4e>
  105330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105333:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105337:	c7 44 24 08 7c 6f 10 	movl   $0x106f7c,0x8(%esp)
  10533e:	00 
  10533f:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  105346:	00 
  105347:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10534e:	e8 ca b9 ff ff       	call   100d1d <__panic>
  105353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105356:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10535b:	89 c2                	mov    %eax,%edx
  10535d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105369:	00 
  10536a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10536e:	89 04 24             	mov    %eax,(%esp)
  105371:	e8 75 f5 ff ff       	call   1048eb <get_pte>
  105376:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105379:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10537d:	75 24                	jne    1053a3 <check_boot_pgdir+0x9e>
  10537f:	c7 44 24 0c 54 73 10 	movl   $0x107354,0xc(%esp)
  105386:	00 
  105387:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10538e:	00 
  10538f:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  105396:	00 
  105397:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10539e:	e8 7a b9 ff ff       	call   100d1d <__panic>
        assert(PTE_ADDR(*ptep) == i);
  1053a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053a6:	8b 00                	mov    (%eax),%eax
  1053a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1053ad:	89 c2                	mov    %eax,%edx
  1053af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053b2:	39 c2                	cmp    %eax,%edx
  1053b4:	74 24                	je     1053da <check_boot_pgdir+0xd5>
  1053b6:	c7 44 24 0c 91 73 10 	movl   $0x107391,0xc(%esp)
  1053bd:	00 
  1053be:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1053c5:	00 
  1053c6:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  1053cd:	00 
  1053ce:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1053d5:	e8 43 b9 ff ff       	call   100d1d <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  1053da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1053e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1053e4:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1053e9:	39 c2                	cmp    %eax,%edx
  1053eb:	0f 82 26 ff ff ff    	jb     105317 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  1053f1:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1053f6:	05 ac 0f 00 00       	add    $0xfac,%eax
  1053fb:	8b 00                	mov    (%eax),%eax
  1053fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105402:	89 c2                	mov    %eax,%edx
  105404:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105409:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10540c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  105413:	77 23                	ja     105438 <check_boot_pgdir+0x133>
  105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10541c:	c7 44 24 08 20 70 10 	movl   $0x107020,0x8(%esp)
  105423:	00 
  105424:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  10542b:	00 
  10542c:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105433:	e8 e5 b8 ff ff       	call   100d1d <__panic>
  105438:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10543b:	05 00 00 00 40       	add    $0x40000000,%eax
  105440:	39 d0                	cmp    %edx,%eax
  105442:	74 24                	je     105468 <check_boot_pgdir+0x163>
  105444:	c7 44 24 0c a8 73 10 	movl   $0x1073a8,0xc(%esp)
  10544b:	00 
  10544c:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105453:	00 
  105454:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  10545b:	00 
  10545c:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105463:	e8 b5 b8 ff ff       	call   100d1d <__panic>

    assert(boot_pgdir[0] == 0);
  105468:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10546d:	8b 00                	mov    (%eax),%eax
  10546f:	85 c0                	test   %eax,%eax
  105471:	74 24                	je     105497 <check_boot_pgdir+0x192>
  105473:	c7 44 24 0c dc 73 10 	movl   $0x1073dc,0xc(%esp)
  10547a:	00 
  10547b:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105482:	00 
  105483:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  10548a:	00 
  10548b:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105492:	e8 86 b8 ff ff       	call   100d1d <__panic>

    struct Page *p;
    p = alloc_page();
  105497:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10549e:	e8 b6 ed ff ff       	call   104259 <alloc_pages>
  1054a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  1054a6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1054ab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1054b2:	00 
  1054b3:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  1054ba:	00 
  1054bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054be:	89 54 24 04          	mov    %edx,0x4(%esp)
  1054c2:	89 04 24             	mov    %eax,(%esp)
  1054c5:	e8 62 f6 ff ff       	call   104b2c <page_insert>
  1054ca:	85 c0                	test   %eax,%eax
  1054cc:	74 24                	je     1054f2 <check_boot_pgdir+0x1ed>
  1054ce:	c7 44 24 0c f0 73 10 	movl   $0x1073f0,0xc(%esp)
  1054d5:	00 
  1054d6:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1054dd:	00 
  1054de:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  1054e5:	00 
  1054e6:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1054ed:	e8 2b b8 ff ff       	call   100d1d <__panic>
    assert(page_ref(p) == 1);
  1054f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1054f5:	89 04 24             	mov    %eax,(%esp)
  1054f8:	e8 4c eb ff ff       	call   104049 <page_ref>
  1054fd:	83 f8 01             	cmp    $0x1,%eax
  105500:	74 24                	je     105526 <check_boot_pgdir+0x221>
  105502:	c7 44 24 0c 1e 74 10 	movl   $0x10741e,0xc(%esp)
  105509:	00 
  10550a:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105511:	00 
  105512:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  105519:	00 
  10551a:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  105521:	e8 f7 b7 ff ff       	call   100d1d <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105526:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10552b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105532:	00 
  105533:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10553a:	00 
  10553b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10553e:	89 54 24 04          	mov    %edx,0x4(%esp)
  105542:	89 04 24             	mov    %eax,(%esp)
  105545:	e8 e2 f5 ff ff       	call   104b2c <page_insert>
  10554a:	85 c0                	test   %eax,%eax
  10554c:	74 24                	je     105572 <check_boot_pgdir+0x26d>
  10554e:	c7 44 24 0c 30 74 10 	movl   $0x107430,0xc(%esp)
  105555:	00 
  105556:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10555d:	00 
  10555e:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
  105565:	00 
  105566:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10556d:	e8 ab b7 ff ff       	call   100d1d <__panic>
    assert(page_ref(p) == 2);
  105572:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105575:	89 04 24             	mov    %eax,(%esp)
  105578:	e8 cc ea ff ff       	call   104049 <page_ref>
  10557d:	83 f8 02             	cmp    $0x2,%eax
  105580:	74 24                	je     1055a6 <check_boot_pgdir+0x2a1>
  105582:	c7 44 24 0c 67 74 10 	movl   $0x107467,0xc(%esp)
  105589:	00 
  10558a:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  105591:	00 
  105592:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  105599:	00 
  10559a:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1055a1:	e8 77 b7 ff ff       	call   100d1d <__panic>

    const char *str = "ucore: Hello world!!";
  1055a6:	c7 45 e8 78 74 10 00 	movl   $0x107478,-0x18(%ebp)
    strcpy((void *)0x100, str);
  1055ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1055b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055b4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1055bb:	e8 fc 09 00 00       	call   105fbc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1055c0:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1055c7:	00 
  1055c8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1055cf:	e8 60 0a 00 00       	call   106034 <strcmp>
  1055d4:	85 c0                	test   %eax,%eax
  1055d6:	74 24                	je     1055fc <check_boot_pgdir+0x2f7>
  1055d8:	c7 44 24 0c 90 74 10 	movl   $0x107490,0xc(%esp)
  1055df:	00 
  1055e0:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  1055e7:	00 
  1055e8:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
  1055ef:	00 
  1055f0:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  1055f7:	e8 21 b7 ff ff       	call   100d1d <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1055fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055ff:	89 04 24             	mov    %eax,(%esp)
  105602:	e8 92 e9 ff ff       	call   103f99 <page2kva>
  105607:	05 00 01 00 00       	add    $0x100,%eax
  10560c:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10560f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105616:	e8 47 09 00 00       	call   105f62 <strlen>
  10561b:	85 c0                	test   %eax,%eax
  10561d:	74 24                	je     105643 <check_boot_pgdir+0x33e>
  10561f:	c7 44 24 0c c8 74 10 	movl   $0x1074c8,0xc(%esp)
  105626:	00 
  105627:	c7 44 24 08 69 70 10 	movl   $0x107069,0x8(%esp)
  10562e:	00 
  10562f:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  105636:	00 
  105637:	c7 04 24 44 70 10 00 	movl   $0x107044,(%esp)
  10563e:	e8 da b6 ff ff       	call   100d1d <__panic>

    free_page(p);
  105643:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10564a:	00 
  10564b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10564e:	89 04 24             	mov    %eax,(%esp)
  105651:	e8 3d ec ff ff       	call   104293 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105656:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10565b:	8b 00                	mov    (%eax),%eax
  10565d:	89 04 24             	mov    %eax,(%esp)
  105660:	e8 ca e9 ff ff       	call   10402f <pde2page>
  105665:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10566c:	00 
  10566d:	89 04 24             	mov    %eax,(%esp)
  105670:	e8 1e ec ff ff       	call   104293 <free_pages>
    boot_pgdir[0] = 0;
  105675:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10567a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105680:	c7 04 24 ec 74 10 00 	movl   $0x1074ec,(%esp)
  105687:	e8 0f ad ff ff       	call   10039b <cprintf>
}
  10568c:	90                   	nop
  10568d:	89 ec                	mov    %ebp,%esp
  10568f:	5d                   	pop    %ebp
  105690:	c3                   	ret    

00105691 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105691:	55                   	push   %ebp
  105692:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105694:	8b 45 08             	mov    0x8(%ebp),%eax
  105697:	83 e0 04             	and    $0x4,%eax
  10569a:	85 c0                	test   %eax,%eax
  10569c:	74 04                	je     1056a2 <perm2str+0x11>
  10569e:	b0 75                	mov    $0x75,%al
  1056a0:	eb 02                	jmp    1056a4 <perm2str+0x13>
  1056a2:	b0 2d                	mov    $0x2d,%al
  1056a4:	a2 88 cf 11 00       	mov    %al,0x11cf88
    str[1] = 'r';
  1056a9:	c6 05 89 cf 11 00 72 	movb   $0x72,0x11cf89
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1056b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b3:	83 e0 02             	and    $0x2,%eax
  1056b6:	85 c0                	test   %eax,%eax
  1056b8:	74 04                	je     1056be <perm2str+0x2d>
  1056ba:	b0 77                	mov    $0x77,%al
  1056bc:	eb 02                	jmp    1056c0 <perm2str+0x2f>
  1056be:	b0 2d                	mov    $0x2d,%al
  1056c0:	a2 8a cf 11 00       	mov    %al,0x11cf8a
    str[3] = '\0';
  1056c5:	c6 05 8b cf 11 00 00 	movb   $0x0,0x11cf8b
    return str;
  1056cc:	b8 88 cf 11 00       	mov    $0x11cf88,%eax
}
  1056d1:	5d                   	pop    %ebp
  1056d2:	c3                   	ret    

001056d3 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1056d3:	55                   	push   %ebp
  1056d4:	89 e5                	mov    %esp,%ebp
  1056d6:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1056d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1056dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1056df:	72 0d                	jb     1056ee <get_pgtable_items+0x1b>
        return 0;
  1056e1:	b8 00 00 00 00       	mov    $0x0,%eax
  1056e6:	e9 98 00 00 00       	jmp    105783 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1056eb:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1056ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1056f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1056f4:	73 18                	jae    10570e <get_pgtable_items+0x3b>
  1056f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1056f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105700:	8b 45 14             	mov    0x14(%ebp),%eax
  105703:	01 d0                	add    %edx,%eax
  105705:	8b 00                	mov    (%eax),%eax
  105707:	83 e0 01             	and    $0x1,%eax
  10570a:	85 c0                	test   %eax,%eax
  10570c:	74 dd                	je     1056eb <get_pgtable_items+0x18>
    }
    if (start < right) {
  10570e:	8b 45 10             	mov    0x10(%ebp),%eax
  105711:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105714:	73 68                	jae    10577e <get_pgtable_items+0xab>
        if (left_store != NULL) {
  105716:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10571a:	74 08                	je     105724 <get_pgtable_items+0x51>
            *left_store = start;
  10571c:	8b 45 18             	mov    0x18(%ebp),%eax
  10571f:	8b 55 10             	mov    0x10(%ebp),%edx
  105722:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105724:	8b 45 10             	mov    0x10(%ebp),%eax
  105727:	8d 50 01             	lea    0x1(%eax),%edx
  10572a:	89 55 10             	mov    %edx,0x10(%ebp)
  10572d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105734:	8b 45 14             	mov    0x14(%ebp),%eax
  105737:	01 d0                	add    %edx,%eax
  105739:	8b 00                	mov    (%eax),%eax
  10573b:	83 e0 07             	and    $0x7,%eax
  10573e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105741:	eb 03                	jmp    105746 <get_pgtable_items+0x73>
            start ++;
  105743:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105746:	8b 45 10             	mov    0x10(%ebp),%eax
  105749:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10574c:	73 1d                	jae    10576b <get_pgtable_items+0x98>
  10574e:	8b 45 10             	mov    0x10(%ebp),%eax
  105751:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105758:	8b 45 14             	mov    0x14(%ebp),%eax
  10575b:	01 d0                	add    %edx,%eax
  10575d:	8b 00                	mov    (%eax),%eax
  10575f:	83 e0 07             	and    $0x7,%eax
  105762:	89 c2                	mov    %eax,%edx
  105764:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105767:	39 c2                	cmp    %eax,%edx
  105769:	74 d8                	je     105743 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  10576b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10576f:	74 08                	je     105779 <get_pgtable_items+0xa6>
            *right_store = start;
  105771:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105774:	8b 55 10             	mov    0x10(%ebp),%edx
  105777:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105779:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10577c:	eb 05                	jmp    105783 <get_pgtable_items+0xb0>
    }
    return 0;
  10577e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105783:	89 ec                	mov    %ebp,%esp
  105785:	5d                   	pop    %ebp
  105786:	c3                   	ret    

00105787 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105787:	55                   	push   %ebp
  105788:	89 e5                	mov    %esp,%ebp
  10578a:	57                   	push   %edi
  10578b:	56                   	push   %esi
  10578c:	53                   	push   %ebx
  10578d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105790:	c7 04 24 0c 75 10 00 	movl   $0x10750c,(%esp)
  105797:	e8 ff ab ff ff       	call   10039b <cprintf>
    size_t left, right = 0, perm;
  10579c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1057a3:	e9 f2 00 00 00       	jmp    10589a <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1057a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057ab:	89 04 24             	mov    %eax,(%esp)
  1057ae:	e8 de fe ff ff       	call   105691 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1057b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1057b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1057b9:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1057bb:	89 d6                	mov    %edx,%esi
  1057bd:	c1 e6 16             	shl    $0x16,%esi
  1057c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1057c3:	89 d3                	mov    %edx,%ebx
  1057c5:	c1 e3 16             	shl    $0x16,%ebx
  1057c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1057cb:	89 d1                	mov    %edx,%ecx
  1057cd:	c1 e1 16             	shl    $0x16,%ecx
  1057d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1057d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  1057d6:	29 fa                	sub    %edi,%edx
  1057d8:	89 44 24 14          	mov    %eax,0x14(%esp)
  1057dc:	89 74 24 10          	mov    %esi,0x10(%esp)
  1057e0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1057e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1057e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057ec:	c7 04 24 3d 75 10 00 	movl   $0x10753d,(%esp)
  1057f3:	e8 a3 ab ff ff       	call   10039b <cprintf>
        size_t l, r = left * NPTEENTRY;
  1057f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057fb:	c1 e0 0a             	shl    $0xa,%eax
  1057fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105801:	eb 50                	jmp    105853 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105806:	89 04 24             	mov    %eax,(%esp)
  105809:	e8 83 fe ff ff       	call   105691 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10580e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105811:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  105814:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105816:	89 d6                	mov    %edx,%esi
  105818:	c1 e6 0c             	shl    $0xc,%esi
  10581b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10581e:	89 d3                	mov    %edx,%ebx
  105820:	c1 e3 0c             	shl    $0xc,%ebx
  105823:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105826:	89 d1                	mov    %edx,%ecx
  105828:	c1 e1 0c             	shl    $0xc,%ecx
  10582b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10582e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  105831:	29 fa                	sub    %edi,%edx
  105833:	89 44 24 14          	mov    %eax,0x14(%esp)
  105837:	89 74 24 10          	mov    %esi,0x10(%esp)
  10583b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10583f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105843:	89 54 24 04          	mov    %edx,0x4(%esp)
  105847:	c7 04 24 5c 75 10 00 	movl   $0x10755c,(%esp)
  10584e:	e8 48 ab ff ff       	call   10039b <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105853:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  105858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10585b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10585e:	89 d3                	mov    %edx,%ebx
  105860:	c1 e3 0a             	shl    $0xa,%ebx
  105863:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105866:	89 d1                	mov    %edx,%ecx
  105868:	c1 e1 0a             	shl    $0xa,%ecx
  10586b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  10586e:	89 54 24 14          	mov    %edx,0x14(%esp)
  105872:	8d 55 d8             	lea    -0x28(%ebp),%edx
  105875:	89 54 24 10          	mov    %edx,0x10(%esp)
  105879:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10587d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105881:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  105885:	89 0c 24             	mov    %ecx,(%esp)
  105888:	e8 46 fe ff ff       	call   1056d3 <get_pgtable_items>
  10588d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105890:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105894:	0f 85 69 ff ff ff    	jne    105803 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10589a:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10589f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058a2:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1058a5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1058a9:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1058ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  1058b0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1058b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058b8:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1058bf:	00 
  1058c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1058c7:	e8 07 fe ff ff       	call   1056d3 <get_pgtable_items>
  1058cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1058cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058d3:	0f 85 cf fe ff ff    	jne    1057a8 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1058d9:	c7 04 24 80 75 10 00 	movl   $0x107580,(%esp)
  1058e0:	e8 b6 aa ff ff       	call   10039b <cprintf>
}
  1058e5:	90                   	nop
  1058e6:	83 c4 4c             	add    $0x4c,%esp
  1058e9:	5b                   	pop    %ebx
  1058ea:	5e                   	pop    %esi
  1058eb:	5f                   	pop    %edi
  1058ec:	5d                   	pop    %ebp
  1058ed:	c3                   	ret    

001058ee <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1058ee:	55                   	push   %ebp
  1058ef:	89 e5                	mov    %esp,%ebp
  1058f1:	83 ec 58             	sub    $0x58,%esp
  1058f4:	8b 45 10             	mov    0x10(%ebp),%eax
  1058f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1058fa:	8b 45 14             	mov    0x14(%ebp),%eax
  1058fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105900:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105903:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105906:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105909:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10590c:	8b 45 18             	mov    0x18(%ebp),%eax
  10590f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105912:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105915:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105918:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10591b:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105928:	74 1c                	je     105946 <printnum+0x58>
  10592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10592d:	ba 00 00 00 00       	mov    $0x0,%edx
  105932:	f7 75 e4             	divl   -0x1c(%ebp)
  105935:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10593b:	ba 00 00 00 00       	mov    $0x0,%edx
  105940:	f7 75 e4             	divl   -0x1c(%ebp)
  105943:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105946:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105949:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10594c:	f7 75 e4             	divl   -0x1c(%ebp)
  10594f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105952:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105955:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105958:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10595b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10595e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105961:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105964:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105967:	8b 45 18             	mov    0x18(%ebp),%eax
  10596a:	ba 00 00 00 00       	mov    $0x0,%edx
  10596f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105972:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105975:	19 d1                	sbb    %edx,%ecx
  105977:	72 4c                	jb     1059c5 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  105979:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10597c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10597f:	8b 45 20             	mov    0x20(%ebp),%eax
  105982:	89 44 24 18          	mov    %eax,0x18(%esp)
  105986:	89 54 24 14          	mov    %edx,0x14(%esp)
  10598a:	8b 45 18             	mov    0x18(%ebp),%eax
  10598d:	89 44 24 10          	mov    %eax,0x10(%esp)
  105991:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105994:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105997:	89 44 24 08          	mov    %eax,0x8(%esp)
  10599b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10599f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a9:	89 04 24             	mov    %eax,(%esp)
  1059ac:	e8 3d ff ff ff       	call   1058ee <printnum>
  1059b1:	eb 1b                	jmp    1059ce <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1059b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059ba:	8b 45 20             	mov    0x20(%ebp),%eax
  1059bd:	89 04 24             	mov    %eax,(%esp)
  1059c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1059c3:	ff d0                	call   *%eax
        while (-- width > 0)
  1059c5:	ff 4d 1c             	decl   0x1c(%ebp)
  1059c8:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1059cc:	7f e5                	jg     1059b3 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1059ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1059d1:	05 34 76 10 00       	add    $0x107634,%eax
  1059d6:	0f b6 00             	movzbl (%eax),%eax
  1059d9:	0f be c0             	movsbl %al,%eax
  1059dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1059df:	89 54 24 04          	mov    %edx,0x4(%esp)
  1059e3:	89 04 24             	mov    %eax,(%esp)
  1059e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1059e9:	ff d0                	call   *%eax
}
  1059eb:	90                   	nop
  1059ec:	89 ec                	mov    %ebp,%esp
  1059ee:	5d                   	pop    %ebp
  1059ef:	c3                   	ret    

001059f0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1059f0:	55                   	push   %ebp
  1059f1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1059f3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1059f7:	7e 14                	jle    105a0d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1059f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1059fc:	8b 00                	mov    (%eax),%eax
  1059fe:	8d 48 08             	lea    0x8(%eax),%ecx
  105a01:	8b 55 08             	mov    0x8(%ebp),%edx
  105a04:	89 0a                	mov    %ecx,(%edx)
  105a06:	8b 50 04             	mov    0x4(%eax),%edx
  105a09:	8b 00                	mov    (%eax),%eax
  105a0b:	eb 30                	jmp    105a3d <getuint+0x4d>
    }
    else if (lflag) {
  105a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105a11:	74 16                	je     105a29 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105a13:	8b 45 08             	mov    0x8(%ebp),%eax
  105a16:	8b 00                	mov    (%eax),%eax
  105a18:	8d 48 04             	lea    0x4(%eax),%ecx
  105a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  105a1e:	89 0a                	mov    %ecx,(%edx)
  105a20:	8b 00                	mov    (%eax),%eax
  105a22:	ba 00 00 00 00       	mov    $0x0,%edx
  105a27:	eb 14                	jmp    105a3d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105a29:	8b 45 08             	mov    0x8(%ebp),%eax
  105a2c:	8b 00                	mov    (%eax),%eax
  105a2e:	8d 48 04             	lea    0x4(%eax),%ecx
  105a31:	8b 55 08             	mov    0x8(%ebp),%edx
  105a34:	89 0a                	mov    %ecx,(%edx)
  105a36:	8b 00                	mov    (%eax),%eax
  105a38:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105a3d:	5d                   	pop    %ebp
  105a3e:	c3                   	ret    

00105a3f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105a3f:	55                   	push   %ebp
  105a40:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105a42:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a46:	7e 14                	jle    105a5c <getint+0x1d>
        return va_arg(*ap, long long);
  105a48:	8b 45 08             	mov    0x8(%ebp),%eax
  105a4b:	8b 00                	mov    (%eax),%eax
  105a4d:	8d 48 08             	lea    0x8(%eax),%ecx
  105a50:	8b 55 08             	mov    0x8(%ebp),%edx
  105a53:	89 0a                	mov    %ecx,(%edx)
  105a55:	8b 50 04             	mov    0x4(%eax),%edx
  105a58:	8b 00                	mov    (%eax),%eax
  105a5a:	eb 28                	jmp    105a84 <getint+0x45>
    }
    else if (lflag) {
  105a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105a60:	74 12                	je     105a74 <getint+0x35>
        return va_arg(*ap, long);
  105a62:	8b 45 08             	mov    0x8(%ebp),%eax
  105a65:	8b 00                	mov    (%eax),%eax
  105a67:	8d 48 04             	lea    0x4(%eax),%ecx
  105a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  105a6d:	89 0a                	mov    %ecx,(%edx)
  105a6f:	8b 00                	mov    (%eax),%eax
  105a71:	99                   	cltd   
  105a72:	eb 10                	jmp    105a84 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105a74:	8b 45 08             	mov    0x8(%ebp),%eax
  105a77:	8b 00                	mov    (%eax),%eax
  105a79:	8d 48 04             	lea    0x4(%eax),%ecx
  105a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  105a7f:	89 0a                	mov    %ecx,(%edx)
  105a81:	8b 00                	mov    (%eax),%eax
  105a83:	99                   	cltd   
    }
}
  105a84:	5d                   	pop    %ebp
  105a85:	c3                   	ret    

00105a86 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105a86:	55                   	push   %ebp
  105a87:	89 e5                	mov    %esp,%ebp
  105a89:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105a8c:	8d 45 14             	lea    0x14(%ebp),%eax
  105a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a99:	8b 45 10             	mov    0x10(%ebp),%eax
  105a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  105aaa:	89 04 24             	mov    %eax,(%esp)
  105aad:	e8 05 00 00 00       	call   105ab7 <vprintfmt>
    va_end(ap);
}
  105ab2:	90                   	nop
  105ab3:	89 ec                	mov    %ebp,%esp
  105ab5:	5d                   	pop    %ebp
  105ab6:	c3                   	ret    

00105ab7 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105ab7:	55                   	push   %ebp
  105ab8:	89 e5                	mov    %esp,%ebp
  105aba:	56                   	push   %esi
  105abb:	53                   	push   %ebx
  105abc:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105abf:	eb 17                	jmp    105ad8 <vprintfmt+0x21>
            if (ch == '\0') {
  105ac1:	85 db                	test   %ebx,%ebx
  105ac3:	0f 84 bf 03 00 00    	je     105e88 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ad0:	89 1c 24             	mov    %ebx,(%esp)
  105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ad6:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  105adb:	8d 50 01             	lea    0x1(%eax),%edx
  105ade:	89 55 10             	mov    %edx,0x10(%ebp)
  105ae1:	0f b6 00             	movzbl (%eax),%eax
  105ae4:	0f b6 d8             	movzbl %al,%ebx
  105ae7:	83 fb 25             	cmp    $0x25,%ebx
  105aea:	75 d5                	jne    105ac1 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105aec:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105af0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105af7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105afa:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105afd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105b04:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105b07:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105b0a:	8b 45 10             	mov    0x10(%ebp),%eax
  105b0d:	8d 50 01             	lea    0x1(%eax),%edx
  105b10:	89 55 10             	mov    %edx,0x10(%ebp)
  105b13:	0f b6 00             	movzbl (%eax),%eax
  105b16:	0f b6 d8             	movzbl %al,%ebx
  105b19:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105b1c:	83 f8 55             	cmp    $0x55,%eax
  105b1f:	0f 87 37 03 00 00    	ja     105e5c <vprintfmt+0x3a5>
  105b25:	8b 04 85 58 76 10 00 	mov    0x107658(,%eax,4),%eax
  105b2c:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105b2e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105b32:	eb d6                	jmp    105b0a <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105b34:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105b38:	eb d0                	jmp    105b0a <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105b3a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105b41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105b44:	89 d0                	mov    %edx,%eax
  105b46:	c1 e0 02             	shl    $0x2,%eax
  105b49:	01 d0                	add    %edx,%eax
  105b4b:	01 c0                	add    %eax,%eax
  105b4d:	01 d8                	add    %ebx,%eax
  105b4f:	83 e8 30             	sub    $0x30,%eax
  105b52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105b55:	8b 45 10             	mov    0x10(%ebp),%eax
  105b58:	0f b6 00             	movzbl (%eax),%eax
  105b5b:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105b5e:	83 fb 2f             	cmp    $0x2f,%ebx
  105b61:	7e 38                	jle    105b9b <vprintfmt+0xe4>
  105b63:	83 fb 39             	cmp    $0x39,%ebx
  105b66:	7f 33                	jg     105b9b <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105b68:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105b6b:	eb d4                	jmp    105b41 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105b6d:	8b 45 14             	mov    0x14(%ebp),%eax
  105b70:	8d 50 04             	lea    0x4(%eax),%edx
  105b73:	89 55 14             	mov    %edx,0x14(%ebp)
  105b76:	8b 00                	mov    (%eax),%eax
  105b78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105b7b:	eb 1f                	jmp    105b9c <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105b7d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b81:	79 87                	jns    105b0a <vprintfmt+0x53>
                width = 0;
  105b83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105b8a:	e9 7b ff ff ff       	jmp    105b0a <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105b8f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105b96:	e9 6f ff ff ff       	jmp    105b0a <vprintfmt+0x53>
            goto process_precision;
  105b9b:	90                   	nop

        process_precision:
            if (width < 0)
  105b9c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ba0:	0f 89 64 ff ff ff    	jns    105b0a <vprintfmt+0x53>
                width = precision, precision = -1;
  105ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ba9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105bac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105bb3:	e9 52 ff ff ff       	jmp    105b0a <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105bb8:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105bbb:	e9 4a ff ff ff       	jmp    105b0a <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105bc0:	8b 45 14             	mov    0x14(%ebp),%eax
  105bc3:	8d 50 04             	lea    0x4(%eax),%edx
  105bc6:	89 55 14             	mov    %edx,0x14(%ebp)
  105bc9:	8b 00                	mov    (%eax),%eax
  105bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  105bce:	89 54 24 04          	mov    %edx,0x4(%esp)
  105bd2:	89 04 24             	mov    %eax,(%esp)
  105bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd8:	ff d0                	call   *%eax
            break;
  105bda:	e9 a4 02 00 00       	jmp    105e83 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105bdf:	8b 45 14             	mov    0x14(%ebp),%eax
  105be2:	8d 50 04             	lea    0x4(%eax),%edx
  105be5:	89 55 14             	mov    %edx,0x14(%ebp)
  105be8:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105bea:	85 db                	test   %ebx,%ebx
  105bec:	79 02                	jns    105bf0 <vprintfmt+0x139>
                err = -err;
  105bee:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105bf0:	83 fb 06             	cmp    $0x6,%ebx
  105bf3:	7f 0b                	jg     105c00 <vprintfmt+0x149>
  105bf5:	8b 34 9d 18 76 10 00 	mov    0x107618(,%ebx,4),%esi
  105bfc:	85 f6                	test   %esi,%esi
  105bfe:	75 23                	jne    105c23 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105c00:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105c04:	c7 44 24 08 45 76 10 	movl   $0x107645,0x8(%esp)
  105c0b:	00 
  105c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c13:	8b 45 08             	mov    0x8(%ebp),%eax
  105c16:	89 04 24             	mov    %eax,(%esp)
  105c19:	e8 68 fe ff ff       	call   105a86 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105c1e:	e9 60 02 00 00       	jmp    105e83 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105c23:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105c27:	c7 44 24 08 4e 76 10 	movl   $0x10764e,0x8(%esp)
  105c2e:	00 
  105c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c36:	8b 45 08             	mov    0x8(%ebp),%eax
  105c39:	89 04 24             	mov    %eax,(%esp)
  105c3c:	e8 45 fe ff ff       	call   105a86 <printfmt>
            break;
  105c41:	e9 3d 02 00 00       	jmp    105e83 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105c46:	8b 45 14             	mov    0x14(%ebp),%eax
  105c49:	8d 50 04             	lea    0x4(%eax),%edx
  105c4c:	89 55 14             	mov    %edx,0x14(%ebp)
  105c4f:	8b 30                	mov    (%eax),%esi
  105c51:	85 f6                	test   %esi,%esi
  105c53:	75 05                	jne    105c5a <vprintfmt+0x1a3>
                p = "(null)";
  105c55:	be 51 76 10 00       	mov    $0x107651,%esi
            }
            if (width > 0 && padc != '-') {
  105c5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c5e:	7e 76                	jle    105cd6 <vprintfmt+0x21f>
  105c60:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105c64:	74 70                	je     105cd6 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c6d:	89 34 24             	mov    %esi,(%esp)
  105c70:	e8 16 03 00 00       	call   105f8b <strnlen>
  105c75:	89 c2                	mov    %eax,%edx
  105c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c7a:	29 d0                	sub    %edx,%eax
  105c7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105c7f:	eb 16                	jmp    105c97 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105c81:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105c85:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c88:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c8c:	89 04 24             	mov    %eax,(%esp)
  105c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c92:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c94:	ff 4d e8             	decl   -0x18(%ebp)
  105c97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c9b:	7f e4                	jg     105c81 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c9d:	eb 37                	jmp    105cd6 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105c9f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105ca3:	74 1f                	je     105cc4 <vprintfmt+0x20d>
  105ca5:	83 fb 1f             	cmp    $0x1f,%ebx
  105ca8:	7e 05                	jle    105caf <vprintfmt+0x1f8>
  105caa:	83 fb 7e             	cmp    $0x7e,%ebx
  105cad:	7e 15                	jle    105cc4 <vprintfmt+0x20d>
                    putch('?', putdat);
  105caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cb6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc0:	ff d0                	call   *%eax
  105cc2:	eb 0f                	jmp    105cd3 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ccb:	89 1c 24             	mov    %ebx,(%esp)
  105cce:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd1:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105cd3:	ff 4d e8             	decl   -0x18(%ebp)
  105cd6:	89 f0                	mov    %esi,%eax
  105cd8:	8d 70 01             	lea    0x1(%eax),%esi
  105cdb:	0f b6 00             	movzbl (%eax),%eax
  105cde:	0f be d8             	movsbl %al,%ebx
  105ce1:	85 db                	test   %ebx,%ebx
  105ce3:	74 27                	je     105d0c <vprintfmt+0x255>
  105ce5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105ce9:	78 b4                	js     105c9f <vprintfmt+0x1e8>
  105ceb:	ff 4d e4             	decl   -0x1c(%ebp)
  105cee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105cf2:	79 ab                	jns    105c9f <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105cf4:	eb 16                	jmp    105d0c <vprintfmt+0x255>
                putch(' ', putdat);
  105cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cfd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105d04:	8b 45 08             	mov    0x8(%ebp),%eax
  105d07:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105d09:	ff 4d e8             	decl   -0x18(%ebp)
  105d0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d10:	7f e4                	jg     105cf6 <vprintfmt+0x23f>
            }
            break;
  105d12:	e9 6c 01 00 00       	jmp    105e83 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105d17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d1e:	8d 45 14             	lea    0x14(%ebp),%eax
  105d21:	89 04 24             	mov    %eax,(%esp)
  105d24:	e8 16 fd ff ff       	call   105a3f <getint>
  105d29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d35:	85 d2                	test   %edx,%edx
  105d37:	79 26                	jns    105d5f <vprintfmt+0x2a8>
                putch('-', putdat);
  105d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d40:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105d47:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4a:	ff d0                	call   *%eax
                num = -(long long)num;
  105d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d52:	f7 d8                	neg    %eax
  105d54:	83 d2 00             	adc    $0x0,%edx
  105d57:	f7 da                	neg    %edx
  105d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105d5f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d66:	e9 a8 00 00 00       	jmp    105e13 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d72:	8d 45 14             	lea    0x14(%ebp),%eax
  105d75:	89 04 24             	mov    %eax,(%esp)
  105d78:	e8 73 fc ff ff       	call   1059f0 <getuint>
  105d7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d80:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105d83:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d8a:	e9 84 00 00 00       	jmp    105e13 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105d8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d92:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d96:	8d 45 14             	lea    0x14(%ebp),%eax
  105d99:	89 04 24             	mov    %eax,(%esp)
  105d9c:	e8 4f fc ff ff       	call   1059f0 <getuint>
  105da1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105da4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105da7:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105dae:	eb 63                	jmp    105e13 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105db7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc1:	ff d0                	call   *%eax
            putch('x', putdat);
  105dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  105dd4:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105dd6:	8b 45 14             	mov    0x14(%ebp),%eax
  105dd9:	8d 50 04             	lea    0x4(%eax),%edx
  105ddc:	89 55 14             	mov    %edx,0x14(%ebp)
  105ddf:	8b 00                	mov    (%eax),%eax
  105de1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105deb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105df2:	eb 1f                	jmp    105e13 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dfb:	8d 45 14             	lea    0x14(%ebp),%eax
  105dfe:	89 04 24             	mov    %eax,(%esp)
  105e01:	e8 ea fb ff ff       	call   1059f0 <getuint>
  105e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e09:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105e0c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105e13:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e1a:	89 54 24 18          	mov    %edx,0x18(%esp)
  105e1e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105e21:	89 54 24 14          	mov    %edx,0x14(%esp)
  105e25:	89 44 24 10          	mov    %eax,0x10(%esp)
  105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e33:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  105e41:	89 04 24             	mov    %eax,(%esp)
  105e44:	e8 a5 fa ff ff       	call   1058ee <printnum>
            break;
  105e49:	eb 38                	jmp    105e83 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e52:	89 1c 24             	mov    %ebx,(%esp)
  105e55:	8b 45 08             	mov    0x8(%ebp),%eax
  105e58:	ff d0                	call   *%eax
            break;
  105e5a:	eb 27                	jmp    105e83 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e63:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  105e6d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105e6f:	ff 4d 10             	decl   0x10(%ebp)
  105e72:	eb 03                	jmp    105e77 <vprintfmt+0x3c0>
  105e74:	ff 4d 10             	decl   0x10(%ebp)
  105e77:	8b 45 10             	mov    0x10(%ebp),%eax
  105e7a:	48                   	dec    %eax
  105e7b:	0f b6 00             	movzbl (%eax),%eax
  105e7e:	3c 25                	cmp    $0x25,%al
  105e80:	75 f2                	jne    105e74 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105e82:	90                   	nop
    while (1) {
  105e83:	e9 37 fc ff ff       	jmp    105abf <vprintfmt+0x8>
                return;
  105e88:	90                   	nop
        }
    }
}
  105e89:	83 c4 40             	add    $0x40,%esp
  105e8c:	5b                   	pop    %ebx
  105e8d:	5e                   	pop    %esi
  105e8e:	5d                   	pop    %ebp
  105e8f:	c3                   	ret    

00105e90 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105e90:	55                   	push   %ebp
  105e91:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e96:	8b 40 08             	mov    0x8(%eax),%eax
  105e99:	8d 50 01             	lea    0x1(%eax),%edx
  105e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e9f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ea5:	8b 10                	mov    (%eax),%edx
  105ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eaa:	8b 40 04             	mov    0x4(%eax),%eax
  105ead:	39 c2                	cmp    %eax,%edx
  105eaf:	73 12                	jae    105ec3 <sprintputch+0x33>
        *b->buf ++ = ch;
  105eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eb4:	8b 00                	mov    (%eax),%eax
  105eb6:	8d 48 01             	lea    0x1(%eax),%ecx
  105eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ebc:	89 0a                	mov    %ecx,(%edx)
  105ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  105ec1:	88 10                	mov    %dl,(%eax)
    }
}
  105ec3:	90                   	nop
  105ec4:	5d                   	pop    %ebp
  105ec5:	c3                   	ret    

00105ec6 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105ec6:	55                   	push   %ebp
  105ec7:	89 e5                	mov    %esp,%ebp
  105ec9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105ecc:	8d 45 14             	lea    0x14(%ebp),%eax
  105ecf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ed5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ed9:	8b 45 10             	mov    0x10(%ebp),%eax
  105edc:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  105eea:	89 04 24             	mov    %eax,(%esp)
  105eed:	e8 0a 00 00 00       	call   105efc <vsnprintf>
  105ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ef8:	89 ec                	mov    %ebp,%esp
  105efa:	5d                   	pop    %ebp
  105efb:	c3                   	ret    

00105efc <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105efc:	55                   	push   %ebp
  105efd:	89 e5                	mov    %esp,%ebp
  105eff:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105f02:	8b 45 08             	mov    0x8(%ebp),%eax
  105f05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f0b:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  105f11:	01 d0                	add    %edx,%eax
  105f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105f1d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105f21:	74 0a                	je     105f2d <vsnprintf+0x31>
  105f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f29:	39 c2                	cmp    %eax,%edx
  105f2b:	76 07                	jbe    105f34 <vsnprintf+0x38>
        return -E_INVAL;
  105f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105f32:	eb 2a                	jmp    105f5e <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105f34:	8b 45 14             	mov    0x14(%ebp),%eax
  105f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  105f3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f42:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105f45:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f49:	c7 04 24 90 5e 10 00 	movl   $0x105e90,(%esp)
  105f50:	e8 62 fb ff ff       	call   105ab7 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105f55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f58:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105f5e:	89 ec                	mov    %ebp,%esp
  105f60:	5d                   	pop    %ebp
  105f61:	c3                   	ret    

00105f62 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105f62:	55                   	push   %ebp
  105f63:	89 e5                	mov    %esp,%ebp
  105f65:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105f68:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105f6f:	eb 03                	jmp    105f74 <strlen+0x12>
        cnt ++;
  105f71:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105f74:	8b 45 08             	mov    0x8(%ebp),%eax
  105f77:	8d 50 01             	lea    0x1(%eax),%edx
  105f7a:	89 55 08             	mov    %edx,0x8(%ebp)
  105f7d:	0f b6 00             	movzbl (%eax),%eax
  105f80:	84 c0                	test   %al,%al
  105f82:	75 ed                	jne    105f71 <strlen+0xf>
    }
    return cnt;
  105f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105f87:	89 ec                	mov    %ebp,%esp
  105f89:	5d                   	pop    %ebp
  105f8a:	c3                   	ret    

00105f8b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105f8b:	55                   	push   %ebp
  105f8c:	89 e5                	mov    %esp,%ebp
  105f8e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105f91:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105f98:	eb 03                	jmp    105f9d <strnlen+0x12>
        cnt ++;
  105f9a:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fa0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105fa3:	73 10                	jae    105fb5 <strnlen+0x2a>
  105fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  105fa8:	8d 50 01             	lea    0x1(%eax),%edx
  105fab:	89 55 08             	mov    %edx,0x8(%ebp)
  105fae:	0f b6 00             	movzbl (%eax),%eax
  105fb1:	84 c0                	test   %al,%al
  105fb3:	75 e5                	jne    105f9a <strnlen+0xf>
    }
    return cnt;
  105fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105fb8:	89 ec                	mov    %ebp,%esp
  105fba:	5d                   	pop    %ebp
  105fbb:	c3                   	ret    

00105fbc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105fbc:	55                   	push   %ebp
  105fbd:	89 e5                	mov    %esp,%ebp
  105fbf:	57                   	push   %edi
  105fc0:	56                   	push   %esi
  105fc1:	83 ec 20             	sub    $0x20,%esp
  105fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105fd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105fd6:	89 d1                	mov    %edx,%ecx
  105fd8:	89 c2                	mov    %eax,%edx
  105fda:	89 ce                	mov    %ecx,%esi
  105fdc:	89 d7                	mov    %edx,%edi
  105fde:	ac                   	lods   %ds:(%esi),%al
  105fdf:	aa                   	stos   %al,%es:(%edi)
  105fe0:	84 c0                	test   %al,%al
  105fe2:	75 fa                	jne    105fde <strcpy+0x22>
  105fe4:	89 fa                	mov    %edi,%edx
  105fe6:	89 f1                	mov    %esi,%ecx
  105fe8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105feb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105ff4:	83 c4 20             	add    $0x20,%esp
  105ff7:	5e                   	pop    %esi
  105ff8:	5f                   	pop    %edi
  105ff9:	5d                   	pop    %ebp
  105ffa:	c3                   	ret    

00105ffb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105ffb:	55                   	push   %ebp
  105ffc:	89 e5                	mov    %esp,%ebp
  105ffe:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  106001:	8b 45 08             	mov    0x8(%ebp),%eax
  106004:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  106007:	eb 1e                	jmp    106027 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  106009:	8b 45 0c             	mov    0xc(%ebp),%eax
  10600c:	0f b6 10             	movzbl (%eax),%edx
  10600f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106012:	88 10                	mov    %dl,(%eax)
  106014:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106017:	0f b6 00             	movzbl (%eax),%eax
  10601a:	84 c0                	test   %al,%al
  10601c:	74 03                	je     106021 <strncpy+0x26>
            src ++;
  10601e:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  106021:	ff 45 fc             	incl   -0x4(%ebp)
  106024:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  106027:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10602b:	75 dc                	jne    106009 <strncpy+0xe>
    }
    return dst;
  10602d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106030:	89 ec                	mov    %ebp,%esp
  106032:	5d                   	pop    %ebp
  106033:	c3                   	ret    

00106034 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  106034:	55                   	push   %ebp
  106035:	89 e5                	mov    %esp,%ebp
  106037:	57                   	push   %edi
  106038:	56                   	push   %esi
  106039:	83 ec 20             	sub    $0x20,%esp
  10603c:	8b 45 08             	mov    0x8(%ebp),%eax
  10603f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106042:	8b 45 0c             	mov    0xc(%ebp),%eax
  106045:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  106048:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10604b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10604e:	89 d1                	mov    %edx,%ecx
  106050:	89 c2                	mov    %eax,%edx
  106052:	89 ce                	mov    %ecx,%esi
  106054:	89 d7                	mov    %edx,%edi
  106056:	ac                   	lods   %ds:(%esi),%al
  106057:	ae                   	scas   %es:(%edi),%al
  106058:	75 08                	jne    106062 <strcmp+0x2e>
  10605a:	84 c0                	test   %al,%al
  10605c:	75 f8                	jne    106056 <strcmp+0x22>
  10605e:	31 c0                	xor    %eax,%eax
  106060:	eb 04                	jmp    106066 <strcmp+0x32>
  106062:	19 c0                	sbb    %eax,%eax
  106064:	0c 01                	or     $0x1,%al
  106066:	89 fa                	mov    %edi,%edx
  106068:	89 f1                	mov    %esi,%ecx
  10606a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10606d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106070:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  106073:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  106076:	83 c4 20             	add    $0x20,%esp
  106079:	5e                   	pop    %esi
  10607a:	5f                   	pop    %edi
  10607b:	5d                   	pop    %ebp
  10607c:	c3                   	ret    

0010607d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10607d:	55                   	push   %ebp
  10607e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106080:	eb 09                	jmp    10608b <strncmp+0xe>
        n --, s1 ++, s2 ++;
  106082:	ff 4d 10             	decl   0x10(%ebp)
  106085:	ff 45 08             	incl   0x8(%ebp)
  106088:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10608b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10608f:	74 1a                	je     1060ab <strncmp+0x2e>
  106091:	8b 45 08             	mov    0x8(%ebp),%eax
  106094:	0f b6 00             	movzbl (%eax),%eax
  106097:	84 c0                	test   %al,%al
  106099:	74 10                	je     1060ab <strncmp+0x2e>
  10609b:	8b 45 08             	mov    0x8(%ebp),%eax
  10609e:	0f b6 10             	movzbl (%eax),%edx
  1060a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060a4:	0f b6 00             	movzbl (%eax),%eax
  1060a7:	38 c2                	cmp    %al,%dl
  1060a9:	74 d7                	je     106082 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1060ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1060af:	74 18                	je     1060c9 <strncmp+0x4c>
  1060b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1060b4:	0f b6 00             	movzbl (%eax),%eax
  1060b7:	0f b6 d0             	movzbl %al,%edx
  1060ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060bd:	0f b6 00             	movzbl (%eax),%eax
  1060c0:	0f b6 c8             	movzbl %al,%ecx
  1060c3:	89 d0                	mov    %edx,%eax
  1060c5:	29 c8                	sub    %ecx,%eax
  1060c7:	eb 05                	jmp    1060ce <strncmp+0x51>
  1060c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1060ce:	5d                   	pop    %ebp
  1060cf:	c3                   	ret    

001060d0 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1060d0:	55                   	push   %ebp
  1060d1:	89 e5                	mov    %esp,%ebp
  1060d3:	83 ec 04             	sub    $0x4,%esp
  1060d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060d9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1060dc:	eb 13                	jmp    1060f1 <strchr+0x21>
        if (*s == c) {
  1060de:	8b 45 08             	mov    0x8(%ebp),%eax
  1060e1:	0f b6 00             	movzbl (%eax),%eax
  1060e4:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1060e7:	75 05                	jne    1060ee <strchr+0x1e>
            return (char *)s;
  1060e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1060ec:	eb 12                	jmp    106100 <strchr+0x30>
        }
        s ++;
  1060ee:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1060f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1060f4:	0f b6 00             	movzbl (%eax),%eax
  1060f7:	84 c0                	test   %al,%al
  1060f9:	75 e3                	jne    1060de <strchr+0xe>
    }
    return NULL;
  1060fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106100:	89 ec                	mov    %ebp,%esp
  106102:	5d                   	pop    %ebp
  106103:	c3                   	ret    

00106104 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  106104:	55                   	push   %ebp
  106105:	89 e5                	mov    %esp,%ebp
  106107:	83 ec 04             	sub    $0x4,%esp
  10610a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10610d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106110:	eb 0e                	jmp    106120 <strfind+0x1c>
        if (*s == c) {
  106112:	8b 45 08             	mov    0x8(%ebp),%eax
  106115:	0f b6 00             	movzbl (%eax),%eax
  106118:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10611b:	74 0f                	je     10612c <strfind+0x28>
            break;
        }
        s ++;
  10611d:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106120:	8b 45 08             	mov    0x8(%ebp),%eax
  106123:	0f b6 00             	movzbl (%eax),%eax
  106126:	84 c0                	test   %al,%al
  106128:	75 e8                	jne    106112 <strfind+0xe>
  10612a:	eb 01                	jmp    10612d <strfind+0x29>
            break;
  10612c:	90                   	nop
    }
    return (char *)s;
  10612d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106130:	89 ec                	mov    %ebp,%esp
  106132:	5d                   	pop    %ebp
  106133:	c3                   	ret    

00106134 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106134:	55                   	push   %ebp
  106135:	89 e5                	mov    %esp,%ebp
  106137:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10613a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106141:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  106148:	eb 03                	jmp    10614d <strtol+0x19>
        s ++;
  10614a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10614d:	8b 45 08             	mov    0x8(%ebp),%eax
  106150:	0f b6 00             	movzbl (%eax),%eax
  106153:	3c 20                	cmp    $0x20,%al
  106155:	74 f3                	je     10614a <strtol+0x16>
  106157:	8b 45 08             	mov    0x8(%ebp),%eax
  10615a:	0f b6 00             	movzbl (%eax),%eax
  10615d:	3c 09                	cmp    $0x9,%al
  10615f:	74 e9                	je     10614a <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  106161:	8b 45 08             	mov    0x8(%ebp),%eax
  106164:	0f b6 00             	movzbl (%eax),%eax
  106167:	3c 2b                	cmp    $0x2b,%al
  106169:	75 05                	jne    106170 <strtol+0x3c>
        s ++;
  10616b:	ff 45 08             	incl   0x8(%ebp)
  10616e:	eb 14                	jmp    106184 <strtol+0x50>
    }
    else if (*s == '-') {
  106170:	8b 45 08             	mov    0x8(%ebp),%eax
  106173:	0f b6 00             	movzbl (%eax),%eax
  106176:	3c 2d                	cmp    $0x2d,%al
  106178:	75 0a                	jne    106184 <strtol+0x50>
        s ++, neg = 1;
  10617a:	ff 45 08             	incl   0x8(%ebp)
  10617d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106184:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106188:	74 06                	je     106190 <strtol+0x5c>
  10618a:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10618e:	75 22                	jne    1061b2 <strtol+0x7e>
  106190:	8b 45 08             	mov    0x8(%ebp),%eax
  106193:	0f b6 00             	movzbl (%eax),%eax
  106196:	3c 30                	cmp    $0x30,%al
  106198:	75 18                	jne    1061b2 <strtol+0x7e>
  10619a:	8b 45 08             	mov    0x8(%ebp),%eax
  10619d:	40                   	inc    %eax
  10619e:	0f b6 00             	movzbl (%eax),%eax
  1061a1:	3c 78                	cmp    $0x78,%al
  1061a3:	75 0d                	jne    1061b2 <strtol+0x7e>
        s += 2, base = 16;
  1061a5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1061a9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1061b0:	eb 29                	jmp    1061db <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1061b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1061b6:	75 16                	jne    1061ce <strtol+0x9a>
  1061b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1061bb:	0f b6 00             	movzbl (%eax),%eax
  1061be:	3c 30                	cmp    $0x30,%al
  1061c0:	75 0c                	jne    1061ce <strtol+0x9a>
        s ++, base = 8;
  1061c2:	ff 45 08             	incl   0x8(%ebp)
  1061c5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1061cc:	eb 0d                	jmp    1061db <strtol+0xa7>
    }
    else if (base == 0) {
  1061ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1061d2:	75 07                	jne    1061db <strtol+0xa7>
        base = 10;
  1061d4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1061db:	8b 45 08             	mov    0x8(%ebp),%eax
  1061de:	0f b6 00             	movzbl (%eax),%eax
  1061e1:	3c 2f                	cmp    $0x2f,%al
  1061e3:	7e 1b                	jle    106200 <strtol+0xcc>
  1061e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1061e8:	0f b6 00             	movzbl (%eax),%eax
  1061eb:	3c 39                	cmp    $0x39,%al
  1061ed:	7f 11                	jg     106200 <strtol+0xcc>
            dig = *s - '0';
  1061ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1061f2:	0f b6 00             	movzbl (%eax),%eax
  1061f5:	0f be c0             	movsbl %al,%eax
  1061f8:	83 e8 30             	sub    $0x30,%eax
  1061fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1061fe:	eb 48                	jmp    106248 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  106200:	8b 45 08             	mov    0x8(%ebp),%eax
  106203:	0f b6 00             	movzbl (%eax),%eax
  106206:	3c 60                	cmp    $0x60,%al
  106208:	7e 1b                	jle    106225 <strtol+0xf1>
  10620a:	8b 45 08             	mov    0x8(%ebp),%eax
  10620d:	0f b6 00             	movzbl (%eax),%eax
  106210:	3c 7a                	cmp    $0x7a,%al
  106212:	7f 11                	jg     106225 <strtol+0xf1>
            dig = *s - 'a' + 10;
  106214:	8b 45 08             	mov    0x8(%ebp),%eax
  106217:	0f b6 00             	movzbl (%eax),%eax
  10621a:	0f be c0             	movsbl %al,%eax
  10621d:	83 e8 57             	sub    $0x57,%eax
  106220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106223:	eb 23                	jmp    106248 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  106225:	8b 45 08             	mov    0x8(%ebp),%eax
  106228:	0f b6 00             	movzbl (%eax),%eax
  10622b:	3c 40                	cmp    $0x40,%al
  10622d:	7e 3b                	jle    10626a <strtol+0x136>
  10622f:	8b 45 08             	mov    0x8(%ebp),%eax
  106232:	0f b6 00             	movzbl (%eax),%eax
  106235:	3c 5a                	cmp    $0x5a,%al
  106237:	7f 31                	jg     10626a <strtol+0x136>
            dig = *s - 'A' + 10;
  106239:	8b 45 08             	mov    0x8(%ebp),%eax
  10623c:	0f b6 00             	movzbl (%eax),%eax
  10623f:	0f be c0             	movsbl %al,%eax
  106242:	83 e8 37             	sub    $0x37,%eax
  106245:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106248:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10624b:	3b 45 10             	cmp    0x10(%ebp),%eax
  10624e:	7d 19                	jge    106269 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106250:	ff 45 08             	incl   0x8(%ebp)
  106253:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106256:	0f af 45 10          	imul   0x10(%ebp),%eax
  10625a:	89 c2                	mov    %eax,%edx
  10625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10625f:	01 d0                	add    %edx,%eax
  106261:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106264:	e9 72 ff ff ff       	jmp    1061db <strtol+0xa7>
            break;
  106269:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10626a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10626e:	74 08                	je     106278 <strtol+0x144>
        *endptr = (char *) s;
  106270:	8b 45 0c             	mov    0xc(%ebp),%eax
  106273:	8b 55 08             	mov    0x8(%ebp),%edx
  106276:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106278:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10627c:	74 07                	je     106285 <strtol+0x151>
  10627e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106281:	f7 d8                	neg    %eax
  106283:	eb 03                	jmp    106288 <strtol+0x154>
  106285:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106288:	89 ec                	mov    %ebp,%esp
  10628a:	5d                   	pop    %ebp
  10628b:	c3                   	ret    

0010628c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10628c:	55                   	push   %ebp
  10628d:	89 e5                	mov    %esp,%ebp
  10628f:	83 ec 28             	sub    $0x28,%esp
  106292:	89 7d fc             	mov    %edi,-0x4(%ebp)
  106295:	8b 45 0c             	mov    0xc(%ebp),%eax
  106298:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10629b:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  10629f:	8b 45 08             	mov    0x8(%ebp),%eax
  1062a2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1062a5:	88 55 f7             	mov    %dl,-0x9(%ebp)
  1062a8:	8b 45 10             	mov    0x10(%ebp),%eax
  1062ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1062ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1062b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1062b5:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1062b8:	89 d7                	mov    %edx,%edi
  1062ba:	f3 aa                	rep stos %al,%es:(%edi)
  1062bc:	89 fa                	mov    %edi,%edx
  1062be:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1062c1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1062c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1062c7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1062ca:	89 ec                	mov    %ebp,%esp
  1062cc:	5d                   	pop    %ebp
  1062cd:	c3                   	ret    

001062ce <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1062ce:	55                   	push   %ebp
  1062cf:	89 e5                	mov    %esp,%ebp
  1062d1:	57                   	push   %edi
  1062d2:	56                   	push   %esi
  1062d3:	53                   	push   %ebx
  1062d4:	83 ec 30             	sub    $0x30,%esp
  1062d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1062da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1062dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1062e3:	8b 45 10             	mov    0x10(%ebp),%eax
  1062e6:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1062ec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1062ef:	73 42                	jae    106333 <memmove+0x65>
  1062f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1062f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1062f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1062fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1062fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106300:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106303:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106306:	c1 e8 02             	shr    $0x2,%eax
  106309:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10630b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10630e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106311:	89 d7                	mov    %edx,%edi
  106313:	89 c6                	mov    %eax,%esi
  106315:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10631a:	83 e1 03             	and    $0x3,%ecx
  10631d:	74 02                	je     106321 <memmove+0x53>
  10631f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106321:	89 f0                	mov    %esi,%eax
  106323:	89 fa                	mov    %edi,%edx
  106325:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106328:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10632b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10632e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  106331:	eb 36                	jmp    106369 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106333:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106336:	8d 50 ff             	lea    -0x1(%eax),%edx
  106339:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10633c:	01 c2                	add    %eax,%edx
  10633e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106341:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106347:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  10634a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10634d:	89 c1                	mov    %eax,%ecx
  10634f:	89 d8                	mov    %ebx,%eax
  106351:	89 d6                	mov    %edx,%esi
  106353:	89 c7                	mov    %eax,%edi
  106355:	fd                   	std    
  106356:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106358:	fc                   	cld    
  106359:	89 f8                	mov    %edi,%eax
  10635b:	89 f2                	mov    %esi,%edx
  10635d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106360:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106363:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106369:	83 c4 30             	add    $0x30,%esp
  10636c:	5b                   	pop    %ebx
  10636d:	5e                   	pop    %esi
  10636e:	5f                   	pop    %edi
  10636f:	5d                   	pop    %ebp
  106370:	c3                   	ret    

00106371 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106371:	55                   	push   %ebp
  106372:	89 e5                	mov    %esp,%ebp
  106374:	57                   	push   %edi
  106375:	56                   	push   %esi
  106376:	83 ec 20             	sub    $0x20,%esp
  106379:	8b 45 08             	mov    0x8(%ebp),%eax
  10637c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10637f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106382:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106385:	8b 45 10             	mov    0x10(%ebp),%eax
  106388:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10638b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10638e:	c1 e8 02             	shr    $0x2,%eax
  106391:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106393:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106399:	89 d7                	mov    %edx,%edi
  10639b:	89 c6                	mov    %eax,%esi
  10639d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10639f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1063a2:	83 e1 03             	and    $0x3,%ecx
  1063a5:	74 02                	je     1063a9 <memcpy+0x38>
  1063a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1063a9:	89 f0                	mov    %esi,%eax
  1063ab:	89 fa                	mov    %edi,%edx
  1063ad:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1063b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1063b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1063b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1063b9:	83 c4 20             	add    $0x20,%esp
  1063bc:	5e                   	pop    %esi
  1063bd:	5f                   	pop    %edi
  1063be:	5d                   	pop    %ebp
  1063bf:	c3                   	ret    

001063c0 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1063c0:	55                   	push   %ebp
  1063c1:	89 e5                	mov    %esp,%ebp
  1063c3:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1063c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1063c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1063cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1063d2:	eb 2e                	jmp    106402 <memcmp+0x42>
        if (*s1 != *s2) {
  1063d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1063d7:	0f b6 10             	movzbl (%eax),%edx
  1063da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1063dd:	0f b6 00             	movzbl (%eax),%eax
  1063e0:	38 c2                	cmp    %al,%dl
  1063e2:	74 18                	je     1063fc <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1063e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1063e7:	0f b6 00             	movzbl (%eax),%eax
  1063ea:	0f b6 d0             	movzbl %al,%edx
  1063ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1063f0:	0f b6 00             	movzbl (%eax),%eax
  1063f3:	0f b6 c8             	movzbl %al,%ecx
  1063f6:	89 d0                	mov    %edx,%eax
  1063f8:	29 c8                	sub    %ecx,%eax
  1063fa:	eb 18                	jmp    106414 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1063fc:	ff 45 fc             	incl   -0x4(%ebp)
  1063ff:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  106402:	8b 45 10             	mov    0x10(%ebp),%eax
  106405:	8d 50 ff             	lea    -0x1(%eax),%edx
  106408:	89 55 10             	mov    %edx,0x10(%ebp)
  10640b:	85 c0                	test   %eax,%eax
  10640d:	75 c5                	jne    1063d4 <memcmp+0x14>
    }
    return 0;
  10640f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106414:	89 ec                	mov    %ebp,%esp
  106416:	5d                   	pop    %ebp
  106417:	c3                   	ret    
