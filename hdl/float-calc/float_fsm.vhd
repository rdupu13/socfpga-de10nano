library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity float_fsm is
	port
	(
		clk    : in  std_logic;
		rst    : in  std_logic;
		opcode : in  std_logic_vector(7 downto 0);
		ctl_1  : in  std_logic_vector(7 downto 0);
		ctl_2  : in  std_logic_vector(7 downto 0);
		irq    : out std_logic_vector(7 downto 0)
	);
end entity;

architecture float_fsm_arch of float_fsm is
	
	type STATE is (S_IDLE, S_DECODE, S_ERROR,
				   S_ADD_0,
				   S_SUB_0,
				   S_MULT_0,
				   S_DIV_0);
	signal curr_state : STATE;
	
	signal shift_count : natural := 0;
	
	begin
		
		NEXT_STATE_LOGIC : process (clk, rst, ctl_1, shift_count)
		begin
			if rst = '1' then
				curr_state <= S_IDLE_0;
				
			elsif rising_edge(clk) then
				case curr_state is
					
					when S_IDLE =>
						if ctl_1(0) = '1' then
							curr_state <= S_DECODE;
						else
							curr_state <= S_IDLE;
						end if;
						
					when S_DECODE =>
						case control(7 downto 0) is
							when x"11"  => curr_state <= S_ADD_0;
							when x"21"  => curr_state <= S_SUB_0;
							when x"31"  => curr_state <= S_MULT_0;
							when x"41"  => curr_state <= S_DIV_0;
							when others =>
								curr_state <= S_ERROR;
						end case;
						
					when S_ERROR =>
						curr_state <= S_IDLE;
						ctl_1      <= ctl_1 or x"01";
						
					when S_ADD_0  => curr_state <= S_IDLE;
					when S_SUB_0  => curr_state <= S_IDLE;
					when S_MULT_0 => curr_state <= S_IDLE;
					when S_DIV_0  => curr_state <= S_IDLE;
					
				end case;
			end if;
		end process;
		
		OUTPUT_LOGIC : process (clk, rst, ctl_1, shift_count)
		begin
			case curr_state
				when S_IDLE_0 =>
					
				when S_DECODE_0 =>
					
				when S_ERROR =>
					
				when S_ADD_0 =>
					
				when S_SUB_0 =>
					
				when S_MULT_0 =>
					
				when S_DIV_0 =>
					
			end case;
		end process;
end architecture;
