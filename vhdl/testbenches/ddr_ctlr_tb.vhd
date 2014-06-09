library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_ctlr_tb is
end ddr_ctlr_tb;

architecture beh of ddr_ctlr_tb is
	signal clock		: std_logic := '0';	-- main clock
	signal clock_33	: std_logic := '0';	-- 33 MHz clock	
	signal ddr_clk 	: std_logic := '0';	-- ddr clock
	
	signal vec		: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal o			: std_logic_vector(31 downto 0);
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
begin
	t : DDR_CTRL_V1
	port map
	(
		CLK_MAIN => clock,
		vec_in => vec,
		vec_out => o
	);
	
	stimulate_clock : process
	begin
		wait for 5 ps;
		clock <= not clock;
	end process;
	
	stimulate : process
	begin
		vec <= "00000000000000000000000000000001";
		wait for 20 ps;
		vec <= "10000000000000000000000000000000";
		wait for 20 ps;
		vec <= "00000000000000000000000000000101";
		wait for 20 ps;
	end process;
end beh;
