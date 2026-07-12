library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
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
end controller;

architecture behave of controller is

    type clock_adjust_type is (clk_normal, clk_adj_hour, clk_adj_min, clk_adj_sec);
    type alarm_adjust_type is (alm_adj_hour, alm_adj_min);
    type down_adjust_type is (down_adj_min, down_adj_sec);

    signal clock_state : clock_adjust_type := clk_normal;
    signal alarm_state : alarm_adjust_type := alm_adj_hour;
    signal down_state  : down_adjust_type  := down_adj_min;

    signal mode_last : std_logic_vector(1 downto 0) := "00";
    signal key0_last : std_logic := '1';
    signal key1_last : std_logic := '1';
    signal tick_last : std_logic := '0';

    signal key0_pulse : std_logic := '0';
    signal key1_pulse : std_logic := '0';
    signal tick_pulse : std_logic := '0';

    signal hour_now : integer range 0 to 23 := 0;
    signal min_now  : integer range 0 to 59 := 0;
    signal sec_now  : integer range 0 to 59 := 0;

    signal alarm_hour : integer range 0 to 23 := 0;
    signal alarm_min  : integer range 0 to 59 := 0;

    signal up_min : integer range 0 to 99 := 0;
    signal up_sec : integer range 0 to 59 := 0;

    signal down_min : integer range 0 to 99 := 0;
    signal down_sec : integer range 0 to 59 := 0;

    signal d5 : integer range 0 to 9 := 0;
    signal d4 : integer range 0 to 9 := 0;
    signal d3 : integer range 0 to 9 := 0;
    signal d2 : integer range 0 to 9 := 0;
    signal d1 : integer range 0 to 9 := 0;
    signal d0 : integer range 0 to 9 := 0;

    signal e5 : std_logic := '0';
    signal e4 : std_logic := '0';
    signal e3 : std_logic := '0';
    signal e2 : std_logic := '0';
    signal e1 : std_logic := '0';
    signal e0 : std_logic := '0';

    component segment4to7 is
        port(
            input : in integer range 0 to 9;
            en    : in std_logic;
            seg   : out std_logic_vector(6 downto 0)
        );
    end component;

    function tens_digit(value : integer) return integer is
    begin
        if value >= 90 then
            return 9;
        elsif value >= 80 then
            return 8;
        elsif value >= 70 then
            return 7;
        elsif value >= 60 then
            return 6;
        elsif value >= 50 then
            return 5;
        elsif value >= 40 then
            return 4;
        elsif value >= 30 then
            return 3;
        elsif value >= 20 then
            return 2;
        elsif value >= 10 then
            return 1;
        else
            return 0;
        end if;
    end function;

    function ones_digit(value : integer) return integer is
    begin
        if value >= 90 then
            return value - 90;
        elsif value >= 80 then
            return value - 80;
        elsif value >= 70 then
            return value - 70;
        elsif value >= 60 then
            return value - 60;
        elsif value >= 50 then
            return value - 50;
        elsif value >= 40 then
            return value - 40;
        elsif value >= 30 then
            return value - 30;
        elsif value >= 20 then
            return value - 20;
        elsif value >= 10 then
            return value - 10;
        else
            return value;
        end if;
    end function;

begin

    dec5 : segment4to7 port map(input => d5, en => e5, seg => hex5);
    dec4 : segment4to7 port map(input => d4, en => e4, seg => hex4);
    dec3 : segment4to7 port map(input => d3, en => e3, seg => hex3);
    dec2 : segment4to7 port map(input => d2, en => e2, seg => hex2);
    dec1 : segment4to7 port map(input => d1, en => e1, seg => hex1);
    dec0 : segment4to7 port map(input => d0, en => e0, seg => hex0);

    process(clk_50MHz, reset)
    begin
        if reset = '1' then
            key0_last <= '1';
            key1_last <= '1';
            tick_last <= '0';
            key0_pulse <= '0';
            key1_pulse <= '0';
            tick_pulse <= '0';
        elsif rising_edge(clk_50MHz) then
            key0_pulse <= '0';
            key1_pulse <= '0';
            tick_pulse <= '0';

            if key0_last = '1' and key_mode = '0' then
                key0_pulse <= '1';
            end if;

            if key1_last = '1' and key_set = '0' then
                key1_pulse <= '1';
            end if;

            if tick_last = '0' and clk_tick = '1' then
                tick_pulse <= '1';
            end if;

            key0_last <= key_mode;
            key1_last <= key_set;
            tick_last <= clk_tick;
        end if;
    end process;

    process(clk_50MHz, reset)
    begin
        if reset = '1' then
            clock_state <= clk_normal;
            alarm_state <= alm_adj_hour;
            down_state <= down_adj_min;
            mode_last <= "00";

            hour_now <= 0;
            min_now <= 0;
            sec_now <= 0;
            alarm_hour <= 0;
            alarm_min <= 0;
            up_min <= 0;
            up_sec <= 0;
            down_min <= 0;
            down_sec <= 0;
        elsif rising_edge(clk_50MHz) then
            if sw_mode /= mode_last then
                clock_state <= clk_normal;
                alarm_state <= alm_adj_hour;
                down_state <= down_adj_min;
                mode_last <= sw_mode;
            end if;

            if tick_pulse = '1' then
                if sec_now = 59 then
                    sec_now <= 0;
                    if min_now = 59 then
                        min_now <= 0;
                        if hour_now = 23 then
                            hour_now <= 0;
                        else
                            hour_now <= hour_now + 1;
                        end if;
                    else
                        min_now <= min_now + 1;
                    end if;
                else
                    sec_now <= sec_now + 1;
                end if;

                if sw_mode = "10" and sw_start = '1' then
                    if up_sec = 59 then
                        up_sec <= 0;
                        if up_min = 99 then
                            up_min <= 0;
                        else
                            up_min <= up_min + 1;
                        end if;
                    else
                        up_sec <= up_sec + 1;
                    end if;
                end if;

                if sw_mode = "11" and sw_down = '1' then
                    if down_min /= 0 or down_sec /= 0 then
                        if down_sec = 0 then
                            down_sec <= 59;
                            if down_min /= 0 then
                                down_min <= down_min - 1;
                            end if;
                        else
                            down_sec <= down_sec - 1;
                        end if;
                    end if;
                end if;
            end if;

            case sw_mode is
                when "00" =>
                    if key0_pulse = '1' then
                        case clock_state is
                            when clk_normal   => clock_state <= clk_adj_hour;
                            when clk_adj_hour => clock_state <= clk_adj_min;
                            when clk_adj_min  => clock_state <= clk_adj_sec;
                            when clk_adj_sec  => clock_state <= clk_normal;
                        end case;
                    end if;

                    if key1_pulse = '1' then
                        case clock_state is
                            when clk_adj_hour =>
                                if hour_now = 23 then
                                    hour_now <= 0;
                                else
                                    hour_now <= hour_now + 1;
                                end if;
                            when clk_adj_min =>
                                if min_now = 59 then
                                    min_now <= 0;
                                else
                                    min_now <= min_now + 1;
                                end if;
                            when clk_adj_sec =>
                                if sec_now = 59 then
                                    sec_now <= 0;
                                else
                                    sec_now <= sec_now + 1;
                                end if;
                            when others =>
                                null;
                        end case;
                    end if;

                when "01" =>
                    if key0_pulse = '1' then
                        if alarm_state = alm_adj_hour then
                            alarm_state <= alm_adj_min;
                        else
                            alarm_state <= alm_adj_hour;
                        end if;
                    end if;

                    if key1_pulse = '1' then
                        if alarm_state = alm_adj_hour then
                            if alarm_hour = 23 then
                                alarm_hour <= 0;
                            else
                                alarm_hour <= alarm_hour + 1;
                            end if;
                        else
                            if alarm_min = 59 then
                                alarm_min <= 0;
                            else
                                alarm_min <= alarm_min + 1;
                            end if;
                        end if;
                    end if;

                when "10" =>
                    if key1_pulse = '1' then
                        up_min <= 0;
                        up_sec <= 0;
                    end if;

                when others =>
                    if sw_down = '0' and key0_pulse = '1' then
                        if down_state = down_adj_min then
                            down_state <= down_adj_sec;
                        else
                            down_state <= down_adj_min;
                        end if;
                    end if;

                    if sw_down = '0' and key1_pulse = '1' then
                        if down_state = down_adj_min then
                            if down_min = 99 then
                                down_min <= 0;
                            else
                                down_min <= down_min + 1;
                            end if;
                        else
                            if down_sec = 59 then
                                down_sec <= 0;
                            else
                                down_sec <= down_sec + 1;
                            end if;
                        end if;
                    end if;
            end case;
        end if;
    end process;

    process(sw_mode, hour_now, min_now, sec_now, alarm_hour, alarm_min,
            up_min, up_sec, down_min, down_sec, clock_state, alarm_state,
            down_state, blink_clk, sw_down)
        variable show_clock_hour : std_logic;
        variable show_clock_min  : std_logic;
        variable show_clock_sec  : std_logic;
        variable show_alarm_hour : std_logic;
        variable show_alarm_min  : std_logic;
        variable show_down_min   : std_logic;
        variable show_down_sec   : std_logic;
    begin
        d5 <= 0; d4 <= 0; d3 <= 0; d2 <= 0; d1 <= 0; d0 <= 0;
        e5 <= '0'; e4 <= '0'; e3 <= '0'; e2 <= '0'; e1 <= '0'; e0 <= '0';

        case sw_mode is
            when "00" =>
                show_clock_hour := '1';
                show_clock_min := '1';
                show_clock_sec := '1';

                if clock_state = clk_adj_hour and blink_clk = '1' then
                    show_clock_hour := '0';
                elsif clock_state = clk_adj_min and blink_clk = '1' then
                    show_clock_min := '0';
                elsif clock_state = clk_adj_sec and blink_clk = '1' then
                    show_clock_sec := '0';
                end if;

                d5 <= tens_digit(hour_now); d4 <= ones_digit(hour_now);
                d3 <= tens_digit(min_now);  d2 <= ones_digit(min_now);
                d1 <= tens_digit(sec_now);  d0 <= ones_digit(sec_now);
                e5 <= show_clock_hour; e4 <= show_clock_hour;
                e3 <= show_clock_min;  e2 <= show_clock_min;
                e1 <= show_clock_sec;  e0 <= show_clock_sec;

            when "01" =>
                show_alarm_hour := '1';
                show_alarm_min := '1';

                if alarm_state = alm_adj_hour and blink_clk = '1' then
                    show_alarm_hour := '0';
                elsif alarm_state = alm_adj_min and blink_clk = '1' then
                    show_alarm_min := '0';
                end if;

                d5 <= tens_digit(alarm_hour); d4 <= ones_digit(alarm_hour);
                d3 <= tens_digit(alarm_min);  d2 <= ones_digit(alarm_min);
                e5 <= show_alarm_hour; e4 <= show_alarm_hour;
                e3 <= show_alarm_min;  e2 <= show_alarm_min;

            when "10" =>
                d3 <= tens_digit(up_min); d2 <= ones_digit(up_min);
                d1 <= tens_digit(up_sec); d0 <= ones_digit(up_sec);
                e3 <= '1'; e2 <= '1'; e1 <= '1'; e0 <= '1';

            when others =>
                show_down_min := '1';
                show_down_sec := '1';

                if sw_down = '0' then
                    if down_state = down_adj_min and blink_clk = '1' then
                        show_down_min := '0';
                    elsif down_state = down_adj_sec and blink_clk = '1' then
                        show_down_sec := '0';
                    end if;
                end if;

                d3 <= tens_digit(down_min); d2 <= ones_digit(down_min);
                d1 <= tens_digit(down_sec); d0 <= ones_digit(down_sec);
                e3 <= show_down_min; e2 <= show_down_min;
                e1 <= show_down_sec; e0 <= show_down_sec;
        end case;
    end process;

    led_clock <= '1' when sw_mode = "00" else '0';
    led_alarm <= '1' when sw_mode = "01" else '0';
    led_timer <= '1' when sw_mode = "10" or sw_mode = "11" else '0';

    led_alert <= blink_clk when
        ((alarm_en = '1' and hour_now = alarm_hour and min_now = alarm_min) or
         (sw_mode = "11" and down_min = 0 and down_sec = 0))
        else '0';

end behave;
