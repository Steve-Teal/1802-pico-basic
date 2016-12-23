---------------------------------------------------------------------------------------------------
-- PICO 1802 Tiny BASIC - GPIO module
---------------------------------------------------------------------------------------------------
-- 2 x 8-bit general purpose IO ports
-- Each port bit independently configurable as an input or output via the data direction regsiter
-- Occupies 16 bytes of contiguous memory
-- Full read / write access to data direction and port registers
-- Seperatate locations to set, reset or toggle data direction and port register bits
-- Reset leaves all bits configured as input
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

entity gpio is 
	port(  
		-- Processor interface
		clock:		in std_logic; -- Global clock
		reset_n:	in std_logic; -- Active low reset
		data_in:	in std_logic_vector(7 downto 0);
		data_out:	out std_logic_vector(7 downto 0);
		address:	in std_logic_vector(3 downto 0);
		rd_n:		in std_logic;
		wr_n:		in std_logic;
		cs_n:       in std_logic;
		-- GPIO Ports (for connection to the outside world)
		pa:         inout std_logic_vector(7 downto 0);
		pb:         inout std_logic_vector(7 downto 0));         
end gpio;

architecture rtl of gpio is

	signal porta  : std_logic_vector(7 downto 0);
	signal portb  : std_logic_vector(7 downto 0);
	signal ddra   : std_logic_vector(7 downto 0);
	signal ddrb   : std_logic_vector(7 downto 0);
	signal pina   : std_logic_vector(7 downto 0);
	signal pinb   : std_logic_vector(7 downto 0);

begin

	gen_port: for i in 0 to 7 generate
		pa(i) <= porta(i) when ddra(i) = '0' else 'Z';
		pb(i) <= portb(i) when ddrb(i) = '0' else 'Z';
	end generate gen_port;
	
	process(clock)
	begin
		if(rising_edge(clock))then
			if(reset_n = '0')then
				porta <= X"00";
				portb <= X"00";
				ddra <= X"FF";
				ddrb <= X"FF";
			elsif(wr_n = '0' and cs_n = '0')then
				case address is
					when "0000" => porta <= data_in;
					when "0001" => porta <= data_in or porta;
					when "0010" => porta <= (not data_in) and porta;
					when "0011" => porta <= data_in xor porta;
					when "0100" => ddra <= data_in;
					when "0101" => ddra <= data_in or ddra;
					when "0110" => ddra <= (not data_in) and ddra;
					when "0111" => ddra <= data_in xor ddra;
					when "1000" => portb <= data_in;
					when "1001" => portb <= data_in or portb;
					when "1010" => portb <= (not data_in) and portb;
					when "1011" => portb <= data_in xor portb;
					when "1100" => ddrb <= data_in;
					when "1101" => ddrb <= data_in or ddrb;
					when "1110" => ddrb <= (not data_in) and ddrb;
					when "1111" => ddrb <= data_in xor ddrb;
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
	process(address,pina,pinb,ddra,ddrb,rd_n,cs_n)
	begin
		if(rd_n = '0' and cs_n = '0')then
			case address(3 downto 2) is
				when "00" => data_out <= pina;
				when "01" => data_out <= ddra;
				when "10" => data_out <= pinb;
				when "11" => data_out <= ddrb;
				when others => data_out <= X"00";
			end case;
		else
			data_out <= X"00";
		end if;
	end process;
	
	process(clock)
	begin
		if(rising_edge(clock))then
			pina <= pa;
			pinb <= pb;
		end if;
	end process;

end rtl;