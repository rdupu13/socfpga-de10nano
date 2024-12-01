library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity  is
	port
	(
		clk : in  std_logic;
		rst : in  std_logic;
		
	);
end entity;

architecture _arch of  is
	
	type state is
	(
		
	);
	signal curr_state : state;
	
	
	
begin
	
	NEXT_STATE_LOGIC : process (clk, rst, curr_state)
	begin
		if rst = '1' then
			
			
		elsif rising_edge(clk) then
			case curr_state is
				when  =>
				when  =>
				when others =>
			end case;
		end if;
	end process;
	
	OUTPUT_LOGIC : process (curr_state)
	begin
		case curr_state is
			when  =>
			when  =>
			when others =>
		end case;
	end process;
	
end architecture;
