--------------------------------------------------------------------------------
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 09/06/2018 11:49:12 PM
-- Module Name: square_wave - Behavioral
-- 
-- Additional Comments:
-- utility component which generates a square wave. Used for testing other components
-- note: frequency is not accurate.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;
use ieee.math_real.all;

entity square_wave is
    Port ( resetn : std_logic;
           MCLK_in : in std_logic;
           wave_left_out : out sample_t;
           wave_right_out : out sample_t 
           );

   -- Approximate frequencies of left and right test audio signals
   constant WAVE_LEFT_FREQ : integer := 440;
   constant WAVE_RIGHT_FREQ : integer := 880; 
   --Change square wave phase every _DIV ticks of SCLK
   constant WAVE_LEFT_DIV : integer := (MCLK_FREQ / (WAVE_LEFT_FREQ*2)) -1;
   constant WAVE_RIGHT_DIV : integer := (MCLK_FREQ / (WAVE_RIGHT_FREQ*2)) -1;

   --required number of bits for the dividers
   constant WAVE_LEFT_DIV_BITS : natural := integer(ceil(log2(real(WAVE_LEFT_DIV))));
   constant WAVE_RIGHT_DIV_BITS : natural := integer(ceil(log2(real(WAVE_RIGHT_DIV))));
   
   -- amplitude is max amplitude/8
   constant MAX_WAVE : sample_t := to_signed(2**(SAMPLE_WIDTH-3), SAMPLE_WIDTH)+1; 

end square_wave;

architecture Behavioral of square_wave is
    subtype div_wave_left_t  is unsigned(WAVE_LEFT_DIV_BITS-1 downto 0);
    subtype div_wave_right_t  is unsigned(WAVE_RIGHT_DIV_BITS-1 downto 0);
        
    signal wave_left_cnt : div_wave_left_t;
    signal wave_right_cnt : div_wave_right_t;
    signal dummy: std_logic;
begin
    testseq2 : process (dummy) is
    begin
        --print the dividers once
        report "WAVE_LEFT_DIV " & integer'image(WAVE_LEFT_DIV);
        report "WAVE_RIGHT_DIV " & integer'image(WAVE_RIGHT_DIV);
        report "WAVE_LEFT_DIV_BITS " & integer'image(WAVE_LEFT_DIV_BITS);
        report "WAVE_RIGHT_DIV_BITS " & integer'image(WAVE_RIGHT_DIV_BITS);

    end process;
    
    -- a process to generate the audio waveform
    waveform_process : process (MCLK_in, resetn) is --runs at Fs
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            wave_left_cnt <= (others => '0');
            wave_right_cnt <= (others => '0');
            
            wave_left_out <= MAX_WAVE;
            wave_right_out <= -MAX_WAVE;
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
