----------------------------------------------------------------------
----                                                              ----
---- This file is part OF the 'Firebee' project.                  ----
---- http://acp.atari.org                                         ----
----                                                              ----
---- Description:                                                 ----
---- This design unit provides the interruptlogic OF the 'Firebee'----
---- computer. It is optimized FOR the use of an Altera Cyclone   ----
---- FPGA (EP3C40F484). This IP-Core is based on the first edi-   ----
---- tion OF the Firebee configware originally provided by Fredi  ----
---- Aschwanden  AND Wolfgang Förster. This release is in compa-  ----
---- rision TO the first edition completely written in VHDL.      ----
----                                                              ----
---- Author(s):                                                   ----
---- - Wolfgang Foerster, wf@experiment-s.de; wf@inventronik.de   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2012 Fredi Aschwanden, Wolfgang Förster        ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- AND/or modify it under the terms OF the GNU General Public   ----
---- License as published by the Free Software Foundation; either ----
---- version 2 of the License, or (at your option) any later      ----
---- version.                                                     ----
----                                                              ----
---- This program IS distributed in the hope that it will be      ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty OF MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU General Public License FOR more        ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU General Public    ----
---- License along with this program; IF NOT, write TO the Free   ----
---- Software Foundation, Inc., 51 Franklin Street, Fifth Floor,  ----
---- Boston, MA 02110-1301, USA.                                  ----
----                                                              ----
----------------------------------------------------------------------
-- 
-- Revision History
-- 
-- Revision 2K12B  20120801 WF
--   Initial Release OF the second edition.

LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.numeric_std.all;
-- USE ieee.std_logic_arith.ALL;

ENTITY inthandler IS
    PORT(
        clk_main        : IN STD_LOGIC;
        reset_n         : IN STD_LOGIC;
        fb_adr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_cs_n         : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
        fb_size0        : IN STD_LOGIC;
        fb_size1        : IN STD_LOGIC;
        fb_wr_n         : IN STD_LOGIC;
        fb_oe_n         : IN STD_LOGIC;
        fb_ad_in        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_ad_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        fb_ad_en_31_24  : OUT STD_LOGIC;
        fb_ad_en_23_16  : OUT STD_LOGIC;
        fb_ad_en_15_8   : OUT STD_LOGIC;
        fb_ad_en_7_0    : OUT STD_LOGIC;
        pic_int         : IN STD_LOGIC;
        e0_int          : IN STD_LOGIC;
        dvi_int         : IN STD_LOGIC;
        pci_inta_n      : IN STD_LOGIC;
        pci_intb_n      : IN STD_LOGIC;
        pci_intc_n      : IN STD_LOGIC;
        pci_intd_n      : IN STD_LOGIC;
        mfp_int_n       : IN STD_LOGIC;
        dsp_int         : IN STD_LOGIC;
        vsync           : IN STD_LOGIC;
        hsync           : IN STD_LOGIC;
        drq_dma         : IN STD_LOGIC;
        irq_n           : OUT STD_LOGIC_VECTOR(7 DOWNTO 2);
        int_handler_ta  : OUT STD_LOGIC;
        fbee_conf       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        tin0            : OUT STD_LOGIC
    );
END ENTITY inthandler;

ARCHITECTURE BEHAVIOUR OF inthandler IS
	type int_la_t IS array(9 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal int_la                  : int_la_t;
	signal fb_b                    : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal int_ctr                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal int_ctr_cs              : STD_LOGIC;
	signal int_latch               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal int_latch_cs            : STD_LOGIC;
	signal int_clear               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal int_clear_cs            : STD_LOGIC;
	signal int_in                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal int_ena                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal int_ena_cs              : STD_LOGIC;
	signal int_l                   : STD_LOGIC_VECTOR(9 DOWNTO 0);
	signal fbee_conf_reg           : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal fbee_conf_cs            : STD_LOGIC;
	signal pseudo_bus_error        : STD_LOGIC;
BEGIN
	-- Byte selectors:
	fb_b(0) <= '1' WHEN fb_size1 = '1' AND fb_size0 = '0' AND fb_adr(1) = '0' ELSE -- High word.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '1' AND fb_adr(1 DOWNTO 0) = "00" ELSE -- HH Byte.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '0' ELSE -- Long.
					'1' WHEN fb_size1 = '1' AND fb_size0 = '1' ELSE '0';-- Line.

	fb_b(1) <= '1' WHEN fb_size1 = '1' AND fb_size0 = '0' AND fb_adr(1) = '0' ELSE -- High word.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '1' AND fb_adr(1 DOWNTO 0) = "01" ELSE -- HL Byte.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '0' ELSE -- Long.
					'1' WHEN fb_size1 = '1' AND fb_size0 = '1' ELSE '0';-- Line.
             
	fb_b(2) <= '1' WHEN fb_size1 = '1' AND fb_size0 = '0' AND fb_adr(1) = '1' ELSE -- Low word.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '1' AND fb_adr(1 DOWNTO 0) = "10" ELSE -- LH Byte.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '0' ELSE -- Long.
					'1' WHEN fb_size1 = '1' AND fb_size0 = '1' ELSE '0';-- Line.
             
	fb_b(3) <= '1' WHEN fb_size1 = '1' AND fb_size0 = '0' AND fb_adr(1) = '1' ELSE -- Low word.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '1' AND fb_adr(1 DOWNTO 0) = "11" ELSE -- LL Byte.
					'1' WHEN fb_size1 = '0' AND fb_size0 = '0' ELSE -- Long.
					'1' WHEN fb_size1 = '1' AND fb_size0 = '1' ELSE '0';-- Line.

	int_ctr_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000100000000000000" ELSE '0'; -- $10000/4;
	int_ena_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000100000000000001" ELSE '0'; -- $10004/4;
	int_clear_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000100000000000010" ELSE '0'; -- $10008/4;
	int_latch_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000000000100000000000011" ELSE '0'; -- $1000C/4;

	P_INT_CTRL  : PROCESS
		-- Interrupt control register:
		-- BIT0 = INT5, Bit1 = INT7.
		-- Interrupt enabe register:
		-- BIT31 = INT7, Bit30 = INT6, Bit29 = INT5, Bit28 = INT4, Bit27 = INT3, Bit26 = INT2
		-- The interrupt clear register IS write only; 1 = interrupt clear.
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_main);
		IF int_ctr_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			int_ctr(31 DOWNTO 24) <= fb_ad_in(31 DOWNTO 24);
		ELSIF int_ctr_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			int_ctr(23 DOWNTO 16) <= fb_ad_in(23 DOWNTO 16);
		ELSIF int_ctr_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			int_ctr(15 DOWNTO 8) <= fb_ad_in(15 DOWNTO 8);
		ELSIF int_ctr_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			int_ctr(7 DOWNTO 0) <= fb_ad_in(7 DOWNTO 0);
		END IF;
		--
		IF reset_n = '0' THEN
			int_ena <= (OTHERS => '0');
		ELSIF int_ena_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			int_ena(31 DOWNTO 24) <= fb_ad_in(31 DOWNTO 24);
		ELSIF int_ena_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			int_ena(23 DOWNTO 16) <= fb_ad_in(23 DOWNTO 16);
		ELSIF int_ena_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			int_ena(15 DOWNTO 8) <= fb_ad_in(15 DOWNTO 8);
		ELSIF int_ena_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			int_ena(7 DOWNTO 0) <= fb_ad_in(7 DOWNTO 0);
		END IF;
		--
		IF int_clear_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			int_clear(31 DOWNTO 24) <= fb_ad_in(31 DOWNTO 24);
		ELSIF int_clear_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			int_clear(23 DOWNTO 16) <= fb_ad_in(23 DOWNTO 16);
		ELSIF int_clear_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			int_clear(15 DOWNTO 8) <= fb_ad_in(15 DOWNTO 8);
		ELSIF int_clear_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			int_clear(7 DOWNTO 0) <= fb_ad_in(7 DOWNTO 0);
		END IF;
    END PROCESS P_INT_CTRL;

    -- Interrupt latch register: read only.
    irq_n(2) <= '0' WHEN hsync = '1' AND int_ena(26) = '1' ELSE '1';
    irq_n(3) <= '0' WHEN int_ctr(0) = '1' AND int_ena(27) = '1' ELSE '1';
    irq_n(4) <= '0' WHEN vsync = '1' AND int_ena(28) = '1' ELSE '1';
    irq_n(5) <= '0' WHEN int_latch /= x"00000000" AND int_ena(29) = '1' ELSE '1';
    irq_n(6) <= '0' WHEN mfp_int_n = '0' AND int_ena(30) = '1' ELSE '1';
    irq_n(7) <= '0' WHEN pseudo_bus_error = '1' AND int_ena(31) = '1' ELSE '1';

    pseudo_bus_error <= '1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F8C8" ELSE -- SCC
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F8E0" ELSE -- VME
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F920" ELSE -- PADDLE
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F921" ELSE -- PADDLE
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F922" ELSE -- PADDLE
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFA8" ELSE -- MFP2
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFA9" ELSE -- MFP2
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFAA" ELSE -- MFP2
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFA8" ELSE -- MFP2
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 8) = x"F87" ELSE -- TT SCSI
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFC2" ELSE -- ST UHR
								'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"FFC3" ELSE '0'; -- ST UHR
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F890" ELSE -- DMA SOUND
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F891" ELSE -- DMA SOUND
	--							'1' WHEN fb_cs_n(1) = '0' AND fb_adr(19 DOWNTO 4) = x"F892" ELSE '0'; -- DMA SOUND

	-- IF video ADR changes:
	tin0 <= '1' WHEN fb_cs_n(1) = '0' AND fb_wr_n = '0' AND fb_adr(19 DOWNTO 1) = 19x"7C100" ELSE '0'; -- Write video base address high 0xFFFF8201/2.

	P_INT_LATCH  : PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_main);
		IF reset_n = '0' THEN
			int_l <= (OTHERS => '0');
		ELSE
			int_l(0) <= pic_int AND int_ena(0);
			int_l(1) <= e0_int AND int_ena(1);
			int_l(2) <= dvi_int AND int_ena(2);
			int_l(3) <= NOT pci_inta_n AND int_ena(3);
			int_l(4) <= NOT pci_intb_n AND int_ena(4);
			int_l(5) <= NOT pci_intc_n AND int_ena(5);
			int_l(6) <= NOT pci_intd_n AND int_ena(6);
			int_l(7) <= dsp_int AND int_ena(7);
			int_l(8) <= vsync AND int_ena(8);
			int_l(9) <= hsync AND int_ena(9);
		END IF;
        
		FOR i IN 0 TO 9 LOOP
			IF int_ena(i) = '1' AND reset_n = '1' THEN
				int_la(i) <= x"0";
			ELSIF int_l(i) = '1' AND int_la(i) < x"7" THEN
				int_la(i) <= STD_LOGIC_VECTOR(UNSIGNED(int_la(i)) + 1);
			ELSIF int_l(i) = '0' AND int_la(i) > x"8" THEN
				int_la(i) <= STD_LOGIC_VECTOR(UNSIGNED(int_la(i)) - 1);
			ELSIF int_l(i) = '1' AND int_la(i) > x"6" THEN
				int_la(i) <= x"F";
			ELSIF int_l(i) = '0' AND int_la(i) > x"9" THEN
				int_la(i) <= x"0";
			END IF;
		END LOOP;
        
		FOR i IN 0 TO 31 LOOP
			IF int_clear(i) = '0' AND reset_n = '1' THEN
				int_latch(i) <= '0';
			END IF;
		END LOOP;

		FOR i IN 0 TO 9 LOOP
			IF int_la(i)(3) = '1' THEN
				int_latch(i) <= '1';
			END IF;
		END LOOP;
	END PROCESS P_INT_LATCH;

	-- int_in:
	int_in(0) <= pic_int;
	int_in(1) <= e0_int;
	int_in(2) <= dvi_int;
	int_in(3) <= NOT pci_inta_n;
	int_in(4) <= NOT pci_intb_n;
	int_in(5) <= NOT pci_intc_n;
	int_in(6) <= NOT pci_intd_n;
	int_in(7) <= dsp_int;
	int_in(8) <= vsync;
	int_in(9) <= hsync;
	int_in(25 DOWNTO 10) <= x"0000";
	int_in(26) <= hsync; 
	int_in(27) <= int_ctr(0); 
	int_in(28) <= vsync; 
	int_in(29) <= '1' WHEN int_latch /= x"00000000";
	int_in(30) <= NOT mfp_int_n; 
	int_in(31) <= drq_dma; 

	fbee_conf_cs <= '1' WHEN fb_cs_n(2) = '0' AND fb_adr(27 DOWNTO 2) = "00000001000000000000000000" ELSE '0'; -- $40000/4.

	p_fbee_config : PROCESS
		-- Firebee configuration register: BIT 31 -> 0 = CF 1 = IDE 
	BEGIN
		WAIT UNTIL RISING_EDGE(clk_main);
		IF fbee_conf_cs = '1' AND fb_b(0) = '1' AND fb_wr_n = '0' THEN
			fbee_conf_reg(31 DOWNTO 24) <= fb_ad_in(31 DOWNTO 24);
		ELSIF fbee_conf_cs = '1' AND fb_b(1) = '1' AND fb_wr_n = '0' THEN
			fbee_conf_reg(23 DOWNTO 16) <= fb_ad_in(23 DOWNTO 16);
		ELSIF fbee_conf_cs = '1' AND fb_b(2) = '1' AND fb_wr_n = '0' THEN
			fbee_conf_reg(15 DOWNTO 8) <= fb_ad_in(15 DOWNTO 8);
		ELSIF fbee_conf_cs = '1' AND fb_b(3) = '1' AND fb_wr_n = '0' THEN
			fbee_conf_reg(7 DOWNTO 0) <= fb_ad_in(7 DOWNTO 0);
		END IF;
		fbee_conf <= fbee_conf_reg;
	END PROCESS p_fbee_config;
    
	-- Data OUT multiplexers:
	fb_ad_en_31_24 <= (int_ctr_cs or int_ena_cs or int_latch_cs or int_clear_cs or fbee_conf_cs) AND NOT fb_oe_n;
	fb_ad_en_23_16 <= (int_ctr_cs or int_ena_cs or int_latch_cs or int_clear_cs or fbee_conf_cs) AND NOT fb_oe_n;
	fb_ad_en_15_8 <= (int_ctr_cs or int_ena_cs or int_latch_cs or int_clear_cs or fbee_conf_cs)  AND NOT fb_oe_n;
	fb_ad_en_7_0 <= (int_ctr_cs or int_ena_cs or int_latch_cs or int_clear_cs or fbee_conf_cs) AND NOT fb_oe_n;

	fb_ad_out(31 DOWNTO 24) <= int_ctr(31 DOWNTO 24) WHEN int_ctr_cs = '1' ELSE
										int_ena(31 DOWNTO 24) WHEN int_ena_cs = '1' ELSE
										int_latch(31 DOWNTO 24) WHEN int_latch_cs = '1' ELSE
										int_in(31 DOWNTO 24) WHEN int_clear_cs = '1' ELSE fbee_conf_reg(31 DOWNTO 24);

	fb_ad_out(23 DOWNTO 16) <= int_ctr(23 DOWNTO 16) WHEN int_ctr_cs = '1' ELSE
										int_ena(23 DOWNTO 16) WHEN int_ena_cs = '1' ELSE
										int_latch(23 DOWNTO 16) WHEN int_latch_cs = '1' ELSE
										int_in(23 DOWNTO 16) WHEN int_clear_cs = '1' ELSE fbee_conf_reg(23 DOWNTO 16);

	fb_ad_out(15 DOWNTO 8) <= int_ctr(15 DOWNTO 8) WHEN int_ctr_cs = '1' ELSE
										int_ena(15 DOWNTO 8) WHEN int_ena_cs = '1' ELSE
										int_latch(15 DOWNTO 8) WHEN int_latch_cs = '1' ELSE
										int_clear(15 DOWNTO 8) WHEN int_clear_cs = '1' ELSE fbee_conf_reg(15 DOWNTO 8);
                              
	fb_ad_out(7 DOWNTO 0) <= int_ctr(7 DOWNTO 0) WHEN int_ctr_cs = '1' ELSE
										int_ena(7 DOWNTO 0) WHEN int_ena_cs = '1' ELSE
										int_latch(7 DOWNTO 0) WHEN int_latch_cs = '1' ELSE
										int_clear(7 DOWNTO 0) WHEN int_clear_cs = '1' ELSE fbee_conf_reg(7 DOWNTO 0);

	int_handler_ta <= int_ctr_cs or int_ena_cs or int_latch_cs or int_clear_cs;
END ARCHITECTURE BEHAVIOUR;
