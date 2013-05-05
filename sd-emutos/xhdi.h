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

/* XHDI DOS limits */

#define XH_DL_SECSIZ (0) 	/* Maximum sector size (BIOS level) */
#define XH_DL_MINFAT (1) 	/* Minimum number of FATs */
#define XH_DL_MAXFAT (2) 	/* Maximal number of FATs */
#define XH_DL_MINSPC (3) 	/* Minimum sectors per cluster */
#define XH_DL_MAXSPC (4) 	/* Maximum sectors per cluster */
#define XH_DL_CLUSTS (5) 	/* Maximum number of clusters of a 16-bit FAT */
#define XH_DL_MAXSEC (6) 	/* Maximum number of sectors */
#define XH_DL_DRIVES (7) 	/* Maximum number of BIOS drives supported by the DOS */
#define XH_DL_CLSIZB (8) 	/* Maximum cluster size */
#define XH_DL_RDLEN (9) 	/* Max. (bpb->rdlen * bpb->recsiz/32) */
#define XH_DL_CLUSTS12 (12) 	/* Max. number of clusters of a 12-bit FAT */
#define XH_DL_CLUSTS32 (13) 	/* Max. number of clusters of a 32 bit FAT */
#define XH_DL_BFLAGS (14) 	/* Supported bits in bpb->bflags  */

#ifndef _FEATURES_H
#include <features.h>
#endif	/* _FEATURES_H */


extern long xhdi_entrypoint;

#define CLOBBER_REGISTERS "a0","memory" /* */

/* XHDI #0 */
#define XHGetVersion(xhdi_entry)								\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w 		#0,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#2,sp\n\t"						\
				: [retvalue]"=r"(retvalue)		/* outputs */	\
				: [entry] "g" (xhdi_entry)		/* inputs */ 	\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
		);														\
		retvalue;												\
})

/* XHDI #1 */
#define XHInqTarget(xhdi_entry, major, minor, block_size, flags, product_name)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_product_name],-(sp)\n\t"	\
				"move.l			%[a_flags],-(sp)\n\t"			\
				"move.l			%[a_block_size],-(sp)\n\t"		\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#1,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			18(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_block_size]"g"(block_size),				\
				  [a_flags]"g"(flags),							\
				  [a_product_name]"g"(product_name)				\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

 /* XHDI #2 */
 #define XHReserve(xhdi_entry, major, minor, do_reserve, key)	\
 __extension__													\
 	({															\
 		register long retvalue __asm__("d0");					\
 																\
 		__asm__ volatile(										\
 				"move.w			%[a_key],-(sp)\n\t"				\
 				"move.w			%[a_do_reserve],-(sp)\n\t"		\
 				"move.w 		%[a_minor],-(sp)\n\t"			\
 				"move.w			%[a_major],-(sp)\n\t"			\
 				"move.w			#2,-(sp)\n\t"					\
 				"move.l			%[entry],a0\n\t"				\
 				"jsr			(a0)\n\t"						\
 				"lea			10(sp),sp\n\t"					\
 				: "=r"(retvalue)		/* outputs */			\
 				: [entry]"g"(xhdi_entry),						\
 				  [a_major]"g"(major),							\
 				  [a_minor]"g"(minor),							\
 				  [a_do_reserve]"g"(do_reserve),				\
 				  [a_key]"g"(key)								\
 				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
 	);															\
 	retvalue;													\
 })

/* XHDI #3 */
#define XHLock(xhdi_entry, major, minor, do_lock, key)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_key],-(sp)\n\t"				\
				"move.w			%[a_do_lock],-(sp)\n\t"			\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#3,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_do_lock]"g"(do_lock),						\
				  [a_key]"g"(key)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #4 */
#define XHStop(xhdi_entry, major, minor, do_stop, key)			\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_key],-(sp)\n\t"				\
				"move.w			%[a_do_stop],-(sp)\n\t"			\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#4,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_do_stop]"g"(do_stop),						\
				  [a_key]"g"(key)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #5 */
#define XHEject(xhdi_entry, major, minor, do_eject, key)		\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_key],-(sp)\n\t"				\
				"move.w			%[a_do_eject],-(sp)\n\t"		\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#5,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_do_eject]"g"(do_eject),					\
				  [a_key]"g"(key)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

 /* XHDI #6 */
#define XHDrvMap(xhdi_entry)									\
__extension__													\
 	({															\
 		register long retvalue __asm__("d0");					\
 																\
 		__asm__ volatile(										\
 				"move.w 		#6,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#2,sp\n\t"						\
 				: [retvalue] "=r" (retvalue)/* outputs */		\
 				: [entry] "m" (xhdi_entry)	/* inputs */ 		\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
 		);														\
 		retvalue;												\
})

/* XHDI #7 */
#define XHInqDev(xhdi_entry, bios_device, major, minor, start_sector, bpb)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_bpb],-(sp)\n\t"				\
				"move.l			%[a_start_sector],-(sp)\n\t"	\
				"move.l	 		%[a_minor],-(sp)\n\t"			\
				"move.l			%[a_major],-(sp)\n\t"			\
				"move.w			%[a_bios_device],-(sp)\n\t"		\
				"move.w			#7,-(sp)\n\t"					\
				"move.l			%[a_entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			20(sp),sp\n\t"					\
				: [retvalue]"=r"(retvalue)	/* outputs */		\
				: [a_entry]"g"(xhdi_entry),						\
				  [a_bios_device]"g"(bios_device),				\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_start_sector]"g"(start_sector),			\
				  [a_bpb]"g"(bpb)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #8 */
#define XHInqDriver(xhdi_entry, bios_device, name, version, company, ahdi_version, max_ipl)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_max_ipl],-(sp)\n\t"			\
				"move.l			%[a_ahdi_version],-(sp)\n\t"	\
				"move.l			%[a_company],-(sp)\n\t"			\
				"move.l			%[a_version],-(sp)\n\t"			\
				"move.l			%[a_name],-(sp)\n\t"			\
				"move.w			%[a_bios_device],-(sp)\n\t"		\
				"move.w			#8,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			16(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_bios_device]"g"(bios_device),				\
				  [a_name]"g"(name),							\
				  [a_version]"g"(version),						\
				  [a_company]"g"(company),						\
				  [a_ahdi_version]"g"(ahdi_version),			\
				  [a_max_ipl]"g"(max_ipl)						\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #9 */
#define XHNewCookie(xhdi_entry, newcookie)						\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_newcookie],-(sp)\n\t"		\
				"move.w 		#9,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#6,sp\n\t"						\
				: "=r"(retvalue)	/* outputs */				\
				: [entry] "g" (xhdi_entry),						\
				  [a_newcookie]"g"(newcookie)	/* inputs */ 	\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
		);														\
		retvalue;												\
})

/* XHDI #10 */
#define XHReadWrite(xhdi_entry, major, minor, rwflag, recno, count, buf)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_buf],-(sp)\n\t"				\
				"move.w			%[a_count],-(sp)\n\t"			\
				"move.l			%[a_recno],-(sp)\n\t"			\
				"move.w			%[a_rwflag],-(sp)\n\t"			\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#10,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			18(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_rwflag]"g"(rwflag),						\
				  [a_recno]"g"(recno),							\
				  [a_count]"g"(count),							\
				  [a_buf]"g"(buf)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #11 */
#define XHInqTarget2(xhdi_entry, major, minor, block_size, device_flags, product_name, stringlen)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_stringlen],-(sp)\n\t"		\
				"move.l			%[a_product_name],-(sp)\n\t"	\
				"move.l			%[a_device_flags],-(sp)\n\t"	\
				"move.l			%[a_block_size],-(sp)\n\t"		\
				"move.w 		%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#11,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			24(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_block_size]"g"(block_size),				\
				  [a_device_flags]"g"(device_flags),			\
				  [a_product_name]"g"(product_name),			\
				  [a_stringlen]"g"(stringlen)					\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #12 */
#define XHInqDev2(xhdi_entry, bios_device, major, minor, start_sector, bpb, blocks, partid)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_partid],-(sp)\n\t"			\
				"move.l			%[a_blocks],-(sp)\n\t"			\
				"move.l			%[a_bpb],-(sp)\n\t"				\
				"move.l			%[a_start_sector],-(sp)\n\t"	\
				"move.l	 		%[a_minor],-(sp)\n\t"			\
				"move.l			%[a_major],-(sp)\n\t"			\
				"move.w			%[a_bios_device],-(sp)\n\t"		\
				"move.w			#12,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			28(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_bios_device]"g"(bios_device),				\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_start_sector]"g"(start_sector),			\
				  [a_bpb]"g"(bpb),								\
				  [a_blocks]"g"(blocks),						\
				  [a_partid]"g"(partid)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #13 */
#define XHDriverSpecial(xhdi_entry, key1, key2, subopcode, data)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_data],-(sp)\n\t"			\
				"move.w	 		%[a_subopcode],-(sp)\n\t"		\
				"move.l			%[a_key2],-(sp)\n\t"			\
				"move.l			%[a_key1],-(sp)\n\t"			\
				"move.w			#13,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			16(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_key1]"g"(key1),							\
				  [a_key2]"g"(key2),							\
				  [a_subopcode]"g"(subopcode),					\
				  [a_data]"g"(data)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #14 */
#define XHGetCapacity(xhdi_entry, major, minor, blocks, bs)		\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_bs],-(sp)\n\t"				\
				"move.l	 		%[a_blocks],-(sp)\n\t"			\
				"move.w			%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#14,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			14(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_blocks]"g"(blocks),						\
				  [a_bs]"g"(bs)									\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #15 */
#define XHMediumChanged(xhdi_entry, major, minor)				\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#15,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#6,sp\n\t"						\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #16 */
#define XHMintInfo(xhdi_entry, opcode, data)					\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_data],-(sp)\n\t"			\
				"move.w			%[a_opcode],-(sp)\n\t"			\
				"move.w			#16,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			8(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_opcode]"g"(opcode),						\
				  [a_data]"g"(data)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #17 */
#define XHDOSLimits(xhdi_entry, which, limit)					\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_limit],-(sp)\n\t"			\
				"move.w			%[a_which],-(sp)\n\t"			\
				"move.w			#17,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			8(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_which]"g"(which),							\
				  [a_limit]"g"(limit)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #18 */
#define XHLastAccess(xhdi_entry, major, minor, ms)				\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.l			%[a_ms],-(sp)\n\t"				\
				"move.w			%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#18,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor),							\
				  [a_ms]"g"(ms)									\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

/* XHDI #19 */
#define XHReaccess(xhdi_entry, major, minor)				\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			%[a_minor],-(sp)\n\t"			\
				"move.w			%[a_major],-(sp)\n\t"			\
				"move.w			#19,-(sp)\n\t"					\
				"move.l			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#6,sp\n\t"						\
				: "=r"(retvalue)	/* outputs */				\
				: [entry]"g"(xhdi_entry),						\
				  [a_major]"g"(major),							\
				  [a_minor]"g"(minor)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
	);															\
	retvalue;													\
})

#endif /* XHDI_H_ */
