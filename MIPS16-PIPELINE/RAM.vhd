library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           en : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (3 downto 0);
           di : in STD_LOGIC_VECTOR (15 downto 0);
           do : out STD_LOGIC_VECTOR (15 downto 0));
end RAM;

architecture Behavioral of RAM is

    type ram_type is array(0 to 15) of std_logic_vector(15 downto 0);
    signal ram: ram_type := (x"0001", x"0002", x"0003", x"0004", others => x"0000");

begin

    process (clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                if we = '1' then
                    ram(conv_integer(addr)) <= di;
                    do <= di;
                else
                    do <= ram( conv_integer(addr));
                end if;
            end if;
        end if;
    end process;
   
end Behavioral;
