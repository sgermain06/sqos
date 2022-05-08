section .text
global writeu
global sleepu
global exitu
global waitu
global keyboard_readu
global get_total_memoryu
global open_file
global read_file
global close_file
global get_file_size
global fork
global exec
global read_root_directory

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
    sub rsp, 8            ; Allocate 8 bytes on stack   
    mov eax, 3            ; Assign system call ID 3 to eax
    mov [rsp], rdi        ; Move arguments to the new allocated space
    mov rdi, 1            ; Declare that we have 1 argument
    mov rsi, rsp          ; Move the stack pointer to rsi

    int 0x80
    add rsp, 8            ; Free the stack
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

open_file:
    sub rsp, 8
    mov eax, 6

    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret

read_file:
    sub rsp, 24
    mov eax, 7

    mov [rsp], rdi
    mov [rsp+8], rsi
    mov [rsp+16], rdx

    mov rdi, 3
    mov rsi, rsp

    int 0x80

    add rsp, 24
    ret

get_file_size:
    sub rsp, 8
    mov eax, 8

    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret

close_file:
    sub rsp, 8
    mov eax, 9

    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret

fork:
    mov eax, 10
    xor edi, edi

    int 0x80
    ret

exec:
    sub rsp, 8
    mov eax, 11

    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret

read_root_directory:
    sub rsp, 8
    mov eax, 12

    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80

    add rsp, 8
    ret