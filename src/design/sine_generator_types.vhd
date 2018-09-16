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
use ieee.math_real.all;
use work.types_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package sine_generator_types_pkg is    

    constant SINE_TABLE_PHASE_BITS : natural := 20;

    constant FREQUENCY_RESOLUTION : real := 0.01;
    
    
    -- a frequency value with the specified resolution can be represented by an
    -- unsigned value if it multiplied by a factor. Determine the factor
    constant FREQUENCY_DECIMALS : real := ceil(abs(log10(FREQUENCY_RESOLUTION)));
    constant FREQUENCY_FACTOR : natural := natural(10.0 ** FREQUENCY_DECIMALS);


    constant FREQUENCY_MAX : natural := 20000;
    constant FREQUENCY_BITS : natural := natural(ceil(log2(real(FREQUENCY_MAX * FREQUENCY_FACTOR))));

    subtype frequency_t is unsigned(FREQUENCY_BITS-1 downto 0);
    
    
    
    constant PHASE_STEPS_PER_SECOND_1HZ : real := real(2 ** SINE_TABLE_PHASE_BITS) * real(FREQUENCY_FACTOR) * real(1);
    constant PHASE_STEPS_PER_MCLK_1HZ : real := PHASE_STEPS_PER_SECOND_1HZ / real(MCLK_FREQ);    

    constant PHASE_STEPS_PER_SECOND_1HZ_minus : real := real(2 ** SINE_TABLE_PHASE_BITS) * real(FREQUENCY_FACTOR) * real(1.0-FREQUENCY_RESOLUTION);
    constant PHASE_STEPS_PER_MCLK_1HZ_minus : real := PHASE_STEPS_PER_SECOND_1HZ_minus / real(MCLK_FREQ);    
    
    constant PHASE_STEPS_PER_MCLK_DIFF : real := PHASE_STEPS_PER_MCLK_1HZ - PHASE_STEPS_PER_MCLK_1HZ_minus;
    constant PHASE_STEPS_PER_MCLK_DIFF_FRACT : real := PHASE_STEPS_PER_MCLK_DIFF - floor(PHASE_STEPS_PER_MCLK_DIFF);
    constant PHASE_STEPS_PER_MCLK_DIFF_BITS : natural := natural(ceil(log2(real(PHASE_STEPS_PER_MCLK_DIFF_FRACT))));
    constant PHASE_STEPS_PER_MCLK_FACTOR : natural := natural(2 ** PHASE_STEPS_PER_MCLK_DIFF_BITS);

    constant PHASE_DIVIDER_i : natural := FREQUENCY_FACTOR * PHASE_STEPS_PER_MCLK_FACTOR;
    constant PHASE_DIVIDER_BITS : natural := natural(ceil(log2(real(PHASE_DIVIDER_i))));
    
    constant PHASE_STEPS_PER_SECOND_BITS : natural := SINE_TABLE_PHASE_BITS + FREQUENCY_BITS + PHASE_STEPS_PER_MCLK_DIFF_BITS;
    
    
    
end;

package body sine_generator_types_pkg is 
end;
