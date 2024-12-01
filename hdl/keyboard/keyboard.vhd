library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	port
	(
		clk       : in  std_logic;
		rst       : in  std_logic;
		rows      : out std_logic_vector(2 downto 0);
		columns   : in  std_logic_vector(6 downto 0);
		kb_buffer : out std_logic_vector(31 downto 0)
	);
end entity;

architecture keyboard_arch of keyboard is
	
	--type keyboard_matrix is array (6 downto 0, 2 downto 0) of std_logic_vector(7 downto 0);
	--constant kb_matrix : keyboard_matrix := {};
	
	type state is (row_0, row_1, row_2);
	signal curr_state : state;
	
	signal kb : std_logic_vector(31 downto 0);
	
	-- asynchronous conditioner ----------------------------------
	component async_conditioner is
		generic
		(
			clk_period    : time;
			debounce_time : time
		);
		port
		(
			clk   : in  std_ulogic;
			rst   : in  std_ulogic;
			async : in  std_ulogic;
			sync  : out std_ulogic
		);
	end component;
	---------------------------------- asynchronous conditioner --
	
begin
	
	NEXT_STATE_LOGIC : process (clk, rst, curr_state, columns, kb)
	begin
		if rst = '1' then
			kb <= x"00000000";
			
		elsif rising_edge(clk) then
			case curr_state is
				when row_0 =>
					case columns is
						when "0000001" => kb <= kb(23 downto 0) & "00000101";
						when "0000010" => kb <= kb(23 downto 0) & "00000100";
						when "0000100" => kb <= kb(23 downto 0) & "00000011";
						when "0001000" => kb <= kb(23 downto 0) & "00000010";
						when "0010000" => kb <= kb(23 downto 0) & "00000001";
						when "0100000" => kb <= kb(23 downto 0) & "11111111";
						when "1000000" => kb <= kb(23 downto 0) & "11111110";
						when others    => kb <= kb;
					end case;
					curr_state <= row_1;
				when row_1 =>
					case columns is
						when "0000001" => kb <= kb(23 downto 0) & "01000101";
						when "0000010" => kb <= kb(23 downto 0) & "01000100";
						when "0000100" => kb <= kb(23 downto 0) & "01000011";
						when "0001000" => kb <= kb(23 downto 0) & "01000010";
						when "0010000" => kb <= kb(23 downto 0) & "01000001";
						when "0100000" => kb <= kb(23 downto 0) & "10111111";
						when "1000000" => kb <= kb(23 downto 0) & "10111110";
						when others    => kb <= kb;
					end case;
					curr_state <= row_2;
				when row_2 =>
					case columns is
						when "0000001" => kb <= kb(23 downto 0) & "11000101";
						when "0000010" => kb <= kb(23 downto 0) & "11000100";
						when "0000100" => kb <= kb(23 downto 0) & "11000011";
						when "0001000" => kb <= kb(23 downto 0) & "11000010";
						when "0010000" => kb <= kb(23 downto 0) & "11000001";
						when "0100000" => kb <= kb(23 downto 0) & "00111111";
						when "1000000" => kb <= kb(23 downto 0) & "00111110";
						when others    => kb <= kb;
					end case;
					curr_state <= row_0;
			end case;
		end if;
	end process;
	
	OUTPUT_LOGIC : process (clk, rst, curr_state, columns)
	begin
		case curr_state is
			when row_0  => rows <= "001";
			when row_1  => rows <= "001";
			when row_2  => rows <= "001";
			when others => rows <= "000";
		end case;
	end process;
	
	kb_buffer <= kb;
	
end architecture;
