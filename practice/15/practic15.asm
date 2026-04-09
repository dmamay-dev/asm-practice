section .bss
    input_buf resb 16
    num_buf   resb 16
    calls     resd 1
section .data
    msg_fact  db "FACT: ", 0
    msg_calls db 10, "CALLS: ", 0
section .text
    global _start
_start:
    mov eax, 3
    xor ebx, ebx
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    mov esi, input_buf
    call get_int
    cmp eax, 0
    jge .check_max
    mov eax, 0
    jmp .calc_fact
.check_max:
    cmp eax, 12
    jle .calc_fact
    mov eax, 12
.calc_fact:
    mov dword [calls], 0
    call fact
    push eax
    mov esi, msg_fact
    call print_str
    pop eax
    call print_uint
    mov esi, msg_calls
    call print_str
    mov eax, [calls]
    call print_uint
    push 10
    mov eax, 4
    mov ebx, 1
    mov ecx, esp
    mov edx, 1
    int 0x80
    add esp, 4
    mov eax, 1
    xor ebx, ebx
    int 0x80
fact:
    push ebp
    mov ebp, esp
    push ebx
    inc dword [calls]
    cmp eax, 1
    jle .base_case
    push eax
    dec eax
    call fact
    pop ebx
    mul ebx
    jmp .end
.base_case:
    mov eax, 1
.end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret
get_int:
    xor eax, eax
.skip_ws:
    mov cl, [esi]
    test cl, cl
    jz .done
    cmp cl, '0'
    jge .read
    inc esi
    jmp .skip_ws
.read:
    mov edi, 10
.dig:
    mov cl, [esi]
    cmp cl, '0'
    jl .done
    cmp cl, '9'
    jg .done
    sub cl, '0'
    mul edi
    movzx ecx, cl
    add eax, ecx
    inc esi
    jmp .dig
.done:
    ret
print_uint:
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