----------------------------------------------------------------------
----                                                              ----
---- This file is part of the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the DMA controller of the 'Firebee'----
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FBEE_DMA is
    port(
        RESET                       : in std_logic;
        CLK_MAIN                    : in std_logic;
        CLK_FDC                     : in std_logic;

        FB_ADR                      : in std_logic_vector(26 downto 0);
        FB_ALE                      : in std_logic;
        FB_SIZE                     : in std_logic_vector(1 downto 0);
        FB_CSn                      : in std_logic_vector(2 downto 1);
        FB_OEn                      : in std_logic;
        FB_WRn                      : in std_logic;
        FB_AD_IN                    : in std_logic_vector(31 downto 0);
        FB_AD_OUT                   : out std_logic_vector(31 downto 0);
        FB_AD_EN_31_24              : out std_logic;
        FB_AD_EN_23_16              : out std_logic;
        FB_AD_EN_15_8               : out std_logic;
        FB_AD_EN_7_0                : out std_logic;

        ACSI_DIR                    : out std_logic;
        ACSI_D_IN                   : in std_logic_vector(7 downto 0);
        ACSI_D_OUT                  : out std_logic_vector(7 downto 0);
        ACSI_D_EN                   : out std_logic;
        ACSI_CSn                    : out std_logic;
        ACSI_A1                     : out std_logic;
        ACSI_RESETn                 : out std_logic;
        ACSI_DRQn                   : in std_logic;
        ACSI_ACKn                   : out std_logic;

        DATA_IN_FDC                 : in std_logic_vector(7 downto 0);
        DATA_IN_SCSI                : in std_logic_vector(7 downto 0);
        DATA_OUT_FDC_SCSI			: out std_logic_vector(7 downto 0);

        DMA_DRQ_IN                  : in std_logic; -- From 1772.
        DMA_DRQ_OUT                 : out std_logic; -- To Interrupt handler.
        DMA_DRQ11                   : out std_logic; -- To MFP.
        
        SCSI_DRQ                    : in std_logic;
        SCSI_DACKn                  : out std_logic;
        SCSI_INT                    : in std_logic;
        SCSI_CSn                    : out std_logic;
        SCSI_CS                     : out std_logic;

        CA                          : out std_logic_vector(2 downto 0);
        FLOPPY_HD_DD                : in std_logic;
        WDC_BSL0                    : out std_logic;
        FDC_CSn                     : out std_logic;
        FDC_WRn                     : out std_logic;
        FD_INT                      : in std_logic;
        IDE_INT                     : in std_logic;
        DMA_CS                      : out std_logic
    );
end entity FBEE_DMA;

architecture BEHAVIOUR of FBEE_DMA is
	component dcfifo0 is
		port(
			aclr		: in std_logic  := '0';
			data		: in std_logic_vector (7 downto 0);
			rdclk		: in std_logic ;
			rdreq		: in std_logic ;
			wrclk		: in std_logic ;
			wrreq		: in std_logic ;
			q		    : out std_logic_vector (31 downto 0);
			wrusedw		: out std_logic_vector (9 downto 0)
		);
	end component;
	
	component dcfifo1 is
		port(
			aclr		: in std_logic  := '0';
			data		: in std_logic_vector (31 downto 0);
			rdclk		: in std_logic ;
			rdreq		: in std_logic ;
			wrclk		: in std_logic ;
			wrreq		: in std_logic ;
			q		    : out std_logic_vector (7 downto 0);
			rdusedw		: out std_logic_vector (9 downto 0)
		);
	end component;
	
	type FCF_STATES is(	FCF_IDLE, FCF_T0, FCF_T1, FCF_T2, FCF_T3, FCF_T6, FCF_T7);
	signal FCF_STATE			: FCF_STATES;
	signal NEXT_FCF_STATE		: FCF_STATES;
	signal FCF_CS				: std_logic;
	signal FCF_APH				: std_logic;
	
	signal DMA_MODE_CS			: std_logic;
	signal DMA_DATA_CS			: std_logic;
	signal DMA_MODE				: std_logic_vector(15 downto 0);
	signal DMA_DRQQ				: std_logic;
	signal DMA_DRQ11_I          : std_logic;
	signal DMA_REQ				: std_logic;
	signal DMA_ACTIVE			: std_logic;
	signal DMA_ACTIVE_NEW		: std_logic;
	signal DMA_DRQ_REG			: std_logic_vector(1 downto 0);
	signal DMA_STATUS			: std_logic_vector(2 downto 0);
	signal DMA_AZ_CS			: std_logic;
	
	signal DMA_BYTECNT_CS		: std_logic;
	signal DMA_DIRECT_CS		: std_logic;
	signal DMA_TOP_CS			: std_logic;
	signal DMA_HIGH_CS			: std_logic;
	signal DMA_MID_CS			: std_logic;
	signal DMA_LOW_CS			: std_logic;
	signal DMA_ADR_CS			: std_logic;
	signal DMA_BYTECNT			: std_logic_vector(31 downto 0);
	signal DMA_TOP				: std_logic_vector(7 downto 0);
	signal DMA_HIGH				: std_logic_vector(7 downto 0);
	signal DMA_MID				: std_logic_vector(7 downto 0);
	signal DMA_LOW				: std_logic_vector(7 downto 0);
	
	signal DMA_SND_CS			: std_logic;
	signal SNDMACTL				: std_logic_vector(7 downto 0);
	signal SNDBASHI				: std_logic_vector(7 downto 0);
	signal SNDBASMI				: std_logic_vector(7 downto 0);
	signal SNDBASLO				: std_logic_vector(7 downto 0);
	signal SNDADRHI				: std_logic_vector(7 downto 0);
	signal SNDADRMI				: std_logic_vector(7 downto 0);
	signal SNDADRLO				: std_logic_vector(7 downto 0);
	signal SNDENDHI				: std_logic_vector(7 downto 0);
	signal SNDENDMI				: std_logic_vector(7 downto 0);
	signal SNDENDLO				: std_logic_vector(7 downto 0);
	signal SNDMODE				: std_logic_vector(7 downto 0);
	
	signal WDC_BSL				: std_logic_vector(1 downto 0);
	signal FDC_CS_In			: std_logic;
	signal CLR_FIFO				: std_logic;
	signal FDC_OUT				: std_logic_vector(7 downto 0);
	signal RDF_DIN				: std_logic_vector(7 downto 0);
	signal RDF_DOUT				: std_logic_vector(31 downto 0);
	signal RDF_AZ				: std_logic_vector(9 downto 0);
	signal RDF_RDE				: std_logic;
	signal RDF_WRE				: std_logic;
	signal WRF_DATA_OUT			: std_logic_vector(7 downto 0);
	signal WRF_AZ				: std_logic_vector(9 downto 0);
	signal WRF_RDE				: std_logic;
	signal WRF_WRE				: std_logic;
	signal WDC_BSL_CS           : std_logic;
	signal CA_I                 : std_logic_vector(2 downto 0);
	signal FDC_CS               : std_logic;
	signal SCSI_CS_I            : std_logic;
	signal LONG                 : std_logic;
	signal BYTE                 : std_logic;
	signal FB_B1                : std_logic;
	signal FB_B0                : std_logic;
	signal WRF_DOUT				: std_logic_vector(7 downto 0);
	signal FB_AD_I              : std_logic_vector(7 downto 0);
  signal d : std_logic_vector(31 downto 0);
begin
    LONG <= '1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '0' else '0';
    BYTE <= '1' when FB_SIZE(1) = '0' and FB_SIZE(0) = '1' else '0';
    FB_B0 <= '1' when FB_ADR(0) = '0' or BYTE = '0' else '0';
    FB_B1 <= '1' when FB_ADR(0) = '1' or BYTE = '0' else '0';

    FB_AD_OUT(31 downto 24) <= DMA_TOP  when DMA_TOP_CS = '1'  and FB_OEn = '0' else
                           x"00" when DMA_DATA_CS = '1' and FB_OEn = '0' else
                           DMA_TOP when DMA_ADR_CS = '1'  and FB_OEn = '0' else
                           DMA_BYTECNT(31 downto 24) when DMA_BYTECNT_CS = '1'  and FB_OEn = '0' else
                           DMA_MODE(15 downto 8) when DMA_DIRECT_CS = '1' and FB_OEn = '0' else
                           x"00" when DMA_MODE_CS = '1' and FB_OEn = '0' else
                           DMA_DRQ11_I & DMA_DRQ_REG & IDE_INT & FD_INT & SCSI_INT & RDF_AZ(9 downto 8) when DMA_AZ_CS = '1' and FB_OEn = '0' else
                           RDF_DOUT(7 downto 0) when FCF_CS = '1' and FB_OEn = '0' else x"00";

    FB_AD_OUT(23 downto 16) <= "00000" & DMA_STATUS when DMA_MODE_CS = '1' and FB_OEn = '0' else
                               FDC_OUT when DMA_DATA_CS = '1' and DMA_MODE(4 downto 3) = "00" and FB_OEn = '0' else
                               DATA_IN_SCSI when DMA_DATA_CS = '1' and DMA_MODE(4 downto 3) = "01" and FB_OEn = '0' else 
                               DMA_BYTECNT(16 downto 9) when DMA_DATA_CS = '1' and DMA_MODE(4) = '1' and FB_OEn = '0' else
                               "0000" & (not DMA_STATUS(1)) & "0" & WDC_BSL(1) & FLOPPY_HD_DD when WDC_BSL_CS = '1' and FB_OEn = '0' else
                               RDF_AZ(7 downto 0) when DMA_AZ_CS = '1' and FB_OEn = '0' else
                               SNDMACTL when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"0" and FB_OEn = '0' else
                               SNDBASHI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"1" and FB_OEn = '0' else
                               SNDBASMI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"2" and FB_OEn = '0' else
                               SNDBASLO when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"3" and FB_OEn = '0' else
                               SNDADRHI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"4" and FB_OEn = '0' else
                               SNDADRMI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"5" and FB_OEn = '0' else
                               SNDADRLO when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"6" and FB_OEn = '0' else
                               SNDENDHI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"7" and FB_OEn = '0' else
                               SNDENDMI when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"8" and FB_OEn = '0' else
                               SNDENDLO when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"9" and FB_OEn = '0' else
                               SNDMODE when DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"10" and FB_OEn = '0' else
                               DMA_HIGH when DMA_HIGH_CS = '1' and FB_OEn = '0' else
                               DMA_MID  when DMA_MID_CS = '1'  and FB_OEn = '0' else
                               DMA_LOW  when DMA_LOW_CS = '1'  and FB_OEn = '0' else
                               DMA_MODE(7 downto 0) when DMA_DIRECT_CS = '1' and FB_OEn = '0' else
                               DMA_HIGH when DMA_ADR_CS = '1'  and FB_OEn = '0' else
                               DMA_BYTECNT(23 downto 16) when DMA_BYTECNT_CS = '1'  and FB_OEn = '0' else
                               RDF_DOUT(15 downto 8) when FCF_CS = '1' and FB_OEn = '0' else x"00";

    FB_AD_OUT(15 downto 8) <= "0" & DMA_STATUS & "00" & WRF_AZ(9 downto 8) when DMA_AZ_CS = '1' and FB_OEn = '0' else
                          DMA_MID when DMA_ADR_CS = '1'  and FB_OEn = '0' else
                          DMA_BYTECNT(15 downto 8) when DMA_BYTECNT_CS = '1'  and FB_OEn = '0' else
                          RDF_DOUT(23 downto 16) when FCF_CS = '1' and FB_OEn = '0' else x"00";

    FB_AD_OUT(7 downto 0) <= WRF_AZ(7 downto 0) when DMA_AZ_CS = '1' and FB_OEn = '0' else
                         DMA_LOW when DMA_ADR_CS = '1' and FB_OEn = '0' else
                         DMA_BYTECNT(7 downto 0) when DMA_BYTECNT_CS = '1'  and FB_OEn = '0' else
                         RDF_DOUT(31 downto 24) when FCF_CS = '1' and FB_OEn = '0' else x"00";

    FB_AD_EN_31_24 <= (DMA_TOP_CS or DMA_DATA_CS or DMA_ADR_CS or DMA_BYTECNT_CS or DMA_DIRECT_CS or
                       DMA_MODE_CS or DMA_AZ_CS or FCF_CS) and not FB_OEn;

    FB_AD_EN_23_16 <= (DMA_MODE_CS or DMA_DATA_CS or WDC_BSL_CS or DMA_AZ_CS or DMA_SND_CS or DMA_HIGH_CS or
                       DMA_MID_CS or DMA_LOW_CS or DMA_DIRECT_CS or DMA_ADR_CS or DMA_BYTECNT_CS or FCF_CS) and not FB_OEn;

    FB_AD_EN_15_8 <= (DMA_AZ_CS or DMA_ADR_CS or DMA_BYTECNT_CS or FCF_CS) and not FB_OEn;

    FB_AD_EN_7_0 <= (DMA_AZ_CS or DMA_ADR_CS or DMA_BYTECNT_CS or FCF_CS) and not FB_OEn;

    INBUFFER: process(CLK_MAIN)
	begin
		if rising_edge(CLK_MAIN) then
			if FB_WRn = '0' THEN
				FB_AD_I <= FB_AD_IN(23 downto 16); 
			end if;
		end if;
	end process INBUFFER;

    -- ACSI is currently disabled.
    ACSI_DIR <= '0';
    ACSI_D_OUT <= x"00";
    ACSI_D_EN <= '0';
    ACSI_CSn <= '1';
    ACSI_A1 <= CA_I(1);
    ACSI_RESETn <= not RESET;
    ACSI_ACKn <= '1';

    SCSI_CS <= SCSI_CS_I;

    DMA_MODE_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C303" else '0';						-- F8606/2
    DMA_DATA_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C302" else '0';						-- F8604/2 
    FDC_CS   <= '1' when DMA_DATA_CS = '1' and DMA_MODE(4 downto 3) = "00" and FB_B1 = '1' else '0';
    SCSI_CS_I  <= '1' when DMA_DATA_CS = '1' and DMA_MODE(4 downto 3) = "01" and FB_B1 = '1' else '0';
    DMA_AZ_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(26 downto 0) = 27x"002010C" else '0'; -- F002'010C LONG
    DMA_TOP_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C304" and FB_B0 = '1' else '0'; -- F8608/2
    DMA_HIGH_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C304" and FB_B1 = '1' else '0'; -- F8609/2		
    DMA_MID_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C305" and FB_B1 = '1' else '0'; -- F860B/2		
    DMA_LOW_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C306" and FB_B1 = '1' else '0'; -- F860D/2	
    DMA_DIRECT_CS <= '1' when FB_CSn(2) = '0' and FB_ADR(26 downto 0) = 27x"20100" else '0'; -- F002'0100 WORD 
    DMA_ADR_CS  <= '1' when FB_CSn(2) = '0' and FB_ADR(26 downto 0) = 27x"20104" else '0'; -- F002'0104 LONG 
    DMA_BYTECNT_CS  <= '1' when FB_CSn(2) = '0' and FB_ADR(26 downto 0) = 27x"20108" else '0'; -- F002'0108 LONG 
    DMA_SND_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(20 downto 6) = 15x"3E24" else '0'; -- F8900-F893F
    FCF_CS  <= '1' when FB_CSn(2) = '0' and FB_ADR(26 downto 0) = 27x"0020110" and LONG = '1' else '0'; -- F002'0110 LONG ONLY
    DMA_CS <= FCF_CS or DMA_MODE_CS or DMA_SND_CS or DMA_ADR_CS or DMA_DIRECT_CS or DMA_BYTECNT_CS;
    WDC_BSL_CS <= '1' when FB_CSn(1) = '0' and FB_ADR(19 downto 1) = 19x"7C307" else '0';						-- F860E/2

    FCF_APH <= '1' when FB_ALE = '1' and FB_AD_IN(31 downto 0) = x"F0020110" and LONG = '1' else '0'; -- ADRESSPHASE F0020110 LONG ONLY

    RDF_DIN <= DATA_IN_FDC when DMA_MODE(7) = '1' else DATA_IN_SCSI;
    RDF_RDE <= '1' when FCF_APH = '1' and FB_WRn = '1' else '0';										-- AKTIVIEREN IN ADRESSPHASE

    DATA_OUT_FDC_SCSI <=  WRF_DOUT when DMA_ACTIVE = '1' and DMA_MODE(8) = '1' else FB_AD_I; 							-- BEI DMA WRITE <-FIFO SONST <-FB

    CA_I(0) <= '1' when DMA_ACTIVE = '1' else DMA_MODE(0);
    CA_I(1) <= '1' when DMA_ACTIVE = '1' else DMA_MODE(1);
    CA_I(2) <= '1' when DMA_ACTIVE = '1' else DMA_MODE(2);
    CA <= CA_I;
    
    FDC_WRn <= (not DMA_MODE(8)) when DMA_ACTIVE = '1' else FB_WRn;
    
	DMA_MODE_REGISTER: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' then
			DMA_MODE <= x"0000";
		elsif rising_edge(CLK_MAIN) then
            if DMA_MODE_CS = '1' and FB_WRn = '0' and FB_B0 = '1' then
				DMA_MODE(15 downto 8) <= FB_AD_IN(31 downto 24);
            elsif DMA_MODE_CS = '1' and FB_WRn = '0' and FB_B1 = '1' then
				DMA_MODE(7 downto 0) <= FB_AD_IN(23 downto 16);
            end if;
		end if;
	end process DMA_MODE_REGISTER;

	BYTECOUNTER: process(RESET, CLR_FIFO, CLK_MAIN)
	begin
		if RESET = '1' or CLR_FIFO = '1' THEN
			DMA_BYTECNT <= x"00000000";											 
		elsif rising_edge(CLK_MAIN) then
            if DMA_DATA_CS = '1' and FB_WRn = '0' and DMA_MODE(4) = '1' and FB_B1 = '1' then
				DMA_BYTECNT(31 downto 17) <= "000000000000000";
				DMA_BYTECNT(16 downto 9) <= FB_AD_IN(23 downto 16);
				DMA_BYTECNT(8 downto 0) <= "000000000";
			elsif DMA_BYTECNT_CS = '1' and FB_WRn = '0' then
					DMA_BYTECNT <= FB_AD_IN;
			end if;
        end if;
	end process BYTECOUNTER;

	WDC_BSL_REG: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' THEN
			WDC_BSL <= "00";
		elsif rising_edge(CLK_MAIN) then
			if WDC_BSL_CS = '1' and FB_WRn = '0' and FB_B0 = '1' then
				WDC_BSL <= FB_AD_IN(25 downto 24);
			end if;
            WDC_BSL0 <= WDC_BSL(0);
		end if;
	end process WDC_BSL_REG;

-- Rausoptimieren?
    FDC_REG: process(RESET, CLK_FDC, FDC_CS_In)
	begin
		if RESET = '1' then
			FDC_OUT <= x"00";
		elsif rising_edge(CLK_FDC) then
            if FDC_CS_In = '0'  then
				FDC_OUT <= DATA_IN_FDC;
			end if;
        end if;
        FDC_CSn <= FDC_CS_In;
    end process FDC_REG;

	DMA_ADRESSREGISTERS: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' THEN
			DMA_TOP <= x"00";
			DMA_HIGH <= x"00";
			DMA_MID <= x"00";
			DMA_LOW <= x"00";
		elsif rising_edge(CLK_MAIN) then
            if FB_WRn = '0' and (DMA_TOP_CS = '1' or DMA_ADR_CS = '1') then
				DMA_TOP <= FB_AD_IN(31 downto 24);
			end if;
            if FB_WRn = '0' and (DMA_HIGH_CS = '1' or DMA_ADR_CS = '1') then
				DMA_HIGH <= FB_AD_IN(23 downto 16);
			end if;
			if FB_WRn = '0' and DMA_MID_CS = '1' then
				DMA_MID <= FB_AD_IN(23 downto 16);
			elsif FB_WRn = '0' and DMA_ADR_CS = '1' then
				DMA_MID <= FB_AD_IN(15 downto 8);
			end if;
			if FB_WRn = '0' and DMA_LOW_CS = '1' then
				DMA_LOW <= FB_AD_IN(23 downto 16);
			elsif FB_WRn = '0' and DMA_ADR_CS = '1' then
				DMA_LOW <= FB_AD_IN(7 downto 0);
			end if;
        end if;
	end process DMA_ADRESSREGISTERS;
    
    DMA_STATUS(0) <= '1'; -- DMA OK
    DMA_STATUS(1) <= '1' when DMA_BYTECNT /= x"00000000" and DMA_BYTECNT(31) = '0' else '0'; -- When byts and not negative.
    DMA_STATUS(2) <= '0' when DMA_DRQ_IN = '1' or SCSI_DRQ = '1' else '0'; 

    DMA_REQ <= '1' when ((DMA_DRQ_IN = '1' and DMA_MODE(7) = '1') or (SCSI_DRQ = '1' and DMA_MODE(7) = '0')) and DMA_STATUS(1) = '1' and DMA_MODE(6) = '0' and CLR_FIFO = '0' else '0';
    DMA_DRQ_OUT <= '1' when DMA_DRQ_REG = "11" and DMA_MODE(6) = '0' else '0';
    DMA_DRQQ <= '1' when DMA_STATUS(1) = '1' and DMA_MODE(8) = '0' and unsigned(RDF_AZ) > 15 and DMA_MODE(6) = '0' else
                '1' when DMA_STATUS(1) = '1' and DMA_MODE(8) = '1' and unsigned(WRF_AZ) < 512 and DMA_MODE(6) = '0' else '0';
    DMA_DRQ11_I <= '1' when DMA_DRQ_REG = "11" and DMA_MODE(6) = '0' else '0';
    DMA_DRQ11 <= DMA_DRQ11_I;
    
	SPIKEFILTER: process(RESET, CLK_FDC)
	begin
		if RESET = '1' THEN
			DMA_DRQ_REG <= "00";
		elsif rising_edge(CLK_FDC) then
			DMA_DRQ_REG(0) <= DMA_DRQQ;
			DMA_DRQ_REG(1) <= DMA_DRQ_REG(0) and DMA_DRQQ;
		end if;
	end process SPIKEFILTER;

	READ_FIFO: dcfifo0
		port map(
		aclr				=> CLR_FIFO,
		data				=> RDF_DIN,
		rdclk				=> CLK_MAIN,
		rdreq				=> RDF_RDE,
		wrclk				=> CLK_FDC,
		wrreq				=> RDF_WRE,
		q					=> RDF_DOUT,
		wrusedw				=> RDF_AZ
	);

	FIFO_WRITE_CTRL: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' THEN
			WRF_WRE <= '0';
		elsif rising_edge(CLK_MAIN) then
            if FCF_APH = '1' and FB_WRn = '0' then
                WRF_WRE <= '1';
            else
                WRF_WRE <= '0';
            end if;
        end if;
	end process FIFO_WRITE_CTRL;

  d <= FB_AD_IN(7 downto 0) & FB_AD_IN(15 downto 8) & FB_AD_IN(23 downto 16) & FB_AD_IN(31 downto 24);


    WRITE_FIFO: dcfifo1
		port map(
		aclr				=> CLR_FIFO,
		data				=> d,
		rdclk				=> CLK_FDC,
		rdreq				=> WRF_RDE,
		wrclk				=> CLK_MAIN,
		wrreq				=> WRF_WRE,
		q					=> WRF_DOUT,
		rdusedw				=> WRF_AZ
	);

	SOUNDREGS: process(RESET, CLK_MAIN)
	begin
		if RESET = '1' then
			SNDMACTL <= x"00";
            SNDBASHI <= x"00";
            SNDBASMI <= x"00";
            SNDBASLO <= x"00";
            SNDADRHI <= x"00";
            SNDADRMI <= x"00";
            SNDADRLO <= x"00";
            SNDENDHI <= x"00";
            SNDENDMI <= x"00";
            SNDENDLO <= x"00";
            SNDMODE <= x"00";
		elsif CLK_MAIN = '1' and CLK_MAIN' event then
            if DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"0" and FB_WRn = '0' and FB_B1 ='1' then
				SNDMACTL <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"1" and FB_WRn = '0' and FB_B1 ='1' then
                SNDBASHI <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"2" and FB_WRn = '0' and FB_B1 ='1' then
                SNDBASMI <= FB_AD_IN(23downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"3" and FB_WRn = '0' and FB_B1 ='1' then
                SNDBASLO <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"4" and FB_WRn = '0' and FB_B1 ='1' then
                SNDADRHI <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"5" and FB_WRn = '0' and FB_B1 ='1' then
                SNDADRMI <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"6" and FB_WRn = '0' and FB_B1 ='1' then
                SNDADRLO <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"7" and FB_WRn = '0' and FB_B1 ='1' then
                SNDENDHI <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"8" and FB_WRn = '0' and FB_B1 ='1' then
                SNDENDMI <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"9" and FB_WRn = '0' and FB_B1 ='1' then
                SNDENDLO <= FB_AD_IN(23 downto 16);
            elsif DMA_SND_CS = '1' and FB_ADR(5 downto 1) = 5x"10" and FB_WRn = '0' and FB_B1 ='1' then
                SNDMODE <= FB_AD_IN(23 downto 16);
			end if;
        end if;
    end process SOUNDREGS;

    CLEAR_BY_TOGGLE: process(RESET, CLK_MAIN, DMA_MODE)
    variable DMA_DIR_OLD : std_logic;
	begin
		if RESET = '1' THEN
			DMA_DIR_OLD := '0';
		elsif CLK_MAIN = '1' and CLK_MAIN' event then
            if DMA_MODE_CS = '0' then
				DMA_DIR_OLD := DMA_MODE(8);
			end if;
        end if;
        CLR_FIFO <= DMA_MODE(8) xor DMA_DIR_OLD;
	end process CLEAR_BY_TOGGLE;
 
    FCF_REG: process(RESET, CLK_FDC)
	begin
		if RESET = '1' then
			FCF_STATE <= FCF_IDLE;
			DMA_ACTIVE <= '0';
		elsif rising_edge(CLK_FDC) then
            FCF_STATE <= NEXT_FCF_STATE;
            DMA_ACTIVE <= DMA_ACTIVE_NEW;
        end if;
	end process FCF_REG;

	FCF_DECODER: process(FCF_STATE, DMA_REQ, FDC_CS, SCSI_CS_I, DMA_ACTIVE, DMA_MODE)
	begin
		case FCF_STATE is
			when FCF_IDLE =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				SCSI_DACKn <= '1';
				if DMA_REQ = '1' or FDC_CS = '1' or SCSI_CS_I = '1' then 	 
					DMA_ACTIVE_NEW <= DMA_REQ;
					NEXT_FCF_STATE <= FCF_T0;
				else
					DMA_ACTIVE_NEW <= '0';
					NEXT_FCF_STATE <= FCF_IDLE; 		 
				end if;
			when FCF_T0 =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				SCSI_DACKn <= '1';
				DMA_ACTIVE_NEW <= DMA_REQ;
				WRF_RDE <= DMA_MODE(8) and DMA_REQ; -- Write -> Read from FIFO
				if 	DMA_REQ = '0' and DMA_ACTIVE = '1' then -- Spike?
					NEXT_FCF_STATE <= FCF_IDLE; -- Yes -> Start
				else
					NEXT_FCF_STATE <= FCF_T1;
				end if;
			when FCF_T1 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				DMA_ACTIVE_NEW <= DMA_ACTIVE;
				SCSI_CSn <= not SCSI_CS_I;
				FDC_CS_In <= DMA_MODE(4) or DMA_MODE(3);
				SCSI_DACKn <= DMA_MODE(7) and DMA_ACTIVE;
				NEXT_FCF_STATE <= FCF_T2;
			when FCF_T2 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				DMA_ACTIVE_NEW <= DMA_ACTIVE;
				SCSI_CSn <= not SCSI_CS_I;
				FDC_CS_In <= DMA_MODE(4) or DMA_MODE(3);
				SCSI_DACKn <= DMA_MODE(7) and DMA_ACTIVE;
				NEXT_FCF_STATE <= FCF_T3;
			when FCF_T3 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				DMA_ACTIVE_NEW <= DMA_ACTIVE;
				SCSI_CSn <= not SCSI_CS_I;
				FDC_CS_In <= DMA_MODE(4) or DMA_MODE(3);
				SCSI_DACKn <= DMA_MODE(7) and DMA_ACTIVE;
				NEXT_FCF_STATE <= FCF_T6;
			when FCF_T6 =>
				WRF_RDE <= '0';
				DMA_ACTIVE_NEW <= DMA_ACTIVE;
				SCSI_CSn <= not SCSI_CS_I;
				FDC_CS_In <= DMA_MODE(4) or DMA_MODE(3);
				SCSI_DACKn <= DMA_MODE(7)  and DMA_ACTIVE;
				RDF_WRE <= not DMA_MODE(8) and DMA_ACTIVE; -- Read -> Write to FIFO
				NEXT_FCF_STATE <= FCF_T7;
			when FCF_T7 =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				SCSI_DACKn <= '1';
				DMA_ACTIVE_NEW <= '0';
				if FDC_CS = '1' and DMA_REQ = '0'  then 	 
					NEXT_FCF_STATE <= FCF_T7;
				else
					NEXT_FCF_STATE <= FCF_IDLE; 		 
				end if;
		end case;
	end process FCF_DECODER;
end architecture BEHAVIOUR;
