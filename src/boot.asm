[BITS 16]
[ORG 0x7c00]

start:
    xor ax, ax                  ; XOR ax with itself will set it to 0, as AX has to equal AX. Exclusive OR (XOR) needs to have both operands to be different to return true.
    mov ds, ax                  ; Propagate 0 to data segment, extra segment and stack segment.
    mov es, ax  
    mov ss, ax
    mov sp, 0x7c00              ; Set stack pointer at boot code loaded from disk's master boot record.

TestDiskExtension:
    mov [DriveId], dl           ; The BIOS will put the drive ID in dl when booting. Store that ID into a variable named DriveId
    mov ah, 0x41                ; Function code. 0x41 is check extension present
    mov bx, 0x55aa              ; Boot signature
    int 0x13                    ; Call disk interrupt (13h)
    jc  NotSupported            ; If extension is not supported, the function will set the carry flag to 1.
    cmp bx, 0xaa55              ; If the check extension is supported and the drive supports it, the function will reverse the 2 bytes in bx.
    jne NotSupported            ; If the 2 bytes in bx are not the reverse of the original 2 bytes, the drive doesn't support the extension.

LoadLoader:
    mov si, ReadPacket          ; Assign the address of the read packet to the source index register
    mov word[si], 0x10          ; Size of the packet
    mov word[si + 2], 15        ; Number of sectors to read
    mov word[si + 4], 0x7e00    ; Memory offset where we want the read packet to be stored to
    mov word[si + 6], 0         ; Memory segment for read packet. Start at 0. (offset:segment => 0x7e00:0)
    mov dword[si + 8], 1        ; LBA block 1 needs to be read (address lo)
    mov dword[si + 0xc], 0      ; Address hi is not needed, set to 0
    mov dl, [DriveId]           ; Set the drive ID to dl
    mov ah, 0x42                ; Use Disk Extension service
    int 0x13                    ; Call disk interrupt (13h)
    jc ReadError                ; If there was an error reading the packet, the interrupt will set the carry flag to 1. Jump to label if this happens.

    mov dl, [DriveId]           ; Set the drive ID to dl
    jmp 0x7e00                  ; Jump to loader code.

ReadError:
NotSupported:                   ; We jump here if the disk extension check failed.
    mov ah, 0x13                ; Print Screen function
    mov al, 1                   ; Place cursor at end of the string
    mov bx, 0xa                 ; Bright green
    xor dx, dx                  ; Zero out dx, position
    mov bp, Message             ; Set base pointer to Message
    mov cx, MessageLen          ; Set the counter to the length of the message to know how many characters to print
    int 0x10                    ; Call BIOS interrupt to print character to screen

End:
    hlt                         ; Halt the processor. Will move forward on interrupt
    jmp End                     ; Loop forever
     
DriveId:    db 0                ; Default value. HD is 80h
Message:    db "Boot Error."    ; Message to print
MessageLen: equ $-Message       ; Length of the message, in bytes
ReadPacket: times 16 db 0       ; Read packet

times (0x1be - ($-$$)) db 0     ; Filler

    db 80h                      ; Boot indicator (bootable partition)
    db 1, 1, 0                  ; Starting cylinder/head/sector
    db 06h                      ; Partition type. Type F0 is "PA-RISC Linux boot loader" and must reside in first physical 2 GB
    db 0fh, 3fh, 0cah           ; Ending cylinder/head/sector
    dd 3fh                      ; LBA (Logical block address) Starting sector
    dd 031f11h                  ; Partition size (10MB) (21059)
	
    times (16 * 3) db 0         ; Fill to 512 bytes

    db 0x55                     ; Boot signature
    db 0xaa                     ;

	
