; nasm -f elf64 main.asm && gcc -no-pie main.o


default rel

section     .data   

    fmt db "%d", 10, 0
    a   dd 5
    b   dd 10


section     .text
    global      main
    extern      printf

main:
    
    mov rdi, 1      ; rdi register is used for 1st integer argument 
    mov rsi, 2      ; rdi register is used for 2nd integer argument

    push rdi        ; push value to stack to save it
    push rsi        ; push value to stack to save it

    mov rdi, [a]    ; now move a into rdi as the first argument for the function
    mov rsi, [b]    ; move b into rsi as the second argument for the function

    call add        ; call the function add
    
    mov rdi, fmt    ; formatting for printf function
    mov rsi, rax    ; move rax, the returned value from the function call, into rsi to be printed

    xor rax, rax    ; function call for printf function?
    call printf     ; call printf


    pop rdi         ; pop rdi from the stack
    pop rsi         ; pop rsi from the stack

    call add        ; call add function

    mov rdi, fmt    ; same setup for printf function
    mov rsi, rax    
    xor rax, rax
    call printf 

    xor rax, rax    ; exit syscall
    ret             


add:
    
    mov rax, rdi    ; move the first argument into rax
    add rax, rsi    ; add rsi to the first argument

    ret             ; return

