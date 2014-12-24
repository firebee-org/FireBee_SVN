LIBRARY work;
    USE work.firebee_pkg.ALL;
    USE work.ddr_ram_model_pkg.ALL;
    
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

USE std.textio.ALL;


ENTITY firebee_tb IS
END firebee_tb;


ARCHITECTURE beh OF firebee_tb IS
    COMPONENT firebee IS
        PORT(
            rsto_mcf_n          : IN STD_LOGIC;                -- reset SIGNAL from Coldfire
            clk_33m             : IN STD_LOGIC;                -- 33 MHz clock
            clk_main            : IN STD_LOGIC;                -- 33 MHz clock
    
            clk_24m576          : OUT STD_LOGIC;            -- 
            clk_25m             : OUT STD_LOGIC;
            clk_ddr_out         : OUT STD_LOGIC;
            clk_ddr_out_n       : OUT STD_LOGIC;
            clk_usb             : OUT STD_LOGIC;
    
            fb_ad               : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            fb_ale              : IN STD_LOGIC;
            fb_burst_n          : IN STD_LOGIC;
            fb_cs_n             : IN STD_LOGIC_VECTOR (3 DOWNTO 1);
            fb_size             : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            fb_oe_n             : IN STD_LOGIC;
            fb_wr_n             : IN STD_LOGIC;
            fb_ta_n             : OUT STD_LOGIC;
            
            dack1_n             : IN STD_LOGIC;
            dreq1_n             : OUT STD_LOGIC;
    
            master_n            : IN STD_LOGIC; -- determines if the Firebee is PCI master (='0') OR slave. Not used so far.
            tout0_n             : IN STD_LOGIC; -- Not used so far.
    
            led_fpga_ok         : OUT STD_LOGIC;
            reserved_1          : OUT STD_LOGIC;
    
            va                  : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
            ba                  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            vwe_n               : OUT STD_LOGIC;
            vcas_n              : OUT STD_LOGIC;
            vras_n              : OUT STD_LOGIC;
            vcs_n               : OUT STD_LOGIC;
    
            clk_pixel           : OUT STD_LOGIC;
            sync_n              : OUT STD_LOGIC;
            vsync               : OUT STD_LOGIC;
            hsync               : OUT STD_LOGIC;
            blank_n             : OUT STD_LOGIC;
            
            vr                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            vg                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            vb                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    
            vdm                 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    
            vd                  : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            vd_qs               : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    
            pd_vga_n            : OUT STD_LOGIC;
            vcke                : OUT STD_LOGIC;
            pic_int             : IN STD_LOGIC;
            e0_int              : IN STD_LOGIC;
            dvi_int             : IN STD_LOGIC;
            pci_inta_n          : IN STD_LOGIC;
            pci_intb_n          : IN STD_LOGIC;
            pci_intc_n          : IN STD_LOGIC;
            pci_intd_n          : IN STD_LOGIC;
    
            irq_n               : OUT STD_LOGIC_VECTOR (7 DOWNTO 2);
            tin0                : OUT STD_LOGIC;
    
            ym_qa               : OUT STD_LOGIC;
            ym_qb               : OUT STD_LOGIC;
            ym_qc               : OUT STD_LOGIC;
    
            lp_d                : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            lp_dir              : OUT STD_LOGIC;
    
            dsa_d               : OUT STD_LOGIC;
            lp_str              : OUT STD_LOGIC;
            dtr                 : OUT STD_LOGIC;
            rts                 : OUT STD_LOGIC;
            cts                 : IN STD_LOGIC;
            ri                  : IN STD_LOGIC;
            dcd                 : IN STD_LOGIC;
            lp_busy             : IN STD_LOGIC;
            rxd                 : IN STD_LOGIC;
            txd                 : OUT STD_LOGIC;
            midi_in             : IN STD_LOGIC;
            midi_olr            : OUT STD_LOGIC;
            midi_tlr            : OUT STD_LOGIC;
            pic_amkb_rx         : IN STD_LOGIC;
            amkb_rx             : IN STD_LOGIC;
            amkb_tx             : OUT STD_LOGIC;
            dack0_n             : IN STD_LOGIC; -- Not used.
            
            scsi_drqn           : IN STD_LOGIC;
            SCSI_MSGn           : IN STD_LOGIC;
            SCSI_CDn            : IN STD_LOGIC;
            SCSI_IOn            : IN STD_LOGIC;
            SCSI_ACKn           : OUT STD_LOGIC;
            SCSI_ATNn           : OUT STD_LOGIC;
            SCSI_SELn           : INOUT STD_LOGIC;
            SCSI_BUSYn          : INOUT STD_LOGIC;
            SCSI_RSTn           : INOUT STD_LOGIC;
            SCSI_DIR            : OUT STD_LOGIC;
            SCSI_D              : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            SCSI_PAR            : INOUT STD_LOGIC;
    
            ACSI_DIR            : OUT STD_LOGIC;
            ACSI_D              : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            ACSI_CSn            : OUT STD_LOGIC;
            ACSI_A1             : OUT STD_LOGIC;
            ACSI_reset_n        : OUT STD_LOGIC;
            ACSI_ACKn           : OUT STD_LOGIC;
            ACSI_DRQn           : IN STD_LOGIC;
            ACSI_INTn           : IN STD_LOGIC;
    
            FDD_DCHGn           : IN STD_LOGIC;
            FDD_SDSELn          : OUT STD_LOGIC;
            FDD_HD_DD           : IN STD_LOGIC;
            FDD_RDn             : IN STD_LOGIC;
            FDD_TRACK00         : IN STD_LOGIC;
            FDD_INDEXn          : IN STD_LOGIC;
            FDD_WPn             : IN STD_LOGIC;
            FDD_MOT_ON          : OUT STD_LOGIC;
            FDD_WR_GATE         : OUT STD_LOGIC;
            FDD_WDn             : OUT STD_LOGIC;
            FDD_STEP            : OUT STD_LOGIC;
            FDD_STEP_DIR        : OUT STD_LOGIC;
    
            ROM4n               : OUT STD_LOGIC;
            ROM3n               : OUT STD_LOGIC;
    
            RP_UDSn             : OUT STD_LOGIC;
            RP_ldsn             : OUT STD_LOGIC;
            SD_CLK              : OUT STD_LOGIC;
            SD_D3               : INOUT STD_LOGIC;
            SD_CMD_D1           : INOUT STD_LOGIC;
            SD_D0               : IN STD_LOGIC;
            SD_D1               : IN STD_LOGIC;
            SD_D2               : IN STD_LOGIC;
            SD_caRD_DETECT      : IN STD_LOGIC;
            SD_WP               : IN STD_LOGIC;
    
            CF_WP               : IN STD_LOGIC;
            CF_CSn              : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    
            DSP_IO              : INOUT STD_LOGIC_VECTOR (17 DOWNTO 0);
            DSP_SRD             : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            DSP_SRCSn           : OUT STD_LOGIC;
            DSP_SRBLEn          : OUT STD_LOGIC;
            DSP_SRBHEn          : OUT STD_LOGIC;
            DSP_SRWEn           : OUT STD_LOGIC;
            DSP_SROEn           : OUT STD_LOGIC;
    
            ide_int             : IN STD_LOGIC;
            ide_rdy             : IN STD_LOGIC;
            ide_res             : OUT STD_LOGIC;
            IDE_WRn             : OUT STD_LOGIC;
            IDE_RDn             : OUT STD_LOGIC;
            IDE_CSn             : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT firebee;
    
    SIGNAL rsto_mcf_n       : STD_LOGIC := '0';                -- reset SIGNAL from Coldfire
    SIGNAL clk_33m          : STD_LOGIC := '0';                -- 33 MHz clock
    SIGNAL clk_main         : STD_LOGIC := '0';                -- 33 MHz clock
    
    SIGNAL clk_24m576       : STD_LOGIC;            -- 
    SIGNAL clk_25m          : STD_LOGIC;
    SIGNAL clk_ddr_out      : STD_LOGIC;
    SIGNAL clk_ddr_out_n    : STD_LOGIC;
    SIGNAL clk_usb          : STD_LOGIC;
    
    SIGNAL fb_ad            : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_ale           : STD_LOGIC;
    SIGNAL fb_burst_n       : STD_LOGIC := '1';
    SIGNAL fb_cs_n          : STD_LOGIC_VECTOR (3 DOWNTO 1) := "111";
    SIGNAL fb_size          : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    SIGNAL fb_oe_n          : STD_LOGIC := '1';
    SIGNAL fb_wr_n          : STD_LOGIC := '1';
    SIGNAL fb_ta_n          : STD_LOGIC := '1';
            
    SIGNAL dack1_n          : STD_LOGIC;
    SIGNAL dreq1_n          : STD_LOGIC;
    
    SIGNAL master_n         : STD_LOGIC := '0'; -- determines if the Firebee is PCI master (='0') OR slave. Not used so far.
    SIGNAL tout0_n          : STD_LOGIC; -- Not used so far.
    
    SIGNAL led_fpga_ok      : STD_LOGIC;
    SIGNAL reserved_1       : STD_LOGIC;
    
    SIGNAL va               : STD_LOGIC_VECTOR (12 DOWNTO 0);
    SIGNAL ba               : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL vwe_n            : STD_LOGIC;
    SIGNAL vcas_n           : STD_LOGIC;
    SIGNAL vras_n           : STD_LOGIC;
    SIGNAL vcs_n            : STD_LOGIC;
    
    SIGNAL clk_pixel        : STD_LOGIC;
    SIGNAL sync_n           : STD_LOGIC;
    SIGNAL vsync            : STD_LOGIC;
    SIGNAL hsync            : STD_LOGIC;
    SIGNAL blank_n          : STD_LOGIC;
            
    SIGNAL vr               : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL vg               : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL vb               : STD_LOGIC_VECTOR (7 DOWNTO 0);
    
    SIGNAL vdm              : STD_LOGIC_VECTOR (3 DOWNTO 0);
    
    SIGNAL vd               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL vd_qs            : STD_LOGIC_VECTOR (3 DOWNTO 0);
    
    SIGNAL pd_vga_n         : STD_LOGIC;
    SIGNAL vcke             : STD_LOGIC;
    SIGNAL pic_int          : STD_LOGIC;
    SIGNAL e0_int           : STD_LOGIC;
    SIGNAL dvi_int          : STD_LOGIC;
    SIGNAL pci_inta_n       : STD_LOGIC;
    SIGNAL pci_intb_n       : STD_LOGIC;
    SIGNAL pci_intc_n       : STD_LOGIC;
    SIGNAL pci_intd_n       : STD_LOGIC;
    
    SIGNAL irq_n            : STD_LOGIC_VECTOR (7 DOWNTO 2);
    SIGNAL tin0             : STD_LOGIC;
    
    SIGNAL ym_qa            : STD_LOGIC;
    SIGNAL ym_qb            : STD_LOGIC;
    SIGNAL ym_qc            : STD_LOGIC;
    
    SIGNAL lp_d             : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL lp_dir           : STD_LOGIC;
    
    SIGNAL dsa_d            : STD_LOGIC;
    SIGNAL lp_str           : STD_LOGIC;
    SIGNAL dtr              : STD_LOGIC;
    SIGNAL rts              : STD_LOGIC;
    SIGNAL cts              : STD_LOGIC;
    SIGNAL ri               : STD_LOGIC;
    SIGNAL dcd              : STD_LOGIC;
    SIGNAL lp_busy          : STD_LOGIC;
    SIGNAL rxd              : STD_LOGIC;
    SIGNAL txd              : STD_LOGIC;
    SIGNAL midi_in          : STD_LOGIC;
    SIGNAL midi_olr         : STD_LOGIC;
    SIGNAL midi_tlr         : STD_LOGIC;
    SIGNAL pic_amkb_rx      : STD_LOGIC;
    SIGNAL amkb_rx          : STD_LOGIC;
    SIGNAL amkb_tx          : STD_LOGIC;
    SIGNAL dack0_n          : STD_LOGIC; -- Not used.
            
    SIGNAL scsi_drqn        : STD_LOGIC;
    SIGNAL SCSI_MSGn        : STD_LOGIC;
    SIGNAL SCSI_CDn         : STD_LOGIC;
    SIGNAL SCSI_IOn         : STD_LOGIC;
    SIGNAL SCSI_ACKn        : STD_LOGIC;
    SIGNAL SCSI_ATNn        : STD_LOGIC;
    SIGNAL SCSI_SELn        : STD_LOGIC;
    SIGNAL SCSI_BUSYn       : STD_LOGIC;
    SIGNAL SCSI_RSTn        : STD_LOGIC;
    SIGNAL SCSI_DIR         : STD_LOGIC;
    SIGNAL SCSI_D           : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL SCSI_PAR         : STD_LOGIC;
    
    SIGNAL ACSI_DIR         : STD_LOGIC;
    SIGNAL ACSI_D           : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL ACSI_CSn         : STD_LOGIC;
    SIGNAL ACSI_A1          : STD_LOGIC;
    SIGNAL ACSI_reset_n     : STD_LOGIC;
    SIGNAL ACSI_ACKn        : STD_LOGIC;
    SIGNAL ACSI_DRQn        : STD_LOGIC;
    SIGNAL ACSI_INTn        : STD_LOGIC;
    
    SIGNAL FDD_DCHGn        : STD_LOGIC;
    SIGNAL FDD_SDSELn       : STD_LOGIC;
    SIGNAL FDD_HD_DD        : STD_LOGIC;
    SIGNAL FDD_RDn          : STD_LOGIC;
    SIGNAL FDD_TRACK00      : STD_LOGIC;
    SIGNAL FDD_INDEXn       : STD_LOGIC;
    SIGNAL FDD_WPn          : STD_LOGIC;
    SIGNAL FDD_MOT_ON       : STD_LOGIC;
    SIGNAL FDD_WR_GATE      : STD_LOGIC;
    SIGNAL FDD_WDn          : STD_LOGIC;
    SIGNAL FDD_STEP         : STD_LOGIC;
    SIGNAL FDD_STEP_DIR     : STD_LOGIC;
    
    SIGNAL ROM4n            : STD_LOGIC;
    SIGNAL ROM3n            : STD_LOGIC;
    
    SIGNAL RP_UDSn          : STD_LOGIC;
    SIGNAL RP_ldsn          : STD_LOGIC;
    SIGNAL SD_CLK           : STD_LOGIC;
    SIGNAL SD_D3            : STD_LOGIC;
    SIGNAL SD_CMD_D1        : STD_LOGIC;
    SIGNAL SD_D0            : STD_LOGIC;
    SIGNAL SD_D1            : STD_LOGIC;
    SIGNAL SD_D2            : STD_LOGIC;
    SIGNAL SD_caRD_DETECT   : STD_LOGIC;
    SIGNAL SD_WP            : STD_LOGIC;
    
    SIGNAL CF_WP            : STD_LOGIC;
    SIGNAL CF_CSn           : STD_LOGIC_VECTOR (1 DOWNTO 0);
    
    SIGNAL DSP_IO           : STD_LOGIC_VECTOR (17 DOWNTO 0);
    SIGNAL DSP_SRD          : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL DSP_SRCSn        : STD_LOGIC;
    SIGNAL DSP_SRBLEn       : STD_LOGIC;
    SIGNAL DSP_SRBHEn       : STD_LOGIC;
    SIGNAL DSP_SRWEn        : STD_LOGIC;
    SIGNAL DSP_SROEn        : STD_LOGIC;
    
    SIGNAL ide_int          : STD_LOGIC;
    SIGNAL ide_rdy          : STD_LOGIC;
    SIGNAL ide_res          : STD_LOGIC;
    SIGNAL IDE_WRn          : STD_LOGIC;
    SIGNAL IDE_RDn          : STD_LOGIC;
    SIGNAL IDE_CSn          : STD_LOGIC_VECTOR (1 DOWNTO 0);
    
    SIGNAL a                : UNSIGNED (31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    I_FIREBEE : firebee
    PORT MAP (
        rsto_mcf_n      => rsto_mcf_n,
        clk_33m         => clk_33m,
        clk_main        => clk_main,
        clk_24m576      => clk_24m576,
        clk_25m         => clk_25m,
        clk_ddr_out     => clk_ddr_out,
        clk_ddr_out_n   => clk_ddr_out_n,
        clk_usb         => clk_usb,
        fb_ad           => fb_ad,
        fb_ale          => fb_ale,
        fb_burst_n      => fb_burst_n,
        fb_cs_n         => fb_cs_n,
        fb_size         => fb_size,
        fb_oe_n         => fb_oe_n,
        fb_wr_n         => fb_wr_n,
        fb_ta_n         => fb_ta_n,       
        dack1_n         => dack1_n,
        dreq1_n         => dreq1_n,
        master_n        => master_n,
        tout0_n         => tout0_n,
        led_fpga_ok     => led_fpga_ok,
        reserved_1      => reserved_1,
        va              => va,
        ba              => ba,
        vwe_n           => vwe_n,
        vcas_n          => vcas_n,
        vras_n          => vras_n,
        vcs_n           => vcs_n,
        clk_pixel       => clk_pixel,
        sync_n          => sync_n,
        vsync           => vsync,
        hsync           => hsync,
        blank_n         => blank_n,       
        vr              => vr,
        vg              => vg,
        vb              => vb,
        vdm             => vdm,
        vd              => vd,
        vd_qs           => vd_qs,
        pd_vga_n        => pd_vga_n,
        vcke            => vcke,
        pic_int         => pic_int,
        e0_int          => e0_int,
        dvi_int         => dvi_int,
        pci_inta_n      => pci_inta_n,
        pci_intb_n      => pci_intb_n,
        pci_intc_n      => pci_intc_n,
        pci_intd_n      => pci_intd_n,
        irq_n           => irq_n,
        tin0            => tin0,
        ym_qa           => ym_qa,
        ym_qb           => ym_qb,
        ym_qc           => ym_qc,
        lp_d            => lp_d,
        lp_dir          => lp_dir,
        dsa_d           => dsa_d,
        lp_str          => lp_str,
        dtr             => dtr,
        rts             => rts,
        cts             => cts,
        ri              => ri,
        dcd             => dcd,
        lp_busy         => lp_busy,
        rxd             => rxd,
        txd             => txd,
        midi_in         => midi_in,
        midi_olr        => midi_olr,
        midi_tlr        => midi_tlr,
        pic_amkb_rx     => pic_amkb_rx,
        amkb_rx         => amkb_rx,
        amkb_tx         => amkb_tx,
        dack0_n         => dack0_n,        
        scsi_drqn       => scsi_drqn,
        SCSI_MSGn       => scsi_msgn,
        SCSI_CDn        => scsi_cdn,
        SCSI_IOn        => scsi_ion,
        SCSI_ACKn       => scsi_ackn,
        SCSI_ATNn       => scsi_atnn,
        SCSI_SELn       => scsi_seln,
        SCSI_BUSYn      => scsi_busyn,
        SCSI_RSTn       => scsi_rstn,
        SCSI_DIR        => scsi_dir,
        SCSI_D          => scsi_d,
        SCSI_PAR        => scsi_par,
        ACSI_DIR        => acsi_dir,
        ACSI_D          => acsi_d,
        ACSI_CSn        => acsi_csn,
        ACSI_A1         => acsi_a1,
        ACSI_reset_n    => acsi_reset_n,
        ACSI_ACKn       => acsi_ackn,
        ACSI_DRQn       => acsi_drqn,
        ACSI_INTn       => acsi_intn,
        FDD_DCHGn       => fdd_dchgn,
        FDD_SDSELn      => fdd_sdseln,
        FDD_HD_DD       => fdd_hd_dd,
        FDD_RDn         => fdd_rdn,
        FDD_TRACK00     => fdd_track00,
        FDD_INDEXn      => fdd_indexn,
        FDD_WPn         => fdd_wpn,
        FDD_MOT_ON      => fdd_mot_on,
        FDD_WR_GATE     => fdd_wr_gate,
        FDD_WDn         => fdd_wdn,
        FDD_STEP        => fdd_step,
        FDD_STEP_DIR    => fdd_step_dir,
        ROM4n           => rom4n,
        ROM3n           => rom3n,
        RP_UDSn         => rp_udsn,
        RP_ldsn         => rp_ldsn,
        SD_CLK          => sd_clk,
        SD_D3           => sd_d3,
        SD_CMD_D1       => sd_cmd_d1,
        SD_D0           => sd_d0,
        SD_D1           => sd_d1,
        SD_D2           => sd_d2,
        SD_caRD_DETECT  => sd_card_detect,
        SD_WP           => sd_wp,
        CF_WP           => cf_wp,
        CF_CSn          => cf_csn,
        DSP_IO          => dsp_io,
        DSP_SRD         => dsp_srd,
        DSP_SRCSn       => dsp_srcsn,
        DSP_SRBLEn      => dsp_srblen,
        DSP_SRBHEn      => dsp_srbhen,
        DSP_SRWEn       => dsp_srwen,
        DSP_SROEn       => dsp_sroen,
        ide_int         => ide_int,
        ide_rdy         => ide_rdy,
        ide_res         => ide_res,
        IDE_WRn         => ide_wrn,
        IDE_RDn         => ide_rdn,
        IDE_CSn         => ide_csn
    );
    
    I_DDR_1 : ddr_ram_model
    PORT MAP
    (
        clk             => clk_ddr_out,
        clkb            => clk_ddr_out_n,
        cke             => vcke,
        csb             => vcs_n,
        rasb            => vras_n,
        casb            => vcas_n,
        web             => vwe_n,
        ba              => UNSIGNED(ba),
        ad              => va (12 DOWNTO 0),
        dqi             => vd (30 DOWNTO 15),
        dm              => UNSIGNED(vdm (3 DOWNTO 2)),
        dqs             => vd_qs (3 DOWNTO 2)
    );
    
    rsto_mcf_n <= '1' AFTER 1 ns;
    
    p_main_clk : PROCESS
    BEGIN
        WAIT FOR 30.03 ns;
        clk_main <= NOT clk_main;
    END PROCESS;
    
    stimulate_33mHz_clock : PROCESS
    BEGIN
        WAIT FOR 30.3 ns;
        clk_33m <= NOT clk_33m;
    END PROCESS;
    
    stimulate_bus : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_main);
        fb_ad <= STD_LOGIC_VECTOR (a);      -- put something (rather meaningless) on the FlexBus
        a <= a + 1;
        fb_ale <= a(0);                     -- just toggle for now
    END PROCESS;
END beh;