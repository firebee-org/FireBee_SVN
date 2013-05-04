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

#define CLOBBER_REGISTERS "memory" /* */

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
#define e_xhdi_version	xhdi_version(xhdi_entrypoint)

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
				"lea			%[entry],a0\n\t"				\
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
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

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
 				"lea			[xhdi_entry],a0\n\t"			\
 				"jsr			(a0)\n\t"				\
 				"lea			10(sp),sp\n\t"					\
 				: "=r"(retvalue)	/* outputs */				\
 				: [xhdi_entry]"g"(xhdi_entry),					\
 				  [major]"g"(major),							\
 				  [minor]"g"(minor),							\
 				  [do_reserve]"g"(do_reserve),					\
 				  [key]"g"(key),								\
 				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
 				  AND_MEMORY									\
 	);															\
 	retvalue;													\
 });

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
				"move.w			#XHDI_STOP,-(sp)\n\t"		\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"move.w			[do_stop],-(sp)\n\t"			\
				"move.w			[key],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [do_stop]"g"(do_stop),						\
				  [key]"g"(key),								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
});

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
 #define e_xhdi_drivemap	xhdi_drivemap(xhdi_entrypoint)

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
#define xhdi_inquire_driver(xhdi_entry, bios_device, name, version, company, ahdi_version, max_ipl)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_INQUIRE_DRIVER,-(sp)\n\t"	\
				"move.w			[bios_device],-(sp)\n\t"		\
				"lea 			[name],-(sp)\n\t"				\
				"lea			[version],-(sp)\n\t"			\
				"move.w			[ahdi_version],-(sp)\n\t"		\
				"move.w			[max_ipl],-(sp)\n\t"			\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			16(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [bios_device]"g"(bios_device),				\
				  [name]"g"(name),								\
				  [version]"g"(version),						\
				  [company]"g"(company),						\
				  [ahdi_version]"g"(ahdi_version),				\
				  [max_ipl]"g"(max_ipl),						\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #9 */
#define xhdi_new_cookie(xhdi_entry, newcookie)					\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w 		#XHDI_NEW_COOKIE,-(sp)\n\t"		\
				"lea			[newcookie],-(sp)\n\t"			\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"addq.l			#6,sp\n\t"						\
				: "=r"(retvalue)	/* outputs */				\
				: [newcookie]"g"(newcookie)	/* inputs */ 	\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
		);														\
		retvalue;												\
})
#define e_xhdi_new_cookie	xhdi_newcookie(xhdi_entrypoint)

/* XHDI #10 */
#define xhdi_read_write(xhdi_entry, major, minor, rwflag, recno, count, buf)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_READ_WRITE,-(sp)\n\t"		\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"move.w			[rwflag],-(sp)\n\t"				\
				"lea			[recno],-(sp)\n\t"				\
				"move.w			[count],-(sp)\n\t"				\
				"lea			[buf],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			18(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [rwflag]"g"(rwflag)							\
				  [recno]"g"(recno),							\
				  [count]"g"(count),							\
				  [buf]"g"(buf)									\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #11 */
#define xhdi_inquire_target2(xhdi_entry, major, minor, block_size, device_flags, product_name, stringlen)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_INQUIRE_TARGET2,-(sp)\n\t"\
				"move.w			[major],-(sp)\n\t"				\
				"move.w 		[minor],-(sp)\n\t"				\
				"lea			[block_size],-(sp)\n\t"			\
				"lea			[recno],-(sp)\n\t"				\
				"lea			[device_flags],-(sp)\n\t"		\
				"lea			[product_name],-(sp)\n\t"		\
				"move.w			[stringlen],-(sp)\n\t"			\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			24(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [blocksize]"g"(blocksize)						\
				  [device_flags]"g"(device_flags),				\
				  [product_name]"g"(product_name),				\
				  [stringlen]"g"(stringlen)						\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #12 */
#define xhdi_inquire_device2(xhdi_entry, bios_device, major, minor, start_sector, bpb, blocks, partid)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DEVICE2,-(sp)\n\t"		\
				"move.w			[bios_device],-(sp)\n\t"		\
				"lea			[major],-(sp)\n\t"				\
				"lea	 		[minor],-(sp)\n\t"				\
				"lea			[start_sector],-(sp)\n\t"		\
				"lea			[bpb],-(sp)\n\t"				\
				"lea			[blocks],-(sp)\n\t"				\
				"lea			[part_id],-(sp)\n\t"			\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			28(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [bios_device]"g"(bios_device),				\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [start_sector]"g"(start_sector)				\
				  [bpb]"g"(bpb),								\
				  [blocks]"g"(blocks),							\
				  [partid]"g"(partid)							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #13 */
#define xhdi_driver_special(xhdi_entry, key1, key2, subopcode, data)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DRIVER_SPECIAL,-(sp)\n\t"	\
				"move.l			[key1],-(sp)\n\t"				\
				"move.l			[key2],-(sp)\n\t"				\
				"move.w	 		[subopcode],-(sp)\n\t"			\
				"lea			[data],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			16(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [key1]"g"(key1),								\
				  [key2]"g"(key2),								\
				  [subopcode]"g"(subopcode),					\
				  [data]"g"(data)								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #14 */
#define xhdi_get_capacyty(xhdi_entry, major, minor, blocks, bs)	\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_GET_CAPACITY,-(sp)\n\t"	\
				"move.w			[major],-(sp)\n\t"				\
				"move.w			[minor],-(sp)\n\t"				\
				"lea	 		[blocks],-(sp)\n\t"				\
				"lea			[bs],-(sp)\n\t"					\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			12(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [blocks]"g"(blocks),							\
				  [bs]"g"(bs)									\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #15 */
#define xhdi_medium_changed(xhdi_entry, major, minor)			\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_MEDIUM_CHANGED,-(sp)\n\t"	\
				"move.w			[major],-(sp)\n\t"				\
				"move.w			[minor],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			12(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #16 */
#define xhdi_mint_info(xhdi_entry, opcode, data)				\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_MINT_INFO,-(sp)\n\t"	\
				"move.w			[opcode],-(sp)\n\t"				\
				"lea			[data],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			8(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [opcode]"g"(opcode),							\
				  [data]"g"(data),								\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #17 */
#define xhdi_dos_limits(xhdi_entry, which, limit)				\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_DOS_LIMITS,-(sp)\n\t"		\
				"move.w			[which],-(sp)\n\t"				\
				"move.l			[limit],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			8(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [which]"g"(which),							\
				  [limit]"g"(limit),							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #18 */
#define xhdi_last_access(xhdi_entry, major, minor, ms)			\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_LAST_ACCESS,-(sp)\n\t"	\
				"move.w			[major],-(sp)\n\t"				\
				"move.w			[minor],-(sp)\n\t"				\
				"lea			[ms],-(sp)\n\t"					\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			10(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				  [ms]"g"(ms)									\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

/* XHDI #18 */
#define xhdi_last_reaccess(xhdi_entry, major, minor)			\
__extension__													\
	({															\
		register long retvalue __asm__("d0");					\
																\
		__asm__ volatile(										\
				"move.w			#XHDI_LAST_ACCESS,-(sp)\n\t"	\
				"move.w			[major],-(sp)\n\t"				\
				"move.w			[minor],-(sp)\n\t"				\
				"lea			%[entry],a0\n\t"				\
				"jsr			(a0)\n\t"						\
				"lea			6(sp),sp\n\t"					\
				: "=r"(retvalue)	/* outputs */				\
				: [xhdi_entry]"g"(xhdi_entry),					\
				  [major]"g"(major),							\
				  [minor]"g"(minor),							\
				: CLOBBER_REGISTERS		/* clobbered regs */ 	\
				  AND_MEMORY									\
	);															\
	retvalue;													\
})

#endif /* XHDI_H_ */
