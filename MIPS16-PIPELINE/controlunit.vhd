library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ControlUnit is
    Port ( func : in STD_LOGIC_VECTOR (2 downto 0);
           opcode : in STD_LOGIC_VECTOR (2 downto 0);
           regDst : out STD_LOGIC;
           regWrite : out STD_LOGIC;
           extOp : out STD_LOGIC;
           aluSrc : out STD_LOGIC;
           aluOp : out STD_LOGIC_VECTOR(1 downto 0);
           branch : out STD_LOGIC;
           memToReg : out STD_LOGIC;
           memWrite : out STD_LOGIC;
           jump : out STD_LOGIC;
           jumpReg : out STD_LOGIC;
           branchBgez : out STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is

begin
    process(opcode, func)
    begin
        regDst <= '0';
        regWrite <= '0';
        extOp <= '0';
        aluSrc <= '0';
        aluOp <= "00";
        branch <= '0';
        memToReg <= '0';
        memWrite <= '0';
        jump <= '0';
        jumpReg <= '0';
        branchBgez <= '0';
        
        case opcode is
            when "000" =>  if func = "111" then
                                jumpReg <= '1';
                           else
                                regDst <= '1'; 
                                regWrite <= '1';
                           end if;
                           aluOp <= "10";
            when "001" => regWrite <= '1'; aluSrc <= '1'; aluOp <= "00"; extOp <= '1';
            when "010" => regWrite <= '1'; aluSrc <= '1'; memToReg <= '1'; extOp <= '1';
            when "011" => aluSrc <= '1'; memWrite <= '1'; extOp <= '1';
            when "100" => aluOp <= "11"; branch <= '1'; extOp <= '1';
            when "101" => regWrite <= '1'; aluSrc <= '1'; aluOp <= "01";
            when "110" => aluSrc <= '1'; aluOp <= "11"; extOp <= '1'; branchBgez <= '1';
            when "111" => aluOp <= "11"; jump <= '1';
			when others => aluOp <= "11";
        end case;
    end process;

end Behavioral;
