---------------------------------------------------------------------------------------------------
-- PICO 1802 Tiny BASIC - 4K x 8 RAM module
---------------------------------------------------------------------------------------------------
-- Generic synchronous RAM entity 
-- When not selected, the outputs are driven low, allowing the system data bus to OR all data bus
-- sources togeather.
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

entity ram is 
	port(  
		clock:		in std_logic;
		cs_n:		in std_logic;
		rd_n:       in std_logic;	   
		wr_n:       in std_logic;
		address:    in std_logic_vector(11 downto 0); 
		data_in:    in std_logic_vector(7 downto 0);
		data_out:   out std_logic_vector(7 downto 0));
end ram;

architecture rtl of ram is

	type ram_type is array (0 to 4095) of std_logic_vector(7 downto 0);
	signal ram : ram_type;
		
begin
	
	process(clock)
	begin
		if(rising_edge(clock))then	
			if(cs_n = '0' and wr_n = '0')then
				ram(to_integer(unsigned(address))) <= data_in;
			end if;
		end if;
	end process;
	
	process(clock)
	begin	
		if(rising_edge(clock))then
			if(cs_n = '0' and rd_n = '0')then
				data_out <= ram(to_integer(unsigned(address)));	  
			else
				data_out <= "00000000";
			end if;
		end if;
	end process;

end rtl;

