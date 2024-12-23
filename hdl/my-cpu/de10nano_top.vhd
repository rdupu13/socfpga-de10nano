-- SPDX-License-Identifier: MIT
-- Copyright (c) 2024 Ross K. Snider, Trevor Vannoy.  All rights reserved.
----------------------------------------------------------------------------
-- Description:  Top level VHDL file for the DE10-Nano
----------------------------------------------------------------------------
-- Author:       Ross K. Snider, Trevor Vannoy
-- Company:      Montana State University
-- Create Date:  September 1, 2017
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_primitives_components.all;

-----------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
-----------------------------------------------------------
entity de10nano_top is
	port
	(
		----------------------------------------
		-- 50 MHz Clock inputs
		-- See DE10 Nano User Manual page 23
		----------------------------------------
		fpga_clk1_50 : in std_logic;
		fpga_clk2_50 : in std_logic;
		fpga_clk3_50 : in std_logic;
		
		----------------------------------------
		-- HDMI TX Interface
		-- See DE10 Nano User Manual page 34
		----------------------------------------
		hdmi_i2c_scl : inout std_logic;
		hdmi_i2c_sda : inout std_logic;
		hdmi_i2s     : inout std_logic;
		hdmi_lrclk   : inout std_logic;
		hdmi_mclk    : inout std_logic;
		hdmi_sclk    : inout std_logic;
		hdmi_tx_clk  : out   std_logic;
		hdmi_tx_d    : out   std_logic_vector(23 downto 0);
		hdmi_tx_de   : out   std_logic;
		hdmi_tx_hs   : out   std_logic;
		hdmi_tx_int  : in    std_logic;
		hdmi_tx_vs   : out   std_logic;
		
		----------------------------------------
		-- Push button inputs (KEY[0] and KEY[1])
		-- See DE10 Nano User Manual page 24
		-- The KEY push button inputs produce a '0'
		-- when pressed (asserted)
		-- and produce a '1' in the rest (non-pushed) state
		----------------------------------------
		push_button_n : in std_logic_vector(1 downto 0);
		
		----------------------------------------
		-- Slide switch inputs (SW)
		-- See DE10 Nano User Manual page 25
		-- The slide switches produce a '0' when
		-- in the down position
		-- (towards the edge of the board)
		----------------------------------------
		sw : in std_logic_vector(3 downto 0);
		
		----------------------------------------
		-- LED outputs
		-- See DE10 Nano User Manual page 26
		-- Setting LED to 1 will turn it on
		----------------------------------------
		led : out std_logic_vector(7 downto 0);
		
		----------------------------------------
		-- GPIO expansion headers (40-pin)
		-- See DE10 Nano User Manual page 27
		-- Pin 11 = 5V supply (1A max)
		-- Pin 29 = 3.3 supply (1.5A max)
		-- Pins 12, 30 = GND
		----------------------------------------
		gpio_0 : inout std_logic_vector(35 downto 0);
		gpio_1 : inout std_logic_vector(35 downto 0);
		
		----------------------------------------
		-- Arudino headers
		-- See DE10 Nano User Manual page 30
		----------------------------------------
		arduino_io      : inout std_logic_vector(15 downto 0);
		arduino_reset_n : inout std_logic;
		
		----------------------------------------
		-- ADC header
		-- See DE10 Nano User Manual page 32
		----------------------------------------
		adc_convst : out std_logic;
		adc_sck    : out std_logic;
		adc_sdi    : out std_logic;
		adc_sdo    : in  std_logic
	);
end entity;

architecture de10nano_arch of de10nano_top is
	
	component processor is
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
			data       : inout std_logic_vector(31 downto 0);
			address    : out   std_logic_vector(31 downto 0)
		);
	end component;
	
	entity  is
	
	end
	
	signal count   : unsigned(23 downto 0);
	signal div_clk : std_logic;
	
	signal bus_enable : std_logic;
	signal ready      : std_logic;
	signal irq        : std_logic_vector(3 downto 0);
	signal hw_exc     : std_logic_vector(3 downto 0);
	signal read_write : std_logic;
	signal vector     : std_logic;
	signal lock       : std_logic;
	signal sync       : std_logic;
	
	signal data       : std_logic_vector(15 downto 0);
	signal address    : std_logic_vector(15 downto 0);
	
begin
	
	CLOCK_DIV : process
	begin
		if push_button_n(0) = '0' then
			div_clk <= '0';
		elsif rising_edge(fpga_clk1_50) then
			if count < sw & "00000000000000000000" then
				div_clk <= '1';
			else
				div_clk <= '0';
			end if;
			count <= count + 1;
		end if;
	end process;
	
	CPU : processor
		port map
		(
			clk        => div_clk,
			rst        => push_button_n(0),
			bus_enable => bus_enable,
			ready      => ready,
			irq        => irq,
			hw_exc     => hw_exc,
			read_write => read_write,
			vector     => vector,
			lock       => lock,
			sync       => sync,
			data       => data,
			address    => address
		);
	
	RAM : memory
		port map
		(
			clk        => div_clk,
			rst        => push_button_n(0),
			read_write => read_write,
			data       => data,
			address    => address
		);
	
	led <= div_clk & "0000000";
	
end architecture;	
