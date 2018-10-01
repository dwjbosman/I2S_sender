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
use ieee.math_real.all;
use work.types_pkg.all;
use work.sine_generator_types_pkg.all;

entity segment_display is
    Port ( resetn : std_logic;
           CLK_in : in std_logic; 
           value_in : in unsigned(31 downto 0); -- the scaled frequency of the sine
           );
end;



architecture Behavioral of segment_display is
    signal AN : std_logic_vector(7 downto 0);
    signal SSEG_CA : std_logic_vector(7 downto 0);

    type BCD_t : is unsigned(3 downto 0);
    constant BCD_ZERO : BCD_t := (others=>'0');

    signal BCD : array (7 downto 0) of BCD_t;
begin

            bcd_converter: process (CLK_in, resetn) is
                variable bit_counter: integer range 0 to 31;
                variable decimal_counter: integer range 0 to 7;    
                variable BCD_build : array (7 downto 0) of BCD_t;
                variable BCD_current : BCD_t;
                variable value_build : unsigned(31 downto 0);

                variable state: BCD_builder_it; 
            begin

                if resetn = '0' then -- ASynchronous reset (active low)
                    bit_counter := 0;
                    decimal_counter :=0;
                    shift_counter := 0;
                    BCD_build := (others => BCD_ZERO);
                    value_build := (others => '0');
                    state := START;
                elsif (CLK_in'event) and (CLK_in = '1') then     
                    
                    if state = START then
                        BCD <= BCD_build;
                        value_build := value_in;
                        BCD_build := (others => BCD_ZERO);
                        bit_counter :=0;
                        decimal_counter :=0;
                        state := DECIMALS
                    elsif state = DECIMALS then
                        BCD_current := BCD_build(decimal_counter);
                        if (BCD_current>=5 then
                            BCD_current := BCD_current + 3;
                            BCD_build(decimal_counter) := BCD_current;
                        end if;
                        if decimal_counter = 7 then
                            state := SHIFT;
                            shift_counter := 7;
                        else
                            decimal_counter := decimal_counter + 1;
                        end if;
                    elsif state = SHIFT then
                         
                       https://pubweb.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html 
                    end if


                end if;
            end process;


    
            digit_process: process (CLK_in, resetn) is

                -- led_id:  first 3 bits point the segment
                --          next 3 bits point to the led in the segment
                variable led_id : unsigned(5 downto 0); 
                variable segment_index  : integer range 0 to 7;
                variable led_in_segment : integer range 0 to 7;
            begin
                if resetn = '0' then -- ASynchronous reset (active low)
                    led_id <= (others => '0');
                    AN <= (others => '0');
                    SSEG_CA <= (others => '0');
                   
                elsif (CLK_in'event) and (CLK_in = '1') then     
                    led_id := led_id + 1;

                    segment_index := to_integer(led_id(5 downto 3));
                    led_in_segment := to_integer(led_id and 7);
                
                    segment_value := BCD(segment_index);
                    led_representation = value_to_led_representation(segment_value);

                    AN <= (segment_index => '1', others=>'0');
                    SSEG_CS <= (led_in_segment = led_representation(led_in_segment), others => '0');
                end if;
             end process;

end Behavioral;
