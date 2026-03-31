; nasm -f elf64 main.asm && gcc -no-pie main.o

default rel

section     .data
    fmt  db "%d", 10, 0     ; Needed for printf from C-language
    a    dd 9
    b    dd 2
    temp dd 0
    
section     .text
    global     main
    extern     printf       ; printf function taken from C-language


main:
    mov eax, [a]
    cdq
    idiv dword [b]

    mov [temp], eax

    mov rdi, fmt
    mov esi, [temp]
    xor rax, rax
    call printf

    xor rax, rax
    ret
       

