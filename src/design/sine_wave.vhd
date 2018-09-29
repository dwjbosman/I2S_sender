----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/09/2018 08:04:08 PM
-- Design Name: 
-- Module Name: square_wave - Behavioral
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

use work.types_pkg.all;
use work.sine_generator_types_pkg.all;
use ieee.math_real.all;

entity sine_wave is
    Port ( resetn : std_logic;
           MCLK_in : in std_logic;
           
           freq_in_ce: in std_logic;
           freq_in: in frequency_t;

           wave_out : out sample_t
           );

    CONSTANT MAX_WAVE : sample_t := to_signed(2**(SAMPLE_WIDTH-3), SAMPLE_WIDTH)+1; 

end sine_wave;

architecture Behavioral of sine_wave is
    

  
    signal sin_clk_en : std_logic;
    signal dummy_cos : sample_t;


    signal phase : phase_state_t;
    signal phase_step: phase_step_t;
    signal sample_clk : std_logic;

begin
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



    sample_clk_process_scope: block 
        signal internal_sample_clk : std_logic;
        constant SAMPLE_CLK_DIVIDER : integer := MCLK_FREQ / (LRCK_FREQ*2)-1;
    
        subtype sample_div_clk_t  is integer range 0 to SAMPLE_CLK_DIVIDER;
        --subtype div_wave_right_t  is unsigned(WAVE_RIGHT_BITS-1 downto 0);
    begin
            sample_clk_process: process (MCLK_in, resetn) is
                variable sample_div_clk_cnt : sample_div_clk_t :=0; 
            begin
                if resetn = '0' then -- ASynchronous reset (active low)
                    internal_sample_clk <= '0';
                    sample_div_clk_cnt := 0;
                elsif (MCLK_in'event) and (MCLK_in = '1') then     
                    if sample_div_clk_cnt = SAMPLE_CLK_DIVIDER then
                        internal_sample_clk <= not internal_sample_clk;
                        sample_div_clk_cnt := 0;
                    else
                        sample_div_clk_cnt := sample_div_clk_cnt + 1;
                    end if;
                end if;
             end process;
             sample_clk <= internal_sample_clk;
     end block;

    freq_process_scope: block
    begin
            freq_process : process (MCLK_in, resetn) is 
                variable phase_step_internal :  phase_step_t;   
            begin
                if resetn = '0' then -- ASynchronous reset (active low)
                    phase_step_internal := ZERO_PHASE_STEP;
                elsif (MCLK_in'event) and (MCLK_in = '1') then     
                    if freq_in_ce = '1' then
                        Calculate_Phase_Step(freq_in,phase_step_internal);
                    end if;
                end if;
                phase_step <= phase_step_internal;
            end process;
    end block;
 
    waveform_process_scope: block
        
    begin
        -- a process to generate the audio waveform
        waveform_process : process (sample_clk, resetn) is --runs at Fs
            variable internal_phase: phase_state_t;
        begin
            if resetn = '0' then -- ASynchronous reset (active low)
                internal_phase := ZERO_PHASE_STATE;
                sin_clk_en <= '0';           
                
                internal_phase.current := to_unsigned(786432-100, internal_phase.current'length);
                                              
            elsif (sample_clk'event) and (sample_clk = '1') then     
                sin_clk_en <= '1';
                internal_phase.step := phase_step;
                Advance_Phase(internal_phase);
                                 
            end if;
            phase <= internal_phase;
        end process;
    end block;
end Behavioral;
