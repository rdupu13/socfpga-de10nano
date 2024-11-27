-- Debouncer testbench
--
-- Copyright (c) Trevor Vannoy 2024
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity debouncer_tb is
end entity debouncer_tb;

architecture testbench of debouncer_tb is
	
	type natural_array is array (natural range<>) of natural;
	type time_array is array (natural range<>) of time;

	signal clk_tb	  : std_ulogic := '0';
	signal rst_tb	  : std_ulogic := '0';
	signal bouncer_tb : std_ulogic := '0';

	constant BOUNCE_PERIOD : time := 100 ns;

	constant DEBOUNCE_TIME_1US		  : time	:= 1000 ns;
	constant DEBOUNCE_CYCLES_1US	  : natural := DEBOUNCE_TIME_1US / BOUNCE_PERIOD;
	constant DEBOUNCE_CLK_CYCLES_1US  : natural := DEBOUNCE_TIME_1US / CLK_PERIOD;

	constant DEBOUNCE_TIME_10US		  : time	:= 10 us;
	constant DEBOUNCE_CYCLES_10US	  : natural := DEBOUNCE_TIME_10US / BOUNCE_PERIOD;
	constant DEBOUNCE_CLK_CYCLES_10US : natural := DEBOUNCE_TIME_10US / CLK_PERIOD;
	signal debounced_tb				  : std_ulogic_vector(0 to 1);

	constant DEBOUNCE_TIMES : time_array(0 to 1) := (
		DEBOUNCE_TIME_1US,
		DEBOUNCE_TIME_10US
	);

	constant DEBOUNCE_CYCLES : natural_array(0 to 1) := (
		DEBOUNCE_CYCLES_1US,
		DEBOUNCE_CYCLES_10US
	);

	constant DEBOUNCE_CLK_CYCLES : natural_array(0 to 1) := (
		DEBOUNCE_CLK_CYCLES_1US,
		DEBOUNCE_CLK_CYCLES_10US
	);

	procedure bounce_signal (
			signal bounce          : out std_ulogic;
			constant BOUNCE_PERIOD : time;
			constant BOUNCE_CYCLES : natural;
			constant FINAL_VALUE   : std_ulogic
		) is

		-- If BOUNCE_CYCLES is not an integer multiple of 4, the division
		-- operation will only return the integer part (i.e., perform a floor
		-- operation). Thus, we need to calculate how many cycles are remaining
		-- after waiting for 3 * BOUNCE_CYCLES_BY_4 BOUNCE_PERIODs. If BOUNCE_CYCLES
		-- is an integer multiple of 4, then REMAINING_CYCLES will be equal to
		-- BOUNCE_CYCLES_BY_4.
	
		constant BOUNCE_CYCLES_BY_4 : natural := BOUNCE_CYCLES / 4;
		constant REMAINING_CYCLES   : natural := BOUNCE_CYCLES - (3 * BOUNCE_CYCLES_BY_4);

	begin
	
		-- Toggle the bouncing input quickly for ~1/4 of the debounce time
		for i in 1 to BOUNCE_CYCLES_BY_4 loop
			bounce <= not bounce;
			wait for BOUNCE_PERIOD;
		end loop;

		-- Toggle the bouncing input slowly for ~1/2 of the debounce time
		for i in 1 to BOUNCE_CYCLES_BY_4 loop
			bounce <= not bounce;
			wait for 2 * BOUNCE_PERIOD;
		end loop;

		-- Settle at the final value for the rest of the debounce time
		bounce <= FINAL_VALUE;
		wait for REMAINING_CYCLES * BOUNCE_PERIOD;
	
	end procedure bounce_signal;
 
begin

	generate_duvs : for i in DEBOUNCE_TIMES'range generate

		duv : entity work.debouncer
			generic map (
				clk_period    => CLK_PERIOD,
				debounce_time => DEBOUNCE_TIMES(i)
			)
			port map (
				clk       => clk_tb,
				rst       => rst_tb,
				input     => bouncer_tb,
				debounced => debounced_tb(i)
			);

	end generate generate_duvs;

	clk_tb <= not clk_tb after CLK_PERIOD / 2;

	stimuli_generator : process is
	begin

		for debouncer_num in DEBOUNCE_TIMES'range loop
			-- Reset at the beginning of the tests to make sure the debouncers
			-- are in their reset/idle state.
			rst_tb <= '1', '0' after 50 ns;
			-- Let the input sit low for a while
			wait_for_clock_edges(clk_tb, 20);
			-- Transition the bouncing signal on the falling edges of the clock
			wait for CLK_PERIOD / 2;

			-- Press the button
			bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES(debouncer_num), '1');

			-- Hold the button for an extra debounce time
			wait_for_clock_edges(clk_tb, DEBOUNCE_CLK_CYCLES(debouncer_num));

			-- Transition the bouncing signal on the falling edges of the clock
			wait for CLK_PERIOD / 2;

			-- Release the button
			bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES(debouncer_num), '0');

			-- Keep the button unpressed for an extra debounce time
			wait_for_clock_edges(clk_tb, DEBOUNCE_CLK_CYCLES(debouncer_num));

			-- Transition the bouncing signal on the falling edges of the clock
			wait for CLK_PERIOD / 2;

			-- Press the button again, but release it right after the deboucne time
			-- is up; this makes sure the debouncer is not debouncing for longer than
			-- it is supposed to.
			bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES(debouncer_num), '1');
			bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES(debouncer_num), '0');
			
			-- Wait a few clock cycles to allow for the release debounce time to be done
			wait_for_clock_edges(clk_tb, 10);

			-- Make sure the debouncer works even if the final value during the
			-- initial-press debounce time is 0 (e.g., the button was pressed
			-- and released before the debounce time was up, or somehow settled
			-- in an unpressed state). In other words, make sure the debouncer
			-- output stays high for the whole debounce time, .
			-- NOTE: this test relies on the fact that bouncer_tb = '0' right before
			-- running this procedure, that way the first toggle sets bouncer_tb = '1'.
			bounce_signal(bouncer_tb, BOUNCE_PERIOD, DEBOUNCE_CYCLES(debouncer_num), '0');
		end loop;

		std.env.finish;

	end process stimuli_generator;

	response_checker : process is

		-- To view this variable in the Questa waveform display, you need to
		-- turn on "apply full visibility to all modules (full debug mode)" in
		-- the Optimization Options dialog.
		variable debounced_expected : std_ulogic := '0';
	
	begin

		for debouncer_num in DEBOUNCE_TIMES'range loop
			
			print("----------------------------------------------------");
			print("testing debouncer with debounce time = " & to_string(DEBOUNCE_TIMES(debouncer_num)));
			print("----------------------------------------------------");

			-- before the button has been pressed
			print("test: before button pressed");

			for i in 1 to 20 loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '0';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "before button pressed");
			end loop;
			
			-- while the button is pressed and is bouncing
			print("test: while pressed and bouncing");

			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '1';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "while pressed and bouncing");
			end loop;
			
			-- while the button is being held
			print("test: while button held");
			
			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '1';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "while button held");
			end loop;
			
			-- while the button is being released and is bouncing
			print("test: while released and bouncing");

			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '0';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "while released and bouncing");
			end loop;
			
			-- after the button has been released and stopped bouncing
			print("test: after button released");

			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '0';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "after button released");
			end loop;

			print("test: make sure debouncer debounces for correct time");

			-- while the button is pressed and is bouncing
			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '1';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "while pressed and bouncing");
			end loop;

			-- while the button is being released and is bouncing
			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '0';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "while released and bouncing");
			end loop;

			-- Wait a few clock cycles to allow for the release debounce time to be done
			wait_for_clock_edges(clk_tb, 10);
			
			print("test: make sure debouncer remains high for entire debounce time");

			for i in 1 to DEBOUNCE_CLK_CYCLES(debouncer_num) loop
				wait_for_clock_edge(clk_tb);
				debounced_expected := '1';
				assert_eq(debounced_tb(debouncer_num), debounced_expected, "remains high for entire debounce time");
			end loop;
		
		end loop;

	end process response_checker;

end architecture testbench;