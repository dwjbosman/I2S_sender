--------------------------------------------------------------------------------
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 09/06/2018 11:49:12 PM
-- Module Name: sine_wave - Behavioral
-- 
-- Additional Comments:
-- blog post:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
use work.i2s_types_pkg.all;
use work.sine_generator_types_pkg.all;

entity sine_wave is
    Port ( resetn : std_logic;
           MCLK_in : in std_logic; -- Master clock of the I2S Sender
           sample_clk_in : in std_logic; -- the sample clock (eg. 48kHz)
           
           freq_in_ce: in std_logic; -- if '1' freq_in will be sampled on next rising edge
           freq_in: in frequency_t; -- the scaled frequency (POWER2_PHASE_STEP) of the sine
                 
           wave_out : out sample_t -- the generated output samples
           
           );
end sine_wave;

architecture Behavioral of sine_wave is
    
    signal sin_clk_en : std_logic;
    signal dummy_cos : sample_t;

    signal phase : phase_state_t;
    signal phase_step: phase_step_t;
begin
    
    -- Note: with taylor_order => 1 there is a sign overflow 
    -- TODO determine required addrbits, extrabits....
    gen0: entity work.sincos_gen
        generic map (
            data_bits       => sample_t'length,
            phase_bits      => POWER2_PHASE_SPACE_BITS,
            phase_extrabits => 2,
            table_addrbits  => 10,
            taylor_order    => 2 )
        port map (
            clk             => MCLK_in,
            clk_en          => sin_clk_en,
            in_phase        => phase.current,
            out_sin         => wave_out,
            out_cos         => dummy_cos );

    --a process that updates the phase_step when a new frequency is set
    freq_process : process (MCLK_in, resetn) is 
        variable phase_step_internal :  phase_step_t;   
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            phase_step_internal := ZERO_PHASE_STEP;
        elsif (MCLK_in'event) and (MCLK_in = '1') then     
            if freq_in_ce = '1' then
                -- update phase_step_internal based on the new freq_in value
                Calculate_Phase_Step(freq_in,phase_step_internal);
            end if;
        end if;
        --assign to a signal so we can use it outside the process and debug
        phase_step <= phase_step_internal;
    end process;

    -- a process to generate the audio waveform
    waveform_process : process (sample_clk_in, resetn) is --runs at Fs
        variable internal_phase: phase_state_t;
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            internal_phase := ZERO_PHASE_STATE;
            sin_clk_en <= '0';           
        elsif (sample_clk_in'event) and (sample_clk_in = '1') then     
            sin_clk_en <= '1';
            internal_phase.step := phase_step;
            Advance_Phase(internal_phase);                                 
        end if;
        --assign to signal so we can use it outside the process
        phase <= internal_phase;
    end process;
end Behavioral;
