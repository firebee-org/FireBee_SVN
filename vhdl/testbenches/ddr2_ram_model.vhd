LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

LIBRARY work;

PACKAGE ddr2_ram_model_pkg IS
    -- DDR2 RAM timing constants
    
    CONSTANT TRFC_MIN       : TIME := 105000 ps;        -- refresh to refresh command minimum value
    CONSTANT TRFC_MAX       : TIME := 70000000 ps;      -- refresh to refresh command maximum value
    CONSTANT TRP            : TIME := 13125 ps;         -- precharge period
    CONSTANT TRPA           : TIME := 13125 ps;         -- precharge all period
    CONSTANT TRC            : TIME := 54000 ps;         -- activate to activate/auto refresh command time
    CONSTANT TRAS_MIN       : TIME := 40000 ps;         -- minimum active to precharge command time
    CONSTANT TRAS_MAX       : TIME := 70000000 ps;      -- maximum active to precharge command time
    CONSTANT TRRD           : TIME := 10000 ps;         -- tRRD: active bank to active bank command time
    CONSTANT TFAW           : TIME := 45000 ps;         -- four bank activate window
    CONSTANT TWR            : TIME := 15000 ps;         -- write recovery time
    
    CONSTANT RANDOM_SEED    : INTEGER := 711689044;     -- seed value for random generator
   
    COMPONENT ddr2_ram_model IS
        GENERIC
        (
            VERBOSE         : BOOLEAN := TRUE;          -- define if you want additional debug output

            CLOCK_TICK  : TIME := (1000000 / 132000) * 1 ps;     -- time for one clock tick

            BA_BITS         : INTEGER := 2;             -- number of banks
            ADDR_BITS       : INTEGER := 13;            -- number of address bits
            DM_BITS         : INTEGER := 2;             -- number of data mask bits
            DQ_BITS         : INTEGER := 16;            -- number of data bits
            DQS_BITS        : INTEGER := 2              -- number of data strobes
        );
        PORT
        (
            ck              : IN STD_LOGIC;
            ck_n            : IN STD_LOGIC;
            cke             : IN STD_LOGIC;
            cs_n            : IN STD_LOGIC;
            ras_n           : IN STD_LOGIC;
            cas_n           : IN STD_LOGIC;
            we_n            : IN STD_LOGIC;
            dm_rdqs         : INOUT UNSIGNED (DM_BITS - 1 DOWNTO 0);
            ba              : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
            addr            : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0);
            dq              : INOUT UNSIGNED (DQ_BITS - 1 DOWNTO 0);
            dqs             : INOUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
            dqs_n           : INOUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
            rdqs_n          : OUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
            odt             : IN STD_LOGIC
        );
    END COMPONENT;
END PACKAGE;

PACKAGE BODY ddr2_ram_model_pkg IS
    
END PACKAGE BODY ddr2_ram_model_pkg;
---------------------------------------------------------------------------------------------------------------------------------------    

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

LIBRARY work;
    USE work.ddr2_ram_model_pkg.ALL;
    
ENTITY ddr2_ram_model IS
    GENERIC
    (
        VERBOSE     : BOOLEAN := TRUE;          -- define if you want additional debug output
        CLOCK_TICK  : TIME := (1000000 / 132000) * 1 ps;     -- time for one clock tick
        
        BA_BITS     : INTEGER := 2;             -- number of banks
        ADDR_BITS   : INTEGER := 13;            -- number of address bits
        DM_BITS     : INTEGER := 2;             -- number of data mask bits
        DQ_BITS     : INTEGER := 8;             -- number of data bits
        DQS_BITS    : INTEGER := 2              -- number of data strobes
    );
    PORT
    (
        ck          : IN STD_LOGIC;
        ck_n        : IN STD_LOGIC;
        cke         : IN STD_LOGIC;
        cs_n        : IN STD_LOGIC;
        ras_n       : IN STD_LOGIC;
        cas_n       : IN STD_LOGIC;
        we_n        : IN STD_LOGIC;
        dm_rdqs     : INOUT UNSIGNED (DM_BITS - 1 DOWNTO 0);
        ba          : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
        addr        : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0);
        dq          : INOUT UNSIGNED (DQ_BITS - 1 DOWNTO 0);
        dqs         : INOUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
        dqs_n       : INOUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
        rdqs_n      : OUT UNSIGNED (DQS_BITS - 1 DOWNTO 0);
        odt         : IN STD_LOGIC
    );
END ENTITY ddr2_ram_model;

ARCHITECTURE rtl OF ddr2_ram_model IS
    -- DDR2 RAM size constants
    CONSTANT MEM_BITS       : INTEGER := 10;            -- number of write data bursts can be stored in memory. The default is 2 ** 10 = 1024
    CONSTANT AP             : INTEGER := 10;            -- the address bit that controls auto-precharge and precharge-all
    CONSTANT TDLLK          : INTEGER := 200;
    CONSTANT BANKS          : INTEGER := TO_INTEGER(SHIFT_LEFT(TO_UNSIGNED(1, 32), BA_BITS));
    CONSTANT ROW_BITS       : INTEGER := 13;
    CONSTANT COL_BITS       : INTEGER := 10;
    CONSTANT BL_BITS        : INTEGER := 3;             -- the number of bits required to count to MAX_BL
    CONSTANT BL_MAX         : INTEGER := 8;
    CONSTANT BO_BITS        : INTEGER := 2;             -- the number of burst order bits
    CONSTANT MAX_BITS       : INTEGER := BA_BITS + ROW_BITS + COL_BITS - BL_BITS;
    

    -- time constants
    CONSTANT BUS_DELAY      : TIME := 0 ps;

    -- time constants (in tCK's)
    CONSTANT TMRD           : INTEGER := 2;             -- load mode register command cycle time
    CONSTANT TCCD           : INTEGER := 2;             -- CAS to CAS command delay

    CONSTANT DQ_PER_DQS     : INTEGER := DQ_BITS / DQS_BITS;
    CONSTANT MAX_SIZE       : INTEGER := TO_INTEGER(SHIFT_LEFT(TO_UNSIGNED(1, 32), BA_BITS + ROW_BITS + COL_BITS - BL_BITS));
    CONSTANT MEM_SIZE       : INTEGER := TO_INTEGER(SHIFT_LEFT(TO_UNSIGNED(1, 32), MEM_BITS));
    CONSTANT AL_MAX         : INTEGER := 6;
    CONSTANT CL_MAX         : INTEGER := 7;
    CONSTANT MAX_PIPE       : INTEGER := 2 * (AL_MAX + CL_MAX);
    
    TYPE time_array_t IS ARRAY (NATURAL RANGE <>) OF TIME;
    
    -- clock jitter
    SIGNAL tck_avg          : REAL;
    SIGNAL tck_sample       : time_array_t (TDLLK - 1 DOWNTO 0);
    SIGNAL tch_sample       : time_array_t (TDLLK - 1 DOWNTO 0);
    SIGNAL tcl_sample       : time_array_t (TDLLK - 1 DOWNTO 0);
    SIGNAL tck_i            : TIME;
    SIGNAL tch_i            : TIME;
    SIGNAL tcl_i            : TIME;
    SIGNAL tch_avg          : REAL;
    SIGNAL tcl_avg          : REAL;
    SIGNAL tm_ck_pos        : TIME;
    SIGNAL tm_ck_neg        : TIME;
    SIGNAL tjit_per_rtime   : REAL;
    SIGNAL tjit_cc_time     : INTEGER;
    SIGNAL terr_nper_rtime  : REAL;
    
    -- clock skew
    SIGNAL out_delay        : REAL;
    SIGNAL dqsck            : UNSIGNED (DQS_BITS - 1 DOWNTO 0);
    SIGNAL dqsck_min        : INTEGER;
    SIGNAL dqsck_max        : INTEGER;
    SIGNAL dqsq_min         : INTEGER;
    SIGNAL dqsq_max         : INTEGER;
    SIGNAL seed             : INTEGER;
    
    -- mode registers
    SIGNAL burst_order      : STD_LOGIC;
    SIGNAL burst_length     : UNSIGNED (BL_BITS DOWNTO 0);
    SIGNAL cas_latency      : INTEGER;
    SIGNAL additive_latency : INTEGER;
    SIGNAL dll_reset        : STD_LOGIC;
    SIGNAL dll_locked       : STD_LOGIC;
    SIGNAL dll_en           : STD_LOGIC;
    SIGNAL write_recovery   : INTEGER;
    SIGNAL low_power        : STD_LOGIC;
    SIGNAL odt_rtt          : UNSIGNED (1 DOWNTO 0);
    SIGNAL odt_en           : STD_LOGIC;
    SIGNAL ocd              : UNSIGNED (2 DOWNTO 0);
    SIGNAL dqs_n_en         : STD_LOGIC;
    SIGNAL rdqs_en          : STD_LOGIC;
    SIGNAL out_en           : STD_LOGIC;
    SIGNAL READ_CMD_latency     : INTEGER;
    SIGNAL write_latency    : INTEGER;
    
    TYPE cmd_type_t IS (LOAD_MODE, REFRESH, PRECHARGE, ACTIVATE, WRITE_CMD, READ_CMD, NOP, PWR_DOWN, SELF_REF);
    TYPE cmd_type_encoding_array_t IS ARRAY(cmd_type_t) OF UNSIGNED(3 DOWNTO 0);
    CONSTANT cmd_type_encoding : cmd_type_encoding_array_t :=
        (
            "0000", "0001", "0010", "0011",
            "0100", "0101", "0111", "1000",
            "1001"
        );
        
    TYPE cmd_string_array_t IS ARRAY (INTEGER RANGE <>) OF STRING(1 TO 9);
    CONSTANT cmd_string     : cmd_string_array_t(1 TO 9) :=
        ( "Load Mode",
          "Refresh  ",
          "Precharge",
          "Activate ",
          "Write    ",
          "Read     ",
          "No OP    ",
          "Pwr Down ",
          "Self Ref "
        );
    
    -- command state
    SIGNAL active_bank          : UNSIGNED (BANKS - 1 DOWNTO 0);
    SIGNAL auto_precharge_bank  : UNSIGNED (BANKS - 1 DOWNTO 0);
    SIGNAL write_precharge_bank : UNSIGNED (BANKS - 1 DOWNTO 0);
    SIGNAL read_precharge_bank  : UNSIGNED (BANKS - 1 DOWNTO 0);
    
    TYPE row_array_t IS ARRAY (INTEGER RANGE <>) OF UNSIGNED (BANKS - 1 DOWNTO 0);
    SIGNAL active_row           : row_array_t (ROW_BITS - 1 DOWNTO 0);
    SIGNAL in_power_down        : STD_LOGIC;
    SIGNAL in_self_refresh      : STD_LOGIC;
    SIGNAL init_mode_reg        : UNSIGNED (3 DOWNTO 0);
    SIGNAL init_done            : STD_LOGIC;
    SIGNAL init_step            : INTEGER;
    SIGNAL er_trfc_max          : STD_LOGIC;
    SIGNAL odt_state            : STD_LOGIC;
    SIGNAL pref_odt             : STD_LOGIC;
    
    -- cmd timers/counters
    SIGNAL ref_cntr             : INTEGER;
    SIGNAL ck_cntr              : INTEGER;
    SIGNAL ck_load_mode         : INTEGER;
    SIGNAL ck_write             : INTEGER;
    SIGNAL ck_read              : INTEGER;
    SIGNAL ck_write_ap          : INTEGER;
    SIGNAL ck_power_down        : INTEGER;
    SIGNAL ck_slow_exit_pd      : INTEGER;
    SIGNAL ck_self_refresh      : INTEGER;
    SIGNAL ck_cke               : INTEGER;
    SIGNAL ck_odt               : INTEGER;
    SIGNAL ck_dll_reset         : INTEGER;
    
    TYPE ck_bank_array_t IS ARRAY (NATURAL RANGE <>) OF INTEGER;
    SIGNAL ck_bank_write        : ck_bank_array_t (BANKS - 1 DOWNTO 0);
    SIGNAL ck_bank_read         : ck_bank_array_t (BANKS - 1 DOWNTO 0);
    
    SIGNAL tm_refresh           : TIME;
    SIGNAL tm_precharge         : TIME;
    SIGNAL tm_precharge_all     : TIME;
    SIGNAL tm_activate          : TIME;
    SIGNAL tm_write_end         : TIME;
    SIGNAL tm_self_refresh      : TIME;
    SIGNAL tm_odt_en            : TIME;
    SIGNAL tm_bank_precharge    : time_array_t (BANKS - 1 DOWNTO 0);
    SIGNAL tm_bank_activate     : time_array_t (BANKS - 1 DOWNTO 0);
    SIGNAL tm_bank_write_end    : time_array_t (BANKS - 1 DOWNTO 0);
    SIGNAL tm_bank_read_end     : time_array_t (BANKS - 1 DOWNTO 0);
    
    -- pipelines
    SIGNAL al_pipeline          : UNSIGNED (MAX_PIPE DOWNTO 0);
    SIGNAL wr_pipeline          : UNSIGNED (MAX_PIPE DOWNTO 0);
    SIGNAL rd_pipeline          : UNSIGNED (MAX_PIPE DOWNTO 0);
    SIGNAL odt_pipeline         : UNSIGNED (MAX_PIPE DOWNTO 0);
    
    TYPE ba_pipeline_t IS ARRAY (NATURAL RANGE <>) OF UNSIGNED (BA_BITS - 1 DOWNTO 0);
    SIGNAL ba_pipeline          : ba_pipeline_t (MAX_PIPE DOWNTO 0);
    
    TYPE row_pipeline_t IS ARRAY (NATURAL RANGE <>) OF UNSIGNED (ROW_BITS - 1 DOWNTO 0);
    SIGNAL row_pipeline         : row_pipeline_t (MAX_PIPE DOWNTO 0);
    
    TYPE col_pipeline_t IS ARRAY (NATURAL RANGE <>) OF UNSIGNED (COL_BITS - 1 DOWNTO 0);
    SIGNAL col_pipeline         : col_pipeline_t (MAX_PIPE DOWNTO 0);
    
    SIGNAL prev_cke             : STD_LOGIC;
    
    -- data state
    SIGNAL memory_data          : UNSIGNED (BL_MAX * DQ_BITS - 1 DOWNTO 0);
    SIGNAL bit_mask             : UNSIGNED (BL_MAX * DQ_BITS - 1 DOWNTO 0);
    SIGNAL burst_position       : UNSIGNED (BL_BITS - 1 DOWNTO 0);
    SIGNAL burst_cntr           : UNSIGNED (BL_BITS DOWNTO 0);
    SIGNAL dq_temp              : UNSIGNED (DQ_BITS - 1 DOWNTO 0);
    SIGNAL check_write_postamble: UNSIGNED (35 DOWNTO 0);
    SIGNAL check_write_preamble : UNSIGNED (35 DOWNTO 0);
    SIGNAL check_write_dqs_high : UNSIGNED (35 DOWNTO 0);
    SIGNAL check_write_dqs_low  : UNSIGNED (35 DOWNTO 0);
    SIGNAL check_dm_tdipw       : UNSIGNED (17 DOWNTO 0);
    SIGNAL check_dq_tdipw       : UNSIGNED (17 DOWNTO 0);
    
    -- data timers/counters
    SIGNAL tm_cke               : TIME;
    SIGNAL tm_odt               : TIME;
    SIGNAL tm_tdqss             : TIME;
    SIGNAL tm_dm                : time_array_t (17 DOWNTO 0);
    SIGNAL tm_dqs               : time_array_t (17 DOWNTO 0);
    SIGNAL tm_dqs_pos           : time_array_t (35 DOWNTO 0);
    SIGNAL tm_dqss_pos          : time_array_t (35 DOWNTO 0);
    SIGNAL tm_dqss_neg          : time_array_t (35 DOWNTO 0);
    SIGNAL tm_dq                : time_array_t (71 DOWNTO 0);
    SIGNAL tm_cmd_addr          : time_array_t (22 DOWNTO 0);
    
    TYPE cmd_addr_array_t IS ARRAY (INTEGER RANGE <>) OF STRING(1 TO 8);
    CONSTANT cmd_addr_string     : cmd_addr_array_t(22 DOWNTO 0) :=
        (
            "CS_N    ",
            "RAS_N   ",
            "CAS_N   ",
            "WE_N    ",
            "BA 0    ",
            "BA 1    ",
            "BA 2    ",
            "ADDR   0",
            "ADDR   1",
            "ADDR   2",
            "ADDR   3",
            "ADDR   4",
            "ADDR   5",
            "ADDR   6",
            "ADDR   7",
            "ADDR   8",
            "ADDR   9",
            "ADDR  10",
            "ADDR  11",
            "ADDR  12",
            "ADDR  13",
            "ADDR  14",
            "ADDR  15"
        );
    
    TYPE dqs_string_t IS ARRAY (INTEGER RANGE <>) OF STRING (1 TO 5);
    CONSTANT dqs_string         : dqs_string_t (1 DOWNTO 0) :=
        (
            "DQS  ",
            "DQS_N"
        );

    -- memory storage
    TYPE mem_t IS ARRAY (INTEGER RANGE <>) OF UNSIGNED (BL_MAX * DQ_BITS - 1 DOWNTO 0);
    SIGNAL memory               : mem_t(0 TO MEM_SIZE - 1);
    TYPE adr_t IS ARRAY (INTEGER RANGE <>) OF UNSIGNED (MAX_BITS - 1 DOWNTO 0);
    SIGNAL address              : adr_t(0 TO MEM_SIZE - 1);
    SIGNAL memory_index         : UNSIGNED(MEM_BITS DOWNTO 0);
    SIGNAL memory_used          : UNSIGNED(MEM_BITS DOWNTO 0);
    
    SIGNAL ck_in                : STD_LOGIC;
    SIGNAL ck_n_in              : STD_LOGIC;
    SIGNAL cke_in               : STD_LOGIC;
    SIGNAL cs_n_in              : STD_LOGIC;
    SIGNAL ras_n_in             : STD_LOGIC;
    SIGNAL cas_n_in             : STD_LOGIC;
    SIGNAL we_n_in              : STD_LOGIC;
    SIGNAL dm_in                : UNSIGNED (17 DOWNTO 0);
    SIGNAL ba_in                : UNSIGNED (2 DOWNTO 0);
    SIGNAL addr_in              : UNSIGNED (15 DOWNTO 0);
    SIGNAL dq_in                : UNSIGNED (71 DOWNTO 0);
    SIGNAL dqs_in               : UNSIGNED (35 DOWNTO 0);
    SIGNAL odt_in               : STD_LOGIC;
    
    SIGNAL dm_in_pos            : UNSIGNED (17 DOWNTO 0);
    SIGNAL dm_in_neg            : UNSIGNED (17 DOWNTO 0);
    SIGNAL dq_in_pos            : UNSIGNED (71 DOWNTO 0);
    SIGNAL dq_in_neg            : UNSIGNED (71 DOWNTO 0);
    SIGNAL dq_in_valid          : STD_LOGIC;
    SIGNAL dqs_in_valid         : STD_LOGIC;
    SIGNAL wdqs_cntr            : INTEGER;
    SIGNAL wdq_cntr             : INTEGER;
    
    TYPE integer_array_t IS ARRAY (NATURAL RANGE <>) OF INTEGER;
    SIGNAL wdqs_pos_cntr        : integer_array_t(35 DOWNTO 0);
    
    SIGNAL b2b_write            : STD_LOGIC;
    SIGNAL prev_dqs_in          : UNSIGNED (35 DOWNTO 0);
    SIGNAL diff_ck              : STD_LOGIC;
    
    SIGNAL dqs_even             : UNSIGNED (17 DOWNTO 0);
    SIGNAL dqs_odd              : UNSIGNED (17 DOWNTO 0);
    SIGNAL cmd_n_in             : UNSIGNED (3 DOWNTO 0);
    
    -- transmit
    SIGNAL dqs_out_en           : STD_LOGIC;
    SIGNAL dqs_out_en_dly       : UNSIGNED (DQS_BITS - 1 DOWNTO 0);
    SIGNAL dqs_out              : STD_LOGIC;
    SIGNAL dqs_out_dly          : UNSIGNED (DQS_BITS - 1 DOWNTO 0);
    SIGNAL dq_out_en            : STD_LOGIC;
    SIGNAL dq_out_en_dly        : UNSIGNED (DQ_BITS - 1 DOWNTO 0);
    SIGNAL dq_out               : UNSIGNED (DQ_BITS - 1 DOWNTO 0);
    SIGNAL dq_out_dly           : UNSIGNED (DQ_BITS - 1 DOWNTO 0);
    SIGNAL rdqsen_cntr          : INTEGER;
    SIGNAL rdqs_cntr            : INTEGER;
    SIGNAL rdqen_cntr           : INTEGER;
    SIGNAL rdq_cntr             : INTEGER;
    
    SIGNAL r                    : STD_LOGIC := '0';
  
  PROCEDURE memory_write(
        SIGNAL bank    : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
        SIGNAL row     : IN UNSIGNED (ROW_BITS - 1 DOWNTO 0);
        SIGNAL col     : IN UNSIGNED (COL_BITS - 1 DOWNTO 0);
        SIGNAL data    : IN UNSIGNED (BL_MAX * DQ_BITS - 1 DOWNTO 0);
        SIGNAL addr    : INOUT UNSIGNED (MAX_BITS - 1 DOWNTO 0)) IS
    BEGIN
        addr <= (bank & row & col) / BL_MAX;
        -- TODO: only the MAX_MEM defined functionality available here
        -- memory(addr) <= data;
    END memory_write;
    
    PROCEDURE memory_READ_CMD(
        SIGNAL bank     : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
        SIGNAL row      : IN UNSIGNED (ROW_BITS - 1 DOWNTO 0);
        SIGNAL col      : IN UNSIGNED (COL_BITS - 1 DOWNTO 0);
        SIGNAL data     : OUT UNSIGNED (BL_MAX * DQ_BITS - 1 DOWNTO 0);
        SIGNAL addr     : INOUT UNSIGNED (MAX_BITS - 1 DOWNTO 0)) IS
    BEGIN
        -- chop off the lowest address bits
        addr <= (bank & row & col) / BL_MAX;
        -- TODO: only the MAX_MEM defined functionality defined yet
        -- data <= memory(addr);
    END memory_READ_CMD;
    
    PROCEDURE cmd_task(
        cke        : IN STD_LOGIC;
        cmd        : IN UNSIGNED (3 DOWNTO 0);
        bank       : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
        addr       : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0)) IS
        
        VARIABLE i          : UNSIGNED (BANKS DOWNTO 0);
        VARIABLE j          : INTEGER;
        VARIABLE tfaw_cntr  : UNSIGNED (BANKS DOWNTO 0);
        VARIABLE col        : UNSIGNED (COL_BITS - 1 DOWNTO 0);
    BEGIN
    END cmd_task;
    
    
    PROCEDURE initialize(
        SIGNAL mode_reg0    : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0);
        SIGNAL mode_reg1    : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0);
        SIGNAL mode_reg2    : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0);
        SIGNAL mode_reg3    : IN UNSIGNED (ADDR_BITS - 1 DOWNTO 0)) IS
        
        CONSTANT AP_BIT     : UNSIGNED (ADDR_BITS - 1 DOWNTO 0) := UNSIGNED(TO_UNSIGNED(2 ** AP, ADDR_BITS));
    BEGIN
        REPORT("at time " & TIME'IMAGE(NOW) & "INFO: performing initialization sequence");
        
        cmd_task('1', cmd_type_encoding(NOP),  (OTHERS => 'X'), (OTHERS => 'X'));
        cmd_task('1', cmd_type_encoding(PRECHARGE), (OTHERS => 'X'), AP_BIT);
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(3, BA_BITS)), mode_reg3);
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(2, BA_BITS)), mode_reg2);
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(1, BA_BITS)), mode_reg1);
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(0, BA_BITS)), mode_reg0 OR "100");  -- DLL reset
        cmd_task('1', cmd_type_encoding(PRECHARGE), (OTHERS => 'X'), AP_BIT);           -- Precharge all
        cmd_task('1', cmd_type_encoding(REFRESH), (OTHERS => 'X'), (OTHERS => 'X'));
        cmd_task('1', cmd_type_encoding(REFRESH), (OTHERS => 'X'), (OTHERS => 'X'));
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(0, BA_BITS)), mode_reg0);
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(1, BA_BITS)), mode_reg1 OR x"380"); -- OCD default
        cmd_task('1', cmd_type_encoding(LOAD_MODE), UNSIGNED(TO_UNSIGNED(1, BA_BITS)), mode_reg1);
        cmd_task('1', cmd_type_encoding(NOP), (OTHERS => 'X'), (OTHERS => 'X'));
    END initialize;
        
    FUNCTION abs_value(SIGNAL arg : IN REAL) RETURN REAL IS
    BEGIN
        IF arg < 0.0 THEN
            RETURN -1.0 * arg;
        END IF;
        
        RETURN arg;
    END abs_value;
    
BEGIN
    PROCESS (ck)
    BEGIN
        ck_in <= ck AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (ck_n)
    BEGIN
        ck_n_in <= ck_n AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (cke)
    BEGIN
        cke_in <= cke AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (cs_n)
    BEGIN
        cs_n_in <= cs_n AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (ras_n)
    BEGIN
        ras_n_in <= ras_n AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (cas_n)
    BEGIN
        cas_n_in <= cas_n AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (we_n)
    BEGIN
        we_n_in <= we_n AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (dm_rdqs)
    BEGIN
        dm_in <= UNSIGNED(RESIZE(UNSIGNED(dm_rdqs), dm_in'LENGTH)) AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (ba)
    BEGIN
        ba_in <= UNSIGNED(RESIZE(UNSIGNED(ba), ba_in'LENGTH)) AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (addr)
    BEGIN
        addr_in <= UNSIGNED(RESIZE(UNSIGNED(addr), addr_in'LENGTH)) AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (dq)
    BEGIN
        dq_in <= UNSIGNED(RESIZE(UNSIGNED(dq), dq_in'LENGTH)) AFTER BUS_DELAY;
    END PROCESS;
    
    PROCESS (dqs, dqs_n)
    BEGIN
        dqs_in <= UNSIGNED(SHIFT_LEFT(RESIZE(UNSIGNED(dqs_n), dqs_in'LENGTH), 18)) OR UNSIGNED(RESIZE(UNSIGNED(dqs), dqs_in'LENGTH));
    END PROCESS;
    
    PROCESS (odt)
    BEGIN
        odt_in <= odt AFTER BUS_DELAY;
    END PROCESS;
    
    -- create internal clock
    PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ck_in);
        diff_ck <= ck_in;
    END PROCESS;
    
    PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ck_n_in);
        diff_ck <= NOT ck_n_in;
    END PROCESS;
    
    dqs_even <= dqs_in (17 DOWNTO 0);
    dqs_odd <= dqs_in (35 DOWNTO 18) WHEN dqs_n_en = '1' ELSE NOT(dqs_in (17 DOWNTO 0));
    cmd_n_in <= '0' & ras_n_in & cas_n_in & we_n_in WHEN NOT(cs_n_in) ELSE cmd_type_encoding(NOP);
    
    -- bufif1 buf_dqs
    dqs <= dqs_out_dly WHEN (dqs_out_en_dly AND UNSIGNED'(0 TO DQS_BITS - 1 => out_en)) /= x"0" ELSE (OTHERS => 'Z');
    
    -- bufif1 buf_dm
    dm_rdqs <= dqs_out_dly WHEN (dqs_out_en_dly AND
                                UNSIGNED'(0 TO DM_BITS - 1 => out_en) AND
                                UNSIGNED'(0 TO DM_BITS - 1 => rdqs_en)) /= x"0" ELSE (OTHERS => 'Z');
    -- bufif1 buf_dqs_n
    dqs_n <= NOT dqs_out_dly WHEN (dqs_out_en_dly AND
                                    UNSIGNED'(0 TO DQS_BITS - 1 => out_en) AND
                                    UNSIGNED'(0 TO DQS_BITS - 1 => dqs_n_en)) /= x"0" ELSE (OTHERS => 'Z');
    -- bufif1 buf_rdqs_n
    rdqs_n <= NOT dqs_out_dly WHEN (dqs_out_en_dly AND
                                    UNSIGNED'(0  TO DQS_BITS - 1 => out_en) AND
                                    UNSIGNED'(0 to DQS_BITS - 1 => dqs_n_en) AND
                                    UNSIGNED'(0 TO DQS_BITS - 1 => rdqs_en)) /= x"0" ELSE (OTHERS => 'Z');
    
    -- bufif1 buf_dq
    dq <= dq_out_dly WHEN (dq_out_en_dly AND
                            UNSIGNED'(0 TO DQ_BITS - 1 => out_en)) /= x"0" ELSE (OTHERS => 'Z');

    -- initial block
    init : PROCESS
    BEGIN
        IF BL_MAX < 2 THEN
            REPORT("ERROR: BL_MAX parameter must be >= 2. BL_MAX=" & INTEGER'IMAGE(BL_MAX));
        END IF;
        
        IF 2 ** BO_BITS > BL_MAX THEN
            REPORT("ERROR: 2**BO_BITS cannot be greater than BL_MAX parameter");
        END IF;
        seed <= RANDOM_SEED;
        ck_cntr <= 0;
        
        WAIT;
    END PROCESS;
    
    -- ugly kludge: encapsulate reset_task PROCEDURE into a process to make ModelSim happy
    reset : PROCESS
        PROCEDURE reset_task IS
            -- VARIABLE i              : INTEGER;
        BEGIN
            -- disable inputs
            dq_in_valid         <= '0';
            dqs_in_valid        <= '0';
            wdqs_cntr           <= 0;
            wdq_cntr            <= 0;
            
            FOR i IN 0 TO 35 LOOP
                wdqs_pos_cntr(i) <= 0;
            END LOOP;
            
            b2b_write <= '0';
            
            -- disable outputs
            out_en <= '0';
            dqs_n_en <= '0';
            rdqs_en <= '0';
            dq_out_en <= '0';
            rdq_cntr <= 0;
            dqs_out_en <= '0';
            rdqs_cntr <= 0;
            
            -- disable ODT
            odt_en <= '0';
            odt_state <= '0';
            
            -- reset bank state
            active_bank <= (OTHERS => '1');
            auto_precharge_bank <= (OTHERS =>'0');
            read_precharge_bank <= (OTHERS => '0');
            write_precharge_bank <= (OTHERS =>'0');
            
            -- require initialization sequence
            init_done <= '0';
            init_step <= 0;
            init_mode_reg <= (OTHERS => '0');
            
            -- reset DLL
            dll_en <= '0';
            dll_reset <= '0';
            dll_locked <= '0';
            ocd <= (OTHERS => '0');
            
            -- exit power down and self refresh
            in_power_down <= '0';
            in_self_refresh <= '0';
            
            -- clear pipelines
            al_pipeline <= (OTHERS => '0');
            wr_pipeline <= (OTHERS => '0');
            rd_pipeline <= (OTHERS => '0');
            odt_pipeline <= (OTHERS => '0');
            
            -- clear memory
            FOR i IN 0 TO MAX_SIZE LOOP
                memory(i) <= (OTHERS => 'X');
            END LOOP;
            
            -- clear maximum timing checks
            tm_refresh <= 0 ns;
            FOR i IN 0 TO BANKS - 1 LOOP
                tm_bank_activate(i) <= 0 ns;
            END LOOP;
        END reset_task;    
    BEGIN
        WAIT UNTIL rising_edge(ck);
        IF r /= '0' THEN
            reset_task;
            r <= '0';
        END IF;
    END PROCESS; -- reset
    
    err : PROCESS
        PROCEDURE chk_err(
            samebank    : IN UNSIGNED (0 DOWNTO 0);
            bank        : IN UNSIGNED (BA_BITS - 1 DOWNTO 0);
            fromcmd     : IN UNSIGNED (3 DOWNTO 0);
            cmd         : IN UNSIGNED (3 DOWNTO 0)
            ) IS
            
            VARIABLE err         : STD_LOGIC;
        BEGIN
            -- all matching case expression will be evaluated
            
            CASE? (UNSIGNED'(samebank & fromcmd & cmd)) IS
                WHEN "0" & cmd_type_encoding(LOAD_MODE) & "0---" =>
                    IF ck_cntr - ck_load_mode < TMRD THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tMRD violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(LOAD_MODE) & "100-" =>
                    IF ck_cntr - ck_load_mode < TMRD THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " INFO: Load Mode to Reset Condition");
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(REFRESH) & "0---" =>
                    IF NOW - tm_refresh < TRFC_MIN THEN
                        REPORT("tRFC violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(REFRESH) & cmd_type_encoding(PWR_DOWN) =>
                    NULL;       -- 1 tCK_avg
                    
                WHEN "0" & cmd_type_encoding(REFRESH) & cmd_type_encoding(SELF_REF) =>
                    IF NOW - tm_refresh < TRFC_MIN THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & "INFO: Refresh to Reset condition");
                    END IF;
                    init_done <= '0';
                    
                WHEN "0" & cmd_type_encoding(PRECHARGE) & "000-" =>
                    IF NOW - tm_precharge_all < TRPA THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRPA violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    IF NOW - tm_precharge < TRP THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRP violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    
                WHEN "1" & cmd_type_encoding(PRECHARGE) & cmd_type_encoding(PRECHARGE) =>
                    IF VERBOSE = TRUE AND NOW - tm_precharge_all < TRPA THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " INFO: Precharge All interruption during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    IF VERBOSE = TRUE AND NOW - tm_bank_precharge(TO_INTEGER(UNSIGNED(bank))) < TRP THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " INFO: Precharge Bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))) & " interruption during "
                            & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    
                WHEN "1" & cmd_type_encoding(PRECHARGE) & cmd_type_encoding(ACTIVATE) =>
                    IF NOW - tm_precharge_all < TRPA THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRPA violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    IF NOW - tm_bank_precharge(TO_INTEGER(UNSIGNED(bank))) < TRP THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " tRP violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) & " to bank "
                            & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(PRECHARGE) & cmd_type_encoding(PWR_DOWN) =>
                    -- 1 tCK, can be concurrent with auto precharge
                    
                WHEN "0" & cmd_type_encoding(PRECHARGE) & cmd_type_encoding(SELF_REF) =>
                    IF NOW - tm_precharge_all < TRPA OR NOW - tm_precharge < TRP THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " INFO: Precharge to reset condition");
                        init_done <= '0';
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(ACTIVATE) & cmd_type_encoding(REFRESH) =>
                    IF NOW - tm_activate < TRC THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRC violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))));
                    END IF;
                    
                WHEN "1" & cmd_type_encoding(ACTIVATE) & cmd_type_encoding(PRECHARGE) =>
                    IF NOW - tm_bank_activate(TO_INTEGER(UNSIGNED(bank))) > TRAS_MAX AND active_bank(TO_INTEGER(UNSIGNED(bank))) = '1' THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRAS maximum violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                            " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;
                    IF NOW - tm_bank_activate(TO_INTEGER(UNSIGNED(bank))) < TRAS_MIN THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRAS minimum violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                            " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;
                    
                WHEN "0" & cmd_type_encoding(ACTIVATE) & cmd_type_encoding(ACTIVATE) =>
                    IF NOW - tm_activate < TRRD THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRRD violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                            " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;
                    
                WHEN "1" & cmd_type_encoding(ACTIVATE) & cmd_type_encoding(ACTIVATE) =>
                    IF NOW - tm_bank_activate(TO_INTEGER(UNSIGNED(bank))) < TRC THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tRC violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) & " to bank " &
                                INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;

                WHEN "1" & cmd_type_encoding(ACTIVATE) & "010-" =>
                    NULL;       -- tRCD is checked outside this task

                WHEN "1" & cmd_type_encoding(ACTIVATE) & cmd_type_encoding(PWR_DOWN) =>
                    NULL;       -- 1 tCK

                WHEN "1" & cmd_type_encoding(WRITE_CMD) & cmd_type_encoding(PRECHARGE) =>
                    IF ck_cntr - ck_bank_write(TO_INTEGER(UNSIGNED(bank)))
                                <= write_latency + TO_INTEGER(UNSIGNED(burst_length)) + 2 OR
                            NOW - tm_bank_write_end(TO_INTEGER(UNSIGNED(bank))) < TWR THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tWR violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                                " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;

                WHEN "0" & cmd_type_encoding(WRITE_CMD) & cmd_type_encoding(WRITE_CMD) =>
                    IF ck_cntr - ck_write < TCCD THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tCCD violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                                " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;

                WHEN "0" & cmd_type_encoding(WRITE_CMD) & cmd_type_encoding(READ_CMD) => 
                    IF ck_load_mode < ck_write AND ck_cntr - ck_write < write_latency + TO_INTEGER(UNSIGNED(burst_length)) / 2 + 2 - additive_latency THEN
                        REPORT("at time " & TIME'IMAGE(NOW) & " ERROR: tWTR violation during " & cmd_string(TO_INTEGER(UNSIGNED(cmd))) &
                                " to bank " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(bank))));
                    END IF;

                WHEN "0" & cmd_type_encoding(WRITE_CMD) & cmd_type_encoding(PWR_DOWN) =>
                    
                    
                WHEN OTHERS =>
                    NULL;       -- do nothing
                
            END CASE?;
        END;
    BEGIN
        WAIT UNTIL RISING_EDGE(ck);
    END PROCESS; -- err
END rtl;
