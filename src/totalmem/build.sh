nasm -f elf64 -o ./build/totalmem/start.o ./src/totalmem/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src/lib -c ./src/totalmem/main.c -o ./build/totalmem/main.o
ld -nostdlib -Tlink.lds -o ./build/totalmem/user ./build/totalmem/start.o ./build/totalmem/main.o ./build/lib/lib.a
objcopy -O binary ./build/totalmem/user ./build/totalmem.bin