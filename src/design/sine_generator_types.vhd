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

package sine_generator_func_pkg is    
     function sel(Cond: BOOLEAN; If_True, If_False: natural) return natural;
end;

package body sine_generator_func_pkg is 

     function sel(Cond: BOOLEAN; If_True, If_False: natural) return natural is
       begin
           if (Cond = TRUE) then
               return(If_True);
           else
               return(If_False);
           end if;
       end function sel; 
end;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
use work.types_pkg.all;
use work.sine_generator_func_pkg.all;

use STD.textio.all;
--use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package sine_generator_types_pkg is    

    
    constant TARGET_FREQUENCY_RESOLUTION : real := 0.05; -- Hz
    constant SAMPLE_RATE: natural := 48000; --Hz
    constant PHASE_SPACE_SIZE: natural := natural(real(SAMPLE_RATE)/TARGET_FREQUENCY_RESOLUTION);
   
    constant POWER2_PHASE_SPACE_BITS: natural := natural(ceil(log(real(PHASE_SPACE_SIZE))/log(2.0)));
    constant POWER2_PHASE_SPACE_SIZE: natural := 2 ** POWER2_PHASE_SPACE_BITS;

    -- max frequency = POWER2_PHASE_SPACE_SIZE/2
    subtype frequency_t is unsigned(POWER2_PHASE_SPACE_BITS-2 downto 0);
 
    constant QUANTIZED_FREQUENCY_RESOLUTION : real :=  real(SAMPLE_RATE) / real(POWER2_PHASE_SPACE_SIZE);
    constant PHASE_STEP : real := 1.0 / QUANTIZED_FREQUENCY_RESOLUTION;
    
    constant POWER2_PHASE_STEP_BITS1: natural :=  natural(floor(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES1 : real := 1.0 / POWER2_PHASE_STEP_BITS1;
    constant POWER2_PHASE_STEP_BITS2: natural :=  natural(ceil(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES2 : real := 1.0 / POWER2_PHASE_STEP_BITS2;
    constant POWER2_PHASE_STEP_BITS1_USABLE: boolean := FREQ_RES1 < TARGET_FREQUENCY_RESOLUTION;
    constant POWER2_PHASE_STEP_BITS : natural := sel(POWER2_PHASE_STEP_BITS1_USABLE, POWER2_PHASE_STEP_BITS1, POWER2_PHASE_STEP_BITS2);
    
    constant POWER2_PHASE_STEP : natural := 2 ** POWER2_PHASE_STEP_BITS;
    constant PHASE_STEP_SCALING_BITS: natural := POWER2_PHASE_SPACE_BITS - (POWER2_PHASE_STEP_BITS + 1);
    constant PHASE_STEP_SCALING_FACTOR: natural := 2 ** ( PHASE_STEP_SCALING_BITS );
      
    constant SCALED_PHASE_STEP : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR) * PHASE_STEP));
    constant DECIMAL_DIVIDER_BITS : natural := POWER2_PHASE_STEP_BITS + PHASE_STEP_SCALING_BITS;
    
     
    /**

    constant CLK_BITS : natural := 24;
    constant CLK_FREQUENCY : natural := 2 ** 24;
        
    constant SINE_TABLE_PHASE_BITS : natural := 20;

    constant FREQUENCY_RESOLUTION : real := 1.0/100.0;
    
    
    -- a frequency value with the specified resolution can be represented by an
    -- unsigned value if it multiplied by a factor. Determine the factor
    constant FREQUENCY_RESOLUTION_BITS : natural := natural(ceil(abs(log2(FREQUENCY_RESOLUTION))));
    constant FREQUENCY_FACTOR : natural := 2 ** FREQUENCY_RESOLUTION_BITS;

    constant FREQUENCY_INT_BITS : natural := 15;
    constant FREQUENCY_MAX : natural := 2 ** FREQUENCY_INT_BITS;
    constant FREQUENCY_BITS : natural := FREQUENCY_RESOLUTION_BITS + FREQUENCY_INT_BITS;

    
    
    
    constant PHASE_STEPS_PER_SECOND_1HZ : natural := (2 ** SINE_TABLE_PHASE_BITS) * ( 2 ** FREQUENCY_RESOLUTION_BITS);
    constant PHASE_STEPS_PER_CLK_1HZ : real := real(PHASE_STEPS_PER_SECOND_1HZ) / real(CLK_FREQUENCY);    

    constant PHASE_STEPS_PER_SECOND_1HZ_minus : natural := (2 ** SINE_TABLE_PHASE_BITS) * (( 2 ** FREQUENCY_RESOLUTION_BITS) -1);
    constant PHASE_STEPS_PER_CLK_1HZ_minus : real := real(PHASE_STEPS_PER_SECOND_1HZ_minus) / real(CLK_FREQUENCY);    
    
    constant PHASE_STEPS_PER_CLK_DIFF : real := PHASE_STEPS_PER_CLK_1HZ - PHASE_STEPS_PER_CLK_1HZ_minus;
    constant PHASE_STEPS_PER_CLK_DIFF_FRACT : real := PHASE_STEPS_PER_CLK_DIFF - floor(PHASE_STEPS_PER_CLK_DIFF);
    constant PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS : natural := natural(ceil(abs(log2(real(PHASE_STEPS_PER_CLK_DIFF_FRACT)))));
    constant PHASE_STEPS_PER_CLK_FACTOR : natural := natural(2 ** PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS);

    constant PHASE_DIVIDER_BITS : natural := FREQUENCY_RESOLUTION_BITS + PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS;
    constant PHASE_DIVIDER_i : natural := 2 ** PHASE_DIVIDER_BITS;
    
    constant PHASE_STEPS_PER_SECOND_BITS : natural := SINE_TABLE_PHASE_BITS + FREQUENCY_BITS + PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS;
    constant PHASE_STEPS_PER_CLK_BITS : natural := PHASE_STEPS_PER_SECOND_BITS - CLK_BITS;
       
    constant SHIFT_FREQ_SPLIT_BITPOS : integer := CLK_BITS - (SINE_TABLE_PHASE_BITS + PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS ) + PHASE_DIVIDER_BITS;
    **/
    
    -- synthesis translate_off
    procedure Report_Constants(constant dummy: in integer);
    -- synthesis translate_on     
end;

package body sine_generator_types_pkg is 


    -- synthesis translate_off




    procedure Report_Constants ( constant dummy: in integer) is 
        variable l: line;
    begin
                          
        write( l, string'("TARGET_FREQUENCY_RESOLUTION      = " ));                    
        write( l, TARGET_FREQUENCY_RESOLUTION);
        writeline( output, l );

        write( l, string'("SAMPLE_RATE                      = " ));                    
        write( l, SAMPLE_RATE);
        writeline( output, l );

        write( l, string'("PHASE_SPACE_SIZE                 = " ));                    
        write( l, PHASE_SPACE_SIZE);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_SPACE_BITS          = " ));                    
        write( l, POWER2_PHASE_SPACE_BITS);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_SPACE_SIZE          = " ));                    
        write( l, POWER2_PHASE_SPACE_SIZE);
        writeline( output, l );

        write( l, string'("QUANTIZED_FREQUENCY_RESOLUTION   = " ));                    
        write( l, QUANTIZED_FREQUENCY_RESOLUTION);
        writeline( output, l );

        write( l, string'("PHASE_STEP                       = " ));                    
        write( l, PHASE_STEP);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_STEP_BITS1          = " ));                    
        write( l, POWER2_PHASE_STEP_BITS1);
        writeline( output, l );

        write( l, string'("FREQ_RES1                        = " ));                    
        write( l, FREQ_RES1);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_STEP_BITS2          = " ));                    
        write( l, POWER2_PHASE_STEP_BITS2);
        writeline( output, l );

        write( l, string'("FREQ_RES2                        = " ));                    
        write( l, FREQ_RES2);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_STEP_BITS1_USABLE   = " ));                    
        write( l, POWER2_PHASE_STEP_BITS1_USABLE);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_STEP_BITS           = " ));                    
        write( l, POWER2_PHASE_STEP_BITS);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_STEP                = " ));                    
        write( l, POWER2_PHASE_STEP);
        writeline( output, l );

        write( l, string'("PHASE_STEP_SCALING_BITS          = " ));                    
        write( l, PHASE_STEP_SCALING_BITS);
        writeline( output, l );

        write( l, string'("PHASE_STEP_SCALING_FACTOR        = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR);
        writeline( output, l );

        write( l, string'("SCALED_PHASE_STEP                = " ));                    
        write( l, SCALED_PHASE_STEP);
        writeline( output, l );
        
        write( l, string'("DECIMAL_DIVIDER_BITS             = " ));                    
        write( l, DECIMAL_DIVIDER_BITS);
        writeline( output, l );
        
        
    end Report_Constants ;
    -- synthesis translate_on     

    procedure Calculate_Phase_Step(
        frequency: in frequency_t;
              
        decimal: out frequency_t;
        fractional: out frequency_t) is 
        
    begin
        --decimal := (FREQUENCY_BITS-1-SHIFT_FREQ_SPLIT_BITPOS downto 0 => frequency(FREQUENCY_BITS-1 downto SHIFT_FREQ_SPLIT_BITPOS), others => '0');
        --fractional := (PHASE_DIVIDER_BITS-1 downto 0 => frequency(SHIFT_FREQ_SPLIT_BITPOS-1 downto SHIFT_FREQ_SPLIT_BITPOS-PHASE_DIVIDER_BITS-1), others => '0');
                
    Let's say the frequency to generate is 440 Hz:
        
            frequency_scaled = frequency * power2_phase_step
            frequency_scaled -> 56320
        
        If it would be possible to use floating point arithmatic the phase step would be:
        
            phase_step_fp  = ( power2_phase_space_size / sample_rate ) * frequency
        
        or rewritten:
        
            phase_step_fp -> ( power2_phase_space_size * frequency ) / sample_rate
            phase_step_fp -> 76895.5733333333
        
        The integer version of phase_step_fp consists of phase_step_decimal and phase_step_numerator. Phase_step_decimal will give the decimal part (in the example 76895) while the fraction (0.57333...) will be specified as a numerator, divisor pair (a rational number). The decimal part is calculated as follows:
        
            scaled_phase  = trunc(frequency_scaled * scaled_phase_step)
            scaled_phase -> 322523407360
            phase_step_decimal  = shift_right ( scaled_phase, power2_phase_step_bits + phase_step_scaling_factor)
            phase_step_decimal -> 76895
        
        As a check the phase_step_decimal is indeed equal to the decimal part of phase_step_fp. 
        
        Now the fractional part is calculated as a rational value. The value consists of a numerator and divisor.  Recall the calculation of phase_step_fp:
        
            phase_step_fp -> ( power2_phase_space_size * frequency ) / sample_rate
        
        This value can be converted to a rational number:
        
            phase_step_divisor  = sample_rate
            phase_step_divisor -> 48000
        
            phase_step_numerator_incl_decimal  = power2_phase_space_size * frequency

phase_step_numerator_incl_decimal -> 3690987520

As phase_step_fp is larger then one the numerator is larger then the divisor. To get the fractional part without the decimal part the decimal value is subtracted:

    phase_step_numerator  = phase_step_numerator_incl_decimal - phase_step_decimal * sample_rate
    phase_step_numerator -> 27520

Lastly assert that the numerator is indeed equal to the fractional part of phase_step_fp:

    phase_step_fp -> 76895.5733333333
    phase_step_numerator / phase_step_divisor -> 0.573333333...


    end Calculate_Phase_Step;
 

end;
