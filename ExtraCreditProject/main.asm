; nasm -f elf64 main.asm && gcc -no-pie main.o

default rel

section     .data
    fmt         db "%d", 10, 0

    arr         dq 2, 1, 5, 4, 3
    arr_len     equ ($ - arr) / 8

    q           dq 0
    i           dq 0
    j           dq 0
        
    target      dq 1
    mid         dq 0
    
    
section     .text
    global      main
    extern      printf

main:

    mov rdi, arr
    mov rsi, 0
    mov rdx, arr_len
    dec rdx
    call quicksort


    mov rdi, arr
    mov rsi, 0
    mov rdx, arr_len
    dec rdx
    call print_array


    mov rdi, arr
    mov rsi, 0
    mov rdx, arr_len
    dec rdx
    call binary_search

    
    mov rdi, fmt
    mov rsi, rax
    xor rax, rax
    call printf
    
    xor rax, rax
    ret


print_array:

    cmp rsi, rdx
    jg print_array_end

    mov rax, [rdi + rsi*8]

    push rsi
    push rdi
    push rdx

    mov rdi, fmt
    mov rsi, rax
    xor rax, rax
    call printf

    pop rdx
    pop rdi
    pop rsi
    
    inc rsi
    jmp print_array
    
print_array_end:
    ret


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





binary_search:
    
    cmp rsi, rdx                ; Compare low index to high index
    jg binary_search_end        ; If low is greater than high, then exit by jumping to binary_search_end


    mov rax, rdx                ; Move high index to eax
    add rax, rsi                ; Add low to high
    cdq                         ; Extend eax to edx:eax to prepare for division

    mov rcx, 2                  ; Move constant value 2 into ecx
    idiv rcx                    ; Divide by 2
    mov [mid], rax              ; Move the quotient into mid index


    mov rcx, [mid]              ; Move mid index into ecx
    mov rax, [rdi + rcx*4]      ; Move element at index mid into eax

                                ; The following three comparisons are made:
    cmp [target], rax           
    jg greater_than             ; target > arr[mid]                
    jl less_than                ; target < arr[mid]
    je found                    ; target == arr[mid]

greater_than:
                            ; low = mid + 1
    inc dword [mid]         ; Increment mid by 1
    mov rax, [mid]          ; Move mid into eax
    mov rsi, rax          ; Move value stored in eax into low
    jmp binary_search ; Jump to the beginning of the binary_search section

less_than:
                            ; high = mid - 1
    dec dword [mid]         ; Decrement mid by 1
    mov rax, [mid]          ; Move mid into eax
    mov rdx, rax         ; Move value stored in eax into high
    jmp binary_search       ; Jump to the beginning of the binary_search section


found:
                            ; target found
    mov rax, [mid]          ; Move mid into eax

    jmp binary_search_end   ; target was found so we can exit the function and return the index where it was found
    
binary_search_end:
    ret        


