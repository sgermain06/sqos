#include "lib.h"

int main(void)
{
    int64_t i = 0;

    while (1) {
        printf("User process %d\n", i);
        sleepu(1000);
        i++;
    }
    return 0;
}