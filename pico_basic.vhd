---------------------------------------------------------------------------------------------------
-- PICO 1802 Tiny BASIC - Top level entity
---------------------------------------------------------------------------------------------------
-- This file is part of the PICO 1802 Tiny BASIC Project
-- Copyright 2016, Steve Teal: steveteal71@gmail.com
-- 
-- This source file may be used and distributed without restriction provided that this copyright
-- statement is not removed from the file and that any derivative work contains the original
-- copyright notice and the associated disclaimer.
-- 
-- This source file is free software; you can redistribute it and/or modify it under the terms
-- of the GNU Lesser General Public License as published by the Free Software Foundation,
-- either version 3 of the License, or (at your option) any later version.
-- 
-- This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
-- See the GNU Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-3.0.en.html
---------------------------------------------------------------------------------------------------
-- Steve Teal, Northamptonshire, United Kingdom
---------------------------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pico_basic is
	port(
		reset_n : in  std_logic;   -- Active low reset input
		clock   : in std_logic;    -- Clock, typically 12MHz
		tx      : out std_logic;   -- Serial output to terminal
		rx      : in std_logic;    -- Serial input from terminal
		pa      : inout std_logic_vector(7 downto 0);  -- 8 BIT GPIO PORT A
		pb      : inout std_logic_vector(7 downto 0)); -- 8 BIT GPIO PORT B
end pico_basic;

architecture rtl of pico_basic is

	component mx18 
		port(
			clock:		in std_logic;
			reset_n:	in std_logic;
			data_in:	in std_logic_vector(7 downto 0);
			data_out:	out std_logic_vector(7 downto 0);
			address:	out std_logic_vector(15 downto 0);
			ef:			in std_logic_vector(3 downto 0);
			nlines: 	out std_logic_vector(2 downto 0);
			q:			out std_logic;
			rd_n:		out std_logic;
			wr_n:		out std_logic);
		end component;

	component ram
		port(
			clock:		in std_logic;
			cs_n:		in std_logic;
			rd_n:       in std_logic;	   
			wr_n:       in std_logic;
			address:    in std_logic_vector(11 downto 0); 
			data_in:    in std_logic_vector(7 downto 0);
			data_out:   out std_logic_vector(7 downto 0));
		end component;
		
	component ut4 is 
		port(  
			clock:		in std_logic;
			cs_n:		in std_logic;
			rd_n:       in std_logic;
			address:    in std_logic_vector(8 downto 0);
			data_out:   out std_logic_vector(7 downto 0));
		end component;
		
	component tiny_basic is 
		port(  
			clock:		in std_logic;
			cs_n:		in std_logic;
			rd_n:       in std_logic;
			address:    in std_logic_vector(10 downto 0);
			data_out:   out std_logic_vector(7 downto 0));
		end component;
		
	component gpio is 
		port(  
			clock:		in std_logic;
			reset_n:	in std_logic;
			data_in:	in std_logic_vector(7 downto 0);
			data_out:	out std_logic_vector(7 downto 0);
			address:	in std_logic_vector(3 downto 0);
			rd_n:		in std_logic;
			wr_n:		in std_logic;
			cs_n:       in std_logic;
			pa:         inout std_logic_vector(7 downto 0);
			pb:         inout std_logic_vector(7 downto 0));         
		end component;
		
	signal data_bus      : std_logic_vector(7 downto 0);
	signal cpu_data      : std_logic_vector(7 downto 0);
	signal ram_data      : std_logic_vector(7 downto 0);
	signal ut4_rom_data  : std_logic_vector(7 downto 0);
	signal gpio_data     : std_logic_vector(7 downto 0);
	signal tb_rom_data   : std_logic_vector(7 downto 0);
	signal cpu_address   : std_logic_vector(15 downto 0);
	signal address       : std_logic_vector(15 downto 0);
	signal nlines        : std_logic_vector(2 downto 0);
	signal rd_n          : std_logic;
	signal wr_n          : std_logic;
	signal ram_cs        : std_logic;
	signal ut4_cs        : std_logic;
	signal tb_cs         : std_logic;
	signal gpio_cs       : std_logic;
	signal sync_reset_n  : std_logic; -- Active low syncronised reset
	signal ef            : std_logic_vector(3 downto 0);
	signal q             : std_logic;
	signal reset_counter : unsigned(8 downto 0);
	signal hold_a15_hi   : std_logic;


begin

	u1: mx18 port map (
		clock => clock,
		reset_n => sync_reset_n,
		data_in => data_bus,
		data_out => cpu_data,
		address => cpu_address,
		ef => ef,
		nlines => nlines, 
		q => q,
		rd_n => rd_n,
		wr_n =>	wr_n);

	u2: ram port map (
		clock => clock,
		cs_n => ram_cs,
		rd_n => rd_n,
		wr_n => wr_n,
		address => address(11 downto 0),
		data_in => data_bus,
		data_out =>	ram_data);

	u3: ut4 port map (
		clock => clock,
		cs_n => ut4_cs,
		rd_n => rd_n,
		address => address(8 downto 0),
		data_out => ut4_rom_data);
	
    u4: tiny_basic port map (
		clock => clock,
		cs_n => tb_cs,
		rd_n => rd_n,
		address => address(10 downto 0),
		data_out => tb_rom_data);
		
	u5: gpio port map (
		clock => clock,
		reset_n => sync_reset_n,
		data_in => data_bus,
		data_out => gpio_data,
		address => address(3 downto 0),
		rd_n => rd_n,
		wr_n => wr_n,
		cs_n => gpio_cs,
		pa => pa,
		pb => pb);
	
	--
	-- Data bus - each module drives its outputs low while not selected allowing a simple OR
	-- function to combine the verious sources to a single bus.
	--
	data_bus <= cpu_data or ram_data or ut4_rom_data or tb_rom_data or gpio_data;
	
	--
	-- Address decoder
	--
	tb_cs <= '0' when address(15 downto 11) = "00000" else '1';
	ut4_cs <= '0' when address(15 downto 10) = "100000" else '1';
	ram_cs <= '0' when address(15 downto 11) = "00010" or address(15 downto 11) = "00001" else '1';
	gpio_cs <= '0' when address(15 downto 4) = "000110000000" else '1';

	--
	-- EF inputs (note on the real 1802 these are numbered EF1..4)
	-- EF4 (ef(3)) is used as serial RX
	--
	ef(0) <= pb(2);
	ef(1) <= pb(3);
	ef(2) <= pb(4);
	ef(3) <= not rx; 
	
	--
	-- Q is used as serial TX
	--
	tx <= not q;
	
	--
	-- A15 is held high for a short while after reset so that the monitor located at 0x8000 appears at 
	-- location 0x0000, the start address of the 1802. Early on the monitor adjusts the program
	-- counter such that A15 can be released.
	--
	 
	address <= (cpu_address(15) or hold_a15_hi) & cpu_address(14 downto 0);
	 
	process(clock)
	begin
		if(rising_edge(clock))then
			-- Force A15 high for 512 clock cycles after reset
			if(reset_n = '0')then
				reset_counter <= "000000000";
			elsif(reset_counter /= "111111111")then
				reset_counter <= reset_counter + 1;
				hold_a15_hi <= '1';
			else
				hold_a15_hi <= '0';
			end if;
			-- Synchronous reset 
			if(reset_counter(8 downto 3) = "000000")then
				sync_reset_n <= '0';
			else
				sync_reset_n <= '1';
			end if;
		end if;
	end process;
			
	
end;