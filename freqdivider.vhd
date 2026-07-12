library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freqdivider is
    generic(
        freq_in  : integer := 50000000;
        freq_out : integer := 1
    );

    port(
        clk_in  : in std_logic;
        clk_out : out std_logic
    );

end entity;

architecture behave of freqdivider is

    constant div_range : integer := freq_in / freq_out;

    signal cnt : integer range 0 to div_range-1 := 0;

begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then

            if cnt = div_range-1 then
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;

            if cnt > div_range/2 then
                clk_out <= '1';
            else
                clk_out <= '0';
            end if;

        end if;
    end process;

end behave;