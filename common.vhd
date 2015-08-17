library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
	-- used globally (Quartus II 15.0.2 can't do generic packages)
	constant disc_width: positive := 6;
	constant delay_width: positive := 5;

	function to_std_ulogic(b: boolean) return std_ulogic;
end;

package body common is
	function to_std_ulogic(b: boolean) return std_ulogic is begin
		if b then
			return '1';
		else
			return '0';
		end if;
	end;
end;
