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

entity wave_testbench is
--  Port ( );
end wave_testbench ;

architecture Behavioral of wave_testbench  is
    signal MCLK: std_logic := '0';
    signal resetn: std_logic := '0';
    
    signal freq : frequency_t;
    signal freq_ce: std_logic;
    signal wave: sample_t;
    
    /**
    
    signal iteration: unsigned(19 downto 0);
    signal monitor_sin : signed(23 downto 0);
    signal dummy_cos : signed(23 downto 0);
    **/
begin
    Report_Constants(0);

    resetn <= '0', '1' after 100ns;
    MCLK <= not MCLK after 27.1267361111 ns; -- 18.4320 Mhz

    /**
    -- test the sincos generator
    gen0: entity work.sincos_gen
        generic map (
            data_bits       => 24,
            phase_bits      => 20,
            phase_extrabits => 2,
            table_addrbits  => 10,
            taylor_order    => 2 )
        port map (
            clk             => MCLK,
            clk_en          => resetn,
            in_phase        => iteration,
            out_sin         => monitor_sin,
            out_cos         => dummy_cos );


    tst_process : process(MCLK,resetn) is 
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            iteration <= (others => '0');
        elsif (MCLK'event) and (MCLK = '1') then     
            --if div_cnt = 9 then
            --    div_cnt <= 0;
                iteration <= iteration + 1; --to_unsigned(1, iteration'length); --iteration + 1;
            --else
            --    div_cnt <= div_cnt + 1;
            --end if;
        end if;
    end process;
    **/


    wave_gen: entity work.sine_wave
        port map (
            resetn      => resetn,
            MCLK_in     => MCLK,
            freq_in     => freq,
            freq_in_ce        => freq_ce,
            wave_out         => wave);

    
    
    tst_process : process(MCLK,resetn) is 
        variable iteration: unsigned(63 downto 0);    
    begin
        if resetn = '0' then -- ASynchronous reset (active low)
            iteration := (others => '0');
        elsif (MCLK'event) and (MCLK = '1') then     
            iteration := iteration + 1;
        end if;

        if iteration=100 then
            freq_ce <= '1';
            -- at iteration 100 set the frequency to 440 Hz.
            freq <= to_unsigned(440 * POWER2_PHASE_STEP, freq'length);
        else
            freq_ce <= '0';
            freq <= (others => '0');       
        end if;
                      
     end process;

end Behavioral;
