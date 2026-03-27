; nasm -f elf64 main.asm && gcc -no-pie main.o && ./a.out

default rel

section     .data
    fmt     db "%d", 10, 0

    arr     dq 2, 1, 5, 4, 3
    arr_len equ ($ - arr) / 8

    q       dq 0     
    i       dq 0
    j       dq 0

section     .text
    global      main
    extern      printf


main:

    mov rdi, arr        ; base address of arr
    mov rsi, 0          ; start index is 0
    mov rdx, arr_len    ; end index is the length of the array - 1
    dec rdx             

    call quicksort      ; sort the array
    call print_array    ; print the array

    xor rax, rax        ; exit system call
    ret                 

print_array:
    mov rcx, 0          
    jmp begin

    begin: 
        cmp rcx, arr_len
        jge print_array_end

        mov rax, [rdi + rcx*8]
        mov rsi, rax

        push rdi
        mov rdi, fmt
        xor rax, rax
        push rcx
        call printf
        pop rcx
        pop rdi
        
        inc rcx
        jmp begin
    
print_array_end:
    ret


; takes array, low index, high index
partition:

    push rsi            ; push current value of rsi (start) onto stack
    dec rsi             ; decrement rsi (start - 1)
    mov [i], rsi        ; move start - 1 to i
    pop rsi             ; pop rsi to get (start) back
    

    mov [j], rsi        ; move start into j
    mov rax, [j]
    cmp rax, rdx        ; compare j to end
    jl loop             ; if j smaller than end enter loop
    jge partition_end   ; else go to end of loop
   
    loop:   
        mov rcx, [j]            ; move j into rcx
        mov rax, [rdi + rcx*8]  ; move element of arr at index j into rax
        cmp rax, [rdi + rdx*8]  ; compare element of arr at index j to element of arr at index end
        jg continue             ; if A[j] > A[end] do nothing, go to next iteration
    
        inc qword [i]           ; else i++ and swap A[i] with A[j]
        
    
        push rsi                ; push rsi so we can use it
        mov rsi, [i]            ; move i into rsi

        mov rax, [rdi + rsi*8]  
        
        xor rax, [rdi + rcx*8]
        xor [rdi + rcx*8], rax
        xor rax, [rdi + rcx*8]
    
        mov [rdi + rsi*8], rax

        pop rsi                 ; pop rsi to get back its value

        jmp continue
        continue:
            inc qword [j]       ; increment j
            mov rax, [j]
            cmp rax, rdx
            jl loop             ; jump to start of loop

    partition_end:
        mov rcx, [i]            ; move i into rcx
        add rcx, 1              ; add 1 to rcx
        

        mov rax, [rdi + rcx*8]  ; move element of arr at index i into rax

        xor rax, [rdi + rdx*8]
        xor [rdi + rdx*8], rax 
        xor rax, [rdi + rdx*8]

        mov [rdi + rcx*8], rax  ; move rax into end index of arr


        mov rax, [i]            ; move i into rax
        add rax, 1              ; add 1 to rax
        ret                     ; return (rax will be returned)

    
; takes array, low index, high index
quicksort:
    
    cmp rsi, rdx        ; compare rsi (start) to rdx (end)
    jge base_case      ; if start is greater than or equal to then we need to exit
    

    call partition

    mov [q], rax        ; move result of partition to q

                        ; left partition
    push rdx            ; save rdx (end)
    mov rdx, [q]        ; move q into rdx
    dec rdx             ; decrement rdx
    
    call quicksort      ; call quicksort on left partition
    
    pop rdx             ; pop back rdx to restore value from before recursive call

    push rsi            ; save rsi by pushing to stack (start)
    mov rsi, [q]        ; move q into rsi
    inc rsi             ; increment rsi

    call quicksort      ; call quicksort on right partition

    pop rsi             ; pop back rsi to restore value from before recursive call

base_case:             ; in the base case we just need to exit the function
    ret

