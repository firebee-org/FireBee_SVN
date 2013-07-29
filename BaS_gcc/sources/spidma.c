/*
 * spidma.c
 *
 *  Created on: 27.07.2013
 *      Author: mfro
 */

#include "spidma.h"
#include <MCD_dma.h>
#include "bas_printf.h"

extern char _SYS_SRAM[];
#define SYS_SRAM &_SYS_SRAM[0]

int spidma_init(void)
{
	int res;

	res = MCD_initDma((dmaRegs *) &MCF_DMA_TASKBAR, SYS_SRAM, MCD_RELOC_TASKS | MCD_COMM_PREFETCH_EN);
	if (res != MCD_OK)
	{
		xprintf("DMA API initialization failed (0x%x)\r\n", res);
		return 0;
	}
	xprintf("DMA API initialized. Tasks are at %p\r\n", SYS_SRAM);
	return 1;
}

