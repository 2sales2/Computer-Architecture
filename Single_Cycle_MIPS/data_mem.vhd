library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
  port(clk, we: in std_logic;
         a, wd: in std_logic_vector(31 downto 0);
			   rd: out std_logic_vector(31 downto 0));
end data_mem;

architecture synth of data_mem is
  type ram_type is array(63 downto 0) of std_logic_vector(31 downto 0);
  signal mem: ram_type := (others => (others =>'0')); -- inicializa com 0  
begin
 -- Leitura combinacional
 rd <= mem(to_integer(unsigned(a(7 downto 2))));
 
 -- Concorrentemenete faz gravacoes
 process(clk)
 begin
   if rising_edge(clk) then
	  if we = '1' then
	    mem(to_integer(unsigned(a(7 downto 2)))) <= wd;
	  end if;
	end if;
 end process;
end synth;
