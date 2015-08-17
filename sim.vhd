library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

package sim_common is
	constant max_disc_count: positive := 2**disc_width - 1;
	--constant max_move_count: positive := 2**max_disc_count - 1;
	-- Quartus II 15.0.2 says:
	-- Error (10528): VHDL error at sim.vhd(8): value "-1" is outside the target constraint range (1 to 2147483647)

	subtype disc_t is unsigned(disc_width-1 downto 0);
	subtype move_t is unsigned(max_disc_count downto 0);
	subtype tower_t is natural range 0 to 2;
	type counters_t is array (tower_t) of disc_t;

	constant disc_0: disc_t := (others => '0');
	constant move_0: move_t := (others => '0');

	type sim_event_t is record
		finished: boolean;
		moved_disc: disc_t;
		moved_from, moved_to: tower_t;
		moves: move_t;
		counters: counters_t;
	end record;
end sim_common;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sim_common.all;

entity sim is
	port (clk, reset: in std_ulogic;
		  disc_count: in disc_t;
		  ev: out sim_event_t);
end;

architecture seq of sim is
	type state_t is record
		disc_count: disc_t;
		max_moves: move_t;
		t: tower_t;
		p: integer range -1 to 1;
		ev: sim_event_t;
	end record;

	signal state, next_state: state_t;
begin
	ev <= state.ev;

	process (clk, reset, disc_count)
		variable max_moves: move_t;
	begin
		if reset then
			max_moves := (0 => '1', others => '0');
			max_moves := shift_left(max_moves, to_integer(disc_count)) - 1;
			state <= (
				disc_count => disc_count,
				max_moves => max_moves,
				t => 0,
				p => -2*(to_integer(disc_count) mod 2) + 1,
				ev => (
					finished => disc_count = 0,
					moved_disc => disc_0,
					moved_from => 0,
					moved_to => 0,
					moves => move_0,
					counters => (
						0 => disc_count,
						1 => disc_0,
						2 => disc_0)));
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;

	process (state)
		variable newt: tower_t;
		variable disc: disc_t;
		variable st: state_t;

		procedure move(disc: disc_t; t1: tower_t; t2: tower_t) is begin
			st.ev.moves := st.ev.moves + 1;
			st.ev.finished := std_match(st.ev.moves, st.max_moves);
			st.ev.moved_disc := disc;
			st.ev.moved_from := t1;
			st.ev.moved_to := t2;
			st.ev.counters(t1) := st.ev.counters(t1) - 1;
			st.ev.counters(t2) := st.ev.counters(t2) + 1;
		end;

		function find_first_not_set(vec: move_t) return disc_t is
			variable pos: disc_t := disc_0;
		begin
			for i in vec'reverse_range loop
				pos := pos + 1;
				exit when not vec(i);
			end loop;
			return pos;
		end;
	begin
		st := state;
		if not st.ev.finished then
			if st.ev.moves mod 2 = 0 then
				newt := (st.t + st.p + 3) mod 3;
				move(disc_0 + 1, st.t, newt);
				st.t := newt;
			else
				disc := find_first_not_set(st.ev.moves);
				if disc mod 2 = 0 then
					move(disc, (st.t - st.p + 3) mod 3, (st.t + st.p + 3) mod 3);
				else
					move(disc, (st.t + st.p + 3) mod 3, (st.t - st.p + 3) mod 3);
				end if;
			end if;
		end if;
		next_state <= st;
	end process;
end;
