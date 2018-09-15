----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/04/2018 11:51:51 PM
-- Design Name: 
-- Module Name: types - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package types_pkg is    
    --see datasheet https://statics.cirrus.com/pubs/proDatasheet/CS4344-45-48_F2.pdf
    constant MCLK_FREQ : integer := 18432000; -- Hz
    -- 48Khz sample rate
    constant LRCK_FREQ : integer := 48000; -- MCLK/384 
    --24 bits per LRCK phase (low = left channel)
    constant SCLK_FREQ : integer := LRCK_FREQ*48;
    constant SAMPLE_WIDTH : integer := 24;

    subtype sample_t is signed(SAMPLE_WIDTH-1 downto 0);
end;

package body types_pkg is 
end;

