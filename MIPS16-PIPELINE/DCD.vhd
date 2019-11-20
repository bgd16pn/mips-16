----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 10:23:11 PM
-- Design Name: 
-- Module Name: DCD - Behavioral
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

entity DCD is
    Port ( sel : in STD_LOGIC_VECTOR (2 downto 0);
           output : out STD_LOGIC_VECTOR (7 downto 0));
end DCD;

architecture Behavioral of DCD is

begin
    process(sel)
    begin
        case sel is
            when "000" => output <= "00000001";
            when "001" => output <= "00000010";
            when "010" => output <= "00000100";
            when "011" => output <= "00001000";
            when "100" => output <= "00010000";
            when "101" => output <= "00100000";
            when "110" => output <= "01000000";
            when others => output <= "10000000";
        end case;
    end process;

end Behavioral;
