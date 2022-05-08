#include "stdint.h"
#include "stdlib/lib.h"

struct DirEntry buffer[1024];

int main(void)
{
    int count;

    char name[9] = { 0 };
    char ext[4] = { 0 };

    uint64_t totalDiskUsage = 0;

    count = read_root_directory(buffer);

    if (count != 0) {
        printf("NAME       EXT                 FILE SIZE\n");
        printf("--------------------------------------\n");
        for (int i = 0; i < count; i++) {
            if (buffer[i].name[0] == ENTRY_AVAILABLE || 
                buffer[i].name[0] == ENTRY_DELETED ||
                buffer[i].attributes == 0xf ||
                buffer[i].attributes == 8) {
                continue;
            }
            
            memcpy(name, buffer[i].name, 8);
            memcpy(ext, buffer[i].ext, 3);
            
            totalDiskUsage += (uint64_t)buffer[i].file_size;
            
            if ((buffer[i].attributes & 0x10) == 0x10) {
                printf("<%s>   %s               ...\n", name, ext);
            }
            else {
                printf("%s   %s                 %ukb\n", name, ext, (uint64_t)buffer[i].file_size / 1024);
            }
        }
        printf("-----------------------------------------\n");
        printf("Total Disk Usage: %ukb\n", totalDiskUsage / 1024);
    }

    return 0;
}