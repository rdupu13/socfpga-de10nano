library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity control_unit is
	port
	(
		clk          : in  std_logic;
		rst          : in  std_logic;
		
		bus_enable   : in  std_logic;
		ready        : in  std_logic;
		interrupt    : in  std_logic;
		nm_interrupt : in  std_logic;
		p_status     : in  std_logic_vector(31 downto 0);
		
		read_write   : out std_logic;
		vector_pull  : out std_logic;
		memory_lock  : out std_logic;
		synchronize  : out std_logic;
		alu_sel      : out std_logic_vector(3 downto 0);
		reg_sel      : out std_logic_vector(3 downto 0)
	);
end entity;

architecture processor_arch of processor is
	
	type fsm_state is (s_rst_0, s_rst_1, s_rst_2, s_rst_3,
					   
					   s_decode,
					   s_);
	signal curr_state : fsm_state;
	
	signal alu_sel : std_logic_vector(3 downto 0);
	signal reg_sel : std_logic_vector(3 downto 0);
	
begin
		
	NEXT_STATE_LOGIC : process (clk, rst)
	begin
		if rst = '0' then
			curr_state <= s_rst_0;
		elsif rising_edge(clk) then
			case curr_state is
				when s_rst_0 => s_rst_1;
				when s_rst_1 => s_rst_2;
				when s_rst_2 => s_rst_3;
				when s_rst_3 => s_;
				
				when others =>
					
			end case;
		end if;
	end process;
	
	OUTPUT_LOGIC : process (curr_state)
	begin
		case curr_state is
			when s_rst_0 =>
				
			when s_rst_1 =>
				
			when s_rst_2 =>
				
			when s_rst_3 =>
				
			when others =>
				
		end case;
	end process;
	
end architecture;
