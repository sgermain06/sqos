nasm -f elf64 -o ./build/console/start.o ./src/console/start.asm
nasm -f bin -o ./build/test.bin ./src/console/test.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src/lib -c ./src/console/console.c -o ./build/console/console.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src/lib -c ./src/console/main.c -o ./build/console/main.o
ld -nostdlib -Tlink.lds -o ./build/console/console ./build/console/start.o ./build/console/main.o ./build/lib/lib.a ./build/console/console.o
objcopy -O binary ./build/console/console ./build/console.bin