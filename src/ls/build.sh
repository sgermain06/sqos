nasm -f elf64 -o ./build/apps/ls/start.o ./src/ls/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/ls/main.c -o ./build/apps/ls/main.o
ld -nostdlib -Tlink.lds -o ./build/apps/ls/ls ./build/apps/ls/start.o ./build/apps/ls/main.o ./build/apps/stdlib/lib.a
objcopy -O binary ./build/apps/ls/ls ./build/ls