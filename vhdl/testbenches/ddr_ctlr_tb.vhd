LIBRARY work;
    USE work.firebee_pkg.ALL;
    USE work.ddr2_ram_model_pkg.ALL;
    
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

USE std.textio.ALL;


ENTITY ddr_ctlr_tb IS
END ddr_ctlr_tb;


ARCHITECTURE beh OF ddr_ctlr_tb IS
    SIGNAL clock            : STD_LOGIC := '0';    -- main clock
    SIGNAL ddr_clk          : STD_LOGIC := '0';    -- ddr clock
            
    SIGNAL fb_adr           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ddr_sync_66m     : STD_LOGIC := '0';
    SIGNAL fb_cs1_n         : STD_LOGIC;
    SIGNAL fb_oe_n          : STD_LOGIC := '1';    -- only write cycles for now
    SIGNAL fb_size0         : STD_LOGIC := '1';
    SIGNAL fb_size1         : STD_LOGIC := '1';    -- long word access
    SIGNAL fb_ale           : STD_LOGIC := 'Z';    -- defined reset state
    SIGNAL fb_wr_n          : STD_LOGIC;
    SIGNAL fifo_clr         : STD_LOGIC;
    SIGNAL video_ram_ctr    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL blitter_adr      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL blitter_sig      : STD_LOGIC;
    SIGNAL blitter_wr       : STD_LOGIC;
    SIGNAL ddrclk0          : STD_LOGIC;
    SIGNAL clk_33m          : STD_LOGIC := '0';
    SIGNAL fifo_mw          : UNSIGNED (8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL va               : STD_LOGIC_VECTOR(12 DOWNTO 0);
    SIGNAL vwe_n            : STD_LOGIC;
    SIGNAL vras_n           : STD_LOGIC;
    SIGNAL vcs_n            : STD_LOGIC;
    SIGNAL vcke             : STD_LOGIC;
    SIGNAL vcas_n           : STD_LOGIC;
    SIGNAL fb_le            : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL fb_vdoe          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sr_fifo_wre      : STD_LOGIC;
    SIGNAL sr_ddr_fb        : STD_LOGIC;
    SIGNAL sr_ddr_wr        : STD_LOGIC;
    SIGNAL sr_ddrwr_d_sel   : STD_LOGIC;
    SIGNAL sr_vdmp          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL video_ddr_ta     : STD_LOGIC;
    SIGNAL sr_blitter_dack  : STD_LOGIC;
    SIGNAL ba               : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ddrwr_d_sel1     : STD_LOGIC;
    SIGNAL vdm_sel          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL data_in          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data_out         : STD_LOGIC_VECTOR(31 DOWNTO 16);
    SIGNAL data_en_h        : STD_LOGIC;
    SIGNAL data_en_l        : STD_LOGIC;
    
    TYPE bus_state_t IS (S0, S1, S2, S3);               -- according to state machine description on p 17-14 of the MCF ref manual
    SIGNAL bus_state        : bus_state_t := S0;
        
BEGIN
    i_ddr_ctrl : DDR_CTRL
    PORT map
    (
        clk_main => clock,
        ddr_sync_66m => ddr_sync_66m,
        fb_adr => fb_adr,
        fb_cs1_n => fb_cs1_n,
        fb_oe_n => fb_oe_n,
        fb_size0 => fb_size0,
        fb_size1 => fb_size1,
        fb_ale => fb_ale,
        FB_WR_n => fb_wr_n,
        fifo_clr => fifo_clr,
        video_control_register => video_ram_ctr,
        blitter_adr => blitter_adr,
        blitter_sig => blitter_sig,
        blitter_wr => blitter_wr,
        ddrclk0 => ddrclk0,
        clk_33m => clk_33m,
        fifo_mw => fifo_mw,
        va => va,
        vwe_n => vwe_n,
        vras_n => vras_n,
        vcs_n => vcs_n,
        vcke => vcke,
        vcas_n => vcas_n,
        fb_le => fb_le,
        fb_vdoe => fb_vdoe,
        sr_fifo_wre => sr_fifo_wre,
        sr_ddr_fb => sr_ddr_fb,
        sr_ddr_wr => sr_ddr_wr,
        sr_ddrwr_d_sel => sr_ddrwr_d_sel,
        sr_vdmp => sr_vdmp,
        video_ddr_ta => video_ddr_ta,
        sr_blitter_dack => sr_blitter_dack,
        ba => ba,
        ddrwr_d_sel1 => ddrwr_d_sel1,
        vdm_sel => vdm_sel,
        data_in => data_in,
        data_out => data_out,
        data_en_h => data_en_h,
        data_en_l => data_en_l
    );
    
    i_ddr2_ram_1 : ddr2_ram_model
    GENERIC MAP
    (
        VERBOSE     => TRUE,          -- define if you want additional debug output

        CLOCK_TICK  => (1000000 / 132000) * 1 ps,     -- time for one clock tick

        BA_BITS     => 2,             -- number of banks
        ADDR_BITS   => 13,            -- number of address bits
        DM_BITS     => 2,             -- number of data mask bits
        DQ_BITS     => 8,             -- number of data bits
        DQS_BITS    => 2              -- number of data strobes
    )
    PORT map
    (
        ck          => ddrclk0,
        ck_n        => NOT ddrclk0,
        cke         => vcke,
        cs_n        => vcs_n,
        ras_n       => vras_n,
        cas_n       => vcas_n,
        we_n        => vwe_n,
        dm_rdqs(0)  => data_en_l,
        dm_rdqs(1)  => data_en_h,
        ba          => ba,
        addr        => va,
        dq          => sr_vdmp,
        dqs(0)      => data_en_l,
        dqs(1)      => data_en_h,
        odt         => '0'
    );

    i_ddr2_ram_2 : ddr2_ram_model
    GENERIC MAP
    (
        VERBOSE     => TRUE,          -- define if you want additional debug output

        CLOCK_TICK  => (1000000 / 132000) * 1 ps,     -- time for one clock tick

        BA_BITS     => 2,             -- number of banks
        ADDR_BITS   => 13,            -- number of address bits
        DM_BITS     => 2,             -- number of data mask bits
        DQ_BITS     => 8,             -- number of data bits
        DQS_BITS    => 2              -- number of data strobes
    )
    PORT map
    (
        ck          => ddrclk0,
        ck_n        => NOT ddrclk0,
        cke         => vcke,
        cs_n        => vcs_n,
        ras_n       => vras_n,
        cas_n       => vcas_n,
        we_n        => vwe_n,
        dm_rdqs(0)  => data_en_l,
        dm_rdqs(1)  => data_en_h,
        ba          => ba,
        addr        => va,
        dq          => sr_vdmp,
        dqs(0)      => data_en_l,
        dqs(1)      => data_en_h,
        odt         => '0'
    );
    
    stimulate_main_clock : process
    BEGIN
        WAIT FOR 4.31 ns;
        clock <= NOT clock;
    END process;
    
    stimulate_33mHz_clock : process
    BEGIN
        WAIT FOR 30.3 ns;
        clk_33m <= NOT clk_33m;
    END process;
    
    stimulate_66MHz_clock : process
    BEGIN
        WAIT FOR 66.6 ns;
        ddr_sync_66m <= NOT ddr_sync_66m;
        ddrclk0 <= ddr_sync_66m;
    END process;
    
    stimulate : process
        VARIABLE adr : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    BEGIN
        WAIT UNTIL RISING_EDGE(clock);
        CASE bus_state IS
            WHEN S0 =>
              -- address phase
                fb_adr <= adr;
                fb_ale <= '1';
                fb_wr_n <= '0';
                bus_state <= S1;
            WHEN S1 =>
                -- data phase
                fb_ale <= '0';
                fb_cs1_n <= '0';
                fb_adr <= x"47114711";
                if (video_ddr_ta = '1') then
                    bus_state <= S2;
                END if;
            WHEN S2 =>
                fb_cs1_n <= '0';
                bus_state <= S3;
            WHEN S3 =>
                fb_adr <= STD_LOGIC_VECTOR(UNSIGNED(fb_adr) + 4);
                bus_state <= S0;
                fb_wr_n <= 'Z';
            WHEN others =>
                REPORT("bus_state: ");
        END CASE;
    END process;
END beh;

