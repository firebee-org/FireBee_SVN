.public 	_illegal_instruction
.public 	_illegal_table_make

.include 	"startcf.h"
.include	"ii_macro.h"
.include	"ii_func.h"
.include	"ii_op.h"
.include	"ii_opc.h"
.include	"ii_add.h"
.include	"ii_sub.h"
.include	"ii_or.h"
.include	"ii_and.h"
.include	"ii_dbcc.h"
.include	"ii_shd.h"
.include	"ii_movem.h"
.include	"ii_lea.h"
.include	"ii_shift.h"
.include	"ii_exg.h"
.include	"ii_movep.h"
.include	"ii_ewf.h"
.include	"ii_move.h"

.extern		_ii_shift_vec
.extern		ewf

/*******************************************************/
.text
ii_error:
	nop
	halt
	nop
	nop
	
_illegal_instruction:
#ifdef	ii_on
	move.w		#0x2700,sr
	lea			-ii_ss(a7),a7
	movem.l		d0/d1/a0/a1,(a7)
	move.l		pc_off(a7),a0			// pc
	mvz.w		(a0)+,d0				// code
	lea			table,a1
	move.l		0(a1,d0*4),a1
	jmp			(a1)
/*************************************************************************************************/
#endif
_illegal_table_make:
#ifdef	ii_on
	lea			table,a0
	moveq		#0,d0
_itm_loop:
	move.l		#ii_error,(a0)+
	addq.l		#1,d0
	cmp.l		#0xF000,d0
	bne			_itm_loop
//-------------------------------------------------------------------------
	ii_ewf_lset		// diverse fehlende adressierungn
//-------------------------------------------------------------------------
// 0x0000 
// ori
	ii_lset_op	00
// andi
	ii_lset_op	02
// subi
	ii_lset_op	04
// addi
	ii_lset_op	06
// eori
	ii_lset_op	0a
// cmpi
	ii_lset_op	0c
// movep
	ii_movep_lset	
//-------------------------------------------------------------------------
// 0x1000 move.b
// 0x2000 move.l
// 0x3000 move.w
	ii_move_lset
//-------------------------------------------------------------------------
// 0x4000 
//-------------------------------------------------------------------------
// negx
	ii_lset_op	40
// neg
	ii_lset_op	44
// not
	ii_lset_op	46
//---------------------------------------------------------------------------------------------
// lea	d8(ax,dy.w),az; d8(pc,dy.w),az
//-------------------------------------------------------------------
	ii_lea_lset
//-------------------------------------------------------------------
// movem 
//-------------------------------------------------------------------
	ii_movem_lset
//-------------------------------------------------------------------------
// 0x5000
//-------------------------------------------------------------------------
// addq, subq
	ii_lset_op	50
	ii_lset_op	51
	ii_lset_op	52
	ii_lset_op	53
	ii_lset_op	54
	ii_lset_op	55
	ii_lset_op	56
	ii_lset_op	57
	ii_lset_op	58
	ii_lset_op	59
	ii_lset_op	5a
	ii_lset_op	5b
	ii_lset_op	5c
	ii_lset_op	5d
	ii_lset_op	5e
	ii_lset_op	5f
// dbcc
	ii_lset_dbcc
// scc
	ii_lset_opc	50
	ii_lset_opc	51
	ii_lset_opc	52
	ii_lset_opc	53
	ii_lset_opc	54
	ii_lset_opc	55
	ii_lset_opc	56
	ii_lset_opc	57
	ii_lset_opc	58
	ii_lset_opc	59
	ii_lset_opc	5a
	ii_lset_opc	5b
	ii_lset_opc	5c
	ii_lset_opc	5d
	ii_lset_opc	5e
	ii_lset_opc	5f
//-------------------------------------------------------------------------
// 0x8000		or
//-------------------------------------------------------------------------
	ii_lset_func	8
//-------------------------------------------------------------------------
// 0x9000		sub
//-------------------------------------------------------------------------
	ii_lset_func	9
//-------------------------------------------------------------------------
// 0xb000		
//-------------------------------------------------------------------------
// eor
	ii_lset_op	b1
	ii_lset_op	b3
	ii_lset_op	b5
	ii_lset_op	b7
	ii_lset_op	b9
	ii_lset_op	bb
	ii_lset_op	bd
	ii_lset_op	bf
//-------------------------------------------------------------------------
// 0xc000		
//-------------------------------------------------------------------------
// and
	ii_lset_func	c
// exg
	ii_exg_lset
//-------------------------------------------------------------------------
// 0xd000		add
//-------------------------------------------------------------------------
	ii_lset_func	d
//-------------------------------------------------------------------------
// 0xe000
//-------------------------------------------------------------------------
// shift register
	ii_shift_lset	e	
//-------------------------------------------------
// differenz zwischen orginal und gemoved korrigieren
	lea			ii_error(pc),a1
	move.l		a1,d1
	sub.l		#ii_error,d1
	lea			table,a0
	moveq		#0,d0
_itkorr_loop:
	add.l		d1,(a0)+
	addq.l		#1,d0
	cmp.l		#0xF000,d0
	bne			_itkorr_loop
#endif
	rts
#ifdef	ii_on
//***********************************************************************************/
//-------------------------------------------------------------------------
		ii_ewf_func		// diverse fehlende adressierungn
//-------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
// 0x0000
//--------------------------------------------------------------------
// ori 00
		ii_op		00,or.l,i
//--------------------------------------------------------------------
// andi 02
		ii_op		02,and.l,i
//--------------------------------------------------------------------
// subi 04
		ii_op		04,and.l,i
//--------------------------------------------------------------------
// addi 06
		ii_op		06,add.l,i
//--------------------------------------------------------------------
// eori 0a
		ii_op		0a,eor.l,i
//--------------------------------------------------------------------
// cmpi 0c
		ii_op		0c,cmp.l,i
//--------------------------------------------------------------------
// movep
	ii_movep_func	
///---------------------------------------------------------------------------------------------
// 0x1000 move.b
// 0x2000 move.l	
// 0x3000 move.w
		ii_move_op
//---------------------------------------------------------------------------------------------
// 0x4000
//---------------------------------------------------------------------------------------------
// neg 0x40..
		ii_op		40,negx.l,n
//---------------------------------------------------------------------------------------------
// neg 0x44..
		ii_op		44,neg.l,n
//---------------------------------------------------------------------------------------------
// not 0x46..
		ii_op		46,not.l,n
//---------------------------------------------------------------------------------------------
// lea	d8(ax,dy.w),az; d8(pc,dy.w),az
//-------------------------------------------------------------------
		ii_lea_func
//-------------------------------------------------------------------
// movem
//--------------------------------------------------------------------
ii_movem_func
//---------------------------------------------------------------------------------------------
// 0x5000
//---------------------------------------------------------------------------------------------
//dbcc
		ii_dbcc_func
// addq 0x5...
		ii_op		50,addq.l #8,q
		ii_op		52,addq.l #1,q
		ii_op		54,addq.l #2,q
		ii_op		56,addq.l #3,q
		ii_op		58,addq.l #4,q
		ii_op		5a,addq.l #5,q
		ii_op		5c,addq.l #6,q
		ii_op		5e,addq.l #7,q
//---------------------------------------------------------------------------------------------
// subq 0x5...
		ii_op		51,subq.l #8,q
		ii_op		53,subq.l #1,q
		ii_op		55,subq.l #2,q
		ii_op		57,subq.l #3,q
		ii_op		59,subq.l #4,q
		ii_op		5b,subq.l #5,q
		ii_op		5d,subq.l #6,q
		ii_op		5f,subq.l #7,q
//---------------------------------------------------------------------------------------------
// 0x5... scc
		ii_opc		50,st,c
		ii_opc		51,sf,c
		ii_opc		52,shi,c
		ii_opc		53,sls,c
		ii_opc		54,scc,c
		ii_opc		55,scs,c
		ii_opc		56,sne,c
		ii_opc		57,seq,c
		ii_opc		58,svc,c
		ii_opc		59,svs,c
		ii_opc		5a,spl,c
		ii_opc		5b,smi,c
		ii_opc		5c,sge,c
		ii_opc		5d,slt,c
		ii_opc		5e,sgt,c
		ii_opc		5f,sle,c
//---------------------------------------------------------------------------------------------
// 0x6000
//--------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
// 0x7000
//--------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
// 0x8000
//---------------------------------------------------------------------------------------------
// or
		ii_func		8,or
//---------------------------------------------------------------------------------------------
// 0x9000
//---------------------------------------------------------------------------------------------
// sub
		ii_func		9,sub
//---------------------------------------------------------------------------------------------
// 0xa000
//--------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
// 0xb000
//---------------------------------------------------------------------------------------------
// eor
		ii_op		b1,eor.l d0,q
		ii_op		b3,eor.l d1,q
		ii_op		b5,eor.l d2,q
		ii_op		b7,eor.l d3,q
		ii_op		b9,eor.l d4,q
		ii_op		bb,eor.l d5,q
		ii_op		bd,eor.l d6,q
		ii_op		bf,eor.l d7,q
//---------------------------------------------------------------------------------------------
// 0xc000
//---------------------------------------------------------------------------------------------
// and
		ii_func		c,and
// exg
		ii_exg_func
//---------------------------------------------------------------------------------------------
// 0xd000
//---------------------------------------------------------------------------------------------
// add
		ii_func		d,add
//---------------------------------------------------------------------------------------------
// 0xe000 shift
//--------------------------------------------------------------------
		ii_shift_op
//--------------------------------------------------------------------
// 0xf000
//--------------------------------------------------------------------
#endif