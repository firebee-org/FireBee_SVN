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
    CONSTANT BIT_C          : INTEGER := NCOL - 1;
    CONSTANT NWORD          : INTEGER := TBITS / B / NBANK;
    CONSTANT BIT_T          : INTEGER := NCOL + ADDRTOP;
    CONSTANT WORD           : INTEGER := NWORD - 1;

    CONSTANT HB             : INTEGER := B / 2;
    
    CONSTANT PWRUP_TIME     : INTEGER := 0;
    CONSTANT PWUP_CHECK     : STD_LOGIC := '1';
    
    CONSTANT INITIAL        : INTEGER := 0;
    CONSTANT HIGH           : INTEGER := 1;
    CONSTANT LOW            : INTEGER := 0;
    
    SIGNAL addr             : STD_LOGIC_VECTOR (NBANK / 2 + ADDRTOP DOWNTO 0);
    
    TYPE mem_array_t IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL mem_a            : mem_array_t (NWORD - 1 DOWNTO 0);                         -- memory cell array of a bank
    SIGNAL mem_b            : mem_array_t (NWORD - 1 DOWNTO 0);                         -- memory cell array of b bank
    SIGNAL mem_c            : mem_array_t (NWORD - 1 DOWNTO 0);                         -- memory cell array of c bank
    SIGNAL mem_d            : mem_array_t (NWORD - 1 DOWNTO 0);                         -- memory cell array of d bank
    
    SIGNAL t_dqi            : UNSIGNED (B - 1 DOWNTO 0);
    SIGNAL dqsi             : UNSIGNED (NDQS - 1 DOWNTO 0);
    SIGNAL dqsi_n           : UNSIGNED (NDQS - 1 DOWNTO 0);
    
    SIGNAL dqo              : UNSIGNED (B - 1 DOWNTO 0);        -- output temp register declaration
    SIGNAL t_tqo            : UNSIGNED (B - 1 DOWNTO 0);
    
    TYPE r_addr_t IS ARRAY (NATURAL RANGE <>) OF UNSIGNED (NBANK - 1 DOWNTO 0);
    SIGNAL r_addr_n             : r_addr_t (ADDRTOP DOWNTO 0);
    SIGNAL r_addr               : UNSIGNED (ADDRTOP DOWNTO 0);
    SIGNAL c_addr               : UNSIGNED (BIT_C DOWNTO 0);
    SIGNAL c_addr_delay         : UNSIGNED (BIT_C DOWNTO 0);
    SIGNAL c_addr_delay_bf      : UNSIGNED (BIT_C DOWNTO 0);
    SIGNAL m_addr               : UNSIGNED (BIT_T DOWNTO 0);        -- merge row and column address
    SIGNAL m1_addr              : UNSIGNED (BIT_T DOWNTO 0);        -- merge row and column address pseudo
    
    TYPE d_reg_t IS ARRAY (NATURAL RANGE <>) OF UNSIGNED (PAGEDEPTH DOWNTO 0);
    SIGNAL dout_reg             : UNSIGNED (B - 1 DOWNTO 0);
    SIGNAL din_reg              : UNSIGNED (B - 1 DOWNTO 0);
    SIGNAL clk_dq               : UNSIGNED (B - 1 DOWNTO 0);
    SIGNAL ptr                  : STD_LOGIC;
    SIGNAL zdata                : UNSIGNED(B - 1 DOWNTO 0);
    SIGNAL zbyte                : UNSIGNED(7 DOWNTO 0);
    
    -- we know the phase of external signal by examining the state of its flag
    SIGNAL r_bank_addr          : STD_LOGIC;
    SIGNAL c_bank_addr          : UNSIGNED (NBANK / 2 - 1 DOWNTO 0);    -- column bank check flag
    SIGNAL c_bank_addr_delay    : UNSIGNED (NBANK / 2 - 1 DOWNTO 0);    -- column bank check flag 
    SIGNAL c_bank_addr_delay_bf : UNSIGNED (NBANK / 2 - 1 DOWNTO 0);    -- column bank check flag
    SIGNAL prech_reg            : UNSIGNED (NBANK / 2 DOWNTO 0);        -- precharge mode (addr (13 DOWNTO 12) AND (addr(10))
    
    SIGNAL auto_flag            : UNSIGNED (NBANK - 1 DOWNTO 0);
    SIGNAL burst_type           : STD_LOGIC;                            -- burst type flag
    SIGNAL auto_flagx           : STD_LOGIC;                            -- auto refresh flag
    SIGNAL self_flag            : STD_LOGIC;                            -- self refresh flag
    SIGNAL kill_bank            : INTEGER;
    SIGNAL k                    : INTEGER;
    
    SIGNAL precharge_flag       : UNSIGNED (NBANK - 1 DOWNTO 0);        -- precharge bank check flag
    SIGNAL autoprech_reg        : UNSIGNED (1 DOWNTO 0);
    SIGNAL pwrup_done           : STD_LOGIC;
    SIGNAL first_pre            : UNSIGNED (NBANK - 1 DOWNTO 0);
    
    SIGNAL auto_cnt             : INTEGER;
    SIGNAL i                    : INTEGER;
    
    SIGNAL rfu                  : UNSIGNED (6 DOWNTO 0);
BEGIN  
    addr <= STD_LOGIC_VECTOR(ba) & ad;
    rfu <= UNSIGNED(addr(14 DOWNTO 9)) & UNSIGNED(addr(7 DOWNTO 7)); 
END rtl;
