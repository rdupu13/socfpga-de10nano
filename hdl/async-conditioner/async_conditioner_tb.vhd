library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is
end entity;

architecture async_conditioner_tb_arch of async_conditioner_tb is
	
	constant CLK_PERIOD      : time := 20 ns;
	constant DEBOUNCE_TIME_0 : time := 500 ns;
	constant DEBOUNCE_TIME_1 : time := 2000 ns;
	
	signal clk_tb   : std_ulogic;
	signal rst_tb   : std_ulogic;
	signal async_tb : std_ulogic;
	signal sync_tb  : std_ulogic_vector(1 downto 0);
	
	component async_conditioner is
		generic (
			clk_period    : time;
			debounce_time : time
		);
		port (
			clk   : in  std_ulogic;
			rst   : in  std_ulogic;
			async : in  std_ulogic;
			sync  : out std_ulogic
		);
	end component;
	
	begin
		
		DUT_0 : async_conditioner
			generic map (
				clk_period    => CLK_PERIOD,
				debounce_time => DEBOUNCE_TIME_0
			)
			port map (
				clk   => clk_tb,
				rst   => rst_tb,
				async => async_tb,
				sync  => sync_tb(0)
			);
		
		DUT_1 : async_conditioner
			generic map (
				clk_period    => CLK_PERIOD,
				debounce_time => DEBOUNCE_TIME_1
			)
			port map (
				clk   => clk_tb,
				rst   => rst_tb,
				async => async_tb,
				sync  => sync_tb(1)
			);
			
		-- Clock process
		CLK_PROCESS : process is
		begin
			clk_tb <= '1';
			wait for CLK_PERIOD / 2;
			clk_tb <= '0';
			wait for CLK_PERIOD / 2;
		end process;
		
		-- Device testing
		STIMULUS : process is
		begin
			
			async_tb <= '0';
			
			-- Reset
			rst_tb <= '0'; wait for CLK_PERIOD;
			rst_tb <= '1'; wait for CLK_PERIOD * 2;
			rst_tb <= '0';
			
			wait for 5 * CLK_PERIOD;
			
			-- Asynchronous stimulus: button press
			async_tb <= '1'; wait for CLK_PERIOD * 9;
			async_tb <= '0'; wait for CLK_PERIOD * 11;
			async_tb <= '1'; wait for CLK_PERIOD * 4;
			async_tb <= '0'; wait for CLK_PERIOD * 6;
			async_tb <= '1'; wait for CLK_PERIOD * 2;
			async_tb <= '0'; wait for CLK_PERIOD * 1;
			
			async_tb <= '1'; wait for CLK_PERIOD * 23;
			
			async_tb <= '0'; wait for CLK_PERIOD * 3;
			async_tb <= '1'; wait for CLK_PERIOD * 7;
			async_tb <= '0'; wait for CLK_PERIOD * 11;
			async_tb <= '1'; wait for CLK_PERIOD * 15;
			async_tb <= '0'; wait for CLK_PERIOD * 6;
			async_tb <= '1'; wait for CLK_PERIOD * 2;
			
			async_tb <= '0'; wait for CLK_PERIOD * 50;
			
			-- Asynchronous stimulus: quicker button press
			async_tb <= '0'; wait for CLK_PERIOD * 0.5;
			async_tb <= '1'; wait for CLK_PERIOD * 3;
			async_tb <= '0'; wait for CLK_PERIOD * 4.5;
			async_tb <= '1'; wait for CLK_PERIOD * 3.7;
			async_tb <= '0'; wait for CLK_PERIOD * 2.1;
			async_tb <= '1'; wait for CLK_PERIOD * 0.9;
			
			async_tb <= '0'; wait for CLK_PERIOD * 5;
			
			async_tb <= '0'; wait for CLK_PERIOD * 0.1;
			async_tb <= '1'; wait for CLK_PERIOD * 0.2;
			async_tb <= '0'; wait for CLK_PERIOD * 2.8;
			async_tb <= '1'; wait for CLK_PERIOD * 1.5;
			async_tb <= '0'; wait for CLK_PERIOD * 2;
			async_tb <= '1'; wait for CLK_PERIOD * 4;
			
			async_tb <= '0'; wait for CLK_PERIOD * 50;
			
			-- Asynchronous stimulus: long alternating input
			for i in 0 to 255 loop
				async_tb <= '1'; wait for CLK_PERIOD * 3.1415926535;
				async_tb <= '0'; wait for CLK_PERIOD * 3.1415926535;
			end loop;
			
			std.env.finish;
			
			-- Too lazy to make an output checker...
			-- Checked them on the waveform and they seem good to me!
			
		end process;
		
end architecture;