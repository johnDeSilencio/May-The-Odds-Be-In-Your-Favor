library ieee;
use ieee.std_logic_1164.all;

entity lcd_driver is
    port(
        count:      in std_logic_vector(3 downto 0);
		CLK:        in std_logic;
		LCD_DATA:   out std_logic_vector(7 downto 0);
		LCD_EN:     out std_logic;
		LCD_RW:     out std_logic;
		LCD_RS:     out std_logic;
		LCD_ON:     out std_logic
    );
end entity lcd_driver;

architecture rtl of lcd_driver is
begin
    process (CLK)
    begin
        
    end process;
end architecture rtl;