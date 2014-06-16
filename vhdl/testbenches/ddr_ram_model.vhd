library work;
use work.firebee_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

-- DDR ram simulation for Firebee video RAM

entity ddr_ram_model is
	port (
		signal CK		: in std_logic;
		signal CKE		: in std_logic;
		signal CSn		: in std_logic;
		signal RASn		: in std_logic;
		signal CASn		: in std_logic;
		signal WEn		: in std_logic;
		signal LDM		: in std_logic;
		signal UDM		: in std_logic;
		signal BA		: in std_logic_vector(1 downto 0);
		signal A			: in std_logic_vector(12 downto 0);
		signal DQ		: inout std_logic_vector(7 downto 0);
		signal LDQS		: inout std_logic;
		signal UDQS		: inout std_logic
	);
end entity ddr_ram_model;

architecture behav of ddr_ram_model is
	signal opcode 		: std_logic_vector(14 downto 0);
	signal command 	: std_logic_vector(5 downto 0);
	signal OLD_CKE		: std_logic := 'X';
begin
	opcode <= BA & A(10) & A(12 downto 11) & A(9 downto 0);
	command <= OLD_CKE & CKE & CSn & RASn & CASn & WEn;
	clock_hi : process
	begin
		wait until rising_edge(CK) and CK = '1';
		
	end process;
	
	clock_lo : process
	begin
		wait until falling_edge(CK) and CK = '0';
	end process;
end behav;
