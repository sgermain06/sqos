#include "console.h"

static void cmd_get_total_memory(void)
{
    uint64_t total;

    total = get_total_memoryu();
    printf("Total Memory is %dMB\n", total);
}

int read_cmd(char *buffer)
{
    char ch[2] = { 0 };
    int buffer_size = 0;

    while(1) {
        ch[0] = keyboard_readu();

        if (ch[0] == '\n' || buffer_size >= 80) {
            printf("%s", ch);
            break;
        }
        else if (ch[0] == '\b') {
            if (buffer_size > 0) {
                buffer[--buffer_size] = 0;
                printf("%s", ch);
            }
        }
        else {
            buffer[buffer_size++] = ch[0];
            printf("%s", ch);
        }
    }

    return buffer_size;
}

int parse_cmd(char *buffer, int buffer_size)
{
    int cmd = -1;

    if (buffer_size == 8 && (!memcmp("totalmem", buffer, 8))) {
        cmd = 0;
    }

    return cmd;
}

void execute_cmd(int cmd)
{
    CmdFunc cmd_list[1] = { cmd_get_total_memory };

    if (cmd == 0) {
        cmd_list[0]();
    }
}