----------------------------------------------------------------------------------
-- Company: UTCN
-- Engineer: Paun Bogdan
-- 
-- Create Date: 02/26/2019 09:43:49 PM
-- Design Name: 
-- Module Name: MUX - Behavioral
-- Project Name: 
-- Target Devices: Basys 3
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

entity MUX is
    Port ( input: in std_logic_vector(3 downto 0);
           sel: in std_logic_vector(1 downto 0);
           output: out std_logic
    );
end MUX;

architecture Behavioral of MUX is

begin

    process(sel, input)
    begin
        case sel is
            when "00" => output <= input(0);
            when "01" => output <= input(1);
            when "10" => output <= input(2);
            when "11" => output <= input(3);
        end case;
    end process;

end Behavioral;
