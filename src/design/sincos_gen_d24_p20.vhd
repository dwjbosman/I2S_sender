--
--  Wrapper for sine / cosine function core
--
--  Copyright 2016 Joris van Rantwijk
--
--  This design is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--
--  Phase input:
--    unsigned 20 bits (2**20 steps for a full circle)
--
--  Sin/cos output:
--    signed 18 bits (nominal amplitude = 2**17-1)
--
--  Latency:
--    6 clock cycles
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sincos_gen_d24_p20 is

    port (
        -- System clock, active on rising edge.
        clk:        in  std_logic;

        -- Clock enable.
        clk_en:     in  std_logic;

        -- Phase input.
        in_phase:   in  unsigned(19 downto 0);

        -- Sine output.
        -- (6 clock cycles latency after in_phase).
        out_sin:    out signed(17 downto 0);

        -- Cosine output.
        -- (6 clock cycles latency after in_phase).
        out_cos:    out signed(17 downto 0) );

end entity;

architecture rtl of sincos_gen_d24_p20 is

begin

    gen0: entity work.sincos_gen
        generic map (
            data_bits       => 24,
            phase_bits      => 20,
            phase_extrabits => 2,
            table_addrbits  => 10,
            taylor_order    => 1 )
        port map (
            clk             => clk,
            clk_en          => clk_en,
            in_phase        => in_phase,
            out_sin         => out_sin,
            out_cos         => out_cos );

end architecture;
