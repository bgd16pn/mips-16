library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrFetch is
    Port ( clk : in STD_LOGIC;
           enable: in STD_LOGIC;
           rst: in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Jump : in STD_LOGIC;
           JumpReg : in STD_LOGIC;
           JumpAddr : in STD_LOGIC_VECTOR (15 downto 0);
           BranchAddr : in STD_LOGIC_VECTOR (15 downto 0);
           JumpRegAddr : in STD_LOGIC_VECTOR (15 downto 0);
           Instruction : out STD_LOGIC_VECTOR (15 downto 0);
           NextPC : out STD_LOGIC_VECTOR (15 downto 0) );
end InstrFetch;

architecture Behavioral of InstrFetch is
    
    constant NOP : std_logic_vector(15 downto 0) := x"0000";
    type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
    
-- FIBONACCI
    signal rom : rom_type := (B"001_000_001_0000001",  -- ADDI $1, $0, 1
                              B"001_000_010_0000001",  -- ADDI $2, $0, 1
                              B"001_000_011_0000100",  -- ADDI $3, $0, 4
                              NOP,
                              NOP,
                              B"000_001_010_100_0_000",-- ADD $4, $1, $2
                              B"001_010_001_0000000",  -- ADDI $1, $2, 0
                              NOP,
                              NOP,
                              B"001_100_010_0000000",  -- ADDI $2, $4, 0
                              B"001_011_011_1111111",  -- ADDI $3, $3, -1
                              NOP,
                              NOP,
                              B"110_011_000_1110111",  -- BGEZ $3, -9
                              NOP,
                              NOP,
                              NOP,
                              B"011_000_001_0000000",  -- SW $1, 0($0)
                              B"011_000_010_0000001",  -- SW $2, 1($0)
                              B"011_000_100_0000010",  -- SW $4, 2($0)
                              B"010_000_001_0000001",  -- LW $1, 1($0)
                              NOP,
                              NOP,
                              B"001_001_001_0000000",  -- ADDI $1, $1, 0
                              NOP,
                              NOP,
                              B"111_0000000000000",    -- J 0
                              NOP,
                              others => x"0000");

    signal currentPc, pcinc, auxPc : std_logic_vector(15 downto 0) := (others => '0');
    signal sel : std_logic_vector(2 downto 0) := "000";                
                         
begin

    sel <= JumpReg & Jump & PCSrc;
    pcinc <= currentPc + 1; 
    NextPC <= pcinc;

    Instruction <= rom(conv_integer(currentPc(7 downto 0)));

program_counter: process(clk, enable, rst)
    begin
        if rst = '1' then
            currentPc <= (others => '0');
        else
            if clk'event and clk = '1' then
                if enable = '1' then
                    currentPc <= auxPc;
                end if;
            end if;
        end if;
end process program_counter;

next_pc: process(sel, pcinc, BranchAddr, JumpAddr, JumpRegAddr)
    begin
        case sel is
            when "000" => auxPc <= pcinc;
            when "001" => auxPc <= BranchAddr;
            when "010" => auxPc <= JumpAddr;
            when "011" => auxPc <= JumpAddr;
            when "100" => auxPc <= JumpRegAddr;
            when "101" => auxPc <= JumpRegAddr;
            when "110" => auxPc <= JumpRegAddr;
            when "111" => auxPc <= JumpRegAddr;
            when others => auxPc <= (others => '0'); 
        end case;
end process next_pc;

end Behavioral;
