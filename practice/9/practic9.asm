section .bss
    buf resb 16
    line_buf resb 256
    freq resd 10
    num_n resd 1
    seed resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 16
    int 0x80

    xor eax, eax
    xor ecx, ecx
    mov esi, buf
.parse_loop:
    movzx ebx, byte [esi + ecx]
    cmp bl, 10
    je .parse_done
    cmp bl, 0
    je .parse_done
    cmp bl, '0'
    jb .parse_done
    cmp bl, '9'
    ja .parse_done

    sub bl, '0'
    mov edx, 10
    mul edx
    add eax, ebx

    inc ecx
    jmp .parse_loop
.parse_done:
    mov [num_n], eax

    test eax, eax
    jz exit

    mov ecx, [num_n]
    mov dword [seed], 1

generate_loop:
    push ecx

    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7FFFFFFF
    mov [seed], eax

    mov ebx, 10
    xor edx, edx
    div ebx

    inc dword [freq + edx*4]

    pop ecx
    loop generate_loop

    mov esi, 0
print_loop:
    mov edi, line_buf

    ; 1. Додаємо префікс "X: "
    mov eax, esi
    add al, '0'
    mov [edi], al
    mov byte [edi+1], ':'
    mov byte [edi+2], ' '
    add edi, 3

    mov eax, [freq + esi*4]
    mov ebx, 10
    xor edx, edx
    div ebx
    mov ecx, eax

    test ecx, ecx
    jz .skip_hashes
.hash_loop:
    mov byte [edi], '#'
    inc edi
    loop .hash_loop
.skip_hashes:

    mov byte [edi], ' '
    mov byte [edi+1], '('
    add edi, 2

    mov eax, [freq + esi*4]
    mov ebx, 10
    push 0
.itoa_div:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    test eax, eax
    jnz .itoa_div

.itoa_pop:
    pop eax
    test eax, eax
    jz .itoa_done
    mov [edi], al
    inc edi
    jmp .itoa_pop
.itoa_done:

    mov byte [edi], ')'
    mov byte [edi+1], 10
    add edi, 2

    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, edi
    sub edx, line_buf
    int 0x80
    pop esi

    inc esi
    cmp esi, 10
    jl print_loop

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80