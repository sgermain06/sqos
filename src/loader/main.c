#include "print.h"
#include "file.h"
#include "debug.h"

void EMain(void)
{
    init_fs();
    ASSERT(load_file("KERNEL.BIN", 0x200000) == 0);
    ASSERT(load_file("CONSOLE.BIN", 0x30000) == 0);
}