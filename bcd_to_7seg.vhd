library ieee;
use ieee.std_logic_1164.all;
use work.bcd.all;
use work.disp7seg.all;

entity bcd_to_7seg is
	port (bcd: in bcd_t; display: out disp7seg_t);
end;

architecture comb of bcd_to_7seg is
begin
	-- Quartus II 15.0.2 doesn't know "with foo select?"
	/*
	with bcd select?
		display <= "0000001" when "0000", -- 0
				   "1001111" when "0001", -- 1
				   "0010010" when "0010", -- 2
				   "0000110" when "0011", -- 3
				   "1001100" when "0100", -- 4 
				   "0100100" when "0101", -- 5
				   "0100000" when "0110", -- 6
				   "0001111" when "0111", -- 7
				   "0000000" when "1000", -- 8
				   "0000100" when "1001", -- 9
				   "1111111" when others;
	*/

	process (bcd) is
	begin
		case? bcd is
			when "0000" => display <= "0000001"; -- 0
			when "0001" => display <= "1001111"; -- 1
			when "0010" => display <= "0010010"; -- 2
			when "0011" => display <= "0000110"; -- 3
			when "0100" => display <= "1001100"; -- 4 
			when "0101" => display <= "0100100"; -- 5
			when "0110" => display <= "0100000"; -- 6
			when "0111" => display <= "0001111"; -- 7
			when "1000" => display <= "0000000"; -- 8
			when "1001" => display <= "0000100"; -- 9
			when others => display <= "1111111";
		end case?;
	end process;
end;
