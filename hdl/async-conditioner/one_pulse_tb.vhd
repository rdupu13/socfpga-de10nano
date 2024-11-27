library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity one_pulse_tb is
end entity;

architecture one_pulse_tb_arch of one_pulse_tb is
	
	constant CLK_PERIOD : time := 20 ns;
	
	signal clk_tb   : std_ulogic;
	signal rst_tb   : std_ulogic;
	signal input_tb : std_ulogic;
	signal pulse_tb : std_ulogic;
	
	component one_pulse is
		port (
			clk   : in  std_ulogic;
			rst   : in  std_ulogic;
			input : in  std_ulogic;
			pulse : out std_ulogic
		);
	end component;
	
	begin
		
		DUT : one_pulse
			port map (
				clk   => clk_tb,
				rst   => rst_tb,
				input => input_tb,
				pulse => pulse_tb
			);
		
		-- Clock generation
		CLOCK_GEN : process is
		begin
			clk_tb <= '1'; wait for CLK_PERIOD;
			clk_tb <= '0'; wait for CLK_PERIOD;
		end process;
		
		-- DUT Stimulus
		STIMULUS : process is
		begin
			
			input_tb <= '0';
			
			-- Reset
			rst_tb <= '0'; wait for CLK_PERIOD;
			rst_tb <= '1'; wait for CLK_PERIOD * 2;
			rst_tb <= '0';
			
			-- Asynchronous stimulus: strange input with quadraticly changing period
			input_tb <= '0'; wait for CLK_PERIOD * 10;
			for i in 0 to 15 loop
				input_tb <= '1'; wait for CLK_PERIOD * i * i * 0.31415926535;
				input_tb <= '0'; wait for CLK_PERIOD * i * i * 0.31415926535;
			end loop;
			
			std.env.finish;
			
		end process;
		
end architecture;