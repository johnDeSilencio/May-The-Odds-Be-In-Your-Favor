--
-- Tutorial on using the LCD on the DE2-115 board
-- by Claudio Talarico
-- Gonzaga University
-- talarico@gonzaga.edu
--
--
-- The example displays the word VHDL and a "running" digit
-- on the LCD. The word VHDL is "split" on the first and
-- the second line, while the runnning digit is on the last
-- character of the second line
-- +----------------+
-- |VH              |
-- |  DL           0|
-- +----------------+
--
--
-- The 2 x 16 character LCD on the board has an internal Sitronix ST7066U graphics
-- controller that is functionally equivalent with the following devices:
-- * Samsung S6A0069X or KS0066U
-- * Hitachi HD44780
-- * SMOS SED1278
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd_driver is
	generic (clk_divider: integer := 50000);
	PORT (
		clk         : in std_logic; -- clock
		rst         : in std_logic; -- reset
		rs          : out std_logic; -- REGISTER
		selectrw    : out std_logic; -- read/write
		en          : out std_logic; -- enable
		lcd_on      : out std_logic; -- lcd power ON
		db          : out std_logic_vector(7 DOWNTO 0);
        
        -- Game logic specific I/O
        win_lose_na  : in integer;
        point        : in integer;
        die_roll_1   : in integer;
        die_roll_2   : in integer;
        roll         : in integer -- die_roll_1 + die_roll_2
	);
end lcd_driver;

architecture rtl of lcd_driver is
	type state_t is (fs1, fs2, fs3, fs4, cld, ctd, em, sa2,
                     wd1,       -- (C)   or (Y)
                     wd2,       -- (R)   or (O)
                     wd3,       -- (A)   or (U)
                     wd4,       -- (P)   or (' ')
                     wd5,       -- (S)   or (W) or (L)
                     wd6,       -- (!)   or (O)
                     wd7,       -- (' ') or (N) or (S)
                     wd8,       -- (' ') or (!) or (T)
                     wd9,       -- (' ')
                     wd10,      -- P
                     wd11,      -- T
                     wd12,      -- ' '
                     wd13,      -- =
                     wd14,      -- ' '
                     wd15,      -- [tens digit of point]
                     wd16,      -- [ones digit of point]
                     wd17,      -- D
                     wd18,      -- 1
                     wd19,      -- =
                     wd20,      -- [result of roll for die 1]
                     wd21,      -- +
                     wd22,      -- D
                     wd23,      -- 2
                     wd24,      -- =
                     wd25,      -- [result of roll for die 2]
                     wd26,      -- ' '
                     wd27,      -- '-'
                     wd28,      -- '>'
                     wd29,      -- ' '
                     wd30,      -- [tens digit of roll]
                     wd31       -- [ones digit of roll]
                );
    
    
    -- ASCII letter constant declerations
    constant c_letter : std_logic_vector(7 downto 0) := "01000011";
    constant r_letter : std_logic_vector(7 downto 0) := "01010010";
    constant a_letter : std_logic_vector(7 downto 0) := "01000001";
    constant p_letter : std_logic_vector(7 downto 0) := "01010000";
    constant s_letter : std_logic_vector(7 downto 0) := "01010011";
    constant y_letter : std_logic_vector(7 downto 0) := "01011001";
    constant o_letter : std_logic_vector(7 downto 0) := "01001111";
    constant u_letter : std_logic_vector(7 downto 0) := "01010101";
    constant w_letter : std_logic_vector(7 downto 0) := "01010111";
    constant n_letter : std_logic_vector(7 downto 0) := "01001110";
    constant l_letter : std_logic_vector(7 downto 0) := "01001100";
    constant t_letter : std_logic_vector(7 downto 0) := "01000100";
    constant d_letter : std_logic_vector(7 downto 0) := "01000100";
    
    -- ASCII number declaration
    constant num_zero       : std_logic_vector(7 downto 0) := "00110000";
    constant num_one        : std_logic_vector(7 downto 0) := "00110001";
    constant num_two        : std_logic_vector(7 downto 0) := "00110010";
    constant num_three      : std_logic_vector(7 downto 0) := "00110011";
    constant num_four       : std_logic_vector(7 downto 0) := "00110100";
    constant num_five       : std_logic_vector(7 downto 0) := "00110101";
    constant num_six        : std_logic_vector(7 downto 0) := "00110110";
    constant num_seven      : std_logic_vector(7 downto 0) := "00110111";
    constant num_eight      : std_logic_vector(7 downto 0) := "00111000";
    constant num_nine       : std_logic_vector(7 downto 0) := "00111001";
    
    -- ASCII symbol declaration
    constant exclamation    : std_logic_vector(7 downto 0) := "00100001";
    constant space          : std_logic_vector(7 downto 0) := "00100000";
    constant equals         : std_logic_vector(7 downto 0) := "00111101";
    constant plus           : std_logic_vector(7 downto 0) := "00101011";
    constant hyphen         : std_logic_vector(7 downto 0) := "00101101";
    constant greater_than   : std_logic_vector(7 downto 0) := "00111110";
    
	constant timer_limit : INTEGER := 500;
	signal next_lcdon, lcdon : std_logic;
	signal ckdiv : std_logic;
	signal state, next_state : state_t;
	signal digit, next_digit : integer range 0 TO 9;
	signal cnt, next_cnt : integer range 0 TO timer_limit;
    signal rw : std_logic;
BEGIN
-- clock divider
	clk_div : PROCESS (clk)
		variable count_v : integer range 0 TO clk_divider;
		variable ckdiv_v : std_logic;
	begin
		if (clk = '1'AND clk'event) THEN
			count_v := count_v + 1;
			IF (count_v = clk_divider) THEN
				ckdiv_v := NOT ckdiv_v;
			count_v := 0;
			end if;
		end if;
		ckdiv <= ckdiv_v; -- ckdiv is used as the LCD's enable
	end process clk_div; 
	
	-- registers
	regs: process(ckdiv, rst)
	begin
		if rst='0' then
			state  <= fs1;
			lcdon  <= '0';
			cnt    <= 0;
			digit  <= 0;
		elsif (ckdiv'event and ckdiv='1') then
			state  <= next_state;
			lcdon  <= next_lcdon;
			cnt    <= next_cnt;
			digit  <= next_digit;
		end if;
	end process regs;
	
	--
	-- generate a 0 to 9 "running digit
	-- increment the digit every 0.5 sec (2Hz)
	--
	
	digit_incr: process(digit,cnt)
	begin
		-- by default hold
		next_digit <= digit;
		next_cnt   <= cnt;
		if (cnt = timer_limit) then
			if (digit = 9) then
				next_digit <= 0;
			else
				next_digit <= digit + 1;
			end if;
			
			next_cnt <= 0;
		else
			next_cnt <= cnt + 1;
		end if;
	end process digit_incr;
	
	--
	-- state machine driving the LCD
	--
	machine: process(state, digit, lcdon, roll)
	begin
		-- default
		next_state  <= state;
		next_lcdon  <= lcdon;
		case state is
			when fs1 => -- function set 1
				rs <= '0'; rw <= '0';
				db <= "00111000";
				next_state <= fs2;
			when fs2 => -- function set 2
				rs <= '0'; rw <= '0';
				db <= "00111000";
				next_state <= fs3;
			when fs3 => -- function set 3
				rs <= '0'; rw <= '0';
				db <= "00111000";
				next_state <= fs4;
			when fs4 => -- function set 4
				rs <= '0'; rw <= '0';
				db <= "00111000"; -- 8 bit bus, 2-lines, 5x8 dots
				next_state <= cld;
			when ctd => -- control display
				rs <= '0'; rw <= '0';
				db <= "00001100";
				next_state <= em;
			when cld => -- clear display
				rs <= '0'; rw <= '0';
				db <= "00000001";
				next_state <= ctd;
			when em => -- entry mode
				rs <= '0'; rw <= '0';
				db <= "00000110"; -- increment DDRAM address, do not shift display
				next_state <= wd1;
				next_lcdon <= '1'; -- turn on the LCD
			when wd1 => -- write data
				rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= c_letter; -- C
                else
                    -- win_lose_na /= 0
                    db <= y_letter; -- Y
				end if;
                next_state <= wd2;
			when wd2 =>
				rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= r_letter; -- R
                else
                    db <= o_letter; -- O
                end if;
				next_state <= wd3;
            when wd3 =>
				rs <= '1'; rw <= '0';
				if (win_lose_na = 0) then
                    db <= a_letter; -- A
				else
                    db <= u_letter; -- U
                end if;
                next_state <= wd4;
            when wd4 =>
				rs <= '1'; rw <= '0';
				if (win_lose_na = 0) then
                    db <= p_letter; -- P
                else
                    db <= space; -- ' '
                end if;
				next_state <= wd5;
            when wd5 =>
				rs <= '1'; rw <= '0';
				if (win_lose_na = 0) then
                    db <= s_letter; -- S
                elsif (win_lose_na = 1) then
                    db <= l_letter; -- L
				else
                    -- win_lose_na = 2
                    db <= w_letter; -- W
                end if;
                next_state <= wd6;
            when wd6 =>
				rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= exclamation; -- !
                else
                    -- win_lose_na /= 0
                    db <= o_letter; -- O
				end if;
                next_state <= wd7;
            when wd7 =>
                rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= space; -- ' ' 
                elsif (win_lose_na = 1) then
                    db <= n_letter; -- 'N'
                else
                    db <= s_letter; -- 'S'
                end if;
                next_state <= wd8;
            when wd8 =>
                rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= space; -- ' ' 
                elsif (win_lose_na = 1) then
                    db <= exclamation; -- '!'
                else
                    db <= t_letter; -- 'T'
                end if;
                next_state <= wd9;
            when wd9 =>
                rs <= '1'; rw <= '0';
                db <= space; -- ' '
                next_state <= wd10;
            when wd10 =>
				rs <= '1'; rw <= '0';
				db <= p_letter; -- P
				next_state <= wd11;
            when wd11 =>
				rs <= '1'; rw <= '0';
				db <= t_letter; -- T
				next_state <= wd12;
            when wd12 =>
				rs <= '1'; rw <= '0';
				db <= space; -- ' '
				next_state <= wd13;
            when wd13 =>
				rs <= '1'; rw <= '0';
				db <= equals; -- =
				next_state <= wd14;
            when wd14 =>
				rs <= '1'; rw <= '0';
				db <= space; -- ' '
				next_state <= wd15;
            when wd15 =>
				rs <= '1'; rw <= '0';
				if (win_lose_na = 0) then
                    db <= n_letter; -- N
                else
                    case point is
                        when 10 =>
                            db <= num_one;
                        when 11 =>
                            db <= num_one;
                        when 12 =>
                            db <= num_one;
                        when others =>
                            db <= num_zero;
                    end case;
                end if;
				next_state <= wd16;
            when wd16 =>
				rs <= '1'; rw <= '0';
                if (win_lose_na = 0) then
                    db <= a_letter; -- A
                else
                    case point is
                        when 2 =>
                            db <= num_two;
                        when 3 =>
                            db <= num_three;
                        when 4 =>
                            db <= num_four;
                        when 5 =>
                            db <= num_five;
                        when 6 =>
                            db <= num_six;
                        when 7 =>
                            db <= num_seven;
                        when 8 =>
                            db <= num_eight;
                        when 9 =>
                            db <= num_nine;
                        when 10 =>
                            db <= num_zero;
                        when 11 =>
                            db <= num_one;
                        when 12 =>
                            db <= num_two;
                        when others =>
                            -- do nothing
                    end case;
                end if;
				next_state <= sa2;
                
            when sa2 =>
                rs <= '0'; rw <= '0';
                -- the first char of the second line is addr = 0x40
                db <= "11000000"; -- addr = 0x40 (the MSB indicates 2nd line)
                next_state <= wd17;
                
            when wd17 =>
				rs <= '1'; rw <= '0';
				db <= d_letter; -- D
				next_state <= wd18; 
			when wd18 =>
				rs <= '1'; rw <= '0';
				db <= num_one; -- 1
				next_state <= wd19;
            when wd19 =>
				rs <= '1'; rw <= '0';
				db <= equals; -- =
				next_state <= wd20;
            when wd20 =>
				rs <= '1'; rw <= '0';
                case die_roll_1 is
                    when 1 =>
                        db <= num_one;
                    when 2 =>
                        db <= num_two;
                    when 3 =>
                        db <= num_three;
                    when 4 =>
                        db <= num_four;
                    when 5 =>
                        db <= num_five;
                    when 6 =>
                        db <= num_six;
                    when others =>
                        -- do nothing
                end case;
				next_state <= wd21;
            when wd21 =>
				rs <= '1'; rw <= '0';
				db <= plus; -- +
				next_state <= wd22;
            when wd22 =>
				rs <= '1'; rw <= '0';
				db <= d_letter; -- D
				next_state <= wd23;
            when wd23 =>
				rs <= '1'; rw <= '0';
				db <= num_two; -- 2
				next_state <= wd24;
            when wd24 =>
				rs <= '1'; rw <= '0';
				db <= equals; -- =
				next_state <= wd25;
            when wd25 =>
				rs <= '1'; rw <= '0';
				case die_roll_2 is
                    when 1 =>
                        db <= num_one;
                    when 2 =>
                        db <= num_two;
                    when 3 =>
                        db <= num_three;
                    when 4 =>
                        db <= num_four;
                    when 5 =>
                        db <= num_five;
                    when 6 =>
                        db <= num_six;
                    when others =>
                        -- do nothing
                end case;
				next_state <= wd26;
            when wd26 =>
				rs <= '1'; rw <= '0';
				db <= space; -- ' '
				next_state <= wd27;
            when wd27 =>
				rs <= '1'; rw <= '0';
				db <= hyphen; -- -
				next_state <= wd28;
            when wd28 =>
				rs <= '1'; rw <= '0';
				db <= greater_than; -- >
				next_state <= wd29;
            when wd29 =>
				rs <= '1'; rw <= '0';
				db <= space; -- ' '
				next_state <= wd30;
            when wd30 =>
				rs <= '1'; rw <= '0';
				case roll is
                    when 10 =>
                        db <= num_one;
                    when 11 =>
                        db <= num_one;
                    when 12 =>
                        db <= num_one;
                    when others =>
                        db <= num_zero;
                end case;
				next_state <= wd31;
            when wd31 =>
				rs <= '1'; rw <= '0';
				case roll is
                    when 2 =>
                        db <= num_two;
                    when 3 =>
                        db <= num_three;
                    when 4 =>
                        db <= num_four;
                    when 5 =>
                        db <= num_five;
                    when 6 =>
                        db <= num_six;
                    when 7 =>
                        db <= num_seven;
                    when 8 =>
                        db <= num_eight;
                    when 9 =>
                        db <= num_nine;
                    when 10 =>
                        db <= num_zero;
                    when 11 =>
                        db <= num_one;
                    when 12 =>
                        db <= num_two;
                    when others =>
                        -- do nothing
                end case;
				next_state <= fs1;
		end case;
	end process machine;
	
	-- simple assignments
	lcd_on <= lcdon;
	en     <= ckdiv;
end architecture;