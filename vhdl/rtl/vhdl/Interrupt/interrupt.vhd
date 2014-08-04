----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the interruptlogic of the 'Firebee'----
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
-- use ieee.std_logic_arith.all;

entity INTHANDLER is
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
end entity INTHANDLER;

architecture BEHAVIOUR of INTHANDLER is
type INT_LA_TYPE is array(9 downto 0) of std_logic_vector(3 downto 0);
signal INT_LA                  : INT_LA_TYPE;
signal FB_B                    : std_logic_vector(3 downto 0);
signal INT_CTR                 : std_logic_vector(31 downto 0);
signal INT_CTR_CS              : std_logic;
signal INT_LATCH               : std_logic_vector(31 downto 0);
signal INT_LATCH_CS            : std_logic;
signal INT_CLEAR               : std_logic_vector(31 downto 0);
signal INT_CLEAR_CS            : std_logic;
signal INT_IN                  : std_logic_vector(31 downto 0);
signal INT_ENA                 : std_logic_vector(31 downto 0);
signal INT_ENA_CS              : std_logic;
signal INT_L                   : std_logic_vector(9 downto 0);
signal FBEE_CONF_REG           : std_logic_vector(31 downto 0);
signal FBEE_CONF_CS            : std_logic;
signal PSEUDO_BUS_ERROR        : std_logic;
begin
    -- Byte selectors:
    FB_B(0) <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '0' else -- High word.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "00" else -- HH Byte.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
               '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.

    FB_B(1) <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '0' else -- High word.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "01" else -- HL Byte.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
               '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.
             
    FB_B(2) <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '1' else -- Low word.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "10" else -- LH Byte.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
               '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.
             
    FB_B(3) <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '1' else -- Low word.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "11" else -- LL Byte.
               '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
               '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.

    INT_CTR_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000100000000000000" else '0'; -- $10000/4;
    INT_ENA_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000100000000000001" else '0'; -- $10004/4;
    INT_CLEAR_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000100000000000010" else '0'; -- $10008/4;
    INT_LATCH_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000000000100000000000011" else '0'; -- $1000C/4;

    P_INT_CTRL  : process
    -- Interrupt control register:
    --BIT0 = INT5, Bit1 = INT7.
    -- Interrupt enabe register:
    -- BIT31 = INT7, Bit30 = INT6, Bit29 = INT5, Bit28 = INT4, Bit27 = INT3, Bit26 = INT2
    -- The interrupt clear register is write only; 1 = interrupt clear.
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if INT_CTR_CS = '1' and FB_B(0) = '1' and FB_WRn = '0' then
            INT_CTR(31 downto 24) <= FB_AD_IN(31 downto 24);
        elsif INT_CTR_CS = '1' and FB_B(1) = '1' and FB_WRn = '0' then
            INT_CTR(23 downto 16) <= FB_AD_IN(23 downto 16);
        elsif INT_CTR_CS = '1' and FB_B(2) = '1' and FB_WRn = '0' then
            INT_CTR(15 downto 8) <= FB_AD_IN(15 downto 8);
        elsif INT_CTR_CS = '1' and FB_B(3) = '1' and FB_WRn = '0' then
            INT_CTR(7 downto 0) <= FB_AD_IN(7 downto 0);
        end if;
        --
        if RESETn = '0' then
            INT_ENA <= (others => '0');
        elsif INT_ENA_CS = '1' and FB_B(0) = '1' and FB_WRn = '0' then
            INT_ENA(31 downto 24) <= FB_AD_IN(31 downto 24);
        elsif INT_ENA_CS = '1' and FB_B(1) = '1' and FB_WRn = '0' then
            INT_ENA(23 downto 16) <= FB_AD_IN(23 downto 16);
        elsif INT_ENA_CS = '1' and FB_B(2) = '1' and FB_WRn = '0' then
            INT_ENA(15 downto 8) <= FB_AD_IN(15 downto 8);
        elsif INT_ENA_CS = '1' and FB_B(3) = '1' and FB_WRn = '0' then
            INT_ENA(7 downto 0) <= FB_AD_IN(7 downto 0);
        end if;
        --
        if INT_CLEAR_CS = '1' and FB_B(0) = '1' and FB_WRn = '0' then
            INT_CLEAR(31 downto 24) <= FB_AD_IN(31 downto 24);
        elsif INT_CLEAR_CS = '1' and FB_B(1) = '1' and FB_WRn = '0' then
            INT_CLEAR(23 downto 16) <= FB_AD_IN(23 downto 16);
        elsif INT_CLEAR_CS = '1' and FB_B(2) = '1' and FB_WRn = '0' then
            INT_CLEAR(15 downto 8) <= FB_AD_IN(15 downto 8);
        elsif INT_CLEAR_CS = '1' and FB_B(3) = '1' and FB_WRn = '0' then
            INT_CLEAR(7 downto 0) <= FB_AD_IN(7 downto 0);
        end if;
    end process P_INT_CTRL;

    -- Interrupt latch register: read only.
    IRQn(2) <= '0' when HSYNC = '1' and INT_ENA(26) = '1' else '1';
    IRQn(3) <= '0' when INT_CTR(0) = '1' and INT_ENA(27) = '1' else '1';
    IRQn(4) <= '0' when VSYNC = '1' and INT_ENA(28) = '1' else '1';
    IRQn(5) <= '0' when INT_LATCH /= x"00000000" and INT_ENA(29) = '1' else '1';
    IRQn(6) <= '0' when MFP_INTn = '0' and INT_ENA(30) = '1' else '1';
    IRQn(7) <= '0' when PSEUDO_BUS_ERROR = '1' and INT_ENA(31) = '1' else '1';

    PSEUDO_BUS_ERROR <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F8C8" else -- SCC
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F8E0" else -- VME
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F920" else -- PADDLE
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F921" else -- PADDLE
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F922" else -- PADDLE
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFA8" else -- MFP2
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFA9" else -- MFP2
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFAA" else -- MFP2
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFA8" else -- MFP2
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 8) = x"F87" else -- TT SCSI
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFC2" else -- ST UHR
                        '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"FFC3" else '0'; -- ST UHR
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F890" else -- DMA SOUND
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F891" else -- DMA SOUND
    --                  '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 4) = x"F892" else '0'; -- DMA SOUND

    -- IF video ADR changes:
    TIN0 <= '1' when FB_CSn(1) = '0' and FB_WRn = '0' and FB_ADR(19 downto 1) = x"7C100" else '0'; -- Write video base address high 0xFFFF8201/2.

    P_INT_LATCH  : process
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if RESETn = '0' then
            INT_L <= (others => '0');
        else
            INT_L(0) <= PIC_INT and INT_ENA(0);
            INT_L(1) <= E0_INT and INT_ENA(1);
            INT_L(2) <= DVI_INT and INT_ENA(2);
            INT_L(3) <= not PCI_INTAn and INT_ENA(3);
            INT_L(4) <= not PCI_INTBn and INT_ENA(4);
            INT_L(5) <= not PCI_INTCn and INT_ENA(5);
            INT_L(6) <= not PCI_INTDn and INT_ENA(6);
            INT_L(7) <= DSP_INT and INT_ENA(7);
            INT_L(8) <= VSYNC and INT_ENA(8);
            INT_L(9) <= HSYNC and INT_ENA(9);
        end if;
        
        for i in 0 to 9 loop
            if INT_ENA(i) = '1' and RESETn = '1' then
                INT_LA(i) <= x"0";
            elsif INT_L(i) = '1' and INT_LA(i) < x"7" then
                INT_LA(i) <= std_logic_vector(unsigned(INT_LA(i)) + 1);
            elsif INT_L(i) = '0' and INT_LA(i) > x"8" then
                INT_LA(i) <= std_logic_vector(unsigned(INT_LA(i)) - 1);
            elsif INT_L(i) = '1' and INT_LA(i) > x"6" then
                INT_LA(i) <= x"F";
            elsif INT_L(i) = '0' and INT_LA(i) > x"9" then
                INT_LA(i) <= x"0";
            end if;
        end loop;
        
        for i in 0 to 31 loop
            if INT_CLEAR(i) = '0' and RESETn = '1' then
                INT_LATCH(i) <= '0';
            end if;
        end loop;

        for i in 0 to 9 loop
            if INT_LA(i)(3) = '1' then
                INT_LATCH(i) <= '1';
            end if;
        end loop;
    end process P_INT_LATCH;

    -- INT_IN:
    INT_IN(0) <= PIC_INT;
    INT_IN(1) <= E0_INT;
    INT_IN(2) <= DVI_INT;
    INT_IN(3) <= not PCI_INTAn;
    INT_IN(4) <= not PCI_INTBn;
    INT_IN(5) <= not PCI_INTCn;
    INT_IN(6) <= not PCI_INTDn;
    INT_IN(7) <= DSP_INT;
    INT_IN(8) <= VSYNC;
    INT_IN(9) <= HSYNC;
    INT_IN(25 downto 10) <= x"0000";
    INT_IN(26) <= HSYNC; 
    INT_IN(27) <= INT_CTR(0); 
    INT_IN(28) <= VSYNC; 
    INT_IN(29) <= '1' when INT_LATCH /= x"00000000";
    INT_IN(30) <= not MFP_INTn; 
    INT_IN(31) <= DRQ_DMA; 

    FBEE_CONF_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(27 downto 2) = "00000001000000000000000000" else '0'; -- $40000/4.
    
    P_FBEE_CONFIG : process
    -- Firebee configuration register: BIT 31 -> 0 = CF 1 = IDE 
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if FBEE_CONF_CS = '1' and FB_B(0) = '1' and FB_WRn = '0' then
            FBEE_CONF_REG(31 downto 24) <= FB_AD_IN(31 downto 24);
        elsif FBEE_CONF_CS = '1' and FB_B(1) = '1' and FB_WRn = '0' then
            FBEE_CONF_REG(23 downto 16) <= FB_AD_IN(23 downto 16);
        elsif FBEE_CONF_CS = '1' and FB_B(2) = '1' and FB_WRn = '0' then
            FBEE_CONF_REG(15 downto 8) <= FB_AD_IN(15 downto 8);
        elsif FBEE_CONF_CS = '1' and FB_B(3) = '1' and FB_WRn = '0' then
            FBEE_CONF_REG(7 downto 0) <= FB_AD_IN(7 downto 0);
        end if;
        FBEE_CONF <= FBEE_CONF_REG;
    end process P_FBEE_CONFIG;
    
    -- Data out multiplexers:
    FB_AD_EN_31_24 <= (INT_CTR_CS or INT_ENA_CS or INT_LATCH_CS or INT_CLEAR_CS or FBEE_CONF_CS) and not FB_OEn;
    FB_AD_EN_23_16 <= (INT_CTR_CS or INT_ENA_CS or INT_LATCH_CS or INT_CLEAR_CS or FBEE_CONF_CS) and not FB_OEn;
    FB_AD_EN_15_8 <= (INT_CTR_CS or INT_ENA_CS or INT_LATCH_CS or INT_CLEAR_CS or FBEE_CONF_CS)  and not FB_OEn;
    FB_AD_EN_7_0 <= (INT_CTR_CS or INT_ENA_CS or INT_LATCH_CS or INT_CLEAR_CS or FBEE_CONF_CS) and not FB_OEn;

    FB_AD_OUT(31 downto 24) <= INT_CTR(31 downto 24) when INT_CTR_CS = '1' else
                               INT_ENA(31 downto 24) when INT_ENA_CS = '1' else
                               INT_LATCH(31 downto 24) when INT_LATCH_CS = '1' else
                               INT_IN(31 downto 24) when INT_CLEAR_CS = '1' else FBEE_CONF_REG(31 downto 24);

    FB_AD_OUT(23 downto 16) <= INT_CTR(23 downto 16) when INT_CTR_CS = '1' else
                               INT_ENA(23 downto 16) when INT_ENA_CS = '1' else
                               INT_LATCH(23 downto 16) when INT_LATCH_CS = '1' else
                               INT_IN(23 downto 16) when INT_CLEAR_CS = '1' else FBEE_CONF_REG(23 downto 16);

    FB_AD_OUT(15 downto 8) <= INT_CTR(15 downto 8) when INT_CTR_CS = '1' else
                              INT_ENA(15 downto 8) when INT_ENA_CS = '1' else
                              INT_LATCH(15 downto 8) when INT_LATCH_CS = '1' else
                              INT_CLEAR(15 downto 8) when INT_CLEAR_CS = '1' else FBEE_CONF_REG(15 downto 8);
                              
    FB_AD_OUT(7 downto 0) <= INT_CTR(7 downto 0) when INT_CTR_CS = '1' else
                              INT_ENA(7 downto 0) when INT_ENA_CS = '1' else
                              INT_LATCH(7 downto 0) when INT_LATCH_CS = '1' else
                              INT_CLEAR(7 downto 0) when INT_CLEAR_CS = '1' else FBEE_CONF_REG(7 downto 0);

    INT_HANDLER_TA <= INT_CTR_CS or INT_ENA_CS or INT_LATCH_CS or INT_CLEAR_CS;
end architecture BEHAVIOUR;
