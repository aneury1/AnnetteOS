#pragma once 

#include "../../gnu/gtypes.h"

void writePort(u8 data, u16 port);
void writePort(u16 data, u16 port);
void writePort(u32 data, u16 port);


u8 readPort(u8 data, u16 port);
u16 readPort(u16 data, u16 port);
u32 readPort(u32 data, u16 port);