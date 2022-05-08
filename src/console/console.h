#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include "stdint.h"
#include "lib.h"

typedef void (*CmdFunc)(void);

int read_cmd(char *buffer);
int parse_cmd(char *buffer, int buffer_size);
void execute_cmd(int cmd);

#endif