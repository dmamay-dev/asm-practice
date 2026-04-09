section .bss
    input_buf   resb 4096
    arr_orig    resd 200
    arr_rev     resd 200
    n_val       resd 1
    num_buf     resb 16

section .data
    msg_yes     db "PALINDROME: YES", 10
    len_yes     equ $ - msg_yes
    msg_no      db "PALINDROME: NO", 10
    len_no      equ $ - msg_no

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 4096
    int 0x80

    mov esi, input_buf

    call get_next_int

    cmp eax, 5
    jge .check_max
    mov eax, 5
    jmp .store_n
.check_max:
    cmp eax, 200
    jle .store_n
    mov eax, 200
.store_n:
    mov [n_val], eax
    mov ecx, [n_val]
    xor ebx, ebx
.read_arr_loop:
    push ecx
    push ebx
    call get_next_int
    pop ebx
    pop ecx
    mov [arr_orig + ebx*4], eax
    inc ebx
    dec ecx
    jnz .read_arr_loop

    cld
    mov esi, arr_orig
    mov edi, arr_rev
    mov ecx, [n_val]
    rep movsd

    mov ecx, [n_val]
    shr ecx, 1
    test ecx, ecx
    jz .print_orig

    xor ebx, ebx
    mov edx, [n_val]
    dec edx
.reverse_loop:
    mov eax, [arr_rev + ebx*4]
    mov edi, [arr_rev + edx*4]
    mov [arr_rev + ebx*4], edi
    mov [arr_rev + edx*4], eax

    inc ebx
    dec edx
    dec ecx
    jnz .reverse_loop

.print_orig:
    mov ecx, [n_val]
    xor ebx, ebx
.print_orig_loop:
    push ecx
    push ebx
    mov eax, [arr_orig + ebx*4]
    call print_int
    call print_space
    pop ebx
    pop ecx
    inc ebx
    dec ecx
    jnz .print_orig_loop
    call print_newline

    mov ecx, [n_val]
    xor ebx, ebx
.print_rev_loop:
    push ecx
    push ebx
    mov eax, [arr_rev + ebx*4]
    call print_int
    call print_space
    pop ebx
    pop ecx
    inc ebx
    dec ecx
    jnz .print_rev_loop
    call print_newline

    mov ecx, [n_val]
    xor ebx, ebx
.palindrome_loop:
    mov eax, [arr_orig + ebx*4]
    cmp eax, [arr_rev + ebx*4]
    jne .not_palindrome
    inc ebx
    dec ecx
    jnz .palindrome_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_yes
    mov edx, len_yes
    int 0x80
    jmp .exit_prog

.not_palindrome:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_no
    mov edx, len_no
    int 0x80

.exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80

get_next_int:
    xor edx, edx
.skip_whitespace:
    mov cl, [esi]
    test cl, cl
    jz .done_read
    cmp cl, ' '
    je .next_char
    cmp cl, 10
    je .next_char
    cmp cl, 9
    je .next_char
    cmp cl, '-'
    je .is_negative
    cmp cl, '0'
    jl .next_char
    cmp cl, '9'
    jg .next_char
    jmp .read_digits
.is_negative:
    mov edx, 1
    inc esi
    jmp .read_digits
.next_char:
    inc esi
    jmp .skip_whitespace

.read_digits:
    xor eax, eax
    mov edi, 10
.digit_loop:
    mov cl, [esi]
    cmp cl, '0'
    jl .apply_sign
    cmp cl, '9'
    jg .apply_sign
    sub cl, '0'

    push edx
    mul edi
    pop edx
    movzx ecx, cl
    add eax, ecx

    inc esi
    jmp .digit_loop
.apply_sign:
    test edx, edx
    jz .done_read
    neg eax
.done_read:
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

print_space:
    mov eax, 4
    mov ebx, 1
    push 32
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax
    ret

print_newline:
    mov eax, 4
    mov ebx, 1
    push 10
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax
    ret