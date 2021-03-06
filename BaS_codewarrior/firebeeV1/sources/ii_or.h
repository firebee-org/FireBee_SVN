//--------------------------------------------------------------------
// or
//--------------------------------------------------------------------
/*****************************************************************************************/
//--------------------------------------------------------------------
// byt
//--------------------------------------------------------------------
//--------------------------------------------------------------------
// or.b	#im,dx
//--------------------------------------------------------------------
orbir_macro:.macro
#ifdef	halten_or
	halt
#endif
	move.w		(a0)+,d0
	extb.l		d0
	mvs.b		\2,d1
	or.l		d0,d1
	set_cc0
	move.b		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	ea,dx
//--------------------------------------------------------------------
ordd:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	ea(l)->dy(w),dx z.B. f�r USP
//--------------------------------------------------------------------
orddd:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	mvs.\3		a1,d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	(ea)->dy,dx
//--------------------------------------------------------------------
ordda:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	ea->ay,(ay)+,dx
//--------------------------------------------------------------------
orddai:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	mvs.\3		(a1)+,d0
	move.l		a1,\1
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	ea->ay,-(ay),dx
//--------------------------------------------------------------------
orddad:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	mvs.\3		-(a1),d0
	move.l		a1,\1
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	d16(ay),dx
//--------------------------------------------------------------------
ord16ad:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	mvs.w		(a0)+,d0
	add.l		d0,a1
	mvs.\3		(a1),d0		
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	d8(ay,dy),dx
//--------------------------------------------------------------------
ord8ad:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\1,a1
	jsr			ewf
.ifc	\3,l
	move.l		(a1),d0
	move.l		\2,d1
.else
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
.endif
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	xxx.w,dx
//--------------------------------------------------------------------
orxwd:.macro
#ifdef	halten_or
	halt
#endif
	move.w		(a0)+,a1
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	xxx.l,dx
//--------------------------------------------------------------------
orxld:.macro
#ifdef	halten_or
	halt
#endif
	move.l		(a0)+,a1
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	d16(pc),dx
//--------------------------------------------------------------------
ord16pcd:.macro
	halt
	move.l		a0,a1
	mvs.w		(a0)+,d0
	add.l		d0,a1
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	d8(pc,dy),dx
//--------------------------------------------------------------------
ord8pcd:.macro
#ifdef	halten_or
	halt
#endif
	move.l		a0,a1
	jsr			ewf
.ifc	\3,l
	move.l		(a1),d0
	move.l		\2,d1
.else
	mvs.\3		(a1),d0
	mvs.\3		\2,d1
.endif
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
//  or dy,ea
//--------------------------------------------------------------------
//--------------------------------------------------------------------
// // or	(ea)->dy,dx
//--------------------------------------------------------------------
oreda:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.l		\2,a1
	mvs.\3		(a1),d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,ea->ay,(ay)+
//--------------------------------------------------------------------
oredai:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.l		\2,a1
	mvs.\3		(a1),d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)+
	move.l		a1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,ea->ay,(ay)+
//--------------------------------------------------------------------
oredaid:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	mvs.\3		\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2+
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,ea->ay,-(ay)
//--------------------------------------------------------------------
oredad:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.l		\2,a1
	mvs.\3		-(a1),d1
	move.l		a1,\2
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,ea->ay,-(ay)
//--------------------------------------------------------------------
oredadd:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	mvs.\3		-\2,d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,\2
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,d16(ay)
//--------------------------------------------------------------------
ore16ad:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.l		\2,a1
	mvs.w		(a0)+,d1
	add.l		d1,a1
	mvs.\3		(a1),d1		
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or.w	dx,d8(ay,dy)
//--------------------------------------------------------------------
ore8ad:.macro
#ifdef	halten_or
	halt
#endif
	move.l		\2,a1
	jsr			ewf
.ifc	\3,l
	move.l		(a1),d1
	move.l		\1,d0
.else
	mvs.\3		(a1),d1
	mvs.\3		\1,d0
.endif
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,xxx.w
//--------------------------------------------------------------------
orxwe:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.w		(a0)+,a1
	mvs.\3		(a1),d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // or	dx,xxx.l
//--------------------------------------------------------------------
orxle:.macro
#ifdef	halten_or
	halt
#endif
	mvs.\3		\1,d0
	move.l		(a0)+,a1
	mvs.\3		(a1),d1
	or.l		d0,d1
	set_cc0
	move.\3		d1,(a1)
	ii_end
	.endm;
//--------------------------------------------------------------------
// // ora.w	ea,ax
//--------------------------------------------------------------------
oraw:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// or.w ea,usp
//--------------------------------------------------------------------
orawa7:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	usp?,ax
//--------------------------------------------------------------------
orawu:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	usp?,usp
//--------------------------------------------------------------------
orawua7:.macro
	orawu		\1,\2
	.endm;
//--------------------------------------------------------------------
// // ora.w	d16(ay),ax
//--------------------------------------------------------------------
orawd16a:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	d8(ay,dy),ax
//--------------------------------------------------------------------
orawd8a:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	xxx.w,ax
//--------------------------------------------------------------------
orawxwax:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	xxx.l,ax
//--------------------------------------------------------------------
orawxlax:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	d16(pc),ax
//--------------------------------------------------------------------
orawd16pcax:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	d8(pc,dy),ax
//--------------------------------------------------------------------
orawd8pcax:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.w	#im,ax
//--------------------------------------------------------------------
orawim:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.l	d8(ay,dy),ax
//--------------------------------------------------------------------
orald8a:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // ora.l	d8(pc,dy),ax
//--------------------------------------------------------------------
orald8pcax:.macro
	jmp			ii_error
	.endm;
//*****************************************************************************************
// spezial addx subx etc.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
// // addx	dy,dx
//--------------------------------------------------------------------
ordx:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
// // addx	-(ay),-(ax)
//--------------------------------------------------------------------
ordax:.macro
	jmp			ii_error
	.endm;
//--------------------------------------------------------------------
