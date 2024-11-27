library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_controller is
	generic
	(
		CLK_PERIOD : time := 20 ns
	);
	port
	(
		clk        : in  std_logic;
		rst        : in  std_logic;
		-- PWM period in milliseconds
		-- period data type: u17.11
		period     : in  unsigned(16 downto 0);
		-- PWM duty cycle between 0 and 1, out-of-range values are hard-limited
		-- duty_cycle data type: u12.11
		duty_cycle : in  unsigned(11 downto 0);
		output     : out std_logic
	);
end entity;

architecture pwm_controller_arch of pwm_controller is
	
	constant CYC_PER_SEC : natural := 1000000000 ns / CLK_PERIOD;
	
	signal cyc_per_period : natural;
	signal cyc_per_dc : natural;
	signal dc_is_one : boolean;
	signal counter   : natural := 0;
	
begin
	
	-- Conversion from fixed point to clock-cycle countable integers
	cyc_per_period <= to_integer(period(16 downto 11)) * CYC_PER_SEC
		            + to_integer(period(10 downto 0)) * CYC_PER_SEC / 2048;
	cyc_per_dc     <= to_integer(duty_cycle(10 downto 0)) * cyc_per_period / 2048;
	dc_is_one      <= (duty_cycle(11) = '1');
	
	-- Counter control
	-- 1 when < cyc_per_dc
	-- 0 when > cyc_per_dc
	PULSE_WIDTH_MODULATION : process (clk, rst, cyc_per_period, cyc_per_dc, dc_is_one)
	begin
		if rst = '1' then
			output <= '0';
			counter <= 0;
			
		elsif rising_edge(clk) then
			if dc_is_one then
				output <= '1';
				counter <= 0;
				
			else
				if counter < cyc_per_dc then
					output <= '1';
					counter <= counter + 1;
					
				elsif counter >= cyc_per_dc and counter < cyc_per_period then
					output <= '0';
					counter <= counter + 1;
					
				else
					output <= '1';
					counter <= 1;
					
				end if;
			end if;
		end if;
	end process;
	
end architecture;
