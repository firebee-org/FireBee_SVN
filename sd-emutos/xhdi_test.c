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

/*
 * XHDI test routine
 *
 * XHDI functions must be called in supervisor mode - pack everything in a function that can be called by Supexec()
 */
void xhdi_test(void)
{
	long drvmap;
	int i;

	printf("XHDI cookie: %p\r\n\r\n", xhdi);

	printf("XHGetVersion = %lx\r\n", XHGetVersion(xhdi));
	drvmap = XHDrvMap(xhdi);
	printf("XHDrvmap = %lx\r\n", drvmap);

	printf("XHInqDev and XHInqDriver for all XHDI devices\r\n");
	for (i = 0; i < 32; i++)
	{
		char driver_name[17];
		char driver_version[7];
		char driver_company[17];
		uint16_t ahdi_version;
		uint16_t max_ipl;

		uint16_t major = 0;
		uint16_t minor = 0;
		long start_sector = 0L;
		uint32_t ret;
		_BPB *bpb = NULL;
		long blocks;
		char part_id[20];

		if ((drvmap >> i) & 1)
		{
			printf("XHInqDev(%d):\r\n", i);
			ret = XHInqDev(xhdi, i, &major, &minor, &start_sector, &bpb);
			if (ret == E_OK || ret == EDRVNR)
			{
				long block_size;
				long flags;
				char product_name[33];
				char buff[512];
				unsigned long blocks;
				unsigned long blocksize;
				unsigned long ms;

				printf("drive %d returned %d:\r\n", i, ret);
				printf("\tmajor = %x, minor = %x, start_sector = %lx, bpb = %p\r\n", major, minor, start_sector, bpb);
				if (bpb != NULL)
					print_bpb(bpb);

				printf("XHInqTarget() major = %x, minor = %x. result = %ld\r\n", major, minor,
							XHInqTarget(xhdi, major, minor, &block_size, &flags, &product_name));
				printf("block_size = %ld, flags = %lx, product_name = \"%s\"\r\n", block_size, flags, product_name);

				printf("XHInqTarget2() major = %x, minor = %x. result = %ld\r\n", major, minor,
							XHInqTarget2(xhdi, major, minor, &block_size, &flags, &buff, 512));
				printf("block_size = %ld, flags = %lx, product_name = \"%s\"\r\n", block_size, flags, product_name);

				printf("try to read sector 1 from device major = %x, minor = %x. Result: %ld\r\n",
							major, minor, XHReadWrite(xhdi, major, minor, 0, 1, 1, &buff));

				(void) Cconws("\r\n<press any key>\r\n");
				(void) Cconin();

				printf("XHEject() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHEject(xhdi, major, minor, 1, 1));

				printf("XHLock() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHLock(xhdi, major, minor, 1, 1));

				printf("XHReserve() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHReserve(xhdi, major, minor, 1, 1));

				printf("XHStop() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHStop(xhdi, major, minor, 1, 1));

				printf("XHDriverSpecial() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHDriverSpecial(xhdi, 'EMUT', 0x12345678, 0, NULL));

				printf("XHGetCapacity() on device major = %x, minor = %x. result = %ld\r\n",
							major, minor, XHGetCapacity(xhdi, major, minor, &blocks, &blocksize));
				printf("blocks = %ld, blocksize = %ld\r\n", blocks, blocksize);

				printf("XHMediumChanged() on device major = %x, minor = %x. Result = %ld\r\n",
							major, minor, XHMediumChanged(xhdi, major, minor));

				printf("XHMintInfo() on driver. Result = %ld\r\n",
							XHMintInfo(xhdi, 1, &buff));

				(void) Cconws("\r\n<press any key>\r\n");
				(void) Cconin();

				printf("XHDOSLimits(XH_DL_SECSIZ); on driver. Result = %ld\r\n",
							XHDOSLimits(xhdi, XH_DL_SECSIZ, 0));

				ms = 0L;
				printf("XHLastAccess() on device major = %x, minor = %x. Result = %ld\r\n",
							major, minor, XHLastAccess(xhdi, major, minor, &ms));
				printf("ms = %ld\r\n", ms);

				printf("XHReaccess() on device major = %x, minor = %x. Result = %ld\r\n",
							major, minor, XHReaccess(xhdi, major, minor));
			}
			printf("XHInqDriver(%d):", i);
			ret = XHInqDriver(xhdi, i, &driver_name, &driver_version, &driver_company, &ahdi_version, &max_ipl);
			printf("%d\r\n", ret);
			if (ret == E_OK || ret == EDRVNR)
			{
				printf("driver_name = %s, driver_version = %s, driver_company = %s, ahdi_version = %d, max_ipl = %d\r\n",
						driver_name, driver_version, driver_company, ahdi_version, max_ipl);
			}

			printf("XHInqDev2(%d):\r\n", i);
			ret = XHInqDev2(xhdi, i, &major, &minor, &start_sector, &bpb, &blocks, &part_id);
			if (ret == E_OK || ret == EDRVNR)
			{
				printf("drive %d returned %d:\r\n", i, ret);
				printf("\tmajor = %x, minor = %x, start_sector = %lx, bpb = %p, blocks = %ld, part_id = %s\r\n",
							major, minor, start_sector, bpb, blocks, part_id);
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
