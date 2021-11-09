library ieee;
use ieee.std_logic_1164.all;

entity topfile is
	port(
		KEY   :	in std_logic_vector(3 downto 0);
		CLOCK_50    :   in std_logic;
		LEDG	:	out std_logic_vector(7 downto 0);
	);
end entity topfile;

architecture rtl of counter is
	
	component testLogic
		port(
	   Clock : in std_logic;
		n_RST	: in std_logic;
		roll1 : in integer;
		roll2 : in integer;
		WinLoseNA: out std_logic
		);
	end component;
		

	signal count_val : integer;
begin
	
	logic1: testLogic port map(
							CLOCK_50,
							KEY[0],
							x,
							y,
							LEDG[7]);
	
	
end architecture rtl;