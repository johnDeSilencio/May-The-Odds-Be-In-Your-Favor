library ieee;
use ieee.std_logic_1164.all;

entity testLogic_tb is
    -- empty
end entity testLogic_tb;

architecture beh of testLogic_tb is
    
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
    end component testLogic;
    
    --constant declaration
    constant period_c      : time := 20 ns; -- 50 MHz clock
    constant probe_c       : time := 4 ns; --probe signals 4 ns before the end of the cycle
    constant tb_skew_c     : time := 1 ns;
    constant severity_c    : severity_level := warning;
    
    --signal declaration
    signal tb_ck        : std_logic;
    signal ck           : std_logic;
    signal n_rst        : std_logic;
    signal die_1        : integer;
    signal die_2        : integer;
    signal new_roll     : std_logic;
    signal point_out    : integer;
    signal roll_out     : integer;
    signal win_lose_na  : integer;
    
    
    begin -- beh
    
    --mapping
    inst_testLogic: testLogic
        port map(
            Clock => ck,
            n_RST => n_rst,
            roll1 => die_1,
            roll2 => die_2,
            newRoll => new_roll,
            pointOUT => point_out,
            rollOUT => roll_out,
            WinLoseNA => win_lose_na
        );
    
    
    -- testbench clock generator
    tb_ck_gen : process
    begin
        tb_ck <= '0';
        wait for period_c/2;
        tb_ck <= '1';
        wait for period_c/2;
    end process;
    
    
    -- system clock generator
    clock_gen : process (tb_ck)
    begin
        ck <= transport tb_ck after tb_skew_c;
    end process;
    
    
    --
    -- the test bench process
    --
    test_bench : process

        --
        -- wait for the rising edge of tb_ck
        --
        procedure wait_tb_ck(num_cyc : integer := 1) is
        begin
        for i in 1 to num_cyc loop
            wait until tb_ck'event and tb_ck = '1';
        end loop;
        end wait_tb_ck;
    
        --
        -- wait for the rising edge of clk
        --
        procedure wait_ck(num_cyc : integer := 1) is
        begin
        for i in 1 to num_cyc loop
            wait until ck'event and ck = '1';
        end loop;
        end wait_ck;
    
        --
        -- check expected value for a std_logic
        --
        procedure check_exp_val(sig_to_test : std_logic; exp_val : std_logic) is
        begin
            if (sig_to_test /= exp_val) then
                assert false
                report "Mismatch Error"
                severity severity_c;
            end if;
        end check_exp_val;
    
        --
        -- check expected value for an integer
        --
        procedure check_exp_val(sig_to_test : integer; exp_val : integer) is
        begin
            if (sig_to_test /= exp_val) then
                assert false
                report "Mismatch Error"
                severity severity_c;
            end if;
        end check_exp_val;

        --
        -- initialize all input signals: nothing must be left floating
        --
        procedure initialize_tb is
        begin
            n_rst       <= '1';
            new_roll    <= '0';
            die_1       <= 0;
            die_2       <= 0;  
        end initialize_tb;
        
        --
        -- reset the tb 
        --
        procedure reset_tb is
        begin
            n_rst <= '1';
            wait for period_c/20;
            n_rst <= '0';
            wait for period_c/20;
            n_rst <= '1';
        end reset_tb;
        
        --
        -- test that a win is properly detected in the first roll
        --
        procedure run_win_conditions_first_roll is
        begin
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll a 7
            die_1 <= 3;
            die_2 <= 4;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '1';
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 2);
            wait_ck;
            
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll an 11
            new_roll <= '1';
            die_1 <= 5;
            die_2 <= 6;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 2);
            wait_ck;
        end run_win_conditions_first_roll;
            
        
        --
        -- test that a lose is properly detected in the first roll
        --
        procedure run_lose_conditions_first_roll is
        begin
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll a 2
            new_roll <= '1';
            die_1 <= 1;
            die_2 <= 1;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 1);
            wait_ck;
            
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll a 3
            new_roll <= '1';
            die_1 <= 1;
            die_2 <= 2;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 1);
            wait_ck;
            
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll a 12
            new_roll <= '1';
            die_1 <= 6;
            die_2 <= 6;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 1);
            wait_ck;
        end run_lose_conditions_first_roll;
        
        
        --
        -- test that the 
        procedure run_win_conditions_second_roll is
        begin
            reset_tb; -- restart game
            
            wait_tb_ck;
            wait_ck;
            
            wait_tb_ck; -- roll a 4
            new_roll <= '1';
            die_1 <= 3;
            die_2 <= 1;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 0);
            wait_ck;
            
            wait_tb_ck; -- roll a 4
            new_roll <= '1';
            die_1 <= 2;
            die_2 <= 2;
            wait_ck;
            
            wait_tb_ck;
            new_roll <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(win_lose_na, 2);
            wait_ck;
        end run_win_conditions_second_roll;
    
    
    begin -- testbench process
    
        
        initialize_tb;
        reset_tb;

        -- test the logic for all win conditions in the first roll
        run_win_conditions_first_roll;
        
        -- test the logic for all lose conditions in the first roll
        run_lose_conditions_first_roll;

        -- test the player winning if the players gets the point again in the second roll
        run_win_conditions_second_roll;
    
        assert false
        report "End of Simulation"
        severity failure;
    
    
    end process test_bench;
end beh;
