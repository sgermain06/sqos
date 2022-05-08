nasm -f elf64 -o ./build/apps/stdlib/syscall.o ./src/stdlib/syscall.asm
nasm -f elf64 -o ./build/apps/stdlib/liba.o ./src/stdlib/lib.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/stdlib/print.c -o ./build/apps/stdlib/print.o
ar -rcs ./build/apps/stdlib/lib.a ./build/apps/stdlib/print.o ./build/apps/stdlib/syscall.o