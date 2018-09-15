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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.types_pkg.all;

use ieee.math_real.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity square_wave is
    Port ( resetn : std_logic;
           MCLK_in : in std_logic;
           wave_left_out : out sample_t;
           wave_right_out : out sample_t 
           );

   -- Approximate frequencies of left and right test audio signals
   CONSTANT WAVE_LEFT_FREQ : integer := 440;
   CONSTANT WAVE_RIGHT_FREQ : integer := 880; 
   --Change square wave phase every _DIV ticks of SCLK
   CONSTANT WAVE_LEFT_DIV : integer := (MCLK_FREQ / (WAVE_LEFT_FREQ*2)) -1;
   CONSTANT WAVE_RIGHT_DIV : integer := (MCLK_FREQ / (WAVE_RIGHT_FREQ*2)) -1;

   constant WAVE_LEFT_BITS : natural := integer(ceil(log2(real(WAVE_LEFT_DIV))));
   constant WAVE_RIGHT_BITS : natural := integer(ceil(log2(real(WAVE_RIGHT_DIV))));


    CONSTANT MAX_WAVE : sample_t := to_signed(2**(SAMPLE_WIDTH-3), SAMPLE_WIDTH)+1; 

end square_wave;

architecture Behavioral of square_wave is
    subtype div_wave_left_t  is unsigned(WAVE_LEFT_BITS-1 downto 0);
    subtype div_wave_right_t  is unsigned(WAVE_RIGHT_BITS-1 downto 0);
        
    signal wave_left_cnt : div_wave_left_t;
    signal wave_right_cnt : div_wave_right_t;
    signal dummy: std_logic;
begin
    testseq2 : process (dummy) is
    begin
        --print the dividers once
        report "WAVE_LEFT_DIV " & integer'image(WAVE_LEFT_DIV);
        report "WAVE_RIGHT_DIV " & integer'image(WAVE_RIGHT_DIV);
        report "WAVE_LEFT_BITS " & integer'image(WAVE_LEFT_BITS);
        report "WAVE_RIGHT_BITS " & integer'image(WAVE_RIGHT_BITS);

    end process;
    
    -- a process to generate the audio waveform
    waveform_process : process (MCLK_in, resetn) is --runs at Fs
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            wave_left_cnt <= (others => '0');
            wave_right_cnt <= (others => '0');
            
  
            -- initialize wave_left to MAX(sample_t)/2
            wave_left_out <= MAX_WAVE;
            wave_right_out <= -MAX_WAVE;
            --wave_left <= (wave_left'HIGH => '0', others => '1')/2;
            --wave_right <= (wave_right'LEFT => '0', others => '1');
                                      
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
