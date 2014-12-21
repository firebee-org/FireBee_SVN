----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the video controller of the 'Fire- ----
---- bee' computer. It is optimized for the use of an Altera Cyc- ----
---- lone FPGA (EP3C40F484). This IP-Core is based on the first   ----
---- edition of the Firebee configware originally provided by     ----
---- Fredi Ashwanden  and Wolfgang Förster. This release is in    ----
---- comparision to the first edition completely written in VHDL. ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi Aschwanden, Wolfgang Förster        ----
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
use ieee.numeric_std.all;

entity VIDEO_CTRL is
	port(
		CLK_MAIN        : in std_logic;
		FB_CSn          : in std_logic_vector(2 downto 1);
		fb_wr_n          : in std_logic;
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
end entity VIDEO_CTRL;

architecture BEHAVIOUR of VIDEO_CTRL is
	signal CLK17M                   : std_logic; 
	signal CLK13M                   : std_logic;
	signal FBEE_CLUT_CS             : std_logic;
	signal FBEE_CLUT                : std_logic;
	signal VIDEO_PLL_CONFIG_CS      : std_logic;
	signal VR_WR_I                  : std_logic;
	signal VR_DOUT                  : std_logic_vector(8 downto 0);
	signal VR_FRQ                   : std_logic_vector(7 downto 0);
	signal VIDEO_PLL_RECONFIG_CS    : std_logic;
	signal VIDEO_RECONFIG_I         : std_logic;
	signal FALCON_CLUT_CS           : std_logic;
	signal FALCON_CLUT              : std_logic;
	signal ST_CLUT_CS               : std_logic;
	signal ST_CLUT                  : std_logic;
	signal FB_B                     : std_logic_vector(3 downto 0);
	signal FB_16B                   : std_logic_vector(1 downto 0);
	signal ST_SHIFT_MODE            : std_logic_vector(1 downto 0);
	signal ST_SHIFT_MODE_CS         : std_logic;
	signal FALCON_SHIFT_MODE        : std_logic_vector(10 downto 0);
	signal FALCON_SHIFT_MODE_CS     : std_logic;
	signal CLUT_MUX_AV_1            : std_logic_vector(3 downto 0);
	signal CLUT_MUX_AV_0            : std_logic_vector(3 downto 0);
	signal FBEE_VCTR_CS             : std_logic;
	signal FBEE_VCTR                : std_logic_vector(31 downto 0);
	signal CCR_CS                   : std_logic;
	signal CCR_I                      : std_logic_vector(23 downto 0);
	signal FBEE_VIDEO_ON            : std_logic;
	signal SYS_CTR                  : std_logic_vector(6 downto 0);
	signal SYS_CTR_CS               : std_logic;
	signal VDL_LOF                  : std_logic_vector(15 downto 0);
	signal VDL_LOF_CS               : std_logic;
	signal VDL_LWD                  : std_logic_vector(15 downto 0);
	signal VDL_LWD_CS               : std_logic;

	-- Miscellaneous control registers:
	signal CLUT_TA                  : std_logic; -- Requires one wait state.
	signal HSYNC_I                  : std_logic_vector(7 downto 0);
	signal HSY_LEN                  : std_logic_vector(7 downto 0); -- Length of a HSYNC pulse in CLK_PIXEL cycles.
	signal HSYNC_START              : std_logic;
	signal LAST                     : std_logic; -- Last pixel of a line indicator.
	signal VSYNC_START              : std_logic;
	signal VSYNC_I                  : std_logic_vector(2 downto 0);
	signal BLANK_In                 : std_logic;
	signal DISP_ON                  : std_logic;
	signal DPO_ZL                   : std_logic;
	signal DPO_ON                   : std_logic;
	signal DPO_OFF                  : std_logic;
	signal VDTRON                   : std_logic;
	signal VDO_ZL                   : std_logic;
	signal VDO_ON                   : std_logic;
	signal VDO_OFF                  : std_logic;
	signal VHCNT                    : std_logic_vector(11 downto 0);
	signal SUB_PIXEL_CNT            : std_logic_vector(6 downto 0);
	signal VVCNT                    : std_logic_vector(10 downto 0);
	signal VERZ_2                   : std_logic_vector(9 downto 0);
	signal VERZ_1                   : std_logic_vector(9 downto 0);
	signal VERZ_0                   : std_logic_vector(9 downto 0);
	signal BORDER                     : std_logic_vector(6 downto 0);
	signal BORDER_ON                : std_logic;
	signal START_ZEILE              : std_logic;
	signal SYNC_PIX                 : std_logic;
	signal SYNC_PIX1                : std_logic;
	signal SYNC_PIX2                : std_logic;

	-- Legacy ATARI resolutions:
	signal ATARI_SYNC               : std_logic;   
	signal ATARI_HH                 : std_logic_vector(31 downto 0); -- Horizontal timing 640x480.
	signal ATARI_HH_CS              : std_logic;
	signal ATARI_VH                 : std_logic_vector(31 downto 0); -- Vertical timing 640x480.
	signal ATARI_VH_CS              : std_logic;
	signal ATARI_HL                 : std_logic_vector(31 downto 0); -- Horizontal timing 320x240.
	signal ATARI_HL_CS              : std_logic;
	signal ATARI_VL                 : std_logic_vector(31 downto 0); -- Vertical timing 320x240.
	signal ATARI_VL_CS              : std_logic;

	-- Horizontal stuff:
	signal BORDER_LEFT               : std_logic_vector(11 downto 0);
	signal HDIS_START               : std_logic_vector(11 downto 0);
	signal HDIS_END                 : std_logic_vector(11 downto 0);
	signal BORDER_RIGHT              : std_logic_vector(11 downto 0);
	signal HS_START                 : std_logic_vector(11 downto 0);
	signal H_TOTAL                  : std_logic_vector(11 downto 0);
	signal HDIS_LEN                 : std_logic_vector(11 downto 0);
	signal MULF                     : std_logic_vector(5 downto 0);
	signal VDL_HHT                  : std_logic_vector(11 downto 0);
	signal VDL_HHT_CS               : std_logic;
	signal VDL_HBE                  : std_logic_vector(11 downto 0);
	signal VDL_HBE_CS               : std_logic;
	signal VDL_HDB                  : std_logic_vector(11 downto 0);
	signal VDL_HDB_CS               : std_logic;
	signal VDL_HDE                  : std_logic_vector(11 downto 0);
	signal VDL_HDE_CS               : std_logic;
	signal VDL_HBB                  : std_logic_vector(11 downto 0);
	signal VDL_HBB_CS               : std_logic;
	signal VDL_HSS                  : std_logic_vector(11 downto 0);
	signal VDL_HSS_CS               : std_logic;
	
	-- Vertical stuff:
	signal BORDER_TOP                : std_logic_vector(10 downto 0);
	signal VDIS_START               : std_logic_vector(10 downto 0);
	signal VDIS_END                 : std_logic_vector(10 downto 0);
	signal BORDER_BOTTOM               : std_logic_vector(10 downto 0);
	signal VS_START                 : std_logic_vector(10 downto 0);
	signal V_TOTAL                  : std_logic_vector(10 downto 0);
	signal FALCON_VIDEO             : std_logic;
	signal ST_VIDEO                 : std_logic;
	signal INTER_ZEI_I              : std_logic;
	signal DOP_ZEI                  : std_logic;
    
	signal VDL_VBE                  : std_logic_vector(10 downto 0);
	signal VDL_VBE_CS               : std_logic;
	signal VDL_VDB                  : std_logic_vector(10 downto 0);
	signal VDL_VDB_CS               : std_logic;
	signal VDL_VDE                  : std_logic_vector(10 downto 0);
	signal VDL_VDE_CS               : std_logic;
	signal VDL_VBB                  : std_logic_vector(10 downto 0);
	signal VDL_VBB_CS               : std_logic;
	signal VDL_VSS                  : std_logic_vector(10 downto 0);
	signal VDL_VSS_CS               : std_logic;
	signal VDL_VFT                  : std_logic_vector(10 downto 0);
	signal VDL_VFT_CS               : std_logic;
	signal VDL_VCT                  : std_logic_vector(8 downto 0);
	signal VDL_VCT_CS               : std_logic;
	signal VDL_VMD                  : std_logic_vector(3 downto 0);
	signal VDL_VMD_CS               : std_logic;
	signal COLOR1_I                 : std_logic;
	signal COLOR2_I                 : std_logic;
	signal COLOR4_I                 : std_logic;
	signal COLOR8_I                 : std_logic;
	signal COLOR16_I                : std_logic;
	signal COLOR24_I                : std_logic;
	signal VIDEO_MOD_TA_I           : std_logic;
	signal VR_RD_I                  : std_logic;
	signal CLK_PIXEL_I              : std_logic;
	signal MUL1                     : unsigned (16 downto 0);
	signal MUL2                     : unsigned(16 downto 0);
	signal MUL3                     : unsigned(16 downto 0);
begin
	VR_WR <= VR_WR_I;
	VIDEO_RECONFIG <= VIDEO_RECONFIG_I;
	CCR <= CCR_I;
	INTER_ZEI <= INTER_ZEI_I;
	VIDEO_MOD_TA <= VIDEO_MOD_TA_I;
	VR_RD <= VR_RD_I;
	CLK_PIXEL <= CLK_PIXEL_I;
	
	-- Byte selectors:
	FB_B(0) <= '1' when FB_ADR(1 downto 0) = "00" else '0'; -- Byte 0.

	FB_B(1) <= '1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '1' else -- Long word.
					'1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '0' else -- Long.
					'1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '0' and FB_ADR(1) = '0' else -- High word.
					'1' when FB_ADR(1 downto 0) = "01" else '0'; -- Byte 1.
             
	FB_B(2) <= '1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '1' else -- Long word.
					'1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '0' else -- Long.
					'1' when FB_ADR(1 downto 0) = "10" else '0'; -- Byte 2.
             
	FB_B(3) <= '1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '1' else -- Long word.
					'1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '0' else -- Long.
					'1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '0' and FB_ADR(1) = '1' else -- Low word.
					'1' when FB_ADR(1 downto 0) = "11" else '0'; -- Byte 3.
             
	-- 16 bit selectors:
	FB_16B(0) <= not FB_ADR(0);
	FB_16B(1) <= '1'when FB_ADR(0) = '1' else
					'1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '0' else -- No byte.
					'1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '0' else -- No byte.
					'1' when FB_SIZE(1) = '1' and FB_SIZE(0) = '1' else '0'; -- No byte.

	-- Firebee CLUT:
	FBEE_CLUT_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 10) = "000000000000000000" else '0'; -- 0-3FF/1024
	FBEE_CLUT_RD <= '1' when FBEE_CLUT_CS = '1' and FB_OEn = '0' else '0';
	FBEE_CLUT_WR <= FB_B when FBEE_CLUT_CS = '1' and fb_wr_n = '0' else x"0";

	P_CLUT_TA : process
	begin
		wait until CLK_MAIN = '1' and CLK_MAIN' event;
		if VIDEO_MOD_TA_I = '0' and FBEE_CLUT_CS = '1' then
			CLUT_TA <= '1';
		elsif VIDEO_MOD_TA_I = '0' and FALCON_CLUT_CS = '1' then
			CLUT_TA <= '1';
		elsif VIDEO_MOD_TA_I = '0' and ST_CLUT_CS = '1' then
			CLUT_TA <= '1';
		else
			CLUT_TA <= '0';
		end if;
	end process P_CLUT_TA;

	--Falcon CLUT:
	FALCON_CLUT_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 10) = "1111100110" else '0'; -- $F9800/$400
	FALCON_CLUT_RDH <= '1' when FALCON_CLUT_CS = '1' and FB_OEn = '0' and FB_ADR(1) = '0' else '0'; -- High word.
	FALCON_CLUT_RDL <= '1' when FALCON_CLUT_CS = '1' and FB_OEn = '0' and FB_ADR(1) = '1' else '0'; -- Low word.
	FALCON_CLUT_WR(1 downto 0) <= FB_16B when FB_ADR(1) = '0' and FALCON_CLUT_CS = '1' and fb_wr_n = '0' else "00";
	FALCON_CLUT_WR(3 downto 2) <= FB_16B when FB_ADR(1) = '1' and FALCON_CLUT_CS = '1' and fb_wr_n = '0' else "00";
	
	-- ST CLUT:
	ST_CLUT_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 5) = "111110000010010" else '0'; -- $F8240/$2
	CLUT_ST_RD <= '1' when ST_CLUT_CS = '1' and FB_OEn = '0' else '0';
	CLUT_ST_WR <= FB_16B when ST_CLUT_CS = '1' and fb_wr_n = '0' else "00";

	ST_SHIFT_MODE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = "1111100000100110000" else '0'; -- $F8260/$2.
	FALCON_SHIFT_MODE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = "1111100000100110011" else '0'; -- $F8266/$2.
	FBEE_VCTR_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000000000100000000" else '0'; -- $400/$4
	ATARI_HH_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000000000100000100" else '0'; -- $410/4
	ATARI_VH_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000000000100000101" else '0'; -- $414/4
	ATARI_HL_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000000000100000110" else '0'; -- $418/4
	ATARI_VL_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000000000100000111" else '0'; -- $41C/4

	P_VIDEO_CONTROL : process
	begin
		wait until rising_edge(CLK_MAIN);
		if ST_SHIFT_MODE_CS = '1' and fb_wr_n = '0' and FB_B(0) = '1' then
			ST_SHIFT_MODE <= DATA_IN(25 downto 24);
		end if;

		if FALCON_SHIFT_MODE_CS = '1' and fb_wr_n = '0' and FB_B(2) = '1' then
			FALCON_SHIFT_MODE(10 downto 8) <= DATA_IN(26 downto 24);
		elsif FALCON_SHIFT_MODE_CS = '1' and fb_wr_n = '0' and FB_B(3) = '1' then
			FALCON_SHIFT_MODE(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- Firebee VIDEO CONTROL:
		-- Bit 0 = FBEE VIDEO ON, 1 = POWER ON VIDEO DAC, 2 = FBEE 24BIT,
		-- Bit 3 = FBEE 16BIT, 4 = FBEE 8BIT, 5 = FBEE 1BIT, 
		-- Bit 6 = FALCON SHIFT MODE, 7 = ST SHIFT MODE, 9..8 = VCLK frequency,
		-- Bit 15 = SYNC ALLOWED, 31..16 = VIDEO_RAM_CTR,
		-- Bit 25 = RANDFARBE EINSCHALTEN, 26 = STANDARD ATARI SYNCS.
		if FBEE_VCTR_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			FBEE_VCTR(31 downto 24) <= DATA_IN(31 downto 24);
		elsif FBEE_VCTR_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			FBEE_VCTR(23 downto 16) <= DATA_IN(23 downto 16);
		elsif FBEE_VCTR_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			FBEE_VCTR(15 downto 8) <= DATA_IN(15 downto 8);
		elsif FBEE_VCTR_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			FBEE_VCTR(5 downto 0) <= DATA_IN(5 downto 0);
		end if;
        
		-- ST or Falcon shift mode: assert when X..shift register:
		if FALCON_SHIFT_MODE_CS = '1' and fb_wr_n = '0' then
			FBEE_VCTR(7) <= FALCON_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
			FBEE_VCTR(6) <= ST_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
		end if;
		if ST_SHIFT_MODE_CS = '1' and fb_wr_n = '0' then
			FBEE_VCTR(7) <= FALCON_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
			FBEE_VCTR(6) <= ST_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
		end if;
		if FBEE_VCTR_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' and DATA_IN(0) = '1' then
			FBEE_VCTR(7) <= FALCON_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
			FBEE_VCTR(6) <= ST_SHIFT_MODE_CS and not fb_wr_n and not FBEE_VIDEO_ON;
		end if;
    
		-- ATARI ST mode
		-- Horizontal timing 640x480:
		if ATARI_HH_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			ATARI_HH(31 downto 24) <= DATA_IN(31 downto 24);
		elsif ATARI_HH_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			ATARI_HH(23 downto 16) <= DATA_IN(23 downto 16);
		elsif ATARI_HH_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			ATARI_HH(15 downto 8) <= DATA_IN(15 downto 8);
		elsif ATARI_HH_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			ATARI_HH(7 downto 0) <= DATA_IN(7 downto 0);
		end if;

		-- Vertical timing 640x480:
		if ATARI_VH_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			ATARI_VH(31 downto 24) <= DATA_IN(31 downto 24);
		elsif ATARI_VH_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			ATARI_VH(23 downto 16) <= DATA_IN(23 downto 16);
		elsif ATARI_VH_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			ATARI_VH(15 downto 8) <= DATA_IN(15 downto 8);
		elsif ATARI_VH_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			ATARI_VH(7 downto 0) <= DATA_IN(7 downto 0);
		end if;

		-- Horizontal timing 320x240:
		if ATARI_HL_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			ATARI_HL(31 downto 24) <= DATA_IN(31 downto 24);
		elsif ATARI_HL_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			ATARI_HL(23 downto 16) <= DATA_IN(23 downto 16);
		elsif ATARI_HL_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			ATARI_HL(15 downto 8) <= DATA_IN(15 downto 8);
		elsif ATARI_HL_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			ATARI_HL(7 downto 0) <= DATA_IN(7 downto 0);
		end if;

		-- Vertical timing 320x240:
		if ATARI_VL_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			ATARI_VL(31 downto 24) <= DATA_IN(31 downto 24);
		elsif ATARI_VL_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			ATARI_VL(23 downto 16) <= DATA_IN(23 downto 16);
		elsif ATARI_VL_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			ATARI_VL(15 downto 8) <= DATA_IN(15 downto 8);
		elsif ATARI_VL_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			ATARI_VL(7 downto 0) <= DATA_IN(7 downto 0);
		end if;
	end process P_VIDEO_CONTROL;
    
	CLUT_OFF <= FALCON_SHIFT_MODE(3 downto 0) when COLOR4_I = '1' else x"0";
	PD_VGAn <= FBEE_VCTR(1);
	FBEE_VIDEO_ON <= FBEE_VCTR(0);
	ATARI_SYNC <= FBEE_VCTR(26); -- If 1 -> automatic resolution.

	COLOR1_I <= '1' when ST_VIDEO = '1' and FBEE_VIDEO_ON = '0' and ST_SHIFT_MODE = "10" and COLOR8_I = '0' else -- ST mono.
					'1' when FALCON_VIDEO = '1' and FBEE_VIDEO_ON = '0' and FALCON_SHIFT_MODE(10) = '1' and COLOR16_I = '0' and COLOR8_I = '0' else -- Falcon mono.
					'1' when FBEE_VIDEO_ON = '1' and FBEE_VCTR(5 downto 2) = "1000" else '0'; -- Firebee mode.
	COLOR2_I <= '1' when ST_VIDEO = '1' and FBEE_VIDEO_ON = '0' and ST_SHIFT_MODE = "01" and COLOR8_I = '0' else '0'; -- ST 4 colours.
	COLOR4_I <= '1' when ST_VIDEO = '1' and FBEE_VIDEO_ON = '0' and ST_SHIFT_MODE = "00" and COLOR8_I = '0' else -- ST 16 colours.
					'1' when FALCON_VIDEO = '1' and FBEE_VIDEO_ON = '0' and COLOR16_I = '0' and COLOR8_I = '0' and COLOR1_I = '0' else '0'; -- Falcon mode.
	COLOR8_I <= '1' when FALCON_VIDEO = '1' and FBEE_VIDEO_ON = '0' and FALCON_SHIFT_MODE(4) = '1' and COLOR16_I = '0' else -- Falcon mode.
					'1' when FBEE_VIDEO_ON = '1' and FBEE_VCTR(4 downto 2) = "100" else '0'; -- Firebee mode.
	COLOR16_I <= '1' when FALCON_VIDEO = '1' and FBEE_VIDEO_ON = '0' and FALCON_SHIFT_MODE(8) = '1' else -- Falcon mode.
					'1' when FBEE_VIDEO_ON = '1' and FBEE_VCTR(3 downto 2) = "10" else '0'; -- Firebee mode.
	COLOR24_I <= '1' when FBEE_VIDEO_ON = '1' and FBEE_VCTR(2) = '1' else '0'; -- Firebee mode.
    
	COLOR1 <= COLOR1_I;
	COLOR2 <= COLOR2_I;
	COLOR4 <= COLOR4_I;
	COLOR8 <= COLOR8_I;
	
	-- VIDEO PLL config and reconfig:
	VIDEO_PLL_CONFIG_CS <= '1' when FB_CSn(2) = '0' and FB_B(0) = '1' and FB_B(1) = '1' and FB_ADR(27 downto 9) = "0000000000000000011" else '0'; -- $(F)000'0600-7FF -> 6/2 word and long only.
	VIDEO_PLL_RECONFIG_CS <= '1' when FB_CSn(2) = '0' and FB_B(0) = '1' and FB_ADR(27 downto 0) = x"0000800" else '0'; -- $(F)000'0800. 
	VR_RD_I <= '1' when VIDEO_PLL_CONFIG_CS = '1' and fb_wr_n = '0' and VR_BUSY = '0' else '0';

	P_VIDEO_CONFIG: process
		variable LOCK : boolean;
	begin
		wait until rising_edge(CLK_MAIN);

		if VIDEO_PLL_CONFIG_CS = '1' and fb_wr_n = '0' and VR_BUSY = '0' and VR_WR_I = '0' then
			VR_WR_I <= '1'; -- This is a strobe.
		else
			VR_WR_I <= '0';
		end if;

		if VR_BUSY = '1' then
			VR_DOUT <= VR_D;
		end if;
        
		if VR_WR_I = '1' and FB_ADR(8 downto 0) = "000000100" then
			VR_FRQ <= DATA_IN(23 downto 16);
		end if;

		if VIDEO_PLL_RECONFIG_CS = '1' and fb_wr_n = '0' and VR_BUSY = '0' and LOCK = false then
			VIDEO_RECONFIG_I <= '1'; -- This is a strobe.
			LOCK := true;
		elsif VIDEO_PLL_RECONFIG_CS = '0' or fb_wr_n = '1' or VR_BUSY = '1' then
			VIDEO_RECONFIG_I <= '0';
			LOCK := false;
		else
			VIDEO_RECONFIG_I <= '0';
		end if;
	end process P_VIDEO_CONFIG;
    
	VIDEO_RAM_CTR <= FBEE_VCTR(31 downto 16);
    
	-- Firebee colour modi: 
	FBEE_CLUT <= '1' when FBEE_VIDEO_ON = '1' and (COLOR1_I = '1' or COLOR8_I = '1') else
						'1' when ST_VIDEO = '1' and COLOR1_I = '1';
                 
	FALCON_VIDEO <= FBEE_VCTR(7);
	FALCON_CLUT <= '1' when FALCON_VIDEO = '1' and FBEE_VIDEO_ON = '0' and COLOR16_I = '0' else '0';
	ST_VIDEO <= FBEE_VCTR(6);
	ST_CLUT <= '1' when ST_VIDEO = '1' and FBEE_VIDEO_ON = '0' and FALCON_CLUT = '0' and COLOR1_I = '0' else '0';

    -- Several (video)-registers:
	CCR_CS <= '1' when FB_CSn(2) = '0' and FB_ADR = x"f0000404" else '0';	-- $F0000404 - Firebee video border color
	SYS_CTR_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8008" else '0';	-- $FF8006 - Falcon monitor type register
	VDL_LOF_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff820e" else '0'; -- $FF820E/F - line-width hi/lo.
	VDL_LWD_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8210" else '0'; -- $FF8210/1 - vertical wrap hi/lo.
	VDL_HHT_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8282" else '0'; -- $FF8282/3 - horizontal hold timer hi/lo.
	VDL_HBE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8286" else '0'; -- $FF8286/7 - horizontal border end hi/lo.
	VDL_HDB_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8288" else '0'; -- $FF8288/9 - horizontal display begin hi/lo.
	VDL_HDE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff828a" else '0'; -- $FF828A/B - horizontal display end hi/lo.
	VDL_HBB_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff8284" else '0'; -- $FF8284/5 - horizontal border begin hi/lo.
	VDL_HSS_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff828c" else '0'; -- $FF828C/D - position hsync (HSS).
	VDL_VFT_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82a2" else '0'; -- $FF82A2/3 - video frequency timer (VFT).
	VDL_VBB_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82a4" else '0'; -- $FF82A4/5 - vertical blank on (in half line steps).
	VDL_VBE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82a6" else '0'; -- $FF82A6/7 - vertical blank off (in half line steps).
	VDL_VDB_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82a8" else '0'; -- $FF82A8/9 - vertical display begin (VDB).
	VDL_VDE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82aa" else '0'; -- $FF82AA/B - vertical display end (VDE).
	VDL_VSS_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82ac" else '0'; -- $FF82AC/D - position vsync (VSS).
	VDL_VCT_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82c0" else '0'; -- $FF82C0/1 - clock control (VCO).
	VDL_VMD_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(23 downto 1) & '0' = x"ff82c2" else '0'; -- $FF82C2/3 - resolution control.

	P_MISC_CTRL : process
	begin
		wait until rising_edge(CLK_MAIN);
        
		-- Colour of video borders
		if CCR_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			CCR_I(23 downto 16) <= DATA_IN(23 downto 16);
		elsif CCR_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			CCR_I(15 downto 8) <= DATA_IN(15 downto 8);
		elsif CCR_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			CCR_I(7 downto 0) <= DATA_IN(7 downto 0);
		end if;

		-- SYS CTRL:
		if SYS_CTR_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			SYS_CTR <= DATA_IN(22 downto 16);
		end if;

		--VDL_LOF:
		if VDL_LOF_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_LOF(15 downto 8) <= DATA_IN(31 downto 24);
		elsif VDL_LOF_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_LOF(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		--VDL_LWD
		if VDL_LWD_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_LWD(15 downto 8) <= DATA_IN(31 downto 24);
		elsif VDL_LWD_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_LWD(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- Horizontal:
		-- VDL_HHT:
		if VDL_HHT_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_HHT(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HHT_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_HHT(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_HBE:
		if VDL_HBE_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_HBE(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HBE_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_HBE(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_HDB:
		if VDL_HDB_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_HDB(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HDB_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_HDB(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_HDE:
		if VDL_HDE_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_HDE(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HDE_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_HDE(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_HBB:
		if VDL_HBB_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_HBB(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HBB_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_HBB(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_HSS:
		if VDL_HSS_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_HSS(11 downto 8) <= DATA_IN(27 downto 24);
		elsif VDL_HSS_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_HSS(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- Vertical:
		-- VDL_VBE:
		if VDL_VBE_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_VBE(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VBE_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_VBE(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VDB:
		if VDL_VDB_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_VDB(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VDB_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_VDB(7 downto 0) <= DATA_IN(23 downto 16);
		end if;
        
		-- VDL_VDE:
		if VDL_VDE_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_VDE(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VDE_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_VDE(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VBB:
		if VDL_VBB_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_VBB(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VBB_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_VBB(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VSS
		if VDL_VSS_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_VSS(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VSS_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_VSS(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VFT
		if VDL_VFT_CS = '1' and FB_B(2) = '1' and fb_wr_n = '0' then
			VDL_VFT(10 downto 8) <= DATA_IN(26 downto 24);
		elsif VDL_VFT_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_VFT(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VCT(2): 1 = 32MHz CLK_PIXEL, 0 = 25MHZ; VDL_VCT(0): 1 = linedoubling.
		if VDL_VCT_CS = '1' and FB_B(0) = '1' and fb_wr_n = '0' then
			VDL_VCT(8) <= DATA_IN(24);
		elsif VDL_VCT_CS = '1' and FB_B(1) = '1' and fb_wr_n = '0' then
			VDL_VCT(7 downto 0) <= DATA_IN(23 downto 16);
		end if;

		-- VDL_VMD(2): 1 = CLK_PIXEL/2.
		if VDL_VMD_CS = '1' and FB_B(3) = '1' and fb_wr_n = '0' then
			VDL_VMD <= DATA_IN(19 downto 16);
		end if;
	end process P_MISC_CTRL;

	BLITTER_ON <= not SYS_CTR(3);
    
	-- Register out:
	DATA_OUT(31 downto 16) <= "000000" & ST_SHIFT_MODE & x"00" when ST_SHIFT_MODE_CS = '1' else
										"00000" & FALCON_SHIFT_MODE when FALCON_SHIFT_MODE_CS = '1' else
										"100000000" & SYS_CTR(6 downto 4) & not BLITTER_RUN & SYS_CTR(2 downto 0) when SYS_CTR_CS = '1' else
										VDL_LOF when VDL_LOF_CS = '1' else
										VDL_LWD when VDL_LWD_CS = '1' else
										x"0" & VDL_HBE when VDL_HBE_CS = '1' else
										x"0" & VDL_HDB when VDL_HDB_CS = '1' else
										x"0" & VDL_HDE when VDL_HDE_CS = '1' else
										x"0" & VDL_HBB when VDL_HBB_CS = '1' else
										x"0" & VDL_HSS when VDL_HSS_CS = '1' else
										x"0" & VDL_HHT when VDL_HHT_CS = '1' else
										"00000" & VDL_VBE when VDL_VBE_CS = '1' else
										"00000" & VDL_VDB when VDL_VDB_CS = '1' else
										"00000" & VDL_VDE when VDL_VDE_CS = '1' else
										"00000" & VDL_VBB when VDL_VBB_CS = '1' else
										"00000" & VDL_VSS when VDL_VSS_CS = '1' else
										"00000" & VDL_VFT when VDL_VFT_CS = '1' else
										"0000000" & VDL_VCT when VDL_VCT_CS = '1' else    
										x"000" & VDL_VMD when VDL_VMD_CS = '1' else
										FBEE_VCTR(31 downto 16) when FBEE_VCTR_CS = '1' else
										ATARI_HH(31 downto 16) when ATARI_HH_CS = '1' else
										ATARI_VH(31 downto 16) when ATARI_VH_CS = '1' else
										ATARI_HL(31 downto 16) when ATARI_HL_CS = '1' else
										ATARI_VL(31 downto 16) when ATARI_VL_CS = '1' else
										x"00" & CCR_I(23 downto 16) when CCR_CS = '1' else 
										"0000000" & VR_DOUT when VIDEO_PLL_CONFIG_CS = '1' else
										VR_BUSY & "0000" & VR_WR_I & VR_RD_I & VIDEO_RECONFIG_I & x"FA" when VIDEO_PLL_RECONFIG_CS = '1' else (others => '0');
    
	DATA_OUT(15 downto 0) <= FBEE_VCTR(15 downto 0) when FBEE_VCTR_CS = '1' else
										ATARI_HH(15 downto 0) when ATARI_HH_CS = '1' else
										ATARI_VH(15 downto 0) when ATARI_VH_CS = '1' else
										ATARI_HL(15 downto 0) when ATARI_HL_CS = '1' else
										ATARI_VL(15 downto 0) when ATARI_VL_CS = '1' else
										CCR_I(15 downto 0) when CCR_CS = '1' else (others => '0');

	DATA_EN_H <= (ST_SHIFT_MODE_CS or FALCON_SHIFT_MODE_CS or FBEE_VCTR_CS or CCR_CS or SYS_CTR_CS or VDL_LOF_CS or VDL_LWD_CS or
						VDL_HBE_CS or VDL_HDB_CS or VDL_HDE_CS or VDL_HBB_CS or VDL_HSS_CS or VDL_HHT_CS or
						ATARI_HH_CS or ATARI_VH_CS or ATARI_HL_CS or ATARI_VL_CS or VIDEO_PLL_CONFIG_CS or VIDEO_PLL_RECONFIG_CS or
						VDL_VBE_CS or VDL_VDB_CS or VDL_VDE_CS or VDL_VBB_CS or VDL_VSS_CS or VDL_VFT_CS or VDL_VCT_CS or VDL_VMD_CS) and not FB_OEn;

	DATA_EN_L <= (FBEE_VCTR_CS or CCR_CS or ATARI_HH_CS or ATARI_VH_CS or ATARI_HL_CS or ATARI_VL_CS ) and not FB_OEn;

	VIDEO_MOD_TA_I <= CLUT_TA or ST_SHIFT_MODE_CS or FALCON_SHIFT_MODE_CS or FBEE_VCTR_CS or SYS_CTR_CS or VDL_LOF_CS or VDL_LWD_CS or
							VDL_HBE_CS or VDL_HDB_CS or VDL_HDE_CS or VDL_HBB_CS or VDL_HSS_CS or VDL_HHT_CS or
							ATARI_HH_CS or ATARI_VH_CS or ATARI_HL_CS or ATARI_VL_CS or
							VDL_VBE_CS or VDL_VDB_CS or VDL_VDE_CS or VDL_VBB_CS or VDL_VSS_CS or VDL_VFT_CS or VDL_VCT_CS or VDL_VMD_CS;
    
	P_CLK_16M5 : process
	begin
		wait until rising_edge(CLK33M);
		CLK17M <= not CLK17M;
	end process P_CLK_16M5;

	P_CLK_12M5 : process
	begin
		wait until rising_edge(CLK25M);
		CLK13M <= not CLK13M;
	end process P_CLK_12M5;

	CLK_PIXEL_I <= CLK13M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(2) = '1' else
						CLK13M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(0) = '1' else
						CLK17M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(2) = '0' else
						CLK17M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(0) = '0' else
						CLK25M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and  VDL_VMD(2) = '0' and VDL_VCT(2) = '1' and VDL_VCT(0) = '0' else
						CLK33M when FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and  VDL_VMD(2) = '0' and VDL_VCT(2) = '0' and VDL_VCT(0) = '0' else
						CLK25M when FBEE_VIDEO_ON = '1' and FBEE_VCTR(9 downto 8) = "00" else
						CLK33M when FBEE_VIDEO_ON = '1' and FBEE_VCTR(9 downto 8) = "01" else
						CLK_VIDEO when FBEE_VIDEO_ON = '1' and FBEE_VCTR(9) = '1' else '0';

	P_HSYN_LEN  : process
		-- Horizontal SYNC in CLK_PIXEL:
	begin
		wait until rising_edge(CLK_MAIN);
		if FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(2) = '1' then
			HSY_LEN <= x"0E";
		elsif FBEE_VIDEO_ON = '0' and (FALCON_VIDEO = '1' or ST_VIDEO = '1') and VDL_VMD(2) = '1' and VDL_VCT(0) = '1' then
			HSY_LEN <= x"0E";
		elsif FBEE_VIDEO_ON = '0' and (FALCON_VIDEO or ST_VIDEO) = '1' and VDL_VMD(2) = '1' and VDL_VCT(2) = '0' then
			HSY_LEN <= x"10";
		elsif FBEE_VIDEO_ON = '0' and (FALCON_VIDEO or ST_VIDEO) = '1' and VDL_VMD(2) = '1' and VDL_VCT(0) = '0' then
			HSY_LEN <= x"10";
		elsif FBEE_VIDEO_ON = '0' and (FALCON_VIDEO or ST_VIDEO) = '1' and  VDL_VMD(2) = '0' and VDL_VCT(2) = '1' and VDL_VCT(0) = '0' then
			HSY_LEN <= x"1C";
		elsif FBEE_VIDEO_ON = '0' and (FALCON_VIDEO or ST_VIDEO) = '1' and  VDL_VMD(2) = '0' and VDL_VCT(2) = '0' and VDL_VCT(0) = '0' then
			HSY_LEN <= x"20";
		elsif FBEE_VIDEO_ON = '1' and FBEE_VCTR(9 downto 8) = "00" then
			HSY_LEN <= x"1C";
		elsif FBEE_VIDEO_ON = '1' and FBEE_VCTR(9 downto 8) = "01" then
			HSY_LEN <= x"20";
		elsif FBEE_VIDEO_ON = '1' and FBEE_VCTR(9) = '1' then
			HSY_LEN <= std_logic_vector(unsigned'(x"10") + unsigned('0' & VR_FRQ(7 downto 1))); -- HSYNC pulse length in pixels = frequency/500ns.
		else
			HSY_LEN <= x"00";
		end if;
	end process P_HSYN_LEN;

	MULF <= "000010" when ST_VIDEO = '0' and VDL_VMD(2) = '1' else -- Multiplier.
				"000100" when ST_VIDEO = '0' and VDL_VMD(2) = '0' else
				"010000" when ST_VIDEO = '1' and VDL_VMD(2) = '1' else
				"100000" when ST_VIDEO = '1' and VDL_VMD(2) = '0' else "000000";

	HDIS_LEN <= x"140" when VDL_VMD(2) = '1' else x"280"; -- Width in pixels (320 / 640).

	P_DOUBLE_LINE_1   : process
	begin
		wait until rising_edge(CLK_MAIN);
		DOP_ZEI <= VDL_VMD(0) and ST_VIDEO; -- Line doubling on off.
	end process P_DOUBLE_LINE_1;

	P_DOUBLE_LINE_2   : process
	begin
		wait until rising_edge(CLK_PIXEL_I);
		if DOP_ZEI = '1' and VVCNT(0) /= VDIS_START(0) and VVCNT /= "00000000000" and VHCNT < std_logic_vector(unsigned(HDIS_END) - 1) then        
			INTER_ZEI_I <= '1'; -- Switch insertion line to "double". Line zero due to SYNC.
		elsif DOP_ZEI = '1' and VVCNT(0) = VDIS_START(0) and VVCNT /= "00000000000" and VHCNT > std_logic_vector(unsigned(HDIS_END) - 10) then
			INTER_ZEI_I <= '1'; -- Switch insertion mode to "normal". Lines and line zero due to SYNC.
		else
			INTER_ZEI_I <= '0';
		end if;
		--
		DOP_FIFO_CLR <= INTER_ZEI_I and HSYNC_START and SYNC_PIX; -- Double line info erase at the end of a double line and at main FIFO start.
	end process P_DOUBLE_LINE_2;

    -- The following multiplications change every time the video resolution is changed.
	MUL1 <= unsigned(VDL_HBE) * unsigned(MULF(5 downto 1));
	MUL2 <= unsigned(VDL_HHT) + 1 + unsigned(VDL_HSS) * unsigned(MULF(5 downto 1));
	MUL3 <= resize(unsigned(VDL_HHT) + 10 * unsigned(MULF(5 downto 1)), MUL3'length);

	BORDER_LEFT <= VDL_HBE when FBEE_VIDEO_ON = '1' else 
						x"015" when ATARI_SYNC = '1' and VDL_VMD(2) = '1' else
						x"02A" when ATARI_SYNC = '1' else std_logic_vector(MUL1(16 downto 5));
	HDIS_START <= VDL_HDB when FBEE_VIDEO_ON = '1' else std_logic_vector(unsigned(BORDER_LEFT) + 1);
	HDIS_END <= VDL_HDE when FBEE_VIDEO_ON = '1' else std_logic_vector(unsigned(BORDER_LEFT) + unsigned(HDIS_LEN));
	BORDER_RIGHT <= VDL_HBB when FBEE_VIDEO_ON = '1' else std_logic_vector(unsigned(HDIS_END) + 1);
	HS_START <= VDL_HSS when FBEE_VIDEO_ON = '1' else
					ATARI_HL(11 downto 0) when ATARI_SYNC = '1' and VDL_VMD(2) = '1' else
					ATARI_HH(11 downto 0) when VDL_VMD(2) = '1' else std_logic_vector(MUL2(16 downto 5));
	H_TOTAL <= VDL_HHT when FBEE_VIDEO_ON = '1' else
					ATARI_HL(27 downto 16) when ATARI_SYNC = '1' and VDL_VMD(2) = '1' else
					ATARI_HH(27 downto 16) when ATARI_SYNC = '1' else std_logic_vector(MUL3(16 downto 5));
	BORDER_TOP <= VDL_VBE when FBEE_VIDEO_ON = '1' else
						"00000011111" when ATARI_SYNC = '1' else '0' & VDL_VBE(10 downto 1);
	VDIS_START <= VDL_VDB when FBEE_VIDEO_ON = '1' else
						"00000100000" when ATARI_SYNC = '1' else '0' & VDL_VDB(10 downto 1);
	VDIS_END <= VDL_VDE when FBEE_VIDEO_ON = '1' else
					"00110101111" when ATARI_SYNC = '1' and ST_VIDEO = '1' else -- 431.
					"00111111111" when ATARI_SYNC = '1' else '0' & VDL_VDE(10 downto 1); -- 511.
	BORDER_BOTTOM <= VDL_VBB when FBEE_VIDEO_ON = '1' else
						std_logic_vector(unsigned(VDIS_END) + 1) when ATARI_SYNC = '1' else ('0' & std_logic_vector(unsigned(VDL_VBB(10 downto 1)) + 1));
	VS_START <= VDL_VSS when FBEE_VIDEO_ON = '1' else
					ATARI_VL(10 downto 0) when ATARI_SYNC = '1' and VDL_VMD(2) = '1' else
					ATARI_VH(10 downto 0) when ATARI_SYNC = '1' else '0' & VDL_VSS(10 downto 1);
	V_TOTAL <= VDL_VFT when FBEE_VIDEO_ON = '1' else
					ATARI_VL(26 downto 16) when ATARI_SYNC = '1' and VDL_VMD(2) = '1' else
					ATARI_VH(26 downto 16) when ATARI_SYNC = '1' else '0' & VDL_VFT(10 downto 1);

	LAST <= '1' when VHCNT  = std_logic_vector(unsigned(H_TOTAL) - 10) else '0';

	VIDEO_CLOCK_DOMAIN   : process
	begin
		wait until rising_edge(CLK_PIXEL_I);
		if ST_CLUT = '1' then
			CCSEL <= "000"; -- For information only.
		elsif FALCON_CLUT = '1' then
			CCSEL <= "001";
		elsif FBEE_CLUT = '1' then
			CCSEL <= "100";
		elsif COLOR16_I = '1' then
			CCSEL <= "101";
		elsif COLOR24_I = '1' then
			CCSEL <= "110";
		elsif BORDER_ON = '1' then
			CCSEL <= "111";
		end if;

		if LAST = '0' then
			VHCNT <= std_logic_vector(unsigned(VHCNT) + 1);
		else
			VHCNT <= (others => '0');
		end if;

		if LAST = '1' and VVCNT = std_logic_vector(unsigned(V_TOTAL) - 1) then
			VVCNT <= (others => '0');
		elsif LAST = '1' then
			VVCNT <= std_logic_vector(unsigned(VVCNT) + 1);
		end if;

		-- Display on/off:
		if LAST = '1' and VVCNT > std_logic_vector(unsigned(BORDER_TOP) - 1) and VVCNT < std_logic_vector(unsigned(BORDER_BOTTOM) - 1) then
			DPO_ZL <= '1';
		elsif LAST = '1' then
			DPO_ZL <= '0';
		end if;
        
		if VHCNT = BORDER_LEFT then
			DPO_ON <= '1'; -- BESSER EINZELN WEGEN TIMING
		else
			DPO_ON <= '0';
		end if;

		if VHCNT = std_logic_vector(unsigned(BORDER_RIGHT) - 1) then
			DPO_OFF <= '1';
		else
			DPO_OFF <= '0';
		end if;

		DISP_ON <= (DISP_ON and not DPO_OFF) or (DPO_ON and DPO_ZL);

		-- Data transfer on/off:
		if VHCNT = std_logic_vector(unsigned(HDIS_START) - 1) then
			VDO_ON <= '1'; -- BESSER EINZELN WEGEN TIMING.
		else
			VDO_ON <= '0';
		end if;

		if VHCNT = HDIS_END then
			VDO_OFF <= '1';
		else
			VDO_OFF <= '0';
		end if;

		if LAST = '1' and VVCNT >= std_logic_vector(unsigned(VDIS_START) - 1) and VVCNT < VDIS_END then
			VDO_ZL <= '1'; -- Take over at the end of the line.
		elsif LAST = '1' then
			VDO_ZL <= '0'; -- 1 ZEILE DAVOR ON OFF
		end if;

		VDTRON <= (VDTRON and not VDO_OFF) or (VDO_ON and VDO_ZL);

		-- Delay and SYNC
		if VHCNT = std_logic_vector(unsigned(HS_START) - 11) then
			HSYNC_START <= '1';
		else
			HSYNC_START <= '0';
		end if;
        
		if HSYNC_START = '1' then
			HSYNC_I <= std_logic_vector(unsigned(HSY_LEN));
		elsif HSYNC_I > x"00" then
			HSYNC_I <= std_logic_vector(unsigned(HSYNC_I) - 1);
		end if;

		if LAST = '1' and VVCNT = std_logic_vector(unsigned(VS_START) - 11) then
			VSYNC_START <= '1'; -- start am ende der Zeile vor dem vsync
		else
			VSYNC_START <= '0';
		end if;
        
		if LAST = '1' and VSYNC_START = '1' then -- Start at the end of the line before VSYNC.
			VSYNC_I <= "011"; -- 3 lines vsync length.
		elsif LAST = '1' and VSYNC_I > "000" then
			VSYNC_I <= std_logic_vector(unsigned(VSYNC_I) - 1); -- Count down.
		end if;

		if FBEE_VCTR(15) = '1' and VDL_VCT(5) = '1' and VSYNC_I = "000" then
			VERZ_2 <= VERZ_2(8 downto 0) & '1';
		elsif (FBEE_VCTR(15) = '0' or VDL_VCT(5) = '0') and VSYNC_I /= "000" then
			VERZ_2 <= VERZ_2(8 downto 0) & '1';
		else
			VERZ_2 <= VERZ_2(8 downto 0) & '0';
		end if;
        
		if HSYNC_I > x"00" then
			VERZ_1 <= VERZ_1(8 downto 0) & '1';
		else
			VERZ_1 <= VERZ_1(8 downto 0) & '0';
		end if;

		VERZ_0 <= VERZ_0(8 downto 0) & DISP_ON;

		BLANKn <=  VERZ_0(8);
		HSYNC  <=  VERZ_1(9);
		VSYNC  <=  VERZ_2(9);
		SYNCn <= not(VERZ_2(9) or VERZ_1(9));

		-- border colours:
		BORDER <= BORDER(5 downto 0) & (DISP_ON and not VDTRON and FBEE_VCTR(25));
		BORDER_ON <= BORDER(6);

		if LAST = '1' and VVCNT = std_logic_vector(unsigned(V_TOTAL) - 10) then
			FIFO_CLR <= '1';
		elsif LAST = '1' then
			FIFO_CLR <= '0';
		end if;

		if LAST = '1' and VVCNT = "00000000000" then
			START_ZEILE <= '1';
		elsif LAST = '1' then
			START_ZEILE <= '0';
		end if;

		if VHCNT = x"003" and START_ZEILE = '1' then
			SYNC_PIX <= '1';
		else
			SYNC_PIX <= '0';
		end if;

		if VHCNT = x"005" and START_ZEILE = '1' then
			SYNC_PIX1 <= '1';
		else
			SYNC_PIX1 <= '0';
		end if;

		if VHCNT = x"007" and START_ZEILE = '1' then
			SYNC_PIX2 <= '1';
		else
			SYNC_PIX2 <= '0';
		end if;
        
		if VDTRON = '1' and SYNC_PIX = '0' then
			SUB_PIXEL_CNT <= std_logic_vector(unsigned(SUB_PIXEL_CNT) + 1);
		elsif VDTRON = '1' then
			SUB_PIXEL_CNT <= (others => '0');
		end if;
        
		if VDTRON = '1' and SUB_PIXEL_CNT(6 downto 0) = "0000001" and COLOR1_I = '1' then
			FIFO_RDE <= '1';
		elsif VDTRON = '1' and SUB_PIXEL_CNT(5 downto 0) = "000001" and COLOR2_I = '1' then
			FIFO_RDE <= '1';
		elsif VDTRON = '1' and SUB_PIXEL_CNT(4 downto 0) = "00001" and COLOR4_I = '1' then
			FIFO_RDE <= '1';
		elsif VDTRON = '1' and SUB_PIXEL_CNT(3 downto 0) = "0001" and COLOR8_I = '1' then
			FIFO_RDE <= '1';
		elsif VDTRON = '1' and SUB_PIXEL_CNT(2 downto 0) = "001" and COLOR16_I = '1' then
			FIFO_RDE <= '1';
		elsif VDTRON = '1' and SUB_PIXEL_CNT(1 downto 0) = "01" and COLOR24_I = '1' then
			FIFO_RDE <= '1';
		elsif SYNC_PIX = '1' or SYNC_PIX1 = '1' or SYNC_PIX2 = '1' then
			FIFO_RDE <= '1'; -- 3 CLOCK ZUSï¿½TZLICH Fï¿½R FIFO SHIFT DATAOUT UND SHIFT RIGTH POSITION
		else
			FIFO_RDE <= '0';
		end if;

		CLUT_MUX_AV_0 <= SUB_PIXEL_CNT(3 downto 0);
		CLUT_MUX_AV_1 <= CLUT_MUX_AV_0;
		CLUT_MUX_ADR <= CLUT_MUX_AV_1;
	end process VIDEO_CLOCK_DOMAIN;
end architecture BEHAVIOUR;
