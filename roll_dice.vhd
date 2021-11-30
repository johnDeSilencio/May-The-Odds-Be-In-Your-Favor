library ieee;
use ieee.std_logic_1164.all;

entity roll_dice is
	port(
		CLK		   : in std_logic;
		RB         : in std_logic;
        n_RST      : in std_logic;
        DIE_1      : out integer;
        DIE_2      : out integer;
        NEW_ROLL   : out std_logic -- goes high for two clock cycles when rolls are decided
	);
end entity roll_dice;

architecture rtl of roll_dice is

    component edge_detector
        port(
            CLK         :   in std_logic;
            n_RST       :   in std_logic;
            SIN         :   in std_logic;
            POS_EDGE    :   out std_logic;
            NEG_EDGE    :   out std_logic
        );
    end component edge_detector;

	component counter
        generic(
            count_from : integer
		);
        
        port(
            n_RST   :   in std_logic;
            CLK     :   in std_logic;
            ENABLE  :   in std_logic;
            COUNT   :   out integer
        );
    end component counter;

    -- signal declaration
    signal pos_edge     :   std_logic;
    signal neg_edge     :   std_logic;
    signal die_1_roll   :   integer;
    signal die_2_roll   :   integer;
    
    -- FSM
    type state_type is (rolling_first_die, rolling_second_die, not_rolling);
    signal state, next_state : state_type;
    signal next_die_1, next_die_2 : integer;
    signal die_1_reg, die_2_reg : integer;
    signal next_new_roll, curr_new_roll : std_logic;
    
begin

    inst_edge_detector : edge_detector
        port map(
            n_RST => n_RST,
            CLK => CLK,
            SIN => RB,
            POS_EDGE => pos_edge,
            NEG_EDGE => neg_edge
        );

	die_1_counter : counter
        generic map(
            count_from => 6
        )
       
        port map(
            n_RST => n_RST,
            CLK => CLK,
            ENABLE => '1', -- always keep counting
            COUNT => die_1_roll
        );
    
    die_2_counter : counter
        generic map(
            count_from => 6
        )
        
        port map(
            n_RST => n_RST,
            CLK => CLK,
            ENABLE => '1', -- always keep counting
            COUNT => die_2_roll
        );

    next_state_logic : process(state, pos_edge, neg_edge, die_1_reg, die_2_reg, curr_new_roll)
	begin
        -- defaults to preserve state
        next_state <= state;
        next_die_1 <= die_1_reg;
        next_die_2 <= die_2_reg;
        next_new_roll <= curr_new_roll;
        
        -- when there is a negative edge, store the first dice roll
        -- when there is a positive edge, store the second dice roll
        
        case state is
            when rolling_first_die =>
                if (neg_edge = '1') then
                    next_state <= rolling_second_die;
                    next_die_1 <= die_1_roll;
                    next_new_roll <= '0';
                else
                    -- do nothing
                end if;
            when rolling_second_die =>
                if (pos_edge = '1') then
                    next_state <= not_rolling;
                    next_die_2 <= die_2_roll;
                    next_new_roll <= '1';
                else
                    -- do nothing
                end if;
            when others =>
                -- state = not_rolling
                next_new_roll <= '0';
        end case;
	end process next_state_logic;
    
    reg_logic : process(n_RST, CLK)
    begin
        if (n_RST <= '0') then
            state <= rolling_first_die;
            die_1_reg <= 0;
            die_2_reg <= 0;
            curr_new_roll <= '0';
        elsif (CLK = '1' and CLK'event) then
            state <= next_state;
            die_1_reg <= next_die_1;
            die_2_reg <= next_die_2;
            curr_new_roll <= next_new_roll;
        end if;
    end process reg_logic;
    
    -- dummy assignments
    DIE_1 <= die_1_reg;
    DIE_2 <= die_2_reg;
    NEW_ROLL <= curr_new_roll;
    
end architecture rtl;
		