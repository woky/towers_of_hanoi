library ieee;
use ieee.std_logic_1164.all;

package disp7seg is
	subtype disp7seg_t is std_ulogic_vector(0 to 6);
	type disp7seg_row_t is array (natural range <>) of disp7seg_t;
end disp7seg;
