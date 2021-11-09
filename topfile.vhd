library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topfile is
	port(
		KEY   :	in std_logic_vector(3 downto 0);
		CLOCK_50    :   in std_logic;
		LED	:	out std_logic_vector(3 downto 0);
		LEDL	:	out std_logic_vector(3 downto 0);
		LEDR	:	out std_logic_vector(3 downto 0)
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
		pointOUT : out integer;
		rollOUT : out integer;
		WinLoseNA: out integer);
	end component;
	
	component roll_dice
		port(
		CLK		   : in std_logic;
		RB         : in std_logic;
        n_RST      : in std_logic;
        DIE_1      : out integer;
        DIE_2      : out integer;
        NEW_ROLL   : out std_logic -- goes high for one clock cycle when rolls are decided
			);
			
	end component;
		
	signal DIE_1 :	integer;
	signal DIE_2 :	integer;
	signal outRoll : integer;
	signal outpoint : integer;
	signal newRoll : std_logic;
	signal Win_Lose : integer;
begin

	roll1: roll_dice port map(
							CLOCK_50,
							KEY(3),
							KEY(0),
							DIE_1,
							DIE_2,
							newRoll);
	
	
	logic1: testLogic port map(
							CLOCK_50,
							KEY(0),
							DIE_1,
							DIE_2,
							newRoll,
							outPoint,
							outRoll,
							Win_Lose);
	
	LED(3 downto 0) <= std_logic_vector(to_unsigned(outRoll, 4));
	LEDL(3 downto 0) <= std_logic_vector(to_unsigned(outPoint, 4));
	LEDR(3 downto 0) <= std_logic_vector(to_unsigned(Win_Lose, 4));			
	--LEDG(8) <= std_logic_vector(to_unsigned(outPoint, 4));
	
	
end architecture struct;