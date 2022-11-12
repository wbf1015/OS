
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
void grade_backtrace(void);
static void lab1_switch_test(void);
static void lab1_print_cur_status(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c0100041:	2d 00 c0 11 c0       	sub    $0xc011c000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c0100059:	e8 2e 62 00 00       	call   c010628c <memset>

    cons_init();                // init the console
c010005e:	e8 2c 16 00 00       	call   c010168f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f0 20 64 10 c0 	movl   $0xc0106420,-0x10(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 3c 64 10 c0 	movl   $0xc010643c,(%esp)
c0100078:	e8 1e 03 00 00       	call   c010039b <cprintf>

    print_kerninfo();
c010007d:	e8 3c 08 00 00       	call   c01008be <print_kerninfo>

    grade_backtrace();
c0100082:	e8 ca 00 00 00       	call   c0100151 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 77 47 00 00       	call   c0104803 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 7f 17 00 00       	call   c0101810 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 06 19 00 00       	call   c010199c <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 53 0d 00 00       	call   c0100dee <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 ce 16 00 00       	call   c010176e <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a0:	e8 ab 01 00 00       	call   c0100250 <lab1_switch_test>

    /* do nothing */
    long cnt = 0;
c01000a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
	if ((++cnt) % 10000000 == 0)
c01000ac:	ff 45 f4             	incl   -0xc(%ebp)
c01000af:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c01000b2:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
c01000b7:	89 c8                	mov    %ecx,%eax
c01000b9:	f7 ea                	imul   %edx
c01000bb:	89 d0                	mov    %edx,%eax
c01000bd:	c1 f8 16             	sar    $0x16,%eax
c01000c0:	89 ca                	mov    %ecx,%edx
c01000c2:	c1 fa 1f             	sar    $0x1f,%edx
c01000c5:	29 d0                	sub    %edx,%eax
c01000c7:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
c01000cd:	89 c8                	mov    %ecx,%eax
c01000cf:	29 d0                	sub    %edx,%eax
c01000d1:	85 c0                	test   %eax,%eax
c01000d3:	75 d7                	jne    c01000ac <kern_init+0x76>
	    lab1_print_cur_status();
c01000d5:	e8 9f 00 00 00       	call   c0100179 <lab1_print_cur_status>
	if ((++cnt) % 10000000 == 0)
c01000da:	eb d0                	jmp    c01000ac <kern_init+0x76>

c01000dc <grade_backtrace2>:
	}
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000dc:	55                   	push   %ebp
c01000dd:	89 e5                	mov    %esp,%ebp
c01000df:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000e9:	00 
c01000ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000f1:	00 
c01000f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000f9:	e8 0b 0c 00 00       	call   c0100d09 <mon_backtrace>
}
c01000fe:	90                   	nop
c01000ff:	89 ec                	mov    %ebp,%esp
c0100101:	5d                   	pop    %ebp
c0100102:	c3                   	ret    

c0100103 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c0100103:	55                   	push   %ebp
c0100104:	89 e5                	mov    %esp,%ebp
c0100106:	83 ec 18             	sub    $0x18,%esp
c0100109:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c010010c:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c010010f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100112:	8d 5d 08             	lea    0x8(%ebp),%ebx
c0100115:	8b 45 08             	mov    0x8(%ebp),%eax
c0100118:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010011c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100124:	89 04 24             	mov    %eax,(%esp)
c0100127:	e8 b0 ff ff ff       	call   c01000dc <grade_backtrace2>
}
c010012c:	90                   	nop
c010012d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100130:	89 ec                	mov    %ebp,%esp
c0100132:	5d                   	pop    %ebp
c0100133:	c3                   	ret    

c0100134 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100134:	55                   	push   %ebp
c0100135:	89 e5                	mov    %esp,%ebp
c0100137:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010013a:	8b 45 10             	mov    0x10(%ebp),%eax
c010013d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100141:	8b 45 08             	mov    0x8(%ebp),%eax
c0100144:	89 04 24             	mov    %eax,(%esp)
c0100147:	e8 b7 ff ff ff       	call   c0100103 <grade_backtrace1>
}
c010014c:	90                   	nop
c010014d:	89 ec                	mov    %ebp,%esp
c010014f:	5d                   	pop    %ebp
c0100150:	c3                   	ret    

c0100151 <grade_backtrace>:

void
grade_backtrace(void) {
c0100151:	55                   	push   %ebp
c0100152:	89 e5                	mov    %esp,%ebp
c0100154:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100157:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010015c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100163:	ff 
c0100164:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010016f:	e8 c0 ff ff ff       	call   c0100134 <grade_backtrace0>
}
c0100174:	90                   	nop
c0100175:	89 ec                	mov    %ebp,%esp
c0100177:	5d                   	pop    %ebp
c0100178:	c3                   	ret    

c0100179 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100179:	55                   	push   %ebp
c010017a:	89 e5                	mov    %esp,%ebp
c010017c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010017f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100182:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100185:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100188:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010018b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018f:	83 e0 03             	and    $0x3,%eax
c0100192:	89 c2                	mov    %eax,%edx
c0100194:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 41 64 10 c0 	movl   $0xc0106441,(%esp)
c01001a8:	e8 ee 01 00 00       	call   c010039b <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c01001ad:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01001b1:	89 c2                	mov    %eax,%edx
c01001b3:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001b8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c0:	c7 04 24 4f 64 10 c0 	movl   $0xc010644f,(%esp)
c01001c7:	e8 cf 01 00 00       	call   c010039b <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001cc:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001d0:	89 c2                	mov    %eax,%edx
c01001d2:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001d7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001df:	c7 04 24 5d 64 10 c0 	movl   $0xc010645d,(%esp)
c01001e6:	e8 b0 01 00 00       	call   c010039b <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001eb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001ef:	89 c2                	mov    %eax,%edx
c01001f1:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fe:	c7 04 24 6b 64 10 c0 	movl   $0xc010646b,(%esp)
c0100205:	e8 91 01 00 00       	call   c010039b <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c010020a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010020e:	89 c2                	mov    %eax,%edx
c0100210:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100215:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100219:	89 44 24 04          	mov    %eax,0x4(%esp)
c010021d:	c7 04 24 79 64 10 c0 	movl   $0xc0106479,(%esp)
c0100224:	e8 72 01 00 00       	call   c010039b <cprintf>
    round ++;
c0100229:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010022e:	40                   	inc    %eax
c010022f:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c0100234:	90                   	nop
c0100235:	89 ec                	mov    %ebp,%esp
c0100237:	5d                   	pop    %ebp
c0100238:	c3                   	ret    

c0100239 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100239:	55                   	push   %ebp
c010023a:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	__asm__ __volatile__ (
c010023c:	83 ec 08             	sub    $0x8,%esp
c010023f:	cd 78                	int    $0x78
c0100241:	89 ec                	mov    %ebp,%esp
		"int %0 \n"
        "movl %%ebp, %%esp\n"
		:
		:"i" (T_SWITCH_TOU)
	);
}
c0100243:	90                   	nop
c0100244:	5d                   	pop    %ebp
c0100245:	c3                   	ret    

c0100246 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100246:	55                   	push   %ebp
c0100247:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
c0100249:	cd 79                	int    $0x79
c010024b:	89 ec                	mov    %ebp,%esp
    	"int %0 \n"
    	"movl %%ebp,%%esp \n" 
    	:
    	:"i"(T_SWITCH_TOK)
    );
}
c010024d:	90                   	nop
c010024e:	5d                   	pop    %ebp
c010024f:	c3                   	ret    

c0100250 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100250:	55                   	push   %ebp
c0100251:	89 e5                	mov    %esp,%ebp
c0100253:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100256:	e8 1e ff ff ff       	call   c0100179 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010025b:	c7 04 24 88 64 10 c0 	movl   $0xc0106488,(%esp)
c0100262:	e8 34 01 00 00       	call   c010039b <cprintf>
    lab1_switch_to_user();
c0100267:	e8 cd ff ff ff       	call   c0100239 <lab1_switch_to_user>
    lab1_print_cur_status();
c010026c:	e8 08 ff ff ff       	call   c0100179 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100271:	c7 04 24 a8 64 10 c0 	movl   $0xc01064a8,(%esp)
c0100278:	e8 1e 01 00 00       	call   c010039b <cprintf>
    lab1_switch_to_kernel();
c010027d:	e8 c4 ff ff ff       	call   c0100246 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100282:	e8 f2 fe ff ff       	call   c0100179 <lab1_print_cur_status>
}
c0100287:	90                   	nop
c0100288:	89 ec                	mov    %ebp,%esp
c010028a:	5d                   	pop    %ebp
c010028b:	c3                   	ret    

c010028c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010028c:	55                   	push   %ebp
c010028d:	89 e5                	mov    %esp,%ebp
c010028f:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100292:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100296:	74 13                	je     c01002ab <readline+0x1f>
        cprintf("%s", prompt);
c0100298:	8b 45 08             	mov    0x8(%ebp),%eax
c010029b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010029f:	c7 04 24 c7 64 10 c0 	movl   $0xc01064c7,(%esp)
c01002a6:	e8 f0 00 00 00       	call   c010039b <cprintf>
    }
    int i = 0, c;
c01002ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01002b2:	e8 73 01 00 00       	call   c010042a <getchar>
c01002b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01002ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01002be:	79 07                	jns    c01002c7 <readline+0x3b>
            return NULL;
c01002c0:	b8 00 00 00 00       	mov    $0x0,%eax
c01002c5:	eb 78                	jmp    c010033f <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01002c7:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01002cb:	7e 28                	jle    c01002f5 <readline+0x69>
c01002cd:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002d4:	7f 1f                	jg     c01002f5 <readline+0x69>
            cputchar(c);
c01002d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d9:	89 04 24             	mov    %eax,(%esp)
c01002dc:	e8 e2 00 00 00       	call   c01003c3 <cputchar>
            buf[i ++] = c;
c01002e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e4:	8d 50 01             	lea    0x1(%eax),%edx
c01002e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ed:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01002f3:	eb 45                	jmp    c010033a <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002f5:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002f9:	75 16                	jne    c0100311 <readline+0x85>
c01002fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ff:	7e 10                	jle    c0100311 <readline+0x85>
            cputchar(c);
c0100301:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100304:	89 04 24             	mov    %eax,(%esp)
c0100307:	e8 b7 00 00 00       	call   c01003c3 <cputchar>
            i --;
c010030c:	ff 4d f4             	decl   -0xc(%ebp)
c010030f:	eb 29                	jmp    c010033a <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c0100311:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100315:	74 06                	je     c010031d <readline+0x91>
c0100317:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010031b:	75 95                	jne    c01002b2 <readline+0x26>
            cputchar(c);
c010031d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100320:	89 04 24             	mov    %eax,(%esp)
c0100323:	e8 9b 00 00 00       	call   c01003c3 <cputchar>
            buf[i] = '\0';
c0100328:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010032b:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100330:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100333:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c0100338:	eb 05                	jmp    c010033f <readline+0xb3>
        c = getchar();
c010033a:	e9 73 ff ff ff       	jmp    c01002b2 <readline+0x26>
        }
    }
}
c010033f:	89 ec                	mov    %ebp,%esp
c0100341:	5d                   	pop    %ebp
c0100342:	c3                   	ret    

c0100343 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100343:	55                   	push   %ebp
c0100344:	89 e5                	mov    %esp,%ebp
c0100346:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100349:	8b 45 08             	mov    0x8(%ebp),%eax
c010034c:	89 04 24             	mov    %eax,(%esp)
c010034f:	e8 6a 13 00 00       	call   c01016be <cons_putc>
    (*cnt) ++;
c0100354:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100357:	8b 00                	mov    (%eax),%eax
c0100359:	8d 50 01             	lea    0x1(%eax),%edx
c010035c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010035f:	89 10                	mov    %edx,(%eax)
}
c0100361:	90                   	nop
c0100362:	89 ec                	mov    %ebp,%esp
c0100364:	5d                   	pop    %ebp
c0100365:	c3                   	ret    

c0100366 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100366:	55                   	push   %ebp
c0100367:	89 e5                	mov    %esp,%ebp
c0100369:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010036c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100373:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100376:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010037a:	8b 45 08             	mov    0x8(%ebp),%eax
c010037d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100381:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100384:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100388:	c7 04 24 43 03 10 c0 	movl   $0xc0100343,(%esp)
c010038f:	e8 23 57 00 00       	call   c0105ab7 <vprintfmt>
    return cnt;
c0100394:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100397:	89 ec                	mov    %ebp,%esp
c0100399:	5d                   	pop    %ebp
c010039a:	c3                   	ret    

c010039b <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010039b:	55                   	push   %ebp
c010039c:	89 e5                	mov    %esp,%ebp
c010039e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01003a1:	8d 45 0c             	lea    0xc(%ebp),%eax
c01003a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01003a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b1:	89 04 24             	mov    %eax,(%esp)
c01003b4:	e8 ad ff ff ff       	call   c0100366 <vcprintf>
c01003b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003bf:	89 ec                	mov    %ebp,%esp
c01003c1:	5d                   	pop    %ebp
c01003c2:	c3                   	ret    

c01003c3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01003c3:	55                   	push   %ebp
c01003c4:	89 e5                	mov    %esp,%ebp
c01003c6:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01003c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01003cc:	89 04 24             	mov    %eax,(%esp)
c01003cf:	e8 ea 12 00 00       	call   c01016be <cons_putc>
}
c01003d4:	90                   	nop
c01003d5:	89 ec                	mov    %ebp,%esp
c01003d7:	5d                   	pop    %ebp
c01003d8:	c3                   	ret    

c01003d9 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003d9:	55                   	push   %ebp
c01003da:	89 e5                	mov    %esp,%ebp
c01003dc:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003e6:	eb 13                	jmp    c01003fb <cputs+0x22>
        cputch(c, &cnt);
c01003e8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003ec:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003ef:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003f3:	89 04 24             	mov    %eax,(%esp)
c01003f6:	e8 48 ff ff ff       	call   c0100343 <cputch>
    while ((c = *str ++) != '\0') {
c01003fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01003fe:	8d 50 01             	lea    0x1(%eax),%edx
c0100401:	89 55 08             	mov    %edx,0x8(%ebp)
c0100404:	0f b6 00             	movzbl (%eax),%eax
c0100407:	88 45 f7             	mov    %al,-0x9(%ebp)
c010040a:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010040e:	75 d8                	jne    c01003e8 <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100410:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100413:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100417:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010041e:	e8 20 ff ff ff       	call   c0100343 <cputch>
    return cnt;
c0100423:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100426:	89 ec                	mov    %ebp,%esp
c0100428:	5d                   	pop    %ebp
c0100429:	c3                   	ret    

c010042a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010042a:	55                   	push   %ebp
c010042b:	89 e5                	mov    %esp,%ebp
c010042d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100430:	90                   	nop
c0100431:	e8 c7 12 00 00       	call   c01016fd <cons_getc>
c0100436:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010043d:	74 f2                	je     c0100431 <getchar+0x7>
        /* do nothing */;
    return c;
c010043f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100442:	89 ec                	mov    %ebp,%esp
c0100444:	5d                   	pop    %ebp
c0100445:	c3                   	ret    

c0100446 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100446:	55                   	push   %ebp
c0100447:	89 e5                	mov    %esp,%ebp
c0100449:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010044c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010044f:	8b 00                	mov    (%eax),%eax
c0100451:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100454:	8b 45 10             	mov    0x10(%ebp),%eax
c0100457:	8b 00                	mov    (%eax),%eax
c0100459:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010045c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100463:	e9 ca 00 00 00       	jmp    c0100532 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100468:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010046b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010046e:	01 d0                	add    %edx,%eax
c0100470:	89 c2                	mov    %eax,%edx
c0100472:	c1 ea 1f             	shr    $0x1f,%edx
c0100475:	01 d0                	add    %edx,%eax
c0100477:	d1 f8                	sar    %eax
c0100479:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010047c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010047f:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100482:	eb 03                	jmp    c0100487 <stab_binsearch+0x41>
            m --;
c0100484:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100487:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010048a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010048d:	7c 1f                	jl     c01004ae <stab_binsearch+0x68>
c010048f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100492:	89 d0                	mov    %edx,%eax
c0100494:	01 c0                	add    %eax,%eax
c0100496:	01 d0                	add    %edx,%eax
c0100498:	c1 e0 02             	shl    $0x2,%eax
c010049b:	89 c2                	mov    %eax,%edx
c010049d:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a0:	01 d0                	add    %edx,%eax
c01004a2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01004a6:	0f b6 c0             	movzbl %al,%eax
c01004a9:	39 45 14             	cmp    %eax,0x14(%ebp)
c01004ac:	75 d6                	jne    c0100484 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c01004ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004b4:	7d 09                	jge    c01004bf <stab_binsearch+0x79>
            l = true_m + 1;
c01004b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004b9:	40                   	inc    %eax
c01004ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01004bd:	eb 73                	jmp    c0100532 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c01004bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01004c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004c9:	89 d0                	mov    %edx,%eax
c01004cb:	01 c0                	add    %eax,%eax
c01004cd:	01 d0                	add    %edx,%eax
c01004cf:	c1 e0 02             	shl    $0x2,%eax
c01004d2:	89 c2                	mov    %eax,%edx
c01004d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d7:	01 d0                	add    %edx,%eax
c01004d9:	8b 40 08             	mov    0x8(%eax),%eax
c01004dc:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004df:	76 11                	jbe    c01004f2 <stab_binsearch+0xac>
            *region_left = m;
c01004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e7:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004ec:	40                   	inc    %eax
c01004ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004f0:	eb 40                	jmp    c0100532 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f5:	89 d0                	mov    %edx,%eax
c01004f7:	01 c0                	add    %eax,%eax
c01004f9:	01 d0                	add    %edx,%eax
c01004fb:	c1 e0 02             	shl    $0x2,%eax
c01004fe:	89 c2                	mov    %eax,%edx
c0100500:	8b 45 08             	mov    0x8(%ebp),%eax
c0100503:	01 d0                	add    %edx,%eax
c0100505:	8b 40 08             	mov    0x8(%eax),%eax
c0100508:	39 45 18             	cmp    %eax,0x18(%ebp)
c010050b:	73 14                	jae    c0100521 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010050d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100510:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100513:	8b 45 10             	mov    0x10(%ebp),%eax
c0100516:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010051b:	48                   	dec    %eax
c010051c:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010051f:	eb 11                	jmp    c0100532 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100521:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100524:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100527:	89 10                	mov    %edx,(%eax)
            l = m;
c0100529:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010052f:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100532:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100535:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100538:	0f 8e 2a ff ff ff    	jle    c0100468 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c010053e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100542:	75 0f                	jne    c0100553 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 00                	mov    (%eax),%eax
c0100549:	8d 50 ff             	lea    -0x1(%eax),%edx
c010054c:	8b 45 10             	mov    0x10(%ebp),%eax
c010054f:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100551:	eb 3e                	jmp    c0100591 <stab_binsearch+0x14b>
        l = *region_right;
c0100553:	8b 45 10             	mov    0x10(%ebp),%eax
c0100556:	8b 00                	mov    (%eax),%eax
c0100558:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010055b:	eb 03                	jmp    c0100560 <stab_binsearch+0x11a>
c010055d:	ff 4d fc             	decl   -0x4(%ebp)
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	8b 00                	mov    (%eax),%eax
c0100565:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100568:	7e 1f                	jle    c0100589 <stab_binsearch+0x143>
c010056a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010056d:	89 d0                	mov    %edx,%eax
c010056f:	01 c0                	add    %eax,%eax
c0100571:	01 d0                	add    %edx,%eax
c0100573:	c1 e0 02             	shl    $0x2,%eax
c0100576:	89 c2                	mov    %eax,%edx
c0100578:	8b 45 08             	mov    0x8(%ebp),%eax
c010057b:	01 d0                	add    %edx,%eax
c010057d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100581:	0f b6 c0             	movzbl %al,%eax
c0100584:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100587:	75 d4                	jne    c010055d <stab_binsearch+0x117>
        *region_left = l;
c0100589:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010058f:	89 10                	mov    %edx,(%eax)
}
c0100591:	90                   	nop
c0100592:	89 ec                	mov    %ebp,%esp
c0100594:	5d                   	pop    %ebp
c0100595:	c3                   	ret    

c0100596 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100596:	55                   	push   %ebp
c0100597:	89 e5                	mov    %esp,%ebp
c0100599:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010059c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010059f:	c7 00 cc 64 10 c0    	movl   $0xc01064cc,(%eax)
    info->eip_line = 0;
c01005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	c7 40 08 cc 64 10 c0 	movl   $0xc01064cc,0x8(%eax)
    info->eip_fn_namelen = 9;
c01005b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005bc:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c6:	8b 55 08             	mov    0x8(%ebp),%edx
c01005c9:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005cf:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005d6:	c7 45 f4 b0 77 10 c0 	movl   $0xc01077b0,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005dd:	c7 45 f0 90 33 11 c0 	movl   $0xc0113390,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005e4:	c7 45 ec 91 33 11 c0 	movl   $0xc0113391,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005eb:	c7 45 e8 a4 69 11 c0 	movl   $0xc01169a4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005f8:	76 0b                	jbe    c0100605 <debuginfo_eip+0x6f>
c01005fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005fd:	48                   	dec    %eax
c01005fe:	0f b6 00             	movzbl (%eax),%eax
c0100601:	84 c0                	test   %al,%al
c0100603:	74 0a                	je     c010060f <debuginfo_eip+0x79>
        return -1;
c0100605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060a:	e9 ab 02 00 00       	jmp    c01008ba <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010060f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100616:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100619:	2b 45 f4             	sub    -0xc(%ebp),%eax
c010061c:	c1 f8 02             	sar    $0x2,%eax
c010061f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100625:	48                   	dec    %eax
c0100626:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 f5 fd ff ff       	call   c0100446 <stab_binsearch>
    if (lfile == 0)
c0100651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100654:	85 c0                	test   %eax,%eax
c0100656:	75 0a                	jne    c0100662 <debuginfo_eip+0xcc>
        return -1;
c0100658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010065d:	e9 58 02 00 00       	jmp    c01008ba <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100665:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100668:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010066e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100671:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100675:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010067c:	00 
c010067d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100680:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100684:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100687:	89 44 24 04          	mov    %eax,0x4(%esp)
c010068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068e:	89 04 24             	mov    %eax,(%esp)
c0100691:	e8 b0 fd ff ff       	call   c0100446 <stab_binsearch>

    if (lfun <= rfun) {
c0100696:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100699:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010069c:	39 c2                	cmp    %eax,%edx
c010069e:	7f 78                	jg     c0100718 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01006a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a3:	89 c2                	mov    %eax,%edx
c01006a5:	89 d0                	mov    %edx,%eax
c01006a7:	01 c0                	add    %eax,%eax
c01006a9:	01 d0                	add    %edx,%eax
c01006ab:	c1 e0 02             	shl    $0x2,%eax
c01006ae:	89 c2                	mov    %eax,%edx
c01006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b3:	01 d0                	add    %edx,%eax
c01006b5:	8b 10                	mov    (%eax),%edx
c01006b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ba:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01006bd:	39 c2                	cmp    %eax,%edx
c01006bf:	73 22                	jae    c01006e3 <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c01006c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c4:	89 c2                	mov    %eax,%edx
c01006c6:	89 d0                	mov    %edx,%eax
c01006c8:	01 c0                	add    %eax,%eax
c01006ca:	01 d0                	add    %edx,%eax
c01006cc:	c1 e0 02             	shl    $0x2,%eax
c01006cf:	89 c2                	mov    %eax,%edx
c01006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d4:	01 d0                	add    %edx,%eax
c01006d6:	8b 10                	mov    (%eax),%edx
c01006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006db:	01 c2                	add    %eax,%edx
c01006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006e6:	89 c2                	mov    %eax,%edx
c01006e8:	89 d0                	mov    %edx,%eax
c01006ea:	01 c0                	add    %eax,%eax
c01006ec:	01 d0                	add    %edx,%eax
c01006ee:	c1 e0 02             	shl    $0x2,%eax
c01006f1:	89 c2                	mov    %eax,%edx
c01006f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006f6:	01 d0                	add    %edx,%eax
c01006f8:	8b 50 08             	mov    0x8(%eax),%edx
c01006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fe:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100701:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100704:	8b 40 10             	mov    0x10(%eax),%eax
c0100707:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010070a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010070d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100710:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100713:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100716:	eb 15                	jmp    c010072d <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100718:	8b 45 0c             	mov    0xc(%ebp),%eax
c010071b:	8b 55 08             	mov    0x8(%ebp),%edx
c010071e:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100724:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100727:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010072a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c010072d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100730:	8b 40 08             	mov    0x8(%eax),%eax
c0100733:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010073a:	00 
c010073b:	89 04 24             	mov    %eax,(%esp)
c010073e:	e8 c1 59 00 00       	call   c0106104 <strfind>
c0100743:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100746:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100749:	29 c8                	sub    %ecx,%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100750:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100753:	8b 45 08             	mov    0x8(%ebp),%eax
c0100756:	89 44 24 10          	mov    %eax,0x10(%esp)
c010075a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100761:	00 
c0100762:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100765:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100769:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010076c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100770:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100773:	89 04 24             	mov    %eax,(%esp)
c0100776:	e8 cb fc ff ff       	call   c0100446 <stab_binsearch>
    if (lline <= rline) {
c010077b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010077e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100781:	39 c2                	cmp    %eax,%edx
c0100783:	7f 23                	jg     c01007a8 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100785:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100788:	89 c2                	mov    %eax,%edx
c010078a:	89 d0                	mov    %edx,%eax
c010078c:	01 c0                	add    %eax,%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	c1 e0 02             	shl    $0x2,%eax
c0100793:	89 c2                	mov    %eax,%edx
c0100795:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100798:	01 d0                	add    %edx,%eax
c010079a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a3:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01007a6:	eb 11                	jmp    c01007b9 <debuginfo_eip+0x223>
        return -1;
c01007a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007ad:	e9 08 01 00 00       	jmp    c01008ba <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01007b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b5:	48                   	dec    %eax
c01007b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c01007b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007bf:	39 c2                	cmp    %eax,%edx
c01007c1:	7c 56                	jl     c0100819 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c01007c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	89 d0                	mov    %edx,%eax
c01007ca:	01 c0                	add    %eax,%eax
c01007cc:	01 d0                	add    %edx,%eax
c01007ce:	c1 e0 02             	shl    $0x2,%eax
c01007d1:	89 c2                	mov    %eax,%edx
c01007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d6:	01 d0                	add    %edx,%eax
c01007d8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007dc:	3c 84                	cmp    $0x84,%al
c01007de:	74 39                	je     c0100819 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e3:	89 c2                	mov    %eax,%edx
c01007e5:	89 d0                	mov    %edx,%eax
c01007e7:	01 c0                	add    %eax,%eax
c01007e9:	01 d0                	add    %edx,%eax
c01007eb:	c1 e0 02             	shl    $0x2,%eax
c01007ee:	89 c2                	mov    %eax,%edx
c01007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007f9:	3c 64                	cmp    $0x64,%al
c01007fb:	75 b5                	jne    c01007b2 <debuginfo_eip+0x21c>
c01007fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	89 d0                	mov    %edx,%eax
c0100804:	01 c0                	add    %eax,%eax
c0100806:	01 d0                	add    %edx,%eax
c0100808:	c1 e0 02             	shl    $0x2,%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	8b 40 08             	mov    0x8(%eax),%eax
c0100815:	85 c0                	test   %eax,%eax
c0100817:	74 99                	je     c01007b2 <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100819:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010081c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010081f:	39 c2                	cmp    %eax,%edx
c0100821:	7c 42                	jl     c0100865 <debuginfo_eip+0x2cf>
c0100823:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100826:	89 c2                	mov    %eax,%edx
c0100828:	89 d0                	mov    %edx,%eax
c010082a:	01 c0                	add    %eax,%eax
c010082c:	01 d0                	add    %edx,%eax
c010082e:	c1 e0 02             	shl    $0x2,%eax
c0100831:	89 c2                	mov    %eax,%edx
c0100833:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100836:	01 d0                	add    %edx,%eax
c0100838:	8b 10                	mov    (%eax),%edx
c010083a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010083d:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100840:	39 c2                	cmp    %eax,%edx
c0100842:	73 21                	jae    c0100865 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100847:	89 c2                	mov    %eax,%edx
c0100849:	89 d0                	mov    %edx,%eax
c010084b:	01 c0                	add    %eax,%eax
c010084d:	01 d0                	add    %edx,%eax
c010084f:	c1 e0 02             	shl    $0x2,%eax
c0100852:	89 c2                	mov    %eax,%edx
c0100854:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100857:	01 d0                	add    %edx,%eax
c0100859:	8b 10                	mov    (%eax),%edx
c010085b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010085e:	01 c2                	add    %eax,%edx
c0100860:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100863:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100865:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100868:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010086b:	39 c2                	cmp    %eax,%edx
c010086d:	7d 46                	jge    c01008b5 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010086f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100872:	40                   	inc    %eax
c0100873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100876:	eb 16                	jmp    c010088e <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100878:	8b 45 0c             	mov    0xc(%ebp),%eax
c010087b:	8b 40 14             	mov    0x14(%eax),%eax
c010087e:	8d 50 01             	lea    0x1(%eax),%edx
c0100881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100884:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100887:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088a:	40                   	inc    %eax
c010088b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010088e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100891:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100894:	39 c2                	cmp    %eax,%edx
c0100896:	7d 1d                	jge    c01008b5 <debuginfo_eip+0x31f>
c0100898:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089b:	89 c2                	mov    %eax,%edx
c010089d:	89 d0                	mov    %edx,%eax
c010089f:	01 c0                	add    %eax,%eax
c01008a1:	01 d0                	add    %edx,%eax
c01008a3:	c1 e0 02             	shl    $0x2,%eax
c01008a6:	89 c2                	mov    %eax,%edx
c01008a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ab:	01 d0                	add    %edx,%eax
c01008ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008b1:	3c a0                	cmp    $0xa0,%al
c01008b3:	74 c3                	je     c0100878 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c01008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01008ba:	89 ec                	mov    %ebp,%esp
c01008bc:	5d                   	pop    %ebp
c01008bd:	c3                   	ret    

c01008be <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c01008be:	55                   	push   %ebp
c01008bf:	89 e5                	mov    %esp,%ebp
c01008c1:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c01008c4:	c7 04 24 d6 64 10 c0 	movl   $0xc01064d6,(%esp)
c01008cb:	e8 cb fa ff ff       	call   c010039b <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01008d0:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008d7:	c0 
c01008d8:	c7 04 24 ef 64 10 c0 	movl   $0xc01064ef,(%esp)
c01008df:	e8 b7 fa ff ff       	call   c010039b <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008e4:	c7 44 24 04 18 64 10 	movl   $0xc0106418,0x4(%esp)
c01008eb:	c0 
c01008ec:	c7 04 24 07 65 10 c0 	movl   $0xc0106507,(%esp)
c01008f3:	e8 a3 fa ff ff       	call   c010039b <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008f8:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01008ff:	c0 
c0100900:	c7 04 24 1f 65 10 c0 	movl   $0xc010651f,(%esp)
c0100907:	e8 8f fa ff ff       	call   c010039b <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c010090c:	c7 44 24 04 8c cf 11 	movl   $0xc011cf8c,0x4(%esp)
c0100913:	c0 
c0100914:	c7 04 24 37 65 10 c0 	movl   $0xc0106537,(%esp)
c010091b:	e8 7b fa ff ff       	call   c010039b <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100920:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c0100925:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c010092a:	05 ff 03 00 00       	add    $0x3ff,%eax
c010092f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100935:	85 c0                	test   %eax,%eax
c0100937:	0f 48 c2             	cmovs  %edx,%eax
c010093a:	c1 f8 0a             	sar    $0xa,%eax
c010093d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100941:	c7 04 24 50 65 10 c0 	movl   $0xc0106550,(%esp)
c0100948:	e8 4e fa ff ff       	call   c010039b <cprintf>
}
c010094d:	90                   	nop
c010094e:	89 ec                	mov    %ebp,%esp
c0100950:	5d                   	pop    %ebp
c0100951:	c3                   	ret    

c0100952 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100952:	55                   	push   %ebp
c0100953:	89 e5                	mov    %esp,%ebp
c0100955:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010095b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010095e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100962:	8b 45 08             	mov    0x8(%ebp),%eax
c0100965:	89 04 24             	mov    %eax,(%esp)
c0100968:	e8 29 fc ff ff       	call   c0100596 <debuginfo_eip>
c010096d:	85 c0                	test   %eax,%eax
c010096f:	74 15                	je     c0100986 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100971:	8b 45 08             	mov    0x8(%ebp),%eax
c0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100978:	c7 04 24 7a 65 10 c0 	movl   $0xc010657a,(%esp)
c010097f:	e8 17 fa ff ff       	call   c010039b <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100984:	eb 6c                	jmp    c01009f2 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010098d:	eb 1b                	jmp    c01009aa <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010098f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100995:	01 d0                	add    %edx,%eax
c0100997:	0f b6 10             	movzbl (%eax),%edx
c010099a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a3:	01 c8                	add    %ecx,%eax
c01009a5:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009a7:	ff 45 f4             	incl   -0xc(%ebp)
c01009aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01009ad:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01009b0:	7c dd                	jl     c010098f <print_debuginfo+0x3d>
        fnname[j] = '\0';
c01009b2:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c01009b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009bb:	01 d0                	add    %edx,%eax
c01009bd:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c01009c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c01009c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01009c6:	29 d0                	sub    %edx,%eax
c01009c8:	89 c1                	mov    %eax,%ecx
c01009ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01009cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009d0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009d4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009de:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e6:	c7 04 24 96 65 10 c0 	movl   $0xc0106596,(%esp)
c01009ed:	e8 a9 f9 ff ff       	call   c010039b <cprintf>
}
c01009f2:	90                   	nop
c01009f3:	89 ec                	mov    %ebp,%esp
c01009f5:	5d                   	pop    %ebp
c01009f6:	c3                   	ret    

c01009f7 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009f7:	55                   	push   %ebp
c01009f8:	89 e5                	mov    %esp,%ebp
c01009fa:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009fd:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a00:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a06:	89 ec                	mov    %ebp,%esp
c0100a08:	5d                   	pop    %ebp
c0100a09:	c3                   	ret    

c0100a0a <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a0a:	55                   	push   %ebp
c0100a0b:	89 e5                	mov    %esp,%ebp
c0100a0d:	83 ec 48             	sub    $0x48,%esp
c0100a10:	89 5d fc             	mov    %ebx,-0x4(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a13:	89 e8                	mov    %ebp,%eax
c0100a15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp();
c0100a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
c0100a1e:	e8 d4 ff ff ff       	call   c01009f7 <read_eip>
c0100a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;   //这里有个细节问题，就是不能for int i，这里面的C标准似乎不允许
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
c0100a26:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a2d:	eb 7e                	jmp    c0100aad <print_stackframe+0xa3>
	{
		cprintf("ebp:0x%08x eip:0x%08x\n",ebp,eip);
c0100a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a32:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3d:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0100a44:	e8 52 f9 ff ff       	call   c010039b <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
c0100a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a4c:	83 c0 08             	add    $0x8,%eax
c0100a4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));//依次打印调用函数的参数1 2 3 4
c0100a52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a55:	83 c0 0c             	add    $0xc,%eax
c0100a58:	8b 18                	mov    (%eax),%ebx
c0100a5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a5d:	83 c0 08             	add    $0x8,%eax
c0100a60:	8b 08                	mov    (%eax),%ecx
c0100a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a65:	83 c0 04             	add    $0x4,%eax
c0100a68:	8b 10                	mov    (%eax),%edx
c0100a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a6d:	8b 00                	mov    (%eax),%eax
c0100a6f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a73:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a77:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a7f:	c7 04 24 c0 65 10 c0 	movl   $0xc01065c0,(%esp)
c0100a86:	e8 10 f9 ff ff       	call   c010039b <cprintf>
 
 
    //因为使用的是栈数据结构，因此可以直接根据ebp就能读取到各个栈帧的地址和值，ebp+4处为返回地址，
    //ebp+8处为第一个参数值（最后一个入栈的参数值，对应32位系统），ebp-4处为第一个局部变量，ebp处为上一层 ebp 值。

		print_debuginfo(eip-1);
c0100a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a8e:	48                   	dec    %eax
c0100a8f:	89 04 24             	mov    %eax,(%esp)
c0100a92:	e8 bb fe ff ff       	call   c0100952 <print_debuginfo>
		eip=((uint32_t *)ebp)[1];
c0100a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a9a:	83 c0 04             	add    $0x4,%eax
c0100a9d:	8b 00                	mov    (%eax),%eax
c0100a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
c0100aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa5:	8b 00                	mov    (%eax),%eax
c0100aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
c0100aaa:	ff 45 ec             	incl   -0x14(%ebp)
c0100aad:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100ab1:	7f 0a                	jg     c0100abd <print_stackframe+0xb3>
c0100ab3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ab7:	0f 85 72 ff ff ff    	jne    c0100a2f <print_stackframe+0x25>
    }
}
c0100abd:	90                   	nop
c0100abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100ac1:	89 ec                	mov    %ebp,%esp
c0100ac3:	5d                   	pop    %ebp
c0100ac4:	c3                   	ret    

c0100ac5 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ac5:	55                   	push   %ebp
c0100ac6:	89 e5                	mov    %esp,%ebp
c0100ac8:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100acb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ad2:	eb 0c                	jmp    c0100ae0 <parse+0x1b>
            *buf ++ = '\0';
c0100ad4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad7:	8d 50 01             	lea    0x1(%eax),%edx
c0100ada:	89 55 08             	mov    %edx,0x8(%ebp)
c0100add:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ae0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae3:	0f b6 00             	movzbl (%eax),%eax
c0100ae6:	84 c0                	test   %al,%al
c0100ae8:	74 1d                	je     c0100b07 <parse+0x42>
c0100aea:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aed:	0f b6 00             	movzbl (%eax),%eax
c0100af0:	0f be c0             	movsbl %al,%eax
c0100af3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af7:	c7 04 24 64 66 10 c0 	movl   $0xc0106664,(%esp)
c0100afe:	e8 cd 55 00 00       	call   c01060d0 <strchr>
c0100b03:	85 c0                	test   %eax,%eax
c0100b05:	75 cd                	jne    c0100ad4 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0a:	0f b6 00             	movzbl (%eax),%eax
c0100b0d:	84 c0                	test   %al,%al
c0100b0f:	74 65                	je     c0100b76 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b11:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b15:	75 14                	jne    c0100b2b <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b17:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b1e:	00 
c0100b1f:	c7 04 24 69 66 10 c0 	movl   $0xc0106669,(%esp)
c0100b26:	e8 70 f8 ff ff       	call   c010039b <cprintf>
        }
        argv[argc ++] = buf;
c0100b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b2e:	8d 50 01             	lea    0x1(%eax),%edx
c0100b31:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b3e:	01 c2                	add    %eax,%edx
c0100b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b43:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b45:	eb 03                	jmp    c0100b4a <parse+0x85>
            buf ++;
c0100b47:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4d:	0f b6 00             	movzbl (%eax),%eax
c0100b50:	84 c0                	test   %al,%al
c0100b52:	74 8c                	je     c0100ae0 <parse+0x1b>
c0100b54:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b57:	0f b6 00             	movzbl (%eax),%eax
c0100b5a:	0f be c0             	movsbl %al,%eax
c0100b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b61:	c7 04 24 64 66 10 c0 	movl   $0xc0106664,(%esp)
c0100b68:	e8 63 55 00 00       	call   c01060d0 <strchr>
c0100b6d:	85 c0                	test   %eax,%eax
c0100b6f:	74 d6                	je     c0100b47 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b71:	e9 6a ff ff ff       	jmp    c0100ae0 <parse+0x1b>
            break;
c0100b76:	90                   	nop
        }
    }
    return argc;
c0100b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b7a:	89 ec                	mov    %ebp,%esp
c0100b7c:	5d                   	pop    %ebp
c0100b7d:	c3                   	ret    

c0100b7e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b7e:	55                   	push   %ebp
c0100b7f:	89 e5                	mov    %esp,%ebp
c0100b81:	83 ec 68             	sub    $0x68,%esp
c0100b84:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b87:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b91:	89 04 24             	mov    %eax,(%esp)
c0100b94:	e8 2c ff ff ff       	call   c0100ac5 <parse>
c0100b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100ba0:	75 0a                	jne    c0100bac <runcmd+0x2e>
        return 0;
c0100ba2:	b8 00 00 00 00       	mov    $0x0,%eax
c0100ba7:	e9 83 00 00 00       	jmp    c0100c2f <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bb3:	eb 5a                	jmp    c0100c0f <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100bb5:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100bb8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100bbb:	89 c8                	mov    %ecx,%eax
c0100bbd:	01 c0                	add    %eax,%eax
c0100bbf:	01 c8                	add    %ecx,%eax
c0100bc1:	c1 e0 02             	shl    $0x2,%eax
c0100bc4:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100bc9:	8b 00                	mov    (%eax),%eax
c0100bcb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bcf:	89 04 24             	mov    %eax,(%esp)
c0100bd2:	e8 5d 54 00 00       	call   c0106034 <strcmp>
c0100bd7:	85 c0                	test   %eax,%eax
c0100bd9:	75 31                	jne    c0100c0c <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bde:	89 d0                	mov    %edx,%eax
c0100be0:	01 c0                	add    %eax,%eax
c0100be2:	01 d0                	add    %edx,%eax
c0100be4:	c1 e0 02             	shl    $0x2,%eax
c0100be7:	05 08 90 11 c0       	add    $0xc0119008,%eax
c0100bec:	8b 10                	mov    (%eax),%edx
c0100bee:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bf1:	83 c0 04             	add    $0x4,%eax
c0100bf4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bf7:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c05:	89 1c 24             	mov    %ebx,(%esp)
c0100c08:	ff d2                	call   *%edx
c0100c0a:	eb 23                	jmp    c0100c2f <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c0c:	ff 45 f4             	incl   -0xc(%ebp)
c0100c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c12:	83 f8 02             	cmp    $0x2,%eax
c0100c15:	76 9e                	jbe    c0100bb5 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c17:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c1e:	c7 04 24 87 66 10 c0 	movl   $0xc0106687,(%esp)
c0100c25:	e8 71 f7 ff ff       	call   c010039b <cprintf>
    return 0;
c0100c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c32:	89 ec                	mov    %ebp,%esp
c0100c34:	5d                   	pop    %ebp
c0100c35:	c3                   	ret    

c0100c36 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c36:	55                   	push   %ebp
c0100c37:	89 e5                	mov    %esp,%ebp
c0100c39:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c3c:	c7 04 24 a0 66 10 c0 	movl   $0xc01066a0,(%esp)
c0100c43:	e8 53 f7 ff ff       	call   c010039b <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c48:	c7 04 24 c8 66 10 c0 	movl   $0xc01066c8,(%esp)
c0100c4f:	e8 47 f7 ff ff       	call   c010039b <cprintf>

    if (tf != NULL) {
c0100c54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c58:	74 0b                	je     c0100c65 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c5d:	89 04 24             	mov    %eax,(%esp)
c0100c60:	e8 6e 0f 00 00       	call   c0101bd3 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c65:	c7 04 24 ed 66 10 c0 	movl   $0xc01066ed,(%esp)
c0100c6c:	e8 1b f6 ff ff       	call   c010028c <readline>
c0100c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c78:	74 eb                	je     c0100c65 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c84:	89 04 24             	mov    %eax,(%esp)
c0100c87:	e8 f2 fe ff ff       	call   c0100b7e <runcmd>
c0100c8c:	85 c0                	test   %eax,%eax
c0100c8e:	78 02                	js     c0100c92 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c90:	eb d3                	jmp    c0100c65 <kmonitor+0x2f>
                break;
c0100c92:	90                   	nop
            }
        }
    }
}
c0100c93:	90                   	nop
c0100c94:	89 ec                	mov    %ebp,%esp
c0100c96:	5d                   	pop    %ebp
c0100c97:	c3                   	ret    

c0100c98 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c98:	55                   	push   %ebp
c0100c99:	89 e5                	mov    %esp,%ebp
c0100c9b:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ca5:	eb 3d                	jmp    c0100ce4 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100ca7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100caa:	89 d0                	mov    %edx,%eax
c0100cac:	01 c0                	add    %eax,%eax
c0100cae:	01 d0                	add    %edx,%eax
c0100cb0:	c1 e0 02             	shl    $0x2,%eax
c0100cb3:	05 04 90 11 c0       	add    $0xc0119004,%eax
c0100cb8:	8b 10                	mov    (%eax),%edx
c0100cba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100cbd:	89 c8                	mov    %ecx,%eax
c0100cbf:	01 c0                	add    %eax,%eax
c0100cc1:	01 c8                	add    %ecx,%eax
c0100cc3:	c1 e0 02             	shl    $0x2,%eax
c0100cc6:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100ccb:	8b 00                	mov    (%eax),%eax
c0100ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cd5:	c7 04 24 f1 66 10 c0 	movl   $0xc01066f1,(%esp)
c0100cdc:	e8 ba f6 ff ff       	call   c010039b <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ce1:	ff 45 f4             	incl   -0xc(%ebp)
c0100ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ce7:	83 f8 02             	cmp    $0x2,%eax
c0100cea:	76 bb                	jbe    c0100ca7 <mon_help+0xf>
    }
    return 0;
c0100cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cf1:	89 ec                	mov    %ebp,%esp
c0100cf3:	5d                   	pop    %ebp
c0100cf4:	c3                   	ret    

c0100cf5 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cf5:	55                   	push   %ebp
c0100cf6:	89 e5                	mov    %esp,%ebp
c0100cf8:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cfb:	e8 be fb ff ff       	call   c01008be <print_kerninfo>
    return 0;
c0100d00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d05:	89 ec                	mov    %ebp,%esp
c0100d07:	5d                   	pop    %ebp
c0100d08:	c3                   	ret    

c0100d09 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d09:	55                   	push   %ebp
c0100d0a:	89 e5                	mov    %esp,%ebp
c0100d0c:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d0f:	e8 f6 fc ff ff       	call   c0100a0a <print_stackframe>
    return 0;
c0100d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d19:	89 ec                	mov    %ebp,%esp
c0100d1b:	5d                   	pop    %ebp
c0100d1c:	c3                   	ret    

c0100d1d <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d1d:	55                   	push   %ebp
c0100d1e:	89 e5                	mov    %esp,%ebp
c0100d20:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d23:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100d28:	85 c0                	test   %eax,%eax
c0100d2a:	75 5b                	jne    c0100d87 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d2c:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100d33:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d36:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d43:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4a:	c7 04 24 fa 66 10 c0 	movl   $0xc01066fa,(%esp)
c0100d51:	e8 45 f6 ff ff       	call   c010039b <cprintf>
    vcprintf(fmt, ap);
c0100d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d60:	89 04 24             	mov    %eax,(%esp)
c0100d63:	e8 fe f5 ff ff       	call   c0100366 <vcprintf>
    cprintf("\n");
c0100d68:	c7 04 24 16 67 10 c0 	movl   $0xc0106716,(%esp)
c0100d6f:	e8 27 f6 ff ff       	call   c010039b <cprintf>
    
    cprintf("stack trackback:\n");
c0100d74:	c7 04 24 18 67 10 c0 	movl   $0xc0106718,(%esp)
c0100d7b:	e8 1b f6 ff ff       	call   c010039b <cprintf>
    print_stackframe();
c0100d80:	e8 85 fc ff ff       	call   c0100a0a <print_stackframe>
c0100d85:	eb 01                	jmp    c0100d88 <__panic+0x6b>
        goto panic_dead;
c0100d87:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d88:	e8 e9 09 00 00       	call   c0101776 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d94:	e8 9d fe ff ff       	call   c0100c36 <kmonitor>
c0100d99:	eb f2                	jmp    c0100d8d <__panic+0x70>

c0100d9b <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d9b:	55                   	push   %ebp
c0100d9c:	89 e5                	mov    %esp,%ebp
c0100d9e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100da1:	8d 45 14             	lea    0x14(%ebp),%eax
c0100da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100da7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100daa:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100dae:	8b 45 08             	mov    0x8(%ebp),%eax
c0100db1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100db5:	c7 04 24 2a 67 10 c0 	movl   $0xc010672a,(%esp)
c0100dbc:	e8 da f5 ff ff       	call   c010039b <cprintf>
    vcprintf(fmt, ap);
c0100dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc8:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dcb:	89 04 24             	mov    %eax,(%esp)
c0100dce:	e8 93 f5 ff ff       	call   c0100366 <vcprintf>
    cprintf("\n");
c0100dd3:	c7 04 24 16 67 10 c0 	movl   $0xc0106716,(%esp)
c0100dda:	e8 bc f5 ff ff       	call   c010039b <cprintf>
    va_end(ap);
}
c0100ddf:	90                   	nop
c0100de0:	89 ec                	mov    %ebp,%esp
c0100de2:	5d                   	pop    %ebp
c0100de3:	c3                   	ret    

c0100de4 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100de4:	55                   	push   %ebp
c0100de5:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100de7:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c0100dec:	5d                   	pop    %ebp
c0100ded:	c3                   	ret    

c0100dee <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dee:	55                   	push   %ebp
c0100def:	89 e5                	mov    %esp,%ebp
c0100df1:	83 ec 28             	sub    $0x28,%esp
c0100df4:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100dfa:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dfe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e02:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e06:	ee                   	out    %al,(%dx)
}
c0100e07:	90                   	nop
c0100e08:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e0e:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e12:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e16:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e1a:	ee                   	out    %al,(%dx)
}
c0100e1b:	90                   	nop
c0100e1c:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e22:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e26:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e2a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e2e:	ee                   	out    %al,(%dx)
}
c0100e2f:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e30:	c7 05 24 c4 11 c0 00 	movl   $0x0,0xc011c424
c0100e37:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e3a:	c7 04 24 48 67 10 c0 	movl   $0xc0106748,(%esp)
c0100e41:	e8 55 f5 ff ff       	call   c010039b <cprintf>
    pic_enable(IRQ_TIMER);
c0100e46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e4d:	e8 89 09 00 00       	call   c01017db <pic_enable>
}
c0100e52:	90                   	nop
c0100e53:	89 ec                	mov    %ebp,%esp
c0100e55:	5d                   	pop    %ebp
c0100e56:	c3                   	ret    

c0100e57 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e57:	55                   	push   %ebp
c0100e58:	89 e5                	mov    %esp,%ebp
c0100e5a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e5d:	9c                   	pushf  
c0100e5e:	58                   	pop    %eax
c0100e5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e65:	25 00 02 00 00       	and    $0x200,%eax
c0100e6a:	85 c0                	test   %eax,%eax
c0100e6c:	74 0c                	je     c0100e7a <__intr_save+0x23>
        intr_disable();
c0100e6e:	e8 03 09 00 00       	call   c0101776 <intr_disable>
        return 1;
c0100e73:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e78:	eb 05                	jmp    c0100e7f <__intr_save+0x28>
    }
    return 0;
c0100e7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e7f:	89 ec                	mov    %ebp,%esp
c0100e81:	5d                   	pop    %ebp
c0100e82:	c3                   	ret    

c0100e83 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e83:	55                   	push   %ebp
c0100e84:	89 e5                	mov    %esp,%ebp
c0100e86:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e8d:	74 05                	je     c0100e94 <__intr_restore+0x11>
        intr_enable();
c0100e8f:	e8 da 08 00 00       	call   c010176e <intr_enable>
    }
}
c0100e94:	90                   	nop
c0100e95:	89 ec                	mov    %ebp,%esp
c0100e97:	5d                   	pop    %ebp
c0100e98:	c3                   	ret    

c0100e99 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e99:	55                   	push   %ebp
c0100e9a:	89 e5                	mov    %esp,%ebp
c0100e9c:	83 ec 10             	sub    $0x10,%esp
c0100e9f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ea5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ea9:	89 c2                	mov    %eax,%edx
c0100eab:	ec                   	in     (%dx),%al
c0100eac:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100eaf:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100eb5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100eb9:	89 c2                	mov    %eax,%edx
c0100ebb:	ec                   	in     (%dx),%al
c0100ebc:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100ebf:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ec5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ec9:	89 c2                	mov    %eax,%edx
c0100ecb:	ec                   	in     (%dx),%al
c0100ecc:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100ecf:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ed5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ed9:	89 c2                	mov    %eax,%edx
c0100edb:	ec                   	in     (%dx),%al
c0100edc:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100edf:	90                   	nop
c0100ee0:	89 ec                	mov    %ebp,%esp
c0100ee2:	5d                   	pop    %ebp
c0100ee3:	c3                   	ret    

c0100ee4 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ee4:	55                   	push   %ebp
c0100ee5:	89 e5                	mov    %esp,%ebp
c0100ee7:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100eea:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ef1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef4:	0f b7 00             	movzwl (%eax),%eax
c0100ef7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100efe:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f03:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f06:	0f b7 00             	movzwl (%eax),%eax
c0100f09:	0f b7 c0             	movzwl %ax,%eax
c0100f0c:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f11:	74 12                	je     c0100f25 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f13:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f1a:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100f21:	b4 03 
c0100f23:	eb 13                	jmp    c0100f38 <cga_init+0x54>
    } else {
        *cp = was;
c0100f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f28:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f2c:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f2f:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100f36:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f38:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f3f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f43:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f47:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f4b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f4f:	ee                   	out    %al,(%dx)
}
c0100f50:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f51:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f58:	40                   	inc    %eax
c0100f59:	0f b7 c0             	movzwl %ax,%eax
c0100f5c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f60:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f64:	89 c2                	mov    %eax,%edx
c0100f66:	ec                   	in     (%dx),%al
c0100f67:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f6a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f6e:	0f b6 c0             	movzbl %al,%eax
c0100f71:	c1 e0 08             	shl    $0x8,%eax
c0100f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f77:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f7e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f82:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f86:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f8a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f8e:	ee                   	out    %al,(%dx)
}
c0100f8f:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f90:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f97:	40                   	inc    %eax
c0100f98:	0f b7 c0             	movzwl %ax,%eax
c0100f9b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f9f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fa3:	89 c2                	mov    %eax,%edx
c0100fa5:	ec                   	in     (%dx),%al
c0100fa6:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fa9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fad:	0f b6 c0             	movzbl %al,%eax
c0100fb0:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fb6:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fbe:	0f b7 c0             	movzwl %ax,%eax
c0100fc1:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100fc7:	90                   	nop
c0100fc8:	89 ec                	mov    %ebp,%esp
c0100fca:	5d                   	pop    %ebp
c0100fcb:	c3                   	ret    

c0100fcc <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fcc:	55                   	push   %ebp
c0100fcd:	89 e5                	mov    %esp,%ebp
c0100fcf:	83 ec 48             	sub    $0x48,%esp
c0100fd2:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fd8:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fdc:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fe0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
}
c0100fe5:	90                   	nop
c0100fe6:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fec:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100ff4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100ff8:	ee                   	out    %al,(%dx)
}
c0100ff9:	90                   	nop
c0100ffa:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101000:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101004:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101008:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010100c:	ee                   	out    %al,(%dx)
}
c010100d:	90                   	nop
c010100e:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101014:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101018:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010101c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101020:	ee                   	out    %al,(%dx)
}
c0101021:	90                   	nop
c0101022:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101028:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010102c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101030:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101034:	ee                   	out    %al,(%dx)
}
c0101035:	90                   	nop
c0101036:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010103c:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101040:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101044:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101048:	ee                   	out    %al,(%dx)
}
c0101049:	90                   	nop
c010104a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101050:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101054:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101058:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010105c:	ee                   	out    %al,(%dx)
}
c010105d:	90                   	nop
c010105e:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101064:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101068:	89 c2                	mov    %eax,%edx
c010106a:	ec                   	in     (%dx),%al
c010106b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010106e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101072:	3c ff                	cmp    $0xff,%al
c0101074:	0f 95 c0             	setne  %al
c0101077:	0f b6 c0             	movzbl %al,%eax
c010107a:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c010107f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101085:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101089:	89 c2                	mov    %eax,%edx
c010108b:	ec                   	in     (%dx),%al
c010108c:	88 45 f1             	mov    %al,-0xf(%ebp)
c010108f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101095:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101099:	89 c2                	mov    %eax,%edx
c010109b:	ec                   	in     (%dx),%al
c010109c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010109f:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01010a4:	85 c0                	test   %eax,%eax
c01010a6:	74 0c                	je     c01010b4 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c01010a8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010af:	e8 27 07 00 00       	call   c01017db <pic_enable>
    }
}
c01010b4:	90                   	nop
c01010b5:	89 ec                	mov    %ebp,%esp
c01010b7:	5d                   	pop    %ebp
c01010b8:	c3                   	ret    

c01010b9 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010b9:	55                   	push   %ebp
c01010ba:	89 e5                	mov    %esp,%ebp
c01010bc:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010c6:	eb 08                	jmp    c01010d0 <lpt_putc_sub+0x17>
        delay();
c01010c8:	e8 cc fd ff ff       	call   c0100e99 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010cd:	ff 45 fc             	incl   -0x4(%ebp)
c01010d0:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010da:	89 c2                	mov    %eax,%edx
c01010dc:	ec                   	in     (%dx),%al
c01010dd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010e0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010e4:	84 c0                	test   %al,%al
c01010e6:	78 09                	js     c01010f1 <lpt_putc_sub+0x38>
c01010e8:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010ef:	7e d7                	jle    c01010c8 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f4:	0f b6 c0             	movzbl %al,%eax
c01010f7:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010fd:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101100:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101104:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101108:	ee                   	out    %al,(%dx)
}
c0101109:	90                   	nop
c010110a:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101110:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101114:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101118:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010111c:	ee                   	out    %al,(%dx)
}
c010111d:	90                   	nop
c010111e:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101124:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101128:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010112c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101130:	ee                   	out    %al,(%dx)
}
c0101131:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101132:	90                   	nop
c0101133:	89 ec                	mov    %ebp,%esp
c0101135:	5d                   	pop    %ebp
c0101136:	c3                   	ret    

c0101137 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101137:	55                   	push   %ebp
c0101138:	89 e5                	mov    %esp,%ebp
c010113a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010113d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101141:	74 0d                	je     c0101150 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101143:	8b 45 08             	mov    0x8(%ebp),%eax
c0101146:	89 04 24             	mov    %eax,(%esp)
c0101149:	e8 6b ff ff ff       	call   c01010b9 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010114e:	eb 24                	jmp    c0101174 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101150:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101157:	e8 5d ff ff ff       	call   c01010b9 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010115c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101163:	e8 51 ff ff ff       	call   c01010b9 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101168:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010116f:	e8 45 ff ff ff       	call   c01010b9 <lpt_putc_sub>
}
c0101174:	90                   	nop
c0101175:	89 ec                	mov    %ebp,%esp
c0101177:	5d                   	pop    %ebp
c0101178:	c3                   	ret    

c0101179 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101179:	55                   	push   %ebp
c010117a:	89 e5                	mov    %esp,%ebp
c010117c:	83 ec 38             	sub    $0x38,%esp
c010117f:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101182:	8b 45 08             	mov    0x8(%ebp),%eax
c0101185:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010118a:	85 c0                	test   %eax,%eax
c010118c:	75 07                	jne    c0101195 <cga_putc+0x1c>
        c |= 0x0700;
c010118e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101195:	8b 45 08             	mov    0x8(%ebp),%eax
c0101198:	0f b6 c0             	movzbl %al,%eax
c010119b:	83 f8 0d             	cmp    $0xd,%eax
c010119e:	74 72                	je     c0101212 <cga_putc+0x99>
c01011a0:	83 f8 0d             	cmp    $0xd,%eax
c01011a3:	0f 8f a3 00 00 00    	jg     c010124c <cga_putc+0xd3>
c01011a9:	83 f8 08             	cmp    $0x8,%eax
c01011ac:	74 0a                	je     c01011b8 <cga_putc+0x3f>
c01011ae:	83 f8 0a             	cmp    $0xa,%eax
c01011b1:	74 4c                	je     c01011ff <cga_putc+0x86>
c01011b3:	e9 94 00 00 00       	jmp    c010124c <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c01011b8:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011bf:	85 c0                	test   %eax,%eax
c01011c1:	0f 84 af 00 00 00    	je     c0101276 <cga_putc+0xfd>
            crt_pos --;
c01011c7:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011ce:	48                   	dec    %eax
c01011cf:	0f b7 c0             	movzwl %ax,%eax
c01011d2:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01011db:	98                   	cwtl   
c01011dc:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011e1:	98                   	cwtl   
c01011e2:	83 c8 20             	or     $0x20,%eax
c01011e5:	98                   	cwtl   
c01011e6:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c01011ec:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c01011f3:	01 d2                	add    %edx,%edx
c01011f5:	01 ca                	add    %ecx,%edx
c01011f7:	0f b7 c0             	movzwl %ax,%eax
c01011fa:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011fd:	eb 77                	jmp    c0101276 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011ff:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101206:	83 c0 50             	add    $0x50,%eax
c0101209:	0f b7 c0             	movzwl %ax,%eax
c010120c:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101212:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c0101219:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c0101220:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101225:	89 c8                	mov    %ecx,%eax
c0101227:	f7 e2                	mul    %edx
c0101229:	c1 ea 06             	shr    $0x6,%edx
c010122c:	89 d0                	mov    %edx,%eax
c010122e:	c1 e0 02             	shl    $0x2,%eax
c0101231:	01 d0                	add    %edx,%eax
c0101233:	c1 e0 04             	shl    $0x4,%eax
c0101236:	29 c1                	sub    %eax,%ecx
c0101238:	89 ca                	mov    %ecx,%edx
c010123a:	0f b7 d2             	movzwl %dx,%edx
c010123d:	89 d8                	mov    %ebx,%eax
c010123f:	29 d0                	sub    %edx,%eax
c0101241:	0f b7 c0             	movzwl %ax,%eax
c0101244:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c010124a:	eb 2b                	jmp    c0101277 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010124c:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c0101252:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101259:	8d 50 01             	lea    0x1(%eax),%edx
c010125c:	0f b7 d2             	movzwl %dx,%edx
c010125f:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c0101266:	01 c0                	add    %eax,%eax
c0101268:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010126b:	8b 45 08             	mov    0x8(%ebp),%eax
c010126e:	0f b7 c0             	movzwl %ax,%eax
c0101271:	66 89 02             	mov    %ax,(%edx)
        break;
c0101274:	eb 01                	jmp    c0101277 <cga_putc+0xfe>
        break;
c0101276:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101277:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010127e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101283:	76 5e                	jbe    c01012e3 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101285:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010128a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101290:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101295:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010129c:	00 
c010129d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012a1:	89 04 24             	mov    %eax,(%esp)
c01012a4:	e8 25 50 00 00       	call   c01062ce <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012a9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012b0:	eb 15                	jmp    c01012c7 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c01012b2:	8b 15 40 c4 11 c0    	mov    0xc011c440,%edx
c01012b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012bb:	01 c0                	add    %eax,%eax
c01012bd:	01 d0                	add    %edx,%eax
c01012bf:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012c4:	ff 45 f4             	incl   -0xc(%ebp)
c01012c7:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012ce:	7e e2                	jle    c01012b2 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012d0:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012d7:	83 e8 50             	sub    $0x50,%eax
c01012da:	0f b7 c0             	movzwl %ax,%eax
c01012dd:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012e3:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01012ea:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012ee:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012f2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012f6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012fa:	ee                   	out    %al,(%dx)
}
c01012fb:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012fc:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101303:	c1 e8 08             	shr    $0x8,%eax
c0101306:	0f b7 c0             	movzwl %ax,%eax
c0101309:	0f b6 c0             	movzbl %al,%eax
c010130c:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101313:	42                   	inc    %edx
c0101314:	0f b7 d2             	movzwl %dx,%edx
c0101317:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010131b:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101322:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101326:	ee                   	out    %al,(%dx)
}
c0101327:	90                   	nop
    outb(addr_6845, 15);
c0101328:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c010132f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101333:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101337:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010133b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010133f:	ee                   	out    %al,(%dx)
}
c0101340:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101341:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101348:	0f b6 c0             	movzbl %al,%eax
c010134b:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101352:	42                   	inc    %edx
c0101353:	0f b7 d2             	movzwl %dx,%edx
c0101356:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010135a:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010135d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101361:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101365:	ee                   	out    %al,(%dx)
}
c0101366:	90                   	nop
}
c0101367:	90                   	nop
c0101368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010136b:	89 ec                	mov    %ebp,%esp
c010136d:	5d                   	pop    %ebp
c010136e:	c3                   	ret    

c010136f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010136f:	55                   	push   %ebp
c0101370:	89 e5                	mov    %esp,%ebp
c0101372:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101375:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010137c:	eb 08                	jmp    c0101386 <serial_putc_sub+0x17>
        delay();
c010137e:	e8 16 fb ff ff       	call   c0100e99 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101383:	ff 45 fc             	incl   -0x4(%ebp)
c0101386:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010138c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101390:	89 c2                	mov    %eax,%edx
c0101392:	ec                   	in     (%dx),%al
c0101393:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101396:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010139a:	0f b6 c0             	movzbl %al,%eax
c010139d:	83 e0 20             	and    $0x20,%eax
c01013a0:	85 c0                	test   %eax,%eax
c01013a2:	75 09                	jne    c01013ad <serial_putc_sub+0x3e>
c01013a4:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013ab:	7e d1                	jle    c010137e <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c01013ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b0:	0f b6 c0             	movzbl %al,%eax
c01013b3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013b9:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013bc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013c0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013c4:	ee                   	out    %al,(%dx)
}
c01013c5:	90                   	nop
}
c01013c6:	90                   	nop
c01013c7:	89 ec                	mov    %ebp,%esp
c01013c9:	5d                   	pop    %ebp
c01013ca:	c3                   	ret    

c01013cb <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013cb:	55                   	push   %ebp
c01013cc:	89 e5                	mov    %esp,%ebp
c01013ce:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013d1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013d5:	74 0d                	je     c01013e4 <serial_putc+0x19>
        serial_putc_sub(c);
c01013d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01013da:	89 04 24             	mov    %eax,(%esp)
c01013dd:	e8 8d ff ff ff       	call   c010136f <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013e2:	eb 24                	jmp    c0101408 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013eb:	e8 7f ff ff ff       	call   c010136f <serial_putc_sub>
        serial_putc_sub(' ');
c01013f0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013f7:	e8 73 ff ff ff       	call   c010136f <serial_putc_sub>
        serial_putc_sub('\b');
c01013fc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101403:	e8 67 ff ff ff       	call   c010136f <serial_putc_sub>
}
c0101408:	90                   	nop
c0101409:	89 ec                	mov    %ebp,%esp
c010140b:	5d                   	pop    %ebp
c010140c:	c3                   	ret    

c010140d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010140d:	55                   	push   %ebp
c010140e:	89 e5                	mov    %esp,%ebp
c0101410:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101413:	eb 33                	jmp    c0101448 <cons_intr+0x3b>
        if (c != 0) {
c0101415:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101419:	74 2d                	je     c0101448 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010141b:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101420:	8d 50 01             	lea    0x1(%eax),%edx
c0101423:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c0101429:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010142c:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101432:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101437:	3d 00 02 00 00       	cmp    $0x200,%eax
c010143c:	75 0a                	jne    c0101448 <cons_intr+0x3b>
                cons.wpos = 0;
c010143e:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c0101445:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101448:	8b 45 08             	mov    0x8(%ebp),%eax
c010144b:	ff d0                	call   *%eax
c010144d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101450:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101454:	75 bf                	jne    c0101415 <cons_intr+0x8>
            }
        }
    }
}
c0101456:	90                   	nop
c0101457:	90                   	nop
c0101458:	89 ec                	mov    %ebp,%esp
c010145a:	5d                   	pop    %ebp
c010145b:	c3                   	ret    

c010145c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010145c:	55                   	push   %ebp
c010145d:	89 e5                	mov    %esp,%ebp
c010145f:	83 ec 10             	sub    $0x10,%esp
c0101462:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101468:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010146c:	89 c2                	mov    %eax,%edx
c010146e:	ec                   	in     (%dx),%al
c010146f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101472:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101476:	0f b6 c0             	movzbl %al,%eax
c0101479:	83 e0 01             	and    $0x1,%eax
c010147c:	85 c0                	test   %eax,%eax
c010147e:	75 07                	jne    c0101487 <serial_proc_data+0x2b>
        return -1;
c0101480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101485:	eb 2a                	jmp    c01014b1 <serial_proc_data+0x55>
c0101487:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010148d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101491:	89 c2                	mov    %eax,%edx
c0101493:	ec                   	in     (%dx),%al
c0101494:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101497:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010149b:	0f b6 c0             	movzbl %al,%eax
c010149e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014a1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014a5:	75 07                	jne    c01014ae <serial_proc_data+0x52>
        c = '\b';
c01014a7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014b1:	89 ec                	mov    %ebp,%esp
c01014b3:	5d                   	pop    %ebp
c01014b4:	c3                   	ret    

c01014b5 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014b5:	55                   	push   %ebp
c01014b6:	89 e5                	mov    %esp,%ebp
c01014b8:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014bb:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01014c0:	85 c0                	test   %eax,%eax
c01014c2:	74 0c                	je     c01014d0 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014c4:	c7 04 24 5c 14 10 c0 	movl   $0xc010145c,(%esp)
c01014cb:	e8 3d ff ff ff       	call   c010140d <cons_intr>
    }
}
c01014d0:	90                   	nop
c01014d1:	89 ec                	mov    %ebp,%esp
c01014d3:	5d                   	pop    %ebp
c01014d4:	c3                   	ret    

c01014d5 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014d5:	55                   	push   %ebp
c01014d6:	89 e5                	mov    %esp,%ebp
c01014d8:	83 ec 38             	sub    $0x38,%esp
c01014db:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014e4:	89 c2                	mov    %eax,%edx
c01014e6:	ec                   	in     (%dx),%al
c01014e7:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014ee:	0f b6 c0             	movzbl %al,%eax
c01014f1:	83 e0 01             	and    $0x1,%eax
c01014f4:	85 c0                	test   %eax,%eax
c01014f6:	75 0a                	jne    c0101502 <kbd_proc_data+0x2d>
        return -1;
c01014f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014fd:	e9 56 01 00 00       	jmp    c0101658 <kbd_proc_data+0x183>
c0101502:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010150b:	89 c2                	mov    %eax,%edx
c010150d:	ec                   	in     (%dx),%al
c010150e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101511:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101515:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101518:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010151c:	75 17                	jne    c0101535 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010151e:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101523:	83 c8 40             	or     $0x40,%eax
c0101526:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c010152b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101530:	e9 23 01 00 00       	jmp    c0101658 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101539:	84 c0                	test   %al,%al
c010153b:	79 45                	jns    c0101582 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010153d:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101542:	83 e0 40             	and    $0x40,%eax
c0101545:	85 c0                	test   %eax,%eax
c0101547:	75 08                	jne    c0101551 <kbd_proc_data+0x7c>
c0101549:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010154d:	24 7f                	and    $0x7f,%al
c010154f:	eb 04                	jmp    c0101555 <kbd_proc_data+0x80>
c0101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101555:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101558:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155c:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101563:	0c 40                	or     $0x40,%al
c0101565:	0f b6 c0             	movzbl %al,%eax
c0101568:	f7 d0                	not    %eax
c010156a:	89 c2                	mov    %eax,%edx
c010156c:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101571:	21 d0                	and    %edx,%eax
c0101573:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c0101578:	b8 00 00 00 00       	mov    $0x0,%eax
c010157d:	e9 d6 00 00 00       	jmp    c0101658 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101582:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101587:	83 e0 40             	and    $0x40,%eax
c010158a:	85 c0                	test   %eax,%eax
c010158c:	74 11                	je     c010159f <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010158e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101592:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101597:	83 e0 bf             	and    $0xffffffbf,%eax
c010159a:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c010159f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015a3:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c01015aa:	0f b6 d0             	movzbl %al,%edx
c01015ad:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015b2:	09 d0                	or     %edx,%eax
c01015b4:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c01015b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015bd:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c01015c4:	0f b6 d0             	movzbl %al,%edx
c01015c7:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015cc:	31 d0                	xor    %edx,%eax
c01015ce:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015d3:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015d8:	83 e0 03             	and    $0x3,%eax
c01015db:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c01015e2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015e6:	01 d0                	add    %edx,%eax
c01015e8:	0f b6 00             	movzbl (%eax),%eax
c01015eb:	0f b6 c0             	movzbl %al,%eax
c01015ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015f1:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015f6:	83 e0 08             	and    $0x8,%eax
c01015f9:	85 c0                	test   %eax,%eax
c01015fb:	74 22                	je     c010161f <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015fd:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101601:	7e 0c                	jle    c010160f <kbd_proc_data+0x13a>
c0101603:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101607:	7f 06                	jg     c010160f <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101609:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010160d:	eb 10                	jmp    c010161f <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c010160f:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101613:	7e 0a                	jle    c010161f <kbd_proc_data+0x14a>
c0101615:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101619:	7f 04                	jg     c010161f <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010161b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010161f:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101624:	f7 d0                	not    %eax
c0101626:	83 e0 06             	and    $0x6,%eax
c0101629:	85 c0                	test   %eax,%eax
c010162b:	75 28                	jne    c0101655 <kbd_proc_data+0x180>
c010162d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101634:	75 1f                	jne    c0101655 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101636:	c7 04 24 63 67 10 c0 	movl   $0xc0106763,(%esp)
c010163d:	e8 59 ed ff ff       	call   c010039b <cprintf>
c0101642:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101648:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010164c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101650:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101653:	ee                   	out    %al,(%dx)
}
c0101654:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101655:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101658:	89 ec                	mov    %ebp,%esp
c010165a:	5d                   	pop    %ebp
c010165b:	c3                   	ret    

c010165c <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010165c:	55                   	push   %ebp
c010165d:	89 e5                	mov    %esp,%ebp
c010165f:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101662:	c7 04 24 d5 14 10 c0 	movl   $0xc01014d5,(%esp)
c0101669:	e8 9f fd ff ff       	call   c010140d <cons_intr>
}
c010166e:	90                   	nop
c010166f:	89 ec                	mov    %ebp,%esp
c0101671:	5d                   	pop    %ebp
c0101672:	c3                   	ret    

c0101673 <kbd_init>:

static void
kbd_init(void) {
c0101673:	55                   	push   %ebp
c0101674:	89 e5                	mov    %esp,%ebp
c0101676:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101679:	e8 de ff ff ff       	call   c010165c <kbd_intr>
    pic_enable(IRQ_KBD);
c010167e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101685:	e8 51 01 00 00       	call   c01017db <pic_enable>
}
c010168a:	90                   	nop
c010168b:	89 ec                	mov    %ebp,%esp
c010168d:	5d                   	pop    %ebp
c010168e:	c3                   	ret    

c010168f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010168f:	55                   	push   %ebp
c0101690:	89 e5                	mov    %esp,%ebp
c0101692:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101695:	e8 4a f8 ff ff       	call   c0100ee4 <cga_init>
    serial_init();
c010169a:	e8 2d f9 ff ff       	call   c0100fcc <serial_init>
    kbd_init();
c010169f:	e8 cf ff ff ff       	call   c0101673 <kbd_init>
    if (!serial_exists) {
c01016a4:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01016a9:	85 c0                	test   %eax,%eax
c01016ab:	75 0c                	jne    c01016b9 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016ad:	c7 04 24 6f 67 10 c0 	movl   $0xc010676f,(%esp)
c01016b4:	e8 e2 ec ff ff       	call   c010039b <cprintf>
    }
}
c01016b9:	90                   	nop
c01016ba:	89 ec                	mov    %ebp,%esp
c01016bc:	5d                   	pop    %ebp
c01016bd:	c3                   	ret    

c01016be <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016be:	55                   	push   %ebp
c01016bf:	89 e5                	mov    %esp,%ebp
c01016c1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016c4:	e8 8e f7 ff ff       	call   c0100e57 <__intr_save>
c01016c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01016cf:	89 04 24             	mov    %eax,(%esp)
c01016d2:	e8 60 fa ff ff       	call   c0101137 <lpt_putc>
        cga_putc(c);
c01016d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01016da:	89 04 24             	mov    %eax,(%esp)
c01016dd:	e8 97 fa ff ff       	call   c0101179 <cga_putc>
        serial_putc(c);
c01016e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e5:	89 04 24             	mov    %eax,(%esp)
c01016e8:	e8 de fc ff ff       	call   c01013cb <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016f0:	89 04 24             	mov    %eax,(%esp)
c01016f3:	e8 8b f7 ff ff       	call   c0100e83 <__intr_restore>
}
c01016f8:	90                   	nop
c01016f9:	89 ec                	mov    %ebp,%esp
c01016fb:	5d                   	pop    %ebp
c01016fc:	c3                   	ret    

c01016fd <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016fd:	55                   	push   %ebp
c01016fe:	89 e5                	mov    %esp,%ebp
c0101700:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010170a:	e8 48 f7 ff ff       	call   c0100e57 <__intr_save>
c010170f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101712:	e8 9e fd ff ff       	call   c01014b5 <serial_intr>
        kbd_intr();
c0101717:	e8 40 ff ff ff       	call   c010165c <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010171c:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c0101722:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101727:	39 c2                	cmp    %eax,%edx
c0101729:	74 31                	je     c010175c <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010172b:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101730:	8d 50 01             	lea    0x1(%eax),%edx
c0101733:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c0101739:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c0101740:	0f b6 c0             	movzbl %al,%eax
c0101743:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101746:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c010174b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101750:	75 0a                	jne    c010175c <cons_getc+0x5f>
                cons.rpos = 0;
c0101752:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c0101759:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010175f:	89 04 24             	mov    %eax,(%esp)
c0101762:	e8 1c f7 ff ff       	call   c0100e83 <__intr_restore>
    return c;
c0101767:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010176a:	89 ec                	mov    %ebp,%esp
c010176c:	5d                   	pop    %ebp
c010176d:	c3                   	ret    

c010176e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010176e:	55                   	push   %ebp
c010176f:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101771:	fb                   	sti    
}
c0101772:	90                   	nop
    sti();
}
c0101773:	90                   	nop
c0101774:	5d                   	pop    %ebp
c0101775:	c3                   	ret    

c0101776 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101776:	55                   	push   %ebp
c0101777:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101779:	fa                   	cli    
}
c010177a:	90                   	nop
    cli();
}
c010177b:	90                   	nop
c010177c:	5d                   	pop    %ebp
c010177d:	c3                   	ret    

c010177e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010177e:	55                   	push   %ebp
c010177f:	89 e5                	mov    %esp,%ebp
c0101781:	83 ec 14             	sub    $0x14,%esp
c0101784:	8b 45 08             	mov    0x8(%ebp),%eax
c0101787:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010178b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010178e:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c0101794:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c0101799:	85 c0                	test   %eax,%eax
c010179b:	74 39                	je     c01017d6 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c010179d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017a0:	0f b6 c0             	movzbl %al,%eax
c01017a3:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01017a9:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ac:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017b0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017b4:	ee                   	out    %al,(%dx)
}
c01017b5:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01017b6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017ba:	c1 e8 08             	shr    $0x8,%eax
c01017bd:	0f b7 c0             	movzwl %ax,%eax
c01017c0:	0f b6 c0             	movzbl %al,%eax
c01017c3:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01017c9:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017cc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01017d0:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01017d4:	ee                   	out    %al,(%dx)
}
c01017d5:	90                   	nop
    }
}
c01017d6:	90                   	nop
c01017d7:	89 ec                	mov    %ebp,%esp
c01017d9:	5d                   	pop    %ebp
c01017da:	c3                   	ret    

c01017db <pic_enable>:

void
pic_enable(unsigned int irq) {
c01017db:	55                   	push   %ebp
c01017dc:	89 e5                	mov    %esp,%ebp
c01017de:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01017e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01017e4:	ba 01 00 00 00       	mov    $0x1,%edx
c01017e9:	88 c1                	mov    %al,%cl
c01017eb:	d3 e2                	shl    %cl,%edx
c01017ed:	89 d0                	mov    %edx,%eax
c01017ef:	98                   	cwtl   
c01017f0:	f7 d0                	not    %eax
c01017f2:	0f bf d0             	movswl %ax,%edx
c01017f5:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c01017fc:	98                   	cwtl   
c01017fd:	21 d0                	and    %edx,%eax
c01017ff:	98                   	cwtl   
c0101800:	0f b7 c0             	movzwl %ax,%eax
c0101803:	89 04 24             	mov    %eax,(%esp)
c0101806:	e8 73 ff ff ff       	call   c010177e <pic_setmask>
}
c010180b:	90                   	nop
c010180c:	89 ec                	mov    %ebp,%esp
c010180e:	5d                   	pop    %ebp
c010180f:	c3                   	ret    

c0101810 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101810:	55                   	push   %ebp
c0101811:	89 e5                	mov    %esp,%ebp
c0101813:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101816:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c010181d:	00 00 00 
c0101820:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101826:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010182a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010182e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
}
c0101833:	90                   	nop
c0101834:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010183a:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010183e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101842:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101846:	ee                   	out    %al,(%dx)
}
c0101847:	90                   	nop
c0101848:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010184e:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101852:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101856:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010185a:	ee                   	out    %al,(%dx)
}
c010185b:	90                   	nop
c010185c:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101862:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101866:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010186a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010186e:	ee                   	out    %al,(%dx)
}
c010186f:	90                   	nop
c0101870:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101876:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010187a:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010187e:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101882:	ee                   	out    %al,(%dx)
}
c0101883:	90                   	nop
c0101884:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010188a:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010188e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101892:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101896:	ee                   	out    %al,(%dx)
}
c0101897:	90                   	nop
c0101898:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c010189e:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018a2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01018a6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01018aa:	ee                   	out    %al,(%dx)
}
c01018ab:	90                   	nop
c01018ac:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01018b2:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018ba:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018be:	ee                   	out    %al,(%dx)
}
c01018bf:	90                   	nop
c01018c0:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01018c6:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ca:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018ce:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018d2:	ee                   	out    %al,(%dx)
}
c01018d3:	90                   	nop
c01018d4:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01018da:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018de:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018e2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018e6:	ee                   	out    %al,(%dx)
}
c01018e7:	90                   	nop
c01018e8:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018ee:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018f2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018f6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018fa:	ee                   	out    %al,(%dx)
}
c01018fb:	90                   	nop
c01018fc:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101902:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101906:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010190a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010190e:	ee                   	out    %al,(%dx)
}
c010190f:	90                   	nop
c0101910:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101916:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010191a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010191e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101922:	ee                   	out    %al,(%dx)
}
c0101923:	90                   	nop
c0101924:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010192a:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010192e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101932:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101936:	ee                   	out    %al,(%dx)
}
c0101937:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101938:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010193f:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101944:	74 0f                	je     c0101955 <pic_init+0x145>
        pic_setmask(irq_mask);
c0101946:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010194d:	89 04 24             	mov    %eax,(%esp)
c0101950:	e8 29 fe ff ff       	call   c010177e <pic_setmask>
    }
}
c0101955:	90                   	nop
c0101956:	89 ec                	mov    %ebp,%esp
c0101958:	5d                   	pop    %ebp
c0101959:	c3                   	ret    

c010195a <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010195a:	55                   	push   %ebp
c010195b:	89 e5                	mov    %esp,%ebp
c010195d:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101960:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101967:	00 
c0101968:	c7 04 24 a0 67 10 c0 	movl   $0xc01067a0,(%esp)
c010196f:	e8 27 ea ff ff       	call   c010039b <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0101974:	c7 04 24 aa 67 10 c0 	movl   $0xc01067aa,(%esp)
c010197b:	e8 1b ea ff ff       	call   c010039b <cprintf>
    panic("EOT: kernel seems ok.");
c0101980:	c7 44 24 08 b8 67 10 	movl   $0xc01067b8,0x8(%esp)
c0101987:	c0 
c0101988:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010198f:	00 
c0101990:	c7 04 24 ce 67 10 c0 	movl   $0xc01067ce,(%esp)
c0101997:	e8 81 f3 ff ff       	call   c0100d1d <__panic>

c010199c <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010199c:	55                   	push   %ebp
c010199d:	89 e5                	mov    %esp,%ebp
c010199f:	83 ec 10             	sub    $0x10,%esp
      */
      extern uintptr_t __vectors[];

    //all gate DPL=0, so use DPL_KERNEL 
    int i;
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c01019a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019a9:	e9 c4 00 00 00       	jmp    c0101a72 <idt_init+0xd6>
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c01019ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b1:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c01019b8:	0f b7 d0             	movzwl %ax,%edx
c01019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019be:	66 89 14 c5 e0 c6 11 	mov    %dx,-0x3fee3920(,%eax,8)
c01019c5:	c0 
c01019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019c9:	66 c7 04 c5 e2 c6 11 	movw   $0x8,-0x3fee391e(,%eax,8)
c01019d0:	c0 08 00 
c01019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d6:	0f b6 14 c5 e4 c6 11 	movzbl -0x3fee391c(,%eax,8),%edx
c01019dd:	c0 
c01019de:	80 e2 e0             	and    $0xe0,%dl
c01019e1:	88 14 c5 e4 c6 11 c0 	mov    %dl,-0x3fee391c(,%eax,8)
c01019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019eb:	0f b6 14 c5 e4 c6 11 	movzbl -0x3fee391c(,%eax,8),%edx
c01019f2:	c0 
c01019f3:	80 e2 1f             	and    $0x1f,%dl
c01019f6:	88 14 c5 e4 c6 11 c0 	mov    %dl,-0x3fee391c(,%eax,8)
c01019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a00:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c0101a07:	c0 
c0101a08:	80 e2 f0             	and    $0xf0,%dl
c0101a0b:	80 ca 0e             	or     $0xe,%dl
c0101a0e:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a18:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c0101a1f:	c0 
c0101a20:	80 e2 ef             	and    $0xef,%dl
c0101a23:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a2d:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c0101a34:	c0 
c0101a35:	80 e2 9f             	and    $0x9f,%dl
c0101a38:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a42:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c0101a49:	c0 
c0101a4a:	80 ca 80             	or     $0x80,%dl
c0101a4d:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a57:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101a5e:	c1 e8 10             	shr    $0x10,%eax
c0101a61:	0f b7 d0             	movzwl %ax,%edx
c0101a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a67:	66 89 14 c5 e6 c6 11 	mov    %dx,-0x3fee391a(,%eax,8)
c0101a6e:	c0 
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c0101a6f:	ff 45 fc             	incl   -0x4(%ebp)
c0101a72:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a75:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a7a:	0f 86 2e ff ff ff    	jbe    c01019ae <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL],1,KERNEL_CS,__vectors[T_SYSCALL],DPL_USER);
c0101a80:	a1 e0 97 11 c0       	mov    0xc01197e0,%eax
c0101a85:	0f b7 c0             	movzwl %ax,%eax
c0101a88:	66 a3 e0 ca 11 c0    	mov    %ax,0xc011cae0
c0101a8e:	66 c7 05 e2 ca 11 c0 	movw   $0x8,0xc011cae2
c0101a95:	08 00 
c0101a97:	0f b6 05 e4 ca 11 c0 	movzbl 0xc011cae4,%eax
c0101a9e:	24 e0                	and    $0xe0,%al
c0101aa0:	a2 e4 ca 11 c0       	mov    %al,0xc011cae4
c0101aa5:	0f b6 05 e4 ca 11 c0 	movzbl 0xc011cae4,%eax
c0101aac:	24 1f                	and    $0x1f,%al
c0101aae:	a2 e4 ca 11 c0       	mov    %al,0xc011cae4
c0101ab3:	0f b6 05 e5 ca 11 c0 	movzbl 0xc011cae5,%eax
c0101aba:	0c 0f                	or     $0xf,%al
c0101abc:	a2 e5 ca 11 c0       	mov    %al,0xc011cae5
c0101ac1:	0f b6 05 e5 ca 11 c0 	movzbl 0xc011cae5,%eax
c0101ac8:	24 ef                	and    $0xef,%al
c0101aca:	a2 e5 ca 11 c0       	mov    %al,0xc011cae5
c0101acf:	0f b6 05 e5 ca 11 c0 	movzbl 0xc011cae5,%eax
c0101ad6:	0c 60                	or     $0x60,%al
c0101ad8:	a2 e5 ca 11 c0       	mov    %al,0xc011cae5
c0101add:	0f b6 05 e5 ca 11 c0 	movzbl 0xc011cae5,%eax
c0101ae4:	0c 80                	or     $0x80,%al
c0101ae6:	a2 e5 ca 11 c0       	mov    %al,0xc011cae5
c0101aeb:	a1 e0 97 11 c0       	mov    0xc01197e0,%eax
c0101af0:	c1 e8 10             	shr    $0x10,%eax
c0101af3:	0f b7 c0             	movzwl %ax,%eax
c0101af6:	66 a3 e6 ca 11 c0    	mov    %ax,0xc011cae6
    SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
c0101afc:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101b01:	0f b7 c0             	movzwl %ax,%eax
c0101b04:	66 a3 a8 ca 11 c0    	mov    %ax,0xc011caa8
c0101b0a:	66 c7 05 aa ca 11 c0 	movw   $0x8,0xc011caaa
c0101b11:	08 00 
c0101b13:	0f b6 05 ac ca 11 c0 	movzbl 0xc011caac,%eax
c0101b1a:	24 e0                	and    $0xe0,%al
c0101b1c:	a2 ac ca 11 c0       	mov    %al,0xc011caac
c0101b21:	0f b6 05 ac ca 11 c0 	movzbl 0xc011caac,%eax
c0101b28:	24 1f                	and    $0x1f,%al
c0101b2a:	a2 ac ca 11 c0       	mov    %al,0xc011caac
c0101b2f:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101b36:	24 f0                	and    $0xf0,%al
c0101b38:	0c 0e                	or     $0xe,%al
c0101b3a:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101b3f:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101b46:	24 ef                	and    $0xef,%al
c0101b48:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101b4d:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101b54:	0c 60                	or     $0x60,%al
c0101b56:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101b5b:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101b62:	0c 80                	or     $0x80,%al
c0101b64:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101b69:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101b6e:	c1 e8 10             	shr    $0x10,%eax
c0101b71:	0f b7 c0             	movzwl %ax,%eax
c0101b74:	66 a3 ae ca 11 c0    	mov    %ax,0xc011caae
c0101b7a:	c7 45 f8 60 95 11 c0 	movl   $0xc0119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101b81:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b84:	0f 01 18             	lidtl  (%eax)
}
c0101b87:	90                   	nop
    
    //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
c0101b88:	90                   	nop
c0101b89:	89 ec                	mov    %ebp,%esp
c0101b8b:	5d                   	pop    %ebp
c0101b8c:	c3                   	ret    

c0101b8d <trapname>:

static const char *
trapname(int trapno) {
c0101b8d:	55                   	push   %ebp
c0101b8e:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b93:	83 f8 13             	cmp    $0x13,%eax
c0101b96:	77 0c                	ja     c0101ba4 <trapname+0x17>
        return excnames[trapno];
c0101b98:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9b:	8b 04 85 20 6b 10 c0 	mov    -0x3fef94e0(,%eax,4),%eax
c0101ba2:	eb 18                	jmp    c0101bbc <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101ba4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101ba8:	7e 0d                	jle    c0101bb7 <trapname+0x2a>
c0101baa:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101bae:	7f 07                	jg     c0101bb7 <trapname+0x2a>
        return "Hardware Interrupt";
c0101bb0:	b8 df 67 10 c0       	mov    $0xc01067df,%eax
c0101bb5:	eb 05                	jmp    c0101bbc <trapname+0x2f>
    }
    return "(unknown trap)";
c0101bb7:	b8 f2 67 10 c0       	mov    $0xc01067f2,%eax
}
c0101bbc:	5d                   	pop    %ebp
c0101bbd:	c3                   	ret    

c0101bbe <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101bbe:	55                   	push   %ebp
c0101bbf:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101bc8:	83 f8 08             	cmp    $0x8,%eax
c0101bcb:	0f 94 c0             	sete   %al
c0101bce:	0f b6 c0             	movzbl %al,%eax
}
c0101bd1:	5d                   	pop    %ebp
c0101bd2:	c3                   	ret    

c0101bd3 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101bd3:	55                   	push   %ebp
c0101bd4:	89 e5                	mov    %esp,%ebp
c0101bd6:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be0:	c7 04 24 33 68 10 c0 	movl   $0xc0106833,(%esp)
c0101be7:	e8 af e7 ff ff       	call   c010039b <cprintf>
    print_regs(&tf->tf_regs);
c0101bec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bef:	89 04 24             	mov    %eax,(%esp)
c0101bf2:	e8 8f 01 00 00       	call   c0101d86 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfa:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c02:	c7 04 24 44 68 10 c0 	movl   $0xc0106844,(%esp)
c0101c09:	e8 8d e7 ff ff       	call   c010039b <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c11:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c19:	c7 04 24 57 68 10 c0 	movl   $0xc0106857,(%esp)
c0101c20:	e8 76 e7 ff ff       	call   c010039b <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c28:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 6a 68 10 c0 	movl   $0xc010686a,(%esp)
c0101c37:	e8 5f e7 ff ff       	call   c010039b <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3f:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c47:	c7 04 24 7d 68 10 c0 	movl   $0xc010687d,(%esp)
c0101c4e:	e8 48 e7 ff ff       	call   c010039b <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c56:	8b 40 30             	mov    0x30(%eax),%eax
c0101c59:	89 04 24             	mov    %eax,(%esp)
c0101c5c:	e8 2c ff ff ff       	call   c0101b8d <trapname>
c0101c61:	8b 55 08             	mov    0x8(%ebp),%edx
c0101c64:	8b 52 30             	mov    0x30(%edx),%edx
c0101c67:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101c6b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101c6f:	c7 04 24 90 68 10 c0 	movl   $0xc0106890,(%esp)
c0101c76:	e8 20 e7 ff ff       	call   c010039b <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7e:	8b 40 34             	mov    0x34(%eax),%eax
c0101c81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c85:	c7 04 24 a2 68 10 c0 	movl   $0xc01068a2,(%esp)
c0101c8c:	e8 0a e7 ff ff       	call   c010039b <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101c91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c94:	8b 40 38             	mov    0x38(%eax),%eax
c0101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9b:	c7 04 24 b1 68 10 c0 	movl   $0xc01068b1,(%esp)
c0101ca2:	e8 f4 e6 ff ff       	call   c010039b <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101caa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101cae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb2:	c7 04 24 c0 68 10 c0 	movl   $0xc01068c0,(%esp)
c0101cb9:	e8 dd e6 ff ff       	call   c010039b <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc1:	8b 40 40             	mov    0x40(%eax),%eax
c0101cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc8:	c7 04 24 d3 68 10 c0 	movl   $0xc01068d3,(%esp)
c0101ccf:	e8 c7 e6 ff ff       	call   c010039b <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101cd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101cdb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101ce2:	eb 3d                	jmp    c0101d21 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce7:	8b 50 40             	mov    0x40(%eax),%edx
c0101cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101ced:	21 d0                	and    %edx,%eax
c0101cef:	85 c0                	test   %eax,%eax
c0101cf1:	74 28                	je     c0101d1b <print_trapframe+0x148>
c0101cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cf6:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101cfd:	85 c0                	test   %eax,%eax
c0101cff:	74 1a                	je     c0101d1b <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d04:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0f:	c7 04 24 e2 68 10 c0 	movl   $0xc01068e2,(%esp)
c0101d16:	e8 80 e6 ff ff       	call   c010039b <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101d1b:	ff 45 f4             	incl   -0xc(%ebp)
c0101d1e:	d1 65 f0             	shll   -0x10(%ebp)
c0101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d24:	83 f8 17             	cmp    $0x17,%eax
c0101d27:	76 bb                	jbe    c0101ce4 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101d29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d2c:	8b 40 40             	mov    0x40(%eax),%eax
c0101d2f:	c1 e8 0c             	shr    $0xc,%eax
c0101d32:	83 e0 03             	and    $0x3,%eax
c0101d35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d39:	c7 04 24 e6 68 10 c0 	movl   $0xc01068e6,(%esp)
c0101d40:	e8 56 e6 ff ff       	call   c010039b <cprintf>

    if (!trap_in_kernel(tf)) {
c0101d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d48:	89 04 24             	mov    %eax,(%esp)
c0101d4b:	e8 6e fe ff ff       	call   c0101bbe <trap_in_kernel>
c0101d50:	85 c0                	test   %eax,%eax
c0101d52:	75 2d                	jne    c0101d81 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d57:	8b 40 44             	mov    0x44(%eax),%eax
c0101d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d5e:	c7 04 24 ef 68 10 c0 	movl   $0xc01068ef,(%esp)
c0101d65:	e8 31 e6 ff ff       	call   c010039b <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101d71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d75:	c7 04 24 fe 68 10 c0 	movl   $0xc01068fe,(%esp)
c0101d7c:	e8 1a e6 ff ff       	call   c010039b <cprintf>
    }
}
c0101d81:	90                   	nop
c0101d82:	89 ec                	mov    %ebp,%esp
c0101d84:	5d                   	pop    %ebp
c0101d85:	c3                   	ret    

c0101d86 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101d86:	55                   	push   %ebp
c0101d87:	89 e5                	mov    %esp,%ebp
c0101d89:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8f:	8b 00                	mov    (%eax),%eax
c0101d91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d95:	c7 04 24 11 69 10 c0 	movl   $0xc0106911,(%esp)
c0101d9c:	e8 fa e5 ff ff       	call   c010039b <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101da1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da4:	8b 40 04             	mov    0x4(%eax),%eax
c0101da7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dab:	c7 04 24 20 69 10 c0 	movl   $0xc0106920,(%esp)
c0101db2:	e8 e4 e5 ff ff       	call   c010039b <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101db7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dba:	8b 40 08             	mov    0x8(%eax),%eax
c0101dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dc1:	c7 04 24 2f 69 10 c0 	movl   $0xc010692f,(%esp)
c0101dc8:	e8 ce e5 ff ff       	call   c010039b <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd0:	8b 40 0c             	mov    0xc(%eax),%eax
c0101dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dd7:	c7 04 24 3e 69 10 c0 	movl   $0xc010693e,(%esp)
c0101dde:	e8 b8 e5 ff ff       	call   c010039b <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101de3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101de6:	8b 40 10             	mov    0x10(%eax),%eax
c0101de9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ded:	c7 04 24 4d 69 10 c0 	movl   $0xc010694d,(%esp)
c0101df4:	e8 a2 e5 ff ff       	call   c010039b <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101df9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dfc:	8b 40 14             	mov    0x14(%eax),%eax
c0101dff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e03:	c7 04 24 5c 69 10 c0 	movl   $0xc010695c,(%esp)
c0101e0a:	e8 8c e5 ff ff       	call   c010039b <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e12:	8b 40 18             	mov    0x18(%eax),%eax
c0101e15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e19:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0101e20:	e8 76 e5 ff ff       	call   c010039b <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101e25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e28:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e2f:	c7 04 24 7a 69 10 c0 	movl   $0xc010697a,(%esp)
c0101e36:	e8 60 e5 ff ff       	call   c010039b <cprintf>
}
c0101e3b:	90                   	nop
c0101e3c:	89 ec                	mov    %ebp,%esp
c0101e3e:	5d                   	pop    %ebp
c0101e3f:	c3                   	ret    

c0101e40 <trap_dispatch>:



/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101e40:	55                   	push   %ebp
c0101e41:	89 e5                	mov    %esp,%ebp
c0101e43:	83 ec 38             	sub    $0x38,%esp
c0101e46:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
c0101e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e4c:	8b 40 30             	mov    0x30(%eax),%eax
c0101e4f:	83 f8 79             	cmp    $0x79,%eax
c0101e52:	0f 84 ca 02 00 00    	je     c0102122 <trap_dispatch+0x2e2>
c0101e58:	83 f8 79             	cmp    $0x79,%eax
c0101e5b:	0f 87 41 03 00 00    	ja     c01021a2 <trap_dispatch+0x362>
c0101e61:	83 f8 78             	cmp    $0x78,%eax
c0101e64:	0f 84 2b 02 00 00    	je     c0102095 <trap_dispatch+0x255>
c0101e6a:	83 f8 78             	cmp    $0x78,%eax
c0101e6d:	0f 87 2f 03 00 00    	ja     c01021a2 <trap_dispatch+0x362>
c0101e73:	83 f8 2f             	cmp    $0x2f,%eax
c0101e76:	0f 87 26 03 00 00    	ja     c01021a2 <trap_dispatch+0x362>
c0101e7c:	83 f8 2e             	cmp    $0x2e,%eax
c0101e7f:	0f 83 52 03 00 00    	jae    c01021d7 <trap_dispatch+0x397>
c0101e85:	83 f8 24             	cmp    $0x24,%eax
c0101e88:	74 5e                	je     c0101ee8 <trap_dispatch+0xa8>
c0101e8a:	83 f8 24             	cmp    $0x24,%eax
c0101e8d:	0f 87 0f 03 00 00    	ja     c01021a2 <trap_dispatch+0x362>
c0101e93:	83 f8 20             	cmp    $0x20,%eax
c0101e96:	74 0a                	je     c0101ea2 <trap_dispatch+0x62>
c0101e98:	83 f8 21             	cmp    $0x21,%eax
c0101e9b:	74 74                	je     c0101f11 <trap_dispatch+0xd1>
c0101e9d:	e9 00 03 00 00       	jmp    c01021a2 <trap_dispatch+0x362>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
         ticks++;
c0101ea2:	a1 24 c4 11 c0       	mov    0xc011c424,%eax
c0101ea7:	40                   	inc    %eax
c0101ea8:	a3 24 c4 11 c0       	mov    %eax,0xc011c424
        if(ticks%100==0){
c0101ead:	8b 0d 24 c4 11 c0    	mov    0xc011c424,%ecx
c0101eb3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101eb8:	89 c8                	mov    %ecx,%eax
c0101eba:	f7 e2                	mul    %edx
c0101ebc:	c1 ea 05             	shr    $0x5,%edx
c0101ebf:	89 d0                	mov    %edx,%eax
c0101ec1:	c1 e0 02             	shl    $0x2,%eax
c0101ec4:	01 d0                	add    %edx,%eax
c0101ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101ecd:	01 d0                	add    %edx,%eax
c0101ecf:	c1 e0 02             	shl    $0x2,%eax
c0101ed2:	29 c1                	sub    %eax,%ecx
c0101ed4:	89 ca                	mov    %ecx,%edx
c0101ed6:	85 d2                	test   %edx,%edx
c0101ed8:	0f 85 fc 02 00 00    	jne    c01021da <trap_dispatch+0x39a>
            print_ticks();
c0101ede:	e8 77 fa ff ff       	call   c010195a <print_ticks>
        }
        break;
c0101ee3:	e9 f2 02 00 00       	jmp    c01021da <trap_dispatch+0x39a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101ee8:	e8 10 f8 ff ff       	call   c01016fd <cons_getc>
c0101eed:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ef0:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ef4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101ef8:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101efc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f00:	c7 04 24 89 69 10 c0 	movl   $0xc0106989,(%esp)
c0101f07:	e8 8f e4 ff ff       	call   c010039b <cprintf>
        break;
c0101f0c:	e9 cd 02 00 00       	jmp    c01021de <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101f11:	e8 e7 f7 ff ff       	call   c01016fd <cons_getc>
c0101f16:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101f19:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101f1d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101f21:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f29:	c7 04 24 9b 69 10 c0 	movl   $0xc010699b,(%esp)
c0101f30:	e8 66 e4 ff ff       	call   c010039b <cprintf>
        if (c == '0'&&!trap_in_kernel(tf)) {
c0101f35:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c0101f39:	0f 85 a1 00 00 00    	jne    c0101fe0 <trap_dispatch+0x1a0>
c0101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f42:	89 04 24             	mov    %eax,(%esp)
c0101f45:	e8 74 fc ff ff       	call   c0101bbe <trap_in_kernel>
c0101f4a:	85 c0                	test   %eax,%eax
c0101f4c:	0f 85 8e 00 00 00    	jne    c0101fe0 <trap_dispatch+0x1a0>
c0101f52:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c0101f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f5f:	83 f8 08             	cmp    $0x8,%eax
c0101f62:	74 6b                	je     c0101fcf <trap_dispatch+0x18f>
        tf->tf_cs = KERNEL_CS;
c0101f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f67:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f70:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f79:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f80:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0101f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f87:	8b 40 40             	mov    0x40(%eax),%eax
c0101f8a:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101f8f:	89 c2                	mov    %eax,%edx
c0101f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f94:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f9a:	8b 40 44             	mov    0x44(%eax),%eax
c0101f9d:	83 e8 44             	sub    $0x44,%eax
c0101fa0:	a3 cc c6 11 c0       	mov    %eax,0xc011c6cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0101fa5:	a1 cc c6 11 c0       	mov    0xc011c6cc,%eax
c0101faa:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101fb1:	00 
c0101fb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101fb5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101fb9:	89 04 24             	mov    %eax,(%esp)
c0101fbc:	e8 0d 43 00 00       	call   c01062ce <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0101fc1:	8b 15 cc c6 11 c0    	mov    0xc011c6cc,%edx
c0101fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101fca:	83 e8 04             	sub    $0x4,%eax
c0101fcd:	89 10                	mov    %edx,(%eax)
}
c0101fcf:	90                   	nop
        //切换为内核态
        switch_to_kernel(tf);
        print_trapframe(tf);
c0101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fd3:	89 04 24             	mov    %eax,(%esp)
c0101fd6:	e8 f8 fb ff ff       	call   c0101bd3 <print_trapframe>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
        //切换为用户态
        switch_to_user(tf);
        print_trapframe(tf);
        }
        break;
c0101fdb:	e9 fd 01 00 00       	jmp    c01021dd <trap_dispatch+0x39d>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
c0101fe0:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c0101fe4:	0f 85 f3 01 00 00    	jne    c01021dd <trap_dispatch+0x39d>
c0101fea:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fed:	89 04 24             	mov    %eax,(%esp)
c0101ff0:	e8 c9 fb ff ff       	call   c0101bbe <trap_in_kernel>
c0101ff5:	85 c0                	test   %eax,%eax
c0101ff7:	0f 84 e0 01 00 00    	je     c01021dd <trap_dispatch+0x39d>
c0101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102000:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (tf->tf_cs != USER_CS) {
c0102003:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102006:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010200a:	83 f8 1b             	cmp    $0x1b,%eax
c010200d:	74 75                	je     c0102084 <trap_dispatch+0x244>
        switchk2u = *tf;
c010200f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0102012:	b8 4c 00 00 00       	mov    $0x4c,%eax
c0102017:	83 e0 fc             	and    $0xfffffffc,%eax
c010201a:	89 c3                	mov    %eax,%ebx
c010201c:	b8 00 00 00 00       	mov    $0x0,%eax
c0102021:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c0102024:	89 90 80 c6 11 c0    	mov    %edx,-0x3fee3980(%eax)
c010202a:	83 c0 04             	add    $0x4,%eax
c010202d:	39 d8                	cmp    %ebx,%eax
c010202f:	72 f0                	jb     c0102021 <trap_dispatch+0x1e1>
        switchk2u.tf_cs = USER_CS;
c0102031:	66 c7 05 bc c6 11 c0 	movw   $0x1b,0xc011c6bc
c0102038:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c010203a:	66 c7 05 c8 c6 11 c0 	movw   $0x23,0xc011c6c8
c0102041:	23 00 
c0102043:	0f b7 05 c8 c6 11 c0 	movzwl 0xc011c6c8,%eax
c010204a:	66 a3 a8 c6 11 c0    	mov    %ax,0xc011c6a8
c0102050:	0f b7 05 a8 c6 11 c0 	movzwl 0xc011c6a8,%eax
c0102057:	66 a3 ac c6 11 c0    	mov    %ax,0xc011c6ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c010205d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102060:	83 c0 4c             	add    $0x4c,%eax
c0102063:	a3 c4 c6 11 c0       	mov    %eax,0xc011c6c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c0102068:	a1 c0 c6 11 c0       	mov    0xc011c6c0,%eax
c010206d:	0d 00 30 00 00       	or     $0x3000,%eax
c0102072:	a3 c0 c6 11 c0       	mov    %eax,0xc011c6c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0102077:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010207a:	83 e8 04             	sub    $0x4,%eax
c010207d:	ba 80 c6 11 c0       	mov    $0xc011c680,%edx
c0102082:	89 10                	mov    %edx,(%eax)
}
c0102084:	90                   	nop
        print_trapframe(tf);
c0102085:	8b 45 08             	mov    0x8(%ebp),%eax
c0102088:	89 04 24             	mov    %eax,(%esp)
c010208b:	e8 43 fb ff ff       	call   c0101bd3 <print_trapframe>
        break;
c0102090:	e9 48 01 00 00       	jmp    c01021dd <trap_dispatch+0x39d>
c0102095:	8b 45 08             	mov    0x8(%ebp),%eax
c0102098:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (tf->tf_cs != USER_CS) {
c010209b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010209e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01020a2:	83 f8 1b             	cmp    $0x1b,%eax
c01020a5:	74 75                	je     c010211c <trap_dispatch+0x2dc>
        switchk2u = *tf;
c01020a7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01020aa:	b8 4c 00 00 00       	mov    $0x4c,%eax
c01020af:	83 e0 fc             	and    $0xfffffffc,%eax
c01020b2:	89 c3                	mov    %eax,%ebx
c01020b4:	b8 00 00 00 00       	mov    $0x0,%eax
c01020b9:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c01020bc:	89 90 80 c6 11 c0    	mov    %edx,-0x3fee3980(%eax)
c01020c2:	83 c0 04             	add    $0x4,%eax
c01020c5:	39 d8                	cmp    %ebx,%eax
c01020c7:	72 f0                	jb     c01020b9 <trap_dispatch+0x279>
        switchk2u.tf_cs = USER_CS;
c01020c9:	66 c7 05 bc c6 11 c0 	movw   $0x1b,0xc011c6bc
c01020d0:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01020d2:	66 c7 05 c8 c6 11 c0 	movw   $0x23,0xc011c6c8
c01020d9:	23 00 
c01020db:	0f b7 05 c8 c6 11 c0 	movzwl 0xc011c6c8,%eax
c01020e2:	66 a3 a8 c6 11 c0    	mov    %ax,0xc011c6a8
c01020e8:	0f b7 05 a8 c6 11 c0 	movzwl 0xc011c6a8,%eax
c01020ef:	66 a3 ac c6 11 c0    	mov    %ax,0xc011c6ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c01020f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01020f8:	83 c0 4c             	add    $0x4c,%eax
c01020fb:	a3 c4 c6 11 c0       	mov    %eax,0xc011c6c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c0102100:	a1 c0 c6 11 c0       	mov    0xc011c6c0,%eax
c0102105:	0d 00 30 00 00       	or     $0x3000,%eax
c010210a:	a3 c0 c6 11 c0       	mov    %eax,0xc011c6c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c010210f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102112:	83 e8 04             	sub    $0x4,%eax
c0102115:	ba 80 c6 11 c0       	mov    $0xc011c680,%edx
c010211a:	89 10                	mov    %edx,(%eax)
}
c010211c:	90                   	nop
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    	switch_to_user(tf);
    	break;
c010211d:	e9 bc 00 00 00       	jmp    c01021de <trap_dispatch+0x39e>
c0102122:	8b 45 08             	mov    0x8(%ebp),%eax
c0102125:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c0102128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010212b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010212f:	83 f8 08             	cmp    $0x8,%eax
c0102132:	74 6b                	je     c010219f <trap_dispatch+0x35f>
        tf->tf_cs = KERNEL_CS;
c0102134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102137:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c010213d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102140:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102146:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102149:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010214d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102150:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0102154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102157:	8b 40 40             	mov    0x40(%eax),%eax
c010215a:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c010215f:	89 c2                	mov    %eax,%edx
c0102161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102164:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010216a:	8b 40 44             	mov    0x44(%eax),%eax
c010216d:	83 e8 44             	sub    $0x44,%eax
c0102170:	a3 cc c6 11 c0       	mov    %eax,0xc011c6cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102175:	a1 cc c6 11 c0       	mov    0xc011c6cc,%eax
c010217a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102181:	00 
c0102182:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102185:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102189:	89 04 24             	mov    %eax,(%esp)
c010218c:	e8 3d 41 00 00       	call   c01062ce <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102191:	8b 15 cc c6 11 c0    	mov    0xc011c6cc,%edx
c0102197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010219a:	83 e8 04             	sub    $0x4,%eax
c010219d:	89 10                	mov    %edx,(%eax)
}
c010219f:	90                   	nop
    case T_SWITCH_TOK:
    	switch_to_kernel(tf);
        break;
c01021a0:	eb 3c                	jmp    c01021de <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01021a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01021a5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01021a9:	83 e0 03             	and    $0x3,%eax
c01021ac:	85 c0                	test   %eax,%eax
c01021ae:	75 2e                	jne    c01021de <trap_dispatch+0x39e>
            print_trapframe(tf);
c01021b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01021b3:	89 04 24             	mov    %eax,(%esp)
c01021b6:	e8 18 fa ff ff       	call   c0101bd3 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01021bb:	c7 44 24 08 aa 69 10 	movl   $0xc01069aa,0x8(%esp)
c01021c2:	c0 
c01021c3:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c01021ca:	00 
c01021cb:	c7 04 24 ce 67 10 c0 	movl   $0xc01067ce,(%esp)
c01021d2:	e8 46 eb ff ff       	call   c0100d1d <__panic>
        break;
c01021d7:	90                   	nop
c01021d8:	eb 04                	jmp    c01021de <trap_dispatch+0x39e>
        break;
c01021da:	90                   	nop
c01021db:	eb 01                	jmp    c01021de <trap_dispatch+0x39e>
        break;
c01021dd:	90                   	nop
        }
    }
}
c01021de:	90                   	nop
c01021df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01021e2:	89 ec                	mov    %ebp,%esp
c01021e4:	5d                   	pop    %ebp
c01021e5:	c3                   	ret    

c01021e6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01021e6:	55                   	push   %ebp
c01021e7:	89 e5                	mov    %esp,%ebp
c01021e9:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01021ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ef:	89 04 24             	mov    %eax,(%esp)
c01021f2:	e8 49 fc ff ff       	call   c0101e40 <trap_dispatch>
}
c01021f7:	90                   	nop
c01021f8:	89 ec                	mov    %ebp,%esp
c01021fa:	5d                   	pop    %ebp
c01021fb:	c3                   	ret    

c01021fc <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01021fc:	1e                   	push   %ds
    pushl %es
c01021fd:	06                   	push   %es
    pushl %fs
c01021fe:	0f a0                	push   %fs
    pushl %gs
c0102200:	0f a8                	push   %gs
    pushal
c0102202:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102203:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102208:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010220a:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010220c:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010220d:	e8 d4 ff ff ff       	call   c01021e6 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102212:	5c                   	pop    %esp

c0102213 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102213:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102214:	0f a9                	pop    %gs
    popl %fs
c0102216:	0f a1                	pop    %fs
    popl %es
c0102218:	07                   	pop    %es
    popl %ds
c0102219:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010221a:	83 c4 08             	add    $0x8,%esp
    iret
c010221d:	cf                   	iret   

c010221e <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010221e:	6a 00                	push   $0x0
  pushl $0
c0102220:	6a 00                	push   $0x0
  jmp __alltraps
c0102222:	e9 d5 ff ff ff       	jmp    c01021fc <__alltraps>

c0102227 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102227:	6a 00                	push   $0x0
  pushl $1
c0102229:	6a 01                	push   $0x1
  jmp __alltraps
c010222b:	e9 cc ff ff ff       	jmp    c01021fc <__alltraps>

c0102230 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102230:	6a 00                	push   $0x0
  pushl $2
c0102232:	6a 02                	push   $0x2
  jmp __alltraps
c0102234:	e9 c3 ff ff ff       	jmp    c01021fc <__alltraps>

c0102239 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $3
c010223b:	6a 03                	push   $0x3
  jmp __alltraps
c010223d:	e9 ba ff ff ff       	jmp    c01021fc <__alltraps>

c0102242 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102242:	6a 00                	push   $0x0
  pushl $4
c0102244:	6a 04                	push   $0x4
  jmp __alltraps
c0102246:	e9 b1 ff ff ff       	jmp    c01021fc <__alltraps>

c010224b <vector5>:
.globl vector5
vector5:
  pushl $0
c010224b:	6a 00                	push   $0x0
  pushl $5
c010224d:	6a 05                	push   $0x5
  jmp __alltraps
c010224f:	e9 a8 ff ff ff       	jmp    c01021fc <__alltraps>

c0102254 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102254:	6a 00                	push   $0x0
  pushl $6
c0102256:	6a 06                	push   $0x6
  jmp __alltraps
c0102258:	e9 9f ff ff ff       	jmp    c01021fc <__alltraps>

c010225d <vector7>:
.globl vector7
vector7:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $7
c010225f:	6a 07                	push   $0x7
  jmp __alltraps
c0102261:	e9 96 ff ff ff       	jmp    c01021fc <__alltraps>

c0102266 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102266:	6a 08                	push   $0x8
  jmp __alltraps
c0102268:	e9 8f ff ff ff       	jmp    c01021fc <__alltraps>

c010226d <vector9>:
.globl vector9
vector9:
  pushl $0
c010226d:	6a 00                	push   $0x0
  pushl $9
c010226f:	6a 09                	push   $0x9
  jmp __alltraps
c0102271:	e9 86 ff ff ff       	jmp    c01021fc <__alltraps>

c0102276 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102276:	6a 0a                	push   $0xa
  jmp __alltraps
c0102278:	e9 7f ff ff ff       	jmp    c01021fc <__alltraps>

c010227d <vector11>:
.globl vector11
vector11:
  pushl $11
c010227d:	6a 0b                	push   $0xb
  jmp __alltraps
c010227f:	e9 78 ff ff ff       	jmp    c01021fc <__alltraps>

c0102284 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102284:	6a 0c                	push   $0xc
  jmp __alltraps
c0102286:	e9 71 ff ff ff       	jmp    c01021fc <__alltraps>

c010228b <vector13>:
.globl vector13
vector13:
  pushl $13
c010228b:	6a 0d                	push   $0xd
  jmp __alltraps
c010228d:	e9 6a ff ff ff       	jmp    c01021fc <__alltraps>

c0102292 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102292:	6a 0e                	push   $0xe
  jmp __alltraps
c0102294:	e9 63 ff ff ff       	jmp    c01021fc <__alltraps>

c0102299 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $15
c010229b:	6a 0f                	push   $0xf
  jmp __alltraps
c010229d:	e9 5a ff ff ff       	jmp    c01021fc <__alltraps>

c01022a2 <vector16>:
.globl vector16
vector16:
  pushl $0
c01022a2:	6a 00                	push   $0x0
  pushl $16
c01022a4:	6a 10                	push   $0x10
  jmp __alltraps
c01022a6:	e9 51 ff ff ff       	jmp    c01021fc <__alltraps>

c01022ab <vector17>:
.globl vector17
vector17:
  pushl $17
c01022ab:	6a 11                	push   $0x11
  jmp __alltraps
c01022ad:	e9 4a ff ff ff       	jmp    c01021fc <__alltraps>

c01022b2 <vector18>:
.globl vector18
vector18:
  pushl $0
c01022b2:	6a 00                	push   $0x0
  pushl $18
c01022b4:	6a 12                	push   $0x12
  jmp __alltraps
c01022b6:	e9 41 ff ff ff       	jmp    c01021fc <__alltraps>

c01022bb <vector19>:
.globl vector19
vector19:
  pushl $0
c01022bb:	6a 00                	push   $0x0
  pushl $19
c01022bd:	6a 13                	push   $0x13
  jmp __alltraps
c01022bf:	e9 38 ff ff ff       	jmp    c01021fc <__alltraps>

c01022c4 <vector20>:
.globl vector20
vector20:
  pushl $0
c01022c4:	6a 00                	push   $0x0
  pushl $20
c01022c6:	6a 14                	push   $0x14
  jmp __alltraps
c01022c8:	e9 2f ff ff ff       	jmp    c01021fc <__alltraps>

c01022cd <vector21>:
.globl vector21
vector21:
  pushl $0
c01022cd:	6a 00                	push   $0x0
  pushl $21
c01022cf:	6a 15                	push   $0x15
  jmp __alltraps
c01022d1:	e9 26 ff ff ff       	jmp    c01021fc <__alltraps>

c01022d6 <vector22>:
.globl vector22
vector22:
  pushl $0
c01022d6:	6a 00                	push   $0x0
  pushl $22
c01022d8:	6a 16                	push   $0x16
  jmp __alltraps
c01022da:	e9 1d ff ff ff       	jmp    c01021fc <__alltraps>

c01022df <vector23>:
.globl vector23
vector23:
  pushl $0
c01022df:	6a 00                	push   $0x0
  pushl $23
c01022e1:	6a 17                	push   $0x17
  jmp __alltraps
c01022e3:	e9 14 ff ff ff       	jmp    c01021fc <__alltraps>

c01022e8 <vector24>:
.globl vector24
vector24:
  pushl $0
c01022e8:	6a 00                	push   $0x0
  pushl $24
c01022ea:	6a 18                	push   $0x18
  jmp __alltraps
c01022ec:	e9 0b ff ff ff       	jmp    c01021fc <__alltraps>

c01022f1 <vector25>:
.globl vector25
vector25:
  pushl $0
c01022f1:	6a 00                	push   $0x0
  pushl $25
c01022f3:	6a 19                	push   $0x19
  jmp __alltraps
c01022f5:	e9 02 ff ff ff       	jmp    c01021fc <__alltraps>

c01022fa <vector26>:
.globl vector26
vector26:
  pushl $0
c01022fa:	6a 00                	push   $0x0
  pushl $26
c01022fc:	6a 1a                	push   $0x1a
  jmp __alltraps
c01022fe:	e9 f9 fe ff ff       	jmp    c01021fc <__alltraps>

c0102303 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102303:	6a 00                	push   $0x0
  pushl $27
c0102305:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102307:	e9 f0 fe ff ff       	jmp    c01021fc <__alltraps>

c010230c <vector28>:
.globl vector28
vector28:
  pushl $0
c010230c:	6a 00                	push   $0x0
  pushl $28
c010230e:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102310:	e9 e7 fe ff ff       	jmp    c01021fc <__alltraps>

c0102315 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102315:	6a 00                	push   $0x0
  pushl $29
c0102317:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102319:	e9 de fe ff ff       	jmp    c01021fc <__alltraps>

c010231e <vector30>:
.globl vector30
vector30:
  pushl $0
c010231e:	6a 00                	push   $0x0
  pushl $30
c0102320:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102322:	e9 d5 fe ff ff       	jmp    c01021fc <__alltraps>

c0102327 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102327:	6a 00                	push   $0x0
  pushl $31
c0102329:	6a 1f                	push   $0x1f
  jmp __alltraps
c010232b:	e9 cc fe ff ff       	jmp    c01021fc <__alltraps>

c0102330 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102330:	6a 00                	push   $0x0
  pushl $32
c0102332:	6a 20                	push   $0x20
  jmp __alltraps
c0102334:	e9 c3 fe ff ff       	jmp    c01021fc <__alltraps>

c0102339 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102339:	6a 00                	push   $0x0
  pushl $33
c010233b:	6a 21                	push   $0x21
  jmp __alltraps
c010233d:	e9 ba fe ff ff       	jmp    c01021fc <__alltraps>

c0102342 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102342:	6a 00                	push   $0x0
  pushl $34
c0102344:	6a 22                	push   $0x22
  jmp __alltraps
c0102346:	e9 b1 fe ff ff       	jmp    c01021fc <__alltraps>

c010234b <vector35>:
.globl vector35
vector35:
  pushl $0
c010234b:	6a 00                	push   $0x0
  pushl $35
c010234d:	6a 23                	push   $0x23
  jmp __alltraps
c010234f:	e9 a8 fe ff ff       	jmp    c01021fc <__alltraps>

c0102354 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102354:	6a 00                	push   $0x0
  pushl $36
c0102356:	6a 24                	push   $0x24
  jmp __alltraps
c0102358:	e9 9f fe ff ff       	jmp    c01021fc <__alltraps>

c010235d <vector37>:
.globl vector37
vector37:
  pushl $0
c010235d:	6a 00                	push   $0x0
  pushl $37
c010235f:	6a 25                	push   $0x25
  jmp __alltraps
c0102361:	e9 96 fe ff ff       	jmp    c01021fc <__alltraps>

c0102366 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102366:	6a 00                	push   $0x0
  pushl $38
c0102368:	6a 26                	push   $0x26
  jmp __alltraps
c010236a:	e9 8d fe ff ff       	jmp    c01021fc <__alltraps>

c010236f <vector39>:
.globl vector39
vector39:
  pushl $0
c010236f:	6a 00                	push   $0x0
  pushl $39
c0102371:	6a 27                	push   $0x27
  jmp __alltraps
c0102373:	e9 84 fe ff ff       	jmp    c01021fc <__alltraps>

c0102378 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102378:	6a 00                	push   $0x0
  pushl $40
c010237a:	6a 28                	push   $0x28
  jmp __alltraps
c010237c:	e9 7b fe ff ff       	jmp    c01021fc <__alltraps>

c0102381 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102381:	6a 00                	push   $0x0
  pushl $41
c0102383:	6a 29                	push   $0x29
  jmp __alltraps
c0102385:	e9 72 fe ff ff       	jmp    c01021fc <__alltraps>

c010238a <vector42>:
.globl vector42
vector42:
  pushl $0
c010238a:	6a 00                	push   $0x0
  pushl $42
c010238c:	6a 2a                	push   $0x2a
  jmp __alltraps
c010238e:	e9 69 fe ff ff       	jmp    c01021fc <__alltraps>

c0102393 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102393:	6a 00                	push   $0x0
  pushl $43
c0102395:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102397:	e9 60 fe ff ff       	jmp    c01021fc <__alltraps>

c010239c <vector44>:
.globl vector44
vector44:
  pushl $0
c010239c:	6a 00                	push   $0x0
  pushl $44
c010239e:	6a 2c                	push   $0x2c
  jmp __alltraps
c01023a0:	e9 57 fe ff ff       	jmp    c01021fc <__alltraps>

c01023a5 <vector45>:
.globl vector45
vector45:
  pushl $0
c01023a5:	6a 00                	push   $0x0
  pushl $45
c01023a7:	6a 2d                	push   $0x2d
  jmp __alltraps
c01023a9:	e9 4e fe ff ff       	jmp    c01021fc <__alltraps>

c01023ae <vector46>:
.globl vector46
vector46:
  pushl $0
c01023ae:	6a 00                	push   $0x0
  pushl $46
c01023b0:	6a 2e                	push   $0x2e
  jmp __alltraps
c01023b2:	e9 45 fe ff ff       	jmp    c01021fc <__alltraps>

c01023b7 <vector47>:
.globl vector47
vector47:
  pushl $0
c01023b7:	6a 00                	push   $0x0
  pushl $47
c01023b9:	6a 2f                	push   $0x2f
  jmp __alltraps
c01023bb:	e9 3c fe ff ff       	jmp    c01021fc <__alltraps>

c01023c0 <vector48>:
.globl vector48
vector48:
  pushl $0
c01023c0:	6a 00                	push   $0x0
  pushl $48
c01023c2:	6a 30                	push   $0x30
  jmp __alltraps
c01023c4:	e9 33 fe ff ff       	jmp    c01021fc <__alltraps>

c01023c9 <vector49>:
.globl vector49
vector49:
  pushl $0
c01023c9:	6a 00                	push   $0x0
  pushl $49
c01023cb:	6a 31                	push   $0x31
  jmp __alltraps
c01023cd:	e9 2a fe ff ff       	jmp    c01021fc <__alltraps>

c01023d2 <vector50>:
.globl vector50
vector50:
  pushl $0
c01023d2:	6a 00                	push   $0x0
  pushl $50
c01023d4:	6a 32                	push   $0x32
  jmp __alltraps
c01023d6:	e9 21 fe ff ff       	jmp    c01021fc <__alltraps>

c01023db <vector51>:
.globl vector51
vector51:
  pushl $0
c01023db:	6a 00                	push   $0x0
  pushl $51
c01023dd:	6a 33                	push   $0x33
  jmp __alltraps
c01023df:	e9 18 fe ff ff       	jmp    c01021fc <__alltraps>

c01023e4 <vector52>:
.globl vector52
vector52:
  pushl $0
c01023e4:	6a 00                	push   $0x0
  pushl $52
c01023e6:	6a 34                	push   $0x34
  jmp __alltraps
c01023e8:	e9 0f fe ff ff       	jmp    c01021fc <__alltraps>

c01023ed <vector53>:
.globl vector53
vector53:
  pushl $0
c01023ed:	6a 00                	push   $0x0
  pushl $53
c01023ef:	6a 35                	push   $0x35
  jmp __alltraps
c01023f1:	e9 06 fe ff ff       	jmp    c01021fc <__alltraps>

c01023f6 <vector54>:
.globl vector54
vector54:
  pushl $0
c01023f6:	6a 00                	push   $0x0
  pushl $54
c01023f8:	6a 36                	push   $0x36
  jmp __alltraps
c01023fa:	e9 fd fd ff ff       	jmp    c01021fc <__alltraps>

c01023ff <vector55>:
.globl vector55
vector55:
  pushl $0
c01023ff:	6a 00                	push   $0x0
  pushl $55
c0102401:	6a 37                	push   $0x37
  jmp __alltraps
c0102403:	e9 f4 fd ff ff       	jmp    c01021fc <__alltraps>

c0102408 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102408:	6a 00                	push   $0x0
  pushl $56
c010240a:	6a 38                	push   $0x38
  jmp __alltraps
c010240c:	e9 eb fd ff ff       	jmp    c01021fc <__alltraps>

c0102411 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102411:	6a 00                	push   $0x0
  pushl $57
c0102413:	6a 39                	push   $0x39
  jmp __alltraps
c0102415:	e9 e2 fd ff ff       	jmp    c01021fc <__alltraps>

c010241a <vector58>:
.globl vector58
vector58:
  pushl $0
c010241a:	6a 00                	push   $0x0
  pushl $58
c010241c:	6a 3a                	push   $0x3a
  jmp __alltraps
c010241e:	e9 d9 fd ff ff       	jmp    c01021fc <__alltraps>

c0102423 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102423:	6a 00                	push   $0x0
  pushl $59
c0102425:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102427:	e9 d0 fd ff ff       	jmp    c01021fc <__alltraps>

c010242c <vector60>:
.globl vector60
vector60:
  pushl $0
c010242c:	6a 00                	push   $0x0
  pushl $60
c010242e:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102430:	e9 c7 fd ff ff       	jmp    c01021fc <__alltraps>

c0102435 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102435:	6a 00                	push   $0x0
  pushl $61
c0102437:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102439:	e9 be fd ff ff       	jmp    c01021fc <__alltraps>

c010243e <vector62>:
.globl vector62
vector62:
  pushl $0
c010243e:	6a 00                	push   $0x0
  pushl $62
c0102440:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102442:	e9 b5 fd ff ff       	jmp    c01021fc <__alltraps>

c0102447 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102447:	6a 00                	push   $0x0
  pushl $63
c0102449:	6a 3f                	push   $0x3f
  jmp __alltraps
c010244b:	e9 ac fd ff ff       	jmp    c01021fc <__alltraps>

c0102450 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102450:	6a 00                	push   $0x0
  pushl $64
c0102452:	6a 40                	push   $0x40
  jmp __alltraps
c0102454:	e9 a3 fd ff ff       	jmp    c01021fc <__alltraps>

c0102459 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102459:	6a 00                	push   $0x0
  pushl $65
c010245b:	6a 41                	push   $0x41
  jmp __alltraps
c010245d:	e9 9a fd ff ff       	jmp    c01021fc <__alltraps>

c0102462 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102462:	6a 00                	push   $0x0
  pushl $66
c0102464:	6a 42                	push   $0x42
  jmp __alltraps
c0102466:	e9 91 fd ff ff       	jmp    c01021fc <__alltraps>

c010246b <vector67>:
.globl vector67
vector67:
  pushl $0
c010246b:	6a 00                	push   $0x0
  pushl $67
c010246d:	6a 43                	push   $0x43
  jmp __alltraps
c010246f:	e9 88 fd ff ff       	jmp    c01021fc <__alltraps>

c0102474 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102474:	6a 00                	push   $0x0
  pushl $68
c0102476:	6a 44                	push   $0x44
  jmp __alltraps
c0102478:	e9 7f fd ff ff       	jmp    c01021fc <__alltraps>

c010247d <vector69>:
.globl vector69
vector69:
  pushl $0
c010247d:	6a 00                	push   $0x0
  pushl $69
c010247f:	6a 45                	push   $0x45
  jmp __alltraps
c0102481:	e9 76 fd ff ff       	jmp    c01021fc <__alltraps>

c0102486 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102486:	6a 00                	push   $0x0
  pushl $70
c0102488:	6a 46                	push   $0x46
  jmp __alltraps
c010248a:	e9 6d fd ff ff       	jmp    c01021fc <__alltraps>

c010248f <vector71>:
.globl vector71
vector71:
  pushl $0
c010248f:	6a 00                	push   $0x0
  pushl $71
c0102491:	6a 47                	push   $0x47
  jmp __alltraps
c0102493:	e9 64 fd ff ff       	jmp    c01021fc <__alltraps>

c0102498 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102498:	6a 00                	push   $0x0
  pushl $72
c010249a:	6a 48                	push   $0x48
  jmp __alltraps
c010249c:	e9 5b fd ff ff       	jmp    c01021fc <__alltraps>

c01024a1 <vector73>:
.globl vector73
vector73:
  pushl $0
c01024a1:	6a 00                	push   $0x0
  pushl $73
c01024a3:	6a 49                	push   $0x49
  jmp __alltraps
c01024a5:	e9 52 fd ff ff       	jmp    c01021fc <__alltraps>

c01024aa <vector74>:
.globl vector74
vector74:
  pushl $0
c01024aa:	6a 00                	push   $0x0
  pushl $74
c01024ac:	6a 4a                	push   $0x4a
  jmp __alltraps
c01024ae:	e9 49 fd ff ff       	jmp    c01021fc <__alltraps>

c01024b3 <vector75>:
.globl vector75
vector75:
  pushl $0
c01024b3:	6a 00                	push   $0x0
  pushl $75
c01024b5:	6a 4b                	push   $0x4b
  jmp __alltraps
c01024b7:	e9 40 fd ff ff       	jmp    c01021fc <__alltraps>

c01024bc <vector76>:
.globl vector76
vector76:
  pushl $0
c01024bc:	6a 00                	push   $0x0
  pushl $76
c01024be:	6a 4c                	push   $0x4c
  jmp __alltraps
c01024c0:	e9 37 fd ff ff       	jmp    c01021fc <__alltraps>

c01024c5 <vector77>:
.globl vector77
vector77:
  pushl $0
c01024c5:	6a 00                	push   $0x0
  pushl $77
c01024c7:	6a 4d                	push   $0x4d
  jmp __alltraps
c01024c9:	e9 2e fd ff ff       	jmp    c01021fc <__alltraps>

c01024ce <vector78>:
.globl vector78
vector78:
  pushl $0
c01024ce:	6a 00                	push   $0x0
  pushl $78
c01024d0:	6a 4e                	push   $0x4e
  jmp __alltraps
c01024d2:	e9 25 fd ff ff       	jmp    c01021fc <__alltraps>

c01024d7 <vector79>:
.globl vector79
vector79:
  pushl $0
c01024d7:	6a 00                	push   $0x0
  pushl $79
c01024d9:	6a 4f                	push   $0x4f
  jmp __alltraps
c01024db:	e9 1c fd ff ff       	jmp    c01021fc <__alltraps>

c01024e0 <vector80>:
.globl vector80
vector80:
  pushl $0
c01024e0:	6a 00                	push   $0x0
  pushl $80
c01024e2:	6a 50                	push   $0x50
  jmp __alltraps
c01024e4:	e9 13 fd ff ff       	jmp    c01021fc <__alltraps>

c01024e9 <vector81>:
.globl vector81
vector81:
  pushl $0
c01024e9:	6a 00                	push   $0x0
  pushl $81
c01024eb:	6a 51                	push   $0x51
  jmp __alltraps
c01024ed:	e9 0a fd ff ff       	jmp    c01021fc <__alltraps>

c01024f2 <vector82>:
.globl vector82
vector82:
  pushl $0
c01024f2:	6a 00                	push   $0x0
  pushl $82
c01024f4:	6a 52                	push   $0x52
  jmp __alltraps
c01024f6:	e9 01 fd ff ff       	jmp    c01021fc <__alltraps>

c01024fb <vector83>:
.globl vector83
vector83:
  pushl $0
c01024fb:	6a 00                	push   $0x0
  pushl $83
c01024fd:	6a 53                	push   $0x53
  jmp __alltraps
c01024ff:	e9 f8 fc ff ff       	jmp    c01021fc <__alltraps>

c0102504 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102504:	6a 00                	push   $0x0
  pushl $84
c0102506:	6a 54                	push   $0x54
  jmp __alltraps
c0102508:	e9 ef fc ff ff       	jmp    c01021fc <__alltraps>

c010250d <vector85>:
.globl vector85
vector85:
  pushl $0
c010250d:	6a 00                	push   $0x0
  pushl $85
c010250f:	6a 55                	push   $0x55
  jmp __alltraps
c0102511:	e9 e6 fc ff ff       	jmp    c01021fc <__alltraps>

c0102516 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102516:	6a 00                	push   $0x0
  pushl $86
c0102518:	6a 56                	push   $0x56
  jmp __alltraps
c010251a:	e9 dd fc ff ff       	jmp    c01021fc <__alltraps>

c010251f <vector87>:
.globl vector87
vector87:
  pushl $0
c010251f:	6a 00                	push   $0x0
  pushl $87
c0102521:	6a 57                	push   $0x57
  jmp __alltraps
c0102523:	e9 d4 fc ff ff       	jmp    c01021fc <__alltraps>

c0102528 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102528:	6a 00                	push   $0x0
  pushl $88
c010252a:	6a 58                	push   $0x58
  jmp __alltraps
c010252c:	e9 cb fc ff ff       	jmp    c01021fc <__alltraps>

c0102531 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102531:	6a 00                	push   $0x0
  pushl $89
c0102533:	6a 59                	push   $0x59
  jmp __alltraps
c0102535:	e9 c2 fc ff ff       	jmp    c01021fc <__alltraps>

c010253a <vector90>:
.globl vector90
vector90:
  pushl $0
c010253a:	6a 00                	push   $0x0
  pushl $90
c010253c:	6a 5a                	push   $0x5a
  jmp __alltraps
c010253e:	e9 b9 fc ff ff       	jmp    c01021fc <__alltraps>

c0102543 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102543:	6a 00                	push   $0x0
  pushl $91
c0102545:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102547:	e9 b0 fc ff ff       	jmp    c01021fc <__alltraps>

c010254c <vector92>:
.globl vector92
vector92:
  pushl $0
c010254c:	6a 00                	push   $0x0
  pushl $92
c010254e:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102550:	e9 a7 fc ff ff       	jmp    c01021fc <__alltraps>

c0102555 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102555:	6a 00                	push   $0x0
  pushl $93
c0102557:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102559:	e9 9e fc ff ff       	jmp    c01021fc <__alltraps>

c010255e <vector94>:
.globl vector94
vector94:
  pushl $0
c010255e:	6a 00                	push   $0x0
  pushl $94
c0102560:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102562:	e9 95 fc ff ff       	jmp    c01021fc <__alltraps>

c0102567 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102567:	6a 00                	push   $0x0
  pushl $95
c0102569:	6a 5f                	push   $0x5f
  jmp __alltraps
c010256b:	e9 8c fc ff ff       	jmp    c01021fc <__alltraps>

c0102570 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102570:	6a 00                	push   $0x0
  pushl $96
c0102572:	6a 60                	push   $0x60
  jmp __alltraps
c0102574:	e9 83 fc ff ff       	jmp    c01021fc <__alltraps>

c0102579 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102579:	6a 00                	push   $0x0
  pushl $97
c010257b:	6a 61                	push   $0x61
  jmp __alltraps
c010257d:	e9 7a fc ff ff       	jmp    c01021fc <__alltraps>

c0102582 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102582:	6a 00                	push   $0x0
  pushl $98
c0102584:	6a 62                	push   $0x62
  jmp __alltraps
c0102586:	e9 71 fc ff ff       	jmp    c01021fc <__alltraps>

c010258b <vector99>:
.globl vector99
vector99:
  pushl $0
c010258b:	6a 00                	push   $0x0
  pushl $99
c010258d:	6a 63                	push   $0x63
  jmp __alltraps
c010258f:	e9 68 fc ff ff       	jmp    c01021fc <__alltraps>

c0102594 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102594:	6a 00                	push   $0x0
  pushl $100
c0102596:	6a 64                	push   $0x64
  jmp __alltraps
c0102598:	e9 5f fc ff ff       	jmp    c01021fc <__alltraps>

c010259d <vector101>:
.globl vector101
vector101:
  pushl $0
c010259d:	6a 00                	push   $0x0
  pushl $101
c010259f:	6a 65                	push   $0x65
  jmp __alltraps
c01025a1:	e9 56 fc ff ff       	jmp    c01021fc <__alltraps>

c01025a6 <vector102>:
.globl vector102
vector102:
  pushl $0
c01025a6:	6a 00                	push   $0x0
  pushl $102
c01025a8:	6a 66                	push   $0x66
  jmp __alltraps
c01025aa:	e9 4d fc ff ff       	jmp    c01021fc <__alltraps>

c01025af <vector103>:
.globl vector103
vector103:
  pushl $0
c01025af:	6a 00                	push   $0x0
  pushl $103
c01025b1:	6a 67                	push   $0x67
  jmp __alltraps
c01025b3:	e9 44 fc ff ff       	jmp    c01021fc <__alltraps>

c01025b8 <vector104>:
.globl vector104
vector104:
  pushl $0
c01025b8:	6a 00                	push   $0x0
  pushl $104
c01025ba:	6a 68                	push   $0x68
  jmp __alltraps
c01025bc:	e9 3b fc ff ff       	jmp    c01021fc <__alltraps>

c01025c1 <vector105>:
.globl vector105
vector105:
  pushl $0
c01025c1:	6a 00                	push   $0x0
  pushl $105
c01025c3:	6a 69                	push   $0x69
  jmp __alltraps
c01025c5:	e9 32 fc ff ff       	jmp    c01021fc <__alltraps>

c01025ca <vector106>:
.globl vector106
vector106:
  pushl $0
c01025ca:	6a 00                	push   $0x0
  pushl $106
c01025cc:	6a 6a                	push   $0x6a
  jmp __alltraps
c01025ce:	e9 29 fc ff ff       	jmp    c01021fc <__alltraps>

c01025d3 <vector107>:
.globl vector107
vector107:
  pushl $0
c01025d3:	6a 00                	push   $0x0
  pushl $107
c01025d5:	6a 6b                	push   $0x6b
  jmp __alltraps
c01025d7:	e9 20 fc ff ff       	jmp    c01021fc <__alltraps>

c01025dc <vector108>:
.globl vector108
vector108:
  pushl $0
c01025dc:	6a 00                	push   $0x0
  pushl $108
c01025de:	6a 6c                	push   $0x6c
  jmp __alltraps
c01025e0:	e9 17 fc ff ff       	jmp    c01021fc <__alltraps>

c01025e5 <vector109>:
.globl vector109
vector109:
  pushl $0
c01025e5:	6a 00                	push   $0x0
  pushl $109
c01025e7:	6a 6d                	push   $0x6d
  jmp __alltraps
c01025e9:	e9 0e fc ff ff       	jmp    c01021fc <__alltraps>

c01025ee <vector110>:
.globl vector110
vector110:
  pushl $0
c01025ee:	6a 00                	push   $0x0
  pushl $110
c01025f0:	6a 6e                	push   $0x6e
  jmp __alltraps
c01025f2:	e9 05 fc ff ff       	jmp    c01021fc <__alltraps>

c01025f7 <vector111>:
.globl vector111
vector111:
  pushl $0
c01025f7:	6a 00                	push   $0x0
  pushl $111
c01025f9:	6a 6f                	push   $0x6f
  jmp __alltraps
c01025fb:	e9 fc fb ff ff       	jmp    c01021fc <__alltraps>

c0102600 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102600:	6a 00                	push   $0x0
  pushl $112
c0102602:	6a 70                	push   $0x70
  jmp __alltraps
c0102604:	e9 f3 fb ff ff       	jmp    c01021fc <__alltraps>

c0102609 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102609:	6a 00                	push   $0x0
  pushl $113
c010260b:	6a 71                	push   $0x71
  jmp __alltraps
c010260d:	e9 ea fb ff ff       	jmp    c01021fc <__alltraps>

c0102612 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102612:	6a 00                	push   $0x0
  pushl $114
c0102614:	6a 72                	push   $0x72
  jmp __alltraps
c0102616:	e9 e1 fb ff ff       	jmp    c01021fc <__alltraps>

c010261b <vector115>:
.globl vector115
vector115:
  pushl $0
c010261b:	6a 00                	push   $0x0
  pushl $115
c010261d:	6a 73                	push   $0x73
  jmp __alltraps
c010261f:	e9 d8 fb ff ff       	jmp    c01021fc <__alltraps>

c0102624 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102624:	6a 00                	push   $0x0
  pushl $116
c0102626:	6a 74                	push   $0x74
  jmp __alltraps
c0102628:	e9 cf fb ff ff       	jmp    c01021fc <__alltraps>

c010262d <vector117>:
.globl vector117
vector117:
  pushl $0
c010262d:	6a 00                	push   $0x0
  pushl $117
c010262f:	6a 75                	push   $0x75
  jmp __alltraps
c0102631:	e9 c6 fb ff ff       	jmp    c01021fc <__alltraps>

c0102636 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102636:	6a 00                	push   $0x0
  pushl $118
c0102638:	6a 76                	push   $0x76
  jmp __alltraps
c010263a:	e9 bd fb ff ff       	jmp    c01021fc <__alltraps>

c010263f <vector119>:
.globl vector119
vector119:
  pushl $0
c010263f:	6a 00                	push   $0x0
  pushl $119
c0102641:	6a 77                	push   $0x77
  jmp __alltraps
c0102643:	e9 b4 fb ff ff       	jmp    c01021fc <__alltraps>

c0102648 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102648:	6a 00                	push   $0x0
  pushl $120
c010264a:	6a 78                	push   $0x78
  jmp __alltraps
c010264c:	e9 ab fb ff ff       	jmp    c01021fc <__alltraps>

c0102651 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102651:	6a 00                	push   $0x0
  pushl $121
c0102653:	6a 79                	push   $0x79
  jmp __alltraps
c0102655:	e9 a2 fb ff ff       	jmp    c01021fc <__alltraps>

c010265a <vector122>:
.globl vector122
vector122:
  pushl $0
c010265a:	6a 00                	push   $0x0
  pushl $122
c010265c:	6a 7a                	push   $0x7a
  jmp __alltraps
c010265e:	e9 99 fb ff ff       	jmp    c01021fc <__alltraps>

c0102663 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102663:	6a 00                	push   $0x0
  pushl $123
c0102665:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102667:	e9 90 fb ff ff       	jmp    c01021fc <__alltraps>

c010266c <vector124>:
.globl vector124
vector124:
  pushl $0
c010266c:	6a 00                	push   $0x0
  pushl $124
c010266e:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102670:	e9 87 fb ff ff       	jmp    c01021fc <__alltraps>

c0102675 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102675:	6a 00                	push   $0x0
  pushl $125
c0102677:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102679:	e9 7e fb ff ff       	jmp    c01021fc <__alltraps>

c010267e <vector126>:
.globl vector126
vector126:
  pushl $0
c010267e:	6a 00                	push   $0x0
  pushl $126
c0102680:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102682:	e9 75 fb ff ff       	jmp    c01021fc <__alltraps>

c0102687 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102687:	6a 00                	push   $0x0
  pushl $127
c0102689:	6a 7f                	push   $0x7f
  jmp __alltraps
c010268b:	e9 6c fb ff ff       	jmp    c01021fc <__alltraps>

c0102690 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102690:	6a 00                	push   $0x0
  pushl $128
c0102692:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102697:	e9 60 fb ff ff       	jmp    c01021fc <__alltraps>

c010269c <vector129>:
.globl vector129
vector129:
  pushl $0
c010269c:	6a 00                	push   $0x0
  pushl $129
c010269e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01026a3:	e9 54 fb ff ff       	jmp    c01021fc <__alltraps>

c01026a8 <vector130>:
.globl vector130
vector130:
  pushl $0
c01026a8:	6a 00                	push   $0x0
  pushl $130
c01026aa:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01026af:	e9 48 fb ff ff       	jmp    c01021fc <__alltraps>

c01026b4 <vector131>:
.globl vector131
vector131:
  pushl $0
c01026b4:	6a 00                	push   $0x0
  pushl $131
c01026b6:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01026bb:	e9 3c fb ff ff       	jmp    c01021fc <__alltraps>

c01026c0 <vector132>:
.globl vector132
vector132:
  pushl $0
c01026c0:	6a 00                	push   $0x0
  pushl $132
c01026c2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01026c7:	e9 30 fb ff ff       	jmp    c01021fc <__alltraps>

c01026cc <vector133>:
.globl vector133
vector133:
  pushl $0
c01026cc:	6a 00                	push   $0x0
  pushl $133
c01026ce:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01026d3:	e9 24 fb ff ff       	jmp    c01021fc <__alltraps>

c01026d8 <vector134>:
.globl vector134
vector134:
  pushl $0
c01026d8:	6a 00                	push   $0x0
  pushl $134
c01026da:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01026df:	e9 18 fb ff ff       	jmp    c01021fc <__alltraps>

c01026e4 <vector135>:
.globl vector135
vector135:
  pushl $0
c01026e4:	6a 00                	push   $0x0
  pushl $135
c01026e6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01026eb:	e9 0c fb ff ff       	jmp    c01021fc <__alltraps>

c01026f0 <vector136>:
.globl vector136
vector136:
  pushl $0
c01026f0:	6a 00                	push   $0x0
  pushl $136
c01026f2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01026f7:	e9 00 fb ff ff       	jmp    c01021fc <__alltraps>

c01026fc <vector137>:
.globl vector137
vector137:
  pushl $0
c01026fc:	6a 00                	push   $0x0
  pushl $137
c01026fe:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102703:	e9 f4 fa ff ff       	jmp    c01021fc <__alltraps>

c0102708 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102708:	6a 00                	push   $0x0
  pushl $138
c010270a:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010270f:	e9 e8 fa ff ff       	jmp    c01021fc <__alltraps>

c0102714 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102714:	6a 00                	push   $0x0
  pushl $139
c0102716:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010271b:	e9 dc fa ff ff       	jmp    c01021fc <__alltraps>

c0102720 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102720:	6a 00                	push   $0x0
  pushl $140
c0102722:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102727:	e9 d0 fa ff ff       	jmp    c01021fc <__alltraps>

c010272c <vector141>:
.globl vector141
vector141:
  pushl $0
c010272c:	6a 00                	push   $0x0
  pushl $141
c010272e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102733:	e9 c4 fa ff ff       	jmp    c01021fc <__alltraps>

c0102738 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102738:	6a 00                	push   $0x0
  pushl $142
c010273a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010273f:	e9 b8 fa ff ff       	jmp    c01021fc <__alltraps>

c0102744 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102744:	6a 00                	push   $0x0
  pushl $143
c0102746:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010274b:	e9 ac fa ff ff       	jmp    c01021fc <__alltraps>

c0102750 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102750:	6a 00                	push   $0x0
  pushl $144
c0102752:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102757:	e9 a0 fa ff ff       	jmp    c01021fc <__alltraps>

c010275c <vector145>:
.globl vector145
vector145:
  pushl $0
c010275c:	6a 00                	push   $0x0
  pushl $145
c010275e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102763:	e9 94 fa ff ff       	jmp    c01021fc <__alltraps>

c0102768 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102768:	6a 00                	push   $0x0
  pushl $146
c010276a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010276f:	e9 88 fa ff ff       	jmp    c01021fc <__alltraps>

c0102774 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102774:	6a 00                	push   $0x0
  pushl $147
c0102776:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010277b:	e9 7c fa ff ff       	jmp    c01021fc <__alltraps>

c0102780 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102780:	6a 00                	push   $0x0
  pushl $148
c0102782:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102787:	e9 70 fa ff ff       	jmp    c01021fc <__alltraps>

c010278c <vector149>:
.globl vector149
vector149:
  pushl $0
c010278c:	6a 00                	push   $0x0
  pushl $149
c010278e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102793:	e9 64 fa ff ff       	jmp    c01021fc <__alltraps>

c0102798 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102798:	6a 00                	push   $0x0
  pushl $150
c010279a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010279f:	e9 58 fa ff ff       	jmp    c01021fc <__alltraps>

c01027a4 <vector151>:
.globl vector151
vector151:
  pushl $0
c01027a4:	6a 00                	push   $0x0
  pushl $151
c01027a6:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01027ab:	e9 4c fa ff ff       	jmp    c01021fc <__alltraps>

c01027b0 <vector152>:
.globl vector152
vector152:
  pushl $0
c01027b0:	6a 00                	push   $0x0
  pushl $152
c01027b2:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01027b7:	e9 40 fa ff ff       	jmp    c01021fc <__alltraps>

c01027bc <vector153>:
.globl vector153
vector153:
  pushl $0
c01027bc:	6a 00                	push   $0x0
  pushl $153
c01027be:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01027c3:	e9 34 fa ff ff       	jmp    c01021fc <__alltraps>

c01027c8 <vector154>:
.globl vector154
vector154:
  pushl $0
c01027c8:	6a 00                	push   $0x0
  pushl $154
c01027ca:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01027cf:	e9 28 fa ff ff       	jmp    c01021fc <__alltraps>

c01027d4 <vector155>:
.globl vector155
vector155:
  pushl $0
c01027d4:	6a 00                	push   $0x0
  pushl $155
c01027d6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01027db:	e9 1c fa ff ff       	jmp    c01021fc <__alltraps>

c01027e0 <vector156>:
.globl vector156
vector156:
  pushl $0
c01027e0:	6a 00                	push   $0x0
  pushl $156
c01027e2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01027e7:	e9 10 fa ff ff       	jmp    c01021fc <__alltraps>

c01027ec <vector157>:
.globl vector157
vector157:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $157
c01027ee:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01027f3:	e9 04 fa ff ff       	jmp    c01021fc <__alltraps>

c01027f8 <vector158>:
.globl vector158
vector158:
  pushl $0
c01027f8:	6a 00                	push   $0x0
  pushl $158
c01027fa:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01027ff:	e9 f8 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102804 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102804:	6a 00                	push   $0x0
  pushl $159
c0102806:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010280b:	e9 ec f9 ff ff       	jmp    c01021fc <__alltraps>

c0102810 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102810:	6a 00                	push   $0x0
  pushl $160
c0102812:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102817:	e9 e0 f9 ff ff       	jmp    c01021fc <__alltraps>

c010281c <vector161>:
.globl vector161
vector161:
  pushl $0
c010281c:	6a 00                	push   $0x0
  pushl $161
c010281e:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102823:	e9 d4 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102828 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102828:	6a 00                	push   $0x0
  pushl $162
c010282a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010282f:	e9 c8 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102834 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102834:	6a 00                	push   $0x0
  pushl $163
c0102836:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010283b:	e9 bc f9 ff ff       	jmp    c01021fc <__alltraps>

c0102840 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102840:	6a 00                	push   $0x0
  pushl $164
c0102842:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102847:	e9 b0 f9 ff ff       	jmp    c01021fc <__alltraps>

c010284c <vector165>:
.globl vector165
vector165:
  pushl $0
c010284c:	6a 00                	push   $0x0
  pushl $165
c010284e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102853:	e9 a4 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102858 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $166
c010285a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010285f:	e9 98 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102864 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102864:	6a 00                	push   $0x0
  pushl $167
c0102866:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010286b:	e9 8c f9 ff ff       	jmp    c01021fc <__alltraps>

c0102870 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102870:	6a 00                	push   $0x0
  pushl $168
c0102872:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102877:	e9 80 f9 ff ff       	jmp    c01021fc <__alltraps>

c010287c <vector169>:
.globl vector169
vector169:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $169
c010287e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102883:	e9 74 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102888 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102888:	6a 00                	push   $0x0
  pushl $170
c010288a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010288f:	e9 68 f9 ff ff       	jmp    c01021fc <__alltraps>

c0102894 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102894:	6a 00                	push   $0x0
  pushl $171
c0102896:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010289b:	e9 5c f9 ff ff       	jmp    c01021fc <__alltraps>

c01028a0 <vector172>:
.globl vector172
vector172:
  pushl $0
c01028a0:	6a 00                	push   $0x0
  pushl $172
c01028a2:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01028a7:	e9 50 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028ac <vector173>:
.globl vector173
vector173:
  pushl $0
c01028ac:	6a 00                	push   $0x0
  pushl $173
c01028ae:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01028b3:	e9 44 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028b8 <vector174>:
.globl vector174
vector174:
  pushl $0
c01028b8:	6a 00                	push   $0x0
  pushl $174
c01028ba:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01028bf:	e9 38 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028c4 <vector175>:
.globl vector175
vector175:
  pushl $0
c01028c4:	6a 00                	push   $0x0
  pushl $175
c01028c6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01028cb:	e9 2c f9 ff ff       	jmp    c01021fc <__alltraps>

c01028d0 <vector176>:
.globl vector176
vector176:
  pushl $0
c01028d0:	6a 00                	push   $0x0
  pushl $176
c01028d2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01028d7:	e9 20 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028dc <vector177>:
.globl vector177
vector177:
  pushl $0
c01028dc:	6a 00                	push   $0x0
  pushl $177
c01028de:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01028e3:	e9 14 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028e8 <vector178>:
.globl vector178
vector178:
  pushl $0
c01028e8:	6a 00                	push   $0x0
  pushl $178
c01028ea:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01028ef:	e9 08 f9 ff ff       	jmp    c01021fc <__alltraps>

c01028f4 <vector179>:
.globl vector179
vector179:
  pushl $0
c01028f4:	6a 00                	push   $0x0
  pushl $179
c01028f6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01028fb:	e9 fc f8 ff ff       	jmp    c01021fc <__alltraps>

c0102900 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102900:	6a 00                	push   $0x0
  pushl $180
c0102902:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102907:	e9 f0 f8 ff ff       	jmp    c01021fc <__alltraps>

c010290c <vector181>:
.globl vector181
vector181:
  pushl $0
c010290c:	6a 00                	push   $0x0
  pushl $181
c010290e:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102913:	e9 e4 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102918 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102918:	6a 00                	push   $0x0
  pushl $182
c010291a:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010291f:	e9 d8 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102924 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102924:	6a 00                	push   $0x0
  pushl $183
c0102926:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010292b:	e9 cc f8 ff ff       	jmp    c01021fc <__alltraps>

c0102930 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102930:	6a 00                	push   $0x0
  pushl $184
c0102932:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102937:	e9 c0 f8 ff ff       	jmp    c01021fc <__alltraps>

c010293c <vector185>:
.globl vector185
vector185:
  pushl $0
c010293c:	6a 00                	push   $0x0
  pushl $185
c010293e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102943:	e9 b4 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102948 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102948:	6a 00                	push   $0x0
  pushl $186
c010294a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010294f:	e9 a8 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102954 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102954:	6a 00                	push   $0x0
  pushl $187
c0102956:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010295b:	e9 9c f8 ff ff       	jmp    c01021fc <__alltraps>

c0102960 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102960:	6a 00                	push   $0x0
  pushl $188
c0102962:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102967:	e9 90 f8 ff ff       	jmp    c01021fc <__alltraps>

c010296c <vector189>:
.globl vector189
vector189:
  pushl $0
c010296c:	6a 00                	push   $0x0
  pushl $189
c010296e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102973:	e9 84 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102978 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102978:	6a 00                	push   $0x0
  pushl $190
c010297a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010297f:	e9 78 f8 ff ff       	jmp    c01021fc <__alltraps>

c0102984 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102984:	6a 00                	push   $0x0
  pushl $191
c0102986:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010298b:	e9 6c f8 ff ff       	jmp    c01021fc <__alltraps>

c0102990 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102990:	6a 00                	push   $0x0
  pushl $192
c0102992:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102997:	e9 60 f8 ff ff       	jmp    c01021fc <__alltraps>

c010299c <vector193>:
.globl vector193
vector193:
  pushl $0
c010299c:	6a 00                	push   $0x0
  pushl $193
c010299e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01029a3:	e9 54 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029a8 <vector194>:
.globl vector194
vector194:
  pushl $0
c01029a8:	6a 00                	push   $0x0
  pushl $194
c01029aa:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01029af:	e9 48 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029b4 <vector195>:
.globl vector195
vector195:
  pushl $0
c01029b4:	6a 00                	push   $0x0
  pushl $195
c01029b6:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01029bb:	e9 3c f8 ff ff       	jmp    c01021fc <__alltraps>

c01029c0 <vector196>:
.globl vector196
vector196:
  pushl $0
c01029c0:	6a 00                	push   $0x0
  pushl $196
c01029c2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01029c7:	e9 30 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029cc <vector197>:
.globl vector197
vector197:
  pushl $0
c01029cc:	6a 00                	push   $0x0
  pushl $197
c01029ce:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01029d3:	e9 24 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029d8 <vector198>:
.globl vector198
vector198:
  pushl $0
c01029d8:	6a 00                	push   $0x0
  pushl $198
c01029da:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01029df:	e9 18 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029e4 <vector199>:
.globl vector199
vector199:
  pushl $0
c01029e4:	6a 00                	push   $0x0
  pushl $199
c01029e6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01029eb:	e9 0c f8 ff ff       	jmp    c01021fc <__alltraps>

c01029f0 <vector200>:
.globl vector200
vector200:
  pushl $0
c01029f0:	6a 00                	push   $0x0
  pushl $200
c01029f2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01029f7:	e9 00 f8 ff ff       	jmp    c01021fc <__alltraps>

c01029fc <vector201>:
.globl vector201
vector201:
  pushl $0
c01029fc:	6a 00                	push   $0x0
  pushl $201
c01029fe:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102a03:	e9 f4 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a08 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102a08:	6a 00                	push   $0x0
  pushl $202
c0102a0a:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102a0f:	e9 e8 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a14 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102a14:	6a 00                	push   $0x0
  pushl $203
c0102a16:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102a1b:	e9 dc f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a20 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102a20:	6a 00                	push   $0x0
  pushl $204
c0102a22:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102a27:	e9 d0 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a2c <vector205>:
.globl vector205
vector205:
  pushl $0
c0102a2c:	6a 00                	push   $0x0
  pushl $205
c0102a2e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102a33:	e9 c4 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a38 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102a38:	6a 00                	push   $0x0
  pushl $206
c0102a3a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102a3f:	e9 b8 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a44 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102a44:	6a 00                	push   $0x0
  pushl $207
c0102a46:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102a4b:	e9 ac f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a50 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102a50:	6a 00                	push   $0x0
  pushl $208
c0102a52:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102a57:	e9 a0 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a5c <vector209>:
.globl vector209
vector209:
  pushl $0
c0102a5c:	6a 00                	push   $0x0
  pushl $209
c0102a5e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102a63:	e9 94 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a68 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102a68:	6a 00                	push   $0x0
  pushl $210
c0102a6a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102a6f:	e9 88 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a74 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102a74:	6a 00                	push   $0x0
  pushl $211
c0102a76:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102a7b:	e9 7c f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a80 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102a80:	6a 00                	push   $0x0
  pushl $212
c0102a82:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102a87:	e9 70 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a8c <vector213>:
.globl vector213
vector213:
  pushl $0
c0102a8c:	6a 00                	push   $0x0
  pushl $213
c0102a8e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102a93:	e9 64 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102a98 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102a98:	6a 00                	push   $0x0
  pushl $214
c0102a9a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102a9f:	e9 58 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102aa4 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102aa4:	6a 00                	push   $0x0
  pushl $215
c0102aa6:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102aab:	e9 4c f7 ff ff       	jmp    c01021fc <__alltraps>

c0102ab0 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102ab0:	6a 00                	push   $0x0
  pushl $216
c0102ab2:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102ab7:	e9 40 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102abc <vector217>:
.globl vector217
vector217:
  pushl $0
c0102abc:	6a 00                	push   $0x0
  pushl $217
c0102abe:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102ac3:	e9 34 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102ac8 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102ac8:	6a 00                	push   $0x0
  pushl $218
c0102aca:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102acf:	e9 28 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102ad4 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102ad4:	6a 00                	push   $0x0
  pushl $219
c0102ad6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102adb:	e9 1c f7 ff ff       	jmp    c01021fc <__alltraps>

c0102ae0 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102ae0:	6a 00                	push   $0x0
  pushl $220
c0102ae2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102ae7:	e9 10 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102aec <vector221>:
.globl vector221
vector221:
  pushl $0
c0102aec:	6a 00                	push   $0x0
  pushl $221
c0102aee:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102af3:	e9 04 f7 ff ff       	jmp    c01021fc <__alltraps>

c0102af8 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102af8:	6a 00                	push   $0x0
  pushl $222
c0102afa:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102aff:	e9 f8 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b04 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102b04:	6a 00                	push   $0x0
  pushl $223
c0102b06:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102b0b:	e9 ec f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b10 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102b10:	6a 00                	push   $0x0
  pushl $224
c0102b12:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102b17:	e9 e0 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b1c <vector225>:
.globl vector225
vector225:
  pushl $0
c0102b1c:	6a 00                	push   $0x0
  pushl $225
c0102b1e:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102b23:	e9 d4 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b28 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102b28:	6a 00                	push   $0x0
  pushl $226
c0102b2a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102b2f:	e9 c8 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b34 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102b34:	6a 00                	push   $0x0
  pushl $227
c0102b36:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102b3b:	e9 bc f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b40 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102b40:	6a 00                	push   $0x0
  pushl $228
c0102b42:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102b47:	e9 b0 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b4c <vector229>:
.globl vector229
vector229:
  pushl $0
c0102b4c:	6a 00                	push   $0x0
  pushl $229
c0102b4e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102b53:	e9 a4 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b58 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102b58:	6a 00                	push   $0x0
  pushl $230
c0102b5a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102b5f:	e9 98 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b64 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $231
c0102b66:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102b6b:	e9 8c f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b70 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102b70:	6a 00                	push   $0x0
  pushl $232
c0102b72:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102b77:	e9 80 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b7c <vector233>:
.globl vector233
vector233:
  pushl $0
c0102b7c:	6a 00                	push   $0x0
  pushl $233
c0102b7e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102b83:	e9 74 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b88 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $234
c0102b8a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102b8f:	e9 68 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102b94 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102b94:	6a 00                	push   $0x0
  pushl $235
c0102b96:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102b9b:	e9 5c f6 ff ff       	jmp    c01021fc <__alltraps>

c0102ba0 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102ba0:	6a 00                	push   $0x0
  pushl $236
c0102ba2:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102ba7:	e9 50 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bac <vector237>:
.globl vector237
vector237:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $237
c0102bae:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102bb3:	e9 44 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bb8 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102bb8:	6a 00                	push   $0x0
  pushl $238
c0102bba:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102bbf:	e9 38 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bc4 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102bc4:	6a 00                	push   $0x0
  pushl $239
c0102bc6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102bcb:	e9 2c f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bd0 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $240
c0102bd2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102bd7:	e9 20 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bdc <vector241>:
.globl vector241
vector241:
  pushl $0
c0102bdc:	6a 00                	push   $0x0
  pushl $241
c0102bde:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102be3:	e9 14 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102be8 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102be8:	6a 00                	push   $0x0
  pushl $242
c0102bea:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102bef:	e9 08 f6 ff ff       	jmp    c01021fc <__alltraps>

c0102bf4 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $243
c0102bf6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102bfb:	e9 fc f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c00 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $244
c0102c02:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102c07:	e9 f0 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c0c <vector245>:
.globl vector245
vector245:
  pushl $0
c0102c0c:	6a 00                	push   $0x0
  pushl $245
c0102c0e:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102c13:	e9 e4 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c18 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $246
c0102c1a:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102c1f:	e9 d8 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c24 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102c24:	6a 00                	push   $0x0
  pushl $247
c0102c26:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102c2b:	e9 cc f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c30 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $248
c0102c32:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102c37:	e9 c0 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c3c <vector249>:
.globl vector249
vector249:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $249
c0102c3e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102c43:	e9 b4 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c48 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $250
c0102c4a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102c4f:	e9 a8 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c54 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102c54:	6a 00                	push   $0x0
  pushl $251
c0102c56:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102c5b:	e9 9c f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c60 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $252
c0102c62:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102c67:	e9 90 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c6c <vector253>:
.globl vector253
vector253:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $253
c0102c6e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102c73:	e9 84 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c78 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102c78:	6a 00                	push   $0x0
  pushl $254
c0102c7a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102c7f:	e9 78 f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c84 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $255
c0102c86:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102c8b:	e9 6c f5 ff ff       	jmp    c01021fc <__alltraps>

c0102c90 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102c90:	55                   	push   %ebp
c0102c91:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102c93:	8b 15 00 cf 11 c0    	mov    0xc011cf00,%edx
c0102c99:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c9c:	29 d0                	sub    %edx,%eax
c0102c9e:	c1 f8 02             	sar    $0x2,%eax
c0102ca1:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102ca7:	5d                   	pop    %ebp
c0102ca8:	c3                   	ret    

c0102ca9 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102ca9:	55                   	push   %ebp
c0102caa:	89 e5                	mov    %esp,%ebp
c0102cac:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cb2:	89 04 24             	mov    %eax,(%esp)
c0102cb5:	e8 d6 ff ff ff       	call   c0102c90 <page2ppn>
c0102cba:	c1 e0 0c             	shl    $0xc,%eax
}
c0102cbd:	89 ec                	mov    %ebp,%esp
c0102cbf:	5d                   	pop    %ebp
c0102cc0:	c3                   	ret    

c0102cc1 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102cc1:	55                   	push   %ebp
c0102cc2:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cc7:	8b 00                	mov    (%eax),%eax
}
c0102cc9:	5d                   	pop    %ebp
c0102cca:	c3                   	ret    

c0102ccb <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102ccb:	55                   	push   %ebp
c0102ccc:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cd4:	89 10                	mov    %edx,(%eax)
}
c0102cd6:	90                   	nop
c0102cd7:	5d                   	pop    %ebp
c0102cd8:	c3                   	ret    

c0102cd9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102cd9:	55                   	push   %ebp
c0102cda:	89 e5                	mov    %esp,%ebp
c0102cdc:	83 ec 10             	sub    $0x10,%esp
c0102cdf:	c7 45 fc e0 ce 11 c0 	movl   $0xc011cee0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102ce6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102ce9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102cec:	89 50 04             	mov    %edx,0x4(%eax)
c0102cef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102cf2:	8b 50 04             	mov    0x4(%eax),%edx
c0102cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102cf8:	89 10                	mov    %edx,(%eax)
}
c0102cfa:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0102cfb:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c0102d02:	00 00 00 
}
c0102d05:	90                   	nop
c0102d06:	89 ec                	mov    %ebp,%esp
c0102d08:	5d                   	pop    %ebp
c0102d09:	c3                   	ret    

c0102d0a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102d0a:	55                   	push   %ebp
c0102d0b:	89 e5                	mov    %esp,%ebp
c0102d0d:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0102d10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102d14:	75 24                	jne    c0102d3a <default_init_memmap+0x30>
c0102d16:	c7 44 24 0c 70 6b 10 	movl   $0xc0106b70,0xc(%esp)
c0102d1d:	c0 
c0102d1e:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0102d25:	c0 
c0102d26:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102d2d:	00 
c0102d2e:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0102d35:	e8 e3 df ff ff       	call   c0100d1d <__panic>
    struct Page *p = base;
c0102d3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102d40:	eb 7d                	jmp    c0102dbf <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d45:	83 c0 04             	add    $0x4,%eax
c0102d48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102d4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d55:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102d58:	0f a3 10             	bt     %edx,(%eax)
c0102d5b:	19 c0                	sbb    %eax,%eax
c0102d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102d60:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102d64:	0f 95 c0             	setne  %al
c0102d67:	0f b6 c0             	movzbl %al,%eax
c0102d6a:	85 c0                	test   %eax,%eax
c0102d6c:	75 24                	jne    c0102d92 <default_init_memmap+0x88>
c0102d6e:	c7 44 24 0c a1 6b 10 	movl   $0xc0106ba1,0xc(%esp)
c0102d75:	c0 
c0102d76:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0102d7d:	c0 
c0102d7e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102d85:	00 
c0102d86:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0102d8d:	e8 8b df ff ff       	call   c0100d1d <__panic>
        p->flags = p->property = 0;
c0102d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d9f:	8b 50 08             	mov    0x8(%eax),%edx
c0102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102da5:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102daf:	00 
c0102db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102db3:	89 04 24             	mov    %eax,(%esp)
c0102db6:	e8 10 ff ff ff       	call   c0102ccb <set_page_ref>
    for (; p != base + n; p ++) {
c0102dbb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102dc2:	89 d0                	mov    %edx,%eax
c0102dc4:	c1 e0 02             	shl    $0x2,%eax
c0102dc7:	01 d0                	add    %edx,%eax
c0102dc9:	c1 e0 02             	shl    $0x2,%eax
c0102dcc:	89 c2                	mov    %eax,%edx
c0102dce:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dd1:	01 d0                	add    %edx,%eax
c0102dd3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102dd6:	0f 85 66 ff ff ff    	jne    c0102d42 <default_init_memmap+0x38>
    }
    base->property = n;
c0102ddc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102de2:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102de5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102de8:	83 c0 04             	add    $0x4,%eax
c0102deb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102df2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102df5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102df8:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102dfb:	0f ab 10             	bts    %edx,(%eax)
}
c0102dfe:	90                   	nop
    nr_free += n;
c0102dff:	8b 15 e8 ce 11 c0    	mov    0xc011cee8,%edx
c0102e05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e08:	01 d0                	add    %edx,%eax
c0102e0a:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
    list_add(&free_list, &(base->page_link));
c0102e0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e12:	83 c0 0c             	add    $0xc,%eax
c0102e15:	c7 45 e4 e0 ce 11 c0 	movl   $0xc011cee0,-0x1c(%ebp)
c0102e1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102e22:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e28:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102e2e:	8b 40 04             	mov    0x4(%eax),%eax
c0102e31:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102e34:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102e37:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e3a:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102e3d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102e40:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102e43:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102e46:	89 10                	mov    %edx,(%eax)
c0102e48:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102e4b:	8b 10                	mov    (%eax),%edx
c0102e4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102e50:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102e56:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102e59:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102e5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102e5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102e62:	89 10                	mov    %edx,(%eax)
}
c0102e64:	90                   	nop
}
c0102e65:	90                   	nop
}
c0102e66:	90                   	nop
}
c0102e67:	90                   	nop
c0102e68:	89 ec                	mov    %ebp,%esp
c0102e6a:	5d                   	pop    %ebp
c0102e6b:	c3                   	ret    

c0102e6c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102e6c:	55                   	push   %ebp
c0102e6d:	89 e5                	mov    %esp,%ebp
c0102e6f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102e72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102e76:	75 24                	jne    c0102e9c <default_alloc_pages+0x30>
c0102e78:	c7 44 24 0c 70 6b 10 	movl   $0xc0106b70,0xc(%esp)
c0102e7f:	c0 
c0102e80:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0102e87:	c0 
c0102e88:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102e8f:	00 
c0102e90:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0102e97:	e8 81 de ff ff       	call   c0100d1d <__panic>
    if (n > nr_free) {
c0102e9c:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0102ea1:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102ea4:	76 0a                	jbe    c0102eb0 <default_alloc_pages+0x44>
        return NULL;
c0102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
c0102eab:	e9 4e 01 00 00       	jmp    c0102ffe <default_alloc_pages+0x192>
    }
    struct Page *page = NULL;
c0102eb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    //开始遍历空闲链表
    list_entry_t *le = &free_list;
c0102eb7:	c7 45 f0 e0 ce 11 c0 	movl   $0xc011cee0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102ebe:	eb 1c                	jmp    c0102edc <default_alloc_pages+0x70>
    	//找到当前链表指向的页表，如果这个内存页数大于我们需要的页数，则直接从这个内存块取n页
        struct Page *p = le2page(le, page_link);
c0102ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ec3:	83 e8 0c             	sub    $0xc,%eax
c0102ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ecc:	8b 40 08             	mov    0x8(%eax),%eax
c0102ecf:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102ed2:	77 08                	ja     c0102edc <default_alloc_pages+0x70>
            page = p;
c0102ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            //SetPageReserved(page);
            break;
c0102eda:	eb 18                	jmp    c0102ef4 <default_alloc_pages+0x88>
c0102edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102edf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0102ee2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102ee5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0102ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102eeb:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c0102ef2:	75 cc                	jne    c0102ec0 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0102ef4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102ef8:	0f 84 fd 00 00 00    	je     c0102ffb <default_alloc_pages+0x18f>
        //list_del(&(page->page_link));
        if (page->property > n) {
c0102efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f01:	8b 40 08             	mov    0x8(%eax),%eax
c0102f04:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102f07:	0f 83 9a 00 00 00    	jae    c0102fa7 <default_alloc_pages+0x13b>
        	//因为我们取了n页，内存块可能还有部分内存页，需要当前内存块头偏移n个`Page`位置就是
        	//内存块剩下的页组成新的内存块结构，新的页头描述这个小内存块
            struct Page *p = page + n;
c0102f0d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102f10:	89 d0                	mov    %edx,%eax
c0102f12:	c1 e0 02             	shl    $0x2,%eax
c0102f15:	01 d0                	add    %edx,%eax
c0102f17:	c1 e0 02             	shl    $0x2,%eax
c0102f1a:	89 c2                	mov    %eax,%edx
c0102f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f1f:	01 d0                	add    %edx,%eax
c0102f21:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f27:	8b 40 08             	mov    0x8(%eax),%eax
c0102f2a:	2b 45 08             	sub    0x8(%ebp),%eax
c0102f2d:	89 c2                	mov    %eax,%edx
c0102f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102f32:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);//记得做这步，把property设为1，否则出错
c0102f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102f38:	83 c0 04             	add    $0x4,%eax
c0102f3b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102f42:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102f45:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102f48:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102f4b:	0f ab 10             	bts    %edx,(%eax)
}
c0102f4e:	90                   	nop
            //ClearPageReserved(p);
            //往空闲链表里加入这个新的小内存
            list_add(&free_list, &(p->page_link));
c0102f4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102f52:	83 c0 0c             	add    $0xc,%eax
c0102f55:	c7 45 e0 e0 ce 11 c0 	movl   $0xc011cee0,-0x20(%ebp)
c0102f5c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f62:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102f65:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102f68:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102f6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102f6e:	8b 40 04             	mov    0x4(%eax),%eax
c0102f71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f74:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102f77:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102f7a:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102f7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0102f80:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f83:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f86:	89 10                	mov    %edx,(%eax)
c0102f88:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f8b:	8b 10                	mov    (%eax),%edx
c0102f8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102f90:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102f93:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f96:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102f99:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f9f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102fa2:	89 10                	mov    %edx,(%eax)
}
c0102fa4:	90                   	nop
}
c0102fa5:	90                   	nop
}
c0102fa6:	90                   	nop
    }
        list_del(&(page->page_link));
c0102fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102faa:	83 c0 0c             	add    $0xc,%eax
c0102fad:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102fb0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102fb3:	8b 40 04             	mov    0x4(%eax),%eax
c0102fb6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102fb9:	8b 12                	mov    (%edx),%edx
c0102fbb:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0102fbe:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102fc1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102fc4:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102fc7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102fca:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102fcd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102fd0:	89 10                	mov    %edx,(%eax)
}
c0102fd2:	90                   	nop
}
c0102fd3:	90                   	nop
        nr_free -= n;
c0102fd4:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0102fd9:	2b 45 08             	sub    0x8(%ebp),%eax
c0102fdc:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
        ClearPageProperty(page);
c0102fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fe4:	83 c0 04             	add    $0x4,%eax
c0102fe7:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0102fee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ff1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ff4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102ff7:	0f b3 10             	btr    %edx,(%eax)
}
c0102ffa:	90                   	nop
    }
    return page;
c0102ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102ffe:	89 ec                	mov    %ebp,%esp
c0103000:	5d                   	pop    %ebp
c0103001:	c3                   	ret    

c0103002 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103002:	55                   	push   %ebp
c0103003:	89 e5                	mov    %esp,%ebp
c0103005:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010300b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010300f:	75 24                	jne    c0103035 <default_free_pages+0x33>
c0103011:	c7 44 24 0c 70 6b 10 	movl   $0xc0106b70,0xc(%esp)
c0103018:	c0 
c0103019:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103020:	c0 
c0103021:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0103028:	00 
c0103029:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103030:	e8 e8 dc ff ff       	call   c0100d1d <__panic>
    struct Page *p = base;
c0103035:	8b 45 08             	mov    0x8(%ebp),%eax
c0103038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //首先遍历页表，把flags全部置0，并将ref清0，说明此时没有逻辑地址引用这块内存
    for (; p != base + n; p ++) {
c010303b:	e9 9d 00 00 00       	jmp    c01030dd <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103043:	83 c0 04             	add    $0x4,%eax
c0103046:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010304d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103050:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103053:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103056:	0f a3 10             	bt     %edx,(%eax)
c0103059:	19 c0                	sbb    %eax,%eax
c010305b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010305e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103062:	0f 95 c0             	setne  %al
c0103065:	0f b6 c0             	movzbl %al,%eax
c0103068:	85 c0                	test   %eax,%eax
c010306a:	75 2c                	jne    c0103098 <default_free_pages+0x96>
c010306c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010306f:	83 c0 04             	add    $0x4,%eax
c0103072:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103079:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010307c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010307f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103082:	0f a3 10             	bt     %edx,(%eax)
c0103085:	19 c0                	sbb    %eax,%eax
c0103087:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010308a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010308e:	0f 95 c0             	setne  %al
c0103091:	0f b6 c0             	movzbl %al,%eax
c0103094:	85 c0                	test   %eax,%eax
c0103096:	74 24                	je     c01030bc <default_free_pages+0xba>
c0103098:	c7 44 24 0c b4 6b 10 	movl   $0xc0106bb4,0xc(%esp)
c010309f:	c0 
c01030a0:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01030a7:	c0 
c01030a8:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c01030af:	00 
c01030b0:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01030b7:	e8 61 dc ff ff       	call   c0100d1d <__panic>
        p->flags = 0;
c01030bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030bf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01030c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01030cd:	00 
c01030ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030d1:	89 04 24             	mov    %eax,(%esp)
c01030d4:	e8 f2 fb ff ff       	call   c0102ccb <set_page_ref>
    for (; p != base + n; p ++) {
c01030d9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01030dd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01030e0:	89 d0                	mov    %edx,%eax
c01030e2:	c1 e0 02             	shl    $0x2,%eax
c01030e5:	01 d0                	add    %edx,%eax
c01030e7:	c1 e0 02             	shl    $0x2,%eax
c01030ea:	89 c2                	mov    %eax,%edx
c01030ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01030ef:	01 d0                	add    %edx,%eax
c01030f1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01030f4:	0f 85 46 ff ff ff    	jne    c0103040 <default_free_pages+0x3e>
    }
    //同样的道理，我释放了n页，那么个n页形成新的一个大一点的内存块，我们需要设置这个内存块的第一个
    //页表描述内存块里有多少个页
    base->property = n;
c01030fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01030fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103100:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103103:	8b 45 08             	mov    0x8(%ebp),%eax
c0103106:	83 c0 04             	add    $0x4,%eax
c0103109:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103110:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103113:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103116:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103119:	0f ab 10             	bts    %edx,(%eax)
}
c010311c:	90                   	nop
c010311d:	c7 45 d4 e0 ce 11 c0 	movl   $0xc011cee0,-0x2c(%ebp)
    return listelm->next;
c0103124:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103127:	8b 40 04             	mov    0x4(%eax),%eax
    //遍历空闲链表，目的找到有没有地址空间是连在一起的内存块，把他们合并
    list_entry_t *le = list_next(&free_list);
c010312a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010312d:	e9 0e 01 00 00       	jmp    c0103240 <default_free_pages+0x23e>
        p = le2page(le, page_link);
c0103132:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103135:	83 e8 0c             	sub    $0xc,%eax
c0103138:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010313b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010313e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103141:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103144:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103147:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c010314a:	8b 45 08             	mov    0x8(%ebp),%eax
c010314d:	8b 50 08             	mov    0x8(%eax),%edx
c0103150:	89 d0                	mov    %edx,%eax
c0103152:	c1 e0 02             	shl    $0x2,%eax
c0103155:	01 d0                	add    %edx,%eax
c0103157:	c1 e0 02             	shl    $0x2,%eax
c010315a:	89 c2                	mov    %eax,%edx
c010315c:	8b 45 08             	mov    0x8(%ebp),%eax
c010315f:	01 d0                	add    %edx,%eax
c0103161:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103164:	75 5d                	jne    c01031c3 <default_free_pages+0x1c1>
            base->property += p->property;
c0103166:	8b 45 08             	mov    0x8(%ebp),%eax
c0103169:	8b 50 08             	mov    0x8(%eax),%edx
c010316c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010316f:	8b 40 08             	mov    0x8(%eax),%eax
c0103172:	01 c2                	add    %eax,%edx
c0103174:	8b 45 08             	mov    0x8(%ebp),%eax
c0103177:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010317a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010317d:	83 c0 04             	add    $0x4,%eax
c0103180:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103187:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010318a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010318d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103190:	0f b3 10             	btr    %edx,(%eax)
}
c0103193:	90                   	nop
            list_del(&(p->page_link));
c0103194:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103197:	83 c0 0c             	add    $0xc,%eax
c010319a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010319d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01031a0:	8b 40 04             	mov    0x4(%eax),%eax
c01031a3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01031a6:	8b 12                	mov    (%edx),%edx
c01031a8:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01031ab:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01031ae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01031b1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01031b4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01031b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01031ba:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01031bd:	89 10                	mov    %edx,(%eax)
}
c01031bf:	90                   	nop
}
c01031c0:	90                   	nop
c01031c1:	eb 7d                	jmp    c0103240 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
c01031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031c6:	8b 50 08             	mov    0x8(%eax),%edx
c01031c9:	89 d0                	mov    %edx,%eax
c01031cb:	c1 e0 02             	shl    $0x2,%eax
c01031ce:	01 d0                	add    %edx,%eax
c01031d0:	c1 e0 02             	shl    $0x2,%eax
c01031d3:	89 c2                	mov    %eax,%edx
c01031d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031d8:	01 d0                	add    %edx,%eax
c01031da:	39 45 08             	cmp    %eax,0x8(%ebp)
c01031dd:	75 61                	jne    c0103240 <default_free_pages+0x23e>
            p->property += base->property;
c01031df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031e2:	8b 50 08             	mov    0x8(%eax),%edx
c01031e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01031e8:	8b 40 08             	mov    0x8(%eax),%eax
c01031eb:	01 c2                	add    %eax,%edx
c01031ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031f0:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01031f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01031f6:	83 c0 04             	add    $0x4,%eax
c01031f9:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0103200:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103203:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103206:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103209:	0f b3 10             	btr    %edx,(%eax)
}
c010320c:	90                   	nop
            base = p;
c010320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103210:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103213:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103216:	83 c0 0c             	add    $0xc,%eax
c0103219:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010321c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010321f:	8b 40 04             	mov    0x4(%eax),%eax
c0103222:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103225:	8b 12                	mov    (%edx),%edx
c0103227:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010322a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010322d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103230:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103233:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103236:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103239:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010323c:	89 10                	mov    %edx,(%eax)
}
c010323e:	90                   	nop
}
c010323f:	90                   	nop
    while (le != &free_list) {
c0103240:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c0103247:	0f 85 e5 fe ff ff    	jne    c0103132 <default_free_pages+0x130>
        }
    }
    nr_free += n;
c010324d:	8b 15 e8 ce 11 c0    	mov    0xc011cee8,%edx
c0103253:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103256:	01 d0                	add    %edx,%eax
c0103258:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
c010325d:	c7 45 9c e0 ce 11 c0 	movl   $0xc011cee0,-0x64(%ebp)
    return listelm->next;
c0103264:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103267:	8b 40 04             	mov    0x4(%eax),%eax
    //遍历空闲链表，因为空闲链表是from low to high
    //只需要遍历找打第一个地址比他高的，把释放的内存插入到他前面就行
    le = list_next(&free_list);
c010326a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010326d:	eb 74                	jmp    c01032e3 <default_free_pages+0x2e1>
        p = le2page(le, page_link);
c010326f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103272:	83 e8 0c             	sub    $0xc,%eax
c0103275:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103278:	8b 45 08             	mov    0x8(%ebp),%eax
c010327b:	8b 50 08             	mov    0x8(%eax),%edx
c010327e:	89 d0                	mov    %edx,%eax
c0103280:	c1 e0 02             	shl    $0x2,%eax
c0103283:	01 d0                	add    %edx,%eax
c0103285:	c1 e0 02             	shl    $0x2,%eax
c0103288:	89 c2                	mov    %eax,%edx
c010328a:	8b 45 08             	mov    0x8(%ebp),%eax
c010328d:	01 d0                	add    %edx,%eax
c010328f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103292:	72 40                	jb     c01032d4 <default_free_pages+0x2d2>
            assert(base + base->property != p);
c0103294:	8b 45 08             	mov    0x8(%ebp),%eax
c0103297:	8b 50 08             	mov    0x8(%eax),%edx
c010329a:	89 d0                	mov    %edx,%eax
c010329c:	c1 e0 02             	shl    $0x2,%eax
c010329f:	01 d0                	add    %edx,%eax
c01032a1:	c1 e0 02             	shl    $0x2,%eax
c01032a4:	89 c2                	mov    %eax,%edx
c01032a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a9:	01 d0                	add    %edx,%eax
c01032ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01032ae:	75 3e                	jne    c01032ee <default_free_pages+0x2ec>
c01032b0:	c7 44 24 0c d9 6b 10 	movl   $0xc0106bd9,0xc(%esp)
c01032b7:	c0 
c01032b8:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01032bf:	c0 
c01032c0:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01032c7:	00 
c01032c8:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01032cf:	e8 49 da ff ff       	call   c0100d1d <__panic>
c01032d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032d7:	89 45 98             	mov    %eax,-0x68(%ebp)
c01032da:	8b 45 98             	mov    -0x68(%ebp),%eax
c01032dd:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01032e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01032e3:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c01032ea:	75 83                	jne    c010326f <default_free_pages+0x26d>
c01032ec:	eb 01                	jmp    c01032ef <default_free_pages+0x2ed>
            break;
c01032ee:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c01032ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01032f2:	8d 50 0c             	lea    0xc(%eax),%edx
c01032f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032f8:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01032fb:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01032fe:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103301:	8b 00                	mov    (%eax),%eax
c0103303:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103306:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103309:	89 45 88             	mov    %eax,-0x78(%ebp)
c010330c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010330f:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0103312:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103315:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103318:	89 10                	mov    %edx,(%eax)
c010331a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010331d:	8b 10                	mov    (%eax),%edx
c010331f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103322:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103325:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103328:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010332b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010332e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103331:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103334:	89 10                	mov    %edx,(%eax)
}
c0103336:	90                   	nop
}
c0103337:	90                   	nop
}
c0103338:	90                   	nop
c0103339:	89 ec                	mov    %ebp,%esp
c010333b:	5d                   	pop    %ebp
c010333c:	c3                   	ret    

c010333d <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010333d:	55                   	push   %ebp
c010333e:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103340:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
}
c0103345:	5d                   	pop    %ebp
c0103346:	c3                   	ret    

c0103347 <basic_check>:

static void
basic_check(void) {
c0103347:	55                   	push   %ebp
c0103348:	89 e5                	mov    %esp,%ebp
c010334a:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010334d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103354:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103357:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010335a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010335d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103360:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103367:	e8 ed 0e 00 00       	call   c0104259 <alloc_pages>
c010336c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010336f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103373:	75 24                	jne    c0103399 <basic_check+0x52>
c0103375:	c7 44 24 0c f4 6b 10 	movl   $0xc0106bf4,0xc(%esp)
c010337c:	c0 
c010337d:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103384:	c0 
c0103385:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010338c:	00 
c010338d:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103394:	e8 84 d9 ff ff       	call   c0100d1d <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033a0:	e8 b4 0e 00 00       	call   c0104259 <alloc_pages>
c01033a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01033ac:	75 24                	jne    c01033d2 <basic_check+0x8b>
c01033ae:	c7 44 24 0c 10 6c 10 	movl   $0xc0106c10,0xc(%esp)
c01033b5:	c0 
c01033b6:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01033bd:	c0 
c01033be:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01033c5:	00 
c01033c6:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01033cd:	e8 4b d9 ff ff       	call   c0100d1d <__panic>
    assert((p2 = alloc_page()) != NULL);
c01033d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033d9:	e8 7b 0e 00 00       	call   c0104259 <alloc_pages>
c01033de:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033e5:	75 24                	jne    c010340b <basic_check+0xc4>
c01033e7:	c7 44 24 0c 2c 6c 10 	movl   $0xc0106c2c,0xc(%esp)
c01033ee:	c0 
c01033ef:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01033f6:	c0 
c01033f7:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01033fe:	00 
c01033ff:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103406:	e8 12 d9 ff ff       	call   c0100d1d <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c010340b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010340e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103411:	74 10                	je     c0103423 <basic_check+0xdc>
c0103413:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103416:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103419:	74 08                	je     c0103423 <basic_check+0xdc>
c010341b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010341e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103421:	75 24                	jne    c0103447 <basic_check+0x100>
c0103423:	c7 44 24 0c 48 6c 10 	movl   $0xc0106c48,0xc(%esp)
c010342a:	c0 
c010342b:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103432:	c0 
c0103433:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010343a:	00 
c010343b:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103442:	e8 d6 d8 ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103447:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010344a:	89 04 24             	mov    %eax,(%esp)
c010344d:	e8 6f f8 ff ff       	call   c0102cc1 <page_ref>
c0103452:	85 c0                	test   %eax,%eax
c0103454:	75 1e                	jne    c0103474 <basic_check+0x12d>
c0103456:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103459:	89 04 24             	mov    %eax,(%esp)
c010345c:	e8 60 f8 ff ff       	call   c0102cc1 <page_ref>
c0103461:	85 c0                	test   %eax,%eax
c0103463:	75 0f                	jne    c0103474 <basic_check+0x12d>
c0103465:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103468:	89 04 24             	mov    %eax,(%esp)
c010346b:	e8 51 f8 ff ff       	call   c0102cc1 <page_ref>
c0103470:	85 c0                	test   %eax,%eax
c0103472:	74 24                	je     c0103498 <basic_check+0x151>
c0103474:	c7 44 24 0c 6c 6c 10 	movl   $0xc0106c6c,0xc(%esp)
c010347b:	c0 
c010347c:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103483:	c0 
c0103484:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010348b:	00 
c010348c:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103493:	e8 85 d8 ff ff       	call   c0100d1d <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103498:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010349b:	89 04 24             	mov    %eax,(%esp)
c010349e:	e8 06 f8 ff ff       	call   c0102ca9 <page2pa>
c01034a3:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c01034a9:	c1 e2 0c             	shl    $0xc,%edx
c01034ac:	39 d0                	cmp    %edx,%eax
c01034ae:	72 24                	jb     c01034d4 <basic_check+0x18d>
c01034b0:	c7 44 24 0c a8 6c 10 	movl   $0xc0106ca8,0xc(%esp)
c01034b7:	c0 
c01034b8:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01034bf:	c0 
c01034c0:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01034c7:	00 
c01034c8:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01034cf:	e8 49 d8 ff ff       	call   c0100d1d <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01034d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034d7:	89 04 24             	mov    %eax,(%esp)
c01034da:	e8 ca f7 ff ff       	call   c0102ca9 <page2pa>
c01034df:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c01034e5:	c1 e2 0c             	shl    $0xc,%edx
c01034e8:	39 d0                	cmp    %edx,%eax
c01034ea:	72 24                	jb     c0103510 <basic_check+0x1c9>
c01034ec:	c7 44 24 0c c5 6c 10 	movl   $0xc0106cc5,0xc(%esp)
c01034f3:	c0 
c01034f4:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01034fb:	c0 
c01034fc:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103503:	00 
c0103504:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010350b:	e8 0d d8 ff ff       	call   c0100d1d <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103510:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103513:	89 04 24             	mov    %eax,(%esp)
c0103516:	e8 8e f7 ff ff       	call   c0102ca9 <page2pa>
c010351b:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c0103521:	c1 e2 0c             	shl    $0xc,%edx
c0103524:	39 d0                	cmp    %edx,%eax
c0103526:	72 24                	jb     c010354c <basic_check+0x205>
c0103528:	c7 44 24 0c e2 6c 10 	movl   $0xc0106ce2,0xc(%esp)
c010352f:	c0 
c0103530:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103537:	c0 
c0103538:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c010353f:	00 
c0103540:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103547:	e8 d1 d7 ff ff       	call   c0100d1d <__panic>

    list_entry_t free_list_store = free_list;
c010354c:	a1 e0 ce 11 c0       	mov    0xc011cee0,%eax
c0103551:	8b 15 e4 ce 11 c0    	mov    0xc011cee4,%edx
c0103557:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010355a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010355d:	c7 45 dc e0 ce 11 c0 	movl   $0xc011cee0,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103564:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103567:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010356a:	89 50 04             	mov    %edx,0x4(%eax)
c010356d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103570:	8b 50 04             	mov    0x4(%eax),%edx
c0103573:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103576:	89 10                	mov    %edx,(%eax)
}
c0103578:	90                   	nop
c0103579:	c7 45 e0 e0 ce 11 c0 	movl   $0xc011cee0,-0x20(%ebp)
    return list->next == list;
c0103580:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103583:	8b 40 04             	mov    0x4(%eax),%eax
c0103586:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103589:	0f 94 c0             	sete   %al
c010358c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010358f:	85 c0                	test   %eax,%eax
c0103591:	75 24                	jne    c01035b7 <basic_check+0x270>
c0103593:	c7 44 24 0c ff 6c 10 	movl   $0xc0106cff,0xc(%esp)
c010359a:	c0 
c010359b:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01035a2:	c0 
c01035a3:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01035aa:	00 
c01035ab:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01035b2:	e8 66 d7 ff ff       	call   c0100d1d <__panic>

    unsigned int nr_free_store = nr_free;
c01035b7:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c01035bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01035bf:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c01035c6:	00 00 00 

    assert(alloc_page() == NULL);
c01035c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035d0:	e8 84 0c 00 00       	call   c0104259 <alloc_pages>
c01035d5:	85 c0                	test   %eax,%eax
c01035d7:	74 24                	je     c01035fd <basic_check+0x2b6>
c01035d9:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c01035e0:	c0 
c01035e1:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01035e8:	c0 
c01035e9:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01035f0:	00 
c01035f1:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01035f8:	e8 20 d7 ff ff       	call   c0100d1d <__panic>

    free_page(p0);
c01035fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103604:	00 
c0103605:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103608:	89 04 24             	mov    %eax,(%esp)
c010360b:	e8 83 0c 00 00       	call   c0104293 <free_pages>
    free_page(p1);
c0103610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103617:	00 
c0103618:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010361b:	89 04 24             	mov    %eax,(%esp)
c010361e:	e8 70 0c 00 00       	call   c0104293 <free_pages>
    free_page(p2);
c0103623:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010362a:	00 
c010362b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010362e:	89 04 24             	mov    %eax,(%esp)
c0103631:	e8 5d 0c 00 00       	call   c0104293 <free_pages>
    assert(nr_free == 3);
c0103636:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c010363b:	83 f8 03             	cmp    $0x3,%eax
c010363e:	74 24                	je     c0103664 <basic_check+0x31d>
c0103640:	c7 44 24 0c 2b 6d 10 	movl   $0xc0106d2b,0xc(%esp)
c0103647:	c0 
c0103648:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c010364f:	c0 
c0103650:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103657:	00 
c0103658:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010365f:	e8 b9 d6 ff ff       	call   c0100d1d <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010366b:	e8 e9 0b 00 00       	call   c0104259 <alloc_pages>
c0103670:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103673:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103677:	75 24                	jne    c010369d <basic_check+0x356>
c0103679:	c7 44 24 0c f4 6b 10 	movl   $0xc0106bf4,0xc(%esp)
c0103680:	c0 
c0103681:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103688:	c0 
c0103689:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103690:	00 
c0103691:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103698:	e8 80 d6 ff ff       	call   c0100d1d <__panic>
    assert((p1 = alloc_page()) != NULL);
c010369d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036a4:	e8 b0 0b 00 00       	call   c0104259 <alloc_pages>
c01036a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036b0:	75 24                	jne    c01036d6 <basic_check+0x38f>
c01036b2:	c7 44 24 0c 10 6c 10 	movl   $0xc0106c10,0xc(%esp)
c01036b9:	c0 
c01036ba:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01036c1:	c0 
c01036c2:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01036c9:	00 
c01036ca:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01036d1:	e8 47 d6 ff ff       	call   c0100d1d <__panic>
    assert((p2 = alloc_page()) != NULL);
c01036d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036dd:	e8 77 0b 00 00       	call   c0104259 <alloc_pages>
c01036e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036e9:	75 24                	jne    c010370f <basic_check+0x3c8>
c01036eb:	c7 44 24 0c 2c 6c 10 	movl   $0xc0106c2c,0xc(%esp)
c01036f2:	c0 
c01036f3:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01036fa:	c0 
c01036fb:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103702:	00 
c0103703:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010370a:	e8 0e d6 ff ff       	call   c0100d1d <__panic>

    assert(alloc_page() == NULL);
c010370f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103716:	e8 3e 0b 00 00       	call   c0104259 <alloc_pages>
c010371b:	85 c0                	test   %eax,%eax
c010371d:	74 24                	je     c0103743 <basic_check+0x3fc>
c010371f:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c0103726:	c0 
c0103727:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c010372e:	c0 
c010372f:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0103736:	00 
c0103737:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010373e:	e8 da d5 ff ff       	call   c0100d1d <__panic>

    free_page(p0);
c0103743:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010374a:	00 
c010374b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010374e:	89 04 24             	mov    %eax,(%esp)
c0103751:	e8 3d 0b 00 00       	call   c0104293 <free_pages>
c0103756:	c7 45 d8 e0 ce 11 c0 	movl   $0xc011cee0,-0x28(%ebp)
c010375d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103760:	8b 40 04             	mov    0x4(%eax),%eax
c0103763:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103766:	0f 94 c0             	sete   %al
c0103769:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010376c:	85 c0                	test   %eax,%eax
c010376e:	74 24                	je     c0103794 <basic_check+0x44d>
c0103770:	c7 44 24 0c 38 6d 10 	movl   $0xc0106d38,0xc(%esp)
c0103777:	c0 
c0103778:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c010377f:	c0 
c0103780:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0103787:	00 
c0103788:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010378f:	e8 89 d5 ff ff       	call   c0100d1d <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103794:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010379b:	e8 b9 0a 00 00       	call   c0104259 <alloc_pages>
c01037a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01037a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01037a9:	74 24                	je     c01037cf <basic_check+0x488>
c01037ab:	c7 44 24 0c 50 6d 10 	movl   $0xc0106d50,0xc(%esp)
c01037b2:	c0 
c01037b3:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01037ba:	c0 
c01037bb:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01037c2:	00 
c01037c3:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01037ca:	e8 4e d5 ff ff       	call   c0100d1d <__panic>
    assert(alloc_page() == NULL);
c01037cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037d6:	e8 7e 0a 00 00       	call   c0104259 <alloc_pages>
c01037db:	85 c0                	test   %eax,%eax
c01037dd:	74 24                	je     c0103803 <basic_check+0x4bc>
c01037df:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c01037e6:	c0 
c01037e7:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01037ee:	c0 
c01037ef:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01037f6:	00 
c01037f7:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01037fe:	e8 1a d5 ff ff       	call   c0100d1d <__panic>

    assert(nr_free == 0);
c0103803:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103808:	85 c0                	test   %eax,%eax
c010380a:	74 24                	je     c0103830 <basic_check+0x4e9>
c010380c:	c7 44 24 0c 69 6d 10 	movl   $0xc0106d69,0xc(%esp)
c0103813:	c0 
c0103814:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c010381b:	c0 
c010381c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103823:	00 
c0103824:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c010382b:	e8 ed d4 ff ff       	call   c0100d1d <__panic>
    free_list = free_list_store;
c0103830:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103833:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103836:	a3 e0 ce 11 c0       	mov    %eax,0xc011cee0
c010383b:	89 15 e4 ce 11 c0    	mov    %edx,0xc011cee4
    nr_free = nr_free_store;
c0103841:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103844:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8

    free_page(p);
c0103849:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103850:	00 
c0103851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103854:	89 04 24             	mov    %eax,(%esp)
c0103857:	e8 37 0a 00 00       	call   c0104293 <free_pages>
    free_page(p1);
c010385c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103863:	00 
c0103864:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103867:	89 04 24             	mov    %eax,(%esp)
c010386a:	e8 24 0a 00 00       	call   c0104293 <free_pages>
    free_page(p2);
c010386f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103876:	00 
c0103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010387a:	89 04 24             	mov    %eax,(%esp)
c010387d:	e8 11 0a 00 00       	call   c0104293 <free_pages>
}
c0103882:	90                   	nop
c0103883:	89 ec                	mov    %ebp,%esp
c0103885:	5d                   	pop    %ebp
c0103886:	c3                   	ret    

c0103887 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103887:	55                   	push   %ebp
c0103888:	89 e5                	mov    %esp,%ebp
c010388a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103890:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103897:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010389e:	c7 45 ec e0 ce 11 c0 	movl   $0xc011cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01038a5:	eb 6a                	jmp    c0103911 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c01038a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038aa:	83 e8 0c             	sub    $0xc,%eax
c01038ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01038b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038b3:	83 c0 04             	add    $0x4,%eax
c01038b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01038bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038c3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038c6:	0f a3 10             	bt     %edx,(%eax)
c01038c9:	19 c0                	sbb    %eax,%eax
c01038cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01038ce:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01038d2:	0f 95 c0             	setne  %al
c01038d5:	0f b6 c0             	movzbl %al,%eax
c01038d8:	85 c0                	test   %eax,%eax
c01038da:	75 24                	jne    c0103900 <default_check+0x79>
c01038dc:	c7 44 24 0c 76 6d 10 	movl   $0xc0106d76,0xc(%esp)
c01038e3:	c0 
c01038e4:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01038eb:	c0 
c01038ec:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01038f3:	00 
c01038f4:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01038fb:	e8 1d d4 ff ff       	call   c0100d1d <__panic>
        count ++, total += p->property;
c0103900:	ff 45 f4             	incl   -0xc(%ebp)
c0103903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103906:	8b 50 08             	mov    0x8(%eax),%edx
c0103909:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010390c:	01 d0                	add    %edx,%eax
c010390e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103911:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103914:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103917:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010391a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010391d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103920:	81 7d ec e0 ce 11 c0 	cmpl   $0xc011cee0,-0x14(%ebp)
c0103927:	0f 85 7a ff ff ff    	jne    c01038a7 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c010392d:	e8 96 09 00 00       	call   c01042c8 <nr_free_pages>
c0103932:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103935:	39 d0                	cmp    %edx,%eax
c0103937:	74 24                	je     c010395d <default_check+0xd6>
c0103939:	c7 44 24 0c 86 6d 10 	movl   $0xc0106d86,0xc(%esp)
c0103940:	c0 
c0103941:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103948:	c0 
c0103949:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0103950:	00 
c0103951:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103958:	e8 c0 d3 ff ff       	call   c0100d1d <__panic>

    basic_check();
c010395d:	e8 e5 f9 ff ff       	call   c0103347 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103962:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103969:	e8 eb 08 00 00       	call   c0104259 <alloc_pages>
c010396e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0103971:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103975:	75 24                	jne    c010399b <default_check+0x114>
c0103977:	c7 44 24 0c 9f 6d 10 	movl   $0xc0106d9f,0xc(%esp)
c010397e:	c0 
c010397f:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103986:	c0 
c0103987:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010398e:	00 
c010398f:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103996:	e8 82 d3 ff ff       	call   c0100d1d <__panic>
    assert(!PageProperty(p0));
c010399b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010399e:	83 c0 04             	add    $0x4,%eax
c01039a1:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01039a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039ab:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039ae:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01039b1:	0f a3 10             	bt     %edx,(%eax)
c01039b4:	19 c0                	sbb    %eax,%eax
c01039b6:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01039b9:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01039bd:	0f 95 c0             	setne  %al
c01039c0:	0f b6 c0             	movzbl %al,%eax
c01039c3:	85 c0                	test   %eax,%eax
c01039c5:	74 24                	je     c01039eb <default_check+0x164>
c01039c7:	c7 44 24 0c aa 6d 10 	movl   $0xc0106daa,0xc(%esp)
c01039ce:	c0 
c01039cf:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c01039d6:	c0 
c01039d7:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01039de:	00 
c01039df:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c01039e6:	e8 32 d3 ff ff       	call   c0100d1d <__panic>

    list_entry_t free_list_store = free_list;
c01039eb:	a1 e0 ce 11 c0       	mov    0xc011cee0,%eax
c01039f0:	8b 15 e4 ce 11 c0    	mov    0xc011cee4,%edx
c01039f6:	89 45 80             	mov    %eax,-0x80(%ebp)
c01039f9:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01039fc:	c7 45 b0 e0 ce 11 c0 	movl   $0xc011cee0,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0103a03:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103a06:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103a09:	89 50 04             	mov    %edx,0x4(%eax)
c0103a0c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103a0f:	8b 50 04             	mov    0x4(%eax),%edx
c0103a12:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103a15:	89 10                	mov    %edx,(%eax)
}
c0103a17:	90                   	nop
c0103a18:	c7 45 b4 e0 ce 11 c0 	movl   $0xc011cee0,-0x4c(%ebp)
    return list->next == list;
c0103a1f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103a22:	8b 40 04             	mov    0x4(%eax),%eax
c0103a25:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0103a28:	0f 94 c0             	sete   %al
c0103a2b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103a2e:	85 c0                	test   %eax,%eax
c0103a30:	75 24                	jne    c0103a56 <default_check+0x1cf>
c0103a32:	c7 44 24 0c ff 6c 10 	movl   $0xc0106cff,0xc(%esp)
c0103a39:	c0 
c0103a3a:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103a41:	c0 
c0103a42:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103a49:	00 
c0103a4a:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103a51:	e8 c7 d2 ff ff       	call   c0100d1d <__panic>
    assert(alloc_page() == NULL);
c0103a56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a5d:	e8 f7 07 00 00       	call   c0104259 <alloc_pages>
c0103a62:	85 c0                	test   %eax,%eax
c0103a64:	74 24                	je     c0103a8a <default_check+0x203>
c0103a66:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c0103a6d:	c0 
c0103a6e:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103a75:	c0 
c0103a76:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0103a7d:	00 
c0103a7e:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103a85:	e8 93 d2 ff ff       	call   c0100d1d <__panic>

    unsigned int nr_free_store = nr_free;
c0103a8a:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0103a92:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c0103a99:	00 00 00 

    free_pages(p0 + 2, 3);
c0103a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a9f:	83 c0 28             	add    $0x28,%eax
c0103aa2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103aa9:	00 
c0103aaa:	89 04 24             	mov    %eax,(%esp)
c0103aad:	e8 e1 07 00 00       	call   c0104293 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103ab2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103ab9:	e8 9b 07 00 00       	call   c0104259 <alloc_pages>
c0103abe:	85 c0                	test   %eax,%eax
c0103ac0:	74 24                	je     c0103ae6 <default_check+0x25f>
c0103ac2:	c7 44 24 0c bc 6d 10 	movl   $0xc0106dbc,0xc(%esp)
c0103ac9:	c0 
c0103aca:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103ad1:	c0 
c0103ad2:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0103ad9:	00 
c0103ada:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103ae1:	e8 37 d2 ff ff       	call   c0100d1d <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103ae6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ae9:	83 c0 28             	add    $0x28,%eax
c0103aec:	83 c0 04             	add    $0x4,%eax
c0103aef:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103af6:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103af9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103afc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103aff:	0f a3 10             	bt     %edx,(%eax)
c0103b02:	19 c0                	sbb    %eax,%eax
c0103b04:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103b07:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103b0b:	0f 95 c0             	setne  %al
c0103b0e:	0f b6 c0             	movzbl %al,%eax
c0103b11:	85 c0                	test   %eax,%eax
c0103b13:	74 0e                	je     c0103b23 <default_check+0x29c>
c0103b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b18:	83 c0 28             	add    $0x28,%eax
c0103b1b:	8b 40 08             	mov    0x8(%eax),%eax
c0103b1e:	83 f8 03             	cmp    $0x3,%eax
c0103b21:	74 24                	je     c0103b47 <default_check+0x2c0>
c0103b23:	c7 44 24 0c d4 6d 10 	movl   $0xc0106dd4,0xc(%esp)
c0103b2a:	c0 
c0103b2b:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103b32:	c0 
c0103b33:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103b3a:	00 
c0103b3b:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103b42:	e8 d6 d1 ff ff       	call   c0100d1d <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0103b47:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103b4e:	e8 06 07 00 00       	call   c0104259 <alloc_pages>
c0103b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103b56:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103b5a:	75 24                	jne    c0103b80 <default_check+0x2f9>
c0103b5c:	c7 44 24 0c 00 6e 10 	movl   $0xc0106e00,0xc(%esp)
c0103b63:	c0 
c0103b64:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103b6b:	c0 
c0103b6c:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0103b73:	00 
c0103b74:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103b7b:	e8 9d d1 ff ff       	call   c0100d1d <__panic>
    assert(alloc_page() == NULL);
c0103b80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b87:	e8 cd 06 00 00       	call   c0104259 <alloc_pages>
c0103b8c:	85 c0                	test   %eax,%eax
c0103b8e:	74 24                	je     c0103bb4 <default_check+0x32d>
c0103b90:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c0103b97:	c0 
c0103b98:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103b9f:	c0 
c0103ba0:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0103ba7:	00 
c0103ba8:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103baf:	e8 69 d1 ff ff       	call   c0100d1d <__panic>
    assert(p0 + 2 == p1);
c0103bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bb7:	83 c0 28             	add    $0x28,%eax
c0103bba:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103bbd:	74 24                	je     c0103be3 <default_check+0x35c>
c0103bbf:	c7 44 24 0c 1e 6e 10 	movl   $0xc0106e1e,0xc(%esp)
c0103bc6:	c0 
c0103bc7:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103bce:	c0 
c0103bcf:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0103bd6:	00 
c0103bd7:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103bde:	e8 3a d1 ff ff       	call   c0100d1d <__panic>

    p2 = p0 + 1;
c0103be3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103be6:	83 c0 14             	add    $0x14,%eax
c0103be9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0103bec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103bf3:	00 
c0103bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103bf7:	89 04 24             	mov    %eax,(%esp)
c0103bfa:	e8 94 06 00 00       	call   c0104293 <free_pages>
    free_pages(p1, 3);
c0103bff:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103c06:	00 
c0103c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c0a:	89 04 24             	mov    %eax,(%esp)
c0103c0d:	e8 81 06 00 00       	call   c0104293 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0103c12:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c15:	83 c0 04             	add    $0x4,%eax
c0103c18:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103c1f:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103c22:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103c25:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103c28:	0f a3 10             	bt     %edx,(%eax)
c0103c2b:	19 c0                	sbb    %eax,%eax
c0103c2d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103c30:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103c34:	0f 95 c0             	setne  %al
c0103c37:	0f b6 c0             	movzbl %al,%eax
c0103c3a:	85 c0                	test   %eax,%eax
c0103c3c:	74 0b                	je     c0103c49 <default_check+0x3c2>
c0103c3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c41:	8b 40 08             	mov    0x8(%eax),%eax
c0103c44:	83 f8 01             	cmp    $0x1,%eax
c0103c47:	74 24                	je     c0103c6d <default_check+0x3e6>
c0103c49:	c7 44 24 0c 2c 6e 10 	movl   $0xc0106e2c,0xc(%esp)
c0103c50:	c0 
c0103c51:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103c58:	c0 
c0103c59:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0103c60:	00 
c0103c61:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103c68:	e8 b0 d0 ff ff       	call   c0100d1d <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103c6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c70:	83 c0 04             	add    $0x4,%eax
c0103c73:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103c7a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103c7d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103c80:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103c83:	0f a3 10             	bt     %edx,(%eax)
c0103c86:	19 c0                	sbb    %eax,%eax
c0103c88:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103c8b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103c8f:	0f 95 c0             	setne  %al
c0103c92:	0f b6 c0             	movzbl %al,%eax
c0103c95:	85 c0                	test   %eax,%eax
c0103c97:	74 0b                	je     c0103ca4 <default_check+0x41d>
c0103c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c9c:	8b 40 08             	mov    0x8(%eax),%eax
c0103c9f:	83 f8 03             	cmp    $0x3,%eax
c0103ca2:	74 24                	je     c0103cc8 <default_check+0x441>
c0103ca4:	c7 44 24 0c 54 6e 10 	movl   $0xc0106e54,0xc(%esp)
c0103cab:	c0 
c0103cac:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103cb3:	c0 
c0103cb4:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0103cbb:	00 
c0103cbc:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103cc3:	e8 55 d0 ff ff       	call   c0100d1d <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103cc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ccf:	e8 85 05 00 00       	call   c0104259 <alloc_pages>
c0103cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103cd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cda:	83 e8 14             	sub    $0x14,%eax
c0103cdd:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103ce0:	74 24                	je     c0103d06 <default_check+0x47f>
c0103ce2:	c7 44 24 0c 7a 6e 10 	movl   $0xc0106e7a,0xc(%esp)
c0103ce9:	c0 
c0103cea:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103cf1:	c0 
c0103cf2:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0103cf9:	00 
c0103cfa:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103d01:	e8 17 d0 ff ff       	call   c0100d1d <__panic>
    free_page(p0);
c0103d06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d0d:	00 
c0103d0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d11:	89 04 24             	mov    %eax,(%esp)
c0103d14:	e8 7a 05 00 00       	call   c0104293 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103d19:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103d20:	e8 34 05 00 00       	call   c0104259 <alloc_pages>
c0103d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d2b:	83 c0 14             	add    $0x14,%eax
c0103d2e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103d31:	74 24                	je     c0103d57 <default_check+0x4d0>
c0103d33:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c0103d3a:	c0 
c0103d3b:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103d42:	c0 
c0103d43:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0103d4a:	00 
c0103d4b:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103d52:	e8 c6 cf ff ff       	call   c0100d1d <__panic>

    free_pages(p0, 2);
c0103d57:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103d5e:	00 
c0103d5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d62:	89 04 24             	mov    %eax,(%esp)
c0103d65:	e8 29 05 00 00       	call   c0104293 <free_pages>
    free_page(p2);
c0103d6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d71:	00 
c0103d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d75:	89 04 24             	mov    %eax,(%esp)
c0103d78:	e8 16 05 00 00       	call   c0104293 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103d7d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103d84:	e8 d0 04 00 00       	call   c0104259 <alloc_pages>
c0103d89:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d90:	75 24                	jne    c0103db6 <default_check+0x52f>
c0103d92:	c7 44 24 0c b8 6e 10 	movl   $0xc0106eb8,0xc(%esp)
c0103d99:	c0 
c0103d9a:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103da1:	c0 
c0103da2:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0103da9:	00 
c0103daa:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103db1:	e8 67 cf ff ff       	call   c0100d1d <__panic>
    assert(alloc_page() == NULL);
c0103db6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dbd:	e8 97 04 00 00       	call   c0104259 <alloc_pages>
c0103dc2:	85 c0                	test   %eax,%eax
c0103dc4:	74 24                	je     c0103dea <default_check+0x563>
c0103dc6:	c7 44 24 0c 16 6d 10 	movl   $0xc0106d16,0xc(%esp)
c0103dcd:	c0 
c0103dce:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103dd5:	c0 
c0103dd6:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0103ddd:	00 
c0103dde:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103de5:	e8 33 cf ff ff       	call   c0100d1d <__panic>

    assert(nr_free == 0);
c0103dea:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103def:	85 c0                	test   %eax,%eax
c0103df1:	74 24                	je     c0103e17 <default_check+0x590>
c0103df3:	c7 44 24 0c 69 6d 10 	movl   $0xc0106d69,0xc(%esp)
c0103dfa:	c0 
c0103dfb:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103e02:	c0 
c0103e03:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0103e0a:	00 
c0103e0b:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103e12:	e8 06 cf ff ff       	call   c0100d1d <__panic>
    nr_free = nr_free_store;
c0103e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e1a:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8

    free_list = free_list_store;
c0103e1f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103e22:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103e25:	a3 e0 ce 11 c0       	mov    %eax,0xc011cee0
c0103e2a:	89 15 e4 ce 11 c0    	mov    %edx,0xc011cee4
    free_pages(p0, 5);
c0103e30:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103e37:	00 
c0103e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e3b:	89 04 24             	mov    %eax,(%esp)
c0103e3e:	e8 50 04 00 00       	call   c0104293 <free_pages>

    le = &free_list;
c0103e43:	c7 45 ec e0 ce 11 c0 	movl   $0xc011cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103e4a:	eb 5a                	jmp    c0103ea6 <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0103e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e4f:	8b 40 04             	mov    0x4(%eax),%eax
c0103e52:	8b 00                	mov    (%eax),%eax
c0103e54:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103e57:	75 0d                	jne    c0103e66 <default_check+0x5df>
c0103e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e5c:	8b 00                	mov    (%eax),%eax
c0103e5e:	8b 40 04             	mov    0x4(%eax),%eax
c0103e61:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103e64:	74 24                	je     c0103e8a <default_check+0x603>
c0103e66:	c7 44 24 0c d8 6e 10 	movl   $0xc0106ed8,0xc(%esp)
c0103e6d:	c0 
c0103e6e:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103e75:	c0 
c0103e76:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0103e7d:	00 
c0103e7e:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103e85:	e8 93 ce ff ff       	call   c0100d1d <__panic>
        struct Page *p = le2page(le, page_link);
c0103e8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e8d:	83 e8 0c             	sub    $0xc,%eax
c0103e90:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0103e93:	ff 4d f4             	decl   -0xc(%ebp)
c0103e96:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103e99:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e9c:	8b 48 08             	mov    0x8(%eax),%ecx
c0103e9f:	89 d0                	mov    %edx,%eax
c0103ea1:	29 c8                	sub    %ecx,%eax
c0103ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ea6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ea9:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0103eac:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103eaf:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103eb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103eb5:	81 7d ec e0 ce 11 c0 	cmpl   $0xc011cee0,-0x14(%ebp)
c0103ebc:	75 8e                	jne    c0103e4c <default_check+0x5c5>
    }
    assert(count == 0);
c0103ebe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ec2:	74 24                	je     c0103ee8 <default_check+0x661>
c0103ec4:	c7 44 24 0c 05 6f 10 	movl   $0xc0106f05,0xc(%esp)
c0103ecb:	c0 
c0103ecc:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103ed3:	c0 
c0103ed4:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0103edb:	00 
c0103edc:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103ee3:	e8 35 ce ff ff       	call   c0100d1d <__panic>
    assert(total == 0);
c0103ee8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103eec:	74 24                	je     c0103f12 <default_check+0x68b>
c0103eee:	c7 44 24 0c 10 6f 10 	movl   $0xc0106f10,0xc(%esp)
c0103ef5:	c0 
c0103ef6:	c7 44 24 08 76 6b 10 	movl   $0xc0106b76,0x8(%esp)
c0103efd:	c0 
c0103efe:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c0103f05:	00 
c0103f06:	c7 04 24 8b 6b 10 c0 	movl   $0xc0106b8b,(%esp)
c0103f0d:	e8 0b ce ff ff       	call   c0100d1d <__panic>
}
c0103f12:	90                   	nop
c0103f13:	89 ec                	mov    %ebp,%esp
c0103f15:	5d                   	pop    %ebp
c0103f16:	c3                   	ret    

c0103f17 <page2ppn>:
page2ppn(struct Page *page) {
c0103f17:	55                   	push   %ebp
c0103f18:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103f1a:	8b 15 00 cf 11 c0    	mov    0xc011cf00,%edx
c0103f20:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f23:	29 d0                	sub    %edx,%eax
c0103f25:	c1 f8 02             	sar    $0x2,%eax
c0103f28:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103f2e:	5d                   	pop    %ebp
c0103f2f:	c3                   	ret    

c0103f30 <page2pa>:
page2pa(struct Page *page) {
c0103f30:	55                   	push   %ebp
c0103f31:	89 e5                	mov    %esp,%ebp
c0103f33:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103f36:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f39:	89 04 24             	mov    %eax,(%esp)
c0103f3c:	e8 d6 ff ff ff       	call   c0103f17 <page2ppn>
c0103f41:	c1 e0 0c             	shl    $0xc,%eax
}
c0103f44:	89 ec                	mov    %ebp,%esp
c0103f46:	5d                   	pop    %ebp
c0103f47:	c3                   	ret    

c0103f48 <pa2page>:
pa2page(uintptr_t pa) {
c0103f48:	55                   	push   %ebp
c0103f49:	89 e5                	mov    %esp,%ebp
c0103f4b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f51:	c1 e8 0c             	shr    $0xc,%eax
c0103f54:	89 c2                	mov    %eax,%edx
c0103f56:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0103f5b:	39 c2                	cmp    %eax,%edx
c0103f5d:	72 1c                	jb     c0103f7b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103f5f:	c7 44 24 08 4c 6f 10 	movl   $0xc0106f4c,0x8(%esp)
c0103f66:	c0 
c0103f67:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103f6e:	00 
c0103f6f:	c7 04 24 6b 6f 10 c0 	movl   $0xc0106f6b,(%esp)
c0103f76:	e8 a2 cd ff ff       	call   c0100d1d <__panic>
    return &pages[PPN(pa)];
c0103f7b:	8b 0d 00 cf 11 c0    	mov    0xc011cf00,%ecx
c0103f81:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f84:	c1 e8 0c             	shr    $0xc,%eax
c0103f87:	89 c2                	mov    %eax,%edx
c0103f89:	89 d0                	mov    %edx,%eax
c0103f8b:	c1 e0 02             	shl    $0x2,%eax
c0103f8e:	01 d0                	add    %edx,%eax
c0103f90:	c1 e0 02             	shl    $0x2,%eax
c0103f93:	01 c8                	add    %ecx,%eax
}
c0103f95:	89 ec                	mov    %ebp,%esp
c0103f97:	5d                   	pop    %ebp
c0103f98:	c3                   	ret    

c0103f99 <page2kva>:
page2kva(struct Page *page) {
c0103f99:	55                   	push   %ebp
c0103f9a:	89 e5                	mov    %esp,%ebp
c0103f9c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103f9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fa2:	89 04 24             	mov    %eax,(%esp)
c0103fa5:	e8 86 ff ff ff       	call   c0103f30 <page2pa>
c0103faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fb0:	c1 e8 0c             	shr    $0xc,%eax
c0103fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fb6:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0103fbb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103fbe:	72 23                	jb     c0103fe3 <page2kva+0x4a>
c0103fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103fc7:	c7 44 24 08 7c 6f 10 	movl   $0xc0106f7c,0x8(%esp)
c0103fce:	c0 
c0103fcf:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103fd6:	00 
c0103fd7:	c7 04 24 6b 6f 10 c0 	movl   $0xc0106f6b,(%esp)
c0103fde:	e8 3a cd ff ff       	call   c0100d1d <__panic>
c0103fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fe6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103feb:	89 ec                	mov    %ebp,%esp
c0103fed:	5d                   	pop    %ebp
c0103fee:	c3                   	ret    

c0103fef <pte2page>:
pte2page(pte_t pte) {
c0103fef:	55                   	push   %ebp
c0103ff0:	89 e5                	mov    %esp,%ebp
c0103ff2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ff8:	83 e0 01             	and    $0x1,%eax
c0103ffb:	85 c0                	test   %eax,%eax
c0103ffd:	75 1c                	jne    c010401b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103fff:	c7 44 24 08 a0 6f 10 	movl   $0xc0106fa0,0x8(%esp)
c0104006:	c0 
c0104007:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010400e:	00 
c010400f:	c7 04 24 6b 6f 10 c0 	movl   $0xc0106f6b,(%esp)
c0104016:	e8 02 cd ff ff       	call   c0100d1d <__panic>
    return pa2page(PTE_ADDR(pte));
c010401b:	8b 45 08             	mov    0x8(%ebp),%eax
c010401e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104023:	89 04 24             	mov    %eax,(%esp)
c0104026:	e8 1d ff ff ff       	call   c0103f48 <pa2page>
}
c010402b:	89 ec                	mov    %ebp,%esp
c010402d:	5d                   	pop    %ebp
c010402e:	c3                   	ret    

c010402f <pde2page>:
pde2page(pde_t pde) {
c010402f:	55                   	push   %ebp
c0104030:	89 e5                	mov    %esp,%ebp
c0104032:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104035:	8b 45 08             	mov    0x8(%ebp),%eax
c0104038:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010403d:	89 04 24             	mov    %eax,(%esp)
c0104040:	e8 03 ff ff ff       	call   c0103f48 <pa2page>
}
c0104045:	89 ec                	mov    %ebp,%esp
c0104047:	5d                   	pop    %ebp
c0104048:	c3                   	ret    

c0104049 <page_ref>:
page_ref(struct Page *page) {
c0104049:	55                   	push   %ebp
c010404a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010404c:	8b 45 08             	mov    0x8(%ebp),%eax
c010404f:	8b 00                	mov    (%eax),%eax
}
c0104051:	5d                   	pop    %ebp
c0104052:	c3                   	ret    

c0104053 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104053:	55                   	push   %ebp
c0104054:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104056:	8b 45 08             	mov    0x8(%ebp),%eax
c0104059:	8b 55 0c             	mov    0xc(%ebp),%edx
c010405c:	89 10                	mov    %edx,(%eax)
}
c010405e:	90                   	nop
c010405f:	5d                   	pop    %ebp
c0104060:	c3                   	ret    

c0104061 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104061:	55                   	push   %ebp
c0104062:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104064:	8b 45 08             	mov    0x8(%ebp),%eax
c0104067:	8b 00                	mov    (%eax),%eax
c0104069:	8d 50 01             	lea    0x1(%eax),%edx
c010406c:	8b 45 08             	mov    0x8(%ebp),%eax
c010406f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104071:	8b 45 08             	mov    0x8(%ebp),%eax
c0104074:	8b 00                	mov    (%eax),%eax
}
c0104076:	5d                   	pop    %ebp
c0104077:	c3                   	ret    

c0104078 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104078:	55                   	push   %ebp
c0104079:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010407b:	8b 45 08             	mov    0x8(%ebp),%eax
c010407e:	8b 00                	mov    (%eax),%eax
c0104080:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104083:	8b 45 08             	mov    0x8(%ebp),%eax
c0104086:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104088:	8b 45 08             	mov    0x8(%ebp),%eax
c010408b:	8b 00                	mov    (%eax),%eax
}
c010408d:	5d                   	pop    %ebp
c010408e:	c3                   	ret    

c010408f <__intr_save>:
__intr_save(void) {
c010408f:	55                   	push   %ebp
c0104090:	89 e5                	mov    %esp,%ebp
c0104092:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104095:	9c                   	pushf  
c0104096:	58                   	pop    %eax
c0104097:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010409a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010409d:	25 00 02 00 00       	and    $0x200,%eax
c01040a2:	85 c0                	test   %eax,%eax
c01040a4:	74 0c                	je     c01040b2 <__intr_save+0x23>
        intr_disable();
c01040a6:	e8 cb d6 ff ff       	call   c0101776 <intr_disable>
        return 1;
c01040ab:	b8 01 00 00 00       	mov    $0x1,%eax
c01040b0:	eb 05                	jmp    c01040b7 <__intr_save+0x28>
    return 0;
c01040b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040b7:	89 ec                	mov    %ebp,%esp
c01040b9:	5d                   	pop    %ebp
c01040ba:	c3                   	ret    

c01040bb <__intr_restore>:
__intr_restore(bool flag) {
c01040bb:	55                   	push   %ebp
c01040bc:	89 e5                	mov    %esp,%ebp
c01040be:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01040c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01040c5:	74 05                	je     c01040cc <__intr_restore+0x11>
        intr_enable();
c01040c7:	e8 a2 d6 ff ff       	call   c010176e <intr_enable>
}
c01040cc:	90                   	nop
c01040cd:	89 ec                	mov    %ebp,%esp
c01040cf:	5d                   	pop    %ebp
c01040d0:	c3                   	ret    

c01040d1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01040d1:	55                   	push   %ebp
c01040d2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01040d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01040d7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01040da:	b8 23 00 00 00       	mov    $0x23,%eax
c01040df:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01040e1:	b8 23 00 00 00       	mov    $0x23,%eax
c01040e6:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01040e8:	b8 10 00 00 00       	mov    $0x10,%eax
c01040ed:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01040ef:	b8 10 00 00 00       	mov    $0x10,%eax
c01040f4:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01040f6:	b8 10 00 00 00       	mov    $0x10,%eax
c01040fb:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01040fd:	ea 04 41 10 c0 08 00 	ljmp   $0x8,$0xc0104104
}
c0104104:	90                   	nop
c0104105:	5d                   	pop    %ebp
c0104106:	c3                   	ret    

c0104107 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104107:	55                   	push   %ebp
c0104108:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c010410a:	8b 45 08             	mov    0x8(%ebp),%eax
c010410d:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24
}
c0104112:	90                   	nop
c0104113:	5d                   	pop    %ebp
c0104114:	c3                   	ret    

c0104115 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104115:	55                   	push   %ebp
c0104116:	89 e5                	mov    %esp,%ebp
c0104118:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010411b:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0104120:	89 04 24             	mov    %eax,(%esp)
c0104123:	e8 df ff ff ff       	call   c0104107 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104128:	66 c7 05 28 cf 11 c0 	movw   $0x10,0xc011cf28
c010412f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104131:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0104138:	68 00 
c010413a:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c010413f:	0f b7 c0             	movzwl %ax,%eax
c0104142:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0104148:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c010414d:	c1 e8 10             	shr    $0x10,%eax
c0104150:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0104155:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010415c:	24 f0                	and    $0xf0,%al
c010415e:	0c 09                	or     $0x9,%al
c0104160:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104165:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010416c:	24 ef                	and    $0xef,%al
c010416e:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104173:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c010417a:	24 9f                	and    $0x9f,%al
c010417c:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0104181:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0104188:	0c 80                	or     $0x80,%al
c010418a:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c010418f:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0104196:	24 f0                	and    $0xf0,%al
c0104198:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c010419d:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01041a4:	24 ef                	and    $0xef,%al
c01041a6:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01041ab:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01041b2:	24 df                	and    $0xdf,%al
c01041b4:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01041b9:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01041c0:	0c 40                	or     $0x40,%al
c01041c2:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01041c7:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c01041ce:	24 7f                	and    $0x7f,%al
c01041d0:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c01041d5:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c01041da:	c1 e8 18             	shr    $0x18,%eax
c01041dd:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01041e2:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c01041e9:	e8 e3 fe ff ff       	call   c01040d1 <lgdt>
c01041ee:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01041f4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01041f8:	0f 00 d8             	ltr    %ax
}
c01041fb:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01041fc:	90                   	nop
c01041fd:	89 ec                	mov    %ebp,%esp
c01041ff:	5d                   	pop    %ebp
c0104200:	c3                   	ret    

c0104201 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104201:	55                   	push   %ebp
c0104202:	89 e5                	mov    %esp,%ebp
c0104204:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &buddy_pmm_manager;
    pmm_manager = &default_pmm_manager;
c0104207:	c7 05 0c cf 11 c0 30 	movl   $0xc0106f30,0xc011cf0c
c010420e:	6f 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104211:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104216:	8b 00                	mov    (%eax),%eax
c0104218:	89 44 24 04          	mov    %eax,0x4(%esp)
c010421c:	c7 04 24 cc 6f 10 c0 	movl   $0xc0106fcc,(%esp)
c0104223:	e8 73 c1 ff ff       	call   c010039b <cprintf>
    pmm_manager->init();
c0104228:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c010422d:	8b 40 04             	mov    0x4(%eax),%eax
c0104230:	ff d0                	call   *%eax
}
c0104232:	90                   	nop
c0104233:	89 ec                	mov    %ebp,%esp
c0104235:	5d                   	pop    %ebp
c0104236:	c3                   	ret    

c0104237 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104237:	55                   	push   %ebp
c0104238:	89 e5                	mov    %esp,%ebp
c010423a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010423d:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104242:	8b 40 08             	mov    0x8(%eax),%eax
c0104245:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104248:	89 54 24 04          	mov    %edx,0x4(%esp)
c010424c:	8b 55 08             	mov    0x8(%ebp),%edx
c010424f:	89 14 24             	mov    %edx,(%esp)
c0104252:	ff d0                	call   *%eax
}
c0104254:	90                   	nop
c0104255:	89 ec                	mov    %ebp,%esp
c0104257:	5d                   	pop    %ebp
c0104258:	c3                   	ret    

c0104259 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104259:	55                   	push   %ebp
c010425a:	89 e5                	mov    %esp,%ebp
c010425c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c010425f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0104266:	e8 24 fe ff ff       	call   c010408f <__intr_save>
c010426b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c010426e:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104273:	8b 40 0c             	mov    0xc(%eax),%eax
c0104276:	8b 55 08             	mov    0x8(%ebp),%edx
c0104279:	89 14 24             	mov    %edx,(%esp)
c010427c:	ff d0                	call   *%eax
c010427e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0104281:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104284:	89 04 24             	mov    %eax,(%esp)
c0104287:	e8 2f fe ff ff       	call   c01040bb <__intr_restore>
    return page;
c010428c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010428f:	89 ec                	mov    %ebp,%esp
c0104291:	5d                   	pop    %ebp
c0104292:	c3                   	ret    

c0104293 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104293:	55                   	push   %ebp
c0104294:	89 e5                	mov    %esp,%ebp
c0104296:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104299:	e8 f1 fd ff ff       	call   c010408f <__intr_save>
c010429e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01042a1:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c01042a6:	8b 40 10             	mov    0x10(%eax),%eax
c01042a9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042ac:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042b0:	8b 55 08             	mov    0x8(%ebp),%edx
c01042b3:	89 14 24             	mov    %edx,(%esp)
c01042b6:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01042b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042bb:	89 04 24             	mov    %eax,(%esp)
c01042be:	e8 f8 fd ff ff       	call   c01040bb <__intr_restore>
}
c01042c3:	90                   	nop
c01042c4:	89 ec                	mov    %ebp,%esp
c01042c6:	5d                   	pop    %ebp
c01042c7:	c3                   	ret    

c01042c8 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01042c8:	55                   	push   %ebp
c01042c9:	89 e5                	mov    %esp,%ebp
c01042cb:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01042ce:	e8 bc fd ff ff       	call   c010408f <__intr_save>
c01042d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01042d6:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c01042db:	8b 40 14             	mov    0x14(%eax),%eax
c01042de:	ff d0                	call   *%eax
c01042e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042e6:	89 04 24             	mov    %eax,(%esp)
c01042e9:	e8 cd fd ff ff       	call   c01040bb <__intr_restore>
    return ret;
c01042ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01042f1:	89 ec                	mov    %ebp,%esp
c01042f3:	5d                   	pop    %ebp
c01042f4:	c3                   	ret    

c01042f5 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01042f5:	55                   	push   %ebp
c01042f6:	89 e5                	mov    %esp,%ebp
c01042f8:	57                   	push   %edi
c01042f9:	56                   	push   %esi
c01042fa:	53                   	push   %ebx
c01042fb:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104301:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104308:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010430f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104316:	c7 04 24 e3 6f 10 c0 	movl   $0xc0106fe3,(%esp)
c010431d:	e8 79 c0 ff ff       	call   c010039b <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104329:	e9 0c 01 00 00       	jmp    c010443a <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010432e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104331:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104334:	89 d0                	mov    %edx,%eax
c0104336:	c1 e0 02             	shl    $0x2,%eax
c0104339:	01 d0                	add    %edx,%eax
c010433b:	c1 e0 02             	shl    $0x2,%eax
c010433e:	01 c8                	add    %ecx,%eax
c0104340:	8b 50 08             	mov    0x8(%eax),%edx
c0104343:	8b 40 04             	mov    0x4(%eax),%eax
c0104346:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104349:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010434c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010434f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104352:	89 d0                	mov    %edx,%eax
c0104354:	c1 e0 02             	shl    $0x2,%eax
c0104357:	01 d0                	add    %edx,%eax
c0104359:	c1 e0 02             	shl    $0x2,%eax
c010435c:	01 c8                	add    %ecx,%eax
c010435e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104361:	8b 58 10             	mov    0x10(%eax),%ebx
c0104364:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104367:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010436a:	01 c8                	add    %ecx,%eax
c010436c:	11 da                	adc    %ebx,%edx
c010436e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104371:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104374:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104377:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010437a:	89 d0                	mov    %edx,%eax
c010437c:	c1 e0 02             	shl    $0x2,%eax
c010437f:	01 d0                	add    %edx,%eax
c0104381:	c1 e0 02             	shl    $0x2,%eax
c0104384:	01 c8                	add    %ecx,%eax
c0104386:	83 c0 14             	add    $0x14,%eax
c0104389:	8b 00                	mov    (%eax),%eax
c010438b:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104391:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104394:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104397:	83 c0 ff             	add    $0xffffffff,%eax
c010439a:	83 d2 ff             	adc    $0xffffffff,%edx
c010439d:	89 c6                	mov    %eax,%esi
c010439f:	89 d7                	mov    %edx,%edi
c01043a1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01043a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043a7:	89 d0                	mov    %edx,%eax
c01043a9:	c1 e0 02             	shl    $0x2,%eax
c01043ac:	01 d0                	add    %edx,%eax
c01043ae:	c1 e0 02             	shl    $0x2,%eax
c01043b1:	01 c8                	add    %ecx,%eax
c01043b3:	8b 48 0c             	mov    0xc(%eax),%ecx
c01043b6:	8b 58 10             	mov    0x10(%eax),%ebx
c01043b9:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01043bf:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01043c3:	89 74 24 14          	mov    %esi,0x14(%esp)
c01043c7:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01043cb:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01043ce:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01043d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043d5:	89 54 24 10          	mov    %edx,0x10(%esp)
c01043d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01043dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01043e1:	c7 04 24 f0 6f 10 c0 	movl   $0xc0106ff0,(%esp)
c01043e8:	e8 ae bf ff ff       	call   c010039b <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01043ed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01043f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043f3:	89 d0                	mov    %edx,%eax
c01043f5:	c1 e0 02             	shl    $0x2,%eax
c01043f8:	01 d0                	add    %edx,%eax
c01043fa:	c1 e0 02             	shl    $0x2,%eax
c01043fd:	01 c8                	add    %ecx,%eax
c01043ff:	83 c0 14             	add    $0x14,%eax
c0104402:	8b 00                	mov    (%eax),%eax
c0104404:	83 f8 01             	cmp    $0x1,%eax
c0104407:	75 2e                	jne    c0104437 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104409:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010440c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010440f:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104412:	89 d0                	mov    %edx,%eax
c0104414:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104417:	73 1e                	jae    c0104437 <page_init+0x142>
c0104419:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c010441e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104423:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104426:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104429:	72 0c                	jb     c0104437 <page_init+0x142>
                maxpa = end;
c010442b:	8b 45 98             	mov    -0x68(%ebp),%eax
c010442e:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104431:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104434:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104437:	ff 45 dc             	incl   -0x24(%ebp)
c010443a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010443d:	8b 00                	mov    (%eax),%eax
c010443f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104442:	0f 8c e6 fe ff ff    	jl     c010432e <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104448:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010444d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104452:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104455:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104458:	73 0e                	jae    c0104468 <page_init+0x173>
        maxpa = KMEMSIZE;
c010445a:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104461:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104468:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010446b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010446e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104472:	c1 ea 0c             	shr    $0xc,%edx
c0104475:	a3 04 cf 11 c0       	mov    %eax,0xc011cf04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010447a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104481:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c0104486:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104489:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010448c:	01 d0                	add    %edx,%eax
c010448e:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104491:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104494:	ba 00 00 00 00       	mov    $0x0,%edx
c0104499:	f7 75 c0             	divl   -0x40(%ebp)
c010449c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010449f:	29 d0                	sub    %edx,%eax
c01044a1:	a3 00 cf 11 c0       	mov    %eax,0xc011cf00

    for (i = 0; i < npage; i ++) {
c01044a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01044ad:	eb 2f                	jmp    c01044de <page_init+0x1e9>
        SetPageReserved(pages + i);
c01044af:	8b 0d 00 cf 11 c0    	mov    0xc011cf00,%ecx
c01044b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044b8:	89 d0                	mov    %edx,%eax
c01044ba:	c1 e0 02             	shl    $0x2,%eax
c01044bd:	01 d0                	add    %edx,%eax
c01044bf:	c1 e0 02             	shl    $0x2,%eax
c01044c2:	01 c8                	add    %ecx,%eax
c01044c4:	83 c0 04             	add    $0x4,%eax
c01044c7:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01044ce:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01044d1:	8b 45 90             	mov    -0x70(%ebp),%eax
c01044d4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01044d7:	0f ab 10             	bts    %edx,(%eax)
}
c01044da:	90                   	nop
    for (i = 0; i < npage; i ++) {
c01044db:	ff 45 dc             	incl   -0x24(%ebp)
c01044de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044e1:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01044e6:	39 c2                	cmp    %eax,%edx
c01044e8:	72 c5                	jb     c01044af <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01044ea:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c01044f0:	89 d0                	mov    %edx,%eax
c01044f2:	c1 e0 02             	shl    $0x2,%eax
c01044f5:	01 d0                	add    %edx,%eax
c01044f7:	c1 e0 02             	shl    $0x2,%eax
c01044fa:	89 c2                	mov    %eax,%edx
c01044fc:	a1 00 cf 11 c0       	mov    0xc011cf00,%eax
c0104501:	01 d0                	add    %edx,%eax
c0104503:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104506:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010450d:	77 23                	ja     c0104532 <page_init+0x23d>
c010450f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104512:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104516:	c7 44 24 08 20 70 10 	movl   $0xc0107020,0x8(%esp)
c010451d:	c0 
c010451e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104525:	00 
c0104526:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010452d:	e8 eb c7 ff ff       	call   c0100d1d <__panic>
c0104532:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104535:	05 00 00 00 40       	add    $0x40000000,%eax
c010453a:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010453d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104544:	e9 53 01 00 00       	jmp    c010469c <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104549:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010454c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010454f:	89 d0                	mov    %edx,%eax
c0104551:	c1 e0 02             	shl    $0x2,%eax
c0104554:	01 d0                	add    %edx,%eax
c0104556:	c1 e0 02             	shl    $0x2,%eax
c0104559:	01 c8                	add    %ecx,%eax
c010455b:	8b 50 08             	mov    0x8(%eax),%edx
c010455e:	8b 40 04             	mov    0x4(%eax),%eax
c0104561:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104564:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104567:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010456a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010456d:	89 d0                	mov    %edx,%eax
c010456f:	c1 e0 02             	shl    $0x2,%eax
c0104572:	01 d0                	add    %edx,%eax
c0104574:	c1 e0 02             	shl    $0x2,%eax
c0104577:	01 c8                	add    %ecx,%eax
c0104579:	8b 48 0c             	mov    0xc(%eax),%ecx
c010457c:	8b 58 10             	mov    0x10(%eax),%ebx
c010457f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104582:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104585:	01 c8                	add    %ecx,%eax
c0104587:	11 da                	adc    %ebx,%edx
c0104589:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010458c:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010458f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104592:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104595:	89 d0                	mov    %edx,%eax
c0104597:	c1 e0 02             	shl    $0x2,%eax
c010459a:	01 d0                	add    %edx,%eax
c010459c:	c1 e0 02             	shl    $0x2,%eax
c010459f:	01 c8                	add    %ecx,%eax
c01045a1:	83 c0 14             	add    $0x14,%eax
c01045a4:	8b 00                	mov    (%eax),%eax
c01045a6:	83 f8 01             	cmp    $0x1,%eax
c01045a9:	0f 85 ea 00 00 00    	jne    c0104699 <page_init+0x3a4>
            if (begin < freemem) {
c01045af:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045b2:	ba 00 00 00 00       	mov    $0x0,%edx
c01045b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01045ba:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01045bd:	19 d1                	sbb    %edx,%ecx
c01045bf:	73 0d                	jae    c01045ce <page_init+0x2d9>
                begin = freemem;
c01045c1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01045c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01045ce:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01045d3:	b8 00 00 00 00       	mov    $0x0,%eax
c01045d8:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01045db:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01045de:	73 0e                	jae    c01045ee <page_init+0x2f9>
                end = KMEMSIZE;
c01045e0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01045e7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01045ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01045f1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01045f4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01045f7:	89 d0                	mov    %edx,%eax
c01045f9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01045fc:	0f 83 97 00 00 00    	jae    c0104699 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c0104602:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104609:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010460c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010460f:	01 d0                	add    %edx,%eax
c0104611:	48                   	dec    %eax
c0104612:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104615:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104618:	ba 00 00 00 00       	mov    $0x0,%edx
c010461d:	f7 75 b0             	divl   -0x50(%ebp)
c0104620:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104623:	29 d0                	sub    %edx,%eax
c0104625:	ba 00 00 00 00       	mov    $0x0,%edx
c010462a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010462d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104630:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104633:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104636:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104639:	ba 00 00 00 00       	mov    $0x0,%edx
c010463e:	89 c7                	mov    %eax,%edi
c0104640:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104646:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104649:	89 d0                	mov    %edx,%eax
c010464b:	83 e0 00             	and    $0x0,%eax
c010464e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104651:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104654:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104657:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010465a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010465d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104660:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104663:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104666:	89 d0                	mov    %edx,%eax
c0104668:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010466b:	73 2c                	jae    c0104699 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010466d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104670:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104673:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0104676:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0104679:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010467d:	c1 ea 0c             	shr    $0xc,%edx
c0104680:	89 c3                	mov    %eax,%ebx
c0104682:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104685:	89 04 24             	mov    %eax,(%esp)
c0104688:	e8 bb f8 ff ff       	call   c0103f48 <pa2page>
c010468d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104691:	89 04 24             	mov    %eax,(%esp)
c0104694:	e8 9e fb ff ff       	call   c0104237 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0104699:	ff 45 dc             	incl   -0x24(%ebp)
c010469c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010469f:	8b 00                	mov    (%eax),%eax
c01046a1:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01046a4:	0f 8c 9f fe ff ff    	jl     c0104549 <page_init+0x254>
                }
            }
        }
    }
}
c01046aa:	90                   	nop
c01046ab:	90                   	nop
c01046ac:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01046b2:	5b                   	pop    %ebx
c01046b3:	5e                   	pop    %esi
c01046b4:	5f                   	pop    %edi
c01046b5:	5d                   	pop    %ebp
c01046b6:	c3                   	ret    

c01046b7 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01046b7:	55                   	push   %ebp
c01046b8:	89 e5                	mov    %esp,%ebp
c01046ba:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01046bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046c0:	33 45 14             	xor    0x14(%ebp),%eax
c01046c3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01046c8:	85 c0                	test   %eax,%eax
c01046ca:	74 24                	je     c01046f0 <boot_map_segment+0x39>
c01046cc:	c7 44 24 0c 52 70 10 	movl   $0xc0107052,0xc(%esp)
c01046d3:	c0 
c01046d4:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01046db:	c0 
c01046dc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01046e3:	00 
c01046e4:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01046eb:	e8 2d c6 ff ff       	call   c0100d1d <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01046f0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01046f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046fa:	25 ff 0f 00 00       	and    $0xfff,%eax
c01046ff:	89 c2                	mov    %eax,%edx
c0104701:	8b 45 10             	mov    0x10(%ebp),%eax
c0104704:	01 c2                	add    %eax,%edx
c0104706:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104709:	01 d0                	add    %edx,%eax
c010470b:	48                   	dec    %eax
c010470c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010470f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104712:	ba 00 00 00 00       	mov    $0x0,%edx
c0104717:	f7 75 f0             	divl   -0x10(%ebp)
c010471a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010471d:	29 d0                	sub    %edx,%eax
c010471f:	c1 e8 0c             	shr    $0xc,%eax
c0104722:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104725:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104728:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010472b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010472e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104733:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104736:	8b 45 14             	mov    0x14(%ebp),%eax
c0104739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010473c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010473f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104744:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104747:	eb 68                	jmp    c01047b1 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104749:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104750:	00 
c0104751:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104754:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104758:	8b 45 08             	mov    0x8(%ebp),%eax
c010475b:	89 04 24             	mov    %eax,(%esp)
c010475e:	e8 88 01 00 00       	call   c01048eb <get_pte>
c0104763:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104766:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010476a:	75 24                	jne    c0104790 <boot_map_segment+0xd9>
c010476c:	c7 44 24 0c 7e 70 10 	movl   $0xc010707e,0xc(%esp)
c0104773:	c0 
c0104774:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010477b:	c0 
c010477c:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0104783:	00 
c0104784:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010478b:	e8 8d c5 ff ff       	call   c0100d1d <__panic>
        *ptep = pa | PTE_P | perm;
c0104790:	8b 45 14             	mov    0x14(%ebp),%eax
c0104793:	0b 45 18             	or     0x18(%ebp),%eax
c0104796:	83 c8 01             	or     $0x1,%eax
c0104799:	89 c2                	mov    %eax,%edx
c010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010479e:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01047a0:	ff 4d f4             	decl   -0xc(%ebp)
c01047a3:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01047aa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01047b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047b5:	75 92                	jne    c0104749 <boot_map_segment+0x92>
    }
}
c01047b7:	90                   	nop
c01047b8:	90                   	nop
c01047b9:	89 ec                	mov    %ebp,%esp
c01047bb:	5d                   	pop    %ebp
c01047bc:	c3                   	ret    

c01047bd <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01047bd:	55                   	push   %ebp
c01047be:	89 e5                	mov    %esp,%ebp
c01047c0:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01047c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047ca:	e8 8a fa ff ff       	call   c0104259 <alloc_pages>
c01047cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01047d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047d6:	75 1c                	jne    c01047f4 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01047d8:	c7 44 24 08 8b 70 10 	movl   $0xc010708b,0x8(%esp)
c01047df:	c0 
c01047e0:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c01047e7:	00 
c01047e8:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01047ef:	e8 29 c5 ff ff       	call   c0100d1d <__panic>
    }
    return page2kva(p);
c01047f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f7:	89 04 24             	mov    %eax,(%esp)
c01047fa:	e8 9a f7 ff ff       	call   c0103f99 <page2kva>
}
c01047ff:	89 ec                	mov    %ebp,%esp
c0104801:	5d                   	pop    %ebp
c0104802:	c3                   	ret    

c0104803 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104803:	55                   	push   %ebp
c0104804:	89 e5                	mov    %esp,%ebp
c0104806:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104809:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010480e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104811:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104818:	77 23                	ja     c010483d <pmm_init+0x3a>
c010481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010481d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104821:	c7 44 24 08 20 70 10 	movl   $0xc0107020,0x8(%esp)
c0104828:	c0 
c0104829:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0104830:	00 
c0104831:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104838:	e8 e0 c4 ff ff       	call   c0100d1d <__panic>
c010483d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104840:	05 00 00 00 40       	add    $0x40000000,%eax
c0104845:	a3 08 cf 11 c0       	mov    %eax,0xc011cf08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010484a:	e8 b2 f9 ff ff       	call   c0104201 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010484f:	e8 a1 fa ff ff       	call   c01042f5 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104854:	e8 ed 03 00 00       	call   c0104c46 <check_alloc_page>

    check_pgdir();
c0104859:	e8 09 04 00 00       	call   c0104c67 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010485e:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104863:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104866:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010486d:	77 23                	ja     c0104892 <pmm_init+0x8f>
c010486f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104872:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104876:	c7 44 24 08 20 70 10 	movl   $0xc0107020,0x8(%esp)
c010487d:	c0 
c010487e:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c0104885:	00 
c0104886:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010488d:	e8 8b c4 ff ff       	call   c0100d1d <__panic>
c0104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104895:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010489b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01048a0:	05 ac 0f 00 00       	add    $0xfac,%eax
c01048a5:	83 ca 03             	or     $0x3,%edx
c01048a8:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01048aa:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01048af:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01048b6:	00 
c01048b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01048be:	00 
c01048bf:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01048c6:	38 
c01048c7:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01048ce:	c0 
c01048cf:	89 04 24             	mov    %eax,(%esp)
c01048d2:	e8 e0 fd ff ff       	call   c01046b7 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01048d7:	e8 39 f8 ff ff       	call   c0104115 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01048dc:	e8 24 0a 00 00       	call   c0105305 <check_boot_pgdir>

    print_pgdir();
c01048e1:	e8 a1 0e 00 00       	call   c0105787 <print_pgdir>

}
c01048e6:	90                   	nop
c01048e7:	89 ec                	mov    %ebp,%esp
c01048e9:	5d                   	pop    %ebp
c01048ea:	c3                   	ret    

c01048eb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01048eb:	55                   	push   %ebp
c01048ec:	89 e5                	mov    %esp,%ebp
c01048ee:	83 ec 38             	sub    $0x38,%esp
        }
        return NULL;          // (8) return page table entry
    #endif
    */
   
   pde_t *pdep = &pgdir[PDX(la)];
c01048f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048f4:	c1 e8 16             	shr    $0x16,%eax
c01048f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01048fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104901:	01 d0                	add    %edx,%eax
c0104903:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104909:	8b 00                	mov    (%eax),%eax
c010490b:	83 e0 01             	and    $0x1,%eax
c010490e:	85 c0                	test   %eax,%eax
c0104910:	0f 85 af 00 00 00    	jne    c01049c5 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0104916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010491a:	74 15                	je     c0104931 <get_pte+0x46>
c010491c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104923:	e8 31 f9 ff ff       	call   c0104259 <alloc_pages>
c0104928:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010492b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010492f:	75 0a                	jne    c010493b <get_pte+0x50>
            return NULL;
c0104931:	b8 00 00 00 00       	mov    $0x0,%eax
c0104936:	e9 e7 00 00 00       	jmp    c0104a22 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c010493b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104942:	00 
c0104943:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104946:	89 04 24             	mov    %eax,(%esp)
c0104949:	e8 05 f7 ff ff       	call   c0104053 <set_page_ref>
        uintptr_t pa = page2pa(page);
c010494e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104951:	89 04 24             	mov    %eax,(%esp)
c0104954:	e8 d7 f5 ff ff       	call   c0103f30 <page2pa>
c0104959:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c010495c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010495f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104962:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104965:	c1 e8 0c             	shr    $0xc,%eax
c0104968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010496b:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104970:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104973:	72 23                	jb     c0104998 <get_pte+0xad>
c0104975:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104978:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010497c:	c7 44 24 08 7c 6f 10 	movl   $0xc0106f7c,0x8(%esp)
c0104983:	c0 
c0104984:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c010498b:	00 
c010498c:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104993:	e8 85 c3 ff ff       	call   c0100d1d <__panic>
c0104998:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010499b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01049a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01049a7:	00 
c01049a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01049af:	00 
c01049b0:	89 04 24             	mov    %eax,(%esp)
c01049b3:	e8 d4 18 00 00       	call   c010628c <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01049b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049bb:	83 c8 07             	or     $0x7,%eax
c01049be:	89 c2                	mov    %eax,%edx
c01049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c3:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c8:	8b 00                	mov    (%eax),%eax
c01049ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01049d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049d5:	c1 e8 0c             	shr    $0xc,%eax
c01049d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01049db:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01049e0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01049e3:	72 23                	jb     c0104a08 <get_pte+0x11d>
c01049e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049ec:	c7 44 24 08 7c 6f 10 	movl   $0xc0106f7c,0x8(%esp)
c01049f3:	c0 
c01049f4:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c01049fb:	00 
c01049fc:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104a03:	e8 15 c3 ff ff       	call   c0100d1d <__panic>
c0104a08:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a0b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104a10:	89 c2                	mov    %eax,%edx
c0104a12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a15:	c1 e8 0c             	shr    $0xc,%eax
c0104a18:	25 ff 03 00 00       	and    $0x3ff,%eax
c0104a1d:	c1 e0 02             	shl    $0x2,%eax
c0104a20:	01 d0                	add    %edx,%eax
}
c0104a22:	89 ec                	mov    %ebp,%esp
c0104a24:	5d                   	pop    %ebp
c0104a25:	c3                   	ret    

c0104a26 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104a26:	55                   	push   %ebp
c0104a27:	89 e5                	mov    %esp,%ebp
c0104a29:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104a2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a33:	00 
c0104a34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a3e:	89 04 24             	mov    %eax,(%esp)
c0104a41:	e8 a5 fe ff ff       	call   c01048eb <get_pte>
c0104a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104a49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104a4d:	74 08                	je     c0104a57 <get_page+0x31>
        *ptep_store = ptep;
c0104a4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a55:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104a57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a5b:	74 1b                	je     c0104a78 <get_page+0x52>
c0104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a60:	8b 00                	mov    (%eax),%eax
c0104a62:	83 e0 01             	and    $0x1,%eax
c0104a65:	85 c0                	test   %eax,%eax
c0104a67:	74 0f                	je     c0104a78 <get_page+0x52>
        return pte2page(*ptep);
c0104a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6c:	8b 00                	mov    (%eax),%eax
c0104a6e:	89 04 24             	mov    %eax,(%esp)
c0104a71:	e8 79 f5 ff ff       	call   c0103fef <pte2page>
c0104a76:	eb 05                	jmp    c0104a7d <get_page+0x57>
    }
    return NULL;
c0104a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104a7d:	89 ec                	mov    %ebp,%esp
c0104a7f:	5d                   	pop    %ebp
c0104a80:	c3                   	ret    

c0104a81 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104a81:	55                   	push   %ebp
c0104a82:	89 e5                	mov    %esp,%ebp
c0104a84:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
*/

   	if (*ptep & PTE_P) {
c0104a87:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a8a:	8b 00                	mov    (%eax),%eax
c0104a8c:	83 e0 01             	and    $0x1,%eax
c0104a8f:	85 c0                	test   %eax,%eax
c0104a91:	74 4d                	je     c0104ae0 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104a93:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a96:	8b 00                	mov    (%eax),%eax
c0104a98:	89 04 24             	mov    %eax,(%esp)
c0104a9b:	e8 4f f5 ff ff       	call   c0103fef <pte2page>
c0104aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aa6:	89 04 24             	mov    %eax,(%esp)
c0104aa9:	e8 ca f5 ff ff       	call   c0104078 <page_ref_dec>
c0104aae:	85 c0                	test   %eax,%eax
c0104ab0:	75 13                	jne    c0104ac5 <page_remove_pte+0x44>
            free_page(page);
c0104ab2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ab9:	00 
c0104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104abd:	89 04 24             	mov    %eax,(%esp)
c0104ac0:	e8 ce f7 ff ff       	call   c0104293 <free_pages>
        }
        *ptep = 0;
c0104ac5:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ac8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104ace:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ad8:	89 04 24             	mov    %eax,(%esp)
c0104adb:	e8 07 01 00 00       	call   c0104be7 <tlb_invalidate>
    }

}
c0104ae0:	90                   	nop
c0104ae1:	89 ec                	mov    %ebp,%esp
c0104ae3:	5d                   	pop    %ebp
c0104ae4:	c3                   	ret    

c0104ae5 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104ae5:	55                   	push   %ebp
c0104ae6:	89 e5                	mov    %esp,%ebp
c0104ae8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104aeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104af2:	00 
c0104af3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104af6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0104afd:	89 04 24             	mov    %eax,(%esp)
c0104b00:	e8 e6 fd ff ff       	call   c01048eb <get_pte>
c0104b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104b08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b0c:	74 19                	je     c0104b27 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b11:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104b15:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b1f:	89 04 24             	mov    %eax,(%esp)
c0104b22:	e8 5a ff ff ff       	call   c0104a81 <page_remove_pte>
    }
}
c0104b27:	90                   	nop
c0104b28:	89 ec                	mov    %ebp,%esp
c0104b2a:	5d                   	pop    %ebp
c0104b2b:	c3                   	ret    

c0104b2c <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104b2c:	55                   	push   %ebp
c0104b2d:	89 e5                	mov    %esp,%ebp
c0104b2f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104b32:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104b39:	00 
c0104b3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b44:	89 04 24             	mov    %eax,(%esp)
c0104b47:	e8 9f fd ff ff       	call   c01048eb <get_pte>
c0104b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104b4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b53:	75 0a                	jne    c0104b5f <page_insert+0x33>
        return -E_NO_MEM;
c0104b55:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104b5a:	e9 84 00 00 00       	jmp    c0104be3 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b62:	89 04 24             	mov    %eax,(%esp)
c0104b65:	e8 f7 f4 ff ff       	call   c0104061 <page_ref_inc>
    if (*ptep & PTE_P) {
c0104b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b6d:	8b 00                	mov    (%eax),%eax
c0104b6f:	83 e0 01             	and    $0x1,%eax
c0104b72:	85 c0                	test   %eax,%eax
c0104b74:	74 3e                	je     c0104bb4 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b79:	8b 00                	mov    (%eax),%eax
c0104b7b:	89 04 24             	mov    %eax,(%esp)
c0104b7e:	e8 6c f4 ff ff       	call   c0103fef <pte2page>
c0104b83:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b89:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104b8c:	75 0d                	jne    c0104b9b <page_insert+0x6f>
            page_ref_dec(page);
c0104b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b91:	89 04 24             	mov    %eax,(%esp)
c0104b94:	e8 df f4 ff ff       	call   c0104078 <page_ref_dec>
c0104b99:	eb 19                	jmp    c0104bb4 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104ba2:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bac:	89 04 24             	mov    %eax,(%esp)
c0104baf:	e8 cd fe ff ff       	call   c0104a81 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bb7:	89 04 24             	mov    %eax,(%esp)
c0104bba:	e8 71 f3 ff ff       	call   c0103f30 <page2pa>
c0104bbf:	0b 45 14             	or     0x14(%ebp),%eax
c0104bc2:	83 c8 01             	or     $0x1,%eax
c0104bc5:	89 c2                	mov    %eax,%edx
c0104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bca:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104bcc:	8b 45 10             	mov    0x10(%ebp),%eax
c0104bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bd6:	89 04 24             	mov    %eax,(%esp)
c0104bd9:	e8 09 00 00 00       	call   c0104be7 <tlb_invalidate>
    return 0;
c0104bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104be3:	89 ec                	mov    %ebp,%esp
c0104be5:	5d                   	pop    %ebp
c0104be6:	c3                   	ret    

c0104be7 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104be7:	55                   	push   %ebp
c0104be8:	89 e5                	mov    %esp,%ebp
c0104bea:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104bed:	0f 20 d8             	mov    %cr3,%eax
c0104bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104bf3:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bfc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104c03:	77 23                	ja     c0104c28 <tlb_invalidate+0x41>
c0104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c0c:	c7 44 24 08 20 70 10 	movl   $0xc0107020,0x8(%esp)
c0104c13:	c0 
c0104c14:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0104c1b:	00 
c0104c1c:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104c23:	e8 f5 c0 ff ff       	call   c0100d1d <__panic>
c0104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2b:	05 00 00 00 40       	add    $0x40000000,%eax
c0104c30:	39 d0                	cmp    %edx,%eax
c0104c32:	75 0d                	jne    c0104c41 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0104c34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c3d:	0f 01 38             	invlpg (%eax)
}
c0104c40:	90                   	nop
    }
}
c0104c41:	90                   	nop
c0104c42:	89 ec                	mov    %ebp,%esp
c0104c44:	5d                   	pop    %ebp
c0104c45:	c3                   	ret    

c0104c46 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104c46:	55                   	push   %ebp
c0104c47:	89 e5                	mov    %esp,%ebp
c0104c49:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104c4c:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104c51:	8b 40 18             	mov    0x18(%eax),%eax
c0104c54:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104c56:	c7 04 24 a4 70 10 c0 	movl   $0xc01070a4,(%esp)
c0104c5d:	e8 39 b7 ff ff       	call   c010039b <cprintf>
}
c0104c62:	90                   	nop
c0104c63:	89 ec                	mov    %ebp,%esp
c0104c65:	5d                   	pop    %ebp
c0104c66:	c3                   	ret    

c0104c67 <check_pgdir>:

static void
check_pgdir(void) {
c0104c67:	55                   	push   %ebp
c0104c68:	89 e5                	mov    %esp,%ebp
c0104c6a:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104c6d:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104c72:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104c77:	76 24                	jbe    c0104c9d <check_pgdir+0x36>
c0104c79:	c7 44 24 0c c3 70 10 	movl   $0xc01070c3,0xc(%esp)
c0104c80:	c0 
c0104c81:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104c88:	c0 
c0104c89:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104c90:	00 
c0104c91:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104c98:	e8 80 c0 ff ff       	call   c0100d1d <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104c9d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ca2:	85 c0                	test   %eax,%eax
c0104ca4:	74 0e                	je     c0104cb4 <check_pgdir+0x4d>
c0104ca6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104cab:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104cb0:	85 c0                	test   %eax,%eax
c0104cb2:	74 24                	je     c0104cd8 <check_pgdir+0x71>
c0104cb4:	c7 44 24 0c e0 70 10 	movl   $0xc01070e0,0xc(%esp)
c0104cbb:	c0 
c0104cbc:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104cc3:	c0 
c0104cc4:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104ccb:	00 
c0104ccc:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104cd3:	e8 45 c0 ff ff       	call   c0100d1d <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104cd8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104cdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ce4:	00 
c0104ce5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cec:	00 
c0104ced:	89 04 24             	mov    %eax,(%esp)
c0104cf0:	e8 31 fd ff ff       	call   c0104a26 <get_page>
c0104cf5:	85 c0                	test   %eax,%eax
c0104cf7:	74 24                	je     c0104d1d <check_pgdir+0xb6>
c0104cf9:	c7 44 24 0c 18 71 10 	movl   $0xc0107118,0xc(%esp)
c0104d00:	c0 
c0104d01:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104d08:	c0 
c0104d09:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0104d10:	00 
c0104d11:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104d18:	e8 00 c0 ff ff       	call   c0100d1d <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104d1d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d24:	e8 30 f5 ff ff       	call   c0104259 <alloc_pages>
c0104d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104d2c:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104d31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104d38:	00 
c0104d39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d40:	00 
c0104d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104d44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104d48:	89 04 24             	mov    %eax,(%esp)
c0104d4b:	e8 dc fd ff ff       	call   c0104b2c <page_insert>
c0104d50:	85 c0                	test   %eax,%eax
c0104d52:	74 24                	je     c0104d78 <check_pgdir+0x111>
c0104d54:	c7 44 24 0c 40 71 10 	movl   $0xc0107140,0xc(%esp)
c0104d5b:	c0 
c0104d5c:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104d63:	c0 
c0104d64:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0104d6b:	00 
c0104d6c:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104d73:	e8 a5 bf ff ff       	call   c0100d1d <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104d78:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104d7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d84:	00 
c0104d85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d8c:	00 
c0104d8d:	89 04 24             	mov    %eax,(%esp)
c0104d90:	e8 56 fb ff ff       	call   c01048eb <get_pte>
c0104d95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d9c:	75 24                	jne    c0104dc2 <check_pgdir+0x15b>
c0104d9e:	c7 44 24 0c 6c 71 10 	movl   $0xc010716c,0xc(%esp)
c0104da5:	c0 
c0104da6:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104dad:	c0 
c0104dae:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104db5:	00 
c0104db6:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104dbd:	e8 5b bf ff ff       	call   c0100d1d <__panic>
    assert(pte2page(*ptep) == p1);
c0104dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dc5:	8b 00                	mov    (%eax),%eax
c0104dc7:	89 04 24             	mov    %eax,(%esp)
c0104dca:	e8 20 f2 ff ff       	call   c0103fef <pte2page>
c0104dcf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104dd2:	74 24                	je     c0104df8 <check_pgdir+0x191>
c0104dd4:	c7 44 24 0c 99 71 10 	movl   $0xc0107199,0xc(%esp)
c0104ddb:	c0 
c0104ddc:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104de3:	c0 
c0104de4:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104deb:	00 
c0104dec:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104df3:	e8 25 bf ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p1) == 1);
c0104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dfb:	89 04 24             	mov    %eax,(%esp)
c0104dfe:	e8 46 f2 ff ff       	call   c0104049 <page_ref>
c0104e03:	83 f8 01             	cmp    $0x1,%eax
c0104e06:	74 24                	je     c0104e2c <check_pgdir+0x1c5>
c0104e08:	c7 44 24 0c af 71 10 	movl   $0xc01071af,0xc(%esp)
c0104e0f:	c0 
c0104e10:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104e17:	c0 
c0104e18:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104e1f:	00 
c0104e20:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104e27:	e8 f1 be ff ff       	call   c0100d1d <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104e2c:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104e31:	8b 00                	mov    (%eax),%eax
c0104e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e38:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e3e:	c1 e8 0c             	shr    $0xc,%eax
c0104e41:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e44:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104e49:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104e4c:	72 23                	jb     c0104e71 <check_pgdir+0x20a>
c0104e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e51:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e55:	c7 44 24 08 7c 6f 10 	movl   $0xc0106f7c,0x8(%esp)
c0104e5c:	c0 
c0104e5d:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0104e64:	00 
c0104e65:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104e6c:	e8 ac be ff ff       	call   c0100d1d <__panic>
c0104e71:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e74:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104e79:	83 c0 04             	add    $0x4,%eax
c0104e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104e7f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104e84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e8b:	00 
c0104e8c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104e93:	00 
c0104e94:	89 04 24             	mov    %eax,(%esp)
c0104e97:	e8 4f fa ff ff       	call   c01048eb <get_pte>
c0104e9c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104e9f:	74 24                	je     c0104ec5 <check_pgdir+0x25e>
c0104ea1:	c7 44 24 0c c4 71 10 	movl   $0xc01071c4,0xc(%esp)
c0104ea8:	c0 
c0104ea9:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104eb0:	c0 
c0104eb1:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104eb8:	00 
c0104eb9:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104ec0:	e8 58 be ff ff       	call   c0100d1d <__panic>

    p2 = alloc_page();
c0104ec5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ecc:	e8 88 f3 ff ff       	call   c0104259 <alloc_pages>
c0104ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104ed4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ed9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104ee0:	00 
c0104ee1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ee8:	00 
c0104ee9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104eec:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ef0:	89 04 24             	mov    %eax,(%esp)
c0104ef3:	e8 34 fc ff ff       	call   c0104b2c <page_insert>
c0104ef8:	85 c0                	test   %eax,%eax
c0104efa:	74 24                	je     c0104f20 <check_pgdir+0x2b9>
c0104efc:	c7 44 24 0c ec 71 10 	movl   $0xc01071ec,0xc(%esp)
c0104f03:	c0 
c0104f04:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104f0b:	c0 
c0104f0c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104f13:	00 
c0104f14:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104f1b:	e8 fd bd ff ff       	call   c0100d1d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104f20:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104f25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f2c:	00 
c0104f2d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104f34:	00 
c0104f35:	89 04 24             	mov    %eax,(%esp)
c0104f38:	e8 ae f9 ff ff       	call   c01048eb <get_pte>
c0104f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f44:	75 24                	jne    c0104f6a <check_pgdir+0x303>
c0104f46:	c7 44 24 0c 24 72 10 	movl   $0xc0107224,0xc(%esp)
c0104f4d:	c0 
c0104f4e:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104f55:	c0 
c0104f56:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0104f5d:	00 
c0104f5e:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104f65:	e8 b3 bd ff ff       	call   c0100d1d <__panic>
    assert(*ptep & PTE_U);
c0104f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f6d:	8b 00                	mov    (%eax),%eax
c0104f6f:	83 e0 04             	and    $0x4,%eax
c0104f72:	85 c0                	test   %eax,%eax
c0104f74:	75 24                	jne    c0104f9a <check_pgdir+0x333>
c0104f76:	c7 44 24 0c 54 72 10 	movl   $0xc0107254,0xc(%esp)
c0104f7d:	c0 
c0104f7e:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104f85:	c0 
c0104f86:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104f8d:	00 
c0104f8e:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104f95:	e8 83 bd ff ff       	call   c0100d1d <__panic>
    assert(*ptep & PTE_W);
c0104f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f9d:	8b 00                	mov    (%eax),%eax
c0104f9f:	83 e0 02             	and    $0x2,%eax
c0104fa2:	85 c0                	test   %eax,%eax
c0104fa4:	75 24                	jne    c0104fca <check_pgdir+0x363>
c0104fa6:	c7 44 24 0c 62 72 10 	movl   $0xc0107262,0xc(%esp)
c0104fad:	c0 
c0104fae:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104fb5:	c0 
c0104fb6:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104fbd:	00 
c0104fbe:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104fc5:	e8 53 bd ff ff       	call   c0100d1d <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104fca:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104fcf:	8b 00                	mov    (%eax),%eax
c0104fd1:	83 e0 04             	and    $0x4,%eax
c0104fd4:	85 c0                	test   %eax,%eax
c0104fd6:	75 24                	jne    c0104ffc <check_pgdir+0x395>
c0104fd8:	c7 44 24 0c 70 72 10 	movl   $0xc0107270,0xc(%esp)
c0104fdf:	c0 
c0104fe0:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0104fe7:	c0 
c0104fe8:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104fef:	00 
c0104ff0:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0104ff7:	e8 21 bd ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p2) == 1);
c0104ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fff:	89 04 24             	mov    %eax,(%esp)
c0105002:	e8 42 f0 ff ff       	call   c0104049 <page_ref>
c0105007:	83 f8 01             	cmp    $0x1,%eax
c010500a:	74 24                	je     c0105030 <check_pgdir+0x3c9>
c010500c:	c7 44 24 0c 86 72 10 	movl   $0xc0107286,0xc(%esp)
c0105013:	c0 
c0105014:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010501b:	c0 
c010501c:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0105023:	00 
c0105024:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010502b:	e8 ed bc ff ff       	call   c0100d1d <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105030:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010503c:	00 
c010503d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105044:	00 
c0105045:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105048:	89 54 24 04          	mov    %edx,0x4(%esp)
c010504c:	89 04 24             	mov    %eax,(%esp)
c010504f:	e8 d8 fa ff ff       	call   c0104b2c <page_insert>
c0105054:	85 c0                	test   %eax,%eax
c0105056:	74 24                	je     c010507c <check_pgdir+0x415>
c0105058:	c7 44 24 0c 98 72 10 	movl   $0xc0107298,0xc(%esp)
c010505f:	c0 
c0105060:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105067:	c0 
c0105068:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c010506f:	00 
c0105070:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105077:	e8 a1 bc ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p1) == 2);
c010507c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010507f:	89 04 24             	mov    %eax,(%esp)
c0105082:	e8 c2 ef ff ff       	call   c0104049 <page_ref>
c0105087:	83 f8 02             	cmp    $0x2,%eax
c010508a:	74 24                	je     c01050b0 <check_pgdir+0x449>
c010508c:	c7 44 24 0c c4 72 10 	movl   $0xc01072c4,0xc(%esp)
c0105093:	c0 
c0105094:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010509b:	c0 
c010509c:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c01050a3:	00 
c01050a4:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01050ab:	e8 6d bc ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p2) == 0);
c01050b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050b3:	89 04 24             	mov    %eax,(%esp)
c01050b6:	e8 8e ef ff ff       	call   c0104049 <page_ref>
c01050bb:	85 c0                	test   %eax,%eax
c01050bd:	74 24                	je     c01050e3 <check_pgdir+0x47c>
c01050bf:	c7 44 24 0c d6 72 10 	movl   $0xc01072d6,0xc(%esp)
c01050c6:	c0 
c01050c7:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01050ce:	c0 
c01050cf:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c01050d6:	00 
c01050d7:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01050de:	e8 3a bc ff ff       	call   c0100d1d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01050e3:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050ef:	00 
c01050f0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01050f7:	00 
c01050f8:	89 04 24             	mov    %eax,(%esp)
c01050fb:	e8 eb f7 ff ff       	call   c01048eb <get_pte>
c0105100:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105103:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105107:	75 24                	jne    c010512d <check_pgdir+0x4c6>
c0105109:	c7 44 24 0c 24 72 10 	movl   $0xc0107224,0xc(%esp)
c0105110:	c0 
c0105111:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105118:	c0 
c0105119:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0105120:	00 
c0105121:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105128:	e8 f0 bb ff ff       	call   c0100d1d <__panic>
    assert(pte2page(*ptep) == p1);
c010512d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105130:	8b 00                	mov    (%eax),%eax
c0105132:	89 04 24             	mov    %eax,(%esp)
c0105135:	e8 b5 ee ff ff       	call   c0103fef <pte2page>
c010513a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010513d:	74 24                	je     c0105163 <check_pgdir+0x4fc>
c010513f:	c7 44 24 0c 99 71 10 	movl   $0xc0107199,0xc(%esp)
c0105146:	c0 
c0105147:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010514e:	c0 
c010514f:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105156:	00 
c0105157:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010515e:	e8 ba bb ff ff       	call   c0100d1d <__panic>
    assert((*ptep & PTE_U) == 0);
c0105163:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105166:	8b 00                	mov    (%eax),%eax
c0105168:	83 e0 04             	and    $0x4,%eax
c010516b:	85 c0                	test   %eax,%eax
c010516d:	74 24                	je     c0105193 <check_pgdir+0x52c>
c010516f:	c7 44 24 0c e8 72 10 	movl   $0xc01072e8,0xc(%esp)
c0105176:	c0 
c0105177:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010517e:	c0 
c010517f:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0105186:	00 
c0105187:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010518e:	e8 8a bb ff ff       	call   c0100d1d <__panic>

    page_remove(boot_pgdir, 0x0);
c0105193:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010519f:	00 
c01051a0:	89 04 24             	mov    %eax,(%esp)
c01051a3:	e8 3d f9 ff ff       	call   c0104ae5 <page_remove>
    assert(page_ref(p1) == 1);
c01051a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051ab:	89 04 24             	mov    %eax,(%esp)
c01051ae:	e8 96 ee ff ff       	call   c0104049 <page_ref>
c01051b3:	83 f8 01             	cmp    $0x1,%eax
c01051b6:	74 24                	je     c01051dc <check_pgdir+0x575>
c01051b8:	c7 44 24 0c af 71 10 	movl   $0xc01071af,0xc(%esp)
c01051bf:	c0 
c01051c0:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01051c7:	c0 
c01051c8:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c01051cf:	00 
c01051d0:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01051d7:	e8 41 bb ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p2) == 0);
c01051dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051df:	89 04 24             	mov    %eax,(%esp)
c01051e2:	e8 62 ee ff ff       	call   c0104049 <page_ref>
c01051e7:	85 c0                	test   %eax,%eax
c01051e9:	74 24                	je     c010520f <check_pgdir+0x5a8>
c01051eb:	c7 44 24 0c d6 72 10 	movl   $0xc01072d6,0xc(%esp)
c01051f2:	c0 
c01051f3:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01051fa:	c0 
c01051fb:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0105202:	00 
c0105203:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010520a:	e8 0e bb ff ff       	call   c0100d1d <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010520f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105214:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010521b:	00 
c010521c:	89 04 24             	mov    %eax,(%esp)
c010521f:	e8 c1 f8 ff ff       	call   c0104ae5 <page_remove>
    assert(page_ref(p1) == 0);
c0105224:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105227:	89 04 24             	mov    %eax,(%esp)
c010522a:	e8 1a ee ff ff       	call   c0104049 <page_ref>
c010522f:	85 c0                	test   %eax,%eax
c0105231:	74 24                	je     c0105257 <check_pgdir+0x5f0>
c0105233:	c7 44 24 0c fd 72 10 	movl   $0xc01072fd,0xc(%esp)
c010523a:	c0 
c010523b:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105242:	c0 
c0105243:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c010524a:	00 
c010524b:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105252:	e8 c6 ba ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p2) == 0);
c0105257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010525a:	89 04 24             	mov    %eax,(%esp)
c010525d:	e8 e7 ed ff ff       	call   c0104049 <page_ref>
c0105262:	85 c0                	test   %eax,%eax
c0105264:	74 24                	je     c010528a <check_pgdir+0x623>
c0105266:	c7 44 24 0c d6 72 10 	movl   $0xc01072d6,0xc(%esp)
c010526d:	c0 
c010526e:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105275:	c0 
c0105276:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c010527d:	00 
c010527e:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105285:	e8 93 ba ff ff       	call   c0100d1d <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010528a:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010528f:	8b 00                	mov    (%eax),%eax
c0105291:	89 04 24             	mov    %eax,(%esp)
c0105294:	e8 96 ed ff ff       	call   c010402f <pde2page>
c0105299:	89 04 24             	mov    %eax,(%esp)
c010529c:	e8 a8 ed ff ff       	call   c0104049 <page_ref>
c01052a1:	83 f8 01             	cmp    $0x1,%eax
c01052a4:	74 24                	je     c01052ca <check_pgdir+0x663>
c01052a6:	c7 44 24 0c 10 73 10 	movl   $0xc0107310,0xc(%esp)
c01052ad:	c0 
c01052ae:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01052b5:	c0 
c01052b6:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c01052bd:	00 
c01052be:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01052c5:	e8 53 ba ff ff       	call   c0100d1d <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01052ca:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01052cf:	8b 00                	mov    (%eax),%eax
c01052d1:	89 04 24             	mov    %eax,(%esp)
c01052d4:	e8 56 ed ff ff       	call   c010402f <pde2page>
c01052d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052e0:	00 
c01052e1:	89 04 24             	mov    %eax,(%esp)
c01052e4:	e8 aa ef ff ff       	call   c0104293 <free_pages>
    boot_pgdir[0] = 0;
c01052e9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01052ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01052f4:	c7 04 24 37 73 10 c0 	movl   $0xc0107337,(%esp)
c01052fb:	e8 9b b0 ff ff       	call   c010039b <cprintf>
}
c0105300:	90                   	nop
c0105301:	89 ec                	mov    %ebp,%esp
c0105303:	5d                   	pop    %ebp
c0105304:	c3                   	ret    

c0105305 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105305:	55                   	push   %ebp
c0105306:	89 e5                	mov    %esp,%ebp
c0105308:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010530b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105312:	e9 ca 00 00 00       	jmp    c01053e1 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105317:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010531a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010531d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105320:	c1 e8 0c             	shr    $0xc,%eax
c0105323:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105326:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c010532b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010532e:	72 23                	jb     c0105353 <check_boot_pgdir+0x4e>
c0105330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105333:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105337:	c7 44 24 08 7c 6f 10 	movl   $0xc0106f7c,0x8(%esp)
c010533e:	c0 
c010533f:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105346:	00 
c0105347:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010534e:	e8 ca b9 ff ff       	call   c0100d1d <__panic>
c0105353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105356:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010535b:	89 c2                	mov    %eax,%edx
c010535d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105369:	00 
c010536a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010536e:	89 04 24             	mov    %eax,(%esp)
c0105371:	e8 75 f5 ff ff       	call   c01048eb <get_pte>
c0105376:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105379:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010537d:	75 24                	jne    c01053a3 <check_boot_pgdir+0x9e>
c010537f:	c7 44 24 0c 54 73 10 	movl   $0xc0107354,0xc(%esp)
c0105386:	c0 
c0105387:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010538e:	c0 
c010538f:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105396:	00 
c0105397:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010539e:	e8 7a b9 ff ff       	call   c0100d1d <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01053a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053a6:	8b 00                	mov    (%eax),%eax
c01053a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01053ad:	89 c2                	mov    %eax,%edx
c01053af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053b2:	39 c2                	cmp    %eax,%edx
c01053b4:	74 24                	je     c01053da <check_boot_pgdir+0xd5>
c01053b6:	c7 44 24 0c 91 73 10 	movl   $0xc0107391,0xc(%esp)
c01053bd:	c0 
c01053be:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01053c5:	c0 
c01053c6:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01053cd:	00 
c01053ce:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01053d5:	e8 43 b9 ff ff       	call   c0100d1d <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01053da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01053e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053e4:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01053e9:	39 c2                	cmp    %eax,%edx
c01053eb:	0f 82 26 ff ff ff    	jb     c0105317 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01053f1:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01053f6:	05 ac 0f 00 00       	add    $0xfac,%eax
c01053fb:	8b 00                	mov    (%eax),%eax
c01053fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105402:	89 c2                	mov    %eax,%edx
c0105404:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105409:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010540c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105413:	77 23                	ja     c0105438 <check_boot_pgdir+0x133>
c0105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105418:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010541c:	c7 44 24 08 20 70 10 	movl   $0xc0107020,0x8(%esp)
c0105423:	c0 
c0105424:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c010542b:	00 
c010542c:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105433:	e8 e5 b8 ff ff       	call   c0100d1d <__panic>
c0105438:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010543b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105440:	39 d0                	cmp    %edx,%eax
c0105442:	74 24                	je     c0105468 <check_boot_pgdir+0x163>
c0105444:	c7 44 24 0c a8 73 10 	movl   $0xc01073a8,0xc(%esp)
c010544b:	c0 
c010544c:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105453:	c0 
c0105454:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c010545b:	00 
c010545c:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105463:	e8 b5 b8 ff ff       	call   c0100d1d <__panic>

    assert(boot_pgdir[0] == 0);
c0105468:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010546d:	8b 00                	mov    (%eax),%eax
c010546f:	85 c0                	test   %eax,%eax
c0105471:	74 24                	je     c0105497 <check_boot_pgdir+0x192>
c0105473:	c7 44 24 0c dc 73 10 	movl   $0xc01073dc,0xc(%esp)
c010547a:	c0 
c010547b:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105482:	c0 
c0105483:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c010548a:	00 
c010548b:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105492:	e8 86 b8 ff ff       	call   c0100d1d <__panic>

    struct Page *p;
    p = alloc_page();
c0105497:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010549e:	e8 b6 ed ff ff       	call   c0104259 <alloc_pages>
c01054a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01054a6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01054ab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01054b2:	00 
c01054b3:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01054ba:	00 
c01054bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054be:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054c2:	89 04 24             	mov    %eax,(%esp)
c01054c5:	e8 62 f6 ff ff       	call   c0104b2c <page_insert>
c01054ca:	85 c0                	test   %eax,%eax
c01054cc:	74 24                	je     c01054f2 <check_boot_pgdir+0x1ed>
c01054ce:	c7 44 24 0c f0 73 10 	movl   $0xc01073f0,0xc(%esp)
c01054d5:	c0 
c01054d6:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01054dd:	c0 
c01054de:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c01054e5:	00 
c01054e6:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01054ed:	e8 2b b8 ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p) == 1);
c01054f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054f5:	89 04 24             	mov    %eax,(%esp)
c01054f8:	e8 4c eb ff ff       	call   c0104049 <page_ref>
c01054fd:	83 f8 01             	cmp    $0x1,%eax
c0105500:	74 24                	je     c0105526 <check_boot_pgdir+0x221>
c0105502:	c7 44 24 0c 1e 74 10 	movl   $0xc010741e,0xc(%esp)
c0105509:	c0 
c010550a:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105511:	c0 
c0105512:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0105519:	00 
c010551a:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c0105521:	e8 f7 b7 ff ff       	call   c0100d1d <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105526:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010552b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105532:	00 
c0105533:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010553a:	00 
c010553b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010553e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105542:	89 04 24             	mov    %eax,(%esp)
c0105545:	e8 e2 f5 ff ff       	call   c0104b2c <page_insert>
c010554a:	85 c0                	test   %eax,%eax
c010554c:	74 24                	je     c0105572 <check_boot_pgdir+0x26d>
c010554e:	c7 44 24 0c 30 74 10 	movl   $0xc0107430,0xc(%esp)
c0105555:	c0 
c0105556:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010555d:	c0 
c010555e:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0105565:	00 
c0105566:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010556d:	e8 ab b7 ff ff       	call   c0100d1d <__panic>
    assert(page_ref(p) == 2);
c0105572:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105575:	89 04 24             	mov    %eax,(%esp)
c0105578:	e8 cc ea ff ff       	call   c0104049 <page_ref>
c010557d:	83 f8 02             	cmp    $0x2,%eax
c0105580:	74 24                	je     c01055a6 <check_boot_pgdir+0x2a1>
c0105582:	c7 44 24 0c 67 74 10 	movl   $0xc0107467,0xc(%esp)
c0105589:	c0 
c010558a:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c0105591:	c0 
c0105592:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0105599:	00 
c010559a:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01055a1:	e8 77 b7 ff ff       	call   c0100d1d <__panic>

    const char *str = "ucore: Hello world!!";
c01055a6:	c7 45 e8 78 74 10 c0 	movl   $0xc0107478,-0x18(%ebp)
    strcpy((void *)0x100, str);
c01055ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055b4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01055bb:	e8 fc 09 00 00       	call   c0105fbc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01055c0:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01055c7:	00 
c01055c8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01055cf:	e8 60 0a 00 00       	call   c0106034 <strcmp>
c01055d4:	85 c0                	test   %eax,%eax
c01055d6:	74 24                	je     c01055fc <check_boot_pgdir+0x2f7>
c01055d8:	c7 44 24 0c 90 74 10 	movl   $0xc0107490,0xc(%esp)
c01055df:	c0 
c01055e0:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c01055e7:	c0 
c01055e8:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c01055ef:	00 
c01055f0:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c01055f7:	e8 21 b7 ff ff       	call   c0100d1d <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01055fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055ff:	89 04 24             	mov    %eax,(%esp)
c0105602:	e8 92 e9 ff ff       	call   c0103f99 <page2kva>
c0105607:	05 00 01 00 00       	add    $0x100,%eax
c010560c:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010560f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105616:	e8 47 09 00 00       	call   c0105f62 <strlen>
c010561b:	85 c0                	test   %eax,%eax
c010561d:	74 24                	je     c0105643 <check_boot_pgdir+0x33e>
c010561f:	c7 44 24 0c c8 74 10 	movl   $0xc01074c8,0xc(%esp)
c0105626:	c0 
c0105627:	c7 44 24 08 69 70 10 	movl   $0xc0107069,0x8(%esp)
c010562e:	c0 
c010562f:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0105636:	00 
c0105637:	c7 04 24 44 70 10 c0 	movl   $0xc0107044,(%esp)
c010563e:	e8 da b6 ff ff       	call   c0100d1d <__panic>

    free_page(p);
c0105643:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010564a:	00 
c010564b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010564e:	89 04 24             	mov    %eax,(%esp)
c0105651:	e8 3d ec ff ff       	call   c0104293 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105656:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010565b:	8b 00                	mov    (%eax),%eax
c010565d:	89 04 24             	mov    %eax,(%esp)
c0105660:	e8 ca e9 ff ff       	call   c010402f <pde2page>
c0105665:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010566c:	00 
c010566d:	89 04 24             	mov    %eax,(%esp)
c0105670:	e8 1e ec ff ff       	call   c0104293 <free_pages>
    boot_pgdir[0] = 0;
c0105675:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010567a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105680:	c7 04 24 ec 74 10 c0 	movl   $0xc01074ec,(%esp)
c0105687:	e8 0f ad ff ff       	call   c010039b <cprintf>
}
c010568c:	90                   	nop
c010568d:	89 ec                	mov    %ebp,%esp
c010568f:	5d                   	pop    %ebp
c0105690:	c3                   	ret    

c0105691 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105691:	55                   	push   %ebp
c0105692:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105694:	8b 45 08             	mov    0x8(%ebp),%eax
c0105697:	83 e0 04             	and    $0x4,%eax
c010569a:	85 c0                	test   %eax,%eax
c010569c:	74 04                	je     c01056a2 <perm2str+0x11>
c010569e:	b0 75                	mov    $0x75,%al
c01056a0:	eb 02                	jmp    c01056a4 <perm2str+0x13>
c01056a2:	b0 2d                	mov    $0x2d,%al
c01056a4:	a2 88 cf 11 c0       	mov    %al,0xc011cf88
    str[1] = 'r';
c01056a9:	c6 05 89 cf 11 c0 72 	movb   $0x72,0xc011cf89
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01056b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b3:	83 e0 02             	and    $0x2,%eax
c01056b6:	85 c0                	test   %eax,%eax
c01056b8:	74 04                	je     c01056be <perm2str+0x2d>
c01056ba:	b0 77                	mov    $0x77,%al
c01056bc:	eb 02                	jmp    c01056c0 <perm2str+0x2f>
c01056be:	b0 2d                	mov    $0x2d,%al
c01056c0:	a2 8a cf 11 c0       	mov    %al,0xc011cf8a
    str[3] = '\0';
c01056c5:	c6 05 8b cf 11 c0 00 	movb   $0x0,0xc011cf8b
    return str;
c01056cc:	b8 88 cf 11 c0       	mov    $0xc011cf88,%eax
}
c01056d1:	5d                   	pop    %ebp
c01056d2:	c3                   	ret    

c01056d3 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01056d3:	55                   	push   %ebp
c01056d4:	89 e5                	mov    %esp,%ebp
c01056d6:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01056d9:	8b 45 10             	mov    0x10(%ebp),%eax
c01056dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056df:	72 0d                	jb     c01056ee <get_pgtable_items+0x1b>
        return 0;
c01056e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01056e6:	e9 98 00 00 00       	jmp    c0105783 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01056eb:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01056ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01056f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056f4:	73 18                	jae    c010570e <get_pgtable_items+0x3b>
c01056f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105700:	8b 45 14             	mov    0x14(%ebp),%eax
c0105703:	01 d0                	add    %edx,%eax
c0105705:	8b 00                	mov    (%eax),%eax
c0105707:	83 e0 01             	and    $0x1,%eax
c010570a:	85 c0                	test   %eax,%eax
c010570c:	74 dd                	je     c01056eb <get_pgtable_items+0x18>
    }
    if (start < right) {
c010570e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105711:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105714:	73 68                	jae    c010577e <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0105716:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010571a:	74 08                	je     c0105724 <get_pgtable_items+0x51>
            *left_store = start;
c010571c:	8b 45 18             	mov    0x18(%ebp),%eax
c010571f:	8b 55 10             	mov    0x10(%ebp),%edx
c0105722:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105724:	8b 45 10             	mov    0x10(%ebp),%eax
c0105727:	8d 50 01             	lea    0x1(%eax),%edx
c010572a:	89 55 10             	mov    %edx,0x10(%ebp)
c010572d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105734:	8b 45 14             	mov    0x14(%ebp),%eax
c0105737:	01 d0                	add    %edx,%eax
c0105739:	8b 00                	mov    (%eax),%eax
c010573b:	83 e0 07             	and    $0x7,%eax
c010573e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105741:	eb 03                	jmp    c0105746 <get_pgtable_items+0x73>
            start ++;
c0105743:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105746:	8b 45 10             	mov    0x10(%ebp),%eax
c0105749:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010574c:	73 1d                	jae    c010576b <get_pgtable_items+0x98>
c010574e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105751:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105758:	8b 45 14             	mov    0x14(%ebp),%eax
c010575b:	01 d0                	add    %edx,%eax
c010575d:	8b 00                	mov    (%eax),%eax
c010575f:	83 e0 07             	and    $0x7,%eax
c0105762:	89 c2                	mov    %eax,%edx
c0105764:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105767:	39 c2                	cmp    %eax,%edx
c0105769:	74 d8                	je     c0105743 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c010576b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010576f:	74 08                	je     c0105779 <get_pgtable_items+0xa6>
            *right_store = start;
c0105771:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105774:	8b 55 10             	mov    0x10(%ebp),%edx
c0105777:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105779:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010577c:	eb 05                	jmp    c0105783 <get_pgtable_items+0xb0>
    }
    return 0;
c010577e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105783:	89 ec                	mov    %ebp,%esp
c0105785:	5d                   	pop    %ebp
c0105786:	c3                   	ret    

c0105787 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105787:	55                   	push   %ebp
c0105788:	89 e5                	mov    %esp,%ebp
c010578a:	57                   	push   %edi
c010578b:	56                   	push   %esi
c010578c:	53                   	push   %ebx
c010578d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105790:	c7 04 24 0c 75 10 c0 	movl   $0xc010750c,(%esp)
c0105797:	e8 ff ab ff ff       	call   c010039b <cprintf>
    size_t left, right = 0, perm;
c010579c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01057a3:	e9 f2 00 00 00       	jmp    c010589a <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01057a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057ab:	89 04 24             	mov    %eax,(%esp)
c01057ae:	e8 de fe ff ff       	call   c0105691 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01057b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01057b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01057b9:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01057bb:	89 d6                	mov    %edx,%esi
c01057bd:	c1 e6 16             	shl    $0x16,%esi
c01057c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01057c3:	89 d3                	mov    %edx,%ebx
c01057c5:	c1 e3 16             	shl    $0x16,%ebx
c01057c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01057cb:	89 d1                	mov    %edx,%ecx
c01057cd:	c1 e1 16             	shl    $0x16,%ecx
c01057d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01057d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
c01057d6:	29 fa                	sub    %edi,%edx
c01057d8:	89 44 24 14          	mov    %eax,0x14(%esp)
c01057dc:	89 74 24 10          	mov    %esi,0x10(%esp)
c01057e0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01057e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01057e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057ec:	c7 04 24 3d 75 10 c0 	movl   $0xc010753d,(%esp)
c01057f3:	e8 a3 ab ff ff       	call   c010039b <cprintf>
        size_t l, r = left * NPTEENTRY;
c01057f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057fb:	c1 e0 0a             	shl    $0xa,%eax
c01057fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105801:	eb 50                	jmp    c0105853 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105806:	89 04 24             	mov    %eax,(%esp)
c0105809:	e8 83 fe ff ff       	call   c0105691 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010580e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105811:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0105814:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105816:	89 d6                	mov    %edx,%esi
c0105818:	c1 e6 0c             	shl    $0xc,%esi
c010581b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010581e:	89 d3                	mov    %edx,%ebx
c0105820:	c1 e3 0c             	shl    $0xc,%ebx
c0105823:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105826:	89 d1                	mov    %edx,%ecx
c0105828:	c1 e1 0c             	shl    $0xc,%ecx
c010582b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010582e:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0105831:	29 fa                	sub    %edi,%edx
c0105833:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105837:	89 74 24 10          	mov    %esi,0x10(%esp)
c010583b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010583f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105843:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105847:	c7 04 24 5c 75 10 c0 	movl   $0xc010755c,(%esp)
c010584e:	e8 48 ab ff ff       	call   c010039b <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105853:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0105858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010585b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010585e:	89 d3                	mov    %edx,%ebx
c0105860:	c1 e3 0a             	shl    $0xa,%ebx
c0105863:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105866:	89 d1                	mov    %edx,%ecx
c0105868:	c1 e1 0a             	shl    $0xa,%ecx
c010586b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c010586e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105872:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0105875:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105879:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010587d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105881:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0105885:	89 0c 24             	mov    %ecx,(%esp)
c0105888:	e8 46 fe ff ff       	call   c01056d3 <get_pgtable_items>
c010588d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105890:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105894:	0f 85 69 ff ff ff    	jne    c0105803 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010589a:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010589f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058a2:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01058a5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01058a9:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01058ac:	89 54 24 10          	mov    %edx,0x10(%esp)
c01058b0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01058b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058b8:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01058bf:	00 
c01058c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01058c7:	e8 07 fe ff ff       	call   c01056d3 <get_pgtable_items>
c01058cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01058cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058d3:	0f 85 cf fe ff ff    	jne    c01057a8 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01058d9:	c7 04 24 80 75 10 c0 	movl   $0xc0107580,(%esp)
c01058e0:	e8 b6 aa ff ff       	call   c010039b <cprintf>
}
c01058e5:	90                   	nop
c01058e6:	83 c4 4c             	add    $0x4c,%esp
c01058e9:	5b                   	pop    %ebx
c01058ea:	5e                   	pop    %esi
c01058eb:	5f                   	pop    %edi
c01058ec:	5d                   	pop    %ebp
c01058ed:	c3                   	ret    

c01058ee <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01058ee:	55                   	push   %ebp
c01058ef:	89 e5                	mov    %esp,%ebp
c01058f1:	83 ec 58             	sub    $0x58,%esp
c01058f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01058f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01058fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01058fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105900:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105903:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105906:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105909:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010590c:	8b 45 18             	mov    0x18(%ebp),%eax
c010590f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105912:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105915:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105918:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010591b:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105928:	74 1c                	je     c0105946 <printnum+0x58>
c010592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010592d:	ba 00 00 00 00       	mov    $0x0,%edx
c0105932:	f7 75 e4             	divl   -0x1c(%ebp)
c0105935:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105938:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010593b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105940:	f7 75 e4             	divl   -0x1c(%ebp)
c0105943:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105946:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105949:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010594c:	f7 75 e4             	divl   -0x1c(%ebp)
c010594f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105952:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105955:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105958:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010595b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010595e:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105961:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105964:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105967:	8b 45 18             	mov    0x18(%ebp),%eax
c010596a:	ba 00 00 00 00       	mov    $0x0,%edx
c010596f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105972:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105975:	19 d1                	sbb    %edx,%ecx
c0105977:	72 4c                	jb     c01059c5 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105979:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010597c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010597f:	8b 45 20             	mov    0x20(%ebp),%eax
c0105982:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105986:	89 54 24 14          	mov    %edx,0x14(%esp)
c010598a:	8b 45 18             	mov    0x18(%ebp),%eax
c010598d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105991:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105994:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105997:	89 44 24 08          	mov    %eax,0x8(%esp)
c010599b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010599f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a9:	89 04 24             	mov    %eax,(%esp)
c01059ac:	e8 3d ff ff ff       	call   c01058ee <printnum>
c01059b1:	eb 1b                	jmp    c01059ce <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01059b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ba:	8b 45 20             	mov    0x20(%ebp),%eax
c01059bd:	89 04 24             	mov    %eax,(%esp)
c01059c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c3:	ff d0                	call   *%eax
        while (-- width > 0)
c01059c5:	ff 4d 1c             	decl   0x1c(%ebp)
c01059c8:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01059cc:	7f e5                	jg     c01059b3 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01059ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01059d1:	05 34 76 10 c0       	add    $0xc0107634,%eax
c01059d6:	0f b6 00             	movzbl (%eax),%eax
c01059d9:	0f be c0             	movsbl %al,%eax
c01059dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059df:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059e3:	89 04 24             	mov    %eax,(%esp)
c01059e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e9:	ff d0                	call   *%eax
}
c01059eb:	90                   	nop
c01059ec:	89 ec                	mov    %ebp,%esp
c01059ee:	5d                   	pop    %ebp
c01059ef:	c3                   	ret    

c01059f0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01059f0:	55                   	push   %ebp
c01059f1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01059f3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01059f7:	7e 14                	jle    c0105a0d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01059f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01059fc:	8b 00                	mov    (%eax),%eax
c01059fe:	8d 48 08             	lea    0x8(%eax),%ecx
c0105a01:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a04:	89 0a                	mov    %ecx,(%edx)
c0105a06:	8b 50 04             	mov    0x4(%eax),%edx
c0105a09:	8b 00                	mov    (%eax),%eax
c0105a0b:	eb 30                	jmp    c0105a3d <getuint+0x4d>
    }
    else if (lflag) {
c0105a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105a11:	74 16                	je     c0105a29 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a16:	8b 00                	mov    (%eax),%eax
c0105a18:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a1b:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a1e:	89 0a                	mov    %ecx,(%edx)
c0105a20:	8b 00                	mov    (%eax),%eax
c0105a22:	ba 00 00 00 00       	mov    $0x0,%edx
c0105a27:	eb 14                	jmp    c0105a3d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105a29:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a2c:	8b 00                	mov    (%eax),%eax
c0105a2e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a31:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a34:	89 0a                	mov    %ecx,(%edx)
c0105a36:	8b 00                	mov    (%eax),%eax
c0105a38:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105a3d:	5d                   	pop    %ebp
c0105a3e:	c3                   	ret    

c0105a3f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105a3f:	55                   	push   %ebp
c0105a40:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105a42:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105a46:	7e 14                	jle    c0105a5c <getint+0x1d>
        return va_arg(*ap, long long);
c0105a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a4b:	8b 00                	mov    (%eax),%eax
c0105a4d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105a50:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a53:	89 0a                	mov    %ecx,(%edx)
c0105a55:	8b 50 04             	mov    0x4(%eax),%edx
c0105a58:	8b 00                	mov    (%eax),%eax
c0105a5a:	eb 28                	jmp    c0105a84 <getint+0x45>
    }
    else if (lflag) {
c0105a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105a60:	74 12                	je     c0105a74 <getint+0x35>
        return va_arg(*ap, long);
c0105a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a65:	8b 00                	mov    (%eax),%eax
c0105a67:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a6a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a6d:	89 0a                	mov    %ecx,(%edx)
c0105a6f:	8b 00                	mov    (%eax),%eax
c0105a71:	99                   	cltd   
c0105a72:	eb 10                	jmp    c0105a84 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a77:	8b 00                	mov    (%eax),%eax
c0105a79:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a7c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a7f:	89 0a                	mov    %ecx,(%edx)
c0105a81:	8b 00                	mov    (%eax),%eax
c0105a83:	99                   	cltd   
    }
}
c0105a84:	5d                   	pop    %ebp
c0105a85:	c3                   	ret    

c0105a86 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105a86:	55                   	push   %ebp
c0105a87:	89 e5                	mov    %esp,%ebp
c0105a89:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105a8c:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a95:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a99:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aaa:	89 04 24             	mov    %eax,(%esp)
c0105aad:	e8 05 00 00 00       	call   c0105ab7 <vprintfmt>
    va_end(ap);
}
c0105ab2:	90                   	nop
c0105ab3:	89 ec                	mov    %ebp,%esp
c0105ab5:	5d                   	pop    %ebp
c0105ab6:	c3                   	ret    

c0105ab7 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105ab7:	55                   	push   %ebp
c0105ab8:	89 e5                	mov    %esp,%ebp
c0105aba:	56                   	push   %esi
c0105abb:	53                   	push   %ebx
c0105abc:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105abf:	eb 17                	jmp    c0105ad8 <vprintfmt+0x21>
            if (ch == '\0') {
c0105ac1:	85 db                	test   %ebx,%ebx
c0105ac3:	0f 84 bf 03 00 00    	je     c0105e88 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ad0:	89 1c 24             	mov    %ebx,(%esp)
c0105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad6:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105ad8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105adb:	8d 50 01             	lea    0x1(%eax),%edx
c0105ade:	89 55 10             	mov    %edx,0x10(%ebp)
c0105ae1:	0f b6 00             	movzbl (%eax),%eax
c0105ae4:	0f b6 d8             	movzbl %al,%ebx
c0105ae7:	83 fb 25             	cmp    $0x25,%ebx
c0105aea:	75 d5                	jne    c0105ac1 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105aec:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105af0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105af7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105afa:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105afd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105b04:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b07:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105b0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b0d:	8d 50 01             	lea    0x1(%eax),%edx
c0105b10:	89 55 10             	mov    %edx,0x10(%ebp)
c0105b13:	0f b6 00             	movzbl (%eax),%eax
c0105b16:	0f b6 d8             	movzbl %al,%ebx
c0105b19:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105b1c:	83 f8 55             	cmp    $0x55,%eax
c0105b1f:	0f 87 37 03 00 00    	ja     c0105e5c <vprintfmt+0x3a5>
c0105b25:	8b 04 85 58 76 10 c0 	mov    -0x3fef89a8(,%eax,4),%eax
c0105b2c:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105b2e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105b32:	eb d6                	jmp    c0105b0a <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105b34:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105b38:	eb d0                	jmp    c0105b0a <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105b3a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105b41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105b44:	89 d0                	mov    %edx,%eax
c0105b46:	c1 e0 02             	shl    $0x2,%eax
c0105b49:	01 d0                	add    %edx,%eax
c0105b4b:	01 c0                	add    %eax,%eax
c0105b4d:	01 d8                	add    %ebx,%eax
c0105b4f:	83 e8 30             	sub    $0x30,%eax
c0105b52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105b55:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b58:	0f b6 00             	movzbl (%eax),%eax
c0105b5b:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105b5e:	83 fb 2f             	cmp    $0x2f,%ebx
c0105b61:	7e 38                	jle    c0105b9b <vprintfmt+0xe4>
c0105b63:	83 fb 39             	cmp    $0x39,%ebx
c0105b66:	7f 33                	jg     c0105b9b <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105b68:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105b6b:	eb d4                	jmp    c0105b41 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105b6d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b70:	8d 50 04             	lea    0x4(%eax),%edx
c0105b73:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b76:	8b 00                	mov    (%eax),%eax
c0105b78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105b7b:	eb 1f                	jmp    c0105b9c <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105b7d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b81:	79 87                	jns    c0105b0a <vprintfmt+0x53>
                width = 0;
c0105b83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105b8a:	e9 7b ff ff ff       	jmp    c0105b0a <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105b8f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105b96:	e9 6f ff ff ff       	jmp    c0105b0a <vprintfmt+0x53>
            goto process_precision;
c0105b9b:	90                   	nop

        process_precision:
            if (width < 0)
c0105b9c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ba0:	0f 89 64 ff ff ff    	jns    c0105b0a <vprintfmt+0x53>
                width = precision, precision = -1;
c0105ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ba9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105bac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105bb3:	e9 52 ff ff ff       	jmp    c0105b0a <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105bb8:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105bbb:	e9 4a ff ff ff       	jmp    c0105b0a <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105bc0:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bc3:	8d 50 04             	lea    0x4(%eax),%edx
c0105bc6:	89 55 14             	mov    %edx,0x14(%ebp)
c0105bc9:	8b 00                	mov    (%eax),%eax
c0105bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105bce:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bd2:	89 04 24             	mov    %eax,(%esp)
c0105bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd8:	ff d0                	call   *%eax
            break;
c0105bda:	e9 a4 02 00 00       	jmp    c0105e83 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105bdf:	8b 45 14             	mov    0x14(%ebp),%eax
c0105be2:	8d 50 04             	lea    0x4(%eax),%edx
c0105be5:	89 55 14             	mov    %edx,0x14(%ebp)
c0105be8:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105bea:	85 db                	test   %ebx,%ebx
c0105bec:	79 02                	jns    c0105bf0 <vprintfmt+0x139>
                err = -err;
c0105bee:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105bf0:	83 fb 06             	cmp    $0x6,%ebx
c0105bf3:	7f 0b                	jg     c0105c00 <vprintfmt+0x149>
c0105bf5:	8b 34 9d 18 76 10 c0 	mov    -0x3fef89e8(,%ebx,4),%esi
c0105bfc:	85 f6                	test   %esi,%esi
c0105bfe:	75 23                	jne    c0105c23 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105c00:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105c04:	c7 44 24 08 45 76 10 	movl   $0xc0107645,0x8(%esp)
c0105c0b:	c0 
c0105c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c16:	89 04 24             	mov    %eax,(%esp)
c0105c19:	e8 68 fe ff ff       	call   c0105a86 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105c1e:	e9 60 02 00 00       	jmp    c0105e83 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105c23:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105c27:	c7 44 24 08 4e 76 10 	movl   $0xc010764e,0x8(%esp)
c0105c2e:	c0 
c0105c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c39:	89 04 24             	mov    %eax,(%esp)
c0105c3c:	e8 45 fe ff ff       	call   c0105a86 <printfmt>
            break;
c0105c41:	e9 3d 02 00 00       	jmp    c0105e83 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105c46:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c49:	8d 50 04             	lea    0x4(%eax),%edx
c0105c4c:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c4f:	8b 30                	mov    (%eax),%esi
c0105c51:	85 f6                	test   %esi,%esi
c0105c53:	75 05                	jne    c0105c5a <vprintfmt+0x1a3>
                p = "(null)";
c0105c55:	be 51 76 10 c0       	mov    $0xc0107651,%esi
            }
            if (width > 0 && padc != '-') {
c0105c5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c5e:	7e 76                	jle    c0105cd6 <vprintfmt+0x21f>
c0105c60:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105c64:	74 70                	je     c0105cd6 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c6d:	89 34 24             	mov    %esi,(%esp)
c0105c70:	e8 16 03 00 00       	call   c0105f8b <strnlen>
c0105c75:	89 c2                	mov    %eax,%edx
c0105c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c7a:	29 d0                	sub    %edx,%eax
c0105c7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c7f:	eb 16                	jmp    c0105c97 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105c81:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105c85:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c8c:	89 04 24             	mov    %eax,(%esp)
c0105c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c92:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105c94:	ff 4d e8             	decl   -0x18(%ebp)
c0105c97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c9b:	7f e4                	jg     c0105c81 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105c9d:	eb 37                	jmp    c0105cd6 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105c9f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105ca3:	74 1f                	je     c0105cc4 <vprintfmt+0x20d>
c0105ca5:	83 fb 1f             	cmp    $0x1f,%ebx
c0105ca8:	7e 05                	jle    c0105caf <vprintfmt+0x1f8>
c0105caa:	83 fb 7e             	cmp    $0x7e,%ebx
c0105cad:	7e 15                	jle    c0105cc4 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105caf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc0:	ff d0                	call   *%eax
c0105cc2:	eb 0f                	jmp    c0105cd3 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ccb:	89 1c 24             	mov    %ebx,(%esp)
c0105cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd1:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105cd3:	ff 4d e8             	decl   -0x18(%ebp)
c0105cd6:	89 f0                	mov    %esi,%eax
c0105cd8:	8d 70 01             	lea    0x1(%eax),%esi
c0105cdb:	0f b6 00             	movzbl (%eax),%eax
c0105cde:	0f be d8             	movsbl %al,%ebx
c0105ce1:	85 db                	test   %ebx,%ebx
c0105ce3:	74 27                	je     c0105d0c <vprintfmt+0x255>
c0105ce5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ce9:	78 b4                	js     c0105c9f <vprintfmt+0x1e8>
c0105ceb:	ff 4d e4             	decl   -0x1c(%ebp)
c0105cee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105cf2:	79 ab                	jns    c0105c9f <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105cf4:	eb 16                	jmp    c0105d0c <vprintfmt+0x255>
                putch(' ', putdat);
c0105cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cfd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d07:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105d09:	ff 4d e8             	decl   -0x18(%ebp)
c0105d0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d10:	7f e4                	jg     c0105cf6 <vprintfmt+0x23f>
            }
            break;
c0105d12:	e9 6c 01 00 00       	jmp    c0105e83 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105d17:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d1e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d21:	89 04 24             	mov    %eax,(%esp)
c0105d24:	e8 16 fd ff ff       	call   c0105a3f <getint>
c0105d29:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d35:	85 d2                	test   %edx,%edx
c0105d37:	79 26                	jns    c0105d5f <vprintfmt+0x2a8>
                putch('-', putdat);
c0105d39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d40:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105d47:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4a:	ff d0                	call   *%eax
                num = -(long long)num;
c0105d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d52:	f7 d8                	neg    %eax
c0105d54:	83 d2 00             	adc    $0x0,%edx
c0105d57:	f7 da                	neg    %edx
c0105d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105d5f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105d66:	e9 a8 00 00 00       	jmp    c0105e13 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d72:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d75:	89 04 24             	mov    %eax,(%esp)
c0105d78:	e8 73 fc ff ff       	call   c01059f0 <getuint>
c0105d7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d80:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105d83:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105d8a:	e9 84 00 00 00       	jmp    c0105e13 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105d8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d96:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d99:	89 04 24             	mov    %eax,(%esp)
c0105d9c:	e8 4f fc ff ff       	call   c01059f0 <getuint>
c0105da1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105da4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105da7:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105dae:	eb 63                	jmp    c0105e13 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105db0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105db7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105dbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc1:	ff d0                	call   *%eax
            putch('x', putdat);
c0105dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd4:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105dd6:	8b 45 14             	mov    0x14(%ebp),%eax
c0105dd9:	8d 50 04             	lea    0x4(%eax),%edx
c0105ddc:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ddf:	8b 00                	mov    (%eax),%eax
c0105de1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105deb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105df2:	eb 1f                	jmp    c0105e13 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105df7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dfb:	8d 45 14             	lea    0x14(%ebp),%eax
c0105dfe:	89 04 24             	mov    %eax,(%esp)
c0105e01:	e8 ea fb ff ff       	call   c01059f0 <getuint>
c0105e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e09:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105e0c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105e13:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e1a:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105e1e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e21:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105e25:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e33:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105e37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e41:	89 04 24             	mov    %eax,(%esp)
c0105e44:	e8 a5 fa ff ff       	call   c01058ee <printnum>
            break;
c0105e49:	eb 38                	jmp    c0105e83 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e52:	89 1c 24             	mov    %ebx,(%esp)
c0105e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e58:	ff d0                	call   *%eax
            break;
c0105e5a:	eb 27                	jmp    c0105e83 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e63:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105e6f:	ff 4d 10             	decl   0x10(%ebp)
c0105e72:	eb 03                	jmp    c0105e77 <vprintfmt+0x3c0>
c0105e74:	ff 4d 10             	decl   0x10(%ebp)
c0105e77:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e7a:	48                   	dec    %eax
c0105e7b:	0f b6 00             	movzbl (%eax),%eax
c0105e7e:	3c 25                	cmp    $0x25,%al
c0105e80:	75 f2                	jne    c0105e74 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105e82:	90                   	nop
    while (1) {
c0105e83:	e9 37 fc ff ff       	jmp    c0105abf <vprintfmt+0x8>
                return;
c0105e88:	90                   	nop
        }
    }
}
c0105e89:	83 c4 40             	add    $0x40,%esp
c0105e8c:	5b                   	pop    %ebx
c0105e8d:	5e                   	pop    %esi
c0105e8e:	5d                   	pop    %ebp
c0105e8f:	c3                   	ret    

c0105e90 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105e90:	55                   	push   %ebp
c0105e91:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105e93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e96:	8b 40 08             	mov    0x8(%eax),%eax
c0105e99:	8d 50 01             	lea    0x1(%eax),%edx
c0105e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e9f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ea5:	8b 10                	mov    (%eax),%edx
c0105ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eaa:	8b 40 04             	mov    0x4(%eax),%eax
c0105ead:	39 c2                	cmp    %eax,%edx
c0105eaf:	73 12                	jae    c0105ec3 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eb4:	8b 00                	mov    (%eax),%eax
c0105eb6:	8d 48 01             	lea    0x1(%eax),%ecx
c0105eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ebc:	89 0a                	mov    %ecx,(%edx)
c0105ebe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ec1:	88 10                	mov    %dl,(%eax)
    }
}
c0105ec3:	90                   	nop
c0105ec4:	5d                   	pop    %ebp
c0105ec5:	c3                   	ret    

c0105ec6 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105ec6:	55                   	push   %ebp
c0105ec7:	89 e5                	mov    %esp,%ebp
c0105ec9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105ecc:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ecf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ed5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ed9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105edc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ee7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eea:	89 04 24             	mov    %eax,(%esp)
c0105eed:	e8 0a 00 00 00       	call   c0105efc <vsnprintf>
c0105ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ef8:	89 ec                	mov    %ebp,%esp
c0105efa:	5d                   	pop    %ebp
c0105efb:	c3                   	ret    

c0105efc <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105efc:	55                   	push   %ebp
c0105efd:	89 e5                	mov    %esp,%ebp
c0105eff:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105f02:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f05:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105f08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f0b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f11:	01 d0                	add    %edx,%eax
c0105f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105f1d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105f21:	74 0a                	je     c0105f2d <vsnprintf+0x31>
c0105f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f29:	39 c2                	cmp    %eax,%edx
c0105f2b:	76 07                	jbe    c0105f34 <vsnprintf+0x38>
        return -E_INVAL;
c0105f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105f32:	eb 2a                	jmp    c0105f5e <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105f34:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f3e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f42:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105f45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f49:	c7 04 24 90 5e 10 c0 	movl   $0xc0105e90,(%esp)
c0105f50:	e8 62 fb ff ff       	call   c0105ab7 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105f55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f58:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105f5e:	89 ec                	mov    %ebp,%esp
c0105f60:	5d                   	pop    %ebp
c0105f61:	c3                   	ret    

c0105f62 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105f62:	55                   	push   %ebp
c0105f63:	89 e5                	mov    %esp,%ebp
c0105f65:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105f68:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105f6f:	eb 03                	jmp    c0105f74 <strlen+0x12>
        cnt ++;
c0105f71:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0105f74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f77:	8d 50 01             	lea    0x1(%eax),%edx
c0105f7a:	89 55 08             	mov    %edx,0x8(%ebp)
c0105f7d:	0f b6 00             	movzbl (%eax),%eax
c0105f80:	84 c0                	test   %al,%al
c0105f82:	75 ed                	jne    c0105f71 <strlen+0xf>
    }
    return cnt;
c0105f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105f87:	89 ec                	mov    %ebp,%esp
c0105f89:	5d                   	pop    %ebp
c0105f8a:	c3                   	ret    

c0105f8b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105f8b:	55                   	push   %ebp
c0105f8c:	89 e5                	mov    %esp,%ebp
c0105f8e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105f91:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105f98:	eb 03                	jmp    c0105f9d <strnlen+0x12>
        cnt ++;
c0105f9a:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fa0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105fa3:	73 10                	jae    c0105fb5 <strnlen+0x2a>
c0105fa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fa8:	8d 50 01             	lea    0x1(%eax),%edx
c0105fab:	89 55 08             	mov    %edx,0x8(%ebp)
c0105fae:	0f b6 00             	movzbl (%eax),%eax
c0105fb1:	84 c0                	test   %al,%al
c0105fb3:	75 e5                	jne    c0105f9a <strnlen+0xf>
    }
    return cnt;
c0105fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105fb8:	89 ec                	mov    %ebp,%esp
c0105fba:	5d                   	pop    %ebp
c0105fbb:	c3                   	ret    

c0105fbc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105fbc:	55                   	push   %ebp
c0105fbd:	89 e5                	mov    %esp,%ebp
c0105fbf:	57                   	push   %edi
c0105fc0:	56                   	push   %esi
c0105fc1:	83 ec 20             	sub    $0x20,%esp
c0105fc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105fd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fd6:	89 d1                	mov    %edx,%ecx
c0105fd8:	89 c2                	mov    %eax,%edx
c0105fda:	89 ce                	mov    %ecx,%esi
c0105fdc:	89 d7                	mov    %edx,%edi
c0105fde:	ac                   	lods   %ds:(%esi),%al
c0105fdf:	aa                   	stos   %al,%es:(%edi)
c0105fe0:	84 c0                	test   %al,%al
c0105fe2:	75 fa                	jne    c0105fde <strcpy+0x22>
c0105fe4:	89 fa                	mov    %edi,%edx
c0105fe6:	89 f1                	mov    %esi,%ecx
c0105fe8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105feb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105ff4:	83 c4 20             	add    $0x20,%esp
c0105ff7:	5e                   	pop    %esi
c0105ff8:	5f                   	pop    %edi
c0105ff9:	5d                   	pop    %ebp
c0105ffa:	c3                   	ret    

c0105ffb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105ffb:	55                   	push   %ebp
c0105ffc:	89 e5                	mov    %esp,%ebp
c0105ffe:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106001:	8b 45 08             	mov    0x8(%ebp),%eax
c0106004:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106007:	eb 1e                	jmp    c0106027 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0106009:	8b 45 0c             	mov    0xc(%ebp),%eax
c010600c:	0f b6 10             	movzbl (%eax),%edx
c010600f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106012:	88 10                	mov    %dl,(%eax)
c0106014:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106017:	0f b6 00             	movzbl (%eax),%eax
c010601a:	84 c0                	test   %al,%al
c010601c:	74 03                	je     c0106021 <strncpy+0x26>
            src ++;
c010601e:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0106021:	ff 45 fc             	incl   -0x4(%ebp)
c0106024:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0106027:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010602b:	75 dc                	jne    c0106009 <strncpy+0xe>
    }
    return dst;
c010602d:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106030:	89 ec                	mov    %ebp,%esp
c0106032:	5d                   	pop    %ebp
c0106033:	c3                   	ret    

c0106034 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106034:	55                   	push   %ebp
c0106035:	89 e5                	mov    %esp,%ebp
c0106037:	57                   	push   %edi
c0106038:	56                   	push   %esi
c0106039:	83 ec 20             	sub    $0x20,%esp
c010603c:	8b 45 08             	mov    0x8(%ebp),%eax
c010603f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106042:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106045:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0106048:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010604b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010604e:	89 d1                	mov    %edx,%ecx
c0106050:	89 c2                	mov    %eax,%edx
c0106052:	89 ce                	mov    %ecx,%esi
c0106054:	89 d7                	mov    %edx,%edi
c0106056:	ac                   	lods   %ds:(%esi),%al
c0106057:	ae                   	scas   %es:(%edi),%al
c0106058:	75 08                	jne    c0106062 <strcmp+0x2e>
c010605a:	84 c0                	test   %al,%al
c010605c:	75 f8                	jne    c0106056 <strcmp+0x22>
c010605e:	31 c0                	xor    %eax,%eax
c0106060:	eb 04                	jmp    c0106066 <strcmp+0x32>
c0106062:	19 c0                	sbb    %eax,%eax
c0106064:	0c 01                	or     $0x1,%al
c0106066:	89 fa                	mov    %edi,%edx
c0106068:	89 f1                	mov    %esi,%ecx
c010606a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010606d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106070:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106073:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106076:	83 c4 20             	add    $0x20,%esp
c0106079:	5e                   	pop    %esi
c010607a:	5f                   	pop    %edi
c010607b:	5d                   	pop    %ebp
c010607c:	c3                   	ret    

c010607d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010607d:	55                   	push   %ebp
c010607e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106080:	eb 09                	jmp    c010608b <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106082:	ff 4d 10             	decl   0x10(%ebp)
c0106085:	ff 45 08             	incl   0x8(%ebp)
c0106088:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010608b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010608f:	74 1a                	je     c01060ab <strncmp+0x2e>
c0106091:	8b 45 08             	mov    0x8(%ebp),%eax
c0106094:	0f b6 00             	movzbl (%eax),%eax
c0106097:	84 c0                	test   %al,%al
c0106099:	74 10                	je     c01060ab <strncmp+0x2e>
c010609b:	8b 45 08             	mov    0x8(%ebp),%eax
c010609e:	0f b6 10             	movzbl (%eax),%edx
c01060a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060a4:	0f b6 00             	movzbl (%eax),%eax
c01060a7:	38 c2                	cmp    %al,%dl
c01060a9:	74 d7                	je     c0106082 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01060ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01060af:	74 18                	je     c01060c9 <strncmp+0x4c>
c01060b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01060b4:	0f b6 00             	movzbl (%eax),%eax
c01060b7:	0f b6 d0             	movzbl %al,%edx
c01060ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060bd:	0f b6 00             	movzbl (%eax),%eax
c01060c0:	0f b6 c8             	movzbl %al,%ecx
c01060c3:	89 d0                	mov    %edx,%eax
c01060c5:	29 c8                	sub    %ecx,%eax
c01060c7:	eb 05                	jmp    c01060ce <strncmp+0x51>
c01060c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01060ce:	5d                   	pop    %ebp
c01060cf:	c3                   	ret    

c01060d0 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01060d0:	55                   	push   %ebp
c01060d1:	89 e5                	mov    %esp,%ebp
c01060d3:	83 ec 04             	sub    $0x4,%esp
c01060d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060d9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01060dc:	eb 13                	jmp    c01060f1 <strchr+0x21>
        if (*s == c) {
c01060de:	8b 45 08             	mov    0x8(%ebp),%eax
c01060e1:	0f b6 00             	movzbl (%eax),%eax
c01060e4:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01060e7:	75 05                	jne    c01060ee <strchr+0x1e>
            return (char *)s;
c01060e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01060ec:	eb 12                	jmp    c0106100 <strchr+0x30>
        }
        s ++;
c01060ee:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01060f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01060f4:	0f b6 00             	movzbl (%eax),%eax
c01060f7:	84 c0                	test   %al,%al
c01060f9:	75 e3                	jne    c01060de <strchr+0xe>
    }
    return NULL;
c01060fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106100:	89 ec                	mov    %ebp,%esp
c0106102:	5d                   	pop    %ebp
c0106103:	c3                   	ret    

c0106104 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106104:	55                   	push   %ebp
c0106105:	89 e5                	mov    %esp,%ebp
c0106107:	83 ec 04             	sub    $0x4,%esp
c010610a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010610d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106110:	eb 0e                	jmp    c0106120 <strfind+0x1c>
        if (*s == c) {
c0106112:	8b 45 08             	mov    0x8(%ebp),%eax
c0106115:	0f b6 00             	movzbl (%eax),%eax
c0106118:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010611b:	74 0f                	je     c010612c <strfind+0x28>
            break;
        }
        s ++;
c010611d:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106120:	8b 45 08             	mov    0x8(%ebp),%eax
c0106123:	0f b6 00             	movzbl (%eax),%eax
c0106126:	84 c0                	test   %al,%al
c0106128:	75 e8                	jne    c0106112 <strfind+0xe>
c010612a:	eb 01                	jmp    c010612d <strfind+0x29>
            break;
c010612c:	90                   	nop
    }
    return (char *)s;
c010612d:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106130:	89 ec                	mov    %ebp,%esp
c0106132:	5d                   	pop    %ebp
c0106133:	c3                   	ret    

c0106134 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106134:	55                   	push   %ebp
c0106135:	89 e5                	mov    %esp,%ebp
c0106137:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010613a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106141:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106148:	eb 03                	jmp    c010614d <strtol+0x19>
        s ++;
c010614a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010614d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106150:	0f b6 00             	movzbl (%eax),%eax
c0106153:	3c 20                	cmp    $0x20,%al
c0106155:	74 f3                	je     c010614a <strtol+0x16>
c0106157:	8b 45 08             	mov    0x8(%ebp),%eax
c010615a:	0f b6 00             	movzbl (%eax),%eax
c010615d:	3c 09                	cmp    $0x9,%al
c010615f:	74 e9                	je     c010614a <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0106161:	8b 45 08             	mov    0x8(%ebp),%eax
c0106164:	0f b6 00             	movzbl (%eax),%eax
c0106167:	3c 2b                	cmp    $0x2b,%al
c0106169:	75 05                	jne    c0106170 <strtol+0x3c>
        s ++;
c010616b:	ff 45 08             	incl   0x8(%ebp)
c010616e:	eb 14                	jmp    c0106184 <strtol+0x50>
    }
    else if (*s == '-') {
c0106170:	8b 45 08             	mov    0x8(%ebp),%eax
c0106173:	0f b6 00             	movzbl (%eax),%eax
c0106176:	3c 2d                	cmp    $0x2d,%al
c0106178:	75 0a                	jne    c0106184 <strtol+0x50>
        s ++, neg = 1;
c010617a:	ff 45 08             	incl   0x8(%ebp)
c010617d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106184:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106188:	74 06                	je     c0106190 <strtol+0x5c>
c010618a:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010618e:	75 22                	jne    c01061b2 <strtol+0x7e>
c0106190:	8b 45 08             	mov    0x8(%ebp),%eax
c0106193:	0f b6 00             	movzbl (%eax),%eax
c0106196:	3c 30                	cmp    $0x30,%al
c0106198:	75 18                	jne    c01061b2 <strtol+0x7e>
c010619a:	8b 45 08             	mov    0x8(%ebp),%eax
c010619d:	40                   	inc    %eax
c010619e:	0f b6 00             	movzbl (%eax),%eax
c01061a1:	3c 78                	cmp    $0x78,%al
c01061a3:	75 0d                	jne    c01061b2 <strtol+0x7e>
        s += 2, base = 16;
c01061a5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01061a9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01061b0:	eb 29                	jmp    c01061db <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c01061b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01061b6:	75 16                	jne    c01061ce <strtol+0x9a>
c01061b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01061bb:	0f b6 00             	movzbl (%eax),%eax
c01061be:	3c 30                	cmp    $0x30,%al
c01061c0:	75 0c                	jne    c01061ce <strtol+0x9a>
        s ++, base = 8;
c01061c2:	ff 45 08             	incl   0x8(%ebp)
c01061c5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01061cc:	eb 0d                	jmp    c01061db <strtol+0xa7>
    }
    else if (base == 0) {
c01061ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01061d2:	75 07                	jne    c01061db <strtol+0xa7>
        base = 10;
c01061d4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01061db:	8b 45 08             	mov    0x8(%ebp),%eax
c01061de:	0f b6 00             	movzbl (%eax),%eax
c01061e1:	3c 2f                	cmp    $0x2f,%al
c01061e3:	7e 1b                	jle    c0106200 <strtol+0xcc>
c01061e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01061e8:	0f b6 00             	movzbl (%eax),%eax
c01061eb:	3c 39                	cmp    $0x39,%al
c01061ed:	7f 11                	jg     c0106200 <strtol+0xcc>
            dig = *s - '0';
c01061ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01061f2:	0f b6 00             	movzbl (%eax),%eax
c01061f5:	0f be c0             	movsbl %al,%eax
c01061f8:	83 e8 30             	sub    $0x30,%eax
c01061fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01061fe:	eb 48                	jmp    c0106248 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0106200:	8b 45 08             	mov    0x8(%ebp),%eax
c0106203:	0f b6 00             	movzbl (%eax),%eax
c0106206:	3c 60                	cmp    $0x60,%al
c0106208:	7e 1b                	jle    c0106225 <strtol+0xf1>
c010620a:	8b 45 08             	mov    0x8(%ebp),%eax
c010620d:	0f b6 00             	movzbl (%eax),%eax
c0106210:	3c 7a                	cmp    $0x7a,%al
c0106212:	7f 11                	jg     c0106225 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0106214:	8b 45 08             	mov    0x8(%ebp),%eax
c0106217:	0f b6 00             	movzbl (%eax),%eax
c010621a:	0f be c0             	movsbl %al,%eax
c010621d:	83 e8 57             	sub    $0x57,%eax
c0106220:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106223:	eb 23                	jmp    c0106248 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0106225:	8b 45 08             	mov    0x8(%ebp),%eax
c0106228:	0f b6 00             	movzbl (%eax),%eax
c010622b:	3c 40                	cmp    $0x40,%al
c010622d:	7e 3b                	jle    c010626a <strtol+0x136>
c010622f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106232:	0f b6 00             	movzbl (%eax),%eax
c0106235:	3c 5a                	cmp    $0x5a,%al
c0106237:	7f 31                	jg     c010626a <strtol+0x136>
            dig = *s - 'A' + 10;
c0106239:	8b 45 08             	mov    0x8(%ebp),%eax
c010623c:	0f b6 00             	movzbl (%eax),%eax
c010623f:	0f be c0             	movsbl %al,%eax
c0106242:	83 e8 37             	sub    $0x37,%eax
c0106245:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106248:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010624b:	3b 45 10             	cmp    0x10(%ebp),%eax
c010624e:	7d 19                	jge    c0106269 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106250:	ff 45 08             	incl   0x8(%ebp)
c0106253:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106256:	0f af 45 10          	imul   0x10(%ebp),%eax
c010625a:	89 c2                	mov    %eax,%edx
c010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010625f:	01 d0                	add    %edx,%eax
c0106261:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106264:	e9 72 ff ff ff       	jmp    c01061db <strtol+0xa7>
            break;
c0106269:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010626a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010626e:	74 08                	je     c0106278 <strtol+0x144>
        *endptr = (char *) s;
c0106270:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106273:	8b 55 08             	mov    0x8(%ebp),%edx
c0106276:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106278:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010627c:	74 07                	je     c0106285 <strtol+0x151>
c010627e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106281:	f7 d8                	neg    %eax
c0106283:	eb 03                	jmp    c0106288 <strtol+0x154>
c0106285:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106288:	89 ec                	mov    %ebp,%esp
c010628a:	5d                   	pop    %ebp
c010628b:	c3                   	ret    

c010628c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010628c:	55                   	push   %ebp
c010628d:	89 e5                	mov    %esp,%ebp
c010628f:	83 ec 28             	sub    $0x28,%esp
c0106292:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0106295:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106298:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010629b:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c010629f:	8b 45 08             	mov    0x8(%ebp),%eax
c01062a2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01062a5:	88 55 f7             	mov    %dl,-0x9(%ebp)
c01062a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01062ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01062ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01062b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01062b5:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01062b8:	89 d7                	mov    %edx,%edi
c01062ba:	f3 aa                	rep stos %al,%es:(%edi)
c01062bc:	89 fa                	mov    %edi,%edx
c01062be:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01062c1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01062c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01062c7:	8b 7d fc             	mov    -0x4(%ebp),%edi
c01062ca:	89 ec                	mov    %ebp,%esp
c01062cc:	5d                   	pop    %ebp
c01062cd:	c3                   	ret    

c01062ce <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01062ce:	55                   	push   %ebp
c01062cf:	89 e5                	mov    %esp,%ebp
c01062d1:	57                   	push   %edi
c01062d2:	56                   	push   %esi
c01062d3:	53                   	push   %ebx
c01062d4:	83 ec 30             	sub    $0x30,%esp
c01062d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01062da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01062e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01062e6:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062ec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01062ef:	73 42                	jae    c0106333 <memmove+0x65>
c01062f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01062f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01062fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106300:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106303:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106306:	c1 e8 02             	shr    $0x2,%eax
c0106309:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010630b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010630e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106311:	89 d7                	mov    %edx,%edi
c0106313:	89 c6                	mov    %eax,%esi
c0106315:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010631a:	83 e1 03             	and    $0x3,%ecx
c010631d:	74 02                	je     c0106321 <memmove+0x53>
c010631f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106321:	89 f0                	mov    %esi,%eax
c0106323:	89 fa                	mov    %edi,%edx
c0106325:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106328:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010632b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010632e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0106331:	eb 36                	jmp    c0106369 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106333:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106336:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106339:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010633c:	01 c2                	add    %eax,%edx
c010633e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106341:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106344:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106347:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010634a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010634d:	89 c1                	mov    %eax,%ecx
c010634f:	89 d8                	mov    %ebx,%eax
c0106351:	89 d6                	mov    %edx,%esi
c0106353:	89 c7                	mov    %eax,%edi
c0106355:	fd                   	std    
c0106356:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106358:	fc                   	cld    
c0106359:	89 f8                	mov    %edi,%eax
c010635b:	89 f2                	mov    %esi,%edx
c010635d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106360:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106363:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106369:	83 c4 30             	add    $0x30,%esp
c010636c:	5b                   	pop    %ebx
c010636d:	5e                   	pop    %esi
c010636e:	5f                   	pop    %edi
c010636f:	5d                   	pop    %ebp
c0106370:	c3                   	ret    

c0106371 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106371:	55                   	push   %ebp
c0106372:	89 e5                	mov    %esp,%ebp
c0106374:	57                   	push   %edi
c0106375:	56                   	push   %esi
c0106376:	83 ec 20             	sub    $0x20,%esp
c0106379:	8b 45 08             	mov    0x8(%ebp),%eax
c010637c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010637f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106382:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106385:	8b 45 10             	mov    0x10(%ebp),%eax
c0106388:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010638b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010638e:	c1 e8 02             	shr    $0x2,%eax
c0106391:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106393:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106396:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106399:	89 d7                	mov    %edx,%edi
c010639b:	89 c6                	mov    %eax,%esi
c010639d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010639f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01063a2:	83 e1 03             	and    $0x3,%ecx
c01063a5:	74 02                	je     c01063a9 <memcpy+0x38>
c01063a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01063a9:	89 f0                	mov    %esi,%eax
c01063ab:	89 fa                	mov    %edi,%edx
c01063ad:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01063b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01063b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01063b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01063b9:	83 c4 20             	add    $0x20,%esp
c01063bc:	5e                   	pop    %esi
c01063bd:	5f                   	pop    %edi
c01063be:	5d                   	pop    %ebp
c01063bf:	c3                   	ret    

c01063c0 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01063c0:	55                   	push   %ebp
c01063c1:	89 e5                	mov    %esp,%ebp
c01063c3:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01063c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01063cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01063d2:	eb 2e                	jmp    c0106402 <memcmp+0x42>
        if (*s1 != *s2) {
c01063d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01063d7:	0f b6 10             	movzbl (%eax),%edx
c01063da:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01063dd:	0f b6 00             	movzbl (%eax),%eax
c01063e0:	38 c2                	cmp    %al,%dl
c01063e2:	74 18                	je     c01063fc <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01063e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01063e7:	0f b6 00             	movzbl (%eax),%eax
c01063ea:	0f b6 d0             	movzbl %al,%edx
c01063ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01063f0:	0f b6 00             	movzbl (%eax),%eax
c01063f3:	0f b6 c8             	movzbl %al,%ecx
c01063f6:	89 d0                	mov    %edx,%eax
c01063f8:	29 c8                	sub    %ecx,%eax
c01063fa:	eb 18                	jmp    c0106414 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01063fc:	ff 45 fc             	incl   -0x4(%ebp)
c01063ff:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0106402:	8b 45 10             	mov    0x10(%ebp),%eax
c0106405:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106408:	89 55 10             	mov    %edx,0x10(%ebp)
c010640b:	85 c0                	test   %eax,%eax
c010640d:	75 c5                	jne    c01063d4 <memcmp+0x14>
    }
    return 0;
c010640f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106414:	89 ec                	mov    %ebp,%esp
c0106416:	5d                   	pop    %ebp
c0106417:	c3                   	ret    
