nasm -f bin -o boot.bin src/boot.asm
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
