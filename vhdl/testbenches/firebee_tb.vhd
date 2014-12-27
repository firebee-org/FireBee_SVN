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
            rsto_mcf_n          : IN std_logic;                -- reset SIGNAL from Coldfire
            clk_33m             : IN std_logic;                -- 33 MHz clock
            clk_main            : IN std_logic;                -- 33 MHz clock
    
            clk_24m576          : OUT std_logic;            -- 
            clk_25m             : OUT std_logic;
            clk_ddr_out         : OUT std_logic;
            clk_ddr_out_n       : OUT std_logic;
            clk_usb             : OUT std_logic;
    
            fb_ad               : INOUT std_logic_vector (31 DOWNTO 0);
            fb_ale              : IN std_logic;
            fb_burst_n          : IN std_logic;
            fb_cs_n             : IN std_logic_vector (3 DOWNTO 1);
            fb_size             : IN std_logic_vector (1 DOWNTO 0);
            fb_oe_n             : IN std_logic;
            fb_wr_n             : IN std_logic;
            fb_ta_n             : OUT std_logic;
            
            dack1_n             : IN std_logic;
            dreq1_n             : OUT std_logic;
    
            master_n            : IN std_logic; -- determines if the Firebee is PCI master (='0') OR slave. Not used so far.
            tout0_n             : IN std_logic; -- Not used so far.
    
            led_fpga_ok         : OUT std_logic;
            reserved_1          : OUT std_logic;
    
            va                  : OUT std_logic_vector (12 DOWNTO 0);
            ba                  : OUT std_logic_vector (1 DOWNTO 0);
            vwe_n               : OUT std_logic;
            vcas_n              : OUT std_logic;
            vras_n              : OUT std_logic;
            vcs_n               : OUT std_logic;
    
            clk_pixel           : OUT std_logic;
            sync_n              : OUT std_logic;
            vsync               : OUT std_logic;
            hsync               : OUT std_logic;
            blank_n             : OUT std_logic;
            
            vr                  : OUT std_logic_vector (7 DOWNTO 0);
            vg                  : OUT std_logic_vector (7 DOWNTO 0);
            vb                  : OUT std_logic_vector (7 DOWNTO 0);
    
            vdm                 : OUT std_logic_vector (3 DOWNTO 0);
    
            vd                  : INOUT std_logic_vector (31 DOWNTO 0);
            vd_qs               : OUT std_logic_vector (3 DOWNTO 0);
    
            pd_vga_n            : OUT std_logic;
            vcke                : OUT std_logic;
            pic_int             : IN std_logic;
            e0_int              : IN std_logic;
            dvi_int             : IN std_logic;
            pci_inta_n          : IN std_logic;
            pci_intb_n          : IN std_logic;
            pci_intc_n          : IN std_logic;
            pci_intd_n          : IN std_logic;
    
            irq_n               : OUT std_logic_vector (7 DOWNTO 2);
            tin0                : OUT std_logic;
    
            ym_qa               : OUT std_logic;
            ym_qb               : OUT std_logic;
            ym_qc               : OUT std_logic;
    
            lp_d                : INOUT std_logic_vector (7 DOWNTO 0);
            lp_dir              : OUT std_logic;
    
            dsa_d               : OUT std_logic;
            lp_str              : OUT std_logic;
            dtr                 : OUT std_logic;
            rts                 : OUT std_logic;
            cts                 : IN std_logic;
            ri                  : IN std_logic;
            dcd                 : IN std_logic;
            lp_busy             : IN std_logic;
            rxd                 : IN std_logic;
            txd                 : OUT std_logic;
            midi_in             : IN std_logic;
            midi_olr            : OUT std_logic;
            midi_tlr            : OUT std_logic;
            pic_amkb_rx         : IN std_logic;
            amkb_rx             : IN std_logic;
            amkb_tx             : OUT std_logic;
            dack0_n             : IN std_logic; -- Not used.
            
            scsi_drqn           : IN std_logic;
            SCSI_MSGn           : IN std_logic;
            SCSI_CDn            : IN std_logic;
            SCSI_IOn            : IN std_logic;
            SCSI_ACKn           : OUT std_logic;
            SCSI_ATNn           : OUT std_logic;
            SCSI_SELn           : INOUT std_logic;
            SCSI_BUSYn          : INOUT std_logic;
            SCSI_RSTn           : INOUT std_logic;
            SCSI_DIR            : OUT std_logic;
            SCSI_D              : INOUT std_logic_vector (7 DOWNTO 0);
            SCSI_PAR            : INOUT std_logic;
    
            ACSI_DIR            : OUT std_logic;
            ACSI_D              : INOUT std_logic_vector (7 DOWNTO 0);
            ACSI_CSn            : OUT std_logic;
            ACSI_A1             : OUT std_logic;
            ACSI_reset_n        : OUT std_logic;
            ACSI_ACKn           : OUT std_logic;
            ACSI_DRQn           : IN std_logic;
            ACSI_INTn           : IN std_logic;
    
            FDD_DCHGn           : IN std_logic;
            FDD_SDSELn          : OUT std_logic;
            FDD_HD_DD           : IN std_logic;
            FDD_RDn             : IN std_logic;
            FDD_TRACK00         : IN std_logic;
            FDD_INDEXn          : IN std_logic;
            FDD_WPn             : IN std_logic;
            FDD_MOT_ON          : OUT std_logic;
            FDD_WR_GATE         : OUT std_logic;
            FDD_WDn             : OUT std_logic;
            FDD_STEP            : OUT std_logic;
            FDD_STEP_DIR        : OUT std_logic;
    
            ROM4n               : OUT std_logic;
            ROM3n               : OUT std_logic;
    
            RP_UDSn             : OUT std_logic;
            RP_ldsn             : OUT std_logic;
            SD_CLK              : OUT std_logic;
            SD_D3               : INOUT std_logic;
            SD_CMD_D1           : INOUT std_logic;
            SD_D0               : IN std_logic;
            SD_D1               : IN std_logic;
            SD_D2               : IN std_logic;
            SD_caRD_DETECT      : IN std_logic;
            SD_WP               : IN std_logic;
    
            CF_WP               : IN std_logic;
            CF_CSn              : OUT std_logic_vector (1 DOWNTO 0);
    
            DSP_IO              : INOUT std_logic_vector (17 DOWNTO 0);
            DSP_SRD             : INOUT std_logic_vector (15 DOWNTO 0);
            DSP_SRCSn           : OUT std_logic;
            DSP_SRBLEn          : OUT std_logic;
            DSP_SRBHEn          : OUT std_logic;
            DSP_SRWEn           : OUT std_logic;
            DSP_SROEn           : OUT std_logic;
    
            ide_int             : IN std_logic;
            ide_rdy             : IN std_logic;
            ide_res             : OUT std_logic;
            IDE_WRn             : OUT std_logic;
            IDE_RDn             : OUT std_logic;
            IDE_CSn             : OUT std_logic_vector (1 DOWNTO 0)
        );
    END COMPONENT firebee;
    
    SIGNAL rsto_mcf_n       : std_logic := '0';                -- reset SIGNAL from Coldfire
    SIGNAL clk_33m          : std_logic := '0';                -- 33 MHz clock
    SIGNAL clk_main         : std_logic := '0';                -- 33 MHz clock
    
    SIGNAL clk_24m576       : std_logic;            -- 
    SIGNAL clk_25m          : std_logic;
    SIGNAL clk_ddr_out      : std_logic;
    SIGNAL clk_ddr_out_n    : std_logic;
    SIGNAL clk_usb          : std_logic;
    
    SIGNAL fb_ad            : std_logic_vector (31 DOWNTO 0);
    SIGNAL fb_ale           : std_logic;
    SIGNAL fb_burst_n       : std_logic := '1';
    SIGNAL fb_cs_n          : std_logic_vector (3 DOWNTO 1) := "111";
    SIGNAL fb_size          : std_logic_vector (1 DOWNTO 0) := "00";
    SIGNAL fb_oe_n          : std_logic := '1';
    SIGNAL fb_wr_n          : std_logic := '1';
    SIGNAL fb_ta_n          : std_logic := '1';
            
    SIGNAL dack1_n          : std_logic;
    SIGNAL dreq1_n          : std_logic;
    
    SIGNAL master_n         : std_logic := '0'; -- determines if the Firebee is PCI master (='0') OR slave. Not used so far.
    SIGNAL tout0_n          : std_logic; -- Not used so far.
    
    SIGNAL led_fpga_ok      : std_logic;
    SIGNAL reserved_1       : std_logic;
    
    SIGNAL va               : std_logic_vector (12 DOWNTO 0);
    SIGNAL ba               : std_logic_vector (1 DOWNTO 0);
    SIGNAL vwe_n            : std_logic;
    SIGNAL vcas_n           : std_logic;
    SIGNAL vras_n           : std_logic;
    SIGNAL vcs_n            : std_logic;
    
    SIGNAL clk_pixel        : std_logic;
    SIGNAL sync_n           : std_logic;
    SIGNAL vsync            : std_logic;
    SIGNAL hsync            : std_logic;
    SIGNAL blank_n          : std_logic;
            
    SIGNAL vr               : std_logic_vector (7 DOWNTO 0);
    SIGNAL vg               : std_logic_vector (7 DOWNTO 0);
    SIGNAL vb               : std_logic_vector (7 DOWNTO 0);
    
    SIGNAL vdm              : std_logic_vector (3 DOWNTO 0);
    
    SIGNAL vd               : std_logic_vector (31 DOWNTO 0);
    SIGNAL vd_qs            : std_logic_vector (3 DOWNTO 0);
    
    SIGNAL pd_vga_n         : std_logic;
    SIGNAL vcke             : std_logic;
    SIGNAL pic_int          : std_logic;
    SIGNAL e0_int           : std_logic;
    SIGNAL dvi_int          : std_logic;
    SIGNAL pci_inta_n       : std_logic;
    SIGNAL pci_intb_n       : std_logic;
    SIGNAL pci_intc_n       : std_logic;
    SIGNAL pci_intd_n       : std_logic;
    
    SIGNAL irq_n            : std_logic_vector (7 DOWNTO 2);
    SIGNAL tin0             : std_logic;
    
    SIGNAL ym_qa            : std_logic;
    SIGNAL ym_qb            : std_logic;
    SIGNAL ym_qc            : std_logic;
    
    SIGNAL lp_d             : std_logic_vector (7 DOWNTO 0);
    SIGNAL lp_dir           : std_logic;
    
    SIGNAL dsa_d            : std_logic;
    SIGNAL lp_str           : std_logic;
    SIGNAL dtr              : std_logic;
    SIGNAL rts              : std_logic;
    SIGNAL cts              : std_logic;
    SIGNAL ri               : std_logic;
    SIGNAL dcd              : std_logic;
    SIGNAL lp_busy          : std_logic;
    SIGNAL rxd              : std_logic;
    SIGNAL txd              : std_logic;
    SIGNAL midi_in          : std_logic;
    SIGNAL midi_olr         : std_logic;
    SIGNAL midi_tlr         : std_logic;
    SIGNAL pic_amkb_rx      : std_logic;
    SIGNAL amkb_rx          : std_logic;
    SIGNAL amkb_tx          : std_logic;
    SIGNAL dack0_n          : std_logic; -- Not used.
            
    SIGNAL scsi_drqn        : std_logic;
    SIGNAL SCSI_MSGn        : std_logic;
    SIGNAL SCSI_CDn         : std_logic;
    SIGNAL SCSI_IOn         : std_logic;
    SIGNAL SCSI_ACKn        : std_logic;
    SIGNAL SCSI_ATNn        : std_logic;
    SIGNAL SCSI_SELn        : std_logic;
    SIGNAL SCSI_BUSYn       : std_logic;
    SIGNAL SCSI_RSTn        : std_logic;
    SIGNAL SCSI_DIR         : std_logic;
    SIGNAL SCSI_D           : std_logic_vector (7 DOWNTO 0);
    SIGNAL SCSI_PAR         : std_logic;
    
    SIGNAL ACSI_DIR         : std_logic;
    SIGNAL ACSI_D           : std_logic_vector (7 DOWNTO 0);
    SIGNAL ACSI_CSn         : std_logic;
    SIGNAL ACSI_A1          : std_logic;
    SIGNAL ACSI_reset_n     : std_logic;
    SIGNAL ACSI_ACKn        : std_logic;
    SIGNAL ACSI_DRQn        : std_logic;
    SIGNAL ACSI_INTn        : std_logic;
    
    SIGNAL FDD_DCHGn        : std_logic;
    SIGNAL FDD_SDSELn       : std_logic;
    SIGNAL FDD_HD_DD        : std_logic;
    SIGNAL FDD_RDn          : std_logic;
    SIGNAL FDD_TRACK00      : std_logic;
    SIGNAL FDD_INDEXn       : std_logic;
    SIGNAL FDD_WPn          : std_logic;
    SIGNAL FDD_MOT_ON       : std_logic;
    SIGNAL FDD_WR_GATE      : std_logic;
    SIGNAL FDD_WDn          : std_logic;
    SIGNAL FDD_STEP         : std_logic;
    SIGNAL FDD_STEP_DIR     : std_logic;
    
    SIGNAL ROM4n            : std_logic;
    SIGNAL ROM3n            : std_logic;
    
    SIGNAL RP_UDSn          : std_logic;
    SIGNAL RP_ldsn          : std_logic;
    SIGNAL SD_CLK           : std_logic;
    SIGNAL SD_D3            : std_logic;
    SIGNAL SD_CMD_D1        : std_logic;
    SIGNAL SD_D0            : std_logic;
    SIGNAL SD_D1            : std_logic;
    SIGNAL SD_D2            : std_logic;
    SIGNAL SD_caRD_DETECT   : std_logic;
    SIGNAL SD_WP            : std_logic;
    
    SIGNAL CF_WP            : std_logic;
    SIGNAL CF_CSn           : std_logic_vector (1 DOWNTO 0);
    
    SIGNAL DSP_IO           : std_logic_vector (17 DOWNTO 0);
    SIGNAL DSP_SRD          : std_logic_vector (15 DOWNTO 0);
    SIGNAL DSP_SRCSn        : std_logic;
    SIGNAL DSP_SRBLEn       : std_logic;
    SIGNAL DSP_SRBHEn       : std_logic;
    SIGNAL DSP_SRWEn        : std_logic;
    SIGNAL DSP_SROEn        : std_logic;
    
    SIGNAL ide_int          : std_logic;
    SIGNAL ide_rdy          : std_logic;
    SIGNAL ide_res          : std_logic;
    SIGNAL IDE_WRn          : std_logic;
    SIGNAL IDE_RDn          : std_logic;
    SIGNAL IDE_CSn          : std_logic_vector (1 DOWNTO 0);
    
    SIGNAL a                : unsigned (31 DOWNTO 0) := (OTHERS => '0');

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
        ba              => unsigned(ba),
        ad              => va (12 DOWNTO 0),
        dqi             => vd (30 DOWNTO 15),
        dm              => unsigned(vdm (3 DOWNTO 2)),
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
        fb_ad <= std_logic_vector (a);      -- put something (rather meaningless) on the FlexBus
        a <= a + 1;
        fb_ale <= a(0);                     -- just toggle for now
    END PROCESS;
END beh;