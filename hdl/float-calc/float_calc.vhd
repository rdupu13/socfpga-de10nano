library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity float_calc is
	port
	(
		clk           : in std_logic;
		rst           : in std_logic;
		-- Avalon memory-mapped slave interface
		avs_read      : in  std_logic;
		avs_write     : in  std_logic;
		avs_address   : in  std_logic_vector(1 downto 0);
		avs_readdata  : out std_logic_vector(31 downto 0);
		avs_writedata : in  std_logic_vector(31 downto 0);
		-- External I/O; export to top-level
		gpio_lcd_ctl  : out std_logic_vector(2 downto 0);
		gpio_lcd_data : out std_logic_vector(7 downto 0);
		push_button   : in  std_logic;
		switches      : in  std_logic_vector(3 downto 0);
		led           : out std_logic_vector(7 downto 0)
	);
end entity;

architecture float_calc_arch of float_calc is
	
	signal calc_ctl : std_logic_vector(31 downto 0);
	signal in_0     : std_logic_vector(31 downto 0);
	signal in_1     : std_logic_vector(31 downto 0);
	signal out_0    : std_logic_vector(31 downto 0);
	signal lcd_ctl  : std_logic_vector(31 downto 0);
	signal lcd_data : std_logic_vector(31 downto 0);
	
	
	
	-- Finite state machine control unit
	component float_fsm is
		generic
		(
			system_clock_period : time := 20 ns
		);
		port
		(
			clk    : in  std_logic;
			rst    : in  std_logic;
			opcode : in  std_logic_vector(7 downto 0);
			ctl_1  : in  std_logic_vector(7 downto 0);
			ctl_2  : in  std_logic_vector(7 downto 0);
			irq    : out std_logic_vector(7 downto 0)
		);
	end component;
	
	-- Mantissa calculation
	component mantissa_unit is
		generic
		(
			system_clock_period : time := 20 ns
		);
		port
		(
			clk : in  std_logic;
			rst : in  std_logic
		);
	end component;
	
	-- Exponent calculation
	component exponent_unit is
		generic
		(
			system_clock_period : time := 20 ns
		);
		port
		(
			clk    : in  std_logic;
			rst    : in  std_logic;
			opcode : in  std_logic_vector(7 downto 0);
			ctl_1  : in  std_logic_vector(7 downto 0);
			ctl_2  : in  std_logic_vector(7 downto 0);
			irq    : out std_logic_vector(7 downto 0)
		);
	end component;
	
	begin
		
		-- Finite state machine control unit
		FSM : float_fsm
			generic map
			(
				system_clock_period => 20 ns
			)
			port map
			(
				clk    => clk,
				rst    => rst,
				opcode => calc_ctl(7 downto 0),
				ctl_1  => calc_ctl(15 downto 8),
				ctl_2  => calc_ctl(23 downto 16),
				irq    => calc_ctl(31 downto 24)
			);
		
		-- Mantissa calculation
		MANTISSA : mantissa_unit
			generic map
			(
				system_clock_period => 20 ns
			)
			port map
			(
				clk => clk,
				rst => rst
			);
		
		-- Exponent calculation
		EXPONENT : exponent_unit
			generic map
			(
				system_clock_period => 20 ns
			)
			port map
			(
				clk => clk,
				rst => rst
			);
		
		-- CPU reading from component registers
		AVALON_REGISTER_READ : process(clk, avs_read)
		begin
			if rising_edge(clk) and avs_read = '1' then
				case avs_address is
					
					when "000"  => avs_readdata <= calc_ctl;
					when "001"  => avs_readdata <= in_0;
					when "010"  => avs_readdata <= in_1;
					when "011"  => avs_readdata <= out_0;
					when "100"  => avs_readdata <= lcd_ctl;
					when "101"  => avs_readdata <= lcd_data;
					when others => avs_readdata <= (others => '0');
					
				end case;
			end if;
		end process;
		
		-- CPU writing to component registers
		AVALON_REGISTER_WRITE : process (clk, rst, avs_write)
		begin
			if rst = '1' then
				calc_ctl <= x"00000000";
				in_0     <= x"00000000";
				in_1     <= x"00000000";
				out_0    <= x"00000000";
				lcd_ctl  <= x"00000000";
				lcd_data <= x"00000000";
				
			elsif rising_edge(clk) and avs_write = '1' then
				case avs_address is
					
					when "000"  => calc_ctl <= avs_writedata;
					when "001"  => in_0     <= avs_writedata;
					when "010"  => in_1     <= avs_writedata;
					when "011"  => out_0    <= avs_writedata;
					when "100"  => lcd_ctl  <= avs_writedata;
					when "101"  => lcd_data <= avs_writedata;
					when others => null; -- Ignore writes to unused registers
					
				end case;
			end if;
		end process;
		
		-- External connection to LCD display
		gpio_lcd_ctl  <= lcd_ctl;
		gpio_lcd_data <= lcd_data;
		
end architecture;
