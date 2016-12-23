--------------------------------------------------------------------------------------------------------
-- UT4 ROM image as listed in BMP802 "Design Ideas Book for the CDP1802 COSMAC Microprocessor"
-- Author: Tom Pittman 
-- Copyright: unkown
-- http://www.retrotechnology.com/memship/UT4_rom.html
--------------------------------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ut4 is 
	port(  
		clock:		in std_logic;
		cs_n:		in std_logic;
		rd_n:       in std_logic;
		address:    in std_logic_vector(8 downto 0);
		data_out:   out std_logic_vector(7 downto 0));
end ut4;

architecture rtl of ut4 is

	type rom_type is array(0 to 511) of std_logic_vector(7 downto 0);
	signal rom : rom_type := (
			(X"C4"),(X"F8"),(X"80"),(X"B0"),(X"F8"),(X"8C"),(X"B1"),(X"F8"),
			(X"1E"),(X"A1"),(X"F8"),(X"A0"),(X"B4"),(X"E1"),(X"F8"),(X"D0"),
			(X"51"),(X"F3"),(X"3A"),(X"29"),(X"21"),(X"94"),(X"FC"),(X"70"),
			(X"33"),(X"1C"),(X"FC"),(X"21"),(X"FC"),(X"7F"),(X"B4"),(X"51"),
			(X"F3"),(X"3A"),(X"29"),(X"D1"),(X"51"),(X"21"),(X"21"),(X"30"),
			(X"0E"),(X"90"),(X"B5"),(X"B3"),(X"F8"),(X"30"),(X"A5"),(X"D5"),
			(X"E5"),(X"71"),(X"55"),(X"61"),(X"01"),(X"F8"),(X"FE"),(X"A3"),
			(X"D3"),(X"F8"),(X"9C"),(X"A3"),(X"D3"),(X"0D"),(X"D3"),(X"0A"),
			(X"D3"),(X"2A"),(X"F8"),(X"00"),(X"AD"),(X"BD"),(X"F8"),(X"3B"),
			(X"A3"),(X"D3"),(X"FB"),(X"24"),(X"32"),(X"D6"),(X"FB"),(X"05"),
			(X"A1"),(X"CE"),(X"FB"),(X"1E"),(X"3A"),(X"42"),(X"D3"),(X"FB"),
			(X"4D"),(X"3A"),(X"CA"),(X"D3"),(X"3B"),(X"5B"),(X"D3"),(X"33"),
			(X"5E"),(X"FB"),(X"20"),(X"3A"),(X"CA"),(X"9D"),(X"B0"),(X"8D"),
			(X"A0"),(X"81"),(X"32"),(X"B4"),(X"F8"),(X"00"),(X"AD"),(X"BD"),
			(X"D3"),(X"33"),(X"70"),(X"FB"),(X"0D"),(X"3A"),(X"CA"),(X"F8"),
			(X"9C"),(X"A3"),(X"8D"),(X"A1"),(X"9D"),(X"B1"),(X"D3"),(X"0A"),
			(X"90"),(X"BF"),(X"F8"),(X"AE"),(X"A3"),(X"D3"),(X"80"),(X"BF"),
			(X"F8"),(X"AE"),(X"A3"),(X"D3"),(X"D3"),(X"20"),(X"40"),(X"BF"),
			(X"F8"),(X"AE"),(X"A3"),(X"D3"),(X"21"),(X"81"),(X"3A"),(X"9B"),
			(X"91"),(X"32"),(X"39"),(X"80"),(X"FA"),(X"0F"),(X"3A"),(X"A6"),
			(X"D3"),(X"3B"),(X"D3"),(X"0D"),(X"30"),(X"7E"),(X"F6"),(X"33"),
			(X"8E"),(X"30"),(X"8C"),(X"D3"),(X"3B"),(X"AB"),(X"D3"),(X"3B"),
			(X"CA"),(X"8D"),(X"50"),(X"10"),(X"D3"),(X"33"),(X"AE"),(X"FB"),
			(X"0D"),(X"32"),(X"39"),(X"FB"),(X"21"),(X"32"),(X"AB"),(X"FB"),
			(X"17"),(X"3A"),(X"B4"),(X"D3"),(X"FB"),(X"0D"),(X"3A"),(X"C3"),
			(X"30"),(X"5B"),(X"F8"),(X"9C"),(X"A3"),(X"D3"),(X"0D"),(X"C0"),
			(X"81"),(X"F8"),(X"00"),(X"00"),(X"00"),(X"00"),(X"D3"),(X"FB"),
			(X"50"),(X"3A"),(X"CA"),(X"D3"),(X"33"),(X"DB"),(X"FB"),(X"0D"),
			(X"3A"),(X"CA"),(X"9D"),(X"B0"),(X"8D"),(X"A0"),(X"F8"),(X"9C"),
			(X"A3"),(X"D3"),(X"0A"),(X"E5"),(X"70"),(X"00"),(X"D3"),(X"9E"),
			(X"F6"),(X"AE"),(X"2E"),(X"43"),(X"FF"),(X"01"),(X"3A"),(X"F4"),
			(X"8E"),(X"32"),(X"EE"),(X"23"),(X"30"),(X"F2"),(X"93"),(X"BC"),
			(X"F8"),(X"00"),(X"AE"),(X"AF"),(X"F8"),(X"EF"),(X"AC"),(X"37"),
			(X"07"),(X"3F"),(X"09"),(X"F8"),(X"03"),(X"FF"),(X"01"),(X"3A"),
			(X"0D"),(X"8F"),(X"3A"),(X"17"),(X"37"),(X"19"),(X"1F"),(X"37"),
			(X"1E"),(X"1E"),(X"F8"),(X"07"),(X"30"),(X"0D"),(X"2E"),(X"2E"),
			(X"8E"),(X"F9"),(X"01"),(X"BE"),(X"DC"),(X"0C"),(X"3F"),(X"2C"),
			(X"9E"),(X"FA"),(X"FE"),(X"BE"),(X"DC"),(X"26"),(X"D5"),(X"FC"),
			(X"07"),(X"33"),(X"37"),(X"FC"),(X"0A"),(X"33"),(X"87"),(X"FC"),
			(X"00"),(X"9F"),(X"D5"),(X"F8"),(X"00"),(X"38"),(X"83"),(X"C8"),
			(X"F8"),(X"01"),(X"AF"),(X"F8"),(X"80"),(X"BF"),(X"E3"),(X"8F"),
			(X"F6"),(X"3B"),(X"4D"),(X"67"),(X"80"),(X"3F"),(X"4D"),(X"37"),
			(X"4F"),(X"DC"),(X"02"),(X"37"),(X"4F"),(X"8F"),(X"F6"),(X"3B"),
			(X"5B"),(X"67"),(X"40"),(X"E2"),(X"C4"),(X"9E"),(X"F6"),(X"33"),
			(X"68"),(X"37"),(X"66"),(X"7B"),(X"30"),(X"68"),(X"7A"),(X"C4"),
			(X"DC"),(X"07"),(X"C4"),(X"C4"),(X"9F"),(X"F6"),(X"BF"),(X"33"),
			(X"78"),(X"F9"),(X"80"),(X"3F"),(X"5B"),(X"BF"),(X"30"),(X"5D"),
			(X"7A"),(X"32"),(X"43"),(X"8F"),(X"3A"),(X"39"),(X"9F"),(X"FF"),
			(X"41"),(X"3B"),(X"2F"),(X"FF"),(X"06"),(X"33"),(X"37"),(X"FE"),
			(X"FE"),(X"FE"),(X"FE"),(X"FC"),(X"08"),(X"FE"),(X"AE"),(X"8D"),
			(X"7E"),(X"AD"),(X"9D"),(X"7E"),(X"BD"),(X"8E"),(X"FE"),(X"3A"),
			(X"8E"),(X"30"),(X"39"),(X"00"),(X"DC"),(X"17"),(X"38"),(X"D5"),
			(X"45"),(X"38"),(X"46"),(X"38"),(X"9F"),(X"AE"),(X"FB"),(X"0A"),
			(X"3A"),(X"BF"),(X"F8"),(X"8B"),(X"30"),(X"C1"),(X"9F"),(X"F6"),
			(X"F6"),(X"F6"),(X"F6"),(X"FC"),(X"F6"),(X"3B"),(X"B9"),(X"FC"),
			(X"07"),(X"FF"),(X"C6"),(X"AE"),(X"F8"),(X"1B"),(X"C8"),(X"F8"),
			(X"0B"),(X"AF"),(X"7B"),(X"8E"),(X"AD"),(X"DC"),(X"07"),(X"2F"),
			(X"F5"),(X"8D"),(X"76"),(X"AD"),(X"33"),(X"D1"),(X"7B"),(X"30"),
			(X"D3"),(X"7A"),(X"C4"),(X"8F"),(X"FA"),(X"0F"),(X"C4"),(X"C4"),
			(X"3A"),(X"C5"),(X"8F"),(X"FC"),(X"FB"),(X"AF"),(X"3B"),(X"9F"),
			(X"FF"),(X"1B"),(X"32"),(X"9F"),(X"3B"),(X"EA"),(X"F8"),(X"00"),
			(X"30"),(X"F5"),(X"9F"),(X"FA"),(X"0F"),(X"FC"),(X"F6"),(X"3B"),
			(X"F3"),(X"FC"),(X"07"),(X"FF"),(X"C6"),(X"AE"),(X"30"),(X"C2"),
			(X"D3"),(X"0A"),(X"D3"),(X"3F"),(X"C0"),(X"80"),(X"39"),(X"00"));

begin

	process(clock)
	begin
		if(rising_edge(clock))then
			if(rd_n = '0' and cs_n = '0')then
				data_out <= rom(to_integer(unsigned(address)));
			else
				data_out <= "00000000";
			end if;
		end if;
	end process;
	
end rtl;

