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
---- restriction provided that this copyright statement IS not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file IS free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source IS distributed IN the hope that it will be       ----
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

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY WF6850IP_TOP_SOC IS
	PORT (
		CLK					: IN STD_LOGIC;
		RESETn				: IN STD_LOGIC;

		CS2n, CS1, CS0		: IN STD_LOGIC;
		E		       		: IN STD_LOGIC;   
		RWn              	: IN STD_LOGIC;
		RS						: IN STD_LOGIC;

		DATA_IN				: IN STD_LOGIC_VECTOR(7 downto 0);   
		DATA_OUT				: OUT STD_LOGIC_VECTOR(7 downto 0);   
		DATA_EN				: OUT STD_LOGIC;

		TXCLK					: IN STD_LOGIC;
		RXCLK					: IN STD_LOGIC;
		RXDATA				: IN STD_LOGIC;
		CTSn					: IN STD_LOGIC;
		DCDn					: IN STD_LOGIC;
        
		IRQn					: OUT STD_LOGIC;
		TXDATA				: OUT STD_LOGIC;   
		RTSn					: OUT STD_LOGIC
	);                                              
END ENTITY WF6850IP_TOP_SOC;

ARCHITECTURE STRUCTURE of WF6850IP_TOP_SOC IS
	COMPONENT WF6850IP_CTRL_STATUS
		PORT (
			CLK		: IN STD_LOGIC;
			RESETn	: IN STD_LOGIC;
			CS			: IN STD_LOGIC_VECTOR(2 downto 0);
			E			: IN STD_LOGIC;   
			RWn     	: IN STD_LOGIC;
			RS			: IN STD_LOGIC;
			DATA_IN	: IN STD_LOGIC_VECTOR(7 downto 0);   
			DATA_OUT	: OUT STD_LOGIC_VECTOR(7 downto 0);  
			DATA_EN	: OUT STD_LOGIC;
			RDRF		: IN STD_LOGIC;
			TDRE		: IN STD_LOGIC;
			DCDn		: IN STD_LOGIC;
			CTSn		: IN STD_LOGIC;
			FE			: IN STD_LOGIC;
			OVR		: IN STD_LOGIC;
			PE			: IN STD_LOGIC;
			MCLR		: OUT STD_LOGIC;
			RTSn		: OUT STD_LOGIC;
			CDS		: OUT STD_LOGIC_VECTOR(1 downto 0);
			WS			: OUT STD_LOGIC_VECTOR(2 downto 0);
			TC			: OUT STD_LOGIC_VECTOR(1 downto 0);
			IRQn		: OUT STD_LOGIC
		);                                              
	END COMPONENT;
	
	COMPONENT WF6850IP_RECEIVE
		PORT (
			CLK				: IN STD_LOGIC;
			RESETn			: IN STD_LOGIC;
			MCLR				: IN STD_LOGIC;
			CS					: IN STD_LOGIC_VECTOR(2 downto 0);
			E		       	: IN STD_LOGIC;   
			RWn            : IN STD_LOGIC;
			RS					: IN STD_LOGIC;
			DATA_OUT	      : OUT STD_LOGIC_VECTOR(7 downto 0);   
			DATA_EN			: OUT STD_LOGIC;
			WS					: IN STD_LOGIC_VECTOR(2 downto 0);
			CDS				: IN STD_LOGIC_VECTOR(1 downto 0);
			RXCLK				: IN STD_LOGIC;
			RXDATA			: IN STD_LOGIC;
			RDRF				: OUT STD_LOGIC;
			OVR				: OUT STD_LOGIC;
			PE					: OUT STD_LOGIC;
			FE					: OUT STD_LOGIC
		);                                              
	END COMPONENT;
	
	COMPONENT WF6850IP_TRANSMIT
		PORT (
			CLK					: IN STD_LOGIC;
			RESETn				: IN STD_LOGIC;
			MCLR				: IN STD_LOGIC;
			CS					: IN STD_LOGIC_VECTOR(2 downto 0);
			E		       		: IN STD_LOGIC;   
			RWn              	: IN STD_LOGIC;
			RS					: IN STD_LOGIC;
			DATA_IN		        : IN STD_LOGIC_VECTOR(7 downto 0);   
			CTSn				: IN STD_LOGIC;
			TC					: IN STD_LOGIC_VECTOR(1 downto 0);
			WS					: IN STD_LOGIC_VECTOR(2 downto 0);
			CDS					: IN STD_LOGIC_VECTOR(1 downto 0);
			TXCLK				: IN STD_LOGIC;
			TDRE				: OUT STD_LOGIC;        
			TXDATA				: OUT STD_LOGIC
		);                                              
	END COMPONENT;
	
	SIGNAL DATA_IN_I	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL DATA_RX		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL DATA_RX_EN	: STD_LOGIC;
	SIGNAL DATA_CTRL	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL DATA_CTRL_EN	: STD_LOGIC;
	SIGNAL RDRF_I		: STD_LOGIC;
	SIGNAL TDRE_I		: STD_LOGIC;
	SIGNAL FE_I			: STD_LOGIC;
	SIGNAL OVR_I		: STD_LOGIC;
	SIGNAL PE_I			: STD_LOGIC;
	SIGNAL MCLR_I		: STD_LOGIC;
	SIGNAL CDS_I		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL WS_I			: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL TC_I			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL IRQ_In		: STD_LOGIC;
BEGIN
	DATA_IN_I <= (DATA_IN);
	DATA_EN <= DATA_RX_EN or DATA_CTRL_EN;
	DATA_OUT <= (DATA_RX) WHEN DATA_RX_EN = '1' ELSE
				(DATA_CTRL) WHEN DATA_CTRL_EN = '1' ELSE (others => '0');
				
	IRQn <= '0' WHEN IRQ_In = '0' ELSE '1';

	I_UART_CTRL_STATUS: WF6850IP_CTRL_STATUS
	PORT MAP(
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
	PORT MAP (
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
	PORT MAP (
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
END ARCHITECTURE STRUCTURE;