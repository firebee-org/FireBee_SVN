-- WARNING: Do NOT edit the input and output ports in this file in a text
-- editor if you plan to continue editing the block that represents it in
-- the Block Editor! File corruption is VERY likely to occur.

-- Copyright (C) 1991-2008 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.


-- Generated by Quartus II Version 8.1 (Build Build 163 10/28/2008)
-- Created on Fri Oct 16 15:40:59 2009

LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
    USE ieee.numeric_std.ALL;

ENTITY blitter IS
	-- {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
	PORT
	(
		nRSTO           : IN std_logic;
		MAIN_CLK        : IN std_logic;
		FB_ALE          : IN std_logic;
		nFB_WR          : IN std_logic;
		nFB_OE          : IN std_logic;
		FB_SIZE0        : IN std_logic;
		FB_SIZE1        : IN std_logic;
		VIDEO_RAM_CTR   : IN std_logic_vector(15 DOWNTO 0);
		BLITTER_ON      : IN std_logic;
		FB_ADR          : IN std_logic_vector(31 DOWNTO 0);
		nFB_CS1         : IN std_logic;
		nFB_CS2         : IN std_logic;
		nFB_CS3         : IN std_logic;
		DDRCLK0         : IN std_logic;
		BLITTER_DIN     : IN std_logic_vector(127 DOWNTO 0);
		BLITTER_DACK    : IN std_logic_vector(4 DOWNTO 0);
        SR_BLITTER_DACK : IN std_logic;
		BLITTER_RUN     : OUT std_logic;
		BLITTER_DOUT    : OUT std_logic_vector(127 DOWNTO 0);
		BLITTER_ADR     : OUT std_logic_vector(31 DOWNTO 0);
		BLITTER_SIG     : OUT std_logic;
		BLITTER_WR      : OUT std_logic;
		BLITTER_TA      : OUT std_logic;
		FB_AD           : INOUT std_logic_vector(31 DOWNTO 0)
	);
	-- {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
	
END BLITTER;


ARCHITECTURE rtl OF blitter IS

	
BEGIN
	BLITTER_RUN <= '0';
	BLITTER_DOUT <= x"FEDCBA9876543210F0F0F0F0F0F0F0F0";
	BLITTER_ADR <=  x"76543210";
	BLITTER_SIG <= '0';
	BLITTER_WR <= '0';
	BLITTER_TA <= '0';

END rtl;