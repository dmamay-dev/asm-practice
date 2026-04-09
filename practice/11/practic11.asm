section .bss
    input_buf resb 16
    tree_buf  resb 64
    h_val     resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    xor eax, eax
    xor ebx, ebx
    mov esi, input_buf
    mov edi, 10
.parse_loop:
    mov bl, byte [esi]
    cmp bl, 10
    je .parse_done
    cmp bl, '0'
    jl .parse_done
    cmp bl, '9'
    jg .parse_done
    sub bl, '0'

    mov ecx, eax
    mov eax, edi
    mul ecx
    add eax, ebx

    inc esi
    jmp .parse_loop
.parse_done:
    cmp eax, 5
    jge .check_max
    mov eax, 5
    jmp .store_h
.check_max:
    cmp eax, 25
    jle .store_h
    mov eax, 25
.store_h:
    mov [h_val], eax

    mov ecx, 1
.tree_outer_loop:
    push ecx
    mov edi, tree_buf
    mov eax, [h_val]
    sub eax, ecx
    cmp eax, 0
    jle .spaces_done
    mov edx, eax
.spaces_loop:
    mov byte [edi], ' '
    inc edi
    dec edx
    jnz .spaces_loop
.spaces_done:
    mov eax, ecx
    shl eax, 1
    dec eax
    mov edx, eax
.stars_loop:
    mov byte [edi], '*'
    inc edi
    dec edx
    jnz .stars_loop

    mov byte [edi], 10
    inc edi

    mov eax, edi
    sub eax, tree_buf
    mov ebx, tree_buf
    call print_line

    pop ecx
    inc ecx
    cmp ecx, [h_val]
    jle .tree_outer_loop

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_line:

    push eax
    push ebx
    push ecx
    push edx

    mov edx, eax
    mov ecx, ebx
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret