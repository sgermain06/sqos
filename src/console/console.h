#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include "stdint.h"
#include "stdlib/lib.h"

typedef void (*CmdFunc)(void);

int read_cmd(char *buffer);

#endif