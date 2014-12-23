----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the package of the 'Firebee'       ----
---- computer. It is optimized for the use of an Altera Cyclone   ----
---- FPGA (EP3C40F484). This IP-Core is based on the first edi-   ----
---- tion of the Firebee configware originally provided by Fredi  ----
---- Ashwanden  and Wolfgang Förster. This release is IN compa-   ----
---- rision to the first edition completely written IN VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Wolfgang Förster                          ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 of the License, or (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program is distributed IN the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License for more        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along with this program; if not, write to the Free   ----
---- Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K12B  20120801 WF
--   Initial Release of the second edition.
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

PACKAGE firebee_pkg IS
	COMPONENT VIDEO_SYSTEM
		PORT(
			clk_main            : IN STD_LOGIC;
			CLK_33M             : IN STD_LOGIC;
			CLK_25M             : IN STD_LOGIC;
			clk_video           : IN STD_LOGIC;
			CLK_DDR3            : IN STD_LOGIC;
			CLK_DDR2            : IN STD_LOGIC;
			CLK_DDR0            : IN STD_LOGIC;
			CLK_PIXEL           : OUT STD_LOGIC;
            
			vr_d                : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			vr_busy             : IN STD_LOGIC;
            
			fb_adr              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_IN            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_OUT           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_EN_31_16      : OUT STD_LOGIC; -- Hi word.
			FB_AD_EN_15_0       : OUT STD_LOGIC; -- Low word.
			FB_ALE              : IN STD_LOGIC;
			fb_cs_n             : IN STD_LOGIC_VECTOR(3 DOWNTO 1);
			fb_oe_n             : IN STD_LOGIC;
			fb_wr_n             : IN STD_LOGIC;
			fb_size1            : IN STD_LOGIC;
			fb_size0            : IN STD_LOGIC;
            
			vdp_in              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);

			VR_RD               : OUT STD_LOGIC;
			VR_WR               : OUT STD_LOGIC;
			video_reconfig      : OUT STD_LOGIC;

			red                 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			green               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			blue                : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			vsync               : OUT STD_LOGIC;
			hsync               : OUT STD_LOGIC;
			sync_n              : OUT STD_LOGIC;
			blank_n             : OUT STD_LOGIC;
            
			pd_vga_n            : OUT STD_LOGIC;
			video_mod_ta        : OUT STD_LOGIC;

			vd_vz               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			sr_fifo_wre         : IN STD_LOGIC;
			sr_vdmp             : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			fifo_mw             : OUT UNSIGNED (8 DOWNTO 0);
			vdm_sel             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			video_ram_ctr       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			fifo_clr            : OUT STD_LOGIC;

			vdm                 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

			blitter_run         : IN STD_LOGIC;
			blitter_on          : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT VIDEO_CTRL
		PORT(
			clk_main        : IN STD_LOGIC;
			fb_cs_n         : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
			fb_wr_n         : IN STD_LOGIC;
			fb_oe_n         : IN STD_LOGIC;
			fb_size         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			fb_adr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk33m          : IN STD_LOGIC;
			clk25m          : IN STD_LOGIC;
			blitter_run     : IN STD_LOGIC;
			clk_video       : IN STD_LOGIC;
			vr_d            : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			vr_busy         : IN STD_LOGIC;
			color8          : OUT STD_LOGIC;
			fbee_clut_rd    : OUT STD_LOGIC;
			color1          : OUT STD_LOGIC;
			falcon_clut_rdh : OUT STD_LOGIC;
			falcon_clut_rdl : OUT STD_LOGIC;
			falcon_clut_wr  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			clut_st_rd      : OUT STD_LOGIC;
			clut_st_wr      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			clut_mux_adr    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			hsync           : OUT STD_LOGIC;
			vsync           : OUT STD_LOGIC;
			blank_n         : OUT STD_LOGIC;
			sync_n          : OUT STD_LOGIC;
			pd_vga_n        : OUT STD_LOGIC;
			FIFO_RDE        : OUT STD_LOGIC;
			COLOR2          : OUT STD_LOGIC;
			COLOR4          : OUT STD_LOGIC;
			CLK_PIXEL       : OUT STD_LOGIC;
			CLUT_OFF        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			blitter_on      : OUT STD_LOGIC;
			video_ram_ctr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			video_mod_ta    : OUT STD_LOGIC;
			CCR             : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			CCSEL           : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			FBEE_CLUT_WR    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			INTER_ZEI       : OUT STD_LOGIC;
			DOP_FIFO_CLR    : OUT STD_LOGIC;
			video_reconfig  : OUT STD_LOGIC;
			VR_WR           : OUT STD_LOGIC;
			VR_RD           : OUT STD_LOGIC;
			fifo_clr        : OUT STD_LOGIC;
			DATA_IN         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_OUT        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_EN_H       : OUT STD_LOGIC;
			DATA_EN_L       : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT DDR_CTRL is
		PORT(
            clk_main        : IN STD_LOGIC;
            ddr_sync_66m    : IN STD_LOGIC;
            fb_adr          : IN UNSIGNED (31 DOWNTO 0);
            fb_cs1_n        : IN STD_LOGIC;
            fb_oe_n         : IN STD_LOGIC;
            fb_size0        : IN STD_LOGIC;
            fb_size1        : IN STD_LOGIC;
            fb_ale          : IN STD_LOGIC;
            fb_wr_n         : IN STD_LOGIC;
            fifo_clr        : IN STD_LOGIC;
            video_control_register   : IN UNSIGNED (15 DOWNTO 0);
            blitter_adr     : IN UNSIGNED (31 DOWNTO 0);
            blitter_sig     : IN STD_LOGIC;
            blitter_wr      : IN STD_LOGIC;
    
            ddrclk0         : IN STD_LOGIC;
            clk_33m         : IN STD_LOGIC;
            fifo_mw         : IN UNSIGNED (8 DOWNTO 0);
            
            va              : OUT UNSIGNED (12 DOWNTO 0);               -- video Adress bus at the DDR chips
            vwe_n           : OUT STD_LOGIC;                                    -- video memory write enable
            vras_n          : OUT STD_LOGIC;                                    -- video memory RAS
            vcs_n           : OUT STD_LOGIC;                                    -- video memory chip SELECT
            vcke            : OUT STD_LOGIC;                                    -- video memory clock enable
            vcas_n          : OUT STD_LOGIC;                                    -- video memory CAS
            
            fb_le           : OUT UNSIGNED (3 DOWNTO 0);
            fb_vdoe         : OUT UNSIGNED (3 DOWNTO 0);
            
            sr_fifo_wre     : OUT STD_LOGIC;
            sr_ddr_fb       : OUT STD_LOGIC;
            sr_ddr_wr       : OUT STD_LOGIC;
            sr_ddrwr_d_sel  : OUT STD_LOGIC;
            sr_vdmp         : OUT UNSIGNED (7 DOWNTO 0);
            
            video_ddr_ta    : OUT STD_LOGIC;
            sr_blitter_dack : OUT STD_LOGIC;
            ba              : OUT UNSIGNED (1 DOWNTO 0);
            ddrwr_d_sel1    : OUT STD_LOGIC;
            vdm_sel         : OUT UNSIGNED (3 DOWNTO 0);
            data_in         : IN UNSIGNED (31 DOWNTO 0);
            data_out        : OUT UNSIGNED (31 DOWNTO 16);
            data_en_h       : OUT STD_LOGIC;
            data_en_l       : OUT STD_LOGIC
        );
	END COMPONENT;

	COMPONENT INTHANDLER
		PORT(
			clk_main        : IN STD_LOGIC;
			reset_n          : IN STD_LOGIC;
			fb_adr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			fb_cs_n         : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
			fb_size0        : IN STD_LOGIC;
			fb_size1        : IN STD_LOGIC;
			fb_wr_n         : IN STD_LOGIC;
			fb_oe_n         : IN STD_LOGIC;
			FB_AD_IN        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_OUT       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_EN_31_24  : OUT STD_LOGIC;
			FB_AD_EN_23_16  : OUT STD_LOGIC;
			FB_AD_EN_15_8   : OUT STD_LOGIC;
			FB_AD_EN_7_0    : OUT STD_LOGIC;
			PIC_INT         : IN STD_LOGIC;
			E0_INT          : IN STD_LOGIC;
			DVI_INT         : IN STD_LOGIC;
			pci_inta_n      : IN STD_LOGIC;
			pci_intb_n      : IN STD_LOGIC;
			pci_intc_n      : IN STD_LOGIC;
			pci_intd_n      : IN STD_LOGIC;
			mfp_int_n       : IN STD_LOGIC;
			DSP_INT         : IN STD_LOGIC;
			vsync           : IN STD_LOGIC;
			hsync           : IN STD_LOGIC;
			DRQ_DMA         : IN STD_LOGIC;
			irq_n           : OUT STD_LOGIC_VECTOR(7 DOWNTO 2);
			INT_HANDLER_TA  : OUT STD_LOGIC;
			FBEE_CONF       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			TIN0            : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT FBEE_DMA is
		PORT(
			RESET                       : IN STD_LOGIC;
			clk_main                    : IN STD_LOGIC;
			CLK_FDC                     : IN STD_LOGIC;

			fb_adr                      : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
			FB_ALE                      : IN STD_LOGIC;
			fb_size                     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			fb_cs_n                     : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
			fb_oe_n                     : IN STD_LOGIC;
			fb_wr_n                     : IN STD_LOGIC;
			FB_AD_IN                    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_OUT                   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_EN_31_24              : OUT STD_LOGIC;
			FB_AD_EN_23_16              : OUT STD_LOGIC;
			FB_AD_EN_15_8               : OUT STD_LOGIC;
			FB_AD_EN_7_0                : OUT STD_LOGIC;

			ACSI_DIR                    : OUT STD_LOGIC;
			ACSI_D_IN                   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			ACSI_D_OUT                  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ACSI_D_EN                   : OUT STD_LOGIC;
			ACSI_CSn                    : OUT STD_LOGIC;
			ACSI_A1                     : OUT STD_LOGIC;
			ACSI_RESETn                 : OUT STD_LOGIC;
			ACSI_DRQn                   : IN STD_LOGIC;
			ACSI_ACKn                   : OUT STD_LOGIC;

			DATA_IN_FDC                 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_IN_SCSI                : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_OUT_FDC_SCSI			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

			DMA_DRQ_IN                  : IN STD_LOGIC; -- From 1772.
			DMA_DRQ_OUT                 : OUT STD_LOGIC; -- To Interrupt handler.
			DMA_DRQ11                   : OUT STD_LOGIC;
            
			SCSI_DRQ                    : IN STD_LOGIC;
			SCSI_DACKn                  : OUT STD_LOGIC;
			SCSI_INT                    : IN STD_LOGIC;
			SCSI_CSn                    : OUT STD_LOGIC;
			SCSI_CS                     : OUT STD_LOGIC;

			CA                          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			FLOPPY_HD_DD                : IN STD_LOGIC;
			WDC_BSL0                    : OUT STD_LOGIC;
			FDC_CSn                     : OUT STD_LOGIC;
			FDC_WRn                     : OUT STD_LOGIC;
			FD_INT                      : IN STD_LOGIC;
			IDE_INT                     : IN STD_LOGIC;
			DMA_CS                      : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT IDE_CF_SD_ROM is
		PORT(
			RESET               : IN STD_LOGIC;
			clk_main            : IN STD_LOGIC;

			fb_adr              : IN STD_LOGIC_VECTOR(19 DOWNTO 5);
			FB_CS1n             : IN STD_LOGIC;
			fb_wr_n             : IN STD_LOGIC;
			FB_B0               : IN STD_LOGIC;
			FB_B1               : IN STD_LOGIC;

			FBEE_CONF           : IN STD_LOGIC_VECTOR(31 DOWNTO 30);

			RP_UDSn             : OUT STD_LOGIC;
			RP_LDSn             : OUT STD_LOGIC;

			SD_CLK              : OUT STD_LOGIC;
			SD_D0               : IN STD_LOGIC;
			SD_D1               : IN STD_LOGIC;
			SD_D2               : IN STD_LOGIC;
			SD_CD_D3_IN         : IN STD_LOGIC;
			SD_CD_D3_OUT        : OUT STD_LOGIC;
			SD_CD_D3_EN         : OUT STD_LOGIC;
			SD_CMD_D1_IN        : IN STD_LOGIC;
			SD_CMD_D1_OUT       : OUT STD_LOGIC;
			SD_CMD_D1_EN        : OUT STD_LOGIC;
			SD_CARD_DETECT      : IN STD_LOGIC;
			SD_WP               : IN STD_LOGIC;

			IDE_RDY             : IN STD_LOGIC;
			IDE_WRn             : buffer STD_LOGIC;
			IDE_RDn             : OUT STD_LOGIC;
			IDE_CSn             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			IDE_DRQn            : OUT STD_LOGIC;
			IDE_CF_TA           : OUT STD_LOGIC;

			ROM4n               : OUT STD_LOGIC;
			ROM3n               : OUT STD_LOGIC;

			CF_WP               : IN STD_LOGIC;
			CF_CSn              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT FBEE_BLITTER is
		PORT(
			reset_n         : IN STD_LOGIC;
			clk_main        : IN STD_LOGIC;
			CLK_DDR0        : IN STD_LOGIC;
			fb_adr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_ALE          : IN STD_LOGIC;
			fb_size1        : IN STD_LOGIC;
			fb_size0        : IN STD_LOGIC;
			fb_cs_n         : IN STD_LOGIC_VECTOR(3 DOWNTO 1);
			fb_oe_n         : IN STD_LOGIC;
			fb_wr_n         : IN STD_LOGIC;
			DATA_IN         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_OUT        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_EN         : OUT STD_LOGIC;
			blitter_on      : IN STD_LOGIC;
			BLITTER_DIN     : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			BLITTER_DACK_SR : IN STD_LOGIC;
			blitter_run     : OUT STD_LOGIC;
			BLITTER_DOUT    : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			BLITTER_ADR     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			BLITTER_SIG     : OUT STD_LOGIC;
			BLITTER_WR      : OUT STD_LOGIC;
			BLITTER_TA      : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT DSP is
		PORT(
			CLK_33M         : IN STD_LOGIC;
			clk_main        : IN STD_LOGIC;
			fb_oe_n         : IN STD_LOGIC;
			fb_wr_n         : IN STD_LOGIC;
			FB_CS1n         : IN STD_LOGIC;
			FB_CS2n         : IN STD_LOGIC;
			fb_size0        : IN STD_LOGIC;
			fb_size1        : IN STD_LOGIC;
			FB_BURSTn       : IN STD_LOGIC;
			fb_adr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			RESETn          : IN STD_LOGIC;
			FB_CS3n         : IN STD_LOGIC;
			SRCSn           : OUT STD_LOGIC;
			SRBLEn          : OUT STD_LOGIC;
			SRBHEn          : OUT STD_LOGIC;
			SRWEn           : OUT STD_LOGIC;
			SROEn           : OUT STD_LOGIC;
			DSP_INT         : OUT STD_LOGIC;
			DSP_TA          : OUT STD_LOGIC;
			FB_AD_IN        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_OUT       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FB_AD_EN        : OUT STD_LOGIC;
			IO_IN           : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			IO_OUT          : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			IO_EN           : OUT STD_LOGIC;
			SRD_IN          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			SRD_OUT         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			SRD_EN          : OUT STD_LOGIC
		);
	END COMPONENT DSP;

	COMPONENT WF2149IP_TOP_SOC
		PORT(
			SYS_CLK		: IN STD_LOGIC;
			RESETn   	: IN STD_LOGIC;

			WAV_CLK		: IN STD_LOGIC;
			SELn		: IN STD_LOGIC;
			
			BDIR		: IN STD_LOGIC;
			BC2, BC1	: IN STD_LOGIC;

			A9n, A8		: IN STD_LOGIC;
			DA_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DA_OUT		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DA_EN		: OUT STD_LOGIC;
			
			IO_A_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			IO_A_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			IO_A_EN		: OUT STD_LOGIC;
			IO_B_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			IO_B_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			IO_B_EN		: OUT STD_LOGIC;

			OUT_A		: OUT STD_LOGIC;
			OUT_B		: OUT STD_LOGIC;
			OUT_C		: OUT STD_LOGIC
		);
	END COMPONENT WF2149IP_TOP_SOC;

	COMPONENT WF68901IP_TOP_SOC
		PORT (
			CLK			: IN STD_LOGIC;
			RESETn		: IN STD_LOGIC;
			DSn			: IN STD_LOGIC;
			CSn			: IN STD_LOGIC;
			RWn			: IN STD_LOGIC;
			DTACKn		: OUT STD_LOGIC;
			RS			: IN STD_LOGIC_VECTOR(5 DOWNTO 1);
			DATA_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_EN		: OUT STD_LOGIC;
			GPIP_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			GPIP_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			GPIP_EN		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			IACKn		: IN STD_LOGIC;
			IEIn		: IN STD_LOGIC;
			IEOn		: OUT STD_LOGIC;
			irq_n		: OUT STD_LOGIC;
			XTAL1		: IN STD_LOGIC;
			TAI			: IN STD_LOGIC;
			TBI			: IN STD_LOGIC;
			TAO			: OUT STD_LOGIC;			
			TBO			: OUT STD_LOGIC;			
			TCO			: OUT STD_LOGIC;			
			TDO			: OUT STD_LOGIC;			
			RC			: IN STD_LOGIC;
			TC			: IN STD_LOGIC;
			SI			: IN STD_LOGIC;
			SO			: OUT STD_LOGIC;
			SO_EN		: OUT STD_LOGIC;
			RRn			: OUT STD_LOGIC;
			TRn			: OUT STD_LOGIC			
		);
	END COMPONENT WF68901IP_TOP_SOC;

	COMPONENT WF6850IP_TOP_SOC
	  PORT (
			CLK					: IN STD_LOGIC;
			RESETn				: IN STD_LOGIC;

			CS2n, CS1, CS0		: IN STD_LOGIC;
			E		       		: IN STD_LOGIC;   
			RWn              	: IN STD_LOGIC;
			RS					: IN STD_LOGIC;

			DATA_IN		        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);   
			DATA_OUT	        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   
			DATA_EN				: OUT STD_LOGIC;

			TXCLK				: IN STD_LOGIC;
			RXCLK				: IN STD_LOGIC;
			RXDATA				: IN STD_LOGIC;
			CTSn				: IN STD_LOGIC;
			DCDn				: IN STD_LOGIC;
	        
			irq_n				: OUT STD_LOGIC;
			TXDATA				: OUT STD_LOGIC;   
			RTSn				: OUT STD_LOGIC
		);                                              
	END COMPONENT WF6850IP_TOP_SOC;

	COMPONENT WF5380_TOP_SOC
		PORT (
			CLK			: IN STD_LOGIC;
			RESETn	    : IN STD_LOGIC;
			ADR			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			DATA_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_EN		: OUT STD_LOGIC;
			CSn			: IN STD_LOGIC;
			RDn		    : IN STD_LOGIC;
			WRn	        : IN STD_LOGIC;
			EOPn        : IN STD_LOGIC;
			DACKn	    : IN STD_LOGIC;
			DRQ		    : OUT STD_LOGIC;
			INT		    : OUT STD_LOGIC;
			READY       : OUT STD_LOGIC;
			DB_INn		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DB_OUTn		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DB_EN       : OUT STD_LOGIC;
			DBP_INn		: IN STD_LOGIC;
			DBP_OUTn	: OUT STD_LOGIC;
			DBP_EN      : OUT STD_LOGIC;
			RST_INn     : IN STD_LOGIC;
			RST_OUTn    : OUT STD_LOGIC;
			RST_EN      : OUT STD_LOGIC;
			BSY_INn     : IN STD_LOGIC;
			BSY_OUTn    : OUT STD_LOGIC;
			BSY_EN      : OUT STD_LOGIC;
			SEL_INn     : IN STD_LOGIC;
			SEL_OUTn    : OUT STD_LOGIC;
			SEL_EN      : OUT STD_LOGIC;
			ACK_INn     : IN STD_LOGIC;
			ACK_OUTn    : OUT STD_LOGIC;
			ACK_EN      : OUT STD_LOGIC;
			ATN_INn     : IN STD_LOGIC;
			ATN_OUTn    : OUT STD_LOGIC;
			ATN_EN      : OUT STD_LOGIC;
			REQ_INn     : IN STD_LOGIC;
			REQ_OUTn    : OUT STD_LOGIC;
			REQ_EN      : OUT STD_LOGIC;
			IOn_IN      : IN STD_LOGIC;
			IOn_OUT     : OUT STD_LOGIC;
			IO_EN       : OUT STD_LOGIC;
			CDn_IN      : IN STD_LOGIC;
			CDn_OUT     : OUT STD_LOGIC;
			CD_EN       : OUT STD_LOGIC;
			MSG_INn     : IN STD_LOGIC;
			MSG_OUTn    : OUT STD_LOGIC;
			MSG_EN      : OUT STD_LOGIC
		);
	END COMPONENT WF5380_TOP_SOC;

	COMPONENT WF1772IP_TOP_SOC
		PORT (
			CLK			: IN STD_LOGIC;
			RESETn		: IN STD_LOGIC;
			CSn			: IN STD_LOGIC;
			RWn			: IN STD_LOGIC;
			A1, A0		: IN STD_LOGIC;
			DATA_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_EN		: OUT STD_LOGIC;
			RDn			: IN STD_LOGIC;
			TR00n		: IN STD_LOGIC;
			IPn			: IN STD_LOGIC;
			WPRTn		: IN STD_LOGIC;
			DDEn		: IN STD_LOGIC;
			HDTYPE		: IN STD_LOGIC;
			MO			: OUT STD_LOGIC;
			WG			: OUT STD_LOGIC;
			WD			: OUT STD_LOGIC;
			STEP		: OUT STD_LOGIC;
			DIRC		: OUT STD_LOGIC;
			DRQ			: OUT STD_LOGIC;
			INTRQ		: OUT STD_LOGIC
		);
	END COMPONENT WF1772IP_TOP_SOC;

	COMPONENT RTC is
		PORT(
			clk_main        : IN STD_LOGIC;
			fb_adr          : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
			FB_CS1n         : IN STD_LOGIC;
			fb_size0        : IN STD_LOGIC;
			fb_size1        : IN STD_LOGIC;
			fb_wr_n         : IN STD_LOGIC;
			fb_oe_n         : IN STD_LOGIC;
			FB_AD_IN        : IN STD_LOGIC_VECTOR(23 DOWNTO 16);
			FB_AD_OUT       : OUT STD_LOGIC_VECTOR(23 DOWNTO 16);
			FB_AD_EN_23_16  : OUT STD_LOGIC;
			PIC_INT         : IN STD_LOGIC
		);
	END COMPONENT RTC;
END firebee_pkg;
