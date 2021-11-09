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
		WinLoseNA: out std_logic
	);
end entity counter;

architecture rtl of counter is
	type state_type is (firstRoll,afterFirst,idle); --state machine
	variable curr_state : state_type := firstRoll;
	variable nxt_state : state_type := firstRoll;
	signal point : integer;
	signal roll : integer;
begin
	roll<= roll1 + roll2;
	process(roll,n_RST,clk)
	begin
		if(n_RST = '0') then
			roll1 <= 0;
			roll2 <= 0;
			WinLoseNA <= '0'; --nothing
			curr_state := firstRoll;
			nxt_state := firstRoll;
		elsif(Clock'event and Clock ='1') then
			case (state) is 
				when firstRoll =>
					if(roll = 7 or roll = 11) then 
						WinLoseNA <= '2';--win
						nxt_state := idle;
					elsif roll = 2 or roll = 3 or roll = 12 then
						WinLoseNA <= '1'; --lose
						nxt_state := idle;
					else 
						WinLoseNA <= '0';--nothing
						point <= roll;
						nxt_state := afterFirst;
					end if;
				when afterFirst =>
					if roll = 7 then
						WinLoseNA <= '1';--lose
						nxt_state := idle;
					elsif  roll = point then
						WinLoseNA <= '2'; --win
						nxt_state := idle
					else 
						WinLoseNA <= '0';--nothing
						nxt_state := afterFirst;
					end if;
				when idle =>
					--do nothing
				when other =>
					--do nothing
			end case;
		end if;
	end process;
end architecture rtl;