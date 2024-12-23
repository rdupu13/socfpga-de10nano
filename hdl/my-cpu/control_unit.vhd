library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity control_unit is
	port
	(
		clk        : in  std_logic;
		rst        : in  std_logic;
		
		bus_enable : in  std_logic;
		ready      : in  std_logic;
		irq        : in  std_logic_vector(3 downto 0);
		hw_exc     : in  std_logic_vector(3 downto 0);
		p_status   : in  std_logic_vector(15 downto 0);
		
		read_write : out std_logic;
		vector     : out std_logic;
		lock       : out std_logic;
		sync       : out std_logic;
		
		alu_sel    : out std_logic_vector(3 downto 0);
	);
end entity;

architecture processor_arch of processor is
	
	type fsm_state is (s_rst_0, s_rst_1, s_rst_2, s_rst_3,			   
					   s_waiting,
					   s_fetch_0, s_fetch_1, s_fetch_2, s_fetch_3,
					   s_decode_0,
					   s_add_0);
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
				when s_rst_0    => curr_state <= s_rst_1;
				when s_rst_1    => curr_state <= s_rst_2;
				when s_rst_2    => curr_state <= s_rst_3;
				when s_rst_3    => curr_state <= s_fetch_0;
				when s_fetch_0  => curr_state <= s_fetch_1;
				when s_fetch_1  => curr_state <= s_fetch_2;
				when s_fetch_2  => curr_state <= s_fetch_3;
				when s_fetch_3  => curr_state <= s_decode_0;
				when s_decode_0 => curr_state <= s_add_0;
				when s_add_0    => curr_state <= s_waiting;
				when s_waiting  => curr_state <= s_waiting;
				when others => curr_state <= s_rst_0;
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
			when others  => 
		end case;
	end process;
	
end architecture;
