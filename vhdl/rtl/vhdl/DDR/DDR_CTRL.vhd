----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the DDR controller of the 'Firebee'----
---- computer. It is optimized for the use of an Altera Cyclone   ----
---- FPGA (EP3C40F484). This IP-Core is based on the first edi-   ----
---- tion of the Firebee configware originally provided by Fredi  ----
---- Aschwanden and Wolfgang Förster. This release is in compa-   ----
---- rision to the first edition completely written in VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                     K                                         ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi Aschwanden, Wolfgang Förster        ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- AND/OR modify it under the terms of the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 of the License, OR (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program is distributed in the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; WITHout even the implied   ----
---- warranty of MERCHANTABILITY OR FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License for more        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along WITH this program; IF not, write to the Free   ----
---- Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K12B  20120801 WF
--   Initial Release of the second edition.

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY DDR_CTRL IS
    PORT(
        clk_main        : IN STD_LOGIC;
        ddr_sync_66m    : IN STD_LOGIC;
        fb_adr          : IN UNSIGNED (31 DOWNTO 0);
        fb_cs1_n        : IN STD_LOGIC;
        fb_oe_n         : IN STD_LOGIC;
        fb_size0        : IN STD_LOGIC;
        fb_size1        : IN STD_LOGIC;
        fb_ale          : IN STD_LOGIC;
        fb_wr_n          : IN STD_LOGIC;
        fifo_clr        : IN STD_LOGIC;
        video_control_register   : IN UNSIGNED (15 DOWNTO 0);
        blitter_adr     : IN UNSIGNED (31 DOWNTO 0);
        blitter_sig     : IN STD_LOGIC;
        blitter_wr      : IN STD_LOGIC;

        ddrclk0         : IN STD_LOGIC;
        clk_33m         : IN STD_LOGIC;
        fifo_mw         : IN UNSIGNED (8 DOWNTO 0);
        
        va              : OUT UNSIGNED (12 DOWNTO 0);               -- video Adress bus at the DDR chips
        vwe_n           : OUT STD_LOGIC;                                    -- video memory write enable
        vras_n          : OUT STD_LOGIC;                                    -- video memory RAS
        vcs_n           : OUT STD_LOGIC;                                    -- video memory chip SELECT
        vcke            : OUT STD_LOGIC;                                    -- video memory clock enable
        vcas_n          : OUT STD_LOGIC;                                    -- video memory CAS
        
        fb_le           : OUT UNSIGNED (3 DOWNTO 0);
        fb_vdoe         : OUT UNSIGNED (3 DOWNTO 0);
        
        sr_fifo_wre     : OUT STD_LOGIC;
        sr_ddr_fb       : OUT STD_LOGIC;
        sr_ddr_wr       : OUT STD_LOGIC;
        sr_ddrwr_d_sel  : OUT STD_LOGIC;
        sr_vdmp         : OUT UNSIGNED (7 DOWNTO 0);
        
        video_ddr_ta    : OUT STD_LOGIC;
        sr_blitter_dack : OUT STD_LOGIC;
        ba              : OUT UNSIGNED (1 DOWNTO 0);
        ddrwr_d_sel1    : OUT STD_LOGIC;
        vdm_sel         : OUT UNSIGNED (3 DOWNTO 0);
        data_in         : IN UNSIGNED (31 DOWNTO 0);
        data_out        : OUT UNSIGNED (31 DOWNTO 16);
        data_en_h       : OUT STD_LOGIC;
        data_en_l       : OUT STD_LOGIC
    );
END ENTITY DDR_CTRL;

ARCHITECTURE BEHAVIOUR of DDR_CTRL IS
    -- fifo watermark:
    CONSTANT FIFO_LWM : INTEGER := 0;       -- low water mark
    CONSTANT FIFO_MWM : INTEGER := 200;     -- medium water mark
    CONSTANT FIFO_HWM : INTEGER := 500;     -- high water mark
    
    -- constants for bits in video_control_register
    CONSTANT vrcr_vcke          : INTEGER := 0;
    CONSTANT VRCR_REFRESH_ON    : INTEGER := 2;
    CONSTANT VRCR_CONFIG_ON     : INTEGER := 3;
    CONSTANT vrcr_vcs           : INTEGER := 1;
    --
    CONSTANT VRCR_FIFO_ON       : INTEGER := 24;
    CONSTANT VRCR_BORDER_ON     : INTEGER := 25;
    
    TYPE access_width_t IS (long_access, word_access, byte_access);
    TYPE ddr_access_t IS (ddr_access_cpu, ddr_access_fifo, ddr_access_blitter, ddr_access_none);
    TYPE fb_regddr_t IS (fr_wait, fr_s0, fr_s1, fr_s2, fr_s3);    
    TYPE ddr_sm_t IS (ds_t1, ds_t2a, ds_t2b, ds_t3, ds_n5, ds_n6, ds_n7, ds_n8,             -- Start (normal 8 cycles total = 60ns).
                               ds_c2, ds_c3, dc_c4, ds_c5, ds_c6, ds_c7,                    -- Configuration. 
                               ds_t4r, ds_t5r,                                              -- Read ddr_access_cpu OR ddr_access_blitter.
                               ds_t4w, ds_t5w, ds_t6w, ds_t7w, ds_t8w, ds_t9w,              -- Write ddr_access_cpu OR ddr_access_blitter.
                               ds_t4f, ds_t5f, ds_t6f, ds_t7f, ds_t8f, ds_t9f, ds_t10f,     -- Read ddr_access_fifo.
                               ds_cb6, ds_cb8,                                              -- Close ddr_access_fifo bank.
                               ds_r2, ds_r3, ds_r4, ds_r5, ds_r6);                          -- Refresh: 10 x 7.5ns = 75ns.
    
    SIGNAL access_width     : access_width_t;
    SIGNAL fb_regddr        : fb_regddr_t;
    SIGNAL fb_regddr_next   : fb_regddr_t;
    SIGNAL ddr_access       : ddr_access_t;
    SIGNAL ddr_state        : ddr_sm_t;
    SIGNAL ddr_next_state   : ddr_sm_t;
    SIGNAL byte_sel         : UNSIGNED (3 DOWNTO 0);
    SIGNAL sr_fifo_wre_i    : STD_LOGIC;
    SIGNAL vcas             : STD_LOGIC;
    SIGNAL vras             : STD_LOGIC;
    SIGNAL vwe              : STD_LOGIC;
    SIGNAL mcs              : UNSIGNED (1 DOWNTO 0);
    SIGNAL bus_cyc          : STD_LOGIC;
    SIGNAL bus_cyc_end      : STD_LOGIC;
    SIGNAL blitter_req      : STD_LOGIC;
    SIGNAL blitter_row_adr  : UNSIGNED (12 DOWNTO 0);
    SIGNAL blitter_ba       : UNSIGNED (1 DOWNTO 0);
    SIGNAL blitter_col_adr  : UNSIGNED (9 DOWNTO 0);
    SIGNAL cpu_ddr_sync     : STD_LOGIC;
    SIGNAL cpu_row_adr      : UNSIGNED (12 DOWNTO 0);
    SIGNAL cpu_ba           : UNSIGNED (1 DOWNTO 0);
    SIGNAL cpu_col_adr      : UNSIGNED (9 DOWNTO 0);
    SIGNAL cpu_req          : STD_LOGIC;
    SIGNAL ddr_sel          : STD_LOGIC;
    SIGNAL ddr_cs           : STD_LOGIC;
    SIGNAL ddr_config       : STD_LOGIC;
    SIGNAL fifo_req         : STD_LOGIC;
    SIGNAL fifo_row_adr     : UNSIGNED (12 DOWNTO 0);
    SIGNAL fifo_ba          : UNSIGNED (1 DOWNTO 0);
    SIGNAL fifo_col_adr     : UNSIGNED(9 DOWNTO 0);
    SIGNAL fifo_active      : STD_LOGIC;
    SIGNAL fifo_clr_sync    : STD_LOGIC;
    SIGNAL vdm_sel_i        : UNSIGNED (3 DOWNTO 0);
    SIGNAL clear_fifo_cnt   : STD_LOGIC;
    SIGNAL stop             : STD_LOGIC;
    SIGNAL fifo_bank_ok     : STD_LOGIC;
    SIGNAL ddr_refresh_cnt  : UNSIGNED(10 DOWNTO 0) := "00000000000";
    SIGNAL ddr_refresh_req  : STD_LOGIC;
    SIGNAL ddr_refresh_sig  : UNSIGNED(3 DOWNTO 0);
    SIGNAL need_refresh     : STD_LOGIC;
    SIGNAL video_base_l_d   : UNSIGNED (7 DOWNTO 0);
    SIGNAL video_base_l     : STD_LOGIC;
    SIGNAL video_base_m_d   : UNSIGNED (7 DOWNTO 0);
    SIGNAL video_base_m     : STD_LOGIC;
    SIGNAL video_base_h_d   : UNSIGNED (7 DOWNTO 0);
    SIGNAL video_base_h     : STD_LOGIC;
    SIGNAL video_base_x_d   : UNSIGNED (2 DOWNTO 0);
    SIGNAL video_adr_cnt    : UNSIGNED(22 DOWNTO 0);
    SIGNAL video_cnt_l      : STD_LOGIC;
    SIGNAL video_cnt_m      : STD_LOGIC;
    SIGNAL video_cnt_h      : STD_LOGIC;
    SIGNAL video_base_adr   : UNSIGNED (22 DOWNTO 0);
    SIGNAL video_act_adr    : UNSIGNED (26 DOWNTO 0);
    SIGNAL fb_adr_i         : UNSIGNED (32 DOWNTO 0);
    
    
    SIGNAL va_s             : UNSIGNED (12 DOWNTO 0);
    SIGNAL va_p             : UNSIGNED (12 DOWNTO 0);
    SIGNAL ba_s             : UNSIGNED (1 DOWNTO 0) ;
    SIGNAL ba_p             : UNSIGNED (1 DOWNTO 0);
    SIGNAL tsiz             : UNSIGNED (1 DOWNTO 0);
BEGIN
    tsiz <= fb_size1 & fb_size0;
    WITH tsiz SELECT
        access_width <= long_access WHEN "11",
                        word_access WHEN "00",
                        byte_access WHEN OTHERS;

    -- Byte selectors:
    byte_sel(0) <= '1' WHEN access_width = long_access OR access_width = word_access ELSE
                        '1' WHEN fb_adr(1 DOWNTO 0) = "00" ELSE '0';            -- Byte 0.

    byte_sel(1) <= '1' WHEN access_width = long_access OR access_width = word_access ELSE
                        '1' WHEN access_width = byte_access AND fb_adr(1) = '0' ELSE   -- High word_access.
                        '1' WHEN fb_adr(1 DOWNTO 0) = "01" ELSE '0';            -- Byte 1.
             
    byte_sel(2) <= '1' WHEN access_width = long_access OR access_width = word_access ELSE
                        '1' WHEN fb_adr(1 DOWNTO 0) = "10" ELSE '0';            -- Byte 2.
             
    byte_sel(3) <= '1' WHEN access_width = long_access OR access_width = word_access ELSE
                        '1' WHEN access_width = byte_access AND fb_adr(1) = '1' ELSE   -- Low word_access.
                        '1' WHEN fb_adr(1 DOWNTO 0) = "11" ELSE '0'; -- Byte 3.
             
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------ ddr_access_cpu READ (REG DDR => ddr_access_cpu) AND WRITE (ddr_access_cpu => REG DDR) ---------------------------------------------------------------------
    fbctrl_reg : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_33m);
        fb_regddr <= fb_regddr_next;
    END PROCESS FBCTRL_REG;
    
    fbctrl_dec : PROCESS(fb_regddr, bus_cyc, ddr_sel, access_width, fb_wr_n, ddr_cs)
    BEGIN
        CASE fb_regddr IS
            WHEN fr_wait => 
                IF bus_cyc = '1' THEN
                    fb_regddr_next <= fr_s0;
                ELSIF ddr_sel = '1' AND access_width = long_access AND fb_wr_n = '0' THEN
                    fb_regddr_next <= fr_s0;
                ELSE
                    fb_regddr_next <= fr_wait;
                END IF;
            
            WHEN fr_s0 =>
                IF ddr_cs = '1' AND access_width = long_access THEN
                    fb_regddr_next <= fr_s1;
                ELSE
                    fb_regddr_next <= fr_wait; 
                END IF;
            
            WHEN fr_s1 => 
                IF ddr_cs = '1' THEN
                    fb_regddr_next <= fr_s2;
                ELSE
                    fb_regddr_next <= fr_wait; 
                END IF;
            
            WHEN fr_s2 => 
                IF ddr_cs = '1' AND bus_cyc = '0' AND access_width = long_access AND fb_wr_n = '0' THEN -- wait during long_access word_access access if needed
                    fb_regddr_next <= fr_s2;
                ELSIF ddr_cs = '1' THEN
                    fb_regddr_next <= fr_s3;
                ELSE
                    fb_regddr_next <= fr_wait;
                END IF;
    
            WHEN fr_s3 => 
                fb_regddr_next <= fr_wait;
        END CASE;
    END PROCESS FBCTRL_DEC;

    -- Coldfire ddr_access_cpu access:
    fb_le(0) <= NOT fb_wr_n WHEN fb_regddr = fr_wait ELSE
                NOT fb_wr_n WHEN fb_regddr = fr_s0 AND ddr_cs = '1' ELSE '0';
    fb_le(1) <= NOT fb_wr_n WHEN fb_regddr = fr_s1 AND ddr_cs = '1' ELSE '0';
    fb_le(2) <= NOT fb_wr_n WHEN fb_regddr = fr_s2 AND ddr_cs = '1' ELSE '0';
    fb_le(3) <= NOT fb_wr_n WHEN fb_regddr = fr_s3 AND ddr_cs = '1' ELSE '0';

    -- video data access:
    video_ddr_ta <= '1' WHEN fb_regddr = fr_s0 AND ddr_cs = '1' ELSE
                    '1' WHEN fb_regddr = fr_s1 AND ddr_cs = '1' ELSE
                    '1' WHEN fb_regddr = fr_s2 AND fb_regddr_next = fr_s3 ELSE
                    '1' WHEN fb_regddr = fr_s3 AND ddr_cs = '1' ELSE '0';

    -- fb_vdoe # VIDEO_OE.

    -- Write access for video data:
    fb_vdoe(0) <= '1' WHEN fb_regddr = fr_s0 AND ddr_cs = '1' AND fb_oe_n = '0' AND ddr_config = '0' AND access_width = long_access ELSE
                  '1' WHEN fb_regddr = fr_s0 AND ddr_cs = '1' AND fb_oe_n = '0' AND ddr_config = '0' AND access_width /= long_access AND clk_33m = '0' ELSE '0';
    fb_vdoe(1) <= '1' WHEN fb_regddr = fr_s1 AND ddr_cs = '1' AND fb_oe_n = '0' AND ddr_config = '0' ELSE '0';
    fb_vdoe(2) <= '1' WHEN fb_regddr = fr_s2 AND ddr_cs = '1' AND fb_oe_n = '0' AND ddr_config = '0' ELSE '0';
    fb_vdoe(3) <= '1' WHEN fb_regddr = fr_s3 AND ddr_cs = '1' AND fb_oe_n = '0' AND ddr_config = '0' AND clk_33m = '0' ELSE '0';

    bus_cyc_end <= '1' WHEN fb_regddr = fr_s0 AND ddr_cs = '1' AND access_width /= long_access ELSE
                   '1' WHEN fb_regddr = fr_s3 AND ddr_cs = '1' ELSE '0';

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------ DDR State Machine --------------------------------------------------------------------------------------
    ddr_state_reg: PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ddrclk0);
        ddr_state <= ddr_next_state;
    END PROCESS ddr_state_reg;

    ddr_state_dec: PROCESS(ddr_state, ddr_refresh_req, cpu_ddr_sync, ddr_config, fb_wr_n, ddr_access, blitter_wr, fifo_req, fifo_bank_ok,
                                    fifo_mw, cpu_req, video_adr_cnt, ddr_sel, tsiz, data_in, fifo_ba, ddr_refresh_sig)
    BEGIN
        CASE ddr_state IS
            WHEN ds_t1 =>
                IF ddr_refresh_req = '1' THEN
                    ddr_next_state <= ds_r2;
                ELSIF cpu_ddr_sync = '1' AND ddr_config = '1' THEN -- Synchronous start.
                    ddr_next_state <= ds_c2;
                ELSIF cpu_ddr_sync = '1' AND cpu_req = '1' THEN -- Synchronous start.
                    ddr_next_state <= ds_t2b;
                ELSIF cpu_ddr_sync = '1' THEN
                    ddr_next_state <= ds_t2a;
                ELSE
                    ddr_next_state <= ds_t1; -- Synchronize.
                END IF;
            
            WHEN ds_t2a => -- Fast access, IN this CASE page IS always NOT ok.
                ddr_next_state <= ds_t3;
    
            WHEN ds_t2b =>
                ddr_next_state <= ds_t3;

            WHEN ds_t3 =>
                IF ddr_access = ddr_access_cpu AND fb_wr_n = '0' THEN
                    ddr_next_state <= ds_t4w;
                ELSIF ddr_access = ddr_access_blitter AND blitter_wr = '1' THEN
                    ddr_next_state <= ds_t4w;
                ELSIF ddr_access = ddr_access_cpu THEN     -- ddr_access_cpu?
                    ddr_next_state <= ds_t4r;                                                 
                ELSIF ddr_access = ddr_access_fifo THEN    -- ddr_access_fifo?
                    ddr_next_state <= ds_t4f;
                ELSIF ddr_access = ddr_access_blitter THEN
                    ddr_next_state <= ds_t4r;                                                 
                ELSE
                    ddr_next_state <= ds_n8;
                END IF;
            
            -- Read:
            WHEN ds_t4r =>
                ddr_next_state <= ds_t5r;                

            WHEN ds_t5r =>
                IF fifo_req = '1' AND fifo_bank_ok = '1' THEN -- Insert ddr_access_fifo read, WHEN bank ok.
                    ddr_next_state <= ds_t6f;
                ELSE    
                    ddr_next_state <= ds_cb6;
                END IF;
            
            -- Write:            
            WHEN ds_t4w =>
                ddr_next_state <= ds_t5w;

            WHEN ds_t5w =>
                ddr_next_state <= ds_t6w;

            WHEN ds_t6w =>                               
                ddr_next_state <= ds_t7w;

            WHEN ds_t7w =>                               
                ddr_next_state <= ds_t8w;
            
            WHEN ds_t8w =>                               
                ddr_next_state <= ds_t9w;
            
            WHEN ds_t9w =>                               
                IF fifo_req = '1' AND fifo_bank_ok = '1' THEN
                    ddr_next_state <= ds_t6f;
                ELSE
                    ddr_next_state <= ds_cb6;
                END IF;
            
            -- ddr_access_fifo read:
            WHEN ds_t4f =>
                ddr_next_state <= ds_t5f;                

            WHEN ds_t5f =>
                IF fifo_req = '1' THEN
                    ddr_next_state <= ds_t6f;
                ELSE
                    ddr_next_state <= ds_cb6; -- Leave open.
                END IF;

            WHEN ds_t6f =>
                ddr_next_state <= ds_t7f;                                                                      
            
            WHEN ds_t7f =>
                IF cpu_req = '1' AND fifo_mw > FIFO_LWM THEN    
                    ddr_next_state <= ds_cb8; -- Close bank.
                ELSIF fifo_req = '1' AND video_adr_cnt(7 DOWNTO 0) = x"FF" THEN -- New page?
                    ddr_next_state <= ds_cb8; -- Close bank.
                ELSIF fifo_req = '1' THEN
                    ddr_next_state <= ds_t8f;
                ELSE
                    ddr_next_state <= ds_cb8; -- Close bank.
                END IF;

            WHEN ds_t8f =>
                IF fifo_mw < FIFO_LWM THEN -- Emergency?
                    ddr_next_state <= ds_t5f; -- Yes!
                ELSE
                    ddr_next_state <= ds_t9f;
                END IF;

            WHEN ds_t9f =>
                IF fifo_req = '1' AND video_adr_cnt(7 DOWNTO 0) = x"FF"  THEN -- New page?
                    ddr_next_state <= ds_cb6; -- Close bank.
                ELSIF fifo_req = '1' THEN
                    ddr_next_state <= ds_t10f;
                ELSE
                    ddr_next_state <= ds_cb6; -- Close bank.
                END IF;

            WHEN ds_t10f =>
                IF ddr_sel = '1' AND (fb_wr_n = '1' OR tsiz /= "11") AND data_in(13 DOWNTO 12) /= fifo_ba THEN
                    ddr_next_state <= ds_t3;
                ELSE
                    ddr_next_state <= ds_t7f;
                END IF; 

            -- Configuration cycles:
            WHEN ds_c2 =>
                ddr_next_state <= ds_c3;
            
            WHEN ds_c3 =>
                ddr_next_state <= dc_c4;
            
            WHEN dc_c4 =>
                IF cpu_req = '1' THEN
                    ddr_next_state <= ds_c5;
                ELSE
                    ddr_next_state <= ds_t1;
                END IF; 

            WHEN ds_c5 =>
                ddr_next_state <= ds_c6;
            
            WHEN ds_c6 =>
                ddr_next_state <= ds_c7;
            
            WHEN ds_c7 =>
                ddr_next_state <= ds_n8;

            -- Close ddr_access_fifo bank.
            WHEN ds_cb6 =>
                ddr_next_state <= ds_n7;
            
            WHEN ds_cb8 =>
                ddr_next_state <= ds_t1;
            
            -- Refresh 70ns = ten cycles.
            WHEN ds_r2 =>
                IF ddr_refresh_sig = x"9" THEN -- One cycle delay to close all banks.
                    ddr_next_state <= ds_r4;
                ELSE
                    ddr_next_state <= ds_r3;
                END IF;

            WHEN ds_r3 =>
                ddr_next_state <= ds_r4;

            WHEN ds_r4 =>
                ddr_next_state <= ds_r5;
            
            WHEN ds_r5 =>
                ddr_next_state <= ds_r6;
            
            WHEN ds_r6 =>
                ddr_next_state <= ds_n5;
            
            -- Loop:
            WHEN ds_n5 =>
                ddr_next_state <= ds_n6;

            WHEN ds_n6 =>
                ddr_next_state <= ds_n7;

            WHEN ds_n7 =>
                ddr_next_state <= ds_n8;
            
            WHEN ds_n8 =>
                ddr_next_state <= ds_t1;
        END CASE;
    END PROCESS ddr_state_dec;

    p_clk0 : PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ddrclk0);
        
        -- Default assignments;
        ddr_access <= ddr_access_none;
        sr_fifo_wre_i <= '0';
        sr_vdmp <= x"00";
        sr_ddr_wr <= '0';
        sr_ddrwr_d_sel <= '0';

        mcs <= mcs(0) & clk_33m;        -- sync on clk_33m
        
        blitter_req <= blitter_sig AND NOT
                        video_control_register(VRCR_CONFIG_ON) AND
                        video_control_register(vrcr_vcke) AND
                        video_control_register(vrcr_vcs);

        fifo_clr_sync <= fifo_clr;
        clear_fifo_cnt <= fifo_clr_sync OR NOT fifo_active;
        stop <= fifo_clr_sync OR clear_fifo_cnt;

        IF fifo_mw < fifo_mwm THEN
            fifo_req <= '1';
        ELSIF fifo_mw < FIFO_HWM AND fifo_req = '1' THEN
            fifo_req <= '1';
        ELSIF fifo_active = '1' AND
                clear_fifo_cnt = '0' AND
                stop = '0' AND
                ddr_config = '0' AND
                video_control_register(vrcr_vcke) = '1' AND
                video_control_register(vrcr_vcs) = '1' THEN
            fifo_req <= '1';
        ELSE
            fifo_req <= '1';
        END IF;

        IF clear_fifo_cnt = '1' THEN
            video_adr_cnt <= video_base_adr;
        ELSIF sr_fifo_wre_i = '1' THEN
            video_adr_cnt <= video_adr_cnt + 1;  
        END IF;

        IF mcs = "10" AND video_control_register(vrcr_vcke) = '1' AND video_control_register(vrcr_vcs) = '1' THEN
            cpu_ddr_sync <= '1';
        ELSE
            cpu_ddr_sync <= '0';
        END IF;

        IF ddr_refresh_sig /= x"0" AND video_control_register(VRCR_REFRESH_ON) = '1' AND ddr_config = '0' AND need_refresh = '1' THEN
            ddr_refresh_req <= '1';
        ELSE
            ddr_refresh_req <= '0';
        END IF;

        IF ddr_refresh_cnt = 0 AND clk_33m = '0' THEN
            need_refresh <= '1';
        ELSE
            need_refresh <= '0';
        END IF;

        IF need_refresh = '1' AND video_control_register(VRCR_REFRESH_ON) = '1' AND ddr_config = '0' THEN
            ddr_refresh_sig <= x"9";
        ELSIF ddr_state = ds_r6 AND video_control_register(VRCR_REFRESH_ON) = '1' AND ddr_config = '0' THEN
            ddr_refresh_sig <= ddr_refresh_sig - 1;
        ELSE
            ddr_refresh_sig <= x"0";
        END IF;

        IF bus_cyc_end = '1' THEN
            bus_cyc <= '0';
        ELSIF ddr_state = ds_t1 AND cpu_ddr_sync = '1' AND cpu_req = '1' THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_t2a AND ddr_sel = '1' AND fb_wr_n = '0' THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_t2a AND ddr_sel = '1' AND access_width /= long_access THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_t2b THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_t10f AND fb_wr_n = '0' AND data_in(13 DOWNTO 12) = fifo_ba THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_t10f AND access_width /= long_access AND data_in(13 DOWNTO 12) = fifo_ba THEN
            bus_cyc <= '1';
        ELSIF ddr_state = ds_c3 THEN
            bus_cyc <= cpu_req;
        END IF;

        IF ddr_state = ds_t1 AND cpu_ddr_sync = '1' AND cpu_req = '1' THEN
            va_s <= cpu_row_adr;
            ba_s <= cpu_ba;
            ddr_access <= ddr_access_cpu;
        ELSIF ddr_state = ds_t1 AND cpu_ddr_sync = '1' AND fifo_req = '1' THEN
            va_p <= fifo_row_adr;
            ba_p <= fifo_ba;
            ddr_access <= ddr_access_fifo;
        ELSIF ddr_state = ds_t1 AND cpu_ddr_sync = '1' AND blitter_req = '0' THEN
            va_p <= blitter_row_adr;
            ba_p <= blitter_ba;
            ddr_access <= ddr_access_blitter;
        ELSIF ddr_state = ds_t2a AND ddr_sel = '1' AND fb_wr_n = '0' THEN
            va_s(10) <= '1';
            ddr_access <= ddr_access_cpu;
        ELSIF ddr_state = ds_t2a AND ddr_sel = '1' AND access_width /= long_access THEN
            va_s(10) <= '1';
            ddr_access <= ddr_access_cpu;
        ELSIF ddr_state = ds_t2a THEN
            -- ?? mfro
            va_s(10) <= NOT (fifo_active AND fifo_req);
            ddr_access <= ddr_access_fifo;
            fifo_bank_ok <= fifo_active AND fifo_req;
            IF ddr_access = ddr_access_blitter AND blitter_req = '1' THEN
                ddr_access <= ddr_access_blitter;
            END IF;
            -- ?? mfro BLITTER_AC <= BLITTER_ACTIVE AND blitter_req;
        ELSIF ddr_state = ds_t2b THEN
            fifo_bank_ok <= '0';
        ELSIF ddr_state = ds_t3 THEN
            va_s(10) <= va_s(10);
            IF (fb_wr_n = '0' AND ddr_access = ddr_access_cpu) OR (blitter_wr = '1' AND ddr_access = ddr_access_blitter) THEN
                va_s(9 DOWNTO 0) <= cpu_col_adr;
                ba_s <= cpu_ba;
            ELSIF fifo_active = '1' THEN
                va_s(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr);
                ba_s <= fifo_ba;
            ELSIF ddr_access = ddr_access_blitter THEN
                va_s(9 DOWNTO 0) <= blitter_col_adr;
                ba_s <= blitter_ba;
            END IF;
        ELSIF ddr_state = ds_t4r THEN
            -- mfro change next two statements
            IF ddr_access = ddr_access_cpu THEN
                sr_ddr_fb <= '1';
            ELSIF ddr_access = ddr_access_blitter THEN
                sr_blitter_dack <= '1';
            END IF;
        ELSIF ddr_state = ds_t5r AND fifo_req = '1' AND fifo_bank_ok = '1' THEN
            va_s(10) <= '0';
            va_s(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr);
            ba_s <= fifo_ba;
        ELSIF ddr_state = ds_t5r THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t4w THEN
            va_s(10) <= va_s(10);
            -- mfro changed next IF
            IF ddr_access = ddr_access_blitter THEN
                sr_blitter_dack <= '1';
            END IF;
        ELSIF ddr_state = ds_t5w THEN
            va_s(10) <= va_s(10);
            IF ddr_access = ddr_access_cpu THEN
                va_s(9 DOWNTO 0) <= cpu_col_adr;
                ba_s <= cpu_ba;
            ELSIF ddr_access = ddr_access_blitter THEN
                va_s(9 DOWNTO 0) <= blitter_col_adr;
                ba_s <= blitter_ba;
            END IF;
            IF ddr_access = ddr_access_blitter AND access_width = long_access THEN
                sr_vdmp <= byte_sel & x"F";
            ELSIF ddr_access = ddr_access_blitter THEN
                sr_vdmp <= byte_sel & x"0";
            ELSE
                sr_vdmp <= byte_sel & x"0";
            END IF;
        ELSIF ddr_state = ds_t6w THEN
            sr_ddr_wr <= '1';
            sr_ddrwr_d_sel <= '1';
            IF ddr_access = ddr_access_blitter OR access_width = long_access THEN
                sr_vdmp <= x"FF";
            ELSE
                sr_vdmp <= x"00";
            END IF;
        ELSIF ddr_state = ds_t7w THEN
            sr_ddr_wr <= '1';
            sr_ddrwr_d_sel <= '1';
        ELSIF ddr_state = ds_t9w AND fifo_req = '1' AND fifo_bank_ok = '1' THEN
            va_s(10) <= '0';
            va_s(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr);
            ba_s <= fifo_ba;
        ELSIF ddr_state = ds_t9w THEN
            va_s(10) <= '0';
        ELSIF ddr_state = ds_t4f THEN
            sr_fifo_wre_i <= '1';
        ELSIF ddr_state = ds_t5f AND fifo_req = '1' AND video_adr_cnt(7 DOWNTO 0) = x"FF" THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t5f AND fifo_req = '1' THEN
            va_s(10) <= '0';
            va_s(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr + "100");
            ba_s <= fifo_ba;
        ELSIF ddr_state = ds_t5f THEN
            va_s(10) <= '0';
        ELSIF ddr_state = ds_t6f THEN
            sr_fifo_wre_i <= '1';
        ELSIF ddr_state = ds_t7f AND cpu_req = '1' AND fifo_mw > FIFO_LWM THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t7f AND fifo_req = '1' AND video_adr_cnt(7 DOWNTO 0) = x"FF" THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t7f AND fifo_req = '1' THEN
            va_s(10) <= '0';
            va_s(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr + "100");
            ba_s <= fifo_ba;
        ELSIF ddr_state = ds_t7f THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t9f AND fifo_req = '1' AND video_adr_cnt(7 DOWNTO 0) = x"FF" THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t9f AND fifo_req = '1' THEN
            va_p(10) <= '0';
            va_p(9 DOWNTO 0) <= UNSIGNED (fifo_col_adr + "100");
            ba_p <= fifo_ba;
        ELSIF ddr_state = ds_t9f THEN
            va_s(10) <= '1';
        ELSIF ddr_state = ds_t10f AND fb_wr_n = '0' AND data_in(13 DOWNTO 12) = fifo_ba THEN
            va_s(10) <= '1';
            ddr_access <= ddr_access_cpu;
        ELSIF ddr_state = ds_t10f AND access_width /= long_access AND data_in(13 DOWNTO 12) = fifo_ba THEN
            va_s(10) <= '1';
            ddr_access <= ddr_access_cpu;
        ELSIF ddr_state = ds_t10f THEN
            sr_fifo_wre_i <= '1';
        ELSIF ddr_state = ds_c6 THEN
            va_s <= data_in(12 DOWNTO 0);
            ba_s <= data_in(14 DOWNTO 13);
        ELSIF ddr_state = ds_cb6 THEN
            fifo_bank_ok <= '0';
        ELSIF ddr_state = ds_cb8 THEN
            fifo_bank_ok <= '0';
        ELSIF ddr_state = ds_r2 THEN
            fifo_bank_ok <= '0';
        ELSE
        END IF;
    END PROCESS p_clk0;

    ddr_sel <= '1' WHEN fb_ale = '1' AND data_in(31 DOWNTO 30) = "01" ELSE '0';

    p_ddr_cs: PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_33m);
        IF fb_ale = '1' THEN
            ddr_cs <= ddr_sel;
        END IF;
    END PROCESS p_ddr_cs;
    
    p_cpu_req: PROCESS
    BEGIN
        WAIT UNTIL RISING_EDGE(ddr_sync_66m);

        IF ddr_sel = '1' AND fb_wr_n = '1' AND ddr_config = '0' THEN
            cpu_req <= '1';
        ELSIF ddr_sel = '1' AND access_width /= long_access AND ddr_config = '0' THEN                   -- Start when not config and not longword access.
            cpu_req <= '1';
        ELSIF ddr_sel = '1' AND ddr_config = '1' THEN                                                   -- Config, start immediately.
            cpu_req <= '1';
        ELSIF fb_regddr = fr_s1 AND fb_wr_n = '0' THEN                                                  -- Longword write later.
            cpu_req <= '1';
        ELSIF fb_regddr /= fr_s1 AND fb_regddr /= fr_s3 AND bus_cyc_end = '0' AND bus_cyc = '0' THEN    -- Halt, bus cycle in progress or ready.
            cpu_req <= '0';
        END IF;
    END PROCESS p_cpu_req;
    
    p_refresh : PROCESS
        -- Refresh: Always 8 at a time every 7.8us.
        -- 7.8us x 8 = 62.4us = 2059 -> 2048 @ 33MHz.
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_33m);
        ddr_refresh_cnt <= ddr_refresh_cnt + 1;                                                         -- Count from 0 to 2047
    END PROCESS p_refresh;

    sr_fifo_wre <= sr_fifo_wre_i;
    
    va <=   data_in(26 DOWNTO 14) WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND fb_wr_n = '0' ELSE
            data_in(26 DOWNTO 14) WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND (fb_size0 = '0' OR fb_size1= '0') ELSE
            va_p WHEN ddr_state = ds_t2a ELSE
            data_in(26 DOWNTO 14) WHEN ddr_state = ds_t10f AND fb_wr_n = '0' AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            data_in(26 DOWNTO 14) WHEN ddr_state = ds_t10f AND (fb_size0 = '0' OR fb_size1= '0') AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            va_p WHEN ddr_state = ds_t10f ELSE
            "0010000000000" WHEN ddr_state = ds_r2 AND ddr_refresh_sig = x"9" ELSE va_s;

    ba <=   data_in(13 DOWNTO 12) WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND fb_wr_n = '0' ELSE
            data_in(13 DOWNTO 12) WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND (fb_size0 = '0' OR fb_size1= '0') ELSE
            ba_p WHEN ddr_state = ds_t2a ELSE
            data_in(13 DOWNTO 12) WHEN ddr_state = ds_t10f AND fb_wr_n = '0' AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            data_in(13 DOWNTO 12) WHEN ddr_state = ds_t10f AND (fb_size0 = '0' OR fb_size1= '0') AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            ba_p WHEN ddr_state = ds_t10f ELSE ba_s;
            
    vras <= '1' WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND fb_wr_n = '0' ELSE
            '1' WHEN ddr_state = ds_t2a AND ddr_sel = '1' AND (fb_size0 = '0' OR fb_size1= '0') ELSE
            '1' WHEN ddr_state = ds_t2a AND ddr_access = ddr_access_fifo AND fifo_req = '1' ELSE
            '1' WHEN ddr_state = ds_t2a AND ddr_access = ddr_access_blitter AND blitter_req = '1' ELSE
            '1' WHEN ddr_state = ds_t2b ELSE
            '1' WHEN ddr_state = ds_t10f AND fb_wr_n = '0' AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            '1' WHEN ddr_state = ds_t10f AND (fb_size0 = '0' OR fb_size1= '0') AND data_in(13 DOWNTO 12) = fifo_ba ELSE
            data_in(18) AND NOT fb_wr_n AND NOT fb_size0 AND NOT fb_size1 WHEN ddr_state = ds_c7 ELSE
            '1' WHEN ddr_state = ds_cb6 ELSE
            '1' WHEN ddr_state = ds_cb8 ELSE
            '1' WHEN ddr_state = ds_r2 ELSE '0';

    vcas <= '1' WHEN ddr_state = ds_t4r ELSE
            '1' WHEN ddr_state = ds_t6w ELSE
            '1' WHEN ddr_state = ds_t4f ELSE
            '1' WHEN ddr_state = ds_t6f ELSE
            '1' WHEN ddr_state = ds_t8f ELSE
            '1' WHEN ddr_state = ds_t10f AND vras = '0' ELSE
            data_in(17) AND NOT fb_wr_n AND NOT fb_size0 AND NOT fb_size1 WHEN ddr_state = ds_c7 ELSE
            '1' WHEN ddr_state = ds_r2 AND ddr_refresh_sig /= x"9" ELSE '0';

    vwe <= '1' WHEN ddr_state = ds_t6w ELSE
           data_in(16) AND NOT fb_wr_n AND NOT fb_size0 AND NOT fb_size1 WHEN ddr_state = ds_c7 ELSE
           '1' WHEN ddr_state = ds_cb6 ELSE
           '1' WHEN ddr_state = ds_cb8 ELSE
           '1' WHEN ddr_state = ds_r2 AND ddr_refresh_sig = x"9" ELSE '0';

    -- DDR controller:
    -- VIDEO RAM CONTROL REGISTER (IS IN VIDEO_MUX_CTR) 
    -- $F0000400: BIT 0: vcke; 1: NOT nVCS ;2:REFRESH ON , (0=ddr_access_fifo AND CNT CLEAR); 
    -- 3: CONFIG; 8: fifo_active; 
    vcs_n <= NOT(video_control_register(VRCR_REFRESH_ON));
    ddr_config <= video_control_register(3);
    fifo_active <= video_control_register(8);

    cpu_row_adr <= fb_adr(26 DOWNTO 14);
    cpu_ba <= fb_adr(13 DOWNTO 12);
    cpu_col_adr <= fb_adr(11 DOWNTO 2);
    vras_n <= NOT vras;
    vcas_n <= NOT vcas;
    vwe_n <= NOT vwe;

    ddrwr_d_sel1 <= '1' WHEN ddr_access = ddr_access_blitter ELSE '0';
    
    blitter_row_adr <= blitter_adr(26 DOWNTO 14);
    blitter_ba <= blitter_adr(13 DOWNTO 12);
    blitter_col_adr <= blitter_adr(11 DOWNTO 2);

    fifo_row_adr <= video_adr_cnt(22 DOWNTO 10);
    fifo_ba <= video_adr_cnt(9 DOWNTO 8);
    fifo_col_adr <= video_adr_cnt(7 DOWNTO 0) & "00";

    video_base_adr(22 DOWNTO 20) <= video_base_x_d;
    video_base_adr(19 DOWNTO 12) <= video_base_h_d;
    video_base_adr(11 DOWNTO 4)  <= video_base_m_d;
    video_base_adr(3 DOWNTO 0)   <= video_base_l_d(7 DOWNTO 4);

    vdm_sel <= vdm_sel_i;
    vdm_sel_i <= video_base_l_d(3 DOWNTO 0);

    -- Current video address:
    video_act_adr(26 DOWNTO 4) <= video_adr_cnt - fifo_mw;
    video_act_adr(3 DOWNTO 0) <= vdm_sel_i;

    p_video_regs : PROCESS
    -- Video registers.
    BEGIN
        WAIT UNTIL RISING_EDGE(clk_33m);
        IF video_base_l = '1' AND fb_wr_n = '0' AND byte_sel(1) = '1' THEN
            video_base_l_d <= data_in(23 DOWNTO 16); -- 16 byte borders
        END IF;
          
        IF video_base_m = '1' AND fb_wr_n = '0' AND byte_sel(3) = '1' THEN
            video_base_m_d <= data_in(23 DOWNTO 16);
        END IF;

        IF video_base_h = '1' AND fb_wr_n = '0' AND byte_sel(1) = '1' THEN
            video_base_h_d <= data_in(23 DOWNTO 16);
        END IF;

        IF video_base_h = '1' AND fb_wr_n = '0' AND byte_sel(0) = '1' THEN
            video_base_x_d <= data_in(26 DOWNTO 24);
        END IF;
    END PROCESS p_video_regs;

    fb_adr_i <= fb_adr & '0';

    video_base_l <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"820D" ELSE '0'; -- x"FF820D".
    video_base_m <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"8204" ELSE '0'; -- x"FF8203". 
    video_base_h <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"8202" ELSE '0'; -- x"FF8201".

    video_cnt_l <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"8208" ELSE '0'; -- x"FF8209".
    video_cnt_m <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"8206" ELSE '0'; -- x"FF8207". 
    video_cnt_h <= '1' WHEN fb_cs1_n = '0' AND fb_adr_i(15 DOWNTO 0) = x"8204" ELSE '0'; -- x"FF8205".

    data_out(31 DOWNTO 24) <= "00000" & video_base_x_d WHEN video_base_h = '1' ELSE
                              "00000" & video_act_adr(26 DOWNTO 24) WHEN video_cnt_h = '1' ELSE (OTHERS => '0');

    data_en_h <= (video_base_h OR video_cnt_h) AND NOT fb_oe_n;

    data_out(23 DOWNTO 16) <= video_base_l_d WHEN video_base_l = '1' ELSE
                              video_base_m_d WHEN video_base_m = '1' ELSE
                              video_base_h_d WHEN video_base_h = '1' ELSE
                              video_act_adr(7 DOWNTO 0) WHEN video_cnt_l = '1' ELSE
                              video_act_adr(15 DOWNTO 8) WHEN video_cnt_m = '1' ELSE
                              video_act_adr(23 DOWNTO 16) WHEN video_cnt_h = '1' ELSE (OTHERS => '0');
                      
    data_en_l <= (video_base_l OR video_base_m OR video_base_h OR video_cnt_l OR video_cnt_m OR video_cnt_h) AND NOT fb_oe_n;
END ARCHITECTURE BEHAVIOUR;
-- va           : Video DDR address multiplexed
-- va_p         : latched va, wenn FIFO_AC, BLITTER_AC
-- va_s         : latch for default va
-- ba           : Video DDR bank address multiplexed
-- ba_p         : latched ba, wenn FIFO_AC, BLITTER_AC
-- ba_s         : latch for default ba
--
--FB_SIZE ersetzen.
