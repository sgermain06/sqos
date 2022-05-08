nasm -f elf64 -o ./build/user2/start.o ./src/user2/start.asm
nasm -f elf64 -o ./build/user2/liba.o ./src/user2/lib.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ./src/user2/main.c -o ./build/user2/main.o
ld -nostdlib -Tlink.lds -o ./build/user2/user ./build/user2/start.o ./build/user2/main.o ./build/user2/liba.o ./build/lib/lib.a
objcopy -O binary ./build/user2/user ./build/user2.bin