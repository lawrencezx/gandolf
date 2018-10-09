org 07c00h

  BaseOfLoader              equ 09000h
  OffsetOfLoader            equ 0100h 
  BaseOfStack               equ 07c00h
  SectorNoOfRootDirectory   equ 19 
  SectorNoOfFAT1            equ 1
  RootDirSectors            equ 14
  DeltaSectorNo             equ 17

  jmp short LABEL_START
  nop

  BS_OEMName        DB 'Burglar '
  BPB_BytsPerSec    DW 0x0200
  BPB_SecPerClus    DB 0x01     
  BPB_RsvdSecCnt    DW 1     
  BPB_NumFATs       DB 0x02     
  BPB_RootEntCnt    DW 0x00E0     ;224
  BPB_TotSec16      DW 0x0B40     ;2880   
  BPB_Media         DB 0xF0    
  BPB_FATSz16       DW 0x0009     
  BPB_SecPerTrk     DW 0x0012    
  BPB_NumHeads      DW 0x0002     
  BPB_HiddSec       DD 0     
  BPB_TotSec32      DD 0  
  BS_DrvNum         DB 0x00     
  BS_Reserved1      DB 0x00     
  BS_BootSig        DB 0x29   
  BS_VolID          DD 0     
  BS_VolLab         DB 'Gandolf    '
  BS_FileSysType    DB 'FAT12   '

LABEL_START:
  mov ax, cs
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, BaseOfStack

  mov ax, 0600h
  mov bx, 0700h
  mov cx, 0 
  mov dx, 0184fh
  int 10h

  mov dh, 0
  call DispStr
  xor ah, ah
  xor dl, dl
  int 13h

  mov word [wSectorNo], SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
  cmp word [wRootDirSizeForLoop], 0 
  jz LABEL_NO_LOADERBIN
  dec word [wRootDirSizeForLoop]
  mov ax, BaseOfLoader
  mov es, ax
  mov bx, OffsetOfLoader
  mov ax, [wSectorNo]
  mov cl, 1 
  call ReadSector

  mov si, LoaderFileName
  mov di, OffsetOfLoader
  cld
  mov cx, 10h
LABEL_SEARCH_FOR_LOADERBIN:
  cmp cx, 0 
  jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
  dec cx 
  mov dx, 11 
LABEL_CMP_FILENAME:
  cmp dx, 0 
  jz LABEL_FILENAME_FOUND
  dec dx 
  lodsb
  cmp al, byte [es:di]
  jz LABEL_GO_ON
  jmp LABEL_DIFFERENT
LABEL_GO_ON:
  inc di 
  jmp LABEL_CMP_FILENAME

LABEL_NO_LOADERBIN:
  mov dh, 2 
  call DispStr
  jmp $

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
  add word [wSectorNo], 1 
  jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_DIFFERENT:
  add di, 20h
  and di, 0FFE0h
  mov si, LoaderFileName
  jmp LABEL_SEARCH_FOR_LOADERBIN 

LABEL_FILENAME_FOUND:
  mov ax, RootDirSectors
  and di, 0FFE0h
  add di, 01Ah 
  mov cx, word [es:di]
  push cx 
  add cx, ax 
  add cx, DeltaSectorNo
  mov ax, BaseOfLoader
  mov es, ax 
  mov bx, OffsetOfLoader
  mov ax, cx

LABEL_GOON_LOADING_FILE:
  push ax 
  push bx 
  mov ah, 0Eh 
  mov al, '.'
  mov bl, 0Fh 
  int 10h 
  pop bx 
  pop ax 

  mov cl, 1 
  call ReadSector
  pop ax 
  call GetFATEntry
  cmp ax, 0FFFh 
  jz LABEL_FILE_LOADED
  push ax 
  mov dx, RootDirSectors
  add ax, dx 
  add ax, DeltaSectorNo 
  add bx, [BPB_BytsPerSec]
  jmp LABEL_GOON_LOADING_FILE

GetFATEntry:
  push es 
  push bx 
  push ax 
  mov ax, BaseOfLoader
  sub ax, 0100h 
  mov es, ax 
  pop ax 
  mov byte [bOdd], 0 
  mov bx, 3 
  mul bx 
  mov bx, 2 
  div bx 
  cmp dx, 0 
  jz LABEL_EVEN
  mov byte [bOdd], 1 
LABEL_EVEN:

  xor dx, dx 
  mov bx, [BPB_BytsPerSec]
  div bx 

  push dx 
  mov bx, 0 
  add ax, SectorNoOfFAT1 
  mov cl, 2 
  call ReadSector

  pop dx 
  add bx, dx 
  add ax, [es:bx] 
  cmp byte [bOdd], 1 
  jnz LABEL_EVEN_2 
  shr ax, 4
LABEL_EVEN_2:
  and ax, 0FFFh

LABEL_GET_FAT_ENRY_OK:
  pop bx 
  pop es 
  ret 
  
LABEL_FILE_LOADED:
  mov dh, 1 
  call DispStr
  jmp BaseOfLoader:OffsetOfLoader
  
ReadSector:
  push bp
  mov  bp, sp

  mov byte [ReadSectorN], cl
  push bx
  mov bl, [BPB_SecPerTrk]
  div bl
  mov dh, al
  and dh, 1 
  shr al, 1 
  mov ch, al 
  inc ah 
  mov cl, ah 
  pop bx
  mov dl, [BS_DrvNum]

KeepReading:
  mov al, [ReadSectorN]
  mov ah, 2 
  int 13h
  jc KeepReading

  pop bp
  ret

wRootDirSizeForLoop dw RootDirSectors
wSectorNo   dw 0 
bOdd        db 0 
ReadSectorN db 0 

LoaderFileName  db "LOADER  BIN", 0

MessageLength   equ 10
BootMessage     db  "Booting   "
Message1        db  "Ready.    "
Message2        db  "No Gandolf"

  
DispStr:                ;the next 7 lines is about display a message by int 10h
  mov ax, MessageLength 
  mul dh 
  add ax, BootMessage   ;find the message to display
  mov bp, ax            
  mov ax, ds 
  mov es, ax 
  mov ax, 1301h         
  mov bx, 000ch         
  mov cx, MessageLength            
  mov dl, 0         
  int 10h               
  ret 

times 510-($-$$)  db 0 
dw 0xaa55
