----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the RTC logic for the 'Firebee'    ----
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity RTC is
	port(
		CLK_MAIN        : in std_logic;
		FB_ADR          : in std_logic_vector(19 downto 0);
		FB_CS1n         : in std_logic;
		FB_SIZE0        : in std_logic;
		FB_SIZE1        : in std_logic;
		FB_WRn          : in std_logic;
		fb_oe_n          : in std_logic;
		FB_AD_IN        : in std_logic_vector(23 downto 16);
		FB_AD_OUT       : out std_logic_vector(23 downto 16);
		FB_AD_EN_23_16  : out std_logic;
		PIC_INT         : in std_logic
	);
end entity RTC;

architecture BEHAVIOUR of RTC is
	type VALUES_TYPE is array(63 downto 0) of std_logic_vector(7 downto 0);
	signal VALUES                   : VALUES_TYPE;
	signal FB_B1                    : std_logic;
	signal FB_B3                    : std_logic;
	signal UHR_AS                   : std_logic;
	signal UHR_DS                   : std_logic;
	signal RTC_ADR                  : std_logic_vector(5 downto 0);
	signal EIGHTHs_OF_SECOND        : std_logic_vector(2 downto 0);
	signal PIC_INT_SYNC             : std_logic_vector(2 downto 0);
	signal INC_SEC                  : std_logic;
	signal INC_MIN                  : std_logic;
	signal INC_HOUR                 : std_logic;
	signal INC_DAY                  : std_logic;
	signal DAYs_PER_MONTH           : std_logic_vector(7 downto 0);
	signal WINTERTIME               : std_logic;
	signal SUMMERTIME               : std_logic;
	signal INC_MONAT                : std_logic;
	signal INC_JAHR                 : std_logic;
	signal UPDATE_ON                : std_logic;
begin
    -- Byte selectors:
    FB_B1 <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '0' else -- High word.
             '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "01" else -- HL Byte.
             '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
             '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.
             
    FB_B3 <= '1' when FB_SIZE1 = '1' and FB_SIZE0 = '0' and FB_ADR(1) = '1' else -- Low word.
             '1' when FB_SIZE1 = '0' and FB_SIZE0 = '1' and FB_ADR(1 downto 0) = "11" else -- LL Byte.
             '1' when FB_SIZE1 = '0' and FB_SIZE0 = '0' else -- Long.
             '1' when FB_SIZE1 = '1' and FB_SIZE0 = '1' else '0';-- Line.

    UHR_AS <= '1' when FB_B1 = '1' and FB_CS1n = '0' and FB_ADR(19 downto 1) = x"7C4B0" else '0'; -- $FFFF8961.
    UHR_DS <= '1' when FB_B3 = '1' and FB_CS1n = '0' and FB_ADR(19 downto 1) = x"7C4B1" else '0'; -- $FFFF8963.

    UPDATE_ON <= not VALUES(11)(7);  -- UPDATE ON OFF

    INC_SEC <= '1' when EIGHTHs_OF_SECOND = 7 and PIC_INT_SYNC(2) = '1' and UPDATE_ON = '1' else '0';
    INC_MIN <= '1' when INC_SEC = '1' and VALUES(0) = x"3B" else '0'; -- 59.
    INC_HOUR <= '1' when INC_MIN = '1' and VALUES(2) = x"3B" else '0'; -- 59.
    INC_DAY <= '1' when INC_HOUR = '1' and VALUES(2) = x"17" else '0'; -- 23.
    INC_MONAT <= '1' when INC_DAY = '1' and VALUES(7) = DAYs_PER_MONTH else '0';
    INC_JAHR <= '1' when INC_MONAT = '1' and VALUES(8) = x"C" else '0'; -- 12.
    
    DAYs_PER_MONTH <= x"1F" when VALUES(8) = x"01" or VALUES(8) = x"03" or VALUES(8) = x"05" or VALUES(8) = x"07" or VALUES(8) = x"08" or VALUES(8) = x"0A" or VALUES(8) = x"0C" else
                      x"1E" when VALUES(8) = x"04" or VALUES(8) = x"06" or VALUES(8) = x"09" or VALUES(8) = x"0B" else
                      x"1D" when VALUES(8) = x"02" and VALUES(9)(1 downto 0) = x"00" else x"1C";  

    P_1287  : process
    -- C1287: 0 = SEK 2 = MIN 4 = STD 6 = WOCHENTAG 7 = TAG 8 = MONAT 9 = JAHR
    variable ADRVAR : std_logic_vector(5 downto 0);
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if UHR_AS = '1' and FB_WRn = '0' then
            RTC_ADR <= FB_AD_IN(21 downto 16);
        end if;

        for i in 0 to 63 loop
            ADRVAR := conv_std_logic_vector(i,6);
            if RTC_ADR = ADRVAR and UHR_DS = '1' and FB_WRn = '0' then
                VALUES(i) <= FB_AD_IN(23 downto 16);
            end if;
        end loop;

        PIC_INT_SYNC(0) <= PIC_INT;
        PIC_INT_SYNC(1) <= PIC_INT_SYNC(0);
        PIC_INT_SYNC(2) <= not PIC_INT_SYNC(1) and PIC_INT_SYNC(0);

        VALUES(10)(6) <= '0'; -- No UIP.
        VALUES(11)(2) <= '1'; -- Always binary.
        VALUES(11)(1) <= '1'; -- Always 24h format.
        VALUES(11)(0) <= '1'; -- Always correction of summertime.
        VALUES(13)(7) <= '1'; -- Always true.

        -- Summer- wintertime: bit 0 in the register D provides information wether there is summer- or wintertime.
        if VALUES(6)= x"01" and VALUES(4) = x"01" and VALUES(8) = x"04" and VALUES(7) > x"17" then -- Last Sunday in April.
            SUMMERTIME <= '1';
        else
            SUMMERTIME <= '0';
        end if;

        if VALUES(6)= x"01" and VALUES(4) = x"01" and VALUES(8) = x"0A" and VALUES(7) > x"18" then  -- Last Sunday in October.
            WINTERTIME <= '1';
        else
            WINTERTIME <= '0';
        end if;

        if INC_HOUR = '1' and (SUMMERTIME or WINTERTIME) = '1' then
            VALUES(13)(0) <= SUMMERTIME;
        end if;

        -- Eighths of a second:
        if PIC_INT_SYNC(2) = '1' and UPDATE_ON = '1' then
            EIGHTHs_OF_SECOND <= EIGHTHs_OF_SECOND + '1';
        end if;
        
        -- Seconds:
        if INC_SEC = '1' and (RTC_ADR /= "000000" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(0) = x"3B" then -- 59.
                VALUES(0) <= (others => '0');
            else
                VALUES(0) <= VALUES(0) + '1';
            end if;
        end if;

        -- Minutes:
        if INC_MIN = '1' and (RTC_ADR /= "000010" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(2) = x"3B" then -- 59.
                VALUES(2) <= (others => '0');
            else
                VALUES(2) <= VALUES(2) + '1';
            end if;
        end if;

        -- Hours:
        if INC_HOUR = '1' and (WINTERTIME = '0' or VALUES(12)(0) = '0') and (RTC_ADR /= "000100" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(4) = x"17" then -- 23.
                VALUES(4) <= (others => '0');
            elsif SUMMERTIME = '1' then
                VALUES(4) <= VALUES(4) + "10";
            else
                VALUES(4) <= VALUES(4) + '1';
            end if;
        end if;

        -- Day and day of the week: 
        if INC_DAY = '1' and (RTC_ADR /= "000110" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(6) = x"07" then
                VALUES(6) <= x"01";
            else
                VALUES(6) <= VALUES(6) + '1';
            end if;
        end if;

        if INC_DAY = '1' and (RTC_ADR /= "000111" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(7) = DAYs_PER_MONTH then
                VALUES(7) <= x"01";
            else
                VALUES(7) <= VALUES(7) + '1';
            end if;
        end if;

        -- Month:
        if INC_MONAT = '1' and (RTC_ADR /= "001000" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(8) = x"0C" then
                VALUES(8) <= x"01";
            else
                VALUES(8) <= VALUES(8) + '1';
            end if;
        end if;

        -- Year:
        if INC_JAHR = '1' and (RTC_ADR /= "001001" or UHR_DS = '0' or FB_WRn = '1') then
            if VALUES(9) = x"63" then -- 99.
                VALUES(9) <= (others => '0');
            else
                VALUES(9) <= VALUES(9) + '1';
            end if;
        end if;
    end process P_1287;
    
    -- Data out multiplexers:
    FB_AD_EN_23_16 <= (UHR_DS or UHR_AS) and not fb_oe_n;

    FB_AD_OUT(23 downto 16) <= VALUES(conv_integer(RTC_ADR)) when UHR_DS = '1' else
                               "00" & RTC_ADR when UHR_AS = '1' else x"00";
end architecture BEHAVIOUR;
