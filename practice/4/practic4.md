section .bss
; [memory]
buffer resb 16        
out_str resb 16        

section .text
global _start

_start:

mov eax, 3         
mov ebx, 0          
mov ecx, buffer        
mov edx, 16        
int 0x80

    xor eax, eax           
    xor ebx, ebx           
    mov esi, buffer    

.parse_loop:
; [loops]
movzx ecx, byte [esi + ebx]

    cmp cl, 10          
    je .parse_done
    cmp cl, 0             
    je .parse_done

    sub cl, '0'       
    imul eax, 10         
    add eax, ecx          
    
    inc ebx
    jmp .parse_loop

.parse_done:
; [logic] 

    movzx eax, ax        
    mov edi, out_str + 15 
    mov byte [edi], 0    
    mov ecx, 10            

.itoa_loop:
; [loops]
xor edx, edx           
div ecx                

    add dl, '0'            
    dec edi
    mov [edi], dl      
    
    test eax, eax       
    jnz .itoa_loop

    mov edx, out_str + 15
    sub edx, edi          

    mov eax, 4           
    mov ebx, 1          
    mov ecx, edi          
    int 0x80

    push 0xA
    mov ecx, esp
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    pop eax

    mov eax, 1           
    xor ebx, ebx          
    int 0x80