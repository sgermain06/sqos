nasm -f elf64 -o ./build/apps/console/start.o ./src/console/start.asm
nasm -f bin -o ./build/test.bin ./src/console/test.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/console/console.c -o ./build/apps/console/console.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c ./src/console/main.c -o ./build/apps/console/main.o
ld -nostdlib -Tlink.lds -o ./build/apps/console/console ./build/apps/console/start.o ./build/apps/console/main.o ./build/apps/stdlib/lib.a ./build/apps/console/console.o
objcopy -O binary ./build/apps/console/console ./build/console.bin