nasm -f bin -o build/boot.bin src/boot.asm
nasm -f bin -o build/loader.bin src/loader/loader.asm
nasm -f elf64 -o build/entry.o src/loader/entry.asm
nasm -f elf64 -o build/liba.o src/lib.asm
nasm -f elf64 -o build/kernel.o src/kernel.asm
nasm -f elf64 -o build/trapa.o src/trap.asm -I src/include
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c src/loader/file.c -o build/loader_file.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -I src -c src/loader/main.c -o build/loader_main.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/print.c -o build/print.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/debug.c -o build/debug.o
ld -nostdlib -T src/loader/link.lds -o build/entry build/entry.o build/loader_main.o build/liba.o build/print.o build/debug.o build/loader_file.o
objcopy -O binary build/entry build/entry.bin
dd if=build/entry.bin >> build/loader.bin

gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/main.c -o build/kernel_main.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/trap.c -o build/trap.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/memory.c -o build/memory.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/process.c -o build/process.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/syscall.c -o build/syscall.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/lib.c -o build/lib.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/keyboard.c -o build/keyboard.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c src/file.c -o build/file.o

ld -nostdlib -T link.lds -o build/kernel build/kernel.o build/kernel_main.o build/trapa.o build/trap.o build/liba.o build/lib.o build/print.o build/debug.o build/memory.o build/process.o build/syscall.o build/keyboard.o build/file.o
objcopy -O binary build/kernel build/kernel.bin

./src/lib/build.sh
./src/console/build.sh
./src/totalmem/build.sh
./src/ls/build.sh

dd if=build/boot.bin of=os.img bs=512 count=1 conv=notrunc
dd if=build/loader.bin of=os.img bs=512 count=15 seek=1 conv=notrunc
# dd if=build/kernel.bin of=os.img bs=512 count=110 seek=16 conv=notrunc
# dd if=build/user1.bin of=os.img bs=512 count=10 seek=116 conv=notrunc
# dd if=build/user2.bin of=os.img bs=512 count=10 seek=126 conv=notrunc
# dd if=build/user3.bin of=os.img bs=512 count=10 seek=136 conv=notrunc

# Copy files to the os.img.
sudo mount -o loop,rw,sync,offset=32256 os.img ./mnt
sudo cp build/kernel.bin ./mnt/
sudo cp build/console.bin ./mnt/
sudo cp build/totalmem.bin ./mnt/
sudo cp build/ls.bin ./mnt/
sudo umount ./mnt