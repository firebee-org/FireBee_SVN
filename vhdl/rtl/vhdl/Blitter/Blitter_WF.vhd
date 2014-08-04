----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the std_logic block transfer processor   ----
---- (BLITTER) of the 'Firebee' computer.                         ----
---- It is optimized for the use of an Altera Cyclone             ----
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
use ieee.numeric_std.all;

entity FBEE_BLITTER is
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
end entity FBEE_BLITTER;

architecture BEHAVIOUR of FBEE_BLITTER is
	signal BLITTER_DACK     : std_logic_vector(4 downto 0);
	signal BLITTER_DIN_I    : std_logic_vector(127 downto 0);
begin
	P_BLITTER_DACK: process
	begin
		wait until CLK_DDR0 = '1' and CLK_DDR0' event;
		BLITTER_DACK <= BLITTER_DACK_SR & BLITTER_DACK(4 downto 1);
		if BLITTER_DACK(0) = '1' then
			BLITTER_DIN_I <= BLITTER_DIN;
		end if;
	end process P_BLITTER_DACK;


	BLITTER_RUN <= '0';
	BLITTER_DOUT <= x"FEDCBA9876543210F0F0F0F0F0F0F0F0";
	DATA_OUT <= x"FEDCBA98";
	BLITTER_ADR <=  x"76543210";
	BLITTER_SIG <= '0';
	BLITTER_WR <= '0';
	BLITTER_TA <= '0';
	DATA_EN <= '0';
END BEHAVIOUR;
