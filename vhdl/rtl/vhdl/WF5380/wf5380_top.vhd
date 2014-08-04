----------------------------------------------------------------------
----                                                              ----
---- WF5380 IP Core                                               ----
----                                                              ----
---- Description:                                                 ----
---- This model provides an asynchronous SCSI interface compa-    ----
---- tible to the DP5380 from National Semiconductor and others.  ----
----                                                              ----
---- This file is the top level file with tree state buses.       ----
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
-- 

library work;
use work.wf5380_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WF5380_TOP is
	port (
        -- System controls:
		CLK			: in std_logic;
		RESETn	    : in std_logic;
		
		-- Address and data:
		ADR			: in std_logic_vector(2 downto 0);
		DATA		: inout std_logic_vector(7 downto 0);

		-- Bus and DMA controls:
		CSn			: in std_logic;
		RDn		    : in std_logic;
		WRn	        : in std_logic;
		EOPn        : in std_logic;
		DACKn	    : in std_logic;
		DRQ		    : out std_logic;
		INT		    : out std_logic;
		READY       : out std_logic;
		
		-- SCSI bus:
		DBn		    : inout std_logic_vector(7 downto 0);
		DBPn        : inout std_logic;
		RSTn        : inout std_logic;
		BSYn        : inout std_logic;
		SELn        : inout std_logic;
		ACKn        : inout std_logic;
		ATNn        : inout std_logic;
		REQn        : inout std_logic;
		IOn         : inout std_logic;
		CDn         : inout std_logic;
		MSGn        : inout std_logic
	);
end entity WF5380_TOP;
	
architecture STRUCTURE of WF5380_TOP is
component WF5380_TOP_SOC
	port (
        -- System controls:
		CLK			: in std_logic;
		RESETn	    : in std_logic;
		ADR			: in std_logic_vector(2 downto 0);
		DATA_IN		: in std_logic_vector(7 downto 0);
		DATA_OUT	: out std_logic_vector(7 downto 0);
		DATA_EN		: out std_logic;
		CSn			: in std_logic;
		RDn		    : in std_logic;
		WRn	        : in std_logic;
		EOPn        : in std_logic;
		DACKn	    : in std_logic;
		DRQ		    : out std_logic;
		INT		    : out std_logic;
		READY       : out std_logic;
		DB_INn		: in std_logic_vector(7 downto 0);
		DB_OUTn		: out std_logic_vector(7 downto 0);
		DB_EN       : out std_logic;
		DBP_INn		: in std_logic;
		DBP_OUTn	: out std_logic;
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
end component;
--
signal ADR_IN       : std_logic_vector(2 downto 0);
signal DATA_IN      : std_logic_vector(7 downto 0);
signal DATA_OUT     : std_logic_vector(7 downto 0);
signal DATA_EN      : std_logic;
signal DB_INn	    : std_logic_vector(7 downto 0);
signal DB_OUTn	    : std_logic_vector(7 downto 0);
signal DB_EN        : std_logic;
signal DBP_INn	    : std_logic;
signal DBP_OUTn	    : std_logic;
signal DBP_EN       : std_logic;
signal RST_INn      : std_logic;
signal RST_OUTn     : std_logic;
signal RST_EN       : std_logic;
signal BSY_INn      : std_logic;
signal BSY_OUTn     : std_logic;
signal BSY_EN       : std_logic;
signal SEL_INn      : std_logic;
signal SEL_OUTn     : std_logic;
signal SEL_EN       : std_logic;
signal ACK_INn      : std_logic;
signal ACK_OUTn     : std_logic;
signal ACK_EN       : std_logic;
signal ATN_INn      : std_logic;
signal ATN_OUTn     : std_logic;
signal ATN_EN       : std_logic;
signal REQ_INn      : std_logic;
signal REQ_OUTn     : std_logic;
signal REQ_EN       : std_logic;
signal IOn_IN       : std_logic;
signal IOn_OUT      : std_logic;
signal IO_EN        : std_logic;
signal CDn_IN       : std_logic;
signal CDn_OUT      : std_logic;
signal CD_EN        : std_logic;
signal MSG_INn      : std_logic;
signal MSG_OUTn     : std_logic;
signal MSG_EN       : std_logic;
begin
    ADR_IN <= ADR;

    DATA_IN <= DATA;
    DATA <= DATA_OUT when DATA_EN = '1' else (others => 'Z');

    DB_INn <= DBn;
    DBn <= DB_OUTn when DB_EN = '1' else (others => 'Z');

    DBP_INn <= DBPn;

    RST_INn <= RSTn;
    BSY_INn <= BSYn;
    SEL_INn <= SELn;
    ACK_INn <= ACKn;
    ATN_INn <= ATNn;
    REQ_INn <= REQn;
    IOn_IN <= IOn;
    CDn_IN <= CDn;
    MSG_INn <= MSGn;

    DBPn <= '1' when DBP_OUTn = '1' and DBP_EN = '1' else
            '0' when DBP_OUTn = '0' and DBP_EN = '1' else 'Z';
    RSTn <= '1' when RST_OUTn = '1' and RST_EN = '1'else
            '0' when RST_OUTn = '0' and RST_EN = '1' else 'Z';
    BSYn <= '1' when BSY_OUTn = '1' and BSY_EN = '1' else
            '0' when BSY_OUTn = '0' and BSY_EN = '1' else 'Z';
    SELn <= '1' when SEL_OUTn = '1' and SEL_EN = '1' else
            '0' when SEL_OUTn = '0' and SEL_EN = '1' else 'Z';
    ACKn <= '1' when ACK_OUTn = '1' and ACK_EN = '1' else
            '0' when ACK_OUTn = '0' and ACK_EN = '1' else 'Z';
    ATNn <= '1' when ATN_OUTn = '1' and ATN_EN = '1' else
            '0' when ATN_OUTn = '0' and ATN_EN = '1' else 'Z';
    REQn <= '1' when REQ_OUTn = '1' and REQ_EN = '1' else
            '0' when REQ_OUTn = '0' and REQ_EN = '1' else 'Z';
    IOn <=  '1' when IOn_OUT = '1' and IO_EN = '1' else
            '0' when IOn_OUT = '0' and IO_EN = '1' else 'Z';
    CDn <=  '1' when CDn_OUT = '1' and CD_EN = '1' else
            '0' when CDn_OUT = '0' and CD_EN = '1' else 'Z';
    MSGn <= '1' when MSG_OUTn = '1' and MSG_EN = '1' else
            '0' when MSG_OUTn = '0' and MSG_EN = '1' else 'Z';

    I_5380: WF5380_TOP_SOC
        port map(
            CLK			=> CLK,
            RESETn	    => RESETn,
            ADR			=> ADR_IN,
            DATA_IN		=> DATA_IN,
            DATA_OUT	=> DATA_OUT,
            DATA_EN		=> DATA_EN,
            CSn			=> CSn,
            RDn		    => RDn,
            WRn	        => WRn,
            EOPn        => EOPn,
            DACKn	    => DACKn,
            DRQ		    => DRQ,
            INT		    => INT,
            READY       => READY,
            DB_INn		=> DB_INn,
            DB_OUTn		=> DB_OUTn,
            DB_EN       => DB_EN,
            DBP_INn     => DBP_INn,
            DBP_OUTn    => DBP_OUTn,
            DBP_EN      => DBP_EN,
            RST_INn     => RST_INn,
            RST_OUTn    => RST_OUTn,
            RST_EN      => RST_EN,
            BSY_INn     => BSY_INn,
            BSY_OUTn    => BSY_OUTn,
            BSY_EN      => BSY_EN,
            SEL_INn     => SEL_INn,
            SEL_OUTn    => SEL_OUTn,
            SEL_EN      => SEL_EN,
            ACK_INn     => ACK_INn,
            ACK_OUTn    => ACK_OUTn,
            ACK_EN      => ACK_EN,
            ATN_INn     => ATN_INn,
            ATN_OUTn    => ATN_OUTn,
            ATN_EN      => ATN_EN,
            REQ_INn     => REQ_INn,
            REQ_OUTn    => REQ_OUTn,
            REQ_EN      => REQ_EN,
            IOn_IN      => IOn_IN,
            IOn_OUT     => IOn_OUT,
            IO_EN       => IO_EN,
            CDn_IN      => CDn_IN,
            CDn_OUT     => CDn_OUT,
            CD_EN       => CD_EN,
            MSG_INn     => MSG_INn,
            MSG_OUTn    => MSG_OUTn,
            MSG_EN      => MSG_EN
        );
end STRUCTURE;

architecture LIGHT of WF5380_TOP is
begin
end LIGHT;