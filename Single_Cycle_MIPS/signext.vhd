library IEEE; 
use IEEE.STD_LOGIC_1164.all;

-- extende o sinal a de 16 bits para 32 bits
entity signext is
  port(a: in  STD_LOGIC_VECTOR(15 downto 0);
       y: out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture synth of signext is
begin
  y <= (X"ffff" & a) when a(15) = '1' else (X"0000" & a); 
end;
