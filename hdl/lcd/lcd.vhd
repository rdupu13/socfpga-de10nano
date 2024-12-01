library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
	generic
	(
		sys_clk_period : time := 20 ns
	);
	port
	(
		clk  : in  std_logic;
		rst  : in  std_logic;
		reg  : in  std_logic_vector(31 downto 0);
		ctl  : out std_logic_vector(2 downto 0);
		data : out std_logic_vector(7 downto 0)
	);
end entity;

architecture lcd_arch of lcd is
	
	type state is
	(
		rst_0, rst_1, rst_2, rst_3, rst_4, rst_5, rst_6, rst_7, rst_8,
		write_0, write_1, write_2,
		idle
	);
	signal curr_state : state;
	
	constant lcd_clk_period      : time := 50 ms;
	constant cyc_per_half_period : natural := (lcd_clk_period / sys_clk_period) / 2;

	signal counter               : natural := 0;
	signal lcd_clk               : std_logic;
	
begin
	
	CLOCK_DIV : process (clk, rst)
	begin
		if rst = '1' then
			counter <= 0;
			lcd_clk <= '0';
			
		elsif rising_edge(clk) then
			if counter >= cyc_per_half_period then
				counter <= 0;
				lcd_clk <= not lcd_clk;
			
			else
				counter <= counter + 1;
				lcd_clk <= lcd_clk;
				
			end if;
		end if;
	end process;
	
	NEXT_STATE_LOGIC : process (lcd_clk, rst, curr_state, reg)
	begin
		if rst = '1' then
			ctl  <= "000";
			data <= "00000000";
			
		elsif rising_edge(lcd_clk) then
			case curr_state is
				
				when rst_0 => curr_state <= rst_1;
					ctl  <= "000";
					data <= "00000001";
				when rst_1 => curr_state <= rst_2;
					ctl  <= "001";
					data <= "00000001";
				when rst_2 => curr_state <= rst_3;
					ctl  <= "000";
					data <= "00000001";
				when rst_3 => curr_state <= rst_4;
					ctl  <= "000";
					data <= "00000010";
				when rst_4 => curr_state <= rst_5;
					ctl  <= "001";
					data <= "00000010";
				when rst_5 => curr_state <= rst_6;
					ctl  <= "000";
					data <= "00000010";
				when rst_6 => curr_state <= rst_7;
					ctl  <= "000";
					data <= "00001111";
				when rst_7 => curr_state <= rst_8;
					ctl  <= "001";
					data <= "00001111";
				when rst_8 => curr_state <= write_0;
					ctl  <= "000";
					data <= "00001111";
				
				when write_0 => curr_state <= write_1;
					ctl  <= "100";
					data <= "01001000";
				when write_1 => curr_state <= write_2;
					ctl  <= "101";
					data <= "01001000";
				when write_2 => curr_state <= idle;
					ctl  <= "100";
					data <= "01001000";
				
				when idle => curr_state <= idle;
					ctl  <= "000";
					data <= "00000000";
				
				when others => curr_state <= rst_0;
					ctl  <= "000";
					data <= "00000000";
					
			end case;
		end if;
	end process;
	
end architecture;
