----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the toplevel of the 'Firebee'      ----
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
--   Initial Release of the second edition, the most important changes are listed below.
--     Structural work:
--       Replaced the graphical top level by a VHDL model.
--       The new toplevel is now FIREBEE_V1.
--       Replaced the graphical Video Top Level by a VHDL model
--       The DDR_CTR is now DDR_CTRL.
--       Rewritten the DDR_CTR in VHDL.
--       Moved the DDR_CTRL to the FIREBEE_V1 top level.
--       Moved the BLITTER to the FIREBEE_V1 top level.
--       Removed the VIDEO_MOD_MUX_CLUTCTR.
--       Extracted from the AHDL code of MOD_MUX_CLUTCTR the new VIDEO_CTRL.
--       VIDEO_CTRL is now written in VHDL.
--       Removed the FalconIO_SDCard_IDE_CF.
--       Moved the keyboard ACIA from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the MIDI ACIA from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the soundchip module from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the multi function port (MFP) from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the floppy disk controller (FDC) from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the SCSI controller from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Extracted a DMA logic from FalconIO_SDCard_IDE_CF which is now located in the FIREBEE_V1 top level.
--       Extracted a IDE_CF_SD_ROM logic from FalconIO_SDCard_IDE_CF which is now located in the FIREBEE_V1 top level.
--       Moved the PADDLE logic from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Rewritten the interrupt handler in VHDL.
--       Extracted the real time clock (RTC) logic from the interrupt handler (VHDL).
--       The RTC is now located in the FIREBEE_V1 top level.
--     Several code cleanups:
--       Resolved the tri state logic in all modules. The only tri states are now in the
--         top level FIREBEE_V1.
--       Replaced several Altera lpm modules to achieve a manufacturer independant code.
--         However we have still some modules like memory or FIFOs which are required up to now.
--       Removed the VDR latch.
--       Removed the AMKBD filter.
--       Updated all Suska-Codes (ACIA, MFP, 5380, 1772, 2149) to the latest code base.
--       The sound module works now on the positive clock edge.
--       The multi function port works now on the positive clock edge.
--     Naming conventions:
--       Replaced the 'n' prefixes with 'n' postfixes to achieve consistent signal names.
--       Replaced the old ACP_xx signal names by FBEE_xx (ACP is the old working title).
--     Improvements (hopefully)
--         Fixed the VIDEO_RECONFIG strobe logic in the video control section.
--     Others:
--       Provided file headers to all Firebee relevant design units.
--       Provided a timequest constraint file.
--       Switched all code elements to English language.
--       Provided a complete new file structure for the project.
--

library work;
use work.firebee_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity firebee is
	port(
		RSTO_MCFn           : in std_logic;
		CLK_33M             : in std_logic;
		CLK_MAIN            : in std_logic;

		CLK_24M576          : out std_logic;
		CLK_25M             : out std_logic;
		CLK_DDR_OUT         : out std_logic;
		CLK_DDR_OUTn        : out std_logic;
		CLK_USB             : out std_logic;

		FB_AD               : inout std_logic_vector(31 downto 0);
		FB_ALE              : in std_logic;
		FB_BURSTn           : in std_logic;
		FB_CSn              : in std_logic_vector(3 downto 1);
		FB_SIZE             : in std_logic_vector(1 downto 0);
		FB_OEn              : in std_logic;
		FB_WRn              : in std_logic;
		FB_TAn              : out std_logic;
        
		DACK1n              : in std_logic;
		DREQ1n              : out std_logic;

		MASTERn             : in std_logic; -- Not used so far.
		TOUT0n              : in std_logic; -- Not used so far.

		LED_FPGA_OK         : out std_logic;
		RESERVED_1          : out std_logic;

		VA                  : out std_logic_vector(12 downto 0);
		BA                  : out std_logic_vector(1 downto 0);
		VWEn                : out std_logic;
		VCASn               : out std_logic;
		VRASn               : out std_logic;
		VCSn                : out std_logic;

		CLK_PIXEL           : out std_logic;
		SYNCn               : out std_logic;
		VSYNC               : out std_logic;
		HSYNC               : out std_logic;
		BLANKn              : out std_logic;
        
		VR                  : out std_logic_vector(7 downto 0);
		VG                  : out std_logic_vector(7 downto 0);
		VB                  : out std_logic_vector(7 downto 0);

		VDM                 : out std_logic_vector(3 downto 0);

		VD                  : inout std_logic_vector(31 downto 0);
		VD_QS               : out std_logic_vector(3 downto 0);

		PD_VGAn             : out std_logic;
		VCKE                : out std_logic;
		PIC_INT             : in std_logic;
		E0_INT              : in std_logic;
		DVI_INT             : in std_logic;
		PCI_INTAn           : in std_logic;
		PCI_INTBn           : in std_logic;
		PCI_INTCn           : in std_logic;
		PCI_INTDn           : in std_logic;

		IRQn                : out std_logic_vector(7 downto 2);
		TIN0                : out std_logic;

		YM_QA               : out std_logic;
		YM_QB               : out std_logic;
		YM_QC               : out std_logic;

		LP_D                : inout std_logic_vector(7 downto 0);
		LP_DIR              : out std_logic;

		DSA_D               : out std_logic;
		LP_STR              : out std_logic;
		DTR                 : out std_logic;
		RTS                 : out std_logic;
		CTS                 : in std_logic;
		RI                  : in std_logic;
		DCD                 : in std_logic;
		LP_BUSY             : in std_logic;
		RxD                 : in std_logic;
		TxD                 : out std_logic;
		MIDI_IN             : in std_logic;
		MIDI_OLR            : out std_logic;
		MIDI_TLR            : out std_logic;
		PIC_AMKB_RX         : in std_logic;
		AMKB_RX             : in std_logic;
		AMKB_TX             : out std_logic;
		DACK0n              : in std_logic; -- Not used.
        
		SCSI_DRQn           : in std_logic;
		SCSI_MSGn           : in std_logic;
		SCSI_CDn            : in std_logic;
		SCSI_IOn            : in std_logic;
		SCSI_ACKn           : out std_logic;
		SCSI_ATNn           : out std_logic;
		SCSI_SELn           : inout std_logic;
		SCSI_BUSYn          : inout std_logic;
		SCSI_RSTn           : inout std_logic;
		SCSI_DIR            : out std_logic;
		SCSI_D              : inout std_logic_vector(7 downto 0);
		SCSI_PAR            : inout std_logic;

		ACSI_DIR            : out std_logic;
		ACSI_D              : inout std_logic_vector(7 downto 0);
		ACSI_CSn            : out std_logic;
		ACSI_A1             : out std_logic;
		ACSI_RESETn         : out std_logic;
		ACSI_ACKn           : out std_logic;
		ACSI_DRQn           : in std_logic;
		ACSI_INTn           : in std_logic;

		FDD_DCHGn           : in std_logic;
		FDD_SDSELn          : out std_logic;
		FDD_HD_DD           : in std_logic;
		FDD_RDn             : in std_logic;
		FDD_TRACK00         : in std_logic;
		FDD_INDEXn          : in std_logic;
		FDD_WPn             : in std_logic;
		FDD_MOT_ON          : out std_logic;
		FDD_WR_GATE         : out std_logic;
		FDD_WDn             : out std_logic;
		FDD_STEP            : out std_logic;
		FDD_STEP_DIR        : out std_logic;

		ROM4n               : out std_logic;
		ROM3n               : out std_logic;

		RP_UDSn             : out std_logic;
		RP_LDSn             : out std_logic;
		SD_CLK              : out std_logic;
		SD_D3               : inout std_logic;
		SD_CMD_D1           : inout std_logic;
		SD_D0               : in std_logic;
		SD_D1               : in std_logic;
		SD_D2               : in std_logic;
		SD_CARD_DETECT      : in std_logic;
		SD_WP               : in std_logic;

		CF_WP               : in std_logic;
		CF_CSn              : out std_logic_vector(1 downto 0);

		DSP_IO              : inout std_logic_vector(17 downto 0);
		DSP_SRD             : inout std_logic_vector(15 downto 0);
		DSP_SRCSn           : out std_logic;
		DSP_SRBLEn          : out std_logic;
		DSP_SRBHEn          : out std_logic;
		DSP_SRWEn           : out std_logic;
		DSP_SROEn           : out std_logic;

		IDE_INT             : in std_logic;
		IDE_RDY             : in std_logic;
		IDE_RES             : out std_logic;
		IDE_WRn             : out std_logic;
		IDE_RDn             : out std_logic;
		IDE_CSn             : out std_logic_vector(1 downto 0)
	);
end entity firebee;

architecture Structure of firebee is
	component altpll1
		port(
			inclk0      : in std_logic  := '0';
			c0          : out std_logic ;
			c1          : out std_logic ;
			c2          : out std_logic ;
			locked      : out std_logic 
		);
	end component;

	component altpll2
		port(
			inclk0      : in std_logic  := '0';
			c0          : out std_logic ;
			c1          : out std_logic ;
			c2          : out std_logic ;
			c3          : out std_logic ;
			c4          : out std_logic 
		);
	end component;

	component altpll3
		port(
			inclk0      : in std_logic  := '0';
			c0          : out std_logic ;
			c1          : out std_logic ;
			c2          : out std_logic ;
			c3          : out std_logic 
		);
	end component;

	component altpll4
		port(
			areset          : in std_logic  := '0';
			configupdate    : in std_logic  := '0';
			inclk0          : in std_logic  := '0';
			scanclk         : in std_logic  := '1';
			scanclkena      : in std_logic  := '0';
			scandata        : in std_logic  := '0';
			c0              : out std_logic ;
			locked          : out std_logic ;
			scandataout     : out std_logic ;
			scandone        : out std_logic 
		);
	end component;

	component altpll_reconfig1
		port( 
			busy               :   out  std_logic;
			clock              :   in  std_logic;
			counter_param      :   in  std_logic_VECTOR (2 downto 0) := (others => '0');
			counter_type       :   in  std_logic_VECTOR (3 downto 0) := (others => '0');
			data_in            :   in  std_logic_VECTOR (8 downto 0) := (others => '0');
			data_out           :   out  std_logic_VECTOR (8 downto 0);
			pll_areset         :   out  std_logic;
			pll_areset_in      :   in  std_logic := '0';
			pll_configupdate   :   out  std_logic;
			pll_scanclk        :   out  std_logic;
			pll_scanclkena     :   out  std_logic;
			pll_scandata       :   out  std_logic;
			pll_scandataout    :   in  std_logic := '0';
			pll_scandone       :   in  std_logic := '0';
			read_param         :   in  std_logic := '0';
			reconfig           :   in  std_logic := '0';
			reset              :   in  std_logic;
			write_param        :   in  std_logic := '0'
		); 
	end component;

	signal ACIA_CS		    	: std_logic;
	signal ACIA_IRQn			: std_logic;
	signal ACSI_D_OUT           : std_logic_vector(7 downto 0);
	signal ACSI_D_EN            : std_logic;
	signal BLANK_In             : std_logic;
	signal BLITTER_ADR          : std_logic_vector(31 downto 0);
	signal BLITTER_DACK_SR      : std_logic;
	signal BLITTER_DOUT         : std_logic_vector(127 downto 0);
	signal BLITTER_ON           : std_logic;
	signal BLITTER_RUN          : std_logic;
	signal BLITTER_SIG          : std_logic;
	signal BLITTER_TA           : std_logic;
	signal BLITTER_WR           : std_logic;
	signal BYTE				    : std_logic; -- When Byte -> 1
	signal CA                   : std_logic_vector(2 downto 0);
	signal CLK_2M0              : std_logic;
	signal CLK_2M4576           : std_logic;
	signal CLK_25M_I            : std_logic;
	signal CLK_48M              : std_logic;
	signal CLK_500K             : std_logic;
	signal CLK_DDR              : std_logic_vector(3 downto 0);
	signal CLK_FDC              : std_logic;
	signal CLK_PIXEL_I          : std_logic;
	signal CLK_VIDEO            : std_logic;
	signal DA_OUT_X             : std_logic_vector(7 downto 0);
	signal DATA_EN_BLITTER      : std_logic;
	signal DATA_EN_H_DDR_CTRL   : std_logic;
	signal DATA_EN_L_DDR_CTRL   : std_logic;
	signal DATA_IN_FDC_SCSI     : std_logic_vector(7 downto 0);
	signal DATA_OUT_ACIA_I		: std_logic_vector(7 downto 0);
	signal DATA_OUT_ACIA_II		: std_logic_vector(7 downto 0);
	signal DATA_OUT_BLITTER     : std_logic_vector(31 downto 0);
	signal DATA_OUT_DDR_CTRL    : std_logic_vector(31 downto 16);
	signal DATA_OUT_FDC			: std_logic_vector(7 downto 0);
	signal DATA_OUT_MFP			: std_logic_vector(7 downto 0);
	signal DATA_OUT_SCSI		: std_logic_vector(7 downto 0);
	signal DINTn                : std_logic;
	signal DDR_D_IN_N           : std_logic_vector(31 downto 0);
	signal DDR_FB               : std_logic_vector(4 downto 0);
	signal DDR_SYNC_66M         : std_logic;
	signal DDR_WR               : std_logic;
	signal DDRWR_D_SEL          : std_logic_vector(1 downto 0);
	signal DMA_CS               : std_logic;
	signal DRQ11_DMA            : std_logic;
	signal DRQ_FDC              : std_logic;
	signal DRQ_DMA              : std_logic;
	signal DSP_INT              : std_logic;
	signal DSP_IO_EN            : std_logic;
	signal DSP_IO_OUT           : std_logic_vector(17 downto 0);
	signal DSP_SRD_EN           : std_logic;
	signal DSP_SRD_OUT          : std_logic_vector(15 downto 0);
	signal DSP_TA               : std_logic;
	signal DTACK_OUT_MFPn       : std_logic;
	signal FALCON_IO_TA         : std_logic;
	signal FB_AD_EN_15_0_VIDEO  : std_logic;
	signal FB_AD_EN_31_16_VIDEO : std_logic;
	signal FB_AD_EN_7_0_DMA     : std_logic;
	signal FB_AD_EN_7_0_IH      : std_logic;
	signal FB_AD_EN_15_8_DMA    : std_logic;
	signal FB_AD_EN_15_8_IH     : std_logic;
	signal FB_AD_EN_23_16_DMA   : std_logic;
	signal FB_AD_EN_23_16_IH    : std_logic;
	signal FB_AD_EN_31_24_DMA   : std_logic;
	signal FB_AD_EN_31_24_IH    : std_logic;
	signal FB_AD_EN_DSP         : std_logic;
	signal FB_AD_EN_RTC         : std_logic;
	signal FB_AD_OUT_DMA        : std_logic_vector(31 downto 0);
	signal FB_AD_OUT_DSP        : std_logic_vector(31 downto 0);
	signal FB_AD_OUT_IH         : std_logic_vector(31 downto 0);
	signal FB_AD_OUT_RTC        : std_logic_vector(7 downto 0);
	signal FB_AD_OUT_VIDEO      : std_logic_vector(31 downto 0);
	signal FB_ADR               : std_logic_vector(31 downto 0);
	signal FB_B0				: std_logic; -- UPPER Byte BEI 16 std_logic BUS
	signal FB_B1				: std_logic; -- LOWER Byte BEI 16 std_logic BUS
	signal FB_DDR               : std_logic_vector(127 downto 0);
	signal FB_LE                : std_logic_vector(3 downto 0);
	signal FB_VDOE              : std_logic_vector(3 downto 0);
	signal FBEE_CONF            : std_logic_vector(31 downto 0);
	signal FD_INT               : std_logic;
	signal FDC_CSn				: std_logic;
	signal FDC_WRn				: std_logic;
	signal FIFO_CLR             : std_logic;
	signal FIFO_MW              : std_logic_vector(8 downto 0);
	signal HD_DD_OUT			: std_logic;
	signal HSYNC_I              : std_logic;
	signal IDE_CF_TA            : std_logic;
	signal IDE_RES_I            : std_logic;
	signal INT_HANDLER_TA       : std_logic;
	signal IRQ_KEYBDn			: std_logic;
	signal IRQ_MIDIn			: std_logic;
	signal KEYB_RxD			    : std_logic;
	signal LDS                  : std_logic;
	signal LOCKED               : std_logic;
	signal LP_D_X               : std_logic_vector(7 downto 0);
	signal LP_DIR_X             : std_logic;
	signal MFP_CS               : std_logic;
	signal MFP_INTACK           : std_logic;
	signal MFP_INTn             : std_logic;
	signal MIDI_OUT             : std_logic;
	signal PADDLE_CS            : std_logic;
	signal PLL_ARESET           : std_logic;
	signal PLL_SCANCLK          : std_logic;
	signal PLL_SCANDATA         : std_logic;
	signal PLL_SCANCLKENA       : std_logic;
	signal PLL_CONFIGUPDATE     : std_logic;
	signal PLL_SCANDONE         : std_logic;
	signal PLL_SCANDATAOUT      : std_logic;
	signal RESETn               : std_logic;
	signal SCSI_BSY_EN			: std_logic;
	signal SCSI_BSY_OUTn		: std_logic;
	signal SCSI_CS 				: std_logic;
	signal SCSI_CSn				: std_logic;
	signal SCSI_D_EN			: std_logic;
	signal SCSI_DACKn			: std_logic;
	signal SCSI_DBP_EN  		: std_logic;
	signal SCSI_DBP_OUTn		: std_logic;
	signal SCSI_DRQ				: std_logic;
	signal SCSI_INT             : std_logic;
	signal SCSI_D_OUTn			: std_logic_vector(7 downto 0);
	signal SCSI_RST_EN 			: std_logic;
	signal SCSI_RST_OUTn		: std_logic;
	signal SCSI_SEL_EN			: std_logic;
	signal SCSI_SEL_OUTn		: std_logic;
	signal SD_CD_D3_EN          : std_logic;
	signal SD_CD_D3_OUT         : std_logic;
	signal SD_CMD_D1_EN         : std_logic;
	signal SD_CMD_D1_OUT        : std_logic;
	signal SNDCS                : std_logic;
	signal SNDCS_I              : std_logic;
	signal SNDIR_I              : std_logic;
	signal SR_DDR_FB            : std_logic;
	signal SR_DDR_WR            : std_logic;
	signal SR_DDRWR_D_SEL       : std_logic;
	signal SR_FIFO_WRE          : std_logic;
	signal SR_VDMP              : std_logic_vector(7 downto 0);
	signal TDO					: std_logic;
	signal TIMEBASE             : unsigned (17 downto 0);
	signal VD_EN                : std_logic;
	signal VD_EN_I              : std_logic;
	signal VD_OUT               : std_logic_vector(31 downto 0);
	signal VD_QS_EN             : std_logic;
	signal VD_QS_OUT            : std_logic_vector(3 downto 0);
	signal VD_VZ                : std_logic_vector(127 downto 0);
	signal VDM_SEL              : std_logic_vector(3 downto 0);
	signal VDP_IN               : std_logic_vector(63 downto 0);
	signal VDP_OUT              : std_logic_vector(63 downto 0);
	signal VDP_Q1               : std_logic_vector(31 downto 0);
	signal VDP_Q2               : std_logic_vector(31 downto 0);
	signal VDP_Q3               : std_logic_vector(31 downto 0);
	signal VDR                  : std_logic_vector(31 downto 0);
	signal VIDEO_DDR_TA         : std_logic;
	signal VIDEO_MOD_TA         : std_logic;
	signal VIDEO_RAM_CTR        : std_logic_vector(15 downto 0);
	signal VIDEO_RECONFIG       : std_logic;
	signal VR_BUSY              : std_logic;
	signal VR_D                 : std_logic_vector(8 downto 0);
	signal VR_RD                : std_logic;
	signal VR_WR                : std_logic;
	signal VSYNC_I              : std_logic;
	signal WDC_BSL0             : std_logic;
	
begin
	I_PLL1: altpll1
		port map(
			inclk0      => CLK_MAIN,
			c0          => CLK_2M4576,
			c1          => CLK_24M576,
			c2          => CLK_48M,
			locked      => LOCKED
		);

	I_PLL2: altpll2
		port map(
			inclk0      => CLK_MAIN,
			c0          => CLK_DDR(0),
			c1          => CLK_DDR(1),
			c2          => CLK_DDR(2),
			c3          => CLK_DDR(3),
			c4          => DDR_SYNC_66M
		);
    
	I_PLL3: altpll3
		port map(
			inclk0      => CLK_MAIN,
			c0          => CLK_2M0,
			c1          => CLK_FDC,
			c2          => CLK_25M_I,
			c3          => CLK_500K
		);
    
	I_PLL4: altpll4
		port map(
			inclk0          => CLK_MAIN,
			areset          => PLL_ARESET,
			scanclk         => PLL_SCANCLK,
			scandata        => PLL_SCANDATA,
			scanclkena      => PLL_SCANCLKENA,
			configupdate    => PLL_CONFIGUPDATE,
			c0              => CLK_VIDEO,
			scandataout     => PLL_SCANDATAOUT,
			scandone        => PLL_SCANDONE
			--locked        => -- Not used.
		);

	I_RECONFIG: altpll_reconfig1
		port map(
			reconfig            => VIDEO_RECONFIG,
			read_param          => VR_RD,
			write_param         => VR_WR,
			data_in             => FB_ADR(24 downto 16),
			counter_type        => FB_ADR(5 downto 2),
			counter_param       => FB_ADR(8 downto 6),
			pll_scandataout     => PLL_SCANDATAOUT,
			pll_scandone        => PLL_SCANDONE,
			clock               => CLK_MAIN,
			reset               => not RESETn,
			pll_areset_in       => '0', -- Not used.
			busy                => VR_BUSY,
			data_out            => VR_D,
			pll_scandata        => PLL_SCANDATA,
			pll_scanclk         => PLL_SCANCLK,
			pll_scanclkena      => PLL_SCANCLKENA,
			pll_configupdate    => PLL_CONFIGUPDATE,
			pll_areset          => PLL_ARESET
		);

	CLK_25M <= CLK_25M_I;
	CLK_USB <= CLK_48M;
	CLK_DDR_OUT <= CLK_DDR(0);
	CLK_DDR_OUTn <= not CLK_DDR(0);
	CLK_PIXEL <= CLK_PIXEL_I;

	P_TIMEBASE: process
	begin
		wait until CLK_500K = '1' and CLK_500K' event;
		TIMEBASE <= TIMEBASE + 1;
	end process P_TIMEBASE;

	RESETn <= RSTO_MCFn and LOCKED;
	IDE_RES <= not IDE_RES_I and RESETn;
	DREQ1n <= DACK1n;
	LED_FPGA_OK <= TIMEBASE(17);

	FALCON_IO_TA <= ACIA_CS or SNDCS or not DTACK_OUT_MFPn or PADDLE_CS or IDE_CF_TA or DMA_CS;
	FB_TAn <= '0' when (BLITTER_TA or VIDEO_DDR_TA or VIDEO_MOD_TA or FALCON_IO_TA or DSP_TA or INT_HANDLER_TA)= '1' else '1';

	ACIA_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 3) & "000" = x"FFFC00" else '0';			-- FFFC00 - FFFC07
	MFP_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 6) & "000000" = x"FFFA00" else '0';		-- FFFA00/40
	PADDLE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 6) & "000000"= x"FF9200" else '0';	-- FF9200-FF923F
	SNDCS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 2) & "00" = x"FF8800" else '0'; 			-- FF8800-FF8803
	SNDCS_I <= '1' when SNDCS = '1' and FB_ADR (1) = '0' else '0';
	SNDIR_I <= '1' when SNDCS = '1' and FB_WRn = '0' else '0';

	LP_D <= LP_D_X when LP_DIR_X = '0' else (others => 'Z');
	LP_DIR <= LP_DIR_X;
    
	ACSI_D <= ACSI_D_OUT when ACSI_D_EN = '1' else (others => 'Z');

	SCSI_D <= SCSI_D_OUTn when SCSI_D_EN = '1' else (others => 'Z');
	SCSI_DIR <= '0' when SCSI_D_EN = '1' else '1';	 
	SCSI_PAR <= SCSI_DBP_OUTn when SCSI_DBP_EN = '1' else 'Z';
	SCSI_RSTn <= SCSI_RST_OUTn when SCSI_RST_EN = '1' else 'Z';
	SCSI_BUSYn <= SCSI_BSY_OUTn when SCSI_BSY_EN = '1' else 'Z';
	SCSI_SELn <= SCSI_SEL_OUTn when SCSI_SEL_EN = '1' else 'Z';

	KEYB_RxD <= '0' when AMKB_RX = '0' or PIC_AMKB_RX = '0' else '1'; -- TASTATUR DATEN VOM PIC(PS2) OR NORMAL  // 

	SD_D3 <= SD_CD_D3_OUT when SD_CD_D3_EN = '1' else 'Z';
	SD_CMD_D1 <= SD_CMD_D1_OUT when SD_CMD_D1_EN = '1' else 'Z';

	DSP_IO <= DSP_IO_OUT when DSP_IO_EN = '1' else (others => 'Z');
	DSP_SRD <= DSP_SRD_OUT when DSP_SRD_EN = '1' else (others => 'Z');
      
	HD_DD_OUT <= FDD_HD_DD when FBEE_CONF(29) = '0' else WDC_BSL0;
	LDS <= '1' when MFP_CS = '1' or MFP_INTACK = '1' else '0';
	ACIA_IRQn <= IRQ_KEYBDn and IRQ_MIDIn;
	MFP_INTACK <= '1' when FB_CSn(2) = '0' and FB_ADR(19 downto 0) = x"20000" else '0'; 	--F002'0000
	DINTn <= '0' when IDE_INT = '1' and FBEE_CONF(28) = '1' else
				'0' when FD_INT = '1' else
				'0' when SCSI_INT = '1' and FBEE_CONF(28) = '1' else '1';

	MIDI_TLR <= MIDI_OUT;
	MIDI_OLR <= MIDI_OUT;

	BYTE <= '1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '1' else '0';
	FB_B0 <= '1' when FB_ADR(0) = '0' or BYTE = '0' else '0';
	FB_B1 <= '1' when FB_ADR(0) = '1' or BYTE = '0' else '0';

	FB_AD(31 downto 24) <= DATA_OUT_BLITTER(31 downto 24) when DATA_EN_BLITTER = '1' else
									VDP_Q1(31 downto 24) when FB_VDOE = x"2" else
									VDP_Q2(31 downto 24) when FB_VDOE = x"4" else
									VDP_Q3(31 downto 24) when FB_VDOE = x"8" else
									FB_AD_OUT_VIDEO(31 downto 24) when FB_AD_EN_31_16_VIDEO = '1' else
									FB_AD_OUT_DSP(31 downto 24) when FB_AD_EN_DSP = '1' else
									FB_AD_OUT_IH(31 downto 24) when FB_AD_EN_31_24_IH = '1' else
									FB_AD_OUT_DMA(31 downto 24) when FB_AD_EN_31_24_DMA = '1' else
									VDR(31 downto 24) when FB_VDOE = x"1" else
									DATA_OUT_DDR_CTRL(31 downto 24) when DATA_EN_H_DDR_CTRL = '1' else
									DA_OUT_X when SNDCS_I = '1' and FB_OEn = '0' else
									x"00" when MFP_INTACK = '1' and FB_OEn = '0' else
									DATA_OUT_ACIA_I  when ACIA_CS = '1' and FB_ADR(2) = '0' and FB_OEn = '0' else
									DATA_OUT_ACIA_II when ACIA_CS = '1' and FB_ADR(2) = '1' and FB_OEn = '0' else
									x"BF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"0" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"1" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"8" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"9" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"A" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"B" and FB_OEn = '0' else
									x"00" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"10" and FB_OEn = '0' else
									x"00" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"11" and FB_OEn = '0' else (others => 'Z');

	FB_AD(23 downto 16) <= DATA_OUT_BLITTER(23 downto 16) when DATA_EN_BLITTER = '1' else
									VDP_Q1(23 downto 16) when FB_VDOE = x"2" else
									VDP_Q2(23 downto 16) when FB_VDOE = x"4" else
									VDP_Q3(23 downto 16) when FB_VDOE = x"8" else
									FB_AD_OUT_VIDEO(23 downto 16) when FB_AD_EN_31_16_VIDEO = '1' else
									FB_AD_OUT_DSP(23 downto 16) when FB_AD_EN_DSP = '1' else
									FB_AD_OUT_IH(23 downto 16) when FB_AD_EN_23_16_IH = '1' else
									FB_AD_OUT_DMA(23 downto 16) when FB_AD_EN_23_16_DMA = '1' else
									VDR(23 downto 16) when FB_VDOE = x"1" else
									DATA_OUT_DDR_CTRL(23 downto 16) when DATA_EN_L_DDR_CTRL = '1' else
									DATA_OUT_MFP when MFP_CS = '1' and FB_OEn = '0' else
									x"00" when MFP_INTACK = '1' and FB_OEn = '0' else
									FB_AD_OUT_RTC when FB_AD_EN_RTC = '1' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"0" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"1" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"8" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"9" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"A" and FB_OEn = '0' else
									x"FF" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"B" and FB_OEn = '0' else
									x"00" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"10" and FB_OEn = '0' else
									x"00" when PADDLE_CS = '1' and FB_ADR(5 downto 1) = x"11" and FB_OEn = '0' else (others => 'Z');

	FB_AD(15 downto 8) <= DATA_OUT_BLITTER(15 downto 8) when DATA_EN_BLITTER = '1' else
									VDP_Q1(15 downto 8) when FB_VDOE = x"2" else
									VDP_Q2(15 downto 8) when FB_VDOE = x"4" else
									VDP_Q3(15 downto 8) when FB_VDOE = x"8" else
									FB_AD_OUT_VIDEO(15 downto 8) when FB_AD_EN_15_0_VIDEO = '1' else
									FB_AD_OUT_DSP(15 downto 8) when FB_AD_EN_DSP = '1' else
									FB_AD_OUT_IH(15 downto 8) when FB_AD_EN_15_8_IH = '1' else
									FB_AD_OUT_DMA(15 downto 8) when FB_AD_EN_15_8_DMA = '1' else
									VDR(15 downto 8) when FB_VDOE = x"1" else
									"000000" & DATA_OUT_MFP(7 downto 6) when MFP_INTACK = '1' and FB_OEn = '0' else (others => 'Z');

	FB_AD(7 downto 0) <= DATA_OUT_BLITTER(7 downto 0) when DATA_EN_BLITTER = '1' else
									VDP_Q1(7 downto 0) when FB_VDOE = x"2" else
									VDP_Q2(7 downto 0) when FB_VDOE = x"4" else
									VDP_Q3(7 downto 0) when FB_VDOE = x"8" else
									FB_AD_OUT_VIDEO(7 downto 0) when FB_AD_EN_15_0_VIDEO = '1' else
									FB_AD_OUT_DSP(7 downto 0) when FB_AD_EN_DSP = '1' else
									FB_AD_OUT_IH(7 downto 0) when FB_AD_EN_7_0_IH = '1' else
									FB_AD_OUT_DMA(7 downto 0) when FB_AD_EN_7_0_DMA = '1' else
									VDR(7 downto 0) when FB_VDOE = x"1" else
									DATA_OUT_MFP(5 downto 0) & "00" when MFP_INTACK = '1' and FB_OEn = '0' else (others => 'Z');

	SYNCHRONIZATION: process
	begin
		wait until DDR_SYNC_66M = '1' and DDR_SYNC_66M' event;
		if FB_ALE = '1' then
			FB_ADR <= FB_AD;
		end if;
		--
		if VD_EN_I = '0' then
			VDR <= VD;
		else
			VDR <= VD_OUT;
		end if;
		--
		if FB_LE(0) = '1' then
			FB_DDR(127 downto 96) <= FB_AD;
		end if;
        --
		if FB_LE(1) = '1' then
			FB_DDR(95 downto 64) <= FB_AD;
		end if;
		--
		if FB_LE(2) = '1' then
			FB_DDR(63 downto 32) <= FB_AD;
		end if;
        --
		if FB_LE(3) = '1' then
			FB_DDR(31 downto 0) <= FB_AD;
		end if;
	end process SYNCHRONIZATION;

	VIDEO_OUT: process
	begin
		wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
		VSYNC <= VSYNC_I;
		HSYNC <= HSYNC_I;
		BLANKn <= BLANK_In;
	end process VIDEO_OUT;

	P_DDR_WR: process
	begin
		wait until CLK_DDR(3) = '1' and CLK_DDR(3)' event;
		DDR_WR <= SR_DDR_WR;
		DDRWR_D_SEL(0) <= SR_DDRWR_D_SEL;
	end process P_DDR_WR;

	VD_QS_EN <= DDR_WR;
	VD <= VD_OUT when VD_EN = '1' else (others => 'Z');

	VD_QS_OUT(0) <= CLK_DDR(0);
	VD_QS_OUT(1) <= CLK_DDR(0);
	VD_QS_OUT(2) <= CLK_DDR(0);
	VD_QS_OUT(3) <= CLK_DDR(0);
	VD_QS <= VD_QS_OUT when VD_QS_EN = '1' else (others => 'Z');

	DDR_DATA_IN_N: process
	begin
		wait until CLK_DDR(1) = '0' and CLK_DDR(1)' event;
		DDR_D_IN_N <= VD;
	end process DDR_DATA_IN_N;
    --
	DDR_DATA_IN_P: process
	begin
		wait until CLK_DDR(1) = '1' and CLK_DDR(1)' event;
		VDP_IN(31 downto 0) <= VD;
		VDP_IN(63 downto 32) <= DDR_D_IN_N;
	end process DDR_DATA_IN_P;

	DDR_DATA_OUT_P: process(CLK_DDR(3))
		variable DDR_D_OUT_H    : std_logic_vector(31 downto 0);
		variable DDR_D_OUT_L    : std_logic_vector(31 downto 0);
	begin
		if CLK_DDR(3) = '1' and CLK_DDR(3)' event then
			DDR_D_OUT_H := VDP_OUT(63 downto 32);
			DDR_D_OUT_L := VDP_OUT(31 downto 0);
			VD_EN <= SR_DDR_WR or DDR_WR;
		end if;
        --
		case CLK_DDR(3) is
			when  '1' => VD_OUT <= DDR_D_OUT_H;
			when others => VD_OUT <= DDR_D_OUT_L;
		end case;
	end process DDR_DATA_OUT_P;

	with DDRWR_D_SEL select
		VDP_OUT <= BLITTER_DOUT(63 downto 0) when "11",
						BLITTER_DOUT(127 downto 64) when "10",
						FB_DDR(63 downto 0) when "01",
						FB_DDR(127 downto 64) when "00",
						(others => 'Z') when others;

	VD_EN_I <= SR_DDR_WR or DDR_WR;

	VDP_Q_BUFFER: process
	begin
		wait until CLK_DDR(0) = '1' and CLK_DDR(0)' event;
		DDR_FB <= SR_DDR_FB & DDR_FB(4 downto 1);
		--
		if DDR_FB(1) = '1' then
			VDP_Q1 <= VDP_IN(31 downto 0);
		end if;
		--
		if DDR_FB(0) = '1' then
			VDP_Q2 <= VDP_IN(63 downto 32);
			VDP_Q3 <= VDP_IN(31 downto 0);
		end if;
	end process VDP_Q_BUFFER;
 
    I_DDR_CTRL: DDR_CTRL_V1
        port map(
            CLK_MAIN            => CLK_MAIN,
            DDR_SYNC_66M        => DDR_SYNC_66M,
            FB_ADR              => FB_ADR,
            FB_CS1n             => FB_CSn(1),
            FB_OEn              => FB_OEn,
            FB_SIZE0            => FB_SIZE(0),
            FB_SIZE1            => FB_SIZE(1),
            FB_ALE              => FB_ALE,
            FB_WRn              => FB_WRn,
            BLITTER_ADR         => BLITTER_ADR,
            BLITTER_SIG         => BLITTER_SIG,
            BLITTER_WR          => BLITTER_WR,
            SR_BLITTER_DACK     => BLITTER_DACK_SR,
            BA                  => BA,
            VA                  => VA,
            FB_LE               => FB_LE,
            CLK_33M             => CLK_33M,
            VRASn               => VRASn,
            VCASn               => VCASn,
            VWEn                => VWEn,
            VCSn                => VCSn,
            FIFO_CLR            => FIFO_CLR,
            DDRCLK0             => CLK_DDR(0),
            VIDEO_RAM_CTR       => VIDEO_RAM_CTR,
            VCKE                => VCKE,
            DATA_IN             => FB_AD,
            DATA_OUT            => DATA_OUT_DDR_CTRL,
            DATA_EN_H           => DATA_EN_H_DDR_CTRL,
            DATA_EN_L           => DATA_EN_L_DDR_CTRL,
            VDM_SEL             => VDM_SEL,
            FIFO_MW             => FIFO_MW,
            FB_VDOE             => FB_VDOE,
            SR_FIFO_WRE         => SR_FIFO_WRE,
            SR_DDR_FB           => SR_DDR_FB,
            SR_DDR_WR           => SR_DDR_WR,
            SR_DDRWR_D_SEL      => SR_DDRWR_D_SEL,
            SR_VDMP             => SR_VDMP,
            VIDEO_DDR_TA        => VIDEO_DDR_TA,
            DDRWR_D_SEL1        => DDRWR_D_SEL(1)
        );

    I_BLITTER: FBEE_BLITTER
        port map(
            RESETn               => RESETn,
            CLK_MAIN            => CLK_MAIN,
            CLK_DDR0            => CLK_DDR(0),
            FB_ADR              => FB_ADR,
            FB_ALE              => FB_ALE,
            FB_SIZE1            => FB_SIZE(1),
            FB_SIZE0            => FB_SIZE(0),
            FB_CSn              => FB_CSn,
            FB_OEn              => FB_OEn,
            FB_WRn              => FB_WRn,
            DATA_IN             => FB_AD,
            DATA_OUT            => DATA_OUT_BLITTER,
            DATA_EN             => DATA_EN_BLITTER,
            BLITTER_ADR         => BLITTER_ADR,
            BLITTER_SIG         => BLITTER_SIG,
            BLITTER_WR          => BLITTER_WR,
            BLITTER_ON          => BLITTER_ON,
            BLITTER_RUN         => BLITTER_RUN,
            BLITTER_DIN         => VD_VZ,
            BLITTER_DOUT        => BLITTER_DOUT,
            BLITTER_TA          => BLITTER_TA,
            BLITTER_DACK_SR     => BLITTER_DACK_SR
        );

    I_VIDEOSYSTEM: VIDEO_SYSTEM
        port map(
            CLK_MAIN            => CLK_MAIN,
            CLK_33M             => CLK_33M,
            CLK_25M             => CLK_25M_I,
            CLK_VIDEO           => CLK_VIDEO,
            CLK_DDR3            => CLK_DDR(3),
            CLK_DDR2            => CLK_DDR(2),
            CLK_DDR0            => CLK_DDR(0),
            CLK_PIXEL           => CLK_PIXEL_I,
            
            VR_D                => VR_D,
            VR_BUSY             => VR_BUSY,
            
            FB_ADR              => FB_ADR,
            FB_AD_IN            => FB_AD,
            FB_AD_OUT           => FB_AD_OUT_VIDEO,
            FB_AD_EN_31_16      => FB_AD_EN_31_16_VIDEO,
            FB_AD_EN_15_0       => FB_AD_EN_15_0_VIDEO,
            FB_ALE              => FB_ALE,
            FB_CSn              => FB_CSn,
            FB_OEn              => FB_OEn,
            FB_WRn              => FB_WRn,
            FB_SIZE1            => FB_SIZE(1),
            FB_SIZE0            => FB_SIZE(0),

            VDP_IN              => VDP_IN,

            VR_RD               => VR_RD,
            VR_WR               => VR_WR,
            VIDEO_RECONFIG      => VIDEO_RECONFIG,

            RED                 => VR,
            GREEN               => VG,
            BLUE                => VB,
            VSYNC               => VSYNC_I,
            HSYNC               => HSYNC_I,
            SYNCn               => SYNCn,
            BLANKn              => BLANK_In,
            
            PD_VGAn             => PD_VGAn,
            VIDEO_MOD_TA        => VIDEO_MOD_TA,

            VD_VZ               => VD_VZ,
            SR_FIFO_WRE         => SR_FIFO_WRE,
            SR_VDMP             => SR_VDMP,
            FIFO_MW             => FIFO_MW,
            VDM_SEL             => VDM_SEL,
            VIDEO_RAM_CTR       => VIDEO_RAM_CTR,
            FIFO_CLR            => FIFO_CLR,
            VDM                 => VDM,
            BLITTER_ON          => BLITTER_ON,
            BLITTER_RUN         => BLITTER_RUN
        );

    I_INTHANDLER: INTHANDLER
        port map(
            CLK_MAIN            => CLK_MAIN,
            RESETn              => RESETn,
            FB_ADR              => FB_ADR,
            FB_CSn              => FB_CSn(2 downto 1),
            FB_OEn              => FB_OEn,
            FB_SIZE0            => FB_SIZE(0),
            FB_SIZE1            => FB_SIZE(1),
            FB_WRn              => FB_WRn,
            FB_AD_IN            => FB_AD,
            FB_AD_OUT           => FB_AD_OUT_IH,
            FB_AD_EN_31_24      => FB_AD_EN_31_24_IH,
            FB_AD_EN_23_16      => FB_AD_EN_23_16_IH,
            FB_AD_EN_15_8       => FB_AD_EN_15_8_IH,
            FB_AD_EN_7_0        => FB_AD_EN_7_0_IH,
            PIC_INT             => PIC_INT,
            E0_INT              => E0_INT,
            DVI_INT             => DVI_INT,
            PCI_INTAn           => PCI_INTAn,
            PCI_INTBn           => PCI_INTBn,
            PCI_INTCn           => PCI_INTCn,
            PCI_INTDn           => PCI_INTDn,
            MFP_INTn            => MFP_INTn,
            DSP_INT             => DSP_INT,
            VSYNC               => VSYNC_I,
            HSYNC               => HSYNC_I,
            DRQ_DMA             => DRQ_DMA,
            IRQn                => IRQn,
            INT_HANDLER_TA      => INT_HANDLER_TA,
            FBEE_CONF           => FBEE_CONF,
            TIN0                => TIN0
        );

    I_DMA: FBEE_DMA
        port map(
            RESET               => not RESETn,
            CLK_MAIN            => CLK_MAIN,
            CLK_FDC             => CLK_FDC,

            FB_ADR              => FB_ADR(26 downto 0),
            FB_ALE              => FB_ALE,
            FB_SIZE             => FB_SIZE,
            FB_CSn              => FB_CSn(2 downto 1),
            FB_OEn              => FB_OEn,
            FB_WRn              => FB_WRn,
            FB_AD_IN            => FB_AD,
            FB_AD_OUT           => FB_AD_OUT_DMA,
            FB_AD_EN_31_24      => FB_AD_EN_31_24_DMA,
            FB_AD_EN_23_16      => FB_AD_EN_23_16_DMA,
            FB_AD_EN_15_8       => FB_AD_EN_15_8_DMA,
            FB_AD_EN_7_0        => FB_AD_EN_7_0_DMA,

            ACSI_DIR            => ACSI_DIR,
            ACSI_D_IN           => ACSI_D,
            ACSI_D_OUT          => ACSI_D_OUT,
            ACSI_D_EN           => ACSI_D_EN,
            ACSI_CSn            => ACSI_CSn,
            ACSI_A1             => ACSI_A1,
            ACSI_RESETn         => ACSI_RESETn,
            ACSI_DRQn           => ACSI_DRQn,
            ACSI_ACKn           => ACSI_ACKn,

            DATA_IN_FDC         => DATA_OUT_FDC,
            DATA_IN_SCSI        => DATA_OUT_SCSI,
            DATA_OUT_FDC_SCSI	=> DATA_IN_FDC_SCSI,

            DMA_DRQ_IN          => DRQ_FDC,
            DMA_DRQ_OUT         => DRQ_DMA,            
            DMA_DRQ11           => DRQ11_DMA,

            SCSI_DRQ            => SCSI_DRQ,
            SCSI_DACKn          => SCSI_DACKn,
            SCSI_INT            => SCSI_INT,
            SCSI_CSn            => SCSI_CSn,
            SCSI_CS             => SCSI_CS,

            CA                  => CA,
            FLOPPY_HD_DD        => FDD_HD_DD,
            WDC_BSL0            => WDC_BSL0,
            FDC_CSn             => FDC_CSn,
            FDC_WRn             => FDC_WRn,
            FD_INT              => FD_INT,
            IDE_INT             => IDE_INT,
            DMA_CS              => DMA_CS
        );

    I_IDE_CF_SD_ROM: IDE_CF_SD_ROM
        port map(
            RESET               => not RESETn,
            CLK_MAIN            => CLK_MAIN,

            FB_ADR              => FB_ADR(19 downto 5),
            FB_CS1n             => FB_CSn(1),
            FB_WRn              => FB_WRn,
            FB_B0               => FB_B0,
            FB_B1               => FB_B1,

            FBEE_CONF           => FBEE_CONF(31 downto 30),

            RP_UDSn             => RP_UDSn,
            RP_LDSn             => RP_LDSn,

            SD_CLK              => SD_CLK,
            SD_D0               => SD_D0,
            SD_D1               => SD_D1,
            SD_D2               => SD_D2,
            SD_CD_D3_IN         => SD_D3,
            SD_CD_D3_OUT        => SD_CD_D3_OUT,
            SD_CD_D3_EN         => SD_CD_D3_EN,
            SD_CMD_D1_IN        => SD_CMD_D1,
            SD_CMD_D1_OUT       => SD_CMD_D1_OUT,
            SD_CMD_D1_EN        => SD_CMD_D1_EN,
            SD_CARD_DETECT      => SD_CARD_DETECT,
            SD_WP               => SD_WP,

            IDE_RDY             => IDE_RDY,
            IDE_WRn             => IDE_WRn,
            IDE_RDn             => IDE_RDn,
            IDE_CSn             => IDE_CSn,
            -- IDE_DRQn         =>, -- Not used.
            IDE_CF_TA           => IDE_CF_TA,

            ROM4n               => ROM4n,
            ROM3n               => ROM3n,

            CF_WP               => CF_WP,
            CF_CSn              => CF_CSn
        );

    I_DSP: DSP
        port map(
            CLK_33M             => CLK_33M,
            CLK_MAIN            => CLK_MAIN,
            FB_OEn              => FB_OEn,
            FB_WRn              => FB_WRn,
            FB_CS1n             => FB_CSn(1),
            FB_CS2n             => FB_CSn(2),
            FB_SIZE0            => FB_SIZE(0),
            FB_SIZE1            => FB_SIZE(1),
            FB_BURSTn           => FB_BURSTn,
            FB_ADR              => FB_ADR,
            RESETn              => RESETn,
            FB_CS3n             => FB_CSn(3),
            SRCSn               => DSP_SRCSn,
            SRBLEn              => DSP_SRBLEn,
            SRBHEn              => DSP_SRBHEn,
            SRWEn               => DSP_SRWEn,
            SROEn               => DSP_SROEn,
            DSP_INT             => DSP_INT,
            DSP_TA              => DSP_TA,
            FB_AD_IN            => FB_AD,
            FB_AD_OUT           => FB_AD_OUT_DSP,
            FB_AD_EN            => FB_AD_EN_DSP,
            IO_IN               => DSP_IO,
            IO_OUT              => DSP_IO_OUT,
            IO_EN               => DSP_IO_EN,
            SRD_IN              => DSP_SRD,
            SRD_OUT             => DSP_SRD_OUT,
            SRD_EN              => DSP_SRD_EN
        );

    I_SOUND: WF2149IP_TOP_SOC
		port map(
            SYS_CLK				=> CLK_MAIN,
			RESETn				=> RESETn,

			WAV_CLK				=> CLK_2M0,
			SELn				=> '1',

            BDIR				=> SNDIR_I,
			BC2					=> '1',
            BC1					=> SNDCS_I,

			A9n					=> '0',
			A8					=> '1',
            DA_IN				=> FB_AD(31 downto 24),
            DA_OUT 				=> DA_OUT_X,

			IO_A_IN				=> x"00", -- All port pins are dedicated outputs.
            IO_A_OUT(7)			=> IDE_RES_I,
            IO_A_OUT(6)			=> LP_DIR_X,
            IO_A_OUT(5)			=> LP_STR,
            IO_A_OUT(4)			=> DTR,
            IO_A_OUT(3)			=> RTS,
            IO_A_OUT(2)		    => RESERVED_1,
            IO_A_OUT(1)			=> DSA_D,
            IO_A_OUT(0)			=> FDD_SDSELn,
            -- IO_A_EN			=> TOUT0n, -- Not required.
            IO_B_IN				=> LP_D,
            IO_B_OUT			=> LP_D_X,
            -- IO_B_EN			=> -- Not used.

			OUT_A				=> YM_QA,
			OUT_B				=> YM_QB,
			OUT_C				=> YM_QC
		);

	I_MFP: WF68901IP_TOP_SOC
		port map(  
			-- System control:
            CLK					=> CLK_MAIN,
			RESETn				=> RESETn,
			-- Asynchronous bus control:
            DSn					=> not LDS,
            CSn					=> not MFP_CS,
            RWn					=> FB_WRn,
            DTACKn				=> DTACK_OUT_MFPn,
            -- Data and Adresses:
            RS					=> FB_ADR(5 downto 1),
            DATA_IN				=> FB_AD(23 downto 16),
            DATA_OUT			=> DATA_OUT_MFP,
            -- DATA_EN			=> DATA_EN_MFP, -- Not used.
            GPIP_IN(7)			=> not DRQ11_DMA,
            GPIP_IN(6)			=> not RI,
            GPIP_IN(5)			=> DINTn,
            GPIP_IN(4)			=> ACIA_IRQn,
            GPIP_IN(3)			=> DSP_INT,
            GPIP_IN(2)			=> not CTS,
            GPIP_IN(1)			=> not DCD,
            GPIP_IN(0)			=> LP_BUSY,
            -- GPIP_OUT			=>, -- Not used; all GPIPs are direction input.
            -- GPIP_EN			=>, -- Not used; all GPIPs are direction input.
            -- Interrupt control:
            IACKn				=> not MFP_INTACK,
            IEIn				=> '0',
            -- IEOn				=>, -- Not used.
            IRQn				=> MFP_INTn,
            -- Timers and timer control:
            XTAL1				=> CLK_2M4576,
            TAI					=> '0',
            TBI				   	=> BLANK_In,
            -- TAO				=>,
            -- TBO				=>,
            -- TCO				=>,
            TDO					=> TDO,
            -- Serial I/O control:
            RC					=> TDO,
            TC					=> TDO,
            SI					=> RxD, 
            SO					=> TxD
            -- SO_EN			=> -- Not used.
            -- DMA control:
            -- RRn				=> -- Not used.
            -- TRn				=> -- Not used.
		);

	I_ACIA_MIDI: WF6850IP_TOP_SOC
		port map(
			CLK					=> CLK_MAIN,
			RESETn				=> RESETn,

			CS2n				=> '0',
			CS1					=> FB_ADR(2),
            CS0					=> ACIA_CS,
            E					=> ACIA_CS,
            RWn					=> FB_WRN,
            RS					=> FB_ADR(1),

            DATA_IN				=> FB_AD(31 downto 24),
            DATA_OUT			=> DATA_OUT_ACIA_II,
            -- DATA_EN				=> -- Not used.

            TXCLK				=> CLK_500K,
            RXCLK				=> CLK_500K,
            RXDATA				=> MIDI_IN,
            CTSn				=> '0',
            DCDn				=> '0',

            IRQn				=> IRQ_MIDIn,
            TXDATA				=> MIDI_OUT
            --RTSn				=> -- Not used.
	    );                                              

    I_ACIA_KEYBOARD: WF6850IP_TOP_SOC
        port map(
			CLK					=> CLK_MAIN,
			RESETn				=> RESETn,

			CS2n				=> FB_ADR(2),
			CS1					=> '1',
            CS0					=> ACIA_CS,
            E					=> ACIA_CS,
            RWn					=> FB_WRn,
            RS					=> FB_ADR(1),

            DATA_IN				=> FB_AD(31 downto 24),
            DATA_OUT			=> DATA_OUT_ACIA_I,
            -- DATA_EN				=> Not used.

            TXCLK				=> CLK_500K,
            RXCLK				=> CLK_500K,
            RXDATA				=> KEYB_RxD,

            CTSn				=> '0',
            DCDn				=> '0',

            IRQn				=> IRQ_KEYBDn,
            TXDATA				=> AMKB_TX
            --RTSn				=> -- Not used.
		);                                              

	I_SCSI: WF5380_TOP_SOC
		port map(
			CLK					=> CLK_FDC,
			RESETn				=> RESETn,
			ADR			        => CA,
			DATA_IN		        => DATA_IN_FDC_SCSI,
			DATA_OUT			=> DATA_OUT_SCSI,
			--DATA_EN			=>,
			-- Bus and DMA controls:
			CSn			        => SCSI_CSn,
			RDn		            => not FDC_WRn or not SCSI_CS,
			WRn	                => FDC_WRn  or not SCSI_CS,
			EOPn                => '1',
			DACKn	            => SCSI_DACKn,
			DRQ		            => SCSI_DRQ,
			INT		            => SCSI_INT,
			-- READY            =>, 
			-- SCSI bus:
			DB_INn		        => SCSI_D,
			DB_OUTn		        => SCSI_D_OUTn,
			DB_EN               => SCSI_D_EN,
			DBP_INn		        => SCSI_PAR,
			DBP_OUTn	        => SCSI_DBP_OUTn,
			DBP_EN              => SCSI_DBP_EN,				-- wenn 1 dann output
			RST_INn             => SCSI_RSTn,
			RST_OUTn            => SCSI_RST_OUTn,
			RST_EN              => SCSI_RST_EN,
			BSY_INn             => SCSI_BUSYn,
			BSY_OUTn            => SCSI_BSY_OUTn,
			BSY_EN              => SCSI_BSY_EN,
			SEL_INn             => SCSI_SELn,
			SEL_OUTn            => SCSI_SEL_OUTn,
			SEL_EN              => SCSI_SEL_EN,
			ACK_INn             => '1',
			ACK_OUTn            => SCSI_ACKn,
			-- ACK_EN           => ACK_EN,
			ATN_INn             => '1',
			ATN_OUTn            => SCSI_ATNn,
			-- ATN_EN           => ATN_EN,
			REQ_INn             => SCSI_DRQn,
			-- REQ_OUTn         => REQ_OUTn,
			-- REQ_EN           => REQ_EN,
			IOn_IN              => SCSI_IOn,
			-- IOn_OUT          => IOn_OUT,
			-- IO_EN            => IO_EN,
			CDn_IN              => SCSI_CDn,
			-- CDn_OUT          => CDn_OUT,
			-- CD_EN            => CD_EN,
			MSG_INn             => SCSI_MSGn
			-- MSG_OUTn         => MSG_OUTn,
			-- MSG_EN           => MSG_EN
		);              

	I_FDC: WF1772IP_TOP_SOC
		port map(
			CLK					=> CLK_FDC,
			RESETn				=> RESETn,
			CSn					=> FDC_CSn,
			RWn					=> FDC_WRn,
			A1					=> CA(2),
			A0					=> CA(1),
			DATA_IN				=> DATA_IN_FDC_SCSI,
			DATA_OUT			=> DATA_OUT_FDC,
			-- DATA_EN			=> CD_EN_FDC,
			RDn					=> FDD_RDn,
			TR00n				=> FDD_TRACK00,
			IPn					=> FDD_INDEXn,
			WPRTn				=> FDD_WPn,
			DDEn				=> '0', -- Fixed to MFM.
			HDTYPE				=> HD_DD_OUT,  
			MO					=> FDD_MOT_ON,
			WG					=> FDD_WR_GATE,
			WD					=> FDD_WDn,
			STEP				=> FDD_STEP,
			DIRC				=> FDD_STEP_DIR,
			DRQ					=> DRQ_FDC,
			INTRQ				=> FD_INT 
		);

	I_RTC: RTC
		port map(
			CLK_MAIN            => CLK_MAIN,
			FB_ADR              => FB_ADR(19 downto 0),
			FB_CS1n             => FB_CSn(1),
			FB_SIZE0            => FB_SIZE(0),
			FB_SIZE1            => FB_SIZE(1),
			FB_WRn              => FB_WRn,
			FB_OEn              => FB_OEn,
			FB_AD_IN            => FB_AD(23 downto 16),
			FB_AD_OUT           => FB_AD_OUT_RTC,
			FB_AD_EN_23_16      => FB_AD_EN_RTC,
			PIC_INT             => PIC_INT
		);
end architecture;

configuration NO_SCSI of firebee is
	for Structure
		for all:
			WF5380_TOP_SOC use entity work.WF5380_TOP_SOC(LIGHT);
		end for;
	end for;	
end configuration no_scsi;

configuration FULL of firebee is
	for Structure
		-- default configuration
	end for;
end configuration FULL;