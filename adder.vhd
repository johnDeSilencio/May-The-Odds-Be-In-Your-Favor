library ieee;
use ieee.std_logic_1164.all;

-- generic down counter with count
-- value output every clock cycle

-- counts down from "count_from" to one

entity adder is
	port(
		X   :	in integer;
		Y   :   in integer;
		Z   :	out integer
	);
end entity adder;

architecture rtl of adder is
begin
	process(X,Y)
	begin
		Z <= X+Y;
	end process;
end architecture rtl;