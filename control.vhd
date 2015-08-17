library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use work.sim_common.all;

entity control is
	port (clk: in std_ulogic;
		  hard_reset: in std_ulogic;
		  reset: in std_ulogic;
		  pause: in std_ulogic;
		  disc_count: in unsigned(disc_width-1 downto 0);
		  delay: in unsigned(delay_width-1 downto 0);
		  sim_ev: buffer sim_event_t;
		  status: out std_ulogic_vector(1 downto 0));
end;

architecture seq of control is
	type state_t is (init, running, paused, finished);
	
	signal state: state_t;
	signal reset1, pause1: std_ulogic;
	signal reset_released, pause_released: boolean;
	signal sim_clk, sim_enable, sim_reset: std_ulogic;
begin
	sim_clk_e: entity work.div_by_2_pow_n
		port map (clk, sim_reset, sim_enable, delay, sim_clk);

	sim_e: entity work.sim port map (sim_clk, sim_reset, disc_count, sim_ev);

	process (clk, hard_reset) is
		variable r1, r2: boolean;
	begin
		if hard_reset then
			reset1 <= '1';
			pause1 <= '1';
			state <= init;
		elsif rising_edge(clk) then
			case state is
				when init =>
					if pause_released then
						state <= running;
					end if;
				when running =>
					if pause_released then
						state <= paused;
					elsif sim_ev.finished then
						state <= finished;
					end if;
				when paused =>
					if pause_released then
						state <= running;
					elsif reset_released then
						state <= init;
					end if;
				when finished =>
					if pause_released then
						state <= running;
					elsif reset_released then
						state <= init;
					end if;
			end case;

			reset_released <= reset1 ?= '0' and reset ?= '1';
			pause_released <= pause1 ?= '0' and pause ?= '1';

			reset1 <= reset;
			pause1 <= pause;

			sim_enable <= to_std_ulogic(state = running);

			sim_reset <= to_std_ulogic(
						 	(reset ?= '0' and state = running) or
							(pause_released and state = finished) or
							state = init);

			status(0) <= to_std_ulogic(state = running);
			status(1) <= to_std_ulogic(state = finished);
		end if;
	end process;
end;
