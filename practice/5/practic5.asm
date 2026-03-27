section .data
    ; [memory]
    newline db 10
    K dd 5

section .bss
    ; [memory]
    input_buf resb 16
    output_buf resb 16

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    mov esi, input_buf
    call atoi

    mov ebx, 10
    xor ecx, ecx
    xor edi, edi

    test eax, eax
    jz .done_loop

    xor edx, edx
    div ebx

    add ecx, edx
    inc edi
    jmp .split_loop

    push edi
    push ecx

    pop eax
    push eax
    call print_num

    pop ebx
    pop eax
    push ebx
    call print_num


    pop eax
    add eax, [K]
    call print_num

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
.next_digit:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done

    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .next_digit
.done:
    ret

print_num:

    mov edi, output_buf + 15
    mov byte [edi], 10
    mov ebx, 10
.itoa_loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, output_buf + 16
    sub edx, edi
    int 0x80
    ret