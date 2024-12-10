library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is	
	port
	(
		clk  : in  std_logic;
		rst  : in  std_logic;
		-- Avalon Memory-Mapped Ports
	--	avs_read      : in  std_logic;
	--	avs_write     : in  std_logic;
	--	avs_address   : in  std_logic_vector(1 downto 0);
	--	avs_readdata  : out std_logic_vector(31 downto 0);
	--	avs_writedata : in  std_logic_vector(31 downto 0);
		-- Export
		lcd_ctl_n  : out std_logic_vector(2 downto 0);
		lcd_data_n : out std_logic_vector(7 downto 0)
	);
end entity;

architecture lcd_arch of lcd is
	
	constant sys_clk_period      : time := 20 ns;
	constant lcd_clk_period      : time := 10 ms;
	constant cyc_per_half_period : natural := (lcd_clk_period / sys_clk_period) / 2;
	
	signal counter : natural := 0;
	signal lcd_clk : std_logic;
	
	type state is
	(
		rst_0, rst_1,  rst_2,  rst_3,  rst_4,  rst_5,  rst_6,  rst_7,
		rst_8, rst_9, rst_10, rst_11, rst_12, rst_13, rst_14,
		write_0, write_1, write_2,
		idle
	);
	signal curr_state : state;
	
	signal ctl  : std_logic_vector(2 downto 0);
	signal data : std_logic_vector(7 downto 0);
	
--	signal reg : std_logic_vector(31 downto 0);
	
begin
	
	-- Clock divider
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
	
	-- State machine that controls LCD
	STATE_MACHINE : process (lcd_clk, rst, curr_state)
	begin
		if rst = '1' then
			curr_state <= rst_0;
			ctl  <= "000";
			data <= "00000000";
		
		elsif rising_edge(lcd_clk) then
			case curr_state is
				
				-- Function set
				-- Set 8-bit mode, 2-line display, 5x8 font
				when rst_0 =>
					curr_state <= rst_1;
					ctl  <= "000";
					data <= "00111000";
				when rst_1 =>
					curr_state <= rst_2;
					ctl  <= "001";
					data <= "00111000";
				when rst_2 =>
					curr_state <= rst_3;
					ctl  <= "000";
					data <= "00111000";
				
				-- Display on/off control
				-- Display on, cursor on, blink on
				when rst_3 =>
					curr_state <= rst_4;
					ctl  <= "000";
					data <= "00001111";
				when rst_4 =>
					curr_state <= rst_5;
					ctl  <= "001";
					data <= "00001111";
				when rst_5 =>
					curr_state <= rst_6;
					ctl  <= "000";
					data <= "00001111";
				
				-- Entry mode set
				-- Increment and shift cursor, don't shift entire display
				when rst_6 =>
					curr_state <= rst_7;
					ctl  <= "000";
					data <= "00000110";
				when rst_7 =>
					curr_state <= rst_8;
					ctl  <= "001";
					data <= "00000110";
				when rst_8 =>
					curr_state <= rst_9;
					ctl  <= "000";
					data <= "00000110";
				
				-- Clear display
				when rst_9 =>
					curr_state <= rst_10;
					ctl  <= "000";
					data <= "00000001";
				when rst_10 =>
					curr_state <= rst_11;
					ctl  <= "001";
					data <= "00000001";
				when rst_11 =>
					curr_state <= rst_12;
					ctl  <= "000";
					data <= "00000001";
				
				-- Return home
				when rst_12 =>
					curr_state <= rst_13;
					ctl  <= "000";
					data <= "00000010";
				when rst_13 =>
					curr_state <= rst_14;
					ctl  <= "001";
					data <= "00000010";
				when rst_14 =>
					curr_state <= write_0;
					ctl  <= "000";
					data <= "00000010";
					
				-- Write an R
				when write_0 =>
					curr_state <= write_1;
					ctl  <= "100";
					data <= "01010010";
				when write_1 =>
					curr_state <= write_2;
					ctl  <= "101";
					data <= "01010010";
				when write_2 =>
					curr_state <= idle;
					ctl  <= "100";
					data <= "01010010";
					
				-- Idle
				when idle =>
					curr_state <= idle;
					ctl  <= "000";
					data <= "00000000";
					
				when others =>
					curr_state <= rst_0;
					ctl  <= "000";
					data <= "00000000";
					
			end case;
		end if;
	end process;
	
	lcd_ctl_n <= not ctl;
	
	lcd_data_n <= not data(0) & not data(1) & not data(2) & not data(3)
                & not data(4) & not data(5) & not data(6) & not data(7);
	
end architecture;
