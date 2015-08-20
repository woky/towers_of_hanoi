library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.disp7seg.all;
use work.bcd.all;

entity bin_to_7seg_row is
	generic (bin_width: positive);
	port (bin: in std_ulogic_vector(bin_width-1 downto 0);
		  displays: out disp7seg_row_t(bcd_digits(bin_width)-1 downto 0));
end;

architecture comb of bin_to_7seg_row is
	signal bcd: std_ulogic_vector(4*bcd_digits(bin_width)-1 downto 0);
	signal check_zero: std_ulogic_vector(bcd_digits(bin_width)-1 downto 0);
begin
	check_zero(check_zero'left) <= '1';
	bcd(bcd'left downto bcd_width(bin_width)) <= (others => '0');

	bin2bcd: entity work.bin_to_bcd
		generic map (bin_width)
		port map (bin, bcd(bcd_width(bin_width)-1 downto 0));

	right:
	for d in bcd_digits(bin_width)-1 downto 1 generate
		signal tmp: disp7seg_t;
	begin
		display: entity work.bcd_to_7seg port map (bcd(4*d+3 downto 4*d), tmp);

		process (all)
		begin
			-- any straightforward way to do `vector <= vector and bit`?
			if check_zero(d) ?= '1' and bcd(4*d+3 downto 4*d) ?= "0000" then
				displays(d) <= "1111111";
				check_zero(d-1) <= '1';
			else
				displays(d) <= tmp;
				check_zero(d-1) <= '0';
			end if;
		end process;
	end generate;

	leftmost: entity work.bcd_to_7seg port map (bcd(3 downto 0), displays(0));
end;
