nasm -f elf64 -o ./build/user1/start.o ./src/user1/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ./src/user1/main.c -o ./build/user1/main.o
ld -nostdlib -Tlink.lds -o ./build/user1/user ./build/user1/start.o ./build/user1/main.o ./build/lib/lib.a
objcopy -O binary ./build/user1/user ./build/user1.bin