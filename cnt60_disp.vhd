library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt60_disp is
    port(
        clk    : in std_logic;
        reset  : in std_logic;
        en     : in std_logic;
        blink  : in std_logic;

        seg_h  : out std_logic_vector(6 downto 0);
        seg_l  : out std_logic_vector(6 downto 0);

        cout   : out std_logic
    );
end cnt60_disp;

architecture structural of cnt60_disp is

    component bcd_cnt60 is
        port(
            clk    : in std_logic;
            reset  : in std_logic;
            en     : in std_logic;
            bcd_h  : out integer range 0 to 9;
            bcd_l  : out integer range 0 to 9;
            cout   : out std_logic
        );
    end component;

    component segment4to7 is
        port(
            input : in integer range 0 to 9;
            en    : in std_logic;
            seg   : out std_logic_vector(6 downto 0)
        );
    end component;

    signal bcd_h_int : integer range 0 to 9;
    signal bcd_l_int : integer range 0 to 9;

begin

    counter : bcd_cnt60
        port map(
            clk    => clk,
            reset  => reset,
            en     => en,
            bcd_h  => bcd_h_int,
            bcd_l  => bcd_l_int,
            cout   => cout
        );

    decoder_h : segment4to7
        port map(
            input => bcd_h_int,
            en    => not blink,
            seg   => seg_h
        );

    decoder_l : segment4to7
        port map(
            input => bcd_l_int,
            en    => not blink,
            seg   => seg_l
        );

end structural;