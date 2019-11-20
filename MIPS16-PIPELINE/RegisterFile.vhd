library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
    Port ( clk : in STD_LOGIC;
           ra1 : in STD_LOGIC_VECTOR (2 downto 0);
           ra2 : in STD_LOGIC_VECTOR (2 downto 0);
           wa : in STD_LOGIC_VECTOR (2 downto 0);
           wd : in STD_LOGIC_VECTOR (15 downto 0);
           wen : in STD_LOGIC;
           rd1 : out STD_LOGIC_VECTOR (15 downto 0);
           rd2 : out STD_LOGIC_VECTOR (15 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

    type reg_type is array(0 to 7) of std_logic_vector(15 downto 0);
    signal rf: reg_type := (others => x"0000");

begin
    register_file: process(clk)
    begin
        if clk'event and clk = '0' then
            if wen = '1' then
                rf(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process register_file;

    rd1 <= rf(conv_integer(ra1));
    rd2 <= rf(conv_integer(ra2));  

end Behavioral;
