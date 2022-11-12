
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
c0100020:	a3 00 d0 11 c0       	mov    %eax,0xc011d000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 c0 11 c0       	mov    $0xc011c000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	f3 0f 1e fb          	endbr32 
c010003a:	55                   	push   %ebp
c010003b:	89 e5                	mov    %esp,%ebp
c010003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100040:	b8 20 00 12 c0       	mov    $0xc0120020,%eax
c0100045:	2d 00 f0 11 c0       	sub    $0xc011f000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 f0 11 c0 	movl   $0xc011f000,(%esp)
c010005d:	e8 48 6a 00 00       	call   c0106aaa <memset>

    cons_init();                // init the console
c0100062:	e8 4b 16 00 00       	call   c01016b2 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 72 10 c0 	movl   $0xc01072e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 72 10 c0 	movl   $0xc01072fc,(%esp)
c010007c:	e8 44 02 00 00       	call   c01002c5 <cprintf>

    print_kerninfo();
c0100081:	e8 02 09 00 00       	call   c0100988 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 95 00 00 00       	call   c0100120 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 55 36 00 00       	call   c01036e5 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 98 17 00 00       	call   c010182d <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 3d 19 00 00       	call   c01019d7 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 5a 0d 00 00       	call   c0100df9 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 d5 18 00 00       	call   c0101979 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	f3 0f 1e fb          	endbr32 
c01000aa:	55                   	push   %ebp
c01000ab:	89 e5                	mov    %esp,%ebp
c01000ad:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b7:	00 
c01000b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bf:	00 
c01000c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c7:	e8 17 0d 00 00       	call   c0100de3 <mon_backtrace>
}
c01000cc:	90                   	nop
c01000cd:	c9                   	leave  
c01000ce:	c3                   	ret    

c01000cf <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cf:	f3 0f 1e fb          	endbr32 
c01000d3:	55                   	push   %ebp
c01000d4:	89 e5                	mov    %esp,%ebp
c01000d6:	53                   	push   %ebx
c01000d7:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000da:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000dd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e0:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000ea:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f2:	89 04 24             	mov    %eax,(%esp)
c01000f5:	e8 ac ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000fa:	90                   	nop
c01000fb:	83 c4 14             	add    $0x14,%esp
c01000fe:	5b                   	pop    %ebx
c01000ff:	5d                   	pop    %ebp
c0100100:	c3                   	ret    

c0100101 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100101:	f3 0f 1e fb          	endbr32 
c0100105:	55                   	push   %ebp
c0100106:	89 e5                	mov    %esp,%ebp
c0100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010b:	8b 45 10             	mov    0x10(%ebp),%eax
c010010e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100112:	8b 45 08             	mov    0x8(%ebp),%eax
c0100115:	89 04 24             	mov    %eax,(%esp)
c0100118:	e8 b2 ff ff ff       	call   c01000cf <grade_backtrace1>
}
c010011d:	90                   	nop
c010011e:	c9                   	leave  
c010011f:	c3                   	ret    

c0100120 <grade_backtrace>:

void
grade_backtrace(void) {
c0100120:	f3 0f 1e fb          	endbr32 
c0100124:	55                   	push   %ebp
c0100125:	89 e5                	mov    %esp,%ebp
c0100127:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100136:	ff 
c0100137:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100142:	e8 ba ff ff ff       	call   c0100101 <grade_backtrace0>
}
c0100147:	90                   	nop
c0100148:	c9                   	leave  
c0100149:	c3                   	ret    

c010014a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014a:	f3 0f 1e fb          	endbr32 
c010014e:	55                   	push   %ebp
c010014f:	89 e5                	mov    %esp,%ebp
c0100151:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100154:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100157:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015a:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100160:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100164:	83 e0 03             	and    $0x3,%eax
c0100167:	89 c2                	mov    %eax,%edx
c0100169:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c010016e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100172:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100176:	c7 04 24 01 73 10 c0 	movl   $0xc0107301,(%esp)
c010017d:	e8 43 01 00 00       	call   c01002c5 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100182:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100186:	89 c2                	mov    %eax,%edx
c0100188:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 0f 73 10 c0 	movl   $0xc010730f,(%esp)
c010019c:	e8 24 01 00 00       	call   c01002c5 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a1:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a5:	89 c2                	mov    %eax,%edx
c01001a7:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c01001ac:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b4:	c7 04 24 1d 73 10 c0 	movl   $0xc010731d,(%esp)
c01001bb:	e8 05 01 00 00       	call   c01002c5 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c4:	89 c2                	mov    %eax,%edx
c01001c6:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c01001cb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d3:	c7 04 24 2b 73 10 c0 	movl   $0xc010732b,(%esp)
c01001da:	e8 e6 00 00 00       	call   c01002c5 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001df:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e3:	89 c2                	mov    %eax,%edx
c01001e5:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c01001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f2:	c7 04 24 39 73 10 c0 	movl   $0xc0107339,(%esp)
c01001f9:	e8 c7 00 00 00       	call   c01002c5 <cprintf>
    round ++;
c01001fe:	a1 00 f0 11 c0       	mov    0xc011f000,%eax
c0100203:	40                   	inc    %eax
c0100204:	a3 00 f0 11 c0       	mov    %eax,0xc011f000
}
c0100209:	90                   	nop
c010020a:	c9                   	leave  
c010020b:	c3                   	ret    

c010020c <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020c:	f3 0f 1e fb          	endbr32 
c0100210:	55                   	push   %ebp
c0100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	__asm__ __volatile__ (
c0100213:	83 ec 08             	sub    $0x8,%esp
c0100216:	cd 78                	int    $0x78
c0100218:	89 ec                	mov    %ebp,%esp
		"int %0 \n"
        "movl %%ebp, %%esp\n"
		:
		:"i" (T_SWITCH_TOU)
	);
}
c010021a:	90                   	nop
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021d:	f3 0f 1e fb          	endbr32 
c0100221:	55                   	push   %ebp
c0100222:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    __asm__ __volatile__(
c0100224:	cd 79                	int    $0x79
c0100226:	89 ec                	mov    %ebp,%esp
    	"int %0 \n"
    	"movl %%ebp,%%esp \n" 
    	:
    	:"i"(T_SWITCH_TOK)
    );
}
c0100228:	90                   	nop
c0100229:	5d                   	pop    %ebp
c010022a:	c3                   	ret    

c010022b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010022b:	f3 0f 1e fb          	endbr32 
c010022f:	55                   	push   %ebp
c0100230:	89 e5                	mov    %esp,%ebp
c0100232:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100235:	e8 10 ff ff ff       	call   c010014a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010023a:	c7 04 24 48 73 10 c0 	movl   $0xc0107348,(%esp)
c0100241:	e8 7f 00 00 00       	call   c01002c5 <cprintf>
    lab1_switch_to_user();
c0100246:	e8 c1 ff ff ff       	call   c010020c <lab1_switch_to_user>
    lab1_print_cur_status();
c010024b:	e8 fa fe ff ff       	call   c010014a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100250:	c7 04 24 68 73 10 c0 	movl   $0xc0107368,(%esp)
c0100257:	e8 69 00 00 00       	call   c01002c5 <cprintf>
    lab1_switch_to_kernel();
c010025c:	e8 bc ff ff ff       	call   c010021d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100261:	e8 e4 fe ff ff       	call   c010014a <lab1_print_cur_status>
}
c0100266:	90                   	nop
c0100267:	c9                   	leave  
c0100268:	c3                   	ret    

c0100269 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100269:	f3 0f 1e fb          	endbr32 
c010026d:	55                   	push   %ebp
c010026e:	89 e5                	mov    %esp,%ebp
c0100270:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 04 24             	mov    %eax,(%esp)
c0100279:	e8 65 14 00 00       	call   c01016e3 <cons_putc>
    (*cnt) ++;
c010027e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100281:	8b 00                	mov    (%eax),%eax
c0100283:	8d 50 01             	lea    0x1(%eax),%edx
c0100286:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100289:	89 10                	mov    %edx,(%eax)
}
c010028b:	90                   	nop
c010028c:	c9                   	leave  
c010028d:	c3                   	ret    

c010028e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010028e:	f3 0f 1e fb          	endbr32 
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100298:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010029f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01002a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01002ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b4:	c7 04 24 69 02 10 c0 	movl   $0xc0100269,(%esp)
c01002bb:	e8 56 6b 00 00       	call   c0106e16 <vprintfmt>
    return cnt;
c01002c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c3:	c9                   	leave  
c01002c4:	c3                   	ret    

c01002c5 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002c5:	f3 0f 1e fb          	endbr32 
c01002c9:	55                   	push   %ebp
c01002ca:	89 e5                	mov    %esp,%ebp
c01002cc:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002cf:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01002df:	89 04 24             	mov    %eax,(%esp)
c01002e2:	e8 a7 ff ff ff       	call   c010028e <vcprintf>
c01002e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002ed:	c9                   	leave  
c01002ee:	c3                   	ret    

c01002ef <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002ef:	f3 0f 1e fb          	endbr32 
c01002f3:	55                   	push   %ebp
c01002f4:	89 e5                	mov    %esp,%ebp
c01002f6:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fc:	89 04 24             	mov    %eax,(%esp)
c01002ff:	e8 df 13 00 00       	call   c01016e3 <cons_putc>
}
c0100304:	90                   	nop
c0100305:	c9                   	leave  
c0100306:	c3                   	ret    

c0100307 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100307:	f3 0f 1e fb          	endbr32 
c010030b:	55                   	push   %ebp
c010030c:	89 e5                	mov    %esp,%ebp
c010030e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100311:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100318:	eb 13                	jmp    c010032d <cputs+0x26>
        cputch(c, &cnt);
c010031a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010031e:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100321:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100325:	89 04 24             	mov    %eax,(%esp)
c0100328:	e8 3c ff ff ff       	call   c0100269 <cputch>
    while ((c = *str ++) != '\0') {
c010032d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100330:	8d 50 01             	lea    0x1(%eax),%edx
c0100333:	89 55 08             	mov    %edx,0x8(%ebp)
c0100336:	0f b6 00             	movzbl (%eax),%eax
c0100339:	88 45 f7             	mov    %al,-0x9(%ebp)
c010033c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100340:	75 d8                	jne    c010031a <cputs+0x13>
    }
    cputch('\n', &cnt);
c0100342:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100345:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100349:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100350:	e8 14 ff ff ff       	call   c0100269 <cputch>
    return cnt;
c0100355:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100358:	c9                   	leave  
c0100359:	c3                   	ret    

c010035a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010035a:	f3 0f 1e fb          	endbr32 
c010035e:	55                   	push   %ebp
c010035f:	89 e5                	mov    %esp,%ebp
c0100361:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100364:	90                   	nop
c0100365:	e8 ba 13 00 00       	call   c0101724 <cons_getc>
c010036a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010036d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100371:	74 f2                	je     c0100365 <getchar+0xb>
        /* do nothing */;
    return c;
c0100373:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100376:	c9                   	leave  
c0100377:	c3                   	ret    

c0100378 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100378:	f3 0f 1e fb          	endbr32 
c010037c:	55                   	push   %ebp
c010037d:	89 e5                	mov    %esp,%ebp
c010037f:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100382:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100386:	74 13                	je     c010039b <readline+0x23>
        cprintf("%s", prompt);
c0100388:	8b 45 08             	mov    0x8(%ebp),%eax
c010038b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010038f:	c7 04 24 87 73 10 c0 	movl   $0xc0107387,(%esp)
c0100396:	e8 2a ff ff ff       	call   c01002c5 <cprintf>
    }
    int i = 0, c;
c010039b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01003a2:	e8 b3 ff ff ff       	call   c010035a <getchar>
c01003a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01003aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003ae:	79 07                	jns    c01003b7 <readline+0x3f>
            return NULL;
c01003b0:	b8 00 00 00 00       	mov    $0x0,%eax
c01003b5:	eb 78                	jmp    c010042f <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01003b7:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01003bb:	7e 28                	jle    c01003e5 <readline+0x6d>
c01003bd:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01003c4:	7f 1f                	jg     c01003e5 <readline+0x6d>
            cputchar(c);
c01003c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c9:	89 04 24             	mov    %eax,(%esp)
c01003cc:	e8 1e ff ff ff       	call   c01002ef <cputchar>
            buf[i ++] = c;
c01003d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d4:	8d 50 01             	lea    0x1(%eax),%edx
c01003d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003da:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003dd:	88 90 20 f0 11 c0    	mov    %dl,-0x3fee0fe0(%eax)
c01003e3:	eb 45                	jmp    c010042a <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
c01003e5:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003e9:	75 16                	jne    c0100401 <readline+0x89>
c01003eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ef:	7e 10                	jle    c0100401 <readline+0x89>
            cputchar(c);
c01003f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f4:	89 04 24             	mov    %eax,(%esp)
c01003f7:	e8 f3 fe ff ff       	call   c01002ef <cputchar>
            i --;
c01003fc:	ff 4d f4             	decl   -0xc(%ebp)
c01003ff:	eb 29                	jmp    c010042a <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
c0100401:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100405:	74 06                	je     c010040d <readline+0x95>
c0100407:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010040b:	75 95                	jne    c01003a2 <readline+0x2a>
            cputchar(c);
c010040d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100410:	89 04 24             	mov    %eax,(%esp)
c0100413:	e8 d7 fe ff ff       	call   c01002ef <cputchar>
            buf[i] = '\0';
c0100418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010041b:	05 20 f0 11 c0       	add    $0xc011f020,%eax
c0100420:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100423:	b8 20 f0 11 c0       	mov    $0xc011f020,%eax
c0100428:	eb 05                	jmp    c010042f <readline+0xb7>
        c = getchar();
c010042a:	e9 73 ff ff ff       	jmp    c01003a2 <readline+0x2a>
        }
    }
}
c010042f:	c9                   	leave  
c0100430:	c3                   	ret    

c0100431 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100431:	f3 0f 1e fb          	endbr32 
c0100435:	55                   	push   %ebp
c0100436:	89 e5                	mov    %esp,%ebp
c0100438:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c010043b:	a1 20 f4 11 c0       	mov    0xc011f420,%eax
c0100440:	85 c0                	test   %eax,%eax
c0100442:	75 5b                	jne    c010049f <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100444:	c7 05 20 f4 11 c0 01 	movl   $0x1,0xc011f420
c010044b:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010044e:	8d 45 14             	lea    0x14(%ebp),%eax
c0100451:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100454:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100457:	89 44 24 08          	mov    %eax,0x8(%esp)
c010045b:	8b 45 08             	mov    0x8(%ebp),%eax
c010045e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100462:	c7 04 24 8a 73 10 c0 	movl   $0xc010738a,(%esp)
c0100469:	e8 57 fe ff ff       	call   c01002c5 <cprintf>
    vcprintf(fmt, ap);
c010046e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100471:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100475:	8b 45 10             	mov    0x10(%ebp),%eax
c0100478:	89 04 24             	mov    %eax,(%esp)
c010047b:	e8 0e fe ff ff       	call   c010028e <vcprintf>
    cprintf("\n");
c0100480:	c7 04 24 a6 73 10 c0 	movl   $0xc01073a6,(%esp)
c0100487:	e8 39 fe ff ff       	call   c01002c5 <cprintf>
    
    cprintf("stack trackback:\n");
c010048c:	c7 04 24 a8 73 10 c0 	movl   $0xc01073a8,(%esp)
c0100493:	e8 2d fe ff ff       	call   c01002c5 <cprintf>
    print_stackframe();
c0100498:	e8 3d 06 00 00       	call   c0100ada <print_stackframe>
c010049d:	eb 01                	jmp    c01004a0 <__panic+0x6f>
        goto panic_dead;
c010049f:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004a0:	e8 e0 14 00 00       	call   c0101985 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004ac:	e8 59 08 00 00       	call   c0100d0a <kmonitor>
c01004b1:	eb f2                	jmp    c01004a5 <__panic+0x74>

c01004b3 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01004b3:	f3 0f 1e fb          	endbr32 
c01004b7:	55                   	push   %ebp
c01004b8:	89 e5                	mov    %esp,%ebp
c01004ba:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01004bd:	8d 45 14             	lea    0x14(%ebp),%eax
c01004c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004d1:	c7 04 24 ba 73 10 c0 	movl   $0xc01073ba,(%esp)
c01004d8:	e8 e8 fd ff ff       	call   c01002c5 <cprintf>
    vcprintf(fmt, ap);
c01004dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004e4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e7:	89 04 24             	mov    %eax,(%esp)
c01004ea:	e8 9f fd ff ff       	call   c010028e <vcprintf>
    cprintf("\n");
c01004ef:	c7 04 24 a6 73 10 c0 	movl   $0xc01073a6,(%esp)
c01004f6:	e8 ca fd ff ff       	call   c01002c5 <cprintf>
    va_end(ap);
}
c01004fb:	90                   	nop
c01004fc:	c9                   	leave  
c01004fd:	c3                   	ret    

c01004fe <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004fe:	f3 0f 1e fb          	endbr32 
c0100502:	55                   	push   %ebp
c0100503:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100505:	a1 20 f4 11 c0       	mov    0xc011f420,%eax
}
c010050a:	5d                   	pop    %ebp
c010050b:	c3                   	ret    

c010050c <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c010050c:	f3 0f 1e fb          	endbr32 
c0100510:	55                   	push   %ebp
c0100511:	89 e5                	mov    %esp,%ebp
c0100513:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100519:	8b 00                	mov    (%eax),%eax
c010051b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010051e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100521:	8b 00                	mov    (%eax),%eax
c0100523:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010052d:	e9 ca 00 00 00       	jmp    c01005fc <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
c0100532:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100535:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100538:	01 d0                	add    %edx,%eax
c010053a:	89 c2                	mov    %eax,%edx
c010053c:	c1 ea 1f             	shr    $0x1f,%edx
c010053f:	01 d0                	add    %edx,%eax
c0100541:	d1 f8                	sar    %eax
c0100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100546:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100549:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010054c:	eb 03                	jmp    c0100551 <stab_binsearch+0x45>
            m --;
c010054e:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100551:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100554:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100557:	7c 1f                	jl     c0100578 <stab_binsearch+0x6c>
c0100559:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010055c:	89 d0                	mov    %edx,%eax
c010055e:	01 c0                	add    %eax,%eax
c0100560:	01 d0                	add    %edx,%eax
c0100562:	c1 e0 02             	shl    $0x2,%eax
c0100565:	89 c2                	mov    %eax,%edx
c0100567:	8b 45 08             	mov    0x8(%ebp),%eax
c010056a:	01 d0                	add    %edx,%eax
c010056c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100570:	0f b6 c0             	movzbl %al,%eax
c0100573:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100576:	75 d6                	jne    c010054e <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
c0100578:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010057b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010057e:	7d 09                	jge    c0100589 <stab_binsearch+0x7d>
            l = true_m + 1;
c0100580:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100583:	40                   	inc    %eax
c0100584:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100587:	eb 73                	jmp    c01005fc <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
c0100589:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100590:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100593:	89 d0                	mov    %edx,%eax
c0100595:	01 c0                	add    %eax,%eax
c0100597:	01 d0                	add    %edx,%eax
c0100599:	c1 e0 02             	shl    $0x2,%eax
c010059c:	89 c2                	mov    %eax,%edx
c010059e:	8b 45 08             	mov    0x8(%ebp),%eax
c01005a1:	01 d0                	add    %edx,%eax
c01005a3:	8b 40 08             	mov    0x8(%eax),%eax
c01005a6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005a9:	76 11                	jbe    c01005bc <stab_binsearch+0xb0>
            *region_left = m;
c01005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b1:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01005b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005b6:	40                   	inc    %eax
c01005b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01005ba:	eb 40                	jmp    c01005fc <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
c01005bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005bf:	89 d0                	mov    %edx,%eax
c01005c1:	01 c0                	add    %eax,%eax
c01005c3:	01 d0                	add    %edx,%eax
c01005c5:	c1 e0 02             	shl    $0x2,%eax
c01005c8:	89 c2                	mov    %eax,%edx
c01005ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01005cd:	01 d0                	add    %edx,%eax
c01005cf:	8b 40 08             	mov    0x8(%eax),%eax
c01005d2:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005d5:	73 14                	jae    c01005eb <stab_binsearch+0xdf>
            *region_right = m - 1;
c01005d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005da:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e0:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e5:	48                   	dec    %eax
c01005e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005e9:	eb 11                	jmp    c01005fc <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005f1:	89 10                	mov    %edx,(%eax)
            l = m;
c01005f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005f9:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100602:	0f 8e 2a ff ff ff    	jle    c0100532 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
c0100608:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010060c:	75 0f                	jne    c010061d <stab_binsearch+0x111>
        *region_right = *region_left - 1;
c010060e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100611:	8b 00                	mov    (%eax),%eax
c0100613:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100616:	8b 45 10             	mov    0x10(%ebp),%eax
c0100619:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010061b:	eb 3e                	jmp    c010065b <stab_binsearch+0x14f>
        l = *region_right;
c010061d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100620:	8b 00                	mov    (%eax),%eax
c0100622:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100625:	eb 03                	jmp    c010062a <stab_binsearch+0x11e>
c0100627:	ff 4d fc             	decl   -0x4(%ebp)
c010062a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062d:	8b 00                	mov    (%eax),%eax
c010062f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100632:	7e 1f                	jle    c0100653 <stab_binsearch+0x147>
c0100634:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100637:	89 d0                	mov    %edx,%eax
c0100639:	01 c0                	add    %eax,%eax
c010063b:	01 d0                	add    %edx,%eax
c010063d:	c1 e0 02             	shl    $0x2,%eax
c0100640:	89 c2                	mov    %eax,%edx
c0100642:	8b 45 08             	mov    0x8(%ebp),%eax
c0100645:	01 d0                	add    %edx,%eax
c0100647:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010064b:	0f b6 c0             	movzbl %al,%eax
c010064e:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100651:	75 d4                	jne    c0100627 <stab_binsearch+0x11b>
        *region_left = l;
c0100653:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100656:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100659:	89 10                	mov    %edx,(%eax)
}
c010065b:	90                   	nop
c010065c:	c9                   	leave  
c010065d:	c3                   	ret    

c010065e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010065e:	f3 0f 1e fb          	endbr32 
c0100662:	55                   	push   %ebp
c0100663:	89 e5                	mov    %esp,%ebp
c0100665:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100668:	8b 45 0c             	mov    0xc(%ebp),%eax
c010066b:	c7 00 d8 73 10 c0    	movl   $0xc01073d8,(%eax)
    info->eip_line = 0;
c0100671:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100674:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010067b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010067e:	c7 40 08 d8 73 10 c0 	movl   $0xc01073d8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100685:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100688:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010068f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100692:	8b 55 08             	mov    0x8(%ebp),%edx
c0100695:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01006a2:	c7 45 f4 ec 88 10 c0 	movl   $0xc01088ec,-0xc(%ebp)
    stab_end = __STAB_END__;
c01006a9:	c7 45 f0 9c 6e 11 c0 	movl   $0xc0116e9c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01006b0:	c7 45 ec 9d 6e 11 c0 	movl   $0xc0116e9d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01006b7:	c7 45 e8 61 9c 11 c0 	movl   $0xc0119c61,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c4:	76 0b                	jbe    c01006d1 <debuginfo_eip+0x73>
c01006c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c9:	48                   	dec    %eax
c01006ca:	0f b6 00             	movzbl (%eax),%eax
c01006cd:	84 c0                	test   %al,%al
c01006cf:	74 0a                	je     c01006db <debuginfo_eip+0x7d>
        return -1;
c01006d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d6:	e9 ab 02 00 00       	jmp    c0100986 <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006e5:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006e8:	c1 f8 02             	sar    $0x2,%eax
c01006eb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006f1:	48                   	dec    %eax
c01006f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006fc:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100703:	00 
c0100704:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100707:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010070e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100712:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100715:	89 04 24             	mov    %eax,(%esp)
c0100718:	e8 ef fd ff ff       	call   c010050c <stab_binsearch>
    if (lfile == 0)
c010071d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100720:	85 c0                	test   %eax,%eax
c0100722:	75 0a                	jne    c010072e <debuginfo_eip+0xd0>
        return -1;
c0100724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100729:	e9 58 02 00 00       	jmp    c0100986 <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010072e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100731:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100734:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100737:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010073a:	8b 45 08             	mov    0x8(%ebp),%eax
c010073d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100741:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100748:	00 
c0100749:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010074c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100750:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100753:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100757:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075a:	89 04 24             	mov    %eax,(%esp)
c010075d:	e8 aa fd ff ff       	call   c010050c <stab_binsearch>

    if (lfun <= rfun) {
c0100762:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100765:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100768:	39 c2                	cmp    %eax,%edx
c010076a:	7f 78                	jg     c01007e4 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010076c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010076f:	89 c2                	mov    %eax,%edx
c0100771:	89 d0                	mov    %edx,%eax
c0100773:	01 c0                	add    %eax,%eax
c0100775:	01 d0                	add    %edx,%eax
c0100777:	c1 e0 02             	shl    $0x2,%eax
c010077a:	89 c2                	mov    %eax,%edx
c010077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077f:	01 d0                	add    %edx,%eax
c0100781:	8b 10                	mov    (%eax),%edx
c0100783:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100786:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100789:	39 c2                	cmp    %eax,%edx
c010078b:	73 22                	jae    c01007af <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010078d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100790:	89 c2                	mov    %eax,%edx
c0100792:	89 d0                	mov    %edx,%eax
c0100794:	01 c0                	add    %eax,%eax
c0100796:	01 d0                	add    %edx,%eax
c0100798:	c1 e0 02             	shl    $0x2,%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a0:	01 d0                	add    %edx,%eax
c01007a2:	8b 10                	mov    (%eax),%edx
c01007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007a7:	01 c2                	add    %eax,%edx
c01007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ac:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007b2:	89 c2                	mov    %eax,%edx
c01007b4:	89 d0                	mov    %edx,%eax
c01007b6:	01 c0                	add    %eax,%eax
c01007b8:	01 d0                	add    %edx,%eax
c01007ba:	c1 e0 02             	shl    $0x2,%eax
c01007bd:	89 c2                	mov    %eax,%edx
c01007bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c2:	01 d0                	add    %edx,%eax
c01007c4:	8b 50 08             	mov    0x8(%eax),%edx
c01007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ca:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d0:	8b 40 10             	mov    0x10(%eax),%eax
c01007d3:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007df:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007e2:	eb 15                	jmp    c01007f9 <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ea:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007fc:	8b 40 08             	mov    0x8(%eax),%eax
c01007ff:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100806:	00 
c0100807:	89 04 24             	mov    %eax,(%esp)
c010080a:	e8 0f 61 00 00       	call   c010691e <strfind>
c010080f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100812:	8b 52 08             	mov    0x8(%edx),%edx
c0100815:	29 d0                	sub    %edx,%eax
c0100817:	89 c2                	mov    %eax,%edx
c0100819:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081c:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010081f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100822:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100826:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010082d:	00 
c010082e:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100831:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100835:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100838:	89 44 24 04          	mov    %eax,0x4(%esp)
c010083c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083f:	89 04 24             	mov    %eax,(%esp)
c0100842:	e8 c5 fc ff ff       	call   c010050c <stab_binsearch>
    if (lline <= rline) {
c0100847:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010084d:	39 c2                	cmp    %eax,%edx
c010084f:	7f 23                	jg     c0100874 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
c0100851:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100854:	89 c2                	mov    %eax,%edx
c0100856:	89 d0                	mov    %edx,%eax
c0100858:	01 c0                	add    %eax,%eax
c010085a:	01 d0                	add    %edx,%eax
c010085c:	c1 e0 02             	shl    $0x2,%eax
c010085f:	89 c2                	mov    %eax,%edx
c0100861:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100864:	01 d0                	add    %edx,%eax
c0100866:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010086f:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100872:	eb 11                	jmp    c0100885 <debuginfo_eip+0x227>
        return -1;
c0100874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100879:	e9 08 01 00 00       	jmp    c0100986 <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010087e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100881:	48                   	dec    %eax
c0100882:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100885:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100888:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010088b:	39 c2                	cmp    %eax,%edx
c010088d:	7c 56                	jl     c01008e5 <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
c010088f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100892:	89 c2                	mov    %eax,%edx
c0100894:	89 d0                	mov    %edx,%eax
c0100896:	01 c0                	add    %eax,%eax
c0100898:	01 d0                	add    %edx,%eax
c010089a:	c1 e0 02             	shl    $0x2,%eax
c010089d:	89 c2                	mov    %eax,%edx
c010089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a2:	01 d0                	add    %edx,%eax
c01008a4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008a8:	3c 84                	cmp    $0x84,%al
c01008aa:	74 39                	je     c01008e5 <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008af:	89 c2                	mov    %eax,%edx
c01008b1:	89 d0                	mov    %edx,%eax
c01008b3:	01 c0                	add    %eax,%eax
c01008b5:	01 d0                	add    %edx,%eax
c01008b7:	c1 e0 02             	shl    $0x2,%eax
c01008ba:	89 c2                	mov    %eax,%edx
c01008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bf:	01 d0                	add    %edx,%eax
c01008c1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c5:	3c 64                	cmp    $0x64,%al
c01008c7:	75 b5                	jne    c010087e <debuginfo_eip+0x220>
c01008c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008cc:	89 c2                	mov    %eax,%edx
c01008ce:	89 d0                	mov    %edx,%eax
c01008d0:	01 c0                	add    %eax,%eax
c01008d2:	01 d0                	add    %edx,%eax
c01008d4:	c1 e0 02             	shl    $0x2,%eax
c01008d7:	89 c2                	mov    %eax,%edx
c01008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008dc:	01 d0                	add    %edx,%eax
c01008de:	8b 40 08             	mov    0x8(%eax),%eax
c01008e1:	85 c0                	test   %eax,%eax
c01008e3:	74 99                	je     c010087e <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008eb:	39 c2                	cmp    %eax,%edx
c01008ed:	7c 42                	jl     c0100931 <debuginfo_eip+0x2d3>
c01008ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f2:	89 c2                	mov    %eax,%edx
c01008f4:	89 d0                	mov    %edx,%eax
c01008f6:	01 c0                	add    %eax,%eax
c01008f8:	01 d0                	add    %edx,%eax
c01008fa:	c1 e0 02             	shl    $0x2,%eax
c01008fd:	89 c2                	mov    %eax,%edx
c01008ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100902:	01 d0                	add    %edx,%eax
c0100904:	8b 10                	mov    (%eax),%edx
c0100906:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100909:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010090c:	39 c2                	cmp    %eax,%edx
c010090e:	73 21                	jae    c0100931 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100910:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100913:	89 c2                	mov    %eax,%edx
c0100915:	89 d0                	mov    %edx,%eax
c0100917:	01 c0                	add    %eax,%eax
c0100919:	01 d0                	add    %edx,%eax
c010091b:	c1 e0 02             	shl    $0x2,%eax
c010091e:	89 c2                	mov    %eax,%edx
c0100920:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100923:	01 d0                	add    %edx,%eax
c0100925:	8b 10                	mov    (%eax),%edx
c0100927:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092a:	01 c2                	add    %eax,%edx
c010092c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010092f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100931:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100934:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100937:	39 c2                	cmp    %eax,%edx
c0100939:	7d 46                	jge    c0100981 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
c010093b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010093e:	40                   	inc    %eax
c010093f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100942:	eb 16                	jmp    c010095a <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100944:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100947:	8b 40 14             	mov    0x14(%eax),%eax
c010094a:	8d 50 01             	lea    0x1(%eax),%edx
c010094d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100950:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100953:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100956:	40                   	inc    %eax
c0100957:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010095d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100960:	39 c2                	cmp    %eax,%edx
c0100962:	7d 1d                	jge    c0100981 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100964:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100967:	89 c2                	mov    %eax,%edx
c0100969:	89 d0                	mov    %edx,%eax
c010096b:	01 c0                	add    %eax,%eax
c010096d:	01 d0                	add    %edx,%eax
c010096f:	c1 e0 02             	shl    $0x2,%eax
c0100972:	89 c2                	mov    %eax,%edx
c0100974:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100977:	01 d0                	add    %edx,%eax
c0100979:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010097d:	3c a0                	cmp    $0xa0,%al
c010097f:	74 c3                	je     c0100944 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
c0100981:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100986:	c9                   	leave  
c0100987:	c3                   	ret    

c0100988 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100988:	f3 0f 1e fb          	endbr32 
c010098c:	55                   	push   %ebp
c010098d:	89 e5                	mov    %esp,%ebp
c010098f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100992:	c7 04 24 e2 73 10 c0 	movl   $0xc01073e2,(%esp)
c0100999:	e8 27 f9 ff ff       	call   c01002c5 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010099e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a5:	c0 
c01009a6:	c7 04 24 fb 73 10 c0 	movl   $0xc01073fb,(%esp)
c01009ad:	e8 13 f9 ff ff       	call   c01002c5 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b2:	c7 44 24 04 ce 72 10 	movl   $0xc01072ce,0x4(%esp)
c01009b9:	c0 
c01009ba:	c7 04 24 13 74 10 c0 	movl   $0xc0107413,(%esp)
c01009c1:	e8 ff f8 ff ff       	call   c01002c5 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009c6:	c7 44 24 04 00 f0 11 	movl   $0xc011f000,0x4(%esp)
c01009cd:	c0 
c01009ce:	c7 04 24 2b 74 10 c0 	movl   $0xc010742b,(%esp)
c01009d5:	e8 eb f8 ff ff       	call   c01002c5 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009da:	c7 44 24 04 20 00 12 	movl   $0xc0120020,0x4(%esp)
c01009e1:	c0 
c01009e2:	c7 04 24 43 74 10 c0 	movl   $0xc0107443,(%esp)
c01009e9:	e8 d7 f8 ff ff       	call   c01002c5 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009ee:	b8 20 00 12 c0       	mov    $0xc0120020,%eax
c01009f3:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009f8:	05 ff 03 00 00       	add    $0x3ff,%eax
c01009fd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a03:	85 c0                	test   %eax,%eax
c0100a05:	0f 48 c2             	cmovs  %edx,%eax
c0100a08:	c1 f8 0a             	sar    $0xa,%eax
c0100a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0f:	c7 04 24 5c 74 10 c0 	movl   $0xc010745c,(%esp)
c0100a16:	e8 aa f8 ff ff       	call   c01002c5 <cprintf>
}
c0100a1b:	90                   	nop
c0100a1c:	c9                   	leave  
c0100a1d:	c3                   	ret    

c0100a1e <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a1e:	f3 0f 1e fb          	endbr32 
c0100a22:	55                   	push   %ebp
c0100a23:	89 e5                	mov    %esp,%ebp
c0100a25:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a2b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a35:	89 04 24             	mov    %eax,(%esp)
c0100a38:	e8 21 fc ff ff       	call   c010065e <debuginfo_eip>
c0100a3d:	85 c0                	test   %eax,%eax
c0100a3f:	74 15                	je     c0100a56 <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a48:	c7 04 24 86 74 10 c0 	movl   $0xc0107486,(%esp)
c0100a4f:	e8 71 f8 ff ff       	call   c01002c5 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a54:	eb 6c                	jmp    c0100ac2 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a5d:	eb 1b                	jmp    c0100a7a <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100a5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a65:	01 d0                	add    %edx,%eax
c0100a67:	0f b6 10             	movzbl (%eax),%edx
c0100a6a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a73:	01 c8                	add    %ecx,%eax
c0100a75:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a77:	ff 45 f4             	incl   -0xc(%ebp)
c0100a7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a7d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a80:	7c dd                	jl     c0100a5f <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100a82:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8b:	01 d0                	add    %edx,%eax
c0100a8d:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a93:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a96:	89 d1                	mov    %edx,%ecx
c0100a98:	29 c1                	sub    %eax,%ecx
c0100a9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aaa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aae:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 a2 74 10 c0 	movl   $0xc01074a2,(%esp)
c0100abd:	e8 03 f8 ff ff       	call   c01002c5 <cprintf>
}
c0100ac2:	90                   	nop
c0100ac3:	c9                   	leave  
c0100ac4:	c3                   	ret    

c0100ac5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac5:	f3 0f 1e fb          	endbr32 
c0100ac9:	55                   	push   %ebp
c0100aca:	89 e5                	mov    %esp,%ebp
c0100acc:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100acf:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ad2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ad8:	c9                   	leave  
c0100ad9:	c3                   	ret    

c0100ada <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ada:	f3 0f 1e fb          	endbr32 
c0100ade:	55                   	push   %ebp
c0100adf:	89 e5                	mov    %esp,%ebp
c0100ae1:	53                   	push   %ebx
c0100ae2:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae5:	89 e8                	mov    %ebp,%eax
c0100ae7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp();
c0100aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
c0100af0:	e8 d0 ff ff ff       	call   c0100ac5 <read_eip>
c0100af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;   //这里有个细节问题，就是不能for int i，这里面的C标准似乎不允许
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
c0100af8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aff:	eb 7e                	jmp    c0100b7f <print_stackframe+0xa5>
	{
		cprintf("ebp:0x%08x eip:0x%08x\n",ebp,eip);
c0100b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b04:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b0f:	c7 04 24 b4 74 10 c0 	movl   $0xc01074b4,(%esp)
c0100b16:	e8 aa f7 ff ff       	call   c01002c5 <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
c0100b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1e:	83 c0 08             	add    $0x8,%eax
c0100b21:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));//依次打印调用函数的参数1 2 3 4
c0100b24:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b27:	83 c0 0c             	add    $0xc,%eax
c0100b2a:	8b 18                	mov    (%eax),%ebx
c0100b2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b2f:	83 c0 08             	add    $0x8,%eax
c0100b32:	8b 08                	mov    (%eax),%ecx
c0100b34:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b37:	83 c0 04             	add    $0x4,%eax
c0100b3a:	8b 10                	mov    (%eax),%edx
c0100b3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b3f:	8b 00                	mov    (%eax),%eax
c0100b41:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b45:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b49:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b51:	c7 04 24 cc 74 10 c0 	movl   $0xc01074cc,(%esp)
c0100b58:	e8 68 f7 ff ff       	call   c01002c5 <cprintf>
 
 
    //因为使用的是栈数据结构，因此可以直接根据ebp就能读取到各个栈帧的地址和值，ebp+4处为返回地址，
    //ebp+8处为第一个参数值（最后一个入栈的参数值，对应32位系统），ebp-4处为第一个局部变量，ebp处为上一层 ebp 值。

		print_debuginfo(eip-1);
c0100b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b60:	48                   	dec    %eax
c0100b61:	89 04 24             	mov    %eax,(%esp)
c0100b64:	e8 b5 fe ff ff       	call   c0100a1e <print_debuginfo>
		eip=((uint32_t *)ebp)[1];
c0100b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b6c:	83 c0 04             	add    $0x4,%eax
c0100b6f:	8b 00                	mov    (%eax),%eax
c0100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
c0100b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b77:	8b 00                	mov    (%eax),%eax
c0100b79:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
c0100b7c:	ff 45 ec             	incl   -0x14(%ebp)
c0100b7f:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b83:	7f 0a                	jg     c0100b8f <print_stackframe+0xb5>
c0100b85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b89:	0f 85 72 ff ff ff    	jne    c0100b01 <print_stackframe+0x27>
    }
}
c0100b8f:	90                   	nop
c0100b90:	83 c4 44             	add    $0x44,%esp
c0100b93:	5b                   	pop    %ebx
c0100b94:	5d                   	pop    %ebp
c0100b95:	c3                   	ret    

c0100b96 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b96:	f3 0f 1e fb          	endbr32 
c0100b9a:	55                   	push   %ebp
c0100b9b:	89 e5                	mov    %esp,%ebp
c0100b9d:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ba7:	eb 0c                	jmp    c0100bb5 <parse+0x1f>
            *buf ++ = '\0';
c0100ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bac:	8d 50 01             	lea    0x1(%eax),%edx
c0100baf:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bb2:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb8:	0f b6 00             	movzbl (%eax),%eax
c0100bbb:	84 c0                	test   %al,%al
c0100bbd:	74 1d                	je     c0100bdc <parse+0x46>
c0100bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc2:	0f b6 00             	movzbl (%eax),%eax
c0100bc5:	0f be c0             	movsbl %al,%eax
c0100bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bcc:	c7 04 24 70 75 10 c0 	movl   $0xc0107570,(%esp)
c0100bd3:	e8 10 5d 00 00       	call   c01068e8 <strchr>
c0100bd8:	85 c0                	test   %eax,%eax
c0100bda:	75 cd                	jne    c0100ba9 <parse+0x13>
        }
        if (*buf == '\0') {
c0100bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdf:	0f b6 00             	movzbl (%eax),%eax
c0100be2:	84 c0                	test   %al,%al
c0100be4:	74 65                	je     c0100c4b <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100be6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bea:	75 14                	jne    c0100c00 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bec:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bf3:	00 
c0100bf4:	c7 04 24 75 75 10 c0 	movl   $0xc0107575,(%esp)
c0100bfb:	e8 c5 f6 ff ff       	call   c01002c5 <cprintf>
        }
        argv[argc ++] = buf;
c0100c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c03:	8d 50 01             	lea    0x1(%eax),%edx
c0100c06:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c13:	01 c2                	add    %eax,%edx
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c1a:	eb 03                	jmp    c0100c1f <parse+0x89>
            buf ++;
c0100c1c:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c22:	0f b6 00             	movzbl (%eax),%eax
c0100c25:	84 c0                	test   %al,%al
c0100c27:	74 8c                	je     c0100bb5 <parse+0x1f>
c0100c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2c:	0f b6 00             	movzbl (%eax),%eax
c0100c2f:	0f be c0             	movsbl %al,%eax
c0100c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c36:	c7 04 24 70 75 10 c0 	movl   $0xc0107570,(%esp)
c0100c3d:	e8 a6 5c 00 00       	call   c01068e8 <strchr>
c0100c42:	85 c0                	test   %eax,%eax
c0100c44:	74 d6                	je     c0100c1c <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c46:	e9 6a ff ff ff       	jmp    c0100bb5 <parse+0x1f>
            break;
c0100c4b:	90                   	nop
        }
    }
    return argc;
c0100c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c4f:	c9                   	leave  
c0100c50:	c3                   	ret    

c0100c51 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c51:	f3 0f 1e fb          	endbr32 
c0100c55:	55                   	push   %ebp
c0100c56:	89 e5                	mov    %esp,%ebp
c0100c58:	53                   	push   %ebx
c0100c59:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c5c:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c66:	89 04 24             	mov    %eax,(%esp)
c0100c69:	e8 28 ff ff ff       	call   c0100b96 <parse>
c0100c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c75:	75 0a                	jne    c0100c81 <runcmd+0x30>
        return 0;
c0100c77:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c7c:	e9 83 00 00 00       	jmp    c0100d04 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c88:	eb 5a                	jmp    c0100ce4 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c8a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c90:	89 d0                	mov    %edx,%eax
c0100c92:	01 c0                	add    %eax,%eax
c0100c94:	01 d0                	add    %edx,%eax
c0100c96:	c1 e0 02             	shl    $0x2,%eax
c0100c99:	05 00 c0 11 c0       	add    $0xc011c000,%eax
c0100c9e:	8b 00                	mov    (%eax),%eax
c0100ca0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ca4:	89 04 24             	mov    %eax,(%esp)
c0100ca7:	e8 98 5b 00 00       	call   c0106844 <strcmp>
c0100cac:	85 c0                	test   %eax,%eax
c0100cae:	75 31                	jne    c0100ce1 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cb3:	89 d0                	mov    %edx,%eax
c0100cb5:	01 c0                	add    %eax,%eax
c0100cb7:	01 d0                	add    %edx,%eax
c0100cb9:	c1 e0 02             	shl    $0x2,%eax
c0100cbc:	05 08 c0 11 c0       	add    $0xc011c008,%eax
c0100cc1:	8b 10                	mov    (%eax),%edx
c0100cc3:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100cc6:	83 c0 04             	add    $0x4,%eax
c0100cc9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100ccc:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100cd2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cda:	89 1c 24             	mov    %ebx,(%esp)
c0100cdd:	ff d2                	call   *%edx
c0100cdf:	eb 23                	jmp    c0100d04 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ce1:	ff 45 f4             	incl   -0xc(%ebp)
c0100ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ce7:	83 f8 02             	cmp    $0x2,%eax
c0100cea:	76 9e                	jbe    c0100c8a <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cec:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf3:	c7 04 24 93 75 10 c0 	movl   $0xc0107593,(%esp)
c0100cfa:	e8 c6 f5 ff ff       	call   c01002c5 <cprintf>
    return 0;
c0100cff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d04:	83 c4 64             	add    $0x64,%esp
c0100d07:	5b                   	pop    %ebx
c0100d08:	5d                   	pop    %ebp
c0100d09:	c3                   	ret    

c0100d0a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d0a:	f3 0f 1e fb          	endbr32 
c0100d0e:	55                   	push   %ebp
c0100d0f:	89 e5                	mov    %esp,%ebp
c0100d11:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d14:	c7 04 24 ac 75 10 c0 	movl   $0xc01075ac,(%esp)
c0100d1b:	e8 a5 f5 ff ff       	call   c01002c5 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d20:	c7 04 24 d4 75 10 c0 	movl   $0xc01075d4,(%esp)
c0100d27:	e8 99 f5 ff ff       	call   c01002c5 <cprintf>

    if (tf != NULL) {
c0100d2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d30:	74 0b                	je     c0100d3d <kmonitor+0x33>
        print_trapframe(tf);
c0100d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d35:	89 04 24             	mov    %eax,(%esp)
c0100d38:	e8 db 0e 00 00       	call   c0101c18 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d3d:	c7 04 24 f9 75 10 c0 	movl   $0xc01075f9,(%esp)
c0100d44:	e8 2f f6 ff ff       	call   c0100378 <readline>
c0100d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d50:	74 eb                	je     c0100d3d <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100d52:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5c:	89 04 24             	mov    %eax,(%esp)
c0100d5f:	e8 ed fe ff ff       	call   c0100c51 <runcmd>
c0100d64:	85 c0                	test   %eax,%eax
c0100d66:	78 02                	js     c0100d6a <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100d68:	eb d3                	jmp    c0100d3d <kmonitor+0x33>
                break;
c0100d6a:	90                   	nop
            }
        }
    }
}
c0100d6b:	90                   	nop
c0100d6c:	c9                   	leave  
c0100d6d:	c3                   	ret    

c0100d6e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d6e:	f3 0f 1e fb          	endbr32 
c0100d72:	55                   	push   %ebp
c0100d73:	89 e5                	mov    %esp,%ebp
c0100d75:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d7f:	eb 3d                	jmp    c0100dbe <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d84:	89 d0                	mov    %edx,%eax
c0100d86:	01 c0                	add    %eax,%eax
c0100d88:	01 d0                	add    %edx,%eax
c0100d8a:	c1 e0 02             	shl    $0x2,%eax
c0100d8d:	05 04 c0 11 c0       	add    $0xc011c004,%eax
c0100d92:	8b 08                	mov    (%eax),%ecx
c0100d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d97:	89 d0                	mov    %edx,%eax
c0100d99:	01 c0                	add    %eax,%eax
c0100d9b:	01 d0                	add    %edx,%eax
c0100d9d:	c1 e0 02             	shl    $0x2,%eax
c0100da0:	05 00 c0 11 c0       	add    $0xc011c000,%eax
c0100da5:	8b 00                	mov    (%eax),%eax
c0100da7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100dab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100daf:	c7 04 24 fd 75 10 c0 	movl   $0xc01075fd,(%esp)
c0100db6:	e8 0a f5 ff ff       	call   c01002c5 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100dbb:	ff 45 f4             	incl   -0xc(%ebp)
c0100dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dc1:	83 f8 02             	cmp    $0x2,%eax
c0100dc4:	76 bb                	jbe    c0100d81 <mon_help+0x13>
    }
    return 0;
c0100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dcb:	c9                   	leave  
c0100dcc:	c3                   	ret    

c0100dcd <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dcd:	f3 0f 1e fb          	endbr32 
c0100dd1:	55                   	push   %ebp
c0100dd2:	89 e5                	mov    %esp,%ebp
c0100dd4:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dd7:	e8 ac fb ff ff       	call   c0100988 <print_kerninfo>
    return 0;
c0100ddc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100de1:	c9                   	leave  
c0100de2:	c3                   	ret    

c0100de3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100de3:	f3 0f 1e fb          	endbr32 
c0100de7:	55                   	push   %ebp
c0100de8:	89 e5                	mov    %esp,%ebp
c0100dea:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ded:	e8 e8 fc ff ff       	call   c0100ada <print_stackframe>
    return 0;
c0100df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df7:	c9                   	leave  
c0100df8:	c3                   	ret    

c0100df9 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100df9:	f3 0f 1e fb          	endbr32 
c0100dfd:	55                   	push   %ebp
c0100dfe:	89 e5                	mov    %esp,%ebp
c0100e00:	83 ec 28             	sub    $0x28,%esp
c0100e03:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e09:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e11:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e15:	ee                   	out    %al,(%dx)
}
c0100e16:	90                   	nop
c0100e17:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e1d:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e21:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e25:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e29:	ee                   	out    %al,(%dx)
}
c0100e2a:	90                   	nop
c0100e2b:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e31:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e35:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e39:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e3d:	ee                   	out    %al,(%dx)
}
c0100e3e:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e3f:	c7 05 0c ff 11 c0 00 	movl   $0x0,0xc011ff0c
c0100e46:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e49:	c7 04 24 06 76 10 c0 	movl   $0xc0107606,(%esp)
c0100e50:	e8 70 f4 ff ff       	call   c01002c5 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e5c:	e8 95 09 00 00       	call   c01017f6 <pic_enable>
}
c0100e61:	90                   	nop
c0100e62:	c9                   	leave  
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
c0100e7b:	e8 05 0b 00 00       	call   c0101985 <intr_disable>
        return 1;
c0100e80:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e85:	eb 05                	jmp    c0100e8c <__intr_save+0x28>
    }
    return 0;
c0100e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e8c:	c9                   	leave  
c0100e8d:	c3                   	ret    

c0100e8e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e8e:	55                   	push   %ebp
c0100e8f:	89 e5                	mov    %esp,%ebp
c0100e91:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e98:	74 05                	je     c0100e9f <__intr_restore+0x11>
        intr_enable();
c0100e9a:	e8 da 0a 00 00       	call   c0101979 <intr_enable>
    }
}
c0100e9f:	90                   	nop
c0100ea0:	c9                   	leave  
c0100ea1:	c3                   	ret    

c0100ea2 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100ea2:	f3 0f 1e fb          	endbr32 
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
c0100eed:	c9                   	leave  
c0100eee:	c3                   	ret    

c0100eef <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100eef:	f3 0f 1e fb          	endbr32 
c0100ef3:	55                   	push   %ebp
c0100ef4:	89 e5                	mov    %esp,%ebp
c0100ef6:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ef9:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f00:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f03:	0f b7 00             	movzwl (%eax),%eax
c0100f06:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f0d:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f15:	0f b7 00             	movzwl (%eax),%eax
c0100f18:	0f b7 c0             	movzwl %ax,%eax
c0100f1b:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f20:	74 12                	je     c0100f34 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f22:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f29:	66 c7 05 46 f4 11 c0 	movw   $0x3b4,0xc011f446
c0100f30:	b4 03 
c0100f32:	eb 13                	jmp    c0100f47 <cga_init+0x58>
    } else {
        *cp = was;
c0100f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f37:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f3b:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f3e:	66 c7 05 46 f4 11 c0 	movw   $0x3d4,0xc011f446
c0100f45:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f47:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c0100f4e:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f52:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f56:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f5a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f5e:	ee                   	out    %al,(%dx)
}
c0100f5f:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f60:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c0100f67:	40                   	inc    %eax
c0100f68:	0f b7 c0             	movzwl %ax,%eax
c0100f6b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f6f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f73:	89 c2                	mov    %eax,%edx
c0100f75:	ec                   	in     (%dx),%al
c0100f76:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f79:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f7d:	0f b6 c0             	movzbl %al,%eax
c0100f80:	c1 e0 08             	shl    $0x8,%eax
c0100f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f86:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c0100f8d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f91:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f95:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f99:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f9d:	ee                   	out    %al,(%dx)
}
c0100f9e:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f9f:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c0100fa6:	40                   	inc    %eax
c0100fa7:	0f b7 c0             	movzwl %ax,%eax
c0100faa:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fae:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fb2:	89 c2                	mov    %eax,%edx
c0100fb4:	ec                   	in     (%dx),%al
c0100fb5:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fb8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fbc:	0f b6 c0             	movzbl %al,%eax
c0100fbf:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc5:	a3 40 f4 11 c0       	mov    %eax,0xc011f440
    crt_pos = pos;
c0100fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fcd:	0f b7 c0             	movzwl %ax,%eax
c0100fd0:	66 a3 44 f4 11 c0    	mov    %ax,0xc011f444
}
c0100fd6:	90                   	nop
c0100fd7:	c9                   	leave  
c0100fd8:	c3                   	ret    

c0100fd9 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fd9:	f3 0f 1e fb          	endbr32 
c0100fdd:	55                   	push   %ebp
c0100fde:	89 e5                	mov    %esp,%ebp
c0100fe0:	83 ec 48             	sub    $0x48,%esp
c0100fe3:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fe9:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fed:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100ff1:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100ff5:	ee                   	out    %al,(%dx)
}
c0100ff6:	90                   	nop
c0100ff7:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100ffd:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101001:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101005:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101009:	ee                   	out    %al,(%dx)
}
c010100a:	90                   	nop
c010100b:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101011:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101015:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101019:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010101d:	ee                   	out    %al,(%dx)
}
c010101e:	90                   	nop
c010101f:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101025:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101029:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010102d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101031:	ee                   	out    %al,(%dx)
}
c0101032:	90                   	nop
c0101033:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101039:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010103d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101041:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101045:	ee                   	out    %al,(%dx)
}
c0101046:	90                   	nop
c0101047:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010104d:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101051:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101055:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101059:	ee                   	out    %al,(%dx)
}
c010105a:	90                   	nop
c010105b:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101061:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101065:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101069:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010106d:	ee                   	out    %al,(%dx)
}
c010106e:	90                   	nop
c010106f:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101075:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101079:	89 c2                	mov    %eax,%edx
c010107b:	ec                   	in     (%dx),%al
c010107c:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010107f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101083:	3c ff                	cmp    $0xff,%al
c0101085:	0f 95 c0             	setne  %al
c0101088:	0f b6 c0             	movzbl %al,%eax
c010108b:	a3 48 f4 11 c0       	mov    %eax,0xc011f448
c0101090:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101096:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010109a:	89 c2                	mov    %eax,%edx
c010109c:	ec                   	in     (%dx),%al
c010109d:	88 45 f1             	mov    %al,-0xf(%ebp)
c01010a0:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01010a6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010aa:	89 c2                	mov    %eax,%edx
c01010ac:	ec                   	in     (%dx),%al
c01010ad:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01010b0:	a1 48 f4 11 c0       	mov    0xc011f448,%eax
c01010b5:	85 c0                	test   %eax,%eax
c01010b7:	74 0c                	je     c01010c5 <serial_init+0xec>
        pic_enable(IRQ_COM1);
c01010b9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010c0:	e8 31 07 00 00       	call   c01017f6 <pic_enable>
    }
}
c01010c5:	90                   	nop
c01010c6:	c9                   	leave  
c01010c7:	c3                   	ret    

c01010c8 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010c8:	f3 0f 1e fb          	endbr32 
c01010cc:	55                   	push   %ebp
c01010cd:	89 e5                	mov    %esp,%ebp
c01010cf:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010d9:	eb 08                	jmp    c01010e3 <lpt_putc_sub+0x1b>
        delay();
c01010db:	e8 c2 fd ff ff       	call   c0100ea2 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010e0:	ff 45 fc             	incl   -0x4(%ebp)
c01010e3:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010ed:	89 c2                	mov    %eax,%edx
c01010ef:	ec                   	in     (%dx),%al
c01010f0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010f3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010f7:	84 c0                	test   %al,%al
c01010f9:	78 09                	js     c0101104 <lpt_putc_sub+0x3c>
c01010fb:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101102:	7e d7                	jle    c01010db <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c0101104:	8b 45 08             	mov    0x8(%ebp),%eax
c0101107:	0f b6 c0             	movzbl %al,%eax
c010110a:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101110:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101113:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101117:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010111b:	ee                   	out    %al,(%dx)
}
c010111c:	90                   	nop
c010111d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101123:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101127:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010112b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010112f:	ee                   	out    %al,(%dx)
}
c0101130:	90                   	nop
c0101131:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101137:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010113b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010113f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101143:	ee                   	out    %al,(%dx)
}
c0101144:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101145:	90                   	nop
c0101146:	c9                   	leave  
c0101147:	c3                   	ret    

c0101148 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101148:	f3 0f 1e fb          	endbr32 
c010114c:	55                   	push   %ebp
c010114d:	89 e5                	mov    %esp,%ebp
c010114f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101152:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101156:	74 0d                	je     c0101165 <lpt_putc+0x1d>
        lpt_putc_sub(c);
c0101158:	8b 45 08             	mov    0x8(%ebp),%eax
c010115b:	89 04 24             	mov    %eax,(%esp)
c010115e:	e8 65 ff ff ff       	call   c01010c8 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101163:	eb 24                	jmp    c0101189 <lpt_putc+0x41>
        lpt_putc_sub('\b');
c0101165:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010116c:	e8 57 ff ff ff       	call   c01010c8 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101171:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101178:	e8 4b ff ff ff       	call   c01010c8 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010117d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101184:	e8 3f ff ff ff       	call   c01010c8 <lpt_putc_sub>
}
c0101189:	90                   	nop
c010118a:	c9                   	leave  
c010118b:	c3                   	ret    

c010118c <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010118c:	f3 0f 1e fb          	endbr32 
c0101190:	55                   	push   %ebp
c0101191:	89 e5                	mov    %esp,%ebp
c0101193:	53                   	push   %ebx
c0101194:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101197:	8b 45 08             	mov    0x8(%ebp),%eax
c010119a:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010119f:	85 c0                	test   %eax,%eax
c01011a1:	75 07                	jne    c01011aa <cga_putc+0x1e>
        c |= 0x0700;
c01011a3:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01011aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ad:	0f b6 c0             	movzbl %al,%eax
c01011b0:	83 f8 0d             	cmp    $0xd,%eax
c01011b3:	74 72                	je     c0101227 <cga_putc+0x9b>
c01011b5:	83 f8 0d             	cmp    $0xd,%eax
c01011b8:	0f 8f a3 00 00 00    	jg     c0101261 <cga_putc+0xd5>
c01011be:	83 f8 08             	cmp    $0x8,%eax
c01011c1:	74 0a                	je     c01011cd <cga_putc+0x41>
c01011c3:	83 f8 0a             	cmp    $0xa,%eax
c01011c6:	74 4c                	je     c0101214 <cga_putc+0x88>
c01011c8:	e9 94 00 00 00       	jmp    c0101261 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c01011cd:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c01011d4:	85 c0                	test   %eax,%eax
c01011d6:	0f 84 af 00 00 00    	je     c010128b <cga_putc+0xff>
            crt_pos --;
c01011dc:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c01011e3:	48                   	dec    %eax
c01011e4:	0f b7 c0             	movzwl %ax,%eax
c01011e7:	66 a3 44 f4 11 c0    	mov    %ax,0xc011f444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f0:	98                   	cwtl   
c01011f1:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011f6:	98                   	cwtl   
c01011f7:	83 c8 20             	or     $0x20,%eax
c01011fa:	98                   	cwtl   
c01011fb:	8b 15 40 f4 11 c0    	mov    0xc011f440,%edx
c0101201:	0f b7 0d 44 f4 11 c0 	movzwl 0xc011f444,%ecx
c0101208:	01 c9                	add    %ecx,%ecx
c010120a:	01 ca                	add    %ecx,%edx
c010120c:	0f b7 c0             	movzwl %ax,%eax
c010120f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101212:	eb 77                	jmp    c010128b <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c0101214:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c010121b:	83 c0 50             	add    $0x50,%eax
c010121e:	0f b7 c0             	movzwl %ax,%eax
c0101221:	66 a3 44 f4 11 c0    	mov    %ax,0xc011f444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101227:	0f b7 1d 44 f4 11 c0 	movzwl 0xc011f444,%ebx
c010122e:	0f b7 0d 44 f4 11 c0 	movzwl 0xc011f444,%ecx
c0101235:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010123a:	89 c8                	mov    %ecx,%eax
c010123c:	f7 e2                	mul    %edx
c010123e:	c1 ea 06             	shr    $0x6,%edx
c0101241:	89 d0                	mov    %edx,%eax
c0101243:	c1 e0 02             	shl    $0x2,%eax
c0101246:	01 d0                	add    %edx,%eax
c0101248:	c1 e0 04             	shl    $0x4,%eax
c010124b:	29 c1                	sub    %eax,%ecx
c010124d:	89 c8                	mov    %ecx,%eax
c010124f:	0f b7 c0             	movzwl %ax,%eax
c0101252:	29 c3                	sub    %eax,%ebx
c0101254:	89 d8                	mov    %ebx,%eax
c0101256:	0f b7 c0             	movzwl %ax,%eax
c0101259:	66 a3 44 f4 11 c0    	mov    %ax,0xc011f444
        break;
c010125f:	eb 2b                	jmp    c010128c <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101261:	8b 0d 40 f4 11 c0    	mov    0xc011f440,%ecx
c0101267:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c010126e:	8d 50 01             	lea    0x1(%eax),%edx
c0101271:	0f b7 d2             	movzwl %dx,%edx
c0101274:	66 89 15 44 f4 11 c0 	mov    %dx,0xc011f444
c010127b:	01 c0                	add    %eax,%eax
c010127d:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101280:	8b 45 08             	mov    0x8(%ebp),%eax
c0101283:	0f b7 c0             	movzwl %ax,%eax
c0101286:	66 89 02             	mov    %ax,(%edx)
        break;
c0101289:	eb 01                	jmp    c010128c <cga_putc+0x100>
        break;
c010128b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010128c:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c0101293:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101298:	76 5d                	jbe    c01012f7 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010129a:	a1 40 f4 11 c0       	mov    0xc011f440,%eax
c010129f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012a5:	a1 40 f4 11 c0       	mov    0xc011f440,%eax
c01012aa:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012b1:	00 
c01012b2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012b6:	89 04 24             	mov    %eax,(%esp)
c01012b9:	e8 2f 58 00 00       	call   c0106aed <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012be:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012c5:	eb 14                	jmp    c01012db <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c01012c7:	a1 40 f4 11 c0       	mov    0xc011f440,%eax
c01012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012cf:	01 d2                	add    %edx,%edx
c01012d1:	01 d0                	add    %edx,%eax
c01012d3:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012d8:	ff 45 f4             	incl   -0xc(%ebp)
c01012db:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012e2:	7e e3                	jle    c01012c7 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c01012e4:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c01012eb:	83 e8 50             	sub    $0x50,%eax
c01012ee:	0f b7 c0             	movzwl %ax,%eax
c01012f1:	66 a3 44 f4 11 c0    	mov    %ax,0xc011f444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012f7:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c01012fe:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101302:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101306:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010130a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010130e:	ee                   	out    %al,(%dx)
}
c010130f:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101310:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c0101317:	c1 e8 08             	shr    $0x8,%eax
c010131a:	0f b7 c0             	movzwl %ax,%eax
c010131d:	0f b6 c0             	movzbl %al,%eax
c0101320:	0f b7 15 46 f4 11 c0 	movzwl 0xc011f446,%edx
c0101327:	42                   	inc    %edx
c0101328:	0f b7 d2             	movzwl %dx,%edx
c010132b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010132f:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101332:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101336:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010133a:	ee                   	out    %al,(%dx)
}
c010133b:	90                   	nop
    outb(addr_6845, 15);
c010133c:	0f b7 05 46 f4 11 c0 	movzwl 0xc011f446,%eax
c0101343:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101347:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010134b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010134f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101353:	ee                   	out    %al,(%dx)
}
c0101354:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101355:	0f b7 05 44 f4 11 c0 	movzwl 0xc011f444,%eax
c010135c:	0f b6 c0             	movzbl %al,%eax
c010135f:	0f b7 15 46 f4 11 c0 	movzwl 0xc011f446,%edx
c0101366:	42                   	inc    %edx
c0101367:	0f b7 d2             	movzwl %dx,%edx
c010136a:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010136e:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101371:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101375:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101379:	ee                   	out    %al,(%dx)
}
c010137a:	90                   	nop
}
c010137b:	90                   	nop
c010137c:	83 c4 34             	add    $0x34,%esp
c010137f:	5b                   	pop    %ebx
c0101380:	5d                   	pop    %ebp
c0101381:	c3                   	ret    

c0101382 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101382:	f3 0f 1e fb          	endbr32 
c0101386:	55                   	push   %ebp
c0101387:	89 e5                	mov    %esp,%ebp
c0101389:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010138c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101393:	eb 08                	jmp    c010139d <serial_putc_sub+0x1b>
        delay();
c0101395:	e8 08 fb ff ff       	call   c0100ea2 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010139a:	ff 45 fc             	incl   -0x4(%ebp)
c010139d:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013a3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013a7:	89 c2                	mov    %eax,%edx
c01013a9:	ec                   	in     (%dx),%al
c01013aa:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013ad:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013b1:	0f b6 c0             	movzbl %al,%eax
c01013b4:	83 e0 20             	and    $0x20,%eax
c01013b7:	85 c0                	test   %eax,%eax
c01013b9:	75 09                	jne    c01013c4 <serial_putc_sub+0x42>
c01013bb:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013c2:	7e d1                	jle    c0101395 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c01013c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013c7:	0f b6 c0             	movzbl %al,%eax
c01013ca:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013d0:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013d3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013d7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013db:	ee                   	out    %al,(%dx)
}
c01013dc:	90                   	nop
}
c01013dd:	90                   	nop
c01013de:	c9                   	leave  
c01013df:	c3                   	ret    

c01013e0 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013e0:	f3 0f 1e fb          	endbr32 
c01013e4:	55                   	push   %ebp
c01013e5:	89 e5                	mov    %esp,%ebp
c01013e7:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013ea:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013ee:	74 0d                	je     c01013fd <serial_putc+0x1d>
        serial_putc_sub(c);
c01013f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01013f3:	89 04 24             	mov    %eax,(%esp)
c01013f6:	e8 87 ff ff ff       	call   c0101382 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013fb:	eb 24                	jmp    c0101421 <serial_putc+0x41>
        serial_putc_sub('\b');
c01013fd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101404:	e8 79 ff ff ff       	call   c0101382 <serial_putc_sub>
        serial_putc_sub(' ');
c0101409:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101410:	e8 6d ff ff ff       	call   c0101382 <serial_putc_sub>
        serial_putc_sub('\b');
c0101415:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010141c:	e8 61 ff ff ff       	call   c0101382 <serial_putc_sub>
}
c0101421:	90                   	nop
c0101422:	c9                   	leave  
c0101423:	c3                   	ret    

c0101424 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101424:	f3 0f 1e fb          	endbr32 
c0101428:	55                   	push   %ebp
c0101429:	89 e5                	mov    %esp,%ebp
c010142b:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010142e:	eb 33                	jmp    c0101463 <cons_intr+0x3f>
        if (c != 0) {
c0101430:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101434:	74 2d                	je     c0101463 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0101436:	a1 64 f6 11 c0       	mov    0xc011f664,%eax
c010143b:	8d 50 01             	lea    0x1(%eax),%edx
c010143e:	89 15 64 f6 11 c0    	mov    %edx,0xc011f664
c0101444:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101447:	88 90 60 f4 11 c0    	mov    %dl,-0x3fee0ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010144d:	a1 64 f6 11 c0       	mov    0xc011f664,%eax
c0101452:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101457:	75 0a                	jne    c0101463 <cons_intr+0x3f>
                cons.wpos = 0;
c0101459:	c7 05 64 f6 11 c0 00 	movl   $0x0,0xc011f664
c0101460:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101463:	8b 45 08             	mov    0x8(%ebp),%eax
c0101466:	ff d0                	call   *%eax
c0101468:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010146b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c010146f:	75 bf                	jne    c0101430 <cons_intr+0xc>
            }
        }
    }
}
c0101471:	90                   	nop
c0101472:	90                   	nop
c0101473:	c9                   	leave  
c0101474:	c3                   	ret    

c0101475 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101475:	f3 0f 1e fb          	endbr32 
c0101479:	55                   	push   %ebp
c010147a:	89 e5                	mov    %esp,%ebp
c010147c:	83 ec 10             	sub    $0x10,%esp
c010147f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101485:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101489:	89 c2                	mov    %eax,%edx
c010148b:	ec                   	in     (%dx),%al
c010148c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010148f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101493:	0f b6 c0             	movzbl %al,%eax
c0101496:	83 e0 01             	and    $0x1,%eax
c0101499:	85 c0                	test   %eax,%eax
c010149b:	75 07                	jne    c01014a4 <serial_proc_data+0x2f>
        return -1;
c010149d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014a2:	eb 2a                	jmp    c01014ce <serial_proc_data+0x59>
c01014a4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014aa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014ae:	89 c2                	mov    %eax,%edx
c01014b0:	ec                   	in     (%dx),%al
c01014b1:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014b4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014b8:	0f b6 c0             	movzbl %al,%eax
c01014bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014be:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014c2:	75 07                	jne    c01014cb <serial_proc_data+0x56>
        c = '\b';
c01014c4:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014ce:	c9                   	leave  
c01014cf:	c3                   	ret    

c01014d0 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014d0:	f3 0f 1e fb          	endbr32 
c01014d4:	55                   	push   %ebp
c01014d5:	89 e5                	mov    %esp,%ebp
c01014d7:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014da:	a1 48 f4 11 c0       	mov    0xc011f448,%eax
c01014df:	85 c0                	test   %eax,%eax
c01014e1:	74 0c                	je     c01014ef <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c01014e3:	c7 04 24 75 14 10 c0 	movl   $0xc0101475,(%esp)
c01014ea:	e8 35 ff ff ff       	call   c0101424 <cons_intr>
    }
}
c01014ef:	90                   	nop
c01014f0:	c9                   	leave  
c01014f1:	c3                   	ret    

c01014f2 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014f2:	f3 0f 1e fb          	endbr32 
c01014f6:	55                   	push   %ebp
c01014f7:	89 e5                	mov    %esp,%ebp
c01014f9:	83 ec 38             	sub    $0x38,%esp
c01014fc:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101502:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101505:	89 c2                	mov    %eax,%edx
c0101507:	ec                   	in     (%dx),%al
c0101508:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010150b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010150f:	0f b6 c0             	movzbl %al,%eax
c0101512:	83 e0 01             	and    $0x1,%eax
c0101515:	85 c0                	test   %eax,%eax
c0101517:	75 0a                	jne    c0101523 <kbd_proc_data+0x31>
        return -1;
c0101519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010151e:	e9 56 01 00 00       	jmp    c0101679 <kbd_proc_data+0x187>
c0101523:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101529:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010152c:	89 c2                	mov    %eax,%edx
c010152e:	ec                   	in     (%dx),%al
c010152f:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101532:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101536:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101539:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010153d:	75 17                	jne    c0101556 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c010153f:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c0101544:	83 c8 40             	or     $0x40,%eax
c0101547:	a3 68 f6 11 c0       	mov    %eax,0xc011f668
        return 0;
c010154c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101551:	e9 23 01 00 00       	jmp    c0101679 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101556:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155a:	84 c0                	test   %al,%al
c010155c:	79 45                	jns    c01015a3 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010155e:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c0101563:	83 e0 40             	and    $0x40,%eax
c0101566:	85 c0                	test   %eax,%eax
c0101568:	75 08                	jne    c0101572 <kbd_proc_data+0x80>
c010156a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010156e:	24 7f                	and    $0x7f,%al
c0101570:	eb 04                	jmp    c0101576 <kbd_proc_data+0x84>
c0101572:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101576:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101579:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010157d:	0f b6 80 40 c0 11 c0 	movzbl -0x3fee3fc0(%eax),%eax
c0101584:	0c 40                	or     $0x40,%al
c0101586:	0f b6 c0             	movzbl %al,%eax
c0101589:	f7 d0                	not    %eax
c010158b:	89 c2                	mov    %eax,%edx
c010158d:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c0101592:	21 d0                	and    %edx,%eax
c0101594:	a3 68 f6 11 c0       	mov    %eax,0xc011f668
        return 0;
c0101599:	b8 00 00 00 00       	mov    $0x0,%eax
c010159e:	e9 d6 00 00 00       	jmp    c0101679 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015a3:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c01015a8:	83 e0 40             	and    $0x40,%eax
c01015ab:	85 c0                	test   %eax,%eax
c01015ad:	74 11                	je     c01015c0 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015af:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015b3:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c01015b8:	83 e0 bf             	and    $0xffffffbf,%eax
c01015bb:	a3 68 f6 11 c0       	mov    %eax,0xc011f668
    }

    shift |= shiftcode[data];
c01015c0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015c4:	0f b6 80 40 c0 11 c0 	movzbl -0x3fee3fc0(%eax),%eax
c01015cb:	0f b6 d0             	movzbl %al,%edx
c01015ce:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c01015d3:	09 d0                	or     %edx,%eax
c01015d5:	a3 68 f6 11 c0       	mov    %eax,0xc011f668
    shift ^= togglecode[data];
c01015da:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015de:	0f b6 80 40 c1 11 c0 	movzbl -0x3fee3ec0(%eax),%eax
c01015e5:	0f b6 d0             	movzbl %al,%edx
c01015e8:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c01015ed:	31 d0                	xor    %edx,%eax
c01015ef:	a3 68 f6 11 c0       	mov    %eax,0xc011f668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015f4:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c01015f9:	83 e0 03             	and    $0x3,%eax
c01015fc:	8b 14 85 40 c5 11 c0 	mov    -0x3fee3ac0(,%eax,4),%edx
c0101603:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101607:	01 d0                	add    %edx,%eax
c0101609:	0f b6 00             	movzbl (%eax),%eax
c010160c:	0f b6 c0             	movzbl %al,%eax
c010160f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101612:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c0101617:	83 e0 08             	and    $0x8,%eax
c010161a:	85 c0                	test   %eax,%eax
c010161c:	74 22                	je     c0101640 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010161e:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101622:	7e 0c                	jle    c0101630 <kbd_proc_data+0x13e>
c0101624:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101628:	7f 06                	jg     c0101630 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010162a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010162e:	eb 10                	jmp    c0101640 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101630:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101634:	7e 0a                	jle    c0101640 <kbd_proc_data+0x14e>
c0101636:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010163a:	7f 04                	jg     c0101640 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010163c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101640:	a1 68 f6 11 c0       	mov    0xc011f668,%eax
c0101645:	f7 d0                	not    %eax
c0101647:	83 e0 06             	and    $0x6,%eax
c010164a:	85 c0                	test   %eax,%eax
c010164c:	75 28                	jne    c0101676 <kbd_proc_data+0x184>
c010164e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101655:	75 1f                	jne    c0101676 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101657:	c7 04 24 21 76 10 c0 	movl   $0xc0107621,(%esp)
c010165e:	e8 62 ec ff ff       	call   c01002c5 <cprintf>
c0101663:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101669:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010166d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101671:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101674:	ee                   	out    %al,(%dx)
}
c0101675:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101676:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101679:	c9                   	leave  
c010167a:	c3                   	ret    

c010167b <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010167b:	f3 0f 1e fb          	endbr32 
c010167f:	55                   	push   %ebp
c0101680:	89 e5                	mov    %esp,%ebp
c0101682:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101685:	c7 04 24 f2 14 10 c0 	movl   $0xc01014f2,(%esp)
c010168c:	e8 93 fd ff ff       	call   c0101424 <cons_intr>
}
c0101691:	90                   	nop
c0101692:	c9                   	leave  
c0101693:	c3                   	ret    

c0101694 <kbd_init>:

static void
kbd_init(void) {
c0101694:	f3 0f 1e fb          	endbr32 
c0101698:	55                   	push   %ebp
c0101699:	89 e5                	mov    %esp,%ebp
c010169b:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010169e:	e8 d8 ff ff ff       	call   c010167b <kbd_intr>
    pic_enable(IRQ_KBD);
c01016a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016aa:	e8 47 01 00 00       	call   c01017f6 <pic_enable>
}
c01016af:	90                   	nop
c01016b0:	c9                   	leave  
c01016b1:	c3                   	ret    

c01016b2 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016b2:	f3 0f 1e fb          	endbr32 
c01016b6:	55                   	push   %ebp
c01016b7:	89 e5                	mov    %esp,%ebp
c01016b9:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016bc:	e8 2e f8 ff ff       	call   c0100eef <cga_init>
    serial_init();
c01016c1:	e8 13 f9 ff ff       	call   c0100fd9 <serial_init>
    kbd_init();
c01016c6:	e8 c9 ff ff ff       	call   c0101694 <kbd_init>
    if (!serial_exists) {
c01016cb:	a1 48 f4 11 c0       	mov    0xc011f448,%eax
c01016d0:	85 c0                	test   %eax,%eax
c01016d2:	75 0c                	jne    c01016e0 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01016d4:	c7 04 24 2d 76 10 c0 	movl   $0xc010762d,(%esp)
c01016db:	e8 e5 eb ff ff       	call   c01002c5 <cprintf>
    }
}
c01016e0:	90                   	nop
c01016e1:	c9                   	leave  
c01016e2:	c3                   	ret    

c01016e3 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016e3:	f3 0f 1e fb          	endbr32 
c01016e7:	55                   	push   %ebp
c01016e8:	89 e5                	mov    %esp,%ebp
c01016ea:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016ed:	e8 72 f7 ff ff       	call   c0100e64 <__intr_save>
c01016f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016f8:	89 04 24             	mov    %eax,(%esp)
c01016fb:	e8 48 fa ff ff       	call   c0101148 <lpt_putc>
        cga_putc(c);
c0101700:	8b 45 08             	mov    0x8(%ebp),%eax
c0101703:	89 04 24             	mov    %eax,(%esp)
c0101706:	e8 81 fa ff ff       	call   c010118c <cga_putc>
        serial_putc(c);
c010170b:	8b 45 08             	mov    0x8(%ebp),%eax
c010170e:	89 04 24             	mov    %eax,(%esp)
c0101711:	e8 ca fc ff ff       	call   c01013e0 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101719:	89 04 24             	mov    %eax,(%esp)
c010171c:	e8 6d f7 ff ff       	call   c0100e8e <__intr_restore>
}
c0101721:	90                   	nop
c0101722:	c9                   	leave  
c0101723:	c3                   	ret    

c0101724 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101724:	f3 0f 1e fb          	endbr32 
c0101728:	55                   	push   %ebp
c0101729:	89 e5                	mov    %esp,%ebp
c010172b:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010172e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101735:	e8 2a f7 ff ff       	call   c0100e64 <__intr_save>
c010173a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010173d:	e8 8e fd ff ff       	call   c01014d0 <serial_intr>
        kbd_intr();
c0101742:	e8 34 ff ff ff       	call   c010167b <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101747:	8b 15 60 f6 11 c0    	mov    0xc011f660,%edx
c010174d:	a1 64 f6 11 c0       	mov    0xc011f664,%eax
c0101752:	39 c2                	cmp    %eax,%edx
c0101754:	74 31                	je     c0101787 <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c0101756:	a1 60 f6 11 c0       	mov    0xc011f660,%eax
c010175b:	8d 50 01             	lea    0x1(%eax),%edx
c010175e:	89 15 60 f6 11 c0    	mov    %edx,0xc011f660
c0101764:	0f b6 80 60 f4 11 c0 	movzbl -0x3fee0ba0(%eax),%eax
c010176b:	0f b6 c0             	movzbl %al,%eax
c010176e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101771:	a1 60 f6 11 c0       	mov    0xc011f660,%eax
c0101776:	3d 00 02 00 00       	cmp    $0x200,%eax
c010177b:	75 0a                	jne    c0101787 <cons_getc+0x63>
                cons.rpos = 0;
c010177d:	c7 05 60 f6 11 c0 00 	movl   $0x0,0xc011f660
c0101784:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101787:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010178a:	89 04 24             	mov    %eax,(%esp)
c010178d:	e8 fc f6 ff ff       	call   c0100e8e <__intr_restore>
    return c;
c0101792:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101795:	c9                   	leave  
c0101796:	c3                   	ret    

c0101797 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101797:	f3 0f 1e fb          	endbr32 
c010179b:	55                   	push   %ebp
c010179c:	89 e5                	mov    %esp,%ebp
c010179e:	83 ec 14             	sub    $0x14,%esp
c01017a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01017a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017ab:	66 a3 50 c5 11 c0    	mov    %ax,0xc011c550
    if (did_init) {
c01017b1:	a1 6c f6 11 c0       	mov    0xc011f66c,%eax
c01017b6:	85 c0                	test   %eax,%eax
c01017b8:	74 39                	je     c01017f3 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c01017ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017bd:	0f b6 c0             	movzbl %al,%eax
c01017c0:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01017c6:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017c9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017cd:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017d1:	ee                   	out    %al,(%dx)
}
c01017d2:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01017d3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017d7:	c1 e8 08             	shr    $0x8,%eax
c01017da:	0f b7 c0             	movzwl %ax,%eax
c01017dd:	0f b6 c0             	movzbl %al,%eax
c01017e0:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01017e6:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017e9:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01017ed:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01017f1:	ee                   	out    %al,(%dx)
}
c01017f2:	90                   	nop
    }
}
c01017f3:	90                   	nop
c01017f4:	c9                   	leave  
c01017f5:	c3                   	ret    

c01017f6 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01017f6:	f3 0f 1e fb          	endbr32 
c01017fa:	55                   	push   %ebp
c01017fb:	89 e5                	mov    %esp,%ebp
c01017fd:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101800:	8b 45 08             	mov    0x8(%ebp),%eax
c0101803:	ba 01 00 00 00       	mov    $0x1,%edx
c0101808:	88 c1                	mov    %al,%cl
c010180a:	d3 e2                	shl    %cl,%edx
c010180c:	89 d0                	mov    %edx,%eax
c010180e:	98                   	cwtl   
c010180f:	f7 d0                	not    %eax
c0101811:	0f bf d0             	movswl %ax,%edx
c0101814:	0f b7 05 50 c5 11 c0 	movzwl 0xc011c550,%eax
c010181b:	98                   	cwtl   
c010181c:	21 d0                	and    %edx,%eax
c010181e:	98                   	cwtl   
c010181f:	0f b7 c0             	movzwl %ax,%eax
c0101822:	89 04 24             	mov    %eax,(%esp)
c0101825:	e8 6d ff ff ff       	call   c0101797 <pic_setmask>
}
c010182a:	90                   	nop
c010182b:	c9                   	leave  
c010182c:	c3                   	ret    

c010182d <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010182d:	f3 0f 1e fb          	endbr32 
c0101831:	55                   	push   %ebp
c0101832:	89 e5                	mov    %esp,%ebp
c0101834:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101837:	c7 05 6c f6 11 c0 01 	movl   $0x1,0xc011f66c
c010183e:	00 00 00 
c0101841:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101847:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010184b:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010184f:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101853:	ee                   	out    %al,(%dx)
}
c0101854:	90                   	nop
c0101855:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010185b:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010185f:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101863:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101867:	ee                   	out    %al,(%dx)
}
c0101868:	90                   	nop
c0101869:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010186f:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101873:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101877:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010187b:	ee                   	out    %al,(%dx)
}
c010187c:	90                   	nop
c010187d:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101883:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101887:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010188b:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010188f:	ee                   	out    %al,(%dx)
}
c0101890:	90                   	nop
c0101891:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101897:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010189b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010189f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01018a3:	ee                   	out    %al,(%dx)
}
c01018a4:	90                   	nop
c01018a5:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01018ab:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018af:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01018b3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01018b7:	ee                   	out    %al,(%dx)
}
c01018b8:	90                   	nop
c01018b9:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01018bf:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c3:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01018c7:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01018cb:	ee                   	out    %al,(%dx)
}
c01018cc:	90                   	nop
c01018cd:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01018d3:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018db:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018df:	ee                   	out    %al,(%dx)
}
c01018e0:	90                   	nop
c01018e1:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01018e7:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018eb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018ef:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018f3:	ee                   	out    %al,(%dx)
}
c01018f4:	90                   	nop
c01018f5:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01018fb:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ff:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101903:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101907:	ee                   	out    %al,(%dx)
}
c0101908:	90                   	nop
c0101909:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010190f:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101913:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101917:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010191b:	ee                   	out    %al,(%dx)
}
c010191c:	90                   	nop
c010191d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101923:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101927:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010192b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010192f:	ee                   	out    %al,(%dx)
}
c0101930:	90                   	nop
c0101931:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101937:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010193b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010193f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101943:	ee                   	out    %al,(%dx)
}
c0101944:	90                   	nop
c0101945:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010194b:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010194f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101953:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101957:	ee                   	out    %al,(%dx)
}
c0101958:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101959:	0f b7 05 50 c5 11 c0 	movzwl 0xc011c550,%eax
c0101960:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101965:	74 0f                	je     c0101976 <pic_init+0x149>
        pic_setmask(irq_mask);
c0101967:	0f b7 05 50 c5 11 c0 	movzwl 0xc011c550,%eax
c010196e:	89 04 24             	mov    %eax,(%esp)
c0101971:	e8 21 fe ff ff       	call   c0101797 <pic_setmask>
    }
}
c0101976:	90                   	nop
c0101977:	c9                   	leave  
c0101978:	c3                   	ret    

c0101979 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101979:	f3 0f 1e fb          	endbr32 
c010197d:	55                   	push   %ebp
c010197e:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101980:	fb                   	sti    
}
c0101981:	90                   	nop
    sti();
}
c0101982:	90                   	nop
c0101983:	5d                   	pop    %ebp
c0101984:	c3                   	ret    

c0101985 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101985:	f3 0f 1e fb          	endbr32 
c0101989:	55                   	push   %ebp
c010198a:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010198c:	fa                   	cli    
}
c010198d:	90                   	nop
    cli();
}
c010198e:	90                   	nop
c010198f:	5d                   	pop    %ebp
c0101990:	c3                   	ret    

c0101991 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101991:	f3 0f 1e fb          	endbr32 
c0101995:	55                   	push   %ebp
c0101996:	89 e5                	mov    %esp,%ebp
c0101998:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010199b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01019a2:	00 
c01019a3:	c7 04 24 60 76 10 c0 	movl   $0xc0107660,(%esp)
c01019aa:	e8 16 e9 ff ff       	call   c01002c5 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01019af:	c7 04 24 6a 76 10 c0 	movl   $0xc010766a,(%esp)
c01019b6:	e8 0a e9 ff ff       	call   c01002c5 <cprintf>
    panic("EOT: kernel seems ok.");
c01019bb:	c7 44 24 08 78 76 10 	movl   $0xc0107678,0x8(%esp)
c01019c2:	c0 
c01019c3:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01019ca:	00 
c01019cb:	c7 04 24 8e 76 10 c0 	movl   $0xc010768e,(%esp)
c01019d2:	e8 5a ea ff ff       	call   c0100431 <__panic>

c01019d7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01019d7:	f3 0f 1e fb          	endbr32 
c01019db:	55                   	push   %ebp
c01019dc:	89 e5                	mov    %esp,%ebp
c01019de:	83 ec 10             	sub    $0x10,%esp
      */
    extern uintptr_t __vectors[];

    //all gate DPL=0, so use DPL_KERNEL 
    int i;
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c01019e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019e8:	e9 c4 00 00 00       	jmp    c0101ab1 <idt_init+0xda>
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c01019ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019f0:	8b 04 85 e0 c5 11 c0 	mov    -0x3fee3a20(,%eax,4),%eax
c01019f7:	0f b7 d0             	movzwl %ax,%edx
c01019fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019fd:	66 89 14 c5 80 f6 11 	mov    %dx,-0x3fee0980(,%eax,8)
c0101a04:	c0 
c0101a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a08:	66 c7 04 c5 82 f6 11 	movw   $0x8,-0x3fee097e(,%eax,8)
c0101a0f:	c0 08 00 
c0101a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a15:	0f b6 14 c5 84 f6 11 	movzbl -0x3fee097c(,%eax,8),%edx
c0101a1c:	c0 
c0101a1d:	80 e2 e0             	and    $0xe0,%dl
c0101a20:	88 14 c5 84 f6 11 c0 	mov    %dl,-0x3fee097c(,%eax,8)
c0101a27:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a2a:	0f b6 14 c5 84 f6 11 	movzbl -0x3fee097c(,%eax,8),%edx
c0101a31:	c0 
c0101a32:	80 e2 1f             	and    $0x1f,%dl
c0101a35:	88 14 c5 84 f6 11 c0 	mov    %dl,-0x3fee097c(,%eax,8)
c0101a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a3f:	0f b6 14 c5 85 f6 11 	movzbl -0x3fee097b(,%eax,8),%edx
c0101a46:	c0 
c0101a47:	80 e2 f0             	and    $0xf0,%dl
c0101a4a:	80 ca 0e             	or     $0xe,%dl
c0101a4d:	88 14 c5 85 f6 11 c0 	mov    %dl,-0x3fee097b(,%eax,8)
c0101a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a57:	0f b6 14 c5 85 f6 11 	movzbl -0x3fee097b(,%eax,8),%edx
c0101a5e:	c0 
c0101a5f:	80 e2 ef             	and    $0xef,%dl
c0101a62:	88 14 c5 85 f6 11 c0 	mov    %dl,-0x3fee097b(,%eax,8)
c0101a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a6c:	0f b6 14 c5 85 f6 11 	movzbl -0x3fee097b(,%eax,8),%edx
c0101a73:	c0 
c0101a74:	80 e2 9f             	and    $0x9f,%dl
c0101a77:	88 14 c5 85 f6 11 c0 	mov    %dl,-0x3fee097b(,%eax,8)
c0101a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a81:	0f b6 14 c5 85 f6 11 	movzbl -0x3fee097b(,%eax,8),%edx
c0101a88:	c0 
c0101a89:	80 ca 80             	or     $0x80,%dl
c0101a8c:	88 14 c5 85 f6 11 c0 	mov    %dl,-0x3fee097b(,%eax,8)
c0101a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a96:	8b 04 85 e0 c5 11 c0 	mov    -0x3fee3a20(,%eax,4),%eax
c0101a9d:	c1 e8 10             	shr    $0x10,%eax
c0101aa0:	0f b7 d0             	movzwl %ax,%edx
c0101aa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101aa6:	66 89 14 c5 86 f6 11 	mov    %dx,-0x3fee097a(,%eax,8)
c0101aad:	c0 
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
c0101aae:	ff 45 fc             	incl   -0x4(%ebp)
c0101ab1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101ab4:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101ab9:	0f 86 2e ff ff ff    	jbe    c01019ed <idt_init+0x16>
    }
    SETGATE(idt[T_SYSCALL],1,KERNEL_CS,__vectors[T_SYSCALL],DPL_USER);
c0101abf:	a1 e0 c7 11 c0       	mov    0xc011c7e0,%eax
c0101ac4:	0f b7 c0             	movzwl %ax,%eax
c0101ac7:	66 a3 80 fa 11 c0    	mov    %ax,0xc011fa80
c0101acd:	66 c7 05 82 fa 11 c0 	movw   $0x8,0xc011fa82
c0101ad4:	08 00 
c0101ad6:	0f b6 05 84 fa 11 c0 	movzbl 0xc011fa84,%eax
c0101add:	24 e0                	and    $0xe0,%al
c0101adf:	a2 84 fa 11 c0       	mov    %al,0xc011fa84
c0101ae4:	0f b6 05 84 fa 11 c0 	movzbl 0xc011fa84,%eax
c0101aeb:	24 1f                	and    $0x1f,%al
c0101aed:	a2 84 fa 11 c0       	mov    %al,0xc011fa84
c0101af2:	0f b6 05 85 fa 11 c0 	movzbl 0xc011fa85,%eax
c0101af9:	0c 0f                	or     $0xf,%al
c0101afb:	a2 85 fa 11 c0       	mov    %al,0xc011fa85
c0101b00:	0f b6 05 85 fa 11 c0 	movzbl 0xc011fa85,%eax
c0101b07:	24 ef                	and    $0xef,%al
c0101b09:	a2 85 fa 11 c0       	mov    %al,0xc011fa85
c0101b0e:	0f b6 05 85 fa 11 c0 	movzbl 0xc011fa85,%eax
c0101b15:	0c 60                	or     $0x60,%al
c0101b17:	a2 85 fa 11 c0       	mov    %al,0xc011fa85
c0101b1c:	0f b6 05 85 fa 11 c0 	movzbl 0xc011fa85,%eax
c0101b23:	0c 80                	or     $0x80,%al
c0101b25:	a2 85 fa 11 c0       	mov    %al,0xc011fa85
c0101b2a:	a1 e0 c7 11 c0       	mov    0xc011c7e0,%eax
c0101b2f:	c1 e8 10             	shr    $0x10,%eax
c0101b32:	0f b7 c0             	movzwl %ax,%eax
c0101b35:	66 a3 86 fa 11 c0    	mov    %ax,0xc011fa86
    SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
c0101b3b:	a1 c4 c7 11 c0       	mov    0xc011c7c4,%eax
c0101b40:	0f b7 c0             	movzwl %ax,%eax
c0101b43:	66 a3 48 fa 11 c0    	mov    %ax,0xc011fa48
c0101b49:	66 c7 05 4a fa 11 c0 	movw   $0x8,0xc011fa4a
c0101b50:	08 00 
c0101b52:	0f b6 05 4c fa 11 c0 	movzbl 0xc011fa4c,%eax
c0101b59:	24 e0                	and    $0xe0,%al
c0101b5b:	a2 4c fa 11 c0       	mov    %al,0xc011fa4c
c0101b60:	0f b6 05 4c fa 11 c0 	movzbl 0xc011fa4c,%eax
c0101b67:	24 1f                	and    $0x1f,%al
c0101b69:	a2 4c fa 11 c0       	mov    %al,0xc011fa4c
c0101b6e:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0101b75:	24 f0                	and    $0xf0,%al
c0101b77:	0c 0e                	or     $0xe,%al
c0101b79:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0101b7e:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0101b85:	24 ef                	and    $0xef,%al
c0101b87:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0101b8c:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0101b93:	0c 60                	or     $0x60,%al
c0101b95:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0101b9a:	0f b6 05 4d fa 11 c0 	movzbl 0xc011fa4d,%eax
c0101ba1:	0c 80                	or     $0x80,%al
c0101ba3:	a2 4d fa 11 c0       	mov    %al,0xc011fa4d
c0101ba8:	a1 c4 c7 11 c0       	mov    0xc011c7c4,%eax
c0101bad:	c1 e8 10             	shr    $0x10,%eax
c0101bb0:	0f b7 c0             	movzwl %ax,%eax
c0101bb3:	66 a3 4e fa 11 c0    	mov    %ax,0xc011fa4e
c0101bb9:	c7 45 f8 60 c5 11 c0 	movl   $0xc011c560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101bc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101bc3:	0f 01 18             	lidtl  (%eax)
}
c0101bc6:	90                   	nop
    
    //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
c0101bc7:	90                   	nop
c0101bc8:	c9                   	leave  
c0101bc9:	c3                   	ret    

c0101bca <trapname>:

static const char *
trapname(int trapno) {
c0101bca:	f3 0f 1e fb          	endbr32 
c0101bce:	55                   	push   %ebp
c0101bcf:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd4:	83 f8 13             	cmp    $0x13,%eax
c0101bd7:	77 0c                	ja     c0101be5 <trapname+0x1b>
        return excnames[trapno];
c0101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bdc:	8b 04 85 00 7a 10 c0 	mov    -0x3fef8600(,%eax,4),%eax
c0101be3:	eb 18                	jmp    c0101bfd <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101be5:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101be9:	7e 0d                	jle    c0101bf8 <trapname+0x2e>
c0101beb:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101bef:	7f 07                	jg     c0101bf8 <trapname+0x2e>
        return "Hardware Interrupt";
c0101bf1:	b8 9f 76 10 c0       	mov    $0xc010769f,%eax
c0101bf6:	eb 05                	jmp    c0101bfd <trapname+0x33>
    }
    return "(unknown trap)";
c0101bf8:	b8 b2 76 10 c0       	mov    $0xc01076b2,%eax
}
c0101bfd:	5d                   	pop    %ebp
c0101bfe:	c3                   	ret    

c0101bff <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101bff:	f3 0f 1e fb          	endbr32 
c0101c03:	55                   	push   %ebp
c0101c04:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101c06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c09:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101c0d:	83 f8 08             	cmp    $0x8,%eax
c0101c10:	0f 94 c0             	sete   %al
c0101c13:	0f b6 c0             	movzbl %al,%eax
}
c0101c16:	5d                   	pop    %ebp
c0101c17:	c3                   	ret    

c0101c18 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101c18:	f3 0f 1e fb          	endbr32 
c0101c1c:	55                   	push   %ebp
c0101c1d:	89 e5                	mov    %esp,%ebp
c0101c1f:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c29:	c7 04 24 f3 76 10 c0 	movl   $0xc01076f3,(%esp)
c0101c30:	e8 90 e6 ff ff       	call   c01002c5 <cprintf>
    print_regs(&tf->tf_regs);
c0101c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c38:	89 04 24             	mov    %eax,(%esp)
c0101c3b:	e8 8d 01 00 00       	call   c0101dcd <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101c40:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c43:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101c47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4b:	c7 04 24 04 77 10 c0 	movl   $0xc0107704,(%esp)
c0101c52:	e8 6e e6 ff ff       	call   c01002c5 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101c57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5a:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c62:	c7 04 24 17 77 10 c0 	movl   $0xc0107717,(%esp)
c0101c69:	e8 57 e6 ff ff       	call   c01002c5 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c71:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101c75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c79:	c7 04 24 2a 77 10 c0 	movl   $0xc010772a,(%esp)
c0101c80:	e8 40 e6 ff ff       	call   c01002c5 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101c85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c88:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c90:	c7 04 24 3d 77 10 c0 	movl   $0xc010773d,(%esp)
c0101c97:	e8 29 e6 ff ff       	call   c01002c5 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9f:	8b 40 30             	mov    0x30(%eax),%eax
c0101ca2:	89 04 24             	mov    %eax,(%esp)
c0101ca5:	e8 20 ff ff ff       	call   c0101bca <trapname>
c0101caa:	8b 55 08             	mov    0x8(%ebp),%edx
c0101cad:	8b 52 30             	mov    0x30(%edx),%edx
c0101cb0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101cb8:	c7 04 24 50 77 10 c0 	movl   $0xc0107750,(%esp)
c0101cbf:	e8 01 e6 ff ff       	call   c01002c5 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc7:	8b 40 34             	mov    0x34(%eax),%eax
c0101cca:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cce:	c7 04 24 62 77 10 c0 	movl   $0xc0107762,(%esp)
c0101cd5:	e8 eb e5 ff ff       	call   c01002c5 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdd:	8b 40 38             	mov    0x38(%eax),%eax
c0101ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce4:	c7 04 24 71 77 10 c0 	movl   $0xc0107771,(%esp)
c0101ceb:	e8 d5 e5 ff ff       	call   c01002c5 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cfb:	c7 04 24 80 77 10 c0 	movl   $0xc0107780,(%esp)
c0101d02:	e8 be e5 ff ff       	call   c01002c5 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101d07:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d0a:	8b 40 40             	mov    0x40(%eax),%eax
c0101d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d11:	c7 04 24 93 77 10 c0 	movl   $0xc0107793,(%esp)
c0101d18:	e8 a8 e5 ff ff       	call   c01002c5 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101d1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101d24:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101d2b:	eb 3d                	jmp    c0101d6a <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d30:	8b 50 40             	mov    0x40(%eax),%edx
c0101d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101d36:	21 d0                	and    %edx,%eax
c0101d38:	85 c0                	test   %eax,%eax
c0101d3a:	74 28                	je     c0101d64 <print_trapframe+0x14c>
c0101d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d3f:	8b 04 85 80 c5 11 c0 	mov    -0x3fee3a80(,%eax,4),%eax
c0101d46:	85 c0                	test   %eax,%eax
c0101d48:	74 1a                	je     c0101d64 <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
c0101d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d4d:	8b 04 85 80 c5 11 c0 	mov    -0x3fee3a80(,%eax,4),%eax
c0101d54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d58:	c7 04 24 a2 77 10 c0 	movl   $0xc01077a2,(%esp)
c0101d5f:	e8 61 e5 ff ff       	call   c01002c5 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101d64:	ff 45 f4             	incl   -0xc(%ebp)
c0101d67:	d1 65 f0             	shll   -0x10(%ebp)
c0101d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d6d:	83 f8 17             	cmp    $0x17,%eax
c0101d70:	76 bb                	jbe    c0101d2d <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101d72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d75:	8b 40 40             	mov    0x40(%eax),%eax
c0101d78:	c1 e8 0c             	shr    $0xc,%eax
c0101d7b:	83 e0 03             	and    $0x3,%eax
c0101d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d82:	c7 04 24 a6 77 10 c0 	movl   $0xc01077a6,(%esp)
c0101d89:	e8 37 e5 ff ff       	call   c01002c5 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d91:	89 04 24             	mov    %eax,(%esp)
c0101d94:	e8 66 fe ff ff       	call   c0101bff <trap_in_kernel>
c0101d99:	85 c0                	test   %eax,%eax
c0101d9b:	75 2d                	jne    c0101dca <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da0:	8b 40 44             	mov    0x44(%eax),%eax
c0101da3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da7:	c7 04 24 af 77 10 c0 	movl   $0xc01077af,(%esp)
c0101dae:	e8 12 e5 ff ff       	call   c01002c5 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101db3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db6:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101dba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dbe:	c7 04 24 be 77 10 c0 	movl   $0xc01077be,(%esp)
c0101dc5:	e8 fb e4 ff ff       	call   c01002c5 <cprintf>
    }
}
c0101dca:	90                   	nop
c0101dcb:	c9                   	leave  
c0101dcc:	c3                   	ret    

c0101dcd <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101dcd:	f3 0f 1e fb          	endbr32 
c0101dd1:	55                   	push   %ebp
c0101dd2:	89 e5                	mov    %esp,%ebp
c0101dd4:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dda:	8b 00                	mov    (%eax),%eax
c0101ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101de0:	c7 04 24 d1 77 10 c0 	movl   $0xc01077d1,(%esp)
c0101de7:	e8 d9 e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101dec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101def:	8b 40 04             	mov    0x4(%eax),%eax
c0101df2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101df6:	c7 04 24 e0 77 10 c0 	movl   $0xc01077e0,(%esp)
c0101dfd:	e8 c3 e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101e02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e05:	8b 40 08             	mov    0x8(%eax),%eax
c0101e08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e0c:	c7 04 24 ef 77 10 c0 	movl   $0xc01077ef,(%esp)
c0101e13:	e8 ad e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101e18:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e1b:	8b 40 0c             	mov    0xc(%eax),%eax
c0101e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e22:	c7 04 24 fe 77 10 c0 	movl   $0xc01077fe,(%esp)
c0101e29:	e8 97 e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101e2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e31:	8b 40 10             	mov    0x10(%eax),%eax
c0101e34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e38:	c7 04 24 0d 78 10 c0 	movl   $0xc010780d,(%esp)
c0101e3f:	e8 81 e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101e44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e47:	8b 40 14             	mov    0x14(%eax),%eax
c0101e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e4e:	c7 04 24 1c 78 10 c0 	movl   $0xc010781c,(%esp)
c0101e55:	e8 6b e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e5d:	8b 40 18             	mov    0x18(%eax),%eax
c0101e60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e64:	c7 04 24 2b 78 10 c0 	movl   $0xc010782b,(%esp)
c0101e6b:	e8 55 e4 ff ff       	call   c01002c5 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101e70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e73:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101e76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e7a:	c7 04 24 3a 78 10 c0 	movl   $0xc010783a,(%esp)
c0101e81:	e8 3f e4 ff ff       	call   c01002c5 <cprintf>
}
c0101e86:	90                   	nop
c0101e87:	c9                   	leave  
c0101e88:	c3                   	ret    

c0101e89 <trap_dispatch>:
}


/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101e89:	f3 0f 1e fb          	endbr32 
c0101e8d:	55                   	push   %ebp
c0101e8e:	89 e5                	mov    %esp,%ebp
c0101e90:	57                   	push   %edi
c0101e91:	56                   	push   %esi
c0101e92:	53                   	push   %ebx
c0101e93:	83 ec 3c             	sub    $0x3c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e99:	8b 40 30             	mov    0x30(%eax),%eax
c0101e9c:	83 f8 79             	cmp    $0x79,%eax
c0101e9f:	0f 84 ac 03 00 00    	je     c0102251 <trap_dispatch+0x3c8>
c0101ea5:	83 f8 79             	cmp    $0x79,%eax
c0101ea8:	0f 87 31 04 00 00    	ja     c01022df <trap_dispatch+0x456>
c0101eae:	83 f8 78             	cmp    $0x78,%eax
c0101eb1:	0f 84 af 02 00 00    	je     c0102166 <trap_dispatch+0x2dd>
c0101eb7:	83 f8 78             	cmp    $0x78,%eax
c0101eba:	0f 87 1f 04 00 00    	ja     c01022df <trap_dispatch+0x456>
c0101ec0:	83 f8 2f             	cmp    $0x2f,%eax
c0101ec3:	0f 87 16 04 00 00    	ja     c01022df <trap_dispatch+0x456>
c0101ec9:	83 f8 2e             	cmp    $0x2e,%eax
c0101ecc:	0f 83 42 04 00 00    	jae    c0102314 <trap_dispatch+0x48b>
c0101ed2:	83 f8 24             	cmp    $0x24,%eax
c0101ed5:	74 5e                	je     c0101f35 <trap_dispatch+0xac>
c0101ed7:	83 f8 24             	cmp    $0x24,%eax
c0101eda:	0f 87 ff 03 00 00    	ja     c01022df <trap_dispatch+0x456>
c0101ee0:	83 f8 20             	cmp    $0x20,%eax
c0101ee3:	74 0a                	je     c0101eef <trap_dispatch+0x66>
c0101ee5:	83 f8 21             	cmp    $0x21,%eax
c0101ee8:	74 74                	je     c0101f5e <trap_dispatch+0xd5>
c0101eea:	e9 f0 03 00 00       	jmp    c01022df <trap_dispatch+0x456>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0101eef:	a1 0c ff 11 c0       	mov    0xc011ff0c,%eax
c0101ef4:	40                   	inc    %eax
c0101ef5:	a3 0c ff 11 c0       	mov    %eax,0xc011ff0c
        if(ticks%100==0){
c0101efa:	8b 0d 0c ff 11 c0    	mov    0xc011ff0c,%ecx
c0101f00:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101f05:	89 c8                	mov    %ecx,%eax
c0101f07:	f7 e2                	mul    %edx
c0101f09:	c1 ea 05             	shr    $0x5,%edx
c0101f0c:	89 d0                	mov    %edx,%eax
c0101f0e:	c1 e0 02             	shl    $0x2,%eax
c0101f11:	01 d0                	add    %edx,%eax
c0101f13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101f1a:	01 d0                	add    %edx,%eax
c0101f1c:	c1 e0 02             	shl    $0x2,%eax
c0101f1f:	29 c1                	sub    %eax,%ecx
c0101f21:	89 ca                	mov    %ecx,%edx
c0101f23:	85 d2                	test   %edx,%edx
c0101f25:	0f 85 ec 03 00 00    	jne    c0102317 <trap_dispatch+0x48e>
            print_ticks();
c0101f2b:	e8 61 fa ff ff       	call   c0101991 <print_ticks>
        }
        break;
c0101f30:	e9 e2 03 00 00       	jmp    c0102317 <trap_dispatch+0x48e>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101f35:	e8 ea f7 ff ff       	call   c0101724 <cons_getc>
c0101f3a:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101f3d:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101f41:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101f45:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f4d:	c7 04 24 49 78 10 c0 	movl   $0xc0107849,(%esp)
c0101f54:	e8 6c e3 ff ff       	call   c01002c5 <cprintf>
        break;
c0101f59:	e9 bd 03 00 00       	jmp    c010231b <trap_dispatch+0x492>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101f5e:	e8 c1 f7 ff ff       	call   c0101724 <cons_getc>
c0101f63:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101f66:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101f6a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101f6e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f76:	c7 04 24 5b 78 10 c0 	movl   $0xc010785b,(%esp)
c0101f7d:	e8 43 e3 ff ff       	call   c01002c5 <cprintf>
        if (c == '0'&&!trap_in_kernel(tf)) {
c0101f82:	80 7d e7 30          	cmpb   $0x30,-0x19(%ebp)
c0101f86:	0f 85 bb 00 00 00    	jne    c0102047 <trap_dispatch+0x1be>
c0101f8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8f:	89 04 24             	mov    %eax,(%esp)
c0101f92:	e8 68 fc ff ff       	call   c0101bff <trap_in_kernel>
c0101f97:	85 c0                	test   %eax,%eax
c0101f99:	0f 85 a8 00 00 00    	jne    c0102047 <trap_dispatch+0x1be>
c0101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c0101fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fa8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101fac:	83 f8 08             	cmp    $0x8,%eax
c0101faf:	74 79                	je     c010202a <trap_dispatch+0x1a1>
        tf->tf_cs = KERNEL_CS;
c0101fb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fb4:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es =tf->tf_ss = KERNEL_DS;
c0101fba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fbd:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
c0101fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fc6:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c0101fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fcd:	66 89 50 28          	mov    %dx,0x28(%eax)
c0101fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fd4:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101fd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fdb:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0101fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fe2:	8b 40 40             	mov    0x40(%eax),%eax
c0101fe5:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101fea:	89 c2                	mov    %eax,%edx
c0101fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101fef:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101ff5:	8b 40 44             	mov    0x44(%eax),%eax
c0101ff8:	83 e8 44             	sub    $0x44,%eax
c0101ffb:	a3 6c ff 11 c0       	mov    %eax,0xc011ff6c
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102000:	a1 6c ff 11 c0       	mov    0xc011ff6c,%eax
c0102005:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c010200c:	00 
c010200d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102010:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102014:	89 04 24             	mov    %eax,(%esp)
c0102017:	e8 d1 4a 00 00       	call   c0106aed <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c010201c:	8b 15 6c ff 11 c0    	mov    0xc011ff6c,%edx
c0102022:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102025:	83 e8 04             	sub    $0x4,%eax
c0102028:	89 10                	mov    %edx,(%eax)
}
c010202a:	90                   	nop
        //切换为内核态
        switch_to_kernel(tf);
        cprintf("user to kernel\n");
c010202b:	c7 04 24 6a 78 10 c0 	movl   $0xc010786a,(%esp)
c0102032:	e8 8e e2 ff ff       	call   c01002c5 <cprintf>
        print_trapframe(tf);
c0102037:	8b 45 08             	mov    0x8(%ebp),%eax
c010203a:	89 04 24             	mov    %eax,(%esp)
c010203d:	e8 d6 fb ff ff       	call   c0101c18 <print_trapframe>
        //切换为用户态
        switch_to_user(tf);
        cprintf("kernel to user\n");
        print_trapframe(tf);
        }
        break;
c0102042:	e9 d3 02 00 00       	jmp    c010231a <trap_dispatch+0x491>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
c0102047:	80 7d e7 33          	cmpb   $0x33,-0x19(%ebp)
c010204b:	0f 85 c9 02 00 00    	jne    c010231a <trap_dispatch+0x491>
c0102051:	8b 45 08             	mov    0x8(%ebp),%eax
c0102054:	89 04 24             	mov    %eax,(%esp)
c0102057:	e8 a3 fb ff ff       	call   c0101bff <trap_in_kernel>
c010205c:	85 c0                	test   %eax,%eax
c010205e:	0f 84 b6 02 00 00    	je     c010231a <trap_dispatch+0x491>
c0102064:	8b 45 08             	mov    0x8(%ebp),%eax
c0102067:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (tf->tf_cs != USER_CS) {
c010206a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010206d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102071:	83 f8 1b             	cmp    $0x1b,%eax
c0102074:	0f 84 cf 00 00 00    	je     c0102149 <trap_dispatch+0x2c0>
        switchk2u = *tf;
c010207a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010207d:	b8 20 ff 11 c0       	mov    $0xc011ff20,%eax
c0102082:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0102087:	89 c1                	mov    %eax,%ecx
c0102089:	83 e1 01             	and    $0x1,%ecx
c010208c:	85 c9                	test   %ecx,%ecx
c010208e:	74 0c                	je     c010209c <trap_dispatch+0x213>
c0102090:	0f b6 0a             	movzbl (%edx),%ecx
c0102093:	88 08                	mov    %cl,(%eax)
c0102095:	8d 40 01             	lea    0x1(%eax),%eax
c0102098:	8d 52 01             	lea    0x1(%edx),%edx
c010209b:	4b                   	dec    %ebx
c010209c:	89 c1                	mov    %eax,%ecx
c010209e:	83 e1 02             	and    $0x2,%ecx
c01020a1:	85 c9                	test   %ecx,%ecx
c01020a3:	74 0f                	je     c01020b4 <trap_dispatch+0x22b>
c01020a5:	0f b7 0a             	movzwl (%edx),%ecx
c01020a8:	66 89 08             	mov    %cx,(%eax)
c01020ab:	8d 40 02             	lea    0x2(%eax),%eax
c01020ae:	8d 52 02             	lea    0x2(%edx),%edx
c01020b1:	83 eb 02             	sub    $0x2,%ebx
c01020b4:	89 df                	mov    %ebx,%edi
c01020b6:	83 e7 fc             	and    $0xfffffffc,%edi
c01020b9:	b9 00 00 00 00       	mov    $0x0,%ecx
c01020be:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c01020c1:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c01020c4:	83 c1 04             	add    $0x4,%ecx
c01020c7:	39 f9                	cmp    %edi,%ecx
c01020c9:	72 f3                	jb     c01020be <trap_dispatch+0x235>
c01020cb:	01 c8                	add    %ecx,%eax
c01020cd:	01 ca                	add    %ecx,%edx
c01020cf:	b9 00 00 00 00       	mov    $0x0,%ecx
c01020d4:	89 de                	mov    %ebx,%esi
c01020d6:	83 e6 02             	and    $0x2,%esi
c01020d9:	85 f6                	test   %esi,%esi
c01020db:	74 0b                	je     c01020e8 <trap_dispatch+0x25f>
c01020dd:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c01020e1:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c01020e5:	83 c1 02             	add    $0x2,%ecx
c01020e8:	83 e3 01             	and    $0x1,%ebx
c01020eb:	85 db                	test   %ebx,%ebx
c01020ed:	74 07                	je     c01020f6 <trap_dispatch+0x26d>
c01020ef:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c01020f3:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        switchk2u.tf_cs = USER_CS;
c01020f6:	66 c7 05 5c ff 11 c0 	movw   $0x1b,0xc011ff5c
c01020fd:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c01020ff:	66 c7 05 68 ff 11 c0 	movw   $0x23,0xc011ff68
c0102106:	23 00 
c0102108:	0f b7 05 68 ff 11 c0 	movzwl 0xc011ff68,%eax
c010210f:	66 a3 48 ff 11 c0    	mov    %ax,0xc011ff48
c0102115:	0f b7 05 48 ff 11 c0 	movzwl 0xc011ff48,%eax
c010211c:	66 a3 4c ff 11 c0    	mov    %ax,0xc011ff4c
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c0102122:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102125:	83 c0 4c             	add    $0x4c,%eax
c0102128:	a3 64 ff 11 c0       	mov    %eax,0xc011ff64
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c010212d:	a1 60 ff 11 c0       	mov    0xc011ff60,%eax
c0102132:	0d 00 30 00 00       	or     $0x3000,%eax
c0102137:	a3 60 ff 11 c0       	mov    %eax,0xc011ff60
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c010213c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010213f:	83 e8 04             	sub    $0x4,%eax
c0102142:	ba 20 ff 11 c0       	mov    $0xc011ff20,%edx
c0102147:	89 10                	mov    %edx,(%eax)
}
c0102149:	90                   	nop
        cprintf("kernel to user\n");
c010214a:	c7 04 24 7a 78 10 c0 	movl   $0xc010787a,(%esp)
c0102151:	e8 6f e1 ff ff       	call   c01002c5 <cprintf>
        print_trapframe(tf);
c0102156:	8b 45 08             	mov    0x8(%ebp),%eax
c0102159:	89 04 24             	mov    %eax,(%esp)
c010215c:	e8 b7 fa ff ff       	call   c0101c18 <print_trapframe>
        break;
c0102161:	e9 b4 01 00 00       	jmp    c010231a <trap_dispatch+0x491>
c0102166:	8b 45 08             	mov    0x8(%ebp),%eax
c0102169:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (tf->tf_cs != USER_CS) {
c010216c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010216f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102173:	83 f8 1b             	cmp    $0x1b,%eax
c0102176:	0f 84 cf 00 00 00    	je     c010224b <trap_dispatch+0x3c2>
        switchk2u = *tf;
c010217c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010217f:	b8 20 ff 11 c0       	mov    $0xc011ff20,%eax
c0102184:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0102189:	89 c1                	mov    %eax,%ecx
c010218b:	83 e1 01             	and    $0x1,%ecx
c010218e:	85 c9                	test   %ecx,%ecx
c0102190:	74 0c                	je     c010219e <trap_dispatch+0x315>
c0102192:	0f b6 0a             	movzbl (%edx),%ecx
c0102195:	88 08                	mov    %cl,(%eax)
c0102197:	8d 40 01             	lea    0x1(%eax),%eax
c010219a:	8d 52 01             	lea    0x1(%edx),%edx
c010219d:	4b                   	dec    %ebx
c010219e:	89 c1                	mov    %eax,%ecx
c01021a0:	83 e1 02             	and    $0x2,%ecx
c01021a3:	85 c9                	test   %ecx,%ecx
c01021a5:	74 0f                	je     c01021b6 <trap_dispatch+0x32d>
c01021a7:	0f b7 0a             	movzwl (%edx),%ecx
c01021aa:	66 89 08             	mov    %cx,(%eax)
c01021ad:	8d 40 02             	lea    0x2(%eax),%eax
c01021b0:	8d 52 02             	lea    0x2(%edx),%edx
c01021b3:	83 eb 02             	sub    $0x2,%ebx
c01021b6:	89 df                	mov    %ebx,%edi
c01021b8:	83 e7 fc             	and    $0xfffffffc,%edi
c01021bb:	b9 00 00 00 00       	mov    $0x0,%ecx
c01021c0:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c01021c3:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c01021c6:	83 c1 04             	add    $0x4,%ecx
c01021c9:	39 f9                	cmp    %edi,%ecx
c01021cb:	72 f3                	jb     c01021c0 <trap_dispatch+0x337>
c01021cd:	01 c8                	add    %ecx,%eax
c01021cf:	01 ca                	add    %ecx,%edx
c01021d1:	b9 00 00 00 00       	mov    $0x0,%ecx
c01021d6:	89 de                	mov    %ebx,%esi
c01021d8:	83 e6 02             	and    $0x2,%esi
c01021db:	85 f6                	test   %esi,%esi
c01021dd:	74 0b                	je     c01021ea <trap_dispatch+0x361>
c01021df:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c01021e3:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c01021e7:	83 c1 02             	add    $0x2,%ecx
c01021ea:	83 e3 01             	and    $0x1,%ebx
c01021ed:	85 db                	test   %ebx,%ebx
c01021ef:	74 07                	je     c01021f8 <trap_dispatch+0x36f>
c01021f1:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c01021f5:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        switchk2u.tf_cs = USER_CS;
c01021f8:	66 c7 05 5c ff 11 c0 	movw   $0x1b,0xc011ff5c
c01021ff:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0102201:	66 c7 05 68 ff 11 c0 	movw   $0x23,0xc011ff68
c0102208:	23 00 
c010220a:	0f b7 05 68 ff 11 c0 	movzwl 0xc011ff68,%eax
c0102211:	66 a3 48 ff 11 c0    	mov    %ax,0xc011ff48
c0102217:	0f b7 05 48 ff 11 c0 	movzwl 0xc011ff48,%eax
c010221e:	66 a3 4c ff 11 c0    	mov    %ax,0xc011ff4c
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
c0102224:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102227:	83 c0 4c             	add    $0x4c,%eax
c010222a:	a3 64 ff 11 c0       	mov    %eax,0xc011ff64
        switchk2u.tf_eflags |= FL_IOPL_MASK;
c010222f:	a1 60 ff 11 c0       	mov    0xc011ff60,%eax
c0102234:	0d 00 30 00 00       	or     $0x3000,%eax
c0102239:	a3 60 ff 11 c0       	mov    %eax,0xc011ff60
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c010223e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102241:	83 e8 04             	sub    $0x4,%eax
c0102244:	ba 20 ff 11 c0       	mov    $0xc011ff20,%edx
c0102249:	89 10                	mov    %edx,(%eax)
}
c010224b:	90                   	nop
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
c010224c:	e9 ca 00 00 00       	jmp    c010231b <trap_dispatch+0x492>
c0102251:	8b 45 08             	mov    0x8(%ebp),%eax
c0102254:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
c0102257:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010225a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010225e:	83 f8 08             	cmp    $0x8,%eax
c0102261:	74 79                	je     c01022dc <trap_dispatch+0x453>
        tf->tf_cs = KERNEL_CS;
c0102263:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102266:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es =tf->tf_ss = KERNEL_DS;
c010226c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010226f:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
c0102275:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102278:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010227c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010227f:	66 89 50 28          	mov    %dx,0x28(%eax)
c0102283:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102286:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010228a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010228d:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0102291:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102294:	8b 40 40             	mov    0x40(%eax),%eax
c0102297:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c010229c:	89 c2                	mov    %eax,%edx
c010229e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01022a1:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c01022a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01022a7:	8b 40 44             	mov    0x44(%eax),%eax
c01022aa:	83 e8 44             	sub    $0x44,%eax
c01022ad:	a3 6c ff 11 c0       	mov    %eax,0xc011ff6c
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c01022b2:	a1 6c ff 11 c0       	mov    0xc011ff6c,%eax
c01022b7:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c01022be:	00 
c01022bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01022c2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01022c6:	89 04 24             	mov    %eax,(%esp)
c01022c9:	e8 1f 48 00 00       	call   c0106aed <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c01022ce:	8b 15 6c ff 11 c0    	mov    0xc011ff6c,%edx
c01022d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01022d7:	83 e8 04             	sub    $0x4,%eax
c01022da:	89 10                	mov    %edx,(%eax)
}
c01022dc:	90                   	nop
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        break;
c01022dd:	eb 3c                	jmp    c010231b <trap_dispatch+0x492>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01022df:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022e6:	83 e0 03             	and    $0x3,%eax
c01022e9:	85 c0                	test   %eax,%eax
c01022eb:	75 2e                	jne    c010231b <trap_dispatch+0x492>
            print_trapframe(tf);
c01022ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f0:	89 04 24             	mov    %eax,(%esp)
c01022f3:	e8 20 f9 ff ff       	call   c0101c18 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01022f8:	c7 44 24 08 8a 78 10 	movl   $0xc010788a,0x8(%esp)
c01022ff:	c0 
c0102300:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0102307:	00 
c0102308:	c7 04 24 8e 76 10 c0 	movl   $0xc010768e,(%esp)
c010230f:	e8 1d e1 ff ff       	call   c0100431 <__panic>
        break;
c0102314:	90                   	nop
c0102315:	eb 04                	jmp    c010231b <trap_dispatch+0x492>
        break;
c0102317:	90                   	nop
c0102318:	eb 01                	jmp    c010231b <trap_dispatch+0x492>
        break;
c010231a:	90                   	nop
        }
    }
}
c010231b:	90                   	nop
c010231c:	83 c4 3c             	add    $0x3c,%esp
c010231f:	5b                   	pop    %ebx
c0102320:	5e                   	pop    %esi
c0102321:	5f                   	pop    %edi
c0102322:	5d                   	pop    %ebp
c0102323:	c3                   	ret    

c0102324 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102324:	f3 0f 1e fb          	endbr32 
c0102328:	55                   	push   %ebp
c0102329:	89 e5                	mov    %esp,%ebp
c010232b:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010232e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102331:	89 04 24             	mov    %eax,(%esp)
c0102334:	e8 50 fb ff ff       	call   c0101e89 <trap_dispatch>
}
c0102339:	90                   	nop
c010233a:	c9                   	leave  
c010233b:	c3                   	ret    

c010233c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010233c:	6a 00                	push   $0x0
  pushl $0
c010233e:	6a 00                	push   $0x0
  jmp __alltraps
c0102340:	e9 69 0a 00 00       	jmp    c0102dae <__alltraps>

c0102345 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102345:	6a 00                	push   $0x0
  pushl $1
c0102347:	6a 01                	push   $0x1
  jmp __alltraps
c0102349:	e9 60 0a 00 00       	jmp    c0102dae <__alltraps>

c010234e <vector2>:
.globl vector2
vector2:
  pushl $0
c010234e:	6a 00                	push   $0x0
  pushl $2
c0102350:	6a 02                	push   $0x2
  jmp __alltraps
c0102352:	e9 57 0a 00 00       	jmp    c0102dae <__alltraps>

c0102357 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $3
c0102359:	6a 03                	push   $0x3
  jmp __alltraps
c010235b:	e9 4e 0a 00 00       	jmp    c0102dae <__alltraps>

c0102360 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102360:	6a 00                	push   $0x0
  pushl $4
c0102362:	6a 04                	push   $0x4
  jmp __alltraps
c0102364:	e9 45 0a 00 00       	jmp    c0102dae <__alltraps>

c0102369 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102369:	6a 00                	push   $0x0
  pushl $5
c010236b:	6a 05                	push   $0x5
  jmp __alltraps
c010236d:	e9 3c 0a 00 00       	jmp    c0102dae <__alltraps>

c0102372 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102372:	6a 00                	push   $0x0
  pushl $6
c0102374:	6a 06                	push   $0x6
  jmp __alltraps
c0102376:	e9 33 0a 00 00       	jmp    c0102dae <__alltraps>

c010237b <vector7>:
.globl vector7
vector7:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $7
c010237d:	6a 07                	push   $0x7
  jmp __alltraps
c010237f:	e9 2a 0a 00 00       	jmp    c0102dae <__alltraps>

c0102384 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102384:	6a 08                	push   $0x8
  jmp __alltraps
c0102386:	e9 23 0a 00 00       	jmp    c0102dae <__alltraps>

c010238b <vector9>:
.globl vector9
vector9:
  pushl $0
c010238b:	6a 00                	push   $0x0
  pushl $9
c010238d:	6a 09                	push   $0x9
  jmp __alltraps
c010238f:	e9 1a 0a 00 00       	jmp    c0102dae <__alltraps>

c0102394 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102394:	6a 0a                	push   $0xa
  jmp __alltraps
c0102396:	e9 13 0a 00 00       	jmp    c0102dae <__alltraps>

c010239b <vector11>:
.globl vector11
vector11:
  pushl $11
c010239b:	6a 0b                	push   $0xb
  jmp __alltraps
c010239d:	e9 0c 0a 00 00       	jmp    c0102dae <__alltraps>

c01023a2 <vector12>:
.globl vector12
vector12:
  pushl $12
c01023a2:	6a 0c                	push   $0xc
  jmp __alltraps
c01023a4:	e9 05 0a 00 00       	jmp    c0102dae <__alltraps>

c01023a9 <vector13>:
.globl vector13
vector13:
  pushl $13
c01023a9:	6a 0d                	push   $0xd
  jmp __alltraps
c01023ab:	e9 fe 09 00 00       	jmp    c0102dae <__alltraps>

c01023b0 <vector14>:
.globl vector14
vector14:
  pushl $14
c01023b0:	6a 0e                	push   $0xe
  jmp __alltraps
c01023b2:	e9 f7 09 00 00       	jmp    c0102dae <__alltraps>

c01023b7 <vector15>:
.globl vector15
vector15:
  pushl $0
c01023b7:	6a 00                	push   $0x0
  pushl $15
c01023b9:	6a 0f                	push   $0xf
  jmp __alltraps
c01023bb:	e9 ee 09 00 00       	jmp    c0102dae <__alltraps>

c01023c0 <vector16>:
.globl vector16
vector16:
  pushl $0
c01023c0:	6a 00                	push   $0x0
  pushl $16
c01023c2:	6a 10                	push   $0x10
  jmp __alltraps
c01023c4:	e9 e5 09 00 00       	jmp    c0102dae <__alltraps>

c01023c9 <vector17>:
.globl vector17
vector17:
  pushl $17
c01023c9:	6a 11                	push   $0x11
  jmp __alltraps
c01023cb:	e9 de 09 00 00       	jmp    c0102dae <__alltraps>

c01023d0 <vector18>:
.globl vector18
vector18:
  pushl $0
c01023d0:	6a 00                	push   $0x0
  pushl $18
c01023d2:	6a 12                	push   $0x12
  jmp __alltraps
c01023d4:	e9 d5 09 00 00       	jmp    c0102dae <__alltraps>

c01023d9 <vector19>:
.globl vector19
vector19:
  pushl $0
c01023d9:	6a 00                	push   $0x0
  pushl $19
c01023db:	6a 13                	push   $0x13
  jmp __alltraps
c01023dd:	e9 cc 09 00 00       	jmp    c0102dae <__alltraps>

c01023e2 <vector20>:
.globl vector20
vector20:
  pushl $0
c01023e2:	6a 00                	push   $0x0
  pushl $20
c01023e4:	6a 14                	push   $0x14
  jmp __alltraps
c01023e6:	e9 c3 09 00 00       	jmp    c0102dae <__alltraps>

c01023eb <vector21>:
.globl vector21
vector21:
  pushl $0
c01023eb:	6a 00                	push   $0x0
  pushl $21
c01023ed:	6a 15                	push   $0x15
  jmp __alltraps
c01023ef:	e9 ba 09 00 00       	jmp    c0102dae <__alltraps>

c01023f4 <vector22>:
.globl vector22
vector22:
  pushl $0
c01023f4:	6a 00                	push   $0x0
  pushl $22
c01023f6:	6a 16                	push   $0x16
  jmp __alltraps
c01023f8:	e9 b1 09 00 00       	jmp    c0102dae <__alltraps>

c01023fd <vector23>:
.globl vector23
vector23:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $23
c01023ff:	6a 17                	push   $0x17
  jmp __alltraps
c0102401:	e9 a8 09 00 00       	jmp    c0102dae <__alltraps>

c0102406 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102406:	6a 00                	push   $0x0
  pushl $24
c0102408:	6a 18                	push   $0x18
  jmp __alltraps
c010240a:	e9 9f 09 00 00       	jmp    c0102dae <__alltraps>

c010240f <vector25>:
.globl vector25
vector25:
  pushl $0
c010240f:	6a 00                	push   $0x0
  pushl $25
c0102411:	6a 19                	push   $0x19
  jmp __alltraps
c0102413:	e9 96 09 00 00       	jmp    c0102dae <__alltraps>

c0102418 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102418:	6a 00                	push   $0x0
  pushl $26
c010241a:	6a 1a                	push   $0x1a
  jmp __alltraps
c010241c:	e9 8d 09 00 00       	jmp    c0102dae <__alltraps>

c0102421 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $27
c0102423:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102425:	e9 84 09 00 00       	jmp    c0102dae <__alltraps>

c010242a <vector28>:
.globl vector28
vector28:
  pushl $0
c010242a:	6a 00                	push   $0x0
  pushl $28
c010242c:	6a 1c                	push   $0x1c
  jmp __alltraps
c010242e:	e9 7b 09 00 00       	jmp    c0102dae <__alltraps>

c0102433 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102433:	6a 00                	push   $0x0
  pushl $29
c0102435:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102437:	e9 72 09 00 00       	jmp    c0102dae <__alltraps>

c010243c <vector30>:
.globl vector30
vector30:
  pushl $0
c010243c:	6a 00                	push   $0x0
  pushl $30
c010243e:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102440:	e9 69 09 00 00       	jmp    c0102dae <__alltraps>

c0102445 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $31
c0102447:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102449:	e9 60 09 00 00       	jmp    c0102dae <__alltraps>

c010244e <vector32>:
.globl vector32
vector32:
  pushl $0
c010244e:	6a 00                	push   $0x0
  pushl $32
c0102450:	6a 20                	push   $0x20
  jmp __alltraps
c0102452:	e9 57 09 00 00       	jmp    c0102dae <__alltraps>

c0102457 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102457:	6a 00                	push   $0x0
  pushl $33
c0102459:	6a 21                	push   $0x21
  jmp __alltraps
c010245b:	e9 4e 09 00 00       	jmp    c0102dae <__alltraps>

c0102460 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102460:	6a 00                	push   $0x0
  pushl $34
c0102462:	6a 22                	push   $0x22
  jmp __alltraps
c0102464:	e9 45 09 00 00       	jmp    c0102dae <__alltraps>

c0102469 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $35
c010246b:	6a 23                	push   $0x23
  jmp __alltraps
c010246d:	e9 3c 09 00 00       	jmp    c0102dae <__alltraps>

c0102472 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102472:	6a 00                	push   $0x0
  pushl $36
c0102474:	6a 24                	push   $0x24
  jmp __alltraps
c0102476:	e9 33 09 00 00       	jmp    c0102dae <__alltraps>

c010247b <vector37>:
.globl vector37
vector37:
  pushl $0
c010247b:	6a 00                	push   $0x0
  pushl $37
c010247d:	6a 25                	push   $0x25
  jmp __alltraps
c010247f:	e9 2a 09 00 00       	jmp    c0102dae <__alltraps>

c0102484 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102484:	6a 00                	push   $0x0
  pushl $38
c0102486:	6a 26                	push   $0x26
  jmp __alltraps
c0102488:	e9 21 09 00 00       	jmp    c0102dae <__alltraps>

c010248d <vector39>:
.globl vector39
vector39:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $39
c010248f:	6a 27                	push   $0x27
  jmp __alltraps
c0102491:	e9 18 09 00 00       	jmp    c0102dae <__alltraps>

c0102496 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102496:	6a 00                	push   $0x0
  pushl $40
c0102498:	6a 28                	push   $0x28
  jmp __alltraps
c010249a:	e9 0f 09 00 00       	jmp    c0102dae <__alltraps>

c010249f <vector41>:
.globl vector41
vector41:
  pushl $0
c010249f:	6a 00                	push   $0x0
  pushl $41
c01024a1:	6a 29                	push   $0x29
  jmp __alltraps
c01024a3:	e9 06 09 00 00       	jmp    c0102dae <__alltraps>

c01024a8 <vector42>:
.globl vector42
vector42:
  pushl $0
c01024a8:	6a 00                	push   $0x0
  pushl $42
c01024aa:	6a 2a                	push   $0x2a
  jmp __alltraps
c01024ac:	e9 fd 08 00 00       	jmp    c0102dae <__alltraps>

c01024b1 <vector43>:
.globl vector43
vector43:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $43
c01024b3:	6a 2b                	push   $0x2b
  jmp __alltraps
c01024b5:	e9 f4 08 00 00       	jmp    c0102dae <__alltraps>

c01024ba <vector44>:
.globl vector44
vector44:
  pushl $0
c01024ba:	6a 00                	push   $0x0
  pushl $44
c01024bc:	6a 2c                	push   $0x2c
  jmp __alltraps
c01024be:	e9 eb 08 00 00       	jmp    c0102dae <__alltraps>

c01024c3 <vector45>:
.globl vector45
vector45:
  pushl $0
c01024c3:	6a 00                	push   $0x0
  pushl $45
c01024c5:	6a 2d                	push   $0x2d
  jmp __alltraps
c01024c7:	e9 e2 08 00 00       	jmp    c0102dae <__alltraps>

c01024cc <vector46>:
.globl vector46
vector46:
  pushl $0
c01024cc:	6a 00                	push   $0x0
  pushl $46
c01024ce:	6a 2e                	push   $0x2e
  jmp __alltraps
c01024d0:	e9 d9 08 00 00       	jmp    c0102dae <__alltraps>

c01024d5 <vector47>:
.globl vector47
vector47:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $47
c01024d7:	6a 2f                	push   $0x2f
  jmp __alltraps
c01024d9:	e9 d0 08 00 00       	jmp    c0102dae <__alltraps>

c01024de <vector48>:
.globl vector48
vector48:
  pushl $0
c01024de:	6a 00                	push   $0x0
  pushl $48
c01024e0:	6a 30                	push   $0x30
  jmp __alltraps
c01024e2:	e9 c7 08 00 00       	jmp    c0102dae <__alltraps>

c01024e7 <vector49>:
.globl vector49
vector49:
  pushl $0
c01024e7:	6a 00                	push   $0x0
  pushl $49
c01024e9:	6a 31                	push   $0x31
  jmp __alltraps
c01024eb:	e9 be 08 00 00       	jmp    c0102dae <__alltraps>

c01024f0 <vector50>:
.globl vector50
vector50:
  pushl $0
c01024f0:	6a 00                	push   $0x0
  pushl $50
c01024f2:	6a 32                	push   $0x32
  jmp __alltraps
c01024f4:	e9 b5 08 00 00       	jmp    c0102dae <__alltraps>

c01024f9 <vector51>:
.globl vector51
vector51:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $51
c01024fb:	6a 33                	push   $0x33
  jmp __alltraps
c01024fd:	e9 ac 08 00 00       	jmp    c0102dae <__alltraps>

c0102502 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102502:	6a 00                	push   $0x0
  pushl $52
c0102504:	6a 34                	push   $0x34
  jmp __alltraps
c0102506:	e9 a3 08 00 00       	jmp    c0102dae <__alltraps>

c010250b <vector53>:
.globl vector53
vector53:
  pushl $0
c010250b:	6a 00                	push   $0x0
  pushl $53
c010250d:	6a 35                	push   $0x35
  jmp __alltraps
c010250f:	e9 9a 08 00 00       	jmp    c0102dae <__alltraps>

c0102514 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102514:	6a 00                	push   $0x0
  pushl $54
c0102516:	6a 36                	push   $0x36
  jmp __alltraps
c0102518:	e9 91 08 00 00       	jmp    c0102dae <__alltraps>

c010251d <vector55>:
.globl vector55
vector55:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $55
c010251f:	6a 37                	push   $0x37
  jmp __alltraps
c0102521:	e9 88 08 00 00       	jmp    c0102dae <__alltraps>

c0102526 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102526:	6a 00                	push   $0x0
  pushl $56
c0102528:	6a 38                	push   $0x38
  jmp __alltraps
c010252a:	e9 7f 08 00 00       	jmp    c0102dae <__alltraps>

c010252f <vector57>:
.globl vector57
vector57:
  pushl $0
c010252f:	6a 00                	push   $0x0
  pushl $57
c0102531:	6a 39                	push   $0x39
  jmp __alltraps
c0102533:	e9 76 08 00 00       	jmp    c0102dae <__alltraps>

c0102538 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102538:	6a 00                	push   $0x0
  pushl $58
c010253a:	6a 3a                	push   $0x3a
  jmp __alltraps
c010253c:	e9 6d 08 00 00       	jmp    c0102dae <__alltraps>

c0102541 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $59
c0102543:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102545:	e9 64 08 00 00       	jmp    c0102dae <__alltraps>

c010254a <vector60>:
.globl vector60
vector60:
  pushl $0
c010254a:	6a 00                	push   $0x0
  pushl $60
c010254c:	6a 3c                	push   $0x3c
  jmp __alltraps
c010254e:	e9 5b 08 00 00       	jmp    c0102dae <__alltraps>

c0102553 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102553:	6a 00                	push   $0x0
  pushl $61
c0102555:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102557:	e9 52 08 00 00       	jmp    c0102dae <__alltraps>

c010255c <vector62>:
.globl vector62
vector62:
  pushl $0
c010255c:	6a 00                	push   $0x0
  pushl $62
c010255e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102560:	e9 49 08 00 00       	jmp    c0102dae <__alltraps>

c0102565 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $63
c0102567:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102569:	e9 40 08 00 00       	jmp    c0102dae <__alltraps>

c010256e <vector64>:
.globl vector64
vector64:
  pushl $0
c010256e:	6a 00                	push   $0x0
  pushl $64
c0102570:	6a 40                	push   $0x40
  jmp __alltraps
c0102572:	e9 37 08 00 00       	jmp    c0102dae <__alltraps>

c0102577 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102577:	6a 00                	push   $0x0
  pushl $65
c0102579:	6a 41                	push   $0x41
  jmp __alltraps
c010257b:	e9 2e 08 00 00       	jmp    c0102dae <__alltraps>

c0102580 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102580:	6a 00                	push   $0x0
  pushl $66
c0102582:	6a 42                	push   $0x42
  jmp __alltraps
c0102584:	e9 25 08 00 00       	jmp    c0102dae <__alltraps>

c0102589 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $67
c010258b:	6a 43                	push   $0x43
  jmp __alltraps
c010258d:	e9 1c 08 00 00       	jmp    c0102dae <__alltraps>

c0102592 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102592:	6a 00                	push   $0x0
  pushl $68
c0102594:	6a 44                	push   $0x44
  jmp __alltraps
c0102596:	e9 13 08 00 00       	jmp    c0102dae <__alltraps>

c010259b <vector69>:
.globl vector69
vector69:
  pushl $0
c010259b:	6a 00                	push   $0x0
  pushl $69
c010259d:	6a 45                	push   $0x45
  jmp __alltraps
c010259f:	e9 0a 08 00 00       	jmp    c0102dae <__alltraps>

c01025a4 <vector70>:
.globl vector70
vector70:
  pushl $0
c01025a4:	6a 00                	push   $0x0
  pushl $70
c01025a6:	6a 46                	push   $0x46
  jmp __alltraps
c01025a8:	e9 01 08 00 00       	jmp    c0102dae <__alltraps>

c01025ad <vector71>:
.globl vector71
vector71:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $71
c01025af:	6a 47                	push   $0x47
  jmp __alltraps
c01025b1:	e9 f8 07 00 00       	jmp    c0102dae <__alltraps>

c01025b6 <vector72>:
.globl vector72
vector72:
  pushl $0
c01025b6:	6a 00                	push   $0x0
  pushl $72
c01025b8:	6a 48                	push   $0x48
  jmp __alltraps
c01025ba:	e9 ef 07 00 00       	jmp    c0102dae <__alltraps>

c01025bf <vector73>:
.globl vector73
vector73:
  pushl $0
c01025bf:	6a 00                	push   $0x0
  pushl $73
c01025c1:	6a 49                	push   $0x49
  jmp __alltraps
c01025c3:	e9 e6 07 00 00       	jmp    c0102dae <__alltraps>

c01025c8 <vector74>:
.globl vector74
vector74:
  pushl $0
c01025c8:	6a 00                	push   $0x0
  pushl $74
c01025ca:	6a 4a                	push   $0x4a
  jmp __alltraps
c01025cc:	e9 dd 07 00 00       	jmp    c0102dae <__alltraps>

c01025d1 <vector75>:
.globl vector75
vector75:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $75
c01025d3:	6a 4b                	push   $0x4b
  jmp __alltraps
c01025d5:	e9 d4 07 00 00       	jmp    c0102dae <__alltraps>

c01025da <vector76>:
.globl vector76
vector76:
  pushl $0
c01025da:	6a 00                	push   $0x0
  pushl $76
c01025dc:	6a 4c                	push   $0x4c
  jmp __alltraps
c01025de:	e9 cb 07 00 00       	jmp    c0102dae <__alltraps>

c01025e3 <vector77>:
.globl vector77
vector77:
  pushl $0
c01025e3:	6a 00                	push   $0x0
  pushl $77
c01025e5:	6a 4d                	push   $0x4d
  jmp __alltraps
c01025e7:	e9 c2 07 00 00       	jmp    c0102dae <__alltraps>

c01025ec <vector78>:
.globl vector78
vector78:
  pushl $0
c01025ec:	6a 00                	push   $0x0
  pushl $78
c01025ee:	6a 4e                	push   $0x4e
  jmp __alltraps
c01025f0:	e9 b9 07 00 00       	jmp    c0102dae <__alltraps>

c01025f5 <vector79>:
.globl vector79
vector79:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $79
c01025f7:	6a 4f                	push   $0x4f
  jmp __alltraps
c01025f9:	e9 b0 07 00 00       	jmp    c0102dae <__alltraps>

c01025fe <vector80>:
.globl vector80
vector80:
  pushl $0
c01025fe:	6a 00                	push   $0x0
  pushl $80
c0102600:	6a 50                	push   $0x50
  jmp __alltraps
c0102602:	e9 a7 07 00 00       	jmp    c0102dae <__alltraps>

c0102607 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102607:	6a 00                	push   $0x0
  pushl $81
c0102609:	6a 51                	push   $0x51
  jmp __alltraps
c010260b:	e9 9e 07 00 00       	jmp    c0102dae <__alltraps>

c0102610 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102610:	6a 00                	push   $0x0
  pushl $82
c0102612:	6a 52                	push   $0x52
  jmp __alltraps
c0102614:	e9 95 07 00 00       	jmp    c0102dae <__alltraps>

c0102619 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $83
c010261b:	6a 53                	push   $0x53
  jmp __alltraps
c010261d:	e9 8c 07 00 00       	jmp    c0102dae <__alltraps>

c0102622 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102622:	6a 00                	push   $0x0
  pushl $84
c0102624:	6a 54                	push   $0x54
  jmp __alltraps
c0102626:	e9 83 07 00 00       	jmp    c0102dae <__alltraps>

c010262b <vector85>:
.globl vector85
vector85:
  pushl $0
c010262b:	6a 00                	push   $0x0
  pushl $85
c010262d:	6a 55                	push   $0x55
  jmp __alltraps
c010262f:	e9 7a 07 00 00       	jmp    c0102dae <__alltraps>

c0102634 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102634:	6a 00                	push   $0x0
  pushl $86
c0102636:	6a 56                	push   $0x56
  jmp __alltraps
c0102638:	e9 71 07 00 00       	jmp    c0102dae <__alltraps>

c010263d <vector87>:
.globl vector87
vector87:
  pushl $0
c010263d:	6a 00                	push   $0x0
  pushl $87
c010263f:	6a 57                	push   $0x57
  jmp __alltraps
c0102641:	e9 68 07 00 00       	jmp    c0102dae <__alltraps>

c0102646 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102646:	6a 00                	push   $0x0
  pushl $88
c0102648:	6a 58                	push   $0x58
  jmp __alltraps
c010264a:	e9 5f 07 00 00       	jmp    c0102dae <__alltraps>

c010264f <vector89>:
.globl vector89
vector89:
  pushl $0
c010264f:	6a 00                	push   $0x0
  pushl $89
c0102651:	6a 59                	push   $0x59
  jmp __alltraps
c0102653:	e9 56 07 00 00       	jmp    c0102dae <__alltraps>

c0102658 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102658:	6a 00                	push   $0x0
  pushl $90
c010265a:	6a 5a                	push   $0x5a
  jmp __alltraps
c010265c:	e9 4d 07 00 00       	jmp    c0102dae <__alltraps>

c0102661 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102661:	6a 00                	push   $0x0
  pushl $91
c0102663:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102665:	e9 44 07 00 00       	jmp    c0102dae <__alltraps>

c010266a <vector92>:
.globl vector92
vector92:
  pushl $0
c010266a:	6a 00                	push   $0x0
  pushl $92
c010266c:	6a 5c                	push   $0x5c
  jmp __alltraps
c010266e:	e9 3b 07 00 00       	jmp    c0102dae <__alltraps>

c0102673 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102673:	6a 00                	push   $0x0
  pushl $93
c0102675:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102677:	e9 32 07 00 00       	jmp    c0102dae <__alltraps>

c010267c <vector94>:
.globl vector94
vector94:
  pushl $0
c010267c:	6a 00                	push   $0x0
  pushl $94
c010267e:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102680:	e9 29 07 00 00       	jmp    c0102dae <__alltraps>

c0102685 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102685:	6a 00                	push   $0x0
  pushl $95
c0102687:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102689:	e9 20 07 00 00       	jmp    c0102dae <__alltraps>

c010268e <vector96>:
.globl vector96
vector96:
  pushl $0
c010268e:	6a 00                	push   $0x0
  pushl $96
c0102690:	6a 60                	push   $0x60
  jmp __alltraps
c0102692:	e9 17 07 00 00       	jmp    c0102dae <__alltraps>

c0102697 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102697:	6a 00                	push   $0x0
  pushl $97
c0102699:	6a 61                	push   $0x61
  jmp __alltraps
c010269b:	e9 0e 07 00 00       	jmp    c0102dae <__alltraps>

c01026a0 <vector98>:
.globl vector98
vector98:
  pushl $0
c01026a0:	6a 00                	push   $0x0
  pushl $98
c01026a2:	6a 62                	push   $0x62
  jmp __alltraps
c01026a4:	e9 05 07 00 00       	jmp    c0102dae <__alltraps>

c01026a9 <vector99>:
.globl vector99
vector99:
  pushl $0
c01026a9:	6a 00                	push   $0x0
  pushl $99
c01026ab:	6a 63                	push   $0x63
  jmp __alltraps
c01026ad:	e9 fc 06 00 00       	jmp    c0102dae <__alltraps>

c01026b2 <vector100>:
.globl vector100
vector100:
  pushl $0
c01026b2:	6a 00                	push   $0x0
  pushl $100
c01026b4:	6a 64                	push   $0x64
  jmp __alltraps
c01026b6:	e9 f3 06 00 00       	jmp    c0102dae <__alltraps>

c01026bb <vector101>:
.globl vector101
vector101:
  pushl $0
c01026bb:	6a 00                	push   $0x0
  pushl $101
c01026bd:	6a 65                	push   $0x65
  jmp __alltraps
c01026bf:	e9 ea 06 00 00       	jmp    c0102dae <__alltraps>

c01026c4 <vector102>:
.globl vector102
vector102:
  pushl $0
c01026c4:	6a 00                	push   $0x0
  pushl $102
c01026c6:	6a 66                	push   $0x66
  jmp __alltraps
c01026c8:	e9 e1 06 00 00       	jmp    c0102dae <__alltraps>

c01026cd <vector103>:
.globl vector103
vector103:
  pushl $0
c01026cd:	6a 00                	push   $0x0
  pushl $103
c01026cf:	6a 67                	push   $0x67
  jmp __alltraps
c01026d1:	e9 d8 06 00 00       	jmp    c0102dae <__alltraps>

c01026d6 <vector104>:
.globl vector104
vector104:
  pushl $0
c01026d6:	6a 00                	push   $0x0
  pushl $104
c01026d8:	6a 68                	push   $0x68
  jmp __alltraps
c01026da:	e9 cf 06 00 00       	jmp    c0102dae <__alltraps>

c01026df <vector105>:
.globl vector105
vector105:
  pushl $0
c01026df:	6a 00                	push   $0x0
  pushl $105
c01026e1:	6a 69                	push   $0x69
  jmp __alltraps
c01026e3:	e9 c6 06 00 00       	jmp    c0102dae <__alltraps>

c01026e8 <vector106>:
.globl vector106
vector106:
  pushl $0
c01026e8:	6a 00                	push   $0x0
  pushl $106
c01026ea:	6a 6a                	push   $0x6a
  jmp __alltraps
c01026ec:	e9 bd 06 00 00       	jmp    c0102dae <__alltraps>

c01026f1 <vector107>:
.globl vector107
vector107:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $107
c01026f3:	6a 6b                	push   $0x6b
  jmp __alltraps
c01026f5:	e9 b4 06 00 00       	jmp    c0102dae <__alltraps>

c01026fa <vector108>:
.globl vector108
vector108:
  pushl $0
c01026fa:	6a 00                	push   $0x0
  pushl $108
c01026fc:	6a 6c                	push   $0x6c
  jmp __alltraps
c01026fe:	e9 ab 06 00 00       	jmp    c0102dae <__alltraps>

c0102703 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102703:	6a 00                	push   $0x0
  pushl $109
c0102705:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102707:	e9 a2 06 00 00       	jmp    c0102dae <__alltraps>

c010270c <vector110>:
.globl vector110
vector110:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $110
c010270e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102710:	e9 99 06 00 00       	jmp    c0102dae <__alltraps>

c0102715 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $111
c0102717:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102719:	e9 90 06 00 00       	jmp    c0102dae <__alltraps>

c010271e <vector112>:
.globl vector112
vector112:
  pushl $0
c010271e:	6a 00                	push   $0x0
  pushl $112
c0102720:	6a 70                	push   $0x70
  jmp __alltraps
c0102722:	e9 87 06 00 00       	jmp    c0102dae <__alltraps>

c0102727 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102727:	6a 00                	push   $0x0
  pushl $113
c0102729:	6a 71                	push   $0x71
  jmp __alltraps
c010272b:	e9 7e 06 00 00       	jmp    c0102dae <__alltraps>

c0102730 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102730:	6a 00                	push   $0x0
  pushl $114
c0102732:	6a 72                	push   $0x72
  jmp __alltraps
c0102734:	e9 75 06 00 00       	jmp    c0102dae <__alltraps>

c0102739 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $115
c010273b:	6a 73                	push   $0x73
  jmp __alltraps
c010273d:	e9 6c 06 00 00       	jmp    c0102dae <__alltraps>

c0102742 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102742:	6a 00                	push   $0x0
  pushl $116
c0102744:	6a 74                	push   $0x74
  jmp __alltraps
c0102746:	e9 63 06 00 00       	jmp    c0102dae <__alltraps>

c010274b <vector117>:
.globl vector117
vector117:
  pushl $0
c010274b:	6a 00                	push   $0x0
  pushl $117
c010274d:	6a 75                	push   $0x75
  jmp __alltraps
c010274f:	e9 5a 06 00 00       	jmp    c0102dae <__alltraps>

c0102754 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102754:	6a 00                	push   $0x0
  pushl $118
c0102756:	6a 76                	push   $0x76
  jmp __alltraps
c0102758:	e9 51 06 00 00       	jmp    c0102dae <__alltraps>

c010275d <vector119>:
.globl vector119
vector119:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $119
c010275f:	6a 77                	push   $0x77
  jmp __alltraps
c0102761:	e9 48 06 00 00       	jmp    c0102dae <__alltraps>

c0102766 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102766:	6a 00                	push   $0x0
  pushl $120
c0102768:	6a 78                	push   $0x78
  jmp __alltraps
c010276a:	e9 3f 06 00 00       	jmp    c0102dae <__alltraps>

c010276f <vector121>:
.globl vector121
vector121:
  pushl $0
c010276f:	6a 00                	push   $0x0
  pushl $121
c0102771:	6a 79                	push   $0x79
  jmp __alltraps
c0102773:	e9 36 06 00 00       	jmp    c0102dae <__alltraps>

c0102778 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102778:	6a 00                	push   $0x0
  pushl $122
c010277a:	6a 7a                	push   $0x7a
  jmp __alltraps
c010277c:	e9 2d 06 00 00       	jmp    c0102dae <__alltraps>

c0102781 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $123
c0102783:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102785:	e9 24 06 00 00       	jmp    c0102dae <__alltraps>

c010278a <vector124>:
.globl vector124
vector124:
  pushl $0
c010278a:	6a 00                	push   $0x0
  pushl $124
c010278c:	6a 7c                	push   $0x7c
  jmp __alltraps
c010278e:	e9 1b 06 00 00       	jmp    c0102dae <__alltraps>

c0102793 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102793:	6a 00                	push   $0x0
  pushl $125
c0102795:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102797:	e9 12 06 00 00       	jmp    c0102dae <__alltraps>

c010279c <vector126>:
.globl vector126
vector126:
  pushl $0
c010279c:	6a 00                	push   $0x0
  pushl $126
c010279e:	6a 7e                	push   $0x7e
  jmp __alltraps
c01027a0:	e9 09 06 00 00       	jmp    c0102dae <__alltraps>

c01027a5 <vector127>:
.globl vector127
vector127:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $127
c01027a7:	6a 7f                	push   $0x7f
  jmp __alltraps
c01027a9:	e9 00 06 00 00       	jmp    c0102dae <__alltraps>

c01027ae <vector128>:
.globl vector128
vector128:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $128
c01027b0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01027b5:	e9 f4 05 00 00       	jmp    c0102dae <__alltraps>

c01027ba <vector129>:
.globl vector129
vector129:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $129
c01027bc:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01027c1:	e9 e8 05 00 00       	jmp    c0102dae <__alltraps>

c01027c6 <vector130>:
.globl vector130
vector130:
  pushl $0
c01027c6:	6a 00                	push   $0x0
  pushl $130
c01027c8:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01027cd:	e9 dc 05 00 00       	jmp    c0102dae <__alltraps>

c01027d2 <vector131>:
.globl vector131
vector131:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $131
c01027d4:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01027d9:	e9 d0 05 00 00       	jmp    c0102dae <__alltraps>

c01027de <vector132>:
.globl vector132
vector132:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $132
c01027e0:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01027e5:	e9 c4 05 00 00       	jmp    c0102dae <__alltraps>

c01027ea <vector133>:
.globl vector133
vector133:
  pushl $0
c01027ea:	6a 00                	push   $0x0
  pushl $133
c01027ec:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01027f1:	e9 b8 05 00 00       	jmp    c0102dae <__alltraps>

c01027f6 <vector134>:
.globl vector134
vector134:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $134
c01027f8:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01027fd:	e9 ac 05 00 00       	jmp    c0102dae <__alltraps>

c0102802 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $135
c0102804:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102809:	e9 a0 05 00 00       	jmp    c0102dae <__alltraps>

c010280e <vector136>:
.globl vector136
vector136:
  pushl $0
c010280e:	6a 00                	push   $0x0
  pushl $136
c0102810:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102815:	e9 94 05 00 00       	jmp    c0102dae <__alltraps>

c010281a <vector137>:
.globl vector137
vector137:
  pushl $0
c010281a:	6a 00                	push   $0x0
  pushl $137
c010281c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102821:	e9 88 05 00 00       	jmp    c0102dae <__alltraps>

c0102826 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $138
c0102828:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010282d:	e9 7c 05 00 00       	jmp    c0102dae <__alltraps>

c0102832 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102832:	6a 00                	push   $0x0
  pushl $139
c0102834:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102839:	e9 70 05 00 00       	jmp    c0102dae <__alltraps>

c010283e <vector140>:
.globl vector140
vector140:
  pushl $0
c010283e:	6a 00                	push   $0x0
  pushl $140
c0102840:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102845:	e9 64 05 00 00       	jmp    c0102dae <__alltraps>

c010284a <vector141>:
.globl vector141
vector141:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $141
c010284c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102851:	e9 58 05 00 00       	jmp    c0102dae <__alltraps>

c0102856 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102856:	6a 00                	push   $0x0
  pushl $142
c0102858:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010285d:	e9 4c 05 00 00       	jmp    c0102dae <__alltraps>

c0102862 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102862:	6a 00                	push   $0x0
  pushl $143
c0102864:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102869:	e9 40 05 00 00       	jmp    c0102dae <__alltraps>

c010286e <vector144>:
.globl vector144
vector144:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $144
c0102870:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102875:	e9 34 05 00 00       	jmp    c0102dae <__alltraps>

c010287a <vector145>:
.globl vector145
vector145:
  pushl $0
c010287a:	6a 00                	push   $0x0
  pushl $145
c010287c:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102881:	e9 28 05 00 00       	jmp    c0102dae <__alltraps>

c0102886 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102886:	6a 00                	push   $0x0
  pushl $146
c0102888:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010288d:	e9 1c 05 00 00       	jmp    c0102dae <__alltraps>

c0102892 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $147
c0102894:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102899:	e9 10 05 00 00       	jmp    c0102dae <__alltraps>

c010289e <vector148>:
.globl vector148
vector148:
  pushl $0
c010289e:	6a 00                	push   $0x0
  pushl $148
c01028a0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01028a5:	e9 04 05 00 00       	jmp    c0102dae <__alltraps>

c01028aa <vector149>:
.globl vector149
vector149:
  pushl $0
c01028aa:	6a 00                	push   $0x0
  pushl $149
c01028ac:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01028b1:	e9 f8 04 00 00       	jmp    c0102dae <__alltraps>

c01028b6 <vector150>:
.globl vector150
vector150:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $150
c01028b8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01028bd:	e9 ec 04 00 00       	jmp    c0102dae <__alltraps>

c01028c2 <vector151>:
.globl vector151
vector151:
  pushl $0
c01028c2:	6a 00                	push   $0x0
  pushl $151
c01028c4:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01028c9:	e9 e0 04 00 00       	jmp    c0102dae <__alltraps>

c01028ce <vector152>:
.globl vector152
vector152:
  pushl $0
c01028ce:	6a 00                	push   $0x0
  pushl $152
c01028d0:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01028d5:	e9 d4 04 00 00       	jmp    c0102dae <__alltraps>

c01028da <vector153>:
.globl vector153
vector153:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $153
c01028dc:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01028e1:	e9 c8 04 00 00       	jmp    c0102dae <__alltraps>

c01028e6 <vector154>:
.globl vector154
vector154:
  pushl $0
c01028e6:	6a 00                	push   $0x0
  pushl $154
c01028e8:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01028ed:	e9 bc 04 00 00       	jmp    c0102dae <__alltraps>

c01028f2 <vector155>:
.globl vector155
vector155:
  pushl $0
c01028f2:	6a 00                	push   $0x0
  pushl $155
c01028f4:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01028f9:	e9 b0 04 00 00       	jmp    c0102dae <__alltraps>

c01028fe <vector156>:
.globl vector156
vector156:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $156
c0102900:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102905:	e9 a4 04 00 00       	jmp    c0102dae <__alltraps>

c010290a <vector157>:
.globl vector157
vector157:
  pushl $0
c010290a:	6a 00                	push   $0x0
  pushl $157
c010290c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102911:	e9 98 04 00 00       	jmp    c0102dae <__alltraps>

c0102916 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102916:	6a 00                	push   $0x0
  pushl $158
c0102918:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010291d:	e9 8c 04 00 00       	jmp    c0102dae <__alltraps>

c0102922 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $159
c0102924:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102929:	e9 80 04 00 00       	jmp    c0102dae <__alltraps>

c010292e <vector160>:
.globl vector160
vector160:
  pushl $0
c010292e:	6a 00                	push   $0x0
  pushl $160
c0102930:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102935:	e9 74 04 00 00       	jmp    c0102dae <__alltraps>

c010293a <vector161>:
.globl vector161
vector161:
  pushl $0
c010293a:	6a 00                	push   $0x0
  pushl $161
c010293c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102941:	e9 68 04 00 00       	jmp    c0102dae <__alltraps>

c0102946 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $162
c0102948:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010294d:	e9 5c 04 00 00       	jmp    c0102dae <__alltraps>

c0102952 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102952:	6a 00                	push   $0x0
  pushl $163
c0102954:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102959:	e9 50 04 00 00       	jmp    c0102dae <__alltraps>

c010295e <vector164>:
.globl vector164
vector164:
  pushl $0
c010295e:	6a 00                	push   $0x0
  pushl $164
c0102960:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102965:	e9 44 04 00 00       	jmp    c0102dae <__alltraps>

c010296a <vector165>:
.globl vector165
vector165:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $165
c010296c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102971:	e9 38 04 00 00       	jmp    c0102dae <__alltraps>

c0102976 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102976:	6a 00                	push   $0x0
  pushl $166
c0102978:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010297d:	e9 2c 04 00 00       	jmp    c0102dae <__alltraps>

c0102982 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102982:	6a 00                	push   $0x0
  pushl $167
c0102984:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102989:	e9 20 04 00 00       	jmp    c0102dae <__alltraps>

c010298e <vector168>:
.globl vector168
vector168:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $168
c0102990:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102995:	e9 14 04 00 00       	jmp    c0102dae <__alltraps>

c010299a <vector169>:
.globl vector169
vector169:
  pushl $0
c010299a:	6a 00                	push   $0x0
  pushl $169
c010299c:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01029a1:	e9 08 04 00 00       	jmp    c0102dae <__alltraps>

c01029a6 <vector170>:
.globl vector170
vector170:
  pushl $0
c01029a6:	6a 00                	push   $0x0
  pushl $170
c01029a8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01029ad:	e9 fc 03 00 00       	jmp    c0102dae <__alltraps>

c01029b2 <vector171>:
.globl vector171
vector171:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $171
c01029b4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01029b9:	e9 f0 03 00 00       	jmp    c0102dae <__alltraps>

c01029be <vector172>:
.globl vector172
vector172:
  pushl $0
c01029be:	6a 00                	push   $0x0
  pushl $172
c01029c0:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01029c5:	e9 e4 03 00 00       	jmp    c0102dae <__alltraps>

c01029ca <vector173>:
.globl vector173
vector173:
  pushl $0
c01029ca:	6a 00                	push   $0x0
  pushl $173
c01029cc:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01029d1:	e9 d8 03 00 00       	jmp    c0102dae <__alltraps>

c01029d6 <vector174>:
.globl vector174
vector174:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $174
c01029d8:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01029dd:	e9 cc 03 00 00       	jmp    c0102dae <__alltraps>

c01029e2 <vector175>:
.globl vector175
vector175:
  pushl $0
c01029e2:	6a 00                	push   $0x0
  pushl $175
c01029e4:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01029e9:	e9 c0 03 00 00       	jmp    c0102dae <__alltraps>

c01029ee <vector176>:
.globl vector176
vector176:
  pushl $0
c01029ee:	6a 00                	push   $0x0
  pushl $176
c01029f0:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01029f5:	e9 b4 03 00 00       	jmp    c0102dae <__alltraps>

c01029fa <vector177>:
.globl vector177
vector177:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $177
c01029fc:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102a01:	e9 a8 03 00 00       	jmp    c0102dae <__alltraps>

c0102a06 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102a06:	6a 00                	push   $0x0
  pushl $178
c0102a08:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102a0d:	e9 9c 03 00 00       	jmp    c0102dae <__alltraps>

c0102a12 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102a12:	6a 00                	push   $0x0
  pushl $179
c0102a14:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102a19:	e9 90 03 00 00       	jmp    c0102dae <__alltraps>

c0102a1e <vector180>:
.globl vector180
vector180:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $180
c0102a20:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102a25:	e9 84 03 00 00       	jmp    c0102dae <__alltraps>

c0102a2a <vector181>:
.globl vector181
vector181:
  pushl $0
c0102a2a:	6a 00                	push   $0x0
  pushl $181
c0102a2c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102a31:	e9 78 03 00 00       	jmp    c0102dae <__alltraps>

c0102a36 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102a36:	6a 00                	push   $0x0
  pushl $182
c0102a38:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102a3d:	e9 6c 03 00 00       	jmp    c0102dae <__alltraps>

c0102a42 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $183
c0102a44:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102a49:	e9 60 03 00 00       	jmp    c0102dae <__alltraps>

c0102a4e <vector184>:
.globl vector184
vector184:
  pushl $0
c0102a4e:	6a 00                	push   $0x0
  pushl $184
c0102a50:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102a55:	e9 54 03 00 00       	jmp    c0102dae <__alltraps>

c0102a5a <vector185>:
.globl vector185
vector185:
  pushl $0
c0102a5a:	6a 00                	push   $0x0
  pushl $185
c0102a5c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102a61:	e9 48 03 00 00       	jmp    c0102dae <__alltraps>

c0102a66 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $186
c0102a68:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102a6d:	e9 3c 03 00 00       	jmp    c0102dae <__alltraps>

c0102a72 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102a72:	6a 00                	push   $0x0
  pushl $187
c0102a74:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102a79:	e9 30 03 00 00       	jmp    c0102dae <__alltraps>

c0102a7e <vector188>:
.globl vector188
vector188:
  pushl $0
c0102a7e:	6a 00                	push   $0x0
  pushl $188
c0102a80:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102a85:	e9 24 03 00 00       	jmp    c0102dae <__alltraps>

c0102a8a <vector189>:
.globl vector189
vector189:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $189
c0102a8c:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102a91:	e9 18 03 00 00       	jmp    c0102dae <__alltraps>

c0102a96 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102a96:	6a 00                	push   $0x0
  pushl $190
c0102a98:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102a9d:	e9 0c 03 00 00       	jmp    c0102dae <__alltraps>

c0102aa2 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102aa2:	6a 00                	push   $0x0
  pushl $191
c0102aa4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102aa9:	e9 00 03 00 00       	jmp    c0102dae <__alltraps>

c0102aae <vector192>:
.globl vector192
vector192:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $192
c0102ab0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102ab5:	e9 f4 02 00 00       	jmp    c0102dae <__alltraps>

c0102aba <vector193>:
.globl vector193
vector193:
  pushl $0
c0102aba:	6a 00                	push   $0x0
  pushl $193
c0102abc:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102ac1:	e9 e8 02 00 00       	jmp    c0102dae <__alltraps>

c0102ac6 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102ac6:	6a 00                	push   $0x0
  pushl $194
c0102ac8:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102acd:	e9 dc 02 00 00       	jmp    c0102dae <__alltraps>

c0102ad2 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $195
c0102ad4:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102ad9:	e9 d0 02 00 00       	jmp    c0102dae <__alltraps>

c0102ade <vector196>:
.globl vector196
vector196:
  pushl $0
c0102ade:	6a 00                	push   $0x0
  pushl $196
c0102ae0:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102ae5:	e9 c4 02 00 00       	jmp    c0102dae <__alltraps>

c0102aea <vector197>:
.globl vector197
vector197:
  pushl $0
c0102aea:	6a 00                	push   $0x0
  pushl $197
c0102aec:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102af1:	e9 b8 02 00 00       	jmp    c0102dae <__alltraps>

c0102af6 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $198
c0102af8:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102afd:	e9 ac 02 00 00       	jmp    c0102dae <__alltraps>

c0102b02 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102b02:	6a 00                	push   $0x0
  pushl $199
c0102b04:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102b09:	e9 a0 02 00 00       	jmp    c0102dae <__alltraps>

c0102b0e <vector200>:
.globl vector200
vector200:
  pushl $0
c0102b0e:	6a 00                	push   $0x0
  pushl $200
c0102b10:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102b15:	e9 94 02 00 00       	jmp    c0102dae <__alltraps>

c0102b1a <vector201>:
.globl vector201
vector201:
  pushl $0
c0102b1a:	6a 00                	push   $0x0
  pushl $201
c0102b1c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102b21:	e9 88 02 00 00       	jmp    c0102dae <__alltraps>

c0102b26 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102b26:	6a 00                	push   $0x0
  pushl $202
c0102b28:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102b2d:	e9 7c 02 00 00       	jmp    c0102dae <__alltraps>

c0102b32 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102b32:	6a 00                	push   $0x0
  pushl $203
c0102b34:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102b39:	e9 70 02 00 00       	jmp    c0102dae <__alltraps>

c0102b3e <vector204>:
.globl vector204
vector204:
  pushl $0
c0102b3e:	6a 00                	push   $0x0
  pushl $204
c0102b40:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102b45:	e9 64 02 00 00       	jmp    c0102dae <__alltraps>

c0102b4a <vector205>:
.globl vector205
vector205:
  pushl $0
c0102b4a:	6a 00                	push   $0x0
  pushl $205
c0102b4c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102b51:	e9 58 02 00 00       	jmp    c0102dae <__alltraps>

c0102b56 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102b56:	6a 00                	push   $0x0
  pushl $206
c0102b58:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102b5d:	e9 4c 02 00 00       	jmp    c0102dae <__alltraps>

c0102b62 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102b62:	6a 00                	push   $0x0
  pushl $207
c0102b64:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102b69:	e9 40 02 00 00       	jmp    c0102dae <__alltraps>

c0102b6e <vector208>:
.globl vector208
vector208:
  pushl $0
c0102b6e:	6a 00                	push   $0x0
  pushl $208
c0102b70:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102b75:	e9 34 02 00 00       	jmp    c0102dae <__alltraps>

c0102b7a <vector209>:
.globl vector209
vector209:
  pushl $0
c0102b7a:	6a 00                	push   $0x0
  pushl $209
c0102b7c:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102b81:	e9 28 02 00 00       	jmp    c0102dae <__alltraps>

c0102b86 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $210
c0102b88:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102b8d:	e9 1c 02 00 00       	jmp    c0102dae <__alltraps>

c0102b92 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102b92:	6a 00                	push   $0x0
  pushl $211
c0102b94:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102b99:	e9 10 02 00 00       	jmp    c0102dae <__alltraps>

c0102b9e <vector212>:
.globl vector212
vector212:
  pushl $0
c0102b9e:	6a 00                	push   $0x0
  pushl $212
c0102ba0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ba5:	e9 04 02 00 00       	jmp    c0102dae <__alltraps>

c0102baa <vector213>:
.globl vector213
vector213:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $213
c0102bac:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102bb1:	e9 f8 01 00 00       	jmp    c0102dae <__alltraps>

c0102bb6 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102bb6:	6a 00                	push   $0x0
  pushl $214
c0102bb8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102bbd:	e9 ec 01 00 00       	jmp    c0102dae <__alltraps>

c0102bc2 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102bc2:	6a 00                	push   $0x0
  pushl $215
c0102bc4:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102bc9:	e9 e0 01 00 00       	jmp    c0102dae <__alltraps>

c0102bce <vector216>:
.globl vector216
vector216:
  pushl $0
c0102bce:	6a 00                	push   $0x0
  pushl $216
c0102bd0:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102bd5:	e9 d4 01 00 00       	jmp    c0102dae <__alltraps>

c0102bda <vector217>:
.globl vector217
vector217:
  pushl $0
c0102bda:	6a 00                	push   $0x0
  pushl $217
c0102bdc:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102be1:	e9 c8 01 00 00       	jmp    c0102dae <__alltraps>

c0102be6 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102be6:	6a 00                	push   $0x0
  pushl $218
c0102be8:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102bed:	e9 bc 01 00 00       	jmp    c0102dae <__alltraps>

c0102bf2 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102bf2:	6a 00                	push   $0x0
  pushl $219
c0102bf4:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102bf9:	e9 b0 01 00 00       	jmp    c0102dae <__alltraps>

c0102bfe <vector220>:
.globl vector220
vector220:
  pushl $0
c0102bfe:	6a 00                	push   $0x0
  pushl $220
c0102c00:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102c05:	e9 a4 01 00 00       	jmp    c0102dae <__alltraps>

c0102c0a <vector221>:
.globl vector221
vector221:
  pushl $0
c0102c0a:	6a 00                	push   $0x0
  pushl $221
c0102c0c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102c11:	e9 98 01 00 00       	jmp    c0102dae <__alltraps>

c0102c16 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102c16:	6a 00                	push   $0x0
  pushl $222
c0102c18:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102c1d:	e9 8c 01 00 00       	jmp    c0102dae <__alltraps>

c0102c22 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102c22:	6a 00                	push   $0x0
  pushl $223
c0102c24:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102c29:	e9 80 01 00 00       	jmp    c0102dae <__alltraps>

c0102c2e <vector224>:
.globl vector224
vector224:
  pushl $0
c0102c2e:	6a 00                	push   $0x0
  pushl $224
c0102c30:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102c35:	e9 74 01 00 00       	jmp    c0102dae <__alltraps>

c0102c3a <vector225>:
.globl vector225
vector225:
  pushl $0
c0102c3a:	6a 00                	push   $0x0
  pushl $225
c0102c3c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102c41:	e9 68 01 00 00       	jmp    c0102dae <__alltraps>

c0102c46 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102c46:	6a 00                	push   $0x0
  pushl $226
c0102c48:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102c4d:	e9 5c 01 00 00       	jmp    c0102dae <__alltraps>

c0102c52 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102c52:	6a 00                	push   $0x0
  pushl $227
c0102c54:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102c59:	e9 50 01 00 00       	jmp    c0102dae <__alltraps>

c0102c5e <vector228>:
.globl vector228
vector228:
  pushl $0
c0102c5e:	6a 00                	push   $0x0
  pushl $228
c0102c60:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102c65:	e9 44 01 00 00       	jmp    c0102dae <__alltraps>

c0102c6a <vector229>:
.globl vector229
vector229:
  pushl $0
c0102c6a:	6a 00                	push   $0x0
  pushl $229
c0102c6c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102c71:	e9 38 01 00 00       	jmp    c0102dae <__alltraps>

c0102c76 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102c76:	6a 00                	push   $0x0
  pushl $230
c0102c78:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102c7d:	e9 2c 01 00 00       	jmp    c0102dae <__alltraps>

c0102c82 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102c82:	6a 00                	push   $0x0
  pushl $231
c0102c84:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102c89:	e9 20 01 00 00       	jmp    c0102dae <__alltraps>

c0102c8e <vector232>:
.globl vector232
vector232:
  pushl $0
c0102c8e:	6a 00                	push   $0x0
  pushl $232
c0102c90:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102c95:	e9 14 01 00 00       	jmp    c0102dae <__alltraps>

c0102c9a <vector233>:
.globl vector233
vector233:
  pushl $0
c0102c9a:	6a 00                	push   $0x0
  pushl $233
c0102c9c:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102ca1:	e9 08 01 00 00       	jmp    c0102dae <__alltraps>

c0102ca6 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102ca6:	6a 00                	push   $0x0
  pushl $234
c0102ca8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102cad:	e9 fc 00 00 00       	jmp    c0102dae <__alltraps>

c0102cb2 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102cb2:	6a 00                	push   $0x0
  pushl $235
c0102cb4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102cb9:	e9 f0 00 00 00       	jmp    c0102dae <__alltraps>

c0102cbe <vector236>:
.globl vector236
vector236:
  pushl $0
c0102cbe:	6a 00                	push   $0x0
  pushl $236
c0102cc0:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102cc5:	e9 e4 00 00 00       	jmp    c0102dae <__alltraps>

c0102cca <vector237>:
.globl vector237
vector237:
  pushl $0
c0102cca:	6a 00                	push   $0x0
  pushl $237
c0102ccc:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102cd1:	e9 d8 00 00 00       	jmp    c0102dae <__alltraps>

c0102cd6 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102cd6:	6a 00                	push   $0x0
  pushl $238
c0102cd8:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102cdd:	e9 cc 00 00 00       	jmp    c0102dae <__alltraps>

c0102ce2 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102ce2:	6a 00                	push   $0x0
  pushl $239
c0102ce4:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102ce9:	e9 c0 00 00 00       	jmp    c0102dae <__alltraps>

c0102cee <vector240>:
.globl vector240
vector240:
  pushl $0
c0102cee:	6a 00                	push   $0x0
  pushl $240
c0102cf0:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102cf5:	e9 b4 00 00 00       	jmp    c0102dae <__alltraps>

c0102cfa <vector241>:
.globl vector241
vector241:
  pushl $0
c0102cfa:	6a 00                	push   $0x0
  pushl $241
c0102cfc:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102d01:	e9 a8 00 00 00       	jmp    c0102dae <__alltraps>

c0102d06 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102d06:	6a 00                	push   $0x0
  pushl $242
c0102d08:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102d0d:	e9 9c 00 00 00       	jmp    c0102dae <__alltraps>

c0102d12 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102d12:	6a 00                	push   $0x0
  pushl $243
c0102d14:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102d19:	e9 90 00 00 00       	jmp    c0102dae <__alltraps>

c0102d1e <vector244>:
.globl vector244
vector244:
  pushl $0
c0102d1e:	6a 00                	push   $0x0
  pushl $244
c0102d20:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102d25:	e9 84 00 00 00       	jmp    c0102dae <__alltraps>

c0102d2a <vector245>:
.globl vector245
vector245:
  pushl $0
c0102d2a:	6a 00                	push   $0x0
  pushl $245
c0102d2c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102d31:	e9 78 00 00 00       	jmp    c0102dae <__alltraps>

c0102d36 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102d36:	6a 00                	push   $0x0
  pushl $246
c0102d38:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102d3d:	e9 6c 00 00 00       	jmp    c0102dae <__alltraps>

c0102d42 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102d42:	6a 00                	push   $0x0
  pushl $247
c0102d44:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102d49:	e9 60 00 00 00       	jmp    c0102dae <__alltraps>

c0102d4e <vector248>:
.globl vector248
vector248:
  pushl $0
c0102d4e:	6a 00                	push   $0x0
  pushl $248
c0102d50:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102d55:	e9 54 00 00 00       	jmp    c0102dae <__alltraps>

c0102d5a <vector249>:
.globl vector249
vector249:
  pushl $0
c0102d5a:	6a 00                	push   $0x0
  pushl $249
c0102d5c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102d61:	e9 48 00 00 00       	jmp    c0102dae <__alltraps>

c0102d66 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102d66:	6a 00                	push   $0x0
  pushl $250
c0102d68:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102d6d:	e9 3c 00 00 00       	jmp    c0102dae <__alltraps>

c0102d72 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102d72:	6a 00                	push   $0x0
  pushl $251
c0102d74:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102d79:	e9 30 00 00 00       	jmp    c0102dae <__alltraps>

c0102d7e <vector252>:
.globl vector252
vector252:
  pushl $0
c0102d7e:	6a 00                	push   $0x0
  pushl $252
c0102d80:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102d85:	e9 24 00 00 00       	jmp    c0102dae <__alltraps>

c0102d8a <vector253>:
.globl vector253
vector253:
  pushl $0
c0102d8a:	6a 00                	push   $0x0
  pushl $253
c0102d8c:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102d91:	e9 18 00 00 00       	jmp    c0102dae <__alltraps>

c0102d96 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102d96:	6a 00                	push   $0x0
  pushl $254
c0102d98:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102d9d:	e9 0c 00 00 00       	jmp    c0102dae <__alltraps>

c0102da2 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102da2:	6a 00                	push   $0x0
  pushl $255
c0102da4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102da9:	e9 00 00 00 00       	jmp    c0102dae <__alltraps>

c0102dae <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102dae:	1e                   	push   %ds
    pushl %es
c0102daf:	06                   	push   %es
    pushl %fs
c0102db0:	0f a0                	push   %fs
    pushl %gs
c0102db2:	0f a8                	push   %gs
    pushal
c0102db4:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102db5:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102dba:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102dbc:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102dbe:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102dbf:	e8 60 f5 ff ff       	call   c0102324 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102dc4:	5c                   	pop    %esp

c0102dc5 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102dc5:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102dc6:	0f a9                	pop    %gs
    popl %fs
c0102dc8:	0f a1                	pop    %fs
    popl %es
c0102dca:	07                   	pop    %es
    popl %ds
c0102dcb:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102dcc:	83 c4 08             	add    $0x8,%esp
    iret
c0102dcf:	cf                   	iret   

c0102dd0 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102dd0:	55                   	push   %ebp
c0102dd1:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102dd3:	a1 78 ff 11 c0       	mov    0xc011ff78,%eax
c0102dd8:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ddb:	29 c2                	sub    %eax,%edx
c0102ddd:	89 d0                	mov    %edx,%eax
c0102ddf:	c1 f8 02             	sar    $0x2,%eax
c0102de2:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102de8:	5d                   	pop    %ebp
c0102de9:	c3                   	ret    

c0102dea <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102dea:	55                   	push   %ebp
c0102deb:	89 e5                	mov    %esp,%ebp
c0102ded:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102df0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102df3:	89 04 24             	mov    %eax,(%esp)
c0102df6:	e8 d5 ff ff ff       	call   c0102dd0 <page2ppn>
c0102dfb:	c1 e0 0c             	shl    $0xc,%eax
}
c0102dfe:	c9                   	leave  
c0102dff:	c3                   	ret    

c0102e00 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102e00:	55                   	push   %ebp
c0102e01:	89 e5                	mov    %esp,%ebp
c0102e03:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102e06:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e09:	c1 e8 0c             	shr    $0xc,%eax
c0102e0c:	89 c2                	mov    %eax,%edx
c0102e0e:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c0102e13:	39 c2                	cmp    %eax,%edx
c0102e15:	72 1c                	jb     c0102e33 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102e17:	c7 44 24 08 50 7a 10 	movl   $0xc0107a50,0x8(%esp)
c0102e1e:	c0 
c0102e1f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102e26:	00 
c0102e27:	c7 04 24 6f 7a 10 c0 	movl   $0xc0107a6f,(%esp)
c0102e2e:	e8 fe d5 ff ff       	call   c0100431 <__panic>
    }
    return &pages[PPN(pa)];
c0102e33:	8b 0d 78 ff 11 c0    	mov    0xc011ff78,%ecx
c0102e39:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e3c:	c1 e8 0c             	shr    $0xc,%eax
c0102e3f:	89 c2                	mov    %eax,%edx
c0102e41:	89 d0                	mov    %edx,%eax
c0102e43:	c1 e0 02             	shl    $0x2,%eax
c0102e46:	01 d0                	add    %edx,%eax
c0102e48:	c1 e0 02             	shl    $0x2,%eax
c0102e4b:	01 c8                	add    %ecx,%eax
}
c0102e4d:	c9                   	leave  
c0102e4e:	c3                   	ret    

c0102e4f <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102e4f:	55                   	push   %ebp
c0102e50:	89 e5                	mov    %esp,%ebp
c0102e52:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e58:	89 04 24             	mov    %eax,(%esp)
c0102e5b:	e8 8a ff ff ff       	call   c0102dea <page2pa>
c0102e60:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e66:	c1 e8 0c             	shr    $0xc,%eax
c0102e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102e6c:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c0102e71:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102e74:	72 23                	jb     c0102e99 <page2kva+0x4a>
c0102e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e7d:	c7 44 24 08 80 7a 10 	movl   $0xc0107a80,0x8(%esp)
c0102e84:	c0 
c0102e85:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102e8c:	00 
c0102e8d:	c7 04 24 6f 7a 10 c0 	movl   $0xc0107a6f,(%esp)
c0102e94:	e8 98 d5 ff ff       	call   c0100431 <__panic>
c0102e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e9c:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102ea1:	c9                   	leave  
c0102ea2:	c3                   	ret    

c0102ea3 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102ea3:	55                   	push   %ebp
c0102ea4:	89 e5                	mov    %esp,%ebp
c0102ea6:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102ea9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eac:	83 e0 01             	and    $0x1,%eax
c0102eaf:	85 c0                	test   %eax,%eax
c0102eb1:	75 1c                	jne    c0102ecf <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102eb3:	c7 44 24 08 a4 7a 10 	movl   $0xc0107aa4,0x8(%esp)
c0102eba:	c0 
c0102ebb:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102ec2:	00 
c0102ec3:	c7 04 24 6f 7a 10 c0 	movl   $0xc0107a6f,(%esp)
c0102eca:	e8 62 d5 ff ff       	call   c0100431 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ed2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102ed7:	89 04 24             	mov    %eax,(%esp)
c0102eda:	e8 21 ff ff ff       	call   c0102e00 <pa2page>
}
c0102edf:	c9                   	leave  
c0102ee0:	c3                   	ret    

c0102ee1 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102ee1:	55                   	push   %ebp
c0102ee2:	89 e5                	mov    %esp,%ebp
c0102ee4:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102ee7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102eef:	89 04 24             	mov    %eax,(%esp)
c0102ef2:	e8 09 ff ff ff       	call   c0102e00 <pa2page>
}
c0102ef7:	c9                   	leave  
c0102ef8:	c3                   	ret    

c0102ef9 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102ef9:	55                   	push   %ebp
c0102efa:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102efc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eff:	8b 00                	mov    (%eax),%eax
}
c0102f01:	5d                   	pop    %ebp
c0102f02:	c3                   	ret    

c0102f03 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102f03:	55                   	push   %ebp
c0102f04:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f09:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102f0c:	89 10                	mov    %edx,(%eax)
}
c0102f0e:	90                   	nop
c0102f0f:	5d                   	pop    %ebp
c0102f10:	c3                   	ret    

c0102f11 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102f11:	55                   	push   %ebp
c0102f12:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f17:	8b 00                	mov    (%eax),%eax
c0102f19:	8d 50 01             	lea    0x1(%eax),%edx
c0102f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f1f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102f21:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f24:	8b 00                	mov    (%eax),%eax
}
c0102f26:	5d                   	pop    %ebp
c0102f27:	c3                   	ret    

c0102f28 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102f28:	55                   	push   %ebp
c0102f29:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f2e:	8b 00                	mov    (%eax),%eax
c0102f30:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102f33:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f36:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102f38:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f3b:	8b 00                	mov    (%eax),%eax
}
c0102f3d:	5d                   	pop    %ebp
c0102f3e:	c3                   	ret    

c0102f3f <__intr_save>:
__intr_save(void) {
c0102f3f:	55                   	push   %ebp
c0102f40:	89 e5                	mov    %esp,%ebp
c0102f42:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102f45:	9c                   	pushf  
c0102f46:	58                   	pop    %eax
c0102f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102f4d:	25 00 02 00 00       	and    $0x200,%eax
c0102f52:	85 c0                	test   %eax,%eax
c0102f54:	74 0c                	je     c0102f62 <__intr_save+0x23>
        intr_disable();
c0102f56:	e8 2a ea ff ff       	call   c0101985 <intr_disable>
        return 1;
c0102f5b:	b8 01 00 00 00       	mov    $0x1,%eax
c0102f60:	eb 05                	jmp    c0102f67 <__intr_save+0x28>
    return 0;
c0102f62:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102f67:	c9                   	leave  
c0102f68:	c3                   	ret    

c0102f69 <__intr_restore>:
__intr_restore(bool flag) {
c0102f69:	55                   	push   %ebp
c0102f6a:	89 e5                	mov    %esp,%ebp
c0102f6c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102f6f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102f73:	74 05                	je     c0102f7a <__intr_restore+0x11>
        intr_enable();
c0102f75:	e8 ff e9 ff ff       	call   c0101979 <intr_enable>
}
c0102f7a:	90                   	nop
c0102f7b:	c9                   	leave  
c0102f7c:	c3                   	ret    

c0102f7d <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102f7d:	55                   	push   %ebp
c0102f7e:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102f80:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f83:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102f86:	b8 23 00 00 00       	mov    $0x23,%eax
c0102f8b:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102f8d:	b8 23 00 00 00       	mov    $0x23,%eax
c0102f92:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102f94:	b8 10 00 00 00       	mov    $0x10,%eax
c0102f99:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102f9b:	b8 10 00 00 00       	mov    $0x10,%eax
c0102fa0:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102fa2:	b8 10 00 00 00       	mov    $0x10,%eax
c0102fa7:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102fa9:	ea b0 2f 10 c0 08 00 	ljmp   $0x8,$0xc0102fb0
}
c0102fb0:	90                   	nop
c0102fb1:	5d                   	pop    %ebp
c0102fb2:	c3                   	ret    

c0102fb3 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102fb3:	f3 0f 1e fb          	endbr32 
c0102fb7:	55                   	push   %ebp
c0102fb8:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102fba:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fbd:	a3 a4 fe 11 c0       	mov    %eax,0xc011fea4
}
c0102fc2:	90                   	nop
c0102fc3:	5d                   	pop    %ebp
c0102fc4:	c3                   	ret    

c0102fc5 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102fc5:	f3 0f 1e fb          	endbr32 
c0102fc9:	55                   	push   %ebp
c0102fca:	89 e5                	mov    %esp,%ebp
c0102fcc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102fcf:	b8 00 c0 11 c0       	mov    $0xc011c000,%eax
c0102fd4:	89 04 24             	mov    %eax,(%esp)
c0102fd7:	e8 d7 ff ff ff       	call   c0102fb3 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102fdc:	66 c7 05 a8 fe 11 c0 	movw   $0x10,0xc011fea8
c0102fe3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102fe5:	66 c7 05 28 ca 11 c0 	movw   $0x68,0xc011ca28
c0102fec:	68 00 
c0102fee:	b8 a0 fe 11 c0       	mov    $0xc011fea0,%eax
c0102ff3:	0f b7 c0             	movzwl %ax,%eax
c0102ff6:	66 a3 2a ca 11 c0    	mov    %ax,0xc011ca2a
c0102ffc:	b8 a0 fe 11 c0       	mov    $0xc011fea0,%eax
c0103001:	c1 e8 10             	shr    $0x10,%eax
c0103004:	a2 2c ca 11 c0       	mov    %al,0xc011ca2c
c0103009:	0f b6 05 2d ca 11 c0 	movzbl 0xc011ca2d,%eax
c0103010:	24 f0                	and    $0xf0,%al
c0103012:	0c 09                	or     $0x9,%al
c0103014:	a2 2d ca 11 c0       	mov    %al,0xc011ca2d
c0103019:	0f b6 05 2d ca 11 c0 	movzbl 0xc011ca2d,%eax
c0103020:	24 ef                	and    $0xef,%al
c0103022:	a2 2d ca 11 c0       	mov    %al,0xc011ca2d
c0103027:	0f b6 05 2d ca 11 c0 	movzbl 0xc011ca2d,%eax
c010302e:	24 9f                	and    $0x9f,%al
c0103030:	a2 2d ca 11 c0       	mov    %al,0xc011ca2d
c0103035:	0f b6 05 2d ca 11 c0 	movzbl 0xc011ca2d,%eax
c010303c:	0c 80                	or     $0x80,%al
c010303e:	a2 2d ca 11 c0       	mov    %al,0xc011ca2d
c0103043:	0f b6 05 2e ca 11 c0 	movzbl 0xc011ca2e,%eax
c010304a:	24 f0                	and    $0xf0,%al
c010304c:	a2 2e ca 11 c0       	mov    %al,0xc011ca2e
c0103051:	0f b6 05 2e ca 11 c0 	movzbl 0xc011ca2e,%eax
c0103058:	24 ef                	and    $0xef,%al
c010305a:	a2 2e ca 11 c0       	mov    %al,0xc011ca2e
c010305f:	0f b6 05 2e ca 11 c0 	movzbl 0xc011ca2e,%eax
c0103066:	24 df                	and    $0xdf,%al
c0103068:	a2 2e ca 11 c0       	mov    %al,0xc011ca2e
c010306d:	0f b6 05 2e ca 11 c0 	movzbl 0xc011ca2e,%eax
c0103074:	0c 40                	or     $0x40,%al
c0103076:	a2 2e ca 11 c0       	mov    %al,0xc011ca2e
c010307b:	0f b6 05 2e ca 11 c0 	movzbl 0xc011ca2e,%eax
c0103082:	24 7f                	and    $0x7f,%al
c0103084:	a2 2e ca 11 c0       	mov    %al,0xc011ca2e
c0103089:	b8 a0 fe 11 c0       	mov    $0xc011fea0,%eax
c010308e:	c1 e8 18             	shr    $0x18,%eax
c0103091:	a2 2f ca 11 c0       	mov    %al,0xc011ca2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103096:	c7 04 24 30 ca 11 c0 	movl   $0xc011ca30,(%esp)
c010309d:	e8 db fe ff ff       	call   c0102f7d <lgdt>
c01030a2:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01030a8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01030ac:	0f 00 d8             	ltr    %ax
}
c01030af:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01030b0:	90                   	nop
c01030b1:	c9                   	leave  
c01030b2:	c3                   	ret    

c01030b3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01030b3:	f3 0f 1e fb          	endbr32 
c01030b7:	55                   	push   %ebp
c01030b8:	89 e5                	mov    %esp,%ebp
c01030ba:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &default_pmm_manager;
    pmm_manager= &buddy_pmm_manager;
c01030bd:	c7 05 70 ff 11 c0 d4 	movl   $0xc01086d4,0xc011ff70
c01030c4:	86 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01030c7:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c01030cc:	8b 00                	mov    (%eax),%eax
c01030ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01030d2:	c7 04 24 d0 7a 10 c0 	movl   $0xc0107ad0,(%esp)
c01030d9:	e8 e7 d1 ff ff       	call   c01002c5 <cprintf>
    pmm_manager->init();
c01030de:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c01030e3:	8b 40 04             	mov    0x4(%eax),%eax
c01030e6:	ff d0                	call   *%eax
}
c01030e8:	90                   	nop
c01030e9:	c9                   	leave  
c01030ea:	c3                   	ret    

c01030eb <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c01030eb:	f3 0f 1e fb          	endbr32 
c01030ef:	55                   	push   %ebp
c01030f0:	89 e5                	mov    %esp,%ebp
c01030f2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01030f5:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c01030fa:	8b 40 08             	mov    0x8(%eax),%eax
c01030fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103100:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103104:	8b 55 08             	mov    0x8(%ebp),%edx
c0103107:	89 14 24             	mov    %edx,(%esp)
c010310a:	ff d0                	call   *%eax
}
c010310c:	90                   	nop
c010310d:	c9                   	leave  
c010310e:	c3                   	ret    

c010310f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010310f:	f3 0f 1e fb          	endbr32 
c0103113:	55                   	push   %ebp
c0103114:	89 e5                	mov    %esp,%ebp
c0103116:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103119:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103120:	e8 1a fe ff ff       	call   c0102f3f <__intr_save>
c0103125:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103128:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c010312d:	8b 40 0c             	mov    0xc(%eax),%eax
c0103130:	8b 55 08             	mov    0x8(%ebp),%edx
c0103133:	89 14 24             	mov    %edx,(%esp)
c0103136:	ff d0                	call   *%eax
c0103138:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c010313b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010313e:	89 04 24             	mov    %eax,(%esp)
c0103141:	e8 23 fe ff ff       	call   c0102f69 <__intr_restore>
    return page;
c0103146:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103149:	c9                   	leave  
c010314a:	c3                   	ret    

c010314b <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c010314b:	f3 0f 1e fb          	endbr32 
c010314f:	55                   	push   %ebp
c0103150:	89 e5                	mov    %esp,%ebp
c0103152:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103155:	e8 e5 fd ff ff       	call   c0102f3f <__intr_save>
c010315a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c010315d:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c0103162:	8b 40 10             	mov    0x10(%eax),%eax
c0103165:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103168:	89 54 24 04          	mov    %edx,0x4(%esp)
c010316c:	8b 55 08             	mov    0x8(%ebp),%edx
c010316f:	89 14 24             	mov    %edx,(%esp)
c0103172:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103174:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103177:	89 04 24             	mov    %eax,(%esp)
c010317a:	e8 ea fd ff ff       	call   c0102f69 <__intr_restore>
}
c010317f:	90                   	nop
c0103180:	c9                   	leave  
c0103181:	c3                   	ret    

c0103182 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103182:	f3 0f 1e fb          	endbr32 
c0103186:	55                   	push   %ebp
c0103187:	89 e5                	mov    %esp,%ebp
c0103189:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010318c:	e8 ae fd ff ff       	call   c0102f3f <__intr_save>
c0103191:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103194:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c0103199:	8b 40 14             	mov    0x14(%eax),%eax
c010319c:	ff d0                	call   *%eax
c010319e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01031a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a4:	89 04 24             	mov    %eax,(%esp)
c01031a7:	e8 bd fd ff ff       	call   c0102f69 <__intr_restore>
    return ret;
c01031ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01031af:	c9                   	leave  
c01031b0:	c3                   	ret    

c01031b1 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01031b1:	f3 0f 1e fb          	endbr32 
c01031b5:	55                   	push   %ebp
c01031b6:	89 e5                	mov    %esp,%ebp
c01031b8:	57                   	push   %edi
c01031b9:	56                   	push   %esi
c01031ba:	53                   	push   %ebx
c01031bb:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01031c1:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01031c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01031cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01031d6:	c7 04 24 e7 7a 10 c0 	movl   $0xc0107ae7,(%esp)
c01031dd:	e8 e3 d0 ff ff       	call   c01002c5 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01031e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01031e9:	e9 1a 01 00 00       	jmp    c0103308 <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01031ee:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031f4:	89 d0                	mov    %edx,%eax
c01031f6:	c1 e0 02             	shl    $0x2,%eax
c01031f9:	01 d0                	add    %edx,%eax
c01031fb:	c1 e0 02             	shl    $0x2,%eax
c01031fe:	01 c8                	add    %ecx,%eax
c0103200:	8b 50 08             	mov    0x8(%eax),%edx
c0103203:	8b 40 04             	mov    0x4(%eax),%eax
c0103206:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0103209:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010320c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010320f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103212:	89 d0                	mov    %edx,%eax
c0103214:	c1 e0 02             	shl    $0x2,%eax
c0103217:	01 d0                	add    %edx,%eax
c0103219:	c1 e0 02             	shl    $0x2,%eax
c010321c:	01 c8                	add    %ecx,%eax
c010321e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103221:	8b 58 10             	mov    0x10(%eax),%ebx
c0103224:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103227:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010322a:	01 c8                	add    %ecx,%eax
c010322c:	11 da                	adc    %ebx,%edx
c010322e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103231:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103234:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103237:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010323a:	89 d0                	mov    %edx,%eax
c010323c:	c1 e0 02             	shl    $0x2,%eax
c010323f:	01 d0                	add    %edx,%eax
c0103241:	c1 e0 02             	shl    $0x2,%eax
c0103244:	01 c8                	add    %ecx,%eax
c0103246:	83 c0 14             	add    $0x14,%eax
c0103249:	8b 00                	mov    (%eax),%eax
c010324b:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010324e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103251:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103254:	83 c0 ff             	add    $0xffffffff,%eax
c0103257:	83 d2 ff             	adc    $0xffffffff,%edx
c010325a:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0103260:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103266:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103269:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010326c:	89 d0                	mov    %edx,%eax
c010326e:	c1 e0 02             	shl    $0x2,%eax
c0103271:	01 d0                	add    %edx,%eax
c0103273:	c1 e0 02             	shl    $0x2,%eax
c0103276:	01 c8                	add    %ecx,%eax
c0103278:	8b 48 0c             	mov    0xc(%eax),%ecx
c010327b:	8b 58 10             	mov    0x10(%eax),%ebx
c010327e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103281:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0103285:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c010328b:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103291:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103295:	89 54 24 18          	mov    %edx,0x18(%esp)
c0103299:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010329c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010329f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01032a3:	89 54 24 10          	mov    %edx,0x10(%esp)
c01032a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01032ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01032af:	c7 04 24 f4 7a 10 c0 	movl   $0xc0107af4,(%esp)
c01032b6:	e8 0a d0 ff ff       	call   c01002c5 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01032bb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01032be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01032c1:	89 d0                	mov    %edx,%eax
c01032c3:	c1 e0 02             	shl    $0x2,%eax
c01032c6:	01 d0                	add    %edx,%eax
c01032c8:	c1 e0 02             	shl    $0x2,%eax
c01032cb:	01 c8                	add    %ecx,%eax
c01032cd:	83 c0 14             	add    $0x14,%eax
c01032d0:	8b 00                	mov    (%eax),%eax
c01032d2:	83 f8 01             	cmp    $0x1,%eax
c01032d5:	75 2e                	jne    c0103305 <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
c01032d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01032dd:	3b 45 98             	cmp    -0x68(%ebp),%eax
c01032e0:	89 d0                	mov    %edx,%eax
c01032e2:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c01032e5:	73 1e                	jae    c0103305 <page_init+0x154>
c01032e7:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c01032ec:	b8 00 00 00 00       	mov    $0x0,%eax
c01032f1:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c01032f4:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c01032f7:	72 0c                	jb     c0103305 <page_init+0x154>
                maxpa = end;
c01032f9:	8b 45 98             	mov    -0x68(%ebp),%eax
c01032fc:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01032ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0103305:	ff 45 dc             	incl   -0x24(%ebp)
c0103308:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010330b:	8b 00                	mov    (%eax),%eax
c010330d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103310:	0f 8c d8 fe ff ff    	jl     c01031ee <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103316:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010331b:	b8 00 00 00 00       	mov    $0x0,%eax
c0103320:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0103323:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0103326:	73 0e                	jae    c0103336 <page_init+0x185>
        maxpa = KMEMSIZE;
c0103328:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010332f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103336:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103339:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010333c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103340:	c1 ea 0c             	shr    $0xc,%edx
c0103343:	a3 80 fe 11 c0       	mov    %eax,0xc011fe80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103348:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c010334f:	b8 20 00 12 c0       	mov    $0xc0120020,%eax
c0103354:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103357:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010335a:	01 d0                	add    %edx,%eax
c010335c:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010335f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103362:	ba 00 00 00 00       	mov    $0x0,%edx
c0103367:	f7 75 c0             	divl   -0x40(%ebp)
c010336a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010336d:	29 d0                	sub    %edx,%eax
c010336f:	a3 78 ff 11 c0       	mov    %eax,0xc011ff78

    for (i = 0; i < npage; i ++) {
c0103374:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010337b:	eb 2f                	jmp    c01033ac <page_init+0x1fb>
        SetPageReserved(pages + i);
c010337d:	8b 0d 78 ff 11 c0    	mov    0xc011ff78,%ecx
c0103383:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103386:	89 d0                	mov    %edx,%eax
c0103388:	c1 e0 02             	shl    $0x2,%eax
c010338b:	01 d0                	add    %edx,%eax
c010338d:	c1 e0 02             	shl    $0x2,%eax
c0103390:	01 c8                	add    %ecx,%eax
c0103392:	83 c0 04             	add    $0x4,%eax
c0103395:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010339c:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010339f:	8b 45 90             	mov    -0x70(%ebp),%eax
c01033a2:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01033a5:	0f ab 10             	bts    %edx,(%eax)
}
c01033a8:	90                   	nop
    for (i = 0; i < npage; i ++) {
c01033a9:	ff 45 dc             	incl   -0x24(%ebp)
c01033ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01033af:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c01033b4:	39 c2                	cmp    %eax,%edx
c01033b6:	72 c5                	jb     c010337d <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01033b8:	8b 15 80 fe 11 c0    	mov    0xc011fe80,%edx
c01033be:	89 d0                	mov    %edx,%eax
c01033c0:	c1 e0 02             	shl    $0x2,%eax
c01033c3:	01 d0                	add    %edx,%eax
c01033c5:	c1 e0 02             	shl    $0x2,%eax
c01033c8:	89 c2                	mov    %eax,%edx
c01033ca:	a1 78 ff 11 c0       	mov    0xc011ff78,%eax
c01033cf:	01 d0                	add    %edx,%eax
c01033d1:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01033d4:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c01033db:	77 23                	ja     c0103400 <page_init+0x24f>
c01033dd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01033e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01033e4:	c7 44 24 08 24 7b 10 	movl   $0xc0107b24,0x8(%esp)
c01033eb:	c0 
c01033ec:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01033f3:	00 
c01033f4:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01033fb:	e8 31 d0 ff ff       	call   c0100431 <__panic>
c0103400:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103403:	05 00 00 00 40       	add    $0x40000000,%eax
c0103408:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010340b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103412:	e9 63 01 00 00       	jmp    c010357a <page_init+0x3c9>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103417:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010341a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010341d:	89 d0                	mov    %edx,%eax
c010341f:	c1 e0 02             	shl    $0x2,%eax
c0103422:	01 d0                	add    %edx,%eax
c0103424:	c1 e0 02             	shl    $0x2,%eax
c0103427:	01 c8                	add    %ecx,%eax
c0103429:	8b 50 08             	mov    0x8(%eax),%edx
c010342c:	8b 40 04             	mov    0x4(%eax),%eax
c010342f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103432:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103435:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103438:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010343b:	89 d0                	mov    %edx,%eax
c010343d:	c1 e0 02             	shl    $0x2,%eax
c0103440:	01 d0                	add    %edx,%eax
c0103442:	c1 e0 02             	shl    $0x2,%eax
c0103445:	01 c8                	add    %ecx,%eax
c0103447:	8b 48 0c             	mov    0xc(%eax),%ecx
c010344a:	8b 58 10             	mov    0x10(%eax),%ebx
c010344d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103450:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103453:	01 c8                	add    %ecx,%eax
c0103455:	11 da                	adc    %ebx,%edx
c0103457:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010345a:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010345d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103460:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103463:	89 d0                	mov    %edx,%eax
c0103465:	c1 e0 02             	shl    $0x2,%eax
c0103468:	01 d0                	add    %edx,%eax
c010346a:	c1 e0 02             	shl    $0x2,%eax
c010346d:	01 c8                	add    %ecx,%eax
c010346f:	83 c0 14             	add    $0x14,%eax
c0103472:	8b 00                	mov    (%eax),%eax
c0103474:	83 f8 01             	cmp    $0x1,%eax
c0103477:	0f 85 fa 00 00 00    	jne    c0103577 <page_init+0x3c6>
            if (begin < freemem) {
c010347d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103480:	ba 00 00 00 00       	mov    $0x0,%edx
c0103485:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103488:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010348b:	19 d1                	sbb    %edx,%ecx
c010348d:	73 0d                	jae    c010349c <page_init+0x2eb>
                begin = freemem;
c010348f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103492:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103495:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010349c:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01034a1:	b8 00 00 00 00       	mov    $0x0,%eax
c01034a6:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01034a9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01034ac:	73 0e                	jae    c01034bc <page_init+0x30b>
                end = KMEMSIZE;
c01034ae:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01034b5:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01034bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034c2:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01034c5:	89 d0                	mov    %edx,%eax
c01034c7:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01034ca:	0f 83 a7 00 00 00    	jae    c0103577 <page_init+0x3c6>
                begin = ROUNDUP(begin, PGSIZE);
c01034d0:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c01034d7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034da:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01034dd:	01 d0                	add    %edx,%eax
c01034df:	48                   	dec    %eax
c01034e0:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01034e3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01034e6:	ba 00 00 00 00       	mov    $0x0,%edx
c01034eb:	f7 75 b0             	divl   -0x50(%ebp)
c01034ee:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01034f1:	29 d0                	sub    %edx,%eax
c01034f3:	ba 00 00 00 00       	mov    $0x0,%edx
c01034f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01034fb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01034fe:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103501:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103504:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103507:	ba 00 00 00 00       	mov    $0x0,%edx
c010350c:	89 c3                	mov    %eax,%ebx
c010350e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103514:	89 de                	mov    %ebx,%esi
c0103516:	89 d0                	mov    %edx,%eax
c0103518:	83 e0 00             	and    $0x0,%eax
c010351b:	89 c7                	mov    %eax,%edi
c010351d:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103520:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103523:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103526:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103529:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010352c:	89 d0                	mov    %edx,%eax
c010352e:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103531:	73 44                	jae    c0103577 <page_init+0x3c6>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103533:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103536:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103539:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010353c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010353f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103543:	c1 ea 0c             	shr    $0xc,%edx
c0103546:	89 c3                	mov    %eax,%ebx
c0103548:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010354b:	89 04 24             	mov    %eax,(%esp)
c010354e:	e8 ad f8 ff ff       	call   c0102e00 <pa2page>
c0103553:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103557:	89 04 24             	mov    %eax,(%esp)
c010355a:	e8 8c fb ff ff       	call   c01030eb <init_memmap>
                    first_ppn = page2ppn(pa2page(begin));
c010355f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103562:	89 04 24             	mov    %eax,(%esp)
c0103565:	e8 96 f8 ff ff       	call   c0102e00 <pa2page>
c010356a:	89 04 24             	mov    %eax,(%esp)
c010356d:	e8 5e f8 ff ff       	call   c0102dd0 <page2ppn>
c0103572:	a3 84 fe 11 c0       	mov    %eax,0xc011fe84
    for (i = 0; i < memmap->nr_map; i ++) {
c0103577:	ff 45 dc             	incl   -0x24(%ebp)
c010357a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010357d:	8b 00                	mov    (%eax),%eax
c010357f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103582:	0f 8c 8f fe ff ff    	jl     c0103417 <page_init+0x266>
                }
            }
        }
    }
}
c0103588:	90                   	nop
c0103589:	90                   	nop
c010358a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103590:	5b                   	pop    %ebx
c0103591:	5e                   	pop    %esi
c0103592:	5f                   	pop    %edi
c0103593:	5d                   	pop    %ebp
c0103594:	c3                   	ret    

c0103595 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103595:	f3 0f 1e fb          	endbr32 
c0103599:	55                   	push   %ebp
c010359a:	89 e5                	mov    %esp,%ebp
c010359c:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010359f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035a2:	33 45 14             	xor    0x14(%ebp),%eax
c01035a5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035aa:	85 c0                	test   %eax,%eax
c01035ac:	74 24                	je     c01035d2 <boot_map_segment+0x3d>
c01035ae:	c7 44 24 0c 56 7b 10 	movl   $0xc0107b56,0xc(%esp)
c01035b5:	c0 
c01035b6:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01035bd:	c0 
c01035be:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01035c5:	00 
c01035c6:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01035cd:	e8 5f ce ff ff       	call   c0100431 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01035d2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01035d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035dc:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035e1:	89 c2                	mov    %eax,%edx
c01035e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01035e6:	01 c2                	add    %eax,%edx
c01035e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035eb:	01 d0                	add    %edx,%eax
c01035ed:	48                   	dec    %eax
c01035ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01035f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035f4:	ba 00 00 00 00       	mov    $0x0,%edx
c01035f9:	f7 75 f0             	divl   -0x10(%ebp)
c01035fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035ff:	29 d0                	sub    %edx,%eax
c0103601:	c1 e8 0c             	shr    $0xc,%eax
c0103604:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010360a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010360d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103610:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103615:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103618:	8b 45 14             	mov    0x14(%ebp),%eax
c010361b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010361e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103621:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103626:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103629:	eb 68                	jmp    c0103693 <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010362b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103632:	00 
c0103633:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103636:	89 44 24 04          	mov    %eax,0x4(%esp)
c010363a:	8b 45 08             	mov    0x8(%ebp),%eax
c010363d:	89 04 24             	mov    %eax,(%esp)
c0103640:	e8 8a 01 00 00       	call   c01037cf <get_pte>
c0103645:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103648:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010364c:	75 24                	jne    c0103672 <boot_map_segment+0xdd>
c010364e:	c7 44 24 0c 82 7b 10 	movl   $0xc0107b82,0xc(%esp)
c0103655:	c0 
c0103656:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c010365d:	c0 
c010365e:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0103665:	00 
c0103666:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c010366d:	e8 bf cd ff ff       	call   c0100431 <__panic>
        *ptep = pa | PTE_P | perm;
c0103672:	8b 45 14             	mov    0x14(%ebp),%eax
c0103675:	0b 45 18             	or     0x18(%ebp),%eax
c0103678:	83 c8 01             	or     $0x1,%eax
c010367b:	89 c2                	mov    %eax,%edx
c010367d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103680:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103682:	ff 4d f4             	decl   -0xc(%ebp)
c0103685:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010368c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103693:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103697:	75 92                	jne    c010362b <boot_map_segment+0x96>
    }
}
c0103699:	90                   	nop
c010369a:	90                   	nop
c010369b:	c9                   	leave  
c010369c:	c3                   	ret    

c010369d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010369d:	f3 0f 1e fb          	endbr32 
c01036a1:	55                   	push   %ebp
c01036a2:	89 e5                	mov    %esp,%ebp
c01036a4:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01036a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036ae:	e8 5c fa ff ff       	call   c010310f <alloc_pages>
c01036b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01036b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036ba:	75 1c                	jne    c01036d8 <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
c01036bc:	c7 44 24 08 8f 7b 10 	movl   $0xc0107b8f,0x8(%esp)
c01036c3:	c0 
c01036c4:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01036cb:	00 
c01036cc:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01036d3:	e8 59 cd ff ff       	call   c0100431 <__panic>
    }
    return page2kva(p);
c01036d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036db:	89 04 24             	mov    %eax,(%esp)
c01036de:	e8 6c f7 ff ff       	call   c0102e4f <page2kva>
}
c01036e3:	c9                   	leave  
c01036e4:	c3                   	ret    

c01036e5 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01036e5:	f3 0f 1e fb          	endbr32 
c01036e9:	55                   	push   %ebp
c01036ea:	89 e5                	mov    %esp,%ebp
c01036ec:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01036ef:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c01036f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036f7:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01036fe:	77 23                	ja     c0103723 <pmm_init+0x3e>
c0103700:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103703:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103707:	c7 44 24 08 24 7b 10 	movl   $0xc0107b24,0x8(%esp)
c010370e:	c0 
c010370f:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103716:	00 
c0103717:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c010371e:	e8 0e cd ff ff       	call   c0100431 <__panic>
c0103723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103726:	05 00 00 00 40       	add    $0x40000000,%eax
c010372b:	a3 74 ff 11 c0       	mov    %eax,0xc011ff74
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103730:	e8 7e f9 ff ff       	call   c01030b3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103735:	e8 77 fa ff ff       	call   c01031b1 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010373a:	e8 f3 03 00 00       	call   c0103b32 <check_alloc_page>

    check_pgdir();
c010373f:	e8 11 04 00 00       	call   c0103b55 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103744:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103749:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010374c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103753:	77 23                	ja     c0103778 <pmm_init+0x93>
c0103755:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103758:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010375c:	c7 44 24 08 24 7b 10 	movl   $0xc0107b24,0x8(%esp)
c0103763:	c0 
c0103764:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c010376b:	00 
c010376c:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103773:	e8 b9 cc ff ff       	call   c0100431 <__panic>
c0103778:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010377b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103781:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103786:	05 ac 0f 00 00       	add    $0xfac,%eax
c010378b:	83 ca 03             	or     $0x3,%edx
c010378e:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103790:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103795:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010379c:	00 
c010379d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01037a4:	00 
c01037a5:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01037ac:	38 
c01037ad:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01037b4:	c0 
c01037b5:	89 04 24             	mov    %eax,(%esp)
c01037b8:	e8 d8 fd ff ff       	call   c0103595 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01037bd:	e8 03 f8 ff ff       	call   c0102fc5 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01037c2:	e8 2e 0a 00 00       	call   c01041f5 <check_boot_pgdir>

    print_pgdir();
c01037c7:	e8 b3 0e 00 00       	call   c010467f <print_pgdir>

}
c01037cc:	90                   	nop
c01037cd:	c9                   	leave  
c01037ce:	c3                   	ret    

c01037cf <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01037cf:	f3 0f 1e fb          	endbr32 
c01037d3:	55                   	push   %ebp
c01037d4:	89 e5                	mov    %esp,%ebp
c01037d6:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */

    pde_t *pdep = &pgdir[PDX(la)];//获取页表
c01037d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037dc:	c1 e8 16             	shr    $0x16,%eax
c01037df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01037e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e9:	01 d0                	add    %edx,%eax
c01037eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {//如果页表不存在，尝试新建一个页表
c01037ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f1:	8b 00                	mov    (%eax),%eax
c01037f3:	83 e0 01             	and    $0x1,%eax
c01037f6:	85 c0                	test   %eax,%eax
c01037f8:	0f 85 af 00 00 00    	jne    c01038ad <get_pte+0xde>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//如果不需要创建或者分配失败，返回null
c01037fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103802:	74 15                	je     c0103819 <get_pte+0x4a>
c0103804:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010380b:	e8 ff f8 ff ff       	call   c010310f <alloc_pages>
c0103810:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103817:	75 0a                	jne    c0103823 <get_pte+0x54>
            return NULL;
c0103819:	b8 00 00 00 00       	mov    $0x0,%eax
c010381e:	e9 e7 00 00 00       	jmp    c010390a <get_pte+0x13b>
        }
        set_page_ref(page, 1);//第一次创建，只有一个引用
c0103823:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010382a:	00 
c010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010382e:	89 04 24             	mov    %eax,(%esp)
c0103831:	e8 cd f6 ff ff       	call   c0102f03 <set_page_ref>
        uintptr_t pa = page2pa(page);//转换成物理地址
c0103836:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103839:	89 04 24             	mov    %eax,(%esp)
c010383c:	e8 a9 f5 ff ff       	call   c0102dea <page2pa>
c0103841:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);//将对应物理地址置零
c0103844:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103847:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010384a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010384d:	c1 e8 0c             	shr    $0xc,%eax
c0103850:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103853:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c0103858:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010385b:	72 23                	jb     c0103880 <get_pte+0xb1>
c010385d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103860:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103864:	c7 44 24 08 80 7a 10 	movl   $0xc0107a80,0x8(%esp)
c010386b:	c0 
c010386c:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0103873:	00 
c0103874:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c010387b:	e8 b1 cb ff ff       	call   c0100431 <__panic>
c0103880:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103883:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103888:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010388f:	00 
c0103890:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103897:	00 
c0103898:	89 04 24             	mov    %eax,(%esp)
c010389b:	e8 0a 32 00 00       	call   c0106aaa <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;//设置控制位
c01038a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038a3:	83 c8 07             	or     $0x7,%eax
c01038a6:	89 c2                	mov    %eax,%edx
c01038a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ab:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01038ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b0:	8b 00                	mov    (%eax),%eax
c01038b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01038b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01038ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038bd:	c1 e8 0c             	shr    $0xc,%eax
c01038c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01038c3:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c01038c8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01038cb:	72 23                	jb     c01038f0 <get_pte+0x121>
c01038cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01038d4:	c7 44 24 08 80 7a 10 	movl   $0xc0107a80,0x8(%esp)
c01038db:	c0 
c01038dc:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c01038e3:	00 
c01038e4:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01038eb:	e8 41 cb ff ff       	call   c0100431 <__panic>
c01038f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038f3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01038f8:	89 c2                	mov    %eax,%edx
c01038fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038fd:	c1 e8 0c             	shr    $0xc,%eax
c0103900:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103905:	c1 e0 02             	shl    $0x2,%eax
c0103908:	01 d0                	add    %edx,%eax
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c010390a:	c9                   	leave  
c010390b:	c3                   	ret    

c010390c <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010390c:	f3 0f 1e fb          	endbr32 
c0103910:	55                   	push   %ebp
c0103911:	89 e5                	mov    %esp,%ebp
c0103913:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103916:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010391d:	00 
c010391e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103921:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103925:	8b 45 08             	mov    0x8(%ebp),%eax
c0103928:	89 04 24             	mov    %eax,(%esp)
c010392b:	e8 9f fe ff ff       	call   c01037cf <get_pte>
c0103930:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103933:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103937:	74 08                	je     c0103941 <get_page+0x35>
        *ptep_store = ptep;
c0103939:	8b 45 10             	mov    0x10(%ebp),%eax
c010393c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010393f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103941:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103945:	74 1b                	je     c0103962 <get_page+0x56>
c0103947:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010394a:	8b 00                	mov    (%eax),%eax
c010394c:	83 e0 01             	and    $0x1,%eax
c010394f:	85 c0                	test   %eax,%eax
c0103951:	74 0f                	je     c0103962 <get_page+0x56>
        return pte2page(*ptep);
c0103953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103956:	8b 00                	mov    (%eax),%eax
c0103958:	89 04 24             	mov    %eax,(%esp)
c010395b:	e8 43 f5 ff ff       	call   c0102ea3 <pte2page>
c0103960:	eb 05                	jmp    c0103967 <get_page+0x5b>
    }
    return NULL;
c0103962:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103967:	c9                   	leave  
c0103968:	c3                   	ret    

c0103969 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103969:	55                   	push   %ebp
c010396a:	89 e5                	mov    %esp,%ebp
c010396c:	83 ec 28             	sub    $0x28,%esp
                                  //(3) decrease page reference
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    } */
    if (*ptep & PTE_P) {
c010396f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103972:	8b 00                	mov    (%eax),%eax
c0103974:	83 e0 01             	and    $0x1,%eax
c0103977:	85 c0                	test   %eax,%eax
c0103979:	74 4d                	je     c01039c8 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c010397b:	8b 45 10             	mov    0x10(%ebp),%eax
c010397e:	8b 00                	mov    (%eax),%eax
c0103980:	89 04 24             	mov    %eax,(%esp)
c0103983:	e8 1b f5 ff ff       	call   c0102ea3 <pte2page>
c0103988:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010398b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398e:	89 04 24             	mov    %eax,(%esp)
c0103991:	e8 92 f5 ff ff       	call   c0102f28 <page_ref_dec>
c0103996:	85 c0                	test   %eax,%eax
c0103998:	75 13                	jne    c01039ad <page_remove_pte+0x44>
            free_page(page);
c010399a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01039a1:	00 
c01039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039a5:	89 04 24             	mov    %eax,(%esp)
c01039a8:	e8 9e f7 ff ff       	call   c010314b <free_pages>
        }
        *ptep = 0;
c01039ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01039b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01039b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01039c0:	89 04 24             	mov    %eax,(%esp)
c01039c3:	e8 09 01 00 00       	call   c0103ad1 <tlb_invalidate>
    }
}
c01039c8:	90                   	nop
c01039c9:	c9                   	leave  
c01039ca:	c3                   	ret    

c01039cb <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01039cb:	f3 0f 1e fb          	endbr32 
c01039cf:	55                   	push   %ebp
c01039d0:	89 e5                	mov    %esp,%ebp
c01039d2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01039d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01039dc:	00 
c01039dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01039e7:	89 04 24             	mov    %eax,(%esp)
c01039ea:	e8 e0 fd ff ff       	call   c01037cf <get_pte>
c01039ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01039f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039f6:	74 19                	je     c0103a11 <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
c01039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01039ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a09:	89 04 24             	mov    %eax,(%esp)
c0103a0c:	e8 58 ff ff ff       	call   c0103969 <page_remove_pte>
    }
}
c0103a11:	90                   	nop
c0103a12:	c9                   	leave  
c0103a13:	c3                   	ret    

c0103a14 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103a14:	f3 0f 1e fb          	endbr32 
c0103a18:	55                   	push   %ebp
c0103a19:	89 e5                	mov    %esp,%ebp
c0103a1b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103a1e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103a25:	00 
c0103a26:	8b 45 10             	mov    0x10(%ebp),%eax
c0103a29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a30:	89 04 24             	mov    %eax,(%esp)
c0103a33:	e8 97 fd ff ff       	call   c01037cf <get_pte>
c0103a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103a3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a3f:	75 0a                	jne    c0103a4b <page_insert+0x37>
        return -E_NO_MEM;
c0103a41:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103a46:	e9 84 00 00 00       	jmp    c0103acf <page_insert+0xbb>
    }
    page_ref_inc(page);
c0103a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a4e:	89 04 24             	mov    %eax,(%esp)
c0103a51:	e8 bb f4 ff ff       	call   c0102f11 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a59:	8b 00                	mov    (%eax),%eax
c0103a5b:	83 e0 01             	and    $0x1,%eax
c0103a5e:	85 c0                	test   %eax,%eax
c0103a60:	74 3e                	je     c0103aa0 <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
c0103a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a65:	8b 00                	mov    (%eax),%eax
c0103a67:	89 04 24             	mov    %eax,(%esp)
c0103a6a:	e8 34 f4 ff ff       	call   c0102ea3 <pte2page>
c0103a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a75:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103a78:	75 0d                	jne    c0103a87 <page_insert+0x73>
            page_ref_dec(page);
c0103a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a7d:	89 04 24             	mov    %eax,(%esp)
c0103a80:	e8 a3 f4 ff ff       	call   c0102f28 <page_ref_dec>
c0103a85:	eb 19                	jmp    c0103aa0 <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103a8e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103a91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a98:	89 04 24             	mov    %eax,(%esp)
c0103a9b:	e8 c9 fe ff ff       	call   c0103969 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103aa3:	89 04 24             	mov    %eax,(%esp)
c0103aa6:	e8 3f f3 ff ff       	call   c0102dea <page2pa>
c0103aab:	0b 45 14             	or     0x14(%ebp),%eax
c0103aae:	83 c8 01             	or     $0x1,%eax
c0103ab1:	89 c2                	mov    %eax,%edx
c0103ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ab6:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103ab8:	8b 45 10             	mov    0x10(%ebp),%eax
c0103abb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac2:	89 04 24             	mov    %eax,(%esp)
c0103ac5:	e8 07 00 00 00       	call   c0103ad1 <tlb_invalidate>
    return 0;
c0103aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103acf:	c9                   	leave  
c0103ad0:	c3                   	ret    

c0103ad1 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103ad1:	f3 0f 1e fb          	endbr32 
c0103ad5:	55                   	push   %ebp
c0103ad6:	89 e5                	mov    %esp,%ebp
c0103ad8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103adb:	0f 20 d8             	mov    %cr3,%eax
c0103ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103ae1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103ae4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103aea:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103af1:	77 23                	ja     c0103b16 <tlb_invalidate+0x45>
c0103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103af6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103afa:	c7 44 24 08 24 7b 10 	movl   $0xc0107b24,0x8(%esp)
c0103b01:	c0 
c0103b02:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c0103b09:	00 
c0103b0a:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103b11:	e8 1b c9 ff ff       	call   c0100431 <__panic>
c0103b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b19:	05 00 00 00 40       	add    $0x40000000,%eax
c0103b1e:	39 d0                	cmp    %edx,%eax
c0103b20:	75 0d                	jne    c0103b2f <tlb_invalidate+0x5e>
        invlpg((void *)la);
c0103b22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b25:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b2b:	0f 01 38             	invlpg (%eax)
}
c0103b2e:	90                   	nop
    }
}
c0103b2f:	90                   	nop
c0103b30:	c9                   	leave  
c0103b31:	c3                   	ret    

c0103b32 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103b32:	f3 0f 1e fb          	endbr32 
c0103b36:	55                   	push   %ebp
c0103b37:	89 e5                	mov    %esp,%ebp
c0103b39:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103b3c:	a1 70 ff 11 c0       	mov    0xc011ff70,%eax
c0103b41:	8b 40 18             	mov    0x18(%eax),%eax
c0103b44:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103b46:	c7 04 24 a8 7b 10 c0 	movl   $0xc0107ba8,(%esp)
c0103b4d:	e8 73 c7 ff ff       	call   c01002c5 <cprintf>
}
c0103b52:	90                   	nop
c0103b53:	c9                   	leave  
c0103b54:	c3                   	ret    

c0103b55 <check_pgdir>:

static void
check_pgdir(void) {
c0103b55:	f3 0f 1e fb          	endbr32 
c0103b59:	55                   	push   %ebp
c0103b5a:	89 e5                	mov    %esp,%ebp
c0103b5c:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103b5f:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c0103b64:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103b69:	76 24                	jbe    c0103b8f <check_pgdir+0x3a>
c0103b6b:	c7 44 24 0c c7 7b 10 	movl   $0xc0107bc7,0xc(%esp)
c0103b72:	c0 
c0103b73:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103b7a:	c0 
c0103b7b:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103b82:	00 
c0103b83:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103b8a:	e8 a2 c8 ff ff       	call   c0100431 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103b8f:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103b94:	85 c0                	test   %eax,%eax
c0103b96:	74 0e                	je     c0103ba6 <check_pgdir+0x51>
c0103b98:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103b9d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103ba2:	85 c0                	test   %eax,%eax
c0103ba4:	74 24                	je     c0103bca <check_pgdir+0x75>
c0103ba6:	c7 44 24 0c e4 7b 10 	movl   $0xc0107be4,0xc(%esp)
c0103bad:	c0 
c0103bae:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103bb5:	c0 
c0103bb6:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0103bbd:	00 
c0103bbe:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103bc5:	e8 67 c8 ff ff       	call   c0100431 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103bca:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103bcf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103bd6:	00 
c0103bd7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103bde:	00 
c0103bdf:	89 04 24             	mov    %eax,(%esp)
c0103be2:	e8 25 fd ff ff       	call   c010390c <get_page>
c0103be7:	85 c0                	test   %eax,%eax
c0103be9:	74 24                	je     c0103c0f <check_pgdir+0xba>
c0103beb:	c7 44 24 0c 1c 7c 10 	movl   $0xc0107c1c,0xc(%esp)
c0103bf2:	c0 
c0103bf3:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103bfa:	c0 
c0103bfb:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0103c02:	00 
c0103c03:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103c0a:	e8 22 c8 ff ff       	call   c0100431 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103c0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c16:	e8 f4 f4 ff ff       	call   c010310f <alloc_pages>
c0103c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103c1e:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103c23:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103c2a:	00 
c0103c2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c32:	00 
c0103c33:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103c36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c3a:	89 04 24             	mov    %eax,(%esp)
c0103c3d:	e8 d2 fd ff ff       	call   c0103a14 <page_insert>
c0103c42:	85 c0                	test   %eax,%eax
c0103c44:	74 24                	je     c0103c6a <check_pgdir+0x115>
c0103c46:	c7 44 24 0c 44 7c 10 	movl   $0xc0107c44,0xc(%esp)
c0103c4d:	c0 
c0103c4e:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103c55:	c0 
c0103c56:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103c5d:	00 
c0103c5e:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103c65:	e8 c7 c7 ff ff       	call   c0100431 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103c6a:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103c6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c76:	00 
c0103c77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103c7e:	00 
c0103c7f:	89 04 24             	mov    %eax,(%esp)
c0103c82:	e8 48 fb ff ff       	call   c01037cf <get_pte>
c0103c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c8e:	75 24                	jne    c0103cb4 <check_pgdir+0x15f>
c0103c90:	c7 44 24 0c 70 7c 10 	movl   $0xc0107c70,0xc(%esp)
c0103c97:	c0 
c0103c98:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103c9f:	c0 
c0103ca0:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103ca7:	00 
c0103ca8:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103caf:	e8 7d c7 ff ff       	call   c0100431 <__panic>
    assert(pte2page(*ptep) == p1);
c0103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cb7:	8b 00                	mov    (%eax),%eax
c0103cb9:	89 04 24             	mov    %eax,(%esp)
c0103cbc:	e8 e2 f1 ff ff       	call   c0102ea3 <pte2page>
c0103cc1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103cc4:	74 24                	je     c0103cea <check_pgdir+0x195>
c0103cc6:	c7 44 24 0c 9d 7c 10 	movl   $0xc0107c9d,0xc(%esp)
c0103ccd:	c0 
c0103cce:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103cd5:	c0 
c0103cd6:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103cdd:	00 
c0103cde:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103ce5:	e8 47 c7 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p1) == 1);
c0103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ced:	89 04 24             	mov    %eax,(%esp)
c0103cf0:	e8 04 f2 ff ff       	call   c0102ef9 <page_ref>
c0103cf5:	83 f8 01             	cmp    $0x1,%eax
c0103cf8:	74 24                	je     c0103d1e <check_pgdir+0x1c9>
c0103cfa:	c7 44 24 0c b3 7c 10 	movl   $0xc0107cb3,0xc(%esp)
c0103d01:	c0 
c0103d02:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103d09:	c0 
c0103d0a:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103d11:	00 
c0103d12:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103d19:	e8 13 c7 ff ff       	call   c0100431 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103d1e:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103d23:	8b 00                	mov    (%eax),%eax
c0103d25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d30:	c1 e8 0c             	shr    $0xc,%eax
c0103d33:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d36:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c0103d3b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103d3e:	72 23                	jb     c0103d63 <check_pgdir+0x20e>
c0103d40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d43:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d47:	c7 44 24 08 80 7a 10 	movl   $0xc0107a80,0x8(%esp)
c0103d4e:	c0 
c0103d4f:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0103d56:	00 
c0103d57:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103d5e:	e8 ce c6 ff ff       	call   c0100431 <__panic>
c0103d63:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d66:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103d6b:	83 c0 04             	add    $0x4,%eax
c0103d6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103d71:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103d76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d7d:	00 
c0103d7e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103d85:	00 
c0103d86:	89 04 24             	mov    %eax,(%esp)
c0103d89:	e8 41 fa ff ff       	call   c01037cf <get_pte>
c0103d8e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103d91:	74 24                	je     c0103db7 <check_pgdir+0x262>
c0103d93:	c7 44 24 0c c8 7c 10 	movl   $0xc0107cc8,0xc(%esp)
c0103d9a:	c0 
c0103d9b:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103da2:	c0 
c0103da3:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103daa:	00 
c0103dab:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103db2:	e8 7a c6 ff ff       	call   c0100431 <__panic>

    p2 = alloc_page();
c0103db7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dbe:	e8 4c f3 ff ff       	call   c010310f <alloc_pages>
c0103dc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103dc6:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103dcb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103dd2:	00 
c0103dd3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103dda:	00 
c0103ddb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103dde:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103de2:	89 04 24             	mov    %eax,(%esp)
c0103de5:	e8 2a fc ff ff       	call   c0103a14 <page_insert>
c0103dea:	85 c0                	test   %eax,%eax
c0103dec:	74 24                	je     c0103e12 <check_pgdir+0x2bd>
c0103dee:	c7 44 24 0c f0 7c 10 	movl   $0xc0107cf0,0xc(%esp)
c0103df5:	c0 
c0103df6:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103dfd:	c0 
c0103dfe:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103e05:	00 
c0103e06:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103e0d:	e8 1f c6 ff ff       	call   c0100431 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103e12:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103e17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e1e:	00 
c0103e1f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103e26:	00 
c0103e27:	89 04 24             	mov    %eax,(%esp)
c0103e2a:	e8 a0 f9 ff ff       	call   c01037cf <get_pte>
c0103e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103e36:	75 24                	jne    c0103e5c <check_pgdir+0x307>
c0103e38:	c7 44 24 0c 28 7d 10 	movl   $0xc0107d28,0xc(%esp)
c0103e3f:	c0 
c0103e40:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103e47:	c0 
c0103e48:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0103e4f:	00 
c0103e50:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103e57:	e8 d5 c5 ff ff       	call   c0100431 <__panic>
    assert(*ptep & PTE_U);
c0103e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e5f:	8b 00                	mov    (%eax),%eax
c0103e61:	83 e0 04             	and    $0x4,%eax
c0103e64:	85 c0                	test   %eax,%eax
c0103e66:	75 24                	jne    c0103e8c <check_pgdir+0x337>
c0103e68:	c7 44 24 0c 58 7d 10 	movl   $0xc0107d58,0xc(%esp)
c0103e6f:	c0 
c0103e70:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103e77:	c0 
c0103e78:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103e7f:	00 
c0103e80:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103e87:	e8 a5 c5 ff ff       	call   c0100431 <__panic>
    assert(*ptep & PTE_W);
c0103e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e8f:	8b 00                	mov    (%eax),%eax
c0103e91:	83 e0 02             	and    $0x2,%eax
c0103e94:	85 c0                	test   %eax,%eax
c0103e96:	75 24                	jne    c0103ebc <check_pgdir+0x367>
c0103e98:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c0103e9f:	c0 
c0103ea0:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103ea7:	c0 
c0103ea8:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103eaf:	00 
c0103eb0:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103eb7:	e8 75 c5 ff ff       	call   c0100431 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103ebc:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103ec1:	8b 00                	mov    (%eax),%eax
c0103ec3:	83 e0 04             	and    $0x4,%eax
c0103ec6:	85 c0                	test   %eax,%eax
c0103ec8:	75 24                	jne    c0103eee <check_pgdir+0x399>
c0103eca:	c7 44 24 0c 74 7d 10 	movl   $0xc0107d74,0xc(%esp)
c0103ed1:	c0 
c0103ed2:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103ed9:	c0 
c0103eda:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0103ee1:	00 
c0103ee2:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103ee9:	e8 43 c5 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p2) == 1);
c0103eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ef1:	89 04 24             	mov    %eax,(%esp)
c0103ef4:	e8 00 f0 ff ff       	call   c0102ef9 <page_ref>
c0103ef9:	83 f8 01             	cmp    $0x1,%eax
c0103efc:	74 24                	je     c0103f22 <check_pgdir+0x3cd>
c0103efe:	c7 44 24 0c 8a 7d 10 	movl   $0xc0107d8a,0xc(%esp)
c0103f05:	c0 
c0103f06:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103f0d:	c0 
c0103f0e:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0103f15:	00 
c0103f16:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103f1d:	e8 0f c5 ff ff       	call   c0100431 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103f22:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103f27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103f2e:	00 
c0103f2f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103f36:	00 
c0103f37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f3e:	89 04 24             	mov    %eax,(%esp)
c0103f41:	e8 ce fa ff ff       	call   c0103a14 <page_insert>
c0103f46:	85 c0                	test   %eax,%eax
c0103f48:	74 24                	je     c0103f6e <check_pgdir+0x419>
c0103f4a:	c7 44 24 0c 9c 7d 10 	movl   $0xc0107d9c,0xc(%esp)
c0103f51:	c0 
c0103f52:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103f59:	c0 
c0103f5a:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103f61:	00 
c0103f62:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103f69:	e8 c3 c4 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p1) == 2);
c0103f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f71:	89 04 24             	mov    %eax,(%esp)
c0103f74:	e8 80 ef ff ff       	call   c0102ef9 <page_ref>
c0103f79:	83 f8 02             	cmp    $0x2,%eax
c0103f7c:	74 24                	je     c0103fa2 <check_pgdir+0x44d>
c0103f7e:	c7 44 24 0c c8 7d 10 	movl   $0xc0107dc8,0xc(%esp)
c0103f85:	c0 
c0103f86:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103f8d:	c0 
c0103f8e:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103f95:	00 
c0103f96:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103f9d:	e8 8f c4 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p2) == 0);
c0103fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fa5:	89 04 24             	mov    %eax,(%esp)
c0103fa8:	e8 4c ef ff ff       	call   c0102ef9 <page_ref>
c0103fad:	85 c0                	test   %eax,%eax
c0103faf:	74 24                	je     c0103fd5 <check_pgdir+0x480>
c0103fb1:	c7 44 24 0c da 7d 10 	movl   $0xc0107dda,0xc(%esp)
c0103fb8:	c0 
c0103fb9:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0103fc0:	c0 
c0103fc1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103fc8:	00 
c0103fc9:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0103fd0:	e8 5c c4 ff ff       	call   c0100431 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103fd5:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0103fda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103fe1:	00 
c0103fe2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103fe9:	00 
c0103fea:	89 04 24             	mov    %eax,(%esp)
c0103fed:	e8 dd f7 ff ff       	call   c01037cf <get_pte>
c0103ff2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ff5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ff9:	75 24                	jne    c010401f <check_pgdir+0x4ca>
c0103ffb:	c7 44 24 0c 28 7d 10 	movl   $0xc0107d28,0xc(%esp)
c0104002:	c0 
c0104003:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c010400a:	c0 
c010400b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104012:	00 
c0104013:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c010401a:	e8 12 c4 ff ff       	call   c0100431 <__panic>
    assert(pte2page(*ptep) == p1);
c010401f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104022:	8b 00                	mov    (%eax),%eax
c0104024:	89 04 24             	mov    %eax,(%esp)
c0104027:	e8 77 ee ff ff       	call   c0102ea3 <pte2page>
c010402c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010402f:	74 24                	je     c0104055 <check_pgdir+0x500>
c0104031:	c7 44 24 0c 9d 7c 10 	movl   $0xc0107c9d,0xc(%esp)
c0104038:	c0 
c0104039:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104040:	c0 
c0104041:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0104048:	00 
c0104049:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104050:	e8 dc c3 ff ff       	call   c0100431 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104055:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104058:	8b 00                	mov    (%eax),%eax
c010405a:	83 e0 04             	and    $0x4,%eax
c010405d:	85 c0                	test   %eax,%eax
c010405f:	74 24                	je     c0104085 <check_pgdir+0x530>
c0104061:	c7 44 24 0c ec 7d 10 	movl   $0xc0107dec,0xc(%esp)
c0104068:	c0 
c0104069:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104070:	c0 
c0104071:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104078:	00 
c0104079:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104080:	e8 ac c3 ff ff       	call   c0100431 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104085:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c010408a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104091:	00 
c0104092:	89 04 24             	mov    %eax,(%esp)
c0104095:	e8 31 f9 ff ff       	call   c01039cb <page_remove>
    assert(page_ref(p1) == 1);
c010409a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010409d:	89 04 24             	mov    %eax,(%esp)
c01040a0:	e8 54 ee ff ff       	call   c0102ef9 <page_ref>
c01040a5:	83 f8 01             	cmp    $0x1,%eax
c01040a8:	74 24                	je     c01040ce <check_pgdir+0x579>
c01040aa:	c7 44 24 0c b3 7c 10 	movl   $0xc0107cb3,0xc(%esp)
c01040b1:	c0 
c01040b2:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01040b9:	c0 
c01040ba:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c01040c1:	00 
c01040c2:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01040c9:	e8 63 c3 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p2) == 0);
c01040ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040d1:	89 04 24             	mov    %eax,(%esp)
c01040d4:	e8 20 ee ff ff       	call   c0102ef9 <page_ref>
c01040d9:	85 c0                	test   %eax,%eax
c01040db:	74 24                	je     c0104101 <check_pgdir+0x5ac>
c01040dd:	c7 44 24 0c da 7d 10 	movl   $0xc0107dda,0xc(%esp)
c01040e4:	c0 
c01040e5:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01040ec:	c0 
c01040ed:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c01040f4:	00 
c01040f5:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01040fc:	e8 30 c3 ff ff       	call   c0100431 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104101:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0104106:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010410d:	00 
c010410e:	89 04 24             	mov    %eax,(%esp)
c0104111:	e8 b5 f8 ff ff       	call   c01039cb <page_remove>
    assert(page_ref(p1) == 0);
c0104116:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104119:	89 04 24             	mov    %eax,(%esp)
c010411c:	e8 d8 ed ff ff       	call   c0102ef9 <page_ref>
c0104121:	85 c0                	test   %eax,%eax
c0104123:	74 24                	je     c0104149 <check_pgdir+0x5f4>
c0104125:	c7 44 24 0c 01 7e 10 	movl   $0xc0107e01,0xc(%esp)
c010412c:	c0 
c010412d:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104134:	c0 
c0104135:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010413c:	00 
c010413d:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104144:	e8 e8 c2 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p2) == 0);
c0104149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010414c:	89 04 24             	mov    %eax,(%esp)
c010414f:	e8 a5 ed ff ff       	call   c0102ef9 <page_ref>
c0104154:	85 c0                	test   %eax,%eax
c0104156:	74 24                	je     c010417c <check_pgdir+0x627>
c0104158:	c7 44 24 0c da 7d 10 	movl   $0xc0107dda,0xc(%esp)
c010415f:	c0 
c0104160:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104167:	c0 
c0104168:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c010416f:	00 
c0104170:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104177:	e8 b5 c2 ff ff       	call   c0100431 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010417c:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0104181:	8b 00                	mov    (%eax),%eax
c0104183:	89 04 24             	mov    %eax,(%esp)
c0104186:	e8 56 ed ff ff       	call   c0102ee1 <pde2page>
c010418b:	89 04 24             	mov    %eax,(%esp)
c010418e:	e8 66 ed ff ff       	call   c0102ef9 <page_ref>
c0104193:	83 f8 01             	cmp    $0x1,%eax
c0104196:	74 24                	je     c01041bc <check_pgdir+0x667>
c0104198:	c7 44 24 0c 14 7e 10 	movl   $0xc0107e14,0xc(%esp)
c010419f:	c0 
c01041a0:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01041a7:	c0 
c01041a8:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c01041af:	00 
c01041b0:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01041b7:	e8 75 c2 ff ff       	call   c0100431 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01041bc:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c01041c1:	8b 00                	mov    (%eax),%eax
c01041c3:	89 04 24             	mov    %eax,(%esp)
c01041c6:	e8 16 ed ff ff       	call   c0102ee1 <pde2page>
c01041cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041d2:	00 
c01041d3:	89 04 24             	mov    %eax,(%esp)
c01041d6:	e8 70 ef ff ff       	call   c010314b <free_pages>
    boot_pgdir[0] = 0;
c01041db:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c01041e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01041e6:	c7 04 24 3b 7e 10 c0 	movl   $0xc0107e3b,(%esp)
c01041ed:	e8 d3 c0 ff ff       	call   c01002c5 <cprintf>
}
c01041f2:	90                   	nop
c01041f3:	c9                   	leave  
c01041f4:	c3                   	ret    

c01041f5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01041f5:	f3 0f 1e fb          	endbr32 
c01041f9:	55                   	push   %ebp
c01041fa:	89 e5                	mov    %esp,%ebp
c01041fc:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01041ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104206:	e9 ca 00 00 00       	jmp    c01042d5 <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010420e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104211:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104214:	c1 e8 0c             	shr    $0xc,%eax
c0104217:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010421a:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c010421f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104222:	72 23                	jb     c0104247 <check_boot_pgdir+0x52>
c0104224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104227:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010422b:	c7 44 24 08 80 7a 10 	movl   $0xc0107a80,0x8(%esp)
c0104232:	c0 
c0104233:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c010423a:	00 
c010423b:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104242:	e8 ea c1 ff ff       	call   c0100431 <__panic>
c0104247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010424a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010424f:	89 c2                	mov    %eax,%edx
c0104251:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0104256:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010425d:	00 
c010425e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104262:	89 04 24             	mov    %eax,(%esp)
c0104265:	e8 65 f5 ff ff       	call   c01037cf <get_pte>
c010426a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010426d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104271:	75 24                	jne    c0104297 <check_boot_pgdir+0xa2>
c0104273:	c7 44 24 0c 58 7e 10 	movl   $0xc0107e58,0xc(%esp)
c010427a:	c0 
c010427b:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104282:	c0 
c0104283:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c010428a:	00 
c010428b:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104292:	e8 9a c1 ff ff       	call   c0100431 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104297:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010429a:	8b 00                	mov    (%eax),%eax
c010429c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042a1:	89 c2                	mov    %eax,%edx
c01042a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042a6:	39 c2                	cmp    %eax,%edx
c01042a8:	74 24                	je     c01042ce <check_boot_pgdir+0xd9>
c01042aa:	c7 44 24 0c 95 7e 10 	movl   $0xc0107e95,0xc(%esp)
c01042b1:	c0 
c01042b2:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01042b9:	c0 
c01042ba:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c01042c1:	00 
c01042c2:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01042c9:	e8 63 c1 ff ff       	call   c0100431 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01042ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01042d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01042d8:	a1 80 fe 11 c0       	mov    0xc011fe80,%eax
c01042dd:	39 c2                	cmp    %eax,%edx
c01042df:	0f 82 26 ff ff ff    	jb     c010420b <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01042e5:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c01042ea:	05 ac 0f 00 00       	add    $0xfac,%eax
c01042ef:	8b 00                	mov    (%eax),%eax
c01042f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042f6:	89 c2                	mov    %eax,%edx
c01042f8:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c01042fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104300:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104307:	77 23                	ja     c010432c <check_boot_pgdir+0x137>
c0104309:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010430c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104310:	c7 44 24 08 24 7b 10 	movl   $0xc0107b24,0x8(%esp)
c0104317:	c0 
c0104318:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010431f:	00 
c0104320:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104327:	e8 05 c1 ff ff       	call   c0100431 <__panic>
c010432c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010432f:	05 00 00 00 40       	add    $0x40000000,%eax
c0104334:	39 d0                	cmp    %edx,%eax
c0104336:	74 24                	je     c010435c <check_boot_pgdir+0x167>
c0104338:	c7 44 24 0c ac 7e 10 	movl   $0xc0107eac,0xc(%esp)
c010433f:	c0 
c0104340:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104347:	c0 
c0104348:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010434f:	00 
c0104350:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104357:	e8 d5 c0 ff ff       	call   c0100431 <__panic>

    assert(boot_pgdir[0] == 0);
c010435c:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c0104361:	8b 00                	mov    (%eax),%eax
c0104363:	85 c0                	test   %eax,%eax
c0104365:	74 24                	je     c010438b <check_boot_pgdir+0x196>
c0104367:	c7 44 24 0c e0 7e 10 	movl   $0xc0107ee0,0xc(%esp)
c010436e:	c0 
c010436f:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104376:	c0 
c0104377:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c010437e:	00 
c010437f:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104386:	e8 a6 c0 ff ff       	call   c0100431 <__panic>

    struct Page *p;
    p = alloc_page();
c010438b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104392:	e8 78 ed ff ff       	call   c010310f <alloc_pages>
c0104397:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010439a:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c010439f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01043a6:	00 
c01043a7:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01043ae:	00 
c01043af:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043b2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01043b6:	89 04 24             	mov    %eax,(%esp)
c01043b9:	e8 56 f6 ff ff       	call   c0103a14 <page_insert>
c01043be:	85 c0                	test   %eax,%eax
c01043c0:	74 24                	je     c01043e6 <check_boot_pgdir+0x1f1>
c01043c2:	c7 44 24 0c f4 7e 10 	movl   $0xc0107ef4,0xc(%esp)
c01043c9:	c0 
c01043ca:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01043d1:	c0 
c01043d2:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01043d9:	00 
c01043da:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01043e1:	e8 4b c0 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p) == 1);
c01043e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043e9:	89 04 24             	mov    %eax,(%esp)
c01043ec:	e8 08 eb ff ff       	call   c0102ef9 <page_ref>
c01043f1:	83 f8 01             	cmp    $0x1,%eax
c01043f4:	74 24                	je     c010441a <check_boot_pgdir+0x225>
c01043f6:	c7 44 24 0c 22 7f 10 	movl   $0xc0107f22,0xc(%esp)
c01043fd:	c0 
c01043fe:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104405:	c0 
c0104406:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c010440d:	00 
c010440e:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104415:	e8 17 c0 ff ff       	call   c0100431 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010441a:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c010441f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104426:	00 
c0104427:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010442e:	00 
c010442f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104432:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104436:	89 04 24             	mov    %eax,(%esp)
c0104439:	e8 d6 f5 ff ff       	call   c0103a14 <page_insert>
c010443e:	85 c0                	test   %eax,%eax
c0104440:	74 24                	je     c0104466 <check_boot_pgdir+0x271>
c0104442:	c7 44 24 0c 34 7f 10 	movl   $0xc0107f34,0xc(%esp)
c0104449:	c0 
c010444a:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104451:	c0 
c0104452:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0104459:	00 
c010445a:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104461:	e8 cb bf ff ff       	call   c0100431 <__panic>
    assert(page_ref(p) == 2);
c0104466:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104469:	89 04 24             	mov    %eax,(%esp)
c010446c:	e8 88 ea ff ff       	call   c0102ef9 <page_ref>
c0104471:	83 f8 02             	cmp    $0x2,%eax
c0104474:	74 24                	je     c010449a <check_boot_pgdir+0x2a5>
c0104476:	c7 44 24 0c 6b 7f 10 	movl   $0xc0107f6b,0xc(%esp)
c010447d:	c0 
c010447e:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104485:	c0 
c0104486:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c010448d:	00 
c010448e:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104495:	e8 97 bf ff ff       	call   c0100431 <__panic>

    const char *str = "ucore: Hello world!!";
c010449a:	c7 45 e8 7c 7f 10 c0 	movl   $0xc0107f7c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c01044a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044a8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01044af:	e8 12 23 00 00       	call   c01067c6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01044b4:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01044bb:	00 
c01044bc:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01044c3:	e8 7c 23 00 00       	call   c0106844 <strcmp>
c01044c8:	85 c0                	test   %eax,%eax
c01044ca:	74 24                	je     c01044f0 <check_boot_pgdir+0x2fb>
c01044cc:	c7 44 24 0c 94 7f 10 	movl   $0xc0107f94,0xc(%esp)
c01044d3:	c0 
c01044d4:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c01044db:	c0 
c01044dc:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c01044e3:	00 
c01044e4:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c01044eb:	e8 41 bf ff ff       	call   c0100431 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01044f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044f3:	89 04 24             	mov    %eax,(%esp)
c01044f6:	e8 54 e9 ff ff       	call   c0102e4f <page2kva>
c01044fb:	05 00 01 00 00       	add    $0x100,%eax
c0104500:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0104503:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010450a:	e8 59 22 00 00       	call   c0106768 <strlen>
c010450f:	85 c0                	test   %eax,%eax
c0104511:	74 24                	je     c0104537 <check_boot_pgdir+0x342>
c0104513:	c7 44 24 0c cc 7f 10 	movl   $0xc0107fcc,0xc(%esp)
c010451a:	c0 
c010451b:	c7 44 24 08 6d 7b 10 	movl   $0xc0107b6d,0x8(%esp)
c0104522:	c0 
c0104523:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c010452a:	00 
c010452b:	c7 04 24 48 7b 10 c0 	movl   $0xc0107b48,(%esp)
c0104532:	e8 fa be ff ff       	call   c0100431 <__panic>

    free_page(p);
c0104537:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010453e:	00 
c010453f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104542:	89 04 24             	mov    %eax,(%esp)
c0104545:	e8 01 ec ff ff       	call   c010314b <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010454a:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c010454f:	8b 00                	mov    (%eax),%eax
c0104551:	89 04 24             	mov    %eax,(%esp)
c0104554:	e8 88 e9 ff ff       	call   c0102ee1 <pde2page>
c0104559:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104560:	00 
c0104561:	89 04 24             	mov    %eax,(%esp)
c0104564:	e8 e2 eb ff ff       	call   c010314b <free_pages>
    boot_pgdir[0] = 0;
c0104569:	a1 e0 c9 11 c0       	mov    0xc011c9e0,%eax
c010456e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104574:	c7 04 24 f0 7f 10 c0 	movl   $0xc0107ff0,(%esp)
c010457b:	e8 45 bd ff ff       	call   c01002c5 <cprintf>
}
c0104580:	90                   	nop
c0104581:	c9                   	leave  
c0104582:	c3                   	ret    

c0104583 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104583:	f3 0f 1e fb          	endbr32 
c0104587:	55                   	push   %ebp
c0104588:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010458a:	8b 45 08             	mov    0x8(%ebp),%eax
c010458d:	83 e0 04             	and    $0x4,%eax
c0104590:	85 c0                	test   %eax,%eax
c0104592:	74 04                	je     c0104598 <perm2str+0x15>
c0104594:	b0 75                	mov    $0x75,%al
c0104596:	eb 02                	jmp    c010459a <perm2str+0x17>
c0104598:	b0 2d                	mov    $0x2d,%al
c010459a:	a2 08 ff 11 c0       	mov    %al,0xc011ff08
    str[1] = 'r';
c010459f:	c6 05 09 ff 11 c0 72 	movb   $0x72,0xc011ff09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01045a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a9:	83 e0 02             	and    $0x2,%eax
c01045ac:	85 c0                	test   %eax,%eax
c01045ae:	74 04                	je     c01045b4 <perm2str+0x31>
c01045b0:	b0 77                	mov    $0x77,%al
c01045b2:	eb 02                	jmp    c01045b6 <perm2str+0x33>
c01045b4:	b0 2d                	mov    $0x2d,%al
c01045b6:	a2 0a ff 11 c0       	mov    %al,0xc011ff0a
    str[3] = '\0';
c01045bb:	c6 05 0b ff 11 c0 00 	movb   $0x0,0xc011ff0b
    return str;
c01045c2:	b8 08 ff 11 c0       	mov    $0xc011ff08,%eax
}
c01045c7:	5d                   	pop    %ebp
c01045c8:	c3                   	ret    

c01045c9 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01045c9:	f3 0f 1e fb          	endbr32 
c01045cd:	55                   	push   %ebp
c01045ce:	89 e5                	mov    %esp,%ebp
c01045d0:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01045d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01045d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01045d9:	72 0d                	jb     c01045e8 <get_pgtable_items+0x1f>
        return 0;
c01045db:	b8 00 00 00 00       	mov    $0x0,%eax
c01045e0:	e9 98 00 00 00       	jmp    c010467d <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01045e5:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01045e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01045eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01045ee:	73 18                	jae    c0104608 <get_pgtable_items+0x3f>
c01045f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01045f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01045fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01045fd:	01 d0                	add    %edx,%eax
c01045ff:	8b 00                	mov    (%eax),%eax
c0104601:	83 e0 01             	and    $0x1,%eax
c0104604:	85 c0                	test   %eax,%eax
c0104606:	74 dd                	je     c01045e5 <get_pgtable_items+0x1c>
    }
    if (start < right) {
c0104608:	8b 45 10             	mov    0x10(%ebp),%eax
c010460b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010460e:	73 68                	jae    c0104678 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0104610:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104614:	74 08                	je     c010461e <get_pgtable_items+0x55>
            *left_store = start;
c0104616:	8b 45 18             	mov    0x18(%ebp),%eax
c0104619:	8b 55 10             	mov    0x10(%ebp),%edx
c010461c:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010461e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104621:	8d 50 01             	lea    0x1(%eax),%edx
c0104624:	89 55 10             	mov    %edx,0x10(%ebp)
c0104627:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010462e:	8b 45 14             	mov    0x14(%ebp),%eax
c0104631:	01 d0                	add    %edx,%eax
c0104633:	8b 00                	mov    (%eax),%eax
c0104635:	83 e0 07             	and    $0x7,%eax
c0104638:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010463b:	eb 03                	jmp    c0104640 <get_pgtable_items+0x77>
            start ++;
c010463d:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104640:	8b 45 10             	mov    0x10(%ebp),%eax
c0104643:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104646:	73 1d                	jae    c0104665 <get_pgtable_items+0x9c>
c0104648:	8b 45 10             	mov    0x10(%ebp),%eax
c010464b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104652:	8b 45 14             	mov    0x14(%ebp),%eax
c0104655:	01 d0                	add    %edx,%eax
c0104657:	8b 00                	mov    (%eax),%eax
c0104659:	83 e0 07             	and    $0x7,%eax
c010465c:	89 c2                	mov    %eax,%edx
c010465e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104661:	39 c2                	cmp    %eax,%edx
c0104663:	74 d8                	je     c010463d <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
c0104665:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104669:	74 08                	je     c0104673 <get_pgtable_items+0xaa>
            *right_store = start;
c010466b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010466e:	8b 55 10             	mov    0x10(%ebp),%edx
c0104671:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104673:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104676:	eb 05                	jmp    c010467d <get_pgtable_items+0xb4>
    }
    return 0;
c0104678:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010467d:	c9                   	leave  
c010467e:	c3                   	ret    

c010467f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010467f:	f3 0f 1e fb          	endbr32 
c0104683:	55                   	push   %ebp
c0104684:	89 e5                	mov    %esp,%ebp
c0104686:	57                   	push   %edi
c0104687:	56                   	push   %esi
c0104688:	53                   	push   %ebx
c0104689:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010468c:	c7 04 24 10 80 10 c0 	movl   $0xc0108010,(%esp)
c0104693:	e8 2d bc ff ff       	call   c01002c5 <cprintf>
    size_t left, right = 0, perm;
c0104698:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010469f:	e9 fa 00 00 00       	jmp    c010479e <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01046a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01046a7:	89 04 24             	mov    %eax,(%esp)
c01046aa:	e8 d4 fe ff ff       	call   c0104583 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01046af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01046b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01046b5:	29 d1                	sub    %edx,%ecx
c01046b7:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01046b9:	89 d6                	mov    %edx,%esi
c01046bb:	c1 e6 16             	shl    $0x16,%esi
c01046be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01046c1:	89 d3                	mov    %edx,%ebx
c01046c3:	c1 e3 16             	shl    $0x16,%ebx
c01046c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01046c9:	89 d1                	mov    %edx,%ecx
c01046cb:	c1 e1 16             	shl    $0x16,%ecx
c01046ce:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01046d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01046d4:	29 d7                	sub    %edx,%edi
c01046d6:	89 fa                	mov    %edi,%edx
c01046d8:	89 44 24 14          	mov    %eax,0x14(%esp)
c01046dc:	89 74 24 10          	mov    %esi,0x10(%esp)
c01046e0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01046e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01046e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046ec:	c7 04 24 41 80 10 c0 	movl   $0xc0108041,(%esp)
c01046f3:	e8 cd bb ff ff       	call   c01002c5 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01046f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01046fb:	c1 e0 0a             	shl    $0xa,%eax
c01046fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104701:	eb 54                	jmp    c0104757 <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104706:	89 04 24             	mov    %eax,(%esp)
c0104709:	e8 75 fe ff ff       	call   c0104583 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010470e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104711:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104714:	29 d1                	sub    %edx,%ecx
c0104716:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104718:	89 d6                	mov    %edx,%esi
c010471a:	c1 e6 0c             	shl    $0xc,%esi
c010471d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104720:	89 d3                	mov    %edx,%ebx
c0104722:	c1 e3 0c             	shl    $0xc,%ebx
c0104725:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104728:	89 d1                	mov    %edx,%ecx
c010472a:	c1 e1 0c             	shl    $0xc,%ecx
c010472d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104730:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104733:	29 d7                	sub    %edx,%edi
c0104735:	89 fa                	mov    %edi,%edx
c0104737:	89 44 24 14          	mov    %eax,0x14(%esp)
c010473b:	89 74 24 10          	mov    %esi,0x10(%esp)
c010473f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104743:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104747:	89 54 24 04          	mov    %edx,0x4(%esp)
c010474b:	c7 04 24 60 80 10 c0 	movl   $0xc0108060,(%esp)
c0104752:	e8 6e bb ff ff       	call   c01002c5 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104757:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010475c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010475f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104762:	89 d3                	mov    %edx,%ebx
c0104764:	c1 e3 0a             	shl    $0xa,%ebx
c0104767:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010476a:	89 d1                	mov    %edx,%ecx
c010476c:	c1 e1 0a             	shl    $0xa,%ecx
c010476f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104772:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104776:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104779:	89 54 24 10          	mov    %edx,0x10(%esp)
c010477d:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104781:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104785:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104789:	89 0c 24             	mov    %ecx,(%esp)
c010478c:	e8 38 fe ff ff       	call   c01045c9 <get_pgtable_items>
c0104791:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104794:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104798:	0f 85 65 ff ff ff    	jne    c0104703 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010479e:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01047a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047a6:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01047a9:	89 54 24 14          	mov    %edx,0x14(%esp)
c01047ad:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01047b0:	89 54 24 10          	mov    %edx,0x10(%esp)
c01047b4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01047b8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01047bc:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01047c3:	00 
c01047c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01047cb:	e8 f9 fd ff ff       	call   c01045c9 <get_pgtable_items>
c01047d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01047d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01047d7:	0f 85 c7 fe ff ff    	jne    c01046a4 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01047dd:	c7 04 24 84 80 10 c0 	movl   $0xc0108084,(%esp)
c01047e4:	e8 dc ba ff ff       	call   c01002c5 <cprintf>
}
c01047e9:	90                   	nop
c01047ea:	83 c4 4c             	add    $0x4c,%esp
c01047ed:	5b                   	pop    %ebx
c01047ee:	5e                   	pop    %esi
c01047ef:	5f                   	pop    %edi
c01047f0:	5d                   	pop    %ebp
c01047f1:	c3                   	ret    

c01047f2 <page2ppn>:
page2ppn(struct Page *page) {
c01047f2:	55                   	push   %ebp
c01047f3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01047f5:	a1 78 ff 11 c0       	mov    0xc011ff78,%eax
c01047fa:	8b 55 08             	mov    0x8(%ebp),%edx
c01047fd:	29 c2                	sub    %eax,%edx
c01047ff:	89 d0                	mov    %edx,%eax
c0104801:	c1 f8 02             	sar    $0x2,%eax
c0104804:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010480a:	5d                   	pop    %ebp
c010480b:	c3                   	ret    

c010480c <page2pa>:
page2pa(struct Page *page) {
c010480c:	55                   	push   %ebp
c010480d:	89 e5                	mov    %esp,%ebp
c010480f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104812:	8b 45 08             	mov    0x8(%ebp),%eax
c0104815:	89 04 24             	mov    %eax,(%esp)
c0104818:	e8 d5 ff ff ff       	call   c01047f2 <page2ppn>
c010481d:	c1 e0 0c             	shl    $0xc,%eax
}
c0104820:	c9                   	leave  
c0104821:	c3                   	ret    

c0104822 <page_ref>:
page_ref(struct Page *page) {
c0104822:	55                   	push   %ebp
c0104823:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104825:	8b 45 08             	mov    0x8(%ebp),%eax
c0104828:	8b 00                	mov    (%eax),%eax
}
c010482a:	5d                   	pop    %ebp
c010482b:	c3                   	ret    

c010482c <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010482c:	55                   	push   %ebp
c010482d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010482f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104832:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104835:	89 10                	mov    %edx,(%eax)
}
c0104837:	90                   	nop
c0104838:	5d                   	pop    %ebp
c0104839:	c3                   	ret    

c010483a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010483a:	f3 0f 1e fb          	endbr32 
c010483e:	55                   	push   %ebp
c010483f:	89 e5                	mov    %esp,%ebp
c0104841:	83 ec 10             	sub    $0x10,%esp
c0104844:	c7 45 fc 7c ff 11 c0 	movl   $0xc011ff7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010484b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010484e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104851:	89 50 04             	mov    %edx,0x4(%eax)
c0104854:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104857:	8b 50 04             	mov    0x4(%eax),%edx
c010485a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010485d:	89 10                	mov    %edx,(%eax)
}
c010485f:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0104860:	c7 05 84 ff 11 c0 00 	movl   $0x0,0xc011ff84
c0104867:	00 00 00 
}
c010486a:	90                   	nop
c010486b:	c9                   	leave  
c010486c:	c3                   	ret    

c010486d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010486d:	f3 0f 1e fb          	endbr32 
c0104871:	55                   	push   %ebp
c0104872:	89 e5                	mov    %esp,%ebp
c0104874:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0104877:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010487b:	75 24                	jne    c01048a1 <default_init_memmap+0x34>
c010487d:	c7 44 24 0c b8 80 10 	movl   $0xc01080b8,0xc(%esp)
c0104884:	c0 
c0104885:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010488c:	c0 
c010488d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104894:	00 
c0104895:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010489c:	e8 90 bb ff ff       	call   c0100431 <__panic>
    struct Page *p = base;
c01048a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01048a7:	eb 7d                	jmp    c0104926 <default_init_memmap+0xb9>
        assert(PageReserved(p));
c01048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ac:	83 c0 04             	add    $0x4,%eax
c01048af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01048b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01048b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048bf:	0f a3 10             	bt     %edx,(%eax)
c01048c2:	19 c0                	sbb    %eax,%eax
c01048c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01048c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01048cb:	0f 95 c0             	setne  %al
c01048ce:	0f b6 c0             	movzbl %al,%eax
c01048d1:	85 c0                	test   %eax,%eax
c01048d3:	75 24                	jne    c01048f9 <default_init_memmap+0x8c>
c01048d5:	c7 44 24 0c e9 80 10 	movl   $0xc01080e9,0xc(%esp)
c01048dc:	c0 
c01048dd:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01048e4:	c0 
c01048e5:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01048ec:	00 
c01048ed:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01048f4:	e8 38 bb ff ff       	call   c0100431 <__panic>
        p->flags = p->property = 0;
c01048f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104903:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104906:	8b 50 08             	mov    0x8(%eax),%edx
c0104909:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490c:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010490f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104916:	00 
c0104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010491a:	89 04 24             	mov    %eax,(%esp)
c010491d:	e8 0a ff ff ff       	call   c010482c <set_page_ref>
    for (; p != base + n; p ++) {
c0104922:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104926:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104929:	89 d0                	mov    %edx,%eax
c010492b:	c1 e0 02             	shl    $0x2,%eax
c010492e:	01 d0                	add    %edx,%eax
c0104930:	c1 e0 02             	shl    $0x2,%eax
c0104933:	89 c2                	mov    %eax,%edx
c0104935:	8b 45 08             	mov    0x8(%ebp),%eax
c0104938:	01 d0                	add    %edx,%eax
c010493a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010493d:	0f 85 66 ff ff ff    	jne    c01048a9 <default_init_memmap+0x3c>
    }
    base->property = n;
c0104943:	8b 45 08             	mov    0x8(%ebp),%eax
c0104946:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104949:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010494c:	8b 45 08             	mov    0x8(%ebp),%eax
c010494f:	83 c0 04             	add    $0x4,%eax
c0104952:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104959:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010495c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010495f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104962:	0f ab 10             	bts    %edx,(%eax)
}
c0104965:	90                   	nop
    nr_free += n;
c0104966:	8b 15 84 ff 11 c0    	mov    0xc011ff84,%edx
c010496c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010496f:	01 d0                	add    %edx,%eax
c0104971:	a3 84 ff 11 c0       	mov    %eax,0xc011ff84
    list_add(&free_list, &(base->page_link));
c0104976:	8b 45 08             	mov    0x8(%ebp),%eax
c0104979:	83 c0 0c             	add    $0xc,%eax
c010497c:	c7 45 e4 7c ff 11 c0 	movl   $0xc011ff7c,-0x1c(%ebp)
c0104983:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104989:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010498c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010498f:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0104992:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104995:	8b 40 04             	mov    0x4(%eax),%eax
c0104998:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010499b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010499e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01049a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01049a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01049aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01049ad:	89 10                	mov    %edx,(%eax)
c01049af:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01049b2:	8b 10                	mov    (%eax),%edx
c01049b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01049b7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01049ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01049bd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01049c0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01049c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01049c6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01049c9:	89 10                	mov    %edx,(%eax)
}
c01049cb:	90                   	nop
}
c01049cc:	90                   	nop
}
c01049cd:	90                   	nop
}
c01049ce:	90                   	nop
c01049cf:	c9                   	leave  
c01049d0:	c3                   	ret    

c01049d1 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01049d1:	f3 0f 1e fb          	endbr32 
c01049d5:	55                   	push   %ebp
c01049d6:	89 e5                	mov    %esp,%ebp
c01049d8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01049db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01049df:	75 24                	jne    c0104a05 <default_alloc_pages+0x34>
c01049e1:	c7 44 24 0c b8 80 10 	movl   $0xc01080b8,0xc(%esp)
c01049e8:	c0 
c01049e9:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01049f0:	c0 
c01049f1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01049f8:	00 
c01049f9:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104a00:	e8 2c ba ff ff       	call   c0100431 <__panic>
    if (n > nr_free) {
c0104a05:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c0104a0a:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104a0d:	76 0a                	jbe    c0104a19 <default_alloc_pages+0x48>
        return NULL;
c0104a0f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a14:	e9 4e 01 00 00       	jmp    c0104b67 <default_alloc_pages+0x196>
    }
    struct Page *page = NULL;
c0104a19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104a20:	c7 45 f0 7c ff 11 c0 	movl   $0xc011ff7c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104a27:	eb 1c                	jmp    c0104a45 <default_alloc_pages+0x74>
        struct Page *p = le2page(le, page_link);
c0104a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a2c:	83 e8 0c             	sub    $0xc,%eax
c0104a2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0104a32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a35:	8b 40 08             	mov    0x8(%eax),%eax
c0104a38:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104a3b:	77 08                	ja     c0104a45 <default_alloc_pages+0x74>
            page = p;
c0104a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
            //SetPageReserved(page);
            break;
c0104a43:	eb 18                	jmp    c0104a5d <default_alloc_pages+0x8c>
c0104a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0104a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a4e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104a51:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a54:	81 7d f0 7c ff 11 c0 	cmpl   $0xc011ff7c,-0x10(%ebp)
c0104a5b:	75 cc                	jne    c0104a29 <default_alloc_pages+0x58>
        }
    }
    if (page != NULL) {
c0104a5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a61:	0f 84 fd 00 00 00    	je     c0104b64 <default_alloc_pages+0x193>
        //list_del(&(page->page_link));
        if (page->property > n) {
c0104a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6a:	8b 40 08             	mov    0x8(%eax),%eax
c0104a6d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104a70:	0f 83 9a 00 00 00    	jae    c0104b10 <default_alloc_pages+0x13f>
            struct Page *p = page + n;
c0104a76:	8b 55 08             	mov    0x8(%ebp),%edx
c0104a79:	89 d0                	mov    %edx,%eax
c0104a7b:	c1 e0 02             	shl    $0x2,%eax
c0104a7e:	01 d0                	add    %edx,%eax
c0104a80:	c1 e0 02             	shl    $0x2,%eax
c0104a83:	89 c2                	mov    %eax,%edx
c0104a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a88:	01 d0                	add    %edx,%eax
c0104a8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a90:	8b 40 08             	mov    0x8(%eax),%eax
c0104a93:	2b 45 08             	sub    0x8(%ebp),%eax
c0104a96:	89 c2                	mov    %eax,%edx
c0104a98:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a9b:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0104a9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104aa1:	83 c0 04             	add    $0x4,%eax
c0104aa4:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104aab:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104aae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104ab1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104ab4:	0f ab 10             	bts    %edx,(%eax)
}
c0104ab7:	90                   	nop
            //ClearPageReserved(p);
            list_add(&free_list, &(p->page_link));
c0104ab8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104abb:	83 c0 0c             	add    $0xc,%eax
c0104abe:	c7 45 e0 7c ff 11 c0 	movl   $0xc011ff7c,-0x20(%ebp)
c0104ac5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104acb:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104ace:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104ad1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104ad4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ad7:	8b 40 04             	mov    0x4(%eax),%eax
c0104ada:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104add:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104ae0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104ae3:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104ae6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0104ae9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104aec:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104aef:	89 10                	mov    %edx,(%eax)
c0104af1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104af4:	8b 10                	mov    (%eax),%edx
c0104af6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104af9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104afc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104aff:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104b02:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104b05:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b08:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104b0b:	89 10                	mov    %edx,(%eax)
}
c0104b0d:	90                   	nop
}
c0104b0e:	90                   	nop
}
c0104b0f:	90                   	nop
    }
        list_del(&(page->page_link));
c0104b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b13:	83 c0 0c             	add    $0xc,%eax
c0104b16:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104b19:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104b1c:	8b 40 04             	mov    0x4(%eax),%eax
c0104b1f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104b22:	8b 12                	mov    (%edx),%edx
c0104b24:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0104b27:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104b2a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104b2d:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104b30:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104b33:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104b36:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104b39:	89 10                	mov    %edx,(%eax)
}
c0104b3b:	90                   	nop
}
c0104b3c:	90                   	nop
        nr_free -= n;
c0104b3d:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c0104b42:	2b 45 08             	sub    0x8(%ebp),%eax
c0104b45:	a3 84 ff 11 c0       	mov    %eax,0xc011ff84
        ClearPageProperty(page);
c0104b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b4d:	83 c0 04             	add    $0x4,%eax
c0104b50:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104b57:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b5a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104b5d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104b60:	0f b3 10             	btr    %edx,(%eax)
}
c0104b63:	90                   	nop
    }
    return page;
c0104b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104b67:	c9                   	leave  
c0104b68:	c3                   	ret    

c0104b69 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104b69:	f3 0f 1e fb          	endbr32 
c0104b6d:	55                   	push   %ebp
c0104b6e:	89 e5                	mov    %esp,%ebp
c0104b70:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104b76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104b7a:	75 24                	jne    c0104ba0 <default_free_pages+0x37>
c0104b7c:	c7 44 24 0c b8 80 10 	movl   $0xc01080b8,0xc(%esp)
c0104b83:	c0 
c0104b84:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104b8b:	c0 
c0104b8c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104b93:	00 
c0104b94:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104b9b:	e8 91 b8 ff ff       	call   c0100431 <__panic>
    struct Page *p = base;
c0104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104ba6:	e9 9d 00 00 00       	jmp    c0104c48 <default_free_pages+0xdf>
        assert(!PageReserved(p) && !PageProperty(p));
c0104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bae:	83 c0 04             	add    $0x4,%eax
c0104bb1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bbe:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104bc1:	0f a3 10             	bt     %edx,(%eax)
c0104bc4:	19 c0                	sbb    %eax,%eax
c0104bc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104bc9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104bcd:	0f 95 c0             	setne  %al
c0104bd0:	0f b6 c0             	movzbl %al,%eax
c0104bd3:	85 c0                	test   %eax,%eax
c0104bd5:	75 2c                	jne    c0104c03 <default_free_pages+0x9a>
c0104bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bda:	83 c0 04             	add    $0x4,%eax
c0104bdd:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104be4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104be7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104bea:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104bed:	0f a3 10             	bt     %edx,(%eax)
c0104bf0:	19 c0                	sbb    %eax,%eax
c0104bf2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0104bf5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104bf9:	0f 95 c0             	setne  %al
c0104bfc:	0f b6 c0             	movzbl %al,%eax
c0104bff:	85 c0                	test   %eax,%eax
c0104c01:	74 24                	je     c0104c27 <default_free_pages+0xbe>
c0104c03:	c7 44 24 0c fc 80 10 	movl   $0xc01080fc,0xc(%esp)
c0104c0a:	c0 
c0104c0b:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104c12:	c0 
c0104c13:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0104c1a:	00 
c0104c1b:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104c22:	e8 0a b8 ff ff       	call   c0100431 <__panic>
        p->flags = 0;
c0104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104c31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c38:	00 
c0104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3c:	89 04 24             	mov    %eax,(%esp)
c0104c3f:	e8 e8 fb ff ff       	call   c010482c <set_page_ref>
    for (; p != base + n; p ++) {
c0104c44:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104c48:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104c4b:	89 d0                	mov    %edx,%eax
c0104c4d:	c1 e0 02             	shl    $0x2,%eax
c0104c50:	01 d0                	add    %edx,%eax
c0104c52:	c1 e0 02             	shl    $0x2,%eax
c0104c55:	89 c2                	mov    %eax,%edx
c0104c57:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c5a:	01 d0                	add    %edx,%eax
c0104c5c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104c5f:	0f 85 46 ff ff ff    	jne    c0104bab <default_free_pages+0x42>
    }
    base->property = n;
c0104c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c68:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104c6b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104c6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c71:	83 c0 04             	add    $0x4,%eax
c0104c74:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104c7b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104c7e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c81:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104c84:	0f ab 10             	bts    %edx,(%eax)
}
c0104c87:	90                   	nop
c0104c88:	c7 45 d4 7c ff 11 c0 	movl   $0xc011ff7c,-0x2c(%ebp)
    return listelm->next;
c0104c8f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c92:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104c98:	e9 0e 01 00 00       	jmp    c0104dab <default_free_pages+0x242>
        p = le2page(le, page_link);
c0104c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ca0:	83 e8 0c             	sub    $0xc,%eax
c0104ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ca9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104cac:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104caf:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0104cb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb8:	8b 50 08             	mov    0x8(%eax),%edx
c0104cbb:	89 d0                	mov    %edx,%eax
c0104cbd:	c1 e0 02             	shl    $0x2,%eax
c0104cc0:	01 d0                	add    %edx,%eax
c0104cc2:	c1 e0 02             	shl    $0x2,%eax
c0104cc5:	89 c2                	mov    %eax,%edx
c0104cc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cca:	01 d0                	add    %edx,%eax
c0104ccc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104ccf:	75 5d                	jne    c0104d2e <default_free_pages+0x1c5>
            base->property += p->property;
c0104cd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd4:	8b 50 08             	mov    0x8(%eax),%edx
c0104cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cda:	8b 40 08             	mov    0x8(%eax),%eax
c0104cdd:	01 c2                	add    %eax,%edx
c0104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ce2:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ce8:	83 c0 04             	add    $0x4,%eax
c0104ceb:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0104cf2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104cf5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cf8:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104cfb:	0f b3 10             	btr    %edx,(%eax)
}
c0104cfe:	90                   	nop
            list_del(&(p->page_link));
c0104cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d02:	83 c0 0c             	add    $0xc,%eax
c0104d05:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104d08:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d0b:	8b 40 04             	mov    0x4(%eax),%eax
c0104d0e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104d11:	8b 12                	mov    (%edx),%edx
c0104d13:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104d16:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104d19:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104d1c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104d1f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104d22:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104d25:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104d28:	89 10                	mov    %edx,(%eax)
}
c0104d2a:	90                   	nop
}
c0104d2b:	90                   	nop
c0104d2c:	eb 7d                	jmp    c0104dab <default_free_pages+0x242>
        }
        else if (p + p->property == base) {
c0104d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d31:	8b 50 08             	mov    0x8(%eax),%edx
c0104d34:	89 d0                	mov    %edx,%eax
c0104d36:	c1 e0 02             	shl    $0x2,%eax
c0104d39:	01 d0                	add    %edx,%eax
c0104d3b:	c1 e0 02             	shl    $0x2,%eax
c0104d3e:	89 c2                	mov    %eax,%edx
c0104d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d43:	01 d0                	add    %edx,%eax
c0104d45:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104d48:	75 61                	jne    c0104dab <default_free_pages+0x242>
            p->property += base->property;
c0104d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d4d:	8b 50 08             	mov    0x8(%eax),%edx
c0104d50:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d53:	8b 40 08             	mov    0x8(%eax),%eax
c0104d56:	01 c2                	add    %eax,%edx
c0104d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d5b:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104d5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d61:	83 c0 04             	add    $0x4,%eax
c0104d64:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104d6b:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104d6e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104d71:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104d74:	0f b3 10             	btr    %edx,(%eax)
}
c0104d77:	90                   	nop
            base = p;
c0104d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d7b:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d81:	83 c0 0c             	add    $0xc,%eax
c0104d84:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104d87:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d8a:	8b 40 04             	mov    0x4(%eax),%eax
c0104d8d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104d90:	8b 12                	mov    (%edx),%edx
c0104d92:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0104d95:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0104d98:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d9b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104d9e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104da1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104da4:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104da7:	89 10                	mov    %edx,(%eax)
}
c0104da9:	90                   	nop
}
c0104daa:	90                   	nop
    while (le != &free_list) {
c0104dab:	81 7d f0 7c ff 11 c0 	cmpl   $0xc011ff7c,-0x10(%ebp)
c0104db2:	0f 85 e5 fe ff ff    	jne    c0104c9d <default_free_pages+0x134>
        }
    }
    nr_free += n;
c0104db8:	8b 15 84 ff 11 c0    	mov    0xc011ff84,%edx
c0104dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dc1:	01 d0                	add    %edx,%eax
c0104dc3:	a3 84 ff 11 c0       	mov    %eax,0xc011ff84
c0104dc8:	c7 45 9c 7c ff 11 c0 	movl   $0xc011ff7c,-0x64(%ebp)
    return listelm->next;
c0104dcf:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104dd2:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0104dd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104dd8:	eb 74                	jmp    c0104e4e <default_free_pages+0x2e5>
        p = le2page(le, page_link);
c0104dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ddd:	83 e8 0c             	sub    $0xc,%eax
c0104de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0104de3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104de6:	8b 50 08             	mov    0x8(%eax),%edx
c0104de9:	89 d0                	mov    %edx,%eax
c0104deb:	c1 e0 02             	shl    $0x2,%eax
c0104dee:	01 d0                	add    %edx,%eax
c0104df0:	c1 e0 02             	shl    $0x2,%eax
c0104df3:	89 c2                	mov    %eax,%edx
c0104df5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104df8:	01 d0                	add    %edx,%eax
c0104dfa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104dfd:	72 40                	jb     c0104e3f <default_free_pages+0x2d6>
            assert(base + base->property != p);
c0104dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e02:	8b 50 08             	mov    0x8(%eax),%edx
c0104e05:	89 d0                	mov    %edx,%eax
c0104e07:	c1 e0 02             	shl    $0x2,%eax
c0104e0a:	01 d0                	add    %edx,%eax
c0104e0c:	c1 e0 02             	shl    $0x2,%eax
c0104e0f:	89 c2                	mov    %eax,%edx
c0104e11:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e14:	01 d0                	add    %edx,%eax
c0104e16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104e19:	75 3e                	jne    c0104e59 <default_free_pages+0x2f0>
c0104e1b:	c7 44 24 0c 21 81 10 	movl   $0xc0108121,0xc(%esp)
c0104e22:	c0 
c0104e23:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104e2a:	c0 
c0104e2b:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0104e32:	00 
c0104e33:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104e3a:	e8 f2 b5 ff ff       	call   c0100431 <__panic>
c0104e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e42:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104e45:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104e48:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0104e4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104e4e:	81 7d f0 7c ff 11 c0 	cmpl   $0xc011ff7c,-0x10(%ebp)
c0104e55:	75 83                	jne    c0104dda <default_free_pages+0x271>
c0104e57:	eb 01                	jmp    c0104e5a <default_free_pages+0x2f1>
            break;
c0104e59:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c0104e5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e5d:	8d 50 0c             	lea    0xc(%eax),%edx
c0104e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e63:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104e66:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104e69:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104e6c:	8b 00                	mov    (%eax),%eax
c0104e6e:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104e71:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104e74:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104e77:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104e7a:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0104e7d:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104e80:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104e83:	89 10                	mov    %edx,(%eax)
c0104e85:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104e88:	8b 10                	mov    (%eax),%edx
c0104e8a:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104e8d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104e90:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104e93:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104e96:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104e99:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104e9c:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104e9f:	89 10                	mov    %edx,(%eax)
}
c0104ea1:	90                   	nop
}
c0104ea2:	90                   	nop
}
c0104ea3:	90                   	nop
c0104ea4:	c9                   	leave  
c0104ea5:	c3                   	ret    

c0104ea6 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104ea6:	f3 0f 1e fb          	endbr32 
c0104eaa:	55                   	push   %ebp
c0104eab:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104ead:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
}
c0104eb2:	5d                   	pop    %ebp
c0104eb3:	c3                   	ret    

c0104eb4 <basic_check>:

static void
basic_check(void) {
c0104eb4:	f3 0f 1e fb          	endbr32 
c0104eb8:	55                   	push   %ebp
c0104eb9:	89 e5                	mov    %esp,%ebp
c0104ebb:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104ebe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ece:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104ed1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ed8:	e8 32 e2 ff ff       	call   c010310f <alloc_pages>
c0104edd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ee0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104ee4:	75 24                	jne    c0104f0a <basic_check+0x56>
c0104ee6:	c7 44 24 0c 3c 81 10 	movl   $0xc010813c,0xc(%esp)
c0104eed:	c0 
c0104eee:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104ef5:	c0 
c0104ef6:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104efd:	00 
c0104efe:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104f05:	e8 27 b5 ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104f0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f11:	e8 f9 e1 ff ff       	call   c010310f <alloc_pages>
c0104f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f1d:	75 24                	jne    c0104f43 <basic_check+0x8f>
c0104f1f:	c7 44 24 0c 58 81 10 	movl   $0xc0108158,0xc(%esp)
c0104f26:	c0 
c0104f27:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104f2e:	c0 
c0104f2f:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104f36:	00 
c0104f37:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104f3e:	e8 ee b4 ff ff       	call   c0100431 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104f43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f4a:	e8 c0 e1 ff ff       	call   c010310f <alloc_pages>
c0104f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f56:	75 24                	jne    c0104f7c <basic_check+0xc8>
c0104f58:	c7 44 24 0c 74 81 10 	movl   $0xc0108174,0xc(%esp)
c0104f5f:	c0 
c0104f60:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104f67:	c0 
c0104f68:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104f6f:	00 
c0104f70:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104f77:	e8 b5 b4 ff ff       	call   c0100431 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f7f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104f82:	74 10                	je     c0104f94 <basic_check+0xe0>
c0104f84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f87:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f8a:	74 08                	je     c0104f94 <basic_check+0xe0>
c0104f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f8f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f92:	75 24                	jne    c0104fb8 <basic_check+0x104>
c0104f94:	c7 44 24 0c 90 81 10 	movl   $0xc0108190,0xc(%esp)
c0104f9b:	c0 
c0104f9c:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104fa3:	c0 
c0104fa4:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104fab:	00 
c0104fac:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0104fb3:	e8 79 b4 ff ff       	call   c0100431 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fbb:	89 04 24             	mov    %eax,(%esp)
c0104fbe:	e8 5f f8 ff ff       	call   c0104822 <page_ref>
c0104fc3:	85 c0                	test   %eax,%eax
c0104fc5:	75 1e                	jne    c0104fe5 <basic_check+0x131>
c0104fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fca:	89 04 24             	mov    %eax,(%esp)
c0104fcd:	e8 50 f8 ff ff       	call   c0104822 <page_ref>
c0104fd2:	85 c0                	test   %eax,%eax
c0104fd4:	75 0f                	jne    c0104fe5 <basic_check+0x131>
c0104fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd9:	89 04 24             	mov    %eax,(%esp)
c0104fdc:	e8 41 f8 ff ff       	call   c0104822 <page_ref>
c0104fe1:	85 c0                	test   %eax,%eax
c0104fe3:	74 24                	je     c0105009 <basic_check+0x155>
c0104fe5:	c7 44 24 0c b4 81 10 	movl   $0xc01081b4,0xc(%esp)
c0104fec:	c0 
c0104fed:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0104ff4:	c0 
c0104ff5:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104ffc:	00 
c0104ffd:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105004:	e8 28 b4 ff ff       	call   c0100431 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105009:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010500c:	89 04 24             	mov    %eax,(%esp)
c010500f:	e8 f8 f7 ff ff       	call   c010480c <page2pa>
c0105014:	8b 15 80 fe 11 c0    	mov    0xc011fe80,%edx
c010501a:	c1 e2 0c             	shl    $0xc,%edx
c010501d:	39 d0                	cmp    %edx,%eax
c010501f:	72 24                	jb     c0105045 <basic_check+0x191>
c0105021:	c7 44 24 0c f0 81 10 	movl   $0xc01081f0,0xc(%esp)
c0105028:	c0 
c0105029:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105030:	c0 
c0105031:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0105038:	00 
c0105039:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105040:	e8 ec b3 ff ff       	call   c0100431 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105045:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105048:	89 04 24             	mov    %eax,(%esp)
c010504b:	e8 bc f7 ff ff       	call   c010480c <page2pa>
c0105050:	8b 15 80 fe 11 c0    	mov    0xc011fe80,%edx
c0105056:	c1 e2 0c             	shl    $0xc,%edx
c0105059:	39 d0                	cmp    %edx,%eax
c010505b:	72 24                	jb     c0105081 <basic_check+0x1cd>
c010505d:	c7 44 24 0c 0d 82 10 	movl   $0xc010820d,0xc(%esp)
c0105064:	c0 
c0105065:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010506c:	c0 
c010506d:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0105074:	00 
c0105075:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010507c:	e8 b0 b3 ff ff       	call   c0100431 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105081:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105084:	89 04 24             	mov    %eax,(%esp)
c0105087:	e8 80 f7 ff ff       	call   c010480c <page2pa>
c010508c:	8b 15 80 fe 11 c0    	mov    0xc011fe80,%edx
c0105092:	c1 e2 0c             	shl    $0xc,%edx
c0105095:	39 d0                	cmp    %edx,%eax
c0105097:	72 24                	jb     c01050bd <basic_check+0x209>
c0105099:	c7 44 24 0c 2a 82 10 	movl   $0xc010822a,0xc(%esp)
c01050a0:	c0 
c01050a1:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01050a8:	c0 
c01050a9:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01050b0:	00 
c01050b1:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01050b8:	e8 74 b3 ff ff       	call   c0100431 <__panic>

    list_entry_t free_list_store = free_list;
c01050bd:	a1 7c ff 11 c0       	mov    0xc011ff7c,%eax
c01050c2:	8b 15 80 ff 11 c0    	mov    0xc011ff80,%edx
c01050c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01050cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01050ce:	c7 45 dc 7c ff 11 c0 	movl   $0xc011ff7c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c01050d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050db:	89 50 04             	mov    %edx,0x4(%eax)
c01050de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050e1:	8b 50 04             	mov    0x4(%eax),%edx
c01050e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050e7:	89 10                	mov    %edx,(%eax)
}
c01050e9:	90                   	nop
c01050ea:	c7 45 e0 7c ff 11 c0 	movl   $0xc011ff7c,-0x20(%ebp)
    return list->next == list;
c01050f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050f4:	8b 40 04             	mov    0x4(%eax),%eax
c01050f7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01050fa:	0f 94 c0             	sete   %al
c01050fd:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105100:	85 c0                	test   %eax,%eax
c0105102:	75 24                	jne    c0105128 <basic_check+0x274>
c0105104:	c7 44 24 0c 47 82 10 	movl   $0xc0108247,0xc(%esp)
c010510b:	c0 
c010510c:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105113:	c0 
c0105114:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c010511b:	00 
c010511c:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105123:	e8 09 b3 ff ff       	call   c0100431 <__panic>

    unsigned int nr_free_store = nr_free;
c0105128:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c010512d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0105130:	c7 05 84 ff 11 c0 00 	movl   $0x0,0xc011ff84
c0105137:	00 00 00 

    assert(alloc_page() == NULL);
c010513a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105141:	e8 c9 df ff ff       	call   c010310f <alloc_pages>
c0105146:	85 c0                	test   %eax,%eax
c0105148:	74 24                	je     c010516e <basic_check+0x2ba>
c010514a:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c0105151:	c0 
c0105152:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105159:	c0 
c010515a:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0105161:	00 
c0105162:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105169:	e8 c3 b2 ff ff       	call   c0100431 <__panic>

    free_page(p0);
c010516e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105175:	00 
c0105176:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105179:	89 04 24             	mov    %eax,(%esp)
c010517c:	e8 ca df ff ff       	call   c010314b <free_pages>
    free_page(p1);
c0105181:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105188:	00 
c0105189:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010518c:	89 04 24             	mov    %eax,(%esp)
c010518f:	e8 b7 df ff ff       	call   c010314b <free_pages>
    free_page(p2);
c0105194:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010519b:	00 
c010519c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010519f:	89 04 24             	mov    %eax,(%esp)
c01051a2:	e8 a4 df ff ff       	call   c010314b <free_pages>
    assert(nr_free == 3);
c01051a7:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c01051ac:	83 f8 03             	cmp    $0x3,%eax
c01051af:	74 24                	je     c01051d5 <basic_check+0x321>
c01051b1:	c7 44 24 0c 73 82 10 	movl   $0xc0108273,0xc(%esp)
c01051b8:	c0 
c01051b9:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01051c0:	c0 
c01051c1:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01051c8:	00 
c01051c9:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01051d0:	e8 5c b2 ff ff       	call   c0100431 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01051d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051dc:	e8 2e df ff ff       	call   c010310f <alloc_pages>
c01051e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01051e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01051e8:	75 24                	jne    c010520e <basic_check+0x35a>
c01051ea:	c7 44 24 0c 3c 81 10 	movl   $0xc010813c,0xc(%esp)
c01051f1:	c0 
c01051f2:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01051f9:	c0 
c01051fa:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0105201:	00 
c0105202:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105209:	e8 23 b2 ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010520e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105215:	e8 f5 de ff ff       	call   c010310f <alloc_pages>
c010521a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010521d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105221:	75 24                	jne    c0105247 <basic_check+0x393>
c0105223:	c7 44 24 0c 58 81 10 	movl   $0xc0108158,0xc(%esp)
c010522a:	c0 
c010522b:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105232:	c0 
c0105233:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c010523a:	00 
c010523b:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105242:	e8 ea b1 ff ff       	call   c0100431 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105247:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010524e:	e8 bc de ff ff       	call   c010310f <alloc_pages>
c0105253:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010525a:	75 24                	jne    c0105280 <basic_check+0x3cc>
c010525c:	c7 44 24 0c 74 81 10 	movl   $0xc0108174,0xc(%esp)
c0105263:	c0 
c0105264:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010526b:	c0 
c010526c:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0105273:	00 
c0105274:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010527b:	e8 b1 b1 ff ff       	call   c0100431 <__panic>

    assert(alloc_page() == NULL);
c0105280:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105287:	e8 83 de ff ff       	call   c010310f <alloc_pages>
c010528c:	85 c0                	test   %eax,%eax
c010528e:	74 24                	je     c01052b4 <basic_check+0x400>
c0105290:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c0105297:	c0 
c0105298:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010529f:	c0 
c01052a0:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01052a7:	00 
c01052a8:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01052af:	e8 7d b1 ff ff       	call   c0100431 <__panic>

    free_page(p0);
c01052b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052bb:	00 
c01052bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052bf:	89 04 24             	mov    %eax,(%esp)
c01052c2:	e8 84 de ff ff       	call   c010314b <free_pages>
c01052c7:	c7 45 d8 7c ff 11 c0 	movl   $0xc011ff7c,-0x28(%ebp)
c01052ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01052d1:	8b 40 04             	mov    0x4(%eax),%eax
c01052d4:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01052d7:	0f 94 c0             	sete   %al
c01052da:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01052dd:	85 c0                	test   %eax,%eax
c01052df:	74 24                	je     c0105305 <basic_check+0x451>
c01052e1:	c7 44 24 0c 80 82 10 	movl   $0xc0108280,0xc(%esp)
c01052e8:	c0 
c01052e9:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01052f0:	c0 
c01052f1:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01052f8:	00 
c01052f9:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105300:	e8 2c b1 ff ff       	call   c0100431 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105305:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010530c:	e8 fe dd ff ff       	call   c010310f <alloc_pages>
c0105311:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105317:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010531a:	74 24                	je     c0105340 <basic_check+0x48c>
c010531c:	c7 44 24 0c 98 82 10 	movl   $0xc0108298,0xc(%esp)
c0105323:	c0 
c0105324:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010532b:	c0 
c010532c:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0105333:	00 
c0105334:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010533b:	e8 f1 b0 ff ff       	call   c0100431 <__panic>
    assert(alloc_page() == NULL);
c0105340:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105347:	e8 c3 dd ff ff       	call   c010310f <alloc_pages>
c010534c:	85 c0                	test   %eax,%eax
c010534e:	74 24                	je     c0105374 <basic_check+0x4c0>
c0105350:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c0105357:	c0 
c0105358:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010535f:	c0 
c0105360:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0105367:	00 
c0105368:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010536f:	e8 bd b0 ff ff       	call   c0100431 <__panic>

    assert(nr_free == 0);
c0105374:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c0105379:	85 c0                	test   %eax,%eax
c010537b:	74 24                	je     c01053a1 <basic_check+0x4ed>
c010537d:	c7 44 24 0c b1 82 10 	movl   $0xc01082b1,0xc(%esp)
c0105384:	c0 
c0105385:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010538c:	c0 
c010538d:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0105394:	00 
c0105395:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010539c:	e8 90 b0 ff ff       	call   c0100431 <__panic>
    free_list = free_list_store;
c01053a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053a7:	a3 7c ff 11 c0       	mov    %eax,0xc011ff7c
c01053ac:	89 15 80 ff 11 c0    	mov    %edx,0xc011ff80
    nr_free = nr_free_store;
c01053b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053b5:	a3 84 ff 11 c0       	mov    %eax,0xc011ff84

    free_page(p);
c01053ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053c1:	00 
c01053c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053c5:	89 04 24             	mov    %eax,(%esp)
c01053c8:	e8 7e dd ff ff       	call   c010314b <free_pages>
    free_page(p1);
c01053cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053d4:	00 
c01053d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d8:	89 04 24             	mov    %eax,(%esp)
c01053db:	e8 6b dd ff ff       	call   c010314b <free_pages>
    free_page(p2);
c01053e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053e7:	00 
c01053e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053eb:	89 04 24             	mov    %eax,(%esp)
c01053ee:	e8 58 dd ff ff       	call   c010314b <free_pages>
}
c01053f3:	90                   	nop
c01053f4:	c9                   	leave  
c01053f5:	c3                   	ret    

c01053f6 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01053f6:	f3 0f 1e fb          	endbr32 
c01053fa:	55                   	push   %ebp
c01053fb:	89 e5                	mov    %esp,%ebp
c01053fd:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0105403:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010540a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105411:	c7 45 ec 7c ff 11 c0 	movl   $0xc011ff7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105418:	eb 6a                	jmp    c0105484 <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
c010541a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010541d:	83 e8 0c             	sub    $0xc,%eax
c0105420:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0105423:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105426:	83 c0 04             	add    $0x4,%eax
c0105429:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105430:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105433:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105436:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105439:	0f a3 10             	bt     %edx,(%eax)
c010543c:	19 c0                	sbb    %eax,%eax
c010543e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0105441:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105445:	0f 95 c0             	setne  %al
c0105448:	0f b6 c0             	movzbl %al,%eax
c010544b:	85 c0                	test   %eax,%eax
c010544d:	75 24                	jne    c0105473 <default_check+0x7d>
c010544f:	c7 44 24 0c be 82 10 	movl   $0xc01082be,0xc(%esp)
c0105456:	c0 
c0105457:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c010545e:	c0 
c010545f:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0105466:	00 
c0105467:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c010546e:	e8 be af ff ff       	call   c0100431 <__panic>
        count ++, total += p->property;
c0105473:	ff 45 f4             	incl   -0xc(%ebp)
c0105476:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105479:	8b 50 08             	mov    0x8(%eax),%edx
c010547c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010547f:	01 d0                	add    %edx,%eax
c0105481:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105484:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105487:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c010548a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010548d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105490:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105493:	81 7d ec 7c ff 11 c0 	cmpl   $0xc011ff7c,-0x14(%ebp)
c010549a:	0f 85 7a ff ff ff    	jne    c010541a <default_check+0x24>
    }
    assert(total == nr_free_pages());
c01054a0:	e8 dd dc ff ff       	call   c0103182 <nr_free_pages>
c01054a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01054a8:	39 d0                	cmp    %edx,%eax
c01054aa:	74 24                	je     c01054d0 <default_check+0xda>
c01054ac:	c7 44 24 0c ce 82 10 	movl   $0xc01082ce,0xc(%esp)
c01054b3:	c0 
c01054b4:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01054bb:	c0 
c01054bc:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c01054c3:	00 
c01054c4:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01054cb:	e8 61 af ff ff       	call   c0100431 <__panic>

    basic_check();
c01054d0:	e8 df f9 ff ff       	call   c0104eb4 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01054d5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01054dc:	e8 2e dc ff ff       	call   c010310f <alloc_pages>
c01054e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c01054e4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01054e8:	75 24                	jne    c010550e <default_check+0x118>
c01054ea:	c7 44 24 0c e7 82 10 	movl   $0xc01082e7,0xc(%esp)
c01054f1:	c0 
c01054f2:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01054f9:	c0 
c01054fa:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0105501:	00 
c0105502:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105509:	e8 23 af ff ff       	call   c0100431 <__panic>
    assert(!PageProperty(p0));
c010550e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105511:	83 c0 04             	add    $0x4,%eax
c0105514:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010551b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010551e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105521:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105524:	0f a3 10             	bt     %edx,(%eax)
c0105527:	19 c0                	sbb    %eax,%eax
c0105529:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010552c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105530:	0f 95 c0             	setne  %al
c0105533:	0f b6 c0             	movzbl %al,%eax
c0105536:	85 c0                	test   %eax,%eax
c0105538:	74 24                	je     c010555e <default_check+0x168>
c010553a:	c7 44 24 0c f2 82 10 	movl   $0xc01082f2,0xc(%esp)
c0105541:	c0 
c0105542:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105549:	c0 
c010554a:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0105551:	00 
c0105552:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105559:	e8 d3 ae ff ff       	call   c0100431 <__panic>

    list_entry_t free_list_store = free_list;
c010555e:	a1 7c ff 11 c0       	mov    0xc011ff7c,%eax
c0105563:	8b 15 80 ff 11 c0    	mov    0xc011ff80,%edx
c0105569:	89 45 80             	mov    %eax,-0x80(%ebp)
c010556c:	89 55 84             	mov    %edx,-0x7c(%ebp)
c010556f:	c7 45 b0 7c ff 11 c0 	movl   $0xc011ff7c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0105576:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105579:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010557c:	89 50 04             	mov    %edx,0x4(%eax)
c010557f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105582:	8b 50 04             	mov    0x4(%eax),%edx
c0105585:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105588:	89 10                	mov    %edx,(%eax)
}
c010558a:	90                   	nop
c010558b:	c7 45 b4 7c ff 11 c0 	movl   $0xc011ff7c,-0x4c(%ebp)
    return list->next == list;
c0105592:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105595:	8b 40 04             	mov    0x4(%eax),%eax
c0105598:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010559b:	0f 94 c0             	sete   %al
c010559e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01055a1:	85 c0                	test   %eax,%eax
c01055a3:	75 24                	jne    c01055c9 <default_check+0x1d3>
c01055a5:	c7 44 24 0c 47 82 10 	movl   $0xc0108247,0xc(%esp)
c01055ac:	c0 
c01055ad:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01055b4:	c0 
c01055b5:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01055bc:	00 
c01055bd:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01055c4:	e8 68 ae ff ff       	call   c0100431 <__panic>
    assert(alloc_page() == NULL);
c01055c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01055d0:	e8 3a db ff ff       	call   c010310f <alloc_pages>
c01055d5:	85 c0                	test   %eax,%eax
c01055d7:	74 24                	je     c01055fd <default_check+0x207>
c01055d9:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c01055e0:	c0 
c01055e1:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01055e8:	c0 
c01055e9:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01055f0:	00 
c01055f1:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01055f8:	e8 34 ae ff ff       	call   c0100431 <__panic>

    unsigned int nr_free_store = nr_free;
c01055fd:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c0105602:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105605:	c7 05 84 ff 11 c0 00 	movl   $0x0,0xc011ff84
c010560c:	00 00 00 

    free_pages(p0 + 2, 3);
c010560f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105612:	83 c0 28             	add    $0x28,%eax
c0105615:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010561c:	00 
c010561d:	89 04 24             	mov    %eax,(%esp)
c0105620:	e8 26 db ff ff       	call   c010314b <free_pages>
    assert(alloc_pages(4) == NULL);
c0105625:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010562c:	e8 de da ff ff       	call   c010310f <alloc_pages>
c0105631:	85 c0                	test   %eax,%eax
c0105633:	74 24                	je     c0105659 <default_check+0x263>
c0105635:	c7 44 24 0c 04 83 10 	movl   $0xc0108304,0xc(%esp)
c010563c:	c0 
c010563d:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105644:	c0 
c0105645:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010564c:	00 
c010564d:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105654:	e8 d8 ad ff ff       	call   c0100431 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105659:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010565c:	83 c0 28             	add    $0x28,%eax
c010565f:	83 c0 04             	add    $0x4,%eax
c0105662:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105669:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010566c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010566f:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105672:	0f a3 10             	bt     %edx,(%eax)
c0105675:	19 c0                	sbb    %eax,%eax
c0105677:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010567a:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010567e:	0f 95 c0             	setne  %al
c0105681:	0f b6 c0             	movzbl %al,%eax
c0105684:	85 c0                	test   %eax,%eax
c0105686:	74 0e                	je     c0105696 <default_check+0x2a0>
c0105688:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010568b:	83 c0 28             	add    $0x28,%eax
c010568e:	8b 40 08             	mov    0x8(%eax),%eax
c0105691:	83 f8 03             	cmp    $0x3,%eax
c0105694:	74 24                	je     c01056ba <default_check+0x2c4>
c0105696:	c7 44 24 0c 1c 83 10 	movl   $0xc010831c,0xc(%esp)
c010569d:	c0 
c010569e:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01056a5:	c0 
c01056a6:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01056ad:	00 
c01056ae:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01056b5:	e8 77 ad ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01056ba:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01056c1:	e8 49 da ff ff       	call   c010310f <alloc_pages>
c01056c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01056c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01056cd:	75 24                	jne    c01056f3 <default_check+0x2fd>
c01056cf:	c7 44 24 0c 48 83 10 	movl   $0xc0108348,0xc(%esp)
c01056d6:	c0 
c01056d7:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01056de:	c0 
c01056df:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01056e6:	00 
c01056e7:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01056ee:	e8 3e ad ff ff       	call   c0100431 <__panic>
    assert(alloc_page() == NULL);
c01056f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01056fa:	e8 10 da ff ff       	call   c010310f <alloc_pages>
c01056ff:	85 c0                	test   %eax,%eax
c0105701:	74 24                	je     c0105727 <default_check+0x331>
c0105703:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c010570a:	c0 
c010570b:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105712:	c0 
c0105713:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010571a:	00 
c010571b:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105722:	e8 0a ad ff ff       	call   c0100431 <__panic>
    assert(p0 + 2 == p1);
c0105727:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010572a:	83 c0 28             	add    $0x28,%eax
c010572d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105730:	74 24                	je     c0105756 <default_check+0x360>
c0105732:	c7 44 24 0c 66 83 10 	movl   $0xc0108366,0xc(%esp)
c0105739:	c0 
c010573a:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105741:	c0 
c0105742:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105749:	00 
c010574a:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105751:	e8 db ac ff ff       	call   c0100431 <__panic>

    p2 = p0 + 1;
c0105756:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105759:	83 c0 14             	add    $0x14,%eax
c010575c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c010575f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105766:	00 
c0105767:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010576a:	89 04 24             	mov    %eax,(%esp)
c010576d:	e8 d9 d9 ff ff       	call   c010314b <free_pages>
    free_pages(p1, 3);
c0105772:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105779:	00 
c010577a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010577d:	89 04 24             	mov    %eax,(%esp)
c0105780:	e8 c6 d9 ff ff       	call   c010314b <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105785:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105788:	83 c0 04             	add    $0x4,%eax
c010578b:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105792:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105795:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105798:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010579b:	0f a3 10             	bt     %edx,(%eax)
c010579e:	19 c0                	sbb    %eax,%eax
c01057a0:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01057a3:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01057a7:	0f 95 c0             	setne  %al
c01057aa:	0f b6 c0             	movzbl %al,%eax
c01057ad:	85 c0                	test   %eax,%eax
c01057af:	74 0b                	je     c01057bc <default_check+0x3c6>
c01057b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057b4:	8b 40 08             	mov    0x8(%eax),%eax
c01057b7:	83 f8 01             	cmp    $0x1,%eax
c01057ba:	74 24                	je     c01057e0 <default_check+0x3ea>
c01057bc:	c7 44 24 0c 74 83 10 	movl   $0xc0108374,0xc(%esp)
c01057c3:	c0 
c01057c4:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01057cb:	c0 
c01057cc:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01057d3:	00 
c01057d4:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01057db:	e8 51 ac ff ff       	call   c0100431 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01057e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057e3:	83 c0 04             	add    $0x4,%eax
c01057e6:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01057ed:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01057f0:	8b 45 90             	mov    -0x70(%ebp),%eax
c01057f3:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01057f6:	0f a3 10             	bt     %edx,(%eax)
c01057f9:	19 c0                	sbb    %eax,%eax
c01057fb:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01057fe:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105802:	0f 95 c0             	setne  %al
c0105805:	0f b6 c0             	movzbl %al,%eax
c0105808:	85 c0                	test   %eax,%eax
c010580a:	74 0b                	je     c0105817 <default_check+0x421>
c010580c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010580f:	8b 40 08             	mov    0x8(%eax),%eax
c0105812:	83 f8 03             	cmp    $0x3,%eax
c0105815:	74 24                	je     c010583b <default_check+0x445>
c0105817:	c7 44 24 0c 9c 83 10 	movl   $0xc010839c,0xc(%esp)
c010581e:	c0 
c010581f:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105826:	c0 
c0105827:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010582e:	00 
c010582f:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105836:	e8 f6 ab ff ff       	call   c0100431 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010583b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105842:	e8 c8 d8 ff ff       	call   c010310f <alloc_pages>
c0105847:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010584a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010584d:	83 e8 14             	sub    $0x14,%eax
c0105850:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105853:	74 24                	je     c0105879 <default_check+0x483>
c0105855:	c7 44 24 0c c2 83 10 	movl   $0xc01083c2,0xc(%esp)
c010585c:	c0 
c010585d:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105864:	c0 
c0105865:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c010586c:	00 
c010586d:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105874:	e8 b8 ab ff ff       	call   c0100431 <__panic>
    free_page(p0);
c0105879:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105880:	00 
c0105881:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105884:	89 04 24             	mov    %eax,(%esp)
c0105887:	e8 bf d8 ff ff       	call   c010314b <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010588c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105893:	e8 77 d8 ff ff       	call   c010310f <alloc_pages>
c0105898:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010589b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010589e:	83 c0 14             	add    $0x14,%eax
c01058a1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01058a4:	74 24                	je     c01058ca <default_check+0x4d4>
c01058a6:	c7 44 24 0c e0 83 10 	movl   $0xc01083e0,0xc(%esp)
c01058ad:	c0 
c01058ae:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01058b5:	c0 
c01058b6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01058bd:	00 
c01058be:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01058c5:	e8 67 ab ff ff       	call   c0100431 <__panic>

    free_pages(p0, 2);
c01058ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01058d1:	00 
c01058d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058d5:	89 04 24             	mov    %eax,(%esp)
c01058d8:	e8 6e d8 ff ff       	call   c010314b <free_pages>
    free_page(p2);
c01058dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01058e4:	00 
c01058e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058e8:	89 04 24             	mov    %eax,(%esp)
c01058eb:	e8 5b d8 ff ff       	call   c010314b <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01058f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01058f7:	e8 13 d8 ff ff       	call   c010310f <alloc_pages>
c01058fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105903:	75 24                	jne    c0105929 <default_check+0x533>
c0105905:	c7 44 24 0c 00 84 10 	movl   $0xc0108400,0xc(%esp)
c010590c:	c0 
c010590d:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105914:	c0 
c0105915:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c010591c:	00 
c010591d:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105924:	e8 08 ab ff ff       	call   c0100431 <__panic>
    assert(alloc_page() == NULL);
c0105929:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105930:	e8 da d7 ff ff       	call   c010310f <alloc_pages>
c0105935:	85 c0                	test   %eax,%eax
c0105937:	74 24                	je     c010595d <default_check+0x567>
c0105939:	c7 44 24 0c 5e 82 10 	movl   $0xc010825e,0xc(%esp)
c0105940:	c0 
c0105941:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105948:	c0 
c0105949:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0105950:	00 
c0105951:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105958:	e8 d4 aa ff ff       	call   c0100431 <__panic>

    assert(nr_free == 0);
c010595d:	a1 84 ff 11 c0       	mov    0xc011ff84,%eax
c0105962:	85 c0                	test   %eax,%eax
c0105964:	74 24                	je     c010598a <default_check+0x594>
c0105966:	c7 44 24 0c b1 82 10 	movl   $0xc01082b1,0xc(%esp)
c010596d:	c0 
c010596e:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105975:	c0 
c0105976:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010597d:	00 
c010597e:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105985:	e8 a7 aa ff ff       	call   c0100431 <__panic>
    nr_free = nr_free_store;
c010598a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010598d:	a3 84 ff 11 c0       	mov    %eax,0xc011ff84

    free_list = free_list_store;
c0105992:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105995:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105998:	a3 7c ff 11 c0       	mov    %eax,0xc011ff7c
c010599d:	89 15 80 ff 11 c0    	mov    %edx,0xc011ff80
    free_pages(p0, 5);
c01059a3:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01059aa:	00 
c01059ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059ae:	89 04 24             	mov    %eax,(%esp)
c01059b1:	e8 95 d7 ff ff       	call   c010314b <free_pages>

    le = &free_list;
c01059b6:	c7 45 ec 7c ff 11 c0 	movl   $0xc011ff7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01059bd:	eb 5a                	jmp    c0105a19 <default_check+0x623>
        assert(le->next->prev == le && le->prev->next == le);
c01059bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059c2:	8b 40 04             	mov    0x4(%eax),%eax
c01059c5:	8b 00                	mov    (%eax),%eax
c01059c7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01059ca:	75 0d                	jne    c01059d9 <default_check+0x5e3>
c01059cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059cf:	8b 00                	mov    (%eax),%eax
c01059d1:	8b 40 04             	mov    0x4(%eax),%eax
c01059d4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01059d7:	74 24                	je     c01059fd <default_check+0x607>
c01059d9:	c7 44 24 0c 20 84 10 	movl   $0xc0108420,0xc(%esp)
c01059e0:	c0 
c01059e1:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c01059e8:	c0 
c01059e9:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01059f0:	00 
c01059f1:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c01059f8:	e8 34 aa ff ff       	call   c0100431 <__panic>
        struct Page *p = le2page(le, page_link);
c01059fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a00:	83 e8 0c             	sub    $0xc,%eax
c0105a03:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105a06:	ff 4d f4             	decl   -0xc(%ebp)
c0105a09:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a0c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105a0f:	8b 40 08             	mov    0x8(%eax),%eax
c0105a12:	29 c2                	sub    %eax,%edx
c0105a14:	89 d0                	mov    %edx,%eax
c0105a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a1c:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105a1f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105a22:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a28:	81 7d ec 7c ff 11 c0 	cmpl   $0xc011ff7c,-0x14(%ebp)
c0105a2f:	75 8e                	jne    c01059bf <default_check+0x5c9>
    }
    assert(count == 0);
c0105a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a35:	74 24                	je     c0105a5b <default_check+0x665>
c0105a37:	c7 44 24 0c 4d 84 10 	movl   $0xc010844d,0xc(%esp)
c0105a3e:	c0 
c0105a3f:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105a46:	c0 
c0105a47:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c0105a4e:	00 
c0105a4f:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105a56:	e8 d6 a9 ff ff       	call   c0100431 <__panic>
    assert(total == 0);
c0105a5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a5f:	74 24                	je     c0105a85 <default_check+0x68f>
c0105a61:	c7 44 24 0c 58 84 10 	movl   $0xc0108458,0xc(%esp)
c0105a68:	c0 
c0105a69:	c7 44 24 08 be 80 10 	movl   $0xc01080be,0x8(%esp)
c0105a70:	c0 
c0105a71:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0105a78:	00 
c0105a79:	c7 04 24 d3 80 10 c0 	movl   $0xc01080d3,(%esp)
c0105a80:	e8 ac a9 ff ff       	call   c0100431 <__panic>
}
c0105a85:	90                   	nop
c0105a86:	c9                   	leave  
c0105a87:	c3                   	ret    

c0105a88 <page2ppn>:
page2ppn(struct Page *page) {
c0105a88:	55                   	push   %ebp
c0105a89:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105a8b:	a1 78 ff 11 c0       	mov    0xc011ff78,%eax
c0105a90:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a93:	29 c2                	sub    %eax,%edx
c0105a95:	89 d0                	mov    %edx,%eax
c0105a97:	c1 f8 02             	sar    $0x2,%eax
c0105a9a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0105aa0:	5d                   	pop    %ebp
c0105aa1:	c3                   	ret    

c0105aa2 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0105aa2:	55                   	push   %ebp
c0105aa3:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105aab:	89 10                	mov    %edx,(%eax)
}
c0105aad:	90                   	nop
c0105aae:	5d                   	pop    %ebp
c0105aaf:	c3                   	ret    

c0105ab0 <IS_POWER_OF_2>:
#define max_order (buddy_s.max_order) //最大的层数
#define nr_free (buddy_s.nr_free) //剩余的空闲块

extern ppn_t first_ppn;

static int IS_POWER_OF_2(size_t n) {
c0105ab0:	f3 0f 1e fb          	endbr32 
c0105ab4:	55                   	push   %ebp
c0105ab5:	89 e5                	mov    %esp,%ebp
    if (n & (n - 1)) { 
c0105ab7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aba:	48                   	dec    %eax
c0105abb:	23 45 08             	and    0x8(%ebp),%eax
c0105abe:	85 c0                	test   %eax,%eax
c0105ac0:	74 07                	je     c0105ac9 <IS_POWER_OF_2+0x19>
        return 0;
c0105ac2:	b8 00 00 00 00       	mov    $0x0,%eax
c0105ac7:	eb 05                	jmp    c0105ace <IS_POWER_OF_2+0x1e>
    }
    else {
        return 1;
c0105ac9:	b8 01 00 00 00       	mov    $0x1,%eax
    }
}
c0105ace:	5d                   	pop    %ebp
c0105acf:	c3                   	ret    

c0105ad0 <getOrderOf2>:

static unsigned int getOrderOf2(size_t n) {
c0105ad0:	f3 0f 1e fb          	endbr32 
c0105ad4:	55                   	push   %ebp
c0105ad5:	89 e5                	mov    %esp,%ebp
c0105ad7:	83 ec 10             	sub    $0x10,%esp
    unsigned int order = 0;
c0105ada:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (n >> 1) {
c0105ae1:	eb 06                	jmp    c0105ae9 <getOrderOf2+0x19>
        n >>= 1;
c0105ae3:	d1 6d 08             	shrl   0x8(%ebp)
        order ++;
c0105ae6:	ff 45 fc             	incl   -0x4(%ebp)
    while (n >> 1) {
c0105ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aec:	d1 e8                	shr    %eax
c0105aee:	85 c0                	test   %eax,%eax
c0105af0:	75 f1                	jne    c0105ae3 <getOrderOf2+0x13>
    }
    return order;
c0105af2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105af5:	c9                   	leave  
c0105af6:	c3                   	ret    

c0105af7 <ROUNDDOWN2>:

static size_t ROUNDDOWN2(size_t n) {
c0105af7:	f3 0f 1e fb          	endbr32 
c0105afb:	55                   	push   %ebp
c0105afc:	89 e5                	mov    %esp,%ebp
c0105afe:	83 ec 14             	sub    $0x14,%esp
    size_t res = 1;
c0105b01:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    if (!IS_POWER_OF_2(n)) {
c0105b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0b:	89 04 24             	mov    %eax,(%esp)
c0105b0e:	e8 9d ff ff ff       	call   c0105ab0 <IS_POWER_OF_2>
c0105b13:	85 c0                	test   %eax,%eax
c0105b15:	75 15                	jne    c0105b2c <ROUNDDOWN2+0x35>
        while (n) {
c0105b17:	eb 06                	jmp    c0105b1f <ROUNDDOWN2+0x28>
            n = n >> 1;
c0105b19:	d1 6d 08             	shrl   0x8(%ebp)
            res = res << 1;
c0105b1c:	d1 65 fc             	shll   -0x4(%ebp)
        while (n) {
c0105b1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b23:	75 f4                	jne    c0105b19 <ROUNDDOWN2+0x22>
        }
        return res>>1; 
c0105b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b28:	d1 e8                	shr    %eax
c0105b2a:	eb 03                	jmp    c0105b2f <ROUNDDOWN2+0x38>
    }
    else {
        return n;
c0105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
    }
}
c0105b2f:	c9                   	leave  
c0105b30:	c3                   	ret    

c0105b31 <ROUNDUP2>:

static size_t ROUNDUP2(size_t n) {
c0105b31:	f3 0f 1e fb          	endbr32 
c0105b35:	55                   	push   %ebp
c0105b36:	89 e5                	mov    %esp,%ebp
c0105b38:	83 ec 14             	sub    $0x14,%esp
    size_t res = 1;
c0105b3b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    if (!IS_POWER_OF_2(n)) {
c0105b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b45:	89 04 24             	mov    %eax,(%esp)
c0105b48:	e8 63 ff ff ff       	call   c0105ab0 <IS_POWER_OF_2>
c0105b4d:	85 c0                	test   %eax,%eax
c0105b4f:	75 13                	jne    c0105b64 <ROUNDUP2+0x33>
        while (n) {
c0105b51:	eb 06                	jmp    c0105b59 <ROUNDUP2+0x28>
            n = n >> 1;
c0105b53:	d1 6d 08             	shrl   0x8(%ebp)
            res = res << 1;
c0105b56:	d1 65 fc             	shll   -0x4(%ebp)
        while (n) {
c0105b59:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b5d:	75 f4                	jne    c0105b53 <ROUNDUP2+0x22>
        }
        return res; 
c0105b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b62:	eb 03                	jmp    c0105b67 <ROUNDUP2+0x36>
    }
    else {
        return n;
c0105b64:	8b 45 08             	mov    0x8(%ebp),%eax
    }
}
c0105b67:	c9                   	leave  
c0105b68:	c3                   	ret    

c0105b69 <show_buddy_array>:

//在测试的时候使用，打印buddy array
static void
show_buddy_array(void) {
c0105b69:	f3 0f 1e fb          	endbr32 
c0105b6d:	55                   	push   %ebp
c0105b6e:	89 e5                	mov    %esp,%ebp
c0105b70:	83 ec 28             	sub    $0x28,%esp
    cprintf("[!]BS: Printing buddy array:\n");
c0105b73:	c7 04 24 94 84 10 c0 	movl   $0xc0108494,(%esp)
c0105b7a:	e8 46 a7 ff ff       	call   c01002c5 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
c0105b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b86:	e9 81 00 00 00       	jmp    c0105c0c <show_buddy_array+0xa3>
        cprintf("%d layer: ", i);
c0105b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b92:	c7 04 24 b2 84 10 c0 	movl   $0xc01084b2,(%esp)
c0105b99:	e8 27 a7 ff ff       	call   c01002c5 <cprintf>
        list_entry_t *le = &(buddy_array[i]);
c0105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba1:	c1 e0 03             	shl    $0x3,%eax
c0105ba4:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0105ba9:	83 c0 04             	add    $0x4,%eax
c0105bac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != &(buddy_array[i])) {
c0105baf:	eb 2a                	jmp    c0105bdb <show_buddy_array+0x72>
            struct Page *p = le2page(le, page_link);
c0105bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb4:	83 e8 0c             	sub    $0xc,%eax
c0105bb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
            cprintf("%d ", 1 << (p->property));
c0105bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bbd:	8b 40 08             	mov    0x8(%eax),%eax
c0105bc0:	ba 01 00 00 00       	mov    $0x1,%edx
c0105bc5:	88 c1                	mov    %al,%cl
c0105bc7:	d3 e2                	shl    %cl,%edx
c0105bc9:	89 d0                	mov    %edx,%eax
c0105bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bcf:	c7 04 24 bd 84 10 c0 	movl   $0xc01084bd,(%esp)
c0105bd6:	e8 ea a6 ff ff       	call   c01002c5 <cprintf>
c0105bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bde:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105be1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105be4:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != &(buddy_array[i])) {
c0105be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bed:	c1 e0 03             	shl    $0x3,%eax
c0105bf0:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0105bf5:	83 c0 04             	add    $0x4,%eax
c0105bf8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105bfb:	75 b4                	jne    c0105bb1 <show_buddy_array+0x48>
        }
        cprintf("\n");
c0105bfd:	c7 04 24 c1 84 10 c0 	movl   $0xc01084c1,(%esp)
c0105c04:	e8 bc a6 ff ff       	call   c01002c5 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
c0105c09:	ff 45 f4             	incl   -0xc(%ebp)
c0105c0c:	a1 a0 ff 11 c0       	mov    0xc011ffa0,%eax
c0105c11:	8d 50 01             	lea    0x1(%eax),%edx
c0105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c17:	39 c2                	cmp    %eax,%edx
c0105c19:	0f 87 6c ff ff ff    	ja     c0105b8b <show_buddy_array+0x22>
    }
    cprintf("---------------------------\n");
c0105c1f:	c7 04 24 c3 84 10 c0 	movl   $0xc01084c3,(%esp)
c0105c26:	e8 9a a6 ff ff       	call   c01002c5 <cprintf>
    return;
c0105c2b:	90                   	nop
}
c0105c2c:	c9                   	leave  
c0105c2d:	c3                   	ret    

c0105c2e <buddy_init>:

/*
 *  初始化buddy结构体
 */
buddy_init(void) {
c0105c2e:	f3 0f 1e fb          	endbr32 
c0105c32:	55                   	push   %ebp
c0105c33:	89 e5                	mov    %esp,%ebp
c0105c35:	83 ec 28             	sub    $0x28,%esp
    for (int i = 0;i < MAX_BUDDY_ORDER+1;i ++){
c0105c38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105c3f:	eb 26                	jmp    c0105c67 <buddy_init+0x39>
        list_init(buddy_array + i); 
c0105c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c44:	c1 e0 03             	shl    $0x3,%eax
c0105c47:	05 a4 ff 11 c0       	add    $0xc011ffa4,%eax
c0105c4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0105c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c52:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105c55:	89 50 04             	mov    %edx,0x4(%eax)
c0105c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c5b:	8b 50 04             	mov    0x4(%eax),%edx
c0105c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c61:	89 10                	mov    %edx,(%eax)
}
c0105c63:	90                   	nop
    for (int i = 0;i < MAX_BUDDY_ORDER+1;i ++){
c0105c64:	ff 45 f4             	incl   -0xc(%ebp)
c0105c67:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
c0105c6b:	7e d4                	jle    c0105c41 <buddy_init+0x13>
    }
    max_order = 0;
c0105c6d:	c7 05 a0 ff 11 c0 00 	movl   $0x0,0xc011ffa0
c0105c74:	00 00 00 
    nr_free = 0;
c0105c77:	c7 05 1c 00 12 c0 00 	movl   $0x0,0xc012001c
c0105c7e:	00 00 00 
    cprintf("buddy system init success\n");
c0105c81:	c7 04 24 e0 84 10 c0 	movl   $0xc01084e0,(%esp)
c0105c88:	e8 38 a6 ff ff       	call   c01002c5 <cprintf>
    return;
c0105c8d:	90                   	nop
c0105c8e:	90                   	nop
}
c0105c8f:	c9                   	leave  
c0105c90:	c3                   	ret    

c0105c91 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page *base, size_t n) {
c0105c91:	f3 0f 1e fb          	endbr32 
c0105c95:	55                   	push   %ebp
c0105c96:	89 e5                	mov    %esp,%ebp
c0105c98:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0105c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c9f:	75 24                	jne    c0105cc5 <buddy_init_memmap+0x34>
c0105ca1:	c7 44 24 0c fb 84 10 	movl   $0xc01084fb,0xc(%esp)
c0105ca8:	c0 
c0105ca9:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0105cb0:	c0 
c0105cb1:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0105cb8:	00 
c0105cb9:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0105cc0:	e8 6c a7 ff ff       	call   c0100431 <__panic>
    size_t pnum;
    unsigned int order;
    pnum = ROUNDDOWN2(n);       // 将页数向下取整为2的幂
c0105cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc8:	89 04 24             	mov    %eax,(%esp)
c0105ccb:	e8 27 fe ff ff       	call   c0105af7 <ROUNDDOWN2>
c0105cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    //for debug
    //pnum = 8;
    order = getOrderOf2(pnum);   // 求出页数对应的2的幂
c0105cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cd6:	89 04 24             	mov    %eax,(%esp)
c0105cd9:	e8 f2 fd ff ff       	call   c0105ad0 <getOrderOf2>
c0105cde:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //cprintf("[!]BS: AVA Page num after rounding down to powers of 2: %d = 2^%d\n", pnum, order);

    struct Page *p = base;
c0105ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 初始化pages数组中范围内的每个Page
    for (; p != base + pnum; p ++) {
c0105ce7:	eb 7b                	jmp    c0105d64 <buddy_init_memmap+0xd3>
        assert(PageReserved(p));
c0105ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cec:	83 c0 04             	add    $0x4,%eax
c0105cef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105cff:	0f a3 10             	bt     %edx,(%eax)
c0105d02:	19 c0                	sbb    %eax,%eax
c0105d04:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0105d07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105d0b:	0f 95 c0             	setne  %al
c0105d0e:	0f b6 c0             	movzbl %al,%eax
c0105d11:	85 c0                	test   %eax,%eax
c0105d13:	75 24                	jne    c0105d39 <buddy_init_memmap+0xa8>
c0105d15:	c7 44 24 0c 2a 85 10 	movl   $0xc010852a,0xc(%esp)
c0105d1c:	c0 
c0105d1d:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0105d24:	c0 
c0105d25:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0105d2c:	00 
c0105d2d:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0105d34:	e8 f8 a6 ff ff       	call   c0100431 <__panic>
        p->flags = 0;
c0105d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d3c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property = -1;   // 全部初始化为非头页
c0105d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d46:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
        set_page_ref(p, 0);
c0105d4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105d54:	00 
c0105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d58:	89 04 24             	mov    %eax,(%esp)
c0105d5b:	e8 42 fd ff ff       	call   c0105aa2 <set_page_ref>
    for (; p != base + pnum; p ++) {
c0105d60:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105d64:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105d67:	89 d0                	mov    %edx,%eax
c0105d69:	c1 e0 02             	shl    $0x2,%eax
c0105d6c:	01 d0                	add    %edx,%eax
c0105d6e:	c1 e0 02             	shl    $0x2,%eax
c0105d71:	89 c2                	mov    %eax,%edx
c0105d73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d76:	01 d0                	add    %edx,%eax
c0105d78:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105d7b:	0f 85 68 ff ff ff    	jne    c0105ce9 <buddy_init_memmap+0x58>
    }

    max_order = order>max_order?order:max_order;
c0105d81:	a1 a0 ff 11 c0       	mov    0xc011ffa0,%eax
c0105d86:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105d89:	0f 43 45 ec          	cmovae -0x14(%ebp),%eax
c0105d8d:	a3 a0 ff 11 c0       	mov    %eax,0xc011ffa0
    nr_free += pnum;
c0105d92:	8b 15 1c 00 12 c0    	mov    0xc012001c,%edx
c0105d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d9b:	01 d0                	add    %edx,%eax
c0105d9d:	a3 1c 00 12 c0       	mov    %eax,0xc012001c

    //cprintf("max_order is :%d,nr_free is :%d\n",max_order,nr_free);
    list_add(&(buddy_array[order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块——16384,的头页
c0105da2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da5:	83 c0 0c             	add    $0xc,%eax
c0105da8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105dab:	c1 e2 03             	shl    $0x3,%edx
c0105dae:	81 c2 a0 ff 11 c0    	add    $0xc011ffa0,%edx
c0105db4:	83 c2 04             	add    $0x4,%edx
c0105db7:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105dba:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105dc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105dc3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105dc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105dc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105dcc:	8b 40 04             	mov    0x4(%eax),%eax
c0105dcf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105dd2:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105dd5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105dd8:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105ddb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c0105dde:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105de1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105de4:	89 10                	mov    %edx,(%eax)
c0105de6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105de9:	8b 10                	mov    (%eax),%edx
c0105deb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105dee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105df1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105df4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105df7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105dfa:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105dfd:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105e00:	89 10                	mov    %edx,(%eax)
}
c0105e02:	90                   	nop
}
c0105e03:	90                   	nop
}
c0105e04:	90                   	nop
    base->property = order;                       // 将第一页base的property设为最大块的2幂
c0105e05:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e08:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e0b:	89 50 08             	mov    %edx,0x8(%eax)

    //cprintf("buddy mem init success\n");
    return;
c0105e0e:	90                   	nop
}   
c0105e0f:	c9                   	leave  
c0105e10:	c3                   	ret    

c0105e11 <buddy_split>:
 *  buddy_split：分裂指定阶的物理块
 *  参数：
 *  n： 指定的阶
 *  默认分裂数组中第n条链表的第一块
 */
static void buddy_split(size_t n) {
c0105e11:	f3 0f 1e fb          	endbr32 
c0105e15:	55                   	push   %ebp
c0105e16:	89 e5                	mov    %esp,%ebp
c0105e18:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0 && n <= max_order);
c0105e1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105e1f:	74 0a                	je     c0105e2b <buddy_split+0x1a>
c0105e21:	a1 a0 ff 11 c0       	mov    0xc011ffa0,%eax
c0105e26:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105e29:	76 24                	jbe    c0105e4f <buddy_split+0x3e>
c0105e2b:	c7 44 24 0c 3a 85 10 	movl   $0xc010853a,0xc(%esp)
c0105e32:	c0 
c0105e33:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0105e3a:	c0 
c0105e3b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c0105e42:	00 
c0105e43:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0105e4a:	e8 e2 a5 ff ff       	call   c0100431 <__panic>
    assert(!list_empty(&(buddy_array[n])));
c0105e4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e52:	c1 e0 03             	shl    $0x3,%eax
c0105e55:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0105e5a:	83 c0 04             	add    $0x4,%eax
c0105e5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return list->next == list;
c0105e60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e63:	8b 40 04             	mov    0x4(%eax),%eax
c0105e66:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105e69:	0f 94 c0             	sete   %al
c0105e6c:	0f b6 c0             	movzbl %al,%eax
c0105e6f:	85 c0                	test   %eax,%eax
c0105e71:	74 24                	je     c0105e97 <buddy_split+0x86>
c0105e73:	c7 44 24 0c 54 85 10 	movl   $0xc0108554,0xc(%esp)
c0105e7a:	c0 
c0105e7b:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0105e82:	c0 
c0105e83:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
c0105e8a:	00 
c0105e8b:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0105e92:	e8 9a a5 ff ff       	call   c0100431 <__panic>
    //cprintf("[!]BS: SPLITTING!\n");
    struct Page *page_left;
    struct Page *page_right;

    page_left = le2page(list_next(&(buddy_array[n])), page_link);
c0105e97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e9a:	c1 e0 03             	shl    $0x3,%eax
c0105e9d:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0105ea2:	83 c0 04             	add    $0x4,%eax
c0105ea5:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0105ea8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105eab:	8b 40 04             	mov    0x4(%eax),%eax
c0105eae:	83 e8 0c             	sub    $0xc,%eax
c0105eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    page_right = page_left + (1 << (n - 1));
c0105eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb7:	48                   	dec    %eax
c0105eb8:	ba 14 00 00 00       	mov    $0x14,%edx
c0105ebd:	88 c1                	mov    %al,%cl
c0105ebf:	d3 e2                	shl    %cl,%edx
c0105ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ec4:	01 d0                	add    %edx,%eax
c0105ec6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    page_left->property = n - 1;
c0105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ecc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ed2:	89 50 08             	mov    %edx,0x8(%eax)
    page_right->property = n - 1;
c0105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ede:	89 50 08             	mov    %edx,0x8(%eax)

    list_del(list_next(&(buddy_array[n])));
c0105ee1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee4:	c1 e0 03             	shl    $0x3,%eax
c0105ee7:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0105eec:	83 c0 04             	add    $0x4,%eax
c0105eef:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105ef2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105ef5:	8b 40 04             	mov    0x4(%eax),%eax
c0105ef8:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105efb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105efe:	8b 40 04             	mov    0x4(%eax),%eax
c0105f01:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105f04:	8b 12                	mov    (%edx),%edx
c0105f06:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0105f09:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0105f0c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105f0f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105f12:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105f15:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105f18:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105f1b:	89 10                	mov    %edx,(%eax)
}
c0105f1d:	90                   	nop
}
c0105f1e:	90                   	nop
    list_add(&(buddy_array[n-1]), &(page_left->page_link));
c0105f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f22:	83 c0 0c             	add    $0xc,%eax
c0105f25:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f28:	4a                   	dec    %edx
c0105f29:	c1 e2 03             	shl    $0x3,%edx
c0105f2c:	81 c2 a0 ff 11 c0    	add    $0xc011ffa0,%edx
c0105f32:	83 c2 04             	add    $0x4,%edx
c0105f35:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105f38:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105f3b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105f3e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105f41:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105f44:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105f47:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105f4a:	8b 40 04             	mov    0x4(%eax),%eax
c0105f4d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105f50:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0105f53:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105f56:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0105f59:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
c0105f5c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105f5f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105f62:	89 10                	mov    %edx,(%eax)
c0105f64:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105f67:	8b 10                	mov    (%eax),%edx
c0105f69:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105f6c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105f6f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105f72:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105f75:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105f78:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105f7b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105f7e:	89 10                	mov    %edx,(%eax)
}
c0105f80:	90                   	nop
}
c0105f81:	90                   	nop
}
c0105f82:	90                   	nop
    list_add(&(page_left->page_link), &(page_right->page_link));
c0105f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f86:	83 c0 0c             	add    $0xc,%eax
c0105f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f8c:	83 c2 0c             	add    $0xc,%edx
c0105f8f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105f92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f98:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105fa4:	8b 40 04             	mov    0x4(%eax),%eax
c0105fa7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105faa:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105fad:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105fb0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105fb3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0105fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105fb9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105fbc:	89 10                	mov    %edx,(%eax)
c0105fbe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105fc1:	8b 10                	mov    (%eax),%edx
c0105fc3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105fc6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105fc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105fcc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105fcf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105fd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105fd5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105fd8:	89 10                	mov    %edx,(%eax)
}
c0105fda:	90                   	nop
}
c0105fdb:	90                   	nop
}
c0105fdc:	90                   	nop

    return;
c0105fdd:	90                   	nop
}
c0105fde:	c9                   	leave  
c0105fdf:	c3                   	ret    

c0105fe0 <buddy_alloc_pages>:
 *  buddy_alloc_pages：分配指定大小的物理块
 *  参数：
 *  n： 指定物理块的大小（页）
 */
static struct Page *
buddy_alloc_pages(size_t n) {
c0105fe0:	f3 0f 1e fb          	endbr32 
c0105fe4:	55                   	push   %ebp
c0105fe5:	89 e5                	mov    %esp,%ebp
c0105fe7:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0105fea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fee:	75 24                	jne    c0106014 <buddy_alloc_pages+0x34>
c0105ff0:	c7 44 24 0c fb 84 10 	movl   $0xc01084fb,0xc(%esp)
c0105ff7:	c0 
c0105ff8:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0105fff:	c0 
c0106000:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0106007:	00 
c0106008:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c010600f:	e8 1d a4 ff ff       	call   c0100431 <__panic>
    if (n > nr_free) {
c0106014:	a1 1c 00 12 c0       	mov    0xc012001c,%eax
c0106019:	39 45 08             	cmp    %eax,0x8(%ebp)
c010601c:	76 0a                	jbe    c0106028 <buddy_alloc_pages+0x48>
        return NULL;
c010601e:	b8 00 00 00 00       	mov    $0x0,%eax
c0106023:	e9 1e 01 00 00       	jmp    c0106146 <buddy_alloc_pages+0x166>
    }

    struct Page *page = NULL;
c0106028:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    size_t pnum = ROUNDUP2(n);  
c010602f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106032:	89 04 24             	mov    %eax,(%esp)
c0106035:	e8 f7 fa ff ff       	call   c0105b31 <ROUNDUP2>
c010603a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t order = getOrderOf2(pnum);
c010603d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106040:	89 04 24             	mov    %eax,(%esp)
c0106043:	e8 88 fa ff ff       	call   c0105ad0 <getOrderOf2>
c0106048:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //cprintf("[!]BS: Buddy array before ALLOC:\n");
    //show_buddy_array();

// 若order对应的链表中含有空闲块，则直接分配
find:
    if (!list_empty(&(buddy_array[order]))) {
c010604b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010604e:	c1 e0 03             	shl    $0x3,%eax
c0106051:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0106056:	83 c0 04             	add    $0x4,%eax
c0106059:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return list->next == list;
c010605c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010605f:	8b 40 04             	mov    0x4(%eax),%eax
c0106062:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106065:	0f 94 c0             	sete   %al
c0106068:	0f b6 c0             	movzbl %al,%eax
c010606b:	85 c0                	test   %eax,%eax
c010606d:	75 77                	jne    c01060e6 <buddy_alloc_pages+0x106>
        page = le2page(list_next(&(buddy_array[order])), page_link);
c010606f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106072:	c1 e0 03             	shl    $0x3,%eax
c0106075:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c010607a:	83 c0 04             	add    $0x4,%eax
c010607d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return listelm->next;
c0106080:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106083:	8b 40 04             	mov    0x4(%eax),%eax
c0106086:	83 e8 0c             	sub    $0xc,%eax
c0106089:	89 45 f4             	mov    %eax,-0xc(%ebp)
        list_del(list_next(&(buddy_array[order])));
c010608c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010608f:	c1 e0 03             	shl    $0x3,%eax
c0106092:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0106097:	83 c0 04             	add    $0x4,%eax
c010609a:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010609d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01060a0:	8b 40 04             	mov    0x4(%eax),%eax
c01060a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_del(listelm->prev, listelm->next);
c01060a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01060a9:	8b 40 04             	mov    0x4(%eax),%eax
c01060ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01060af:	8b 12                	mov    (%edx),%edx
c01060b1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01060b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next;
c01060b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01060bd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01060c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01060c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01060c6:	89 10                	mov    %edx,(%eax)
}
c01060c8:	90                   	nop
}
c01060c9:	90                   	nop
        SetPageProperty(page); // 将分配块的头页设置为已被占用
c01060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060cd:	83 c0 04             	add    $0x4,%eax
c01060d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01060d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01060da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01060e0:	0f ab 10             	bts    %edx,(%eax)
}
c01060e3:	90                   	nop
        //cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
        //show_buddy_array();
        goto done; 
c01060e4:	eb 50                	jmp    c0106136 <buddy_alloc_pages+0x156>
    }

//buddy_array[order] is empty,go to top array to split
    for (int i = order + 1;i < max_order + 1;i ++) {
c01060e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060e9:	40                   	inc    %eax
c01060ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060ed:	eb 37                	jmp    c0106126 <buddy_alloc_pages+0x146>
        if (!list_empty(&(buddy_array[i]))) {
c01060ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060f2:	c1 e0 03             	shl    $0x3,%eax
c01060f5:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c01060fa:	83 c0 04             	add    $0x4,%eax
c01060fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return list->next == list;
c0106100:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106103:	8b 40 04             	mov    0x4(%eax),%eax
c0106106:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
c0106109:	0f 94 c0             	sete   %al
c010610c:	0f b6 c0             	movzbl %al,%eax
c010610f:	85 c0                	test   %eax,%eax
c0106111:	75 10                	jne    c0106123 <buddy_alloc_pages+0x143>
            buddy_split(i);
c0106113:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106116:	89 04 24             	mov    %eax,(%esp)
c0106119:	e8 f3 fc ff ff       	call   c0105e11 <buddy_split>
            //cprintf("[!]BS: Buddy array after SPLITT:\n");
            //show_buddy_array();
            goto find;
c010611e:	e9 28 ff ff ff       	jmp    c010604b <buddy_alloc_pages+0x6b>
    for (int i = order + 1;i < max_order + 1;i ++) {
c0106123:	ff 45 f0             	incl   -0x10(%ebp)
c0106126:	a1 a0 ff 11 c0       	mov    0xc011ffa0,%eax
c010612b:	8d 50 01             	lea    0x1(%eax),%edx
c010612e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106131:	39 c2                	cmp    %eax,%edx
c0106133:	77 ba                	ja     c01060ef <buddy_alloc_pages+0x10f>
        }
    }

done:
c0106135:	90                   	nop
    nr_free -= pnum;
c0106136:	a1 1c 00 12 c0       	mov    0xc012001c,%eax
c010613b:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010613e:	a3 1c 00 12 c0       	mov    %eax,0xc012001c
    //cprintf("[!]BS: nr_free: %d\n", nr_free);
    //cprintf("---------------------------\n");
    return page;
c0106143:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106146:	c9                   	leave  
c0106147:	c3                   	ret    

c0106148 <buddy_get_buddy>:

/*
 *  获取以page页为头页的块的伙伴块
 */
static struct Page*
buddy_get_buddy(struct Page *page) {
c0106148:	f3 0f 1e fb          	endbr32 
c010614c:	55                   	push   %ebp
c010614d:	89 e5                	mov    %esp,%ebp
c010614f:	53                   	push   %ebx
c0106150:	83 ec 14             	sub    $0x14,%esp
    unsigned int order = page->property;
c0106153:	8b 45 08             	mov    0x8(%ebp),%eax
c0106156:	8b 40 08             	mov    0x8(%eax),%eax
c0106159:	89 45 f8             	mov    %eax,-0x8(%ebp)
    unsigned int buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn)); // first_ppn是在ppm.c中新声明的全局变量，表示第一个可分配物理内存页的下标
c010615c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010615f:	ba 01 00 00 00       	mov    $0x1,%edx
c0106164:	88 c1                	mov    %al,%cl
c0106166:	d3 e2                	shl    %cl,%edx
c0106168:	89 d0                	mov    %edx,%eax
c010616a:	89 c3                	mov    %eax,%ebx
c010616c:	8b 45 08             	mov    0x8(%ebp),%eax
c010616f:	89 04 24             	mov    %eax,(%esp)
c0106172:	e8 11 f9 ff ff       	call   c0105a88 <page2ppn>
c0106177:	8b 15 84 fe 11 c0    	mov    0xc011fe84,%edx
c010617d:	29 d0                	sub    %edx,%eax
c010617f:	31 c3                	xor    %eax,%ebx
c0106181:	89 da                	mov    %ebx,%edx
c0106183:	a1 84 fe 11 c0       	mov    0xc011fe84,%eax
c0106188:	01 d0                	add    %edx,%eax
c010618a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
    if (buddy_ppn > page2ppn(page)) {
c010618d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106190:	89 04 24             	mov    %eax,(%esp)
c0106193:	e8 f0 f8 ff ff       	call   c0105a88 <page2ppn>
c0106198:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010619b:	76 23                	jbe    c01061c0 <buddy_get_buddy+0x78>
        return page + (buddy_ppn - page2ppn(page));
c010619d:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a0:	89 04 24             	mov    %eax,(%esp)
c01061a3:	e8 e0 f8 ff ff       	call   c0105a88 <page2ppn>
c01061a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061ab:	29 c2                	sub    %eax,%edx
c01061ad:	89 d0                	mov    %edx,%eax
c01061af:	c1 e0 02             	shl    $0x2,%eax
c01061b2:	01 d0                	add    %edx,%eax
c01061b4:	c1 e0 02             	shl    $0x2,%eax
c01061b7:	89 c2                	mov    %eax,%edx
c01061b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01061bc:	01 d0                	add    %edx,%eax
c01061be:	eb 23                	jmp    c01061e3 <buddy_get_buddy+0x9b>
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
c01061c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01061c3:	89 04 24             	mov    %eax,(%esp)
c01061c6:	e8 bd f8 ff ff       	call   c0105a88 <page2ppn>
c01061cb:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01061ce:	89 c2                	mov    %eax,%edx
c01061d0:	89 d0                	mov    %edx,%eax
c01061d2:	c1 e0 02             	shl    $0x2,%eax
c01061d5:	01 d0                	add    %edx,%eax
c01061d7:	c1 e0 02             	shl    $0x2,%eax
c01061da:	f7 d8                	neg    %eax
c01061dc:	89 c2                	mov    %eax,%edx
c01061de:	8b 45 08             	mov    0x8(%ebp),%eax
c01061e1:	01 d0                	add    %edx,%eax
    }
 
}
c01061e3:	83 c4 14             	add    $0x14,%esp
c01061e6:	5b                   	pop    %ebx
c01061e7:	5d                   	pop    %ebp
c01061e8:	c3                   	ret    

c01061e9 <buddy_free_pages>:
 *  参数：
 *  base：所释放物理块的头页
 *  n： 所释放物理块的的大小（页）
 */
static void
buddy_free_pages(struct Page *base, size_t n) {
c01061e9:	f3 0f 1e fb          	endbr32 
c01061ed:	55                   	push   %ebp
c01061ee:	89 e5                	mov    %esp,%ebp
c01061f0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01061f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01061fa:	75 24                	jne    c0106220 <buddy_free_pages+0x37>
c01061fc:	c7 44 24 0c fb 84 10 	movl   $0xc01084fb,0xc(%esp)
c0106203:	c0 
c0106204:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c010620b:	c0 
c010620c:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106213:	00 
c0106214:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c010621b:	e8 11 a2 ff ff       	call   c0100431 <__panic>
    unsigned int pnum = 1 << (base->property);
c0106220:	8b 45 08             	mov    0x8(%ebp),%eax
c0106223:	8b 40 08             	mov    0x8(%eax),%eax
c0106226:	ba 01 00 00 00       	mov    $0x1,%edx
c010622b:	88 c1                	mov    %al,%cl
c010622d:	d3 e2                	shl    %cl,%edx
c010622f:	89 d0                	mov    %edx,%eax
c0106231:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(ROUNDUP2(n) == pnum);
c0106234:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106237:	89 04 24             	mov    %eax,(%esp)
c010623a:	e8 f2 f8 ff ff       	call   c0105b31 <ROUNDUP2>
c010623f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106242:	74 24                	je     c0106268 <buddy_free_pages+0x7f>
c0106244:	c7 44 24 0c 73 85 10 	movl   $0xc0108573,0xc(%esp)
c010624b:	c0 
c010624c:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0106253:	c0 
c0106254:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010625b:	00 
c010625c:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0106263:	e8 c9 a1 ff ff       	call   c0100431 <__panic>
    //cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
    
    struct Page* left_block = base;
c0106268:	8b 45 08             	mov    0x8(%ebp),%eax
c010626b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page *buddy = NULL;
c010626e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    struct Page* tmp = NULL;
c0106275:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
c010627c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010627f:	8d 50 0c             	lea    0xc(%eax),%edx
c0106282:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106285:	8b 40 08             	mov    0x8(%eax),%eax
c0106288:	c1 e0 03             	shl    $0x3,%eax
c010628b:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0106290:	83 c0 04             	add    $0x4,%eax
c0106293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106296:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0106299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010629c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010629f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm, listelm->next);
c01062a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01062a8:	8b 40 04             	mov    0x4(%eax),%eax
c01062ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01062ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01062b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01062b4:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01062b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01062ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01062bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01062c0:	89 10                	mov    %edx,(%eax)
c01062c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01062c5:	8b 10                	mov    (%eax),%edx
c01062c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01062ca:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01062cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01062d3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01062d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01062dc:	89 10                	mov    %edx,(%eax)
}
c01062de:	90                   	nop
}
c01062df:	90                   	nop
}
c01062e0:	90                   	nop
    //cprintf("[!]BS: add to list\n");
    //show_buddy_array();
    buddy = buddy_get_buddy(left_block);
c01062e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062e4:	89 04 24             	mov    %eax,(%esp)
c01062e7:	e8 5c fe ff ff       	call   c0106148 <buddy_get_buddy>
c01062ec:	89 45 f0             	mov    %eax,-0x10(%ebp)

    //cprintf("array 0:%d,%d\n",buddy_array[0].next,buddy_array[0].next->next);
    //cprintf("left_block:%d,buddy:%d\n",&left_block->page_link,&buddy->page_link);

    while (!PageProperty(buddy) && left_block->property < max_order) {
c01062ef:	e9 02 01 00 00       	jmp    c01063f6 <buddy_free_pages+0x20d>
        //make sure that free the buddy,so left_block must be at lower address
        if ((uint32_t)left_block > (uint32_t)buddy) {
c01062f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062fa:	39 c2                	cmp    %eax,%edx
c01062fc:	76 12                	jbe    c0106310 <buddy_free_pages+0x127>
            tmp = left_block;
c01062fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106301:	89 45 e8             	mov    %eax,-0x18(%ebp)
            left_block = buddy;
c0106304:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106307:	89 45 f4             	mov    %eax,-0xc(%ebp)
            buddy = tmp;
c010630a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010630d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        buddy->property = -1;
c0106310:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106313:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
        
        list_del(&(buddy->page_link)); 
c010631a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010631d:	83 c0 0c             	add    $0xc,%eax
c0106320:	89 45 a0             	mov    %eax,-0x60(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106323:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106326:	8b 40 04             	mov    0x4(%eax),%eax
c0106329:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010632c:	8b 12                	mov    (%edx),%edx
c010632e:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106331:	89 45 98             	mov    %eax,-0x68(%ebp)
    prev->next = next;
c0106334:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106337:	8b 55 98             	mov    -0x68(%ebp),%edx
c010633a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010633d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106340:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106343:	89 10                	mov    %edx,(%eax)
}
c0106345:	90                   	nop
}
c0106346:	90                   	nop
        list_del(&(left_block->page_link));
c0106347:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010634a:	83 c0 0c             	add    $0xc,%eax
c010634d:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106350:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106353:	8b 40 04             	mov    0x4(%eax),%eax
c0106356:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106359:	8b 12                	mov    (%edx),%edx
c010635b:	89 55 a8             	mov    %edx,-0x58(%ebp)
c010635e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c0106361:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106364:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106367:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010636a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010636d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106370:	89 10                	mov    %edx,(%eax)
}
c0106372:	90                   	nop
}
c0106373:	90                   	nop
        
        left_block->property += 1;
c0106374:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106377:	8b 40 08             	mov    0x8(%eax),%eax
c010637a:	8d 50 01             	lea    0x1(%eax),%edx
c010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106380:	89 50 08             	mov    %edx,0x8(%eax)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
c0106383:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106386:	8d 50 0c             	lea    0xc(%eax),%edx
c0106389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010638c:	8b 40 08             	mov    0x8(%eax),%eax
c010638f:	c1 e0 03             	shl    $0x3,%eax
c0106392:	05 a0 ff 11 c0       	add    $0xc011ffa0,%eax
c0106397:	83 c0 04             	add    $0x4,%eax
c010639a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010639d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c01063a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01063a3:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01063a6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01063a9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_add(elm, listelm, listelm->next);
c01063ac:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01063af:	8b 40 04             	mov    0x4(%eax),%eax
c01063b2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01063b5:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01063b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01063bb:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01063be:	89 45 b0             	mov    %eax,-0x50(%ebp)
    prev->next = next->prev = elm;
c01063c1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01063c4:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01063c7:	89 10                	mov    %edx,(%eax)
c01063c9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01063cc:	8b 10                	mov    (%eax),%edx
c01063ce:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01063d1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01063d4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01063d7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01063da:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01063dd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01063e0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01063e3:	89 10                	mov    %edx,(%eax)
}
c01063e5:	90                   	nop
}
c01063e6:	90                   	nop
}
c01063e7:	90                   	nop
        buddy = buddy_get_buddy(left_block);
c01063e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063eb:	89 04 24             	mov    %eax,(%esp)
c01063ee:	e8 55 fd ff ff       	call   c0106148 <buddy_get_buddy>
c01063f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (!PageProperty(buddy) && left_block->property < max_order) {
c01063f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063f9:	83 c0 04             	add    $0x4,%eax
c01063fc:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0106403:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106406:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106409:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010640c:	0f a3 10             	bt     %edx,(%eax)
c010640f:	19 c0                	sbb    %eax,%eax
c0106411:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0106414:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0106418:	0f 95 c0             	setne  %al
c010641b:	0f b6 c0             	movzbl %al,%eax
c010641e:	85 c0                	test   %eax,%eax
c0106420:	75 13                	jne    c0106435 <buddy_free_pages+0x24c>
c0106422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106425:	8b 50 08             	mov    0x8(%eax),%edx
c0106428:	a1 a0 ff 11 c0       	mov    0xc011ffa0,%eax
c010642d:	39 c2                	cmp    %eax,%edx
c010642f:	0f 82 bf fe ff ff    	jb     c01062f4 <buddy_free_pages+0x10b>
    }
    //cprintf("[!]BS: Buddy array after FREE:\n");
    ClearPageProperty(left_block); // 将回收块的头页设置为空闲
c0106435:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106438:	83 c0 04             	add    $0x4,%eax
c010643b:	c7 45 88 01 00 00 00 	movl   $0x1,-0x78(%ebp)
c0106442:	89 45 84             	mov    %eax,-0x7c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106445:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106448:	8b 55 88             	mov    -0x78(%ebp),%edx
c010644b:	0f b3 10             	btr    %edx,(%eax)
}
c010644e:	90                   	nop
    nr_free += pnum;
c010644f:	8b 15 1c 00 12 c0    	mov    0xc012001c,%edx
c0106455:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106458:	01 d0                	add    %edx,%eax
c010645a:	a3 1c 00 12 c0       	mov    %eax,0xc012001c
    //show_buddy_array();
    //cprintf("[!]BS: nr_free: %d\n", nr_free);
    
    return;
c010645f:	90                   	nop
}
c0106460:	c9                   	leave  
c0106461:	c3                   	ret    

c0106462 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
c0106462:	f3 0f 1e fb          	endbr32 
c0106466:	55                   	push   %ebp
c0106467:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106469:	a1 1c 00 12 c0       	mov    0xc012001c,%eax
}//返回还剩多少页可以分
c010646e:	5d                   	pop    %ebp
c010646f:	c3                   	ret    

c0106470 <basic_check>:


static void
basic_check(void) {
c0106470:	f3 0f 1e fb          	endbr32 
c0106474:	55                   	push   %ebp
c0106475:	89 e5                	mov    %esp,%ebp
c0106477:	83 ec 28             	sub    $0x28,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010647a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106481:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106484:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106487:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010648a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    cprintf("alloc 3*1 page\n");
c010648d:	c7 04 24 87 85 10 c0 	movl   $0xc0108587,(%esp)
c0106494:	e8 2c 9e ff ff       	call   c01002c5 <cprintf>
    assert((p0 = alloc_page()) != NULL);
c0106499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01064a0:	e8 6a cc ff ff       	call   c010310f <alloc_pages>
c01064a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01064a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01064ac:	75 24                	jne    c01064d2 <basic_check+0x62>
c01064ae:	c7 44 24 0c 97 85 10 	movl   $0xc0108597,0xc(%esp)
c01064b5:	c0 
c01064b6:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c01064bd:	c0 
c01064be:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01064c5:	00 
c01064c6:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c01064cd:	e8 5f 9f ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01064d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01064d9:	e8 31 cc ff ff       	call   c010310f <alloc_pages>
c01064de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01064e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01064e5:	75 24                	jne    c010650b <basic_check+0x9b>
c01064e7:	c7 44 24 0c b3 85 10 	movl   $0xc01085b3,0xc(%esp)
c01064ee:	c0 
c01064ef:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c01064f6:	c0 
c01064f7:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01064fe:	00 
c01064ff:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0106506:	e8 26 9f ff ff       	call   c0100431 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010650b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106512:	e8 f8 cb ff ff       	call   c010310f <alloc_pages>
c0106517:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010651a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010651e:	75 24                	jne    c0106544 <basic_check+0xd4>
c0106520:	c7 44 24 0c cf 85 10 	movl   $0xc01085cf,0xc(%esp)
c0106527:	c0 
c0106528:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c010652f:	c0 
c0106530:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0106537:	00 
c0106538:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c010653f:	e8 ed 9e ff ff       	call   c0100431 <__panic>
    show_buddy_array();
c0106544:	e8 20 f6 ff ff       	call   c0105b69 <show_buddy_array>

    cprintf("free 3*1 page\n");
c0106549:	c7 04 24 eb 85 10 c0 	movl   $0xc01085eb,(%esp)
c0106550:	e8 70 9d ff ff       	call   c01002c5 <cprintf>
    free_page(p0);
c0106555:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010655c:	00 
c010655d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106560:	89 04 24             	mov    %eax,(%esp)
c0106563:	e8 e3 cb ff ff       	call   c010314b <free_pages>
    free_page(p1);
c0106568:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010656f:	00 
c0106570:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106573:	89 04 24             	mov    %eax,(%esp)
c0106576:	e8 d0 cb ff ff       	call   c010314b <free_pages>
    free_page(p2);
c010657b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106582:	00 
c0106583:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106586:	89 04 24             	mov    %eax,(%esp)
c0106589:	e8 bd cb ff ff       	call   c010314b <free_pages>
    show_buddy_array();
c010658e:	e8 d6 f5 ff ff       	call   c0105b69 <show_buddy_array>

    cprintf("alloc 4,2,1 page\n");
c0106593:	c7 04 24 fa 85 10 c0 	movl   $0xc01085fa,(%esp)
c010659a:	e8 26 9d ff ff       	call   c01002c5 <cprintf>
    assert((p0 = alloc_pages(4)) != NULL);
c010659f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01065a6:	e8 64 cb ff ff       	call   c010310f <alloc_pages>
c01065ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01065ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01065b2:	75 24                	jne    c01065d8 <basic_check+0x168>
c01065b4:	c7 44 24 0c 0c 86 10 	movl   $0xc010860c,0xc(%esp)
c01065bb:	c0 
c01065bc:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c01065c3:	c0 
c01065c4:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01065cb:	00 
c01065cc:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c01065d3:	e8 59 9e ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
c01065d8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01065df:	e8 2b cb ff ff       	call   c010310f <alloc_pages>
c01065e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01065eb:	75 24                	jne    c0106611 <basic_check+0x1a1>
c01065ed:	c7 44 24 0c 2a 86 10 	movl   $0xc010862a,0xc(%esp)
c01065f4:	c0 
c01065f5:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c01065fc:	c0 
c01065fd:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0106604:	00 
c0106605:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c010660c:	e8 20 9e ff ff       	call   c0100431 <__panic>
    assert((p2 = alloc_pages(1)) != NULL);
c0106611:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106618:	e8 f2 ca ff ff       	call   c010310f <alloc_pages>
c010661d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106624:	75 24                	jne    c010664a <basic_check+0x1da>
c0106626:	c7 44 24 0c 48 86 10 	movl   $0xc0108648,0xc(%esp)
c010662d:	c0 
c010662e:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0106635:	c0 
c0106636:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c010663d:	00 
c010663e:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0106645:	e8 e7 9d ff ff       	call   c0100431 <__panic>
    show_buddy_array();
c010664a:	e8 1a f5 ff ff       	call   c0105b69 <show_buddy_array>

    cprintf("free 4,2,1 page\n");
c010664f:	c7 04 24 66 86 10 c0 	movl   $0xc0108666,(%esp)
c0106656:	e8 6a 9c ff ff       	call   c01002c5 <cprintf>
    free_pages(p0, 4);
c010665b:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
c0106662:	00 
c0106663:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106666:	89 04 24             	mov    %eax,(%esp)
c0106669:	e8 dd ca ff ff       	call   c010314b <free_pages>
    free_pages(p1, 2);
c010666e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106675:	00 
c0106676:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106679:	89 04 24             	mov    %eax,(%esp)
c010667c:	e8 ca ca ff ff       	call   c010314b <free_pages>
    free_pages(p2, 1);
c0106681:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106688:	00 
c0106689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010668c:	89 04 24             	mov    %eax,(%esp)
c010668f:	e8 b7 ca ff ff       	call   c010314b <free_pages>
    show_buddy_array();
c0106694:	e8 d0 f4 ff ff       	call   c0105b69 <show_buddy_array>

    cprintf("free 2*3 page\n");
c0106699:	c7 04 24 77 86 10 c0 	movl   $0xc0108677,(%esp)
c01066a0:	e8 20 9c ff ff       	call   c01002c5 <cprintf>
    assert((p0 = alloc_pages(3)) != NULL);
c01066a5:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01066ac:	e8 5e ca ff ff       	call   c010310f <alloc_pages>
c01066b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01066b8:	75 24                	jne    c01066de <basic_check+0x26e>
c01066ba:	c7 44 24 0c 86 86 10 	movl   $0xc0108686,0xc(%esp)
c01066c1:	c0 
c01066c2:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c01066c9:	c0 
c01066ca:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01066d1:	00 
c01066d2:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c01066d9:	e8 53 9d ff ff       	call   c0100431 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01066de:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01066e5:	e8 25 ca ff ff       	call   c010310f <alloc_pages>
c01066ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066f1:	75 24                	jne    c0106717 <basic_check+0x2a7>
c01066f3:	c7 44 24 0c a4 86 10 	movl   $0xc01086a4,0xc(%esp)
c01066fa:	c0 
c01066fb:	c7 44 24 08 01 85 10 	movl   $0xc0108501,0x8(%esp)
c0106702:	c0 
c0106703:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010670a:	00 
c010670b:	c7 04 24 16 85 10 c0 	movl   $0xc0108516,(%esp)
c0106712:	e8 1a 9d ff ff       	call   c0100431 <__panic>
    show_buddy_array();
c0106717:	e8 4d f4 ff ff       	call   c0105b69 <show_buddy_array>
    
    cprintf("free 2*3 page\n");
c010671c:	c7 04 24 77 86 10 c0 	movl   $0xc0108677,(%esp)
c0106723:	e8 9d 9b ff ff       	call   c01002c5 <cprintf>
    free_pages(p0, 3);
c0106728:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010672f:	00 
c0106730:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106733:	89 04 24             	mov    %eax,(%esp)
c0106736:	e8 10 ca ff ff       	call   c010314b <free_pages>
    free_pages(p1, 3);
c010673b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106742:	00 
c0106743:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106746:	89 04 24             	mov    %eax,(%esp)
c0106749:	e8 fd c9 ff ff       	call   c010314b <free_pages>
    show_buddy_array();
c010674e:	e8 16 f4 ff ff       	call   c0105b69 <show_buddy_array>
}
c0106753:	90                   	nop
c0106754:	c9                   	leave  
c0106755:	c3                   	ret    

c0106756 <buddy_check>:
static void
buddy_check(void) {
c0106756:	f3 0f 1e fb          	endbr32 
c010675a:	55                   	push   %ebp
c010675b:	89 e5                	mov    %esp,%ebp
c010675d:	83 ec 08             	sub    $0x8,%esp
    basic_check();
c0106760:	e8 0b fd ff ff       	call   c0106470 <basic_check>
}   
c0106765:	90                   	nop
c0106766:	c9                   	leave  
c0106767:	c3                   	ret    

c0106768 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0106768:	f3 0f 1e fb          	endbr32 
c010676c:	55                   	push   %ebp
c010676d:	89 e5                	mov    %esp,%ebp
c010676f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106772:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106779:	eb 03                	jmp    c010677e <strlen+0x16>
        cnt ++;
c010677b:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010677e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106781:	8d 50 01             	lea    0x1(%eax),%edx
c0106784:	89 55 08             	mov    %edx,0x8(%ebp)
c0106787:	0f b6 00             	movzbl (%eax),%eax
c010678a:	84 c0                	test   %al,%al
c010678c:	75 ed                	jne    c010677b <strlen+0x13>
    }
    return cnt;
c010678e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106791:	c9                   	leave  
c0106792:	c3                   	ret    

c0106793 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106793:	f3 0f 1e fb          	endbr32 
c0106797:	55                   	push   %ebp
c0106798:	89 e5                	mov    %esp,%ebp
c010679a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010679d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01067a4:	eb 03                	jmp    c01067a9 <strnlen+0x16>
        cnt ++;
c01067a6:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01067a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01067af:	73 10                	jae    c01067c1 <strnlen+0x2e>
c01067b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b4:	8d 50 01             	lea    0x1(%eax),%edx
c01067b7:	89 55 08             	mov    %edx,0x8(%ebp)
c01067ba:	0f b6 00             	movzbl (%eax),%eax
c01067bd:	84 c0                	test   %al,%al
c01067bf:	75 e5                	jne    c01067a6 <strnlen+0x13>
    }
    return cnt;
c01067c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01067c4:	c9                   	leave  
c01067c5:	c3                   	ret    

c01067c6 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01067c6:	f3 0f 1e fb          	endbr32 
c01067ca:	55                   	push   %ebp
c01067cb:	89 e5                	mov    %esp,%ebp
c01067cd:	57                   	push   %edi
c01067ce:	56                   	push   %esi
c01067cf:	83 ec 20             	sub    $0x20,%esp
c01067d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01067d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067db:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01067de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067e4:	89 d1                	mov    %edx,%ecx
c01067e6:	89 c2                	mov    %eax,%edx
c01067e8:	89 ce                	mov    %ecx,%esi
c01067ea:	89 d7                	mov    %edx,%edi
c01067ec:	ac                   	lods   %ds:(%esi),%al
c01067ed:	aa                   	stos   %al,%es:(%edi)
c01067ee:	84 c0                	test   %al,%al
c01067f0:	75 fa                	jne    c01067ec <strcpy+0x26>
c01067f2:	89 fa                	mov    %edi,%edx
c01067f4:	89 f1                	mov    %esi,%ecx
c01067f6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01067f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01067fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01067ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106802:	83 c4 20             	add    $0x20,%esp
c0106805:	5e                   	pop    %esi
c0106806:	5f                   	pop    %edi
c0106807:	5d                   	pop    %ebp
c0106808:	c3                   	ret    

c0106809 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0106809:	f3 0f 1e fb          	endbr32 
c010680d:	55                   	push   %ebp
c010680e:	89 e5                	mov    %esp,%ebp
c0106810:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106813:	8b 45 08             	mov    0x8(%ebp),%eax
c0106816:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106819:	eb 1e                	jmp    c0106839 <strncpy+0x30>
        if ((*p = *src) != '\0') {
c010681b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010681e:	0f b6 10             	movzbl (%eax),%edx
c0106821:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106824:	88 10                	mov    %dl,(%eax)
c0106826:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106829:	0f b6 00             	movzbl (%eax),%eax
c010682c:	84 c0                	test   %al,%al
c010682e:	74 03                	je     c0106833 <strncpy+0x2a>
            src ++;
c0106830:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0106833:	ff 45 fc             	incl   -0x4(%ebp)
c0106836:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0106839:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010683d:	75 dc                	jne    c010681b <strncpy+0x12>
    }
    return dst;
c010683f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106842:	c9                   	leave  
c0106843:	c3                   	ret    

c0106844 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106844:	f3 0f 1e fb          	endbr32 
c0106848:	55                   	push   %ebp
c0106849:	89 e5                	mov    %esp,%ebp
c010684b:	57                   	push   %edi
c010684c:	56                   	push   %esi
c010684d:	83 ec 20             	sub    $0x20,%esp
c0106850:	8b 45 08             	mov    0x8(%ebp),%eax
c0106853:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106856:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106859:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010685c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010685f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106862:	89 d1                	mov    %edx,%ecx
c0106864:	89 c2                	mov    %eax,%edx
c0106866:	89 ce                	mov    %ecx,%esi
c0106868:	89 d7                	mov    %edx,%edi
c010686a:	ac                   	lods   %ds:(%esi),%al
c010686b:	ae                   	scas   %es:(%edi),%al
c010686c:	75 08                	jne    c0106876 <strcmp+0x32>
c010686e:	84 c0                	test   %al,%al
c0106870:	75 f8                	jne    c010686a <strcmp+0x26>
c0106872:	31 c0                	xor    %eax,%eax
c0106874:	eb 04                	jmp    c010687a <strcmp+0x36>
c0106876:	19 c0                	sbb    %eax,%eax
c0106878:	0c 01                	or     $0x1,%al
c010687a:	89 fa                	mov    %edi,%edx
c010687c:	89 f1                	mov    %esi,%ecx
c010687e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106881:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106884:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106887:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010688a:	83 c4 20             	add    $0x20,%esp
c010688d:	5e                   	pop    %esi
c010688e:	5f                   	pop    %edi
c010688f:	5d                   	pop    %ebp
c0106890:	c3                   	ret    

c0106891 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106891:	f3 0f 1e fb          	endbr32 
c0106895:	55                   	push   %ebp
c0106896:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106898:	eb 09                	jmp    c01068a3 <strncmp+0x12>
        n --, s1 ++, s2 ++;
c010689a:	ff 4d 10             	decl   0x10(%ebp)
c010689d:	ff 45 08             	incl   0x8(%ebp)
c01068a0:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01068a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01068a7:	74 1a                	je     c01068c3 <strncmp+0x32>
c01068a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01068ac:	0f b6 00             	movzbl (%eax),%eax
c01068af:	84 c0                	test   %al,%al
c01068b1:	74 10                	je     c01068c3 <strncmp+0x32>
c01068b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b6:	0f b6 10             	movzbl (%eax),%edx
c01068b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068bc:	0f b6 00             	movzbl (%eax),%eax
c01068bf:	38 c2                	cmp    %al,%dl
c01068c1:	74 d7                	je     c010689a <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01068c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01068c7:	74 18                	je     c01068e1 <strncmp+0x50>
c01068c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01068cc:	0f b6 00             	movzbl (%eax),%eax
c01068cf:	0f b6 d0             	movzbl %al,%edx
c01068d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068d5:	0f b6 00             	movzbl (%eax),%eax
c01068d8:	0f b6 c0             	movzbl %al,%eax
c01068db:	29 c2                	sub    %eax,%edx
c01068dd:	89 d0                	mov    %edx,%eax
c01068df:	eb 05                	jmp    c01068e6 <strncmp+0x55>
c01068e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01068e6:	5d                   	pop    %ebp
c01068e7:	c3                   	ret    

c01068e8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01068e8:	f3 0f 1e fb          	endbr32 
c01068ec:	55                   	push   %ebp
c01068ed:	89 e5                	mov    %esp,%ebp
c01068ef:	83 ec 04             	sub    $0x4,%esp
c01068f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068f5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01068f8:	eb 13                	jmp    c010690d <strchr+0x25>
        if (*s == c) {
c01068fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01068fd:	0f b6 00             	movzbl (%eax),%eax
c0106900:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106903:	75 05                	jne    c010690a <strchr+0x22>
            return (char *)s;
c0106905:	8b 45 08             	mov    0x8(%ebp),%eax
c0106908:	eb 12                	jmp    c010691c <strchr+0x34>
        }
        s ++;
c010690a:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010690d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106910:	0f b6 00             	movzbl (%eax),%eax
c0106913:	84 c0                	test   %al,%al
c0106915:	75 e3                	jne    c01068fa <strchr+0x12>
    }
    return NULL;
c0106917:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010691c:	c9                   	leave  
c010691d:	c3                   	ret    

c010691e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010691e:	f3 0f 1e fb          	endbr32 
c0106922:	55                   	push   %ebp
c0106923:	89 e5                	mov    %esp,%ebp
c0106925:	83 ec 04             	sub    $0x4,%esp
c0106928:	8b 45 0c             	mov    0xc(%ebp),%eax
c010692b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010692e:	eb 0e                	jmp    c010693e <strfind+0x20>
        if (*s == c) {
c0106930:	8b 45 08             	mov    0x8(%ebp),%eax
c0106933:	0f b6 00             	movzbl (%eax),%eax
c0106936:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106939:	74 0f                	je     c010694a <strfind+0x2c>
            break;
        }
        s ++;
c010693b:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010693e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106941:	0f b6 00             	movzbl (%eax),%eax
c0106944:	84 c0                	test   %al,%al
c0106946:	75 e8                	jne    c0106930 <strfind+0x12>
c0106948:	eb 01                	jmp    c010694b <strfind+0x2d>
            break;
c010694a:	90                   	nop
    }
    return (char *)s;
c010694b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010694e:	c9                   	leave  
c010694f:	c3                   	ret    

c0106950 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106950:	f3 0f 1e fb          	endbr32 
c0106954:	55                   	push   %ebp
c0106955:	89 e5                	mov    %esp,%ebp
c0106957:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010695a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106961:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106968:	eb 03                	jmp    c010696d <strtol+0x1d>
        s ++;
c010696a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010696d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106970:	0f b6 00             	movzbl (%eax),%eax
c0106973:	3c 20                	cmp    $0x20,%al
c0106975:	74 f3                	je     c010696a <strtol+0x1a>
c0106977:	8b 45 08             	mov    0x8(%ebp),%eax
c010697a:	0f b6 00             	movzbl (%eax),%eax
c010697d:	3c 09                	cmp    $0x9,%al
c010697f:	74 e9                	je     c010696a <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c0106981:	8b 45 08             	mov    0x8(%ebp),%eax
c0106984:	0f b6 00             	movzbl (%eax),%eax
c0106987:	3c 2b                	cmp    $0x2b,%al
c0106989:	75 05                	jne    c0106990 <strtol+0x40>
        s ++;
c010698b:	ff 45 08             	incl   0x8(%ebp)
c010698e:	eb 14                	jmp    c01069a4 <strtol+0x54>
    }
    else if (*s == '-') {
c0106990:	8b 45 08             	mov    0x8(%ebp),%eax
c0106993:	0f b6 00             	movzbl (%eax),%eax
c0106996:	3c 2d                	cmp    $0x2d,%al
c0106998:	75 0a                	jne    c01069a4 <strtol+0x54>
        s ++, neg = 1;
c010699a:	ff 45 08             	incl   0x8(%ebp)
c010699d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01069a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01069a8:	74 06                	je     c01069b0 <strtol+0x60>
c01069aa:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01069ae:	75 22                	jne    c01069d2 <strtol+0x82>
c01069b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b3:	0f b6 00             	movzbl (%eax),%eax
c01069b6:	3c 30                	cmp    $0x30,%al
c01069b8:	75 18                	jne    c01069d2 <strtol+0x82>
c01069ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01069bd:	40                   	inc    %eax
c01069be:	0f b6 00             	movzbl (%eax),%eax
c01069c1:	3c 78                	cmp    $0x78,%al
c01069c3:	75 0d                	jne    c01069d2 <strtol+0x82>
        s += 2, base = 16;
c01069c5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01069c9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01069d0:	eb 29                	jmp    c01069fb <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c01069d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01069d6:	75 16                	jne    c01069ee <strtol+0x9e>
c01069d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069db:	0f b6 00             	movzbl (%eax),%eax
c01069de:	3c 30                	cmp    $0x30,%al
c01069e0:	75 0c                	jne    c01069ee <strtol+0x9e>
        s ++, base = 8;
c01069e2:	ff 45 08             	incl   0x8(%ebp)
c01069e5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01069ec:	eb 0d                	jmp    c01069fb <strtol+0xab>
    }
    else if (base == 0) {
c01069ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01069f2:	75 07                	jne    c01069fb <strtol+0xab>
        base = 10;
c01069f4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01069fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01069fe:	0f b6 00             	movzbl (%eax),%eax
c0106a01:	3c 2f                	cmp    $0x2f,%al
c0106a03:	7e 1b                	jle    c0106a20 <strtol+0xd0>
c0106a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a08:	0f b6 00             	movzbl (%eax),%eax
c0106a0b:	3c 39                	cmp    $0x39,%al
c0106a0d:	7f 11                	jg     c0106a20 <strtol+0xd0>
            dig = *s - '0';
c0106a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a12:	0f b6 00             	movzbl (%eax),%eax
c0106a15:	0f be c0             	movsbl %al,%eax
c0106a18:	83 e8 30             	sub    $0x30,%eax
c0106a1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a1e:	eb 48                	jmp    c0106a68 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0106a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a23:	0f b6 00             	movzbl (%eax),%eax
c0106a26:	3c 60                	cmp    $0x60,%al
c0106a28:	7e 1b                	jle    c0106a45 <strtol+0xf5>
c0106a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a2d:	0f b6 00             	movzbl (%eax),%eax
c0106a30:	3c 7a                	cmp    $0x7a,%al
c0106a32:	7f 11                	jg     c0106a45 <strtol+0xf5>
            dig = *s - 'a' + 10;
c0106a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a37:	0f b6 00             	movzbl (%eax),%eax
c0106a3a:	0f be c0             	movsbl %al,%eax
c0106a3d:	83 e8 57             	sub    $0x57,%eax
c0106a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a43:	eb 23                	jmp    c0106a68 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0106a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a48:	0f b6 00             	movzbl (%eax),%eax
c0106a4b:	3c 40                	cmp    $0x40,%al
c0106a4d:	7e 3b                	jle    c0106a8a <strtol+0x13a>
c0106a4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a52:	0f b6 00             	movzbl (%eax),%eax
c0106a55:	3c 5a                	cmp    $0x5a,%al
c0106a57:	7f 31                	jg     c0106a8a <strtol+0x13a>
            dig = *s - 'A' + 10;
c0106a59:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a5c:	0f b6 00             	movzbl (%eax),%eax
c0106a5f:	0f be c0             	movsbl %al,%eax
c0106a62:	83 e8 37             	sub    $0x37,%eax
c0106a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a6b:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106a6e:	7d 19                	jge    c0106a89 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c0106a70:	ff 45 08             	incl   0x8(%ebp)
c0106a73:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106a76:	0f af 45 10          	imul   0x10(%ebp),%eax
c0106a7a:	89 c2                	mov    %eax,%edx
c0106a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a7f:	01 d0                	add    %edx,%eax
c0106a81:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106a84:	e9 72 ff ff ff       	jmp    c01069fb <strtol+0xab>
            break;
c0106a89:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0106a8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106a8e:	74 08                	je     c0106a98 <strtol+0x148>
        *endptr = (char *) s;
c0106a90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a93:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a96:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106a98:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106a9c:	74 07                	je     c0106aa5 <strtol+0x155>
c0106a9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106aa1:	f7 d8                	neg    %eax
c0106aa3:	eb 03                	jmp    c0106aa8 <strtol+0x158>
c0106aa5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106aa8:	c9                   	leave  
c0106aa9:	c3                   	ret    

c0106aaa <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106aaa:	f3 0f 1e fb          	endbr32 
c0106aae:	55                   	push   %ebp
c0106aaf:	89 e5                	mov    %esp,%ebp
c0106ab1:	57                   	push   %edi
c0106ab2:	83 ec 24             	sub    $0x24,%esp
c0106ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ab8:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106abb:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0106abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ac2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0106ac5:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0106ac8:	8b 45 10             	mov    0x10(%ebp),%eax
c0106acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106ace:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106ad1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106ad5:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106ad8:	89 d7                	mov    %edx,%edi
c0106ada:	f3 aa                	rep stos %al,%es:(%edi)
c0106adc:	89 fa                	mov    %edi,%edx
c0106ade:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106ae1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106ae4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106ae7:	83 c4 24             	add    $0x24,%esp
c0106aea:	5f                   	pop    %edi
c0106aeb:	5d                   	pop    %ebp
c0106aec:	c3                   	ret    

c0106aed <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106aed:	f3 0f 1e fb          	endbr32 
c0106af1:	55                   	push   %ebp
c0106af2:	89 e5                	mov    %esp,%ebp
c0106af4:	57                   	push   %edi
c0106af5:	56                   	push   %esi
c0106af6:	53                   	push   %ebx
c0106af7:	83 ec 30             	sub    $0x30,%esp
c0106afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0106afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b03:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b06:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b09:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106b12:	73 42                	jae    c0106b56 <memmove+0x69>
c0106b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106b20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b23:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106b26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106b29:	c1 e8 02             	shr    $0x2,%eax
c0106b2c:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106b2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b34:	89 d7                	mov    %edx,%edi
c0106b36:	89 c6                	mov    %eax,%esi
c0106b38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106b3a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106b3d:	83 e1 03             	and    $0x3,%ecx
c0106b40:	74 02                	je     c0106b44 <memmove+0x57>
c0106b42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106b44:	89 f0                	mov    %esi,%eax
c0106b46:	89 fa                	mov    %edi,%edx
c0106b48:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106b4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106b4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0106b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0106b54:	eb 36                	jmp    c0106b8c <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b59:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b5f:	01 c2                	add    %eax,%edx
c0106b61:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b64:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b6a:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0106b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b70:	89 c1                	mov    %eax,%ecx
c0106b72:	89 d8                	mov    %ebx,%eax
c0106b74:	89 d6                	mov    %edx,%esi
c0106b76:	89 c7                	mov    %eax,%edi
c0106b78:	fd                   	std    
c0106b79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106b7b:	fc                   	cld    
c0106b7c:	89 f8                	mov    %edi,%eax
c0106b7e:	89 f2                	mov    %esi,%edx
c0106b80:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106b83:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106b86:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106b8c:	83 c4 30             	add    $0x30,%esp
c0106b8f:	5b                   	pop    %ebx
c0106b90:	5e                   	pop    %esi
c0106b91:	5f                   	pop    %edi
c0106b92:	5d                   	pop    %ebp
c0106b93:	c3                   	ret    

c0106b94 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106b94:	f3 0f 1e fb          	endbr32 
c0106b98:	55                   	push   %ebp
c0106b99:	89 e5                	mov    %esp,%ebp
c0106b9b:	57                   	push   %edi
c0106b9c:	56                   	push   %esi
c0106b9d:	83 ec 20             	sub    $0x20,%esp
c0106ba0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bac:	8b 45 10             	mov    0x10(%ebp),%eax
c0106baf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106bb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bb5:	c1 e8 02             	shr    $0x2,%eax
c0106bb8:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bc0:	89 d7                	mov    %edx,%edi
c0106bc2:	89 c6                	mov    %eax,%esi
c0106bc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106bc6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106bc9:	83 e1 03             	and    $0x3,%ecx
c0106bcc:	74 02                	je     c0106bd0 <memcpy+0x3c>
c0106bce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106bd0:	89 f0                	mov    %esi,%eax
c0106bd2:	89 fa                	mov    %edi,%edx
c0106bd4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106bd7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106bda:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0106bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106be0:	83 c4 20             	add    $0x20,%esp
c0106be3:	5e                   	pop    %esi
c0106be4:	5f                   	pop    %edi
c0106be5:	5d                   	pop    %ebp
c0106be6:	c3                   	ret    

c0106be7 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0106be7:	f3 0f 1e fb          	endbr32 
c0106beb:	55                   	push   %ebp
c0106bec:	89 e5                	mov    %esp,%ebp
c0106bee:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bfa:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0106bfd:	eb 2e                	jmp    c0106c2d <memcmp+0x46>
        if (*s1 != *s2) {
c0106bff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c02:	0f b6 10             	movzbl (%eax),%edx
c0106c05:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106c08:	0f b6 00             	movzbl (%eax),%eax
c0106c0b:	38 c2                	cmp    %al,%dl
c0106c0d:	74 18                	je     c0106c27 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106c0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c12:	0f b6 00             	movzbl (%eax),%eax
c0106c15:	0f b6 d0             	movzbl %al,%edx
c0106c18:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106c1b:	0f b6 00             	movzbl (%eax),%eax
c0106c1e:	0f b6 c0             	movzbl %al,%eax
c0106c21:	29 c2                	sub    %eax,%edx
c0106c23:	89 d0                	mov    %edx,%eax
c0106c25:	eb 18                	jmp    c0106c3f <memcmp+0x58>
        }
        s1 ++, s2 ++;
c0106c27:	ff 45 fc             	incl   -0x4(%ebp)
c0106c2a:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0106c2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c30:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106c33:	89 55 10             	mov    %edx,0x10(%ebp)
c0106c36:	85 c0                	test   %eax,%eax
c0106c38:	75 c5                	jne    c0106bff <memcmp+0x18>
    }
    return 0;
c0106c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c3f:	c9                   	leave  
c0106c40:	c3                   	ret    

c0106c41 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0106c41:	f3 0f 1e fb          	endbr32 
c0106c45:	55                   	push   %ebp
c0106c46:	89 e5                	mov    %esp,%ebp
c0106c48:	83 ec 58             	sub    $0x58,%esp
c0106c4b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106c51:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c54:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0106c57:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106c5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106c5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106c60:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106c63:	8b 45 18             	mov    0x18(%ebp),%eax
c0106c66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106c69:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106c6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106c6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106c72:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106c7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106c7f:	74 1c                	je     c0106c9d <printnum+0x5c>
c0106c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c84:	ba 00 00 00 00       	mov    $0x0,%edx
c0106c89:	f7 75 e4             	divl   -0x1c(%ebp)
c0106c8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0106c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c92:	ba 00 00 00 00       	mov    $0x0,%edx
c0106c97:	f7 75 e4             	divl   -0x1c(%ebp)
c0106c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106ca3:	f7 75 e4             	divl   -0x1c(%ebp)
c0106ca6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106ca9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106caf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106cb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106cb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106cbb:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0106cbe:	8b 45 18             	mov    0x18(%ebp),%eax
c0106cc1:	ba 00 00 00 00       	mov    $0x0,%edx
c0106cc6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106cc9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0106ccc:	19 d1                	sbb    %edx,%ecx
c0106cce:	72 4c                	jb     c0106d1c <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106cd0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106cd3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106cd6:	8b 45 20             	mov    0x20(%ebp),%eax
c0106cd9:	89 44 24 18          	mov    %eax,0x18(%esp)
c0106cdd:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106ce1:	8b 45 18             	mov    0x18(%ebp),%eax
c0106ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106ce8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ceb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106cee:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106cf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d00:	89 04 24             	mov    %eax,(%esp)
c0106d03:	e8 39 ff ff ff       	call   c0106c41 <printnum>
c0106d08:	eb 1b                	jmp    c0106d25 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0106d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d11:	8b 45 20             	mov    0x20(%ebp),%eax
c0106d14:	89 04 24             	mov    %eax,(%esp)
c0106d17:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d1a:	ff d0                	call   *%eax
        while (-- width > 0)
c0106d1c:	ff 4d 1c             	decl   0x1c(%ebp)
c0106d1f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106d23:	7f e5                	jg     c0106d0a <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106d25:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106d28:	05 70 87 10 c0       	add    $0xc0108770,%eax
c0106d2d:	0f b6 00             	movzbl (%eax),%eax
c0106d30:	0f be c0             	movsbl %al,%eax
c0106d33:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d3a:	89 04 24             	mov    %eax,(%esp)
c0106d3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d40:	ff d0                	call   *%eax
}
c0106d42:	90                   	nop
c0106d43:	c9                   	leave  
c0106d44:	c3                   	ret    

c0106d45 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0106d45:	f3 0f 1e fb          	endbr32 
c0106d49:	55                   	push   %ebp
c0106d4a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0106d4c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106d50:	7e 14                	jle    c0106d66 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c0106d52:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d55:	8b 00                	mov    (%eax),%eax
c0106d57:	8d 48 08             	lea    0x8(%eax),%ecx
c0106d5a:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d5d:	89 0a                	mov    %ecx,(%edx)
c0106d5f:	8b 50 04             	mov    0x4(%eax),%edx
c0106d62:	8b 00                	mov    (%eax),%eax
c0106d64:	eb 30                	jmp    c0106d96 <getuint+0x51>
    }
    else if (lflag) {
c0106d66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106d6a:	74 16                	je     c0106d82 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c0106d6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d6f:	8b 00                	mov    (%eax),%eax
c0106d71:	8d 48 04             	lea    0x4(%eax),%ecx
c0106d74:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d77:	89 0a                	mov    %ecx,(%edx)
c0106d79:	8b 00                	mov    (%eax),%eax
c0106d7b:	ba 00 00 00 00       	mov    $0x0,%edx
c0106d80:	eb 14                	jmp    c0106d96 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106d82:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d85:	8b 00                	mov    (%eax),%eax
c0106d87:	8d 48 04             	lea    0x4(%eax),%ecx
c0106d8a:	8b 55 08             	mov    0x8(%ebp),%edx
c0106d8d:	89 0a                	mov    %ecx,(%edx)
c0106d8f:	8b 00                	mov    (%eax),%eax
c0106d91:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106d96:	5d                   	pop    %ebp
c0106d97:	c3                   	ret    

c0106d98 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0106d98:	f3 0f 1e fb          	endbr32 
c0106d9c:	55                   	push   %ebp
c0106d9d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0106d9f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106da3:	7e 14                	jle    c0106db9 <getint+0x21>
        return va_arg(*ap, long long);
c0106da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106da8:	8b 00                	mov    (%eax),%eax
c0106daa:	8d 48 08             	lea    0x8(%eax),%ecx
c0106dad:	8b 55 08             	mov    0x8(%ebp),%edx
c0106db0:	89 0a                	mov    %ecx,(%edx)
c0106db2:	8b 50 04             	mov    0x4(%eax),%edx
c0106db5:	8b 00                	mov    (%eax),%eax
c0106db7:	eb 28                	jmp    c0106de1 <getint+0x49>
    }
    else if (lflag) {
c0106db9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106dbd:	74 12                	je     c0106dd1 <getint+0x39>
        return va_arg(*ap, long);
c0106dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dc2:	8b 00                	mov    (%eax),%eax
c0106dc4:	8d 48 04             	lea    0x4(%eax),%ecx
c0106dc7:	8b 55 08             	mov    0x8(%ebp),%edx
c0106dca:	89 0a                	mov    %ecx,(%edx)
c0106dcc:	8b 00                	mov    (%eax),%eax
c0106dce:	99                   	cltd   
c0106dcf:	eb 10                	jmp    c0106de1 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c0106dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dd4:	8b 00                	mov    (%eax),%eax
c0106dd6:	8d 48 04             	lea    0x4(%eax),%ecx
c0106dd9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ddc:	89 0a                	mov    %ecx,(%edx)
c0106dde:	8b 00                	mov    (%eax),%eax
c0106de0:	99                   	cltd   
    }
}
c0106de1:	5d                   	pop    %ebp
c0106de2:	c3                   	ret    

c0106de3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0106de3:	f3 0f 1e fb          	endbr32 
c0106de7:	55                   	push   %ebp
c0106de8:	89 e5                	mov    %esp,%ebp
c0106dea:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106ded:	8d 45 14             	lea    0x14(%ebp),%eax
c0106df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0106df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106df6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106dfa:	8b 45 10             	mov    0x10(%ebp),%eax
c0106dfd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e0b:	89 04 24             	mov    %eax,(%esp)
c0106e0e:	e8 03 00 00 00       	call   c0106e16 <vprintfmt>
    va_end(ap);
}
c0106e13:	90                   	nop
c0106e14:	c9                   	leave  
c0106e15:	c3                   	ret    

c0106e16 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0106e16:	f3 0f 1e fb          	endbr32 
c0106e1a:	55                   	push   %ebp
c0106e1b:	89 e5                	mov    %esp,%ebp
c0106e1d:	56                   	push   %esi
c0106e1e:	53                   	push   %ebx
c0106e1f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106e22:	eb 17                	jmp    c0106e3b <vprintfmt+0x25>
            if (ch == '\0') {
c0106e24:	85 db                	test   %ebx,%ebx
c0106e26:	0f 84 c0 03 00 00    	je     c01071ec <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c0106e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e33:	89 1c 24             	mov    %ebx,(%esp)
c0106e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e39:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106e3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e3e:	8d 50 01             	lea    0x1(%eax),%edx
c0106e41:	89 55 10             	mov    %edx,0x10(%ebp)
c0106e44:	0f b6 00             	movzbl (%eax),%eax
c0106e47:	0f b6 d8             	movzbl %al,%ebx
c0106e4a:	83 fb 25             	cmp    $0x25,%ebx
c0106e4d:	75 d5                	jne    c0106e24 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0106e4f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0106e53:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0106e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0106e60:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106e67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e6a:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106e6d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e70:	8d 50 01             	lea    0x1(%eax),%edx
c0106e73:	89 55 10             	mov    %edx,0x10(%ebp)
c0106e76:	0f b6 00             	movzbl (%eax),%eax
c0106e79:	0f b6 d8             	movzbl %al,%ebx
c0106e7c:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106e7f:	83 f8 55             	cmp    $0x55,%eax
c0106e82:	0f 87 38 03 00 00    	ja     c01071c0 <vprintfmt+0x3aa>
c0106e88:	8b 04 85 94 87 10 c0 	mov    -0x3fef786c(,%eax,4),%eax
c0106e8f:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106e92:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106e96:	eb d5                	jmp    c0106e6d <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0106e98:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106e9c:	eb cf                	jmp    c0106e6d <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106e9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106ea5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106ea8:	89 d0                	mov    %edx,%eax
c0106eaa:	c1 e0 02             	shl    $0x2,%eax
c0106ead:	01 d0                	add    %edx,%eax
c0106eaf:	01 c0                	add    %eax,%eax
c0106eb1:	01 d8                	add    %ebx,%eax
c0106eb3:	83 e8 30             	sub    $0x30,%eax
c0106eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106eb9:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ebc:	0f b6 00             	movzbl (%eax),%eax
c0106ebf:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106ec2:	83 fb 2f             	cmp    $0x2f,%ebx
c0106ec5:	7e 38                	jle    c0106eff <vprintfmt+0xe9>
c0106ec7:	83 fb 39             	cmp    $0x39,%ebx
c0106eca:	7f 33                	jg     c0106eff <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c0106ecc:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0106ecf:	eb d4                	jmp    c0106ea5 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106ed1:	8b 45 14             	mov    0x14(%ebp),%eax
c0106ed4:	8d 50 04             	lea    0x4(%eax),%edx
c0106ed7:	89 55 14             	mov    %edx,0x14(%ebp)
c0106eda:	8b 00                	mov    (%eax),%eax
c0106edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106edf:	eb 1f                	jmp    c0106f00 <vprintfmt+0xea>

        case '.':
            if (width < 0)
c0106ee1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106ee5:	79 86                	jns    c0106e6d <vprintfmt+0x57>
                width = 0;
c0106ee7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106eee:	e9 7a ff ff ff       	jmp    c0106e6d <vprintfmt+0x57>

        case '#':
            altflag = 1;
c0106ef3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106efa:	e9 6e ff ff ff       	jmp    c0106e6d <vprintfmt+0x57>
            goto process_precision;
c0106eff:	90                   	nop

        process_precision:
            if (width < 0)
c0106f00:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106f04:	0f 89 63 ff ff ff    	jns    c0106e6d <vprintfmt+0x57>
                width = precision, precision = -1;
c0106f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106f10:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0106f17:	e9 51 ff ff ff       	jmp    c0106e6d <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106f1c:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0106f1f:	e9 49 ff ff ff       	jmp    c0106e6d <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106f24:	8b 45 14             	mov    0x14(%ebp),%eax
c0106f27:	8d 50 04             	lea    0x4(%eax),%edx
c0106f2a:	89 55 14             	mov    %edx,0x14(%ebp)
c0106f2d:	8b 00                	mov    (%eax),%eax
c0106f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106f32:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f36:	89 04 24             	mov    %eax,(%esp)
c0106f39:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f3c:	ff d0                	call   *%eax
            break;
c0106f3e:	e9 a4 02 00 00       	jmp    c01071e7 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106f43:	8b 45 14             	mov    0x14(%ebp),%eax
c0106f46:	8d 50 04             	lea    0x4(%eax),%edx
c0106f49:	89 55 14             	mov    %edx,0x14(%ebp)
c0106f4c:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106f4e:	85 db                	test   %ebx,%ebx
c0106f50:	79 02                	jns    c0106f54 <vprintfmt+0x13e>
                err = -err;
c0106f52:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0106f54:	83 fb 06             	cmp    $0x6,%ebx
c0106f57:	7f 0b                	jg     c0106f64 <vprintfmt+0x14e>
c0106f59:	8b 34 9d 54 87 10 c0 	mov    -0x3fef78ac(,%ebx,4),%esi
c0106f60:	85 f6                	test   %esi,%esi
c0106f62:	75 23                	jne    c0106f87 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c0106f64:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106f68:	c7 44 24 08 81 87 10 	movl   $0xc0108781,0x8(%esp)
c0106f6f:	c0 
c0106f70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f77:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f7a:	89 04 24             	mov    %eax,(%esp)
c0106f7d:	e8 61 fe ff ff       	call   c0106de3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106f82:	e9 60 02 00 00       	jmp    c01071e7 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c0106f87:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106f8b:	c7 44 24 08 8a 87 10 	movl   $0xc010878a,0x8(%esp)
c0106f92:	c0 
c0106f93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f9d:	89 04 24             	mov    %eax,(%esp)
c0106fa0:	e8 3e fe ff ff       	call   c0106de3 <printfmt>
            break;
c0106fa5:	e9 3d 02 00 00       	jmp    c01071e7 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106faa:	8b 45 14             	mov    0x14(%ebp),%eax
c0106fad:	8d 50 04             	lea    0x4(%eax),%edx
c0106fb0:	89 55 14             	mov    %edx,0x14(%ebp)
c0106fb3:	8b 30                	mov    (%eax),%esi
c0106fb5:	85 f6                	test   %esi,%esi
c0106fb7:	75 05                	jne    c0106fbe <vprintfmt+0x1a8>
                p = "(null)";
c0106fb9:	be 8d 87 10 c0       	mov    $0xc010878d,%esi
            }
            if (width > 0 && padc != '-') {
c0106fbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106fc2:	7e 76                	jle    c010703a <vprintfmt+0x224>
c0106fc4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106fc8:	74 70                	je     c010703a <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fd1:	89 34 24             	mov    %esi,(%esp)
c0106fd4:	e8 ba f7 ff ff       	call   c0106793 <strnlen>
c0106fd9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106fdc:	29 c2                	sub    %eax,%edx
c0106fde:	89 d0                	mov    %edx,%eax
c0106fe0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106fe3:	eb 16                	jmp    c0106ffb <vprintfmt+0x1e5>
                    putch(padc, putdat);
c0106fe5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106fec:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ff0:	89 04 24             	mov    %eax,(%esp)
c0106ff3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ff6:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106ff8:	ff 4d e8             	decl   -0x18(%ebp)
c0106ffb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106fff:	7f e4                	jg     c0106fe5 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0107001:	eb 37                	jmp    c010703a <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c0107003:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107007:	74 1f                	je     c0107028 <vprintfmt+0x212>
c0107009:	83 fb 1f             	cmp    $0x1f,%ebx
c010700c:	7e 05                	jle    c0107013 <vprintfmt+0x1fd>
c010700e:	83 fb 7e             	cmp    $0x7e,%ebx
c0107011:	7e 15                	jle    c0107028 <vprintfmt+0x212>
                    putch('?', putdat);
c0107013:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107016:	89 44 24 04          	mov    %eax,0x4(%esp)
c010701a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0107021:	8b 45 08             	mov    0x8(%ebp),%eax
c0107024:	ff d0                	call   *%eax
c0107026:	eb 0f                	jmp    c0107037 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c0107028:	8b 45 0c             	mov    0xc(%ebp),%eax
c010702b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010702f:	89 1c 24             	mov    %ebx,(%esp)
c0107032:	8b 45 08             	mov    0x8(%ebp),%eax
c0107035:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0107037:	ff 4d e8             	decl   -0x18(%ebp)
c010703a:	89 f0                	mov    %esi,%eax
c010703c:	8d 70 01             	lea    0x1(%eax),%esi
c010703f:	0f b6 00             	movzbl (%eax),%eax
c0107042:	0f be d8             	movsbl %al,%ebx
c0107045:	85 db                	test   %ebx,%ebx
c0107047:	74 27                	je     c0107070 <vprintfmt+0x25a>
c0107049:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010704d:	78 b4                	js     c0107003 <vprintfmt+0x1ed>
c010704f:	ff 4d e4             	decl   -0x1c(%ebp)
c0107052:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107056:	79 ab                	jns    c0107003 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c0107058:	eb 16                	jmp    c0107070 <vprintfmt+0x25a>
                putch(' ', putdat);
c010705a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010705d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107061:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0107068:	8b 45 08             	mov    0x8(%ebp),%eax
c010706b:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010706d:	ff 4d e8             	decl   -0x18(%ebp)
c0107070:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107074:	7f e4                	jg     c010705a <vprintfmt+0x244>
            }
            break;
c0107076:	e9 6c 01 00 00       	jmp    c01071e7 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010707b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010707e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107082:	8d 45 14             	lea    0x14(%ebp),%eax
c0107085:	89 04 24             	mov    %eax,(%esp)
c0107088:	e8 0b fd ff ff       	call   c0106d98 <getint>
c010708d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107090:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0107093:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107096:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107099:	85 d2                	test   %edx,%edx
c010709b:	79 26                	jns    c01070c3 <vprintfmt+0x2ad>
                putch('-', putdat);
c010709d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070a4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01070ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01070ae:	ff d0                	call   *%eax
                num = -(long long)num;
c01070b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01070b6:	f7 d8                	neg    %eax
c01070b8:	83 d2 00             	adc    $0x0,%edx
c01070bb:	f7 da                	neg    %edx
c01070bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01070c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01070c3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01070ca:	e9 a8 00 00 00       	jmp    c0107177 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01070cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01070d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070d6:	8d 45 14             	lea    0x14(%ebp),%eax
c01070d9:	89 04 24             	mov    %eax,(%esp)
c01070dc:	e8 64 fc ff ff       	call   c0106d45 <getuint>
c01070e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01070e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01070e7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01070ee:	e9 84 00 00 00       	jmp    c0107177 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01070f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01070f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070fa:	8d 45 14             	lea    0x14(%ebp),%eax
c01070fd:	89 04 24             	mov    %eax,(%esp)
c0107100:	e8 40 fc ff ff       	call   c0106d45 <getuint>
c0107105:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107108:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010710b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0107112:	eb 63                	jmp    c0107177 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c0107114:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010711b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0107122:	8b 45 08             	mov    0x8(%ebp),%eax
c0107125:	ff d0                	call   *%eax
            putch('x', putdat);
c0107127:	8b 45 0c             	mov    0xc(%ebp),%eax
c010712a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010712e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0107135:	8b 45 08             	mov    0x8(%ebp),%eax
c0107138:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010713a:	8b 45 14             	mov    0x14(%ebp),%eax
c010713d:	8d 50 04             	lea    0x4(%eax),%edx
c0107140:	89 55 14             	mov    %edx,0x14(%ebp)
c0107143:	8b 00                	mov    (%eax),%eax
c0107145:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107148:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010714f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0107156:	eb 1f                	jmp    c0107177 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0107158:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010715b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010715f:	8d 45 14             	lea    0x14(%ebp),%eax
c0107162:	89 04 24             	mov    %eax,(%esp)
c0107165:	e8 db fb ff ff       	call   c0106d45 <getuint>
c010716a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010716d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0107170:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0107177:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010717b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010717e:	89 54 24 18          	mov    %edx,0x18(%esp)
c0107182:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107185:	89 54 24 14          	mov    %edx,0x14(%esp)
c0107189:	89 44 24 10          	mov    %eax,0x10(%esp)
c010718d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107190:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107193:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107197:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010719b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010719e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01071a5:	89 04 24             	mov    %eax,(%esp)
c01071a8:	e8 94 fa ff ff       	call   c0106c41 <printnum>
            break;
c01071ad:	eb 38                	jmp    c01071e7 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01071af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071b6:	89 1c 24             	mov    %ebx,(%esp)
c01071b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01071bc:	ff d0                	call   *%eax
            break;
c01071be:	eb 27                	jmp    c01071e7 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01071c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071c7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01071ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01071d1:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01071d3:	ff 4d 10             	decl   0x10(%ebp)
c01071d6:	eb 03                	jmp    c01071db <vprintfmt+0x3c5>
c01071d8:	ff 4d 10             	decl   0x10(%ebp)
c01071db:	8b 45 10             	mov    0x10(%ebp),%eax
c01071de:	48                   	dec    %eax
c01071df:	0f b6 00             	movzbl (%eax),%eax
c01071e2:	3c 25                	cmp    $0x25,%al
c01071e4:	75 f2                	jne    c01071d8 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c01071e6:	90                   	nop
    while (1) {
c01071e7:	e9 36 fc ff ff       	jmp    c0106e22 <vprintfmt+0xc>
                return;
c01071ec:	90                   	nop
        }
    }
}
c01071ed:	83 c4 40             	add    $0x40,%esp
c01071f0:	5b                   	pop    %ebx
c01071f1:	5e                   	pop    %esi
c01071f2:	5d                   	pop    %ebp
c01071f3:	c3                   	ret    

c01071f4 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01071f4:	f3 0f 1e fb          	endbr32 
c01071f8:	55                   	push   %ebp
c01071f9:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01071fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071fe:	8b 40 08             	mov    0x8(%eax),%eax
c0107201:	8d 50 01             	lea    0x1(%eax),%edx
c0107204:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107207:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010720a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010720d:	8b 10                	mov    (%eax),%edx
c010720f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107212:	8b 40 04             	mov    0x4(%eax),%eax
c0107215:	39 c2                	cmp    %eax,%edx
c0107217:	73 12                	jae    c010722b <sprintputch+0x37>
        *b->buf ++ = ch;
c0107219:	8b 45 0c             	mov    0xc(%ebp),%eax
c010721c:	8b 00                	mov    (%eax),%eax
c010721e:	8d 48 01             	lea    0x1(%eax),%ecx
c0107221:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107224:	89 0a                	mov    %ecx,(%edx)
c0107226:	8b 55 08             	mov    0x8(%ebp),%edx
c0107229:	88 10                	mov    %dl,(%eax)
    }
}
c010722b:	90                   	nop
c010722c:	5d                   	pop    %ebp
c010722d:	c3                   	ret    

c010722e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010722e:	f3 0f 1e fb          	endbr32 
c0107232:	55                   	push   %ebp
c0107233:	89 e5                	mov    %esp,%ebp
c0107235:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0107238:	8d 45 14             	lea    0x14(%ebp),%eax
c010723b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010723e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107241:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107245:	8b 45 10             	mov    0x10(%ebp),%eax
c0107248:	89 44 24 08          	mov    %eax,0x8(%esp)
c010724c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010724f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107253:	8b 45 08             	mov    0x8(%ebp),%eax
c0107256:	89 04 24             	mov    %eax,(%esp)
c0107259:	e8 08 00 00 00       	call   c0107266 <vsnprintf>
c010725e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0107261:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107264:	c9                   	leave  
c0107265:	c3                   	ret    

c0107266 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0107266:	f3 0f 1e fb          	endbr32 
c010726a:	55                   	push   %ebp
c010726b:	89 e5                	mov    %esp,%ebp
c010726d:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0107270:	8b 45 08             	mov    0x8(%ebp),%eax
c0107273:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107276:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107279:	8d 50 ff             	lea    -0x1(%eax),%edx
c010727c:	8b 45 08             	mov    0x8(%ebp),%eax
c010727f:	01 d0                	add    %edx,%eax
c0107281:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107284:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010728b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010728f:	74 0a                	je     c010729b <vsnprintf+0x35>
c0107291:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107297:	39 c2                	cmp    %eax,%edx
c0107299:	76 07                	jbe    c01072a2 <vsnprintf+0x3c>
        return -E_INVAL;
c010729b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01072a0:	eb 2a                	jmp    c01072cc <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01072a2:	8b 45 14             	mov    0x14(%ebp),%eax
c01072a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01072a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01072ac:	89 44 24 08          	mov    %eax,0x8(%esp)
c01072b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01072b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01072b7:	c7 04 24 f4 71 10 c0 	movl   $0xc01071f4,(%esp)
c01072be:	e8 53 fb ff ff       	call   c0106e16 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01072c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072c6:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01072c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01072cc:	c9                   	leave  
c01072cd:	c3                   	ret    
