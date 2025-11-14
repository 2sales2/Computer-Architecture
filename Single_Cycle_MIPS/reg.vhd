
library IEEE; 
use IEEE.STD_LOGIC_1164.all;  

-- Registrador de n bits implementado de forma comportamental baseado em FF-D
entity reg is 
  generic(n: integer);
  port(clk, reset: in  STD_LOGIC;
       d:          in  STD_LOGIC_VECTOR(n-1 downto 0);
       q:          out STD_LOGIC_VECTOR(n-1 downto 0));
end;

architecture synth of reg is
begin
  process(clk, reset) begin
    if reset = '1' then  
	    q <= (others => '0');
    elsif rising_edge(clk) then
      q <= d;
    end if;
  end process;
end;
