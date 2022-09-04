/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

#include <stdbool.h>
#include <stdio.h>

#include <gba_console.h>
#include <gba_interrupt.h>
#include <gba_systemcalls.h>

int main(void)
{
    irqInit();
    irqEnable(IRQ_VBLANK);

    consoleDemoInit();

    iprintf("\x1b[10;10HHello, world!\n");

    while (true)
    {
        VBlankIntrWait();
    }
}
