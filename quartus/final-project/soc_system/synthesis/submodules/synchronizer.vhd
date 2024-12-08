library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
	port(
		clk   : in  std_ulogic;
		async : in  std_ulogic;
		sync  : out std_ulogic
		);
end entity;

architecture synchronizer_arch of synchronizer is
	
	signal q1 : std_ulogic;
	
begin
	
	D_FLIP_FLOPS : process(clk)
	begin
		-- Update both flip flops on rising clock edge
		if rising_edge(clk) then
			-- First flip flop
			q1 <= async;
			-- Second flip flop
			sync <= q1;
		end if;
	end process;
	
end architecture;