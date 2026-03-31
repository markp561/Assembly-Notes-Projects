; nasm -f elf64 main.asm && ld main.o

default rel

section     .data

    arr      dq 5, 4, 3, 2, 1 
    arr_len  equ ($ - arr) / 8


section     .bss
    buffer   resb 1

section     .text
    global      _start


_start:

    mov rdi, arr
    mov rsi, 0
    mov rdx, arr_len
    dec rdx

    call print_array

    mov eax, 1
    int 0x80


print_array:
     
    cmp rsi, rdx
    jg .print_array_end

    mov rax, [rdi + rsi*8]
    add al, '0'
    mov [buffer], al

    push rdx

    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80

    pop rdx

    inc rsi
    jmp print_array

.print_array_end:
    ret

