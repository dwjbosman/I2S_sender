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
           freq_in: in frequency_t;
           wave_out : out sample_t
           );

    CONSTANT MAX_WAVE : sample_t := to_signed(2**(SAMPLE_WIDTH-3), SAMPLE_WIDTH)+1; 

end square_wave;

architecture Behavioral of sine_wave is
    constant SAMPLE_CLK_DIVIDER : integer := MCLK_FREQ / LRCK_FREQ;
    subtype sample_div_clk_t  is integer range (0 to SAMPLE_CLK_DIVIDER);
    --subtype div_wave_right_t  is unsigned(WAVE_RIGHT_BITS-1 downto 0);
    signal sample_div_clk_cnt : div_clk_t :=0; 
    signal sample_clk : std_logic;
  
    signal sin_clk_en : std_logic;
    signal sin_phase: phase_t;
    signal dummy_cos : sample_t;
begin
    -- assert LRCK_FREQ == SAMPLE_RATE
    gen0: entity work.sincos_gen
        generic map (
            data_bits       => sample_t'length,
            phase_bits      => POWER2_PHASE_SPACE_BITS,
            phase_extrabits => 2,
            table_addrbits  => 10,
            taylor_order    => 1 )
        port map (
            clk             => clk,
            clk_en          => sin_clk_en,
            in_phase        => sin_phase,
            out_sin         => wave_out,
            out_cos         => dummy_cos );



    testseq2 : process (dummy) is
    begin
        --print the dividers once
        report "WAVE_LEFT_DIV " & integer'image(WAVE_LEFT_DIV);
        report "WAVE_RIGHT_DIV " & integer'image(WAVE_RIGHT_DIV);
        report "WAVE_LEFT_BITS " & integer'image(WAVE_LEFT_BITS);
        report "WAVE_RIGHT_BITS " & integer'image(WAVE_RIGHT_BITS);

    end process;

    sample_clock: process (MCLK_in, resetn) is
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            div_cnt <= 0;
        elsif (MCLK_in'event) and (MCLK_in = '1') then     
            if div_cnt = (SAMPLE_CLK_DIVIDER-1) then
                sample_clk <= not sample_clk;
                div_cnt <= 0;
            else
                div_cnt <= div_cnt + 1;
            end if;
        end if;
     end;

    freq_process : process (MCLK_in, freq_in, resetn) is --runs at Fs
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
        elsif (MCLK_in'event) and (MCLK_in = '1') then     
        end if
    end
    
    -- a process to generate the audio waveform
    waveform_process : process (MCLK_in, resetn) is --runs at Fs
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            div_cnt <= 0;            
                                      
        elsif (MCLK_in'event) and (MCLK_in = '1') then     
            
            if wave_left_cnt = WAVE_LEFT_DIV then
                wave_left_cnt <= (others => '0');
                wave_left_out <= -wave_left_out;
            else
                wave_left_cnt <= wave_left_cnt +1;
            end if;                    
            
            if wave_right_cnt = WAVE_RIGHT_DIV then
                wave_right_cnt <= (others => '0');
                wave_right_out <= -wave_right_out;
            else
                wave_right_cnt <= wave_right_cnt +1;
            end if;                    
        end if;
    end process;

end Behavioral;
