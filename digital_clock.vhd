library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_clock is
    port(
        MAX10_CLK1_50 : in std_logic;
        SW            : in std_logic_vector(9 downto 0);
        KEY           : in std_logic_vector(1 downto 0);
        LEDR          : out std_logic_vector(9 downto 0);

        HEX5 : out std_logic_vector(6 downto 0);
        HEX4 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX0 : out std_logic_vector(6 downto 0)
    );
end digital_clock;

architecture structural of digital_clock is

    component freqdivider is
        generic(
            freq_in  : integer := 50000000;
            freq_out : integer := 1
        );
        port(
            clk_in  : in std_logic;
            clk_out : out std_logic
        );
    end component;

    component controller is
        port(
            clk_50MHz : in std_logic;
            clk_tick  : in std_logic;
            blink_clk : in std_logic;
            reset     : in std_logic;

            sw_mode   : in std_logic_vector(1 downto 0);
            alarm_en  : in std_logic;
            sw_start  : in std_logic;
            sw_down   : in std_logic;
            key_mode  : in std_logic;
            key_set   : in std_logic;

            hex5 : out std_logic_vector(6 downto 0);
            hex4 : out std_logic_vector(6 downto 0);
            hex3 : out std_logic_vector(6 downto 0);
            hex2 : out std_logic_vector(6 downto 0);
            hex1 : out std_logic_vector(6 downto 0);
            hex0 : out std_logic_vector(6 downto 0);

            led_clock : out std_logic;
            led_alarm : out std_logic;
            led_timer : out std_logic;
            led_alert : out std_logic
        );
    end component;

    signal clk_1Hz   : std_logic;
    signal clk_100Hz : std_logic;
    signal clk_use   : std_logic;
    signal led0_i    : std_logic;
    signal led1_i    : std_logic;
    signal led2_i    : std_logic;
    signal led4_i    : std_logic;

begin

    div_1Hz : freqdivider
        generic map(
            freq_in  => 50000000,
            freq_out => 1
        )
        port map(
            clk_in  => MAX10_CLK1_50,
            clk_out => clk_1Hz
        );

    div_100Hz : freqdivider
        generic map(
            freq_in  => 50000000,
            freq_out => 100
        )
        port map(
            clk_in  => MAX10_CLK1_50,
            clk_out => clk_100Hz
        );

    clk_use <= clk_100Hz when SW(9) = '1' else clk_1Hz;

    control_unit : controller
        port map(
            clk_50MHz => MAX10_CLK1_50,
            clk_tick  => clk_use,
            blink_clk => clk_1Hz,
            reset     => SW(0),
            sw_mode   => SW(2 downto 1),
            alarm_en  => SW(3),
            sw_start  => SW(4),
            sw_down   => SW(5),
            key_mode  => KEY(0),
            key_set   => KEY(1),
            hex5      => HEX5,
            hex4      => HEX4,
            hex3      => HEX3,
            hex2      => HEX2,
            hex1      => HEX1,
            hex0      => HEX0,
            led_clock => led0_i,
            led_alarm => led1_i,
            led_timer => led2_i,
            led_alert => led4_i
        );

    LEDR(0) <= led0_i;
    LEDR(1) <= led1_i;
    LEDR(2) <= led2_i;
    LEDR(3) <= '0';
    LEDR(4) <= led4_i;
    LEDR(5) <= '0';
    LEDR(6) <= '0';
    LEDR(7) <= '0';
    LEDR(8) <= '0';
    LEDR(9) <= SW(9);

end structural;
