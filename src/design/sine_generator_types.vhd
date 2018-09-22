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
    constant SAMPLE_RATE_BITS: natural := natural(ceil(log(real(SAMPLE_RATE))/log(2.0)));
        
    constant PHASE_SPACE_SIZE: natural := natural(real(SAMPLE_RATE)/TARGET_FREQUENCY_RESOLUTION);
   
    constant POWER2_PHASE_SPACE_BITS: natural := natural(ceil(log(real(PHASE_SPACE_SIZE))/log(2.0)));
    constant POWER2_PHASE_SPACE_SIZE: natural := 2 ** POWER2_PHASE_SPACE_BITS;

    
    
    -- at 0.5 FS  POWER2_PHASE_SPACE_BITS-1 is the maximum step
    constant MAX_POWER2_PHASE_STEP_BITS : natural := POWER2_PHASE_SPACE_BITS-1;
    subtype phase_step_t is unsigned(MAX_POWER2_PHASE_STEP_BITS-1 downto 0);
    subtype phase_step_fraction_t is unsigned(SAMPLE_RATE_BITS-1 downto 0);
     
    constant QUANTIZED_FREQUENCY_RESOLUTION : real :=  real(SAMPLE_RATE) / real(POWER2_PHASE_SPACE_SIZE);
    constant PHASE_STEP : real := 1.0 / QUANTIZED_FREQUENCY_RESOLUTION;
    
    constant POWER2_PHASE_STEP_BITS1: natural :=  natural(floor(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES1 : real := 1.0 / POWER2_PHASE_STEP_BITS1;
    constant POWER2_PHASE_STEP_BITS2: natural :=  natural(ceil(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES2 : real := 1.0 / POWER2_PHASE_STEP_BITS2;
    constant POWER2_PHASE_STEP_BITS1_USABLE: boolean := FREQ_RES1 < TARGET_FREQUENCY_RESOLUTION;
    constant POWER2_PHASE_STEP_BITS : natural := sel(POWER2_PHASE_STEP_BITS1_USABLE, POWER2_PHASE_STEP_BITS1, POWER2_PHASE_STEP_BITS2);    
    constant POWER2_PHASE_STEP : natural := 2 ** POWER2_PHASE_STEP_BITS;
    
        -- max frequency = POWER2_PHASE_SPACE_SIZE/2
    constant FREQUENCY_SCALED_BITS : natural := SAMPLE_RATE_BITS -1 + POWER2_PHASE_STEP_BITS; 
    subtype frequency_t is unsigned(FREQUENCY_SCALED_BITS-1 downto 0);

    constant PHASE_STEP_SCALING_BITS: natural := POWER2_PHASE_SPACE_BITS - (POWER2_PHASE_STEP_BITS + 1);
    constant PHASE_STEP_SCALING_FACTOR: natural := 2 ** ( PHASE_STEP_SCALING_BITS );
      
    constant SCALED_PHASE_STEP : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR) * PHASE_STEP));
    constant SCALED_PHASE_STEP_BITS : natural := natural(ceil(abs(log2(real(SCALED_PHASE_STEP)))));
    constant DECIMAL_DIVIDER_BITS : natural := POWER2_PHASE_STEP_BITS + PHASE_STEP_SCALING_BITS;
    
    
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
        
        write( l, string'("SCALED_PHASE_STEP_BITS           = " ));                    
        write( l, SCALED_PHASE_STEP_BITS);
        writeline( output, l );
                
        write( l, string'("DECIMAL_DIVIDER_BITS             = " ));                    
        write( l, DECIMAL_DIVIDER_BITS);
        writeline( output, l );
        
        
    end Report_Constants ;
    -- synthesis translate_on     

    procedure Calculate_Phase_Step(
        frequency_scaled: in frequency_t;
              
        decimal: out phase_step_t;
        fractional: out phase_step_fraction_t) is 
        
        variable sc1: unsigned(SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS -1 downto 0);
        
        
        variable tmp: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS -1 downto 0);
        
        variable phase_step_numerator_incl_decimal: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
        variable decimal_truncated: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
   
        variable l: line;
                                     
    begin
        
            sc1  := frequency_scaled * SCALED_PHASE_STEP;


            write( l, string'("sc1_bits             = " ));                    
            write( l, sc1'left);
            writeline( output, l );
    
            write( l, string'("sc1             = " ));                    
            write( l, sc1);
            writeline( output, l );
            
            assert(SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS - DECIMAL_DIVIDER_BITS = MAX_POWER2_PHASE_STEP_BITS);
                        
            decimal := shift_right ( sc1, DECIMAL_DIVIDER_BITS);

            write( l, string'("decimal_bits             = " ));                    
            write( l, decimal'left);
            writeline( output, l );
    
            write( l, string'("decimal             = " ));                    
            write( l, decimal);
            writeline( output, l );
            
            tmp := POWER2_PHASE_SPACE_SIZE * frequency_scaled;

            write( l, string'("tmp_bits             = " ));                    
            write( l, tmp'left);
            writeline( output, l );
    
            write( l, string'("tmp             = " ));                    
            write( l, tmp);
              
            phase_step_numerator_incl_decimal := shift_right ( tmp, POWER2_PHASE_STEP_BITS);

            write( l, string'("phase_step_numerator_incl_decimal_bits             = " ));                    
            write( l, phase_step_numerator_incl_decimal'left);
            writeline( output, l );
    
            write( l, string'("phase_step_numerator_incl_decimal             = " ));                    
            write( l, phase_step_numerator_incl_decimal);
           
            decimal_truncated := decimal * SAMPLE_RATE;

            write( l, string'("decimal_truncated_bits             = " ));                    
            write( l, decimal_truncated'left);
            writeline( output, l );
    
            write( l, string'("decimal_truncated             = " ));                    
            write( l, decimal_truncated);
            
            fractional := phase_step_numerator_incl_decimal - decimal_truncated;

            write( l, string'("fractional_bits             = " ));                    
            write( l, fractional'left);
            writeline( output, l );
    
            write( l, string'("fractional             = " ));                    
            write( l, fractional);

    end Calculate_Phase_Step;
 

end;
