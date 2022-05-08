nasm -f elf64 -o ./build/stdlib/syscall.o ./src/stdlib/syscall.asm
nasm -f elf64 -o ./build/stdlib/liba.o ./src/stdlib/lib.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/stdlib/print.c -o ./build/stdlib/print.o
ar -rcs ./build/stdlib/lib.a ./build/stdlib/print.o ./build/stdlib/syscall.o ./build/stdlib/liba.o