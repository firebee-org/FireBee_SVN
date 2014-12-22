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
---- This is the SUSKA MFP IP core top level file.                ----
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
-- Revision 2K7A  2006/12/28 WF
--   The timer is modified to work on the CLK instead
--   of XTAL1. This modification is done to provide
--   a synchronous design.
-- Revision 2K8A  2008/07/14 WF
--   Minor changes.
-- Revision 2K9A  2009/06/20 WF
--   DTACK_OUTn has now synchronous reset to meet preset requirement.
--
--

use work.wf68901ip_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WF68901IP_TOP_SOC is
	port (  -- System control:
			CLK			: in std_logic;
			RESETn		: in std_logic;
			
			-- Asynchronous bus control:
			DSn			: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			DTACKn		: out std_logic;
			
			-- Data and Adresses:
			RS			: in std_logic_vector(5 downto 1);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			GPIP_IN		: in std_logic_vector(7 downto 0);
			GPIP_OUT	: out std_logic_vector(7 downto 0);
			GPIP_EN		: out std_logic_vector(7 downto 0);
			
			-- Interrupt control:
			IACKn		: in std_logic;
			IEIn		: in std_logic;
			IEOn		: out std_logic;
			irq_n		: out std_logic;
			
			-- Timers and timer control:
			XTAL1		: in std_logic; -- Use an oszillator instead of a quartz.
			TAI			: in std_logic;
			TBI			: in std_logic;
			TAO			: out std_logic;			
			TBO			: out std_logic;			
			TCO			: out std_logic;			
			TDO			: out std_logic;			
			
			-- Serial I/O control:
			RC			: in std_logic;
			TC			: in std_logic;
			SI			: in std_logic;
			SO			: out std_logic;
			SO_EN		: out std_logic;
			
			-- DMA control:
			RRn			: out std_logic;
			TRn			: out std_logic			
	);
end entity WF68901IP_TOP_SOC;

architecture STRUCTURE of WF68901IP_TOP_SOC is
signal DATA_IN_I				: std_logic_vector(7 downto 0);
signal DTACK_In					: std_logic;
signal DTACK_LOCK				: boolean;
signal DTACK_OUTn				: std_logic;
signal RX_ERR_INT_I				: std_logic;
signal TX_ERR_INT_I				: std_logic;
signal RX_BUFF_INT_I			: std_logic;
signal TX_BUFF_INT_I			: std_logic;
signal DATA_OUT_USART_I			: std_logic_vector(7 downto 0);
signal DATA_OUT_EN_USART_I		: std_logic;
signal DATA_OUT_INT_I			: std_logic_vector(7 downto 0);
signal DATA_OUT_EN_INT_I		: std_logic;
signal DATA_OUT_GPIO_I			: std_logic_vector(7 downto 0);
signal DATA_OUT_EN_GPIO_I		: std_logic;
signal DATA_OUT_TIMERS_I		: std_logic_vector(7 downto 0);
signal DATA_OUT_EN_TIMERS_I		: std_logic;
signal SO_I						: std_logic;
signal SO_EN_I					: std_logic;
signal GPIP_IN_I				: std_logic_vector(7 downto 0);
signal GPIP_OUT_I				: std_logic_vector(7 downto 0);
signal GPIP_EN_I				: std_logic_vector(7 downto 0);
signal GP_INT_I					: std_logic_vector(7 downto 0);
signal TIMER_A_INT_I			: std_logic;
signal TIMER_B_INT_I			: std_logic;
signal TIMER_C_INT_I			: std_logic;
signal TIMER_D_INT_I			: std_logic;
signal IRQ_In					: std_logic;
signal AER_4_I					: std_logic;
signal AER_3_I					: std_logic;
signal TA_PWM_I					: std_logic;
signal TB_PWM_I					: std_logic;
begin
	-- Interrupt request (open drain):
	irq_n <= IRQ_In;

	-- Serial data output:
	SO <= 	SO_I;
	SO_EN <= SO_EN_I and RESETn;

	-- General purpose port:
	GPIP_IN_I	<= GPIP_IN;
	GPIP_OUT <= GPIP_OUT_I;
	GPIP_EN <= GPIP_EN_I;

	DATA_IN_I <= DATA_IN;
	DATA_EN <= DATA_OUT_EN_USART_I or DATA_OUT_EN_INT_I or DATA_OUT_EN_GPIO_I or DATA_OUT_EN_TIMERS_I;
	-- Output data multiplexer:
	DATA_OUT <= DATA_OUT_USART_I when DATA_OUT_EN_USART_I = '1' else
				DATA_OUT_INT_I when DATA_OUT_EN_INT_I = '1' else
				DATA_OUT_GPIO_I when DATA_OUT_EN_GPIO_I = '1' else
				DATA_OUT_TIMERS_I when DATA_OUT_EN_TIMERS_I = '1' else (others => '1');

	-- Data acknowledge handshake is provided by the following statement and the consecutive two
	-- processes. For more information refer to the M68000 family reference manual.
	DTACK_In <= '0' when CSn = '0' and DSn = '0' and RS <= "10111" else -- Read and write operation.
				'0' when IACKn = '0' and DSn = '0' and IEIn = '0' else '1'; -- Interrupt vector data acknowledge.

	P_DTACK_LOCK: process
	-- This process releases a data acknowledge detect, one rising clock
	-- edge after the DTACK_In occured. This is necessary to ensure write
	-- data to registers for there is one rising clock edge required.
	begin
		wait until CLK = '1' and CLK' event;
		if DTACK_In = '0' then
			DTACK_LOCK <= false;
		else
			DTACK_LOCK <= true;
		end if;
	end process P_DTACK_LOCK;

	DTACK_OUT: process
	-- The DTACKn port pin is released on the falling clock edge after the data
	-- acknowledge detect (DTACK_LOCK) is asserted. The DTACKn is deasserted
	-- immediately when there is no further register access DTACK_In = '1';
	begin
		wait until CLK = '0' and CLK' event;
		if RESETn = '0' then
			DTACK_OUTn <= '1';
		elsif DTACK_In = '1' then
			DTACK_OUTn <= '1';
		elsif DTACK_LOCK = false then
			DTACK_OUTn <= '0';
		end if;
	end process DTACK_OUT;
	DTACKn <= '0' when DTACK_OUTn = '0' else '1';

	I_USART: WF68901IP_USART_TOP
		port map(
			CLK				=> CLK,
			RESETn			=> RESETn,
			DSn				=> DSn,
			CSn				=> CSn,
			RWn				=> RWn,
			RS				=> RS,
			DATA_IN			=> DATA_IN_I,
			DATA_OUT		=> DATA_OUT_USART_I,
			DATA_OUT_EN		=> DATA_OUT_EN_USART_I,
			RC				=> RC,
			TC				=> TC,
			SI				=> SI,
			SO				=> SO_I,
			SO_EN			=> SO_EN_I,
			RX_ERR_INT		=> RX_ERR_INT_I,
			RX_BUFF_INT		=> RX_BUFF_INT_I,
			TX_ERR_INT		=> TX_ERR_INT_I,
			TX_BUFF_INT		=> TX_BUFF_INT_I,
			RRn				=> RRn,
			TRn				=> TRn
		);

	I_INTERRUPTS: WF68901IP_INTERRUPTS
		port map(
			CLK				=> CLK,
			RESETn			=> RESETn,
			DSn				=> DSn,
			CSn				=> CSn,
			RWn				=> RWn,
			RS				=> RS,
			DATA_IN			=> DATA_IN_I,
			DATA_OUT		=> DATA_OUT_INT_I,
			DATA_OUT_EN		=> DATA_OUT_EN_INT_I,
			IACKn			=> IACKn,
			IEIn			=> IEIn,
			IEOn			=> IEOn,
			irq_n			=> IRQ_In,
			GP_INT			=> GP_INT_I,
			AER_4			=> AER_4_I,
			AER_3			=> AER_3_I,
			TAI				=> TAI,
			TBI				=> TBI,
			TA_PWM 			=> TA_PWM_I,
			TB_PWM 			=> TB_PWM_I,
			TIMER_A_INT		=> TIMER_A_INT_I,
			TIMER_B_INT		=> TIMER_B_INT_I,
			TIMER_C_INT		=> TIMER_C_INT_I,
			TIMER_D_INT		=> TIMER_D_INT_I,
			RCV_ERR			=> RX_ERR_INT_I,
			TRM_ERR			=> TX_ERR_INT_I,
			RCV_BUF_F		=> RX_BUFF_INT_I,
			TRM_BUF_E		=> TX_BUFF_INT_I
     	 );

	I_GPIO: WF68901IP_GPIO
		port map(  
			CLK				=> CLK,
			RESETn			=> RESETn,
			DSn				=> DSn,
			CSn				=> CSn,
			RWn				=> RWn,
			RS				=> RS,
			DATA_IN			=> DATA_IN_I,
			DATA_OUT		=> DATA_OUT_GPIO_I,
			DATA_OUT_EN		=> DATA_OUT_EN_GPIO_I,
			AER_4			=> AER_4_I,
			AER_3			=> AER_3_I,
			GPIP_IN			=> GPIP_IN_I,
			GPIP_OUT		=> GPIP_OUT_I,
			GPIP_OUT_EN		=> GPIP_EN_I,
			GP_INT			=> GP_INT_I
      	);

	I_TIMERS: WF68901IP_TIMERS
		port map(
			CLK				=> CLK,
			RESETn			=> RESETn,
			DSn				=> DSn,
			CSn				=> CSn,
			RWn				=> RWn,
			RS				=> RS,
			DATA_IN			=> DATA_IN_I,
			DATA_OUT		=> DATA_OUT_TIMERS_I,
			DATA_OUT_EN		=> DATA_OUT_EN_TIMERS_I,
			XTAL1			=> XTAL1,
			AER_4			=> AER_4_I,
			AER_3			=> AER_3_I,
			TAI				=> TAI,
			TBI				=> TBI,
			TAO				=> TAO,
			TBO				=> TBO,
			TCO				=> TCO,
			TDO				=> TDO,
			TA_PWM 			=> TA_PWM_I,
			TB_PWM 			=> TB_PWM_I,
			TIMER_A_INT		=> TIMER_A_INT_I,
			TIMER_B_INT		=> TIMER_B_INT_I,
			TIMER_C_INT		=> TIMER_C_INT_I,
			TIMER_D_INT		=> TIMER_D_INT_I
      	);
end architecture STRUCTURE;
