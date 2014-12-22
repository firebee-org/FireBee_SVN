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
---- Fredi Ashwanden  AND Wolfgang Förster. This release is IN    ----
---- comparision to the first edition completely written IN VHDL. ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi Aschwanden, Wolfgang Förster        ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- AND/or modify it under the terms of the GNU General Public   ----
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
---- License along with this program; IF NOT, write to the Free   ----
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
    USE ieee.numeric_std.ALL;

ENTITY VIDEO_CTRL IS
	PORT(
		clk_main        : IN STD_LOGIC;
		fb_cs_n         : IN UNSIGNED (2 DOWNTO 1);
		fb_wr_n         : IN STD_LOGIC;
		fb_oe_n         : IN STD_LOGIC;
		fb_size         : IN UNSIGNED (1 DOWNTO 0);
		fb_adr          : IN UNSIGNED (31 DOWNTO 0);
		clk33m          : IN STD_LOGIC;
		clk25m          : IN STD_LOGIC;
		blitter_run     : IN STD_LOGIC;
		clk_video       : IN STD_LOGIC;
		vr_d            : IN UNSIGNED (8 DOWNTO 0);
		vr_busy         : IN STD_LOGIC;
		color8          : OUT STD_LOGIC;
		fbee_clut_rd    : OUT STD_LOGIC;
		COLOR1          : OUT STD_LOGIC;
		falcon_clut_rdh : OUT STD_LOGIC;
		falcon_clut_rdl : OUT STD_LOGIC;
		falcon_clut_wr  : OUT UNSIGNED (3 DOWNTO 0);
		clut_st_rd      : OUT STD_LOGIC;
		clut_st_wr      : OUT UNSIGNED (1 DOWNTO 0);
		clut_mux_adr    : OUT UNSIGNED (3 DOWNTO 0);
		hsync           : OUT STD_LOGIC;
		vsync           : OUT STD_LOGIC;
		blank_n         : OUT STD_LOGIC;
		sync_n          : OUT STD_LOGIC;
		pd_vga_n        : OUT STD_LOGIC;
		fifo_rde        : OUT STD_LOGIC;
		color2          : OUT STD_LOGIC;
		color4          : OUT STD_LOGIC;
		clk_pixel       : OUT STD_LOGIC;
		clut_off        : OUT UNSIGNED (3 DOWNTO 0);
		blitter_on      : OUT STD_LOGIC;
		video_ram_ctr   : OUT UNSIGNED (15 DOWNTO 0);
		video_mod_ta    : OUT STD_LOGIC;
		ccr             : OUT UNSIGNED (23 DOWNTO 0);
		ccsel           : OUT UNSIGNED (2 DOWNTO 0);
		fbee_clut_wr    : OUT UNSIGNED (3 DOWNTO 0);
		inter_zei       : OUT STD_LOGIC;
		dop_fifo_clr    : OUT STD_LOGIC;
		video_reconfig  : OUT STD_LOGIC;
		vr_wr           : OUT STD_LOGIC;
		vr_rd           : OUT STD_LOGIC;
		fifo_clr        : OUT STD_LOGIC;
		data_in         : IN UNSIGNED (31 DOWNTO 0);
		data_out        : OUT UNSIGNED (31 DOWNTO 0);
		data_en_h       : OUT STD_LOGIC;
		data_en_l       : OUT STD_LOGIC
	);
END ENTITY VIDEO_CTRL;

ARCHITECTURE BEHAVIOUR OF VIDEO_CTRL IS
	SIGNAL clk17m                   : STD_LOGIC; 
	SIGNAL clk13m                   : STD_LOGIC;
	SIGNAL fbee_clut_cs             : STD_LOGIC;
	SIGNAL fbee_clut                : STD_LOGIC;
	SIGNAL video_pll_config_cs      : STD_LOGIC;
	SIGNAL vr_wr_i                  : STD_LOGIC;
	SIGNAL vr_dout                  : UNSIGNED (8 DOWNTO 0);
	SIGNAL vr_frq                   : UNSIGNED (7 DOWNTO 0);
	SIGNAL video_pll_reconfig_cs    : STD_LOGIC;
	SIGNAL video_reconfig_i         : STD_LOGIC;
	SIGNAL falcon_clut_cs           : STD_LOGIC;
	SIGNAL falcon_clut              : STD_LOGIC;
	SIGNAL st_clut_cs               : STD_LOGIC;
	SIGNAL st_clut                  : STD_LOGIC;
	SIGNAL fb_b                     : UNSIGNED (3 DOWNTO 0);
	SIGNAL fb_16b                   : UNSIGNED (1 DOWNTO 0);
	SIGNAL st_shift_mode            : UNSIGNED (1 DOWNTO 0);
	SIGNAL st_shift_mode_cs         : STD_LOGIC;
	SIGNAL falcon_shift_mode        : UNSIGNED (10 DOWNTO 0);
	SIGNAL falcon_shift_mode_cs     : STD_LOGIC;
	SIGNAL clut_mux_av_1            : UNSIGNED (3 DOWNTO 0);
	SIGNAL clut_mux_av_0            : UNSIGNED (3 DOWNTO 0);
	SIGNAL fbee_vctr_cs             : STD_LOGIC;
	SIGNAL fbee_vctr                : UNSIGNED (31 DOWNTO 0);
	SIGNAL ccr_cs                   : STD_LOGIC;
	SIGNAL ccr_i                    : UNSIGNED (23 DOWNTO 0);
	SIGNAL fbee_video_on            : STD_LOGIC;
	SIGNAL sys_ctr                  : UNSIGNED (6 DOWNTO 0);
	SIGNAL sys_ctr_cs               : STD_LOGIC;
	SIGNAL vdl_lof                  : UNSIGNED (15 DOWNTO 0);
	SIGNAL vdl_lof_cs               : STD_LOGIC;
	SIGNAL VDL_LWD                  : UNSIGNED (15 DOWNTO 0);
	SIGNAL VDL_LWD_CS               : STD_LOGIC;

	-- Miscellaneous control registers:
	SIGNAL clut_ta                  : STD_LOGIC; -- Requires one wait state.
	SIGNAL hsync_i                  : UNSIGNED (7 DOWNTO 0);
	SIGNAL hsync_len                : UNSIGNED (7 DOWNTO 0);    -- Length of a hsync pulse IN clk_pixel cycles.
	SIGNAL hsync_start              : STD_LOGIC;
	SIGNAL last                     : STD_LOGIC;                -- Last pixel of a line indicator.
	SIGNAL vsync_start              : STD_LOGIC;
	SIGNAL vsync_i                  : UNSIGNED (2 DOWNTO 0);
	SIGNAL blank_i_n                : STD_LOGIC;
	SIGNAL disp_on                  : STD_LOGIC;
	SIGNAL dpo_zl                   : STD_LOGIC;
	SIGNAL dpo_on                   : STD_LOGIC;
	SIGNAL dpo_off                  : STD_LOGIC;
	SIGNAL vdtron                   : STD_LOGIC;
	SIGNAL vdo_zl                   : STD_LOGIC;
	SIGNAL vdo_on                   : STD_LOGIC;
	SIGNAL vdo_off                  : STD_LOGIC;
	SIGNAL vhcnt                    : UNSIGNED (11 DOWNTO 0);
	SIGNAL sub_pixel_cnt            : UNSIGNED (6 DOWNTO 0);
	SIGNAL vvcnt                    : UNSIGNED (10 DOWNTO 0);
	SIGNAL verz_2                   : UNSIGNED (9 DOWNTO 0);
	SIGNAL verz_1                   : UNSIGNED (9 DOWNTO 0);
	SIGNAL verz_0                   : UNSIGNED (9 DOWNTO 0);
	SIGNAL border                   : UNSIGNED (6 DOWNTO 0);
	SIGNAL border_on                : STD_LOGIC;
	SIGNAL start_zeile              : STD_LOGIC;
	SIGNAL sync_pix                 : STD_LOGIC;
	SIGNAL sync_pix1                : STD_LOGIC;
	SIGNAL sync_pix2                : STD_LOGIC;

	-- Legacy ATARI resolutions:
	SIGNAL atari_sync               : STD_LOGIC;   
	SIGNAL atari_hh                 : UNSIGNED (31 DOWNTO 0); -- Horizontal timing 640x480.
	SIGNAL atari_hh_cs              : STD_LOGIC;
	SIGNAL atari_vh                 : UNSIGNED (31 DOWNTO 0); -- Vertical timing 640x480.
	SIGNAL atari_vh_cs              : STD_LOGIC;
	SIGNAL atari_hl                 : UNSIGNED (31 DOWNTO 0); -- Horizontal timing 320x240.
	SIGNAL atari_hl_cs              : STD_LOGIC;
	SIGNAL atari_vl                 : UNSIGNED (31 DOWNTO 0); -- Vertical timing 320x240.
	SIGNAL atari_vl_cs              : STD_LOGIC;

	-- Horizontal stuff:
	SIGNAL border_left              : UNSIGNED (11 DOWNTO 0);
	SIGNAL hdis_start               : UNSIGNED (11 DOWNTO 0);
	SIGNAL hdis_end                 : UNSIGNED (11 DOWNTO 0);
	SIGNAL border_right             : UNSIGNED (11 DOWNTO 0);
	SIGNAL hs_start                 : UNSIGNED (11 DOWNTO 0);
	SIGNAL h_total                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL hdis_len                 : UNSIGNED (11 DOWNTO 0);
	SIGNAL mulf                     : UNSIGNED (5 DOWNTO 0);
	SIGNAL vdl_hht                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hht_cs               : STD_LOGIC;
	SIGNAL vdl_hbe                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hbe_cs               : STD_LOGIC;
	SIGNAL vdl_hdb                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hdb_cs               : STD_LOGIC;
	SIGNAL VDL_HDE                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hde_cs               : STD_LOGIC;
	SIGNAL vdl_hbb                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hbb_cs               : STD_LOGIC;
	SIGNAL vdl_hss                  : UNSIGNED (11 DOWNTO 0);
	SIGNAL vdl_hss_cs               : STD_LOGIC;
	
	-- Vertical stuff:
	SIGNAL border_top               : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdis_start               : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdis_end                 : UNSIGNED (10 DOWNTO 0);
	SIGNAL border_bottom            : UNSIGNED (10 DOWNTO 0);
	SIGNAL vs_start                 : UNSIGNED (10 DOWNTO 0);
	SIGNAL v_total                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL falcon_video             : STD_LOGIC;
	SIGNAL st_video                 : STD_LOGIC;
	SIGNAL inter_zei_i              : STD_LOGIC;
	SIGNAL dop_zei                  : STD_LOGIC;
    
	SIGNAL vdl_vbe                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdl_vbe_cs               : STD_LOGIC;
	SIGNAL vdl_vdb                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL VDL_VDB_CS               : STD_LOGIC;
	SIGNAL vdl_vde                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdl_vde_cs               : STD_LOGIC;
	SIGNAL vdl_vbb                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdl_vbb_cs               : STD_LOGIC;
	SIGNAL vdl_vss                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdl_vss_cs               : STD_LOGIC;
	SIGNAL vdl_vft                  : UNSIGNED (10 DOWNTO 0);
	SIGNAL vdl_vft_cs               : STD_LOGIC;
	SIGNAL vdl_vct                  : UNSIGNED (8 DOWNTO 0);
	SIGNAL vdl_vct_cs               : STD_LOGIC;
	SIGNAL vdl_vmd                  : UNSIGNED (3 DOWNTO 0);
	SIGNAL vdl_vmd_cs               : STD_LOGIC;
	SIGNAL color1_i                 : STD_LOGIC;
	SIGNAL color2_i                 : STD_LOGIC;
	SIGNAL color4_i                 : STD_LOGIC;
	SIGNAL color8_i                 : STD_LOGIC;
	SIGNAL color16_i                : STD_LOGIC;
	SIGNAL color24_i                : STD_LOGIC;
	SIGNAL video_mod_ta_i           : STD_LOGIC;
	SIGNAL vr_rd_i                  : STD_LOGIC;
	SIGNAL clk_pixel_i              : STD_LOGIC;
	SIGNAL mul1                     : UNSIGNED (16 DOWNTO 0);
	SIGNAL mul2                     : UNSIGNED (16 DOWNTO 0);
	SIGNAL mul3                     : UNSIGNED (16 DOWNTO 0);
BEGIN
	vr_wr <= vr_wr_i;
	video_reconfig <= video_reconfig_i;
	ccr <= ccr_i;
	inter_zei <= inter_zei_i;
	video_mod_ta <= video_mod_ta_i;
	vr_rd <= vr_rd_i;
	clk_pixel <= clk_pixel_i;
	
	-- Byte selectors:
	fb_b(0) <= '1' WHEN fb_adr(1 DOWNTO 0) = "00" ELSE '0'; -- Byte 0.

	fb_b(1) <= '1' WHEN fb_size(1) = '1' AND fb_size(0) = '1' ELSE -- Long word.
					'1' WHEN fb_size(1) = '0' AND fb_size(0) = '0' ELSE -- Long.
					'1' WHEN fb_size(1) = '1' AND fb_size(0) = '0' AND fb_adr(1) = '0' ELSE -- High word.
					'1' WHEN fb_adr(1 DOWNTO 0) = "01" ELSE '0'; -- Byte 1.
             
	fb_b(2) <= '1' WHEN fb_size(1) = '1' AND fb_size(0) = '1' ELSE -- Long word.
					'1' WHEN fb_size(1) = '0' AND fb_size(0) = '0' ELSE -- Long.
					'1' WHEN fb_adr(1 DOWNTO 0) = "10" ELSE '0'; -- Byte 2.
             
	fb_b(3) <= '1' WHEN fb_size(1) = '1' AND fb_size(0) = '1' ELSE -- Long word.
					'1' WHEN fb_size(1) = '0' AND fb_size(0) = '0' ELSE -- Long.
					'1' WHEN fb_size(1) = '1' AND fb_size(0) = '0' AND fb_adr(1) = '1' ELSE -- Low word.
					'1' WHEN fb_adr(1 DOWNTO 0) = "11" ELSE '0'; -- Byte 3.
             
	-- 16 bit selectors:
	fb_16b(0) <= NOT fb_adr(0);
	fb_16b(1) <= '1'WHEN fb_adr(0) = '1' ELSE
					'1' WHEN fb_size(1) = '0' AND fb_size(0) = '0' ELSE -- No byte.
					'1' WHEN fb_size(1) = '1' AND fb_size(0) = '0' ELSE -- No byte.
					'1' WHEN fb_size(1) = '1' AND fb_size(0) = '1' ELSE '0'; -- No byte.

	-- Firebee CLUT:
	fbee_clut_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 10) = "000000000000000000" ELSE '0'; -- 0-3FF/1024
	fbee_clut_rd <= '1' WHEN fbee_clut_cs = '1' AND fb_oe_n = '0' ELSE '0';
	fbee_clut_wr <= fb_b WHEN fbee_clut_cs = '1' AND fb_wr_n = '0' ELSE x"0";

	P_CLUT_TA : PROCESS
	BEGIN
		WAIT UNTIL clk_main = '1' AND clk_main' EVENT;
		IF video_mod_ta_i = '0' AND fbee_clut_cs = '1' THEN
			clut_ta <= '1';
		ELSIF video_mod_ta_i = '0' AND falcon_clut_cs = '1' THEN
			clut_ta <= '1';
		ELSIF video_mod_ta_i = '0' AND st_clut_cs = '1' THEN
			clut_ta <= '1';
		ELSE
			clut_ta <= '0';
		END IF;
	END PROCESS P_CLUT_TA;

	--Falcon CLUT:
	falcon_clut_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 10) = "1111100110" ELSE '0'; -- $F9800/$400
	falcon_clut_rdh <= '1' WHEN falcon_clut_cs = '1' AND fb_oe_n = '0' AND fb_adr(1) = '0' ELSE '0'; -- High word.
	falcon_clut_rdl <= '1' WHEN falcon_clut_cs = '1' AND fb_oe_n = '0' AND fb_adr(1) = '1' ELSE '0'; -- Low word.
	falcon_clut_wr(1 DOWNTO 0) <= fb_16b WHEN fb_adr(1) = '0' AND falcon_clut_cs = '1' AND fb_wr_n = '0' ELSE "00";
	falcon_clut_wr(3 DOWNTO 2) <= fb_16b WHEN fb_adr(1) = '1' AND falcon_clut_cs = '1' AND fb_wr_n = '0' ELSE "00";
	
	-- ST CLUT:
	st_clut_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 5) = "111110000010010" ELSE '0'; -- $F8240/$2
	clut_st_rd <= '1' WHEN st_clut_cs = '1' AND fb_oe_n = '0' ELSE '0';
	clut_st_wr <= fb_16b WHEN st_clut_cs = '1' AND fb_wr_n = '0' ELSE "00";

	st_shift_mode_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 1) = "1111100000100110000" ELSE '0'; -- $F8260/$2.
	falcon_shift_mode_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 1) = "1111100000100110011" ELSE '0'; -- $F8266/$2.
	fbee_vctr_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000000000100000000" ELSE '0'; -- $400/$4
	atari_hh_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000000000100000100" ELSE '0'; -- $410/4
	atari_vh_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000000000100000101" ELSE '0'; -- $414/4
	atari_hl_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000000000100000110" ELSE '0'; -- $418/4
	atari_vl_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000000000100000111" ELSE '0'; -- $41C/4

	P_VIDEO_CONTROL : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_main);
		IF st_shift_mode_cs = '1' AND fb_wr_n = '0' AND fb_b(0) = '1' THEN
			st_shift_mode <= data_in(25 DOWNTO 24);
		END IF;

		IF falcon_shift_mode_cs = '1' AND fb_wr_n = '0' AND fb_b(2) = '1' THEN
			falcon_shift_mode(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF falcon_shift_mode_cs = '1' AND fb_wr_n = '0' AND fb_b(3) = '1' THEN
			falcon_shift_mode(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- Firebee VIDEO CONTROL:
		-- Bit 0 = FBEE VIDEO ON, 1 = POWER ON VIDEO DAC, 2 = FBEE 24BIT,
		-- Bit 3 = FBEE 16BIT, 4 = FBEE 8BIT, 5 = FBEE 1BIT, 
		-- Bit 6 = FALCON SHIFT MODE, 7 = ST SHIFT MODE, 9..8 = VCLK frequency,
		-- Bit 15 = SYNC ALLOWED, 31..16 = video_ram_ctr,
		-- Bit 25 = RANDFARBE EINSCHALTEN, 26 = STANDARD ATARI SYNCS.
		IF fbee_vctr_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
		ELSIF fbee_vctr_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF fbee_vctr_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF fbee_vctr_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(5 DOWNTO 0) <= data_in(5 DOWNTO 0);
		END IF;
        
		-- ST or Falcon shift mode: assert WHEN X..shift register:
		IF falcon_shift_mode_cs = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(7) <= falcon_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
			fbee_vctr(6) <= st_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
		END IF;
		IF st_shift_mode_cs = '1' AND fb_wr_n = '0' THEN
			fbee_vctr(7) <= falcon_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
			fbee_vctr(6) <= st_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
		END IF;
		IF fbee_vctr_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' AND data_in(0) = '1' THEN
			fbee_vctr(7) <= falcon_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
			fbee_vctr(6) <= st_shift_mode_cs AND NOT fb_wr_n AND NOT fbee_video_on;
		END IF;
    
		-- ATARI ST mode
		-- Horizontal timing 640x480:
		IF atari_hh_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			atari_hh(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
		ELSIF atari_hh_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			atari_hh(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF atari_hh_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			atari_hh(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF atari_hh_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			atari_hh(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
		END IF;

		-- Vertical timing 640x480:
		IF atari_vh_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			atari_vh(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
		ELSIF atari_vh_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			atari_vh(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF atari_vh_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			atari_vh(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF atari_vh_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			atari_vh(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
		END IF;

		-- Horizontal timing 320x240:
		IF atari_hl_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			atari_hl(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
		ELSIF atari_hl_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			atari_hl(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF atari_hl_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			atari_hl(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF atari_hl_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			atari_hl(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
		END IF;

		-- Vertical timing 320x240:
		IF atari_vl_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			atari_vl(31 DOWNTO 24) <= data_in(31 DOWNTO 24);
		ELSIF atari_vl_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			atari_vl(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF atari_vl_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			atari_vl(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF atari_vl_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			atari_vl(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
		END IF;
	END PROCESS P_VIDEO_CONTROL;
    
	clut_off <= falcon_shift_mode(3 DOWNTO 0) WHEN color4_i = '1' ELSE x"0";
	pd_vga_n <= fbee_vctr(1);
	fbee_video_on <= fbee_vctr(0);
	atari_sync <= fbee_vctr(26); -- If 1 -> automatic resolution.

	color1_i <= '1' WHEN st_video = '1' AND fbee_video_on = '0' AND st_shift_mode = "10" AND color8_i = '0' ELSE -- ST mono.
					'1' WHEN falcon_video = '1' AND fbee_video_on = '0' AND falcon_shift_mode(10) = '1' AND color16_i = '0' AND color8_i = '0' ELSE -- Falcon mono.
					'1' WHEN fbee_video_on = '1' AND fbee_vctr(5 DOWNTO 2) = "1000" ELSE '0'; -- Firebee mode.
	color2_i <= '1' WHEN st_video = '1' AND fbee_video_on = '0' AND st_shift_mode = "01" AND color8_i = '0' ELSE '0'; -- ST 4 colours.
	color4_i <= '1' WHEN st_video = '1' AND fbee_video_on = '0' AND st_shift_mode = "00" AND color8_i = '0' ELSE -- ST 16 colours.
					'1' WHEN falcon_video = '1' AND fbee_video_on = '0' AND color16_i = '0' AND color8_i = '0' AND color1_i = '0' ELSE '0'; -- Falcon mode.
	color8_i <= '1' WHEN falcon_video = '1' AND fbee_video_on = '0' AND falcon_shift_mode(4) = '1' AND color16_i = '0' ELSE -- Falcon mode.
					'1' WHEN fbee_video_on = '1' AND fbee_vctr(4 DOWNTO 2) = "100" ELSE '0'; -- Firebee mode.
	color16_i <= '1' WHEN falcon_video = '1' AND fbee_video_on = '0' AND falcon_shift_mode(8) = '1' ELSE -- Falcon mode.
					'1' WHEN fbee_video_on = '1' AND fbee_vctr(3 DOWNTO 2) = "10" ELSE '0'; -- Firebee mode.
	color24_i <= '1' WHEN fbee_video_on = '1' AND fbee_vctr(2) = '1' ELSE '0'; -- Firebee mode.
    
	COLOR1 <= color1_i;
	color2 <= color2_i;
	color4 <= color4_i;
	color8 <= color8_i;
	
	-- VIDEO PLL config AND reconfig:
	video_pll_config_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_b(0) = '1' AND fb_b(1) = '1' AND fb_adr(27 DOWNTO 9) = "0000000000000000011" ELSE '0'; -- $(F)000'0600-7FF -> 6/2 word AND long only.
	video_pll_reconfig_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_b(0) = '1' AND fb_adr(27 DOWNTO 0) = x"0000800" ELSE '0'; -- $(F)000'0800. 
	vr_rd_i <= '1' WHEN video_pll_config_cs = '1' AND fb_wr_n = '0' AND vr_busy = '0' ELSE '0';

	P_VIDEO_CONFIG: PROCESS
		variable LOCK : boolean;
	BEGIN
		WAIT UNTIL rising_edge(clk_main);

		IF video_pll_config_cs = '1' AND fb_wr_n = '0' AND vr_busy = '0' AND vr_wr_i = '0' THEN
			vr_wr_i <= '1'; -- This is a strobe.
		ELSE
			vr_wr_i <= '0';
		END IF;

		IF vr_busy = '1' THEN
			vr_dout <= vr_d;
		END IF;
        
		IF vr_wr_i = '1' AND fb_adr(8 DOWNTO 0) = "000000100" THEN
			vr_frq <= data_in(23 DOWNTO 16);
		END IF;

		IF video_pll_reconfig_cs = '1' AND fb_wr_n = '0' AND vr_busy = '0' AND LOCK = false THEN
			video_reconfig_i <= '1'; -- This is a strobe.
			LOCK := true;
		ELSIF video_pll_reconfig_cs = '0' or fb_wr_n = '1' or vr_busy = '1' THEN
			video_reconfig_i <= '0';
			LOCK := false;
		ELSE
			video_reconfig_i <= '0';
		END IF;
	END PROCESS P_VIDEO_CONFIG;
    
	video_ram_ctr <= fbee_vctr(31 DOWNTO 16);
    
	-- Firebee colour modi: 
	fbee_clut <= '1' WHEN fbee_video_on = '1' AND (color1_i = '1' or color8_i = '1') ELSE
						'1' WHEN st_video = '1' AND color1_i = '1';
                 
	falcon_video <= fbee_vctr(7);
	falcon_clut <= '1' WHEN falcon_video = '1' AND fbee_video_on = '0' AND color16_i = '0' ELSE '0';
	st_video <= fbee_vctr(6);
	st_clut <= '1' WHEN st_video = '1' AND fbee_video_on = '0' AND falcon_clut = '0' AND color1_i = '0' ELSE '0';

    -- Several (video)-registers:
	ccr_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr = x"f0000404" ELSE '0';	-- $F0000404 - Firebee video border color
	sys_ctr_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8008" ELSE '0';	-- $FF8006 - Falcon monitor type register
	vdl_lof_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff820e" ELSE '0'; -- $FF820E/F - line-width hi/lo.
	VDL_LWD_CS <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8210" ELSE '0'; -- $FF8210/1 - vertical wrap hi/lo.
	vdl_hht_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8282" ELSE '0'; -- $FF8282/3 - horizontal hold timer hi/lo.
	vdl_hbe_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8286" ELSE '0'; -- $FF8286/7 - horizontal border END hi/lo.
	vdl_hdb_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8288" ELSE '0'; -- $FF8288/9 - horizontal display BEGIN hi/lo.
	vdl_hde_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff828a" ELSE '0'; -- $FF828A/B - horizontal display END hi/lo.
	vdl_hbb_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff8284" ELSE '0'; -- $FF8284/5 - horizontal border BEGIN hi/lo.
	vdl_hss_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff828c" ELSE '0'; -- $FF828C/D - position hsync (HSS).
	vdl_vft_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82a2" ELSE '0'; -- $FF82A2/3 - video frequency timer (VFT).
	vdl_vbb_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82a4" ELSE '0'; -- $FF82A4/5 - vertical blank on (IN half line steps).
	vdl_vbe_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82a6" ELSE '0'; -- $FF82A6/7 - vertical blank off (IN half line steps).
	VDL_VDB_CS <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82a8" ELSE '0'; -- $FF82A8/9 - vertical display BEGIN (VDB).
	vdl_vde_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82aa" ELSE '0'; -- $FF82AA/B - vertical display END (VDE).
	vdl_vss_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82ac" ELSE '0'; -- $FF82AC/D - position vsync (VSS).
	vdl_vct_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82c0" ELSE '0'; -- $FF82C0/1 - clock control (VCO).
	vdl_vmd_cs <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(23 DOWNTO 1) & '0' = x"ff82c2" ELSE '0'; -- $FF82C2/3 - resolution control.

	P_MISC_CTRL : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_main);
        
		-- Colour of video borders
		IF ccr_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			ccr_i(23 DOWNTO 16) <= data_in(23 DOWNTO 16);
		ELSIF ccr_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			ccr_i(15 DOWNTO 8) <= data_in(15 DOWNTO 8);
		ELSIF ccr_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			ccr_i(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
		END IF;

		-- SYS CTRL:
		IF sys_ctr_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			sys_ctr <= data_in(22 DOWNTO 16);
		END IF;

		--vdl_lof:
		IF vdl_lof_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_lof(15 DOWNTO 8) <= data_in(31 DOWNTO 24);
		ELSIF vdl_lof_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_lof(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		--VDL_LWD
		IF VDL_LWD_CS = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			VDL_LWD(15 DOWNTO 8) <= data_in(31 DOWNTO 24);
		ELSIF VDL_LWD_CS = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			VDL_LWD(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- Horizontal:
		-- vdl_hht:
		IF vdl_hht_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_hht(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hht_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_hht(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_hbe:
		IF vdl_hbe_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_hbe(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hbe_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_hbe(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_hdb:
		IF vdl_hdb_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_hdb(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hdb_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_hdb(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- VDL_HDE:
		IF vdl_hde_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			VDL_HDE(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hde_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			VDL_HDE(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_hbb:
		IF vdl_hbb_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_hbb(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hbb_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_hbb(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_hss:
		IF vdl_hss_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_hss(11 DOWNTO 8) <= data_in(27 DOWNTO 24);
		ELSIF vdl_hss_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_hss(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- Vertical:
		-- vdl_vbe:
		IF vdl_vbe_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_vbe(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF vdl_vbe_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_vbe(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vdb:
		IF VDL_VDB_CS = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_vdb(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF VDL_VDB_CS = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_vdb(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;
        
		-- vdl_vde:
		IF vdl_vde_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_vde(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF vdl_vde_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_vde(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vbb:
		IF vdl_vbb_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_vbb(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF vdl_vbb_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_vbb(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vss
		IF vdl_vss_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_vss(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF vdl_vss_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_vss(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vft
		IF vdl_vft_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			vdl_vft(10 DOWNTO 8) <= data_in(26 DOWNTO 24);
		ELSIF vdl_vft_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_vft(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vct(2): 1 = 32MHz clk_pixel, 0 = 25MHZ; vdl_vct(0): 1 = linedoubling.
		IF vdl_vct_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			vdl_vct(8) <= data_in(24);
		ELSIF vdl_vct_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			vdl_vct(7 DOWNTO 0) <= data_in(23 DOWNTO 16);
		END IF;

		-- vdl_vmd(2): 1 = clk_pixel/2.
		IF vdl_vmd_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			vdl_vmd <= data_in(19 DOWNTO 16);
		END IF;
	END PROCESS P_MISC_CTRL;

	blitter_on <= NOT sys_ctr(3);
    
	-- Register OUT:
	data_out(31 DOWNTO 16) <= "000000" & st_shift_mode & x"00" WHEN st_shift_mode_cs = '1' ELSE
										"00000" & falcon_shift_mode WHEN falcon_shift_mode_cs = '1' ELSE
										"100000000" & sys_ctr(6 DOWNTO 4) & NOT blitter_run & sys_ctr(2 DOWNTO 0) WHEN sys_ctr_cs = '1' ELSE
										vdl_lof WHEN vdl_lof_cs = '1' ELSE
										VDL_LWD WHEN VDL_LWD_CS = '1' ELSE
										x"0" & vdl_hbe WHEN vdl_hbe_cs = '1' ELSE
										x"0" & vdl_hdb WHEN vdl_hdb_cs = '1' ELSE
										x"0" & VDL_HDE WHEN vdl_hde_cs = '1' ELSE
										x"0" & vdl_hbb WHEN vdl_hbb_cs = '1' ELSE
										x"0" & vdl_hss WHEN vdl_hss_cs = '1' ELSE
										x"0" & vdl_hht WHEN vdl_hht_cs = '1' ELSE
										"00000" & vdl_vbe WHEN vdl_vbe_cs = '1' ELSE
										"00000" & vdl_vdb WHEN VDL_VDB_CS = '1' ELSE
										"00000" & vdl_vde WHEN vdl_vde_cs = '1' ELSE
										"00000" & vdl_vbb WHEN vdl_vbb_cs = '1' ELSE
										"00000" & vdl_vss WHEN vdl_vss_cs = '1' ELSE
										"00000" & vdl_vft WHEN vdl_vft_cs = '1' ELSE
										"0000000" & vdl_vct WHEN vdl_vct_cs = '1' ELSE    
										x"000" & vdl_vmd WHEN vdl_vmd_cs = '1' ELSE
										fbee_vctr(31 DOWNTO 16) WHEN fbee_vctr_cs = '1' ELSE
										atari_hh(31 DOWNTO 16) WHEN atari_hh_cs = '1' ELSE
										atari_vh(31 DOWNTO 16) WHEN atari_vh_cs = '1' ELSE
										atari_hl(31 DOWNTO 16) WHEN atari_hl_cs = '1' ELSE
										atari_vl(31 DOWNTO 16) WHEN atari_vl_cs = '1' ELSE
										x"00" & ccr_i(23 DOWNTO 16) WHEN ccr_cs = '1' ELSE 
										"0000000" & vr_dout WHEN video_pll_config_cs = '1' ELSE
										vr_busy & "0000" & vr_wr_i & vr_rd_i & video_reconfig_i & x"FA" WHEN video_pll_reconfig_cs = '1' ELSE (OTHERS => '0');
    
	data_out(15 DOWNTO 0) <= fbee_vctr(15 DOWNTO 0) WHEN fbee_vctr_cs = '1' ELSE
										atari_hh(15 DOWNTO 0) WHEN atari_hh_cs = '1' ELSE
										atari_vh(15 DOWNTO 0) WHEN atari_vh_cs = '1' ELSE
										atari_hl(15 DOWNTO 0) WHEN atari_hl_cs = '1' ELSE
										atari_vl(15 DOWNTO 0) WHEN atari_vl_cs = '1' ELSE
										ccr_i(15 DOWNTO 0) WHEN ccr_cs = '1' ELSE (OTHERS => '0');

	data_en_h <= (st_shift_mode_cs or falcon_shift_mode_cs or fbee_vctr_cs or ccr_cs or sys_ctr_cs or vdl_lof_cs or VDL_LWD_CS or
						vdl_hbe_cs or vdl_hdb_cs or vdl_hde_cs or vdl_hbb_cs or vdl_hss_cs or vdl_hht_cs or
						atari_hh_cs or atari_vh_cs or atari_hl_cs or atari_vl_cs or video_pll_config_cs or video_pll_reconfig_cs or
						vdl_vbe_cs or VDL_VDB_CS or vdl_vde_cs or vdl_vbb_cs or vdl_vss_cs or vdl_vft_cs or vdl_vct_cs or vdl_vmd_cs) AND NOT fb_oe_n;

	data_en_l <= (fbee_vctr_cs or ccr_cs or atari_hh_cs or atari_vh_cs or atari_hl_cs or atari_vl_cs ) AND NOT fb_oe_n;

	video_mod_ta_i <= clut_ta or st_shift_mode_cs or falcon_shift_mode_cs or fbee_vctr_cs or sys_ctr_cs or vdl_lof_cs or VDL_LWD_CS or
							vdl_hbe_cs or vdl_hdb_cs or vdl_hde_cs or vdl_hbb_cs or vdl_hss_cs or vdl_hht_cs or
							atari_hh_cs or atari_vh_cs or atari_hl_cs or atari_vl_cs or
							vdl_vbe_cs or VDL_VDB_CS or vdl_vde_cs or vdl_vbb_cs or vdl_vss_cs or vdl_vft_cs or vdl_vct_cs or vdl_vmd_cs;
    
	P_CLK_16M5 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk33m);
		clk17m <= NOT clk17m;
	END PROCESS P_CLK_16M5;

	P_CLK_12M5 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk25m);
		clk13m <= NOT clk13m;
	END PROCESS P_CLK_12M5;

	clk_pixel_i <= clk13m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(2) = '1' ELSE
						clk13m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(0) = '1' ELSE
						clk17m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(2) = '0' ELSE
						clk17m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(0) = '0' ELSE
						clk25m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND  vdl_vmd(2) = '0' AND vdl_vct(2) = '1' AND vdl_vct(0) = '0' ELSE
						clk33m WHEN fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND  vdl_vmd(2) = '0' AND vdl_vct(2) = '0' AND vdl_vct(0) = '0' ELSE
						clk25m WHEN fbee_video_on = '1' AND fbee_vctr(9 DOWNTO 8) = "00" ELSE
						clk33m WHEN fbee_video_on = '1' AND fbee_vctr(9 DOWNTO 8) = "01" ELSE
						clk_video WHEN fbee_video_on = '1' AND fbee_vctr(9) = '1' ELSE '0';

	p_hsyn_len  : PROCESS
		-- Horizontal SYNC IN clk_pixel:
	BEGIN
		WAIT UNTIL rising_edge(clk_main);
		IF fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(2) = '1' THEN
			hsync_len <= 8D"14";
		ELSIF fbee_video_on = '0' AND (falcon_video = '1' or st_video = '1') AND vdl_vmd(2) = '1' AND vdl_vct(0) = '1' THEN
			hsync_len <= 8D"14";
		ELSIF fbee_video_on = '0' AND (falcon_video or st_video) = '1' AND vdl_vmd(2) = '1' AND vdl_vct(2) = '0' THEN
			hsync_len <= 8D"16";
		ELSIF fbee_video_on = '0' AND (falcon_video or st_video) = '1' AND vdl_vmd(2) = '1' AND vdl_vct(0) = '0' THEN
			hsync_len <= 8D"16";
		ELSIF fbee_video_on = '0' AND (falcon_video or st_video) = '1' AND  vdl_vmd(2) = '0' AND vdl_vct(2) = '1' AND vdl_vct(0) = '0' THEN
			hsync_len <= 8D"28";
		ELSIF fbee_video_on = '0' AND (falcon_video or st_video) = '1' AND  vdl_vmd(2) = '0' AND vdl_vct(2) = '0' AND vdl_vct(0) = '0' THEN
			hsync_len <= 8D"32";
		ELSIF fbee_video_on = '1' AND fbee_vctr(9 DOWNTO 8) = "00" THEN
			hsync_len <= 8D"28";
		ELSIF fbee_video_on = '1' AND fbee_vctr(9 DOWNTO 8) = "01" THEN
			hsync_len <= 8D"32";
		ELSIF fbee_video_on = '1' AND fbee_vctr(9) = '1' THEN
			hsync_len <= 8D"16" + vr_frq / 2; -- hsync pulse length IN pixels = frequency/500ns.
		ELSE
			hsync_len <= x"00";
		END IF;
	END PROCESS p_hsyn_len;

	mulf <= "000010" WHEN st_video = '0' AND vdl_vmd(2) = '1' ELSE -- Multiplier.
				"000100" WHEN st_video = '0' AND vdl_vmd(2) = '0' ELSE
				"010000" WHEN st_video = '1' AND vdl_vmd(2) = '1' ELSE
				"100000" WHEN st_video = '1' AND vdl_vmd(2) = '0' ELSE "000000";

	hdis_len <= x"140" WHEN vdl_vmd(2) = '1' ELSE x"280"; -- Width IN pixels (320 / 640).

	p_double_line_1   : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_main);
		dop_zei <= vdl_vmd(0) AND st_video; -- Line doubling on off.
	END PROCESS p_double_line_1;

	p_double_line_2   : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_pixel_i);
		IF dop_zei = '1' AND vvcnt(0) /= vdis_start(0) AND vvcnt /= "00000000000" AND vhcnt < hdis_end - 1 THEN        
			inter_zei_i <= '1'; -- Switch insertion line to "double". Line zero due to SYNC.
		ELSIF dop_zei = '1' AND vvcnt(0) = vdis_start(0) AND vvcnt /= "00000000000" AND vhcnt > hdis_end - 10 THEN
			inter_zei_i <= '1'; -- Switch insertion mode to "normal". Lines AND line zero due to SYNC.
		ELSE
			inter_zei_i <= '0';
		END IF;
		--
		dop_fifo_clr <= inter_zei_i AND hsync_start AND sync_pix; -- Double line info erase at the END of a double line AND at main FIFO start.
	END PROCESS p_double_line_2;

    -- The following multiplications change every time the video resolution is changed.
	mul1 <= vdl_hbe * mulf(5 DOWNTO 1);
	mul2 <= vdl_hht + 1 + vdl_hss * mulf(5 DOWNTO 1);
	mul3 <= RESIZE(vdl_hht + 10 * mulf(5 DOWNTO 1), mul3'LENGTH);

	border_left <= vdl_hbe WHEN fbee_video_on = '1' ELSE 
						x"015" WHEN atari_sync = '1' AND vdl_vmd(2) = '1' ELSE
						x"02A" WHEN atari_sync = '1' ELSE mul1(16 DOWNTO 5);
	hdis_start <= vdl_hdb WHEN fbee_video_on = '1' ELSE border_left + 1;
	hdis_end <= VDL_HDE WHEN fbee_video_on = '1' ELSE UNSIGNED (UNSIGNED(border_left) + UNSIGNED(hdis_len));
	border_right <= vdl_hbb WHEN fbee_video_on = '1' ELSE UNSIGNED (UNSIGNED(hdis_end) + 1);
	hs_start <= vdl_hss WHEN fbee_video_on = '1' ELSE
					atari_hl(11 DOWNTO 0) WHEN atari_sync = '1' AND vdl_vmd(2) = '1' ELSE
					atari_hh(11 DOWNTO 0) WHEN vdl_vmd(2) = '1' ELSE UNSIGNED (mul2(16 DOWNTO 5));
	h_total <= vdl_hht WHEN fbee_video_on = '1' ELSE
					atari_hl(27 DOWNTO 16) WHEN atari_sync = '1' AND vdl_vmd(2) = '1' ELSE
					atari_hh(27 DOWNTO 16) WHEN atari_sync = '1' ELSE UNSIGNED (mul3(16 DOWNTO 5));
	border_top <= vdl_vbe WHEN fbee_video_on = '1' ELSE
						"00000011111" WHEN atari_sync = '1' ELSE '0' & vdl_vbe(10 DOWNTO 1);
	vdis_start <= vdl_vdb WHEN fbee_video_on = '1' ELSE
						"00000100000" WHEN atari_sync = '1' ELSE '0' & vdl_vdb(10 DOWNTO 1);
	vdis_end <= vdl_vde WHEN fbee_video_on = '1' ELSE
					"00110101111" WHEN atari_sync = '1' AND st_video = '1' ELSE -- 431.
					"00111111111" WHEN atari_sync = '1' ELSE '0' & vdl_vde(10 DOWNTO 1); -- 511.
	border_bottom <= vdl_vbb WHEN fbee_video_on = '1' ELSE
						UNSIGNED (UNSIGNED(vdis_end) + 1) WHEN atari_sync = '1' ELSE ('0' & UNSIGNED (UNSIGNED(vdl_vbb(10 DOWNTO 1)) + 1));
	vs_start <= vdl_vss WHEN fbee_video_on = '1' ELSE
					atari_vl(10 DOWNTO 0) WHEN atari_sync = '1' AND vdl_vmd(2) = '1' ELSE
					atari_vh(10 DOWNTO 0) WHEN atari_sync = '1' ELSE '0' & vdl_vss(10 DOWNTO 1);
	v_total <= vdl_vft WHEN fbee_video_on = '1' ELSE
					atari_vl(26 DOWNTO 16) WHEN atari_sync = '1' AND vdl_vmd(2) = '1' ELSE
					atari_vh(26 DOWNTO 16) WHEN atari_sync = '1' ELSE '0' & vdl_vft(10 DOWNTO 1);

	last <= '1' WHEN vhcnt  = UNSIGNED (UNSIGNED(h_total) - 10) ELSE '0';

	VIDEO_CLOCK_DOMAIN   : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_pixel_i);
		IF st_clut = '1' THEN
			ccsel <= "000"; -- For information only.
		ELSIF falcon_clut = '1' THEN
			ccsel <= "001";
		ELSIF fbee_clut = '1' THEN
			ccsel <= "100";
		ELSIF color16_i = '1' THEN
			ccsel <= "101";
		ELSIF color24_i = '1' THEN
			ccsel <= "110";
		ELSIF border_on = '1' THEN
			ccsel <= "111";
		END IF;

		IF last = '0' THEN
			vhcnt <= UNSIGNED (UNSIGNED(vhcnt) + 1);
		ELSE
			vhcnt <= (OTHERS => '0');
		END IF;

		IF last = '1' AND vvcnt = UNSIGNED (UNSIGNED(v_total) - 1) THEN
			vvcnt <= (OTHERS => '0');
		ELSIF last = '1' THEN
			vvcnt <= UNSIGNED (UNSIGNED(vvcnt) + 1);
		END IF;

		-- Display on/off:
		IF last = '1' AND vvcnt > UNSIGNED (UNSIGNED(border_top) - 1) AND vvcnt < UNSIGNED (UNSIGNED(border_bottom) - 1) THEN
			dpo_zl <= '1';
		ELSIF last = '1' THEN
			dpo_zl <= '0';
		END IF;
        
		IF vhcnt = border_left THEN
			dpo_on <= '1'; -- BESSER EINZELN WEGEN TIMING
		ELSE
			dpo_on <= '0';
		END IF;

		IF vhcnt = UNSIGNED (UNSIGNED(border_right) - 1) THEN
			dpo_off <= '1';
		ELSE
			dpo_off <= '0';
		END IF;

		disp_on <= (disp_on AND NOT dpo_off) or (dpo_on AND dpo_zl);

		-- Data transfer on/off:
		IF vhcnt = UNSIGNED (UNSIGNED(hdis_start) - 1) THEN
			vdo_on <= '1'; -- BESSER EINZELN WEGEN TIMING.
		ELSE
			vdo_on <= '0';
		END IF;

		IF vhcnt = hdis_end THEN
			vdo_off <= '1';
		ELSE
			vdo_off <= '0';
		END IF;

		IF last = '1' AND vvcnt >= UNSIGNED (UNSIGNED(vdis_start) - 1) AND vvcnt < vdis_end THEN
			vdo_zl <= '1'; -- Take over at the END of the line.
		ELSIF last = '1' THEN
			vdo_zl <= '0'; -- 1 ZEILE DAVOR ON OFF
		END IF;

		vdtron <= (vdtron AND NOT vdo_off) or (vdo_on AND vdo_zl);

		-- Delay AND SYNC
		IF vhcnt = UNSIGNED (UNSIGNED(hs_start) - 11) THEN
			hsync_start <= '1';
		ELSE
			hsync_start <= '0';
		END IF;
        
		IF hsync_start = '1' THEN
			hsync_i <= UNSIGNED (UNSIGNED(hsync_len));
		ELSIF hsync_i > x"00" THEN
			hsync_i <= UNSIGNED (UNSIGNED(hsync_i) - 1);
		END IF;

		IF last = '1' AND vvcnt = UNSIGNED (UNSIGNED(vs_start) - 11) THEN
			vsync_start <= '1'; -- start am ende der Zeile vor dem vsync
		ELSE
			vsync_start <= '0';
		END IF;
        
		IF last = '1' AND vsync_start = '1' THEN -- Start at the END of the line before vsync.
			vsync_i <= "011"; -- 3 lines vsync length.
		ELSIF last = '1' AND vsync_i > "000" THEN
			vsync_i <= UNSIGNED (UNSIGNED(vsync_i) - 1); -- Count down.
		END IF;

		IF fbee_vctr(15) = '1' AND vdl_vct(5) = '1' AND vsync_i = "000" THEN
			verz_2 <= verz_2(8 DOWNTO 0) & '1';
		ELSIF (fbee_vctr(15) = '0' or vdl_vct(5) = '0') AND vsync_i /= "000" THEN
			verz_2 <= verz_2(8 DOWNTO 0) & '1';
		ELSE
			verz_2 <= verz_2(8 DOWNTO 0) & '0';
		END IF;
        
		IF hsync_i > x"00" THEN
			verz_1 <= verz_1(8 DOWNTO 0) & '1';
		ELSE
			verz_1 <= verz_1(8 DOWNTO 0) & '0';
		END IF;

		verz_0 <= verz_0(8 DOWNTO 0) & disp_on;

		blank_n <=  verz_0(8);
		hsync  <=  verz_1(9);
		vsync  <=  verz_2(9);
		sync_n <= NOT(verz_2(9) or verz_1(9));

		-- border colours:
		border <= border(5 DOWNTO 0) & (disp_on AND NOT vdtron AND fbee_vctr(25));
		border_on <= border(6);

		IF last = '1' AND vvcnt = UNSIGNED (UNSIGNED(v_total) - 10) THEN
			fifo_clr <= '1';
		ELSIF last = '1' THEN
			fifo_clr <= '0';
		END IF;

		IF last = '1' AND vvcnt = "00000000000" THEN
			start_zeile <= '1';
		ELSIF last = '1' THEN
			start_zeile <= '0';
		END IF;

		IF vhcnt = x"003" AND start_zeile = '1' THEN
			sync_pix <= '1';
		ELSE
			sync_pix <= '0';
		END IF;

		IF vhcnt = x"005" AND start_zeile = '1' THEN
			sync_pix1 <= '1';
		ELSE
			sync_pix1 <= '0';
		END IF;

		IF vhcnt = x"007" AND start_zeile = '1' THEN
			sync_pix2 <= '1';
		ELSE
			sync_pix2 <= '0';
		END IF;
        
		IF vdtron = '1' AND sync_pix = '0' THEN
			sub_pixel_cnt <= UNSIGNED (UNSIGNED(sub_pixel_cnt) + 1);
		ELSIF vdtron = '1' THEN
			sub_pixel_cnt <= (OTHERS => '0');
		END IF;
        
		IF vdtron = '1' AND sub_pixel_cnt(6 DOWNTO 0) = "0000001" AND color1_i = '1' THEN
			fifo_rde <= '1';
		ELSIF vdtron = '1' AND sub_pixel_cnt(5 DOWNTO 0) = "000001" AND color2_i = '1' THEN
			fifo_rde <= '1';
		ELSIF vdtron = '1' AND sub_pixel_cnt(4 DOWNTO 0) = "00001" AND color4_i = '1' THEN
			fifo_rde <= '1';
		ELSIF vdtron = '1' AND sub_pixel_cnt(3 DOWNTO 0) = "0001" AND color8_i = '1' THEN
			fifo_rde <= '1';
		ELSIF vdtron = '1' AND sub_pixel_cnt(2 DOWNTO 0) = "001" AND color16_i = '1' THEN
			fifo_rde <= '1';
		ELSIF vdtron = '1' AND sub_pixel_cnt(1 DOWNTO 0) = "01" AND color24_i = '1' THEN
			fifo_rde <= '1';
		ELSIF sync_pix = '1' or sync_pix1 = '1' or sync_pix2 = '1' THEN
			fifo_rde <= '1'; -- 3 CLOCK ZUSï¿½TZLICH Fï¿½R FIFO SHIFT DATAOUT UND SHIFT RIGTH POSITION
		ELSE
			fifo_rde <= '0';
		END IF;

		clut_mux_av_0 <= sub_pixel_cnt(3 DOWNTO 0);
		clut_mux_av_1 <= clut_mux_av_0;
		clut_mux_adr <= clut_mux_av_1;
	END PROCESS VIDEO_CLOCK_DOMAIN;
END architecture BEHAVIOUR;
