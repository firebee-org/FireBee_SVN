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

void xhdi_test(void)
{
	long drvmap;
	int i;

	printf("XHDI cookie: %p\r\n\r\n", xhdi);

	printf("XHGetVersion = %lx\r\n", XHGetVersion(xhdi));
	drvmap = XHDrvMap(xhdi);
	printf("XHDrvmap = %lx\r\n", drvmap);

	printf("XHInqDev for all XHDI devices\r\n");
	for (i = 0; i < 32; i++)
	{
		uint16_t major = 0;
		uint16_t minor = 0;
		long start_sector = 0L;
		uint32_t ret;
		_BPB *bpb = NULL;

		if ((drvmap >> i) & 1)
		{
			ret = XHInqDev(xhdi, i, &major, &minor, &start_sector, &bpb);
			//if (ret == E_OK)
			{
				printf("drive %d returned %d:\r\n", i, ret);
				printf("\tmajor = %d, minor = %d, start_sector = %lx, bpb = %p\r\n", major & 0xff, minor & 0xff, start_sector, bpb);
			}
		}
	}
}
int main(int argc, char *argv[])
{
	(void) Cconws("\033EGCC XHDI Test Program\r\n=====================\r\n\r\n");

	if (getcookie('XHDI', (uint32_t *) &xhdi))
	{
		Supexec(xhdi_test);
	}
	else
		(void) Cconws("no XHDI cookie found.\r\n");

	(void) Cconws("\r\n<press any key to return to desktop>\r\n");
	(void) Cconin();

	return 0;
}
