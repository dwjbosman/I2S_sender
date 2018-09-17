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

    constant CLK_BITS : natural := 24;
    constant CLK_FREQUENCY : natural := 2 ** 24;
        
    constant SINE_TABLE_PHASE_BITS : natural := 20;

    constant FREQUENCY_RESOLUTION : real := 0.01;
    
    
    -- a frequency value with the specified resolution can be represented by an
    -- unsigned value if it multiplied by a factor. Determine the factor
    constant FREQUENCY_RESOLUTION_BITS : natural := natural(ceil(abs(log2(FREQUENCY_RESOLUTION))));
    constant FREQUENCY_FACTOR : natural := 2 ** FREQUENCY_RESOLUTION_BITS;

    constant FREQUENCY_INT_BITS : natural := 15;
    constant FREQUENCY_MAX : natural := 2 ** FREQUENCY_INT_BITS;
    constant FREQUENCY_BITS : natural := FREQUENCY_RESOLUTION_BITS + FREQUENCY_INT_BITS;

    subtype frequency_t is unsigned(FREQUENCY_BITS-1 downto 0);
    
    
    
    constant PHASE_STEPS_PER_SECOND_1HZ : natural := 2 ** (SINE_TABLE_PHASE_BITS + FREQUENCY_RESOLUTION_BITS);
    constant PHASE_STEPS_PER_MCLK_1HZ : real := real(PHASE_STEPS_PER_SECOND_1HZ) / real(CLK_FREQUENCY);    

    constant PHASE_STEPS_PER_SECOND_1HZ_minus : real := real(2 ** (SINE_TABLE_PHASE_BITS + FREQUENCY_RESOLUTION_BITS)) * (1.0-FREQUENCY_RESOLUTION);
    constant PHASE_STEPS_PER_MCLK_1HZ_minus : real := PHASE_STEPS_PER_SECOND_1HZ_minus / real(CLK_FREQUENCY);    
    
    constant PHASE_STEPS_PER_MCLK_DIFF : real := PHASE_STEPS_PER_MCLK_1HZ - PHASE_STEPS_PER_MCLK_1HZ_minus;
    constant PHASE_STEPS_PER_MCLK_DIFF_FRACT : real := PHASE_STEPS_PER_MCLK_DIFF - floor(PHASE_STEPS_PER_MCLK_DIFF);
    constant PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS : natural := natural(ceil(log2(real(PHASE_STEPS_PER_MCLK_DIFF_FRACT))));
    constant PHASE_STEPS_PER_MCLK_FACTOR : natural := natural(2 ** PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS);

    constant PHASE_DIVIDER_BITS : natural := FREQUENCY_RESOLUTION_BITS + PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS;
    constant PHASE_DIVIDER_i : natural := 2 ** PHASE_DIVIDER_BITS;
    
    constant PHASE_STEPS_PER_SECOND_BITS : natural := SINE_TABLE_PHASE_BITS + FREQUENCY_BITS + PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS;
    constant PHASE_STEPS_PER_MCLK_BITS : natural := PHASE_STEPS_PER_SECOND_BITS - CLK_BITS;
       
    
    
end;

package body sine_generator_types_pkg is 

procedure Report_Constants is 
begin
    report "FREQUENCY_RESOLUTION                 = " & real'image(FREQUENCY_RESOLUTION);
    report "FREQUENCY_RESOLUTION_BITS            = " & integer'image(FREQUENCY_RESOLUTION_BITS);
    report "PHASE_STEPS_PER_SECOND_1HZ           = " & integer'image(PHASE_STEPS_PER_SECOND_1HZ);
    report "PHASE_STEPS_PER_MCLK_1HZ             = " & real'image(PHASE_STEPS_PER_MCLK_1HZ);
    report "PHASE_STEPS_PER_SECOND_1HZ_minus     = " & real'image(PHASE_STEPS_PER_SECOND_1HZ_minus);
    report "PHASE_STEPS_PER_MCLK_1HZ_minus       = " & real'image(PHASE_STEPS_PER_MCLK_1HZ_minus);
    report "PHASE_STEPS_PER_MCLK_DIFF            = " & real'image(PHASE_STEPS_PER_MCLK_DIFF);
    report "PHASE_STEPS_PER_MCLK_DIFF_FRACT      = " & real'image(PHASE_STEPS_PER_MCLK_DIFF_FRACT);
    report "PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS = " & integer'image(PHASE_STEPS_PER_MCLK_DIFF_FRACT_BITS);
    report "PHASE_STEPS_PER_MCLK_FACTOR          = " & integer'image(PHASE_STEPS_PER_MCLK_FACTOR);
    report "PHASE_DIVIDER_BITS                   = " & integer'image(PHASE_DIVIDER_BITS);
    report "PHASE_DIVIDER_i                      = " & integer'image(PHASE_DIVIDER_i);
    report "PHASE_STEPS_PER_SECOND_BITS          = " & integer'image(PHASE_STEPS_PER_SECOND_BITS);
    report "PHASE_STEPS_PER_MCLK_BITS            = " & integer'image(PHASE_STEPS_PER_MCLK_BITS);
                     
    
end Report_Constants ;

end;
