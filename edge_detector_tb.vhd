library ieee;
use ieee.std_logic_1164.all;

entity edge_detector_tb is
    -- empty
end entity edge_detector_tb;

architecture beh of edge_detector_tb is
    
    component edge_detector
            port(
                    CLK         :   in std_logic;
                    n_RST       :   in std_logic;
                    SIN         :   in std_logic;
                    POS_EDGE    :   out std_logic;
                    NEG_EDGE    :   out std_logic
            );
    end component edge_detector;
    
    --constant declaration
    constant period_c      : time := 20 ns; -- 50 MHz clock
    constant probe_c       : time := 4 ns; --probe signals 4 ns before the end of the cycle
    constant tb_skew_c     : time := 1 ns;
    constant severity_c    : severity_level := warning;
    
    --signal declaration
    signal tb_ck    : std_logic;
    signal ck       : std_logic;
    signal n_rst    : std_logic;
    signal sin      : std_logic;
    signal pos_edge : std_logic;
    signal neg_edge : std_logic;
    
    begin -- beh
    
    --mapping
    inst_edge_detector: edge_detector
        port map(
            CLK => ck,
            n_RST => n_rst,
            SIN => sin,
            POS_EDGE => pos_edge,
            NEG_EDGE => neg_edge
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
            sin         <= '1';
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
        procedure run_button_press_test is
        begin
            wait_tb_ck;
            wait_ck(2);
            
            wait_tb_ck;
            check_exp_val(pos_edge, '0');
            check_exp_val(neg_edge, '0');
            sin <= '0';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(pos_edge, '0');
            check_exp_val(neg_edge, '1');
            wait_ck(2);
            
            wait_tb_ck;
            check_exp_val(pos_edge, '0');
            check_exp_val(neg_edge, '0');
            sin <= '1';
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(pos_edge, '1');
            check_exp_val(neg_edge, '0');
            wait_ck;
            
            wait_tb_ck;
            check_exp_val(pos_edge, '0');
            check_exp_val(neg_edge, '0');
            wait_ck(2);
        end run_button_press_test;
    
    begin -- testbench process
    
        
        initialize_tb;
        reset_tb;

        -- make sure edges are detected correctly
        run_button_press_test;

    
        assert false
        report "End of Simulation"
        severity failure;
    
    
    end process test_bench;
end beh;
