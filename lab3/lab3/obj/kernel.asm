
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 40 12 00       	mov    $0x124000,%eax
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
c0100020:	a3 00 40 12 c0       	mov    %eax,0xc0124000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 30 12 c0       	mov    $0xc0123000,%esp
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
c010003c:	b8 74 71 12 c0       	mov    $0xc0127174,%eax
c0100041:	2d 00 60 12 c0       	sub    $0xc0126000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 60 12 c0 	movl   $0xc0126000,(%esp)
c0100059:	e8 6f 8f 00 00       	call   c0108fcd <memset>

    cons_init();                // init the console
c010005e:	e8 39 16 00 00       	call   c010169c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f0 60 91 10 c0 	movl   $0xc0109160,-0x10(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 7c 91 10 c0 	movl   $0xc010917c,(%esp)
c0100078:	e8 28 03 00 00       	call   c01003a5 <cprintf>

    print_kerninfo();
c010007d:	e8 46 08 00 00       	call   c01008c8 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 d4 00 00 00       	call   c010015b <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 25 51 00 00       	call   c01051b1 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 e9 1f 00 00       	call   c010207a <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 70 21 00 00       	call   c0102206 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 82 79 00 00       	call   c0107a1d <vmm_init>

    ide_init();                 // init ide devices
c010009b:	e8 36 17 00 00       	call   c01017d6 <ide_init>
    swap_init();                // init swap
c01000a0:	e8 8b 64 00 00       	call   c0106530 <swap_init>

    clock_init();               // init clock interrupt
c01000a5:	e8 51 0d 00 00       	call   c0100dfb <clock_init>
    intr_enable();              // enable irq interrupt
c01000aa:	e8 29 1f 00 00       	call   c0101fd8 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    long cnt = 0;
c01000af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
	if ((++cnt) % 10000000 == 0)
c01000b6:	ff 45 f4             	incl   -0xc(%ebp)
c01000b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c01000bc:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
c01000c1:	89 c8                	mov    %ecx,%eax
c01000c3:	f7 ea                	imul   %edx
c01000c5:	89 d0                	mov    %edx,%eax
c01000c7:	c1 f8 16             	sar    $0x16,%eax
c01000ca:	89 ca                	mov    %ecx,%edx
c01000cc:	c1 fa 1f             	sar    $0x1f,%edx
c01000cf:	29 d0                	sub    %edx,%eax
c01000d1:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
c01000d7:	89 c8                	mov    %ecx,%eax
c01000d9:	29 d0                	sub    %edx,%eax
c01000db:	85 c0                	test   %eax,%eax
c01000dd:	75 d7                	jne    c01000b6 <kern_init+0x80>
	    lab1_print_cur_status();
c01000df:	e8 9f 00 00 00       	call   c0100183 <lab1_print_cur_status>
	if ((++cnt) % 10000000 == 0)
c01000e4:	eb d0                	jmp    c01000b6 <kern_init+0x80>

c01000e6 <grade_backtrace2>:
	}
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000e6:	55                   	push   %ebp
c01000e7:	89 e5                	mov    %esp,%ebp
c01000e9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000f3:	00 
c01000f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000fb:	00 
c01000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100103:	e8 0e 0c 00 00       	call   c0100d16 <mon_backtrace>
}
c0100108:	90                   	nop
c0100109:	89 ec                	mov    %ebp,%esp
c010010b:	5d                   	pop    %ebp
c010010c:	c3                   	ret    

c010010d <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c010010d:	55                   	push   %ebp
c010010e:	89 e5                	mov    %esp,%ebp
c0100110:	83 ec 18             	sub    $0x18,%esp
c0100113:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c0100116:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c0100119:	8b 55 0c             	mov    0xc(%ebp),%edx
c010011c:	8d 5d 08             	lea    0x8(%ebp),%ebx
c010011f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100122:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100126:	89 54 24 08          	mov    %edx,0x8(%esp)
c010012a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010012e:	89 04 24             	mov    %eax,(%esp)
c0100131:	e8 b0 ff ff ff       	call   c01000e6 <grade_backtrace2>
}
c0100136:	90                   	nop
c0100137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010013a:	89 ec                	mov    %ebp,%esp
c010013c:	5d                   	pop    %ebp
c010013d:	c3                   	ret    

c010013e <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c010013e:	55                   	push   %ebp
c010013f:	89 e5                	mov    %esp,%ebp
c0100141:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100144:	8b 45 10             	mov    0x10(%ebp),%eax
c0100147:	89 44 24 04          	mov    %eax,0x4(%esp)
c010014b:	8b 45 08             	mov    0x8(%ebp),%eax
c010014e:	89 04 24             	mov    %eax,(%esp)
c0100151:	e8 b7 ff ff ff       	call   c010010d <grade_backtrace1>
}
c0100156:	90                   	nop
c0100157:	89 ec                	mov    %ebp,%esp
c0100159:	5d                   	pop    %ebp
c010015a:	c3                   	ret    

c010015b <grade_backtrace>:

void
grade_backtrace(void) {
c010015b:	55                   	push   %ebp
c010015c:	89 e5                	mov    %esp,%ebp
c010015e:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100161:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100166:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010016d:	ff 
c010016e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100179:	e8 c0 ff ff ff       	call   c010013e <grade_backtrace0>
}
c010017e:	90                   	nop
c010017f:	89 ec                	mov    %ebp,%esp
c0100181:	5d                   	pop    %ebp
c0100182:	c3                   	ret    

c0100183 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100183:	55                   	push   %ebp
c0100184:	89 e5                	mov    %esp,%ebp
c0100186:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100189:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010018c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010018f:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100192:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100195:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100199:	83 e0 03             	and    $0x3,%eax
c010019c:	89 c2                	mov    %eax,%edx
c010019e:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001a3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ab:	c7 04 24 81 91 10 c0 	movl   $0xc0109181,(%esp)
c01001b2:	e8 ee 01 00 00       	call   c01003a5 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c01001b7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01001bb:	89 c2                	mov    %eax,%edx
c01001bd:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001c2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ca:	c7 04 24 8f 91 10 c0 	movl   $0xc010918f,(%esp)
c01001d1:	e8 cf 01 00 00       	call   c01003a5 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001d6:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001da:	89 c2                	mov    %eax,%edx
c01001dc:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001e1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e9:	c7 04 24 9d 91 10 c0 	movl   $0xc010919d,(%esp)
c01001f0:	e8 b0 01 00 00       	call   c01003a5 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001f5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001f9:	89 c2                	mov    %eax,%edx
c01001fb:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c0100200:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100204:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100208:	c7 04 24 ab 91 10 c0 	movl   $0xc01091ab,(%esp)
c010020f:	e8 91 01 00 00       	call   c01003a5 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c0100214:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0100218:	89 c2                	mov    %eax,%edx
c010021a:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010021f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100223:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100227:	c7 04 24 b9 91 10 c0 	movl   $0xc01091b9,(%esp)
c010022e:	e8 72 01 00 00       	call   c01003a5 <cprintf>
    round ++;
c0100233:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c0100238:	40                   	inc    %eax
c0100239:	a3 00 60 12 c0       	mov    %eax,0xc0126000
}
c010023e:	90                   	nop
c010023f:	89 ec                	mov    %ebp,%esp
c0100241:	5d                   	pop    %ebp
c0100242:	c3                   	ret    

c0100243 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100243:	55                   	push   %ebp
c0100244:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	__asm__ __volatile__ (
c0100246:	83 ec 08             	sub    $0x8,%esp
c0100249:	cd 78                	int    $0x78
c010024b:	89 ec                	mov    %ebp,%esp
		"int %0 \n"
        "movl %%ebp, %%esp\n"
		:
		:"i" (T_SWITCH_TOU)
	);
}
c010024d:	90                   	nop
c010024e:	5d                   	pop    %ebp
c010024f:	c3                   	ret    

c0100250 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100250:	55                   	push   %ebp
c0100251:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
c0100253:	cd 79                	int    $0x79
c0100255:	89 ec                	mov    %ebp,%esp
    	"int %0 \n"
    	"movl %%ebp,%%esp \n" 
    	:
    	:"i"(T_SWITCH_TOK)
    );
}
c0100257:	90                   	nop
c0100258:	5d                   	pop    %ebp
c0100259:	c3                   	ret    

c010025a <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010025a:	55                   	push   %ebp
c010025b:	89 e5                	mov    %esp,%ebp
c010025d:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100260:	e8 1e ff ff ff       	call   c0100183 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100265:	c7 04 24 c8 91 10 c0 	movl   $0xc01091c8,(%esp)
c010026c:	e8 34 01 00 00       	call   c01003a5 <cprintf>
    lab1_switch_to_user();
c0100271:	e8 cd ff ff ff       	call   c0100243 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100276:	e8 08 ff ff ff       	call   c0100183 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010027b:	c7 04 24 e8 91 10 c0 	movl   $0xc01091e8,(%esp)
c0100282:	e8 1e 01 00 00       	call   c01003a5 <cprintf>
    lab1_switch_to_kernel();
c0100287:	e8 c4 ff ff ff       	call   c0100250 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010028c:	e8 f2 fe ff ff       	call   c0100183 <lab1_print_cur_status>
}
c0100291:	90                   	nop
c0100292:	89 ec                	mov    %ebp,%esp
c0100294:	5d                   	pop    %ebp
c0100295:	c3                   	ret    

c0100296 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100296:	55                   	push   %ebp
c0100297:	89 e5                	mov    %esp,%ebp
c0100299:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010029c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01002a0:	74 13                	je     c01002b5 <readline+0x1f>
        cprintf("%s", prompt);
c01002a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a9:	c7 04 24 07 92 10 c0 	movl   $0xc0109207,(%esp)
c01002b0:	e8 f0 00 00 00       	call   c01003a5 <cprintf>
    }
    int i = 0, c;
c01002b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01002bc:	e8 73 01 00 00       	call   c0100434 <getchar>
c01002c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01002c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01002c8:	79 07                	jns    c01002d1 <readline+0x3b>
            return NULL;
c01002ca:	b8 00 00 00 00       	mov    $0x0,%eax
c01002cf:	eb 78                	jmp    c0100349 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01002d1:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01002d5:	7e 28                	jle    c01002ff <readline+0x69>
c01002d7:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002de:	7f 1f                	jg     c01002ff <readline+0x69>
            cputchar(c);
c01002e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 e2 00 00 00       	call   c01003cd <cputchar>
            buf[i ++] = c;
c01002eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ee:	8d 50 01             	lea    0x1(%eax),%edx
c01002f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002f7:	88 90 20 60 12 c0    	mov    %dl,-0x3fed9fe0(%eax)
c01002fd:	eb 45                	jmp    c0100344 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002ff:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0100303:	75 16                	jne    c010031b <readline+0x85>
c0100305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100309:	7e 10                	jle    c010031b <readline+0x85>
            cputchar(c);
c010030b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010030e:	89 04 24             	mov    %eax,(%esp)
c0100311:	e8 b7 00 00 00       	call   c01003cd <cputchar>
            i --;
c0100316:	ff 4d f4             	decl   -0xc(%ebp)
c0100319:	eb 29                	jmp    c0100344 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c010031b:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c010031f:	74 06                	je     c0100327 <readline+0x91>
c0100321:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0100325:	75 95                	jne    c01002bc <readline+0x26>
            cputchar(c);
c0100327:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010032a:	89 04 24             	mov    %eax,(%esp)
c010032d:	e8 9b 00 00 00       	call   c01003cd <cputchar>
            buf[i] = '\0';
c0100332:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100335:	05 20 60 12 c0       	add    $0xc0126020,%eax
c010033a:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010033d:	b8 20 60 12 c0       	mov    $0xc0126020,%eax
c0100342:	eb 05                	jmp    c0100349 <readline+0xb3>
        c = getchar();
c0100344:	e9 73 ff ff ff       	jmp    c01002bc <readline+0x26>
        }
    }
}
c0100349:	89 ec                	mov    %ebp,%esp
c010034b:	5d                   	pop    %ebp
c010034c:	c3                   	ret    

c010034d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010034d:	55                   	push   %ebp
c010034e:	89 e5                	mov    %esp,%ebp
c0100350:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100353:	8b 45 08             	mov    0x8(%ebp),%eax
c0100356:	89 04 24             	mov    %eax,(%esp)
c0100359:	e8 6d 13 00 00       	call   c01016cb <cons_putc>
    (*cnt) ++;
c010035e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100361:	8b 00                	mov    (%eax),%eax
c0100363:	8d 50 01             	lea    0x1(%eax),%edx
c0100366:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100369:	89 10                	mov    %edx,(%eax)
}
c010036b:	90                   	nop
c010036c:	89 ec                	mov    %ebp,%esp
c010036e:	5d                   	pop    %ebp
c010036f:	c3                   	ret    

c0100370 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100370:	55                   	push   %ebp
c0100371:	89 e5                	mov    %esp,%ebp
c0100373:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010037d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100380:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 44 24 08          	mov    %eax,0x8(%esp)
c010038b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010038e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100392:	c7 04 24 4d 03 10 c0 	movl   $0xc010034d,(%esp)
c0100399:	e8 82 83 00 00       	call   c0108720 <vprintfmt>
    return cnt;
c010039e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003a1:	89 ec                	mov    %ebp,%esp
c01003a3:	5d                   	pop    %ebp
c01003a4:	c3                   	ret    

c01003a5 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01003a5:	55                   	push   %ebp
c01003a6:	89 e5                	mov    %esp,%ebp
c01003a8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
c01003ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01003b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01003bb:	89 04 24             	mov    %eax,(%esp)
c01003be:	e8 ad ff ff ff       	call   c0100370 <vcprintf>
c01003c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01003c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003c9:	89 ec                	mov    %ebp,%esp
c01003cb:	5d                   	pop    %ebp
c01003cc:	c3                   	ret    

c01003cd <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01003cd:	55                   	push   %ebp
c01003ce:	89 e5                	mov    %esp,%ebp
c01003d0:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01003d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003d6:	89 04 24             	mov    %eax,(%esp)
c01003d9:	e8 ed 12 00 00       	call   c01016cb <cons_putc>
}
c01003de:	90                   	nop
c01003df:	89 ec                	mov    %ebp,%esp
c01003e1:	5d                   	pop    %ebp
c01003e2:	c3                   	ret    

c01003e3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003e3:	55                   	push   %ebp
c01003e4:	89 e5                	mov    %esp,%ebp
c01003e6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003f0:	eb 13                	jmp    c0100405 <cputs+0x22>
        cputch(c, &cnt);
c01003f2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003f6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003fd:	89 04 24             	mov    %eax,(%esp)
c0100400:	e8 48 ff ff ff       	call   c010034d <cputch>
    while ((c = *str ++) != '\0') {
c0100405:	8b 45 08             	mov    0x8(%ebp),%eax
c0100408:	8d 50 01             	lea    0x1(%eax),%edx
c010040b:	89 55 08             	mov    %edx,0x8(%ebp)
c010040e:	0f b6 00             	movzbl (%eax),%eax
c0100411:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100414:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100418:	75 d8                	jne    c01003f2 <cputs+0xf>
    }
    cputch('\n', &cnt);
c010041a:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010041d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100421:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100428:	e8 20 ff ff ff       	call   c010034d <cputch>
    return cnt;
c010042d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100430:	89 ec                	mov    %ebp,%esp
c0100432:	5d                   	pop    %ebp
c0100433:	c3                   	ret    

c0100434 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100434:	55                   	push   %ebp
c0100435:	89 e5                	mov    %esp,%ebp
c0100437:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010043a:	90                   	nop
c010043b:	e8 ca 12 00 00       	call   c010170a <cons_getc>
c0100440:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100443:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100447:	74 f2                	je     c010043b <getchar+0x7>
        /* do nothing */;
    return c;
c0100449:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010044c:	89 ec                	mov    %ebp,%esp
c010044e:	5d                   	pop    %ebp
c010044f:	c3                   	ret    

c0100450 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100450:	55                   	push   %ebp
c0100451:	89 e5                	mov    %esp,%ebp
c0100453:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100456:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100459:	8b 00                	mov    (%eax),%eax
c010045b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010045e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100461:	8b 00                	mov    (%eax),%eax
c0100463:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010046d:	e9 ca 00 00 00       	jmp    c010053c <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100472:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100475:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100478:	01 d0                	add    %edx,%eax
c010047a:	89 c2                	mov    %eax,%edx
c010047c:	c1 ea 1f             	shr    $0x1f,%edx
c010047f:	01 d0                	add    %edx,%eax
c0100481:	d1 f8                	sar    %eax
c0100483:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100486:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100489:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010048c:	eb 03                	jmp    c0100491 <stab_binsearch+0x41>
            m --;
c010048e:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100491:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100494:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100497:	7c 1f                	jl     c01004b8 <stab_binsearch+0x68>
c0100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049c:	89 d0                	mov    %edx,%eax
c010049e:	01 c0                	add    %eax,%eax
c01004a0:	01 d0                	add    %edx,%eax
c01004a2:	c1 e0 02             	shl    $0x2,%eax
c01004a5:	89 c2                	mov    %eax,%edx
c01004a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004aa:	01 d0                	add    %edx,%eax
c01004ac:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01004b0:	0f b6 c0             	movzbl %al,%eax
c01004b3:	39 45 14             	cmp    %eax,0x14(%ebp)
c01004b6:	75 d6                	jne    c010048e <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c01004b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004bb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004be:	7d 09                	jge    c01004c9 <stab_binsearch+0x79>
            l = true_m + 1;
c01004c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004c3:	40                   	inc    %eax
c01004c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01004c7:	eb 73                	jmp    c010053c <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c01004c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01004d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d3:	89 d0                	mov    %edx,%eax
c01004d5:	01 c0                	add    %eax,%eax
c01004d7:	01 d0                	add    %edx,%eax
c01004d9:	c1 e0 02             	shl    $0x2,%eax
c01004dc:	89 c2                	mov    %eax,%edx
c01004de:	8b 45 08             	mov    0x8(%ebp),%eax
c01004e1:	01 d0                	add    %edx,%eax
c01004e3:	8b 40 08             	mov    0x8(%eax),%eax
c01004e6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004e9:	76 11                	jbe    c01004fc <stab_binsearch+0xac>
            *region_left = m;
c01004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f1:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f6:	40                   	inc    %eax
c01004f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004fa:	eb 40                	jmp    c010053c <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ff:	89 d0                	mov    %edx,%eax
c0100501:	01 c0                	add    %eax,%eax
c0100503:	01 d0                	add    %edx,%eax
c0100505:	c1 e0 02             	shl    $0x2,%eax
c0100508:	89 c2                	mov    %eax,%edx
c010050a:	8b 45 08             	mov    0x8(%ebp),%eax
c010050d:	01 d0                	add    %edx,%eax
c010050f:	8b 40 08             	mov    0x8(%eax),%eax
c0100512:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100515:	73 14                	jae    c010052b <stab_binsearch+0xdb>
            *region_right = m - 1;
c0100517:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010051a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010051d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100520:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100522:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100525:	48                   	dec    %eax
c0100526:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100529:	eb 11                	jmp    c010053c <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010052b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100531:	89 10                	mov    %edx,(%eax)
            l = m;
c0100533:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100536:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100539:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c010053c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010053f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100542:	0f 8e 2a ff ff ff    	jle    c0100472 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100548:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010054c:	75 0f                	jne    c010055d <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	8b 00                	mov    (%eax),%eax
c0100553:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100556:	8b 45 10             	mov    0x10(%ebp),%eax
c0100559:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010055b:	eb 3e                	jmp    c010059b <stab_binsearch+0x14b>
        l = *region_right;
c010055d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100560:	8b 00                	mov    (%eax),%eax
c0100562:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100565:	eb 03                	jmp    c010056a <stab_binsearch+0x11a>
c0100567:	ff 4d fc             	decl   -0x4(%ebp)
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	8b 00                	mov    (%eax),%eax
c010056f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100572:	7e 1f                	jle    c0100593 <stab_binsearch+0x143>
c0100574:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100577:	89 d0                	mov    %edx,%eax
c0100579:	01 c0                	add    %eax,%eax
c010057b:	01 d0                	add    %edx,%eax
c010057d:	c1 e0 02             	shl    $0x2,%eax
c0100580:	89 c2                	mov    %eax,%edx
c0100582:	8b 45 08             	mov    0x8(%ebp),%eax
c0100585:	01 d0                	add    %edx,%eax
c0100587:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010058b:	0f b6 c0             	movzbl %al,%eax
c010058e:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100591:	75 d4                	jne    c0100567 <stab_binsearch+0x117>
        *region_left = l;
c0100593:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100596:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100599:	89 10                	mov    %edx,(%eax)
}
c010059b:	90                   	nop
c010059c:	89 ec                	mov    %ebp,%esp
c010059e:	5d                   	pop    %ebp
c010059f:	c3                   	ret    

c01005a0 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01005a0:	55                   	push   %ebp
c01005a1:	89 e5                	mov    %esp,%ebp
c01005a3:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a9:	c7 00 0c 92 10 c0    	movl   $0xc010920c,(%eax)
    info->eip_line = 0;
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01005b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005bc:	c7 40 08 0c 92 10 c0 	movl   $0xc010920c,0x8(%eax)
    info->eip_fn_namelen = 9;
c01005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c6:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01005d3:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005e0:	c7 45 f4 24 b2 10 c0 	movl   $0xc010b224,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005e7:	c7 45 f0 68 b8 11 c0 	movl   $0xc011b868,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005ee:	c7 45 ec 69 b8 11 c0 	movl   $0xc011b869,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005f5:	c7 45 e8 92 07 12 c0 	movl   $0xc0120792,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005ff:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100602:	76 0b                	jbe    c010060f <debuginfo_eip+0x6f>
c0100604:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100607:	48                   	dec    %eax
c0100608:	0f b6 00             	movzbl (%eax),%eax
c010060b:	84 c0                	test   %al,%al
c010060d:	74 0a                	je     c0100619 <debuginfo_eip+0x79>
        return -1;
c010060f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100614:	e9 ab 02 00 00       	jmp    c01008c4 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100619:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100620:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100623:	2b 45 f4             	sub    -0xc(%ebp),%eax
c0100626:	c1 f8 02             	sar    $0x2,%eax
c0100629:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c010062f:	48                   	dec    %eax
c0100630:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100633:	8b 45 08             	mov    0x8(%ebp),%eax
c0100636:	89 44 24 10          	mov    %eax,0x10(%esp)
c010063a:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100641:	00 
c0100642:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100645:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100649:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010064c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100650:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100653:	89 04 24             	mov    %eax,(%esp)
c0100656:	e8 f5 fd ff ff       	call   c0100450 <stab_binsearch>
    if (lfile == 0)
c010065b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010065e:	85 c0                	test   %eax,%eax
c0100660:	75 0a                	jne    c010066c <debuginfo_eip+0xcc>
        return -1;
c0100662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100667:	e9 58 02 00 00       	jmp    c01008c4 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010066c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010066f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100672:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100675:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100678:	8b 45 08             	mov    0x8(%ebp),%eax
c010067b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010067f:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100686:	00 
c0100687:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010068a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010068e:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100691:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100698:	89 04 24             	mov    %eax,(%esp)
c010069b:	e8 b0 fd ff ff       	call   c0100450 <stab_binsearch>

    if (lfun <= rfun) {
c01006a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006a6:	39 c2                	cmp    %eax,%edx
c01006a8:	7f 78                	jg     c0100722 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01006aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006ad:	89 c2                	mov    %eax,%edx
c01006af:	89 d0                	mov    %edx,%eax
c01006b1:	01 c0                	add    %eax,%eax
c01006b3:	01 d0                	add    %edx,%eax
c01006b5:	c1 e0 02             	shl    $0x2,%eax
c01006b8:	89 c2                	mov    %eax,%edx
c01006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bd:	01 d0                	add    %edx,%eax
c01006bf:	8b 10                	mov    (%eax),%edx
c01006c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c4:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01006c7:	39 c2                	cmp    %eax,%edx
c01006c9:	73 22                	jae    c01006ed <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c01006cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006ce:	89 c2                	mov    %eax,%edx
c01006d0:	89 d0                	mov    %edx,%eax
c01006d2:	01 c0                	add    %eax,%eax
c01006d4:	01 d0                	add    %edx,%eax
c01006d6:	c1 e0 02             	shl    $0x2,%eax
c01006d9:	89 c2                	mov    %eax,%edx
c01006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006de:	01 d0                	add    %edx,%eax
c01006e0:	8b 10                	mov    (%eax),%edx
c01006e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006e5:	01 c2                	add    %eax,%edx
c01006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ea:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006f0:	89 c2                	mov    %eax,%edx
c01006f2:	89 d0                	mov    %edx,%eax
c01006f4:	01 c0                	add    %eax,%eax
c01006f6:	01 d0                	add    %edx,%eax
c01006f8:	c1 e0 02             	shl    $0x2,%eax
c01006fb:	89 c2                	mov    %eax,%edx
c01006fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100700:	01 d0                	add    %edx,%eax
c0100702:	8b 50 08             	mov    0x8(%eax),%edx
c0100705:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100708:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010070b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070e:	8b 40 10             	mov    0x10(%eax),%eax
c0100711:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100717:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010071a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100720:	eb 15                	jmp    c0100737 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100722:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100725:	8b 55 08             	mov    0x8(%ebp),%edx
c0100728:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010072b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010072e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100731:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100734:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100737:	8b 45 0c             	mov    0xc(%ebp),%eax
c010073a:	8b 40 08             	mov    0x8(%eax),%eax
c010073d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100744:	00 
c0100745:	89 04 24             	mov    %eax,(%esp)
c0100748:	e8 f8 86 00 00       	call   c0108e45 <strfind>
c010074d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100750:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100753:	29 c8                	sub    %ecx,%eax
c0100755:	89 c2                	mov    %eax,%edx
c0100757:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075a:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010075d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100760:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100764:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010076b:	00 
c010076c:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010076f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100773:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100776:	89 44 24 04          	mov    %eax,0x4(%esp)
c010077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077d:	89 04 24             	mov    %eax,(%esp)
c0100780:	e8 cb fc ff ff       	call   c0100450 <stab_binsearch>
    if (lline <= rline) {
c0100785:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100788:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010078b:	39 c2                	cmp    %eax,%edx
c010078d:	7f 23                	jg     c01007b2 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c010078f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100792:	89 c2                	mov    %eax,%edx
c0100794:	89 d0                	mov    %edx,%eax
c0100796:	01 c0                	add    %eax,%eax
c0100798:	01 d0                	add    %edx,%eax
c010079a:	c1 e0 02             	shl    $0x2,%eax
c010079d:	89 c2                	mov    %eax,%edx
c010079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a2:	01 d0                	add    %edx,%eax
c01007a4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007a8:	89 c2                	mov    %eax,%edx
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01007b0:	eb 11                	jmp    c01007c3 <debuginfo_eip+0x223>
        return -1;
c01007b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007b7:	e9 08 01 00 00       	jmp    c01008c4 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01007bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bf:	48                   	dec    %eax
c01007c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c01007c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007c9:	39 c2                	cmp    %eax,%edx
c01007cb:	7c 56                	jl     c0100823 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c01007cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d0:	89 c2                	mov    %eax,%edx
c01007d2:	89 d0                	mov    %edx,%eax
c01007d4:	01 c0                	add    %eax,%eax
c01007d6:	01 d0                	add    %edx,%eax
c01007d8:	c1 e0 02             	shl    $0x2,%eax
c01007db:	89 c2                	mov    %eax,%edx
c01007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e0:	01 d0                	add    %edx,%eax
c01007e2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007e6:	3c 84                	cmp    $0x84,%al
c01007e8:	74 39                	je     c0100823 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	89 d0                	mov    %edx,%eax
c01007f1:	01 c0                	add    %eax,%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	c1 e0 02             	shl    $0x2,%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100803:	3c 64                	cmp    $0x64,%al
c0100805:	75 b5                	jne    c01007bc <debuginfo_eip+0x21c>
c0100807:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010080a:	89 c2                	mov    %eax,%edx
c010080c:	89 d0                	mov    %edx,%eax
c010080e:	01 c0                	add    %eax,%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	c1 e0 02             	shl    $0x2,%eax
c0100815:	89 c2                	mov    %eax,%edx
c0100817:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081a:	01 d0                	add    %edx,%eax
c010081c:	8b 40 08             	mov    0x8(%eax),%eax
c010081f:	85 c0                	test   %eax,%eax
c0100821:	74 99                	je     c01007bc <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100823:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100826:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100829:	39 c2                	cmp    %eax,%edx
c010082b:	7c 42                	jl     c010086f <debuginfo_eip+0x2cf>
c010082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100830:	89 c2                	mov    %eax,%edx
c0100832:	89 d0                	mov    %edx,%eax
c0100834:	01 c0                	add    %eax,%eax
c0100836:	01 d0                	add    %edx,%eax
c0100838:	c1 e0 02             	shl    $0x2,%eax
c010083b:	89 c2                	mov    %eax,%edx
c010083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100840:	01 d0                	add    %edx,%eax
c0100842:	8b 10                	mov    (%eax),%edx
c0100844:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100847:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010084a:	39 c2                	cmp    %eax,%edx
c010084c:	73 21                	jae    c010086f <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010084e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100851:	89 c2                	mov    %eax,%edx
c0100853:	89 d0                	mov    %edx,%eax
c0100855:	01 c0                	add    %eax,%eax
c0100857:	01 d0                	add    %edx,%eax
c0100859:	c1 e0 02             	shl    $0x2,%eax
c010085c:	89 c2                	mov    %eax,%edx
c010085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	8b 10                	mov    (%eax),%edx
c0100865:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100868:	01 c2                	add    %eax,%edx
c010086a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010086d:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010086f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100872:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100875:	39 c2                	cmp    %eax,%edx
c0100877:	7d 46                	jge    c01008bf <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c0100879:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010087c:	40                   	inc    %eax
c010087d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100880:	eb 16                	jmp    c0100898 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100882:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100885:	8b 40 14             	mov    0x14(%eax),%eax
c0100888:	8d 50 01             	lea    0x1(%eax),%edx
c010088b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010088e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100891:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100894:	40                   	inc    %eax
c0100895:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100898:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010089b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010089e:	39 c2                	cmp    %eax,%edx
c01008a0:	7d 1d                	jge    c01008bf <debuginfo_eip+0x31f>
c01008a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a5:	89 c2                	mov    %eax,%edx
c01008a7:	89 d0                	mov    %edx,%eax
c01008a9:	01 c0                	add    %eax,%eax
c01008ab:	01 d0                	add    %edx,%eax
c01008ad:	c1 e0 02             	shl    $0x2,%eax
c01008b0:	89 c2                	mov    %eax,%edx
c01008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b5:	01 d0                	add    %edx,%eax
c01008b7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008bb:	3c a0                	cmp    $0xa0,%al
c01008bd:	74 c3                	je     c0100882 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c01008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01008c4:	89 ec                	mov    %ebp,%esp
c01008c6:	5d                   	pop    %ebp
c01008c7:	c3                   	ret    

c01008c8 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c01008c8:	55                   	push   %ebp
c01008c9:	89 e5                	mov    %esp,%ebp
c01008cb:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c01008ce:	c7 04 24 16 92 10 c0 	movl   $0xc0109216,(%esp)
c01008d5:	e8 cb fa ff ff       	call   c01003a5 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01008da:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008e1:	c0 
c01008e2:	c7 04 24 2f 92 10 c0 	movl   $0xc010922f,(%esp)
c01008e9:	e8 b7 fa ff ff       	call   c01003a5 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ee:	c7 44 24 04 59 91 10 	movl   $0xc0109159,0x4(%esp)
c01008f5:	c0 
c01008f6:	c7 04 24 47 92 10 c0 	movl   $0xc0109247,(%esp)
c01008fd:	e8 a3 fa ff ff       	call   c01003a5 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100902:	c7 44 24 04 00 60 12 	movl   $0xc0126000,0x4(%esp)
c0100909:	c0 
c010090a:	c7 04 24 5f 92 10 c0 	movl   $0xc010925f,(%esp)
c0100911:	e8 8f fa ff ff       	call   c01003a5 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100916:	c7 44 24 04 74 71 12 	movl   $0xc0127174,0x4(%esp)
c010091d:	c0 
c010091e:	c7 04 24 77 92 10 c0 	movl   $0xc0109277,(%esp)
c0100925:	e8 7b fa ff ff       	call   c01003a5 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010092a:	b8 74 71 12 c0       	mov    $0xc0127174,%eax
c010092f:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c0100934:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100939:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c010093f:	85 c0                	test   %eax,%eax
c0100941:	0f 48 c2             	cmovs  %edx,%eax
c0100944:	c1 f8 0a             	sar    $0xa,%eax
c0100947:	89 44 24 04          	mov    %eax,0x4(%esp)
c010094b:	c7 04 24 90 92 10 c0 	movl   $0xc0109290,(%esp)
c0100952:	e8 4e fa ff ff       	call   c01003a5 <cprintf>
}
c0100957:	90                   	nop
c0100958:	89 ec                	mov    %ebp,%esp
c010095a:	5d                   	pop    %ebp
c010095b:	c3                   	ret    

c010095c <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010095c:	55                   	push   %ebp
c010095d:	89 e5                	mov    %esp,%ebp
c010095f:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100965:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010096c:	8b 45 08             	mov    0x8(%ebp),%eax
c010096f:	89 04 24             	mov    %eax,(%esp)
c0100972:	e8 29 fc ff ff       	call   c01005a0 <debuginfo_eip>
c0100977:	85 c0                	test   %eax,%eax
c0100979:	74 15                	je     c0100990 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010097b:	8b 45 08             	mov    0x8(%ebp),%eax
c010097e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100982:	c7 04 24 ba 92 10 c0 	movl   $0xc01092ba,(%esp)
c0100989:	e8 17 fa ff ff       	call   c01003a5 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010098e:	eb 6c                	jmp    c01009fc <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100997:	eb 1b                	jmp    c01009b4 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100999:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010099c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010099f:	01 d0                	add    %edx,%eax
c01009a1:	0f b6 10             	movzbl (%eax),%edx
c01009a4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ad:	01 c8                	add    %ecx,%eax
c01009af:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009b1:	ff 45 f4             	incl   -0xc(%ebp)
c01009b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01009b7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01009ba:	7c dd                	jl     c0100999 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c01009bc:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c01009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009c5:	01 d0                	add    %edx,%eax
c01009c7:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c01009ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c01009cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01009d0:	29 d0                	sub    %edx,%eax
c01009d2:	89 c1                	mov    %eax,%ecx
c01009d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01009d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009de:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009e4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009e8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f0:	c7 04 24 d6 92 10 c0 	movl   $0xc01092d6,(%esp)
c01009f7:	e8 a9 f9 ff ff       	call   c01003a5 <cprintf>
}
c01009fc:	90                   	nop
c01009fd:	89 ec                	mov    %ebp,%esp
c01009ff:	5d                   	pop    %ebp
c0100a00:	c3                   	ret    

c0100a01 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a01:	55                   	push   %ebp
c0100a02:	89 e5                	mov    %esp,%ebp
c0100a04:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a07:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a10:	89 ec                	mov    %ebp,%esp
c0100a12:	5d                   	pop    %ebp
c0100a13:	c3                   	ret    

c0100a14 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a14:	55                   	push   %ebp
c0100a15:	89 e5                	mov    %esp,%ebp
c0100a17:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a1a:	89 e8                	mov    %ebp,%eax
c0100a1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a22:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a25:	e8 d7 ff ff ff       	call   c0100a01 <read_eip>
c0100a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a2d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a34:	e9 84 00 00 00       	jmp    c0100abd <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a3c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a47:	c7 04 24 e8 92 10 c0 	movl   $0xc01092e8,(%esp)
c0100a4e:	e8 52 f9 ff ff       	call   c01003a5 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a56:	83 c0 08             	add    $0x8,%eax
c0100a59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a5c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a63:	eb 24                	jmp    c0100a89 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100a65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a72:	01 d0                	add    %edx,%eax
c0100a74:	8b 00                	mov    (%eax),%eax
c0100a76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a7a:	c7 04 24 04 93 10 c0 	movl   $0xc0109304,(%esp)
c0100a81:	e8 1f f9 ff ff       	call   c01003a5 <cprintf>
        for (j = 0; j < 4; j ++) {
c0100a86:	ff 45 e8             	incl   -0x18(%ebp)
c0100a89:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a8d:	7e d6                	jle    c0100a65 <print_stackframe+0x51>
        }
        cprintf("\n");
c0100a8f:	c7 04 24 0c 93 10 c0 	movl   $0xc010930c,(%esp)
c0100a96:	e8 0a f9 ff ff       	call   c01003a5 <cprintf>
        print_debuginfo(eip - 1);
c0100a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a9e:	48                   	dec    %eax
c0100a9f:	89 04 24             	mov    %eax,(%esp)
c0100aa2:	e8 b5 fe ff ff       	call   c010095c <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aaa:	83 c0 04             	add    $0x4,%eax
c0100aad:	8b 00                	mov    (%eax),%eax
c0100aaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab5:	8b 00                	mov    (%eax),%eax
c0100ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100aba:	ff 45 ec             	incl   -0x14(%ebp)
c0100abd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ac1:	74 0a                	je     c0100acd <print_stackframe+0xb9>
c0100ac3:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100ac7:	0f 8e 6c ff ff ff    	jle    c0100a39 <print_stackframe+0x25>
    }
}
c0100acd:	90                   	nop
c0100ace:	89 ec                	mov    %ebp,%esp
c0100ad0:	5d                   	pop    %ebp
c0100ad1:	c3                   	ret    

c0100ad2 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ad2:	55                   	push   %ebp
c0100ad3:	89 e5                	mov    %esp,%ebp
c0100ad5:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100adf:	eb 0c                	jmp    c0100aed <parse+0x1b>
            *buf ++ = '\0';
c0100ae1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae4:	8d 50 01             	lea    0x1(%eax),%edx
c0100ae7:	89 55 08             	mov    %edx,0x8(%ebp)
c0100aea:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af0:	0f b6 00             	movzbl (%eax),%eax
c0100af3:	84 c0                	test   %al,%al
c0100af5:	74 1d                	je     c0100b14 <parse+0x42>
c0100af7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100afa:	0f b6 00             	movzbl (%eax),%eax
c0100afd:	0f be c0             	movsbl %al,%eax
c0100b00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b04:	c7 04 24 90 93 10 c0 	movl   $0xc0109390,(%esp)
c0100b0b:	e8 01 83 00 00       	call   c0108e11 <strchr>
c0100b10:	85 c0                	test   %eax,%eax
c0100b12:	75 cd                	jne    c0100ae1 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b17:	0f b6 00             	movzbl (%eax),%eax
c0100b1a:	84 c0                	test   %al,%al
c0100b1c:	74 65                	je     c0100b83 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b1e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b22:	75 14                	jne    c0100b38 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b24:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b2b:	00 
c0100b2c:	c7 04 24 95 93 10 c0 	movl   $0xc0109395,(%esp)
c0100b33:	e8 6d f8 ff ff       	call   c01003a5 <cprintf>
        }
        argv[argc ++] = buf;
c0100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3b:	8d 50 01             	lea    0x1(%eax),%edx
c0100b3e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b4b:	01 c2                	add    %eax,%edx
c0100b4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b50:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b52:	eb 03                	jmp    c0100b57 <parse+0x85>
            buf ++;
c0100b54:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5a:	0f b6 00             	movzbl (%eax),%eax
c0100b5d:	84 c0                	test   %al,%al
c0100b5f:	74 8c                	je     c0100aed <parse+0x1b>
c0100b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b64:	0f b6 00             	movzbl (%eax),%eax
c0100b67:	0f be c0             	movsbl %al,%eax
c0100b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b6e:	c7 04 24 90 93 10 c0 	movl   $0xc0109390,(%esp)
c0100b75:	e8 97 82 00 00       	call   c0108e11 <strchr>
c0100b7a:	85 c0                	test   %eax,%eax
c0100b7c:	74 d6                	je     c0100b54 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b7e:	e9 6a ff ff ff       	jmp    c0100aed <parse+0x1b>
            break;
c0100b83:	90                   	nop
        }
    }
    return argc;
c0100b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b87:	89 ec                	mov    %ebp,%esp
c0100b89:	5d                   	pop    %ebp
c0100b8a:	c3                   	ret    

c0100b8b <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b8b:	55                   	push   %ebp
c0100b8c:	89 e5                	mov    %esp,%ebp
c0100b8e:	83 ec 68             	sub    $0x68,%esp
c0100b91:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b94:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9e:	89 04 24             	mov    %eax,(%esp)
c0100ba1:	e8 2c ff ff ff       	call   c0100ad2 <parse>
c0100ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100ba9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100bad:	75 0a                	jne    c0100bb9 <runcmd+0x2e>
        return 0;
c0100baf:	b8 00 00 00 00       	mov    $0x0,%eax
c0100bb4:	e9 83 00 00 00       	jmp    c0100c3c <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bc0:	eb 5a                	jmp    c0100c1c <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100bc2:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100bc5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100bc8:	89 c8                	mov    %ecx,%eax
c0100bca:	01 c0                	add    %eax,%eax
c0100bcc:	01 c8                	add    %ecx,%eax
c0100bce:	c1 e0 02             	shl    $0x2,%eax
c0100bd1:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100bd6:	8b 00                	mov    (%eax),%eax
c0100bd8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bdc:	89 04 24             	mov    %eax,(%esp)
c0100bdf:	e8 91 81 00 00       	call   c0108d75 <strcmp>
c0100be4:	85 c0                	test   %eax,%eax
c0100be6:	75 31                	jne    c0100c19 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100beb:	89 d0                	mov    %edx,%eax
c0100bed:	01 c0                	add    %eax,%eax
c0100bef:	01 d0                	add    %edx,%eax
c0100bf1:	c1 e0 02             	shl    $0x2,%eax
c0100bf4:	05 08 30 12 c0       	add    $0xc0123008,%eax
c0100bf9:	8b 10                	mov    (%eax),%edx
c0100bfb:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bfe:	83 c0 04             	add    $0x4,%eax
c0100c01:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c04:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c0a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c12:	89 1c 24             	mov    %ebx,(%esp)
c0100c15:	ff d2                	call   *%edx
c0100c17:	eb 23                	jmp    c0100c3c <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c19:	ff 45 f4             	incl   -0xc(%ebp)
c0100c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c1f:	83 f8 02             	cmp    $0x2,%eax
c0100c22:	76 9e                	jbe    c0100bc2 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c24:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c2b:	c7 04 24 b3 93 10 c0 	movl   $0xc01093b3,(%esp)
c0100c32:	e8 6e f7 ff ff       	call   c01003a5 <cprintf>
    return 0;
c0100c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c3f:	89 ec                	mov    %ebp,%esp
c0100c41:	5d                   	pop    %ebp
c0100c42:	c3                   	ret    

c0100c43 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c43:	55                   	push   %ebp
c0100c44:	89 e5                	mov    %esp,%ebp
c0100c46:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c49:	c7 04 24 cc 93 10 c0 	movl   $0xc01093cc,(%esp)
c0100c50:	e8 50 f7 ff ff       	call   c01003a5 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c55:	c7 04 24 f4 93 10 c0 	movl   $0xc01093f4,(%esp)
c0100c5c:	e8 44 f7 ff ff       	call   c01003a5 <cprintf>

    if (tf != NULL) {
c0100c61:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c65:	74 0b                	je     c0100c72 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6a:	89 04 24             	mov    %eax,(%esp)
c0100c6d:	e8 cb 17 00 00       	call   c010243d <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c72:	c7 04 24 19 94 10 c0 	movl   $0xc0109419,(%esp)
c0100c79:	e8 18 f6 ff ff       	call   c0100296 <readline>
c0100c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c85:	74 eb                	je     c0100c72 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c91:	89 04 24             	mov    %eax,(%esp)
c0100c94:	e8 f2 fe ff ff       	call   c0100b8b <runcmd>
c0100c99:	85 c0                	test   %eax,%eax
c0100c9b:	78 02                	js     c0100c9f <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c9d:	eb d3                	jmp    c0100c72 <kmonitor+0x2f>
                break;
c0100c9f:	90                   	nop
            }
        }
    }
}
c0100ca0:	90                   	nop
c0100ca1:	89 ec                	mov    %ebp,%esp
c0100ca3:	5d                   	pop    %ebp
c0100ca4:	c3                   	ret    

c0100ca5 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100ca5:	55                   	push   %ebp
c0100ca6:	89 e5                	mov    %esp,%ebp
c0100ca8:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100cb2:	eb 3d                	jmp    c0100cf1 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cb7:	89 d0                	mov    %edx,%eax
c0100cb9:	01 c0                	add    %eax,%eax
c0100cbb:	01 d0                	add    %edx,%eax
c0100cbd:	c1 e0 02             	shl    $0x2,%eax
c0100cc0:	05 04 30 12 c0       	add    $0xc0123004,%eax
c0100cc5:	8b 10                	mov    (%eax),%edx
c0100cc7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100cca:	89 c8                	mov    %ecx,%eax
c0100ccc:	01 c0                	add    %eax,%eax
c0100cce:	01 c8                	add    %ecx,%eax
c0100cd0:	c1 e0 02             	shl    $0x2,%eax
c0100cd3:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100cd8:	8b 00                	mov    (%eax),%eax
c0100cda:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ce2:	c7 04 24 1d 94 10 c0 	movl   $0xc010941d,(%esp)
c0100ce9:	e8 b7 f6 ff ff       	call   c01003a5 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cee:	ff 45 f4             	incl   -0xc(%ebp)
c0100cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf4:	83 f8 02             	cmp    $0x2,%eax
c0100cf7:	76 bb                	jbe    c0100cb4 <mon_help+0xf>
    }
    return 0;
c0100cf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cfe:	89 ec                	mov    %ebp,%esp
c0100d00:	5d                   	pop    %ebp
c0100d01:	c3                   	ret    

c0100d02 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d02:	55                   	push   %ebp
c0100d03:	89 e5                	mov    %esp,%ebp
c0100d05:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d08:	e8 bb fb ff ff       	call   c01008c8 <print_kerninfo>
    return 0;
c0100d0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d12:	89 ec                	mov    %ebp,%esp
c0100d14:	5d                   	pop    %ebp
c0100d15:	c3                   	ret    

c0100d16 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d16:	55                   	push   %ebp
c0100d17:	89 e5                	mov    %esp,%ebp
c0100d19:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d1c:	e8 f3 fc ff ff       	call   c0100a14 <print_stackframe>
    return 0;
c0100d21:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d26:	89 ec                	mov    %ebp,%esp
c0100d28:	5d                   	pop    %ebp
c0100d29:	c3                   	ret    

c0100d2a <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d2a:	55                   	push   %ebp
c0100d2b:	89 e5                	mov    %esp,%ebp
c0100d2d:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d30:	a1 20 64 12 c0       	mov    0xc0126420,%eax
c0100d35:	85 c0                	test   %eax,%eax
c0100d37:	75 5b                	jne    c0100d94 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d39:	c7 05 20 64 12 c0 01 	movl   $0x1,0xc0126420
c0100d40:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d43:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d50:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d57:	c7 04 24 26 94 10 c0 	movl   $0xc0109426,(%esp)
c0100d5e:	e8 42 f6 ff ff       	call   c01003a5 <cprintf>
    vcprintf(fmt, ap);
c0100d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d6d:	89 04 24             	mov    %eax,(%esp)
c0100d70:	e8 fb f5 ff ff       	call   c0100370 <vcprintf>
    cprintf("\n");
c0100d75:	c7 04 24 42 94 10 c0 	movl   $0xc0109442,(%esp)
c0100d7c:	e8 24 f6 ff ff       	call   c01003a5 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d81:	c7 04 24 44 94 10 c0 	movl   $0xc0109444,(%esp)
c0100d88:	e8 18 f6 ff ff       	call   c01003a5 <cprintf>
    print_stackframe();
c0100d8d:	e8 82 fc ff ff       	call   c0100a14 <print_stackframe>
c0100d92:	eb 01                	jmp    c0100d95 <__panic+0x6b>
        goto panic_dead;
c0100d94:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d95:	e8 46 12 00 00       	call   c0101fe0 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100da1:	e8 9d fe ff ff       	call   c0100c43 <kmonitor>
c0100da6:	eb f2                	jmp    c0100d9a <__panic+0x70>

c0100da8 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100da8:	55                   	push   %ebp
c0100da9:	89 e5                	mov    %esp,%ebp
c0100dab:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100dae:	8d 45 14             	lea    0x14(%ebp),%eax
c0100db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100db4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100db7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc2:	c7 04 24 56 94 10 c0 	movl   $0xc0109456,(%esp)
c0100dc9:	e8 d7 f5 ff ff       	call   c01003a5 <cprintf>
    vcprintf(fmt, ap);
c0100dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dd5:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dd8:	89 04 24             	mov    %eax,(%esp)
c0100ddb:	e8 90 f5 ff ff       	call   c0100370 <vcprintf>
    cprintf("\n");
c0100de0:	c7 04 24 42 94 10 c0 	movl   $0xc0109442,(%esp)
c0100de7:	e8 b9 f5 ff ff       	call   c01003a5 <cprintf>
    va_end(ap);
}
c0100dec:	90                   	nop
c0100ded:	89 ec                	mov    %ebp,%esp
c0100def:	5d                   	pop    %ebp
c0100df0:	c3                   	ret    

c0100df1 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100df1:	55                   	push   %ebp
c0100df2:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100df4:	a1 20 64 12 c0       	mov    0xc0126420,%eax
}
c0100df9:	5d                   	pop    %ebp
c0100dfa:	c3                   	ret    

c0100dfb <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dfb:	55                   	push   %ebp
c0100dfc:	89 e5                	mov    %esp,%ebp
c0100dfe:	83 ec 28             	sub    $0x28,%esp
c0100e01:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e07:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e0b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e0f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e13:	ee                   	out    %al,(%dx)
}
c0100e14:	90                   	nop
c0100e15:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e1b:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e1f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e23:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e27:	ee                   	out    %al,(%dx)
}
c0100e28:	90                   	nop
c0100e29:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e2f:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e33:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e37:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e3b:	ee                   	out    %al,(%dx)
}
c0100e3c:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e3d:	c7 05 24 64 12 c0 00 	movl   $0x0,0xc0126424
c0100e44:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e47:	c7 04 24 74 94 10 c0 	movl   $0xc0109474,(%esp)
c0100e4e:	e8 52 f5 ff ff       	call   c01003a5 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e5a:	e8 e6 11 00 00       	call   c0102045 <pic_enable>
}
c0100e5f:	90                   	nop
c0100e60:	89 ec                	mov    %ebp,%esp
c0100e62:	5d                   	pop    %ebp
c0100e63:	c3                   	ret    

c0100e64 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e64:	55                   	push   %ebp
c0100e65:	89 e5                	mov    %esp,%ebp
c0100e67:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e6a:	9c                   	pushf  
c0100e6b:	58                   	pop    %eax
c0100e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e72:	25 00 02 00 00       	and    $0x200,%eax
c0100e77:	85 c0                	test   %eax,%eax
c0100e79:	74 0c                	je     c0100e87 <__intr_save+0x23>
        intr_disable();
c0100e7b:	e8 60 11 00 00       	call   c0101fe0 <intr_disable>
        return 1;
c0100e80:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e85:	eb 05                	jmp    c0100e8c <__intr_save+0x28>
    }
    return 0;
c0100e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e8c:	89 ec                	mov    %ebp,%esp
c0100e8e:	5d                   	pop    %ebp
c0100e8f:	c3                   	ret    

c0100e90 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e90:	55                   	push   %ebp
c0100e91:	89 e5                	mov    %esp,%ebp
c0100e93:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e9a:	74 05                	je     c0100ea1 <__intr_restore+0x11>
        intr_enable();
c0100e9c:	e8 37 11 00 00       	call   c0101fd8 <intr_enable>
    }
}
c0100ea1:	90                   	nop
c0100ea2:	89 ec                	mov    %ebp,%esp
c0100ea4:	5d                   	pop    %ebp
c0100ea5:	c3                   	ret    

c0100ea6 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100ea6:	55                   	push   %ebp
c0100ea7:	89 e5                	mov    %esp,%ebp
c0100ea9:	83 ec 10             	sub    $0x10,%esp
c0100eac:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100eb2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100eb6:	89 c2                	mov    %eax,%edx
c0100eb8:	ec                   	in     (%dx),%al
c0100eb9:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100ebc:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ec2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ec6:	89 c2                	mov    %eax,%edx
c0100ec8:	ec                   	in     (%dx),%al
c0100ec9:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100ecc:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ed2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ed6:	89 c2                	mov    %eax,%edx
c0100ed8:	ec                   	in     (%dx),%al
c0100ed9:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100edc:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ee2:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ee6:	89 c2                	mov    %eax,%edx
c0100ee8:	ec                   	in     (%dx),%al
c0100ee9:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100eec:	90                   	nop
c0100eed:	89 ec                	mov    %ebp,%esp
c0100eef:	5d                   	pop    %ebp
c0100ef0:	c3                   	ret    

c0100ef1 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ef1:	55                   	push   %ebp
c0100ef2:	89 e5                	mov    %esp,%ebp
c0100ef4:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ef7:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f01:	0f b7 00             	movzwl (%eax),%eax
c0100f04:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f08:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f0b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f10:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f13:	0f b7 00             	movzwl (%eax),%eax
c0100f16:	0f b7 c0             	movzwl %ax,%eax
c0100f19:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f1e:	74 12                	je     c0100f32 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f20:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f27:	66 c7 05 46 64 12 c0 	movw   $0x3b4,0xc0126446
c0100f2e:	b4 03 
c0100f30:	eb 13                	jmp    c0100f45 <cga_init+0x54>
    } else {
        *cp = was;
c0100f32:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f35:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f39:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f3c:	66 c7 05 46 64 12 c0 	movw   $0x3d4,0xc0126446
c0100f43:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f45:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f4c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f50:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f54:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f58:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f5c:	ee                   	out    %al,(%dx)
}
c0100f5d:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f5e:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f65:	40                   	inc    %eax
c0100f66:	0f b7 c0             	movzwl %ax,%eax
c0100f69:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f6d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f71:	89 c2                	mov    %eax,%edx
c0100f73:	ec                   	in     (%dx),%al
c0100f74:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f77:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f7b:	0f b6 c0             	movzbl %al,%eax
c0100f7e:	c1 e0 08             	shl    $0x8,%eax
c0100f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f84:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f8b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f8f:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f93:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f97:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f9b:	ee                   	out    %al,(%dx)
}
c0100f9c:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f9d:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100fa4:	40                   	inc    %eax
c0100fa5:	0f b7 c0             	movzwl %ax,%eax
c0100fa8:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fb0:	89 c2                	mov    %eax,%edx
c0100fb2:	ec                   	in     (%dx),%al
c0100fb3:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fb6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fba:	0f b6 c0             	movzbl %al,%eax
c0100fbd:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc3:	a3 40 64 12 c0       	mov    %eax,0xc0126440
    crt_pos = pos;
c0100fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fcb:	0f b7 c0             	movzwl %ax,%eax
c0100fce:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
}
c0100fd4:	90                   	nop
c0100fd5:	89 ec                	mov    %ebp,%esp
c0100fd7:	5d                   	pop    %ebp
c0100fd8:	c3                   	ret    

c0100fd9 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fd9:	55                   	push   %ebp
c0100fda:	89 e5                	mov    %esp,%ebp
c0100fdc:	83 ec 48             	sub    $0x48,%esp
c0100fdf:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fe5:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe9:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fed:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100ff1:	ee                   	out    %al,(%dx)
}
c0100ff2:	90                   	nop
c0100ff3:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100ff9:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffd:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101001:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101005:	ee                   	out    %al,(%dx)
}
c0101006:	90                   	nop
c0101007:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c010100d:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101011:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101015:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101019:	ee                   	out    %al,(%dx)
}
c010101a:	90                   	nop
c010101b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101021:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101025:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101029:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010102d:	ee                   	out    %al,(%dx)
}
c010102e:	90                   	nop
c010102f:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101035:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101039:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010103d:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101041:	ee                   	out    %al,(%dx)
}
c0101042:	90                   	nop
c0101043:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101049:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010104d:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101051:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101055:	ee                   	out    %al,(%dx)
}
c0101056:	90                   	nop
c0101057:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010105d:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101061:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101065:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101069:	ee                   	out    %al,(%dx)
}
c010106a:	90                   	nop
c010106b:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101071:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101075:	89 c2                	mov    %eax,%edx
c0101077:	ec                   	in     (%dx),%al
c0101078:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010107b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010107f:	3c ff                	cmp    $0xff,%al
c0101081:	0f 95 c0             	setne  %al
c0101084:	0f b6 c0             	movzbl %al,%eax
c0101087:	a3 48 64 12 c0       	mov    %eax,0xc0126448
c010108c:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101092:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101096:	89 c2                	mov    %eax,%edx
c0101098:	ec                   	in     (%dx),%al
c0101099:	88 45 f1             	mov    %al,-0xf(%ebp)
c010109c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01010a2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a6:	89 c2                	mov    %eax,%edx
c01010a8:	ec                   	in     (%dx),%al
c01010a9:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01010ac:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c01010b1:	85 c0                	test   %eax,%eax
c01010b3:	74 0c                	je     c01010c1 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c01010b5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010bc:	e8 84 0f 00 00       	call   c0102045 <pic_enable>
    }
}
c01010c1:	90                   	nop
c01010c2:	89 ec                	mov    %ebp,%esp
c01010c4:	5d                   	pop    %ebp
c01010c5:	c3                   	ret    

c01010c6 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010c6:	55                   	push   %ebp
c01010c7:	89 e5                	mov    %esp,%ebp
c01010c9:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010d3:	eb 08                	jmp    c01010dd <lpt_putc_sub+0x17>
        delay();
c01010d5:	e8 cc fd ff ff       	call   c0100ea6 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010da:	ff 45 fc             	incl   -0x4(%ebp)
c01010dd:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010e3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010e7:	89 c2                	mov    %eax,%edx
c01010e9:	ec                   	in     (%dx),%al
c01010ea:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010ed:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010f1:	84 c0                	test   %al,%al
c01010f3:	78 09                	js     c01010fe <lpt_putc_sub+0x38>
c01010f5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010fc:	7e d7                	jle    c01010d5 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101101:	0f b6 c0             	movzbl %al,%eax
c0101104:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c010110a:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010110d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101111:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101115:	ee                   	out    %al,(%dx)
}
c0101116:	90                   	nop
c0101117:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010111d:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101121:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101125:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101129:	ee                   	out    %al,(%dx)
}
c010112a:	90                   	nop
c010112b:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101131:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101135:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101139:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010113d:	ee                   	out    %al,(%dx)
}
c010113e:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010113f:	90                   	nop
c0101140:	89 ec                	mov    %ebp,%esp
c0101142:	5d                   	pop    %ebp
c0101143:	c3                   	ret    

c0101144 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101144:	55                   	push   %ebp
c0101145:	89 e5                	mov    %esp,%ebp
c0101147:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010114a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010114e:	74 0d                	je     c010115d <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101150:	8b 45 08             	mov    0x8(%ebp),%eax
c0101153:	89 04 24             	mov    %eax,(%esp)
c0101156:	e8 6b ff ff ff       	call   c01010c6 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010115b:	eb 24                	jmp    c0101181 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010115d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101164:	e8 5d ff ff ff       	call   c01010c6 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101169:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101170:	e8 51 ff ff ff       	call   c01010c6 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101175:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010117c:	e8 45 ff ff ff       	call   c01010c6 <lpt_putc_sub>
}
c0101181:	90                   	nop
c0101182:	89 ec                	mov    %ebp,%esp
c0101184:	5d                   	pop    %ebp
c0101185:	c3                   	ret    

c0101186 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101186:	55                   	push   %ebp
c0101187:	89 e5                	mov    %esp,%ebp
c0101189:	83 ec 38             	sub    $0x38,%esp
c010118c:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c010118f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101192:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101197:	85 c0                	test   %eax,%eax
c0101199:	75 07                	jne    c01011a2 <cga_putc+0x1c>
        c |= 0x0700;
c010119b:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01011a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a5:	0f b6 c0             	movzbl %al,%eax
c01011a8:	83 f8 0d             	cmp    $0xd,%eax
c01011ab:	74 72                	je     c010121f <cga_putc+0x99>
c01011ad:	83 f8 0d             	cmp    $0xd,%eax
c01011b0:	0f 8f a3 00 00 00    	jg     c0101259 <cga_putc+0xd3>
c01011b6:	83 f8 08             	cmp    $0x8,%eax
c01011b9:	74 0a                	je     c01011c5 <cga_putc+0x3f>
c01011bb:	83 f8 0a             	cmp    $0xa,%eax
c01011be:	74 4c                	je     c010120c <cga_putc+0x86>
c01011c0:	e9 94 00 00 00       	jmp    c0101259 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c01011c5:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011cc:	85 c0                	test   %eax,%eax
c01011ce:	0f 84 af 00 00 00    	je     c0101283 <cga_putc+0xfd>
            crt_pos --;
c01011d4:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011db:	48                   	dec    %eax
c01011dc:	0f b7 c0             	movzwl %ax,%eax
c01011df:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e8:	98                   	cwtl   
c01011e9:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011ee:	98                   	cwtl   
c01011ef:	83 c8 20             	or     $0x20,%eax
c01011f2:	98                   	cwtl   
c01011f3:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c01011f9:	0f b7 15 44 64 12 c0 	movzwl 0xc0126444,%edx
c0101200:	01 d2                	add    %edx,%edx
c0101202:	01 ca                	add    %ecx,%edx
c0101204:	0f b7 c0             	movzwl %ax,%eax
c0101207:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010120a:	eb 77                	jmp    c0101283 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c010120c:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101213:	83 c0 50             	add    $0x50,%eax
c0101216:	0f b7 c0             	movzwl %ax,%eax
c0101219:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010121f:	0f b7 1d 44 64 12 c0 	movzwl 0xc0126444,%ebx
c0101226:	0f b7 0d 44 64 12 c0 	movzwl 0xc0126444,%ecx
c010122d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101232:	89 c8                	mov    %ecx,%eax
c0101234:	f7 e2                	mul    %edx
c0101236:	c1 ea 06             	shr    $0x6,%edx
c0101239:	89 d0                	mov    %edx,%eax
c010123b:	c1 e0 02             	shl    $0x2,%eax
c010123e:	01 d0                	add    %edx,%eax
c0101240:	c1 e0 04             	shl    $0x4,%eax
c0101243:	29 c1                	sub    %eax,%ecx
c0101245:	89 ca                	mov    %ecx,%edx
c0101247:	0f b7 d2             	movzwl %dx,%edx
c010124a:	89 d8                	mov    %ebx,%eax
c010124c:	29 d0                	sub    %edx,%eax
c010124e:	0f b7 c0             	movzwl %ax,%eax
c0101251:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
        break;
c0101257:	eb 2b                	jmp    c0101284 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101259:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c010125f:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101266:	8d 50 01             	lea    0x1(%eax),%edx
c0101269:	0f b7 d2             	movzwl %dx,%edx
c010126c:	66 89 15 44 64 12 c0 	mov    %dx,0xc0126444
c0101273:	01 c0                	add    %eax,%eax
c0101275:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101278:	8b 45 08             	mov    0x8(%ebp),%eax
c010127b:	0f b7 c0             	movzwl %ax,%eax
c010127e:	66 89 02             	mov    %ax,(%edx)
        break;
c0101281:	eb 01                	jmp    c0101284 <cga_putc+0xfe>
        break;
c0101283:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101284:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010128b:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101290:	76 5e                	jbe    c01012f0 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101292:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c0101297:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010129d:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c01012a2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012a9:	00 
c01012aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012ae:	89 04 24             	mov    %eax,(%esp)
c01012b1:	e8 59 7d 00 00       	call   c010900f <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012b6:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012bd:	eb 15                	jmp    c01012d4 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c01012bf:	8b 15 40 64 12 c0    	mov    0xc0126440,%edx
c01012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012c8:	01 c0                	add    %eax,%eax
c01012ca:	01 d0                	add    %edx,%eax
c01012cc:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012d1:	ff 45 f4             	incl   -0xc(%ebp)
c01012d4:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012db:	7e e2                	jle    c01012bf <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012dd:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01012e4:	83 e8 50             	sub    $0x50,%eax
c01012e7:	0f b7 c0             	movzwl %ax,%eax
c01012ea:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012f0:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c01012f7:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012fb:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012ff:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101303:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101307:	ee                   	out    %al,(%dx)
}
c0101308:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101309:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101310:	c1 e8 08             	shr    $0x8,%eax
c0101313:	0f b7 c0             	movzwl %ax,%eax
c0101316:	0f b6 c0             	movzbl %al,%eax
c0101319:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c0101320:	42                   	inc    %edx
c0101321:	0f b7 d2             	movzwl %dx,%edx
c0101324:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101328:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010132f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101333:	ee                   	out    %al,(%dx)
}
c0101334:	90                   	nop
    outb(addr_6845, 15);
c0101335:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c010133c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101340:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101344:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101348:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010134c:	ee                   	out    %al,(%dx)
}
c010134d:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010134e:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101355:	0f b6 c0             	movzbl %al,%eax
c0101358:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c010135f:	42                   	inc    %edx
c0101360:	0f b7 d2             	movzwl %dx,%edx
c0101363:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101367:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010136a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010136e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101372:	ee                   	out    %al,(%dx)
}
c0101373:	90                   	nop
}
c0101374:	90                   	nop
c0101375:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101378:	89 ec                	mov    %ebp,%esp
c010137a:	5d                   	pop    %ebp
c010137b:	c3                   	ret    

c010137c <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010137c:	55                   	push   %ebp
c010137d:	89 e5                	mov    %esp,%ebp
c010137f:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101382:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101389:	eb 08                	jmp    c0101393 <serial_putc_sub+0x17>
        delay();
c010138b:	e8 16 fb ff ff       	call   c0100ea6 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101390:	ff 45 fc             	incl   -0x4(%ebp)
c0101393:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101399:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010139d:	89 c2                	mov    %eax,%edx
c010139f:	ec                   	in     (%dx),%al
c01013a0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013a3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013a7:	0f b6 c0             	movzbl %al,%eax
c01013aa:	83 e0 20             	and    $0x20,%eax
c01013ad:	85 c0                	test   %eax,%eax
c01013af:	75 09                	jne    c01013ba <serial_putc_sub+0x3e>
c01013b1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013b8:	7e d1                	jle    c010138b <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c01013ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01013bd:	0f b6 c0             	movzbl %al,%eax
c01013c0:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013c6:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013c9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013cd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013d1:	ee                   	out    %al,(%dx)
}
c01013d2:	90                   	nop
}
c01013d3:	90                   	nop
c01013d4:	89 ec                	mov    %ebp,%esp
c01013d6:	5d                   	pop    %ebp
c01013d7:	c3                   	ret    

c01013d8 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013d8:	55                   	push   %ebp
c01013d9:	89 e5                	mov    %esp,%ebp
c01013db:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013de:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013e2:	74 0d                	je     c01013f1 <serial_putc+0x19>
        serial_putc_sub(c);
c01013e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013e7:	89 04 24             	mov    %eax,(%esp)
c01013ea:	e8 8d ff ff ff       	call   c010137c <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013ef:	eb 24                	jmp    c0101415 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013f1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013f8:	e8 7f ff ff ff       	call   c010137c <serial_putc_sub>
        serial_putc_sub(' ');
c01013fd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101404:	e8 73 ff ff ff       	call   c010137c <serial_putc_sub>
        serial_putc_sub('\b');
c0101409:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101410:	e8 67 ff ff ff       	call   c010137c <serial_putc_sub>
}
c0101415:	90                   	nop
c0101416:	89 ec                	mov    %ebp,%esp
c0101418:	5d                   	pop    %ebp
c0101419:	c3                   	ret    

c010141a <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010141a:	55                   	push   %ebp
c010141b:	89 e5                	mov    %esp,%ebp
c010141d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101420:	eb 33                	jmp    c0101455 <cons_intr+0x3b>
        if (c != 0) {
c0101422:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101426:	74 2d                	je     c0101455 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101428:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c010142d:	8d 50 01             	lea    0x1(%eax),%edx
c0101430:	89 15 64 66 12 c0    	mov    %edx,0xc0126664
c0101436:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101439:	88 90 60 64 12 c0    	mov    %dl,-0x3fed9ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010143f:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101444:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101449:	75 0a                	jne    c0101455 <cons_intr+0x3b>
                cons.wpos = 0;
c010144b:	c7 05 64 66 12 c0 00 	movl   $0x0,0xc0126664
c0101452:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101455:	8b 45 08             	mov    0x8(%ebp),%eax
c0101458:	ff d0                	call   *%eax
c010145a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010145d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101461:	75 bf                	jne    c0101422 <cons_intr+0x8>
            }
        }
    }
}
c0101463:	90                   	nop
c0101464:	90                   	nop
c0101465:	89 ec                	mov    %ebp,%esp
c0101467:	5d                   	pop    %ebp
c0101468:	c3                   	ret    

c0101469 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101469:	55                   	push   %ebp
c010146a:	89 e5                	mov    %esp,%ebp
c010146c:	83 ec 10             	sub    $0x10,%esp
c010146f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101475:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101479:	89 c2                	mov    %eax,%edx
c010147b:	ec                   	in     (%dx),%al
c010147c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010147f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101483:	0f b6 c0             	movzbl %al,%eax
c0101486:	83 e0 01             	and    $0x1,%eax
c0101489:	85 c0                	test   %eax,%eax
c010148b:	75 07                	jne    c0101494 <serial_proc_data+0x2b>
        return -1;
c010148d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101492:	eb 2a                	jmp    c01014be <serial_proc_data+0x55>
c0101494:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010149a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010149e:	89 c2                	mov    %eax,%edx
c01014a0:	ec                   	in     (%dx),%al
c01014a1:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014a4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014a8:	0f b6 c0             	movzbl %al,%eax
c01014ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014ae:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014b2:	75 07                	jne    c01014bb <serial_proc_data+0x52>
        c = '\b';
c01014b4:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014be:	89 ec                	mov    %ebp,%esp
c01014c0:	5d                   	pop    %ebp
c01014c1:	c3                   	ret    

c01014c2 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014c2:	55                   	push   %ebp
c01014c3:	89 e5                	mov    %esp,%ebp
c01014c5:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014c8:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c01014cd:	85 c0                	test   %eax,%eax
c01014cf:	74 0c                	je     c01014dd <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014d1:	c7 04 24 69 14 10 c0 	movl   $0xc0101469,(%esp)
c01014d8:	e8 3d ff ff ff       	call   c010141a <cons_intr>
    }
}
c01014dd:	90                   	nop
c01014de:	89 ec                	mov    %ebp,%esp
c01014e0:	5d                   	pop    %ebp
c01014e1:	c3                   	ret    

c01014e2 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014e2:	55                   	push   %ebp
c01014e3:	89 e5                	mov    %esp,%ebp
c01014e5:	83 ec 38             	sub    $0x38,%esp
c01014e8:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014f1:	89 c2                	mov    %eax,%edx
c01014f3:	ec                   	in     (%dx),%al
c01014f4:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014fb:	0f b6 c0             	movzbl %al,%eax
c01014fe:	83 e0 01             	and    $0x1,%eax
c0101501:	85 c0                	test   %eax,%eax
c0101503:	75 0a                	jne    c010150f <kbd_proc_data+0x2d>
        return -1;
c0101505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010150a:	e9 56 01 00 00       	jmp    c0101665 <kbd_proc_data+0x183>
c010150f:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101515:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101518:	89 c2                	mov    %eax,%edx
c010151a:	ec                   	in     (%dx),%al
c010151b:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010151e:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101522:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101525:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101529:	75 17                	jne    c0101542 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010152b:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101530:	83 c8 40             	or     $0x40,%eax
c0101533:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c0101538:	b8 00 00 00 00       	mov    $0x0,%eax
c010153d:	e9 23 01 00 00       	jmp    c0101665 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101542:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101546:	84 c0                	test   %al,%al
c0101548:	79 45                	jns    c010158f <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010154a:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c010154f:	83 e0 40             	and    $0x40,%eax
c0101552:	85 c0                	test   %eax,%eax
c0101554:	75 08                	jne    c010155e <kbd_proc_data+0x7c>
c0101556:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155a:	24 7f                	and    $0x7f,%al
c010155c:	eb 04                	jmp    c0101562 <kbd_proc_data+0x80>
c010155e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101562:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101565:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101569:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c0101570:	0c 40                	or     $0x40,%al
c0101572:	0f b6 c0             	movzbl %al,%eax
c0101575:	f7 d0                	not    %eax
c0101577:	89 c2                	mov    %eax,%edx
c0101579:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c010157e:	21 d0                	and    %edx,%eax
c0101580:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c0101585:	b8 00 00 00 00       	mov    $0x0,%eax
c010158a:	e9 d6 00 00 00       	jmp    c0101665 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c010158f:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101594:	83 e0 40             	and    $0x40,%eax
c0101597:	85 c0                	test   %eax,%eax
c0101599:	74 11                	je     c01015ac <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010159b:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010159f:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015a4:	83 e0 bf             	and    $0xffffffbf,%eax
c01015a7:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    }

    shift |= shiftcode[data];
c01015ac:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b0:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c01015b7:	0f b6 d0             	movzbl %al,%edx
c01015ba:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015bf:	09 d0                	or     %edx,%eax
c01015c1:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    shift ^= togglecode[data];
c01015c6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ca:	0f b6 80 40 31 12 c0 	movzbl -0x3fedcec0(%eax),%eax
c01015d1:	0f b6 d0             	movzbl %al,%edx
c01015d4:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015d9:	31 d0                	xor    %edx,%eax
c01015db:	a3 68 66 12 c0       	mov    %eax,0xc0126668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015e0:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015e5:	83 e0 03             	and    $0x3,%eax
c01015e8:	8b 14 85 40 35 12 c0 	mov    -0x3fedcac0(,%eax,4),%edx
c01015ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015f3:	01 d0                	add    %edx,%eax
c01015f5:	0f b6 00             	movzbl (%eax),%eax
c01015f8:	0f b6 c0             	movzbl %al,%eax
c01015fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015fe:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101603:	83 e0 08             	and    $0x8,%eax
c0101606:	85 c0                	test   %eax,%eax
c0101608:	74 22                	je     c010162c <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010160a:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010160e:	7e 0c                	jle    c010161c <kbd_proc_data+0x13a>
c0101610:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101614:	7f 06                	jg     c010161c <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101616:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010161a:	eb 10                	jmp    c010162c <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c010161c:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101620:	7e 0a                	jle    c010162c <kbd_proc_data+0x14a>
c0101622:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101626:	7f 04                	jg     c010162c <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101628:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010162c:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101631:	f7 d0                	not    %eax
c0101633:	83 e0 06             	and    $0x6,%eax
c0101636:	85 c0                	test   %eax,%eax
c0101638:	75 28                	jne    c0101662 <kbd_proc_data+0x180>
c010163a:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101641:	75 1f                	jne    c0101662 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101643:	c7 04 24 8f 94 10 c0 	movl   $0xc010948f,(%esp)
c010164a:	e8 56 ed ff ff       	call   c01003a5 <cprintf>
c010164f:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101655:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101659:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010165d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101660:	ee                   	out    %al,(%dx)
}
c0101661:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101662:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101665:	89 ec                	mov    %ebp,%esp
c0101667:	5d                   	pop    %ebp
c0101668:	c3                   	ret    

c0101669 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101669:	55                   	push   %ebp
c010166a:	89 e5                	mov    %esp,%ebp
c010166c:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010166f:	c7 04 24 e2 14 10 c0 	movl   $0xc01014e2,(%esp)
c0101676:	e8 9f fd ff ff       	call   c010141a <cons_intr>
}
c010167b:	90                   	nop
c010167c:	89 ec                	mov    %ebp,%esp
c010167e:	5d                   	pop    %ebp
c010167f:	c3                   	ret    

c0101680 <kbd_init>:

static void
kbd_init(void) {
c0101680:	55                   	push   %ebp
c0101681:	89 e5                	mov    %esp,%ebp
c0101683:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101686:	e8 de ff ff ff       	call   c0101669 <kbd_intr>
    pic_enable(IRQ_KBD);
c010168b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101692:	e8 ae 09 00 00       	call   c0102045 <pic_enable>
}
c0101697:	90                   	nop
c0101698:	89 ec                	mov    %ebp,%esp
c010169a:	5d                   	pop    %ebp
c010169b:	c3                   	ret    

c010169c <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010169c:	55                   	push   %ebp
c010169d:	89 e5                	mov    %esp,%ebp
c010169f:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016a2:	e8 4a f8 ff ff       	call   c0100ef1 <cga_init>
    serial_init();
c01016a7:	e8 2d f9 ff ff       	call   c0100fd9 <serial_init>
    kbd_init();
c01016ac:	e8 cf ff ff ff       	call   c0101680 <kbd_init>
    if (!serial_exists) {
c01016b1:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c01016b6:	85 c0                	test   %eax,%eax
c01016b8:	75 0c                	jne    c01016c6 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016ba:	c7 04 24 9b 94 10 c0 	movl   $0xc010949b,(%esp)
c01016c1:	e8 df ec ff ff       	call   c01003a5 <cprintf>
    }
}
c01016c6:	90                   	nop
c01016c7:	89 ec                	mov    %ebp,%esp
c01016c9:	5d                   	pop    %ebp
c01016ca:	c3                   	ret    

c01016cb <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016cb:	55                   	push   %ebp
c01016cc:	89 e5                	mov    %esp,%ebp
c01016ce:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016d1:	e8 8e f7 ff ff       	call   c0100e64 <__intr_save>
c01016d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01016dc:	89 04 24             	mov    %eax,(%esp)
c01016df:	e8 60 fa ff ff       	call   c0101144 <lpt_putc>
        cga_putc(c);
c01016e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e7:	89 04 24             	mov    %eax,(%esp)
c01016ea:	e8 97 fa ff ff       	call   c0101186 <cga_putc>
        serial_putc(c);
c01016ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01016f2:	89 04 24             	mov    %eax,(%esp)
c01016f5:	e8 de fc ff ff       	call   c01013d8 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016fd:	89 04 24             	mov    %eax,(%esp)
c0101700:	e8 8b f7 ff ff       	call   c0100e90 <__intr_restore>
}
c0101705:	90                   	nop
c0101706:	89 ec                	mov    %ebp,%esp
c0101708:	5d                   	pop    %ebp
c0101709:	c3                   	ret    

c010170a <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010170a:	55                   	push   %ebp
c010170b:	89 e5                	mov    %esp,%ebp
c010170d:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101710:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101717:	e8 48 f7 ff ff       	call   c0100e64 <__intr_save>
c010171c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010171f:	e8 9e fd ff ff       	call   c01014c2 <serial_intr>
        kbd_intr();
c0101724:	e8 40 ff ff ff       	call   c0101669 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101729:	8b 15 60 66 12 c0    	mov    0xc0126660,%edx
c010172f:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101734:	39 c2                	cmp    %eax,%edx
c0101736:	74 31                	je     c0101769 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101738:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c010173d:	8d 50 01             	lea    0x1(%eax),%edx
c0101740:	89 15 60 66 12 c0    	mov    %edx,0xc0126660
c0101746:	0f b6 80 60 64 12 c0 	movzbl -0x3fed9ba0(%eax),%eax
c010174d:	0f b6 c0             	movzbl %al,%eax
c0101750:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101753:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c0101758:	3d 00 02 00 00       	cmp    $0x200,%eax
c010175d:	75 0a                	jne    c0101769 <cons_getc+0x5f>
                cons.rpos = 0;
c010175f:	c7 05 60 66 12 c0 00 	movl   $0x0,0xc0126660
c0101766:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010176c:	89 04 24             	mov    %eax,(%esp)
c010176f:	e8 1c f7 ff ff       	call   c0100e90 <__intr_restore>
    return c;
c0101774:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101777:	89 ec                	mov    %ebp,%esp
c0101779:	5d                   	pop    %ebp
c010177a:	c3                   	ret    

c010177b <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c010177b:	55                   	push   %ebp
c010177c:	89 e5                	mov    %esp,%ebp
c010177e:	83 ec 14             	sub    $0x14,%esp
c0101781:	8b 45 08             	mov    0x8(%ebp),%eax
c0101784:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101788:	90                   	nop
c0101789:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010178c:	83 c0 07             	add    $0x7,%eax
c010178f:	0f b7 c0             	movzwl %ax,%eax
c0101792:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101796:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010179a:	89 c2                	mov    %eax,%edx
c010179c:	ec                   	in     (%dx),%al
c010179d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01017a0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017a4:	0f b6 c0             	movzbl %al,%eax
c01017a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01017aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ad:	25 80 00 00 00       	and    $0x80,%eax
c01017b2:	85 c0                	test   %eax,%eax
c01017b4:	75 d3                	jne    c0101789 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01017ba:	74 11                	je     c01017cd <ide_wait_ready+0x52>
c01017bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017bf:	83 e0 21             	and    $0x21,%eax
c01017c2:	85 c0                	test   %eax,%eax
c01017c4:	74 07                	je     c01017cd <ide_wait_ready+0x52>
        return -1;
c01017c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01017cb:	eb 05                	jmp    c01017d2 <ide_wait_ready+0x57>
    }
    return 0;
c01017cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017d2:	89 ec                	mov    %ebp,%esp
c01017d4:	5d                   	pop    %ebp
c01017d5:	c3                   	ret    

c01017d6 <ide_init>:

void
ide_init(void) {
c01017d6:	55                   	push   %ebp
c01017d7:	89 e5                	mov    %esp,%ebp
c01017d9:	57                   	push   %edi
c01017da:	53                   	push   %ebx
c01017db:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01017e1:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01017e7:	e9 bd 02 00 00       	jmp    c0101aa9 <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01017ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017f0:	89 d0                	mov    %edx,%eax
c01017f2:	c1 e0 03             	shl    $0x3,%eax
c01017f5:	29 d0                	sub    %edx,%eax
c01017f7:	c1 e0 03             	shl    $0x3,%eax
c01017fa:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01017ff:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101802:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101806:	d1 e8                	shr    %eax
c0101808:	0f b7 c0             	movzwl %ax,%eax
c010180b:	8b 04 85 bc 94 10 c0 	mov    -0x3fef6b44(,%eax,4),%eax
c0101812:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101816:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010181a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101821:	00 
c0101822:	89 04 24             	mov    %eax,(%esp)
c0101825:	e8 51 ff ff ff       	call   c010177b <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c010182a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010182e:	c1 e0 04             	shl    $0x4,%eax
c0101831:	24 10                	and    $0x10,%al
c0101833:	0c e0                	or     $0xe0,%al
c0101835:	0f b6 c0             	movzbl %al,%eax
c0101838:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010183c:	83 c2 06             	add    $0x6,%edx
c010183f:	0f b7 d2             	movzwl %dx,%edx
c0101842:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101846:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101849:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010184d:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101851:	ee                   	out    %al,(%dx)
}
c0101852:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101853:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101857:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010185e:	00 
c010185f:	89 04 24             	mov    %eax,(%esp)
c0101862:	e8 14 ff ff ff       	call   c010177b <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0101867:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010186b:	83 c0 07             	add    $0x7,%eax
c010186e:	0f b7 c0             	movzwl %ax,%eax
c0101871:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101875:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101879:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010187d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101881:	ee                   	out    %al,(%dx)
}
c0101882:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101883:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101887:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010188e:	00 
c010188f:	89 04 24             	mov    %eax,(%esp)
c0101892:	e8 e4 fe ff ff       	call   c010177b <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101897:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010189b:	83 c0 07             	add    $0x7,%eax
c010189e:	0f b7 c0             	movzwl %ax,%eax
c01018a1:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018a5:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01018a9:	89 c2                	mov    %eax,%edx
c01018ab:	ec                   	in     (%dx),%al
c01018ac:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c01018af:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018b3:	84 c0                	test   %al,%al
c01018b5:	0f 84 e4 01 00 00    	je     c0101a9f <ide_init+0x2c9>
c01018bb:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01018c6:	00 
c01018c7:	89 04 24             	mov    %eax,(%esp)
c01018ca:	e8 ac fe ff ff       	call   c010177b <ide_wait_ready>
c01018cf:	85 c0                	test   %eax,%eax
c01018d1:	0f 85 c8 01 00 00    	jne    c0101a9f <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c01018d7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018db:	89 d0                	mov    %edx,%eax
c01018dd:	c1 e0 03             	shl    $0x3,%eax
c01018e0:	29 d0                	sub    %edx,%eax
c01018e2:	c1 e0 03             	shl    $0x3,%eax
c01018e5:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01018ea:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01018ed:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01018f4:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018fa:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01018fd:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0101904:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101907:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010190a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010190d:	89 cb                	mov    %ecx,%ebx
c010190f:	89 df                	mov    %ebx,%edi
c0101911:	89 c1                	mov    %eax,%ecx
c0101913:	fc                   	cld    
c0101914:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101916:	89 c8                	mov    %ecx,%eax
c0101918:	89 fb                	mov    %edi,%ebx
c010191a:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010191d:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0101920:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c0101921:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101927:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010192a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010192d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101933:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101936:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101939:	25 00 00 00 04       	and    $0x4000000,%eax
c010193e:	85 c0                	test   %eax,%eax
c0101940:	74 0e                	je     c0101950 <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101945:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c010194b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010194e:	eb 09                	jmp    c0101959 <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101950:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101953:	8b 40 78             	mov    0x78(%eax),%eax
c0101956:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101959:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010195d:	89 d0                	mov    %edx,%eax
c010195f:	c1 e0 03             	shl    $0x3,%eax
c0101962:	29 d0                	sub    %edx,%eax
c0101964:	c1 e0 03             	shl    $0x3,%eax
c0101967:	8d 90 84 66 12 c0    	lea    -0x3fed997c(%eax),%edx
c010196d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101970:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101972:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101976:	89 d0                	mov    %edx,%eax
c0101978:	c1 e0 03             	shl    $0x3,%eax
c010197b:	29 d0                	sub    %edx,%eax
c010197d:	c1 e0 03             	shl    $0x3,%eax
c0101980:	8d 90 88 66 12 c0    	lea    -0x3fed9978(%eax),%edx
c0101986:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101989:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010198b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010198e:	83 c0 62             	add    $0x62,%eax
c0101991:	0f b7 00             	movzwl (%eax),%eax
c0101994:	25 00 02 00 00       	and    $0x200,%eax
c0101999:	85 c0                	test   %eax,%eax
c010199b:	75 24                	jne    c01019c1 <ide_init+0x1eb>
c010199d:	c7 44 24 0c c4 94 10 	movl   $0xc01094c4,0xc(%esp)
c01019a4:	c0 
c01019a5:	c7 44 24 08 07 95 10 	movl   $0xc0109507,0x8(%esp)
c01019ac:	c0 
c01019ad:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01019b4:	00 
c01019b5:	c7 04 24 1c 95 10 c0 	movl   $0xc010951c,(%esp)
c01019bc:	e8 69 f3 ff ff       	call   c0100d2a <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01019c1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019c5:	89 d0                	mov    %edx,%eax
c01019c7:	c1 e0 03             	shl    $0x3,%eax
c01019ca:	29 d0                	sub    %edx,%eax
c01019cc:	c1 e0 03             	shl    $0x3,%eax
c01019cf:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01019d4:	83 c0 0c             	add    $0xc,%eax
c01019d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01019da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019dd:	83 c0 36             	add    $0x36,%eax
c01019e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019e3:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019f1:	eb 34                	jmp    c0101a27 <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019f6:	8d 50 01             	lea    0x1(%eax),%edx
c01019f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01019fc:	01 c2                	add    %eax,%edx
c01019fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a04:	01 c8                	add    %ecx,%eax
c0101a06:	0f b6 12             	movzbl (%edx),%edx
c0101a09:	88 10                	mov    %dl,(%eax)
c0101a0b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101a0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a11:	01 c2                	add    %eax,%edx
c0101a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a16:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a19:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a1c:	01 c8                	add    %ecx,%eax
c0101a1e:	0f b6 12             	movzbl (%edx),%edx
c0101a21:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101a23:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a2a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a2d:	72 c4                	jb     c01019f3 <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101a2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a35:	01 d0                	add    %edx,%eax
c0101a37:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a3d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a40:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a43:	85 c0                	test   %eax,%eax
c0101a45:	74 0f                	je     c0101a56 <ide_init+0x280>
c0101a47:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a4d:	01 d0                	add    %edx,%eax
c0101a4f:	0f b6 00             	movzbl (%eax),%eax
c0101a52:	3c 20                	cmp    $0x20,%al
c0101a54:	74 d9                	je     c0101a2f <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a56:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a5a:	89 d0                	mov    %edx,%eax
c0101a5c:	c1 e0 03             	shl    $0x3,%eax
c0101a5f:	29 d0                	sub    %edx,%eax
c0101a61:	c1 e0 03             	shl    $0x3,%eax
c0101a64:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101a69:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a6c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a70:	89 d0                	mov    %edx,%eax
c0101a72:	c1 e0 03             	shl    $0x3,%eax
c0101a75:	29 d0                	sub    %edx,%eax
c0101a77:	c1 e0 03             	shl    $0x3,%eax
c0101a7a:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101a7f:	8b 10                	mov    (%eax),%edx
c0101a81:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a85:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a89:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a91:	c7 04 24 2e 95 10 c0 	movl   $0xc010952e,(%esp)
c0101a98:	e8 08 e9 ff ff       	call   c01003a5 <cprintf>
c0101a9d:	eb 01                	jmp    c0101aa0 <ide_init+0x2ca>
            continue ;
c0101a9f:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101aa0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aa4:	40                   	inc    %eax
c0101aa5:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101aa9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aad:	83 f8 03             	cmp    $0x3,%eax
c0101ab0:	0f 86 36 fd ff ff    	jbe    c01017ec <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101ab6:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101abd:	e8 83 05 00 00       	call   c0102045 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101ac2:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101ac9:	e8 77 05 00 00       	call   c0102045 <pic_enable>
}
c0101ace:	90                   	nop
c0101acf:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101ad5:	5b                   	pop    %ebx
c0101ad6:	5f                   	pop    %edi
c0101ad7:	5d                   	pop    %ebp
c0101ad8:	c3                   	ret    

c0101ad9 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101ad9:	55                   	push   %ebp
c0101ada:	89 e5                	mov    %esp,%ebp
c0101adc:	83 ec 04             	sub    $0x4,%esp
c0101adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101ae6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aea:	83 f8 03             	cmp    $0x3,%eax
c0101aed:	77 21                	ja     c0101b10 <ide_device_valid+0x37>
c0101aef:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101af3:	89 d0                	mov    %edx,%eax
c0101af5:	c1 e0 03             	shl    $0x3,%eax
c0101af8:	29 d0                	sub    %edx,%eax
c0101afa:	c1 e0 03             	shl    $0x3,%eax
c0101afd:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101b02:	0f b6 00             	movzbl (%eax),%eax
c0101b05:	84 c0                	test   %al,%al
c0101b07:	74 07                	je     c0101b10 <ide_device_valid+0x37>
c0101b09:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b0e:	eb 05                	jmp    c0101b15 <ide_device_valid+0x3c>
c0101b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b15:	89 ec                	mov    %ebp,%esp
c0101b17:	5d                   	pop    %ebp
c0101b18:	c3                   	ret    

c0101b19 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b19:	55                   	push   %ebp
c0101b1a:	89 e5                	mov    %esp,%ebp
c0101b1c:	83 ec 08             	sub    $0x8,%esp
c0101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b22:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b26:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b2a:	89 04 24             	mov    %eax,(%esp)
c0101b2d:	e8 a7 ff ff ff       	call   c0101ad9 <ide_device_valid>
c0101b32:	85 c0                	test   %eax,%eax
c0101b34:	74 17                	je     c0101b4d <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101b36:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101b3a:	89 d0                	mov    %edx,%eax
c0101b3c:	c1 e0 03             	shl    $0x3,%eax
c0101b3f:	29 d0                	sub    %edx,%eax
c0101b41:	c1 e0 03             	shl    $0x3,%eax
c0101b44:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101b49:	8b 00                	mov    (%eax),%eax
c0101b4b:	eb 05                	jmp    c0101b52 <ide_device_size+0x39>
    }
    return 0;
c0101b4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b52:	89 ec                	mov    %ebp,%esp
c0101b54:	5d                   	pop    %ebp
c0101b55:	c3                   	ret    

c0101b56 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b56:	55                   	push   %ebp
c0101b57:	89 e5                	mov    %esp,%ebp
c0101b59:	57                   	push   %edi
c0101b5a:	53                   	push   %ebx
c0101b5b:	83 ec 50             	sub    $0x50,%esp
c0101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b61:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b65:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b6c:	77 23                	ja     c0101b91 <ide_read_secs+0x3b>
c0101b6e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b72:	83 f8 03             	cmp    $0x3,%eax
c0101b75:	77 1a                	ja     c0101b91 <ide_read_secs+0x3b>
c0101b77:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101b7b:	89 d0                	mov    %edx,%eax
c0101b7d:	c1 e0 03             	shl    $0x3,%eax
c0101b80:	29 d0                	sub    %edx,%eax
c0101b82:	c1 e0 03             	shl    $0x3,%eax
c0101b85:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101b8a:	0f b6 00             	movzbl (%eax),%eax
c0101b8d:	84 c0                	test   %al,%al
c0101b8f:	75 24                	jne    c0101bb5 <ide_read_secs+0x5f>
c0101b91:	c7 44 24 0c 4c 95 10 	movl   $0xc010954c,0xc(%esp)
c0101b98:	c0 
c0101b99:	c7 44 24 08 07 95 10 	movl   $0xc0109507,0x8(%esp)
c0101ba0:	c0 
c0101ba1:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101ba8:	00 
c0101ba9:	c7 04 24 1c 95 10 c0 	movl   $0xc010951c,(%esp)
c0101bb0:	e8 75 f1 ff ff       	call   c0100d2a <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101bb5:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101bbc:	77 0f                	ja     c0101bcd <ide_read_secs+0x77>
c0101bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bc1:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bc4:	01 d0                	add    %edx,%eax
c0101bc6:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101bcb:	76 24                	jbe    c0101bf1 <ide_read_secs+0x9b>
c0101bcd:	c7 44 24 0c 74 95 10 	movl   $0xc0109574,0xc(%esp)
c0101bd4:	c0 
c0101bd5:	c7 44 24 08 07 95 10 	movl   $0xc0109507,0x8(%esp)
c0101bdc:	c0 
c0101bdd:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101be4:	00 
c0101be5:	c7 04 24 1c 95 10 c0 	movl   $0xc010951c,(%esp)
c0101bec:	e8 39 f1 ff ff       	call   c0100d2a <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bf1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bf5:	d1 e8                	shr    %eax
c0101bf7:	0f b7 c0             	movzwl %ax,%eax
c0101bfa:	8b 04 85 bc 94 10 c0 	mov    -0x3fef6b44(,%eax,4),%eax
c0101c01:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c05:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c09:	d1 e8                	shr    %eax
c0101c0b:	0f b7 c0             	movzwl %ax,%eax
c0101c0e:	0f b7 04 85 be 94 10 	movzwl -0x3fef6b42(,%eax,4),%eax
c0101c15:	c0 
c0101c16:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c1a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c25:	00 
c0101c26:	89 04 24             	mov    %eax,(%esp)
c0101c29:	e8 4d fb ff ff       	call   c010177b <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c31:	83 c0 02             	add    $0x2,%eax
c0101c34:	0f b7 c0             	movzwl %ax,%eax
c0101c37:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c3b:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c3f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c43:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c47:	ee                   	out    %al,(%dx)
}
c0101c48:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c49:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c4c:	0f b6 c0             	movzbl %al,%eax
c0101c4f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c53:	83 c2 02             	add    $0x2,%edx
c0101c56:	0f b7 d2             	movzwl %dx,%edx
c0101c59:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c5d:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c60:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c64:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c68:	ee                   	out    %al,(%dx)
}
c0101c69:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c6d:	0f b6 c0             	movzbl %al,%eax
c0101c70:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c74:	83 c2 03             	add    $0x3,%edx
c0101c77:	0f b7 d2             	movzwl %dx,%edx
c0101c7a:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c7e:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c81:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c85:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c89:	ee                   	out    %al,(%dx)
}
c0101c8a:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c8e:	c1 e8 08             	shr    $0x8,%eax
c0101c91:	0f b6 c0             	movzbl %al,%eax
c0101c94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c98:	83 c2 04             	add    $0x4,%edx
c0101c9b:	0f b7 d2             	movzwl %dx,%edx
c0101c9e:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101ca2:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ca5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ca9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101cad:	ee                   	out    %al,(%dx)
}
c0101cae:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101caf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cb2:	c1 e8 10             	shr    $0x10,%eax
c0101cb5:	0f b6 c0             	movzbl %al,%eax
c0101cb8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cbc:	83 c2 05             	add    $0x5,%edx
c0101cbf:	0f b7 d2             	movzwl %dx,%edx
c0101cc2:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cc6:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101ccd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101cd1:	ee                   	out    %al,(%dx)
}
c0101cd2:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101cd3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101cd6:	c0 e0 04             	shl    $0x4,%al
c0101cd9:	24 10                	and    $0x10,%al
c0101cdb:	88 c2                	mov    %al,%dl
c0101cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ce0:	c1 e8 18             	shr    $0x18,%eax
c0101ce3:	24 0f                	and    $0xf,%al
c0101ce5:	08 d0                	or     %dl,%al
c0101ce7:	0c e0                	or     $0xe0,%al
c0101ce9:	0f b6 c0             	movzbl %al,%eax
c0101cec:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cf0:	83 c2 06             	add    $0x6,%edx
c0101cf3:	0f b7 d2             	movzwl %dx,%edx
c0101cf6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cfa:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cfd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101d01:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101d05:	ee                   	out    %al,(%dx)
}
c0101d06:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d07:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d0b:	83 c0 07             	add    $0x7,%eax
c0101d0e:	0f b7 c0             	movzwl %ax,%eax
c0101d11:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101d15:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d19:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101d1d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d21:	ee                   	out    %al,(%dx)
}
c0101d22:	90                   	nop

    int ret = 0;
c0101d23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d2a:	eb 58                	jmp    c0101d84 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d2c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d30:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d37:	00 
c0101d38:	89 04 24             	mov    %eax,(%esp)
c0101d3b:	e8 3b fa ff ff       	call   c010177b <ide_wait_ready>
c0101d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d47:	75 43                	jne    c0101d8c <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d49:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d50:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d53:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d56:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d5d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d60:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d63:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d66:	89 cb                	mov    %ecx,%ebx
c0101d68:	89 df                	mov    %ebx,%edi
c0101d6a:	89 c1                	mov    %eax,%ecx
c0101d6c:	fc                   	cld    
c0101d6d:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d6f:	89 c8                	mov    %ecx,%eax
c0101d71:	89 fb                	mov    %edi,%ebx
c0101d73:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d76:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d79:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d7a:	ff 4d 14             	decl   0x14(%ebp)
c0101d7d:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d84:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d88:	75 a2                	jne    c0101d2c <ide_read_secs+0x1d6>
    }

out:
c0101d8a:	eb 01                	jmp    c0101d8d <ide_read_secs+0x237>
            goto out;
c0101d8c:	90                   	nop
    return ret;
c0101d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d90:	83 c4 50             	add    $0x50,%esp
c0101d93:	5b                   	pop    %ebx
c0101d94:	5f                   	pop    %edi
c0101d95:	5d                   	pop    %ebp
c0101d96:	c3                   	ret    

c0101d97 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d97:	55                   	push   %ebp
c0101d98:	89 e5                	mov    %esp,%ebp
c0101d9a:	56                   	push   %esi
c0101d9b:	53                   	push   %ebx
c0101d9c:	83 ec 50             	sub    $0x50,%esp
c0101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da2:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101da6:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101dad:	77 23                	ja     c0101dd2 <ide_write_secs+0x3b>
c0101daf:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101db3:	83 f8 03             	cmp    $0x3,%eax
c0101db6:	77 1a                	ja     c0101dd2 <ide_write_secs+0x3b>
c0101db8:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101dbc:	89 d0                	mov    %edx,%eax
c0101dbe:	c1 e0 03             	shl    $0x3,%eax
c0101dc1:	29 d0                	sub    %edx,%eax
c0101dc3:	c1 e0 03             	shl    $0x3,%eax
c0101dc6:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101dcb:	0f b6 00             	movzbl (%eax),%eax
c0101dce:	84 c0                	test   %al,%al
c0101dd0:	75 24                	jne    c0101df6 <ide_write_secs+0x5f>
c0101dd2:	c7 44 24 0c 4c 95 10 	movl   $0xc010954c,0xc(%esp)
c0101dd9:	c0 
c0101dda:	c7 44 24 08 07 95 10 	movl   $0xc0109507,0x8(%esp)
c0101de1:	c0 
c0101de2:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101de9:	00 
c0101dea:	c7 04 24 1c 95 10 c0 	movl   $0xc010951c,(%esp)
c0101df1:	e8 34 ef ff ff       	call   c0100d2a <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101df6:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101dfd:	77 0f                	ja     c0101e0e <ide_write_secs+0x77>
c0101dff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e02:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e05:	01 d0                	add    %edx,%eax
c0101e07:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e0c:	76 24                	jbe    c0101e32 <ide_write_secs+0x9b>
c0101e0e:	c7 44 24 0c 74 95 10 	movl   $0xc0109574,0xc(%esp)
c0101e15:	c0 
c0101e16:	c7 44 24 08 07 95 10 	movl   $0xc0109507,0x8(%esp)
c0101e1d:	c0 
c0101e1e:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e25:	00 
c0101e26:	c7 04 24 1c 95 10 c0 	movl   $0xc010951c,(%esp)
c0101e2d:	e8 f8 ee ff ff       	call   c0100d2a <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e32:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e36:	d1 e8                	shr    %eax
c0101e38:	0f b7 c0             	movzwl %ax,%eax
c0101e3b:	8b 04 85 bc 94 10 c0 	mov    -0x3fef6b44(,%eax,4),%eax
c0101e42:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e46:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e4a:	d1 e8                	shr    %eax
c0101e4c:	0f b7 c0             	movzwl %ax,%eax
c0101e4f:	0f b7 04 85 be 94 10 	movzwl -0x3fef6b42(,%eax,4),%eax
c0101e56:	c0 
c0101e57:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e5b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101e66:	00 
c0101e67:	89 04 24             	mov    %eax,(%esp)
c0101e6a:	e8 0c f9 ff ff       	call   c010177b <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e72:	83 c0 02             	add    $0x2,%eax
c0101e75:	0f b7 c0             	movzwl %ax,%eax
c0101e78:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e7c:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e80:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e84:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e88:	ee                   	out    %al,(%dx)
}
c0101e89:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e8a:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e8d:	0f b6 c0             	movzbl %al,%eax
c0101e90:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e94:	83 c2 02             	add    $0x2,%edx
c0101e97:	0f b7 d2             	movzwl %dx,%edx
c0101e9a:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e9e:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ea1:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101ea5:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101ea9:	ee                   	out    %al,(%dx)
}
c0101eaa:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101eab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eae:	0f b6 c0             	movzbl %al,%eax
c0101eb1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101eb5:	83 c2 03             	add    $0x3,%edx
c0101eb8:	0f b7 d2             	movzwl %dx,%edx
c0101ebb:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101ebf:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ec2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101ec6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101eca:	ee                   	out    %al,(%dx)
}
c0101ecb:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ecf:	c1 e8 08             	shr    $0x8,%eax
c0101ed2:	0f b6 c0             	movzbl %al,%eax
c0101ed5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ed9:	83 c2 04             	add    $0x4,%edx
c0101edc:	0f b7 d2             	movzwl %dx,%edx
c0101edf:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101ee3:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ee6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101eea:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101eee:	ee                   	out    %al,(%dx)
}
c0101eef:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ef3:	c1 e8 10             	shr    $0x10,%eax
c0101ef6:	0f b6 c0             	movzbl %al,%eax
c0101ef9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101efd:	83 c2 05             	add    $0x5,%edx
c0101f00:	0f b7 d2             	movzwl %dx,%edx
c0101f03:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f07:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f0a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f0e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f12:	ee                   	out    %al,(%dx)
}
c0101f13:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f14:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101f17:	c0 e0 04             	shl    $0x4,%al
c0101f1a:	24 10                	and    $0x10,%al
c0101f1c:	88 c2                	mov    %al,%dl
c0101f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f21:	c1 e8 18             	shr    $0x18,%eax
c0101f24:	24 0f                	and    $0xf,%al
c0101f26:	08 d0                	or     %dl,%al
c0101f28:	0c e0                	or     $0xe0,%al
c0101f2a:	0f b6 c0             	movzbl %al,%eax
c0101f2d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f31:	83 c2 06             	add    $0x6,%edx
c0101f34:	0f b7 d2             	movzwl %dx,%edx
c0101f37:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f3b:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f3e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f42:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f46:	ee                   	out    %al,(%dx)
}
c0101f47:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f48:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f4c:	83 c0 07             	add    $0x7,%eax
c0101f4f:	0f b7 c0             	movzwl %ax,%eax
c0101f52:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f56:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f5a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f5e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f62:	ee                   	out    %al,(%dx)
}
c0101f63:	90                   	nop

    int ret = 0;
c0101f64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f6b:	eb 58                	jmp    c0101fc5 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f6d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101f78:	00 
c0101f79:	89 04 24             	mov    %eax,(%esp)
c0101f7c:	e8 fa f7 ff ff       	call   c010177b <ide_wait_ready>
c0101f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f88:	75 43                	jne    c0101fcd <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f8a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f91:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f94:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f97:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f9e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101fa1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101fa4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101fa7:	89 cb                	mov    %ecx,%ebx
c0101fa9:	89 de                	mov    %ebx,%esi
c0101fab:	89 c1                	mov    %eax,%ecx
c0101fad:	fc                   	cld    
c0101fae:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101fb0:	89 c8                	mov    %ecx,%eax
c0101fb2:	89 f3                	mov    %esi,%ebx
c0101fb4:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101fb7:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101fba:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fbb:	ff 4d 14             	decl   0x14(%ebp)
c0101fbe:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101fc5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101fc9:	75 a2                	jne    c0101f6d <ide_write_secs+0x1d6>
    }

out:
c0101fcb:	eb 01                	jmp    c0101fce <ide_write_secs+0x237>
            goto out;
c0101fcd:	90                   	nop
    return ret;
c0101fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fd1:	83 c4 50             	add    $0x50,%esp
c0101fd4:	5b                   	pop    %ebx
c0101fd5:	5e                   	pop    %esi
c0101fd6:	5d                   	pop    %ebp
c0101fd7:	c3                   	ret    

c0101fd8 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101fd8:	55                   	push   %ebp
c0101fd9:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101fdb:	fb                   	sti    
}
c0101fdc:	90                   	nop
    sti();
}
c0101fdd:	90                   	nop
c0101fde:	5d                   	pop    %ebp
c0101fdf:	c3                   	ret    

c0101fe0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101fe0:	55                   	push   %ebp
c0101fe1:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101fe3:	fa                   	cli    
}
c0101fe4:	90                   	nop
    cli();
}
c0101fe5:	90                   	nop
c0101fe6:	5d                   	pop    %ebp
c0101fe7:	c3                   	ret    

c0101fe8 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101fe8:	55                   	push   %ebp
c0101fe9:	89 e5                	mov    %esp,%ebp
c0101feb:	83 ec 14             	sub    $0x14,%esp
c0101fee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ff1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ff8:	66 a3 50 35 12 c0    	mov    %ax,0xc0123550
    if (did_init) {
c0101ffe:	a1 60 67 12 c0       	mov    0xc0126760,%eax
c0102003:	85 c0                	test   %eax,%eax
c0102005:	74 39                	je     c0102040 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0102007:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010200a:	0f b6 c0             	movzbl %al,%eax
c010200d:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0102013:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102016:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010201a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010201e:	ee                   	out    %al,(%dx)
}
c010201f:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0102020:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102024:	c1 e8 08             	shr    $0x8,%eax
c0102027:	0f b7 c0             	movzwl %ax,%eax
c010202a:	0f b6 c0             	movzbl %al,%eax
c010202d:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0102033:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102036:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010203a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010203e:	ee                   	out    %al,(%dx)
}
c010203f:	90                   	nop
    }
}
c0102040:	90                   	nop
c0102041:	89 ec                	mov    %ebp,%esp
c0102043:	5d                   	pop    %ebp
c0102044:	c3                   	ret    

c0102045 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102045:	55                   	push   %ebp
c0102046:	89 e5                	mov    %esp,%ebp
c0102048:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010204b:	8b 45 08             	mov    0x8(%ebp),%eax
c010204e:	ba 01 00 00 00       	mov    $0x1,%edx
c0102053:	88 c1                	mov    %al,%cl
c0102055:	d3 e2                	shl    %cl,%edx
c0102057:	89 d0                	mov    %edx,%eax
c0102059:	98                   	cwtl   
c010205a:	f7 d0                	not    %eax
c010205c:	0f bf d0             	movswl %ax,%edx
c010205f:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c0102066:	98                   	cwtl   
c0102067:	21 d0                	and    %edx,%eax
c0102069:	98                   	cwtl   
c010206a:	0f b7 c0             	movzwl %ax,%eax
c010206d:	89 04 24             	mov    %eax,(%esp)
c0102070:	e8 73 ff ff ff       	call   c0101fe8 <pic_setmask>
}
c0102075:	90                   	nop
c0102076:	89 ec                	mov    %ebp,%esp
c0102078:	5d                   	pop    %ebp
c0102079:	c3                   	ret    

c010207a <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010207a:	55                   	push   %ebp
c010207b:	89 e5                	mov    %esp,%ebp
c010207d:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0102080:	c7 05 60 67 12 c0 01 	movl   $0x1,0xc0126760
c0102087:	00 00 00 
c010208a:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102090:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102094:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102098:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010209c:	ee                   	out    %al,(%dx)
}
c010209d:	90                   	nop
c010209e:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01020a4:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a8:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020ac:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020b0:	ee                   	out    %al,(%dx)
}
c01020b1:	90                   	nop
c01020b2:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020b8:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020bc:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020c0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020c4:	ee                   	out    %al,(%dx)
}
c01020c5:	90                   	nop
c01020c6:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01020cc:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020d0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020d4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020d8:	ee                   	out    %al,(%dx)
}
c01020d9:	90                   	nop
c01020da:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01020e0:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020e8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020ec:	ee                   	out    %al,(%dx)
}
c01020ed:	90                   	nop
c01020ee:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01020f4:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01020fc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102100:	ee                   	out    %al,(%dx)
}
c0102101:	90                   	nop
c0102102:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102108:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010210c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102110:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102114:	ee                   	out    %al,(%dx)
}
c0102115:	90                   	nop
c0102116:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c010211c:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102120:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102124:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102128:	ee                   	out    %al,(%dx)
}
c0102129:	90                   	nop
c010212a:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0102130:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102134:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102138:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010213c:	ee                   	out    %al,(%dx)
}
c010213d:	90                   	nop
c010213e:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102144:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102148:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010214c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102150:	ee                   	out    %al,(%dx)
}
c0102151:	90                   	nop
c0102152:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102158:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010215c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102160:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102164:	ee                   	out    %al,(%dx)
}
c0102165:	90                   	nop
c0102166:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010216c:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102170:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102174:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102178:	ee                   	out    %al,(%dx)
}
c0102179:	90                   	nop
c010217a:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102180:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102184:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102188:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010218c:	ee                   	out    %al,(%dx)
}
c010218d:	90                   	nop
c010218e:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102194:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102198:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010219c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01021a0:	ee                   	out    %al,(%dx)
}
c01021a1:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021a2:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c01021a9:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01021ae:	74 0f                	je     c01021bf <pic_init+0x145>
        pic_setmask(irq_mask);
c01021b0:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c01021b7:	89 04 24             	mov    %eax,(%esp)
c01021ba:	e8 29 fe ff ff       	call   c0101fe8 <pic_setmask>
    }
}
c01021bf:	90                   	nop
c01021c0:	89 ec                	mov    %ebp,%esp
c01021c2:	5d                   	pop    %ebp
c01021c3:	c3                   	ret    

c01021c4 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01021c4:	55                   	push   %ebp
c01021c5:	89 e5                	mov    %esp,%ebp
c01021c7:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021ca:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01021d1:	00 
c01021d2:	c7 04 24 c0 95 10 c0 	movl   $0xc01095c0,(%esp)
c01021d9:	e8 c7 e1 ff ff       	call   c01003a5 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01021de:	c7 04 24 ca 95 10 c0 	movl   $0xc01095ca,(%esp)
c01021e5:	e8 bb e1 ff ff       	call   c01003a5 <cprintf>
    panic("EOT: kernel seems ok.");
c01021ea:	c7 44 24 08 d8 95 10 	movl   $0xc01095d8,0x8(%esp)
c01021f1:	c0 
c01021f2:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01021f9:	00 
c01021fa:	c7 04 24 ee 95 10 c0 	movl   $0xc01095ee,(%esp)
c0102201:	e8 24 eb ff ff       	call   c0100d2a <__panic>

c0102206 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102206:	55                   	push   %ebp
c0102207:	89 e5                	mov    %esp,%ebp
c0102209:	83 ec 10             	sub    $0x10,%esp
      */
    extern uintptr_t __vectors[];

    //all gate DPL=0, so use DPL_KERNEL 
    int i;
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c010220c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102213:	e9 c4 00 00 00       	jmp    c01022dc <idt_init+0xd6>
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c0102218:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010221b:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c0102222:	0f b7 d0             	movzwl %ax,%edx
c0102225:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102228:	66 89 14 c5 e0 67 12 	mov    %dx,-0x3fed9820(,%eax,8)
c010222f:	c0 
c0102230:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102233:	66 c7 04 c5 e2 67 12 	movw   $0x8,-0x3fed981e(,%eax,8)
c010223a:	c0 08 00 
c010223d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102240:	0f b6 14 c5 e4 67 12 	movzbl -0x3fed981c(,%eax,8),%edx
c0102247:	c0 
c0102248:	80 e2 e0             	and    $0xe0,%dl
c010224b:	88 14 c5 e4 67 12 c0 	mov    %dl,-0x3fed981c(,%eax,8)
c0102252:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102255:	0f b6 14 c5 e4 67 12 	movzbl -0x3fed981c(,%eax,8),%edx
c010225c:	c0 
c010225d:	80 e2 1f             	and    $0x1f,%dl
c0102260:	88 14 c5 e4 67 12 c0 	mov    %dl,-0x3fed981c(,%eax,8)
c0102267:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010226a:	0f b6 14 c5 e5 67 12 	movzbl -0x3fed981b(,%eax,8),%edx
c0102271:	c0 
c0102272:	80 e2 f0             	and    $0xf0,%dl
c0102275:	80 ca 0e             	or     $0xe,%dl
c0102278:	88 14 c5 e5 67 12 c0 	mov    %dl,-0x3fed981b(,%eax,8)
c010227f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102282:	0f b6 14 c5 e5 67 12 	movzbl -0x3fed981b(,%eax,8),%edx
c0102289:	c0 
c010228a:	80 e2 ef             	and    $0xef,%dl
c010228d:	88 14 c5 e5 67 12 c0 	mov    %dl,-0x3fed981b(,%eax,8)
c0102294:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102297:	0f b6 14 c5 e5 67 12 	movzbl -0x3fed981b(,%eax,8),%edx
c010229e:	c0 
c010229f:	80 e2 9f             	and    $0x9f,%dl
c01022a2:	88 14 c5 e5 67 12 c0 	mov    %dl,-0x3fed981b(,%eax,8)
c01022a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022ac:	0f b6 14 c5 e5 67 12 	movzbl -0x3fed981b(,%eax,8),%edx
c01022b3:	c0 
c01022b4:	80 ca 80             	or     $0x80,%dl
c01022b7:	88 14 c5 e5 67 12 c0 	mov    %dl,-0x3fed981b(,%eax,8)
c01022be:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c1:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c01022c8:	c1 e8 10             	shr    $0x10,%eax
c01022cb:	0f b7 d0             	movzwl %ax,%edx
c01022ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d1:	66 89 14 c5 e6 67 12 	mov    %dx,-0x3fed981a(,%eax,8)
c01022d8:	c0 
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c01022d9:	ff 45 fc             	incl   -0x4(%ebp)
c01022dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022df:	3d ff 00 00 00       	cmp    $0xff,%eax
c01022e4:	0f 86 2e ff ff ff    	jbe    c0102218 <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL],1,KERNEL_CS,__vectors[T_SYSCALL],DPL_USER);
c01022ea:	a1 e0 37 12 c0       	mov    0xc01237e0,%eax
c01022ef:	0f b7 c0             	movzwl %ax,%eax
c01022f2:	66 a3 e0 6b 12 c0    	mov    %ax,0xc0126be0
c01022f8:	66 c7 05 e2 6b 12 c0 	movw   $0x8,0xc0126be2
c01022ff:	08 00 
c0102301:	0f b6 05 e4 6b 12 c0 	movzbl 0xc0126be4,%eax
c0102308:	24 e0                	and    $0xe0,%al
c010230a:	a2 e4 6b 12 c0       	mov    %al,0xc0126be4
c010230f:	0f b6 05 e4 6b 12 c0 	movzbl 0xc0126be4,%eax
c0102316:	24 1f                	and    $0x1f,%al
c0102318:	a2 e4 6b 12 c0       	mov    %al,0xc0126be4
c010231d:	0f b6 05 e5 6b 12 c0 	movzbl 0xc0126be5,%eax
c0102324:	0c 0f                	or     $0xf,%al
c0102326:	a2 e5 6b 12 c0       	mov    %al,0xc0126be5
c010232b:	0f b6 05 e5 6b 12 c0 	movzbl 0xc0126be5,%eax
c0102332:	24 ef                	and    $0xef,%al
c0102334:	a2 e5 6b 12 c0       	mov    %al,0xc0126be5
c0102339:	0f b6 05 e5 6b 12 c0 	movzbl 0xc0126be5,%eax
c0102340:	0c 60                	or     $0x60,%al
c0102342:	a2 e5 6b 12 c0       	mov    %al,0xc0126be5
c0102347:	0f b6 05 e5 6b 12 c0 	movzbl 0xc0126be5,%eax
c010234e:	0c 80                	or     $0x80,%al
c0102350:	a2 e5 6b 12 c0       	mov    %al,0xc0126be5
c0102355:	a1 e0 37 12 c0       	mov    0xc01237e0,%eax
c010235a:	c1 e8 10             	shr    $0x10,%eax
c010235d:	0f b7 c0             	movzwl %ax,%eax
c0102360:	66 a3 e6 6b 12 c0    	mov    %ax,0xc0126be6
    SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
c0102366:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c010236b:	0f b7 c0             	movzwl %ax,%eax
c010236e:	66 a3 a8 6b 12 c0    	mov    %ax,0xc0126ba8
c0102374:	66 c7 05 aa 6b 12 c0 	movw   $0x8,0xc0126baa
c010237b:	08 00 
c010237d:	0f b6 05 ac 6b 12 c0 	movzbl 0xc0126bac,%eax
c0102384:	24 e0                	and    $0xe0,%al
c0102386:	a2 ac 6b 12 c0       	mov    %al,0xc0126bac
c010238b:	0f b6 05 ac 6b 12 c0 	movzbl 0xc0126bac,%eax
c0102392:	24 1f                	and    $0x1f,%al
c0102394:	a2 ac 6b 12 c0       	mov    %al,0xc0126bac
c0102399:	0f b6 05 ad 6b 12 c0 	movzbl 0xc0126bad,%eax
c01023a0:	24 f0                	and    $0xf0,%al
c01023a2:	0c 0e                	or     $0xe,%al
c01023a4:	a2 ad 6b 12 c0       	mov    %al,0xc0126bad
c01023a9:	0f b6 05 ad 6b 12 c0 	movzbl 0xc0126bad,%eax
c01023b0:	24 ef                	and    $0xef,%al
c01023b2:	a2 ad 6b 12 c0       	mov    %al,0xc0126bad
c01023b7:	0f b6 05 ad 6b 12 c0 	movzbl 0xc0126bad,%eax
c01023be:	0c 60                	or     $0x60,%al
c01023c0:	a2 ad 6b 12 c0       	mov    %al,0xc0126bad
c01023c5:	0f b6 05 ad 6b 12 c0 	movzbl 0xc0126bad,%eax
c01023cc:	0c 80                	or     $0x80,%al
c01023ce:	a2 ad 6b 12 c0       	mov    %al,0xc0126bad
c01023d3:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c01023d8:	c1 e8 10             	shr    $0x10,%eax
c01023db:	0f b7 c0             	movzwl %ax,%eax
c01023de:	66 a3 ae 6b 12 c0    	mov    %ax,0xc0126bae
c01023e4:	c7 45 f8 60 35 12 c0 	movl   $0xc0123560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023ee:	0f 01 18             	lidtl  (%eax)
}
c01023f1:	90                   	nop
    
    //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
c01023f2:	90                   	nop
c01023f3:	89 ec                	mov    %ebp,%esp
c01023f5:	5d                   	pop    %ebp
c01023f6:	c3                   	ret    

c01023f7 <trapname>:

static const char *
trapname(int trapno) {
c01023f7:	55                   	push   %ebp
c01023f8:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01023fd:	83 f8 13             	cmp    $0x13,%eax
c0102400:	77 0c                	ja     c010240e <trapname+0x17>
        return excnames[trapno];
c0102402:	8b 45 08             	mov    0x8(%ebp),%eax
c0102405:	8b 04 85 40 9a 10 c0 	mov    -0x3fef65c0(,%eax,4),%eax
c010240c:	eb 18                	jmp    c0102426 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010240e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102412:	7e 0d                	jle    c0102421 <trapname+0x2a>
c0102414:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102418:	7f 07                	jg     c0102421 <trapname+0x2a>
        return "Hardware Interrupt";
c010241a:	b8 ff 95 10 c0       	mov    $0xc01095ff,%eax
c010241f:	eb 05                	jmp    c0102426 <trapname+0x2f>
    }
    return "(unknown trap)";
c0102421:	b8 12 96 10 c0       	mov    $0xc0109612,%eax
}
c0102426:	5d                   	pop    %ebp
c0102427:	c3                   	ret    

c0102428 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102428:	55                   	push   %ebp
c0102429:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010242b:	8b 45 08             	mov    0x8(%ebp),%eax
c010242e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102432:	83 f8 08             	cmp    $0x8,%eax
c0102435:	0f 94 c0             	sete   %al
c0102438:	0f b6 c0             	movzbl %al,%eax
}
c010243b:	5d                   	pop    %ebp
c010243c:	c3                   	ret    

c010243d <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010243d:	55                   	push   %ebp
c010243e:	89 e5                	mov    %esp,%ebp
c0102440:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102443:	8b 45 08             	mov    0x8(%ebp),%eax
c0102446:	89 44 24 04          	mov    %eax,0x4(%esp)
c010244a:	c7 04 24 53 96 10 c0 	movl   $0xc0109653,(%esp)
c0102451:	e8 4f df ff ff       	call   c01003a5 <cprintf>
    print_regs(&tf->tf_regs);
c0102456:	8b 45 08             	mov    0x8(%ebp),%eax
c0102459:	89 04 24             	mov    %eax,(%esp)
c010245c:	e8 8f 01 00 00       	call   c01025f0 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102461:	8b 45 08             	mov    0x8(%ebp),%eax
c0102464:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102468:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246c:	c7 04 24 64 96 10 c0 	movl   $0xc0109664,(%esp)
c0102473:	e8 2d df ff ff       	call   c01003a5 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102478:	8b 45 08             	mov    0x8(%ebp),%eax
c010247b:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010247f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102483:	c7 04 24 77 96 10 c0 	movl   $0xc0109677,(%esp)
c010248a:	e8 16 df ff ff       	call   c01003a5 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010248f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102492:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102496:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249a:	c7 04 24 8a 96 10 c0 	movl   $0xc010968a,(%esp)
c01024a1:	e8 ff de ff ff       	call   c01003a5 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01024a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a9:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01024ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b1:	c7 04 24 9d 96 10 c0 	movl   $0xc010969d,(%esp)
c01024b8:	e8 e8 de ff ff       	call   c01003a5 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01024bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c0:	8b 40 30             	mov    0x30(%eax),%eax
c01024c3:	89 04 24             	mov    %eax,(%esp)
c01024c6:	e8 2c ff ff ff       	call   c01023f7 <trapname>
c01024cb:	8b 55 08             	mov    0x8(%ebp),%edx
c01024ce:	8b 52 30             	mov    0x30(%edx),%edx
c01024d1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024d5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01024d9:	c7 04 24 b0 96 10 c0 	movl   $0xc01096b0,(%esp)
c01024e0:	e8 c0 de ff ff       	call   c01003a5 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e8:	8b 40 34             	mov    0x34(%eax),%eax
c01024eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ef:	c7 04 24 c2 96 10 c0 	movl   $0xc01096c2,(%esp)
c01024f6:	e8 aa de ff ff       	call   c01003a5 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fe:	8b 40 38             	mov    0x38(%eax),%eax
c0102501:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102505:	c7 04 24 d1 96 10 c0 	movl   $0xc01096d1,(%esp)
c010250c:	e8 94 de ff ff       	call   c01003a5 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102511:	8b 45 08             	mov    0x8(%ebp),%eax
c0102514:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102518:	89 44 24 04          	mov    %eax,0x4(%esp)
c010251c:	c7 04 24 e0 96 10 c0 	movl   $0xc01096e0,(%esp)
c0102523:	e8 7d de ff ff       	call   c01003a5 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102528:	8b 45 08             	mov    0x8(%ebp),%eax
c010252b:	8b 40 40             	mov    0x40(%eax),%eax
c010252e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102532:	c7 04 24 f3 96 10 c0 	movl   $0xc01096f3,(%esp)
c0102539:	e8 67 de ff ff       	call   c01003a5 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010253e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102545:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010254c:	eb 3d                	jmp    c010258b <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010254e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102551:	8b 50 40             	mov    0x40(%eax),%edx
c0102554:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102557:	21 d0                	and    %edx,%eax
c0102559:	85 c0                	test   %eax,%eax
c010255b:	74 28                	je     c0102585 <print_trapframe+0x148>
c010255d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102560:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c0102567:	85 c0                	test   %eax,%eax
c0102569:	74 1a                	je     c0102585 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c010256b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010256e:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c0102575:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102579:	c7 04 24 02 97 10 c0 	movl   $0xc0109702,(%esp)
c0102580:	e8 20 de ff ff       	call   c01003a5 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102585:	ff 45 f4             	incl   -0xc(%ebp)
c0102588:	d1 65 f0             	shll   -0x10(%ebp)
c010258b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010258e:	83 f8 17             	cmp    $0x17,%eax
c0102591:	76 bb                	jbe    c010254e <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102593:	8b 45 08             	mov    0x8(%ebp),%eax
c0102596:	8b 40 40             	mov    0x40(%eax),%eax
c0102599:	c1 e8 0c             	shr    $0xc,%eax
c010259c:	83 e0 03             	and    $0x3,%eax
c010259f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a3:	c7 04 24 06 97 10 c0 	movl   $0xc0109706,(%esp)
c01025aa:	e8 f6 dd ff ff       	call   c01003a5 <cprintf>

    if (!trap_in_kernel(tf)) {
c01025af:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b2:	89 04 24             	mov    %eax,(%esp)
c01025b5:	e8 6e fe ff ff       	call   c0102428 <trap_in_kernel>
c01025ba:	85 c0                	test   %eax,%eax
c01025bc:	75 2d                	jne    c01025eb <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01025be:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c1:	8b 40 44             	mov    0x44(%eax),%eax
c01025c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c8:	c7 04 24 0f 97 10 c0 	movl   $0xc010970f,(%esp)
c01025cf:	e8 d1 dd ff ff       	call   c01003a5 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01025d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025df:	c7 04 24 1e 97 10 c0 	movl   $0xc010971e,(%esp)
c01025e6:	e8 ba dd ff ff       	call   c01003a5 <cprintf>
    }
}
c01025eb:	90                   	nop
c01025ec:	89 ec                	mov    %ebp,%esp
c01025ee:	5d                   	pop    %ebp
c01025ef:	c3                   	ret    

c01025f0 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025f0:	55                   	push   %ebp
c01025f1:	89 e5                	mov    %esp,%ebp
c01025f3:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f9:	8b 00                	mov    (%eax),%eax
c01025fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ff:	c7 04 24 31 97 10 c0 	movl   $0xc0109731,(%esp)
c0102606:	e8 9a dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010260b:	8b 45 08             	mov    0x8(%ebp),%eax
c010260e:	8b 40 04             	mov    0x4(%eax),%eax
c0102611:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102615:	c7 04 24 40 97 10 c0 	movl   $0xc0109740,(%esp)
c010261c:	e8 84 dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102621:	8b 45 08             	mov    0x8(%ebp),%eax
c0102624:	8b 40 08             	mov    0x8(%eax),%eax
c0102627:	89 44 24 04          	mov    %eax,0x4(%esp)
c010262b:	c7 04 24 4f 97 10 c0 	movl   $0xc010974f,(%esp)
c0102632:	e8 6e dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102637:	8b 45 08             	mov    0x8(%ebp),%eax
c010263a:	8b 40 0c             	mov    0xc(%eax),%eax
c010263d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102641:	c7 04 24 5e 97 10 c0 	movl   $0xc010975e,(%esp)
c0102648:	e8 58 dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c010264d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102650:	8b 40 10             	mov    0x10(%eax),%eax
c0102653:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102657:	c7 04 24 6d 97 10 c0 	movl   $0xc010976d,(%esp)
c010265e:	e8 42 dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102663:	8b 45 08             	mov    0x8(%ebp),%eax
c0102666:	8b 40 14             	mov    0x14(%eax),%eax
c0102669:	89 44 24 04          	mov    %eax,0x4(%esp)
c010266d:	c7 04 24 7c 97 10 c0 	movl   $0xc010977c,(%esp)
c0102674:	e8 2c dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102679:	8b 45 08             	mov    0x8(%ebp),%eax
c010267c:	8b 40 18             	mov    0x18(%eax),%eax
c010267f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102683:	c7 04 24 8b 97 10 c0 	movl   $0xc010978b,(%esp)
c010268a:	e8 16 dd ff ff       	call   c01003a5 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010268f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102692:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102695:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102699:	c7 04 24 9a 97 10 c0 	movl   $0xc010979a,(%esp)
c01026a0:	e8 00 dd ff ff       	call   c01003a5 <cprintf>
}
c01026a5:	90                   	nop
c01026a6:	89 ec                	mov    %ebp,%esp
c01026a8:	5d                   	pop    %ebp
c01026a9:	c3                   	ret    

c01026aa <print_pgfault>:
    }
}


static inline void
print_pgfault(struct trapframe *tf) {
c01026aa:	55                   	push   %ebp
c01026ab:	89 e5                	mov    %esp,%ebp
c01026ad:	83 ec 38             	sub    $0x38,%esp
c01026b0:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01026b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b6:	8b 40 34             	mov    0x34(%eax),%eax
c01026b9:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026bc:	85 c0                	test   %eax,%eax
c01026be:	74 07                	je     c01026c7 <print_pgfault+0x1d>
c01026c0:	bb a9 97 10 c0       	mov    $0xc01097a9,%ebx
c01026c5:	eb 05                	jmp    c01026cc <print_pgfault+0x22>
c01026c7:	bb ba 97 10 c0       	mov    $0xc01097ba,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c01026cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01026cf:	8b 40 34             	mov    0x34(%eax),%eax
c01026d2:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026d5:	85 c0                	test   %eax,%eax
c01026d7:	74 07                	je     c01026e0 <print_pgfault+0x36>
c01026d9:	b9 57 00 00 00       	mov    $0x57,%ecx
c01026de:	eb 05                	jmp    c01026e5 <print_pgfault+0x3b>
c01026e0:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01026e8:	8b 40 34             	mov    0x34(%eax),%eax
c01026eb:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026ee:	85 c0                	test   %eax,%eax
c01026f0:	74 07                	je     c01026f9 <print_pgfault+0x4f>
c01026f2:	ba 55 00 00 00       	mov    $0x55,%edx
c01026f7:	eb 05                	jmp    c01026fe <print_pgfault+0x54>
c01026f9:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026fe:	0f 20 d0             	mov    %cr2,%eax
c0102701:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102707:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010270b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010270f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102713:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102717:	c7 04 24 c8 97 10 c0 	movl   $0xc01097c8,(%esp)
c010271e:	e8 82 dc ff ff       	call   c01003a5 <cprintf>
}
c0102723:	90                   	nop
c0102724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102727:	89 ec                	mov    %ebp,%esp
c0102729:	5d                   	pop    %ebp
c010272a:	c3                   	ret    

c010272b <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010272b:	55                   	push   %ebp
c010272c:	89 e5                	mov    %esp,%ebp
c010272e:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102731:	8b 45 08             	mov    0x8(%ebp),%eax
c0102734:	89 04 24             	mov    %eax,(%esp)
c0102737:	e8 6e ff ff ff       	call   c01026aa <print_pgfault>
    if (check_mm_struct != NULL) {
c010273c:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0102741:	85 c0                	test   %eax,%eax
c0102743:	74 26                	je     c010276b <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102745:	0f 20 d0             	mov    %cr2,%eax
c0102748:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010274b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c010274e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102751:	8b 50 34             	mov    0x34(%eax),%edx
c0102754:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0102759:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010275d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102761:	89 04 24             	mov    %eax,(%esp)
c0102764:	e8 23 5a 00 00       	call   c010818c <do_pgfault>
c0102769:	eb 1c                	jmp    c0102787 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c010276b:	c7 44 24 08 eb 97 10 	movl   $0xc01097eb,0x8(%esp)
c0102772:	c0 
c0102773:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010277a:	00 
c010277b:	c7 04 24 ee 95 10 c0 	movl   $0xc01095ee,(%esp)
c0102782:	e8 a3 e5 ff ff       	call   c0100d2a <__panic>
}
c0102787:	89 ec                	mov    %ebp,%esp
c0102789:	5d                   	pop    %ebp
c010278a:	c3                   	ret    

c010278b <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010278b:	55                   	push   %ebp
c010278c:	89 e5                	mov    %esp,%ebp
c010278e:	83 ec 38             	sub    $0x38,%esp
c0102791:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102794:	8b 45 08             	mov    0x8(%ebp),%eax
c0102797:	8b 40 30             	mov    0x30(%eax),%eax
c010279a:	83 f8 79             	cmp    $0x79,%eax
c010279d:	0f 84 00 03 00 00    	je     c0102aa3 <trap_dispatch+0x318>
c01027a3:	83 f8 79             	cmp    $0x79,%eax
c01027a6:	0f 87 77 03 00 00    	ja     c0102b23 <trap_dispatch+0x398>
c01027ac:	83 f8 2f             	cmp    $0x2f,%eax
c01027af:	77 1e                	ja     c01027cf <trap_dispatch+0x44>
c01027b1:	83 f8 0e             	cmp    $0xe,%eax
c01027b4:	0f 82 69 03 00 00    	jb     c0102b23 <trap_dispatch+0x398>
c01027ba:	83 e8 0e             	sub    $0xe,%eax
c01027bd:	83 f8 21             	cmp    $0x21,%eax
c01027c0:	0f 87 5d 03 00 00    	ja     c0102b23 <trap_dispatch+0x398>
c01027c6:	8b 04 85 5c 98 10 c0 	mov    -0x3fef67a4(,%eax,4),%eax
c01027cd:	ff e0                	jmp    *%eax
c01027cf:	83 f8 78             	cmp    $0x78,%eax
c01027d2:	0f 84 3e 02 00 00    	je     c0102a16 <trap_dispatch+0x28b>
c01027d8:	e9 46 03 00 00       	jmp    c0102b23 <trap_dispatch+0x398>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01027dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e0:	89 04 24             	mov    %eax,(%esp)
c01027e3:	e8 43 ff ff ff       	call   c010272b <pgfault_handler>
c01027e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01027eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01027ef:	0f 84 66 03 00 00    	je     c0102b5b <trap_dispatch+0x3d0>
            print_trapframe(tf);
c01027f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01027f8:	89 04 24             	mov    %eax,(%esp)
c01027fb:	e8 3d fc ff ff       	call   c010243d <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102800:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102803:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102807:	c7 44 24 08 02 98 10 	movl   $0xc0109802,0x8(%esp)
c010280e:	c0 
c010280f:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0102816:	00 
c0102817:	c7 04 24 ee 95 10 c0 	movl   $0xc01095ee,(%esp)
c010281e:	e8 07 e5 ff ff       	call   c0100d2a <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0102823:	a1 24 64 12 c0       	mov    0xc0126424,%eax
c0102828:	40                   	inc    %eax
c0102829:	a3 24 64 12 c0       	mov    %eax,0xc0126424
        if(ticks%100==0){
c010282e:	8b 0d 24 64 12 c0    	mov    0xc0126424,%ecx
c0102834:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102839:	89 c8                	mov    %ecx,%eax
c010283b:	f7 e2                	mul    %edx
c010283d:	c1 ea 05             	shr    $0x5,%edx
c0102840:	89 d0                	mov    %edx,%eax
c0102842:	c1 e0 02             	shl    $0x2,%eax
c0102845:	01 d0                	add    %edx,%eax
c0102847:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010284e:	01 d0                	add    %edx,%eax
c0102850:	c1 e0 02             	shl    $0x2,%eax
c0102853:	29 c1                	sub    %eax,%ecx
c0102855:	89 ca                	mov    %ecx,%edx
c0102857:	85 d2                	test   %edx,%edx
c0102859:	0f 85 ff 02 00 00    	jne    c0102b5e <trap_dispatch+0x3d3>
            print_ticks();
c010285f:	e8 60 f9 ff ff       	call   c01021c4 <print_ticks>
        }
        break;
c0102864:	e9 f5 02 00 00       	jmp    c0102b5e <trap_dispatch+0x3d3>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102869:	e8 9c ee ff ff       	call   c010170a <cons_getc>
c010286e:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102871:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102875:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0102879:	89 54 24 08          	mov    %edx,0x8(%esp)
c010287d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102881:	c7 04 24 1d 98 10 c0 	movl   $0xc010981d,(%esp)
c0102888:	e8 18 db ff ff       	call   c01003a5 <cprintf>
        break;
c010288d:	e9 d0 02 00 00       	jmp    c0102b62 <trap_dispatch+0x3d7>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102892:	e8 73 ee ff ff       	call   c010170a <cons_getc>
c0102897:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010289a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c010289e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01028a2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01028a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01028aa:	c7 04 24 2f 98 10 c0 	movl   $0xc010982f,(%esp)
c01028b1:	e8 ef da ff ff       	call   c01003a5 <cprintf>
         if (c == '0'&&!trap_in_kernel(tf)) {
c01028b6:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c01028ba:	0f 85 a1 00 00 00    	jne    c0102961 <trap_dispatch+0x1d6>
c01028c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01028c3:	89 04 24             	mov    %eax,(%esp)
c01028c6:	e8 5d fb ff ff       	call   c0102428 <trap_in_kernel>
c01028cb:	85 c0                	test   %eax,%eax
c01028cd:	0f 85 8e 00 00 00    	jne    c0102961 <trap_dispatch+0x1d6>
c01028d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01028d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c01028d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01028e0:	83 f8 08             	cmp    $0x8,%eax
c01028e3:	74 6b                	je     c0102950 <trap_dispatch+0x1c5>
        tf->tf_cs = KERNEL_CS;
c01028e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028e8:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c01028ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028f1:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c01028f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028fa:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c01028fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102901:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0102905:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102908:	8b 40 40             	mov    0x40(%eax),%eax
c010290b:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0102910:	89 c2                	mov    %eax,%edx
c0102912:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102915:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102918:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010291b:	8b 40 44             	mov    0x44(%eax),%eax
c010291e:	83 e8 44             	sub    $0x44,%eax
c0102921:	a3 cc 67 12 c0       	mov    %eax,0xc01267cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102926:	a1 cc 67 12 c0       	mov    0xc01267cc,%eax
c010292b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102932:	00 
c0102933:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102936:	89 54 24 04          	mov    %edx,0x4(%esp)
c010293a:	89 04 24             	mov    %eax,(%esp)
c010293d:	e8 cd 66 00 00       	call   c010900f <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102942:	8b 15 cc 67 12 c0    	mov    0xc01267cc,%edx
c0102948:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010294b:	83 e8 04             	sub    $0x4,%eax
c010294e:	89 10                	mov    %edx,(%eax)
}
c0102950:	90                   	nop
        //切换为内核态
        switch_to_kernel(tf);
        print_trapframe(tf);
c0102951:	8b 45 08             	mov    0x8(%ebp),%eax
c0102954:	89 04 24             	mov    %eax,(%esp)
c0102957:	e8 e1 fa ff ff       	call   c010243d <print_trapframe>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
        //切换为用户态
        switch_to_user(tf);
        print_trapframe(tf);
        }
        break;
c010295c:	e9 00 02 00 00       	jmp    c0102b61 <trap_dispatch+0x3d6>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
c0102961:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c0102965:	0f 85 f6 01 00 00    	jne    c0102b61 <trap_dispatch+0x3d6>
c010296b:	8b 45 08             	mov    0x8(%ebp),%eax
c010296e:	89 04 24             	mov    %eax,(%esp)
c0102971:	e8 b2 fa ff ff       	call   c0102428 <trap_in_kernel>
c0102976:	85 c0                	test   %eax,%eax
c0102978:	0f 84 e3 01 00 00    	je     c0102b61 <trap_dispatch+0x3d6>
c010297e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102981:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (tf->tf_cs != USER_CS) {
c0102984:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102987:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010298b:	83 f8 1b             	cmp    $0x1b,%eax
c010298e:	74 75                	je     c0102a05 <trap_dispatch+0x27a>
        switchk2u = *tf;
c0102990:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0102993:	b8 4c 00 00 00       	mov    $0x4c,%eax
c0102998:	83 e0 fc             	and    $0xfffffffc,%eax
c010299b:	89 c3                	mov    %eax,%ebx
c010299d:	b8 00 00 00 00       	mov    $0x0,%eax
c01029a2:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c01029a5:	89 90 80 67 12 c0    	mov    %edx,-0x3fed9880(%eax)
c01029ab:	83 c0 04             	add    $0x4,%eax
c01029ae:	39 d8                	cmp    %ebx,%eax
c01029b0:	72 f0                	jb     c01029a2 <trap_dispatch+0x217>
        switchk2u.tf_cs = USER_CS;
c01029b2:	66 c7 05 bc 67 12 c0 	movw   $0x1b,0xc01267bc
c01029b9:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01029bb:	66 c7 05 c8 67 12 c0 	movw   $0x23,0xc01267c8
c01029c2:	23 00 
c01029c4:	0f b7 05 c8 67 12 c0 	movzwl 0xc01267c8,%eax
c01029cb:	66 a3 a8 67 12 c0    	mov    %ax,0xc01267a8
c01029d1:	0f b7 05 a8 67 12 c0 	movzwl 0xc01267a8,%eax
c01029d8:	66 a3 ac 67 12 c0    	mov    %ax,0xc01267ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c01029de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01029e1:	83 c0 4c             	add    $0x4c,%eax
c01029e4:	a3 c4 67 12 c0       	mov    %eax,0xc01267c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c01029e9:	a1 c0 67 12 c0       	mov    0xc01267c0,%eax
c01029ee:	0d 00 30 00 00       	or     $0x3000,%eax
c01029f3:	a3 c0 67 12 c0       	mov    %eax,0xc01267c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c01029f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01029fb:	83 e8 04             	sub    $0x4,%eax
c01029fe:	ba 80 67 12 c0       	mov    $0xc0126780,%edx
c0102a03:	89 10                	mov    %edx,(%eax)
}
c0102a05:	90                   	nop
        print_trapframe(tf);
c0102a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a09:	89 04 24             	mov    %eax,(%esp)
c0102a0c:	e8 2c fa ff ff       	call   c010243d <print_trapframe>
        break;
c0102a11:	e9 4b 01 00 00       	jmp    c0102b61 <trap_dispatch+0x3d6>
c0102a16:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (tf->tf_cs != USER_CS) {
c0102a1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a1f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102a23:	83 f8 1b             	cmp    $0x1b,%eax
c0102a26:	74 75                	je     c0102a9d <trap_dispatch+0x312>
        switchk2u = *tf;
c0102a28:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c0102a2b:	b8 4c 00 00 00       	mov    $0x4c,%eax
c0102a30:	83 e0 fc             	and    $0xfffffffc,%eax
c0102a33:	89 c3                	mov    %eax,%ebx
c0102a35:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a3a:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c0102a3d:	89 90 80 67 12 c0    	mov    %edx,-0x3fed9880(%eax)
c0102a43:	83 c0 04             	add    $0x4,%eax
c0102a46:	39 d8                	cmp    %ebx,%eax
c0102a48:	72 f0                	jb     c0102a3a <trap_dispatch+0x2af>
        switchk2u.tf_cs = USER_CS;
c0102a4a:	66 c7 05 bc 67 12 c0 	movw   $0x1b,0xc01267bc
c0102a51:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0102a53:	66 c7 05 c8 67 12 c0 	movw   $0x23,0xc01267c8
c0102a5a:	23 00 
c0102a5c:	0f b7 05 c8 67 12 c0 	movzwl 0xc01267c8,%eax
c0102a63:	66 a3 a8 67 12 c0    	mov    %ax,0xc01267a8
c0102a69:	0f b7 05 a8 67 12 c0 	movzwl 0xc01267a8,%eax
c0102a70:	66 a3 ac 67 12 c0    	mov    %ax,0xc01267ac
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c0102a76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a79:	83 c0 4c             	add    $0x4c,%eax
c0102a7c:	a3 c4 67 12 c0       	mov    %eax,0xc01267c4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c0102a81:	a1 c0 67 12 c0       	mov    0xc01267c0,%eax
c0102a86:	0d 00 30 00 00       	or     $0x3000,%eax
c0102a8b:	a3 c0 67 12 c0       	mov    %eax,0xc01267c0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0102a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a93:	83 e8 04             	sub    $0x4,%eax
c0102a96:	ba 80 67 12 c0       	mov    $0xc0126780,%edx
c0102a9b:	89 10                	mov    %edx,(%eax)
}
c0102a9d:	90                   	nop
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
    	break;
c0102a9e:	e9 bf 00 00 00       	jmp    c0102b62 <trap_dispatch+0x3d7>
c0102aa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c0102aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102aac:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102ab0:	83 f8 08             	cmp    $0x8,%eax
c0102ab3:	74 6b                	je     c0102b20 <trap_dispatch+0x395>
        tf->tf_cs = KERNEL_CS;
c0102ab5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ab8:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c0102abe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ac1:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102ac7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102aca:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102ace:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ad1:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0102ad5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ad8:	8b 40 40             	mov    0x40(%eax),%eax
c0102adb:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0102ae0:	89 c2                	mov    %eax,%edx
c0102ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ae5:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102aeb:	8b 40 44             	mov    0x44(%eax),%eax
c0102aee:	83 e8 44             	sub    $0x44,%eax
c0102af1:	a3 cc 67 12 c0       	mov    %eax,0xc01267cc
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102af6:	a1 cc 67 12 c0       	mov    0xc01267cc,%eax
c0102afb:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102b02:	00 
c0102b03:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102b06:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b0a:	89 04 24             	mov    %eax,(%esp)
c0102b0d:	e8 fd 64 00 00       	call   c010900f <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102b12:	8b 15 cc 67 12 c0    	mov    0xc01267cc,%edx
c0102b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102b1b:	83 e8 04             	sub    $0x4,%eax
c0102b1e:	89 10                	mov    %edx,(%eax)
}
c0102b20:	90                   	nop
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        break;
c0102b21:	eb 3f                	jmp    c0102b62 <trap_dispatch+0x3d7>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102b23:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b26:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102b2a:	83 e0 03             	and    $0x3,%eax
c0102b2d:	85 c0                	test   %eax,%eax
c0102b2f:	75 31                	jne    c0102b62 <trap_dispatch+0x3d7>
            print_trapframe(tf);
c0102b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b34:	89 04 24             	mov    %eax,(%esp)
c0102b37:	e8 01 f9 ff ff       	call   c010243d <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102b3c:	c7 44 24 08 3e 98 10 	movl   $0xc010983e,0x8(%esp)
c0102b43:	c0 
c0102b44:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0102b4b:	00 
c0102b4c:	c7 04 24 ee 95 10 c0 	movl   $0xc01095ee,(%esp)
c0102b53:	e8 d2 e1 ff ff       	call   c0100d2a <__panic>
        break;
c0102b58:	90                   	nop
c0102b59:	eb 07                	jmp    c0102b62 <trap_dispatch+0x3d7>
        break;
c0102b5b:	90                   	nop
c0102b5c:	eb 04                	jmp    c0102b62 <trap_dispatch+0x3d7>
        break;
c0102b5e:	90                   	nop
c0102b5f:	eb 01                	jmp    c0102b62 <trap_dispatch+0x3d7>
        break;
c0102b61:	90                   	nop
        }
    }
}
c0102b62:	90                   	nop
c0102b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102b66:	89 ec                	mov    %ebp,%esp
c0102b68:	5d                   	pop    %ebp
c0102b69:	c3                   	ret    

c0102b6a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102b6a:	55                   	push   %ebp
c0102b6b:	89 e5                	mov    %esp,%ebp
c0102b6d:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b73:	89 04 24             	mov    %eax,(%esp)
c0102b76:	e8 10 fc ff ff       	call   c010278b <trap_dispatch>
}
c0102b7b:	90                   	nop
c0102b7c:	89 ec                	mov    %ebp,%esp
c0102b7e:	5d                   	pop    %ebp
c0102b7f:	c3                   	ret    

c0102b80 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b80:	1e                   	push   %ds
    pushl %es
c0102b81:	06                   	push   %es
    pushl %fs
c0102b82:	0f a0                	push   %fs
    pushl %gs
c0102b84:	0f a8                	push   %gs
    pushal
c0102b86:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102b87:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102b8c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102b8e:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102b90:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102b91:	e8 d4 ff ff ff       	call   c0102b6a <trap>

    # pop the pushed stack pointer
    popl %esp
c0102b96:	5c                   	pop    %esp

c0102b97 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102b97:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102b98:	0f a9                	pop    %gs
    popl %fs
c0102b9a:	0f a1                	pop    %fs
    popl %es
c0102b9c:	07                   	pop    %es
    popl %ds
c0102b9d:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102b9e:	83 c4 08             	add    $0x8,%esp
    iret
c0102ba1:	cf                   	iret   

c0102ba2 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $0
c0102ba4:	6a 00                	push   $0x0
  jmp __alltraps
c0102ba6:	e9 d5 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bab <vector1>:
.globl vector1
vector1:
  pushl $0
c0102bab:	6a 00                	push   $0x0
  pushl $1
c0102bad:	6a 01                	push   $0x1
  jmp __alltraps
c0102baf:	e9 cc ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bb4 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102bb4:	6a 00                	push   $0x0
  pushl $2
c0102bb6:	6a 02                	push   $0x2
  jmp __alltraps
c0102bb8:	e9 c3 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bbd <vector3>:
.globl vector3
vector3:
  pushl $0
c0102bbd:	6a 00                	push   $0x0
  pushl $3
c0102bbf:	6a 03                	push   $0x3
  jmp __alltraps
c0102bc1:	e9 ba ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bc6 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102bc6:	6a 00                	push   $0x0
  pushl $4
c0102bc8:	6a 04                	push   $0x4
  jmp __alltraps
c0102bca:	e9 b1 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bcf <vector5>:
.globl vector5
vector5:
  pushl $0
c0102bcf:	6a 00                	push   $0x0
  pushl $5
c0102bd1:	6a 05                	push   $0x5
  jmp __alltraps
c0102bd3:	e9 a8 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bd8 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102bd8:	6a 00                	push   $0x0
  pushl $6
c0102bda:	6a 06                	push   $0x6
  jmp __alltraps
c0102bdc:	e9 9f ff ff ff       	jmp    c0102b80 <__alltraps>

c0102be1 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102be1:	6a 00                	push   $0x0
  pushl $7
c0102be3:	6a 07                	push   $0x7
  jmp __alltraps
c0102be5:	e9 96 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bea <vector8>:
.globl vector8
vector8:
  pushl $8
c0102bea:	6a 08                	push   $0x8
  jmp __alltraps
c0102bec:	e9 8f ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bf1 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102bf1:	6a 00                	push   $0x0
  pushl $9
c0102bf3:	6a 09                	push   $0x9
  jmp __alltraps
c0102bf5:	e9 86 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102bfa <vector10>:
.globl vector10
vector10:
  pushl $10
c0102bfa:	6a 0a                	push   $0xa
  jmp __alltraps
c0102bfc:	e9 7f ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c01 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102c01:	6a 0b                	push   $0xb
  jmp __alltraps
c0102c03:	e9 78 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c08 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102c08:	6a 0c                	push   $0xc
  jmp __alltraps
c0102c0a:	e9 71 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c0f <vector13>:
.globl vector13
vector13:
  pushl $13
c0102c0f:	6a 0d                	push   $0xd
  jmp __alltraps
c0102c11:	e9 6a ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c16 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102c16:	6a 0e                	push   $0xe
  jmp __alltraps
c0102c18:	e9 63 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c1d <vector15>:
.globl vector15
vector15:
  pushl $0
c0102c1d:	6a 00                	push   $0x0
  pushl $15
c0102c1f:	6a 0f                	push   $0xf
  jmp __alltraps
c0102c21:	e9 5a ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c26 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102c26:	6a 00                	push   $0x0
  pushl $16
c0102c28:	6a 10                	push   $0x10
  jmp __alltraps
c0102c2a:	e9 51 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c2f <vector17>:
.globl vector17
vector17:
  pushl $17
c0102c2f:	6a 11                	push   $0x11
  jmp __alltraps
c0102c31:	e9 4a ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c36 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c36:	6a 00                	push   $0x0
  pushl $18
c0102c38:	6a 12                	push   $0x12
  jmp __alltraps
c0102c3a:	e9 41 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c3f <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c3f:	6a 00                	push   $0x0
  pushl $19
c0102c41:	6a 13                	push   $0x13
  jmp __alltraps
c0102c43:	e9 38 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c48 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $20
c0102c4a:	6a 14                	push   $0x14
  jmp __alltraps
c0102c4c:	e9 2f ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c51 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c51:	6a 00                	push   $0x0
  pushl $21
c0102c53:	6a 15                	push   $0x15
  jmp __alltraps
c0102c55:	e9 26 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c5a <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c5a:	6a 00                	push   $0x0
  pushl $22
c0102c5c:	6a 16                	push   $0x16
  jmp __alltraps
c0102c5e:	e9 1d ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c63 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c63:	6a 00                	push   $0x0
  pushl $23
c0102c65:	6a 17                	push   $0x17
  jmp __alltraps
c0102c67:	e9 14 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c6c <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $24
c0102c6e:	6a 18                	push   $0x18
  jmp __alltraps
c0102c70:	e9 0b ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c75 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c75:	6a 00                	push   $0x0
  pushl $25
c0102c77:	6a 19                	push   $0x19
  jmp __alltraps
c0102c79:	e9 02 ff ff ff       	jmp    c0102b80 <__alltraps>

c0102c7e <vector26>:
.globl vector26
vector26:
  pushl $0
c0102c7e:	6a 00                	push   $0x0
  pushl $26
c0102c80:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102c82:	e9 f9 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102c87 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102c87:	6a 00                	push   $0x0
  pushl $27
c0102c89:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102c8b:	e9 f0 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102c90 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102c90:	6a 00                	push   $0x0
  pushl $28
c0102c92:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102c94:	e9 e7 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102c99 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102c99:	6a 00                	push   $0x0
  pushl $29
c0102c9b:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102c9d:	e9 de fe ff ff       	jmp    c0102b80 <__alltraps>

c0102ca2 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102ca2:	6a 00                	push   $0x0
  pushl $30
c0102ca4:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102ca6:	e9 d5 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cab <vector31>:
.globl vector31
vector31:
  pushl $0
c0102cab:	6a 00                	push   $0x0
  pushl $31
c0102cad:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102caf:	e9 cc fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cb4 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102cb4:	6a 00                	push   $0x0
  pushl $32
c0102cb6:	6a 20                	push   $0x20
  jmp __alltraps
c0102cb8:	e9 c3 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cbd <vector33>:
.globl vector33
vector33:
  pushl $0
c0102cbd:	6a 00                	push   $0x0
  pushl $33
c0102cbf:	6a 21                	push   $0x21
  jmp __alltraps
c0102cc1:	e9 ba fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cc6 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102cc6:	6a 00                	push   $0x0
  pushl $34
c0102cc8:	6a 22                	push   $0x22
  jmp __alltraps
c0102cca:	e9 b1 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102ccf <vector35>:
.globl vector35
vector35:
  pushl $0
c0102ccf:	6a 00                	push   $0x0
  pushl $35
c0102cd1:	6a 23                	push   $0x23
  jmp __alltraps
c0102cd3:	e9 a8 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cd8 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102cd8:	6a 00                	push   $0x0
  pushl $36
c0102cda:	6a 24                	push   $0x24
  jmp __alltraps
c0102cdc:	e9 9f fe ff ff       	jmp    c0102b80 <__alltraps>

c0102ce1 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102ce1:	6a 00                	push   $0x0
  pushl $37
c0102ce3:	6a 25                	push   $0x25
  jmp __alltraps
c0102ce5:	e9 96 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cea <vector38>:
.globl vector38
vector38:
  pushl $0
c0102cea:	6a 00                	push   $0x0
  pushl $38
c0102cec:	6a 26                	push   $0x26
  jmp __alltraps
c0102cee:	e9 8d fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cf3 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102cf3:	6a 00                	push   $0x0
  pushl $39
c0102cf5:	6a 27                	push   $0x27
  jmp __alltraps
c0102cf7:	e9 84 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102cfc <vector40>:
.globl vector40
vector40:
  pushl $0
c0102cfc:	6a 00                	push   $0x0
  pushl $40
c0102cfe:	6a 28                	push   $0x28
  jmp __alltraps
c0102d00:	e9 7b fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d05 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102d05:	6a 00                	push   $0x0
  pushl $41
c0102d07:	6a 29                	push   $0x29
  jmp __alltraps
c0102d09:	e9 72 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d0e <vector42>:
.globl vector42
vector42:
  pushl $0
c0102d0e:	6a 00                	push   $0x0
  pushl $42
c0102d10:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102d12:	e9 69 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d17 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102d17:	6a 00                	push   $0x0
  pushl $43
c0102d19:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102d1b:	e9 60 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d20 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102d20:	6a 00                	push   $0x0
  pushl $44
c0102d22:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102d24:	e9 57 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d29 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102d29:	6a 00                	push   $0x0
  pushl $45
c0102d2b:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102d2d:	e9 4e fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d32 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102d32:	6a 00                	push   $0x0
  pushl $46
c0102d34:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d36:	e9 45 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d3b <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d3b:	6a 00                	push   $0x0
  pushl $47
c0102d3d:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d3f:	e9 3c fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d44 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d44:	6a 00                	push   $0x0
  pushl $48
c0102d46:	6a 30                	push   $0x30
  jmp __alltraps
c0102d48:	e9 33 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d4d <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d4d:	6a 00                	push   $0x0
  pushl $49
c0102d4f:	6a 31                	push   $0x31
  jmp __alltraps
c0102d51:	e9 2a fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d56 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d56:	6a 00                	push   $0x0
  pushl $50
c0102d58:	6a 32                	push   $0x32
  jmp __alltraps
c0102d5a:	e9 21 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d5f <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d5f:	6a 00                	push   $0x0
  pushl $51
c0102d61:	6a 33                	push   $0x33
  jmp __alltraps
c0102d63:	e9 18 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d68 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d68:	6a 00                	push   $0x0
  pushl $52
c0102d6a:	6a 34                	push   $0x34
  jmp __alltraps
c0102d6c:	e9 0f fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d71 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d71:	6a 00                	push   $0x0
  pushl $53
c0102d73:	6a 35                	push   $0x35
  jmp __alltraps
c0102d75:	e9 06 fe ff ff       	jmp    c0102b80 <__alltraps>

c0102d7a <vector54>:
.globl vector54
vector54:
  pushl $0
c0102d7a:	6a 00                	push   $0x0
  pushl $54
c0102d7c:	6a 36                	push   $0x36
  jmp __alltraps
c0102d7e:	e9 fd fd ff ff       	jmp    c0102b80 <__alltraps>

c0102d83 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102d83:	6a 00                	push   $0x0
  pushl $55
c0102d85:	6a 37                	push   $0x37
  jmp __alltraps
c0102d87:	e9 f4 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102d8c <vector56>:
.globl vector56
vector56:
  pushl $0
c0102d8c:	6a 00                	push   $0x0
  pushl $56
c0102d8e:	6a 38                	push   $0x38
  jmp __alltraps
c0102d90:	e9 eb fd ff ff       	jmp    c0102b80 <__alltraps>

c0102d95 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102d95:	6a 00                	push   $0x0
  pushl $57
c0102d97:	6a 39                	push   $0x39
  jmp __alltraps
c0102d99:	e9 e2 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102d9e <vector58>:
.globl vector58
vector58:
  pushl $0
c0102d9e:	6a 00                	push   $0x0
  pushl $58
c0102da0:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102da2:	e9 d9 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102da7 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102da7:	6a 00                	push   $0x0
  pushl $59
c0102da9:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102dab:	e9 d0 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102db0 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102db0:	6a 00                	push   $0x0
  pushl $60
c0102db2:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102db4:	e9 c7 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102db9 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102db9:	6a 00                	push   $0x0
  pushl $61
c0102dbb:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102dbd:	e9 be fd ff ff       	jmp    c0102b80 <__alltraps>

c0102dc2 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102dc2:	6a 00                	push   $0x0
  pushl $62
c0102dc4:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102dc6:	e9 b5 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102dcb <vector63>:
.globl vector63
vector63:
  pushl $0
c0102dcb:	6a 00                	push   $0x0
  pushl $63
c0102dcd:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102dcf:	e9 ac fd ff ff       	jmp    c0102b80 <__alltraps>

c0102dd4 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102dd4:	6a 00                	push   $0x0
  pushl $64
c0102dd6:	6a 40                	push   $0x40
  jmp __alltraps
c0102dd8:	e9 a3 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102ddd <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ddd:	6a 00                	push   $0x0
  pushl $65
c0102ddf:	6a 41                	push   $0x41
  jmp __alltraps
c0102de1:	e9 9a fd ff ff       	jmp    c0102b80 <__alltraps>

c0102de6 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102de6:	6a 00                	push   $0x0
  pushl $66
c0102de8:	6a 42                	push   $0x42
  jmp __alltraps
c0102dea:	e9 91 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102def <vector67>:
.globl vector67
vector67:
  pushl $0
c0102def:	6a 00                	push   $0x0
  pushl $67
c0102df1:	6a 43                	push   $0x43
  jmp __alltraps
c0102df3:	e9 88 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102df8 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102df8:	6a 00                	push   $0x0
  pushl $68
c0102dfa:	6a 44                	push   $0x44
  jmp __alltraps
c0102dfc:	e9 7f fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e01 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102e01:	6a 00                	push   $0x0
  pushl $69
c0102e03:	6a 45                	push   $0x45
  jmp __alltraps
c0102e05:	e9 76 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e0a <vector70>:
.globl vector70
vector70:
  pushl $0
c0102e0a:	6a 00                	push   $0x0
  pushl $70
c0102e0c:	6a 46                	push   $0x46
  jmp __alltraps
c0102e0e:	e9 6d fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e13 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102e13:	6a 00                	push   $0x0
  pushl $71
c0102e15:	6a 47                	push   $0x47
  jmp __alltraps
c0102e17:	e9 64 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e1c <vector72>:
.globl vector72
vector72:
  pushl $0
c0102e1c:	6a 00                	push   $0x0
  pushl $72
c0102e1e:	6a 48                	push   $0x48
  jmp __alltraps
c0102e20:	e9 5b fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e25 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102e25:	6a 00                	push   $0x0
  pushl $73
c0102e27:	6a 49                	push   $0x49
  jmp __alltraps
c0102e29:	e9 52 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e2e <vector74>:
.globl vector74
vector74:
  pushl $0
c0102e2e:	6a 00                	push   $0x0
  pushl $74
c0102e30:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102e32:	e9 49 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e37 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e37:	6a 00                	push   $0x0
  pushl $75
c0102e39:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e3b:	e9 40 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e40 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e40:	6a 00                	push   $0x0
  pushl $76
c0102e42:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e44:	e9 37 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e49 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e49:	6a 00                	push   $0x0
  pushl $77
c0102e4b:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e4d:	e9 2e fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e52 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e52:	6a 00                	push   $0x0
  pushl $78
c0102e54:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e56:	e9 25 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e5b <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e5b:	6a 00                	push   $0x0
  pushl $79
c0102e5d:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e5f:	e9 1c fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e64 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e64:	6a 00                	push   $0x0
  pushl $80
c0102e66:	6a 50                	push   $0x50
  jmp __alltraps
c0102e68:	e9 13 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e6d <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e6d:	6a 00                	push   $0x0
  pushl $81
c0102e6f:	6a 51                	push   $0x51
  jmp __alltraps
c0102e71:	e9 0a fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e76 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e76:	6a 00                	push   $0x0
  pushl $82
c0102e78:	6a 52                	push   $0x52
  jmp __alltraps
c0102e7a:	e9 01 fd ff ff       	jmp    c0102b80 <__alltraps>

c0102e7f <vector83>:
.globl vector83
vector83:
  pushl $0
c0102e7f:	6a 00                	push   $0x0
  pushl $83
c0102e81:	6a 53                	push   $0x53
  jmp __alltraps
c0102e83:	e9 f8 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102e88 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102e88:	6a 00                	push   $0x0
  pushl $84
c0102e8a:	6a 54                	push   $0x54
  jmp __alltraps
c0102e8c:	e9 ef fc ff ff       	jmp    c0102b80 <__alltraps>

c0102e91 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102e91:	6a 00                	push   $0x0
  pushl $85
c0102e93:	6a 55                	push   $0x55
  jmp __alltraps
c0102e95:	e9 e6 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102e9a <vector86>:
.globl vector86
vector86:
  pushl $0
c0102e9a:	6a 00                	push   $0x0
  pushl $86
c0102e9c:	6a 56                	push   $0x56
  jmp __alltraps
c0102e9e:	e9 dd fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ea3 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ea3:	6a 00                	push   $0x0
  pushl $87
c0102ea5:	6a 57                	push   $0x57
  jmp __alltraps
c0102ea7:	e9 d4 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102eac <vector88>:
.globl vector88
vector88:
  pushl $0
c0102eac:	6a 00                	push   $0x0
  pushl $88
c0102eae:	6a 58                	push   $0x58
  jmp __alltraps
c0102eb0:	e9 cb fc ff ff       	jmp    c0102b80 <__alltraps>

c0102eb5 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102eb5:	6a 00                	push   $0x0
  pushl $89
c0102eb7:	6a 59                	push   $0x59
  jmp __alltraps
c0102eb9:	e9 c2 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ebe <vector90>:
.globl vector90
vector90:
  pushl $0
c0102ebe:	6a 00                	push   $0x0
  pushl $90
c0102ec0:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102ec2:	e9 b9 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ec7 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ec7:	6a 00                	push   $0x0
  pushl $91
c0102ec9:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ecb:	e9 b0 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ed0 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102ed0:	6a 00                	push   $0x0
  pushl $92
c0102ed2:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102ed4:	e9 a7 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ed9 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ed9:	6a 00                	push   $0x0
  pushl $93
c0102edb:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102edd:	e9 9e fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ee2 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102ee2:	6a 00                	push   $0x0
  pushl $94
c0102ee4:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102ee6:	e9 95 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102eeb <vector95>:
.globl vector95
vector95:
  pushl $0
c0102eeb:	6a 00                	push   $0x0
  pushl $95
c0102eed:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102eef:	e9 8c fc ff ff       	jmp    c0102b80 <__alltraps>

c0102ef4 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102ef4:	6a 00                	push   $0x0
  pushl $96
c0102ef6:	6a 60                	push   $0x60
  jmp __alltraps
c0102ef8:	e9 83 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102efd <vector97>:
.globl vector97
vector97:
  pushl $0
c0102efd:	6a 00                	push   $0x0
  pushl $97
c0102eff:	6a 61                	push   $0x61
  jmp __alltraps
c0102f01:	e9 7a fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f06 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102f06:	6a 00                	push   $0x0
  pushl $98
c0102f08:	6a 62                	push   $0x62
  jmp __alltraps
c0102f0a:	e9 71 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f0f <vector99>:
.globl vector99
vector99:
  pushl $0
c0102f0f:	6a 00                	push   $0x0
  pushl $99
c0102f11:	6a 63                	push   $0x63
  jmp __alltraps
c0102f13:	e9 68 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f18 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102f18:	6a 00                	push   $0x0
  pushl $100
c0102f1a:	6a 64                	push   $0x64
  jmp __alltraps
c0102f1c:	e9 5f fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f21 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102f21:	6a 00                	push   $0x0
  pushl $101
c0102f23:	6a 65                	push   $0x65
  jmp __alltraps
c0102f25:	e9 56 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f2a <vector102>:
.globl vector102
vector102:
  pushl $0
c0102f2a:	6a 00                	push   $0x0
  pushl $102
c0102f2c:	6a 66                	push   $0x66
  jmp __alltraps
c0102f2e:	e9 4d fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f33 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102f33:	6a 00                	push   $0x0
  pushl $103
c0102f35:	6a 67                	push   $0x67
  jmp __alltraps
c0102f37:	e9 44 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f3c <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f3c:	6a 00                	push   $0x0
  pushl $104
c0102f3e:	6a 68                	push   $0x68
  jmp __alltraps
c0102f40:	e9 3b fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f45 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f45:	6a 00                	push   $0x0
  pushl $105
c0102f47:	6a 69                	push   $0x69
  jmp __alltraps
c0102f49:	e9 32 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f4e <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f4e:	6a 00                	push   $0x0
  pushl $106
c0102f50:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f52:	e9 29 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f57 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f57:	6a 00                	push   $0x0
  pushl $107
c0102f59:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f5b:	e9 20 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f60 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f60:	6a 00                	push   $0x0
  pushl $108
c0102f62:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f64:	e9 17 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f69 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f69:	6a 00                	push   $0x0
  pushl $109
c0102f6b:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f6d:	e9 0e fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f72 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f72:	6a 00                	push   $0x0
  pushl $110
c0102f74:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f76:	e9 05 fc ff ff       	jmp    c0102b80 <__alltraps>

c0102f7b <vector111>:
.globl vector111
vector111:
  pushl $0
c0102f7b:	6a 00                	push   $0x0
  pushl $111
c0102f7d:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102f7f:	e9 fc fb ff ff       	jmp    c0102b80 <__alltraps>

c0102f84 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102f84:	6a 00                	push   $0x0
  pushl $112
c0102f86:	6a 70                	push   $0x70
  jmp __alltraps
c0102f88:	e9 f3 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102f8d <vector113>:
.globl vector113
vector113:
  pushl $0
c0102f8d:	6a 00                	push   $0x0
  pushl $113
c0102f8f:	6a 71                	push   $0x71
  jmp __alltraps
c0102f91:	e9 ea fb ff ff       	jmp    c0102b80 <__alltraps>

c0102f96 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102f96:	6a 00                	push   $0x0
  pushl $114
c0102f98:	6a 72                	push   $0x72
  jmp __alltraps
c0102f9a:	e9 e1 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102f9f <vector115>:
.globl vector115
vector115:
  pushl $0
c0102f9f:	6a 00                	push   $0x0
  pushl $115
c0102fa1:	6a 73                	push   $0x73
  jmp __alltraps
c0102fa3:	e9 d8 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fa8 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102fa8:	6a 00                	push   $0x0
  pushl $116
c0102faa:	6a 74                	push   $0x74
  jmp __alltraps
c0102fac:	e9 cf fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fb1 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102fb1:	6a 00                	push   $0x0
  pushl $117
c0102fb3:	6a 75                	push   $0x75
  jmp __alltraps
c0102fb5:	e9 c6 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fba <vector118>:
.globl vector118
vector118:
  pushl $0
c0102fba:	6a 00                	push   $0x0
  pushl $118
c0102fbc:	6a 76                	push   $0x76
  jmp __alltraps
c0102fbe:	e9 bd fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fc3 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102fc3:	6a 00                	push   $0x0
  pushl $119
c0102fc5:	6a 77                	push   $0x77
  jmp __alltraps
c0102fc7:	e9 b4 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fcc <vector120>:
.globl vector120
vector120:
  pushl $0
c0102fcc:	6a 00                	push   $0x0
  pushl $120
c0102fce:	6a 78                	push   $0x78
  jmp __alltraps
c0102fd0:	e9 ab fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fd5 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102fd5:	6a 00                	push   $0x0
  pushl $121
c0102fd7:	6a 79                	push   $0x79
  jmp __alltraps
c0102fd9:	e9 a2 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fde <vector122>:
.globl vector122
vector122:
  pushl $0
c0102fde:	6a 00                	push   $0x0
  pushl $122
c0102fe0:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102fe2:	e9 99 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102fe7 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102fe7:	6a 00                	push   $0x0
  pushl $123
c0102fe9:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102feb:	e9 90 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102ff0 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ff0:	6a 00                	push   $0x0
  pushl $124
c0102ff2:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ff4:	e9 87 fb ff ff       	jmp    c0102b80 <__alltraps>

c0102ff9 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102ff9:	6a 00                	push   $0x0
  pushl $125
c0102ffb:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ffd:	e9 7e fb ff ff       	jmp    c0102b80 <__alltraps>

c0103002 <vector126>:
.globl vector126
vector126:
  pushl $0
c0103002:	6a 00                	push   $0x0
  pushl $126
c0103004:	6a 7e                	push   $0x7e
  jmp __alltraps
c0103006:	e9 75 fb ff ff       	jmp    c0102b80 <__alltraps>

c010300b <vector127>:
.globl vector127
vector127:
  pushl $0
c010300b:	6a 00                	push   $0x0
  pushl $127
c010300d:	6a 7f                	push   $0x7f
  jmp __alltraps
c010300f:	e9 6c fb ff ff       	jmp    c0102b80 <__alltraps>

c0103014 <vector128>:
.globl vector128
vector128:
  pushl $0
c0103014:	6a 00                	push   $0x0
  pushl $128
c0103016:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010301b:	e9 60 fb ff ff       	jmp    c0102b80 <__alltraps>

c0103020 <vector129>:
.globl vector129
vector129:
  pushl $0
c0103020:	6a 00                	push   $0x0
  pushl $129
c0103022:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0103027:	e9 54 fb ff ff       	jmp    c0102b80 <__alltraps>

c010302c <vector130>:
.globl vector130
vector130:
  pushl $0
c010302c:	6a 00                	push   $0x0
  pushl $130
c010302e:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0103033:	e9 48 fb ff ff       	jmp    c0102b80 <__alltraps>

c0103038 <vector131>:
.globl vector131
vector131:
  pushl $0
c0103038:	6a 00                	push   $0x0
  pushl $131
c010303a:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010303f:	e9 3c fb ff ff       	jmp    c0102b80 <__alltraps>

c0103044 <vector132>:
.globl vector132
vector132:
  pushl $0
c0103044:	6a 00                	push   $0x0
  pushl $132
c0103046:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010304b:	e9 30 fb ff ff       	jmp    c0102b80 <__alltraps>

c0103050 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103050:	6a 00                	push   $0x0
  pushl $133
c0103052:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103057:	e9 24 fb ff ff       	jmp    c0102b80 <__alltraps>

c010305c <vector134>:
.globl vector134
vector134:
  pushl $0
c010305c:	6a 00                	push   $0x0
  pushl $134
c010305e:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0103063:	e9 18 fb ff ff       	jmp    c0102b80 <__alltraps>

c0103068 <vector135>:
.globl vector135
vector135:
  pushl $0
c0103068:	6a 00                	push   $0x0
  pushl $135
c010306a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010306f:	e9 0c fb ff ff       	jmp    c0102b80 <__alltraps>

c0103074 <vector136>:
.globl vector136
vector136:
  pushl $0
c0103074:	6a 00                	push   $0x0
  pushl $136
c0103076:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010307b:	e9 00 fb ff ff       	jmp    c0102b80 <__alltraps>

c0103080 <vector137>:
.globl vector137
vector137:
  pushl $0
c0103080:	6a 00                	push   $0x0
  pushl $137
c0103082:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103087:	e9 f4 fa ff ff       	jmp    c0102b80 <__alltraps>

c010308c <vector138>:
.globl vector138
vector138:
  pushl $0
c010308c:	6a 00                	push   $0x0
  pushl $138
c010308e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0103093:	e9 e8 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103098 <vector139>:
.globl vector139
vector139:
  pushl $0
c0103098:	6a 00                	push   $0x0
  pushl $139
c010309a:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010309f:	e9 dc fa ff ff       	jmp    c0102b80 <__alltraps>

c01030a4 <vector140>:
.globl vector140
vector140:
  pushl $0
c01030a4:	6a 00                	push   $0x0
  pushl $140
c01030a6:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01030ab:	e9 d0 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030b0 <vector141>:
.globl vector141
vector141:
  pushl $0
c01030b0:	6a 00                	push   $0x0
  pushl $141
c01030b2:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01030b7:	e9 c4 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030bc <vector142>:
.globl vector142
vector142:
  pushl $0
c01030bc:	6a 00                	push   $0x0
  pushl $142
c01030be:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01030c3:	e9 b8 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030c8 <vector143>:
.globl vector143
vector143:
  pushl $0
c01030c8:	6a 00                	push   $0x0
  pushl $143
c01030ca:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01030cf:	e9 ac fa ff ff       	jmp    c0102b80 <__alltraps>

c01030d4 <vector144>:
.globl vector144
vector144:
  pushl $0
c01030d4:	6a 00                	push   $0x0
  pushl $144
c01030d6:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01030db:	e9 a0 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030e0 <vector145>:
.globl vector145
vector145:
  pushl $0
c01030e0:	6a 00                	push   $0x0
  pushl $145
c01030e2:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01030e7:	e9 94 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030ec <vector146>:
.globl vector146
vector146:
  pushl $0
c01030ec:	6a 00                	push   $0x0
  pushl $146
c01030ee:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01030f3:	e9 88 fa ff ff       	jmp    c0102b80 <__alltraps>

c01030f8 <vector147>:
.globl vector147
vector147:
  pushl $0
c01030f8:	6a 00                	push   $0x0
  pushl $147
c01030fa:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01030ff:	e9 7c fa ff ff       	jmp    c0102b80 <__alltraps>

c0103104 <vector148>:
.globl vector148
vector148:
  pushl $0
c0103104:	6a 00                	push   $0x0
  pushl $148
c0103106:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010310b:	e9 70 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103110 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103110:	6a 00                	push   $0x0
  pushl $149
c0103112:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0103117:	e9 64 fa ff ff       	jmp    c0102b80 <__alltraps>

c010311c <vector150>:
.globl vector150
vector150:
  pushl $0
c010311c:	6a 00                	push   $0x0
  pushl $150
c010311e:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103123:	e9 58 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103128 <vector151>:
.globl vector151
vector151:
  pushl $0
c0103128:	6a 00                	push   $0x0
  pushl $151
c010312a:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010312f:	e9 4c fa ff ff       	jmp    c0102b80 <__alltraps>

c0103134 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103134:	6a 00                	push   $0x0
  pushl $152
c0103136:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010313b:	e9 40 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103140 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103140:	6a 00                	push   $0x0
  pushl $153
c0103142:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103147:	e9 34 fa ff ff       	jmp    c0102b80 <__alltraps>

c010314c <vector154>:
.globl vector154
vector154:
  pushl $0
c010314c:	6a 00                	push   $0x0
  pushl $154
c010314e:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103153:	e9 28 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103158 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103158:	6a 00                	push   $0x0
  pushl $155
c010315a:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010315f:	e9 1c fa ff ff       	jmp    c0102b80 <__alltraps>

c0103164 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103164:	6a 00                	push   $0x0
  pushl $156
c0103166:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010316b:	e9 10 fa ff ff       	jmp    c0102b80 <__alltraps>

c0103170 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103170:	6a 00                	push   $0x0
  pushl $157
c0103172:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103177:	e9 04 fa ff ff       	jmp    c0102b80 <__alltraps>

c010317c <vector158>:
.globl vector158
vector158:
  pushl $0
c010317c:	6a 00                	push   $0x0
  pushl $158
c010317e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103183:	e9 f8 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103188 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103188:	6a 00                	push   $0x0
  pushl $159
c010318a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010318f:	e9 ec f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103194 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103194:	6a 00                	push   $0x0
  pushl $160
c0103196:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010319b:	e9 e0 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031a0 <vector161>:
.globl vector161
vector161:
  pushl $0
c01031a0:	6a 00                	push   $0x0
  pushl $161
c01031a2:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01031a7:	e9 d4 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031ac <vector162>:
.globl vector162
vector162:
  pushl $0
c01031ac:	6a 00                	push   $0x0
  pushl $162
c01031ae:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01031b3:	e9 c8 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031b8 <vector163>:
.globl vector163
vector163:
  pushl $0
c01031b8:	6a 00                	push   $0x0
  pushl $163
c01031ba:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01031bf:	e9 bc f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031c4 <vector164>:
.globl vector164
vector164:
  pushl $0
c01031c4:	6a 00                	push   $0x0
  pushl $164
c01031c6:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01031cb:	e9 b0 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031d0 <vector165>:
.globl vector165
vector165:
  pushl $0
c01031d0:	6a 00                	push   $0x0
  pushl $165
c01031d2:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031d7:	e9 a4 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031dc <vector166>:
.globl vector166
vector166:
  pushl $0
c01031dc:	6a 00                	push   $0x0
  pushl $166
c01031de:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01031e3:	e9 98 f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031e8 <vector167>:
.globl vector167
vector167:
  pushl $0
c01031e8:	6a 00                	push   $0x0
  pushl $167
c01031ea:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01031ef:	e9 8c f9 ff ff       	jmp    c0102b80 <__alltraps>

c01031f4 <vector168>:
.globl vector168
vector168:
  pushl $0
c01031f4:	6a 00                	push   $0x0
  pushl $168
c01031f6:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01031fb:	e9 80 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103200 <vector169>:
.globl vector169
vector169:
  pushl $0
c0103200:	6a 00                	push   $0x0
  pushl $169
c0103202:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0103207:	e9 74 f9 ff ff       	jmp    c0102b80 <__alltraps>

c010320c <vector170>:
.globl vector170
vector170:
  pushl $0
c010320c:	6a 00                	push   $0x0
  pushl $170
c010320e:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0103213:	e9 68 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103218 <vector171>:
.globl vector171
vector171:
  pushl $0
c0103218:	6a 00                	push   $0x0
  pushl $171
c010321a:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010321f:	e9 5c f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103224 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103224:	6a 00                	push   $0x0
  pushl $172
c0103226:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010322b:	e9 50 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103230 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103230:	6a 00                	push   $0x0
  pushl $173
c0103232:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103237:	e9 44 f9 ff ff       	jmp    c0102b80 <__alltraps>

c010323c <vector174>:
.globl vector174
vector174:
  pushl $0
c010323c:	6a 00                	push   $0x0
  pushl $174
c010323e:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103243:	e9 38 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103248 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103248:	6a 00                	push   $0x0
  pushl $175
c010324a:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010324f:	e9 2c f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103254 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103254:	6a 00                	push   $0x0
  pushl $176
c0103256:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010325b:	e9 20 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103260 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103260:	6a 00                	push   $0x0
  pushl $177
c0103262:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103267:	e9 14 f9 ff ff       	jmp    c0102b80 <__alltraps>

c010326c <vector178>:
.globl vector178
vector178:
  pushl $0
c010326c:	6a 00                	push   $0x0
  pushl $178
c010326e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103273:	e9 08 f9 ff ff       	jmp    c0102b80 <__alltraps>

c0103278 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103278:	6a 00                	push   $0x0
  pushl $179
c010327a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010327f:	e9 fc f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103284 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103284:	6a 00                	push   $0x0
  pushl $180
c0103286:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010328b:	e9 f0 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103290 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103290:	6a 00                	push   $0x0
  pushl $181
c0103292:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103297:	e9 e4 f8 ff ff       	jmp    c0102b80 <__alltraps>

c010329c <vector182>:
.globl vector182
vector182:
  pushl $0
c010329c:	6a 00                	push   $0x0
  pushl $182
c010329e:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01032a3:	e9 d8 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032a8 <vector183>:
.globl vector183
vector183:
  pushl $0
c01032a8:	6a 00                	push   $0x0
  pushl $183
c01032aa:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01032af:	e9 cc f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032b4 <vector184>:
.globl vector184
vector184:
  pushl $0
c01032b4:	6a 00                	push   $0x0
  pushl $184
c01032b6:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01032bb:	e9 c0 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032c0 <vector185>:
.globl vector185
vector185:
  pushl $0
c01032c0:	6a 00                	push   $0x0
  pushl $185
c01032c2:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01032c7:	e9 b4 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032cc <vector186>:
.globl vector186
vector186:
  pushl $0
c01032cc:	6a 00                	push   $0x0
  pushl $186
c01032ce:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01032d3:	e9 a8 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032d8 <vector187>:
.globl vector187
vector187:
  pushl $0
c01032d8:	6a 00                	push   $0x0
  pushl $187
c01032da:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01032df:	e9 9c f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032e4 <vector188>:
.globl vector188
vector188:
  pushl $0
c01032e4:	6a 00                	push   $0x0
  pushl $188
c01032e6:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01032eb:	e9 90 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032f0 <vector189>:
.globl vector189
vector189:
  pushl $0
c01032f0:	6a 00                	push   $0x0
  pushl $189
c01032f2:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01032f7:	e9 84 f8 ff ff       	jmp    c0102b80 <__alltraps>

c01032fc <vector190>:
.globl vector190
vector190:
  pushl $0
c01032fc:	6a 00                	push   $0x0
  pushl $190
c01032fe:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0103303:	e9 78 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103308 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103308:	6a 00                	push   $0x0
  pushl $191
c010330a:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010330f:	e9 6c f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103314 <vector192>:
.globl vector192
vector192:
  pushl $0
c0103314:	6a 00                	push   $0x0
  pushl $192
c0103316:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010331b:	e9 60 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103320 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103320:	6a 00                	push   $0x0
  pushl $193
c0103322:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103327:	e9 54 f8 ff ff       	jmp    c0102b80 <__alltraps>

c010332c <vector194>:
.globl vector194
vector194:
  pushl $0
c010332c:	6a 00                	push   $0x0
  pushl $194
c010332e:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103333:	e9 48 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103338 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103338:	6a 00                	push   $0x0
  pushl $195
c010333a:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010333f:	e9 3c f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103344 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103344:	6a 00                	push   $0x0
  pushl $196
c0103346:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010334b:	e9 30 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103350 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103350:	6a 00                	push   $0x0
  pushl $197
c0103352:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103357:	e9 24 f8 ff ff       	jmp    c0102b80 <__alltraps>

c010335c <vector198>:
.globl vector198
vector198:
  pushl $0
c010335c:	6a 00                	push   $0x0
  pushl $198
c010335e:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103363:	e9 18 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103368 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103368:	6a 00                	push   $0x0
  pushl $199
c010336a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010336f:	e9 0c f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103374 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103374:	6a 00                	push   $0x0
  pushl $200
c0103376:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010337b:	e9 00 f8 ff ff       	jmp    c0102b80 <__alltraps>

c0103380 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103380:	6a 00                	push   $0x0
  pushl $201
c0103382:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103387:	e9 f4 f7 ff ff       	jmp    c0102b80 <__alltraps>

c010338c <vector202>:
.globl vector202
vector202:
  pushl $0
c010338c:	6a 00                	push   $0x0
  pushl $202
c010338e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103393:	e9 e8 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103398 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103398:	6a 00                	push   $0x0
  pushl $203
c010339a:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010339f:	e9 dc f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033a4 <vector204>:
.globl vector204
vector204:
  pushl $0
c01033a4:	6a 00                	push   $0x0
  pushl $204
c01033a6:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01033ab:	e9 d0 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033b0 <vector205>:
.globl vector205
vector205:
  pushl $0
c01033b0:	6a 00                	push   $0x0
  pushl $205
c01033b2:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01033b7:	e9 c4 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033bc <vector206>:
.globl vector206
vector206:
  pushl $0
c01033bc:	6a 00                	push   $0x0
  pushl $206
c01033be:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01033c3:	e9 b8 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033c8 <vector207>:
.globl vector207
vector207:
  pushl $0
c01033c8:	6a 00                	push   $0x0
  pushl $207
c01033ca:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01033cf:	e9 ac f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033d4 <vector208>:
.globl vector208
vector208:
  pushl $0
c01033d4:	6a 00                	push   $0x0
  pushl $208
c01033d6:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01033db:	e9 a0 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033e0 <vector209>:
.globl vector209
vector209:
  pushl $0
c01033e0:	6a 00                	push   $0x0
  pushl $209
c01033e2:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01033e7:	e9 94 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033ec <vector210>:
.globl vector210
vector210:
  pushl $0
c01033ec:	6a 00                	push   $0x0
  pushl $210
c01033ee:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01033f3:	e9 88 f7 ff ff       	jmp    c0102b80 <__alltraps>

c01033f8 <vector211>:
.globl vector211
vector211:
  pushl $0
c01033f8:	6a 00                	push   $0x0
  pushl $211
c01033fa:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01033ff:	e9 7c f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103404 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103404:	6a 00                	push   $0x0
  pushl $212
c0103406:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010340b:	e9 70 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103410 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103410:	6a 00                	push   $0x0
  pushl $213
c0103412:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103417:	e9 64 f7 ff ff       	jmp    c0102b80 <__alltraps>

c010341c <vector214>:
.globl vector214
vector214:
  pushl $0
c010341c:	6a 00                	push   $0x0
  pushl $214
c010341e:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103423:	e9 58 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103428 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103428:	6a 00                	push   $0x0
  pushl $215
c010342a:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010342f:	e9 4c f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103434 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103434:	6a 00                	push   $0x0
  pushl $216
c0103436:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010343b:	e9 40 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103440 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103440:	6a 00                	push   $0x0
  pushl $217
c0103442:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103447:	e9 34 f7 ff ff       	jmp    c0102b80 <__alltraps>

c010344c <vector218>:
.globl vector218
vector218:
  pushl $0
c010344c:	6a 00                	push   $0x0
  pushl $218
c010344e:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103453:	e9 28 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103458 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103458:	6a 00                	push   $0x0
  pushl $219
c010345a:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010345f:	e9 1c f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103464 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103464:	6a 00                	push   $0x0
  pushl $220
c0103466:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010346b:	e9 10 f7 ff ff       	jmp    c0102b80 <__alltraps>

c0103470 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103470:	6a 00                	push   $0x0
  pushl $221
c0103472:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103477:	e9 04 f7 ff ff       	jmp    c0102b80 <__alltraps>

c010347c <vector222>:
.globl vector222
vector222:
  pushl $0
c010347c:	6a 00                	push   $0x0
  pushl $222
c010347e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103483:	e9 f8 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103488 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103488:	6a 00                	push   $0x0
  pushl $223
c010348a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010348f:	e9 ec f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103494 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103494:	6a 00                	push   $0x0
  pushl $224
c0103496:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010349b:	e9 e0 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034a0 <vector225>:
.globl vector225
vector225:
  pushl $0
c01034a0:	6a 00                	push   $0x0
  pushl $225
c01034a2:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01034a7:	e9 d4 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034ac <vector226>:
.globl vector226
vector226:
  pushl $0
c01034ac:	6a 00                	push   $0x0
  pushl $226
c01034ae:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01034b3:	e9 c8 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034b8 <vector227>:
.globl vector227
vector227:
  pushl $0
c01034b8:	6a 00                	push   $0x0
  pushl $227
c01034ba:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01034bf:	e9 bc f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034c4 <vector228>:
.globl vector228
vector228:
  pushl $0
c01034c4:	6a 00                	push   $0x0
  pushl $228
c01034c6:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01034cb:	e9 b0 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034d0 <vector229>:
.globl vector229
vector229:
  pushl $0
c01034d0:	6a 00                	push   $0x0
  pushl $229
c01034d2:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034d7:	e9 a4 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034dc <vector230>:
.globl vector230
vector230:
  pushl $0
c01034dc:	6a 00                	push   $0x0
  pushl $230
c01034de:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01034e3:	e9 98 f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034e8 <vector231>:
.globl vector231
vector231:
  pushl $0
c01034e8:	6a 00                	push   $0x0
  pushl $231
c01034ea:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01034ef:	e9 8c f6 ff ff       	jmp    c0102b80 <__alltraps>

c01034f4 <vector232>:
.globl vector232
vector232:
  pushl $0
c01034f4:	6a 00                	push   $0x0
  pushl $232
c01034f6:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01034fb:	e9 80 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103500 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103500:	6a 00                	push   $0x0
  pushl $233
c0103502:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103507:	e9 74 f6 ff ff       	jmp    c0102b80 <__alltraps>

c010350c <vector234>:
.globl vector234
vector234:
  pushl $0
c010350c:	6a 00                	push   $0x0
  pushl $234
c010350e:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103513:	e9 68 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103518 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103518:	6a 00                	push   $0x0
  pushl $235
c010351a:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010351f:	e9 5c f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103524 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103524:	6a 00                	push   $0x0
  pushl $236
c0103526:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010352b:	e9 50 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103530 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103530:	6a 00                	push   $0x0
  pushl $237
c0103532:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103537:	e9 44 f6 ff ff       	jmp    c0102b80 <__alltraps>

c010353c <vector238>:
.globl vector238
vector238:
  pushl $0
c010353c:	6a 00                	push   $0x0
  pushl $238
c010353e:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103543:	e9 38 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103548 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103548:	6a 00                	push   $0x0
  pushl $239
c010354a:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010354f:	e9 2c f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103554 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103554:	6a 00                	push   $0x0
  pushl $240
c0103556:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010355b:	e9 20 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103560 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103560:	6a 00                	push   $0x0
  pushl $241
c0103562:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103567:	e9 14 f6 ff ff       	jmp    c0102b80 <__alltraps>

c010356c <vector242>:
.globl vector242
vector242:
  pushl $0
c010356c:	6a 00                	push   $0x0
  pushl $242
c010356e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103573:	e9 08 f6 ff ff       	jmp    c0102b80 <__alltraps>

c0103578 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103578:	6a 00                	push   $0x0
  pushl $243
c010357a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010357f:	e9 fc f5 ff ff       	jmp    c0102b80 <__alltraps>

c0103584 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103584:	6a 00                	push   $0x0
  pushl $244
c0103586:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010358b:	e9 f0 f5 ff ff       	jmp    c0102b80 <__alltraps>

c0103590 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103590:	6a 00                	push   $0x0
  pushl $245
c0103592:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103597:	e9 e4 f5 ff ff       	jmp    c0102b80 <__alltraps>

c010359c <vector246>:
.globl vector246
vector246:
  pushl $0
c010359c:	6a 00                	push   $0x0
  pushl $246
c010359e:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01035a3:	e9 d8 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035a8 <vector247>:
.globl vector247
vector247:
  pushl $0
c01035a8:	6a 00                	push   $0x0
  pushl $247
c01035aa:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01035af:	e9 cc f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035b4 <vector248>:
.globl vector248
vector248:
  pushl $0
c01035b4:	6a 00                	push   $0x0
  pushl $248
c01035b6:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01035bb:	e9 c0 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035c0 <vector249>:
.globl vector249
vector249:
  pushl $0
c01035c0:	6a 00                	push   $0x0
  pushl $249
c01035c2:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01035c7:	e9 b4 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035cc <vector250>:
.globl vector250
vector250:
  pushl $0
c01035cc:	6a 00                	push   $0x0
  pushl $250
c01035ce:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01035d3:	e9 a8 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035d8 <vector251>:
.globl vector251
vector251:
  pushl $0
c01035d8:	6a 00                	push   $0x0
  pushl $251
c01035da:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01035df:	e9 9c f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035e4 <vector252>:
.globl vector252
vector252:
  pushl $0
c01035e4:	6a 00                	push   $0x0
  pushl $252
c01035e6:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01035eb:	e9 90 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035f0 <vector253>:
.globl vector253
vector253:
  pushl $0
c01035f0:	6a 00                	push   $0x0
  pushl $253
c01035f2:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01035f7:	e9 84 f5 ff ff       	jmp    c0102b80 <__alltraps>

c01035fc <vector254>:
.globl vector254
vector254:
  pushl $0
c01035fc:	6a 00                	push   $0x0
  pushl $254
c01035fe:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103603:	e9 78 f5 ff ff       	jmp    c0102b80 <__alltraps>

c0103608 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103608:	6a 00                	push   $0x0
  pushl $255
c010360a:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010360f:	e9 6c f5 ff ff       	jmp    c0102b80 <__alltraps>

c0103614 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103614:	55                   	push   %ebp
c0103615:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103617:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c010361d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103620:	29 d0                	sub    %edx,%eax
c0103622:	c1 f8 05             	sar    $0x5,%eax
}
c0103625:	5d                   	pop    %ebp
c0103626:	c3                   	ret    

c0103627 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103627:	55                   	push   %ebp
c0103628:	89 e5                	mov    %esp,%ebp
c010362a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010362d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103630:	89 04 24             	mov    %eax,(%esp)
c0103633:	e8 dc ff ff ff       	call   c0103614 <page2ppn>
c0103638:	c1 e0 0c             	shl    $0xc,%eax
}
c010363b:	89 ec                	mov    %ebp,%esp
c010363d:	5d                   	pop    %ebp
c010363e:	c3                   	ret    

c010363f <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010363f:	55                   	push   %ebp
c0103640:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103642:	8b 45 08             	mov    0x8(%ebp),%eax
c0103645:	8b 00                	mov    (%eax),%eax
}
c0103647:	5d                   	pop    %ebp
c0103648:	c3                   	ret    

c0103649 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103649:	55                   	push   %ebp
c010364a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010364c:	8b 45 08             	mov    0x8(%ebp),%eax
c010364f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103652:	89 10                	mov    %edx,(%eax)
}
c0103654:	90                   	nop
c0103655:	5d                   	pop    %ebp
c0103656:	c3                   	ret    

c0103657 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103657:	55                   	push   %ebp
c0103658:	89 e5                	mov    %esp,%ebp
c010365a:	83 ec 10             	sub    $0x10,%esp
c010365d:	c7 45 fc e4 6f 12 c0 	movl   $0xc0126fe4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103664:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103667:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010366a:	89 50 04             	mov    %edx,0x4(%eax)
c010366d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103670:	8b 50 04             	mov    0x4(%eax),%edx
c0103673:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103676:	89 10                	mov    %edx,(%eax)
}
c0103678:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103679:	c7 05 ec 6f 12 c0 00 	movl   $0x0,0xc0126fec
c0103680:	00 00 00 
}
c0103683:	90                   	nop
c0103684:	89 ec                	mov    %ebp,%esp
c0103686:	5d                   	pop    %ebp
c0103687:	c3                   	ret    

c0103688 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103688:	55                   	push   %ebp
c0103689:	89 e5                	mov    %esp,%ebp
c010368b:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010368e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103692:	75 24                	jne    c01036b8 <default_init_memmap+0x30>
c0103694:	c7 44 24 0c 90 9a 10 	movl   $0xc0109a90,0xc(%esp)
c010369b:	c0 
c010369c:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01036a3:	c0 
c01036a4:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01036ab:	00 
c01036ac:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01036b3:	e8 72 d6 ff ff       	call   c0100d2a <__panic>
    struct Page *p = base;
c01036b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01036bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01036be:	eb 7d                	jmp    c010373d <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01036c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036c3:	83 c0 04             	add    $0x4,%eax
c01036c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01036cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036d6:	0f a3 10             	bt     %edx,(%eax)
c01036d9:	19 c0                	sbb    %eax,%eax
c01036db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036de:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036e2:	0f 95 c0             	setne  %al
c01036e5:	0f b6 c0             	movzbl %al,%eax
c01036e8:	85 c0                	test   %eax,%eax
c01036ea:	75 24                	jne    c0103710 <default_init_memmap+0x88>
c01036ec:	c7 44 24 0c c1 9a 10 	movl   $0xc0109ac1,0xc(%esp)
c01036f3:	c0 
c01036f4:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01036fb:	c0 
c01036fc:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103703:	00 
c0103704:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010370b:	e8 1a d6 ff ff       	call   c0100d2a <__panic>
        p->flags = p->property = 0;
c0103710:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103713:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010371a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010371d:	8b 50 08             	mov    0x8(%eax),%edx
c0103720:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103723:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103726:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010372d:	00 
c010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103731:	89 04 24             	mov    %eax,(%esp)
c0103734:	e8 10 ff ff ff       	call   c0103649 <set_page_ref>
    for (; p != base + n; p ++) {
c0103739:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010373d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103740:	c1 e0 05             	shl    $0x5,%eax
c0103743:	89 c2                	mov    %eax,%edx
c0103745:	8b 45 08             	mov    0x8(%ebp),%eax
c0103748:	01 d0                	add    %edx,%eax
c010374a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010374d:	0f 85 6d ff ff ff    	jne    c01036c0 <default_init_memmap+0x38>
    }
    base->property = n;
c0103753:	8b 45 08             	mov    0x8(%ebp),%eax
c0103756:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103759:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010375c:	8b 45 08             	mov    0x8(%ebp),%eax
c010375f:	83 c0 04             	add    $0x4,%eax
c0103762:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103769:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010376c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010376f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103772:	0f ab 10             	bts    %edx,(%eax)
}
c0103775:	90                   	nop
    nr_free += n;
c0103776:	8b 15 ec 6f 12 c0    	mov    0xc0126fec,%edx
c010377c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010377f:	01 d0                	add    %edx,%eax
c0103781:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec
    list_add(&free_list, &(base->page_link));
c0103786:	8b 45 08             	mov    0x8(%ebp),%eax
c0103789:	83 c0 0c             	add    $0xc,%eax
c010378c:	c7 45 e4 e4 6f 12 c0 	movl   $0xc0126fe4,-0x1c(%ebp)
c0103793:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103796:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103799:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010379c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010379f:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01037a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037a5:	8b 40 04             	mov    0x4(%eax),%eax
c01037a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01037ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01037ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037b1:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01037b4:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01037b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01037bd:	89 10                	mov    %edx,(%eax)
c01037bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037c2:	8b 10                	mov    (%eax),%edx
c01037c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01037ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01037cd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01037d0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01037d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01037d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01037d9:	89 10                	mov    %edx,(%eax)
}
c01037db:	90                   	nop
}
c01037dc:	90                   	nop
}
c01037dd:	90                   	nop
}
c01037de:	90                   	nop
c01037df:	89 ec                	mov    %ebp,%esp
c01037e1:	5d                   	pop    %ebp
c01037e2:	c3                   	ret    

c01037e3 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01037e3:	55                   	push   %ebp
c01037e4:	89 e5                	mov    %esp,%ebp
c01037e6:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01037e9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037ed:	75 24                	jne    c0103813 <default_alloc_pages+0x30>
c01037ef:	c7 44 24 0c 90 9a 10 	movl   $0xc0109a90,0xc(%esp)
c01037f6:	c0 
c01037f7:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01037fe:	c0 
c01037ff:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103806:	00 
c0103807:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010380e:	e8 17 d5 ff ff       	call   c0100d2a <__panic>
    if (n > nr_free) {
c0103813:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0103818:	39 45 08             	cmp    %eax,0x8(%ebp)
c010381b:	76 0a                	jbe    c0103827 <default_alloc_pages+0x44>
        return NULL;
c010381d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103822:	e9 47 01 00 00       	jmp    c010396e <default_alloc_pages+0x18b>
    }
    struct Page *page = NULL;
c0103827:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    //开始遍历空闲链表
    list_entry_t *le = &free_list;
c010382e:	c7 45 f0 e4 6f 12 c0 	movl   $0xc0126fe4,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103835:	eb 1c                	jmp    c0103853 <default_alloc_pages+0x70>
      //找到当前链表指向的页表，如果这个内存页数大于我们需要的页数，则直接从这个内存块取n页
        struct Page *p = le2page(le, page_link);
c0103837:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010383a:	83 e8 0c             	sub    $0xc,%eax
c010383d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103840:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103843:	8b 40 08             	mov    0x8(%eax),%eax
c0103846:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103849:	77 08                	ja     c0103853 <default_alloc_pages+0x70>
            page = p;
c010384b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010384e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            //SetPageReserved(page);
            break;
c0103851:	eb 18                	jmp    c010386b <default_alloc_pages+0x88>
c0103853:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103856:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0103859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010385c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010385f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103862:	81 7d f0 e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x10(%ebp)
c0103869:	75 cc                	jne    c0103837 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c010386b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010386f:	0f 84 f6 00 00 00    	je     c010396b <default_alloc_pages+0x188>
        //list_del(&(page->page_link));
        if (page->property > n) {
c0103875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103878:	8b 40 08             	mov    0x8(%eax),%eax
c010387b:	39 45 08             	cmp    %eax,0x8(%ebp)
c010387e:	0f 83 93 00 00 00    	jae    c0103917 <default_alloc_pages+0x134>
	        //因为我们取了n页，内存块可能还有部分内存页，需要当前内存块头偏移n个`Page`位置就是
        	//内存块剩下的页组成新的内存块结构，新的页头描述这个小内存块
            struct Page *p = page + n;
c0103884:	8b 45 08             	mov    0x8(%ebp),%eax
c0103887:	c1 e0 05             	shl    $0x5,%eax
c010388a:	89 c2                	mov    %eax,%edx
c010388c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010388f:	01 d0                	add    %edx,%eax
c0103891:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103894:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103897:	8b 40 08             	mov    0x8(%eax),%eax
c010389a:	2b 45 08             	sub    0x8(%ebp),%eax
c010389d:	89 c2                	mov    %eax,%edx
c010389f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038a2:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);//记得做这步，把property设为1，否则出错
c01038a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038a8:	83 c0 04             	add    $0x4,%eax
c01038ab:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01038b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038b5:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01038b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01038bb:	0f ab 10             	bts    %edx,(%eax)
}
c01038be:	90                   	nop
            //ClearPageReserved(p);
            //往空闲链表里加入这个新的小内存
            list_add(&free_list, &(p->page_link));
c01038bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038c2:	83 c0 0c             	add    $0xc,%eax
c01038c5:	c7 45 e0 e4 6f 12 c0 	movl   $0xc0126fe4,-0x20(%ebp)
c01038cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01038cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01038d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01038db:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038de:	8b 40 04             	mov    0x4(%eax),%eax
c01038e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01038e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038ea:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01038ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c01038f0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038f3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038f6:	89 10                	mov    %edx,(%eax)
c01038f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038fb:	8b 10                	mov    (%eax),%edx
c01038fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103900:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103903:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103906:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103909:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010390c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010390f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103912:	89 10                	mov    %edx,(%eax)
}
c0103914:	90                   	nop
}
c0103915:	90                   	nop
}
c0103916:	90                   	nop
    }
	list_del(&(page->page_link));
c0103917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391a:	83 c0 0c             	add    $0xc,%eax
c010391d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103920:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103923:	8b 40 04             	mov    0x4(%eax),%eax
c0103926:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103929:	8b 12                	mov    (%edx),%edx
c010392b:	89 55 b0             	mov    %edx,-0x50(%ebp)
c010392e:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103931:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103934:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103937:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010393a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010393d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103940:	89 10                	mov    %edx,(%eax)
}
c0103942:	90                   	nop
}
c0103943:	90                   	nop
        nr_free -= n;
c0103944:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0103949:	2b 45 08             	sub    0x8(%ebp),%eax
c010394c:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec
        ClearPageProperty(page);
c0103951:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103954:	83 c0 04             	add    $0x4,%eax
c0103957:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c010395e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103961:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103964:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103967:	0f b3 10             	btr    %edx,(%eax)
}
c010396a:	90                   	nop
    }
    return page;
c010396b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010396e:	89 ec                	mov    %ebp,%esp
c0103970:	5d                   	pop    %ebp
c0103971:	c3                   	ret    

c0103972 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103972:	55                   	push   %ebp
c0103973:	89 e5                	mov    %esp,%ebp
c0103975:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010397b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010397f:	75 24                	jne    c01039a5 <default_free_pages+0x33>
c0103981:	c7 44 24 0c 90 9a 10 	movl   $0xc0109a90,0xc(%esp)
c0103988:	c0 
c0103989:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103990:	c0 
c0103991:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0103998:	00 
c0103999:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01039a0:	e8 85 d3 ff ff       	call   c0100d2a <__panic>
    struct Page *p = base;
c01039a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
//首先遍历页表，把flags全部置0，并将ref清0，说明此时没有逻辑地址引用这块内存
    for (; p != base + n; p ++) {
c01039ab:	e9 9d 00 00 00       	jmp    c0103a4d <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01039b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b3:	83 c0 04             	add    $0x4,%eax
c01039b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01039bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01039c6:	0f a3 10             	bt     %edx,(%eax)
c01039c9:	19 c0                	sbb    %eax,%eax
c01039cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01039ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01039d2:	0f 95 c0             	setne  %al
c01039d5:	0f b6 c0             	movzbl %al,%eax
c01039d8:	85 c0                	test   %eax,%eax
c01039da:	75 2c                	jne    c0103a08 <default_free_pages+0x96>
c01039dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039df:	83 c0 04             	add    $0x4,%eax
c01039e2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01039e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01039f2:	0f a3 10             	bt     %edx,(%eax)
c01039f5:	19 c0                	sbb    %eax,%eax
c01039f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01039fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01039fe:	0f 95 c0             	setne  %al
c0103a01:	0f b6 c0             	movzbl %al,%eax
c0103a04:	85 c0                	test   %eax,%eax
c0103a06:	74 24                	je     c0103a2c <default_free_pages+0xba>
c0103a08:	c7 44 24 0c d4 9a 10 	movl   $0xc0109ad4,0xc(%esp)
c0103a0f:	c0 
c0103a10:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103a17:	c0 
c0103a18:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0103a1f:	00 
c0103a20:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103a27:	e8 fe d2 ff ff       	call   c0100d2a <__panic>
        p->flags = 0;
c0103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a2f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103a36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103a3d:	00 
c0103a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a41:	89 04 24             	mov    %eax,(%esp)
c0103a44:	e8 00 fc ff ff       	call   c0103649 <set_page_ref>
    for (; p != base + n; p ++) {
c0103a49:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a50:	c1 e0 05             	shl    $0x5,%eax
c0103a53:	89 c2                	mov    %eax,%edx
c0103a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a58:	01 d0                	add    %edx,%eax
c0103a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a5d:	0f 85 4d ff ff ff    	jne    c01039b0 <default_free_pages+0x3e>
    }
//同样的道理，我释放了n页，那么个n页形成新的一个大一点的内存块，我们需要设置这个内存块的第一个
    //页表描述内存块里有多少个页
    base->property = n;
c0103a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a66:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a69:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6f:	83 c0 04             	add    $0x4,%eax
c0103a72:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103a79:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a7c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a7f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103a82:	0f ab 10             	bts    %edx,(%eax)
}
c0103a85:	90                   	nop
c0103a86:	c7 45 d4 e4 6f 12 c0 	movl   $0xc0126fe4,-0x2c(%ebp)
    return listelm->next;
c0103a8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103a90:	8b 40 04             	mov    0x4(%eax),%eax
//遍历空闲链表，目的找到有没有地址空间是连在一起的内存块，把他们合并
    list_entry_t *le = list_next(&free_list);
c0103a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103a96:	e9 00 01 00 00       	jmp    c0103b9b <default_free_pages+0x229>
        p = le2page(le, page_link);
c0103a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a9e:	83 e8 0c             	sub    $0xc,%eax
c0103aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103aa7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103aaa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103aad:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0103ab3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab6:	8b 40 08             	mov    0x8(%eax),%eax
c0103ab9:	c1 e0 05             	shl    $0x5,%eax
c0103abc:	89 c2                	mov    %eax,%edx
c0103abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac1:	01 d0                	add    %edx,%eax
c0103ac3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103ac6:	75 5d                	jne    c0103b25 <default_free_pages+0x1b3>
            base->property += p->property;
c0103ac8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103acb:	8b 50 08             	mov    0x8(%eax),%edx
c0103ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad1:	8b 40 08             	mov    0x8(%eax),%eax
c0103ad4:	01 c2                	add    %eax,%edx
c0103ad6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ad9:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103adf:	83 c0 04             	add    $0x4,%eax
c0103ae2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103ae9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103aec:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103aef:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103af2:	0f b3 10             	btr    %edx,(%eax)
}
c0103af5:	90                   	nop
            list_del(&(p->page_link));
c0103af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103af9:	83 c0 0c             	add    $0xc,%eax
c0103afc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103aff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103b02:	8b 40 04             	mov    0x4(%eax),%eax
c0103b05:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103b08:	8b 12                	mov    (%edx),%edx
c0103b0a:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103b0d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0103b10:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103b13:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103b16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b19:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103b1c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103b1f:	89 10                	mov    %edx,(%eax)
}
c0103b21:	90                   	nop
}
c0103b22:	90                   	nop
c0103b23:	eb 76                	jmp    c0103b9b <default_free_pages+0x229>
        }
        else if (p + p->property == base) {
c0103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b28:	8b 40 08             	mov    0x8(%eax),%eax
c0103b2b:	c1 e0 05             	shl    $0x5,%eax
c0103b2e:	89 c2                	mov    %eax,%edx
c0103b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b33:	01 d0                	add    %edx,%eax
c0103b35:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103b38:	75 61                	jne    c0103b9b <default_free_pages+0x229>
            p->property += base->property;
c0103b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b3d:	8b 50 08             	mov    0x8(%eax),%edx
c0103b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b43:	8b 40 08             	mov    0x8(%eax),%eax
c0103b46:	01 c2                	add    %eax,%edx
c0103b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b4b:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b51:	83 c0 04             	add    $0x4,%eax
c0103b54:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0103b5b:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103b5e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103b61:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b64:	0f b3 10             	btr    %edx,(%eax)
}
c0103b67:	90                   	nop
            base = p;
c0103b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b6b:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b71:	83 c0 0c             	add    $0xc,%eax
c0103b74:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103b77:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103b7a:	8b 40 04             	mov    0x4(%eax),%eax
c0103b7d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103b80:	8b 12                	mov    (%edx),%edx
c0103b82:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0103b85:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0103b88:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b8b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103b8e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b91:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103b94:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103b97:	89 10                	mov    %edx,(%eax)
}
c0103b99:	90                   	nop
}
c0103b9a:	90                   	nop
    while (le != &free_list) {
c0103b9b:	81 7d f0 e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x10(%ebp)
c0103ba2:	0f 85 f3 fe ff ff    	jne    c0103a9b <default_free_pages+0x129>
        }
    }
    nr_free += n;
c0103ba8:	8b 15 ec 6f 12 c0    	mov    0xc0126fec,%edx
c0103bae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bb1:	01 d0                	add    %edx,%eax
c0103bb3:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec
c0103bb8:	c7 45 9c e4 6f 12 c0 	movl   $0xc0126fe4,-0x64(%ebp)
    return listelm->next;
c0103bbf:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103bc2:	8b 40 04             	mov    0x4(%eax),%eax
    //遍历空闲链表，因为空闲链表是from low to high
    //只需要遍历找打第一个地址比他高的，把释放的内存插入到他前面就行
    le = list_next(&free_list);
c0103bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103bc8:	eb 66                	jmp    c0103c30 <default_free_pages+0x2be>
        p = le2page(le, page_link);
c0103bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bcd:	83 e8 0c             	sub    $0xc,%eax
c0103bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd6:	8b 40 08             	mov    0x8(%eax),%eax
c0103bd9:	c1 e0 05             	shl    $0x5,%eax
c0103bdc:	89 c2                	mov    %eax,%edx
c0103bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0103be1:	01 d0                	add    %edx,%eax
c0103be3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103be6:	72 39                	jb     c0103c21 <default_free_pages+0x2af>
            assert(base + base->property != p);
c0103be8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103beb:	8b 40 08             	mov    0x8(%eax),%eax
c0103bee:	c1 e0 05             	shl    $0x5,%eax
c0103bf1:	89 c2                	mov    %eax,%edx
c0103bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf6:	01 d0                	add    %edx,%eax
c0103bf8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103bfb:	75 3e                	jne    c0103c3b <default_free_pages+0x2c9>
c0103bfd:	c7 44 24 0c f9 9a 10 	movl   $0xc0109af9,0xc(%esp)
c0103c04:	c0 
c0103c05:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103c0c:	c0 
c0103c0d:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0103c14:	00 
c0103c15:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103c1c:	e8 09 d1 ff ff       	call   c0100d2a <__panic>
c0103c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c24:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103c27:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103c2a:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0103c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103c30:	81 7d f0 e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x10(%ebp)
c0103c37:	75 91                	jne    c0103bca <default_free_pages+0x258>
c0103c39:	eb 01                	jmp    c0103c3c <default_free_pages+0x2ca>
            break;
c0103c3b:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c0103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c3f:	8d 50 0c             	lea    0xc(%eax),%edx
c0103c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c45:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103c48:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0103c4b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103c4e:	8b 00                	mov    (%eax),%eax
c0103c50:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103c53:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103c56:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103c59:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103c5c:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0103c5f:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c62:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103c65:	89 10                	mov    %edx,(%eax)
c0103c67:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103c6a:	8b 10                	mov    (%eax),%edx
c0103c6c:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c6f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103c72:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c75:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103c78:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103c7b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103c7e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103c81:	89 10                	mov    %edx,(%eax)
}
c0103c83:	90                   	nop
}
c0103c84:	90                   	nop
}
c0103c85:	90                   	nop
c0103c86:	89 ec                	mov    %ebp,%esp
c0103c88:	5d                   	pop    %ebp
c0103c89:	c3                   	ret    

c0103c8a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103c8a:	55                   	push   %ebp
c0103c8b:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103c8d:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
}
c0103c92:	5d                   	pop    %ebp
c0103c93:	c3                   	ret    

c0103c94 <basic_check>:

static void
basic_check(void) {
c0103c94:	55                   	push   %ebp
c0103c95:	89 e5                	mov    %esp,%ebp
c0103c97:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103c9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103cad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cb4:	e8 2a 0f 00 00       	call   c0104be3 <alloc_pages>
c0103cb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103cbc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103cc0:	75 24                	jne    c0103ce6 <basic_check+0x52>
c0103cc2:	c7 44 24 0c 14 9b 10 	movl   $0xc0109b14,0xc(%esp)
c0103cc9:	c0 
c0103cca:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103cd1:	c0 
c0103cd2:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103cd9:	00 
c0103cda:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103ce1:	e8 44 d0 ff ff       	call   c0100d2a <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103ce6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ced:	e8 f1 0e 00 00       	call   c0104be3 <alloc_pages>
c0103cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103cf5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cf9:	75 24                	jne    c0103d1f <basic_check+0x8b>
c0103cfb:	c7 44 24 0c 30 9b 10 	movl   $0xc0109b30,0xc(%esp)
c0103d02:	c0 
c0103d03:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103d0a:	c0 
c0103d0b:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103d12:	00 
c0103d13:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103d1a:	e8 0b d0 ff ff       	call   c0100d2a <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d26:	e8 b8 0e 00 00       	call   c0104be3 <alloc_pages>
c0103d2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d32:	75 24                	jne    c0103d58 <basic_check+0xc4>
c0103d34:	c7 44 24 0c 4c 9b 10 	movl   $0xc0109b4c,0xc(%esp)
c0103d3b:	c0 
c0103d3c:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103d43:	c0 
c0103d44:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103d4b:	00 
c0103d4c:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103d53:	e8 d2 cf ff ff       	call   c0100d2a <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103d58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d5b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103d5e:	74 10                	je     c0103d70 <basic_check+0xdc>
c0103d60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d66:	74 08                	je     c0103d70 <basic_check+0xdc>
c0103d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d6b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d6e:	75 24                	jne    c0103d94 <basic_check+0x100>
c0103d70:	c7 44 24 0c 68 9b 10 	movl   $0xc0109b68,0xc(%esp)
c0103d77:	c0 
c0103d78:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103d7f:	c0 
c0103d80:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103d87:	00 
c0103d88:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103d8f:	e8 96 cf ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d97:	89 04 24             	mov    %eax,(%esp)
c0103d9a:	e8 a0 f8 ff ff       	call   c010363f <page_ref>
c0103d9f:	85 c0                	test   %eax,%eax
c0103da1:	75 1e                	jne    c0103dc1 <basic_check+0x12d>
c0103da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103da6:	89 04 24             	mov    %eax,(%esp)
c0103da9:	e8 91 f8 ff ff       	call   c010363f <page_ref>
c0103dae:	85 c0                	test   %eax,%eax
c0103db0:	75 0f                	jne    c0103dc1 <basic_check+0x12d>
c0103db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db5:	89 04 24             	mov    %eax,(%esp)
c0103db8:	e8 82 f8 ff ff       	call   c010363f <page_ref>
c0103dbd:	85 c0                	test   %eax,%eax
c0103dbf:	74 24                	je     c0103de5 <basic_check+0x151>
c0103dc1:	c7 44 24 0c 8c 9b 10 	movl   $0xc0109b8c,0xc(%esp)
c0103dc8:	c0 
c0103dc9:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103dd0:	c0 
c0103dd1:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103dd8:	00 
c0103dd9:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103de0:	e8 45 cf ff ff       	call   c0100d2a <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103de8:	89 04 24             	mov    %eax,(%esp)
c0103deb:	e8 37 f8 ff ff       	call   c0103627 <page2pa>
c0103df0:	8b 15 04 70 12 c0    	mov    0xc0127004,%edx
c0103df6:	c1 e2 0c             	shl    $0xc,%edx
c0103df9:	39 d0                	cmp    %edx,%eax
c0103dfb:	72 24                	jb     c0103e21 <basic_check+0x18d>
c0103dfd:	c7 44 24 0c c8 9b 10 	movl   $0xc0109bc8,0xc(%esp)
c0103e04:	c0 
c0103e05:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103e0c:	c0 
c0103e0d:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103e14:	00 
c0103e15:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103e1c:	e8 09 cf ff ff       	call   c0100d2a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e24:	89 04 24             	mov    %eax,(%esp)
c0103e27:	e8 fb f7 ff ff       	call   c0103627 <page2pa>
c0103e2c:	8b 15 04 70 12 c0    	mov    0xc0127004,%edx
c0103e32:	c1 e2 0c             	shl    $0xc,%edx
c0103e35:	39 d0                	cmp    %edx,%eax
c0103e37:	72 24                	jb     c0103e5d <basic_check+0x1c9>
c0103e39:	c7 44 24 0c e5 9b 10 	movl   $0xc0109be5,0xc(%esp)
c0103e40:	c0 
c0103e41:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103e48:	c0 
c0103e49:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103e50:	00 
c0103e51:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103e58:	e8 cd ce ff ff       	call   c0100d2a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e60:	89 04 24             	mov    %eax,(%esp)
c0103e63:	e8 bf f7 ff ff       	call   c0103627 <page2pa>
c0103e68:	8b 15 04 70 12 c0    	mov    0xc0127004,%edx
c0103e6e:	c1 e2 0c             	shl    $0xc,%edx
c0103e71:	39 d0                	cmp    %edx,%eax
c0103e73:	72 24                	jb     c0103e99 <basic_check+0x205>
c0103e75:	c7 44 24 0c 02 9c 10 	movl   $0xc0109c02,0xc(%esp)
c0103e7c:	c0 
c0103e7d:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103e84:	c0 
c0103e85:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0103e8c:	00 
c0103e8d:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103e94:	e8 91 ce ff ff       	call   c0100d2a <__panic>

    list_entry_t free_list_store = free_list;
c0103e99:	a1 e4 6f 12 c0       	mov    0xc0126fe4,%eax
c0103e9e:	8b 15 e8 6f 12 c0    	mov    0xc0126fe8,%edx
c0103ea4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103ea7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103eaa:	c7 45 dc e4 6f 12 c0 	movl   $0xc0126fe4,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103eb1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eb7:	89 50 04             	mov    %edx,0x4(%eax)
c0103eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ebd:	8b 50 04             	mov    0x4(%eax),%edx
c0103ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ec3:	89 10                	mov    %edx,(%eax)
}
c0103ec5:	90                   	nop
c0103ec6:	c7 45 e0 e4 6f 12 c0 	movl   $0xc0126fe4,-0x20(%ebp)
    return list->next == list;
c0103ecd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ed0:	8b 40 04             	mov    0x4(%eax),%eax
c0103ed3:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103ed6:	0f 94 c0             	sete   %al
c0103ed9:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103edc:	85 c0                	test   %eax,%eax
c0103ede:	75 24                	jne    c0103f04 <basic_check+0x270>
c0103ee0:	c7 44 24 0c 1f 9c 10 	movl   $0xc0109c1f,0xc(%esp)
c0103ee7:	c0 
c0103ee8:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103eef:	c0 
c0103ef0:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103ef7:	00 
c0103ef8:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103eff:	e8 26 ce ff ff       	call   c0100d2a <__panic>

    unsigned int nr_free_store = nr_free;
c0103f04:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0103f09:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103f0c:	c7 05 ec 6f 12 c0 00 	movl   $0x0,0xc0126fec
c0103f13:	00 00 00 

    assert(alloc_page() == NULL);
c0103f16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f1d:	e8 c1 0c 00 00       	call   c0104be3 <alloc_pages>
c0103f22:	85 c0                	test   %eax,%eax
c0103f24:	74 24                	je     c0103f4a <basic_check+0x2b6>
c0103f26:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c0103f2d:	c0 
c0103f2e:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103f35:	c0 
c0103f36:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0103f3d:	00 
c0103f3e:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103f45:	e8 e0 cd ff ff       	call   c0100d2a <__panic>

    free_page(p0);
c0103f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f51:	00 
c0103f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f55:	89 04 24             	mov    %eax,(%esp)
c0103f58:	e8 f3 0c 00 00       	call   c0104c50 <free_pages>
    free_page(p1);
c0103f5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f64:	00 
c0103f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f68:	89 04 24             	mov    %eax,(%esp)
c0103f6b:	e8 e0 0c 00 00       	call   c0104c50 <free_pages>
    free_page(p2);
c0103f70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f77:	00 
c0103f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f7b:	89 04 24             	mov    %eax,(%esp)
c0103f7e:	e8 cd 0c 00 00       	call   c0104c50 <free_pages>
    assert(nr_free == 3);
c0103f83:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0103f88:	83 f8 03             	cmp    $0x3,%eax
c0103f8b:	74 24                	je     c0103fb1 <basic_check+0x31d>
c0103f8d:	c7 44 24 0c 4b 9c 10 	movl   $0xc0109c4b,0xc(%esp)
c0103f94:	c0 
c0103f95:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103f9c:	c0 
c0103f9d:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103fa4:	00 
c0103fa5:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103fac:	e8 79 cd ff ff       	call   c0100d2a <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103fb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fb8:	e8 26 0c 00 00       	call   c0104be3 <alloc_pages>
c0103fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fc0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103fc4:	75 24                	jne    c0103fea <basic_check+0x356>
c0103fc6:	c7 44 24 0c 14 9b 10 	movl   $0xc0109b14,0xc(%esp)
c0103fcd:	c0 
c0103fce:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0103fd5:	c0 
c0103fd6:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103fdd:	00 
c0103fde:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0103fe5:	e8 40 cd ff ff       	call   c0100d2a <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103fea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ff1:	e8 ed 0b 00 00       	call   c0104be3 <alloc_pages>
c0103ff6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ff9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ffd:	75 24                	jne    c0104023 <basic_check+0x38f>
c0103fff:	c7 44 24 0c 30 9b 10 	movl   $0xc0109b30,0xc(%esp)
c0104006:	c0 
c0104007:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010400e:	c0 
c010400f:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0104016:	00 
c0104017:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010401e:	e8 07 cd ff ff       	call   c0100d2a <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104023:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010402a:	e8 b4 0b 00 00       	call   c0104be3 <alloc_pages>
c010402f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104032:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104036:	75 24                	jne    c010405c <basic_check+0x3c8>
c0104038:	c7 44 24 0c 4c 9b 10 	movl   $0xc0109b4c,0xc(%esp)
c010403f:	c0 
c0104040:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104047:	c0 
c0104048:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c010404f:	00 
c0104050:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104057:	e8 ce cc ff ff       	call   c0100d2a <__panic>

    assert(alloc_page() == NULL);
c010405c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104063:	e8 7b 0b 00 00       	call   c0104be3 <alloc_pages>
c0104068:	85 c0                	test   %eax,%eax
c010406a:	74 24                	je     c0104090 <basic_check+0x3fc>
c010406c:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c0104073:	c0 
c0104074:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010407b:	c0 
c010407c:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0104083:	00 
c0104084:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010408b:	e8 9a cc ff ff       	call   c0100d2a <__panic>

    free_page(p0);
c0104090:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104097:	00 
c0104098:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010409b:	89 04 24             	mov    %eax,(%esp)
c010409e:	e8 ad 0b 00 00       	call   c0104c50 <free_pages>
c01040a3:	c7 45 d8 e4 6f 12 c0 	movl   $0xc0126fe4,-0x28(%ebp)
c01040aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01040ad:	8b 40 04             	mov    0x4(%eax),%eax
c01040b0:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01040b3:	0f 94 c0             	sete   %al
c01040b6:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01040b9:	85 c0                	test   %eax,%eax
c01040bb:	74 24                	je     c01040e1 <basic_check+0x44d>
c01040bd:	c7 44 24 0c 58 9c 10 	movl   $0xc0109c58,0xc(%esp)
c01040c4:	c0 
c01040c5:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01040cc:	c0 
c01040cd:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01040d4:	00 
c01040d5:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01040dc:	e8 49 cc ff ff       	call   c0100d2a <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01040e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040e8:	e8 f6 0a 00 00       	call   c0104be3 <alloc_pages>
c01040ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01040f6:	74 24                	je     c010411c <basic_check+0x488>
c01040f8:	c7 44 24 0c 70 9c 10 	movl   $0xc0109c70,0xc(%esp)
c01040ff:	c0 
c0104100:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104107:	c0 
c0104108:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c010410f:	00 
c0104110:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104117:	e8 0e cc ff ff       	call   c0100d2a <__panic>
    assert(alloc_page() == NULL);
c010411c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104123:	e8 bb 0a 00 00       	call   c0104be3 <alloc_pages>
c0104128:	85 c0                	test   %eax,%eax
c010412a:	74 24                	je     c0104150 <basic_check+0x4bc>
c010412c:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c0104133:	c0 
c0104134:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010413b:	c0 
c010413c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104143:	00 
c0104144:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010414b:	e8 da cb ff ff       	call   c0100d2a <__panic>

    assert(nr_free == 0);
c0104150:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0104155:	85 c0                	test   %eax,%eax
c0104157:	74 24                	je     c010417d <basic_check+0x4e9>
c0104159:	c7 44 24 0c 89 9c 10 	movl   $0xc0109c89,0xc(%esp)
c0104160:	c0 
c0104161:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104168:	c0 
c0104169:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0104170:	00 
c0104171:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104178:	e8 ad cb ff ff       	call   c0100d2a <__panic>
    free_list = free_list_store;
c010417d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104180:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104183:	a3 e4 6f 12 c0       	mov    %eax,0xc0126fe4
c0104188:	89 15 e8 6f 12 c0    	mov    %edx,0xc0126fe8
    nr_free = nr_free_store;
c010418e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104191:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec

    free_page(p);
c0104196:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010419d:	00 
c010419e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041a1:	89 04 24             	mov    %eax,(%esp)
c01041a4:	e8 a7 0a 00 00       	call   c0104c50 <free_pages>
    free_page(p1);
c01041a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041b0:	00 
c01041b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041b4:	89 04 24             	mov    %eax,(%esp)
c01041b7:	e8 94 0a 00 00       	call   c0104c50 <free_pages>
    free_page(p2);
c01041bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041c3:	00 
c01041c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041c7:	89 04 24             	mov    %eax,(%esp)
c01041ca:	e8 81 0a 00 00       	call   c0104c50 <free_pages>
}
c01041cf:	90                   	nop
c01041d0:	89 ec                	mov    %ebp,%esp
c01041d2:	5d                   	pop    %ebp
c01041d3:	c3                   	ret    

c01041d4 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01041d4:	55                   	push   %ebp
c01041d5:	89 e5                	mov    %esp,%ebp
c01041d7:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01041dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01041e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01041eb:	c7 45 ec e4 6f 12 c0 	movl   $0xc0126fe4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01041f2:	eb 6a                	jmp    c010425e <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c01041f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041f7:	83 e8 0c             	sub    $0xc,%eax
c01041fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01041fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104200:	83 c0 04             	add    $0x4,%eax
c0104203:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010420a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010420d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104210:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104213:	0f a3 10             	bt     %edx,(%eax)
c0104216:	19 c0                	sbb    %eax,%eax
c0104218:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010421b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010421f:	0f 95 c0             	setne  %al
c0104222:	0f b6 c0             	movzbl %al,%eax
c0104225:	85 c0                	test   %eax,%eax
c0104227:	75 24                	jne    c010424d <default_check+0x79>
c0104229:	c7 44 24 0c 96 9c 10 	movl   $0xc0109c96,0xc(%esp)
c0104230:	c0 
c0104231:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104238:	c0 
c0104239:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104240:	00 
c0104241:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104248:	e8 dd ca ff ff       	call   c0100d2a <__panic>
        count ++, total += p->property;
c010424d:	ff 45 f4             	incl   -0xc(%ebp)
c0104250:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104253:	8b 50 08             	mov    0x8(%eax),%edx
c0104256:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104259:	01 d0                	add    %edx,%eax
c010425b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010425e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104261:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104264:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104267:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010426a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010426d:	81 7d ec e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x14(%ebp)
c0104274:	0f 85 7a ff ff ff    	jne    c01041f4 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c010427a:	e8 06 0a 00 00       	call   c0104c85 <nr_free_pages>
c010427f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104282:	39 d0                	cmp    %edx,%eax
c0104284:	74 24                	je     c01042aa <default_check+0xd6>
c0104286:	c7 44 24 0c a6 9c 10 	movl   $0xc0109ca6,0xc(%esp)
c010428d:	c0 
c010428e:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104295:	c0 
c0104296:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c010429d:	00 
c010429e:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01042a5:	e8 80 ca ff ff       	call   c0100d2a <__panic>

    basic_check();
c01042aa:	e8 e5 f9 ff ff       	call   c0103c94 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01042af:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01042b6:	e8 28 09 00 00       	call   c0104be3 <alloc_pages>
c01042bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c01042be:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01042c2:	75 24                	jne    c01042e8 <default_check+0x114>
c01042c4:	c7 44 24 0c bf 9c 10 	movl   $0xc0109cbf,0xc(%esp)
c01042cb:	c0 
c01042cc:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01042d3:	c0 
c01042d4:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01042db:	00 
c01042dc:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01042e3:	e8 42 ca ff ff       	call   c0100d2a <__panic>
    assert(!PageProperty(p0));
c01042e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042eb:	83 c0 04             	add    $0x4,%eax
c01042ee:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01042f5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042f8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042fb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042fe:	0f a3 10             	bt     %edx,(%eax)
c0104301:	19 c0                	sbb    %eax,%eax
c0104303:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104306:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010430a:	0f 95 c0             	setne  %al
c010430d:	0f b6 c0             	movzbl %al,%eax
c0104310:	85 c0                	test   %eax,%eax
c0104312:	74 24                	je     c0104338 <default_check+0x164>
c0104314:	c7 44 24 0c ca 9c 10 	movl   $0xc0109cca,0xc(%esp)
c010431b:	c0 
c010431c:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104323:	c0 
c0104324:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010432b:	00 
c010432c:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104333:	e8 f2 c9 ff ff       	call   c0100d2a <__panic>

    list_entry_t free_list_store = free_list;
c0104338:	a1 e4 6f 12 c0       	mov    0xc0126fe4,%eax
c010433d:	8b 15 e8 6f 12 c0    	mov    0xc0126fe8,%edx
c0104343:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104346:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104349:	c7 45 b0 e4 6f 12 c0 	movl   $0xc0126fe4,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104350:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104353:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104356:	89 50 04             	mov    %edx,0x4(%eax)
c0104359:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010435c:	8b 50 04             	mov    0x4(%eax),%edx
c010435f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104362:	89 10                	mov    %edx,(%eax)
}
c0104364:	90                   	nop
c0104365:	c7 45 b4 e4 6f 12 c0 	movl   $0xc0126fe4,-0x4c(%ebp)
    return list->next == list;
c010436c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010436f:	8b 40 04             	mov    0x4(%eax),%eax
c0104372:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104375:	0f 94 c0             	sete   %al
c0104378:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010437b:	85 c0                	test   %eax,%eax
c010437d:	75 24                	jne    c01043a3 <default_check+0x1cf>
c010437f:	c7 44 24 0c 1f 9c 10 	movl   $0xc0109c1f,0xc(%esp)
c0104386:	c0 
c0104387:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010438e:	c0 
c010438f:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0104396:	00 
c0104397:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010439e:	e8 87 c9 ff ff       	call   c0100d2a <__panic>
    assert(alloc_page() == NULL);
c01043a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043aa:	e8 34 08 00 00       	call   c0104be3 <alloc_pages>
c01043af:	85 c0                	test   %eax,%eax
c01043b1:	74 24                	je     c01043d7 <default_check+0x203>
c01043b3:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c01043ba:	c0 
c01043bb:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01043c2:	c0 
c01043c3:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01043ca:	00 
c01043cb:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01043d2:	e8 53 c9 ff ff       	call   c0100d2a <__panic>

    unsigned int nr_free_store = nr_free;
c01043d7:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c01043dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c01043df:	c7 05 ec 6f 12 c0 00 	movl   $0x0,0xc0126fec
c01043e6:	00 00 00 

    free_pages(p0 + 2, 3);
c01043e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043ec:	83 c0 40             	add    $0x40,%eax
c01043ef:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01043f6:	00 
c01043f7:	89 04 24             	mov    %eax,(%esp)
c01043fa:	e8 51 08 00 00       	call   c0104c50 <free_pages>
    assert(alloc_pages(4) == NULL);
c01043ff:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104406:	e8 d8 07 00 00       	call   c0104be3 <alloc_pages>
c010440b:	85 c0                	test   %eax,%eax
c010440d:	74 24                	je     c0104433 <default_check+0x25f>
c010440f:	c7 44 24 0c dc 9c 10 	movl   $0xc0109cdc,0xc(%esp)
c0104416:	c0 
c0104417:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010441e:	c0 
c010441f:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0104426:	00 
c0104427:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010442e:	e8 f7 c8 ff ff       	call   c0100d2a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104433:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104436:	83 c0 40             	add    $0x40,%eax
c0104439:	83 c0 04             	add    $0x4,%eax
c010443c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104443:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104446:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104449:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010444c:	0f a3 10             	bt     %edx,(%eax)
c010444f:	19 c0                	sbb    %eax,%eax
c0104451:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104454:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104458:	0f 95 c0             	setne  %al
c010445b:	0f b6 c0             	movzbl %al,%eax
c010445e:	85 c0                	test   %eax,%eax
c0104460:	74 0e                	je     c0104470 <default_check+0x29c>
c0104462:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104465:	83 c0 40             	add    $0x40,%eax
c0104468:	8b 40 08             	mov    0x8(%eax),%eax
c010446b:	83 f8 03             	cmp    $0x3,%eax
c010446e:	74 24                	je     c0104494 <default_check+0x2c0>
c0104470:	c7 44 24 0c f4 9c 10 	movl   $0xc0109cf4,0xc(%esp)
c0104477:	c0 
c0104478:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010447f:	c0 
c0104480:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0104487:	00 
c0104488:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010448f:	e8 96 c8 ff ff       	call   c0100d2a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104494:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010449b:	e8 43 07 00 00       	call   c0104be3 <alloc_pages>
c01044a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01044a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01044a7:	75 24                	jne    c01044cd <default_check+0x2f9>
c01044a9:	c7 44 24 0c 20 9d 10 	movl   $0xc0109d20,0xc(%esp)
c01044b0:	c0 
c01044b1:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01044b8:	c0 
c01044b9:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01044c0:	00 
c01044c1:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01044c8:	e8 5d c8 ff ff       	call   c0100d2a <__panic>
    assert(alloc_page() == NULL);
c01044cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044d4:	e8 0a 07 00 00       	call   c0104be3 <alloc_pages>
c01044d9:	85 c0                	test   %eax,%eax
c01044db:	74 24                	je     c0104501 <default_check+0x32d>
c01044dd:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c01044e4:	c0 
c01044e5:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01044ec:	c0 
c01044ed:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01044f4:	00 
c01044f5:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01044fc:	e8 29 c8 ff ff       	call   c0100d2a <__panic>
    assert(p0 + 2 == p1);
c0104501:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104504:	83 c0 40             	add    $0x40,%eax
c0104507:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010450a:	74 24                	je     c0104530 <default_check+0x35c>
c010450c:	c7 44 24 0c 3e 9d 10 	movl   $0xc0109d3e,0xc(%esp)
c0104513:	c0 
c0104514:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010451b:	c0 
c010451c:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0104523:	00 
c0104524:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010452b:	e8 fa c7 ff ff       	call   c0100d2a <__panic>

    p2 = p0 + 1;
c0104530:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104533:	83 c0 20             	add    $0x20,%eax
c0104536:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0104539:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104540:	00 
c0104541:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104544:	89 04 24             	mov    %eax,(%esp)
c0104547:	e8 04 07 00 00       	call   c0104c50 <free_pages>
    free_pages(p1, 3);
c010454c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104553:	00 
c0104554:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104557:	89 04 24             	mov    %eax,(%esp)
c010455a:	e8 f1 06 00 00       	call   c0104c50 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010455f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104562:	83 c0 04             	add    $0x4,%eax
c0104565:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010456c:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010456f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104572:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104575:	0f a3 10             	bt     %edx,(%eax)
c0104578:	19 c0                	sbb    %eax,%eax
c010457a:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010457d:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104581:	0f 95 c0             	setne  %al
c0104584:	0f b6 c0             	movzbl %al,%eax
c0104587:	85 c0                	test   %eax,%eax
c0104589:	74 0b                	je     c0104596 <default_check+0x3c2>
c010458b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010458e:	8b 40 08             	mov    0x8(%eax),%eax
c0104591:	83 f8 01             	cmp    $0x1,%eax
c0104594:	74 24                	je     c01045ba <default_check+0x3e6>
c0104596:	c7 44 24 0c 4c 9d 10 	movl   $0xc0109d4c,0xc(%esp)
c010459d:	c0 
c010459e:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01045a5:	c0 
c01045a6:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01045ad:	00 
c01045ae:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01045b5:	e8 70 c7 ff ff       	call   c0100d2a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01045ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045bd:	83 c0 04             	add    $0x4,%eax
c01045c0:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01045c7:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045ca:	8b 45 90             	mov    -0x70(%ebp),%eax
c01045cd:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01045d0:	0f a3 10             	bt     %edx,(%eax)
c01045d3:	19 c0                	sbb    %eax,%eax
c01045d5:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01045d8:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01045dc:	0f 95 c0             	setne  %al
c01045df:	0f b6 c0             	movzbl %al,%eax
c01045e2:	85 c0                	test   %eax,%eax
c01045e4:	74 0b                	je     c01045f1 <default_check+0x41d>
c01045e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045e9:	8b 40 08             	mov    0x8(%eax),%eax
c01045ec:	83 f8 03             	cmp    $0x3,%eax
c01045ef:	74 24                	je     c0104615 <default_check+0x441>
c01045f1:	c7 44 24 0c 74 9d 10 	movl   $0xc0109d74,0xc(%esp)
c01045f8:	c0 
c01045f9:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104600:	c0 
c0104601:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0104608:	00 
c0104609:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104610:	e8 15 c7 ff ff       	call   c0100d2a <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104615:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010461c:	e8 c2 05 00 00       	call   c0104be3 <alloc_pages>
c0104621:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104624:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104627:	83 e8 20             	sub    $0x20,%eax
c010462a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010462d:	74 24                	je     c0104653 <default_check+0x47f>
c010462f:	c7 44 24 0c 9a 9d 10 	movl   $0xc0109d9a,0xc(%esp)
c0104636:	c0 
c0104637:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010463e:	c0 
c010463f:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0104646:	00 
c0104647:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010464e:	e8 d7 c6 ff ff       	call   c0100d2a <__panic>
    free_page(p0);
c0104653:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010465a:	00 
c010465b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010465e:	89 04 24             	mov    %eax,(%esp)
c0104661:	e8 ea 05 00 00       	call   c0104c50 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104666:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010466d:	e8 71 05 00 00       	call   c0104be3 <alloc_pages>
c0104672:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104675:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104678:	83 c0 20             	add    $0x20,%eax
c010467b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010467e:	74 24                	je     c01046a4 <default_check+0x4d0>
c0104680:	c7 44 24 0c b8 9d 10 	movl   $0xc0109db8,0xc(%esp)
c0104687:	c0 
c0104688:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010468f:	c0 
c0104690:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104697:	00 
c0104698:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010469f:	e8 86 c6 ff ff       	call   c0100d2a <__panic>

    free_pages(p0, 2);
c01046a4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01046ab:	00 
c01046ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046af:	89 04 24             	mov    %eax,(%esp)
c01046b2:	e8 99 05 00 00       	call   c0104c50 <free_pages>
    free_page(p2);
c01046b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01046be:	00 
c01046bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01046c2:	89 04 24             	mov    %eax,(%esp)
c01046c5:	e8 86 05 00 00       	call   c0104c50 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01046ca:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01046d1:	e8 0d 05 00 00       	call   c0104be3 <alloc_pages>
c01046d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01046d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01046dd:	75 24                	jne    c0104703 <default_check+0x52f>
c01046df:	c7 44 24 0c d8 9d 10 	movl   $0xc0109dd8,0xc(%esp)
c01046e6:	c0 
c01046e7:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01046ee:	c0 
c01046ef:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01046f6:	00 
c01046f7:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01046fe:	e8 27 c6 ff ff       	call   c0100d2a <__panic>
    assert(alloc_page() == NULL);
c0104703:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010470a:	e8 d4 04 00 00       	call   c0104be3 <alloc_pages>
c010470f:	85 c0                	test   %eax,%eax
c0104711:	74 24                	je     c0104737 <default_check+0x563>
c0104713:	c7 44 24 0c 36 9c 10 	movl   $0xc0109c36,0xc(%esp)
c010471a:	c0 
c010471b:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104722:	c0 
c0104723:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c010472a:	00 
c010472b:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104732:	e8 f3 c5 ff ff       	call   c0100d2a <__panic>

    assert(nr_free == 0);
c0104737:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c010473c:	85 c0                	test   %eax,%eax
c010473e:	74 24                	je     c0104764 <default_check+0x590>
c0104740:	c7 44 24 0c 89 9c 10 	movl   $0xc0109c89,0xc(%esp)
c0104747:	c0 
c0104748:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010474f:	c0 
c0104750:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0104757:	00 
c0104758:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010475f:	e8 c6 c5 ff ff       	call   c0100d2a <__panic>
    nr_free = nr_free_store;
c0104764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104767:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec

    free_list = free_list_store;
c010476c:	8b 45 80             	mov    -0x80(%ebp),%eax
c010476f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104772:	a3 e4 6f 12 c0       	mov    %eax,0xc0126fe4
c0104777:	89 15 e8 6f 12 c0    	mov    %edx,0xc0126fe8
    free_pages(p0, 5);
c010477d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104784:	00 
c0104785:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104788:	89 04 24             	mov    %eax,(%esp)
c010478b:	e8 c0 04 00 00       	call   c0104c50 <free_pages>

    le = &free_list;
c0104790:	c7 45 ec e4 6f 12 c0 	movl   $0xc0126fe4,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104797:	eb 5a                	jmp    c01047f3 <default_check+0x61f>
	assert(le->next->prev == le && le->prev->next == le);
c0104799:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010479c:	8b 40 04             	mov    0x4(%eax),%eax
c010479f:	8b 00                	mov    (%eax),%eax
c01047a1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01047a4:	75 0d                	jne    c01047b3 <default_check+0x5df>
c01047a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a9:	8b 00                	mov    (%eax),%eax
c01047ab:	8b 40 04             	mov    0x4(%eax),%eax
c01047ae:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01047b1:	74 24                	je     c01047d7 <default_check+0x603>
c01047b3:	c7 44 24 0c f8 9d 10 	movl   $0xc0109df8,0xc(%esp)
c01047ba:	c0 
c01047bb:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c01047c2:	c0 
c01047c3:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c01047ca:	00 
c01047cb:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c01047d2:	e8 53 c5 ff ff       	call   c0100d2a <__panic>
        struct Page *p = le2page(le, page_link);
c01047d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047da:	83 e8 0c             	sub    $0xc,%eax
c01047dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c01047e0:	ff 4d f4             	decl   -0xc(%ebp)
c01047e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01047e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047e9:	8b 48 08             	mov    0x8(%eax),%ecx
c01047ec:	89 d0                	mov    %edx,%eax
c01047ee:	29 c8                	sub    %ecx,%eax
c01047f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047f6:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01047f9:	8b 45 88             	mov    -0x78(%ebp),%eax
c01047fc:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01047ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104802:	81 7d ec e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x14(%ebp)
c0104809:	75 8e                	jne    c0104799 <default_check+0x5c5>
    }
    assert(count == 0);
c010480b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010480f:	74 24                	je     c0104835 <default_check+0x661>
c0104811:	c7 44 24 0c 25 9e 10 	movl   $0xc0109e25,0xc(%esp)
c0104818:	c0 
c0104819:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c0104820:	c0 
c0104821:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0104828:	00 
c0104829:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c0104830:	e8 f5 c4 ff ff       	call   c0100d2a <__panic>
    assert(total == 0);
c0104835:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104839:	74 24                	je     c010485f <default_check+0x68b>
c010483b:	c7 44 24 0c 30 9e 10 	movl   $0xc0109e30,0xc(%esp)
c0104842:	c0 
c0104843:	c7 44 24 08 96 9a 10 	movl   $0xc0109a96,0x8(%esp)
c010484a:	c0 
c010484b:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c0104852:	00 
c0104853:	c7 04 24 ab 9a 10 c0 	movl   $0xc0109aab,(%esp)
c010485a:	e8 cb c4 ff ff       	call   c0100d2a <__panic>
}
c010485f:	90                   	nop
c0104860:	89 ec                	mov    %ebp,%esp
c0104862:	5d                   	pop    %ebp
c0104863:	c3                   	ret    

c0104864 <page2ppn>:
page2ppn(struct Page *page) {
c0104864:	55                   	push   %ebp
c0104865:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104867:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c010486d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104870:	29 d0                	sub    %edx,%eax
c0104872:	c1 f8 05             	sar    $0x5,%eax
}
c0104875:	5d                   	pop    %ebp
c0104876:	c3                   	ret    

c0104877 <page2pa>:
page2pa(struct Page *page) {
c0104877:	55                   	push   %ebp
c0104878:	89 e5                	mov    %esp,%ebp
c010487a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010487d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104880:	89 04 24             	mov    %eax,(%esp)
c0104883:	e8 dc ff ff ff       	call   c0104864 <page2ppn>
c0104888:	c1 e0 0c             	shl    $0xc,%eax
}
c010488b:	89 ec                	mov    %ebp,%esp
c010488d:	5d                   	pop    %ebp
c010488e:	c3                   	ret    

c010488f <pa2page>:
pa2page(uintptr_t pa) {
c010488f:	55                   	push   %ebp
c0104890:	89 e5                	mov    %esp,%ebp
c0104892:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104895:	8b 45 08             	mov    0x8(%ebp),%eax
c0104898:	c1 e8 0c             	shr    $0xc,%eax
c010489b:	89 c2                	mov    %eax,%edx
c010489d:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01048a2:	39 c2                	cmp    %eax,%edx
c01048a4:	72 1c                	jb     c01048c2 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01048a6:	c7 44 24 08 6c 9e 10 	movl   $0xc0109e6c,0x8(%esp)
c01048ad:	c0 
c01048ae:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01048b5:	00 
c01048b6:	c7 04 24 8b 9e 10 c0 	movl   $0xc0109e8b,(%esp)
c01048bd:	e8 68 c4 ff ff       	call   c0100d2a <__panic>
    return &pages[PPN(pa)];
c01048c2:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c01048c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01048cb:	c1 e8 0c             	shr    $0xc,%eax
c01048ce:	c1 e0 05             	shl    $0x5,%eax
c01048d1:	01 d0                	add    %edx,%eax
}
c01048d3:	89 ec                	mov    %ebp,%esp
c01048d5:	5d                   	pop    %ebp
c01048d6:	c3                   	ret    

c01048d7 <page2kva>:
page2kva(struct Page *page) {
c01048d7:	55                   	push   %ebp
c01048d8:	89 e5                	mov    %esp,%ebp
c01048da:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01048dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01048e0:	89 04 24             	mov    %eax,(%esp)
c01048e3:	e8 8f ff ff ff       	call   c0104877 <page2pa>
c01048e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ee:	c1 e8 0c             	shr    $0xc,%eax
c01048f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048f4:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01048f9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048fc:	72 23                	jb     c0104921 <page2kva+0x4a>
c01048fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104901:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104905:	c7 44 24 08 9c 9e 10 	movl   $0xc0109e9c,0x8(%esp)
c010490c:	c0 
c010490d:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0104914:	00 
c0104915:	c7 04 24 8b 9e 10 c0 	movl   $0xc0109e8b,(%esp)
c010491c:	e8 09 c4 ff ff       	call   c0100d2a <__panic>
c0104921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104924:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104929:	89 ec                	mov    %ebp,%esp
c010492b:	5d                   	pop    %ebp
c010492c:	c3                   	ret    

c010492d <kva2page>:
kva2page(void *kva) {
c010492d:	55                   	push   %ebp
c010492e:	89 e5                	mov    %esp,%ebp
c0104930:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104933:	8b 45 08             	mov    0x8(%ebp),%eax
c0104936:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104939:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104940:	77 23                	ja     c0104965 <kva2page+0x38>
c0104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104945:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104949:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c0104950:	c0 
c0104951:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104958:	00 
c0104959:	c7 04 24 8b 9e 10 c0 	movl   $0xc0109e8b,(%esp)
c0104960:	e8 c5 c3 ff ff       	call   c0100d2a <__panic>
c0104965:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104968:	05 00 00 00 40       	add    $0x40000000,%eax
c010496d:	89 04 24             	mov    %eax,(%esp)
c0104970:	e8 1a ff ff ff       	call   c010488f <pa2page>
}
c0104975:	89 ec                	mov    %ebp,%esp
c0104977:	5d                   	pop    %ebp
c0104978:	c3                   	ret    

c0104979 <pte2page>:
pte2page(pte_t pte) {
c0104979:	55                   	push   %ebp
c010497a:	89 e5                	mov    %esp,%ebp
c010497c:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010497f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104982:	83 e0 01             	and    $0x1,%eax
c0104985:	85 c0                	test   %eax,%eax
c0104987:	75 1c                	jne    c01049a5 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104989:	c7 44 24 08 e4 9e 10 	movl   $0xc0109ee4,0x8(%esp)
c0104990:	c0 
c0104991:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104998:	00 
c0104999:	c7 04 24 8b 9e 10 c0 	movl   $0xc0109e8b,(%esp)
c01049a0:	e8 85 c3 ff ff       	call   c0100d2a <__panic>
    return pa2page(PTE_ADDR(pte));
c01049a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01049a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049ad:	89 04 24             	mov    %eax,(%esp)
c01049b0:	e8 da fe ff ff       	call   c010488f <pa2page>
}
c01049b5:	89 ec                	mov    %ebp,%esp
c01049b7:	5d                   	pop    %ebp
c01049b8:	c3                   	ret    

c01049b9 <pde2page>:
pde2page(pde_t pde) {
c01049b9:	55                   	push   %ebp
c01049ba:	89 e5                	mov    %esp,%ebp
c01049bc:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01049bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01049c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01049c7:	89 04 24             	mov    %eax,(%esp)
c01049ca:	e8 c0 fe ff ff       	call   c010488f <pa2page>
}
c01049cf:	89 ec                	mov    %ebp,%esp
c01049d1:	5d                   	pop    %ebp
c01049d2:	c3                   	ret    

c01049d3 <page_ref>:
page_ref(struct Page *page) {
c01049d3:	55                   	push   %ebp
c01049d4:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01049d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01049d9:	8b 00                	mov    (%eax),%eax
}
c01049db:	5d                   	pop    %ebp
c01049dc:	c3                   	ret    

c01049dd <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01049dd:	55                   	push   %ebp
c01049de:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01049e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01049e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01049e6:	89 10                	mov    %edx,(%eax)
}
c01049e8:	90                   	nop
c01049e9:	5d                   	pop    %ebp
c01049ea:	c3                   	ret    

c01049eb <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01049eb:	55                   	push   %ebp
c01049ec:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01049ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01049f1:	8b 00                	mov    (%eax),%eax
c01049f3:	8d 50 01             	lea    0x1(%eax),%edx
c01049f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01049f9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01049fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01049fe:	8b 00                	mov    (%eax),%eax
}
c0104a00:	5d                   	pop    %ebp
c0104a01:	c3                   	ret    

c0104a02 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104a02:	55                   	push   %ebp
c0104a03:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a08:	8b 00                	mov    (%eax),%eax
c0104a0a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a10:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104a12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a15:	8b 00                	mov    (%eax),%eax
}
c0104a17:	5d                   	pop    %ebp
c0104a18:	c3                   	ret    

c0104a19 <__intr_save>:
__intr_save(void) {
c0104a19:	55                   	push   %ebp
c0104a1a:	89 e5                	mov    %esp,%ebp
c0104a1c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104a1f:	9c                   	pushf  
c0104a20:	58                   	pop    %eax
c0104a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104a27:	25 00 02 00 00       	and    $0x200,%eax
c0104a2c:	85 c0                	test   %eax,%eax
c0104a2e:	74 0c                	je     c0104a3c <__intr_save+0x23>
        intr_disable();
c0104a30:	e8 ab d5 ff ff       	call   c0101fe0 <intr_disable>
        return 1;
c0104a35:	b8 01 00 00 00       	mov    $0x1,%eax
c0104a3a:	eb 05                	jmp    c0104a41 <__intr_save+0x28>
    return 0;
c0104a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104a41:	89 ec                	mov    %ebp,%esp
c0104a43:	5d                   	pop    %ebp
c0104a44:	c3                   	ret    

c0104a45 <__intr_restore>:
__intr_restore(bool flag) {
c0104a45:	55                   	push   %ebp
c0104a46:	89 e5                	mov    %esp,%ebp
c0104a48:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104a4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104a4f:	74 05                	je     c0104a56 <__intr_restore+0x11>
        intr_enable();
c0104a51:	e8 82 d5 ff ff       	call   c0101fd8 <intr_enable>
}
c0104a56:	90                   	nop
c0104a57:	89 ec                	mov    %ebp,%esp
c0104a59:	5d                   	pop    %ebp
c0104a5a:	c3                   	ret    

c0104a5b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104a5b:	55                   	push   %ebp
c0104a5c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104a5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a61:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104a64:	b8 23 00 00 00       	mov    $0x23,%eax
c0104a69:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104a6b:	b8 23 00 00 00       	mov    $0x23,%eax
c0104a70:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104a72:	b8 10 00 00 00       	mov    $0x10,%eax
c0104a77:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104a79:	b8 10 00 00 00       	mov    $0x10,%eax
c0104a7e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104a80:	b8 10 00 00 00       	mov    $0x10,%eax
c0104a85:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104a87:	ea 8e 4a 10 c0 08 00 	ljmp   $0x8,$0xc0104a8e
}
c0104a8e:	90                   	nop
c0104a8f:	5d                   	pop    %ebp
c0104a90:	c3                   	ret    

c0104a91 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104a91:	55                   	push   %ebp
c0104a92:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a97:	a3 24 70 12 c0       	mov    %eax,0xc0127024
}
c0104a9c:	90                   	nop
c0104a9d:	5d                   	pop    %ebp
c0104a9e:	c3                   	ret    

c0104a9f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104a9f:	55                   	push   %ebp
c0104aa0:	89 e5                	mov    %esp,%ebp
c0104aa2:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104aa5:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0104aaa:	89 04 24             	mov    %eax,(%esp)
c0104aad:	e8 df ff ff ff       	call   c0104a91 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104ab2:	66 c7 05 28 70 12 c0 	movw   $0x10,0xc0127028
c0104ab9:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104abb:	66 c7 05 28 3a 12 c0 	movw   $0x68,0xc0123a28
c0104ac2:	68 00 
c0104ac4:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c0104ac9:	0f b7 c0             	movzwl %ax,%eax
c0104acc:	66 a3 2a 3a 12 c0    	mov    %ax,0xc0123a2a
c0104ad2:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c0104ad7:	c1 e8 10             	shr    $0x10,%eax
c0104ada:	a2 2c 3a 12 c0       	mov    %al,0xc0123a2c
c0104adf:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104ae6:	24 f0                	and    $0xf0,%al
c0104ae8:	0c 09                	or     $0x9,%al
c0104aea:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104aef:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104af6:	24 ef                	and    $0xef,%al
c0104af8:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104afd:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104b04:	24 9f                	and    $0x9f,%al
c0104b06:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104b0b:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104b12:	0c 80                	or     $0x80,%al
c0104b14:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104b19:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104b20:	24 f0                	and    $0xf0,%al
c0104b22:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104b27:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104b2e:	24 ef                	and    $0xef,%al
c0104b30:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104b35:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104b3c:	24 df                	and    $0xdf,%al
c0104b3e:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104b43:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104b4a:	0c 40                	or     $0x40,%al
c0104b4c:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104b51:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104b58:	24 7f                	and    $0x7f,%al
c0104b5a:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104b5f:	b8 20 70 12 c0       	mov    $0xc0127020,%eax
c0104b64:	c1 e8 18             	shr    $0x18,%eax
c0104b67:	a2 2f 3a 12 c0       	mov    %al,0xc0123a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104b6c:	c7 04 24 30 3a 12 c0 	movl   $0xc0123a30,(%esp)
c0104b73:	e8 e3 fe ff ff       	call   c0104a5b <lgdt>
c0104b78:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104b7e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104b82:	0f 00 d8             	ltr    %ax
}
c0104b85:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104b86:	90                   	nop
c0104b87:	89 ec                	mov    %ebp,%esp
c0104b89:	5d                   	pop    %ebp
c0104b8a:	c3                   	ret    

c0104b8b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104b8b:	55                   	push   %ebp
c0104b8c:	89 e5                	mov    %esp,%ebp
c0104b8e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104b91:	c7 05 0c 70 12 c0 50 	movl   $0xc0109e50,0xc012700c
c0104b98:	9e 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104b9b:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104ba0:	8b 00                	mov    (%eax),%eax
c0104ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ba6:	c7 04 24 10 9f 10 c0 	movl   $0xc0109f10,(%esp)
c0104bad:	e8 f3 b7 ff ff       	call   c01003a5 <cprintf>
    pmm_manager->init();
c0104bb2:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104bb7:	8b 40 04             	mov    0x4(%eax),%eax
c0104bba:	ff d0                	call   *%eax
}
c0104bbc:	90                   	nop
c0104bbd:	89 ec                	mov    %ebp,%esp
c0104bbf:	5d                   	pop    %ebp
c0104bc0:	c3                   	ret    

c0104bc1 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104bc1:	55                   	push   %ebp
c0104bc2:	89 e5                	mov    %esp,%ebp
c0104bc4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104bc7:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104bcc:	8b 40 08             	mov    0x8(%eax),%eax
c0104bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104bd2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bd6:	8b 55 08             	mov    0x8(%ebp),%edx
c0104bd9:	89 14 24             	mov    %edx,(%esp)
c0104bdc:	ff d0                	call   *%eax
}
c0104bde:	90                   	nop
c0104bdf:	89 ec                	mov    %ebp,%esp
c0104be1:	5d                   	pop    %ebp
c0104be2:	c3                   	ret    

c0104be3 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104be3:	55                   	push   %ebp
c0104be4:	89 e5                	mov    %esp,%ebp
c0104be6:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104be9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0104bf0:	e8 24 fe ff ff       	call   c0104a19 <__intr_save>
c0104bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0104bf8:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104bfd:	8b 40 0c             	mov    0xc(%eax),%eax
c0104c00:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c03:	89 14 24             	mov    %edx,(%esp)
c0104c06:	ff d0                	call   *%eax
c0104c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0104c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c0e:	89 04 24             	mov    %eax,(%esp)
c0104c11:	e8 2f fe ff ff       	call   c0104a45 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0104c16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c1a:	75 2d                	jne    c0104c49 <alloc_pages+0x66>
c0104c1c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0104c20:	77 27                	ja     c0104c49 <alloc_pages+0x66>
c0104c22:	a1 a4 70 12 c0       	mov    0xc01270a4,%eax
c0104c27:	85 c0                	test   %eax,%eax
c0104c29:	74 1e                	je     c0104c49 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0104c2b:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c2e:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0104c33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c3a:	00 
c0104c3b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c3f:	89 04 24             	mov    %eax,(%esp)
c0104c42:	e8 ff 19 00 00       	call   c0106646 <swap_out>
    {
c0104c47:	eb a7                	jmp    c0104bf0 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0104c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104c4c:	89 ec                	mov    %ebp,%esp
c0104c4e:	5d                   	pop    %ebp
c0104c4f:	c3                   	ret    

c0104c50 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104c50:	55                   	push   %ebp
c0104c51:	89 e5                	mov    %esp,%ebp
c0104c53:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104c56:	e8 be fd ff ff       	call   c0104a19 <__intr_save>
c0104c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104c5e:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104c63:	8b 40 10             	mov    0x10(%eax),%eax
c0104c66:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104c69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c6d:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c70:	89 14 24             	mov    %edx,(%esp)
c0104c73:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c78:	89 04 24             	mov    %eax,(%esp)
c0104c7b:	e8 c5 fd ff ff       	call   c0104a45 <__intr_restore>
}
c0104c80:	90                   	nop
c0104c81:	89 ec                	mov    %ebp,%esp
c0104c83:	5d                   	pop    %ebp
c0104c84:	c3                   	ret    

c0104c85 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104c85:	55                   	push   %ebp
c0104c86:	89 e5                	mov    %esp,%ebp
c0104c88:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104c8b:	e8 89 fd ff ff       	call   c0104a19 <__intr_save>
c0104c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104c93:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c0104c98:	8b 40 14             	mov    0x14(%eax),%eax
c0104c9b:	ff d0                	call   *%eax
c0104c9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca3:	89 04 24             	mov    %eax,(%esp)
c0104ca6:	e8 9a fd ff ff       	call   c0104a45 <__intr_restore>
    return ret;
c0104cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104cae:	89 ec                	mov    %ebp,%esp
c0104cb0:	5d                   	pop    %ebp
c0104cb1:	c3                   	ret    

c0104cb2 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104cb2:	55                   	push   %ebp
c0104cb3:	89 e5                	mov    %esp,%ebp
c0104cb5:	57                   	push   %edi
c0104cb6:	56                   	push   %esi
c0104cb7:	53                   	push   %ebx
c0104cb8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104cbe:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104cc5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104ccc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104cd3:	c7 04 24 27 9f 10 c0 	movl   $0xc0109f27,(%esp)
c0104cda:	e8 c6 b6 ff ff       	call   c01003a5 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104cdf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104ce6:	e9 0c 01 00 00       	jmp    c0104df7 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104ceb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104cee:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104cf1:	89 d0                	mov    %edx,%eax
c0104cf3:	c1 e0 02             	shl    $0x2,%eax
c0104cf6:	01 d0                	add    %edx,%eax
c0104cf8:	c1 e0 02             	shl    $0x2,%eax
c0104cfb:	01 c8                	add    %ecx,%eax
c0104cfd:	8b 50 08             	mov    0x8(%eax),%edx
c0104d00:	8b 40 04             	mov    0x4(%eax),%eax
c0104d03:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104d06:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104d09:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d0f:	89 d0                	mov    %edx,%eax
c0104d11:	c1 e0 02             	shl    $0x2,%eax
c0104d14:	01 d0                	add    %edx,%eax
c0104d16:	c1 e0 02             	shl    $0x2,%eax
c0104d19:	01 c8                	add    %ecx,%eax
c0104d1b:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104d1e:	8b 58 10             	mov    0x10(%eax),%ebx
c0104d21:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104d24:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104d27:	01 c8                	add    %ecx,%eax
c0104d29:	11 da                	adc    %ebx,%edx
c0104d2b:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104d2e:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104d31:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d34:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d37:	89 d0                	mov    %edx,%eax
c0104d39:	c1 e0 02             	shl    $0x2,%eax
c0104d3c:	01 d0                	add    %edx,%eax
c0104d3e:	c1 e0 02             	shl    $0x2,%eax
c0104d41:	01 c8                	add    %ecx,%eax
c0104d43:	83 c0 14             	add    $0x14,%eax
c0104d46:	8b 00                	mov    (%eax),%eax
c0104d48:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104d4e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104d51:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104d54:	83 c0 ff             	add    $0xffffffff,%eax
c0104d57:	83 d2 ff             	adc    $0xffffffff,%edx
c0104d5a:	89 c6                	mov    %eax,%esi
c0104d5c:	89 d7                	mov    %edx,%edi
c0104d5e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104d61:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d64:	89 d0                	mov    %edx,%eax
c0104d66:	c1 e0 02             	shl    $0x2,%eax
c0104d69:	01 d0                	add    %edx,%eax
c0104d6b:	c1 e0 02             	shl    $0x2,%eax
c0104d6e:	01 c8                	add    %ecx,%eax
c0104d70:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104d73:	8b 58 10             	mov    0x10(%eax),%ebx
c0104d76:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104d7c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104d80:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104d84:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104d88:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104d8b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104d8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d92:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104d96:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104d9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104d9e:	c7 04 24 34 9f 10 c0 	movl   $0xc0109f34,(%esp)
c0104da5:	e8 fb b5 ff ff       	call   c01003a5 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104daa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104dad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104db0:	89 d0                	mov    %edx,%eax
c0104db2:	c1 e0 02             	shl    $0x2,%eax
c0104db5:	01 d0                	add    %edx,%eax
c0104db7:	c1 e0 02             	shl    $0x2,%eax
c0104dba:	01 c8                	add    %ecx,%eax
c0104dbc:	83 c0 14             	add    $0x14,%eax
c0104dbf:	8b 00                	mov    (%eax),%eax
c0104dc1:	83 f8 01             	cmp    $0x1,%eax
c0104dc4:	75 2e                	jne    c0104df4 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104dc9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104dcc:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104dcf:	89 d0                	mov    %edx,%eax
c0104dd1:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104dd4:	73 1e                	jae    c0104df4 <page_init+0x142>
c0104dd6:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104ddb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104de0:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104de3:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104de6:	72 0c                	jb     c0104df4 <page_init+0x142>
                maxpa = end;
c0104de8:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104deb:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104dee:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104df1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104df4:	ff 45 dc             	incl   -0x24(%ebp)
c0104df7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104dfa:	8b 00                	mov    (%eax),%eax
c0104dfc:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104dff:	0f 8c e6 fe ff ff    	jl     c0104ceb <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104e05:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104e0a:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e0f:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104e12:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104e15:	73 0e                	jae    c0104e25 <page_init+0x173>
        maxpa = KMEMSIZE;
c0104e17:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104e1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104e2b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104e2f:	c1 ea 0c             	shr    $0xc,%edx
c0104e32:	a3 04 70 12 c0       	mov    %eax,0xc0127004
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104e37:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104e3e:	b8 74 71 12 c0       	mov    $0xc0127174,%eax
c0104e43:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104e46:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104e49:	01 d0                	add    %edx,%eax
c0104e4b:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104e4e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104e51:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e56:	f7 75 c0             	divl   -0x40(%ebp)
c0104e59:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104e5c:	29 d0                	sub    %edx,%eax
c0104e5e:	a3 00 70 12 c0       	mov    %eax,0xc0127000

    for (i = 0; i < npage; i ++) {
c0104e63:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104e6a:	eb 28                	jmp    c0104e94 <page_init+0x1e2>
        SetPageReserved(pages + i);
c0104e6c:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c0104e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e75:	c1 e0 05             	shl    $0x5,%eax
c0104e78:	01 d0                	add    %edx,%eax
c0104e7a:	83 c0 04             	add    $0x4,%eax
c0104e7d:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104e84:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104e87:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104e8a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104e8d:	0f ab 10             	bts    %edx,(%eax)
}
c0104e90:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0104e91:	ff 45 dc             	incl   -0x24(%ebp)
c0104e94:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104e97:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c0104e9c:	39 c2                	cmp    %eax,%edx
c0104e9e:	72 cc                	jb     c0104e6c <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104ea0:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c0104ea5:	c1 e0 05             	shl    $0x5,%eax
c0104ea8:	89 c2                	mov    %eax,%edx
c0104eaa:	a1 00 70 12 c0       	mov    0xc0127000,%eax
c0104eaf:	01 d0                	add    %edx,%eax
c0104eb1:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104eb4:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104ebb:	77 23                	ja     c0104ee0 <page_init+0x22e>
c0104ebd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104ec0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ec4:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c0104ecb:	c0 
c0104ecc:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104ed3:	00 
c0104ed4:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0104edb:	e8 4a be ff ff       	call   c0100d2a <__panic>
c0104ee0:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104ee3:	05 00 00 00 40       	add    $0x40000000,%eax
c0104ee8:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104eeb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104ef2:	e9 53 01 00 00       	jmp    c010504a <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104ef7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104efa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104efd:	89 d0                	mov    %edx,%eax
c0104eff:	c1 e0 02             	shl    $0x2,%eax
c0104f02:	01 d0                	add    %edx,%eax
c0104f04:	c1 e0 02             	shl    $0x2,%eax
c0104f07:	01 c8                	add    %ecx,%eax
c0104f09:	8b 50 08             	mov    0x8(%eax),%edx
c0104f0c:	8b 40 04             	mov    0x4(%eax),%eax
c0104f0f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104f12:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104f15:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104f18:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f1b:	89 d0                	mov    %edx,%eax
c0104f1d:	c1 e0 02             	shl    $0x2,%eax
c0104f20:	01 d0                	add    %edx,%eax
c0104f22:	c1 e0 02             	shl    $0x2,%eax
c0104f25:	01 c8                	add    %ecx,%eax
c0104f27:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104f2a:	8b 58 10             	mov    0x10(%eax),%ebx
c0104f2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f30:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f33:	01 c8                	add    %ecx,%eax
c0104f35:	11 da                	adc    %ebx,%edx
c0104f37:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104f3a:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104f3d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104f40:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f43:	89 d0                	mov    %edx,%eax
c0104f45:	c1 e0 02             	shl    $0x2,%eax
c0104f48:	01 d0                	add    %edx,%eax
c0104f4a:	c1 e0 02             	shl    $0x2,%eax
c0104f4d:	01 c8                	add    %ecx,%eax
c0104f4f:	83 c0 14             	add    $0x14,%eax
c0104f52:	8b 00                	mov    (%eax),%eax
c0104f54:	83 f8 01             	cmp    $0x1,%eax
c0104f57:	0f 85 ea 00 00 00    	jne    c0105047 <page_init+0x395>
            if (begin < freemem) {
c0104f5d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f60:	ba 00 00 00 00       	mov    $0x0,%edx
c0104f65:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104f68:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104f6b:	19 d1                	sbb    %edx,%ecx
c0104f6d:	73 0d                	jae    c0104f7c <page_init+0x2ca>
                begin = freemem;
c0104f6f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f72:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104f75:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104f7c:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104f81:	b8 00 00 00 00       	mov    $0x0,%eax
c0104f86:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104f89:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104f8c:	73 0e                	jae    c0104f9c <page_init+0x2ea>
                end = KMEMSIZE;
c0104f8e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104f95:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104fa2:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104fa5:	89 d0                	mov    %edx,%eax
c0104fa7:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104faa:	0f 83 97 00 00 00    	jae    c0105047 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0104fb0:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104fb7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104fba:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104fbd:	01 d0                	add    %edx,%eax
c0104fbf:	48                   	dec    %eax
c0104fc0:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104fc3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104fc6:	ba 00 00 00 00       	mov    $0x0,%edx
c0104fcb:	f7 75 b0             	divl   -0x50(%ebp)
c0104fce:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104fd1:	29 d0                	sub    %edx,%eax
c0104fd3:	ba 00 00 00 00       	mov    $0x0,%edx
c0104fd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104fdb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104fde:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104fe1:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104fe4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104fe7:	ba 00 00 00 00       	mov    $0x0,%edx
c0104fec:	89 c7                	mov    %eax,%edi
c0104fee:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104ff4:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104ff7:	89 d0                	mov    %edx,%eax
c0104ff9:	83 e0 00             	and    $0x0,%eax
c0104ffc:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104fff:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105002:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105005:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105008:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010500b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010500e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105011:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105014:	89 d0                	mov    %edx,%eax
c0105016:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105019:	73 2c                	jae    c0105047 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010501b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010501e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105021:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0105024:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0105027:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010502b:	c1 ea 0c             	shr    $0xc,%edx
c010502e:	89 c3                	mov    %eax,%ebx
c0105030:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105033:	89 04 24             	mov    %eax,(%esp)
c0105036:	e8 54 f8 ff ff       	call   c010488f <pa2page>
c010503b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010503f:	89 04 24             	mov    %eax,(%esp)
c0105042:	e8 7a fb ff ff       	call   c0104bc1 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0105047:	ff 45 dc             	incl   -0x24(%ebp)
c010504a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010504d:	8b 00                	mov    (%eax),%eax
c010504f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105052:	0f 8c 9f fe ff ff    	jl     c0104ef7 <page_init+0x245>
                }
            }
        }
    }
}
c0105058:	90                   	nop
c0105059:	90                   	nop
c010505a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0105060:	5b                   	pop    %ebx
c0105061:	5e                   	pop    %esi
c0105062:	5f                   	pop    %edi
c0105063:	5d                   	pop    %ebp
c0105064:	c3                   	ret    

c0105065 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0105065:	55                   	push   %ebp
c0105066:	89 e5                	mov    %esp,%ebp
c0105068:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010506b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010506e:	33 45 14             	xor    0x14(%ebp),%eax
c0105071:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105076:	85 c0                	test   %eax,%eax
c0105078:	74 24                	je     c010509e <boot_map_segment+0x39>
c010507a:	c7 44 24 0c 72 9f 10 	movl   $0xc0109f72,0xc(%esp)
c0105081:	c0 
c0105082:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105089:	c0 
c010508a:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0105091:	00 
c0105092:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105099:	e8 8c bc ff ff       	call   c0100d2a <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010509e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01050a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050a8:	25 ff 0f 00 00       	and    $0xfff,%eax
c01050ad:	89 c2                	mov    %eax,%edx
c01050af:	8b 45 10             	mov    0x10(%ebp),%eax
c01050b2:	01 c2                	add    %eax,%edx
c01050b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050b7:	01 d0                	add    %edx,%eax
c01050b9:	48                   	dec    %eax
c01050ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01050bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050c0:	ba 00 00 00 00       	mov    $0x0,%edx
c01050c5:	f7 75 f0             	divl   -0x10(%ebp)
c01050c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050cb:	29 d0                	sub    %edx,%eax
c01050cd:	c1 e8 0c             	shr    $0xc,%eax
c01050d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01050d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01050d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050e1:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01050e4:	8b 45 14             	mov    0x14(%ebp),%eax
c01050e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050f2:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01050f5:	eb 68                	jmp    c010515f <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01050f7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01050fe:	00 
c01050ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105106:	8b 45 08             	mov    0x8(%ebp),%eax
c0105109:	89 04 24             	mov    %eax,(%esp)
c010510c:	e8 88 01 00 00       	call   c0105299 <get_pte>
c0105111:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0105114:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105118:	75 24                	jne    c010513e <boot_map_segment+0xd9>
c010511a:	c7 44 24 0c 9e 9f 10 	movl   $0xc0109f9e,0xc(%esp)
c0105121:	c0 
c0105122:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105129:	c0 
c010512a:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0105131:	00 
c0105132:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105139:	e8 ec bb ff ff       	call   c0100d2a <__panic>
        *ptep = pa | PTE_P | perm;
c010513e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105141:	0b 45 18             	or     0x18(%ebp),%eax
c0105144:	83 c8 01             	or     $0x1,%eax
c0105147:	89 c2                	mov    %eax,%edx
c0105149:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010514c:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010514e:	ff 4d f4             	decl   -0xc(%ebp)
c0105151:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0105158:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010515f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105163:	75 92                	jne    c01050f7 <boot_map_segment+0x92>
    }
}
c0105165:	90                   	nop
c0105166:	90                   	nop
c0105167:	89 ec                	mov    %ebp,%esp
c0105169:	5d                   	pop    %ebp
c010516a:	c3                   	ret    

c010516b <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010516b:	55                   	push   %ebp
c010516c:	89 e5                	mov    %esp,%ebp
c010516e:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0105171:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105178:	e8 66 fa ff ff       	call   c0104be3 <alloc_pages>
c010517d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105180:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105184:	75 1c                	jne    c01051a2 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105186:	c7 44 24 08 ab 9f 10 	movl   $0xc0109fab,0x8(%esp)
c010518d:	c0 
c010518e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0105195:	00 
c0105196:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010519d:	e8 88 bb ff ff       	call   c0100d2a <__panic>
    }
    return page2kva(p);
c01051a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051a5:	89 04 24             	mov    %eax,(%esp)
c01051a8:	e8 2a f7 ff ff       	call   c01048d7 <page2kva>
}
c01051ad:	89 ec                	mov    %ebp,%esp
c01051af:	5d                   	pop    %ebp
c01051b0:	c3                   	ret    

c01051b1 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01051b1:	55                   	push   %ebp
c01051b2:	89 e5                	mov    %esp,%ebp
c01051b4:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01051b7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01051bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01051bf:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01051c6:	77 23                	ja     c01051eb <pmm_init+0x3a>
c01051c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01051cf:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c01051d6:	c0 
c01051d7:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01051de:	00 
c01051df:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01051e6:	e8 3f bb ff ff       	call   c0100d2a <__panic>
c01051eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051ee:	05 00 00 00 40       	add    $0x40000000,%eax
c01051f3:	a3 08 70 12 c0       	mov    %eax,0xc0127008
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01051f8:	e8 8e f9 ff ff       	call   c0104b8b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01051fd:	e8 b0 fa ff ff       	call   c0104cb2 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0105202:	e8 ba 04 00 00       	call   c01056c1 <check_alloc_page>

    check_pgdir();
c0105207:	e8 d6 04 00 00       	call   c01056e2 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010520c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105211:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105214:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010521b:	77 23                	ja     c0105240 <pmm_init+0x8f>
c010521d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105220:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105224:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c010522b:	c0 
c010522c:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0105233:	00 
c0105234:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010523b:	e8 ea ba ff ff       	call   c0100d2a <__panic>
c0105240:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105243:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0105249:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010524e:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105253:	83 ca 03             	or     $0x3,%edx
c0105256:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105258:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010525d:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105264:	00 
c0105265:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010526c:	00 
c010526d:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105274:	38 
c0105275:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010527c:	c0 
c010527d:	89 04 24             	mov    %eax,(%esp)
c0105280:	e8 e0 fd ff ff       	call   c0105065 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105285:	e8 15 f8 ff ff       	call   c0104a9f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010528a:	e8 f1 0a 00 00       	call   c0105d80 <check_boot_pgdir>

    print_pgdir();
c010528f:	e8 6e 0f 00 00       	call   c0106202 <print_pgdir>

}
c0105294:	90                   	nop
c0105295:	89 ec                	mov    %ebp,%esp
c0105297:	5d                   	pop    %ebp
c0105298:	c3                   	ret    

c0105299 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105299:	55                   	push   %ebp
c010529a:	89 e5                	mov    %esp,%ebp
c010529c:	83 ec 38             	sub    $0x38,%esp
        }
        return NULL;          // (8) return page table entry
    #endif
    */
   
   pde_t *pdep = &pgdir[PDX(la)];
c010529f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052a2:	c1 e8 16             	shr    $0x16,%eax
c01052a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01052af:	01 d0                	add    %edx,%eax
c01052b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b7:	8b 00                	mov    (%eax),%eax
c01052b9:	83 e0 01             	and    $0x1,%eax
c01052bc:	85 c0                	test   %eax,%eax
c01052be:	0f 85 af 00 00 00    	jne    c0105373 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01052c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01052c8:	74 15                	je     c01052df <get_pte+0x46>
c01052ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052d1:	e8 0d f9 ff ff       	call   c0104be3 <alloc_pages>
c01052d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01052dd:	75 0a                	jne    c01052e9 <get_pte+0x50>
            return NULL;
c01052df:	b8 00 00 00 00       	mov    $0x0,%eax
c01052e4:	e9 e7 00 00 00       	jmp    c01053d0 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c01052e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052f0:	00 
c01052f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052f4:	89 04 24             	mov    %eax,(%esp)
c01052f7:	e8 e1 f6 ff ff       	call   c01049dd <set_page_ref>
        uintptr_t pa = page2pa(page);
c01052fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052ff:	89 04 24             	mov    %eax,(%esp)
c0105302:	e8 70 f5 ff ff       	call   c0104877 <page2pa>
c0105307:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c010530a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010530d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105310:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105313:	c1 e8 0c             	shr    $0xc,%eax
c0105316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105319:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c010531e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105321:	72 23                	jb     c0105346 <get_pte+0xad>
c0105323:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105326:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010532a:	c7 44 24 08 9c 9e 10 	movl   $0xc0109e9c,0x8(%esp)
c0105331:	c0 
c0105332:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0105339:	00 
c010533a:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105341:	e8 e4 b9 ff ff       	call   c0100d2a <__panic>
c0105346:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105349:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010534e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105355:	00 
c0105356:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010535d:	00 
c010535e:	89 04 24             	mov    %eax,(%esp)
c0105361:	e8 67 3c 00 00       	call   c0108fcd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0105366:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105369:	83 c8 07             	or     $0x7,%eax
c010536c:	89 c2                	mov    %eax,%edx
c010536e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105371:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0105373:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105376:	8b 00                	mov    (%eax),%eax
c0105378:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010537d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105380:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105383:	c1 e8 0c             	shr    $0xc,%eax
c0105386:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105389:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c010538e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105391:	72 23                	jb     c01053b6 <get_pte+0x11d>
c0105393:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105396:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010539a:	c7 44 24 08 9c 9e 10 	movl   $0xc0109e9c,0x8(%esp)
c01053a1:	c0 
c01053a2:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01053a9:	00 
c01053aa:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01053b1:	e8 74 b9 ff ff       	call   c0100d2a <__panic>
c01053b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01053be:	89 c2                	mov    %eax,%edx
c01053c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053c3:	c1 e8 0c             	shr    $0xc,%eax
c01053c6:	25 ff 03 00 00       	and    $0x3ff,%eax
c01053cb:	c1 e0 02             	shl    $0x2,%eax
c01053ce:	01 d0                	add    %edx,%eax
}
c01053d0:	89 ec                	mov    %ebp,%esp
c01053d2:	5d                   	pop    %ebp
c01053d3:	c3                   	ret    

c01053d4 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01053d4:	55                   	push   %ebp
c01053d5:	89 e5                	mov    %esp,%ebp
c01053d7:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01053da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01053e1:	00 
c01053e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01053ec:	89 04 24             	mov    %eax,(%esp)
c01053ef:	e8 a5 fe ff ff       	call   c0105299 <get_pte>
c01053f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01053f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01053fb:	74 08                	je     c0105405 <get_page+0x31>
        *ptep_store = ptep;
c01053fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105400:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105403:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105405:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105409:	74 1b                	je     c0105426 <get_page+0x52>
c010540b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010540e:	8b 00                	mov    (%eax),%eax
c0105410:	83 e0 01             	and    $0x1,%eax
c0105413:	85 c0                	test   %eax,%eax
c0105415:	74 0f                	je     c0105426 <get_page+0x52>
        return pte2page(*ptep);
c0105417:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010541a:	8b 00                	mov    (%eax),%eax
c010541c:	89 04 24             	mov    %eax,(%esp)
c010541f:	e8 55 f5 ff ff       	call   c0104979 <pte2page>
c0105424:	eb 05                	jmp    c010542b <get_page+0x57>
    }
    return NULL;
c0105426:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010542b:	89 ec                	mov    %ebp,%esp
c010542d:	5d                   	pop    %ebp
c010542e:	c3                   	ret    

c010542f <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010542f:	55                   	push   %ebp
c0105430:	89 e5                	mov    %esp,%ebp
c0105432:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
*/

   	if (*ptep & PTE_P) {
c0105435:	8b 45 10             	mov    0x10(%ebp),%eax
c0105438:	8b 00                	mov    (%eax),%eax
c010543a:	83 e0 01             	and    $0x1,%eax
c010543d:	85 c0                	test   %eax,%eax
c010543f:	74 4d                	je     c010548e <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0105441:	8b 45 10             	mov    0x10(%ebp),%eax
c0105444:	8b 00                	mov    (%eax),%eax
c0105446:	89 04 24             	mov    %eax,(%esp)
c0105449:	e8 2b f5 ff ff       	call   c0104979 <pte2page>
c010544e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0105451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105454:	89 04 24             	mov    %eax,(%esp)
c0105457:	e8 a6 f5 ff ff       	call   c0104a02 <page_ref_dec>
c010545c:	85 c0                	test   %eax,%eax
c010545e:	75 13                	jne    c0105473 <page_remove_pte+0x44>
            free_page(page);
c0105460:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105467:	00 
c0105468:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010546b:	89 04 24             	mov    %eax,(%esp)
c010546e:	e8 dd f7 ff ff       	call   c0104c50 <free_pages>
        }
        *ptep = 0;
c0105473:	8b 45 10             	mov    0x10(%ebp),%eax
c0105476:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010547c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010547f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105483:	8b 45 08             	mov    0x8(%ebp),%eax
c0105486:	89 04 24             	mov    %eax,(%esp)
c0105489:	e8 07 01 00 00       	call   c0105595 <tlb_invalidate>
    }

}
c010548e:	90                   	nop
c010548f:	89 ec                	mov    %ebp,%esp
c0105491:	5d                   	pop    %ebp
c0105492:	c3                   	ret    

c0105493 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105493:	55                   	push   %ebp
c0105494:	89 e5                	mov    %esp,%ebp
c0105496:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105499:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01054a0:	00 
c01054a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ab:	89 04 24             	mov    %eax,(%esp)
c01054ae:	e8 e6 fd ff ff       	call   c0105299 <get_pte>
c01054b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01054b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01054ba:	74 19                	je     c01054d5 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01054bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054bf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01054cd:	89 04 24             	mov    %eax,(%esp)
c01054d0:	e8 5a ff ff ff       	call   c010542f <page_remove_pte>
    }
}
c01054d5:	90                   	nop
c01054d6:	89 ec                	mov    %ebp,%esp
c01054d8:	5d                   	pop    %ebp
c01054d9:	c3                   	ret    

c01054da <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01054da:	55                   	push   %ebp
c01054db:	89 e5                	mov    %esp,%ebp
c01054dd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01054e0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01054e7:	00 
c01054e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01054eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f2:	89 04 24             	mov    %eax,(%esp)
c01054f5:	e8 9f fd ff ff       	call   c0105299 <get_pte>
c01054fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01054fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105501:	75 0a                	jne    c010550d <page_insert+0x33>
        return -E_NO_MEM;
c0105503:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105508:	e9 84 00 00 00       	jmp    c0105591 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010550d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105510:	89 04 24             	mov    %eax,(%esp)
c0105513:	e8 d3 f4 ff ff       	call   c01049eb <page_ref_inc>
    if (*ptep & PTE_P) {
c0105518:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010551b:	8b 00                	mov    (%eax),%eax
c010551d:	83 e0 01             	and    $0x1,%eax
c0105520:	85 c0                	test   %eax,%eax
c0105522:	74 3e                	je     c0105562 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105524:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105527:	8b 00                	mov    (%eax),%eax
c0105529:	89 04 24             	mov    %eax,(%esp)
c010552c:	e8 48 f4 ff ff       	call   c0104979 <pte2page>
c0105531:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105534:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105537:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010553a:	75 0d                	jne    c0105549 <page_insert+0x6f>
            page_ref_dec(page);
c010553c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010553f:	89 04 24             	mov    %eax,(%esp)
c0105542:	e8 bb f4 ff ff       	call   c0104a02 <page_ref_dec>
c0105547:	eb 19                	jmp    c0105562 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010554c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105550:	8b 45 10             	mov    0x10(%ebp),%eax
c0105553:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105557:	8b 45 08             	mov    0x8(%ebp),%eax
c010555a:	89 04 24             	mov    %eax,(%esp)
c010555d:	e8 cd fe ff ff       	call   c010542f <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105565:	89 04 24             	mov    %eax,(%esp)
c0105568:	e8 0a f3 ff ff       	call   c0104877 <page2pa>
c010556d:	0b 45 14             	or     0x14(%ebp),%eax
c0105570:	83 c8 01             	or     $0x1,%eax
c0105573:	89 c2                	mov    %eax,%edx
c0105575:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105578:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010557a:	8b 45 10             	mov    0x10(%ebp),%eax
c010557d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105581:	8b 45 08             	mov    0x8(%ebp),%eax
c0105584:	89 04 24             	mov    %eax,(%esp)
c0105587:	e8 09 00 00 00       	call   c0105595 <tlb_invalidate>
    return 0;
c010558c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105591:	89 ec                	mov    %ebp,%esp
c0105593:	5d                   	pop    %ebp
c0105594:	c3                   	ret    

c0105595 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105595:	55                   	push   %ebp
c0105596:	89 e5                	mov    %esp,%ebp
c0105598:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010559b:	0f 20 d8             	mov    %cr3,%eax
c010559e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01055a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01055a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055aa:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01055b1:	77 23                	ja     c01055d6 <tlb_invalidate+0x41>
c01055b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055ba:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c01055c1:	c0 
c01055c2:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c01055c9:	00 
c01055ca:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01055d1:	e8 54 b7 ff ff       	call   c0100d2a <__panic>
c01055d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055d9:	05 00 00 00 40       	add    $0x40000000,%eax
c01055de:	39 d0                	cmp    %edx,%eax
c01055e0:	75 0d                	jne    c01055ef <tlb_invalidate+0x5a>
        invlpg((void *)la);
c01055e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01055e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055eb:	0f 01 38             	invlpg (%eax)
}
c01055ee:	90                   	nop
    }
}
c01055ef:	90                   	nop
c01055f0:	89 ec                	mov    %ebp,%esp
c01055f2:	5d                   	pop    %ebp
c01055f3:	c3                   	ret    

c01055f4 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01055f4:	55                   	push   %ebp
c01055f5:	89 e5                	mov    %esp,%ebp
c01055f7:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01055fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105601:	e8 dd f5 ff ff       	call   c0104be3 <alloc_pages>
c0105606:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105609:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010560d:	0f 84 a7 00 00 00    	je     c01056ba <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105613:	8b 45 10             	mov    0x10(%ebp),%eax
c0105616:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010561a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010561d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105621:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105624:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105628:	8b 45 08             	mov    0x8(%ebp),%eax
c010562b:	89 04 24             	mov    %eax,(%esp)
c010562e:	e8 a7 fe ff ff       	call   c01054da <page_insert>
c0105633:	85 c0                	test   %eax,%eax
c0105635:	74 1a                	je     c0105651 <pgdir_alloc_page+0x5d>
            free_page(page);
c0105637:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010563e:	00 
c010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105642:	89 04 24             	mov    %eax,(%esp)
c0105645:	e8 06 f6 ff ff       	call   c0104c50 <free_pages>
            return NULL;
c010564a:	b8 00 00 00 00       	mov    $0x0,%eax
c010564f:	eb 6c                	jmp    c01056bd <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105651:	a1 a4 70 12 c0       	mov    0xc01270a4,%eax
c0105656:	85 c0                	test   %eax,%eax
c0105658:	74 60                	je     c01056ba <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c010565a:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c010565f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105666:	00 
c0105667:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010566a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010566e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105671:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105675:	89 04 24             	mov    %eax,(%esp)
c0105678:	e8 79 0f 00 00       	call   c01065f6 <swap_map_swappable>
            page->pra_vaddr=la;
c010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105680:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105683:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105689:	89 04 24             	mov    %eax,(%esp)
c010568c:	e8 42 f3 ff ff       	call   c01049d3 <page_ref>
c0105691:	83 f8 01             	cmp    $0x1,%eax
c0105694:	74 24                	je     c01056ba <pgdir_alloc_page+0xc6>
c0105696:	c7 44 24 0c c4 9f 10 	movl   $0xc0109fc4,0xc(%esp)
c010569d:	c0 
c010569e:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c01056a5:	c0 
c01056a6:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c01056ad:	00 
c01056ae:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01056b5:	e8 70 b6 ff ff       	call   c0100d2a <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c01056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056bd:	89 ec                	mov    %ebp,%esp
c01056bf:	5d                   	pop    %ebp
c01056c0:	c3                   	ret    

c01056c1 <check_alloc_page>:

static void
check_alloc_page(void) {
c01056c1:	55                   	push   %ebp
c01056c2:	89 e5                	mov    %esp,%ebp
c01056c4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01056c7:	a1 0c 70 12 c0       	mov    0xc012700c,%eax
c01056cc:	8b 40 18             	mov    0x18(%eax),%eax
c01056cf:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01056d1:	c7 04 24 d8 9f 10 c0 	movl   $0xc0109fd8,(%esp)
c01056d8:	e8 c8 ac ff ff       	call   c01003a5 <cprintf>
}
c01056dd:	90                   	nop
c01056de:	89 ec                	mov    %ebp,%esp
c01056e0:	5d                   	pop    %ebp
c01056e1:	c3                   	ret    

c01056e2 <check_pgdir>:

static void
check_pgdir(void) {
c01056e2:	55                   	push   %ebp
c01056e3:	89 e5                	mov    %esp,%ebp
c01056e5:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01056e8:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01056ed:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01056f2:	76 24                	jbe    c0105718 <check_pgdir+0x36>
c01056f4:	c7 44 24 0c f7 9f 10 	movl   $0xc0109ff7,0xc(%esp)
c01056fb:	c0 
c01056fc:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105703:	c0 
c0105704:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c010570b:	00 
c010570c:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105713:	e8 12 b6 ff ff       	call   c0100d2a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105718:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010571d:	85 c0                	test   %eax,%eax
c010571f:	74 0e                	je     c010572f <check_pgdir+0x4d>
c0105721:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105726:	25 ff 0f 00 00       	and    $0xfff,%eax
c010572b:	85 c0                	test   %eax,%eax
c010572d:	74 24                	je     c0105753 <check_pgdir+0x71>
c010572f:	c7 44 24 0c 14 a0 10 	movl   $0xc010a014,0xc(%esp)
c0105736:	c0 
c0105737:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010573e:	c0 
c010573f:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0105746:	00 
c0105747:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010574e:	e8 d7 b5 ff ff       	call   c0100d2a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105753:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105758:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010575f:	00 
c0105760:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105767:	00 
c0105768:	89 04 24             	mov    %eax,(%esp)
c010576b:	e8 64 fc ff ff       	call   c01053d4 <get_page>
c0105770:	85 c0                	test   %eax,%eax
c0105772:	74 24                	je     c0105798 <check_pgdir+0xb6>
c0105774:	c7 44 24 0c 4c a0 10 	movl   $0xc010a04c,0xc(%esp)
c010577b:	c0 
c010577c:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105783:	c0 
c0105784:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c010578b:	00 
c010578c:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105793:	e8 92 b5 ff ff       	call   c0100d2a <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105798:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010579f:	e8 3f f4 ff ff       	call   c0104be3 <alloc_pages>
c01057a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01057a7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01057ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01057b3:	00 
c01057b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01057bb:	00 
c01057bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057c3:	89 04 24             	mov    %eax,(%esp)
c01057c6:	e8 0f fd ff ff       	call   c01054da <page_insert>
c01057cb:	85 c0                	test   %eax,%eax
c01057cd:	74 24                	je     c01057f3 <check_pgdir+0x111>
c01057cf:	c7 44 24 0c 74 a0 10 	movl   $0xc010a074,0xc(%esp)
c01057d6:	c0 
c01057d7:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c01057de:	c0 
c01057df:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c01057e6:	00 
c01057e7:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01057ee:	e8 37 b5 ff ff       	call   c0100d2a <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01057f3:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01057f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01057ff:	00 
c0105800:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105807:	00 
c0105808:	89 04 24             	mov    %eax,(%esp)
c010580b:	e8 89 fa ff ff       	call   c0105299 <get_pte>
c0105810:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105817:	75 24                	jne    c010583d <check_pgdir+0x15b>
c0105819:	c7 44 24 0c a0 a0 10 	movl   $0xc010a0a0,0xc(%esp)
c0105820:	c0 
c0105821:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105828:	c0 
c0105829:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105830:	00 
c0105831:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105838:	e8 ed b4 ff ff       	call   c0100d2a <__panic>
    assert(pte2page(*ptep) == p1);
c010583d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105840:	8b 00                	mov    (%eax),%eax
c0105842:	89 04 24             	mov    %eax,(%esp)
c0105845:	e8 2f f1 ff ff       	call   c0104979 <pte2page>
c010584a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010584d:	74 24                	je     c0105873 <check_pgdir+0x191>
c010584f:	c7 44 24 0c cd a0 10 	movl   $0xc010a0cd,0xc(%esp)
c0105856:	c0 
c0105857:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010585e:	c0 
c010585f:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105866:	00 
c0105867:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010586e:	e8 b7 b4 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p1) == 1);
c0105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105876:	89 04 24             	mov    %eax,(%esp)
c0105879:	e8 55 f1 ff ff       	call   c01049d3 <page_ref>
c010587e:	83 f8 01             	cmp    $0x1,%eax
c0105881:	74 24                	je     c01058a7 <check_pgdir+0x1c5>
c0105883:	c7 44 24 0c e3 a0 10 	movl   $0xc010a0e3,0xc(%esp)
c010588a:	c0 
c010588b:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105892:	c0 
c0105893:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c010589a:	00 
c010589b:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01058a2:	e8 83 b4 ff ff       	call   c0100d2a <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01058a7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01058ac:	8b 00                	mov    (%eax),%eax
c01058ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01058b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058b9:	c1 e8 0c             	shr    $0xc,%eax
c01058bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058bf:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01058c4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01058c7:	72 23                	jb     c01058ec <check_pgdir+0x20a>
c01058c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058d0:	c7 44 24 08 9c 9e 10 	movl   $0xc0109e9c,0x8(%esp)
c01058d7:	c0 
c01058d8:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c01058df:	00 
c01058e0:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01058e7:	e8 3e b4 ff ff       	call   c0100d2a <__panic>
c01058ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058ef:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01058f4:	83 c0 04             	add    $0x4,%eax
c01058f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01058fa:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01058ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105906:	00 
c0105907:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010590e:	00 
c010590f:	89 04 24             	mov    %eax,(%esp)
c0105912:	e8 82 f9 ff ff       	call   c0105299 <get_pte>
c0105917:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010591a:	74 24                	je     c0105940 <check_pgdir+0x25e>
c010591c:	c7 44 24 0c f8 a0 10 	movl   $0xc010a0f8,0xc(%esp)
c0105923:	c0 
c0105924:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010592b:	c0 
c010592c:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105933:	00 
c0105934:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010593b:	e8 ea b3 ff ff       	call   c0100d2a <__panic>

    p2 = alloc_page();
c0105940:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105947:	e8 97 f2 ff ff       	call   c0104be3 <alloc_pages>
c010594c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010594f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105954:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010595b:	00 
c010595c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105963:	00 
c0105964:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105967:	89 54 24 04          	mov    %edx,0x4(%esp)
c010596b:	89 04 24             	mov    %eax,(%esp)
c010596e:	e8 67 fb ff ff       	call   c01054da <page_insert>
c0105973:	85 c0                	test   %eax,%eax
c0105975:	74 24                	je     c010599b <check_pgdir+0x2b9>
c0105977:	c7 44 24 0c 20 a1 10 	movl   $0xc010a120,0xc(%esp)
c010597e:	c0 
c010597f:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105986:	c0 
c0105987:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c010598e:	00 
c010598f:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105996:	e8 8f b3 ff ff       	call   c0100d2a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010599b:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01059a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01059a7:	00 
c01059a8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01059af:	00 
c01059b0:	89 04 24             	mov    %eax,(%esp)
c01059b3:	e8 e1 f8 ff ff       	call   c0105299 <get_pte>
c01059b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01059bf:	75 24                	jne    c01059e5 <check_pgdir+0x303>
c01059c1:	c7 44 24 0c 58 a1 10 	movl   $0xc010a158,0xc(%esp)
c01059c8:	c0 
c01059c9:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c01059d0:	c0 
c01059d1:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c01059d8:	00 
c01059d9:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01059e0:	e8 45 b3 ff ff       	call   c0100d2a <__panic>
    assert(*ptep & PTE_U);
c01059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059e8:	8b 00                	mov    (%eax),%eax
c01059ea:	83 e0 04             	and    $0x4,%eax
c01059ed:	85 c0                	test   %eax,%eax
c01059ef:	75 24                	jne    c0105a15 <check_pgdir+0x333>
c01059f1:	c7 44 24 0c 88 a1 10 	movl   $0xc010a188,0xc(%esp)
c01059f8:	c0 
c01059f9:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105a00:	c0 
c0105a01:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105a08:	00 
c0105a09:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105a10:	e8 15 b3 ff ff       	call   c0100d2a <__panic>
    assert(*ptep & PTE_W);
c0105a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a18:	8b 00                	mov    (%eax),%eax
c0105a1a:	83 e0 02             	and    $0x2,%eax
c0105a1d:	85 c0                	test   %eax,%eax
c0105a1f:	75 24                	jne    c0105a45 <check_pgdir+0x363>
c0105a21:	c7 44 24 0c 96 a1 10 	movl   $0xc010a196,0xc(%esp)
c0105a28:	c0 
c0105a29:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105a30:	c0 
c0105a31:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105a38:	00 
c0105a39:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105a40:	e8 e5 b2 ff ff       	call   c0100d2a <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105a45:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a4a:	8b 00                	mov    (%eax),%eax
c0105a4c:	83 e0 04             	and    $0x4,%eax
c0105a4f:	85 c0                	test   %eax,%eax
c0105a51:	75 24                	jne    c0105a77 <check_pgdir+0x395>
c0105a53:	c7 44 24 0c a4 a1 10 	movl   $0xc010a1a4,0xc(%esp)
c0105a5a:	c0 
c0105a5b:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105a62:	c0 
c0105a63:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105a6a:	00 
c0105a6b:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105a72:	e8 b3 b2 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p2) == 1);
c0105a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a7a:	89 04 24             	mov    %eax,(%esp)
c0105a7d:	e8 51 ef ff ff       	call   c01049d3 <page_ref>
c0105a82:	83 f8 01             	cmp    $0x1,%eax
c0105a85:	74 24                	je     c0105aab <check_pgdir+0x3c9>
c0105a87:	c7 44 24 0c ba a1 10 	movl   $0xc010a1ba,0xc(%esp)
c0105a8e:	c0 
c0105a8f:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105a96:	c0 
c0105a97:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105a9e:	00 
c0105a9f:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105aa6:	e8 7f b2 ff ff       	call   c0100d2a <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105aab:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ab0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105ab7:	00 
c0105ab8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105abf:	00 
c0105ac0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ac3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ac7:	89 04 24             	mov    %eax,(%esp)
c0105aca:	e8 0b fa ff ff       	call   c01054da <page_insert>
c0105acf:	85 c0                	test   %eax,%eax
c0105ad1:	74 24                	je     c0105af7 <check_pgdir+0x415>
c0105ad3:	c7 44 24 0c cc a1 10 	movl   $0xc010a1cc,0xc(%esp)
c0105ada:	c0 
c0105adb:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105ae2:	c0 
c0105ae3:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105aea:	00 
c0105aeb:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105af2:	e8 33 b2 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p1) == 2);
c0105af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105afa:	89 04 24             	mov    %eax,(%esp)
c0105afd:	e8 d1 ee ff ff       	call   c01049d3 <page_ref>
c0105b02:	83 f8 02             	cmp    $0x2,%eax
c0105b05:	74 24                	je     c0105b2b <check_pgdir+0x449>
c0105b07:	c7 44 24 0c f8 a1 10 	movl   $0xc010a1f8,0xc(%esp)
c0105b0e:	c0 
c0105b0f:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105b16:	c0 
c0105b17:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0105b1e:	00 
c0105b1f:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105b26:	e8 ff b1 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p2) == 0);
c0105b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b2e:	89 04 24             	mov    %eax,(%esp)
c0105b31:	e8 9d ee ff ff       	call   c01049d3 <page_ref>
c0105b36:	85 c0                	test   %eax,%eax
c0105b38:	74 24                	je     c0105b5e <check_pgdir+0x47c>
c0105b3a:	c7 44 24 0c 0a a2 10 	movl   $0xc010a20a,0xc(%esp)
c0105b41:	c0 
c0105b42:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105b49:	c0 
c0105b4a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0105b51:	00 
c0105b52:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105b59:	e8 cc b1 ff ff       	call   c0100d2a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105b5e:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b6a:	00 
c0105b6b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105b72:	00 
c0105b73:	89 04 24             	mov    %eax,(%esp)
c0105b76:	e8 1e f7 ff ff       	call   c0105299 <get_pte>
c0105b7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105b82:	75 24                	jne    c0105ba8 <check_pgdir+0x4c6>
c0105b84:	c7 44 24 0c 58 a1 10 	movl   $0xc010a158,0xc(%esp)
c0105b8b:	c0 
c0105b8c:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105b93:	c0 
c0105b94:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0105b9b:	00 
c0105b9c:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105ba3:	e8 82 b1 ff ff       	call   c0100d2a <__panic>
    assert(pte2page(*ptep) == p1);
c0105ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bab:	8b 00                	mov    (%eax),%eax
c0105bad:	89 04 24             	mov    %eax,(%esp)
c0105bb0:	e8 c4 ed ff ff       	call   c0104979 <pte2page>
c0105bb5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105bb8:	74 24                	je     c0105bde <check_pgdir+0x4fc>
c0105bba:	c7 44 24 0c cd a0 10 	movl   $0xc010a0cd,0xc(%esp)
c0105bc1:	c0 
c0105bc2:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105bc9:	c0 
c0105bca:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0105bd1:	00 
c0105bd2:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105bd9:	e8 4c b1 ff ff       	call   c0100d2a <__panic>
    assert((*ptep & PTE_U) == 0);
c0105bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105be1:	8b 00                	mov    (%eax),%eax
c0105be3:	83 e0 04             	and    $0x4,%eax
c0105be6:	85 c0                	test   %eax,%eax
c0105be8:	74 24                	je     c0105c0e <check_pgdir+0x52c>
c0105bea:	c7 44 24 0c 1c a2 10 	movl   $0xc010a21c,0xc(%esp)
c0105bf1:	c0 
c0105bf2:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105bf9:	c0 
c0105bfa:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0105c01:	00 
c0105c02:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105c09:	e8 1c b1 ff ff       	call   c0100d2a <__panic>

    page_remove(boot_pgdir, 0x0);
c0105c0e:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105c1a:	00 
c0105c1b:	89 04 24             	mov    %eax,(%esp)
c0105c1e:	e8 70 f8 ff ff       	call   c0105493 <page_remove>
    assert(page_ref(p1) == 1);
c0105c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c26:	89 04 24             	mov    %eax,(%esp)
c0105c29:	e8 a5 ed ff ff       	call   c01049d3 <page_ref>
c0105c2e:	83 f8 01             	cmp    $0x1,%eax
c0105c31:	74 24                	je     c0105c57 <check_pgdir+0x575>
c0105c33:	c7 44 24 0c e3 a0 10 	movl   $0xc010a0e3,0xc(%esp)
c0105c3a:	c0 
c0105c3b:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105c42:	c0 
c0105c43:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0105c4a:	00 
c0105c4b:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105c52:	e8 d3 b0 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p2) == 0);
c0105c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c5a:	89 04 24             	mov    %eax,(%esp)
c0105c5d:	e8 71 ed ff ff       	call   c01049d3 <page_ref>
c0105c62:	85 c0                	test   %eax,%eax
c0105c64:	74 24                	je     c0105c8a <check_pgdir+0x5a8>
c0105c66:	c7 44 24 0c 0a a2 10 	movl   $0xc010a20a,0xc(%esp)
c0105c6d:	c0 
c0105c6e:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105c75:	c0 
c0105c76:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0105c7d:	00 
c0105c7e:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105c85:	e8 a0 b0 ff ff       	call   c0100d2a <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105c8a:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c8f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105c96:	00 
c0105c97:	89 04 24             	mov    %eax,(%esp)
c0105c9a:	e8 f4 f7 ff ff       	call   c0105493 <page_remove>
    assert(page_ref(p1) == 0);
c0105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ca2:	89 04 24             	mov    %eax,(%esp)
c0105ca5:	e8 29 ed ff ff       	call   c01049d3 <page_ref>
c0105caa:	85 c0                	test   %eax,%eax
c0105cac:	74 24                	je     c0105cd2 <check_pgdir+0x5f0>
c0105cae:	c7 44 24 0c 31 a2 10 	movl   $0xc010a231,0xc(%esp)
c0105cb5:	c0 
c0105cb6:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105cbd:	c0 
c0105cbe:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0105cc5:	00 
c0105cc6:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105ccd:	e8 58 b0 ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p2) == 0);
c0105cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cd5:	89 04 24             	mov    %eax,(%esp)
c0105cd8:	e8 f6 ec ff ff       	call   c01049d3 <page_ref>
c0105cdd:	85 c0                	test   %eax,%eax
c0105cdf:	74 24                	je     c0105d05 <check_pgdir+0x623>
c0105ce1:	c7 44 24 0c 0a a2 10 	movl   $0xc010a20a,0xc(%esp)
c0105ce8:	c0 
c0105ce9:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105cf0:	c0 
c0105cf1:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0105cf8:	00 
c0105cf9:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105d00:	e8 25 b0 ff ff       	call   c0100d2a <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105d05:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d0a:	8b 00                	mov    (%eax),%eax
c0105d0c:	89 04 24             	mov    %eax,(%esp)
c0105d0f:	e8 a5 ec ff ff       	call   c01049b9 <pde2page>
c0105d14:	89 04 24             	mov    %eax,(%esp)
c0105d17:	e8 b7 ec ff ff       	call   c01049d3 <page_ref>
c0105d1c:	83 f8 01             	cmp    $0x1,%eax
c0105d1f:	74 24                	je     c0105d45 <check_pgdir+0x663>
c0105d21:	c7 44 24 0c 44 a2 10 	movl   $0xc010a244,0xc(%esp)
c0105d28:	c0 
c0105d29:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105d30:	c0 
c0105d31:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0105d38:	00 
c0105d39:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105d40:	e8 e5 af ff ff       	call   c0100d2a <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105d45:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d4a:	8b 00                	mov    (%eax),%eax
c0105d4c:	89 04 24             	mov    %eax,(%esp)
c0105d4f:	e8 65 ec ff ff       	call   c01049b9 <pde2page>
c0105d54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105d5b:	00 
c0105d5c:	89 04 24             	mov    %eax,(%esp)
c0105d5f:	e8 ec ee ff ff       	call   c0104c50 <free_pages>
    boot_pgdir[0] = 0;
c0105d64:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d69:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105d6f:	c7 04 24 6b a2 10 c0 	movl   $0xc010a26b,(%esp)
c0105d76:	e8 2a a6 ff ff       	call   c01003a5 <cprintf>
}
c0105d7b:	90                   	nop
c0105d7c:	89 ec                	mov    %ebp,%esp
c0105d7e:	5d                   	pop    %ebp
c0105d7f:	c3                   	ret    

c0105d80 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105d80:	55                   	push   %ebp
c0105d81:	89 e5                	mov    %esp,%ebp
c0105d83:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105d86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105d8d:	e9 ca 00 00 00       	jmp    c0105e5c <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105d98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d9b:	c1 e8 0c             	shr    $0xc,%eax
c0105d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105da1:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c0105da6:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105da9:	72 23                	jb     c0105dce <check_boot_pgdir+0x4e>
c0105dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105db2:	c7 44 24 08 9c 9e 10 	movl   $0xc0109e9c,0x8(%esp)
c0105db9:	c0 
c0105dba:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0105dc1:	00 
c0105dc2:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105dc9:	e8 5c af ff ff       	call   c0100d2a <__panic>
c0105dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dd1:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105dd6:	89 c2                	mov    %eax,%edx
c0105dd8:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ddd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105de4:	00 
c0105de5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105de9:	89 04 24             	mov    %eax,(%esp)
c0105dec:	e8 a8 f4 ff ff       	call   c0105299 <get_pte>
c0105df1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105df4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105df8:	75 24                	jne    c0105e1e <check_boot_pgdir+0x9e>
c0105dfa:	c7 44 24 0c 88 a2 10 	movl   $0xc010a288,0xc(%esp)
c0105e01:	c0 
c0105e02:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105e09:	c0 
c0105e0a:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0105e11:	00 
c0105e12:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105e19:	e8 0c af ff ff       	call   c0100d2a <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105e1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e21:	8b 00                	mov    (%eax),%eax
c0105e23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105e28:	89 c2                	mov    %eax,%edx
c0105e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e2d:	39 c2                	cmp    %eax,%edx
c0105e2f:	74 24                	je     c0105e55 <check_boot_pgdir+0xd5>
c0105e31:	c7 44 24 0c c5 a2 10 	movl   $0xc010a2c5,0xc(%esp)
c0105e38:	c0 
c0105e39:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105e40:	c0 
c0105e41:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0105e48:	00 
c0105e49:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105e50:	e8 d5 ae ff ff       	call   c0100d2a <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0105e55:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e5f:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c0105e64:	39 c2                	cmp    %eax,%edx
c0105e66:	0f 82 26 ff ff ff    	jb     c0105d92 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105e6c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105e71:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105e76:	8b 00                	mov    (%eax),%eax
c0105e78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105e7d:	89 c2                	mov    %eax,%edx
c0105e7f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105e84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e87:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105e8e:	77 23                	ja     c0105eb3 <check_boot_pgdir+0x133>
c0105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e93:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e97:	c7 44 24 08 c0 9e 10 	movl   $0xc0109ec0,0x8(%esp)
c0105e9e:	c0 
c0105e9f:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0105ea6:	00 
c0105ea7:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105eae:	e8 77 ae ff ff       	call   c0100d2a <__panic>
c0105eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eb6:	05 00 00 00 40       	add    $0x40000000,%eax
c0105ebb:	39 d0                	cmp    %edx,%eax
c0105ebd:	74 24                	je     c0105ee3 <check_boot_pgdir+0x163>
c0105ebf:	c7 44 24 0c dc a2 10 	movl   $0xc010a2dc,0xc(%esp)
c0105ec6:	c0 
c0105ec7:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105ece:	c0 
c0105ecf:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0105ed6:	00 
c0105ed7:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105ede:	e8 47 ae ff ff       	call   c0100d2a <__panic>

    assert(boot_pgdir[0] == 0);
c0105ee3:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ee8:	8b 00                	mov    (%eax),%eax
c0105eea:	85 c0                	test   %eax,%eax
c0105eec:	74 24                	je     c0105f12 <check_boot_pgdir+0x192>
c0105eee:	c7 44 24 0c 10 a3 10 	movl   $0xc010a310,0xc(%esp)
c0105ef5:	c0 
c0105ef6:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105efd:	c0 
c0105efe:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105f05:	00 
c0105f06:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105f0d:	e8 18 ae ff ff       	call   c0100d2a <__panic>

    struct Page *p;
    p = alloc_page();
c0105f12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f19:	e8 c5 ec ff ff       	call   c0104be3 <alloc_pages>
c0105f1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105f21:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105f26:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105f2d:	00 
c0105f2e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105f35:	00 
c0105f36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105f39:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f3d:	89 04 24             	mov    %eax,(%esp)
c0105f40:	e8 95 f5 ff ff       	call   c01054da <page_insert>
c0105f45:	85 c0                	test   %eax,%eax
c0105f47:	74 24                	je     c0105f6d <check_boot_pgdir+0x1ed>
c0105f49:	c7 44 24 0c 24 a3 10 	movl   $0xc010a324,0xc(%esp)
c0105f50:	c0 
c0105f51:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105f58:	c0 
c0105f59:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0105f60:	00 
c0105f61:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105f68:	e8 bd ad ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p) == 1);
c0105f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f70:	89 04 24             	mov    %eax,(%esp)
c0105f73:	e8 5b ea ff ff       	call   c01049d3 <page_ref>
c0105f78:	83 f8 01             	cmp    $0x1,%eax
c0105f7b:	74 24                	je     c0105fa1 <check_boot_pgdir+0x221>
c0105f7d:	c7 44 24 0c 52 a3 10 	movl   $0xc010a352,0xc(%esp)
c0105f84:	c0 
c0105f85:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105f8c:	c0 
c0105f8d:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c0105f94:	00 
c0105f95:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105f9c:	e8 89 ad ff ff       	call   c0100d2a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105fa1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105fa6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105fad:	00 
c0105fae:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105fb5:	00 
c0105fb6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105fb9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105fbd:	89 04 24             	mov    %eax,(%esp)
c0105fc0:	e8 15 f5 ff ff       	call   c01054da <page_insert>
c0105fc5:	85 c0                	test   %eax,%eax
c0105fc7:	74 24                	je     c0105fed <check_boot_pgdir+0x26d>
c0105fc9:	c7 44 24 0c 64 a3 10 	movl   $0xc010a364,0xc(%esp)
c0105fd0:	c0 
c0105fd1:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0105fd8:	c0 
c0105fd9:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c0105fe0:	00 
c0105fe1:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0105fe8:	e8 3d ad ff ff       	call   c0100d2a <__panic>
    assert(page_ref(p) == 2);
c0105fed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ff0:	89 04 24             	mov    %eax,(%esp)
c0105ff3:	e8 db e9 ff ff       	call   c01049d3 <page_ref>
c0105ff8:	83 f8 02             	cmp    $0x2,%eax
c0105ffb:	74 24                	je     c0106021 <check_boot_pgdir+0x2a1>
c0105ffd:	c7 44 24 0c 9b a3 10 	movl   $0xc010a39b,0xc(%esp)
c0106004:	c0 
c0106005:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010600c:	c0 
c010600d:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0106014:	00 
c0106015:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010601c:	e8 09 ad ff ff       	call   c0100d2a <__panic>

    const char *str = "ucore: Hello world!!";
c0106021:	c7 45 e8 ac a3 10 c0 	movl   $0xc010a3ac,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0106028:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010602b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010602f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106036:	e8 c2 2c 00 00       	call   c0108cfd <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010603b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106042:	00 
c0106043:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010604a:	e8 26 2d 00 00       	call   c0108d75 <strcmp>
c010604f:	85 c0                	test   %eax,%eax
c0106051:	74 24                	je     c0106077 <check_boot_pgdir+0x2f7>
c0106053:	c7 44 24 0c c4 a3 10 	movl   $0xc010a3c4,0xc(%esp)
c010605a:	c0 
c010605b:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0106062:	c0 
c0106063:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c010606a:	00 
c010606b:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0106072:	e8 b3 ac ff ff       	call   c0100d2a <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106077:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010607a:	89 04 24             	mov    %eax,(%esp)
c010607d:	e8 55 e8 ff ff       	call   c01048d7 <page2kva>
c0106082:	05 00 01 00 00       	add    $0x100,%eax
c0106087:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010608a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106091:	e8 0d 2c 00 00       	call   c0108ca3 <strlen>
c0106096:	85 c0                	test   %eax,%eax
c0106098:	74 24                	je     c01060be <check_boot_pgdir+0x33e>
c010609a:	c7 44 24 0c fc a3 10 	movl   $0xc010a3fc,0xc(%esp)
c01060a1:	c0 
c01060a2:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c01060a9:	c0 
c01060aa:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
c01060b1:	00 
c01060b2:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01060b9:	e8 6c ac ff ff       	call   c0100d2a <__panic>

    free_page(p);
c01060be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060c5:	00 
c01060c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060c9:	89 04 24             	mov    %eax,(%esp)
c01060cc:	e8 7f eb ff ff       	call   c0104c50 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01060d1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01060d6:	8b 00                	mov    (%eax),%eax
c01060d8:	89 04 24             	mov    %eax,(%esp)
c01060db:	e8 d9 e8 ff ff       	call   c01049b9 <pde2page>
c01060e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060e7:	00 
c01060e8:	89 04 24             	mov    %eax,(%esp)
c01060eb:	e8 60 eb ff ff       	call   c0104c50 <free_pages>
    boot_pgdir[0] = 0;
c01060f0:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01060f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01060fb:	c7 04 24 20 a4 10 c0 	movl   $0xc010a420,(%esp)
c0106102:	e8 9e a2 ff ff       	call   c01003a5 <cprintf>
}
c0106107:	90                   	nop
c0106108:	89 ec                	mov    %ebp,%esp
c010610a:	5d                   	pop    %ebp
c010610b:	c3                   	ret    

c010610c <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010610c:	55                   	push   %ebp
c010610d:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010610f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106112:	83 e0 04             	and    $0x4,%eax
c0106115:	85 c0                	test   %eax,%eax
c0106117:	74 04                	je     c010611d <perm2str+0x11>
c0106119:	b0 75                	mov    $0x75,%al
c010611b:	eb 02                	jmp    c010611f <perm2str+0x13>
c010611d:	b0 2d                	mov    $0x2d,%al
c010611f:	a2 88 70 12 c0       	mov    %al,0xc0127088
    str[1] = 'r';
c0106124:	c6 05 89 70 12 c0 72 	movb   $0x72,0xc0127089
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010612b:	8b 45 08             	mov    0x8(%ebp),%eax
c010612e:	83 e0 02             	and    $0x2,%eax
c0106131:	85 c0                	test   %eax,%eax
c0106133:	74 04                	je     c0106139 <perm2str+0x2d>
c0106135:	b0 77                	mov    $0x77,%al
c0106137:	eb 02                	jmp    c010613b <perm2str+0x2f>
c0106139:	b0 2d                	mov    $0x2d,%al
c010613b:	a2 8a 70 12 c0       	mov    %al,0xc012708a
    str[3] = '\0';
c0106140:	c6 05 8b 70 12 c0 00 	movb   $0x0,0xc012708b
    return str;
c0106147:	b8 88 70 12 c0       	mov    $0xc0127088,%eax
}
c010614c:	5d                   	pop    %ebp
c010614d:	c3                   	ret    

c010614e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010614e:	55                   	push   %ebp
c010614f:	89 e5                	mov    %esp,%ebp
c0106151:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106154:	8b 45 10             	mov    0x10(%ebp),%eax
c0106157:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010615a:	72 0d                	jb     c0106169 <get_pgtable_items+0x1b>
        return 0;
c010615c:	b8 00 00 00 00       	mov    $0x0,%eax
c0106161:	e9 98 00 00 00       	jmp    c01061fe <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0106166:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0106169:	8b 45 10             	mov    0x10(%ebp),%eax
c010616c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010616f:	73 18                	jae    c0106189 <get_pgtable_items+0x3b>
c0106171:	8b 45 10             	mov    0x10(%ebp),%eax
c0106174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010617b:	8b 45 14             	mov    0x14(%ebp),%eax
c010617e:	01 d0                	add    %edx,%eax
c0106180:	8b 00                	mov    (%eax),%eax
c0106182:	83 e0 01             	and    $0x1,%eax
c0106185:	85 c0                	test   %eax,%eax
c0106187:	74 dd                	je     c0106166 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106189:	8b 45 10             	mov    0x10(%ebp),%eax
c010618c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010618f:	73 68                	jae    c01061f9 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0106191:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106195:	74 08                	je     c010619f <get_pgtable_items+0x51>
            *left_store = start;
c0106197:	8b 45 18             	mov    0x18(%ebp),%eax
c010619a:	8b 55 10             	mov    0x10(%ebp),%edx
c010619d:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010619f:	8b 45 10             	mov    0x10(%ebp),%eax
c01061a2:	8d 50 01             	lea    0x1(%eax),%edx
c01061a5:	89 55 10             	mov    %edx,0x10(%ebp)
c01061a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01061af:	8b 45 14             	mov    0x14(%ebp),%eax
c01061b2:	01 d0                	add    %edx,%eax
c01061b4:	8b 00                	mov    (%eax),%eax
c01061b6:	83 e0 07             	and    $0x7,%eax
c01061b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01061bc:	eb 03                	jmp    c01061c1 <get_pgtable_items+0x73>
            start ++;
c01061be:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01061c1:	8b 45 10             	mov    0x10(%ebp),%eax
c01061c4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01061c7:	73 1d                	jae    c01061e6 <get_pgtable_items+0x98>
c01061c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01061cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01061d3:	8b 45 14             	mov    0x14(%ebp),%eax
c01061d6:	01 d0                	add    %edx,%eax
c01061d8:	8b 00                	mov    (%eax),%eax
c01061da:	83 e0 07             	and    $0x7,%eax
c01061dd:	89 c2                	mov    %eax,%edx
c01061df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061e2:	39 c2                	cmp    %eax,%edx
c01061e4:	74 d8                	je     c01061be <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c01061e6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01061ea:	74 08                	je     c01061f4 <get_pgtable_items+0xa6>
            *right_store = start;
c01061ec:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01061ef:	8b 55 10             	mov    0x10(%ebp),%edx
c01061f2:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01061f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061f7:	eb 05                	jmp    c01061fe <get_pgtable_items+0xb0>
    }
    return 0;
c01061f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01061fe:	89 ec                	mov    %ebp,%esp
c0106200:	5d                   	pop    %ebp
c0106201:	c3                   	ret    

c0106202 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106202:	55                   	push   %ebp
c0106203:	89 e5                	mov    %esp,%ebp
c0106205:	57                   	push   %edi
c0106206:	56                   	push   %esi
c0106207:	53                   	push   %ebx
c0106208:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010620b:	c7 04 24 40 a4 10 c0 	movl   $0xc010a440,(%esp)
c0106212:	e8 8e a1 ff ff       	call   c01003a5 <cprintf>
    size_t left, right = 0, perm;
c0106217:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010621e:	e9 f2 00 00 00       	jmp    c0106315 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106226:	89 04 24             	mov    %eax,(%esp)
c0106229:	e8 de fe ff ff       	call   c010610c <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010622e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106231:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106234:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106236:	89 d6                	mov    %edx,%esi
c0106238:	c1 e6 16             	shl    $0x16,%esi
c010623b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010623e:	89 d3                	mov    %edx,%ebx
c0106240:	c1 e3 16             	shl    $0x16,%ebx
c0106243:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106246:	89 d1                	mov    %edx,%ecx
c0106248:	c1 e1 16             	shl    $0x16,%ecx
c010624b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010624e:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106251:	29 fa                	sub    %edi,%edx
c0106253:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106257:	89 74 24 10          	mov    %esi,0x10(%esp)
c010625b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010625f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106263:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106267:	c7 04 24 71 a4 10 c0 	movl   $0xc010a471,(%esp)
c010626e:	e8 32 a1 ff ff       	call   c01003a5 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106273:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106276:	c1 e0 0a             	shl    $0xa,%eax
c0106279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010627c:	eb 50                	jmp    c01062ce <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010627e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106281:	89 04 24             	mov    %eax,(%esp)
c0106284:	e8 83 fe ff ff       	call   c010610c <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106289:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010628c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010628f:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106291:	89 d6                	mov    %edx,%esi
c0106293:	c1 e6 0c             	shl    $0xc,%esi
c0106296:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106299:	89 d3                	mov    %edx,%ebx
c010629b:	c1 e3 0c             	shl    $0xc,%ebx
c010629e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01062a1:	89 d1                	mov    %edx,%ecx
c01062a3:	c1 e1 0c             	shl    $0xc,%ecx
c01062a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01062a9:	8b 7d d8             	mov    -0x28(%ebp),%edi
c01062ac:	29 fa                	sub    %edi,%edx
c01062ae:	89 44 24 14          	mov    %eax,0x14(%esp)
c01062b2:	89 74 24 10          	mov    %esi,0x10(%esp)
c01062b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01062ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01062be:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062c2:	c7 04 24 90 a4 10 c0 	movl   $0xc010a490,(%esp)
c01062c9:	e8 d7 a0 ff ff       	call   c01003a5 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01062ce:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01062d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062d9:	89 d3                	mov    %edx,%ebx
c01062db:	c1 e3 0a             	shl    $0xa,%ebx
c01062de:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01062e1:	89 d1                	mov    %edx,%ecx
c01062e3:	c1 e1 0a             	shl    $0xa,%ecx
c01062e6:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01062e9:	89 54 24 14          	mov    %edx,0x14(%esp)
c01062ed:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01062f0:	89 54 24 10          	mov    %edx,0x10(%esp)
c01062f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01062f8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01062fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106300:	89 0c 24             	mov    %ecx,(%esp)
c0106303:	e8 46 fe ff ff       	call   c010614e <get_pgtable_items>
c0106308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010630b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010630f:	0f 85 69 ff ff ff    	jne    c010627e <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106315:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010631a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010631d:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106320:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106324:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0106327:	89 54 24 10          	mov    %edx,0x10(%esp)
c010632b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010632f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106333:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010633a:	00 
c010633b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106342:	e8 07 fe ff ff       	call   c010614e <get_pgtable_items>
c0106347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010634a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010634e:	0f 85 cf fe ff ff    	jne    c0106223 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106354:	c7 04 24 b4 a4 10 c0 	movl   $0xc010a4b4,(%esp)
c010635b:	e8 45 a0 ff ff       	call   c01003a5 <cprintf>
}
c0106360:	90                   	nop
c0106361:	83 c4 4c             	add    $0x4c,%esp
c0106364:	5b                   	pop    %ebx
c0106365:	5e                   	pop    %esi
c0106366:	5f                   	pop    %edi
c0106367:	5d                   	pop    %ebp
c0106368:	c3                   	ret    

c0106369 <kmalloc>:

void *
kmalloc(size_t n) {
c0106369:	55                   	push   %ebp
c010636a:	89 e5                	mov    %esp,%ebp
c010636c:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c010636f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0106376:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c010637d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106381:	74 09                	je     c010638c <kmalloc+0x23>
c0106383:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c010638a:	76 24                	jbe    c01063b0 <kmalloc+0x47>
c010638c:	c7 44 24 0c e5 a4 10 	movl   $0xc010a4e5,0xc(%esp)
c0106393:	c0 
c0106394:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010639b:	c0 
c010639c:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c01063a3:	00 
c01063a4:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01063ab:	e8 7a a9 ff ff       	call   c0100d2a <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c01063b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b3:	05 ff 0f 00 00       	add    $0xfff,%eax
c01063b8:	c1 e8 0c             	shr    $0xc,%eax
c01063bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c01063be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063c1:	89 04 24             	mov    %eax,(%esp)
c01063c4:	e8 1a e8 ff ff       	call   c0104be3 <alloc_pages>
c01063c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c01063cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063d0:	75 24                	jne    c01063f6 <kmalloc+0x8d>
c01063d2:	c7 44 24 0c fc a4 10 	movl   $0xc010a4fc,0xc(%esp)
c01063d9:	c0 
c01063da:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c01063e1:	c0 
c01063e2:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c01063e9:	00 
c01063ea:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c01063f1:	e8 34 a9 ff ff       	call   c0100d2a <__panic>
    ptr=page2kva(base);
c01063f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063f9:	89 04 24             	mov    %eax,(%esp)
c01063fc:	e8 d6 e4 ff ff       	call   c01048d7 <page2kva>
c0106401:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0106404:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106407:	89 ec                	mov    %ebp,%esp
c0106409:	5d                   	pop    %ebp
c010640a:	c3                   	ret    

c010640b <kfree>:

void 
kfree(void *ptr, size_t n) {
c010640b:	55                   	push   %ebp
c010640c:	89 e5                	mov    %esp,%ebp
c010640e:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0106411:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106415:	74 09                	je     c0106420 <kfree+0x15>
c0106417:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c010641e:	76 24                	jbe    c0106444 <kfree+0x39>
c0106420:	c7 44 24 0c e5 a4 10 	movl   $0xc010a4e5,0xc(%esp)
c0106427:	c0 
c0106428:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c010642f:	c0 
c0106430:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c0106437:	00 
c0106438:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c010643f:	e8 e6 a8 ff ff       	call   c0100d2a <__panic>
    assert(ptr != NULL);
c0106444:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106448:	75 24                	jne    c010646e <kfree+0x63>
c010644a:	c7 44 24 0c 09 a5 10 	movl   $0xc010a509,0xc(%esp)
c0106451:	c0 
c0106452:	c7 44 24 08 89 9f 10 	movl   $0xc0109f89,0x8(%esp)
c0106459:	c0 
c010645a:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0106461:	00 
c0106462:	c7 04 24 64 9f 10 c0 	movl   $0xc0109f64,(%esp)
c0106469:	e8 bc a8 ff ff       	call   c0100d2a <__panic>
    struct Page *base=NULL;
c010646e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106475:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106478:	05 ff 0f 00 00       	add    $0xfff,%eax
c010647d:	c1 e8 0c             	shr    $0xc,%eax
c0106480:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0106483:	8b 45 08             	mov    0x8(%ebp),%eax
c0106486:	89 04 24             	mov    %eax,(%esp)
c0106489:	e8 9f e4 ff ff       	call   c010492d <kva2page>
c010648e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0106491:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106494:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106498:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010649b:	89 04 24             	mov    %eax,(%esp)
c010649e:	e8 ad e7 ff ff       	call   c0104c50 <free_pages>
}
c01064a3:	90                   	nop
c01064a4:	89 ec                	mov    %ebp,%esp
c01064a6:	5d                   	pop    %ebp
c01064a7:	c3                   	ret    

c01064a8 <pa2page>:
pa2page(uintptr_t pa) {
c01064a8:	55                   	push   %ebp
c01064a9:	89 e5                	mov    %esp,%ebp
c01064ab:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01064ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b1:	c1 e8 0c             	shr    $0xc,%eax
c01064b4:	89 c2                	mov    %eax,%edx
c01064b6:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01064bb:	39 c2                	cmp    %eax,%edx
c01064bd:	72 1c                	jb     c01064db <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01064bf:	c7 44 24 08 18 a5 10 	movl   $0xc010a518,0x8(%esp)
c01064c6:	c0 
c01064c7:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01064ce:	00 
c01064cf:	c7 04 24 37 a5 10 c0 	movl   $0xc010a537,(%esp)
c01064d6:	e8 4f a8 ff ff       	call   c0100d2a <__panic>
    return &pages[PPN(pa)];
c01064db:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c01064e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e4:	c1 e8 0c             	shr    $0xc,%eax
c01064e7:	c1 e0 05             	shl    $0x5,%eax
c01064ea:	01 d0                	add    %edx,%eax
}
c01064ec:	89 ec                	mov    %ebp,%esp
c01064ee:	5d                   	pop    %ebp
c01064ef:	c3                   	ret    

c01064f0 <pte2page>:
pte2page(pte_t pte) {
c01064f0:	55                   	push   %ebp
c01064f1:	89 e5                	mov    %esp,%ebp
c01064f3:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01064f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f9:	83 e0 01             	and    $0x1,%eax
c01064fc:	85 c0                	test   %eax,%eax
c01064fe:	75 1c                	jne    c010651c <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106500:	c7 44 24 08 48 a5 10 	movl   $0xc010a548,0x8(%esp)
c0106507:	c0 
c0106508:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010650f:	00 
c0106510:	c7 04 24 37 a5 10 c0 	movl   $0xc010a537,(%esp)
c0106517:	e8 0e a8 ff ff       	call   c0100d2a <__panic>
    return pa2page(PTE_ADDR(pte));
c010651c:	8b 45 08             	mov    0x8(%ebp),%eax
c010651f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106524:	89 04 24             	mov    %eax,(%esp)
c0106527:	e8 7c ff ff ff       	call   c01064a8 <pa2page>
}
c010652c:	89 ec                	mov    %ebp,%esp
c010652e:	5d                   	pop    %ebp
c010652f:	c3                   	ret    

c0106530 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106530:	55                   	push   %ebp
c0106531:	89 e5                	mov    %esp,%ebp
c0106533:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106536:	e8 e9 1e 00 00       	call   c0108424 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010653b:	a1 a0 70 12 c0       	mov    0xc01270a0,%eax
c0106540:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106545:	76 0c                	jbe    c0106553 <swap_init+0x23>
c0106547:	a1 a0 70 12 c0       	mov    0xc01270a0,%eax
c010654c:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106551:	76 25                	jbe    c0106578 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106553:	a1 a0 70 12 c0       	mov    0xc01270a0,%eax
c0106558:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010655c:	c7 44 24 08 69 a5 10 	movl   $0xc010a569,0x8(%esp)
c0106563:	c0 
c0106564:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c010656b:	00 
c010656c:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106573:	e8 b2 a7 ff ff       	call   c0100d2a <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106578:	c7 05 60 71 12 c0 40 	movl   $0xc0123a40,0xc0127160
c010657f:	3a 12 c0 
     int r = sm->init();
c0106582:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c0106587:	8b 40 04             	mov    0x4(%eax),%eax
c010658a:	ff d0                	call   *%eax
c010658c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010658f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106593:	75 26                	jne    c01065bb <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106595:	c7 05 a4 70 12 c0 01 	movl   $0x1,0xc01270a4
c010659c:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010659f:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c01065a4:	8b 00                	mov    (%eax),%eax
c01065a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065aa:	c7 04 24 93 a5 10 c0 	movl   $0xc010a593,(%esp)
c01065b1:	e8 ef 9d ff ff       	call   c01003a5 <cprintf>
          check_swap();
c01065b6:	e8 b0 04 00 00       	call   c0106a6b <check_swap>
     }

     return r;
c01065bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01065be:	89 ec                	mov    %ebp,%esp
c01065c0:	5d                   	pop    %ebp
c01065c1:	c3                   	ret    

c01065c2 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01065c2:	55                   	push   %ebp
c01065c3:	89 e5                	mov    %esp,%ebp
c01065c5:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01065c8:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c01065cd:	8b 40 08             	mov    0x8(%eax),%eax
c01065d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01065d3:	89 14 24             	mov    %edx,(%esp)
c01065d6:	ff d0                	call   *%eax
}
c01065d8:	89 ec                	mov    %ebp,%esp
c01065da:	5d                   	pop    %ebp
c01065db:	c3                   	ret    

c01065dc <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01065dc:	55                   	push   %ebp
c01065dd:	89 e5                	mov    %esp,%ebp
c01065df:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01065e2:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c01065e7:	8b 40 0c             	mov    0xc(%eax),%eax
c01065ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01065ed:	89 14 24             	mov    %edx,(%esp)
c01065f0:	ff d0                	call   *%eax
}
c01065f2:	89 ec                	mov    %ebp,%esp
c01065f4:	5d                   	pop    %ebp
c01065f5:	c3                   	ret    

c01065f6 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01065f6:	55                   	push   %ebp
c01065f7:	89 e5                	mov    %esp,%ebp
c01065f9:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01065fc:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c0106601:	8b 40 10             	mov    0x10(%eax),%eax
c0106604:	8b 55 14             	mov    0x14(%ebp),%edx
c0106607:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010660b:	8b 55 10             	mov    0x10(%ebp),%edx
c010660e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106612:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106615:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106619:	8b 55 08             	mov    0x8(%ebp),%edx
c010661c:	89 14 24             	mov    %edx,(%esp)
c010661f:	ff d0                	call   *%eax
}
c0106621:	89 ec                	mov    %ebp,%esp
c0106623:	5d                   	pop    %ebp
c0106624:	c3                   	ret    

c0106625 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106625:	55                   	push   %ebp
c0106626:	89 e5                	mov    %esp,%ebp
c0106628:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c010662b:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c0106630:	8b 40 14             	mov    0x14(%eax),%eax
c0106633:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106636:	89 54 24 04          	mov    %edx,0x4(%esp)
c010663a:	8b 55 08             	mov    0x8(%ebp),%edx
c010663d:	89 14 24             	mov    %edx,(%esp)
c0106640:	ff d0                	call   *%eax
}
c0106642:	89 ec                	mov    %ebp,%esp
c0106644:	5d                   	pop    %ebp
c0106645:	c3                   	ret    

c0106646 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106646:	55                   	push   %ebp
c0106647:	89 e5                	mov    %esp,%ebp
c0106649:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c010664c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106653:	e9 53 01 00 00       	jmp    c01067ab <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106658:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c010665d:	8b 40 18             	mov    0x18(%eax),%eax
c0106660:	8b 55 10             	mov    0x10(%ebp),%edx
c0106663:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106667:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010666a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010666e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106671:	89 14 24             	mov    %edx,(%esp)
c0106674:	ff d0                	call   *%eax
c0106676:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106679:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010667d:	74 18                	je     c0106697 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010667f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106682:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106686:	c7 04 24 a8 a5 10 c0 	movl   $0xc010a5a8,(%esp)
c010668d:	e8 13 9d ff ff       	call   c01003a5 <cprintf>
c0106692:	e9 20 01 00 00       	jmp    c01067b7 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010669a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010669d:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01066a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a3:	8b 40 0c             	mov    0xc(%eax),%eax
c01066a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01066ad:	00 
c01066ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01066b1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01066b5:	89 04 24             	mov    %eax,(%esp)
c01066b8:	e8 dc eb ff ff       	call   c0105299 <get_pte>
c01066bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01066c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066c3:	8b 00                	mov    (%eax),%eax
c01066c5:	83 e0 01             	and    $0x1,%eax
c01066c8:	85 c0                	test   %eax,%eax
c01066ca:	75 24                	jne    c01066f0 <swap_out+0xaa>
c01066cc:	c7 44 24 0c d5 a5 10 	movl   $0xc010a5d5,0xc(%esp)
c01066d3:	c0 
c01066d4:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c01066db:	c0 
c01066dc:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01066e3:	00 
c01066e4:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01066eb:	e8 3a a6 ff ff       	call   c0100d2a <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01066f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01066f6:	8b 52 1c             	mov    0x1c(%edx),%edx
c01066f9:	c1 ea 0c             	shr    $0xc,%edx
c01066fc:	42                   	inc    %edx
c01066fd:	c1 e2 08             	shl    $0x8,%edx
c0106700:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106704:	89 14 24             	mov    %edx,(%esp)
c0106707:	e8 d7 1d 00 00       	call   c01084e3 <swapfs_write>
c010670c:	85 c0                	test   %eax,%eax
c010670e:	74 34                	je     c0106744 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0106710:	c7 04 24 ff a5 10 c0 	movl   $0xc010a5ff,(%esp)
c0106717:	e8 89 9c ff ff       	call   c01003a5 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c010671c:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c0106721:	8b 40 10             	mov    0x10(%eax),%eax
c0106724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106727:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010672e:	00 
c010672f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106733:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106736:	89 54 24 04          	mov    %edx,0x4(%esp)
c010673a:	8b 55 08             	mov    0x8(%ebp),%edx
c010673d:	89 14 24             	mov    %edx,(%esp)
c0106740:	ff d0                	call   *%eax
c0106742:	eb 64                	jmp    c01067a8 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106747:	8b 40 1c             	mov    0x1c(%eax),%eax
c010674a:	c1 e8 0c             	shr    $0xc,%eax
c010674d:	40                   	inc    %eax
c010674e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106752:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106755:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010675c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106760:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106767:	e8 39 9c ff ff       	call   c01003a5 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010676c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010676f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106772:	c1 e8 0c             	shr    $0xc,%eax
c0106775:	40                   	inc    %eax
c0106776:	c1 e0 08             	shl    $0x8,%eax
c0106779:	89 c2                	mov    %eax,%edx
c010677b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010677e:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106780:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106783:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010678a:	00 
c010678b:	89 04 24             	mov    %eax,(%esp)
c010678e:	e8 bd e4 ff ff       	call   c0104c50 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106793:	8b 45 08             	mov    0x8(%ebp),%eax
c0106796:	8b 40 0c             	mov    0xc(%eax),%eax
c0106799:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010679c:	89 54 24 04          	mov    %edx,0x4(%esp)
c01067a0:	89 04 24             	mov    %eax,(%esp)
c01067a3:	e8 ed ed ff ff       	call   c0105595 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c01067a8:	ff 45 f4             	incl   -0xc(%ebp)
c01067ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01067b1:	0f 85 a1 fe ff ff    	jne    c0106658 <swap_out+0x12>
     }
     return i;
c01067b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01067ba:	89 ec                	mov    %ebp,%esp
c01067bc:	5d                   	pop    %ebp
c01067bd:	c3                   	ret    

c01067be <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01067be:	55                   	push   %ebp
c01067bf:	89 e5                	mov    %esp,%ebp
c01067c1:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01067c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01067cb:	e8 13 e4 ff ff       	call   c0104be3 <alloc_pages>
c01067d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01067d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01067d7:	75 24                	jne    c01067fd <swap_in+0x3f>
c01067d9:	c7 44 24 0c 58 a6 10 	movl   $0xc010a658,0xc(%esp)
c01067e0:	c0 
c01067e1:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c01067e8:	c0 
c01067e9:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01067f0:	00 
c01067f1:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01067f8:	e8 2d a5 ff ff       	call   c0100d2a <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01067fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106800:	8b 40 0c             	mov    0xc(%eax),%eax
c0106803:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010680a:	00 
c010680b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010680e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106812:	89 04 24             	mov    %eax,(%esp)
c0106815:	e8 7f ea ff ff       	call   c0105299 <get_pte>
c010681a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c010681d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106820:	8b 00                	mov    (%eax),%eax
c0106822:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106825:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106829:	89 04 24             	mov    %eax,(%esp)
c010682c:	e8 3e 1c 00 00       	call   c010846f <swapfs_read>
c0106831:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106834:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106838:	74 2a                	je     c0106864 <swap_in+0xa6>
     {
        assert(r!=0);
c010683a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010683e:	75 24                	jne    c0106864 <swap_in+0xa6>
c0106840:	c7 44 24 0c 65 a6 10 	movl   $0xc010a665,0xc(%esp)
c0106847:	c0 
c0106848:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c010684f:	c0 
c0106850:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106857:	00 
c0106858:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c010685f:	e8 c6 a4 ff ff       	call   c0100d2a <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106864:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106867:	8b 00                	mov    (%eax),%eax
c0106869:	c1 e8 08             	shr    $0x8,%eax
c010686c:	89 c2                	mov    %eax,%edx
c010686e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106871:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106875:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106879:	c7 04 24 6c a6 10 c0 	movl   $0xc010a66c,(%esp)
c0106880:	e8 20 9b ff ff       	call   c01003a5 <cprintf>
     *ptr_result=result;
c0106885:	8b 45 10             	mov    0x10(%ebp),%eax
c0106888:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010688b:	89 10                	mov    %edx,(%eax)
     return 0;
c010688d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106892:	89 ec                	mov    %ebp,%esp
c0106894:	5d                   	pop    %ebp
c0106895:	c3                   	ret    

c0106896 <check_content_set>:



static inline void
check_content_set(void)
{
c0106896:	55                   	push   %ebp
c0106897:	89 e5                	mov    %esp,%ebp
c0106899:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010689c:	b8 00 10 00 00       	mov    $0x1000,%eax
c01068a1:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01068a4:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01068a9:	83 f8 01             	cmp    $0x1,%eax
c01068ac:	74 24                	je     c01068d2 <check_content_set+0x3c>
c01068ae:	c7 44 24 0c aa a6 10 	movl   $0xc010a6aa,0xc(%esp)
c01068b5:	c0 
c01068b6:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c01068bd:	c0 
c01068be:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c01068c5:	00 
c01068c6:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01068cd:	e8 58 a4 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01068d2:	b8 10 10 00 00       	mov    $0x1010,%eax
c01068d7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01068da:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01068df:	83 f8 01             	cmp    $0x1,%eax
c01068e2:	74 24                	je     c0106908 <check_content_set+0x72>
c01068e4:	c7 44 24 0c aa a6 10 	movl   $0xc010a6aa,0xc(%esp)
c01068eb:	c0 
c01068ec:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c01068f3:	c0 
c01068f4:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01068fb:	00 
c01068fc:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106903:	e8 22 a4 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106908:	b8 00 20 00 00       	mov    $0x2000,%eax
c010690d:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106910:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0106915:	83 f8 02             	cmp    $0x2,%eax
c0106918:	74 24                	je     c010693e <check_content_set+0xa8>
c010691a:	c7 44 24 0c b9 a6 10 	movl   $0xc010a6b9,0xc(%esp)
c0106921:	c0 
c0106922:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106929:	c0 
c010692a:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106931:	00 
c0106932:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106939:	e8 ec a3 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010693e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106943:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106946:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c010694b:	83 f8 02             	cmp    $0x2,%eax
c010694e:	74 24                	je     c0106974 <check_content_set+0xde>
c0106950:	c7 44 24 0c b9 a6 10 	movl   $0xc010a6b9,0xc(%esp)
c0106957:	c0 
c0106958:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c010695f:	c0 
c0106960:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106967:	00 
c0106968:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c010696f:	e8 b6 a3 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106974:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106979:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010697c:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0106981:	83 f8 03             	cmp    $0x3,%eax
c0106984:	74 24                	je     c01069aa <check_content_set+0x114>
c0106986:	c7 44 24 0c c8 a6 10 	movl   $0xc010a6c8,0xc(%esp)
c010698d:	c0 
c010698e:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106995:	c0 
c0106996:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010699d:	00 
c010699e:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01069a5:	e8 80 a3 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01069aa:	b8 10 30 00 00       	mov    $0x3010,%eax
c01069af:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01069b2:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01069b7:	83 f8 03             	cmp    $0x3,%eax
c01069ba:	74 24                	je     c01069e0 <check_content_set+0x14a>
c01069bc:	c7 44 24 0c c8 a6 10 	movl   $0xc010a6c8,0xc(%esp)
c01069c3:	c0 
c01069c4:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c01069cb:	c0 
c01069cc:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01069d3:	00 
c01069d4:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c01069db:	e8 4a a3 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01069e0:	b8 00 40 00 00       	mov    $0x4000,%eax
c01069e5:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01069e8:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01069ed:	83 f8 04             	cmp    $0x4,%eax
c01069f0:	74 24                	je     c0106a16 <check_content_set+0x180>
c01069f2:	c7 44 24 0c d7 a6 10 	movl   $0xc010a6d7,0xc(%esp)
c01069f9:	c0 
c01069fa:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106a01:	c0 
c0106a02:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106a09:	00 
c0106a0a:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106a11:	e8 14 a3 ff ff       	call   c0100d2a <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106a16:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106a1b:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106a1e:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0106a23:	83 f8 04             	cmp    $0x4,%eax
c0106a26:	74 24                	je     c0106a4c <check_content_set+0x1b6>
c0106a28:	c7 44 24 0c d7 a6 10 	movl   $0xc010a6d7,0xc(%esp)
c0106a2f:	c0 
c0106a30:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106a37:	c0 
c0106a38:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0106a3f:	00 
c0106a40:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106a47:	e8 de a2 ff ff       	call   c0100d2a <__panic>
}
c0106a4c:	90                   	nop
c0106a4d:	89 ec                	mov    %ebp,%esp
c0106a4f:	5d                   	pop    %ebp
c0106a50:	c3                   	ret    

c0106a51 <check_content_access>:

static inline int
check_content_access(void)
{
c0106a51:	55                   	push   %ebp
c0106a52:	89 e5                	mov    %esp,%ebp
c0106a54:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106a57:	a1 60 71 12 c0       	mov    0xc0127160,%eax
c0106a5c:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a5f:	ff d0                	call   *%eax
c0106a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106a67:	89 ec                	mov    %ebp,%esp
c0106a69:	5d                   	pop    %ebp
c0106a6a:	c3                   	ret    

c0106a6b <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106a6b:	55                   	push   %ebp
c0106a6c:	89 e5                	mov    %esp,%ebp
c0106a6e:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106a78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106a7f:	c7 45 e8 e4 6f 12 c0 	movl   $0xc0126fe4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106a86:	eb 6a                	jmp    c0106af2 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0106a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a8b:	83 e8 0c             	sub    $0xc,%eax
c0106a8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106a91:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106a94:	83 c0 04             	add    $0x4,%eax
c0106a97:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106a9e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106aa1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106aa4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106aa7:	0f a3 10             	bt     %edx,(%eax)
c0106aaa:	19 c0                	sbb    %eax,%eax
c0106aac:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106aaf:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106ab3:	0f 95 c0             	setne  %al
c0106ab6:	0f b6 c0             	movzbl %al,%eax
c0106ab9:	85 c0                	test   %eax,%eax
c0106abb:	75 24                	jne    c0106ae1 <check_swap+0x76>
c0106abd:	c7 44 24 0c e6 a6 10 	movl   $0xc010a6e6,0xc(%esp)
c0106ac4:	c0 
c0106ac5:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106acc:	c0 
c0106acd:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0106ad4:	00 
c0106ad5:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106adc:	e8 49 a2 ff ff       	call   c0100d2a <__panic>
        count ++, total += p->property;
c0106ae1:	ff 45 f4             	incl   -0xc(%ebp)
c0106ae4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106ae7:	8b 50 08             	mov    0x8(%eax),%edx
c0106aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106aed:	01 d0                	add    %edx,%eax
c0106aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106af2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106af5:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106af8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106afb:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106afe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106b01:	81 7d e8 e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x18(%ebp)
c0106b08:	0f 85 7a ff ff ff    	jne    c0106a88 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0106b0e:	e8 72 e1 ff ff       	call   c0104c85 <nr_free_pages>
c0106b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106b16:	39 d0                	cmp    %edx,%eax
c0106b18:	74 24                	je     c0106b3e <check_swap+0xd3>
c0106b1a:	c7 44 24 0c f6 a6 10 	movl   $0xc010a6f6,0xc(%esp)
c0106b21:	c0 
c0106b22:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106b29:	c0 
c0106b2a:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0106b31:	00 
c0106b32:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106b39:	e8 ec a1 ff ff       	call   c0100d2a <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b4c:	c7 04 24 10 a7 10 c0 	movl   $0xc010a710,(%esp)
c0106b53:	e8 4d 98 ff ff       	call   c01003a5 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106b58:	e8 f4 0a 00 00       	call   c0107651 <mm_create>
c0106b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106b60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106b64:	75 24                	jne    c0106b8a <check_swap+0x11f>
c0106b66:	c7 44 24 0c 36 a7 10 	movl   $0xc010a736,0xc(%esp)
c0106b6d:	c0 
c0106b6e:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106b75:	c0 
c0106b76:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0106b7d:	00 
c0106b7e:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106b85:	e8 a0 a1 ff ff       	call   c0100d2a <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106b8a:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0106b8f:	85 c0                	test   %eax,%eax
c0106b91:	74 24                	je     c0106bb7 <check_swap+0x14c>
c0106b93:	c7 44 24 0c 41 a7 10 	movl   $0xc010a741,0xc(%esp)
c0106b9a:	c0 
c0106b9b:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106ba2:	c0 
c0106ba3:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106baa:	00 
c0106bab:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106bb2:	e8 73 a1 ff ff       	call   c0100d2a <__panic>

     check_mm_struct = mm;
c0106bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106bba:	a3 6c 71 12 c0       	mov    %eax,0xc012716c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106bbf:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0106bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106bc8:	89 50 0c             	mov    %edx,0xc(%eax)
c0106bcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106bce:	8b 40 0c             	mov    0xc(%eax),%eax
c0106bd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106bd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bd7:	8b 00                	mov    (%eax),%eax
c0106bd9:	85 c0                	test   %eax,%eax
c0106bdb:	74 24                	je     c0106c01 <check_swap+0x196>
c0106bdd:	c7 44 24 0c 59 a7 10 	movl   $0xc010a759,0xc(%esp)
c0106be4:	c0 
c0106be5:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106bec:	c0 
c0106bed:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106bf4:	00 
c0106bf5:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106bfc:	e8 29 a1 ff ff       	call   c0100d2a <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106c01:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106c08:	00 
c0106c09:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106c10:	00 
c0106c11:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106c18:	e8 af 0a 00 00       	call   c01076cc <vma_create>
c0106c1d:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106c20:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106c24:	75 24                	jne    c0106c4a <check_swap+0x1df>
c0106c26:	c7 44 24 0c 67 a7 10 	movl   $0xc010a767,0xc(%esp)
c0106c2d:	c0 
c0106c2e:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106c35:	c0 
c0106c36:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0106c3d:	00 
c0106c3e:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106c45:	e8 e0 a0 ff ff       	call   c0100d2a <__panic>

     insert_vma_struct(mm, vma);
c0106c4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c54:	89 04 24             	mov    %eax,(%esp)
c0106c57:	e8 07 0c 00 00       	call   c0107863 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106c5c:	c7 04 24 74 a7 10 c0 	movl   $0xc010a774,(%esp)
c0106c63:	e8 3d 97 ff ff       	call   c01003a5 <cprintf>
     pte_t *temp_ptep=NULL;
c0106c68:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c72:	8b 40 0c             	mov    0xc(%eax),%eax
c0106c75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106c7c:	00 
c0106c7d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106c84:	00 
c0106c85:	89 04 24             	mov    %eax,(%esp)
c0106c88:	e8 0c e6 ff ff       	call   c0105299 <get_pte>
c0106c8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106c90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106c94:	75 24                	jne    c0106cba <check_swap+0x24f>
c0106c96:	c7 44 24 0c a8 a7 10 	movl   $0xc010a7a8,0xc(%esp)
c0106c9d:	c0 
c0106c9e:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106ca5:	c0 
c0106ca6:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106cad:	00 
c0106cae:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106cb5:	e8 70 a0 ff ff       	call   c0100d2a <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106cba:	c7 04 24 bc a7 10 c0 	movl   $0xc010a7bc,(%esp)
c0106cc1:	e8 df 96 ff ff       	call   c01003a5 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106cc6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ccd:	e9 a2 00 00 00       	jmp    c0106d74 <check_swap+0x309>
          check_rp[i] = alloc_page();
c0106cd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106cd9:	e8 05 df ff ff       	call   c0104be3 <alloc_pages>
c0106cde:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ce1:	89 04 95 2c 71 12 c0 	mov    %eax,-0x3fed8ed4(,%edx,4)
          assert(check_rp[i] != NULL );
c0106ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ceb:	8b 04 85 2c 71 12 c0 	mov    -0x3fed8ed4(,%eax,4),%eax
c0106cf2:	85 c0                	test   %eax,%eax
c0106cf4:	75 24                	jne    c0106d1a <check_swap+0x2af>
c0106cf6:	c7 44 24 0c e0 a7 10 	movl   $0xc010a7e0,0xc(%esp)
c0106cfd:	c0 
c0106cfe:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106d05:	c0 
c0106d06:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0106d0d:	00 
c0106d0e:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106d15:	e8 10 a0 ff ff       	call   c0100d2a <__panic>
          assert(!PageProperty(check_rp[i]));
c0106d1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d1d:	8b 04 85 2c 71 12 c0 	mov    -0x3fed8ed4(,%eax,4),%eax
c0106d24:	83 c0 04             	add    $0x4,%eax
c0106d27:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106d2e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106d31:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106d34:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106d37:	0f a3 10             	bt     %edx,(%eax)
c0106d3a:	19 c0                	sbb    %eax,%eax
c0106d3c:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106d3f:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106d43:	0f 95 c0             	setne  %al
c0106d46:	0f b6 c0             	movzbl %al,%eax
c0106d49:	85 c0                	test   %eax,%eax
c0106d4b:	74 24                	je     c0106d71 <check_swap+0x306>
c0106d4d:	c7 44 24 0c f4 a7 10 	movl   $0xc010a7f4,0xc(%esp)
c0106d54:	c0 
c0106d55:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106d5c:	c0 
c0106d5d:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106d64:	00 
c0106d65:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106d6c:	e8 b9 9f ff ff       	call   c0100d2a <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d71:	ff 45 ec             	incl   -0x14(%ebp)
c0106d74:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106d78:	0f 8e 54 ff ff ff    	jle    c0106cd2 <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c0106d7e:	a1 e4 6f 12 c0       	mov    0xc0126fe4,%eax
c0106d83:	8b 15 e8 6f 12 c0    	mov    0xc0126fe8,%edx
c0106d89:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106d8c:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106d8f:	c7 45 a4 e4 6f 12 c0 	movl   $0xc0126fe4,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106d96:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106d99:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106d9c:	89 50 04             	mov    %edx,0x4(%eax)
c0106d9f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106da2:	8b 50 04             	mov    0x4(%eax),%edx
c0106da5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106da8:	89 10                	mov    %edx,(%eax)
}
c0106daa:	90                   	nop
c0106dab:	c7 45 a8 e4 6f 12 c0 	movl   $0xc0126fe4,-0x58(%ebp)
    return list->next == list;
c0106db2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106db5:	8b 40 04             	mov    0x4(%eax),%eax
c0106db8:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106dbb:	0f 94 c0             	sete   %al
c0106dbe:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106dc1:	85 c0                	test   %eax,%eax
c0106dc3:	75 24                	jne    c0106de9 <check_swap+0x37e>
c0106dc5:	c7 44 24 0c 0f a8 10 	movl   $0xc010a80f,0xc(%esp)
c0106dcc:	c0 
c0106dcd:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106dd4:	c0 
c0106dd5:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0106ddc:	00 
c0106ddd:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106de4:	e8 41 9f ff ff       	call   c0100d2a <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106de9:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0106dee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106df1:	c7 05 ec 6f 12 c0 00 	movl   $0x0,0xc0126fec
c0106df8:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106dfb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106e02:	eb 1d                	jmp    c0106e21 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c0106e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e07:	8b 04 85 2c 71 12 c0 	mov    -0x3fed8ed4(,%eax,4),%eax
c0106e0e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106e15:	00 
c0106e16:	89 04 24             	mov    %eax,(%esp)
c0106e19:	e8 32 de ff ff       	call   c0104c50 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106e1e:	ff 45 ec             	incl   -0x14(%ebp)
c0106e21:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106e25:	7e dd                	jle    c0106e04 <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106e27:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0106e2c:	83 f8 04             	cmp    $0x4,%eax
c0106e2f:	74 24                	je     c0106e55 <check_swap+0x3ea>
c0106e31:	c7 44 24 0c 28 a8 10 	movl   $0xc010a828,0xc(%esp)
c0106e38:	c0 
c0106e39:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106e40:	c0 
c0106e41:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0106e48:	00 
c0106e49:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106e50:	e8 d5 9e ff ff       	call   c0100d2a <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106e55:	c7 04 24 4c a8 10 c0 	movl   $0xc010a84c,(%esp)
c0106e5c:	e8 44 95 ff ff       	call   c01003a5 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106e61:	c7 05 70 71 12 c0 00 	movl   $0x0,0xc0127170
c0106e68:	00 00 00 
     
     check_content_set();
c0106e6b:	e8 26 fa ff ff       	call   c0106896 <check_content_set>
     assert( nr_free == 0);         
c0106e70:	a1 ec 6f 12 c0       	mov    0xc0126fec,%eax
c0106e75:	85 c0                	test   %eax,%eax
c0106e77:	74 24                	je     c0106e9d <check_swap+0x432>
c0106e79:	c7 44 24 0c 73 a8 10 	movl   $0xc010a873,0xc(%esp)
c0106e80:	c0 
c0106e81:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106e88:	c0 
c0106e89:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106e90:	00 
c0106e91:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106e98:	e8 8d 9e ff ff       	call   c0100d2a <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106e9d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ea4:	eb 25                	jmp    c0106ecb <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106ea6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ea9:	c7 04 85 c0 70 12 c0 	movl   $0xffffffff,-0x3fed8f40(,%eax,4)
c0106eb0:	ff ff ff ff 
c0106eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106eb7:	8b 14 85 c0 70 12 c0 	mov    -0x3fed8f40(,%eax,4),%edx
c0106ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ec1:	89 14 85 00 71 12 c0 	mov    %edx,-0x3fed8f00(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106ec8:	ff 45 ec             	incl   -0x14(%ebp)
c0106ecb:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106ecf:	7e d5                	jle    c0106ea6 <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ed1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ed8:	e9 e8 00 00 00       	jmp    c0106fc5 <check_swap+0x55a>
         check_ptep[i]=0;
c0106edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ee0:	c7 04 85 3c 71 12 c0 	movl   $0x0,-0x3fed8ec4(,%eax,4)
c0106ee7:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106eeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106eee:	40                   	inc    %eax
c0106eef:	c1 e0 0c             	shl    $0xc,%eax
c0106ef2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ef9:	00 
c0106efa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f01:	89 04 24             	mov    %eax,(%esp)
c0106f04:	e8 90 e3 ff ff       	call   c0105299 <get_pte>
c0106f09:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f0c:	89 04 95 3c 71 12 c0 	mov    %eax,-0x3fed8ec4(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f16:	8b 04 85 3c 71 12 c0 	mov    -0x3fed8ec4(,%eax,4),%eax
c0106f1d:	85 c0                	test   %eax,%eax
c0106f1f:	75 24                	jne    c0106f45 <check_swap+0x4da>
c0106f21:	c7 44 24 0c 80 a8 10 	movl   $0xc010a880,0xc(%esp)
c0106f28:	c0 
c0106f29:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106f30:	c0 
c0106f31:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0106f38:	00 
c0106f39:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106f40:	e8 e5 9d ff ff       	call   c0100d2a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f48:	8b 04 85 3c 71 12 c0 	mov    -0x3fed8ec4(,%eax,4),%eax
c0106f4f:	8b 00                	mov    (%eax),%eax
c0106f51:	89 04 24             	mov    %eax,(%esp)
c0106f54:	e8 97 f5 ff ff       	call   c01064f0 <pte2page>
c0106f59:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f5c:	8b 14 95 2c 71 12 c0 	mov    -0x3fed8ed4(,%edx,4),%edx
c0106f63:	39 d0                	cmp    %edx,%eax
c0106f65:	74 24                	je     c0106f8b <check_swap+0x520>
c0106f67:	c7 44 24 0c 98 a8 10 	movl   $0xc010a898,0xc(%esp)
c0106f6e:	c0 
c0106f6f:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106f76:	c0 
c0106f77:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106f7e:	00 
c0106f7f:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106f86:	e8 9f 9d ff ff       	call   c0100d2a <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106f8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f8e:	8b 04 85 3c 71 12 c0 	mov    -0x3fed8ec4(,%eax,4),%eax
c0106f95:	8b 00                	mov    (%eax),%eax
c0106f97:	83 e0 01             	and    $0x1,%eax
c0106f9a:	85 c0                	test   %eax,%eax
c0106f9c:	75 24                	jne    c0106fc2 <check_swap+0x557>
c0106f9e:	c7 44 24 0c c0 a8 10 	movl   $0xc010a8c0,0xc(%esp)
c0106fa5:	c0 
c0106fa6:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106fad:	c0 
c0106fae:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106fb5:	00 
c0106fb6:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0106fbd:	e8 68 9d ff ff       	call   c0100d2a <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106fc2:	ff 45 ec             	incl   -0x14(%ebp)
c0106fc5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106fc9:	0f 8e 0e ff ff ff    	jle    c0106edd <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c0106fcf:	c7 04 24 dc a8 10 c0 	movl   $0xc010a8dc,(%esp)
c0106fd6:	e8 ca 93 ff ff       	call   c01003a5 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106fdb:	e8 71 fa ff ff       	call   c0106a51 <check_content_access>
c0106fe0:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0106fe3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106fe7:	74 24                	je     c010700d <check_swap+0x5a2>
c0106fe9:	c7 44 24 0c 02 a9 10 	movl   $0xc010a902,0xc(%esp)
c0106ff0:	c0 
c0106ff1:	c7 44 24 08 ea a5 10 	movl   $0xc010a5ea,0x8(%esp)
c0106ff8:	c0 
c0106ff9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0107000:	00 
c0107001:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0107008:	e8 1d 9d ff ff       	call   c0100d2a <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010700d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107014:	eb 1d                	jmp    c0107033 <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0107016:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107019:	8b 04 85 2c 71 12 c0 	mov    -0x3fed8ed4(,%eax,4),%eax
c0107020:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107027:	00 
c0107028:	89 04 24             	mov    %eax,(%esp)
c010702b:	e8 20 dc ff ff       	call   c0104c50 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107030:	ff 45 ec             	incl   -0x14(%ebp)
c0107033:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107037:	7e dd                	jle    c0107016 <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0107039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010703c:	89 04 24             	mov    %eax,(%esp)
c010703f:	e8 55 09 00 00       	call   c0107999 <mm_destroy>
         
     nr_free = nr_free_store;
c0107044:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107047:	a3 ec 6f 12 c0       	mov    %eax,0xc0126fec
     free_list = free_list_store;
c010704c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010704f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107052:	a3 e4 6f 12 c0       	mov    %eax,0xc0126fe4
c0107057:	89 15 e8 6f 12 c0    	mov    %edx,0xc0126fe8

     
     le = &free_list;
c010705d:	c7 45 e8 e4 6f 12 c0 	movl   $0xc0126fe4,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107064:	eb 1c                	jmp    c0107082 <check_swap+0x617>
         struct Page *p = le2page(le, page_link);
c0107066:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107069:	83 e8 0c             	sub    $0xc,%eax
c010706c:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c010706f:	ff 4d f4             	decl   -0xc(%ebp)
c0107072:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107075:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107078:	8b 48 08             	mov    0x8(%eax),%ecx
c010707b:	89 d0                	mov    %edx,%eax
c010707d:	29 c8                	sub    %ecx,%eax
c010707f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107082:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107085:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0107088:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010708b:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010708e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107091:	81 7d e8 e4 6f 12 c0 	cmpl   $0xc0126fe4,-0x18(%ebp)
c0107098:	75 cc                	jne    c0107066 <check_swap+0x5fb>
     }
     cprintf("count is %d, total is %d\n",count,total);
c010709a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010709d:	89 44 24 08          	mov    %eax,0x8(%esp)
c01070a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070a8:	c7 04 24 09 a9 10 c0 	movl   $0xc010a909,(%esp)
c01070af:	e8 f1 92 ff ff       	call   c01003a5 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01070b4:	c7 04 24 23 a9 10 c0 	movl   $0xc010a923,(%esp)
c01070bb:	e8 e5 92 ff ff       	call   c01003a5 <cprintf>
}
c01070c0:	90                   	nop
c01070c1:	89 ec                	mov    %ebp,%esp
c01070c3:	5d                   	pop    %ebp
c01070c4:	c3                   	ret    

c01070c5 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01070c5:	55                   	push   %ebp
c01070c6:	89 e5                	mov    %esp,%ebp
c01070c8:	83 ec 10             	sub    $0x10,%esp
c01070cb:	c7 45 fc 64 71 12 c0 	movl   $0xc0127164,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01070d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01070d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01070d8:	89 50 04             	mov    %edx,0x4(%eax)
c01070db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01070de:	8b 50 04             	mov    0x4(%eax),%edx
c01070e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01070e4:	89 10                	mov    %edx,(%eax)
}
c01070e6:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01070e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01070ea:	c7 40 14 64 71 12 c0 	movl   $0xc0127164,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01070f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070f6:	89 ec                	mov    %ebp,%esp
c01070f8:	5d                   	pop    %ebp
c01070f9:	c3                   	ret    

c01070fa <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01070fa:	55                   	push   %ebp
c01070fb:	89 e5                	mov    %esp,%ebp
c01070fd:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107100:	8b 45 08             	mov    0x8(%ebp),%eax
c0107103:	8b 40 14             	mov    0x14(%eax),%eax
c0107106:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107109:	8b 45 10             	mov    0x10(%ebp),%eax
c010710c:	83 c0 14             	add    $0x14,%eax
c010710f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107112:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107116:	74 06                	je     c010711e <_fifo_map_swappable+0x24>
c0107118:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010711c:	75 24                	jne    c0107142 <_fifo_map_swappable+0x48>
c010711e:	c7 44 24 0c 3c a9 10 	movl   $0xc010a93c,0xc(%esp)
c0107125:	c0 
c0107126:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c010712d:	c0 
c010712e:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107135:	00 
c0107136:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c010713d:	e8 e8 9b ff ff       	call   c0100d2a <__panic>
c0107142:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107145:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107148:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010714b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010714e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107151:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107154:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107157:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c010715a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010715d:	8b 40 04             	mov    0x4(%eax),%eax
c0107160:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107163:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107166:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107169:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010716c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c010716f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107172:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107175:	89 10                	mov    %edx,(%eax)
c0107177:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010717a:	8b 10                	mov    (%eax),%edx
c010717c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010717f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107182:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107185:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107188:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010718b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010718e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107191:	89 10                	mov    %edx,(%eax)
}
c0107193:	90                   	nop
}
c0107194:	90                   	nop
}
c0107195:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0107196:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010719b:	89 ec                	mov    %ebp,%esp
c010719d:	5d                   	pop    %ebp
c010719e:	c3                   	ret    

c010719f <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c010719f:	55                   	push   %ebp
c01071a0:	89 e5                	mov    %esp,%ebp
c01071a2:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01071a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01071a8:	8b 40 14             	mov    0x14(%eax),%eax
c01071ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c01071ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071b2:	75 24                	jne    c01071d8 <_fifo_swap_out_victim+0x39>
c01071b4:	c7 44 24 0c 83 a9 10 	movl   $0xc010a983,0xc(%esp)
c01071bb:	c0 
c01071bc:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01071c3:	c0 
c01071c4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c01071cb:	00 
c01071cc:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01071d3:	e8 52 9b ff ff       	call   c0100d2a <__panic>
     assert(in_tick==0);
c01071d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01071dc:	74 24                	je     c0107202 <_fifo_swap_out_victim+0x63>
c01071de:	c7 44 24 0c 90 a9 10 	movl   $0xc010a990,0xc(%esp)
c01071e5:	c0 
c01071e6:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01071ed:	c0 
c01071ee:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01071f5:	00 
c01071f6:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01071fd:	e8 28 9b ff ff       	call   c0100d2a <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le=head->prev;
c0107202:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107205:	8b 00                	mov    (%eax),%eax
c0107207:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c010720a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010720d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107210:	75 24                	jne    c0107236 <_fifo_swap_out_victim+0x97>
c0107212:	c7 44 24 0c 9b a9 10 	movl   $0xc010a99b,0xc(%esp)
c0107219:	c0 
c010721a:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c0107221:	c0 
c0107222:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107229:	00 
c010722a:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107231:	e8 f4 9a ff ff       	call   c0100d2a <__panic>
     struct Page *p=le2page(le,pra_page_link);
c0107236:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107239:	83 e8 14             	sub    $0x14,%eax
c010723c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010723f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107242:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107245:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107248:	8b 40 04             	mov    0x4(%eax),%eax
c010724b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010724e:	8b 12                	mov    (%edx),%edx
c0107250:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107253:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0107256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107259:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010725c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010725f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107262:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107265:	89 10                	mov    %edx,(%eax)
}
c0107267:	90                   	nop
}
c0107268:	90                   	nop
     list_del(le);
     *ptr_page=p; 
c0107269:	8b 45 0c             	mov    0xc(%ebp),%eax
c010726c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010726f:	89 10                	mov    %edx,(%eax)
     return 0;
c0107271:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107276:	89 ec                	mov    %ebp,%esp
c0107278:	5d                   	pop    %ebp
c0107279:	c3                   	ret    

c010727a <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c010727a:	55                   	push   %ebp
c010727b:	89 e5                	mov    %esp,%ebp
c010727d:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107280:	c7 04 24 a4 a9 10 c0 	movl   $0xc010a9a4,(%esp)
c0107287:	e8 19 91 ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010728c:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107291:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107294:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0107299:	83 f8 04             	cmp    $0x4,%eax
c010729c:	74 24                	je     c01072c2 <_fifo_check_swap+0x48>
c010729e:	c7 44 24 0c ca a9 10 	movl   $0xc010a9ca,0xc(%esp)
c01072a5:	c0 
c01072a6:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01072ad:	c0 
c01072ae:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c01072b5:	00 
c01072b6:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01072bd:	e8 68 9a ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01072c2:	c7 04 24 dc a9 10 c0 	movl   $0xc010a9dc,(%esp)
c01072c9:	e8 d7 90 ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01072ce:	b8 00 10 00 00       	mov    $0x1000,%eax
c01072d3:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01072d6:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01072db:	83 f8 04             	cmp    $0x4,%eax
c01072de:	74 24                	je     c0107304 <_fifo_check_swap+0x8a>
c01072e0:	c7 44 24 0c ca a9 10 	movl   $0xc010a9ca,0xc(%esp)
c01072e7:	c0 
c01072e8:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01072ef:	c0 
c01072f0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c01072f7:	00 
c01072f8:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01072ff:	e8 26 9a ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107304:	c7 04 24 04 aa 10 c0 	movl   $0xc010aa04,(%esp)
c010730b:	e8 95 90 ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107310:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107315:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107318:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c010731d:	83 f8 04             	cmp    $0x4,%eax
c0107320:	74 24                	je     c0107346 <_fifo_check_swap+0xcc>
c0107322:	c7 44 24 0c ca a9 10 	movl   $0xc010a9ca,0xc(%esp)
c0107329:	c0 
c010732a:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c0107331:	c0 
c0107332:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0107339:	00 
c010733a:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107341:	e8 e4 99 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107346:	c7 04 24 2c aa 10 c0 	movl   $0xc010aa2c,(%esp)
c010734d:	e8 53 90 ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107352:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107357:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010735a:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c010735f:	83 f8 04             	cmp    $0x4,%eax
c0107362:	74 24                	je     c0107388 <_fifo_check_swap+0x10e>
c0107364:	c7 44 24 0c ca a9 10 	movl   $0xc010a9ca,0xc(%esp)
c010736b:	c0 
c010736c:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c0107373:	c0 
c0107374:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c010737b:	00 
c010737c:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107383:	e8 a2 99 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107388:	c7 04 24 54 aa 10 c0 	movl   $0xc010aa54,(%esp)
c010738f:	e8 11 90 ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107394:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107399:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c010739c:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01073a1:	83 f8 05             	cmp    $0x5,%eax
c01073a4:	74 24                	je     c01073ca <_fifo_check_swap+0x150>
c01073a6:	c7 44 24 0c 7a aa 10 	movl   $0xc010aa7a,0xc(%esp)
c01073ad:	c0 
c01073ae:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01073b5:	c0 
c01073b6:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01073bd:	00 
c01073be:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01073c5:	e8 60 99 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01073ca:	c7 04 24 2c aa 10 c0 	movl   $0xc010aa2c,(%esp)
c01073d1:	e8 cf 8f ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01073d6:	b8 00 20 00 00       	mov    $0x2000,%eax
c01073db:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01073de:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01073e3:	83 f8 05             	cmp    $0x5,%eax
c01073e6:	74 24                	je     c010740c <_fifo_check_swap+0x192>
c01073e8:	c7 44 24 0c 7a aa 10 	movl   $0xc010aa7a,0xc(%esp)
c01073ef:	c0 
c01073f0:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01073f7:	c0 
c01073f8:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01073ff:	00 
c0107400:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107407:	e8 1e 99 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010740c:	c7 04 24 dc a9 10 c0 	movl   $0xc010a9dc,(%esp)
c0107413:	e8 8d 8f ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107418:	b8 00 10 00 00       	mov    $0x1000,%eax
c010741d:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107420:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0107425:	83 f8 06             	cmp    $0x6,%eax
c0107428:	74 24                	je     c010744e <_fifo_check_swap+0x1d4>
c010742a:	c7 44 24 0c 89 aa 10 	movl   $0xc010aa89,0xc(%esp)
c0107431:	c0 
c0107432:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c0107439:	c0 
c010743a:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107441:	00 
c0107442:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107449:	e8 dc 98 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010744e:	c7 04 24 2c aa 10 c0 	movl   $0xc010aa2c,(%esp)
c0107455:	e8 4b 8f ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010745a:	b8 00 20 00 00       	mov    $0x2000,%eax
c010745f:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107462:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c0107467:	83 f8 07             	cmp    $0x7,%eax
c010746a:	74 24                	je     c0107490 <_fifo_check_swap+0x216>
c010746c:	c7 44 24 0c 98 aa 10 	movl   $0xc010aa98,0xc(%esp)
c0107473:	c0 
c0107474:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c010747b:	c0 
c010747c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107483:	00 
c0107484:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c010748b:	e8 9a 98 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107490:	c7 04 24 a4 a9 10 c0 	movl   $0xc010a9a4,(%esp)
c0107497:	e8 09 8f ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010749c:	b8 00 30 00 00       	mov    $0x3000,%eax
c01074a1:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01074a4:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01074a9:	83 f8 08             	cmp    $0x8,%eax
c01074ac:	74 24                	je     c01074d2 <_fifo_check_swap+0x258>
c01074ae:	c7 44 24 0c a7 aa 10 	movl   $0xc010aaa7,0xc(%esp)
c01074b5:	c0 
c01074b6:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01074bd:	c0 
c01074be:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01074c5:	00 
c01074c6:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01074cd:	e8 58 98 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01074d2:	c7 04 24 04 aa 10 c0 	movl   $0xc010aa04,(%esp)
c01074d9:	e8 c7 8e ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01074de:	b8 00 40 00 00       	mov    $0x4000,%eax
c01074e3:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01074e6:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01074eb:	83 f8 09             	cmp    $0x9,%eax
c01074ee:	74 24                	je     c0107514 <_fifo_check_swap+0x29a>
c01074f0:	c7 44 24 0c b6 aa 10 	movl   $0xc010aab6,0xc(%esp)
c01074f7:	c0 
c01074f8:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01074ff:	c0 
c0107500:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c0107507:	00 
c0107508:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c010750f:	e8 16 98 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107514:	c7 04 24 54 aa 10 c0 	movl   $0xc010aa54,(%esp)
c010751b:	e8 85 8e ff ff       	call   c01003a5 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107520:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107525:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107528:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c010752d:	83 f8 0a             	cmp    $0xa,%eax
c0107530:	74 24                	je     c0107556 <_fifo_check_swap+0x2dc>
c0107532:	c7 44 24 0c c5 aa 10 	movl   $0xc010aac5,0xc(%esp)
c0107539:	c0 
c010753a:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c0107541:	c0 
c0107542:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107549:	00 
c010754a:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c0107551:	e8 d4 97 ff ff       	call   c0100d2a <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107556:	c7 04 24 dc a9 10 c0 	movl   $0xc010a9dc,(%esp)
c010755d:	e8 43 8e ff ff       	call   c01003a5 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107562:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107567:	0f b6 00             	movzbl (%eax),%eax
c010756a:	3c 0a                	cmp    $0xa,%al
c010756c:	74 24                	je     c0107592 <_fifo_check_swap+0x318>
c010756e:	c7 44 24 0c d8 aa 10 	movl   $0xc010aad8,0xc(%esp)
c0107575:	c0 
c0107576:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c010757d:	c0 
c010757e:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0107585:	00 
c0107586:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c010758d:	e8 98 97 ff ff       	call   c0100d2a <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107592:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107597:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010759a:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c010759f:	83 f8 0b             	cmp    $0xb,%eax
c01075a2:	74 24                	je     c01075c8 <_fifo_check_swap+0x34e>
c01075a4:	c7 44 24 0c f9 aa 10 	movl   $0xc010aaf9,0xc(%esp)
c01075ab:	c0 
c01075ac:	c7 44 24 08 5a a9 10 	movl   $0xc010a95a,0x8(%esp)
c01075b3:	c0 
c01075b4:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c01075bb:	00 
c01075bc:	c7 04 24 6f a9 10 c0 	movl   $0xc010a96f,(%esp)
c01075c3:	e8 62 97 ff ff       	call   c0100d2a <__panic>
    return 0;
c01075c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075cd:	89 ec                	mov    %ebp,%esp
c01075cf:	5d                   	pop    %ebp
c01075d0:	c3                   	ret    

c01075d1 <_fifo_init>:


static int
_fifo_init(void)
{
c01075d1:	55                   	push   %ebp
c01075d2:	89 e5                	mov    %esp,%ebp
    return 0;
c01075d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075d9:	5d                   	pop    %ebp
c01075da:	c3                   	ret    

c01075db <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01075db:	55                   	push   %ebp
c01075dc:	89 e5                	mov    %esp,%ebp
    return 0;
c01075de:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075e3:	5d                   	pop    %ebp
c01075e4:	c3                   	ret    

c01075e5 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01075e5:	55                   	push   %ebp
c01075e6:	89 e5                	mov    %esp,%ebp
c01075e8:	b8 00 00 00 00       	mov    $0x0,%eax
c01075ed:	5d                   	pop    %ebp
c01075ee:	c3                   	ret    

c01075ef <pa2page>:
pa2page(uintptr_t pa) {
c01075ef:	55                   	push   %ebp
c01075f0:	89 e5                	mov    %esp,%ebp
c01075f2:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01075f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01075f8:	c1 e8 0c             	shr    $0xc,%eax
c01075fb:	89 c2                	mov    %eax,%edx
c01075fd:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c0107602:	39 c2                	cmp    %eax,%edx
c0107604:	72 1c                	jb     c0107622 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107606:	c7 44 24 08 1c ab 10 	movl   $0xc010ab1c,0x8(%esp)
c010760d:	c0 
c010760e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107615:	00 
c0107616:	c7 04 24 3b ab 10 c0 	movl   $0xc010ab3b,(%esp)
c010761d:	e8 08 97 ff ff       	call   c0100d2a <__panic>
    return &pages[PPN(pa)];
c0107622:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c0107628:	8b 45 08             	mov    0x8(%ebp),%eax
c010762b:	c1 e8 0c             	shr    $0xc,%eax
c010762e:	c1 e0 05             	shl    $0x5,%eax
c0107631:	01 d0                	add    %edx,%eax
}
c0107633:	89 ec                	mov    %ebp,%esp
c0107635:	5d                   	pop    %ebp
c0107636:	c3                   	ret    

c0107637 <pde2page>:
pde2page(pde_t pde) {
c0107637:	55                   	push   %ebp
c0107638:	89 e5                	mov    %esp,%ebp
c010763a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010763d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107640:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107645:	89 04 24             	mov    %eax,(%esp)
c0107648:	e8 a2 ff ff ff       	call   c01075ef <pa2page>
}
c010764d:	89 ec                	mov    %ebp,%esp
c010764f:	5d                   	pop    %ebp
c0107650:	c3                   	ret    

c0107651 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107651:	55                   	push   %ebp
c0107652:	89 e5                	mov    %esp,%ebp
c0107654:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107657:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010765e:	e8 06 ed ff ff       	call   c0106369 <kmalloc>
c0107663:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107666:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010766a:	74 59                	je     c01076c5 <mm_create+0x74>
        list_init(&(mm->mmap_list));
c010766c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010766f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0107672:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107675:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107678:	89 50 04             	mov    %edx,0x4(%eax)
c010767b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010767e:	8b 50 04             	mov    0x4(%eax),%edx
c0107681:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107684:	89 10                	mov    %edx,(%eax)
}
c0107686:	90                   	nop
        mm->mmap_cache = NULL;
c0107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010768a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107694:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010769b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010769e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01076a5:	a1 a4 70 12 c0       	mov    0xc01270a4,%eax
c01076aa:	85 c0                	test   %eax,%eax
c01076ac:	74 0d                	je     c01076bb <mm_create+0x6a>
c01076ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076b1:	89 04 24             	mov    %eax,(%esp)
c01076b4:	e8 09 ef ff ff       	call   c01065c2 <swap_init_mm>
c01076b9:	eb 0a                	jmp    c01076c5 <mm_create+0x74>
        else mm->sm_priv = NULL;
c01076bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076be:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01076c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01076c8:	89 ec                	mov    %ebp,%esp
c01076ca:	5d                   	pop    %ebp
c01076cb:	c3                   	ret    

c01076cc <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01076cc:	55                   	push   %ebp
c01076cd:	89 e5                	mov    %esp,%ebp
c01076cf:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01076d2:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01076d9:	e8 8b ec ff ff       	call   c0106369 <kmalloc>
c01076de:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01076e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076e5:	74 1b                	je     c0107702 <vma_create+0x36>
        vma->vm_start = vm_start;
c01076e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01076ed:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076f3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01076f6:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01076f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076fc:	8b 55 10             	mov    0x10(%ebp),%edx
c01076ff:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107702:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107705:	89 ec                	mov    %ebp,%esp
c0107707:	5d                   	pop    %ebp
c0107708:	c3                   	ret    

c0107709 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107709:	55                   	push   %ebp
c010770a:	89 e5                	mov    %esp,%ebp
c010770c:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010770f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107716:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010771a:	0f 84 95 00 00 00    	je     c01077b5 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107720:	8b 45 08             	mov    0x8(%ebp),%eax
c0107723:	8b 40 08             	mov    0x8(%eax),%eax
c0107726:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107729:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010772d:	74 16                	je     c0107745 <find_vma+0x3c>
c010772f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107732:	8b 40 04             	mov    0x4(%eax),%eax
c0107735:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107738:	72 0b                	jb     c0107745 <find_vma+0x3c>
c010773a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010773d:	8b 40 08             	mov    0x8(%eax),%eax
c0107740:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107743:	72 61                	jb     c01077a6 <find_vma+0x9d>
                bool found = 0;
c0107745:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010774c:	8b 45 08             	mov    0x8(%ebp),%eax
c010774f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107752:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107755:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107758:	eb 28                	jmp    c0107782 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010775a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010775d:	83 e8 10             	sub    $0x10,%eax
c0107760:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107763:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107766:	8b 40 04             	mov    0x4(%eax),%eax
c0107769:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010776c:	72 14                	jb     c0107782 <find_vma+0x79>
c010776e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107771:	8b 40 08             	mov    0x8(%eax),%eax
c0107774:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107777:	73 09                	jae    c0107782 <find_vma+0x79>
                        found = 1;
c0107779:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107780:	eb 17                	jmp    c0107799 <find_vma+0x90>
c0107782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107785:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0107788:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010778b:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c010778e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107791:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107794:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107797:	75 c1                	jne    c010775a <find_vma+0x51>
                    }
                }
                if (!found) {
c0107799:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010779d:	75 07                	jne    c01077a6 <find_vma+0x9d>
                    vma = NULL;
c010779f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01077a6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01077aa:	74 09                	je     c01077b5 <find_vma+0xac>
            mm->mmap_cache = vma;
c01077ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01077af:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01077b2:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01077b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01077b8:	89 ec                	mov    %ebp,%esp
c01077ba:	5d                   	pop    %ebp
c01077bb:	c3                   	ret    

c01077bc <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01077bc:	55                   	push   %ebp
c01077bd:	89 e5                	mov    %esp,%ebp
c01077bf:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01077c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01077c5:	8b 50 04             	mov    0x4(%eax),%edx
c01077c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01077cb:	8b 40 08             	mov    0x8(%eax),%eax
c01077ce:	39 c2                	cmp    %eax,%edx
c01077d0:	72 24                	jb     c01077f6 <check_vma_overlap+0x3a>
c01077d2:	c7 44 24 0c 49 ab 10 	movl   $0xc010ab49,0xc(%esp)
c01077d9:	c0 
c01077da:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c01077e1:	c0 
c01077e2:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01077e9:	00 
c01077ea:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c01077f1:	e8 34 95 ff ff       	call   c0100d2a <__panic>
    assert(prev->vm_end <= next->vm_start);
c01077f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01077f9:	8b 50 08             	mov    0x8(%eax),%edx
c01077fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01077ff:	8b 40 04             	mov    0x4(%eax),%eax
c0107802:	39 c2                	cmp    %eax,%edx
c0107804:	76 24                	jbe    c010782a <check_vma_overlap+0x6e>
c0107806:	c7 44 24 0c 8c ab 10 	movl   $0xc010ab8c,0xc(%esp)
c010780d:	c0 
c010780e:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107815:	c0 
c0107816:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010781d:	00 
c010781e:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107825:	e8 00 95 ff ff       	call   c0100d2a <__panic>
    assert(next->vm_start < next->vm_end);
c010782a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010782d:	8b 50 04             	mov    0x4(%eax),%edx
c0107830:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107833:	8b 40 08             	mov    0x8(%eax),%eax
c0107836:	39 c2                	cmp    %eax,%edx
c0107838:	72 24                	jb     c010785e <check_vma_overlap+0xa2>
c010783a:	c7 44 24 0c ab ab 10 	movl   $0xc010abab,0xc(%esp)
c0107841:	c0 
c0107842:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107849:	c0 
c010784a:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107851:	00 
c0107852:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107859:	e8 cc 94 ff ff       	call   c0100d2a <__panic>
}
c010785e:	90                   	nop
c010785f:	89 ec                	mov    %ebp,%esp
c0107861:	5d                   	pop    %ebp
c0107862:	c3                   	ret    

c0107863 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107863:	55                   	push   %ebp
c0107864:	89 e5                	mov    %esp,%ebp
c0107866:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107869:	8b 45 0c             	mov    0xc(%ebp),%eax
c010786c:	8b 50 04             	mov    0x4(%eax),%edx
c010786f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107872:	8b 40 08             	mov    0x8(%eax),%eax
c0107875:	39 c2                	cmp    %eax,%edx
c0107877:	72 24                	jb     c010789d <insert_vma_struct+0x3a>
c0107879:	c7 44 24 0c c9 ab 10 	movl   $0xc010abc9,0xc(%esp)
c0107880:	c0 
c0107881:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107888:	c0 
c0107889:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107890:	00 
c0107891:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107898:	e8 8d 94 ff ff       	call   c0100d2a <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010789d:	8b 45 08             	mov    0x8(%ebp),%eax
c01078a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01078a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01078a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01078af:	eb 1f                	jmp    c01078d0 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01078b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078b4:	83 e8 10             	sub    $0x10,%eax
c01078b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01078ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078bd:	8b 50 04             	mov    0x4(%eax),%edx
c01078c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078c3:	8b 40 04             	mov    0x4(%eax),%eax
c01078c6:	39 c2                	cmp    %eax,%edx
c01078c8:	77 1f                	ja     c01078e9 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01078ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01078d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078d9:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01078dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01078e5:	75 ca                	jne    c01078b1 <insert_vma_struct+0x4e>
c01078e7:	eb 01                	jmp    c01078ea <insert_vma_struct+0x87>
                break;
c01078e9:	90                   	nop
c01078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01078f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01078f3:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c01078f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078fc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01078ff:	74 15                	je     c0107916 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107904:	8d 50 f0             	lea    -0x10(%eax),%edx
c0107907:	8b 45 0c             	mov    0xc(%ebp),%eax
c010790a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010790e:	89 14 24             	mov    %edx,(%esp)
c0107911:	e8 a6 fe ff ff       	call   c01077bc <check_vma_overlap>
    }
    if (le_next != list) {
c0107916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107919:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010791c:	74 15                	je     c0107933 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010791e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107921:	83 e8 10             	sub    $0x10,%eax
c0107924:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107928:	8b 45 0c             	mov    0xc(%ebp),%eax
c010792b:	89 04 24             	mov    %eax,(%esp)
c010792e:	e8 89 fe ff ff       	call   c01077bc <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107933:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107936:	8b 55 08             	mov    0x8(%ebp),%edx
c0107939:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010793b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010793e:	8d 50 10             	lea    0x10(%eax),%edx
c0107941:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107944:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107947:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010794a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010794d:	8b 40 04             	mov    0x4(%eax),%eax
c0107950:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107953:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107956:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107959:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010795c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c010795f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107962:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107965:	89 10                	mov    %edx,(%eax)
c0107967:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010796a:	8b 10                	mov    (%eax),%edx
c010796c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010796f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107972:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107975:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107978:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010797b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010797e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107981:	89 10                	mov    %edx,(%eax)
}
c0107983:	90                   	nop
}
c0107984:	90                   	nop

    mm->map_count ++;
c0107985:	8b 45 08             	mov    0x8(%ebp),%eax
c0107988:	8b 40 10             	mov    0x10(%eax),%eax
c010798b:	8d 50 01             	lea    0x1(%eax),%edx
c010798e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107991:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107994:	90                   	nop
c0107995:	89 ec                	mov    %ebp,%esp
c0107997:	5d                   	pop    %ebp
c0107998:	c3                   	ret    

c0107999 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107999:	55                   	push   %ebp
c010799a:	89 e5                	mov    %esp,%ebp
c010799c:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010799f:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01079a5:	eb 40                	jmp    c01079e7 <mm_destroy+0x4e>
c01079a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01079ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079b0:	8b 40 04             	mov    0x4(%eax),%eax
c01079b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079b6:	8b 12                	mov    (%edx),%edx
c01079b8:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01079bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c01079be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079c4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01079c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079ca:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01079cd:	89 10                	mov    %edx,(%eax)
}
c01079cf:	90                   	nop
}
c01079d0:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01079d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079d4:	83 e8 10             	sub    $0x10,%eax
c01079d7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01079de:	00 
c01079df:	89 04 24             	mov    %eax,(%esp)
c01079e2:	e8 24 ea ff ff       	call   c010640b <kfree>
c01079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01079ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01079f0:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01079f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01079f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079fc:	75 a9                	jne    c01079a7 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01079fe:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107a05:	00 
c0107a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a09:	89 04 24             	mov    %eax,(%esp)
c0107a0c:	e8 fa e9 ff ff       	call   c010640b <kfree>
    mm=NULL;
c0107a11:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107a18:	90                   	nop
c0107a19:	89 ec                	mov    %ebp,%esp
c0107a1b:	5d                   	pop    %ebp
c0107a1c:	c3                   	ret    

c0107a1d <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107a1d:	55                   	push   %ebp
c0107a1e:	89 e5                	mov    %esp,%ebp
c0107a20:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107a23:	e8 05 00 00 00       	call   c0107a2d <check_vmm>
}
c0107a28:	90                   	nop
c0107a29:	89 ec                	mov    %ebp,%esp
c0107a2b:	5d                   	pop    %ebp
c0107a2c:	c3                   	ret    

c0107a2d <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107a2d:	55                   	push   %ebp
c0107a2e:	89 e5                	mov    %esp,%ebp
c0107a30:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a33:	e8 4d d2 ff ff       	call   c0104c85 <nr_free_pages>
c0107a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107a3b:	e8 44 00 00 00       	call   c0107a84 <check_vma_struct>
    check_pgfault();
c0107a40:	e8 01 05 00 00       	call   c0107f46 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0107a45:	e8 3b d2 ff ff       	call   c0104c85 <nr_free_pages>
c0107a4a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107a4d:	74 24                	je     c0107a73 <check_vmm+0x46>
c0107a4f:	c7 44 24 0c e8 ab 10 	movl   $0xc010abe8,0xc(%esp)
c0107a56:	c0 
c0107a57:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107a5e:	c0 
c0107a5f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0107a66:	00 
c0107a67:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107a6e:	e8 b7 92 ff ff       	call   c0100d2a <__panic>

    cprintf("check_vmm() succeeded.\n");
c0107a73:	c7 04 24 0f ac 10 c0 	movl   $0xc010ac0f,(%esp)
c0107a7a:	e8 26 89 ff ff       	call   c01003a5 <cprintf>
}
c0107a7f:	90                   	nop
c0107a80:	89 ec                	mov    %ebp,%esp
c0107a82:	5d                   	pop    %ebp
c0107a83:	c3                   	ret    

c0107a84 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107a84:	55                   	push   %ebp
c0107a85:	89 e5                	mov    %esp,%ebp
c0107a87:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a8a:	e8 f6 d1 ff ff       	call   c0104c85 <nr_free_pages>
c0107a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107a92:	e8 ba fb ff ff       	call   c0107651 <mm_create>
c0107a97:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107a9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107a9e:	75 24                	jne    c0107ac4 <check_vma_struct+0x40>
c0107aa0:	c7 44 24 0c 27 ac 10 	movl   $0xc010ac27,0xc(%esp)
c0107aa7:	c0 
c0107aa8:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107aaf:	c0 
c0107ab0:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0107ab7:	00 
c0107ab8:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107abf:	e8 66 92 ff ff       	call   c0100d2a <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107ac4:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107acb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ace:	89 d0                	mov    %edx,%eax
c0107ad0:	c1 e0 02             	shl    $0x2,%eax
c0107ad3:	01 d0                	add    %edx,%eax
c0107ad5:	01 c0                	add    %eax,%eax
c0107ad7:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107add:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ae0:	eb 6f                	jmp    c0107b51 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ae5:	89 d0                	mov    %edx,%eax
c0107ae7:	c1 e0 02             	shl    $0x2,%eax
c0107aea:	01 d0                	add    %edx,%eax
c0107aec:	83 c0 02             	add    $0x2,%eax
c0107aef:	89 c1                	mov    %eax,%ecx
c0107af1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107af4:	89 d0                	mov    %edx,%eax
c0107af6:	c1 e0 02             	shl    $0x2,%eax
c0107af9:	01 d0                	add    %edx,%eax
c0107afb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b02:	00 
c0107b03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107b07:	89 04 24             	mov    %eax,(%esp)
c0107b0a:	e8 bd fb ff ff       	call   c01076cc <vma_create>
c0107b0f:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0107b12:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107b16:	75 24                	jne    c0107b3c <check_vma_struct+0xb8>
c0107b18:	c7 44 24 0c 32 ac 10 	movl   $0xc010ac32,0xc(%esp)
c0107b1f:	c0 
c0107b20:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107b27:	c0 
c0107b28:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0107b2f:	00 
c0107b30:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107b37:	e8 ee 91 ff ff       	call   c0100d2a <__panic>
        insert_vma_struct(mm, vma);
c0107b3c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b46:	89 04 24             	mov    %eax,(%esp)
c0107b49:	e8 15 fd ff ff       	call   c0107863 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0107b4e:	ff 4d f4             	decl   -0xc(%ebp)
c0107b51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b55:	7f 8b                	jg     c0107ae2 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107b57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b5a:	40                   	inc    %eax
c0107b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b5e:	eb 6f                	jmp    c0107bcf <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107b60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b63:	89 d0                	mov    %edx,%eax
c0107b65:	c1 e0 02             	shl    $0x2,%eax
c0107b68:	01 d0                	add    %edx,%eax
c0107b6a:	83 c0 02             	add    $0x2,%eax
c0107b6d:	89 c1                	mov    %eax,%ecx
c0107b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b72:	89 d0                	mov    %edx,%eax
c0107b74:	c1 e0 02             	shl    $0x2,%eax
c0107b77:	01 d0                	add    %edx,%eax
c0107b79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b80:	00 
c0107b81:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107b85:	89 04 24             	mov    %eax,(%esp)
c0107b88:	e8 3f fb ff ff       	call   c01076cc <vma_create>
c0107b8d:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0107b90:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107b94:	75 24                	jne    c0107bba <check_vma_struct+0x136>
c0107b96:	c7 44 24 0c 32 ac 10 	movl   $0xc010ac32,0xc(%esp)
c0107b9d:	c0 
c0107b9e:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107ba5:	c0 
c0107ba6:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0107bad:	00 
c0107bae:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107bb5:	e8 70 91 ff ff       	call   c0100d2a <__panic>
        insert_vma_struct(mm, vma);
c0107bba:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bc4:	89 04 24             	mov    %eax,(%esp)
c0107bc7:	e8 97 fc ff ff       	call   c0107863 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0107bcc:	ff 45 f4             	incl   -0xc(%ebp)
c0107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bd2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107bd5:	7e 89                	jle    c0107b60 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107bd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bda:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107bdd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107be0:	8b 40 04             	mov    0x4(%eax),%eax
c0107be3:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107be6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107bed:	e9 96 00 00 00       	jmp    c0107c88 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bf5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107bf8:	75 24                	jne    c0107c1e <check_vma_struct+0x19a>
c0107bfa:	c7 44 24 0c 3e ac 10 	movl   $0xc010ac3e,0xc(%esp)
c0107c01:	c0 
c0107c02:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107c09:	c0 
c0107c0a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0107c11:	00 
c0107c12:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107c19:	e8 0c 91 ff ff       	call   c0100d2a <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c21:	83 e8 10             	sub    $0x10,%eax
c0107c24:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107c27:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c2a:	8b 48 04             	mov    0x4(%eax),%ecx
c0107c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c30:	89 d0                	mov    %edx,%eax
c0107c32:	c1 e0 02             	shl    $0x2,%eax
c0107c35:	01 d0                	add    %edx,%eax
c0107c37:	39 c1                	cmp    %eax,%ecx
c0107c39:	75 17                	jne    c0107c52 <check_vma_struct+0x1ce>
c0107c3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c3e:	8b 48 08             	mov    0x8(%eax),%ecx
c0107c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c44:	89 d0                	mov    %edx,%eax
c0107c46:	c1 e0 02             	shl    $0x2,%eax
c0107c49:	01 d0                	add    %edx,%eax
c0107c4b:	83 c0 02             	add    $0x2,%eax
c0107c4e:	39 c1                	cmp    %eax,%ecx
c0107c50:	74 24                	je     c0107c76 <check_vma_struct+0x1f2>
c0107c52:	c7 44 24 0c 58 ac 10 	movl   $0xc010ac58,0xc(%esp)
c0107c59:	c0 
c0107c5a:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107c61:	c0 
c0107c62:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0107c69:	00 
c0107c6a:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107c71:	e8 b4 90 ff ff       	call   c0100d2a <__panic>
c0107c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c79:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107c7c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107c7f:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107c85:	ff 45 f4             	incl   -0xc(%ebp)
c0107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c8b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107c8e:	0f 8e 5e ff ff ff    	jle    c0107bf2 <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107c94:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107c9b:	e9 cb 01 00 00       	jmp    c0107e6b <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107caa:	89 04 24             	mov    %eax,(%esp)
c0107cad:	e8 57 fa ff ff       	call   c0107709 <find_vma>
c0107cb2:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0107cb5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107cb9:	75 24                	jne    c0107cdf <check_vma_struct+0x25b>
c0107cbb:	c7 44 24 0c 8d ac 10 	movl   $0xc010ac8d,0xc(%esp)
c0107cc2:	c0 
c0107cc3:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107cca:	c0 
c0107ccb:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0107cd2:	00 
c0107cd3:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107cda:	e8 4b 90 ff ff       	call   c0100d2a <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ce2:	40                   	inc    %eax
c0107ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cea:	89 04 24             	mov    %eax,(%esp)
c0107ced:	e8 17 fa ff ff       	call   c0107709 <find_vma>
c0107cf2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0107cf5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0107cf9:	75 24                	jne    c0107d1f <check_vma_struct+0x29b>
c0107cfb:	c7 44 24 0c 9a ac 10 	movl   $0xc010ac9a,0xc(%esp)
c0107d02:	c0 
c0107d03:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107d0a:	c0 
c0107d0b:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0107d12:	00 
c0107d13:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107d1a:	e8 0b 90 ff ff       	call   c0100d2a <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d22:	83 c0 02             	add    $0x2,%eax
c0107d25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d2c:	89 04 24             	mov    %eax,(%esp)
c0107d2f:	e8 d5 f9 ff ff       	call   c0107709 <find_vma>
c0107d34:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0107d37:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107d3b:	74 24                	je     c0107d61 <check_vma_struct+0x2dd>
c0107d3d:	c7 44 24 0c a7 ac 10 	movl   $0xc010aca7,0xc(%esp)
c0107d44:	c0 
c0107d45:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107d4c:	c0 
c0107d4d:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0107d54:	00 
c0107d55:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107d5c:	e8 c9 8f ff ff       	call   c0100d2a <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d64:	83 c0 03             	add    $0x3,%eax
c0107d67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d6e:	89 04 24             	mov    %eax,(%esp)
c0107d71:	e8 93 f9 ff ff       	call   c0107709 <find_vma>
c0107d76:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0107d79:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107d7d:	74 24                	je     c0107da3 <check_vma_struct+0x31f>
c0107d7f:	c7 44 24 0c b4 ac 10 	movl   $0xc010acb4,0xc(%esp)
c0107d86:	c0 
c0107d87:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107d8e:	c0 
c0107d8f:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0107d96:	00 
c0107d97:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107d9e:	e8 87 8f ff ff       	call   c0100d2a <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107da6:	83 c0 04             	add    $0x4,%eax
c0107da9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107dad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107db0:	89 04 24             	mov    %eax,(%esp)
c0107db3:	e8 51 f9 ff ff       	call   c0107709 <find_vma>
c0107db8:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0107dbb:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107dbf:	74 24                	je     c0107de5 <check_vma_struct+0x361>
c0107dc1:	c7 44 24 0c c1 ac 10 	movl   $0xc010acc1,0xc(%esp)
c0107dc8:	c0 
c0107dc9:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107dd0:	c0 
c0107dd1:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107dd8:	00 
c0107dd9:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107de0:	e8 45 8f ff ff       	call   c0100d2a <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107de5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107de8:	8b 50 04             	mov    0x4(%eax),%edx
c0107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dee:	39 c2                	cmp    %eax,%edx
c0107df0:	75 10                	jne    c0107e02 <check_vma_struct+0x37e>
c0107df2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107df5:	8b 40 08             	mov    0x8(%eax),%eax
c0107df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107dfb:	83 c2 02             	add    $0x2,%edx
c0107dfe:	39 d0                	cmp    %edx,%eax
c0107e00:	74 24                	je     c0107e26 <check_vma_struct+0x3a2>
c0107e02:	c7 44 24 0c d0 ac 10 	movl   $0xc010acd0,0xc(%esp)
c0107e09:	c0 
c0107e0a:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107e11:	c0 
c0107e12:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0107e19:	00 
c0107e1a:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107e21:	e8 04 8f ff ff       	call   c0100d2a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0107e26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e29:	8b 50 04             	mov    0x4(%eax),%edx
c0107e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e2f:	39 c2                	cmp    %eax,%edx
c0107e31:	75 10                	jne    c0107e43 <check_vma_struct+0x3bf>
c0107e33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e36:	8b 40 08             	mov    0x8(%eax),%eax
c0107e39:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e3c:	83 c2 02             	add    $0x2,%edx
c0107e3f:	39 d0                	cmp    %edx,%eax
c0107e41:	74 24                	je     c0107e67 <check_vma_struct+0x3e3>
c0107e43:	c7 44 24 0c 00 ad 10 	movl   $0xc010ad00,0xc(%esp)
c0107e4a:	c0 
c0107e4b:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107e52:	c0 
c0107e53:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107e5a:	00 
c0107e5b:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107e62:	e8 c3 8e ff ff       	call   c0100d2a <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0107e67:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107e6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107e6e:	89 d0                	mov    %edx,%eax
c0107e70:	c1 e0 02             	shl    $0x2,%eax
c0107e73:	01 d0                	add    %edx,%eax
c0107e75:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107e78:	0f 8e 22 fe ff ff    	jle    c0107ca0 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0107e7e:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107e85:	eb 6f                	jmp    c0107ef6 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e91:	89 04 24             	mov    %eax,(%esp)
c0107e94:	e8 70 f8 ff ff       	call   c0107709 <find_vma>
c0107e99:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0107e9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107ea0:	74 27                	je     c0107ec9 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107ea2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ea5:	8b 50 08             	mov    0x8(%eax),%edx
c0107ea8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107eab:	8b 40 04             	mov    0x4(%eax),%eax
c0107eae:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107eb2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ebd:	c7 04 24 30 ad 10 c0 	movl   $0xc010ad30,(%esp)
c0107ec4:	e8 dc 84 ff ff       	call   c01003a5 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107ec9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107ecd:	74 24                	je     c0107ef3 <check_vma_struct+0x46f>
c0107ecf:	c7 44 24 0c 55 ad 10 	movl   $0xc010ad55,0xc(%esp)
c0107ed6:	c0 
c0107ed7:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107ede:	c0 
c0107edf:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0107ee6:	00 
c0107ee7:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107eee:	e8 37 8e ff ff       	call   c0100d2a <__panic>
    for (i =4; i>=0; i--) {
c0107ef3:	ff 4d f4             	decl   -0xc(%ebp)
c0107ef6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107efa:	79 8b                	jns    c0107e87 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0107efc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107eff:	89 04 24             	mov    %eax,(%esp)
c0107f02:	e8 92 fa ff ff       	call   c0107999 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107f07:	e8 79 cd ff ff       	call   c0104c85 <nr_free_pages>
c0107f0c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107f0f:	74 24                	je     c0107f35 <check_vma_struct+0x4b1>
c0107f11:	c7 44 24 0c e8 ab 10 	movl   $0xc010abe8,0xc(%esp)
c0107f18:	c0 
c0107f19:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107f20:	c0 
c0107f21:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107f28:	00 
c0107f29:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107f30:	e8 f5 8d ff ff       	call   c0100d2a <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107f35:	c7 04 24 6c ad 10 c0 	movl   $0xc010ad6c,(%esp)
c0107f3c:	e8 64 84 ff ff       	call   c01003a5 <cprintf>
}
c0107f41:	90                   	nop
c0107f42:	89 ec                	mov    %ebp,%esp
c0107f44:	5d                   	pop    %ebp
c0107f45:	c3                   	ret    

c0107f46 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107f46:	55                   	push   %ebp
c0107f47:	89 e5                	mov    %esp,%ebp
c0107f49:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107f4c:	e8 34 cd ff ff       	call   c0104c85 <nr_free_pages>
c0107f51:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107f54:	e8 f8 f6 ff ff       	call   c0107651 <mm_create>
c0107f59:	a3 6c 71 12 c0       	mov    %eax,0xc012716c
    assert(check_mm_struct != NULL);
c0107f5e:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0107f63:	85 c0                	test   %eax,%eax
c0107f65:	75 24                	jne    c0107f8b <check_pgfault+0x45>
c0107f67:	c7 44 24 0c 8b ad 10 	movl   $0xc010ad8b,0xc(%esp)
c0107f6e:	c0 
c0107f6f:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107f76:	c0 
c0107f77:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0107f7e:	00 
c0107f7f:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107f86:	e8 9f 8d ff ff       	call   c0100d2a <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107f8b:	a1 6c 71 12 c0       	mov    0xc012716c,%eax
c0107f90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107f93:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0107f99:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f9c:	89 50 0c             	mov    %edx,0xc(%eax)
c0107f9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fa2:	8b 40 0c             	mov    0xc(%eax),%eax
c0107fa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fab:	8b 00                	mov    (%eax),%eax
c0107fad:	85 c0                	test   %eax,%eax
c0107faf:	74 24                	je     c0107fd5 <check_pgfault+0x8f>
c0107fb1:	c7 44 24 0c a3 ad 10 	movl   $0xc010ada3,0xc(%esp)
c0107fb8:	c0 
c0107fb9:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0107fc0:	c0 
c0107fc1:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107fc8:	00 
c0107fc9:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107fd0:	e8 55 8d ff ff       	call   c0100d2a <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107fd5:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107fdc:	00 
c0107fdd:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107fe4:	00 
c0107fe5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107fec:	e8 db f6 ff ff       	call   c01076cc <vma_create>
c0107ff1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107ff4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107ff8:	75 24                	jne    c010801e <check_pgfault+0xd8>
c0107ffa:	c7 44 24 0c 32 ac 10 	movl   $0xc010ac32,0xc(%esp)
c0108001:	c0 
c0108002:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0108009:	c0 
c010800a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0108011:	00 
c0108012:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0108019:	e8 0c 8d ff ff       	call   c0100d2a <__panic>

    insert_vma_struct(mm, vma);
c010801e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108021:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108025:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108028:	89 04 24             	mov    %eax,(%esp)
c010802b:	e8 33 f8 ff ff       	call   c0107863 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108030:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108037:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010803a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010803e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108041:	89 04 24             	mov    %eax,(%esp)
c0108044:	e8 c0 f6 ff ff       	call   c0107709 <find_vma>
c0108049:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010804c:	74 24                	je     c0108072 <check_pgfault+0x12c>
c010804e:	c7 44 24 0c b1 ad 10 	movl   $0xc010adb1,0xc(%esp)
c0108055:	c0 
c0108056:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c010805d:	c0 
c010805e:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0108065:	00 
c0108066:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c010806d:	e8 b8 8c ff ff       	call   c0100d2a <__panic>

    int i, sum = 0;
c0108072:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108079:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108080:	eb 16                	jmp    c0108098 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0108082:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108085:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108088:	01 d0                	add    %edx,%eax
c010808a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010808d:	88 10                	mov    %dl,(%eax)
        sum += i;
c010808f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108092:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108095:	ff 45 f4             	incl   -0xc(%ebp)
c0108098:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010809c:	7e e4                	jle    c0108082 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c010809e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01080a5:	eb 14                	jmp    c01080bb <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c01080a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080ad:	01 d0                	add    %edx,%eax
c01080af:	0f b6 00             	movzbl (%eax),%eax
c01080b2:	0f be c0             	movsbl %al,%eax
c01080b5:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01080b8:	ff 45 f4             	incl   -0xc(%ebp)
c01080bb:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01080bf:	7e e6                	jle    c01080a7 <check_pgfault+0x161>
    }
    assert(sum == 0);
c01080c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01080c5:	74 24                	je     c01080eb <check_pgfault+0x1a5>
c01080c7:	c7 44 24 0c cb ad 10 	movl   $0xc010adcb,0xc(%esp)
c01080ce:	c0 
c01080cf:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c01080d6:	c0 
c01080d7:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01080de:	00 
c01080df:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c01080e6:	e8 3f 8c ff ff       	call   c0100d2a <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01080eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01080f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01080f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01080f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108100:	89 04 24             	mov    %eax,(%esp)
c0108103:	e8 8b d3 ff ff       	call   c0105493 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010810b:	8b 00                	mov    (%eax),%eax
c010810d:	89 04 24             	mov    %eax,(%esp)
c0108110:	e8 22 f5 ff ff       	call   c0107637 <pde2page>
c0108115:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010811c:	00 
c010811d:	89 04 24             	mov    %eax,(%esp)
c0108120:	e8 2b cb ff ff       	call   c0104c50 <free_pages>
    pgdir[0] = 0;
c0108125:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108128:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010812e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108131:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108138:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010813b:	89 04 24             	mov    %eax,(%esp)
c010813e:	e8 56 f8 ff ff       	call   c0107999 <mm_destroy>
    check_mm_struct = NULL;
c0108143:	c7 05 6c 71 12 c0 00 	movl   $0x0,0xc012716c
c010814a:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010814d:	e8 33 cb ff ff       	call   c0104c85 <nr_free_pages>
c0108152:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108155:	74 24                	je     c010817b <check_pgfault+0x235>
c0108157:	c7 44 24 0c e8 ab 10 	movl   $0xc010abe8,0xc(%esp)
c010815e:	c0 
c010815f:	c7 44 24 08 67 ab 10 	movl   $0xc010ab67,0x8(%esp)
c0108166:	c0 
c0108167:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c010816e:	00 
c010816f:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0108176:	e8 af 8b ff ff       	call   c0100d2a <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010817b:	c7 04 24 d4 ad 10 c0 	movl   $0xc010add4,(%esp)
c0108182:	e8 1e 82 ff ff       	call   c01003a5 <cprintf>
}
c0108187:	90                   	nop
c0108188:	89 ec                	mov    %ebp,%esp
c010818a:	5d                   	pop    %ebp
c010818b:	c3                   	ret    

c010818c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010818c:	55                   	push   %ebp
c010818d:	89 e5                	mov    %esp,%ebp
c010818f:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108192:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108199:	8b 45 10             	mov    0x10(%ebp),%eax
c010819c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a3:	89 04 24             	mov    %eax,(%esp)
c01081a6:	e8 5e f5 ff ff       	call   c0107709 <find_vma>
c01081ab:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01081ae:	a1 70 71 12 c0       	mov    0xc0127170,%eax
c01081b3:	40                   	inc    %eax
c01081b4:	a3 70 71 12 c0       	mov    %eax,0xc0127170
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01081b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01081bd:	74 0b                	je     c01081ca <do_pgfault+0x3e>
c01081bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081c2:	8b 40 04             	mov    0x4(%eax),%eax
c01081c5:	39 45 10             	cmp    %eax,0x10(%ebp)
c01081c8:	73 18                	jae    c01081e2 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01081ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01081cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081d1:	c7 04 24 f0 ad 10 c0 	movl   $0xc010adf0,(%esp)
c01081d8:	e8 c8 81 ff ff       	call   c01003a5 <cprintf>
        goto failed;
c01081dd:	e9 ba 01 00 00       	jmp    c010839c <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c01081e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081e5:	83 e0 03             	and    $0x3,%eax
c01081e8:	85 c0                	test   %eax,%eax
c01081ea:	74 34                	je     c0108220 <do_pgfault+0x94>
c01081ec:	83 f8 01             	cmp    $0x1,%eax
c01081ef:	74 1e                	je     c010820f <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
            
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01081f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081f4:	8b 40 0c             	mov    0xc(%eax),%eax
c01081f7:	83 e0 02             	and    $0x2,%eax
c01081fa:	85 c0                	test   %eax,%eax
c01081fc:	75 40                	jne    c010823e <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01081fe:	c7 04 24 20 ae 10 c0 	movl   $0xc010ae20,(%esp)
c0108205:	e8 9b 81 ff ff       	call   c01003a5 <cprintf>
            goto failed;
c010820a:	e9 8d 01 00 00       	jmp    c010839c <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010820f:	c7 04 24 80 ae 10 c0 	movl   $0xc010ae80,(%esp)
c0108216:	e8 8a 81 ff ff       	call   c01003a5 <cprintf>
        goto failed;
c010821b:	e9 7c 01 00 00       	jmp    c010839c <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108220:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108223:	8b 40 0c             	mov    0xc(%eax),%eax
c0108226:	83 e0 05             	and    $0x5,%eax
c0108229:	85 c0                	test   %eax,%eax
c010822b:	75 12                	jne    c010823f <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010822d:	c7 04 24 b8 ae 10 c0 	movl   $0xc010aeb8,(%esp)
c0108234:	e8 6c 81 ff ff       	call   c01003a5 <cprintf>
            goto failed;
c0108239:	e9 5e 01 00 00       	jmp    c010839c <do_pgfault+0x210>
        break;
c010823e:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010823f:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108246:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108249:	8b 40 0c             	mov    0xc(%eax),%eax
c010824c:	83 e0 02             	and    $0x2,%eax
c010824f:	85 c0                	test   %eax,%eax
c0108251:	74 04                	je     c0108257 <do_pgfault+0xcb>
        perm |= PTE_W;
c0108253:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108257:	8b 45 10             	mov    0x10(%ebp),%eax
c010825a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010825d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108260:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108265:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108268:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c010826f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0108276:	8b 45 08             	mov    0x8(%ebp),%eax
c0108279:	8b 40 0c             	mov    0xc(%eax),%eax
c010827c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108283:	00 
c0108284:	8b 55 10             	mov    0x10(%ebp),%edx
c0108287:	89 54 24 04          	mov    %edx,0x4(%esp)
c010828b:	89 04 24             	mov    %eax,(%esp)
c010828e:	e8 06 d0 ff ff       	call   c0105299 <get_pte>
c0108293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108296:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010829a:	75 11                	jne    c01082ad <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c010829c:	c7 04 24 1b af 10 c0 	movl   $0xc010af1b,(%esp)
c01082a3:	e8 fd 80 ff ff       	call   c01003a5 <cprintf>
        goto failed;
c01082a8:	e9 ef 00 00 00       	jmp    c010839c <do_pgfault+0x210>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01082ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082b0:	8b 00                	mov    (%eax),%eax
c01082b2:	85 c0                	test   %eax,%eax
c01082b4:	75 35                	jne    c01082eb <do_pgfault+0x15f>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01082b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b9:	8b 40 0c             	mov    0xc(%eax),%eax
c01082bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01082bf:	89 54 24 08          	mov    %edx,0x8(%esp)
c01082c3:	8b 55 10             	mov    0x10(%ebp),%edx
c01082c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082ca:	89 04 24             	mov    %eax,(%esp)
c01082cd:	e8 22 d3 ff ff       	call   c01055f4 <pgdir_alloc_page>
c01082d2:	85 c0                	test   %eax,%eax
c01082d4:	0f 85 bb 00 00 00    	jne    c0108395 <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01082da:	c7 04 24 3c af 10 c0 	movl   $0xc010af3c,(%esp)
c01082e1:	e8 bf 80 ff ff       	call   c01003a5 <cprintf>
            goto failed;
c01082e6:	e9 b1 00 00 00       	jmp    c010839c <do_pgfault+0x210>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c01082eb:	a1 a4 70 12 c0       	mov    0xc01270a4,%eax
c01082f0:	85 c0                	test   %eax,%eax
c01082f2:	0f 84 86 00 00 00    	je     c010837e <do_pgfault+0x1f2>
            struct Page *page=NULL;
c01082f8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01082ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0108302:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108306:	8b 45 10             	mov    0x10(%ebp),%eax
c0108309:	89 44 24 04          	mov    %eax,0x4(%esp)
c010830d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108310:	89 04 24             	mov    %eax,(%esp)
c0108313:	e8 a6 e4 ff ff       	call   c01067be <swap_in>
c0108318:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010831b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010831f:	74 0e                	je     c010832f <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c0108321:	c7 04 24 63 af 10 c0 	movl   $0xc010af63,(%esp)
c0108328:	e8 78 80 ff ff       	call   c01003a5 <cprintf>
c010832d:	eb 6d                	jmp    c010839c <do_pgfault+0x210>
                goto failed;
            }    
            // 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系(perm标识这个二级页表的各个权限位)
            page_insert(mm->pgdir, page, addr, perm);
c010832f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108332:	8b 45 08             	mov    0x8(%ebp),%eax
c0108335:	8b 40 0c             	mov    0xc(%eax),%eax
c0108338:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010833b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010833f:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108342:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108346:	89 54 24 04          	mov    %edx,0x4(%esp)
c010834a:	89 04 24             	mov    %eax,(%esp)
c010834d:	e8 88 d1 ff ff       	call   c01054da <page_insert>
            //// 当前page是为可交换的，将其加入全局虚拟内存交换管理器的管理
            swap_map_swappable(mm, addr, page, 1);
c0108352:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108355:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010835c:	00 
c010835d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108361:	8b 45 10             	mov    0x10(%ebp),%eax
c0108364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108368:	8b 45 08             	mov    0x8(%ebp),%eax
c010836b:	89 04 24             	mov    %eax,(%esp)
c010836e:	e8 83 e2 ff ff       	call   c01065f6 <swap_map_swappable>
            page->pra_vaddr = addr;
c0108373:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108376:	8b 55 10             	mov    0x10(%ebp),%edx
c0108379:	89 50 1c             	mov    %edx,0x1c(%eax)
c010837c:	eb 17                	jmp    c0108395 <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010837e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108381:	8b 00                	mov    (%eax),%eax
c0108383:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108387:	c7 04 24 84 af 10 c0 	movl   $0xc010af84,(%esp)
c010838e:	e8 12 80 ff ff       	call   c01003a5 <cprintf>
            goto failed;
c0108393:	eb 07                	jmp    c010839c <do_pgfault+0x210>
        }
   }
   ret = 0;
c0108395:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010839c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010839f:	89 ec                	mov    %ebp,%esp
c01083a1:	5d                   	pop    %ebp
c01083a2:	c3                   	ret    

c01083a3 <page2ppn>:
page2ppn(struct Page *page) {
c01083a3:	55                   	push   %ebp
c01083a4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01083a6:	8b 15 00 70 12 c0    	mov    0xc0127000,%edx
c01083ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01083af:	29 d0                	sub    %edx,%eax
c01083b1:	c1 f8 05             	sar    $0x5,%eax
}
c01083b4:	5d                   	pop    %ebp
c01083b5:	c3                   	ret    

c01083b6 <page2pa>:
page2pa(struct Page *page) {
c01083b6:	55                   	push   %ebp
c01083b7:	89 e5                	mov    %esp,%ebp
c01083b9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01083bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01083bf:	89 04 24             	mov    %eax,(%esp)
c01083c2:	e8 dc ff ff ff       	call   c01083a3 <page2ppn>
c01083c7:	c1 e0 0c             	shl    $0xc,%eax
}
c01083ca:	89 ec                	mov    %ebp,%esp
c01083cc:	5d                   	pop    %ebp
c01083cd:	c3                   	ret    

c01083ce <page2kva>:
page2kva(struct Page *page) {
c01083ce:	55                   	push   %ebp
c01083cf:	89 e5                	mov    %esp,%ebp
c01083d1:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01083d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083d7:	89 04 24             	mov    %eax,(%esp)
c01083da:	e8 d7 ff ff ff       	call   c01083b6 <page2pa>
c01083df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083e5:	c1 e8 0c             	shr    $0xc,%eax
c01083e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01083eb:	a1 04 70 12 c0       	mov    0xc0127004,%eax
c01083f0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01083f3:	72 23                	jb     c0108418 <page2kva+0x4a>
c01083f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01083fc:	c7 44 24 08 ac af 10 	movl   $0xc010afac,0x8(%esp)
c0108403:	c0 
c0108404:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010840b:	00 
c010840c:	c7 04 24 cf af 10 c0 	movl   $0xc010afcf,(%esp)
c0108413:	e8 12 89 ff ff       	call   c0100d2a <__panic>
c0108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010841b:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108420:	89 ec                	mov    %ebp,%esp
c0108422:	5d                   	pop    %ebp
c0108423:	c3                   	ret    

c0108424 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108424:	55                   	push   %ebp
c0108425:	89 e5                	mov    %esp,%ebp
c0108427:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010842a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108431:	e8 a3 96 ff ff       	call   c0101ad9 <ide_device_valid>
c0108436:	85 c0                	test   %eax,%eax
c0108438:	75 1c                	jne    c0108456 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010843a:	c7 44 24 08 dd af 10 	movl   $0xc010afdd,0x8(%esp)
c0108441:	c0 
c0108442:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0108449:	00 
c010844a:	c7 04 24 f7 af 10 c0 	movl   $0xc010aff7,(%esp)
c0108451:	e8 d4 88 ff ff       	call   c0100d2a <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108456:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010845d:	e8 b7 96 ff ff       	call   c0101b19 <ide_device_size>
c0108462:	c1 e8 03             	shr    $0x3,%eax
c0108465:	a3 a0 70 12 c0       	mov    %eax,0xc01270a0
}
c010846a:	90                   	nop
c010846b:	89 ec                	mov    %ebp,%esp
c010846d:	5d                   	pop    %ebp
c010846e:	c3                   	ret    

c010846f <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010846f:	55                   	push   %ebp
c0108470:	89 e5                	mov    %esp,%ebp
c0108472:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108475:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108478:	89 04 24             	mov    %eax,(%esp)
c010847b:	e8 4e ff ff ff       	call   c01083ce <page2kva>
c0108480:	8b 55 08             	mov    0x8(%ebp),%edx
c0108483:	c1 ea 08             	shr    $0x8,%edx
c0108486:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108489:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010848d:	74 0b                	je     c010849a <swapfs_read+0x2b>
c010848f:	8b 15 a0 70 12 c0    	mov    0xc01270a0,%edx
c0108495:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108498:	72 23                	jb     c01084bd <swapfs_read+0x4e>
c010849a:	8b 45 08             	mov    0x8(%ebp),%eax
c010849d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01084a1:	c7 44 24 08 08 b0 10 	movl   $0xc010b008,0x8(%esp)
c01084a8:	c0 
c01084a9:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01084b0:	00 
c01084b1:	c7 04 24 f7 af 10 c0 	movl   $0xc010aff7,(%esp)
c01084b8:	e8 6d 88 ff ff       	call   c0100d2a <__panic>
c01084bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084c0:	c1 e2 03             	shl    $0x3,%edx
c01084c3:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01084ca:	00 
c01084cb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01084cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084da:	e8 77 96 ff ff       	call   c0101b56 <ide_read_secs>
}
c01084df:	89 ec                	mov    %ebp,%esp
c01084e1:	5d                   	pop    %ebp
c01084e2:	c3                   	ret    

c01084e3 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01084e3:	55                   	push   %ebp
c01084e4:	89 e5                	mov    %esp,%ebp
c01084e6:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01084e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084ec:	89 04 24             	mov    %eax,(%esp)
c01084ef:	e8 da fe ff ff       	call   c01083ce <page2kva>
c01084f4:	8b 55 08             	mov    0x8(%ebp),%edx
c01084f7:	c1 ea 08             	shr    $0x8,%edx
c01084fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01084fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108501:	74 0b                	je     c010850e <swapfs_write+0x2b>
c0108503:	8b 15 a0 70 12 c0    	mov    0xc01270a0,%edx
c0108509:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010850c:	72 23                	jb     c0108531 <swapfs_write+0x4e>
c010850e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108511:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108515:	c7 44 24 08 08 b0 10 	movl   $0xc010b008,0x8(%esp)
c010851c:	c0 
c010851d:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108524:	00 
c0108525:	c7 04 24 f7 af 10 c0 	movl   $0xc010aff7,(%esp)
c010852c:	e8 f9 87 ff ff       	call   c0100d2a <__panic>
c0108531:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108534:	c1 e2 03             	shl    $0x3,%edx
c0108537:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010853e:	00 
c010853f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108543:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108547:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010854e:	e8 44 98 ff ff       	call   c0101d97 <ide_write_secs>
}
c0108553:	89 ec                	mov    %ebp,%esp
c0108555:	5d                   	pop    %ebp
c0108556:	c3                   	ret    

c0108557 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108557:	55                   	push   %ebp
c0108558:	89 e5                	mov    %esp,%ebp
c010855a:	83 ec 58             	sub    $0x58,%esp
c010855d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108560:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108563:	8b 45 14             	mov    0x14(%ebp),%eax
c0108566:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108569:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010856c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010856f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108572:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108575:	8b 45 18             	mov    0x18(%ebp),%eax
c0108578:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010857b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010857e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108581:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108584:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108587:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010858a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010858d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108591:	74 1c                	je     c01085af <printnum+0x58>
c0108593:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108596:	ba 00 00 00 00       	mov    $0x0,%edx
c010859b:	f7 75 e4             	divl   -0x1c(%ebp)
c010859e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01085a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085a4:	ba 00 00 00 00       	mov    $0x0,%edx
c01085a9:	f7 75 e4             	divl   -0x1c(%ebp)
c01085ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085af:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085b5:	f7 75 e4             	divl   -0x1c(%ebp)
c01085b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01085bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01085be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01085c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085c7:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01085ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085cd:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01085d0:	8b 45 18             	mov    0x18(%ebp),%eax
c01085d3:	ba 00 00 00 00       	mov    $0x0,%edx
c01085d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01085db:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01085de:	19 d1                	sbb    %edx,%ecx
c01085e0:	72 4c                	jb     c010862e <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01085e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01085e5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01085e8:	8b 45 20             	mov    0x20(%ebp),%eax
c01085eb:	89 44 24 18          	mov    %eax,0x18(%esp)
c01085ef:	89 54 24 14          	mov    %edx,0x14(%esp)
c01085f3:	8b 45 18             	mov    0x18(%ebp),%eax
c01085f6:	89 44 24 10          	mov    %eax,0x10(%esp)
c01085fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108600:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108604:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010860b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010860f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108612:	89 04 24             	mov    %eax,(%esp)
c0108615:	e8 3d ff ff ff       	call   c0108557 <printnum>
c010861a:	eb 1b                	jmp    c0108637 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010861c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010861f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108623:	8b 45 20             	mov    0x20(%ebp),%eax
c0108626:	89 04 24             	mov    %eax,(%esp)
c0108629:	8b 45 08             	mov    0x8(%ebp),%eax
c010862c:	ff d0                	call   *%eax
        while (-- width > 0)
c010862e:	ff 4d 1c             	decl   0x1c(%ebp)
c0108631:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108635:	7f e5                	jg     c010861c <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108637:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010863a:	05 a8 b0 10 c0       	add    $0xc010b0a8,%eax
c010863f:	0f b6 00             	movzbl (%eax),%eax
c0108642:	0f be c0             	movsbl %al,%eax
c0108645:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108648:	89 54 24 04          	mov    %edx,0x4(%esp)
c010864c:	89 04 24             	mov    %eax,(%esp)
c010864f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108652:	ff d0                	call   *%eax
}
c0108654:	90                   	nop
c0108655:	89 ec                	mov    %ebp,%esp
c0108657:	5d                   	pop    %ebp
c0108658:	c3                   	ret    

c0108659 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108659:	55                   	push   %ebp
c010865a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010865c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108660:	7e 14                	jle    c0108676 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108662:	8b 45 08             	mov    0x8(%ebp),%eax
c0108665:	8b 00                	mov    (%eax),%eax
c0108667:	8d 48 08             	lea    0x8(%eax),%ecx
c010866a:	8b 55 08             	mov    0x8(%ebp),%edx
c010866d:	89 0a                	mov    %ecx,(%edx)
c010866f:	8b 50 04             	mov    0x4(%eax),%edx
c0108672:	8b 00                	mov    (%eax),%eax
c0108674:	eb 30                	jmp    c01086a6 <getuint+0x4d>
    }
    else if (lflag) {
c0108676:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010867a:	74 16                	je     c0108692 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010867c:	8b 45 08             	mov    0x8(%ebp),%eax
c010867f:	8b 00                	mov    (%eax),%eax
c0108681:	8d 48 04             	lea    0x4(%eax),%ecx
c0108684:	8b 55 08             	mov    0x8(%ebp),%edx
c0108687:	89 0a                	mov    %ecx,(%edx)
c0108689:	8b 00                	mov    (%eax),%eax
c010868b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108690:	eb 14                	jmp    c01086a6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108692:	8b 45 08             	mov    0x8(%ebp),%eax
c0108695:	8b 00                	mov    (%eax),%eax
c0108697:	8d 48 04             	lea    0x4(%eax),%ecx
c010869a:	8b 55 08             	mov    0x8(%ebp),%edx
c010869d:	89 0a                	mov    %ecx,(%edx)
c010869f:	8b 00                	mov    (%eax),%eax
c01086a1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01086a6:	5d                   	pop    %ebp
c01086a7:	c3                   	ret    

c01086a8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01086a8:	55                   	push   %ebp
c01086a9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01086ab:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01086af:	7e 14                	jle    c01086c5 <getint+0x1d>
        return va_arg(*ap, long long);
c01086b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b4:	8b 00                	mov    (%eax),%eax
c01086b6:	8d 48 08             	lea    0x8(%eax),%ecx
c01086b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01086bc:	89 0a                	mov    %ecx,(%edx)
c01086be:	8b 50 04             	mov    0x4(%eax),%edx
c01086c1:	8b 00                	mov    (%eax),%eax
c01086c3:	eb 28                	jmp    c01086ed <getint+0x45>
    }
    else if (lflag) {
c01086c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01086c9:	74 12                	je     c01086dd <getint+0x35>
        return va_arg(*ap, long);
c01086cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ce:	8b 00                	mov    (%eax),%eax
c01086d0:	8d 48 04             	lea    0x4(%eax),%ecx
c01086d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01086d6:	89 0a                	mov    %ecx,(%edx)
c01086d8:	8b 00                	mov    (%eax),%eax
c01086da:	99                   	cltd   
c01086db:	eb 10                	jmp    c01086ed <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01086dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01086e0:	8b 00                	mov    (%eax),%eax
c01086e2:	8d 48 04             	lea    0x4(%eax),%ecx
c01086e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01086e8:	89 0a                	mov    %ecx,(%edx)
c01086ea:	8b 00                	mov    (%eax),%eax
c01086ec:	99                   	cltd   
    }
}
c01086ed:	5d                   	pop    %ebp
c01086ee:	c3                   	ret    

c01086ef <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01086ef:	55                   	push   %ebp
c01086f0:	89 e5                	mov    %esp,%ebp
c01086f2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01086f5:	8d 45 14             	lea    0x14(%ebp),%eax
c01086f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01086fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108702:	8b 45 10             	mov    0x10(%ebp),%eax
c0108705:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010870c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108710:	8b 45 08             	mov    0x8(%ebp),%eax
c0108713:	89 04 24             	mov    %eax,(%esp)
c0108716:	e8 05 00 00 00       	call   c0108720 <vprintfmt>
    va_end(ap);
}
c010871b:	90                   	nop
c010871c:	89 ec                	mov    %ebp,%esp
c010871e:	5d                   	pop    %ebp
c010871f:	c3                   	ret    

c0108720 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108720:	55                   	push   %ebp
c0108721:	89 e5                	mov    %esp,%ebp
c0108723:	56                   	push   %esi
c0108724:	53                   	push   %ebx
c0108725:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108728:	eb 17                	jmp    c0108741 <vprintfmt+0x21>
            if (ch == '\0') {
c010872a:	85 db                	test   %ebx,%ebx
c010872c:	0f 84 bf 03 00 00    	je     c0108af1 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0108732:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108735:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108739:	89 1c 24             	mov    %ebx,(%esp)
c010873c:	8b 45 08             	mov    0x8(%ebp),%eax
c010873f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108741:	8b 45 10             	mov    0x10(%ebp),%eax
c0108744:	8d 50 01             	lea    0x1(%eax),%edx
c0108747:	89 55 10             	mov    %edx,0x10(%ebp)
c010874a:	0f b6 00             	movzbl (%eax),%eax
c010874d:	0f b6 d8             	movzbl %al,%ebx
c0108750:	83 fb 25             	cmp    $0x25,%ebx
c0108753:	75 d5                	jne    c010872a <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108755:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108759:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108763:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108766:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010876d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108770:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108773:	8b 45 10             	mov    0x10(%ebp),%eax
c0108776:	8d 50 01             	lea    0x1(%eax),%edx
c0108779:	89 55 10             	mov    %edx,0x10(%ebp)
c010877c:	0f b6 00             	movzbl (%eax),%eax
c010877f:	0f b6 d8             	movzbl %al,%ebx
c0108782:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108785:	83 f8 55             	cmp    $0x55,%eax
c0108788:	0f 87 37 03 00 00    	ja     c0108ac5 <vprintfmt+0x3a5>
c010878e:	8b 04 85 cc b0 10 c0 	mov    -0x3fef4f34(,%eax,4),%eax
c0108795:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108797:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010879b:	eb d6                	jmp    c0108773 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010879d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01087a1:	eb d0                	jmp    c0108773 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01087a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01087aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01087ad:	89 d0                	mov    %edx,%eax
c01087af:	c1 e0 02             	shl    $0x2,%eax
c01087b2:	01 d0                	add    %edx,%eax
c01087b4:	01 c0                	add    %eax,%eax
c01087b6:	01 d8                	add    %ebx,%eax
c01087b8:	83 e8 30             	sub    $0x30,%eax
c01087bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01087be:	8b 45 10             	mov    0x10(%ebp),%eax
c01087c1:	0f b6 00             	movzbl (%eax),%eax
c01087c4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01087c7:	83 fb 2f             	cmp    $0x2f,%ebx
c01087ca:	7e 38                	jle    c0108804 <vprintfmt+0xe4>
c01087cc:	83 fb 39             	cmp    $0x39,%ebx
c01087cf:	7f 33                	jg     c0108804 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01087d1:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01087d4:	eb d4                	jmp    c01087aa <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01087d6:	8b 45 14             	mov    0x14(%ebp),%eax
c01087d9:	8d 50 04             	lea    0x4(%eax),%edx
c01087dc:	89 55 14             	mov    %edx,0x14(%ebp)
c01087df:	8b 00                	mov    (%eax),%eax
c01087e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01087e4:	eb 1f                	jmp    c0108805 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01087e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087ea:	79 87                	jns    c0108773 <vprintfmt+0x53>
                width = 0;
c01087ec:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01087f3:	e9 7b ff ff ff       	jmp    c0108773 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01087f8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01087ff:	e9 6f ff ff ff       	jmp    c0108773 <vprintfmt+0x53>
            goto process_precision;
c0108804:	90                   	nop

        process_precision:
            if (width < 0)
c0108805:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108809:	0f 89 64 ff ff ff    	jns    c0108773 <vprintfmt+0x53>
                width = precision, precision = -1;
c010880f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108812:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108815:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010881c:	e9 52 ff ff ff       	jmp    c0108773 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108821:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0108824:	e9 4a ff ff ff       	jmp    c0108773 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108829:	8b 45 14             	mov    0x14(%ebp),%eax
c010882c:	8d 50 04             	lea    0x4(%eax),%edx
c010882f:	89 55 14             	mov    %edx,0x14(%ebp)
c0108832:	8b 00                	mov    (%eax),%eax
c0108834:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108837:	89 54 24 04          	mov    %edx,0x4(%esp)
c010883b:	89 04 24             	mov    %eax,(%esp)
c010883e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108841:	ff d0                	call   *%eax
            break;
c0108843:	e9 a4 02 00 00       	jmp    c0108aec <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108848:	8b 45 14             	mov    0x14(%ebp),%eax
c010884b:	8d 50 04             	lea    0x4(%eax),%edx
c010884e:	89 55 14             	mov    %edx,0x14(%ebp)
c0108851:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0108853:	85 db                	test   %ebx,%ebx
c0108855:	79 02                	jns    c0108859 <vprintfmt+0x139>
                err = -err;
c0108857:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108859:	83 fb 06             	cmp    $0x6,%ebx
c010885c:	7f 0b                	jg     c0108869 <vprintfmt+0x149>
c010885e:	8b 34 9d 8c b0 10 c0 	mov    -0x3fef4f74(,%ebx,4),%esi
c0108865:	85 f6                	test   %esi,%esi
c0108867:	75 23                	jne    c010888c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0108869:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010886d:	c7 44 24 08 b9 b0 10 	movl   $0xc010b0b9,0x8(%esp)
c0108874:	c0 
c0108875:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108878:	89 44 24 04          	mov    %eax,0x4(%esp)
c010887c:	8b 45 08             	mov    0x8(%ebp),%eax
c010887f:	89 04 24             	mov    %eax,(%esp)
c0108882:	e8 68 fe ff ff       	call   c01086ef <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108887:	e9 60 02 00 00       	jmp    c0108aec <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010888c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108890:	c7 44 24 08 c2 b0 10 	movl   $0xc010b0c2,0x8(%esp)
c0108897:	c0 
c0108898:	8b 45 0c             	mov    0xc(%ebp),%eax
c010889b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010889f:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a2:	89 04 24             	mov    %eax,(%esp)
c01088a5:	e8 45 fe ff ff       	call   c01086ef <printfmt>
            break;
c01088aa:	e9 3d 02 00 00       	jmp    c0108aec <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01088af:	8b 45 14             	mov    0x14(%ebp),%eax
c01088b2:	8d 50 04             	lea    0x4(%eax),%edx
c01088b5:	89 55 14             	mov    %edx,0x14(%ebp)
c01088b8:	8b 30                	mov    (%eax),%esi
c01088ba:	85 f6                	test   %esi,%esi
c01088bc:	75 05                	jne    c01088c3 <vprintfmt+0x1a3>
                p = "(null)";
c01088be:	be c5 b0 10 c0       	mov    $0xc010b0c5,%esi
            }
            if (width > 0 && padc != '-') {
c01088c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088c7:	7e 76                	jle    c010893f <vprintfmt+0x21f>
c01088c9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01088cd:	74 70                	je     c010893f <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088d6:	89 34 24             	mov    %esi,(%esp)
c01088d9:	e8 ee 03 00 00       	call   c0108ccc <strnlen>
c01088de:	89 c2                	mov    %eax,%edx
c01088e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088e3:	29 d0                	sub    %edx,%eax
c01088e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01088e8:	eb 16                	jmp    c0108900 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01088ea:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01088ee:	8b 55 0c             	mov    0xc(%ebp),%edx
c01088f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01088f5:	89 04 24             	mov    %eax,(%esp)
c01088f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01088fb:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088fd:	ff 4d e8             	decl   -0x18(%ebp)
c0108900:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108904:	7f e4                	jg     c01088ea <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108906:	eb 37                	jmp    c010893f <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108908:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010890c:	74 1f                	je     c010892d <vprintfmt+0x20d>
c010890e:	83 fb 1f             	cmp    $0x1f,%ebx
c0108911:	7e 05                	jle    c0108918 <vprintfmt+0x1f8>
c0108913:	83 fb 7e             	cmp    $0x7e,%ebx
c0108916:	7e 15                	jle    c010892d <vprintfmt+0x20d>
                    putch('?', putdat);
c0108918:	8b 45 0c             	mov    0xc(%ebp),%eax
c010891b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010891f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0108926:	8b 45 08             	mov    0x8(%ebp),%eax
c0108929:	ff d0                	call   *%eax
c010892b:	eb 0f                	jmp    c010893c <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010892d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108930:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108934:	89 1c 24             	mov    %ebx,(%esp)
c0108937:	8b 45 08             	mov    0x8(%ebp),%eax
c010893a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010893c:	ff 4d e8             	decl   -0x18(%ebp)
c010893f:	89 f0                	mov    %esi,%eax
c0108941:	8d 70 01             	lea    0x1(%eax),%esi
c0108944:	0f b6 00             	movzbl (%eax),%eax
c0108947:	0f be d8             	movsbl %al,%ebx
c010894a:	85 db                	test   %ebx,%ebx
c010894c:	74 27                	je     c0108975 <vprintfmt+0x255>
c010894e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108952:	78 b4                	js     c0108908 <vprintfmt+0x1e8>
c0108954:	ff 4d e4             	decl   -0x1c(%ebp)
c0108957:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010895b:	79 ab                	jns    c0108908 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010895d:	eb 16                	jmp    c0108975 <vprintfmt+0x255>
                putch(' ', putdat);
c010895f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108962:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108966:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010896d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108970:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0108972:	ff 4d e8             	decl   -0x18(%ebp)
c0108975:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108979:	7f e4                	jg     c010895f <vprintfmt+0x23f>
            }
            break;
c010897b:	e9 6c 01 00 00       	jmp    c0108aec <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108980:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108983:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108987:	8d 45 14             	lea    0x14(%ebp),%eax
c010898a:	89 04 24             	mov    %eax,(%esp)
c010898d:	e8 16 fd ff ff       	call   c01086a8 <getint>
c0108992:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108995:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108998:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010899b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010899e:	85 d2                	test   %edx,%edx
c01089a0:	79 26                	jns    c01089c8 <vprintfmt+0x2a8>
                putch('-', putdat);
c01089a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01089b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b3:	ff d0                	call   *%eax
                num = -(long long)num;
c01089b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089bb:	f7 d8                	neg    %eax
c01089bd:	83 d2 00             	adc    $0x0,%edx
c01089c0:	f7 da                	neg    %edx
c01089c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01089c8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089cf:	e9 a8 00 00 00       	jmp    c0108a7c <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01089d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089db:	8d 45 14             	lea    0x14(%ebp),%eax
c01089de:	89 04 24             	mov    %eax,(%esp)
c01089e1:	e8 73 fc ff ff       	call   c0108659 <getuint>
c01089e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01089ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089f3:	e9 84 00 00 00       	jmp    c0108a7c <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01089f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089ff:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a02:	89 04 24             	mov    %eax,(%esp)
c0108a05:	e8 4f fc ff ff       	call   c0108659 <getuint>
c0108a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108a10:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108a17:	eb 63                	jmp    c0108a7c <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0108a19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a20:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108a27:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a2a:	ff d0                	call   *%eax
            putch('x', putdat);
c0108a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a33:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108a3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a3d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108a3f:	8b 45 14             	mov    0x14(%ebp),%eax
c0108a42:	8d 50 04             	lea    0x4(%eax),%edx
c0108a45:	89 55 14             	mov    %edx,0x14(%ebp)
c0108a48:	8b 00                	mov    (%eax),%eax
c0108a4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108a54:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108a5b:	eb 1f                	jmp    c0108a7c <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108a5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a64:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a67:	89 04 24             	mov    %eax,(%esp)
c0108a6a:	e8 ea fb ff ff       	call   c0108659 <getuint>
c0108a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a72:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108a75:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108a7c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a83:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108a87:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a8a:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108a8e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a95:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a98:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108a9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aaa:	89 04 24             	mov    %eax,(%esp)
c0108aad:	e8 a5 fa ff ff       	call   c0108557 <printnum>
            break;
c0108ab2:	eb 38                	jmp    c0108aec <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108abb:	89 1c 24             	mov    %ebx,(%esp)
c0108abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ac1:	ff d0                	call   *%eax
            break;
c0108ac3:	eb 27                	jmp    c0108aec <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108acc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108ad8:	ff 4d 10             	decl   0x10(%ebp)
c0108adb:	eb 03                	jmp    c0108ae0 <vprintfmt+0x3c0>
c0108add:	ff 4d 10             	decl   0x10(%ebp)
c0108ae0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ae3:	48                   	dec    %eax
c0108ae4:	0f b6 00             	movzbl (%eax),%eax
c0108ae7:	3c 25                	cmp    $0x25,%al
c0108ae9:	75 f2                	jne    c0108add <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0108aeb:	90                   	nop
    while (1) {
c0108aec:	e9 37 fc ff ff       	jmp    c0108728 <vprintfmt+0x8>
                return;
c0108af1:	90                   	nop
        }
    }
}
c0108af2:	83 c4 40             	add    $0x40,%esp
c0108af5:	5b                   	pop    %ebx
c0108af6:	5e                   	pop    %esi
c0108af7:	5d                   	pop    %ebp
c0108af8:	c3                   	ret    

c0108af9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108af9:	55                   	push   %ebp
c0108afa:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108afc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aff:	8b 40 08             	mov    0x8(%eax),%eax
c0108b02:	8d 50 01             	lea    0x1(%eax),%edx
c0108b05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b08:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b0e:	8b 10                	mov    (%eax),%edx
c0108b10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b13:	8b 40 04             	mov    0x4(%eax),%eax
c0108b16:	39 c2                	cmp    %eax,%edx
c0108b18:	73 12                	jae    c0108b2c <sprintputch+0x33>
        *b->buf ++ = ch;
c0108b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b1d:	8b 00                	mov    (%eax),%eax
c0108b1f:	8d 48 01             	lea    0x1(%eax),%ecx
c0108b22:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b25:	89 0a                	mov    %ecx,(%edx)
c0108b27:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b2a:	88 10                	mov    %dl,(%eax)
    }
}
c0108b2c:	90                   	nop
c0108b2d:	5d                   	pop    %ebp
c0108b2e:	c3                   	ret    

c0108b2f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108b2f:	55                   	push   %ebp
c0108b30:	89 e5                	mov    %esp,%ebp
c0108b32:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108b35:	8d 45 14             	lea    0x14(%ebp),%eax
c0108b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108b42:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b45:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b53:	89 04 24             	mov    %eax,(%esp)
c0108b56:	e8 0a 00 00 00       	call   c0108b65 <vsnprintf>
c0108b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108b61:	89 ec                	mov    %ebp,%esp
c0108b63:	5d                   	pop    %ebp
c0108b64:	c3                   	ret    

c0108b65 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108b65:	55                   	push   %ebp
c0108b66:	89 e5                	mov    %esp,%ebp
c0108b68:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b74:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b7a:	01 d0                	add    %edx,%eax
c0108b7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108b86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108b8a:	74 0a                	je     c0108b96 <vsnprintf+0x31>
c0108b8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b92:	39 c2                	cmp    %eax,%edx
c0108b94:	76 07                	jbe    c0108b9d <vsnprintf+0x38>
        return -E_INVAL;
c0108b96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108b9b:	eb 2a                	jmp    c0108bc7 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108b9d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ba0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108ba4:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ba7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108bab:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108bae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108bb2:	c7 04 24 f9 8a 10 c0 	movl   $0xc0108af9,(%esp)
c0108bb9:	e8 62 fb ff ff       	call   c0108720 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108bbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bc1:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108bc7:	89 ec                	mov    %ebp,%esp
c0108bc9:	5d                   	pop    %ebp
c0108bca:	c3                   	ret    

c0108bcb <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108bcb:	55                   	push   %ebp
c0108bcc:	89 e5                	mov    %esp,%ebp
c0108bce:	57                   	push   %edi
c0108bcf:	56                   	push   %esi
c0108bd0:	53                   	push   %ebx
c0108bd1:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108bd4:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108bd9:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108bdf:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108be5:	6b f0 05             	imul   $0x5,%eax,%esi
c0108be8:	01 fe                	add    %edi,%esi
c0108bea:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108bef:	f7 e7                	mul    %edi
c0108bf1:	01 d6                	add    %edx,%esi
c0108bf3:	89 f2                	mov    %esi,%edx
c0108bf5:	83 c0 0b             	add    $0xb,%eax
c0108bf8:	83 d2 00             	adc    $0x0,%edx
c0108bfb:	89 c7                	mov    %eax,%edi
c0108bfd:	83 e7 ff             	and    $0xffffffff,%edi
c0108c00:	89 f9                	mov    %edi,%ecx
c0108c02:	0f b7 da             	movzwl %dx,%ebx
c0108c05:	89 0d 60 3a 12 c0    	mov    %ecx,0xc0123a60
c0108c0b:	89 1d 64 3a 12 c0    	mov    %ebx,0xc0123a64
    unsigned long long result = (next >> 12);
c0108c11:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108c16:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108c1c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108c20:	c1 ea 0c             	shr    $0xc,%edx
c0108c23:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108c29:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c36:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c39:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c42:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108c46:	74 1c                	je     c0108c64 <rand+0x99>
c0108c48:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c4b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c50:	f7 75 dc             	divl   -0x24(%ebp)
c0108c53:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108c56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c59:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c5e:	f7 75 dc             	divl   -0x24(%ebp)
c0108c61:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c64:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c67:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108c6a:	f7 75 dc             	divl   -0x24(%ebp)
c0108c6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c70:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108c73:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c76:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c7c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108c82:	83 c4 24             	add    $0x24,%esp
c0108c85:	5b                   	pop    %ebx
c0108c86:	5e                   	pop    %esi
c0108c87:	5f                   	pop    %edi
c0108c88:	5d                   	pop    %ebp
c0108c89:	c3                   	ret    

c0108c8a <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108c8a:	55                   	push   %ebp
c0108c8b:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108c8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c90:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c95:	a3 60 3a 12 c0       	mov    %eax,0xc0123a60
c0108c9a:	89 15 64 3a 12 c0    	mov    %edx,0xc0123a64
}
c0108ca0:	90                   	nop
c0108ca1:	5d                   	pop    %ebp
c0108ca2:	c3                   	ret    

c0108ca3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108ca3:	55                   	push   %ebp
c0108ca4:	89 e5                	mov    %esp,%ebp
c0108ca6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108ca9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108cb0:	eb 03                	jmp    c0108cb5 <strlen+0x12>
        cnt ++;
c0108cb2:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0108cb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cb8:	8d 50 01             	lea    0x1(%eax),%edx
c0108cbb:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cbe:	0f b6 00             	movzbl (%eax),%eax
c0108cc1:	84 c0                	test   %al,%al
c0108cc3:	75 ed                	jne    c0108cb2 <strlen+0xf>
    }
    return cnt;
c0108cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108cc8:	89 ec                	mov    %ebp,%esp
c0108cca:	5d                   	pop    %ebp
c0108ccb:	c3                   	ret    

c0108ccc <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108ccc:	55                   	push   %ebp
c0108ccd:	89 e5                	mov    %esp,%ebp
c0108ccf:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108cd2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cd9:	eb 03                	jmp    c0108cde <strnlen+0x12>
        cnt ++;
c0108cdb:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cde:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ce1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108ce4:	73 10                	jae    c0108cf6 <strnlen+0x2a>
c0108ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce9:	8d 50 01             	lea    0x1(%eax),%edx
c0108cec:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cef:	0f b6 00             	movzbl (%eax),%eax
c0108cf2:	84 c0                	test   %al,%al
c0108cf4:	75 e5                	jne    c0108cdb <strnlen+0xf>
    }
    return cnt;
c0108cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108cf9:	89 ec                	mov    %ebp,%esp
c0108cfb:	5d                   	pop    %ebp
c0108cfc:	c3                   	ret    

c0108cfd <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108cfd:	55                   	push   %ebp
c0108cfe:	89 e5                	mov    %esp,%ebp
c0108d00:	57                   	push   %edi
c0108d01:	56                   	push   %esi
c0108d02:	83 ec 20             	sub    $0x20,%esp
c0108d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d08:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108d11:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d17:	89 d1                	mov    %edx,%ecx
c0108d19:	89 c2                	mov    %eax,%edx
c0108d1b:	89 ce                	mov    %ecx,%esi
c0108d1d:	89 d7                	mov    %edx,%edi
c0108d1f:	ac                   	lods   %ds:(%esi),%al
c0108d20:	aa                   	stos   %al,%es:(%edi)
c0108d21:	84 c0                	test   %al,%al
c0108d23:	75 fa                	jne    c0108d1f <strcpy+0x22>
c0108d25:	89 fa                	mov    %edi,%edx
c0108d27:	89 f1                	mov    %esi,%ecx
c0108d29:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108d2c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108d2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108d35:	83 c4 20             	add    $0x20,%esp
c0108d38:	5e                   	pop    %esi
c0108d39:	5f                   	pop    %edi
c0108d3a:	5d                   	pop    %ebp
c0108d3b:	c3                   	ret    

c0108d3c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108d3c:	55                   	push   %ebp
c0108d3d:	89 e5                	mov    %esp,%ebp
c0108d3f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d45:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108d48:	eb 1e                	jmp    c0108d68 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0108d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d4d:	0f b6 10             	movzbl (%eax),%edx
c0108d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d53:	88 10                	mov    %dl,(%eax)
c0108d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d58:	0f b6 00             	movzbl (%eax),%eax
c0108d5b:	84 c0                	test   %al,%al
c0108d5d:	74 03                	je     c0108d62 <strncpy+0x26>
            src ++;
c0108d5f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108d62:	ff 45 fc             	incl   -0x4(%ebp)
c0108d65:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0108d68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d6c:	75 dc                	jne    c0108d4a <strncpy+0xe>
    }
    return dst;
c0108d6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108d71:	89 ec                	mov    %ebp,%esp
c0108d73:	5d                   	pop    %ebp
c0108d74:	c3                   	ret    

c0108d75 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108d75:	55                   	push   %ebp
c0108d76:	89 e5                	mov    %esp,%ebp
c0108d78:	57                   	push   %edi
c0108d79:	56                   	push   %esi
c0108d7a:	83 ec 20             	sub    $0x20,%esp
c0108d7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108d89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d8f:	89 d1                	mov    %edx,%ecx
c0108d91:	89 c2                	mov    %eax,%edx
c0108d93:	89 ce                	mov    %ecx,%esi
c0108d95:	89 d7                	mov    %edx,%edi
c0108d97:	ac                   	lods   %ds:(%esi),%al
c0108d98:	ae                   	scas   %es:(%edi),%al
c0108d99:	75 08                	jne    c0108da3 <strcmp+0x2e>
c0108d9b:	84 c0                	test   %al,%al
c0108d9d:	75 f8                	jne    c0108d97 <strcmp+0x22>
c0108d9f:	31 c0                	xor    %eax,%eax
c0108da1:	eb 04                	jmp    c0108da7 <strcmp+0x32>
c0108da3:	19 c0                	sbb    %eax,%eax
c0108da5:	0c 01                	or     $0x1,%al
c0108da7:	89 fa                	mov    %edi,%edx
c0108da9:	89 f1                	mov    %esi,%ecx
c0108dab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108dae:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108db1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0108db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108db7:	83 c4 20             	add    $0x20,%esp
c0108dba:	5e                   	pop    %esi
c0108dbb:	5f                   	pop    %edi
c0108dbc:	5d                   	pop    %ebp
c0108dbd:	c3                   	ret    

c0108dbe <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108dbe:	55                   	push   %ebp
c0108dbf:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dc1:	eb 09                	jmp    c0108dcc <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108dc3:	ff 4d 10             	decl   0x10(%ebp)
c0108dc6:	ff 45 08             	incl   0x8(%ebp)
c0108dc9:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108dd0:	74 1a                	je     c0108dec <strncmp+0x2e>
c0108dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dd5:	0f b6 00             	movzbl (%eax),%eax
c0108dd8:	84 c0                	test   %al,%al
c0108dda:	74 10                	je     c0108dec <strncmp+0x2e>
c0108ddc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ddf:	0f b6 10             	movzbl (%eax),%edx
c0108de2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108de5:	0f b6 00             	movzbl (%eax),%eax
c0108de8:	38 c2                	cmp    %al,%dl
c0108dea:	74 d7                	je     c0108dc3 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108dec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108df0:	74 18                	je     c0108e0a <strncmp+0x4c>
c0108df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108df5:	0f b6 00             	movzbl (%eax),%eax
c0108df8:	0f b6 d0             	movzbl %al,%edx
c0108dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dfe:	0f b6 00             	movzbl (%eax),%eax
c0108e01:	0f b6 c8             	movzbl %al,%ecx
c0108e04:	89 d0                	mov    %edx,%eax
c0108e06:	29 c8                	sub    %ecx,%eax
c0108e08:	eb 05                	jmp    c0108e0f <strncmp+0x51>
c0108e0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e0f:	5d                   	pop    %ebp
c0108e10:	c3                   	ret    

c0108e11 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108e11:	55                   	push   %ebp
c0108e12:	89 e5                	mov    %esp,%ebp
c0108e14:	83 ec 04             	sub    $0x4,%esp
c0108e17:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e1a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e1d:	eb 13                	jmp    c0108e32 <strchr+0x21>
        if (*s == c) {
c0108e1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e22:	0f b6 00             	movzbl (%eax),%eax
c0108e25:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e28:	75 05                	jne    c0108e2f <strchr+0x1e>
            return (char *)s;
c0108e2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e2d:	eb 12                	jmp    c0108e41 <strchr+0x30>
        }
        s ++;
c0108e2f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e32:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e35:	0f b6 00             	movzbl (%eax),%eax
c0108e38:	84 c0                	test   %al,%al
c0108e3a:	75 e3                	jne    c0108e1f <strchr+0xe>
    }
    return NULL;
c0108e3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e41:	89 ec                	mov    %ebp,%esp
c0108e43:	5d                   	pop    %ebp
c0108e44:	c3                   	ret    

c0108e45 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108e45:	55                   	push   %ebp
c0108e46:	89 e5                	mov    %esp,%ebp
c0108e48:	83 ec 04             	sub    $0x4,%esp
c0108e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e4e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e51:	eb 0e                	jmp    c0108e61 <strfind+0x1c>
        if (*s == c) {
c0108e53:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e56:	0f b6 00             	movzbl (%eax),%eax
c0108e59:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e5c:	74 0f                	je     c0108e6d <strfind+0x28>
            break;
        }
        s ++;
c0108e5e:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e61:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e64:	0f b6 00             	movzbl (%eax),%eax
c0108e67:	84 c0                	test   %al,%al
c0108e69:	75 e8                	jne    c0108e53 <strfind+0xe>
c0108e6b:	eb 01                	jmp    c0108e6e <strfind+0x29>
            break;
c0108e6d:	90                   	nop
    }
    return (char *)s;
c0108e6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108e71:	89 ec                	mov    %ebp,%esp
c0108e73:	5d                   	pop    %ebp
c0108e74:	c3                   	ret    

c0108e75 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108e75:	55                   	push   %ebp
c0108e76:	89 e5                	mov    %esp,%ebp
c0108e78:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108e7b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108e82:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108e89:	eb 03                	jmp    c0108e8e <strtol+0x19>
        s ++;
c0108e8b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108e8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e91:	0f b6 00             	movzbl (%eax),%eax
c0108e94:	3c 20                	cmp    $0x20,%al
c0108e96:	74 f3                	je     c0108e8b <strtol+0x16>
c0108e98:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e9b:	0f b6 00             	movzbl (%eax),%eax
c0108e9e:	3c 09                	cmp    $0x9,%al
c0108ea0:	74 e9                	je     c0108e8b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0108ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea5:	0f b6 00             	movzbl (%eax),%eax
c0108ea8:	3c 2b                	cmp    $0x2b,%al
c0108eaa:	75 05                	jne    c0108eb1 <strtol+0x3c>
        s ++;
c0108eac:	ff 45 08             	incl   0x8(%ebp)
c0108eaf:	eb 14                	jmp    c0108ec5 <strtol+0x50>
    }
    else if (*s == '-') {
c0108eb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eb4:	0f b6 00             	movzbl (%eax),%eax
c0108eb7:	3c 2d                	cmp    $0x2d,%al
c0108eb9:	75 0a                	jne    c0108ec5 <strtol+0x50>
        s ++, neg = 1;
c0108ebb:	ff 45 08             	incl   0x8(%ebp)
c0108ebe:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108ec5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ec9:	74 06                	je     c0108ed1 <strtol+0x5c>
c0108ecb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108ecf:	75 22                	jne    c0108ef3 <strtol+0x7e>
c0108ed1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ed4:	0f b6 00             	movzbl (%eax),%eax
c0108ed7:	3c 30                	cmp    $0x30,%al
c0108ed9:	75 18                	jne    c0108ef3 <strtol+0x7e>
c0108edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ede:	40                   	inc    %eax
c0108edf:	0f b6 00             	movzbl (%eax),%eax
c0108ee2:	3c 78                	cmp    $0x78,%al
c0108ee4:	75 0d                	jne    c0108ef3 <strtol+0x7e>
        s += 2, base = 16;
c0108ee6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108eea:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108ef1:	eb 29                	jmp    c0108f1c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108ef3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ef7:	75 16                	jne    c0108f0f <strtol+0x9a>
c0108ef9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108efc:	0f b6 00             	movzbl (%eax),%eax
c0108eff:	3c 30                	cmp    $0x30,%al
c0108f01:	75 0c                	jne    c0108f0f <strtol+0x9a>
        s ++, base = 8;
c0108f03:	ff 45 08             	incl   0x8(%ebp)
c0108f06:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108f0d:	eb 0d                	jmp    c0108f1c <strtol+0xa7>
    }
    else if (base == 0) {
c0108f0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f13:	75 07                	jne    c0108f1c <strtol+0xa7>
        base = 10;
c0108f15:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f1f:	0f b6 00             	movzbl (%eax),%eax
c0108f22:	3c 2f                	cmp    $0x2f,%al
c0108f24:	7e 1b                	jle    c0108f41 <strtol+0xcc>
c0108f26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f29:	0f b6 00             	movzbl (%eax),%eax
c0108f2c:	3c 39                	cmp    $0x39,%al
c0108f2e:	7f 11                	jg     c0108f41 <strtol+0xcc>
            dig = *s - '0';
c0108f30:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f33:	0f b6 00             	movzbl (%eax),%eax
c0108f36:	0f be c0             	movsbl %al,%eax
c0108f39:	83 e8 30             	sub    $0x30,%eax
c0108f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f3f:	eb 48                	jmp    c0108f89 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f44:	0f b6 00             	movzbl (%eax),%eax
c0108f47:	3c 60                	cmp    $0x60,%al
c0108f49:	7e 1b                	jle    c0108f66 <strtol+0xf1>
c0108f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f4e:	0f b6 00             	movzbl (%eax),%eax
c0108f51:	3c 7a                	cmp    $0x7a,%al
c0108f53:	7f 11                	jg     c0108f66 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f58:	0f b6 00             	movzbl (%eax),%eax
c0108f5b:	0f be c0             	movsbl %al,%eax
c0108f5e:	83 e8 57             	sub    $0x57,%eax
c0108f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f64:	eb 23                	jmp    c0108f89 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108f66:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f69:	0f b6 00             	movzbl (%eax),%eax
c0108f6c:	3c 40                	cmp    $0x40,%al
c0108f6e:	7e 3b                	jle    c0108fab <strtol+0x136>
c0108f70:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f73:	0f b6 00             	movzbl (%eax),%eax
c0108f76:	3c 5a                	cmp    $0x5a,%al
c0108f78:	7f 31                	jg     c0108fab <strtol+0x136>
            dig = *s - 'A' + 10;
c0108f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f7d:	0f b6 00             	movzbl (%eax),%eax
c0108f80:	0f be c0             	movsbl %al,%eax
c0108f83:	83 e8 37             	sub    $0x37,%eax
c0108f86:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f8c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108f8f:	7d 19                	jge    c0108faa <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108f91:	ff 45 08             	incl   0x8(%ebp)
c0108f94:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f97:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108f9b:	89 c2                	mov    %eax,%edx
c0108f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fa0:	01 d0                	add    %edx,%eax
c0108fa2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108fa5:	e9 72 ff ff ff       	jmp    c0108f1c <strtol+0xa7>
            break;
c0108faa:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108fab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108faf:	74 08                	je     c0108fb9 <strtol+0x144>
        *endptr = (char *) s;
c0108fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fb4:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fb7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108fb9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108fbd:	74 07                	je     c0108fc6 <strtol+0x151>
c0108fbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108fc2:	f7 d8                	neg    %eax
c0108fc4:	eb 03                	jmp    c0108fc9 <strtol+0x154>
c0108fc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108fc9:	89 ec                	mov    %ebp,%esp
c0108fcb:	5d                   	pop    %ebp
c0108fcc:	c3                   	ret    

c0108fcd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108fcd:	55                   	push   %ebp
c0108fce:	89 e5                	mov    %esp,%ebp
c0108fd0:	83 ec 28             	sub    $0x28,%esp
c0108fd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0108fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fd9:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108fdc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0108fe0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fe3:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0108fe6:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0108fe9:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fec:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108fef:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108ff2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108ff6:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108ff9:	89 d7                	mov    %edx,%edi
c0108ffb:	f3 aa                	rep stos %al,%es:(%edi)
c0108ffd:	89 fa                	mov    %edi,%edx
c0108fff:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109002:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109005:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109008:	8b 7d fc             	mov    -0x4(%ebp),%edi
c010900b:	89 ec                	mov    %ebp,%esp
c010900d:	5d                   	pop    %ebp
c010900e:	c3                   	ret    

c010900f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010900f:	55                   	push   %ebp
c0109010:	89 e5                	mov    %esp,%ebp
c0109012:	57                   	push   %edi
c0109013:	56                   	push   %esi
c0109014:	53                   	push   %ebx
c0109015:	83 ec 30             	sub    $0x30,%esp
c0109018:	8b 45 08             	mov    0x8(%ebp),%eax
c010901b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010901e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109021:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109024:	8b 45 10             	mov    0x10(%ebp),%eax
c0109027:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010902a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010902d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109030:	73 42                	jae    c0109074 <memmove+0x65>
c0109032:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109035:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109038:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010903b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010903e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109041:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109044:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109047:	c1 e8 02             	shr    $0x2,%eax
c010904a:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010904c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010904f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109052:	89 d7                	mov    %edx,%edi
c0109054:	89 c6                	mov    %eax,%esi
c0109056:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109058:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010905b:	83 e1 03             	and    $0x3,%ecx
c010905e:	74 02                	je     c0109062 <memmove+0x53>
c0109060:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109062:	89 f0                	mov    %esi,%eax
c0109064:	89 fa                	mov    %edi,%edx
c0109066:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109069:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010906c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010906f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0109072:	eb 36                	jmp    c01090aa <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109074:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109077:	8d 50 ff             	lea    -0x1(%eax),%edx
c010907a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010907d:	01 c2                	add    %eax,%edx
c010907f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109082:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109085:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109088:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010908b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010908e:	89 c1                	mov    %eax,%ecx
c0109090:	89 d8                	mov    %ebx,%eax
c0109092:	89 d6                	mov    %edx,%esi
c0109094:	89 c7                	mov    %eax,%edi
c0109096:	fd                   	std    
c0109097:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109099:	fc                   	cld    
c010909a:	89 f8                	mov    %edi,%eax
c010909c:	89 f2                	mov    %esi,%edx
c010909e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01090a1:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01090a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01090a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01090aa:	83 c4 30             	add    $0x30,%esp
c01090ad:	5b                   	pop    %ebx
c01090ae:	5e                   	pop    %esi
c01090af:	5f                   	pop    %edi
c01090b0:	5d                   	pop    %ebp
c01090b1:	c3                   	ret    

c01090b2 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01090b2:	55                   	push   %ebp
c01090b3:	89 e5                	mov    %esp,%ebp
c01090b5:	57                   	push   %edi
c01090b6:	56                   	push   %esi
c01090b7:	83 ec 20             	sub    $0x20,%esp
c01090ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01090bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01090c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01090cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090cf:	c1 e8 02             	shr    $0x2,%eax
c01090d2:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01090d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090da:	89 d7                	mov    %edx,%edi
c01090dc:	89 c6                	mov    %eax,%esi
c01090de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01090e0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01090e3:	83 e1 03             	and    $0x3,%ecx
c01090e6:	74 02                	je     c01090ea <memcpy+0x38>
c01090e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01090ea:	89 f0                	mov    %esi,%eax
c01090ec:	89 fa                	mov    %edi,%edx
c01090ee:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01090f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01090f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01090f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01090fa:	83 c4 20             	add    $0x20,%esp
c01090fd:	5e                   	pop    %esi
c01090fe:	5f                   	pop    %edi
c01090ff:	5d                   	pop    %ebp
c0109100:	c3                   	ret    

c0109101 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0109101:	55                   	push   %ebp
c0109102:	89 e5                	mov    %esp,%ebp
c0109104:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0109107:	8b 45 08             	mov    0x8(%ebp),%eax
c010910a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010910d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109110:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0109113:	eb 2e                	jmp    c0109143 <memcmp+0x42>
        if (*s1 != *s2) {
c0109115:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109118:	0f b6 10             	movzbl (%eax),%edx
c010911b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010911e:	0f b6 00             	movzbl (%eax),%eax
c0109121:	38 c2                	cmp    %al,%dl
c0109123:	74 18                	je     c010913d <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109125:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109128:	0f b6 00             	movzbl (%eax),%eax
c010912b:	0f b6 d0             	movzbl %al,%edx
c010912e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109131:	0f b6 00             	movzbl (%eax),%eax
c0109134:	0f b6 c8             	movzbl %al,%ecx
c0109137:	89 d0                	mov    %edx,%eax
c0109139:	29 c8                	sub    %ecx,%eax
c010913b:	eb 18                	jmp    c0109155 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010913d:	ff 45 fc             	incl   -0x4(%ebp)
c0109140:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0109143:	8b 45 10             	mov    0x10(%ebp),%eax
c0109146:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109149:	89 55 10             	mov    %edx,0x10(%ebp)
c010914c:	85 c0                	test   %eax,%eax
c010914e:	75 c5                	jne    c0109115 <memcmp+0x14>
    }
    return 0;
c0109150:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109155:	89 ec                	mov    %ebp,%esp
c0109157:	5d                   	pop    %ebp
c0109158:	c3                   	ret    
