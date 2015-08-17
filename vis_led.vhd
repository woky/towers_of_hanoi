library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.sim_common.all;

entity vis_led is
	port (ev: in sim_event_t;
		  leds_from: out std_ulogic_vector(tower_t);
		  leds_to: out std_ulogic_vector(tower_t));
end;

architecture comb of vis_led is
begin
	process (ev)
		variable l1, l2: unsigned(tower_t);
	begin
		l1 := (0 => '1', others => '0');
		l2 := (0 => '1', others => '0');
		l1 := shift_right(l1, ev.moved_from);
		l2 := shift_right(l2, ev.moved_to);
		leds_from <= std_ulogic_vector(l1);
		leds_to <= std_ulogic_vector(l2);
	end process;
end;
