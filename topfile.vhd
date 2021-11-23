library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topfile is
	port(
		KEY   :	in std_logic_vector(3 downto 0);
		CLOCK_50    :   in std_logic;
		LED	:	out std_logic_vector(3 downto 0);
		LEDL	:	out std_logic_vector(3 downto 0);
		LEDR	:	out std_logic_vector(3 downto 0);
        
        -- LCD specific I/O
        RS          : out std_logic; -- REGISTER
        SELECTRW    : out std_logic; -- read/write
        EN          : out std_logic; -- enable
        LCD_ON      : out std_logic; -- lcd power ON
        DB          : out std_logic_vector(7 DOWNTO 0) -- parallel data input
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
            WinLoseNA: out integer
        );
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
    
    component lcd_driver
        port(
            clk         : in std_logic; -- clock
            rst         : in std_logic; -- reset
            rs          : out std_logic; -- REGISTER
            selectrw    : out std_logic; -- read/write
            en          : out std_logic; -- enable
            lcd_on      : out std_logic; -- lcd power ON
            db          : out std_logic_vector(7 DOWNTO 0)
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
							orr,
							DIE_1,
							DIE_2,
							newRoll);
	
	
	logic1: testLogic port map(
							CLOCK_50,
							KEY(0),
							DIE_1,
							DIE_2,
							newRoll,
							reset_sig,
							outPoint,
							outRoll,
							Win_Lose);
                            
    isnt_lcd_driver : lcd_driver port map(
                            clk => CLOCK_50,
                            rst => KEY(0),
                            rs  => RS,        
                            selectrw => SELECTRW,  
                            en => EN,
                            lcd_on => LCD_ON,   
                            db => DB,
                            
                            -- Game logic specific I/O
                            win_lose_na => Win_Lose,
                            point => outpoint,
                            die_roll_1 => DIE_1,
                            die_roll_2 => DIE_2,
                            roll => outRoll);
	
	LED(3 downto 0) <= std_logic_vector(to_unsigned(outRoll, 4));
	LEDL(3 downto 0) <= std_logic_vector(to_unsigned(outPoint, 4));
	LEDR(1 downto 0) <= std_logic_vector(to_unsigned(Win_Lose, 2));			
	orr <= KEY(0) and reset_sig;
	
	
end architecture struct;