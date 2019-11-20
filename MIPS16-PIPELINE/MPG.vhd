library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is
    signal cnt : std_logic_vector(15 downto 0) := (others => '0');
    signal Q1, Q2, Q3 : std_logic := '0';
begin
    
    process(clk)
    begin      
        if (clk'event and clk = '1') then
            cnt <= cnt + 1;
        end if;
    end process;
    
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if cnt(15 downto 0) = x"1111" then
                Q1 <= btn;
            end if;
        end if;
    end process;
    
    process(clk)
        begin      
            if (clk'event and clk = '1') then
                Q2 <= Q1;
                Q3 <= Q2;
            end if;
    end process;

    enable <= Q2 and (not Q3);

end Behavioral;
