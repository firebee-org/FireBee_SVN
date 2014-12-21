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
        CLK_MAIN            : IN STD_LOGIC;
        CLK_33M             : IN STD_LOGIC;
        CLK_25M             : IN STD_LOGIC;
        CLK_VIDEO           : IN STD_LOGIC;
        CLK_DDR3            : IN STD_LOGIC;
        CLK_DDR2            : IN STD_LOGIC;
        CLK_DDR0            : IN STD_LOGIC;
        CLK_PIXEL           : OUT STD_LOGIC;
        
        VR_D                : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        VR_BUSY             : IN STD_LOGIC;
        
        FB_ADR              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FB_AD_IN            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FB_AD_OUT           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FB_AD_EN_31_16      : OUT STD_LOGIC; -- Hi word.
        FB_AD_EN_15_0       : OUT STD_LOGIC; -- Low word.
        FB_ALE              : IN STD_LOGIC;
        FB_CSn              : IN STD_LOGIC_VECTOR(3 DOWNTO 1);
        FB_OEn              : IN STD_LOGIC;
        fb_wr_n             : IN STD_LOGIC;
        FB_SIZE1            : IN STD_LOGIC;
        FB_SIZE0            : IN STD_LOGIC;
        
        VDP_IN              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);

        VR_RD               : OUT STD_LOGIC;
        VR_WR               : OUT STD_LOGIC;
        VIDEO_RECONFIG      : OUT STD_LOGIC;

        RED                 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        GREEN               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        BLUE                : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        VSYNC               : OUT STD_LOGIC;
        HSYNC               : OUT STD_LOGIC;
        SYNCn               : OUT STD_LOGIC;
        BLANKn              : OUT STD_LOGIC;
        
        PD_VGAn             : OUT STD_LOGIC;
        VIDEO_MOD_TA        : OUT STD_LOGIC;

        VD_VZ               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
        SR_FIFO_WRE         : IN STD_LOGIC;
        SR_VDMP             : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        FIFO_MW             : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        VDM_SEL             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        VIDEO_RAM_CTR       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        FIFO_CLR            : OUT STD_LOGIC;
        VDM                 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        BLITTER_RUN         : IN STD_LOGIC;
        BLITTER_ON          : OUT STD_LOGIC
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
			q		   : OUT STD_LOGIC_VECTOR (127 DOWNTO 0)
		);
	END COMPONENT;
	
	TYPE CLUT_SHIFTREG_TYPE is ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	TYPE CLUT_ST_TYPE is ARRAY(0 TO 15) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
	TYPE CLUT_FA_TYPE is ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(17 DOWNTO 0);
	TYPE CLUT_FBEE_TYPE is ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
	
	SIGNAL CLUT_FA              : CLUT_FA_TYPE;
	SIGNAL CLUT_FI              : CLUT_FBEE_TYPE;
	SIGNAL CLUT_ST              : CLUT_ST_TYPE;
	
	SIGNAL CLUT_FA_R            : STD_LOGIC_VECTOR(5 DOWNTO 0);  
	SIGNAL CLUT_FA_G            : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL CLUT_FA_B            : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL CLUT_FBEE_R          : STD_LOGIC_VECTOR(7 DOWNTO 0);  
	SIGNAL CLUT_FBEE_G          : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLUT_FBEE_B          : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLUT_ST_R            : STD_LOGIC_VECTOR(3 DOWNTO 0);  
	SIGNAL CLUT_ST_G            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CLUT_ST_B            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	SIGNAL CLUT_FA_OUT          : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL CLUT_FBEE_OUT        : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL CLUT_ST_OUT          : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	SIGNAL CLUT_ADR             : STD_LOGIC_VECTOR(7 DOWNTO 0);        
	SIGNAL CLUT_ADR_A           : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLUT_ADR_MUX         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CLUT_SHIFT_IN        : STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	SIGNAL CLUT_SHIFT_LOAD      : STD_LOGIC;
	SIGNAL CLUT_OFF             : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CLUT_FBEE_RD         : STD_LOGIC;
	SIGNAL CLUT_FBEE_WR         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CLUT_FA_RDH          : STD_LOGIC;
	SIGNAL CLUT_FA_RDL          : STD_LOGIC;
	SIGNAL CLUT_FA_WR           : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL CLUT_ST_RD           : STD_LOGIC;
	SIGNAL CLUT_ST_WR           : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	SIGNAL DATA_OUT_VIDEO_CTRL  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_EN_H_VIDEO_CTRL : STD_LOGIC;
	SIGNAL DATA_EN_L_VIDEO_CTRL : STD_LOGIC;
	
	SIGNAL COLOR1               : STD_LOGIC;
	SIGNAL COLOR2               : STD_LOGIC;
	SIGNAL COLOR4               : STD_LOGIC;
	SIGNAL COLOR8               : STD_LOGIC;
	SIGNAL CCR                  : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL CC_SEL               : STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	SIGNAL FIFO_CLR_I           : STD_LOGIC;
	SIGNAL DOP_FIFO_CLR         : STD_LOGIC;
	SIGNAL FIFO_WRE             : STD_LOGIC;
	
	SIGNAL FIFO_RD_REQ_128      : STD_LOGIC;
	SIGNAL FIFO_RD_REQ_512      : STD_LOGIC;
	SIGNAL FIFO_RDE             : STD_LOGIC;
	SIGNAL INTER_ZEI            : STD_LOGIC;
	SIGNAL FIFO_D_OUT_128       : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL FIFO_D_OUT_512       : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL FIFO_D_IN_512        : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL FIFO_D               : STD_LOGIC_VECTOR(127 DOWNTO 0);
	
	SIGNAL VD_VZ_I              : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL VDM_A                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL VDM_B                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL VDM_C                : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL V_DMA_SEL            : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL VDMP                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL VDMP_I               : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CC_24                : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CC_16                : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL CLK_PIXEL_I          : STD_LOGIC;
	SIGNAL VD_OUT_I             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ZR_C8                : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN
	CLK_PIXEL <= CLK_PIXEL_I;
	FIFO_CLR <= FIFO_CLR_I;
		
	P_CLUT_ST_MC: PROCESS
		-- This is the dual ported ram FOR the ST colour lookup tables.
	 	VARIABLE clut_fa_index			: integer;
		VARIABLE clut_st_index			: integer;
		VARIABLE clut_fi_index			: integer;
	BEGIN
		clut_st_index := TO_INTEGER(UNSIGNED(FB_ADR(4 DOWNTO 1)));
		clut_fa_index := TO_INTEGER(UNSIGNED(FB_ADR(9 DOWNTO 2)));
		clut_fi_index := TO_INTEGER(UNSIGNED(FB_ADR(9 DOWNTO 2)));

		WAIT UNTIL RISING_EDGE(CLK_MAIN);
		IF CLUT_ST_WR(0) = '1' THEN
			CLUT_ST(clut_st_index)(11 DOWNTO 8) <= FB_AD_IN(27 DOWNTO 24);
		END IF;
		IF CLUT_ST_WR(1) = '1' THEN
			CLUT_ST(clut_st_index)(7 DOWNTO 0) <= FB_AD_IN(23 DOWNTO 16);
		END IF;

		IF CLUT_FA_WR(0) = '1' THEN
			CLUT_FA(clut_fa_index)(17 DOWNTO 12) <= FB_AD_IN(31 DOWNTO 26);
		END IF;
		IF CLUT_FA_WR(1) = '1' THEN
			CLUT_FA(clut_fa_index)(11 DOWNTO 6) <= FB_AD_IN(23 DOWNTO 18);
		END IF;
		IF CLUT_FA_WR(3) = '1' THEN
			CLUT_FA(clut_fa_index)(5 DOWNTO 0) <= FB_AD_IN(23 DOWNTO 18);
		END IF;

		IF CLUT_FBEE_WR(1) = '1' THEN
			CLUT_FI(clut_fi_index)(23 DOWNTO 16) <= FB_AD_IN(23 DOWNTO 16);
		END IF;
		IF CLUT_FBEE_WR(2) = '1' THEN
			CLUT_FI(clut_fi_index)(15 DOWNTO 8) <= FB_AD_IN(15 DOWNTO 8);
		END IF;
		IF CLUT_FBEE_WR(3) = '1' THEN
			CLUT_FI(clut_fi_index)(7 DOWNTO 0) <= FB_AD_IN(7 DOWNTO 0);
		END IF;
        --
		CLUT_ST_OUT <= CLUT_ST(clut_st_index);
		CLUT_FA_OUT <= CLUT_FA(clut_fa_index);
		CLUT_FBEE_OUT <= CLUT_FI(clut_fi_index);
	END PROCESS P_CLUT_ST_MC;

	P_CLUT_ST_PX: PROCESS
		VARIABLE clut_fa_index			: integer;
		VARIABLE clut_st_index			: integer;
		VARIABLE clut_fi_index			: integer;
		-- This is the dual ported ram FOR the ST colour lookup tables.
	BEGIN
		clut_st_index := TO_INTEGER(UNSIGNED(CLUT_ADR(3 DOWNTO 0)));
		clut_fa_index := TO_INTEGER(UNSIGNED(CLUT_ADR));
		clut_fi_index := TO_INTEGER(UNSIGNED(ZR_C8));
		
		WAIT UNTIL CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;

		CLUT_ST_R <= CLUT_ST(clut_st_index)(8) & CLUT_ST(clut_st_index)(11 DOWNTO 9);
		CLUT_ST_G <= CLUT_ST(clut_st_index)(4) & CLUT_ST(clut_st_index)(7 DOWNTO 5);
		CLUT_ST_B <= CLUT_ST(clut_st_index)(0) & CLUT_ST(clut_st_index)(3 DOWNTO 1);
		
		CLUT_FA_R <= CLUT_FA(clut_fa_index)(17 DOWNTO 12);
		CLUT_FA_G <= CLUT_FA(clut_fa_index)(11 DOWNTO 6);
		CLUT_FA_B <= CLUT_FA(clut_fa_index)(5 DOWNTO 0);
		
		CLUT_FBEE_R <= CLUT_FI(clut_fi_index)(23 DOWNTO 16);
		CLUT_FBEE_G <= CLUT_FI(clut_fi_index)(15 DOWNTO 8);
		CLUT_FBEE_B <= CLUT_FI(clut_fi_index)(7 DOWNTO 0);
	END PROCESS P_CLUT_ST_PX;

	P_VIDEO_OUT: PROCESS
		VARIABLE VIDEO_OUT  : STD_LOGIC_VECTOR(23 DOWNTO 0);
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_PIXEL_I);
		CASE CC_SEL is
			WHEN "111" => VIDEO_OUT := CCR; -- Register TYPE video.
			WHEN "110" => VIDEO_OUT := CC_24(23 DOWNTO 0); -- 3 byte FIFO TYPE video.
			WHEN "101" => VIDEO_OUT := CC_16; -- 2 byte FIFO TYPE video.
			WHEN "100" => VIDEO_OUT := CLUT_FBEE_R & CLUT_FBEE_G & CLUT_FBEE_B; -- Firebee TYPE video.
			WHEN "001" => VIDEO_OUT := CLUT_FA_R & "00" & CLUT_FA_G & "00" & CLUT_FA_B & "00"; -- Falcon TYPE video.
			WHEN "000" => VIDEO_OUT := CLUT_ST_R & x"0" & CLUT_ST_G & x"0" & CLUT_ST_B & x"0"; -- ST TYPE video.
			WHEN OTHERS => VIDEO_OUT := (OTHERS => '0');
		END CASE;
		RED <= VIDEO_OUT(23 DOWNTO 16);
		GREEN <= VIDEO_OUT(15 DOWNTO 8);
		BLUE <= VIDEO_OUT(7 DOWNTO 0);
	END PROCESS P_VIDEO_OUT;

	P_CC: PROCESS
		VARIABLE CC24_I : STD_LOGIC_VECTOR(31 DOWNTO 0);
      VARIABLE CC_I   : STD_LOGIC_VECTOR(15 DOWNTO 0);
      VARIABLE ZR_C8_I   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		WAIT UNTIL CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
		CASE CLUT_ADR_MUX(1 DOWNTO 0) is
			WHEN "11" => CC24_I := FIFO_D(31 DOWNTO 0);
			WHEN "10" => CC24_I := FIFO_D(63 DOWNTO 32);
			WHEN "01" => CC24_I := FIFO_D(95 DOWNTO 64);
			WHEN "00" => CC24_I := FIFO_D(127 DOWNTO 96);
			WHEN OTHERS => CC24_I := (OTHERS => 'Z');
		END CASE;
           --
		CC_24 <= CC24_I;
           --
		CASE CLUT_ADR_MUX(2 DOWNTO 0) is
			WHEN "111" => CC_I := FIFO_D(15 DOWNTO 0);
			WHEN "110" => CC_I := FIFO_D(31 DOWNTO 16);
			WHEN "101" => CC_I := FIFO_D(47 DOWNTO 32);
			WHEN "100" => CC_I := FIFO_D(63 DOWNTO 48);
			WHEN "011" => CC_I := FIFO_D(79 DOWNTO 64);
			WHEN "010" => CC_I := FIFO_D(95 DOWNTO 80);
			WHEN "001" => CC_I := FIFO_D(111 DOWNTO 96);
			WHEN "000" => CC_I := FIFO_D(127 DOWNTO 112);
			WHEN OTHERS => CC_I := (OTHERS => 'X');
		END CASE;
           --
		CC_16 <= CC_I(15 DOWNTO 11) & "000" & CC_I(10 DOWNTO 5) & "00" & CC_I(4 DOWNTO 0) & "000";
           --
		CASE CLUT_ADR_MUX(3 DOWNTO 0) is
			WHEN x"F" => ZR_C8_I := FIFO_D(7 DOWNTO 0);
			WHEN x"E" => ZR_C8_I := FIFO_D(15 DOWNTO 8);
			WHEN x"D" => ZR_C8_I := FIFO_D(23 DOWNTO 16);
			WHEN x"C" => ZR_C8_I := FIFO_D(31 DOWNTO 24);
			WHEN x"B" => ZR_C8_I := FIFO_D(39 DOWNTO 32);
			WHEN x"A" => ZR_C8_I := FIFO_D(47 DOWNTO 40);
			WHEN x"9" => ZR_C8_I := FIFO_D(55 DOWNTO 48);
			WHEN x"8" => ZR_C8_I := FIFO_D(63 DOWNTO 56);
			WHEN x"7" => ZR_C8_I := FIFO_D(71 DOWNTO 64);
			WHEN x"6" => ZR_C8_I := FIFO_D(79 DOWNTO 72);
			WHEN x"5" => ZR_C8_I := FIFO_D(87 DOWNTO 80);
			WHEN x"4" => ZR_C8_I := FIFO_D(95 DOWNTO 88);
			WHEN x"3" => ZR_C8_I := FIFO_D(103 DOWNTO 96);
			WHEN x"2" => ZR_C8_I := FIFO_D(111 DOWNTO 104);
			WHEN x"1" => ZR_C8_I := FIFO_D(119 DOWNTO 112);
			WHEN x"0" => ZR_C8_I := FIFO_D(127 DOWNTO 120);
			WHEN OTHERS => ZR_C8_I := (OTHERS => 'X');
		END CASE;
			--
		CASE COLOR1 is
			WHEN '1' => ZR_C8 <= ZR_C8_I;
			WHEN OTHERS => ZR_C8 <= "0000000" & ZR_C8_I(0); 
		END CASE;
	END PROCESS P_CC;

	CLUT_SHIFT_IN <= CLUT_ADR_A(6 DOWNTO 1) WHEN COLOR4 = '0' and COLOR2 = '0' ELSE
							CLUT_ADR_A(7 DOWNTO 2) WHEN COLOR4 = '0' and COLOR2 = '1' ELSE
							"00" & CLUT_ADR_A(7 DOWNTO 4) WHEN COLOR4 = '1' and COLOR2 = '0' ELSE "000000";

	FIFO_RD_REQ_128 <= '1' WHEN FIFO_RDE = '1' and INTER_ZEI = '1' ELSE '0';
	FIFO_RD_REQ_512 <= '1' WHEN FIFO_RDE = '1' and INTER_ZEI = '0' ELSE '0';

	FIFO_DMUX: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_PIXEL_I);
		IF FIFO_RDE = '1' and INTER_ZEI = '1' THEN
			FIFO_D <= FIFO_D_OUT_128;
		ELSIF FIFO_RDE = '1' THEN
			FIFO_D <= FIFO_D_OUT_512;
		END IF;
	END PROCESS FIFO_DMUX;

	CLUT_SHIFTREGS: PROCESS
		VARIABLE CLUT_SHIFTREG   : CLUT_SHIFTREG_TYPE;
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_PIXEL_I);
		CLUT_SHIFT_LOAD <= FIFO_RDE;
		IF CLUT_SHIFT_LOAD = '1' THEN
			FOR i IN 0 TO 7 LOOP
				CLUT_SHIFTREG(7 - i) := FIFO_D((i + 1) * 16 - 1 DOWNTO i * 16);
			END LOOP;
		ELSE
			CLUT_SHIFTREG(7) := CLUT_SHIFTREG(7)(14 DOWNTO 0) & CLUT_ADR_A(0);
			CLUT_SHIFTREG(6) := CLUT_SHIFTREG(6)(14 DOWNTO 0) & CLUT_ADR_A(7);
			CLUT_SHIFTREG(5) := CLUT_SHIFTREG(5)(14 DOWNTO 0) & CLUT_SHIFT_IN(5);
			CLUT_SHIFTREG(4) := CLUT_SHIFTREG(4)(14 DOWNTO 0) & CLUT_SHIFT_IN(4);
			CLUT_SHIFTREG(3) := CLUT_SHIFTREG(3)(14 DOWNTO 0) & CLUT_SHIFT_IN(3);
			CLUT_SHIFTREG(2) := CLUT_SHIFTREG(2)(14 DOWNTO 0) & CLUT_SHIFT_IN(2);
			CLUT_SHIFTREG(1) := CLUT_SHIFTREG(1)(14 DOWNTO 0) & CLUT_SHIFT_IN(1);
			CLUT_SHIFTREG(0) := CLUT_SHIFTREG(0)(14 DOWNTO 0) & CLUT_SHIFT_IN(0);
		END IF;
		--
      FOR i IN 0 TO 7 LOOP
			CLUT_ADR_A(i) <= CLUT_SHIFTREG(i)(15);
		END LOOP;
	END PROCESS CLUT_SHIFTREGS;

	CLUT_ADR(7) <= CLUT_OFF(3) or (CLUT_ADR_A(7) and COLOR8);
	CLUT_ADR(6) <= CLUT_OFF(2) or (CLUT_ADR_A(6) and COLOR8);
	CLUT_ADR(5) <= CLUT_OFF(1) or (CLUT_ADR_A(5) and COLOR8);
	CLUT_ADR(4) <= CLUT_OFF(0) or (CLUT_ADR_A(4) and COLOR8);
	CLUT_ADR(3) <= CLUT_ADR_A(3) and (COLOR8 or COLOR4);
	CLUT_ADR(2) <= CLUT_ADR_A(2) and (COLOR8 or COLOR4);
	CLUT_ADR(1) <= CLUT_ADR_A(1) and (COLOR8 or COLOR4 or COLOR2);
	CLUT_ADR(0) <= CLUT_ADR_A(0);
    
	FB_AD_OUT <= x"0" & CLUT_ST_OUT & x"0000" WHEN CLUT_ST_RD = '1' ELSE
						CLUT_FA_OUT(17 DOWNTO 12) & "00" & CLUT_FA_OUT(11 DOWNTO 6) & "00" & x"0000" WHEN CLUT_FA_RDH = '1' ELSE
						x"00" & CLUT_FA_OUT(5 DOWNTO 0) & "00" & x"0000" WHEN CLUT_FA_RDL = '1' ELSE
						x"00" & CLUT_FBEE_OUT WHEN CLUT_FBEE_RD = '1' ELSE 
						DATA_OUT_VIDEO_CTRL WHEN DATA_EN_H_VIDEO_CTRL = '1' ELSE -- Use upper word.
						DATA_OUT_VIDEO_CTRL WHEN DATA_EN_L_VIDEO_CTRL = '1' ELSE (OTHERS => '0'); -- Use lower word.

	FB_AD_EN_31_16 <= '1' WHEN CLUT_FBEE_RD = '1' ELSE
							'1' WHEN CLUT_FA_RDH = '1' ELSE
							'1' WHEN DATA_EN_H_VIDEO_CTRL = '1' ELSE '0';
                
	FB_AD_EN_15_0 <= '1' WHEN CLUT_FBEE_RD = '1' ELSE
							'1' WHEN CLUT_FA_RDL = '1' ELSE
							'1' WHEN DATA_EN_L_VIDEO_CTRL = '1' ELSE '0';
    
	VD_VZ <= VD_VZ_I;
    
	DFF_CLK0: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_DDR0);
		VD_VZ_I <= VD_VZ_I(63 DOWNTO 0) & VDP_IN(63 DOWNTO 0);

		IF FIFO_WRE = '1' THEN
			VDM_A <= VD_VZ_I;
			VDM_B <= VDM_A;
		END IF;
	END PROCESS DFF_CLK0;

	DFF_CLK2: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_DDR2);
		VDMP <= SR_VDMP;
	END PROCESS DFF_CLK2;

	DFF_CLK3: PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_DDR3);
		VDMP_I <= VDMP;
	END PROCESS DFF_CLK3;

	VDM <= VDMP_I(7 DOWNTO 4) WHEN CLK_DDR3 = '1' ELSE VDMP_I(3 DOWNTO 0);
    
	SHIFT_CLK0: PROCESS
		VARIABLE TMP : STD_LOGIC_VECTOR(4 DOWNTO 0);
	BEGIN
		WAIT UNTIL RISING_EDGE(CLK_DDR0);
		TMP := SR_FIFO_WRE & TMP(4 DOWNTO 1);
		FIFO_WRE <= TMP(0);
	END PROCESS SHIFT_CLK0;

	with VDM_SEL select
		VDM_C <=  VDM_B WHEN x"0",
						VDM_B(119 DOWNTO 0) & VDM_A(127 DOWNTO 120) WHEN x"1",
						VDM_B(111 DOWNTO 0) & VDM_A(127 DOWNTO 112) WHEN x"2",
						VDM_B(103 DOWNTO 0) & VDM_A(127 DOWNTO 104) WHEN x"3",
						VDM_B(95 DOWNTO 0) & VDM_A(127 DOWNTO 96) WHEN x"4",
						VDM_B(87 DOWNTO 0) & VDM_A(127 DOWNTO 88) WHEN x"5",
						VDM_B(79 DOWNTO 0) & VDM_A(127 DOWNTO 80) WHEN x"6",
						VDM_B(71 DOWNTO 0) & VDM_A(127 DOWNTO 72) WHEN x"7",
						VDM_B(63 DOWNTO 0) & VDM_A(127 DOWNTO 64) WHEN x"8",
						VDM_B(55 DOWNTO 0) & VDM_A(127 DOWNTO 56) WHEN x"9",
						VDM_B(47 DOWNTO 0) & VDM_A(127 DOWNTO 48) WHEN x"A",
						VDM_B(39 DOWNTO 0) & VDM_A(127 DOWNTO 40) WHEN x"B",
						VDM_B(31 DOWNTO 0) & VDM_A(127 DOWNTO 32) WHEN x"C",
						VDM_B(23 DOWNTO 0) & VDM_A(127 DOWNTO 24) WHEN x"D",
						VDM_B(15 DOWNTO 0) & VDM_A(127 DOWNTO 16) WHEN x"E",
						VDM_B(7 DOWNTO 0) & VDM_A(127 DOWNTO 8) WHEN x"F",
						(OTHERS => 'X') WHEN OTHERS;

	I_FIFO_DC0: lpm_fifo_dc0
	PORT map(
		aclr        => FIFO_CLR_I,  
		data        => VDM_C,
		rdclk       => CLK_PIXEL_I,
		rdreq       => FIFO_RD_REQ_512,
		wrclk       => CLK_DDR0,
		wrreq       => FIFO_WRE,
		q           => FIFO_D_OUT_512,
		--rdempty   =>, -- Not  d.
		wrusedw     => FIFO_MW
	);

	I_FIFO_DZ: lpm_fifoDZ
		PORT map(
			aclr        => DOP_FIFO_CLR,
			clock       => CLK_PIXEL_I,
			data        => FIFO_D_OUT_512,
			rdreq       => FIFO_RD_REQ_128,
			wrreq       => FIFO_RD_REQ_512,
			q           => FIFO_D_OUT_128
		);

	I_VIDEO_CTRL: VIDEO_CTRL
		PORT map(
			CLK_MAIN            => CLK_MAIN,
			FB_CSn(1)           => FB_CSn(1),
			FB_CSn(2)           => FB_CSn(2),
			fb_wr_n             => fb_wr_n,
			FB_OEn              => FB_OEn,
			FB_SIZE(0)          => FB_SIZE0,
			FB_SIZE(1)          => FB_SIZE1,
			FB_ADR              => FB_ADR,
			CLK33M              => CLK_33M,
			CLK25M              => CLK_25M,
			BLITTER_RUN         => BLITTER_RUN,
			CLK_VIDEO           => CLK_VIDEO,
			VR_D                => VR_D,
			VR_BUSY             => VR_BUSY,
			COLOR8              => COLOR8,
			FBEE_CLUT_RD        => CLUT_FBEE_RD,
			COLOR1              => COLOR1,
			FALCON_CLUT_RDH     => CLUT_FA_RDH,
			FALCON_CLUT_RDL     => CLUT_FA_RDL,
			FALCON_CLUT_WR      => CLUT_FA_WR,
			CLUT_ST_RD          => CLUT_ST_RD,
			CLUT_ST_WR          => CLUT_ST_WR,
			CLUT_MUX_ADR        => CLUT_ADR_MUX,
			HSYNC               => HSYNC,
			VSYNC               => VSYNC,
			BLANKn              => BLANKn,
			SYNCn               => SYNCn,
			PD_VGAn             => PD_VGAn,
			FIFO_RDE            => FIFO_RDE,
			COLOR2              => COLOR2,
			COLOR4              => COLOR4,
			CLK_PIXEL           => CLK_PIXEL_I,
			CLUT_OFF            => CLUT_OFF,
			BLITTER_ON          => BLITTER_ON,
			VIDEO_RAM_CTR       => VIDEO_RAM_CTR,
			VIDEO_MOD_TA        => VIDEO_MOD_TA,
			CCR                 => CCR,
			CCSEL               => CC_SEL,
			FBEE_CLUT_WR        => CLUT_FBEE_WR,
			INTER_ZEI           => INTER_ZEI,
			DOP_FIFO_CLR        => DOP_FIFO_CLR,
			VIDEO_RECONFIG      => VIDEO_RECONFIG,
			VR_WR               => VR_WR,
			VR_RD               => VR_RD,
			FIFO_CLR            => FIFO_CLR_I,
			DATA_IN             => FB_AD_IN,
			DATA_OUT            => DATA_OUT_VIDEO_CTRL,
			DATA_EN_H           => DATA_EN_H_VIDEO_CTRL,
			DATA_EN_L           => DATA_EN_L_VIDEO_CTRL
		);
END ARCHITECTURE;
