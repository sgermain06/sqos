[BITS 16]
[ORG 0x7e00]

start:
    mov [DriveId], dl

    mov eax, 0x80000000         ; Check if CPU supports requesting processor features
    cpuid                       ; Call cpuid function
    cmp eax, 0x80000001         ; Compare eax value with the value of the function for processor features
    jb NotSupported             ; If it's below the value, the function is not supported.

    mov eax, 0x80000001         ; Request processor features
    cpuid                       ; Call cpuid function
    test edx, (1 << 29)         ; Check if bit 29 is set to 1
    jz NotSupported             ; If it's set to 0, long mode is not supported.
    test edx, (1 << 26)         ; Check if 1GB page support is supported
    jz NotSupported             ; If it's set to 0, 1GB page support is not enabled

LoadKernel:
    mov si, ReadPacket          ; Assign the address of the read packet to the source index register
    mov word[si], 0x10          ; Size of the packet
    mov word[si + 2], 100       ; Number of sectors to read
    mov word[si + 4], 0         ; Memory offset where we want the read packet to be stored to
    mov word[si + 6], 0x1000    ; Memory segment for read packet. Start at 0. (offset:segment => 0:0x1000 => 0x10000)
    mov dword[si + 8], 6        ; LBA block 6 needs to be read (address lo)
    mov dword[si + 0xc], 0      ; Address hi is not needed, set to 0
    mov dl, [DriveId]           ; Set the drive ID to dl
    mov ah, 0x42                ; Use Disk Extension service
    int 0x13                    ; Call disk interrupt (13h)
    jc ReadError                ; If there was an error reading the packet, the interrupt will set the carry flag to 1. Jump to label if this happens.

LoadUser:
    mov si, ReadPacket          ; Assign the address of the read packet to the source index register
    mov word[si], 0x10          ; Size of the packet
    mov word[si + 2], 10        ; Number of sectors to read
    mov word[si + 4], 0         ; Memory offset where we want the read packet to be stored to
    mov word[si + 6], 0x2000    ; Memory segment for read packet. Start at 0. (offset:segment => 0:0x1000 => 0x10000)
    mov dword[si + 8], 106      ; LBA block 6 needs to be read (address lo)
    mov dword[si + 0xc], 0      ; Address hi is not needed, set to 0
    mov dl, [DriveId]           ; Set the drive ID to dl
    mov ah, 0x42                ; Use Disk Extension service
    int 0x13                    ; Call disk interrupt (13h)
    jc ReadError                ; If there was an error reading the packet, the interrupt will set the carry flag to 1. Jump to label if this happens.

LoadUser2:
    mov si, ReadPacket          ; Assign the address of the read packet to the source index register
    mov word[si], 0x10          ; Size of the packet
    mov word[si + 2], 10        ; Number of sectors to read
    mov word[si + 4], 0         ; Memory offset where we want the read packet to be stored to
    mov word[si + 6], 0x3000    ; Memory segment for read packet. Start at 0. (offset:segment => 0:0x1000 => 0x10000)
    mov dword[si + 8], 116      ; LBA block 6 needs to be read (address lo)
    mov dword[si + 0xc], 0      ; Address hi is not needed, set to 0
    mov dl, [DriveId]           ; Set the drive ID to dl
    mov ah, 0x42                ; Use Disk Extension service
    int 0x13                    ; Call disk interrupt (13h)
    jc ReadError                ; If there was an error reading the packet, the interrupt will set the carry flag to 1. Jump to label if this happens.

LoadUser3:
    mov si, ReadPacket          ; Assign the address of the read packet to the source index register
    mov word[si], 0x10          ; Size of the packet
    mov word[si + 2], 10        ; Number of sectors to read
    mov word[si + 4], 0         ; Memory offset where we want the read packet to be stored to
    mov word[si + 6], 0x4000    ; Memory segment for read packet. Start at 0. (offset:segment => 0:0x1000 => 0x10000)
    mov dword[si + 8], 126      ; LBA block 6 needs to be read (address lo)
    mov dword[si + 0xc], 0      ; Address hi is not needed, set to 0
    mov dl, [DriveId]           ; Set the drive ID to dl
    mov ah, 0x42                ; Use Disk Extension service
    int 0x13                    ; Call disk interrupt (13h)
    jc ReadError                ; If there was an error reading the packet, the interrupt will set the carry flag to 1. Jump to label if this happens.

GetMemoryInfoStart:
    mov eax, 0xe820             ; Query System Address Map. The information returned from E820 supersedes what is returned from the older AX=E801h and AH=88h interfaces.
    mov edx, 0x534d4150         ; Place "SMAP" into edx
    mov ecx, 20                 ; Ask for 20 bytes
    mov dword[0x9000], 0
    mov edi, 0x9008             ; Set edi to 0x9008. Otherwise this code will get stuck in `int 0x15` after some entries are fetched 
    xor ebx, ebx                ; ebx must be 0 to start
    int 0x15                    ; Call interrupt 15h
    jc NotSupported             ; If there was an error, the interrupt will set the carry flag to 1. Jump to label if this happens.

GetMemoryInfo:
    add edi, 20                 ; Add 20 bytes to edi, so we can fetch the next entry
    inc dword[0x9000]
    test ebx, ebx               ; Check if ebx is 0. If it is, we reached the end of the memory map.
    jz GetMemoryDone            ; If it is, jump to the label to fetch the next entry.
    mov eax, 0xe820             ; Query System Address Map. The information returned from E820 supersedes what is returned from the older AX=E801h and AH=88h interfaces.
    mov edx, 0x534d4150         ; Place "SMAP" into edx
    mov ecx, 20                 ; Ask for 20 bytes
    int 0x15                    ; Call interrupt 15h 
    jnc GetMemoryInfo           ; If the carry flag is not set, this means there's more to read, loop back to GetMemoryInfo

GetMemoryDone:

TestA20:
    mov ax, 0xffff
    mov es, ax
    mov word[ds:0x7c00], 0xa200 ; Set the segment of the memory map to 0xa200
    cmp word[es:0x7c00], 0xa200 ; Compare the segment of the memory map with 0xa200
    jne SetA20LineDone
    mov word[0x7c00], 0xb200 ; Set the segment of the memory map to 0xb200
    cmp word[es:0x7c10], 0xb200 ; Compare the segment of the memory map with 0xb200
    je End

SetA20LineDone:
    xor ax, ax
    mov es, ax

; Color Index
; Foreground
; 0 => Black        8 => Dark Gray
; 1 => Blue         9 => Light Blue
; 2 => Green        A => Light Green
; 3 => Cyan         B => Light Cyan
; 4 => Red          C => Light Red
; 5 => Magenta      D => Light Magenta
; 6 => Brown        E => Yellow
; 7 => Light Gray   F => White

; Background
; 0 => Black        8 => Black + blink text
; 1 => Blue         9 => Blue + blink text
; 2 => Green        A => Green + blink text
; 3 => Cyan         B => Cyan + blink text
; 4 => Red          C => Red + blink text
; 5 => Magenta      D => Magenta + blink text    
; 6 => Brown        E => Brown + blink text
; 7 => Light Gray   F => Light Gray + blink text

SetVideoMode:
    mov ax, 3               ; Set the video mode to 3 (text)
    int 0x10                ; Call interrupt 10h

    cli                     ; Disable interrupts
    lgdt [Gdt32Ptr]         ; Load the GDT
    lidt [Idt32Ptr]         ; Load the IDT

    mov eax, cr0            ; Get the current CR0 value
    or eax, 1               ; Set the PG bit in the CR0 value
    mov cr0, eax            ; Set the new CR0 value

    jmp 8:PMEntry           ; Jump to the protected mode entry point

ReadError:
NotSupported:
End:
    hlt
    jmp End

[BITS 32]
PMEntry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00

    cld                     ; Clear the direction flag
    mov edi, 0x70000        ; Set edi to 0x70000
    xor eax, eax            ; Zero out eax
    mov ecx, 0x10000 / 4    ; Set ecx to 0x10000 / 4, which is the number of bytes to copy
    rep stosd               ; Copy the data from the source to the destination

    mov dword[0x70000], 0x71003
    mov dword[0x71000], 10000011b

    mov eax, (0xffff800000000000 >> 39)
    and eax, 0x1ff
    mov dword[0x70000+eax*8], 0x72003
    mov dword[0x72000], 10000011b

    lgdt [Gdt64Ptr]         ; Load the GDT (64 bits)

    mov eax, cr4            ; Get the current CR4 value
    or eax, (1 << 5)        ; Set the PAE bit in the CR4 value
    mov cr4, eax            ; Set the new CR4 value

    mov eax, 0x70000        ; Set eax to 0x80000
    mov cr3, eax            ; Set the CR3 value to the video memory address

    mov ecx, 0xc0000080     ; Set ecx to 0xc0000080h, which is the address of the IDT
    rdmsr                   ; Read the current value of the IA32_IDT_MSR register
    or eax, (1 << 8)        ; Set the IDT_MSR_RD_EN bit in the IA32_IDT_MSR register
    wrmsr                   ; Write the new value of the IA32_IDT_MSR register

    mov eax, cr0            ; Get the current CR0 value
    or eax, (1 << 31)       ; Set the PE bit in the CR0 value
    mov cr0, eax            ; Set the new CR0 value

    jmp 8:LMEntry           ; Jump to the long mode entry point

PEnd:
    hlt                     ; Halt the CPU
    jmp PEnd

[BITS 64]
LMEntry:
    mov rsp, 0x7c00

    cld                     ; Clear the direction flag
    mov rdi, 0x200000       ; Set rdi to 0x200000 (Destination address for kernel)
    mov rsi, 0x10000        ; Set rsi to 0x10000 (Source address for kernel)
    mov rcx, 51200/8        ; Set rcx to 51200/8, which is the number of bytes to copy
    rep movsq               ; Copy the data from the source to the destination

    mov rax, 0xffff800000200000
    jmp 0x200000           ; Jump to the kernel

LEnd:
    hlt                     ; Halt the CPU
    jmp LEnd

DriveId:    db 0
Message:    db "Text mode is set."    ; Message to print
MessageLen: equ $-Message       ; Length of the message, in bytes
ReadPacket: times 16 db 0

Gdt32:
    dq 0
Code32:                     ; +---+-----+---+---+----+----+---+    P = Present
    dw 0xffff               ; | P | DPL | S | E | DC | RW | A |    DPL = Descriptor Privilege Level
    dw 0                    ; +---+-----+---+---+----+----+---+    S = System flag
    db 0                    ; | 1 | 00  | 1 | 1 | 0  | 1  | 0 |    E = Executable flag, DC = Conforming flag (0 = execute at DPL, 1 = execute at DPL or lower), RW = Readable flag (0 = not readable, 1 = readable), A = Accessed flag (leave as 0)
    db 0x9a                 ; +---+-----+---+---+----+----+---+    10011010b = 0x9a00
    db 0xcf                 ; Granularity = 1 (4K blocks), Size = 1 (32-bit), Long mode code flag = 0 (just set to 0), Limit = 1111b
    db 0                    ; Base address
Data32:                     ; +---+-----+---+---+----+----+---+    P = Present
    dw 0xffff               ; | P | DPL | S | E | DC | RW | A |    DPL = Descriptor Privilege Level
    dw 0                    ; +---+-----+---+---+----+----+---+    S = System flag
    db 0                    ; | 1 | 00  | 1 | 0 | 0  | 1  | 0 |    E = Executable flag, DC = Conforming flag (0 = execute at DPL, 1 = execute at DPL or lower), RW = Readable flag (0 = not readable, 1 = readable), A = Accessed flag (leave as 0)
    db 0x92                 ; +---+-----+---+---+----+----+---+    10010010b = 0x9200
    db 0xcf                 ; Granularity = 1 (4K blocks), Size = 1 (32-bit), Long mode code flag = 0 (just set to 0), Limit = 1111b
    db 0                    ; Base address
Gdt32Len:   equ $-Gdt32
Gdt32Ptr:   dw Gdt32Len-1
            dd Gdt32

Idt32Ptr:   dw 0
            dd 0

Gdt64:
    dq 0
Code64:                     ; D L     P DPL  1  1   C
    dq 0x0020980000000000   ; 0 1     1 00   1  1   1

Gdt64Len:   equ $-Gdt64
Gdt64Ptr:   dw Gdt64Len-1
            dd Gdt64



;     mov si, Message         ; Assign the address of the message to the source index register
;     mov ax, 0xb800          ; Set the video memory address to 0xb800
;     mov es, ax              ; Set the video memory segment to es
;     xor di, di              ; Zero out di, which will produce address 0xb8000
;     mov cx, MessageLen      ; Set the length of the message to cx for loop

; PrintMessage:
;     mov al, [si]            ; Fetch the next character from the message
;     mov [es:di], al         ; Write the character code to the video memory
;     mov byte[es:di+1], 0xa  ; Write the character attribute to the video memory

;     add di, 2               ; Add 2 to di, so we can write the next character
;     add si, 1               ; Add 1 to si, so we can fetch the next character
;     loop PrintMessage       ; Loop back to the label to print the next character

    ; mov byte[0xb8000], 'P'
    ; mov byte[0xb8001], 0xa
