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
    end component;
    
    component InstrDecode is
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
               nextPc: in STD_LOGIC_VECTOR(15 downto 0);
               zero : out STD_LOGIC;
               gtz : out STD_LOGIC;
               aluRes : out STD_LOGIC_VECTOR (15 downto 0);
               branchAddress: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component DataMemory is
        Port ( clk : in STD_LOGIC;
               enable : in STD_LOGIC;
               addr : in STD_LOGIC_VECTOR (15 downto 0);
               writeData: in STD_LOGIC_VECTOR (15 downto 0);
               memData : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
        signal en, rst, zero, gtz, pcSrc, jumpRegister : std_logic := '0';
        
        signal RegIF_ID : std_logic_vector(31 downto 0) := (others => '0');
        signal RegID_EX : std_logic_vector(82 downto 0) := (others => '0');
        signal RegEX_MEM : std_logic_vector(57 downto 0) := (others => '0');
        signal RegMEM_WB : std_logic_vector(36 downto 0) := (others => '0');

        signal nextPc, toSSD, Instruction, rd1, rd2, extendedImm, 
               aluRes, branchAddr, jumpAddr, jumpRegAddr, 
               memData, branchAddrAux, wd : std_logic_vector(15 downto 0) := (others => '0');
               
        signal regWrite, regDst, extOp, sa, aluSrc, branch, 
               memToReg, memWrite, jump, jumpReg, bgez : std_logic := '0';
        signal aluOp : std_logic_vector(1 downto 0) := "00";
        signal func : std_logic_vector(2 downto 0) := "000";
        
begin
    MPG_ENABLE_ENABLE : MPG port map (btn => btn(4), clk => clk, enable => en);
    MPG_ENABLE_RESET : MPG port map (btn => btn(2), clk => clk, enable => rst);
    SD : SSD port map (clk => clk, digit => toSSD, an => an, cat => cat);
    
    IFetch : InstrFetch port map (clk => clk, 
                                  enable => en, 
                                  rst => rst, 
                                  NextPC => nextPc, 
                                  Instruction => instruction,
                                  PCSrc => pcSrc,
                                  Jump => jump, 
                                  JumpReg => jumpReg, 
                                  JumpAddr => jumpAddr, 
                                  BranchAddr => branchAddr, 
                                  JumpRegAddr => jumpRegAddr);
    
    IDecode : InstrDecode port map (clk => clk, 
                                    enable => en, 
                                    instruction => RegIF_ID(15 downto 0), 
                                    wa => RegMEM_WB(2 downto 0),
                                    wd => wd,
                                    extOp => extOp,
                                    regWrite => RegMEM_WB(35), 
                                    rd1 => rd1, 
                                    rd2 => rd2,
                                    extImm => extendedImm,
                                    func => func, 
                                    sa => sa );                                
                                                                                                   
    UC : ControlUnit port map (func => func, 
                               opcode => RegIF_ID(15 downto 13), -- opcode
                               regDst => regDst, 
                               regWrite => regWrite, 
                               extOp => extOp, 
                               aluSrc => aluSrc, 
                               aluOp => aluOp, 
                               branch => branch, 
                               memToReg => memToReg, 
                               memWrite => memWrite, 
                               jump => jump, 
                               jumpReg => jumpReg, 
                               branchBgez => bgez);
    
    EX : ExecutionUnit port map(rd1 => RegID_EX(57 downto 42),
                                rd2 => RegID_EX(41 downto 26),
                                extImm => RegID_EX(25 downto 10), 
                                sa => RegID_EX(0), 
                                func => RegID_EX(9 downto 7),
                                aluSrc => RegID_EX(75),
                                aluOp => RegID_EX(77 downto 76),
                                nextPc => RegID_EX(73 downto 58),
                                zero => zero, 
                                gtz => gtz,
                                aluRes => aluRes, 
                                branchAddress => branchAddrAux);
    
    MEM : DataMemory port map(clk => clk, 
                              enable => RegEX_MEM(55),
                              addr => RegEX_MEM(34 downto 19),
                              writeData => RegEX_MEM(18 downto 3),
                              memData => memData);
    
    with RegMEM_WB(36) select 
        wd <= RegMEM_WB(34 downto 19) when '1',
              RegMEM_WB(18 downto 3) when '0',
              (others => '0') when others; -- memData when memToReg='1' else aluRes 
               
    branchAddr <= RegEX_MEM(52 downto 37);                                           
    pcSrc <= (RegEX_MEM(36) and RegEX_MEM(54)) or (RegEX_MEM(35) and RegEX_MEM(53)); -- zero and branch or branchBgez and ctrlBgez
    jumpAddr <= "000" & RegIF_ID(12 downto 0);  -- target addr
    jumpRegAddr <= rd1;
    
    led(13 downto 0) <= aluOp & regDst & extOp & aluSrc & zero & branch & gtz & bgez & jump & jumpReg & memWrite & memToReg & regWrite;
                                                                        
if_id_reg:process(clk)
    begin 
        if clk'event and clk = '1' then
            if en = '1' then
                RegIF_ID(31 downto 16) <= nextPc;
                RegIF_ID(15 downto 0) <= instruction;
            end if;
        end if;
    end process if_id_reg;                                   
                                                                               

id_ex_reg:process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                RegID_EX(82 downto 81) <= memToReg & regWrite;
                RegID_EX(80 downto 78) <= memWrite & branch & bgez;
                RegID_EX(77 downto 76) <= aluOp;
                RegID_EX(75 downto 74) <= aluSrc & regDst;
                RegID_EX(73 downto 58) <= RegIF_ID(31 downto 16); -- nextPc
                RegID_EX(57 downto 42) <= rd1;
                RegID_EX(41 downto 26) <= rd2;
                RegID_EX(25 downto 10) <= extendedImm;
                RegID_EX(9 downto 7) <= func; -- func
                RegID_EX(6 downto 4) <= RegIF_ID(9 downto 7); -- rt
                RegID_EX(3 downto 1) <= RegIF_ID(6 downto 4); -- rd
                RegID_EX(0) <= RegIF_ID(3); -- sa
            end if;
        end if;
end process id_ex_reg;
                   
mux_reg_dst: process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                if RegID_EX(74) = '0' then
                    RegEX_MEM(2 downto 0) <= RegID_EX(6 downto 4);  -- wa <= rt
                else
                    RegEX_MEM(2 downto 0) <= RegID_EX(3 downto 1); -- wa <= rd
                end if;
             end if;
         end if;
end process mux_reg_dst;                   
                                  
ex_mem_reg:process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                RegEX_MEM(57 downto 56) <= RegID_EX(82 downto 81); -- memToReg & regWrite
                RegEX_MEM(55 downto 53) <= RegID_EX(80 downto 78); -- memWrite & branch & bgez
                RegEX_MEM(52 downto 37) <= branchAddrAux;
                RegEX_MEM(36 downto 35) <= zero & gtz;
                RegEX_MEM(34 downto 19) <= aluRes;
                RegEX_MEM(18 downto 3) <= RegID_EX(41 downto 26); -- rd2
            end if;
        end if;
end process ex_mem_reg;    
                                                                
mem_wb_reg:process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                RegMEM_WB(36 downto 35) <= RegEX_MEM(57 downto 56); -- memToReg & regWrite
                RegMEM_WB(34 downto 19) <= memData;
                RegMEM_WB(18 downto 3) <= RegEX_MEM(34 downto 19); -- aluRes
                RegMEM_WB(2 downto 0) <= RegEX_MEM(2 downto 0); -- wa
            end if;
        end if;
end process mem_wb_reg;  
                                         
alu_mux: process(sw(2 downto 0), Instruction, nextPc, rd1, rd2, extendedImm, aluRes, memData)
    begin
        case sw(2 downto 0) is 
            when "000" => toSSD <= Instruction; -- instr
            when "001" => toSSD <= nextPc; -- nextPc
            when "010" => toSSD <= rd1; -- rd1
            when "011" => toSSD <= rd2; -- rd2
            when "100" => toSSD <= extendedImm;  -- extImm
            when "101" => toSSD <= aluRes;
            when "110" => toSSD <= memData; -- memOut
            when others => toSSD <= wd;
         end case;
end process alu_mux;
            
end Behavioral;
