section .data
; [memory]
msg_min db "min: ", 0
msg_max db "max: ", 0
msg_idx db " (index: ", 0
msg_end db ")", 10, 0
space   db " ", 0
newline db 10, 0

section .bss
; [memory]
array   resd 50       
n_val   resd 1       
input   resb 16
out_buf resb 16

section .text
global _start

_start:

mov eax, 3
mov ebx, 0
mov ecx, input
mov edx, 16
int 0x80

.fill_loop:
cmp ecx, [n_val]
je .print_init

.print_init:

xor ecx, ecx
.print_loop:
cmp ecx, [n_val]
je .find_minmax

.find_minmax:
mov edx, newline
call print_str

.cmp_loop:
cmp ecx, [n_val]
je .results

.not_min:
; Перевірка на max
cmp esi, edx
jbe .next_iter
mov edx, esi
mov edi, ecx
.next_iter:
inc ecx
jmp .cmp_loop

.results:

push edx                
push edi                

atoi:
xor eax, eax
.l: movzx edx, byte [esi]
cmp dl, '0'
jb .d
cmp dl, '9'
ja .d
sub dl, '0'
imul eax, 10
add eax, edx
inc esi
jmp .l
.d: ret

print_num:
pusha
mov edi, out_buf + 15
mov byte [edi], 0
mov ebx, 10
.il: xor edx, edx
div ebx
add dl, '0'
dec edi
mov [edi], dl
test eax, eax
jnz .il
mov edx, edi
call print_str
popa
ret

print_str:
pusha
mov edi, edx
xor edx, edx
.len: cmp byte [edi+edx], 0
je .w
inc edx
jmp .len
.w: mov ecx, edi
mov eax, 4
mov ebx, 1
int 0x80
popa
ret