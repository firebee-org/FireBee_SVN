/*
 * emusd.c
 *
 * The driver actually resides within BaS_gcc. All we need to do within the AUTO-folder program is to find the driver
 * entry point and put its address into the XHDI cookie
 *
 *  Created on: 01.05.2013
 *      Author: mfro
 */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <osbind.h>

#include "cookie.h"

#define XHDIMAGIC 0x27011992L

typedef uint32_t (*cookie_fun)(uint16_t opcode,...);

static cookie_fun old_vector = NULL;

static cookie_fun get_fun_ptr(void)
{
	static cookie_fun xhdi = NULL;
	static int have_it = 0;

	if (!have_it)
	{
		uint32_t *magic_test;

		getcookie ('XHDI', (uint32_t *) &xhdi);
		have_it = 1;

		/* check magic */

		magic_test = (uint32_t *) xhdi;
		if (magic_test && (magic_test[-1] != XHDIMAGIC))
			xhdi = NULL;
	}

	return xhdi;
}

cookie_fun bas_sd_vector(cookie_fun old_vector)
{
	register long retvalue __asm__("d0");

	__asm__ __volatile__(
			"move.l	%[retvalue],-(sp)\n\t"
			"trap   #0\n\t"
			"addq.l	#4,sp\n\t"
			: [retvalue]"=r"(retvalue)
			: "g"(old_vector)
			: "d1","d2","d3","a0","a1","a2"
	);
	return (cookie_fun) retvalue;
}

int main(int argc, char *argv[])
{
	uint32_t value;
	cookie_fun bas_vector;

	if (getcookie('XHDI', &value))
	{
		if ((old_vector = get_fun_ptr()))
		{
			printf("old XHDI vector (%p) found and saved\r\n", old_vector);
		}
	}

	bas_vector = bas_sd_vector(old_vector);
	printf("got vector from BaS: %p\r\n", bas_vector);
	//setcookie('XHDI', (uint32_t) bas_vector);
	XHNewCookie(old_vector, bas_vector);
	printf("vector to BaS driver set\r\n");

	return 0;
}
