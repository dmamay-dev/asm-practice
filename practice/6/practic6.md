section .data

    msg_signed   db "SIGNED: ", 0
    msg_unsigned db "UNSIGNED: ", 0
    msg_max_s    db "max_signed: ", 0
    msg_max_u    db "max_unsigned: ", 0
    rel_lt       db "a < b", 10, 0
    rel_gt       db "a > b", 10, 0
    rel_eq       db "a = b", 10, 0
    newline      db 10

section .bss
; [memory]
buf_a    resb 32
buf_b    resb 32
val_a    resd 1
val_b    resd 1
out_buf  resb 32

section .text
global _start

_start:
mov eax, 3
mov ebx, 0
mov ecx, buf_a
mov edx, 32
int 0x80

    mov esi, buf_a
    call atoi
    mov [val_a], eax

    mov eax, 3
    mov ebx, 0
    mov ecx, buf_b
    mov edx, 32
    int 0x80

    mov esi, buf_b
    call atoi
    mov [val_b], eax

    mov edx, msg_signed
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jg .s_gt
    jl .s_lt
    je .s_eq
.s_gt:
mov edx, rel_gt
jmp .s_print
.s_lt:
mov edx, rel_lt
jmp .s_print
.s_eq:
mov edx, rel_eq
.s_print:
call print_str

    mov edx, msg_unsigned
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    ja .u_gt
    jb .u_lt
    je .u_eq
.u_gt:
mov edx, rel_gt
jmp .u_print
.u_lt:
mov edx, rel_lt
jmp .u_print
.u_eq:
mov edx, rel_eq
.u_print:
call print_str

    mov edx, msg_max_s
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jg .max_s_a
    mov eax, ebx
.max_s_a:
call print_signed_num

    mov edx, msg_max_u
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    ja .max_u_a
    mov eax, ebx
.max_u_a:
call print_unsigned_num

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
xor eax, eax
xor ecx, ecx
movzx edx, byte [esi]
cmp dl, '-'
jne .loop
inc ecx
inc esi
.loop:
movzx edx, byte [esi]
cmp dl, '0'
jb .done
cmp dl, '9'
ja .done
sub dl, '0'
imul eax, 10
add eax, edx
inc esi
jmp .loop
.done:
test ecx, ecx
jz .exit
neg eax
.exit:
ret

print_str:
push eax
push ebx
push ecx
push edx
mov edi, edx
xor edx, edx

    cmp byte [edi + edx], 0
    je .write
    inc edx
    jmp .len_loop
.write:
mov ecx, edi
mov eax, 4
mov ebx, 1
int 0x80
pop edx
pop ecx
pop ebx
pop eax
ret

print_signed_num:
test eax, eax
jns print_unsigned_num
push eax
mov edx, .minus
call print_str
pop eax
neg eax
jmp print_unsigned_num
.minus db "-", 0

print_unsigned_num:
mov edi, out_buf + 31
mov byte [edi], 0
mov byte [edi-1], 10
sub edi, 1
mov ebx, 10
.loop:
xor edx, edx
div ebx
add dl, '0'
dec edi
mov [edi], dl
test eax, eax
jnz .loop
mov edx, edi
call print_str
ret