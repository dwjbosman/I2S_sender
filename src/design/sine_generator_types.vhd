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
use STD.textio.all;
--use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package sine_generator_types_pkg is    

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

    subtype frequency_t is unsigned(FREQUENCY_BITS-1 downto 0);
    
    
    
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
    
    -- synthesis translate_off
    procedure Report_Constants(constant dummy: in integer);
    -- synthesis translate_on     
end;

package body sine_generator_types_pkg is 

    -- synthesis translate_off
    procedure Report_Constants ( constant dummy: in integer) is 
        variable l: line;
    begin
            
        write( l, string'("FREQUENCY_RESOLUTION                 = " ));                    
        write( l, FREQUENCY_RESOLUTION);
        writeline( output, l );
                                    
        write( l, string'("FREQUENCY_RESOLUTION_BITS            = " ));
        write( l, FREQUENCY_RESOLUTION_BITS);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_SECOND_1HZ           = " ));
        write( l, PHASE_STEPS_PER_SECOND_1HZ);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_1HZ              = " ));
        write( l, PHASE_STEPS_PER_CLK_1HZ);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_SECOND_1HZ_minus     = " ));
        write( l, PHASE_STEPS_PER_SECOND_1HZ_minus);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_1HZ_minus        = " ));
        write( l, PHASE_STEPS_PER_CLK_1HZ_minus);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_DIFF             = " ));
        write( l, PHASE_STEPS_PER_CLK_DIFF);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_DIFF_FRACT       = " ));
        write( l, PHASE_STEPS_PER_CLK_DIFF_FRACT);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS  = " ));
        write( l, PHASE_STEPS_PER_CLK_DIFF_FRACT_BITS);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_FACTOR           = " ));
        write( l, PHASE_STEPS_PER_CLK_FACTOR);
        writeline( output, l );
        write( l, string'("PHASE_DIVIDER_BITS                   = " ));
        write( l, PHASE_DIVIDER_BITS);
        writeline( output, l );
        write( l, string'("PHASE_DIVIDER_i                      = " ));
        write( l, PHASE_DIVIDER_i);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_SECOND_BITS          = " ));
        write( l, PHASE_STEPS_PER_SECOND_BITS);
        writeline( output, l );
        write( l, string'("PHASE_STEPS_PER_CLK_BITS             = " ));
        write( l, PHASE_STEPS_PER_CLK_BITS);
        writeline( output, l );
        write( l, string'("SHIFT_FREQ_SPLIT_BITPOS              = " ));
        write( l, SHIFT_FREQ_SPLIT_BITPOS);
        writeline( output, l );
                          
        
    end Report_Constants ;
    -- synthesis translate_on     

    procedure Calculate_Phase_Step(
        frequency: in frequency_t;
        decimal: out frequency_t;
        fractional: out frequency_t) is 
        
    begin
        decimal := (FREQUENCY_BITS-1-SHIFT_FREQ_SPLIT_BITPOS downto 0 => frequency(FREQUENCY_BITS-1 downto SHIFT_FREQ_SPLIT_BITPOS), others => '0');
        fractional := (PHASE_DIVIDER_BITS-1 downto 0 => frequency(SHIFT_FREQ_SPLIT_BITPOS-1 downto SHIFT_FREQ_SPLIT_BITPOS-PHASE_DIVIDER_BITS-1), others => '0');
                
    
    end Calculate_Phase_Step;
        

end;
