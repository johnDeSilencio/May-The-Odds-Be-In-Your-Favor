library ieee;
use ieee.std_logic_1164.all;

-- generic down counter with count
-- value output every clock cycle

-- counts down from "count_from" to one

entity testLogic is
	port(
	   Clock : in std_logic;
		n_RST	: in std_logic;
		roll1 : in integer;
		roll2 : in integer;
		newRoll :in std_logic;
        pointOUT : out integer;
        rollOUT : out integer;
		WinLoseNA: out integer
	);
end entity testLogic;

architecture rtl of testLogic is
	type state_type is (firstRoll,afterFirst, rolling,idle); --state machine
	signal curr_state : state_type;
	signal nxt_state : state_type;
	signal point : integer;
	signal roll : integer;
    signal curr_win_lose_na, nxt_win_lose_na : integer;
begin
    adder : process(roll1, roll2)
    begin
        roll <= roll1 + roll2;
    end process adder;
    
	next_state_logic : process(curr_state, roll,newRoll)
	begin
        -- defaults to preserve state
        nxt_state <= curr_state;
        
    
		case (curr_state) is 
			when firstRoll =>
				if(roll = 7 or roll = 11) then 
					nxt_win_lose_na <= 2;--win
					nxt_state <= idle;
				elsif roll = 2 or roll = 3 or roll = 12 then
					nxt_win_lose_na <= 1; --lose
					nxt_state <= idle;
				else 
					nxt_win_lose_na <= 0;--nothing
					point <= roll;
					nxt_state <= rolling;
				end if;
			when rolling =>
				if newRoll = '1' then
					nxt_state <= afterFirst;
				end if;
			when afterFirst =>
				if roll = 7 then
					nxt_win_lose_na <= 1;--lose
					nxt_state <= idle;
				elsif  roll = point then
					nxt_win_lose_na <= 2; --win
					nxt_state <= idle;
				else 
					nxt_win_lose_na <= 0;--nothing
					nxt_state <= afterFirst;
				end if;
			when idle =>
				--do nothing
			when others =>
				--do nothing
		end case;
	end process next_state_logic;
    
    reg_logic : process(n_RST, Clock)
    begin
        if (n_RST = '0') then
            curr_win_lose_na <= 0; -- N/A
            curr_state <= firstRoll;
        elsif (Clock'event and Clock = '1') then
            curr_win_lose_na <= nxt_win_lose_na;
            curr_state <= nxt_state;
        end if;
    end process reg_logic;
    
    -- dummy assignment
    WinLoseNA <= curr_win_lose_na;
    rollOUT <= roll;
    pointOUT <= point;
    
end architecture rtl;