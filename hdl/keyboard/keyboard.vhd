library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	port
	(
		clk           : in  std_logic;
		rst           : in  std_logic;
		rows          : out std_logic_vector(2 downto 0);
		columns       : in  std_logic_vector(6 downto 0);
		kb_buffer_out : out std_logic_vector(31 downto 0)
	);
end entity;

architecture keyboard_arch of keyboard is
	
	--type keyboard_matrix is array (6 downto 0, 2 downto 0) of std_logic_vector(7 downto 0);
	--constant kb_matrix : keyboard_matrix := {};
	
	signal kb_buffer : std_logic_vector(31 downto 0);
	signal row_sel   : std_logic_vector(2 downto 0);
	
begin
	
	ROW_CYCLE : process (clk, rst, row_sel)
	begin
		if rst = '1' then
			row_sel <= "001";
		elsif rising_edge(clk) then
			case row_sel is
				when "001"  => row_sel <= "010";
				when "010"  => row_sel <= "100";
				when "100"  => row_sel <= "001";
				when others => row_sel <= "001";
			end case;
		end if;
	end process;
	
	KEY_DETECTION : process (clk, rst, columns)
	begin
		if rst = '1' then
			kb_buffer <= "00000000000000000000000000000000";
			
		elsif rising_edge(clk) then
			case columns is
			when "1000000" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"00"; -- No connection
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"00"; -- No connection
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"30"; -- 0
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0100000" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"37"; -- 7
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"34"; -- 4
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"31"; -- 1
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0010000" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"38"; -- 8
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"35"; -- 5
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"32"; -- 2
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0001000" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"39"; -- 9
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"36"; -- 6
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"33"; -- 3
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0000100" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"2F"; -- Divide
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"2B"; -- Add
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"2E"; -- Period
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0000010" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"2A"; -- Multiply
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"2D"; -- Subtract
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"27"; -- Negate
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when "0000001" =>
				case row_sel is
					when "001"  => kb_buffer <= kb_buffer(23 downto 0) & x"1B"; -- Clear all
					when "010"  => kb_buffer <= kb_buffer(23 downto 0) & x"08"; -- Clear
					when "100"  => kb_buffer <= kb_buffer(23 downto 0) & x"0D"; -- Equals/Enter
					when others => kb_buffer <= kb_buffer(31 downto 0);
				end case;
			when others => 
				kb_buffer <= kb_buffer;
			end case;
		end if;
	end process;
	
	rows          <= row_sel;
	kb_buffer_out <= kb_buffer;
	
end architecture;
