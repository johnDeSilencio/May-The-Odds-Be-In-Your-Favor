library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port(
        CLK         :   in std_logic;
        n_RST       :   in std_logic;
        SIN         :   in std_logic;
        POS_EDGE    :   out std_logic;
        NEG_EDGE    :   out std_logic
    );
end entity edge_detector;

architecture rtl of edge_detector is

    -- FSM
    type state_type is (neg_edge_state, pos_edge_state, low_state, high_state);
    signal state, next_state : state_type;

begin
    next_state_logic : process(state, SIN)
	begin
        -- defaults to preserve state
        next_state <= state;
        
        case state is
            when neg_edge_state =>
                POS_EDGE <= '0';
                NEG_EDGE <= '1';
                
                if (SIN = '1') then
                    next_state <= pos_edge_state;
                else
                    -- SIN = '0'
                    next_state <= low_state;
                end if;
            when pos_edge_state =>
                POS_EDGE <= '1';
                NEG_EDGE <= '0';
                
                if (SIN = '1') then
                    next_state <= high_state;
                else
                    -- SIN = '0'
                    next_state <= neg_edge_state;
                end if;
            when high_state =>
                POS_EDGE <= '0';
                NEG_EDGE <= '0';
            
                if (SIN = '1') then
                    next_state <= high_state;
                else
                    -- SIN = '0'
                    next_state <= neg_edge_state;
                end if;
            when low_state =>
                POS_EDGE <= '0';
                NEG_EDGE <= '0';
                
                if (SIN = '1') then
                    next_state <= pos_edge_state;
                else
                    -- SIN = '0'
                    next_state <= low_state;
                end if;
            when others => -- do nothing
        end case;
	end process next_state_logic;


    reg_logic : process(n_RST, CLK, SIN)
    begin
        if (n_RST = '0') then
            if (SIN = '1') then
                state <= high_state;
            else
                -- SIN = '0'
                state <= low_state;
            end if;
        elsif (CLK = '1' and CLK'event) then
            state <= next_state;
        end if;
    end process reg_logic;
    
end architecture rtl;