----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the toplevel of the 'Firebee'      ----
---- computer. It is optimized for the use of an Altera Cyclone   ----
---- FPGA (EP3C40F484). This IP-Core is based on the first edi-   ----
---- tion of the Firebee configware originally provided by Fredi  ----
---- Aschwanden  and Wolfgang Förster. This release is in compa-  ----
---- rision to the first edition completely written in VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Wolfgang Förster                          ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/OR modify it under the terms of the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 of the License, or (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program is distributed in the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; WITHOUT even the implied   ----
---- warranty of MERCHANTABILITY OR FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License fOR mORe        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along with this program; If not, write to the Free   ----
---- Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision HistORy
-- 
-- Revision 2K12B  20120801 WF
--   Initial Release of the second edition, the most imPORTant changes are listed below.
--     Structural wORk:
--       Replaced the graphical top level by a VHDL model.
--       The new toplevel is now FIREBEE_V1.
--       Replaced the graphical Video Top Level by a VHDL model
--       The DDR_CTR is now DDR_CTRL.
--       Rewritten the DDR_CTR IN VHDL.
--       Moved the DDR_CTRL to the FIREBEE_V1 top level.
--       Moved the BLITTER to the FIREBEE_V1 top level.
--       Removed the VIDEO_MOD_MUX_CLUTCTR.
--       Extracted from the AHDL code of MOD_MUX_CLUTCTR the new VIDEO_CTRL.
--       VIDEO_CTRL is now written IN VHDL.
--       Removed the FalconIO_SDCard_IDE_CF.
--       Moved the keyboard ACIA from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the MIDI ACIA from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the soundchip module from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the multi function PORT (MFP) from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the floppy disk controller (FDC) from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Moved the SCSI controller from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Extracted a DMA logic from FalconIO_SDCard_IDE_CF which is now located IN the FIREBEE_V1 top level.
--       Extracted a IDE_CF_SD_ROM logic from FalconIO_SDCard_IDE_CF which is now located IN the FIREBEE_V1 top level.
--       Moved the PADDLE logic from FalconIO_SDCard_IDE_CF to the FIREBEE_V1 top level.
--       Rewritten the INterrupt handler IN VHDL.
--       Extracted the real time clock (RTC) logic from the INterrupt handler (VHDL).
--       The RTC is now located IN the FIREBEE_V1 top level.
--     Several code cleanups:
--       Resolved the tri state logic IN all modules. The only tri states are now IN the
--         top level FIREBEE_V1.
--       Replaced several Altera lpm modules to achieve a manufacturer independant code.
--         However we have still some modules like memory OR FIFOs which are required up to now.
--       Removed the vdr latch.
--       Removed the AMKBD filter.
--       Updated all Suska-Codes (ACIA, MFP, 5380, 1772, 2149) to the latest code base.
--       The sound module works now on the positive clock edge.
--       The multi function port works now on the positive clock edge.
--     Naming conventions:
--       Replaced the 'n' prefixes WITH 'n' postfixes to achieve consistent signal names.
--       Replaced the old ACP_xx signal names by FBEE_xx (ACP is the old working title).
--     Improvements (hopefully)
--         Fixed the video_reconfig strobe logic IN the video control section.
--     Others:
--       Provided file headers to all Firebee relevant design units.
--       Provided a timequest constraint file.
--       Switched all code elements to English language.
--       Provided a complete new file structure for the project.
--

LIBRARY work;
    USE work.firebee_pkg.ALL;

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY firebee IS
    PORT(
        rsto_mcf_n           : IN STD_LOGIC;                -- reset SIGNAL from Coldfire
        clk_33m             : IN STD_LOGIC;                -- 33 MHz clock
        clk_main            : IN STD_LOGIC;                -- 33 MHz clock

        clk_24m576          : OUT STD_LOGIC;            -- 
        clk_25m             : OUT STD_LOGIC;
        clk_ddr_out         : OUT STD_LOGIC;
        clk_ddr_out_n       : OUT STD_LOGIC;
        clk_usb             : OUT STD_LOGIC;

        fb_ad               : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        fb_ale              : IN STD_LOGIC;
        fb_burst_n           : IN STD_LOGIC;
        fb_cs_n              : IN STD_LOGIC_VECTOR (3 DOWNTO 1);
        fb_size             : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        fb_oe_n              : IN STD_LOGIC;
        fb_wr_n             : IN STD_LOGIC;
        fb_ta_n              : OUT STD_LOGIC;
        
        dack1_n              : IN STD_LOGIC;
        dreq1_n              : OUT STD_LOGIC;

        master_n             : IN STD_LOGIC; -- determines if the Firebee is PCI master (='0') OR slave. Not used so far.
        tout0_n              : IN STD_LOGIC; -- Not used so far.

        led_fpga_ok         : OUT STD_LOGIC;
        reserved_1          : OUT STD_LOGIC;

        va                  : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        ba                  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        vwe_n                : OUT STD_LOGIC;
        vcas_n              : OUT STD_LOGIC;
        vras_n              : OUT STD_LOGIC;
        vcs_n                : OUT STD_LOGIC;

        clk_pixel           : OUT STD_LOGIC;
        sync_n               : OUT STD_LOGIC;
        vsync               : OUT STD_LOGIC;
        hsync               : OUT STD_LOGIC;
        blank_n              : OUT STD_LOGIC;
        
        vr                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        vg                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        vb                  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

        vdm                 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        vd                  : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        vd_qs               : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        pd_vga_n             : OUT STD_LOGIC;
        vcke                : OUT STD_LOGIC;
        pic_int             : IN STD_LOGIC;
        e0_int              : IN STD_LOGIC;
        dvi_int             : IN STD_LOGIC;
        pci_inta_n           : IN STD_LOGIC;
        pci_intb_n           : IN STD_LOGIC;
        pci_intc_n           : IN STD_LOGIC;
        pci_intd_n           : IN STD_LOGIC;

        irq_n                : OUT STD_LOGIC_VECTOR (7 DOWNTO 2);
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
        dack0_n              : IN STD_LOGIC; -- Not used.
        
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
        ACSI_reset_n         : OUT STD_LOGIC;
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
END ENTITY firebee;

ARCHITECTURE Structure of firebee is
    COMPONENT altpll1
        PORT(
            inclk0      : IN STD_LOGIC  := '0';
            c0          : OUT STD_LOGIC ;
            c1          : OUT STD_LOGIC ;
            c2          : OUT STD_LOGIC ;
            locked      : OUT STD_LOGIC 
        );
    END COMPONENT;

    COMPONENT altpll2
        PORT(
            inclk0      : IN STD_LOGIC  := '0';
            c0          : OUT STD_LOGIC ;
            c1          : OUT STD_LOGIC ;
            c2          : OUT STD_LOGIC ;
            c3          : OUT STD_LOGIC ;
            c4          : OUT STD_LOGIC 
        );
    END COMPONENT;

    COMPONENT altpll3
        PORT(
            inclk0      : IN STD_LOGIC  := '0';
            c0          : OUT STD_LOGIC;
            c1          : OUT STD_LOGIC;
            c2          : OUT STD_LOGIC;
            c3          : OUT STD_LOGIC 
        );
    END COMPONENT;

    COMPONENT altpll4
        PORT(
            areset          : IN STD_LOGIC  := '0';
            configupdate    : IN STD_LOGIC  := '0';
            inclk0          : IN STD_LOGIC  := '0';
            scanclk         : IN STD_LOGIC  := '1';
            scanclkena      : IN STD_LOGIC  := '0';
            scandata        : IN STD_LOGIC  := '0';
            c0              : OUT STD_LOGIC;
            locked          : OUT STD_LOGIC;
            scandataOUT     : OUT STD_LOGIC;
            scandone        : OUT STD_LOGIC 
        );
    END COMPONENT;

    COMPONENT altpll_reconfig1
        PORT( 
            busy                : OUT STD_LOGIC;
            clock               : IN STD_LOGIC;
            counter_param       : IN STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
            counter_type        : IN STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
            data_in             : IN STD_LOGIC_VECTOR (8 DOWNTO 0) := (OTHERS => '0');
            data_out            : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
            pll_areset          : OUT STD_LOGIC;
            pll_areset_in       : IN STD_LOGIC := '0';
            pll_configupdate    : OUT STD_LOGIC;
            pll_scanclk         : OUT STD_LOGIC;
            pll_scanclkena      : OUT STD_LOGIC;
            pll_scandata        : OUT STD_LOGIC;
            pll_scandataout     : IN STD_LOGIC := '0';
            pll_scandone        : IN STD_LOGIC := '0';
            read_param          : IN STD_LOGIC := '0';
            reconfig            : IN STD_LOGIC := '0';
            reset               : IN STD_LOGIC;
            write_param         : IN STD_LOGIC := '0'
        ); 
    END COMPONENT;

    SIGNAL acia_cs              : STD_LOGIC;
    SIGNAL acia_irq_n           : STD_LOGIC;
    SIGNAL acsi_d_out           : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL acsi_d_en            : STD_LOGIC;
    SIGNAL blank_i_n            : STD_LOGIC;
    SIGNAL blitter_adr          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL blitter_dack_sr      : STD_LOGIC;
    SIGNAL blitter_dout         : STD_LOGIC_VECTOR (127 DOWNTO 0);
    SIGNAL blitter_on           : STD_LOGIC;
    SIGNAL blitter_run          : STD_LOGIC;
    SIGNAL blitter_sig          : STD_LOGIC;
    SIGNAL blitter_ta           : STD_LOGIC;
    SIGNAL blitter_wr           : STD_LOGIC;
    SIGNAL byte                 : STD_LOGIC; -- When Byte -> 1
    SIGNAL ca                   : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL clk_2m0              : STD_LOGIC;
    SIGNAL clk_2m4576           : STD_LOGIC;
    SIGNAL clk_25m_i            : STD_LOGIC;
    SIGNAL clk_48m              : STD_LOGIC;
    SIGNAL clk_500k             : STD_LOGIC;
    SIGNAL clk_ddr              : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL clk_fdc              : STD_LOGIC;
    SIGNAL clk_pixel_i          : STD_LOGIC;
    SIGNAL clk_video            : STD_LOGIC;
    SIGNAL da_out_x             : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_en_blitter      : STD_LOGIC;
    SIGNAL data_en_h_ddr_ctrl   : STD_LOGIC;
    SIGNAL data_en_l_ddr_ctrl   : STD_LOGIC;
    SIGNAL data_in_fdc_scsi     : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_out_acia_i      : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_out_acia_iI     : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_out_blitter     : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL data_out_ddr_ctrl    : STD_LOGIC_VECTOR (31 DOWNTO 16);
    SIGNAL data_out_fdc         : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_out_mfp         : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL data_out_scsi        : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL dint_n               : STD_LOGIC;
    SIGNAL ddr_d_in_n           : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ddr_fb               : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL ddr_sync_66m         : STD_LOGIC;
    SIGNAL ddr_wr               : STD_LOGIC;
    SIGNAL ddrwr_d_sel          : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL dma_cs               : STD_LOGIC;
    SIGNAL drq11_dma            : STD_LOGIC;
    SIGNAL drq_fdc              : STD_LOGIC;
    SIGNAL drq_dma              : STD_LOGIC;
    SIGNAL dsp_int              : STD_LOGIC;
    SIGNAL dsp_io_en            : STD_LOGIC;
    SIGNAL dsp_io_out           : STD_LOGIC_VECTOR (17 DOWNTO 0);
    SIGNAL dsp_srd_en           : STD_LOGIC;
    SIGNAL dsp_srd_out          : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL dsp_ta               : STD_LOGIC;
    SIGNAL dtack_out_mfp_n      : STD_LOGIC;
    SIGNAL falcon_io_ta         : STD_LOGIC;

    SIGNAL fb_ad_en_15_0_video  : STD_LOGIC;
    SIGNAL fb_ad_en_31_16_video : STD_LOGIC;
    SIGNAL fb_ad_en_7_0_dma     : STD_LOGIC;
    SIGNAL fb_ad_en_7_0_ih      : STD_LOGIC;
    SIGNAL fb_ad_en_15_8_dma    : STD_LOGIC;
    SIGNAL fb_ad_en_15_8_ih     : STD_LOGIC;
    SIGNAL fb_ad_en_23_16_dma   : STD_LOGIC;
    SIGNAL fb_ad_en_23_16_ih    : STD_LOGIC;
    SIGNAL fb_ad_en_31_24_dma   : STD_LOGIC;
    SIGNAL fb_ad_en_31_24_ih    : STD_LOGIC;

    SIGNAL fb_ad_en_dsp         : STD_LOGIC;
    SIGNAL fb_ad_en_rtc         : STD_LOGIC;
    SIGNAL fb_ad_out_dma        : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_ad_out_dsp        : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_ad_out_ih         : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_ad_out_rtc        : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL fb_ad_out_video      : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_adr               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fb_b0                : STD_LOGIC; -- UPPER Byte BEI 16 STD_LOGIC BUS
    SIGNAL fb_b1                : STD_LOGIC; -- LOWER Byte BEI 16 STD_LOGIC BUS
    SIGNAL fb_ddr               : STD_LOGIC_VECTOR (127 DOWNTO 0);
    SIGNAL fb_le                : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL fb_vdoe              : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL fbee_conf            : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fd_int               : STD_LOGIC;
    SIGNAL fdc_cs_n             : STD_LOGIC;
    SIGNAL fdc_wr_n             : STD_LOGIC;
    SIGNAL fifo_clr             : STD_LOGIC;
    SIGNAL fifo_mw              : UNSIGNED (8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL hd_dd_out            : STD_LOGIC;
    SIGNAL hsync_i              : STD_LOGIC;
    SIGNAL ide_cf_ta            : STD_LOGIC;
    SIGNAL ide_res_i            : STD_LOGIC;
    SIGNAL int_handler_ta       : STD_LOGIC;
    SIGNAL irq_keybd_n          : STD_LOGIC;
    SIGNAL irq_midi_n           : STD_LOGIC;
    SIGNAL keyb_rxd             : STD_LOGIC;
    SIGNAL lds                  : STD_LOGIC;
    SIGNAL locked               : STD_LOGIC;
    SIGNAL lp_d_x               : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL lp_dir_x             : STD_LOGIC;
    SIGNAL mfp_cs               : STD_LOGIC;
    SIGNAL mfp_intack           : STD_LOGIC;
    SIGNAL mfp_int_n            : STD_LOGIC;
    SIGNAL midi_out             : STD_LOGIC;
    SIGNAL paddle_cs            : STD_LOGIC;
    SIGNAL pll_areset           : STD_LOGIC;
    SIGNAL pll_scanclk          : STD_LOGIC;
    SIGNAL pll_scandata         : STD_LOGIC;
    SIGNAL pll_scanclkena       : STD_LOGIC;
    SIGNAL pll_configupdate     : STD_LOGIC;
    SIGNAL pll_scandone         : STD_LOGIC;
    SIGNAL pll_scandataout      : STD_LOGIC;
    SIGNAL reset_n              : STD_LOGIC;
    SIGNAL scsi_bsy_en          : STD_LOGIC;
    SIGNAL scsi_bsy_out_n       : STD_LOGIC;
    SIGNAL scsi_cs              : STD_LOGIC;
    SIGNAL scsi_csn             : STD_LOGIC;
    SIGNAL scsi_d_en            : STD_LOGIC;
    SIGNAL scsi_dack_n          : STD_LOGIC;
    SIGNAL scsi_dbp_en          : STD_LOGIC;
    SIGNAL scsi_dbp_out_n       : STD_LOGIC;
    SIGNAL scsi_drq             : STD_LOGIC;
    SIGNAL scsi_int             : STD_LOGIC;
    SIGNAL scsi_d_out_n         : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL scsi_rst_en          : STD_LOGIC;
    SIGNAL scsi_rst_out_n       : STD_LOGIC;
    SIGNAL scsi_sel_en          : STD_LOGIC;
    SIGNAL scsi_sel_out_n        : STD_LOGIC;
    SIGNAL sd_cd_d3_en          : STD_LOGIC;
    SIGNAL sd_cd_d3_out         : STD_LOGIC;
    SIGNAL sd_cmd_d1_en         : STD_LOGIC;
    SIGNAL sd_cmd_d1_out        : STD_LOGIC;

    SIGNAL sndcs                : STD_LOGIC;
    SIGNAL sndcs_i              : STD_LOGIC;
    SIGNAL sndir_i              : STD_LOGIC;
    SIGNAL sr_ddr_fb            : STD_LOGIC;
    SIGNAL sr_ddr_wr            : STD_LOGIC;
    SIGNAL sr_ddrwr_d_sel       : STD_LOGIC;
    SIGNAL sr_fifo_wre          : STD_LOGIC;
    SIGNAL sr_vdmp              : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tdo                  : STD_LOGIC;
    SIGNAL timebase             : UNSIGNED (17 DOWNTO 0);
    SIGNAL vd_en                : STD_LOGIC;
    SIGNAL vd_en_i              : STD_LOGIC;
    SIGNAL vd_out               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL vd_qs_en             : STD_LOGIC;
    SIGNAL vd_qs_out            : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL vd_vz                : STD_LOGIC_VECTOR (127 DOWNTO 0);
    SIGNAL vdm_sel              : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL vdp_in               : STD_LOGIC_VECTOR (63 DOWNTO 0);
    SIGNAL vdp_out              : STD_LOGIC_VECTOR (63 DOWNTO 0);
    SIGNAL vdp_q1               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL vdp_q2               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL vdp_q3               : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL vdr                  : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL video_ddr_ta         : STD_LOGIC;
    SIGNAL video_mod_ta         : STD_LOGIC;
    SIGNAL video_ram_ctr        : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL video_reconfig       : STD_LOGIC;
    SIGNAL vr_busy              : STD_LOGIC;
    SIGNAL vr_d                 : STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL vr_rd                : STD_LOGIC;
    SIGNAL vr_wr                : STD_LOGIC;
    SIGNAL vsync_i              : STD_LOGIC;
    SIGNAL wdc_bsl0             : STD_LOGIC;
    
BEGIN
    I_PLL1: altpll1
        PORT MAP(
            inclk0      => clk_main,
            c0          => clk_2m4576,              -- 2.4576 MHz
            c1          => clk_24m576,              -- 24.576 MHz
            c2          => clk_48m,                 -- 48 MHz
            locked      => locked
        );

    I_PLL2: altpll2
        PORT MAP(
            inclk0      => clk_main,
            c0          => clk_ddr(0),              -- 132 MHz / 240°
            c1          => clk_ddr(1),              -- 132 MHz / 0°
            c2          => clk_ddr(2),              -- 132 MHz / 180°
            c3          => clk_ddr(3),              -- 132 MHz / 105°
            c4          => ddr_sync_66m             -- 66 MHz / 270°
        );
    
    I_PLL3: altpll3
        PORT MAP(
            inclk0      => clk_main,
            c0          => clk_2m0,                 -- 2 MHz
            c1          => clk_fdc,                 -- 16 MHz
            c2          => clk_25m_i,               -- 25 MHz
            c3          => clk_500k                 -- 500 KHz
        );
    
    I_PLL4: altpll4
        PORT MAP(
            inclk0          => clk_main,
            areset          => pll_areset,
            scanclk         => pll_scanclk,
            scandata        => pll_scandata,
            scanclkena      => pll_scanclkena,
            configupdate    => pll_configupdate,
            c0              => clk_video,                   -- configurable video clk, set to 96 MHz initially
            scandataOUT     => pll_scandataout,
            scandone        => pll_scandone
            --locked        => -- Not used.
        );

    I_RECONFIG: altpll_reconfig1                            -- to enable reconfiguration of altpll4 (video clock)
        PORT MAP(
            reconfig            => video_reconfig,
            read_param          => vr_rd,
            write_param         => vr_wr,
            data_in             => fb_ad (24 DOWNTO 16),    -- FIXED: this looks like a typo. Must be fb_ad(24 DOWNTO 16) instead of fb_adr(24 DOWNTO 16)
            counter_type        => fb_adr (5 DOWNTO 2),
            counter_param       => fb_adr (8 DOWNTO 6),
            pll_scandataout     => pll_scandataout,
            pll_scandone        => pll_scandone,
            clock               => clk_main,
            reset               => NOT reset_n,
            pll_areset_in       => '0', -- Not used.
            busy                => vr_busy,
            data_out            => vr_d,
            pll_scandata        => pll_scandata,
            pll_scanclk         => pll_scanclk,
            pll_scanclkena      => pll_scanclkena,
            pll_configupdate    => pll_configupdate,
            pll_areset          => pll_areset
        );

    clk_25m <= clk_25m_i;
    clk_usb <= clk_48m;
    
    clk_ddr_out <= clk_ddr(0);
    clk_ddr_out_n <= NOT clk_ddr(0);
    
    clk_pixel <= clk_pixel_i;

    p_timebase: PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_500k);
        timebase <= timebase + 1;
    END PROCESS p_timebase;

    reset_n <= rsto_mcf_n and locked;
    ide_res <= NOT ide_res_i and reset_n;
    dreq1_n <= dack1_n;
    led_fpga_ok <= timebase(17);                                    -- won't work: doesn't seem to be connected

    falcon_io_ta <= acia_cs OR sndcs OR NOT dtack_out_mfp_n OR paddle_cs OR ide_cf_ta OR dma_cs;
    fb_ta_n <= '0' WHEN (blitter_ta OR video_ddr_ta OR video_mod_ta OR falcon_io_ta OR dsp_ta OR int_handler_ta) = '1' ELSE 'Z';

    acia_cs <= '1' WHEN fb_cs_n(1) = '0' and fb_adr(23 DOWNTO 3) & "000" = x"FFFC00" ELSE '0';           -- FFFC00 - FFFC07
    mfp_cs <= '1' WHEN fb_cs_n(1) = '0' and fb_adr(23 DOWNTO 6) & "000000" = x"FFFA00" ELSE '0';         -- FFFA00/40
    paddle_cs <= '1' WHEN fb_cs_n(1) = '0' and fb_adr(23 DOWNTO 6) & "000000"= x"FF9200" ELSE '0';       -- FF9200-FF923F
    sndcs <= '1' WHEN fb_cs_n(1) = '0' and fb_adr(23 DOWNTO 2) & "00" = x"FF8800" ELSE '0';              -- FF8800-FF8803
    sndcs_i <= '1' WHEN sndcs = '1' and fb_adr (1) = '0' ELSE '0';
    sndir_i <= '1' WHEN sndcs = '1' and fb_wr_n = '0' ELSE '0';

    lp_d <= lp_d_x WHEN lp_dir_x = '0' ELSE (OTHERS => 'Z');
    lp_dir <= lp_dir_x;
    
    ACSI_D <= acsi_d_out WHEN acsi_d_en = '1' ELSE (OTHERS => 'Z');

    SCSI_D <= scsi_d_out_n WHEN scsi_d_en = '1' ELSE (OTHERS => 'Z');
    SCSI_DIR <= '0' WHEN scsi_d_en = '1' ELSE '1';     
    SCSI_PAR <= scsi_dbp_out_n WHEN scsi_dbp_en = '1' ELSE 'Z';
    SCSI_RSTn <= scsi_rst_out_n WHEN scsi_rst_en = '1' ELSE 'Z';
    SCSI_BUSYn <= scsi_bsy_out_n WHEN scsi_bsy_en = '1' ELSE 'Z';
    SCSI_SELn <= scsi_sel_out_n WHEN scsi_sel_en = '1' ELSE 'Z';

    keyb_rxd <= '0' WHEN amkb_rx = '0' OR pic_amkb_rx = '0' ELSE '1';                                       -- get keyboard data either from PIC (PS/2) OR from Atari keyboard

    SD_D3 <= sd_cd_d3_out WHEN sd_cd_d3_en = '1' ELSE 'Z';
    SD_CMD_D1 <= sd_cmd_d1_out WHEN sd_cmd_d1_en = '1' ELSE 'Z';

    DSP_IO <= dsp_io_out WHEN dsp_io_en = '1' ELSE (OTHERS => 'Z');
    DSP_SRD <= dsp_srd_out WHEN dsp_srd_en = '1' ELSE (OTHERS => 'Z');
      
    hd_dd_out <= FDD_HD_DD WHEN fbee_conf(29) = '0' ELSE wdc_bsl0;
    lds <= '1' WHEN mfp_cs = '1' OR mfp_intack = '1' ELSE '0';
    acia_irq_n <= irq_keybd_n and irq_midi_n;
    mfp_intack <= '1' WHEN fb_cs_n(2) = '0' and fb_adr(19 DOWNTO 0) = x"20000" ELSE '0';                     --F002'0000
    dint_n <= '0' WHEN ide_int = '1' and fbee_conf(28) = '1' ELSE
                '0' WHEN fd_int = '1' ELSE
                '0' WHEN scsi_int = '1' and fbee_conf(28) = '1' ELSE '1';

    midi_tlr <= midi_out;
    midi_olr <= midi_out;

    byte <= '1' WHEN fb_size(1) = '0' and fb_size(0) = '1' ELSE '0';
    fb_b0 <= '1' WHEN fb_adr(0) = '0' OR byte = '0' ELSE '0';
    fb_b1 <= '1' WHEN fb_adr(0) = '1' OR byte = '0' ELSE '0';

    fb_ad(31 DOWNTO 24) <= data_out_blitter(31 DOWNTO 24) WHEN data_en_blitter = '1' ELSE
                                    vdp_q1(31 DOWNTO 24) WHEN fb_vdoe = x"2" ELSE
                                    vdp_q2(31 DOWNTO 24) WHEN fb_vdoe = x"4" ELSE
                                    vdp_q3(31 DOWNTO 24) WHEN fb_vdoe = x"8" ELSE
                                    fb_ad_out_video(31 DOWNTO 24) WHEN fb_ad_en_31_16_video = '1' ELSE
                                    fb_ad_out_dsp(31 DOWNTO 24) WHEN fb_ad_en_dsp = '1' ELSE
                                    fb_ad_out_ih(31 DOWNTO 24) WHEN fb_ad_en_31_24_ih = '1' ELSE
                                    fb_ad_out_dma(31 DOWNTO 24) WHEN fb_ad_en_31_24_dma = '1' ELSE
                                    vdr(31 DOWNTO 24) WHEN fb_vdoe = x"1" ELSE
                                    data_out_ddr_ctrl(31 DOWNTO 24) WHEN data_en_h_ddr_ctrl = '1' ELSE
                                    da_out_x WHEN sndcs_i = '1' and fb_oe_n = '0' ELSE
                                    x"00" WHEN mfp_intack = '1' and fb_oe_n = '0' ELSE
                                    data_out_acia_i  WHEN acia_cs = '1' and fb_adr(2) = '0' and fb_oe_n = '0' ELSE
                                    data_out_acia_iI WHEN acia_cs = '1' and fb_adr(2) = '1' and fb_oe_n = '0' ELSE
                                    x"BF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"0" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"1" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"8" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"9" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"A" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"B" and fb_oe_n = '0' ELSE
                                    x"00" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"10" and fb_oe_n = '0' ELSE
                                    x"00" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"11" and fb_oe_n = '0' ELSE (OTHERS => 'Z');

    fb_ad(23 DOWNTO 16) <= data_out_blitter(23 DOWNTO 16) WHEN data_en_blitter = '1' ELSE
                                    vdp_q1(23 DOWNTO 16) WHEN fb_vdoe = x"2" ELSE
                                    vdp_q2(23 DOWNTO 16) WHEN fb_vdoe = x"4" ELSE
                                    vdp_q3(23 DOWNTO 16) WHEN fb_vdoe = x"8" ELSE
                                    fb_ad_out_video(23 DOWNTO 16) WHEN fb_ad_en_31_16_video = '1' ELSE
                                    fb_ad_out_dsp(23 DOWNTO 16) WHEN fb_ad_en_dsp = '1' ELSE
                                    fb_ad_out_ih(23 DOWNTO 16) WHEN fb_ad_en_23_16_ih = '1' ELSE
                                    fb_ad_out_dma(23 DOWNTO 16) WHEN fb_ad_en_23_16_dma = '1' ELSE
                                    vdr(23 DOWNTO 16) WHEN fb_vdoe = x"1" ELSE
                                    data_out_ddr_ctrl(23 DOWNTO 16) WHEN data_en_l_ddr_ctrl = '1' ELSE
                                    data_out_mfp WHEN mfp_cs = '1' and fb_oe_n = '0' ELSE
                                    x"00" WHEN mfp_intack = '1' and fb_oe_n = '0' ELSE
                                    fb_ad_out_rtc WHEN fb_ad_en_rtc = '1' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"0" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"1" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"8" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"9" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"A" and fb_oe_n = '0' ELSE
                                    x"FF" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"B" and fb_oe_n = '0' ELSE
                                    x"00" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"10" and fb_oe_n = '0' ELSE
                                    x"00" WHEN paddle_cs = '1' and fb_adr(5 DOWNTO 1) = 5x"11" and fb_oe_n = '0' ELSE (OTHERS => 'Z');

    fb_ad(15 DOWNTO 8) <= data_out_blitter(15 DOWNTO 8) WHEN data_en_blitter = '1' ELSE
                                    vdp_q1(15 DOWNTO 8) WHEN fb_vdoe = x"2" ELSE
                                    vdp_q2(15 DOWNTO 8) WHEN fb_vdoe = x"4" ELSE
                                    vdp_q3(15 DOWNTO 8) WHEN fb_vdoe = x"8" ELSE
                                    fb_ad_out_video(15 DOWNTO 8) WHEN fb_ad_en_15_0_video = '1' ELSE
                                    fb_ad_out_dsp(15 DOWNTO 8) WHEN fb_ad_en_dsp = '1' ELSE
                                    fb_ad_out_ih(15 DOWNTO 8) WHEN fb_ad_en_15_8_ih = '1' ELSE
                                    fb_ad_out_dma(15 DOWNTO 8) WHEN fb_ad_en_15_8_dma = '1' ELSE
                                    vdr(15 DOWNTO 8) WHEN fb_vdoe = x"1" ELSE
                                    "000000" & data_out_mfp(7 DOWNTO 6) WHEN mfp_intack = '1' and fb_oe_n = '0' ELSE (OTHERS => 'Z');

    fb_ad(7 DOWNTO 0) <= data_out_blitter(7 DOWNTO 0) WHEN data_en_blitter = '1' ELSE
                                    vdp_q1(7 DOWNTO 0) WHEN fb_vdoe = x"2" ELSE
                                    vdp_q2(7 DOWNTO 0) WHEN fb_vdoe = x"4" ELSE
                                    vdp_q3(7 DOWNTO 0) WHEN fb_vdoe = x"8" ELSE
                                    fb_ad_out_video(7 DOWNTO 0) WHEN fb_ad_en_15_0_video = '1' ELSE
                                    fb_ad_out_dsp(7 DOWNTO 0) WHEN fb_ad_en_dsp = '1' ELSE
                                    fb_ad_out_ih(7 DOWNTO 0) WHEN fb_ad_en_7_0_ih = '1' ELSE
                                    fb_ad_out_dma(7 DOWNTO 0) WHEN fb_ad_en_7_0_dma = '1' ELSE
                                    vdr(7 DOWNTO 0) WHEN fb_vdoe = x"1" ELSE
                                    data_out_mfp(5 DOWNTO 0) & "00" WHEN mfp_intack = '1' and fb_oe_n = '0' ELSE (OTHERS => 'Z');

    synchronization : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ddr_sync_66m);
        IF fb_ale = '1' THEN
            fb_adr <= fb_ad;        -- latch Flexbus address
        END IF;
        --
        IF vd_en_i = '0' THEN
            vdr <= vd;
        ELSE
            vdr <= vd_out;
        END IF;
        --
        IF fb_le(0) = '1' THEN
            fb_ddr(127 DOWNTO 96) <= fb_ad;
        END IF;
        --
        IF fb_le(1) = '1' THEN
            fb_ddr(95 DOWNTO 64) <= fb_ad;
        END IF;
        --
        IF fb_le(2) = '1' THEN
            fb_ddr(63 DOWNTO 32) <= fb_ad;
        END IF;
        --
        IF fb_le(3) = '1' THEN
            fb_ddr(31 DOWNTO 0) <= fb_ad;
        END IF;
    END PROCESS synchronization;

    video_out : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_pixel_i);
        vsync <= vsync_i;
        hsync <= hsync_i;
        blank_n <= blank_i_n;
    END PROCESS video_out;

    p_ddr_wr: PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_ddr(3));
        ddr_wr <= sr_ddr_wr;
        ddrwr_d_sel(0) <= sr_ddrwr_d_sel;
    END PROCESS p_ddr_wr;

    vd_qs_en <= ddr_wr;
    vd <= vd_out WHEN vd_en = '1' ELSE (OTHERS => 'Z');

    vd_qs_out(0) <= clk_ddr(0);
    vd_qs_out(1) <= clk_ddr(0);
    vd_qs_out(2) <= clk_ddr(0);
    vd_qs_out(3) <= clk_ddr(0);
    vd_qs <= vd_qs_out WHEN vd_qs_en = '1' ELSE (OTHERS => 'Z');

    ddr_data_in_n : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_ddr(1));
        ddr_d_in_n <= vd;
    END PROCESS ddr_data_in_n;
    --
    ddr_data_in_p : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_ddr(1));
        vdp_in(31 DOWNTO 0) <= vd;
        vdp_in(63 DOWNTO 32) <= ddr_d_in_n;
    END PROCESS ddr_data_in_p;

    ddr_data_out_p : PROCESS(clk_ddr(3))
        variable DDR_D_OUT_H    : STD_LOGIC_VECTOR(31 DOWNTO 0);
        variable DDR_D_OUT_L    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    BEGIN
        IF clk_ddr(3) = '1' and clk_ddr(3)' event THEN
            DDR_D_OUT_H := vdp_out(63 DOWNTO 32);
            DDR_D_OUT_L := vdp_out(31 DOWNTO 0);
            vd_en <= sr_ddr_wr OR ddr_wr;
        END IF;
        --
        CASE clk_ddr(3) IS
            WHEN  '1' => vd_out <= DDR_D_OUT_H;
            WHEN OTHERS => vd_out <= DDR_D_OUT_L;
        END CASE;
    END PROCESS ddr_data_out_p;

    WITH ddrwr_d_sel SELECT
        vdp_out <= blitter_dout(63 DOWNTO 0) WHEN "11",
                        blitter_dout(127 DOWNTO 64) WHEN "10",
                        fb_ddr(63 DOWNTO 0) WHEN "01",
                        fb_ddr(127 DOWNTO 64) WHEN "00",
                        (OTHERS => 'Z') WHEN OTHERS;

    vd_en_i <= sr_ddr_wr OR ddr_wr;

    vdp_q_buffer : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_ddr(0));
        ddr_fb <= sr_ddr_fb & ddr_fb(4 DOWNTO 1);
        --
        IF ddr_fb(1) = '1' THEN
            vdp_q1 <= vdp_in(31 DOWNTO 0);
        END IF;
        --
        IF ddr_fb(0) = '1' THEN
            vdp_q2 <= vdp_in(63 DOWNTO 32);
            vdp_q3 <= vdp_in(31 DOWNTO 0);
        END IF;
    END PROCESS vdp_q_buffer;
 
    I_DDR_CTRL: DDR_CTRL
        PORT MAP(
            clk_main            => clk_main,
            ddr_sync_66m        => ddr_sync_66m,
            fb_adr              => fb_adr,
            fb_cs1_n            => fb_cs_n(1),
            fb_oe_n             => fb_oe_n,
            fb_size0            => fb_size(0),
            fb_size1            => fb_size(1),
            fb_ale              => fb_ale,
            fb_wr_n             => fb_wr_n,
            blitter_adr         => blitter_adr,
            blitter_sig         => blitter_sig,
            blitter_wr          => blitter_wr,
            SR_BLITTER_DACK     => blitter_dack_sr,
            ba                  => ba,
            va                  => va,
            fb_le               => fb_le,
            clk_33m             => clk_33m,
            vras_n              => vras_n,
            vcas_n              => vcas_n,
            vwe_n                => vwe_n,
            vcs_n                => vcs_n,
            fifo_clr            => fifo_clr,
            DDRCLK0             => clk_ddr(0),
            video_control_register => video_ram_ctr,
            vcke                => vcke,
            DATA_IN             => fb_ad,
            DATA_OUT            => data_out_ddr_ctrl,
            DATA_EN_H           => data_en_h_ddr_ctrl,
            DATA_EN_L           => data_en_l_ddr_ctrl,
            vdm_sel             => vdm_sel,
            fifo_mw             => fifo_mw,
            fb_vdoe             => fb_vdoe,
            sr_fifo_wre         => sr_fifo_wre,
            sr_ddr_fb           => sr_ddr_fb,
            sr_ddr_wr           => sr_ddr_wr,
            sr_ddrwr_d_sel      => sr_ddrwr_d_sel,
            sr_vdmp             => sr_vdmp,
            video_ddr_ta        => video_ddr_ta,
            ddrwr_d_sel1        => ddrwr_d_sel(1)
        );

--    I_BLITTER: FBEE_BLITTER
--        PORT MAP(
--            resetn               => reset_n,
--            clk_main            => clk_main,
--            clk_ddr0            => clk_ddr(0),
--            fb_adr              => fb_adr,
--            fb_ale              => fb_ale,
--            fb_size1            => fb_size(1),
--            fb_size0            => fb_size(0),
--            fb_cs_n              => fb_cs_n,
--            fb_oe_n              => fb_oe_n,
--            fb_wr_n              => fb_wr_n,
--            DATA_IN             => fb_ad,
--            DATA_OUT            => data_out_blitter,
--            DATA_EN             => data_en_blitter,
--            blitter_adr         => blitter_adr,
--            blitter_sig         => blitter_sig,
--            blitter_wr          => blitter_wr,
--            blitter_on          => blitter_on,
--            blitter_run         => blitter_run,
--            BLITTER_DIN         => vd_vz,
--            blitter_dout        => blitter_dout,
--            blitter_ta          => blitter_ta,
--            blitter_dack_sr     => blitter_dack_sr
--        );

    I_VIDEOSYSTEM: VIDEO_SYSTEM
        PORT MAP(
            clk_main            => clk_main,
            clk_33m             => clk_33m,
            clk_25m             => clk_25m_i,
            clk_video           => clk_video,
            clk_ddr3            => clk_ddr(3),
            clk_ddr2            => clk_ddr(2),
            clk_ddr0            => clk_ddr(0),
            clk_pixel           => clk_pixel_i,

            vr_d                => vr_d,
            vr_busy             => vr_busy,

            fb_adr              => fb_adr,
            fb_ad_in            => fb_ad,
            fb_ad_out           => fb_ad_out_video,
            fb_ad_en_31_16      => fb_ad_en_31_16_video,
            fb_ad_en_15_0       => fb_ad_en_15_0_video,
            fb_ale              => fb_ale,
            fb_cs_n              => fb_cs_n,
            fb_oe_n              => fb_oe_n,
            fb_wr_n             => FB_WR_n,
            fb_size1            => fb_size(1),
            fb_size0            => fb_size(0),

            vdp_in              => vdp_in,

            vr_rd               => vr_rd,
            vr_wr               => vr_wr,
            video_reconfig      => video_reconfig,

            RED                 => vr,
            GREEN               => vg,
            BLUE                => vb,
            vsync               => vsync_i,
            hsync               => hsync_i,
            sync_n               => sync_n,
            blank_n              => blank_i_n,

            pd_vga_n             => pd_vga_n,
            video_mod_ta        => video_mod_ta,

            vd_vz               => vd_vz,
            sr_fifo_wre         => sr_fifo_wre,
            sr_vdmp             => sr_vdmp,
            fifo_mw             => fifo_mw,
            vdm_sel             => vdm_sel,
            video_ram_ctr       => video_ram_ctr,
            fifo_clr            => fifo_clr,
            vdm                 => vdm,
            blitter_on          => blitter_on,
            blitter_run         => blitter_run
        );

--    I_INTHANDLER: INTHANDLER
--        PORT MAP(
--            clk_main            => clk_main,
--            resetn              => reset_n,
--            fb_adr              => fb_adr,
--            fb_cs_n              => fb_cs_n(2 DOWNTO 1),
--            fb_oe_n              => fb_oe_n,
--            fb_size0            => fb_size(0),
--            fb_size1            => fb_size(1),
--            fb_wr_n              => fb_wr_n,
--            fb_ad_IN            => fb_ad,
--            fb_ad_OUT           => fb_ad_out_ih,
--            fb_ad_EN_31_24      => fb_ad_en_31_24_ih,
--            fb_ad_EN_23_16      => fb_ad_en_23_16_ih,
--            fb_ad_EN_15_8       => fb_ad_en_15_8_ih,
--            fb_ad_EN_7_0        => fb_ad_en_7_0_ih,
--            pic_int             => pic_int,
--            e0_int              => e0_int,
--            dvi_int             => dvi_int,
--            pci_inta_n           => pci_inta_n,
--            pci_intb_n           => pci_intb_n,
--            pci_intc_n           => pci_intc_n,
--            pci_intd_n           => pci_intd_n,
--            mfp_intn            => mfp_int_n,
--            dsp_int             => dsp_int,
--            vsync               => vsync_i,
--            hsync               => hsync_i,
--            drq_dma             => drq_dma,
--            irq_n                => irq_n,
--            int_handler_ta      => int_handler_ta,
--            fbee_conf           => fbee_conf,
--            tin0                => tin0
--        );

--    I_DMA: FBEE_DMA
--        PORT MAP(
--            RESET               => NOT reset_n,
--            clk_main            => clk_main,
--            clk_fdc             => clk_fdc,
--
--            fb_adr              => fb_adr(26 DOWNTO 0),
--            fb_ale              => fb_ale,
--            fb_size             => fb_size,
--            fb_cs_n              => fb_cs_n(2 DOWNTO 1),
--            fb_oe_n              => fb_oe_n,
--            fb_wr_n              => fb_wr_n,
--            fb_ad_IN            => fb_ad,
--            fb_ad_OUT           => fb_ad_out_dma,
--            fb_ad_EN_31_24      => fb_ad_en_31_24_dma,
--            fb_ad_EN_23_16      => fb_ad_en_23_16_dma,
--            fb_ad_EN_15_8       => fb_ad_en_15_8_dma,
--            fb_ad_EN_7_0        => fb_ad_en_7_0_dma,
--
--            ACSI_DIR            => ACSI_DIR,
--            ACSI_D_IN           => ACSI_D,
--            acsi_d_out          => acsi_d_out,
--            acsi_d_en           => acsi_d_en,
--            ACSI_CSn            => ACSI_CSn,
--            ACSI_A1             => ACSI_A1,
--            ACSI_resetn         => ACSI_reset_n,
--            ACSI_DRQn           => ACSI_DRQn,
--            ACSI_ACKn           => ACSI_ACKn,
--
--            DATA_IN_FDC         => data_out_fdc,
--            DATA_IN_SCSI        => data_out_scsi,
--            data_out_fdc_SCSI    => data_in_fdc_scsi,
--
--            DMA_DRQ_IN          => drq_fdc,
--            DMA_DRQ_OUT         => drq_dma,            
--            DMA_DRQ11           => drq11_dma,
--
--            scsi_drq            => scsi_drq,
--            scsi_dackn          => scsi_dack_n,
--            scsi_int            => scsi_int,
--            scsi_csn            => scsi_csn,
--            scsi_cs             => scsi_cs,
--
--            ca                  => ca,
--            FLOPPY_HD_DD        => FDD_HD_DD,
--            wdc_bsl0            => wdc_bsl0,
--            fdc_csn             => fdc_cs_n,
--            fdc_wrn             => fdc_wr_n,
--            fd_int              => fd_int,
--            ide_int             => ide_int,
--            dma_cs              => dma_cs
--        );

--    I_IDE_CF_SD_ROM: IDE_CF_SD_ROM
--        PORT MAP(
--            RESET               => NOT reset_n,
--            clk_main            => clk_main,
--
--            fb_adr              => fb_adr(19 DOWNTO 5),
--            FB_CS1n             => fb_cs_n(1),
--            fb_wr_n              => fb_wr_n,
--            fb_b0               => fb_b0,
--            fb_b1               => fb_b1,
--
--            fbee_conf           => fbee_conf(31 DOWNTO 30),
--
--            RP_UDSn             => RP_UDSn,
--            RP_ldsn             => RP_ldsn,
--
--            SD_CLK              => SD_CLK,
--            SD_D0               => SD_D0,
--            SD_D1               => SD_D1,
--            SD_D2               => SD_D2,
--            SD_CD_D3_IN         => SD_D3,
--            sd_cd_d3_out        => sd_cd_d3_out,
--            sd_cd_d3_en         => sd_cd_d3_en,
--            SD_CMD_D1_IN        => SD_CMD_D1,
--            sd_cmd_d1_out       => sd_cmd_d1_out,
--            sd_cmd_d1_en        => sd_cmd_d1_en,
--            SD_caRD_DETECT      => SD_caRD_DETECT,
--            SD_WP               => SD_WP,
--
--            ide_rdy             => ide_rdy,
--            IDE_WRn             => IDE_WRn,
--            IDE_RDn             => IDE_RDn,
--            IDE_CSn             => IDE_CSn,
--            -- IDE_DRQn         =>, -- Not used.
--            ide_cf_ta           => ide_cf_ta,
--
--            ROM4n               => ROM4n,
--            ROM3n               => ROM3n,
--
--            CF_WP               => CF_WP,
--            CF_CSn              => CF_CSn
--        );

--    I_DSP: DSP
--        PORT MAP(
--            clk_33m             => clk_33m,
--            clk_main            => clk_main,
--            fb_oe_n              => fb_oe_n,
--            fb_wr_n              => fb_wr_n,
--            FB_CS1n             => fb_cs_n(1),
--            FB_CS2n             => fb_cs_n(2),
--            fb_size0            => fb_size(0),
--            fb_size1            => fb_size(1),
--            fb_burst_n           => fb_burst_n,
--            fb_adr              => fb_adr,
--            resetn              => reset_n,
--            FB_CS3n             => fb_cs_n(3),
--            SRCSn               => DSP_SRCSn,
--            SRBLEn              => DSP_SRBLEn,
--            SRBHEn              => DSP_SRBHEn,
--            SRWEn               => DSP_SRWEn,
--            SROEn               => DSP_SROEn,
--            dsp_int             => dsp_int,
--            dsp_ta              => dsp_ta,
--            fb_ad_IN            => fb_ad,
--            fb_ad_OUT           => fb_ad_out_dsp,
--            fb_ad_EN            => fb_ad_en_dsp,
--            IO_IN               => DSP_IO,
--            IO_OUT              => dsp_io_out,
--            IO_EN               => dsp_io_en,
--            SRD_IN              => DSP_SRD,
--            SRD_OUT             => dsp_srd_out,
--            SRD_EN              => dsp_srd_en
--        );

--    I_SOUND: WF2149IP_TOP_SOC
--        PORT MAP(
--            SYS_CLK             => clk_main,
--            resetn              => reset_n,
--
--            WAV_CLK             => clk_2m0,
--            SELn                => '1',
--
--            BDIR                => sndir_i,
--            BC2                 => '1',
--            BC1                 => sndcs_i,
--
--            A9n                 => '0',
--            A8                  => '1',
--            DA_IN               => fb_ad(31 DOWNTO 24),
--            DA_OUT              => da_out_x,
--
--            IO_A_IN             => x"00", -- All port pINs are dedicated OUTputs.
--            IO_A_OUT(7)         => ide_res_i,
--            IO_A_OUT(6)         => lp_dir_x,
--            IO_A_OUT(5)         => lp_str,
--            IO_A_OUT(4)         => dtr,
--            IO_A_OUT(3)         => rts,
--            IO_A_OUT(2)         => reserved_1,
--            IO_A_OUT(1)         => dsa_d,
--            IO_A_OUT(0)         => FDD_SDSELn,
--            -- IO_A_EN          => tout0_n, -- Not required.
--            IO_B_IN             => lp_d,
--            IO_B_OUT            => lp_d_x,
--            -- IO_B_EN          => -- Not used.
--
--            OUT_A               => ym_qa,
--            OUT_B               => ym_qb,
--            OUT_C               => ym_qc
--        );

    I_MFP: WF68901IP_TOP_SOC
        PORT MAP(  
            -- System control:
            CLK                 => clk_main,
            resetn              => reset_n,
            -- Asynchronous bus control:
            DSn                 => NOT lds,
            CSn                 => NOT mfp_cs,
            RWn                 => fb_wr_n,
            DTACKn              => dtack_out_mfp_n,
            -- Data and Adresses:
            RS                  => fb_adr(5 DOWNTO 1),
            DATA_IN             => fb_ad(23 DOWNTO 16),
            DATA_OUT            => data_out_mfp,
            -- DATA_EN          => DATA_EN_MFP, -- Not used.
            GPIP_IN(7)          => NOT drq11_dma,
            GPIP_IN(6)          => NOT ri,
            GPIP_IN(5)          => dint_n,
            GPIP_IN(4)          => acia_irq_n,
            GPIP_IN(3)          => dsp_int,
            GPIP_IN(2)          => NOT cts,
            GPIP_IN(1)          => NOT dcd,
            GPIP_IN(0)          => lp_busy,
            -- GPIP_OUT           =>, -- Not used; all GPIPs are direction INput.
            -- GPIP_EN            =>, -- Not used; all GPIPs are direction INput.
            -- Interrupt control:
            IACKn               => NOT mfp_intack,
            IEIn                => '0',
            -- IEOn             =>, -- Not used.
            irq_n                => mfp_int_n,
            -- Timers and timer control:
            XTAL1               => clk_2m4576,
            TAI                 => '0',
            TBI                 => blank_i_n,
            -- TAO              =>,
            -- TBO              =>,
            -- TCO              =>,
            tdo                 => tdo,
            -- Serial I/O control:
            RC                  => tdo,
            TC                  => tdo,
            SI                  => rxd, 
            SO                  => txd
            -- SO_EN            => -- Not used.
            -- DMA control:
            -- RRn              => -- Not used.
            -- TRn              => -- Not used.
        );

--    I_ACIA_MIDI: WF6850IP_TOP_SOC
--        PORT MAP(
--            CLK                 => clk_main,
--            resetn              => reset_n,
--
--            CS2n                => '0',
--            CS1                 => fb_adr(2),
--            CS0                 => acia_cs,
--            E                   => acia_cs,
--            RWn                 => fb_wr_n,
--            RS                  => fb_adr(1),
--
--            DATA_IN             => fb_ad(31 DOWNTO 24),
--            DATA_OUT            => data_out_acia_iI,
--            -- DATA_EN                => -- Not used.
--
--            TXCLK               => clk_500k,
--            RXCLK               => clk_500k,
--            RXDATA              => midi_in,
--            CTSn                => '0',
--            DCDn                => '0',
--
--            irq_n                => irq_midi_n,
--            TXDATA              => midi_out
--            --RTSn                => -- Not used.
--        );                                              

    I_ACIA_KEYBOARD: WF6850IP_TOP_SOC
        PORT MAP(
            CLK                 => clk_main,
            resetn              => reset_n,

            CS2n                => fb_adr(2),
            CS1                 => '1',
            CS0                 => acia_cs,
            E                   => acia_cs,
            RWn                 => fb_wr_n,
            RS                  => fb_adr(1),

            DATA_IN             => fb_ad(31 DOWNTO 24),
            DATA_OUT            => data_out_acia_i,
            -- DATA_EN                => Not used.

            TXCLK               => clk_500k,
            RXCLK               => clk_500k,
            RXDATA              => keyb_rxd,

            CTSn                => '0',
            DCDn                => '0',

            irq_n                => irq_keybd_n,
            TXDATA              => amkb_tx
            --RTSn                => -- Not used.
        );                                              

--    I_SCSI: WF5380_TOP_SOC
--        PORT MAP(
--            CLK                 => clk_fdc,
--            resetn              => reset_n,
--            ADR                 => ca,
--            DATA_IN             => data_in_fdc_scsi,
--            DATA_OUT            => data_out_scsi,
--            --DATA_EN           =>,
--            -- Bus and DMA controls:
--            CSn                 => scsi_csn,
--            RDn                 => NOT fdc_wr_n OR NOT scsi_cs,
--            WRn                 => fdc_wr_n  OR NOT scsi_cs,
--            EOPn                => '1',
--            DACKn               => scsi_dack_n,
--            DRQ                 => scsi_drq,
--            INT                 => scsi_int,
--            -- READY            =>, 
--            -- SCSI bus:
--            DB_INn              => SCSI_D,
--            DB_OUTn             => scsi_d_out_n,
--            DB_EN               => scsi_d_en,
--            DBP_INn             => SCSI_PAR,
--            DBP_OUTn            => scsi_dbp_out_n,
--            DBP_EN              => scsi_dbp_en,                -- wenn 1 dann OUTput
--            RST_INn             => SCSI_RSTn,
--            RST_OUTn            => scsi_rst_out_n,
--            RST_EN              => scsi_rst_en,
--            BSY_INn             => SCSI_BUSYn,
--            BSY_OUTn            => scsi_bsy_out_n,
--            BSY_EN              => scsi_bsy_en,
--            SEL_INn             => SCSI_SELn,
--            SEL_OUTn            => scsi_sel_out_n,
--            SEL_EN              => scsi_sel_en,
--            ACK_INn             => '1',
--            ACK_OUTn            => SCSI_ACKn,
--            -- ACK_EN           => ACK_EN,
--            ATN_INn             => '1',
--            ATN_OUTn            => SCSI_ATNn,
--            -- ATN_EN           => ATN_EN,
--            REQ_INn             => scsi_drqn,
--            -- REQ_OUTn         => REQ_OUTn,
--            -- REQ_EN           => REQ_EN,
--            IOn_IN              => SCSI_IOn,
--            -- IOn_OUT          => IOn_OUT,
--            -- IO_EN            => IO_EN,
--            CDn_IN              => SCSI_CDn,
--            -- CDn_OUT          => CDn_OUT,
--            -- CD_EN            => CD_EN,
--            MSG_INn             => SCSI_MSGn
--            -- MSG_OUTn         => MSG_OUTn,
--            -- MSG_EN           => MSG_EN
--        );              
--
--    I_FDC: WF1772IP_TOP_SOC
--        PORT MAP(
--            CLK                 => clk_fdc,
--            resetn              => reset_n,
--            CSn                 => fdc_cs_n,
--            RWn                 => fdc_wr_n,
--            A1                  => ca(2),
--            A0                  => ca(1),
--            DATA_IN             => data_in_fdc_scsi,
--            DATA_OUT            => data_out_fdc,
--            -- DATA_EN          => CD_EN_FDC,
--            RDn                 => FDD_RDn,
--            TR00n               => FDD_TRACK00,
--            IPn                 => FDD_INDEXn,
--            WPRTn               => FDD_WPn,
--            DDEn                => '0', -- Fixed to MFM.
--            HDTYPE              => hd_dd_out,  
--            MO                  => FDD_MOT_ON,
--            WG                  => FDD_WR_GATE,
--            WD                  => FDD_WDn,
--            STEP                => FDD_STEP,
--            DIRC                => FDD_STEP_DIR,
--            DRQ                 => drq_fdc,
--            INTRQ               => fd_int 
--        );

--    I_RTC: RTC
--        PORT MAP(
--            clk_main            => clk_main,
--            fb_adr              => fb_adr(19 DOWNTO 0),
--            FB_CS1n             => fb_cs_n(1),
--            fb_size0            => fb_size(0),
--            fb_size1            => fb_size(1),
--            fb_wr_n              => fb_wr_n,
--            fb_oe_n              => fb_oe_n,
--            fb_ad_IN            => fb_ad(23 DOWNTO 16),
--            fb_ad_OUT           => fb_ad_out_rtc,
--            fb_ad_EN_23_16      => fb_ad_en_rtc,
--            pic_int             => pic_int
--        );
END ARCHITECTURE;

