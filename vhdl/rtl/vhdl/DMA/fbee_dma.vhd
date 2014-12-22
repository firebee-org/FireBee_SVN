----------------------------------------------------------------------
----                                                              ----
---- ThIS file IS part of the 'Firebee' project.                  ----
---- http://acp.atari.ORg                                         ----
----                                                              ----
---- Description:                                                 ----
---- ThIS design unit provides the DMA controller of the 'Firebee'----
---- computer. It IS optimized fOR the use of an Altera Cyclone   ----
---- FPGA (EP3C40F484). ThIS IP-CORe IS based on the first edi-   ----
---- tion of the Firebee configware ORigINally provided by Fredi  ----
---- AshwANDen  AND Wolfgang Förster. ThIS release IS IN compa-   ----
---- rISion to the first edition completely written IN VHDL.      ----
----                                                              ----
---- AuthOR(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@INventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi AschwANDen, Wolfgang Förster        ----
----                                                              ----
---- ThIS source file IS free software; you can redIStribute it   ----
---- AND/OR modIFy it under the terms of the GNU General Public   ----
---- License as publIShed by the Free Software Foundation; either ----
---- version 2 of the License, OR (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- ThIS program IS dIStributed IN the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; withOUT even the implied   ----
---- warranty of MERCHANTABILITY OR FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License fOR mORe        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along with thIS program; IF NOT, write to the Free   ----
---- Software Foundation, Inc., 51 FranklIN Street, FIFth FloOR,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- RevISion HIStORy
-- 
-- RevISion 2K12B  20120801 WF
--   Initial Release of the second edition.

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.ALL;

ENTITY FBEE_DMA IS
    PORT(
        RESET                       : IN STD_LOGIC;
        CLK_MAIN                    : IN STD_LOGIC;
        CLK_FDC                     : IN STD_LOGIC;

        FB_ADR                      : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
        FB_ALE                      : IN STD_LOGIC;
        FB_SIZE                     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        fb_cs_n                      : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
        fb_oe_n                      : IN STD_LOGIC;
        FB_WRn                      : IN STD_LOGIC;
        FB_AD_IN                    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FB_AD_OUT                   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FB_AD_EN_31_24              : OUT STD_LOGIC;
        FB_AD_EN_23_16              : OUT STD_LOGIC;
        FB_AD_EN_15_8               : OUT STD_LOGIC;
        FB_AD_EN_7_0                : OUT STD_LOGIC;

        ACSI_DIR                    : OUT STD_LOGIC;
        ACSI_D_IN                   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        ACSI_D_OUT                  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ACSI_D_EN                   : OUT STD_LOGIC;
        ACSI_CSn                    : OUT STD_LOGIC;
        ACSI_A1                     : OUT STD_LOGIC;
        ACSI_RESETn                 : OUT STD_LOGIC;
        ACSI_DRQn                   : IN STD_LOGIC;
        ACSI_ACKn                   : OUT STD_LOGIC;

        DATA_IN_FDC                 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_IN_SCSI                : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_OUT_FDC_SCSI			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        DMA_DRQ_IN                  : IN STD_LOGIC; -- From 1772.
        DMA_DRQ_OUT                 : OUT STD_LOGIC; -- To Interrupt hANDler.
        DMA_DRQ11                   : OUT STD_LOGIC; -- To MFP.
        
        SCSI_DRQ                    : IN STD_LOGIC;
        SCSI_DACKn                  : OUT STD_LOGIC;
        SCSI_INT                    : IN STD_LOGIC;
        SCSI_CSn                    : OUT STD_LOGIC;
        SCSI_CS                     : OUT STD_LOGIC;

        CA                          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FLOPPY_HD_DD                : IN STD_LOGIC;
        WDC_BSL0                    : OUT STD_LOGIC;
        FDC_CSn                     : OUT STD_LOGIC;
        FDC_WRn                     : OUT STD_LOGIC;
        FD_INT                      : IN STD_LOGIC;
        IDE_INT                     : IN STD_LOGIC;
        DMA_CS                      : OUT STD_LOGIC
    );
END ENTITY FBEE_DMA;

ARCHITECTURE BEHAVIOUR of FBEE_DMA IS
	COMPONENT dcfIFo0 IS
		PORT(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			wrusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT dcfIFo1 IS
		PORT(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END COMPONENT;
	
	TYPE fcf_states_t IS (FCF_IDLE, FCF_T0, FCF_T1, FCF_T2, FCF_T3, FCF_T6, FCF_T7);
	SIGNAL fcf_state			: fcf_states_t;
	SIGNAL next_fcf_state		: fcf_states_t;
	SIGNAL fcf_cs				: STD_LOGIC;
	SIGNAL fcf_aph				: STD_LOGIC;
	
	SIGNAL dma_mode_cs			: STD_LOGIC;
	SIGNAL dma_data_cs			: STD_LOGIC;
	SIGNAL dma_mode				: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL dma_drqq				: STD_LOGIC;
	SIGNAL dma_drq11_i          : STD_LOGIC;
	SIGNAL dma_req				: STD_LOGIC;
	SIGNAL dma_active			: STD_LOGIC;
	SIGNAL dma_active_new		: STD_LOGIC;
	SIGNAL dma_drq_reg			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL dma_status			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL dma_az_cs			: STD_LOGIC;
	
	SIGNAL dma_bytecnt_cs		: STD_LOGIC;
	SIGNAL dma_direct_cs		: STD_LOGIC;
	SIGNAL dma_top_cs			: STD_LOGIC;
	SIGNAL dma_high_cs			: STD_LOGIC;
	SIGNAL dma_mid_cs			: STD_LOGIC;
	SIGNAL dma_low_cs			: STD_LOGIC;
	SIGNAL dma_adr_cs			: STD_LOGIC;
	SIGNAL dma_bytecnt			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL dma_top				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dma_high				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dma_mid				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dma_low				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL DMA_SND_CS			: STD_LOGIC;
	SIGNAL SNDMACTL				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDBASHI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDBASMI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDBASLO				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDADRHI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDADRMI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDADRLO				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDENDHI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDENDMI				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDENDLO				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SNDMODE				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL WDC_BSL				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL FDC_CS_In			: STD_LOGIC;
	SIGNAL CLR_FIFO				: STD_LOGIC;
	SIGNAL FDC_OUT				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL RDF_DIN				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL RDF_DOUT				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RDF_AZ				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL RDF_RDE				: STD_LOGIC;
	SIGNAL RDF_WRE				: STD_LOGIC;
	SIGNAL WRF_DATA_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL WRF_AZ				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL WRF_RDE				: STD_LOGIC;
	SIGNAL WRF_WRE				: STD_LOGIC;
	SIGNAL WDC_BSL_CS           : STD_LOGIC;
	SIGNAL CA_I                 : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL FDC_CS               : STD_LOGIC;
	SIGNAL SCSI_CS_I            : STD_LOGIC;
	SIGNAL LONG                 : STD_LOGIC;
	SIGNAL BYTE                 : STD_LOGIC;
	SIGNAL FB_B1                : STD_LOGIC;
	SIGNAL FB_B0                : STD_LOGIC;
	SIGNAL WRF_DOUT				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL FB_AD_I              : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL d : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    LONG <= '1' WHEN FB_SIZE(1) = '0' AND FB_SIZE(0) = '0' ELSE '0';
    BYTE <= '1' WHEN FB_SIZE(1) = '0' AND FB_SIZE(0) = '1' ELSE '0';
    FB_B0 <= '1' WHEN FB_ADR(0) = '0' OR BYTE = '0' ELSE '0';
    FB_B1 <= '1' WHEN FB_ADR(0) = '1' OR BYTE = '0' ELSE '0';

    FB_AD_OUT(31 DOWNTO 24) <= dma_top  WHEN dma_top_cs = '1'  AND fb_oe_n = '0' ELSE
                           x"00" WHEN dma_data_cs = '1' AND fb_oe_n = '0' ELSE
                           dma_top WHEN dma_adr_cs = '1'  AND fb_oe_n = '0' ELSE
                           dma_bytecnt(31 DOWNTO 24) WHEN dma_bytecnt_cs = '1'  AND fb_oe_n = '0' ELSE
                           dma_mode(15 DOWNTO 8) WHEN dma_direct_cs = '1' AND fb_oe_n = '0' ELSE
                           x"00" WHEN dma_mode_cs = '1' AND fb_oe_n = '0' ELSE
                           dma_drq11_i & dma_drq_reg & IDE_INT & FD_INT & SCSI_INT & RDF_AZ(9 DOWNTO 8) WHEN dma_az_cs = '1' AND fb_oe_n = '0' ELSE
                           RDF_DOUT(7 DOWNTO 0) WHEN fcf_cs = '1' AND fb_oe_n = '0' ELSE x"00";

    FB_AD_OUT(23 DOWNTO 16) <= "00000" & dma_status WHEN dma_mode_cs = '1' AND fb_oe_n = '0' ELSE
                               FDC_OUT WHEN dma_data_cs = '1' AND dma_mode(4 DOWNTO 3) = "00" AND fb_oe_n = '0' ELSE
                               DATA_IN_SCSI WHEN dma_data_cs = '1' AND dma_mode(4 DOWNTO 3) = "01" AND fb_oe_n = '0' ELSE 
                               dma_bytecnt(16 DOWNTO 9) WHEN dma_data_cs = '1' AND dma_mode(4) = '1' AND fb_oe_n = '0' ELSE
                               "0000" & (NOT dma_status(1)) & "0" & WDC_BSL(1) & FLOPPY_HD_DD WHEN WDC_BSL_CS = '1' AND fb_oe_n = '0' ELSE
                               RDF_AZ(7 DOWNTO 0) WHEN dma_az_cs = '1' AND fb_oe_n = '0' ELSE
                               SNDMACTL WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"0" AND fb_oe_n = '0' ELSE
                               SNDBASHI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"1" AND fb_oe_n = '0' ELSE
                               SNDBASMI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"2" AND fb_oe_n = '0' ELSE
                               SNDBASLO WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"3" AND fb_oe_n = '0' ELSE
                               SNDADRHI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"4" AND fb_oe_n = '0' ELSE
                               SNDADRMI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"5" AND fb_oe_n = '0' ELSE
                               SNDADRLO WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"6" AND fb_oe_n = '0' ELSE
                               SNDENDHI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"7" AND fb_oe_n = '0' ELSE
                               SNDENDMI WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"8" AND fb_oe_n = '0' ELSE
                               SNDENDLO WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"9" AND fb_oe_n = '0' ELSE
                               SNDMODE WHEN DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"10" AND fb_oe_n = '0' ELSE
                               dma_high WHEN dma_high_cs = '1' AND fb_oe_n = '0' ELSE
                               dma_mid  WHEN dma_mid_cs = '1'  AND fb_oe_n = '0' ELSE
                               dma_low  WHEN dma_low_cs = '1'  AND fb_oe_n = '0' ELSE
                               dma_mode(7 DOWNTO 0) WHEN dma_direct_cs = '1' AND fb_oe_n = '0' ELSE
                               dma_high WHEN dma_adr_cs = '1'  AND fb_oe_n = '0' ELSE
                               dma_bytecnt(23 DOWNTO 16) WHEN dma_bytecnt_cs = '1'  AND fb_oe_n = '0' ELSE
                               RDF_DOUT(15 DOWNTO 8) WHEN fcf_cs = '1' AND fb_oe_n = '0' ELSE x"00";

    FB_AD_OUT(15 DOWNTO 8) <= "0" & dma_status & "00" & WRF_AZ(9 DOWNTO 8) WHEN dma_az_cs = '1' AND fb_oe_n = '0' ELSE
                          dma_mid WHEN dma_adr_cs = '1'  AND fb_oe_n = '0' ELSE
                          dma_bytecnt(15 DOWNTO 8) WHEN dma_bytecnt_cs = '1'  AND fb_oe_n = '0' ELSE
                          RDF_DOUT(23 DOWNTO 16) WHEN fcf_cs = '1' AND fb_oe_n = '0' ELSE x"00";

    FB_AD_OUT(7 DOWNTO 0) <= WRF_AZ(7 DOWNTO 0) WHEN dma_az_cs = '1' AND fb_oe_n = '0' ELSE
                         dma_low WHEN dma_adr_cs = '1' AND fb_oe_n = '0' ELSE
                         dma_bytecnt(7 DOWNTO 0) WHEN dma_bytecnt_cs = '1'  AND fb_oe_n = '0' ELSE
                         RDF_DOUT(31 DOWNTO 24) WHEN fcf_cs = '1' AND fb_oe_n = '0' ELSE x"00";

    FB_AD_EN_31_24 <= (dma_top_cs OR dma_data_cs OR dma_adr_cs OR dma_bytecnt_cs OR dma_direct_cs OR
                       dma_mode_cs OR dma_az_cs OR fcf_cs) AND NOT fb_oe_n;

    FB_AD_EN_23_16 <= (dma_mode_cs OR dma_data_cs OR WDC_BSL_CS OR dma_az_cs OR DMA_SND_CS OR dma_high_cs OR
                       dma_mid_cs OR dma_low_cs OR dma_direct_cs OR dma_adr_cs OR dma_bytecnt_cs OR fcf_cs) AND NOT fb_oe_n;

    FB_AD_EN_15_8 <= (dma_az_cs OR dma_adr_cs OR dma_bytecnt_cs OR fcf_cs) AND NOT fb_oe_n;

    FB_AD_EN_7_0 <= (dma_az_cs OR dma_adr_cs OR dma_bytecnt_cs OR fcf_cs) AND NOT fb_oe_n;

    INBUFFER: PROCESS(CLK_MAIN)
	BEGIN
		IF RISING_EDGE(CLK_MAIN) THEN
			IF FB_WRn = '0' THEN
				FB_AD_I <= FB_AD_IN(23 DOWNTO 16); 
			END IF;
		END IF;
	END PROCESS INBUFFER;

    -- ACSI IS currently dISabled.
    ACSI_DIR <= '0';
    ACSI_D_OUT <= x"00";
    ACSI_D_EN <= '0';
    ACSI_CSn <= '1';
    ACSI_A1 <= CA_I(1);
    ACSI_RESETn <= NOT RESET;
    ACSI_ACKn <= '1';

    SCSI_CS <= SCSI_CS_I;

    dma_mode_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C303" ELSE '0';						-- F8606/2
    dma_data_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C302" ELSE '0';						-- F8604/2 
    FDC_CS   <= '1' WHEN dma_data_cs = '1' AND dma_mode(4 DOWNTO 3) = "00" AND FB_B1 = '1' ELSE '0';
    SCSI_CS_I  <= '1' WHEN dma_data_cs = '1' AND dma_mode(4 DOWNTO 3) = "01" AND FB_B1 = '1' ELSE '0';
    dma_az_cs <= '1' WHEN fb_cs_n(2) = '0' AND FB_ADR(26 DOWNTO 0) = 27x"002010C" ELSE '0'; -- F002'010C LONG
    dma_top_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C304" AND FB_B0 = '1' ELSE '0'; -- F8608/2
    dma_high_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C304" AND FB_B1 = '1' ELSE '0'; -- F8609/2		
    dma_mid_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C305" AND FB_B1 = '1' ELSE '0'; -- F860B/2		
    dma_low_cs <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C306" AND FB_B1 = '1' ELSE '0'; -- F860D/2	
    dma_direct_cs <= '1' WHEN fb_cs_n(2) = '0' AND FB_ADR(26 DOWNTO 0) = 27x"20100" ELSE '0'; -- F002'0100 WORD 
    dma_adr_cs  <= '1' WHEN fb_cs_n(2) = '0' AND FB_ADR(26 DOWNTO 0) = 27x"20104" ELSE '0'; -- F002'0104 LONG 
    dma_bytecnt_cs  <= '1' WHEN fb_cs_n(2) = '0' AND FB_ADR(26 DOWNTO 0) = 27x"20108" ELSE '0'; -- F002'0108 LONG 
    DMA_SND_CS <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(20 DOWNTO 6) = 15x"3E24" ELSE '0'; -- F8900-F893F
    fcf_cs  <= '1' WHEN fb_cs_n(2) = '0' AND FB_ADR(26 DOWNTO 0) = 27x"0020110" AND LONG = '1' ELSE '0'; -- F002'0110 LONG ONLY
    DMA_CS <= fcf_cs OR dma_mode_cs OR DMA_SND_CS OR dma_adr_cs OR dma_direct_cs OR dma_bytecnt_cs;
    WDC_BSL_CS <= '1' WHEN fb_cs_n(1) = '0' AND FB_ADR(19 DOWNTO 1) = 19x"7C307" ELSE '0';						-- F860E/2

    fcf_aph <= '1' WHEN FB_ALE = '1' AND FB_AD_IN(31 DOWNTO 0) = x"F0020110" AND LONG = '1' ELSE '0'; -- ADRESSPHASE F0020110 LONG ONLY

    RDF_DIN <= DATA_IN_FDC WHEN dma_mode(7) = '1' ELSE DATA_IN_SCSI;
    RDF_RDE <= '1' WHEN fcf_aph = '1' AND FB_WRn = '1' ELSE '0';										-- AKTIVIEREN IN ADRESSPHASE

    DATA_OUT_FDC_SCSI <=  WRF_DOUT WHEN dma_active = '1' AND dma_mode(8) = '1' ELSE FB_AD_I; 							-- BEI DMA WRITE <-FIFO SONST <-FB

    CA_I(0) <= '1' WHEN dma_active = '1' ELSE dma_mode(0);
    CA_I(1) <= '1' WHEN dma_active = '1' ELSE dma_mode(1);
    CA_I(2) <= '1' WHEN dma_active = '1' ELSE dma_mode(2);
    CA <= CA_I;
    
    FDC_WRn <= (NOT dma_mode(8)) WHEN dma_active = '1' ELSE FB_WRn;
    
	dma_mode_REGISTER: PROCESS(RESET, CLK_MAIN)
	BEGIN
		IF RESET = '1' THEN
			dma_mode <= x"0000";
		ELSIF RISING_EDGE(CLK_MAIN) THEN
            IF dma_mode_cs = '1' AND FB_WRn = '0' AND FB_B0 = '1' THEN
				dma_mode(15 DOWNTO 8) <= FB_AD_IN(31 DOWNTO 24);
            ELSIF dma_mode_cs = '1' AND FB_WRn = '0' AND FB_B1 = '1' THEN
				dma_mode(7 DOWNTO 0) <= FB_AD_IN(23 DOWNTO 16);
            END IF;
		END IF;
	END PROCESS dma_mode_REGISTER;

	BYTECOUNTER: PROCESS(RESET, CLR_FIFO, CLK_MAIN)
	BEGIN
		IF RESET = '1' OR CLR_FIFO = '1' THEN
			dma_bytecnt <= x"00000000";											 
		ELSIF RISING_EDGE(CLK_MAIN) THEN
            IF dma_data_cs = '1' AND FB_WRn = '0' AND dma_mode(4) = '1' AND FB_B1 = '1' THEN
				dma_bytecnt(31 DOWNTO 17) <= "000000000000000";
				dma_bytecnt(16 DOWNTO 9) <= FB_AD_IN(23 DOWNTO 16);
				dma_bytecnt(8 DOWNTO 0) <= "000000000";
			ELSIF dma_bytecnt_cs = '1' AND FB_WRn = '0' THEN
					dma_bytecnt <= FB_AD_IN;
			END IF;
        END IF;
	END PROCESS BYTECOUNTER;

	WDC_BSL_REG: PROCESS(RESET, CLK_MAIN)
	BEGIN
		IF RESET = '1' THEN
			WDC_BSL <= "00";
		ELSIF RISING_EDGE(CLK_MAIN) THEN
			IF WDC_BSL_CS = '1' AND FB_WRn = '0' AND FB_B0 = '1' THEN
				WDC_BSL <= FB_AD_IN(25 DOWNTO 24);
			END IF;
            WDC_BSL0 <= WDC_BSL(0);
		END IF;
	END PROCESS WDC_BSL_REG;

-- Rausoptimieren?
    FDC_REG: PROCESS(RESET, CLK_FDC, FDC_CS_In)
	BEGIN
		IF RESET = '1' THEN
			FDC_OUT <= x"00";
		ELSIF RISING_EDGE(CLK_FDC) THEN
            IF FDC_CS_In = '0'  THEN
				FDC_OUT <= DATA_IN_FDC;
			END IF;
        END IF;
        FDC_CSn <= FDC_CS_In;
    END PROCESS FDC_REG;

	DMA_ADRESSREGISTERS: PROCESS(RESET, CLK_MAIN)
	BEGIN
		IF RESET = '1' THEN
			dma_top <= x"00";
			dma_high <= x"00";
			dma_mid <= x"00";
			dma_low <= x"00";
		ELSIF RISING_EDGE(CLK_MAIN) THEN
            IF FB_WRn = '0' AND (dma_top_cs = '1' OR dma_adr_cs = '1') THEN
				dma_top <= FB_AD_IN(31 DOWNTO 24);
			END IF;
            IF FB_WRn = '0' AND (dma_high_cs = '1' OR dma_adr_cs = '1') THEN
				dma_high <= FB_AD_IN(23 DOWNTO 16);
			END IF;
			IF FB_WRn = '0' AND dma_mid_cs = '1' THEN
				dma_mid <= FB_AD_IN(23 DOWNTO 16);
			ELSIF FB_WRn = '0' AND dma_adr_cs = '1' THEN
				dma_mid <= FB_AD_IN(15 DOWNTO 8);
			END IF;
			IF FB_WRn = '0' AND dma_low_cs = '1' THEN
				dma_low <= FB_AD_IN(23 DOWNTO 16);
			ELSIF FB_WRn = '0' AND dma_adr_cs = '1' THEN
				dma_low <= FB_AD_IN(7 DOWNTO 0);
			END IF;
        END IF;
	END PROCESS DMA_ADRESSREGISTERS;
    
    dma_status(0) <= '1'; -- DMA OK
    dma_status(1) <= '1' WHEN dma_bytecnt /= x"00000000" AND dma_bytecnt(31) = '0' ELSE '0'; -- When byts AND NOT negative.
    dma_status(2) <= '0' WHEN DMA_DRQ_IN = '1' OR SCSI_DRQ = '1' ELSE '0'; 

    dma_req <= '1' WHEN ((DMA_DRQ_IN = '1' AND dma_mode(7) = '1') OR (SCSI_DRQ = '1' AND dma_mode(7) = '0')) AND dma_status(1) = '1' AND dma_mode(6) = '0' AND CLR_FIFO = '0' ELSE '0';
    DMA_DRQ_OUT <= '1' WHEN dma_drq_reg = "11" AND dma_mode(6) = '0' ELSE '0';
    dma_drqq <= '1' WHEN dma_status(1) = '1' AND dma_mode(8) = '0' AND unsigned(RDF_AZ) > 15 AND dma_mode(6) = '0' ELSE
                '1' WHEN dma_status(1) = '1' AND dma_mode(8) = '1' AND unsigned(WRF_AZ) < 512 AND dma_mode(6) = '0' ELSE '0';
    dma_drq11_i <= '1' WHEN dma_drq_reg = "11" AND dma_mode(6) = '0' ELSE '0';
    DMA_DRQ11 <= dma_drq11_i;
    
	SPIKEFILTER: PROCESS(RESET, CLK_FDC)
	BEGIN
		IF RESET = '1' THEN
			dma_drq_reg <= "00";
		ELSIF RISING_EDGE(CLK_FDC) THEN
			dma_drq_reg(0) <= dma_drqq;
			dma_drq_reg(1) <= dma_drq_reg(0) AND dma_drqq;
		END IF;
	END PROCESS SPIKEFILTER;

	READ_FIFO: dcfIFo0
		PORT MAP(
		aclr				=> CLR_FIFO,
		data				=> RDF_DIN,
		rdclk				=> CLK_MAIN,
		rdreq				=> RDF_RDE,
		wrclk				=> CLK_FDC,
		wrreq				=> RDF_WRE,
		q					=> RDF_DOUT,
		wrusedw				=> RDF_AZ
	);

	FIFO_WRITE_CTRL: PROCESS(RESET, CLK_MAIN)
	BEGIN
		IF RESET = '1' THEN
			WRF_WRE <= '0';
		ELSIF RISING_EDGE(CLK_MAIN) THEN
            IF fcf_aph = '1' AND FB_WRn = '0' THEN
                WRF_WRE <= '1';
            ELSE
                WRF_WRE <= '0';
            END IF;
        END IF;
	END PROCESS FIFO_WRITE_CTRL;

  d <= FB_AD_IN(7 DOWNTO 0) & FB_AD_IN(15 DOWNTO 8) & FB_AD_IN(23 DOWNTO 16) & FB_AD_IN(31 DOWNTO 24);


    WRITE_FIFO: dcfIFo1
		PORT MAP(
		aclr				=> CLR_FIFO,
		data				=> d,
		rdclk				=> CLK_FDC,
		rdreq				=> WRF_RDE,
		wrclk				=> CLK_MAIN,
		wrreq				=> WRF_WRE,
		q					=> WRF_DOUT,
		rdusedw				=> WRF_AZ
	);

	SOUNDREGS: PROCESS(RESET, CLK_MAIN)
	BEGIN
		IF RESET = '1' THEN
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
		ELSIF CLK_MAIN = '1' AND CLK_MAIN' event THEN
            IF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"0" AND FB_WRn = '0' AND FB_B1 ='1' THEN
				SNDMACTL <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"1" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDBASHI <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"2" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDBASMI <= FB_AD_IN(23DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"3" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDBASLO <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"4" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDADRHI <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"5" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDADRMI <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"6" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDADRLO <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"7" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDENDHI <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"8" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDENDMI <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"9" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDENDLO <= FB_AD_IN(23 DOWNTO 16);
            ELSIF DMA_SND_CS = '1' AND FB_ADR(5 DOWNTO 1) = 5x"10" AND FB_WRn = '0' AND FB_B1 ='1' THEN
                SNDMODE <= FB_AD_IN(23 DOWNTO 16);
			END IF;
        END IF;
    END PROCESS SOUNDREGS;

    CLEAR_BY_TOGGLE: PROCESS(RESET, CLK_MAIN, dma_mode)
        VARIABLE DMA_DIR_OLD : STD_LOGIC;
	BEGIN
		IF RESET = '1' THEN
			DMA_DIR_OLD := '0';
		ELSIF CLK_MAIN = '1' AND CLK_MAIN' event THEN
            IF dma_mode_cs = '0' THEN
				DMA_DIR_OLD := dma_mode(8);
			END IF;
        END IF;
        CLR_FIFO <= dma_mode(8) xOR DMA_DIR_OLD;
	END PROCESS CLEAR_BY_TOGGLE;
 
    FCF_REG: PROCESS(RESET, CLK_FDC)
	BEGIN
		IF RESET = '1' THEN
			fcf_state <= FCF_IDLE;
			dma_active <= '0';
		ELSIF RISING_EDGE(CLK_FDC) THEN
            fcf_state <= next_fcf_state;
            dma_active <= dma_active_new;
        END IF;
	END PROCESS FCF_REG;

	FCF_DECODER: PROCESS(fcf_state, dma_req, FDC_CS, SCSI_CS_I, dma_active, dma_mode)
	BEGIN
		CASE fcf_state IS
			WHEN FCF_IDLE =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				SCSI_DACKn <= '1';
				IF dma_req = '1' OR FDC_CS = '1' OR SCSI_CS_I = '1' THEN 	 
					dma_active_new <= dma_req;
					next_fcf_state <= FCF_T0;
				ELSE
					dma_active_new <= '0';
					next_fcf_state <= FCF_IDLE; 		 
				END IF;
			WHEN FCF_T0 =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				SCSI_DACKn <= '1';
				dma_active_new <= dma_req;
				WRF_RDE <= dma_mode(8) AND dma_req; -- Write -> Read from FIFO
				IF 	dma_req = '0' AND dma_active = '1' THEN -- Spike?
					next_fcf_state <= FCF_IDLE; -- Yes -> Start
				ELSE
					next_fcf_state <= FCF_T1;
				END IF;
			WHEN FCF_T1 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				dma_active_new <= dma_active;
				SCSI_CSn <= NOT SCSI_CS_I;
				FDC_CS_In <= dma_mode(4) OR dma_mode(3);
				SCSI_DACKn <= dma_mode(7) AND dma_active;
				next_fcf_state <= FCF_T2;
			WHEN FCF_T2 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				dma_active_new <= dma_active;
				SCSI_CSn <= NOT SCSI_CS_I;
				FDC_CS_In <= dma_mode(4) OR dma_mode(3);
				SCSI_DACKn <= dma_mode(7) AND dma_active;
				next_fcf_state <= FCF_T3;
			WHEN FCF_T3 =>
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				dma_active_new <= dma_active;
				SCSI_CSn <= NOT SCSI_CS_I;
				FDC_CS_In <= dma_mode(4) OR dma_mode(3);
				SCSI_DACKn <= dma_mode(7) AND dma_active;
				next_fcf_state <= FCF_T6;
			WHEN FCF_T6 =>
				WRF_RDE <= '0';
				dma_active_new <= dma_active;
				SCSI_CSn <= NOT SCSI_CS_I;
				FDC_CS_In <= dma_mode(4) OR dma_mode(3);
				SCSI_DACKn <= dma_mode(7)  AND dma_active;
				RDF_WRE <= NOT dma_mode(8) AND dma_active; -- Read -> Write to FIFO
				next_fcf_state <= FCF_T7;
			WHEN FCF_T7 =>
				SCSI_CSn <= '1';
				FDC_CS_In <= '1';
				RDF_WRE <= '0';
				WRF_RDE <= '0';
				SCSI_DACKn <= '1';
				dma_active_new <= '0';
				IF FDC_CS = '1' AND dma_req = '0'  THEN 	 
					next_fcf_state <= FCF_T7;
				ELSE
					next_fcf_state <= FCF_IDLE; 		 
				END IF;
		END CASE;
	END PROCESS FCF_DECODER;
END ARCHITECTURE BEHAVIOUR;
