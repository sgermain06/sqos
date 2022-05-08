nasm -f elf64 -o ./build/lib/syscall.o ./src/lib/syscall.asm
nasm -f elf64 -o ./build/lib/liba.o ./src/lib/lib.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src/lib -c ./src/lib/print.c -o ./build/lib/print.o
ar -rcs ./build/lib/lib.a ./build/lib/print.o ./build/lib/syscall.o ./build/lib/liba.o