library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topfile is
	port(
		KEY   :	in std_logic_vector(3 downto 0);
		CLOCK_50    :   in std_logic;
		LEDG	:	out std_logic_vector(7 downto 0)
	);
end entity topfile;

architecture struct of topfile is
	
	component testLogic
		port(
	   Clock : in std_logic;
		n_RST	: in std_logic;
		roll1 : in integer;
		roll2 : in integer;
		newRoll :in std_logic;
		WinLoseNA: out integer
	);
	end component;
	
	component roll_dice
		port(
		CLK		   : in std_logic;
		RB         : in std_logic;
        n_RST      : in std_logic;
        DIE_1      : out integer;
        DIE_2      : out integer
	);
	end component;
		
	signal DIE_1 :	integer;
	signal DIE_2 :	integer;
	signal output : integer;
	signal newRoll : std_logic;
begin

	roll1: roll_dice port map(
							CLOCK_50,
							KEY(3),
							KEY(0),
							DIE_1,
							DIE_2);
	
	
	logic1: testLogic port map(
							CLOCK_50,
							KEY(0),
							DIE_1,
							DIE_2,
							newRoll,
							output);
							
	LEDG <= std_logic_vector(to_unsigned(output, LEDG'length));
	
	
end architecture struct;