Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY decode_buffer IS
PORT(

  CLK ,RST       :  IN std_logic;
  IR_out: in std_logic_vector (15 downto 0);
  RET_out: in std_logic;
  CALL_out: in std_logic;
  PC_IF_EX_out:in std_logic_vector (31 downto 0);
  INT_out : in std_logic;
  RTI_out: in std_logic;
  TEMP_OUT_out: in std_logic_vector (3 downto 0);
  REG1_WR_out: in std_logic;
  REG2_WR_out: in std_logic;
  DST1_ADD_out: in std_logic_vector (2 downto 0);
  DST2_ADD_out: in std_logic_vector (2 downto 0);
  OUT1_out: in std_logic_vector (31 downto 0);
  OUT2_out: in std_logic_vector (31 downto 0);
  EA_out: in std_logic_vector (31 downto 0);
  IMM_out: in std_logic_vector (31 downto 0);
  OUT_SIGNAL_out: in std_logic;
  MEMEORY_READ_out: in std_logic;
  MEMORY_WRITE_out: in std_logic;
  ALU_SRC2_out: in std_logic;
  ALU_ENABLE_out: in std_logic;
  JZ_out: in std_logic;
  JMP_out: in std_logic

);
END decode_buffer;


architecture decode_buffer of decode_buffer_arch is

component EX_STAGE IS
PORT(
--INPUTA ,INPUTB :  IN std_logic_vector(3 downto 0);
CLK ,RST       :  IN std_logic;
IR : IN std_logic_vector(15 downto 0);

INT, JMPZ :  IN std_logic;
LOADCASE, DP1, C1, R1, DP2, C2, R2, Stall  :  IN std_logic;

OUT1, OUT2, Dst1_EX, Dst1_MEM, Dst2_EX, Dst2_MEM, PC_ID, JMP_INT_PC  :  IN std_logic_vector(31 downto 0);
ALU_Enable     :  IN std_logic;
IMM, EA  :  IN std_logic_vector(31 downto 0);
--flags : OUT std_logic_vector(3 downto 0);
Predication, Predication_Done, Flush_out :  OUT std_logic; -- BranchPredicator outputs
DP1_EX, DP2_EX : OUT std_logic;
PC_EX, ADD_DST1_EX, DATA_DST2_EX : OUT std_logic_vector(31 downto 0)
);
END component; 



component EX_MEM_Buffer is
port (
CLK, RST, Stall: in std_logic;
--IR_Buff: in std_logic_vector (15 downto 0);
PC_IN, ADD_DST1_IN, DATA_DST2_IN : IN std_logic_vector(31 downto 0);
PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT : OUT std_logic_vector(31 downto 0);
reg1_wr_IN, reg2_wr_IN, dst1_add_IN, dst2_add_IN , MEM_WR, MEM_RD  : IN  std_logic;
reg1_wr_OUT, reg2_wr_OUT, dst1_add_OUT, dst2_add_OUT, MEM_WR_OUT, MEM_RD_OUT  : OUT  std_logic;
CALL_IN, RET_IN, RTI_IN, OUT_IN, IN_IN, INT_IN ,INC_IN, DEC_IN, DP1_IN, DP2_IN :  IN std_logic;
CALL_OUT, RET_OUT, RTI_OUT, OUT_OUT, IN_OUT, INT_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT :  OUT std_logic

) ;
end component;

signal Predication, Predication_Done, Flush_out :  std_logic; -- BranchPredicator outputs
signal DP1_EX, DP2_EX : std_logic;
signal PC_EX, ADD_DST1_EX, DATA_DST2_EX : std_logic_vector(31 downto 0);

begin
	
	execute_component : EX_STAGE port map(CLK,RST,IR_out,INT_out,JZ_out,'0',);

end decode_buffer_arch;

