nasm -f elf64 -o ./build/lib/syscall.o ./src/lib/syscall.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ./src/lib/print.c -o ./build/lib/print.o
ar -rcs ./build/lib/lib.a ./build/lib/print.o ./build/lib/syscall.o