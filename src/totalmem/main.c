#include "stdint.h"
#include "lib.h"

int main(void)
{
    int total = get_total_memoryu();
    printf("Total Memory is %dMB\n", (uint64_t)total);
    return 0;
}