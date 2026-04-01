; nasm -f elf32 main.asm && ld main.o

section     .data
    arr         dd 12, 34, 56, 78, 9
    arr_len     equ ($ - arr) / 4

section     .bss
    buffer      resb 16

section     .text
    global      _start


_start:
    mov edi, arr            ; first arg --> base address of array
    mov esi, 0              ; second arg --> start index
    mov edx, buffer         ; third arg --> buffer
    mov ecx, arr_len        ; fourth arg --> array length
    
    call print_array

    mov eax, 1
    xor ebx, ebx
    int 0x80

; parameters: array, start index, array length, buffer
print_array:
    cmp esi, ecx
    jge .print_array_end
    mov eax, [edi + esi*4]

    push esi
    push ecx
    push edi

    call itoa
        
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    push edx

    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80

    pop edx

    pop edi
    pop ecx
    pop esi
    
    inc esi
    jmp print_array

.print_array_end:
    ret
    
; parameters: integer, buffer
itoa:
    mov edi, edx
    push edx
    mov ecx, 10
    xor esi, esi
  
.loop1:
    xor edx, edx
    idiv ecx

    push edx

    inc esi 

    test eax, eax
    jne .loop1

    mov eax, edi

.loop2:
    pop edx
    add dl, '0'
    mov [edi], dl

    inc edi
    dec esi
    jnz .loop2 

    mov edx, edi
    sub edx, eax
    
    pop edx
    mov eax, edi
    
    ret
