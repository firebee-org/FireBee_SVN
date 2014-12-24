----------------------------------------------------------------------
----                                                              ----
---- This file is part OF the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the video toplevel OF the 'Firebee'----
---- computer. It is optimized FOR the   OF an Altera Cyclone   ----
---- FPGA (EP3C40F484). This IP-Core is based on the first edi-   ----
---- tion OF the Firebee configware originally provided by Fredi  ----
---- Ashwanden  and Wolfgang Förster. This release is IN compa-   ----
---- rision TO the first edition completely written IN VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Wolfgang Förster                          ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms OF the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 OF the License, or (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program is distributed IN the hope that it will be      ----
----    ful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty OF MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License FOR more        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy OF the GNU General Public    ----
---- License along with this program; IF not, write TO the Free   ----
---- Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K12B  20120801 WF
--   Initial Release OF the second edition.
--     ST colours enhanced TO 4 bit colour mode (STE compatibility).

LIBRARY work;
    USE work.firebee_pkg.ALL;

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY VIDEO_SYSTEM IS
    PORT (
        clk_main            : IN STD_LOGIC;
        clk_33m             : IN STD_LOGIC;
        clk_25m             : IN STD_LOGIC;
        clk_video           : IN STD_LOGIC;
        clk_ddr3            : IN STD_LOGIC;
        clk_ddr2            : IN STD_LOGIC;
        clk_ddr0            : IN STD_LOGIC;
        clk_pixel           : OUT STD_LOGIC;
        
        vr_d                : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        vr_busy             : IN STD_LOGIC;
        
        fb_adr              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_ad_in            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_ad_out           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_ad_en_31_16      : OUT STD_LOGIC; -- Hi word.
        fb_ad_en_15_0       : OUT STD_LOGIC; -- Low word.
        fb_ale              : IN STD_LOGIC;
        fb_cs_n             : IN STD_LOGIC_VECTOR(3 DOWNTO 1);
        fb_oe_n             : IN STD_LOGIC;
        fb_wr_n             : IN STD_LOGIC;
        fb_size1            : IN STD_LOGIC;
        fb_size0            : IN STD_LOGIC;
        
        vdp_in              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);

        vr_rd               : OUT STD_LOGIC;
        vr_wr               : OUT STD_LOGIC;
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
END ENTITY VIDEO_SYSTEM;
        
ARCHITECTURE BEHAVIOUR OF VIDEO_SYSTEM is
	COMPONENT lpm_fifo_dc0
		PORT(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		    : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrusedw		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT lpm_fifoDZ is
		PORT(
			aclr		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
			rdreq		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		    : OUT STD_LOGIC_VECTOR (127 DOWNTO 0)
		);
	END COMPONENT;
	
	TYPE clut_shiftreg_t IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	TYPE clut_st_t IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
	TYPE clut_fa_t IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(17 DOWNTO 0);
	TYPE clut_fbee_t IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
	
	SIGNAL clut_fa              : clut_fa_t;
	SIGNAL clut_fi              : clut_fbee_t;
	SIGNAL clut_st              : clut_st_t;
	
	SIGNAL clut_fa_r            : STD_LOGIC_VECTOR(5 DOWNTO 0);  
	SIGNAL clut_fa_g            : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL clut_fa_b            : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL clut_fbee_r          : STD_LOGIC_VECTOR(7 DOWNTO 0);  
	SIGNAL clut_fbee_g          : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clut_fbee_b          : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clut_st_r            : STD_LOGIC_VECTOR(3 DOWNTO 0);  
	SIGNAL clut_st_g            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clut_st_b            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	SIGNAL clut_fa_out          : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL clut_fbee_out        : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL clut_st_out          : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	SIGNAL clut_adr             : STD_LOGIC_VECTOR(7 DOWNTO 0);        
	SIGNAL clut_adr_a           : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clut_adr_mux         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clut_shift_in        : STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	SIGNAL clut_shift_load      : STD_LOGIC;
	SIGNAL clut_off             : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clut_fbee_rd         : STD_LOGIC;
	SIGNAL clut_fbee_wr         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clut_fa_rdh          : STD_LOGIC;
	SIGNAL clut_fa_rdl          : STD_LOGIC;
	SIGNAL clut_fa_wr           : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clut_st_rd           : STD_LOGIC;
	SIGNAL clut_st_wr           : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	SIGNAL data_out_video_ctrl  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data_en_h_video_ctrl : STD_LOGIC;
	SIGNAL data_en_l_video_ctrl : STD_LOGIC;
	
	SIGNAL COLOR1               : STD_LOGIC;
	SIGNAL color2               : STD_LOGIC;
	SIGNAL color4               : STD_LOGIC;
	SIGNAL color8               : STD_LOGIC;
	SIGNAL ccr                  : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL CC_SEL               : STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL fifo_clr_i           : STD_LOGIC;
	SIGNAL dop_fifo_clr         : STD_LOGIC;
	SIGNAL fifo_wre             : STD_LOGIC;
	
	SIGNAL fifo_rd_req_128      : STD_LOGIC;
	SIGNAL fifo_rd_req_512      : STD_LOGIC;
	SIGNAL fifo_rde             : STD_LOGIC;
	SIGNAL inter_zei            : STD_LOGIC;
	SIGNAL fifo_d_out_128       : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL fifo_d_out_512       : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL FIFO_D_IN_512        : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL fifo_d               : STD_LOGIC_VECTOR(127 DOWNTO 0);
	
	SIGNAL vd_vz_i              : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL vdm_a                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL vdm_b                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL vdm_c                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL V_DMA_SEL            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL vdmp                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL vdmp_i               : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL cc_24                : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cc_16                : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL clk_pixel_i          : STD_LOGIC;
	SIGNAL VD_OUT_I             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL zr_c8                : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN
	clk_pixel <= clk_pixel_i;
	fifo_clr <= fifo_clr_i;
		
	p_clut_st_mc : PROCESS
		-- This is the dual ported ram FOR the ST colour lookup tables.
	 	VARIABLE clut_fa_index			: INTEGER;
		VARIABLE clut_st_index			: INTEGER;
		VARIABLE clut_fi_index			: INTEGER;
	BEGIN
		clut_st_index := TO_INTEGER(UNSIGNED(fb_adr(4 DOWNTO 1)));
		clut_fa_index := TO_INTEGER(UNSIGNED(fb_adr(9 DOWNTO 2)));
		clut_fi_index := TO_INTEGER(UNSIGNED(fb_adr(9 DOWNTO 2)));

		WAIT UNTIL RISING_EDGE(clk_main);
        
		IF clut_st_wr(0) = '1' THEN
			clut_st(clut_st_index)(11 DOWNTO 8) <= fb_ad_in(27 DOWNTO 24);
		END IF;
		IF clut_st_wr(1) = '1' THEN
			clut_st(clut_st_index)(7 DOWNTO 0) <= fb_ad_in(23 DOWNTO 16);
		END IF;

		IF clut_fa_wr(0) = '1' THEN
			clut_fa(clut_fa_index)(17 DOWNTO 12) <= fb_ad_in(31 DOWNTO 26);
		END IF;
		IF clut_fa_wr(1) = '1' THEN
			clut_fa(clut_fa_index)(11 DOWNTO 6) <= fb_ad_in(23 DOWNTO 18);
		END IF;
		IF clut_fa_wr(3) = '1' THEN
			clut_fa(clut_fa_index)(5 DOWNTO 0) <= fb_ad_in(23 DOWNTO 18);
		END IF;

		IF clut_fbee_wr(1) = '1' THEN
			clut_fi(clut_fi_index)(23 DOWNTO 16) <= fb_ad_in(23 DOWNTO 16);
		END IF;
		IF clut_fbee_wr(2) = '1' THEN
			clut_fi(clut_fi_index)(15 DOWNTO 8) <= fb_ad_in(15 DOWNTO 8);
		END IF;
		IF clut_fbee_wr(3) = '1' THEN
			clut_fi(clut_fi_index)(7 DOWNTO 0) <= fb_ad_in(7 DOWNTO 0);
		END IF;
        --
		clut_st_out <= clut_st(clut_st_index);
		clut_fa_out <= clut_fa(clut_fa_index);
		clut_fbee_out <= clut_fi(clut_fi_index);
	END PROCESS p_clut_st_mc;

	p_clut_st_px : PROCESS
		VARIABLE clut_fa_index			: INTEGER;
		VARIABLE clut_st_index			: INTEGER;
		VARIABLE clut_fi_index			: INTEGER;
		-- This is the dual ported ram FOR the ST colour lookup tables.
	BEGIN
		clut_st_index := TO_INTEGER(UNSIGNED(clut_adr(3 DOWNTO 0)));
		clut_fa_index := TO_INTEGER(UNSIGNED(clut_adr));
		clut_fi_index := TO_INTEGER(UNSIGNED(zr_c8));
		
		WAIT UNTIL clk_pixel_i = '1' and clk_pixel_i' event;

		clut_st_r <= clut_st(clut_st_index)(8) & clut_st(clut_st_index)(11 DOWNTO 9);
		clut_st_g <= clut_st(clut_st_index)(4) & clut_st(clut_st_index)(7 DOWNTO 5);
		clut_st_b <= clut_st(clut_st_index)(0) & clut_st(clut_st_index)(3 DOWNTO 1);
		
		clut_fa_r <= clut_fa(clut_fa_index)(17 DOWNTO 12);
		clut_fa_g <= clut_fa(clut_fa_index)(11 DOWNTO 6);
		clut_fa_b <= clut_fa(clut_fa_index)(5 DOWNTO 0);
		
		clut_fbee_r <= clut_fi(clut_fi_index)(23 DOWNTO 16);
		clut_fbee_g <= clut_fi(clut_fi_index)(15 DOWNTO 8);
		clut_fbee_b <= clut_fi(clut_fi_index)(7 DOWNTO 0);
	END PROCESS p_clut_st_px;

	p_video_out : PROCESS
		VARIABLE video_out  : STD_LOGIC_VECTOR(23 DOWNTO 0);
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_pixel_i);
		CASE CC_SEL is
			WHEN "111" => video_out := ccr; -- Register TYPE video.
			WHEN "110" => video_out := cc_24(23 DOWNTO 0); -- 3 byte FIFO TYPE video.
			WHEN "101" => video_out := cc_16; -- 2 byte FIFO TYPE video.
			WHEN "100" => video_out := clut_fbee_r & clut_fbee_g & clut_fbee_b; -- Firebee TYPE video.
			WHEN "001" => video_out := clut_fa_r & "00" & clut_fa_g & "00" & clut_fa_b & "00"; -- Falcon TYPE video.
			WHEN "000" => video_out := clut_st_r & x"0" & clut_st_g & x"0" & clut_st_b & x"0"; -- ST TYPE video.
			WHEN OTHERS => video_out := (OTHERS => '0');
		END CASE;
		red <= video_out(23 DOWNTO 16);
		green <= video_out(15 DOWNTO 8);
		blue <= video_out(7 DOWNTO 0);
	END PROCESS p_video_out;

	P_CC: PROCESS
        VARIABLE cc24_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE cc_i   : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE zr_c8_i   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		WAIT UNTIL clk_pixel_i = '1' and clk_pixel_i' event;
		CASE clut_adr_mux(1 DOWNTO 0) is
			WHEN "11" => cc24_i := fifo_d(31 DOWNTO 0);
			WHEN "10" => cc24_i := fifo_d(63 DOWNTO 32);
			WHEN "01" => cc24_i := fifo_d(95 DOWNTO 64);
			WHEN "00" => cc24_i := fifo_d(127 DOWNTO 96);
			WHEN OTHERS => cc24_i := (OTHERS => 'Z');
		END CASE;
           --
		cc_24 <= cc24_i;
           --
		CASE clut_adr_mux(2 DOWNTO 0) is
			WHEN "111" => cc_i := fifo_d(15 DOWNTO 0);
			WHEN "110" => cc_i := fifo_d(31 DOWNTO 16);
			WHEN "101" => cc_i := fifo_d(47 DOWNTO 32);
			WHEN "100" => cc_i := fifo_d(63 DOWNTO 48);
			WHEN "011" => cc_i := fifo_d(79 DOWNTO 64);
			WHEN "010" => cc_i := fifo_d(95 DOWNTO 80);
			WHEN "001" => cc_i := fifo_d(111 DOWNTO 96);
			WHEN "000" => cc_i := fifo_d(127 DOWNTO 112);
			WHEN OTHERS => cc_i := (OTHERS => 'X');
		END CASE;
           --
		cc_16 <= cc_i(15 DOWNTO 11) & "000" & cc_i(10 DOWNTO 5) & "00" & cc_i(4 DOWNTO 0) & "000";
           --
		CASE clut_adr_mux(3 DOWNTO 0) is
			WHEN x"F" => zr_c8_i := fifo_d(7 DOWNTO 0);
			WHEN x"E" => zr_c8_i := fifo_d(15 DOWNTO 8);
			WHEN x"D" => zr_c8_i := fifo_d(23 DOWNTO 16);
			WHEN x"C" => zr_c8_i := fifo_d(31 DOWNTO 24);
			WHEN x"B" => zr_c8_i := fifo_d(39 DOWNTO 32);
			WHEN x"A" => zr_c8_i := fifo_d(47 DOWNTO 40);
			WHEN x"9" => zr_c8_i := fifo_d(55 DOWNTO 48);
			WHEN x"8" => zr_c8_i := fifo_d(63 DOWNTO 56);
			WHEN x"7" => zr_c8_i := fifo_d(71 DOWNTO 64);
			WHEN x"6" => zr_c8_i := fifo_d(79 DOWNTO 72);
			WHEN x"5" => zr_c8_i := fifo_d(87 DOWNTO 80);
			WHEN x"4" => zr_c8_i := fifo_d(95 DOWNTO 88);
			WHEN x"3" => zr_c8_i := fifo_d(103 DOWNTO 96);
			WHEN x"2" => zr_c8_i := fifo_d(111 DOWNTO 104);
			WHEN x"1" => zr_c8_i := fifo_d(119 DOWNTO 112);
			WHEN x"0" => zr_c8_i := fifo_d(127 DOWNTO 120);
			WHEN OTHERS => zr_c8_i := (OTHERS => 'X');
		END CASE;
			--
		CASE COLOR1 is
			WHEN '1' => zr_c8 <= zr_c8_i;
			WHEN OTHERS => zr_c8 <= "0000000" & zr_c8_i(0); 
		END CASE;
	END PROCESS P_CC;

    clut_shift_in <= clut_adr_a(6 DOWNTO 1) WHEN color4 = '0' and color2 = '0' ELSE
                        clut_adr_a(7 DOWNTO 2) WHEN color4 = '0' and color2 = '1' ELSE
                        "00" & clut_adr_a(7 DOWNTO 4) WHEN color4 = '1' and color2 = '0' ELSE "000000";

	fifo_rd_req_128 <= '1' WHEN fifo_rde = '1' and inter_zei = '1' ELSE '0';
	fifo_rd_req_512 <= '1' WHEN fifo_rde = '1' and inter_zei = '0' ELSE '0';

	FIFO_DMUX: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_pixel_i);
		IF fifo_rde = '1' and inter_zei = '1' THEN
			fifo_d <= fifo_d_out_128;
		ELSIF fifo_rde = '1' THEN
			fifo_d <= fifo_d_out_512;
		END IF;
	END PROCESS FIFO_DMUX;

	CLUT_SHIFTREGS: PROCESS
		VARIABLE clut_shiftreg   : clut_shiftreg_t;
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_pixel_i);
		clut_shift_load <= fifo_rde;
		IF clut_shift_load = '1' THEN
			FOR i IN 0 TO 7 LOOP
				clut_shiftreg(7 - i) := fifo_d((i + 1) * 16 - 1 DOWNTO i * 16);
			END LOOP;
		ELSE
			clut_shiftreg(7) := clut_shiftreg(7)(14 DOWNTO 0) & clut_adr_a(0);
			clut_shiftreg(6) := clut_shiftreg(6)(14 DOWNTO 0) & clut_adr_a(7);
			clut_shiftreg(5) := clut_shiftreg(5)(14 DOWNTO 0) & clut_shift_in(5);
			clut_shiftreg(4) := clut_shiftreg(4)(14 DOWNTO 0) & clut_shift_in(4);
			clut_shiftreg(3) := clut_shiftreg(3)(14 DOWNTO 0) & clut_shift_in(3);
			clut_shiftreg(2) := clut_shiftreg(2)(14 DOWNTO 0) & clut_shift_in(2);
			clut_shiftreg(1) := clut_shiftreg(1)(14 DOWNTO 0) & clut_shift_in(1);
			clut_shiftreg(0) := clut_shiftreg(0)(14 DOWNTO 0) & clut_shift_in(0);
		END IF;
		--
      FOR i IN 0 TO 7 LOOP
			clut_adr_a(i) <= clut_shiftreg(i)(15);
		END LOOP;
	END PROCESS CLUT_SHIFTREGS;

	clut_adr(7) <= clut_off(3) or (clut_adr_a(7) and color8);
	clut_adr(6) <= clut_off(2) or (clut_adr_a(6) and color8);
	clut_adr(5) <= clut_off(1) or (clut_adr_a(5) and color8);
	clut_adr(4) <= clut_off(0) or (clut_adr_a(4) and color8);
	clut_adr(3) <= clut_adr_a(3) and (color8 or color4);
	clut_adr(2) <= clut_adr_a(2) and (color8 or color4);
	clut_adr(1) <= clut_adr_a(1) and (color8 or color4 or color2);
	clut_adr(0) <= clut_adr_a(0);
    
	fb_ad_out <= x"0" & clut_st_out & x"0000" WHEN clut_st_rd = '1' ELSE
						clut_fa_out(17 DOWNTO 12) & "00" & clut_fa_out(11 DOWNTO 6) & "00" & x"0000" WHEN clut_fa_rdh = '1' ELSE
						x"00" & clut_fa_out(5 DOWNTO 0) & "00" & x"0000" WHEN clut_fa_rdl = '1' ELSE
						x"00" & clut_fbee_out WHEN clut_fbee_rd = '1' ELSE 
						data_out_video_ctrl WHEN data_en_h_video_ctrl = '1' ELSE -- Use upper word.
						data_out_video_ctrl WHEN data_en_l_video_ctrl = '1' ELSE (OTHERS => '0'); -- Use lower word.

	fb_ad_en_31_16 <= '1' WHEN clut_fbee_rd = '1' ELSE
							'1' WHEN clut_fa_rdh = '1' ELSE
							'1' WHEN data_en_h_video_ctrl = '1' ELSE '0';
                
	fb_ad_en_15_0 <= '1' WHEN clut_fbee_rd = '1' ELSE
							'1' WHEN clut_fa_rdl = '1' ELSE
							'1' WHEN data_en_l_video_ctrl = '1' ELSE '0';
    
	vd_vz <= vd_vz_i;
    
	DFF_CLK0: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_ddr0);
		vd_vz_i <= vd_vz_i(63 DOWNTO 0) & vdp_in(63 DOWNTO 0);

		IF fifo_wre = '1' THEN
			vdm_a <= vd_vz_i;
			vdm_b <= vdm_a;
		END IF;
	END PROCESS DFF_CLK0;

	DFF_CLK2: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_ddr2);
		vdmp <= sr_vdmp;
	END PROCESS DFF_CLK2;

	DFF_CLK3: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_ddr3);
		vdmp_i <= vdmp;
	END PROCESS DFF_CLK3;

	vdm <= vdmp_i(7 DOWNTO 4) WHEN clk_ddr3 = '1' ELSE vdmp_i(3 DOWNTO 0);
    
	SHIFT_CLK0: PROCESS
		VARIABLE tmp : STD_LOGIC_VECTOR(4 DOWNTO 0);
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_ddr0);
		tmp := sr_fifo_wre & tmp(4 DOWNTO 1);
		fifo_wre <= tmp(0);
	END PROCESS SHIFT_CLK0;

	with vdm_sel select
		vdm_c <=  vdm_b WHEN x"0",
						vdm_b(119 DOWNTO 0) & vdm_a(127 DOWNTO 120) WHEN x"1",
						vdm_b(111 DOWNTO 0) & vdm_a(127 DOWNTO 112) WHEN x"2",
						vdm_b(103 DOWNTO 0) & vdm_a(127 DOWNTO 104) WHEN x"3",
						vdm_b(95 DOWNTO 0) & vdm_a(127 DOWNTO 96) WHEN x"4",
						vdm_b(87 DOWNTO 0) & vdm_a(127 DOWNTO 88) WHEN x"5",
						vdm_b(79 DOWNTO 0) & vdm_a(127 DOWNTO 80) WHEN x"6",
						vdm_b(71 DOWNTO 0) & vdm_a(127 DOWNTO 72) WHEN x"7",
						vdm_b(63 DOWNTO 0) & vdm_a(127 DOWNTO 64) WHEN x"8",
						vdm_b(55 DOWNTO 0) & vdm_a(127 DOWNTO 56) WHEN x"9",
						vdm_b(47 DOWNTO 0) & vdm_a(127 DOWNTO 48) WHEN x"A",
						vdm_b(39 DOWNTO 0) & vdm_a(127 DOWNTO 40) WHEN x"B",
						vdm_b(31 DOWNTO 0) & vdm_a(127 DOWNTO 32) WHEN x"C",
						vdm_b(23 DOWNTO 0) & vdm_a(127 DOWNTO 24) WHEN x"D",
						vdm_b(15 DOWNTO 0) & vdm_a(127 DOWNTO 16) WHEN x"E",
						vdm_b(7 DOWNTO 0) & vdm_a(127 DOWNTO 8) WHEN x"F",
						(OTHERS => 'X') WHEN OTHERS;

	I_FIFO_DC0: lpm_fifo_dc0
	PORT map(
		aclr        => fifo_clr_i,  
		data        => vdm_c,
		rdclk       => clk_pixel_i,
		rdreq       => fifo_rd_req_512,
		wrclk       => clk_ddr0,
		wrreq       => fifo_wre,
		q           => fifo_d_out_512,
		--rdempty   =>, -- Not  d.
		UNSIGNED(wrusedw)     => fifo_mw
	);

	I_FIFO_DZ: lpm_fifoDZ
		PORT map(
			aclr        => dop_fifo_clr,
			clock       => clk_pixel_i,
			data        => fifo_d_out_512,
			rdreq       => fifo_rd_req_128,
			wrreq       => fifo_rd_req_512,
			q           => fifo_d_out_128
		);

	I_VIDEO_CTRL: VIDEO_CTRL
		PORT map(
			clk_main            => clk_main,
			fb_cs_n(1)          => fb_cs_n(1),
			fb_cs_n(2)          => fb_cs_n(2),
			fb_wr_n             => fb_wr_n,
			fb_oe_n             => fb_oe_n,
			FB_SIZE(0)          => fb_size0,
			FB_SIZE(1)          => fb_size1,
			fb_adr              => fb_adr,
			CLK33M              => clk_33m,
			CLK25M              => clk_25m,
			blitter_run         => blitter_run,
			clk_video           => clk_video,
			vr_d                => UNSIGNED(vr_d),
			vr_busy             => vr_busy,
			color8              => color8,
			FBEE_CLUT_RD        => clut_fbee_rd,
			COLOR1              => COLOR1,
			FALCON_CLUT_RDH     => clut_fa_rdh,
			FALCON_CLUT_RDL     => clut_fa_rdl,
			STD_LOGIC_VECTOR(FALCON_CLUT_WR)      => clut_fa_wr,
			clut_st_rd          => clut_st_rd,
			STD_LOGIC_VECTOR(clut_st_wr)          => clut_st_wr,
			STD_LOGIC_VECTOR(CLUT_MUX_ADR)        => clut_adr_mux,
			hsync               => hsync,
			vsync               => vsync,
			blank_n             => blank_n,
			sync_n              => sync_n,
			pd_vga_n            => pd_vga_n,
			fifo_rde            => fifo_rde,
			color2              => color2,
			color4              => color4,
			clk_pixel           => clk_pixel_i,
			STD_LOGIC_VECTOR(clut_off)            => clut_off,
			blitter_on          => blitter_on,
			STD_LOGIC_VECTOR(video_ram_ctr)       => video_ram_ctr,
			video_mod_ta        => video_mod_ta,
			STD_LOGIC_VECTOR(ccr)                 => ccr,
			STD_LOGIC_VECTOR(CCSEL)               => CC_SEL,
			STD_LOGIC_VECTOR(FBEE_CLUT_WR)        => clut_fbee_wr,
			inter_zei           => inter_zei,
			dop_fifo_clr        => dop_fifo_clr,
			video_reconfig      => video_reconfig,
			vr_wr               => vr_wr,
			vr_rd               => vr_rd,
			fifo_clr            => fifo_clr_i,
			DATA_IN             => UNSIGNED(fb_ad_in),
			STD_LOGIC_VECTOR(DATA_OUT)            => data_out_video_ctrl,
			DATA_EN_H           => data_en_h_video_ctrl,
			DATA_EN_L           => data_en_l_video_ctrl
		);
END ARCHITECTURE;
