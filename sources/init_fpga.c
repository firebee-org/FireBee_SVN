/*
 * init_fpga.c
 *
 * This file is part of BaS_gcc.
 *
 * BaS_gcc is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BaS_gcc is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with BaS_gcc.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2010 - 2012 F. Aschwanden
 * Copyright 2011 - 2012 V. Riviere
 * Copyright 2012        M. Froeschle
 *
 */

#include <MCF5475.h>
#include "sysinit.h"
#include <bas_printf.h>

#define FPGA_STATUS		(1 << 0)
#define FPGA_CLOCK		(1 << 1)
#define FPGA_CONFIG		(1 << 2)
#define FPGA_DATA0		(1 << 3)
#define FPGA_CONF_DONE	(1 << 5)


/*
 * load FPGA
 */
void init_fpga(void)
{
	uint8_t *fpga_data;
	int i;

	xprintf("FPGA load config... ");


	MCF_GPIO_PODR_FEC1L &= ~FPGA_CLOCK;		/* FPGA clock => low */
	MCF_GPIO_PODR_FEC1L &= ~FPGA_CONFIG;	/* FPGA config => low */

	while ((MCF_GPIO_PPDSDR_FEC1L & FPGA_STATUS) && (MCF_GPIO_PPDSDR_FEC1L & FPGA_CONF_DONE));
	MCF_GPIO_PODR_FEC1L |= FPGA_CONFIG;				/* pull FPGA_CONFIG high */
	while (!(MCF_GPIO_PPDSDR_FEC1L & FPGA_STATUS));	/* wait until status becomes high */

	/*
	 * excerpt from an Altera configuration manual:
	 *
	 * The low-to-high transition of nCONFIG on the FPGA begins the configuration cycle. The
	 * configuration cycle consists of 3 stages�reset, configuration, and initialization.
	 * While nCONFIG is low, the device is in reset. When the device comes out of reset,
	 * nCONFIG must be at a logic high level in order for the device to release the open-drain
 	 * nSTATUS pin. After nSTATUS is released, it is pulled high by a pull-up resistor and the FPGA
	 * is ready to receive configuration data. Before and during configuration, all user I/O pins
	 * are tri-stated. Stratix series, Arria series, and Cyclone series have weak pull-up resistors
	 * on the I/O pins which are on, before and during configuration.
	 *
	 * To begin configuration, nCONFIG and nSTATUS must be at a logic high level. You can delay
	 * configuration by holding the nCONFIG low. The device receives configuration data on its
	 * DATA0 pins. Configuration data is latched into the FPGA on the rising edge of DCLK. After
	 * the FPGA has received all configuration data successfully, it releases the CONF_DONE pin,
	 * which is pulled high by a pull-up resistor. A low to high transition on CONF_DONE indicates
	 * configuration is complete and initialization of the device can begin.
	 */
	fpga_data = (uint8_t *) FPGA_FLASH_DATA;
	do
	{
		uint8_t value = *fpga_data++;
		for (i = 0; i < 8; i++, value >>= 1)
		{

			if (value & 1)
			{
				/* bit set -> toggle DATA0 to high */
				MCF_GPIO_PODR_FEC1L |= FPGA_DATA0;
			}
			else
			{
				/* bit is cleared -> toggle DATA0 to low */
				MCF_GPIO_PODR_FEC1L &= ~FPGA_DATA0;
			}
			/* toggle DCLK -> FPGA reads the bit */
			MCF_GPIO_PODR_FEC1L |= FPGA_CLOCK;
			MCF_GPIO_PODR_FEC1L &= ~FPGA_CLOCK;
		}
	} while ((!(MCF_GPIO_PPDSDR_FEC1L & FPGA_CONF_DONE)) && (fpga_data < (uint8_t *) FPGA_FLASH_DATA_END));

	if (fpga_data < (uint8_t *) FPGA_FLASH_DATA_END)
	{
		while (fpga_data++ < (uint8_t *) FPGA_FLASH_DATA_END)
		{
			/* toggle a little more since it's fun ;) */
			MCF_GPIO_PODR_FEC1L |= FPGA_CLOCK;
			MCF_GPIO_PODR_FEC1L &= ~FPGA_CLOCK;
		}
		xprintf("finished\r\n");
	}
	else
	{
		xprintf("FAILED!\r\n");
	}
}
