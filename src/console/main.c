#include "console.h"

int main(void)
{
    char buffer[100] = { 0 };
    int buffer_size = 0;

    while(1) {
        printf("shell# ");
        memset(buffer, 0, 100);
        buffer_size = read_cmd(buffer);

        if (buffer_size == 0) {
            continue;
        }

        int fd = open_file(buffer);
        if (fd == -1) {
            printf("Command not found\n");
            continue;
        }

        close_file(fd);
        int pid = fork();

        if (pid == 0) {
            exec(buffer);
        }
        else {
            waitu(pid);
        }
    }
    return 0;
}