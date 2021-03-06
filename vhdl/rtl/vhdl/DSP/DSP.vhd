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
-- Created on Tue Sep 08 16:24:57 2009

LIBRARY ieee;
USE ieee.std_logic_1164.all;


--  Entity Declaration

ENTITY DSP IS
	port(
		CLK_33M         : in std_logic;
		CLK_MAIN        : in std_logic;
		fb_oe_n         : in std_logic;
		fb_wr_n         : in std_logic;
		FB_CS1n         : in std_logic;
		FB_CS2n         : in std_logic;
		FB_SIZE0        : in std_logic;
		FB_SIZE1        : in std_logic;
		FB_BURSTn       : in std_logic;
		FB_ADR          : in std_logic_vector(31 downto 0);
		RESETn          : in std_logic;
		FB_CS3n         : in std_logic;
		SRCSn           : buffer std_logic;
		SRBLEn          : out std_logic;
		SRBHEn          : out std_logic;
		SRWEn           : out std_logic;
		SROEn           : out std_logic;
		DSP_INT         : out std_logic;
		DSP_TA          : out std_logic;
		FB_AD_IN        : in std_logic_vector(31 downto 0);
		FB_AD_OUT       : out std_logic_vector(31 downto 0);
		FB_AD_EN        : out std_logic;
		IO_IN           : in std_logic_vector(17 downto 0);
		IO_OUT          : out std_logic_vector(17 downto 0);
		IO_EN           : out std_logic;
		SRD_IN          : in std_logic_vector(15 downto 0);
		SRD_OUT         : out std_logic_vector(15 downto 0);
		SRD_EN          : out std_logic
	);
END DSP;


--  Architecture Body

ARCHITECTURE DSP_architecture OF DSP IS
BEGIN
	SRCSn  <= '0' when FB_CS2n = '0' and FB_ADR(27 downto 24) = x"4" else '1';	--FB_CS3n;
	SRBHEn <= '0' when FB_ADR(0 downto 0) = "0" else '1';
	SRBLEn <= '1' when FB_ADR(0 downto 0) = "0" and FB_SIZE1 = '0' and FB_SIZE0 = '1' else '0'; 
	SRWEn <= '0' when fb_wr_n = '0' and SRCSn = '0' and CLK_MAIN = '0' else '1';
	SROEn <= '0' when fb_oe_n = '0' and SRCSn = '0' else '1';
	DSP_INT <= '0';
	DSP_TA <= '0';
	IO_OUT(17 downto 0) <= FB_ADR(18 downto 1);
	IO_EN <= '1';
	SRD_OUT(15 downto 0) <= FB_AD_IN(31 downto 16) when fb_wr_n = '0' and SRCSn = '0' else x"0000";
	SRD_EN <= '1' when fb_wr_n = '0' and SRCSn = '0' else '0';
	FB_AD_OUT(31 downto 16) <= SRD_IN(15 downto 0) when fb_oe_n = '0' and SRCSn = '0' else x"0000";
	FB_AD_OUT(15 downto 0) <= SRD_IN(15 downto 0) when fb_oe_n = '0' and SRCSn = '0' else x"0000";
	FB_AD_EN <= '1' when fb_oe_n = '0' and SRCSn = '0' else '0';
END DSP_architecture;
