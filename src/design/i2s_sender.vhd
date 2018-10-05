--------------------------------------------------------------------------------
-- Engineer: D.W.J. Bosman
-- 
-- Create Date: 09/06/2018 11:49:12 PM
-- Module Name: i2s_sender - Behavioral
-- 
-- Additional Comments:
-- https://store.digilentinc.com/pmod-i2s2-stereo-audio-input-and-output/
-- https://statics.cirrus.com/pubs/proDatasheet/CS4344-45-48_F2.pdf
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types_pkg.all;

entity i2s_sender is
    --wave_x_in are sampled at the rising edge of MCLK
    generic (
        DEBUG : boolean := false
    );
    Port ( 
        resetn : in std_logic;
        MCLK_in : in std_logic;
        LRCK_out : out std_logic;
        SCLK_out : out std_logic;
        SDIN_out : out std_logic;
        wave_left_in : in sample_t;
        wave_right_in : in sample_t
    );
end i2s_sender;



architecture Behavioral of i2s_sender is
   --Change level every _DIV ticks of MCLK
    constant LRCK_DIV : integer := (MCLK_FREQ / (LRCK_FREQ*2)) -1; -- 384/2 -1 = 161
    constant SCLK_DIV : integer := (MCLK_FREQ / (SCLK_FREQ*2)) -1; 

    --types for various counters
    subtype div_LRCK_t  is integer range 0 to LRCK_DIV; 
    subtype div_SCLK_t  is integer range 0 to SCLK_DIV; 
    
    --count the number of MCLK ticks before toggling LRCK    
    signal LRCK_cnt : div_LRCK_t;
    --count the number of MCLK ticks before toggling SCLK
    signal SCLK_cnt : div_SCLK_t;
    
    --count the number of SCLK periods after LRCK went low
    signal SDIN_cnt : integer range 0 to (SAMPLE_WIDTH*2-1);
        
    --wave_x_in are sampled at the rising edge of MCLK
    signal wave_left : sample_t := (others => '0');
    signal wave_right: sample_t := (others => '0');  
          
    signal shift_reg: std_logic_vector(SAMPLE_WIDTH-1 downto 0);
               
   
    --set optional debugging signals
    attribute mark_debug of shift_reg : signal is boolean'image(DEBUG);
    attribute keep of shift_reg : signal is boolean'image(debug); 
           
    attribute mark_debug of SDIN_cnt : signal is boolean'image(DEBUG);
    attribute keep of SDIN_cnt : signal is boolean'image(DEBUG); 
begin

    
    -- synthesis translate_off
    debug_process : process is
    begin
        --print the dividers when in simulation mode
        report "MCLK_FREQ hz " & integer'image(MCLK_FREQ);
        report "LRCK_FREQ hz " & integer'image(LRCK_FREQ);
        report "SCLK_FREQ hz " & integer'image(SCLK_FREQ);
        report "SAMPLE_WIDTH " & integer'image(SAMPLE_WIDTH);

        report "LRCK_DIV" & integer'image(LRCK_DIV);
        report "SCLK_DIV" & integer'image(SCLK_DIV);
        wait;
    end process;
    -- synthesis translate_on
    
    -- a process to generate LRCK and SCLK from MCLK
    i2s_clk_process : process (MCLK_in, resetn) is 
    begin
        if resetn = '0' then               -- ASynchronous reset (active low)
            LRCK_out <= '0';
            SCLK_out <= '0';
            
            LRCK_cnt <= 0;
            SCLK_cnt <= 0;   
            SDIN_cnt <= 0;      
            wave_left <= (others => '0');
            wave_right <= (others => '0');
            shift_reg <= (others => '0');

        elsif MCLK_in'event and MCLK_in = '1' then     -- Rising clock edge
            -- MCLK == 18.4320 Mhz
            -- LRCK = MCLK / 384 = 48khz = Fs
            -- SCLK = 48 * Fs = MCLK/8
            if LRCK_cnt = LRCK_DIV then
                LRCK_cnt <=0;
                if LRCK_out = '1' then
                    --falling edge
                    --assert: SCLK will go low
                    LRCK_out <= '0';
                    SDIN_cnt <= 0;
                else
                    -- rising edge
                    --assert: SCLK will go low
                    LRCK_out <= '1';
                    SDIN_cnt <= SAMPLE_WIDTH;
                end if;
            else
                if (SCLK_cnt = SCLK_DIV) and (SCLK_out='1') then
                    --SCLK will go low
                    SDIN_cnt <= SDIN_cnt + 1;
                    --SDIN_cnt is still the current bit in the LRCK left-righ frame
                    --before the update        
                    if SDIN_cnt = 0 then
                        -- load shift register for output
                        shift_reg <= std_logic_vector(wave_left); 
                    elsif SDIN_cnt = 24 then
                        -- load shift register for output
                        shift_reg <= std_logic_vector(wave_right);
                    else 
                        --shift one bit to the right
                        shift_reg <= shift_reg(shift_reg'HIGH-1 downto 0) & '0';
                    end if;


                end if;                            
                LRCK_cnt <= LRCK_cnt + 1;  
            end if;
            
            if SCLK_cnt = SCLK_DIV then
                SCLK_cnt <=0;
                SCLK_out <= not SCLK_out;
            else
                SCLK_cnt <= SCLK_cnt + 1;  
            end if;
            
            --sample data
            wave_left <= wave_left_in;
            wave_right <= wave_right_in;
        end if;
    end process;

    SDIN_out <= shift_reg(shift_reg'HIGH);

end Behavioral;
