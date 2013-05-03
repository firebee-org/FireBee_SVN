/*
 * cookie.c
 *
 *  Created on: 03.05.2013
 *      Author: mfro
 */

#include <stdint.h>
#include <osbind.h>

static uint32_t cookieptr(void)
{
	return * (uint32_t *) 0x5a0L;
}

int getcookie(uint32_t cookie, uint32_t *p_value)
{
	uint32_t *cookiejar = (long *) Supexec(cookieptr);

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

void setcookie(uint32_t cookie, uint32_t value)
{
	uint32_t *cookiejar = (uint32_t *) Supexec(cookieptr);

	do
	{
		if (cookiejar[0] == cookie)
		{
			cookiejar[1] = value;
			return;
		}
		else
			cookiejar = &(cookiejar[2]);
	} while (cookiejar[-2]);
}

