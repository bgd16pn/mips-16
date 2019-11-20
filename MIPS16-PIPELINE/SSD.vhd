library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port ( clk : in STD_LOGIC;
           digit : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
    
    signal counter : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal sel: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal hex_digit: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

    sel <= counter(15 downto 14);

    freq_div: process(clk)
    begin
        if clk'event and clk = '1' then
            counter <= counter + 1;
        end if;
    end process freq_div;
    
    mux: process(digit, sel)
    begin
        case sel is
            when "00" => hex_digit <= digit(3 downto 0); an <= "1110";
            when "01" => hex_digit <= digit(7 downto 4); an <= "1101"; 
            when "10" => hex_digit <= digit(11 downto 8); an <= "1011";
            when "11" => hex_digit <= digit(15 downto 12); an <= "0111";
			when others => hex_digit <= "0000"; an <= "0000";
        end case;
    end process mux;
    
    hex_7_seg: with hex_digit select
      cat<= "1111001" when "0001",   --1
            "0100100" when "0010",   --2
            "0110000" when "0011",   --3
            "0011001" when "0100",   --4
            "0010010" when "0101",   --5
            "0000010" when "0110",   --6
            "1111000" when "0111",   --7
            "0000000" when "1000",   --8
            "0010000" when "1001",   --9
            "0001000" when "1010",   --A
            "0000011" when "1011",   --b
            "1000110" when "1100",   --C
            "0100001" when "1101",   --d
            "0000110" when "1110",   --E
            "0001110" when "1111",   --F
            "1000000" when others;   --0

end Behavioral;
