library ieee;
use ieee.std_logic_1164.all;

entity init is
	port (clk: in std_ulogic; reset: out std_ulogic);
end;

architecture seq of init is
	signal ff_reset, ff1, ff2: std_ulogic;
begin
	ff_reset <= '0';
	process (clk)
	begin
		if ff_reset then
			ff1 <= '0';
			ff2 <= '0';
		elsif rising_edge(clk) then
			if ff1 ?= '0' then
				ff1 <= '1';
				reset <= '0';
			elsif ff2 ?= '0' then
				ff2 <= '1';
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;
end;
