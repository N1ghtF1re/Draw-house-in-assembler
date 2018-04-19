        include 'macro\proc16.inc'
        org 100h

        Top_Color = $0
        Mode_Border = 1
        Mode_NoBorder = 0

EntryPoint:
        mov ah, $0f
        int 10h
        mov [Video.OldMode], ah
        mov [Video.OldPage], bh


        mov ax, $0013
        int 10h


        ; push $b800  ; Альетрнатива
        ; pop es

        mov ax, $A000
        mov es, ax

        mov al, 54
        mov cx, 320*200
        xor di,di
        rep stosb


        stdcall drawFillRect, 50, 70, 260,190, 66
        stdcall drawFillRect, 220, 135, 250, 185, $71
        stdcall drawFillRect, 235, 163, 244,165
        stdcall drawCircle, 81, 100, 15, $F, Mode_Border
        stdcall drawCircle, 140, 100, 15, $F,Mode_Border
        stdcall drawCircle, 200, 100, 15, $F, Mode_Border
        stdcall drawCircle, 81, 100, 15, $0, Mode_NoBorder
        stdcall drawCircle, 140, 100, 15, $0,Mode_NoBorder
        stdcall drawCircle, 200, 100, 15, $0, Mode_NoBorder
        stdcall drawFillRect, 70, 135, 110, 155, $03
        stdcall drawFillRect, 140, 135, 180, 155, $03
        stdcall drawRect,70, 135, 110, 155, $00
        stdcall drawRect,140, 135, 180, 155, $00
        stdcall putpixel, 110,155, $00
        stdcall putpixel, 180,155, $00
        stdcall drawFillRect, 230, 40, 250, 70, Top_Color

        stdcall drawVertLine, 30, 38, 234, $f
        stdcall drawVertLine, 13, 23, 234, $f
        stdcall drawVertLine, 24, 34, 238, $f
        stdcall drawVertLine, 10, 23, 244, $f
        stdcall drawVertLine, 14, 34, 242, $f


        mov bx, 50
        mov si, 260

        mov di, 70
        mov ax, 52
.Loopp:
        stdcall drawHorLine, bx, si,di, Top_Color
        add bx, 2
        sub si, 2
        sub di, 1
        dec ax
        cmp ax, 0
        ; stdcall drawHorLine, bx, si,di, Top_Color
        jne .Loopp

        ;stdcall drawCircle, 150,100,90, $F

        ;stdcall DrawBrakhMen

        ;call WriteBrakh

        stdcall drawCircle, 290, 140, 6, $0, Mode_Border
        stdcall drawVertLine, 140, 170, 290, $0
        stdcall drawHorLine, 280, 300, 155, $0
        mov ax, 170

        mov bx, 290
        mov si, 290

        stdcall putpixel, bx, ax, $0
        mov di, 10
.Loopa:
        inc ax

        inc bx
        dec si
        stdcall putpixel, bx, ax, $0
        stdcall putpixel, si, ax, $0

        dec di
        cmp di, 0
        jne .Loopa




        call ReadKey

        movzx ax, [Video.OldMode]
        int 10h
        mov ah, $05
        mov al, [Video.OldPage]


        ret
ReadKey:

        mov ax, $0C08
        int 21h
        test al,al
        jnz @F
        mov ah, $08
        int 21h
@@:
        ret

proc DrawBrakhMen uses bx
    mov ax, $F
    stdcall drawHorLine, 100,105,40, ax
    stdcall drawVertLine, 40, 52, 100, ax
    stdcall drawVertLine, 40, 52, 105, ax
    stdcall drawVertLine, 52, 58, 101, ax
    stdcall drawVertLine, 52, 58, 106, ax
    stdcall drawHorLine, 10,10,20,23, ax
    mov si, 102
    mov di, 58
    mov bx, 17
.Loop:
    stdcall putpixel, si, di, ax
    inc si
    inc di
    dec bx
    cmp bx, 0
    jnz .Loop

    mov si, 116
    mov di, 60
    mov bx, 15
.Loop2:
    stdcall putpixel, si, di, ax
    inc si
    inc di
    dec bx
    cmp bx, 0
    jnz .Loop2


    stdcall drawHorLine, 110,115,40, ax
    stdcall drawVertLine, 40, 60, 110, ax
    stdcall drawVertLine, 40, 60, 115, ax
    ret
endp

proc drawRect \
    x1,y1,x2,y2,color

    stdcall drawHorLine, [x1],[x2],[y1],[color]
    stdcall drawHorLine, [x1],[x2],[y2],[color]
    stdcall drawVertLine, [y1],[y2],[x1],[color]
    stdcall drawVertLine, [y1],[y2],[x2],[color]
    ret
endp

proc drawFillRect uses si,\
    x1,y1,x2,y2,color
    mov si, [y1]
.Loop:
    stdcall drawHorLine, [x1],[x2],si,[color]
    ;mov cx, [y1]
    add si, 1
    stdcall drawHorLine, [x1],[x2],si,[color]
    cmp si, [y2]
    js .Loop

    ret
endp

proc drawHorLine uses es di cx ax,\
    x1, x2, y, color

    mov ax, $A000
    mov es, ax

    mov al, byte[y]
    mov cx, 320
    mul cx
    mov di, ax
    add di, [x1]
    mov cx, [x2]
    sub cx, [x1]
    ;add cx, [x2]
    mov al, byte[color]
    rep stosb

    ret
endp


proc drawVertLine uses es di ax cx,\
    y1, y2, x, color

    mov ax, $A000
    mov es, ax

    mov cx, 320
    mov ax, [y1]
    mul cx
    mov di, ax
    add di, [x]

    mov ax, [y2]
    mov cx, 320
    mul cx
    mov cx, ax

.Loop:
    mov al, byte[color]
    mov [es:di], al

    add di, 320

    cmp di, cx
    js .Loop



    ret
endp

proc drawCircleSim uses bx si di ax,\
    x,y,xc,yc,color, mode
    ;  (E)AX, (E)CX, (E)DX
   ; putpixel(x+xc,y+yc,White);
   ; putpixel(x+xc,-y+yc,White);
   ; putpixel(-x+xc,-y+yc,White);
   ; putpixel(-x+xc,y+yc,White);
   ; putpixel(y+xc,x+yc,White);
   ; putpixel(y+xc,-x+yc,White);
   ; putpixel(-y+xc,-x+yc,White);
   ; putpixel(-y+xc,x+yc,White);

    mov ax, [x]
    add ax, [xc]
    mov bx, [y]
    add bx, [yc]

    stdcall putpixel, ax, bx,[color]
    cmp [mode], Mode_NoBorder
    je @F
    mov dx, [xc]
    sub dx, [x]
    push ax
    push dx
    push bx
    stdcall drawHorLine, dx, ax, bx, [color]
    pop bx
    pop dx
    pop ax
    add ax, 2
    dec dx
    dec bx
    stdcall drawHorLine, dx, ax, bx, [color]
@@:
    mov ax, [x]
    add ax, [xc]
    mov bx, [yc]
    sub bx, [y]
    stdcall putpixel, ax,bx,[color]
    cmp [mode], Mode_NoBorder
    je @F
    mov dx, [xc]
    sub dx, [x]
    push ax
    push dx
    push bx
    stdcall drawHorLine, dx, ax, bx, [color]
    pop bx
    pop dx
    pop ax
    add ax, 2
    dec dx
    add bx, 1
    stdcall drawHorLine, dx, ax, bx, [color]
 @@:
    mov ax, [xc]
    sub ax, [x]
    mov bx, [yc]
    sub bx, [y]

    stdcall putpixel, ax,bx,[color]


    mov ax, [xc]
    sub ax, [x]
    mov bx, [y]
    add bx, [yc]

    stdcall putpixel, ax,bx,[color]


    mov ax, [y]
    add ax, [xc]
    mov bx, [x]
    add bx, [yc]

    stdcall putpixel, ax,bx,[color]

    cmp [mode], Mode_NoBorder
    je @F
    mov dx, [xc]
    sub dx, [x]
    stdcall drawHorLine, dx, ax, bx, [color]
@@:
    mov ax, [y]
    add ax, [xc]
    mov bx, [yc]
    sub bx, [x]


    stdcall putpixel, ax,bx,[color]

    cmp [mode], Mode_NoBorder
    je @F
    mov dx, [xc]
    sub dx, [x]
    stdcall drawHorLine, dx, ax, bx, [color]
@@:
    mov ax, [xc]
    sub ax, [y]
    mov bx, [yc]
    sub bx, [x]

    stdcall putpixel, ax,bx,[color]

    cmp [mode], Mode_NoBorder
    je @F

    mov dx, [xc]
    sub dx, [x]
    stdcall drawHorLine, ax, dx, bx, [color]
@@:
    mov ax, [xc]
    sub ax, [y]
    mov bx, [x]
    add bx, [yc]

    stdcall putpixel, ax,bx,[color]

    cmp [mode], Mode_NoBorder
    je @F
    mov dx, [xc]
    sub dx, [x]
    stdcall drawHorLine, ax, dx, bx, [color]
@@:
    ret
endp
proc drawCircle uses es si ax cx bx dx,\
    xc, yc, r, color, mode

    mov ax, [y]
    add ax, [y]
    mov dx, 3
    sub dx, ax ; d = dx
    mov [d], dx
    mov [x], 0
    mov si, [r]
    mov [y], si




.While:
     stdcall drawCircleSim, [x], [y], [xc], [yc], [color], [mode]
     mov dx, [d]
     cmp dx, 0  ;if d<0
     js .Minus

     mov ax, [x]  ; else begin
     sub ax, [y]  ;d:=d+4*(x-y)+10;
     mov cx, ax
     add ax, cx
     add ax, cx
     add ax, cx

     add ax, 10
     add [d], ax
     dec [y]      ;dec(y)
     jmp .Skip
.Minus:            ;then d:=d+4*x+6
     mov ax, [x]
     add ax, [x]
     add ax, [x]
     add ax, [x]

     add ax, 6

     add [d], ax

.Skip:

     inc [x]
     mov ax, [y]
     cmp [x],ax

     js .While

    ret
endp

proc putpixel uses es di bx ax cx, \
    x,y, color
    mov ax, $A000
    mov es, ax


    mov al, byte[y]
    mov cx, 320
    mul cx
    mov di, ax
    add di, [x]

    mov al, byte[color]
    mov [es:di], al

    ret
endp




Video.OldMode db 0
Video.OldPage db 0
x dw 0
y dw 0
d dw 0

