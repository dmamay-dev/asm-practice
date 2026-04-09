section .bss
    input_buf resb 4096
    arr       resd 100
    n_val     resd 1
    num_buf   resb 16

section .data
    msg_orig  db "ORIG: ", 0
    msg_sort  db 10, "SORTED: ", 0
    msg_med   db 10, "MEDIAN: ", 0

section .text
    global _start

_start:
    mov eax, 3
    xor ebx, ebx
    mov ecx, input_buf
    mov edx, 4096
    int 0x80
    mov esi, input_buf

    call get_int
    cmp eax, 10
    jge .chk_max
    mov eax, 10
    jmp .save_n
.chk_max:
    cmp eax, 100
    jle .save_n
    mov eax, 100
.save_n:
    mov [n_val], eax
    mov ecx, eax
    xor ebx, ebx
.read_arr:
    push ecx
    push ebx
    call get_int
    pop ebx
    pop ecx
    mov [arr + ebx*4], eax
    inc ebx
    dec ecx
    jnz .read_arr

    mov esi, msg_orig
    call print_str
    call print_arr

    mov ecx, [n_val]
    dec ecx
    xor ebx, ebx
.sort_out:
    cmp ebx, ecx
    jge .sort_done
    mov edx, ebx
    lea edi, [ebx+1]
.sort_in:
    cmp edi, [n_val]
    jge .swap
    mov eax, [arr + edi*4]
    cmp eax, [arr + edx*4]
    jge .skip
    mov edx, edi
.skip:
    inc edi
    jmp .sort_in
.swap:
    cmp edx, ebx
    je .nxt_out
    mov eax, [arr + ebx*4]
    mov edi, [arr + edx*4]
    mov [arr + ebx*4], edi
    mov [arr + edx*4], eax
.nxt_out:
    inc ebx
    jmp .sort_out
.sort_done:

    mov esi, msg_sort
    call print_str
    call print_arr

    mov esi, msg_med
    call print_str

    mov eax, [n_val]
    dec eax
    shr eax, 1
    mov eax, [arr + eax*4]
    call print_int

    push 10
    mov eax, 4
    mov ebx, 1
    mov ecx, esp
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

get_int:
    xor edx, edx
.skip_ws:
    mov cl, [esi]
    test cl, cl
    jz .done
    cmp cl, '-'
    je .neg
    cmp cl, '0'
    jge .read
    inc esi
    jmp .skip_ws
.neg:
    mov edx, 1
    inc esi
.read:
    xor eax, eax
    mov edi, 10
.dig:
    mov cl, [esi]
    cmp cl, '0'
    jl .apply
    cmp cl, '9'
    jg .apply
    sub cl, '0'
    push edx
    mul edi
    pop edx
    movzx ecx, cl
    add eax, ecx
    inc esi
    jmp .dig
.apply:
    test edx, edx
    jz .done
    neg eax
.done:
    ret

print_int:
    cmp eax, 0
    jge .pos
    push eax
    mov eax, 4
    mov ebx, 1
    push 45
    mov ecx, esp
    mov edx, 1
    int 0x80
    add esp, 4
    pop eax
    neg eax
.pos:
    mov edi, num_buf + 15
    mov byte [edi], 0
    mov ecx, 10
.itoa:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    lea edx, [num_buf + 15]
    sub edx, edi
    int 0x80
    ret

print_arr:
    mov ecx, [n_val]
    xor ebx, ebx
.arr_l:
    push ecx
    push ebx
    mov eax, [arr + ebx*4]
    call print_int
    mov eax, 4
    mov ebx, 1
    push 32
    mov ecx, esp
    mov edx, 1
    int 0x80
    add esp, 4
    pop ebx
    pop ecx
    inc ebx
    dec ecx
    jnz .arr_l
    ret

print_str:
    mov ecx, esi
    xor edx, edx
.len_l:
    cmp byte [esi+edx], 0
    je .p_str
    inc edx
    jmp .len_l
.p_str:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret