/*
 * cookie.h
 *
 *  Created on: 05.05.2013
 *      Author: mfro
 */

#ifndef _COOKIE_H_
#define _COOKIE_H_

#include <stdint.h>

extern int getcookie(uint32_t cookie, uint32_t *p_value);
extern void setcookie(uint32_t cookie, uint32_t value);

#endif /* _COOKIE_H_ */
