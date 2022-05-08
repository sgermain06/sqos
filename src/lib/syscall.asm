section .text
global writeu
global sleepu
global exitu
global waitu
global keyboard_readu
global get_total_memoryu

writeu:
    sub rsp, 16             ; Allocate 16 bits on the stack
    xor eax, eax            ; Zero-out rax

    mov [rsp], rdi          ; Move arguments to the new allocated space
    mov [rsp+8], rsi        

    mov rdi, 2
    mov rsi, rsp
    int 0x80

    add rsp, 16
    ret

sleepu:
    sub rsp, 8              ; Allocate 8 bytes on stack
    mov eax, 1
    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret

exitu:
    mov eax, 2
    mov rdi, 0

    int 0x80
    ret

waitu:
    mov eax, 3
    mov rdi, 0

    int 0x80
    ret

keyboard_readu:
    mov eax, 4
    xor edi, edi

    int 0x80
    ret

get_total_memoryu:
    mov eax, 5
    xor edi, edi

    int 0x80
    ret