library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataMemory is
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (15 downto 0);
           writeData: in STD_LOGIC_VECTOR (15 downto 0);
           memData : out STD_LOGIC_VECTOR (15 downto 0));
end DataMemory;

architecture Behavioral of DataMemory is
    type ram_type is array(0 to 255) of std_logic_vector(15 downto 0);
    signal ram: ram_type := (others => x"0000");
begin

    process (clk)
    begin
        if clk'event and clk = '1' then
            if we = '1' then
                ram(conv_integer(addr(7 downto 0))) <= writeData;
            end if;
        end if;
    end process;
    
    memData <= ram( conv_integer(addr(7 downto 0)));

end Behavioral;
