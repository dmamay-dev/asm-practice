section .bss
    input_buf   resb 16
    x_val       resd 1
    num_buf     resb 16
    bin_out_buf resb 40

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

    mov [x_val], eax

    mov ecx, 31
    mov esi, bin_out_buf
.bin_loop:

    mov ebx, 1
    shl ebx, cl

    mov eax, [x_val]
    and eax, ebx
    jz .is_zero
    mov byte [esi], '1'
    jmp .done_bit
.is_zero:
    mov byte [esi], '0'
.done_bit:
    inc esi

    test cl, 3
    jnz .no_space
    test cl, cl
    jz .no_space
    mov byte [esi], ' '
    inc esi
.no_space:
    dec ecx
    jns .bin_loop

    mov byte [esi], 10
    inc esi
    mov eax, 4
    mov ebx, 1
    mov edx, esi
    sub edx, bin_out_buf
    mov ecx, bin_out_buf
    int 0x80

    mov eax, [x_val]
    mov ecx, 32
    xor edx, edx
.pop_loop:
    mov ebx, eax
    ; [logic]
    and ebx, 1
    ; [math]
    add edx, ebx
    shr eax, 1
    dec ecx
    jnz .pop_loop

    mov eax, edx
    call print_uint

    mov eax, [x_val]        ; [memory]

    ; [logic] - Set p=4: x |= (1 << 4)
    mov ebx, 1
    shl ebx, 4
    or eax, ebx

    ; [logic] - Set q=8: x |= (1 << 8)
    mov ebx, 1
    shl ebx, 8
    or eax, ebx

    ; [logic] - Clear r=2: x &= ~(1 << 2)
    mov ebx, 1
    shl ebx, 2
    not ebx
    and eax, ebx

    call print_uint

    ; [I/O] - Системний виклик exit(0)
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_uint:
    mov edi, num_buf + 15
    mov byte [edi], 10
    mov ecx, 10
.itoa_loop:
    ; [math]
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    ; [logic]
    test eax, eax
    ; [loops]
    jnz .itoa_loop

    ; [I/O]
    mov eax, 4
    mov ebx, 1
    mov edx, num_buf + 16
    sub edx, edi
    mov ecx, edi
    int 0x80
    ret