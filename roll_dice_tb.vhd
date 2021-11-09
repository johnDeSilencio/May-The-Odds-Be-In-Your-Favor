library ieee;
use ieee.std_logic_1164.all;

entity roll_dice_tb is
    -- empty
end entity roll_dice_tb;

architecture beh of roll_dice_tb is
    
    component roll_dice
            port(
                CLK        : in std_logic;
                RB         : in std_logic;
                n_RST      : in std_logic;
                DIE_1      : out integer;
                DIE_2      : out integer;
                NEW_ROLL   : out std_logic
            );
    end component roll_dice;
    
    --constant declaration
    constant period_c      : time := 20 ns; -- 50 MHz clock
    constant probe_c       : time := 4 ns; --probe signals 4 ns before the end of the cycle
    constant tb_skew_c     : time := 1 ns;
    constant severity_c    : severity_level := warning;
    
    --signal declaration
    signal tb_ck    : std_logic;
    signal ck       : std_logic;
    signal n_rst    : std_logic;
    signal rb       : std_logic;
    signal die_1    : integer;
    signal die_2    : integer;
    signal new_roll : std_logic;
    
    begin -- beh
    
    --mapping
    inst_roll_dice: roll_dice
        port map(
            CLK => ck,
            n_RST => n_rst,
            RB => rb,
            DIE_1 => die_1,
            DIE_2 => die_2,
            NEW_ROLL => new_roll
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
            rb          <= '1';
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
        -- test that the loading of the starting count value works well
        --
        procedure run_roll_dice_test is
        begin
            wait_tb_ck;
            check_exp_val(die_1, 0);
            check_exp_val(die_2, 0);
            wait_ck(10); -- let counters run
            
            wait_tb_ck;
            rb <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(new_roll, '0');
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(die_1, 1); -- hard coded based on chosen wait length
            check_exp_val(die_2, 0);
            wait_ck(68);
            
            wait_tb_ck;
            rb <= '1';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(new_roll, '0');
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(new_roll, '1');
            check_exp_val(die_1, 1);
            check_exp_val(die_2, 3); -- hard coded based on chosen wait length            
            wait_ck(4);
            
            -- make sure output stay the same even if input changes again
            wait_tb_ck;
            rb <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(new_roll, '0');
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(die_1, 1);
            check_exp_val(die_2, 3);
            wait_ck(4);
            
            wait_tb_ck;
            rb <= '1';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(new_roll, '0');
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(die_1, 1);
            check_exp_val(die_2, 3);
            wait_ck(4);
            
        end run_roll_dice_test;
    
    begin -- testbench process
    
        
        initialize_tb;
        reset_tb;

        -- make sure edges are detected correctly
        run_roll_dice_test;

    
        assert false
        report "End of Simulation"
        severity failure;
    
    
    end process test_bench;
end beh;
