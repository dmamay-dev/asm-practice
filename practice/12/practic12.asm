section .bss
    text_buf    resb 200   
    pat_buf     resb 50
    text_len    resd 1
    pat_len     resd 1
    first_pos   resd 1
    count       resd 1
    num_buf     resb 16

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 200
    int 0x80

    mov esi, text_buf
    call my_strlen
    mov [text_len], eax

    mov eax, 3
    mov ebx, 0
    mov ecx, pat_buf
    mov edx, 50
    int 0x80

    mov esi, pat_buf
    call my_strlen
    mov [pat_len], eax

    mov dword [first_pos], -1
    mov dword [count], 0

    cmp dword [pat_len], 0
    je .print_results

    mov eax, [text_len]
    sub eax, [pat_len]
    jl .print_results

    mov ecx, eax
    xor ebx, ebx

.outer_loop:
    cmp ebx, ecx
    jg .print_results

    xor edx, edx

.inner_loop:
    cmp edx, [pat_len]
    je .match_found

    mov esi, text_buf
    add esi, ebx
    add esi, edx
    mov al, byte [esi]

    mov edi, pat_buf
    add edi, edx
    mov ah, byte [edi]

    cmp al, ah
    jne .no_match

    inc edx
    jmp .inner_loop

.match_found:
    cmp dword [first_pos], -1
    jne .skip_first
    mov [first_pos], ebx

.skip_first:
    inc dword [count]
    add ebx, [pat_len]
    jmp .outer_loop

.no_match:
    inc ebx
    jmp .outer_loop

.print_results:
    mov eax, [first_pos]
    call print_int
    call print_newline

    mov eax, [count]
    call print_int
    call print_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

my_strlen:
    xor eax, eax
.str_loop:
    mov cl, byte [esi+eax]
    cmp cl, 0
    je .str_done
    cmp cl, 10
    je .strip_nl
    inc eax
    jmp .str_loop
.strip_nl:
    mov byte [esi+eax], 0
.str_done:
    ret

print_int:
    cmp eax, 0
    jge .positive
    push eax
    mov eax, 4
    mov ebx, 1
    push 45
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax
    pop eax
    neg eax
.positive:
    mov edi, num_buf + 15
    mov byte [edi], 0
    mov ecx, 10
.itoa_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, num_buf + 15
    sub edx, edi
    int 0x80
    ret

print_newline:
    ; [I/O]
    mov eax, 4
    mov ebx, 1
    push 10
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax
    ret