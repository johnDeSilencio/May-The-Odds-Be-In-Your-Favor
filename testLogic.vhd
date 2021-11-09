library ieee;
use ieee.std_logic_1164.all;

-- generic down counter with count
-- value output every clock cycle

-- counts down from "count_from" to one

entity testLogic is
	port(
		n_RST	: in std_logic;
		roll   :	in integer;
		WinLoseNA: out std_logic
	);
end entity counter;

architecture rtl of counter is
	type state_type is (firstRoll,afterFirst,idle); --state machine
	variable curr_state : state_type := firstRoll;
	variable nxt_state : state_type := firstRoll;
	signal point : integer;
begin
	process(roll,n_RST)
	begin
		if(n_RST = '0') then
			roll <= 0;
			WinLoseNA <= '0'; --nothing
			curr_state := firstRoll;
			nxt_state := firstRoll;
		else
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