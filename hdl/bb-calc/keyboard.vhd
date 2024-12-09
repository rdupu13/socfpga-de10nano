library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
	port
	(
		clk           : in  std_logic;
		rst           : in  std_logic;
		-- Avalon Memory-Mapped Ports
	--	avs_read      : in  std_logic;
	--	avs_write     : in  std_logic;
	--	avs_address   : in  std_logic_vector(1 downto 0);
	--	avs_readdata  : out std_logic_vector(31 downto 0);
	--	avs_writedata : in  std_logic_vector(31 downto 0);
		-- Export
		div_clk_out   : out std_logic;
		rows          : out std_logic_vector(2 downto 0);
		columns       : in  std_logic_vector(6 downto 0);
		kb_buf        : out std_logic_vector(31 downto 0)
	);
end entity;

architecture keyboard_arch of keyboard is
	
	constant SYS_CLK_PERIOD : time := 20 ns;
	
	signal kb_buffer : std_logic_vector(31 downto 0);
	
	constant db_time : time := 1 us;
	
	signal col_db : std_logic_vector(6 downto 0);  -- Debounced column signal
	
	signal count   : unsigned(19 downto 0);
	signal div_clk : std_logic;
	
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
	--ASYNC_6 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(6), sync => col_db(6));
	--ASYNC_5 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(5), sync => col_db(5));
	--ASYNC_4 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(4), sync => col_db(4));
	--ASYNC_3 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(3), sync => col_db(3));
	--ASYNC_2 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(2), sync => col_db(2));
	--ASYNC_1 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(1), sync => col_db(1));
	--ASYNC_0 : async_conditioner
	--	generic map (clk_period => SYS_CLK_PERIOD, debounce_time => db_time)
	--	port map (clk => clk, rst => rst, async => columns(0), sync => col_db(0));	
	col_db <= columns;
	
	-- Clock divider
	CLOCK_DIV : process (clk, rst)
	begin
		if rst = '1' then
			count <= x"00000";
			div_clk <= '0';
		elsif rising_edge(clk) then			-- Period of div_clk = 2e-8 * 2^20 = 0.021 sec
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
	
	-- Row sweep
	ROW_SWEEP : process (div_clk, rst, row_sig, col_db)
	begin
		if rst = '1' then
			row_sig <= "001";
			
		elsif rising_edge(div_clk) then
			case row_sig is
				when "001" =>
					case col_db is
						when "0100000" => kb_buffer <= x"00000087"; row_sig <= "001";
						when "0010000" => kb_buffer <= x"00000088"; row_sig <= "001";
						when "0001000" => kb_buffer <= x"00000089"; row_sig <= "001";
						when "0000100" => kb_buffer <= x"00000012"; row_sig <= "001";
						when "0000010" => kb_buffer <= x"00000013"; row_sig <= "001";
						when "0000001" => kb_buffer <= x"00000032"; row_sig <= "001";
						when others =>
							row_sig   <= "010";
							kb_buffer <= kb_buffer;
					end case;
				
				when "010" =>
					case col_db is
						when "0100000" => kb_buffer <= x"00000084"; row_sig <= "010";
						when "0010000" => kb_buffer <= x"00000085"; row_sig <= "010";
						when "0001000" => kb_buffer <= x"00000086"; row_sig <= "010";
						when "0000100" => kb_buffer <= x"00000010"; row_sig <= "010";
						when "0000010" => kb_buffer <= x"00000011"; row_sig <= "010";
						when "0000001" => kb_buffer <= x"00000031"; row_sig <= "010";
						when others =>
							row_sig   <= "100";
							kb_buffer <= kb_buffer;
					end case;
				
				when "100" =>
					case col_db is
						when "1000000" => kb_buffer <= x"00000080"; row_sig <= "100";
						when "0100000" => kb_buffer <= x"00000081"; row_sig <= "100";
						when "0010000" => kb_buffer <= x"00000082"; row_sig <= "100";
						when "0001000" => kb_buffer <= x"00000083"; row_sig <= "100";
						when "0000100" => kb_buffer <= x"00000020"; row_sig <= "100";
						when "0000010" => kb_buffer <= x"00000021"; row_sig <= "100";
						when "0000001" => kb_buffer <= x"00000030"; row_sig <= "100";
						when others =>
							row_sig   <= "001";
							kb_buffer <= kb_buffer;
					end case;
				
				when others =>
					row_sig <= "001";
			end case;
		end if;
	end process;
	
	-- Read registers
--	AVALON_REGISTER_READ : process(clk, avs_read) is
--	begin
--		if rising_edge(clk) and avs_read = '1' then
--			case avs_address is
--				
--				when "00"   => avs_readdata <= kb_buffer;
--				when others => avs_readdata <= (others => '0');
--				
--			end case;
--		end if;
--	end process;
	
	-- Write registers
--	AVALON_REGISTER_WRITE : process (clk, rst, avs_write) is
--	begin
--		if rst = '1' then
--			
--			
--		elsif rising_edge(clk) and avs_write = '1' then
--			case avs_address is
--				
--				when others => null; -- Ignore writes to unused registers
--				
--			end case;
--		end if;
--	end process;
	
	div_clk_out <= div_clk;
	rows <= row_sig;
	kb_buf <= kb_buffer;
	
end architecture;
