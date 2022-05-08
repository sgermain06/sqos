section .data
global Tss

Gdt64:
    dq 0                    ; D L     P DPL  1  1   C
    dq 0x0020980000000000   ; 0 1     1 00   1  1   0
    dq 0x0020F80000000000   ; 0 1     1 11   1  1   0
    dq 0x0000F20000000000   ; 0 1     1 11   1  0   0 1 0 - Ring 3 data segment
TssDesc:
    dw TssLen - 1
    dw 0
    db 0                    ; P DPL TYPE
    db 0x89                 ; 1 00  01001 (64-bit TSS)
    db 0
    db 0
    dq 0

Gdt64Len:   equ $-Gdt64
Gdt64Ptr:   dw Gdt64Len-1
            dq Gdt64

Tss:
    dd 0
    dq 0xffff800000190000
    times 88 db 0
    dd TssLen

TssLen: equ $-Tss
section .text
extern KMain
global start

start:
    mov rax, Gdt64Ptr
    lgdt [rax]

SetTss:
    mov rax, Tss
    mov rdi, TssDesc
    mov [rdi + 2], ax
    shr rax, 16
    mov [rdi + 4], al
    shr rax, 8
    mov [rdi + 7], al
    shr rax, 8
    mov [rdi + 8], eax

    mov ax, 0x20
    ltr ax

PITInit:
    ; Set up the Programmable Interval Timer
    ; Channels:
    ; 0x40: Channel 0 data port (read/write)
    ; 0x41: Channel 1 data port (read/write)
    ; 0x42: Channel 2 data port (read/write)
    ; 0x43: Mode/Command register (write only, read is ignored)

    ; Bits for command:
    ;   0:   BCD/Binary mode. 0 = 16-bit binary, 1 = 4-digit BCD
    ;   1-3: Operating mode:
    ;           0 0 0 = Mode 0 (interrupt on terminal count)
    ;           0 0 1 = Mode 1 (hardware re-triggerable one-shot)
    ;           0 1 0 = Mode 2 (rate generator)
    ;           0 1 1 = Mode 3 (square wave generator)
    ;           1 0 0 = Mode 4 (software triggered strobe)
    ;           1 0 1 = Mode 5 (hardware triggered strobe)
    ;           1 1 0 = Mode 2 (rate generator, same as 011b)
    ;           1 1 1 = Mode 3 (square wave generator, same as 011b)
    ;   4&5: Access Mode:
    ;           0 0 = Latch count value command
    ;           0 1 = Access mode: lobyte only
    ;           1 0 = Access mode: hibyte only
    ;           1 1 = Access mode: lobyte/hibyte
    ;   6&7: Select Channel:
    ;           0 0 = Channel 0
    ;           0 1 = Channel 1
    ;           1 0 = Channel 2
    ;           1 1 = Read-back command (8254 only)
    mov al, (1<<2) | (3<<4)
    out 0x43, al

    mov ax, 11931
    out 0x40, al
    mov al, ah
    out 0x40, al

PICInit:
    ; Set up the Programmable Interrupt Controller
    ; Addresses:
    ;   0x20: Interrupt controller 1
    ;   0xa2: Interrupt controller 2
    ; Initialization:
    ;  0:   If set(1), the PIC expects to recieve IC4 during initialization.
    ;  1:   If set(1), only one PIC in system. If cleared, PIC is cascaded with slave PICs, and ICW3 must be sent to controller.
    ;  2;   If set (1), CALL address interval is 4, else 8. This is useually ignored by x86, and is default to 0
    ;  3:   If set (1), Operate in Level Triggered Mode. If Not set (0), Operate in Edge Triggered Mode
    ;  4:   Initialization bit. Set 1 if PIC is to be initialized
    ;  5-7: Unused on x86, set to 0.

    ; ICW1: Initialization Command Word 1 - Initialize the PICs
    mov al, 0x11            ; Initialize PIC1, 00010001b = 0x11
    out 0x20, al            ; Send to master PIC command port
    out 0xa0, al            ; Send to slave PIC command port

    ; ICW2: Initialization command word 2, start of interrupt vector for IRQs
    mov al, 0x20            ; Interrupt 32 is the first IRQ for the master PIC
    out 0x21, al            ; Send to master PIC data port
    mov al, 0x28            ; Interrupt 40 is the first IRQ for the slave PIC
    out 0xa1, al            ; Send to slave PIC data port

    ; ICW3: Initialization command word 3, determines which IRQ connects the master and slave PICs, IRQ2.
    mov al, 0x4             ; IRQ2 connects master and slave PICs
    out 0x21, al            ; Send to master PIC data port
    mov al, 0x2             ; IRQ2 connects master and slave PICs
    out 0xa1, al            ; Send to slave PIC data port

    ; Initialization command word 4, selecting mode
    ; 0:   If set (1), it is in 80x86 mode. Cleared if MCS-80/86 mode
    ; 1:   If set, on the last interrupt acknowledge pulse, controller automatically performs End of Interrupt (EOI) operation
    ; 2:   Only use if BUF is set. If set (1), selects buffer master. Cleared if buffer slave.
    ; 3:   If set, controller operates in buffered mode
    ; 4:   Special Fully Nested Mode. Used in systems with a large amount of cascaded controllers.
    ; 5-7: Unused on x86, set to 0.
    mov al, 0x1             ; Set to 8086 mode
    out 0x21, al            ; Send to master PIC data port
    out 0xa1, al            ; Send to slave PIC data port

    ; Masking all interrupts other than IRQ0 on master
    mov al, 11111100b
    out 0x21, al            ; Send to master PIC data port
    mov al, 11111111b
    out 0xa1, al            ; Send to slave PIC data port

    mov rax, KernelEntry
    push 8
    push rax
    db 0x48
    retf

KernelEntry:

    mov rsp, 0xffff800000200000       ; Setup stack at 0xffff800000200000
    call KMain

End:
    hlt
    jmp End
