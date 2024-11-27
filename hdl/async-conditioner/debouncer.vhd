library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(
		clk_period    : time := 20 ns;
		debounce_time : time
	);
	port (
		clk       : in  std_ulogic;
		rst       : in  std_ulogic;
		input     : in  std_ulogic;
		debounced : out std_ulogic
	);
end entity;

architecture debouncer_arch of debouncer is
	
	type STATE is (S_WAIT_FOR_PRESS, S_PRESSED_BOUNCING, S_WAIT_FOR_RELEASE, S_RELEASED_BOUNCING);
	
	signal curr_state : STATE;
	
	signal clk_period_ns    : natural := natural(clk_period / 1 ns);
	signal debounce_time_ns : natural := natural(debounce_time / 1 ns);
	signal count            : natural := 0;
	
	begin
		
		NEXT_STATE_LOGIC : process(clk, rst, curr_state, input, count) is
		begin
			if rst = '1' then
				-- Reset state
				curr_state <= S_WAIT_FOR_PRESS;
				
			elsif rising_edge(clk) then
				case (curr_state) is
				
					-- Next state logic
					when S_WAIT_FOR_PRESS =>
						count <= 0;
						if input = '1' then
							curr_state <= S_PRESSED_BOUNCING;
						else
							curr_state <= S_WAIT_FOR_PRESS;
						end if;
					when S_PRESSED_BOUNCING =>
						count <= count + 1;
						if count >= (debounce_time / clk_period) - 2 then
							curr_state <= S_WAIT_FOR_RELEASE;
						else
							curr_state <= S_PRESSED_BOUNCING;
						end if;
					when S_WAIT_FOR_RELEASE =>
						count <= 0;
						if input = '0' then
							curr_state <= S_RELEASED_BOUNCING;
						else
							curr_state <= S_WAIT_FOR_RELEASE;
						end if;
					when S_RELEASED_BOUNCING =>
						count <= count + 1;
						if count >= (debounce_time / clk_period) - 2 then
							curr_state <= S_WAIT_FOR_PRESS;
						else
							curr_state <= S_RELEASED_BOUNCING;
						end if;
					
				end case;
			end if;
		end process;
		
		-- Moore machine
		OUTPUT_LOGIC : process(curr_state) is
		begin
			case (curr_state) is
			
				-- Output logic
				when S_WAIT_FOR_PRESS =>    debounced <= '0';
				when S_PRESSED_BOUNCING =>  debounced <= '1';
				when S_WAIT_FOR_RELEASE =>  debounced <= '1';
				when S_RELEASED_BOUNCING => debounced <= '0';
				
			end case;
		end process;
		
end architecture;