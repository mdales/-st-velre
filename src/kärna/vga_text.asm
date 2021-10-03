[bits 32]

; Inputs:
;     none
; Returns:
;     none
; Clobbers:
;     none
clear_vga_screen:
    push es
    push edx
    push ecx
    push ebx

    mov bx, VGA_TEXT_SEG
    mov es, bx
    mov edx, 0x0
    mov ebx, 0x1E002F00
.loop:
    mov [es:edx], ebx
    add edx, 4
    cmp edx, 80 * 25 * 2
    jne .loop

    ; set the cursor back to zero
    mov word [cursor], 0x0

    pop ebx
    pop ecx
    pop edx
    pop es
    ret

; Inputs:
;     ebx: address of string
; Returns:
;     none
; Clobbers:
;     none
print_vga_string:
    push es
    push eax
    push ebx
    push edx

    mov edx, VGA_TEXT_SEG
    mov es, edx
    mov dx, [cursor]

.loop:
    mov al, [ebx]
    cmp al, 0
    je .done
    mov byte [es:edx], al
    add edx, 2
    inc ebx
    jmp .loop
.done:
    mov [cursor], dx

    pop edx
    pop ebx
    pop eax
    pop es
    ret


; Inputs:
;     bl: ASCII character
; Returns:
;     none
; Clobbers:
;     none
print_vga_character:
    push es
    push ebx
    push edx

    mov edx, VGA_TEXT_SEG
    mov es, edx
    mov dx, [cursor]

    mov byte [es:edx], bl
    add edx, 2
    mov [cursor], dx

    pop edx
    pop ebx
    pop es
    ret


; Inputs:
;     bl: byte to print
; Returns:
;     none
; Clobbers:
;     none
print_vga_hex_byte:
    push es
    push edx
    push ebx

    mov edx, VGA_TEXT_SEG
    mov es, edx
    mov dx, [cursor]

    shr bl, 4
    add bl, '0'
    cmp bl, '9'
    jle .byte1
    add bl, 0x7
.byte1:
    mov byte [es:edx], bl
    add edx, 0x2
    pop ebx
    push ebx
    and bl, 0x0F
    add bl, '0'
    cmp bl, '9',
    jle .byte2
    add bl, 0x7
.byte2:
    mov byte [es:edx], bl
    add edx, 0x2

    mov [cursor], dx

    pop ebx
    pop edx
    pop es
    ret

; Inputs:
;     bl: cursor x position
;     bh: cursor y position
; Returns:
;     none
; Clobbers:
;     none
set_vga_cursor_position:
    cmp bl, 80
    jge .done
    cmp bh, 25
    jge .done

    push eax
    push ebx

    ; a pointless attempt to avoid using mul for fun but not profit
    xor eax, eax
    mov al, bh
    shl eax, 6 ; y * 64
    add al, bl
    adc ah, 0x0
    shr ebx, 4 ; y * 16
    and bx, 0x0FF0
    add ax, bx
    shl ax, 1
    mov word [cursor], ax

    pop ebx
    pop eax
.done:
    ret

; memory location to store current offset in VGA
cursor: dw 0x0
