
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);
static void lab1_print_cur_status(void);
int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	b8 68 0d 11 00       	mov    $0x110d68,%eax
  10000b:	2d 16 fa 10 00       	sub    $0x10fa16,%eax
  100010:	89 44 24 08          	mov    %eax,0x8(%esp)
  100014:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001b:	00 
  10001c:	c7 04 24 16 fa 10 00 	movl   $0x10fa16,(%esp)
  100023:	e8 a5 36 00 00       	call   1036cd <memset>

    cons_init();                // init the console
  100028:	e8 ea 15 00 00       	call   101617 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002d:	c7 45 f0 60 38 10 00 	movl   $0x103860,-0x10(%ebp)
    cprintf("%s\n\n", message);
  100034:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100037:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003b:	c7 04 24 7c 38 10 00 	movl   $0x10387c,(%esp)
  100042:	e8 1e 03 00 00       	call   100365 <cprintf>

    print_kerninfo();
  100047:	e8 3c 08 00 00       	call   100888 <print_kerninfo>

    grade_backtrace();
  10004c:	e8 ca 00 00 00       	call   10011b <grade_backtrace>

    pmm_init();                 // init physical memory management
  100051:	e8 ce 2c 00 00       	call   102d24 <pmm_init>

    pic_init();                 // init interrupt controller
  100056:	e8 17 17 00 00       	call   101772 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005b:	e8 9e 18 00 00       	call   1018fe <idt_init>

    clock_init();               // init clock interrupt
  100060:	e8 53 0d 00 00       	call   100db8 <clock_init>
    intr_enable();              // enable irq interrupt
  100065:	e8 66 16 00 00       	call   1016d0 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006a:	e8 ab 01 00 00       	call   10021a <lab1_switch_test>

    /* do nothing */
    	long cnt = 0;
  10006f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
	if ((++cnt) % 10000000 == 0)
  100076:	ff 45 f4             	incl   -0xc(%ebp)
  100079:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  10007c:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
  100081:	89 c8                	mov    %ecx,%eax
  100083:	f7 ea                	imul   %edx
  100085:	89 d0                	mov    %edx,%eax
  100087:	c1 f8 16             	sar    $0x16,%eax
  10008a:	89 ca                	mov    %ecx,%edx
  10008c:	c1 fa 1f             	sar    $0x1f,%edx
  10008f:	29 d0                	sub    %edx,%eax
  100091:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
  100097:	89 c8                	mov    %ecx,%eax
  100099:	29 d0                	sub    %edx,%eax
  10009b:	85 c0                	test   %eax,%eax
  10009d:	75 d7                	jne    100076 <kern_init+0x76>
	    lab1_print_cur_status();
  10009f:	e8 9f 00 00 00       	call   100143 <lab1_print_cur_status>
	if ((++cnt) % 10000000 == 0)
  1000a4:	eb d0                	jmp    100076 <kern_init+0x76>

001000a6 <grade_backtrace2>:
	}
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 0b 0c 00 00       	call   100cd3 <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	89 ec                	mov    %ebp,%esp
  1000cb:	5d                   	pop    %ebp
  1000cc:	c3                   	ret    

001000cd <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cd:	55                   	push   %ebp
  1000ce:	89 e5                	mov    %esp,%ebp
  1000d0:	83 ec 18             	sub    $0x18,%esp
  1000d3:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d6:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000dc:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000df:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ee:	89 04 24             	mov    %eax,(%esp)
  1000f1:	e8 b0 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f6:	90                   	nop
  1000f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000fa:	89 ec                	mov    %ebp,%esp
  1000fc:	5d                   	pop    %ebp
  1000fd:	c3                   	ret    

001000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100104:	8b 45 10             	mov    0x10(%ebp),%eax
  100107:	89 44 24 04          	mov    %eax,0x4(%esp)
  10010b:	8b 45 08             	mov    0x8(%ebp),%eax
  10010e:	89 04 24             	mov    %eax,(%esp)
  100111:	e8 b7 ff ff ff       	call   1000cd <grade_backtrace1>
}
  100116:	90                   	nop
  100117:	89 ec                	mov    %ebp,%esp
  100119:	5d                   	pop    %ebp
  10011a:	c3                   	ret    

0010011b <grade_backtrace>:

void
grade_backtrace(void) {
  10011b:	55                   	push   %ebp
  10011c:	89 e5                	mov    %esp,%ebp
  10011e:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100121:	b8 00 00 10 00       	mov    $0x100000,%eax
  100126:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10012d:	ff 
  10012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100139:	e8 c0 ff ff ff       	call   1000fe <grade_backtrace0>
}
  10013e:	90                   	nop
  10013f:	89 ec                	mov    %ebp,%esp
  100141:	5d                   	pop    %ebp
  100142:	c3                   	ret    

00100143 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100143:	55                   	push   %ebp
  100144:	89 e5                	mov    %esp,%ebp
  100146:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100149:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10014c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014f:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100152:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100155:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100159:	83 e0 03             	and    $0x3,%eax
  10015c:	89 c2                	mov    %eax,%edx
  10015e:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100163:	89 54 24 08          	mov    %edx,0x8(%esp)
  100167:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016b:	c7 04 24 81 38 10 00 	movl   $0x103881,(%esp)
  100172:	e8 ee 01 00 00       	call   100365 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100177:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10017b:	89 c2                	mov    %eax,%edx
  10017d:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100182:	89 54 24 08          	mov    %edx,0x8(%esp)
  100186:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018a:	c7 04 24 8f 38 10 00 	movl   $0x10388f,(%esp)
  100191:	e8 cf 01 00 00       	call   100365 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100196:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10019a:	89 c2                	mov    %eax,%edx
  10019c:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001a1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a9:	c7 04 24 9d 38 10 00 	movl   $0x10389d,(%esp)
  1001b0:	e8 b0 01 00 00       	call   100365 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b9:	89 c2                	mov    %eax,%edx
  1001bb:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c8:	c7 04 24 ab 38 10 00 	movl   $0x1038ab,(%esp)
  1001cf:	e8 91 01 00 00       	call   100365 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d8:	89 c2                	mov    %eax,%edx
  1001da:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001df:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e7:	c7 04 24 b9 38 10 00 	movl   $0x1038b9,(%esp)
  1001ee:	e8 72 01 00 00       	call   100365 <cprintf>
    round ++;
  1001f3:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001f8:	40                   	inc    %eax
  1001f9:	a3 20 fa 10 00       	mov    %eax,0x10fa20
}
  1001fe:	90                   	nop
  1001ff:	89 ec                	mov    %ebp,%esp
  100201:	5d                   	pop    %ebp
  100202:	c3                   	ret    

00100203 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100203:	55                   	push   %ebp
  100204:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	__asm__ __volatile__ (
  100206:	83 ec 08             	sub    $0x8,%esp
  100209:	cd 78                	int    $0x78
  10020b:	89 ec                	mov    %ebp,%esp
		"int %0 \n"
        "movl %%ebp, %%esp\n"
		:
		:"i" (T_SWITCH_TOU)
	);
}
  10020d:	90                   	nop
  10020e:	5d                   	pop    %ebp
  10020f:	c3                   	ret    

00100210 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100210:	55                   	push   %ebp
  100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
  100213:	cd 79                	int    $0x79
  100215:	89 ec                	mov    %ebp,%esp
    	"int %0 \n"
    	"movl %%ebp,%%esp \n" 
    	:
    	:"i"(T_SWITCH_TOK)
    );
}
  100217:	90                   	nop
  100218:	5d                   	pop    %ebp
  100219:	c3                   	ret    

0010021a <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10021a:	55                   	push   %ebp
  10021b:	89 e5                	mov    %esp,%ebp
  10021d:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100220:	e8 1e ff ff ff       	call   100143 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100225:	c7 04 24 c8 38 10 00 	movl   $0x1038c8,(%esp)
  10022c:	e8 34 01 00 00       	call   100365 <cprintf>
    lab1_switch_to_user();
  100231:	e8 cd ff ff ff       	call   100203 <lab1_switch_to_user>
    lab1_print_cur_status();
  100236:	e8 08 ff ff ff       	call   100143 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10023b:	c7 04 24 e8 38 10 00 	movl   $0x1038e8,(%esp)
  100242:	e8 1e 01 00 00       	call   100365 <cprintf>
    lab1_switch_to_kernel();
  100247:	e8 c4 ff ff ff       	call   100210 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10024c:	e8 f2 fe ff ff       	call   100143 <lab1_print_cur_status>
}
  100251:	90                   	nop
  100252:	89 ec                	mov    %ebp,%esp
  100254:	5d                   	pop    %ebp
  100255:	c3                   	ret    

00100256 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100256:	55                   	push   %ebp
  100257:	89 e5                	mov    %esp,%ebp
  100259:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10025c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100260:	74 13                	je     100275 <readline+0x1f>
        cprintf("%s", prompt);
  100262:	8b 45 08             	mov    0x8(%ebp),%eax
  100265:	89 44 24 04          	mov    %eax,0x4(%esp)
  100269:	c7 04 24 07 39 10 00 	movl   $0x103907,(%esp)
  100270:	e8 f0 00 00 00       	call   100365 <cprintf>
    }
    int i = 0, c;
  100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10027c:	e8 73 01 00 00       	call   1003f4 <getchar>
  100281:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100284:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100288:	79 07                	jns    100291 <readline+0x3b>
            return NULL;
  10028a:	b8 00 00 00 00       	mov    $0x0,%eax
  10028f:	eb 78                	jmp    100309 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100291:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100295:	7e 28                	jle    1002bf <readline+0x69>
  100297:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10029e:	7f 1f                	jg     1002bf <readline+0x69>
            cputchar(c);
  1002a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a3:	89 04 24             	mov    %eax,(%esp)
  1002a6:	e8 e2 00 00 00       	call   10038d <cputchar>
            buf[i ++] = c;
  1002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002ae:	8d 50 01             	lea    0x1(%eax),%edx
  1002b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002b7:	88 90 40 fa 10 00    	mov    %dl,0x10fa40(%eax)
  1002bd:	eb 45                	jmp    100304 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002bf:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002c3:	75 16                	jne    1002db <readline+0x85>
  1002c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002c9:	7e 10                	jle    1002db <readline+0x85>
            cputchar(c);
  1002cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ce:	89 04 24             	mov    %eax,(%esp)
  1002d1:	e8 b7 00 00 00       	call   10038d <cputchar>
            i --;
  1002d6:	ff 4d f4             	decl   -0xc(%ebp)
  1002d9:	eb 29                	jmp    100304 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002db:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002df:	74 06                	je     1002e7 <readline+0x91>
  1002e1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002e5:	75 95                	jne    10027c <readline+0x26>
            cputchar(c);
  1002e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ea:	89 04 24             	mov    %eax,(%esp)
  1002ed:	e8 9b 00 00 00       	call   10038d <cputchar>
            buf[i] = '\0';
  1002f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002f5:	05 40 fa 10 00       	add    $0x10fa40,%eax
  1002fa:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002fd:	b8 40 fa 10 00       	mov    $0x10fa40,%eax
  100302:	eb 05                	jmp    100309 <readline+0xb3>
        c = getchar();
  100304:	e9 73 ff ff ff       	jmp    10027c <readline+0x26>
        }
    }
}
  100309:	89 ec                	mov    %ebp,%esp
  10030b:	5d                   	pop    %ebp
  10030c:	c3                   	ret    

0010030d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10030d:	55                   	push   %ebp
  10030e:	89 e5                	mov    %esp,%ebp
  100310:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100313:	8b 45 08             	mov    0x8(%ebp),%eax
  100316:	89 04 24             	mov    %eax,(%esp)
  100319:	e8 28 13 00 00       	call   101646 <cons_putc>
    (*cnt) ++;
  10031e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100321:	8b 00                	mov    (%eax),%eax
  100323:	8d 50 01             	lea    0x1(%eax),%edx
  100326:	8b 45 0c             	mov    0xc(%ebp),%eax
  100329:	89 10                	mov    %edx,(%eax)
}
  10032b:	90                   	nop
  10032c:	89 ec                	mov    %ebp,%esp
  10032e:	5d                   	pop    %ebp
  10032f:	c3                   	ret    

00100330 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100330:	55                   	push   %ebp
  100331:	89 e5                	mov    %esp,%ebp
  100333:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10033d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100344:	8b 45 08             	mov    0x8(%ebp),%eax
  100347:	89 44 24 08          	mov    %eax,0x8(%esp)
  10034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10034e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100352:	c7 04 24 0d 03 10 00 	movl   $0x10030d,(%esp)
  100359:	e8 9a 2b 00 00       	call   102ef8 <vprintfmt>
    return cnt;
  10035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100361:	89 ec                	mov    %ebp,%esp
  100363:	5d                   	pop    %ebp
  100364:	c3                   	ret    

00100365 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100365:	55                   	push   %ebp
  100366:	89 e5                	mov    %esp,%ebp
  100368:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10036b:	8d 45 0c             	lea    0xc(%ebp),%eax
  10036e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100374:	89 44 24 04          	mov    %eax,0x4(%esp)
  100378:	8b 45 08             	mov    0x8(%ebp),%eax
  10037b:	89 04 24             	mov    %eax,(%esp)
  10037e:	e8 ad ff ff ff       	call   100330 <vcprintf>
  100383:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100389:	89 ec                	mov    %ebp,%esp
  10038b:	5d                   	pop    %ebp
  10038c:	c3                   	ret    

0010038d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10038d:	55                   	push   %ebp
  10038e:	89 e5                	mov    %esp,%ebp
  100390:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100393:	8b 45 08             	mov    0x8(%ebp),%eax
  100396:	89 04 24             	mov    %eax,(%esp)
  100399:	e8 a8 12 00 00       	call   101646 <cons_putc>
}
  10039e:	90                   	nop
  10039f:	89 ec                	mov    %ebp,%esp
  1003a1:	5d                   	pop    %ebp
  1003a2:	c3                   	ret    

001003a3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1003a3:	55                   	push   %ebp
  1003a4:	89 e5                	mov    %esp,%ebp
  1003a6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1003a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003b0:	eb 13                	jmp    1003c5 <cputs+0x22>
        cputch(c, &cnt);
  1003b2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003b6:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003bd:	89 04 24             	mov    %eax,(%esp)
  1003c0:	e8 48 ff ff ff       	call   10030d <cputch>
    while ((c = *str ++) != '\0') {
  1003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1003c8:	8d 50 01             	lea    0x1(%eax),%edx
  1003cb:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ce:	0f b6 00             	movzbl (%eax),%eax
  1003d1:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003d4:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003d8:	75 d8                	jne    1003b2 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003e1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003e8:	e8 20 ff ff ff       	call   10030d <cputch>
    return cnt;
  1003ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003f0:	89 ec                	mov    %ebp,%esp
  1003f2:	5d                   	pop    %ebp
  1003f3:	c3                   	ret    

001003f4 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003f4:	55                   	push   %ebp
  1003f5:	89 e5                	mov    %esp,%ebp
  1003f7:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003fa:	90                   	nop
  1003fb:	e8 72 12 00 00       	call   101672 <cons_getc>
  100400:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100407:	74 f2                	je     1003fb <getchar+0x7>
        /* do nothing */;
    return c;
  100409:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10040c:	89 ec                	mov    %ebp,%esp
  10040e:	5d                   	pop    %ebp
  10040f:	c3                   	ret    

00100410 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100410:	55                   	push   %ebp
  100411:	89 e5                	mov    %esp,%ebp
  100413:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100416:	8b 45 0c             	mov    0xc(%ebp),%eax
  100419:	8b 00                	mov    (%eax),%eax
  10041b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10041e:	8b 45 10             	mov    0x10(%ebp),%eax
  100421:	8b 00                	mov    (%eax),%eax
  100423:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100426:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10042d:	e9 ca 00 00 00       	jmp    1004fc <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100432:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100435:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100438:	01 d0                	add    %edx,%eax
  10043a:	89 c2                	mov    %eax,%edx
  10043c:	c1 ea 1f             	shr    $0x1f,%edx
  10043f:	01 d0                	add    %edx,%eax
  100441:	d1 f8                	sar    %eax
  100443:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100446:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100449:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10044c:	eb 03                	jmp    100451 <stab_binsearch+0x41>
            m --;
  10044e:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100451:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100454:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100457:	7c 1f                	jl     100478 <stab_binsearch+0x68>
  100459:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10045c:	89 d0                	mov    %edx,%eax
  10045e:	01 c0                	add    %eax,%eax
  100460:	01 d0                	add    %edx,%eax
  100462:	c1 e0 02             	shl    $0x2,%eax
  100465:	89 c2                	mov    %eax,%edx
  100467:	8b 45 08             	mov    0x8(%ebp),%eax
  10046a:	01 d0                	add    %edx,%eax
  10046c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100470:	0f b6 c0             	movzbl %al,%eax
  100473:	39 45 14             	cmp    %eax,0x14(%ebp)
  100476:	75 d6                	jne    10044e <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100478:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10047b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10047e:	7d 09                	jge    100489 <stab_binsearch+0x79>
            l = true_m + 1;
  100480:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100483:	40                   	inc    %eax
  100484:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100487:	eb 73                	jmp    1004fc <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100489:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100490:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100493:	89 d0                	mov    %edx,%eax
  100495:	01 c0                	add    %eax,%eax
  100497:	01 d0                	add    %edx,%eax
  100499:	c1 e0 02             	shl    $0x2,%eax
  10049c:	89 c2                	mov    %eax,%edx
  10049e:	8b 45 08             	mov    0x8(%ebp),%eax
  1004a1:	01 d0                	add    %edx,%eax
  1004a3:	8b 40 08             	mov    0x8(%eax),%eax
  1004a6:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004a9:	76 11                	jbe    1004bc <stab_binsearch+0xac>
            *region_left = m;
  1004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b1:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004b6:	40                   	inc    %eax
  1004b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ba:	eb 40                	jmp    1004fc <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004bf:	89 d0                	mov    %edx,%eax
  1004c1:	01 c0                	add    %eax,%eax
  1004c3:	01 d0                	add    %edx,%eax
  1004c5:	c1 e0 02             	shl    $0x2,%eax
  1004c8:	89 c2                	mov    %eax,%edx
  1004ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1004cd:	01 d0                	add    %edx,%eax
  1004cf:	8b 40 08             	mov    0x8(%eax),%eax
  1004d2:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004d5:	73 14                	jae    1004eb <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004da:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004dd:	8b 45 10             	mov    0x10(%ebp),%eax
  1004e0:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e5:	48                   	dec    %eax
  1004e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004e9:	eb 11                	jmp    1004fc <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004f1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004f9:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100502:	0f 8e 2a ff ff ff    	jle    100432 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  100508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10050c:	75 0f                	jne    10051d <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  10050e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	8d 50 ff             	lea    -0x1(%eax),%edx
  100516:	8b 45 10             	mov    0x10(%ebp),%eax
  100519:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10051b:	eb 3e                	jmp    10055b <stab_binsearch+0x14b>
        l = *region_right;
  10051d:	8b 45 10             	mov    0x10(%ebp),%eax
  100520:	8b 00                	mov    (%eax),%eax
  100522:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100525:	eb 03                	jmp    10052a <stab_binsearch+0x11a>
  100527:	ff 4d fc             	decl   -0x4(%ebp)
  10052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052d:	8b 00                	mov    (%eax),%eax
  10052f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100532:	7e 1f                	jle    100553 <stab_binsearch+0x143>
  100534:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100537:	89 d0                	mov    %edx,%eax
  100539:	01 c0                	add    %eax,%eax
  10053b:	01 d0                	add    %edx,%eax
  10053d:	c1 e0 02             	shl    $0x2,%eax
  100540:	89 c2                	mov    %eax,%edx
  100542:	8b 45 08             	mov    0x8(%ebp),%eax
  100545:	01 d0                	add    %edx,%eax
  100547:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10054b:	0f b6 c0             	movzbl %al,%eax
  10054e:	39 45 14             	cmp    %eax,0x14(%ebp)
  100551:	75 d4                	jne    100527 <stab_binsearch+0x117>
        *region_left = l;
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100559:	89 10                	mov    %edx,(%eax)
}
  10055b:	90                   	nop
  10055c:	89 ec                	mov    %ebp,%esp
  10055e:	5d                   	pop    %ebp
  10055f:	c3                   	ret    

00100560 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100560:	55                   	push   %ebp
  100561:	89 e5                	mov    %esp,%ebp
  100563:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100566:	8b 45 0c             	mov    0xc(%ebp),%eax
  100569:	c7 00 0c 39 10 00    	movl   $0x10390c,(%eax)
    info->eip_line = 0;
  10056f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100572:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100579:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057c:	c7 40 08 0c 39 10 00 	movl   $0x10390c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100583:	8b 45 0c             	mov    0xc(%ebp),%eax
  100586:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100590:	8b 55 08             	mov    0x8(%ebp),%edx
  100593:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100596:	8b 45 0c             	mov    0xc(%ebp),%eax
  100599:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  1005a0:	c7 45 f4 ac 41 10 00 	movl   $0x1041ac,-0xc(%ebp)
    stab_end = __STAB_END__;
  1005a7:	c7 45 f0 c4 c2 10 00 	movl   $0x10c2c4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  1005ae:	c7 45 ec c5 c2 10 00 	movl   $0x10c2c5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005b5:	c7 45 e8 b2 ec 10 00 	movl   $0x10ecb2,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005c2:	76 0b                	jbe    1005cf <debuginfo_eip+0x6f>
  1005c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005c7:	48                   	dec    %eax
  1005c8:	0f b6 00             	movzbl (%eax),%eax
  1005cb:	84 c0                	test   %al,%al
  1005cd:	74 0a                	je     1005d9 <debuginfo_eip+0x79>
        return -1;
  1005cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005d4:	e9 ab 02 00 00       	jmp    100884 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005e6:	c1 f8 02             	sar    $0x2,%eax
  1005e9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005ef:	48                   	dec    %eax
  1005f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005fa:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100601:	00 
  100602:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100605:	89 44 24 08          	mov    %eax,0x8(%esp)
  100609:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100613:	89 04 24             	mov    %eax,(%esp)
  100616:	e8 f5 fd ff ff       	call   100410 <stab_binsearch>
    if (lfile == 0)
  10061b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10061e:	85 c0                	test   %eax,%eax
  100620:	75 0a                	jne    10062c <debuginfo_eip+0xcc>
        return -1;
  100622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100627:	e9 58 02 00 00       	jmp    100884 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10062f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100632:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100635:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100638:	8b 45 08             	mov    0x8(%ebp),%eax
  10063b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10063f:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100646:	00 
  100647:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10064a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10064e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100651:	89 44 24 04          	mov    %eax,0x4(%esp)
  100655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100658:	89 04 24             	mov    %eax,(%esp)
  10065b:	e8 b0 fd ff ff       	call   100410 <stab_binsearch>

    if (lfun <= rfun) {
  100660:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100663:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100666:	39 c2                	cmp    %eax,%edx
  100668:	7f 78                	jg     1006e2 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10066a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10066d:	89 c2                	mov    %eax,%edx
  10066f:	89 d0                	mov    %edx,%eax
  100671:	01 c0                	add    %eax,%eax
  100673:	01 d0                	add    %edx,%eax
  100675:	c1 e0 02             	shl    $0x2,%eax
  100678:	89 c2                	mov    %eax,%edx
  10067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10067d:	01 d0                	add    %edx,%eax
  10067f:	8b 10                	mov    (%eax),%edx
  100681:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100684:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100687:	39 c2                	cmp    %eax,%edx
  100689:	73 22                	jae    1006ad <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10068b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10068e:	89 c2                	mov    %eax,%edx
  100690:	89 d0                	mov    %edx,%eax
  100692:	01 c0                	add    %eax,%eax
  100694:	01 d0                	add    %edx,%eax
  100696:	c1 e0 02             	shl    $0x2,%eax
  100699:	89 c2                	mov    %eax,%edx
  10069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10069e:	01 d0                	add    %edx,%eax
  1006a0:	8b 10                	mov    (%eax),%edx
  1006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1006a5:	01 c2                	add    %eax,%edx
  1006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006aa:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1006ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006b0:	89 c2                	mov    %eax,%edx
  1006b2:	89 d0                	mov    %edx,%eax
  1006b4:	01 c0                	add    %eax,%eax
  1006b6:	01 d0                	add    %edx,%eax
  1006b8:	c1 e0 02             	shl    $0x2,%eax
  1006bb:	89 c2                	mov    %eax,%edx
  1006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006c0:	01 d0                	add    %edx,%eax
  1006c2:	8b 50 08             	mov    0x8(%eax),%edx
  1006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c8:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006ce:	8b 40 10             	mov    0x10(%eax),%eax
  1006d1:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006e0:	eb 15                	jmp    1006f7 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  1006e8:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fa:	8b 40 08             	mov    0x8(%eax),%eax
  1006fd:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  100704:	00 
  100705:	89 04 24             	mov    %eax,(%esp)
  100708:	e8 38 2e 00 00       	call   103545 <strfind>
  10070d:	8b 55 0c             	mov    0xc(%ebp),%edx
  100710:	8b 4a 08             	mov    0x8(%edx),%ecx
  100713:	29 c8                	sub    %ecx,%eax
  100715:	89 c2                	mov    %eax,%edx
  100717:	8b 45 0c             	mov    0xc(%ebp),%eax
  10071a:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10071d:	8b 45 08             	mov    0x8(%ebp),%eax
  100720:	89 44 24 10          	mov    %eax,0x10(%esp)
  100724:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10072b:	00 
  10072c:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10072f:	89 44 24 08          	mov    %eax,0x8(%esp)
  100733:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100736:	89 44 24 04          	mov    %eax,0x4(%esp)
  10073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10073d:	89 04 24             	mov    %eax,(%esp)
  100740:	e8 cb fc ff ff       	call   100410 <stab_binsearch>
    if (lline <= rline) {
  100745:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100748:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10074b:	39 c2                	cmp    %eax,%edx
  10074d:	7f 23                	jg     100772 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  10074f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100752:	89 c2                	mov    %eax,%edx
  100754:	89 d0                	mov    %edx,%eax
  100756:	01 c0                	add    %eax,%eax
  100758:	01 d0                	add    %edx,%eax
  10075a:	c1 e0 02             	shl    $0x2,%eax
  10075d:	89 c2                	mov    %eax,%edx
  10075f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100762:	01 d0                	add    %edx,%eax
  100764:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100768:	89 c2                	mov    %eax,%edx
  10076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10076d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100770:	eb 11                	jmp    100783 <debuginfo_eip+0x223>
        return -1;
  100772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100777:	e9 08 01 00 00       	jmp    100884 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10077c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077f:	48                   	dec    %eax
  100780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100789:	39 c2                	cmp    %eax,%edx
  10078b:	7c 56                	jl     1007e3 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10078d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100790:	89 c2                	mov    %eax,%edx
  100792:	89 d0                	mov    %edx,%eax
  100794:	01 c0                	add    %eax,%eax
  100796:	01 d0                	add    %edx,%eax
  100798:	c1 e0 02             	shl    $0x2,%eax
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a0:	01 d0                	add    %edx,%eax
  1007a2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007a6:	3c 84                	cmp    $0x84,%al
  1007a8:	74 39                	je     1007e3 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ad:	89 c2                	mov    %eax,%edx
  1007af:	89 d0                	mov    %edx,%eax
  1007b1:	01 c0                	add    %eax,%eax
  1007b3:	01 d0                	add    %edx,%eax
  1007b5:	c1 e0 02             	shl    $0x2,%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007c3:	3c 64                	cmp    $0x64,%al
  1007c5:	75 b5                	jne    10077c <debuginfo_eip+0x21c>
  1007c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ca:	89 c2                	mov    %eax,%edx
  1007cc:	89 d0                	mov    %edx,%eax
  1007ce:	01 c0                	add    %eax,%eax
  1007d0:	01 d0                	add    %edx,%eax
  1007d2:	c1 e0 02             	shl    $0x2,%eax
  1007d5:	89 c2                	mov    %eax,%edx
  1007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007da:	01 d0                	add    %edx,%eax
  1007dc:	8b 40 08             	mov    0x8(%eax),%eax
  1007df:	85 c0                	test   %eax,%eax
  1007e1:	74 99                	je     10077c <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e9:	39 c2                	cmp    %eax,%edx
  1007eb:	7c 42                	jl     10082f <debuginfo_eip+0x2cf>
  1007ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007f0:	89 c2                	mov    %eax,%edx
  1007f2:	89 d0                	mov    %edx,%eax
  1007f4:	01 c0                	add    %eax,%eax
  1007f6:	01 d0                	add    %edx,%eax
  1007f8:	c1 e0 02             	shl    $0x2,%eax
  1007fb:	89 c2                	mov    %eax,%edx
  1007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100800:	01 d0                	add    %edx,%eax
  100802:	8b 10                	mov    (%eax),%edx
  100804:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100807:	2b 45 ec             	sub    -0x14(%ebp),%eax
  10080a:	39 c2                	cmp    %eax,%edx
  10080c:	73 21                	jae    10082f <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10080e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100811:	89 c2                	mov    %eax,%edx
  100813:	89 d0                	mov    %edx,%eax
  100815:	01 c0                	add    %eax,%eax
  100817:	01 d0                	add    %edx,%eax
  100819:	c1 e0 02             	shl    $0x2,%eax
  10081c:	89 c2                	mov    %eax,%edx
  10081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100821:	01 d0                	add    %edx,%eax
  100823:	8b 10                	mov    (%eax),%edx
  100825:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100828:	01 c2                	add    %eax,%edx
  10082a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082d:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  10082f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100832:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100835:	39 c2                	cmp    %eax,%edx
  100837:	7d 46                	jge    10087f <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  100839:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10083c:	40                   	inc    %eax
  10083d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100840:	eb 16                	jmp    100858 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100842:	8b 45 0c             	mov    0xc(%ebp),%eax
  100845:	8b 40 14             	mov    0x14(%eax),%eax
  100848:	8d 50 01             	lea    0x1(%eax),%edx
  10084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10084e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100854:	40                   	inc    %eax
  100855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100858:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10085b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10085e:	39 c2                	cmp    %eax,%edx
  100860:	7d 1d                	jge    10087f <debuginfo_eip+0x31f>
  100862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100865:	89 c2                	mov    %eax,%edx
  100867:	89 d0                	mov    %edx,%eax
  100869:	01 c0                	add    %eax,%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	c1 e0 02             	shl    $0x2,%eax
  100870:	89 c2                	mov    %eax,%edx
  100872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100875:	01 d0                	add    %edx,%eax
  100877:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10087b:	3c a0                	cmp    $0xa0,%al
  10087d:	74 c3                	je     100842 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  10087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100884:	89 ec                	mov    %ebp,%esp
  100886:	5d                   	pop    %ebp
  100887:	c3                   	ret    

00100888 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100888:	55                   	push   %ebp
  100889:	89 e5                	mov    %esp,%ebp
  10088b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10088e:	c7 04 24 16 39 10 00 	movl   $0x103916,(%esp)
  100895:	e8 cb fa ff ff       	call   100365 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10089a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  1008a1:	00 
  1008a2:	c7 04 24 2f 39 10 00 	movl   $0x10392f,(%esp)
  1008a9:	e8 b7 fa ff ff       	call   100365 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008ae:	c7 44 24 04 59 38 10 	movl   $0x103859,0x4(%esp)
  1008b5:	00 
  1008b6:	c7 04 24 47 39 10 00 	movl   $0x103947,(%esp)
  1008bd:	e8 a3 fa ff ff       	call   100365 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008c2:	c7 44 24 04 16 fa 10 	movl   $0x10fa16,0x4(%esp)
  1008c9:	00 
  1008ca:	c7 04 24 5f 39 10 00 	movl   $0x10395f,(%esp)
  1008d1:	e8 8f fa ff ff       	call   100365 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008d6:	c7 44 24 04 68 0d 11 	movl   $0x110d68,0x4(%esp)
  1008dd:	00 
  1008de:	c7 04 24 77 39 10 00 	movl   $0x103977,(%esp)
  1008e5:	e8 7b fa ff ff       	call   100365 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008ea:	b8 68 0d 11 00       	mov    $0x110d68,%eax
  1008ef:	2d 00 00 10 00       	sub    $0x100000,%eax
  1008f4:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008f9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008ff:	85 c0                	test   %eax,%eax
  100901:	0f 48 c2             	cmovs  %edx,%eax
  100904:	c1 f8 0a             	sar    $0xa,%eax
  100907:	89 44 24 04          	mov    %eax,0x4(%esp)
  10090b:	c7 04 24 90 39 10 00 	movl   $0x103990,(%esp)
  100912:	e8 4e fa ff ff       	call   100365 <cprintf>
}
  100917:	90                   	nop
  100918:	89 ec                	mov    %ebp,%esp
  10091a:	5d                   	pop    %ebp
  10091b:	c3                   	ret    

0010091c <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10091c:	55                   	push   %ebp
  10091d:	89 e5                	mov    %esp,%ebp
  10091f:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100925:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100928:	89 44 24 04          	mov    %eax,0x4(%esp)
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 04 24             	mov    %eax,(%esp)
  100932:	e8 29 fc ff ff       	call   100560 <debuginfo_eip>
  100937:	85 c0                	test   %eax,%eax
  100939:	74 15                	je     100950 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10093b:	8b 45 08             	mov    0x8(%ebp),%eax
  10093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100942:	c7 04 24 ba 39 10 00 	movl   $0x1039ba,(%esp)
  100949:	e8 17 fa ff ff       	call   100365 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10094e:	eb 6c                	jmp    1009bc <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100957:	eb 1b                	jmp    100974 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095f:	01 d0                	add    %edx,%eax
  100961:	0f b6 10             	movzbl (%eax),%edx
  100964:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10096d:	01 c8                	add    %ecx,%eax
  10096f:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100971:	ff 45 f4             	incl   -0xc(%ebp)
  100974:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100977:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10097a:	7c dd                	jl     100959 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10097c:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100985:	01 d0                	add    %edx,%eax
  100987:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10098a:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10098d:	8b 45 08             	mov    0x8(%ebp),%eax
  100990:	29 d0                	sub    %edx,%eax
  100992:	89 c1                	mov    %eax,%ecx
  100994:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100997:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10099a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10099e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1009a8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b0:	c7 04 24 d6 39 10 00 	movl   $0x1039d6,(%esp)
  1009b7:	e8 a9 f9 ff ff       	call   100365 <cprintf>
}
  1009bc:	90                   	nop
  1009bd:	89 ec                	mov    %ebp,%esp
  1009bf:	5d                   	pop    %ebp
  1009c0:	c3                   	ret    

001009c1 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009c1:	55                   	push   %ebp
  1009c2:	89 e5                	mov    %esp,%ebp
  1009c4:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009c7:	8b 45 04             	mov    0x4(%ebp),%eax
  1009ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009d0:	89 ec                	mov    %ebp,%esp
  1009d2:	5d                   	pop    %ebp
  1009d3:	c3                   	ret    

001009d4 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009d4:	55                   	push   %ebp
  1009d5:	89 e5                	mov    %esp,%ebp
  1009d7:	83 ec 48             	sub    $0x48,%esp
  1009da:	89 5d fc             	mov    %ebx,-0x4(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009dd:	89 e8                	mov    %ebp,%eax
  1009df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp=read_ebp();
  1009e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
  1009e8:	e8 d4 ff ff ff       	call   1009c1 <read_eip>
  1009ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;   //这里有个细节问题，就是不能for int i，这里面的C标准似乎不允许
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  1009f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009f7:	eb 7e                	jmp    100a77 <print_stackframe+0xa3>
	{
		cprintf("ebp:0x%08x eip:0x%08x\n",ebp,eip);
  1009f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a07:	c7 04 24 e8 39 10 00 	movl   $0x1039e8,(%esp)
  100a0e:	e8 52 f9 ff ff       	call   100365 <cprintf>
		uint32_t *args=(uint32_t *)ebp+2;
  100a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a16:	83 c0 08             	add    $0x8,%eax
  100a19:	89 45 e8             	mov    %eax,-0x18(%ebp)
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x\n",*(args+0),*(args+1),*(args+2),*(args+3));//依次打印调用函数的参数1 2 3 4
  100a1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1f:	83 c0 0c             	add    $0xc,%eax
  100a22:	8b 18                	mov    (%eax),%ebx
  100a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a27:	83 c0 08             	add    $0x8,%eax
  100a2a:	8b 08                	mov    (%eax),%ecx
  100a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2f:	83 c0 04             	add    $0x4,%eax
  100a32:	8b 10                	mov    (%eax),%edx
  100a34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a37:	8b 00                	mov    (%eax),%eax
  100a39:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a3d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a41:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a49:	c7 04 24 00 3a 10 00 	movl   $0x103a00,(%esp)
  100a50:	e8 10 f9 ff ff       	call   100365 <cprintf>
 
 
    //因为使用的是栈数据结构，因此可以直接根据ebp就能读取到各个栈帧的地址和值，ebp+4处为返回地址，
    //ebp+8处为第一个参数值（最后一个入栈的参数值，对应32位系统），ebp-4处为第一个局部变量，ebp处为上一层 ebp 值。

		print_debuginfo(eip-1);
  100a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a58:	48                   	dec    %eax
  100a59:	89 04 24             	mov    %eax,(%esp)
  100a5c:	e8 bb fe ff ff       	call   10091c <print_debuginfo>
		eip=((uint32_t *)ebp)[1];
  100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a64:	83 c0 04             	add    $0x4,%eax
  100a67:	8b 00                	mov    (%eax),%eax
  100a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
  100a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6f:	8b 00                	mov    (%eax),%eax
  100a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  100a74:	ff 45 ec             	incl   -0x14(%ebp)
  100a77:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a7b:	7f 0a                	jg     100a87 <print_stackframe+0xb3>
  100a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a81:	0f 85 72 ff ff ff    	jne    1009f9 <print_stackframe+0x25>
    }
}
  100a87:	90                   	nop
  100a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100a8b:	89 ec                	mov    %ebp,%esp
  100a8d:	5d                   	pop    %ebp
  100a8e:	c3                   	ret    

00100a8f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a8f:	55                   	push   %ebp
  100a90:	89 e5                	mov    %esp,%ebp
  100a92:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9c:	eb 0c                	jmp    100aaa <parse+0x1b>
            *buf ++ = '\0';
  100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa1:	8d 50 01             	lea    0x1(%eax),%edx
  100aa4:	89 55 08             	mov    %edx,0x8(%ebp)
  100aa7:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  100aad:	0f b6 00             	movzbl (%eax),%eax
  100ab0:	84 c0                	test   %al,%al
  100ab2:	74 1d                	je     100ad1 <parse+0x42>
  100ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab7:	0f b6 00             	movzbl (%eax),%eax
  100aba:	0f be c0             	movsbl %al,%eax
  100abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac1:	c7 04 24 a4 3a 10 00 	movl   $0x103aa4,(%esp)
  100ac8:	e8 44 2a 00 00       	call   103511 <strchr>
  100acd:	85 c0                	test   %eax,%eax
  100acf:	75 cd                	jne    100a9e <parse+0xf>
        }
        if (*buf == '\0') {
  100ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  100ad4:	0f b6 00             	movzbl (%eax),%eax
  100ad7:	84 c0                	test   %al,%al
  100ad9:	74 65                	je     100b40 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100adb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100adf:	75 14                	jne    100af5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ae1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ae8:	00 
  100ae9:	c7 04 24 a9 3a 10 00 	movl   $0x103aa9,(%esp)
  100af0:	e8 70 f8 ff ff       	call   100365 <cprintf>
        }
        argv[argc ++] = buf;
  100af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af8:	8d 50 01             	lea    0x1(%eax),%edx
  100afb:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100afe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b08:	01 c2                	add    %eax,%edx
  100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0d:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0f:	eb 03                	jmp    100b14 <parse+0x85>
            buf ++;
  100b11:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b14:	8b 45 08             	mov    0x8(%ebp),%eax
  100b17:	0f b6 00             	movzbl (%eax),%eax
  100b1a:	84 c0                	test   %al,%al
  100b1c:	74 8c                	je     100aaa <parse+0x1b>
  100b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b21:	0f b6 00             	movzbl (%eax),%eax
  100b24:	0f be c0             	movsbl %al,%eax
  100b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b2b:	c7 04 24 a4 3a 10 00 	movl   $0x103aa4,(%esp)
  100b32:	e8 da 29 00 00       	call   103511 <strchr>
  100b37:	85 c0                	test   %eax,%eax
  100b39:	74 d6                	je     100b11 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b3b:	e9 6a ff ff ff       	jmp    100aaa <parse+0x1b>
            break;
  100b40:	90                   	nop
        }
    }
    return argc;
  100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b44:	89 ec                	mov    %ebp,%esp
  100b46:	5d                   	pop    %ebp
  100b47:	c3                   	ret    

00100b48 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b48:	55                   	push   %ebp
  100b49:	89 e5                	mov    %esp,%ebp
  100b4b:	83 ec 68             	sub    $0x68,%esp
  100b4e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b51:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b58:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5b:	89 04 24             	mov    %eax,(%esp)
  100b5e:	e8 2c ff ff ff       	call   100a8f <parse>
  100b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b6a:	75 0a                	jne    100b76 <runcmd+0x2e>
        return 0;
  100b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  100b71:	e9 83 00 00 00       	jmp    100bf9 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b7d:	eb 5a                	jmp    100bd9 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b7f:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b82:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b85:	89 c8                	mov    %ecx,%eax
  100b87:	01 c0                	add    %eax,%eax
  100b89:	01 c8                	add    %ecx,%eax
  100b8b:	c1 e0 02             	shl    $0x2,%eax
  100b8e:	05 00 f0 10 00       	add    $0x10f000,%eax
  100b93:	8b 00                	mov    (%eax),%eax
  100b95:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b99:	89 04 24             	mov    %eax,(%esp)
  100b9c:	e8 d4 28 00 00       	call   103475 <strcmp>
  100ba1:	85 c0                	test   %eax,%eax
  100ba3:	75 31                	jne    100bd6 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ba8:	89 d0                	mov    %edx,%eax
  100baa:	01 c0                	add    %eax,%eax
  100bac:	01 d0                	add    %edx,%eax
  100bae:	c1 e0 02             	shl    $0x2,%eax
  100bb1:	05 08 f0 10 00       	add    $0x10f008,%eax
  100bb6:	8b 10                	mov    (%eax),%edx
  100bb8:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bbb:	83 c0 04             	add    $0x4,%eax
  100bbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bc1:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bcf:	89 1c 24             	mov    %ebx,(%esp)
  100bd2:	ff d2                	call   *%edx
  100bd4:	eb 23                	jmp    100bf9 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bd6:	ff 45 f4             	incl   -0xc(%ebp)
  100bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bdc:	83 f8 02             	cmp    $0x2,%eax
  100bdf:	76 9e                	jbe    100b7f <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100be1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be8:	c7 04 24 c7 3a 10 00 	movl   $0x103ac7,(%esp)
  100bef:	e8 71 f7 ff ff       	call   100365 <cprintf>
    return 0;
  100bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100bfc:	89 ec                	mov    %ebp,%esp
  100bfe:	5d                   	pop    %ebp
  100bff:	c3                   	ret    

00100c00 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c00:	55                   	push   %ebp
  100c01:	89 e5                	mov    %esp,%ebp
  100c03:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c06:	c7 04 24 e0 3a 10 00 	movl   $0x103ae0,(%esp)
  100c0d:	e8 53 f7 ff ff       	call   100365 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c12:	c7 04 24 08 3b 10 00 	movl   $0x103b08,(%esp)
  100c19:	e8 47 f7 ff ff       	call   100365 <cprintf>

    if (tf != NULL) {
  100c1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c22:	74 0b                	je     100c2f <kmonitor+0x2f>
        print_trapframe(tf);
  100c24:	8b 45 08             	mov    0x8(%ebp),%eax
  100c27:	89 04 24             	mov    %eax,(%esp)
  100c2a:	e8 06 0f 00 00       	call   101b35 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c2f:	c7 04 24 2d 3b 10 00 	movl   $0x103b2d,(%esp)
  100c36:	e8 1b f6 ff ff       	call   100256 <readline>
  100c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c42:	74 eb                	je     100c2f <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c44:	8b 45 08             	mov    0x8(%ebp),%eax
  100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c4e:	89 04 24             	mov    %eax,(%esp)
  100c51:	e8 f2 fe ff ff       	call   100b48 <runcmd>
  100c56:	85 c0                	test   %eax,%eax
  100c58:	78 02                	js     100c5c <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c5a:	eb d3                	jmp    100c2f <kmonitor+0x2f>
                break;
  100c5c:	90                   	nop
            }
        }
    }
}
  100c5d:	90                   	nop
  100c5e:	89 ec                	mov    %ebp,%esp
  100c60:	5d                   	pop    %ebp
  100c61:	c3                   	ret    

00100c62 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c62:	55                   	push   %ebp
  100c63:	89 e5                	mov    %esp,%ebp
  100c65:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c6f:	eb 3d                	jmp    100cae <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c74:	89 d0                	mov    %edx,%eax
  100c76:	01 c0                	add    %eax,%eax
  100c78:	01 d0                	add    %edx,%eax
  100c7a:	c1 e0 02             	shl    $0x2,%eax
  100c7d:	05 04 f0 10 00       	add    $0x10f004,%eax
  100c82:	8b 10                	mov    (%eax),%edx
  100c84:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c87:	89 c8                	mov    %ecx,%eax
  100c89:	01 c0                	add    %eax,%eax
  100c8b:	01 c8                	add    %ecx,%eax
  100c8d:	c1 e0 02             	shl    $0x2,%eax
  100c90:	05 00 f0 10 00       	add    $0x10f000,%eax
  100c95:	8b 00                	mov    (%eax),%eax
  100c97:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9f:	c7 04 24 31 3b 10 00 	movl   $0x103b31,(%esp)
  100ca6:	e8 ba f6 ff ff       	call   100365 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cab:	ff 45 f4             	incl   -0xc(%ebp)
  100cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cb1:	83 f8 02             	cmp    $0x2,%eax
  100cb4:	76 bb                	jbe    100c71 <mon_help+0xf>
    }
    return 0;
  100cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbb:	89 ec                	mov    %ebp,%esp
  100cbd:	5d                   	pop    %ebp
  100cbe:	c3                   	ret    

00100cbf <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cbf:	55                   	push   %ebp
  100cc0:	89 e5                	mov    %esp,%ebp
  100cc2:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cc5:	e8 be fb ff ff       	call   100888 <print_kerninfo>
    return 0;
  100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ccf:	89 ec                	mov    %ebp,%esp
  100cd1:	5d                   	pop    %ebp
  100cd2:	c3                   	ret    

00100cd3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cd3:	55                   	push   %ebp
  100cd4:	89 e5                	mov    %esp,%ebp
  100cd6:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cd9:	e8 f6 fc ff ff       	call   1009d4 <print_stackframe>
    return 0;
  100cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ce3:	89 ec                	mov    %ebp,%esp
  100ce5:	5d                   	pop    %ebp
  100ce6:	c3                   	ret    

00100ce7 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100ce7:	55                   	push   %ebp
  100ce8:	89 e5                	mov    %esp,%ebp
  100cea:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ced:	a1 40 fe 10 00       	mov    0x10fe40,%eax
  100cf2:	85 c0                	test   %eax,%eax
  100cf4:	75 5b                	jne    100d51 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cf6:	c7 05 40 fe 10 00 01 	movl   $0x1,0x10fe40
  100cfd:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d00:	8d 45 14             	lea    0x14(%ebp),%eax
  100d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d09:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d14:	c7 04 24 3a 3b 10 00 	movl   $0x103b3a,(%esp)
  100d1b:	e8 45 f6 ff ff       	call   100365 <cprintf>
    vcprintf(fmt, ap);
  100d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d27:	8b 45 10             	mov    0x10(%ebp),%eax
  100d2a:	89 04 24             	mov    %eax,(%esp)
  100d2d:	e8 fe f5 ff ff       	call   100330 <vcprintf>
    cprintf("\n");
  100d32:	c7 04 24 56 3b 10 00 	movl   $0x103b56,(%esp)
  100d39:	e8 27 f6 ff ff       	call   100365 <cprintf>
    
    cprintf("stack trackback:\n");
  100d3e:	c7 04 24 58 3b 10 00 	movl   $0x103b58,(%esp)
  100d45:	e8 1b f6 ff ff       	call   100365 <cprintf>
    print_stackframe();
  100d4a:	e8 85 fc ff ff       	call   1009d4 <print_stackframe>
  100d4f:	eb 01                	jmp    100d52 <__panic+0x6b>
        goto panic_dead;
  100d51:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d52:	e8 81 09 00 00       	call   1016d8 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d5e:	e8 9d fe ff ff       	call   100c00 <kmonitor>
  100d63:	eb f2                	jmp    100d57 <__panic+0x70>

00100d65 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d65:	55                   	push   %ebp
  100d66:	89 e5                	mov    %esp,%ebp
  100d68:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d6b:	8d 45 14             	lea    0x14(%ebp),%eax
  100d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d71:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d74:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d78:	8b 45 08             	mov    0x8(%ebp),%eax
  100d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7f:	c7 04 24 6a 3b 10 00 	movl   $0x103b6a,(%esp)
  100d86:	e8 da f5 ff ff       	call   100365 <cprintf>
    vcprintf(fmt, ap);
  100d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d92:	8b 45 10             	mov    0x10(%ebp),%eax
  100d95:	89 04 24             	mov    %eax,(%esp)
  100d98:	e8 93 f5 ff ff       	call   100330 <vcprintf>
    cprintf("\n");
  100d9d:	c7 04 24 56 3b 10 00 	movl   $0x103b56,(%esp)
  100da4:	e8 bc f5 ff ff       	call   100365 <cprintf>
    va_end(ap);
}
  100da9:	90                   	nop
  100daa:	89 ec                	mov    %ebp,%esp
  100dac:	5d                   	pop    %ebp
  100dad:	c3                   	ret    

00100dae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100dae:	55                   	push   %ebp
  100daf:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100db1:	a1 40 fe 10 00       	mov    0x10fe40,%eax
}
  100db6:	5d                   	pop    %ebp
  100db7:	c3                   	ret    

00100db8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100db8:	55                   	push   %ebp
  100db9:	89 e5                	mov    %esp,%ebp
  100dbb:	83 ec 28             	sub    $0x28,%esp
  100dbe:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dc4:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dc8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dcc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dd0:	ee                   	out    %al,(%dx)
}
  100dd1:	90                   	nop
  100dd2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dd8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ddc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100de0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100de4:	ee                   	out    %al,(%dx)
}
  100de5:	90                   	nop
  100de6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dec:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100df0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100df4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100df8:	ee                   	out    %al,(%dx)
}
  100df9:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dfa:	c7 05 44 fe 10 00 00 	movl   $0x0,0x10fe44
  100e01:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e04:	c7 04 24 88 3b 10 00 	movl   $0x103b88,(%esp)
  100e0b:	e8 55 f5 ff ff       	call   100365 <cprintf>
    pic_enable(IRQ_TIMER);
  100e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e17:	e8 21 09 00 00       	call   10173d <pic_enable>
}
  100e1c:	90                   	nop
  100e1d:	89 ec                	mov    %ebp,%esp
  100e1f:	5d                   	pop    %ebp
  100e20:	c3                   	ret    

00100e21 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e21:	55                   	push   %ebp
  100e22:	89 e5                	mov    %esp,%ebp
  100e24:	83 ec 10             	sub    $0x10,%esp
  100e27:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e2d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e31:	89 c2                	mov    %eax,%edx
  100e33:	ec                   	in     (%dx),%al
  100e34:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e37:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e3d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e41:	89 c2                	mov    %eax,%edx
  100e43:	ec                   	in     (%dx),%al
  100e44:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e47:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e4d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e51:	89 c2                	mov    %eax,%edx
  100e53:	ec                   	in     (%dx),%al
  100e54:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e57:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e5d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e61:	89 c2                	mov    %eax,%edx
  100e63:	ec                   	in     (%dx),%al
  100e64:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e67:	90                   	nop
  100e68:	89 ec                	mov    %ebp,%esp
  100e6a:	5d                   	pop    %ebp
  100e6b:	c3                   	ret    

00100e6c <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e6c:	55                   	push   %ebp
  100e6d:	89 e5                	mov    %esp,%ebp
  100e6f:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e72:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e79:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e7c:	0f b7 00             	movzwl (%eax),%eax
  100e7f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e86:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8e:	0f b7 00             	movzwl (%eax),%eax
  100e91:	0f b7 c0             	movzwl %ax,%eax
  100e94:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e99:	74 12                	je     100ead <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e9b:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100ea2:	66 c7 05 66 fe 10 00 	movw   $0x3b4,0x10fe66
  100ea9:	b4 03 
  100eab:	eb 13                	jmp    100ec0 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eb4:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100eb7:	66 c7 05 66 fe 10 00 	movw   $0x3d4,0x10fe66
  100ebe:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100ec0:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ec7:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ecb:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ecf:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ed3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ed7:	ee                   	out    %al,(%dx)
}
  100ed8:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100ed9:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ee0:	40                   	inc    %eax
  100ee1:	0f b7 c0             	movzwl %ax,%eax
  100ee4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ee8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100eec:	89 c2                	mov    %eax,%edx
  100eee:	ec                   	in     (%dx),%al
  100eef:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100ef2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ef6:	0f b6 c0             	movzbl %al,%eax
  100ef9:	c1 e0 08             	shl    $0x8,%eax
  100efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100eff:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f06:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f0a:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f0e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f12:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f16:	ee                   	out    %al,(%dx)
}
  100f17:	90                   	nop
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100f18:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f1f:	40                   	inc    %eax
  100f20:	0f b7 c0             	movzwl %ax,%eax
  100f23:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f27:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f2b:	89 c2                	mov    %eax,%edx
  100f2d:	ec                   	in     (%dx),%al
  100f2e:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f31:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f35:	0f b6 c0             	movzbl %al,%eax
  100f38:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f3e:	a3 60 fe 10 00       	mov    %eax,0x10fe60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f46:	0f b7 c0             	movzwl %ax,%eax
  100f49:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
}
  100f4f:	90                   	nop
  100f50:	89 ec                	mov    %ebp,%esp
  100f52:	5d                   	pop    %ebp
  100f53:	c3                   	ret    

00100f54 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f54:	55                   	push   %ebp
  100f55:	89 e5                	mov    %esp,%ebp
  100f57:	83 ec 48             	sub    $0x48,%esp
  100f5a:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f60:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f64:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f68:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f6c:	ee                   	out    %al,(%dx)
}
  100f6d:	90                   	nop
  100f6e:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f74:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f78:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f7c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f80:	ee                   	out    %al,(%dx)
}
  100f81:	90                   	nop
  100f82:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f88:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f8c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f90:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f94:	ee                   	out    %al,(%dx)
}
  100f95:	90                   	nop
  100f96:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f9c:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fa0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa4:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fa8:	ee                   	out    %al,(%dx)
}
  100fa9:	90                   	nop
  100faa:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fb0:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fb4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fb8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fbc:	ee                   	out    %al,(%dx)
}
  100fbd:	90                   	nop
  100fbe:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fc4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fc8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd0:	ee                   	out    %al,(%dx)
}
  100fd1:	90                   	nop
  100fd2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd8:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fdc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fe0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
}
  100fe5:	90                   	nop
  100fe6:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fec:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ff0:	89 c2                	mov    %eax,%edx
  100ff2:	ec                   	in     (%dx),%al
  100ff3:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ff6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ffa:	3c ff                	cmp    $0xff,%al
  100ffc:	0f 95 c0             	setne  %al
  100fff:	0f b6 c0             	movzbl %al,%eax
  101002:	a3 68 fe 10 00       	mov    %eax,0x10fe68
  101007:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10100d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101011:	89 c2                	mov    %eax,%edx
  101013:	ec                   	in     (%dx),%al
  101014:	88 45 f1             	mov    %al,-0xf(%ebp)
  101017:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10101d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101021:	89 c2                	mov    %eax,%edx
  101023:	ec                   	in     (%dx),%al
  101024:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101027:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10102c:	85 c0                	test   %eax,%eax
  10102e:	74 0c                	je     10103c <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101030:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101037:	e8 01 07 00 00       	call   10173d <pic_enable>
    }
}
  10103c:	90                   	nop
  10103d:	89 ec                	mov    %ebp,%esp
  10103f:	5d                   	pop    %ebp
  101040:	c3                   	ret    

00101041 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101041:	55                   	push   %ebp
  101042:	89 e5                	mov    %esp,%ebp
  101044:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101047:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10104e:	eb 08                	jmp    101058 <lpt_putc_sub+0x17>
        delay();
  101050:	e8 cc fd ff ff       	call   100e21 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101055:	ff 45 fc             	incl   -0x4(%ebp)
  101058:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10105e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101062:	89 c2                	mov    %eax,%edx
  101064:	ec                   	in     (%dx),%al
  101065:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101068:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10106c:	84 c0                	test   %al,%al
  10106e:	78 09                	js     101079 <lpt_putc_sub+0x38>
  101070:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101077:	7e d7                	jle    101050 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101079:	8b 45 08             	mov    0x8(%ebp),%eax
  10107c:	0f b6 c0             	movzbl %al,%eax
  10107f:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101085:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101088:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10108c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101090:	ee                   	out    %al,(%dx)
}
  101091:	90                   	nop
  101092:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101098:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10109c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010a0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010a4:	ee                   	out    %al,(%dx)
}
  1010a5:	90                   	nop
  1010a6:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010ac:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010b0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010b4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010b8:	ee                   	out    %al,(%dx)
}
  1010b9:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010ba:	90                   	nop
  1010bb:	89 ec                	mov    %ebp,%esp
  1010bd:	5d                   	pop    %ebp
  1010be:	c3                   	ret    

001010bf <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010bf:	55                   	push   %ebp
  1010c0:	89 e5                	mov    %esp,%ebp
  1010c2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010c5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010c9:	74 0d                	je     1010d8 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ce:	89 04 24             	mov    %eax,(%esp)
  1010d1:	e8 6b ff ff ff       	call   101041 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010d6:	eb 24                	jmp    1010fc <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010d8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010df:	e8 5d ff ff ff       	call   101041 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010eb:	e8 51 ff ff ff       	call   101041 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010f0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f7:	e8 45 ff ff ff       	call   101041 <lpt_putc_sub>
}
  1010fc:	90                   	nop
  1010fd:	89 ec                	mov    %ebp,%esp
  1010ff:	5d                   	pop    %ebp
  101100:	c3                   	ret    

00101101 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101101:	55                   	push   %ebp
  101102:	89 e5                	mov    %esp,%ebp
  101104:	83 ec 38             	sub    $0x38,%esp
  101107:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  10110a:	8b 45 08             	mov    0x8(%ebp),%eax
  10110d:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101112:	85 c0                	test   %eax,%eax
  101114:	75 07                	jne    10111d <cga_putc+0x1c>
        c |= 0x0700;
  101116:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10111d:	8b 45 08             	mov    0x8(%ebp),%eax
  101120:	0f b6 c0             	movzbl %al,%eax
  101123:	83 f8 0d             	cmp    $0xd,%eax
  101126:	74 72                	je     10119a <cga_putc+0x99>
  101128:	83 f8 0d             	cmp    $0xd,%eax
  10112b:	0f 8f a3 00 00 00    	jg     1011d4 <cga_putc+0xd3>
  101131:	83 f8 08             	cmp    $0x8,%eax
  101134:	74 0a                	je     101140 <cga_putc+0x3f>
  101136:	83 f8 0a             	cmp    $0xa,%eax
  101139:	74 4c                	je     101187 <cga_putc+0x86>
  10113b:	e9 94 00 00 00       	jmp    1011d4 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101140:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101147:	85 c0                	test   %eax,%eax
  101149:	0f 84 af 00 00 00    	je     1011fe <cga_putc+0xfd>
            crt_pos --;
  10114f:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101156:	48                   	dec    %eax
  101157:	0f b7 c0             	movzwl %ax,%eax
  10115a:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101160:	8b 45 08             	mov    0x8(%ebp),%eax
  101163:	98                   	cwtl   
  101164:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101169:	98                   	cwtl   
  10116a:	83 c8 20             	or     $0x20,%eax
  10116d:	98                   	cwtl   
  10116e:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  101174:	0f b7 15 64 fe 10 00 	movzwl 0x10fe64,%edx
  10117b:	01 d2                	add    %edx,%edx
  10117d:	01 ca                	add    %ecx,%edx
  10117f:	0f b7 c0             	movzwl %ax,%eax
  101182:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101185:	eb 77                	jmp    1011fe <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  101187:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10118e:	83 c0 50             	add    $0x50,%eax
  101191:	0f b7 c0             	movzwl %ax,%eax
  101194:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10119a:	0f b7 1d 64 fe 10 00 	movzwl 0x10fe64,%ebx
  1011a1:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  1011a8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011ad:	89 c8                	mov    %ecx,%eax
  1011af:	f7 e2                	mul    %edx
  1011b1:	c1 ea 06             	shr    $0x6,%edx
  1011b4:	89 d0                	mov    %edx,%eax
  1011b6:	c1 e0 02             	shl    $0x2,%eax
  1011b9:	01 d0                	add    %edx,%eax
  1011bb:	c1 e0 04             	shl    $0x4,%eax
  1011be:	29 c1                	sub    %eax,%ecx
  1011c0:	89 ca                	mov    %ecx,%edx
  1011c2:	0f b7 d2             	movzwl %dx,%edx
  1011c5:	89 d8                	mov    %ebx,%eax
  1011c7:	29 d0                	sub    %edx,%eax
  1011c9:	0f b7 c0             	movzwl %ax,%eax
  1011cc:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
        break;
  1011d2:	eb 2b                	jmp    1011ff <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011d4:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  1011da:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011e1:	8d 50 01             	lea    0x1(%eax),%edx
  1011e4:	0f b7 d2             	movzwl %dx,%edx
  1011e7:	66 89 15 64 fe 10 00 	mov    %dx,0x10fe64
  1011ee:	01 c0                	add    %eax,%eax
  1011f0:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f6:	0f b7 c0             	movzwl %ax,%eax
  1011f9:	66 89 02             	mov    %ax,(%edx)
        break;
  1011fc:	eb 01                	jmp    1011ff <cga_putc+0xfe>
        break;
  1011fe:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011ff:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101206:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  10120b:	76 5e                	jbe    10126b <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10120d:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  101212:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101218:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  10121d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101224:	00 
  101225:	89 54 24 04          	mov    %edx,0x4(%esp)
  101229:	89 04 24             	mov    %eax,(%esp)
  10122c:	e8 de 24 00 00       	call   10370f <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101231:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101238:	eb 15                	jmp    10124f <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  10123a:	8b 15 60 fe 10 00    	mov    0x10fe60,%edx
  101240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101243:	01 c0                	add    %eax,%eax
  101245:	01 d0                	add    %edx,%eax
  101247:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10124c:	ff 45 f4             	incl   -0xc(%ebp)
  10124f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101256:	7e e2                	jle    10123a <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  101258:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10125f:	83 e8 50             	sub    $0x50,%eax
  101262:	0f b7 c0             	movzwl %ax,%eax
  101265:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10126b:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101272:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101276:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10127a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10127e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101282:	ee                   	out    %al,(%dx)
}
  101283:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  101284:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10128b:	c1 e8 08             	shr    $0x8,%eax
  10128e:	0f b7 c0             	movzwl %ax,%eax
  101291:	0f b6 c0             	movzbl %al,%eax
  101294:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  10129b:	42                   	inc    %edx
  10129c:	0f b7 d2             	movzwl %dx,%edx
  10129f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012a3:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012ae:	ee                   	out    %al,(%dx)
}
  1012af:	90                   	nop
    outb(addr_6845, 15);
  1012b0:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  1012b7:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012bb:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012bf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012c3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012c7:	ee                   	out    %al,(%dx)
}
  1012c8:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012c9:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1012d0:	0f b6 c0             	movzbl %al,%eax
  1012d3:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  1012da:	42                   	inc    %edx
  1012db:	0f b7 d2             	movzwl %dx,%edx
  1012de:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012e2:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012e5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012e9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012ed:	ee                   	out    %al,(%dx)
}
  1012ee:	90                   	nop
}
  1012ef:	90                   	nop
  1012f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1012f3:	89 ec                	mov    %ebp,%esp
  1012f5:	5d                   	pop    %ebp
  1012f6:	c3                   	ret    

001012f7 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012f7:	55                   	push   %ebp
  1012f8:	89 e5                	mov    %esp,%ebp
  1012fa:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101304:	eb 08                	jmp    10130e <serial_putc_sub+0x17>
        delay();
  101306:	e8 16 fb ff ff       	call   100e21 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10130b:	ff 45 fc             	incl   -0x4(%ebp)
  10130e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101314:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101318:	89 c2                	mov    %eax,%edx
  10131a:	ec                   	in     (%dx),%al
  10131b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10131e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101322:	0f b6 c0             	movzbl %al,%eax
  101325:	83 e0 20             	and    $0x20,%eax
  101328:	85 c0                	test   %eax,%eax
  10132a:	75 09                	jne    101335 <serial_putc_sub+0x3e>
  10132c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101333:	7e d1                	jle    101306 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101335:	8b 45 08             	mov    0x8(%ebp),%eax
  101338:	0f b6 c0             	movzbl %al,%eax
  10133b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101341:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101344:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101348:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10134c:	ee                   	out    %al,(%dx)
}
  10134d:	90                   	nop
}
  10134e:	90                   	nop
  10134f:	89 ec                	mov    %ebp,%esp
  101351:	5d                   	pop    %ebp
  101352:	c3                   	ret    

00101353 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101353:	55                   	push   %ebp
  101354:	89 e5                	mov    %esp,%ebp
  101356:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101359:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10135d:	74 0d                	je     10136c <serial_putc+0x19>
        serial_putc_sub(c);
  10135f:	8b 45 08             	mov    0x8(%ebp),%eax
  101362:	89 04 24             	mov    %eax,(%esp)
  101365:	e8 8d ff ff ff       	call   1012f7 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10136a:	eb 24                	jmp    101390 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10136c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101373:	e8 7f ff ff ff       	call   1012f7 <serial_putc_sub>
        serial_putc_sub(' ');
  101378:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10137f:	e8 73 ff ff ff       	call   1012f7 <serial_putc_sub>
        serial_putc_sub('\b');
  101384:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10138b:	e8 67 ff ff ff       	call   1012f7 <serial_putc_sub>
}
  101390:	90                   	nop
  101391:	89 ec                	mov    %ebp,%esp
  101393:	5d                   	pop    %ebp
  101394:	c3                   	ret    

00101395 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101395:	55                   	push   %ebp
  101396:	89 e5                	mov    %esp,%ebp
  101398:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10139b:	eb 33                	jmp    1013d0 <cons_intr+0x3b>
        if (c != 0) {
  10139d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013a1:	74 2d                	je     1013d0 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013a3:	a1 84 00 11 00       	mov    0x110084,%eax
  1013a8:	8d 50 01             	lea    0x1(%eax),%edx
  1013ab:	89 15 84 00 11 00    	mov    %edx,0x110084
  1013b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013b4:	88 90 80 fe 10 00    	mov    %dl,0x10fe80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013ba:	a1 84 00 11 00       	mov    0x110084,%eax
  1013bf:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013c4:	75 0a                	jne    1013d0 <cons_intr+0x3b>
                cons.wpos = 0;
  1013c6:	c7 05 84 00 11 00 00 	movl   $0x0,0x110084
  1013cd:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1013d3:	ff d0                	call   *%eax
  1013d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013d8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013dc:	75 bf                	jne    10139d <cons_intr+0x8>
            }
        }
    }
}
  1013de:	90                   	nop
  1013df:	90                   	nop
  1013e0:	89 ec                	mov    %ebp,%esp
  1013e2:	5d                   	pop    %ebp
  1013e3:	c3                   	ret    

001013e4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013e4:	55                   	push   %ebp
  1013e5:	89 e5                	mov    %esp,%ebp
  1013e7:	83 ec 10             	sub    $0x10,%esp
  1013ea:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013f0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013fa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	83 e0 01             	and    $0x1,%eax
  101404:	85 c0                	test   %eax,%eax
  101406:	75 07                	jne    10140f <serial_proc_data+0x2b>
        return -1;
  101408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10140d:	eb 2a                	jmp    101439 <serial_proc_data+0x55>
  10140f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101415:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101419:	89 c2                	mov    %eax,%edx
  10141b:	ec                   	in     (%dx),%al
  10141c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10141f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101423:	0f b6 c0             	movzbl %al,%eax
  101426:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101429:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10142d:	75 07                	jne    101436 <serial_proc_data+0x52>
        c = '\b';
  10142f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101436:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101439:	89 ec                	mov    %ebp,%esp
  10143b:	5d                   	pop    %ebp
  10143c:	c3                   	ret    

0010143d <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10143d:	55                   	push   %ebp
  10143e:	89 e5                	mov    %esp,%ebp
  101440:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101443:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101448:	85 c0                	test   %eax,%eax
  10144a:	74 0c                	je     101458 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10144c:	c7 04 24 e4 13 10 00 	movl   $0x1013e4,(%esp)
  101453:	e8 3d ff ff ff       	call   101395 <cons_intr>
    }
}
  101458:	90                   	nop
  101459:	89 ec                	mov    %ebp,%esp
  10145b:	5d                   	pop    %ebp
  10145c:	c3                   	ret    

0010145d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10145d:	55                   	push   %ebp
  10145e:	89 e5                	mov    %esp,%ebp
  101460:	83 ec 38             	sub    $0x38,%esp
  101463:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10146c:	89 c2                	mov    %eax,%edx
  10146e:	ec                   	in     (%dx),%al
  10146f:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101472:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101476:	0f b6 c0             	movzbl %al,%eax
  101479:	83 e0 01             	and    $0x1,%eax
  10147c:	85 c0                	test   %eax,%eax
  10147e:	75 0a                	jne    10148a <kbd_proc_data+0x2d>
        return -1;
  101480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101485:	e9 56 01 00 00       	jmp    1015e0 <kbd_proc_data+0x183>
  10148a:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101490:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101493:	89 c2                	mov    %eax,%edx
  101495:	ec                   	in     (%dx),%al
  101496:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101499:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10149d:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014a0:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014a4:	75 17                	jne    1014bd <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014a6:	a1 88 00 11 00       	mov    0x110088,%eax
  1014ab:	83 c8 40             	or     $0x40,%eax
  1014ae:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  1014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  1014b8:	e9 23 01 00 00       	jmp    1015e0 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c1:	84 c0                	test   %al,%al
  1014c3:	79 45                	jns    10150a <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014c5:	a1 88 00 11 00       	mov    0x110088,%eax
  1014ca:	83 e0 40             	and    $0x40,%eax
  1014cd:	85 c0                	test   %eax,%eax
  1014cf:	75 08                	jne    1014d9 <kbd_proc_data+0x7c>
  1014d1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d5:	24 7f                	and    $0x7f,%al
  1014d7:	eb 04                	jmp    1014dd <kbd_proc_data+0x80>
  1014d9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014dd:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014e0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014e4:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  1014eb:	0c 40                	or     $0x40,%al
  1014ed:	0f b6 c0             	movzbl %al,%eax
  1014f0:	f7 d0                	not    %eax
  1014f2:	89 c2                	mov    %eax,%edx
  1014f4:	a1 88 00 11 00       	mov    0x110088,%eax
  1014f9:	21 d0                	and    %edx,%eax
  1014fb:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  101500:	b8 00 00 00 00       	mov    $0x0,%eax
  101505:	e9 d6 00 00 00       	jmp    1015e0 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  10150a:	a1 88 00 11 00       	mov    0x110088,%eax
  10150f:	83 e0 40             	and    $0x40,%eax
  101512:	85 c0                	test   %eax,%eax
  101514:	74 11                	je     101527 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101516:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10151a:	a1 88 00 11 00       	mov    0x110088,%eax
  10151f:	83 e0 bf             	and    $0xffffffbf,%eax
  101522:	a3 88 00 11 00       	mov    %eax,0x110088
    }

    shift |= shiftcode[data];
  101527:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10152b:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  101532:	0f b6 d0             	movzbl %al,%edx
  101535:	a1 88 00 11 00       	mov    0x110088,%eax
  10153a:	09 d0                	or     %edx,%eax
  10153c:	a3 88 00 11 00       	mov    %eax,0x110088
    shift ^= togglecode[data];
  101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101545:	0f b6 80 40 f1 10 00 	movzbl 0x10f140(%eax),%eax
  10154c:	0f b6 d0             	movzbl %al,%edx
  10154f:	a1 88 00 11 00       	mov    0x110088,%eax
  101554:	31 d0                	xor    %edx,%eax
  101556:	a3 88 00 11 00       	mov    %eax,0x110088

    c = charcode[shift & (CTL | SHIFT)][data];
  10155b:	a1 88 00 11 00       	mov    0x110088,%eax
  101560:	83 e0 03             	and    $0x3,%eax
  101563:	8b 14 85 40 f5 10 00 	mov    0x10f540(,%eax,4),%edx
  10156a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10156e:	01 d0                	add    %edx,%eax
  101570:	0f b6 00             	movzbl (%eax),%eax
  101573:	0f b6 c0             	movzbl %al,%eax
  101576:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101579:	a1 88 00 11 00       	mov    0x110088,%eax
  10157e:	83 e0 08             	and    $0x8,%eax
  101581:	85 c0                	test   %eax,%eax
  101583:	74 22                	je     1015a7 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101585:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101589:	7e 0c                	jle    101597 <kbd_proc_data+0x13a>
  10158b:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10158f:	7f 06                	jg     101597 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101591:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101595:	eb 10                	jmp    1015a7 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101597:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10159b:	7e 0a                	jle    1015a7 <kbd_proc_data+0x14a>
  10159d:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015a1:	7f 04                	jg     1015a7 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015a3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015a7:	a1 88 00 11 00       	mov    0x110088,%eax
  1015ac:	f7 d0                	not    %eax
  1015ae:	83 e0 06             	and    $0x6,%eax
  1015b1:	85 c0                	test   %eax,%eax
  1015b3:	75 28                	jne    1015dd <kbd_proc_data+0x180>
  1015b5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015bc:	75 1f                	jne    1015dd <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015be:	c7 04 24 a3 3b 10 00 	movl   $0x103ba3,(%esp)
  1015c5:	e8 9b ed ff ff       	call   100365 <cprintf>
  1015ca:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015d0:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1015d4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015db:	ee                   	out    %al,(%dx)
}
  1015dc:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015e0:	89 ec                	mov    %ebp,%esp
  1015e2:	5d                   	pop    %ebp
  1015e3:	c3                   	ret    

001015e4 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015e4:	55                   	push   %ebp
  1015e5:	89 e5                	mov    %esp,%ebp
  1015e7:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015ea:	c7 04 24 5d 14 10 00 	movl   $0x10145d,(%esp)
  1015f1:	e8 9f fd ff ff       	call   101395 <cons_intr>
}
  1015f6:	90                   	nop
  1015f7:	89 ec                	mov    %ebp,%esp
  1015f9:	5d                   	pop    %ebp
  1015fa:	c3                   	ret    

001015fb <kbd_init>:

static void
kbd_init(void) {
  1015fb:	55                   	push   %ebp
  1015fc:	89 e5                	mov    %esp,%ebp
  1015fe:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101601:	e8 de ff ff ff       	call   1015e4 <kbd_intr>
    pic_enable(IRQ_KBD);
  101606:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10160d:	e8 2b 01 00 00       	call   10173d <pic_enable>
}
  101612:	90                   	nop
  101613:	89 ec                	mov    %ebp,%esp
  101615:	5d                   	pop    %ebp
  101616:	c3                   	ret    

00101617 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101617:	55                   	push   %ebp
  101618:	89 e5                	mov    %esp,%ebp
  10161a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10161d:	e8 4a f8 ff ff       	call   100e6c <cga_init>
    serial_init();
  101622:	e8 2d f9 ff ff       	call   100f54 <serial_init>
    kbd_init();
  101627:	e8 cf ff ff ff       	call   1015fb <kbd_init>
    if (!serial_exists) {
  10162c:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101631:	85 c0                	test   %eax,%eax
  101633:	75 0c                	jne    101641 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101635:	c7 04 24 af 3b 10 00 	movl   $0x103baf,(%esp)
  10163c:	e8 24 ed ff ff       	call   100365 <cprintf>
    }
}
  101641:	90                   	nop
  101642:	89 ec                	mov    %ebp,%esp
  101644:	5d                   	pop    %ebp
  101645:	c3                   	ret    

00101646 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101646:	55                   	push   %ebp
  101647:	89 e5                	mov    %esp,%ebp
  101649:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  10164c:	8b 45 08             	mov    0x8(%ebp),%eax
  10164f:	89 04 24             	mov    %eax,(%esp)
  101652:	e8 68 fa ff ff       	call   1010bf <lpt_putc>
    cga_putc(c);
  101657:	8b 45 08             	mov    0x8(%ebp),%eax
  10165a:	89 04 24             	mov    %eax,(%esp)
  10165d:	e8 9f fa ff ff       	call   101101 <cga_putc>
    serial_putc(c);
  101662:	8b 45 08             	mov    0x8(%ebp),%eax
  101665:	89 04 24             	mov    %eax,(%esp)
  101668:	e8 e6 fc ff ff       	call   101353 <serial_putc>
}
  10166d:	90                   	nop
  10166e:	89 ec                	mov    %ebp,%esp
  101670:	5d                   	pop    %ebp
  101671:	c3                   	ret    

00101672 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101672:	55                   	push   %ebp
  101673:	89 e5                	mov    %esp,%ebp
  101675:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  101678:	e8 c0 fd ff ff       	call   10143d <serial_intr>
    kbd_intr();
  10167d:	e8 62 ff ff ff       	call   1015e4 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  101682:	8b 15 80 00 11 00    	mov    0x110080,%edx
  101688:	a1 84 00 11 00       	mov    0x110084,%eax
  10168d:	39 c2                	cmp    %eax,%edx
  10168f:	74 36                	je     1016c7 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101691:	a1 80 00 11 00       	mov    0x110080,%eax
  101696:	8d 50 01             	lea    0x1(%eax),%edx
  101699:	89 15 80 00 11 00    	mov    %edx,0x110080
  10169f:	0f b6 80 80 fe 10 00 	movzbl 0x10fe80(%eax),%eax
  1016a6:	0f b6 c0             	movzbl %al,%eax
  1016a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  1016ac:	a1 80 00 11 00       	mov    0x110080,%eax
  1016b1:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016b6:	75 0a                	jne    1016c2 <cons_getc+0x50>
            cons.rpos = 0;
  1016b8:	c7 05 80 00 11 00 00 	movl   $0x0,0x110080
  1016bf:	00 00 00 
        }
        return c;
  1016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016c5:	eb 05                	jmp    1016cc <cons_getc+0x5a>
    }
    return 0;
  1016c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1016cc:	89 ec                	mov    %ebp,%esp
  1016ce:	5d                   	pop    %ebp
  1016cf:	c3                   	ret    

001016d0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016d0:	55                   	push   %ebp
  1016d1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016d3:	fb                   	sti    
}
  1016d4:	90                   	nop
    sti();
}
  1016d5:	90                   	nop
  1016d6:	5d                   	pop    %ebp
  1016d7:	c3                   	ret    

001016d8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016d8:	55                   	push   %ebp
  1016d9:	89 e5                	mov    %esp,%ebp

static inline void
cli(void) {
    asm volatile ("cli");
  1016db:	fa                   	cli    
}
  1016dc:	90                   	nop
    cli();
}
  1016dd:	90                   	nop
  1016de:	5d                   	pop    %ebp
  1016df:	c3                   	ret    

001016e0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016e0:	55                   	push   %ebp
  1016e1:	89 e5                	mov    %esp,%ebp
  1016e3:	83 ec 14             	sub    $0x14,%esp
  1016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1016e9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016f0:	66 a3 50 f5 10 00    	mov    %ax,0x10f550
    if (did_init) {
  1016f6:	a1 8c 00 11 00       	mov    0x11008c,%eax
  1016fb:	85 c0                	test   %eax,%eax
  1016fd:	74 39                	je     101738 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  1016ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101702:	0f b6 c0             	movzbl %al,%eax
  101705:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10170b:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10170e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101712:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101716:	ee                   	out    %al,(%dx)
}
  101717:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101718:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10171c:	c1 e8 08             	shr    $0x8,%eax
  10171f:	0f b7 c0             	movzwl %ax,%eax
  101722:	0f b6 c0             	movzbl %al,%eax
  101725:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10172b:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10172e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101732:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101736:	ee                   	out    %al,(%dx)
}
  101737:	90                   	nop
    }
}
  101738:	90                   	nop
  101739:	89 ec                	mov    %ebp,%esp
  10173b:	5d                   	pop    %ebp
  10173c:	c3                   	ret    

0010173d <pic_enable>:

void
pic_enable(unsigned int irq) {
  10173d:	55                   	push   %ebp
  10173e:	89 e5                	mov    %esp,%ebp
  101740:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101743:	8b 45 08             	mov    0x8(%ebp),%eax
  101746:	ba 01 00 00 00       	mov    $0x1,%edx
  10174b:	88 c1                	mov    %al,%cl
  10174d:	d3 e2                	shl    %cl,%edx
  10174f:	89 d0                	mov    %edx,%eax
  101751:	98                   	cwtl   
  101752:	f7 d0                	not    %eax
  101754:	0f bf d0             	movswl %ax,%edx
  101757:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  10175e:	98                   	cwtl   
  10175f:	21 d0                	and    %edx,%eax
  101761:	98                   	cwtl   
  101762:	0f b7 c0             	movzwl %ax,%eax
  101765:	89 04 24             	mov    %eax,(%esp)
  101768:	e8 73 ff ff ff       	call   1016e0 <pic_setmask>
}
  10176d:	90                   	nop
  10176e:	89 ec                	mov    %ebp,%esp
  101770:	5d                   	pop    %ebp
  101771:	c3                   	ret    

00101772 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101772:	55                   	push   %ebp
  101773:	89 e5                	mov    %esp,%ebp
  101775:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101778:	c7 05 8c 00 11 00 01 	movl   $0x1,0x11008c
  10177f:	00 00 00 
  101782:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101788:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10178c:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101790:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101794:	ee                   	out    %al,(%dx)
}
  101795:	90                   	nop
  101796:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  10179c:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017a0:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017a4:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017a8:	ee                   	out    %al,(%dx)
}
  1017a9:	90                   	nop
  1017aa:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017b0:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017b4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017b8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017bc:	ee                   	out    %al,(%dx)
}
  1017bd:	90                   	nop
  1017be:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017c4:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017c8:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017cc:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017d0:	ee                   	out    %al,(%dx)
}
  1017d1:	90                   	nop
  1017d2:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017d8:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017dc:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017e0:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017e4:	ee                   	out    %al,(%dx)
}
  1017e5:	90                   	nop
  1017e6:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017ec:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017f0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017f4:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017f8:	ee                   	out    %al,(%dx)
}
  1017f9:	90                   	nop
  1017fa:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101800:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101804:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101808:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10180c:	ee                   	out    %al,(%dx)
}
  10180d:	90                   	nop
  10180e:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101814:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101818:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10181c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101820:	ee                   	out    %al,(%dx)
}
  101821:	90                   	nop
  101822:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101828:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10182c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101830:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101834:	ee                   	out    %al,(%dx)
}
  101835:	90                   	nop
  101836:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10183c:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101840:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101844:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101848:	ee                   	out    %al,(%dx)
}
  101849:	90                   	nop
  10184a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101850:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101854:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101858:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10185c:	ee                   	out    %al,(%dx)
}
  10185d:	90                   	nop
  10185e:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101864:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101868:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10186c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101870:	ee                   	out    %al,(%dx)
}
  101871:	90                   	nop
  101872:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101878:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10187c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101880:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101884:	ee                   	out    %al,(%dx)
}
  101885:	90                   	nop
  101886:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10188c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101890:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101894:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101898:	ee                   	out    %al,(%dx)
}
  101899:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10189a:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1018a1:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1018a6:	74 0f                	je     1018b7 <pic_init+0x145>
        pic_setmask(irq_mask);
  1018a8:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1018af:	89 04 24             	mov    %eax,(%esp)
  1018b2:	e8 29 fe ff ff       	call   1016e0 <pic_setmask>
    }
}
  1018b7:	90                   	nop
  1018b8:	89 ec                	mov    %ebp,%esp
  1018ba:	5d                   	pop    %ebp
  1018bb:	c3                   	ret    

001018bc <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1018bc:	55                   	push   %ebp
  1018bd:	89 e5                	mov    %esp,%ebp
  1018bf:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018c2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018c9:	00 
  1018ca:	c7 04 24 e0 3b 10 00 	movl   $0x103be0,(%esp)
  1018d1:	e8 8f ea ff ff       	call   100365 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018d6:	c7 04 24 ea 3b 10 00 	movl   $0x103bea,(%esp)
  1018dd:	e8 83 ea ff ff       	call   100365 <cprintf>
    panic("EOT: kernel seems ok.");
  1018e2:	c7 44 24 08 f8 3b 10 	movl   $0x103bf8,0x8(%esp)
  1018e9:	00 
  1018ea:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018f1:	00 
  1018f2:	c7 04 24 0e 3c 10 00 	movl   $0x103c0e,(%esp)
  1018f9:	e8 e9 f3 ff ff       	call   100ce7 <__panic>

001018fe <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018fe:	55                   	push   %ebp
  1018ff:	89 e5                	mov    %esp,%ebp
  101901:	83 ec 10             	sub    $0x10,%esp
    
    extern uintptr_t __vectors[];

    //all gate DPL=0, so use DPL_KERNEL 
    int i;
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
  101904:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10190b:	e9 c4 00 00 00       	jmp    1019d4 <idt_init+0xd6>
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101913:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  10191a:	0f b7 d0             	movzwl %ax,%edx
  10191d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101920:	66 89 14 c5 00 01 11 	mov    %dx,0x110100(,%eax,8)
  101927:	00 
  101928:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192b:	66 c7 04 c5 02 01 11 	movw   $0x8,0x110102(,%eax,8)
  101932:	00 08 00 
  101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101938:	0f b6 14 c5 04 01 11 	movzbl 0x110104(,%eax,8),%edx
  10193f:	00 
  101940:	80 e2 e0             	and    $0xe0,%dl
  101943:	88 14 c5 04 01 11 00 	mov    %dl,0x110104(,%eax,8)
  10194a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194d:	0f b6 14 c5 04 01 11 	movzbl 0x110104(,%eax,8),%edx
  101954:	00 
  101955:	80 e2 1f             	and    $0x1f,%dl
  101958:	88 14 c5 04 01 11 00 	mov    %dl,0x110104(,%eax,8)
  10195f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101962:	0f b6 14 c5 05 01 11 	movzbl 0x110105(,%eax,8),%edx
  101969:	00 
  10196a:	80 e2 f0             	and    $0xf0,%dl
  10196d:	80 ca 0e             	or     $0xe,%dl
  101970:	88 14 c5 05 01 11 00 	mov    %dl,0x110105(,%eax,8)
  101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197a:	0f b6 14 c5 05 01 11 	movzbl 0x110105(,%eax,8),%edx
  101981:	00 
  101982:	80 e2 ef             	and    $0xef,%dl
  101985:	88 14 c5 05 01 11 00 	mov    %dl,0x110105(,%eax,8)
  10198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198f:	0f b6 14 c5 05 01 11 	movzbl 0x110105(,%eax,8),%edx
  101996:	00 
  101997:	80 e2 9f             	and    $0x9f,%dl
  10199a:	88 14 c5 05 01 11 00 	mov    %dl,0x110105(,%eax,8)
  1019a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a4:	0f b6 14 c5 05 01 11 	movzbl 0x110105(,%eax,8),%edx
  1019ab:	00 
  1019ac:	80 ca 80             	or     $0x80,%dl
  1019af:	88 14 c5 05 01 11 00 	mov    %dl,0x110105(,%eax,8)
  1019b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b9:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1019c0:	c1 e8 10             	shr    $0x10,%eax
  1019c3:	0f b7 d0             	movzwl %ax,%edx
  1019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c9:	66 89 14 c5 06 01 11 	mov    %dx,0x110106(,%eax,8)
  1019d0:	00 
    for(i=0;i<sizeof(idt)/sizeof(struct gatedesc);i++){
  1019d1:	ff 45 fc             	incl   -0x4(%ebp)
  1019d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019dc:	0f 86 2e ff ff ff    	jbe    101910 <idt_init+0x12>
    }
    SETGATE(idt[T_SYSCALL],1,KERNEL_CS,__vectors[T_SYSCALL],DPL_USER);
  1019e2:	a1 e0 f7 10 00       	mov    0x10f7e0,%eax
  1019e7:	0f b7 c0             	movzwl %ax,%eax
  1019ea:	66 a3 00 05 11 00    	mov    %ax,0x110500
  1019f0:	66 c7 05 02 05 11 00 	movw   $0x8,0x110502
  1019f7:	08 00 
  1019f9:	0f b6 05 04 05 11 00 	movzbl 0x110504,%eax
  101a00:	24 e0                	and    $0xe0,%al
  101a02:	a2 04 05 11 00       	mov    %al,0x110504
  101a07:	0f b6 05 04 05 11 00 	movzbl 0x110504,%eax
  101a0e:	24 1f                	and    $0x1f,%al
  101a10:	a2 04 05 11 00       	mov    %al,0x110504
  101a15:	0f b6 05 05 05 11 00 	movzbl 0x110505,%eax
  101a1c:	0c 0f                	or     $0xf,%al
  101a1e:	a2 05 05 11 00       	mov    %al,0x110505
  101a23:	0f b6 05 05 05 11 00 	movzbl 0x110505,%eax
  101a2a:	24 ef                	and    $0xef,%al
  101a2c:	a2 05 05 11 00       	mov    %al,0x110505
  101a31:	0f b6 05 05 05 11 00 	movzbl 0x110505,%eax
  101a38:	0c 60                	or     $0x60,%al
  101a3a:	a2 05 05 11 00       	mov    %al,0x110505
  101a3f:	0f b6 05 05 05 11 00 	movzbl 0x110505,%eax
  101a46:	0c 80                	or     $0x80,%al
  101a48:	a2 05 05 11 00       	mov    %al,0x110505
  101a4d:	a1 e0 f7 10 00       	mov    0x10f7e0,%eax
  101a52:	c1 e8 10             	shr    $0x10,%eax
  101a55:	0f b7 c0             	movzwl %ax,%eax
  101a58:	66 a3 06 05 11 00    	mov    %ax,0x110506
    SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
  101a5e:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101a63:	0f b7 c0             	movzwl %ax,%eax
  101a66:	66 a3 c8 04 11 00    	mov    %ax,0x1104c8
  101a6c:	66 c7 05 ca 04 11 00 	movw   $0x8,0x1104ca
  101a73:	08 00 
  101a75:	0f b6 05 cc 04 11 00 	movzbl 0x1104cc,%eax
  101a7c:	24 e0                	and    $0xe0,%al
  101a7e:	a2 cc 04 11 00       	mov    %al,0x1104cc
  101a83:	0f b6 05 cc 04 11 00 	movzbl 0x1104cc,%eax
  101a8a:	24 1f                	and    $0x1f,%al
  101a8c:	a2 cc 04 11 00       	mov    %al,0x1104cc
  101a91:	0f b6 05 cd 04 11 00 	movzbl 0x1104cd,%eax
  101a98:	24 f0                	and    $0xf0,%al
  101a9a:	0c 0e                	or     $0xe,%al
  101a9c:	a2 cd 04 11 00       	mov    %al,0x1104cd
  101aa1:	0f b6 05 cd 04 11 00 	movzbl 0x1104cd,%eax
  101aa8:	24 ef                	and    $0xef,%al
  101aaa:	a2 cd 04 11 00       	mov    %al,0x1104cd
  101aaf:	0f b6 05 cd 04 11 00 	movzbl 0x1104cd,%eax
  101ab6:	0c 60                	or     $0x60,%al
  101ab8:	a2 cd 04 11 00       	mov    %al,0x1104cd
  101abd:	0f b6 05 cd 04 11 00 	movzbl 0x1104cd,%eax
  101ac4:	0c 80                	or     $0x80,%al
  101ac6:	a2 cd 04 11 00       	mov    %al,0x1104cd
  101acb:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101ad0:	c1 e8 10             	shr    $0x10,%eax
  101ad3:	0f b7 c0             	movzwl %ax,%eax
  101ad6:	66 a3 ce 04 11 00    	mov    %ax,0x1104ce
  101adc:	c7 45 f8 60 f5 10 00 	movl   $0x10f560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101ae3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101ae6:	0f 01 18             	lidtl  (%eax)
}
  101ae9:	90                   	nop
    
    //建立好中断门描述符表后，通过指令lidt把中断门描述符表的起始地址装入IDTR寄存器中，从而完成中段描述符表的初始化工作。
    lidt(&idt_pd);
}
  101aea:	90                   	nop
  101aeb:	89 ec                	mov    %ebp,%esp
  101aed:	5d                   	pop    %ebp
  101aee:	c3                   	ret    

00101aef <trapname>:

static const char *
trapname(int trapno) {
  101aef:	55                   	push   %ebp
  101af0:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101af2:	8b 45 08             	mov    0x8(%ebp),%eax
  101af5:	83 f8 13             	cmp    $0x13,%eax
  101af8:	77 0c                	ja     101b06 <trapname+0x17>
        return excnames[trapno];
  101afa:	8b 45 08             	mov    0x8(%ebp),%eax
  101afd:	8b 04 85 60 3f 10 00 	mov    0x103f60(,%eax,4),%eax
  101b04:	eb 18                	jmp    101b1e <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101b06:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101b0a:	7e 0d                	jle    101b19 <trapname+0x2a>
  101b0c:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101b10:	7f 07                	jg     101b19 <trapname+0x2a>
        return "Hardware Interrupt";
  101b12:	b8 1f 3c 10 00       	mov    $0x103c1f,%eax
  101b17:	eb 05                	jmp    101b1e <trapname+0x2f>
    }
    return "(unknown trap)";
  101b19:	b8 32 3c 10 00       	mov    $0x103c32,%eax
}
  101b1e:	5d                   	pop    %ebp
  101b1f:	c3                   	ret    

00101b20 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b20:	55                   	push   %ebp
  101b21:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b23:	8b 45 08             	mov    0x8(%ebp),%eax
  101b26:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b2a:	83 f8 08             	cmp    $0x8,%eax
  101b2d:	0f 94 c0             	sete   %al
  101b30:	0f b6 c0             	movzbl %al,%eax
}
  101b33:	5d                   	pop    %ebp
  101b34:	c3                   	ret    

00101b35 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b35:	55                   	push   %ebp
  101b36:	89 e5                	mov    %esp,%ebp
  101b38:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b42:	c7 04 24 73 3c 10 00 	movl   $0x103c73,(%esp)
  101b49:	e8 17 e8 ff ff       	call   100365 <cprintf>
    print_regs(&tf->tf_regs);
  101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b51:	89 04 24             	mov    %eax,(%esp)
  101b54:	e8 8f 01 00 00       	call   101ce8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b59:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b64:	c7 04 24 84 3c 10 00 	movl   $0x103c84,(%esp)
  101b6b:	e8 f5 e7 ff ff       	call   100365 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b70:	8b 45 08             	mov    0x8(%ebp),%eax
  101b73:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7b:	c7 04 24 97 3c 10 00 	movl   $0x103c97,(%esp)
  101b82:	e8 de e7 ff ff       	call   100365 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b87:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8a:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b92:	c7 04 24 aa 3c 10 00 	movl   $0x103caa,(%esp)
  101b99:	e8 c7 e7 ff ff       	call   100365 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba1:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba9:	c7 04 24 bd 3c 10 00 	movl   $0x103cbd,(%esp)
  101bb0:	e8 b0 e7 ff ff       	call   100365 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb8:	8b 40 30             	mov    0x30(%eax),%eax
  101bbb:	89 04 24             	mov    %eax,(%esp)
  101bbe:	e8 2c ff ff ff       	call   101aef <trapname>
  101bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  101bc6:	8b 52 30             	mov    0x30(%edx),%edx
  101bc9:	89 44 24 08          	mov    %eax,0x8(%esp)
  101bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  101bd1:	c7 04 24 d0 3c 10 00 	movl   $0x103cd0,(%esp)
  101bd8:	e8 88 e7 ff ff       	call   100365 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  101be0:	8b 40 34             	mov    0x34(%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 e2 3c 10 00 	movl   $0x103ce2,(%esp)
  101bee:	e8 72 e7 ff ff       	call   100365 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 38             	mov    0x38(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 f1 3c 10 00 	movl   $0x103cf1,(%esp)
  101c04:	e8 5c e7 ff ff       	call   100365 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c14:	c7 04 24 00 3d 10 00 	movl   $0x103d00,(%esp)
  101c1b:	e8 45 e7 ff ff       	call   100365 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c20:	8b 45 08             	mov    0x8(%ebp),%eax
  101c23:	8b 40 40             	mov    0x40(%eax),%eax
  101c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2a:	c7 04 24 13 3d 10 00 	movl   $0x103d13,(%esp)
  101c31:	e8 2f e7 ff ff       	call   100365 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c3d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c44:	eb 3d                	jmp    101c83 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c46:	8b 45 08             	mov    0x8(%ebp),%eax
  101c49:	8b 50 40             	mov    0x40(%eax),%edx
  101c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c4f:	21 d0                	and    %edx,%eax
  101c51:	85 c0                	test   %eax,%eax
  101c53:	74 28                	je     101c7d <print_trapframe+0x148>
  101c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c58:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c5f:	85 c0                	test   %eax,%eax
  101c61:	74 1a                	je     101c7d <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c66:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c71:	c7 04 24 22 3d 10 00 	movl   $0x103d22,(%esp)
  101c78:	e8 e8 e6 ff ff       	call   100365 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c7d:	ff 45 f4             	incl   -0xc(%ebp)
  101c80:	d1 65 f0             	shll   -0x10(%ebp)
  101c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c86:	83 f8 17             	cmp    $0x17,%eax
  101c89:	76 bb                	jbe    101c46 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8e:	8b 40 40             	mov    0x40(%eax),%eax
  101c91:	c1 e8 0c             	shr    $0xc,%eax
  101c94:	83 e0 03             	and    $0x3,%eax
  101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9b:	c7 04 24 26 3d 10 00 	movl   $0x103d26,(%esp)
  101ca2:	e8 be e6 ff ff       	call   100365 <cprintf>

    if (!trap_in_kernel(tf)) {
  101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  101caa:	89 04 24             	mov    %eax,(%esp)
  101cad:	e8 6e fe ff ff       	call   101b20 <trap_in_kernel>
  101cb2:	85 c0                	test   %eax,%eax
  101cb4:	75 2d                	jne    101ce3 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb9:	8b 40 44             	mov    0x44(%eax),%eax
  101cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc0:	c7 04 24 2f 3d 10 00 	movl   $0x103d2f,(%esp)
  101cc7:	e8 99 e6 ff ff       	call   100365 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd7:	c7 04 24 3e 3d 10 00 	movl   $0x103d3e,(%esp)
  101cde:	e8 82 e6 ff ff       	call   100365 <cprintf>
    }
}
  101ce3:	90                   	nop
  101ce4:	89 ec                	mov    %ebp,%esp
  101ce6:	5d                   	pop    %ebp
  101ce7:	c3                   	ret    

00101ce8 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ce8:	55                   	push   %ebp
  101ce9:	89 e5                	mov    %esp,%ebp
  101ceb:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cee:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf1:	8b 00                	mov    (%eax),%eax
  101cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf7:	c7 04 24 51 3d 10 00 	movl   $0x103d51,(%esp)
  101cfe:	e8 62 e6 ff ff       	call   100365 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101d03:	8b 45 08             	mov    0x8(%ebp),%eax
  101d06:	8b 40 04             	mov    0x4(%eax),%eax
  101d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0d:	c7 04 24 60 3d 10 00 	movl   $0x103d60,(%esp)
  101d14:	e8 4c e6 ff ff       	call   100365 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d19:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1c:	8b 40 08             	mov    0x8(%eax),%eax
  101d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d23:	c7 04 24 6f 3d 10 00 	movl   $0x103d6f,(%esp)
  101d2a:	e8 36 e6 ff ff       	call   100365 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d32:	8b 40 0c             	mov    0xc(%eax),%eax
  101d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d39:	c7 04 24 7e 3d 10 00 	movl   $0x103d7e,(%esp)
  101d40:	e8 20 e6 ff ff       	call   100365 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d45:	8b 45 08             	mov    0x8(%ebp),%eax
  101d48:	8b 40 10             	mov    0x10(%eax),%eax
  101d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d4f:	c7 04 24 8d 3d 10 00 	movl   $0x103d8d,(%esp)
  101d56:	e8 0a e6 ff ff       	call   100365 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5e:	8b 40 14             	mov    0x14(%eax),%eax
  101d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d65:	c7 04 24 9c 3d 10 00 	movl   $0x103d9c,(%esp)
  101d6c:	e8 f4 e5 ff ff       	call   100365 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d71:	8b 45 08             	mov    0x8(%ebp),%eax
  101d74:	8b 40 18             	mov    0x18(%eax),%eax
  101d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d7b:	c7 04 24 ab 3d 10 00 	movl   $0x103dab,(%esp)
  101d82:	e8 de e5 ff ff       	call   100365 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d87:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8a:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d91:	c7 04 24 ba 3d 10 00 	movl   $0x103dba,(%esp)
  101d98:	e8 c8 e5 ff ff       	call   100365 <cprintf>
}
  101d9d:	90                   	nop
  101d9e:	89 ec                	mov    %ebp,%esp
  101da0:	5d                   	pop    %ebp
  101da1:	c3                   	ret    

00101da2 <trap_dispatch>:



/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101da2:	55                   	push   %ebp
  101da3:	89 e5                	mov    %esp,%ebp
  101da5:	83 ec 38             	sub    $0x38,%esp
  101da8:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
  101dab:	8b 45 08             	mov    0x8(%ebp),%eax
  101dae:	8b 40 30             	mov    0x30(%eax),%eax
  101db1:	83 f8 79             	cmp    $0x79,%eax
  101db4:	0f 84 ca 02 00 00    	je     102084 <trap_dispatch+0x2e2>
  101dba:	83 f8 79             	cmp    $0x79,%eax
  101dbd:	0f 87 41 03 00 00    	ja     102104 <trap_dispatch+0x362>
  101dc3:	83 f8 78             	cmp    $0x78,%eax
  101dc6:	0f 84 2b 02 00 00    	je     101ff7 <trap_dispatch+0x255>
  101dcc:	83 f8 78             	cmp    $0x78,%eax
  101dcf:	0f 87 2f 03 00 00    	ja     102104 <trap_dispatch+0x362>
  101dd5:	83 f8 2f             	cmp    $0x2f,%eax
  101dd8:	0f 87 26 03 00 00    	ja     102104 <trap_dispatch+0x362>
  101dde:	83 f8 2e             	cmp    $0x2e,%eax
  101de1:	0f 83 52 03 00 00    	jae    102139 <trap_dispatch+0x397>
  101de7:	83 f8 24             	cmp    $0x24,%eax
  101dea:	74 5e                	je     101e4a <trap_dispatch+0xa8>
  101dec:	83 f8 24             	cmp    $0x24,%eax
  101def:	0f 87 0f 03 00 00    	ja     102104 <trap_dispatch+0x362>
  101df5:	83 f8 20             	cmp    $0x20,%eax
  101df8:	74 0a                	je     101e04 <trap_dispatch+0x62>
  101dfa:	83 f8 21             	cmp    $0x21,%eax
  101dfd:	74 74                	je     101e73 <trap_dispatch+0xd1>
  101dff:	e9 00 03 00 00       	jmp    102104 <trap_dispatch+0x362>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101e04:	a1 44 fe 10 00       	mov    0x10fe44,%eax
  101e09:	40                   	inc    %eax
  101e0a:	a3 44 fe 10 00       	mov    %eax,0x10fe44
        if(ticks%100==0){
  101e0f:	8b 0d 44 fe 10 00    	mov    0x10fe44,%ecx
  101e15:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e1a:	89 c8                	mov    %ecx,%eax
  101e1c:	f7 e2                	mul    %edx
  101e1e:	c1 ea 05             	shr    $0x5,%edx
  101e21:	89 d0                	mov    %edx,%eax
  101e23:	c1 e0 02             	shl    $0x2,%eax
  101e26:	01 d0                	add    %edx,%eax
  101e28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e2f:	01 d0                	add    %edx,%eax
  101e31:	c1 e0 02             	shl    $0x2,%eax
  101e34:	29 c1                	sub    %eax,%ecx
  101e36:	89 ca                	mov    %ecx,%edx
  101e38:	85 d2                	test   %edx,%edx
  101e3a:	0f 85 fc 02 00 00    	jne    10213c <trap_dispatch+0x39a>
            print_ticks();
  101e40:	e8 77 fa ff ff       	call   1018bc <print_ticks>
        }
        break;
  101e45:	e9 f2 02 00 00       	jmp    10213c <trap_dispatch+0x39a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e4a:	e8 23 f8 ff ff       	call   101672 <cons_getc>
  101e4f:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e52:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e56:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e5a:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e62:	c7 04 24 c9 3d 10 00 	movl   $0x103dc9,(%esp)
  101e69:	e8 f7 e4 ff ff       	call   100365 <cprintf>
        break;
  101e6e:	e9 cd 02 00 00       	jmp    102140 <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e73:	e8 fa f7 ff ff       	call   101672 <cons_getc>
  101e78:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e7b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e7f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e83:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e87:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e8b:	c7 04 24 db 3d 10 00 	movl   $0x103ddb,(%esp)
  101e92:	e8 ce e4 ff ff       	call   100365 <cprintf>
         if (c == '0'&&!trap_in_kernel(tf)) {
  101e97:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101e9b:	0f 85 a1 00 00 00    	jne    101f42 <trap_dispatch+0x1a0>
  101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea4:	89 04 24             	mov    %eax,(%esp)
  101ea7:	e8 74 fc ff ff       	call   101b20 <trap_in_kernel>
  101eac:	85 c0                	test   %eax,%eax
  101eae:	0f 85 8e 00 00 00    	jne    101f42 <trap_dispatch+0x1a0>
  101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
  101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ebd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ec1:	83 f8 08             	cmp    $0x8,%eax
  101ec4:	74 6b                	je     101f31 <trap_dispatch+0x18f>
        tf->tf_cs = KERNEL_CS;
  101ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ec9:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  101ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ed2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101edb:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ee2:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  101ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ee9:	8b 40 40             	mov    0x40(%eax),%eax
  101eec:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101ef1:	89 c2                	mov    %eax,%edx
  101ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ef6:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101efc:	8b 40 44             	mov    0x44(%eax),%eax
  101eff:	83 e8 44             	sub    $0x44,%eax
  101f02:	a3 ec 00 11 00       	mov    %eax,0x1100ec
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101f07:	a1 ec 00 11 00       	mov    0x1100ec,%eax
  101f0c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101f13:	00 
  101f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101f17:	89 54 24 04          	mov    %edx,0x4(%esp)
  101f1b:	89 04 24             	mov    %eax,(%esp)
  101f1e:	e8 ec 17 00 00       	call   10370f <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101f23:	8b 15 ec 00 11 00    	mov    0x1100ec,%edx
  101f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101f2c:	83 e8 04             	sub    $0x4,%eax
  101f2f:	89 10                	mov    %edx,(%eax)
}
  101f31:	90                   	nop
        //切换为内核态
        switch_to_kernel(tf);
        print_trapframe(tf);
  101f32:	8b 45 08             	mov    0x8(%ebp),%eax
  101f35:	89 04 24             	mov    %eax,(%esp)
  101f38:	e8 f8 fb ff ff       	call   101b35 <print_trapframe>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
        //切换为用户态
        switch_to_user(tf);
        print_trapframe(tf);
        }
        break;
  101f3d:	e9 fd 01 00 00       	jmp    10213f <trap_dispatch+0x39d>
        } else if (c == '3'&&(trap_in_kernel(tf))) {
  101f42:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101f46:	0f 85 f3 01 00 00    	jne    10213f <trap_dispatch+0x39d>
  101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101f4f:	89 04 24             	mov    %eax,(%esp)
  101f52:	e8 c9 fb ff ff       	call   101b20 <trap_in_kernel>
  101f57:	85 c0                	test   %eax,%eax
  101f59:	0f 84 e0 01 00 00    	je     10213f <trap_dispatch+0x39d>
  101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f62:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (tf->tf_cs != USER_CS) {
  101f65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101f68:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f6c:	83 f8 1b             	cmp    $0x1b,%eax
  101f6f:	74 75                	je     101fe6 <trap_dispatch+0x244>
        switchk2u = *tf;
  101f71:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  101f74:	b8 4c 00 00 00       	mov    $0x4c,%eax
  101f79:	83 e0 fc             	and    $0xfffffffc,%eax
  101f7c:	89 c3                	mov    %eax,%ebx
  101f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  101f83:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  101f86:	89 90 a0 00 11 00    	mov    %edx,0x1100a0(%eax)
  101f8c:	83 c0 04             	add    $0x4,%eax
  101f8f:	39 d8                	cmp    %ebx,%eax
  101f91:	72 f0                	jb     101f83 <trap_dispatch+0x1e1>
        switchk2u.tf_cs = USER_CS;
  101f93:	66 c7 05 dc 00 11 00 	movw   $0x1b,0x1100dc
  101f9a:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101f9c:	66 c7 05 e8 00 11 00 	movw   $0x23,0x1100e8
  101fa3:	23 00 
  101fa5:	0f b7 05 e8 00 11 00 	movzwl 0x1100e8,%eax
  101fac:	66 a3 c8 00 11 00    	mov    %ax,0x1100c8
  101fb2:	0f b7 05 c8 00 11 00 	movzwl 0x1100c8,%eax
  101fb9:	66 a3 cc 00 11 00    	mov    %ax,0x1100cc
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
  101fbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fc2:	83 c0 4c             	add    $0x4c,%eax
  101fc5:	a3 e4 00 11 00       	mov    %eax,0x1100e4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
  101fca:	a1 e0 00 11 00       	mov    0x1100e0,%eax
  101fcf:	0d 00 30 00 00       	or     $0x3000,%eax
  101fd4:	a3 e0 00 11 00       	mov    %eax,0x1100e0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fdc:	83 e8 04             	sub    $0x4,%eax
  101fdf:	ba a0 00 11 00       	mov    $0x1100a0,%edx
  101fe4:	89 10                	mov    %edx,(%eax)
}
  101fe6:	90                   	nop
        print_trapframe(tf);
  101fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  101fea:	89 04 24             	mov    %eax,(%esp)
  101fed:	e8 43 fb ff ff       	call   101b35 <print_trapframe>
        break;
  101ff2:	e9 48 01 00 00       	jmp    10213f <trap_dispatch+0x39d>
  101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  101ffa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (tf->tf_cs != USER_CS) {
  101ffd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102000:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102004:	83 f8 1b             	cmp    $0x1b,%eax
  102007:	74 75                	je     10207e <trap_dispatch+0x2dc>
        switchk2u = *tf;
  102009:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10200c:	b8 4c 00 00 00       	mov    $0x4c,%eax
  102011:	83 e0 fc             	and    $0xfffffffc,%eax
  102014:	89 c3                	mov    %eax,%ebx
  102016:	b8 00 00 00 00       	mov    $0x0,%eax
  10201b:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  10201e:	89 90 a0 00 11 00    	mov    %edx,0x1100a0(%eax)
  102024:	83 c0 04             	add    $0x4,%eax
  102027:	39 d8                	cmp    %ebx,%eax
  102029:	72 f0                	jb     10201b <trap_dispatch+0x279>
        switchk2u.tf_cs = USER_CS;
  10202b:	66 c7 05 dc 00 11 00 	movw   $0x1b,0x1100dc
  102032:	1b 00 
        switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  102034:	66 c7 05 e8 00 11 00 	movw   $0x23,0x1100e8
  10203b:	23 00 
  10203d:	0f b7 05 e8 00 11 00 	movzwl 0x1100e8,%eax
  102044:	66 a3 c8 00 11 00    	mov    %ax,0x1100c8
  10204a:	0f b7 05 c8 00 11 00 	movzwl 0x1100c8,%eax
  102051:	66 a3 cc 00 11 00    	mov    %ax,0x1100cc
        switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe);
  102057:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10205a:	83 c0 4c             	add    $0x4c,%eax
  10205d:	a3 e4 00 11 00       	mov    %eax,0x1100e4
        switchk2u.tf_eflags |= FL_IOPL_MASK;
  102062:	a1 e0 00 11 00       	mov    0x1100e0,%eax
  102067:	0d 00 30 00 00       	or     $0x3000,%eax
  10206c:	a3 e0 00 11 00       	mov    %eax,0x1100e0
        *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  102071:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102074:	83 e8 04             	sub    $0x4,%eax
  102077:	ba a0 00 11 00       	mov    $0x1100a0,%edx
  10207c:	89 10                	mov    %edx,(%eax)
}
  10207e:	90                   	nop
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            tf->tf_eflags |= FL_IOPL_MASK;
        }*/
        switch_to_user(tf);
        break;
  10207f:	e9 bc 00 00 00       	jmp    102140 <trap_dispatch+0x39e>
  102084:	8b 45 08             	mov    0x8(%ebp),%eax
  102087:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (tf->tf_cs != KERNEL_CS) {
  10208a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10208d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102091:	83 f8 08             	cmp    $0x8,%eax
  102094:	74 6b                	je     102101 <trap_dispatch+0x35f>
        tf->tf_cs = KERNEL_CS;
  102096:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102099:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  10209f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020a2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  1020a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020ab:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  1020af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020b2:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  1020b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020b9:	8b 40 40             	mov    0x40(%eax),%eax
  1020bc:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  1020c1:	89 c2                	mov    %eax,%edx
  1020c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020c6:	89 50 40             	mov    %edx,0x40(%eax)
        switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  1020c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020cc:	8b 40 44             	mov    0x44(%eax),%eax
  1020cf:	83 e8 44             	sub    $0x44,%eax
  1020d2:	a3 ec 00 11 00       	mov    %eax,0x1100ec
        memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  1020d7:	a1 ec 00 11 00       	mov    0x1100ec,%eax
  1020dc:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  1020e3:	00 
  1020e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1020e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1020eb:	89 04 24             	mov    %eax,(%esp)
  1020ee:	e8 1c 16 00 00       	call   10370f <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  1020f3:	8b 15 ec 00 11 00    	mov    0x1100ec,%edx
  1020f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1020fc:	83 e8 04             	sub    $0x4,%eax
  1020ff:	89 10                	mov    %edx,(%eax)
}
  102101:	90                   	nop
            tf->tf_cs = KERNEL_CS;
            tf->tf_ds = tf->tf_es = KERNEL_DS;
            tf->tf_eflags &= ~FL_IOPL_MASK;
        }*/
        switch_to_kernel(tf);
        break;
  102102:	eb 3c                	jmp    102140 <trap_dispatch+0x39e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102104:	8b 45 08             	mov    0x8(%ebp),%eax
  102107:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10210b:	83 e0 03             	and    $0x3,%eax
  10210e:	85 c0                	test   %eax,%eax
  102110:	75 2e                	jne    102140 <trap_dispatch+0x39e>
            print_trapframe(tf);
  102112:	8b 45 08             	mov    0x8(%ebp),%eax
  102115:	89 04 24             	mov    %eax,(%esp)
  102118:	e8 18 fa ff ff       	call   101b35 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  10211d:	c7 44 24 08 ea 3d 10 	movl   $0x103dea,0x8(%esp)
  102124:	00 
  102125:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  10212c:	00 
  10212d:	c7 04 24 0e 3c 10 00 	movl   $0x103c0e,(%esp)
  102134:	e8 ae eb ff ff       	call   100ce7 <__panic>
        break;
  102139:	90                   	nop
  10213a:	eb 04                	jmp    102140 <trap_dispatch+0x39e>
        break;
  10213c:	90                   	nop
  10213d:	eb 01                	jmp    102140 <trap_dispatch+0x39e>
        break;
  10213f:	90                   	nop
        }
    }
}
  102140:	90                   	nop
  102141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  102144:	89 ec                	mov    %ebp,%esp
  102146:	5d                   	pop    %ebp
  102147:	c3                   	ret    

00102148 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  102148:	55                   	push   %ebp
  102149:	89 e5                	mov    %esp,%ebp
  10214b:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  10214e:	8b 45 08             	mov    0x8(%ebp),%eax
  102151:	89 04 24             	mov    %eax,(%esp)
  102154:	e8 49 fc ff ff       	call   101da2 <trap_dispatch>
}
  102159:	90                   	nop
  10215a:	89 ec                	mov    %ebp,%esp
  10215c:	5d                   	pop    %ebp
  10215d:	c3                   	ret    

0010215e <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  10215e:	1e                   	push   %ds
    pushl %es
  10215f:	06                   	push   %es
    pushl %fs
  102160:	0f a0                	push   %fs
    pushl %gs
  102162:	0f a8                	push   %gs
    pushal
  102164:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102165:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10216a:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10216c:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10216e:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10216f:	e8 d4 ff ff ff       	call   102148 <trap>

    # pop the pushed stack pointer
    popl %esp
  102174:	5c                   	pop    %esp

00102175 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102175:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102176:	0f a9                	pop    %gs
    popl %fs
  102178:	0f a1                	pop    %fs
    popl %es
  10217a:	07                   	pop    %es
    popl %ds
  10217b:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10217c:	83 c4 08             	add    $0x8,%esp
    iret
  10217f:	cf                   	iret   

00102180 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  102180:	6a 00                	push   $0x0
  pushl $0
  102182:	6a 00                	push   $0x0
  jmp __alltraps
  102184:	e9 d5 ff ff ff       	jmp    10215e <__alltraps>

00102189 <vector1>:
.globl vector1
vector1:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $1
  10218b:	6a 01                	push   $0x1
  jmp __alltraps
  10218d:	e9 cc ff ff ff       	jmp    10215e <__alltraps>

00102192 <vector2>:
.globl vector2
vector2:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $2
  102194:	6a 02                	push   $0x2
  jmp __alltraps
  102196:	e9 c3 ff ff ff       	jmp    10215e <__alltraps>

0010219b <vector3>:
.globl vector3
vector3:
  pushl $0
  10219b:	6a 00                	push   $0x0
  pushl $3
  10219d:	6a 03                	push   $0x3
  jmp __alltraps
  10219f:	e9 ba ff ff ff       	jmp    10215e <__alltraps>

001021a4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1021a4:	6a 00                	push   $0x0
  pushl $4
  1021a6:	6a 04                	push   $0x4
  jmp __alltraps
  1021a8:	e9 b1 ff ff ff       	jmp    10215e <__alltraps>

001021ad <vector5>:
.globl vector5
vector5:
  pushl $0
  1021ad:	6a 00                	push   $0x0
  pushl $5
  1021af:	6a 05                	push   $0x5
  jmp __alltraps
  1021b1:	e9 a8 ff ff ff       	jmp    10215e <__alltraps>

001021b6 <vector6>:
.globl vector6
vector6:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $6
  1021b8:	6a 06                	push   $0x6
  jmp __alltraps
  1021ba:	e9 9f ff ff ff       	jmp    10215e <__alltraps>

001021bf <vector7>:
.globl vector7
vector7:
  pushl $0
  1021bf:	6a 00                	push   $0x0
  pushl $7
  1021c1:	6a 07                	push   $0x7
  jmp __alltraps
  1021c3:	e9 96 ff ff ff       	jmp    10215e <__alltraps>

001021c8 <vector8>:
.globl vector8
vector8:
  pushl $8
  1021c8:	6a 08                	push   $0x8
  jmp __alltraps
  1021ca:	e9 8f ff ff ff       	jmp    10215e <__alltraps>

001021cf <vector9>:
.globl vector9
vector9:
  pushl $0
  1021cf:	6a 00                	push   $0x0
  pushl $9
  1021d1:	6a 09                	push   $0x9
  jmp __alltraps
  1021d3:	e9 86 ff ff ff       	jmp    10215e <__alltraps>

001021d8 <vector10>:
.globl vector10
vector10:
  pushl $10
  1021d8:	6a 0a                	push   $0xa
  jmp __alltraps
  1021da:	e9 7f ff ff ff       	jmp    10215e <__alltraps>

001021df <vector11>:
.globl vector11
vector11:
  pushl $11
  1021df:	6a 0b                	push   $0xb
  jmp __alltraps
  1021e1:	e9 78 ff ff ff       	jmp    10215e <__alltraps>

001021e6 <vector12>:
.globl vector12
vector12:
  pushl $12
  1021e6:	6a 0c                	push   $0xc
  jmp __alltraps
  1021e8:	e9 71 ff ff ff       	jmp    10215e <__alltraps>

001021ed <vector13>:
.globl vector13
vector13:
  pushl $13
  1021ed:	6a 0d                	push   $0xd
  jmp __alltraps
  1021ef:	e9 6a ff ff ff       	jmp    10215e <__alltraps>

001021f4 <vector14>:
.globl vector14
vector14:
  pushl $14
  1021f4:	6a 0e                	push   $0xe
  jmp __alltraps
  1021f6:	e9 63 ff ff ff       	jmp    10215e <__alltraps>

001021fb <vector15>:
.globl vector15
vector15:
  pushl $0
  1021fb:	6a 00                	push   $0x0
  pushl $15
  1021fd:	6a 0f                	push   $0xf
  jmp __alltraps
  1021ff:	e9 5a ff ff ff       	jmp    10215e <__alltraps>

00102204 <vector16>:
.globl vector16
vector16:
  pushl $0
  102204:	6a 00                	push   $0x0
  pushl $16
  102206:	6a 10                	push   $0x10
  jmp __alltraps
  102208:	e9 51 ff ff ff       	jmp    10215e <__alltraps>

0010220d <vector17>:
.globl vector17
vector17:
  pushl $17
  10220d:	6a 11                	push   $0x11
  jmp __alltraps
  10220f:	e9 4a ff ff ff       	jmp    10215e <__alltraps>

00102214 <vector18>:
.globl vector18
vector18:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $18
  102216:	6a 12                	push   $0x12
  jmp __alltraps
  102218:	e9 41 ff ff ff       	jmp    10215e <__alltraps>

0010221d <vector19>:
.globl vector19
vector19:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $19
  10221f:	6a 13                	push   $0x13
  jmp __alltraps
  102221:	e9 38 ff ff ff       	jmp    10215e <__alltraps>

00102226 <vector20>:
.globl vector20
vector20:
  pushl $0
  102226:	6a 00                	push   $0x0
  pushl $20
  102228:	6a 14                	push   $0x14
  jmp __alltraps
  10222a:	e9 2f ff ff ff       	jmp    10215e <__alltraps>

0010222f <vector21>:
.globl vector21
vector21:
  pushl $0
  10222f:	6a 00                	push   $0x0
  pushl $21
  102231:	6a 15                	push   $0x15
  jmp __alltraps
  102233:	e9 26 ff ff ff       	jmp    10215e <__alltraps>

00102238 <vector22>:
.globl vector22
vector22:
  pushl $0
  102238:	6a 00                	push   $0x0
  pushl $22
  10223a:	6a 16                	push   $0x16
  jmp __alltraps
  10223c:	e9 1d ff ff ff       	jmp    10215e <__alltraps>

00102241 <vector23>:
.globl vector23
vector23:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $23
  102243:	6a 17                	push   $0x17
  jmp __alltraps
  102245:	e9 14 ff ff ff       	jmp    10215e <__alltraps>

0010224a <vector24>:
.globl vector24
vector24:
  pushl $0
  10224a:	6a 00                	push   $0x0
  pushl $24
  10224c:	6a 18                	push   $0x18
  jmp __alltraps
  10224e:	e9 0b ff ff ff       	jmp    10215e <__alltraps>

00102253 <vector25>:
.globl vector25
vector25:
  pushl $0
  102253:	6a 00                	push   $0x0
  pushl $25
  102255:	6a 19                	push   $0x19
  jmp __alltraps
  102257:	e9 02 ff ff ff       	jmp    10215e <__alltraps>

0010225c <vector26>:
.globl vector26
vector26:
  pushl $0
  10225c:	6a 00                	push   $0x0
  pushl $26
  10225e:	6a 1a                	push   $0x1a
  jmp __alltraps
  102260:	e9 f9 fe ff ff       	jmp    10215e <__alltraps>

00102265 <vector27>:
.globl vector27
vector27:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $27
  102267:	6a 1b                	push   $0x1b
  jmp __alltraps
  102269:	e9 f0 fe ff ff       	jmp    10215e <__alltraps>

0010226e <vector28>:
.globl vector28
vector28:
  pushl $0
  10226e:	6a 00                	push   $0x0
  pushl $28
  102270:	6a 1c                	push   $0x1c
  jmp __alltraps
  102272:	e9 e7 fe ff ff       	jmp    10215e <__alltraps>

00102277 <vector29>:
.globl vector29
vector29:
  pushl $0
  102277:	6a 00                	push   $0x0
  pushl $29
  102279:	6a 1d                	push   $0x1d
  jmp __alltraps
  10227b:	e9 de fe ff ff       	jmp    10215e <__alltraps>

00102280 <vector30>:
.globl vector30
vector30:
  pushl $0
  102280:	6a 00                	push   $0x0
  pushl $30
  102282:	6a 1e                	push   $0x1e
  jmp __alltraps
  102284:	e9 d5 fe ff ff       	jmp    10215e <__alltraps>

00102289 <vector31>:
.globl vector31
vector31:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $31
  10228b:	6a 1f                	push   $0x1f
  jmp __alltraps
  10228d:	e9 cc fe ff ff       	jmp    10215e <__alltraps>

00102292 <vector32>:
.globl vector32
vector32:
  pushl $0
  102292:	6a 00                	push   $0x0
  pushl $32
  102294:	6a 20                	push   $0x20
  jmp __alltraps
  102296:	e9 c3 fe ff ff       	jmp    10215e <__alltraps>

0010229b <vector33>:
.globl vector33
vector33:
  pushl $0
  10229b:	6a 00                	push   $0x0
  pushl $33
  10229d:	6a 21                	push   $0x21
  jmp __alltraps
  10229f:	e9 ba fe ff ff       	jmp    10215e <__alltraps>

001022a4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1022a4:	6a 00                	push   $0x0
  pushl $34
  1022a6:	6a 22                	push   $0x22
  jmp __alltraps
  1022a8:	e9 b1 fe ff ff       	jmp    10215e <__alltraps>

001022ad <vector35>:
.globl vector35
vector35:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $35
  1022af:	6a 23                	push   $0x23
  jmp __alltraps
  1022b1:	e9 a8 fe ff ff       	jmp    10215e <__alltraps>

001022b6 <vector36>:
.globl vector36
vector36:
  pushl $0
  1022b6:	6a 00                	push   $0x0
  pushl $36
  1022b8:	6a 24                	push   $0x24
  jmp __alltraps
  1022ba:	e9 9f fe ff ff       	jmp    10215e <__alltraps>

001022bf <vector37>:
.globl vector37
vector37:
  pushl $0
  1022bf:	6a 00                	push   $0x0
  pushl $37
  1022c1:	6a 25                	push   $0x25
  jmp __alltraps
  1022c3:	e9 96 fe ff ff       	jmp    10215e <__alltraps>

001022c8 <vector38>:
.globl vector38
vector38:
  pushl $0
  1022c8:	6a 00                	push   $0x0
  pushl $38
  1022ca:	6a 26                	push   $0x26
  jmp __alltraps
  1022cc:	e9 8d fe ff ff       	jmp    10215e <__alltraps>

001022d1 <vector39>:
.globl vector39
vector39:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $39
  1022d3:	6a 27                	push   $0x27
  jmp __alltraps
  1022d5:	e9 84 fe ff ff       	jmp    10215e <__alltraps>

001022da <vector40>:
.globl vector40
vector40:
  pushl $0
  1022da:	6a 00                	push   $0x0
  pushl $40
  1022dc:	6a 28                	push   $0x28
  jmp __alltraps
  1022de:	e9 7b fe ff ff       	jmp    10215e <__alltraps>

001022e3 <vector41>:
.globl vector41
vector41:
  pushl $0
  1022e3:	6a 00                	push   $0x0
  pushl $41
  1022e5:	6a 29                	push   $0x29
  jmp __alltraps
  1022e7:	e9 72 fe ff ff       	jmp    10215e <__alltraps>

001022ec <vector42>:
.globl vector42
vector42:
  pushl $0
  1022ec:	6a 00                	push   $0x0
  pushl $42
  1022ee:	6a 2a                	push   $0x2a
  jmp __alltraps
  1022f0:	e9 69 fe ff ff       	jmp    10215e <__alltraps>

001022f5 <vector43>:
.globl vector43
vector43:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $43
  1022f7:	6a 2b                	push   $0x2b
  jmp __alltraps
  1022f9:	e9 60 fe ff ff       	jmp    10215e <__alltraps>

001022fe <vector44>:
.globl vector44
vector44:
  pushl $0
  1022fe:	6a 00                	push   $0x0
  pushl $44
  102300:	6a 2c                	push   $0x2c
  jmp __alltraps
  102302:	e9 57 fe ff ff       	jmp    10215e <__alltraps>

00102307 <vector45>:
.globl vector45
vector45:
  pushl $0
  102307:	6a 00                	push   $0x0
  pushl $45
  102309:	6a 2d                	push   $0x2d
  jmp __alltraps
  10230b:	e9 4e fe ff ff       	jmp    10215e <__alltraps>

00102310 <vector46>:
.globl vector46
vector46:
  pushl $0
  102310:	6a 00                	push   $0x0
  pushl $46
  102312:	6a 2e                	push   $0x2e
  jmp __alltraps
  102314:	e9 45 fe ff ff       	jmp    10215e <__alltraps>

00102319 <vector47>:
.globl vector47
vector47:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $47
  10231b:	6a 2f                	push   $0x2f
  jmp __alltraps
  10231d:	e9 3c fe ff ff       	jmp    10215e <__alltraps>

00102322 <vector48>:
.globl vector48
vector48:
  pushl $0
  102322:	6a 00                	push   $0x0
  pushl $48
  102324:	6a 30                	push   $0x30
  jmp __alltraps
  102326:	e9 33 fe ff ff       	jmp    10215e <__alltraps>

0010232b <vector49>:
.globl vector49
vector49:
  pushl $0
  10232b:	6a 00                	push   $0x0
  pushl $49
  10232d:	6a 31                	push   $0x31
  jmp __alltraps
  10232f:	e9 2a fe ff ff       	jmp    10215e <__alltraps>

00102334 <vector50>:
.globl vector50
vector50:
  pushl $0
  102334:	6a 00                	push   $0x0
  pushl $50
  102336:	6a 32                	push   $0x32
  jmp __alltraps
  102338:	e9 21 fe ff ff       	jmp    10215e <__alltraps>

0010233d <vector51>:
.globl vector51
vector51:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $51
  10233f:	6a 33                	push   $0x33
  jmp __alltraps
  102341:	e9 18 fe ff ff       	jmp    10215e <__alltraps>

00102346 <vector52>:
.globl vector52
vector52:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $52
  102348:	6a 34                	push   $0x34
  jmp __alltraps
  10234a:	e9 0f fe ff ff       	jmp    10215e <__alltraps>

0010234f <vector53>:
.globl vector53
vector53:
  pushl $0
  10234f:	6a 00                	push   $0x0
  pushl $53
  102351:	6a 35                	push   $0x35
  jmp __alltraps
  102353:	e9 06 fe ff ff       	jmp    10215e <__alltraps>

00102358 <vector54>:
.globl vector54
vector54:
  pushl $0
  102358:	6a 00                	push   $0x0
  pushl $54
  10235a:	6a 36                	push   $0x36
  jmp __alltraps
  10235c:	e9 fd fd ff ff       	jmp    10215e <__alltraps>

00102361 <vector55>:
.globl vector55
vector55:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $55
  102363:	6a 37                	push   $0x37
  jmp __alltraps
  102365:	e9 f4 fd ff ff       	jmp    10215e <__alltraps>

0010236a <vector56>:
.globl vector56
vector56:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $56
  10236c:	6a 38                	push   $0x38
  jmp __alltraps
  10236e:	e9 eb fd ff ff       	jmp    10215e <__alltraps>

00102373 <vector57>:
.globl vector57
vector57:
  pushl $0
  102373:	6a 00                	push   $0x0
  pushl $57
  102375:	6a 39                	push   $0x39
  jmp __alltraps
  102377:	e9 e2 fd ff ff       	jmp    10215e <__alltraps>

0010237c <vector58>:
.globl vector58
vector58:
  pushl $0
  10237c:	6a 00                	push   $0x0
  pushl $58
  10237e:	6a 3a                	push   $0x3a
  jmp __alltraps
  102380:	e9 d9 fd ff ff       	jmp    10215e <__alltraps>

00102385 <vector59>:
.globl vector59
vector59:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $59
  102387:	6a 3b                	push   $0x3b
  jmp __alltraps
  102389:	e9 d0 fd ff ff       	jmp    10215e <__alltraps>

0010238e <vector60>:
.globl vector60
vector60:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $60
  102390:	6a 3c                	push   $0x3c
  jmp __alltraps
  102392:	e9 c7 fd ff ff       	jmp    10215e <__alltraps>

00102397 <vector61>:
.globl vector61
vector61:
  pushl $0
  102397:	6a 00                	push   $0x0
  pushl $61
  102399:	6a 3d                	push   $0x3d
  jmp __alltraps
  10239b:	e9 be fd ff ff       	jmp    10215e <__alltraps>

001023a0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1023a0:	6a 00                	push   $0x0
  pushl $62
  1023a2:	6a 3e                	push   $0x3e
  jmp __alltraps
  1023a4:	e9 b5 fd ff ff       	jmp    10215e <__alltraps>

001023a9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $63
  1023ab:	6a 3f                	push   $0x3f
  jmp __alltraps
  1023ad:	e9 ac fd ff ff       	jmp    10215e <__alltraps>

001023b2 <vector64>:
.globl vector64
vector64:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $64
  1023b4:	6a 40                	push   $0x40
  jmp __alltraps
  1023b6:	e9 a3 fd ff ff       	jmp    10215e <__alltraps>

001023bb <vector65>:
.globl vector65
vector65:
  pushl $0
  1023bb:	6a 00                	push   $0x0
  pushl $65
  1023bd:	6a 41                	push   $0x41
  jmp __alltraps
  1023bf:	e9 9a fd ff ff       	jmp    10215e <__alltraps>

001023c4 <vector66>:
.globl vector66
vector66:
  pushl $0
  1023c4:	6a 00                	push   $0x0
  pushl $66
  1023c6:	6a 42                	push   $0x42
  jmp __alltraps
  1023c8:	e9 91 fd ff ff       	jmp    10215e <__alltraps>

001023cd <vector67>:
.globl vector67
vector67:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $67
  1023cf:	6a 43                	push   $0x43
  jmp __alltraps
  1023d1:	e9 88 fd ff ff       	jmp    10215e <__alltraps>

001023d6 <vector68>:
.globl vector68
vector68:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $68
  1023d8:	6a 44                	push   $0x44
  jmp __alltraps
  1023da:	e9 7f fd ff ff       	jmp    10215e <__alltraps>

001023df <vector69>:
.globl vector69
vector69:
  pushl $0
  1023df:	6a 00                	push   $0x0
  pushl $69
  1023e1:	6a 45                	push   $0x45
  jmp __alltraps
  1023e3:	e9 76 fd ff ff       	jmp    10215e <__alltraps>

001023e8 <vector70>:
.globl vector70
vector70:
  pushl $0
  1023e8:	6a 00                	push   $0x0
  pushl $70
  1023ea:	6a 46                	push   $0x46
  jmp __alltraps
  1023ec:	e9 6d fd ff ff       	jmp    10215e <__alltraps>

001023f1 <vector71>:
.globl vector71
vector71:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $71
  1023f3:	6a 47                	push   $0x47
  jmp __alltraps
  1023f5:	e9 64 fd ff ff       	jmp    10215e <__alltraps>

001023fa <vector72>:
.globl vector72
vector72:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $72
  1023fc:	6a 48                	push   $0x48
  jmp __alltraps
  1023fe:	e9 5b fd ff ff       	jmp    10215e <__alltraps>

00102403 <vector73>:
.globl vector73
vector73:
  pushl $0
  102403:	6a 00                	push   $0x0
  pushl $73
  102405:	6a 49                	push   $0x49
  jmp __alltraps
  102407:	e9 52 fd ff ff       	jmp    10215e <__alltraps>

0010240c <vector74>:
.globl vector74
vector74:
  pushl $0
  10240c:	6a 00                	push   $0x0
  pushl $74
  10240e:	6a 4a                	push   $0x4a
  jmp __alltraps
  102410:	e9 49 fd ff ff       	jmp    10215e <__alltraps>

00102415 <vector75>:
.globl vector75
vector75:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $75
  102417:	6a 4b                	push   $0x4b
  jmp __alltraps
  102419:	e9 40 fd ff ff       	jmp    10215e <__alltraps>

0010241e <vector76>:
.globl vector76
vector76:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $76
  102420:	6a 4c                	push   $0x4c
  jmp __alltraps
  102422:	e9 37 fd ff ff       	jmp    10215e <__alltraps>

00102427 <vector77>:
.globl vector77
vector77:
  pushl $0
  102427:	6a 00                	push   $0x0
  pushl $77
  102429:	6a 4d                	push   $0x4d
  jmp __alltraps
  10242b:	e9 2e fd ff ff       	jmp    10215e <__alltraps>

00102430 <vector78>:
.globl vector78
vector78:
  pushl $0
  102430:	6a 00                	push   $0x0
  pushl $78
  102432:	6a 4e                	push   $0x4e
  jmp __alltraps
  102434:	e9 25 fd ff ff       	jmp    10215e <__alltraps>

00102439 <vector79>:
.globl vector79
vector79:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $79
  10243b:	6a 4f                	push   $0x4f
  jmp __alltraps
  10243d:	e9 1c fd ff ff       	jmp    10215e <__alltraps>

00102442 <vector80>:
.globl vector80
vector80:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $80
  102444:	6a 50                	push   $0x50
  jmp __alltraps
  102446:	e9 13 fd ff ff       	jmp    10215e <__alltraps>

0010244b <vector81>:
.globl vector81
vector81:
  pushl $0
  10244b:	6a 00                	push   $0x0
  pushl $81
  10244d:	6a 51                	push   $0x51
  jmp __alltraps
  10244f:	e9 0a fd ff ff       	jmp    10215e <__alltraps>

00102454 <vector82>:
.globl vector82
vector82:
  pushl $0
  102454:	6a 00                	push   $0x0
  pushl $82
  102456:	6a 52                	push   $0x52
  jmp __alltraps
  102458:	e9 01 fd ff ff       	jmp    10215e <__alltraps>

0010245d <vector83>:
.globl vector83
vector83:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $83
  10245f:	6a 53                	push   $0x53
  jmp __alltraps
  102461:	e9 f8 fc ff ff       	jmp    10215e <__alltraps>

00102466 <vector84>:
.globl vector84
vector84:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $84
  102468:	6a 54                	push   $0x54
  jmp __alltraps
  10246a:	e9 ef fc ff ff       	jmp    10215e <__alltraps>

0010246f <vector85>:
.globl vector85
vector85:
  pushl $0
  10246f:	6a 00                	push   $0x0
  pushl $85
  102471:	6a 55                	push   $0x55
  jmp __alltraps
  102473:	e9 e6 fc ff ff       	jmp    10215e <__alltraps>

00102478 <vector86>:
.globl vector86
vector86:
  pushl $0
  102478:	6a 00                	push   $0x0
  pushl $86
  10247a:	6a 56                	push   $0x56
  jmp __alltraps
  10247c:	e9 dd fc ff ff       	jmp    10215e <__alltraps>

00102481 <vector87>:
.globl vector87
vector87:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $87
  102483:	6a 57                	push   $0x57
  jmp __alltraps
  102485:	e9 d4 fc ff ff       	jmp    10215e <__alltraps>

0010248a <vector88>:
.globl vector88
vector88:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $88
  10248c:	6a 58                	push   $0x58
  jmp __alltraps
  10248e:	e9 cb fc ff ff       	jmp    10215e <__alltraps>

00102493 <vector89>:
.globl vector89
vector89:
  pushl $0
  102493:	6a 00                	push   $0x0
  pushl $89
  102495:	6a 59                	push   $0x59
  jmp __alltraps
  102497:	e9 c2 fc ff ff       	jmp    10215e <__alltraps>

0010249c <vector90>:
.globl vector90
vector90:
  pushl $0
  10249c:	6a 00                	push   $0x0
  pushl $90
  10249e:	6a 5a                	push   $0x5a
  jmp __alltraps
  1024a0:	e9 b9 fc ff ff       	jmp    10215e <__alltraps>

001024a5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $91
  1024a7:	6a 5b                	push   $0x5b
  jmp __alltraps
  1024a9:	e9 b0 fc ff ff       	jmp    10215e <__alltraps>

001024ae <vector92>:
.globl vector92
vector92:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $92
  1024b0:	6a 5c                	push   $0x5c
  jmp __alltraps
  1024b2:	e9 a7 fc ff ff       	jmp    10215e <__alltraps>

001024b7 <vector93>:
.globl vector93
vector93:
  pushl $0
  1024b7:	6a 00                	push   $0x0
  pushl $93
  1024b9:	6a 5d                	push   $0x5d
  jmp __alltraps
  1024bb:	e9 9e fc ff ff       	jmp    10215e <__alltraps>

001024c0 <vector94>:
.globl vector94
vector94:
  pushl $0
  1024c0:	6a 00                	push   $0x0
  pushl $94
  1024c2:	6a 5e                	push   $0x5e
  jmp __alltraps
  1024c4:	e9 95 fc ff ff       	jmp    10215e <__alltraps>

001024c9 <vector95>:
.globl vector95
vector95:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $95
  1024cb:	6a 5f                	push   $0x5f
  jmp __alltraps
  1024cd:	e9 8c fc ff ff       	jmp    10215e <__alltraps>

001024d2 <vector96>:
.globl vector96
vector96:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $96
  1024d4:	6a 60                	push   $0x60
  jmp __alltraps
  1024d6:	e9 83 fc ff ff       	jmp    10215e <__alltraps>

001024db <vector97>:
.globl vector97
vector97:
  pushl $0
  1024db:	6a 00                	push   $0x0
  pushl $97
  1024dd:	6a 61                	push   $0x61
  jmp __alltraps
  1024df:	e9 7a fc ff ff       	jmp    10215e <__alltraps>

001024e4 <vector98>:
.globl vector98
vector98:
  pushl $0
  1024e4:	6a 00                	push   $0x0
  pushl $98
  1024e6:	6a 62                	push   $0x62
  jmp __alltraps
  1024e8:	e9 71 fc ff ff       	jmp    10215e <__alltraps>

001024ed <vector99>:
.globl vector99
vector99:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $99
  1024ef:	6a 63                	push   $0x63
  jmp __alltraps
  1024f1:	e9 68 fc ff ff       	jmp    10215e <__alltraps>

001024f6 <vector100>:
.globl vector100
vector100:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $100
  1024f8:	6a 64                	push   $0x64
  jmp __alltraps
  1024fa:	e9 5f fc ff ff       	jmp    10215e <__alltraps>

001024ff <vector101>:
.globl vector101
vector101:
  pushl $0
  1024ff:	6a 00                	push   $0x0
  pushl $101
  102501:	6a 65                	push   $0x65
  jmp __alltraps
  102503:	e9 56 fc ff ff       	jmp    10215e <__alltraps>

00102508 <vector102>:
.globl vector102
vector102:
  pushl $0
  102508:	6a 00                	push   $0x0
  pushl $102
  10250a:	6a 66                	push   $0x66
  jmp __alltraps
  10250c:	e9 4d fc ff ff       	jmp    10215e <__alltraps>

00102511 <vector103>:
.globl vector103
vector103:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $103
  102513:	6a 67                	push   $0x67
  jmp __alltraps
  102515:	e9 44 fc ff ff       	jmp    10215e <__alltraps>

0010251a <vector104>:
.globl vector104
vector104:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $104
  10251c:	6a 68                	push   $0x68
  jmp __alltraps
  10251e:	e9 3b fc ff ff       	jmp    10215e <__alltraps>

00102523 <vector105>:
.globl vector105
vector105:
  pushl $0
  102523:	6a 00                	push   $0x0
  pushl $105
  102525:	6a 69                	push   $0x69
  jmp __alltraps
  102527:	e9 32 fc ff ff       	jmp    10215e <__alltraps>

0010252c <vector106>:
.globl vector106
vector106:
  pushl $0
  10252c:	6a 00                	push   $0x0
  pushl $106
  10252e:	6a 6a                	push   $0x6a
  jmp __alltraps
  102530:	e9 29 fc ff ff       	jmp    10215e <__alltraps>

00102535 <vector107>:
.globl vector107
vector107:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $107
  102537:	6a 6b                	push   $0x6b
  jmp __alltraps
  102539:	e9 20 fc ff ff       	jmp    10215e <__alltraps>

0010253e <vector108>:
.globl vector108
vector108:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $108
  102540:	6a 6c                	push   $0x6c
  jmp __alltraps
  102542:	e9 17 fc ff ff       	jmp    10215e <__alltraps>

00102547 <vector109>:
.globl vector109
vector109:
  pushl $0
  102547:	6a 00                	push   $0x0
  pushl $109
  102549:	6a 6d                	push   $0x6d
  jmp __alltraps
  10254b:	e9 0e fc ff ff       	jmp    10215e <__alltraps>

00102550 <vector110>:
.globl vector110
vector110:
  pushl $0
  102550:	6a 00                	push   $0x0
  pushl $110
  102552:	6a 6e                	push   $0x6e
  jmp __alltraps
  102554:	e9 05 fc ff ff       	jmp    10215e <__alltraps>

00102559 <vector111>:
.globl vector111
vector111:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $111
  10255b:	6a 6f                	push   $0x6f
  jmp __alltraps
  10255d:	e9 fc fb ff ff       	jmp    10215e <__alltraps>

00102562 <vector112>:
.globl vector112
vector112:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $112
  102564:	6a 70                	push   $0x70
  jmp __alltraps
  102566:	e9 f3 fb ff ff       	jmp    10215e <__alltraps>

0010256b <vector113>:
.globl vector113
vector113:
  pushl $0
  10256b:	6a 00                	push   $0x0
  pushl $113
  10256d:	6a 71                	push   $0x71
  jmp __alltraps
  10256f:	e9 ea fb ff ff       	jmp    10215e <__alltraps>

00102574 <vector114>:
.globl vector114
vector114:
  pushl $0
  102574:	6a 00                	push   $0x0
  pushl $114
  102576:	6a 72                	push   $0x72
  jmp __alltraps
  102578:	e9 e1 fb ff ff       	jmp    10215e <__alltraps>

0010257d <vector115>:
.globl vector115
vector115:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $115
  10257f:	6a 73                	push   $0x73
  jmp __alltraps
  102581:	e9 d8 fb ff ff       	jmp    10215e <__alltraps>

00102586 <vector116>:
.globl vector116
vector116:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $116
  102588:	6a 74                	push   $0x74
  jmp __alltraps
  10258a:	e9 cf fb ff ff       	jmp    10215e <__alltraps>

0010258f <vector117>:
.globl vector117
vector117:
  pushl $0
  10258f:	6a 00                	push   $0x0
  pushl $117
  102591:	6a 75                	push   $0x75
  jmp __alltraps
  102593:	e9 c6 fb ff ff       	jmp    10215e <__alltraps>

00102598 <vector118>:
.globl vector118
vector118:
  pushl $0
  102598:	6a 00                	push   $0x0
  pushl $118
  10259a:	6a 76                	push   $0x76
  jmp __alltraps
  10259c:	e9 bd fb ff ff       	jmp    10215e <__alltraps>

001025a1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $119
  1025a3:	6a 77                	push   $0x77
  jmp __alltraps
  1025a5:	e9 b4 fb ff ff       	jmp    10215e <__alltraps>

001025aa <vector120>:
.globl vector120
vector120:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $120
  1025ac:	6a 78                	push   $0x78
  jmp __alltraps
  1025ae:	e9 ab fb ff ff       	jmp    10215e <__alltraps>

001025b3 <vector121>:
.globl vector121
vector121:
  pushl $0
  1025b3:	6a 00                	push   $0x0
  pushl $121
  1025b5:	6a 79                	push   $0x79
  jmp __alltraps
  1025b7:	e9 a2 fb ff ff       	jmp    10215e <__alltraps>

001025bc <vector122>:
.globl vector122
vector122:
  pushl $0
  1025bc:	6a 00                	push   $0x0
  pushl $122
  1025be:	6a 7a                	push   $0x7a
  jmp __alltraps
  1025c0:	e9 99 fb ff ff       	jmp    10215e <__alltraps>

001025c5 <vector123>:
.globl vector123
vector123:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $123
  1025c7:	6a 7b                	push   $0x7b
  jmp __alltraps
  1025c9:	e9 90 fb ff ff       	jmp    10215e <__alltraps>

001025ce <vector124>:
.globl vector124
vector124:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $124
  1025d0:	6a 7c                	push   $0x7c
  jmp __alltraps
  1025d2:	e9 87 fb ff ff       	jmp    10215e <__alltraps>

001025d7 <vector125>:
.globl vector125
vector125:
  pushl $0
  1025d7:	6a 00                	push   $0x0
  pushl $125
  1025d9:	6a 7d                	push   $0x7d
  jmp __alltraps
  1025db:	e9 7e fb ff ff       	jmp    10215e <__alltraps>

001025e0 <vector126>:
.globl vector126
vector126:
  pushl $0
  1025e0:	6a 00                	push   $0x0
  pushl $126
  1025e2:	6a 7e                	push   $0x7e
  jmp __alltraps
  1025e4:	e9 75 fb ff ff       	jmp    10215e <__alltraps>

001025e9 <vector127>:
.globl vector127
vector127:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $127
  1025eb:	6a 7f                	push   $0x7f
  jmp __alltraps
  1025ed:	e9 6c fb ff ff       	jmp    10215e <__alltraps>

001025f2 <vector128>:
.globl vector128
vector128:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $128
  1025f4:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1025f9:	e9 60 fb ff ff       	jmp    10215e <__alltraps>

001025fe <vector129>:
.globl vector129
vector129:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $129
  102600:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102605:	e9 54 fb ff ff       	jmp    10215e <__alltraps>

0010260a <vector130>:
.globl vector130
vector130:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $130
  10260c:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102611:	e9 48 fb ff ff       	jmp    10215e <__alltraps>

00102616 <vector131>:
.globl vector131
vector131:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $131
  102618:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10261d:	e9 3c fb ff ff       	jmp    10215e <__alltraps>

00102622 <vector132>:
.globl vector132
vector132:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $132
  102624:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102629:	e9 30 fb ff ff       	jmp    10215e <__alltraps>

0010262e <vector133>:
.globl vector133
vector133:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $133
  102630:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102635:	e9 24 fb ff ff       	jmp    10215e <__alltraps>

0010263a <vector134>:
.globl vector134
vector134:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $134
  10263c:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102641:	e9 18 fb ff ff       	jmp    10215e <__alltraps>

00102646 <vector135>:
.globl vector135
vector135:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $135
  102648:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10264d:	e9 0c fb ff ff       	jmp    10215e <__alltraps>

00102652 <vector136>:
.globl vector136
vector136:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $136
  102654:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102659:	e9 00 fb ff ff       	jmp    10215e <__alltraps>

0010265e <vector137>:
.globl vector137
vector137:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $137
  102660:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102665:	e9 f4 fa ff ff       	jmp    10215e <__alltraps>

0010266a <vector138>:
.globl vector138
vector138:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $138
  10266c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102671:	e9 e8 fa ff ff       	jmp    10215e <__alltraps>

00102676 <vector139>:
.globl vector139
vector139:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $139
  102678:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10267d:	e9 dc fa ff ff       	jmp    10215e <__alltraps>

00102682 <vector140>:
.globl vector140
vector140:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $140
  102684:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102689:	e9 d0 fa ff ff       	jmp    10215e <__alltraps>

0010268e <vector141>:
.globl vector141
vector141:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $141
  102690:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102695:	e9 c4 fa ff ff       	jmp    10215e <__alltraps>

0010269a <vector142>:
.globl vector142
vector142:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $142
  10269c:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1026a1:	e9 b8 fa ff ff       	jmp    10215e <__alltraps>

001026a6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $143
  1026a8:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1026ad:	e9 ac fa ff ff       	jmp    10215e <__alltraps>

001026b2 <vector144>:
.globl vector144
vector144:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $144
  1026b4:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1026b9:	e9 a0 fa ff ff       	jmp    10215e <__alltraps>

001026be <vector145>:
.globl vector145
vector145:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $145
  1026c0:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1026c5:	e9 94 fa ff ff       	jmp    10215e <__alltraps>

001026ca <vector146>:
.globl vector146
vector146:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $146
  1026cc:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1026d1:	e9 88 fa ff ff       	jmp    10215e <__alltraps>

001026d6 <vector147>:
.globl vector147
vector147:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $147
  1026d8:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1026dd:	e9 7c fa ff ff       	jmp    10215e <__alltraps>

001026e2 <vector148>:
.globl vector148
vector148:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $148
  1026e4:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1026e9:	e9 70 fa ff ff       	jmp    10215e <__alltraps>

001026ee <vector149>:
.globl vector149
vector149:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $149
  1026f0:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1026f5:	e9 64 fa ff ff       	jmp    10215e <__alltraps>

001026fa <vector150>:
.globl vector150
vector150:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $150
  1026fc:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102701:	e9 58 fa ff ff       	jmp    10215e <__alltraps>

00102706 <vector151>:
.globl vector151
vector151:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $151
  102708:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10270d:	e9 4c fa ff ff       	jmp    10215e <__alltraps>

00102712 <vector152>:
.globl vector152
vector152:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $152
  102714:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102719:	e9 40 fa ff ff       	jmp    10215e <__alltraps>

0010271e <vector153>:
.globl vector153
vector153:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $153
  102720:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102725:	e9 34 fa ff ff       	jmp    10215e <__alltraps>

0010272a <vector154>:
.globl vector154
vector154:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $154
  10272c:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102731:	e9 28 fa ff ff       	jmp    10215e <__alltraps>

00102736 <vector155>:
.globl vector155
vector155:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $155
  102738:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10273d:	e9 1c fa ff ff       	jmp    10215e <__alltraps>

00102742 <vector156>:
.globl vector156
vector156:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $156
  102744:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102749:	e9 10 fa ff ff       	jmp    10215e <__alltraps>

0010274e <vector157>:
.globl vector157
vector157:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $157
  102750:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102755:	e9 04 fa ff ff       	jmp    10215e <__alltraps>

0010275a <vector158>:
.globl vector158
vector158:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $158
  10275c:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102761:	e9 f8 f9 ff ff       	jmp    10215e <__alltraps>

00102766 <vector159>:
.globl vector159
vector159:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $159
  102768:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10276d:	e9 ec f9 ff ff       	jmp    10215e <__alltraps>

00102772 <vector160>:
.globl vector160
vector160:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $160
  102774:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102779:	e9 e0 f9 ff ff       	jmp    10215e <__alltraps>

0010277e <vector161>:
.globl vector161
vector161:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $161
  102780:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102785:	e9 d4 f9 ff ff       	jmp    10215e <__alltraps>

0010278a <vector162>:
.globl vector162
vector162:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $162
  10278c:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102791:	e9 c8 f9 ff ff       	jmp    10215e <__alltraps>

00102796 <vector163>:
.globl vector163
vector163:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $163
  102798:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10279d:	e9 bc f9 ff ff       	jmp    10215e <__alltraps>

001027a2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $164
  1027a4:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1027a9:	e9 b0 f9 ff ff       	jmp    10215e <__alltraps>

001027ae <vector165>:
.globl vector165
vector165:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $165
  1027b0:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1027b5:	e9 a4 f9 ff ff       	jmp    10215e <__alltraps>

001027ba <vector166>:
.globl vector166
vector166:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $166
  1027bc:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1027c1:	e9 98 f9 ff ff       	jmp    10215e <__alltraps>

001027c6 <vector167>:
.globl vector167
vector167:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $167
  1027c8:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1027cd:	e9 8c f9 ff ff       	jmp    10215e <__alltraps>

001027d2 <vector168>:
.globl vector168
vector168:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $168
  1027d4:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1027d9:	e9 80 f9 ff ff       	jmp    10215e <__alltraps>

001027de <vector169>:
.globl vector169
vector169:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $169
  1027e0:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1027e5:	e9 74 f9 ff ff       	jmp    10215e <__alltraps>

001027ea <vector170>:
.globl vector170
vector170:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $170
  1027ec:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1027f1:	e9 68 f9 ff ff       	jmp    10215e <__alltraps>

001027f6 <vector171>:
.globl vector171
vector171:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $171
  1027f8:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1027fd:	e9 5c f9 ff ff       	jmp    10215e <__alltraps>

00102802 <vector172>:
.globl vector172
vector172:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $172
  102804:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102809:	e9 50 f9 ff ff       	jmp    10215e <__alltraps>

0010280e <vector173>:
.globl vector173
vector173:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $173
  102810:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102815:	e9 44 f9 ff ff       	jmp    10215e <__alltraps>

0010281a <vector174>:
.globl vector174
vector174:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $174
  10281c:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102821:	e9 38 f9 ff ff       	jmp    10215e <__alltraps>

00102826 <vector175>:
.globl vector175
vector175:
  pushl $0
  102826:	6a 00                	push   $0x0
  pushl $175
  102828:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10282d:	e9 2c f9 ff ff       	jmp    10215e <__alltraps>

00102832 <vector176>:
.globl vector176
vector176:
  pushl $0
  102832:	6a 00                	push   $0x0
  pushl $176
  102834:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102839:	e9 20 f9 ff ff       	jmp    10215e <__alltraps>

0010283e <vector177>:
.globl vector177
vector177:
  pushl $0
  10283e:	6a 00                	push   $0x0
  pushl $177
  102840:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102845:	e9 14 f9 ff ff       	jmp    10215e <__alltraps>

0010284a <vector178>:
.globl vector178
vector178:
  pushl $0
  10284a:	6a 00                	push   $0x0
  pushl $178
  10284c:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102851:	e9 08 f9 ff ff       	jmp    10215e <__alltraps>

00102856 <vector179>:
.globl vector179
vector179:
  pushl $0
  102856:	6a 00                	push   $0x0
  pushl $179
  102858:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10285d:	e9 fc f8 ff ff       	jmp    10215e <__alltraps>

00102862 <vector180>:
.globl vector180
vector180:
  pushl $0
  102862:	6a 00                	push   $0x0
  pushl $180
  102864:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102869:	e9 f0 f8 ff ff       	jmp    10215e <__alltraps>

0010286e <vector181>:
.globl vector181
vector181:
  pushl $0
  10286e:	6a 00                	push   $0x0
  pushl $181
  102870:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102875:	e9 e4 f8 ff ff       	jmp    10215e <__alltraps>

0010287a <vector182>:
.globl vector182
vector182:
  pushl $0
  10287a:	6a 00                	push   $0x0
  pushl $182
  10287c:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102881:	e9 d8 f8 ff ff       	jmp    10215e <__alltraps>

00102886 <vector183>:
.globl vector183
vector183:
  pushl $0
  102886:	6a 00                	push   $0x0
  pushl $183
  102888:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10288d:	e9 cc f8 ff ff       	jmp    10215e <__alltraps>

00102892 <vector184>:
.globl vector184
vector184:
  pushl $0
  102892:	6a 00                	push   $0x0
  pushl $184
  102894:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102899:	e9 c0 f8 ff ff       	jmp    10215e <__alltraps>

0010289e <vector185>:
.globl vector185
vector185:
  pushl $0
  10289e:	6a 00                	push   $0x0
  pushl $185
  1028a0:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1028a5:	e9 b4 f8 ff ff       	jmp    10215e <__alltraps>

001028aa <vector186>:
.globl vector186
vector186:
  pushl $0
  1028aa:	6a 00                	push   $0x0
  pushl $186
  1028ac:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1028b1:	e9 a8 f8 ff ff       	jmp    10215e <__alltraps>

001028b6 <vector187>:
.globl vector187
vector187:
  pushl $0
  1028b6:	6a 00                	push   $0x0
  pushl $187
  1028b8:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1028bd:	e9 9c f8 ff ff       	jmp    10215e <__alltraps>

001028c2 <vector188>:
.globl vector188
vector188:
  pushl $0
  1028c2:	6a 00                	push   $0x0
  pushl $188
  1028c4:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1028c9:	e9 90 f8 ff ff       	jmp    10215e <__alltraps>

001028ce <vector189>:
.globl vector189
vector189:
  pushl $0
  1028ce:	6a 00                	push   $0x0
  pushl $189
  1028d0:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1028d5:	e9 84 f8 ff ff       	jmp    10215e <__alltraps>

001028da <vector190>:
.globl vector190
vector190:
  pushl $0
  1028da:	6a 00                	push   $0x0
  pushl $190
  1028dc:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1028e1:	e9 78 f8 ff ff       	jmp    10215e <__alltraps>

001028e6 <vector191>:
.globl vector191
vector191:
  pushl $0
  1028e6:	6a 00                	push   $0x0
  pushl $191
  1028e8:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1028ed:	e9 6c f8 ff ff       	jmp    10215e <__alltraps>

001028f2 <vector192>:
.globl vector192
vector192:
  pushl $0
  1028f2:	6a 00                	push   $0x0
  pushl $192
  1028f4:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1028f9:	e9 60 f8 ff ff       	jmp    10215e <__alltraps>

001028fe <vector193>:
.globl vector193
vector193:
  pushl $0
  1028fe:	6a 00                	push   $0x0
  pushl $193
  102900:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102905:	e9 54 f8 ff ff       	jmp    10215e <__alltraps>

0010290a <vector194>:
.globl vector194
vector194:
  pushl $0
  10290a:	6a 00                	push   $0x0
  pushl $194
  10290c:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102911:	e9 48 f8 ff ff       	jmp    10215e <__alltraps>

00102916 <vector195>:
.globl vector195
vector195:
  pushl $0
  102916:	6a 00                	push   $0x0
  pushl $195
  102918:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10291d:	e9 3c f8 ff ff       	jmp    10215e <__alltraps>

00102922 <vector196>:
.globl vector196
vector196:
  pushl $0
  102922:	6a 00                	push   $0x0
  pushl $196
  102924:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102929:	e9 30 f8 ff ff       	jmp    10215e <__alltraps>

0010292e <vector197>:
.globl vector197
vector197:
  pushl $0
  10292e:	6a 00                	push   $0x0
  pushl $197
  102930:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102935:	e9 24 f8 ff ff       	jmp    10215e <__alltraps>

0010293a <vector198>:
.globl vector198
vector198:
  pushl $0
  10293a:	6a 00                	push   $0x0
  pushl $198
  10293c:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102941:	e9 18 f8 ff ff       	jmp    10215e <__alltraps>

00102946 <vector199>:
.globl vector199
vector199:
  pushl $0
  102946:	6a 00                	push   $0x0
  pushl $199
  102948:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10294d:	e9 0c f8 ff ff       	jmp    10215e <__alltraps>

00102952 <vector200>:
.globl vector200
vector200:
  pushl $0
  102952:	6a 00                	push   $0x0
  pushl $200
  102954:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102959:	e9 00 f8 ff ff       	jmp    10215e <__alltraps>

0010295e <vector201>:
.globl vector201
vector201:
  pushl $0
  10295e:	6a 00                	push   $0x0
  pushl $201
  102960:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102965:	e9 f4 f7 ff ff       	jmp    10215e <__alltraps>

0010296a <vector202>:
.globl vector202
vector202:
  pushl $0
  10296a:	6a 00                	push   $0x0
  pushl $202
  10296c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102971:	e9 e8 f7 ff ff       	jmp    10215e <__alltraps>

00102976 <vector203>:
.globl vector203
vector203:
  pushl $0
  102976:	6a 00                	push   $0x0
  pushl $203
  102978:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10297d:	e9 dc f7 ff ff       	jmp    10215e <__alltraps>

00102982 <vector204>:
.globl vector204
vector204:
  pushl $0
  102982:	6a 00                	push   $0x0
  pushl $204
  102984:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102989:	e9 d0 f7 ff ff       	jmp    10215e <__alltraps>

0010298e <vector205>:
.globl vector205
vector205:
  pushl $0
  10298e:	6a 00                	push   $0x0
  pushl $205
  102990:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102995:	e9 c4 f7 ff ff       	jmp    10215e <__alltraps>

0010299a <vector206>:
.globl vector206
vector206:
  pushl $0
  10299a:	6a 00                	push   $0x0
  pushl $206
  10299c:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1029a1:	e9 b8 f7 ff ff       	jmp    10215e <__alltraps>

001029a6 <vector207>:
.globl vector207
vector207:
  pushl $0
  1029a6:	6a 00                	push   $0x0
  pushl $207
  1029a8:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1029ad:	e9 ac f7 ff ff       	jmp    10215e <__alltraps>

001029b2 <vector208>:
.globl vector208
vector208:
  pushl $0
  1029b2:	6a 00                	push   $0x0
  pushl $208
  1029b4:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1029b9:	e9 a0 f7 ff ff       	jmp    10215e <__alltraps>

001029be <vector209>:
.globl vector209
vector209:
  pushl $0
  1029be:	6a 00                	push   $0x0
  pushl $209
  1029c0:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1029c5:	e9 94 f7 ff ff       	jmp    10215e <__alltraps>

001029ca <vector210>:
.globl vector210
vector210:
  pushl $0
  1029ca:	6a 00                	push   $0x0
  pushl $210
  1029cc:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1029d1:	e9 88 f7 ff ff       	jmp    10215e <__alltraps>

001029d6 <vector211>:
.globl vector211
vector211:
  pushl $0
  1029d6:	6a 00                	push   $0x0
  pushl $211
  1029d8:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1029dd:	e9 7c f7 ff ff       	jmp    10215e <__alltraps>

001029e2 <vector212>:
.globl vector212
vector212:
  pushl $0
  1029e2:	6a 00                	push   $0x0
  pushl $212
  1029e4:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1029e9:	e9 70 f7 ff ff       	jmp    10215e <__alltraps>

001029ee <vector213>:
.globl vector213
vector213:
  pushl $0
  1029ee:	6a 00                	push   $0x0
  pushl $213
  1029f0:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1029f5:	e9 64 f7 ff ff       	jmp    10215e <__alltraps>

001029fa <vector214>:
.globl vector214
vector214:
  pushl $0
  1029fa:	6a 00                	push   $0x0
  pushl $214
  1029fc:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102a01:	e9 58 f7 ff ff       	jmp    10215e <__alltraps>

00102a06 <vector215>:
.globl vector215
vector215:
  pushl $0
  102a06:	6a 00                	push   $0x0
  pushl $215
  102a08:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102a0d:	e9 4c f7 ff ff       	jmp    10215e <__alltraps>

00102a12 <vector216>:
.globl vector216
vector216:
  pushl $0
  102a12:	6a 00                	push   $0x0
  pushl $216
  102a14:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102a19:	e9 40 f7 ff ff       	jmp    10215e <__alltraps>

00102a1e <vector217>:
.globl vector217
vector217:
  pushl $0
  102a1e:	6a 00                	push   $0x0
  pushl $217
  102a20:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102a25:	e9 34 f7 ff ff       	jmp    10215e <__alltraps>

00102a2a <vector218>:
.globl vector218
vector218:
  pushl $0
  102a2a:	6a 00                	push   $0x0
  pushl $218
  102a2c:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102a31:	e9 28 f7 ff ff       	jmp    10215e <__alltraps>

00102a36 <vector219>:
.globl vector219
vector219:
  pushl $0
  102a36:	6a 00                	push   $0x0
  pushl $219
  102a38:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102a3d:	e9 1c f7 ff ff       	jmp    10215e <__alltraps>

00102a42 <vector220>:
.globl vector220
vector220:
  pushl $0
  102a42:	6a 00                	push   $0x0
  pushl $220
  102a44:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102a49:	e9 10 f7 ff ff       	jmp    10215e <__alltraps>

00102a4e <vector221>:
.globl vector221
vector221:
  pushl $0
  102a4e:	6a 00                	push   $0x0
  pushl $221
  102a50:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102a55:	e9 04 f7 ff ff       	jmp    10215e <__alltraps>

00102a5a <vector222>:
.globl vector222
vector222:
  pushl $0
  102a5a:	6a 00                	push   $0x0
  pushl $222
  102a5c:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102a61:	e9 f8 f6 ff ff       	jmp    10215e <__alltraps>

00102a66 <vector223>:
.globl vector223
vector223:
  pushl $0
  102a66:	6a 00                	push   $0x0
  pushl $223
  102a68:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102a6d:	e9 ec f6 ff ff       	jmp    10215e <__alltraps>

00102a72 <vector224>:
.globl vector224
vector224:
  pushl $0
  102a72:	6a 00                	push   $0x0
  pushl $224
  102a74:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102a79:	e9 e0 f6 ff ff       	jmp    10215e <__alltraps>

00102a7e <vector225>:
.globl vector225
vector225:
  pushl $0
  102a7e:	6a 00                	push   $0x0
  pushl $225
  102a80:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102a85:	e9 d4 f6 ff ff       	jmp    10215e <__alltraps>

00102a8a <vector226>:
.globl vector226
vector226:
  pushl $0
  102a8a:	6a 00                	push   $0x0
  pushl $226
  102a8c:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102a91:	e9 c8 f6 ff ff       	jmp    10215e <__alltraps>

00102a96 <vector227>:
.globl vector227
vector227:
  pushl $0
  102a96:	6a 00                	push   $0x0
  pushl $227
  102a98:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102a9d:	e9 bc f6 ff ff       	jmp    10215e <__alltraps>

00102aa2 <vector228>:
.globl vector228
vector228:
  pushl $0
  102aa2:	6a 00                	push   $0x0
  pushl $228
  102aa4:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102aa9:	e9 b0 f6 ff ff       	jmp    10215e <__alltraps>

00102aae <vector229>:
.globl vector229
vector229:
  pushl $0
  102aae:	6a 00                	push   $0x0
  pushl $229
  102ab0:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102ab5:	e9 a4 f6 ff ff       	jmp    10215e <__alltraps>

00102aba <vector230>:
.globl vector230
vector230:
  pushl $0
  102aba:	6a 00                	push   $0x0
  pushl $230
  102abc:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102ac1:	e9 98 f6 ff ff       	jmp    10215e <__alltraps>

00102ac6 <vector231>:
.globl vector231
vector231:
  pushl $0
  102ac6:	6a 00                	push   $0x0
  pushl $231
  102ac8:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102acd:	e9 8c f6 ff ff       	jmp    10215e <__alltraps>

00102ad2 <vector232>:
.globl vector232
vector232:
  pushl $0
  102ad2:	6a 00                	push   $0x0
  pushl $232
  102ad4:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102ad9:	e9 80 f6 ff ff       	jmp    10215e <__alltraps>

00102ade <vector233>:
.globl vector233
vector233:
  pushl $0
  102ade:	6a 00                	push   $0x0
  pushl $233
  102ae0:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102ae5:	e9 74 f6 ff ff       	jmp    10215e <__alltraps>

00102aea <vector234>:
.globl vector234
vector234:
  pushl $0
  102aea:	6a 00                	push   $0x0
  pushl $234
  102aec:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102af1:	e9 68 f6 ff ff       	jmp    10215e <__alltraps>

00102af6 <vector235>:
.globl vector235
vector235:
  pushl $0
  102af6:	6a 00                	push   $0x0
  pushl $235
  102af8:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102afd:	e9 5c f6 ff ff       	jmp    10215e <__alltraps>

00102b02 <vector236>:
.globl vector236
vector236:
  pushl $0
  102b02:	6a 00                	push   $0x0
  pushl $236
  102b04:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102b09:	e9 50 f6 ff ff       	jmp    10215e <__alltraps>

00102b0e <vector237>:
.globl vector237
vector237:
  pushl $0
  102b0e:	6a 00                	push   $0x0
  pushl $237
  102b10:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102b15:	e9 44 f6 ff ff       	jmp    10215e <__alltraps>

00102b1a <vector238>:
.globl vector238
vector238:
  pushl $0
  102b1a:	6a 00                	push   $0x0
  pushl $238
  102b1c:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102b21:	e9 38 f6 ff ff       	jmp    10215e <__alltraps>

00102b26 <vector239>:
.globl vector239
vector239:
  pushl $0
  102b26:	6a 00                	push   $0x0
  pushl $239
  102b28:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102b2d:	e9 2c f6 ff ff       	jmp    10215e <__alltraps>

00102b32 <vector240>:
.globl vector240
vector240:
  pushl $0
  102b32:	6a 00                	push   $0x0
  pushl $240
  102b34:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102b39:	e9 20 f6 ff ff       	jmp    10215e <__alltraps>

00102b3e <vector241>:
.globl vector241
vector241:
  pushl $0
  102b3e:	6a 00                	push   $0x0
  pushl $241
  102b40:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102b45:	e9 14 f6 ff ff       	jmp    10215e <__alltraps>

00102b4a <vector242>:
.globl vector242
vector242:
  pushl $0
  102b4a:	6a 00                	push   $0x0
  pushl $242
  102b4c:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102b51:	e9 08 f6 ff ff       	jmp    10215e <__alltraps>

00102b56 <vector243>:
.globl vector243
vector243:
  pushl $0
  102b56:	6a 00                	push   $0x0
  pushl $243
  102b58:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102b5d:	e9 fc f5 ff ff       	jmp    10215e <__alltraps>

00102b62 <vector244>:
.globl vector244
vector244:
  pushl $0
  102b62:	6a 00                	push   $0x0
  pushl $244
  102b64:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102b69:	e9 f0 f5 ff ff       	jmp    10215e <__alltraps>

00102b6e <vector245>:
.globl vector245
vector245:
  pushl $0
  102b6e:	6a 00                	push   $0x0
  pushl $245
  102b70:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102b75:	e9 e4 f5 ff ff       	jmp    10215e <__alltraps>

00102b7a <vector246>:
.globl vector246
vector246:
  pushl $0
  102b7a:	6a 00                	push   $0x0
  pushl $246
  102b7c:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102b81:	e9 d8 f5 ff ff       	jmp    10215e <__alltraps>

00102b86 <vector247>:
.globl vector247
vector247:
  pushl $0
  102b86:	6a 00                	push   $0x0
  pushl $247
  102b88:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102b8d:	e9 cc f5 ff ff       	jmp    10215e <__alltraps>

00102b92 <vector248>:
.globl vector248
vector248:
  pushl $0
  102b92:	6a 00                	push   $0x0
  pushl $248
  102b94:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102b99:	e9 c0 f5 ff ff       	jmp    10215e <__alltraps>

00102b9e <vector249>:
.globl vector249
vector249:
  pushl $0
  102b9e:	6a 00                	push   $0x0
  pushl $249
  102ba0:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102ba5:	e9 b4 f5 ff ff       	jmp    10215e <__alltraps>

00102baa <vector250>:
.globl vector250
vector250:
  pushl $0
  102baa:	6a 00                	push   $0x0
  pushl $250
  102bac:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102bb1:	e9 a8 f5 ff ff       	jmp    10215e <__alltraps>

00102bb6 <vector251>:
.globl vector251
vector251:
  pushl $0
  102bb6:	6a 00                	push   $0x0
  pushl $251
  102bb8:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102bbd:	e9 9c f5 ff ff       	jmp    10215e <__alltraps>

00102bc2 <vector252>:
.globl vector252
vector252:
  pushl $0
  102bc2:	6a 00                	push   $0x0
  pushl $252
  102bc4:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102bc9:	e9 90 f5 ff ff       	jmp    10215e <__alltraps>

00102bce <vector253>:
.globl vector253
vector253:
  pushl $0
  102bce:	6a 00                	push   $0x0
  pushl $253
  102bd0:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102bd5:	e9 84 f5 ff ff       	jmp    10215e <__alltraps>

00102bda <vector254>:
.globl vector254
vector254:
  pushl $0
  102bda:	6a 00                	push   $0x0
  pushl $254
  102bdc:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102be1:	e9 78 f5 ff ff       	jmp    10215e <__alltraps>

00102be6 <vector255>:
.globl vector255
vector255:
  pushl $0
  102be6:	6a 00                	push   $0x0
  pushl $255
  102be8:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102bed:	e9 6c f5 ff ff       	jmp    10215e <__alltraps>

00102bf2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102bf2:	55                   	push   %ebp
  102bf3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102bfb:	b8 23 00 00 00       	mov    $0x23,%eax
  102c00:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102c02:	b8 23 00 00 00       	mov    $0x23,%eax
  102c07:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102c09:	b8 10 00 00 00       	mov    $0x10,%eax
  102c0e:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102c10:	b8 10 00 00 00       	mov    $0x10,%eax
  102c15:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102c17:	b8 10 00 00 00       	mov    $0x10,%eax
  102c1c:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102c1e:	ea 25 2c 10 00 08 00 	ljmp   $0x8,$0x102c25
}
  102c25:	90                   	nop
  102c26:	5d                   	pop    %ebp
  102c27:	c3                   	ret    

00102c28 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102c28:	55                   	push   %ebp
  102c29:	89 e5                	mov    %esp,%ebp
  102c2b:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102c2e:	b8 00 09 11 00       	mov    $0x110900,%eax
  102c33:	05 00 04 00 00       	add    $0x400,%eax
  102c38:	a3 04 0d 11 00       	mov    %eax,0x110d04
    ts.ts_ss0 = KERNEL_DS;
  102c3d:	66 c7 05 08 0d 11 00 	movw   $0x10,0x110d08
  102c44:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102c46:	66 c7 05 08 fa 10 00 	movw   $0x68,0x10fa08
  102c4d:	68 00 
  102c4f:	b8 00 0d 11 00       	mov    $0x110d00,%eax
  102c54:	0f b7 c0             	movzwl %ax,%eax
  102c57:	66 a3 0a fa 10 00    	mov    %ax,0x10fa0a
  102c5d:	b8 00 0d 11 00       	mov    $0x110d00,%eax
  102c62:	c1 e8 10             	shr    $0x10,%eax
  102c65:	a2 0c fa 10 00       	mov    %al,0x10fa0c
  102c6a:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102c71:	24 f0                	and    $0xf0,%al
  102c73:	0c 09                	or     $0x9,%al
  102c75:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102c7a:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102c81:	0c 10                	or     $0x10,%al
  102c83:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102c88:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102c8f:	24 9f                	and    $0x9f,%al
  102c91:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102c96:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102c9d:	0c 80                	or     $0x80,%al
  102c9f:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102ca4:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cab:	24 f0                	and    $0xf0,%al
  102cad:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cb2:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cb9:	24 ef                	and    $0xef,%al
  102cbb:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cc0:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cc7:	24 df                	and    $0xdf,%al
  102cc9:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cce:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cd5:	0c 40                	or     $0x40,%al
  102cd7:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cdc:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102ce3:	24 7f                	and    $0x7f,%al
  102ce5:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cea:	b8 00 0d 11 00       	mov    $0x110d00,%eax
  102cef:	c1 e8 18             	shr    $0x18,%eax
  102cf2:	a2 0f fa 10 00       	mov    %al,0x10fa0f
    gdt[SEG_TSS].sd_s = 0;
  102cf7:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102cfe:	24 ef                	and    $0xef,%al
  102d00:	a2 0d fa 10 00       	mov    %al,0x10fa0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102d05:	c7 04 24 10 fa 10 00 	movl   $0x10fa10,(%esp)
  102d0c:	e8 e1 fe ff ff       	call   102bf2 <lgdt>
  102d11:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102d17:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102d1b:	0f 00 d8             	ltr    %ax
}
  102d1e:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102d1f:	90                   	nop
  102d20:	89 ec                	mov    %ebp,%esp
  102d22:	5d                   	pop    %ebp
  102d23:	c3                   	ret    

00102d24 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102d24:	55                   	push   %ebp
  102d25:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102d27:	e8 fc fe ff ff       	call   102c28 <gdt_init>
}
  102d2c:	90                   	nop
  102d2d:	5d                   	pop    %ebp
  102d2e:	c3                   	ret    

00102d2f <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102d2f:	55                   	push   %ebp
  102d30:	89 e5                	mov    %esp,%ebp
  102d32:	83 ec 58             	sub    $0x58,%esp
  102d35:	8b 45 10             	mov    0x10(%ebp),%eax
  102d38:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102d3b:	8b 45 14             	mov    0x14(%ebp),%eax
  102d3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102d41:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102d47:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d4a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102d4d:	8b 45 18             	mov    0x18(%ebp),%eax
  102d50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102d53:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d56:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102d59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d5c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102d69:	74 1c                	je     102d87 <printnum+0x58>
  102d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  102d73:	f7 75 e4             	divl   -0x1c(%ebp)
  102d76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d7c:	ba 00 00 00 00       	mov    $0x0,%edx
  102d81:	f7 75 e4             	divl   -0x1c(%ebp)
  102d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d8d:	f7 75 e4             	divl   -0x1c(%ebp)
  102d90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d93:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102d96:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d99:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d9f:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102da2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102da5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102da8:	8b 45 18             	mov    0x18(%ebp),%eax
  102dab:	ba 00 00 00 00       	mov    $0x0,%edx
  102db0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  102db3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102db6:	19 d1                	sbb    %edx,%ecx
  102db8:	72 4c                	jb     102e06 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102dba:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102dbd:	8d 50 ff             	lea    -0x1(%eax),%edx
  102dc0:	8b 45 20             	mov    0x20(%ebp),%eax
  102dc3:	89 44 24 18          	mov    %eax,0x18(%esp)
  102dc7:	89 54 24 14          	mov    %edx,0x14(%esp)
  102dcb:	8b 45 18             	mov    0x18(%ebp),%eax
  102dce:	89 44 24 10          	mov    %eax,0x10(%esp)
  102dd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102dd5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102dd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ddc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102de7:	8b 45 08             	mov    0x8(%ebp),%eax
  102dea:	89 04 24             	mov    %eax,(%esp)
  102ded:	e8 3d ff ff ff       	call   102d2f <printnum>
  102df2:	eb 1b                	jmp    102e0f <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dfb:	8b 45 20             	mov    0x20(%ebp),%eax
  102dfe:	89 04 24             	mov    %eax,(%esp)
  102e01:	8b 45 08             	mov    0x8(%ebp),%eax
  102e04:	ff d0                	call   *%eax
        while (-- width > 0)
  102e06:	ff 4d 1c             	decl   0x1c(%ebp)
  102e09:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102e0d:	7f e5                	jg     102df4 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102e0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102e12:	05 30 40 10 00       	add    $0x104030,%eax
  102e17:	0f b6 00             	movzbl (%eax),%eax
  102e1a:	0f be c0             	movsbl %al,%eax
  102e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e20:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e24:	89 04 24             	mov    %eax,(%esp)
  102e27:	8b 45 08             	mov    0x8(%ebp),%eax
  102e2a:	ff d0                	call   *%eax
}
  102e2c:	90                   	nop
  102e2d:	89 ec                	mov    %ebp,%esp
  102e2f:	5d                   	pop    %ebp
  102e30:	c3                   	ret    

00102e31 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102e31:	55                   	push   %ebp
  102e32:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102e34:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102e38:	7e 14                	jle    102e4e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3d:	8b 00                	mov    (%eax),%eax
  102e3f:	8d 48 08             	lea    0x8(%eax),%ecx
  102e42:	8b 55 08             	mov    0x8(%ebp),%edx
  102e45:	89 0a                	mov    %ecx,(%edx)
  102e47:	8b 50 04             	mov    0x4(%eax),%edx
  102e4a:	8b 00                	mov    (%eax),%eax
  102e4c:	eb 30                	jmp    102e7e <getuint+0x4d>
    }
    else if (lflag) {
  102e4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102e52:	74 16                	je     102e6a <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102e54:	8b 45 08             	mov    0x8(%ebp),%eax
  102e57:	8b 00                	mov    (%eax),%eax
  102e59:	8d 48 04             	lea    0x4(%eax),%ecx
  102e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  102e5f:	89 0a                	mov    %ecx,(%edx)
  102e61:	8b 00                	mov    (%eax),%eax
  102e63:	ba 00 00 00 00       	mov    $0x0,%edx
  102e68:	eb 14                	jmp    102e7e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e6d:	8b 00                	mov    (%eax),%eax
  102e6f:	8d 48 04             	lea    0x4(%eax),%ecx
  102e72:	8b 55 08             	mov    0x8(%ebp),%edx
  102e75:	89 0a                	mov    %ecx,(%edx)
  102e77:	8b 00                	mov    (%eax),%eax
  102e79:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102e7e:	5d                   	pop    %ebp
  102e7f:	c3                   	ret    

00102e80 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102e80:	55                   	push   %ebp
  102e81:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102e83:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102e87:	7e 14                	jle    102e9d <getint+0x1d>
        return va_arg(*ap, long long);
  102e89:	8b 45 08             	mov    0x8(%ebp),%eax
  102e8c:	8b 00                	mov    (%eax),%eax
  102e8e:	8d 48 08             	lea    0x8(%eax),%ecx
  102e91:	8b 55 08             	mov    0x8(%ebp),%edx
  102e94:	89 0a                	mov    %ecx,(%edx)
  102e96:	8b 50 04             	mov    0x4(%eax),%edx
  102e99:	8b 00                	mov    (%eax),%eax
  102e9b:	eb 28                	jmp    102ec5 <getint+0x45>
    }
    else if (lflag) {
  102e9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102ea1:	74 12                	je     102eb5 <getint+0x35>
        return va_arg(*ap, long);
  102ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea6:	8b 00                	mov    (%eax),%eax
  102ea8:	8d 48 04             	lea    0x4(%eax),%ecx
  102eab:	8b 55 08             	mov    0x8(%ebp),%edx
  102eae:	89 0a                	mov    %ecx,(%edx)
  102eb0:	8b 00                	mov    (%eax),%eax
  102eb2:	99                   	cltd   
  102eb3:	eb 10                	jmp    102ec5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  102eb8:	8b 00                	mov    (%eax),%eax
  102eba:	8d 48 04             	lea    0x4(%eax),%ecx
  102ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  102ec0:	89 0a                	mov    %ecx,(%edx)
  102ec2:	8b 00                	mov    (%eax),%eax
  102ec4:	99                   	cltd   
    }
}
  102ec5:	5d                   	pop    %ebp
  102ec6:	c3                   	ret    

00102ec7 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102ec7:	55                   	push   %ebp
  102ec8:	89 e5                	mov    %esp,%ebp
  102eca:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102ecd:	8d 45 14             	lea    0x14(%ebp),%eax
  102ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ed6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102eda:	8b 45 10             	mov    0x10(%ebp),%eax
  102edd:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  102eeb:	89 04 24             	mov    %eax,(%esp)
  102eee:	e8 05 00 00 00       	call   102ef8 <vprintfmt>
    va_end(ap);
}
  102ef3:	90                   	nop
  102ef4:	89 ec                	mov    %ebp,%esp
  102ef6:	5d                   	pop    %ebp
  102ef7:	c3                   	ret    

00102ef8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102ef8:	55                   	push   %ebp
  102ef9:	89 e5                	mov    %esp,%ebp
  102efb:	56                   	push   %esi
  102efc:	53                   	push   %ebx
  102efd:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102f00:	eb 17                	jmp    102f19 <vprintfmt+0x21>
            if (ch == '\0') {
  102f02:	85 db                	test   %ebx,%ebx
  102f04:	0f 84 bf 03 00 00    	je     1032c9 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  102f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f11:	89 1c 24             	mov    %ebx,(%esp)
  102f14:	8b 45 08             	mov    0x8(%ebp),%eax
  102f17:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102f19:	8b 45 10             	mov    0x10(%ebp),%eax
  102f1c:	8d 50 01             	lea    0x1(%eax),%edx
  102f1f:	89 55 10             	mov    %edx,0x10(%ebp)
  102f22:	0f b6 00             	movzbl (%eax),%eax
  102f25:	0f b6 d8             	movzbl %al,%ebx
  102f28:	83 fb 25             	cmp    $0x25,%ebx
  102f2b:	75 d5                	jne    102f02 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  102f2d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102f31:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102f3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102f3e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102f45:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102f48:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  102f4e:	8d 50 01             	lea    0x1(%eax),%edx
  102f51:	89 55 10             	mov    %edx,0x10(%ebp)
  102f54:	0f b6 00             	movzbl (%eax),%eax
  102f57:	0f b6 d8             	movzbl %al,%ebx
  102f5a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102f5d:	83 f8 55             	cmp    $0x55,%eax
  102f60:	0f 87 37 03 00 00    	ja     10329d <vprintfmt+0x3a5>
  102f66:	8b 04 85 54 40 10 00 	mov    0x104054(,%eax,4),%eax
  102f6d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102f6f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102f73:	eb d6                	jmp    102f4b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102f75:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102f79:	eb d0                	jmp    102f4b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102f7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102f82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f85:	89 d0                	mov    %edx,%eax
  102f87:	c1 e0 02             	shl    $0x2,%eax
  102f8a:	01 d0                	add    %edx,%eax
  102f8c:	01 c0                	add    %eax,%eax
  102f8e:	01 d8                	add    %ebx,%eax
  102f90:	83 e8 30             	sub    $0x30,%eax
  102f93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102f96:	8b 45 10             	mov    0x10(%ebp),%eax
  102f99:	0f b6 00             	movzbl (%eax),%eax
  102f9c:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102f9f:	83 fb 2f             	cmp    $0x2f,%ebx
  102fa2:	7e 38                	jle    102fdc <vprintfmt+0xe4>
  102fa4:	83 fb 39             	cmp    $0x39,%ebx
  102fa7:	7f 33                	jg     102fdc <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  102fa9:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  102fac:	eb d4                	jmp    102f82 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  102fae:	8b 45 14             	mov    0x14(%ebp),%eax
  102fb1:	8d 50 04             	lea    0x4(%eax),%edx
  102fb4:	89 55 14             	mov    %edx,0x14(%ebp)
  102fb7:	8b 00                	mov    (%eax),%eax
  102fb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102fbc:	eb 1f                	jmp    102fdd <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  102fbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102fc2:	79 87                	jns    102f4b <vprintfmt+0x53>
                width = 0;
  102fc4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102fcb:	e9 7b ff ff ff       	jmp    102f4b <vprintfmt+0x53>

        case '#':
            altflag = 1;
  102fd0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102fd7:	e9 6f ff ff ff       	jmp    102f4b <vprintfmt+0x53>
            goto process_precision;
  102fdc:	90                   	nop

        process_precision:
            if (width < 0)
  102fdd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102fe1:	0f 89 64 ff ff ff    	jns    102f4b <vprintfmt+0x53>
                width = precision, precision = -1;
  102fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102fea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102fed:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102ff4:	e9 52 ff ff ff       	jmp    102f4b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102ff9:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  102ffc:	e9 4a ff ff ff       	jmp    102f4b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  103001:	8b 45 14             	mov    0x14(%ebp),%eax
  103004:	8d 50 04             	lea    0x4(%eax),%edx
  103007:	89 55 14             	mov    %edx,0x14(%ebp)
  10300a:	8b 00                	mov    (%eax),%eax
  10300c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10300f:	89 54 24 04          	mov    %edx,0x4(%esp)
  103013:	89 04 24             	mov    %eax,(%esp)
  103016:	8b 45 08             	mov    0x8(%ebp),%eax
  103019:	ff d0                	call   *%eax
            break;
  10301b:	e9 a4 02 00 00       	jmp    1032c4 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  103020:	8b 45 14             	mov    0x14(%ebp),%eax
  103023:	8d 50 04             	lea    0x4(%eax),%edx
  103026:	89 55 14             	mov    %edx,0x14(%ebp)
  103029:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10302b:	85 db                	test   %ebx,%ebx
  10302d:	79 02                	jns    103031 <vprintfmt+0x139>
                err = -err;
  10302f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  103031:	83 fb 06             	cmp    $0x6,%ebx
  103034:	7f 0b                	jg     103041 <vprintfmt+0x149>
  103036:	8b 34 9d 14 40 10 00 	mov    0x104014(,%ebx,4),%esi
  10303d:	85 f6                	test   %esi,%esi
  10303f:	75 23                	jne    103064 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  103041:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103045:	c7 44 24 08 41 40 10 	movl   $0x104041,0x8(%esp)
  10304c:	00 
  10304d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103050:	89 44 24 04          	mov    %eax,0x4(%esp)
  103054:	8b 45 08             	mov    0x8(%ebp),%eax
  103057:	89 04 24             	mov    %eax,(%esp)
  10305a:	e8 68 fe ff ff       	call   102ec7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10305f:	e9 60 02 00 00       	jmp    1032c4 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  103064:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103068:	c7 44 24 08 4a 40 10 	movl   $0x10404a,0x8(%esp)
  10306f:	00 
  103070:	8b 45 0c             	mov    0xc(%ebp),%eax
  103073:	89 44 24 04          	mov    %eax,0x4(%esp)
  103077:	8b 45 08             	mov    0x8(%ebp),%eax
  10307a:	89 04 24             	mov    %eax,(%esp)
  10307d:	e8 45 fe ff ff       	call   102ec7 <printfmt>
            break;
  103082:	e9 3d 02 00 00       	jmp    1032c4 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103087:	8b 45 14             	mov    0x14(%ebp),%eax
  10308a:	8d 50 04             	lea    0x4(%eax),%edx
  10308d:	89 55 14             	mov    %edx,0x14(%ebp)
  103090:	8b 30                	mov    (%eax),%esi
  103092:	85 f6                	test   %esi,%esi
  103094:	75 05                	jne    10309b <vprintfmt+0x1a3>
                p = "(null)";
  103096:	be 4d 40 10 00       	mov    $0x10404d,%esi
            }
            if (width > 0 && padc != '-') {
  10309b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10309f:	7e 76                	jle    103117 <vprintfmt+0x21f>
  1030a1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1030a5:	74 70                	je     103117 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1030a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030ae:	89 34 24             	mov    %esi,(%esp)
  1030b1:	e8 16 03 00 00       	call   1033cc <strnlen>
  1030b6:	89 c2                	mov    %eax,%edx
  1030b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030bb:	29 d0                	sub    %edx,%eax
  1030bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030c0:	eb 16                	jmp    1030d8 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  1030c2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1030c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1030cd:	89 04 24             	mov    %eax,(%esp)
  1030d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1030d3:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  1030d5:	ff 4d e8             	decl   -0x18(%ebp)
  1030d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1030dc:	7f e4                	jg     1030c2 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1030de:	eb 37                	jmp    103117 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  1030e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1030e4:	74 1f                	je     103105 <vprintfmt+0x20d>
  1030e6:	83 fb 1f             	cmp    $0x1f,%ebx
  1030e9:	7e 05                	jle    1030f0 <vprintfmt+0x1f8>
  1030eb:	83 fb 7e             	cmp    $0x7e,%ebx
  1030ee:	7e 15                	jle    103105 <vprintfmt+0x20d>
                    putch('?', putdat);
  1030f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030f7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1030fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103101:	ff d0                	call   *%eax
  103103:	eb 0f                	jmp    103114 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  103105:	8b 45 0c             	mov    0xc(%ebp),%eax
  103108:	89 44 24 04          	mov    %eax,0x4(%esp)
  10310c:	89 1c 24             	mov    %ebx,(%esp)
  10310f:	8b 45 08             	mov    0x8(%ebp),%eax
  103112:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103114:	ff 4d e8             	decl   -0x18(%ebp)
  103117:	89 f0                	mov    %esi,%eax
  103119:	8d 70 01             	lea    0x1(%eax),%esi
  10311c:	0f b6 00             	movzbl (%eax),%eax
  10311f:	0f be d8             	movsbl %al,%ebx
  103122:	85 db                	test   %ebx,%ebx
  103124:	74 27                	je     10314d <vprintfmt+0x255>
  103126:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10312a:	78 b4                	js     1030e0 <vprintfmt+0x1e8>
  10312c:	ff 4d e4             	decl   -0x1c(%ebp)
  10312f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103133:	79 ab                	jns    1030e0 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  103135:	eb 16                	jmp    10314d <vprintfmt+0x255>
                putch(' ', putdat);
  103137:	8b 45 0c             	mov    0xc(%ebp),%eax
  10313a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10313e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103145:	8b 45 08             	mov    0x8(%ebp),%eax
  103148:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  10314a:	ff 4d e8             	decl   -0x18(%ebp)
  10314d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103151:	7f e4                	jg     103137 <vprintfmt+0x23f>
            }
            break;
  103153:	e9 6c 01 00 00       	jmp    1032c4 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103158:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10315b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10315f:	8d 45 14             	lea    0x14(%ebp),%eax
  103162:	89 04 24             	mov    %eax,(%esp)
  103165:	e8 16 fd ff ff       	call   102e80 <getint>
  10316a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10316d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103173:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103176:	85 d2                	test   %edx,%edx
  103178:	79 26                	jns    1031a0 <vprintfmt+0x2a8>
                putch('-', putdat);
  10317a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10317d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103181:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  103188:	8b 45 08             	mov    0x8(%ebp),%eax
  10318b:	ff d0                	call   *%eax
                num = -(long long)num;
  10318d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103190:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103193:	f7 d8                	neg    %eax
  103195:	83 d2 00             	adc    $0x0,%edx
  103198:	f7 da                	neg    %edx
  10319a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10319d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1031a0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1031a7:	e9 a8 00 00 00       	jmp    103254 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1031ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1031af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031b3:	8d 45 14             	lea    0x14(%ebp),%eax
  1031b6:	89 04 24             	mov    %eax,(%esp)
  1031b9:	e8 73 fc ff ff       	call   102e31 <getuint>
  1031be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1031c4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1031cb:	e9 84 00 00 00       	jmp    103254 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1031d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1031d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031d7:	8d 45 14             	lea    0x14(%ebp),%eax
  1031da:	89 04 24             	mov    %eax,(%esp)
  1031dd:	e8 4f fc ff ff       	call   102e31 <getuint>
  1031e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031e5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1031e8:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1031ef:	eb 63                	jmp    103254 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031f8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1031ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103202:	ff d0                	call   *%eax
            putch('x', putdat);
  103204:	8b 45 0c             	mov    0xc(%ebp),%eax
  103207:	89 44 24 04          	mov    %eax,0x4(%esp)
  10320b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  103212:	8b 45 08             	mov    0x8(%ebp),%eax
  103215:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103217:	8b 45 14             	mov    0x14(%ebp),%eax
  10321a:	8d 50 04             	lea    0x4(%eax),%edx
  10321d:	89 55 14             	mov    %edx,0x14(%ebp)
  103220:	8b 00                	mov    (%eax),%eax
  103222:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103225:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10322c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103233:	eb 1f                	jmp    103254 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103235:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103238:	89 44 24 04          	mov    %eax,0x4(%esp)
  10323c:	8d 45 14             	lea    0x14(%ebp),%eax
  10323f:	89 04 24             	mov    %eax,(%esp)
  103242:	e8 ea fb ff ff       	call   102e31 <getuint>
  103247:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10324a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10324d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103254:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103258:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10325b:	89 54 24 18          	mov    %edx,0x18(%esp)
  10325f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103262:	89 54 24 14          	mov    %edx,0x14(%esp)
  103266:	89 44 24 10          	mov    %eax,0x10(%esp)
  10326a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10326d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103270:	89 44 24 08          	mov    %eax,0x8(%esp)
  103274:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103278:	8b 45 0c             	mov    0xc(%ebp),%eax
  10327b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10327f:	8b 45 08             	mov    0x8(%ebp),%eax
  103282:	89 04 24             	mov    %eax,(%esp)
  103285:	e8 a5 fa ff ff       	call   102d2f <printnum>
            break;
  10328a:	eb 38                	jmp    1032c4 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10328c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10328f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103293:	89 1c 24             	mov    %ebx,(%esp)
  103296:	8b 45 08             	mov    0x8(%ebp),%eax
  103299:	ff d0                	call   *%eax
            break;
  10329b:	eb 27                	jmp    1032c4 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10329d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032a4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1032ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ae:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1032b0:	ff 4d 10             	decl   0x10(%ebp)
  1032b3:	eb 03                	jmp    1032b8 <vprintfmt+0x3c0>
  1032b5:	ff 4d 10             	decl   0x10(%ebp)
  1032b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1032bb:	48                   	dec    %eax
  1032bc:	0f b6 00             	movzbl (%eax),%eax
  1032bf:	3c 25                	cmp    $0x25,%al
  1032c1:	75 f2                	jne    1032b5 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  1032c3:	90                   	nop
    while (1) {
  1032c4:	e9 37 fc ff ff       	jmp    102f00 <vprintfmt+0x8>
                return;
  1032c9:	90                   	nop
        }
    }
}
  1032ca:	83 c4 40             	add    $0x40,%esp
  1032cd:	5b                   	pop    %ebx
  1032ce:	5e                   	pop    %esi
  1032cf:	5d                   	pop    %ebp
  1032d0:	c3                   	ret    

001032d1 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1032d1:	55                   	push   %ebp
  1032d2:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1032d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032d7:	8b 40 08             	mov    0x8(%eax),%eax
  1032da:	8d 50 01             	lea    0x1(%eax),%edx
  1032dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e0:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1032e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e6:	8b 10                	mov    (%eax),%edx
  1032e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032eb:	8b 40 04             	mov    0x4(%eax),%eax
  1032ee:	39 c2                	cmp    %eax,%edx
  1032f0:	73 12                	jae    103304 <sprintputch+0x33>
        *b->buf ++ = ch;
  1032f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032f5:	8b 00                	mov    (%eax),%eax
  1032f7:	8d 48 01             	lea    0x1(%eax),%ecx
  1032fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1032fd:	89 0a                	mov    %ecx,(%edx)
  1032ff:	8b 55 08             	mov    0x8(%ebp),%edx
  103302:	88 10                	mov    %dl,(%eax)
    }
}
  103304:	90                   	nop
  103305:	5d                   	pop    %ebp
  103306:	c3                   	ret    

00103307 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103307:	55                   	push   %ebp
  103308:	89 e5                	mov    %esp,%ebp
  10330a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10330d:	8d 45 14             	lea    0x14(%ebp),%eax
  103310:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103313:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103316:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10331a:	8b 45 10             	mov    0x10(%ebp),%eax
  10331d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103321:	8b 45 0c             	mov    0xc(%ebp),%eax
  103324:	89 44 24 04          	mov    %eax,0x4(%esp)
  103328:	8b 45 08             	mov    0x8(%ebp),%eax
  10332b:	89 04 24             	mov    %eax,(%esp)
  10332e:	e8 0a 00 00 00       	call   10333d <vsnprintf>
  103333:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  103336:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103339:	89 ec                	mov    %ebp,%esp
  10333b:	5d                   	pop    %ebp
  10333c:	c3                   	ret    

0010333d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  10333d:	55                   	push   %ebp
  10333e:	89 e5                	mov    %esp,%ebp
  103340:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  103343:	8b 45 08             	mov    0x8(%ebp),%eax
  103346:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103349:	8b 45 0c             	mov    0xc(%ebp),%eax
  10334c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10334f:	8b 45 08             	mov    0x8(%ebp),%eax
  103352:	01 d0                	add    %edx,%eax
  103354:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103357:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10335e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103362:	74 0a                	je     10336e <vsnprintf+0x31>
  103364:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10336a:	39 c2                	cmp    %eax,%edx
  10336c:	76 07                	jbe    103375 <vsnprintf+0x38>
        return -E_INVAL;
  10336e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103373:	eb 2a                	jmp    10339f <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103375:	8b 45 14             	mov    0x14(%ebp),%eax
  103378:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10337c:	8b 45 10             	mov    0x10(%ebp),%eax
  10337f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103383:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103386:	89 44 24 04          	mov    %eax,0x4(%esp)
  10338a:	c7 04 24 d1 32 10 00 	movl   $0x1032d1,(%esp)
  103391:	e8 62 fb ff ff       	call   102ef8 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103396:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103399:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10339c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10339f:	89 ec                	mov    %ebp,%esp
  1033a1:	5d                   	pop    %ebp
  1033a2:	c3                   	ret    

001033a3 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1033a3:	55                   	push   %ebp
  1033a4:	89 e5                	mov    %esp,%ebp
  1033a6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1033a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1033b0:	eb 03                	jmp    1033b5 <strlen+0x12>
        cnt ++;
  1033b2:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1033b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b8:	8d 50 01             	lea    0x1(%eax),%edx
  1033bb:	89 55 08             	mov    %edx,0x8(%ebp)
  1033be:	0f b6 00             	movzbl (%eax),%eax
  1033c1:	84 c0                	test   %al,%al
  1033c3:	75 ed                	jne    1033b2 <strlen+0xf>
    }
    return cnt;
  1033c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1033c8:	89 ec                	mov    %ebp,%esp
  1033ca:	5d                   	pop    %ebp
  1033cb:	c3                   	ret    

001033cc <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1033cc:	55                   	push   %ebp
  1033cd:	89 e5                	mov    %esp,%ebp
  1033cf:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1033d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1033d9:	eb 03                	jmp    1033de <strnlen+0x12>
        cnt ++;
  1033db:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1033de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1033e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1033e4:	73 10                	jae    1033f6 <strnlen+0x2a>
  1033e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e9:	8d 50 01             	lea    0x1(%eax),%edx
  1033ec:	89 55 08             	mov    %edx,0x8(%ebp)
  1033ef:	0f b6 00             	movzbl (%eax),%eax
  1033f2:	84 c0                	test   %al,%al
  1033f4:	75 e5                	jne    1033db <strnlen+0xf>
    }
    return cnt;
  1033f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1033f9:	89 ec                	mov    %ebp,%esp
  1033fb:	5d                   	pop    %ebp
  1033fc:	c3                   	ret    

001033fd <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1033fd:	55                   	push   %ebp
  1033fe:	89 e5                	mov    %esp,%ebp
  103400:	57                   	push   %edi
  103401:	56                   	push   %esi
  103402:	83 ec 20             	sub    $0x20,%esp
  103405:	8b 45 08             	mov    0x8(%ebp),%eax
  103408:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10340b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10340e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  103411:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103417:	89 d1                	mov    %edx,%ecx
  103419:	89 c2                	mov    %eax,%edx
  10341b:	89 ce                	mov    %ecx,%esi
  10341d:	89 d7                	mov    %edx,%edi
  10341f:	ac                   	lods   %ds:(%esi),%al
  103420:	aa                   	stos   %al,%es:(%edi)
  103421:	84 c0                	test   %al,%al
  103423:	75 fa                	jne    10341f <strcpy+0x22>
  103425:	89 fa                	mov    %edi,%edx
  103427:	89 f1                	mov    %esi,%ecx
  103429:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10342c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10342f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  103432:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  103435:	83 c4 20             	add    $0x20,%esp
  103438:	5e                   	pop    %esi
  103439:	5f                   	pop    %edi
  10343a:	5d                   	pop    %ebp
  10343b:	c3                   	ret    

0010343c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10343c:	55                   	push   %ebp
  10343d:	89 e5                	mov    %esp,%ebp
  10343f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  103442:	8b 45 08             	mov    0x8(%ebp),%eax
  103445:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  103448:	eb 1e                	jmp    103468 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10344a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10344d:	0f b6 10             	movzbl (%eax),%edx
  103450:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103453:	88 10                	mov    %dl,(%eax)
  103455:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103458:	0f b6 00             	movzbl (%eax),%eax
  10345b:	84 c0                	test   %al,%al
  10345d:	74 03                	je     103462 <strncpy+0x26>
            src ++;
  10345f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  103462:	ff 45 fc             	incl   -0x4(%ebp)
  103465:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  103468:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10346c:	75 dc                	jne    10344a <strncpy+0xe>
    }
    return dst;
  10346e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103471:	89 ec                	mov    %ebp,%esp
  103473:	5d                   	pop    %ebp
  103474:	c3                   	ret    

00103475 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  103475:	55                   	push   %ebp
  103476:	89 e5                	mov    %esp,%ebp
  103478:	57                   	push   %edi
  103479:	56                   	push   %esi
  10347a:	83 ec 20             	sub    $0x20,%esp
  10347d:	8b 45 08             	mov    0x8(%ebp),%eax
  103480:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103483:	8b 45 0c             	mov    0xc(%ebp),%eax
  103486:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  103489:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10348c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10348f:	89 d1                	mov    %edx,%ecx
  103491:	89 c2                	mov    %eax,%edx
  103493:	89 ce                	mov    %ecx,%esi
  103495:	89 d7                	mov    %edx,%edi
  103497:	ac                   	lods   %ds:(%esi),%al
  103498:	ae                   	scas   %es:(%edi),%al
  103499:	75 08                	jne    1034a3 <strcmp+0x2e>
  10349b:	84 c0                	test   %al,%al
  10349d:	75 f8                	jne    103497 <strcmp+0x22>
  10349f:	31 c0                	xor    %eax,%eax
  1034a1:	eb 04                	jmp    1034a7 <strcmp+0x32>
  1034a3:	19 c0                	sbb    %eax,%eax
  1034a5:	0c 01                	or     $0x1,%al
  1034a7:	89 fa                	mov    %edi,%edx
  1034a9:	89 f1                	mov    %esi,%ecx
  1034ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1034ae:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1034b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1034b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1034b7:	83 c4 20             	add    $0x20,%esp
  1034ba:	5e                   	pop    %esi
  1034bb:	5f                   	pop    %edi
  1034bc:	5d                   	pop    %ebp
  1034bd:	c3                   	ret    

001034be <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1034be:	55                   	push   %ebp
  1034bf:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1034c1:	eb 09                	jmp    1034cc <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1034c3:	ff 4d 10             	decl   0x10(%ebp)
  1034c6:	ff 45 08             	incl   0x8(%ebp)
  1034c9:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1034cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1034d0:	74 1a                	je     1034ec <strncmp+0x2e>
  1034d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034d5:	0f b6 00             	movzbl (%eax),%eax
  1034d8:	84 c0                	test   %al,%al
  1034da:	74 10                	je     1034ec <strncmp+0x2e>
  1034dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1034df:	0f b6 10             	movzbl (%eax),%edx
  1034e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034e5:	0f b6 00             	movzbl (%eax),%eax
  1034e8:	38 c2                	cmp    %al,%dl
  1034ea:	74 d7                	je     1034c3 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1034ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1034f0:	74 18                	je     10350a <strncmp+0x4c>
  1034f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f5:	0f b6 00             	movzbl (%eax),%eax
  1034f8:	0f b6 d0             	movzbl %al,%edx
  1034fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034fe:	0f b6 00             	movzbl (%eax),%eax
  103501:	0f b6 c8             	movzbl %al,%ecx
  103504:	89 d0                	mov    %edx,%eax
  103506:	29 c8                	sub    %ecx,%eax
  103508:	eb 05                	jmp    10350f <strncmp+0x51>
  10350a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10350f:	5d                   	pop    %ebp
  103510:	c3                   	ret    

00103511 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  103511:	55                   	push   %ebp
  103512:	89 e5                	mov    %esp,%ebp
  103514:	83 ec 04             	sub    $0x4,%esp
  103517:	8b 45 0c             	mov    0xc(%ebp),%eax
  10351a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10351d:	eb 13                	jmp    103532 <strchr+0x21>
        if (*s == c) {
  10351f:	8b 45 08             	mov    0x8(%ebp),%eax
  103522:	0f b6 00             	movzbl (%eax),%eax
  103525:	38 45 fc             	cmp    %al,-0x4(%ebp)
  103528:	75 05                	jne    10352f <strchr+0x1e>
            return (char *)s;
  10352a:	8b 45 08             	mov    0x8(%ebp),%eax
  10352d:	eb 12                	jmp    103541 <strchr+0x30>
        }
        s ++;
  10352f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  103532:	8b 45 08             	mov    0x8(%ebp),%eax
  103535:	0f b6 00             	movzbl (%eax),%eax
  103538:	84 c0                	test   %al,%al
  10353a:	75 e3                	jne    10351f <strchr+0xe>
    }
    return NULL;
  10353c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103541:	89 ec                	mov    %ebp,%esp
  103543:	5d                   	pop    %ebp
  103544:	c3                   	ret    

00103545 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  103545:	55                   	push   %ebp
  103546:	89 e5                	mov    %esp,%ebp
  103548:	83 ec 04             	sub    $0x4,%esp
  10354b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10354e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103551:	eb 0e                	jmp    103561 <strfind+0x1c>
        if (*s == c) {
  103553:	8b 45 08             	mov    0x8(%ebp),%eax
  103556:	0f b6 00             	movzbl (%eax),%eax
  103559:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10355c:	74 0f                	je     10356d <strfind+0x28>
            break;
        }
        s ++;
  10355e:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  103561:	8b 45 08             	mov    0x8(%ebp),%eax
  103564:	0f b6 00             	movzbl (%eax),%eax
  103567:	84 c0                	test   %al,%al
  103569:	75 e8                	jne    103553 <strfind+0xe>
  10356b:	eb 01                	jmp    10356e <strfind+0x29>
            break;
  10356d:	90                   	nop
    }
    return (char *)s;
  10356e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103571:	89 ec                	mov    %ebp,%esp
  103573:	5d                   	pop    %ebp
  103574:	c3                   	ret    

00103575 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  103575:	55                   	push   %ebp
  103576:	89 e5                	mov    %esp,%ebp
  103578:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10357b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  103582:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  103589:	eb 03                	jmp    10358e <strtol+0x19>
        s ++;
  10358b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10358e:	8b 45 08             	mov    0x8(%ebp),%eax
  103591:	0f b6 00             	movzbl (%eax),%eax
  103594:	3c 20                	cmp    $0x20,%al
  103596:	74 f3                	je     10358b <strtol+0x16>
  103598:	8b 45 08             	mov    0x8(%ebp),%eax
  10359b:	0f b6 00             	movzbl (%eax),%eax
  10359e:	3c 09                	cmp    $0x9,%al
  1035a0:	74 e9                	je     10358b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1035a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1035a5:	0f b6 00             	movzbl (%eax),%eax
  1035a8:	3c 2b                	cmp    $0x2b,%al
  1035aa:	75 05                	jne    1035b1 <strtol+0x3c>
        s ++;
  1035ac:	ff 45 08             	incl   0x8(%ebp)
  1035af:	eb 14                	jmp    1035c5 <strtol+0x50>
    }
    else if (*s == '-') {
  1035b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1035b4:	0f b6 00             	movzbl (%eax),%eax
  1035b7:	3c 2d                	cmp    $0x2d,%al
  1035b9:	75 0a                	jne    1035c5 <strtol+0x50>
        s ++, neg = 1;
  1035bb:	ff 45 08             	incl   0x8(%ebp)
  1035be:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1035c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1035c9:	74 06                	je     1035d1 <strtol+0x5c>
  1035cb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1035cf:	75 22                	jne    1035f3 <strtol+0x7e>
  1035d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1035d4:	0f b6 00             	movzbl (%eax),%eax
  1035d7:	3c 30                	cmp    $0x30,%al
  1035d9:	75 18                	jne    1035f3 <strtol+0x7e>
  1035db:	8b 45 08             	mov    0x8(%ebp),%eax
  1035de:	40                   	inc    %eax
  1035df:	0f b6 00             	movzbl (%eax),%eax
  1035e2:	3c 78                	cmp    $0x78,%al
  1035e4:	75 0d                	jne    1035f3 <strtol+0x7e>
        s += 2, base = 16;
  1035e6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1035ea:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1035f1:	eb 29                	jmp    10361c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1035f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1035f7:	75 16                	jne    10360f <strtol+0x9a>
  1035f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1035fc:	0f b6 00             	movzbl (%eax),%eax
  1035ff:	3c 30                	cmp    $0x30,%al
  103601:	75 0c                	jne    10360f <strtol+0x9a>
        s ++, base = 8;
  103603:	ff 45 08             	incl   0x8(%ebp)
  103606:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10360d:	eb 0d                	jmp    10361c <strtol+0xa7>
    }
    else if (base == 0) {
  10360f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103613:	75 07                	jne    10361c <strtol+0xa7>
        base = 10;
  103615:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10361c:	8b 45 08             	mov    0x8(%ebp),%eax
  10361f:	0f b6 00             	movzbl (%eax),%eax
  103622:	3c 2f                	cmp    $0x2f,%al
  103624:	7e 1b                	jle    103641 <strtol+0xcc>
  103626:	8b 45 08             	mov    0x8(%ebp),%eax
  103629:	0f b6 00             	movzbl (%eax),%eax
  10362c:	3c 39                	cmp    $0x39,%al
  10362e:	7f 11                	jg     103641 <strtol+0xcc>
            dig = *s - '0';
  103630:	8b 45 08             	mov    0x8(%ebp),%eax
  103633:	0f b6 00             	movzbl (%eax),%eax
  103636:	0f be c0             	movsbl %al,%eax
  103639:	83 e8 30             	sub    $0x30,%eax
  10363c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10363f:	eb 48                	jmp    103689 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  103641:	8b 45 08             	mov    0x8(%ebp),%eax
  103644:	0f b6 00             	movzbl (%eax),%eax
  103647:	3c 60                	cmp    $0x60,%al
  103649:	7e 1b                	jle    103666 <strtol+0xf1>
  10364b:	8b 45 08             	mov    0x8(%ebp),%eax
  10364e:	0f b6 00             	movzbl (%eax),%eax
  103651:	3c 7a                	cmp    $0x7a,%al
  103653:	7f 11                	jg     103666 <strtol+0xf1>
            dig = *s - 'a' + 10;
  103655:	8b 45 08             	mov    0x8(%ebp),%eax
  103658:	0f b6 00             	movzbl (%eax),%eax
  10365b:	0f be c0             	movsbl %al,%eax
  10365e:	83 e8 57             	sub    $0x57,%eax
  103661:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103664:	eb 23                	jmp    103689 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  103666:	8b 45 08             	mov    0x8(%ebp),%eax
  103669:	0f b6 00             	movzbl (%eax),%eax
  10366c:	3c 40                	cmp    $0x40,%al
  10366e:	7e 3b                	jle    1036ab <strtol+0x136>
  103670:	8b 45 08             	mov    0x8(%ebp),%eax
  103673:	0f b6 00             	movzbl (%eax),%eax
  103676:	3c 5a                	cmp    $0x5a,%al
  103678:	7f 31                	jg     1036ab <strtol+0x136>
            dig = *s - 'A' + 10;
  10367a:	8b 45 08             	mov    0x8(%ebp),%eax
  10367d:	0f b6 00             	movzbl (%eax),%eax
  103680:	0f be c0             	movsbl %al,%eax
  103683:	83 e8 37             	sub    $0x37,%eax
  103686:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  103689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10368c:	3b 45 10             	cmp    0x10(%ebp),%eax
  10368f:	7d 19                	jge    1036aa <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  103691:	ff 45 08             	incl   0x8(%ebp)
  103694:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103697:	0f af 45 10          	imul   0x10(%ebp),%eax
  10369b:	89 c2                	mov    %eax,%edx
  10369d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a0:	01 d0                	add    %edx,%eax
  1036a2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1036a5:	e9 72 ff ff ff       	jmp    10361c <strtol+0xa7>
            break;
  1036aa:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1036ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1036af:	74 08                	je     1036b9 <strtol+0x144>
        *endptr = (char *) s;
  1036b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036b4:	8b 55 08             	mov    0x8(%ebp),%edx
  1036b7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1036b9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1036bd:	74 07                	je     1036c6 <strtol+0x151>
  1036bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1036c2:	f7 d8                	neg    %eax
  1036c4:	eb 03                	jmp    1036c9 <strtol+0x154>
  1036c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1036c9:	89 ec                	mov    %ebp,%esp
  1036cb:	5d                   	pop    %ebp
  1036cc:	c3                   	ret    

001036cd <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1036cd:	55                   	push   %ebp
  1036ce:	89 e5                	mov    %esp,%ebp
  1036d0:	83 ec 28             	sub    $0x28,%esp
  1036d3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1036d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036d9:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1036dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  1036e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1036e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1036e6:	88 55 f7             	mov    %dl,-0x9(%ebp)
  1036e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1036ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1036ef:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1036f2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1036f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1036f9:	89 d7                	mov    %edx,%edi
  1036fb:	f3 aa                	rep stos %al,%es:(%edi)
  1036fd:	89 fa                	mov    %edi,%edx
  1036ff:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103702:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  103705:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  103708:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10370b:	89 ec                	mov    %ebp,%esp
  10370d:	5d                   	pop    %ebp
  10370e:	c3                   	ret    

0010370f <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10370f:	55                   	push   %ebp
  103710:	89 e5                	mov    %esp,%ebp
  103712:	57                   	push   %edi
  103713:	56                   	push   %esi
  103714:	53                   	push   %ebx
  103715:	83 ec 30             	sub    $0x30,%esp
  103718:	8b 45 08             	mov    0x8(%ebp),%eax
  10371b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10371e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103724:	8b 45 10             	mov    0x10(%ebp),%eax
  103727:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  10372a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10372d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103730:	73 42                	jae    103774 <memmove+0x65>
  103732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10373b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10373e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103741:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103747:	c1 e8 02             	shr    $0x2,%eax
  10374a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10374c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10374f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103752:	89 d7                	mov    %edx,%edi
  103754:	89 c6                	mov    %eax,%esi
  103756:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103758:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10375b:	83 e1 03             	and    $0x3,%ecx
  10375e:	74 02                	je     103762 <memmove+0x53>
  103760:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103762:	89 f0                	mov    %esi,%eax
  103764:	89 fa                	mov    %edi,%edx
  103766:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  103769:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10376c:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  10376f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  103772:	eb 36                	jmp    1037aa <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  103774:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103777:	8d 50 ff             	lea    -0x1(%eax),%edx
  10377a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10377d:	01 c2                	add    %eax,%edx
  10377f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103782:	8d 48 ff             	lea    -0x1(%eax),%ecx
  103785:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103788:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  10378b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10378e:	89 c1                	mov    %eax,%ecx
  103790:	89 d8                	mov    %ebx,%eax
  103792:	89 d6                	mov    %edx,%esi
  103794:	89 c7                	mov    %eax,%edi
  103796:	fd                   	std    
  103797:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103799:	fc                   	cld    
  10379a:	89 f8                	mov    %edi,%eax
  10379c:	89 f2                	mov    %esi,%edx
  10379e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1037a1:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1037a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1037a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1037aa:	83 c4 30             	add    $0x30,%esp
  1037ad:	5b                   	pop    %ebx
  1037ae:	5e                   	pop    %esi
  1037af:	5f                   	pop    %edi
  1037b0:	5d                   	pop    %ebp
  1037b1:	c3                   	ret    

001037b2 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1037b2:	55                   	push   %ebp
  1037b3:	89 e5                	mov    %esp,%ebp
  1037b5:	57                   	push   %edi
  1037b6:	56                   	push   %esi
  1037b7:	83 ec 20             	sub    $0x20,%esp
  1037ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1037bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1037c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1037c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1037cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037cf:	c1 e8 02             	shr    $0x2,%eax
  1037d2:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1037d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1037d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037da:	89 d7                	mov    %edx,%edi
  1037dc:	89 c6                	mov    %eax,%esi
  1037de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1037e0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1037e3:	83 e1 03             	and    $0x3,%ecx
  1037e6:	74 02                	je     1037ea <memcpy+0x38>
  1037e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1037ea:	89 f0                	mov    %esi,%eax
  1037ec:	89 fa                	mov    %edi,%edx
  1037ee:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1037f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1037f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1037f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1037fa:	83 c4 20             	add    $0x20,%esp
  1037fd:	5e                   	pop    %esi
  1037fe:	5f                   	pop    %edi
  1037ff:	5d                   	pop    %ebp
  103800:	c3                   	ret    

00103801 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  103801:	55                   	push   %ebp
  103802:	89 e5                	mov    %esp,%ebp
  103804:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  103807:	8b 45 08             	mov    0x8(%ebp),%eax
  10380a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  10380d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103810:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  103813:	eb 2e                	jmp    103843 <memcmp+0x42>
        if (*s1 != *s2) {
  103815:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103818:	0f b6 10             	movzbl (%eax),%edx
  10381b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10381e:	0f b6 00             	movzbl (%eax),%eax
  103821:	38 c2                	cmp    %al,%dl
  103823:	74 18                	je     10383d <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  103825:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103828:	0f b6 00             	movzbl (%eax),%eax
  10382b:	0f b6 d0             	movzbl %al,%edx
  10382e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103831:	0f b6 00             	movzbl (%eax),%eax
  103834:	0f b6 c8             	movzbl %al,%ecx
  103837:	89 d0                	mov    %edx,%eax
  103839:	29 c8                	sub    %ecx,%eax
  10383b:	eb 18                	jmp    103855 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  10383d:	ff 45 fc             	incl   -0x4(%ebp)
  103840:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  103843:	8b 45 10             	mov    0x10(%ebp),%eax
  103846:	8d 50 ff             	lea    -0x1(%eax),%edx
  103849:	89 55 10             	mov    %edx,0x10(%ebp)
  10384c:	85 c0                	test   %eax,%eax
  10384e:	75 c5                	jne    103815 <memcmp+0x14>
    }
    return 0;
  103850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103855:	89 ec                	mov    %ebp,%esp
  103857:	5d                   	pop    %ebp
  103858:	c3                   	ret    
