library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is	
	port
	(
		clk  : in  std_logic;
		rst  : in  std_logic;
		-- Avalon Memory-Mapped Ports
		avs_read      : in  std_logic;
		avs_write     : in  std_logic;
		avs_address   : in  std_logic_vector(1 downto 0);
		avs_readdata  : out std_logic_vector(31 downto 0);
		avs_writedata : in  std_logic_vector(31 downto 0);
		-- Export
		ctl_n  : out std_logic_vector(2 downto 0);
		data_n : out std_logic_vector(7 downto 0)
	);
end entity;

architecture lcd_arch of lcd is
	
	signal ctl_reg  : std_logic_vector(31 downto 0);
	signal data_reg : std_logic_vector(31 downto 0);
	
begin
	
	-- Read registers
	AVALON_REGISTER_READ : process(clk, avs_read) is
	begin
		if rising_edge(clk) and avs_read = '1' then
			case avs_address is
				
				when "00"   => avs_readdata <= ctl_reg;
				when "01"   => avs_readdata <= data_reg;
				when others => avs_readdata <= (others => '0');
				
			end case;
		end if;
	end process;
	
	-- Write registers
	AVALON_REGISTER_WRITE : process (clk, rst, avs_write) is
	begin
		if rst = '1' then
			ctl_reg  <= x"00000000";
			data_reg <= x"00000000";
			
		elsif rising_edge(clk) and avs_write = '1' then
			case avs_address is
				
				when "00"   => ctl_reg  <= avs_writedata;
				when "01"   => data_reg <= avs_writedata;
				when others => null; -- Ignore writes to unused registers
				
			end case;
		end if;
	end process;
	
	ctl_n  <= not ctl_reg(2 downto 0);
	data_n <= not data_reg(0) & not data_reg(1) & not data_reg(2) & not data_reg(3)
	        & not data_reg(4) & not data_reg(5) & not data_reg(6) & not data_reg(7);
	
end architecture;
