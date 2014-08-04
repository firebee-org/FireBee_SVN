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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package WF5380_PKG is
	component WF5380_REGISTERS
		port (
			CLK			: in std_logic;
			RESETn		: in std_logic;
			ADR			: in std_logic_vector(2 downto 0);
			DATA_IN		: in std_logic_vector(7 downto 0);
			DATA_OUT		: out std_logic_vector(7 downto 0);
			DATA_EN		: out std_logic;
			CSn			: in std_logic;
			RDn			: in std_logic;
			WRn			: in std_logic;
			RSTn			: in std_logic;
			RST         : out std_logic;
			ARB_EN      : out std_logic;
			DMA_ACTIVE  : in std_logic;
			DMA_EN      : out std_logic;
			BSY_DISn    : out std_logic;
			EOP_EN      : out std_logic;
			PINT_EN     : out std_logic;
			SPER        : out std_logic;
			TARG        : out std_logic;
			BLK         : out std_logic;
			DMA_DIS     : in std_logic;
			IDR_WR      : in std_logic;
			ODR_WR      : in std_logic;
			CHK_PAR     : in std_logic;
			AIP         : in std_logic;
			ARB         : in std_logic;
			LA          : in std_logic;
			CSD         : in std_logic_vector(7 downto 0);
			CSB         : in std_logic_vector(7 downto 0);
			BSR         : in std_logic_vector(7 downto 0);
			ODR_OUT     : out std_logic_vector(7 downto 0);
			ICR_OUT     : out std_logic_vector(7 downto 0);
			TCR_OUT     : out std_logic_vector(3 downto 0);
			SER_OUT     : out std_logic_vector(7 downto 0);
			SDS         : out std_logic;
			SDT         : out std_logic;
			SDI         : out std_logic;
			RPI         : out std_logic
		);
	end component;

	component WF5380_CONTROL
		port (
			CLK			: in std_logic;
			RESETn	    : in std_logic;
			BSY_INn     : in std_logic;
            BSY_OUTn    : out std_logic;
            DATA_EN     : out std_logic;
            SEL_INn     : in std_logic;
            ARB_EN      : in std_logic;
            BSY_DISn    : in std_logic;
            RSTn	    : in std_logic;
            ARB         : out std_logic;
            AIP         : out std_logic;
            LA          : out std_logic;
            ACK_INn     : in std_logic;
            ACK_OUTn    : out std_logic;
            REQ_INn     : in std_logic;
            REQ_OUTn    : out std_logic;
            DACKn       : in std_logic;
            READY       : out std_logic;
            DRQ         : out std_logic;
            TARG        : in std_logic;
            BLK         : in std_logic;
            PINT_EN     : in std_logic;
            SPER        : in std_logic;
            SER_ID      : in std_logic;
            RPI         : in std_logic;
            DMA_EN      : in std_logic;
            SDS         : in std_logic;
            SDT         : in std_logic;
            SDI         : in std_logic;
            EOP_EN      : in std_logic;
            EOPn        : in std_logic;
            PHSM        : in std_logic;
            INT         : out std_logic;
            IDR_WR      : out std_logic;
            ODR_WR      : out std_logic;
            CHK_PAR     : out std_logic;
            BSY_ERR     : out std_logic;
            DMA_SND     : out std_logic;
            DMA_ACTIVE  : out std_logic
        );
    end component;
end WF5380_PKG;
