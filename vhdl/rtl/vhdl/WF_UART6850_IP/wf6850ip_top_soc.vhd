----------------------------------------------------------------------
----                                                              ----
---- 6850 compatible IP Core     					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- UART 6850 compatible IP core                                 ----
----                                                              ----
---- This is the top level file.                                  ----
---- Top level file for use in systems on programmable chips.     ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2006 - 2011 Wolfgang Foerster                  ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/lgpl.html                   ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K6A  2006/06/03 WF
--   Initial Release.
-- Revision 2K6B  2006/11/07 WF
--   Modified Source to compile with the Xilinx ISE.
--   Top level file provided for SOC (systems on programmable chips).
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
-- Revision 2K9B  2009/12/24 WF
--   Fixed the interrupt logic.
--   Introduced a minor RTSn correction.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WF6850IP_TOP_SOC is
	port (
		CLK					: in std_logic;
		RESETn				: in std_logic;

		CS2n, CS1, CS0		: in std_logic;
		E		       		: in std_logic;   
		RWn              	: in std_logic;
		RS						: in std_logic;

		DATA_IN				: in std_logic_vector(7 downto 0);   
		DATA_OUT				: out std_logic_vector(7 downto 0);   
		DATA_EN				: out std_logic;

		TXCLK					: in std_logic;
		RXCLK					: in std_logic;
		RXDATA				: in std_logic;
		CTSn					: in std_logic;
		DCDn					: in std_logic;
        
		IRQn					: out std_logic;
		TXDATA				: out std_logic;   
		RTSn					: out std_logic
	);                                              
end entity WF6850IP_TOP_SOC;

architecture STRUCTURE of WF6850IP_TOP_SOC is
	component WF6850IP_CTRL_STATUS
		port (
			CLK		: in std_logic;
			RESETn	: in std_logic;
			CS			: in std_logic_vector(2 downto 0);
			E			: in std_logic;   
			RWn     	: in std_logic;
			RS			: in std_logic;
			DATA_IN	: in std_logic_vector(7 downto 0);   
			DATA_OUT	: out std_logic_vector(7 downto 0);  
			DATA_EN	: out std_logic;
			RDRF		: in std_logic;
			TDRE		: in std_logic;
			DCDn		: in std_logic;
			CTSn		: in std_logic;
			FE			: in std_logic;
			OVR		: in std_logic;
			PE			: in std_logic;
			MCLR		: out std_logic;
			RTSn		: out std_logic;
			CDS		: out std_logic_vector(1 downto 0);
			WS			: out std_logic_vector(2 downto 0);
			TC			: out std_logic_vector(1 downto 0);
			IRQn		: out std_logic
		);                                              
	end component;
	
	component WF6850IP_RECEIVE
		port (
			CLK				: in std_logic;
			RESETn			: in std_logic;
			MCLR				: in std_logic;
			CS					: in std_logic_vector(2 downto 0);
			E		       	: in std_logic;   
			RWn            : in std_logic;
			RS					: in std_logic;
			DATA_OUT	      : out std_logic_vector(7 downto 0);   
			DATA_EN			: out std_logic;
			WS					: in std_logic_vector(2 downto 0);
			CDS				: in std_logic_vector(1 downto 0);
			RXCLK				: in std_logic;
			RXDATA			: in std_logic;
			RDRF				: out std_logic;
			OVR				: out std_logic;
			PE					: out std_logic;
			FE					: out std_logic
		);                                              
	end component;
	
	component WF6850IP_TRANSMIT
		port (
			CLK					: in std_logic;
			RESETn				: in std_logic;
			MCLR				: in std_logic;
			CS					: in std_logic_vector(2 downto 0);
			E		       		: in std_logic;   
			RWn              	: in std_logic;
			RS					: in std_logic;
			DATA_IN		        : in std_logic_vector(7 downto 0);   
			CTSn				: in std_logic;
			TC					: in std_logic_vector(1 downto 0);
			WS					: in std_logic_vector(2 downto 0);
			CDS					: in std_logic_vector(1 downto 0);
			TXCLK				: in std_logic;
			TDRE				: out std_logic;        
			TXDATA				: out std_logic
		);                                              
	end component;
	
	signal DATA_IN_I	: std_logic_vector(7 downto 0);
	signal DATA_RX		: std_logic_vector(7 downto 0);
	signal DATA_RX_EN	: std_logic;
	signal DATA_CTRL	: std_logic_vector(7 downto 0);
	signal DATA_CTRL_EN	: std_logic;
	signal RDRF_I		: std_logic;
	signal TDRE_I		: std_logic;
	signal FE_I			: std_logic;
	signal OVR_I		: std_logic;
	signal PE_I			: std_logic;
	signal MCLR_I		: std_logic;
	signal CDS_I		: std_logic_vector(1 downto 0);
	signal WS_I			: std_logic_vector(2 downto 0);
	signal TC_I			: std_logic_vector(1 downto 0);
	signal IRQ_In		: std_logic;
begin
	DATA_IN_I <= (DATA_IN);
	DATA_EN <= DATA_RX_EN or DATA_CTRL_EN;
	DATA_OUT <= (DATA_RX) when DATA_RX_EN = '1' else
				(DATA_CTRL) when DATA_CTRL_EN = '1' else (others => '0');
				
	IRQn <= '0' when IRQ_In = '0' else '1';

	I_UART_CTRL_STATUS: WF6850IP_CTRL_STATUS
	port map(
		CLK		=> CLK,
		RESETn	=> RESETn,
		CS(2)		=> CS2n,
		CS(1)		=> CS1,
		CS(0)		=> CS0,
		E			=> E,
		RWn     	=> RWn,
		RS			=> RS,
		DATA_IN	=> DATA_IN_I,
		DATA_OUT	=> DATA_CTRL,
		DATA_EN	=> DATA_CTRL_EN,
		RDRF		=> RDRF_I,
		TDRE		=> TDRE_I,
		DCDn		=> DCDn,
		CTSn		=> CTSn,
		FE			=> FE_I,
		OVR		=> OVR_I,
		PE			=> PE_I,
		MCLR		=> MCLR_I,
		RTSn		=> RTSn,
		CDS		=> CDS_I,
		WS			=> WS_I,
		TC			=> TC_I,
		IRQn		=> IRQ_In
	);                                              

	I_UART_RECEIVE: WF6850IP_RECEIVE
	port map (
		CLK		=> CLK,
		RESETn	=> RESETn,
		MCLR		=> MCLR_I,
		CS(2)		=> CS2n,
		CS(1)		=> CS1,
		CS(0)		=> CS0,
		E			=> E,
		RWn     	=> RWn,
		RS			=> RS,
		DATA_OUT	=> DATA_RX,
		DATA_EN	=> DATA_RX_EN,
		WS			=> WS_I,
		CDS		=> CDS_I,
		RXCLK		=> RXCLK,
		RXDATA	=> RXDATA,
		RDRF		=> RDRF_I,
		OVR		=> OVR_I,
		PE			=> PE_I,
		FE			=> FE_I
	);                                              

	I_UART_TRANSMIT: WF6850IP_TRANSMIT
	port map (
		CLK		=> CLK,
		RESETn	=> RESETn,
		MCLR		=> MCLR_I,
		CS(2)		=> CS2n,
		CS(1)		=> CS1,
		CS(0)		=> CS0,
		E			=> E,
		RWn     	=> RWn,
		RS			=> RS,
		DATA_IN	=> DATA_IN_I,
		CTSn		=> CTSn,
		TC			=> TC_I,
		WS			=> WS_I,
		CDS		=> CDS_I,
		TDRE		=> TDRE_I,
		TXCLK		=> TXCLK,
		TXDATA	=> TXDATA
	);
end architecture STRUCTURE;