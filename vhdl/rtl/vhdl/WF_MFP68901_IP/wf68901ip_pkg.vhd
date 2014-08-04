----------------------------------------------------------------------
----                                                              ----
---- ATARI MFP compatible IP Core					              ----
----                                                              ----
---- This file is part of the SUSKA ATARI clone project.          ----
---- http://www.experiment-s.de                                   ----
----                                                              ----
---- Description:                                                 ----
---- MC68901 compatible multi function port core.                 ----
----                                                              ----
---- This is the package file containing the component            ----
---- declarations.                                                ----
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
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
--

library ieee;
use ieee.std_logic_1164.all;

package WF68901IP_PKG is
component WF68901IP_USART_TOP
	port (  CLK			: in std_logic;
			RESETn		: in std_logic;
			DSn			: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			RS			: in std_logic_vector(5 downto 1);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_OUT_EN	: out std_logic;
			RC			: in std_logic;
			TC			: in std_logic;
			SI			: in std_logic;
			SO			: out std_logic;
			SO_EN		: out std_logic;
			RX_ERR_INT	: out std_logic;
			RX_BUFF_INT	: out std_logic;
			TX_ERR_INT	: out std_logic;
			TX_BUFF_INT	: out std_logic;
			RRn			: out std_logic;
			TRn			: out std_logic			
	);
end component;

component WF68901IP_USART_CTRL
	port (
		CLK				: in std_logic;
        RESETn			: in std_logic;
        DSn				: in std_logic;
        CSn				: in std_logic;   
        RWn     		: in std_logic;
        RS				: in std_logic_vector(5 downto 1);
        DATA_IN			: in std_logic_vector(7 downto 0);   
        DATA_OUT		: out std_logic_vector(7 downto 0);   
		DATA_OUT_EN		: out std_logic;
		RX_SAMPLE		: in std_logic;
        RX_DATA			: in std_logic_vector(7 downto 0);   
        TX_DATA			: out std_logic_vector(7 downto 0);   
        SCR_OUT			: out std_logic_vector(7 downto 0);   
		BF				: in std_logic;
		BE				: in std_logic;
		FE				: in std_logic;
		OE				: in std_logic;
		UE				: in std_logic;
		PE				: in std_logic;
		M_CIP			: in std_logic;
		FS_B			: in std_logic;
		TX_END			: in std_logic;
		CL				: out std_logic_vector(1 downto 0);
		ST				: out std_logic_vector(1 downto 0);
		FS_CLR			: out std_logic;
		RSR_READ		: out std_logic;
		TSR_READ		: out std_logic;
		UDR_READ		: out std_logic;
		UDR_WRITE		: out std_logic;
		LOOPBACK		: out std_logic;
		SDOUT_EN		: out std_logic;
		SD_LEVEL		: out std_logic;
		CLK_MODE		: out std_logic;
		RE				: out std_logic;
		TE				: out std_logic;
		P_ENA			: out std_logic;
		P_EOn			: out std_logic;
		SS				: out std_logic;
		BR				: out std_logic
	);                                              
end component;

component WF68901IP_USART_TX
	port (
		CLK			: in std_logic;
        RESETn		: in std_logic;
		SCR			: in std_logic_vector(7 downto 0);
		TX_DATA		: in std_logic_vector(7 downto 0);
        SDATA_OUT	: out std_logic;
        TXCLK		: in std_logic;
		CL			: in std_logic_vector(1 downto 0);
		ST			: in std_logic_vector(1 downto 0);
		TE			: in std_logic;
		BR			: in std_logic;
		P_ENA		: in std_logic;
		P_EOn		: in std_logic;
		UDR_WRITE	: in std_logic;
		TSR_READ	: in std_logic;
		CLK_MODE	: in std_logic;
		TX_END		: out std_logic;
		UE			: out std_logic;
		BE			: out std_logic
	);                                              
end component;

component WF68901IP_USART_RX
	port (
		CLK			: in std_logic;
        RESETn		: in std_logic;
		SCR			: in std_logic_vector(7 downto 0);
		RX_SAMPLE	: out std_logic;
        RX_DATA	  	: out std_logic_vector(7 downto 0);   
        RXCLK		: in std_logic;
        SDATA_IN	: in std_logic;
		CL			: in std_logic_vector(1 downto 0);
		ST			: in std_logic_vector(1 downto 0);
		P_ENA		: in std_logic;
		P_EOn		: in std_logic;
		CLK_MODE	: in std_logic;
		RE			: in std_logic;
		FS_CLR		: in std_logic;
		SS			: in std_logic;
		RSR_READ	: in std_logic;
		UDR_READ	: in std_logic;
		M_CIP		: out std_logic;
		FS_B		: out std_logic;
		BF			: out std_logic;
		OE			: out std_logic;
		PE			: out std_logic;
		FE			: out std_logic
	);                                              
end component;

component WF68901IP_INTERRUPTS
	port ( 	
		CLK			: in std_logic;
		RESETn		: in std_logic;
		DSn			: in std_logic;
		CSn			: in std_logic;
		RWn			: in std_logic;
		RS			: in std_logic_vector(5 downto 1);
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_OUT_EN	: out std_logic;
		IACKn		: in std_logic;
		IEIn		: in std_logic;
		IEOn		: out std_logic;
		IRQn		: out std_logic;
		GP_INT		: in std_logic_vector(7 downto 0);
		AER_4		: in std_logic;
		AER_3		: in std_logic;
		TAI			: in std_logic;
		TBI			: in std_logic;
		TA_PWM		: in std_logic;
		TB_PWM		: in std_logic;
		TIMER_A_INT	: in std_logic;
		TIMER_B_INT	: in std_logic;
		TIMER_C_INT	: in std_logic;
		TIMER_D_INT	: in std_logic;
		RCV_ERR		: in std_logic;
		TRM_ERR		: in std_logic;
		RCV_BUF_F	: in std_logic;
		TRM_BUF_E	: in std_logic
	);
end component;

component WF68901IP_GPIO
	port (  
		CLK			: in std_logic;
		RESETn		: in std_logic;
		DSn			: in std_logic;
		CSn			: in std_logic;
		RWn			: in std_logic;
		RS			: in std_logic_vector(5 downto 1);
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_OUT_EN	: out std_logic;
		AER_4		: out std_logic;
		AER_3		: out std_logic;
		GPIP_IN		: in std_logic_vector(7 downto 0);
		GPIP_OUT	: out std_logic_vector(7 downto 0);
		GPIP_OUT_EN	: out std_logic_vector(7 downto 0);
		GP_INT		: out std_logic_vector(7 downto 0)
	);
end component;

component WF68901IP_TIMERS
	port (  
		CLK			: in std_logic;
		RESETn		: in std_logic;
		DSn			: in std_logic;
		CSn			: in std_logic;
		RWn			: in std_logic;
		RS			: in std_logic_vector(5 downto 1);
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_OUT_EN	: out std_logic;
		XTAL1		: in std_logic;
		TAI			: in std_logic;
		TBI			: in std_logic;
		AER_4		: in std_logic;
		AER_3		: in std_logic;
		TA_PWM		: out std_logic;
		TB_PWM		: out std_logic;
		TAO			: out std_logic;			
		TBO			: out std_logic;			
		TCO			: out std_logic;			
		TDO			: out std_logic;
		TIMER_A_INT	: out std_logic;
		TIMER_B_INT	: out std_logic;
		TIMER_C_INT	: out std_logic;
		TIMER_D_INT	: out std_logic
	);
end component;

end WF68901IP_PKG;
