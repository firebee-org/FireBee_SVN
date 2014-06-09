----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the package file of the ip core.                ----
----                                                              ----
----                                                              ----
----                                                              ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright © 2009-2010 Wolfgang Foerster Inventronik GmbH.    ----
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

library ieee;
use ieee.std_logic_1164.all;

package WF5380_PKG is
    component WF5380_REGISTERS
        port (
            CLK			: in bit;
            RESETn	    : in bit;
            ADR			: in bit_vector(2 downto 0);
            DATA_IN		: in bit_vector(7 downto 0);
            DATA_OUT	: out bit_vector(7 downto 0);
            DATA_EN		: out bit;
            CSn			: in bit;
            RDn		    : in bit;
            WRn	        : in bit;
            RSTn	    : in bit;
            RST         : out bit;
            ARB_EN      : out bit;
            DMA_ACTIVE  : in bit;
            DMA_EN      : out bit;
            BSY_DISn    : out bit;
            EOP_EN      : out bit;
            PINT_EN     : out bit;
            SPER        : out bit;
            TARG        : out bit;
            BLK         : out bit;
            DMA_DIS     : in bit;
            IDR_WR      : in bit;
            ODR_WR      : in bit;
            CHK_PAR     : in bit;
            AIP         : in bit;
            ARB         : in bit;
            LA          : in bit;
            CSD         : in bit_vector(7 downto 0);
            CSB         : in bit_vector(7 downto 0);
            BSR         : in bit_vector(7 downto 0);
            ODR_OUT     : out bit_vector(7 downto 0);
            ICR_OUT     : out bit_vector(7 downto 0);
            TCR_OUT     : out bit_vector(3 downto 0);
            SER_OUT     : out bit_vector(7 downto 0);
            SDS         : out bit;
            SDT         : out bit;
            SDI         : out bit;
            RPI         : out bit
        );
    end component;

    component WF5380_CONTROL
        port (
            CLK			: in bit;
            RESETn	    : in bit;
            BSY_INn     : in bit;
            BSY_OUTn    : out bit;
            DATA_EN     : out bit;
            SEL_INn     : in bit;
            ARB_EN      : in bit;
            BSY_DISn    : in bit;
            RSTn	    : in bit;
            ARB         : out bit;
            AIP         : out bit;
            LA          : out bit;
            ACK_INn     : in bit;
            ACK_OUTn    : out bit;
            REQ_INn     : in bit;
            REQ_OUTn    : out bit;
            DACKn       : in bit;
            READY       : out bit;
            DRQ         : out bit;
            TARG        : in bit;
            BLK         : in bit;
            PINT_EN     : in bit;
            SPER        : in bit;
            SER_ID      : in bit;
            RPI         : in bit;
            DMA_EN      : in bit;
            SDS         : in bit;
            SDT         : in bit;
            SDI         : in bit;
            EOP_EN      : in bit;
            EOPn        : in bit;
            PHSM        : in bit;
            INT         : out bit;
            IDR_WR      : out bit;
            ODR_WR      : out bit;
            CHK_PAR     : out bit;
            BSY_ERR     : out bit;
            DMA_SND     : out bit;
            DMA_ACTIVE  : out bit
        );
    end component;
end WF5380_PKG;
