----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the 5380's register model.                      ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Register description (for more information see the DP5380    ----
---- data sheet:                                                  ----
----   ODR (address 0) Output data register, write only.          ----
----   CSD (address 0) Current SCSI data, read only.              ----
----   ICR (address 1) Initiator command register, read/write.    ----
----   MR2 (address 2) Mode register 2, read/write.               ----
----   TCR (address 3) Target command register, read/write.       ----
----   SER (address 4) Select enable register, write only.        ----
----   CSB (address 4) Current SCSI bus status, read only.        ----
----   BSR (address 5) Start DMA send, write only.                ----
----   SDS (address 5) Bus and status, read only.                 ----
----   SDT (address 6) Start DMA target receive, write only.      ----
----   IDR (address 6) Input data register, read only.            ----
----   SDI (address 7) Start DMA initiator recive, write only.    ----
----   RPI (address 7) Reset parity / interrupts, read only.      ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright � 2009-2010 Wolfgang Foerster Inventronik GmbH.    ----
---- All rights reserved. No portion of this sourcecode may be    ----
---- reproduced or transmitted in any form by any means, whether  ----
---- by electronic, mechanical, photocopying, recording or        ----
---- otherwise, without my written permission.                    ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K9A  2009/06/20 WF
--   Initial Release.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WF5380_REGISTERS is
	port (
        -- System controls:
		CLK			: in std_logic;
		RESETn	    : in std_logic; -- System reset.
		
		-- Address and data:
		ADR			: in std_logic_vector(2 downto 0);
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_EN		: out std_logic;

		-- Bus and DMA controls:
		CSn			: in std_logic;
		RDn		    : in std_logic;
		WRn	        : in std_logic;

        -- Core controls:
		RSTn	    : in std_logic; -- SCSI reset.
		RST         : out std_logic; -- Programmed SCSI reset.
        ARB_EN      : out std_logic; -- Arstd_logicration enable.
        DMA_ACTIVE  : in std_logic; -- DMA is running.
        DMA_EN      : out std_logic; -- DMA mode enable.
        BSY_DISn    : out std_logic; -- BSY monitoring enable.
        EOP_EN      : out std_logic; -- EOP interrupt enable.
        PINT_EN     : out std_logic; -- Parity interrupt enable.
        SPER        : out std_logic; -- Parity error.
        TARG        : out std_logic; -- Target mode.
        BLK         : out std_logic; -- Block DMA mode.
        DMA_DIS     : in std_logic; -- Reset the DMA_EN by this signal.
        IDR_WR      : in std_logic; -- Write input data register during DMA.
        ODR_WR      : in std_logic; -- Write output data register, during DMA.
        CHK_PAR     : in std_logic; -- Check Parity during DMA operation.
        AIP         : in std_logic; -- Arstd_logicration in progress.
        ARB         : in std_logic; -- Arstd_logicration.
        LA          : in std_logic; -- Lost arstd_logicration.

        CSD         : in std_logic_vector(7 downto 0); -- SCSI data.
        CSB         : in std_logic_vector(7 downto 0); -- Current SCSI bus status.
        BSR         : in std_logic_vector(7 downto 0); -- Bus and status.

        ODR_OUT     : out std_logic_vector(7 downto 0); -- This is the ODR register.
        ICR_OUT     : out std_logic_vector(7 downto 0); -- This is the ICR register.
        TCR_OUT     : out std_logic_vector(3 downto 0); -- This is the TCR register.
        SER_OUT     : out std_logic_vector(7 downto 0); -- This is the SER register.
        
		SDS         : out std_logic; -- Start DMA send, write only.
		SDT         : out std_logic; -- Start DMA target receive, write only.
		SDI         : out std_logic; -- Start DMA initiator receive, write only.
		RPI         : out std_logic
    );
end entity WF5380_REGISTERS;
	
architecture BEHAVIOUR of WF5380_REGISTERS is
signal ICR  : std_logic_vector(7 downto 0); -- Initiator command register, read/write.
signal IDR  : std_logic_vector(7 downto 0); -- Input data register.
signal MR2  : std_logic_vector(7 downto 0); -- Mode register 2, read/write.
signal ODR  : std_logic_vector(7 downto 0); -- Output data register, write only.
signal SER  : std_logic_vector(7 downto 0); -- Select enable register, write only.
signal TCR  : std_logic_vector(3 downto 0); -- Target command register, read/write.
begin
    REGISTERS: process(RESETn, CLK)
    -- This process reflects all registers in the 5380.
    variable BSY_LOCK   : boolean;
    begin
        if RESETn = '0' then
            ODR <= (others => '0');
            ICR <= (others => '0');
            MR2 <= (others => '0');
            TCR <= (others => '0');
            SER <= (others => '0');
            BSY_LOCK  := false;
        elsif CLK = '1' and CLK' event then
            if RSTn = '0' then -- SCSI reset.
                ODR <= (others => '0');
                ICR(6 downto 0) <= (others => '0');
                MR2(7) <= '0';
                MR2(5 downto 0) <= (others => '0');
                TCR <= (others => '0');
                SER <= (others => '0');
                BSY_LOCK  := false;
            elsif ADR = "000" and CSn = '0' and WRn = '0' then
                ODR <= DATA_IN;
            elsif ADR = "001" and CSn = '0' and WRn = '0' then
                ICR <= DATA_IN;
            elsif ADR = "010" and CSn = '0' and WRn = '0' then
                MR2 <= DATA_IN;
            elsif ADR = "011" and CSn = '0' and WRn = '0' then
                TCR <= DATA_IN(3 downto 0);
            elsif ADR = "100" and CSn = '0' and WRn = '0' then
                SER <= DATA_IN;
            end if;
            --
            if ODR_WR = '1' then
                ODR <= DATA_IN;
            end if;
            --
            -- This reset function is edge triggered on the 'Monitor Busy'
            -- MR2(2).
            if MR2(2) = '1' and BSY_LOCK = false then
                ICR(5 downto 0) <= "000000";
                BSY_LOCK := true;
            elsif MR2(2) = '0' then
                BSY_LOCK := false;
            end if;
            --
            if DMA_DIS = '1' then
                MR2(1) <= '0';
            end if;
        end if;
    end process REGISTERS;
    
    IDR_REGISTER: process(RESETn, CLK)
    begin
        if RESETn = '0' then
            IDR <= x"00";
        elsif CLK = '1' and CLK' event then
            if RSTn = '0' or ICR(7) = '1' then
                IDR <= x"00"; -- SCSI reset.
            elsif IDR_WR = '1' then
                IDR <= CSD;
            end if;
        end if;
    end process IDR_REGISTER;
    
    PARITY: process(RESETn, CLK)
    -- This is the parity generating logic with it's related
    -- error generation.
	variable PAR_VAR : std_logic;
	variable LOCK : boolean;
    begin
        if RESETn = '0' then
            SPER <= '0';
            LOCK := false;
        elsif CLK = '1' and CLK' event then
            -- Parity checked during 'Read from CSD' 
            -- (registered I/O and selection/reselection):
            if ADR = "000" and CSn = '0' and RDn = '0' and LOCK = false then
                for i in 1 to 7 loop
                    PAR_VAR := CSD(i) xor CSD(i-1);
                end loop;
                SPER <= not PAR_VAR;
                LOCK := true;
            end if;
            --
            -- Parity checking during DMA operation:
            if DMA_ACTIVE = '1' and CHK_PAR = '1' then
                for i in 1 to 7 loop
                    PAR_VAR := IDR(i) xor IDR(i-1);
                end loop;
                SPER <= not PAR_VAR;
                LOCK := true;
            end if;
            --
            -- Reset parity flag:
            if MR2(5) <= '0' then -- MR2(5) = PCHK (disabled).
                SPER <= '0';
            elsif ADR = "111" and CSn = '0' and RDn = '0' then -- Reset parity/interrupts.
                SPER <= '0';
                LOCK := false;
            end if;
        end if;
    end process PARITY;

    DATA_EN <= '1' when ADR < "101" and CSn = '0' and WRn = '0' else '0';

    SDS <= '1' when ADR = "101" and CSn = '0' and WRn = '0' else '0';
    SDT <= '1' when ADR = "110" and CSn = '0' and WRn = '0' else '0';
    SDI <= '1' when ADR = "111" and CSn = '0' and WRn = '0' else '0';
    
    ICR_OUT <= ICR;
    TCR_OUT <= TCR;
    SER_OUT <= SER;
    ODR_OUT <= ODR;
    
    ARB_EN  <= MR2(0);
    DMA_EN  <= MR2(1);
    BSY_DISn  <= MR2(2);
    EOP_EN  <= MR2(3);
    PINT_EN <= MR2(4);
    TARG    <= MR2(6);
    BLK     <= MR2(7);
    
    RST     <= ICR(7);
       
    -- Readback, unused std_logic positions are read back zero.
    DATA_OUT <= CSD when ADR = "000" and CSn = '0' and RDn = '0' else -- Current SCSI data.
                ICR(7) & AIP & LA & ICR(4 downto 0) when ADR = "001" and CSn = '0' and RDn = '0' else
                MR2 when ADR = "010" and CSn = '0' and RDn = '0' else
                x"0" & TCR when ADR = "011" and CSn = '0' and RDn = '0' else
                CSB when ADR = "100" and CSn = '0' and RDn = '0' else -- Current SCSI bus status.
                BSR when ADR = "101" and CSn = '0' and RDn = '0' else -- Bus and status.
                IDR when ADR = "110" and CSn = '0' and RDn = '0' else x"00"; -- Input data register.

    RPI <= '1' when ADR = "111" and CSn = '0' and RDn = '0' else '0'; -- Reset parity/interrupts.
end BEHAVIOUR;

architecture LIGHT of WF5380_REGISTERS is
begin
end LIGHT;