library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity processor is
	port
	(	
		clk        : in    std_logic;
		rst        : in    std_logic;
		
		bus_enable : in    std_logic;
		ready      : in    std_logic;
		irq        : in    std_logic_vector(3 downto 0);
		hw_exc     : in    std_logic_vector(3 downto 0);
		
		read_write : out   std_logic;
		vector     : out   std_logic;
		lock       : out   std_logic;
		sync       : out   std_logic;
		
		data       : inout std_logic_vector(15 downto 0);
		address    : out   std_logic_vector(15 downto 0)
	);
end entity;

architecture processor_arch of processor is
	
	component control_unit is
		port
		(
			clk        : in  std_logic;
			rst        : in  std_logic;
			
			bus_enable : in  std_logic;
			ready      : in  std_logic;
			irq        : in  std_logic_vector(3 downto 0);
			hw_exc     : in  std_logic_vector(3 downto 0);
			p_status   : in  std_logic_vector(15 downto 0);
			
			read_write : out std_logic;
			vector     : out std_logic;
			lock       : out std_logic;
			sync       : out std_logic;
			
			alu_sel    : out std_logic_vector(3 downto 0);
			
		);
	end component;
	
	component alu is
		port
		(
			clk     : in  std_logic;
			rst     : in  std_logic;
			alu_sel : in  std_logic_vector(3 downto 0);
			opd1_in : in  std_logic_vector(15 downto 0);
			opd2_in : in  std_logic_vector(15 downto 0);
			result  : out std_logic_vector(15 downto 0)
		);
	end component;
	
	-- irq disable (iiii)
	-- carry (c)
	-- zero (z)
	-- negative (n)
	-- overflow (v)
	-- endianness (e)                    -0 -1 -2 -3   transfer order
	--     0 = little endian 0A0B0C0D => 0D 0C 0B 0A   low byte first  <- I prefer
	--     1 = big endian    0A0B0C0D => 0A 0B 0C 0D   high byte first
	-- modes (mm)
	--     001 - usr    USeR
	--     100 - exc    hardware EXCeption
	--     101 - irq    InteRRupt ReQuest
	--     110 - knl    KerNeL
	--     111 - 
	
	-- processor status bit layout
	
	-- 1111 iiii vnzc epmm
	
	
	
	-- context block (16 x 16) -----------------------------
	signal register_0       : std_logic_vector(15 downto 0);
	signal register_1       : std_logic_vector(15 downto 0);
	signal register_2       : std_logic_vector(15 downto 0);
	signal register_3       : std_logic_vector(15 downto 0);
	signal register_4       : std_logic_vector(15 downto 0);
	signal register_5       : std_logic_vector(15 downto 0);
	signal register_6       : std_logic_vector(15 downto 0);
	signal register_7       : std_logic_vector(15 downto 0);
	signal register_8       : std_logic_vector(15 downto 0);
	signal register_9       : std_logic_vector(15 downto 0);
	signal register_a       : std_logic_vector(15 downto 0);
	signal base_pointer     : std_logic_vector(15 downto 0); -- "register_b"
	signal stack_pointer    : std_logic_vector(15 downto 0); -- "register_c"
	signal link_register    : std_logic_vector(15 downto 0); -- "register_d"
	signal program_counter  : std_logic_vector(15 downto 0); -- "register_e"
	signal processor_status : std_logic_vector(15 downto 0); -- "register_f"
	--------------------------------------------------------
	
	signal instruction_register : std_logic_vector(15 downto 0);
	signal address_register     : std_logic_vector(15 downto 0);
	
	signal d1_bus  : std_logic_vector(15 downto 0);
	signal d2_bus  : std_logic_vector(15 downto 0);
	
	signal alu_sel : std_logic_vector(3 downto 0);
	
	
	
begin
	
	CONTROL_UNIT_COMPONENT : control_unit
		port map
		(
			clk          => clk,
			rst          => rst,
			
			bus_enable   => bus_enable,
			ready        => ready,
			interrupt    => interrupt,
			nm_interrupt => nm_interrupt,
			p_status     => processor_status,
			
			read_write   => read_write,
			vector_pull  => vector_pull,
			memory_lock  => memory_lock,
			synchronize  => synchronize,
			alu_sel      => alu_sel,
			src_sel      => src_sel,
			dst_sel      => dst_sel
		);
	
	
	
	ALU_COMPONENT : alu
		port map
		(
			clk     => clk,
			rst     => rst,
			alu_sel => alu_sel,
			opd1_in => d2_bus,
			opd1_in => d2_bus,
			result  => dout
		);
	
	CONTEXT_BLOCK_REGISTERS : process (clk, rst)
	begin
		if rst = '0' then
			register_0       <= x"0005";
			register_1       <= x"0003";
			register_2       <= x"0000";
			register_3       <= x"0000";
			register_4       <= x"0000";
			register_5       <= x"0000";
			register_6       <= x"0000";
			register_7       <= x"0000";
			register_8       <= x"0000";
			register_9       <= x"0000";
			register_a       <= x"0000";
			base_pointer     <= x"0000";
			stack_pointer    <= x"0000";
			link_register    <= x"0000";
			program_counter  <= x"0000";
			processor_status <= x"F006";
		elsif rising_edge(div_clk) then
			
		end if;
	end process;
	
end architecture;
