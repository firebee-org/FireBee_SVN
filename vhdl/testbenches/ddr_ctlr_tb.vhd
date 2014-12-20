library work;
use work.firebee_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;


entity ddr_ctlr_tb is
end ddr_ctlr_tb;


architecture beh of ddr_ctlr_tb is
	signal clock			: std_logic := '0';	-- main clock
	signal ddr_clk 		: std_logic := '0';	-- ddr clock
			
	signal FB_ADR			: std_logic_vector(31 downto 0);
	signal DDR_SYNC_66M	: std_logic := '0';
	signal FB_CS1n			: std_logic;
	signal FB_OEn			: std_logic := '1';	-- only write cycles for now
	signal FB_SIZE0		: std_logic := '1';
	signal FB_SIZE1		: std_logic := '1';	-- long word access
	signal FB_ALE			: std_logic := 'Z';	-- defined reset state
	signal FB_WRn			: std_logic;
	signal FIFO_CLR		: std_logic;
	signal VIDEO_RAM_CTR : std_logic_vector(15 downto 0);
	signal BLITTER_ADR	: std_logic_vector(31 downto 0);
	signal BLITTER_SIG	: std_logic;
	signal BLITTER_WR		: std_logic;
	signal DDRCLK0			: std_logic;
	signal CLK_33M			: std_logic := '0';
	signal FIFO_MW			: std_logic_vector(8 downto 0);
	signal VA				: std_logic_vector(12 downto 0);
	signal VWEn				: std_logic;
	signal VRASn			: std_logic;
	signal VCSn				: std_logic;
	signal VCKE				: std_logic;
	signal VCASn			: std_logic;
	signal FB_LE			: std_logic_vector(3 downto 0);
	signal FB_VDOE			: std_logic_vector(3 downto 0);
	signal SR_FIFO_WRE	: std_logic;
	signal SR_DDR_FB		: std_logic;
	signal SR_DDR_WR		: std_logic;
	signal SR_DDRWR_D_SEL: std_logic;
	signal SR_VDMP			: std_logic_vector(7 downto 0);
	signal VIDEO_DDR_TA	: std_logic;
	signal SR_BLITTER_DACK	: std_logic;
	signal BA				: std_logic_vector(1 downto 0);
	signal DDRWR_D_SEL1	: std_logic;
	signal VDM_SEL			: std_logic_vector(3 downto 0);
	signal DATA_IN			: std_logic_vector(31 downto 0);
	signal DATA_OUT		: std_logic_vector(31 downto 16);
	signal DATA_EN_H		: std_logic;
	signal DATA_EN_L		: std_logic;
	
	type bus_state_type is (S0, S1, S2, S3); 		-- according to state machine description on p 17-14 of the MCF ref manual
	signal bus_state 		: bus_state_type := S0;
	
	component DDR_CTRL_V1
		port(
			CLK_MAIN        : in std_logic;
			DDR_SYNC_66M    : in std_logic;
			FB_ADR          : in std_logic_vector(31 downto 0);
			FB_CS1n         : in std_logic;
			FB_OEn          : in std_logic;
			FB_SIZE0        : in std_logic;
			FB_SIZE1        : in std_logic;
			FB_ALE          : in std_logic;
			FB_WRn          : in std_logic;
			FIFO_CLR        : in std_logic;
			VIDEO_RAM_CTR   : in std_logic_vector(15 downto 0);
			BLITTER_ADR     : in std_logic_vector(31 downto 0);
			BLITTER_SIG     : in std_logic;
			BLITTER_WR      : in std_logic;
			DDRCLK0         : in std_logic;
			CLK_33M         : in std_logic;
			FIFO_MW         : in std_logic_vector(8 downto 0);
			VA              : out std_logic_vector(12 downto 0);
			VWEn            : out std_logic;
			VRASn           : out std_logic;
			VCSn            : out std_logic;
			VCKE            : out std_logic;
			VCASn           : out std_logic;
			FB_LE           : out std_logic_vector(3 downto 0);
			FB_VDOE         : out std_logic_vector(3 downto 0);
			SR_FIFO_WRE     : out std_logic;
			SR_DDR_FB       : out std_logic;
			SR_DDR_WR       : out std_logic;
			SR_DDRWR_D_SEL  : out std_logic;
			SR_VDMP         : out std_logic_vector(7 downto 0);
			VIDEO_DDR_TA    : out std_logic;
			SR_BLITTER_DACK : out std_logic;
			BA              : out std_logic_vector(1 downto 0);
			DDRWR_D_SEL1    : out std_logic;
			VDM_SEL         : out std_logic_vector(3 downto 0);
			DATA_IN         : in std_logic_vector(31 downto 0);
			DATA_OUT        : out std_logic_vector(31 downto 16);
			DATA_EN_H       : out std_logic;
			DATA_EN_L       : out std_logic
		);
	end component;
	
	component ddr_ram_model
	port (
		signal CK		: in std_logic;
		signal CKE		: in std_logic;
		signal CSn		: in std_logic;
		signal RASn		: in std_logic;
		signal CASn		: in std_logic;
		signal WEn		: in std_logic;
		signal LDM		: in std_logic;
		signal UDM		: in std_logic;
		signal BA		: in std_logic_vector(1 downto 0);
		signal A			: in std_logic_vector(12 downto 0);
		signal DQ		: inout std_logic_vector(7 downto 0);
		signal LDQS		: inout std_logic;
		signal UDQS		: inout std_logic
	);
	end component;
begin
	t : DDR_CTRL_V1
	port map
	(
		CLK_MAIN => clock,
		DDR_SYNC_66M => DDR_SYNC_66M,
		FB_ADR => FB_ADR,
		FB_CS1n => FB_CS1n,
		FB_OEn => FB_OEn,
		FB_SIZE0 => FB_SIZE0,
		FB_SIZE1 => FB_SIZE1,
		FB_ALE => FB_ALE,
		FB_WRn => FB_WRn,
		FIFO_CLR => FIFO_CLR,
		VIDEO_RAM_CTR => VIDEO_RAM_CTR,
		BLITTER_ADR => BLITTER_ADR,
		BLITTER_SIG => BLITTER_SIG,
		BLITTER_WR => BLITTER_WR,
		DDRCLK0 => DDRCLK0,
		CLK_33M => CLK_33M,
		FIFO_MW => FIFO_MW,
		VA => VA,
		VWEn => VWEn,
		VRASn => VRASn,
		VCSn => VCSn,
		VCKE => VCKE,
		VCASn => VCASn,
		FB_LE => FB_LE,
		FB_VDOE => FB_VDOE,
		SR_FIFO_WRE => SR_FIFO_WRE,
		SR_DDR_FB => SR_DDR_FB,
		SR_DDR_WR => SR_DDR_WR,
		SR_DDRWR_D_SEL => SR_DDRWR_D_SEL,
		SR_VDMP => SR_VDMP,
		VIDEO_DDR_TA => VIDEO_DDR_TA,
		SR_BLITTER_DACK => SR_BLITTER_DACK,
		BA => BA,
		DDRWR_D_SEL1 => DDRWR_D_SEL1,
		VDM_SEL => VDM_SEL,
		DATA_IN => DATA_IN,
		DATA_OUT => DATA_OUT,
		DATA_EN_H => DATA_EN_H,
		DATA_EN_L => DATA_EN_L
	);
	
	d : ddr_ram_model
	port map
	(
		CK		=> DDRCLK0,
		CKE	=> VCKE,
		CSn	=> VCSn,
		RASn	=> VRASn,
		CASn	=> VCASn,
		WEn	=> VWEn,
		LDM	=> DATA_EN_L,
		UDM	=> DATA_EN_H,
		BA		=> BA,
		A		=> VA,
		DQ		=> SR_VDMP,
		LDQS	=> DATA_EN_L,
		UDQS	=> DATA_EN_H
	);
	
	stimulate_main_clock : process
	begin
		wait for 4.31 ns;
		clock <= not clock;
	end process;
	
	stimulate_33mHz_clock : process
	begin
		wait for 30.3 ns;
		CLK_33M <= not CLK_33M;
	end process;
	
	stimulate_66MHz_clock : process
	begin
		wait for 66.6 ns;
		DDR_SYNC_66M <= not DDR_SYNC_66M;
		DDRCLK0 <= DDR_SYNC_66M;
	end process;
	
	stimulate : process
		variable adr : std_logic_vector(31 downto 0) := x"00000000";
	begin
		wait until rising_edge(clock) and clock = '1';
		case bus_state is
			when S0 =>
			  -- address phase
				FB_ADR <= adr;
				FB_ALE <= '1';
				FB_WRn <= '0';
				bus_state <= S1;
			when S1 =>
				-- data phase
				FB_ALE <= '0';
				FB_CS1n <= '0';
				FB_ADR <= x"47114711";
				if (VIDEO_DDR_TA = '1') then
					bus_state <= S2;
				end if;
			when S2 =>
				FB_CS1n <= '0';
				bus_state <= S3;
			when S3 =>
				FB_ADR <= std_logic_vector(unsigned(FB_ADR) + 4);
				bus_state <= S0;
				FB_WRn <= 'Z';
			when others =>
				report("bus_state: ");
		end case;
	end process;
end beh;
