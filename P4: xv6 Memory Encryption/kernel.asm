
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 52 3a 10 80       	mov    $0x80103a52,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 18 93 10 80       	push   $0x80109318
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 4d 52 00 00       	call   8010529d <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 1f 93 10 80       	push   $0x8010931f
80100094:	50                   	push   %eax
80100095:	e8 70 50 00 00       	call   8010510a <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 e7 51 00 00       	call   801052c3 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 1a 52 00 00       	call   80105335 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 1d 50 00 00       	call   8010514a <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 99 51 00 00       	call   80105335 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 9c 4f 00 00       	call   8010514a <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 26 93 10 80       	push   $0x80109326
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 a5 28 00 00       	call   80102ab1 <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 d7 4f 00 00       	call   80105204 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 37 93 10 80       	push   $0x80109337
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 56 28 00 00       	call   80102ab1 <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 8a 4f 00 00       	call   80105204 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 3e 93 10 80       	push   $0x8010933e
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 15 4f 00 00       	call   801051b2 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 16 50 00 00       	call   801052c3 <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 18 50 00 00       	call   80105335 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 cd 4f 00 00       	call   8010540a <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 72 4e 00 00       	call   801052c3 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 48 93 10 80       	push   $0x80109348
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 58 93 10 80 	mov    -0x7fef6ca8(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 51 93 10 80 	movl   $0x80109351,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 33 4d 00 00       	call   80105335 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 7d 2b 00 00       	call   801031a3 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 b0 93 10 80       	push   $0x801093b0
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 c4 93 10 80       	push   $0x801093c4
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 25 4d 00 00       	call   8010538b <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 c6 93 10 80       	push   $0x801093c6
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 ca 93 10 80       	push   $0x801093ca
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 85 4e 00 00       	call   80105629 <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 94 4d 00 00       	call   80105562 <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 02 68 00 00       	call   8010706c <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 f5 67 00 00       	call   8010706c <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 e8 67 00 00       	call   8010706c <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 d8 67 00 00       	call   8010706c <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 fd 49 00 00       	call   801052c3 <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 27 45 00 00       	call   80104f43 <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 f6 48 00 00       	call   80105335 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 bc 45 00 00       	call   80105009 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 d2 11 00 00       	call   80101c37 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 48 48 00 00       	call   801052c3 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 4c 3a 00 00       	call   801044d4 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 99 48 00 00       	call   80105335 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 76 10 00 00       	call   80101b20 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 88 43 00 00       	call   80104e51 <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 ee 47 00 00       	call   80105335 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 cb 0f 00 00       	call   80101b20 <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 be 10 00 00       	call   80101c37 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 3a 47 00 00       	call   801052c3 <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 6a 47 00 00       	call   80105335 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 47 0f 00 00       	call   80101b20 <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 dd 93 10 80       	push   $0x801093dd
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 a0 46 00 00       	call   8010529d <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 60 20 00 00       	call   80102c8a <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 92 38 00 00       	call   801044d4 <myproc>
80100c42:	89 45 cc             	mov    %eax,-0x34(%ebp)

  begin_op();
80100c45:	e8 cb 2a 00 00       	call   80103715 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 36 1a 00 00       	call   8010268b <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 3f 2b 00 00       	call   801037a5 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 e5 93 10 80       	push   $0x801093e5
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 36 04 00 00       	jmp    801010b6 <exec+0x486>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 95 0e 00 00       	call   80101b20 <ilock>
80100c8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c95:	6a 34                	push   $0x34
80100c97:	6a 00                	push   $0x0
80100c99:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c9f:	50                   	push   %eax
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 80 13 00 00       	call   80102028 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 ab 03 00 00    	jne    8010105f <exec+0x42f>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 9d 03 00 00    	jne    80101062 <exec+0x432>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 d9 73 00 00       	call   801080a3 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 8e 03 00 00    	je     80101065 <exec+0x435>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce5:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100ceb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cee:	e9 de 00 00 00       	jmp    80100dd1 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf6:	6a 20                	push   $0x20
80100cf8:	50                   	push   %eax
80100cf9:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	pushl  -0x28(%ebp)
80100d03:	e8 20 13 00 00       	call   80102028 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 54 03 00 00    	jne    80101068 <exec+0x438>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d14:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d1a:	83 f8 01             	cmp    $0x1,%eax
80100d1d:	0f 85 a0 00 00 00    	jne    80100dc3 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100d23:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d29:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d2f:	39 c2                	cmp    %eax,%edx
80100d31:	0f 82 34 03 00 00    	jb     8010106b <exec+0x43b>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d3d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 1b 03 00 00    	jb     8010106e <exec+0x43e>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d59:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 f1 76 00 00       	call   80108461 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 f1 02 00 00    	je     80101071 <exec+0x441>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 e1 02 00 00    	jne    80101074 <exec+0x444>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d93:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d99:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d9f:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100da5:	83 ec 0c             	sub    $0xc,%esp
80100da8:	52                   	push   %edx
80100da9:	50                   	push   %eax
80100daa:	ff 75 d8             	pushl  -0x28(%ebp)
80100dad:	51                   	push   %ecx
80100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db1:	e8 da 75 00 00       	call   80108390 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 b6 02 00 00    	js     80101077 <exec+0x447>
80100dc1:	eb 01                	jmp    80100dc4 <exec+0x194>
      continue;
80100dc3:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dc4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dcb:	83 c0 20             	add    $0x20,%eax
80100dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dd1:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100dd8:	0f b7 c0             	movzwl %ax,%eax
80100ddb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dde:	0f 8c 0f ff ff ff    	jl     80100cf3 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100de4:	83 ec 0c             	sub    $0xc,%esp
80100de7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dea:	e8 6e 0f 00 00       	call   80101d5d <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 ae 29 00 00       	call   801037a5 <end_op>
  ip = 0;
80100df7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e11:	05 00 20 00 00       	add    $0x2000,%eax
80100e16:	83 ec 04             	sub    $0x4,%esp
80100e19:	50                   	push   %eax
80100e1a:	ff 75 e0             	pushl  -0x20(%ebp)
80100e1d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e20:	e8 3c 76 00 00       	call   80108461 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 45 02 00 00    	je     8010107a <exec+0x44a>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 8a 78 00 00       	call   801086d3 <clearpteu>
80100e49:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e59:	e9 96 00 00 00       	jmp    80100ef4 <exec+0x2c4>
    if(argc >= MAXARG)
80100e5e:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e62:	0f 87 15 02 00 00    	ja     8010107d <exec+0x44d>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 49 49 00 00       	call   801057cb <strlen>
80100e82:	83 c4 10             	add    $0x10,%esp
80100e85:	89 c2                	mov    %eax,%edx
80100e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8a:	29 d0                	sub    %edx,%eax
80100e8c:	83 e8 01             	sub    $0x1,%eax
80100e8f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea2:	01 d0                	add    %edx,%eax
80100ea4:	8b 00                	mov    (%eax),%eax
80100ea6:	83 ec 0c             	sub    $0xc,%esp
80100ea9:	50                   	push   %eax
80100eaa:	e8 1c 49 00 00       	call   801057cb <strlen>
80100eaf:	83 c4 10             	add    $0x10,%esp
80100eb2:	83 c0 01             	add    $0x1,%eax
80100eb5:	89 c1                	mov    %eax,%ecx
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec4:	01 d0                	add    %edx,%eax
80100ec6:	8b 00                	mov    (%eax),%eax
80100ec8:	51                   	push   %ecx
80100ec9:	50                   	push   %eax
80100eca:	ff 75 dc             	pushl  -0x24(%ebp)
80100ecd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ed0:	e8 ba 79 00 00       	call   8010888f <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 a0 01 00 00    	js     80101080 <exec+0x450>
      goto bad;
    ustack[3+argc] = sp;
80100ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee3:	8d 50 03             	lea    0x3(%eax),%edx
80100ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee9:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ef0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f01:	01 d0                	add    %edx,%eax
80100f03:	8b 00                	mov    (%eax),%eax
80100f05:	85 c0                	test   %eax,%eax
80100f07:	0f 85 51 ff ff ff    	jne    80100e5e <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	83 c0 03             	add    $0x3,%eax
80100f13:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100f1a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f1e:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100f25:	ff ff ff 
  ustack[1] = argc;
80100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2b:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f34:	83 c0 01             	add    $0x1,%eax
80100f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f41:	29 d0                	sub    %edx,%eax
80100f43:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4c:	83 c0 04             	add    $0x4,%eax
80100f4f:	c1 e0 02             	shl    $0x2,%eax
80100f52:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f58:	83 c0 04             	add    $0x4,%eax
80100f5b:	c1 e0 02             	shl    $0x2,%eax
80100f5e:	50                   	push   %eax
80100f5f:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100f65:	50                   	push   %eax
80100f66:	ff 75 dc             	pushl  -0x24(%ebp)
80100f69:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f6c:	e8 1e 79 00 00       	call   8010888f <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 07 01 00 00    	js     80101083 <exec+0x453>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f88:	eb 17                	jmp    80100fa1 <exec+0x371>
    if(*s == '/')
80100f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8d:	0f b6 00             	movzbl (%eax),%eax
80100f90:	3c 2f                	cmp    $0x2f,%al
80100f92:	75 09                	jne    80100f9d <exec+0x36d>
      last = s+1;
80100f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f97:	83 c0 01             	add    $0x1,%eax
80100f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	0f b6 00             	movzbl (%eax),%eax
80100fa7:	84 c0                	test   %al,%al
80100fa9:	75 df                	jne    80100f8a <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fab:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fae:	83 c0 6c             	add    $0x6c,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 be 47 00 00       	call   8010577d <safestrcpy>
80100fbf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fc5:	8b 40 04             	mov    0x4(%eax),%eax
80100fc8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100fcb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd1:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fd4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fda:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fdc:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fdf:	8b 40 18             	mov    0x18(%eax),%eax
80100fe2:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100fe8:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100feb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fee:	8b 40 18             	mov    0x18(%eax),%eax
80100ff1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ff4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	ff 75 cc             	pushl  -0x34(%ebp)
80100ffd:	e8 77 71 00 00       	call   80108179 <switchuvm>
80101002:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 c8             	pushl  -0x38(%ebp)
8010100b:	e8 24 76 00 00       	call   80108634 <freevm>
80101010:	83 c4 10             	add    $0x10,%esp
  mencrypt(0, sz/PGSIZE);
80101013:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101016:	c1 e8 0c             	shr    $0xc,%eax
80101019:	83 ec 08             	sub    $0x8,%esp
8010101c:	50                   	push   %eax
8010101d:	6a 00                	push   $0x0
8010101f:	e8 52 7d 00 00       	call   80108d76 <mencrypt>
80101024:	83 c4 10             	add    $0x10,%esp
  curproc->clockIndex = -1;
80101027:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010102a:	c7 80 bc 00 00 00 ff 	movl   $0xffffffff,0xbc(%eax)
80101031:	ff ff ff 
  for(int i = 0; i < CLOCKSIZE; i++){
80101034:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010103b:	eb 15                	jmp    80101052 <exec+0x422>
    curproc->clockQueue[i].vpn = -1;
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101043:	83 c2 0e             	add    $0xe,%edx
80101046:	c7 44 d0 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,8)
8010104d:	ff 
  for(int i = 0; i < CLOCKSIZE; i++){
8010104e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80101052:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80101056:	7e e5                	jle    8010103d <exec+0x40d>
  }
  return 0;
80101058:	b8 00 00 00 00       	mov    $0x0,%eax
8010105d:	eb 57                	jmp    801010b6 <exec+0x486>
    goto bad;
8010105f:	90                   	nop
80101060:	eb 22                	jmp    80101084 <exec+0x454>
    goto bad;
80101062:	90                   	nop
80101063:	eb 1f                	jmp    80101084 <exec+0x454>
    goto bad;
80101065:	90                   	nop
80101066:	eb 1c                	jmp    80101084 <exec+0x454>
      goto bad;
80101068:	90                   	nop
80101069:	eb 19                	jmp    80101084 <exec+0x454>
      goto bad;
8010106b:	90                   	nop
8010106c:	eb 16                	jmp    80101084 <exec+0x454>
      goto bad;
8010106e:	90                   	nop
8010106f:	eb 13                	jmp    80101084 <exec+0x454>
      goto bad;
80101071:	90                   	nop
80101072:	eb 10                	jmp    80101084 <exec+0x454>
      goto bad;
80101074:	90                   	nop
80101075:	eb 0d                	jmp    80101084 <exec+0x454>
      goto bad;
80101077:	90                   	nop
80101078:	eb 0a                	jmp    80101084 <exec+0x454>
    goto bad;
8010107a:	90                   	nop
8010107b:	eb 07                	jmp    80101084 <exec+0x454>
      goto bad;
8010107d:	90                   	nop
8010107e:	eb 04                	jmp    80101084 <exec+0x454>
      goto bad;
80101080:	90                   	nop
80101081:	eb 01                	jmp    80101084 <exec+0x454>
    goto bad;
80101083:	90                   	nop

 bad:
  if(pgdir)
80101084:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101088:	74 0e                	je     80101098 <exec+0x468>
    freevm(pgdir);
8010108a:	83 ec 0c             	sub    $0xc,%esp
8010108d:	ff 75 d4             	pushl  -0x2c(%ebp)
80101090:	e8 9f 75 00 00       	call   80108634 <freevm>
80101095:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101098:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010109c:	74 13                	je     801010b1 <exec+0x481>
    iunlockput(ip);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	ff 75 d8             	pushl  -0x28(%ebp)
801010a4:	e8 b4 0c 00 00       	call   80101d5d <iunlockput>
801010a9:	83 c4 10             	add    $0x10,%esp
    end_op();
801010ac:	e8 f4 26 00 00       	call   801037a5 <end_op>
  }
  return -1;
801010b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010b6:	c9                   	leave  
801010b7:	c3                   	ret    

801010b8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010b8:	f3 0f 1e fb          	endbr32 
801010bc:	55                   	push   %ebp
801010bd:	89 e5                	mov    %esp,%ebp
801010bf:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010c2:	83 ec 08             	sub    $0x8,%esp
801010c5:	68 f1 93 10 80       	push   $0x801093f1
801010ca:	68 60 20 11 80       	push   $0x80112060
801010cf:	e8 c9 41 00 00       	call   8010529d <initlock>
801010d4:	83 c4 10             	add    $0x10,%esp
}
801010d7:	90                   	nop
801010d8:	c9                   	leave  
801010d9:	c3                   	ret    

801010da <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010da:	f3 0f 1e fb          	endbr32 
801010de:	55                   	push   %ebp
801010df:	89 e5                	mov    %esp,%ebp
801010e1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 60 20 11 80       	push   $0x80112060
801010ec:	e8 d2 41 00 00       	call   801052c3 <acquire>
801010f1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010f4:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010fb:	eb 2d                	jmp    8010112a <filealloc+0x50>
    if(f->ref == 0){
801010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101100:	8b 40 04             	mov    0x4(%eax),%eax
80101103:	85 c0                	test   %eax,%eax
80101105:	75 1f                	jne    80101126 <filealloc+0x4c>
      f->ref = 1;
80101107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101111:	83 ec 0c             	sub    $0xc,%esp
80101114:	68 60 20 11 80       	push   $0x80112060
80101119:	e8 17 42 00 00       	call   80105335 <release>
8010111e:	83 c4 10             	add    $0x10,%esp
      return f;
80101121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101124:	eb 23                	jmp    80101149 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101126:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010112a:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
8010112f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101132:	72 c9                	jb     801010fd <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101134:	83 ec 0c             	sub    $0xc,%esp
80101137:	68 60 20 11 80       	push   $0x80112060
8010113c:	e8 f4 41 00 00       	call   80105335 <release>
80101141:	83 c4 10             	add    $0x10,%esp
  return 0;
80101144:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101149:	c9                   	leave  
8010114a:	c3                   	ret    

8010114b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010114b:	f3 0f 1e fb          	endbr32 
8010114f:	55                   	push   %ebp
80101150:	89 e5                	mov    %esp,%ebp
80101152:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101155:	83 ec 0c             	sub    $0xc,%esp
80101158:	68 60 20 11 80       	push   $0x80112060
8010115d:	e8 61 41 00 00       	call   801052c3 <acquire>
80101162:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101165:	8b 45 08             	mov    0x8(%ebp),%eax
80101168:	8b 40 04             	mov    0x4(%eax),%eax
8010116b:	85 c0                	test   %eax,%eax
8010116d:	7f 0d                	jg     8010117c <filedup+0x31>
    panic("filedup");
8010116f:	83 ec 0c             	sub    $0xc,%esp
80101172:	68 f8 93 10 80       	push   $0x801093f8
80101177:	e8 8c f4 ff ff       	call   80100608 <panic>
  f->ref++;
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 40 04             	mov    0x4(%eax),%eax
80101182:	8d 50 01             	lea    0x1(%eax),%edx
80101185:	8b 45 08             	mov    0x8(%ebp),%eax
80101188:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010118b:	83 ec 0c             	sub    $0xc,%esp
8010118e:	68 60 20 11 80       	push   $0x80112060
80101193:	e8 9d 41 00 00       	call   80105335 <release>
80101198:	83 c4 10             	add    $0x10,%esp
  return f;
8010119b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010119e:	c9                   	leave  
8010119f:	c3                   	ret    

801011a0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011a0:	f3 0f 1e fb          	endbr32 
801011a4:	55                   	push   %ebp
801011a5:	89 e5                	mov    %esp,%ebp
801011a7:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011aa:	83 ec 0c             	sub    $0xc,%esp
801011ad:	68 60 20 11 80       	push   $0x80112060
801011b2:	e8 0c 41 00 00       	call   801052c3 <acquire>
801011b7:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 04             	mov    0x4(%eax),%eax
801011c0:	85 c0                	test   %eax,%eax
801011c2:	7f 0d                	jg     801011d1 <fileclose+0x31>
    panic("fileclose");
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	68 00 94 10 80       	push   $0x80109400
801011cc:	e8 37 f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	8b 40 04             	mov    0x4(%eax),%eax
801011d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801011da:	8b 45 08             	mov    0x8(%ebp),%eax
801011dd:	89 50 04             	mov    %edx,0x4(%eax)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	8b 40 04             	mov    0x4(%eax),%eax
801011e6:	85 c0                	test   %eax,%eax
801011e8:	7e 15                	jle    801011ff <fileclose+0x5f>
    release(&ftable.lock);
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 60 20 11 80       	push   $0x80112060
801011f2:	e8 3e 41 00 00       	call   80105335 <release>
801011f7:	83 c4 10             	add    $0x10,%esp
801011fa:	e9 8b 00 00 00       	jmp    8010128a <fileclose+0xea>
    return;
  }
  ff = *f;
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 10                	mov    (%eax),%edx
80101204:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101207:	8b 50 04             	mov    0x4(%eax),%edx
8010120a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010120d:	8b 50 08             	mov    0x8(%eax),%edx
80101210:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101213:	8b 50 0c             	mov    0xc(%eax),%edx
80101216:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101219:	8b 50 10             	mov    0x10(%eax),%edx
8010121c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010121f:	8b 40 14             	mov    0x14(%eax),%eax
80101222:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101225:	8b 45 08             	mov    0x8(%ebp),%eax
80101228:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010122f:	8b 45 08             	mov    0x8(%ebp),%eax
80101232:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101238:	83 ec 0c             	sub    $0xc,%esp
8010123b:	68 60 20 11 80       	push   $0x80112060
80101240:	e8 f0 40 00 00       	call   80105335 <release>
80101245:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101248:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010124b:	83 f8 01             	cmp    $0x1,%eax
8010124e:	75 19                	jne    80101269 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101250:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101254:	0f be d0             	movsbl %al,%edx
80101257:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010125a:	83 ec 08             	sub    $0x8,%esp
8010125d:	52                   	push   %edx
8010125e:	50                   	push   %eax
8010125f:	e8 e7 2e 00 00       	call   8010414b <pipeclose>
80101264:	83 c4 10             	add    $0x10,%esp
80101267:	eb 21                	jmp    8010128a <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101269:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010126c:	83 f8 02             	cmp    $0x2,%eax
8010126f:	75 19                	jne    8010128a <fileclose+0xea>
    begin_op();
80101271:	e8 9f 24 00 00       	call   80103715 <begin_op>
    iput(ff.ip);
80101276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101279:	83 ec 0c             	sub    $0xc,%esp
8010127c:	50                   	push   %eax
8010127d:	e8 07 0a 00 00       	call   80101c89 <iput>
80101282:	83 c4 10             	add    $0x10,%esp
    end_op();
80101285:	e8 1b 25 00 00       	call   801037a5 <end_op>
  }
}
8010128a:	c9                   	leave  
8010128b:	c3                   	ret    

8010128c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010128c:	f3 0f 1e fb          	endbr32 
80101290:	55                   	push   %ebp
80101291:	89 e5                	mov    %esp,%ebp
80101293:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 00                	mov    (%eax),%eax
8010129b:	83 f8 02             	cmp    $0x2,%eax
8010129e:	75 40                	jne    801012e0 <filestat+0x54>
    ilock(f->ip);
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	8b 40 10             	mov    0x10(%eax),%eax
801012a6:	83 ec 0c             	sub    $0xc,%esp
801012a9:	50                   	push   %eax
801012aa:	e8 71 08 00 00       	call   80101b20 <ilock>
801012af:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 10             	mov    0x10(%eax),%eax
801012b8:	83 ec 08             	sub    $0x8,%esp
801012bb:	ff 75 0c             	pushl  0xc(%ebp)
801012be:	50                   	push   %eax
801012bf:	e8 1a 0d 00 00       	call   80101fde <stati>
801012c4:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012c7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ca:	8b 40 10             	mov    0x10(%eax),%eax
801012cd:	83 ec 0c             	sub    $0xc,%esp
801012d0:	50                   	push   %eax
801012d1:	e8 61 09 00 00       	call   80101c37 <iunlock>
801012d6:	83 c4 10             	add    $0x10,%esp
    return 0;
801012d9:	b8 00 00 00 00       	mov    $0x0,%eax
801012de:	eb 05                	jmp    801012e5 <filestat+0x59>
  }
  return -1;
801012e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012e5:	c9                   	leave  
801012e6:	c3                   	ret    

801012e7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012e7:	f3 0f 1e fb          	endbr32 
801012eb:	55                   	push   %ebp
801012ec:	89 e5                	mov    %esp,%ebp
801012ee:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012f1:	8b 45 08             	mov    0x8(%ebp),%eax
801012f4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012f8:	84 c0                	test   %al,%al
801012fa:	75 0a                	jne    80101306 <fileread+0x1f>
    return -1;
801012fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101301:	e9 9b 00 00 00       	jmp    801013a1 <fileread+0xba>
  if(f->type == FD_PIPE)
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 00                	mov    (%eax),%eax
8010130b:	83 f8 01             	cmp    $0x1,%eax
8010130e:	75 1a                	jne    8010132a <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 40 0c             	mov    0xc(%eax),%eax
80101316:	83 ec 04             	sub    $0x4,%esp
80101319:	ff 75 10             	pushl  0x10(%ebp)
8010131c:	ff 75 0c             	pushl  0xc(%ebp)
8010131f:	50                   	push   %eax
80101320:	e8 db 2f 00 00       	call   80104300 <piperead>
80101325:	83 c4 10             	add    $0x10,%esp
80101328:	eb 77                	jmp    801013a1 <fileread+0xba>
  if(f->type == FD_INODE){
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 00                	mov    (%eax),%eax
8010132f:	83 f8 02             	cmp    $0x2,%eax
80101332:	75 60                	jne    80101394 <fileread+0xad>
    ilock(f->ip);
80101334:	8b 45 08             	mov    0x8(%ebp),%eax
80101337:	8b 40 10             	mov    0x10(%eax),%eax
8010133a:	83 ec 0c             	sub    $0xc,%esp
8010133d:	50                   	push   %eax
8010133e:	e8 dd 07 00 00       	call   80101b20 <ilock>
80101343:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101346:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	8b 50 14             	mov    0x14(%eax),%edx
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 40 10             	mov    0x10(%eax),%eax
80101355:	51                   	push   %ecx
80101356:	52                   	push   %edx
80101357:	ff 75 0c             	pushl  0xc(%ebp)
8010135a:	50                   	push   %eax
8010135b:	e8 c8 0c 00 00       	call   80102028 <readi>
80101360:	83 c4 10             	add    $0x10,%esp
80101363:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010136a:	7e 11                	jle    8010137d <fileread+0x96>
      f->off += r;
8010136c:	8b 45 08             	mov    0x8(%ebp),%eax
8010136f:	8b 50 14             	mov    0x14(%eax),%edx
80101372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101375:	01 c2                	add    %eax,%edx
80101377:	8b 45 08             	mov    0x8(%ebp),%eax
8010137a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010137d:	8b 45 08             	mov    0x8(%ebp),%eax
80101380:	8b 40 10             	mov    0x10(%eax),%eax
80101383:	83 ec 0c             	sub    $0xc,%esp
80101386:	50                   	push   %eax
80101387:	e8 ab 08 00 00       	call   80101c37 <iunlock>
8010138c:	83 c4 10             	add    $0x10,%esp
    return r;
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	eb 0d                	jmp    801013a1 <fileread+0xba>
  }
  panic("fileread");
80101394:	83 ec 0c             	sub    $0xc,%esp
80101397:	68 0a 94 10 80       	push   $0x8010940a
8010139c:	e8 67 f2 ff ff       	call   80100608 <panic>
}
801013a1:	c9                   	leave  
801013a2:	c3                   	ret    

801013a3 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013a3:	f3 0f 1e fb          	endbr32 
801013a7:	55                   	push   %ebp
801013a8:	89 e5                	mov    %esp,%ebp
801013aa:	53                   	push   %ebx
801013ab:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013b5:	84 c0                	test   %al,%al
801013b7:	75 0a                	jne    801013c3 <filewrite+0x20>
    return -1;
801013b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013be:	e9 1b 01 00 00       	jmp    801014de <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013c3:	8b 45 08             	mov    0x8(%ebp),%eax
801013c6:	8b 00                	mov    (%eax),%eax
801013c8:	83 f8 01             	cmp    $0x1,%eax
801013cb:	75 1d                	jne    801013ea <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013cd:	8b 45 08             	mov    0x8(%ebp),%eax
801013d0:	8b 40 0c             	mov    0xc(%eax),%eax
801013d3:	83 ec 04             	sub    $0x4,%esp
801013d6:	ff 75 10             	pushl  0x10(%ebp)
801013d9:	ff 75 0c             	pushl  0xc(%ebp)
801013dc:	50                   	push   %eax
801013dd:	e8 18 2e 00 00       	call   801041fa <pipewrite>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	e9 f4 00 00 00       	jmp    801014de <filewrite+0x13b>
  if(f->type == FD_INODE){
801013ea:	8b 45 08             	mov    0x8(%ebp),%eax
801013ed:	8b 00                	mov    (%eax),%eax
801013ef:	83 f8 02             	cmp    $0x2,%eax
801013f2:	0f 85 d9 00 00 00    	jne    801014d1 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013f8:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101406:	e9 a3 00 00 00       	jmp    801014ae <filewrite+0x10b>
      int n1 = n - i;
8010140b:	8b 45 10             	mov    0x10(%ebp),%eax
8010140e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101411:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101414:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101417:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010141a:	7e 06                	jle    80101422 <filewrite+0x7f>
        n1 = max;
8010141c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010141f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101422:	e8 ee 22 00 00       	call   80103715 <begin_op>
      ilock(f->ip);
80101427:	8b 45 08             	mov    0x8(%ebp),%eax
8010142a:	8b 40 10             	mov    0x10(%eax),%eax
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	50                   	push   %eax
80101431:	e8 ea 06 00 00       	call   80101b20 <ilock>
80101436:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101439:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	8b 50 14             	mov    0x14(%eax),%edx
80101442:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101445:	8b 45 0c             	mov    0xc(%ebp),%eax
80101448:	01 c3                	add    %eax,%ebx
8010144a:	8b 45 08             	mov    0x8(%ebp),%eax
8010144d:	8b 40 10             	mov    0x10(%eax),%eax
80101450:	51                   	push   %ecx
80101451:	52                   	push   %edx
80101452:	53                   	push   %ebx
80101453:	50                   	push   %eax
80101454:	e8 28 0d 00 00       	call   80102181 <writei>
80101459:	83 c4 10             	add    $0x10,%esp
8010145c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010145f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101463:	7e 11                	jle    80101476 <filewrite+0xd3>
        f->off += r;
80101465:	8b 45 08             	mov    0x8(%ebp),%eax
80101468:	8b 50 14             	mov    0x14(%eax),%edx
8010146b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010146e:	01 c2                	add    %eax,%edx
80101470:	8b 45 08             	mov    0x8(%ebp),%eax
80101473:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101476:	8b 45 08             	mov    0x8(%ebp),%eax
80101479:	8b 40 10             	mov    0x10(%eax),%eax
8010147c:	83 ec 0c             	sub    $0xc,%esp
8010147f:	50                   	push   %eax
80101480:	e8 b2 07 00 00       	call   80101c37 <iunlock>
80101485:	83 c4 10             	add    $0x10,%esp
      end_op();
80101488:	e8 18 23 00 00       	call   801037a5 <end_op>

      if(r < 0)
8010148d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101491:	78 29                	js     801014bc <filewrite+0x119>
        break;
      if(r != n1)
80101493:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101496:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101499:	74 0d                	je     801014a8 <filewrite+0x105>
        panic("short filewrite");
8010149b:	83 ec 0c             	sub    $0xc,%esp
8010149e:	68 13 94 10 80       	push   $0x80109413
801014a3:	e8 60 f1 ff ff       	call   80100608 <panic>
      i += r;
801014a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014ab:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801014b4:	0f 8c 51 ff ff ff    	jl     8010140b <filewrite+0x68>
801014ba:	eb 01                	jmp    801014bd <filewrite+0x11a>
        break;
801014bc:	90                   	nop
    }
    return i == n ? n : -1;
801014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801014c3:	75 05                	jne    801014ca <filewrite+0x127>
801014c5:	8b 45 10             	mov    0x10(%ebp),%eax
801014c8:	eb 14                	jmp    801014de <filewrite+0x13b>
801014ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014cf:	eb 0d                	jmp    801014de <filewrite+0x13b>
  }
  panic("filewrite");
801014d1:	83 ec 0c             	sub    $0xc,%esp
801014d4:	68 23 94 10 80       	push   $0x80109423
801014d9:	e8 2a f1 ff ff       	call   80100608 <panic>
}
801014de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014e1:	c9                   	leave  
801014e2:	c3                   	ret    

801014e3 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014e3:	f3 0f 1e fb          	endbr32 
801014e7:	55                   	push   %ebp
801014e8:	89 e5                	mov    %esp,%ebp
801014ea:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014ed:	8b 45 08             	mov    0x8(%ebp),%eax
801014f0:	83 ec 08             	sub    $0x8,%esp
801014f3:	6a 01                	push   $0x1
801014f5:	50                   	push   %eax
801014f6:	e8 dc ec ff ff       	call   801001d7 <bread>
801014fb:	83 c4 10             	add    $0x10,%esp
801014fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101504:	83 c0 5c             	add    $0x5c,%eax
80101507:	83 ec 04             	sub    $0x4,%esp
8010150a:	6a 1c                	push   $0x1c
8010150c:	50                   	push   %eax
8010150d:	ff 75 0c             	pushl  0xc(%ebp)
80101510:	e8 14 41 00 00       	call   80105629 <memmove>
80101515:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 f4             	pushl  -0xc(%ebp)
8010151e:	e8 3e ed ff ff       	call   80100261 <brelse>
80101523:	83 c4 10             	add    $0x10,%esp
}
80101526:	90                   	nop
80101527:	c9                   	leave  
80101528:	c3                   	ret    

80101529 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101529:	f3 0f 1e fb          	endbr32 
8010152d:	55                   	push   %ebp
8010152e:	89 e5                	mov    %esp,%ebp
80101530:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101533:	8b 55 0c             	mov    0xc(%ebp),%edx
80101536:	8b 45 08             	mov    0x8(%ebp),%eax
80101539:	83 ec 08             	sub    $0x8,%esp
8010153c:	52                   	push   %edx
8010153d:	50                   	push   %eax
8010153e:	e8 94 ec ff ff       	call   801001d7 <bread>
80101543:	83 c4 10             	add    $0x10,%esp
80101546:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154c:	83 c0 5c             	add    $0x5c,%eax
8010154f:	83 ec 04             	sub    $0x4,%esp
80101552:	68 00 02 00 00       	push   $0x200
80101557:	6a 00                	push   $0x0
80101559:	50                   	push   %eax
8010155a:	e8 03 40 00 00       	call   80105562 <memset>
8010155f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 f4             	pushl  -0xc(%ebp)
80101568:	e8 f1 23 00 00       	call   8010395e <log_write>
8010156d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101570:	83 ec 0c             	sub    $0xc,%esp
80101573:	ff 75 f4             	pushl  -0xc(%ebp)
80101576:	e8 e6 ec ff ff       	call   80100261 <brelse>
8010157b:	83 c4 10             	add    $0x10,%esp
}
8010157e:	90                   	nop
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101581:	f3 0f 1e fb          	endbr32 
80101585:	55                   	push   %ebp
80101586:	89 e5                	mov    %esp,%ebp
80101588:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010158b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101592:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101599:	e9 13 01 00 00       	jmp    801016b1 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
8010159e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015a7:	85 c0                	test   %eax,%eax
801015a9:	0f 48 c2             	cmovs  %edx,%eax
801015ac:	c1 f8 0c             	sar    $0xc,%eax
801015af:	89 c2                	mov    %eax,%edx
801015b1:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015b6:	01 d0                	add    %edx,%eax
801015b8:	83 ec 08             	sub    $0x8,%esp
801015bb:	50                   	push   %eax
801015bc:	ff 75 08             	pushl  0x8(%ebp)
801015bf:	e8 13 ec ff ff       	call   801001d7 <bread>
801015c4:	83 c4 10             	add    $0x10,%esp
801015c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015d1:	e9 a6 00 00 00       	jmp    8010167c <balloc+0xfb>
      m = 1 << (bi % 8);
801015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d9:	99                   	cltd   
801015da:	c1 ea 1d             	shr    $0x1d,%edx
801015dd:	01 d0                	add    %edx,%eax
801015df:	83 e0 07             	and    $0x7,%eax
801015e2:	29 d0                	sub    %edx,%eax
801015e4:	ba 01 00 00 00       	mov    $0x1,%edx
801015e9:	89 c1                	mov    %eax,%ecx
801015eb:	d3 e2                	shl    %cl,%edx
801015ed:	89 d0                	mov    %edx,%eax
801015ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f5:	8d 50 07             	lea    0x7(%eax),%edx
801015f8:	85 c0                	test   %eax,%eax
801015fa:	0f 48 c2             	cmovs  %edx,%eax
801015fd:	c1 f8 03             	sar    $0x3,%eax
80101600:	89 c2                	mov    %eax,%edx
80101602:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101605:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010160a:	0f b6 c0             	movzbl %al,%eax
8010160d:	23 45 e8             	and    -0x18(%ebp),%eax
80101610:	85 c0                	test   %eax,%eax
80101612:	75 64                	jne    80101678 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101617:	8d 50 07             	lea    0x7(%eax),%edx
8010161a:	85 c0                	test   %eax,%eax
8010161c:	0f 48 c2             	cmovs  %edx,%eax
8010161f:	c1 f8 03             	sar    $0x3,%eax
80101622:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101625:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010162a:	89 d1                	mov    %edx,%ecx
8010162c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010162f:	09 ca                	or     %ecx,%edx
80101631:	89 d1                	mov    %edx,%ecx
80101633:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101636:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010163a:	83 ec 0c             	sub    $0xc,%esp
8010163d:	ff 75 ec             	pushl  -0x14(%ebp)
80101640:	e8 19 23 00 00       	call   8010395e <log_write>
80101645:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101648:	83 ec 0c             	sub    $0xc,%esp
8010164b:	ff 75 ec             	pushl  -0x14(%ebp)
8010164e:	e8 0e ec ff ff       	call   80100261 <brelse>
80101653:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165c:	01 c2                	add    %eax,%edx
8010165e:	8b 45 08             	mov    0x8(%ebp),%eax
80101661:	83 ec 08             	sub    $0x8,%esp
80101664:	52                   	push   %edx
80101665:	50                   	push   %eax
80101666:	e8 be fe ff ff       	call   80101529 <bzero>
8010166b:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010166e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101674:	01 d0                	add    %edx,%eax
80101676:	eb 57                	jmp    801016cf <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101678:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010167c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101683:	7f 17                	jg     8010169c <balloc+0x11b>
80101685:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168b:	01 d0                	add    %edx,%eax
8010168d:	89 c2                	mov    %eax,%edx
8010168f:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101694:	39 c2                	cmp    %eax,%edx
80101696:	0f 82 3a ff ff ff    	jb     801015d6 <balloc+0x55>
      }
    }
    brelse(bp);
8010169c:	83 ec 0c             	sub    $0xc,%esp
8010169f:	ff 75 ec             	pushl  -0x14(%ebp)
801016a2:	e8 ba eb ff ff       	call   80100261 <brelse>
801016a7:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016aa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016b1:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ba:	39 c2                	cmp    %eax,%edx
801016bc:	0f 87 dc fe ff ff    	ja     8010159e <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016c2:	83 ec 0c             	sub    $0xc,%esp
801016c5:	68 30 94 10 80       	push   $0x80109430
801016ca:	e8 39 ef ff ff       	call   80100608 <panic>
}
801016cf:	c9                   	leave  
801016d0:	c3                   	ret    

801016d1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016d1:	f3 0f 1e fb          	endbr32 
801016d5:	55                   	push   %ebp
801016d6:	89 e5                	mov    %esp,%ebp
801016d8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016db:	8b 45 0c             	mov    0xc(%ebp),%eax
801016de:	c1 e8 0c             	shr    $0xc,%eax
801016e1:	89 c2                	mov    %eax,%edx
801016e3:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016e8:	01 c2                	add    %eax,%edx
801016ea:	8b 45 08             	mov    0x8(%ebp),%eax
801016ed:	83 ec 08             	sub    $0x8,%esp
801016f0:	52                   	push   %edx
801016f1:	50                   	push   %eax
801016f2:	e8 e0 ea ff ff       	call   801001d7 <bread>
801016f7:	83 c4 10             	add    $0x10,%esp
801016fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101700:	25 ff 0f 00 00       	and    $0xfff,%eax
80101705:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170b:	99                   	cltd   
8010170c:	c1 ea 1d             	shr    $0x1d,%edx
8010170f:	01 d0                	add    %edx,%eax
80101711:	83 e0 07             	and    $0x7,%eax
80101714:	29 d0                	sub    %edx,%eax
80101716:	ba 01 00 00 00       	mov    $0x1,%edx
8010171b:	89 c1                	mov    %eax,%ecx
8010171d:	d3 e2                	shl    %cl,%edx
8010171f:	89 d0                	mov    %edx,%eax
80101721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101727:	8d 50 07             	lea    0x7(%eax),%edx
8010172a:	85 c0                	test   %eax,%eax
8010172c:	0f 48 c2             	cmovs  %edx,%eax
8010172f:	c1 f8 03             	sar    $0x3,%eax
80101732:	89 c2                	mov    %eax,%edx
80101734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101737:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010173c:	0f b6 c0             	movzbl %al,%eax
8010173f:	23 45 ec             	and    -0x14(%ebp),%eax
80101742:	85 c0                	test   %eax,%eax
80101744:	75 0d                	jne    80101753 <bfree+0x82>
    panic("freeing free block");
80101746:	83 ec 0c             	sub    $0xc,%esp
80101749:	68 46 94 10 80       	push   $0x80109446
8010174e:	e8 b5 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
80101753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101756:	8d 50 07             	lea    0x7(%eax),%edx
80101759:	85 c0                	test   %eax,%eax
8010175b:	0f 48 c2             	cmovs  %edx,%eax
8010175e:	c1 f8 03             	sar    $0x3,%eax
80101761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101764:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101769:	89 d1                	mov    %edx,%ecx
8010176b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010176e:	f7 d2                	not    %edx
80101770:	21 ca                	and    %ecx,%edx
80101772:	89 d1                	mov    %edx,%ecx
80101774:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101777:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010177b:	83 ec 0c             	sub    $0xc,%esp
8010177e:	ff 75 f4             	pushl  -0xc(%ebp)
80101781:	e8 d8 21 00 00       	call   8010395e <log_write>
80101786:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101789:	83 ec 0c             	sub    $0xc,%esp
8010178c:	ff 75 f4             	pushl  -0xc(%ebp)
8010178f:	e8 cd ea ff ff       	call   80100261 <brelse>
80101794:	83 c4 10             	add    $0x10,%esp
}
80101797:	90                   	nop
80101798:	c9                   	leave  
80101799:	c3                   	ret    

8010179a <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010179a:	f3 0f 1e fb          	endbr32 
8010179e:	55                   	push   %ebp
8010179f:	89 e5                	mov    %esp,%ebp
801017a1:	57                   	push   %edi
801017a2:	56                   	push   %esi
801017a3:	53                   	push   %ebx
801017a4:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017ae:	83 ec 08             	sub    $0x8,%esp
801017b1:	68 59 94 10 80       	push   $0x80109459
801017b6:	68 80 2a 11 80       	push   $0x80112a80
801017bb:	e8 dd 3a 00 00       	call   8010529d <initlock>
801017c0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017ca:	eb 2d                	jmp    801017f9 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017cf:	89 d0                	mov    %edx,%eax
801017d1:	c1 e0 03             	shl    $0x3,%eax
801017d4:	01 d0                	add    %edx,%eax
801017d6:	c1 e0 04             	shl    $0x4,%eax
801017d9:	83 c0 30             	add    $0x30,%eax
801017dc:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017e1:	83 c0 10             	add    $0x10,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	68 60 94 10 80       	push   $0x80109460
801017ec:	50                   	push   %eax
801017ed:	e8 18 39 00 00       	call   8010510a <initsleeplock>
801017f2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017f5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017f9:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017fd:	7e cd                	jle    801017cc <iinit+0x32>
  }

  readsb(dev, &sb);
801017ff:	83 ec 08             	sub    $0x8,%esp
80101802:	68 60 2a 11 80       	push   $0x80112a60
80101807:	ff 75 08             	pushl  0x8(%ebp)
8010180a:	e8 d4 fc ff ff       	call   801014e3 <readsb>
8010180f:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101812:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101817:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010181a:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101820:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101826:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
8010182c:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101832:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101838:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010183d:	ff 75 d4             	pushl  -0x2c(%ebp)
80101840:	57                   	push   %edi
80101841:	56                   	push   %esi
80101842:	53                   	push   %ebx
80101843:	51                   	push   %ecx
80101844:	52                   	push   %edx
80101845:	50                   	push   %eax
80101846:	68 68 94 10 80       	push   $0x80109468
8010184b:	e8 c8 eb ff ff       	call   80100418 <cprintf>
80101850:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101853:	90                   	nop
80101854:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101857:	5b                   	pop    %ebx
80101858:	5e                   	pop    %esi
80101859:	5f                   	pop    %edi
8010185a:	5d                   	pop    %ebp
8010185b:	c3                   	ret    

8010185c <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010185c:	f3 0f 1e fb          	endbr32 
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	83 ec 28             	sub    $0x28,%esp
80101866:	8b 45 0c             	mov    0xc(%ebp),%eax
80101869:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010186d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101874:	e9 9e 00 00 00       	jmp    80101917 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	c1 e8 03             	shr    $0x3,%eax
8010187f:	89 c2                	mov    %eax,%edx
80101881:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101886:	01 d0                	add    %edx,%eax
80101888:	83 ec 08             	sub    $0x8,%esp
8010188b:	50                   	push   %eax
8010188c:	ff 75 08             	pushl  0x8(%ebp)
8010188f:	e8 43 e9 ff ff       	call   801001d7 <bread>
80101894:	83 c4 10             	add    $0x10,%esp
80101897:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	83 e0 07             	and    $0x7,%eax
801018a6:	c1 e0 06             	shl    $0x6,%eax
801018a9:	01 d0                	add    %edx,%eax
801018ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018b1:	0f b7 00             	movzwl (%eax),%eax
801018b4:	66 85 c0             	test   %ax,%ax
801018b7:	75 4c                	jne    80101905 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018b9:	83 ec 04             	sub    $0x4,%esp
801018bc:	6a 40                	push   $0x40
801018be:	6a 00                	push   $0x0
801018c0:	ff 75 ec             	pushl  -0x14(%ebp)
801018c3:	e8 9a 3c 00 00       	call   80105562 <memset>
801018c8:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018ce:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018d2:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018d5:	83 ec 0c             	sub    $0xc,%esp
801018d8:	ff 75 f0             	pushl  -0x10(%ebp)
801018db:	e8 7e 20 00 00       	call   8010395e <log_write>
801018e0:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	ff 75 f0             	pushl  -0x10(%ebp)
801018e9:	e8 73 e9 ff ff       	call   80100261 <brelse>
801018ee:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f4:	83 ec 08             	sub    $0x8,%esp
801018f7:	50                   	push   %eax
801018f8:	ff 75 08             	pushl  0x8(%ebp)
801018fb:	e8 fc 00 00 00       	call   801019fc <iget>
80101900:	83 c4 10             	add    $0x10,%esp
80101903:	eb 30                	jmp    80101935 <ialloc+0xd9>
    }
    brelse(bp);
80101905:	83 ec 0c             	sub    $0xc,%esp
80101908:	ff 75 f0             	pushl  -0x10(%ebp)
8010190b:	e8 51 e9 ff ff       	call   80100261 <brelse>
80101910:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101913:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101917:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	39 c2                	cmp    %eax,%edx
80101922:	0f 87 51 ff ff ff    	ja     80101879 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101928:	83 ec 0c             	sub    $0xc,%esp
8010192b:	68 bb 94 10 80       	push   $0x801094bb
80101930:	e8 d3 ec ff ff       	call   80100608 <panic>
}
80101935:	c9                   	leave  
80101936:	c3                   	ret    

80101937 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101937:	f3 0f 1e fb          	endbr32 
8010193b:	55                   	push   %ebp
8010193c:	89 e5                	mov    %esp,%ebp
8010193e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 40 04             	mov    0x4(%eax),%eax
80101947:	c1 e8 03             	shr    $0x3,%eax
8010194a:	89 c2                	mov    %eax,%edx
8010194c:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101951:	01 c2                	add    %eax,%edx
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 00                	mov    (%eax),%eax
80101958:	83 ec 08             	sub    $0x8,%esp
8010195b:	52                   	push   %edx
8010195c:	50                   	push   %eax
8010195d:	e8 75 e8 ff ff       	call   801001d7 <bread>
80101962:	83 c4 10             	add    $0x10,%esp
80101965:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	8b 40 04             	mov    0x4(%eax),%eax
80101974:	83 e0 07             	and    $0x7,%eax
80101977:	c1 e0 06             	shl    $0x6,%eax
8010197a:	01 d0                	add    %edx,%eax
8010197c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010197f:	8b 45 08             	mov    0x8(%ebp),%eax
80101982:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101989:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010198c:	8b 45 08             	mov    0x8(%ebp),%eax
8010198f:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101996:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a4:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b2:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019b6:	8b 45 08             	mov    0x8(%ebp),%eax
801019b9:	8b 50 58             	mov    0x58(%eax),%edx
801019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bf:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8d 50 5c             	lea    0x5c(%eax),%edx
801019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cb:	83 c0 0c             	add    $0xc,%eax
801019ce:	83 ec 04             	sub    $0x4,%esp
801019d1:	6a 34                	push   $0x34
801019d3:	52                   	push   %edx
801019d4:	50                   	push   %eax
801019d5:	e8 4f 3c 00 00       	call   80105629 <memmove>
801019da:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	ff 75 f4             	pushl  -0xc(%ebp)
801019e3:	e8 76 1f 00 00       	call   8010395e <log_write>
801019e8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019eb:	83 ec 0c             	sub    $0xc,%esp
801019ee:	ff 75 f4             	pushl  -0xc(%ebp)
801019f1:	e8 6b e8 ff ff       	call   80100261 <brelse>
801019f6:	83 c4 10             	add    $0x10,%esp
}
801019f9:	90                   	nop
801019fa:	c9                   	leave  
801019fb:	c3                   	ret    

801019fc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019fc:	f3 0f 1e fb          	endbr32 
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a06:	83 ec 0c             	sub    $0xc,%esp
80101a09:	68 80 2a 11 80       	push   $0x80112a80
80101a0e:	e8 b0 38 00 00       	call   801052c3 <acquire>
80101a13:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a16:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a1d:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a24:	eb 60                	jmp    80101a86 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a29:	8b 40 08             	mov    0x8(%eax),%eax
80101a2c:	85 c0                	test   %eax,%eax
80101a2e:	7e 39                	jle    80101a69 <iget+0x6d>
80101a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a33:	8b 00                	mov    (%eax),%eax
80101a35:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a38:	75 2f                	jne    80101a69 <iget+0x6d>
80101a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3d:	8b 40 04             	mov    0x4(%eax),%eax
80101a40:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a43:	75 24                	jne    80101a69 <iget+0x6d>
      ip->ref++;
80101a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a48:	8b 40 08             	mov    0x8(%eax),%eax
80101a4b:	8d 50 01             	lea    0x1(%eax),%edx
80101a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a51:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a54:	83 ec 0c             	sub    $0xc,%esp
80101a57:	68 80 2a 11 80       	push   $0x80112a80
80101a5c:	e8 d4 38 00 00       	call   80105335 <release>
80101a61:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a67:	eb 77                	jmp    80101ae0 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a6d:	75 10                	jne    80101a7f <iget+0x83>
80101a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a72:	8b 40 08             	mov    0x8(%eax),%eax
80101a75:	85 c0                	test   %eax,%eax
80101a77:	75 06                	jne    80101a7f <iget+0x83>
      empty = ip;
80101a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a7f:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a86:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a8d:	72 97                	jb     80101a26 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a93:	75 0d                	jne    80101aa2 <iget+0xa6>
    panic("iget: no inodes");
80101a95:	83 ec 0c             	sub    $0xc,%esp
80101a98:	68 cd 94 10 80       	push   $0x801094cd
80101a9d:	e8 66 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aab:	8b 55 08             	mov    0x8(%ebp),%edx
80101aae:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ab6:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac6:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101acd:	83 ec 0c             	sub    $0xc,%esp
80101ad0:	68 80 2a 11 80       	push   $0x80112a80
80101ad5:	e8 5b 38 00 00       	call   80105335 <release>
80101ada:	83 c4 10             	add    $0x10,%esp

  return ip;
80101add:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ae0:	c9                   	leave  
80101ae1:	c3                   	ret    

80101ae2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ae2:	f3 0f 1e fb          	endbr32 
80101ae6:	55                   	push   %ebp
80101ae7:	89 e5                	mov    %esp,%ebp
80101ae9:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aec:	83 ec 0c             	sub    $0xc,%esp
80101aef:	68 80 2a 11 80       	push   $0x80112a80
80101af4:	e8 ca 37 00 00       	call   801052c3 <acquire>
80101af9:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	8b 40 08             	mov    0x8(%eax),%eax
80101b02:	8d 50 01             	lea    0x1(%eax),%edx
80101b05:	8b 45 08             	mov    0x8(%ebp),%eax
80101b08:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b0b:	83 ec 0c             	sub    $0xc,%esp
80101b0e:	68 80 2a 11 80       	push   $0x80112a80
80101b13:	e8 1d 38 00 00       	call   80105335 <release>
80101b18:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b1e:	c9                   	leave  
80101b1f:	c3                   	ret    

80101b20 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b20:	f3 0f 1e fb          	endbr32 
80101b24:	55                   	push   %ebp
80101b25:	89 e5                	mov    %esp,%ebp
80101b27:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b2e:	74 0a                	je     80101b3a <ilock+0x1a>
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 40 08             	mov    0x8(%eax),%eax
80101b36:	85 c0                	test   %eax,%eax
80101b38:	7f 0d                	jg     80101b47 <ilock+0x27>
    panic("ilock");
80101b3a:	83 ec 0c             	sub    $0xc,%esp
80101b3d:	68 dd 94 10 80       	push   $0x801094dd
80101b42:	e8 c1 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b47:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4a:	83 c0 0c             	add    $0xc,%eax
80101b4d:	83 ec 0c             	sub    $0xc,%esp
80101b50:	50                   	push   %eax
80101b51:	e8 f4 35 00 00       	call   8010514a <acquiresleep>
80101b56:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5f:	85 c0                	test   %eax,%eax
80101b61:	0f 85 cd 00 00 00    	jne    80101c34 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b67:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6a:	8b 40 04             	mov    0x4(%eax),%eax
80101b6d:	c1 e8 03             	shr    $0x3,%eax
80101b70:	89 c2                	mov    %eax,%edx
80101b72:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b77:	01 c2                	add    %eax,%edx
80101b79:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7c:	8b 00                	mov    (%eax),%eax
80101b7e:	83 ec 08             	sub    $0x8,%esp
80101b81:	52                   	push   %edx
80101b82:	50                   	push   %eax
80101b83:	e8 4f e6 ff ff       	call   801001d7 <bread>
80101b88:	83 c4 10             	add    $0x10,%esp
80101b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b91:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	8b 40 04             	mov    0x4(%eax),%eax
80101b9a:	83 e0 07             	and    $0x7,%eax
80101b9d:	c1 e0 06             	shl    $0x6,%eax
80101ba0:	01 d0                	add    %edx,%eax
80101ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba8:	0f b7 10             	movzwl (%eax),%edx
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bca:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bdf:	8b 50 08             	mov    0x8(%eax),%edx
80101be2:	8b 45 08             	mov    0x8(%ebp),%eax
80101be5:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101beb:	8d 50 0c             	lea    0xc(%eax),%edx
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	83 c0 5c             	add    $0x5c,%eax
80101bf4:	83 ec 04             	sub    $0x4,%esp
80101bf7:	6a 34                	push   $0x34
80101bf9:	52                   	push   %edx
80101bfa:	50                   	push   %eax
80101bfb:	e8 29 3a 00 00       	call   80105629 <memmove>
80101c00:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c03:	83 ec 0c             	sub    $0xc,%esp
80101c06:	ff 75 f4             	pushl  -0xc(%ebp)
80101c09:	e8 53 e6 ff ff       	call   80100261 <brelse>
80101c0e:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c22:	66 85 c0             	test   %ax,%ax
80101c25:	75 0d                	jne    80101c34 <ilock+0x114>
      panic("ilock: no type");
80101c27:	83 ec 0c             	sub    $0xc,%esp
80101c2a:	68 e3 94 10 80       	push   $0x801094e3
80101c2f:	e8 d4 e9 ff ff       	call   80100608 <panic>
  }
}
80101c34:	90                   	nop
80101c35:	c9                   	leave  
80101c36:	c3                   	ret    

80101c37 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c37:	f3 0f 1e fb          	endbr32 
80101c3b:	55                   	push   %ebp
80101c3c:	89 e5                	mov    %esp,%ebp
80101c3e:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c45:	74 20                	je     80101c67 <iunlock+0x30>
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	83 c0 0c             	add    $0xc,%eax
80101c4d:	83 ec 0c             	sub    $0xc,%esp
80101c50:	50                   	push   %eax
80101c51:	e8 ae 35 00 00       	call   80105204 <holdingsleep>
80101c56:	83 c4 10             	add    $0x10,%esp
80101c59:	85 c0                	test   %eax,%eax
80101c5b:	74 0a                	je     80101c67 <iunlock+0x30>
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 40 08             	mov    0x8(%eax),%eax
80101c63:	85 c0                	test   %eax,%eax
80101c65:	7f 0d                	jg     80101c74 <iunlock+0x3d>
    panic("iunlock");
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	68 f2 94 10 80       	push   $0x801094f2
80101c6f:	e8 94 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c74:	8b 45 08             	mov    0x8(%ebp),%eax
80101c77:	83 c0 0c             	add    $0xc,%eax
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	50                   	push   %eax
80101c7e:	e8 2f 35 00 00       	call   801051b2 <releasesleep>
80101c83:	83 c4 10             	add    $0x10,%esp
}
80101c86:	90                   	nop
80101c87:	c9                   	leave  
80101c88:	c3                   	ret    

80101c89 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c89:	f3 0f 1e fb          	endbr32 
80101c8d:	55                   	push   %ebp
80101c8e:	89 e5                	mov    %esp,%ebp
80101c90:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	83 c0 0c             	add    $0xc,%eax
80101c99:	83 ec 0c             	sub    $0xc,%esp
80101c9c:	50                   	push   %eax
80101c9d:	e8 a8 34 00 00       	call   8010514a <acquiresleep>
80101ca2:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cab:	85 c0                	test   %eax,%eax
80101cad:	74 6a                	je     80101d19 <iput+0x90>
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cb6:	66 85 c0             	test   %ax,%ax
80101cb9:	75 5e                	jne    80101d19 <iput+0x90>
    acquire(&icache.lock);
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	68 80 2a 11 80       	push   $0x80112a80
80101cc3:	e8 fb 35 00 00       	call   801052c3 <acquire>
80101cc8:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cce:	8b 40 08             	mov    0x8(%eax),%eax
80101cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cd4:	83 ec 0c             	sub    $0xc,%esp
80101cd7:	68 80 2a 11 80       	push   $0x80112a80
80101cdc:	e8 54 36 00 00       	call   80105335 <release>
80101ce1:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ce4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ce8:	75 2f                	jne    80101d19 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cea:	83 ec 0c             	sub    $0xc,%esp
80101ced:	ff 75 08             	pushl  0x8(%ebp)
80101cf0:	e8 b5 01 00 00       	call   80101eaa <itrunc>
80101cf5:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d01:	83 ec 0c             	sub    $0xc,%esp
80101d04:	ff 75 08             	pushl  0x8(%ebp)
80101d07:	e8 2b fc ff ff       	call   80101937 <iupdate>
80101d0c:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d12:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d19:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1c:	83 c0 0c             	add    $0xc,%eax
80101d1f:	83 ec 0c             	sub    $0xc,%esp
80101d22:	50                   	push   %eax
80101d23:	e8 8a 34 00 00       	call   801051b2 <releasesleep>
80101d28:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d2b:	83 ec 0c             	sub    $0xc,%esp
80101d2e:	68 80 2a 11 80       	push   $0x80112a80
80101d33:	e8 8b 35 00 00       	call   801052c3 <acquire>
80101d38:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3e:	8b 40 08             	mov    0x8(%eax),%eax
80101d41:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d4a:	83 ec 0c             	sub    $0xc,%esp
80101d4d:	68 80 2a 11 80       	push   $0x80112a80
80101d52:	e8 de 35 00 00       	call   80105335 <release>
80101d57:	83 c4 10             	add    $0x10,%esp
}
80101d5a:	90                   	nop
80101d5b:	c9                   	leave  
80101d5c:	c3                   	ret    

80101d5d <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d5d:	f3 0f 1e fb          	endbr32 
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d67:	83 ec 0c             	sub    $0xc,%esp
80101d6a:	ff 75 08             	pushl  0x8(%ebp)
80101d6d:	e8 c5 fe ff ff       	call   80101c37 <iunlock>
80101d72:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d75:	83 ec 0c             	sub    $0xc,%esp
80101d78:	ff 75 08             	pushl  0x8(%ebp)
80101d7b:	e8 09 ff ff ff       	call   80101c89 <iput>
80101d80:	83 c4 10             	add    $0x10,%esp
}
80101d83:	90                   	nop
80101d84:	c9                   	leave  
80101d85:	c3                   	ret    

80101d86 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d86:	f3 0f 1e fb          	endbr32 
80101d8a:	55                   	push   %ebp
80101d8b:	89 e5                	mov    %esp,%ebp
80101d8d:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d90:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d94:	77 42                	ja     80101dd8 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d9c:	83 c2 14             	add    $0x14,%edx
80101d9f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101daa:	75 24                	jne    80101dd0 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101dac:	8b 45 08             	mov    0x8(%ebp),%eax
80101daf:	8b 00                	mov    (%eax),%eax
80101db1:	83 ec 0c             	sub    $0xc,%esp
80101db4:	50                   	push   %eax
80101db5:	e8 c7 f7 ff ff       	call   80101581 <balloc>
80101dba:	83 c4 10             	add    $0x10,%esp
80101dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dc6:	8d 4a 14             	lea    0x14(%edx),%ecx
80101dc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcc:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd3:	e9 d0 00 00 00       	jmp    80101ea8 <bmap+0x122>
  }
  bn -= NDIRECT;
80101dd8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ddc:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101de0:	0f 87 b5 00 00 00    	ja     80101e9b <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101de6:	8b 45 08             	mov    0x8(%ebp),%eax
80101de9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101def:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df6:	75 20                	jne    80101e18 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101df8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfb:	8b 00                	mov    (%eax),%eax
80101dfd:	83 ec 0c             	sub    $0xc,%esp
80101e00:	50                   	push   %eax
80101e01:	e8 7b f7 ff ff       	call   80101581 <balloc>
80101e06:	83 c4 10             	add    $0x10,%esp
80101e09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e12:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	8b 00                	mov    (%eax),%eax
80101e1d:	83 ec 08             	sub    $0x8,%esp
80101e20:	ff 75 f4             	pushl  -0xc(%ebp)
80101e23:	50                   	push   %eax
80101e24:	e8 ae e3 ff ff       	call   801001d7 <bread>
80101e29:	83 c4 10             	add    $0x10,%esp
80101e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e32:	83 c0 5c             	add    $0x5c,%eax
80101e35:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e45:	01 d0                	add    %edx,%eax
80101e47:	8b 00                	mov    (%eax),%eax
80101e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e50:	75 36                	jne    80101e88 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	8b 00                	mov    (%eax),%eax
80101e57:	83 ec 0c             	sub    $0xc,%esp
80101e5a:	50                   	push   %eax
80101e5b:	e8 21 f7 ff ff       	call   80101581 <balloc>
80101e60:	83 c4 10             	add    $0x10,%esp
80101e63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e73:	01 c2                	add    %eax,%edx
80101e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e78:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e7a:	83 ec 0c             	sub    $0xc,%esp
80101e7d:	ff 75 f0             	pushl  -0x10(%ebp)
80101e80:	e8 d9 1a 00 00       	call   8010395e <log_write>
80101e85:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e88:	83 ec 0c             	sub    $0xc,%esp
80101e8b:	ff 75 f0             	pushl  -0x10(%ebp)
80101e8e:	e8 ce e3 ff ff       	call   80100261 <brelse>
80101e93:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e99:	eb 0d                	jmp    80101ea8 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e9b:	83 ec 0c             	sub    $0xc,%esp
80101e9e:	68 fa 94 10 80       	push   $0x801094fa
80101ea3:	e8 60 e7 ff ff       	call   80100608 <panic>
}
80101ea8:	c9                   	leave  
80101ea9:	c3                   	ret    

80101eaa <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101eaa:	f3 0f 1e fb          	endbr32 
80101eae:	55                   	push   %ebp
80101eaf:	89 e5                	mov    %esp,%ebp
80101eb1:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ebb:	eb 45                	jmp    80101f02 <itrunc+0x58>
    if(ip->addrs[i]){
80101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ec3:	83 c2 14             	add    $0x14,%edx
80101ec6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101eca:	85 c0                	test   %eax,%eax
80101ecc:	74 30                	je     80101efe <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ed4:	83 c2 14             	add    $0x14,%edx
80101ed7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101edb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ede:	8b 12                	mov    (%edx),%edx
80101ee0:	83 ec 08             	sub    $0x8,%esp
80101ee3:	50                   	push   %eax
80101ee4:	52                   	push   %edx
80101ee5:	e8 e7 f7 ff ff       	call   801016d1 <bfree>
80101eea:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101eed:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef3:	83 c2 14             	add    $0x14,%edx
80101ef6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101efd:	00 
  for(i = 0; i < NDIRECT; i++){
80101efe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f02:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f06:	7e b5                	jle    80101ebd <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	0f 84 aa 00 00 00    	je     80101fc3 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	8b 00                	mov    (%eax),%eax
80101f27:	83 ec 08             	sub    $0x8,%esp
80101f2a:	52                   	push   %edx
80101f2b:	50                   	push   %eax
80101f2c:	e8 a6 e2 ff ff       	call   801001d7 <bread>
80101f31:	83 c4 10             	add    $0x10,%esp
80101f34:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f3a:	83 c0 5c             	add    $0x5c,%eax
80101f3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f47:	eb 3c                	jmp    80101f85 <itrunc+0xdb>
      if(a[j])
80101f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f4c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	8b 00                	mov    (%eax),%eax
80101f5a:	85 c0                	test   %eax,%eax
80101f5c:	74 23                	je     80101f81 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f61:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f6b:	01 d0                	add    %edx,%eax
80101f6d:	8b 00                	mov    (%eax),%eax
80101f6f:	8b 55 08             	mov    0x8(%ebp),%edx
80101f72:	8b 12                	mov    (%edx),%edx
80101f74:	83 ec 08             	sub    $0x8,%esp
80101f77:	50                   	push   %eax
80101f78:	52                   	push   %edx
80101f79:	e8 53 f7 ff ff       	call   801016d1 <bfree>
80101f7e:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f81:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f88:	83 f8 7f             	cmp    $0x7f,%eax
80101f8b:	76 bc                	jbe    80101f49 <itrunc+0x9f>
    }
    brelse(bp);
80101f8d:	83 ec 0c             	sub    $0xc,%esp
80101f90:	ff 75 ec             	pushl  -0x14(%ebp)
80101f93:	e8 c9 e2 ff ff       	call   80100261 <brelse>
80101f98:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fa4:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa7:	8b 12                	mov    (%edx),%edx
80101fa9:	83 ec 08             	sub    $0x8,%esp
80101fac:	50                   	push   %eax
80101fad:	52                   	push   %edx
80101fae:	e8 1e f7 ff ff       	call   801016d1 <bfree>
80101fb3:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb9:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fc0:	00 00 00 
  }

  ip->size = 0;
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fcd:	83 ec 0c             	sub    $0xc,%esp
80101fd0:	ff 75 08             	pushl  0x8(%ebp)
80101fd3:	e8 5f f9 ff ff       	call   80101937 <iupdate>
80101fd8:	83 c4 10             	add    $0x10,%esp
}
80101fdb:	90                   	nop
80101fdc:	c9                   	leave  
80101fdd:	c3                   	ret    

80101fde <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fde:	f3 0f 1e fb          	endbr32 
80101fe2:	55                   	push   %ebp
80101fe3:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe8:	8b 00                	mov    (%eax),%eax
80101fea:	89 c2                	mov    %eax,%edx
80101fec:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fef:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff5:	8b 50 04             	mov    0x4(%eax),%edx
80101ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffb:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80102001:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102005:	8b 45 0c             	mov    0xc(%ebp),%eax
80102008:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010200b:	8b 45 08             	mov    0x8(%ebp),%eax
8010200e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102012:	8b 45 0c             	mov    0xc(%ebp),%eax
80102015:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	8b 50 58             	mov    0x58(%eax),%edx
8010201f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102022:	89 50 10             	mov    %edx,0x10(%eax)
}
80102025:	90                   	nop
80102026:	5d                   	pop    %ebp
80102027:	c3                   	ret    

80102028 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102028:	f3 0f 1e fb          	endbr32 
8010202c:	55                   	push   %ebp
8010202d:	89 e5                	mov    %esp,%ebp
8010202f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102039:	66 83 f8 03          	cmp    $0x3,%ax
8010203d:	75 5c                	jne    8010209b <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	66 85 c0             	test   %ax,%ax
80102049:	78 20                	js     8010206b <readi+0x43>
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102052:	66 83 f8 09          	cmp    $0x9,%ax
80102056:	7f 13                	jg     8010206b <readi+0x43>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	98                   	cwtl   
80102060:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <readi+0x4d>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 0a 01 00 00       	jmp    8010217f <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102084:	8b 55 14             	mov    0x14(%ebp),%edx
80102087:	83 ec 04             	sub    $0x4,%esp
8010208a:	52                   	push   %edx
8010208b:	ff 75 0c             	pushl  0xc(%ebp)
8010208e:	ff 75 08             	pushl  0x8(%ebp)
80102091:	ff d0                	call   *%eax
80102093:	83 c4 10             	add    $0x10,%esp
80102096:	e9 e4 00 00 00       	jmp    8010217f <readi+0x157>
  }

  if(off > ip->size || off + n < off)
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	8b 40 58             	mov    0x58(%eax),%eax
801020a1:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a4:	77 0d                	ja     801020b3 <readi+0x8b>
801020a6:	8b 55 10             	mov    0x10(%ebp),%edx
801020a9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ac:	01 d0                	add    %edx,%eax
801020ae:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b1:	76 0a                	jbe    801020bd <readi+0x95>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 c2 00 00 00       	jmp    8010217f <readi+0x157>
  if(off + n > ip->size)
801020bd:	8b 55 10             	mov    0x10(%ebp),%edx
801020c0:	8b 45 14             	mov    0x14(%ebp),%eax
801020c3:	01 c2                	add    %eax,%edx
801020c5:	8b 45 08             	mov    0x8(%ebp),%eax
801020c8:	8b 40 58             	mov    0x58(%eax),%eax
801020cb:	39 c2                	cmp    %eax,%edx
801020cd:	76 0c                	jbe    801020db <readi+0xb3>
    n = ip->size - off;
801020cf:	8b 45 08             	mov    0x8(%ebp),%eax
801020d2:	8b 40 58             	mov    0x58(%eax),%eax
801020d5:	2b 45 10             	sub    0x10(%ebp),%eax
801020d8:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e2:	e9 89 00 00 00       	jmp    80102170 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e7:	8b 45 10             	mov    0x10(%ebp),%eax
801020ea:	c1 e8 09             	shr    $0x9,%eax
801020ed:	83 ec 08             	sub    $0x8,%esp
801020f0:	50                   	push   %eax
801020f1:	ff 75 08             	pushl  0x8(%ebp)
801020f4:	e8 8d fc ff ff       	call   80101d86 <bmap>
801020f9:	83 c4 10             	add    $0x10,%esp
801020fc:	8b 55 08             	mov    0x8(%ebp),%edx
801020ff:	8b 12                	mov    (%edx),%edx
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	50                   	push   %eax
80102105:	52                   	push   %edx
80102106:	e8 cc e0 ff ff       	call   801001d7 <bread>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	25 ff 01 00 00       	and    $0x1ff,%eax
80102119:	ba 00 02 00 00       	mov    $0x200,%edx
8010211e:	29 c2                	sub    %eax,%edx
80102120:	8b 45 14             	mov    0x14(%ebp),%eax
80102123:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102126:	39 c2                	cmp    %eax,%edx
80102128:	0f 46 c2             	cmovbe %edx,%eax
8010212b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	8d 50 5c             	lea    0x5c(%eax),%edx
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	ff 75 ec             	pushl  -0x14(%ebp)
80102144:	50                   	push   %eax
80102145:	ff 75 0c             	pushl  0xc(%ebp)
80102148:	e8 dc 34 00 00       	call   80105629 <memmove>
8010214d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	ff 75 f0             	pushl  -0x10(%ebp)
80102156:	e8 06 e1 ff ff       	call   80100261 <brelse>
8010215b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010215e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102161:	01 45 f4             	add    %eax,-0xc(%ebp)
80102164:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102167:	01 45 10             	add    %eax,0x10(%ebp)
8010216a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216d:	01 45 0c             	add    %eax,0xc(%ebp)
80102170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102173:	3b 45 14             	cmp    0x14(%ebp),%eax
80102176:	0f 82 6b ff ff ff    	jb     801020e7 <readi+0xbf>
  }
  return n;
8010217c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010217f:	c9                   	leave  
80102180:	c3                   	ret    

80102181 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102181:	f3 0f 1e fb          	endbr32 
80102185:	55                   	push   %ebp
80102186:	89 e5                	mov    %esp,%ebp
80102188:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102192:	66 83 f8 03          	cmp    $0x3,%ax
80102196:	75 5c                	jne    801021f4 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
8010219b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010219f:	66 85 c0             	test   %ax,%ax
801021a2:	78 20                	js     801021c4 <writei+0x43>
801021a4:	8b 45 08             	mov    0x8(%ebp),%eax
801021a7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021ab:	66 83 f8 09          	cmp    $0x9,%ax
801021af:	7f 13                	jg     801021c4 <writei+0x43>
801021b1:	8b 45 08             	mov    0x8(%ebp),%eax
801021b4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021b8:	98                   	cwtl   
801021b9:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021c0:	85 c0                	test   %eax,%eax
801021c2:	75 0a                	jne    801021ce <writei+0x4d>
      return -1;
801021c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c9:	e9 3b 01 00 00       	jmp    80102309 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021ce:	8b 45 08             	mov    0x8(%ebp),%eax
801021d1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021d5:	98                   	cwtl   
801021d6:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021dd:	8b 55 14             	mov    0x14(%ebp),%edx
801021e0:	83 ec 04             	sub    $0x4,%esp
801021e3:	52                   	push   %edx
801021e4:	ff 75 0c             	pushl  0xc(%ebp)
801021e7:	ff 75 08             	pushl  0x8(%ebp)
801021ea:	ff d0                	call   *%eax
801021ec:	83 c4 10             	add    $0x10,%esp
801021ef:	e9 15 01 00 00       	jmp    80102309 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021f4:	8b 45 08             	mov    0x8(%ebp),%eax
801021f7:	8b 40 58             	mov    0x58(%eax),%eax
801021fa:	39 45 10             	cmp    %eax,0x10(%ebp)
801021fd:	77 0d                	ja     8010220c <writei+0x8b>
801021ff:	8b 55 10             	mov    0x10(%ebp),%edx
80102202:	8b 45 14             	mov    0x14(%ebp),%eax
80102205:	01 d0                	add    %edx,%eax
80102207:	39 45 10             	cmp    %eax,0x10(%ebp)
8010220a:	76 0a                	jbe    80102216 <writei+0x95>
    return -1;
8010220c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102211:	e9 f3 00 00 00       	jmp    80102309 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102216:	8b 55 10             	mov    0x10(%ebp),%edx
80102219:	8b 45 14             	mov    0x14(%ebp),%eax
8010221c:	01 d0                	add    %edx,%eax
8010221e:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102223:	76 0a                	jbe    8010222f <writei+0xae>
    return -1;
80102225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010222a:	e9 da 00 00 00       	jmp    80102309 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010222f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102236:	e9 97 00 00 00       	jmp    801022d2 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010223b:	8b 45 10             	mov    0x10(%ebp),%eax
8010223e:	c1 e8 09             	shr    $0x9,%eax
80102241:	83 ec 08             	sub    $0x8,%esp
80102244:	50                   	push   %eax
80102245:	ff 75 08             	pushl  0x8(%ebp)
80102248:	e8 39 fb ff ff       	call   80101d86 <bmap>
8010224d:	83 c4 10             	add    $0x10,%esp
80102250:	8b 55 08             	mov    0x8(%ebp),%edx
80102253:	8b 12                	mov    (%edx),%edx
80102255:	83 ec 08             	sub    $0x8,%esp
80102258:	50                   	push   %eax
80102259:	52                   	push   %edx
8010225a:	e8 78 df ff ff       	call   801001d7 <bread>
8010225f:	83 c4 10             	add    $0x10,%esp
80102262:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102265:	8b 45 10             	mov    0x10(%ebp),%eax
80102268:	25 ff 01 00 00       	and    $0x1ff,%eax
8010226d:	ba 00 02 00 00       	mov    $0x200,%edx
80102272:	29 c2                	sub    %eax,%edx
80102274:	8b 45 14             	mov    0x14(%ebp),%eax
80102277:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010227a:	39 c2                	cmp    %eax,%edx
8010227c:	0f 46 c2             	cmovbe %edx,%eax
8010227f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102285:	8d 50 5c             	lea    0x5c(%eax),%edx
80102288:	8b 45 10             	mov    0x10(%ebp),%eax
8010228b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102290:	01 d0                	add    %edx,%eax
80102292:	83 ec 04             	sub    $0x4,%esp
80102295:	ff 75 ec             	pushl  -0x14(%ebp)
80102298:	ff 75 0c             	pushl  0xc(%ebp)
8010229b:	50                   	push   %eax
8010229c:	e8 88 33 00 00       	call   80105629 <memmove>
801022a1:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022a4:	83 ec 0c             	sub    $0xc,%esp
801022a7:	ff 75 f0             	pushl  -0x10(%ebp)
801022aa:	e8 af 16 00 00       	call   8010395e <log_write>
801022af:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022b2:	83 ec 0c             	sub    $0xc,%esp
801022b5:	ff 75 f0             	pushl  -0x10(%ebp)
801022b8:	e8 a4 df ff ff       	call   80100261 <brelse>
801022bd:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c3:	01 45 f4             	add    %eax,-0xc(%ebp)
801022c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c9:	01 45 10             	add    %eax,0x10(%ebp)
801022cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022cf:	01 45 0c             	add    %eax,0xc(%ebp)
801022d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d5:	3b 45 14             	cmp    0x14(%ebp),%eax
801022d8:	0f 82 5d ff ff ff    	jb     8010223b <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022de:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022e2:	74 22                	je     80102306 <writei+0x185>
801022e4:	8b 45 08             	mov    0x8(%ebp),%eax
801022e7:	8b 40 58             	mov    0x58(%eax),%eax
801022ea:	39 45 10             	cmp    %eax,0x10(%ebp)
801022ed:	76 17                	jbe    80102306 <writei+0x185>
    ip->size = off;
801022ef:	8b 45 08             	mov    0x8(%ebp),%eax
801022f2:	8b 55 10             	mov    0x10(%ebp),%edx
801022f5:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022f8:	83 ec 0c             	sub    $0xc,%esp
801022fb:	ff 75 08             	pushl  0x8(%ebp)
801022fe:	e8 34 f6 ff ff       	call   80101937 <iupdate>
80102303:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102306:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102309:	c9                   	leave  
8010230a:	c3                   	ret    

8010230b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010230b:	f3 0f 1e fb          	endbr32 
8010230f:	55                   	push   %ebp
80102310:	89 e5                	mov    %esp,%ebp
80102312:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102315:	83 ec 04             	sub    $0x4,%esp
80102318:	6a 0e                	push   $0xe
8010231a:	ff 75 0c             	pushl  0xc(%ebp)
8010231d:	ff 75 08             	pushl  0x8(%ebp)
80102320:	e8 a2 33 00 00       	call   801056c7 <strncmp>
80102325:	83 c4 10             	add    $0x10,%esp
}
80102328:	c9                   	leave  
80102329:	c3                   	ret    

8010232a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010232a:	f3 0f 1e fb          	endbr32 
8010232e:	55                   	push   %ebp
8010232f:	89 e5                	mov    %esp,%ebp
80102331:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102334:	8b 45 08             	mov    0x8(%ebp),%eax
80102337:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010233b:	66 83 f8 01          	cmp    $0x1,%ax
8010233f:	74 0d                	je     8010234e <dirlookup+0x24>
    panic("dirlookup not DIR");
80102341:	83 ec 0c             	sub    $0xc,%esp
80102344:	68 0d 95 10 80       	push   $0x8010950d
80102349:	e8 ba e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010234e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102355:	eb 7b                	jmp    801023d2 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102357:	6a 10                	push   $0x10
80102359:	ff 75 f4             	pushl  -0xc(%ebp)
8010235c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010235f:	50                   	push   %eax
80102360:	ff 75 08             	pushl  0x8(%ebp)
80102363:	e8 c0 fc ff ff       	call   80102028 <readi>
80102368:	83 c4 10             	add    $0x10,%esp
8010236b:	83 f8 10             	cmp    $0x10,%eax
8010236e:	74 0d                	je     8010237d <dirlookup+0x53>
      panic("dirlookup read");
80102370:	83 ec 0c             	sub    $0xc,%esp
80102373:	68 1f 95 10 80       	push   $0x8010951f
80102378:	e8 8b e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010237d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102381:	66 85 c0             	test   %ax,%ax
80102384:	74 47                	je     801023cd <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102386:	83 ec 08             	sub    $0x8,%esp
80102389:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238c:	83 c0 02             	add    $0x2,%eax
8010238f:	50                   	push   %eax
80102390:	ff 75 0c             	pushl  0xc(%ebp)
80102393:	e8 73 ff ff ff       	call   8010230b <namecmp>
80102398:	83 c4 10             	add    $0x10,%esp
8010239b:	85 c0                	test   %eax,%eax
8010239d:	75 2f                	jne    801023ce <dirlookup+0xa4>
      // entry matches path element
      if(poff)
8010239f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023a3:	74 08                	je     801023ad <dirlookup+0x83>
        *poff = off;
801023a5:	8b 45 10             	mov    0x10(%ebp),%eax
801023a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023ab:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023ad:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b1:	0f b7 c0             	movzwl %ax,%eax
801023b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	8b 00                	mov    (%eax),%eax
801023bc:	83 ec 08             	sub    $0x8,%esp
801023bf:	ff 75 f0             	pushl  -0x10(%ebp)
801023c2:	50                   	push   %eax
801023c3:	e8 34 f6 ff ff       	call   801019fc <iget>
801023c8:	83 c4 10             	add    $0x10,%esp
801023cb:	eb 19                	jmp    801023e6 <dirlookup+0xbc>
      continue;
801023cd:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ce:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023d2:	8b 45 08             	mov    0x8(%ebp),%eax
801023d5:	8b 40 58             	mov    0x58(%eax),%eax
801023d8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023db:	0f 82 76 ff ff ff    	jb     80102357 <dirlookup+0x2d>
    }
  }

  return 0;
801023e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023e6:	c9                   	leave  
801023e7:	c3                   	ret    

801023e8 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023e8:	f3 0f 1e fb          	endbr32 
801023ec:	55                   	push   %ebp
801023ed:	89 e5                	mov    %esp,%ebp
801023ef:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023f2:	83 ec 04             	sub    $0x4,%esp
801023f5:	6a 00                	push   $0x0
801023f7:	ff 75 0c             	pushl  0xc(%ebp)
801023fa:	ff 75 08             	pushl  0x8(%ebp)
801023fd:	e8 28 ff ff ff       	call   8010232a <dirlookup>
80102402:	83 c4 10             	add    $0x10,%esp
80102405:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102408:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010240c:	74 18                	je     80102426 <dirlink+0x3e>
    iput(ip);
8010240e:	83 ec 0c             	sub    $0xc,%esp
80102411:	ff 75 f0             	pushl  -0x10(%ebp)
80102414:	e8 70 f8 ff ff       	call   80101c89 <iput>
80102419:	83 c4 10             	add    $0x10,%esp
    return -1;
8010241c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102421:	e9 9c 00 00 00       	jmp    801024c2 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102426:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010242d:	eb 39                	jmp    80102468 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010242f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102432:	6a 10                	push   $0x10
80102434:	50                   	push   %eax
80102435:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102438:	50                   	push   %eax
80102439:	ff 75 08             	pushl  0x8(%ebp)
8010243c:	e8 e7 fb ff ff       	call   80102028 <readi>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	83 f8 10             	cmp    $0x10,%eax
80102447:	74 0d                	je     80102456 <dirlink+0x6e>
      panic("dirlink read");
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	68 2e 95 10 80       	push   $0x8010952e
80102451:	e8 b2 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102456:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010245a:	66 85 c0             	test   %ax,%ax
8010245d:	74 18                	je     80102477 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010245f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102462:	83 c0 10             	add    $0x10,%eax
80102465:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102468:	8b 45 08             	mov    0x8(%ebp),%eax
8010246b:	8b 50 58             	mov    0x58(%eax),%edx
8010246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102471:	39 c2                	cmp    %eax,%edx
80102473:	77 ba                	ja     8010242f <dirlink+0x47>
80102475:	eb 01                	jmp    80102478 <dirlink+0x90>
      break;
80102477:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102478:	83 ec 04             	sub    $0x4,%esp
8010247b:	6a 0e                	push   $0xe
8010247d:	ff 75 0c             	pushl  0xc(%ebp)
80102480:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102483:	83 c0 02             	add    $0x2,%eax
80102486:	50                   	push   %eax
80102487:	e8 95 32 00 00       	call   80105721 <strncpy>
8010248c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010248f:	8b 45 10             	mov    0x10(%ebp),%eax
80102492:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102499:	6a 10                	push   $0x10
8010249b:	50                   	push   %eax
8010249c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010249f:	50                   	push   %eax
801024a0:	ff 75 08             	pushl  0x8(%ebp)
801024a3:	e8 d9 fc ff ff       	call   80102181 <writei>
801024a8:	83 c4 10             	add    $0x10,%esp
801024ab:	83 f8 10             	cmp    $0x10,%eax
801024ae:	74 0d                	je     801024bd <dirlink+0xd5>
    panic("dirlink");
801024b0:	83 ec 0c             	sub    $0xc,%esp
801024b3:	68 3b 95 10 80       	push   $0x8010953b
801024b8:	e8 4b e1 ff ff       	call   80100608 <panic>

  return 0;
801024bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32 
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024ce:	eb 04                	jmp    801024d4 <skipelem+0x10>
    path++;
801024d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024d4:	8b 45 08             	mov    0x8(%ebp),%eax
801024d7:	0f b6 00             	movzbl (%eax),%eax
801024da:	3c 2f                	cmp    $0x2f,%al
801024dc:	74 f2                	je     801024d0 <skipelem+0xc>
  if(*path == 0)
801024de:	8b 45 08             	mov    0x8(%ebp),%eax
801024e1:	0f b6 00             	movzbl (%eax),%eax
801024e4:	84 c0                	test   %al,%al
801024e6:	75 07                	jne    801024ef <skipelem+0x2b>
    return 0;
801024e8:	b8 00 00 00 00       	mov    $0x0,%eax
801024ed:	eb 77                	jmp    80102566 <skipelem+0xa2>
  s = path;
801024ef:	8b 45 08             	mov    0x8(%ebp),%eax
801024f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024f5:	eb 04                	jmp    801024fb <skipelem+0x37>
    path++;
801024f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024fb:	8b 45 08             	mov    0x8(%ebp),%eax
801024fe:	0f b6 00             	movzbl (%eax),%eax
80102501:	3c 2f                	cmp    $0x2f,%al
80102503:	74 0a                	je     8010250f <skipelem+0x4b>
80102505:	8b 45 08             	mov    0x8(%ebp),%eax
80102508:	0f b6 00             	movzbl (%eax),%eax
8010250b:	84 c0                	test   %al,%al
8010250d:	75 e8                	jne    801024f7 <skipelem+0x33>
  len = path - s;
8010250f:	8b 45 08             	mov    0x8(%ebp),%eax
80102512:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102515:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102518:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010251c:	7e 15                	jle    80102533 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010251e:	83 ec 04             	sub    $0x4,%esp
80102521:	6a 0e                	push   $0xe
80102523:	ff 75 f4             	pushl  -0xc(%ebp)
80102526:	ff 75 0c             	pushl  0xc(%ebp)
80102529:	e8 fb 30 00 00       	call   80105629 <memmove>
8010252e:	83 c4 10             	add    $0x10,%esp
80102531:	eb 26                	jmp    80102559 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102533:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102536:	83 ec 04             	sub    $0x4,%esp
80102539:	50                   	push   %eax
8010253a:	ff 75 f4             	pushl  -0xc(%ebp)
8010253d:	ff 75 0c             	pushl  0xc(%ebp)
80102540:	e8 e4 30 00 00       	call   80105629 <memmove>
80102545:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102548:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010254b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010254e:	01 d0                	add    %edx,%eax
80102550:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102553:	eb 04                	jmp    80102559 <skipelem+0x95>
    path++;
80102555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102559:	8b 45 08             	mov    0x8(%ebp),%eax
8010255c:	0f b6 00             	movzbl (%eax),%eax
8010255f:	3c 2f                	cmp    $0x2f,%al
80102561:	74 f2                	je     80102555 <skipelem+0x91>
  return path;
80102563:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102566:	c9                   	leave  
80102567:	c3                   	ret    

80102568 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102568:	f3 0f 1e fb          	endbr32 
8010256c:	55                   	push   %ebp
8010256d:	89 e5                	mov    %esp,%ebp
8010256f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102572:	8b 45 08             	mov    0x8(%ebp),%eax
80102575:	0f b6 00             	movzbl (%eax),%eax
80102578:	3c 2f                	cmp    $0x2f,%al
8010257a:	75 17                	jne    80102593 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010257c:	83 ec 08             	sub    $0x8,%esp
8010257f:	6a 01                	push   $0x1
80102581:	6a 01                	push   $0x1
80102583:	e8 74 f4 ff ff       	call   801019fc <iget>
80102588:	83 c4 10             	add    $0x10,%esp
8010258b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010258e:	e9 ba 00 00 00       	jmp    8010264d <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
80102593:	e8 3c 1f 00 00       	call   801044d4 <myproc>
80102598:	8b 40 68             	mov    0x68(%eax),%eax
8010259b:	83 ec 0c             	sub    $0xc,%esp
8010259e:	50                   	push   %eax
8010259f:	e8 3e f5 ff ff       	call   80101ae2 <idup>
801025a4:	83 c4 10             	add    $0x10,%esp
801025a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025aa:	e9 9e 00 00 00       	jmp    8010264d <namex+0xe5>
    ilock(ip);
801025af:	83 ec 0c             	sub    $0xc,%esp
801025b2:	ff 75 f4             	pushl  -0xc(%ebp)
801025b5:	e8 66 f5 ff ff       	call   80101b20 <ilock>
801025ba:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025c4:	66 83 f8 01          	cmp    $0x1,%ax
801025c8:	74 18                	je     801025e2 <namex+0x7a>
      iunlockput(ip);
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	ff 75 f4             	pushl  -0xc(%ebp)
801025d0:	e8 88 f7 ff ff       	call   80101d5d <iunlockput>
801025d5:	83 c4 10             	add    $0x10,%esp
      return 0;
801025d8:	b8 00 00 00 00       	mov    $0x0,%eax
801025dd:	e9 a7 00 00 00       	jmp    80102689 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025e6:	74 20                	je     80102608 <namex+0xa0>
801025e8:	8b 45 08             	mov    0x8(%ebp),%eax
801025eb:	0f b6 00             	movzbl (%eax),%eax
801025ee:	84 c0                	test   %al,%al
801025f0:	75 16                	jne    80102608 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025f2:	83 ec 0c             	sub    $0xc,%esp
801025f5:	ff 75 f4             	pushl  -0xc(%ebp)
801025f8:	e8 3a f6 ff ff       	call   80101c37 <iunlock>
801025fd:	83 c4 10             	add    $0x10,%esp
      return ip;
80102600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102603:	e9 81 00 00 00       	jmp    80102689 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102608:	83 ec 04             	sub    $0x4,%esp
8010260b:	6a 00                	push   $0x0
8010260d:	ff 75 10             	pushl  0x10(%ebp)
80102610:	ff 75 f4             	pushl  -0xc(%ebp)
80102613:	e8 12 fd ff ff       	call   8010232a <dirlookup>
80102618:	83 c4 10             	add    $0x10,%esp
8010261b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010261e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102622:	75 15                	jne    80102639 <namex+0xd1>
      iunlockput(ip);
80102624:	83 ec 0c             	sub    $0xc,%esp
80102627:	ff 75 f4             	pushl  -0xc(%ebp)
8010262a:	e8 2e f7 ff ff       	call   80101d5d <iunlockput>
8010262f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102632:	b8 00 00 00 00       	mov    $0x0,%eax
80102637:	eb 50                	jmp    80102689 <namex+0x121>
    }
    iunlockput(ip);
80102639:	83 ec 0c             	sub    $0xc,%esp
8010263c:	ff 75 f4             	pushl  -0xc(%ebp)
8010263f:	e8 19 f7 ff ff       	call   80101d5d <iunlockput>
80102644:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102647:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010264a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010264d:	83 ec 08             	sub    $0x8,%esp
80102650:	ff 75 10             	pushl  0x10(%ebp)
80102653:	ff 75 08             	pushl  0x8(%ebp)
80102656:	e8 69 fe ff ff       	call   801024c4 <skipelem>
8010265b:	83 c4 10             	add    $0x10,%esp
8010265e:	89 45 08             	mov    %eax,0x8(%ebp)
80102661:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102665:	0f 85 44 ff ff ff    	jne    801025af <namex+0x47>
  }
  if(nameiparent){
8010266b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010266f:	74 15                	je     80102686 <namex+0x11e>
    iput(ip);
80102671:	83 ec 0c             	sub    $0xc,%esp
80102674:	ff 75 f4             	pushl  -0xc(%ebp)
80102677:	e8 0d f6 ff ff       	call   80101c89 <iput>
8010267c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010267f:	b8 00 00 00 00       	mov    $0x0,%eax
80102684:	eb 03                	jmp    80102689 <namex+0x121>
  }
  return ip;
80102686:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102689:	c9                   	leave  
8010268a:	c3                   	ret    

8010268b <namei>:

struct inode*
namei(char *path)
{
8010268b:	f3 0f 1e fb          	endbr32 
8010268f:	55                   	push   %ebp
80102690:	89 e5                	mov    %esp,%ebp
80102692:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102695:	83 ec 04             	sub    $0x4,%esp
80102698:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010269b:	50                   	push   %eax
8010269c:	6a 00                	push   $0x0
8010269e:	ff 75 08             	pushl  0x8(%ebp)
801026a1:	e8 c2 fe ff ff       	call   80102568 <namex>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	c9                   	leave  
801026aa:	c3                   	ret    

801026ab <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026ab:	f3 0f 1e fb          	endbr32 
801026af:	55                   	push   %ebp
801026b0:	89 e5                	mov    %esp,%ebp
801026b2:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026b5:	83 ec 04             	sub    $0x4,%esp
801026b8:	ff 75 0c             	pushl  0xc(%ebp)
801026bb:	6a 01                	push   $0x1
801026bd:	ff 75 08             	pushl  0x8(%ebp)
801026c0:	e8 a3 fe ff ff       	call   80102568 <namex>
801026c5:	83 c4 10             	add    $0x10,%esp
}
801026c8:	c9                   	leave  
801026c9:	c3                   	ret    

801026ca <inb>:
{
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 14             	sub    $0x14,%esp
801026d0:	8b 45 08             	mov    0x8(%ebp),%eax
801026d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026db:	89 c2                	mov    %eax,%edx
801026dd:	ec                   	in     (%dx),%al
801026de:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026e1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026e5:	c9                   	leave  
801026e6:	c3                   	ret    

801026e7 <insl>:
{
801026e7:	55                   	push   %ebp
801026e8:	89 e5                	mov    %esp,%ebp
801026ea:	57                   	push   %edi
801026eb:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026ec:	8b 55 08             	mov    0x8(%ebp),%edx
801026ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026f2:	8b 45 10             	mov    0x10(%ebp),%eax
801026f5:	89 cb                	mov    %ecx,%ebx
801026f7:	89 df                	mov    %ebx,%edi
801026f9:	89 c1                	mov    %eax,%ecx
801026fb:	fc                   	cld    
801026fc:	f3 6d                	rep insl (%dx),%es:(%edi)
801026fe:	89 c8                	mov    %ecx,%eax
80102700:	89 fb                	mov    %edi,%ebx
80102702:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102705:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102708:	90                   	nop
80102709:	5b                   	pop    %ebx
8010270a:	5f                   	pop    %edi
8010270b:	5d                   	pop    %ebp
8010270c:	c3                   	ret    

8010270d <outb>:
{
8010270d:	55                   	push   %ebp
8010270e:	89 e5                	mov    %esp,%ebp
80102710:	83 ec 08             	sub    $0x8,%esp
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	8b 55 0c             	mov    0xc(%ebp),%edx
80102719:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010271d:	89 d0                	mov    %edx,%eax
8010271f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102722:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102726:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010272a:	ee                   	out    %al,(%dx)
}
8010272b:	90                   	nop
8010272c:	c9                   	leave  
8010272d:	c3                   	ret    

8010272e <outsl>:
{
8010272e:	55                   	push   %ebp
8010272f:	89 e5                	mov    %esp,%ebp
80102731:	56                   	push   %esi
80102732:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102733:	8b 55 08             	mov    0x8(%ebp),%edx
80102736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102739:	8b 45 10             	mov    0x10(%ebp),%eax
8010273c:	89 cb                	mov    %ecx,%ebx
8010273e:	89 de                	mov    %ebx,%esi
80102740:	89 c1                	mov    %eax,%ecx
80102742:	fc                   	cld    
80102743:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102745:	89 c8                	mov    %ecx,%eax
80102747:	89 f3                	mov    %esi,%ebx
80102749:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010274c:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010274f:	90                   	nop
80102750:	5b                   	pop    %ebx
80102751:	5e                   	pop    %esi
80102752:	5d                   	pop    %ebp
80102753:	c3                   	ret    

80102754 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102754:	f3 0f 1e fb          	endbr32 
80102758:	55                   	push   %ebp
80102759:	89 e5                	mov    %esp,%ebp
8010275b:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010275e:	90                   	nop
8010275f:	68 f7 01 00 00       	push   $0x1f7
80102764:	e8 61 ff ff ff       	call   801026ca <inb>
80102769:	83 c4 04             	add    $0x4,%esp
8010276c:	0f b6 c0             	movzbl %al,%eax
8010276f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102772:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102775:	25 c0 00 00 00       	and    $0xc0,%eax
8010277a:	83 f8 40             	cmp    $0x40,%eax
8010277d:	75 e0                	jne    8010275f <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010277f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102783:	74 11                	je     80102796 <idewait+0x42>
80102785:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102788:	83 e0 21             	and    $0x21,%eax
8010278b:	85 c0                	test   %eax,%eax
8010278d:	74 07                	je     80102796 <idewait+0x42>
    return -1;
8010278f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102794:	eb 05                	jmp    8010279b <idewait+0x47>
  return 0;
80102796:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010279b:	c9                   	leave  
8010279c:	c3                   	ret    

8010279d <ideinit>:

void
ideinit(void)
{
8010279d:	f3 0f 1e fb          	endbr32 
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027a7:	83 ec 08             	sub    $0x8,%esp
801027aa:	68 43 95 10 80       	push   $0x80109543
801027af:	68 00 c6 10 80       	push   $0x8010c600
801027b4:	e8 e4 2a 00 00       	call   8010529d <initlock>
801027b9:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027bc:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027c1:	83 e8 01             	sub    $0x1,%eax
801027c4:	83 ec 08             	sub    $0x8,%esp
801027c7:	50                   	push   %eax
801027c8:	6a 0e                	push   $0xe
801027ca:	e8 bb 04 00 00       	call   80102c8a <ioapicenable>
801027cf:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	6a 00                	push   $0x0
801027d7:	e8 78 ff ff ff       	call   80102754 <idewait>
801027dc:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027df:	83 ec 08             	sub    $0x8,%esp
801027e2:	68 f0 00 00 00       	push   $0xf0
801027e7:	68 f6 01 00 00       	push   $0x1f6
801027ec:	e8 1c ff ff ff       	call   8010270d <outb>
801027f1:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027fb:	eb 24                	jmp    80102821 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027fd:	83 ec 0c             	sub    $0xc,%esp
80102800:	68 f7 01 00 00       	push   $0x1f7
80102805:	e8 c0 fe ff ff       	call   801026ca <inb>
8010280a:	83 c4 10             	add    $0x10,%esp
8010280d:	84 c0                	test   %al,%al
8010280f:	74 0c                	je     8010281d <ideinit+0x80>
      havedisk1 = 1;
80102811:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102818:	00 00 00 
      break;
8010281b:	eb 0d                	jmp    8010282a <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010281d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102821:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102828:	7e d3                	jle    801027fd <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010282a:	83 ec 08             	sub    $0x8,%esp
8010282d:	68 e0 00 00 00       	push   $0xe0
80102832:	68 f6 01 00 00       	push   $0x1f6
80102837:	e8 d1 fe ff ff       	call   8010270d <outb>
8010283c:	83 c4 10             	add    $0x10,%esp
}
8010283f:	90                   	nop
80102840:	c9                   	leave  
80102841:	c3                   	ret    

80102842 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102842:	f3 0f 1e fb          	endbr32 
80102846:	55                   	push   %ebp
80102847:	89 e5                	mov    %esp,%ebp
80102849:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010284c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102850:	75 0d                	jne    8010285f <idestart+0x1d>
    panic("idestart");
80102852:	83 ec 0c             	sub    $0xc,%esp
80102855:	68 47 95 10 80       	push   $0x80109547
8010285a:	e8 a9 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
8010285f:	8b 45 08             	mov    0x8(%ebp),%eax
80102862:	8b 40 08             	mov    0x8(%eax),%eax
80102865:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010286a:	76 0d                	jbe    80102879 <idestart+0x37>
    panic("incorrect blockno");
8010286c:	83 ec 0c             	sub    $0xc,%esp
8010286f:	68 50 95 10 80       	push   $0x80109550
80102874:	e8 8f dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102879:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102880:	8b 45 08             	mov    0x8(%ebp),%eax
80102883:	8b 50 08             	mov    0x8(%eax),%edx
80102886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102889:	0f af c2             	imul   %edx,%eax
8010288c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010288f:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102893:	75 07                	jne    8010289c <idestart+0x5a>
80102895:	b8 20 00 00 00       	mov    $0x20,%eax
8010289a:	eb 05                	jmp    801028a1 <idestart+0x5f>
8010289c:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028a4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028a8:	75 07                	jne    801028b1 <idestart+0x6f>
801028aa:	b8 30 00 00 00       	mov    $0x30,%eax
801028af:	eb 05                	jmp    801028b6 <idestart+0x74>
801028b1:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028b6:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028b9:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028bd:	7e 0d                	jle    801028cc <idestart+0x8a>
801028bf:	83 ec 0c             	sub    $0xc,%esp
801028c2:	68 47 95 10 80       	push   $0x80109547
801028c7:	e8 3c dd ff ff       	call   80100608 <panic>

  idewait(0);
801028cc:	83 ec 0c             	sub    $0xc,%esp
801028cf:	6a 00                	push   $0x0
801028d1:	e8 7e fe ff ff       	call   80102754 <idewait>
801028d6:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028d9:	83 ec 08             	sub    $0x8,%esp
801028dc:	6a 00                	push   $0x0
801028de:	68 f6 03 00 00       	push   $0x3f6
801028e3:	e8 25 fe ff ff       	call   8010270d <outb>
801028e8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ee:	0f b6 c0             	movzbl %al,%eax
801028f1:	83 ec 08             	sub    $0x8,%esp
801028f4:	50                   	push   %eax
801028f5:	68 f2 01 00 00       	push   $0x1f2
801028fa:	e8 0e fe ff ff       	call   8010270d <outb>
801028ff:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102905:	0f b6 c0             	movzbl %al,%eax
80102908:	83 ec 08             	sub    $0x8,%esp
8010290b:	50                   	push   %eax
8010290c:	68 f3 01 00 00       	push   $0x1f3
80102911:	e8 f7 fd ff ff       	call   8010270d <outb>
80102916:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010291c:	c1 f8 08             	sar    $0x8,%eax
8010291f:	0f b6 c0             	movzbl %al,%eax
80102922:	83 ec 08             	sub    $0x8,%esp
80102925:	50                   	push   %eax
80102926:	68 f4 01 00 00       	push   $0x1f4
8010292b:	e8 dd fd ff ff       	call   8010270d <outb>
80102930:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102936:	c1 f8 10             	sar    $0x10,%eax
80102939:	0f b6 c0             	movzbl %al,%eax
8010293c:	83 ec 08             	sub    $0x8,%esp
8010293f:	50                   	push   %eax
80102940:	68 f5 01 00 00       	push   $0x1f5
80102945:	e8 c3 fd ff ff       	call   8010270d <outb>
8010294a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010294d:	8b 45 08             	mov    0x8(%ebp),%eax
80102950:	8b 40 04             	mov    0x4(%eax),%eax
80102953:	c1 e0 04             	shl    $0x4,%eax
80102956:	83 e0 10             	and    $0x10,%eax
80102959:	89 c2                	mov    %eax,%edx
8010295b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010295e:	c1 f8 18             	sar    $0x18,%eax
80102961:	83 e0 0f             	and    $0xf,%eax
80102964:	09 d0                	or     %edx,%eax
80102966:	83 c8 e0             	or     $0xffffffe0,%eax
80102969:	0f b6 c0             	movzbl %al,%eax
8010296c:	83 ec 08             	sub    $0x8,%esp
8010296f:	50                   	push   %eax
80102970:	68 f6 01 00 00       	push   $0x1f6
80102975:	e8 93 fd ff ff       	call   8010270d <outb>
8010297a:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010297d:	8b 45 08             	mov    0x8(%ebp),%eax
80102980:	8b 00                	mov    (%eax),%eax
80102982:	83 e0 04             	and    $0x4,%eax
80102985:	85 c0                	test   %eax,%eax
80102987:	74 35                	je     801029be <idestart+0x17c>
    outb(0x1f7, write_cmd);
80102989:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010298c:	0f b6 c0             	movzbl %al,%eax
8010298f:	83 ec 08             	sub    $0x8,%esp
80102992:	50                   	push   %eax
80102993:	68 f7 01 00 00       	push   $0x1f7
80102998:	e8 70 fd ff ff       	call   8010270d <outb>
8010299d:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029a0:	8b 45 08             	mov    0x8(%ebp),%eax
801029a3:	83 c0 5c             	add    $0x5c,%eax
801029a6:	83 ec 04             	sub    $0x4,%esp
801029a9:	68 80 00 00 00       	push   $0x80
801029ae:	50                   	push   %eax
801029af:	68 f0 01 00 00       	push   $0x1f0
801029b4:	e8 75 fd ff ff       	call   8010272e <outsl>
801029b9:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029bc:	eb 17                	jmp    801029d5 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029c1:	0f b6 c0             	movzbl %al,%eax
801029c4:	83 ec 08             	sub    $0x8,%esp
801029c7:	50                   	push   %eax
801029c8:	68 f7 01 00 00       	push   $0x1f7
801029cd:	e8 3b fd ff ff       	call   8010270d <outb>
801029d2:	83 c4 10             	add    $0x10,%esp
}
801029d5:	90                   	nop
801029d6:	c9                   	leave  
801029d7:	c3                   	ret    

801029d8 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029d8:	f3 0f 1e fb          	endbr32 
801029dc:	55                   	push   %ebp
801029dd:	89 e5                	mov    %esp,%ebp
801029df:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029e2:	83 ec 0c             	sub    $0xc,%esp
801029e5:	68 00 c6 10 80       	push   $0x8010c600
801029ea:	e8 d4 28 00 00       	call   801052c3 <acquire>
801029ef:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029f2:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029fe:	75 15                	jne    80102a15 <ideintr+0x3d>
    release(&idelock);
80102a00:	83 ec 0c             	sub    $0xc,%esp
80102a03:	68 00 c6 10 80       	push   $0x8010c600
80102a08:	e8 28 29 00 00       	call   80105335 <release>
80102a0d:	83 c4 10             	add    $0x10,%esp
    return;
80102a10:	e9 9a 00 00 00       	jmp    80102aaf <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a18:	8b 40 58             	mov    0x58(%eax),%eax
80102a1b:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a23:	8b 00                	mov    (%eax),%eax
80102a25:	83 e0 04             	and    $0x4,%eax
80102a28:	85 c0                	test   %eax,%eax
80102a2a:	75 2d                	jne    80102a59 <ideintr+0x81>
80102a2c:	83 ec 0c             	sub    $0xc,%esp
80102a2f:	6a 01                	push   $0x1
80102a31:	e8 1e fd ff ff       	call   80102754 <idewait>
80102a36:	83 c4 10             	add    $0x10,%esp
80102a39:	85 c0                	test   %eax,%eax
80102a3b:	78 1c                	js     80102a59 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a40:	83 c0 5c             	add    $0x5c,%eax
80102a43:	83 ec 04             	sub    $0x4,%esp
80102a46:	68 80 00 00 00       	push   $0x80
80102a4b:	50                   	push   %eax
80102a4c:	68 f0 01 00 00       	push   $0x1f0
80102a51:	e8 91 fc ff ff       	call   801026e7 <insl>
80102a56:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5c:	8b 00                	mov    (%eax),%eax
80102a5e:	83 c8 02             	or     $0x2,%eax
80102a61:	89 c2                	mov    %eax,%edx
80102a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a66:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6b:	8b 00                	mov    (%eax),%eax
80102a6d:	83 e0 fb             	and    $0xfffffffb,%eax
80102a70:	89 c2                	mov    %eax,%edx
80102a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a75:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a77:	83 ec 0c             	sub    $0xc,%esp
80102a7a:	ff 75 f4             	pushl  -0xc(%ebp)
80102a7d:	e8 c1 24 00 00       	call   80104f43 <wakeup>
80102a82:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a85:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a8a:	85 c0                	test   %eax,%eax
80102a8c:	74 11                	je     80102a9f <ideintr+0xc7>
    idestart(idequeue);
80102a8e:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a93:	83 ec 0c             	sub    $0xc,%esp
80102a96:	50                   	push   %eax
80102a97:	e8 a6 fd ff ff       	call   80102842 <idestart>
80102a9c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a9f:	83 ec 0c             	sub    $0xc,%esp
80102aa2:	68 00 c6 10 80       	push   $0x8010c600
80102aa7:	e8 89 28 00 00       	call   80105335 <release>
80102aac:	83 c4 10             	add    $0x10,%esp
}
80102aaf:	c9                   	leave  
80102ab0:	c3                   	ret    

80102ab1 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ab1:	f3 0f 1e fb          	endbr32 
80102ab5:	55                   	push   %ebp
80102ab6:	89 e5                	mov    %esp,%ebp
80102ab8:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	83 c0 0c             	add    $0xc,%eax
80102ac1:	83 ec 0c             	sub    $0xc,%esp
80102ac4:	50                   	push   %eax
80102ac5:	e8 3a 27 00 00       	call   80105204 <holdingsleep>
80102aca:	83 c4 10             	add    $0x10,%esp
80102acd:	85 c0                	test   %eax,%eax
80102acf:	75 0d                	jne    80102ade <iderw+0x2d>
    panic("iderw: buf not locked");
80102ad1:	83 ec 0c             	sub    $0xc,%esp
80102ad4:	68 62 95 10 80       	push   $0x80109562
80102ad9:	e8 2a db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ade:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae1:	8b 00                	mov    (%eax),%eax
80102ae3:	83 e0 06             	and    $0x6,%eax
80102ae6:	83 f8 02             	cmp    $0x2,%eax
80102ae9:	75 0d                	jne    80102af8 <iderw+0x47>
    panic("iderw: nothing to do");
80102aeb:	83 ec 0c             	sub    $0xc,%esp
80102aee:	68 78 95 10 80       	push   $0x80109578
80102af3:	e8 10 db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102af8:	8b 45 08             	mov    0x8(%ebp),%eax
80102afb:	8b 40 04             	mov    0x4(%eax),%eax
80102afe:	85 c0                	test   %eax,%eax
80102b00:	74 16                	je     80102b18 <iderw+0x67>
80102b02:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b07:	85 c0                	test   %eax,%eax
80102b09:	75 0d                	jne    80102b18 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b0b:	83 ec 0c             	sub    $0xc,%esp
80102b0e:	68 8d 95 10 80       	push   $0x8010958d
80102b13:	e8 f0 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b18:	83 ec 0c             	sub    $0xc,%esp
80102b1b:	68 00 c6 10 80       	push   $0x8010c600
80102b20:	e8 9e 27 00 00       	call   801052c3 <acquire>
80102b25:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b28:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2b:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b32:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b39:	eb 0b                	jmp    80102b46 <iderw+0x95>
80102b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3e:	8b 00                	mov    (%eax),%eax
80102b40:	83 c0 58             	add    $0x58,%eax
80102b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b49:	8b 00                	mov    (%eax),%eax
80102b4b:	85 c0                	test   %eax,%eax
80102b4d:	75 ec                	jne    80102b3b <iderw+0x8a>
    ;
  *pp = b;
80102b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b52:	8b 55 08             	mov    0x8(%ebp),%edx
80102b55:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b57:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b5c:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b5f:	75 23                	jne    80102b84 <iderw+0xd3>
    idestart(b);
80102b61:	83 ec 0c             	sub    $0xc,%esp
80102b64:	ff 75 08             	pushl  0x8(%ebp)
80102b67:	e8 d6 fc ff ff       	call   80102842 <idestart>
80102b6c:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b6f:	eb 13                	jmp    80102b84 <iderw+0xd3>
    sleep(b, &idelock);
80102b71:	83 ec 08             	sub    $0x8,%esp
80102b74:	68 00 c6 10 80       	push   $0x8010c600
80102b79:	ff 75 08             	pushl  0x8(%ebp)
80102b7c:	e8 d0 22 00 00       	call   80104e51 <sleep>
80102b81:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b84:	8b 45 08             	mov    0x8(%ebp),%eax
80102b87:	8b 00                	mov    (%eax),%eax
80102b89:	83 e0 06             	and    $0x6,%eax
80102b8c:	83 f8 02             	cmp    $0x2,%eax
80102b8f:	75 e0                	jne    80102b71 <iderw+0xc0>
  }


  release(&idelock);
80102b91:	83 ec 0c             	sub    $0xc,%esp
80102b94:	68 00 c6 10 80       	push   $0x8010c600
80102b99:	e8 97 27 00 00       	call   80105335 <release>
80102b9e:	83 c4 10             	add    $0x10,%esp
}
80102ba1:	90                   	nop
80102ba2:	c9                   	leave  
80102ba3:	c3                   	ret    

80102ba4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ba4:	f3 0f 1e fb          	endbr32 
80102ba8:	55                   	push   %ebp
80102ba9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bab:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bb0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bb5:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bba:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bbd:	5d                   	pop    %ebp
80102bbe:	c3                   	ret    

80102bbf <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bbf:	f3 0f 1e fb          	endbr32 
80102bc3:	55                   	push   %ebp
80102bc4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bc6:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bcb:	8b 55 08             	mov    0x8(%ebp),%edx
80102bce:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bd0:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bd8:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bdb:	90                   	nop
80102bdc:	5d                   	pop    %ebp
80102bdd:	c3                   	ret    

80102bde <ioapicinit>:

void
ioapicinit(void)
{
80102bde:	f3 0f 1e fb          	endbr32 
80102be2:	55                   	push   %ebp
80102be3:	89 e5                	mov    %esp,%ebp
80102be5:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102be8:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102bef:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bf2:	6a 01                	push   $0x1
80102bf4:	e8 ab ff ff ff       	call   80102ba4 <ioapicread>
80102bf9:	83 c4 04             	add    $0x4,%esp
80102bfc:	c1 e8 10             	shr    $0x10,%eax
80102bff:	25 ff 00 00 00       	and    $0xff,%eax
80102c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c07:	6a 00                	push   $0x0
80102c09:	e8 96 ff ff ff       	call   80102ba4 <ioapicread>
80102c0e:	83 c4 04             	add    $0x4,%esp
80102c11:	c1 e8 18             	shr    $0x18,%eax
80102c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c17:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c1e:	0f b6 c0             	movzbl %al,%eax
80102c21:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c24:	74 10                	je     80102c36 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c26:	83 ec 0c             	sub    $0xc,%esp
80102c29:	68 ac 95 10 80       	push   $0x801095ac
80102c2e:	e8 e5 d7 ff ff       	call   80100418 <cprintf>
80102c33:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c3d:	eb 3f                	jmp    80102c7e <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c42:	83 c0 20             	add    $0x20,%eax
80102c45:	0d 00 00 01 00       	or     $0x10000,%eax
80102c4a:	89 c2                	mov    %eax,%edx
80102c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4f:	83 c0 08             	add    $0x8,%eax
80102c52:	01 c0                	add    %eax,%eax
80102c54:	83 ec 08             	sub    $0x8,%esp
80102c57:	52                   	push   %edx
80102c58:	50                   	push   %eax
80102c59:	e8 61 ff ff ff       	call   80102bbf <ioapicwrite>
80102c5e:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c64:	83 c0 08             	add    $0x8,%eax
80102c67:	01 c0                	add    %eax,%eax
80102c69:	83 c0 01             	add    $0x1,%eax
80102c6c:	83 ec 08             	sub    $0x8,%esp
80102c6f:	6a 00                	push   $0x0
80102c71:	50                   	push   %eax
80102c72:	e8 48 ff ff ff       	call   80102bbf <ioapicwrite>
80102c77:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c81:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c84:	7e b9                	jle    80102c3f <ioapicinit+0x61>
  }
}
80102c86:	90                   	nop
80102c87:	90                   	nop
80102c88:	c9                   	leave  
80102c89:	c3                   	ret    

80102c8a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c8a:	f3 0f 1e fb          	endbr32 
80102c8e:	55                   	push   %ebp
80102c8f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c91:	8b 45 08             	mov    0x8(%ebp),%eax
80102c94:	83 c0 20             	add    $0x20,%eax
80102c97:	89 c2                	mov    %eax,%edx
80102c99:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9c:	83 c0 08             	add    $0x8,%eax
80102c9f:	01 c0                	add    %eax,%eax
80102ca1:	52                   	push   %edx
80102ca2:	50                   	push   %eax
80102ca3:	e8 17 ff ff ff       	call   80102bbf <ioapicwrite>
80102ca8:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cab:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cae:	c1 e0 18             	shl    $0x18,%eax
80102cb1:	89 c2                	mov    %eax,%edx
80102cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb6:	83 c0 08             	add    $0x8,%eax
80102cb9:	01 c0                	add    %eax,%eax
80102cbb:	83 c0 01             	add    $0x1,%eax
80102cbe:	52                   	push   %edx
80102cbf:	50                   	push   %eax
80102cc0:	e8 fa fe ff ff       	call   80102bbf <ioapicwrite>
80102cc5:	83 c4 08             	add    $0x8,%esp
}
80102cc8:	90                   	nop
80102cc9:	c9                   	leave  
80102cca:	c3                   	ret    

80102ccb <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ccb:	f3 0f 1e fb          	endbr32 
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cd5:	83 ec 08             	sub    $0x8,%esp
80102cd8:	68 e0 95 10 80       	push   $0x801095e0
80102cdd:	68 e0 46 11 80       	push   $0x801146e0
80102ce2:	e8 b6 25 00 00       	call   8010529d <initlock>
80102ce7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cea:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102cf1:	00 00 00 
  freerange(vstart, vend);
80102cf4:	83 ec 08             	sub    $0x8,%esp
80102cf7:	ff 75 0c             	pushl  0xc(%ebp)
80102cfa:	ff 75 08             	pushl  0x8(%ebp)
80102cfd:	e8 2e 00 00 00       	call   80102d30 <freerange>
80102d02:	83 c4 10             	add    $0x10,%esp
}
80102d05:	90                   	nop
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d08:	f3 0f 1e fb          	endbr32 
80102d0c:	55                   	push   %ebp
80102d0d:	89 e5                	mov    %esp,%ebp
80102d0f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d12:	83 ec 08             	sub    $0x8,%esp
80102d15:	ff 75 0c             	pushl  0xc(%ebp)
80102d18:	ff 75 08             	pushl  0x8(%ebp)
80102d1b:	e8 10 00 00 00       	call   80102d30 <freerange>
80102d20:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d23:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d2a:	00 00 00 
}
80102d2d:	90                   	nop
80102d2e:	c9                   	leave  
80102d2f:	c3                   	ret    

80102d30 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d30:	f3 0f 1e fb          	endbr32 
80102d34:	55                   	push   %ebp
80102d35:	89 e5                	mov    %esp,%ebp
80102d37:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d4a:	eb 15                	jmp    80102d61 <freerange+0x31>
    kfree(p);
80102d4c:	83 ec 0c             	sub    $0xc,%esp
80102d4f:	ff 75 f4             	pushl  -0xc(%ebp)
80102d52:	e8 1b 00 00 00       	call   80102d72 <kfree>
80102d57:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d5a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d64:	05 00 10 00 00       	add    $0x1000,%eax
80102d69:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d6c:	73 de                	jae    80102d4c <freerange+0x1c>
}
80102d6e:	90                   	nop
80102d6f:	90                   	nop
80102d70:	c9                   	leave  
80102d71:	c3                   	ret    

80102d72 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d72:	f3 0f 1e fb          	endbr32 
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d84:	85 c0                	test   %eax,%eax
80102d86:	75 18                	jne    80102da0 <kfree+0x2e>
80102d88:	81 7d 08 48 86 11 80 	cmpl   $0x80118648,0x8(%ebp)
80102d8f:	72 0f                	jb     80102da0 <kfree+0x2e>
80102d91:	8b 45 08             	mov    0x8(%ebp),%eax
80102d94:	05 00 00 00 80       	add    $0x80000000,%eax
80102d99:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d9e:	76 0d                	jbe    80102dad <kfree+0x3b>
    panic("kfree");
80102da0:	83 ec 0c             	sub    $0xc,%esp
80102da3:	68 e5 95 10 80       	push   $0x801095e5
80102da8:	e8 5b d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dad:	83 ec 04             	sub    $0x4,%esp
80102db0:	68 00 10 00 00       	push   $0x1000
80102db5:	6a 01                	push   $0x1
80102db7:	ff 75 08             	pushl  0x8(%ebp)
80102dba:	e8 a3 27 00 00       	call   80105562 <memset>
80102dbf:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dc2:	a1 14 47 11 80       	mov    0x80114714,%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	74 10                	je     80102ddb <kfree+0x69>
    acquire(&kmem.lock);
80102dcb:	83 ec 0c             	sub    $0xc,%esp
80102dce:	68 e0 46 11 80       	push   $0x801146e0
80102dd3:	e8 eb 24 00 00       	call   801052c3 <acquire>
80102dd8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102de1:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102def:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102df4:	a1 14 47 11 80       	mov    0x80114714,%eax
80102df9:	85 c0                	test   %eax,%eax
80102dfb:	74 10                	je     80102e0d <kfree+0x9b>
    release(&kmem.lock);
80102dfd:	83 ec 0c             	sub    $0xc,%esp
80102e00:	68 e0 46 11 80       	push   $0x801146e0
80102e05:	e8 2b 25 00 00       	call   80105335 <release>
80102e0a:	83 c4 10             	add    $0x10,%esp
}
80102e0d:	90                   	nop
80102e0e:	c9                   	leave  
80102e0f:	c3                   	ret    

80102e10 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e10:	f3 0f 1e fb          	endbr32 
80102e14:	55                   	push   %ebp
80102e15:	89 e5                	mov    %esp,%ebp
80102e17:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e1a:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	74 10                	je     80102e33 <kalloc+0x23>
    acquire(&kmem.lock);
80102e23:	83 ec 0c             	sub    $0xc,%esp
80102e26:	68 e0 46 11 80       	push   $0x801146e0
80102e2b:	e8 93 24 00 00       	call   801052c3 <acquire>
80102e30:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e33:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e3f:	74 0a                	je     80102e4b <kalloc+0x3b>
    kmem.freelist = r->next;
80102e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e44:	8b 00                	mov    (%eax),%eax
80102e46:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e4b:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e50:	85 c0                	test   %eax,%eax
80102e52:	74 10                	je     80102e64 <kalloc+0x54>
    release(&kmem.lock);
80102e54:	83 ec 0c             	sub    $0xc,%esp
80102e57:	68 e0 46 11 80       	push   $0x801146e0
80102e5c:	e8 d4 24 00 00       	call   80105335 <release>
80102e61:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e67:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e70:	05 00 00 00 80       	add    $0x80000000,%eax
80102e75:	c1 e8 0c             	shr    $0xc,%eax
80102e78:	83 ec 04             	sub    $0x4,%esp
80102e7b:	52                   	push   %edx
80102e7c:	50                   	push   %eax
80102e7d:	68 ec 95 10 80       	push   $0x801095ec
80102e82:	e8 91 d5 ff ff       	call   80100418 <cprintf>
80102e87:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e8d:	c9                   	leave  
80102e8e:	c3                   	ret    

80102e8f <inb>:
{
80102e8f:	55                   	push   %ebp
80102e90:	89 e5                	mov    %esp,%ebp
80102e92:	83 ec 14             	sub    $0x14,%esp
80102e95:	8b 45 08             	mov    0x8(%ebp),%eax
80102e98:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e9c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ea0:	89 c2                	mov    %eax,%edx
80102ea2:	ec                   	in     (%dx),%al
80102ea3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ea6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102eaa:	c9                   	leave  
80102eab:	c3                   	ret    

80102eac <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102eac:	f3 0f 1e fb          	endbr32 
80102eb0:	55                   	push   %ebp
80102eb1:	89 e5                	mov    %esp,%ebp
80102eb3:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102eb6:	6a 64                	push   $0x64
80102eb8:	e8 d2 ff ff ff       	call   80102e8f <inb>
80102ebd:	83 c4 04             	add    $0x4,%esp
80102ec0:	0f b6 c0             	movzbl %al,%eax
80102ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ec9:	83 e0 01             	and    $0x1,%eax
80102ecc:	85 c0                	test   %eax,%eax
80102ece:	75 0a                	jne    80102eda <kbdgetc+0x2e>
    return -1;
80102ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ed5:	e9 23 01 00 00       	jmp    80102ffd <kbdgetc+0x151>
  data = inb(KBDATAP);
80102eda:	6a 60                	push   $0x60
80102edc:	e8 ae ff ff ff       	call   80102e8f <inb>
80102ee1:	83 c4 04             	add    $0x4,%esp
80102ee4:	0f b6 c0             	movzbl %al,%eax
80102ee7:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102eea:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ef1:	75 17                	jne    80102f0a <kbdgetc+0x5e>
    shift |= E0ESC;
80102ef3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ef8:	83 c8 40             	or     $0x40,%eax
80102efb:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f00:	b8 00 00 00 00       	mov    $0x0,%eax
80102f05:	e9 f3 00 00 00       	jmp    80102ffd <kbdgetc+0x151>
  } else if(data & 0x80){
80102f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f0d:	25 80 00 00 00       	and    $0x80,%eax
80102f12:	85 c0                	test   %eax,%eax
80102f14:	74 45                	je     80102f5b <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f16:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f1b:	83 e0 40             	and    $0x40,%eax
80102f1e:	85 c0                	test   %eax,%eax
80102f20:	75 08                	jne    80102f2a <kbdgetc+0x7e>
80102f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f25:	83 e0 7f             	and    $0x7f,%eax
80102f28:	eb 03                	jmp    80102f2d <kbdgetc+0x81>
80102f2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f33:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f38:	0f b6 00             	movzbl (%eax),%eax
80102f3b:	83 c8 40             	or     $0x40,%eax
80102f3e:	0f b6 c0             	movzbl %al,%eax
80102f41:	f7 d0                	not    %eax
80102f43:	89 c2                	mov    %eax,%edx
80102f45:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f4a:	21 d0                	and    %edx,%eax
80102f4c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f51:	b8 00 00 00 00       	mov    $0x0,%eax
80102f56:	e9 a2 00 00 00       	jmp    80102ffd <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f5b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f60:	83 e0 40             	and    $0x40,%eax
80102f63:	85 c0                	test   %eax,%eax
80102f65:	74 14                	je     80102f7b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f67:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f6e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f73:	83 e0 bf             	and    $0xffffffbf,%eax
80102f76:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f7e:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f83:	0f b6 00             	movzbl (%eax),%eax
80102f86:	0f b6 d0             	movzbl %al,%edx
80102f89:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f8e:	09 d0                	or     %edx,%eax
80102f90:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f98:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f9d:	0f b6 00             	movzbl (%eax),%eax
80102fa0:	0f b6 d0             	movzbl %al,%edx
80102fa3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fa8:	31 d0                	xor    %edx,%eax
80102faa:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102faf:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fb4:	83 e0 03             	and    $0x3,%eax
80102fb7:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102fbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fc1:	01 d0                	add    %edx,%eax
80102fc3:	0f b6 00             	movzbl (%eax),%eax
80102fc6:	0f b6 c0             	movzbl %al,%eax
80102fc9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fcc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fd1:	83 e0 08             	and    $0x8,%eax
80102fd4:	85 c0                	test   %eax,%eax
80102fd6:	74 22                	je     80102ffa <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fd8:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fdc:	76 0c                	jbe    80102fea <kbdgetc+0x13e>
80102fde:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fe2:	77 06                	ja     80102fea <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fe4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fe8:	eb 10                	jmp    80102ffa <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fea:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fee:	76 0a                	jbe    80102ffa <kbdgetc+0x14e>
80102ff0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ff4:	77 04                	ja     80102ffa <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ff6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ffa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ffd:	c9                   	leave  
80102ffe:	c3                   	ret    

80102fff <kbdintr>:

void
kbdintr(void)
{
80102fff:	f3 0f 1e fb          	endbr32 
80103003:	55                   	push   %ebp
80103004:	89 e5                	mov    %esp,%ebp
80103006:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	68 ac 2e 10 80       	push   $0x80102eac
80103011:	e8 92 d8 ff ff       	call   801008a8 <consoleintr>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <inb>:
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 14             	sub    $0x14,%esp
80103022:	8b 45 08             	mov    0x8(%ebp),%eax
80103025:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103029:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010302d:	89 c2                	mov    %eax,%edx
8010302f:	ec                   	in     (%dx),%al
80103030:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103033:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103037:	c9                   	leave  
80103038:	c3                   	ret    

80103039 <outb>:
{
80103039:	55                   	push   %ebp
8010303a:	89 e5                	mov    %esp,%ebp
8010303c:	83 ec 08             	sub    $0x8,%esp
8010303f:	8b 45 08             	mov    0x8(%ebp),%eax
80103042:	8b 55 0c             	mov    0xc(%ebp),%edx
80103045:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103049:	89 d0                	mov    %edx,%eax
8010304b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010304e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103052:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103056:	ee                   	out    %al,(%dx)
}
80103057:	90                   	nop
80103058:	c9                   	leave  
80103059:	c3                   	ret    

8010305a <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010305a:	f3 0f 1e fb          	endbr32 
8010305e:	55                   	push   %ebp
8010305f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103061:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103066:	8b 55 08             	mov    0x8(%ebp),%edx
80103069:	c1 e2 02             	shl    $0x2,%edx
8010306c:	01 c2                	add    %eax,%edx
8010306e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103071:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103073:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103078:	83 c0 20             	add    $0x20,%eax
8010307b:	8b 00                	mov    (%eax),%eax
}
8010307d:	90                   	nop
8010307e:	5d                   	pop    %ebp
8010307f:	c3                   	ret    

80103080 <lapicinit>:

void
lapicinit(void)
{
80103080:	f3 0f 1e fb          	endbr32 
80103084:	55                   	push   %ebp
80103085:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80103087:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010308c:	85 c0                	test   %eax,%eax
8010308e:	0f 84 0c 01 00 00    	je     801031a0 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103094:	68 3f 01 00 00       	push   $0x13f
80103099:	6a 3c                	push   $0x3c
8010309b:	e8 ba ff ff ff       	call   8010305a <lapicw>
801030a0:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030a3:	6a 0b                	push   $0xb
801030a5:	68 f8 00 00 00       	push   $0xf8
801030aa:	e8 ab ff ff ff       	call   8010305a <lapicw>
801030af:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030b2:	68 20 00 02 00       	push   $0x20020
801030b7:	68 c8 00 00 00       	push   $0xc8
801030bc:	e8 99 ff ff ff       	call   8010305a <lapicw>
801030c1:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030c4:	68 80 96 98 00       	push   $0x989680
801030c9:	68 e0 00 00 00       	push   $0xe0
801030ce:	e8 87 ff ff ff       	call   8010305a <lapicw>
801030d3:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030d6:	68 00 00 01 00       	push   $0x10000
801030db:	68 d4 00 00 00       	push   $0xd4
801030e0:	e8 75 ff ff ff       	call   8010305a <lapicw>
801030e5:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030e8:	68 00 00 01 00       	push   $0x10000
801030ed:	68 d8 00 00 00       	push   $0xd8
801030f2:	e8 63 ff ff ff       	call   8010305a <lapicw>
801030f7:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030fa:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030ff:	83 c0 30             	add    $0x30,%eax
80103102:	8b 00                	mov    (%eax),%eax
80103104:	c1 e8 10             	shr    $0x10,%eax
80103107:	25 fc 00 00 00       	and    $0xfc,%eax
8010310c:	85 c0                	test   %eax,%eax
8010310e:	74 12                	je     80103122 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103110:	68 00 00 01 00       	push   $0x10000
80103115:	68 d0 00 00 00       	push   $0xd0
8010311a:	e8 3b ff ff ff       	call   8010305a <lapicw>
8010311f:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103122:	6a 33                	push   $0x33
80103124:	68 dc 00 00 00       	push   $0xdc
80103129:	e8 2c ff ff ff       	call   8010305a <lapicw>
8010312e:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103131:	6a 00                	push   $0x0
80103133:	68 a0 00 00 00       	push   $0xa0
80103138:	e8 1d ff ff ff       	call   8010305a <lapicw>
8010313d:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103140:	6a 00                	push   $0x0
80103142:	68 a0 00 00 00       	push   $0xa0
80103147:	e8 0e ff ff ff       	call   8010305a <lapicw>
8010314c:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010314f:	6a 00                	push   $0x0
80103151:	6a 2c                	push   $0x2c
80103153:	e8 02 ff ff ff       	call   8010305a <lapicw>
80103158:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010315b:	6a 00                	push   $0x0
8010315d:	68 c4 00 00 00       	push   $0xc4
80103162:	e8 f3 fe ff ff       	call   8010305a <lapicw>
80103167:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010316a:	68 00 85 08 00       	push   $0x88500
8010316f:	68 c0 00 00 00       	push   $0xc0
80103174:	e8 e1 fe ff ff       	call   8010305a <lapicw>
80103179:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010317c:	90                   	nop
8010317d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103182:	05 00 03 00 00       	add    $0x300,%eax
80103187:	8b 00                	mov    (%eax),%eax
80103189:	25 00 10 00 00       	and    $0x1000,%eax
8010318e:	85 c0                	test   %eax,%eax
80103190:	75 eb                	jne    8010317d <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103192:	6a 00                	push   $0x0
80103194:	6a 20                	push   $0x20
80103196:	e8 bf fe ff ff       	call   8010305a <lapicw>
8010319b:	83 c4 08             	add    $0x8,%esp
8010319e:	eb 01                	jmp    801031a1 <lapicinit+0x121>
    return;
801031a0:	90                   	nop
}
801031a1:	c9                   	leave  
801031a2:	c3                   	ret    

801031a3 <lapicid>:

int
lapicid(void)
{
801031a3:	f3 0f 1e fb          	endbr32 
801031a7:	55                   	push   %ebp
801031a8:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031aa:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031af:	85 c0                	test   %eax,%eax
801031b1:	75 07                	jne    801031ba <lapicid+0x17>
    return 0;
801031b3:	b8 00 00 00 00       	mov    $0x0,%eax
801031b8:	eb 0d                	jmp    801031c7 <lapicid+0x24>
  return lapic[ID] >> 24;
801031ba:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031bf:	83 c0 20             	add    $0x20,%eax
801031c2:	8b 00                	mov    (%eax),%eax
801031c4:	c1 e8 18             	shr    $0x18,%eax
}
801031c7:	5d                   	pop    %ebp
801031c8:	c3                   	ret    

801031c9 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031c9:	f3 0f 1e fb          	endbr32 
801031cd:	55                   	push   %ebp
801031ce:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031d0:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031d5:	85 c0                	test   %eax,%eax
801031d7:	74 0c                	je     801031e5 <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031d9:	6a 00                	push   $0x0
801031db:	6a 2c                	push   $0x2c
801031dd:	e8 78 fe ff ff       	call   8010305a <lapicw>
801031e2:	83 c4 08             	add    $0x8,%esp
}
801031e5:	90                   	nop
801031e6:	c9                   	leave  
801031e7:	c3                   	ret    

801031e8 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031e8:	f3 0f 1e fb          	endbr32 
801031ec:	55                   	push   %ebp
801031ed:	89 e5                	mov    %esp,%ebp
}
801031ef:	90                   	nop
801031f0:	5d                   	pop    %ebp
801031f1:	c3                   	ret    

801031f2 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031f2:	f3 0f 1e fb          	endbr32 
801031f6:	55                   	push   %ebp
801031f7:	89 e5                	mov    %esp,%ebp
801031f9:	83 ec 14             	sub    $0x14,%esp
801031fc:	8b 45 08             	mov    0x8(%ebp),%eax
801031ff:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103202:	6a 0f                	push   $0xf
80103204:	6a 70                	push   $0x70
80103206:	e8 2e fe ff ff       	call   80103039 <outb>
8010320b:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010320e:	6a 0a                	push   $0xa
80103210:	6a 71                	push   $0x71
80103212:	e8 22 fe ff ff       	call   80103039 <outb>
80103217:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010321a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103221:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103224:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010322c:	c1 e8 04             	shr    $0x4,%eax
8010322f:	89 c2                	mov    %eax,%edx
80103231:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103234:	83 c0 02             	add    $0x2,%eax
80103237:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010323a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010323e:	c1 e0 18             	shl    $0x18,%eax
80103241:	50                   	push   %eax
80103242:	68 c4 00 00 00       	push   $0xc4
80103247:	e8 0e fe ff ff       	call   8010305a <lapicw>
8010324c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010324f:	68 00 c5 00 00       	push   $0xc500
80103254:	68 c0 00 00 00       	push   $0xc0
80103259:	e8 fc fd ff ff       	call   8010305a <lapicw>
8010325e:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103261:	68 c8 00 00 00       	push   $0xc8
80103266:	e8 7d ff ff ff       	call   801031e8 <microdelay>
8010326b:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010326e:	68 00 85 00 00       	push   $0x8500
80103273:	68 c0 00 00 00       	push   $0xc0
80103278:	e8 dd fd ff ff       	call   8010305a <lapicw>
8010327d:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103280:	6a 64                	push   $0x64
80103282:	e8 61 ff ff ff       	call   801031e8 <microdelay>
80103287:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010328a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103291:	eb 3d                	jmp    801032d0 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80103293:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103297:	c1 e0 18             	shl    $0x18,%eax
8010329a:	50                   	push   %eax
8010329b:	68 c4 00 00 00       	push   $0xc4
801032a0:	e8 b5 fd ff ff       	call   8010305a <lapicw>
801032a5:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801032ab:	c1 e8 0c             	shr    $0xc,%eax
801032ae:	80 cc 06             	or     $0x6,%ah
801032b1:	50                   	push   %eax
801032b2:	68 c0 00 00 00       	push   $0xc0
801032b7:	e8 9e fd ff ff       	call   8010305a <lapicw>
801032bc:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032bf:	68 c8 00 00 00       	push   $0xc8
801032c4:	e8 1f ff ff ff       	call   801031e8 <microdelay>
801032c9:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032d0:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032d4:	7e bd                	jle    80103293 <lapicstartap+0xa1>
  }
}
801032d6:	90                   	nop
801032d7:	90                   	nop
801032d8:	c9                   	leave  
801032d9:	c3                   	ret    

801032da <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032da:	f3 0f 1e fb          	endbr32 
801032de:	55                   	push   %ebp
801032df:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032e1:	8b 45 08             	mov    0x8(%ebp),%eax
801032e4:	0f b6 c0             	movzbl %al,%eax
801032e7:	50                   	push   %eax
801032e8:	6a 70                	push   $0x70
801032ea:	e8 4a fd ff ff       	call   80103039 <outb>
801032ef:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032f2:	68 c8 00 00 00       	push   $0xc8
801032f7:	e8 ec fe ff ff       	call   801031e8 <microdelay>
801032fc:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032ff:	6a 71                	push   $0x71
80103301:	e8 16 fd ff ff       	call   8010301c <inb>
80103306:	83 c4 04             	add    $0x4,%esp
80103309:	0f b6 c0             	movzbl %al,%eax
}
8010330c:	c9                   	leave  
8010330d:	c3                   	ret    

8010330e <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010330e:	f3 0f 1e fb          	endbr32 
80103312:	55                   	push   %ebp
80103313:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103315:	6a 00                	push   $0x0
80103317:	e8 be ff ff ff       	call   801032da <cmos_read>
8010331c:	83 c4 04             	add    $0x4,%esp
8010331f:	8b 55 08             	mov    0x8(%ebp),%edx
80103322:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103324:	6a 02                	push   $0x2
80103326:	e8 af ff ff ff       	call   801032da <cmos_read>
8010332b:	83 c4 04             	add    $0x4,%esp
8010332e:	8b 55 08             	mov    0x8(%ebp),%edx
80103331:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103334:	6a 04                	push   $0x4
80103336:	e8 9f ff ff ff       	call   801032da <cmos_read>
8010333b:	83 c4 04             	add    $0x4,%esp
8010333e:	8b 55 08             	mov    0x8(%ebp),%edx
80103341:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103344:	6a 07                	push   $0x7
80103346:	e8 8f ff ff ff       	call   801032da <cmos_read>
8010334b:	83 c4 04             	add    $0x4,%esp
8010334e:	8b 55 08             	mov    0x8(%ebp),%edx
80103351:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103354:	6a 08                	push   $0x8
80103356:	e8 7f ff ff ff       	call   801032da <cmos_read>
8010335b:	83 c4 04             	add    $0x4,%esp
8010335e:	8b 55 08             	mov    0x8(%ebp),%edx
80103361:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103364:	6a 09                	push   $0x9
80103366:	e8 6f ff ff ff       	call   801032da <cmos_read>
8010336b:	83 c4 04             	add    $0x4,%esp
8010336e:	8b 55 08             	mov    0x8(%ebp),%edx
80103371:	89 42 14             	mov    %eax,0x14(%edx)
}
80103374:	90                   	nop
80103375:	c9                   	leave  
80103376:	c3                   	ret    

80103377 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103377:	f3 0f 1e fb          	endbr32 
8010337b:	55                   	push   %ebp
8010337c:	89 e5                	mov    %esp,%ebp
8010337e:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103381:	6a 0b                	push   $0xb
80103383:	e8 52 ff ff ff       	call   801032da <cmos_read>
80103388:	83 c4 04             	add    $0x4,%esp
8010338b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010338e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103391:	83 e0 04             	and    $0x4,%eax
80103394:	85 c0                	test   %eax,%eax
80103396:	0f 94 c0             	sete   %al
80103399:	0f b6 c0             	movzbl %al,%eax
8010339c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010339f:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033a2:	50                   	push   %eax
801033a3:	e8 66 ff ff ff       	call   8010330e <fill_rtcdate>
801033a8:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033ab:	6a 0a                	push   $0xa
801033ad:	e8 28 ff ff ff       	call   801032da <cmos_read>
801033b2:	83 c4 04             	add    $0x4,%esp
801033b5:	25 80 00 00 00       	and    $0x80,%eax
801033ba:	85 c0                	test   %eax,%eax
801033bc:	75 27                	jne    801033e5 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033be:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033c1:	50                   	push   %eax
801033c2:	e8 47 ff ff ff       	call   8010330e <fill_rtcdate>
801033c7:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033ca:	83 ec 04             	sub    $0x4,%esp
801033cd:	6a 18                	push   $0x18
801033cf:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033d2:	50                   	push   %eax
801033d3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033d6:	50                   	push   %eax
801033d7:	e8 f1 21 00 00       	call   801055cd <memcmp>
801033dc:	83 c4 10             	add    $0x10,%esp
801033df:	85 c0                	test   %eax,%eax
801033e1:	74 05                	je     801033e8 <cmostime+0x71>
801033e3:	eb ba                	jmp    8010339f <cmostime+0x28>
        continue;
801033e5:	90                   	nop
    fill_rtcdate(&t1);
801033e6:	eb b7                	jmp    8010339f <cmostime+0x28>
      break;
801033e8:	90                   	nop
  }

  // convert
  if(bcd) {
801033e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033ed:	0f 84 b4 00 00 00    	je     801034a7 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033f6:	c1 e8 04             	shr    $0x4,%eax
801033f9:	89 c2                	mov    %eax,%edx
801033fb:	89 d0                	mov    %edx,%eax
801033fd:	c1 e0 02             	shl    $0x2,%eax
80103400:	01 d0                	add    %edx,%eax
80103402:	01 c0                	add    %eax,%eax
80103404:	89 c2                	mov    %eax,%edx
80103406:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103409:	83 e0 0f             	and    $0xf,%eax
8010340c:	01 d0                	add    %edx,%eax
8010340e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103411:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103414:	c1 e8 04             	shr    $0x4,%eax
80103417:	89 c2                	mov    %eax,%edx
80103419:	89 d0                	mov    %edx,%eax
8010341b:	c1 e0 02             	shl    $0x2,%eax
8010341e:	01 d0                	add    %edx,%eax
80103420:	01 c0                	add    %eax,%eax
80103422:	89 c2                	mov    %eax,%edx
80103424:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103427:	83 e0 0f             	and    $0xf,%eax
8010342a:	01 d0                	add    %edx,%eax
8010342c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010342f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103432:	c1 e8 04             	shr    $0x4,%eax
80103435:	89 c2                	mov    %eax,%edx
80103437:	89 d0                	mov    %edx,%eax
80103439:	c1 e0 02             	shl    $0x2,%eax
8010343c:	01 d0                	add    %edx,%eax
8010343e:	01 c0                	add    %eax,%eax
80103440:	89 c2                	mov    %eax,%edx
80103442:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103445:	83 e0 0f             	and    $0xf,%eax
80103448:	01 d0                	add    %edx,%eax
8010344a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010344d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103450:	c1 e8 04             	shr    $0x4,%eax
80103453:	89 c2                	mov    %eax,%edx
80103455:	89 d0                	mov    %edx,%eax
80103457:	c1 e0 02             	shl    $0x2,%eax
8010345a:	01 d0                	add    %edx,%eax
8010345c:	01 c0                	add    %eax,%eax
8010345e:	89 c2                	mov    %eax,%edx
80103460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103463:	83 e0 0f             	and    $0xf,%eax
80103466:	01 d0                	add    %edx,%eax
80103468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010346b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010346e:	c1 e8 04             	shr    $0x4,%eax
80103471:	89 c2                	mov    %eax,%edx
80103473:	89 d0                	mov    %edx,%eax
80103475:	c1 e0 02             	shl    $0x2,%eax
80103478:	01 d0                	add    %edx,%eax
8010347a:	01 c0                	add    %eax,%eax
8010347c:	89 c2                	mov    %eax,%edx
8010347e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103481:	83 e0 0f             	and    $0xf,%eax
80103484:	01 d0                	add    %edx,%eax
80103486:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103489:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348c:	c1 e8 04             	shr    $0x4,%eax
8010348f:	89 c2                	mov    %eax,%edx
80103491:	89 d0                	mov    %edx,%eax
80103493:	c1 e0 02             	shl    $0x2,%eax
80103496:	01 d0                	add    %edx,%eax
80103498:	01 c0                	add    %eax,%eax
8010349a:	89 c2                	mov    %eax,%edx
8010349c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010349f:	83 e0 0f             	and    $0xf,%eax
801034a2:	01 d0                	add    %edx,%eax
801034a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034a7:	8b 45 08             	mov    0x8(%ebp),%eax
801034aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034ad:	89 10                	mov    %edx,(%eax)
801034af:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034b2:	89 50 04             	mov    %edx,0x4(%eax)
801034b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034b8:	89 50 08             	mov    %edx,0x8(%eax)
801034bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034be:	89 50 0c             	mov    %edx,0xc(%eax)
801034c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034c4:	89 50 10             	mov    %edx,0x10(%eax)
801034c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ca:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034cd:	8b 45 08             	mov    0x8(%ebp),%eax
801034d0:	8b 40 14             	mov    0x14(%eax),%eax
801034d3:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034d9:	8b 45 08             	mov    0x8(%ebp),%eax
801034dc:	89 50 14             	mov    %edx,0x14(%eax)
}
801034df:	90                   	nop
801034e0:	c9                   	leave  
801034e1:	c3                   	ret    

801034e2 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034e2:	f3 0f 1e fb          	endbr32 
801034e6:	55                   	push   %ebp
801034e7:	89 e5                	mov    %esp,%ebp
801034e9:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034ec:	83 ec 08             	sub    $0x8,%esp
801034ef:	68 0c 96 10 80       	push   $0x8010960c
801034f4:	68 20 47 11 80       	push   $0x80114720
801034f9:	e8 9f 1d 00 00       	call   8010529d <initlock>
801034fe:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103501:	83 ec 08             	sub    $0x8,%esp
80103504:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103507:	50                   	push   %eax
80103508:	ff 75 08             	pushl  0x8(%ebp)
8010350b:	e8 d3 df ff ff       	call   801014e3 <readsb>
80103510:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103513:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103516:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
8010351b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010351e:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
80103523:	8b 45 08             	mov    0x8(%ebp),%eax
80103526:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
8010352b:	e8 bf 01 00 00       	call   801036ef <recover_from_log>
}
80103530:	90                   	nop
80103531:	c9                   	leave  
80103532:	c3                   	ret    

80103533 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103533:	f3 0f 1e fb          	endbr32 
80103537:	55                   	push   %ebp
80103538:	89 e5                	mov    %esp,%ebp
8010353a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010353d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103544:	e9 95 00 00 00       	jmp    801035de <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103549:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010354f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103552:	01 d0                	add    %edx,%eax
80103554:	83 c0 01             	add    $0x1,%eax
80103557:	89 c2                	mov    %eax,%edx
80103559:	a1 64 47 11 80       	mov    0x80114764,%eax
8010355e:	83 ec 08             	sub    $0x8,%esp
80103561:	52                   	push   %edx
80103562:	50                   	push   %eax
80103563:	e8 6f cc ff ff       	call   801001d7 <bread>
80103568:	83 c4 10             	add    $0x10,%esp
8010356b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010356e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103571:	83 c0 10             	add    $0x10,%eax
80103574:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
8010357b:	89 c2                	mov    %eax,%edx
8010357d:	a1 64 47 11 80       	mov    0x80114764,%eax
80103582:	83 ec 08             	sub    $0x8,%esp
80103585:	52                   	push   %edx
80103586:	50                   	push   %eax
80103587:	e8 4b cc ff ff       	call   801001d7 <bread>
8010358c:	83 c4 10             	add    $0x10,%esp
8010358f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103595:	8d 50 5c             	lea    0x5c(%eax),%edx
80103598:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359b:	83 c0 5c             	add    $0x5c,%eax
8010359e:	83 ec 04             	sub    $0x4,%esp
801035a1:	68 00 02 00 00       	push   $0x200
801035a6:	52                   	push   %edx
801035a7:	50                   	push   %eax
801035a8:	e8 7c 20 00 00       	call   80105629 <memmove>
801035ad:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035b0:	83 ec 0c             	sub    $0xc,%esp
801035b3:	ff 75 ec             	pushl  -0x14(%ebp)
801035b6:	e8 59 cc ff ff       	call   80100214 <bwrite>
801035bb:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035be:	83 ec 0c             	sub    $0xc,%esp
801035c1:	ff 75 f0             	pushl  -0x10(%ebp)
801035c4:	e8 98 cc ff ff       	call   80100261 <brelse>
801035c9:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035cc:	83 ec 0c             	sub    $0xc,%esp
801035cf:	ff 75 ec             	pushl  -0x14(%ebp)
801035d2:	e8 8a cc ff ff       	call   80100261 <brelse>
801035d7:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035de:	a1 68 47 11 80       	mov    0x80114768,%eax
801035e3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035e6:	0f 8c 5d ff ff ff    	jl     80103549 <install_trans+0x16>
  }
}
801035ec:	90                   	nop
801035ed:	90                   	nop
801035ee:	c9                   	leave  
801035ef:	c3                   	ret    

801035f0 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035f0:	f3 0f 1e fb          	endbr32 
801035f4:	55                   	push   %ebp
801035f5:	89 e5                	mov    %esp,%ebp
801035f7:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035fa:	a1 54 47 11 80       	mov    0x80114754,%eax
801035ff:	89 c2                	mov    %eax,%edx
80103601:	a1 64 47 11 80       	mov    0x80114764,%eax
80103606:	83 ec 08             	sub    $0x8,%esp
80103609:	52                   	push   %edx
8010360a:	50                   	push   %eax
8010360b:	e8 c7 cb ff ff       	call   801001d7 <bread>
80103610:	83 c4 10             	add    $0x10,%esp
80103613:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103619:	83 c0 5c             	add    $0x5c,%eax
8010361c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010361f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103622:	8b 00                	mov    (%eax),%eax
80103624:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103630:	eb 1b                	jmp    8010364d <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103632:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103638:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010363c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363f:	83 c2 10             	add    $0x10,%edx
80103642:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103649:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010364d:	a1 68 47 11 80       	mov    0x80114768,%eax
80103652:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103655:	7c db                	jl     80103632 <read_head+0x42>
  }
  brelse(buf);
80103657:	83 ec 0c             	sub    $0xc,%esp
8010365a:	ff 75 f0             	pushl  -0x10(%ebp)
8010365d:	e8 ff cb ff ff       	call   80100261 <brelse>
80103662:	83 c4 10             	add    $0x10,%esp
}
80103665:	90                   	nop
80103666:	c9                   	leave  
80103667:	c3                   	ret    

80103668 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103668:	f3 0f 1e fb          	endbr32 
8010366c:	55                   	push   %ebp
8010366d:	89 e5                	mov    %esp,%ebp
8010366f:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103672:	a1 54 47 11 80       	mov    0x80114754,%eax
80103677:	89 c2                	mov    %eax,%edx
80103679:	a1 64 47 11 80       	mov    0x80114764,%eax
8010367e:	83 ec 08             	sub    $0x8,%esp
80103681:	52                   	push   %edx
80103682:	50                   	push   %eax
80103683:	e8 4f cb ff ff       	call   801001d7 <bread>
80103688:	83 c4 10             	add    $0x10,%esp
8010368b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010368e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103691:	83 c0 5c             	add    $0x5c,%eax
80103694:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103697:	8b 15 68 47 11 80    	mov    0x80114768,%edx
8010369d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a0:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036a9:	eb 1b                	jmp    801036c6 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ae:	83 c0 10             	add    $0x10,%eax
801036b1:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
801036b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036be:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036c6:	a1 68 47 11 80       	mov    0x80114768,%eax
801036cb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036ce:	7c db                	jl     801036ab <write_head+0x43>
  }
  bwrite(buf);
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	ff 75 f0             	pushl  -0x10(%ebp)
801036d6:	e8 39 cb ff ff       	call   80100214 <bwrite>
801036db:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036de:	83 ec 0c             	sub    $0xc,%esp
801036e1:	ff 75 f0             	pushl  -0x10(%ebp)
801036e4:	e8 78 cb ff ff       	call   80100261 <brelse>
801036e9:	83 c4 10             	add    $0x10,%esp
}
801036ec:	90                   	nop
801036ed:	c9                   	leave  
801036ee:	c3                   	ret    

801036ef <recover_from_log>:

static void
recover_from_log(void)
{
801036ef:	f3 0f 1e fb          	endbr32 
801036f3:	55                   	push   %ebp
801036f4:	89 e5                	mov    %esp,%ebp
801036f6:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036f9:	e8 f2 fe ff ff       	call   801035f0 <read_head>
  install_trans(); // if committed, copy from log to disk
801036fe:	e8 30 fe ff ff       	call   80103533 <install_trans>
  log.lh.n = 0;
80103703:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010370a:	00 00 00 
  write_head(); // clear the log
8010370d:	e8 56 ff ff ff       	call   80103668 <write_head>
}
80103712:	90                   	nop
80103713:	c9                   	leave  
80103714:	c3                   	ret    

80103715 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103715:	f3 0f 1e fb          	endbr32 
80103719:	55                   	push   %ebp
8010371a:	89 e5                	mov    %esp,%ebp
8010371c:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010371f:	83 ec 0c             	sub    $0xc,%esp
80103722:	68 20 47 11 80       	push   $0x80114720
80103727:	e8 97 1b 00 00       	call   801052c3 <acquire>
8010372c:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010372f:	a1 60 47 11 80       	mov    0x80114760,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	74 17                	je     8010374f <begin_op+0x3a>
      sleep(&log, &log.lock);
80103738:	83 ec 08             	sub    $0x8,%esp
8010373b:	68 20 47 11 80       	push   $0x80114720
80103740:	68 20 47 11 80       	push   $0x80114720
80103745:	e8 07 17 00 00       	call   80104e51 <sleep>
8010374a:	83 c4 10             	add    $0x10,%esp
8010374d:	eb e0                	jmp    8010372f <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010374f:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103755:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010375a:	8d 50 01             	lea    0x1(%eax),%edx
8010375d:	89 d0                	mov    %edx,%eax
8010375f:	c1 e0 02             	shl    $0x2,%eax
80103762:	01 d0                	add    %edx,%eax
80103764:	01 c0                	add    %eax,%eax
80103766:	01 c8                	add    %ecx,%eax
80103768:	83 f8 1e             	cmp    $0x1e,%eax
8010376b:	7e 17                	jle    80103784 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010376d:	83 ec 08             	sub    $0x8,%esp
80103770:	68 20 47 11 80       	push   $0x80114720
80103775:	68 20 47 11 80       	push   $0x80114720
8010377a:	e8 d2 16 00 00       	call   80104e51 <sleep>
8010377f:	83 c4 10             	add    $0x10,%esp
80103782:	eb ab                	jmp    8010372f <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103784:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103789:	83 c0 01             	add    $0x1,%eax
8010378c:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 20 47 11 80       	push   $0x80114720
80103799:	e8 97 1b 00 00       	call   80105335 <release>
8010379e:	83 c4 10             	add    $0x10,%esp
      break;
801037a1:	90                   	nop
    }
  }
}
801037a2:	90                   	nop
801037a3:	c9                   	leave  
801037a4:	c3                   	ret    

801037a5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037a5:	f3 0f 1e fb          	endbr32 
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037b6:	83 ec 0c             	sub    $0xc,%esp
801037b9:	68 20 47 11 80       	push   $0x80114720
801037be:	e8 00 1b 00 00       	call   801052c3 <acquire>
801037c3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037c6:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037cb:	83 e8 01             	sub    $0x1,%eax
801037ce:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
801037d3:	a1 60 47 11 80       	mov    0x80114760,%eax
801037d8:	85 c0                	test   %eax,%eax
801037da:	74 0d                	je     801037e9 <end_op+0x44>
    panic("log.committing");
801037dc:	83 ec 0c             	sub    $0xc,%esp
801037df:	68 10 96 10 80       	push   $0x80109610
801037e4:	e8 1f ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037e9:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037ee:	85 c0                	test   %eax,%eax
801037f0:	75 13                	jne    80103805 <end_op+0x60>
    do_commit = 1;
801037f2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037f9:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
80103800:	00 00 00 
80103803:	eb 10                	jmp    80103815 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103805:	83 ec 0c             	sub    $0xc,%esp
80103808:	68 20 47 11 80       	push   $0x80114720
8010380d:	e8 31 17 00 00       	call   80104f43 <wakeup>
80103812:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103815:	83 ec 0c             	sub    $0xc,%esp
80103818:	68 20 47 11 80       	push   $0x80114720
8010381d:	e8 13 1b 00 00       	call   80105335 <release>
80103822:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103829:	74 3f                	je     8010386a <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010382b:	e8 fa 00 00 00       	call   8010392a <commit>
    acquire(&log.lock);
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	68 20 47 11 80       	push   $0x80114720
80103838:	e8 86 1a 00 00       	call   801052c3 <acquire>
8010383d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103840:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103847:	00 00 00 
    wakeup(&log);
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	68 20 47 11 80       	push   $0x80114720
80103852:	e8 ec 16 00 00       	call   80104f43 <wakeup>
80103857:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010385a:	83 ec 0c             	sub    $0xc,%esp
8010385d:	68 20 47 11 80       	push   $0x80114720
80103862:	e8 ce 1a 00 00       	call   80105335 <release>
80103867:	83 c4 10             	add    $0x10,%esp
  }
}
8010386a:	90                   	nop
8010386b:	c9                   	leave  
8010386c:	c3                   	ret    

8010386d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010386d:	f3 0f 1e fb          	endbr32 
80103871:	55                   	push   %ebp
80103872:	89 e5                	mov    %esp,%ebp
80103874:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103877:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010387e:	e9 95 00 00 00       	jmp    80103918 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103883:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010388c:	01 d0                	add    %edx,%eax
8010388e:	83 c0 01             	add    $0x1,%eax
80103891:	89 c2                	mov    %eax,%edx
80103893:	a1 64 47 11 80       	mov    0x80114764,%eax
80103898:	83 ec 08             	sub    $0x8,%esp
8010389b:	52                   	push   %edx
8010389c:	50                   	push   %eax
8010389d:	e8 35 c9 ff ff       	call   801001d7 <bread>
801038a2:	83 c4 10             	add    $0x10,%esp
801038a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ab:	83 c0 10             	add    $0x10,%eax
801038ae:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801038b5:	89 c2                	mov    %eax,%edx
801038b7:	a1 64 47 11 80       	mov    0x80114764,%eax
801038bc:	83 ec 08             	sub    $0x8,%esp
801038bf:	52                   	push   %edx
801038c0:	50                   	push   %eax
801038c1:	e8 11 c9 ff ff       	call   801001d7 <bread>
801038c6:	83 c4 10             	add    $0x10,%esp
801038c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801038d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d5:	83 c0 5c             	add    $0x5c,%eax
801038d8:	83 ec 04             	sub    $0x4,%esp
801038db:	68 00 02 00 00       	push   $0x200
801038e0:	52                   	push   %edx
801038e1:	50                   	push   %eax
801038e2:	e8 42 1d 00 00       	call   80105629 <memmove>
801038e7:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	ff 75 f0             	pushl  -0x10(%ebp)
801038f0:	e8 1f c9 ff ff       	call   80100214 <bwrite>
801038f5:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038f8:	83 ec 0c             	sub    $0xc,%esp
801038fb:	ff 75 ec             	pushl  -0x14(%ebp)
801038fe:	e8 5e c9 ff ff       	call   80100261 <brelse>
80103903:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103906:	83 ec 0c             	sub    $0xc,%esp
80103909:	ff 75 f0             	pushl  -0x10(%ebp)
8010390c:	e8 50 c9 ff ff       	call   80100261 <brelse>
80103911:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103914:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103918:	a1 68 47 11 80       	mov    0x80114768,%eax
8010391d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103920:	0f 8c 5d ff ff ff    	jl     80103883 <write_log+0x16>
  }
}
80103926:	90                   	nop
80103927:	90                   	nop
80103928:	c9                   	leave  
80103929:	c3                   	ret    

8010392a <commit>:

static void
commit()
{
8010392a:	f3 0f 1e fb          	endbr32 
8010392e:	55                   	push   %ebp
8010392f:	89 e5                	mov    %esp,%ebp
80103931:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103934:	a1 68 47 11 80       	mov    0x80114768,%eax
80103939:	85 c0                	test   %eax,%eax
8010393b:	7e 1e                	jle    8010395b <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010393d:	e8 2b ff ff ff       	call   8010386d <write_log>
    write_head();    // Write header to disk -- the real commit
80103942:	e8 21 fd ff ff       	call   80103668 <write_head>
    install_trans(); // Now install writes to home locations
80103947:	e8 e7 fb ff ff       	call   80103533 <install_trans>
    log.lh.n = 0;
8010394c:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103953:	00 00 00 
    write_head();    // Erase the transaction from the log
80103956:	e8 0d fd ff ff       	call   80103668 <write_head>
  }
}
8010395b:	90                   	nop
8010395c:	c9                   	leave  
8010395d:	c3                   	ret    

8010395e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010395e:	f3 0f 1e fb          	endbr32 
80103962:	55                   	push   %ebp
80103963:	89 e5                	mov    %esp,%ebp
80103965:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103968:	a1 68 47 11 80       	mov    0x80114768,%eax
8010396d:	83 f8 1d             	cmp    $0x1d,%eax
80103970:	7f 12                	jg     80103984 <log_write+0x26>
80103972:	a1 68 47 11 80       	mov    0x80114768,%eax
80103977:	8b 15 58 47 11 80    	mov    0x80114758,%edx
8010397d:	83 ea 01             	sub    $0x1,%edx
80103980:	39 d0                	cmp    %edx,%eax
80103982:	7c 0d                	jl     80103991 <log_write+0x33>
    panic("too big a transaction");
80103984:	83 ec 0c             	sub    $0xc,%esp
80103987:	68 1f 96 10 80       	push   $0x8010961f
8010398c:	e8 77 cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
80103991:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103996:	85 c0                	test   %eax,%eax
80103998:	7f 0d                	jg     801039a7 <log_write+0x49>
    panic("log_write outside of trans");
8010399a:	83 ec 0c             	sub    $0xc,%esp
8010399d:	68 35 96 10 80       	push   $0x80109635
801039a2:	e8 61 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039a7:	83 ec 0c             	sub    $0xc,%esp
801039aa:	68 20 47 11 80       	push   $0x80114720
801039af:	e8 0f 19 00 00       	call   801052c3 <acquire>
801039b4:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039be:	eb 1d                	jmp    801039dd <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c3:	83 c0 10             	add    $0x10,%eax
801039c6:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801039cd:	89 c2                	mov    %eax,%edx
801039cf:	8b 45 08             	mov    0x8(%ebp),%eax
801039d2:	8b 40 08             	mov    0x8(%eax),%eax
801039d5:	39 c2                	cmp    %eax,%edx
801039d7:	74 10                	je     801039e9 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039dd:	a1 68 47 11 80       	mov    0x80114768,%eax
801039e2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039e5:	7c d9                	jl     801039c0 <log_write+0x62>
801039e7:	eb 01                	jmp    801039ea <log_write+0x8c>
      break;
801039e9:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039ea:	8b 45 08             	mov    0x8(%ebp),%eax
801039ed:	8b 40 08             	mov    0x8(%eax),%eax
801039f0:	89 c2                	mov    %eax,%edx
801039f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f5:	83 c0 10             	add    $0x10,%eax
801039f8:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039ff:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a07:	75 0d                	jne    80103a16 <log_write+0xb8>
    log.lh.n++;
80103a09:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a0e:	83 c0 01             	add    $0x1,%eax
80103a11:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
80103a16:	8b 45 08             	mov    0x8(%ebp),%eax
80103a19:	8b 00                	mov    (%eax),%eax
80103a1b:	83 c8 04             	or     $0x4,%eax
80103a1e:	89 c2                	mov    %eax,%edx
80103a20:	8b 45 08             	mov    0x8(%ebp),%eax
80103a23:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a25:	83 ec 0c             	sub    $0xc,%esp
80103a28:	68 20 47 11 80       	push   $0x80114720
80103a2d:	e8 03 19 00 00       	call   80105335 <release>
80103a32:	83 c4 10             	add    $0x10,%esp
}
80103a35:	90                   	nop
80103a36:	c9                   	leave  
80103a37:	c3                   	ret    

80103a38 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a38:	55                   	push   %ebp
80103a39:	89 e5                	mov    %esp,%ebp
80103a3b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a3e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a41:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a47:	f0 87 02             	lock xchg %eax,(%edx)
80103a4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a50:	c9                   	leave  
80103a51:	c3                   	ret    

80103a52 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a52:	f3 0f 1e fb          	endbr32 
80103a56:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a5a:	83 e4 f0             	and    $0xfffffff0,%esp
80103a5d:	ff 71 fc             	pushl  -0x4(%ecx)
80103a60:	55                   	push   %ebp
80103a61:	89 e5                	mov    %esp,%ebp
80103a63:	51                   	push   %ecx
80103a64:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a67:	83 ec 08             	sub    $0x8,%esp
80103a6a:	68 00 00 40 80       	push   $0x80400000
80103a6f:	68 48 86 11 80       	push   $0x80118648
80103a74:	e8 52 f2 ff ff       	call   80102ccb <kinit1>
80103a79:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a7c:	e8 bf 46 00 00       	call   80108140 <kvmalloc>
  mpinit();        // detect other processors
80103a81:	e8 d9 03 00 00       	call   80103e5f <mpinit>
  lapicinit();     // interrupt controller
80103a86:	e8 f5 f5 ff ff       	call   80103080 <lapicinit>
  seginit();       // segment descriptors
80103a8b:	e8 68 41 00 00       	call   80107bf8 <seginit>
  picinit();       // disable pic
80103a90:	e8 35 05 00 00       	call   80103fca <picinit>
  ioapicinit();    // another interrupt controller
80103a95:	e8 44 f1 ff ff       	call   80102bde <ioapicinit>
  consoleinit();   // console hardware
80103a9a:	e8 42 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a9f:	e8 dd 34 00 00       	call   80106f81 <uartinit>
  pinit();         // process table
80103aa4:	e8 6e 09 00 00       	call   80104417 <pinit>
  tvinit();        // trap vectors
80103aa9:	e8 70 30 00 00       	call   80106b1e <tvinit>
  binit();         // buffer cache
80103aae:	e8 81 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103ab3:	e8 00 d6 ff ff       	call   801010b8 <fileinit>
  ideinit();       // disk 
80103ab8:	e8 e0 ec ff ff       	call   8010279d <ideinit>
  startothers();   // start other processors
80103abd:	e8 88 00 00 00       	call   80103b4a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103ac2:	83 ec 08             	sub    $0x8,%esp
80103ac5:	68 00 00 00 8e       	push   $0x8e000000
80103aca:	68 00 00 40 80       	push   $0x80400000
80103acf:	e8 34 f2 ff ff       	call   80102d08 <kinit2>
80103ad4:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103ad7:	e8 68 0b 00 00       	call   80104644 <userinit>
  mpmain();        // finish this processor's setup
80103adc:	e8 1e 00 00 00       	call   80103aff <mpmain>

80103ae1 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103ae1:	f3 0f 1e fb          	endbr32 
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
80103ae8:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103aeb:	e8 6c 46 00 00       	call   8010815c <switchkvm>
  seginit();
80103af0:	e8 03 41 00 00       	call   80107bf8 <seginit>
  lapicinit();
80103af5:	e8 86 f5 ff ff       	call   80103080 <lapicinit>
  mpmain();
80103afa:	e8 00 00 00 00       	call   80103aff <mpmain>

80103aff <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103aff:	f3 0f 1e fb          	endbr32 
80103b03:	55                   	push   %ebp
80103b04:	89 e5                	mov    %esp,%ebp
80103b06:	53                   	push   %ebx
80103b07:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b0a:	e8 2a 09 00 00       	call   80104439 <cpuid>
80103b0f:	89 c3                	mov    %eax,%ebx
80103b11:	e8 23 09 00 00       	call   80104439 <cpuid>
80103b16:	83 ec 04             	sub    $0x4,%esp
80103b19:	53                   	push   %ebx
80103b1a:	50                   	push   %eax
80103b1b:	68 50 96 10 80       	push   $0x80109650
80103b20:	e8 f3 c8 ff ff       	call   80100418 <cprintf>
80103b25:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b28:	e8 6b 31 00 00       	call   80106c98 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b2d:	e8 26 09 00 00       	call   80104458 <mycpu>
80103b32:	05 a0 00 00 00       	add    $0xa0,%eax
80103b37:	83 ec 08             	sub    $0x8,%esp
80103b3a:	6a 01                	push   $0x1
80103b3c:	50                   	push   %eax
80103b3d:	e8 f6 fe ff ff       	call   80103a38 <xchg>
80103b42:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b45:	e8 03 11 00 00       	call   80104c4d <scheduler>

80103b4a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b4a:	f3 0f 1e fb          	endbr32 
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b54:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b5b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b60:	83 ec 04             	sub    $0x4,%esp
80103b63:	50                   	push   %eax
80103b64:	68 0c c5 10 80       	push   $0x8010c50c
80103b69:	ff 75 f0             	pushl  -0x10(%ebp)
80103b6c:	e8 b8 1a 00 00       	call   80105629 <memmove>
80103b71:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b74:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b7b:	eb 79                	jmp    80103bf6 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b7d:	e8 d6 08 00 00       	call   80104458 <mycpu>
80103b82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b85:	74 67                	je     80103bee <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b87:	e8 84 f2 ff ff       	call   80102e10 <kalloc>
80103b8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b92:	83 e8 04             	sub    $0x4,%eax
80103b95:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b98:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b9e:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba3:	83 e8 08             	sub    $0x8,%eax
80103ba6:	c7 00 e1 3a 10 80    	movl   $0x80103ae1,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103bac:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103bb1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bba:	83 e8 0c             	sub    $0xc,%eax
80103bbd:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcb:	0f b6 00             	movzbl (%eax),%eax
80103bce:	0f b6 c0             	movzbl %al,%eax
80103bd1:	83 ec 08             	sub    $0x8,%esp
80103bd4:	52                   	push   %edx
80103bd5:	50                   	push   %eax
80103bd6:	e8 17 f6 ff ff       	call   801031f2 <lapicstartap>
80103bdb:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103bde:	90                   	nop
80103bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103be8:	85 c0                	test   %eax,%eax
80103bea:	74 f3                	je     80103bdf <startothers+0x95>
80103bec:	eb 01                	jmp    80103bef <startothers+0xa5>
      continue;
80103bee:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bef:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bf6:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bfb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c01:	05 20 48 11 80       	add    $0x80114820,%eax
80103c06:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c09:	0f 82 6e ff ff ff    	jb     80103b7d <startothers+0x33>
      ;
  }
}
80103c0f:	90                   	nop
80103c10:	90                   	nop
80103c11:	c9                   	leave  
80103c12:	c3                   	ret    

80103c13 <inb>:
{
80103c13:	55                   	push   %ebp
80103c14:	89 e5                	mov    %esp,%ebp
80103c16:	83 ec 14             	sub    $0x14,%esp
80103c19:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c20:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c24:	89 c2                	mov    %eax,%edx
80103c26:	ec                   	in     (%dx),%al
80103c27:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c2a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c2e:	c9                   	leave  
80103c2f:	c3                   	ret    

80103c30 <outb>:
{
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	83 ec 08             	sub    $0x8,%esp
80103c36:	8b 45 08             	mov    0x8(%ebp),%eax
80103c39:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c3c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c40:	89 d0                	mov    %edx,%eax
80103c42:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c45:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c49:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c4d:	ee                   	out    %al,(%dx)
}
80103c4e:	90                   	nop
80103c4f:	c9                   	leave  
80103c50:	c3                   	ret    

80103c51 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c51:	f3 0f 1e fb          	endbr32 
80103c55:	55                   	push   %ebp
80103c56:	89 e5                	mov    %esp,%ebp
80103c58:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c5b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c69:	eb 15                	jmp    80103c80 <sum+0x2f>
    sum += addr[i];
80103c6b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	01 d0                	add    %edx,%eax
80103c73:	0f b6 00             	movzbl (%eax),%eax
80103c76:	0f b6 c0             	movzbl %al,%eax
80103c79:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c7c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c86:	7c e3                	jl     80103c6b <sum+0x1a>
  return sum;
80103c88:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c8b:	c9                   	leave  
80103c8c:	c3                   	ret    

80103c8d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c8d:	f3 0f 1e fb          	endbr32 
80103c91:	55                   	push   %ebp
80103c92:	89 e5                	mov    %esp,%ebp
80103c94:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c97:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9a:	05 00 00 00 80       	add    $0x80000000,%eax
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ca2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca8:	01 d0                	add    %edx,%eax
80103caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cb3:	eb 36                	jmp    80103ceb <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103cb5:	83 ec 04             	sub    $0x4,%esp
80103cb8:	6a 04                	push   $0x4
80103cba:	68 64 96 10 80       	push   $0x80109664
80103cbf:	ff 75 f4             	pushl  -0xc(%ebp)
80103cc2:	e8 06 19 00 00       	call   801055cd <memcmp>
80103cc7:	83 c4 10             	add    $0x10,%esp
80103cca:	85 c0                	test   %eax,%eax
80103ccc:	75 19                	jne    80103ce7 <mpsearch1+0x5a>
80103cce:	83 ec 08             	sub    $0x8,%esp
80103cd1:	6a 10                	push   $0x10
80103cd3:	ff 75 f4             	pushl  -0xc(%ebp)
80103cd6:	e8 76 ff ff ff       	call   80103c51 <sum>
80103cdb:	83 c4 10             	add    $0x10,%esp
80103cde:	84 c0                	test   %al,%al
80103ce0:	75 05                	jne    80103ce7 <mpsearch1+0x5a>
      return (struct mp*)p;
80103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce5:	eb 11                	jmp    80103cf8 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ce7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cf1:	72 c2                	jb     80103cb5 <mpsearch1+0x28>
  return 0;
80103cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cf8:	c9                   	leave  
80103cf9:	c3                   	ret    

80103cfa <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cfa:	f3 0f 1e fb          	endbr32 
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d04:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0e:	83 c0 0f             	add    $0xf,%eax
80103d11:	0f b6 00             	movzbl (%eax),%eax
80103d14:	0f b6 c0             	movzbl %al,%eax
80103d17:	c1 e0 08             	shl    $0x8,%eax
80103d1a:	89 c2                	mov    %eax,%edx
80103d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1f:	83 c0 0e             	add    $0xe,%eax
80103d22:	0f b6 00             	movzbl (%eax),%eax
80103d25:	0f b6 c0             	movzbl %al,%eax
80103d28:	09 d0                	or     %edx,%eax
80103d2a:	c1 e0 04             	shl    $0x4,%eax
80103d2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d34:	74 21                	je     80103d57 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d36:	83 ec 08             	sub    $0x8,%esp
80103d39:	68 00 04 00 00       	push   $0x400
80103d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80103d41:	e8 47 ff ff ff       	call   80103c8d <mpsearch1>
80103d46:	83 c4 10             	add    $0x10,%esp
80103d49:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d4c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d50:	74 51                	je     80103da3 <mpsearch+0xa9>
      return mp;
80103d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d55:	eb 61                	jmp    80103db8 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5a:	83 c0 14             	add    $0x14,%eax
80103d5d:	0f b6 00             	movzbl (%eax),%eax
80103d60:	0f b6 c0             	movzbl %al,%eax
80103d63:	c1 e0 08             	shl    $0x8,%eax
80103d66:	89 c2                	mov    %eax,%edx
80103d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6b:	83 c0 13             	add    $0x13,%eax
80103d6e:	0f b6 00             	movzbl (%eax),%eax
80103d71:	0f b6 c0             	movzbl %al,%eax
80103d74:	09 d0                	or     %edx,%eax
80103d76:	c1 e0 0a             	shl    $0xa,%eax
80103d79:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7f:	2d 00 04 00 00       	sub    $0x400,%eax
80103d84:	83 ec 08             	sub    $0x8,%esp
80103d87:	68 00 04 00 00       	push   $0x400
80103d8c:	50                   	push   %eax
80103d8d:	e8 fb fe ff ff       	call   80103c8d <mpsearch1>
80103d92:	83 c4 10             	add    $0x10,%esp
80103d95:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d98:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d9c:	74 05                	je     80103da3 <mpsearch+0xa9>
      return mp;
80103d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103da1:	eb 15                	jmp    80103db8 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103da3:	83 ec 08             	sub    $0x8,%esp
80103da6:	68 00 00 01 00       	push   $0x10000
80103dab:	68 00 00 0f 00       	push   $0xf0000
80103db0:	e8 d8 fe ff ff       	call   80103c8d <mpsearch1>
80103db5:	83 c4 10             	add    $0x10,%esp
}
80103db8:	c9                   	leave  
80103db9:	c3                   	ret    

80103dba <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103dba:	f3 0f 1e fb          	endbr32 
80103dbe:	55                   	push   %ebp
80103dbf:	89 e5                	mov    %esp,%ebp
80103dc1:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103dc4:	e8 31 ff ff ff       	call   80103cfa <mpsearch>
80103dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dd0:	74 0a                	je     80103ddc <mpconfig+0x22>
80103dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd5:	8b 40 04             	mov    0x4(%eax),%eax
80103dd8:	85 c0                	test   %eax,%eax
80103dda:	75 07                	jne    80103de3 <mpconfig+0x29>
    return 0;
80103ddc:	b8 00 00 00 00       	mov    $0x0,%eax
80103de1:	eb 7a                	jmp    80103e5d <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de6:	8b 40 04             	mov    0x4(%eax),%eax
80103de9:	05 00 00 00 80       	add    $0x80000000,%eax
80103dee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103df1:	83 ec 04             	sub    $0x4,%esp
80103df4:	6a 04                	push   $0x4
80103df6:	68 69 96 10 80       	push   $0x80109669
80103dfb:	ff 75 f0             	pushl  -0x10(%ebp)
80103dfe:	e8 ca 17 00 00       	call   801055cd <memcmp>
80103e03:	83 c4 10             	add    $0x10,%esp
80103e06:	85 c0                	test   %eax,%eax
80103e08:	74 07                	je     80103e11 <mpconfig+0x57>
    return 0;
80103e0a:	b8 00 00 00 00       	mov    $0x0,%eax
80103e0f:	eb 4c                	jmp    80103e5d <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e14:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e18:	3c 01                	cmp    $0x1,%al
80103e1a:	74 12                	je     80103e2e <mpconfig+0x74>
80103e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1f:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e23:	3c 04                	cmp    $0x4,%al
80103e25:	74 07                	je     80103e2e <mpconfig+0x74>
    return 0;
80103e27:	b8 00 00 00 00       	mov    $0x0,%eax
80103e2c:	eb 2f                	jmp    80103e5d <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e31:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e35:	0f b7 c0             	movzwl %ax,%eax
80103e38:	83 ec 08             	sub    $0x8,%esp
80103e3b:	50                   	push   %eax
80103e3c:	ff 75 f0             	pushl  -0x10(%ebp)
80103e3f:	e8 0d fe ff ff       	call   80103c51 <sum>
80103e44:	83 c4 10             	add    $0x10,%esp
80103e47:	84 c0                	test   %al,%al
80103e49:	74 07                	je     80103e52 <mpconfig+0x98>
    return 0;
80103e4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103e50:	eb 0b                	jmp    80103e5d <mpconfig+0xa3>
  *pmp = mp;
80103e52:	8b 45 08             	mov    0x8(%ebp),%eax
80103e55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e58:	89 10                	mov    %edx,(%eax)
  return conf;
80103e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e5d:	c9                   	leave  
80103e5e:	c3                   	ret    

80103e5f <mpinit>:

void
mpinit(void)
{
80103e5f:	f3 0f 1e fb          	endbr32 
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e69:	83 ec 0c             	sub    $0xc,%esp
80103e6c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e6f:	50                   	push   %eax
80103e70:	e8 45 ff ff ff       	call   80103dba <mpconfig>
80103e75:	83 c4 10             	add    $0x10,%esp
80103e78:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e7f:	75 0d                	jne    80103e8e <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e81:	83 ec 0c             	sub    $0xc,%esp
80103e84:	68 6e 96 10 80       	push   $0x8010966e
80103e89:	e8 7a c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e8e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e98:	8b 40 24             	mov    0x24(%eax),%eax
80103e9b:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea3:	83 c0 2c             	add    $0x2c,%eax
80103ea6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eac:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103eb0:	0f b7 d0             	movzwl %ax,%edx
80103eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eb6:	01 d0                	add    %edx,%eax
80103eb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ebb:	e9 8c 00 00 00       	jmp    80103f4c <mpinit+0xed>
    switch(*p){
80103ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec3:	0f b6 00             	movzbl (%eax),%eax
80103ec6:	0f b6 c0             	movzbl %al,%eax
80103ec9:	83 f8 04             	cmp    $0x4,%eax
80103ecc:	7f 76                	jg     80103f44 <mpinit+0xe5>
80103ece:	83 f8 03             	cmp    $0x3,%eax
80103ed1:	7d 6b                	jge    80103f3e <mpinit+0xdf>
80103ed3:	83 f8 02             	cmp    $0x2,%eax
80103ed6:	74 4e                	je     80103f26 <mpinit+0xc7>
80103ed8:	83 f8 02             	cmp    $0x2,%eax
80103edb:	7f 67                	jg     80103f44 <mpinit+0xe5>
80103edd:	85 c0                	test   %eax,%eax
80103edf:	74 07                	je     80103ee8 <mpinit+0x89>
80103ee1:	83 f8 01             	cmp    $0x1,%eax
80103ee4:	74 58                	je     80103f3e <mpinit+0xdf>
80103ee6:	eb 5c                	jmp    80103f44 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eee:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ef3:	83 f8 07             	cmp    $0x7,%eax
80103ef6:	7f 28                	jg     80103f20 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ef8:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f01:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f05:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f0b:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103f11:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f13:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f18:	83 c0 01             	add    $0x1,%eax
80103f1b:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103f20:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f24:	eb 26                	jmp    80103f4c <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f2f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f33:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f38:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f3c:	eb 0e                	jmp    80103f4c <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f3e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f42:	eb 08                	jmp    80103f4c <mpinit+0xed>
    default:
      ismp = 0;
80103f44:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f4b:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f52:	0f 82 68 ff ff ff    	jb     80103ec0 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f5c:	75 0d                	jne    80103f6b <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f5e:	83 ec 0c             	sub    $0xc,%esp
80103f61:	68 88 96 10 80       	push   $0x80109688
80103f66:	e8 9d c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f6e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f72:	84 c0                	test   %al,%al
80103f74:	74 30                	je     80103fa6 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f76:	83 ec 08             	sub    $0x8,%esp
80103f79:	6a 70                	push   $0x70
80103f7b:	6a 22                	push   $0x22
80103f7d:	e8 ae fc ff ff       	call   80103c30 <outb>
80103f82:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f85:	83 ec 0c             	sub    $0xc,%esp
80103f88:	6a 23                	push   $0x23
80103f8a:	e8 84 fc ff ff       	call   80103c13 <inb>
80103f8f:	83 c4 10             	add    $0x10,%esp
80103f92:	83 c8 01             	or     $0x1,%eax
80103f95:	0f b6 c0             	movzbl %al,%eax
80103f98:	83 ec 08             	sub    $0x8,%esp
80103f9b:	50                   	push   %eax
80103f9c:	6a 23                	push   $0x23
80103f9e:	e8 8d fc ff ff       	call   80103c30 <outb>
80103fa3:	83 c4 10             	add    $0x10,%esp
  }
}
80103fa6:	90                   	nop
80103fa7:	c9                   	leave  
80103fa8:	c3                   	ret    

80103fa9 <outb>:
{
80103fa9:	55                   	push   %ebp
80103faa:	89 e5                	mov    %esp,%ebp
80103fac:	83 ec 08             	sub    $0x8,%esp
80103faf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fb5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103fb9:	89 d0                	mov    %edx,%eax
80103fbb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fbe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fc2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103fc6:	ee                   	out    %al,(%dx)
}
80103fc7:	90                   	nop
80103fc8:	c9                   	leave  
80103fc9:	c3                   	ret    

80103fca <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103fca:	f3 0f 1e fb          	endbr32 
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fd1:	68 ff 00 00 00       	push   $0xff
80103fd6:	6a 21                	push   $0x21
80103fd8:	e8 cc ff ff ff       	call   80103fa9 <outb>
80103fdd:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fe0:	68 ff 00 00 00       	push   $0xff
80103fe5:	68 a1 00 00 00       	push   $0xa1
80103fea:	e8 ba ff ff ff       	call   80103fa9 <outb>
80103fef:	83 c4 08             	add    $0x8,%esp
}
80103ff2:	90                   	nop
80103ff3:	c9                   	leave  
80103ff4:	c3                   	ret    

80103ff5 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ff5:	f3 0f 1e fb          	endbr32 
80103ff9:	55                   	push   %ebp
80103ffa:	89 e5                	mov    %esp,%ebp
80103ffc:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104006:	8b 45 0c             	mov    0xc(%ebp),%eax
80104009:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010400f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104012:	8b 10                	mov    (%eax),%edx
80104014:	8b 45 08             	mov    0x8(%ebp),%eax
80104017:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104019:	e8 bc d0 ff ff       	call   801010da <filealloc>
8010401e:	8b 55 08             	mov    0x8(%ebp),%edx
80104021:	89 02                	mov    %eax,(%edx)
80104023:	8b 45 08             	mov    0x8(%ebp),%eax
80104026:	8b 00                	mov    (%eax),%eax
80104028:	85 c0                	test   %eax,%eax
8010402a:	0f 84 c8 00 00 00    	je     801040f8 <pipealloc+0x103>
80104030:	e8 a5 d0 ff ff       	call   801010da <filealloc>
80104035:	8b 55 0c             	mov    0xc(%ebp),%edx
80104038:	89 02                	mov    %eax,(%edx)
8010403a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	85 c0                	test   %eax,%eax
80104041:	0f 84 b1 00 00 00    	je     801040f8 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104047:	e8 c4 ed ff ff       	call   80102e10 <kalloc>
8010404c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010404f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104053:	0f 84 a2 00 00 00    	je     801040fb <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104063:	00 00 00 
  p->writeopen = 1;
80104066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104069:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104070:	00 00 00 
  p->nwrite = 0;
80104073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104076:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010407d:	00 00 00 
  p->nread = 0;
80104080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104083:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010408a:	00 00 00 
  initlock(&p->lock, "pipe");
8010408d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104090:	83 ec 08             	sub    $0x8,%esp
80104093:	68 a7 96 10 80       	push   $0x801096a7
80104098:	50                   	push   %eax
80104099:	e8 ff 11 00 00       	call   8010529d <initlock>
8010409e:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	8b 00                	mov    (%eax),%eax
801040a6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040ac:	8b 45 08             	mov    0x8(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040b5:	8b 45 08             	mov    0x8(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	8b 00                	mov    (%eax),%eax
801040c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c6:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d7:	8b 00                	mov    (%eax),%eax
801040d9:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e0:	8b 00                	mov    (%eax),%eax
801040e2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e9:	8b 00                	mov    (%eax),%eax
801040eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ee:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040f1:	b8 00 00 00 00       	mov    $0x0,%eax
801040f6:	eb 51                	jmp    80104149 <pipealloc+0x154>
    goto bad;
801040f8:	90                   	nop
801040f9:	eb 01                	jmp    801040fc <pipealloc+0x107>
    goto bad;
801040fb:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104100:	74 0e                	je     80104110 <pipealloc+0x11b>
    kfree((char*)p);
80104102:	83 ec 0c             	sub    $0xc,%esp
80104105:	ff 75 f4             	pushl  -0xc(%ebp)
80104108:	e8 65 ec ff ff       	call   80102d72 <kfree>
8010410d:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104110:	8b 45 08             	mov    0x8(%ebp),%eax
80104113:	8b 00                	mov    (%eax),%eax
80104115:	85 c0                	test   %eax,%eax
80104117:	74 11                	je     8010412a <pipealloc+0x135>
    fileclose(*f0);
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	8b 00                	mov    (%eax),%eax
8010411e:	83 ec 0c             	sub    $0xc,%esp
80104121:	50                   	push   %eax
80104122:	e8 79 d0 ff ff       	call   801011a0 <fileclose>
80104127:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010412a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412d:	8b 00                	mov    (%eax),%eax
8010412f:	85 c0                	test   %eax,%eax
80104131:	74 11                	je     80104144 <pipealloc+0x14f>
    fileclose(*f1);
80104133:	8b 45 0c             	mov    0xc(%ebp),%eax
80104136:	8b 00                	mov    (%eax),%eax
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	50                   	push   %eax
8010413c:	e8 5f d0 ff ff       	call   801011a0 <fileclose>
80104141:	83 c4 10             	add    $0x10,%esp
  return -1;
80104144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104149:	c9                   	leave  
8010414a:	c3                   	ret    

8010414b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010414b:	f3 0f 1e fb          	endbr32 
8010414f:	55                   	push   %ebp
80104150:	89 e5                	mov    %esp,%ebp
80104152:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	83 ec 0c             	sub    $0xc,%esp
8010415b:	50                   	push   %eax
8010415c:	e8 62 11 00 00       	call   801052c3 <acquire>
80104161:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104164:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104168:	74 23                	je     8010418d <pipeclose+0x42>
    p->writeopen = 0;
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104174:	00 00 00 
    wakeup(&p->nread);
80104177:	8b 45 08             	mov    0x8(%ebp),%eax
8010417a:	05 34 02 00 00       	add    $0x234,%eax
8010417f:	83 ec 0c             	sub    $0xc,%esp
80104182:	50                   	push   %eax
80104183:	e8 bb 0d 00 00       	call   80104f43 <wakeup>
80104188:	83 c4 10             	add    $0x10,%esp
8010418b:	eb 21                	jmp    801041ae <pipeclose+0x63>
  } else {
    p->readopen = 0;
8010418d:	8b 45 08             	mov    0x8(%ebp),%eax
80104190:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104197:	00 00 00 
    wakeup(&p->nwrite);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	05 38 02 00 00       	add    $0x238,%eax
801041a2:	83 ec 0c             	sub    $0xc,%esp
801041a5:	50                   	push   %eax
801041a6:	e8 98 0d 00 00       	call   80104f43 <wakeup>
801041ab:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041b7:	85 c0                	test   %eax,%eax
801041b9:	75 2c                	jne    801041e7 <pipeclose+0x9c>
801041bb:	8b 45 08             	mov    0x8(%ebp),%eax
801041be:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041c4:	85 c0                	test   %eax,%eax
801041c6:	75 1f                	jne    801041e7 <pipeclose+0x9c>
    release(&p->lock);
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	83 ec 0c             	sub    $0xc,%esp
801041ce:	50                   	push   %eax
801041cf:	e8 61 11 00 00       	call   80105335 <release>
801041d4:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041d7:	83 ec 0c             	sub    $0xc,%esp
801041da:	ff 75 08             	pushl  0x8(%ebp)
801041dd:	e8 90 eb ff ff       	call   80102d72 <kfree>
801041e2:	83 c4 10             	add    $0x10,%esp
801041e5:	eb 10                	jmp    801041f7 <pipeclose+0xac>
  } else
    release(&p->lock);
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	83 ec 0c             	sub    $0xc,%esp
801041ed:	50                   	push   %eax
801041ee:	e8 42 11 00 00       	call   80105335 <release>
801041f3:	83 c4 10             	add    $0x10,%esp
}
801041f6:	90                   	nop
801041f7:	90                   	nop
801041f8:	c9                   	leave  
801041f9:	c3                   	ret    

801041fa <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041fa:	f3 0f 1e fb          	endbr32 
801041fe:	55                   	push   %ebp
801041ff:	89 e5                	mov    %esp,%ebp
80104201:	53                   	push   %ebx
80104202:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104205:	8b 45 08             	mov    0x8(%ebp),%eax
80104208:	83 ec 0c             	sub    $0xc,%esp
8010420b:	50                   	push   %eax
8010420c:	e8 b2 10 00 00       	call   801052c3 <acquire>
80104211:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104214:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010421b:	e9 ad 00 00 00       	jmp    801042cd <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104220:	8b 45 08             	mov    0x8(%ebp),%eax
80104223:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104229:	85 c0                	test   %eax,%eax
8010422b:	74 0c                	je     80104239 <pipewrite+0x3f>
8010422d:	e8 a2 02 00 00       	call   801044d4 <myproc>
80104232:	8b 40 24             	mov    0x24(%eax),%eax
80104235:	85 c0                	test   %eax,%eax
80104237:	74 19                	je     80104252 <pipewrite+0x58>
        release(&p->lock);
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	83 ec 0c             	sub    $0xc,%esp
8010423f:	50                   	push   %eax
80104240:	e8 f0 10 00 00       	call   80105335 <release>
80104245:	83 c4 10             	add    $0x10,%esp
        return -1;
80104248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010424d:	e9 a9 00 00 00       	jmp    801042fb <pipewrite+0x101>
      }
      wakeup(&p->nread);
80104252:	8b 45 08             	mov    0x8(%ebp),%eax
80104255:	05 34 02 00 00       	add    $0x234,%eax
8010425a:	83 ec 0c             	sub    $0xc,%esp
8010425d:	50                   	push   %eax
8010425e:	e8 e0 0c 00 00       	call   80104f43 <wakeup>
80104263:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	8b 55 08             	mov    0x8(%ebp),%edx
8010426c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104272:	83 ec 08             	sub    $0x8,%esp
80104275:	50                   	push   %eax
80104276:	52                   	push   %edx
80104277:	e8 d5 0b 00 00       	call   80104e51 <sleep>
8010427c:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010427f:	8b 45 08             	mov    0x8(%ebp),%eax
80104282:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104288:	8b 45 08             	mov    0x8(%ebp),%eax
8010428b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104291:	05 00 02 00 00       	add    $0x200,%eax
80104296:	39 c2                	cmp    %eax,%edx
80104298:	74 86                	je     80104220 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010429a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010429d:	8b 45 0c             	mov    0xc(%ebp),%eax
801042a0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042a3:	8b 45 08             	mov    0x8(%ebp),%eax
801042a6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042ac:	8d 48 01             	lea    0x1(%eax),%ecx
801042af:	8b 55 08             	mov    0x8(%ebp),%edx
801042b2:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042b8:	25 ff 01 00 00       	and    $0x1ff,%eax
801042bd:	89 c1                	mov    %eax,%ecx
801042bf:	0f b6 13             	movzbl (%ebx),%edx
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801042c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	3b 45 10             	cmp    0x10(%ebp),%eax
801042d3:	7c aa                	jl     8010427f <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	05 34 02 00 00       	add    $0x234,%eax
801042dd:	83 ec 0c             	sub    $0xc,%esp
801042e0:	50                   	push   %eax
801042e1:	e8 5d 0c 00 00       	call   80104f43 <wakeup>
801042e6:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042e9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ec:	83 ec 0c             	sub    $0xc,%esp
801042ef:	50                   	push   %eax
801042f0:	e8 40 10 00 00       	call   80105335 <release>
801042f5:	83 c4 10             	add    $0x10,%esp
  return n;
801042f8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042fe:	c9                   	leave  
801042ff:	c3                   	ret    

80104300 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104300:	f3 0f 1e fb          	endbr32 
80104304:	55                   	push   %ebp
80104305:	89 e5                	mov    %esp,%ebp
80104307:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010430a:	8b 45 08             	mov    0x8(%ebp),%eax
8010430d:	83 ec 0c             	sub    $0xc,%esp
80104310:	50                   	push   %eax
80104311:	e8 ad 0f 00 00       	call   801052c3 <acquire>
80104316:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104319:	eb 3e                	jmp    80104359 <piperead+0x59>
    if(myproc()->killed){
8010431b:	e8 b4 01 00 00       	call   801044d4 <myproc>
80104320:	8b 40 24             	mov    0x24(%eax),%eax
80104323:	85 c0                	test   %eax,%eax
80104325:	74 19                	je     80104340 <piperead+0x40>
      release(&p->lock);
80104327:	8b 45 08             	mov    0x8(%ebp),%eax
8010432a:	83 ec 0c             	sub    $0xc,%esp
8010432d:	50                   	push   %eax
8010432e:	e8 02 10 00 00       	call   80105335 <release>
80104333:	83 c4 10             	add    $0x10,%esp
      return -1;
80104336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010433b:	e9 be 00 00 00       	jmp    801043fe <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104340:	8b 45 08             	mov    0x8(%ebp),%eax
80104343:	8b 55 08             	mov    0x8(%ebp),%edx
80104346:	81 c2 34 02 00 00    	add    $0x234,%edx
8010434c:	83 ec 08             	sub    $0x8,%esp
8010434f:	50                   	push   %eax
80104350:	52                   	push   %edx
80104351:	e8 fb 0a 00 00       	call   80104e51 <sleep>
80104356:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104359:	8b 45 08             	mov    0x8(%ebp),%eax
8010435c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104362:	8b 45 08             	mov    0x8(%ebp),%eax
80104365:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010436b:	39 c2                	cmp    %eax,%edx
8010436d:	75 0d                	jne    8010437c <piperead+0x7c>
8010436f:	8b 45 08             	mov    0x8(%ebp),%eax
80104372:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104378:	85 c0                	test   %eax,%eax
8010437a:	75 9f                	jne    8010431b <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010437c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104383:	eb 48                	jmp    801043cd <piperead+0xcd>
    if(p->nread == p->nwrite)
80104385:	8b 45 08             	mov    0x8(%ebp),%eax
80104388:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104397:	39 c2                	cmp    %eax,%edx
80104399:	74 3c                	je     801043d7 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010439b:	8b 45 08             	mov    0x8(%ebp),%eax
8010439e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043a4:	8d 48 01             	lea    0x1(%eax),%ecx
801043a7:	8b 55 08             	mov    0x8(%ebp),%edx
801043aa:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043b0:	25 ff 01 00 00       	and    $0x1ff,%eax
801043b5:	89 c1                	mov    %eax,%ecx
801043b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801043bd:	01 c2                	add    %eax,%edx
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801043c7:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d0:	3b 45 10             	cmp    0x10(%ebp),%eax
801043d3:	7c b0                	jl     80104385 <piperead+0x85>
801043d5:	eb 01                	jmp    801043d8 <piperead+0xd8>
      break;
801043d7:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043d8:	8b 45 08             	mov    0x8(%ebp),%eax
801043db:	05 38 02 00 00       	add    $0x238,%eax
801043e0:	83 ec 0c             	sub    $0xc,%esp
801043e3:	50                   	push   %eax
801043e4:	e8 5a 0b 00 00       	call   80104f43 <wakeup>
801043e9:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043ec:	8b 45 08             	mov    0x8(%ebp),%eax
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	50                   	push   %eax
801043f3:	e8 3d 0f 00 00       	call   80105335 <release>
801043f8:	83 c4 10             	add    $0x10,%esp
  return i;
801043fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043fe:	c9                   	leave  
801043ff:	c3                   	ret    

80104400 <readeflags>:
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104406:	9c                   	pushf  
80104407:	58                   	pop    %eax
80104408:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010440b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010440e:	c9                   	leave  
8010440f:	c3                   	ret    

80104410 <sti>:
{
80104410:	55                   	push   %ebp
80104411:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104413:	fb                   	sti    
}
80104414:	90                   	nop
80104415:	5d                   	pop    %ebp
80104416:	c3                   	ret    

80104417 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104417:	f3 0f 1e fb          	endbr32 
8010441b:	55                   	push   %ebp
8010441c:	89 e5                	mov    %esp,%ebp
8010441e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104421:	83 ec 08             	sub    $0x8,%esp
80104424:	68 ac 96 10 80       	push   $0x801096ac
80104429:	68 c0 4d 11 80       	push   $0x80114dc0
8010442e:	e8 6a 0e 00 00       	call   8010529d <initlock>
80104433:	83 c4 10             	add    $0x10,%esp
}
80104436:	90                   	nop
80104437:	c9                   	leave  
80104438:	c3                   	ret    

80104439 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104439:	f3 0f 1e fb          	endbr32 
8010443d:	55                   	push   %ebp
8010443e:	89 e5                	mov    %esp,%ebp
80104440:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104443:	e8 10 00 00 00       	call   80104458 <mycpu>
80104448:	2d 20 48 11 80       	sub    $0x80114820,%eax
8010444d:	c1 f8 04             	sar    $0x4,%eax
80104450:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104456:	c9                   	leave  
80104457:	c3                   	ret    

80104458 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104458:	f3 0f 1e fb          	endbr32 
8010445c:	55                   	push   %ebp
8010445d:	89 e5                	mov    %esp,%ebp
8010445f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104462:	e8 99 ff ff ff       	call   80104400 <readeflags>
80104467:	25 00 02 00 00       	and    $0x200,%eax
8010446c:	85 c0                	test   %eax,%eax
8010446e:	74 0d                	je     8010447d <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80104470:	83 ec 0c             	sub    $0xc,%esp
80104473:	68 b4 96 10 80       	push   $0x801096b4
80104478:	e8 8b c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
8010447d:	e8 21 ed ff ff       	call   801031a3 <lapicid>
80104482:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104485:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010448c:	eb 2d                	jmp    801044bb <mycpu+0x63>
    if (cpus[i].apicid == apicid)
8010448e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104491:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104497:	05 20 48 11 80       	add    $0x80114820,%eax
8010449c:	0f b6 00             	movzbl (%eax),%eax
8010449f:	0f b6 c0             	movzbl %al,%eax
801044a2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044a5:	75 10                	jne    801044b7 <mycpu+0x5f>
      return &cpus[i];
801044a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044aa:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044b0:	05 20 48 11 80       	add    $0x80114820,%eax
801044b5:	eb 1b                	jmp    801044d2 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044bb:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801044c0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044c3:	7c c9                	jl     8010448e <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044c5:	83 ec 0c             	sub    $0xc,%esp
801044c8:	68 da 96 10 80       	push   $0x801096da
801044cd:	e8 36 c1 ff ff       	call   80100608 <panic>
}
801044d2:	c9                   	leave  
801044d3:	c3                   	ret    

801044d4 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044d4:	f3 0f 1e fb          	endbr32 
801044d8:	55                   	push   %ebp
801044d9:	89 e5                	mov    %esp,%ebp
801044db:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044de:	e8 6c 0f 00 00       	call   8010544f <pushcli>
  c = mycpu();
801044e3:	e8 70 ff ff ff       	call   80104458 <mycpu>
801044e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ee:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044f7:	e8 a4 0f 00 00       	call   801054a0 <popcli>
  return p;
801044fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044ff:	c9                   	leave  
80104500:	c3                   	ret    

80104501 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104501:	f3 0f 1e fb          	endbr32 
80104505:	55                   	push   %ebp
80104506:	89 e5                	mov    %esp,%ebp
80104508:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	68 c0 4d 11 80       	push   $0x80114dc0
80104513:	e8 ab 0d 00 00       	call   801052c3 <acquire>
80104518:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010451b:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104522:	eb 11                	jmp    80104535 <allocproc+0x34>
    if(p->state == UNUSED)
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 0c             	mov    0xc(%eax),%eax
8010452a:	85 c0                	test   %eax,%eax
8010452c:	74 2a                	je     80104558 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010452e:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104535:	81 7d f4 f4 7d 11 80 	cmpl   $0x80117df4,-0xc(%ebp)
8010453c:	72 e6                	jb     80104524 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010453e:	83 ec 0c             	sub    $0xc,%esp
80104541:	68 c0 4d 11 80       	push   $0x80114dc0
80104546:	e8 ea 0d 00 00       	call   80105335 <release>
8010454b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010454e:	b8 00 00 00 00       	mov    $0x0,%eax
80104553:	e9 ea 00 00 00       	jmp    80104642 <allocproc+0x141>
      goto found;
80104558:	90                   	nop
80104559:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
8010455d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104560:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104567:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010456c:	8d 50 01             	lea    0x1(%eax),%edx
8010456f:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104578:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	68 c0 4d 11 80       	push   $0x80114dc0
80104583:	e8 ad 0d 00 00       	call   80105335 <release>
80104588:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010458b:	e8 80 e8 ff ff       	call   80102e10 <kalloc>
80104590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104593:	89 42 08             	mov    %eax,0x8(%edx)
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 08             	mov    0x8(%eax),%eax
8010459c:	85 c0                	test   %eax,%eax
8010459e:	75 14                	jne    801045b4 <allocproc+0xb3>
    p->state = UNUSED;
801045a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045aa:	b8 00 00 00 00       	mov    $0x0,%eax
801045af:	e9 8e 00 00 00       	jmp    80104642 <allocproc+0x141>
  }
  sp = p->kstack + KSTACKSIZE;
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8b 40 08             	mov    0x8(%eax),%eax
801045ba:	05 00 10 00 00       	add    $0x1000,%eax
801045bf:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045c2:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
801045c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801045cc:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045cf:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
801045d3:	ba d8 6a 10 80       	mov    $0x80106ad8,%edx
801045d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045db:	89 10                	mov    %edx,(%eax)

  p->clockIndex  =-1;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	c7 80 bc 00 00 00 ff 	movl   $0xffffffff,0xbc(%eax)
801045e7:	ff ff ff 
  for (int i = 0; i < CLOCKSIZE; i++) {
801045ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045f1:	eb 15                	jmp    80104608 <allocproc+0x107>
    p->clockQueue[i].vpn = -1;
801045f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045f9:	83 c2 0e             	add    $0xe,%edx
801045fc:	c7 44 d0 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,8)
80104603:	ff 
  for (int i = 0; i < CLOCKSIZE; i++) {
80104604:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104608:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
8010460c:	7e e5                	jle    801045f3 <allocproc+0xf2>
    //p->clockQueue[i].pte = -1;
  }

  sp -= sizeof *p->context;
8010460e:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104615:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104618:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010461b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104621:	83 ec 04             	sub    $0x4,%esp
80104624:	6a 14                	push   $0x14
80104626:	6a 00                	push   $0x0
80104628:	50                   	push   %eax
80104629:	e8 34 0f 00 00       	call   80105562 <memset>
8010462e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104634:	8b 40 1c             	mov    0x1c(%eax),%eax
80104637:	ba 07 4e 10 80       	mov    $0x80104e07,%edx
8010463c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104642:	c9                   	leave  
80104643:	c3                   	ret    

80104644 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104644:	f3 0f 1e fb          	endbr32 
80104648:	55                   	push   %ebp
80104649:	89 e5                	mov    %esp,%ebp
8010464b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010464e:	e8 ae fe ff ff       	call   80104501 <allocproc>
80104653:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104659:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
8010465e:	e8 40 3a 00 00       	call   801080a3 <setupkvm>
80104663:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104666:	89 42 04             	mov    %eax,0x4(%edx)
80104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466c:	8b 40 04             	mov    0x4(%eax),%eax
8010466f:	85 c0                	test   %eax,%eax
80104671:	75 0d                	jne    80104680 <userinit+0x3c>
    panic("userinit: out of memory?");
80104673:	83 ec 0c             	sub    $0xc,%esp
80104676:	68 ea 96 10 80       	push   $0x801096ea
8010467b:	e8 88 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104680:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104688:	8b 40 04             	mov    0x4(%eax),%eax
8010468b:	83 ec 04             	sub    $0x4,%esp
8010468e:	52                   	push   %edx
8010468f:	68 e0 c4 10 80       	push   $0x8010c4e0
80104694:	50                   	push   %eax
80104695:	e8 82 3c 00 00       	call   8010831c <inituvm>
8010469a:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010469d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a9:	8b 40 18             	mov    0x18(%eax),%eax
801046ac:	83 ec 04             	sub    $0x4,%esp
801046af:	6a 4c                	push   $0x4c
801046b1:	6a 00                	push   $0x0
801046b3:	50                   	push   %eax
801046b4:	e8 a9 0e 00 00       	call   80105562 <memset>
801046b9:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	8b 40 18             	mov    0x18(%eax),%eax
801046c2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	8b 40 18             	mov    0x18(%eax),%eax
801046ce:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	8b 50 18             	mov    0x18(%eax),%edx
801046da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dd:	8b 40 18             	mov    0x18(%eax),%eax
801046e0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046e4:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046eb:	8b 50 18             	mov    0x18(%eax),%edx
801046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f1:	8b 40 18             	mov    0x18(%eax),%eax
801046f4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046f8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	8b 40 18             	mov    0x18(%eax),%eax
80104702:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	8b 40 18             	mov    0x18(%eax),%eax
8010470f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104719:	8b 40 18             	mov    0x18(%eax),%eax
8010471c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	83 c0 6c             	add    $0x6c,%eax
80104729:	83 ec 04             	sub    $0x4,%esp
8010472c:	6a 10                	push   $0x10
8010472e:	68 03 97 10 80       	push   $0x80109703
80104733:	50                   	push   %eax
80104734:	e8 44 10 00 00       	call   8010577d <safestrcpy>
80104739:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010473c:	83 ec 0c             	sub    $0xc,%esp
8010473f:	68 0c 97 10 80       	push   $0x8010970c
80104744:	e8 42 df ff ff       	call   8010268b <namei>
80104749:	83 c4 10             	add    $0x10,%esp
8010474c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010474f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	68 c0 4d 11 80       	push   $0x80114dc0
8010475a:	e8 64 0b 00 00       	call   801052c3 <acquire>
8010475f:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104765:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010476c:	83 ec 0c             	sub    $0xc,%esp
8010476f:	68 c0 4d 11 80       	push   $0x80114dc0
80104774:	e8 bc 0b 00 00       	call   80105335 <release>
80104779:	83 c4 10             	add    $0x10,%esp
}
8010477c:	90                   	nop
8010477d:	c9                   	leave  
8010477e:	c3                   	ret    

8010477f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010477f:	f3 0f 1e fb          	endbr32 
80104783:	55                   	push   %ebp
80104784:	89 e5                	mov    %esp,%ebp
80104786:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104789:	e8 46 fd ff ff       	call   801044d4 <myproc>
8010478e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104794:	8b 00                	mov    (%eax),%eax
80104796:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104799:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010479d:	7e 2e                	jle    801047cd <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010479f:	8b 55 08             	mov    0x8(%ebp),%edx
801047a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a5:	01 c2                	add    %eax,%edx
801047a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047aa:	8b 40 04             	mov    0x4(%eax),%eax
801047ad:	83 ec 04             	sub    $0x4,%esp
801047b0:	52                   	push   %edx
801047b1:	ff 75 f4             	pushl  -0xc(%ebp)
801047b4:	50                   	push   %eax
801047b5:	e8 a7 3c 00 00       	call   80108461 <allocuvm>
801047ba:	83 c4 10             	add    $0x10,%esp
801047bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047c4:	75 3b                	jne    80104801 <growproc+0x82>
      return -1;
801047c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047cb:	eb 4f                	jmp    8010481c <growproc+0x9d>
  } else if(n < 0){
801047cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047d1:	79 2e                	jns    80104801 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047d3:	8b 55 08             	mov    0x8(%ebp),%edx
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	01 c2                	add    %eax,%edx
801047db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047de:	8b 40 04             	mov    0x4(%eax),%eax
801047e1:	83 ec 04             	sub    $0x4,%esp
801047e4:	52                   	push   %edx
801047e5:	ff 75 f4             	pushl  -0xc(%ebp)
801047e8:	50                   	push   %eax
801047e9:	e8 7c 3d 00 00       	call   8010856a <deallocuvm>
801047ee:	83 c4 10             	add    $0x10,%esp
801047f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047f8:	75 07                	jne    80104801 <growproc+0x82>
      return -1;
801047fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ff:	eb 1b                	jmp    8010481c <growproc+0x9d>
  }
  curproc->sz = sz;
80104801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104804:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104807:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104809:	83 ec 0c             	sub    $0xc,%esp
8010480c:	ff 75 f0             	pushl  -0x10(%ebp)
8010480f:	e8 65 39 00 00       	call   80108179 <switchuvm>
80104814:	83 c4 10             	add    $0x10,%esp
  return 0;
80104817:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010481c:	c9                   	leave  
8010481d:	c3                   	ret    

8010481e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010481e:	f3 0f 1e fb          	endbr32 
80104822:	55                   	push   %ebp
80104823:	89 e5                	mov    %esp,%ebp
80104825:	57                   	push   %edi
80104826:	56                   	push   %esi
80104827:	53                   	push   %ebx
80104828:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010482b:	e8 a4 fc ff ff       	call   801044d4 <myproc>
80104830:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104833:	e8 c9 fc ff ff       	call   80104501 <allocproc>
80104838:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010483b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010483f:	75 0a                	jne    8010484b <fork+0x2d>
    return -1;
80104841:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104846:	e9 ac 01 00 00       	jmp    801049f7 <fork+0x1d9>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010484b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484e:	8b 10                	mov    (%eax),%edx
80104850:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104853:	8b 40 04             	mov    0x4(%eax),%eax
80104856:	83 ec 08             	sub    $0x8,%esp
80104859:	52                   	push   %edx
8010485a:	50                   	push   %eax
8010485b:	e8 b8 3e 00 00       	call   80108718 <copyuvm>
80104860:	83 c4 10             	add    $0x10,%esp
80104863:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104866:	89 42 04             	mov    %eax,0x4(%edx)
80104869:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010486c:	8b 40 04             	mov    0x4(%eax),%eax
8010486f:	85 c0                	test   %eax,%eax
80104871:	75 30                	jne    801048a3 <fork+0x85>
    kfree(np->kstack);
80104873:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104876:	8b 40 08             	mov    0x8(%eax),%eax
80104879:	83 ec 0c             	sub    $0xc,%esp
8010487c:	50                   	push   %eax
8010487d:	e8 f0 e4 ff ff       	call   80102d72 <kfree>
80104882:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104885:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104888:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010488f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104892:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104899:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010489e:	e9 54 01 00 00       	jmp    801049f7 <fork+0x1d9>
  }
  np->sz = curproc->sz;
801048a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a6:	8b 10                	mov    (%eax),%edx
801048a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ab:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048b3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b9:	8b 48 18             	mov    0x18(%eax),%ecx
801048bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bf:	8b 40 18             	mov    0x18(%eax),%eax
801048c2:	89 c2                	mov    %eax,%edx
801048c4:	89 cb                	mov    %ecx,%ebx
801048c6:	b8 13 00 00 00       	mov    $0x13,%eax
801048cb:	89 d7                	mov    %edx,%edi
801048cd:	89 de                	mov    %ebx,%esi
801048cf:	89 c1                	mov    %eax,%ecx
801048d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d6:	8b 40 18             	mov    0x18(%eax),%eax
801048d9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048e7:	eb 3b                	jmp    80104924 <fork+0x106>
    if(curproc->ofile[i])
801048e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048ef:	83 c2 08             	add    $0x8,%edx
801048f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048f6:	85 c0                	test   %eax,%eax
801048f8:	74 26                	je     80104920 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104900:	83 c2 08             	add    $0x8,%edx
80104903:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104907:	83 ec 0c             	sub    $0xc,%esp
8010490a:	50                   	push   %eax
8010490b:	e8 3b c8 ff ff       	call   8010114b <filedup>
80104910:	83 c4 10             	add    $0x10,%esp
80104913:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104916:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104919:	83 c1 08             	add    $0x8,%ecx
8010491c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104920:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104924:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104928:	7e bf                	jle    801048e9 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
8010492a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492d:	8b 40 68             	mov    0x68(%eax),%eax
80104930:	83 ec 0c             	sub    $0xc,%esp
80104933:	50                   	push   %eax
80104934:	e8 a9 d1 ff ff       	call   80101ae2 <idup>
80104939:	83 c4 10             	add    $0x10,%esp
8010493c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010493f:	89 42 68             	mov    %eax,0x68(%edx)

   pte_t *pte;
  for(i = 0; i < CLOCKSIZE; i++){
80104942:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104949:	eb 55                	jmp    801049a0 <fork+0x182>
    //Might need to walkpagedir here
    pte = walkpgdir(np->pgdir, (char*)curproc->clockQueue[i].vpn, 0);
8010494b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104951:	83 c2 0e             	add    $0xe,%edx
80104954:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80104958:	89 c2                	mov    %eax,%edx
8010495a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010495d:	8b 40 04             	mov    0x4(%eax),%eax
80104960:	83 ec 04             	sub    $0x4,%esp
80104963:	6a 00                	push   $0x0
80104965:	52                   	push   %edx
80104966:	50                   	push   %eax
80104967:	e8 e6 35 00 00       	call   80107f52 <walkpgdir>
8010496c:	83 c4 10             	add    $0x10,%esp
8010496f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    np->clockQueue[i].pte = pte;
80104972:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104975:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104978:	8d 4a 0e             	lea    0xe(%edx),%ecx
8010497b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010497e:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    np->clockQueue[i].vpn = curproc->clockQueue[i].vpn;
80104982:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104985:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104988:	83 c2 0e             	add    $0xe,%edx
8010498b:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
8010498f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104992:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104995:	83 c1 0e             	add    $0xe,%ecx
80104998:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
  for(i = 0; i < CLOCKSIZE; i++){
8010499c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801049a0:	83 7d e4 07          	cmpl   $0x7,-0x1c(%ebp)
801049a4:	7e a5                	jle    8010494b <fork+0x12d>
  }

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a9:	8d 50 6c             	lea    0x6c(%eax),%edx
801049ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049af:	83 c0 6c             	add    $0x6c,%eax
801049b2:	83 ec 04             	sub    $0x4,%esp
801049b5:	6a 10                	push   $0x10
801049b7:	52                   	push   %edx
801049b8:	50                   	push   %eax
801049b9:	e8 bf 0d 00 00       	call   8010577d <safestrcpy>
801049be:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049c4:	8b 40 10             	mov    0x10(%eax),%eax
801049c7:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049ca:	83 ec 0c             	sub    $0xc,%esp
801049cd:	68 c0 4d 11 80       	push   $0x80114dc0
801049d2:	e8 ec 08 00 00       	call   801052c3 <acquire>
801049d7:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049dd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049e4:	83 ec 0c             	sub    $0xc,%esp
801049e7:	68 c0 4d 11 80       	push   $0x80114dc0
801049ec:	e8 44 09 00 00       	call   80105335 <release>
801049f1:	83 c4 10             	add    $0x10,%esp

  return pid;
801049f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049fa:	5b                   	pop    %ebx
801049fb:	5e                   	pop    %esi
801049fc:	5f                   	pop    %edi
801049fd:	5d                   	pop    %ebp
801049fe:	c3                   	ret    

801049ff <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049ff:	f3 0f 1e fb          	endbr32 
80104a03:	55                   	push   %ebp
80104a04:	89 e5                	mov    %esp,%ebp
80104a06:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a09:	e8 c6 fa ff ff       	call   801044d4 <myproc>
80104a0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a11:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a16:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a19:	75 0d                	jne    80104a28 <exit+0x29>
    panic("init exiting");
80104a1b:	83 ec 0c             	sub    $0xc,%esp
80104a1e:	68 0e 97 10 80       	push   $0x8010970e
80104a23:	e8 e0 bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a2f:	eb 3f                	jmp    80104a70 <exit+0x71>
    if(curproc->ofile[fd]){
80104a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a37:	83 c2 08             	add    $0x8,%edx
80104a3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a3e:	85 c0                	test   %eax,%eax
80104a40:	74 2a                	je     80104a6c <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a48:	83 c2 08             	add    $0x8,%edx
80104a4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	50                   	push   %eax
80104a53:	e8 48 c7 ff ff       	call   801011a0 <fileclose>
80104a58:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a61:	83 c2 08             	add    $0x8,%edx
80104a64:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a6b:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a6c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a70:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a74:	7e bb                	jle    80104a31 <exit+0x32>
    }
  }

  begin_op();
80104a76:	e8 9a ec ff ff       	call   80103715 <begin_op>
  iput(curproc->cwd);
80104a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a7e:	8b 40 68             	mov    0x68(%eax),%eax
80104a81:	83 ec 0c             	sub    $0xc,%esp
80104a84:	50                   	push   %eax
80104a85:	e8 ff d1 ff ff       	call   80101c89 <iput>
80104a8a:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a8d:	e8 13 ed ff ff       	call   801037a5 <end_op>
  curproc->cwd = 0;
80104a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a95:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a9c:	83 ec 0c             	sub    $0xc,%esp
80104a9f:	68 c0 4d 11 80       	push   $0x80114dc0
80104aa4:	e8 1a 08 00 00       	call   801052c3 <acquire>
80104aa9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aaf:	8b 40 14             	mov    0x14(%eax),%eax
80104ab2:	83 ec 0c             	sub    $0xc,%esp
80104ab5:	50                   	push   %eax
80104ab6:	e8 41 04 00 00       	call   80104efc <wakeup1>
80104abb:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abe:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ac5:	eb 3a                	jmp    80104b01 <exit+0x102>
    if(p->parent == curproc){
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 14             	mov    0x14(%eax),%eax
80104acd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ad0:	75 28                	jne    80104afa <exit+0xfb>
      p->parent = initproc;
80104ad2:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ae4:	83 f8 05             	cmp    $0x5,%eax
80104ae7:	75 11                	jne    80104afa <exit+0xfb>
        wakeup1(initproc);
80104ae9:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104aee:	83 ec 0c             	sub    $0xc,%esp
80104af1:	50                   	push   %eax
80104af2:	e8 05 04 00 00       	call   80104efc <wakeup1>
80104af7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104afa:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104b01:	81 7d f4 f4 7d 11 80 	cmpl   $0x80117df4,-0xc(%ebp)
80104b08:	72 bd                	jb     80104ac7 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b0d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b14:	e8 f3 01 00 00       	call   80104d0c <sched>
  panic("zombie exit");
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	68 1b 97 10 80       	push   $0x8010971b
80104b21:	e8 e2 ba ff ff       	call   80100608 <panic>

80104b26 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b26:	f3 0f 1e fb          	endbr32 
80104b2a:	55                   	push   %ebp
80104b2b:	89 e5                	mov    %esp,%ebp
80104b2d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b30:	e8 9f f9 ff ff       	call   801044d4 <myproc>
80104b35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b38:	83 ec 0c             	sub    $0xc,%esp
80104b3b:	68 c0 4d 11 80       	push   $0x80114dc0
80104b40:	e8 7e 07 00 00       	call   801052c3 <acquire>
80104b45:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b4f:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b56:	e9 a4 00 00 00       	jmp    80104bff <wait+0xd9>
      if(p->parent != curproc)
80104b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5e:	8b 40 14             	mov    0x14(%eax),%eax
80104b61:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b64:	0f 85 8d 00 00 00    	jne    80104bf7 <wait+0xd1>
        continue;
      havekids = 1;
80104b6a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b74:	8b 40 0c             	mov    0xc(%eax),%eax
80104b77:	83 f8 05             	cmp    $0x5,%eax
80104b7a:	75 7c                	jne    80104bf8 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7f:	8b 40 10             	mov    0x10(%eax),%eax
80104b82:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b88:	8b 40 08             	mov    0x8(%eax),%eax
80104b8b:	83 ec 0c             	sub    $0xc,%esp
80104b8e:	50                   	push   %eax
80104b8f:	e8 de e1 ff ff       	call   80102d72 <kfree>
80104b94:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	8b 40 04             	mov    0x4(%eax),%eax
80104ba7:	83 ec 0c             	sub    $0xc,%esp
80104baa:	50                   	push   %eax
80104bab:	e8 84 3a 00 00       	call   80108634 <freevm>
80104bb0:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104be2:	83 ec 0c             	sub    $0xc,%esp
80104be5:	68 c0 4d 11 80       	push   $0x80114dc0
80104bea:	e8 46 07 00 00       	call   80105335 <release>
80104bef:	83 c4 10             	add    $0x10,%esp
        return pid;
80104bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bf5:	eb 54                	jmp    80104c4b <wait+0x125>
        continue;
80104bf7:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bf8:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104bff:	81 7d f4 f4 7d 11 80 	cmpl   $0x80117df4,-0xc(%ebp)
80104c06:	0f 82 4f ff ff ff    	jb     80104b5b <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c10:	74 0a                	je     80104c1c <wait+0xf6>
80104c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c15:	8b 40 24             	mov    0x24(%eax),%eax
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	74 17                	je     80104c33 <wait+0x10d>
      release(&ptable.lock);
80104c1c:	83 ec 0c             	sub    $0xc,%esp
80104c1f:	68 c0 4d 11 80       	push   $0x80114dc0
80104c24:	e8 0c 07 00 00       	call   80105335 <release>
80104c29:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c31:	eb 18                	jmp    80104c4b <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c33:	83 ec 08             	sub    $0x8,%esp
80104c36:	68 c0 4d 11 80       	push   $0x80114dc0
80104c3b:	ff 75 ec             	pushl  -0x14(%ebp)
80104c3e:	e8 0e 02 00 00       	call   80104e51 <sleep>
80104c43:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c46:	e9 fd fe ff ff       	jmp    80104b48 <wait+0x22>
  }
}
80104c4b:	c9                   	leave  
80104c4c:	c3                   	ret    

80104c4d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c4d:	f3 0f 1e fb          	endbr32 
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c57:	e8 fc f7 ff ff       	call   80104458 <mycpu>
80104c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c62:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c69:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c6c:	e8 9f f7 ff ff       	call   80104410 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	68 c0 4d 11 80       	push   $0x80114dc0
80104c79:	e8 45 06 00 00       	call   801052c3 <acquire>
80104c7e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c81:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c88:	eb 64                	jmp    80104cee <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c90:	83 f8 03             	cmp    $0x3,%eax
80104c93:	75 51                	jne    80104ce6 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c9b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104ca1:	83 ec 0c             	sub    $0xc,%esp
80104ca4:	ff 75 f4             	pushl  -0xc(%ebp)
80104ca7:	e8 cd 34 00 00       	call   80108179 <switchuvm>
80104cac:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbc:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cbf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cc2:	83 c2 04             	add    $0x4,%edx
80104cc5:	83 ec 08             	sub    $0x8,%esp
80104cc8:	50                   	push   %eax
80104cc9:	52                   	push   %edx
80104cca:	e8 27 0b 00 00       	call   801057f6 <swtch>
80104ccf:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104cd2:	e8 85 34 00 00       	call   8010815c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cda:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ce1:	00 00 00 
80104ce4:	eb 01                	jmp    80104ce7 <scheduler+0x9a>
        continue;
80104ce6:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce7:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104cee:	81 7d f4 f4 7d 11 80 	cmpl   $0x80117df4,-0xc(%ebp)
80104cf5:	72 93                	jb     80104c8a <scheduler+0x3d>
    }
    release(&ptable.lock);
80104cf7:	83 ec 0c             	sub    $0xc,%esp
80104cfa:	68 c0 4d 11 80       	push   $0x80114dc0
80104cff:	e8 31 06 00 00       	call   80105335 <release>
80104d04:	83 c4 10             	add    $0x10,%esp
    sti();
80104d07:	e9 60 ff ff ff       	jmp    80104c6c <scheduler+0x1f>

80104d0c <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d0c:	f3 0f 1e fb          	endbr32 
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d16:	e8 b9 f7 ff ff       	call   801044d4 <myproc>
80104d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d1e:	83 ec 0c             	sub    $0xc,%esp
80104d21:	68 c0 4d 11 80       	push   $0x80114dc0
80104d26:	e8 df 06 00 00       	call   8010540a <holding>
80104d2b:	83 c4 10             	add    $0x10,%esp
80104d2e:	85 c0                	test   %eax,%eax
80104d30:	75 0d                	jne    80104d3f <sched+0x33>
    panic("sched ptable.lock");
80104d32:	83 ec 0c             	sub    $0xc,%esp
80104d35:	68 27 97 10 80       	push   $0x80109727
80104d3a:	e8 c9 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d3f:	e8 14 f7 ff ff       	call   80104458 <mycpu>
80104d44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d4a:	83 f8 01             	cmp    $0x1,%eax
80104d4d:	74 0d                	je     80104d5c <sched+0x50>
    panic("sched locks");
80104d4f:	83 ec 0c             	sub    $0xc,%esp
80104d52:	68 39 97 10 80       	push   $0x80109739
80104d57:	e8 ac b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d62:	83 f8 04             	cmp    $0x4,%eax
80104d65:	75 0d                	jne    80104d74 <sched+0x68>
    panic("sched running");
80104d67:	83 ec 0c             	sub    $0xc,%esp
80104d6a:	68 45 97 10 80       	push   $0x80109745
80104d6f:	e8 94 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d74:	e8 87 f6 ff ff       	call   80104400 <readeflags>
80104d79:	25 00 02 00 00       	and    $0x200,%eax
80104d7e:	85 c0                	test   %eax,%eax
80104d80:	74 0d                	je     80104d8f <sched+0x83>
    panic("sched interruptible");
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	68 53 97 10 80       	push   $0x80109753
80104d8a:	e8 79 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d8f:	e8 c4 f6 ff ff       	call   80104458 <mycpu>
80104d94:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d9d:	e8 b6 f6 ff ff       	call   80104458 <mycpu>
80104da2:	8b 40 04             	mov    0x4(%eax),%eax
80104da5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da8:	83 c2 1c             	add    $0x1c,%edx
80104dab:	83 ec 08             	sub    $0x8,%esp
80104dae:	50                   	push   %eax
80104daf:	52                   	push   %edx
80104db0:	e8 41 0a 00 00       	call   801057f6 <swtch>
80104db5:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104db8:	e8 9b f6 ff ff       	call   80104458 <mycpu>
80104dbd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dc0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104dc6:	90                   	nop
80104dc7:	c9                   	leave  
80104dc8:	c3                   	ret    

80104dc9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104dc9:	f3 0f 1e fb          	endbr32 
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104dd3:	83 ec 0c             	sub    $0xc,%esp
80104dd6:	68 c0 4d 11 80       	push   $0x80114dc0
80104ddb:	e8 e3 04 00 00       	call   801052c3 <acquire>
80104de0:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104de3:	e8 ec f6 ff ff       	call   801044d4 <myproc>
80104de8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104def:	e8 18 ff ff ff       	call   80104d0c <sched>
  release(&ptable.lock);
80104df4:	83 ec 0c             	sub    $0xc,%esp
80104df7:	68 c0 4d 11 80       	push   $0x80114dc0
80104dfc:	e8 34 05 00 00       	call   80105335 <release>
80104e01:	83 c4 10             	add    $0x10,%esp
}
80104e04:	90                   	nop
80104e05:	c9                   	leave  
80104e06:	c3                   	ret    

80104e07 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e07:	f3 0f 1e fb          	endbr32 
80104e0b:	55                   	push   %ebp
80104e0c:	89 e5                	mov    %esp,%ebp
80104e0e:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e11:	83 ec 0c             	sub    $0xc,%esp
80104e14:	68 c0 4d 11 80       	push   $0x80114dc0
80104e19:	e8 17 05 00 00       	call   80105335 <release>
80104e1e:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e21:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e26:	85 c0                	test   %eax,%eax
80104e28:	74 24                	je     80104e4e <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e2a:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e31:	00 00 00 
    iinit(ROOTDEV);
80104e34:	83 ec 0c             	sub    $0xc,%esp
80104e37:	6a 01                	push   $0x1
80104e39:	e8 5c c9 ff ff       	call   8010179a <iinit>
80104e3e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e41:	83 ec 0c             	sub    $0xc,%esp
80104e44:	6a 01                	push   $0x1
80104e46:	e8 97 e6 ff ff       	call   801034e2 <initlog>
80104e4b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e4e:	90                   	nop
80104e4f:	c9                   	leave  
80104e50:	c3                   	ret    

80104e51 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e51:	f3 0f 1e fb          	endbr32 
80104e55:	55                   	push   %ebp
80104e56:	89 e5                	mov    %esp,%ebp
80104e58:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e5b:	e8 74 f6 ff ff       	call   801044d4 <myproc>
80104e60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e67:	75 0d                	jne    80104e76 <sleep+0x25>
    panic("sleep");
80104e69:	83 ec 0c             	sub    $0xc,%esp
80104e6c:	68 67 97 10 80       	push   $0x80109767
80104e71:	e8 92 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e7a:	75 0d                	jne    80104e89 <sleep+0x38>
    panic("sleep without lk");
80104e7c:	83 ec 0c             	sub    $0xc,%esp
80104e7f:	68 6d 97 10 80       	push   $0x8010976d
80104e84:	e8 7f b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e89:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e90:	74 1e                	je     80104eb0 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e92:	83 ec 0c             	sub    $0xc,%esp
80104e95:	68 c0 4d 11 80       	push   $0x80114dc0
80104e9a:	e8 24 04 00 00       	call   801052c3 <acquire>
80104e9f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ea2:	83 ec 0c             	sub    $0xc,%esp
80104ea5:	ff 75 0c             	pushl  0xc(%ebp)
80104ea8:	e8 88 04 00 00       	call   80105335 <release>
80104ead:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb3:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb6:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebc:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ec3:	e8 44 fe ff ff       	call   80104d0c <sched>

  // Tidy up.
  p->chan = 0;
80104ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecb:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ed2:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ed9:	74 1e                	je     80104ef9 <sleep+0xa8>
    release(&ptable.lock);
80104edb:	83 ec 0c             	sub    $0xc,%esp
80104ede:	68 c0 4d 11 80       	push   $0x80114dc0
80104ee3:	e8 4d 04 00 00       	call   80105335 <release>
80104ee8:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104eeb:	83 ec 0c             	sub    $0xc,%esp
80104eee:	ff 75 0c             	pushl  0xc(%ebp)
80104ef1:	e8 cd 03 00 00       	call   801052c3 <acquire>
80104ef6:	83 c4 10             	add    $0x10,%esp
  }
}
80104ef9:	90                   	nop
80104efa:	c9                   	leave  
80104efb:	c3                   	ret    

80104efc <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104efc:	f3 0f 1e fb          	endbr32 
80104f00:	55                   	push   %ebp
80104f01:	89 e5                	mov    %esp,%ebp
80104f03:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f06:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f0d:	eb 27                	jmp    80104f36 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f12:	8b 40 0c             	mov    0xc(%eax),%eax
80104f15:	83 f8 02             	cmp    $0x2,%eax
80104f18:	75 15                	jne    80104f2f <wakeup1+0x33>
80104f1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f1d:	8b 40 20             	mov    0x20(%eax),%eax
80104f20:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f23:	75 0a                	jne    80104f2f <wakeup1+0x33>
      p->state = RUNNABLE;
80104f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f28:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f2f:	81 45 fc c0 00 00 00 	addl   $0xc0,-0x4(%ebp)
80104f36:	81 7d fc f4 7d 11 80 	cmpl   $0x80117df4,-0x4(%ebp)
80104f3d:	72 d0                	jb     80104f0f <wakeup1+0x13>
}
80104f3f:	90                   	nop
80104f40:	90                   	nop
80104f41:	c9                   	leave  
80104f42:	c3                   	ret    

80104f43 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f43:	f3 0f 1e fb          	endbr32 
80104f47:	55                   	push   %ebp
80104f48:	89 e5                	mov    %esp,%ebp
80104f4a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f4d:	83 ec 0c             	sub    $0xc,%esp
80104f50:	68 c0 4d 11 80       	push   $0x80114dc0
80104f55:	e8 69 03 00 00       	call   801052c3 <acquire>
80104f5a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f5d:	83 ec 0c             	sub    $0xc,%esp
80104f60:	ff 75 08             	pushl  0x8(%ebp)
80104f63:	e8 94 ff ff ff       	call   80104efc <wakeup1>
80104f68:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f6b:	83 ec 0c             	sub    $0xc,%esp
80104f6e:	68 c0 4d 11 80       	push   $0x80114dc0
80104f73:	e8 bd 03 00 00       	call   80105335 <release>
80104f78:	83 c4 10             	add    $0x10,%esp
}
80104f7b:	90                   	nop
80104f7c:	c9                   	leave  
80104f7d:	c3                   	ret    

80104f7e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f7e:	f3 0f 1e fb          	endbr32 
80104f82:	55                   	push   %ebp
80104f83:	89 e5                	mov    %esp,%ebp
80104f85:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f88:	83 ec 0c             	sub    $0xc,%esp
80104f8b:	68 c0 4d 11 80       	push   $0x80114dc0
80104f90:	e8 2e 03 00 00       	call   801052c3 <acquire>
80104f95:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f98:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f9f:	eb 48                	jmp    80104fe9 <kill+0x6b>
    if(p->pid == pid){
80104fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa4:	8b 40 10             	mov    0x10(%eax),%eax
80104fa7:	39 45 08             	cmp    %eax,0x8(%ebp)
80104faa:	75 36                	jne    80104fe2 <kill+0x64>
      p->killed = 1;
80104fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104faf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbc:	83 f8 02             	cmp    $0x2,%eax
80104fbf:	75 0a                	jne    80104fcb <kill+0x4d>
        p->state = RUNNABLE;
80104fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fcb:	83 ec 0c             	sub    $0xc,%esp
80104fce:	68 c0 4d 11 80       	push   $0x80114dc0
80104fd3:	e8 5d 03 00 00       	call   80105335 <release>
80104fd8:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe0:	eb 25                	jmp    80105007 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe2:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104fe9:	81 7d f4 f4 7d 11 80 	cmpl   $0x80117df4,-0xc(%ebp)
80104ff0:	72 af                	jb     80104fa1 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104ff2:	83 ec 0c             	sub    $0xc,%esp
80104ff5:	68 c0 4d 11 80       	push   $0x80114dc0
80104ffa:	e8 36 03 00 00       	call   80105335 <release>
80104fff:	83 c4 10             	add    $0x10,%esp
  return -1;
80105002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105007:	c9                   	leave  
80105008:	c3                   	ret    

80105009 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105009:	f3 0f 1e fb          	endbr32 
8010500d:	55                   	push   %ebp
8010500e:	89 e5                	mov    %esp,%ebp
80105010:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105013:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
8010501a:	e9 da 00 00 00       	jmp    801050f9 <procdump+0xf0>
    if(p->state == UNUSED)
8010501f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105022:	8b 40 0c             	mov    0xc(%eax),%eax
80105025:	85 c0                	test   %eax,%eax
80105027:	0f 84 c4 00 00 00    	je     801050f1 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010502d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105030:	8b 40 0c             	mov    0xc(%eax),%eax
80105033:	83 f8 05             	cmp    $0x5,%eax
80105036:	77 23                	ja     8010505b <procdump+0x52>
80105038:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503b:	8b 40 0c             	mov    0xc(%eax),%eax
8010503e:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105045:	85 c0                	test   %eax,%eax
80105047:	74 12                	je     8010505b <procdump+0x52>
      state = states[p->state];
80105049:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504c:	8b 40 0c             	mov    0xc(%eax),%eax
8010504f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105056:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105059:	eb 07                	jmp    80105062 <procdump+0x59>
    else
      state = "???";
8010505b:	c7 45 ec 7e 97 10 80 	movl   $0x8010977e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105065:	8d 50 6c             	lea    0x6c(%eax),%edx
80105068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506b:	8b 40 10             	mov    0x10(%eax),%eax
8010506e:	52                   	push   %edx
8010506f:	ff 75 ec             	pushl  -0x14(%ebp)
80105072:	50                   	push   %eax
80105073:	68 82 97 10 80       	push   $0x80109782
80105078:	e8 9b b3 ff ff       	call   80100418 <cprintf>
8010507d:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105080:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105083:	8b 40 0c             	mov    0xc(%eax),%eax
80105086:	83 f8 02             	cmp    $0x2,%eax
80105089:	75 54                	jne    801050df <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010508b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105091:	8b 40 0c             	mov    0xc(%eax),%eax
80105094:	83 c0 08             	add    $0x8,%eax
80105097:	89 c2                	mov    %eax,%edx
80105099:	83 ec 08             	sub    $0x8,%esp
8010509c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010509f:	50                   	push   %eax
801050a0:	52                   	push   %edx
801050a1:	e8 e5 02 00 00       	call   8010538b <getcallerpcs>
801050a6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050b0:	eb 1c                	jmp    801050ce <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050b9:	83 ec 08             	sub    $0x8,%esp
801050bc:	50                   	push   %eax
801050bd:	68 8b 97 10 80       	push   $0x8010978b
801050c2:	e8 51 b3 ff ff       	call   80100418 <cprintf>
801050c7:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ce:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050d2:	7f 0b                	jg     801050df <procdump+0xd6>
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050db:	85 c0                	test   %eax,%eax
801050dd:	75 d3                	jne    801050b2 <procdump+0xa9>
    }
    cprintf("\n");
801050df:	83 ec 0c             	sub    $0xc,%esp
801050e2:	68 8f 97 10 80       	push   $0x8010978f
801050e7:	e8 2c b3 ff ff       	call   80100418 <cprintf>
801050ec:	83 c4 10             	add    $0x10,%esp
801050ef:	eb 01                	jmp    801050f2 <procdump+0xe9>
      continue;
801050f1:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050f2:	81 45 f0 c0 00 00 00 	addl   $0xc0,-0x10(%ebp)
801050f9:	81 7d f0 f4 7d 11 80 	cmpl   $0x80117df4,-0x10(%ebp)
80105100:	0f 82 19 ff ff ff    	jb     8010501f <procdump+0x16>
  }
}
80105106:	90                   	nop
80105107:	90                   	nop
80105108:	c9                   	leave  
80105109:	c3                   	ret    

8010510a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010510a:	f3 0f 1e fb          	endbr32 
8010510e:	55                   	push   %ebp
8010510f:	89 e5                	mov    %esp,%ebp
80105111:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105114:	8b 45 08             	mov    0x8(%ebp),%eax
80105117:	83 c0 04             	add    $0x4,%eax
8010511a:	83 ec 08             	sub    $0x8,%esp
8010511d:	68 bb 97 10 80       	push   $0x801097bb
80105122:	50                   	push   %eax
80105123:	e8 75 01 00 00       	call   8010529d <initlock>
80105128:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010512b:	8b 45 08             	mov    0x8(%ebp),%eax
8010512e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105131:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105134:	8b 45 08             	mov    0x8(%ebp),%eax
80105137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010513d:	8b 45 08             	mov    0x8(%ebp),%eax
80105140:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105147:	90                   	nop
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010514a:	f3 0f 1e fb          	endbr32 
8010514e:	55                   	push   %ebp
8010514f:	89 e5                	mov    %esp,%ebp
80105151:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105154:	8b 45 08             	mov    0x8(%ebp),%eax
80105157:	83 c0 04             	add    $0x4,%eax
8010515a:	83 ec 0c             	sub    $0xc,%esp
8010515d:	50                   	push   %eax
8010515e:	e8 60 01 00 00       	call   801052c3 <acquire>
80105163:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105166:	eb 15                	jmp    8010517d <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105168:	8b 45 08             	mov    0x8(%ebp),%eax
8010516b:	83 c0 04             	add    $0x4,%eax
8010516e:	83 ec 08             	sub    $0x8,%esp
80105171:	50                   	push   %eax
80105172:	ff 75 08             	pushl  0x8(%ebp)
80105175:	e8 d7 fc ff ff       	call   80104e51 <sleep>
8010517a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010517d:	8b 45 08             	mov    0x8(%ebp),%eax
80105180:	8b 00                	mov    (%eax),%eax
80105182:	85 c0                	test   %eax,%eax
80105184:	75 e2                	jne    80105168 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105186:	8b 45 08             	mov    0x8(%ebp),%eax
80105189:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010518f:	e8 40 f3 ff ff       	call   801044d4 <myproc>
80105194:	8b 50 10             	mov    0x10(%eax),%edx
80105197:	8b 45 08             	mov    0x8(%ebp),%eax
8010519a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010519d:	8b 45 08             	mov    0x8(%ebp),%eax
801051a0:	83 c0 04             	add    $0x4,%eax
801051a3:	83 ec 0c             	sub    $0xc,%esp
801051a6:	50                   	push   %eax
801051a7:	e8 89 01 00 00       	call   80105335 <release>
801051ac:	83 c4 10             	add    $0x10,%esp
}
801051af:	90                   	nop
801051b0:	c9                   	leave  
801051b1:	c3                   	ret    

801051b2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051b2:	f3 0f 1e fb          	endbr32 
801051b6:	55                   	push   %ebp
801051b7:	89 e5                	mov    %esp,%ebp
801051b9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051bc:	8b 45 08             	mov    0x8(%ebp),%eax
801051bf:	83 c0 04             	add    $0x4,%eax
801051c2:	83 ec 0c             	sub    $0xc,%esp
801051c5:	50                   	push   %eax
801051c6:	e8 f8 00 00 00       	call   801052c3 <acquire>
801051cb:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051ce:	8b 45 08             	mov    0x8(%ebp),%eax
801051d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051d7:	8b 45 08             	mov    0x8(%ebp),%eax
801051da:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051e1:	83 ec 0c             	sub    $0xc,%esp
801051e4:	ff 75 08             	pushl  0x8(%ebp)
801051e7:	e8 57 fd ff ff       	call   80104f43 <wakeup>
801051ec:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801051ef:	8b 45 08             	mov    0x8(%ebp),%eax
801051f2:	83 c0 04             	add    $0x4,%eax
801051f5:	83 ec 0c             	sub    $0xc,%esp
801051f8:	50                   	push   %eax
801051f9:	e8 37 01 00 00       	call   80105335 <release>
801051fe:	83 c4 10             	add    $0x10,%esp
}
80105201:	90                   	nop
80105202:	c9                   	leave  
80105203:	c3                   	ret    

80105204 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105204:	f3 0f 1e fb          	endbr32 
80105208:	55                   	push   %ebp
80105209:	89 e5                	mov    %esp,%ebp
8010520b:	53                   	push   %ebx
8010520c:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	83 c0 04             	add    $0x4,%eax
80105215:	83 ec 0c             	sub    $0xc,%esp
80105218:	50                   	push   %eax
80105219:	e8 a5 00 00 00       	call   801052c3 <acquire>
8010521e:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105221:	8b 45 08             	mov    0x8(%ebp),%eax
80105224:	8b 00                	mov    (%eax),%eax
80105226:	85 c0                	test   %eax,%eax
80105228:	74 19                	je     80105243 <holdingsleep+0x3f>
8010522a:	8b 45 08             	mov    0x8(%ebp),%eax
8010522d:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105230:	e8 9f f2 ff ff       	call   801044d4 <myproc>
80105235:	8b 40 10             	mov    0x10(%eax),%eax
80105238:	39 c3                	cmp    %eax,%ebx
8010523a:	75 07                	jne    80105243 <holdingsleep+0x3f>
8010523c:	b8 01 00 00 00       	mov    $0x1,%eax
80105241:	eb 05                	jmp    80105248 <holdingsleep+0x44>
80105243:	b8 00 00 00 00       	mov    $0x0,%eax
80105248:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010524b:	8b 45 08             	mov    0x8(%ebp),%eax
8010524e:	83 c0 04             	add    $0x4,%eax
80105251:	83 ec 0c             	sub    $0xc,%esp
80105254:	50                   	push   %eax
80105255:	e8 db 00 00 00       	call   80105335 <release>
8010525a:	83 c4 10             	add    $0x10,%esp
  return r;
8010525d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105263:	c9                   	leave  
80105264:	c3                   	ret    

80105265 <readeflags>:
{
80105265:	55                   	push   %ebp
80105266:	89 e5                	mov    %esp,%ebp
80105268:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010526b:	9c                   	pushf  
8010526c:	58                   	pop    %eax
8010526d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105273:	c9                   	leave  
80105274:	c3                   	ret    

80105275 <cli>:
{
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105278:	fa                   	cli    
}
80105279:	90                   	nop
8010527a:	5d                   	pop    %ebp
8010527b:	c3                   	ret    

8010527c <sti>:
{
8010527c:	55                   	push   %ebp
8010527d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010527f:	fb                   	sti    
}
80105280:	90                   	nop
80105281:	5d                   	pop    %ebp
80105282:	c3                   	ret    

80105283 <xchg>:
{
80105283:	55                   	push   %ebp
80105284:	89 e5                	mov    %esp,%ebp
80105286:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105289:	8b 55 08             	mov    0x8(%ebp),%edx
8010528c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105292:	f0 87 02             	lock xchg %eax,(%edx)
80105295:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105298:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010529b:	c9                   	leave  
8010529c:	c3                   	ret    

8010529d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010529d:	f3 0f 1e fb          	endbr32 
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052a4:	8b 45 08             	mov    0x8(%ebp),%eax
801052a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801052aa:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052ad:	8b 45 08             	mov    0x8(%ebp),%eax
801052b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052b6:	8b 45 08             	mov    0x8(%ebp),%eax
801052b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052c0:	90                   	nop
801052c1:	5d                   	pop    %ebp
801052c2:	c3                   	ret    

801052c3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052c3:	f3 0f 1e fb          	endbr32 
801052c7:	55                   	push   %ebp
801052c8:	89 e5                	mov    %esp,%ebp
801052ca:	53                   	push   %ebx
801052cb:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052ce:	e8 7c 01 00 00       	call   8010544f <pushcli>
  if(holding(lk))
801052d3:	8b 45 08             	mov    0x8(%ebp),%eax
801052d6:	83 ec 0c             	sub    $0xc,%esp
801052d9:	50                   	push   %eax
801052da:	e8 2b 01 00 00       	call   8010540a <holding>
801052df:	83 c4 10             	add    $0x10,%esp
801052e2:	85 c0                	test   %eax,%eax
801052e4:	74 0d                	je     801052f3 <acquire+0x30>
    panic("acquire");
801052e6:	83 ec 0c             	sub    $0xc,%esp
801052e9:	68 c6 97 10 80       	push   $0x801097c6
801052ee:	e8 15 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052f3:	90                   	nop
801052f4:	8b 45 08             	mov    0x8(%ebp),%eax
801052f7:	83 ec 08             	sub    $0x8,%esp
801052fa:	6a 01                	push   $0x1
801052fc:	50                   	push   %eax
801052fd:	e8 81 ff ff ff       	call   80105283 <xchg>
80105302:	83 c4 10             	add    $0x10,%esp
80105305:	85 c0                	test   %eax,%eax
80105307:	75 eb                	jne    801052f4 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105309:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010530e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105311:	e8 42 f1 ff ff       	call   80104458 <mycpu>
80105316:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	83 c0 0c             	add    $0xc,%eax
8010531f:	83 ec 08             	sub    $0x8,%esp
80105322:	50                   	push   %eax
80105323:	8d 45 08             	lea    0x8(%ebp),%eax
80105326:	50                   	push   %eax
80105327:	e8 5f 00 00 00       	call   8010538b <getcallerpcs>
8010532c:	83 c4 10             	add    $0x10,%esp
}
8010532f:	90                   	nop
80105330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105333:	c9                   	leave  
80105334:	c3                   	ret    

80105335 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105335:	f3 0f 1e fb          	endbr32 
80105339:	55                   	push   %ebp
8010533a:	89 e5                	mov    %esp,%ebp
8010533c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010533f:	83 ec 0c             	sub    $0xc,%esp
80105342:	ff 75 08             	pushl  0x8(%ebp)
80105345:	e8 c0 00 00 00       	call   8010540a <holding>
8010534a:	83 c4 10             	add    $0x10,%esp
8010534d:	85 c0                	test   %eax,%eax
8010534f:	75 0d                	jne    8010535e <release+0x29>
    panic("release");
80105351:	83 ec 0c             	sub    $0xc,%esp
80105354:	68 ce 97 10 80       	push   $0x801097ce
80105359:	e8 aa b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
8010535e:	8b 45 08             	mov    0x8(%ebp),%eax
80105361:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105368:	8b 45 08             	mov    0x8(%ebp),%eax
8010536b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105372:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105377:	8b 45 08             	mov    0x8(%ebp),%eax
8010537a:	8b 55 08             	mov    0x8(%ebp),%edx
8010537d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105383:	e8 18 01 00 00       	call   801054a0 <popcli>
}
80105388:	90                   	nop
80105389:	c9                   	leave  
8010538a:	c3                   	ret    

8010538b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010538b:	f3 0f 1e fb          	endbr32 
8010538f:	55                   	push   %ebp
80105390:	89 e5                	mov    %esp,%ebp
80105392:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105395:	8b 45 08             	mov    0x8(%ebp),%eax
80105398:	83 e8 08             	sub    $0x8,%eax
8010539b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010539e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053a5:	eb 38                	jmp    801053df <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053a7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053ab:	74 53                	je     80105400 <getcallerpcs+0x75>
801053ad:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053b4:	76 4a                	jbe    80105400 <getcallerpcs+0x75>
801053b6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053ba:	74 44                	je     80105400 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c9:	01 c2                	add    %eax,%edx
801053cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ce:	8b 40 04             	mov    0x4(%eax),%eax
801053d1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053d6:	8b 00                	mov    (%eax),%eax
801053d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053db:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053df:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053e3:	7e c2                	jle    801053a7 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053e5:	eb 19                	jmp    80105400 <getcallerpcs+0x75>
    pcs[i] = 0;
801053e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f4:	01 d0                	add    %edx,%eax
801053f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801053fc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105400:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105404:	7e e1                	jle    801053e7 <getcallerpcs+0x5c>
}
80105406:	90                   	nop
80105407:	90                   	nop
80105408:	c9                   	leave  
80105409:	c3                   	ret    

8010540a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010540a:	f3 0f 1e fb          	endbr32 
8010540e:	55                   	push   %ebp
8010540f:	89 e5                	mov    %esp,%ebp
80105411:	53                   	push   %ebx
80105412:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105415:	e8 35 00 00 00       	call   8010544f <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010541a:	8b 45 08             	mov    0x8(%ebp),%eax
8010541d:	8b 00                	mov    (%eax),%eax
8010541f:	85 c0                	test   %eax,%eax
80105421:	74 16                	je     80105439 <holding+0x2f>
80105423:	8b 45 08             	mov    0x8(%ebp),%eax
80105426:	8b 58 08             	mov    0x8(%eax),%ebx
80105429:	e8 2a f0 ff ff       	call   80104458 <mycpu>
8010542e:	39 c3                	cmp    %eax,%ebx
80105430:	75 07                	jne    80105439 <holding+0x2f>
80105432:	b8 01 00 00 00       	mov    $0x1,%eax
80105437:	eb 05                	jmp    8010543e <holding+0x34>
80105439:	b8 00 00 00 00       	mov    $0x0,%eax
8010543e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105441:	e8 5a 00 00 00       	call   801054a0 <popcli>
  return r;
80105446:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105449:	83 c4 14             	add    $0x14,%esp
8010544c:	5b                   	pop    %ebx
8010544d:	5d                   	pop    %ebp
8010544e:	c3                   	ret    

8010544f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010544f:	f3 0f 1e fb          	endbr32 
80105453:	55                   	push   %ebp
80105454:	89 e5                	mov    %esp,%ebp
80105456:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105459:	e8 07 fe ff ff       	call   80105265 <readeflags>
8010545e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105461:	e8 0f fe ff ff       	call   80105275 <cli>
  if(mycpu()->ncli == 0)
80105466:	e8 ed ef ff ff       	call   80104458 <mycpu>
8010546b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105471:	85 c0                	test   %eax,%eax
80105473:	75 14                	jne    80105489 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105475:	e8 de ef ff ff       	call   80104458 <mycpu>
8010547a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010547d:	81 e2 00 02 00 00    	and    $0x200,%edx
80105483:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105489:	e8 ca ef ff ff       	call   80104458 <mycpu>
8010548e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105494:	83 c2 01             	add    $0x1,%edx
80105497:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010549d:	90                   	nop
8010549e:	c9                   	leave  
8010549f:	c3                   	ret    

801054a0 <popcli>:

void
popcli(void)
{
801054a0:	f3 0f 1e fb          	endbr32 
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
801054a7:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054aa:	e8 b6 fd ff ff       	call   80105265 <readeflags>
801054af:	25 00 02 00 00       	and    $0x200,%eax
801054b4:	85 c0                	test   %eax,%eax
801054b6:	74 0d                	je     801054c5 <popcli+0x25>
    panic("popcli - interruptible");
801054b8:	83 ec 0c             	sub    $0xc,%esp
801054bb:	68 d6 97 10 80       	push   $0x801097d6
801054c0:	e8 43 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054c5:	e8 8e ef ff ff       	call   80104458 <mycpu>
801054ca:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054d0:	83 ea 01             	sub    $0x1,%edx
801054d3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054d9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054df:	85 c0                	test   %eax,%eax
801054e1:	79 0d                	jns    801054f0 <popcli+0x50>
    panic("popcli");
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	68 ed 97 10 80       	push   $0x801097ed
801054eb:	e8 18 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801054f0:	e8 63 ef ff ff       	call   80104458 <mycpu>
801054f5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054fb:	85 c0                	test   %eax,%eax
801054fd:	75 14                	jne    80105513 <popcli+0x73>
801054ff:	e8 54 ef ff ff       	call   80104458 <mycpu>
80105504:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010550a:	85 c0                	test   %eax,%eax
8010550c:	74 05                	je     80105513 <popcli+0x73>
    sti();
8010550e:	e8 69 fd ff ff       	call   8010527c <sti>
}
80105513:	90                   	nop
80105514:	c9                   	leave  
80105515:	c3                   	ret    

80105516 <stosb>:
{
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	57                   	push   %edi
8010551a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010551b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010551e:	8b 55 10             	mov    0x10(%ebp),%edx
80105521:	8b 45 0c             	mov    0xc(%ebp),%eax
80105524:	89 cb                	mov    %ecx,%ebx
80105526:	89 df                	mov    %ebx,%edi
80105528:	89 d1                	mov    %edx,%ecx
8010552a:	fc                   	cld    
8010552b:	f3 aa                	rep stos %al,%es:(%edi)
8010552d:	89 ca                	mov    %ecx,%edx
8010552f:	89 fb                	mov    %edi,%ebx
80105531:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105534:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105537:	90                   	nop
80105538:	5b                   	pop    %ebx
80105539:	5f                   	pop    %edi
8010553a:	5d                   	pop    %ebp
8010553b:	c3                   	ret    

8010553c <stosl>:
{
8010553c:	55                   	push   %ebp
8010553d:	89 e5                	mov    %esp,%ebp
8010553f:	57                   	push   %edi
80105540:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105541:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105544:	8b 55 10             	mov    0x10(%ebp),%edx
80105547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554a:	89 cb                	mov    %ecx,%ebx
8010554c:	89 df                	mov    %ebx,%edi
8010554e:	89 d1                	mov    %edx,%ecx
80105550:	fc                   	cld    
80105551:	f3 ab                	rep stos %eax,%es:(%edi)
80105553:	89 ca                	mov    %ecx,%edx
80105555:	89 fb                	mov    %edi,%ebx
80105557:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010555a:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010555d:	90                   	nop
8010555e:	5b                   	pop    %ebx
8010555f:	5f                   	pop    %edi
80105560:	5d                   	pop    %ebp
80105561:	c3                   	ret    

80105562 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105562:	f3 0f 1e fb          	endbr32 
80105566:	55                   	push   %ebp
80105567:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105569:	8b 45 08             	mov    0x8(%ebp),%eax
8010556c:	83 e0 03             	and    $0x3,%eax
8010556f:	85 c0                	test   %eax,%eax
80105571:	75 43                	jne    801055b6 <memset+0x54>
80105573:	8b 45 10             	mov    0x10(%ebp),%eax
80105576:	83 e0 03             	and    $0x3,%eax
80105579:	85 c0                	test   %eax,%eax
8010557b:	75 39                	jne    801055b6 <memset+0x54>
    c &= 0xFF;
8010557d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105584:	8b 45 10             	mov    0x10(%ebp),%eax
80105587:	c1 e8 02             	shr    $0x2,%eax
8010558a:	89 c1                	mov    %eax,%ecx
8010558c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558f:	c1 e0 18             	shl    $0x18,%eax
80105592:	89 c2                	mov    %eax,%edx
80105594:	8b 45 0c             	mov    0xc(%ebp),%eax
80105597:	c1 e0 10             	shl    $0x10,%eax
8010559a:	09 c2                	or     %eax,%edx
8010559c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559f:	c1 e0 08             	shl    $0x8,%eax
801055a2:	09 d0                	or     %edx,%eax
801055a4:	0b 45 0c             	or     0xc(%ebp),%eax
801055a7:	51                   	push   %ecx
801055a8:	50                   	push   %eax
801055a9:	ff 75 08             	pushl  0x8(%ebp)
801055ac:	e8 8b ff ff ff       	call   8010553c <stosl>
801055b1:	83 c4 0c             	add    $0xc,%esp
801055b4:	eb 12                	jmp    801055c8 <memset+0x66>
  } else
    stosb(dst, c, n);
801055b6:	8b 45 10             	mov    0x10(%ebp),%eax
801055b9:	50                   	push   %eax
801055ba:	ff 75 0c             	pushl  0xc(%ebp)
801055bd:	ff 75 08             	pushl  0x8(%ebp)
801055c0:	e8 51 ff ff ff       	call   80105516 <stosb>
801055c5:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055cb:	c9                   	leave  
801055cc:	c3                   	ret    

801055cd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055cd:	f3 0f 1e fb          	endbr32 
801055d1:	55                   	push   %ebp
801055d2:	89 e5                	mov    %esp,%ebp
801055d4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055d7:	8b 45 08             	mov    0x8(%ebp),%eax
801055da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055e3:	eb 30                	jmp    80105615 <memcmp+0x48>
    if(*s1 != *s2)
801055e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e8:	0f b6 10             	movzbl (%eax),%edx
801055eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055ee:	0f b6 00             	movzbl (%eax),%eax
801055f1:	38 c2                	cmp    %al,%dl
801055f3:	74 18                	je     8010560d <memcmp+0x40>
      return *s1 - *s2;
801055f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f8:	0f b6 00             	movzbl (%eax),%eax
801055fb:	0f b6 d0             	movzbl %al,%edx
801055fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105601:	0f b6 00             	movzbl (%eax),%eax
80105604:	0f b6 c0             	movzbl %al,%eax
80105607:	29 c2                	sub    %eax,%edx
80105609:	89 d0                	mov    %edx,%eax
8010560b:	eb 1a                	jmp    80105627 <memcmp+0x5a>
    s1++, s2++;
8010560d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105611:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105615:	8b 45 10             	mov    0x10(%ebp),%eax
80105618:	8d 50 ff             	lea    -0x1(%eax),%edx
8010561b:	89 55 10             	mov    %edx,0x10(%ebp)
8010561e:	85 c0                	test   %eax,%eax
80105620:	75 c3                	jne    801055e5 <memcmp+0x18>
  }

  return 0;
80105622:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105627:	c9                   	leave  
80105628:	c3                   	ret    

80105629 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105629:	f3 0f 1e fb          	endbr32 
8010562d:	55                   	push   %ebp
8010562e:	89 e5                	mov    %esp,%ebp
80105630:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105633:	8b 45 0c             	mov    0xc(%ebp),%eax
80105636:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105639:	8b 45 08             	mov    0x8(%ebp),%eax
8010563c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010563f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105642:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105645:	73 54                	jae    8010569b <memmove+0x72>
80105647:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010564a:	8b 45 10             	mov    0x10(%ebp),%eax
8010564d:	01 d0                	add    %edx,%eax
8010564f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105652:	73 47                	jae    8010569b <memmove+0x72>
    s += n;
80105654:	8b 45 10             	mov    0x10(%ebp),%eax
80105657:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010565a:	8b 45 10             	mov    0x10(%ebp),%eax
8010565d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105660:	eb 13                	jmp    80105675 <memmove+0x4c>
      *--d = *--s;
80105662:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105666:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010566a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566d:	0f b6 10             	movzbl (%eax),%edx
80105670:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105673:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105675:	8b 45 10             	mov    0x10(%ebp),%eax
80105678:	8d 50 ff             	lea    -0x1(%eax),%edx
8010567b:	89 55 10             	mov    %edx,0x10(%ebp)
8010567e:	85 c0                	test   %eax,%eax
80105680:	75 e0                	jne    80105662 <memmove+0x39>
  if(s < d && s + n > d){
80105682:	eb 24                	jmp    801056a8 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105684:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105687:	8d 42 01             	lea    0x1(%edx),%eax
8010568a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010568d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105690:	8d 48 01             	lea    0x1(%eax),%ecx
80105693:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105696:	0f b6 12             	movzbl (%edx),%edx
80105699:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010569b:	8b 45 10             	mov    0x10(%ebp),%eax
8010569e:	8d 50 ff             	lea    -0x1(%eax),%edx
801056a1:	89 55 10             	mov    %edx,0x10(%ebp)
801056a4:	85 c0                	test   %eax,%eax
801056a6:	75 dc                	jne    80105684 <memmove+0x5b>

  return dst;
801056a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056ab:	c9                   	leave  
801056ac:	c3                   	ret    

801056ad <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056ad:	f3 0f 1e fb          	endbr32 
801056b1:	55                   	push   %ebp
801056b2:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056b4:	ff 75 10             	pushl  0x10(%ebp)
801056b7:	ff 75 0c             	pushl  0xc(%ebp)
801056ba:	ff 75 08             	pushl  0x8(%ebp)
801056bd:	e8 67 ff ff ff       	call   80105629 <memmove>
801056c2:	83 c4 0c             	add    $0xc,%esp
}
801056c5:	c9                   	leave  
801056c6:	c3                   	ret    

801056c7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056c7:	f3 0f 1e fb          	endbr32 
801056cb:	55                   	push   %ebp
801056cc:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056ce:	eb 0c                	jmp    801056dc <strncmp+0x15>
    n--, p++, q++;
801056d0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056d8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056e0:	74 1a                	je     801056fc <strncmp+0x35>
801056e2:	8b 45 08             	mov    0x8(%ebp),%eax
801056e5:	0f b6 00             	movzbl (%eax),%eax
801056e8:	84 c0                	test   %al,%al
801056ea:	74 10                	je     801056fc <strncmp+0x35>
801056ec:	8b 45 08             	mov    0x8(%ebp),%eax
801056ef:	0f b6 10             	movzbl (%eax),%edx
801056f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f5:	0f b6 00             	movzbl (%eax),%eax
801056f8:	38 c2                	cmp    %al,%dl
801056fa:	74 d4                	je     801056d0 <strncmp+0x9>
  if(n == 0)
801056fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105700:	75 07                	jne    80105709 <strncmp+0x42>
    return 0;
80105702:	b8 00 00 00 00       	mov    $0x0,%eax
80105707:	eb 16                	jmp    8010571f <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105709:	8b 45 08             	mov    0x8(%ebp),%eax
8010570c:	0f b6 00             	movzbl (%eax),%eax
8010570f:	0f b6 d0             	movzbl %al,%edx
80105712:	8b 45 0c             	mov    0xc(%ebp),%eax
80105715:	0f b6 00             	movzbl (%eax),%eax
80105718:	0f b6 c0             	movzbl %al,%eax
8010571b:	29 c2                	sub    %eax,%edx
8010571d:	89 d0                	mov    %edx,%eax
}
8010571f:	5d                   	pop    %ebp
80105720:	c3                   	ret    

80105721 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105721:	f3 0f 1e fb          	endbr32 
80105725:	55                   	push   %ebp
80105726:	89 e5                	mov    %esp,%ebp
80105728:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010572b:	8b 45 08             	mov    0x8(%ebp),%eax
8010572e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105731:	90                   	nop
80105732:	8b 45 10             	mov    0x10(%ebp),%eax
80105735:	8d 50 ff             	lea    -0x1(%eax),%edx
80105738:	89 55 10             	mov    %edx,0x10(%ebp)
8010573b:	85 c0                	test   %eax,%eax
8010573d:	7e 2c                	jle    8010576b <strncpy+0x4a>
8010573f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105742:	8d 42 01             	lea    0x1(%edx),%eax
80105745:	89 45 0c             	mov    %eax,0xc(%ebp)
80105748:	8b 45 08             	mov    0x8(%ebp),%eax
8010574b:	8d 48 01             	lea    0x1(%eax),%ecx
8010574e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105751:	0f b6 12             	movzbl (%edx),%edx
80105754:	88 10                	mov    %dl,(%eax)
80105756:	0f b6 00             	movzbl (%eax),%eax
80105759:	84 c0                	test   %al,%al
8010575b:	75 d5                	jne    80105732 <strncpy+0x11>
    ;
  while(n-- > 0)
8010575d:	eb 0c                	jmp    8010576b <strncpy+0x4a>
    *s++ = 0;
8010575f:	8b 45 08             	mov    0x8(%ebp),%eax
80105762:	8d 50 01             	lea    0x1(%eax),%edx
80105765:	89 55 08             	mov    %edx,0x8(%ebp)
80105768:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010576b:	8b 45 10             	mov    0x10(%ebp),%eax
8010576e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105771:	89 55 10             	mov    %edx,0x10(%ebp)
80105774:	85 c0                	test   %eax,%eax
80105776:	7f e7                	jg     8010575f <strncpy+0x3e>
  return os;
80105778:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010577b:	c9                   	leave  
8010577c:	c3                   	ret    

8010577d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010577d:	f3 0f 1e fb          	endbr32 
80105781:	55                   	push   %ebp
80105782:	89 e5                	mov    %esp,%ebp
80105784:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105787:	8b 45 08             	mov    0x8(%ebp),%eax
8010578a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010578d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105791:	7f 05                	jg     80105798 <safestrcpy+0x1b>
    return os;
80105793:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105796:	eb 31                	jmp    801057c9 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105798:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010579c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a0:	7e 1e                	jle    801057c0 <safestrcpy+0x43>
801057a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801057a5:	8d 42 01             	lea    0x1(%edx),%eax
801057a8:	89 45 0c             	mov    %eax,0xc(%ebp)
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
801057ae:	8d 48 01             	lea    0x1(%eax),%ecx
801057b1:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057b4:	0f b6 12             	movzbl (%edx),%edx
801057b7:	88 10                	mov    %dl,(%eax)
801057b9:	0f b6 00             	movzbl (%eax),%eax
801057bc:	84 c0                	test   %al,%al
801057be:	75 d8                	jne    80105798 <safestrcpy+0x1b>
    ;
  *s = 0;
801057c0:	8b 45 08             	mov    0x8(%ebp),%eax
801057c3:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057c9:	c9                   	leave  
801057ca:	c3                   	ret    

801057cb <strlen>:

int
strlen(const char *s)
{
801057cb:	f3 0f 1e fb          	endbr32 
801057cf:	55                   	push   %ebp
801057d0:	89 e5                	mov    %esp,%ebp
801057d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057dc:	eb 04                	jmp    801057e2 <strlen+0x17>
801057de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057e5:	8b 45 08             	mov    0x8(%ebp),%eax
801057e8:	01 d0                	add    %edx,%eax
801057ea:	0f b6 00             	movzbl (%eax),%eax
801057ed:	84 c0                	test   %al,%al
801057ef:	75 ed                	jne    801057de <strlen+0x13>
    ;
  return n;
801057f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f4:	c9                   	leave  
801057f5:	c3                   	ret    

801057f6 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057f6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057fa:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801057fe:	55                   	push   %ebp
  pushl %ebx
801057ff:	53                   	push   %ebx
  pushl %esi
80105800:	56                   	push   %esi
  pushl %edi
80105801:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105802:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105804:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105806:	5f                   	pop    %edi
  popl %esi
80105807:	5e                   	pop    %esi
  popl %ebx
80105808:	5b                   	pop    %ebx
  popl %ebp
80105809:	5d                   	pop    %ebp
  ret
8010580a:	c3                   	ret    

8010580b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010580b:	f3 0f 1e fb          	endbr32 
8010580f:	55                   	push   %ebp
80105810:	89 e5                	mov    %esp,%ebp
80105812:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105815:	e8 ba ec ff ff       	call   801044d4 <myproc>
8010581a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8b 00                	mov    (%eax),%eax
80105822:	39 45 08             	cmp    %eax,0x8(%ebp)
80105825:	73 0f                	jae    80105836 <fetchint+0x2b>
80105827:	8b 45 08             	mov    0x8(%ebp),%eax
8010582a:	8d 50 04             	lea    0x4(%eax),%edx
8010582d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105830:	8b 00                	mov    (%eax),%eax
80105832:	39 c2                	cmp    %eax,%edx
80105834:	76 07                	jbe    8010583d <fetchint+0x32>
    return -1;
80105836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583b:	eb 0f                	jmp    8010584c <fetchint+0x41>
  *ip = *(int*)(addr);
8010583d:	8b 45 08             	mov    0x8(%ebp),%eax
80105840:	8b 10                	mov    (%eax),%edx
80105842:	8b 45 0c             	mov    0xc(%ebp),%eax
80105845:	89 10                	mov    %edx,(%eax)
  return 0;
80105847:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010584c:	c9                   	leave  
8010584d:	c3                   	ret    

8010584e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010584e:	f3 0f 1e fb          	endbr32 
80105852:	55                   	push   %ebp
80105853:	89 e5                	mov    %esp,%ebp
80105855:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105858:	e8 77 ec ff ff       	call   801044d4 <myproc>
8010585d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	8b 00                	mov    (%eax),%eax
80105865:	39 45 08             	cmp    %eax,0x8(%ebp)
80105868:	72 07                	jb     80105871 <fetchstr+0x23>
    return -1;
8010586a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010586f:	eb 43                	jmp    801058b4 <fetchstr+0x66>
  *pp = (char*)addr;
80105871:	8b 55 08             	mov    0x8(%ebp),%edx
80105874:	8b 45 0c             	mov    0xc(%ebp),%eax
80105877:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587c:	8b 00                	mov    (%eax),%eax
8010587e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105881:	8b 45 0c             	mov    0xc(%ebp),%eax
80105884:	8b 00                	mov    (%eax),%eax
80105886:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105889:	eb 1c                	jmp    801058a7 <fetchstr+0x59>
    if(*s == 0)
8010588b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588e:	0f b6 00             	movzbl (%eax),%eax
80105891:	84 c0                	test   %al,%al
80105893:	75 0e                	jne    801058a3 <fetchstr+0x55>
      return s - *pp;
80105895:	8b 45 0c             	mov    0xc(%ebp),%eax
80105898:	8b 00                	mov    (%eax),%eax
8010589a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010589d:	29 c2                	sub    %eax,%edx
8010589f:	89 d0                	mov    %edx,%eax
801058a1:	eb 11                	jmp    801058b4 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058ad:	72 dc                	jb     8010588b <fetchstr+0x3d>
  }
  return -1;
801058af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058b4:	c9                   	leave  
801058b5:	c3                   	ret    

801058b6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058b6:	f3 0f 1e fb          	endbr32 
801058ba:	55                   	push   %ebp
801058bb:	89 e5                	mov    %esp,%ebp
801058bd:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058c0:	e8 0f ec ff ff       	call   801044d4 <myproc>
801058c5:	8b 40 18             	mov    0x18(%eax),%eax
801058c8:	8b 40 44             	mov    0x44(%eax),%eax
801058cb:	8b 55 08             	mov    0x8(%ebp),%edx
801058ce:	c1 e2 02             	shl    $0x2,%edx
801058d1:	01 d0                	add    %edx,%eax
801058d3:	83 c0 04             	add    $0x4,%eax
801058d6:	83 ec 08             	sub    $0x8,%esp
801058d9:	ff 75 0c             	pushl  0xc(%ebp)
801058dc:	50                   	push   %eax
801058dd:	e8 29 ff ff ff       	call   8010580b <fetchint>
801058e2:	83 c4 10             	add    $0x10,%esp
}
801058e5:	c9                   	leave  
801058e6:	c3                   	ret    

801058e7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058e7:	f3 0f 1e fb          	endbr32 
801058eb:	55                   	push   %ebp
801058ec:	89 e5                	mov    %esp,%ebp
801058ee:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801058f1:	e8 de eb ff ff       	call   801044d4 <myproc>
801058f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801058f9:	83 ec 08             	sub    $0x8,%esp
801058fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ff:	50                   	push   %eax
80105900:	ff 75 08             	pushl  0x8(%ebp)
80105903:	e8 ae ff ff ff       	call   801058b6 <argint>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	85 c0                	test   %eax,%eax
8010590d:	79 07                	jns    80105916 <argptr+0x2f>
    return -1;
8010590f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105914:	eb 3b                	jmp    80105951 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010591a:	78 1f                	js     8010593b <argptr+0x54>
8010591c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591f:	8b 00                	mov    (%eax),%eax
80105921:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105924:	39 d0                	cmp    %edx,%eax
80105926:	76 13                	jbe    8010593b <argptr+0x54>
80105928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592b:	89 c2                	mov    %eax,%edx
8010592d:	8b 45 10             	mov    0x10(%ebp),%eax
80105930:	01 c2                	add    %eax,%edx
80105932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105935:	8b 00                	mov    (%eax),%eax
80105937:	39 c2                	cmp    %eax,%edx
80105939:	76 07                	jbe    80105942 <argptr+0x5b>
    return -1;
8010593b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105940:	eb 0f                	jmp    80105951 <argptr+0x6a>
  *pp = (char*)i;
80105942:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105945:	89 c2                	mov    %eax,%edx
80105947:	8b 45 0c             	mov    0xc(%ebp),%eax
8010594a:	89 10                	mov    %edx,(%eax)
  return 0;
8010594c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105951:	c9                   	leave  
80105952:	c3                   	ret    

80105953 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105953:	f3 0f 1e fb          	endbr32 
80105957:	55                   	push   %ebp
80105958:	89 e5                	mov    %esp,%ebp
8010595a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010595d:	83 ec 08             	sub    $0x8,%esp
80105960:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105963:	50                   	push   %eax
80105964:	ff 75 08             	pushl  0x8(%ebp)
80105967:	e8 4a ff ff ff       	call   801058b6 <argint>
8010596c:	83 c4 10             	add    $0x10,%esp
8010596f:	85 c0                	test   %eax,%eax
80105971:	79 07                	jns    8010597a <argstr+0x27>
    return -1;
80105973:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105978:	eb 12                	jmp    8010598c <argstr+0x39>
  return fetchstr(addr, pp);
8010597a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597d:	83 ec 08             	sub    $0x8,%esp
80105980:	ff 75 0c             	pushl  0xc(%ebp)
80105983:	50                   	push   %eax
80105984:	e8 c5 fe ff ff       	call   8010584e <fetchstr>
80105989:	83 c4 10             	add    $0x10,%esp
}
8010598c:	c9                   	leave  
8010598d:	c3                   	ret    

8010598e <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
8010598e:	f3 0f 1e fb          	endbr32 
80105992:	55                   	push   %ebp
80105993:	89 e5                	mov    %esp,%ebp
80105995:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105998:	e8 37 eb ff ff       	call   801044d4 <myproc>
8010599d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a3:	8b 40 18             	mov    0x18(%eax),%eax
801059a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801059a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059b0:	7e 2f                	jle    801059e1 <syscall+0x53>
801059b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b5:	83 f8 18             	cmp    $0x18,%eax
801059b8:	77 27                	ja     801059e1 <syscall+0x53>
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059c4:	85 c0                	test   %eax,%eax
801059c6:	74 19                	je     801059e1 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cb:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059d2:	ff d0                	call   *%eax
801059d4:	89 c2                	mov    %eax,%edx
801059d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d9:	8b 40 18             	mov    0x18(%eax),%eax
801059dc:	89 50 1c             	mov    %edx,0x1c(%eax)
801059df:	eb 2c                	jmp    80105a0d <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e4:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ea:	8b 40 10             	mov    0x10(%eax),%eax
801059ed:	ff 75 f0             	pushl  -0x10(%ebp)
801059f0:	52                   	push   %edx
801059f1:	50                   	push   %eax
801059f2:	68 f4 97 10 80       	push   $0x801097f4
801059f7:	e8 1c aa ff ff       	call   80100418 <cprintf>
801059fc:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801059ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a02:	8b 40 18             	mov    0x18(%eax),%eax
80105a05:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a0c:	90                   	nop
80105a0d:	90                   	nop
80105a0e:	c9                   	leave  
80105a0f:	c3                   	ret    

80105a10 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a10:	f3 0f 1e fb          	endbr32 
80105a14:	55                   	push   %ebp
80105a15:	89 e5                	mov    %esp,%ebp
80105a17:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a1a:	83 ec 08             	sub    $0x8,%esp
80105a1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a20:	50                   	push   %eax
80105a21:	ff 75 08             	pushl  0x8(%ebp)
80105a24:	e8 8d fe ff ff       	call   801058b6 <argint>
80105a29:	83 c4 10             	add    $0x10,%esp
80105a2c:	85 c0                	test   %eax,%eax
80105a2e:	79 07                	jns    80105a37 <argfd+0x27>
    return -1;
80105a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a35:	eb 4f                	jmp    80105a86 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3a:	85 c0                	test   %eax,%eax
80105a3c:	78 20                	js     80105a5e <argfd+0x4e>
80105a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a41:	83 f8 0f             	cmp    $0xf,%eax
80105a44:	7f 18                	jg     80105a5e <argfd+0x4e>
80105a46:	e8 89 ea ff ff       	call   801044d4 <myproc>
80105a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4e:	83 c2 08             	add    $0x8,%edx
80105a51:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a5c:	75 07                	jne    80105a65 <argfd+0x55>
    return -1;
80105a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a63:	eb 21                	jmp    80105a86 <argfd+0x76>
  if(pfd)
80105a65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a69:	74 08                	je     80105a73 <argfd+0x63>
    *pfd = fd;
80105a6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a71:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a77:	74 08                	je     80105a81 <argfd+0x71>
    *pf = f;
80105a79:	8b 45 10             	mov    0x10(%ebp),%eax
80105a7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a7f:	89 10                	mov    %edx,(%eax)
  return 0;
80105a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a86:	c9                   	leave  
80105a87:	c3                   	ret    

80105a88 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a88:	f3 0f 1e fb          	endbr32 
80105a8c:	55                   	push   %ebp
80105a8d:	89 e5                	mov    %esp,%ebp
80105a8f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a92:	e8 3d ea ff ff       	call   801044d4 <myproc>
80105a97:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105aa1:	eb 2a                	jmp    80105acd <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa9:	83 c2 08             	add    $0x8,%edx
80105aac:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ab0:	85 c0                	test   %eax,%eax
80105ab2:	75 15                	jne    80105ac9 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aba:	8d 4a 08             	lea    0x8(%edx),%ecx
80105abd:	8b 55 08             	mov    0x8(%ebp),%edx
80105ac0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac7:	eb 0f                	jmp    80105ad8 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105ac9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105acd:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ad1:	7e d0                	jle    80105aa3 <fdalloc+0x1b>
    }
  }
  return -1;
80105ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ad8:	c9                   	leave  
80105ad9:	c3                   	ret    

80105ada <sys_dup>:

int
sys_dup(void)
{
80105ada:	f3 0f 1e fb          	endbr32 
80105ade:	55                   	push   %ebp
80105adf:	89 e5                	mov    %esp,%ebp
80105ae1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105ae4:	83 ec 04             	sub    $0x4,%esp
80105ae7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aea:	50                   	push   %eax
80105aeb:	6a 00                	push   $0x0
80105aed:	6a 00                	push   $0x0
80105aef:	e8 1c ff ff ff       	call   80105a10 <argfd>
80105af4:	83 c4 10             	add    $0x10,%esp
80105af7:	85 c0                	test   %eax,%eax
80105af9:	79 07                	jns    80105b02 <sys_dup+0x28>
    return -1;
80105afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b00:	eb 31                	jmp    80105b33 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	50                   	push   %eax
80105b09:	e8 7a ff ff ff       	call   80105a88 <fdalloc>
80105b0e:	83 c4 10             	add    $0x10,%esp
80105b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b18:	79 07                	jns    80105b21 <sys_dup+0x47>
    return -1;
80105b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1f:	eb 12                	jmp    80105b33 <sys_dup+0x59>
  filedup(f);
80105b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b24:	83 ec 0c             	sub    $0xc,%esp
80105b27:	50                   	push   %eax
80105b28:	e8 1e b6 ff ff       	call   8010114b <filedup>
80105b2d:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b33:	c9                   	leave  
80105b34:	c3                   	ret    

80105b35 <sys_read>:

int
sys_read(void)
{
80105b35:	f3 0f 1e fb          	endbr32 
80105b39:	55                   	push   %ebp
80105b3a:	89 e5                	mov    %esp,%ebp
80105b3c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b3f:	83 ec 04             	sub    $0x4,%esp
80105b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b45:	50                   	push   %eax
80105b46:	6a 00                	push   $0x0
80105b48:	6a 00                	push   $0x0
80105b4a:	e8 c1 fe ff ff       	call   80105a10 <argfd>
80105b4f:	83 c4 10             	add    $0x10,%esp
80105b52:	85 c0                	test   %eax,%eax
80105b54:	78 2e                	js     80105b84 <sys_read+0x4f>
80105b56:	83 ec 08             	sub    $0x8,%esp
80105b59:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b5c:	50                   	push   %eax
80105b5d:	6a 02                	push   $0x2
80105b5f:	e8 52 fd ff ff       	call   801058b6 <argint>
80105b64:	83 c4 10             	add    $0x10,%esp
80105b67:	85 c0                	test   %eax,%eax
80105b69:	78 19                	js     80105b84 <sys_read+0x4f>
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	83 ec 04             	sub    $0x4,%esp
80105b71:	50                   	push   %eax
80105b72:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b75:	50                   	push   %eax
80105b76:	6a 01                	push   $0x1
80105b78:	e8 6a fd ff ff       	call   801058e7 <argptr>
80105b7d:	83 c4 10             	add    $0x10,%esp
80105b80:	85 c0                	test   %eax,%eax
80105b82:	79 07                	jns    80105b8b <sys_read+0x56>
    return -1;
80105b84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b89:	eb 17                	jmp    80105ba2 <sys_read+0x6d>
  return fileread(f, p, n);
80105b8b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b94:	83 ec 04             	sub    $0x4,%esp
80105b97:	51                   	push   %ecx
80105b98:	52                   	push   %edx
80105b99:	50                   	push   %eax
80105b9a:	e8 48 b7 ff ff       	call   801012e7 <fileread>
80105b9f:	83 c4 10             	add    $0x10,%esp
}
80105ba2:	c9                   	leave  
80105ba3:	c3                   	ret    

80105ba4 <sys_write>:

int
sys_write(void)
{
80105ba4:	f3 0f 1e fb          	endbr32 
80105ba8:	55                   	push   %ebp
80105ba9:	89 e5                	mov    %esp,%ebp
80105bab:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bae:	83 ec 04             	sub    $0x4,%esp
80105bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bb4:	50                   	push   %eax
80105bb5:	6a 00                	push   $0x0
80105bb7:	6a 00                	push   $0x0
80105bb9:	e8 52 fe ff ff       	call   80105a10 <argfd>
80105bbe:	83 c4 10             	add    $0x10,%esp
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	78 2e                	js     80105bf3 <sys_write+0x4f>
80105bc5:	83 ec 08             	sub    $0x8,%esp
80105bc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bcb:	50                   	push   %eax
80105bcc:	6a 02                	push   $0x2
80105bce:	e8 e3 fc ff ff       	call   801058b6 <argint>
80105bd3:	83 c4 10             	add    $0x10,%esp
80105bd6:	85 c0                	test   %eax,%eax
80105bd8:	78 19                	js     80105bf3 <sys_write+0x4f>
80105bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdd:	83 ec 04             	sub    $0x4,%esp
80105be0:	50                   	push   %eax
80105be1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105be4:	50                   	push   %eax
80105be5:	6a 01                	push   $0x1
80105be7:	e8 fb fc ff ff       	call   801058e7 <argptr>
80105bec:	83 c4 10             	add    $0x10,%esp
80105bef:	85 c0                	test   %eax,%eax
80105bf1:	79 07                	jns    80105bfa <sys_write+0x56>
    return -1;
80105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf8:	eb 17                	jmp    80105c11 <sys_write+0x6d>
  return filewrite(f, p, n);
80105bfa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c03:	83 ec 04             	sub    $0x4,%esp
80105c06:	51                   	push   %ecx
80105c07:	52                   	push   %edx
80105c08:	50                   	push   %eax
80105c09:	e8 95 b7 ff ff       	call   801013a3 <filewrite>
80105c0e:	83 c4 10             	add    $0x10,%esp
}
80105c11:	c9                   	leave  
80105c12:	c3                   	ret    

80105c13 <sys_close>:

int
sys_close(void)
{
80105c13:	f3 0f 1e fb          	endbr32 
80105c17:	55                   	push   %ebp
80105c18:	89 e5                	mov    %esp,%ebp
80105c1a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c1d:	83 ec 04             	sub    $0x4,%esp
80105c20:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c23:	50                   	push   %eax
80105c24:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c27:	50                   	push   %eax
80105c28:	6a 00                	push   $0x0
80105c2a:	e8 e1 fd ff ff       	call   80105a10 <argfd>
80105c2f:	83 c4 10             	add    $0x10,%esp
80105c32:	85 c0                	test   %eax,%eax
80105c34:	79 07                	jns    80105c3d <sys_close+0x2a>
    return -1;
80105c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3b:	eb 27                	jmp    80105c64 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c3d:	e8 92 e8 ff ff       	call   801044d4 <myproc>
80105c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c45:	83 c2 08             	add    $0x8,%edx
80105c48:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c4f:	00 
  fileclose(f);
80105c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c53:	83 ec 0c             	sub    $0xc,%esp
80105c56:	50                   	push   %eax
80105c57:	e8 44 b5 ff ff       	call   801011a0 <fileclose>
80105c5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c64:	c9                   	leave  
80105c65:	c3                   	ret    

80105c66 <sys_fstat>:

int
sys_fstat(void)
{
80105c66:	f3 0f 1e fb          	endbr32 
80105c6a:	55                   	push   %ebp
80105c6b:	89 e5                	mov    %esp,%ebp
80105c6d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c70:	83 ec 04             	sub    $0x4,%esp
80105c73:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c76:	50                   	push   %eax
80105c77:	6a 00                	push   $0x0
80105c79:	6a 00                	push   $0x0
80105c7b:	e8 90 fd ff ff       	call   80105a10 <argfd>
80105c80:	83 c4 10             	add    $0x10,%esp
80105c83:	85 c0                	test   %eax,%eax
80105c85:	78 17                	js     80105c9e <sys_fstat+0x38>
80105c87:	83 ec 04             	sub    $0x4,%esp
80105c8a:	6a 14                	push   $0x14
80105c8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c8f:	50                   	push   %eax
80105c90:	6a 01                	push   $0x1
80105c92:	e8 50 fc ff ff       	call   801058e7 <argptr>
80105c97:	83 c4 10             	add    $0x10,%esp
80105c9a:	85 c0                	test   %eax,%eax
80105c9c:	79 07                	jns    80105ca5 <sys_fstat+0x3f>
    return -1;
80105c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca3:	eb 13                	jmp    80105cb8 <sys_fstat+0x52>
  return filestat(f, st);
80105ca5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cab:	83 ec 08             	sub    $0x8,%esp
80105cae:	52                   	push   %edx
80105caf:	50                   	push   %eax
80105cb0:	e8 d7 b5 ff ff       	call   8010128c <filestat>
80105cb5:	83 c4 10             	add    $0x10,%esp
}
80105cb8:	c9                   	leave  
80105cb9:	c3                   	ret    

80105cba <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cba:	f3 0f 1e fb          	endbr32 
80105cbe:	55                   	push   %ebp
80105cbf:	89 e5                	mov    %esp,%ebp
80105cc1:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cc4:	83 ec 08             	sub    $0x8,%esp
80105cc7:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cca:	50                   	push   %eax
80105ccb:	6a 00                	push   $0x0
80105ccd:	e8 81 fc ff ff       	call   80105953 <argstr>
80105cd2:	83 c4 10             	add    $0x10,%esp
80105cd5:	85 c0                	test   %eax,%eax
80105cd7:	78 15                	js     80105cee <sys_link+0x34>
80105cd9:	83 ec 08             	sub    $0x8,%esp
80105cdc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cdf:	50                   	push   %eax
80105ce0:	6a 01                	push   $0x1
80105ce2:	e8 6c fc ff ff       	call   80105953 <argstr>
80105ce7:	83 c4 10             	add    $0x10,%esp
80105cea:	85 c0                	test   %eax,%eax
80105cec:	79 0a                	jns    80105cf8 <sys_link+0x3e>
    return -1;
80105cee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf3:	e9 68 01 00 00       	jmp    80105e60 <sys_link+0x1a6>

  begin_op();
80105cf8:	e8 18 da ff ff       	call   80103715 <begin_op>
  if((ip = namei(old)) == 0){
80105cfd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d00:	83 ec 0c             	sub    $0xc,%esp
80105d03:	50                   	push   %eax
80105d04:	e8 82 c9 ff ff       	call   8010268b <namei>
80105d09:	83 c4 10             	add    $0x10,%esp
80105d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d13:	75 0f                	jne    80105d24 <sys_link+0x6a>
    end_op();
80105d15:	e8 8b da ff ff       	call   801037a5 <end_op>
    return -1;
80105d1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1f:	e9 3c 01 00 00       	jmp    80105e60 <sys_link+0x1a6>
  }

  ilock(ip);
80105d24:	83 ec 0c             	sub    $0xc,%esp
80105d27:	ff 75 f4             	pushl  -0xc(%ebp)
80105d2a:	e8 f1 bd ff ff       	call   80101b20 <ilock>
80105d2f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d35:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d39:	66 83 f8 01          	cmp    $0x1,%ax
80105d3d:	75 1d                	jne    80105d5c <sys_link+0xa2>
    iunlockput(ip);
80105d3f:	83 ec 0c             	sub    $0xc,%esp
80105d42:	ff 75 f4             	pushl  -0xc(%ebp)
80105d45:	e8 13 c0 ff ff       	call   80101d5d <iunlockput>
80105d4a:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d4d:	e8 53 da ff ff       	call   801037a5 <end_op>
    return -1;
80105d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d57:	e9 04 01 00 00       	jmp    80105e60 <sys_link+0x1a6>
  }

  ip->nlink++;
80105d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d63:	83 c0 01             	add    $0x1,%eax
80105d66:	89 c2                	mov    %eax,%edx
80105d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d6f:	83 ec 0c             	sub    $0xc,%esp
80105d72:	ff 75 f4             	pushl  -0xc(%ebp)
80105d75:	e8 bd bb ff ff       	call   80101937 <iupdate>
80105d7a:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d7d:	83 ec 0c             	sub    $0xc,%esp
80105d80:	ff 75 f4             	pushl  -0xc(%ebp)
80105d83:	e8 af be ff ff       	call   80101c37 <iunlock>
80105d88:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d8e:	83 ec 08             	sub    $0x8,%esp
80105d91:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d94:	52                   	push   %edx
80105d95:	50                   	push   %eax
80105d96:	e8 10 c9 ff ff       	call   801026ab <nameiparent>
80105d9b:	83 c4 10             	add    $0x10,%esp
80105d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105da1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da5:	74 71                	je     80105e18 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105da7:	83 ec 0c             	sub    $0xc,%esp
80105daa:	ff 75 f0             	pushl  -0x10(%ebp)
80105dad:	e8 6e bd ff ff       	call   80101b20 <ilock>
80105db2:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db8:	8b 10                	mov    (%eax),%edx
80105dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbd:	8b 00                	mov    (%eax),%eax
80105dbf:	39 c2                	cmp    %eax,%edx
80105dc1:	75 1d                	jne    80105de0 <sys_link+0x126>
80105dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc6:	8b 40 04             	mov    0x4(%eax),%eax
80105dc9:	83 ec 04             	sub    $0x4,%esp
80105dcc:	50                   	push   %eax
80105dcd:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dd0:	50                   	push   %eax
80105dd1:	ff 75 f0             	pushl  -0x10(%ebp)
80105dd4:	e8 0f c6 ff ff       	call   801023e8 <dirlink>
80105dd9:	83 c4 10             	add    $0x10,%esp
80105ddc:	85 c0                	test   %eax,%eax
80105dde:	79 10                	jns    80105df0 <sys_link+0x136>
    iunlockput(dp);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	ff 75 f0             	pushl  -0x10(%ebp)
80105de6:	e8 72 bf ff ff       	call   80101d5d <iunlockput>
80105deb:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105dee:	eb 29                	jmp    80105e19 <sys_link+0x15f>
  }
  iunlockput(dp);
80105df0:	83 ec 0c             	sub    $0xc,%esp
80105df3:	ff 75 f0             	pushl  -0x10(%ebp)
80105df6:	e8 62 bf ff ff       	call   80101d5d <iunlockput>
80105dfb:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105dfe:	83 ec 0c             	sub    $0xc,%esp
80105e01:	ff 75 f4             	pushl  -0xc(%ebp)
80105e04:	e8 80 be ff ff       	call   80101c89 <iput>
80105e09:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e0c:	e8 94 d9 ff ff       	call   801037a5 <end_op>

  return 0;
80105e11:	b8 00 00 00 00       	mov    $0x0,%eax
80105e16:	eb 48                	jmp    80105e60 <sys_link+0x1a6>
    goto bad;
80105e18:	90                   	nop

bad:
  ilock(ip);
80105e19:	83 ec 0c             	sub    $0xc,%esp
80105e1c:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1f:	e8 fc bc ff ff       	call   80101b20 <ilock>
80105e24:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e2e:	83 e8 01             	sub    $0x1,%eax
80105e31:	89 c2                	mov    %eax,%edx
80105e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e36:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e3a:	83 ec 0c             	sub    $0xc,%esp
80105e3d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e40:	e8 f2 ba ff ff       	call   80101937 <iupdate>
80105e45:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e48:	83 ec 0c             	sub    $0xc,%esp
80105e4b:	ff 75 f4             	pushl  -0xc(%ebp)
80105e4e:	e8 0a bf ff ff       	call   80101d5d <iunlockput>
80105e53:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e56:	e8 4a d9 ff ff       	call   801037a5 <end_op>
  return -1;
80105e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e60:	c9                   	leave  
80105e61:	c3                   	ret    

80105e62 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e62:	f3 0f 1e fb          	endbr32 
80105e66:	55                   	push   %ebp
80105e67:	89 e5                	mov    %esp,%ebp
80105e69:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e6c:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e73:	eb 40                	jmp    80105eb5 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e78:	6a 10                	push   $0x10
80105e7a:	50                   	push   %eax
80105e7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e7e:	50                   	push   %eax
80105e7f:	ff 75 08             	pushl  0x8(%ebp)
80105e82:	e8 a1 c1 ff ff       	call   80102028 <readi>
80105e87:	83 c4 10             	add    $0x10,%esp
80105e8a:	83 f8 10             	cmp    $0x10,%eax
80105e8d:	74 0d                	je     80105e9c <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e8f:	83 ec 0c             	sub    $0xc,%esp
80105e92:	68 10 98 10 80       	push   $0x80109810
80105e97:	e8 6c a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e9c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ea0:	66 85 c0             	test   %ax,%ax
80105ea3:	74 07                	je     80105eac <isdirempty+0x4a>
      return 0;
80105ea5:	b8 00 00 00 00       	mov    $0x0,%eax
80105eaa:	eb 1b                	jmp    80105ec7 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eaf:	83 c0 10             	add    $0x10,%eax
80105eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb8:	8b 50 58             	mov    0x58(%eax),%edx
80105ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebe:	39 c2                	cmp    %eax,%edx
80105ec0:	77 b3                	ja     80105e75 <isdirempty+0x13>
  }
  return 1;
80105ec2:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ec7:	c9                   	leave  
80105ec8:	c3                   	ret    

80105ec9 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ec9:	f3 0f 1e fb          	endbr32 
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ed3:	83 ec 08             	sub    $0x8,%esp
80105ed6:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ed9:	50                   	push   %eax
80105eda:	6a 00                	push   $0x0
80105edc:	e8 72 fa ff ff       	call   80105953 <argstr>
80105ee1:	83 c4 10             	add    $0x10,%esp
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	79 0a                	jns    80105ef2 <sys_unlink+0x29>
    return -1;
80105ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eed:	e9 bf 01 00 00       	jmp    801060b1 <sys_unlink+0x1e8>

  begin_op();
80105ef2:	e8 1e d8 ff ff       	call   80103715 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ef7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105efa:	83 ec 08             	sub    $0x8,%esp
80105efd:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f00:	52                   	push   %edx
80105f01:	50                   	push   %eax
80105f02:	e8 a4 c7 ff ff       	call   801026ab <nameiparent>
80105f07:	83 c4 10             	add    $0x10,%esp
80105f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f11:	75 0f                	jne    80105f22 <sys_unlink+0x59>
    end_op();
80105f13:	e8 8d d8 ff ff       	call   801037a5 <end_op>
    return -1;
80105f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1d:	e9 8f 01 00 00       	jmp    801060b1 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f22:	83 ec 0c             	sub    $0xc,%esp
80105f25:	ff 75 f4             	pushl  -0xc(%ebp)
80105f28:	e8 f3 bb ff ff       	call   80101b20 <ilock>
80105f2d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f30:	83 ec 08             	sub    $0x8,%esp
80105f33:	68 22 98 10 80       	push   $0x80109822
80105f38:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f3b:	50                   	push   %eax
80105f3c:	e8 ca c3 ff ff       	call   8010230b <namecmp>
80105f41:	83 c4 10             	add    $0x10,%esp
80105f44:	85 c0                	test   %eax,%eax
80105f46:	0f 84 49 01 00 00    	je     80106095 <sys_unlink+0x1cc>
80105f4c:	83 ec 08             	sub    $0x8,%esp
80105f4f:	68 24 98 10 80       	push   $0x80109824
80105f54:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f57:	50                   	push   %eax
80105f58:	e8 ae c3 ff ff       	call   8010230b <namecmp>
80105f5d:	83 c4 10             	add    $0x10,%esp
80105f60:	85 c0                	test   %eax,%eax
80105f62:	0f 84 2d 01 00 00    	je     80106095 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f68:	83 ec 04             	sub    $0x4,%esp
80105f6b:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f6e:	50                   	push   %eax
80105f6f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f72:	50                   	push   %eax
80105f73:	ff 75 f4             	pushl  -0xc(%ebp)
80105f76:	e8 af c3 ff ff       	call   8010232a <dirlookup>
80105f7b:	83 c4 10             	add    $0x10,%esp
80105f7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f85:	0f 84 0d 01 00 00    	je     80106098 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f8b:	83 ec 0c             	sub    $0xc,%esp
80105f8e:	ff 75 f0             	pushl  -0x10(%ebp)
80105f91:	e8 8a bb ff ff       	call   80101b20 <ilock>
80105f96:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fa0:	66 85 c0             	test   %ax,%ax
80105fa3:	7f 0d                	jg     80105fb2 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fa5:	83 ec 0c             	sub    $0xc,%esp
80105fa8:	68 27 98 10 80       	push   $0x80109827
80105fad:	e8 56 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fb9:	66 83 f8 01          	cmp    $0x1,%ax
80105fbd:	75 25                	jne    80105fe4 <sys_unlink+0x11b>
80105fbf:	83 ec 0c             	sub    $0xc,%esp
80105fc2:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc5:	e8 98 fe ff ff       	call   80105e62 <isdirempty>
80105fca:	83 c4 10             	add    $0x10,%esp
80105fcd:	85 c0                	test   %eax,%eax
80105fcf:	75 13                	jne    80105fe4 <sys_unlink+0x11b>
    iunlockput(ip);
80105fd1:	83 ec 0c             	sub    $0xc,%esp
80105fd4:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd7:	e8 81 bd ff ff       	call   80101d5d <iunlockput>
80105fdc:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fdf:	e9 b5 00 00 00       	jmp    80106099 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105fe4:	83 ec 04             	sub    $0x4,%esp
80105fe7:	6a 10                	push   $0x10
80105fe9:	6a 00                	push   $0x0
80105feb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fee:	50                   	push   %eax
80105fef:	e8 6e f5 ff ff       	call   80105562 <memset>
80105ff4:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ff7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ffa:	6a 10                	push   $0x10
80105ffc:	50                   	push   %eax
80105ffd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106000:	50                   	push   %eax
80106001:	ff 75 f4             	pushl  -0xc(%ebp)
80106004:	e8 78 c1 ff ff       	call   80102181 <writei>
80106009:	83 c4 10             	add    $0x10,%esp
8010600c:	83 f8 10             	cmp    $0x10,%eax
8010600f:	74 0d                	je     8010601e <sys_unlink+0x155>
    panic("unlink: writei");
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	68 39 98 10 80       	push   $0x80109839
80106019:	e8 ea a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
8010601e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106021:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106025:	66 83 f8 01          	cmp    $0x1,%ax
80106029:	75 21                	jne    8010604c <sys_unlink+0x183>
    dp->nlink--;
8010602b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106032:	83 e8 01             	sub    $0x1,%eax
80106035:	89 c2                	mov    %eax,%edx
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010603e:	83 ec 0c             	sub    $0xc,%esp
80106041:	ff 75 f4             	pushl  -0xc(%ebp)
80106044:	e8 ee b8 ff ff       	call   80101937 <iupdate>
80106049:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010604c:	83 ec 0c             	sub    $0xc,%esp
8010604f:	ff 75 f4             	pushl  -0xc(%ebp)
80106052:	e8 06 bd ff ff       	call   80101d5d <iunlockput>
80106057:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010605a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106061:	83 e8 01             	sub    $0x1,%eax
80106064:	89 c2                	mov    %eax,%edx
80106066:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106069:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010606d:	83 ec 0c             	sub    $0xc,%esp
80106070:	ff 75 f0             	pushl  -0x10(%ebp)
80106073:	e8 bf b8 ff ff       	call   80101937 <iupdate>
80106078:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	ff 75 f0             	pushl  -0x10(%ebp)
80106081:	e8 d7 bc ff ff       	call   80101d5d <iunlockput>
80106086:	83 c4 10             	add    $0x10,%esp

  end_op();
80106089:	e8 17 d7 ff ff       	call   801037a5 <end_op>

  return 0;
8010608e:	b8 00 00 00 00       	mov    $0x0,%eax
80106093:	eb 1c                	jmp    801060b1 <sys_unlink+0x1e8>
    goto bad;
80106095:	90                   	nop
80106096:	eb 01                	jmp    80106099 <sys_unlink+0x1d0>
    goto bad;
80106098:	90                   	nop

bad:
  iunlockput(dp);
80106099:	83 ec 0c             	sub    $0xc,%esp
8010609c:	ff 75 f4             	pushl  -0xc(%ebp)
8010609f:	e8 b9 bc ff ff       	call   80101d5d <iunlockput>
801060a4:	83 c4 10             	add    $0x10,%esp
  end_op();
801060a7:	e8 f9 d6 ff ff       	call   801037a5 <end_op>
  return -1;
801060ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060b1:	c9                   	leave  
801060b2:	c3                   	ret    

801060b3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060b3:	f3 0f 1e fb          	endbr32 
801060b7:	55                   	push   %ebp
801060b8:	89 e5                	mov    %esp,%ebp
801060ba:	83 ec 38             	sub    $0x38,%esp
801060bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060c0:	8b 55 10             	mov    0x10(%ebp),%edx
801060c3:	8b 45 14             	mov    0x14(%ebp),%eax
801060c6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060ca:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060ce:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060d2:	83 ec 08             	sub    $0x8,%esp
801060d5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060d8:	50                   	push   %eax
801060d9:	ff 75 08             	pushl  0x8(%ebp)
801060dc:	e8 ca c5 ff ff       	call   801026ab <nameiparent>
801060e1:	83 c4 10             	add    $0x10,%esp
801060e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060eb:	75 0a                	jne    801060f7 <create+0x44>
    return 0;
801060ed:	b8 00 00 00 00       	mov    $0x0,%eax
801060f2:	e9 8e 01 00 00       	jmp    80106285 <create+0x1d2>
  ilock(dp);
801060f7:	83 ec 0c             	sub    $0xc,%esp
801060fa:	ff 75 f4             	pushl  -0xc(%ebp)
801060fd:	e8 1e ba ff ff       	call   80101b20 <ilock>
80106102:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106105:	83 ec 04             	sub    $0x4,%esp
80106108:	6a 00                	push   $0x0
8010610a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010610d:	50                   	push   %eax
8010610e:	ff 75 f4             	pushl  -0xc(%ebp)
80106111:	e8 14 c2 ff ff       	call   8010232a <dirlookup>
80106116:	83 c4 10             	add    $0x10,%esp
80106119:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010611c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106120:	74 50                	je     80106172 <create+0xbf>
    iunlockput(dp);
80106122:	83 ec 0c             	sub    $0xc,%esp
80106125:	ff 75 f4             	pushl  -0xc(%ebp)
80106128:	e8 30 bc ff ff       	call   80101d5d <iunlockput>
8010612d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106130:	83 ec 0c             	sub    $0xc,%esp
80106133:	ff 75 f0             	pushl  -0x10(%ebp)
80106136:	e8 e5 b9 ff ff       	call   80101b20 <ilock>
8010613b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010613e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106143:	75 15                	jne    8010615a <create+0xa7>
80106145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106148:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010614c:	66 83 f8 02          	cmp    $0x2,%ax
80106150:	75 08                	jne    8010615a <create+0xa7>
      return ip;
80106152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106155:	e9 2b 01 00 00       	jmp    80106285 <create+0x1d2>
    iunlockput(ip);
8010615a:	83 ec 0c             	sub    $0xc,%esp
8010615d:	ff 75 f0             	pushl  -0x10(%ebp)
80106160:	e8 f8 bb ff ff       	call   80101d5d <iunlockput>
80106165:	83 c4 10             	add    $0x10,%esp
    return 0;
80106168:	b8 00 00 00 00       	mov    $0x0,%eax
8010616d:	e9 13 01 00 00       	jmp    80106285 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106172:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106179:	8b 00                	mov    (%eax),%eax
8010617b:	83 ec 08             	sub    $0x8,%esp
8010617e:	52                   	push   %edx
8010617f:	50                   	push   %eax
80106180:	e8 d7 b6 ff ff       	call   8010185c <ialloc>
80106185:	83 c4 10             	add    $0x10,%esp
80106188:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010618b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010618f:	75 0d                	jne    8010619e <create+0xeb>
    panic("create: ialloc");
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	68 48 98 10 80       	push   $0x80109848
80106199:	e8 6a a4 ff ff       	call   80100608 <panic>

  ilock(ip);
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	ff 75 f0             	pushl  -0x10(%ebp)
801061a4:	e8 77 b9 ff ff       	call   80101b20 <ilock>
801061a9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061af:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061b3:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ba:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061be:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c5:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061cb:	83 ec 0c             	sub    $0xc,%esp
801061ce:	ff 75 f0             	pushl  -0x10(%ebp)
801061d1:	e8 61 b7 ff ff       	call   80101937 <iupdate>
801061d6:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061d9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061de:	75 6a                	jne    8010624a <create+0x197>
    dp->nlink++;  // for ".."
801061e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061e7:	83 c0 01             	add    $0x1,%eax
801061ea:	89 c2                	mov    %eax,%edx
801061ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ef:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801061f3:	83 ec 0c             	sub    $0xc,%esp
801061f6:	ff 75 f4             	pushl  -0xc(%ebp)
801061f9:	e8 39 b7 ff ff       	call   80101937 <iupdate>
801061fe:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106204:	8b 40 04             	mov    0x4(%eax),%eax
80106207:	83 ec 04             	sub    $0x4,%esp
8010620a:	50                   	push   %eax
8010620b:	68 22 98 10 80       	push   $0x80109822
80106210:	ff 75 f0             	pushl  -0x10(%ebp)
80106213:	e8 d0 c1 ff ff       	call   801023e8 <dirlink>
80106218:	83 c4 10             	add    $0x10,%esp
8010621b:	85 c0                	test   %eax,%eax
8010621d:	78 1e                	js     8010623d <create+0x18a>
8010621f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106222:	8b 40 04             	mov    0x4(%eax),%eax
80106225:	83 ec 04             	sub    $0x4,%esp
80106228:	50                   	push   %eax
80106229:	68 24 98 10 80       	push   $0x80109824
8010622e:	ff 75 f0             	pushl  -0x10(%ebp)
80106231:	e8 b2 c1 ff ff       	call   801023e8 <dirlink>
80106236:	83 c4 10             	add    $0x10,%esp
80106239:	85 c0                	test   %eax,%eax
8010623b:	79 0d                	jns    8010624a <create+0x197>
      panic("create dots");
8010623d:	83 ec 0c             	sub    $0xc,%esp
80106240:	68 57 98 10 80       	push   $0x80109857
80106245:	e8 be a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010624a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624d:	8b 40 04             	mov    0x4(%eax),%eax
80106250:	83 ec 04             	sub    $0x4,%esp
80106253:	50                   	push   %eax
80106254:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106257:	50                   	push   %eax
80106258:	ff 75 f4             	pushl  -0xc(%ebp)
8010625b:	e8 88 c1 ff ff       	call   801023e8 <dirlink>
80106260:	83 c4 10             	add    $0x10,%esp
80106263:	85 c0                	test   %eax,%eax
80106265:	79 0d                	jns    80106274 <create+0x1c1>
    panic("create: dirlink");
80106267:	83 ec 0c             	sub    $0xc,%esp
8010626a:	68 63 98 10 80       	push   $0x80109863
8010626f:	e8 94 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106274:	83 ec 0c             	sub    $0xc,%esp
80106277:	ff 75 f4             	pushl  -0xc(%ebp)
8010627a:	e8 de ba ff ff       	call   80101d5d <iunlockput>
8010627f:	83 c4 10             	add    $0x10,%esp

  return ip;
80106282:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106285:	c9                   	leave  
80106286:	c3                   	ret    

80106287 <sys_open>:

int
sys_open(void)
{
80106287:	f3 0f 1e fb          	endbr32 
8010628b:	55                   	push   %ebp
8010628c:	89 e5                	mov    %esp,%ebp
8010628e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106291:	83 ec 08             	sub    $0x8,%esp
80106294:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106297:	50                   	push   %eax
80106298:	6a 00                	push   $0x0
8010629a:	e8 b4 f6 ff ff       	call   80105953 <argstr>
8010629f:	83 c4 10             	add    $0x10,%esp
801062a2:	85 c0                	test   %eax,%eax
801062a4:	78 15                	js     801062bb <sys_open+0x34>
801062a6:	83 ec 08             	sub    $0x8,%esp
801062a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062ac:	50                   	push   %eax
801062ad:	6a 01                	push   $0x1
801062af:	e8 02 f6 ff ff       	call   801058b6 <argint>
801062b4:	83 c4 10             	add    $0x10,%esp
801062b7:	85 c0                	test   %eax,%eax
801062b9:	79 0a                	jns    801062c5 <sys_open+0x3e>
    return -1;
801062bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c0:	e9 61 01 00 00       	jmp    80106426 <sys_open+0x19f>

  begin_op();
801062c5:	e8 4b d4 ff ff       	call   80103715 <begin_op>

  if(omode & O_CREATE){
801062ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062cd:	25 00 02 00 00       	and    $0x200,%eax
801062d2:	85 c0                	test   %eax,%eax
801062d4:	74 2a                	je     80106300 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062d9:	6a 00                	push   $0x0
801062db:	6a 00                	push   $0x0
801062dd:	6a 02                	push   $0x2
801062df:	50                   	push   %eax
801062e0:	e8 ce fd ff ff       	call   801060b3 <create>
801062e5:	83 c4 10             	add    $0x10,%esp
801062e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ef:	75 75                	jne    80106366 <sys_open+0xdf>
      end_op();
801062f1:	e8 af d4 ff ff       	call   801037a5 <end_op>
      return -1;
801062f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fb:	e9 26 01 00 00       	jmp    80106426 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106300:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106303:	83 ec 0c             	sub    $0xc,%esp
80106306:	50                   	push   %eax
80106307:	e8 7f c3 ff ff       	call   8010268b <namei>
8010630c:	83 c4 10             	add    $0x10,%esp
8010630f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106312:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106316:	75 0f                	jne    80106327 <sys_open+0xa0>
      end_op();
80106318:	e8 88 d4 ff ff       	call   801037a5 <end_op>
      return -1;
8010631d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106322:	e9 ff 00 00 00       	jmp    80106426 <sys_open+0x19f>
    }
    ilock(ip);
80106327:	83 ec 0c             	sub    $0xc,%esp
8010632a:	ff 75 f4             	pushl  -0xc(%ebp)
8010632d:	e8 ee b7 ff ff       	call   80101b20 <ilock>
80106332:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010633c:	66 83 f8 01          	cmp    $0x1,%ax
80106340:	75 24                	jne    80106366 <sys_open+0xdf>
80106342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106345:	85 c0                	test   %eax,%eax
80106347:	74 1d                	je     80106366 <sys_open+0xdf>
      iunlockput(ip);
80106349:	83 ec 0c             	sub    $0xc,%esp
8010634c:	ff 75 f4             	pushl  -0xc(%ebp)
8010634f:	e8 09 ba ff ff       	call   80101d5d <iunlockput>
80106354:	83 c4 10             	add    $0x10,%esp
      end_op();
80106357:	e8 49 d4 ff ff       	call   801037a5 <end_op>
      return -1;
8010635c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106361:	e9 c0 00 00 00       	jmp    80106426 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106366:	e8 6f ad ff ff       	call   801010da <filealloc>
8010636b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010636e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106372:	74 17                	je     8010638b <sys_open+0x104>
80106374:	83 ec 0c             	sub    $0xc,%esp
80106377:	ff 75 f0             	pushl  -0x10(%ebp)
8010637a:	e8 09 f7 ff ff       	call   80105a88 <fdalloc>
8010637f:	83 c4 10             	add    $0x10,%esp
80106382:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106385:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106389:	79 2e                	jns    801063b9 <sys_open+0x132>
    if(f)
8010638b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010638f:	74 0e                	je     8010639f <sys_open+0x118>
      fileclose(f);
80106391:	83 ec 0c             	sub    $0xc,%esp
80106394:	ff 75 f0             	pushl  -0x10(%ebp)
80106397:	e8 04 ae ff ff       	call   801011a0 <fileclose>
8010639c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010639f:	83 ec 0c             	sub    $0xc,%esp
801063a2:	ff 75 f4             	pushl  -0xc(%ebp)
801063a5:	e8 b3 b9 ff ff       	call   80101d5d <iunlockput>
801063aa:	83 c4 10             	add    $0x10,%esp
    end_op();
801063ad:	e8 f3 d3 ff ff       	call   801037a5 <end_op>
    return -1;
801063b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b7:	eb 6d                	jmp    80106426 <sys_open+0x19f>
  }
  iunlock(ip);
801063b9:	83 ec 0c             	sub    $0xc,%esp
801063bc:	ff 75 f4             	pushl  -0xc(%ebp)
801063bf:	e8 73 b8 ff ff       	call   80101c37 <iunlock>
801063c4:	83 c4 10             	add    $0x10,%esp
  end_op();
801063c7:	e8 d9 d3 ff ff       	call   801037a5 <end_op>

  f->type = FD_INODE;
801063cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cf:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063db:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063eb:	83 e0 01             	and    $0x1,%eax
801063ee:	85 c0                	test   %eax,%eax
801063f0:	0f 94 c0             	sete   %al
801063f3:	89 c2                	mov    %eax,%edx
801063f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f8:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063fe:	83 e0 01             	and    $0x1,%eax
80106401:	85 c0                	test   %eax,%eax
80106403:	75 0a                	jne    8010640f <sys_open+0x188>
80106405:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106408:	83 e0 02             	and    $0x2,%eax
8010640b:	85 c0                	test   %eax,%eax
8010640d:	74 07                	je     80106416 <sys_open+0x18f>
8010640f:	b8 01 00 00 00       	mov    $0x1,%eax
80106414:	eb 05                	jmp    8010641b <sys_open+0x194>
80106416:	b8 00 00 00 00       	mov    $0x0,%eax
8010641b:	89 c2                	mov    %eax,%edx
8010641d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106420:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106423:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106426:	c9                   	leave  
80106427:	c3                   	ret    

80106428 <sys_mkdir>:

int
sys_mkdir(void)
{
80106428:	f3 0f 1e fb          	endbr32 
8010642c:	55                   	push   %ebp
8010642d:	89 e5                	mov    %esp,%ebp
8010642f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106432:	e8 de d2 ff ff       	call   80103715 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106437:	83 ec 08             	sub    $0x8,%esp
8010643a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010643d:	50                   	push   %eax
8010643e:	6a 00                	push   $0x0
80106440:	e8 0e f5 ff ff       	call   80105953 <argstr>
80106445:	83 c4 10             	add    $0x10,%esp
80106448:	85 c0                	test   %eax,%eax
8010644a:	78 1b                	js     80106467 <sys_mkdir+0x3f>
8010644c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644f:	6a 00                	push   $0x0
80106451:	6a 00                	push   $0x0
80106453:	6a 01                	push   $0x1
80106455:	50                   	push   %eax
80106456:	e8 58 fc ff ff       	call   801060b3 <create>
8010645b:	83 c4 10             	add    $0x10,%esp
8010645e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106461:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106465:	75 0c                	jne    80106473 <sys_mkdir+0x4b>
    end_op();
80106467:	e8 39 d3 ff ff       	call   801037a5 <end_op>
    return -1;
8010646c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106471:	eb 18                	jmp    8010648b <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106473:	83 ec 0c             	sub    $0xc,%esp
80106476:	ff 75 f4             	pushl  -0xc(%ebp)
80106479:	e8 df b8 ff ff       	call   80101d5d <iunlockput>
8010647e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106481:	e8 1f d3 ff ff       	call   801037a5 <end_op>
  return 0;
80106486:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010648b:	c9                   	leave  
8010648c:	c3                   	ret    

8010648d <sys_mknod>:

int
sys_mknod(void)
{
8010648d:	f3 0f 1e fb          	endbr32 
80106491:	55                   	push   %ebp
80106492:	89 e5                	mov    %esp,%ebp
80106494:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106497:	e8 79 d2 ff ff       	call   80103715 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010649c:	83 ec 08             	sub    $0x8,%esp
8010649f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a2:	50                   	push   %eax
801064a3:	6a 00                	push   $0x0
801064a5:	e8 a9 f4 ff ff       	call   80105953 <argstr>
801064aa:	83 c4 10             	add    $0x10,%esp
801064ad:	85 c0                	test   %eax,%eax
801064af:	78 4f                	js     80106500 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064b1:	83 ec 08             	sub    $0x8,%esp
801064b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064b7:	50                   	push   %eax
801064b8:	6a 01                	push   $0x1
801064ba:	e8 f7 f3 ff ff       	call   801058b6 <argint>
801064bf:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064c2:	85 c0                	test   %eax,%eax
801064c4:	78 3a                	js     80106500 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064c6:	83 ec 08             	sub    $0x8,%esp
801064c9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064cc:	50                   	push   %eax
801064cd:	6a 02                	push   $0x2
801064cf:	e8 e2 f3 ff ff       	call   801058b6 <argint>
801064d4:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064d7:	85 c0                	test   %eax,%eax
801064d9:	78 25                	js     80106500 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064de:	0f bf c8             	movswl %ax,%ecx
801064e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064e4:	0f bf d0             	movswl %ax,%edx
801064e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ea:	51                   	push   %ecx
801064eb:	52                   	push   %edx
801064ec:	6a 03                	push   $0x3
801064ee:	50                   	push   %eax
801064ef:	e8 bf fb ff ff       	call   801060b3 <create>
801064f4:	83 c4 10             	add    $0x10,%esp
801064f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801064fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064fe:	75 0c                	jne    8010650c <sys_mknod+0x7f>
    end_op();
80106500:	e8 a0 d2 ff ff       	call   801037a5 <end_op>
    return -1;
80106505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650a:	eb 18                	jmp    80106524 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010650c:	83 ec 0c             	sub    $0xc,%esp
8010650f:	ff 75 f4             	pushl  -0xc(%ebp)
80106512:	e8 46 b8 ff ff       	call   80101d5d <iunlockput>
80106517:	83 c4 10             	add    $0x10,%esp
  end_op();
8010651a:	e8 86 d2 ff ff       	call   801037a5 <end_op>
  return 0;
8010651f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106524:	c9                   	leave  
80106525:	c3                   	ret    

80106526 <sys_chdir>:

int
sys_chdir(void)
{
80106526:	f3 0f 1e fb          	endbr32 
8010652a:	55                   	push   %ebp
8010652b:	89 e5                	mov    %esp,%ebp
8010652d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106530:	e8 9f df ff ff       	call   801044d4 <myproc>
80106535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106538:	e8 d8 d1 ff ff       	call   80103715 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010653d:	83 ec 08             	sub    $0x8,%esp
80106540:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106543:	50                   	push   %eax
80106544:	6a 00                	push   $0x0
80106546:	e8 08 f4 ff ff       	call   80105953 <argstr>
8010654b:	83 c4 10             	add    $0x10,%esp
8010654e:	85 c0                	test   %eax,%eax
80106550:	78 18                	js     8010656a <sys_chdir+0x44>
80106552:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106555:	83 ec 0c             	sub    $0xc,%esp
80106558:	50                   	push   %eax
80106559:	e8 2d c1 ff ff       	call   8010268b <namei>
8010655e:	83 c4 10             	add    $0x10,%esp
80106561:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106564:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106568:	75 0c                	jne    80106576 <sys_chdir+0x50>
    end_op();
8010656a:	e8 36 d2 ff ff       	call   801037a5 <end_op>
    return -1;
8010656f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106574:	eb 68                	jmp    801065de <sys_chdir+0xb8>
  }
  ilock(ip);
80106576:	83 ec 0c             	sub    $0xc,%esp
80106579:	ff 75 f0             	pushl  -0x10(%ebp)
8010657c:	e8 9f b5 ff ff       	call   80101b20 <ilock>
80106581:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106587:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010658b:	66 83 f8 01          	cmp    $0x1,%ax
8010658f:	74 1a                	je     801065ab <sys_chdir+0x85>
    iunlockput(ip);
80106591:	83 ec 0c             	sub    $0xc,%esp
80106594:	ff 75 f0             	pushl  -0x10(%ebp)
80106597:	e8 c1 b7 ff ff       	call   80101d5d <iunlockput>
8010659c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010659f:	e8 01 d2 ff ff       	call   801037a5 <end_op>
    return -1;
801065a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a9:	eb 33                	jmp    801065de <sys_chdir+0xb8>
  }
  iunlock(ip);
801065ab:	83 ec 0c             	sub    $0xc,%esp
801065ae:	ff 75 f0             	pushl  -0x10(%ebp)
801065b1:	e8 81 b6 ff ff       	call   80101c37 <iunlock>
801065b6:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bc:	8b 40 68             	mov    0x68(%eax),%eax
801065bf:	83 ec 0c             	sub    $0xc,%esp
801065c2:	50                   	push   %eax
801065c3:	e8 c1 b6 ff ff       	call   80101c89 <iput>
801065c8:	83 c4 10             	add    $0x10,%esp
  end_op();
801065cb:	e8 d5 d1 ff ff       	call   801037a5 <end_op>
  curproc->cwd = ip;
801065d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065d6:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065de:	c9                   	leave  
801065df:	c3                   	ret    

801065e0 <sys_exec>:

int
sys_exec(void)
{
801065e0:	f3 0f 1e fb          	endbr32 
801065e4:	55                   	push   %ebp
801065e5:	89 e5                	mov    %esp,%ebp
801065e7:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065ed:	83 ec 08             	sub    $0x8,%esp
801065f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065f3:	50                   	push   %eax
801065f4:	6a 00                	push   $0x0
801065f6:	e8 58 f3 ff ff       	call   80105953 <argstr>
801065fb:	83 c4 10             	add    $0x10,%esp
801065fe:	85 c0                	test   %eax,%eax
80106600:	78 18                	js     8010661a <sys_exec+0x3a>
80106602:	83 ec 08             	sub    $0x8,%esp
80106605:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010660b:	50                   	push   %eax
8010660c:	6a 01                	push   $0x1
8010660e:	e8 a3 f2 ff ff       	call   801058b6 <argint>
80106613:	83 c4 10             	add    $0x10,%esp
80106616:	85 c0                	test   %eax,%eax
80106618:	79 0a                	jns    80106624 <sys_exec+0x44>
    return -1;
8010661a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661f:	e9 c6 00 00 00       	jmp    801066ea <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106624:	83 ec 04             	sub    $0x4,%esp
80106627:	68 80 00 00 00       	push   $0x80
8010662c:	6a 00                	push   $0x0
8010662e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106634:	50                   	push   %eax
80106635:	e8 28 ef ff ff       	call   80105562 <memset>
8010663a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010663d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106647:	83 f8 1f             	cmp    $0x1f,%eax
8010664a:	76 0a                	jbe    80106656 <sys_exec+0x76>
      return -1;
8010664c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106651:	e9 94 00 00 00       	jmp    801066ea <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106659:	c1 e0 02             	shl    $0x2,%eax
8010665c:	89 c2                	mov    %eax,%edx
8010665e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106664:	01 c2                	add    %eax,%edx
80106666:	83 ec 08             	sub    $0x8,%esp
80106669:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010666f:	50                   	push   %eax
80106670:	52                   	push   %edx
80106671:	e8 95 f1 ff ff       	call   8010580b <fetchint>
80106676:	83 c4 10             	add    $0x10,%esp
80106679:	85 c0                	test   %eax,%eax
8010667b:	79 07                	jns    80106684 <sys_exec+0xa4>
      return -1;
8010667d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106682:	eb 66                	jmp    801066ea <sys_exec+0x10a>
    if(uarg == 0){
80106684:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010668a:	85 c0                	test   %eax,%eax
8010668c:	75 27                	jne    801066b5 <sys_exec+0xd5>
      argv[i] = 0;
8010668e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106691:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106698:	00 00 00 00 
      break;
8010669c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010669d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a0:	83 ec 08             	sub    $0x8,%esp
801066a3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066a9:	52                   	push   %edx
801066aa:	50                   	push   %eax
801066ab:	e8 80 a5 ff ff       	call   80100c30 <exec>
801066b0:	83 c4 10             	add    $0x10,%esp
801066b3:	eb 35                	jmp    801066ea <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066b5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066be:	c1 e2 02             	shl    $0x2,%edx
801066c1:	01 c2                	add    %eax,%edx
801066c3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066c9:	83 ec 08             	sub    $0x8,%esp
801066cc:	52                   	push   %edx
801066cd:	50                   	push   %eax
801066ce:	e8 7b f1 ff ff       	call   8010584e <fetchstr>
801066d3:	83 c4 10             	add    $0x10,%esp
801066d6:	85 c0                	test   %eax,%eax
801066d8:	79 07                	jns    801066e1 <sys_exec+0x101>
      return -1;
801066da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066df:	eb 09                	jmp    801066ea <sys_exec+0x10a>
  for(i=0;; i++){
801066e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066e5:	e9 5a ff ff ff       	jmp    80106644 <sys_exec+0x64>
}
801066ea:	c9                   	leave  
801066eb:	c3                   	ret    

801066ec <sys_pipe>:

int
sys_pipe(void)
{
801066ec:	f3 0f 1e fb          	endbr32 
801066f0:	55                   	push   %ebp
801066f1:	89 e5                	mov    %esp,%ebp
801066f3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066f6:	83 ec 04             	sub    $0x4,%esp
801066f9:	6a 08                	push   $0x8
801066fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066fe:	50                   	push   %eax
801066ff:	6a 00                	push   $0x0
80106701:	e8 e1 f1 ff ff       	call   801058e7 <argptr>
80106706:	83 c4 10             	add    $0x10,%esp
80106709:	85 c0                	test   %eax,%eax
8010670b:	79 0a                	jns    80106717 <sys_pipe+0x2b>
    return -1;
8010670d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106712:	e9 ae 00 00 00       	jmp    801067c5 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106717:	83 ec 08             	sub    $0x8,%esp
8010671a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010671d:	50                   	push   %eax
8010671e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106721:	50                   	push   %eax
80106722:	e8 ce d8 ff ff       	call   80103ff5 <pipealloc>
80106727:	83 c4 10             	add    $0x10,%esp
8010672a:	85 c0                	test   %eax,%eax
8010672c:	79 0a                	jns    80106738 <sys_pipe+0x4c>
    return -1;
8010672e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106733:	e9 8d 00 00 00       	jmp    801067c5 <sys_pipe+0xd9>
  fd0 = -1;
80106738:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010673f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106742:	83 ec 0c             	sub    $0xc,%esp
80106745:	50                   	push   %eax
80106746:	e8 3d f3 ff ff       	call   80105a88 <fdalloc>
8010674b:	83 c4 10             	add    $0x10,%esp
8010674e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106751:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106755:	78 18                	js     8010676f <sys_pipe+0x83>
80106757:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010675a:	83 ec 0c             	sub    $0xc,%esp
8010675d:	50                   	push   %eax
8010675e:	e8 25 f3 ff ff       	call   80105a88 <fdalloc>
80106763:	83 c4 10             	add    $0x10,%esp
80106766:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106769:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010676d:	79 3e                	jns    801067ad <sys_pipe+0xc1>
    if(fd0 >= 0)
8010676f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106773:	78 13                	js     80106788 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106775:	e8 5a dd ff ff       	call   801044d4 <myproc>
8010677a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010677d:	83 c2 08             	add    $0x8,%edx
80106780:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106787:	00 
    fileclose(rf);
80106788:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010678b:	83 ec 0c             	sub    $0xc,%esp
8010678e:	50                   	push   %eax
8010678f:	e8 0c aa ff ff       	call   801011a0 <fileclose>
80106794:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010679a:	83 ec 0c             	sub    $0xc,%esp
8010679d:	50                   	push   %eax
8010679e:	e8 fd a9 ff ff       	call   801011a0 <fileclose>
801067a3:	83 c4 10             	add    $0x10,%esp
    return -1;
801067a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ab:	eb 18                	jmp    801067c5 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067b3:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067b8:	8d 50 04             	lea    0x4(%eax),%edx
801067bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067be:	89 02                	mov    %eax,(%edx)
  return 0;
801067c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067c5:	c9                   	leave  
801067c6:	c3                   	ret    

801067c7 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067c7:	f3 0f 1e fb          	endbr32 
801067cb:	55                   	push   %ebp
801067cc:	89 e5                	mov    %esp,%ebp
801067ce:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067d1:	e8 48 e0 ff ff       	call   8010481e <fork>
}
801067d6:	c9                   	leave  
801067d7:	c3                   	ret    

801067d8 <sys_exit>:

int
sys_exit(void)
{
801067d8:	f3 0f 1e fb          	endbr32 
801067dc:	55                   	push   %ebp
801067dd:	89 e5                	mov    %esp,%ebp
801067df:	83 ec 08             	sub    $0x8,%esp
  exit();
801067e2:	e8 18 e2 ff ff       	call   801049ff <exit>
  return 0;  // not reached
801067e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067ec:	c9                   	leave  
801067ed:	c3                   	ret    

801067ee <sys_wait>:

int
sys_wait(void)
{
801067ee:	f3 0f 1e fb          	endbr32 
801067f2:	55                   	push   %ebp
801067f3:	89 e5                	mov    %esp,%ebp
801067f5:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067f8:	e8 29 e3 ff ff       	call   80104b26 <wait>
}
801067fd:	c9                   	leave  
801067fe:	c3                   	ret    

801067ff <sys_kill>:

int
sys_kill(void)
{
801067ff:	f3 0f 1e fb          	endbr32 
80106803:	55                   	push   %ebp
80106804:	89 e5                	mov    %esp,%ebp
80106806:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106809:	83 ec 08             	sub    $0x8,%esp
8010680c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010680f:	50                   	push   %eax
80106810:	6a 00                	push   $0x0
80106812:	e8 9f f0 ff ff       	call   801058b6 <argint>
80106817:	83 c4 10             	add    $0x10,%esp
8010681a:	85 c0                	test   %eax,%eax
8010681c:	79 07                	jns    80106825 <sys_kill+0x26>
    return -1;
8010681e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106823:	eb 0f                	jmp    80106834 <sys_kill+0x35>
  return kill(pid);
80106825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106828:	83 ec 0c             	sub    $0xc,%esp
8010682b:	50                   	push   %eax
8010682c:	e8 4d e7 ff ff       	call   80104f7e <kill>
80106831:	83 c4 10             	add    $0x10,%esp
}
80106834:	c9                   	leave  
80106835:	c3                   	ret    

80106836 <sys_getpid>:

int
sys_getpid(void)
{
80106836:	f3 0f 1e fb          	endbr32 
8010683a:	55                   	push   %ebp
8010683b:	89 e5                	mov    %esp,%ebp
8010683d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106840:	e8 8f dc ff ff       	call   801044d4 <myproc>
80106845:	8b 40 10             	mov    0x10(%eax),%eax
}
80106848:	c9                   	leave  
80106849:	c3                   	ret    

8010684a <sys_sbrk>:

int
sys_sbrk(void)
{
8010684a:	f3 0f 1e fb          	endbr32 
8010684e:	55                   	push   %ebp
8010684f:	89 e5                	mov    %esp,%ebp
80106851:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106854:	83 ec 08             	sub    $0x8,%esp
80106857:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010685a:	50                   	push   %eax
8010685b:	6a 00                	push   $0x0
8010685d:	e8 54 f0 ff ff       	call   801058b6 <argint>
80106862:	83 c4 10             	add    $0x10,%esp
80106865:	85 c0                	test   %eax,%eax
80106867:	79 07                	jns    80106870 <sys_sbrk+0x26>
    return -1;
80106869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686e:	eb 27                	jmp    80106897 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106870:	e8 5f dc ff ff       	call   801044d4 <myproc>
80106875:	8b 00                	mov    (%eax),%eax
80106877:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010687a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687d:	83 ec 0c             	sub    $0xc,%esp
80106880:	50                   	push   %eax
80106881:	e8 f9 de ff ff       	call   8010477f <growproc>
80106886:	83 c4 10             	add    $0x10,%esp
80106889:	85 c0                	test   %eax,%eax
8010688b:	79 07                	jns    80106894 <sys_sbrk+0x4a>
    return -1;
8010688d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106892:	eb 03                	jmp    80106897 <sys_sbrk+0x4d>
  return addr;
80106894:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106897:	c9                   	leave  
80106898:	c3                   	ret    

80106899 <sys_sleep>:

int
sys_sleep(void)
{
80106899:	f3 0f 1e fb          	endbr32 
8010689d:	55                   	push   %ebp
8010689e:	89 e5                	mov    %esp,%ebp
801068a0:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068a3:	83 ec 08             	sub    $0x8,%esp
801068a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068a9:	50                   	push   %eax
801068aa:	6a 00                	push   $0x0
801068ac:	e8 05 f0 ff ff       	call   801058b6 <argint>
801068b1:	83 c4 10             	add    $0x10,%esp
801068b4:	85 c0                	test   %eax,%eax
801068b6:	79 07                	jns    801068bf <sys_sleep+0x26>
    return -1;
801068b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068bd:	eb 76                	jmp    80106935 <sys_sleep+0x9c>
  acquire(&tickslock);
801068bf:	83 ec 0c             	sub    $0xc,%esp
801068c2:	68 00 7e 11 80       	push   $0x80117e00
801068c7:	e8 f7 e9 ff ff       	call   801052c3 <acquire>
801068cc:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068cf:	a1 40 86 11 80       	mov    0x80118640,%eax
801068d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068d7:	eb 38                	jmp    80106911 <sys_sleep+0x78>
    if(myproc()->killed){
801068d9:	e8 f6 db ff ff       	call   801044d4 <myproc>
801068de:	8b 40 24             	mov    0x24(%eax),%eax
801068e1:	85 c0                	test   %eax,%eax
801068e3:	74 17                	je     801068fc <sys_sleep+0x63>
      release(&tickslock);
801068e5:	83 ec 0c             	sub    $0xc,%esp
801068e8:	68 00 7e 11 80       	push   $0x80117e00
801068ed:	e8 43 ea ff ff       	call   80105335 <release>
801068f2:	83 c4 10             	add    $0x10,%esp
      return -1;
801068f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fa:	eb 39                	jmp    80106935 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801068fc:	83 ec 08             	sub    $0x8,%esp
801068ff:	68 00 7e 11 80       	push   $0x80117e00
80106904:	68 40 86 11 80       	push   $0x80118640
80106909:	e8 43 e5 ff ff       	call   80104e51 <sleep>
8010690e:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106911:	a1 40 86 11 80       	mov    0x80118640,%eax
80106916:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106919:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010691c:	39 d0                	cmp    %edx,%eax
8010691e:	72 b9                	jb     801068d9 <sys_sleep+0x40>
  }
  release(&tickslock);
80106920:	83 ec 0c             	sub    $0xc,%esp
80106923:	68 00 7e 11 80       	push   $0x80117e00
80106928:	e8 08 ea ff ff       	call   80105335 <release>
8010692d:	83 c4 10             	add    $0x10,%esp
  return 0;
80106930:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106935:	c9                   	leave  
80106936:	c3                   	ret    

80106937 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106937:	f3 0f 1e fb          	endbr32 
8010693b:	55                   	push   %ebp
8010693c:	89 e5                	mov    %esp,%ebp
8010693e:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106941:	83 ec 0c             	sub    $0xc,%esp
80106944:	68 00 7e 11 80       	push   $0x80117e00
80106949:	e8 75 e9 ff ff       	call   801052c3 <acquire>
8010694e:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106951:	a1 40 86 11 80       	mov    0x80118640,%eax
80106956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106959:	83 ec 0c             	sub    $0xc,%esp
8010695c:	68 00 7e 11 80       	push   $0x80117e00
80106961:	e8 cf e9 ff ff       	call   80105335 <release>
80106966:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106969:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010696c:	c9                   	leave  
8010696d:	c3                   	ret    

8010696e <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
8010696e:	f3 0f 1e fb          	endbr32 
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
80106978:	83 ec 08             	sub    $0x8,%esp
8010697b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010697e:	50                   	push   %eax
8010697f:	6a 01                	push   $0x1
80106981:	e8 30 ef ff ff       	call   801058b6 <argint>
80106986:	83 c4 10             	add    $0x10,%esp
80106989:	85 c0                	test   %eax,%eax
8010698b:	79 07                	jns    80106994 <sys_mencrypt+0x26>
    return -1;
8010698d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106992:	eb 50                	jmp    801069e4 <sys_mencrypt+0x76>
  if (len <= 0) {
80106994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106997:	85 c0                	test   %eax,%eax
80106999:	7f 07                	jg     801069a2 <sys_mencrypt+0x34>
    return -1;
8010699b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a0:	eb 42                	jmp    801069e4 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
801069a2:	83 ec 04             	sub    $0x4,%esp
801069a5:	6a 01                	push   $0x1
801069a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069aa:	50                   	push   %eax
801069ab:	6a 00                	push   $0x0
801069ad:	e8 35 ef ff ff       	call   801058e7 <argptr>
801069b2:	83 c4 10             	add    $0x10,%esp
801069b5:	85 c0                	test   %eax,%eax
801069b7:	79 07                	jns    801069c0 <sys_mencrypt+0x52>
    return -1;
801069b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069be:	eb 24                	jmp    801069e4 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
801069c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c3:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
801069c8:	76 07                	jbe    801069d1 <sys_mencrypt+0x63>
    return -1;
801069ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069cf:	eb 13                	jmp    801069e4 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
801069d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d7:	83 ec 08             	sub    $0x8,%esp
801069da:	52                   	push   %edx
801069db:	50                   	push   %eax
801069dc:	e8 95 23 00 00       	call   80108d76 <mencrypt>
801069e1:	83 c4 10             	add    $0x10,%esp
}
801069e4:	c9                   	leave  
801069e5:	c3                   	ret    

801069e6 <sys_getpgtable>:

int sys_getpgtable(void) {
801069e6:	f3 0f 1e fb          	endbr32 
801069ea:	55                   	push   %ebp
801069eb:	89 e5                	mov    %esp,%ebp
801069ed:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;

  if(argint(2, &wsetOnly) < 0)
801069f0:	83 ec 08             	sub    $0x8,%esp
801069f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069f6:	50                   	push   %eax
801069f7:	6a 02                	push   $0x2
801069f9:	e8 b8 ee ff ff       	call   801058b6 <argint>
801069fe:	83 c4 10             	add    $0x10,%esp
80106a01:	85 c0                	test   %eax,%eax
80106a03:	79 07                	jns    80106a0c <sys_getpgtable+0x26>
    return -1;
80106a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a0a:	eb 56                	jmp    80106a62 <sys_getpgtable+0x7c>
  if(argint(1, &num) < 0)
80106a0c:	83 ec 08             	sub    $0x8,%esp
80106a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a12:	50                   	push   %eax
80106a13:	6a 01                	push   $0x1
80106a15:	e8 9c ee ff ff       	call   801058b6 <argint>
80106a1a:	83 c4 10             	add    $0x10,%esp
80106a1d:	85 c0                	test   %eax,%eax
80106a1f:	79 07                	jns    80106a28 <sys_getpgtable+0x42>
    return -1;
80106a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a26:	eb 3a                	jmp    80106a62 <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a2b:	c1 e0 03             	shl    $0x3,%eax
80106a2e:	83 ec 04             	sub    $0x4,%esp
80106a31:	50                   	push   %eax
80106a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a35:	50                   	push   %eax
80106a36:	6a 00                	push   $0x0
80106a38:	e8 aa ee ff ff       	call   801058e7 <argptr>
80106a3d:	83 c4 10             	add    $0x10,%esp
80106a40:	85 c0                	test   %eax,%eax
80106a42:	79 07                	jns    80106a4b <sys_getpgtable+0x65>
    return -1;
80106a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a49:	eb 17                	jmp    80106a62 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num, wsetOnly);
80106a4b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a54:	83 ec 04             	sub    $0x4,%esp
80106a57:	51                   	push   %ecx
80106a58:	52                   	push   %edx
80106a59:	50                   	push   %eax
80106a5a:	e8 30 24 00 00       	call   80108e8f <getpgtable>
80106a5f:	83 c4 10             	add    $0x10,%esp
}
80106a62:	c9                   	leave  
80106a63:	c3                   	ret    

80106a64 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106a64:	f3 0f 1e fb          	endbr32 
80106a68:	55                   	push   %ebp
80106a69:	89 e5                	mov    %esp,%ebp
80106a6b:	83 ec 18             	sub    $0x18,%esp
  int physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106a6e:	83 ec 04             	sub    $0x4,%esp
80106a71:	68 00 10 00 00       	push   $0x1000
80106a76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a79:	50                   	push   %eax
80106a7a:	6a 01                	push   $0x1
80106a7c:	e8 66 ee ff ff       	call   801058e7 <argptr>
80106a81:	83 c4 10             	add    $0x10,%esp
80106a84:	85 c0                	test   %eax,%eax
80106a86:	79 07                	jns    80106a8f <sys_dump_rawphymem+0x2b>
    return -1;
80106a88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8d:	eb 2f                	jmp    80106abe <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106a8f:	83 ec 08             	sub    $0x8,%esp
80106a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a95:	50                   	push   %eax
80106a96:	6a 00                	push   $0x0
80106a98:	e8 19 ee ff ff       	call   801058b6 <argint>
80106a9d:	83 c4 10             	add    $0x10,%esp
80106aa0:	85 c0                	test   %eax,%eax
80106aa2:	79 07                	jns    80106aab <sys_dump_rawphymem+0x47>
    return -1;
80106aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa9:	eb 13                	jmp    80106abe <sys_dump_rawphymem+0x5a>
  return dump_rawphymem((uint)physical_addr, buffer);
80106aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ab1:	83 ec 08             	sub    $0x8,%esp
80106ab4:	50                   	push   %eax
80106ab5:	52                   	push   %edx
80106ab6:	e8 da 27 00 00       	call   80109295 <dump_rawphymem>
80106abb:	83 c4 10             	add    $0x10,%esp
80106abe:	c9                   	leave  
80106abf:	c3                   	ret    

80106ac0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ac0:	1e                   	push   %ds
  pushl %es
80106ac1:	06                   	push   %es
  pushl %fs
80106ac2:	0f a0                	push   %fs
  pushl %gs
80106ac4:	0f a8                	push   %gs
  pushal
80106ac6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ac7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106acb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106acd:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106acf:	54                   	push   %esp
  call trap
80106ad0:	e8 df 01 00 00       	call   80106cb4 <trap>
  addl $4, %esp
80106ad5:	83 c4 04             	add    $0x4,%esp

80106ad8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ad8:	61                   	popa   
  popl %gs
80106ad9:	0f a9                	pop    %gs
  popl %fs
80106adb:	0f a1                	pop    %fs
  popl %es
80106add:	07                   	pop    %es
  popl %ds
80106ade:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106adf:	83 c4 08             	add    $0x8,%esp
  iret
80106ae2:	cf                   	iret   

80106ae3 <lidt>:
{
80106ae3:	55                   	push   %ebp
80106ae4:	89 e5                	mov    %esp,%ebp
80106ae6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aec:	83 e8 01             	sub    $0x1,%eax
80106aef:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106af3:	8b 45 08             	mov    0x8(%ebp),%eax
80106af6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106afa:	8b 45 08             	mov    0x8(%ebp),%eax
80106afd:	c1 e8 10             	shr    $0x10,%eax
80106b00:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b04:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b07:	0f 01 18             	lidtl  (%eax)
}
80106b0a:	90                   	nop
80106b0b:	c9                   	leave  
80106b0c:	c3                   	ret    

80106b0d <rcr2>:

static inline uint
rcr2(void)
{
80106b0d:	55                   	push   %ebp
80106b0e:	89 e5                	mov    %esp,%ebp
80106b10:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b13:	0f 20 d0             	mov    %cr2,%eax
80106b16:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b19:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b1c:	c9                   	leave  
80106b1d:	c3                   	ret    

80106b1e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b1e:	f3 0f 1e fb          	endbr32 
80106b22:	55                   	push   %ebp
80106b23:	89 e5                	mov    %esp,%ebp
80106b25:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b2f:	e9 c3 00 00 00       	jmp    80106bf7 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b37:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b3e:	89 c2                	mov    %eax,%edx
80106b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b43:	66 89 14 c5 40 7e 11 	mov    %dx,-0x7fee81c0(,%eax,8)
80106b4a:	80 
80106b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4e:	66 c7 04 c5 42 7e 11 	movw   $0x8,-0x7fee81be(,%eax,8)
80106b55:	80 08 00 
80106b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5b:	0f b6 14 c5 44 7e 11 	movzbl -0x7fee81bc(,%eax,8),%edx
80106b62:	80 
80106b63:	83 e2 e0             	and    $0xffffffe0,%edx
80106b66:	88 14 c5 44 7e 11 80 	mov    %dl,-0x7fee81bc(,%eax,8)
80106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b70:	0f b6 14 c5 44 7e 11 	movzbl -0x7fee81bc(,%eax,8),%edx
80106b77:	80 
80106b78:	83 e2 1f             	and    $0x1f,%edx
80106b7b:	88 14 c5 44 7e 11 80 	mov    %dl,-0x7fee81bc(,%eax,8)
80106b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b85:	0f b6 14 c5 45 7e 11 	movzbl -0x7fee81bb(,%eax,8),%edx
80106b8c:	80 
80106b8d:	83 e2 f0             	and    $0xfffffff0,%edx
80106b90:	83 ca 0e             	or     $0xe,%edx
80106b93:	88 14 c5 45 7e 11 80 	mov    %dl,-0x7fee81bb(,%eax,8)
80106b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9d:	0f b6 14 c5 45 7e 11 	movzbl -0x7fee81bb(,%eax,8),%edx
80106ba4:	80 
80106ba5:	83 e2 ef             	and    $0xffffffef,%edx
80106ba8:	88 14 c5 45 7e 11 80 	mov    %dl,-0x7fee81bb(,%eax,8)
80106baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb2:	0f b6 14 c5 45 7e 11 	movzbl -0x7fee81bb(,%eax,8),%edx
80106bb9:	80 
80106bba:	83 e2 9f             	and    $0xffffff9f,%edx
80106bbd:	88 14 c5 45 7e 11 80 	mov    %dl,-0x7fee81bb(,%eax,8)
80106bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc7:	0f b6 14 c5 45 7e 11 	movzbl -0x7fee81bb(,%eax,8),%edx
80106bce:	80 
80106bcf:	83 ca 80             	or     $0xffffff80,%edx
80106bd2:	88 14 c5 45 7e 11 80 	mov    %dl,-0x7fee81bb(,%eax,8)
80106bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bdc:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106be3:	c1 e8 10             	shr    $0x10,%eax
80106be6:	89 c2                	mov    %eax,%edx
80106be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106beb:	66 89 14 c5 46 7e 11 	mov    %dx,-0x7fee81ba(,%eax,8)
80106bf2:	80 
  for(i = 0; i < 256; i++)
80106bf3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bf7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bfe:	0f 8e 30 ff ff ff    	jle    80106b34 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c04:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c09:	66 a3 40 80 11 80    	mov    %ax,0x80118040
80106c0f:	66 c7 05 42 80 11 80 	movw   $0x8,0x80118042
80106c16:	08 00 
80106c18:	0f b6 05 44 80 11 80 	movzbl 0x80118044,%eax
80106c1f:	83 e0 e0             	and    $0xffffffe0,%eax
80106c22:	a2 44 80 11 80       	mov    %al,0x80118044
80106c27:	0f b6 05 44 80 11 80 	movzbl 0x80118044,%eax
80106c2e:	83 e0 1f             	and    $0x1f,%eax
80106c31:	a2 44 80 11 80       	mov    %al,0x80118044
80106c36:	0f b6 05 45 80 11 80 	movzbl 0x80118045,%eax
80106c3d:	83 c8 0f             	or     $0xf,%eax
80106c40:	a2 45 80 11 80       	mov    %al,0x80118045
80106c45:	0f b6 05 45 80 11 80 	movzbl 0x80118045,%eax
80106c4c:	83 e0 ef             	and    $0xffffffef,%eax
80106c4f:	a2 45 80 11 80       	mov    %al,0x80118045
80106c54:	0f b6 05 45 80 11 80 	movzbl 0x80118045,%eax
80106c5b:	83 c8 60             	or     $0x60,%eax
80106c5e:	a2 45 80 11 80       	mov    %al,0x80118045
80106c63:	0f b6 05 45 80 11 80 	movzbl 0x80118045,%eax
80106c6a:	83 c8 80             	or     $0xffffff80,%eax
80106c6d:	a2 45 80 11 80       	mov    %al,0x80118045
80106c72:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c77:	c1 e8 10             	shr    $0x10,%eax
80106c7a:	66 a3 46 80 11 80    	mov    %ax,0x80118046

  initlock(&tickslock, "time");
80106c80:	83 ec 08             	sub    $0x8,%esp
80106c83:	68 74 98 10 80       	push   $0x80109874
80106c88:	68 00 7e 11 80       	push   $0x80117e00
80106c8d:	e8 0b e6 ff ff       	call   8010529d <initlock>
80106c92:	83 c4 10             	add    $0x10,%esp
}
80106c95:	90                   	nop
80106c96:	c9                   	leave  
80106c97:	c3                   	ret    

80106c98 <idtinit>:

void
idtinit(void)
{
80106c98:	f3 0f 1e fb          	endbr32 
80106c9c:	55                   	push   %ebp
80106c9d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c9f:	68 00 08 00 00       	push   $0x800
80106ca4:	68 40 7e 11 80       	push   $0x80117e40
80106ca9:	e8 35 fe ff ff       	call   80106ae3 <lidt>
80106cae:	83 c4 08             	add    $0x8,%esp
}
80106cb1:	90                   	nop
80106cb2:	c9                   	leave  
80106cb3:	c3                   	ret    

80106cb4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cb4:	f3 0f 1e fb          	endbr32 
80106cb8:	55                   	push   %ebp
80106cb9:	89 e5                	mov    %esp,%ebp
80106cbb:	57                   	push   %edi
80106cbc:	56                   	push   %esi
80106cbd:	53                   	push   %ebx
80106cbe:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc4:	8b 40 30             	mov    0x30(%eax),%eax
80106cc7:	83 f8 40             	cmp    $0x40,%eax
80106cca:	75 3b                	jne    80106d07 <trap+0x53>
    if(myproc()->killed)
80106ccc:	e8 03 d8 ff ff       	call   801044d4 <myproc>
80106cd1:	8b 40 24             	mov    0x24(%eax),%eax
80106cd4:	85 c0                	test   %eax,%eax
80106cd6:	74 05                	je     80106cdd <trap+0x29>
      exit();
80106cd8:	e8 22 dd ff ff       	call   801049ff <exit>
    myproc()->tf = tf;
80106cdd:	e8 f2 d7 ff ff       	call   801044d4 <myproc>
80106ce2:	8b 55 08             	mov    0x8(%ebp),%edx
80106ce5:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ce8:	e8 a1 ec ff ff       	call   8010598e <syscall>
    if(myproc()->killed)
80106ced:	e8 e2 d7 ff ff       	call   801044d4 <myproc>
80106cf2:	8b 40 24             	mov    0x24(%eax),%eax
80106cf5:	85 c0                	test   %eax,%eax
80106cf7:	0f 84 3d 02 00 00    	je     80106f3a <trap+0x286>
      exit();
80106cfd:	e8 fd dc ff ff       	call   801049ff <exit>
    return;
80106d02:	e9 33 02 00 00       	jmp    80106f3a <trap+0x286>
  }
  int retval;
  //char *addr;
  switch(tf->trapno){
80106d07:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0a:	8b 40 30             	mov    0x30(%eax),%eax
80106d0d:	83 e8 0e             	sub    $0xe,%eax
80106d10:	83 f8 31             	cmp    $0x31,%eax
80106d13:	0f 87 e9 00 00 00    	ja     80106e02 <trap+0x14e>
80106d19:	8b 04 85 34 99 10 80 	mov    -0x7fef66cc(,%eax,4),%eax
80106d20:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d23:	e8 11 d7 ff ff       	call   80104439 <cpuid>
80106d28:	85 c0                	test   %eax,%eax
80106d2a:	75 3d                	jne    80106d69 <trap+0xb5>
      acquire(&tickslock);
80106d2c:	83 ec 0c             	sub    $0xc,%esp
80106d2f:	68 00 7e 11 80       	push   $0x80117e00
80106d34:	e8 8a e5 ff ff       	call   801052c3 <acquire>
80106d39:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d3c:	a1 40 86 11 80       	mov    0x80118640,%eax
80106d41:	83 c0 01             	add    $0x1,%eax
80106d44:	a3 40 86 11 80       	mov    %eax,0x80118640
      wakeup(&ticks);
80106d49:	83 ec 0c             	sub    $0xc,%esp
80106d4c:	68 40 86 11 80       	push   $0x80118640
80106d51:	e8 ed e1 ff ff       	call   80104f43 <wakeup>
80106d56:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d59:	83 ec 0c             	sub    $0xc,%esp
80106d5c:	68 00 7e 11 80       	push   $0x80117e00
80106d61:	e8 cf e5 ff ff       	call   80105335 <release>
80106d66:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d69:	e8 5b c4 ff ff       	call   801031c9 <lapiceoi>
    break;
80106d6e:	e9 47 01 00 00       	jmp    80106eba <trap+0x206>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d73:	e8 60 bc ff ff       	call   801029d8 <ideintr>
    lapiceoi();
80106d78:	e8 4c c4 ff ff       	call   801031c9 <lapiceoi>
    break;
80106d7d:	e9 38 01 00 00       	jmp    80106eba <trap+0x206>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d82:	e8 78 c2 ff ff       	call   80102fff <kbdintr>
    lapiceoi();
80106d87:	e8 3d c4 ff ff       	call   801031c9 <lapiceoi>
    break;
80106d8c:	e9 29 01 00 00       	jmp    80106eba <trap+0x206>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d91:	e8 86 03 00 00       	call   8010711c <uartintr>
    lapiceoi();
80106d96:	e8 2e c4 ff ff       	call   801031c9 <lapiceoi>
    break;
80106d9b:	e9 1a 01 00 00       	jmp    80106eba <trap+0x206>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106da0:	8b 45 08             	mov    0x8(%ebp),%eax
80106da3:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106da6:	8b 45 08             	mov    0x8(%ebp),%eax
80106da9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dad:	0f b7 d8             	movzwl %ax,%ebx
80106db0:	e8 84 d6 ff ff       	call   80104439 <cpuid>
80106db5:	56                   	push   %esi
80106db6:	53                   	push   %ebx
80106db7:	50                   	push   %eax
80106db8:	68 7c 98 10 80       	push   $0x8010987c
80106dbd:	e8 56 96 ff ff       	call   80100418 <cprintf>
80106dc2:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106dc5:	e8 ff c3 ff ff       	call   801031c9 <lapiceoi>
    break;
80106dca:	e9 eb 00 00 00       	jmp    80106eba <trap+0x206>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106dcf:	83 ec 0c             	sub    $0xc,%esp
80106dd2:	68 a0 98 10 80       	push   $0x801098a0
80106dd7:	e8 3c 96 ff ff       	call   80100418 <cprintf>
80106ddc:	83 c4 10             	add    $0x10,%esp
    // if (mdecrypt(addr))
    // {
    //     panic("p4Debug: Memory fault");
    //     exit();
    // };
    retval = mdecrypt((char*)rcr2());
80106ddf:	e8 29 fd ff ff       	call   80106b0d <rcr2>
80106de4:	83 ec 0c             	sub    $0xc,%esp
80106de7:	50                   	push   %eax
80106de8:	e8 aa 1e 00 00       	call   80108c97 <mdecrypt>
80106ded:	83 c4 10             	add    $0x10,%esp
80106df0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(retval == 0){
80106df3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106df7:	0f 85 bc 00 00 00    	jne    80106eb9 <trap+0x205>
      return;
80106dfd:	e9 39 01 00 00       	jmp    80106f3b <trap+0x287>
    }
    break;
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e02:	e8 cd d6 ff ff       	call   801044d4 <myproc>
80106e07:	85 c0                	test   %eax,%eax
80106e09:	74 11                	je     80106e1c <trap+0x168>
80106e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e0e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e12:	0f b7 c0             	movzwl %ax,%eax
80106e15:	83 e0 03             	and    $0x3,%eax
80106e18:	85 c0                	test   %eax,%eax
80106e1a:	75 39                	jne    80106e55 <trap+0x1a1>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e1c:	e8 ec fc ff ff       	call   80106b0d <rcr2>
80106e21:	89 c3                	mov    %eax,%ebx
80106e23:	8b 45 08             	mov    0x8(%ebp),%eax
80106e26:	8b 70 38             	mov    0x38(%eax),%esi
80106e29:	e8 0b d6 ff ff       	call   80104439 <cpuid>
80106e2e:	8b 55 08             	mov    0x8(%ebp),%edx
80106e31:	8b 52 30             	mov    0x30(%edx),%edx
80106e34:	83 ec 0c             	sub    $0xc,%esp
80106e37:	53                   	push   %ebx
80106e38:	56                   	push   %esi
80106e39:	50                   	push   %eax
80106e3a:	52                   	push   %edx
80106e3b:	68 b8 98 10 80       	push   $0x801098b8
80106e40:	e8 d3 95 ff ff       	call   80100418 <cprintf>
80106e45:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e48:	83 ec 0c             	sub    $0xc,%esp
80106e4b:	68 ea 98 10 80       	push   $0x801098ea
80106e50:	e8 b3 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e55:	e8 b3 fc ff ff       	call   80106b0d <rcr2>
80106e5a:	89 c6                	mov    %eax,%esi
80106e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5f:	8b 40 38             	mov    0x38(%eax),%eax
80106e62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e65:	e8 cf d5 ff ff       	call   80104439 <cpuid>
80106e6a:	89 c3                	mov    %eax,%ebx
80106e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e6f:	8b 48 34             	mov    0x34(%eax),%ecx
80106e72:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e75:	8b 45 08             	mov    0x8(%ebp),%eax
80106e78:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e7b:	e8 54 d6 ff ff       	call   801044d4 <myproc>
80106e80:	8d 50 6c             	lea    0x6c(%eax),%edx
80106e83:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e86:	e8 49 d6 ff ff       	call   801044d4 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e8b:	8b 40 10             	mov    0x10(%eax),%eax
80106e8e:	56                   	push   %esi
80106e8f:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e92:	53                   	push   %ebx
80106e93:	ff 75 d0             	pushl  -0x30(%ebp)
80106e96:	57                   	push   %edi
80106e97:	ff 75 cc             	pushl  -0x34(%ebp)
80106e9a:	50                   	push   %eax
80106e9b:	68 f0 98 10 80       	push   $0x801098f0
80106ea0:	e8 73 95 ff ff       	call   80100418 <cprintf>
80106ea5:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ea8:	e8 27 d6 ff ff       	call   801044d4 <myproc>
80106ead:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106eb4:	eb 04                	jmp    80106eba <trap+0x206>
    break;
80106eb6:	90                   	nop
80106eb7:	eb 01                	jmp    80106eba <trap+0x206>
    break;
80106eb9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eba:	e8 15 d6 ff ff       	call   801044d4 <myproc>
80106ebf:	85 c0                	test   %eax,%eax
80106ec1:	74 23                	je     80106ee6 <trap+0x232>
80106ec3:	e8 0c d6 ff ff       	call   801044d4 <myproc>
80106ec8:	8b 40 24             	mov    0x24(%eax),%eax
80106ecb:	85 c0                	test   %eax,%eax
80106ecd:	74 17                	je     80106ee6 <trap+0x232>
80106ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ed6:	0f b7 c0             	movzwl %ax,%eax
80106ed9:	83 e0 03             	and    $0x3,%eax
80106edc:	83 f8 03             	cmp    $0x3,%eax
80106edf:	75 05                	jne    80106ee6 <trap+0x232>
    exit();
80106ee1:	e8 19 db ff ff       	call   801049ff <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ee6:	e8 e9 d5 ff ff       	call   801044d4 <myproc>
80106eeb:	85 c0                	test   %eax,%eax
80106eed:	74 1d                	je     80106f0c <trap+0x258>
80106eef:	e8 e0 d5 ff ff       	call   801044d4 <myproc>
80106ef4:	8b 40 0c             	mov    0xc(%eax),%eax
80106ef7:	83 f8 04             	cmp    $0x4,%eax
80106efa:	75 10                	jne    80106f0c <trap+0x258>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106efc:	8b 45 08             	mov    0x8(%ebp),%eax
80106eff:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f02:	83 f8 20             	cmp    $0x20,%eax
80106f05:	75 05                	jne    80106f0c <trap+0x258>
    yield();
80106f07:	e8 bd de ff ff       	call   80104dc9 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f0c:	e8 c3 d5 ff ff       	call   801044d4 <myproc>
80106f11:	85 c0                	test   %eax,%eax
80106f13:	74 26                	je     80106f3b <trap+0x287>
80106f15:	e8 ba d5 ff ff       	call   801044d4 <myproc>
80106f1a:	8b 40 24             	mov    0x24(%eax),%eax
80106f1d:	85 c0                	test   %eax,%eax
80106f1f:	74 1a                	je     80106f3b <trap+0x287>
80106f21:	8b 45 08             	mov    0x8(%ebp),%eax
80106f24:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f28:	0f b7 c0             	movzwl %ax,%eax
80106f2b:	83 e0 03             	and    $0x3,%eax
80106f2e:	83 f8 03             	cmp    $0x3,%eax
80106f31:	75 08                	jne    80106f3b <trap+0x287>
    exit();
80106f33:	e8 c7 da ff ff       	call   801049ff <exit>
80106f38:	eb 01                	jmp    80106f3b <trap+0x287>
    return;
80106f3a:	90                   	nop
}
80106f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f3e:	5b                   	pop    %ebx
80106f3f:	5e                   	pop    %esi
80106f40:	5f                   	pop    %edi
80106f41:	5d                   	pop    %ebp
80106f42:	c3                   	ret    

80106f43 <inb>:
{
80106f43:	55                   	push   %ebp
80106f44:	89 e5                	mov    %esp,%ebp
80106f46:	83 ec 14             	sub    $0x14,%esp
80106f49:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f50:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f54:	89 c2                	mov    %eax,%edx
80106f56:	ec                   	in     (%dx),%al
80106f57:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f5a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f5e:	c9                   	leave  
80106f5f:	c3                   	ret    

80106f60 <outb>:
{
80106f60:	55                   	push   %ebp
80106f61:	89 e5                	mov    %esp,%ebp
80106f63:	83 ec 08             	sub    $0x8,%esp
80106f66:	8b 45 08             	mov    0x8(%ebp),%eax
80106f69:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f6c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f70:	89 d0                	mov    %edx,%eax
80106f72:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f75:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f79:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f7d:	ee                   	out    %al,(%dx)
}
80106f7e:	90                   	nop
80106f7f:	c9                   	leave  
80106f80:	c3                   	ret    

80106f81 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f81:	f3 0f 1e fb          	endbr32 
80106f85:	55                   	push   %ebp
80106f86:	89 e5                	mov    %esp,%ebp
80106f88:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f8b:	6a 00                	push   $0x0
80106f8d:	68 fa 03 00 00       	push   $0x3fa
80106f92:	e8 c9 ff ff ff       	call   80106f60 <outb>
80106f97:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f9a:	68 80 00 00 00       	push   $0x80
80106f9f:	68 fb 03 00 00       	push   $0x3fb
80106fa4:	e8 b7 ff ff ff       	call   80106f60 <outb>
80106fa9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fac:	6a 0c                	push   $0xc
80106fae:	68 f8 03 00 00       	push   $0x3f8
80106fb3:	e8 a8 ff ff ff       	call   80106f60 <outb>
80106fb8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fbb:	6a 00                	push   $0x0
80106fbd:	68 f9 03 00 00       	push   $0x3f9
80106fc2:	e8 99 ff ff ff       	call   80106f60 <outb>
80106fc7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fca:	6a 03                	push   $0x3
80106fcc:	68 fb 03 00 00       	push   $0x3fb
80106fd1:	e8 8a ff ff ff       	call   80106f60 <outb>
80106fd6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106fd9:	6a 00                	push   $0x0
80106fdb:	68 fc 03 00 00       	push   $0x3fc
80106fe0:	e8 7b ff ff ff       	call   80106f60 <outb>
80106fe5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fe8:	6a 01                	push   $0x1
80106fea:	68 f9 03 00 00       	push   $0x3f9
80106fef:	e8 6c ff ff ff       	call   80106f60 <outb>
80106ff4:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ff7:	68 fd 03 00 00       	push   $0x3fd
80106ffc:	e8 42 ff ff ff       	call   80106f43 <inb>
80107001:	83 c4 04             	add    $0x4,%esp
80107004:	3c ff                	cmp    $0xff,%al
80107006:	74 61                	je     80107069 <uartinit+0xe8>
    return;
  uart = 1;
80107008:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
8010700f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107012:	68 fa 03 00 00       	push   $0x3fa
80107017:	e8 27 ff ff ff       	call   80106f43 <inb>
8010701c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010701f:	68 f8 03 00 00       	push   $0x3f8
80107024:	e8 1a ff ff ff       	call   80106f43 <inb>
80107029:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010702c:	83 ec 08             	sub    $0x8,%esp
8010702f:	6a 00                	push   $0x0
80107031:	6a 04                	push   $0x4
80107033:	e8 52 bc ff ff       	call   80102c8a <ioapicenable>
80107038:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010703b:	c7 45 f4 fc 99 10 80 	movl   $0x801099fc,-0xc(%ebp)
80107042:	eb 19                	jmp    8010705d <uartinit+0xdc>
    uartputc(*p);
80107044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107047:	0f b6 00             	movzbl (%eax),%eax
8010704a:	0f be c0             	movsbl %al,%eax
8010704d:	83 ec 0c             	sub    $0xc,%esp
80107050:	50                   	push   %eax
80107051:	e8 16 00 00 00       	call   8010706c <uartputc>
80107056:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107059:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010705d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107060:	0f b6 00             	movzbl (%eax),%eax
80107063:	84 c0                	test   %al,%al
80107065:	75 dd                	jne    80107044 <uartinit+0xc3>
80107067:	eb 01                	jmp    8010706a <uartinit+0xe9>
    return;
80107069:	90                   	nop
}
8010706a:	c9                   	leave  
8010706b:	c3                   	ret    

8010706c <uartputc>:

void
uartputc(int c)
{
8010706c:	f3 0f 1e fb          	endbr32 
80107070:	55                   	push   %ebp
80107071:	89 e5                	mov    %esp,%ebp
80107073:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107076:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010707b:	85 c0                	test   %eax,%eax
8010707d:	74 53                	je     801070d2 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010707f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107086:	eb 11                	jmp    80107099 <uartputc+0x2d>
    microdelay(10);
80107088:	83 ec 0c             	sub    $0xc,%esp
8010708b:	6a 0a                	push   $0xa
8010708d:	e8 56 c1 ff ff       	call   801031e8 <microdelay>
80107092:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107095:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107099:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010709d:	7f 1a                	jg     801070b9 <uartputc+0x4d>
8010709f:	83 ec 0c             	sub    $0xc,%esp
801070a2:	68 fd 03 00 00       	push   $0x3fd
801070a7:	e8 97 fe ff ff       	call   80106f43 <inb>
801070ac:	83 c4 10             	add    $0x10,%esp
801070af:	0f b6 c0             	movzbl %al,%eax
801070b2:	83 e0 20             	and    $0x20,%eax
801070b5:	85 c0                	test   %eax,%eax
801070b7:	74 cf                	je     80107088 <uartputc+0x1c>
  outb(COM1+0, c);
801070b9:	8b 45 08             	mov    0x8(%ebp),%eax
801070bc:	0f b6 c0             	movzbl %al,%eax
801070bf:	83 ec 08             	sub    $0x8,%esp
801070c2:	50                   	push   %eax
801070c3:	68 f8 03 00 00       	push   $0x3f8
801070c8:	e8 93 fe ff ff       	call   80106f60 <outb>
801070cd:	83 c4 10             	add    $0x10,%esp
801070d0:	eb 01                	jmp    801070d3 <uartputc+0x67>
    return;
801070d2:	90                   	nop
}
801070d3:	c9                   	leave  
801070d4:	c3                   	ret    

801070d5 <uartgetc>:

static int
uartgetc(void)
{
801070d5:	f3 0f 1e fb          	endbr32 
801070d9:	55                   	push   %ebp
801070da:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070dc:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070e1:	85 c0                	test   %eax,%eax
801070e3:	75 07                	jne    801070ec <uartgetc+0x17>
    return -1;
801070e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ea:	eb 2e                	jmp    8010711a <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801070ec:	68 fd 03 00 00       	push   $0x3fd
801070f1:	e8 4d fe ff ff       	call   80106f43 <inb>
801070f6:	83 c4 04             	add    $0x4,%esp
801070f9:	0f b6 c0             	movzbl %al,%eax
801070fc:	83 e0 01             	and    $0x1,%eax
801070ff:	85 c0                	test   %eax,%eax
80107101:	75 07                	jne    8010710a <uartgetc+0x35>
    return -1;
80107103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107108:	eb 10                	jmp    8010711a <uartgetc+0x45>
  return inb(COM1+0);
8010710a:	68 f8 03 00 00       	push   $0x3f8
8010710f:	e8 2f fe ff ff       	call   80106f43 <inb>
80107114:	83 c4 04             	add    $0x4,%esp
80107117:	0f b6 c0             	movzbl %al,%eax
}
8010711a:	c9                   	leave  
8010711b:	c3                   	ret    

8010711c <uartintr>:

void
uartintr(void)
{
8010711c:	f3 0f 1e fb          	endbr32 
80107120:	55                   	push   %ebp
80107121:	89 e5                	mov    %esp,%ebp
80107123:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107126:	83 ec 0c             	sub    $0xc,%esp
80107129:	68 d5 70 10 80       	push   $0x801070d5
8010712e:	e8 75 97 ff ff       	call   801008a8 <consoleintr>
80107133:	83 c4 10             	add    $0x10,%esp
}
80107136:	90                   	nop
80107137:	c9                   	leave  
80107138:	c3                   	ret    

80107139 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $0
8010713b:	6a 00                	push   $0x0
  jmp alltraps
8010713d:	e9 7e f9 ff ff       	jmp    80106ac0 <alltraps>

80107142 <vector1>:
.globl vector1
vector1:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $1
80107144:	6a 01                	push   $0x1
  jmp alltraps
80107146:	e9 75 f9 ff ff       	jmp    80106ac0 <alltraps>

8010714b <vector2>:
.globl vector2
vector2:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $2
8010714d:	6a 02                	push   $0x2
  jmp alltraps
8010714f:	e9 6c f9 ff ff       	jmp    80106ac0 <alltraps>

80107154 <vector3>:
.globl vector3
vector3:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $3
80107156:	6a 03                	push   $0x3
  jmp alltraps
80107158:	e9 63 f9 ff ff       	jmp    80106ac0 <alltraps>

8010715d <vector4>:
.globl vector4
vector4:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $4
8010715f:	6a 04                	push   $0x4
  jmp alltraps
80107161:	e9 5a f9 ff ff       	jmp    80106ac0 <alltraps>

80107166 <vector5>:
.globl vector5
vector5:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $5
80107168:	6a 05                	push   $0x5
  jmp alltraps
8010716a:	e9 51 f9 ff ff       	jmp    80106ac0 <alltraps>

8010716f <vector6>:
.globl vector6
vector6:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $6
80107171:	6a 06                	push   $0x6
  jmp alltraps
80107173:	e9 48 f9 ff ff       	jmp    80106ac0 <alltraps>

80107178 <vector7>:
.globl vector7
vector7:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $7
8010717a:	6a 07                	push   $0x7
  jmp alltraps
8010717c:	e9 3f f9 ff ff       	jmp    80106ac0 <alltraps>

80107181 <vector8>:
.globl vector8
vector8:
  pushl $8
80107181:	6a 08                	push   $0x8
  jmp alltraps
80107183:	e9 38 f9 ff ff       	jmp    80106ac0 <alltraps>

80107188 <vector9>:
.globl vector9
vector9:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $9
8010718a:	6a 09                	push   $0x9
  jmp alltraps
8010718c:	e9 2f f9 ff ff       	jmp    80106ac0 <alltraps>

80107191 <vector10>:
.globl vector10
vector10:
  pushl $10
80107191:	6a 0a                	push   $0xa
  jmp alltraps
80107193:	e9 28 f9 ff ff       	jmp    80106ac0 <alltraps>

80107198 <vector11>:
.globl vector11
vector11:
  pushl $11
80107198:	6a 0b                	push   $0xb
  jmp alltraps
8010719a:	e9 21 f9 ff ff       	jmp    80106ac0 <alltraps>

8010719f <vector12>:
.globl vector12
vector12:
  pushl $12
8010719f:	6a 0c                	push   $0xc
  jmp alltraps
801071a1:	e9 1a f9 ff ff       	jmp    80106ac0 <alltraps>

801071a6 <vector13>:
.globl vector13
vector13:
  pushl $13
801071a6:	6a 0d                	push   $0xd
  jmp alltraps
801071a8:	e9 13 f9 ff ff       	jmp    80106ac0 <alltraps>

801071ad <vector14>:
.globl vector14
vector14:
  pushl $14
801071ad:	6a 0e                	push   $0xe
  jmp alltraps
801071af:	e9 0c f9 ff ff       	jmp    80106ac0 <alltraps>

801071b4 <vector15>:
.globl vector15
vector15:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $15
801071b6:	6a 0f                	push   $0xf
  jmp alltraps
801071b8:	e9 03 f9 ff ff       	jmp    80106ac0 <alltraps>

801071bd <vector16>:
.globl vector16
vector16:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $16
801071bf:	6a 10                	push   $0x10
  jmp alltraps
801071c1:	e9 fa f8 ff ff       	jmp    80106ac0 <alltraps>

801071c6 <vector17>:
.globl vector17
vector17:
  pushl $17
801071c6:	6a 11                	push   $0x11
  jmp alltraps
801071c8:	e9 f3 f8 ff ff       	jmp    80106ac0 <alltraps>

801071cd <vector18>:
.globl vector18
vector18:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $18
801071cf:	6a 12                	push   $0x12
  jmp alltraps
801071d1:	e9 ea f8 ff ff       	jmp    80106ac0 <alltraps>

801071d6 <vector19>:
.globl vector19
vector19:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $19
801071d8:	6a 13                	push   $0x13
  jmp alltraps
801071da:	e9 e1 f8 ff ff       	jmp    80106ac0 <alltraps>

801071df <vector20>:
.globl vector20
vector20:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $20
801071e1:	6a 14                	push   $0x14
  jmp alltraps
801071e3:	e9 d8 f8 ff ff       	jmp    80106ac0 <alltraps>

801071e8 <vector21>:
.globl vector21
vector21:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $21
801071ea:	6a 15                	push   $0x15
  jmp alltraps
801071ec:	e9 cf f8 ff ff       	jmp    80106ac0 <alltraps>

801071f1 <vector22>:
.globl vector22
vector22:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $22
801071f3:	6a 16                	push   $0x16
  jmp alltraps
801071f5:	e9 c6 f8 ff ff       	jmp    80106ac0 <alltraps>

801071fa <vector23>:
.globl vector23
vector23:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $23
801071fc:	6a 17                	push   $0x17
  jmp alltraps
801071fe:	e9 bd f8 ff ff       	jmp    80106ac0 <alltraps>

80107203 <vector24>:
.globl vector24
vector24:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $24
80107205:	6a 18                	push   $0x18
  jmp alltraps
80107207:	e9 b4 f8 ff ff       	jmp    80106ac0 <alltraps>

8010720c <vector25>:
.globl vector25
vector25:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $25
8010720e:	6a 19                	push   $0x19
  jmp alltraps
80107210:	e9 ab f8 ff ff       	jmp    80106ac0 <alltraps>

80107215 <vector26>:
.globl vector26
vector26:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $26
80107217:	6a 1a                	push   $0x1a
  jmp alltraps
80107219:	e9 a2 f8 ff ff       	jmp    80106ac0 <alltraps>

8010721e <vector27>:
.globl vector27
vector27:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $27
80107220:	6a 1b                	push   $0x1b
  jmp alltraps
80107222:	e9 99 f8 ff ff       	jmp    80106ac0 <alltraps>

80107227 <vector28>:
.globl vector28
vector28:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $28
80107229:	6a 1c                	push   $0x1c
  jmp alltraps
8010722b:	e9 90 f8 ff ff       	jmp    80106ac0 <alltraps>

80107230 <vector29>:
.globl vector29
vector29:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $29
80107232:	6a 1d                	push   $0x1d
  jmp alltraps
80107234:	e9 87 f8 ff ff       	jmp    80106ac0 <alltraps>

80107239 <vector30>:
.globl vector30
vector30:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $30
8010723b:	6a 1e                	push   $0x1e
  jmp alltraps
8010723d:	e9 7e f8 ff ff       	jmp    80106ac0 <alltraps>

80107242 <vector31>:
.globl vector31
vector31:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $31
80107244:	6a 1f                	push   $0x1f
  jmp alltraps
80107246:	e9 75 f8 ff ff       	jmp    80106ac0 <alltraps>

8010724b <vector32>:
.globl vector32
vector32:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $32
8010724d:	6a 20                	push   $0x20
  jmp alltraps
8010724f:	e9 6c f8 ff ff       	jmp    80106ac0 <alltraps>

80107254 <vector33>:
.globl vector33
vector33:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $33
80107256:	6a 21                	push   $0x21
  jmp alltraps
80107258:	e9 63 f8 ff ff       	jmp    80106ac0 <alltraps>

8010725d <vector34>:
.globl vector34
vector34:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $34
8010725f:	6a 22                	push   $0x22
  jmp alltraps
80107261:	e9 5a f8 ff ff       	jmp    80106ac0 <alltraps>

80107266 <vector35>:
.globl vector35
vector35:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $35
80107268:	6a 23                	push   $0x23
  jmp alltraps
8010726a:	e9 51 f8 ff ff       	jmp    80106ac0 <alltraps>

8010726f <vector36>:
.globl vector36
vector36:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $36
80107271:	6a 24                	push   $0x24
  jmp alltraps
80107273:	e9 48 f8 ff ff       	jmp    80106ac0 <alltraps>

80107278 <vector37>:
.globl vector37
vector37:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $37
8010727a:	6a 25                	push   $0x25
  jmp alltraps
8010727c:	e9 3f f8 ff ff       	jmp    80106ac0 <alltraps>

80107281 <vector38>:
.globl vector38
vector38:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $38
80107283:	6a 26                	push   $0x26
  jmp alltraps
80107285:	e9 36 f8 ff ff       	jmp    80106ac0 <alltraps>

8010728a <vector39>:
.globl vector39
vector39:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $39
8010728c:	6a 27                	push   $0x27
  jmp alltraps
8010728e:	e9 2d f8 ff ff       	jmp    80106ac0 <alltraps>

80107293 <vector40>:
.globl vector40
vector40:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $40
80107295:	6a 28                	push   $0x28
  jmp alltraps
80107297:	e9 24 f8 ff ff       	jmp    80106ac0 <alltraps>

8010729c <vector41>:
.globl vector41
vector41:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $41
8010729e:	6a 29                	push   $0x29
  jmp alltraps
801072a0:	e9 1b f8 ff ff       	jmp    80106ac0 <alltraps>

801072a5 <vector42>:
.globl vector42
vector42:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $42
801072a7:	6a 2a                	push   $0x2a
  jmp alltraps
801072a9:	e9 12 f8 ff ff       	jmp    80106ac0 <alltraps>

801072ae <vector43>:
.globl vector43
vector43:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $43
801072b0:	6a 2b                	push   $0x2b
  jmp alltraps
801072b2:	e9 09 f8 ff ff       	jmp    80106ac0 <alltraps>

801072b7 <vector44>:
.globl vector44
vector44:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $44
801072b9:	6a 2c                	push   $0x2c
  jmp alltraps
801072bb:	e9 00 f8 ff ff       	jmp    80106ac0 <alltraps>

801072c0 <vector45>:
.globl vector45
vector45:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $45
801072c2:	6a 2d                	push   $0x2d
  jmp alltraps
801072c4:	e9 f7 f7 ff ff       	jmp    80106ac0 <alltraps>

801072c9 <vector46>:
.globl vector46
vector46:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $46
801072cb:	6a 2e                	push   $0x2e
  jmp alltraps
801072cd:	e9 ee f7 ff ff       	jmp    80106ac0 <alltraps>

801072d2 <vector47>:
.globl vector47
vector47:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $47
801072d4:	6a 2f                	push   $0x2f
  jmp alltraps
801072d6:	e9 e5 f7 ff ff       	jmp    80106ac0 <alltraps>

801072db <vector48>:
.globl vector48
vector48:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $48
801072dd:	6a 30                	push   $0x30
  jmp alltraps
801072df:	e9 dc f7 ff ff       	jmp    80106ac0 <alltraps>

801072e4 <vector49>:
.globl vector49
vector49:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $49
801072e6:	6a 31                	push   $0x31
  jmp alltraps
801072e8:	e9 d3 f7 ff ff       	jmp    80106ac0 <alltraps>

801072ed <vector50>:
.globl vector50
vector50:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $50
801072ef:	6a 32                	push   $0x32
  jmp alltraps
801072f1:	e9 ca f7 ff ff       	jmp    80106ac0 <alltraps>

801072f6 <vector51>:
.globl vector51
vector51:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $51
801072f8:	6a 33                	push   $0x33
  jmp alltraps
801072fa:	e9 c1 f7 ff ff       	jmp    80106ac0 <alltraps>

801072ff <vector52>:
.globl vector52
vector52:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $52
80107301:	6a 34                	push   $0x34
  jmp alltraps
80107303:	e9 b8 f7 ff ff       	jmp    80106ac0 <alltraps>

80107308 <vector53>:
.globl vector53
vector53:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $53
8010730a:	6a 35                	push   $0x35
  jmp alltraps
8010730c:	e9 af f7 ff ff       	jmp    80106ac0 <alltraps>

80107311 <vector54>:
.globl vector54
vector54:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $54
80107313:	6a 36                	push   $0x36
  jmp alltraps
80107315:	e9 a6 f7 ff ff       	jmp    80106ac0 <alltraps>

8010731a <vector55>:
.globl vector55
vector55:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $55
8010731c:	6a 37                	push   $0x37
  jmp alltraps
8010731e:	e9 9d f7 ff ff       	jmp    80106ac0 <alltraps>

80107323 <vector56>:
.globl vector56
vector56:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $56
80107325:	6a 38                	push   $0x38
  jmp alltraps
80107327:	e9 94 f7 ff ff       	jmp    80106ac0 <alltraps>

8010732c <vector57>:
.globl vector57
vector57:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $57
8010732e:	6a 39                	push   $0x39
  jmp alltraps
80107330:	e9 8b f7 ff ff       	jmp    80106ac0 <alltraps>

80107335 <vector58>:
.globl vector58
vector58:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $58
80107337:	6a 3a                	push   $0x3a
  jmp alltraps
80107339:	e9 82 f7 ff ff       	jmp    80106ac0 <alltraps>

8010733e <vector59>:
.globl vector59
vector59:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $59
80107340:	6a 3b                	push   $0x3b
  jmp alltraps
80107342:	e9 79 f7 ff ff       	jmp    80106ac0 <alltraps>

80107347 <vector60>:
.globl vector60
vector60:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $60
80107349:	6a 3c                	push   $0x3c
  jmp alltraps
8010734b:	e9 70 f7 ff ff       	jmp    80106ac0 <alltraps>

80107350 <vector61>:
.globl vector61
vector61:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $61
80107352:	6a 3d                	push   $0x3d
  jmp alltraps
80107354:	e9 67 f7 ff ff       	jmp    80106ac0 <alltraps>

80107359 <vector62>:
.globl vector62
vector62:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $62
8010735b:	6a 3e                	push   $0x3e
  jmp alltraps
8010735d:	e9 5e f7 ff ff       	jmp    80106ac0 <alltraps>

80107362 <vector63>:
.globl vector63
vector63:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $63
80107364:	6a 3f                	push   $0x3f
  jmp alltraps
80107366:	e9 55 f7 ff ff       	jmp    80106ac0 <alltraps>

8010736b <vector64>:
.globl vector64
vector64:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $64
8010736d:	6a 40                	push   $0x40
  jmp alltraps
8010736f:	e9 4c f7 ff ff       	jmp    80106ac0 <alltraps>

80107374 <vector65>:
.globl vector65
vector65:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $65
80107376:	6a 41                	push   $0x41
  jmp alltraps
80107378:	e9 43 f7 ff ff       	jmp    80106ac0 <alltraps>

8010737d <vector66>:
.globl vector66
vector66:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $66
8010737f:	6a 42                	push   $0x42
  jmp alltraps
80107381:	e9 3a f7 ff ff       	jmp    80106ac0 <alltraps>

80107386 <vector67>:
.globl vector67
vector67:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $67
80107388:	6a 43                	push   $0x43
  jmp alltraps
8010738a:	e9 31 f7 ff ff       	jmp    80106ac0 <alltraps>

8010738f <vector68>:
.globl vector68
vector68:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $68
80107391:	6a 44                	push   $0x44
  jmp alltraps
80107393:	e9 28 f7 ff ff       	jmp    80106ac0 <alltraps>

80107398 <vector69>:
.globl vector69
vector69:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $69
8010739a:	6a 45                	push   $0x45
  jmp alltraps
8010739c:	e9 1f f7 ff ff       	jmp    80106ac0 <alltraps>

801073a1 <vector70>:
.globl vector70
vector70:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $70
801073a3:	6a 46                	push   $0x46
  jmp alltraps
801073a5:	e9 16 f7 ff ff       	jmp    80106ac0 <alltraps>

801073aa <vector71>:
.globl vector71
vector71:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $71
801073ac:	6a 47                	push   $0x47
  jmp alltraps
801073ae:	e9 0d f7 ff ff       	jmp    80106ac0 <alltraps>

801073b3 <vector72>:
.globl vector72
vector72:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $72
801073b5:	6a 48                	push   $0x48
  jmp alltraps
801073b7:	e9 04 f7 ff ff       	jmp    80106ac0 <alltraps>

801073bc <vector73>:
.globl vector73
vector73:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $73
801073be:	6a 49                	push   $0x49
  jmp alltraps
801073c0:	e9 fb f6 ff ff       	jmp    80106ac0 <alltraps>

801073c5 <vector74>:
.globl vector74
vector74:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $74
801073c7:	6a 4a                	push   $0x4a
  jmp alltraps
801073c9:	e9 f2 f6 ff ff       	jmp    80106ac0 <alltraps>

801073ce <vector75>:
.globl vector75
vector75:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $75
801073d0:	6a 4b                	push   $0x4b
  jmp alltraps
801073d2:	e9 e9 f6 ff ff       	jmp    80106ac0 <alltraps>

801073d7 <vector76>:
.globl vector76
vector76:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $76
801073d9:	6a 4c                	push   $0x4c
  jmp alltraps
801073db:	e9 e0 f6 ff ff       	jmp    80106ac0 <alltraps>

801073e0 <vector77>:
.globl vector77
vector77:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $77
801073e2:	6a 4d                	push   $0x4d
  jmp alltraps
801073e4:	e9 d7 f6 ff ff       	jmp    80106ac0 <alltraps>

801073e9 <vector78>:
.globl vector78
vector78:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $78
801073eb:	6a 4e                	push   $0x4e
  jmp alltraps
801073ed:	e9 ce f6 ff ff       	jmp    80106ac0 <alltraps>

801073f2 <vector79>:
.globl vector79
vector79:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $79
801073f4:	6a 4f                	push   $0x4f
  jmp alltraps
801073f6:	e9 c5 f6 ff ff       	jmp    80106ac0 <alltraps>

801073fb <vector80>:
.globl vector80
vector80:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $80
801073fd:	6a 50                	push   $0x50
  jmp alltraps
801073ff:	e9 bc f6 ff ff       	jmp    80106ac0 <alltraps>

80107404 <vector81>:
.globl vector81
vector81:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $81
80107406:	6a 51                	push   $0x51
  jmp alltraps
80107408:	e9 b3 f6 ff ff       	jmp    80106ac0 <alltraps>

8010740d <vector82>:
.globl vector82
vector82:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $82
8010740f:	6a 52                	push   $0x52
  jmp alltraps
80107411:	e9 aa f6 ff ff       	jmp    80106ac0 <alltraps>

80107416 <vector83>:
.globl vector83
vector83:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $83
80107418:	6a 53                	push   $0x53
  jmp alltraps
8010741a:	e9 a1 f6 ff ff       	jmp    80106ac0 <alltraps>

8010741f <vector84>:
.globl vector84
vector84:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $84
80107421:	6a 54                	push   $0x54
  jmp alltraps
80107423:	e9 98 f6 ff ff       	jmp    80106ac0 <alltraps>

80107428 <vector85>:
.globl vector85
vector85:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $85
8010742a:	6a 55                	push   $0x55
  jmp alltraps
8010742c:	e9 8f f6 ff ff       	jmp    80106ac0 <alltraps>

80107431 <vector86>:
.globl vector86
vector86:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $86
80107433:	6a 56                	push   $0x56
  jmp alltraps
80107435:	e9 86 f6 ff ff       	jmp    80106ac0 <alltraps>

8010743a <vector87>:
.globl vector87
vector87:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $87
8010743c:	6a 57                	push   $0x57
  jmp alltraps
8010743e:	e9 7d f6 ff ff       	jmp    80106ac0 <alltraps>

80107443 <vector88>:
.globl vector88
vector88:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $88
80107445:	6a 58                	push   $0x58
  jmp alltraps
80107447:	e9 74 f6 ff ff       	jmp    80106ac0 <alltraps>

8010744c <vector89>:
.globl vector89
vector89:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $89
8010744e:	6a 59                	push   $0x59
  jmp alltraps
80107450:	e9 6b f6 ff ff       	jmp    80106ac0 <alltraps>

80107455 <vector90>:
.globl vector90
vector90:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $90
80107457:	6a 5a                	push   $0x5a
  jmp alltraps
80107459:	e9 62 f6 ff ff       	jmp    80106ac0 <alltraps>

8010745e <vector91>:
.globl vector91
vector91:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $91
80107460:	6a 5b                	push   $0x5b
  jmp alltraps
80107462:	e9 59 f6 ff ff       	jmp    80106ac0 <alltraps>

80107467 <vector92>:
.globl vector92
vector92:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $92
80107469:	6a 5c                	push   $0x5c
  jmp alltraps
8010746b:	e9 50 f6 ff ff       	jmp    80106ac0 <alltraps>

80107470 <vector93>:
.globl vector93
vector93:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $93
80107472:	6a 5d                	push   $0x5d
  jmp alltraps
80107474:	e9 47 f6 ff ff       	jmp    80106ac0 <alltraps>

80107479 <vector94>:
.globl vector94
vector94:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $94
8010747b:	6a 5e                	push   $0x5e
  jmp alltraps
8010747d:	e9 3e f6 ff ff       	jmp    80106ac0 <alltraps>

80107482 <vector95>:
.globl vector95
vector95:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $95
80107484:	6a 5f                	push   $0x5f
  jmp alltraps
80107486:	e9 35 f6 ff ff       	jmp    80106ac0 <alltraps>

8010748b <vector96>:
.globl vector96
vector96:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $96
8010748d:	6a 60                	push   $0x60
  jmp alltraps
8010748f:	e9 2c f6 ff ff       	jmp    80106ac0 <alltraps>

80107494 <vector97>:
.globl vector97
vector97:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $97
80107496:	6a 61                	push   $0x61
  jmp alltraps
80107498:	e9 23 f6 ff ff       	jmp    80106ac0 <alltraps>

8010749d <vector98>:
.globl vector98
vector98:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $98
8010749f:	6a 62                	push   $0x62
  jmp alltraps
801074a1:	e9 1a f6 ff ff       	jmp    80106ac0 <alltraps>

801074a6 <vector99>:
.globl vector99
vector99:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $99
801074a8:	6a 63                	push   $0x63
  jmp alltraps
801074aa:	e9 11 f6 ff ff       	jmp    80106ac0 <alltraps>

801074af <vector100>:
.globl vector100
vector100:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $100
801074b1:	6a 64                	push   $0x64
  jmp alltraps
801074b3:	e9 08 f6 ff ff       	jmp    80106ac0 <alltraps>

801074b8 <vector101>:
.globl vector101
vector101:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $101
801074ba:	6a 65                	push   $0x65
  jmp alltraps
801074bc:	e9 ff f5 ff ff       	jmp    80106ac0 <alltraps>

801074c1 <vector102>:
.globl vector102
vector102:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $102
801074c3:	6a 66                	push   $0x66
  jmp alltraps
801074c5:	e9 f6 f5 ff ff       	jmp    80106ac0 <alltraps>

801074ca <vector103>:
.globl vector103
vector103:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $103
801074cc:	6a 67                	push   $0x67
  jmp alltraps
801074ce:	e9 ed f5 ff ff       	jmp    80106ac0 <alltraps>

801074d3 <vector104>:
.globl vector104
vector104:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $104
801074d5:	6a 68                	push   $0x68
  jmp alltraps
801074d7:	e9 e4 f5 ff ff       	jmp    80106ac0 <alltraps>

801074dc <vector105>:
.globl vector105
vector105:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $105
801074de:	6a 69                	push   $0x69
  jmp alltraps
801074e0:	e9 db f5 ff ff       	jmp    80106ac0 <alltraps>

801074e5 <vector106>:
.globl vector106
vector106:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $106
801074e7:	6a 6a                	push   $0x6a
  jmp alltraps
801074e9:	e9 d2 f5 ff ff       	jmp    80106ac0 <alltraps>

801074ee <vector107>:
.globl vector107
vector107:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $107
801074f0:	6a 6b                	push   $0x6b
  jmp alltraps
801074f2:	e9 c9 f5 ff ff       	jmp    80106ac0 <alltraps>

801074f7 <vector108>:
.globl vector108
vector108:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $108
801074f9:	6a 6c                	push   $0x6c
  jmp alltraps
801074fb:	e9 c0 f5 ff ff       	jmp    80106ac0 <alltraps>

80107500 <vector109>:
.globl vector109
vector109:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $109
80107502:	6a 6d                	push   $0x6d
  jmp alltraps
80107504:	e9 b7 f5 ff ff       	jmp    80106ac0 <alltraps>

80107509 <vector110>:
.globl vector110
vector110:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $110
8010750b:	6a 6e                	push   $0x6e
  jmp alltraps
8010750d:	e9 ae f5 ff ff       	jmp    80106ac0 <alltraps>

80107512 <vector111>:
.globl vector111
vector111:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $111
80107514:	6a 6f                	push   $0x6f
  jmp alltraps
80107516:	e9 a5 f5 ff ff       	jmp    80106ac0 <alltraps>

8010751b <vector112>:
.globl vector112
vector112:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $112
8010751d:	6a 70                	push   $0x70
  jmp alltraps
8010751f:	e9 9c f5 ff ff       	jmp    80106ac0 <alltraps>

80107524 <vector113>:
.globl vector113
vector113:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $113
80107526:	6a 71                	push   $0x71
  jmp alltraps
80107528:	e9 93 f5 ff ff       	jmp    80106ac0 <alltraps>

8010752d <vector114>:
.globl vector114
vector114:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $114
8010752f:	6a 72                	push   $0x72
  jmp alltraps
80107531:	e9 8a f5 ff ff       	jmp    80106ac0 <alltraps>

80107536 <vector115>:
.globl vector115
vector115:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $115
80107538:	6a 73                	push   $0x73
  jmp alltraps
8010753a:	e9 81 f5 ff ff       	jmp    80106ac0 <alltraps>

8010753f <vector116>:
.globl vector116
vector116:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $116
80107541:	6a 74                	push   $0x74
  jmp alltraps
80107543:	e9 78 f5 ff ff       	jmp    80106ac0 <alltraps>

80107548 <vector117>:
.globl vector117
vector117:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $117
8010754a:	6a 75                	push   $0x75
  jmp alltraps
8010754c:	e9 6f f5 ff ff       	jmp    80106ac0 <alltraps>

80107551 <vector118>:
.globl vector118
vector118:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $118
80107553:	6a 76                	push   $0x76
  jmp alltraps
80107555:	e9 66 f5 ff ff       	jmp    80106ac0 <alltraps>

8010755a <vector119>:
.globl vector119
vector119:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $119
8010755c:	6a 77                	push   $0x77
  jmp alltraps
8010755e:	e9 5d f5 ff ff       	jmp    80106ac0 <alltraps>

80107563 <vector120>:
.globl vector120
vector120:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $120
80107565:	6a 78                	push   $0x78
  jmp alltraps
80107567:	e9 54 f5 ff ff       	jmp    80106ac0 <alltraps>

8010756c <vector121>:
.globl vector121
vector121:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $121
8010756e:	6a 79                	push   $0x79
  jmp alltraps
80107570:	e9 4b f5 ff ff       	jmp    80106ac0 <alltraps>

80107575 <vector122>:
.globl vector122
vector122:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $122
80107577:	6a 7a                	push   $0x7a
  jmp alltraps
80107579:	e9 42 f5 ff ff       	jmp    80106ac0 <alltraps>

8010757e <vector123>:
.globl vector123
vector123:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $123
80107580:	6a 7b                	push   $0x7b
  jmp alltraps
80107582:	e9 39 f5 ff ff       	jmp    80106ac0 <alltraps>

80107587 <vector124>:
.globl vector124
vector124:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $124
80107589:	6a 7c                	push   $0x7c
  jmp alltraps
8010758b:	e9 30 f5 ff ff       	jmp    80106ac0 <alltraps>

80107590 <vector125>:
.globl vector125
vector125:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $125
80107592:	6a 7d                	push   $0x7d
  jmp alltraps
80107594:	e9 27 f5 ff ff       	jmp    80106ac0 <alltraps>

80107599 <vector126>:
.globl vector126
vector126:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $126
8010759b:	6a 7e                	push   $0x7e
  jmp alltraps
8010759d:	e9 1e f5 ff ff       	jmp    80106ac0 <alltraps>

801075a2 <vector127>:
.globl vector127
vector127:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $127
801075a4:	6a 7f                	push   $0x7f
  jmp alltraps
801075a6:	e9 15 f5 ff ff       	jmp    80106ac0 <alltraps>

801075ab <vector128>:
.globl vector128
vector128:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $128
801075ad:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075b2:	e9 09 f5 ff ff       	jmp    80106ac0 <alltraps>

801075b7 <vector129>:
.globl vector129
vector129:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $129
801075b9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075be:	e9 fd f4 ff ff       	jmp    80106ac0 <alltraps>

801075c3 <vector130>:
.globl vector130
vector130:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $130
801075c5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075ca:	e9 f1 f4 ff ff       	jmp    80106ac0 <alltraps>

801075cf <vector131>:
.globl vector131
vector131:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $131
801075d1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075d6:	e9 e5 f4 ff ff       	jmp    80106ac0 <alltraps>

801075db <vector132>:
.globl vector132
vector132:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $132
801075dd:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075e2:	e9 d9 f4 ff ff       	jmp    80106ac0 <alltraps>

801075e7 <vector133>:
.globl vector133
vector133:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $133
801075e9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075ee:	e9 cd f4 ff ff       	jmp    80106ac0 <alltraps>

801075f3 <vector134>:
.globl vector134
vector134:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $134
801075f5:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075fa:	e9 c1 f4 ff ff       	jmp    80106ac0 <alltraps>

801075ff <vector135>:
.globl vector135
vector135:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $135
80107601:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107606:	e9 b5 f4 ff ff       	jmp    80106ac0 <alltraps>

8010760b <vector136>:
.globl vector136
vector136:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $136
8010760d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107612:	e9 a9 f4 ff ff       	jmp    80106ac0 <alltraps>

80107617 <vector137>:
.globl vector137
vector137:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $137
80107619:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010761e:	e9 9d f4 ff ff       	jmp    80106ac0 <alltraps>

80107623 <vector138>:
.globl vector138
vector138:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $138
80107625:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010762a:	e9 91 f4 ff ff       	jmp    80106ac0 <alltraps>

8010762f <vector139>:
.globl vector139
vector139:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $139
80107631:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107636:	e9 85 f4 ff ff       	jmp    80106ac0 <alltraps>

8010763b <vector140>:
.globl vector140
vector140:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $140
8010763d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107642:	e9 79 f4 ff ff       	jmp    80106ac0 <alltraps>

80107647 <vector141>:
.globl vector141
vector141:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $141
80107649:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010764e:	e9 6d f4 ff ff       	jmp    80106ac0 <alltraps>

80107653 <vector142>:
.globl vector142
vector142:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $142
80107655:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010765a:	e9 61 f4 ff ff       	jmp    80106ac0 <alltraps>

8010765f <vector143>:
.globl vector143
vector143:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $143
80107661:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107666:	e9 55 f4 ff ff       	jmp    80106ac0 <alltraps>

8010766b <vector144>:
.globl vector144
vector144:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $144
8010766d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107672:	e9 49 f4 ff ff       	jmp    80106ac0 <alltraps>

80107677 <vector145>:
.globl vector145
vector145:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $145
80107679:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010767e:	e9 3d f4 ff ff       	jmp    80106ac0 <alltraps>

80107683 <vector146>:
.globl vector146
vector146:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $146
80107685:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010768a:	e9 31 f4 ff ff       	jmp    80106ac0 <alltraps>

8010768f <vector147>:
.globl vector147
vector147:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $147
80107691:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107696:	e9 25 f4 ff ff       	jmp    80106ac0 <alltraps>

8010769b <vector148>:
.globl vector148
vector148:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $148
8010769d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076a2:	e9 19 f4 ff ff       	jmp    80106ac0 <alltraps>

801076a7 <vector149>:
.globl vector149
vector149:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $149
801076a9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076ae:	e9 0d f4 ff ff       	jmp    80106ac0 <alltraps>

801076b3 <vector150>:
.globl vector150
vector150:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $150
801076b5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ba:	e9 01 f4 ff ff       	jmp    80106ac0 <alltraps>

801076bf <vector151>:
.globl vector151
vector151:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $151
801076c1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076c6:	e9 f5 f3 ff ff       	jmp    80106ac0 <alltraps>

801076cb <vector152>:
.globl vector152
vector152:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $152
801076cd:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076d2:	e9 e9 f3 ff ff       	jmp    80106ac0 <alltraps>

801076d7 <vector153>:
.globl vector153
vector153:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $153
801076d9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076de:	e9 dd f3 ff ff       	jmp    80106ac0 <alltraps>

801076e3 <vector154>:
.globl vector154
vector154:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $154
801076e5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076ea:	e9 d1 f3 ff ff       	jmp    80106ac0 <alltraps>

801076ef <vector155>:
.globl vector155
vector155:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $155
801076f1:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076f6:	e9 c5 f3 ff ff       	jmp    80106ac0 <alltraps>

801076fb <vector156>:
.globl vector156
vector156:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $156
801076fd:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107702:	e9 b9 f3 ff ff       	jmp    80106ac0 <alltraps>

80107707 <vector157>:
.globl vector157
vector157:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $157
80107709:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010770e:	e9 ad f3 ff ff       	jmp    80106ac0 <alltraps>

80107713 <vector158>:
.globl vector158
vector158:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $158
80107715:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010771a:	e9 a1 f3 ff ff       	jmp    80106ac0 <alltraps>

8010771f <vector159>:
.globl vector159
vector159:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $159
80107721:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107726:	e9 95 f3 ff ff       	jmp    80106ac0 <alltraps>

8010772b <vector160>:
.globl vector160
vector160:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $160
8010772d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107732:	e9 89 f3 ff ff       	jmp    80106ac0 <alltraps>

80107737 <vector161>:
.globl vector161
vector161:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $161
80107739:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010773e:	e9 7d f3 ff ff       	jmp    80106ac0 <alltraps>

80107743 <vector162>:
.globl vector162
vector162:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $162
80107745:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010774a:	e9 71 f3 ff ff       	jmp    80106ac0 <alltraps>

8010774f <vector163>:
.globl vector163
vector163:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $163
80107751:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107756:	e9 65 f3 ff ff       	jmp    80106ac0 <alltraps>

8010775b <vector164>:
.globl vector164
vector164:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $164
8010775d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107762:	e9 59 f3 ff ff       	jmp    80106ac0 <alltraps>

80107767 <vector165>:
.globl vector165
vector165:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $165
80107769:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010776e:	e9 4d f3 ff ff       	jmp    80106ac0 <alltraps>

80107773 <vector166>:
.globl vector166
vector166:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $166
80107775:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010777a:	e9 41 f3 ff ff       	jmp    80106ac0 <alltraps>

8010777f <vector167>:
.globl vector167
vector167:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $167
80107781:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107786:	e9 35 f3 ff ff       	jmp    80106ac0 <alltraps>

8010778b <vector168>:
.globl vector168
vector168:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $168
8010778d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107792:	e9 29 f3 ff ff       	jmp    80106ac0 <alltraps>

80107797 <vector169>:
.globl vector169
vector169:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $169
80107799:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010779e:	e9 1d f3 ff ff       	jmp    80106ac0 <alltraps>

801077a3 <vector170>:
.globl vector170
vector170:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $170
801077a5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077aa:	e9 11 f3 ff ff       	jmp    80106ac0 <alltraps>

801077af <vector171>:
.globl vector171
vector171:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $171
801077b1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077b6:	e9 05 f3 ff ff       	jmp    80106ac0 <alltraps>

801077bb <vector172>:
.globl vector172
vector172:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $172
801077bd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077c2:	e9 f9 f2 ff ff       	jmp    80106ac0 <alltraps>

801077c7 <vector173>:
.globl vector173
vector173:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $173
801077c9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077ce:	e9 ed f2 ff ff       	jmp    80106ac0 <alltraps>

801077d3 <vector174>:
.globl vector174
vector174:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $174
801077d5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077da:	e9 e1 f2 ff ff       	jmp    80106ac0 <alltraps>

801077df <vector175>:
.globl vector175
vector175:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $175
801077e1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077e6:	e9 d5 f2 ff ff       	jmp    80106ac0 <alltraps>

801077eb <vector176>:
.globl vector176
vector176:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $176
801077ed:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077f2:	e9 c9 f2 ff ff       	jmp    80106ac0 <alltraps>

801077f7 <vector177>:
.globl vector177
vector177:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $177
801077f9:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077fe:	e9 bd f2 ff ff       	jmp    80106ac0 <alltraps>

80107803 <vector178>:
.globl vector178
vector178:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $178
80107805:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010780a:	e9 b1 f2 ff ff       	jmp    80106ac0 <alltraps>

8010780f <vector179>:
.globl vector179
vector179:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $179
80107811:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107816:	e9 a5 f2 ff ff       	jmp    80106ac0 <alltraps>

8010781b <vector180>:
.globl vector180
vector180:
  pushl $0
8010781b:	6a 00                	push   $0x0
  pushl $180
8010781d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107822:	e9 99 f2 ff ff       	jmp    80106ac0 <alltraps>

80107827 <vector181>:
.globl vector181
vector181:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $181
80107829:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010782e:	e9 8d f2 ff ff       	jmp    80106ac0 <alltraps>

80107833 <vector182>:
.globl vector182
vector182:
  pushl $0
80107833:	6a 00                	push   $0x0
  pushl $182
80107835:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010783a:	e9 81 f2 ff ff       	jmp    80106ac0 <alltraps>

8010783f <vector183>:
.globl vector183
vector183:
  pushl $0
8010783f:	6a 00                	push   $0x0
  pushl $183
80107841:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107846:	e9 75 f2 ff ff       	jmp    80106ac0 <alltraps>

8010784b <vector184>:
.globl vector184
vector184:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $184
8010784d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107852:	e9 69 f2 ff ff       	jmp    80106ac0 <alltraps>

80107857 <vector185>:
.globl vector185
vector185:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $185
80107859:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010785e:	e9 5d f2 ff ff       	jmp    80106ac0 <alltraps>

80107863 <vector186>:
.globl vector186
vector186:
  pushl $0
80107863:	6a 00                	push   $0x0
  pushl $186
80107865:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010786a:	e9 51 f2 ff ff       	jmp    80106ac0 <alltraps>

8010786f <vector187>:
.globl vector187
vector187:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $187
80107871:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107876:	e9 45 f2 ff ff       	jmp    80106ac0 <alltraps>

8010787b <vector188>:
.globl vector188
vector188:
  pushl $0
8010787b:	6a 00                	push   $0x0
  pushl $188
8010787d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107882:	e9 39 f2 ff ff       	jmp    80106ac0 <alltraps>

80107887 <vector189>:
.globl vector189
vector189:
  pushl $0
80107887:	6a 00                	push   $0x0
  pushl $189
80107889:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010788e:	e9 2d f2 ff ff       	jmp    80106ac0 <alltraps>

80107893 <vector190>:
.globl vector190
vector190:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $190
80107895:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010789a:	e9 21 f2 ff ff       	jmp    80106ac0 <alltraps>

8010789f <vector191>:
.globl vector191
vector191:
  pushl $0
8010789f:	6a 00                	push   $0x0
  pushl $191
801078a1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078a6:	e9 15 f2 ff ff       	jmp    80106ac0 <alltraps>

801078ab <vector192>:
.globl vector192
vector192:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $192
801078ad:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078b2:	e9 09 f2 ff ff       	jmp    80106ac0 <alltraps>

801078b7 <vector193>:
.globl vector193
vector193:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $193
801078b9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078be:	e9 fd f1 ff ff       	jmp    80106ac0 <alltraps>

801078c3 <vector194>:
.globl vector194
vector194:
  pushl $0
801078c3:	6a 00                	push   $0x0
  pushl $194
801078c5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078ca:	e9 f1 f1 ff ff       	jmp    80106ac0 <alltraps>

801078cf <vector195>:
.globl vector195
vector195:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $195
801078d1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078d6:	e9 e5 f1 ff ff       	jmp    80106ac0 <alltraps>

801078db <vector196>:
.globl vector196
vector196:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $196
801078dd:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078e2:	e9 d9 f1 ff ff       	jmp    80106ac0 <alltraps>

801078e7 <vector197>:
.globl vector197
vector197:
  pushl $0
801078e7:	6a 00                	push   $0x0
  pushl $197
801078e9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078ee:	e9 cd f1 ff ff       	jmp    80106ac0 <alltraps>

801078f3 <vector198>:
.globl vector198
vector198:
  pushl $0
801078f3:	6a 00                	push   $0x0
  pushl $198
801078f5:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078fa:	e9 c1 f1 ff ff       	jmp    80106ac0 <alltraps>

801078ff <vector199>:
.globl vector199
vector199:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $199
80107901:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107906:	e9 b5 f1 ff ff       	jmp    80106ac0 <alltraps>

8010790b <vector200>:
.globl vector200
vector200:
  pushl $0
8010790b:	6a 00                	push   $0x0
  pushl $200
8010790d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107912:	e9 a9 f1 ff ff       	jmp    80106ac0 <alltraps>

80107917 <vector201>:
.globl vector201
vector201:
  pushl $0
80107917:	6a 00                	push   $0x0
  pushl $201
80107919:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010791e:	e9 9d f1 ff ff       	jmp    80106ac0 <alltraps>

80107923 <vector202>:
.globl vector202
vector202:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $202
80107925:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010792a:	e9 91 f1 ff ff       	jmp    80106ac0 <alltraps>

8010792f <vector203>:
.globl vector203
vector203:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $203
80107931:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107936:	e9 85 f1 ff ff       	jmp    80106ac0 <alltraps>

8010793b <vector204>:
.globl vector204
vector204:
  pushl $0
8010793b:	6a 00                	push   $0x0
  pushl $204
8010793d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107942:	e9 79 f1 ff ff       	jmp    80106ac0 <alltraps>

80107947 <vector205>:
.globl vector205
vector205:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $205
80107949:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010794e:	e9 6d f1 ff ff       	jmp    80106ac0 <alltraps>

80107953 <vector206>:
.globl vector206
vector206:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $206
80107955:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010795a:	e9 61 f1 ff ff       	jmp    80106ac0 <alltraps>

8010795f <vector207>:
.globl vector207
vector207:
  pushl $0
8010795f:	6a 00                	push   $0x0
  pushl $207
80107961:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107966:	e9 55 f1 ff ff       	jmp    80106ac0 <alltraps>

8010796b <vector208>:
.globl vector208
vector208:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $208
8010796d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107972:	e9 49 f1 ff ff       	jmp    80106ac0 <alltraps>

80107977 <vector209>:
.globl vector209
vector209:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $209
80107979:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010797e:	e9 3d f1 ff ff       	jmp    80106ac0 <alltraps>

80107983 <vector210>:
.globl vector210
vector210:
  pushl $0
80107983:	6a 00                	push   $0x0
  pushl $210
80107985:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010798a:	e9 31 f1 ff ff       	jmp    80106ac0 <alltraps>

8010798f <vector211>:
.globl vector211
vector211:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $211
80107991:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107996:	e9 25 f1 ff ff       	jmp    80106ac0 <alltraps>

8010799b <vector212>:
.globl vector212
vector212:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $212
8010799d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079a2:	e9 19 f1 ff ff       	jmp    80106ac0 <alltraps>

801079a7 <vector213>:
.globl vector213
vector213:
  pushl $0
801079a7:	6a 00                	push   $0x0
  pushl $213
801079a9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079ae:	e9 0d f1 ff ff       	jmp    80106ac0 <alltraps>

801079b3 <vector214>:
.globl vector214
vector214:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $214
801079b5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ba:	e9 01 f1 ff ff       	jmp    80106ac0 <alltraps>

801079bf <vector215>:
.globl vector215
vector215:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $215
801079c1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079c6:	e9 f5 f0 ff ff       	jmp    80106ac0 <alltraps>

801079cb <vector216>:
.globl vector216
vector216:
  pushl $0
801079cb:	6a 00                	push   $0x0
  pushl $216
801079cd:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079d2:	e9 e9 f0 ff ff       	jmp    80106ac0 <alltraps>

801079d7 <vector217>:
.globl vector217
vector217:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $217
801079d9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079de:	e9 dd f0 ff ff       	jmp    80106ac0 <alltraps>

801079e3 <vector218>:
.globl vector218
vector218:
  pushl $0
801079e3:	6a 00                	push   $0x0
  pushl $218
801079e5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079ea:	e9 d1 f0 ff ff       	jmp    80106ac0 <alltraps>

801079ef <vector219>:
.globl vector219
vector219:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $219
801079f1:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079f6:	e9 c5 f0 ff ff       	jmp    80106ac0 <alltraps>

801079fb <vector220>:
.globl vector220
vector220:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $220
801079fd:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a02:	e9 b9 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a07 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $221
80107a09:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a0e:	e9 ad f0 ff ff       	jmp    80106ac0 <alltraps>

80107a13 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a13:	6a 00                	push   $0x0
  pushl $222
80107a15:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a1a:	e9 a1 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a1f <vector223>:
.globl vector223
vector223:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $223
80107a21:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a26:	e9 95 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a2b <vector224>:
.globl vector224
vector224:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $224
80107a2d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a32:	e9 89 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a37 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $225
80107a39:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a3e:	e9 7d f0 ff ff       	jmp    80106ac0 <alltraps>

80107a43 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $226
80107a45:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a4a:	e9 71 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a4f <vector227>:
.globl vector227
vector227:
  pushl $0
80107a4f:	6a 00                	push   $0x0
  pushl $227
80107a51:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a56:	e9 65 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a5b <vector228>:
.globl vector228
vector228:
  pushl $0
80107a5b:	6a 00                	push   $0x0
  pushl $228
80107a5d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a62:	e9 59 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a67 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $229
80107a69:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a6e:	e9 4d f0 ff ff       	jmp    80106ac0 <alltraps>

80107a73 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a73:	6a 00                	push   $0x0
  pushl $230
80107a75:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a7a:	e9 41 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a7f <vector231>:
.globl vector231
vector231:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $231
80107a81:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a86:	e9 35 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a8b <vector232>:
.globl vector232
vector232:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $232
80107a8d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a92:	e9 29 f0 ff ff       	jmp    80106ac0 <alltraps>

80107a97 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a97:	6a 00                	push   $0x0
  pushl $233
80107a99:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a9e:	e9 1d f0 ff ff       	jmp    80106ac0 <alltraps>

80107aa3 <vector234>:
.globl vector234
vector234:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $234
80107aa5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107aaa:	e9 11 f0 ff ff       	jmp    80106ac0 <alltraps>

80107aaf <vector235>:
.globl vector235
vector235:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $235
80107ab1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ab6:	e9 05 f0 ff ff       	jmp    80106ac0 <alltraps>

80107abb <vector236>:
.globl vector236
vector236:
  pushl $0
80107abb:	6a 00                	push   $0x0
  pushl $236
80107abd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ac2:	e9 f9 ef ff ff       	jmp    80106ac0 <alltraps>

80107ac7 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $237
80107ac9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ace:	e9 ed ef ff ff       	jmp    80106ac0 <alltraps>

80107ad3 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $238
80107ad5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ada:	e9 e1 ef ff ff       	jmp    80106ac0 <alltraps>

80107adf <vector239>:
.globl vector239
vector239:
  pushl $0
80107adf:	6a 00                	push   $0x0
  pushl $239
80107ae1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ae6:	e9 d5 ef ff ff       	jmp    80106ac0 <alltraps>

80107aeb <vector240>:
.globl vector240
vector240:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $240
80107aed:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107af2:	e9 c9 ef ff ff       	jmp    80106ac0 <alltraps>

80107af7 <vector241>:
.globl vector241
vector241:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $241
80107af9:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107afe:	e9 bd ef ff ff       	jmp    80106ac0 <alltraps>

80107b03 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b03:	6a 00                	push   $0x0
  pushl $242
80107b05:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b0a:	e9 b1 ef ff ff       	jmp    80106ac0 <alltraps>

80107b0f <vector243>:
.globl vector243
vector243:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $243
80107b11:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b16:	e9 a5 ef ff ff       	jmp    80106ac0 <alltraps>

80107b1b <vector244>:
.globl vector244
vector244:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $244
80107b1d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b22:	e9 99 ef ff ff       	jmp    80106ac0 <alltraps>

80107b27 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $245
80107b29:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b2e:	e9 8d ef ff ff       	jmp    80106ac0 <alltraps>

80107b33 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b33:	6a 00                	push   $0x0
  pushl $246
80107b35:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b3a:	e9 81 ef ff ff       	jmp    80106ac0 <alltraps>

80107b3f <vector247>:
.globl vector247
vector247:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $247
80107b41:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b46:	e9 75 ef ff ff       	jmp    80106ac0 <alltraps>

80107b4b <vector248>:
.globl vector248
vector248:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $248
80107b4d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b52:	e9 69 ef ff ff       	jmp    80106ac0 <alltraps>

80107b57 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $249
80107b59:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b5e:	e9 5d ef ff ff       	jmp    80106ac0 <alltraps>

80107b63 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $250
80107b65:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b6a:	e9 51 ef ff ff       	jmp    80106ac0 <alltraps>

80107b6f <vector251>:
.globl vector251
vector251:
  pushl $0
80107b6f:	6a 00                	push   $0x0
  pushl $251
80107b71:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b76:	e9 45 ef ff ff       	jmp    80106ac0 <alltraps>

80107b7b <vector252>:
.globl vector252
vector252:
  pushl $0
80107b7b:	6a 00                	push   $0x0
  pushl $252
80107b7d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b82:	e9 39 ef ff ff       	jmp    80106ac0 <alltraps>

80107b87 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b87:	6a 00                	push   $0x0
  pushl $253
80107b89:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b8e:	e9 2d ef ff ff       	jmp    80106ac0 <alltraps>

80107b93 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b93:	6a 00                	push   $0x0
  pushl $254
80107b95:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b9a:	e9 21 ef ff ff       	jmp    80106ac0 <alltraps>

80107b9f <vector255>:
.globl vector255
vector255:
  pushl $0
80107b9f:	6a 00                	push   $0x0
  pushl $255
80107ba1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107ba6:	e9 15 ef ff ff       	jmp    80106ac0 <alltraps>

80107bab <lgdt>:
{
80107bab:	55                   	push   %ebp
80107bac:	89 e5                	mov    %esp,%ebp
80107bae:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bb4:	83 e8 01             	sub    $0x1,%eax
80107bb7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bbe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc5:	c1 e8 10             	shr    $0x10,%eax
80107bc8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bcc:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bcf:	0f 01 10             	lgdtl  (%eax)
}
80107bd2:	90                   	nop
80107bd3:	c9                   	leave  
80107bd4:	c3                   	ret    

80107bd5 <ltr>:
{
80107bd5:	55                   	push   %ebp
80107bd6:	89 e5                	mov    %esp,%ebp
80107bd8:	83 ec 04             	sub    $0x4,%esp
80107bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bde:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107be2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107be6:	0f 00 d8             	ltr    %ax
}
80107be9:	90                   	nop
80107bea:	c9                   	leave  
80107beb:	c3                   	ret    

80107bec <lcr3>:

static inline void
lcr3(uint val)
{
80107bec:	55                   	push   %ebp
80107bed:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bef:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf2:	0f 22 d8             	mov    %eax,%cr3
}
80107bf5:	90                   	nop
80107bf6:	5d                   	pop    %ebp
80107bf7:	c3                   	ret    

80107bf8 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107bf8:	f3 0f 1e fb          	endbr32 
80107bfc:	55                   	push   %ebp
80107bfd:	89 e5                	mov    %esp,%ebp
80107bff:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c02:	e8 32 c8 ff ff       	call   80104439 <cpuid>
80107c07:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107c0d:	05 20 48 11 80       	add    $0x80114820,%eax
80107c12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c18:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c21:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c31:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c35:	83 e2 f0             	and    $0xfffffff0,%edx
80107c38:	83 ca 0a             	or     $0xa,%edx
80107c3b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c45:	83 ca 10             	or     $0x10,%edx
80107c48:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c52:	83 e2 9f             	and    $0xffffff9f,%edx
80107c55:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c5f:	83 ca 80             	or     $0xffffff80,%edx
80107c62:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c68:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c6c:	83 ca 0f             	or     $0xf,%edx
80107c6f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c79:	83 e2 ef             	and    $0xffffffef,%edx
80107c7c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c86:	83 e2 df             	and    $0xffffffdf,%edx
80107c89:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c93:	83 ca 40             	or     $0x40,%edx
80107c96:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca0:	83 ca 80             	or     $0xffffff80,%edx
80107ca3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cb7:	ff ff 
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cc3:	00 00 
80107cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cd9:	83 e2 f0             	and    $0xfffffff0,%edx
80107cdc:	83 ca 02             	or     $0x2,%edx
80107cdf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cef:	83 ca 10             	or     $0x10,%edx
80107cf2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d02:	83 e2 9f             	and    $0xffffff9f,%edx
80107d05:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d15:	83 ca 80             	or     $0xffffff80,%edx
80107d18:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d28:	83 ca 0f             	or     $0xf,%edx
80107d2b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d34:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d3b:	83 e2 ef             	and    $0xffffffef,%edx
80107d3e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d47:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d4e:	83 e2 df             	and    $0xffffffdf,%edx
80107d51:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d61:	83 ca 40             	or     $0x40,%edx
80107d64:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d74:	83 ca 80             	or     $0xffffff80,%edx
80107d77:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8a:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107d91:	ff ff 
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107d9d:	00 00 
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dac:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107db3:	83 e2 f0             	and    $0xfffffff0,%edx
80107db6:	83 ca 0a             	or     $0xa,%edx
80107db9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dc9:	83 ca 10             	or     $0x10,%edx
80107dcc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ddc:	83 ca 60             	or     $0x60,%edx
80107ddf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107def:	83 ca 80             	or     $0xffffff80,%edx
80107df2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e02:	83 ca 0f             	or     $0xf,%edx
80107e05:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e15:	83 e2 ef             	and    $0xffffffef,%edx
80107e18:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e21:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e28:	83 e2 df             	and    $0xffffffdf,%edx
80107e2b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e3b:	83 ca 40             	or     $0x40,%edx
80107e3e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e47:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e4e:	83 ca 80             	or     $0xffffff80,%edx
80107e51:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e6b:	ff ff 
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e77:	00 00 
80107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e86:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e8d:	83 e2 f0             	and    $0xfffffff0,%edx
80107e90:	83 ca 02             	or     $0x2,%edx
80107e93:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ea3:	83 ca 10             	or     $0x10,%edx
80107ea6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eb6:	83 ca 60             	or     $0x60,%edx
80107eb9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ec9:	83 ca 80             	or     $0xffffff80,%edx
80107ecc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107edc:	83 ca 0f             	or     $0xf,%edx
80107edf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107eef:	83 e2 ef             	and    $0xffffffef,%edx
80107ef2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f02:	83 e2 df             	and    $0xffffffdf,%edx
80107f05:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f15:	83 ca 40             	or     $0x40,%edx
80107f18:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f28:	83 ca 80             	or     $0xffffff80,%edx
80107f2b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3e:	83 c0 70             	add    $0x70,%eax
80107f41:	83 ec 08             	sub    $0x8,%esp
80107f44:	6a 30                	push   $0x30
80107f46:	50                   	push   %eax
80107f47:	e8 5f fc ff ff       	call   80107bab <lgdt>
80107f4c:	83 c4 10             	add    $0x10,%esp
}
80107f4f:	90                   	nop
80107f50:	c9                   	leave  
80107f51:	c3                   	ret    

80107f52 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f52:	f3 0f 1e fb          	endbr32 
80107f56:	55                   	push   %ebp
80107f57:	89 e5                	mov    %esp,%ebp
80107f59:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f5f:	c1 e8 16             	shr    $0x16,%eax
80107f62:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f69:	8b 45 08             	mov    0x8(%ebp),%eax
80107f6c:	01 d0                	add    %edx,%eax
80107f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f74:	8b 00                	mov    (%eax),%eax
80107f76:	83 e0 01             	and    $0x1,%eax
80107f79:	85 c0                	test   %eax,%eax
80107f7b:	74 14                	je     80107f91 <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f80:	8b 00                	mov    (%eax),%eax
80107f82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f87:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f8f:	eb 42                	jmp    80107fd3 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f95:	74 0e                	je     80107fa5 <walkpgdir+0x53>
80107f97:	e8 74 ae ff ff       	call   80102e10 <kalloc>
80107f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fa3:	75 07                	jne    80107fac <walkpgdir+0x5a>
      return 0;
80107fa5:	b8 00 00 00 00       	mov    $0x0,%eax
80107faa:	eb 3e                	jmp    80107fea <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fac:	83 ec 04             	sub    $0x4,%esp
80107faf:	68 00 10 00 00       	push   $0x1000
80107fb4:	6a 00                	push   $0x0
80107fb6:	ff 75 f4             	pushl  -0xc(%ebp)
80107fb9:	e8 a4 d5 ff ff       	call   80105562 <memset>
80107fbe:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc4:	05 00 00 00 80       	add    $0x80000000,%eax
80107fc9:	83 c8 07             	or     $0x7,%eax
80107fcc:	89 c2                	mov    %eax,%edx
80107fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd6:	c1 e8 0c             	shr    $0xc,%eax
80107fd9:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe8:	01 d0                	add    %edx,%eax
}
80107fea:	c9                   	leave  
80107feb:	c3                   	ret    

80107fec <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fec:	f3 0f 1e fb          	endbr32 
80107ff0:	55                   	push   %ebp
80107ff1:	89 e5                	mov    %esp,%ebp
80107ff3:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108001:	8b 55 0c             	mov    0xc(%ebp),%edx
80108004:	8b 45 10             	mov    0x10(%ebp),%eax
80108007:	01 d0                	add    %edx,%eax
80108009:	83 e8 01             	sub    $0x1,%eax
8010800c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108011:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108014:	83 ec 04             	sub    $0x4,%esp
80108017:	6a 01                	push   $0x1
80108019:	ff 75 f4             	pushl  -0xc(%ebp)
8010801c:	ff 75 08             	pushl  0x8(%ebp)
8010801f:	e8 2e ff ff ff       	call   80107f52 <walkpgdir>
80108024:	83 c4 10             	add    $0x10,%esp
80108027:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010802a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010802e:	75 07                	jne    80108037 <mappages+0x4b>
      return -1;
80108030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108035:	eb 6a                	jmp    801080a1 <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108037:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010803a:	8b 00                	mov    (%eax),%eax
8010803c:	25 01 04 00 00       	and    $0x401,%eax
80108041:	85 c0                	test   %eax,%eax
80108043:	74 0d                	je     80108052 <mappages+0x66>
      panic("p4Debug, remapping page");
80108045:	83 ec 0c             	sub    $0xc,%esp
80108048:	68 04 9a 10 80       	push   $0x80109a04
8010804d:	e8 b6 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
80108052:	8b 45 18             	mov    0x18(%ebp),%eax
80108055:	25 00 04 00 00       	and    $0x400,%eax
8010805a:	85 c0                	test   %eax,%eax
8010805c:	74 12                	je     80108070 <mappages+0x84>
      *pte = pa | perm | PTE_E;
8010805e:	8b 45 18             	mov    0x18(%ebp),%eax
80108061:	0b 45 14             	or     0x14(%ebp),%eax
80108064:	80 cc 04             	or     $0x4,%ah
80108067:	89 c2                	mov    %eax,%edx
80108069:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806c:	89 10                	mov    %edx,(%eax)
8010806e:	eb 10                	jmp    80108080 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
80108070:	8b 45 18             	mov    0x18(%ebp),%eax
80108073:	0b 45 14             	or     0x14(%ebp),%eax
80108076:	83 c8 01             	or     $0x1,%eax
80108079:	89 c2                	mov    %eax,%edx
8010807b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807e:	89 10                	mov    %edx,(%eax)


    if(a == last)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108086:	74 13                	je     8010809b <mappages+0xaf>
      break;
    a += PGSIZE;
80108088:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010808f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108096:	e9 79 ff ff ff       	jmp    80108014 <mappages+0x28>
      break;
8010809b:	90                   	nop
  }
  return 0;
8010809c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080a1:	c9                   	leave  
801080a2:	c3                   	ret    

801080a3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080a3:	f3 0f 1e fb          	endbr32 
801080a7:	55                   	push   %ebp
801080a8:	89 e5                	mov    %esp,%ebp
801080aa:	53                   	push   %ebx
801080ab:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080ae:	e8 5d ad ff ff       	call   80102e10 <kalloc>
801080b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080ba:	75 07                	jne    801080c3 <setupkvm+0x20>
    return 0;
801080bc:	b8 00 00 00 00       	mov    $0x0,%eax
801080c1:	eb 78                	jmp    8010813b <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080c3:	83 ec 04             	sub    $0x4,%esp
801080c6:	68 00 10 00 00       	push   $0x1000
801080cb:	6a 00                	push   $0x0
801080cd:	ff 75 f0             	pushl  -0x10(%ebp)
801080d0:	e8 8d d4 ff ff       	call   80105562 <memset>
801080d5:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080d8:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801080df:	eb 4e                	jmp    8010812f <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e4:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801080e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ea:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f0:	8b 58 08             	mov    0x8(%eax),%ebx
801080f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f6:	8b 40 04             	mov    0x4(%eax),%eax
801080f9:	29 c3                	sub    %eax,%ebx
801080fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fe:	8b 00                	mov    (%eax),%eax
80108100:	83 ec 0c             	sub    $0xc,%esp
80108103:	51                   	push   %ecx
80108104:	52                   	push   %edx
80108105:	53                   	push   %ebx
80108106:	50                   	push   %eax
80108107:	ff 75 f0             	pushl  -0x10(%ebp)
8010810a:	e8 dd fe ff ff       	call   80107fec <mappages>
8010810f:	83 c4 20             	add    $0x20,%esp
80108112:	85 c0                	test   %eax,%eax
80108114:	79 15                	jns    8010812b <setupkvm+0x88>
      freevm(pgdir);
80108116:	83 ec 0c             	sub    $0xc,%esp
80108119:	ff 75 f0             	pushl  -0x10(%ebp)
8010811c:	e8 13 05 00 00       	call   80108634 <freevm>
80108121:	83 c4 10             	add    $0x10,%esp
      return 0;
80108124:	b8 00 00 00 00       	mov    $0x0,%eax
80108129:	eb 10                	jmp    8010813b <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010812b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010812f:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108136:	72 a9                	jb     801080e1 <setupkvm+0x3e>
    }
  return pgdir;
80108138:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010813b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010813e:	c9                   	leave  
8010813f:	c3                   	ret    

80108140 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108140:	f3 0f 1e fb          	endbr32 
80108144:	55                   	push   %ebp
80108145:	89 e5                	mov    %esp,%ebp
80108147:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010814a:	e8 54 ff ff ff       	call   801080a3 <setupkvm>
8010814f:	a3 44 86 11 80       	mov    %eax,0x80118644
  switchkvm();
80108154:	e8 03 00 00 00       	call   8010815c <switchkvm>
}
80108159:	90                   	nop
8010815a:	c9                   	leave  
8010815b:	c3                   	ret    

8010815c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010815c:	f3 0f 1e fb          	endbr32 
80108160:	55                   	push   %ebp
80108161:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108163:	a1 44 86 11 80       	mov    0x80118644,%eax
80108168:	05 00 00 00 80       	add    $0x80000000,%eax
8010816d:	50                   	push   %eax
8010816e:	e8 79 fa ff ff       	call   80107bec <lcr3>
80108173:	83 c4 04             	add    $0x4,%esp
}
80108176:	90                   	nop
80108177:	c9                   	leave  
80108178:	c3                   	ret    

80108179 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108179:	f3 0f 1e fb          	endbr32 
8010817d:	55                   	push   %ebp
8010817e:	89 e5                	mov    %esp,%ebp
80108180:	56                   	push   %esi
80108181:	53                   	push   %ebx
80108182:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108185:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108189:	75 0d                	jne    80108198 <switchuvm+0x1f>
    panic("switchuvm: no process");
8010818b:	83 ec 0c             	sub    $0xc,%esp
8010818e:	68 1c 9a 10 80       	push   $0x80109a1c
80108193:	e8 70 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108198:	8b 45 08             	mov    0x8(%ebp),%eax
8010819b:	8b 40 08             	mov    0x8(%eax),%eax
8010819e:	85 c0                	test   %eax,%eax
801081a0:	75 0d                	jne    801081af <switchuvm+0x36>
    panic("switchuvm: no kstack");
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	68 32 9a 10 80       	push   $0x80109a32
801081aa:	e8 59 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801081af:	8b 45 08             	mov    0x8(%ebp),%eax
801081b2:	8b 40 04             	mov    0x4(%eax),%eax
801081b5:	85 c0                	test   %eax,%eax
801081b7:	75 0d                	jne    801081c6 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801081b9:	83 ec 0c             	sub    $0xc,%esp
801081bc:	68 47 9a 10 80       	push   $0x80109a47
801081c1:	e8 42 84 ff ff       	call   80100608 <panic>

  pushcli();
801081c6:	e8 84 d2 ff ff       	call   8010544f <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081cb:	e8 88 c2 ff ff       	call   80104458 <mycpu>
801081d0:	89 c3                	mov    %eax,%ebx
801081d2:	e8 81 c2 ff ff       	call   80104458 <mycpu>
801081d7:	83 c0 08             	add    $0x8,%eax
801081da:	89 c6                	mov    %eax,%esi
801081dc:	e8 77 c2 ff ff       	call   80104458 <mycpu>
801081e1:	83 c0 08             	add    $0x8,%eax
801081e4:	c1 e8 10             	shr    $0x10,%eax
801081e7:	88 45 f7             	mov    %al,-0x9(%ebp)
801081ea:	e8 69 c2 ff ff       	call   80104458 <mycpu>
801081ef:	83 c0 08             	add    $0x8,%eax
801081f2:	c1 e8 18             	shr    $0x18,%eax
801081f5:	89 c2                	mov    %eax,%edx
801081f7:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801081fe:	67 00 
80108200:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108207:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010820b:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108211:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108218:	83 e0 f0             	and    $0xfffffff0,%eax
8010821b:	83 c8 09             	or     $0x9,%eax
8010821e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108224:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010822b:	83 c8 10             	or     $0x10,%eax
8010822e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108234:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010823b:	83 e0 9f             	and    $0xffffff9f,%eax
8010823e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108244:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010824b:	83 c8 80             	or     $0xffffff80,%eax
8010824e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108254:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010825b:	83 e0 f0             	and    $0xfffffff0,%eax
8010825e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108264:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010826b:	83 e0 ef             	and    $0xffffffef,%eax
8010826e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108274:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010827b:	83 e0 df             	and    $0xffffffdf,%eax
8010827e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108284:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010828b:	83 c8 40             	or     $0x40,%eax
8010828e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108294:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010829b:	83 e0 7f             	and    $0x7f,%eax
8010829e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082a4:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801082aa:	e8 a9 c1 ff ff       	call   80104458 <mycpu>
801082af:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082b6:	83 e2 ef             	and    $0xffffffef,%edx
801082b9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082bf:	e8 94 c1 ff ff       	call   80104458 <mycpu>
801082c4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082ca:	8b 45 08             	mov    0x8(%ebp),%eax
801082cd:	8b 40 08             	mov    0x8(%eax),%eax
801082d0:	89 c3                	mov    %eax,%ebx
801082d2:	e8 81 c1 ff ff       	call   80104458 <mycpu>
801082d7:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801082dd:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801082e0:	e8 73 c1 ff ff       	call   80104458 <mycpu>
801082e5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801082eb:	83 ec 0c             	sub    $0xc,%esp
801082ee:	6a 28                	push   $0x28
801082f0:	e8 e0 f8 ff ff       	call   80107bd5 <ltr>
801082f5:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801082f8:	8b 45 08             	mov    0x8(%ebp),%eax
801082fb:	8b 40 04             	mov    0x4(%eax),%eax
801082fe:	05 00 00 00 80       	add    $0x80000000,%eax
80108303:	83 ec 0c             	sub    $0xc,%esp
80108306:	50                   	push   %eax
80108307:	e8 e0 f8 ff ff       	call   80107bec <lcr3>
8010830c:	83 c4 10             	add    $0x10,%esp
  popcli();
8010830f:	e8 8c d1 ff ff       	call   801054a0 <popcli>
}
80108314:	90                   	nop
80108315:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108318:	5b                   	pop    %ebx
80108319:	5e                   	pop    %esi
8010831a:	5d                   	pop    %ebp
8010831b:	c3                   	ret    

8010831c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010831c:	f3 0f 1e fb          	endbr32 
80108320:	55                   	push   %ebp
80108321:	89 e5                	mov    %esp,%ebp
80108323:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108326:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010832d:	76 0d                	jbe    8010833c <inituvm+0x20>
    panic("inituvm: more than a page");
8010832f:	83 ec 0c             	sub    $0xc,%esp
80108332:	68 5b 9a 10 80       	push   $0x80109a5b
80108337:	e8 cc 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
8010833c:	e8 cf aa ff ff       	call   80102e10 <kalloc>
80108341:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108344:	83 ec 04             	sub    $0x4,%esp
80108347:	68 00 10 00 00       	push   $0x1000
8010834c:	6a 00                	push   $0x0
8010834e:	ff 75 f4             	pushl  -0xc(%ebp)
80108351:	e8 0c d2 ff ff       	call   80105562 <memset>
80108356:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835c:	05 00 00 00 80       	add    $0x80000000,%eax
80108361:	83 ec 0c             	sub    $0xc,%esp
80108364:	6a 06                	push   $0x6
80108366:	50                   	push   %eax
80108367:	68 00 10 00 00       	push   $0x1000
8010836c:	6a 00                	push   $0x0
8010836e:	ff 75 08             	pushl  0x8(%ebp)
80108371:	e8 76 fc ff ff       	call   80107fec <mappages>
80108376:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108379:	83 ec 04             	sub    $0x4,%esp
8010837c:	ff 75 10             	pushl  0x10(%ebp)
8010837f:	ff 75 0c             	pushl  0xc(%ebp)
80108382:	ff 75 f4             	pushl  -0xc(%ebp)
80108385:	e8 9f d2 ff ff       	call   80105629 <memmove>
8010838a:	83 c4 10             	add    $0x10,%esp
}
8010838d:	90                   	nop
8010838e:	c9                   	leave  
8010838f:	c3                   	ret    

80108390 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108390:	f3 0f 1e fb          	endbr32 
80108394:	55                   	push   %ebp
80108395:	89 e5                	mov    %esp,%ebp
80108397:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010839a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839d:	25 ff 0f 00 00       	and    $0xfff,%eax
801083a2:	85 c0                	test   %eax,%eax
801083a4:	74 0d                	je     801083b3 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801083a6:	83 ec 0c             	sub    $0xc,%esp
801083a9:	68 78 9a 10 80       	push   $0x80109a78
801083ae:	e8 55 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ba:	e9 8f 00 00 00       	jmp    8010844e <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801083c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c5:	01 d0                	add    %edx,%eax
801083c7:	83 ec 04             	sub    $0x4,%esp
801083ca:	6a 00                	push   $0x0
801083cc:	50                   	push   %eax
801083cd:	ff 75 08             	pushl  0x8(%ebp)
801083d0:	e8 7d fb ff ff       	call   80107f52 <walkpgdir>
801083d5:	83 c4 10             	add    $0x10,%esp
801083d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083df:	75 0d                	jne    801083ee <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801083e1:	83 ec 0c             	sub    $0xc,%esp
801083e4:	68 9b 9a 10 80       	push   $0x80109a9b
801083e9:	e8 1a 82 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801083ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f1:	8b 00                	mov    (%eax),%eax
801083f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083fb:	8b 45 18             	mov    0x18(%ebp),%eax
801083fe:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108401:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108406:	77 0b                	ja     80108413 <loaduvm+0x83>
      n = sz - i;
80108408:	8b 45 18             	mov    0x18(%ebp),%eax
8010840b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010840e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108411:	eb 07                	jmp    8010841a <loaduvm+0x8a>
    else
      n = PGSIZE;
80108413:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010841a:	8b 55 14             	mov    0x14(%ebp),%edx
8010841d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108420:	01 d0                	add    %edx,%eax
80108422:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108425:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010842b:	ff 75 f0             	pushl  -0x10(%ebp)
8010842e:	50                   	push   %eax
8010842f:	52                   	push   %edx
80108430:	ff 75 10             	pushl  0x10(%ebp)
80108433:	e8 f0 9b ff ff       	call   80102028 <readi>
80108438:	83 c4 10             	add    $0x10,%esp
8010843b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010843e:	74 07                	je     80108447 <loaduvm+0xb7>
      return -1;
80108440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108445:	eb 18                	jmp    8010845f <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108447:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	3b 45 18             	cmp    0x18(%ebp),%eax
80108454:	0f 82 65 ff ff ff    	jb     801083bf <loaduvm+0x2f>
  }
  return 0;
8010845a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010845f:	c9                   	leave  
80108460:	c3                   	ret    

80108461 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108461:	f3 0f 1e fb          	endbr32 
80108465:	55                   	push   %ebp
80108466:	89 e5                	mov    %esp,%ebp
80108468:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010846b:	8b 45 10             	mov    0x10(%ebp),%eax
8010846e:	85 c0                	test   %eax,%eax
80108470:	79 0a                	jns    8010847c <allocuvm+0x1b>
    return 0;
80108472:	b8 00 00 00 00       	mov    $0x0,%eax
80108477:	e9 ec 00 00 00       	jmp    80108568 <allocuvm+0x107>
  if(newsz < oldsz)
8010847c:	8b 45 10             	mov    0x10(%ebp),%eax
8010847f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108482:	73 08                	jae    8010848c <allocuvm+0x2b>
    return oldsz;
80108484:	8b 45 0c             	mov    0xc(%ebp),%eax
80108487:	e9 dc 00 00 00       	jmp    80108568 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010848c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010848f:	05 ff 0f 00 00       	add    $0xfff,%eax
80108494:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108499:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010849c:	e9 b8 00 00 00       	jmp    80108559 <allocuvm+0xf8>
    mem = kalloc();
801084a1:	e8 6a a9 ff ff       	call   80102e10 <kalloc>
801084a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084ad:	75 2e                	jne    801084dd <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801084af:	83 ec 0c             	sub    $0xc,%esp
801084b2:	68 b9 9a 10 80       	push   $0x80109ab9
801084b7:	e8 5c 7f ff ff       	call   80100418 <cprintf>
801084bc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084bf:	83 ec 04             	sub    $0x4,%esp
801084c2:	ff 75 0c             	pushl  0xc(%ebp)
801084c5:	ff 75 10             	pushl  0x10(%ebp)
801084c8:	ff 75 08             	pushl  0x8(%ebp)
801084cb:	e8 9a 00 00 00       	call   8010856a <deallocuvm>
801084d0:	83 c4 10             	add    $0x10,%esp
      return 0;
801084d3:	b8 00 00 00 00       	mov    $0x0,%eax
801084d8:	e9 8b 00 00 00       	jmp    80108568 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801084dd:	83 ec 04             	sub    $0x4,%esp
801084e0:	68 00 10 00 00       	push   $0x1000
801084e5:	6a 00                	push   $0x0
801084e7:	ff 75 f0             	pushl  -0x10(%ebp)
801084ea:	e8 73 d0 ff ff       	call   80105562 <memset>
801084ef:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801084f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	83 ec 0c             	sub    $0xc,%esp
80108501:	6a 06                	push   $0x6
80108503:	52                   	push   %edx
80108504:	68 00 10 00 00       	push   $0x1000
80108509:	50                   	push   %eax
8010850a:	ff 75 08             	pushl  0x8(%ebp)
8010850d:	e8 da fa ff ff       	call   80107fec <mappages>
80108512:	83 c4 20             	add    $0x20,%esp
80108515:	85 c0                	test   %eax,%eax
80108517:	79 39                	jns    80108552 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108519:	83 ec 0c             	sub    $0xc,%esp
8010851c:	68 d1 9a 10 80       	push   $0x80109ad1
80108521:	e8 f2 7e ff ff       	call   80100418 <cprintf>
80108526:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108529:	83 ec 04             	sub    $0x4,%esp
8010852c:	ff 75 0c             	pushl  0xc(%ebp)
8010852f:	ff 75 10             	pushl  0x10(%ebp)
80108532:	ff 75 08             	pushl  0x8(%ebp)
80108535:	e8 30 00 00 00       	call   8010856a <deallocuvm>
8010853a:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010853d:	83 ec 0c             	sub    $0xc,%esp
80108540:	ff 75 f0             	pushl  -0x10(%ebp)
80108543:	e8 2a a8 ff ff       	call   80102d72 <kfree>
80108548:	83 c4 10             	add    $0x10,%esp
      return 0;
8010854b:	b8 00 00 00 00       	mov    $0x0,%eax
80108550:	eb 16                	jmp    80108568 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108552:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010855f:	0f 82 3c ff ff ff    	jb     801084a1 <allocuvm+0x40>
    }
  }
  return newsz;
80108565:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108568:	c9                   	leave  
80108569:	c3                   	ret    

8010856a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010856a:	f3 0f 1e fb          	endbr32 
8010856e:	55                   	push   %ebp
8010856f:	89 e5                	mov    %esp,%ebp
80108571:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108574:	8b 45 10             	mov    0x10(%ebp),%eax
80108577:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010857a:	72 08                	jb     80108584 <deallocuvm+0x1a>
    return oldsz;
8010857c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010857f:	e9 ae 00 00 00       	jmp    80108632 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
80108584:	8b 45 10             	mov    0x10(%ebp),%eax
80108587:	05 ff 0f 00 00       	add    $0xfff,%eax
8010858c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108591:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108594:	e9 8a 00 00 00       	jmp    80108623 <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859c:	83 ec 04             	sub    $0x4,%esp
8010859f:	6a 00                	push   $0x0
801085a1:	50                   	push   %eax
801085a2:	ff 75 08             	pushl  0x8(%ebp)
801085a5:	e8 a8 f9 ff ff       	call   80107f52 <walkpgdir>
801085aa:	83 c4 10             	add    $0x10,%esp
801085ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085b4:	75 16                	jne    801085cc <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b9:	c1 e8 16             	shr    $0x16,%eax
801085bc:	83 c0 01             	add    $0x1,%eax
801085bf:	c1 e0 16             	shl    $0x16,%eax
801085c2:	2d 00 10 00 00       	sub    $0x1000,%eax
801085c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085ca:	eb 50                	jmp    8010861c <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801085cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085cf:	8b 00                	mov    (%eax),%eax
801085d1:	25 01 04 00 00       	and    $0x401,%eax
801085d6:	85 c0                	test   %eax,%eax
801085d8:	74 42                	je     8010861c <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801085da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085dd:	8b 00                	mov    (%eax),%eax
801085df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085eb:	75 0d                	jne    801085fa <deallocuvm+0x90>
        panic("kfree");
801085ed:	83 ec 0c             	sub    $0xc,%esp
801085f0:	68 ed 9a 10 80       	push   $0x80109aed
801085f5:	e8 0e 80 ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801085fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085fd:	05 00 00 00 80       	add    $0x80000000,%eax
80108602:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108605:	83 ec 0c             	sub    $0xc,%esp
80108608:	ff 75 e8             	pushl  -0x18(%ebp)
8010860b:	e8 62 a7 ff ff       	call   80102d72 <kfree>
80108610:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108616:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010861c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108626:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108629:	0f 82 6a ff ff ff    	jb     80108599 <deallocuvm+0x2f>
    }
  }
  return newsz;
8010862f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108632:	c9                   	leave  
80108633:	c3                   	ret    

80108634 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108634:	f3 0f 1e fb          	endbr32 
80108638:	55                   	push   %ebp
80108639:	89 e5                	mov    %esp,%ebp
8010863b:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010863e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108642:	75 0d                	jne    80108651 <freevm+0x1d>
    panic("freevm: no pgdir");
80108644:	83 ec 0c             	sub    $0xc,%esp
80108647:	68 f3 9a 10 80       	push   $0x80109af3
8010864c:	e8 b7 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108651:	83 ec 04             	sub    $0x4,%esp
80108654:	6a 00                	push   $0x0
80108656:	68 00 00 00 80       	push   $0x80000000
8010865b:	ff 75 08             	pushl  0x8(%ebp)
8010865e:	e8 07 ff ff ff       	call   8010856a <deallocuvm>
80108663:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108666:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010866d:	eb 4a                	jmp    801086b9 <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
8010866f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108672:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108679:	8b 45 08             	mov    0x8(%ebp),%eax
8010867c:	01 d0                	add    %edx,%eax
8010867e:	8b 00                	mov    (%eax),%eax
80108680:	25 01 04 00 00       	and    $0x401,%eax
80108685:	85 c0                	test   %eax,%eax
80108687:	74 2c                	je     801086b5 <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108693:	8b 45 08             	mov    0x8(%ebp),%eax
80108696:	01 d0                	add    %edx,%eax
80108698:	8b 00                	mov    (%eax),%eax
8010869a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010869f:	05 00 00 00 80       	add    $0x80000000,%eax
801086a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086a7:	83 ec 0c             	sub    $0xc,%esp
801086aa:	ff 75 f0             	pushl  -0x10(%ebp)
801086ad:	e8 c0 a6 ff ff       	call   80102d72 <kfree>
801086b2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086b9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086c0:	76 ad                	jbe    8010866f <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801086c2:	83 ec 0c             	sub    $0xc,%esp
801086c5:	ff 75 08             	pushl  0x8(%ebp)
801086c8:	e8 a5 a6 ff ff       	call   80102d72 <kfree>
801086cd:	83 c4 10             	add    $0x10,%esp
}
801086d0:	90                   	nop
801086d1:	c9                   	leave  
801086d2:	c3                   	ret    

801086d3 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086d3:	f3 0f 1e fb          	endbr32 
801086d7:	55                   	push   %ebp
801086d8:	89 e5                	mov    %esp,%ebp
801086da:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086dd:	83 ec 04             	sub    $0x4,%esp
801086e0:	6a 00                	push   $0x0
801086e2:	ff 75 0c             	pushl  0xc(%ebp)
801086e5:	ff 75 08             	pushl  0x8(%ebp)
801086e8:	e8 65 f8 ff ff       	call   80107f52 <walkpgdir>
801086ed:	83 c4 10             	add    $0x10,%esp
801086f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086f7:	75 0d                	jne    80108706 <clearpteu+0x33>
    panic("clearpteu");
801086f9:	83 ec 0c             	sub    $0xc,%esp
801086fc:	68 04 9b 10 80       	push   $0x80109b04
80108701:	e8 02 7f ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108709:	8b 00                	mov    (%eax),%eax
8010870b:	83 e0 fb             	and    $0xfffffffb,%eax
8010870e:	89 c2                	mov    %eax,%edx
80108710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108713:	89 10                	mov    %edx,(%eax)
}
80108715:	90                   	nop
80108716:	c9                   	leave  
80108717:	c3                   	ret    

80108718 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108718:	f3 0f 1e fb          	endbr32 
8010871c:	55                   	push   %ebp
8010871d:	89 e5                	mov    %esp,%ebp
8010871f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108722:	e8 7c f9 ff ff       	call   801080a3 <setupkvm>
80108727:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010872a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010872e:	75 0a                	jne    8010873a <copyuvm+0x22>
    return 0;
80108730:	b8 00 00 00 00       	mov    $0x0,%eax
80108735:	e9 fa 00 00 00       	jmp    80108834 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010873a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108741:	e9 c9 00 00 00       	jmp    8010880f <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108749:	83 ec 04             	sub    $0x4,%esp
8010874c:	6a 00                	push   $0x0
8010874e:	50                   	push   %eax
8010874f:	ff 75 08             	pushl  0x8(%ebp)
80108752:	e8 fb f7 ff ff       	call   80107f52 <walkpgdir>
80108757:	83 c4 10             	add    $0x10,%esp
8010875a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010875d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108761:	75 0d                	jne    80108770 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
80108763:	83 ec 0c             	sub    $0xc,%esp
80108766:	68 10 9b 10 80       	push   $0x80109b10
8010876b:	e8 98 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108770:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108773:	8b 00                	mov    (%eax),%eax
80108775:	25 01 04 00 00       	and    $0x401,%eax
8010877a:	85 c0                	test   %eax,%eax
8010877c:	75 0d                	jne    8010878b <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
8010877e:	83 ec 0c             	sub    $0xc,%esp
80108781:	68 3c 9b 10 80       	push   $0x80109b3c
80108786:	e8 7d 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
8010878b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878e:	8b 00                	mov    (%eax),%eax
80108790:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108795:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108798:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879b:	8b 00                	mov    (%eax),%eax
8010879d:	25 ff 0f 00 00       	and    $0xfff,%eax
801087a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087a5:	e8 66 a6 ff ff       	call   80102e10 <kalloc>
801087aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087b1:	74 6d                	je     80108820 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087b6:	05 00 00 00 80       	add    $0x80000000,%eax
801087bb:	83 ec 04             	sub    $0x4,%esp
801087be:	68 00 10 00 00       	push   $0x1000
801087c3:	50                   	push   %eax
801087c4:	ff 75 e0             	pushl  -0x20(%ebp)
801087c7:	e8 5d ce ff ff       	call   80105629 <memmove>
801087cc:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801087cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087de:	83 ec 0c             	sub    $0xc,%esp
801087e1:	52                   	push   %edx
801087e2:	51                   	push   %ecx
801087e3:	68 00 10 00 00       	push   $0x1000
801087e8:	50                   	push   %eax
801087e9:	ff 75 f0             	pushl  -0x10(%ebp)
801087ec:	e8 fb f7 ff ff       	call   80107fec <mappages>
801087f1:	83 c4 20             	add    $0x20,%esp
801087f4:	85 c0                	test   %eax,%eax
801087f6:	79 10                	jns    80108808 <copyuvm+0xf0>
      kfree(mem);
801087f8:	83 ec 0c             	sub    $0xc,%esp
801087fb:	ff 75 e0             	pushl  -0x20(%ebp)
801087fe:	e8 6f a5 ff ff       	call   80102d72 <kfree>
80108803:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108806:	eb 19                	jmp    80108821 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108808:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010880f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108812:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108815:	0f 82 2b ff ff ff    	jb     80108746 <copyuvm+0x2e>
    }
  }
  return d;
8010881b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010881e:	eb 14                	jmp    80108834 <copyuvm+0x11c>
      goto bad;
80108820:	90                   	nop

bad:
  freevm(d);
80108821:	83 ec 0c             	sub    $0xc,%esp
80108824:	ff 75 f0             	pushl  -0x10(%ebp)
80108827:	e8 08 fe ff ff       	call   80108634 <freevm>
8010882c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010882f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108834:	c9                   	leave  
80108835:	c3                   	ret    

80108836 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108836:	f3 0f 1e fb          	endbr32 
8010883a:	55                   	push   %ebp
8010883b:	89 e5                	mov    %esp,%ebp
8010883d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108840:	83 ec 04             	sub    $0x4,%esp
80108843:	6a 00                	push   $0x0
80108845:	ff 75 0c             	pushl  0xc(%ebp)
80108848:	ff 75 08             	pushl  0x8(%ebp)
8010884b:	e8 02 f7 ff ff       	call   80107f52 <walkpgdir>
80108850:	83 c4 10             	add    $0x10,%esp
80108853:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108859:	8b 00                	mov    (%eax),%eax
8010885b:	25 01 04 00 00       	and    $0x401,%eax
80108860:	85 c0                	test   %eax,%eax
80108862:	75 07                	jne    8010886b <uva2ka+0x35>
    return 0;
80108864:	b8 00 00 00 00       	mov    $0x0,%eax
80108869:	eb 22                	jmp    8010888d <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	8b 00                	mov    (%eax),%eax
80108870:	83 e0 04             	and    $0x4,%eax
80108873:	85 c0                	test   %eax,%eax
80108875:	75 07                	jne    8010887e <uva2ka+0x48>
    return 0;
80108877:	b8 00 00 00 00       	mov    $0x0,%eax
8010887c:	eb 0f                	jmp    8010888d <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
8010887e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108881:	8b 00                	mov    (%eax),%eax
80108883:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108888:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010888d:	c9                   	leave  
8010888e:	c3                   	ret    

8010888f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010888f:	f3 0f 1e fb          	endbr32 
80108893:	55                   	push   %ebp
80108894:	89 e5                	mov    %esp,%ebp
80108896:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108899:	8b 45 10             	mov    0x10(%ebp),%eax
8010889c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010889f:	eb 7f                	jmp    80108920 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801088a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088af:	83 ec 08             	sub    $0x8,%esp
801088b2:	50                   	push   %eax
801088b3:	ff 75 08             	pushl  0x8(%ebp)
801088b6:	e8 7b ff ff ff       	call   80108836 <uva2ka>
801088bb:	83 c4 10             	add    $0x10,%esp
801088be:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088c5:	75 07                	jne    801088ce <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801088c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088cc:	eb 61                	jmp    8010892f <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801088ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d1:	2b 45 0c             	sub    0xc(%ebp),%eax
801088d4:	05 00 10 00 00       	add    $0x1000,%eax
801088d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088df:	3b 45 14             	cmp    0x14(%ebp),%eax
801088e2:	76 06                	jbe    801088ea <copyout+0x5b>
      n = len;
801088e4:	8b 45 14             	mov    0x14(%ebp),%eax
801088e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801088ed:	2b 45 ec             	sub    -0x14(%ebp),%eax
801088f0:	89 c2                	mov    %eax,%edx
801088f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088f5:	01 d0                	add    %edx,%eax
801088f7:	83 ec 04             	sub    $0x4,%esp
801088fa:	ff 75 f0             	pushl  -0x10(%ebp)
801088fd:	ff 75 f4             	pushl  -0xc(%ebp)
80108900:	50                   	push   %eax
80108901:	e8 23 cd ff ff       	call   80105629 <memmove>
80108906:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010890f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108912:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108915:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108918:	05 00 10 00 00       	add    $0x1000,%eax
8010891d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108920:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108924:	0f 85 77 ff ff ff    	jne    801088a1 <copyout+0x12>
  }
  return 0;
8010892a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010892f:	c9                   	leave  
80108930:	c3                   	ret    

80108931 <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108931:	f3 0f 1e fb          	endbr32 
80108935:	55                   	push   %ebp
80108936:	89 e5                	mov    %esp,%ebp
80108938:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
8010893b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010893e:	c1 e8 0c             	shr    $0xc,%eax
80108941:	83 ec 04             	sub    $0x4,%esp
80108944:	50                   	push   %eax
80108945:	ff 75 0c             	pushl  0xc(%ebp)
80108948:	68 68 9b 10 80       	push   $0x80109b68
8010894d:	e8 c6 7a ff ff       	call   80100418 <cprintf>
80108952:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108955:	83 ec 04             	sub    $0x4,%esp
80108958:	6a 00                	push   $0x0
8010895a:	ff 75 0c             	pushl  0xc(%ebp)
8010895d:	ff 75 08             	pushl  0x8(%ebp)
80108960:	e8 ed f5 ff ff       	call   80107f52 <walkpgdir>
80108965:	83 c4 10             	add    $0x10,%esp
80108968:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896e:	8b 00                	mov    (%eax),%eax
80108970:	83 e0 01             	and    $0x1,%eax
80108973:	85 c0                	test   %eax,%eax
80108975:	75 18                	jne    8010898f <translate_and_set+0x5e>
80108977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897a:	8b 00                	mov    (%eax),%eax
8010897c:	25 00 04 00 00       	and    $0x400,%eax
80108981:	85 c0                	test   %eax,%eax
80108983:	75 0a                	jne    8010898f <translate_and_set+0x5e>
    return 0;
80108985:	b8 00 00 00 00       	mov    $0x0,%eax
8010898a:	e9 84 00 00 00       	jmp    80108a13 <translate_and_set+0xe2>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
8010898f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108992:	8b 00                	mov    (%eax),%eax
80108994:	25 00 04 00 00       	and    $0x400,%eax
80108999:	85 c0                	test   %eax,%eax
8010899b:	74 07                	je     801089a4 <translate_and_set+0x73>
    return 0;
8010899d:	b8 00 00 00 00       	mov    $0x0,%eax
801089a2:	eb 6f                	jmp    80108a13 <translate_and_set+0xe2>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
801089a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a7:	8b 00                	mov    (%eax),%eax
801089a9:	83 e0 04             	and    $0x4,%eax
801089ac:	85 c0                	test   %eax,%eax
801089ae:	75 07                	jne    801089b7 <translate_and_set+0x86>
    return 0;
801089b0:	b8 00 00 00 00       	mov    $0x0,%eax
801089b5:	eb 5c                	jmp    80108a13 <translate_and_set+0xe2>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
801089b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ba:	8b 00                	mov    (%eax),%eax
801089bc:	83 ec 04             	sub    $0x4,%esp
801089bf:	ff 75 f4             	pushl  -0xc(%ebp)
801089c2:	50                   	push   %eax
801089c3:	68 90 9b 10 80       	push   $0x80109b90
801089c8:	e8 4b 7a ff ff       	call   80100418 <cprintf>
801089cd:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8b 00                	mov    (%eax),%eax
801089d5:	80 cc 04             	or     $0x4,%ah
801089d8:	89 c2                	mov    %eax,%edx
801089da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089dd:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
801089df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e2:	8b 00                	mov    (%eax),%eax
801089e4:	83 e0 fe             	and    $0xfffffffe,%eax
801089e7:	89 c2                	mov    %eax,%edx
801089e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ec:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
801089ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f1:	8b 00                	mov    (%eax),%eax
801089f3:	83 ec 08             	sub    $0x8,%esp
801089f6:	50                   	push   %eax
801089f7:	68 b8 9b 10 80       	push   $0x80109bb8
801089fc:	e8 17 7a ff ff       	call   80100418 <cprintf>
80108a01:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
80108a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a07:	8b 00                	mov    (%eax),%eax
80108a09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a0e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a13:	c9                   	leave  
80108a14:	c3                   	ret    

80108a15 <clk_insert>:

void
clk_insert(uint vpn, pte_t *pte)
{
80108a15:	f3 0f 1e fb          	endbr32 
80108a19:	55                   	push   %ebp
80108a1a:	89 e5                	mov    %esp,%ebp
80108a1c:	83 ec 18             	sub    $0x18,%esp
  struct proc *currProc = myproc();
80108a1f:	e8 b0 ba ff ff       	call   801044d4 <myproc>
80108a24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (;;) {
        currProc->clockIndex = (currProc->clockIndex + 1) % CLOCKSIZE;
80108a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108a30:	8d 50 01             	lea    0x1(%eax),%edx
80108a33:	89 d0                	mov    %edx,%eax
80108a35:	c1 f8 1f             	sar    $0x1f,%eax
80108a38:	c1 e8 1d             	shr    $0x1d,%eax
80108a3b:	01 c2                	add    %eax,%edx
80108a3d:	83 e2 07             	and    $0x7,%edx
80108a40:	29 c2                	sub    %eax,%edx
80108a42:	89 d0                	mov    %edx,%eax
80108a44:	89 c2                	mov    %eax,%edx
80108a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a49:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
        if (currProc->clockQueue[currProc->clockIndex].vpn == -1) {
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5b:	83 c2 0e             	add    $0xe,%edx
80108a5e:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108a62:	83 f8 ff             	cmp    $0xffffffff,%eax
80108a65:	75 31                	jne    80108a98 <clk_insert+0x83>
            currProc->clockQueue[currProc->clockIndex].vpn = vpn;
80108a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6a:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a73:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108a76:	8b 55 08             	mov    0x8(%ebp),%edx
80108a79:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
            currProc->clockQueue[currProc->clockIndex].pte = pte;
80108a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a80:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a89:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a8f:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
            break;
80108a93:	e9 9d 00 00 00       	jmp    80108b35 <clk_insert+0x120>
        } else if (!(*(currProc->clockQueue[currProc->clockIndex].pte) & PTE_A)) {
80108a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a9b:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa4:	83 c2 0e             	add    $0xe,%edx
80108aa7:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80108aab:	8b 00                	mov    (%eax),%eax
80108aad:	83 e0 20             	and    $0x20,%eax
80108ab0:	85 c0                	test   %eax,%eax
80108ab2:	75 4f                	jne    80108b03 <clk_insert+0xee>
            mencrypt((char*)currProc->clockQueue[currProc->clockIndex].vpn, 1);
80108ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab7:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac0:	83 c2 0e             	add    $0xe,%edx
80108ac3:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108ac7:	83 ec 08             	sub    $0x8,%esp
80108aca:	6a 01                	push   $0x1
80108acc:	50                   	push   %eax
80108acd:	e8 a4 02 00 00       	call   80108d76 <mencrypt>
80108ad2:	83 c4 10             	add    $0x10,%esp
            currProc->clockQueue[currProc->clockIndex].vpn = vpn;
80108ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad8:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae1:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108ae4:	8b 55 08             	mov    0x8(%ebp),%edx
80108ae7:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
            currProc->clockQueue[currProc->clockIndex].pte = pte;
80108aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aee:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af7:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108afa:	8b 55 0c             	mov    0xc(%ebp),%edx
80108afd:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
            break;
80108b01:	eb 32                	jmp    80108b35 <clk_insert+0x120>
        } else {
            *(currProc->clockQueue[currProc->clockIndex].pte) &= (~PTE_A);
80108b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b06:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0f:	83 c2 0e             	add    $0xe,%edx
80108b12:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80108b16:	8b 10                	mov    (%eax),%edx
80108b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1b:	8b 88 bc 00 00 00    	mov    0xbc(%eax),%ecx
80108b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b24:	83 c1 0e             	add    $0xe,%ecx
80108b27:	8b 44 c8 10          	mov    0x10(%eax,%ecx,8),%eax
80108b2b:	83 e2 df             	and    $0xffffffdf,%edx
80108b2e:	89 10                	mov    %edx,(%eax)
        currProc->clockIndex = (currProc->clockIndex + 1) % CLOCKSIZE;
80108b30:	e9 f2 fe ff ff       	jmp    80108a27 <clk_insert+0x12>
        }
    }
    mdecrypt((char*)vpn);
80108b35:	8b 45 08             	mov    0x8(%ebp),%eax
80108b38:	83 ec 0c             	sub    $0xc,%esp
80108b3b:	50                   	push   %eax
80108b3c:	e8 56 01 00 00       	call   80108c97 <mdecrypt>
80108b41:	83 c4 10             	add    $0x10,%esp
}
80108b44:	90                   	nop
80108b45:	c9                   	leave  
80108b46:	c3                   	ret    

80108b47 <clk_remove>:

void
clk_remove(uint vpn)
{
80108b47:	f3 0f 1e fb          	endbr32 
80108b4b:	55                   	push   %ebp
80108b4c:	89 e5                	mov    %esp,%ebp
80108b4e:	83 ec 28             	sub    $0x28,%esp
    struct proc *currProc = myproc();
80108b51:	e8 7e b9 ff ff       	call   801044d4 <myproc>
80108b56:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int start = currProc->clockIndex;
80108b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b5c:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108b62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int match = -1;
80108b65:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

    for (int i = 0; i < CLOCKSIZE; ++i) {
80108b6c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b73:	eb 40                	jmp    80108bb5 <clk_remove+0x6e>
        int index = (currProc->clockIndex + i) % CLOCKSIZE;
80108b75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b78:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
80108b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b81:	01 c2                	add    %eax,%edx
80108b83:	89 d0                	mov    %edx,%eax
80108b85:	c1 f8 1f             	sar    $0x1f,%eax
80108b88:	c1 e8 1d             	shr    $0x1d,%eax
80108b8b:	01 c2                	add    %eax,%edx
80108b8d:	83 e2 07             	and    $0x7,%edx
80108b90:	29 c2                	sub    %eax,%edx
80108b92:	89 d0                	mov    %edx,%eax
80108b94:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (currProc->clockQueue[index].vpn == vpn) {
80108b97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b9d:	83 c2 0e             	add    $0xe,%edx
80108ba0:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108ba4:	39 45 08             	cmp    %eax,0x8(%ebp)
80108ba7:	75 08                	jne    80108bb1 <clk_remove+0x6a>
            match = index;
80108ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
80108baf:	eb 0a                	jmp    80108bbb <clk_remove+0x74>
    for (int i = 0; i < CLOCKSIZE; ++i) {
80108bb1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108bb5:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
80108bb9:	7e ba                	jle    80108b75 <clk_remove+0x2e>
        }
    }

    if (match == -1) {
80108bbb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80108bbf:	0f 84 cf 00 00 00    	je     80108c94 <clk_remove+0x14d>
        return;
		} else {
			mencrypt((char*)currProc->clockQueue[match].vpn, 1);
80108bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bcb:	83 c2 0e             	add    $0xe,%edx
80108bce:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108bd2:	83 ec 08             	sub    $0x8,%esp
80108bd5:	6a 01                	push   $0x1
80108bd7:	50                   	push   %eax
80108bd8:	e8 99 01 00 00       	call   80108d76 <mencrypt>
80108bdd:	83 c4 10             	add    $0x10,%esp
		}

    for (int index = match; index != start; index = (index + 1) % CLOCKSIZE) {
80108be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108be6:	eb 68                	jmp    80108c50 <clk_remove+0x109>
        int next_index = (index + 1) % CLOCKSIZE;
80108be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108beb:	8d 50 01             	lea    0x1(%eax),%edx
80108bee:	89 d0                	mov    %edx,%eax
80108bf0:	c1 f8 1f             	sar    $0x1f,%eax
80108bf3:	c1 e8 1d             	shr    $0x1d,%eax
80108bf6:	01 c2                	add    %eax,%edx
80108bf8:	83 e2 07             	and    $0x7,%edx
80108bfb:	29 c2                	sub    %eax,%edx
80108bfd:	89 d0                	mov    %edx,%eax
80108bff:	89 45 dc             	mov    %eax,-0x24(%ebp)
        currProc->clockQueue[index].vpn = currProc->clockQueue[next_index].vpn;
80108c02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c05:	8b 55 dc             	mov    -0x24(%ebp),%edx
80108c08:	83 c2 0e             	add    $0xe,%edx
80108c0b:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80108c0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c15:	83 c1 0e             	add    $0xe,%ecx
80108c18:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
        currProc->clockQueue[index].pte = currProc->clockQueue[next_index].pte;
80108c1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c1f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80108c22:	83 c2 0e             	add    $0xe,%edx
80108c25:	8b 54 d0 10          	mov    0x10(%eax,%edx,8),%edx
80108c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c2c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c2f:	83 c1 0e             	add    $0xe,%ecx
80108c32:	89 54 c8 10          	mov    %edx,0x10(%eax,%ecx,8)
    for (int index = match; index != start; index = (index + 1) % CLOCKSIZE) {
80108c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c39:	8d 50 01             	lea    0x1(%eax),%edx
80108c3c:	89 d0                	mov    %edx,%eax
80108c3e:	c1 f8 1f             	sar    $0x1f,%eax
80108c41:	c1 e8 1d             	shr    $0x1d,%eax
80108c44:	01 c2                	add    %eax,%edx
80108c46:	83 e2 07             	and    $0x7,%edx
80108c49:	29 c2                	sub    %eax,%edx
80108c4b:	89 d0                	mov    %edx,%eax
80108c4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c53:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80108c56:	75 90                	jne    80108be8 <clk_remove+0xa1>
    }

    currProc->clockQueue[start].vpn = -1;
80108c58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c5b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108c5e:	83 c2 0e             	add    $0xe,%edx
80108c61:	c7 44 d0 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,8)
80108c68:	ff 
    currProc->clockIndex = currProc->clockIndex == 0 ? CLOCKSIZE - 1: currProc->clockIndex - 1;
80108c69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c6c:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108c72:	85 c0                	test   %eax,%eax
80108c74:	74 0e                	je     80108c84 <clk_remove+0x13d>
80108c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c79:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108c7f:	8d 50 ff             	lea    -0x1(%eax),%edx
80108c82:	eb 05                	jmp    80108c89 <clk_remove+0x142>
80108c84:	ba 07 00 00 00       	mov    $0x7,%edx
80108c89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c8c:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
80108c92:	eb 01                	jmp    80108c95 <clk_remove+0x14e>
        return;
80108c94:	90                   	nop
}
80108c95:	c9                   	leave  
80108c96:	c3                   	ret    

80108c97 <mdecrypt>:


int mdecrypt(char *virtual_addr) {
80108c97:	f3 0f 1e fb          	endbr32 
80108c9b:	55                   	push   %ebp
80108c9c:	89 e5                	mov    %esp,%ebp
80108c9e:	83 ec 28             	sub    $0x28,%esp
  //   *slider = *slider ^ 0xFF;
  //   slider++;
  // }
  // return 0;
  pte_t *pte;
  pde_t* mypd = myproc()->pgdir;
80108ca1:	e8 2e b8 ff ff       	call   801044d4 <myproc>
80108ca6:	8b 40 04             	mov    0x4(%eax),%eax
80108ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *alignedAddr = (char*)PGROUNDDOWN(((uint)virtual_addr));
80108cac:	8b 45 08             	mov    0x8(%ebp),%eax
80108caf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  char *kernelAddr = uva2ka(mypd, alignedAddr);
80108cb7:	83 ec 08             	sub    $0x8,%esp
80108cba:	ff 75 ec             	pushl  -0x14(%ebp)
80108cbd:	ff 75 f0             	pushl  -0x10(%ebp)
80108cc0:	e8 71 fb ff ff       	call   80108836 <uva2ka>
80108cc5:	83 c4 10             	add    $0x10,%esp
80108cc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //This means that PTE_U == 0 or PTE_E and PTE_P both == 0
  if(kernelAddr == 0){
80108ccb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ccf:	75 0a                	jne    80108cdb <mdecrypt+0x44>
    return -1;
80108cd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cd6:	e9 99 00 00 00       	jmp    80108d74 <mdecrypt+0xdd>
  }
  pte = walkpgdir(mypd, alignedAddr, 0);
80108cdb:	83 ec 04             	sub    $0x4,%esp
80108cde:	6a 00                	push   $0x0
80108ce0:	ff 75 ec             	pushl  -0x14(%ebp)
80108ce3:	ff 75 f0             	pushl  -0x10(%ebp)
80108ce6:	e8 67 f2 ff ff       	call   80107f52 <walkpgdir>
80108ceb:	83 c4 10             	add    $0x10,%esp
80108cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(!((*pte & PTE_E) == 0) && ((*pte & PTE_P) == 0)){
80108cf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cf4:	8b 00                	mov    (%eax),%eax
80108cf6:	25 00 04 00 00       	and    $0x400,%eax
80108cfb:	85 c0                	test   %eax,%eax
80108cfd:	74 70                	je     80108d6f <mdecrypt+0xd8>
80108cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d02:	8b 00                	mov    (%eax),%eax
80108d04:	83 e0 01             	and    $0x1,%eax
80108d07:	85 c0                	test   %eax,%eax
80108d09:	75 64                	jne    80108d6f <mdecrypt+0xd8>
    *pte = (*pte) | PTE_P; // Set the PTE_P
80108d0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d0e:	8b 00                	mov    (%eax),%eax
80108d10:	83 c8 01             	or     $0x1,%eax
80108d13:	89 c2                	mov    %eax,%edx
80108d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d18:	89 10                	mov    %edx,(%eax)
    *pte = (*pte) & (~PTE_E); // Clear PTE_E
80108d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d1d:	8b 00                	mov    (%eax),%eax
80108d1f:	80 e4 fb             	and    $0xfb,%ah
80108d22:	89 c2                	mov    %eax,%edx
80108d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d27:	89 10                	mov    %edx,(%eax)
    // Decrypt all bits on that page
		for (int i = 0; i < PGSIZE; i++) {
80108d29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d30:	eb 1b                	jmp    80108d4d <mdecrypt+0xb6>
			*(kernelAddr + i) ^= 0xFF;
80108d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d38:	01 d0                	add    %edx,%eax
80108d3a:	0f b6 10             	movzbl (%eax),%edx
80108d3d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108d40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d43:	01 c8                	add    %ecx,%eax
80108d45:	f7 d2                	not    %edx
80108d47:	88 10                	mov    %dl,(%eax)
		for (int i = 0; i < PGSIZE; i++) {
80108d49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d4d:	81 7d f4 ff 0f 00 00 	cmpl   $0xfff,-0xc(%ebp)
80108d54:	7e dc                	jle    80108d32 <mdecrypt+0x9b>
		}
    // Insert page into working set
    clk_insert((uint) alignedAddr, pte);
80108d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d59:	83 ec 08             	sub    $0x8,%esp
80108d5c:	ff 75 e4             	pushl  -0x1c(%ebp)
80108d5f:	50                   	push   %eax
80108d60:	e8 b0 fc ff ff       	call   80108a15 <clk_insert>
80108d65:	83 c4 10             	add    $0x10,%esp
    //Success
    return 0; 
80108d68:	b8 00 00 00 00       	mov    $0x0,%eax
80108d6d:	eb 05                	jmp    80108d74 <mdecrypt+0xdd>
  }
  return -1;
80108d6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108d74:	c9                   	leave  
80108d75:	c3                   	ret    

80108d76 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108d76:	f3 0f 1e fb          	endbr32 
80108d7a:	55                   	push   %ebp
80108d7b:	89 e5                	mov    %esp,%ebp
80108d7d:	83 ec 28             	sub    $0x28,%esp
  //   }
  // }

  // switchuvm(myproc());
  // return 0;
  if(len == 0){
80108d80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80108d84:	75 0a                	jne    80108d90 <mencrypt+0x1a>
    return 0;
80108d86:	b8 00 00 00 00       	mov    $0x0,%eax
80108d8b:	e9 fd 00 00 00       	jmp    80108e8d <mencrypt+0x117>
  }
  if(len < 0){
80108d90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80108d94:	79 0a                	jns    80108da0 <mencrypt+0x2a>
    return -1;
80108d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d9b:	e9 ed 00 00 00       	jmp    80108e8d <mencrypt+0x117>
  }
  struct proc * p = myproc();
80108da0:	e8 2f b7 ff ff       	call   801044d4 <myproc>
80108da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
80108da8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dab:	8b 40 04             	mov    0x4(%eax),%eax
80108dae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pte_t *pte;

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108db1:	8b 45 08             	mov    0x8(%ebp),%eax
80108db4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108db9:	89 45 08             	mov    %eax,0x8(%ebp)
  for(int i = 0; i < len; i++){
80108dbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108dc3:	e9 a3 00 00 00       	jmp    80108e6b <mencrypt+0xf5>
    char* slider = virtual_addr + (i * PGSIZE);
80108dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcb:	c1 e0 0c             	shl    $0xc,%eax
80108dce:	89 c2                	mov    %eax,%edx
80108dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80108dd3:	01 d0                	add    %edx,%eax
80108dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *kernelAddr = uva2ka(mypd, slider);
80108dd8:	83 ec 08             	sub    $0x8,%esp
80108ddb:	ff 75 e4             	pushl  -0x1c(%ebp)
80108dde:	ff 75 e8             	pushl  -0x18(%ebp)
80108de1:	e8 50 fa ff ff       	call   80108836 <uva2ka>
80108de6:	83 c4 10             	add    $0x10,%esp
80108de9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(kernelAddr == 0){
80108dec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108df0:	74 71                	je     80108e63 <mencrypt+0xed>
      continue;
    }
    pte = walkpgdir(mypd, slider, 0);
80108df2:	83 ec 04             	sub    $0x4,%esp
80108df5:	6a 00                	push   $0x0
80108df7:	ff 75 e4             	pushl  -0x1c(%ebp)
80108dfa:	ff 75 e8             	pushl  -0x18(%ebp)
80108dfd:	e8 50 f1 ff ff       	call   80107f52 <walkpgdir>
80108e02:	83 c4 10             	add    $0x10,%esp
80108e05:	89 45 dc             	mov    %eax,-0x24(%ebp)

		if (*pte & PTE_E ) {
80108e08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e0b:	8b 00                	mov    (%eax),%eax
80108e0d:	25 00 04 00 00       	and    $0x400,%eax
80108e12:	85 c0                	test   %eax,%eax
80108e14:	75 50                	jne    80108e66 <mencrypt+0xf0>
    	continue;
		}
    *pte = (*pte) & (~PTE_P);
80108e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e19:	8b 00                	mov    (%eax),%eax
80108e1b:	83 e0 fe             	and    $0xfffffffe,%eax
80108e1e:	89 c2                	mov    %eax,%edx
80108e20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e23:	89 10                	mov    %edx,(%eax)
    *pte = (*pte) | PTE_E;
80108e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e28:	8b 00                	mov    (%eax),%eax
80108e2a:	80 cc 04             	or     $0x4,%ah
80108e2d:	89 c2                	mov    %eax,%edx
80108e2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e32:	89 10                	mov    %edx,(%eax)
  
		for (int offset = 0; offset < PGSIZE; offset++) {
80108e34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e3b:	eb 1b                	jmp    80108e58 <mencrypt+0xe2>
			*(kernelAddr + offset) ^= 0xFF;
80108e3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108e40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e43:	01 d0                	add    %edx,%eax
80108e45:	0f b6 10             	movzbl (%eax),%edx
80108e48:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80108e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4e:	01 c8                	add    %ecx,%eax
80108e50:	f7 d2                	not    %edx
80108e52:	88 10                	mov    %dl,(%eax)
		for (int offset = 0; offset < PGSIZE; offset++) {
80108e54:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e58:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108e5f:	7e dc                	jle    80108e3d <mencrypt+0xc7>
80108e61:	eb 04                	jmp    80108e67 <mencrypt+0xf1>
      continue;
80108e63:	90                   	nop
80108e64:	eb 01                	jmp    80108e67 <mencrypt+0xf1>
    	continue;
80108e66:	90                   	nop
  for(int i = 0; i < len; i++){
80108e67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e71:	0f 8c 51 ff ff ff    	jl     80108dc8 <mencrypt+0x52>
		} 
  }
  switchuvm(myproc());
80108e77:	e8 58 b6 ff ff       	call   801044d4 <myproc>
80108e7c:	83 ec 0c             	sub    $0xc,%esp
80108e7f:	50                   	push   %eax
80108e80:	e8 f4 f2 ff ff       	call   80108179 <switchuvm>
80108e85:	83 c4 10             	add    $0x10,%esp
  return 0;
80108e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e8d:	c9                   	leave  
80108e8e:	c3                   	ret    

80108e8f <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
80108e8f:	f3 0f 1e fb          	endbr32 
80108e93:	55                   	push   %ebp
80108e94:	89 e5                	mov    %esp,%ebp
80108e96:	83 ec 28             	sub    $0x28,%esp

  // }

  // return i;

  if (pt_entries == 0){
80108e99:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e9d:	75 0a                	jne    80108ea9 <getpgtable+0x1a>
    return -1;
80108e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ea4:	e9 ea 03 00 00       	jmp    80109293 <getpgtable+0x404>
  }
  if(wsetOnly != 0 && wsetOnly != 1){
80108ea9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108ead:	74 10                	je     80108ebf <getpgtable+0x30>
80108eaf:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
80108eb3:	74 0a                	je     80108ebf <getpgtable+0x30>
    return -1;
80108eb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eba:	e9 d4 03 00 00       	jmp    80109293 <getpgtable+0x404>
  }
  pte_t *pte;
  struct proc *currProc = myproc();
80108ebf:	e8 10 b6 ff ff       	call   801044d4 <myproc>
80108ec4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  char *currAddr = (char*)PGROUNDDOWN((uint)(currProc->sz));
80108ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eca:	8b 00                	mov    (%eax),%eax
80108ecc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int totalPages = currProc->sz / PGSIZE;
80108ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ed7:	8b 00                	mov    (%eax),%eax
80108ed9:	c1 e8 0c             	shr    $0xc,%eax
80108edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int pagesSearched = 0;
80108edf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int numFilled = 0;
80108ee6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  // only fill upto num pages, if there are less valid pages than num, exit after we've searched all pages
	while (numFilled < num && pagesSearched < totalPages) {
80108eed:	e9 8a 03 00 00       	jmp    8010927c <getpgtable+0x3ed>
    pte = walkpgdir(currProc->pgdir, currAddr, 0);
80108ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef5:	8b 40 04             	mov    0x4(%eax),%eax
80108ef8:	83 ec 04             	sub    $0x4,%esp
80108efb:	6a 00                	push   $0x0
80108efd:	ff 75 f4             	pushl  -0xc(%ebp)
80108f00:	50                   	push   %eax
80108f01:	e8 4c f0 ff ff       	call   80107f52 <walkpgdir>
80108f06:	83 c4 10             	add    $0x10,%esp
80108f09:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (wsetOnly == 0) {
80108f0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108f10:	0f 85 ae 01 00 00    	jne    801090c4 <getpgtable+0x235>
			if ((*pte & PTE_E) != 0 || (*pte & PTE_P) != 0) {
80108f16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f19:	8b 00                	mov    (%eax),%eax
80108f1b:	25 00 04 00 00       	and    $0x400,%eax
80108f20:	85 c0                	test   %eax,%eax
80108f22:	75 10                	jne    80108f34 <getpgtable+0xa5>
80108f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f27:	8b 00                	mov    (%eax),%eax
80108f29:	83 e0 01             	and    $0x1,%eax
80108f2c:	85 c0                	test   %eax,%eax
80108f2e:	0f 84 3d 03 00 00    	je     80109271 <getpgtable+0x3e2>
				pt_entries[numFilled].pdx = PDX(currAddr);
80108f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f37:	c1 e8 16             	shr    $0x16,%eax
80108f3a:	89 c1                	mov    %eax,%ecx
80108f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f3f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108f46:	8b 45 08             	mov    0x8(%ebp),%eax
80108f49:	01 c2                	add    %eax,%edx
80108f4b:	89 c8                	mov    %ecx,%eax
80108f4d:	66 25 ff 03          	and    $0x3ff,%ax
80108f51:	66 25 ff 03          	and    $0x3ff,%ax
80108f55:	89 c1                	mov    %eax,%ecx
80108f57:	0f b7 02             	movzwl (%edx),%eax
80108f5a:	66 25 00 fc          	and    $0xfc00,%ax
80108f5e:	09 c8                	or     %ecx,%eax
80108f60:	66 89 02             	mov    %ax,(%edx)
        pt_entries[numFilled].ptx = PTX(currAddr);
80108f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f66:	c1 e8 0c             	shr    $0xc,%eax
80108f69:	89 c1                	mov    %eax,%ecx
80108f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f6e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108f75:	8b 45 08             	mov    0x8(%ebp),%eax
80108f78:	01 c2                	add    %eax,%edx
80108f7a:	89 c8                	mov    %ecx,%eax
80108f7c:	66 25 ff 03          	and    $0x3ff,%ax
80108f80:	0f b7 c0             	movzwl %ax,%eax
80108f83:	25 ff 03 00 00       	and    $0x3ff,%eax
80108f88:	c1 e0 0a             	shl    $0xa,%eax
80108f8b:	89 c1                	mov    %eax,%ecx
80108f8d:	8b 02                	mov    (%edx),%eax
80108f8f:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108f94:	09 c8                	or     %ecx,%eax
80108f96:	89 02                	mov    %eax,(%edx)
        pt_entries[numFilled].ppage = *pte >> PTXSHIFT;
80108f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f9b:	8b 00                	mov    (%eax),%eax
80108f9d:	c1 e8 0c             	shr    $0xc,%eax
80108fa0:	89 c2                	mov    %eax,%edx
80108fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108fac:	8b 45 08             	mov    0x8(%ebp),%eax
80108faf:	01 c8                	add    %ecx,%eax
80108fb1:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80108fb7:	89 d1                	mov    %edx,%ecx
80108fb9:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80108fbf:	8b 50 04             	mov    0x4(%eax),%edx
80108fc2:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80108fc8:	09 ca                	or     %ecx,%edx
80108fca:	89 50 04             	mov    %edx,0x4(%eax)
        pt_entries[numFilled].present = (*pte & PTE_P) ? 1 : 0;
80108fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd0:	8b 08                	mov    (%eax),%ecx
80108fd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fd5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80108fdf:	01 c2                	add    %eax,%edx
80108fe1:	89 c8                	mov    %ecx,%eax
80108fe3:	83 e0 01             	and    $0x1,%eax
80108fe6:	83 e0 01             	and    $0x1,%eax
80108fe9:	c1 e0 04             	shl    $0x4,%eax
80108fec:	89 c1                	mov    %eax,%ecx
80108fee:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108ff2:	83 e0 ef             	and    $0xffffffef,%eax
80108ff5:	09 c8                	or     %ecx,%eax
80108ff7:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].writable = (*pte & PTE_W) ? 1 : 0;
80108ffa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ffd:	8b 00                	mov    (%eax),%eax
80108fff:	d1 e8                	shr    %eax
80109001:	89 c1                	mov    %eax,%ecx
80109003:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109006:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010900d:	8b 45 08             	mov    0x8(%ebp),%eax
80109010:	01 c2                	add    %eax,%edx
80109012:	89 c8                	mov    %ecx,%eax
80109014:	83 e0 01             	and    $0x1,%eax
80109017:	83 e0 01             	and    $0x1,%eax
8010901a:	c1 e0 05             	shl    $0x5,%eax
8010901d:	89 c1                	mov    %eax,%ecx
8010901f:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109023:	83 e0 df             	and    $0xffffffdf,%eax
80109026:	09 c8                	or     %ecx,%eax
80109028:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].user = (*pte & PTE_U) ? 1 : 0;
8010902b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010902e:	8b 00                	mov    (%eax),%eax
80109030:	c1 e8 02             	shr    $0x2,%eax
80109033:	89 c1                	mov    %eax,%ecx
80109035:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109038:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010903f:	8b 45 08             	mov    0x8(%ebp),%eax
80109042:	01 c2                	add    %eax,%edx
80109044:	89 c8                	mov    %ecx,%eax
80109046:	83 e0 01             	and    $0x1,%eax
80109049:	83 e0 01             	and    $0x1,%eax
8010904c:	c1 e0 06             	shl    $0x6,%eax
8010904f:	89 c1                	mov    %eax,%ecx
80109051:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109055:	83 e0 bf             	and    $0xffffffbf,%eax
80109058:	09 c8                	or     %ecx,%eax
8010905a:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].encrypted = (*pte & PTE_E) ? 1 : 0;
8010905d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109060:	8b 00                	mov    (%eax),%eax
80109062:	c1 e8 0a             	shr    $0xa,%eax
80109065:	89 c1                	mov    %eax,%ecx
80109067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010906a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109071:	8b 45 08             	mov    0x8(%ebp),%eax
80109074:	01 c2                	add    %eax,%edx
80109076:	89 c8                	mov    %ecx,%eax
80109078:	83 e0 01             	and    $0x1,%eax
8010907b:	c1 e0 07             	shl    $0x7,%eax
8010907e:	89 c1                	mov    %eax,%ecx
80109080:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109084:	83 e0 7f             	and    $0x7f,%eax
80109087:	09 c8                	or     %ecx,%eax
80109089:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].ref = (*pte & PTE_A) ? 1 : 0;
8010908c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010908f:	8b 00                	mov    (%eax),%eax
80109091:	c1 e8 05             	shr    $0x5,%eax
80109094:	89 c1                	mov    %eax,%ecx
80109096:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109099:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801090a0:	8b 45 08             	mov    0x8(%ebp),%eax
801090a3:	01 c2                	add    %eax,%edx
801090a5:	89 c8                	mov    %ecx,%eax
801090a7:	83 e0 01             	and    $0x1,%eax
801090aa:	83 e0 01             	and    $0x1,%eax
801090ad:	89 c1                	mov    %eax,%ecx
801090af:	0f b6 42 07          	movzbl 0x7(%edx),%eax
801090b3:	83 e0 fe             	and    $0xfffffffe,%eax
801090b6:	09 c8                	or     %ecx,%eax
801090b8:	88 42 07             	mov    %al,0x7(%edx)
        numFilled++;
801090bb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801090bf:	e9 ad 01 00 00       	jmp    80109271 <getpgtable+0x3e2>
			}
		} else {
			if (((*pte & PTE_E) == 0) && ((*pte & PTE_P) != 0)) {
801090c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c7:	8b 00                	mov    (%eax),%eax
801090c9:	25 00 04 00 00       	and    $0x400,%eax
801090ce:	85 c0                	test   %eax,%eax
801090d0:	0f 85 9b 01 00 00    	jne    80109271 <getpgtable+0x3e2>
801090d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090d9:	8b 00                	mov    (%eax),%eax
801090db:	83 e0 01             	and    $0x1,%eax
801090de:	85 c0                	test   %eax,%eax
801090e0:	0f 84 8b 01 00 00    	je     80109271 <getpgtable+0x3e2>
				pt_entries[numFilled].pdx = PDX(currAddr);
801090e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e9:	c1 e8 16             	shr    $0x16,%eax
801090ec:	89 c1                	mov    %eax,%ecx
801090ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801090f8:	8b 45 08             	mov    0x8(%ebp),%eax
801090fb:	01 c2                	add    %eax,%edx
801090fd:	89 c8                	mov    %ecx,%eax
801090ff:	66 25 ff 03          	and    $0x3ff,%ax
80109103:	66 25 ff 03          	and    $0x3ff,%ax
80109107:	89 c1                	mov    %eax,%ecx
80109109:	0f b7 02             	movzwl (%edx),%eax
8010910c:	66 25 00 fc          	and    $0xfc00,%ax
80109110:	09 c8                	or     %ecx,%eax
80109112:	66 89 02             	mov    %ax,(%edx)
        pt_entries[numFilled].ptx = PTX(currAddr);
80109115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109118:	c1 e8 0c             	shr    $0xc,%eax
8010911b:	89 c1                	mov    %eax,%ecx
8010911d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109120:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109127:	8b 45 08             	mov    0x8(%ebp),%eax
8010912a:	01 c2                	add    %eax,%edx
8010912c:	89 c8                	mov    %ecx,%eax
8010912e:	66 25 ff 03          	and    $0x3ff,%ax
80109132:	0f b7 c0             	movzwl %ax,%eax
80109135:	25 ff 03 00 00       	and    $0x3ff,%eax
8010913a:	c1 e0 0a             	shl    $0xa,%eax
8010913d:	89 c1                	mov    %eax,%ecx
8010913f:	8b 02                	mov    (%edx),%eax
80109141:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80109146:	09 c8                	or     %ecx,%eax
80109148:	89 02                	mov    %eax,(%edx)
        pt_entries[numFilled].ppage = *pte >> PTXSHIFT;
8010914a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010914d:	8b 00                	mov    (%eax),%eax
8010914f:	c1 e8 0c             	shr    $0xc,%eax
80109152:	89 c2                	mov    %eax,%edx
80109154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109157:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010915e:	8b 45 08             	mov    0x8(%ebp),%eax
80109161:	01 c8                	add    %ecx,%eax
80109163:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80109169:	89 d1                	mov    %edx,%ecx
8010916b:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80109171:	8b 50 04             	mov    0x4(%eax),%edx
80109174:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
8010917a:	09 ca                	or     %ecx,%edx
8010917c:	89 50 04             	mov    %edx,0x4(%eax)
        pt_entries[numFilled].present = (*pte & PTE_P) ? 1 : 0;
8010917f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109182:	8b 08                	mov    (%eax),%ecx
80109184:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109187:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010918e:	8b 45 08             	mov    0x8(%ebp),%eax
80109191:	01 c2                	add    %eax,%edx
80109193:	89 c8                	mov    %ecx,%eax
80109195:	83 e0 01             	and    $0x1,%eax
80109198:	83 e0 01             	and    $0x1,%eax
8010919b:	c1 e0 04             	shl    $0x4,%eax
8010919e:	89 c1                	mov    %eax,%ecx
801091a0:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801091a4:	83 e0 ef             	and    $0xffffffef,%eax
801091a7:	09 c8                	or     %ecx,%eax
801091a9:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].writable = (*pte & PTE_W) ? 1 : 0;
801091ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091af:	8b 00                	mov    (%eax),%eax
801091b1:	d1 e8                	shr    %eax
801091b3:	89 c1                	mov    %eax,%ecx
801091b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091b8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801091bf:	8b 45 08             	mov    0x8(%ebp),%eax
801091c2:	01 c2                	add    %eax,%edx
801091c4:	89 c8                	mov    %ecx,%eax
801091c6:	83 e0 01             	and    $0x1,%eax
801091c9:	83 e0 01             	and    $0x1,%eax
801091cc:	c1 e0 05             	shl    $0x5,%eax
801091cf:	89 c1                	mov    %eax,%ecx
801091d1:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801091d5:	83 e0 df             	and    $0xffffffdf,%eax
801091d8:	09 c8                	or     %ecx,%eax
801091da:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].user = (*pte & PTE_U) ? 1 : 0;
801091dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091e0:	8b 00                	mov    (%eax),%eax
801091e2:	c1 e8 02             	shr    $0x2,%eax
801091e5:	89 c1                	mov    %eax,%ecx
801091e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801091f1:	8b 45 08             	mov    0x8(%ebp),%eax
801091f4:	01 c2                	add    %eax,%edx
801091f6:	89 c8                	mov    %ecx,%eax
801091f8:	83 e0 01             	and    $0x1,%eax
801091fb:	83 e0 01             	and    $0x1,%eax
801091fe:	c1 e0 06             	shl    $0x6,%eax
80109201:	89 c1                	mov    %eax,%ecx
80109203:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109207:	83 e0 bf             	and    $0xffffffbf,%eax
8010920a:	09 c8                	or     %ecx,%eax
8010920c:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].encrypted = (*pte & PTE_E) ? 1 : 0;
8010920f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109212:	8b 00                	mov    (%eax),%eax
80109214:	c1 e8 0a             	shr    $0xa,%eax
80109217:	89 c1                	mov    %eax,%ecx
80109219:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010921c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109223:	8b 45 08             	mov    0x8(%ebp),%eax
80109226:	01 c2                	add    %eax,%edx
80109228:	89 c8                	mov    %ecx,%eax
8010922a:	83 e0 01             	and    $0x1,%eax
8010922d:	c1 e0 07             	shl    $0x7,%eax
80109230:	89 c1                	mov    %eax,%ecx
80109232:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109236:	83 e0 7f             	and    $0x7f,%eax
80109239:	09 c8                	or     %ecx,%eax
8010923b:	88 42 06             	mov    %al,0x6(%edx)
        pt_entries[numFilled].ref = (*pte & PTE_A) ? 1 : 0;
8010923e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109241:	8b 00                	mov    (%eax),%eax
80109243:	c1 e8 05             	shr    $0x5,%eax
80109246:	89 c1                	mov    %eax,%ecx
80109248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010924b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109252:	8b 45 08             	mov    0x8(%ebp),%eax
80109255:	01 c2                	add    %eax,%edx
80109257:	89 c8                	mov    %ecx,%eax
80109259:	83 e0 01             	and    $0x1,%eax
8010925c:	83 e0 01             	and    $0x1,%eax
8010925f:	89 c1                	mov    %eax,%ecx
80109261:	0f b6 42 07          	movzbl 0x7(%edx),%eax
80109265:	83 e0 fe             	and    $0xfffffffe,%eax
80109268:	09 c8                	or     %ecx,%eax
8010926a:	88 42 07             	mov    %al,0x7(%edx)
        numFilled++;
8010926d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
			}
		}
    pagesSearched++;
80109271:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    currAddr -= PGSIZE;
80109275:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
	while (numFilled < num && pagesSearched < totalPages) {
8010927c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010927f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109282:	7d 0c                	jge    80109290 <getpgtable+0x401>
80109284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109287:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010928a:	0f 8c 62 fc ff ff    	jl     80108ef2 <getpgtable+0x63>
  }
	return numFilled;
80109290:	8b 45 ec             	mov    -0x14(%ebp),%eax

}
80109293:	c9                   	leave  
80109294:	c3                   	ret    

80109295 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
80109295:	f3 0f 1e fb          	endbr32 
80109299:	55                   	push   %ebp
8010929a:	89 e5                	mov    %esp,%ebp
8010929c:	56                   	push   %esi
8010929d:	53                   	push   %ebx
8010929e:	83 ec 10             	sub    $0x10,%esp
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
801092a1:	83 ec 04             	sub    $0x4,%esp
801092a4:	ff 75 0c             	pushl  0xc(%ebp)
801092a7:	ff 75 08             	pushl  0x8(%ebp)
801092aa:	68 d0 9b 10 80       	push   $0x80109bd0
801092af:	e8 64 71 ff ff       	call   80100418 <cprintf>
801092b4:	83 c4 10             	add    $0x10,%esp
  if(buffer == 0)return -1;
801092b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801092bb:	75 07                	jne    801092c4 <dump_rawphymem+0x2f>
801092bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092c2:	eb 4a                	jmp    8010930e <dump_rawphymem+0x79>
  
  *buffer = *buffer;
801092c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801092c7:	0f b6 10             	movzbl (%eax),%edx
801092ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801092cd:	88 10                	mov    %dl,(%eax)
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
801092cf:	8b 45 08             	mov    0x8(%ebp),%eax
801092d2:	05 00 00 00 80       	add    $0x80000000,%eax
801092d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092dc:	89 c6                	mov    %eax,%esi
801092de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801092e1:	e8 ee b1 ff ff       	call   801044d4 <myproc>
801092e6:	8b 40 04             	mov    0x4(%eax),%eax
801092e9:	68 00 10 00 00       	push   $0x1000
801092ee:	56                   	push   %esi
801092ef:	53                   	push   %ebx
801092f0:	50                   	push   %eax
801092f1:	e8 99 f5 ff ff       	call   8010888f <copyout>
801092f6:	83 c4 10             	add    $0x10,%esp
801092f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
801092fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109300:	74 07                	je     80109309 <dump_rawphymem+0x74>
    return -1;
80109302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109307:	eb 05                	jmp    8010930e <dump_rawphymem+0x79>
  return 0;
80109309:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010930e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109311:	5b                   	pop    %ebx
80109312:	5e                   	pop    %esi
80109313:	5d                   	pop    %ebp
80109314:	c3                   	ret    
