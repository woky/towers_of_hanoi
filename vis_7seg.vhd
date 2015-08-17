library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.bcd.all;
use work.disp7seg.all;
use work.sim_common.all;

package vis_7seg_common is
	type counter_displays_t is
		array (tower_t) of disp7seg_row_t(bcd_digits(disc_width)-1 downto 0);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.sim_common.all;
use work.vis_7seg_common.all;

entity vis_7seg is
	port (ev: in sim_event_t;
		  displays: out counter_displays_t);
end;

architecture comb of vis_7seg is
begin
	gen_display_rows:
	for i in 0 to 2 generate
		display_row: entity work.bin_to_7seg_row
			generic map (disc_width)
			port map (std_ulogic_vector(ev.counters(i)), displays(i));
	end generate;
end;
