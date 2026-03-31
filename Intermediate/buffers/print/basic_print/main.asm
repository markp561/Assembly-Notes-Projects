; nasm -f elf32 main.asm && ld -m elf_i386 main.o


section     .data               ; section for variables
    arr     dd 5, 4, 3, 2, 1
    arr_len equ ($ - arr) / 4

section     .bss                ; section for buffers
    buffer resb 1               ; resb means reserve bytes --- here we create buffer of 1 byte

section     .text               ; section for code
    global      _start


_start:

    mov ebx, arr
    mov ecx, 0 
    mov edx, arr_len

    print_array:
        cmp ecx, edx 
        jge .print_array_end 

        push ecx
        push edx

        mov eax, [ebx + ecx*4]
        add eax, '0'
        mov [buffer], eax

        push ebx
        
        ; print the element from the array
        mov edx, 1
        mov ecx, buffer
        mov ebx, 1
        mov eax, 4
        int 0x80

        
        ; print a newline (or a space)
        mov [buffer], 0x0A       ; 0x0A is hexadecimal for a newline character
        ; mov [buffer], 0x20     ; 0x20 is hexadecimal for a space character
        mov edx, 1
        mov ecx, buffer
        mov ebx, 1
        mov eax, 4
        int 0x80


        pop ebx
        pop edx
        pop ecx

        inc ecx
        jmp print_array

    .print_array_end:
        mov eax, 1
        int 0x80
    
