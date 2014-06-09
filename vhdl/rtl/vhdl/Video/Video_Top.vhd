----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the video toplevel of the 'Firebee'----
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
--     ST colours enhanced to 4 bit colour mode (STE compatibility).

library work;
use work.firebee_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VIDEO_SYSTEM is
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
end entity VIDEO_SYSTEM;
        
architecture BEHAVIOUR of VIDEO_SYSTEM is
component lpm_fifo_dc0
	port(
		aclr		: in std_logic  := '0';
		data		: in std_logic_vector (127 downto 0);
		rdclk		: in std_logic ;
		rdreq		: in std_logic ;
		wrclk		: in std_logic ;
		wrreq		: in std_logic ;
		q		    : out std_logic_vector (127 downto 0);
		rdempty		: out STD_LOGIC ;
		wrusedw		: out std_logic_vector (8 downto 0)
	);
end component;

component lpm_fifoDZ is
	port(
		aclr		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector (127 downto 0);
		rdreq		: in std_logic ;
		wrreq		: in std_logic ;
		q		    : out std_logic_vector (127 downto 0)
	);
end component;

type CLUT_SHIFTREG_TYPE is array(0 to 7) of std_logic_vector(15 downto 0);
type CLUT_ST_TYPE is array(0 to 15) of std_logic_vector(11 downto 0);
type CLUT_FA_TYPE is array(0 to 255) of std_logic_vector(17 downto 0);
type CLUT_FBEE_TYPE is array(0 to 255) of std_logic_vector(23 downto 0);

signal CLUT_FA              : CLUT_FA_TYPE;
signal CLUT_FI              : CLUT_FBEE_TYPE;
signal CLUT_ST              : CLUT_ST_TYPE;

signal CLUT_FA_R            : std_logic_vector(5 downto 0);  
signal CLUT_FA_G            : std_logic_vector(5 downto 0);
signal CLUT_FA_B            : std_logic_vector(5 downto 0);
signal CLUT_FBEE_R          : std_logic_vector(7 downto 0);  
signal CLUT_FBEE_G          : std_logic_vector(7 downto 0);
signal CLUT_FBEE_B          : std_logic_vector(7 downto 0);
signal CLUT_ST_R            : std_logic_vector(3 downto 0);  
signal CLUT_ST_G            : std_logic_vector(3 downto 0);
signal CLUT_ST_B            : std_logic_vector(3 downto 0);

signal CLUT_FA_OUT          : std_logic_vector(17 downto 0);
signal CLUT_FBEE_OUT        : std_logic_vector(23 downto 0);
signal CLUT_ST_OUT          : std_logic_vector(11 downto 0);

signal CLUT_ADR             : std_logic_vector(7 downto 0);        
signal CLUT_ADR_A           : std_logic_vector(7 downto 0);
signal CLUT_ADR_MUX         : std_logic_vector(3 downto 0);

signal CLUT_SHIFT_IN        : std_logic_vector(5 downto 0);

signal CLUT_SHIFT_LOAD      : std_logic;
signal CLUT_OFF             : std_logic_vector(3 downto 0);
signal CLUT_FBEE_RD         : std_logic;
signal CLUT_FBEE_WR         : std_logic_vector(3 downto 0);
signal CLUT_FA_RDH          : std_logic;
signal CLUT_FA_RDL          : std_logic;
signal CLUT_FA_WR           : std_logic_vector(3 downto 0);
signal CLUT_ST_RD           : std_logic;
signal CLUT_ST_WR           : std_logic_vector(1 downto 0);

signal DATA_OUT_VIDEO_CTRL  : std_logic_vector(31 downto 0);
signal DATA_EN_H_VIDEO_CTRL : std_logic;
signal DATA_EN_L_VIDEO_CTRL : std_logic;

signal COLOR1               : std_logic;
signal COLOR2               : std_logic;
signal COLOR4               : std_logic;
signal COLOR8               : std_logic;
signal CCR                  : std_logic_vector(23 downto 0);
signal CC_SEL               : std_logic_vector(2 downto 0);

signal FIFO_CLR_I           : std_logic;
signal DOP_FIFO_CLR         : std_logic;
signal FIFO_WRE             : std_logic;

signal FIFO_RD_REQ_128      : std_logic;
signal FIFO_RD_REQ_512      : std_logic;
signal FIFO_RDE             : std_logic;
signal INTER_ZEI            : std_logic;
signal FIFO_D_OUT_128       : std_logic_vector(127 downto 0);
signal FIFO_D_OUT_512       : std_logic_vector(127 downto 0);
signal FIFO_D_IN_512        : std_logic_vector(127 downto 0);
signal FIFO_D               : std_logic_vector(127 downto 0);

signal VD_VZ_I              : std_logic_vector(127 downto 0);
signal VDM_A                : std_logic_vector(127 downto 0);
signal VDM_B                : std_logic_vector(127 downto 0);
signal VDM_C                : std_logic_vector(127 downto 0);
signal V_DMA_SEL            : std_logic_vector(3 downto 0);
signal VDMP                 : std_logic_vector(7 downto 0);
signal VDMP_I               : std_logic_vector(7 downto 0);
signal CC_24                : std_logic_vector(31 downto 0);
signal CC_16                : std_logic_vector(23 downto 0);
signal CLK_PIXEL_I          : std_logic;
signal VD_OUT_I             : std_logic_vector(31 downto 0);
signal ZR_C8                : std_logic_vector(7 downto 0);
begin
    CLK_PIXEL <= CLK_PIXEL_I;
    
    FIFO_CLR <= FIFO_CLR_I;

    P_CLUT_ST_MC: process

    -- This is the dual ported ram for the ST colour lookup tables.
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if CLUT_ST_WR(0) = '1' then
            CLUT_ST(conv_integer(FB_ADR(4 downto 1)))(11 downto 8) <= FB_AD_IN(27 downto 24);
        end if;
        if CLUT_ST_WR(1) = '1' then
            CLUT_ST(conv_integer(FB_ADR(4 downto 1)))(7 downto 0) <= FB_AD_IN(23 downto 16);
        end if;
        --
        if CLUT_FA_WR(0) = '1' then
            CLUT_FA(conv_integer(FB_ADR(9 downto 2)))(17 downto 12) <= FB_AD_IN(31 downto 26);
        end if;
        if CLUT_FA_WR(1) = '1' then
            CLUT_FA(conv_integer(FB_ADR(9 downto 2)))(11 downto 6) <= FB_AD_IN(23 downto 18);
        end if;
        if CLUT_FA_WR(3) = '1' then
            CLUT_FA(conv_integer(FB_ADR(9 downto 2)))(5 downto 0) <= FB_AD_IN(23 downto 18);
        end if;
        --
        if CLUT_FBEE_WR(1) = '1' then
            CLUT_FI(conv_integer(FB_ADR(9 downto 2)))(23 downto 16) <= FB_AD_IN(23 downto 16);
        end if;
        if CLUT_FBEE_WR(2) = '1' then
            CLUT_FI(conv_integer(FB_ADR(9 downto 2)))(15 downto 8) <= FB_AD_IN(15 downto 8);
        end if;
        if CLUT_FBEE_WR(3) = '1' then
            CLUT_FI(conv_integer(FB_ADR(9 downto 2)))(7 downto 0) <= FB_AD_IN(7 downto 0);
        end if;
        --
        CLUT_ST_OUT <= CLUT_ST(conv_integer(FB_ADR(4 downto 1)));
        CLUT_FA_OUT <= CLUT_FA(conv_integer(FB_ADR(9 downto 2)));
        CLUT_FBEE_OUT <= CLUT_FI(conv_integer(FB_ADR(9 downto 2)));
    end process P_CLUT_ST_MC;

    P_CLUT_ST_PX: process
    -- This is the dual ported ram for the ST colour lookup tables.
    begin
        wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
        CLUT_ST_R <= CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(8) & CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(11 downto 9);
        CLUT_ST_G <= CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(4) & CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(7 downto 5);
        CLUT_ST_B <= CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(0) & CLUT_ST(conv_integer(CLUT_ADR(3 downto 0)))(3 downto 1);
        CLUT_FA_R <= CLUT_FA(conv_integer(CLUT_ADR))(17 downto 12);
        CLUT_FA_G <= CLUT_FA(conv_integer(CLUT_ADR))(11 downto 6);
        CLUT_FA_B <= CLUT_FA(conv_integer(CLUT_ADR))(5 downto 0);
        CLUT_FBEE_R <= CLUT_FI(conv_integer(ZR_C8))(23 downto 16);
        CLUT_FBEE_G <= CLUT_FI(conv_integer(ZR_C8))(15 downto 8);
        CLUT_FBEE_B <= CLUT_FI(conv_integer(ZR_C8))(7 downto 0);
    end process P_CLUT_ST_PX;

    P_VIDEO_OUT: process
    variable VIDEO_OUT  : std_logic_vector(23 downto 0);
    begin
        wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
        case CC_SEL is
            when "111" => VIDEO_OUT := CCR; -- Register type video.
            when "110" => VIDEO_OUT := CC_24(23 downto 0); -- 3 byte FIFO type video.
            when "101" => VIDEO_OUT := CC_16; -- 2 byte FIFO type video.
            when "100" => VIDEO_OUT := CLUT_FBEE_R & CLUT_FBEE_G & CLUT_FBEE_B; -- Firebee type video.
            when "001" => VIDEO_OUT := CLUT_FA_R & "00" & CLUT_FA_G & "00" & CLUT_FA_B & "00"; -- Falcon type video.
            when "000" => VIDEO_OUT := CLUT_ST_R & x"0" & CLUT_ST_G & x"0" & CLUT_ST_B & x"0"; -- ST type video.
            when others => VIDEO_OUT := (others => '0');
        end case;
        RED <= VIDEO_OUT(23 downto 16);
        GREEN <= VIDEO_OUT(15 downto 8);
        BLUE <= VIDEO_OUT(7 downto 0);
    end process P_VIDEO_OUT;

    P_CC: process
    variable CC24_I : std_logic_vector(31 downto 0);
    variable CC_I   : std_logic_vector(15 downto 0);
    variable ZR_C8_I   : std_logic_vector(7 downto 0);
    begin
        wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
            case CLUT_ADR_MUX(1 downto 0) is
                when "11" => CC24_I := FIFO_D(31 downto 0);
                when "10" => CC24_I := FIFO_D(63 downto 32);
                when "01" => CC24_I := FIFO_D(95 downto 64);
                when "00" => CC24_I := FIFO_D(127 downto 96);
            end case;
            --
            CC_24 <= CC24_I;
            --
            case CLUT_ADR_MUX(2 downto 0) is
                when "111" => CC_I := FIFO_D(15 downto 0);
                when "110" => CC_I := FIFO_D(31 downto 16);
                when "101" => CC_I := FIFO_D(47 downto 32);
                when "100" => CC_I := FIFO_D(63 downto 48);
                when "011" => CC_I := FIFO_D(79 downto 64);
                when "010" => CC_I := FIFO_D(95 downto 80);
                when "001" => CC_I := FIFO_D(111 downto 96);
                when "000" => CC_I := FIFO_D(127 downto 112);
            end case;
            --
            CC_16 <= CC_I(15 downto 11) & "000" & CC_I(10 downto 5) & "00" & CC_I(4 downto 0) & "000";
            --
            case CLUT_ADR_MUX(3 downto 0) is
                when x"F" => ZR_C8_I := FIFO_D(7 downto 0);
                when x"E" => ZR_C8_I := FIFO_D(15 downto 8);
                when x"D" => ZR_C8_I := FIFO_D(23 downto 16);
                when x"C" => ZR_C8_I := FIFO_D(31 downto 24);
                when x"B" => ZR_C8_I := FIFO_D(39 downto 32);
                when x"A" => ZR_C8_I := FIFO_D(47 downto 40);
                when x"9" => ZR_C8_I := FIFO_D(55 downto 48);
                when x"8" => ZR_C8_I := FIFO_D(63 downto 56);
                when x"7" => ZR_C8_I := FIFO_D(71 downto 64);
                when x"6" => ZR_C8_I := FIFO_D(79 downto 72);
                when x"5" => ZR_C8_I := FIFO_D(87 downto 80);
                when x"4" => ZR_C8_I := FIFO_D(95 downto 88);
                when x"3" => ZR_C8_I := FIFO_D(103 downto 96);
                when x"2" => ZR_C8_I := FIFO_D(111 downto 104);
                when x"1" => ZR_C8_I := FIFO_D(119 downto 112);
                when x"0" => ZR_C8_I := FIFO_D(127 downto 120);
            end case;
            --
            case COLOR1 is
                when '1' => ZR_C8 <= ZR_C8_I;
                when others => ZR_C8 <= "0000000" & ZR_C8_I(0); 
            end case;
    end process P_CC;

    CLUT_SHIFT_IN <= CLUT_ADR_A(6 downto 1) when COLOR4 = '0' and COLOR2 = '0' else
                     CLUT_ADR_A(7 downto 2) when COLOR4 = '0' and COLOR2 = '1' else
                     "00" & CLUT_ADR_A(7 downto 4) when COLOR4 = '1' and COLOR2 = '0' else "000000";

    FIFO_RD_REQ_128 <= '1' when FIFO_RDE = '1' and INTER_ZEI = '1' else '0';
    FIFO_RD_REQ_512 <= '1' when FIFO_RDE = '1' and INTER_ZEI = '0' else '0';

    FIFO_DMUX: process
    begin
        wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
        if FIFO_RDE = '1' and INTER_ZEI = '1' then
            FIFO_D <= FIFO_D_OUT_128;
        elsif FIFO_RDE = '1' then
            FIFO_D <= FIFO_D_OUT_512;
        end if;
    end process FIFO_DMUX;

    CLUT_SHIFTREGS: process
    variable CLUT_SHIFTREG   : CLUT_SHIFTREG_TYPE;
    begin
        wait until CLK_PIXEL_I = '1' and CLK_PIXEL_I' event;
        CLUT_SHIFT_LOAD <= FIFO_RDE;
        if CLUT_SHIFT_LOAD = '1' then
            for i in 0 to 7 loop
                CLUT_SHIFTREG(7 - i) := FIFO_D((i+1)*16 -1 downto i*16);
            end loop;
        else
            CLUT_SHIFTREG(7) := CLUT_SHIFTREG(7)(14 downto 0) & CLUT_ADR_A(0);
            CLUT_SHIFTREG(6) := CLUT_SHIFTREG(6)(14 downto 0) & CLUT_ADR_A(7);
            CLUT_SHIFTREG(5) := CLUT_SHIFTREG(5)(14 downto 0) & CLUT_SHIFT_IN(5);
            CLUT_SHIFTREG(4) := CLUT_SHIFTREG(4)(14 downto 0) & CLUT_SHIFT_IN(4);
            CLUT_SHIFTREG(3) := CLUT_SHIFTREG(3)(14 downto 0) & CLUT_SHIFT_IN(3);
            CLUT_SHIFTREG(2) := CLUT_SHIFTREG(2)(14 downto 0) & CLUT_SHIFT_IN(2);
            CLUT_SHIFTREG(1) := CLUT_SHIFTREG(1)(14 downto 0) & CLUT_SHIFT_IN(1);
            CLUT_SHIFTREG(0) := CLUT_SHIFTREG(0)(14 downto 0) & CLUT_SHIFT_IN(0);
        end if;
        --
        for i in 0 to 7 loop
            CLUT_ADR_A(i) <= CLUT_SHIFTREG(i)(15);
        end loop;
    end process CLUT_SHIFTREGS;

    CLUT_ADR(7) <= CLUT_OFF(3) or (CLUT_ADR_A(7) and COLOR8);
    CLUT_ADR(6) <= CLUT_OFF(2) or (CLUT_ADR_A(6) and COLOR8);
    CLUT_ADR(5) <= CLUT_OFF(1) or (CLUT_ADR_A(5) and COLOR8);
    CLUT_ADR(4) <= CLUT_OFF(0) or (CLUT_ADR_A(4) and COLOR8);
    CLUT_ADR(3) <= CLUT_ADR_A(3) and (COLOR8 or COLOR4);
    CLUT_ADR(2) <= CLUT_ADR_A(2) and (COLOR8 or COLOR4);
    CLUT_ADR(1) <= CLUT_ADR_A(1) and (COLOR8 or COLOR4 or COLOR2);
    CLUT_ADR(0) <= CLUT_ADR_A(0);
    
    FB_AD_OUT <= x"0" & CLUT_ST_OUT & x"0000" when CLUT_ST_RD = '1' else
                 CLUT_FA_OUT(17 downto 12) & "00" & CLUT_FA_OUT(11 downto 6) & "00" & x"0000" when CLUT_FA_RDH = '1' else
                 x"00" & CLUT_FA_OUT(5 downto 0) & "00" & x"0000" when CLUT_FA_RDL = '1' else
                 x"00" & CLUT_FBEE_OUT when CLUT_FBEE_RD = '1' else 
                 DATA_OUT_VIDEO_CTRL when DATA_EN_H_VIDEO_CTRL = '1' else -- Use upper word.
                 DATA_OUT_VIDEO_CTRL when DATA_EN_L_VIDEO_CTRL = '1' else (others => '0'); -- Use lower word.

    FB_AD_EN_31_16 <= '1' when CLUT_FBEE_RD = '1' else
                      '1' when CLUT_FA_RDH = '1' else
                      '1' when DATA_EN_H_VIDEO_CTRL = '1' else '0';
                
    FB_AD_EN_15_0 <= '1' when CLUT_FBEE_RD = '1' else
                     '1' when CLUT_FA_RDL = '1' else
                     '1' when DATA_EN_L_VIDEO_CTRL = '1' else '0';
    
    VD_VZ <= VD_VZ_I;
    
    DFF_CLK0: process
    begin
        wait until CLK_DDR0 = '1' and CLK_DDR0' event;
        VD_VZ_I <= VD_VZ_I(63 downto 0) & VDP_IN(63 downto 0);
        --
        if FIFO_WRE = '1' then
            VDM_A <= VD_VZ_I;
            VDM_B <= VDM_A;
        end if;
    end process DFF_CLK0;

    DFF_CLK2: process
    begin
        wait until CLK_DDR2 = '1' and CLK_DDR2' event;
        VDMP <= SR_VDMP;
    end process DFF_CLK2;

    DFF_CLK3: process
    begin
        wait until CLK_DDR3 = '1' and CLK_DDR3' event;
        VDMP_I <= VDMP;
    end process DFF_CLK3;

    VDM <= VDMP_I(7 downto 4) when CLK_DDR3 = '1' else VDMP_I(3 downto 0);
    
    SHIFT_CLK0: process
    variable TMP : std_logic_vector(4 downto 0);
    begin
        wait until CLK_DDR0 = '1' and CLK_DDR0' event;
        TMP := SR_FIFO_WRE & TMP(4 downto 1);
        FIFO_WRE <= TMP(0);
    end process SHIFT_CLK0;

    with VDM_SEL select
        VDM_C <=  VDM_B when x"0",
                    VDM_B(119 downto 0) & VDM_A(127 downto 120) when x"1",
                    VDM_B(111 downto 0) & VDM_A(127 downto 112) when x"2",
                    VDM_B(103 downto 0) & VDM_A(127 downto 104) when x"3",
                    VDM_B(95 downto 0) & VDM_A(127 downto 96) when x"4",
                    VDM_B(87 downto 0) & VDM_A(127 downto 88) when x"5",
                    VDM_B(79 downto 0) & VDM_A(127 downto 80) when x"6",
                    VDM_B(71 downto 0) & VDM_A(127 downto 72) when x"7",
                    VDM_B(63 downto 0) & VDM_A(127 downto 64) when x"8",
                    VDM_B(55 downto 0) & VDM_A(127 downto 56) when x"9",
                    VDM_B(47 downto 0) & VDM_A(127 downto 48) when x"A",
                    VDM_B(39 downto 0) & VDM_A(127 downto 40) when x"B",
                    VDM_B(31 downto 0) & VDM_A(127 downto 32) when x"C",
                    VDM_B(23 downto 0) & VDM_A(127 downto 24) when x"D",
                    VDM_B(15 downto 0) & VDM_A(127 downto 16) when x"E",
                    VDM_B(7 downto 0) & VDM_A(127 downto 8) when x"F";

    I_FIFO_DC0: lpm_fifo_dc0
        port map(
            aclr        => FIFO_CLR_I,  
            data        => VDM_C,
            rdclk       => CLK_PIXEL_I,
            rdreq       => FIFO_RD_REQ_512,
            wrclk       => CLK_DDR0,
            wrreq       => FIFO_WRE,
            q           => FIFO_D_OUT_512,
            --rdempty   =>, -- Not used.
            wrusedw     => FIFO_MW
        );

    I_FIFO_DZ: lpm_fifoDZ
        port map(
            aclr        => DOP_FIFO_CLR,
            clock       => CLK_PIXEL_I,
            data        => FIFO_D_OUT_512,
            rdreq       => FIFO_RD_REQ_128,
            wrreq       => FIFO_RD_REQ_512,
            q           => FIFO_D_OUT_128
        );

    I_VIDEO_CTRL: VIDEO_CTRL
        port map(
            CLK_MAIN            => CLK_MAIN,
            FB_CSn(1)           => FB_CSn(1),
            FB_CSn(2)           => FB_CSn(2),
            FB_WRn              => FB_WRn,
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
end architecture;
