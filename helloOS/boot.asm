  org 07c00h
  mov ax, cs
  mov ds, ax
  mov es, ax
  call DispStr 
  jmp $ 
DispStr:                ;the next 7 lines is about display a message by int 10h
  mov ax, BootMessage   ;
  mov bp, ax            ;
  mov ax, 1301h         ;
  mov bx, 000ch         ;
  mov cx, 14            ;
  mov dx, 0000h         ;
  int 10h               ;
  ret 
BootMessage:  db "Hello, Gandalf"
times 510-($-$$)  db 0 
dw 0xaa55
