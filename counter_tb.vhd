library ieee;
use ieee.std_logic_1164.all;

entity counter_tb is
    --empty
end counter_tb;

architecture beh of counter_tb is
    
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
    
    --constant declaration
    constant period_c      : time := 20 ns; -- 50 MHz clock
    constant probe_c       : time := 4 ns; --probe signals 4 ns before the end of the cycle
    constant tb_skew_c     : time := 1 ns;
    constant severity_c    : severity_level := warning;
    
    --signal declaration
    signal tb_ck    : std_logic;
    signal ck       : std_logic;
    signal n_rst    : std_logic;
    signal enable   : std_logic;
    signal count    : integer;
    
    begin -- beh
    
    --mapping
    inst_counter: counter
        generic map(
            count_from => 6
        )
        
        port map(
            n_RST => n_rst,
            CLK => ck,
            ENABLE => enable,
            COUNT => count
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
            enable      <= '1';
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
        procedure run_counter_test is
        begin
            for i in 1 to 12 loop
                wait_tb_ck;
                check_exp_val(count, (12-i) mod 6 + 1);
                wait_ck;
            end loop;
        end run_counter_test;
        
        --
        -- that the counter properly disables and holds value
        --
        procedure run_disable_test is
        begin
            for i in 0 to 3 loop
                wait_tb_ck;
                check_exp_val(count, (6-i));
                wait_ck;
            end loop;
            
            -- disable counter at value 2
            enable <= '0';
            
            for i in 0 to 2 loop
                wait_tb_ck;
                check_exp_val(count, 2);
                wait_ck;
            end loop;
        end procedure;
    
    
    begin -- testbench process
    
        
        initialize_tb;
        reset_tb;

        -- make sure counter outputs values properly
        run_counter_test;
        
        -- make sure disabling functions properly
        run_disable_test;
    
        assert false
        report "End of Simulation"
        severity failure;
    
    
    end process test_bench;
end beh;

