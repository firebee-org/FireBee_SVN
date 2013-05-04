/*
 * xhdi_test.c
 *
 *  Created on: 04.05.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdint.h>
#include <osbind.h>
#include "xhdi.h"


static uint32_t *xhdi;

static uint32_t cookieptr(void)
{
	return * (uint32_t *) 0x5a0L;
}

int getcookie(uint32_t cookie, uint32_t *p_value)
{
	uint32_t *cookiejar = (uint32_t *) Supexec(cookieptr);

	if (!cookiejar) return 0;

	do
	{
		if (cookiejar[0] == cookie)
		{
			if (p_value) *p_value = cookiejar[1];
			return 1;
		}
		else
			cookiejar = &(cookiejar[2]);
	} while (cookiejar[-2]);

	return 0;
}

int main(int argc, char *argv[])
{
	(void) Cconws("\033EGCC XHDI Test Program\r\n=====================\r\n\r\n");

	if (getcookie('XHDI', (uint32_t *) &xhdi))
	{
		printf("XHDI cookie: %p\r\n", xhdi);

		printf("xhdi version : %ld\r\n", xhdi_version(xhdi));
		printf("xhdi drivemap: %lx\r\n", xhdi_drivemap(xhdi));
	}
	else
		(void) Cconws("no XHDI cookie found.\r\n");

	(void) Cconws("press any key\r\n");
	(void) Cconin();
	return 0;
}
