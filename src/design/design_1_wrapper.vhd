library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.types_pkg.all;
use work.sine_generator_types_pkg.all;

entity design_1_wrapper is
  generic(
    DEBUG: boolean := false
  );
  port (
    -- clk_out : out STD_LOGIC;
    -- locked_reset : out STD_LOGIC;
    CPU_RESETN : in STD_LOGIC;
    CLK100MHZ : in STD_LOGIC;
    LED: out STD_LOGIC_VECTOR(15 downto 0);
    
    SSEG_CA: out STD_LOGIC_VECTOR(7 downto 0);
    AN: out STD_LOGIC_VECTOR(7 downto 0);
    
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
          
    signal wave_sine: sample_t := (others=> '0');
    signal frequency_ce: std_logic;
    signal frequency: frequency_t;     
    
    signal MCLK_tmp : std_logic := '0';
     

    signal second_counter: unsigned(MCLK_BITS-1 downto 0) := (others=> '0');
          
          

    attribute mark_debug of MCLK_out : signal is boolean'image(DEBUG);
    attribute keep of MCLK_out : signal is boolean'image(DEBUG); 
   
    attribute mark_debug of LRCK_out : signal is boolean'image(DEBUG);
    attribute keep of LRCK_out : signal is boolean'image(DEBUG);

    attribute mark_debug of SCLK_out : signal is boolean'image(DEBUG); 
    attribute keep of SCLK_out : signal is boolean'image(DEBUG);

    attribute mark_debug of SDIN_out : signal is boolean'image(DEBUG); 
    attribute keep of SDIN_out : signal is boolean'image(DEBUG); 

    attribute mark_debug of wave_left : signal is boolean'image(DEBUG); 
    attribute keep of wave_left : signal is boolean'image(DEBUG); 
          
begin

  design_1_i: component design_1
     port map (
      
      clk_out => counter_clk,
      MCLK_gen_out => MCLK_tmp,
      locked_reset => n_reset,
      reset => not CPU_RESETN,
      sys_clock => CLK100MHZ
    );
    
    
    sqwv : entity work.square_wave
        port map (
            resetn => n_reset,
            MCLK_in => MCLK_tmp,
            wave_left_out => wave_left_sq,
            wave_right_out => wave_right_sq
            );

    
    snwv : entity work.sine_wave
        port map (
            resetn => n_reset,
            MCLK_in => MCLK_tmp,
            freq_in => frequency,
            freq_in_ce => frequency_ce,
            sample_clk_in => LRCK_out,
            wave_out => wave_sine
            );
    
     frequency_ce <= '1' when SW(0) or SW(1) or SW(2) else '0';
          
     -- press button 0 to get 440 hz
     -- press button 1 to get 880 hz
     -- button 2 -> sweep from 100 Hz to 100+4*255 Hz in one second  
     -- button 3, 4 turn on square wave
     frequency <= to_unsigned(440 * POWER2_PHASE_STEP, frequency'length) when SW(0) else
        to_unsigned(880 * POWER2_PHASE_STEP, frequency'length) when SW(1)  else
        to_unsigned(100* POWER2_PHASE_STEP, frequency'length) + 
            resize(
                to_unsigned( 4 * POWER2_PHASE_STEP, frequency'length) 
                * second_counter(second_counter'length -1 downto second_counter'length -1 -7), frequency'length
            )  when SW(2) else
        (others => '0');
     
    wave_left <= wave_sine when SW(3) else
        wave_left_sq when SW(4) else
        wave_right_sq when SW(5) else
        (others => '0');
    
    wave_right <= wave_left;    
        
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

    --LED(8) <= frequency_ce;   
    --LED(7 downto 0) <= std_logic_vector(second_counter(second_counter'length -1 downto second_counter'length -1 - 7)) when SW(2) else
    --    (others => '0');   
    --LED(15 downto 0) <= std_logic_vector(second_counter(second_counter'length -1 downto second_counter'length -1 - 15)); 
    --LED(15 downto 0) <= std_logic_vector(wave_sine(wave_sine'length-1 downto wave_sine'length-1-15)); 
             
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

 
    counter_process : process (MCLK_tmp, n_reset) is 
    begin
        if n_reset = '0' then -- ASynchronous reset (active low)
            second_counter <= (others=>'0');
        elsif (MCLK_tmp'event) and (MCLK_tmp = '1') then     
            second_counter <= second_counter + 1;
        end if;
    end process;
    
    -- turn all led segments off for now
    SSEG_CA <= (others => '0');
    AN <= (others => '1');

end STRUCTURE;
