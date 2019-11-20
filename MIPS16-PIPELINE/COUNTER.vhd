----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 10:34:57 PM
-- Design Name: 
-- Module Name: COUNTER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity COUNTER is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           cnt : inout STD_LOGIC_VECTOR (3 downto 0));
end COUNTER;

architecture Behavioral of COUNTER is
begin
    
    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(en = '1') then
                cnt <= cnt + 1;
            end if;
        end if;
    
    end process;

end Behavioral;
