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

        // Make sure that commands typed in lowercase also work
        printf("Buffer size: %u\n", buffer_size);
        for (int i = 0; buffer[i] != '\0' && i < buffer_size; i++) {
            if (buffer[i] >= 'a' && buffer[i] <= 'z') {
                buffer[i] = buffer[i] - 32;
            }
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