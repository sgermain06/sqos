nasm -f elf64 -o ./build/apps/totalmem/start.o ./src/totalmem/start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/totalmem/main.c -o ./build/apps/totalmem/main.o
ld -nostdlib -Tlink.lds -o ./build/apps/totalmem/totalmem ./build/apps/totalmem/start.o ./build/apps/totalmem/main.o ./build/apps/stdlib/lib.a
objcopy -O binary ./build/apps/totalmem/totalmem ./build/totalmem