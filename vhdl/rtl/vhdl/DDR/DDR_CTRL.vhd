----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the DDR controller of the 'Firebee'----
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

entity DDR_CTRL_V1 is
	port(
		CLK_MAIN        : in std_logic;
		DDR_SYNC_66M    : in std_logic;
		FB_ADR          : in std_logic_vector(31 downto 0);
		FB_CS1n         : in std_logic;
		FB_OEn          : in std_logic;
		FB_SIZE0        : in std_logic;
		FB_SIZE1        : in std_logic;
		FB_ALE          : in std_logic;
		FB_WRn          : in std_logic;
		FIFO_CLR        : in std_logic;
		VIDEO_RAM_CTR   : in std_logic_vector(15 downto 0);
		BLITTER_ADR     : in std_logic_vector(31 downto 0);
		BLITTER_SIG     : in std_logic;
		BLITTER_WR      : in std_logic;
		DDRCLK0         : in std_logic;
		CLK_33M         : in std_logic;
		FIFO_MW         : in std_logic_vector(8 downto 0);
		
		VA              : out std_logic_vector(12 downto 0);		-- video Adress bus at the DDR chips
		VWEn            : out std_logic;									-- video memory write enable
		VRASn           : out std_logic;									-- video memory RAS
		VCSn            : out std_logic;									-- video memory chip select
		VCKE            : out std_logic;									-- video memory clock enable
		VCASn           : out std_logic;									-- video memory CAS
		
		FB_LE           : out std_logic_vector(3 downto 0);
		FB_VDOE         : out std_logic_vector(3 downto 0);
		
		SR_FIFO_WRE     : out std_logic;
		SR_DDR_FB       : out std_logic;
		SR_DDR_WR       : out std_logic;
		SR_DDRWR_D_SEL  : out std_logic;
		SR_VDMP         : out std_logic_vector(7 downto 0);
		
		VIDEO_DDR_TA    : out std_logic;
		SR_BLITTER_DACK : out std_logic;
		BA              : out std_logic_vector(1 downto 0);
		DDRWR_D_SEL1    : out std_logic;
		VDM_SEL         : out std_logic_vector(3 downto 0);
		DATA_IN         : in std_logic_vector(31 downto 0);
		DATA_OUT        : out std_logic_vector(31 downto 16);
		DATA_EN_H       : out std_logic;
		DATA_EN_L       : out std_logic
	);
end entity DDR_CTRL_V1;

architecture BEHAVIOUR of DDR_CTRL_V1 is
	-- FIFO WATER MARK:
	constant FIFO_LWM : integer := 0;		-- low water mark
	constant FIFO_MWM : integer := 200;		-- medium water mark
	constant FIFO_HWM : integer := 500;		-- high water mark
	
	type ACCESS_WIDTH_TYPE is (LONG, WORD, BYTE);
	type DDR_ACCESS_TYPE is (CPU, FIFO, BLITTER, NONE);
	type FB_REGDDR_TYPE is (FR_WAIT, FR_S0, FR_S1, FR_S2, FR_S3);    
	type DDR_SM_TYPE is (DS_T1, DS_T2A, DS_T2B, DS_T3, DS_N5, DS_N6, DS_N7, DS_N8,   -- Start (normal 8 cycles total = 60ns).
							   DS_C2, DS_C3, DS_C4, DS_C5, DS_C6, DS_C7,                   -- Configuration. 
							   DS_T4R, DS_T5R,                                             -- Read CPU or BLITTER.
							   DS_T4W, DS_T5W, DS_T6W, DS_T7W, DS_T8W, DS_T9W,             -- Write CPU or BLITTER.
							   DS_T4F, DS_T5F, DS_T6F, DS_T7F, DS_T8F, DS_T9F, DS_T10F,    -- Read FIFO.
							   DS_CB6, DS_CB8,                                             -- Close FIFO bank.
							   DS_R2, DS_R3, DS_R4, DS_R5, DS_R6);                         -- Refresh: 10 x 7.5ns = 75ns.
	
	signal ACCESS_WIDTH     : ACCESS_WIDTH_TYPE;
	signal FB_REGDDR        : FB_REGDDR_TYPE;
	signal FB_REGDDR_NEXT   : FB_REGDDR_TYPE;
	signal DDR_ACCESS       : DDR_ACCESS_TYPE;
	signal DDR_STATE        : DDR_SM_TYPE;
	signal DDR_NEXT_STATE   : DDR_SM_TYPE;
	signal VCS_In           : std_logic;
	signal VCKE_I           : std_logic;
	signal BYTE_SEL         : std_logic_vector(3 downto 0);
	signal SR_FIFO_WRE_I    : std_logic;
	signal VCAS             : std_logic;
	signal VRAS             : std_logic;
	signal VWE              : std_logic;
	signal MCS              : std_logic_vector(1 downto 0);
	signal BUS_CYC          : std_logic;
	signal BUS_CYC_END      : std_logic;
	signal BLITTER_REQ      : std_logic;
	signal BLITTER_ROW_ADR  : std_logic_vector(12 downto 0);
	signal BLITTER_BA       : std_logic_vector(1 downto 0);
	signal BLITTER_COL_ADR  : std_logic_vector(9 downto 0);
	signal CPU_DDR_SYNC     : std_logic;
	signal CPU_ROW_ADR      : std_logic_vector(12 downto 0);
	signal CPU_BA           : std_logic_vector(1 downto 0);
	signal CPU_COL_ADR      : std_logic_vector(9 downto 0);
	signal CPU_REQ          : std_logic;
	signal DDR_SEL          : std_logic;
	signal DDR_CS           : std_logic;
	signal DDR_CONFIG       : std_logic;
	signal FIFO_REQ         : std_logic;
	signal FIFO_ROW_ADR     : std_logic_vector(12 downto 0);
	signal FIFO_BA          : std_logic_vector(1 downto 0);
	signal FIFO_COL_ADR     : unsigned(9 downto 0);
	signal FIFO_ACTIVE      : std_logic;
	signal FIFO_CLR_SYNC    : std_logic;
	signal VDM_SEL_I        : std_logic_vector(3 downto 0);
	signal CLEAR_FIFO_CNT   : std_logic;
	signal STOP             : std_logic;
	signal FIFO_BANK_OK     : std_logic;
	signal DDR_REFRESH_ON   : std_logic;
	signal DDR_REFRESH_CNT  : unsigned(10 downto 0) := "00000000000";
	signal DDR_REFRESH_REQ  : std_logic;
	signal DDR_REFRESH_SIG  : unsigned(3 downto 0);
	signal REFRESH_TIME     : std_logic;
	signal VIDEO_BASE_L_D   : std_logic_vector(7 downto 0);
	signal VIDEO_BASE_L     : std_logic;
	signal VIDEO_BASE_M_D   : std_logic_vector(7 downto 0);
	signal VIDEO_BASE_M     : std_logic;
	signal VIDEO_BASE_H_D   : std_logic_vector(7 downto 0);
	signal VIDEO_BASE_H     : std_logic;
	signal VIDEO_BASE_X_D   : std_logic_vector(2 downto 0);
	signal VIDEO_ADR_CNT    : unsigned(22 downto 0);
	signal VIDEO_CNT_L      : std_logic;
	signal VIDEO_CNT_M      : std_logic;
	signal VIDEO_CNT_H      : std_logic;
	signal VIDEO_BASE_ADR   : std_logic_vector(22 downto 0);
	signal VIDEO_ACT_ADR    : std_logic_vector(26 downto 0);
	signal FB_ADR_I         : std_logic_vector(32 downto 0);
	
	
	signal VA_S             : std_logic_vector(12 downto 0);
	signal VA_P             : std_logic_vector(12 downto 0);
	signal BA_S             : std_logic_vector(1 downto 0) ;
	signal BA_P             : std_logic_vector(1 downto 0);
	signal TSIZ					: std_logic_vector(1 downto 0);
begin
	TSIZ <= FB_SIZE1 & FB_SIZE0;
	with TSIZ select
        ACCESS_WIDTH <= LONG when "11",
                        WORD when "00",
                        BYTE when others;

	-- Byte selectors:
	BYTE_SEL(0) <= '1' when ACCESS_WIDTH = LONG or ACCESS_WIDTH = WORD else
						'1' when FB_ADR(1 downto 0) = "00" else '0'; -- Byte 0.

	BYTE_SEL(1) <= '1' when ACCESS_WIDTH = LONG or ACCESS_WIDTH = WORD else
						'1' when ACCESS_WIDTH = BYTE and FB_ADR(1) = '0' else -- High word.
						'1' when FB_ADR(1 downto 0) = "01" else '0'; -- Byte 1.
             
	BYTE_SEL(2) <= '1' when ACCESS_WIDTH = LONG or ACCESS_WIDTH = WORD else
						'1' when FB_ADR(1 downto 0) = "10" else '0'; -- Byte 2.
             
	BYTE_SEL(3) <= '1' when ACCESS_WIDTH = LONG or ACCESS_WIDTH = WORD else
						'1' when ACCESS_WIDTH = BYTE and FB_ADR(1) = '1' else -- Low word.
						'1' when FB_ADR(1 downto 0) = "11" else '0'; -- Byte 3.
             
	---------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------ CPU READ (REG DDR => CPU) AND WRITE (CPU => REG DDR) ---------------------------------------------------------------------
	FBCTRL_REG: process
	begin
		wait until rising_edge(CLK_MAIN);
		FB_REGDDR <= FB_REGDDR_NEXT;
	end process FBCTRL_REG;
    
	FBCTRL_DEC: process(FB_REGDDR, BUS_CYC, DDR_SEL, ACCESS_WIDTH, FB_WRn, DDR_CS)
	begin
		case FB_REGDDR is
			when FR_WAIT => 
				if BUS_CYC = '1' then
					FB_REGDDR_NEXT <= FR_S0;
				elsif DDR_SEL = '1' and ACCESS_WIDTH = LONG and FB_WRn = '0' then
					FB_REGDDR_NEXT <= FR_S0;
				else
					FB_REGDDR_NEXT <= FR_WAIT;
				end if;
			
			when FR_S0 =>
				if DDR_CS = '1' and ACCESS_WIDTH = LONG then
					FB_REGDDR_NEXT <= FR_S1;
				else
					FB_REGDDR_NEXT <= FR_WAIT; 
				end if;
			
			when FR_S1 => 
				if DDR_CS = '1' then
					FB_REGDDR_NEXT <= FR_S2;
				else
					FB_REGDDR_NEXT <= FR_WAIT; 
				end if;
			
			when FR_S2 => 
				if DDR_CS = '1' and BUS_CYC = '0' and ACCESS_WIDTH = LONG and FB_WRn = '0' then -- wait during long word access if needed
					FB_REGDDR_NEXT <= FR_S2;
				elsif DDR_CS = '1' then
					FB_REGDDR_NEXT <= FR_S3;
				else
					FB_REGDDR_NEXT <= FR_WAIT;
				end if;
	
			when FR_S3 => 
				FB_REGDDR_NEXT <= FR_WAIT;
		end case;
	end process FBCTRL_DEC;

	-- Coldfire CPU access:
	FB_LE(0) <= not FB_WRn when FB_REGDDR = FR_WAIT else
					not FB_WRn when FB_REGDDR = FR_S0 and DDR_CS = '1' else '0';
	FB_LE(1) <= not FB_WRn when FB_REGDDR = FR_S1 and DDR_CS = '1' else '0';
	FB_LE(2) <= not FB_WRn when FB_REGDDR = FR_S2 and DDR_CS = '1' else '0';
	FB_LE(3) <= not FB_WRn when FB_REGDDR = FR_S3 and DDR_CS = '1' else '0';

	-- Video data access:
	VIDEO_DDR_TA <= '1' when FB_REGDDR = FR_S0 and DDR_CS = '1' else
						'1' when FB_REGDDR = FR_S1 and DDR_CS = '1' else
						'1' when FB_REGDDR = FR_S2 and FB_REGDDR_NEXT = FR_S3 else
						'1' when FB_REGDDR = FR_S3 and DDR_CS = '1' else '0';

	-- FB_VDOE # VIDEO_OE.

	-- Write access for video data:
	FB_VDOE(0) <= '1' when FB_REGDDR = FR_S0 and DDR_CS = '1' and FB_OEn = '0' and DDR_CONFIG = '0' and ACCESS_WIDTH = LONG else
						'1' when FB_REGDDR = FR_S0 and DDR_CS = '1' and FB_OEn = '0' and DDR_CONFIG = '0' and ACCESS_WIDTH /= LONG and CLK_MAIN = '0' else '0';
	FB_VDOE(1) <= '1' when FB_REGDDR = FR_S1 and DDR_CS = '1' and FB_OEn = '0' and DDR_CONFIG = '0' else '0';
	FB_VDOE(2) <= '1' when FB_REGDDR = FR_S2 and DDR_CS = '1' and FB_OEn = '0' and DDR_CONFIG = '0' else '0';
	FB_VDOE(3) <= '1' when FB_REGDDR = FR_S3 and DDR_CS = '1' and FB_OEn = '0' and DDR_CONFIG = '0' and CLK_MAIN = '0' else '0';

	BUS_CYC_END <= '1' when FB_REGDDR = FR_S0 and DDR_CS = '1' and ACCESS_WIDTH /= LONG else
						'1' when FB_REGDDR = FR_S3 and DDR_CS = '1' else '0';

	---------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------ DDR State Machine --------------------------------------------------------------------------------------
	DDR_STATE_REG: process
	begin
		wait until rising_edge(DDRCLK0);
		DDR_STATE <= DDR_NEXT_STATE;
	end process DDR_STATE_REG;

	DDR_STATE_DEC: process(DDR_STATE, DDR_REFRESH_REQ, CPU_DDR_SYNC, DDR_CONFIG, FB_WRn, DDR_ACCESS, BLITTER_WR, FIFO_REQ, FIFO_BANK_OK,
									FIFO_MW, CPU_REQ, VIDEO_ADR_CNT, DDR_SEL, TSIZ, DATA_IN, FIFO_BA, DDR_REFRESH_SIG)
	begin
		case DDR_STATE is
			when DS_T1 =>
				if DDR_REFRESH_REQ = '1' then
					DDR_NEXT_STATE <= DS_R2;
				elsif CPU_DDR_SYNC = '1' and DDR_CONFIG = '1' then -- Synchronous start.
					DDR_NEXT_STATE <= DS_C2;
				elsif CPU_DDR_SYNC = '1' and CPU_REQ = '1' then -- Synchronous start.
					DDR_NEXT_STATE <= DS_T2B;
				elsif CPU_DDR_SYNC = '1' then
					DDR_NEXT_STATE <= DS_T2A;
				else
					DDR_NEXT_STATE <= DS_T1; -- Synchronize.
				end if;
			
			when DS_T2A => -- Fast access, in this case page is always not ok.
				DDR_NEXT_STATE <= DS_T3;
	
			when DS_T2B =>
				DDR_NEXT_STATE <= DS_T3;

			when DS_T3 =>
				if DDR_ACCESS = CPU and FB_WRn = '0' then
					DDR_NEXT_STATE <= DS_T4W;
				elsif DDR_ACCESS = BLITTER and BLITTER_WR = '1' then
					DDR_NEXT_STATE <= DS_T4W;
				elsif DDR_ACCESS = CPU then -- CPU?
					DDR_NEXT_STATE <= DS_T4R;                                                 
				elsif DDR_ACCESS = FIFO then -- FIFO?
					DDR_NEXT_STATE <= DS_T4F;
				elsif DDR_ACCESS = BLITTER then
					DDR_NEXT_STATE <= DS_T4R;                                                 
				else
					DDR_NEXT_STATE <= DS_N8;
				end if;
            
			-- Read:
			when DS_T4R =>
				DDR_NEXT_STATE <= DS_T5R;                

			when DS_T5R =>
				if FIFO_REQ = '1' and FIFO_BANK_OK = '1' then -- Insert FIFO read, when bank ok.
					DDR_NEXT_STATE <= DS_T6F;
				else    
					DDR_NEXT_STATE <= DS_CB6;
				end if;
            
			-- Write:            
			when DS_T4W =>
				DDR_NEXT_STATE <= DS_T5W;

			when DS_T5W =>
				DDR_NEXT_STATE <= DS_T6W;

			when DS_T6W =>                               
				DDR_NEXT_STATE <= DS_T7W;

			when DS_T7W =>                               
				DDR_NEXT_STATE <= DS_T8W;
            
			when DS_T8W =>                               
				DDR_NEXT_STATE <= DS_T9W;
            
			when DS_T9W =>                               
				if FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
					DDR_NEXT_STATE <= DS_T6F;
				else
					DDR_NEXT_STATE <= DS_CB6;
				end if;
            
			-- FIFO read:
			when DS_T4F =>
				DDR_NEXT_STATE <= DS_T5F;                

			when DS_T5F =>
				if FIFO_REQ = '1' then
					DDR_NEXT_STATE <= DS_T6F;
				else
					DDR_NEXT_STATE <= DS_CB6; -- Leave open.
				end if;

			when DS_T6F =>
				DDR_NEXT_STATE <= DS_T7F;                                                                      
            
			when DS_T7F =>
				if CPU_REQ = '1' and FIFO_MW > std_logic_vector(to_unsigned(FIFO_LWM, FIFO_MW'length)) then    
					DDR_NEXT_STATE <= DS_CB8; -- Close bank.
				elsif FIFO_REQ = '1' and VIDEO_ADR_CNT(7 downto 0) = x"FF" then -- New page?
					DDR_NEXT_STATE <= DS_CB8; -- Close bank.
				elsif FIFO_REQ = '1' then
					DDR_NEXT_STATE <= DS_T8F;
				else
					DDR_NEXT_STATE <= DS_CB8; -- Close bank.
				end if;

			when DS_T8F =>
				if FIFO_MW < std_logic_vector(to_unsigned(FIFO_LWM, FIFO_MW'length)) then -- Emergency?
					DDR_NEXT_STATE <= DS_T5F; -- Yes!
				else
					DDR_NEXT_STATE <= DS_T9F;
				end if;

			when DS_T9F =>
				if FIFO_REQ = '1' and VIDEO_ADR_CNT(7 downto 0) = x"FF"  then -- New page?
					DDR_NEXT_STATE <= DS_CB6; -- Close bank.
				elsif FIFO_REQ = '1' then
					DDR_NEXT_STATE <= DS_T10F;
				else
					DDR_NEXT_STATE <= DS_CB6; -- Close bank.
				end if;

			when DS_T10F =>
				if DDR_SEL = '1' and (FB_WRn = '1' or TSIZ /= "11") and DATA_IN(13 downto 12) /= FIFO_BA then
					DDR_NEXT_STATE <= DS_T3;
				else
					DDR_NEXT_STATE <= DS_T7F;
				end if; 

			-- Configuration cycles:
			when DS_C2 =>
				DDR_NEXT_STATE <= DS_C3;
			
			when DS_C3 =>
				DDR_NEXT_STATE <= DS_C4;
            
			when DS_C4 =>
				if CPU_REQ = '1' then
					DDR_NEXT_STATE <= DS_C5;
				else
					DDR_NEXT_STATE <= DS_T1;
				end if; 

			when DS_C5 =>
				DDR_NEXT_STATE <= DS_C6;
			
			when DS_C6 =>
				DDR_NEXT_STATE <= DS_C7;
            
			when DS_C7 =>
				DDR_NEXT_STATE <= DS_N8;

			-- Close FIFO bank.
			when DS_CB6 =>
				DDR_NEXT_STATE <= DS_N7;
            
			when DS_CB8 =>
				DDR_NEXT_STATE <= DS_T1;
			
			-- Refresh 70ns = ten cycles.
			when DS_R2 =>
				if DDR_REFRESH_SIG = x"9" then -- One cycle delay to close all banks.
					DDR_NEXT_STATE <= DS_R4;
				else
					DDR_NEXT_STATE <= DS_R3;
				end if;

			when DS_R3 =>
				DDR_NEXT_STATE <= DS_R4;

			when DS_R4 =>
				DDR_NEXT_STATE <= DS_R5;
            
			when DS_R5 =>
				DDR_NEXT_STATE <= DS_R6;
            
			when DS_R6 =>
				DDR_NEXT_STATE <= DS_N5;
            
			-- Loop:
			when DS_N5 =>
				DDR_NEXT_STATE <= DS_N6;

			when DS_N6 =>
				DDR_NEXT_STATE <= DS_N7;

			when DS_N7 =>
				DDR_NEXT_STATE <= DS_N8;
            
			when DS_N8 =>
				DDR_NEXT_STATE <= DS_T1;
		end case;
	end process DDR_STATE_DEC;

    P_CLK0: process
    begin
		wait until rising_edge(DDRCLK0);
		
		-- Default assignments;
		DDR_ACCESS <= NONE;
		SR_FIFO_WRE_I <= '0';
		SR_VDMP <= x"00";
		SR_DDR_WR <= '0';
		SR_DDRWR_D_SEL <= '0';

		MCS <= MCS(0) & CLK_MAIN;		-- sync on CLK_MAIN
		
		BLITTER_REQ <= BLITTER_SIG and not DDR_CONFIG and VCKE_I and not VCS_In;
		FIFO_CLR_SYNC <= FIFO_CLR;
		CLEAR_FIFO_CNT <= FIFO_CLR_SYNC or not FIFO_ACTIVE;
		STOP <= FIFO_CLR_SYNC or CLEAR_FIFO_CNT;

		if FIFO_MW < std_logic_vector(to_unsigned(FIFO_MWM, FIFO_MW'length)) then
			FIFO_REQ <= '1';
		elsif FIFO_MW < std_logic_vector(to_unsigned(FIFO_HWM, FIFO_MW'length)) and FIFO_REQ = '1' then
			FIFO_REQ <= '1';
		elsif FIFO_ACTIVE = '1' and CLEAR_FIFO_CNT = '0' and STOP = '0' and DDR_CONFIG = '0' and VCKE_I = '1' and VCS_In = '0' then
			FIFO_REQ <= '1';
		else
			FIFO_REQ <= '1';
		end if;

		if CLEAR_FIFO_CNT = '1' then
			VIDEO_ADR_CNT <= unsigned(VIDEO_BASE_ADR);
		elsif SR_FIFO_WRE_I = '1' then
			VIDEO_ADR_CNT <= VIDEO_ADR_CNT + 1;  
		end if;

		if MCS = "10" and VCKE_I = '1' and VCS_In = '0' then
			CPU_DDR_SYNC <= '1';
		else
			CPU_DDR_SYNC <= '0';
		end if;

		if DDR_REFRESH_SIG /= x"0" and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' and REFRESH_TIME = '1' then
			DDR_REFRESH_REQ <= '1';
		else
			DDR_REFRESH_REQ <= '0';
		end if;

		if DDR_REFRESH_CNT = "00000000000" and CLK_MAIN = '0' then
			REFRESH_TIME <= '1';
		else
			REFRESH_TIME <= '0';
		end if;

		if REFRESH_TIME = '1' and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' then
			DDR_REFRESH_SIG <= x"9";
		elsif DDR_STATE = DS_R6 and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' then
			DDR_REFRESH_SIG <= DDR_REFRESH_SIG - 1;
		else
			DDR_REFRESH_SIG <= x"0";
		end if;

		if BUS_CYC_END = '1' then
			BUS_CYC <= '0';
		elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and CPU_REQ = '1' then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and FB_WRn = '0' then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and ACCESS_WIDTH /= LONG then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_T2B then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_T10F and FB_WRn = '0' and DATA_IN(13 downto 12) = FIFO_BA then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_T10F and ACCESS_WIDTH /= LONG and DATA_IN(13 downto 12) = FIFO_BA then
			BUS_CYC <= '1';
		elsif DDR_STATE = DS_C3 then
			BUS_CYC <= CPU_REQ;
		end if;

		if DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and CPU_REQ = '1' then
			VA_S <= CPU_ROW_ADR;
			BA_S <= CPU_BA;
			DDR_ACCESS <= CPU;
		elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and FIFO_REQ = '1' then
			VA_P <= FIFO_ROW_ADR;
			BA_P <= FIFO_BA;
			DDR_ACCESS <= FIFO;
		elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and BLITTER_REQ = '0' then
			VA_P <= BLITTER_ROW_ADR;
			BA_P <= BLITTER_BA;
			DDR_ACCESS <= BLITTER;
		elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and FB_WRn = '0' then
			VA_S(10) <= '1';
			DDR_ACCESS <= CPU;
		elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and ACCESS_WIDTH /= LONG then
			VA_S(10) <= '1';
			DDR_ACCESS <= CPU;
		elsif DDR_STATE = DS_T2A then
			-- ?? mfro
			VA_S(10) <= not (FIFO_ACTIVE and FIFO_REQ);
			DDR_ACCESS <= FIFO;
			FIFO_BANK_OK <= FIFO_ACTIVE and FIFO_REQ;
			if DDR_ACCESS = BLITTER and BLITTER_REQ = '1' then
				DDR_ACCESS <= BLITTER;
			end if;
			-- ?? mfro BLITTER_AC <= BLITTER_ACTIVE and BLITTER_REQ;
		elsif DDR_STATE = DS_T2B then
			FIFO_BANK_OK <= '0';
		elsif DDR_STATE = DS_T3 then
			VA_S(10) <= VA_S(10);
			if (FB_WRn = '0' and DDR_ACCESS = CPU) or (BLITTER_WR = '1' and DDR_ACCESS = BLITTER) then
				VA_S(9 downto 0) <= CPU_COL_ADR;
				BA_S <= CPU_BA;
			elsif FIFO_ACTIVE = '1' then
				VA_S(9 downto 0) <= std_logic_vector(FIFO_COL_ADR);
				BA_S <= FIFO_BA;
			elsif DDR_ACCESS = BLITTER then
				VA_S(9 downto 0) <= BLITTER_COL_ADR;
				BA_S <= BLITTER_BA;
			end if;
		elsif DDR_STATE = DS_T4R then
			-- mfro change next two statements
			if DDR_ACCESS = CPU then
				SR_DDR_FB <= '1';
			elsif DDR_ACCESS = BLITTER then
				SR_BLITTER_DACK <= '1';
			end if;
		elsif DDR_STATE = DS_T5R and FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
			VA_S(10) <= '0';
			VA_S(9 downto 0) <= std_logic_vector(FIFO_COL_ADR);
			BA_S <= FIFO_BA;
		elsif DDR_STATE = DS_T5R then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T4W then
			VA_S(10) <= VA_S(10);
			-- mfro changed next if
			if DDR_ACCESS = BLITTER then
				SR_BLITTER_DACK <= '1';
			end if;
		elsif DDR_STATE = DS_T5W then
			VA_S(10) <= VA_S(10);
			if DDR_ACCESS = CPU then
				VA_S(9 downto 0) <= CPU_COL_ADR;
				BA_S <= CPU_BA;
			elsif DDR_ACCESS = BLITTER then
				VA_S(9 downto 0) <= BLITTER_COL_ADR;
				BA_S <= BLITTER_BA;
			end if;
			if DDR_ACCESS = BLITTER and ACCESS_WIDTH = LONG then
				SR_VDMP <= BYTE_SEL & x"F";
			elsif DDR_ACCESS = BLITTER then
				SR_VDMP <= BYTE_SEL & x"0";
			else
				SR_VDMP <= BYTE_SEL & x"0";
			end if;
		elsif DDR_STATE = DS_T6W then
			SR_DDR_WR <= '1';
			SR_DDRWR_D_SEL <= '1';
			if DDR_ACCESS = BLITTER or ACCESS_WIDTH = LONG then
				SR_VDMP <= x"FF";
			else
				SR_VDMP <= x"00";
			end if;
		elsif DDR_STATE = DS_T7W then
			SR_DDR_WR <= '1';
			SR_DDRWR_D_SEL <= '1';
		elsif DDR_STATE = DS_T9W and FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
			VA_S(10) <= '0';
			VA_S(9 downto 0) <= std_logic_vector(FIFO_COL_ADR);
			BA_S <= FIFO_BA;
		elsif DDR_STATE = DS_T9W then
			VA_S(10) <= '0';
		elsif DDR_STATE = DS_T4F then
			SR_FIFO_WRE_I <= '1';
		elsif DDR_STATE = DS_T5F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 downto 0) = x"FF" then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T5F and FIFO_REQ = '1' then
			VA_S(10) <= '0';
			VA_S(9 downto 0) <= std_logic_vector(FIFO_COL_ADR + "100");
			BA_S <= FIFO_BA;
		elsif DDR_STATE = DS_T5F then
			VA_S(10) <= '0';
		elsif DDR_STATE = DS_T6F then
			SR_FIFO_WRE_I <= '1';
		elsif DDR_STATE = DS_T7F and CPU_REQ = '1' and FIFO_MW > std_logic_vector(to_unsigned(FIFO_LWM, FIFO_MW'length)) then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T7F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 downto 0) = x"FF" then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T7F and FIFO_REQ = '1' then
			VA_S(10) <= '0';
			VA_S(9 downto 0) <= std_logic_vector(FIFO_COL_ADR + "100");
			BA_S <= FIFO_BA;
		elsif DDR_STATE = DS_T7F then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T9F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 downto 0) = x"FF" then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T9F and FIFO_REQ = '1' then
			VA_P(10) <= '0';
			VA_P(9 downto 0) <= std_logic_vector(FIFO_COL_ADR + "100");
			BA_P <= FIFO_BA;
		elsif DDR_STATE = DS_T9F then
			VA_S(10) <= '1';
		elsif DDR_STATE = DS_T10F and FB_WRn = '0' and DATA_IN(13 downto 12) = FIFO_BA then
			VA_S(10) <= '1';
			DDR_ACCESS <= CPU;
		elsif DDR_STATE = DS_T10F and ACCESS_WIDTH /= LONG and DATA_IN(13 downto 12) = FIFO_BA then
			VA_S(10) <= '1';
			DDR_ACCESS <= CPU;
		elsif DDR_STATE = DS_T10F then
			SR_FIFO_WRE_I <= '1';
		elsif DDR_STATE = DS_C6 then
			VA_S <= DATA_IN(12 downto 0);
			BA_S <= DATA_IN(14 downto 13);
		elsif DDR_STATE = DS_CB6 then
			FIFO_BANK_OK <= '0';
		elsif DDR_STATE = DS_CB8 then
			FIFO_BANK_OK <= '0';
		elsif DDR_STATE = DS_R2 then
			FIFO_BANK_OK <= '0';
		else
		end if;
	end process P_CLK0;

	DDR_SEL <= '1' when FB_ALE = '1' and DATA_IN(31 downto 30) = "01" else '0';

	P_DDR_CS: process
	begin
		wait until rising_edge(CLK_MAIN);
		if FB_ALE = '1' then
			DDR_CS <= DDR_SEL;
		end if;
	end process P_DDR_CS;
    
	P_CPU_REQ: process
	begin
		wait until rising_edge(DDR_SYNC_66M);

		if DDR_SEL = '1' and FB_WRn = '1' and DDR_CONFIG = '0' then
			CPU_REQ <= '1';
		elsif DDR_SEL = '1' and ACCESS_WIDTH /= LONG and DDR_CONFIG = '0' then -- Start when not config and not long word access.
			CPU_REQ <= '1';
		elsif DDR_SEL = '1' and DDR_CONFIG = '1' then -- Config, start immediately.
			CPU_REQ <= '1';
		elsif FB_REGDDR = FR_S1 and FB_WRn = '0' then -- Long word write later.
			CPU_REQ <= '1';
		elsif FB_REGDDR /= FR_S1 and FB_REGDDR /= FR_S3 and BUS_CYC_END = '0' and BUS_CYC = '0' then -- Halt, bus cycle in progress or ready.
			CPU_REQ <= '0';
		end if;
	end process P_CPU_REQ;
    
	P_REFRESH: process
		-- Refresh: Always 8 at a time every 7.8us.
		-- 7.8us x 8 = 62.4us = 2059 -> 2048 @ 33MHz.
	begin
		wait until rising_edge(CLK_33M);
		DDR_REFRESH_CNT <= DDR_REFRESH_CNT + 1; -- Count 0 to 2047.
	end process P_REFRESH;

	SR_FIFO_WRE <= SR_FIFO_WRE_I;
    
	VA <=   DATA_IN(26 downto 14) when DDR_STATE = DS_T2A and DDR_SEL = '1' and FB_WRn = '0' else
				DATA_IN(26 downto 14) when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
				VA_P when DDR_STATE = DS_T2A else
				DATA_IN(26 downto 14) when DDR_STATE = DS_T10F and FB_WRn = '0' and DATA_IN(13 downto 12) = FIFO_BA else
				DATA_IN(26 downto 14) when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 downto 12) = FIFO_BA else
				VA_P when DDR_STATE = DS_T10F else
				"0010000000000" when DDR_STATE = DS_R2 and DDR_REFRESH_SIG = x"9" else VA_S;

	BA <=   DATA_IN(13 downto 12) when DDR_STATE = DS_T2A and DDR_SEL = '1' and FB_WRn = '0' else
				DATA_IN(13 downto 12) when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
				BA_P when DDR_STATE = DS_T2A else
				DATA_IN(13 downto 12) when DDR_STATE = DS_T10F and FB_WRn = '0' and DATA_IN(13 downto 12) = FIFO_BA else
				DATA_IN(13 downto 12) when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 downto 12) = FIFO_BA else
				BA_P when DDR_STATE = DS_T10F else BA_S;
            
	VRAS <= '1' when DDR_STATE = DS_T2A and DDR_SEL = '1' and FB_WRn = '0' else
				'1' when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
				'1' when DDR_STATE = DS_T2A and DDR_ACCESS = FIFO and FIFO_REQ = '1' else
				'1' when DDR_STATE = DS_T2A and DDR_ACCESS = BLITTER and BLITTER_REQ = '1' else
				'1' when DDR_STATE = DS_T2B else
				'1' when DDR_STATE = DS_T10F and FB_WRn = '0' and DATA_IN(13 downto 12) = FIFO_BA else
				'1' when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 downto 12) = FIFO_BA else
				DATA_IN(18) and not FB_WRn and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
				'1' when DDR_STATE = DS_CB6 else
				'1' when DDR_STATE = DS_CB8 else
				'1' when DDR_STATE = DS_R2 else '0';

	VCAS <= '1' when DDR_STATE = DS_T4R else
				'1' when DDR_STATE = DS_T6W else
				'1' when DDR_STATE = DS_T4F else
				'1' when DDR_STATE = DS_T6F else
				'1' when DDR_STATE = DS_T8F else
				'1' when DDR_STATE = DS_T10F and VRAS = '0' else
				DATA_IN(17) and not FB_WRn and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
				'1' when DDR_STATE = DS_R2 and DDR_REFRESH_SIG /= x"9" else '0';

	VWE <= '1' when DDR_STATE = DS_T6W else
				DATA_IN(16) and not FB_WRn and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
				'1' when DDR_STATE = DS_CB6 else
				'1' when DDR_STATE = DS_CB8 else
				'1' when DDR_STATE = DS_R2 and DDR_REFRESH_SIG = x"9" else '0';

	-- DDR controller:
	-- VIDEO RAM CONTROL REGISTER (is in VIDEO_MUX_CTR) 
	-- $F0000400: BIT 0: VCKE; 1: not nVCS ;2:REFRESH ON , (0=FIFO and CNT CLEAR); 
	-- 3: CONFIG; 8: FIFO_ACTIVE; 
	VCKE <= VCKE_I;
	VCKE_I <= VIDEO_RAM_CTR(0);
	VCSn <= VCS_In;
	VCS_In <= not VIDEO_RAM_CTR(1);
	DDR_REFRESH_ON <= VIDEO_RAM_CTR(2);
	DDR_CONFIG <= VIDEO_RAM_CTR(3);
	FIFO_ACTIVE <= VIDEO_RAM_CTR(8);

	CPU_ROW_ADR <= FB_ADR(26 downto 14);
	CPU_BA <= FB_ADR(13 downto 12);
	CPU_COL_ADR <= FB_ADR(11 downto 2);
	VRASn <= not VRAS;
	VCASn <= not VCAS;
	VWEn <= not VWE;

	DDRWR_D_SEL1 <= '1' when DDR_ACCESS = BLITTER else '0';
	
	BLITTER_ROW_ADR <= BLITTER_ADR(26 downto 14);
	BLITTER_BA <= BLITTER_ADR(13 downto 12);
	BLITTER_COL_ADR <= BLITTER_ADR(11 downto 2);

	FIFO_ROW_ADR <= std_logic_vector(VIDEO_ADR_CNT(22 downto 10));
	FIFO_BA <= std_logic_vector(VIDEO_ADR_CNT(9 downto 8));
	FIFO_COL_ADR <= VIDEO_ADR_CNT(7 downto 0) & "00";

	VIDEO_BASE_ADR(22 downto 20) <= VIDEO_BASE_X_D;
	VIDEO_BASE_ADR(19 downto 12) <= VIDEO_BASE_H_D;
	VIDEO_BASE_ADR(11 downto 4)  <= VIDEO_BASE_M_D;
	VIDEO_BASE_ADR(3 downto 0)   <= VIDEO_BASE_L_D(7 downto 4);

	VDM_SEL <= VDM_SEL_I;
	VDM_SEL_I <= VIDEO_BASE_L_D(3 downto 0);

	-- Current video address:
	VIDEO_ACT_ADR(26 downto 4) <= std_logic_vector(VIDEO_ADR_CNT - unsigned(FIFO_MW));
	VIDEO_ACT_ADR(3 downto 0) <= VDM_SEL_I;

	P_VIDEO_REGS: process
	-- Video registers.
	begin
		wait until rising_edge(CLK_MAIN);
		if VIDEO_BASE_L = '1' and FB_WRn = '0' and BYTE_SEL(1) = '1' then
			VIDEO_BASE_L_D <= DATA_IN(23 downto 16); -- 16 byte boarders.
		end if;
          
		if VIDEO_BASE_M = '1' and FB_WRn = '0' and BYTE_SEL(3) = '1' then
			VIDEO_BASE_M_D <= DATA_IN(23 downto 16);
		end if;

		if VIDEO_BASE_H = '1' and FB_WRn = '0' and BYTE_SEL(1) = '1' then
			VIDEO_BASE_H_D <= DATA_IN(23 downto 16);
		end if;

		if VIDEO_BASE_H = '1' and FB_WRn = '0' and BYTE_SEL(0) = '1' then
			VIDEO_BASE_X_D <= DATA_IN(26 downto 24);
		end if;
	end process P_VIDEO_REGS;

	FB_ADR_I <= FB_ADR & '0';

	VIDEO_BASE_L <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"820D" else '0'; -- x"FF820D".
	VIDEO_BASE_M <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"8204" else '0'; -- x"FF8203". 
	VIDEO_BASE_H <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"8202" else '0'; -- x"FF8201".

	VIDEO_CNT_L <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"8208" else '0'; -- x"FF8209".
	VIDEO_CNT_M <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"8206" else '0'; -- x"FF8207". 
	VIDEO_CNT_H <= '1' when FB_CS1n = '0' and FB_ADR_I(15 downto 0) = x"8204" else '0'; -- x"FF8205".

	DATA_OUT(31 downto 24) <= "00000" & VIDEO_BASE_X_D when VIDEO_BASE_H = '1' else
										"00000" & VIDEO_ACT_ADR(26 downto 24) when VIDEO_CNT_H = '1' else (others => '0');

	DATA_EN_H <= (VIDEO_BASE_H or VIDEO_CNT_H) and not FB_OEn;

	DATA_OUT(23 downto 16) <= VIDEO_BASE_L_D when VIDEO_BASE_L = '1' else
										VIDEO_BASE_M_D when VIDEO_BASE_M = '1' else
										VIDEO_BASE_H_D when VIDEO_BASE_H = '1' else
										VIDEO_ACT_ADR(7 downto 0) when VIDEO_CNT_L = '1' else
										VIDEO_ACT_ADR(15 downto 8) when VIDEO_CNT_M = '1' else
										VIDEO_ACT_ADR(23 downto 16) when VIDEO_CNT_H = '1' else (others => '0');
                      
	DATA_EN_L <= (VIDEO_BASE_L or VIDEO_BASE_M or VIDEO_BASE_H or VIDEO_CNT_L or VIDEO_CNT_M or VIDEO_CNT_H) and not FB_OEn;
end architecture BEHAVIOUR;
-- VA           : Video DDR address multiplexed
-- VA_P         : latched VA, wenn FIFO_AC, BLITTER_AC
-- VA_S         : latch for default VA
-- BA           : Video DDR bank address multiplexed
-- BA_P         : latched BA, wenn FIFO_AC, BLITTER_AC
-- BA_S         : latch for default BA
--
--FB_SIZE ersetzen.