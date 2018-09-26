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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use work.types_pkg.all;
use work.sine_generator_types_pkg.all;
use STD.textio.all;


entity sine_testbench is
--  Port ( );
end sine_testbench ;

architecture Behavioral of sine_testbench  is
    signal clock: std_logic := '0';
    signal resetn: std_logic := '0';
    

                  
begin
    Report_Constants(0);

    resetn <= '0', '1' after 100ns;
    clock <= not clock after 10 ns;
    
    
    tst_process : process (resetn) is 
        variable in1: frequency_t := to_unsigned(440*32+1, FREQUENCY_SCALED_BITS);
        variable out1: phase_step_t := (others => '0');
        variable out2: phase_step_fraction_t := (others => '0');
        variable l: line;
        begin
            Calculate_Phase_Step(in1,out1,out2);
            
            write( l, string'("in1             = " ));                    
            write( l, in1);
            writeline( output, l );
    
            write( l, string'("out1             = " ));                    
            write( l, out1);
            writeline( output, l );
    
            write( l, string'("out2             = " ));                    
            write( l, out2);
            writeline( output, l );
                        
        end process;
    

end Behavioral;
