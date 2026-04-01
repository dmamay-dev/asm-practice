section .data
    newline db 0xA
    space   db ' '
    minus   db '-'
    msg_not_found db "-1", 0xA

section .bss
    array       resd 100
    n           resd 1
    target      resd 1
    buffer      resb 32
    out_buf     resb 32
    found_indices resd 100

section .text
    global _start

_start:
    call read_int
    mov [n], eax

    mov ecx, 0
fill_loop:
    cmp ecx, [n]
    je read_target
    push ecx
    call read_int
    pop ecx
    mov [array + ecx*4], eax
    inc ecx
    jmp fill_loop

read_target:
    call read_int
    mov [target], eax

    mov ecx, 0
    mov edx, 0
    mov ebx, -1

search_loop:
    cmp ecx, [n]
    je print_results

    mov eax, [array + ecx*4]
    cmp eax, [target]
    jne next_iter

    inc edx
    cmp edx, 1
    jne store_index
    mov ebx, ecx

store_index:

    push edx
    mov eax, edx
    dec eax
    mov [found_indices + eax*4], ecx
    pop edx

next_iter:
    inc ecx
    jmp search_loop

print_results:
    push edx
    push ebx
    mov eax, ebx
    cmp eax, -1
    je print_minus_one
    call write_int
    jmp after_first_idx

print_minus_one:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_not_found
    mov edx, 3
    int 0x80

    pop ebx
    pop edx
    jmp exit_prog

after_first_idx:
    call print_newline
    pop ebx
    pop edx


    push edx
    mov eax, edx
    call write_int
    call print_newline
    pop edx

    mov ecx, 0
print_indices_loop:
    cmp ecx, edx
    je final_newline

    push ecx
    push edx
    mov eax, [found_indices + ecx*4]
    call write_int

    pop edx
    pop ecx
    inc ecx
    cmp ecx, edx
    je print_indices_loop

    push ecx
    push edx
    call print_space
    pop edx
    pop ecx
    jmp print_indices_loop

final_newline:
    call print_newline

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80

read_int:
    push ebx
    push ecx
    push edx
    xor eax, eax
    xor ecx, ecx
.next_char:
    push eax
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax

    cmp eax, 0
    jl .done

    movzx ecx, byte [buffer]
    cmp ecx, 0xA
    je .done
    cmp ecx, ' '
    je .done
    cmp ecx, '0'
    jl .next_char
    cmp ecx, '9'
    jg .next_char

    sub ecx, '0'
    imul eax, 10
    add eax, ecx
    jmp .next_char
.done:
    pop edx
    pop ecx
    pop ebx
    ret

write_int:
    push eax
    push ebx
    push ecx
    push edx

    mov edi, out_buf + 31
    mov byte [edi], 0
    mov ebx, 10

    test eax, eax
    jnz .convert
    dec edi
    mov byte [edi], '0'
    jmp .print

.convert:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .convert

.print:
    mov ecx, edi
    mov eax, out_buf + 32
    sub eax, edi
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

print_space:
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    ret