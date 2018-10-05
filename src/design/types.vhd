----------------------------------------------------------------------------------
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 09/06/2018 11:49:12 PM
-- Module Name: i2s_types - package
-- 
-- Additional Comments:
-- https://store.digilentinc.com/pmod-i2s2-stereo-audio-input-and-output/
-- https://statics.cirrus.com/pubs/proDatasheet/CS4344-45-48_F2.pdf
-- PMOD pin 1: MCLK
-- PMOD pin 2 LRCK
-- PMOD pin 3 SCLK
-- PMOD pin 4 SDIN
--
-- This packagae contains I2S sender configuration constants 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

package i2s_types_pkg is    
    --see datasheet https://statics.cirrus.com/pubs/proDatasheet/CS4344-45-48_F2.pdf
    constant MCLK_FREQ : integer := 18432000; -- Hz
    constant MCLK_BITS : natural := integer(ceil(log2(real(MCLK_FREQ))));

    -- 48Khz sample rate
    constant LRCK_FREQ : integer := 48000; -- MCLK/384 
    --24 bits per LRCK phase (low = left channel, high = right channel)
    
    constant SAMPLE_WIDTH : integer := 24;
    subtype sample_t is signed(SAMPLE_WIDTH-1 downto 0);

    --exactly 2*24 bits in an LRCK frame
    constant SCLK_FREQ : integer := LRCK_FREQ * 2 * SAMPLE_WIDTH;
    
    --used to support debugging with optional embedded ila
    attribute mark_debug : string; 
    attribute keep : string; 
end;

package body i2s_types_pkg is 


end;

