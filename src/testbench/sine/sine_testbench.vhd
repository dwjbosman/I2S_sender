----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2018 12:07:00 AM
-- Design Name: 
-- Module Name: testbench - Behavioral
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

use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use work.types_pkg.all;
use work.sine_generator_types_pkg.all;
use STD.textio.all;
use ieee.math_real.all;

entity sine_testbench is
--  Port ( );
end sine_testbench ;

architecture Behavioral of sine_testbench  is
    signal clock: std_logic := '0';
    signal resetn: std_logic := '0';
    

                  
begin
    Report_Constants(0);

    resetn <= '0', '1' after 100ns;
    clock <= not clock after 10 ns;
    
    
    tst_process : process is 
        variable freq_in: frequency_t := to_unsigned(440*32+1, FREQUENCY_SCALED_BITS);
        
        variable step: phase_step_t;
        
        --variable dec_out: phase_step_decimal_t := (others => '0');
        --variable fract_out: phase_step_fraction_t := (others => '0');
        variable l: line;
        
        variable phase_step_real: real;
        variable dec_step_real: real;
        variable fract_step_real: real;
        variable diff_dec: real;
        variable diff_fract: real;
        variable rnd: unsigned(30 downto 0) := to_unsigned(12, 31);
        
       
        variable phase_state : phase_state_t; 
        variable expected_phase: real;
        variable diff_phase: real;
        
        begin
            wait for 100ns;
            
            step := ZERO_PHASE_STEP;
            
            for iteration in 1 to 2**6 -1 loop --frequency_t'length-1  loop
                
                Rand(rnd);
                
                --freq_in := to_unsigned(freq_scaled, FREQUENCY_SCALED_BITS);
                freq_in := rnd(rnd'left downto rnd'left-frequency_t'length + 1);
                
                if (freq_in >= to_unsigned(MAX_FREQUENCY_SCALED,frequency_t'length)) then
                    freq_in := to_unsigned(MAX_FREQUENCY_SCALED-1,frequency_t'length);
                end if;
                
                phase_step_real := (real(POWER2_PHASE_SPACE_SIZE) / SAMPLE_RATE) * ( real(to_integer(freq_in)) / POWER2_PHASE_STEP);
                dec_step_real := floor(phase_step_real);
                fract_step_real :=  (phase_step_real - dec_step_real) * SAMPLE_RATE;
                
                write( l, string'("trueth: f="));        
                write( l, to_integer(freq_in));
                writeline( output, l );
                                                
                Calculate_Phase_Step(freq_in,step);
                 
                diff_dec:= dec_step_real - real(to_integer(step.decimal));
                diff_fract:= fract_step_real - real(to_integer(step.fraction));
                            
                 
                write( l, string'("  p="));                        
                write( l, phase_step_real);
                write( l, string'("  d="));        
                write( l, dec_step_real);
                write( l, string'("  f="));
                write( l, fract_step_real);
                write( l, string'("  actual: d="));
                write( l, to_integer(dec_out));
                write( l, string'("  f="));        
                write( l, to_integer(fract_out));
                write( l, string'("  dd="));        
                write( l, diff_dec);
                write( l, string'("  df="));        
                write( l, diff_fract);
                write( l, string'("  "));     
                
                if (abs(diff_dec)>0.1) then
                    write( l, string'("dec error "));                     
                end if;
                if (abs(diff_fract)>0.1) then
                    write( l, string'("fract error "));                     
                end if;
                                                   
                writeline( output, l );
                writeline( output, l );
                            
                if iteration = 2**6-1 then
                
                    phase_state := ZERO_PHASE_STATE;
                    phase_state.step := step;
                
                    write( l, string'("Step iterations"));                        
                    writeline( output, l );
                                                                
                    for step_iteration in 1 to 2**6 -1 loop   loop
                        write( l, string'("step="));                        
                        write( l, step_iteration);
                        writeline( output, l );
                                            
                        Advance_Phase(phase_state);
                        
                        expected_phase := phase_step_real * step_iteration;
                        calculated_phase := real(to_integer(phase_state.current)) + real(to_integer(phase_state.current_fraction))/SAMPLE_RATE;
                        diff_phase := expected_phase - calculated_phase;
                                        
                        write( l, string'("expected phase="));                        
                        write( l, expected_phase);
                        write( l, string'("  calculated phase="));                        
                        write( l, calculated_phase);
                        write( l, string'("  diff="));                        
                        write( l, diff_phase);
                        if (abs(diff_phase)>0.1) then
                            write( l, string'("  phase error "));                     
                        end if;
                        writeline( output, l );
                    end for;
                end if;
                                
                wait for 10ns;  
            end loop;
            
            
            
            
            wait;
        end process;
    

end Behavioral;
