library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrDecode is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR (15 downto 0);
           wd : in STD_LOGIC_VECTOR (15 downto 0);
           regWrite : in STD_LOGIC;
           regDst : in STD_LOGIC;
           extOp : in STD_LOGIC;
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
    
    signal writeAddr : std_logic_vector(2 downto 0);
    signal regWriteEnable : std_logic;
begin
    
    regWriteEnable <= regWrite and enable;
    sa <= instr(3);
    func <= instr(2 downto 0);
    
    RF : RegisterFile port map (clk => clk, ra1 => instr(12 downto 10), 
                                ra2 => instr(9 downto 7), wa => writeAddr,
                                wd => wd, wen => regWriteEnable,
                                rd1 => rd1, rd2 => rd2);                
                                
mux_reg_dst: process(instr(9 downto 7), instr(6 downto 4), regDst)
             begin
                if regDst = '0' then
                    writeAddr <= instr(9 downto 7);
                else
                    writeAddr <= instr(6 downto 4);
                end if;
end process mux_reg_dst;

                                
mux_ext_op: process(instr(6 downto 0), extOp)
             begin
                if extOp = '1' and instr(6) = '1' then
                    extImm <= B"111111111" & instr(6 downto 0);
                else
                    extImm <= B"000000000" & instr(6 downto 0);
                end if;
end process mux_ext_op;

end Behavioral;
