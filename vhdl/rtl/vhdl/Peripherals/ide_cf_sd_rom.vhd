----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides peripheral logic for the 'Firebee' ----
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

entity IDE_CF_SD_ROM is
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
end entity IDE_CF_SD_ROM;

architecture BEHAVIOUR of IDE_CF_SD_ROM is
	type CMD_STATES is (IDLE, T1, T6, T7);
	
	signal CMD_STATE				: CMD_STATES;
	signal NEXT_CMD_STATE		: CMD_STATES;
	signal ROM_CS					: STD_LOGIC;
	signal IDE_CF_CS				: std_logic;
	signal NEXT_IDE_RDn			: std_logic;
	signal NEXT_IDE_WRn			: std_logic;
begin
	ROM_CS <= '1' when FB_CS1n = '0' and FB_WRn = '1' and FB_ADR(19 downto 17) = "101" else '0'; -- FFF A'0000/2'0000

    RP_UDSn <= '0' when FB_WRn = '1' and FB_B0 = '1' and (ROM_CS = '1' or IDE_CF_CS = '1' or IDE_WRn = '0') else '1'; 
    RP_LDSn <= '0' when FB_WRn = '1' and FB_B1 = '1' and (ROM_CS = '1' or IDE_CF_CS = '1' or IDE_WRn = '0') else '1'; 

    IDE_CF_CS <= '1' when FB_CS1n = '0' and FB_ADR(19 downto 7) = x"0" else '0'; -- FFF0'0000/80

    IDE_CSn(0) <= '0' when FBEE_CONF(30) = '0' and FB_ADR(19 downto 5) = x"2" else -- FFF0'0040-FFF0'005F 
                  '0' when FBEE_CONF(30) = '1' and FB_ADR(19 downto 5) = x"0" else '1'; -- FFFO'0000-FFF0'001F
    IDE_CSn(1) <= '0' when FBEE_CONF(30) = '0' and FB_ADR(19 downto 5) = x"3" else -- FFF0'0060-FFF0'007F 
                  '0' when FBEE_CONF(30) = '1' and FB_ADR(19 downto 5) = x"1" else '1'; -- FFFO'0020-FFF0'003F

    CF_CSn(0) <= '0' when FBEE_CONF(31) = '0' and FB_ADR(19 downto 5) = x"0" else -- FFFO'0000-FFF0'001F
                 '0' when FBEE_CONF(31) = '1' and FB_ADR(19 downto 5) = x"2" else '1'; -- FFFO'0040-FFF0'005F
    CF_CSn(1) <= '0' when FBEE_CONF(31) = '0' and FB_ADR(19 downto 5) = x"1" else -- FFF0'0020-FFF0'003F
                 '0' when FBEE_CONF(31) = '1' and FB_ADR(19 downto 5) = x"3" else '1'; -- FFFO'0060-FFF0'007F

    IDE_DRQn <= '0';    

	IDE_CMD_REG: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' then
			CMD_STATE <= IDLE;
		elsif rising_edge(CLK_MAIN) then
			CMD_STATE <= NEXT_CMD_STATE;
			IDE_RDn <= NEXT_IDE_RDn;
			IDE_WRn <= NEXT_IDE_WRn;
		end if;
	end process IDE_CMD_REG;

	IDE_CMD_DECODER: process(CMD_STATE, IDE_CF_CS, FB_WRn, IDE_RDY)
	begin
		case CMD_STATE is
			when IDLE =>
				IDE_CF_TA <= '0';
				if IDE_CF_CS = '1' then
					NEXT_IDE_RDn <= not FB_WRn;
					NEXT_IDE_WRn <= FB_WRn;
					NEXT_CMD_STATE <= T1;
				else
					NEXT_IDE_RDn <= '1';
					NEXT_IDE_WRn <= '1';
					NEXT_CMD_STATE <= IDLE; 		 
				end if;
			when T1 =>
				IDE_CF_TA <= '0';
				NEXT_IDE_RDn <= not FB_WRn;
				NEXT_IDE_WRn <= FB_WRn;
				NEXT_CMD_STATE <= T6;
			when T6 =>
				IF IDE_RDY = '1' then
					IDE_CF_TA <= '1';
					NEXT_IDE_RDn <= '1';
					NEXT_IDE_WRn <= '1';
					NEXT_CMD_STATE <= T7;
				else
					IDE_CF_TA <= '0';
					NEXT_IDE_RDn <= not FB_WRn;
					NEXT_IDE_WRn <= FB_WRn;
					NEXT_CMD_STATE <= T6;
				end if;
			when T7 => 
				IDE_CF_TA <= '0';
				NEXT_IDE_RDn <= '1';
				NEXT_IDE_WRn <= '1';
				NEXT_CMD_STATE <= IDLE;
		end case;
	end process IDE_CMD_DECODER;

    SD_CLK <= '0';
    SD_CD_D3_OUT <= '0';
    SD_CD_D3_EN <= '0';
    SD_CMD_D1_OUT <= '0';
    SD_CMD_D1_EN <= '0';

    ROM4n <= '0' when FB_CS1n = '0' and FB_WRn = '1' and FB_ADR(19 downto 17) = x"5" and FB_ADR(16) = '0' else '1'; -- FFF A'0000/2'0000
    ROM3n <= '0' when FB_CS1n = '0' and FB_WRn = '1' and FB_ADR(19 downto 17) = x"5" and FB_ADR(16) = '1' else '1'; -- FFF A'0000/2'0000	
end architecture BEHAVIOUR;
