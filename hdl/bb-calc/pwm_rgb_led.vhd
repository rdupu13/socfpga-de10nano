library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_rgb_led is
	port (
		clk           : in  std_logic;
		rst           : in  std_logic;
		-- Avalon memory-mapped slave interface
	--	avs_read      : in  std_logic;
	--	avs_write     : in  std_logic;
	--	avs_address   : in  std_logic_vector(1 downto 0);
	--	avs_readdata  : out std_logic_vector(31 downto 0);
	--	avs_writedata : in  std_logic_vector(31 downto 0);
		-- External I/O; export to top-level
		switches      : in  std_logic_vector(3 downto 0);
		rgb_output    : out std_logic_vector(2 downto 0)
	);
end entity;

architecture pwm_rgb_led_arch of pwm_rgb_led is
	
	constant system_clock_period : time := 20 ns;
	
	signal period           : unsigned(31 downto 0);
	signal red_duty_cycle   : unsigned(31 downto 0);
	signal green_duty_cycle : unsigned(31 downto 0);
	signal blue_duty_cycle  : unsigned(31 downto 0);
	
	signal red   : std_logic;
	signal green : std_logic;
	signal blue  : std_logic;
	
	-- pwm_controller --------------------------------------------
	component pwm_controller is
		generic
		(
			CLK_PERIOD : time := system_clock_period
		);
		port
		(
			clk        : in  std_logic;
			rst        : in  std_logic;
			period     : in  unsigned(16 downto 0);
			duty_cycle : in  unsigned(11 downto 0);
			output     : out std_logic
		);
	end component;
	-------------------------------------------- pwm_controller --
	
	signal r : std_logic_vector(31 downto 0);
	signal g : std_logic_vector(31 downto 0);
	signal b : std_logic_vector(31 downto 0);
	signal p : std_logic_vector(31 downto 0);
	
begin
	
	-- Red PWM controller
	RED_CONTROL : pwm_controller
		generic map
		(
			CLK_PERIOD => system_clock_period
		)
		port map
		(
			clk        => clk,
			rst        => rst,
			period     => period(16 downto 0),
			duty_cycle => red_duty_cycle(11 downto 0),
			output     => red
		);
	
	-- Green PWM controller
	GREEN_CONTROL : pwm_controller
		generic map
		(
			CLK_PERIOD => system_clock_period
		)
		port map
		(
			clk        => clk,
			rst        => rst,
			period     => period(16 downto 0),
			duty_cycle => green_duty_cycle(11 downto 0),
			output     => green
		);
	
	-- Blue PWM controller
	BLUE_CONTROL : pwm_controller
		generic map
		(
			CLK_PERIOD => system_clock_period
		)
		port map
		(
			clk        => clk,
			rst        => rst,
			period     => period(16 downto 0),
			duty_cycle => blue_duty_cycle(11 downto 0),
			output     => blue
		);
	
	rgb_output <= blue & green & red;
	
	r <= "00000000000000000000" & switches(3 downto 2) & "0000000000";
	g <= "00000000000000000000" & switches(1) & "00000000000";
	b <= "00000000000000000000" & switches(0) & "00000000000";
	p <= "000000000000000" & "00101000000000000";
	
	red_duty_cycle   <= unsigned(r);
	green_duty_cycle <= unsigned(g);
	blue_duty_cycle  <= unsigned(b);
	period           <= unsigned(p);
	
	-- Read registers
	--AVALON_REGISTER_READ : process(clk, avs_read) is
	--begin
	--	if rising_edge(clk) and avs_read = '1' then
	--		case avs_address is
	--			
	--			when "00"   => avs_readdata <= std_logic_vector(red_duty_cycle);
	--			when "01"   => avs_readdata <= std_logic_vector(green_duty_cycle);
	--			when "10"   => avs_readdata <= std_logic_vector(blue_duty_cycle);
	--			when "11"   => avs_readdata <= std_logic_vector(period);
	--			when others => avs_readdata <= (others => '0');
	--			
	--		end case;
	--	end if;
	--end process;
	
	-- Write registers
	--AVALON_REGISTER_WRITE : process (clk, rst, avs_write) is
	--begin
	--	if rst = '1' then
	--		red_duty_cycle   <= "00000000000000000000" & "100000000000"; -- Red    = 1.0
	--		green_duty_cycle <= "00000000000000000000" & "000000000000"; -- Green  = 0.0
	--		blue_duty_cycle  <= "00000000000000000000" & "000000000000"; -- Blue   = 0.0
	--		period           <= "000000000000000" & "00001100110011001"; -- Period = 100 ms
	--		
	--	elsif rising_edge(clk) and avs_write = '1' then
	--		case avs_address is
	--			
	--			when "00"   => red_duty_cycle   <= unsigned(avs_writedata);
	--			when "01"   => green_duty_cycle <= unsigned(avs_writedata);
	--			when "10"   => blue_duty_cycle  <= unsigned(avs_writedata);
	--			when "11"   => period           <= unsigned(avs_writedata);
	--			when others => null; -- Ignore writes to unused registers
	--			
	--		end case;
	--	end if;
	--end process;
	
end architecture;
