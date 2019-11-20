library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrDecode is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           Instruction : in STD_LOGIC_VECTOR (15 downto 0);
           WA : in STD_LOGIC_VECTOR (2 downto 0);
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           extOp : in STD_LOGIC;
           regWrite : in STD_LOGIC;
           rd1 : out STD_LOGIC_VECTOR (15 downto 0);
           rd2 : out STD_LOGIC_VECTOR (15 downto 0);
           extImm : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out STD_LOGIC);
end InstrDecode;

architecture Behavioral of InstrDecode is

    component RegisterFile is
    Port ( clk : in STD_LOGIC;
           ra1 : in STD_LOGIC_VECTOR (2 downto 0);
           ra2 : in STD_LOGIC_VECTOR (2 downto 0);
           wa : in STD_LOGIC_VECTOR (2 downto 0);
           wd : in STD_LOGIC_VECTOR (15 downto 0);
           wen : in STD_LOGIC;
           rd1 : out STD_LOGIC_VECTOR (15 downto 0);
           rd2 : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    signal regWriteEnable : std_logic := '0';
begin
    
    regWriteEnable <= regWrite and enable;
    sa <= Instruction(3);
    func <= Instruction(2 downto 0);
    
    RF : RegisterFile port map (clk => clk, ra1 => Instruction(12 downto 10), 
                                ra2 => Instruction(9 downto 7), wa => WA,
                                wd => WD, wen => regWriteEnable,
                                rd1 => rd1, rd2 => rd2);                
                                                             
mux_ext_op: process(Instruction(6 downto 0), extOp)
             begin
                if extOp = '1' and Instruction(6) = '1' then
                    extImm <= B"111111111" & Instruction(6 downto 0);
                else
                    extImm <= B"000000000" & Instruction(6 downto 0);
                end if;
end process mux_ext_op;

end Behavioral;
