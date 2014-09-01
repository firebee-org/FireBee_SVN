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
---- This is the SUSKA MFP IP core timers logic file.             ----
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
-- Revision 2K6B	2006/11/07 WF
--   Modified Source to compile with the Xilinx ISE.
-- Revision 2K7A	2006/12/28 WF
--   The timer is modified to work on the CLK instead
--   of XTAL1. This modification is done to provide
--   a synchronous design.
-- Revision 2K8A	2008/02/29 WF
--   Fixed a serious prescaler bug.
-- Revision 2K9A 20090620 WF
--   Introduced timer readback registers.
--   TIMER_x_INT is now a strobe.
--   Minor improvements.
-- Revision 2K11A 20110620 WF
--   A minor change in the data readback logic (RWn is now taken into consideration).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WF68901IP_TIMERS is
	port (  -- System control:
			CLK			: in std_logic;
			RESETn		: in std_logic;
			
			-- Asynchronous bus control:
			DSn			: in std_logic;
			CSn			: in std_logic;
			RWn			: in std_logic;
			
			-- Data and Adresses:
			RS			: in std_logic_vector(5 downto 1);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT	: out std_logic_vector(7 downto 0);
			DATA_OUT_EN	: out std_logic;

			-- Timers and timer control:
			XTAL1		: in std_logic; -- Use an oszillator instead of a quartz.
			TAI			: in std_logic;
			TBI			: in std_logic;
			AER_4		: in std_logic;
			AER_3		: in std_logic;
			TA_PWM		: out std_logic; -- Indicates, that timer A is in PWM mode (used in Interrupt logic).
			TB_PWM		: out std_logic; -- Indicates, that timer B is in PWM mode (used in Interrupt logic).
			TAO			: buffer std_logic;
			TBO			: buffer std_logic;
			TCO			: buffer std_logic;
			TDO			: buffer std_logic;
			TIMER_A_INT	: out std_logic;
			TIMER_B_INT	: out std_logic;
			TIMER_C_INT	: out std_logic;
			TIMER_D_INT	: out std_logic
	);
end entity WF68901IP_TIMERS;

architecture BEHAVIOR of WF68901IP_TIMERS is
signal XTAL1_S		: std_logic;
signal XTAL_STRB	: std_logic;
signal TACR			: std_logic_vector(4 downto 0); -- Timer A control register.
signal TBCR			: std_logic_vector(4 downto 0); -- Timer B control register.
signal TCDCR		: std_logic_vector(5 downto 0); -- Timer C and D control register.
signal TADR			: std_logic_vector(7 downto 0); -- Timer A data register.
signal TBDR			: std_logic_vector(7 downto 0); -- Timer B data register.
signal TCDR			: std_logic_vector(7 downto 0); -- Timer C data register.
signal TDDR			: std_logic_vector(7 downto 0); -- Timer D data register.
signal TIMER_A 		: unsigned (7 downto 0); -- Timer A count register.
signal TIMER_B 		: unsigned (7 downto 0); -- Timer B count register.
signal TIMER_C 		: unsigned (7 downto 0); -- Timer C count register.
signal TIMER_D 		: unsigned (7 downto 0); -- Timer D count register.
signal TIMER_R_A    : std_logic_vector (7 downto 0); -- Timer A readback register.
signal TIMER_R_B    : std_logic_vector (7 downto 0); -- Timer B readback register.
signal TIMER_R_C    : std_logic_vector (7 downto 0); -- Timer C readback register.
signal TIMER_R_D    : std_logic_vector (7 downto 0); -- Timer D readback register.
signal A_CNTSTRB	: std_logic;
signal B_CNTSTRB	: std_logic;
signal C_CNTSTRB	: std_logic;
signal D_CNTSTRB	: std_logic;
signal TAI_I		: std_logic;
signal TBI_I		: std_logic;
signal TAI_STRB		: std_logic; -- Strobe for the event counter mode.
signal TBI_STRB		: std_logic; -- Strobe for the event counter mode.
signal TAO_I		: std_logic; -- Timer A output signal.
signal TBO_I		: std_logic; -- Timer A output signal.
begin
	SYNC: process
	-- This process provides a 'clean' XTAL1.
	-- Without this sync, the edge detector for
	-- XTAL_STRB does not work properly.
	begin
		wait until CLK = '1' and CLK' event;
		XTAL1_S <= XTAL1;
        -- Polarity control for the event counter and the PWM mode:
        TAI_I <= TAI xnor AER_4;
        TBI_I <= TBI xnor AER_3;
	end process SYNC;
	
	-- Output enables for timer A and timer B:
	-- The outputs are held low for asserted reset flags in the control registers TACR
	-- and TBCR but also during a write operation to these registers.
	TAO <=	'0' when TACR(4) = '1' else
			'0' when CSn = '0' and DSn = '0' and RWn = '0' and RS = "01100" else TAO_I;
	TBO <=	'0' when TBCR(4) = '1' else
			'0' when CSn = '0' and DSn = '0' and RWn = '0' and RS = "01101" else TBO_I;

	-- Control outputs for the PWM modi of the timers A and B. These
	-- controls are used in the interrupt logic to select the interrupt
	-- sources GPIP4 or TAI repective GPIP3 or TBI.
	TA_PWM <= '1' when TACR(3 downto 0) > x"8" else '0';
	TB_PWM <= '1' when TBCR(3 downto 0) > x"8" else '0';

	TIMER_REGISTERS: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			TACR <= (others => '0');
			TBCR <= (others => '0');
			TCDCR <= (others => '0');
			-- TADR <= Do not clear during reset!
			-- TBDR <= Do not clear during reset!
			-- TCDR <= Do not clear during reset!
			-- TDDR <= Do not clear during reset!
		elsif CLK = '1' and CLK' event then
			if CSn = '0' and DSn = '0' and RWn = '0' then
				case RS is
					when "01100"	=> TACR <= DATA_IN(4 downto 0);
					when "01101"	=> TBCR <= DATA_IN(4 downto 0);
					when "01110"	=> TCDCR <= DATA_IN(6 downto 4) & DATA_IN(2 downto 0);
					when "01111"	=> TADR <= DATA_IN;
					when "10000"	=> TBDR <= DATA_IN;
					when "10001"	=> TCDR <= DATA_IN;
					when "10010"	=> TDDR <= DATA_IN;
					when others		=> null;
				end case;
			end if;
		end if;
	end process TIMER_REGISTERS;

	TIMER_READBACK	: process(RESETn, CLK)
		-- This process provides the readback information for the
		-- timers A to D. The information read is the information
		-- last clocked into the timer read register when the DSn
		-- pin had last gone high prior to the current read cycle.
		variable READ_A : boolean;
		variable READ_B : boolean;
		variable READ_C : boolean;
		variable READ_D : boolean;
	begin
		if RESETn = '0' then
			TIMER_R_A <= x"00";
			TIMER_R_B <= x"00";
			TIMER_R_C <= x"00";
			TIMER_R_D <= x"00";
		elsif CLK = '1' and CLK' event then
			if DSn = '0' and RWn = '1' and RS = "01111" then
				READ_A := true;
			elsif DSn = '0' and RWn = '1' and RS = "10000" then
				READ_B := true;
			elsif DSn = '0' and RWn = '1' and RS = "10001" then
				READ_C := true;
			elsif DSn = '0' and RWn = '1' and RS = "10010" then
				READ_D := true;
			elsif DSn = '1' and READ_A = true then
				TIMER_R_A <= std_logic_vector(TIMER_A);
				READ_A := false;
			elsif DSn = '1' and READ_B = true then
				TIMER_R_B <= std_logic_vector(TIMER_B);
				READ_B := false;
			elsif DSn = '1' and READ_C = true then
				TIMER_R_C <= std_logic_vector(TIMER_C);
				READ_C := false;
			elsif DSn = '1' and READ_D = true then
				TIMER_R_D <= std_logic_vector(TIMER_D);
				READ_D := false;
			end if;
		end if;
	end process TIMER_READBACK;

	DATA_OUT_EN <= '1' when CSn = '0' and DSn = '0' and RWn = '1' and RS > "01011" and RS <= "10010" else '0';
	DATA_OUT <= "000" & TACR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01100" else
				"000" & TBCR when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01101" else
				'0' & TCDCR(5 downto 3) & '0' & TCDCR(2 downto 0) when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01110" else
				TIMER_R_A when CSn = '0' and DSn = '0' and RWn = '1' and RS = "01111" else
				TIMER_R_B when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10000" else
				TIMER_R_C when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10001" else
				TIMER_R_D when CSn = '0' and DSn = '0' and RWn = '1' and RS = "10010" else (others => '0');

	XTAL_STROBE: process(RESETn, CLK)
	-- This process provides a strobe with 1 clock cycle
	-- (CLK) length after every rising edge of XTAL1.
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			XTAL_STRB <= '0';
		elsif CLK = '1' and CLK' event then
            if XTAL1_S = '1' and LOCK = false then
				XTAL_STRB <= '1';
				LOCK := true;
			elsif XTAL1_S = '0' then
				XTAL_STRB <= '0';
				LOCK := false;
			else
				XTAL_STRB <= '0';
			end if;
		end if;
	end process XTAL_STROBE;

	TAI_STROBE: process(RESETn, CLK)
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			TAI_STRB <= '0';
		elsif CLK = '1' and CLK' event then
            if TAI_I = '1' and XTAL_STRB = '1' and LOCK = false then
				LOCK := true;
				TAI_STRB <= '1';
			elsif TAI_I = '0' then
				LOCK := false;
				TAI_STRB <= '0';
			else
				TAI_STRB <= '0';
			end if;
		end if;
	end process TAI_STROBE;

	TBI_STROBE: process(RESETn, CLK)
	variable LOCK : boolean;
	begin
		if RESETn = '0' then
			TBI_STRB <= '0';
		elsif CLK = '1' and CLK' event then
            if TBI_I = '1' and XTAL_STRB = '1' and LOCK = false then
				LOCK := true;
				TBI_STRB <= '1';
			elsif TBI_I = '0' then
				LOCK := false;
				TBI_STRB <= '0';
			else
				TBI_STRB <= '0';
			end if;
		end if;
	end process TBI_STROBE;

	PRESCALE_A: process
	-- The prescalers work even if the RESETn is asserted.
	variable PRESCALE : unsigned (7 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		A_CNTSTRB <= '0';
		if PRESCALE > x"00" and XTAL_STRB = '1' then
			PRESCALE := PRESCALE - 1;
		elsif XTAL_STRB = '1' then
			case TACR(2 downto 0) is
				when "111" => PRESCALE := x"C7"; -- Prescaler = 200.
				when "110" => PRESCALE := x"63"; -- Prescaler = 100.
				when "101" => PRESCALE := x"3F"; -- Prescaler = 64.
				when "100" => PRESCALE := x"31"; -- Prescaler = 50.
				when "011" => PRESCALE := x"0F"; -- Prescaler = 16.
				when "010" => PRESCALE := x"09"; -- Prescaler = 10.
				when "001" => PRESCALE := x"03"; -- Prescaler = 4.
				when "000" => PRESCALE := x"00"; -- Timer stopped or event count mode.
				when others => PRESCALE := x"00";
			end case;
			A_CNTSTRB <= '1';
		end if;
	end process PRESCALE_A;

	PRESCALE_B: process
	-- The prescalers work even if the RESETn is asserted.
	variable PRESCALE : unsigned (7 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		B_CNTSTRB <= '0';
		if PRESCALE > x"00" and XTAL_STRB = '1' then
			PRESCALE := PRESCALE - 1;
		elsif XTAL_STRB = '1' then
			case TBCR(2 downto 0) is
				when "111" => PRESCALE := x"C7"; -- Prescaler = 200.
				when "110" => PRESCALE := x"63"; -- Prescaler = 100.
				when "101" => PRESCALE := x"3F"; -- Prescaler = 64.
				when "100" => PRESCALE := x"31"; -- Prescaler = 50.
				when "011" => PRESCALE := x"0F"; -- Prescaler = 16.
				when "010" => PRESCALE := x"09"; -- Prescaler = 10.
				when "001" => PRESCALE := x"03"; -- Prescaler = 4.
				when "000" => PRESCALE := x"00"; -- Timer stopped or event count mode.
				when others => PRESCALE := x"00";
			end case;
			B_CNTSTRB <= '1';
		end if;
	end process PRESCALE_B;

	PRESCALE_C: process
	-- The prescalers work even if the RESETn is asserted.
	variable PRESCALE : unsigned (7 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		C_CNTSTRB <= '0';
		if PRESCALE > x"00" and XTAL_STRB = '1' then
			PRESCALE := PRESCALE - 1;
		elsif XTAL_STRB = '1' then
			case TCDCR(5 downto 3) is
				when "111" => PRESCALE := x"C7"; -- Prescaler = 200.
				when "110" => PRESCALE := x"63"; -- Prescaler = 100.
				when "101" => PRESCALE := x"3F"; -- Prescaler = 64.
				when "100" => PRESCALE := x"31"; -- Prescaler = 50.
				when "011" => PRESCALE := x"0F"; -- Prescaler = 16.
				when "010" => PRESCALE := x"09"; -- Prescaler = 10.
				when "001" => PRESCALE := x"03"; -- Prescaler = 4.
				when "000" => PRESCALE := x"00"; -- Timer stopped.
				when others => PRESCALE := x"00";
			end case;
			C_CNTSTRB <= '1';
		end if;
	end process PRESCALE_C;

	PRESCALE_D: process
	-- The prescalers work even if the RESETn is asserted.
	variable PRESCALE : unsigned (7 downto 0);
	begin
		wait until CLK = '1' and CLK' event;
		D_CNTSTRB <= '0';
		if PRESCALE > x"00" and XTAL_STRB = '1' then
			PRESCALE := PRESCALE - 1;
		elsif XTAL_STRB = '1' then
			case TCDCR(2 downto 0) is
				when "111" => PRESCALE := x"C7"; -- Prescaler = 200.
				when "110" => PRESCALE := x"63"; -- Prescaler = 100.
				when "101" => PRESCALE := x"3F"; -- Prescaler = 64.
				when "100" => PRESCALE := x"31"; -- Prescaler = 50.
				when "011" => PRESCALE := x"0F"; -- Prescaler = 16.
				when "010" => PRESCALE := x"09"; -- Prescaler = 10.
				when "001" => PRESCALE := x"03"; -- Prescaler = 4.
				when "000" => PRESCALE := x"00"; -- Timer stopped.
				when others => PRESCALE := x"00";
			end case;
			D_CNTSTRB <= '1';
		end if;
	end process PRESCALE_D;

	TIMERA: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			-- Do not clear the timer registers during system reset.
			TAO_I <= '0';
			TIMER_A_INT <= '0';
		elsif CLK = '1' and CLK' event then
            TIMER_A_INT <= '0';
            --
			if CSn = '0' and DSn = '0' and RWn = '0' and RS = "01111" and TACR(3 downto 0) = x"0" then
				-- The timer is reloaded simultaneously to it's timer data register, if it is off.
				TIMER_A <= unsigned(DATA_IN);
			else
				case TACR(3 downto 0) is
					when x"0" => -- Timer is off.
                        TAO_I <= '0';
					when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" => -- Delay counter mode.
						if A_CNTSTRB = '1' and TIMER_A /= x"01" then -- Count.
							TIMER_A <= TIMER_A - 1;
						elsif A_CNTSTRB = '1' and TIMER_A = x"01" then -- Reload.
							TIMER_A <= unsigned(TADR);
							TAO_I <= not TAO_I; -- Toggle the timer A output pin.
							TIMER_A_INT <= '1';
						end if;
					when x"8" => -- Event count operation.
						if TAI_STRB = '1' and TIMER_A /= x"01" then -- Count.
							TIMER_A <= unsigned(TIMER_A) - 1;
						elsif TAI_STRB = '1' and TIMER_A = x"01" then -- Reload.
							TIMER_A <= unsigned(TADR);
							TAO_I <= not TAO_I; -- Toggle the timer A output pin.
							TIMER_A_INT <= '1';
						end if;
					when x"9" | x"A" | x"B" | x"C" | x"D" | x"E" | x"F" => -- PWM mode.
						if TAI_I = '1' and A_CNTSTRB = '1' and TIMER_A /= x"01" then -- Count.
							TIMER_A <= unsigned(TIMER_A) - 1;
						elsif TAI_I = '1' and A_CNTSTRB = '1' and TIMER_A = x"01" then -- Reload.
							TIMER_A <= unsigned(TADR);
							TAO_I <= not TAO_I; -- Toggle the timer A output pin.
							TIMER_A_INT <= '1';
						end if;
				  when others => TAO_I <= '0';
				end case;					
			end if;
		end if;
	end process TIMERA;

	TIMERB: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			-- Do not clear the timer registers during system reset.
			TBO_I <= '0';
			TIMER_B_INT <= '0';
		elsif CLK = '1' and CLK' event then
            TIMER_B_INT <= '0';
            --
			if CSn = '0' and DSn = '0' and RWn = '0' and RS = "10000" and TBCR(3 downto 0) = x"0" then
				-- The timer is reloaded simultaneously to it's timer data register, if it is off.
				TIMER_B <= unsigned(DATA_IN);
			else
				case TBCR(3 downto 0) is
					when x"0" => -- Timer is off.
                        TBO_I <= '0';
					when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" => -- Delay counter mode.
						if B_CNTSTRB = '1' and TIMER_B /= x"01" then -- Count.
							TIMER_B <= TIMER_B - 1;
						elsif B_CNTSTRB = '1' and TIMER_B = x"01" then -- Reload.
							TIMER_B <= unsigned(TBDR);
							TBO_I <= not TBO_I; -- Toggle the timer B output pin.
							TIMER_B_INT <= '1';
						end if;
					when x"8" => -- Event count operation.
						if TBI_STRB = '1' and TIMER_B /= x"01" then -- Count.
							TIMER_B <= TIMER_B - 1;
						elsif TBI_STRB = '1' and TIMER_B = x"01" then -- Reload.
							TIMER_B <= unsigned(TBDR);
							TBO_I <= not TBO_I; -- Toggle the timer B output pin.
							TIMER_B_INT <= '1';
						end if;
					when x"9" | x"A" | x"B" | x"C" | x"D" | x"E" | x"F" => -- PWM mode.
						if TBI_I = '1' and B_CNTSTRB = '1' and TIMER_B /= x"01" then -- Count.
							TIMER_B <= TIMER_B - 1;
						elsif TBI_I = '1' and B_CNTSTRB = '1' and TIMER_B = x"01" then -- Reload.
							TIMER_B <= unsigned(TBDR);
							TBO_I <= not TBO_I; -- Toggle the timer B output pin.
							TIMER_B_INT <= '1';
						end if;
					when others => TBO_I <= '0';
				end case;					
			end if;
		end if;
	end process TIMERB;

	TIMERC: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			-- Do not clear the timer registers during system reset.
			TCO <= '0';
			TIMER_C_INT <= '0';
		elsif CLK = '1' and CLK' event then
            TIMER_C_INT <= '0';
            --
			if CSn = '0' and DSn = '0' and RWn = '0' and RS = "10001" and TCDCR(5 downto 3) = "000" then
				-- The timer is reloaded simultaneously to it's timer data register, if it is off.
				TIMER_C <= unsigned(DATA_IN);
			else
				case TCDCR(5 downto 3) is
					when "000" => -- Timer is off.
                        TCO <= '0';
					when others => -- Delay counter mode.
						if C_CNTSTRB = '1' and TIMER_C /= x"01" then -- Count.
							TIMER_C <= TIMER_C - 1;
						elsif C_CNTSTRB = '1' and TIMER_C = x"01" then -- Reload.
							TIMER_C <= unsigned(TCDR);
							TCO <= not TCO; -- Toggle the timer C output pin.
							TIMER_C_INT <= '1';
						end if;
				end case;					
			end if;
		end if;
	end process TIMERC;

	TIMERD: process(RESETn, CLK)
	begin
		if RESETn = '0' then
			-- Do not clear the timer registers during system reset.
			TDO <= '0';
			TIMER_D_INT <= '0';
		elsif CLK = '1' and CLK' event then
            TIMER_D_INT <= '0';
            --
 			if CSn = '0' and DSn = '0' and RWn = '0' and RS = "10010" and TCDCR(2 downto 0) = "000" then
				-- The timer is reloaded simultaneously to it's timer data register, if it is off.
				TIMER_D <= unsigned(DATA_IN);
			else
				case TCDCR(2 downto 0) is
					when "000" => -- Timer is off.
                        TDO <= '0';
					when others => -- Delay counter mode.
						if D_CNTSTRB = '1' and TIMER_D /= x"01" then -- Count.
							TIMER_D <= TIMER_D - 1;
						elsif D_CNTSTRB = '1' and TIMER_D = x"01" then -- Reload.
							TIMER_D <= unsigned(TDDR);
							TDO <= not TDO; -- Toggle the timer D output pin.
							TIMER_D_INT <= '1';
						end if;
				end case;					
			end if;
		end if;
	end process TIMERD;
end architecture BEHAVIOR;