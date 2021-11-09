library ieee;
use ieee.std_logic_1164.all;

entity testLogic_tb is
    -- empty
end entity testLogic_tb;

architecture beh of testLogic_tb is
    
    component testLogic
            port(
                Clock       : in std_logic;
                n_RST	    : in std_logic;
                roll1       : in integer;
                roll2       : in integer;
                WinLoseNA   : out integer
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
    signal win_lose_na  : integer;
    
    
    begin -- beh
    
    --mapping
    inst_testLogic: testLogic
        port map(
            Clock => ck,
            n_RST => n_rst,
            roll1 => die_1,
            roll2 => die_2,
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
        -- test that the loading of the starting count value works well
        --
        procedure run_all_test_logic_possibilities is
        begin
            for first_dice_roll in 1 to 6 loop
                for second_dice_roll in 1 to 6 loop
                    wait_tb_ck;
                    die_1 <= first_dice_roll;
                    die_2 <= second_dice_roll;
                    wait_ck;
                end loop;
            end loop;
        end run_all_test_logic_possibilities;
    
    begin -- testbench process
    
        
        initialize_tb;
        reset_tb;

        -- make sure edges are detected correctly
        run_all_test_logic_possibilities;

    
        assert false
        report "End of Simulation"
        severity failure;
    
    
    end process test_bench;
end beh;
