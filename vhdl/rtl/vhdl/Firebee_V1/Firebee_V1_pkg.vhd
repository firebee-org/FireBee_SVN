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
---- Ashwanden  and Wolfgang Förster. This release is in compa-   ----
---- rision to the first edition completely written in VHDL.      ----
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
---- This program is distributed in the hope that it will be      ----
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
library ieee;
use ieee.std_logic_1164.all;
package firebee_pkg is
	component VIDEO_SYSTEM
		port(
			CLK_MAIN            : in std_logic;
			CLK_33M             : in std_logic;
			CLK_25M             : in std_logic;
			CLK_VIDEO           : in std_logic;
			CLK_DDR3            : in std_logic;
			CLK_DDR2            : in std_logic;
			CLK_DDR0            : in std_logic;
			CLK_PIXEL           : out std_logic;
            
			VR_D                : in std_logic_vector(8 downto 0);
			VR_BUSY             : in std_logic;
            
			FB_ADR              : in std_logic_vector(31 downto 0);
			FB_AD_IN            : in std_logic_vector(31 downto 0);
			FB_AD_OUT           : out std_logic_vector(31 downto 0);
			FB_AD_EN_31_16      : out std_logic; -- Hi word.
			FB_AD_EN_15_0       : out std_logic; -- Low word.
			FB_ALE              : in std_logic;
			FB_CSn              : in std_logic_vector(3 downto 1);
			FB_OEn              : in std_logic;
			FB_WRn              : in std_logic;
			FB_SIZE1            : in std_logic;
			FB_SIZE0            : in std_logic;
            
			VDP_IN              : in std_logic_vector(63 downto 0);

			VR_RD               : out std_logic;
			VR_WR               : out std_logic;
			VIDEO_RECONFIG      : out std_logic;

			RED                 : out std_logic_vector(7 downto 0);
			GREEN               : out std_logic_vector(7 downto 0);
			BLUE                : out std_logic_vector(7 downto 0);
			VSYNC               : out std_logic;
			HSYNC               : out std_logic;
			SYNCn               : out std_logic;
			BLANKn              : out std_logic;
            
			PD_VGAn             : out std_logic;
			VIDEO_MOD_TA        : out std_logic;

			VD_VZ               : out std_logic_vector(127 downto 0);
			SR_FIFO_WRE         : in std_logic;
			SR_VDMP             : in std_logic_vector(7 downto 0);
			FIFO_MW             : out std_logic_vector(8 downto 0);
			VDM_SEL             : in std_logic_vector(3 downto 0);
			VIDEO_RAM_CTR       : out std_logic_vector(15 downto 0);
			FIFO_CLR            : out std_logic;

			VDM                 : out std_logic_vector(3 downto 0);

			BLITTER_RUN         : in std_logic;
			BLITTER_ON          : out std_logic
		);
	end component;

	component VIDEO_CTRL
		port(
			CLK_MAIN        : in std_logic;
			FB_CSn          : in std_logic_vector(2 downto 1);
			FB_WRn          : in std_logic;
			FB_OEn          : in std_logic;
			FB_SIZE         : in std_logic_vector(1 downto 0);
			FB_ADR          : in std_logic_vector(31 downto 0);
			CLK33M          : in std_logic;
			CLK25M          : in std_logic;
			BLITTER_RUN     : in std_logic;
			CLK_VIDEO       : in std_logic;
			VR_D            : in std_logic_vector(8 downto 0);
			VR_BUSY         : in std_logic;
			COLOR8          : out std_logic;
			FBEE_CLUT_RD    : out std_logic;
			COLOR1          : out std_logic;
			FALCON_CLUT_RDH : out std_logic;
			FALCON_CLUT_RDL : out std_logic;
			FALCON_CLUT_WR  : out std_logic_vector(3 downto 0);
			CLUT_ST_RD      : out std_logic;
			CLUT_ST_WR      : out std_logic_vector(1 downto 0);
			CLUT_MUX_ADR    : out std_logic_vector(3 downto 0);
			HSYNC           : out std_logic;
			VSYNC           : out std_logic;
			BLANKn          : out std_logic;
			SYNCn           : out std_logic;
			PD_VGAn         : out std_logic;
			FIFO_RDE        : out std_logic;
			COLOR2          : out std_logic;
			COLOR4          : out std_logic;
			CLK_PIXEL       : out std_logic;
			CLUT_OFF        : out std_logic_vector(3 downto 0);
			BLITTER_ON      : out std_logic;
			VIDEO_RAM_CTR   : out std_logic_vector(15 downto 0);
			VIDEO_MOD_TA    : out std_logic;
			CCR             : out std_logic_vector(23 downto 0);
			CCSEL           : out std_logic_vector(2 downto 0);
			FBEE_CLUT_WR    : out std_logic_vector(3 downto 0);
			INTER_ZEI       : out std_logic;
			DOP_FIFO_CLR    : out std_logic;
			VIDEO_RECONFIG  : out std_logic;
			VR_WR           : out std_logic;
			VR_RD           : out std_logic;
			FIFO_CLR        : out std_logic;
			DATA_IN         : in std_logic_vector(31 downto 0);
			DATA_OUT        : out std_logic_vector(31 downto 0);
			DATA_EN_H       : out std_logic;
			DATA_EN_L       : out std_logic
		);
	end component;

	component DDR_CTRL_V1 is
		port(
			CLK_MAIN        : in std_logic;
			DDR_SYNC_66M    : in std_logic;
			FB_ADR          : in std_logic_vector(31 downto 0);
			FB_CS1n         : in std_logic;
			FB_OEn          : in std_logic;
			FB_SIZE0        : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_ALE          : in std_logic;
			FB_WRn          : in std_logic;
			FIFO_CLR        : in std_logic;
			VIDEO_RAM_CTR   : in std_logic_vector(15 downto 0);
			BLITTER_ADR     : in std_logic_vector(31 downto 0);
			BLITTER_SIG     : in std_logic;
			BLITTER_WR      : in std_logic;
			DDRCLK0         : in std_logic;
			CLK_33M         : in std_logic;
			FIFO_MW         : in std_logic_vector(8 downto 0);
			VA              : out std_logic_vector(12 downto 0);
			VWEn            : out std_logic;
			VRASn           : out std_logic;
			VCSn            : out std_logic;
			VCKE            : out std_logic;
			VCASn           : out std_logic;
			FB_LE           : out std_logic_vector(3 downto 0);
			FB_VDOE         : out std_logic_vector(3 downto 0);
			SR_FIFO_WRE     : out std_logic;
			SR_DDR_FB       : out std_logic;
			SR_DDR_WR       : out std_logic;
			SR_DDRWR_D_SEL  : out std_logic;
			SR_VDMP         : out std_logic_vector(7 downto 0);
			VIDEO_DDR_TA    : out std_logic;
			SR_BLITTER_DACK : out std_logic;
			BA              : out std_logic_vector(1 downto 0);
			DDRWR_D_SEL1    : out std_logic;
			VDM_SEL         : out std_logic_vector(3 downto 0);
			DATA_IN         : in std_logic_vector(31 downto 0);
			DATA_OUT        : out std_logic_vector(31 downto 16);
			DATA_EN_H       : out std_logic;
			DATA_EN_L       : out std_logic
		);
	end component;

	component INTHANDLER
		port(
			CLK_MAIN        : in std_logic;
			RESETn          : in std_logic;
			FB_ADR          : in std_logic_vector(31 downto 0);
			FB_CSn          : in std_logic_vector(2 downto 1);
			FB_SIZE0        : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_WRn          : in std_logic;
			FB_OEn          : in std_logic;
			FB_AD_IN        : in std_logic_vector(31 downto 0);
			FB_AD_OUT       : out std_logic_vector(31 downto 0);
			FB_AD_EN_31_24  : out std_logic;
			FB_AD_EN_23_16  : out std_logic;
			FB_AD_EN_15_8   : out std_logic;
			FB_AD_EN_7_0    : out std_logic;
			PIC_INT         : in std_logic;
			E0_INT          : in std_logic;
			DVI_INT         : in std_logic;
			PCI_INTAn       : in std_logic;
			PCI_INTBn       : in std_logic;
			PCI_INTCn       : in std_logic;
			PCI_INTDn       : in std_logic;
			MFP_INTn        : in std_logic;
			DSP_INT         : in std_logic;
			VSYNC           : in std_logic;
			HSYNC           : in std_logic;
			DRQ_DMA         : in std_logic;
			IRQn            : out std_logic_vector(7 downto 2);
			INT_HANDLER_TA  : out std_logic;
			FBEE_CONF       : out std_logic_vector(31 downto 0);
			TIN0            : out std_logic
		);
	end component;

	component FBEE_DMA is
		port(
			RESET                       : in std_logic;
			CLK_MAIN                    : in std_logic;
			CLK_FDC                     : in std_logic;

			FB_ADR                      : in std_logic_vector(26 downto 0);
			FB_ALE                      : in std_logic;
			FB_SIZE                     : in std_logic_vector(1 downto 0);
			FB_CSn                      : in std_logic_vector(2 downto 1);
			FB_OEn                      : in std_logic;
			FB_WRn                      : in std_logic;
			FB_AD_IN                    : in std_logic_vector(31 downto 0);
			FB_AD_OUT                   : out std_logic_vector(31 downto 0);
			FB_AD_EN_31_24              : out std_logic;
			FB_AD_EN_23_16              : out std_logic;
			FB_AD_EN_15_8               : out std_logic;
			FB_AD_EN_7_0                : out std_logic;

			ACSI_DIR                    : out std_logic;
			ACSI_D_IN                   : in std_logic_vector(7 downto 0);
			ACSI_D_OUT                  : out std_logic_vector(7 downto 0);
			ACSI_D_EN                   : out std_logic;
			ACSI_CSn                    : out std_logic;
			ACSI_A1                     : out std_logic;
			ACSI_RESETn                 : out std_logic;
			ACSI_DRQn                   : in std_logic;
			ACSI_ACKn                   : out std_logic;

			DATA_IN_FDC                 : in std_logic_vector(7 downto 0);
			DATA_IN_SCSI                : in std_logic_vector(7 downto 0);
			DATA_OUT_FDC_SCSI			: out std_logic_vector(7 downto 0);

			DMA_DRQ_IN                  : in std_logic; -- From 1772.
			DMA_DRQ_OUT                 : out std_logic; -- To Interrupt handler.
			DMA_DRQ11                   : out std_logic;
            
			SCSI_DRQ                    : in std_logic;
			SCSI_DACKn                  : out std_logic;
			SCSI_INT                    : in std_logic;
			SCSI_CSn                    : out std_logic;
			SCSI_CS                     : out std_logic;

			CA                          : out std_logic_vector(2 downto 0);
			FLOPPY_HD_DD                : in std_logic;
			WDC_BSL0                    : out std_logic;
			FDC_CSn                     : out std_logic;
			FDC_WRn                     : out std_logic;
			FD_INT                      : in std_logic;
			IDE_INT                     : in std_logic;
			DMA_CS                      : out std_logic
		);
	end component;

	component IDE_CF_SD_ROM is
		port(
			RESET               : in std_logic;
			CLK_MAIN            : in std_logic;

			FB_ADR              : in std_logic_vector(19 downto 5);
			FB_CS1n             : in std_logic;
			FB_WRn              : in std_logic;
			FB_B0               : in std_logic;
			FB_B1               : in std_logic;

			FBEE_CONF           : in std_logic_vector(31 downto 30);

			RP_UDSn             : out std_logic;
			RP_LDSn             : out std_logic;

			SD_CLK              : out std_logic;
			SD_D0               : in std_logic;
			SD_D1               : in std_logic;
			SD_D2               : in std_logic;
			SD_CD_D3_IN         : in std_logic;
			SD_CD_D3_OUT        : out std_logic;
			SD_CD_D3_EN         : out std_logic;
			SD_CMD_D1_IN        : in std_logic;
			SD_CMD_D1_OUT       : out std_logic;
			SD_CMD_D1_EN        : out std_logic;
			SD_CARD_DETECT      : in std_logic;
			SD_WP               : in std_logic;

			IDE_RDY             : in std_logic;
			IDE_WRn             : buffer std_logic;
			IDE_RDn             : out std_logic;
			IDE_CSn             : out std_logic_vector(1 downto 0);
			IDE_DRQn            : out std_logic;
			IDE_CF_TA           : out std_logic;

			ROM4n               : out std_logic;
			ROM3n               : out std_logic;

			CF_WP               : in std_logic;
			CF_CSn              : out std_logic_vector(1 downto 0)
		);
	end component;

	component FBEE_BLITTER is
		port(
			RESETn          : in std_logic;
			CLK_MAIN        : in std_logic;
			CLK_DDR0        : in std_logic;
			FB_ADR          : in std_logic_vector(31 downto 0);
			FB_ALE          : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_SIZE0        : in std_logic;
			FB_CSn          : in std_logic_vector(3 downto 1);
			FB_OEn          : in std_logic;
			FB_WRn          : in std_logic;
			DATA_IN         : in std_logic_vector(31 downto 0);
			DATA_OUT        : out std_logic_vector(31 downto 0);
			DATA_EN         : out std_logic;
			BLITTER_ON      : in std_logic;
			BLITTER_DIN     : in std_logic_vector(127 downto 0);
			BLITTER_DACK_SR : in std_logic;
			BLITTER_RUN     : out std_logic;
			BLITTER_DOUT    : out std_logic_vector(127 downto 0);
			BLITTER_ADR     : out std_logic_vector(31 downto 0);
			BLITTER_SIG     : out std_logic;
			BLITTER_WR      : out std_logic;
			BLITTER_TA      : out std_logic
		);
	end component;

	component DSP is
		port(
			CLK_33M         : in std_logic;
			CLK_MAIN        : in std_logic;
			FB_OEn          : in std_logic;
			FB_WRn          : in std_logic;
			FB_CS1n         : in std_logic;
			FB_CS2n         : in std_logic;
			FB_SIZE0        : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_BURSTn       : in std_logic;
			FB_ADR          : in std_logic_vector(31 downto 0);
			RESETn          : in std_logic;
			FB_CS3n         : in std_logic;
			SRCSn           : out std_logic;
			SRBLEn          : out std_logic;
			SRBHEn          : out std_logic;
			SRWEn           : out std_logic;
			SROEn           : out std_logic;
			DSP_INT         : out std_logic;
			DSP_TA          : out std_logic;
			FB_AD_IN        : in std_logic_vector(31 downto 0);
			FB_AD_OUT       : out std_logic_vector(31 downto 0);
			FB_AD_EN        : out std_logic;
			IO_IN           : in std_logic_vector(17 downto 0);
			IO_OUT          : out std_logic_vector(17 downto 0);
			IO_EN           : out std_logic;
			SRD_IN          : in std_logic_vector(15 downto 0);
			SRD_OUT         : out std_logic_vector(15 downto 0);
			SRD_EN          : out std_logic
		);
	end component DSP;

	component WF2149IP_TOP_SOC
		port(
			SYS_CLK		: in std_logic;
			RESETn   	: in std_logic;

			WAV_CLK		: in std_logic;
			SELn		: in std_logic;
			
			BDIR		: in std_logic;
			BC2, BC1	: in std_logic;

			A9n, A8		: in std_logic;
			DA_IN		: in std_logic_vector(7 downto 0);
			DA_OUT		: out std_logic_vector(7 downto 0);
			DA_EN		: out std_logic;
			
			IO_A_IN		: in std_logic_vector(7 downto 0);
			IO_A_OUT	: out std_logic_vector(7 downto 0);
			IO_A_EN		: out std_logic;
			IO_B_IN		: in std_logic_vector(7 downto 0);
			IO_B_OUT	: out std_logic_vector(7 downto 0);
			IO_B_EN		: out std_logic;

			OUT_A		: out std_logic;
			OUT_B		: out std_logic;
			OUT_C		: out std_logic
		);
	end component WF2149IP_TOP_SOC;

	component WF68901IP_TOP_SOC
		port (
			CLK			: in std_logic;
			RESETn		: in std_logic;
			DSn			: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			DTACKn		: out std_logic;
			RS			: in std_logic_vector(5 downto 1);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			GPIP_IN		: in std_logic_vector(7 downto 0);
			GPIP_OUT	: out std_logic_vector(7 downto 0);
			GPIP_EN		: out std_logic_vector(7 downto 0);
			IACKn		: in std_logic;
			IEIn		: in std_logic;
			IEOn		: out std_logic;
			IRQn		: out std_logic;
			XTAL1		: in std_logic;
			TAI			: in std_logic;
			TBI			: in std_logic;
			TAO			: out std_logic;			
			TBO			: out std_logic;			
			TCO			: out std_logic;			
			TDO			: out std_logic;			
			RC			: in std_logic;
			TC			: in std_logic;
			SI			: in std_logic;
			SO			: out std_logic;
			SO_EN		: out std_logic;
			RRn			: out std_logic;
			TRn			: out std_logic			
		);
	end component WF68901IP_TOP_SOC;

	component WF6850IP_TOP_SOC
	  port (
			CLK					: in std_logic;
			RESETn				: in std_logic;

			CS2n, CS1, CS0		: in std_logic;
			E		       		: in std_logic;   
			RWn              	: in std_logic;
			RS					: in std_logic;

			DATA_IN		        : in std_logic_vector(7 downto 0);   
			DATA_OUT	        : out std_logic_vector(7 downto 0);   
			DATA_EN				: out std_logic;

			TXCLK				: in std_logic;
			RXCLK				: in std_logic;
			RXDATA				: in std_logic;
			CTSn				: in std_logic;
			DCDn				: in std_logic;
	        
			IRQn				: out std_logic;
			TXDATA				: out std_logic;   
			RTSn				: out std_logic
		);                                              
	end component WF6850IP_TOP_SOC;

	component WF5380_TOP_SOC
		port (
			CLK			: in std_logic;
			RESETn	    : in std_logic;
			ADR			: in std_logic_vector(2 downto 0);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			CSn			: in std_logic;
			RDn		    : in std_logic;
			WRn	        : in std_logic;
			EOPn        : in std_logic;
			DACKn	    : in std_logic;
			DRQ		    : out std_logic;
			INT		    : out std_logic;
			READY       : out std_logic;
			DB_INn		: in std_logic_vector(7 downto 0);
			DB_OUTn		: out std_logic_vector(7 downto 0);
			DB_EN       : out std_logic;
			DBP_INn		: in std_logic;
			DBP_OUTn	: out std_logic;
			DBP_EN      : out std_logic;
			RST_INn     : in std_logic;
			RST_OUTn    : out std_logic;
			RST_EN      : out std_logic;
			BSY_INn     : in std_logic;
			BSY_OUTn    : out std_logic;
			BSY_EN      : out std_logic;
			SEL_INn     : in std_logic;
			SEL_OUTn    : out std_logic;
			SEL_EN      : out std_logic;
			ACK_INn     : in std_logic;
			ACK_OUTn    : out std_logic;
			ACK_EN      : out std_logic;
			ATN_INn     : in std_logic;
			ATN_OUTn    : out std_logic;
			ATN_EN      : out std_logic;
			REQ_INn     : in std_logic;
			REQ_OUTn    : out std_logic;
			REQ_EN      : out std_logic;
			IOn_IN      : in std_logic;
			IOn_OUT     : out std_logic;
			IO_EN       : out std_logic;
			CDn_IN      : in std_logic;
			CDn_OUT     : out std_logic;
			CD_EN       : out std_logic;
			MSG_INn     : in std_logic;
			MSG_OUTn    : out std_logic;
			MSG_EN      : out std_logic
		);
	end component WF5380_TOP_SOC;

	component WF1772IP_TOP_SOC
		port (
			CLK			: in std_logic;
			RESETn		: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			A1, A0		: in std_logic;
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			RDn			: in std_logic;
			TR00n		: in std_logic;
			IPn			: in std_logic;
			WPRTn		: in std_logic;
			DDEn		: in std_logic;
			HDTYPE		: in std_logic;
			MO			: out std_logic;
			WG			: out std_logic;
			WD			: out std_logic;
			STEP		: out std_logic;
			DIRC		: out std_logic;
			DRQ			: out std_logic;
			INTRQ		: out std_logic
		);
	end component WF1772IP_TOP_SOC;

	component RTC is
		port(
			CLK_MAIN        : in std_logic;
			FB_ADR          : in std_logic_vector(19 downto 0);
			FB_CS1n         : in std_logic;
			FB_SIZE0        : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_WRn          : in std_logic;
			FB_OEn          : in std_logic;
			FB_AD_IN        : in std_logic_vector(23 downto 16);
			FB_AD_OUT       : out std_logic_vector(23 downto 16);
			FB_AD_EN_23_16  : out std_logic;
			PIC_INT         : in std_logic
		);
	end component RTC;
end firebee_pkg;
