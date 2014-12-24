LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

LIBRARY work;

PACKAGE ddr_ram_model_pkg IS        
    COMPONENT ddr_ram_model IS
        GENERIC
        (
            VERBOSE         : BOOLEAN := TRUE;          -- define if you want additional debug output

            CLOCK_TICK  : TIME := (1000000 / 132000) * 1 ps;     -- time for one clock tick

            NBANK           : INTEGER := 4;
            ADDRTOP         : INTEGER := 12;
            A10_LESS        : BOOLEAN := TRUE;          -- top column address is less than A10
            B               : INTEGER := 16;            -- number of bit (x16)
            NCOL            : INTEGER := 10;            -- top column address is CA9 (NCOL- 1)
            PAGEDEPTH       : INTEGER := 1024;
            NDM             : INTEGER := 2;
            NDQS            : INTEGER := 2
        );
        PORT
        (
            dqi             : INOUT STD_LOGIC_VECTOR (B - 1 DOWNTO 0);
            ba              : IN UNSIGNED (NBANK / 2 - 1 DOWNTO 0);
            ad              : IN STD_LOGIC_VECTOR (ADDRTOP DOWNTO 0);
            rasb            : IN STD_LOGIC;
            casb            : IN STD_LOGIC;
            web             : IN STD_LOGIC;
            clk             : IN STD_LOGIC;
            clkb            : IN STD_LOGIC;
            cke             : IN STD_LOGIC;
            csb             : IN STD_LOGIC;
            dm              : IN UNSIGNED (NDM - 1 DOWNTO 0);
            dqs             : INOUT STD_LOGIC_VECTOR (NDQS - 1 DOWNTO 0);
            qfc             : OUT STD_LOGIC
        );
    END COMPONENT;
    
END PACKAGE;

PACKAGE BODY ddr_ram_model_pkg IS
    
END PACKAGE BODY ddr_ram_model_pkg;
---------------------------------------------------------------------------------------------------------------------------------------    

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

LIBRARY work;
    USE work.ddr_ram_model_pkg.ALL;
    
ENTITY ddr_ram_model IS
    GENERIC
    (
        VERBOSE         : BOOLEAN := TRUE;          -- define if you want additional debug output

        CLOCK_TICK  : TIME := (1000000 / 132000) * 1 ps;     -- time for one clock tick

        NBANK           : INTEGER := 4;
        ADDRTOP         : INTEGER := 12;
        A10_LESS        : BOOLEAN := TRUE;          -- top column address is less than A10
        B               : INTEGER := 16;            -- number of bit (x16)
        NCOL            : INTEGER := 10;            -- top column address is CA9 (NCOL - 1)
        PAGEDEPTH       : INTEGER := 1024;
        NDM             : INTEGER := 2;
        NDQS            : INTEGER := 2
    );
    PORT
    (
           dqi             : INOUT STD_LOGIC_VECTOR (B - 1 DOWNTO 0);
           ba              : IN UNSIGNED (NBANK / 2 - 1 DOWNTO 0);
           ad              : IN STD_LOGIC_VECTOR (ADDRTOP DOWNTO 0);
           rasb            : IN STD_LOGIC;
           casb            : IN STD_LOGIC;
           web             : IN STD_LOGIC;
           clk             : IN STD_LOGIC;
           clkb            : IN STD_LOGIC;
           cke             : IN STD_LOGIC;
           csb             : IN STD_LOGIC;
           dm              : IN UNSIGNED (NDM - 1 DOWNTO 0);
           dqs             : INOUT STD_LOGIC_VECTOR (NDQS - 1 DOWNTO 0);
           qfc             : OUT STD_LOGIC
     );
END ENTITY ddr_ram_model;

ARCHITECTURE rtl OF ddr_ram_model IS
    -- DDR RAM timing constants
    
    CONSTANT TRC            : TIME := 65 ps;            -- row cycle time (min)
    CONSTANT TRFC           : TIME := 115 ps;           -- Refresh Row cycle time (min)
    CONSTANT TRASMIN        : TIME := 45 ps;            -- Row active minimum time
    CONSTANT TRASMAX        : TIME := 120000 ps;        -- Row active maximum time
    CONSTANT TRCD           : TIME := 20 ps;            -- Ras to cas delay (min)
    CONSTANT TRP            : TIME := 20 ps;            -- Row precharge time (min)
    CONSTANT TRRD           : TIME := 15 ps;            -- Row to row delay (min)
    
    CONSTANT TCCD           : TIME := CLOCK_TICK;       -- Col. address to col. address delay: 1 clk
    
    CONSTANT TCKMIN         : TIME := 7.5 ps;           -- Clock minimum cycle time
    CONSTANT TCKMAX         : TIME := 12 ps;            -- Clock maximum cycle time
    CONSTANT TCK15          : TIME := 10 ps;            -- Clock minimum cycle time at cas latency=1.5
    CONSTANT TCK2           : TIME := 10 ps;            -- Clock minimum cycle time at cas latency=2
    CONSTANT TCK25          : TIME := 7.5 ps;           -- Clock minimum cycle time at cas latency=2.5
    CONSTANT TCK3           : TIME := 7.5 ps;           -- Clock minimum cycle time at cas latency=3
    CONSTANT TCHMIN         : TIME := 0.45 ps;          -- Clock high pulse width (min. 0.45 tCK, max: 0.55 tCK)
    CONSTANT TCHMAX         : TIME := 0.55 ps;
    CONSTANT TCLMIN         : TIME := 0.45 ps;          -- Clock low pulse width (min. 0.45 tCK, max: 0.55 tCK)
    CONSTANT TCLMAX         : TIME := 0.55 ps;
    CONSTANT TIS            : TIME := 0.9 ps;           -- input setup time (old Tss)
    CONSTANT TIH            : TIME := 0.9 ps;           -- input hold time (old Tsh)
    CONSTANT TWR            : TIME := 15 ps;            -- write recovery time
    CONSTANT TDS            : TIME := 0.5 ps;           -- Data in & DQM setup time
    CONSTANT TDH            : TIME := 0.5 ps;           -- Data in & DQM hold time
    CONSTANT TDQSH          : TIME := 0.6 ps;           -- DQS-in high level width (min. 0.4 tCK, max. 0.6 tCK)
    CONSTANT TDQSL          : TIME := 0.6 ps;           --
    CONSTANT TDSC           : TIME := 1 ps;             -- DQS-in cycle time tCIC changed following tDSC
    CONSTANT TPDEX          : TIME := 7.5 ps;           -- Power down exit time
    CONSTANT TSREX          : TIME := 200 ps;           -- Self refresh exit time : 200 clk
    CONSTANT THZQ           : TIME := 0.75 ps;          -- Data out active to High-Z (min:-0.75, max: +0.75)
    CONSTANT TDQSCK         : TIME := 0.75 ps;          -- DQS out edge to clock edge
    CONSTANT TAC            : TIME := 0.75 ps;          -- Output data access time from CK/CKB (min: -0.75, max: +0.75)
    CONSTANT TQCSW          : TIME := 3.5 ps;           -- Delay from the clock edge of write command to QFC out on writes (max: 4ns)
    CONSTANT TQCHW          : TIME := 0.5 ps;           -- QFC hold time on writes (min 1.25 ns, max: 0.5 tCK)
    CONSTANT TQCH           : TIME := 0.4 ps;           -- QFC hold time on reads (min 0.4 tCK, max 0.6 tCK)
    CONSTANT TQCS           : TIME := 0.9 ps;           -- QFC setup time on reads (min: 0.9 tCK, max 1.1 tCK)

    CONSTANT K1             : INTEGER := 1024;
    CONSTANT M1             : INTEGER := 1048576;
    CONSTANT BYTE           : INTEGER := 8;

    CONSTANT TBITS          : INTEGER := 512 * M1;

    --SIGNAL BITs           : UNSIGNED (B - 1 DOWNTO 0);
    SIGNAL BIT_C            : UNSIGNED (NCOL - 1 DOWNTO 0);
    CONSTANT NWORD          : INTEGER := TBITS / B / NBANK;
    SIGNAL BIT_T            : UNSIGNED (NCOL + ADDRTOP DOWNTO 0);
    SIGNAL WORD             : UNSIGNED (NWORD - 1 DOWNTO 0);

    CONSTANT HB             : INTEGER := B / 2;
BEGIN  
END rtl;
