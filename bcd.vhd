library ieee;
use ieee.std_logic_1164.all;

package bcd is
	subtype bcd_t is std_ulogic_vector(3 downto 0);

	function bcd_width(bin_width: positive) return positive;
	function bcd_digits(bin_width: positive) return positive;
end;

package body bcd is
	function bcd_width(bin_width: positive) return positive is begin
		return (4*bin_width-1)/3;
	end;

	function bcd_digits(bin_width: positive) return positive is begin
		return (bcd_width(bin_width)+3)/4;
	end;
end;
