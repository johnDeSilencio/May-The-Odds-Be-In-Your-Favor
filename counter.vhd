library ieee;
use ieee.std_logic_1164.all;

-- generic down counter with count
-- value output every clock cycle

-- counts down from "count_from" to one

entity counter is
	generic(
		count_from : integer
	);
	
	port(
		n_RST   :	in std_logic;
		CLK     :   in std_logic;
        ENABLE  :   in std_logic;
		COUNT   :	out integer
	);
end entity counter;

architecture rtl of counter is
	signal count_val : integer;
begin
	process(n_RST, CLK)
	begin
		if (n_RST = '0') then
			count_val <= count_from;
		elsif (CLK = '1' and CLK'event) then
			if (ENABLE = '1') then
                if (count_val = 1) then
                    count_val <= count_from;
                else
                    -- count_val > 1
                    
                    count_val <= count_val - 1;
                end if;
            end if;
        end if;
	end process;
	
	-- dummy assignment
	COUNT <= count_val;
end architecture rtl;