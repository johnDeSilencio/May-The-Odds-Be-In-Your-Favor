library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

entity DeBounce is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
end DeBounce;

architecture behav of DeBounce is


constant COUNT_MAX : integer := 5; 
constant BTN_ACTIVE : std_logic := '0';
constant BTN_INACTIVE : std_logic := '1';

signal count : integer := 0;
type state_type is (idle,wait_time,down_edge); --state machine
signal state : state_type := idle;

signal Qsig :std_logic;
signal Dsig :std_logic;

begin
  
process(Reset,Clock)
begin	 
	 if(Reset = '0') then
        state <= idle;
        pulse_out <= '0';
		  count <= 0;
   elsif(Clock'event and Clock ='1') then
        case (state) is
            when idle =>
                if(button_in = BTN_ACTIVE) then  
                    state <= wait_time;
                else
                    state <= idle; --wait until button is pressed.
                end if;
                pulse_out <= '0';
            when wait_time =>
                if(count = COUNT_MAX) then
                    count <= 0;
                    if(button_in = BTN_ACTIVE) then
                        pulse_out <= '1';
								state <= down_edge;
                    else
								state <= idle;
						  end if;	
                else
                    count <= count + 1;
                end if; 
				when down_edge =>
					pulse_out <= '0';
					state <= down_edge;
					if(button_in = BTN_INACTIVE) then
						state <= idle;
					end if;
				when others =>
					-- do nothing
        end case;       
    end if;	 
end process;
                                                                
end architecture behav;