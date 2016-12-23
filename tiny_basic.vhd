---------------------------------------------------------------------------------------------------
-- TinyBasic ROM image as listed in MPM-203 "Evaluation Kit Manual for the RCA CDP1802"
-- Author: Tom Pittman
-- TinyBasic interpreter Copyright 1976 Itty Bitty Computers, used by permission
-- http://www.ittybittycomputers.com/IttyBitty/TinyBasic/
-- http://www.retrotechnology.com/memship/mship_tbasic.html
---------------------------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tiny_basic is 
	port(  
		clock:		in std_logic;
		cs_n:		in std_logic;
		rd_n:       in std_logic;
		address:    in std_logic_vector(10 downto 0);
		data_out:   out std_logic_vector(7 downto 0));
end tiny_basic;

architecture rtl of tiny_basic is

	type rom_type is array(0 to 2047) of std_logic_vector(7 downto 0);
	
	signal rom : rom_type := (
			(X"01"),(X"30"),(X"B0"),(X"C0"),(X"00"),(X"ED"),(X"C0"),(X"06"),
			(X"6F"),(X"C0"),(X"06"),(X"76"),(X"C0"),(X"06"),(X"66"),(X"5F"),
			(X"18"),(X"82"),(X"80"),(X"20"),(X"30"),(X"22"),(X"30"),(X"20"),
			(X"58"),(X"D5"),(X"06"),(X"81"),(X"08"),(X"C8"),(X"00"),(X"08"),
			(X"48"),(X"38"),(X"97"),(X"BA"),(X"48"),(X"D5"),(X"C0"),(X"06"),
			(X"51"),(X"D3"),(X"BF"),(X"E2"),(X"86"),(X"73"),(X"96"),(X"73"),
			(X"83"),(X"A6"),(X"93"),(X"B6"),(X"46"),(X"B3"),(X"46"),(X"A3"),
			(X"9F"),(X"30"),(X"29"),(X"D3"),(X"BF"),(X"E2"),(X"96"),(X"B3"),
			(X"86"),(X"A3"),(X"12"),(X"42"),(X"B6"),(X"02"),(X"A6"),(X"9F"),
			(X"30"),(X"3B"),(X"D3"),(X"43"),(X"AD"),(X"F8"),(X"08"),(X"BD"),
			(X"4D"),(X"ED"),(X"30"),(X"4A"),(X"01"),(X"98"),(X"01"),(X"A0"),
			(X"02"),(X"1F"),(X"01"),(X"DD"),(X"01"),(X"F0"),(X"01"),(X"D4"),
			(X"04"),(X"81"),(X"02"),(X"49"),(X"00"),(X"ED"),(X"04"),(X"4E"),
			(X"01"),(X"04"),(X"05"),(X"A2"),(X"01"),(X"D3"),(X"01"),(X"D3"),
			(X"04"),(X"AA"),(X"01"),(X"D3"),(X"01"),(X"D3"),(X"02"),(X"C5"),
			(X"02"),(X"D5"),(X"03"),(X"03"),(X"02"),(X"79"),(X"03"),(X"18"),
			(X"05"),(X"3C"),(X"01"),(X"D3"),(X"04"),(X"29"),(X"03"),(X"6C"),
			(X"03"),(X"CB"),(X"03"),(X"A7"),(X"03"),(X"98"),(X"03"),(X"9B"),
			(X"04"),(X"0E"),(X"04"),(X"60"),(X"04"),(X"6D"),(X"05"),(X"81"),
			(X"01"),(X"B6"),(X"02"),(X"67"),(X"03"),(X"48"),(X"03"),(X"4B"),
			(X"01"),(X"D3"),(X"01"),(X"D3"),(X"01"),(X"C9"),(X"01"),(X"C5"),
			(X"02"),(X"4E"),(X"02"),(X"44"),(X"02"),(X"41"),(X"01"),(X"D3"),
			(X"F8"),(X"B3"),(X"A3"),(X"F8"),(X"00"),(X"B3"),(X"D3"),(X"BA"),
			(X"F8"),(X"1C"),(X"AA"),(X"4A"),(X"B2"),(X"4A"),(X"A2"),(X"4A"),
			(X"BD"),(X"F8"),(X"00"),(X"AD"),(X"0D"),(X"BF"),(X"E2"),(X"12"),
			(X"F0"),(X"AF"),(X"FB"),(X"FF"),(X"52"),(X"F3"),(X"ED"),(X"C6"),
			(X"9F"),(X"F3"),(X"FC"),(X"FF"),(X"8F"),(X"52"),(X"3B"),(X"C6"),
			(X"22"),(X"0A"),(X"BD"),(X"F8"),(X"23"),(X"AD"),(X"82"),(X"73"),
			(X"92"),(X"73"),(X"2A"),(X"2A"),(X"0A"),(X"73"),(X"8D"),(X"FB"),
			(X"12"),(X"3A"),(X"E3"),(X"F6"),(X"C8"),(X"FF"),(X"00"),(X"F8"),
			(X"F2"),(X"A3"),(X"F8"),(X"00"),(X"B3"),(X"D3"),(X"B4"),(X"B5"),
			(X"B7"),(X"F8"),(X"2A"),(X"A4"),(X"F8"),(X"3C"),(X"A5"),(X"F8"),
			(X"4B"),(X"A7"),(X"33"),(X"1A"),(X"D7"),(X"20"),(X"BB"),(X"4D"),
			(X"AB"),(X"97"),(X"5B"),(X"1B"),(X"5B"),(X"D7"),(X"16"),(X"8B"),
			(X"F4"),(X"BF"),(X"D7"),(X"24"),(X"9F"),(X"73"),(X"9B"),(X"7C"),
			(X"00"),(X"73"),(X"D7"),(X"22"),(X"B2"),(X"4D"),(X"A2"),(X"D7"),
			(X"26"),(X"82"),(X"73"),(X"92"),(X"73"),(X"D4"),(X"02"),(X"CC"),
			(X"D7"),(X"1E"),(X"B9"),(X"4D"),(X"A9"),(X"E2"),(X"49"),(X"FF"),
			(X"30"),(X"33"),(X"4B"),(X"FD"),(X"D7"),(X"33"),(X"85"),(X"FE"),
			(X"FC"),(X"B0"),(X"A6"),(X"F8"),(X"2D"),(X"22"),(X"22"),(X"73"),
			(X"93"),(X"73"),(X"97"),(X"B6"),(X"46"),(X"52"),(X"46"),(X"A6"),
			(X"F0"),(X"B6"),(X"D5"),(X"FF"),(X"10"),(X"3B"),(X"6A"),(X"A6"),
			(X"FA"),(X"1F"),(X"32"),(X"5C"),(X"52"),(X"89"),(X"F4"),(X"73"),
			(X"99"),(X"7C"),(X"00"),(X"38"),(X"73"),(X"73"),(X"86"),(X"F6"),
			(X"F6"),(X"F6"),(X"F6"),(X"FA"),(X"FE"),(X"FC"),(X"54"),(X"A6"),
			(X"30"),(X"42"),(X"FC"),(X"08"),(X"FA"),(X"07"),(X"B6"),(X"49"),
			(X"A6"),(X"33"),(X"7A"),(X"89"),(X"73"),(X"99"),(X"73"),(X"D4"),
			(X"02"),(X"37"),(X"D7"),(X"1E"),(X"86"),(X"F4"),(X"A9"),(X"96"),
			(X"2D"),(X"74"),(X"B9"),(X"30"),(X"2D"),(X"FD"),(X"07"),(X"52"),
			(X"D7"),(X"1A"),(X"AD"),(X"E2"),(X"F4"),(X"A6"),(X"9D"),(X"B6"),
			(X"0D"),(X"52"),(X"06"),(X"5D"),(X"02"),(X"56"),(X"30"),(X"2D"),
			(X"86"),(X"FF"),(X"20"),(X"A6"),(X"96"),(X"7F"),(X"00"),(X"38"),
			(X"96"),(X"C2"),(X"02"),(X"7F"),(X"B9"),(X"86"),(X"A9"),(X"30"),
			(X"2D"),(X"1B"),(X"0B"),(X"FF"),(X"20"),(X"32"),(X"A9"),(X"FF"),
			(X"10"),(X"C7"),(X"FD"),(X"09"),(X"0B"),(X"D5"),(X"D4"),(X"01"),
			(X"C5"),(X"4D"),(X"AD"),(X"9A"),(X"5D"),(X"1D"),(X"8A"),(X"5D"),
			(X"30"),(X"C9"),(X"D4"),(X"01"),(X"C5"),(X"D4"),(X"01"),(X"C9"),
			(X"BA"),(X"D7"),(X"1A"),(X"2D"),(X"FC"),(X"01"),(X"5D"),(X"AD"),
			(X"2D"),(X"4D"),(X"AA"),(X"D5"),(X"D4"),(X"01"),(X"AA"),(X"FB"),
			(X"0D"),(X"32"),(X"2D"),(X"30"),(X"A0"),(X"D4"),(X"01"),(X"AA"),
			(X"FF"),(X"41"),(X"3B"),(X"A0"),(X"FF"),(X"1A"),(X"33"),(X"A0"),
			(X"1B"),(X"9F"),(X"FE"),(X"D4"),(X"02"),(X"59"),(X"30"),(X"2D"),
			(X"D4"),(X"01"),(X"AA"),(X"3B"),(X"A0"),(X"97"),(X"BA"),(X"AA"),
			(X"D4"),(X"02"),(X"54"),(X"4B"),(X"FA"),(X"0F"),(X"AA"),(X"97"),
			(X"BA"),(X"F8"),(X"0A"),(X"AF"),(X"ED"),(X"1D"),(X"8A"),(X"F4"),
			(X"AA"),(X"9A"),(X"2D"),(X"74"),(X"BA"),(X"2F"),(X"8F"),(X"3A"),
			(X"05"),(X"9A"),(X"5D"),(X"1D"),(X"8A"),(X"73"),(X"D4"),(X"01"),
			(X"AA"),(X"C3"),(X"01"),(X"FB"),(X"C0"),(X"01"),(X"2D"),(X"9B"),
			(X"BA"),(X"8B"),(X"AA"),(X"D4"),(X"01"),(X"AA"),(X"1B"),(X"52"),
			(X"49"),(X"F3"),(X"32"),(X"23"),(X"FB"),(X"80"),(X"32"),(X"1C"),
			(X"9A"),(X"BB"),(X"8A"),(X"AB"),(X"C0"),(X"01"),(X"A0"),(X"D7"),
			(X"24"),(X"82"),(X"F5"),(X"2D"),(X"92"),(X"75"),(X"33"),(X"7F"),
			(X"D5"),(X"49"),(X"30"),(X"59"),(X"49"),(X"BA"),(X"49"),(X"30"),
			(X"55"),(X"D4"),(X"05"),(X"25"),(X"30"),(X"55"),(X"D4"),(X"01"),
			(X"C5"),(X"D4"),(X"02"),(X"54"),(X"8A"),(X"D4"),(X"02"),(X"59"),
			(X"9A"),(X"52"),(X"D7"),(X"19"),(X"F7"),(X"33"),(X"7F"),(X"F8"),
			(X"01"),(X"F5"),(X"5D"),(X"AD"),(X"02"),(X"5D"),(X"D5"),(X"D4"),
			(X"01"),(X"C9"),(X"AD"),(X"4D"),(X"BA"),(X"4D"),(X"30"),(X"55"),
			(X"FB"),(X"2F"),(X"32"),(X"66"),(X"FB"),(X"22"),(X"D4"),(X"02"),
			(X"F4"),(X"4B"),(X"FB"),(X"0D"),(X"3A"),(X"70"),(X"29"),(X"D7"),
			(X"18"),(X"B8"),(X"D4"),(X"02"),(X"CC"),(X"F8"),(X"21"),(X"D4"),
			(X"02"),(X"F4"),(X"D7"),(X"1E"),(X"89"),(X"F7"),(X"AA"),(X"99"),
			(X"2D"),(X"77"),(X"BA"),(X"D4"),(X"03"),(X"15"),(X"98"),(X"32"),
			(X"A9"),(X"F8"),(X"BD"),(X"A9"),(X"93"),(X"B9"),(X"D4"),(X"02"),
			(X"C5"),(X"D7"),(X"28"),(X"BA"),(X"4D"),(X"AA"),(X"D4"),(X"03"),
			(X"15"),(X"F8"),(X"07"),(X"D4"),(X"00"),(X"09"),(X"D4"),(X"02"),
			(X"D5"),(X"D7"),(X"1A"),(X"97"),(X"5D"),(X"D7"),(X"26"),(X"B2"),
			(X"4D"),(X"A2"),(X"C0"),(X"01"),(X"28"),(X"20"),(X"41"),(X"54"),
			(X"20"),(X"A3"),(X"D4"),(X"02"),(X"F2"),(X"49"),(X"FC"),(X"80"),
			(X"3B"),(X"C2"),(X"30"),(X"F2"),(X"D7"),(X"19"),(X"F8"),(X"80"),
			(X"73"),(X"97"),(X"73"),(X"73"),(X"C8"),(X"D7"),(X"1B"),(X"FE"),
			(X"33"),(X"66"),(X"D7"),(X"15"),(X"AA"),(X"F8"),(X"0D"),(X"D4"),
			(X"00"),(X"09"),(X"D7"),(X"1A"),(X"8A"),(X"FE"),(X"32"),(X"EF"),
			(X"2A"),(X"97"),(X"C7"),(X"F8"),(X"FF"),(X"30"),(X"DF"),(X"73"),
			(X"F8"),(X"8A"),(X"FF"),(X"80"),(X"BF"),(X"D7"),(X"1B"),(X"2D"),
			(X"FC"),(X"81"),(X"FC"),(X"80"),(X"3B"),(X"66"),(X"5D"),(X"9F"),
			(X"C0"),(X"00"),(X"09"),(X"D7"),(X"1B"),(X"FA"),(X"07"),(X"FD"),
			(X"08"),(X"AA"),(X"8A"),(X"32"),(X"97"),(X"F8"),(X"20"),(X"D4"),
			(X"02"),(X"F4"),(X"2A"),(X"30"),(X"0A"),(X"D4"),(X"02"),(X"54"),
			(X"D7"),(X"1A"),(X"AD"),(X"D4"),(X"04"),(X"13"),(X"3B"),(X"25"),
			(X"F8"),(X"2D"),(X"D4"),(X"02"),(X"F4"),(X"97"),(X"73"),(X"BA"),
			(X"F8"),(X"0A"),(X"D4"),(X"02"),(X"55"),(X"1D"),(X"D4"),(X"03"),
			(X"E3"),(X"8A"),(X"F6"),(X"F9"),(X"30"),(X"73"),(X"1D"),(X"4D"),
			(X"ED"),(X"F1"),(X"2D"),(X"2D"),(X"3A"),(X"2E"),(X"12"),(X"02"),
			(X"C2"),(X"01"),(X"C2"),(X"D4"),(X"02"),(X"F4"),(X"30"),(X"3E"),
			(X"D7"),(X"2E"),(X"38"),(X"9B"),(X"FB"),(X"08"),(X"3A"),(X"5E"),
			(X"8B"),(X"52"),(X"F0"),(X"FF"),(X"80"),(X"33"),(X"5E"),(X"D7"),
			(X"2E"),(X"8B"),(X"73"),(X"9B"),(X"5D"),(X"D5"),(X"D7"),(X"2E"),
			(X"B8"),(X"0D"),(X"A8"),(X"8B"),(X"73"),(X"9B"),(X"5D"),(X"98"),
			(X"BB"),(X"88"),(X"AB"),(X"D5"),(X"D4"),(X"01"),(X"C5"),(X"9A"),
			(X"FB"),(X"80"),(X"73"),(X"8A"),(X"73"),(X"D4"),(X"01"),(X"C9"),
			(X"AF"),(X"D4"),(X"01"),(X"C5"),(X"12"),(X"8A"),(X"F7"),(X"AA"),
			(X"12"),(X"9A"),(X"FB"),(X"80"),(X"77"),(X"52"),(X"3B"),(X"92"),
			(X"8A"),(X"F1"),(X"32"),(X"8F"),(X"8F"),(X"F6"),(X"38"),(X"8F"),
			(X"F6"),(X"38"),(X"8F"),(X"F6"),(X"C7"),(X"C4"),(X"19"),(X"D5"),
			(X"D4"),(X"04"),(X"0E"),(X"D4"),(X"01"),(X"C5"),(X"ED"),(X"1D"),
			(X"8A"),(X"F4"),(X"73"),(X"9A"),(X"74"),(X"5D"),(X"D5"),(X"D4"),
			(X"01"),(X"C5"),(X"F8"),(X"10"),(X"AF"),(X"4D"),(X"B8"),(X"0D"),
			(X"A8"),(X"0D"),(X"FE"),(X"5D"),(X"2D"),(X"0D"),(X"7E"),(X"5D"),
			(X"D4"),(X"04"),(X"22"),(X"3B"),(X"C5"),(X"ED"),(X"1D"),(X"88"),
			(X"F4"),(X"73"),(X"98"),(X"74"),(X"5D"),(X"2F"),(X"8F"),(X"1D"),
			(X"3A"),(X"B1"),(X"D5"),(X"D4"),(X"01"),(X"C5"),(X"9A"),(X"52"),
			(X"8A"),(X"F1"),(X"C2"),(X"02"),(X"7F"),(X"0D"),(X"F3"),(X"73"),
			(X"D4"),(X"04"),(X"13"),(X"2D"),(X"2D"),(X"D4"),(X"04"),(X"13"),
			(X"1D"),(X"97"),(X"C8"),(X"97"),(X"73"),(X"AA"),(X"BA"),(X"F8"),
			(X"11"),(X"AF"),(X"ED"),(X"8A"),(X"F7"),(X"52"),(X"2D"),(X"9A"),
			(X"77"),(X"3B"),(X"F6"),(X"BA"),(X"02"),(X"AA"),(X"1D"),(X"1D"),
			(X"1D"),(X"F0"),(X"7E"),(X"73"),(X"F0"),(X"7E"),(X"73"),(X"8A"),
			(X"7E"),(X"D4"),(X"04"),(X"24"),(X"2F"),(X"8F"),(X"CA"),(X"03"),
			(X"EA"),(X"12"),(X"02"),(X"FE"),(X"3B"),(X"21"),(X"D7"),(X"1A"),
			(X"AD"),(X"30"),(X"18"),(X"ED"),(X"F0"),(X"FE"),(X"3B"),(X"21"),
			(X"1D"),(X"97"),(X"F7"),(X"73"),(X"97"),(X"77"),(X"5D"),(X"FF"),
			(X"00"),(X"D5"),(X"8A"),(X"FE"),(X"AA"),(X"9A"),(X"7E"),(X"BA"),
			(X"D5"),(X"D7"),(X"18"),(X"C2"),(X"02"),(X"B1"),(X"4B"),(X"FB"),
			(X"0D"),(X"3A"),(X"2E"),(X"D4"),(X"05"),(X"98"),(X"32"),(X"4B"),
			(X"D4"),(X"00"),(X"0C"),(X"33"),(X"46"),(X"D7"),(X"1C"),(X"B9"),
			(X"4D"),(X"A9"),(X"D7"),(X"17"),(X"5D"),(X"D5"),(X"D7"),(X"1E"),
			(X"B9"),(X"4D"),(X"A9"),(X"C0"),(X"02"),(X"7F"),(X"D7"),(X"20"),
			(X"BB"),(X"4D"),(X"AB"),(X"D4"),(X"05"),(X"98"),(X"32"),(X"4B"),
			(X"D7"),(X"1C"),(X"89"),(X"73"),(X"99"),(X"5D"),(X"30"),(X"42"),
			(X"D4"),(X"04"),(X"FE"),(X"32"),(X"38"),(X"D7"),(X"28"),(X"8A"),
			(X"73"),(X"9A"),(X"5D"),(X"30"),(X"4B"),(X"D4"),(X"04"),(X"8B"),
			(X"42"),(X"BA"),(X"02"),(X"AA"),(X"D7"),(X"26"),(X"82"),(X"73"),
			(X"92"),(X"73"),(X"D4"),(X"05"),(X"01"),(X"3A"),(X"65"),(X"30"),
			(X"88"),(X"D4"),(X"04"),(X"8B"),(X"42"),(X"B9"),(X"02"),(X"A9"),
			(X"C0"),(X"01"),(X"2D"),(X"D7"),(X"22"),(X"12"),(X"12"),(X"82"),
			(X"FC"),(X"02"),(X"F3"),(X"2D"),(X"3A"),(X"9C"),(X"92"),(X"7C"),
			(X"00"),(X"F3"),(X"32"),(X"4B"),(X"12"),(X"D5"),(X"D7"),(X"16"),
			(X"38"),(X"97"),(X"FE"),(X"D7"),(X"1A"),(X"97"),(X"76"),(X"5D"),
			(X"30"),(X"B2"),(X"F8"),(X"30"),(X"AB"),(X"D4"),(X"02"),(X"54"),
			(X"9D"),(X"BB"),(X"D4"),(X"00"),(X"06"),(X"FA"),(X"7F"),(X"32"),
			(X"B2"),(X"52"),(X"FB"),(X"7F"),(X"32"),(X"B2"),(X"FB"),(X"75"),
			(X"32"),(X"9E"),(X"FB"),(X"19"),(X"32"),(X"A1"),(X"D7"),(X"13"),
			(X"02"),(X"F3"),(X"32"),(X"D7"),(X"2D"),(X"02"),(X"F3"),(X"3A"),
			(X"DD"),(X"2B"),(X"8B"),(X"FF"),(X"30"),(X"33"),(X"B2"),(X"F8"),
			(X"30"),(X"AB"),(X"F8"),(X"0D"),(X"38"),(X"02"),(X"5B"),(X"D7"),
			(X"19"),(X"8B"),(X"F7"),(X"3B"),(X"EC"),(X"F8"),(X"07"),(X"D4"),
			(X"02"),(X"F4"),(X"0B"),(X"38"),(X"4B"),(X"FB"),(X"0D"),(X"3A"),
			(X"B2"),(X"D4"),(X"02"),(X"D5"),(X"D7"),(X"18"),(X"8B"),(X"5D"),
			(X"F8"),(X"30"),(X"AB"),(X"C0"),(X"01"),(X"C5"),(X"D4"),(X"01"),
			(X"C5"),(X"8A"),(X"52"),(X"9A"),(X"F1"),(X"C2"),(X"02"),(X"7F"),
			(X"D7"),(X"20"),(X"BB"),(X"4D"),(X"AB"),(X"D4"),(X"05"),(X"98"),
			(X"C6"),(X"8D"),(X"D5"),(X"ED"),(X"8A"),(X"F5"),(X"52"),(X"9A"),
			(X"2D"),(X"75"),(X"E2"),(X"F1"),(X"33"),(X"12"),(X"4B"),(X"FB"),
			(X"0D"),(X"3A"),(X"1E"),(X"30"),(X"0D"),(X"D4"),(X"05"),(X"28"),
			(X"D4"),(X"01"),(X"C5"),(X"4D"),(X"B8"),(X"4D"),(X"A8"),(X"4D"),
			(X"B6"),(X"4D"),(X"A6"),(X"8D"),(X"52"),(X"D7"),(X"19"),(X"02"),
			(X"5D"),(X"AD"),(X"8A"),(X"D5"),(X"D7"),(X"2C"),(X"8B"),(X"73"),
			(X"9B"),(X"5D"),(X"D4"),(X"04"),(X"FE"),(X"D7"),(X"2A"),(X"8B"),
			(X"73"),(X"9B"),(X"73"),(X"D4"),(X"04"),(X"FE"),(X"2B"),(X"2B"),
			(X"D7"),(X"2A"),(X"8B"),(X"F7"),(X"2D"),(X"9B"),(X"77"),(X"33"),
			(X"7B"),(X"4B"),(X"BA"),(X"4B"),(X"AA"),(X"3A"),(X"62"),(X"9A"),
			(X"32"),(X"7B"),(X"D4"),(X"03"),(X"15"),(X"F8"),(X"2D"),(X"FB"),
			(X"0D"),(X"D4"),(X"02"),(X"F4"),(X"D4"),(X"00"),(X"0C"),(X"33"),
			(X"7B"),(X"4B"),(X"FB"),(X"0D"),(X"3A"),(X"67"),(X"D4"),(X"02"),
			(X"D5"),(X"30"),(X"50"),(X"D7"),(X"2C"),(X"BB"),(X"4D"),(X"AB"),
			(X"D5"),(X"D7"),(X"26"),(X"82"),(X"73"),(X"92"),(X"5D"),(X"D7"),
			(X"18"),(X"2D"),(X"CE"),(X"D7"),(X"28"),(X"AA"),(X"4D"),(X"12"),
			(X"12"),(X"E2"),(X"73"),(X"8A"),(X"73"),(X"C0"),(X"01"),(X"2D"),
			(X"D7"),(X"27"),(X"4B"),(X"5D"),(X"1D"),(X"4B"),(X"73"),(X"F1"),
			(X"1D"),(X"D5"),(X"D4"),(X"03"),(X"5E"),(X"D4"),(X"04"),(X"FE"),
			(X"FC"),(X"FF"),(X"97"),(X"AF"),(X"33"),(X"BA"),(X"9B"),(X"BD"),
			(X"8B"),(X"AD"),(X"2F"),(X"2F"),(X"2F"),(X"4D"),(X"FB"),(X"0D"),
			(X"3A"),(X"B4"),(X"2B"),(X"2B"),(X"D4"),(X"03"),(X"5E"),(X"D7"),
			(X"28"),(X"0B"),(X"FB"),(X"0D"),(X"73"),(X"5D"),(X"32"),(X"D9"),
			(X"9A"),(X"5D"),(X"1D"),(X"8A"),(X"5D"),(X"9B"),(X"BA"),(X"8B"),
			(X"AA"),(X"1F"),(X"1F"),(X"1F"),(X"4A"),(X"FB"),(X"0D"),(X"3A"),
			(X"D3"),(X"D7"),(X"2E"),(X"BA"),(X"4D"),(X"AA"),(X"D7"),(X"24"),
			(X"8A"),(X"F7"),(X"AA"),(X"2D"),(X"9A"),(X"77"),(X"BA"),(X"1D"),
			(X"8F"),(X"F4"),(X"BF"),(X"8F"),(X"FA"),(X"80"),(X"CE"),(X"F8"),
			(X"FF"),(X"2D"),(X"74"),(X"E2"),(X"73"),(X"B8"),(X"9F"),(X"73"),
			(X"52"),(X"82"),(X"F5"),(X"98"),(X"52"),(X"92"),(X"75"),(X"C3"),
			(X"02"),(X"7E"),(X"8F"),(X"32"),(X"30"),(X"52"),(X"FE"),(X"3B"),
			(X"1E"),(X"D7"),(X"2E"),(X"BF"),(X"4D"),(X"AF"),(X"E2"),(X"F7"),
			(X"A8"),(X"9F"),(X"7C"),(X"00"),(X"B8"),(X"48"),(X"5F"),(X"1F"),
			(X"1A"),(X"9A"),(X"3A"),(X"15"),(X"30"),(X"30"),(X"9F"),(X"AF"),
			(X"98"),(X"BF"),(X"D7"),(X"24"),(X"B8"),(X"4D"),(X"A8"),(X"2A"),
			(X"EF"),(X"08"),(X"28"),(X"73"),(X"1A"),(X"9A"),(X"3A"),(X"29"),
			(X"D7"),(X"24"),(X"12"),(X"42"),(X"73"),(X"02"),(X"5D"),(X"D7"),
			(X"2E"),(X"BA"),(X"4D"),(X"AA"),(X"D7"),(X"28"),(X"AF"),(X"F1"),
			(X"32"),(X"4E"),(X"8F"),(X"5A"),(X"1A"),(X"4D"),(X"5A"),(X"1A"),
			(X"4B"),(X"5A"),(X"FB"),(X"0D"),(X"3A"),(X"47"),(X"C0"),(X"02"),
			(X"B5"),(X"73"),(X"52"),(X"97"),(X"BA"),(X"2D"),(X"43"),(X"D5"),
			(X"5D"),(X"2D"),(X"88"),(X"FA"),(X"0F"),(X"F9"),(X"60"),(X"5D"),
			(X"FA"),(X"08"),(X"CE"),(X"C4"),(X"12"),(X"DD"),(X"FC"),(X"00"),
			(X"37"),(X"6E"),(X"FF"),(X"00"),(X"3F"),(X"6C"),(X"D5"),(X"D7"),
			(X"11"),(X"8D"),(X"73"),(X"C0"),(X"81"),(X"40"),(X"D7"),(X"12"),
			(X"32"),(X"7E"),(X"DC"),(X"17"),(X"2D"),(X"5D"),(X"C0"),(X"81"),
			(X"A4"),(X"24"),(X"3A"),(X"91"),(X"27"),(X"10"),(X"E1"),(X"59"),
			(X"C3"),(X"2A"),(X"56"),(X"2C"),(X"8A"),(X"47"),(X"4F"),(X"54"),
			(X"CF"),(X"30"),(X"D0"),(X"10"),(X"11"),(X"EB"),(X"6C"),(X"8C"),
			(X"47"),(X"4F"),(X"53"),(X"55"),(X"C2"),(X"30"),(X"D0"),(X"10"),
			(X"11"),(X"E0"),(X"14"),(X"16"),(X"8B"),(X"4C"),(X"45"),(X"D4"),
			(X"A0"),(X"80"),(X"BD"),(X"30"),(X"D0"),(X"E0"),(X"13"),(X"1D"),
			(X"8C"),(X"50"),(X"D2"),(X"83"),(X"49"),(X"4E"),(X"D4"),(X"E1"),
			(X"62"),(X"85"),(X"BA"),(X"38"),(X"53"),(X"38"),(X"55"),(X"83"),
			(X"A2"),(X"21"),(X"63"),(X"30"),(X"D0"),(X"20"),(X"83"),(X"AC"),
			(X"22"),(X"62"),(X"84"),(X"BB"),(X"E1"),(X"67"),(X"4A"),(X"83"),
			(X"DE"),(X"24"),(X"93"),(X"E0"),(X"23"),(X"1D"),(X"91"),(X"49"),
			(X"C6"),(X"30"),(X"D0"),(X"31"),(X"1F"),(X"30"),(X"D0"),(X"84"),
			(X"54"),(X"48"),(X"45"),(X"CE"),(X"1C"),(X"1D"),(X"38"),(X"0B"),
			(X"9B"),(X"49"),(X"CE"),(X"83"),(X"50"),(X"55"),(X"D4"),(X"A0"),
			(X"10"),(X"E7"),(X"24"),(X"3F"),(X"20"),(X"91"),(X"27"),(X"E1"),
			(X"59"),(X"81"),(X"AC"),(X"30"),(X"D0"),(X"13"),(X"11"),(X"82"),
			(X"AC"),(X"4D"),(X"E0"),(X"1D"),(X"8A"),(X"52"),(X"45"),(X"D4"),
			(X"83"),(X"55"),(X"52"),(X"CE"),(X"E0"),(X"15"),(X"1D"),(X"85"),
			(X"45"),(X"4E"),(X"C4"),(X"E0"),(X"2D"),(X"87"),(X"52"),(X"55"),
			(X"CE"),(X"10"),(X"11"),(X"38"),(X"0A"),(X"84"),(X"4E"),(X"45"),
			(X"D7"),(X"2B"),(X"9F"),(X"4C"),(X"49"),(X"53"),(X"D4"),(X"E7"),
			(X"0A"),(X"00"),(X"01"),(X"0A"),(X"7F"),(X"FF"),(X"65"),(X"30"),
			(X"D0"),(X"30"),(X"CB"),(X"E0"),(X"24"),(X"00"),(X"00"),(X"00"),
			(X"00"),(X"00"),(X"00"),(X"0A"),(X"80"),(X"1F"),(X"24"),(X"93"),
			(X"23"),(X"1D"),(X"84"),(X"52"),(X"45"),(X"CD"),(X"1D"),(X"A0"),
			(X"80"),(X"BD"),(X"38"),(X"2A"),(X"82"),(X"AC"),(X"62"),(X"0B"),
			(X"2F"),(X"85"),(X"AD"),(X"30"),(X"E6"),(X"17"),(X"64"),(X"81"),
			(X"AB"),(X"30"),(X"E6"),(X"85"),(X"AB"),(X"30"),(X"E6"),(X"18"),
			(X"5A"),(X"93"),(X"AD"),(X"30"),(X"E6"),(X"19"),(X"54"),(X"30"),
			(X"F5"),(X"85"),(X"AA"),(X"30"),(X"F5"),(X"1A"),(X"5A"),(X"85"),
			(X"AF"),(X"30"),(X"F5"),(X"1B"),(X"54"),(X"2F"),(X"88"),(X"52"),
			(X"4E"),(X"44"),(X"A8"),(X"31"),(X"15"),(X"39"),(X"44"),(X"8E"),
			(X"55"),(X"53"),(X"52"),(X"A8"),(X"30"),(X"D0"),(X"30"),(X"CB"),
			(X"30"),(X"CB"),(X"31"),(X"1C"),(X"2E"),(X"2F"),(X"A2"),(X"12"),
			(X"2F"),(X"C1"),(X"2F"),(X"80"),(X"A8"),(X"65"),(X"30"),(X"D0"),
			(X"0B"),(X"80"),(X"AC"),(X"30"),(X"D0"),(X"80"),(X"A9"),(X"2F"),
			(X"84"),(X"BD"),(X"09"),(X"02"),(X"2F"),(X"83"),(X"3C"),(X"BE"),
			(X"74"),(X"85"),(X"3C"),(X"BD"),(X"09"),(X"03"),(X"2F"),(X"84"),
			(X"BC"),(X"09"),(X"01"),(X"2F"),(X"85"),(X"3E"),(X"BD"),(X"09"),
			(X"06"),(X"2F"),(X"85"),(X"3E"),(X"BC"),(X"09"),(X"05"),(X"2F"),
			(X"80"),(X"BE"),(X"09"),(X"04"),(X"2F"),(X"19"),(X"17"),(X"0A"),
			(X"00"),(X"01"),(X"18"),(X"09"),(X"80"),(X"09"),(X"80"),(X"12"),
			(X"0A"),(X"09"),(X"29"),(X"1A"),(X"0A"),(X"1A"),(X"85"),(X"18"),
			(X"08"),(X"13"),(X"09"),(X"80"),(X"12"),(X"03"),(X"01"),(X"02"),
			(X"31"),(X"6A"),(X"31"),(X"75"),(X"1B"),(X"1A"),(X"19"),(X"31"),
			(X"75"),(X"18"),(X"2F"),(X"0B"),(X"01"),(X"05"),(X"01"),(X"04"),
			(X"0B"),(X"01"),(X"07"),(X"01"),(X"06"),(X"2F"),(X"0B"),(X"09"),
			(X"06"),(X"0A"),(X"00"),(X"00"),(X"1C"),(X"17"),(X"2F"),(X"00"));

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

