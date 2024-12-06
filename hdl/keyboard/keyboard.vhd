library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	generic
	(
		SYS_CLK_PERIOD : time
	);
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
	
	--type state is (row_0, row_1, row_2);
	--signal curr_state : state;
	
	--constant db_time : time := 1 us;
	
	--signal col_db : std_logic_vector(6 downto 0);  -- Debounced column signal
	--signal kb     : std_logic_vector(31 downto 0); -- keyboard buffer signal
	
	signal row_sig : std_logic_vector(2 downto 0);
	
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
	
	-- Asynchronous conditioners for column input signals
--	ASYNC_6 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(6), sync => col_db(6));
--	ASYNC_5 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(5), sync => col_db(5));
--	ASYNC_4 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(4), sync => col_db(4));
--	ASYNC_3 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(3), sync => col_db(3));
--	ASYNC_2 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(2), sync => col_db(2));
--	ASYNC_1 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(1), sync => col_db(1));
--	ASYNC_0 : async_conditioner
--		generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
--		port map (clk => clk, rst => rst, async => columns(0), sync => col_db(0));	
	
	-- Next state logic, not very interesting yet
	NEXT_STATE_LOGIC : process (clk, rst, row_sig)
	begin
		if rst = '1' then
			row_sig <= "001";
			--kb <= x"00000000";
			
		elsif rising_edge(clk) then
			case row_sig is
				when "001" => row_sig <= "010";
				when "010" => row_sig <= "100";
				when "100" => row_sig <= "001";
				when others =>
					row_sig <= "001";
			end case;
			
			--case curr_state is
			--	when row_0 =>
			--		case col_db is
			--			when "0000000" => kb <= kb;
			--			when others    => kb <= kb(23 downto 0) & x"FF";
			--		end case;
			--		curr_state <= row_1;
			--	when row_1 =>
			--		case col_db is
			--			when "0000000" => kb <= kb;
			--			when others    => kb <= kb(23 downto 0) & x"FF";
			--		end case;
			--		curr_state <= row_2;
			--	when row_2 =>
			--		case col_db is
			--			when "0000000" => kb <= kb;
			--			when others    => kb <= kb(23 downto 0) & x"FF";
			--		end case;
			--		curr_state <= row_0;
			--end case;
		end if;
	end process;
	
	--OUTPUT_LOGIC : process (clk, rst, curr_state, columns)
	--begin
	--	case curr_state is
	--		when row_0  => rows <= "001";
	--		when row_1  => rows <= "010";
	--		when row_2  => rows <= "100";
	--		when others => rows <= "000";
	--	end case;
	--end process;
	
	rows <= row_sig;
	kb_buffer <= x"00000000";
	
end architecture;
