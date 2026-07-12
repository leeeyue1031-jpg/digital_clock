library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_cnt is
    generic(
        max : natural := 9
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        en    : in std_logic;
        q     : out integer range 0 to 9;
        cout  : out std_logic
    );
end bcd_cnt;

architecture behavior of bcd_cnt is
    signal cnt : integer range 0 to 9 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cnt <= 0;
            elsif en = '1' then
                if cnt < max then
                    cnt <= cnt + 1;
                else
                    cnt <= 0;
                end if;
            end if;
        end if;
    end process;

    q <= cnt;
    cout <= '1' when cnt = max else '0';

end behavior;