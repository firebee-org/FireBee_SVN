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
    SIGNAL clock            : STD_LOGIC := '0';	-- main clock
    SIGNAL ddr_clk          : STD_LOGIC := '0';	-- ddr clock
			
    SIGNAL FB_ADR           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DDR_SYNC_66M     : STD_LOGIC := '0';
    SIGNAL FB_CS1_n         : STD_LOGIC;
    SIGNAL FB_OE_n          : STD_LOGIC := '1';	-- only write cycles for now
    SIGNAL FB_SIZE0         : STD_LOGIC := '1';
    SIGNAL FB_SIZE1         : STD_LOGIC := '1';	-- long word access
    SIGNAL FB_ALE           : STD_LOGIC := 'Z';	-- defined reset state
    SIGNAL FB_WRn           : STD_LOGIC;
    SIGNAL FIFO_CLR         : STD_LOGIC;
    SIGNAL VIDEO_RAM_CTR    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL BLITTER_ADR      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BLITTER_SIG      : STD_LOGIC;
    SIGNAL BLITTER_WR		: STD_LOGIC;
    SIGNAL ddrclk0			: STD_LOGIC;
    SIGNAL CLK_33M			: STD_LOGIC := '0';
    SIGNAL FIFO_MW			: STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL va				: STD_LOGIC_VECTOR(12 DOWNTO 0);
    SIGNAL vwe_n				: STD_LOGIC;
    SIGNAL vras_n			: STD_LOGIC;
    SIGNAL vcs_n				: STD_LOGIC;
    SIGNAL vcke				: STD_LOGIC;
    SIGNAL vcas_n			: STD_LOGIC;
    SIGNAL FB_LE			: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL FB_VDOE			: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SR_FIFO_WRE      : STD_LOGIC;
    SIGNAL SR_DDR_FB		: STD_LOGIC;
    SIGNAL SR_DDR_WR		: STD_LOGIC;
    SIGNAL SR_DDRWR_D_SEL   : STD_LOGIC;
    SIGNAL sr_vdmp			: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL VIDEO_DDR_TA     : STD_LOGIC;
    SIGNAL SR_BLITTER_DACK	: STD_LOGIC;
    SIGNAL ba				: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL DDRWR_D_SEL1     : STD_LOGIC;
    SIGNAL VDM_SEL			: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL DATA_IN			: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DATA_OUT         : STD_LOGIC_VECTOR(31 DOWNTO 16);
	SIGNAL data_en_h		: STD_LOGIC;
	SIGNAL data_en_l		: STD_LOGIC;
	
	TYPE bus_state_t IS (S0, S1, S2, S3);               -- according to state machine description on p 17-14 of the MCF ref manual
	SIGNAL bus_state        : bus_state_t := S0;
		
BEGIN
	t : DDR_CTRL
	PORT map
	(
		CLK_MAIN => clock,
		DDR_SYNC_66M => DDR_SYNC_66M,
		FB_ADR => FB_ADR,
		FB_CS1_n => fb_cs1_n,
		FB_OE_n => FB_OE_n,
		FB_SIZE0 => FB_SIZE0,
		FB_SIZE1 => FB_SIZE1,
		FB_ALE => FB_ALE,
		FB_WR_n => FB_WRn,
		FIFO_CLR => FIFO_CLR,
		video_control_register => VIDEO_RAM_CTR,
		BLITTER_ADR => BLITTER_ADR,
		BLITTER_SIG => BLITTER_SIG,
		BLITTER_WR => BLITTER_WR,
		ddrclk0 => ddrclk0,
		CLK_33M => CLK_33M,
		FIFO_MW => FIFO_MW,
		va => va,
		vwe_n => vwe_n,
		vras_n => vras_n,
		vcs_n => vcs_n,
		vcke => vcke,
		vcas_n => vcas_n,
		FB_LE => FB_LE,
		FB_VDOE => FB_VDOE,
		SR_FIFO_WRE => SR_FIFO_WRE,
		SR_DDR_FB => SR_DDR_FB,
		SR_DDR_WR => SR_DDR_WR,
		SR_DDRWR_D_SEL => SR_DDRWR_D_SEL,
		sr_vdmp => sr_vdmp,
		VIDEO_DDR_TA => VIDEO_DDR_TA,
		SR_BLITTER_DACK => SR_BLITTER_DACK,
		ba => ba,
		DDRWR_D_SEL1 => DDRWR_D_SEL1,
		VDM_SEL => VDM_SEL,
		DATA_IN => DATA_IN,
		DATA_OUT => DATA_OUT,
		data_en_h => data_en_h,
		data_en_l => data_en_l
	);
	
	d1 : ddr2_ram_model
	PORT map
	(
        ck		=> ddrclk0,
        ck_n    => NOT ddrclk0,
		cke     => vcke,
		cs_n	=> vcs_n,
		ras_n	=> vras_n,
		cas_n	=> vcas_n,
		we_n    => vwe_n,
		dm_rdqs(0)  => data_en_l,
		dm_rdqs(1)  => data_en_h,
		ba		=> ba,
		addr		=> va (25 DOWNTO 13),
		DQ		=> sr_vdmp,
		LDQS	=> data_en_l,
		UDQS	=> data_en_h
	);
	
	stimulate_main_clock : process
	BEGIN
		WAIT FOR 4.31 ns;
		clock <= NOT clock;
	END process;
	
	stimulate_33mHz_clock : process
	BEGIN
		WAIT FOR 30.3 ns;
		CLK_33M <= NOT CLK_33M;
	END process;
	
	stimulate_66MHz_clock : process
	BEGIN
		WAIT FOR 66.6 ns;
		DDR_SYNC_66M <= NOT DDR_SYNC_66M;
		ddrclk0 <= DDR_SYNC_66M;
	END process;
	
	stimulate : process
		VARIABLE adr : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
	BEGIN
		WAIT UNTIL RISING_EDGE(clock);
		CASE bus_state IS
			WHEN S0 =>
			  -- address phase
				FB_ADR <= adr;
				FB_ALE <= '1';
				FB_WRn <= '0';
				bus_state <= S1;
			WHEN S1 =>
				-- data phase
				FB_ALE <= '0';
				FB_CS1n <= '0';
				FB_ADR <= x"47114711";
				if (VIDEO_DDR_TA = '1') then
					bus_state <= S2;
				END if;
			WHEN S2 =>
				FB_CS1n <= '0';
				bus_state <= S3;
			WHEN S3 =>
				FB_ADR <= STD_LOGIC_VECTOR(UNSIGNED(FB_ADR) + 4);
				bus_state <= S0;
				FB_WRn <= 'Z';
			WHEN others =>
				REPORT("bus_state: ");
		END CASE;
	END process;
END beh;

