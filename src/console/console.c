#include "console.h"

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