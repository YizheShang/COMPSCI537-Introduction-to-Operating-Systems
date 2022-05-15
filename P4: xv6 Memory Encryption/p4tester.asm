
_p4tester:     file format elf32-i386


Disassembly of section .text:

00000000 <print_ptentry>:
#include "mmu.h"
#define PGSIZE 4096
#define KERNBASE 0x80000000 
#define VPN(va)         ((uint)(va) >> 12)

void print_ptentry(struct pt_entry entry) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	57                   	push   %edi
   8:	56                   	push   %esi
   9:	53                   	push   %ebx
   a:	83 ec 1c             	sub    $0x1c,%esp
      
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
   d:	0f b6 45 0f          	movzbl 0xf(%ebp),%eax
  11:	83 e0 01             	and    $0x1,%eax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  14:	0f b6 c8             	movzbl %al,%ecx
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  17:	0f b6 45 0e          	movzbl 0xe(%ebp),%eax
  1b:	c0 e8 06             	shr    $0x6,%al
  1e:	83 e0 01             	and    $0x1,%eax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  21:	0f b6 c0             	movzbl %al,%eax
  24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  27:	0f b6 45 0e          	movzbl 0xe(%ebp),%eax
  2b:	c0 e8 07             	shr    $0x7,%al
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  2e:	0f b6 f8             	movzbl %al,%edi
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  31:	0f b6 45 0e          	movzbl 0xe(%ebp),%eax
  35:	c0 e8 05             	shr    $0x5,%al
  38:	83 e0 01             	and    $0x1,%eax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  3b:	0f b6 f0             	movzbl %al,%esi
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  3e:	0f b6 45 0e          	movzbl 0xe(%ebp),%eax
  42:	c0 e8 04             	shr    $0x4,%al
  45:	83 e0 01             	and    $0x1,%eax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  48:	0f b6 d8             	movzbl %al,%ebx
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  4e:	25 ff ff 0f 00       	and    $0xfffff,%eax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  53:	89 45 e0             	mov    %eax,-0x20(%ebp)
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  56:	8b 45 08             	mov    0x8(%ebp),%eax
  59:	c1 e8 0a             	shr    $0xa,%eax
  5c:	66 25 ff 03          	and    $0x3ff,%ax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  60:	0f b7 d0             	movzwl %ax,%edx
        entry.pdx, entry.ptx, entry.ppage, entry.present, entry.writable, entry.encrypted, entry.user, entry.ref);
  63:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  67:	66 25 ff 03          	and    $0x3ff,%ax
      printf(1, "PDX: %d, PTX: %d, PPN: %x, Present: %d, Writable: %d, Encrypted: %d, User: %d, Ref: %d\n", 
  6b:	0f b7 c0             	movzwl %ax,%eax
  6e:	83 ec 08             	sub    $0x8,%esp
  71:	51                   	push   %ecx
  72:	ff 75 e4             	pushl  -0x1c(%ebp)
  75:	57                   	push   %edi
  76:	56                   	push   %esi
  77:	53                   	push   %ebx
  78:	ff 75 e0             	pushl  -0x20(%ebp)
  7b:	52                   	push   %edx
  7c:	50                   	push   %eax
  7d:	68 4c 0c 00 00       	push   $0xc4c
  82:	6a 01                	push   $0x1
  84:	e8 fc 07 00 00       	call   885 <printf>
  89:	83 c4 30             	add    $0x30,%esp
}
  8c:	90                   	nop
  8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  90:	5b                   	pop    %ebx
  91:	5e                   	pop    %esi
  92:	5f                   	pop    %edi
  93:	5d                   	pop    %ebp
  94:	c3                   	ret    

00000095 <err>:

static int 
err(char *msg, ...) {
  95:	f3 0f 1e fb          	endbr32 
  99:	55                   	push   %ebp
  9a:	89 e5                	mov    %esp,%ebp
  9c:	83 ec 08             	sub    $0x8,%esp
    printf(1, "XV6_TEST_OUTPUT %s\n", msg);
  9f:	83 ec 04             	sub    $0x4,%esp
  a2:	ff 75 08             	pushl  0x8(%ebp)
  a5:	68 a4 0c 00 00       	push   $0xca4
  aa:	6a 01                	push   $0x1
  ac:	e8 d4 07 00 00       	call   885 <printf>
  b1:	83 c4 10             	add    $0x10,%esp
    exit();
  b4:	e8 38 06 00 00       	call   6f1 <exit>

000000b9 <main>:
}

int
main(int argc, char **argv)
{
  b9:	f3 0f 1e fb          	endbr32 
  bd:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  c1:	83 e4 f0             	and    $0xfffffff0,%esp
  c4:	ff 71 fc             	pushl  -0x4(%ecx)
  c7:	55                   	push   %ebp
  c8:	89 e5                	mov    %esp,%ebp
  ca:	57                   	push   %edi
  cb:	56                   	push   %esi
  cc:	53                   	push   %ebx
  cd:	51                   	push   %ecx
  ce:	83 ec 48             	sub    $0x48,%esp
    const uint PAGES_NUM = 1;
  d1:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
  d8:	83 ec 0c             	sub    $0xc,%esp
  db:	68 00 10 00 00       	push   $0x1000
  e0:	e8 94 06 00 00       	call   779 <sbrk>
  e5:	83 c4 10             	add    $0x10,%esp
  e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (buffer != (char*)0x6000) {
  eb:	eb 13                	jmp    100 <main+0x47>
        buffer = sbrk(PGSIZE * sizeof(char));
  ed:	83 ec 0c             	sub    $0xc,%esp
  f0:	68 00 10 00 00       	push   $0x1000
  f5:	e8 7f 06 00 00       	call   779 <sbrk>
  fa:	83 c4 10             	add    $0x10,%esp
  fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (buffer != (char*)0x6000) {
 100:	81 7d d4 00 60 00 00 	cmpl   $0x6000,-0x2c(%ebp)
 107:	75 e4                	jne    ed <main+0x34>
    }
    // Allocate one pages of space
    char *ptr = sbrk(PAGES_NUM * PGSIZE);
 109:	8b 45 c8             	mov    -0x38(%ebp),%eax
 10c:	c1 e0 0c             	shl    $0xc,%eax
 10f:	83 ec 0c             	sub    $0xc,%esp
 112:	50                   	push   %eax
 113:	e8 61 06 00 00       	call   779 <sbrk>
 118:	83 c4 10             	add    $0x10,%esp
 11b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    
    struct pt_entry pt_entries[PAGES_NUM];
 11e:	8b 45 c8             	mov    -0x38(%ebp),%eax
 121:	83 e8 01             	sub    $0x1,%eax
 124:	89 45 c0             	mov    %eax,-0x40(%ebp)
 127:	8b 45 c8             	mov    -0x38(%ebp),%eax
 12a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 131:	b8 10 00 00 00       	mov    $0x10,%eax
 136:	83 e8 01             	sub    $0x1,%eax
 139:	01 d0                	add    %edx,%eax
 13b:	bb 10 00 00 00       	mov    $0x10,%ebx
 140:	ba 00 00 00 00       	mov    $0x0,%edx
 145:	f7 f3                	div    %ebx
 147:	6b c0 10             	imul   $0x10,%eax,%eax
 14a:	89 c2                	mov    %eax,%edx
 14c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
 152:	89 e1                	mov    %esp,%ecx
 154:	29 d1                	sub    %edx,%ecx
 156:	89 ca                	mov    %ecx,%edx
 158:	39 d4                	cmp    %edx,%esp
 15a:	74 10                	je     16c <main+0xb3>
 15c:	81 ec 00 10 00 00    	sub    $0x1000,%esp
 162:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
 169:	00 
 16a:	eb ec                	jmp    158 <main+0x9f>
 16c:	89 c2                	mov    %eax,%edx
 16e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 174:	29 d4                	sub    %edx,%esp
 176:	89 c2                	mov    %eax,%edx
 178:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 17e:	85 d2                	test   %edx,%edx
 180:	74 0d                	je     18f <main+0xd6>
 182:	25 ff 0f 00 00       	and    $0xfff,%eax
 187:	83 e8 04             	sub    $0x4,%eax
 18a:	01 e0                	add    %esp,%eax
 18c:	83 08 00             	orl    $0x0,(%eax)
 18f:	89 e0                	mov    %esp,%eax
 191:	83 c0 03             	add    $0x3,%eax
 194:	c1 e8 02             	shr    $0x2,%eax
 197:	c1 e0 02             	shl    $0x2,%eax
 19a:	89 45 bc             	mov    %eax,-0x44(%ebp)

    // Initialize the pages
    for (int i = 0; i < PAGES_NUM * PGSIZE; i++)
 19d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 1a4:	eb 0f                	jmp    1b5 <main+0xfc>
        ptr[i] = 0xAA;
 1a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
 1a9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 1ac:	01 d0                	add    %edx,%eax
 1ae:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int i = 0; i < PAGES_NUM * PGSIZE; i++)
 1b1:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 1b5:	8b 45 c8             	mov    -0x38(%ebp),%eax
 1b8:	c1 e0 0c             	shl    $0xc,%eax
 1bb:	89 c2                	mov    %eax,%edx
 1bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1c0:	39 c2                	cmp    %eax,%edx
 1c2:	77 e2                	ja     1a6 <main+0xed>

    // Call the mencrypt with len = 0
    if (mencrypt((char *)KERNBASE, 0) != 0)
 1c4:	83 ec 08             	sub    $0x8,%esp
 1c7:	6a 00                	push   $0x0
 1c9:	68 00 00 00 80       	push   $0x80000000
 1ce:	e8 be 05 00 00       	call   791 <mencrypt>
 1d3:	83 c4 10             	add    $0x10,%esp
 1d6:	85 c0                	test   %eax,%eax
 1d8:	74 10                	je     1ea <main+0x131>
        err("mencrypt return non-zero value when len equals 0\n");
 1da:	83 ec 0c             	sub    $0xc,%esp
 1dd:	68 b8 0c 00 00       	push   $0xcb8
 1e2:	e8 ae fe ff ff       	call   95 <err>
 1e7:	83 c4 10             	add    $0x10,%esp
    
    // Call the mencrypt on the kernel pages
    if (mencrypt((char *)ptr, -1) != -1)
 1ea:	83 ec 08             	sub    $0x8,%esp
 1ed:	6a ff                	push   $0xffffffff
 1ef:	ff 75 c4             	pushl  -0x3c(%ebp)
 1f2:	e8 9a 05 00 00       	call   791 <mencrypt>
 1f7:	83 c4 10             	add    $0x10,%esp
 1fa:	83 f8 ff             	cmp    $0xffffffff,%eax
 1fd:	74 10                	je     20f <main+0x156>
        err("mencrypt doesn't return -1 value when negative length is given\n");
 1ff:	83 ec 0c             	sub    $0xc,%esp
 202:	68 ec 0c 00 00       	push   $0xcec
 207:	e8 89 fe ff ff       	call   95 <err>
 20c:	83 c4 10             	add    $0x10,%esp

    // Call the mencrypt on the kernel pages
    if (mencrypt((char *)KERNBASE, 1) != -1)
 20f:	83 ec 08             	sub    $0x8,%esp
 212:	6a 01                	push   $0x1
 214:	68 00 00 00 80       	push   $0x80000000
 219:	e8 73 05 00 00       	call   791 <mencrypt>
 21e:	83 c4 10             	add    $0x10,%esp
 221:	83 f8 ff             	cmp    $0xffffffff,%eax
 224:	74 10                	je     236 <main+0x17d>
        err("mencrypt doesn't return -1 value when trying to encrypt kernel page\n");
 226:	83 ec 0c             	sub    $0xc,%esp
 229:	68 2c 0d 00 00       	push   $0xd2c
 22e:	e8 62 fe ff ff       	call   95 <err>
 233:	83 c4 10             	add    $0x10,%esp

    // Call the mencrypt on the kernel pages
    if (mencrypt((char *)((uint)-1), 1) != -1)
 236:	83 ec 08             	sub    $0x8,%esp
 239:	6a 01                	push   $0x1
 23b:	6a ff                	push   $0xffffffff
 23d:	e8 4f 05 00 00       	call   791 <mencrypt>
 242:	83 c4 10             	add    $0x10,%esp
 245:	83 f8 ff             	cmp    $0xffffffff,%eax
 248:	74 10                	je     25a <main+0x1a1>
        err("mencrypt doesn't return -1 value when 0xFFFFFFFF is given as virtual page\n");
 24a:	83 ec 0c             	sub    $0xc,%esp
 24d:	68 74 0d 00 00       	push   $0xd74
 252:	e8 3e fe ff ff       	call   95 <err>
 257:	83 c4 10             	add    $0x10,%esp
    

    if (getpgtable(pt_entries, PAGES_NUM, 0) >= 0){
 25a:	8b 45 c8             	mov    -0x38(%ebp),%eax
 25d:	83 ec 04             	sub    $0x4,%esp
 260:	6a 00                	push   $0x0
 262:	50                   	push   %eax
 263:	ff 75 bc             	pushl  -0x44(%ebp)
 266:	e8 2e 05 00 00       	call   799 <getpgtable>
 26b:	83 c4 10             	add    $0x10,%esp
 26e:	85 c0                	test   %eax,%eax
 270:	0f 88 fb 01 00 00    	js     471 <main+0x3b8>
        for (int i = 0; i < PAGES_NUM; i++) {
 276:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 27d:	e9 e3 01 00 00       	jmp    465 <main+0x3ac>
                pt_entries[i].pdx,
                pt_entries[i].ptx,
                pt_entries[i].ppage,
                pt_entries[i].present,
                pt_entries[i].writable,
                pt_entries[i].encrypted
 282:	8b 45 bc             	mov    -0x44(%ebp),%eax
 285:	8b 55 dc             	mov    -0x24(%ebp),%edx
 288:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 28d:	c0 e8 07             	shr    $0x7,%al
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 290:	0f b6 f0             	movzbl %al,%esi
                pt_entries[i].writable,
 293:	8b 45 bc             	mov    -0x44(%ebp),%eax
 296:	8b 55 dc             	mov    -0x24(%ebp),%edx
 299:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 29e:	c0 e8 05             	shr    $0x5,%al
 2a1:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 2a4:	0f b6 d8             	movzbl %al,%ebx
                pt_entries[i].present,
 2a7:	8b 45 bc             	mov    -0x44(%ebp),%eax
 2aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
 2ad:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 2b2:	c0 e8 04             	shr    $0x4,%al
 2b5:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 2b8:	0f b6 c8             	movzbl %al,%ecx
                pt_entries[i].ppage,
 2bb:	8b 45 bc             	mov    -0x44(%ebp),%eax
 2be:	8b 55 dc             	mov    -0x24(%ebp),%edx
 2c1:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 2c5:	25 ff ff 0f 00       	and    $0xfffff,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 2ca:	89 45 b4             	mov    %eax,-0x4c(%ebp)
                pt_entries[i].ptx,
 2cd:	8b 45 bc             	mov    -0x44(%ebp),%eax
 2d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
 2d3:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 2d6:	c1 e8 0a             	shr    $0xa,%eax
 2d9:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 2dd:	0f b7 d0             	movzwl %ax,%edx
                pt_entries[i].pdx,
 2e0:	8b 45 bc             	mov    -0x44(%ebp),%eax
 2e3:	8b 7d dc             	mov    -0x24(%ebp),%edi
 2e6:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 2ea:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, ppage: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 2ee:	0f b7 c0             	movzwl %ax,%eax
 2f1:	83 ec 0c             	sub    $0xc,%esp
 2f4:	56                   	push   %esi
 2f5:	53                   	push   %ebx
 2f6:	51                   	push   %ecx
 2f7:	ff 75 b4             	pushl  -0x4c(%ebp)
 2fa:	52                   	push   %edx
 2fb:	50                   	push   %eax
 2fc:	ff 75 dc             	pushl  -0x24(%ebp)
 2ff:	68 c0 0d 00 00       	push   $0xdc0
 304:	6a 01                	push   $0x1
 306:	e8 7a 05 00 00       	call   885 <printf>
 30b:	83 c4 30             	add    $0x30,%esp
            );

            if (dump_rawphymem((pt_entries[i].ppage * PGSIZE), buffer) != 0)
 30e:	8b 45 bc             	mov    -0x44(%ebp),%eax
 311:	8b 55 dc             	mov    -0x24(%ebp),%edx
 314:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 318:	25 ff ff 0f 00       	and    $0xfffff,%eax
 31d:	c1 e0 0c             	shl    $0xc,%eax
 320:	83 ec 08             	sub    $0x8,%esp
 323:	ff 75 d4             	pushl  -0x2c(%ebp)
 326:	50                   	push   %eax
 327:	e8 75 04 00 00       	call   7a1 <dump_rawphymem>
 32c:	83 c4 10             	add    $0x10,%esp
 32f:	85 c0                	test   %eax,%eax
 331:	74 10                	je     343 <main+0x28a>
                err("dump_rawphymem return non-zero value\n");
 333:	83 ec 0c             	sub    $0xc,%esp
 336:	68 28 0e 00 00       	push   $0xe28
 33b:	e8 55 fd ff ff       	call   95 <err>
 340:	83 c4 10             	add    $0x10,%esp
            
            uint expected = 0xAA;
 343:	c7 45 b8 aa 00 00 00 	movl   $0xaa,-0x48(%ebp)
            uint is_failed = 0;
 34a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            for (int j = 0; j < PGSIZE; j ++) {
 351:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 358:	eb 1f                	jmp    379 <main+0x2c0>
                if (buffer[j] != (char)expected) {
 35a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 35d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 360:	01 d0                	add    %edx,%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	8b 55 b8             	mov    -0x48(%ebp),%edx
 368:	38 d0                	cmp    %dl,%al
 36a:	74 09                	je     375 <main+0x2bc>
                    is_failed = 1;
 36c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
                    break;
 373:	eb 0d                	jmp    382 <main+0x2c9>
            for (int j = 0; j < PGSIZE; j ++) {
 375:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 379:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 380:	7e d8                	jle    35a <main+0x2a1>
                }
            }
            if (is_failed) {
 382:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 386:	0f 84 d5 00 00 00    	je     461 <main+0x3a8>
                printf(1, "XV6_TEST_OUTPUT wrong content at physical page 0x%x\n", pt_entries[i].ppage * PGSIZE);
 38c:	8b 45 bc             	mov    -0x44(%ebp),%eax
 38f:	8b 55 dc             	mov    -0x24(%ebp),%edx
 392:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 396:	25 ff ff 0f 00       	and    $0xfffff,%eax
 39b:	c1 e0 0c             	shl    $0xc,%eax
 39e:	83 ec 04             	sub    $0x4,%esp
 3a1:	50                   	push   %eax
 3a2:	68 50 0e 00 00       	push   $0xe50
 3a7:	6a 01                	push   $0x1
 3a9:	e8 d7 04 00 00       	call   885 <printf>
 3ae:	83 c4 10             	add    $0x10,%esp
                for (int j = 0; j < PGSIZE; j +=64) {
 3b1:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 3b8:	e9 87 00 00 00       	jmp    444 <main+0x38b>
                    printf(1, "XV6_TEST_OUTPUT ");
 3bd:	83 ec 08             	sub    $0x8,%esp
 3c0:	68 85 0e 00 00       	push   $0xe85
 3c5:	6a 01                	push   $0x1
 3c7:	e8 b9 04 00 00       	call   885 <printf>
 3cc:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 3cf:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 3d6:	eb 62                	jmp    43a <main+0x381>
                        if (k < 63) {
 3d8:	83 7d cc 3e          	cmpl   $0x3e,-0x34(%ebp)
 3dc:	7f 2d                	jg     40b <main+0x352>
                            printf(1, "0x%x ", (uint)buffer[j + k] & 0xFF);
 3de:	8b 55 d0             	mov    -0x30(%ebp),%edx
 3e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
 3e4:	01 d0                	add    %edx,%eax
 3e6:	89 c2                	mov    %eax,%edx
 3e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3eb:	01 d0                	add    %edx,%eax
 3ed:	0f b6 00             	movzbl (%eax),%eax
 3f0:	0f be c0             	movsbl %al,%eax
 3f3:	0f b6 c0             	movzbl %al,%eax
 3f6:	83 ec 04             	sub    $0x4,%esp
 3f9:	50                   	push   %eax
 3fa:	68 96 0e 00 00       	push   $0xe96
 3ff:	6a 01                	push   $0x1
 401:	e8 7f 04 00 00       	call   885 <printf>
 406:	83 c4 10             	add    $0x10,%esp
 409:	eb 2b                	jmp    436 <main+0x37d>
                        } else {
                            printf(1, "0x%x\n", (uint)buffer[j + k] & 0xFF);
 40b:	8b 55 d0             	mov    -0x30(%ebp),%edx
 40e:	8b 45 cc             	mov    -0x34(%ebp),%eax
 411:	01 d0                	add    %edx,%eax
 413:	89 c2                	mov    %eax,%edx
 415:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 418:	01 d0                	add    %edx,%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f be c0             	movsbl %al,%eax
 420:	0f b6 c0             	movzbl %al,%eax
 423:	83 ec 04             	sub    $0x4,%esp
 426:	50                   	push   %eax
 427:	68 9c 0e 00 00       	push   $0xe9c
 42c:	6a 01                	push   $0x1
 42e:	e8 52 04 00 00       	call   885 <printf>
 433:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 436:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 43a:	83 7d cc 3f          	cmpl   $0x3f,-0x34(%ebp)
 43e:	7e 98                	jle    3d8 <main+0x31f>
                for (int j = 0; j < PGSIZE; j +=64) {
 440:	83 45 d0 40          	addl   $0x40,-0x30(%ebp)
 444:	81 7d d0 ff 0f 00 00 	cmpl   $0xfff,-0x30(%ebp)
 44b:	0f 8e 6c ff ff ff    	jle    3bd <main+0x304>
                        }
                    }
                }
                err("None of the pages should be encrypted when len equals to 0\n");
 451:	83 ec 0c             	sub    $0xc,%esp
 454:	68 a4 0e 00 00       	push   $0xea4
 459:	e8 37 fc ff ff       	call   95 <err>
 45e:	83 c4 10             	add    $0x10,%esp
        for (int i = 0; i < PAGES_NUM; i++) {
 461:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 465:	8b 45 dc             	mov    -0x24(%ebp),%eax
 468:	39 45 c8             	cmp    %eax,-0x38(%ebp)
 46b:	0f 87 11 fe ff ff    	ja     282 <main+0x1c9>
            }

        }
    }
    exit();
 471:	e8 7b 02 00 00       	call   6f1 <exit>

00000476 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 476:	55                   	push   %ebp
 477:	89 e5                	mov    %esp,%ebp
 479:	57                   	push   %edi
 47a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 47b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 47e:	8b 55 10             	mov    0x10(%ebp),%edx
 481:	8b 45 0c             	mov    0xc(%ebp),%eax
 484:	89 cb                	mov    %ecx,%ebx
 486:	89 df                	mov    %ebx,%edi
 488:	89 d1                	mov    %edx,%ecx
 48a:	fc                   	cld    
 48b:	f3 aa                	rep stos %al,%es:(%edi)
 48d:	89 ca                	mov    %ecx,%edx
 48f:	89 fb                	mov    %edi,%ebx
 491:	89 5d 08             	mov    %ebx,0x8(%ebp)
 494:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 497:	90                   	nop
 498:	5b                   	pop    %ebx
 499:	5f                   	pop    %edi
 49a:	5d                   	pop    %ebp
 49b:	c3                   	ret    

0000049c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 49c:	f3 0f 1e fb          	endbr32 
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
 4a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4ac:	90                   	nop
 4ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b0:	8d 42 01             	lea    0x1(%edx),%eax
 4b3:	89 45 0c             	mov    %eax,0xc(%ebp)
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	8d 48 01             	lea    0x1(%eax),%ecx
 4bc:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4bf:	0f b6 12             	movzbl (%edx),%edx
 4c2:	88 10                	mov    %dl,(%eax)
 4c4:	0f b6 00             	movzbl (%eax),%eax
 4c7:	84 c0                	test   %al,%al
 4c9:	75 e2                	jne    4ad <strcpy+0x11>
    ;
  return os;
 4cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ce:	c9                   	leave  
 4cf:	c3                   	ret    

000004d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4d0:	f3 0f 1e fb          	endbr32 
 4d4:	55                   	push   %ebp
 4d5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4d7:	eb 08                	jmp    4e1 <strcmp+0x11>
    p++, q++;
 4d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	84 c0                	test   %al,%al
 4e9:	74 10                	je     4fb <strcmp+0x2b>
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	0f b6 10             	movzbl (%eax),%edx
 4f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f4:	0f b6 00             	movzbl (%eax),%eax
 4f7:	38 c2                	cmp    %al,%dl
 4f9:	74 de                	je     4d9 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	0f b6 00             	movzbl (%eax),%eax
 501:	0f b6 d0             	movzbl %al,%edx
 504:	8b 45 0c             	mov    0xc(%ebp),%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	0f b6 c0             	movzbl %al,%eax
 50d:	29 c2                	sub    %eax,%edx
 50f:	89 d0                	mov    %edx,%eax
}
 511:	5d                   	pop    %ebp
 512:	c3                   	ret    

00000513 <strlen>:

uint
strlen(const char *s)
{
 513:	f3 0f 1e fb          	endbr32 
 517:	55                   	push   %ebp
 518:	89 e5                	mov    %esp,%ebp
 51a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 51d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 524:	eb 04                	jmp    52a <strlen+0x17>
 526:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 52a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 52d:	8b 45 08             	mov    0x8(%ebp),%eax
 530:	01 d0                	add    %edx,%eax
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	84 c0                	test   %al,%al
 537:	75 ed                	jne    526 <strlen+0x13>
    ;
  return n;
 539:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53c:	c9                   	leave  
 53d:	c3                   	ret    

0000053e <memset>:

void*
memset(void *dst, int c, uint n)
{
 53e:	f3 0f 1e fb          	endbr32 
 542:	55                   	push   %ebp
 543:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 545:	8b 45 10             	mov    0x10(%ebp),%eax
 548:	50                   	push   %eax
 549:	ff 75 0c             	pushl  0xc(%ebp)
 54c:	ff 75 08             	pushl  0x8(%ebp)
 54f:	e8 22 ff ff ff       	call   476 <stosb>
 554:	83 c4 0c             	add    $0xc,%esp
  return dst;
 557:	8b 45 08             	mov    0x8(%ebp),%eax
}
 55a:	c9                   	leave  
 55b:	c3                   	ret    

0000055c <strchr>:

char*
strchr(const char *s, char c)
{
 55c:	f3 0f 1e fb          	endbr32 
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	83 ec 04             	sub    $0x4,%esp
 566:	8b 45 0c             	mov    0xc(%ebp),%eax
 569:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 56c:	eb 14                	jmp    582 <strchr+0x26>
    if(*s == c)
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
 571:	0f b6 00             	movzbl (%eax),%eax
 574:	38 45 fc             	cmp    %al,-0x4(%ebp)
 577:	75 05                	jne    57e <strchr+0x22>
      return (char*)s;
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	eb 13                	jmp    591 <strchr+0x35>
  for(; *s; s++)
 57e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	84 c0                	test   %al,%al
 58a:	75 e2                	jne    56e <strchr+0x12>
  return 0;
 58c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 591:	c9                   	leave  
 592:	c3                   	ret    

00000593 <gets>:

char*
gets(char *buf, int max)
{
 593:	f3 0f 1e fb          	endbr32 
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 59d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5a4:	eb 42                	jmp    5e8 <gets+0x55>
    cc = read(0, &c, 1);
 5a6:	83 ec 04             	sub    $0x4,%esp
 5a9:	6a 01                	push   $0x1
 5ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5ae:	50                   	push   %eax
 5af:	6a 00                	push   $0x0
 5b1:	e8 53 01 00 00       	call   709 <read>
 5b6:	83 c4 10             	add    $0x10,%esp
 5b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c0:	7e 33                	jle    5f5 <gets+0x62>
      break;
    buf[i++] = c;
 5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c5:	8d 50 01             	lea    0x1(%eax),%edx
 5c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5cb:	89 c2                	mov    %eax,%edx
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
 5d0:	01 c2                	add    %eax,%edx
 5d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5d6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5d8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5dc:	3c 0a                	cmp    $0xa,%al
 5de:	74 16                	je     5f6 <gets+0x63>
 5e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5e4:	3c 0d                	cmp    $0xd,%al
 5e6:	74 0e                	je     5f6 <gets+0x63>
  for(i=0; i+1 < max; ){
 5e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5eb:	83 c0 01             	add    $0x1,%eax
 5ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
 5f1:	7f b3                	jg     5a6 <gets+0x13>
 5f3:	eb 01                	jmp    5f6 <gets+0x63>
      break;
 5f5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 5f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	01 d0                	add    %edx,%eax
 5fe:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 601:	8b 45 08             	mov    0x8(%ebp),%eax
}
 604:	c9                   	leave  
 605:	c3                   	ret    

00000606 <stat>:

int
stat(const char *n, struct stat *st)
{
 606:	f3 0f 1e fb          	endbr32 
 60a:	55                   	push   %ebp
 60b:	89 e5                	mov    %esp,%ebp
 60d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 610:	83 ec 08             	sub    $0x8,%esp
 613:	6a 00                	push   $0x0
 615:	ff 75 08             	pushl  0x8(%ebp)
 618:	e8 14 01 00 00       	call   731 <open>
 61d:	83 c4 10             	add    $0x10,%esp
 620:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 623:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 627:	79 07                	jns    630 <stat+0x2a>
    return -1;
 629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 62e:	eb 25                	jmp    655 <stat+0x4f>
  r = fstat(fd, st);
 630:	83 ec 08             	sub    $0x8,%esp
 633:	ff 75 0c             	pushl  0xc(%ebp)
 636:	ff 75 f4             	pushl  -0xc(%ebp)
 639:	e8 0b 01 00 00       	call   749 <fstat>
 63e:	83 c4 10             	add    $0x10,%esp
 641:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 644:	83 ec 0c             	sub    $0xc,%esp
 647:	ff 75 f4             	pushl  -0xc(%ebp)
 64a:	e8 ca 00 00 00       	call   719 <close>
 64f:	83 c4 10             	add    $0x10,%esp
  return r;
 652:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 655:	c9                   	leave  
 656:	c3                   	ret    

00000657 <atoi>:

int
atoi(const char *s)
{
 657:	f3 0f 1e fb          	endbr32 
 65b:	55                   	push   %ebp
 65c:	89 e5                	mov    %esp,%ebp
 65e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 661:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 668:	eb 25                	jmp    68f <atoi+0x38>
    n = n*10 + *s++ - '0';
 66a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 66d:	89 d0                	mov    %edx,%eax
 66f:	c1 e0 02             	shl    $0x2,%eax
 672:	01 d0                	add    %edx,%eax
 674:	01 c0                	add    %eax,%eax
 676:	89 c1                	mov    %eax,%ecx
 678:	8b 45 08             	mov    0x8(%ebp),%eax
 67b:	8d 50 01             	lea    0x1(%eax),%edx
 67e:	89 55 08             	mov    %edx,0x8(%ebp)
 681:	0f b6 00             	movzbl (%eax),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	01 c8                	add    %ecx,%eax
 689:	83 e8 30             	sub    $0x30,%eax
 68c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	0f b6 00             	movzbl (%eax),%eax
 695:	3c 2f                	cmp    $0x2f,%al
 697:	7e 0a                	jle    6a3 <atoi+0x4c>
 699:	8b 45 08             	mov    0x8(%ebp),%eax
 69c:	0f b6 00             	movzbl (%eax),%eax
 69f:	3c 39                	cmp    $0x39,%al
 6a1:	7e c7                	jle    66a <atoi+0x13>
  return n;
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6a6:	c9                   	leave  
 6a7:	c3                   	ret    

000006a8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6a8:	f3 0f 1e fb          	endbr32 
 6ac:	55                   	push   %ebp
 6ad:	89 e5                	mov    %esp,%ebp
 6af:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 6b2:	8b 45 08             	mov    0x8(%ebp),%eax
 6b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6be:	eb 17                	jmp    6d7 <memmove+0x2f>
    *dst++ = *src++;
 6c0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c3:	8d 42 01             	lea    0x1(%edx),%eax
 6c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8d 48 01             	lea    0x1(%eax),%ecx
 6cf:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6d2:	0f b6 12             	movzbl (%edx),%edx
 6d5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6d7:	8b 45 10             	mov    0x10(%ebp),%eax
 6da:	8d 50 ff             	lea    -0x1(%eax),%edx
 6dd:	89 55 10             	mov    %edx,0x10(%ebp)
 6e0:	85 c0                	test   %eax,%eax
 6e2:	7f dc                	jg     6c0 <memmove+0x18>
  return vdst;
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6e7:	c9                   	leave  
 6e8:	c3                   	ret    

000006e9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6e9:	b8 01 00 00 00       	mov    $0x1,%eax
 6ee:	cd 40                	int    $0x40
 6f0:	c3                   	ret    

000006f1 <exit>:
SYSCALL(exit)
 6f1:	b8 02 00 00 00       	mov    $0x2,%eax
 6f6:	cd 40                	int    $0x40
 6f8:	c3                   	ret    

000006f9 <wait>:
SYSCALL(wait)
 6f9:	b8 03 00 00 00       	mov    $0x3,%eax
 6fe:	cd 40                	int    $0x40
 700:	c3                   	ret    

00000701 <pipe>:
SYSCALL(pipe)
 701:	b8 04 00 00 00       	mov    $0x4,%eax
 706:	cd 40                	int    $0x40
 708:	c3                   	ret    

00000709 <read>:
SYSCALL(read)
 709:	b8 05 00 00 00       	mov    $0x5,%eax
 70e:	cd 40                	int    $0x40
 710:	c3                   	ret    

00000711 <write>:
SYSCALL(write)
 711:	b8 10 00 00 00       	mov    $0x10,%eax
 716:	cd 40                	int    $0x40
 718:	c3                   	ret    

00000719 <close>:
SYSCALL(close)
 719:	b8 15 00 00 00       	mov    $0x15,%eax
 71e:	cd 40                	int    $0x40
 720:	c3                   	ret    

00000721 <kill>:
SYSCALL(kill)
 721:	b8 06 00 00 00       	mov    $0x6,%eax
 726:	cd 40                	int    $0x40
 728:	c3                   	ret    

00000729 <exec>:
SYSCALL(exec)
 729:	b8 07 00 00 00       	mov    $0x7,%eax
 72e:	cd 40                	int    $0x40
 730:	c3                   	ret    

00000731 <open>:
SYSCALL(open)
 731:	b8 0f 00 00 00       	mov    $0xf,%eax
 736:	cd 40                	int    $0x40
 738:	c3                   	ret    

00000739 <mknod>:
SYSCALL(mknod)
 739:	b8 11 00 00 00       	mov    $0x11,%eax
 73e:	cd 40                	int    $0x40
 740:	c3                   	ret    

00000741 <unlink>:
SYSCALL(unlink)
 741:	b8 12 00 00 00       	mov    $0x12,%eax
 746:	cd 40                	int    $0x40
 748:	c3                   	ret    

00000749 <fstat>:
SYSCALL(fstat)
 749:	b8 08 00 00 00       	mov    $0x8,%eax
 74e:	cd 40                	int    $0x40
 750:	c3                   	ret    

00000751 <link>:
SYSCALL(link)
 751:	b8 13 00 00 00       	mov    $0x13,%eax
 756:	cd 40                	int    $0x40
 758:	c3                   	ret    

00000759 <mkdir>:
SYSCALL(mkdir)
 759:	b8 14 00 00 00       	mov    $0x14,%eax
 75e:	cd 40                	int    $0x40
 760:	c3                   	ret    

00000761 <chdir>:
SYSCALL(chdir)
 761:	b8 09 00 00 00       	mov    $0x9,%eax
 766:	cd 40                	int    $0x40
 768:	c3                   	ret    

00000769 <dup>:
SYSCALL(dup)
 769:	b8 0a 00 00 00       	mov    $0xa,%eax
 76e:	cd 40                	int    $0x40
 770:	c3                   	ret    

00000771 <getpid>:
SYSCALL(getpid)
 771:	b8 0b 00 00 00       	mov    $0xb,%eax
 776:	cd 40                	int    $0x40
 778:	c3                   	ret    

00000779 <sbrk>:
SYSCALL(sbrk)
 779:	b8 0c 00 00 00       	mov    $0xc,%eax
 77e:	cd 40                	int    $0x40
 780:	c3                   	ret    

00000781 <sleep>:
SYSCALL(sleep)
 781:	b8 0d 00 00 00       	mov    $0xd,%eax
 786:	cd 40                	int    $0x40
 788:	c3                   	ret    

00000789 <uptime>:
SYSCALL(uptime)
 789:	b8 0e 00 00 00       	mov    $0xe,%eax
 78e:	cd 40                	int    $0x40
 790:	c3                   	ret    

00000791 <mencrypt>:
SYSCALL(mencrypt)
 791:	b8 16 00 00 00       	mov    $0x16,%eax
 796:	cd 40                	int    $0x40
 798:	c3                   	ret    

00000799 <getpgtable>:
SYSCALL(getpgtable)
 799:	b8 17 00 00 00       	mov    $0x17,%eax
 79e:	cd 40                	int    $0x40
 7a0:	c3                   	ret    

000007a1 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 7a1:	b8 18 00 00 00       	mov    $0x18,%eax
 7a6:	cd 40                	int    $0x40
 7a8:	c3                   	ret    

000007a9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7a9:	f3 0f 1e fb          	endbr32 
 7ad:	55                   	push   %ebp
 7ae:	89 e5                	mov    %esp,%ebp
 7b0:	83 ec 18             	sub    $0x18,%esp
 7b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7b9:	83 ec 04             	sub    $0x4,%esp
 7bc:	6a 01                	push   $0x1
 7be:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7c1:	50                   	push   %eax
 7c2:	ff 75 08             	pushl  0x8(%ebp)
 7c5:	e8 47 ff ff ff       	call   711 <write>
 7ca:	83 c4 10             	add    $0x10,%esp
}
 7cd:	90                   	nop
 7ce:	c9                   	leave  
 7cf:	c3                   	ret    

000007d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7d0:	f3 0f 1e fb          	endbr32 
 7d4:	55                   	push   %ebp
 7d5:	89 e5                	mov    %esp,%ebp
 7d7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7e1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7e5:	74 17                	je     7fe <printint+0x2e>
 7e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7eb:	79 11                	jns    7fe <printint+0x2e>
    neg = 1;
 7ed:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 7f7:	f7 d8                	neg    %eax
 7f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7fc:	eb 06                	jmp    804 <printint+0x34>
  } else {
    x = xx;
 7fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 804:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 80b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 80e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 811:	ba 00 00 00 00       	mov    $0x0,%edx
 816:	f7 f1                	div    %ecx
 818:	89 d1                	mov    %edx,%ecx
 81a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81d:	8d 50 01             	lea    0x1(%eax),%edx
 820:	89 55 f4             	mov    %edx,-0xc(%ebp)
 823:	0f b6 91 80 11 00 00 	movzbl 0x1180(%ecx),%edx
 82a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 82e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 831:	8b 45 ec             	mov    -0x14(%ebp),%eax
 834:	ba 00 00 00 00       	mov    $0x0,%edx
 839:	f7 f1                	div    %ecx
 83b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 83e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 842:	75 c7                	jne    80b <printint+0x3b>
  if(neg)
 844:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 848:	74 2d                	je     877 <printint+0xa7>
    buf[i++] = '-';
 84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84d:	8d 50 01             	lea    0x1(%eax),%edx
 850:	89 55 f4             	mov    %edx,-0xc(%ebp)
 853:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 858:	eb 1d                	jmp    877 <printint+0xa7>
    putc(fd, buf[i]);
 85a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	01 d0                	add    %edx,%eax
 862:	0f b6 00             	movzbl (%eax),%eax
 865:	0f be c0             	movsbl %al,%eax
 868:	83 ec 08             	sub    $0x8,%esp
 86b:	50                   	push   %eax
 86c:	ff 75 08             	pushl  0x8(%ebp)
 86f:	e8 35 ff ff ff       	call   7a9 <putc>
 874:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 877:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 87b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 87f:	79 d9                	jns    85a <printint+0x8a>
}
 881:	90                   	nop
 882:	90                   	nop
 883:	c9                   	leave  
 884:	c3                   	ret    

00000885 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 885:	f3 0f 1e fb          	endbr32 
 889:	55                   	push   %ebp
 88a:	89 e5                	mov    %esp,%ebp
 88c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 88f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 896:	8d 45 0c             	lea    0xc(%ebp),%eax
 899:	83 c0 04             	add    $0x4,%eax
 89c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 89f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8a6:	e9 59 01 00 00       	jmp    a04 <printf+0x17f>
    c = fmt[i] & 0xff;
 8ab:	8b 55 0c             	mov    0xc(%ebp),%edx
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	01 d0                	add    %edx,%eax
 8b3:	0f b6 00             	movzbl (%eax),%eax
 8b6:	0f be c0             	movsbl %al,%eax
 8b9:	25 ff 00 00 00       	and    $0xff,%eax
 8be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8c5:	75 2c                	jne    8f3 <printf+0x6e>
      if(c == '%'){
 8c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8cb:	75 0c                	jne    8d9 <printf+0x54>
        state = '%';
 8cd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8d4:	e9 27 01 00 00       	jmp    a00 <printf+0x17b>
      } else {
        putc(fd, c);
 8d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8dc:	0f be c0             	movsbl %al,%eax
 8df:	83 ec 08             	sub    $0x8,%esp
 8e2:	50                   	push   %eax
 8e3:	ff 75 08             	pushl  0x8(%ebp)
 8e6:	e8 be fe ff ff       	call   7a9 <putc>
 8eb:	83 c4 10             	add    $0x10,%esp
 8ee:	e9 0d 01 00 00       	jmp    a00 <printf+0x17b>
      }
    } else if(state == '%'){
 8f3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8f7:	0f 85 03 01 00 00    	jne    a00 <printf+0x17b>
      if(c == 'd'){
 8fd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 901:	75 1e                	jne    921 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 903:	8b 45 e8             	mov    -0x18(%ebp),%eax
 906:	8b 00                	mov    (%eax),%eax
 908:	6a 01                	push   $0x1
 90a:	6a 0a                	push   $0xa
 90c:	50                   	push   %eax
 90d:	ff 75 08             	pushl  0x8(%ebp)
 910:	e8 bb fe ff ff       	call   7d0 <printint>
 915:	83 c4 10             	add    $0x10,%esp
        ap++;
 918:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 91c:	e9 d8 00 00 00       	jmp    9f9 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 921:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 925:	74 06                	je     92d <printf+0xa8>
 927:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 92b:	75 1e                	jne    94b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 92d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 930:	8b 00                	mov    (%eax),%eax
 932:	6a 00                	push   $0x0
 934:	6a 10                	push   $0x10
 936:	50                   	push   %eax
 937:	ff 75 08             	pushl  0x8(%ebp)
 93a:	e8 91 fe ff ff       	call   7d0 <printint>
 93f:	83 c4 10             	add    $0x10,%esp
        ap++;
 942:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 946:	e9 ae 00 00 00       	jmp    9f9 <printf+0x174>
      } else if(c == 's'){
 94b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 94f:	75 43                	jne    994 <printf+0x10f>
        s = (char*)*ap;
 951:	8b 45 e8             	mov    -0x18(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 959:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 95d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 961:	75 25                	jne    988 <printf+0x103>
          s = "(null)";
 963:	c7 45 f4 e0 0e 00 00 	movl   $0xee0,-0xc(%ebp)
        while(*s != 0){
 96a:	eb 1c                	jmp    988 <printf+0x103>
          putc(fd, *s);
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	0f b6 00             	movzbl (%eax),%eax
 972:	0f be c0             	movsbl %al,%eax
 975:	83 ec 08             	sub    $0x8,%esp
 978:	50                   	push   %eax
 979:	ff 75 08             	pushl  0x8(%ebp)
 97c:	e8 28 fe ff ff       	call   7a9 <putc>
 981:	83 c4 10             	add    $0x10,%esp
          s++;
 984:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 988:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98b:	0f b6 00             	movzbl (%eax),%eax
 98e:	84 c0                	test   %al,%al
 990:	75 da                	jne    96c <printf+0xe7>
 992:	eb 65                	jmp    9f9 <printf+0x174>
        }
      } else if(c == 'c'){
 994:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 998:	75 1d                	jne    9b7 <printf+0x132>
        putc(fd, *ap);
 99a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 99d:	8b 00                	mov    (%eax),%eax
 99f:	0f be c0             	movsbl %al,%eax
 9a2:	83 ec 08             	sub    $0x8,%esp
 9a5:	50                   	push   %eax
 9a6:	ff 75 08             	pushl  0x8(%ebp)
 9a9:	e8 fb fd ff ff       	call   7a9 <putc>
 9ae:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b5:	eb 42                	jmp    9f9 <printf+0x174>
      } else if(c == '%'){
 9b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9bb:	75 17                	jne    9d4 <printf+0x14f>
        putc(fd, c);
 9bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9c0:	0f be c0             	movsbl %al,%eax
 9c3:	83 ec 08             	sub    $0x8,%esp
 9c6:	50                   	push   %eax
 9c7:	ff 75 08             	pushl  0x8(%ebp)
 9ca:	e8 da fd ff ff       	call   7a9 <putc>
 9cf:	83 c4 10             	add    $0x10,%esp
 9d2:	eb 25                	jmp    9f9 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9d4:	83 ec 08             	sub    $0x8,%esp
 9d7:	6a 25                	push   $0x25
 9d9:	ff 75 08             	pushl  0x8(%ebp)
 9dc:	e8 c8 fd ff ff       	call   7a9 <putc>
 9e1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9e7:	0f be c0             	movsbl %al,%eax
 9ea:	83 ec 08             	sub    $0x8,%esp
 9ed:	50                   	push   %eax
 9ee:	ff 75 08             	pushl  0x8(%ebp)
 9f1:	e8 b3 fd ff ff       	call   7a9 <putc>
 9f6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a00:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a04:	8b 55 0c             	mov    0xc(%ebp),%edx
 a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0a:	01 d0                	add    %edx,%eax
 a0c:	0f b6 00             	movzbl (%eax),%eax
 a0f:	84 c0                	test   %al,%al
 a11:	0f 85 94 fe ff ff    	jne    8ab <printf+0x26>
    }
  }
}
 a17:	90                   	nop
 a18:	90                   	nop
 a19:	c9                   	leave  
 a1a:	c3                   	ret    

00000a1b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a1b:	f3 0f 1e fb          	endbr32 
 a1f:	55                   	push   %ebp
 a20:	89 e5                	mov    %esp,%ebp
 a22:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a25:	8b 45 08             	mov    0x8(%ebp),%eax
 a28:	83 e8 08             	sub    $0x8,%eax
 a2b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a2e:	a1 9c 11 00 00       	mov    0x119c,%eax
 a33:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a36:	eb 24                	jmp    a5c <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3b:	8b 00                	mov    (%eax),%eax
 a3d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a40:	72 12                	jb     a54 <free+0x39>
 a42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a45:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a48:	77 24                	ja     a6e <free+0x53>
 a4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4d:	8b 00                	mov    (%eax),%eax
 a4f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a52:	72 1a                	jb     a6e <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a57:	8b 00                	mov    (%eax),%eax
 a59:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a62:	76 d4                	jbe    a38 <free+0x1d>
 a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a6c:	73 ca                	jae    a38 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a71:	8b 40 04             	mov    0x4(%eax),%eax
 a74:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7e:	01 c2                	add    %eax,%edx
 a80:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a83:	8b 00                	mov    (%eax),%eax
 a85:	39 c2                	cmp    %eax,%edx
 a87:	75 24                	jne    aad <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 a89:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8c:	8b 50 04             	mov    0x4(%eax),%edx
 a8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a92:	8b 00                	mov    (%eax),%eax
 a94:	8b 40 04             	mov    0x4(%eax),%eax
 a97:	01 c2                	add    %eax,%edx
 a99:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a9c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa2:	8b 00                	mov    (%eax),%eax
 aa4:	8b 10                	mov    (%eax),%edx
 aa6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa9:	89 10                	mov    %edx,(%eax)
 aab:	eb 0a                	jmp    ab7 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 aad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab0:	8b 10                	mov    (%eax),%edx
 ab2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab5:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ab7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aba:	8b 40 04             	mov    0x4(%eax),%eax
 abd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ac4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac7:	01 d0                	add    %edx,%eax
 ac9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 acc:	75 20                	jne    aee <free+0xd3>
    p->s.size += bp->s.size;
 ace:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad1:	8b 50 04             	mov    0x4(%eax),%edx
 ad4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad7:	8b 40 04             	mov    0x4(%eax),%eax
 ada:	01 c2                	add    %eax,%edx
 adc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 adf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ae2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae5:	8b 10                	mov    (%eax),%edx
 ae7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aea:	89 10                	mov    %edx,(%eax)
 aec:	eb 08                	jmp    af6 <free+0xdb>
  } else
    p->s.ptr = bp;
 aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 af4:	89 10                	mov    %edx,(%eax)
  freep = p;
 af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af9:	a3 9c 11 00 00       	mov    %eax,0x119c
}
 afe:	90                   	nop
 aff:	c9                   	leave  
 b00:	c3                   	ret    

00000b01 <morecore>:

static Header*
morecore(uint nu)
{
 b01:	f3 0f 1e fb          	endbr32 
 b05:	55                   	push   %ebp
 b06:	89 e5                	mov    %esp,%ebp
 b08:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b0b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b12:	77 07                	ja     b1b <morecore+0x1a>
    nu = 4096;
 b14:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b1b:	8b 45 08             	mov    0x8(%ebp),%eax
 b1e:	c1 e0 03             	shl    $0x3,%eax
 b21:	83 ec 0c             	sub    $0xc,%esp
 b24:	50                   	push   %eax
 b25:	e8 4f fc ff ff       	call   779 <sbrk>
 b2a:	83 c4 10             	add    $0x10,%esp
 b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b30:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b34:	75 07                	jne    b3d <morecore+0x3c>
    return 0;
 b36:	b8 00 00 00 00       	mov    $0x0,%eax
 b3b:	eb 26                	jmp    b63 <morecore+0x62>
  hp = (Header*)p;
 b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b46:	8b 55 08             	mov    0x8(%ebp),%edx
 b49:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b4f:	83 c0 08             	add    $0x8,%eax
 b52:	83 ec 0c             	sub    $0xc,%esp
 b55:	50                   	push   %eax
 b56:	e8 c0 fe ff ff       	call   a1b <free>
 b5b:	83 c4 10             	add    $0x10,%esp
  return freep;
 b5e:	a1 9c 11 00 00       	mov    0x119c,%eax
}
 b63:	c9                   	leave  
 b64:	c3                   	ret    

00000b65 <malloc>:

void*
malloc(uint nbytes)
{
 b65:	f3 0f 1e fb          	endbr32 
 b69:	55                   	push   %ebp
 b6a:	89 e5                	mov    %esp,%ebp
 b6c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b6f:	8b 45 08             	mov    0x8(%ebp),%eax
 b72:	83 c0 07             	add    $0x7,%eax
 b75:	c1 e8 03             	shr    $0x3,%eax
 b78:	83 c0 01             	add    $0x1,%eax
 b7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b7e:	a1 9c 11 00 00       	mov    0x119c,%eax
 b83:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b8a:	75 23                	jne    baf <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 b8c:	c7 45 f0 94 11 00 00 	movl   $0x1194,-0x10(%ebp)
 b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b96:	a3 9c 11 00 00       	mov    %eax,0x119c
 b9b:	a1 9c 11 00 00       	mov    0x119c,%eax
 ba0:	a3 94 11 00 00       	mov    %eax,0x1194
    base.s.size = 0;
 ba5:	c7 05 98 11 00 00 00 	movl   $0x0,0x1198
 bac:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb2:	8b 00                	mov    (%eax),%eax
 bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bba:	8b 40 04             	mov    0x4(%eax),%eax
 bbd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bc0:	77 4d                	ja     c0f <malloc+0xaa>
      if(p->s.size == nunits)
 bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc5:	8b 40 04             	mov    0x4(%eax),%eax
 bc8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bcb:	75 0c                	jne    bd9 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd0:	8b 10                	mov    (%eax),%edx
 bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd5:	89 10                	mov    %edx,(%eax)
 bd7:	eb 26                	jmp    bff <malloc+0x9a>
      else {
        p->s.size -= nunits;
 bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bdc:	8b 40 04             	mov    0x4(%eax),%eax
 bdf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 be2:	89 c2                	mov    %eax,%edx
 be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bed:	8b 40 04             	mov    0x4(%eax),%eax
 bf0:	c1 e0 03             	shl    $0x3,%eax
 bf3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bfc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c02:	a3 9c 11 00 00       	mov    %eax,0x119c
      return (void*)(p + 1);
 c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0a:	83 c0 08             	add    $0x8,%eax
 c0d:	eb 3b                	jmp    c4a <malloc+0xe5>
    }
    if(p == freep)
 c0f:	a1 9c 11 00 00       	mov    0x119c,%eax
 c14:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c17:	75 1e                	jne    c37 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c19:	83 ec 0c             	sub    $0xc,%esp
 c1c:	ff 75 ec             	pushl  -0x14(%ebp)
 c1f:	e8 dd fe ff ff       	call   b01 <morecore>
 c24:	83 c4 10             	add    $0x10,%esp
 c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c2e:	75 07                	jne    c37 <malloc+0xd2>
        return 0;
 c30:	b8 00 00 00 00       	mov    $0x0,%eax
 c35:	eb 13                	jmp    c4a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c40:	8b 00                	mov    (%eax),%eax
 c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c45:	e9 6d ff ff ff       	jmp    bb7 <malloc+0x52>
  }
}
 c4a:	c9                   	leave  
 c4b:	c3                   	ret    
