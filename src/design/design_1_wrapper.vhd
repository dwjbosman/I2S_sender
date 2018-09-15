--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
--Date        : Mon Jun 18 22:38:55 2018
--Host        : dinne-Aspire-VN7-593G running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



use work.types_pkg.all;

entity design_1_wrapper is
  port (
    -- clk_out : out STD_LOGIC;
    -- locked_reset : out STD_LOGIC;
    CPU_RESETN : in STD_LOGIC;
    CLK100MHZ : in STD_LOGIC;
    LED: out STD_LOGIC_VECTOR(15 downto 0);
    
    SW: in std_logic_vector(15 downto 0);
    
    -- for i2s pmod
    MCLK_out: out STD_LOGIC;
    SCLK_out: out STD_LOGIC;
    SDIN_out: out STD_LOGIC;
    LRCK_out: out STD_LOGIC    
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    sys_clock : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk_out : out STD_LOGIC;
    MCLK_gen_out : out STD_LOGIC;
    locked_reset : out STD_LOGIC        
    
  );
  end component design_1;
  
    signal counter_clk: STD_LOGIC;
    signal n_reset: STD_LOGIC;
      
    
    
    signal wave_left: sample_t := (others=> '0');
    signal wave_right: sample_t := (others=> '0');
        
    
    signal wave_left_sq: sample_t := (others=> '0');
    signal wave_right_sq: sample_t := (others=> '0');
    
    signal wave_left_sine: sample_t := (others=> '0');
    signal wave_right_sine: sample_t := (others=> '0');
        
    
    signal MCLK_tmp : std_logic := '0';
     

    signal shift_reg: std_logic_vector(23 downto 0) := (others=> '0');
          

begin

  design_1_i: component design_1
     port map (
      clk_out => counter_clk,
      MCLK_gen_out => MCLK_tmp,
      locked_reset => n_reset,
      reset => CPU_RESETN,
      sys_clock => CLK100MHZ
    );
    

    sqwv : entity work.square_wave
        port map (
            resetn => n_reset,
            MCLK_in => MCLK_tmp,
            wave_left_out => wave_left_sq,
            wave_right_out => wave_right_sq
            );

    /**
    snwv : entity work.sine_wave
        port map (
            resetn => n_reset,
            MCLK_in => MCLK_tmp,
            wave_left_out => wave_left_sine,
            wave_right_out => wave_right_sine
            );
    **/ 
    wave_left <= (wave_left_sq and SW(0));
    wave_right <= (wave_right_sq and SW(0));
        
    -- wave_left <= (wave_left_sq and SW(0)) + (wave_left_sine and SW(1));
    -- wave_right <= (wave_right_sq and SW(0)) + (wave_right_sine and SW(1));
                
 
    i2s : entity work.i2s_sender
        port map (
            resetn => n_reset,
            MCLK_in => MCLK_tmp,
            SCLK_out => SCLK_out,
            LRCK_out => LRCK_out,
            SDIN_out => SDIN_out,
            wave_left_in => wave_left,
            wave_right_in => wave_right
        );
            
    /**
    led_process : process (MCLK_tmp) is 
        variable cnt : unsigned(23 downto 0);
        begin
                if n_reset = '0' then               -- ASynchronous reset (active low)
                    cnt:= (others => '0');    
                elsif MCLK_out'event and MCLK_out = '1' then     -- Rising clock edge
                    cnt := cnt + 1;
                end if;
                LED(15 downto 0) <= std_logic_vector(cnt(23 downto (23-15)));
        end process;
       **/ 
    MCLK_out <= MCLK_tmp;
    blaat: block
--        alias some_cnt is <<signal sqwv.wave_left_cnt : integer>>;  
     
    begin
    led_process : process (MCLK_tmp, n_reset) is 
        variable old: std_logic;
        variable cnt : unsigned(15 downto 0);
        begin
                if n_reset = '0' then               -- ASynchronous reset (active low)
                    cnt:= (others => '0');
                    old:= '0';
                elsif MCLK_tmp'event and MCLK_tmp = '1' then     -- Rising clock edge
                                
                    if old = SDIN_out then     -- Rising clock edge
                    else
                        old := SDIN_out;
                        cnt := cnt + 1;
                    end if;
                end if;
                LED(15 downto 0) <= std_logic_vector(cnt(15 downto (15-15)));
        end process;
    end block;
    


end STRUCTURE;

--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
--Date        : Sun Jul 22 22:19:38 2018
--Host        : dinne-Aspire-VN7-593G running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------



