----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- Some remarks to the required input clock:                    ----
---- This core is provided for a 16MHz input clock. To use other  ----
---- frequencies, it is necessary to modify the following proces- ----
---- ses in the control file section:                             ----
---- P_BUSFREE, DELAY_800, INTERRUPTS.                            ----
----                                                              ----
---- This file is the top level file without tree state buses for ----
---- use in 'systems on chip' designs.                            ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
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

library work;
use work.wf5380_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WF5380_TOP_SOC is
 port (
        -- System controls:
  CLK   : in std_logic; -- Use a 16MHz Clock.
  RESETn  : in std_logic;
  
  -- Address and data:
  ADR   : in std_logic_vector(2 downto 0);
  DATA_IN  : in std_logic_vector(7 downto 0);
  DATA_OUT : out std_logic_vector(7 downto 0);
  DATA_EN  : out std_logic;

  -- Bus and DMA controls:
  CSn   : in std_logic;
  RDn   : in std_logic;
  WRn   : in std_logic;
  EOPn        : in std_logic;
  DACKn     : in std_logic;
  DRQ      : out std_logic;
  INT      : out std_logic;
  READY       : out std_logic;
  
  -- SCSI bus:
  DB_INn  : in std_logic_vector(7 downto 0);
  DB_OUTn  : out std_logic_vector(7 downto 0);
  DB_EN       : out std_logic;
  DBP_INn  : in std_logic;
  DBP_OUTn : out std_logic;
  DBP_EN      : out std_logic;
  RST_INn     : in std_logic;
  RST_OUTn    : out std_logic;
  RST_EN      : out std_logic;
  BSY_INn     : in std_logic;
  BSY_OUTn    : out std_logic;
  BSY_EN      : out std_logic;
  SEL_INn     : in std_logic;
  SEL_OUTn    : out std_logic;
  SEL_EN      : out std_logic;
  ACK_INn     : in std_logic;
  ACK_OUTn    : out std_logic;
  ACK_EN      : out std_logic;
  ATN_INn     : in std_logic;
  ATN_OUTn    : out std_logic;
  ATN_EN      : out std_logic;
  REQ_INn     : in std_logic;
  REQ_OUTn    : out std_logic;
  REQ_EN      : out std_logic;
  IOn_IN      : in std_logic;
  IOn_OUT     : out std_logic;
  IO_EN       : out std_logic;
  CDn_IN      : in std_logic;
  CDn_OUT     : out std_logic;
  CD_EN       : out std_logic;
  MSG_INn     : in std_logic;
  MSG_OUTn    : out std_logic;
  MSG_EN      : out std_logic
 );
end entity WF5380_TOP_SOC;
 
architecture STRUCTURE of WF5380_TOP_SOC is
signal ACK_OUT_CTRLn    : std_logic;
signal AIP              : std_logic;
signal ARB              : std_logic;
signal ARB_EN           : std_logic;
signal BLK              : std_logic;
signal BSR              : std_logic_vector(7 downto 0);
signal BSY_DISn         : std_logic;
signal BSY_ERR          : std_logic;
signal BSY_OUT_CTRLn    : std_logic;
signal CHK_PAR          : std_logic;
signal CSD              : std_logic_vector(7 downto 0);
signal CSB              : std_logic_vector(7 downto 0);
signal DATA_EN_CTRL     : std_logic;
signal DB_EN_I          : std_logic;
signal DMA_ACTIVE       : std_logic;
signal DMA_EN           : std_logic;
signal DMA_DIS          : std_logic;
signal DMA_SND          : std_logic;
signal DRQ_I            : std_logic;
signal EDMA             : std_logic;
signal EOP_EN           : std_logic;
signal ICR              : std_logic_vector(7 downto 0);
signal IDR_WR           : std_logic;
signal INT_I            : std_logic;
signal LA               : std_logic;
signal ODR              : std_logic_vector(7 downto 0);
signal ODR_WR           : std_logic;
signal PCHK             : std_logic;
signal PHSM             : std_logic;
signal PINT_EN          : std_logic;
signal REQ_OUT_CTRLn    : std_logic;
signal RPI              : std_logic;
signal RST              : std_logic;
signal SDI              : std_logic;
signal SDS              : std_logic;
signal SDT              : std_logic;
signal SER              : std_logic_vector(7 downto 0);
signal SER_ID           : std_logic;
signal SPER             : std_logic;
signal TARG             : std_logic;
signal TCR              : std_logic_vector(3 downto 0);
begin
    EDMA <= '1' when EOPn = '0' and DACKn = '0' and RDn = '0' else
            '1' when EOPn = '0' and DACKn = '0' and WRn = '0' else '0';

    PHSM <= '1' when DMA_ACTIVE = '0' else -- Always true, if there is no DMA.
            '1' when DMA_ACTIVE = '1' and REQ_INn = '0' and CDn_In = TCR(1) and IOn_IN = TCR(0) and MSG_INn = TCR(2) else '0'; -- Phasematch.

    DMA_DIS <= '1' when DMA_ACTIVE = '1' and BSY_INn = '1' else '0';

    SER_ID <= '1' when SER /= x"00" and SER = not CSD else '0';

    DRQ <= DRQ_I;
    INT <= INT_I;

    -- Pay attention: the SCSI bus is driven with inverted signals.
    ACK_OUTn <= ACK_OUT_CTRLn when DMA_ACTIVE = '1' else not ICR(4); -- Valid in initiator mode.
    REQ_OUTn <= REQ_OUT_CTRLn when DMA_ACTIVE = '1' else not TCR(3);  -- Valid in Target mode.
    BSY_OUTn <= '0' when BSY_OUT_CTRLn = '0' and TARG = '0' else -- Valid in initiator mode.
                '0' when ICR(3) = '1' else '1';
    ATN_OUTn <= not ICR(1); -- Valid in initiator mode.
    SEL_OUTn <= not ICR(2); -- Valid in initiator mode.
    IOn_OUT <= not TCR(0);  -- Valid in Target mode.
    CDn_OUT <= not TCR(1);  -- Valid in Target mode.
    MSG_OUTn <= not TCR(2);  -- Valid in Target mode.
    RST_OUTn <= not RST;

    DB_OUTn <= not ODR;
    DBP_OUTn <= not SPER; 

    CSD <= not DB_INn;
    CSB <= not RST_INn & not BSY_INn & not REQ_INn & not MSG_INn & not CDn_IN & not IOn_IN & not SEL_INn & not DBP_INn;
    BSR <= EDMA & DRQ_I & SPER & INT_I & PHSM & BSY_ERR & not ATN_INn & not ACK_INn;

    -- Hi impedance control:
    ATN_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    SEL_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    BSY_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    ACK_EN <= '1' when TARG = '0' else '0'; -- Initiator mode.
    IO_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    CD_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    MSG_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    REQ_EN <= '1' when TARG = '1' else '0'; -- Target mode.
    RST_EN <= '1' when RST = '1' else '0'; -- Open drain control.
    
    -- Data enables:
    DB_EN_I <= '1' when DATA_EN_CTRL = '1' else -- During Arstd_logicration.
               '1' when ICR(0) = '1' and TARG = '1' and DMA_SND = '1' else -- Target 'Send' mode.
               '1' when ICR(0) = '1' and TARG = '0' and IOn_IN = '0' and PHSM = '1' else 
               '1' when ICR(6) = '1' else '0'; -- Test mode enable.

    DB_EN <= DB_EN_I;
    DBP_EN <= DB_EN_I;

    I_REGISTERS: WF5380_REGISTERS
        port map(
            CLK   => CLK,
            RESETn     => RESETn,
            ADR   => ADR,
            DATA_IN  => DATA_IN,
            DATA_OUT => DATA_OUT,
            DATA_EN  => DATA_EN,
            CSn   => CSn,
            RDn      => RDn,
            WRn         => WRn,
            RSTn     => RST_INn,
            RST         => RST,
            ARB_EN      => ARB_EN,
            DMA_ACTIVE  => DMA_ACTIVE,
            DMA_EN      => DMA_EN,
            BSY_DISn    => BSY_DISn,
            EOP_EN      => EOP_EN,
            PINT_EN     => PINT_EN,
            SPER        => SPER,
            TARG        => TARG,
            BLK         => BLK,
            DMA_DIS     => DMA_DIS,
            IDR_WR      => IDR_WR,
            ODR_WR      => ODR_WR,
            CHK_PAR     => CHK_PAR,
            AIP         => AIP,
            ARB         => ARB,
            LA          => LA,
            CSD         => CSD,
            CSB         => CSB,
            BSR         => BSR,
            ODR_OUT     => ODR,
            ICR_OUT     => ICR,
            TCR_OUT     => TCR,
            SER_OUT     => SER,
            SDS         => SDS,
            SDT         => SDT,
            SDI         => SDI,
            RPI         => RPI
        );

    I_CONTROL: WF5380_CONTROL
        port map(
            CLK   => CLK,
            RESETn     => RESETn,
            BSY_INn     => BSY_INn,
            BSY_OUTn    => BSY_OUT_CTRLn,
            DATA_EN     => DATA_EN_CTRL,
            SEL_INn     => SEL_INn,
            ARB_EN      => ARB_EN,
            BSY_DISn    => BSY_DISn,
            RSTn     => RST_INn,
            ARB         => ARB,
            AIP         => AIP,
            LA          => LA,
            ACK_INn     => ACK_INn,
            ACK_OUTn    => ACK_OUT_CTRLn,
            REQ_INn     => REQ_INn,
            REQ_OUTn    => REQ_OUT_CTRLn,
            DACKn       => DACKn,
            READY       => READY,
            DRQ         => DRQ_I,
            TARG        => TARG,
            BLK         => BLK,
            PINT_EN     => PINT_EN,
            SPER        => SPER,
            SER_ID      => SER_ID,
            RPI         => RPI,
            DMA_EN      => DMA_EN,
            SDS         => SDS,
            SDT         => SDT,
            SDI         => SDI,
            EOP_EN      => EOP_EN,
            EOPn        => EOPn,
            PHSM        => PHSM,
            INT         => INT_I,
            IDR_WR      => IDR_WR,
            ODR_WR      => ODR_WR,
            CHK_PAR     => CHK_PAR,
            BSY_ERR     => BSY_ERR,
            DMA_SND     => DMA_SND,
            DMA_ACTIVE  => DMA_ACTIVE
        );
end STRUCTURE;

architecture LIGHT of WF5380_TOP_SOC is
begin
end LIGHT;
