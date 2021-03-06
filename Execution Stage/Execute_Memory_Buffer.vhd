LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity EX_MEM_Buffer is
port (
CLK, RST, Stall: in std_logic;
--IR_Buff: in std_logic_vector (15 downto 0);
PC_IN, ADD_DST1_IN, DATA_DST2_IN : IN std_logic_vector(31 downto 0);
PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT : OUT std_logic_vector(31 downto 0);
reg1_wr_IN, reg2_wr_IN, MEM_WR, MEM_RD  : IN  std_logic;
reg1_wr_OUT, reg2_wr_OUT, MEM_WR_OUT, MEM_RD_OUT  : OUT  std_logic;
CALL_IN, RET_IN, RTI_IN, OUT_IN, IN_IN, INT_IN ,INC_IN, DEC_IN, DP1_IN, DP2_IN :  IN std_logic;
CALL_OUT, RET_OUT, RTI_OUT, OUT_OUT, IN_OUT, INT_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT :  OUT std_logic;
dst1_add_IN, dst2_add_IN : IN std_logic_vector(2 downto 0);
dst1_add_OUT, dst2_add_OUT : OUT std_logic_vector(2 downto 0) ;
ALU_Enable_EX_IN : IN std_logic;
ALU_Enable_EX_OUT : OUT std_logic
) ;
end EX_MEM_Buffer;

architecture a_EX_MEM_Buffer of EX_MEM_Buffer is

component generic_WAR_reg is
GENERIC(REG_WIDTH : INTEGER );
port (
d: in std_logic_vector (REG_WIDTH - 1 downto 0);
clk: in std_logic;
clear: in std_logic;
enable: in std_logic;
q: out std_logic_vector (REG_WIDTH - 1 downto 0)
);
end component;

component WAR_latch is
port (
d: in std_logic;
clk: in std_logic;
clear: in std_logic;
enable: in std_logic;
q: out std_logic
) ;
end component;

component WAR_latch_with_stall is
    port (
      d: in std_logic;
      clk: in std_logic;
      clear: in std_logic;
  enable: in std_logic;
      q: out std_logic;
      stall: in std_logic
  
    ) ;
  end component;

component mux2_1bit is
    port (
      in1,in2: in std_logic;
  sel: in std_logic;
      mux_out: out std_logic
      );
  end component mux2_1bit ;

    signal reset: std_logic;
    signal stall_input,stall_output: std_logic; 

begin
    
--Stall_mux: mux2_1bit port map(Stall,'0',stall_output,stall_input);
--Stall_Latch : WAR_latch port map(stall_input, CLK, '0','1', stall_output);
--reset <= RST or stall_output;
reset <= RST;
-- registers 32 bit
ADD_DST1 : generic_WAR_reg generic map (REG_WIDTH => 32) port map (ADD_DST1_IN, CLK, RST, '1', ADD_DST1_OUT); -- ADD_DST1  register
DATA_DST2 : generic_WAR_reg generic map (REG_WIDTH => 32) port map (DATA_DST2_IN, CLK, RST, '1', DATA_DST2_OUT); -- DATA_DST2  register
PC : generic_WAR_reg generic map (REG_WIDTH => 32) port map (PC_IN, CLK, reset, '1', PC_OUT); -- DATA_DST2  register

-- latches
reg1_Wr_Latch : WAR_latch_with_stall port map(reg1_wr_IN, CLK, reset,'1', reg1_wr_OUT, Stall);
reg2_Wr_Latch : WAR_latch_with_stall port map(reg2_wr_IN, CLK, reset,'1', reg2_wr_OUT, Stall);

dst1_Add_Latch : generic_WAR_reg generic map (REG_WIDTH => 3) port map(dst1_add_IN, CLK, reset,'1', dst1_add_OUT);
dst2_Add_Latch : generic_WAR_reg generic map (REG_WIDTH => 3) port map(dst2_add_IN, CLK, reset,'1', dst2_add_OUT);

MEM_RD_Latch : WAR_latch_with_stall port map(MEM_RD, CLK, reset,'1', MEM_RD_OUT, Stall);
MEM_WR_Latch  : WAR_latch_with_stall port map(MEM_WR, CLK, reset,'1', MEM_WR_OUT, Stall);

CALL_Latch  : WAR_latch_with_stall port map(CALL_IN, CLK, reset,'1', CALL_OUT, Stall);
RET_Latch  : WAR_latch_with_stall port map(RET_IN, CLK, reset,'1', RET_OUT, Stall);
RTI_Latch  : WAR_latch_with_stall port map(RTI_IN, CLK, reset,'1', RTI_OUT, Stall);
OUT_Latch  : WAR_latch_with_stall port map(OUT_IN, CLK, reset,'1', OUT_OUT, Stall);
IN_Latch  : WAR_latch_with_stall port map(IN_IN, CLK, reset,'1', IN_OUT, Stall);
INT_Latch  : WAR_latch_with_stall port map(INT_IN, CLK, reset,'1', INT_OUT, Stall);
INC_Latch  : WAR_latch_with_stall port map(INC_IN, CLK, reset,'1', INC_OUT, Stall);
DEC_Latch  : WAR_latch_with_stall port map(DEC_IN, CLK, reset,'1', DEC_OUT, Stall);
DP1_Latch  : WAR_latch_with_stall port map(DP1_IN, CLK, reset,'1', DP1_OUT, Stall);
DP2_Latch  : WAR_latch_with_stall port map(DP2_IN, CLK, reset,'1', DP2_OUT, Stall);
ALU_Latch  : WAR_latch_with_stall port map(ALU_Enable_EX_IN, CLK, reset,'1', ALU_Enable_EX_OUT, Stall);


end a_EX_MEM_Buffer ;
