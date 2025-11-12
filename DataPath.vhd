library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataPath is 
	port(
		--DataPath input
		clk , reset : in std_logic ;
		zero : out std_logic ;
		ReadData , Instr : in std_logic_vector(31 downto 0);
		PC ,ALUOut , WriteData : buffer std_logic_vector(31 downto 0 );

		--UC input
		ALUControl : in std_logic_vector(2 downto 0) ;
		PCSrc , MemtoReg , ALUSrc , RegDst , RegWrite , Jump : in std_logic );

	end DataPath ;

	
architecture sim of DataPath is 
	--importanto componentes
	
	component mux2 is 
		generic(t: integer);
		port(d0, d1: in  STD_LOGIC_VECTOR(t-1 downto 0);
				s:     in  STD_LOGIC;
				y:     out STD_LOGIC_VECTOR(t-1 downto 0));
	end component;
	
	
	component rcadder is
		port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
				  y:    out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	
	component reg is 
		generic(n: integer);
		port(clk, reset: in  STD_LOGIC;
				d:          in  STD_LOGIC_VECTOR(n-1 downto 0);
				q:          out STD_LOGIC_VECTOR(n-1 downto 0));
	end component;
	
	
	component registerfile is 
		port(clk:           in  STD_LOGIC;
				we:           in  STD_LOGIC;
				ra1, ra2, wa: in  STD_LOGIC_VECTOR(4 downto 0);   -- enderecos de leitura e gravação
				wd:           in  STD_LOGIC_VECTOR(31 downto 0);  -- conteudo a ser gravado
				rd1, rd2:      out STD_LOGIC_VECTOR(31 downto 0)); -- portas de leitura
	end component;
	
	
	component signext is
		port(a: in  STD_LOGIC_VECTOR(15 downto 0);
			  y: out STD_LOGIC_VECTOR(31 downto 0));
	
	end component;
	
	component sl2 is
		port(a: in  STD_LOGIC_VECTOR(31 downto 0);
			  y: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	
	 component ula is 
		port(a, b:       in  STD_LOGIC_VECTOR(31 downto 0);
			  alucontrol: in  STD_LOGIC_VECTOR(2 downto 0);
			  result:     buffer STD_LOGIC_VECTOR(31 downto 0);
			  zero:       out STD_LOGIC);
	 end component;

--sinais 
signal PCPlus4 :  std_logic_vector(31 downto 0);
signal PCBranch : std_logic_vector(31 downto 0);
signal out_Mux_PC4_PCBranch : std_logic_vector(31 downto 0);
signal PCJump : std_logic_vector(31 downto 0);
signal out_Mux_PCJump : std_logic_vector(31 downto 0);

signal SignImm : std_logic_vector(31 downto 0);
signal SrcB : std_logic_vector(31 downto 0);

signal Instr20_16 : std_logic_vector(4 downto 0);
signal Instr15_11 : std_logic_vector(4 downto 0);
signal Instr25_21 : std_logic_vector(4 downto 0);
signal Instr15_0 : std_logic_vector(15 downto 0);
signal Instr25_0 : std_logic_vector(25 downto 0);

signal WriteReg : std_logic_vector(4 downto 0) ;
signal RD : std_logic_vector(31 downto 0);
signal Result : std_logic_vector(31 downto 0);
signal Signimm_shifted : std_logic_vector(31 downto 0);
signal out_sl2_to_jump : std_logic_vector(31 downto 0);
signal Instr25_0_ext_32 : std_logic_vector(31 downto 0);
signal SrcA : std_logic_vector(31 downto 0);

begin 
	--Atribuicoes e slicing
	Instr25_21 <= Instr(25 downto 21); 
	Instr20_16 <= Instr(20 downto 16); 
	Instr15_11 <= Instr(15 downto 11); 
	Instr15_0 <= Instr(15 downto 0);   
	Instr25_0 <= Instr(25 downto 0);  
	Instr25_0_ext_32 <= "000000" & Instr25_0 ;  
	PCjump <= PCPlus4(31 downto 28) & out_sl2_to_jump(27 downto 0) ;
	
	--instanciar componentes
	Mux_PC4_PCBranch : mux2 generic map( t => 32) 
									port map(d0 => PCPlus4 , 
												d1 => PCBranch , 
												s => PCSrc ,
												y => out_Mux_PC4_PCBranch);
	
	
	Mux_PCJump : mux2 generic map( t => 32) 
							port map(d0 => out_Mux_PC4_PCBranch , 
										d1 => PCJump , 
										s => Jump ,
										y => out_Mux_PCJump);
	
	
	
	Mux_RD2_SignImm : mux2 generic map( t => 32)
								  port map(d0 => WriteData , 
											  d1 => SignImm , 
											  s => ALUSrc ,
											  y => SrcB);
	
	
	Mux_slice_Instr : mux2 generic map( t => 5)
								  port map(d0 => Instr20_16 , 
											  d1 => Instr15_11 , 
											  s => RegDst ,
											  y => WriteReg);
											  
											  
	Mux_ALUResult_ReadData : mux2 generic map( t => 32)
											port map(d0 => ALUout , 
														d1 => RD , 
														s => MemtoReg ,
														y => Result);	
	
	
	PCregister : reg generic map(n => 32)
						  port map(clk => clk,
									  reset => reset, --duvida
									  d => out_Mux_PCJump,
									  q => PC);
	
	RCA_PCPlus4 : rcadder port map(a => PC ,
											 b => X"00000004",
											 y => PCPlus4);
	
	
	
	RCA_PCBranch : rcadder port map(a => Signimm_shifted ,
											  b => PCPlus4,
											  y => PCBranch);
	
	SignExtend : signext port map(a => Instr15_0 ,
											y => SignImm);
	

	ShiftInstr : sl2 port map(a => Instr25_0_ext_32 ,
									  y => out_sl2_to_jump);
												 
		
	ShiftSignImm : sl2 port map(a => SignImm ,
										 y => Signimm_shifted);
	
	ALU : ula port map(a => SrcA,
							 b => SrcB,
							 alucontrol => ALUcontrol,
							 result => ALUout ,
							 zero => zero);
	
	RegFile : registerfile port map(clk => clk,
											  we  => RegWrite,
											  ra1 => Instr25_21,
											  ra2 => Instr20_16,
											  wa => WriteReg,
											  wd => Result ,
											  rd1 => SrcA, 
									        rd2 => WriteData);
	
end sim ;			