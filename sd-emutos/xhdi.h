/*
 * xhdi.h
 *
 *  Created on: 03.05.2013
 *      Author: mfro
 */

#ifndef XHDI_H_
#define XHDI_H_

/* XHDI function numbers */

#define XHDI_VERSION			0
#define XHDI_INQUIRE_TARGET		1
#define XHDI_RESERVE			2
#define XHDI_LOCK				3
#define XHDI_STOP				4
#define XHDI_EJECT				5
#define XHDI_DRIVEMAP			6
#define XHDI_INQUIRE_DEVICE		7
#define XHDI_INQUIRE_DRIVER		8
#define XHDI_NEW_COOKIE			9
#define XHDI_READ_WRITE			10
#define XHDI_INQUIRE_TARGET2	11
#define XHDI_INQUIRE_DEVICE2	12
#define XHDI_DRIVER_SPECIAL		13
#define XHDI_GET_CAPACITY		14
#define XHDI_MEDIUM_CHANGED		15
#define XHDI_MINT_INFO			16
#define XHDI_DOS_LIMITS			17
#define XHDI_LAST_ACCESS		18
#define XHDI_REACCESS			19

/* XHDI error codes */

#define	E_OK		0		/* OK */
#define ERROR		-1		/* unspecified error */
#define EDRVNR		-2		/* drive not ready */
#define EUNDEV		-15		/* invalid device/target number */
#define EINVFN		-32		/* invalid function number */
#define EACCDN		-36		/* access denied (device currently reserved) */
#define EDRIVE		-46		/* BIOS device not served by driver */

/* XHDI device capabilities */

#define XH_TARGET_STOPPABLE	(1 << 0)
#define XH_TARGET_REMOVABLE (1 << 1)
#define XH_TARGET_LOCKABLE 	(1 << 2)
#define XH_TARGET_EJECTABLE	(1 << 3)
#define XH_TARGET_LOCKED	(1 << 29)
#define XH_TARGET_STOPPED	(1 << 30)
#define XH_TARGET_RESERVED	(1 << 31)

#ifndef _FEATURES_H
#include <features.h>
#endif	/* _FEATURES_H */

extern long xhdi_entrypoint;

/* XHDI #0 */
#define xhdi_version(xhdi_entry)								\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w 		#XHDI_VERSION,-(sp)\n\t"		\
				"jsr			[xhdi_entry]\n\t"				\
				"addq.l			#2,sp\n\t"						\
				: ="r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry)	/* inputs */ 	\
				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2"	/* clobbered regs */ \
				  AND_MEMORY									\
		);														\
		retvalue;												\
});
#define e_xhdi_version	xhdi_version(xhdi_entrypoint)

/* XHDI #1 */
#define xhdi_inquire_target(xhdi_entry, major, minor, block_size, flags, product_name)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_INQUIRE_TARGET,-(sp)\n\t"	\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"lea			[block_size],-(sp)\n\t"			\
				"move.l			[flags],-(sp)\n\t"				\
				"lea			[product_name],-(sp)\n\t"		\
				"jsr			[xhdi_entry]\n\t"				\
				"lea			18(sp),sp\n\t"					\
				: ="r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [block_size]"g"(block_size),					\
				  [flags]"g"(flags),							\
				  [product_name]"g"(product_name)				\
				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2" /* clobbered regs */ \
				  AND_MEMORY									\
	);															\
	retvalue;													\
});

 /* XHDI #2 */
 #define xhdi_reserve(xhdi_entry, major, minor, do_reserve, key)	\
 __extension__													\
 	({															\
 		register long retvalue __asm__("d0");					\
 																\
 		__asm__ volatile(										\
 				"move.w			#XHDI_RESERVE,-(sp)\n\t"		\
 				"move.w			[major],-(sp)\n\t"				\
 				"move.w 		[minor],-(sp)\n\t"				\
 				"move.w			[do_reserve],-(sp)\n\t"			\
 				"move.w			[key],-(sp)\n\t"				\
 				"jsr			[xhdi_entry]\n\t"				\
 				"lea			10(sp),sp\n\t"					\
 				: ="r"(retvalue)	/* outputs */				\
 				: [xhdi_entry]"g"(xhdi_entry),					\
 				  [major]"g"(major),							\
 				  [minor]"g"(minor),							\
 				  [do_reserve]"g"(do_reserve),					\
 				  [key]"g"(key),								\
 				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2" /* clobbered regs */ \
 				  AND_MEMORY									\
 	);															\
 	retvalue;													\
 });

/* XHDI #3 */
#define xhdi_lock(xhdi_entry, major, minor, do_lock, key)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DO_LOCK,-(sp)\n\t"		\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"move.w			[do_lock],-(sp)\n\t"			\
				"move.w			[key],-(sp)\n\t"				\
				"jsr			[xhdi_entry]\n\t"				\
				"lea			10(sp),sp\n\t"					\
				: ="r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [do_lock]"g"(do_lock),						\
				  [key]"g"(key),								\
				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2" /* clobbered regs */ \
				  AND_MEMORY									\
	);															\
	retvalue;													\
});

/* XHDI #4 */
#define xhdi_stop(xhdi_entry, major, minor, do_stop, key)		\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DO_STOP,-(sp)\n\t"		\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"move.w			[do_stop],-(sp)\n\t"			\
				"move.w			[key],-(sp)\n\t"				\
				"jsr			[xhdi_entry]\n\t"				\
				"lea			10(sp),sp\n\t"					\
				: ="r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [do_stop]"g"(do_stop),						\
				  [key]"g"(key),								\
				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2" /* clobbered regs */ \
				  AND_MEMORY									\
	);															\
	retvalue;													\
});

/* XHDI #5 */
#define xhdi_eject(xhdi_entry, major, minor, do_eject, key)		\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DO_STOP,-(sp)\n\t"		\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"move.w			[do_eject],-(sp)\n\t"			\
				"move.w			[key],-(sp)\n\t"				\
				"jsr			[xhdi_entry]\n\t"				\
				"lea			10(sp),sp\n\t"					\
				: ="r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [do_stop]"g"(do_eject),						\
				  [key]"g"(key),								\
				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2" /* clobbered regs */ \
				  AND_MEMORY									\
	);															\
	retvalue;													\
});

 /* XHDI #6 */
 #define xhdi_drivemap(xhdi_entry)								\
 __extension__													\
 	({															\
 		register long retvalue __asm__("d0");					\
 																\
 		__asm__ volatile(										\
 				"move.w 		#XHDI_DRIVEMAP,-(sp)\n\t"		\
 				"jsr			[xhdi_entry]\n\t"				\
 				"addq.l			#2,sp\n\t"						\
 				: ="r"(retvalue)	/* outputs */				\
 				: [xhdi_entry]"g"(xhdi_entry)	/* inputs */ 	\
 				: CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2"	/* clobbered regs */ \
 				  AND_MEMORY									\
 		);														\
 		retvalue;												\
 });
 #define e_xhdi_drivemap	xhdi_drivemap(xhdi_entrypoint)

#ifdef _NOT_USED_
extern uint32_t xhdi_inquire_device(UINT16_T bios_device, UINT16_T *major, UINT16_T *minor,
        uint32_t *start_sector, /* BPB */ void *bpb);	/* XHDI 7 */

extern uint32_t xhdi_inquire_driver(UINT16_T bios_device, char *name, char *version,
		char *company, UINT16_T *ahdi_version, UINT16_T *maxIPL);	/* XHDI 8 */

extern uint32_t xhdi_new_cookie(void *newcookie);	/* XHDI 9 */

extern uint32_t xhdi_read_write(UINT16_T major, UINT16_T minor, UINT16_T rwflag,
        uint32_t recno, UINT16_T count, void *buf);	/* XHDI 10 */

extern uint32_t xhdi_inquire_target2(UINT16_T major, UINT16_T minor, uint32_t *block_size,
        uint32_t *device_flags, char *product_name, UINT16_T stringlen);	/* XHDI 11 */

extern uint32_t xhdi_inquire_device2(UINT16_T bios_device, UINT16_T *major, UINT16_T *minor,
        UINT16_T *start_sector, /* BPB */ void *bpb, uint32_t *blocks, char *partid); /* XHDI 12 */

extern uint32_t xhdi_driver_special(uint32_t key1, uint32_t key2, UINT16_T subopcode, void *data); /* XHDI 13 */

extern uint32_t xhdi_get_capacity(UINT16_T major, UINT16_T minor, uint32_t *blocks, uint32_t *bs); /* XHDI 14 */

extern uint32_t xhdi_medium_changed(UINT16_T major, UINT16_T minor);	/* XHDI 15 */

extern uint32_t xhdi_mint_info(UINT16_T opcode, void *data);			/* XHDI 16 */

extern uint32_t xhdi_dos_limits(UINT16_T which, uint32_t limit);		/* XHDI 17 */

extern uint32_t xhdi_last_access(UINT16_T major, UINT16_T minor, uint32_t *ms);	/* XHDI 18 */

extern uint32_t xhdi_reaccess(UINT16_T major, UINT16_T minor);	/* XHDI 19 */

#endif /* _NOT_USED_ */


#endif /* XHDI_H_ */
