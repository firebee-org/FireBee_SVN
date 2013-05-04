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

void print_bpb(_BPB *bpb)
{
	printf("\t\trecsiz = %u\r\n", bpb->recsiz);
	printf("\t\tclsiz  = %u\r\n", bpb->clsiz);
	printf("\t\tclsizb = %u\r\n", bpb->clsizb);
	printf("\t\trdlen  = %u\r\n", bpb->rdlen);
	printf("\t\tfsiz   = %u\r\n", bpb->fsiz);
	printf("\t\tfatrec = %u\r\n", bpb->fatrec);
	printf("\t\tdatrec = %u\r\n", bpb->datrec);
	printf("\t\tnumcl  = %u\r\n", bpb->numcl);
	printf("\t\tbflags = %x\r\n", bpb->bflags);
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
		_BPB *bpb;

		if ((drvmap >> i) & 1)
		{
			ret = XHInqDev(xhdi, i, &major, &minor, &start_sector, &bpb);
			if (ret == E_OK || ret == EDRVNR)
			{
				long block_size;
				long flags;
				char *product_name;

				printf("drive %d returned %d:\r\n", i, ret);
				printf("\tmajor = %x, minor = %x, start_sector = %lx, bpb = %p\r\n", major, minor, start_sector, bpb);
				if (bpb != NULL)
					print_bpb(bpb);

				printf("trying to eject device major = %u, minor = %u. result = %ld\r\n",
							major, minor, XHEject(xhdi, major, minor, 1, 1));
				printf("trying to lock device major = %u, minor = %u. result = %ld\r\n",
							major, minor, XHLock(xhdi, major, minor, 1, 1));

				printf("inquire target major = %u, minor = %u. result = %ld\r\n", major, minor,
							XHInqTarget(xhdi, major, minor, &block_size, &flags, &product_name));
				printf("block_size = %ld, flags = %ld, product_name = \"%s\"", block_size, flags, product_name);

			}
		}
		bpb = NULL;
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
