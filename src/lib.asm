section .text
global memset
global memcpy
global memmove
global memcmp

memset:
    cld
    mov ecx, edx
    mov al, sil
    rep stosb
    ret

memcmp:
    cld
    xor eax, eax
    mov ecx, edx
    repe cmpsb
    setnz al
    ret

memcpy:
memmove:
    std                 ; Set direction flag to backwards
    add rdi, rdx        ; Add the length to the destination pointer
    add rsi, rdx        ; Add the length to the source pointer
    sub rdi, 1          ; Subtract 1 from the destination pointer
    sub rsi, 1          ; Subtract 1 from the source pointer

    mov ecx, edx        ; Move the length to ecx for loop
    rep movsb           ; Copy the bytes
    cld                 ; Clear the direction flag
    ret                 ; Return
