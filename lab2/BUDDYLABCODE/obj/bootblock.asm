
obj/bootblock.o:     file format elf32-i386


Disassembly of section .startup:

00007c00 <start>:

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    7c00:	fa                   	cli    
    cld                                             # String operations increment
    7c01:	fc                   	cld    

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
    movw %ax, %ds                                   # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
    movw %ax, %ss                                   # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c0a:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c0c:	a8 02                	test   $0x2,%al
    jnz seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c14:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c16:	a8 02                	test   $0x2,%al
    jnz seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
    7c1c:	e6 60                	out    %al,$0x60

00007c1e <probe_memory>:

probe_memory:
    movl $0, 0x8000
    7c1e:	66 c7 06 00 80       	movw   $0x8000,(%esi)
    7c23:	00 00                	add    %al,(%eax)
    7c25:	00 00                	add    %al,(%eax)
    xorl %ebx, %ebx
    7c27:	66 31 db             	xor    %bx,%bx
    movw $0x8004, %di
    7c2a:	bf                   	.byte 0xbf
    7c2b:	04 80                	add    $0x80,%al

00007c2d <start_probe>:
start_probe:
    movl $0xE820, %eax
    7c2d:	66 b8 20 e8          	mov    $0xe820,%ax
    7c31:	00 00                	add    %al,(%eax)
    movl $20, %ecx
    7c33:	66 b9 14 00          	mov    $0x14,%cx
    7c37:	00 00                	add    %al,(%eax)
    movl $SMAP, %edx
    7c39:	66 ba 50 41          	mov    $0x4150,%dx
    7c3d:	4d                   	dec    %ebp
    7c3e:	53                   	push   %ebx
    int $0x15
    7c3f:	cd 15                	int    $0x15
    jnc cont
    7c41:	73 08                	jae    7c4b <cont>
    movw $12345, 0x8000
    7c43:	c7 06 00 80 39 30    	movl   $0x30398000,(%esi)
    jmp finish_probe
    7c49:	eb 0e                	jmp    7c59 <finish_probe>

00007c4b <cont>:
cont:
    addw $20, %di
    7c4b:	83 c7 14             	add    $0x14,%edi
    incl 0x8000
    7c4e:	66 ff 06             	incw   (%esi)
    7c51:	00 80 66 83 fb 00    	add    %al,0xfb8366(%eax)
    cmpl $0, %ebx
    jnz start_probe
    7c57:	75 d4                	jne    7c2d <start_probe>

00007c59 <finish_probe>:

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    lgdt gdtdesc
    7c59:	0f 01 16             	lgdtl  (%esi)
    7c5c:	b8 7d 0f 20 c0       	mov    $0xc0200f7d,%eax
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    7c61:	66 83 c8 01          	or     $0x1,%ax
    movl %eax, %cr0
    7c65:	0f 22 c0             	mov    %eax,%cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg
    7c68:	ea                   	.byte 0xea
    7c69:	6d                   	insl   (%dx),%es:(%edi)
    7c6a:	7c 08                	jl     7c74 <protcseg+0x7>
	...

00007c6d <protcseg>:

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    7c6d:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds                                   # -> DS: Data Segment
    7c71:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> ES: Extra Segment
    7c73:	8e c0                	mov    %eax,%es
    movw %ax, %fs                                   # -> FS
    7c75:	8e e0                	mov    %eax,%fs
    movw %ax, %gs                                   # -> GS
    7c77:	8e e8                	mov    %eax,%gs
    movw %ax, %ss                                   # -> SS: Stack Segment
    7c79:	8e d0                	mov    %eax,%ss

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    7c7b:	bd 00 00 00 00       	mov    $0x0,%ebp
    movl $start, %esp
    7c80:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    call bootmain
    7c85:	e8 9f 00 00 00       	call   7d29 <bootmain>

00007c8a <spin>:

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin
    7c8a:	eb fe                	jmp    7c8a <spin>

Disassembly of section .text:

00007c8c <readseg>:
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7c8c:	55                   	push   %ebp
    7c8d:	89 e5                	mov    %esp,%ebp
    7c8f:	57                   	push   %edi
    7c90:	56                   	push   %esi
    7c91:	89 c6                	mov    %eax,%esi
    7c93:	53                   	push   %ebx
    uintptr_t end_va = va + count;
    7c94:	01 d0                	add    %edx,%eax
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7c96:	83 ec 08             	sub    $0x8,%esp
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7c99:	bb f7 01 00 00       	mov    $0x1f7,%ebx
    uintptr_t end_va = va + count;
    7c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7ca1:	89 c8                	mov    %ecx,%eax

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;
    7ca3:	c1 e9 09             	shr    $0x9,%ecx
    va -= offset % SECTSIZE;
    7ca6:	25 ff 01 00 00       	and    $0x1ff,%eax
    7cab:	29 c6                	sub    %eax,%esi
    uint32_t secno = (offset / SECTSIZE) + 1;
    7cad:	8d 41 01             	lea    0x1(%ecx),%eax
    7cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7cb3:	3b 75 ec             	cmp    -0x14(%ebp),%esi
    7cb6:	73 6a                	jae    7d22 <readseg+0x96>
    7cb8:	89 da                	mov    %ebx,%edx
    7cba:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7cbb:	24 c0                	and    $0xc0,%al
    7cbd:	3c 40                	cmp    $0x40,%al
    7cbf:	75 f7                	jne    7cb8 <readseg+0x2c>
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
    7cc1:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7cc6:	b0 01                	mov    $0x1,%al
    7cc8:	ee                   	out    %al,(%dx)
    7cc9:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7cce:	8a 45 f0             	mov    -0x10(%ebp),%al
    7cd1:	ee                   	out    %al,(%dx)
    outb(0x1F4, (secno >> 8) & 0xFF);
    7cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7cd5:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cda:	c1 e8 08             	shr    $0x8,%eax
    7cdd:	ee                   	out    %al,(%dx)
    outb(0x1F5, (secno >> 16) & 0xFF);
    7cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7ce1:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7ce6:	c1 e8 10             	shr    $0x10,%eax
    7ce9:	ee                   	out    %al,(%dx)
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    7cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
    7ced:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cf2:	c1 e8 18             	shr    $0x18,%eax
    7cf5:	24 0f                	and    $0xf,%al
    7cf7:	0c e0                	or     $0xe0,%al
    7cf9:	ee                   	out    %al,(%dx)
    7cfa:	b0 20                	mov    $0x20,%al
    7cfc:	89 da                	mov    %ebx,%edx
    7cfe:	ee                   	out    %al,(%dx)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7cff:	89 da                	mov    %ebx,%edx
    7d01:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7d02:	24 c0                	and    $0xc0,%al
    7d04:	3c 40                	cmp    $0x40,%al
    7d06:	75 f7                	jne    7cff <readseg+0x73>
    asm volatile (
    7d08:	89 f7                	mov    %esi,%edi
    7d0a:	b9 80 00 00 00       	mov    $0x80,%ecx
    7d0f:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d14:	fc                   	cld    
    7d15:	f2 6d                	repnz insl (%dx),%es:(%edi)
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7d17:	ff 45 f0             	incl   -0x10(%ebp)
    7d1a:	81 c6 00 02 00 00    	add    $0x200,%esi
    7d20:	eb 91                	jmp    7cb3 <readseg+0x27>
        readsect((void *)va, secno);
    }
}
    7d22:	58                   	pop    %eax
    7d23:	5a                   	pop    %edx
    7d24:	5b                   	pop    %ebx
    7d25:	5e                   	pop    %esi
    7d26:	5f                   	pop    %edi
    7d27:	5d                   	pop    %ebp
    7d28:	c3                   	ret    

00007d29 <bootmain>:

/* bootmain - the entry of bootloader */
void
bootmain(void) {
    7d29:	f3 0f 1e fb          	endbr32 
    7d2d:	55                   	push   %ebp
    // read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d2e:	31 c9                	xor    %ecx,%ecx
bootmain(void) {
    7d30:	89 e5                	mov    %esp,%ebp
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d32:	ba 00 10 00 00       	mov    $0x1000,%edx
bootmain(void) {
    7d37:	56                   	push   %esi
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d38:	b8 00 00 01 00       	mov    $0x10000,%eax
bootmain(void) {
    7d3d:	53                   	push   %ebx
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    7d3e:	e8 49 ff ff ff       	call   7c8c <readseg>

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {
    7d43:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d4a:	45 4c 46 
    7d4d:	75 3f                	jne    7d8e <bootmain+0x65>
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7d4f:	a1 1c 00 01 00       	mov    0x1001c,%eax
    eph = ph + ELFHDR->e_phnum;
    7d54:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7d5b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    eph = ph + ELFHDR->e_phnum;
    7d61:	c1 e6 05             	shl    $0x5,%esi
    7d64:	01 de                	add    %ebx,%esi
    for (; ph < eph; ph ++) {
    7d66:	39 f3                	cmp    %esi,%ebx
    7d68:	73 18                	jae    7d82 <bootmain+0x59>
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d6a:	8b 43 08             	mov    0x8(%ebx),%eax
    for (; ph < eph; ph ++) {
    7d6d:	83 c3 20             	add    $0x20,%ebx
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d70:	8b 4b e4             	mov    -0x1c(%ebx),%ecx
    7d73:	8b 53 f4             	mov    -0xc(%ebx),%edx
    7d76:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d7b:	e8 0c ff ff ff       	call   7c8c <readseg>
    7d80:	eb e4                	jmp    7d66 <bootmain+0x3d>
    }

    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
    7d82:	a1 18 00 01 00       	mov    0x10018,%eax
    7d87:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d8c:	ff d0                	call   *%eax
}

static inline void
outw(uint16_t port, uint16_t data) {
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
    7d8e:	ba 00 8a ff ff       	mov    $0xffff8a00,%edx
    7d93:	89 d0                	mov    %edx,%eax
    7d95:	66 ef                	out    %ax,(%dx)
    7d97:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d9c:	66 ef                	out    %ax,(%dx)
    7d9e:	eb fe                	jmp    7d9e <bootmain+0x75>
