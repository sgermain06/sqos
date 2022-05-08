nasm -f elf64 -o ./build/ls/start.o ./src/ls/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/ls/main.c -o ./build/ls/main.o
ld -nostdlib -Tlink.lds -o ./build/ls/ls ./build/ls/start.o ./build/ls/main.o ./build/stdlib/lib.a
objcopy -O binary ./build/ls/ls ./build/ls.bin