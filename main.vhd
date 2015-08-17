library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.sim_common.all;
use work.disp7seg.all;
use work.vis_7seg_common.all;

entity main is
	port (clock_50: in std_ulogic;
		  sw: in std_ulogic_vector(17 downto 0);
		  key: in std_ulogic_vector(2 downto 0);
		  ledr: out std_ulogic_vector(17 downto 0);
		  ledg: out std_ulogic_vector(7 downto 0);
		  hex7, hex6, hex5, hex4, hex3, hex2: out disp7seg_t);
end;

architecture seq of main is
	signal reset: std_ulogic;
	signal displays: counter_displays_t;
	signal ev: sim_event_t;
begin
	((hex7, hex6), (hex5, hex4), (hex3, hex2)) <= displays;
	
	init_e: entity work.init port map (clock_50, reset);

	vis_7seg_e: entity work.vis_7seg port map (ev, displays);
	vis_led_e: entity work.vis_led
		port map (ev, ledr(2 downto 0), ledg(7 downto 5));

	control_e: entity work.control
		port map (clk => clock_50,
				  hard_reset => reset or not key(2),
				  reset => key(1),
				  pause => key(0),
				  disc_count => unsigned(sw(5 downto 0)),
				  delay => unsigned(sw(17 downto 13)),
				  sim_ev => ev,
				  status => ledg(1 downto 0));
end;
