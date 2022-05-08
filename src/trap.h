#ifndef _TRAP_H_
#define _TRAP_H_

#include "stdint.h"

struct IdtEntry {
    uint16_t low;
    uint16_t selector;
    uint8_t  res0;
    uint8_t  attr;
    uint16_t mid;
    uint32_t high;
    uint32_t res1;
};

struct IdtPtr {
    uint16_t limit;
    uint64_t addr;
} __attribute__((packed));

struct TrapFrame {
    uint64_t r15;
    uint64_t r14;
    uint64_t r13;
    uint64_t r12;
    uint64_t r11;
    uint64_t r10;
    uint64_t r9;
    uint64_t r8;
    uint64_t rbp;
    uint64_t rdi;
    uint64_t rsi;
    uint64_t rdx;
    uint64_t rcx;
    uint64_t rbx;
    uint64_t rax;
    uint64_t trapno;
    uint64_t errorcode;
    uint64_t rip;
    uint64_t cs;
    uint64_t rflags;
    uint64_t rsp;
    uint64_t ss;
};

void vector0(void);
void vector1(void);
void vector2(void);
void vector3(void);
void vector4(void);
void vector5(void);
void vector6(void);
void vector7(void);
void vector8(void);
void vector10(void);
void vector11(void);
void vector12(void);
void vector13(void);
void vector14(void);
void vector16(void);
void vector17(void);
void vector18(void);
void vector19(void);
void vector32(void);
void vector33(void);
void vector39(void);
void sysint(void);
void init_idt(void);
void eoi(void);
void load_idt(struct IdtPtr *ptr);
unsigned char read_isr(void);
uint64_t read_cr2(void);
uint64_t read_cr3(void);
void yield(void);
void TrapReturn(void);
uint64_t get_ticks(void);

#endif