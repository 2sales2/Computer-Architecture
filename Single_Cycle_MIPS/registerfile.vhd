library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_std.all; 

entity registerfile is 
  port(clk:           in  STD_LOGIC;
       we:           in  STD_LOGIC;
       ra1, ra2, wa: in  STD_LOGIC_VECTOR(4 downto 0);   -- enderecos de leitura e gravação
       wd:           in  STD_LOGIC_VECTOR(31 downto 0);  -- conteudo a ser gravado
       rd1, rd2:      out STD_LOGIC_VECTOR(31 downto 0)); -- portas de leitura
end;

architecture synth of registerfile is
  type ram_type is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem: ram_type;
begin
  -- escrita sincronizada na borda de subida do sinal de clock
  process(clk) begin
    if rising_edge(clk) then
       if we = '1' then 
          mem(to_integer(unsigned(wa))) <= wd;
       end if;
    end if;
  end process;
  
  -- leitura combinacional 
  process(all) begin
    if (to_integer(unsigned(ra1)) = 0) then 
       rd1 <= X"00000000"; -- registrador $0 = 0
    else 
       rd1 <= mem(to_integer(unsigned(ra1)));
    end if;
    
    if (to_integer(unsigned(ra2)) = 0) then 
       rd2 <= X"00000000";  -- registrador 0 sempre em 0
    else 
       rd2 <= mem(to_integer(unsigned(ra2)));
    end if;
  end process;
end synth;
