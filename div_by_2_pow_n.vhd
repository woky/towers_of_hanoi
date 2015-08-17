library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity div_by_2_pow_n is
	port (clk: in std_ulogic;
		  reset: in std_ulogic;
		  enable: in std_ulogic;
		  n: in unsigned;
		  clk_div: out std_ulogic);
end;

architecture seq of div_by_2_pow_n is
	signal counter_clk: unsigned(2**n'length - 1 downto 0);
	signal counter: unsigned(counter_clk'left downto 1);
	signal mask: unsigned(counter'range);
begin
	process (clk, reset)
	begin
		if reset ?= '1' then
			counter <= (others => '0');
		elsif rising_edge(clk) and enable ?= '1' then
			counter <= (counter + 1) and mask;
		end if;
	end process;

	process (n)
		variable tmp: unsigned(counter'range);
	begin
		tmp := (others => '0');
		tmp := tmp - 1;
		tmp := shift_right(tmp, tmp'length - to_integer(n));
		mask <= tmp;
	end process;

	counter_clk(counter_clk'left downto 1) <= counter;

	process (clk)
	begin
		if enable ?= '1' then
			counter_clk(0) <= clk;
		else
			counter_clk(0) <= '0';
		end if;
	end process;

	clk_div <= counter_clk(to_integer(n));
end;
