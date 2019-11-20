library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ExecutionUnit is
    Port ( rd1 : in STD_LOGIC_VECTOR (15 downto 0);
           rd2 : in STD_LOGIC_VECTOR (15 downto 0);
           extImm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           aluSrc : in STD_LOGIC;
           aluOp : in STD_LOGIC_VECTOR (1 downto 0);
           nextPc: in STD_LOGIC_VECTOR(15 downto 0);
           zero : out STD_LOGIC;
           gtz : out STD_LOGIC;
           aluRes : out STD_LOGIC_VECTOR (15 downto 0);
           branchAddress: out STD_LOGIC_VECTOR(15 downto 0));
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

    signal aluCtrl: STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal tempRes, secondOp: STD_LOGIC_VECTOR(15 downto 0) := x"0000";

begin
   
    secondOp <= rd2 when aluSrc = '0' else extImm;
    zero <= '1' when tempRes = x"0000" else '0';
    gtz <= '0' when rd1(15) = '1' else '1';
    aluRes <= tempRes;
    branchAddress <= nextPc + extImm;
    
alu: process(rd1, secondOp, sa, aluCtrl)
    begin
        case aluCtrl is
            when "000" => tempRes <= rd1 + secondOp;
            when "001" => tempRes <= rd1 and secondOp;
            when "010" => tempRes <= rd1 or secondOp;
            when "011" => tempRes <= rd1 xor secondOp;
            when "100" => tempRes <= rd1 - secondOp;
            when "101" => if sa = '1' then
                                tempRes <= rd1(14 downto 0) & '0';
                           else
                                tempRes <= rd1;
                           end if;
                           
            when "110" => if sa = '1' then
                               tempRes <= '0' & rd1(15 downto 1);
                           else
                               tempRes <= rd1;
                           end if;
			when others => tempRes <= rd1 - secondOp;
        end case;
end process alu;

alu_control: process(func, aluOp)
    begin
        case aluOp is
            when "00" => aluCtrl <= "000";
            when "01" => aluCtrl <= "010";
            when "10" => case func is
                            when "000" => aluCtrl <= "000";
                            when "001" => aluCtrl <= "100";
                            when "010" => aluCtrl <= "101";
                            when "011" => aluCtrl <= "110";
                            when "100" => aluCtrl <= "001";
                            when "101" => aluCtrl <= "010";  
                            when "110" => aluCtrl <= "011";
							when others => aluCtrl <= "001";
                         end case;
            when "11" => aluCtrl <= "100";
			when others => aluCtrl <= "000";
        end case;
end process alu_control;
    

end Behavioral;
