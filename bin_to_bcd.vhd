library ieee;
use ieee.std_logic_1164.all;
use work.bcd.all;

-- based on chapter 6 of
-- "Digital Design - Basic Concepts and Principles" by Karim, Chen

entity bin_to_bcd is
	generic (bin_width: positive);
	port (bin: in std_ulogic_vector(bin_width-1 downto 0);
		  bcd: out std_ulogic_vector(bcd_width(bin_width)-1 downto 0));
end;

architecture comb of bin_to_bcd is
	-- Following conditional generate crashes Quartus II 15.0.2 compiler
--begin
	--gen_module:
	--if bin_width < 4 generate
	--	bcd <= bin;
	--else generate
		-- most/lower significat processed bits

		constant final_mspbs_width: positive := bcd'length mod 4;
		constant final_lspbs_width: positive := bcd'length-final_mspbs_width;

		signal mspbs: std_ulogic_vector(0 to bin_width-1);
		signal lspbs: std_ulogic_vector(0 to 4*((bin_width-2)*(bin_width-1)/6)-1);

		procedure shifted_bcd(signal bin: in  std_ulogic_vector(4 downto 1);
							  signal bcd: out std_ulogic_vector(4 downto 1)) is
		begin
			bcd(4) <= (bin(3) and bin(1)) or
					  (bin(3) and bin(2)) or
					  bin(4);
			bcd(3) <= (bin(4) and bin(1)) or
					  (bin(3) and not bin(2) and not bin(1));
			bcd(2) <= (bin(2) and bin(1)) or
					  (bin(4) and not bin(1)) or
					  (not bin(3) and bin(2));
			bcd(1) <= (not bin(4) and not bin(3) and bin(1)) or
					  (bin(3) and bin(2) and not bin(1)) or
					  (bin(4) and not bin(1));
		end;
	begin
		mspbs(0 to 2) <= bin(bin_width-1 downto bin_width-3);

		gen_converter:
		for i in 0 to bin_width-4 generate
			constant bin_idx: natural			:= bin_width-4-i;
			constant lspbs_idx: natural			:= 4*((i+1)*(i+2)/6);
			constant row_width: positive		:= 4*(1+i/3);
			constant prev_row_width: natural	:= 4*((i+2)/3);

			signal row_in:  std_ulogic_vector(0 to row_width-1);
			signal row_out: std_ulogic_vector(0 to row_width-1);
		begin
			gen_row_input:
			if i mod 3 = 0 generate
				row_in <= '0' & mspbs(i to i+2) &
						  lspbs(lspbs_idx-prev_row_width to lspbs_idx-1);
			else generate
				row_in <= lspbs(lspbs_idx-prev_row_width to lspbs_idx-1);
			end generate;

			gen_row_converters:
			for j in 0 to i/3 generate
				shifted_bcd(row_in (4*j to 4*j+3),row_out(4*j to 4*j+3));
			end generate;

			mspbs(i+3) <= row_out(0);
			lspbs(lspbs_idx to lspbs_idx+row_width-1) <=
				row_out(1 to row_width-1) & bin(bin_idx);
		end generate;

		bcd(bcd'left downto bcd'left - final_mspbs_width + 1) <=
			mspbs(mspbs'right - final_mspbs_width + 1 to mspbs'right);
		bcd(bcd'left - final_mspbs_width downto bcd'right) <=
			lspbs(lspbs'right - final_lspbs_width + 1 to lspbs'right);
	--end generate;
end;
