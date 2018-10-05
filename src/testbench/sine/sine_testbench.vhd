----------------------------------------------------------------------------------
-- Company: TFG
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 06/19/2018 12:07:00 AM
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--  Test bench for Advance_Phase and Calculate_Phase_Step functions
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
    
-- Test the Avnce_Phase function
--
-- Run a number of iterations, each iteration increase the phase
-- the phase calculated by the Advance_Phase function is compared
-- to a direct calculation using float-ing pojnt.
procedure Run_Phase_Steps ( 
    variable step: in phase_step_t; 
    variable phase_step_real: in real
    ) is 
    variable phase_state : phase_state_t; 
    variable expected_phase: real;
    variable diff_phase: real;
    variable calculated_phase: real;
    variable l: line;
    variable periods: real;
begin

    phase_state := ZERO_PHASE_STATE;
    phase_state.step := step;
    
    write( l, string'("Step iterations"));                        
    writeline( output, l );
                                                
    for step_iteration in 1 to 2**6 -1 loop
        write( l, string'("step="));                        
        write( l, step_iteration);
        writeline( output, l );
                            
        Advance_Phase(phase_state);
        
        -- calculate the number of periods (2*pi == POWER2_PHASE_SPACE_SIZE)
        periods := (phase_step_real * step_iteration) / POWER2_PHASE_SPACE_SIZE;
        -- calculate the expected phase value after a step, subtract the number of periods
        -- to perform get the modulus POWER2_PHASE_SPACE_SIZE value.
        expected_phase := (phase_step_real * step_iteration) - floor(periods) * POWER2_PHASE_SPACE_SIZE;
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
    end loop;

end;
          
begin
    Report_Constants(0);

    resetn <= '0', '1' after 100ns;
    clock <= not clock after 10 ns;
    
    
    tst_process : process is 
        variable freq_in: frequency_t := to_unsigned(440*32+1, FREQUENCY_SCALED_BITS);
        variable freq_real: real;
        variable step: phase_step_t;
        
        variable l: line;
        
        variable phase_step_real: real;
        variable dec_step_real: real;
        variable fract_step_real: real;
        variable diff_dec: real;
        variable diff_fract: real;
        variable rnd: unsigned(30 downto 0) := to_unsigned(12, 31);
           
        
        begin
            wait for 100ns;
            
            step := ZERO_PHASE_STEP;
            
            -- perform the test a number of iterations
            -- each iteration:
            --  choose a random scaled frequency value
            --  calculate the phase step (decimal, fraction) using the Calculate_Phase_Step function 
            --  calculate the phase step using floating point
            --  compare the results  
            for iteration in 1 to 2**6 -1 loop --frequency_t'length-1  loop
                
                Rand(rnd);
                
                --freq_in := to_unsigned(freq_scaled, FREQUENCY_SCALED_BITS);
                freq_in := rnd(rnd'left downto rnd'left-frequency_t'length + 1);
                
                if (freq_in >= to_unsigned(MAX_FREQUENCY_SCALED,frequency_t'length)) then
                    freq_in := to_unsigned(MAX_FREQUENCY_SCALED-1,frequency_t'length);
                end if;
                
                freq_real := real(to_integer(freq_in)) / POWER2_PHASE_STEP;
                
                phase_step_real := (real(POWER2_PHASE_SPACE_SIZE) / SAMPLE_RATE) * ( real(to_integer(freq_in)) / POWER2_PHASE_STEP);
                dec_step_real := floor(phase_step_real);
                fract_step_real :=  (phase_step_real - dec_step_real) * SAMPLE_RATE;
                write( l, string'("truth: f(Hz)="));        
                write( l, freq_real);
                writeline( output, l );
               
                write( l, string'("  f_sc="));                        
                write( l, to_integer(freq_in));
                                                                 
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
                write( l, to_integer(step.decimal));
                write( l, string'("  f="));        
                write( l, to_integer(step.fraction));
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
                    Run_Phase_Steps (step, phase_step_real);
                
                end if;
                                
                wait for 10ns;  
            end loop;
            
            
            
            
            wait;
        end process;
    

end Behavioral;
