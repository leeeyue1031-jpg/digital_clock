library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_cnt60 is
    port(
        clk    : in std_logic;
        reset  : in std_logic;
        en     : in std_logic;
        bcd_h  : out integer range 0 to 9;
        bcd_l  : out integer range 0 to 9;
        cout   : out std_logic
    );
end bcd_cnt60;

architecture structural of bcd_cnt60 is

    component bcd_cnt is
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
    end component;

    signal cnt_h     : integer range 0 to 9 := 0;
    signal cnt_l     : integer range 0 to 9 := 0;
    signal carry_l   : std_logic := '0';
    signal reset_max : std_logic := '0';

begin

    bcd_low : bcd_cnt
        generic map(max => 9)
        port map(
            clk   => clk,
            reset => reset or reset_max,
            en    => en,
            q     => cnt_l,
            cout  => carry_l
        );

    bcd_high : bcd_cnt
        generic map(max => 5)
        port map(
            clk   => clk,
            reset => reset or reset_max,
            en    => en and carry_l,
            q     => cnt_h,
            cout  => open
        );

    reset_max <= '1' when (cnt_h = 5 and cnt_l = 9 and en = '1') else '0';

    bcd_h <= cnt_h;
    bcd_l <= cnt_l;
    cout  <= reset_max;

end structural;