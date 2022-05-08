nasm -f elf64 -o ./build/user3/start.o ./src/user3/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ./src/user3/main.c -o ./build/user3/main.o
ld -nostdlib -Tlink.lds -o ./build/user3/user ./build/user3/start.o ./build/user3/main.o ./build/lib/lib.a
objcopy -O binary ./build/user3/user ./build/user3.bin