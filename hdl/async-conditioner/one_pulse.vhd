library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_pulse is
	port (
		clk   : in  std_ulogic;
		rst   : in  std_ulogic;
		input : in  std_ulogic;
		pulse : out std_ulogic
	);
end entity;

architecture one_pulse_arch of one_pulse is
	
	signal clock_cycles_on : natural := 0;
	
	begin
		
		PULSE_GEN : process(rst, clk, input) is
		begin
			if rst = '1' then
				-- Idle state, no pulse
				pulse <= '0';
				clock_cycles_on <= 0;
			elsif rising_edge(clk) then
				case (input) is
					when '1' =>
						-- Begin counting once input goes to 1
						clock_cycles_on <= clock_cycles_on + 1;
						-- Only drive pulse if count has just begun
						if clock_cycles_on > 0 then
							pulse <= '0';
						else
							pulse <= '1';
						end if;
					when others =>
						-- Idle state, no pulse
						pulse <= '0';
						clock_cycles_on <= 0;
				end case;
			end if;
		end process;
		
end architecture;