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

use work.i2s_types_pkg.all;

entity i2s_testbench is
--  Port ( );
end i2s_testbench ;

architecture Behavioral of i2s_testbench  is
    signal clock: std_logic := '0';
    signal resetn: std_logic := '0';
    
   
    signal MCLK: std_logic := '0';
    signal SCLK: std_logic := '0';
    signal SDIN: std_logic := '0';
    signal LRCK: std_logic := '0';
    signal wave_left: sample_t;
    signal wave_right: sample_t;
    
    signal shift_reg: std_logic_vector(23 downto 0);
    
                  
begin
   
    resetn <= '0', '1' after 100ns;
    clock <= not clock after 10 ns;
    MCLK <= not MCLK after 27.1267361111 ns; -- 18.4320 Mhz
    
    sqwv : entity work.square_wave
        port map (
         resetn => resetn,
         MCLK_in => MCLK,
         wave_left_out => wave_left,
         wave_right_out => wave_right
        );
             
    i2s : entity work.i2s_sender
            port map (
            MCLK_in => MCLK,
            resetn => resetn,
            LRCK_out => LRCK,
            SCLK_out => SCLK,
            SDIN_out => SDIN,
            wave_left_in => wave_left,
            wave_right_in => wave_right
            );    
end Behavioral;
