library ieee;
use ieee.std_logic_1164.all;

entity CompSemUC is 
	port(
		clk ,reset , jump , branch , MemToReg , ALUsrc , regDST , MemWrite , PCSrc , regWrite: in std_logic ;
		AluControl : in std_logic_vector(2 downto 0));
end CompSemUC ;

architecture behaviour of CompSemUC is 
	
	component data_mem is
		port(clk, we: in std_logic;
         a, wd: in std_logic_vector(31 downto 0);
			   rd: out std_logic_vector(31 downto 0));
	end component;
	
	component DataPath is 
	port(
		--DataPath input
		clk , reset : in std_logic ;
		zero : out std_logic ;
		ReadData , Instr : in std_logic_vector(31 downto 0);
		PC ,ALUOut , WriteData : buffer std_logic_vector(31 downto 0 );

		--UC input
		ALUControl : in std_logic_vector(2 downto 0) ;
		PCSrc , MemtoReg , ALUSrc , RegDst , RegWrite , Jump : in std_logic );

	end component ;
	
	
	component instruction_mem is
		port(a: in std_logic_vector(31 downto 0);   -- Parramento de end.
	     rd: out std_logic_vector(31 downto 0)); -- Barramento de dados
	end component;
	
	--definindo sinais
	signal pc_in : std_logic_vector(31 downto 0) ;
	signal aluOut_in: std_logic_vector(31 downto 0) ; 
	signal writeData_in : std_logic_vector(31 downto 0) ;
	signal instr_in : std_logic_vector(31 downto 0) ;
	signal readdata_in: std_logic_vector(31 downto 0) ;
	signal zero_out : std_logic ;
	begin
		DP : DataPath port map(
										clk => clk , 
										reset => reset ,
										alucontrol => alucontrol ,
										jump => Jump ,
										PCSrc => (zero_out and branch) ,
										MemToReg => MemtoReg ,
										AluSrc => AluSrc ,
										RegDST => RegDSt,
										RegWrite => RegWrite ,
										Pc => PC_in,
										ALUout => Aluout_in ,
										WriteData => writeData_in ,
										ReadData => readdata_in,
										instr => instr_in,
										zero => zero_out);
		
		IM : instruction_mem port map(
										a => pc_in ,
										rd => instr_in );
		
		DM : data_mem port map(
										clk => clk ,
										a => aluOUt_in ,
										wd => WriteData_in ,
										rd => readdata_in ,
										we => MemWrite);
	
	end behaviour ;
