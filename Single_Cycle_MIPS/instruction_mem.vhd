library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_mem is
   port(a: in std_logic_vector(31 downto 0);   -- Parramento de end.
	     rd: out std_logic_vector(31 downto 0)); -- Barramento de dados
end instruction_mem;

architecture synth of instruction_mem is
   type rom_type is array (0 to 63) of std_logic_vector(31 downto 0);
	signal mem: rom_type; -- Define a memoria
	
	-- Para inicializar a memoria
	attribute rom_init_file: string; -- Nome do arquivo
	attribute rom_init_file of mem: signal is "programa.mif";
begin
   -- Leitura combinacional
   rd <= mem(to_integer(unsigned(a(7 downto 2))));  
end synth;