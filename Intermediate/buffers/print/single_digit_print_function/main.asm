; nasm -f elf32 main.asm && ld -m elf_i386 main.o


section     .data
    arr     dd 5, 4, 3, 2, 1
    arr_len equ ($ - arr) / 4
    

section     .bss
    buffer  resb 1


section     .text
    global      _start


_start:
    mov edi, arr
    mov esi, 0
    mov edx, arr_len
    
    call print_array

    mov eax, 1
    int 0x80


print_array:
    cmp esi, edx
    jge .print_array_end


    mov al, [edi + esi*4]
    add al, '0'
    mov [buffer], al

    push edi
    push esi
    push edx

    mov eax, 4                    ; print array element
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    

    mov byte [buffer], 0x0A       ; print newline character
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80


    pop edx
    pop esi
    pop edi

    inc esi
    jmp print_array

.print_array_end:
    ret
    
