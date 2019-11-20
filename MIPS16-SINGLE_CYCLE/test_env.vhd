library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led :out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
    component MPG is
        Port ( btn : in STD_LOGIC;
               clk : in STD_LOGIC;
               enable : out STD_LOGIC);
    end component;
    
    component SSD is
        Port ( clk : in STD_LOGIC;
               digit : in STD_LOGIC_VECTOR (15 downto 0);
               an : out STD_LOGIC_VECTOR (3 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    component RegisterFile is
        Port ( clk : in STD_LOGIC;
               ra1 : in STD_LOGIC_VECTOR (3 downto 0);
               ra2 : in STD_LOGIC_VECTOR (3 downto 0);
               wa : in STD_LOGIC_VECTOR (3 downto 0);
               wd : in STD_LOGIC_VECTOR (15 downto 0);
               wen : in STD_LOGIC;
               rd1 : out STD_LOGIC_VECTOR (15 downto 0);
               rd2 : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component InstrFetch is
        Port ( PCSrc : in STD_LOGIC;
               Jump : in STD_LOGIC;
               JumpRegister : in STD_LOGIC;
               JumpAddress : in STD_LOGIC_VECTOR (15 downto 0);
               BranchAddress : in STD_LOGIC_VECTOR (15 downto 0);
               JumpRegisterAddress : in STD_LOGIC_VECTOR (15 downto 0);
               Instruction : out STD_LOGIC_VECTOR (15 downto 0);
               PC : out STD_LOGIC_VECTOR(15 downto 0);
               NextPC : out STD_LOGIC_VECTOR (15 downto 0);
               clk : in STD_LOGIC;
               enable: in STD_LOGIC;
               rst: in STD_LOGIC);
    end component;
    
    component InstrDecode is
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
    end component;
    
    component ControlUnit is
        Port ( func : in STD_LOGIC_VECTOR (2 downto 0);
               opcode : in STD_LOGIC_VECTOR (2 downto 0);
               regDst : out STD_LOGIC;
               regWrite : out STD_LOGIC;
               extOp : out STD_LOGIC;
               aluSrc : out STD_LOGIC;
               aluOp : out STD_LOGIC_VECTOR(1 downto 0);
               branch : out STD_LOGIC;
               memRead : out STD_LOGIC;
               memToReg : out STD_LOGIC;
               memWrite : out STD_LOGIC;
               jump : out STD_LOGIC;
               jumpReg : out STD_LOGIC;
               branchBgez : out STD_LOGIC);
    end component;
    
    component ExecutionUnit is
        Port ( rd1 : in STD_LOGIC_VECTOR (15 downto 0);
               rd2 : in STD_LOGIC_VECTOR (15 downto 0);
               extImm : in STD_LOGIC_VECTOR (15 downto 0);
               sa : in STD_LOGIC;
               func : in STD_LOGIC_VECTOR (2 downto 0);
               aluSrc : in STD_LOGIC;
               aluOp : in STD_LOGIC_VECTOR (1 downto 0);
               pc: in STD_LOGIC_VECTOR(15 downto 0);
               zero : out STD_LOGIC;
               branchBgez : out STD_LOGIC;
               aluRes : out STD_LOGIC_VECTOR (15 downto 0);
               branchAddress: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component DataMemory is
        Port ( clk : in STD_LOGIC;
               we : in STD_LOGIC;
               addr : in STD_LOGIC_VECTOR (15 downto 0);
               writeData: in STD_LOGIC_VECTOR (15 downto 0);
               memData : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
        signal en, rst, zero, pcSrc, jumpRegister : std_logic := '0';
        
        signal nextPc, toSSD, instr, rd1, rd2, writeData, extendedImm, 
               aluRes, branchAddress, jumpAddress, jumpRegisterAddress, 
               pc, memOut : std_logic_vector(15 downto 0) := (others => '0');
               
        signal regWrite, regDst, extOp, sa, aluSrc, branch, branchBgez, 
               memRead, memToReg, memWrite, jump, jumpReg, ctrlBgez : std_logic := '0';
        signal aluOp : std_logic_vector(1 downto 0) := "00";
        signal func : std_logic_vector(2 downto 0) := "000";
        
begin
    MPG_ENABLE_ENABLE : MPG port map (btn => btn(4), clk => clk, enable => en);
    MPG_ENABLE_RESET : MPG port map (btn => btn(2), clk => clk, enable => rst);
    SD : SSD port map (clk => clk, digit => toSSD, an => an, cat => cat);
    
    IFetch : InstrFetch port map (clk => clk, enable => en, rst => rst, PC => pc, NextPC => nextPc, Instruction => instr,
                                    PCSrc => pcSrc, Jump => jump, JumpRegister => jumpReg, 
                                    JumpAddress => jumpAddress, BranchAddress => branchAddress, JumpRegisterAddress => jumpRegisterAddress);
                                                             
    IDecode : InstrDecode port map (clk => clk, enable => en, instr => instr, wd => writeData, regWrite => regWrite,
                                    regDst => regDst, extOp => extOp, rd1 => rd1, rd2 => rd2, extImm => extendedImm,
                                    func => func, sa => sa );                                
                                     
    UC : ControlUnit port map (func => func, opcode => instr(15 downto 13), regDst => regDst, regWrite => regWrite, extOp => extOp, 
                                aluSrc => aluSrc, aluOp => aluOp, branch => branch, memRead => memRead, 
                                memToReg => memToReg, memWrite => memWrite, jump => jump, jumpReg => jumpReg, branchBgez => ctrlBgez);                       
    
    EX : ExecutionUnit port map(rd1 => rd1, rd2 => rd2, extImm => extendedImm, sa => sa, func => func, aluSrc => aluSrc,
                                aluOp => aluOp, pc => pc, zero => zero, branchBgez => branchBgez, aluRes => aluRes, branchAddress => branchAddress);
    
    MEM : DataMemory port map(clk => clk, we => memWrite, addr => aluRes, writeData => rd2, memData => memOut);
        
    writeData <= memOut when memToReg = '1' else aluRes;
    
    pcSrc <= (branch and zero) or (branchBgez and ctrlBgez);
    jumpAddress <= "000" & instr(12 downto 0);
    jumpRegisterAddress <= rd1;
    
    led(15 downto 1) <= regDst & regWrite & aluSrc & memRead & memWrite & memToReg & aluOp & extOp & branch & ctrlBgez & jump & jumpReg & zero & branchBgez;           
    
    alu_mux: process(sw(2 downto 0), instr, nextPc, rd1, rd2, writeData, extendedImm, aluRes, memOut)
    begin
        case sw(2 downto 0) is 
            when "000" => toSSD <= instr;
            when "001" => toSSD <= nextPc;
            when "010" => toSSD <= rd1;
            when "011" => toSSD <= rd2;
            when "100" => toSSD <= extendedImm;
            when "101" => toSSD <= aluRes;
            when "110" => toSSD <= memOut;
            when "111" => toSSD <= writeData;
            when others => toSSD <= instr;
        end case;
    end process alu_mux;
    
end Behavioral;
