library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.all;

-- Somador de 32 bits
entity rcadder is
  port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
       y:    out STD_LOGIC_VECTOR(31 downto 0));
end rcadder;

architecture synth of rcadder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end synth;