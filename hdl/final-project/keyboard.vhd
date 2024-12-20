library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	port
	(
		clk           : in  std_logic;
		rst           : in  std_logic;
		-- Avalon Memory-Mapped Ports
		avs_read      : in  std_logic;
		avs_write     : in  std_logic;
		avs_address   : in  std_logic_vector(1 downto 0);
		avs_readdata  : out std_logic_vector(31 downto 0);
		avs_writedata : in  std_logic_vector(31 downto 0);
		-- Export
		rows          : out std_logic_vector(2 downto 0);
		columns       : in  std_logic_vector(6 downto 0)
	);
end entity;

architecture keyboard_arch of keyboard is
	
	constant SYS_CLK_PERIOD : time := 20 ns;
	
	signal count   : unsigned(19 downto 0);
	signal div_clk : std_logic;
	
	signal row_sig   : std_logic_vector(2 downto 0);
	signal kb_buffer : std_logic_vector(31 downto 0);
	
begin
	
	-- Clock divider
	CLOCK_DIV : process (clk, rst)
	begin
		if rst = '1' then
			count <= x"00000";
			div_clk <= '0';
			
		elsif rising_edge(clk) then	-- Period of div_clk = 2e-8 * 2^20 = 0.021 sec (48 Hz)
		
			if count >= x"FFFFF" then
				count <= x"00000";
				div_clk <= '0';
			elsif count >= x"7FFFF" then
				count <= count + 1;
				div_clk <= '1';
			else
				count <= count + 1;
				div_clk <= div_clk;
			end if;
		
		end if;
	end process;
	
	-- Row sweep state machine
	ROW_SWEEP : process (div_clk, rst, row_sig, columns)
	begin
		if rst = '1' then
			kb_buffer <= x"00000000";
			row_sig   <= "001";
			
		elsif rising_edge(div_clk) then
			case row_sig is
				when "001" =>
					case columns is
						when "0100000" => kb_buffer <= x"00000147"; row_sig <= "001";
						when "0010000" => kb_buffer <= x"00000148"; row_sig <= "001";
						when "0001000" => kb_buffer <= x"00000149"; row_sig <= "001";
						when "0000100" => kb_buffer <= x"00000112"; row_sig <= "001";
						when "0000010" => kb_buffer <= x"00000113"; row_sig <= "001";
						when "0000001" => kb_buffer <= x"00000132"; row_sig <= "001";
						when others =>
							row_sig   <= "010";
							kb_buffer <= x"000000" & kb_buffer(7 downto 0);
					end case;
				
				when "010" =>
					case columns is
						when "0100000" => kb_buffer <= x"00000144"; row_sig <= "010";
						when "0010000" => kb_buffer <= x"00000145"; row_sig <= "010";
						when "0001000" => kb_buffer <= x"00000146"; row_sig <= "010";
						when "0000100" => kb_buffer <= x"00000110"; row_sig <= "010";
						when "0000010" => kb_buffer <= x"00000111"; row_sig <= "010";
						when "0000001" => kb_buffer <= x"00000131"; row_sig <= "010";
						when others =>
							row_sig   <= "100";
							kb_buffer <= x"000000" & kb_buffer(7 downto 0);
					end case;
				
				when "100" =>
					case columns is
						when "1000000" => kb_buffer <= x"00000140"; row_sig <= "100";
						when "0100000" => kb_buffer <= x"00000141"; row_sig <= "100";
						when "0010000" => kb_buffer <= x"00000142"; row_sig <= "100";
						when "0001000" => kb_buffer <= x"00000143"; row_sig <= "100";
						when "0000100" => kb_buffer <= x"00000120"; row_sig <= "100";
						when "0000010" => kb_buffer <= x"00000121"; row_sig <= "100";
						when "0000001" => kb_buffer <= x"00000130"; row_sig <= "100";
						when others =>
							row_sig   <= "001";
							kb_buffer <= x"000000" & kb_buffer(7 downto 0);
					end case;
				
				when others =>
					row_sig   <= "001";
					kb_buffer <= kb_buffer;
			end case;
		end if;
	end process;
	
	rows <= row_sig;
	
	-- Read registers
	AVALON_REGISTER_READ : process(clk, avs_read) is
	begin
		if rising_edge(clk) and avs_read = '1' then
			case avs_address is
				when "00"   => avs_readdata <= kb_buffer;
				when others => avs_readdata <= (others => '0');
			end case;
		end if;
	end process;
	
	-- Write registers
	AVALON_REGISTER_WRITE : process (clk, rst, avs_write) is
	begin
		if rst = '1' then
			
		elsif rising_edge(clk) and avs_write = '1' then
			case avs_address is
				when others => null; -- Ignore all writes
			end case;
		end if;
	end process;
	
end architecture;
