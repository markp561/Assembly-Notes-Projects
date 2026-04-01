; nasm -f elf32 main.asm && ld -m elf_i386 main.o

section     .data
    newline     db 0x0A
    arr         dd 33, -44, 11, 55, -2
    arr_len     equ ($ - arr) / 4

    q           dd 0
    i           dd 0
    j           dd 0
    
    target      dd 33

section     .bss
    buffer      resb 16

section     .text
    global      _start


_start:
                                ; the print array function takes three arguments, a pointer to the base address of the array, the length of the array, and a pointer to the buffer
    push buffer                 ; third argument
    push arr_len                ; second argument
    push arr                    ; first argument
   
    call print_array
    add esp, 12
                                
                                ; the quicksort function takes three argument: a pointer to the base address of the array, and low and a high indices
    mov eax, arr_len            ; the array length needs to be decremented by one before passing it to the function, since the length will be used as a high index 
    dec eax
    push eax                    ; here arr_len-1 is passed as the third argument
    push 0                      ; second argument
    push arr                    ; first argument

    call quicksort
    add esp, 12

    
                                ; here a newline character is printed to seperate the array before and after sorting
    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    
                                ; the print_array function is called again with the same arguments as before, this time to display the sorted array
    push buffer
    push arr_len
    push arr

    call print_array
    add esp, 12

    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80

                                ; the binary_search function takes three arguments: pinter to base address of array, the length of the array, and a pointer to the target
    push target
    mov eax, arr_len
    dec eax
    push eax
    push arr

    call binary_search
    add esp, 12
    
                                ; convert the output of binary search to ascii to be printed
    mov edi, buffer
    call itoa
                                ; print the converted integer                
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov ecx, newline
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80

                                ; exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80


; parameters: array, start index, array length, buffer
print_array:
    push ebp
    mov ebp, esp

    mov edi, [ebp+8]            ; array
    mov ecx, [ebp+12]           ; array length
    mov edx, [ebp+16]           ; buffer

    xor esi, esi
.loop:
    cmp esi, ecx
    jge .end
    mov eax, [edi + esi*4]

    push esi                    ; preserve the counter
    push ecx                    ; preserve the array length
    push edi                    ; preserve the array
    
    mov edi, edx
    push edx
    call itoa
        
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    pop edx
    pop edi                     ; restore the array
    pop ecx                     ; restore the array length
    pop esi                     ; restore the counter
    
    inc esi                     ; increment the counter
    jmp .loop                   ; jump to the next iteration

.end:
    pop ebp                     
    ret




itoa:
    mov ecx, 10                 ; divisor
    xor esi, esi                ; clear esi
    
    mov ebx, eax
    cmp eax, 0
    jge .loop1
    
    neg eax

.loop1:
    cdq
    idiv ecx                    ; divide edx:eax by ecx
    push edx                    ; push the remainder onto the stack
    inc esi                     ; increment the remainder counter
    test eax, eax               ; check if eax is zero
    jne .loop1                  ; if not then jump to next iteration. if it is then go to loop2

    mov eax, edi                ; this will be returned. it is the base address of the buffer

    cmp ebx, 0
    jge .loop2
    
    mov byte [edi], '-'
    inc edi

.loop2:
    pop edx                     ; pop a remainder from the stack
    add dl, '0'                 ; append a '0' to convert it to ascii
    mov [edi], dl               ; mov it into the buffer
    inc edi                     ; increment the buffer so we can append the next digit
    dec esi                     ; decrement the remainder counter
    jnz .loop2                  ; if esi is not zero then jump to next iteration. if it is then the loop is done

    mov byte [edi], 0x0A        ; append a newline character to the buffer
    inc edi                     ; increment the buffer

    mov edx, edi                ; move the address of the buffer into edx
    sub edx, eax                ; calculate length of the buffer by subtracting the current address with the base address that was previously stored in eax

    ret




partition:

    mov [i], esi                       ; move current value of esi (start) into i
    dec dword [i]                      ; decrement i
    
    mov [j], esi                       ; move start into j
    cmp [j], edx                       ; compare j to end
    jl .loop                           ; if j smaller than end enter loop
    jge .end                           ; else go to end of loop
   
.loop:   
    mov ecx, [j]                       ; move j into ecx
    mov eax, [edi + ecx*4]             ; move element of arr at index j into eax
    cmp eax, [edi + edx*4]             ; compare element of arr at index j to element of arr at index end
    jg .continue                       ; if arr[j] > arr[end] do nothing, go to next iteration

    inc dword [i]                      ; else i++ and swap arr[i] with arr[j]
    

    push esi                           ; push esi so we can use it
    mov esi, [i]                       ; move i into esi

                                       ; swap the ith element with the jth element
    mov eax, [edi + esi*4]             ; move ith element of arr into eax
                                       ; xor swapping method
    xor eax, [edi + ecx*4]             ; xor eax with the jth element
    xor [edi + ecx*4], eax             ; xor the jth element with eax
    xor eax, [edi + ecx*4]             ; xor eax with the jth element again

    mov [edi + esi*4], eax             ; move the value of eax into the ith index

    pop esi                            ; pop esi to get back its value

    jmp .continue            

.continue:
        inc dword [j]                  ; increment j to access the next element
        cmp [j], edx                   ; compare j to the end index
        jl .loop                       ; if j is smaller than end, jump to start of loop for the next iteration

.end:
        mov ecx, [i]                   ; move i into ecx
        add ecx, 1                     ; add 1 to ecx
        
    
                                       ; swapping i+1 element with end element
        mov eax, [edi + ecx*4]         ; move element of arr at index i into eax
                                       ; same xor swap as before but with edx register that contains the end index
        xor eax, [edi + edx*4]  
        xor [edi + edx*4], eax 
        xor eax, [edi + edx*4]

        mov [edi + ecx*4], eax         ; move eax into i+1 index of arr


        mov eax, [i]                   ; move i into eax
        add eax, 1                     ; add 1 to eax
        ret                            ; return (eax will be returned)




quicksort:
    push ebp
    mov ebp, esp
    
    mov edi, [ebp+8]
    mov esi, [ebp+12]
    mov edx, [ebp+16]

    cmp esi, edx                       ; compare esi (start) to edx (end)
    jge .base_case                     ; if start is greater than or equal to then we need to exit
    

    call partition

                                       ; left partition
    push edx                           ; save edx (end)
    mov edx, eax                       ; move the return value from partition call to edx
    dec edx                            ; decrement edx
    
    push edx
    push esi
    push edi

    call quicksort                     ; call quicksort on left partition
    add esp, 12

    pop edx                            ; pop back edx to restore value from before recuesive call

    push esi                           ; save esi by pushing to stack (start)
    mov esi, eax                       ; move the return value from partition call to esi
    inc esi                            ; increment esi

    push edx
    push esi
    push edi

    call quicksort                     ; call quicksort on right partition
    add esp, 12

    pop esi                            ; pop back esi to restore value from before recursive call
.base_case:                            ; in the base case we just need to exit the function
    pop ebp
    ret


binary_search:
    push ebp
    mov ebp, esp
    
    mov edi, [ebp+8]               ; arr
    mov edx, [ebp+12]              ; arr_len
    mov ebx, [ebp+16]              ; target
    mov ebx, [ebx]

    xor esi, esi
    xor ecx, ecx
.loop:
    cmp esi, edx                   ; Compare low index to high index
    jg .not_found                  ; If low is greater than high, then exit by jumping to not_found

    mov eax, esi                   ; move low index to rax
    add eax, edx                   ; add high to low
    shr eax, 1                     ; shift right by 1 bit to divide by 2
    mov ecx, eax                   ; mov the quotient into rcx

    mov eax, [edi + ecx*4]         ; Move element at index mid into eax

                                   ; The following three comparisons are made:
    cmp ebx, eax           
    jg .greater_than               ; target > arr[mid]                
    jl .less_than                  ; target < arr[mid]
    je .found                      ; target == arr[mid]

.greater_than:                     ; target is greater than arr[mid] so we update low to be mid+1
    mov esi, ecx
    inc esi
    jmp .loop                      ; Jump to the beginning of the binary_search section

.less_than:                        ; target is less than arr[mid] so we update high to be mid - 1
    mov edx, ecx               
    dec edx                     
    jmp .loop                      ; Jump to the beginning of the binary_search section

.found:                           
    mov eax, ecx                   ; move the index into eax to be returned
    pop ebp
    ret                            ; target was found so we can exit the function and return the index where it was found

.not_found:                        ; the loop ended and the target was not found
    mov eax, -1
    pop ebp
    ret                            ; since target was not found we can exit the function and return -1 as an indication that the search was unsuccessful

