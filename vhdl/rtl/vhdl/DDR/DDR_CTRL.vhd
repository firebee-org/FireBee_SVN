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
---- Ashwanden  and Wolfgang Förster. This release is in compa-   ----
---- rision to the first edition completely written in VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi Aschwanden, Wolfgang Förster        ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 of the License, or (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program is distributed in the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License for more        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along with this program; if not, write to the Free   ----
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

ENTITY ddr_ctrl IS
    PORT(
        CLK_MAIN        : IN std_logic;
        DDR_SYNC_66M    : IN std_logic;
        FB_ADR          : IN std_logic_vector(31 DOWNTO 0);
        fb_cs1_n        : IN std_logic;
        fb_oe_n         : IN std_logic;
        FB_SIZE0        : IN std_logic;
        FB_SIZE1        : IN std_logic;
        FB_ALE          : IN std_logic;
        fb_wr_n         : IN std_logic;
        FIFO_CLR        : IN std_logic;
        vram_control    : IN std_logic_vector(15 DOWNTO 0);
        BLITTER_ADR     : IN std_logic_vector(31 DOWNTO 0);
        BLITTER_SIG     : IN std_logic;
        BLITTER_WR      : IN std_logic;
        DDRCLK0         : IN std_logic;
        CLK_33M         : IN std_logic;
        FIFO_MW         : IN unsigned(8 DOWNTO 0);
        VA              : OUT std_logic_vector(12 DOWNTO 0);
        vwe_n           : OUT std_logic;
        vras_n          : OUT std_logic;
        vcs_n           : OUT std_logic;
        VCKE            : OUT std_logic;
        vcas_n          : OUT std_logic;
        FB_LE           : OUT std_logic_vector(3 DOWNTO 0);
        FB_VDOE         : OUT std_logic_vector(3 DOWNTO 0);
        SR_FIFO_WRE     : OUT std_logic;
        SR_DDR_FB       : OUT std_logic;
        SR_DDR_WR       : OUT std_logic;
        SR_DDRWR_D_SEL  : OUT std_logic;
        SR_VDMP         : OUT std_logic_vector(7 DOWNTO 0);
        video_ddr_ta    : OUT std_logic;
        SR_BLITTER_DACK : OUT std_logic;
        BA              : OUT std_logic_vector(1 DOWNTO 0);
        DDRWR_D_SEL1    : OUT std_logic;
        VDM_SEL         : OUT std_logic_vector(3 DOWNTO 0);
        DATA_IN         : IN std_logic_vector(31 DOWNTO 0);
        DATA_OUT        : OUT std_logic_vector(31 DOWNTO 16);
        DATA_EN_H       : OUT std_logic;
        DATA_EN_L       : OUT std_logic
    );
END ENTITY ddr_ctrl;

ARCHITECTURE behaviour OF ddr_ctrl IS
    -- FIFO WATER MARK:
    CONSTANT FIFO_LWM : unsigned(8 DOWNTO 0) := 9D"0";
    CONSTANT FIFO_MWM : unsigned(8 DOWNTO 0) := 9D"200"; -- 200.
    CONSTANT FIFO_HWM : unsigned(8 DOWNTO 0) := 9D"500"; -- 500.
    
    type DDR_ACCESS_TYPE is(CPU, FIFO, BLITTER, NONE);
    type FB_REGDDR_TYPE is(FR_WAIT,FR_S0,FR_S1,FR_S2,FR_S3);    
    type DDR_SM_TYPE is(DS_T1, DS_T2A, DS_T2B, DS_T3, DS_N5, DS_N6, DS_N7, DS_N8,   -- Start (normal 8 cycles total = 60ns).
                        DS_C2, DS_C3, DS_C4, DS_C5, DS_C6, DS_C7,                   -- Configuration. 
                        DS_T4R, DS_T5R,                                             -- Read CPU or BLITTER.
                        DS_T4W, DS_T5W, DS_T6W, DS_T7W, DS_T8W, DS_T9W,             -- Write CPU or BLITTER.
                        DS_T4F, DS_T5F, DS_T6F, DS_T7F, DS_T8F, DS_T9F, DS_T10F,    -- Read FIFO.
                        DS_CB6, DS_CB8,                                             -- Close FIFO bank.
                        DS_R2, DS_R3, DS_R4, DS_R5, DS_R6);                         -- Refresh: 10 x 7.5ns = 75ns.
    
    signal FB_REGDDR        : FB_REGDDR_TYPE;
    signal FB_REGDDR_NEXT   : FB_REGDDR_TYPE;
    signal DDR_ACCESS       : DDR_ACCESS_TYPE;
    signal DDR_STATE        : DDR_SM_TYPE;
    signal DDR_NEXT_STATE   : DDR_SM_TYPE;
    signal VCS_In           : std_logic;
    signal VCKE_I           : std_logic;
    signal BYTE_SEL         : std_logic_vector(3 DOWNTO 0);
    signal SR_FIFO_WRE_I    : std_logic;
    signal VCAS             : std_logic;
    signal VRAS             : std_logic;
    signal VWE              : std_logic;
    signal MCS              : std_logic_vector(1 DOWNTO 0);
    signal BUS_CYC          : std_logic;
    signal BUS_CYC_END      : std_logic;
    signal BLITTER_REQ      : std_logic;
    signal BLITTER_ROW_ADR  : std_logic_vector(12 DOWNTO 0);
    signal BLITTER_BA       : std_logic_vector(1 DOWNTO 0);
    signal BLITTER_COL_ADR  : std_logic_vector(9 DOWNTO 0);
    signal CPU_DDR_SYNC     : std_logic;
    signal CPU_ROW_ADR      : std_logic_vector(12 DOWNTO 0);
    signal CPU_BA           : std_logic_vector(1 DOWNTO 0);
    signal CPU_COL_ADR      : std_logic_vector(9 DOWNTO 0);
    signal CPU_REQ          : std_logic;
    signal DDR_SEL          : std_logic;
    signal DDR_CS           : std_logic;
    signal DDR_CONFIG       : std_logic;
    signal FIFO_REQ         : std_logic;
    signal FIFO_ROW_ADR     : std_logic_vector(12 DOWNTO 0);
    signal FIFO_BA          : std_logic_vector(1 DOWNTO 0);
    signal FIFO_COL_ADR     : unsigned(9 DOWNTO 0);
    signal FIFO_ACTIVE      : std_logic;
    signal FIFO_CLR_SYNC    : std_logic;
    signal VDM_SEL_I        : std_logic_vector(3 DOWNTO 0);
    signal CLEAR_FIFO_CNT   : std_logic;
    signal STOP             : std_logic;
    signal FIFO_BANK_OK     : std_logic;
    signal DDR_REFRESH_ON   : std_logic;
    signal DDR_REFRESH_CNT  : unsigned(10 DOWNTO 0);
    signal DDR_REFRESH_REQ  : std_logic;
    signal DDR_REFRESH_SIG  : unsigned(3 DOWNTO 0);
    signal REFRESH_TIME     : std_logic;
    signal VIDEO_BASE_L_D   : std_logic_vector(7 DOWNTO 0);
    signal VIDEO_BASE_L     : std_logic;
    signal VIDEO_BASE_M_D   : std_logic_vector(7 DOWNTO 0);
    signal VIDEO_BASE_M     : std_logic;
    signal VIDEO_BASE_H_D   : std_logic_vector(7 DOWNTO 0);
    signal VIDEO_BASE_H     : std_logic;
    signal VIDEO_BASE_X_D   : std_logic_vector(2 DOWNTO 0);
    signal VIDEO_ADR_CNT    : unsigned(22 DOWNTO 0);
    signal VIDEO_CNT_L      : std_logic;
    signal VIDEO_CNT_M      : std_logic;
    signal VIDEO_CNT_H      : std_logic;
    signal VIDEO_BASE_ADR   : std_logic_vector(22 DOWNTO 0);
    signal VIDEO_ACT_ADR    : std_logic_vector(26 DOWNTO 0);
    signal FB_ADR_I         : std_logic_vector(32 DOWNTO 0);
    
    
    signal VA_S             : std_logic_vector(12 DOWNTO 0);
    signal VA_P             : std_logic_vector(12 DOWNTO 0);
    signal BA_S             : std_logic_vector(1 DOWNTO 0) ;
    signal BA_P             : std_logic_vector(1 DOWNTO 0);
    SIGNAL line             : std_logic;
begin
    line <= fb_size1 AND fb_size0;
    
    -- Byte selectors (changed to literal copy of Fredi's code):
    byte_sel(0) <= '1' WHEN fb_adr(1 DOWNTO 0) = "00" OR
                            (?? (fb_size1 AND fb_size0)) OR
                            (?? (NOT fb_size1 AND NOT fb_size0))
                       ELSE '0';
                       
    byte_sel(1) <= '1' WHEN fb_adr(1 DOWNTO 0) = "01" OR
                            (?? (fb_size1 AND NOT fb_size0 AND NOT fb_adr(1))) OR
                            (?? (fb_size1 AND fb_size0)) OR
                            (?? (NOT fb_size1 AND NOT fb_size0))
                       ELSE '0';
                       
    byte_sel(2) <= '1' WHEN fb_adr(1 DOWNTO 0) = "10" OR
                            (??(fb_size1 AND fb_size0)) OR
                            (??(NOT fb_size1 AND NOT fb_size0))
                       ELSE '0';
    byte_sel(3) <= '1' WHEN fb_adr(1 DOWNTO 0) = "11" OR
                            (??(fb_size1 AND NOT fb_size0 AND fb_adr(1))) OR
                            (??(fb_size1 AND fb_size0)) OR
                            (??(NOT fb_size1 AND NOT fb_size0))
                       ELSE '0';
             
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------ CPU READ (REG DDR => CPU) AND WRITE (CPU => REG DDR) ---------------------------------------------------------------------
    fbctrl_reg : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk_main);
        fb_regddr <= fb_regddr_next;
    END PROCESS fbctrl_reg;
    
    fbctrl_dec : PROCESS(ALL)
    BEGIN
        -- avoid latches - assign defaults
        bus_cyc_end <= '0';
        video_ddr_ta <= '0';
        fb_vdoe(3 DOWNTO 0) <= "0000";
        fb_le(3 DOWNTO 0) <= "0000";

        -- mfro: replaced with literal copy of Fredi's original
        
        case FB_REGDDR is
            WHEN FR_WAIT =>
                fb_le(0) <= NOT fb_wr_n;
                IF bus_cyc = '1' OR (??(ddr_sel AND line AND NOT fb_wr_n)) THEN
                    fb_regddr_next <= FR_S0;
                ELSE
                    fb_regddr_next <= FR_WAIT;
                END IF;
                
            WHEN FR_S0 =>
                IF ddr_cs THEN
                    fb_le(0) <= NOT fb_wr_n;
                    video_ddr_ta <= '1';
                    IF line THEN
                        fb_vdoe(0) <= NOT fb_oe_n AND NOT ddr_config;
                        fb_regddr_next <= FR_S1;
                    ELSE
                        bus_cyc_end <= '1';
                        fb_vdoe(0) <= NOT fb_oe_n AND NOT clk_main AND NOT ddr_config;
                        fb_regddr_next <= FR_S0;
                    END IF;
                ELSE
                    fb_regddr_next <= FR_WAIT;
                END IF;
                
            WHEN FR_S1 => 
                IF ddr_cs THEN
                    fb_vdoe(1) <= NOT fb_oe_n AND NOT ddr_config;
                    fb_le(1) <= NOT fb_wr_n;
                    video_ddr_ta <= '1';
                    fb_regddr_next <= FR_S2;
                ELSE
                    fb_regddr_next <= FR_WAIT;
                END IF;

            WHEN FR_S2 => 
                IF ddr_cs THEN
                    fb_vdoe(2) <= NOT fb_oe_n AND NOT ddr_config;
                    fb_le(2) <= NOT fb_wr_n;
                    IF NOT bus_cyc AND line AND NOT fb_wr_n THEN
                        fb_regddr_next <= FR_S2;
                        video_ddr_ta <= '0'; -- mfro: ???
                    ELSE
                        video_ddr_ta <= '1';
                        fb_regddr_next <= FR_S3;
                    END IF;
                ELSE
                    fb_regddr_next <= FR_WAIT;
                END IF;
                
            WHEN FR_S3 =>
                IF ddr_cs THEN
                    fb_vdoe(3) <= NOT fb_oe_n AND NOT clk_main AND NOT ddr_config;
                    fb_le(3) <= NOT fb_wr_n;
                    video_ddr_ta <= '1';
                    bus_cyc_end <= '1';
                    fb_regddr_next <= FR_WAIT;
                ELSE
                    fb_regddr_next <= FR_WAIT;
                END IF;
        END CASE;
    END PROCESS fbctrl_dec;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------ DDR State Machine --------------------------------------------------------------------------------------
    ddr_state_reg : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(ddrclk0);
        ddr_state <= ddr_next_state;
    END PROCESS ddr_state_reg;

    DDR_STATE_DEC: process(ALL)
    begin
        case DDR_STATE is
            when DS_T1 =>
                if DDR_REFRESH_REQ = '1' then
                    DDR_NEXT_STATE <= DS_R2;
                elsif CPU_DDR_SYNC = '1' and DDR_CONFIG = '1' then -- Synchronous start.
                    DDR_NEXT_STATE <= DS_C2;
                elsif CPU_DDR_SYNC = '1' and CPU_REQ = '1' then -- Synchronous start.
                    DDR_NEXT_STATE <= DS_T2B;
                elsif CPU_DDR_SYNC = '1' then
                    DDR_NEXT_STATE <= DS_T2A;
                else
                    DDR_NEXT_STATE <= DS_T1; -- Synchronize.
                end if;
            when DS_T2A => -- Fast access, IN this case page is always not ok.
                DDR_NEXT_STATE <= DS_T3;
            when DS_T2B =>
                DDR_NEXT_STATE <= DS_T3;
            when DS_T3 =>
                if DDR_ACCESS = CPU and fb_wr_n = '0' then
                    DDR_NEXT_STATE <= DS_T4W;
                elsif DDR_ACCESS = BLITTER and BLITTER_WR = '1' then
                    DDR_NEXT_STATE <= DS_T4W;
                elsif DDR_ACCESS = CPU then -- CPU?
                    DDR_NEXT_STATE <= DS_T4R;                                                 
                elsif DDR_ACCESS = FIFO then -- FIFO?
                    DDR_NEXT_STATE <= DS_T4F;
                elsif DDR_ACCESS = BLITTER then
                    DDR_NEXT_STATE <= DS_T4R;                                                 
                else
                    DDR_NEXT_STATE <= DS_N8;
                end if;
            -- Read:
            when DS_T4R =>
                DDR_NEXT_STATE <= DS_T5R;                
            when DS_T5R =>
                if FIFO_REQ = '1' and FIFO_BANK_OK = '1' then -- Insert FIFO read, when bank ok.
                    DDR_NEXT_STATE <= DS_T6F;
                else    
                    DDR_NEXT_STATE <= DS_CB6;
                end if;
            -- Write:            
            when DS_T4W =>
                DDR_NEXT_STATE <= DS_T5W;
            when DS_T5W =>
                DDR_NEXT_STATE <= DS_T6W;
            when DS_T6W =>                               
                DDR_NEXT_STATE <= DS_T7W;
            when DS_T7W =>                               
                DDR_NEXT_STATE <= DS_T8W;
            when DS_T8W =>                               
                DDR_NEXT_STATE <= DS_T9W;
            when DS_T9W =>                               
                if FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
                    DDR_NEXT_STATE <= DS_T6F;
                else
                    DDR_NEXT_STATE <= DS_CB6;
                end if;
            -- FIFO read:
            when DS_T4F =>
                DDR_NEXT_STATE <= DS_T5F;                
            when DS_T5F =>
                if FIFO_REQ = '1' then
                    DDR_NEXT_STATE <= DS_T6F;
                else
                    DDR_NEXT_STATE <= DS_CB6; -- Leave open.
                end if;
            when DS_T6F =>
                DDR_NEXT_STATE <= DS_T7F;                                                                      
            when DS_T7F =>
                if CPU_REQ = '1' and FIFO_MW > FIFO_LWM then    
                    DDR_NEXT_STATE <= DS_CB8; -- Close bank.
                elsif FIFO_REQ = '1' and VIDEO_ADR_CNT(7 DOWNTO 0) = x"FF" then -- New page?
                    DDR_NEXT_STATE <= DS_CB8; -- Close bank.
                elsif FIFO_REQ = '1' then
                    DDR_NEXT_STATE <= DS_T8F;
                else
                    DDR_NEXT_STATE <= DS_CB8; -- Close bank.
                end if;
            when DS_T8F =>
                if FIFO_MW < FIFO_LWM then -- Emergency?
                    DDR_NEXT_STATE <= DS_T5F; -- Yes!
                else
                    DDR_NEXT_STATE <= DS_T9F;
                end if;
            when DS_T9F =>
                if FIFO_REQ = '1' and VIDEO_ADR_CNT(7 DOWNTO 0) = x"FF"  then -- New page?
                    DDR_NEXT_STATE <= DS_CB6; -- Close bank.
                elsif FIFO_REQ = '1' then
                    DDR_NEXT_STATE <= DS_T10F;
                else
                    DDR_NEXT_STATE <= DS_CB6; -- Close bank.
                end if;
            when DS_T10F =>
                if DDR_SEL = '1' and (fb_wr_n = '1' or (FB_SIZE0 and  FB_SIZE1) = '0') and DATA_IN(13 DOWNTO 12) /= FIFO_BA then
                    DDR_NEXT_STATE <= DS_T3;
                else
                    DDR_NEXT_STATE <= DS_T7F;
                end if; 
            -- Configuration cycles:
            when DS_C2 =>
                DDR_NEXT_STATE <= DS_C3;
            when DS_C3 =>
                DDR_NEXT_STATE <= DS_C4;
            when DS_C4 =>
                if CPU_REQ = '1' then
                    DDR_NEXT_STATE <= DS_C5;
                else
                    DDR_NEXT_STATE <= DS_T1;
                end if; 
            when DS_C5 =>
                DDR_NEXT_STATE <= DS_C6;
            when DS_C6 =>
                DDR_NEXT_STATE <= DS_C7;
            when DS_C7 =>
                DDR_NEXT_STATE <= DS_N8;
            -- Close FIFO bank.
            when DS_CB6 =>
                DDR_NEXT_STATE <= DS_N7;
            when DS_CB8 =>
                DDR_NEXT_STATE <= DS_T1;
            -- Refresh 70ns = ten cycles.
            when DS_R2 =>
                if DDR_REFRESH_SIG = x"9" then -- One cycle delay to close all banks.
                    DDR_NEXT_STATE <= DS_R4;
                else
                    DDR_NEXT_STATE <= DS_R3;
                end if;
            when DS_R3 =>
                DDR_NEXT_STATE <= DS_R4;
            when DS_R4 =>
                DDR_NEXT_STATE <= DS_R5;
            when DS_R5 =>
                DDR_NEXT_STATE <= DS_R6;
            when DS_R6 =>
                DDR_NEXT_STATE <= DS_N5;
            -- Loop:
            when DS_N5 =>
                DDR_NEXT_STATE <= DS_N6;
            when DS_N6 =>
                DDR_NEXT_STATE <= DS_N7;
            when DS_N7 =>
                DDR_NEXT_STATE <= DS_N8;
            when DS_N8 =>
                DDR_NEXT_STATE <= DS_T1;
        end case;
    end process DDR_STATE_DEC;

    P_CLK0: process
    begin
        wait until DDRCLK0 = '1' and DDRCLK0' event;
        -- Default assignments;
        DDR_ACCESS <= NONE;
        SR_FIFO_WRE_I <= '0';
        SR_VDMP <= x"00";
        SR_DDR_WR <= '0';
        SR_DDRWR_D_SEL <= '0';

        MCS <= MCS(0) & CLK_MAIN;
        BLITTER_REQ <= BLITTER_SIG and not DDR_CONFIG and VCKE_I and not VCS_In;
        FIFO_CLR_SYNC <= FIFO_CLR;
        CLEAR_FIFO_CNT <= FIFO_CLR_SYNC or not FIFO_ACTIVE;
        STOP <= FIFO_CLR_SYNC or CLEAR_FIFO_CNT;

        if FIFO_MW < FIFO_MWM then
            FIFO_REQ <= '1';
        elsif FIFO_MW < FIFO_HWM and FIFO_REQ = '1' then
            FIFO_REQ <= '1';
        elsif FIFO_ACTIVE = '1' and CLEAR_FIFO_CNT = '0' and STOP = '0' and DDR_CONFIG = '0' and VCKE_I = '1' and VCS_In = '0' then
            FIFO_REQ <= '1';
        else
            FIFO_REQ <= '1';
        end if;

        if CLEAR_FIFO_CNT = '1' then
            VIDEO_ADR_CNT <= unsigned(VIDEO_BASE_ADR);
        elsif SR_FIFO_WRE_I = '1' then
            VIDEO_ADR_CNT <= VIDEO_ADR_CNT + 1;  
        end if;

        if MCS = "10" and VCKE_I = '1' and VCS_In = '0' then
            CPU_DDR_SYNC <= '1';
        else
            CPU_DDR_SYNC <= '0';
        end if;

        if DDR_REFRESH_SIG /= x"0" and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' and REFRESH_TIME = '1' then
            DDR_REFRESH_REQ <= '1';
        else
            DDR_REFRESH_REQ <= '0';
        end if;

        if DDR_REFRESH_CNT = "00000000000" and CLK_MAIN = '0' then
            REFRESH_TIME <= '1';
        else
            REFRESH_TIME <= '0';
        end if;

        if REFRESH_TIME = '1' and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' then
            DDR_REFRESH_SIG <= x"9";
        elsif DDR_STATE = DS_R6 and DDR_REFRESH_ON = '1' and DDR_CONFIG = '0' then
            DDR_REFRESH_SIG <= DDR_REFRESH_SIG - 1;
        else
            DDR_REFRESH_SIG <= x"0";
        end if;

        if BUS_CYC_END = '1' then
            BUS_CYC <= '0';
        elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and CPU_REQ = '1' then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and fb_wr_n = '0' then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_T2B then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_T10F and fb_wr_n = '0' and DATA_IN(13 DOWNTO 12) = FIFO_BA then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 DOWNTO 12) = FIFO_BA then
            BUS_CYC <= '1';
        elsif DDR_STATE = DS_C3 then
            BUS_CYC <= CPU_REQ;
        end if;

        if DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and CPU_REQ = '1' then
            VA_S <= CPU_ROW_ADR;
            BA_S <= CPU_BA;
            DDR_ACCESS <= CPU;
        elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and FIFO_REQ = '1' then
            VA_P <= FIFO_ROW_ADR;
            BA_P <= FIFO_BA;
            DDR_ACCESS <= FIFO;
        elsif DDR_STATE = DS_T1 and CPU_DDR_SYNC = '1' and BLITTER_REQ = '0' then
            VA_P <= BLITTER_ROW_ADR;
            BA_P <= BLITTER_BA;
            DDR_ACCESS <= BLITTER;
        elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and fb_wr_n = '0' then
            VA_S(10) <= '1';
            DDR_ACCESS <= CPU;
        elsif DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') then
            VA_S(10) <= '1';
            DDR_ACCESS <= CPU;
        elsif DDR_STATE = DS_T2A then
                -- ?? mfro
                VA_S(10) <= not (FIFO_ACTIVE and FIFO_REQ);
            DDR_ACCESS <= FIFO;
                FIFO_BANK_OK <= FIFO_ACTIVE and FIFO_REQ; 
                -- ?? mfro BLITTER_AC <= BLITTER_ACTIVE and BLITTER_REQ;
        elsif DDR_STATE = DS_T2B then
            FIFO_BANK_OK <= '0';
        elsif DDR_STATE = DS_T3 then
            VA_S(10) <= VA_S(10);
            if (fb_wr_n = '0' and DDR_ACCESS = CPU) or (BLITTER_WR = '1' and DDR_ACCESS = BLITTER) then
                VA_S(9 DOWNTO 0) <= CPU_COL_ADR;
                BA_S <= CPU_BA;
            elsif FIFO_ACTIVE = '1' then
                VA_S(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR);
                BA_S <= FIFO_BA;
            elsif DDR_ACCESS = BLITTER then
                VA_S(9 DOWNTO 0) <= BLITTER_COL_ADR;
                BA_S <= BLITTER_BA;
            end if;
        elsif DDR_STATE = DS_T4R then
-- mfro SR_DDR_FB <= CPU_AC;
-- mfro SR_BLITTER_DACK <= BLITTER_AC;
        elsif DDR_STATE = DS_T5R and FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
            VA_S(10) <= '0';
            VA_S(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR);
            BA_S <= FIFO_BA;
        elsif DDR_STATE = DS_T5R then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T4W then
            VA_S(10) <= VA_S(10);
-- mfro SR_BLITTER_DACK <= BLITTER_AC;
        elsif DDR_STATE = DS_T5W then
            VA_S(10) <= VA_S(10);
            if DDR_ACCESS = CPU then
                VA_S(9 DOWNTO 0) <= CPU_COL_ADR;
                BA_S <= CPU_BA;
            elsif DDR_ACCESS = BLITTER then
                VA_S(9 DOWNTO 0) <= BLITTER_COL_ADR;
                BA_S <= BLITTER_BA;
            end if;
            if DDR_ACCESS = BLITTER and FB_SIZE1 = '1' and FB_SIZE0 = '1' then
                SR_VDMP <= BYTE_SEL & x"F";
            elsif DDR_ACCESS = BLITTER then
                SR_VDMP <= BYTE_SEL & x"0";
            else
                SR_VDMP <= BYTE_SEL & x"0";
            end if;
        elsif DDR_STATE = DS_T6W then
            SR_DDR_WR <= '1';
            SR_DDRWR_D_SEL <= '1';
            if DDR_ACCESS = BLITTER or (FB_SIZE1 = '1' and FB_SIZE0 = '1') then
                SR_VDMP <= x"FF";
            else
                SR_VDMP <= x"00";
            end if;
        elsif DDR_STATE = DS_T7W then
            SR_DDR_WR <= '1';
            SR_DDRWR_D_SEL <= '1';
        elsif DDR_STATE = DS_T9W and FIFO_REQ = '1' and FIFO_BANK_OK = '1' then
            VA_S(10) <= '0';
            VA_S(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR);
            BA_S <= FIFO_BA;
        elsif DDR_STATE = DS_T9W then
            VA_S(10) <= '0';
        elsif DDR_STATE = DS_T4F then
            SR_FIFO_WRE_I <= '1';
        elsif DDR_STATE = DS_T5F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 DOWNTO 0) = x"FF" then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T5F and FIFO_REQ = '1' then
            VA_S(10) <= '0';
            VA_S(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR + "100");
            BA_S <= FIFO_BA;
        elsif DDR_STATE = DS_T5F then
            VA_S(10) <= '0';
        elsif DDR_STATE = DS_T6F then
            SR_FIFO_WRE_I <= '1';
        elsif DDR_STATE = DS_T7F and CPU_REQ = '1' and FIFO_MW > FIFO_LWM then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T7F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 DOWNTO 0) = x"FF" then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T7F and FIFO_REQ = '1' then
            VA_S(10) <= '0';
            VA_S(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR + "100");
            BA_S <= FIFO_BA;
        elsif DDR_STATE = DS_T7F then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T9F and FIFO_REQ = '1' and VIDEO_ADR_CNT(7 DOWNTO 0) = x"FF" then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T9F and FIFO_REQ = '1' then
            VA_P(10) <= '0';
            VA_P(9 DOWNTO 0) <= std_logic_vector(FIFO_COL_ADR + "100");
            BA_P <= FIFO_BA;
        elsif DDR_STATE = DS_T9F then
            VA_S(10) <= '1';
        elsif DDR_STATE = DS_T10F and fb_wr_n = '0' and DATA_IN(13 DOWNTO 12) = FIFO_BA then
            VA_S(10) <= '1';
            DDR_ACCESS <= CPU;
        elsif DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 DOWNTO 12) = FIFO_BA then
            VA_S(10) <= '1';
            DDR_ACCESS <= CPU;
        elsif DDR_STATE = DS_T10F then
            SR_FIFO_WRE_I <= '1';
        elsif DDR_STATE = DS_C6 then
            VA_S <= DATA_IN(12 DOWNTO 0);
            BA_S <= DATA_IN(14 DOWNTO 13);
        elsif DDR_STATE = DS_CB6 then
            FIFO_BANK_OK <= '0';
        elsif DDR_STATE = DS_CB8 then
            FIFO_BANK_OK <= '0';
        elsif DDR_STATE = DS_R2 then
            FIFO_BANK_OK <= '0';
        else
        end if;
    end process P_CLK0;

    DDR_SEL <= '1' when FB_ALE = '1' and DATA_IN(31 DOWNTO 30) = "01" else '0';

    P_DDR_CS: process
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if FB_ALE = '1' then
            DDR_CS <= DDR_SEL;
        end if;
    end process P_DDR_CS;
    
    P_CPU_REQ: process
    begin
        wait until DDR_SYNC_66M = '1' and DDR_SYNC_66M' event;
        if DDR_SEL = '1' and fb_wr_n = '1' and DDR_CONFIG = '0' then
            CPU_REQ <= '1';
        elsif DDR_SEL = '1' and FB_SIZE1 = '0' and FB_SIZE1 = '0' and DDR_CONFIG = '0' then -- Start when not config and not long word access.
            CPU_REQ <= '1';
        elsif DDR_SEL = '1' and FB_SIZE1 = '0' and FB_SIZE1 = '1' and DDR_CONFIG = '0' then -- Start when not config and not long word access.
            CPU_REQ <= '1';
        elsif DDR_SEL = '1' and FB_SIZE1 = '1' and FB_SIZE1 = '0' and DDR_CONFIG = '0' then -- Start when not config and not long word access.
            CPU_REQ <= '1';
        elsif DDR_SEL = '1' and DDR_CONFIG = '1' then -- Config, start immediately.
            CPU_REQ <= '1';
        elsif FB_REGDDR = FR_S1 and fb_wr_n = '0' then -- Long word write later.
            CPU_REQ <= '1';
        elsif FB_REGDDR /= FR_S1 and FB_REGDDR /= FR_S3 and BUS_CYC_END = '0' and BUS_CYC = '0' then -- Halt, bus cycle IN progress or ready.
            CPU_REQ <= '0';
        end if;
    end process P_CPU_REQ;
    
    P_REFRESH: process
    -- Refresh: Always 8 at a time every 7.8us.
    -- 7.8us x 8 = 62.4us = 2059 -> 2048 @ 33MHz.
    begin
        wait until CLK_33M = '1' and CLK_33M' event;
        DDR_REFRESH_CNT <= DDR_REFRESH_CNT + 1; -- Count 0 to 2047.
    end process P_REFRESH;

    SR_FIFO_WRE <= SR_FIFO_WRE_I;
    
    VA <=   DATA_IN(26 DOWNTO 14) when DDR_STATE = DS_T2A and DDR_SEL = '1' and fb_wr_n = '0' else
            DATA_IN(26 DOWNTO 14) when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
            VA_P when DDR_STATE = DS_T2A else
            DATA_IN(26 DOWNTO 14) when DDR_STATE = DS_T10F and fb_wr_n = '0' and DATA_IN(13 DOWNTO 12) = FIFO_BA else
            DATA_IN(26 DOWNTO 14) when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 DOWNTO 12) = FIFO_BA else
            VA_P when DDR_STATE = DS_T10F else
            "0010000000000" when DDR_STATE = DS_R2 and DDR_REFRESH_SIG = x"9" else VA_S;

    BA <=   DATA_IN(13 DOWNTO 12) when DDR_STATE = DS_T2A and DDR_SEL = '1' and fb_wr_n = '0' else
            DATA_IN(13 DOWNTO 12) when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
            BA_P when DDR_STATE = DS_T2A else
            DATA_IN(13 DOWNTO 12) when DDR_STATE = DS_T10F and fb_wr_n = '0' and DATA_IN(13 DOWNTO 12) = FIFO_BA else
            DATA_IN(13 DOWNTO 12) when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 DOWNTO 12) = FIFO_BA else
            BA_P when DDR_STATE = DS_T10F else BA_S;
            
    VRAS <= '1' when DDR_STATE = DS_T2A and DDR_SEL = '1' and fb_wr_n = '0' else
            '1' when DDR_STATE = DS_T2A and DDR_SEL = '1' and (FB_SIZE0 = '0' or FB_SIZE1= '0') else
            '1' when DDR_STATE = DS_T2A and DDR_ACCESS = FIFO and FIFO_REQ = '1' else
            '1' when DDR_STATE = DS_T2A and DDR_ACCESS = BLITTER and BLITTER_REQ = '1' else
            '1' when DDR_STATE = DS_T2B else
            '1' when DDR_STATE = DS_T10F and fb_wr_n = '0' and DATA_IN(13 DOWNTO 12) = FIFO_BA else
            '1' when DDR_STATE = DS_T10F and (FB_SIZE0 = '0' or FB_SIZE1= '0') and DATA_IN(13 DOWNTO 12) = FIFO_BA else
DATA_IN(18) and not fb_wr_n and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
            '1' when DDR_STATE = DS_CB6 else
            '1' when DDR_STATE = DS_CB8 else
            '1' when DDR_STATE = DS_R2 else '0';

    VCAS <= '1' when DDR_STATE = DS_T4R else
            '1' when DDR_STATE = DS_T6W else
            '1' when DDR_STATE = DS_T4F else
            '1' when DDR_STATE = DS_T6F else
            '1' when DDR_STATE = DS_T8F else
            '1' when DDR_STATE = DS_T10F and VRAS = '0' else
            DATA_IN(17) and not fb_wr_n and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
            '1' when DDR_STATE = DS_R2 and DDR_REFRESH_SIG /= x"9" else '0';

    VWE <= '1' when DDR_STATE = DS_T6W else
            DATA_IN(16) and not fb_wr_n and not FB_SIZE0 and not FB_SIZE1 when DDR_STATE = DS_C7 else
            '1' when DDR_STATE = DS_CB6 else
            '1' when DDR_STATE = DS_CB8 else
            '1' when DDR_STATE = DS_R2 and DDR_REFRESH_SIG = x"9" else '0';

    -- DDR controller:
    -- VIDEO RAM CONTROL REGISTER (is in VIDEO_MUX_CTR) 
    -- $F0000400:
    --      BIT 0: VCKE
    --      BIT 1: not nVCS
    --      BIT 2: REFRESH ON , (0=FIFO and CNT CLEAR); 
    --      BIT 3: CONFIG
    --      BIT 8: FIFO_ACTIVE; 
    VCKE <= VCKE_I;
    VCKE_I <= vram_control(0);
    vcs_n <= VCS_In;
    VCS_In <= not vram_control(1);
    DDR_REFRESH_ON <= vram_control(2);
    DDR_CONFIG <= vram_control(3);
    FIFO_ACTIVE <= vram_control(8);

    CPU_ROW_ADR <= FB_ADR(26 DOWNTO 14);
    CPU_BA <= FB_ADR(13 DOWNTO 12);
    CPU_COL_ADR <= FB_ADR(11 DOWNTO 2);
    vras_n <= not VRAS;
    vcas_n <= not VCAS;
    vwe_n <= not VWE;

    DDRWR_D_SEL1 <= '1' when DDR_ACCESS = BLITTER else '0';

    BLITTER_ROW_ADR <= BLITTER_ADR(26 DOWNTO 14);
    BLITTER_BA <= BLITTER_ADR(13 DOWNTO 12);
    BLITTER_COL_ADR <= BLITTER_ADR(11 DOWNTO 2);

    FIFO_ROW_ADR <= std_logic_vector(VIDEO_ADR_CNT(22 DOWNTO 10));
    FIFO_BA <= std_logic_vector(VIDEO_ADR_CNT)(9 DOWNTO 8);
    FIFO_COL_ADR <= VIDEO_ADR_CNT(7 DOWNTO 0) & "00";

    VIDEO_BASE_ADR(22 DOWNTO 20) <= VIDEO_BASE_X_D;
    VIDEO_BASE_ADR(19 DOWNTO 12) <= VIDEO_BASE_H_D;
    VIDEO_BASE_ADR(11 DOWNTO 4)  <= VIDEO_BASE_M_D;
    VIDEO_BASE_ADR(3 DOWNTO 0)   <= VIDEO_BASE_L_D(7 DOWNTO 4);

    VDM_SEL <= VDM_SEL_I;
    VDM_SEL_I <= VIDEO_BASE_L_D(3 DOWNTO 0);

    -- Current video address:
    VIDEO_ACT_ADR(26 DOWNTO 4) <= std_logic_vector(VIDEO_ADR_CNT - unsigned(FIFO_MW));
    VIDEO_ACT_ADR(3 DOWNTO 0) <= VDM_SEL_I;

    P_VIDEO_REGS: process
    -- Video registers.
    begin
        wait until CLK_MAIN = '1' and CLK_MAIN' event;
        if VIDEO_BASE_L = '1' and fb_wr_n = '0' and BYTE_SEL(1) = '1' then
            VIDEO_BASE_L_D <= DATA_IN(23 DOWNTO 16); -- 16 byte boarders.
        end if;
          
        if VIDEO_BASE_M = '1' and fb_wr_n = '0' and BYTE_SEL(3) = '1' then
            VIDEO_BASE_M_D <= DATA_IN(23 DOWNTO 16);
        end if;

        if VIDEO_BASE_H = '1' and fb_wr_n = '0' and BYTE_SEL(1) = '1' then
            VIDEO_BASE_H_D <= DATA_IN(23 DOWNTO 16);
        end if;

        if VIDEO_BASE_H = '1' and fb_wr_n = '0' and BYTE_SEL(0) = '1' then
            VIDEO_BASE_X_D <= DATA_IN(26 DOWNTO 24);
        end if;
    end process P_VIDEO_REGS;

    FB_ADR_I <= FB_ADR & '0';

    VIDEO_BASE_L <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"820D" else '0'; -- x"FF820D".
    VIDEO_BASE_M <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"8204" else '0'; -- x"FF8203". 
    VIDEO_BASE_H <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"8202" else '0'; -- x"FF8201".

    VIDEO_CNT_L <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"8208" else '0'; -- x"FF8209".
    VIDEO_CNT_M <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"8206" else '0'; -- x"FF8207". 
    VIDEO_CNT_H <= '1' when fb_cs1_n = '0' and FB_ADR_I(15 DOWNTO 0) = x"8204" else '0'; -- x"FF8205".

    DATA_OUT(31 DOWNTO 24) <= "00000" & VIDEO_BASE_X_D when VIDEO_BASE_H = '1' else
                              "00000" & VIDEO_ACT_ADR(26 DOWNTO 24) when VIDEO_CNT_H = '1' else (others => '0');

    DATA_EN_H <= (VIDEO_BASE_H or VIDEO_CNT_H) and not fb_oe_n;

    DATA_OUT(23 DOWNTO 16) <= VIDEO_BASE_L_D when VIDEO_BASE_L = '1' else
                              VIDEO_BASE_M_D when VIDEO_BASE_M = '1' else
                              VIDEO_BASE_H_D when VIDEO_BASE_H = '1' else
                              VIDEO_ACT_ADR(7 DOWNTO 0) when VIDEO_CNT_L = '1' else
                              VIDEO_ACT_ADR(15 DOWNTO 8) when VIDEO_CNT_M = '1' else
                              VIDEO_ACT_ADR(23 DOWNTO 16) when VIDEO_CNT_H = '1' else (others => '0');
                      
    DATA_EN_L <= (VIDEO_BASE_L or VIDEO_BASE_M or VIDEO_BASE_H or VIDEO_CNT_L or VIDEO_CNT_M or VIDEO_CNT_H) and not fb_oe_n;
end architecture BEHAVIOUR;
-- VA           : Video DDR address multiplexed.
-- VA_P         : latched VA, wenn FIFO_AC, BLITTER_AC.
-- VA_S         : latch for default VA.
-- BA           : Video DDR bank address multiplexed.
-- BA_P         : latched BA, wenn FIFO_AC, BLITTER_AC.
-- BA_S         : latch for default BA.
--
--FB_SIZE ersetzen.
