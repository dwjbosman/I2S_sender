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
     function sel(Cond: BOOLEAN; If_True, If_False: real) return real;
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

     function sel(Cond: BOOLEAN; If_True, If_False: real) return real is
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
    constant MAX_FREQUENCY : natural := SAMPLE_RATE/2;   
     
    constant PHASE_SPACE_SIZE: natural := natural(real(SAMPLE_RATE)/TARGET_FREQUENCY_RESOLUTION);
   
    constant POWER2_PHASE_SPACE_BITS: natural := natural(ceil(log(real(PHASE_SPACE_SIZE))/log(2.0)));
    constant POWER2_PHASE_SPACE_SIZE: natural := 2 ** POWER2_PHASE_SPACE_BITS;

    
    
    -- at 0.5 FS  POWER2_PHASE_SPACE_BITS-1 is the maximum step
    constant MAX_POWER2_PHASE_STEP_BITS : natural := POWER2_PHASE_SPACE_BITS-1;
    subtype phase_step_t is unsigned(MAX_POWER2_PHASE_STEP_BITS-1 downto 0);
    subtype phase_step_fraction_t is unsigned(SAMPLE_RATE_BITS-1 downto 0);
     
    constant PHASE_STEP_FRACTION_DIVIDER : phase_step_fraction_t := to_unsigned(SAMPLE_RATE, phase_step_fraction_t'length);
     
    constant QUANTIZED_FREQUENCY_RESOLUTION : real :=  real(SAMPLE_RATE) / real(POWER2_PHASE_SPACE_SIZE);
    constant PHASE_STEP : real := 1.0 / QUANTIZED_FREQUENCY_RESOLUTION;
    constant PHASE_STEP_BITS : real := log2(PHASE_STEP);
        
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

    constant MAX_QUANTISED_PHASE_STEP_ERROR : real := 1.0/MAX_FREQUENCY;
    constant MAX_QUANTISED_PHASE_STEP_ERROR_BITS : real := log2(MAX_QUANTISED_PHASE_STEP_ERROR);
    
    constant SCALED_PHASE_STEP_BITS : natural := natural(ceil( PHASE_STEP_BITS + MAX_QUANTISED_PHASE_STEP_ERROR_BITS));
    
    constant PHASE_STEP_SCALING_FACTOR_BITS1 : natural := natural(floor ( MAX_QUANTISED_PHASE_STEP_ERROR_BITS ));
    constant PHASE_STEP_SCALING_FACTOR1: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS1 );
    constant SCALED_PHASE_STEP1 : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR1) * PHASE_STEP));
    constant PHASE_STEP_ERROR1: real := PHASE_STEP - real(SCALED_PHASE_STEP1) / real(PHASE_STEP_SCALING_FACTOR1);
    constant PHASE_STEP_MAX_ERROR1: real := MAX_FREQUENCY * PHASE_STEP_ERROR1;

    constant PHASE_STEP_SCALING_FACTOR_BITS2 : natural := natural(ceil ( MAX_QUANTISED_PHASE_STEP_ERROR_BITS ));
    constant PHASE_STEP_SCALING_FACTOR2: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS2 );
    constant SCALED_PHASE_STEP2 : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR2) * PHASE_STEP));
    constant PHASE_STEP_ERROR2: real := PHASE_STEP - real(SCALED_PHASE_STEP2) / real(PHASE_STEP_SCALING_FACTOR2);
    constant PHASE_STEP_MAX_ERROR2: real := MAX_FREQUENCY * PHASE_STEP_ERROR2;
                
    constant PHASE_STEP_SCALING_FACTOR_BITS1_USABLE: boolean := PHASE_STEP_MAX_ERROR1<1.0;
    constant PHASE_STEP_SCALING_FACTOR_BITS : natural := sel(PHASE_STEP_SCALING_FACTOR_BITS1_USABLE, PHASE_STEP_SCALING_FACTOR_BITS1, PHASE_STEP_SCALING_FACTOR_BITS2);    
    constant PHASE_STEP_SCALING_FACTOR: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS );
    constant SCALED_PHASE_STEP : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR) * PHASE_STEP));
                                  
    constant DECIMAL_DIVIDER_BITS : natural := POWER2_PHASE_STEP_BITS + PHASE_STEP_SCALING_FACTOR_BITS;
    
    
    -- synthesis translate_off
    procedure Report_Constants(constant dummy: in integer);
    -- synthesis translate_on     
    
    procedure Calculate_Phase_Step(
        frequency_scaled: in frequency_t;
              
        decimal: out phase_step_t;
        fractional: out phase_step_fraction_t);

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

        write( l, string'("MAX_FREQUENCY                    = " ));                    
        write( l, MAX_FREQUENCY);
        writeline( output, l );

        write( l, string'("PHASE_SPACE_SIZE                 = " ));                    
        write( l, PHASE_SPACE_SIZE);
        writeline( output, l );

        write( l, string'("POWER2_PHASE_SPACE_BITS          = " ));                    
        write( l, POWER2_PHASE_SPACE_BITS);
        writeline( output, l );

        write( l, string'("MAX_POWER2_PHASE_STEP_BITS       = " ));                    
        write( l, MAX_POWER2_PHASE_STEP_BITS);
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

        write( l, string'("PHASE_STEP_BITS                  = " ));                    
        write( l, PHASE_STEP_BITS);
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

        write( l, string'("FREQUENCY_SCALED_BITS            = " ));                    
        write( l, FREQUENCY_SCALED_BITS);
        writeline( output, l );

        write( l, string'("MAX_QUANTISED_PHASE_STEP_ERROR   = " ));                    
        write( l, MAX_QUANTISED_PHASE_STEP_ERROR);
        writeline( output, l );

        write( l, string'("MAX_QUANTISED_PHASE_STEP_ERROR_BITS= " ));                    
        write( l, MAX_QUANTISED_PHASE_STEP_ERROR_BITS);
        writeline( output, l );

        write( l, string'("SCALED_PHASE_STEP_BITS           = " ));                    
        write( l, SCALED_PHASE_STEP_BITS);
        writeline( output, l );
    
        write( l, string'("PHASE_STEP_SCALING_FACTOR_BITS1  = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR_BITS1);
        writeline( output, l );

        write( l, string'("PHASE_STEP_SCALING_FACTOR1       = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR1);
        writeline( output, l );

        write( l, string'("SCALED_PHASE_STEP1               = " ));                    
        write( l, SCALED_PHASE_STEP1);
        writeline( output, l );

        write( l, string'("PHASE_STEP_ERROR1                = " ));                    
        write( l, PHASE_STEP_ERROR1);
        writeline( output, l );

        write( l, string'("PHASE_STEP_MAX_ERROR1            = " ));                    
        write( l, PHASE_STEP_MAX_ERROR1);
        writeline( output, l );
    
        write( l, string'("PHASE_STEP_SCALING_FACTOR_BITS2  = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR_BITS2);
        writeline( output, l );

        write( l, string'("PHASE_STEP_SCALING_FACTOR2       = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR2);
        writeline( output, l );

        write( l, string'("SCALED_PHASE_STEP2               = " ));                    
        write( l, SCALED_PHASE_STEP2);
        writeline( output, l );

        write( l, string'("PHASE_STEP_ERROR2                = " ));                    
        write( l, PHASE_STEP_ERROR2);
        writeline( output, l );

        write( l, string'("PHASE_STEP_MAX_ERROR2            = " ));                    
        write( l, PHASE_STEP_MAX_ERROR2);
        writeline( output, l );

        write( l, string'("PHASE_STEP_SCALING_FACTOR_BITS1_USABLE= " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR_BITS1_USABLE);
        writeline( output, l );
                
        write( l, string'("PHASE_STEP_SCALING_FACTOR_BITS  = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR_BITS);
        writeline( output, l );
 
        write( l, string'("PHASE_STEP_SCALING_FACTOR       = " ));                    
        write( l, PHASE_STEP_SCALING_FACTOR);
        writeline( output, l );
 
        write( l, string'("SCALED_PHASE_STEP               = " ));                    
        write( l, SCALED_PHASE_STEP);
        writeline( output, l );
                        
        write( l, string'("DECIMAL_DIVIDER_BITS            = " ));                    
        write( l, DECIMAL_DIVIDER_BITS);
        writeline( output, l );
        
        
    end Report_Constants ;
    -- synthesis translate_on     

    procedure Calculate_Phase_Step(
        frequency_scaled: in frequency_t;
              
        decimal: out phase_step_t;
        fractional: out phase_step_fraction_t) is 
        
        variable scaled_phase: unsigned(SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS -1  downto 0);
        
        
        --variable tmp: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS -1 downto 0);
        
        variable phase_step_numerator_incl_decimal: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
        variable decimal_scaled: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
   
        variable l: line;
                                     
    begin
    
            write( l, string'("sc1_bits             = " ));                    
            write( l, scaled_phase'length);
            writeline( output, l );

            write( l, string'("decimal_bits             = " ));                    
            write( l, decimal'length);
            writeline( output, l );

            write( l, string'("phase_step_numerator_incl_decimal_bits             = " ));                    
            write( l, phase_step_numerator_incl_decimal'length);
            writeline( output, l );

            write( l, string'("decimal_scaled_bits             = " ));                    
            write( l, decimal_scaled'length);
            writeline( output, l );

            write( l, string'("fractional_bits             = " ));                    
            write( l, fractional'length);
            writeline( output, l );

            write( l, string'("frequency_scaled             = " ));                    
            write( l, to_hstring(frequency_scaled));
            writeline( output, l );
        
            scaled_phase  := resize(frequency_scaled * SCALED_PHASE_STEP, scaled_phase'length);
    
            write( l, string'("sc1             = " ));                    
            write( l, to_hstring(scaled_phase));
            writeline( output, l );
            
            write( l, string'("assert " ));                    
            write( l, (SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS - DECIMAL_DIVIDER_BITS -1 ));
            write( l, string'(" == " ));                    
            write( l, MAX_POWER2_PHASE_STEP_BITS);
            writeline( output, l );                        
            assert(SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS - DECIMAL_DIVIDER_BITS -1 = MAX_POWER2_PHASE_STEP_BITS) report "Assertion violation." severity error;
                        
            decimal := scaled_phase(DECIMAL_DIVIDER_BITS + decimal'length -1 downto DECIMAL_DIVIDER_BITS);
            write( l, string'("decimal             = " ));                    
            write( l, to_hstring(decimal));
            writeline( output, l );
   
   
            -- num: frequency_scaled * power2_phase_space_size
            -- size: FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS 
            -- num: (frequency_scaled * power2_phase_space_size)/ power2_phase_space_size
            -- size: FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS
            phase_step_numerator_incl_decimal := frequency_scaled & to_unsigned(0, POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS);
            
            write( l, string'("phase_step_numerator_incl_decimal             = " ));                    
            write( l, to_hstring(phase_step_numerator_incl_decimal));
            writeline( output, l );
                        
            decimal_scaled := resize(decimal * SAMPLE_RATE, decimal_scaled'length);
            write( l, string'("decimal_truncated             = " ));                    
            write( l, to_hstring(decimal_scaled));
            writeline( output, l );
                        
            fractional := resize(
                phase_step_numerator_incl_decimal(fractional'length -1 downto 0) - decimal_scaled(fractional'length -1 downto 0),
                fractional'length);
            write( l, string'("fractional             = " ));                    
            write( l, to_hstring(fractional));
            writeline( output, l );
                        
            if (fractional >= PHASE_STEP_FRACTION_DIVIDER) then
                fractional := fractional - PHASE_STEP_FRACTION_DIVIDER;
                decimal := decimal + 1;
            end if;
    end Calculate_Phase_Step;
 

end;
