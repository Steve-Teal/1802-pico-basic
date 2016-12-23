---------------------------------------------------------------------------------------------------
-- MX18 - CDP1802 Core
---------------------------------------------------------------------------------------------------
-- To save FPGA real estate this core has been coded in such away to try and persuade the synthesis
-- tool to implement the register file in distributed RAM. The core is designed to work with
-- synchronous memory. Interrupts, DMA and the SAV and MARK instructions have not been fully 
-- implemented as yet although this will be done on future releases. 
-- Each processor cycle or state uses 3 system clocks, a real 1802 uses 8.
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

entity mx18 is 
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
end mx18;

architecture rtl of mx18 is

	-- Timing and state signals
	type state_type is (initialize,f1,f2,f3,e1,e2,e3,l1,l2,l3);
	signal state        : state_type;
	signal init_counter : unsigned(3 downto 0);
	
	-- Major state signals
	signal fetch,execute,longbranch : std_logic;

	-- Register file
	type reg_file_type is array (0 to 15) of unsigned(15 downto 0);
	signal reg_file       : reg_file_type;
	signal reg_file_out   : unsigned(15 downto 0);
	signal reg_file_in    : unsigned(15 downto 0);
	signal reg_file_index : unsigned(3 downto 0);
	signal reg_file_adder : unsigned(15 downto 0);
	signal reg_br_mux     : unsigned(15 downto 0);
	
	-- Register file control
	signal rp,rx,rn,r2,r0 : std_logic;
	signal reg_inc, reg_dec, reg_load_lo, reg_load_hi : std_logic;
	
	
	-- Processor registers
	signal n : std_logic_vector(3 downto 0);
	signal i : std_logic_vector(3 downto 0);
	signal p : std_logic_vector(3 downto 0);
	signal x : std_logic_vector(3 downto 0);
	signal t : std_logic_vector(7 downto 0);
	signal d : std_logic_vector(7 downto 0);
	signal b : std_logic_vector(7 downto 0);  
	signal df : std_logic;
	signal ie : std_logic;
	signal qq : std_logic;
		
	-- ALU
	signal alu_a     : std_logic_vector(7 downto 0);
	signal alu_b     : std_logic_vector(7 downto 0);
	signal alu_out   : std_logic_vector(7 downto 0);
	signal adder     : unsigned(8 downto 0);
	signal carry_in  : std_logic;
	
	-- ALU Control 
	signal inv_d     : std_logic;
	signal inv_data_in     : std_logic;
	signal alu_fn    : std_logic_vector(1 downto 0);
	
	-- Instruction decode signals
	signal idl,ldn,inc,dec,sbr,lda,str,inp,outp,glo,ghi,plo,phi : std_logic;
	signal lbr,sep,sex,ret,dis,ldxa,stxd,sav,mark,reqseq : std_logic;
	signal rowf,shift,arithmetic,logic,immd,index : std_logic;
	
	-- Memory control
	signal memory_read,memory_write : std_logic;
	
	-- Branch control
	signal flag_mux, ef_mux, sbr_mux, branch_load_lo, branch_load_hi, branch_inc : std_logic;
	signal d_zero, ie_skip_inhibit : std_logic;
		
begin

	--
	-- State machine
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(reset_n = '0')then
				state <= initialize;
				init_counter <= "0000";
			else
				case state is
					when initialize =>
						if(init_counter = "1111")then
							state <= f1;
						end if;
						init_counter <= init_counter + 1;
					when f1 => state <= f2;
					when f2 => state <= f3;
					when f3 => state <= e1;
					when e1 => state <= e2;
					when e2 => state <= e3;
					when e3 =>
						if(idl = '1')then
							state <= e1;
						elsif(lbr = '1')then
							state <= l1;
						else
							state <= f1;
						end if;
					when l1 => state <= l2;
					when l2 => state <= l3;
					when l3 => state <= f1;
				end case;
			end if;
		end if;
	end process;
	
	--
	-- Major state logic
	--
	fetch <= '1' when state = f1 or state = f2 or state = f3 else '0';
	execute <= '1' when state = e1 or state = e2 or state = e3 else '0';
	longbranch <= '1' when state = l1 or state = l2 or state = l3 else '0';

	--
	-- Instruction Decoder
	--
	idl <= '1' when n = "0000" and i = "0000" else '0';
	ldn <= '1' when n /= "0000" and i = "0000" else '0';
	inc <= '1' when i = "0001" else '0';
	dec <= '1' when i = "0010" else '0';
	sbr <= '1' when i = "0011" else '0';
	lda <= '1' when i = "0100" else '0';
	str <= '1' when i = "0101" else '0';
	outp <= '1' when i = "0110" and n(3) = '0' else '0';
	inp  <= '1' when i = "0110" and n(3) = '1' else '0';
	ret <= '1' when i = "0111" and n = "0000" else '0';
	dis <= '1' when i = "0111" and n = "0001" else '0';
	ldxa <= '1' when i = "0111" and n = "0010" else '0';
	stxd <= '1' when i = "0111" and n = "0011" else '0';
	sav <= '1' when i = "0111" and n = "1000" else '0';
	mark <= '1' when i = "0111" and n = "1001" else '0';
	reqseq <= '1' when i = "0111" and n(3 downto 1) = "101" else '0';
	glo <= '1' when i = "1000" else '0';
	ghi <= '1' when i = "1001" else '0';
	plo <= '1' when i = "1010" else '0';
	phi <= '1' when i = "1011" else '0';
	lbr <= '1' when i = "1100" else '0';
	sep <= '1' when i = "1101" else '0';
	sex <= '1' when i = "1110" else '0';
	shift <= '1' when i(2 downto 0) = "111" and n(2 downto 0) = "110" else '0';
	arithmetic <= '1' when i(2 downto 0) = "111" and  n(2) = '1' else '0';
	logic <= '1' when i = "1111" and n(2) = '0' and (n(0) = '1' or n(1) = '1') else '0';
	rowf <= '1' when i = "1111" else '0';
	immd <= '1' when (i = "0111" and n(3 downto 2) = "11") or (i = "1111" and n(3)='1') else '0';
	index <= '1' when (i = "0111" and n(3 downto 2) = "01") or (i = "1111" and n(3)='0') else '0';
	
	--
	-- ALU and associated control logic
	--
	inv_data_in <= n(0) and n(1) and n(2);
	inv_d <= n(2) and n(0) and not n(1);
	carry_in <= (df and not i(3)) or (i(3) and (inv_data_in or inv_d));
	alu_fn(0) <= n(0) and not n(2);
	alu_fn(1) <= n(1) and not n(2);
	
	alu_a <= not data_in when inv_data_in = '1' else data_in;
	alu_b <= not d when inv_d = '1' else d;
	
	adder <= ('0' & unsigned(alu_a)) + ('0' & unsigned(alu_b)) + ("00000000" & carry_in);
		
	with alu_fn(1 downto 0) select alu_out <=
		std_logic_vector(adder(7 downto 0)) when "00",
		alu_a or alu_b  when "01",
		alu_a and alu_b when "10",
		alu_a xor alu_b when others;
		
	--
	-- DF Register
	--  
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				df <= '0';
			elsif(state = e3)then
				if(shift = '1')then
					if(n(3) = '1')then
						df <= d(7);
					else
						df <= d(0);
					end if;
				elsif(arithmetic = '1')then
					df <= adder(8);
				end if;
			end if;
		end if;
	end process;
	
	--
	-- D Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				d <= "00000000";
			elsif(state = e3)then
				if(shift = '1')then
					if(n(3) = '1')then
						d <= d(6 downto 0) & carry_in;
					else
						d <= carry_in & d(7 downto 1);
					end if;
				elsif(arithmetic = '1' or logic = '1')then
					d <= alu_out;
				elsif(glo = '1')then
					d <= std_logic_vector(reg_file_out(7 downto 0));
				elsif(ghi = '1')then
					d <= std_logic_vector(reg_file_out(15 downto 8));
				elsif(ldn = '1' or lda = '1' or ldxa = '1' or inp = '1' or rowf = '1')then
					d <= data_in;
				end if;
			end if;
		end if;
	end process;
	
	--
	-- B Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = e3 and lbr = '1')then
				b <= data_in;
			end if;
		end if;
	end process;
	
	--
	-- I:N Registers
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				n <= "0000";
				i <= "0000";
			elsif(state = f3)then
				n <= data_in(3 downto 0);
				i <= data_in(7 downto 4);
			end if;
		end if;
	end process;
	
	--
	-- X Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				x <= "0000";
			elsif(state = e3)then
				if(sex = '1')then
					x <= n;
				elsif(ret = '1' or dis = '1')then
					x <= data_in(7 downto 4);
				elsif(mark = '1')then
					x <= p;
				end if;
			end if;
		end if;
	end process;
				
	--
	-- P Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				p <= "0000";
			elsif(state = e3)then
				if(sep = '1')then
					p <= n;
				elsif(ret = '1' or dis = '1')then
					p <= data_in(3 downto 0);
				end if;
			end if;
		end if;
	end process;
	
	--
	-- Q Register
	-- 
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				qq <= '0';
			elsif(state = e3 and reqseq = '1')then
				qq <= n(0);
			end if;
		end if;
	end process;
	
	q <= qq;
	
	--
	-- IE Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				ie <= '0';
			elsif(state = e3)then
				if(ret = '1')then
					ie <= '1';
				elsif(dis = '1')then
					ie <= '0';
				end if;
			end if;
		end if;
	end process;
	
	--
	-- T Register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				t <= "00000000";
			elsif(state = e3 and mark = '1')then
				t <= x & p;
			end if;
		end if;
	end process;
	
	--
	-- Data out register
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize or state = e3)then
				data_out <= "00000000";
			elsif(state = e2)then
				if(str = '1' or stxd = '1')then
					data_out <= d;
				elsif(mark = '1' or sav = '1')then
					data_out <= t;
				end if;
			end if;
		end if;
	end process;
	
	--
	-- Register file read/write
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = f1 or state = e1 or state = l1)then
				reg_file_out <= reg_file(to_integer(reg_file_index));
			elsif(state = f3 or state = e3 or state = l3 or state = initialize)then
				reg_file(to_integer(reg_file_index)) <= reg_file_in;
			end if;
		end if;
	end process;
	
	address <= std_logic_vector(reg_file_out);
	
	--
	-- Register file indexing 
	--
	reg_file_index(0) <= init_counter(0) or (p(0) and rp) or (n(0) and rn) or (x(0) and rx);
	reg_file_index(1) <= init_counter(1) or (p(1) and rp) or (n(1) and rn) or (x(1) and rx) or r2;
	reg_file_index(2) <= init_counter(2) or (p(2) and rp) or (n(2) and rn) or (x(2) and rx);
	reg_file_index(3) <= init_counter(3) or (p(3) and rp) or (n(3) and rn) or (x(3) and rx);
	
	r0 <= execute and idl;
	r2 <= execute and mark;
	rp <= fetch or longbranch or sbr or lbr or (execute and (immd or reqseq));
	rx <= execute and (inp or outp or ret or dis or index or stxd or ldxa or sav);
	rn <= not (r0 or r2 or rp or rx);
	
	--
	-- Register file data path
	--
	reg_file_adder <= reg_file_out - 1 when reg_dec = '1' else reg_file_out + 1 when reg_inc = '1' else X"0000" when state = initialize else reg_file_out;
	reg_file_in(7 downto 0) <= reg_br_mux(7 downto 0) when reg_load_lo = '1' else reg_file_adder(7 downto 0);
	reg_file_in(15 downto 8) <= reg_br_mux(15 downto 8) when reg_load_hi = '1' else reg_file_adder(15 downto 8);
	reg_br_mux <= unsigned(b) & unsigned(data_in) when (lbr or sbr) = '1' else unsigned(d) & unsigned(d);
	
	--
	-- Register file control
	--
	reg_dec <= execute and (dec or stxd);
	reg_inc <= fetch or (execute and (lda or inc or outp or immd or ldxa or ret or dis) and not shift) or ((execute or longbranch) and branch_inc);
	reg_load_lo <= (execute and (plo or branch_load_lo)) or (longbranch and branch_load_lo);
	reg_load_hi <= (execute and phi) or (longbranch and branch_load_hi);

	
	--
	-- Memory control
	--
	memory_read	<= (ldn or lda or sbr or outp or ret or dis or ldxa or lbr or immd or index) and not shift;
	memory_write <= str or inp or stxd or sav or mark;
	
	process(clock)
	begin
		if(rising_edge(clock))then		
			if(state = initialize or state = e3)then
				wr_n <= '1';
			elsif(state = e2 and memory_write = '1')then
				wr_n <= '0';
			end if;
		end if;
	end process;
	
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize or state = f3 or state = e3 or state = l3)then
				rd_n <= '1';
			elsif(state = f1 or state = l1 or (state = e1 and memory_read = '1'))then
				rd_n <= '0';
			end if;
		end if;
	end process;
	
	--
	-- Branch logic
	--
	d_zero <= '1' when d= "00000000" else '0';
	ie_skip_inhibit <= '0' when n = "1100" and ie = '0' else '1';
	
	with n(1 downto 0) select flag_mux <=
		'1'    when "00",
		qq     when "01",
		d_zero when "10",
		df     when "11",
		'X'    when others;
		
	with n(1 downto 0) select ef_mux <= 
		not ef(0) when "00",
		not ef(1) when "01",
		not ef(2) when "10",
		not ef(3) when "11",
		'X'   when others;
		
	sbr_mux <= flag_mux when n(2) = '0' else ef_mux;
		
	branch_inc <= (sbr and (sbr_mux xnor n(3))) or (lbr and ie_skip_inhibit and (flag_mux xnor n(3))) or (execute and lbr and not n(2));
	branch_load_lo <= '1' when (longbranch = '1' and n(2) = '0' and flag_mux /= n(3)) or (sbr = '1' and sbr_mux /= n(3)) else '0';
	branch_load_hi <= '1' when longbranch = '1' and n(2) = '0' and flag_mux /= n(3) else '0';
	
	--
	-- N outputs
	--
	process(clock)
	begin
		if(rising_edge(clock))then
			if(state = initialize)then
				nlines <= "000";
			elsif(state = e1 and (inp = '1' or outp = '1'))then
				nlines <= n(2 downto 0);
			elsif(state = e3)then
				nlines <= "000";
			end if;
		end if;
	end process;
	
end rtl;

