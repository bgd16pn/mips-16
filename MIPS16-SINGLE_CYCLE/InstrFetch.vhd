library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrFetch is
    Port ( PCSrc : in STD_LOGIC;
           Jump : in STD_LOGIC;
           JumpRegister : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (15 downto 0);
           BranchAddress : in STD_LOGIC_VECTOR (15 downto 0);
           JumpRegisterAddress : in STD_LOGIC_VECTOR (15 downto 0);
           Instruction : out STD_LOGIC_VECTOR (15 downto 0);
           PC : out STD_LOGIC_VECTOR (15 downto 0);
           NextPC : out STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           enable: in STD_LOGIC;
           rst: in STD_LOGIC);
end InstrFetch;

architecture Behavioral of InstrFetch is

    type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
    
-- FIBONACCI
    signal rom : rom_type := (B"001_000_001_0000001",  -- ADDI $1, $0, 1
                              B"001_000_010_0000001",  -- ADDI $2, $0, 1
                              B"001_000_011_0000100",  -- ADDI $3, $0, 4
                              B"000_001_010_100_0_000",-- ADD $4, $1, $2
                              B"001_010_001_0000000",  -- ADDI $1, $2, 0
                              B"001_100_010_0000000",  -- ADDI $2, $4, 0
                              B"001_011_011_1111111",  -- ADDI $3, $3, -1
                              B"110_011_000_1111011",  -- BGEZ $3, -5
                              B"011_000_001_0000000",  -- SW $1, 0($0)
                              B"011_000_010_0000001",  -- SW $2, 1($0)
                              B"011_000_100_0000010",  -- SW $4, 2($0)
                              B"010_000_001_0000001",  -- LW $1, 1($0)
                              B"001_001_001_0000000",  -- ADDI $1, $1, 0
                              B"111_0000000000000",    -- J 0
                              others => x"0000");

--    signal rom : rom_type := (x"2083", x"2104", x"0530", others => x"0000");

--    signal rom : rom_type := (x"2201", x"0030", x"0010", x"4D00", x"8104", x"0510", x"0A21", x"E004",
--                              x"6C81", x"2107", x"4E81", x"145A", x"1550", x"6E82", others => x"0000");
    signal currentPc, pcinc, aux : std_logic_vector(15 downto 0) := (others => '0');
    signal sel : std_logic_vector(2 downto 0) := "000";                
                         
begin

sel <= JumpRegister & Jump & PCSrc;
pcinc <= currentPc + 1; 
NextPC <= pcinc;
pc <= currentPc;

program_counter: process(clk, enable, rst)
    begin
        if rst = '1' then
            currentPc <= (others => '0');
        else
            if clk'event and clk = '1' then
                if enable = '1' then
                    currentPc <= aux;
                end if;
            end if;
        end if;
end process program_counter;

Instruction <= rom(conv_integer(currentPc(7 downto 0)));

next_pc: process(sel, pcinc, BranchAddress, JumpAddress, JumpRegisterAddress)
    begin
        case sel is
            when "000" => aux <= pcinc;
            when "001" => aux <= BranchAddress;
            when "010" => aux <= JumpAddress;
            when "011" => aux <= JumpAddress;
            when "100" => aux <= JumpRegisterAddress;
            when "101" => aux <= JumpRegisterAddress;
            when "110" => aux <= JumpRegisterAddress;
            when "111" => aux <= JumpRegisterAddress;
            when others => aux <= (others => '0'); 
        end case;
end process next_pc;

end Behavioral;
