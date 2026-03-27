; nasm -f elf64 main.asm && gcc -no-pie main.o

default rel

section     .data
    fmt db "%d", 10, 0
    n   dd 3


section     .text
    global      main
    extern      printf


main:

    
    mov rdi, [n]

    call factorial


    mov rdi, fmt
    mov rsi, rax

    xor rax, rax
    call printf

    xor rax, rax
    ret
    

factorial:

    cmp rdi, 1
    jle .base_case

    push rdi

    dec rdi
    call factorial

    pop rdi
    imul rax, rdi
    ret
    

.base_case:
    mov rax, 1
    ret




; Tracing the recursive calls for n = 3
; n = 3
; rdi = 3
; rdi <= 1 FALSE
; push rdi       --> rdi = 3 is in the stack
; dec rdi        --> rdi = 2
; call factorial with rdi = 2
; rdi <= 1 FALSE
; push rdi       --> rdi = 2 is in the stack
; dec rdi        --> rdi = 1
; call factorial with rdi = 1
; rdi <= 1 TRUE
; jump to .base_case
; store 1 in rax
; return from base case
; 
; pop rdi        --> rdi is equal to 2 now
; imul rax, rdi  --> rax is 1 (from the base case) rdi is 2
; rax is 2
; return with rax = 2
; 
; pop rdi        --> rdi is equal to 3 now
; imul rax, rdi  --> rax is 2 (from previous call) rdi is 3
; rax = 6
; return with rax = 6
; done

