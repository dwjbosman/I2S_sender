----------------------------------------------------------------------------------
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 09/06/2018 11:49:12 PM
-- Module Name: sine types package
-- 
-- Additional Comments:
-- This library contains constants and functions to calculate the phase step when
-- generating a sine wave given a target frequency
-- At design time frequency resolution and sample rate should be set
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

package sine_generator_func_pkg is    
     -- this function allows settings constants to certain values given a condition
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
use IEEE.NUMERIC_STD.ALL;

use ieee.math_real.all;
use work.i2s_types_pkg.all;
use work.sine_generator_func_pkg.all;
use STD.textio.all;

package sine_generator_types_pkg is    
    --parameters in this package are explained in my blog:
    --also a google sheets version can be found here:

    --these are the input parameters:    
    constant TARGET_FREQUENCY_RESOLUTION : real := 0.05; -- Hz    
    constant SAMPLE_RATE: natural := 48000; --Hz

    constant SAMPLE_RATE_BITS: natural := natural(ceil(log(real(SAMPLE_RATE))/log(2.0)));
    constant MAX_FREQUENCY : natural := SAMPLE_RATE/2;   
     
    constant PHASE_SPACE_SIZE: natural := natural(real(SAMPLE_RATE)/TARGET_FREQUENCY_RESOLUTION);
   
    constant POWER2_PHASE_SPACE_BITS: natural := natural(ceil(log(real(PHASE_SPACE_SIZE))/log(2.0)));
    constant POWER2_PHASE_SPACE_SIZE: natural := 2 ** POWER2_PHASE_SPACE_BITS;
    
    -- at 0.5 FS  POWER2_PHASE_SPACE_BITS-1 is the maximum step
    constant MAX_POWER2_PHASE_STEP_BITS : natural := POWER2_PHASE_SPACE_BITS-1;
    
    subtype phase_t is unsigned(POWER2_PHASE_SPACE_BITS-1 downto 0);
    subtype phase_step_decimal_t is unsigned(MAX_POWER2_PHASE_STEP_BITS-1 downto 0);
    subtype phase_step_fraction_t is unsigned(SAMPLE_RATE_BITS-1 downto 0);
    subtype phase_fraction_t is unsigned(SAMPLE_RATE_BITS+1 downto 0);
    
    type phase_step_t is record 
        decimal : phase_step_decimal_t;
        fraction : phase_step_fraction_t; -- the fraction is not a decimal fraction, it is divided by sample_rate
    end record;
    
    type phase_state_t is record
        step : phase_step_t;
        -- the decimal part, added each step
        current: phase_t; 
        -- the fractional part, if it overflows (above sample_rate)
        -- then the it is reset and 'current' is increased by one
        current_fraction: phase_fraction_t; 
        
    end record; 
    
    --constant to set step and state to zero
    constant ZERO_PHASE_STEP: phase_step_t := (decimal => (others => '0'), fraction => (others => '0'));
    constant ZERO_PHASE_STATE: phase_state_t := 
        (
            current => (others => '0'),
            current_fraction => (others => '0'),
            step => (
                        decimal => (others => '0'), 
                        fraction => (others => '0')
                        )
        );


    constant PHASE_STEP_FRACTION_DIVIDER : phase_step_fraction_t := to_unsigned(SAMPLE_RATE, phase_step_fraction_t'length);
     
    constant QUANTIZED_FREQUENCY_RESOLUTION : real :=  real(SAMPLE_RATE) / real(POWER2_PHASE_SPACE_SIZE);
    constant PHASE_STEP : real := 1.0 / QUANTIZED_FREQUENCY_RESOLUTION;
    constant PHASE_STEP_BITS : real := log2(PHASE_STEP);
        
    constant POWER2_PHASE_STEP_BITS1: natural :=  natural(floor(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES1 : real := 1.0 / real(POWER2_PHASE_STEP_BITS1);
    constant POWER2_PHASE_STEP_BITS2: natural :=  natural(ceil(log(PHASE_STEP)/log(2.0)));
    constant FREQ_RES2 : real := 1.0 / real(POWER2_PHASE_STEP_BITS2);
    constant POWER2_PHASE_STEP_BITS1_USABLE: boolean := FREQ_RES1 < TARGET_FREQUENCY_RESOLUTION;
    constant POWER2_PHASE_STEP_BITS : natural := sel(POWER2_PHASE_STEP_BITS1_USABLE, POWER2_PHASE_STEP_BITS1, POWER2_PHASE_STEP_BITS2);    
    constant POWER2_PHASE_STEP : natural := 2 ** POWER2_PHASE_STEP_BITS;
    
    -- max frequency = POWER2_PHASE_SPACE_SIZE/2
    constant FREQUENCY_SCALED_BITS : natural := SAMPLE_RATE_BITS -1 + POWER2_PHASE_STEP_BITS; 
    subtype frequency_t is unsigned(FREQUENCY_SCALED_BITS-1 downto 0);
    
    constant MAX_FREQUENCY_SCALED : natural := MAX_FREQUENCY * POWER2_PHASE_STEP;   
        
    constant MAX_QUANTISED_PHASE_STEP_ERROR : real := 1.0/real(MAX_FREQUENCY);
    constant MAX_QUANTISED_PHASE_STEP_ERROR_BITS : real := abs(log2(MAX_QUANTISED_PHASE_STEP_ERROR));
    
    constant SCALED_PHASE_STEP_BITS : natural := natural(ceil( PHASE_STEP_BITS + MAX_QUANTISED_PHASE_STEP_ERROR_BITS));
    
    constant PHASE_STEP_SCALING_FACTOR_BITS1 : natural := natural(floor ( MAX_QUANTISED_PHASE_STEP_ERROR_BITS ));
    constant PHASE_STEP_SCALING_FACTOR1: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS1 );
    constant SCALED_PHASE_STEP1 : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR1) * PHASE_STEP));
    constant PHASE_STEP_ERROR1: real := PHASE_STEP - real(SCALED_PHASE_STEP1) / real(PHASE_STEP_SCALING_FACTOR1);
    constant PHASE_STEP_MAX_ERROR1: real := real(MAX_FREQUENCY) * real(PHASE_STEP_ERROR1);

    constant PHASE_STEP_SCALING_FACTOR_BITS2 : natural := natural(ceil ( MAX_QUANTISED_PHASE_STEP_ERROR_BITS ));
    constant PHASE_STEP_SCALING_FACTOR2: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS2 );
    constant SCALED_PHASE_STEP2 : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR2) * PHASE_STEP));
    constant PHASE_STEP_ERROR2: real := PHASE_STEP - real(SCALED_PHASE_STEP2) / real(PHASE_STEP_SCALING_FACTOR2);
    constant PHASE_STEP_MAX_ERROR2: real := real(MAX_FREQUENCY) * real(PHASE_STEP_ERROR2);
                
    constant PHASE_STEP_SCALING_FACTOR_BITS1_USABLE: boolean := PHASE_STEP_MAX_ERROR1<1.0;
    constant PHASE_STEP_SCALING_FACTOR_BITS : natural := sel(PHASE_STEP_SCALING_FACTOR_BITS1_USABLE, PHASE_STEP_SCALING_FACTOR_BITS1, PHASE_STEP_SCALING_FACTOR_BITS2);    
    constant PHASE_STEP_SCALING_FACTOR: natural := 2 ** ( PHASE_STEP_SCALING_FACTOR_BITS );
    constant SCALED_PHASE_STEP : natural := natural( floor( real(PHASE_STEP_SCALING_FACTOR) * PHASE_STEP));
                                  
    constant DECIMAL_DIVIDER_BITS : natural := POWER2_PHASE_STEP_BITS + PHASE_STEP_SCALING_FACTOR_BITS;
    
    
    -- synthesis translate_off
    procedure Report_Constants(constant dummy: in integer);
    -- synthesis translate_on     
    

    --given a target frequency scaled by POWER2_PHASE_STEP the function calculates
    -- the required phase step at each sample
    procedure Calculate_Phase_Step(
        constant frequency_scaled: in frequency_t;          
        variable phase_step: out phase_step_t
    );

    --return a random value
    procedure Rand(variable rand_inout: inout unsigned(30 downto 0));
   
    --update phase according to the phase.step field.
    procedure Advance_Phase(
        variable phase: inout phase_state_t);
 
end;

package body sine_generator_types_pkg is 


    -- synthesis translate_off
    -- print all constants
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

    procedure Rand(variable rand_inout: inout unsigned(30 downto 0)) is
    begin
        rand_inout := resize((rand_inout * 16807) mod 2147483647,31);
    end;

    procedure Calculate_Phase_Step(
        constant frequency_scaled: in frequency_t;
        variable phase_step: out phase_step_t) is
        
        variable scaled_phase: unsigned(SCALED_PHASE_STEP_BITS + FREQUENCY_SCALED_BITS -1  downto 0);
                
        variable phase_step_numerator_incl_decimal: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
        variable decimal_scaled: unsigned(FREQUENCY_SCALED_BITS + POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS -1 downto 0);
   
        variable l: line;                                  
    begin
    
            write( l, string'("sc1_bits             = " ));                    
            write( l, scaled_phase'length);
            writeline( output, l );

            write( l, string'("decimal_bits             = " ));                    
            write( l, phase_step.decimal'length);
            writeline( output, l );

            write( l, string'("phase_step_numerator_incl_decimal_bits   = " ));                    
            write( l, phase_step_numerator_incl_decimal'length);
            writeline( output, l );

            write( l, string'("decimal_scaled_bits                      = " ));                    
            write( l, decimal_scaled'length);
            writeline( output, l );

            write( l, string'("fractional_bits                          = " ));                    
            write( l, phase_step.fraction'length);
            writeline( output, l );

            write( l, string'("frequency_scaled                         = " ));                    
            write( l, to_hstring(frequency_scaled)); 
            writeline( output, l );
        
            scaled_phase  := resize(frequency_scaled * SCALED_PHASE_STEP, scaled_phase'length);
    
            write( l, string'("sc1                                      = " ));                    
            write( l, to_hstring(scaled_phase));
            writeline( output, l );
                        
            phase_step.decimal := scaled_phase(DECIMAL_DIVIDER_BITS + phase_step.decimal'length -1 downto DECIMAL_DIVIDER_BITS);
            write( l, string'("decimal                                  = " ));                    
            write( l, to_hstring(phase_step.decimal));
            writeline( output, l );
   
            phase_step_numerator_incl_decimal := frequency_scaled & to_unsigned(0, POWER2_PHASE_SPACE_BITS - POWER2_PHASE_STEP_BITS);
            
            write( l, string'("phase_step_numerator_incl_decimal        = " ));                    
            write( l, to_hstring(phase_step_numerator_incl_decimal));
            writeline( output, l );
                        
            decimal_scaled := resize(phase_step.decimal * SAMPLE_RATE, decimal_scaled'length);
            write( l, string'("decimal_truncated                        = " ));                    
            write( l, to_hstring(decimal_scaled));
            writeline( output, l );
                        
            phase_step.fraction := resize(
                phase_step_numerator_incl_decimal(phase_step.fraction'length -1 downto 0) - decimal_scaled(phase_step.fraction'length -1 downto 0),
                phase_step.fraction'length);
            write( l, string'("fractional                               = " ));                    
            write( l, to_hstring(phase_step.fraction));
            writeline( output, l );
                        
            if (phase_step.fraction >= PHASE_STEP_FRACTION_DIVIDER) then
                phase_step.fraction := phase_step.fraction - PHASE_STEP_FRACTION_DIVIDER;
                phase_step.decimal := phase_step.decimal + to_unsigned(1,phase_step.decimal'length);

                write( l, string'("wrap" ));                    
                writeline( output, l );
                write( l, string'("decimal                                  = " ));                    
                write( l, to_hstring(phase_step.decimal));
                writeline( output, l );
                write( l, string'("fractional                               = " ));                    
                write( l, to_hstring(phase_step.fraction));
                writeline( output, l );

            end if;
            
    end Calculate_Phase_Step;
 
    procedure Advance_Phase(
        variable phase: inout phase_state_t) is
    begin
        phase.current_fraction := phase.current_fraction + phase.step.fraction;
        if phase.current_fraction >= SAMPLE_RATE then
            phase.current_fraction := phase.current_fraction - to_unsigned(SAMPLE_RATE, SAMPLE_RATE_BITS);
            phase.current := phase.current + phase.step.decimal + 1;
        else
            phase.current := phase.current + phase.step.decimal;
        end if;
    end Advance_Phase;
  
end;
