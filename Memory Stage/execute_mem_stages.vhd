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

architecture decode_buffer_arch of decode_buffer is

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
reg1_wr_IN, reg2_wr_IN, MEM_WR, MEM_RD  : IN  std_logic;
reg1_wr_OUT, reg2_wr_OUT, MEM_WR_OUT, MEM_RD_OUT  : OUT  std_logic;
CALL_IN, RET_IN, RTI_IN, OUT_IN, IN_IN, INT_IN ,INC_IN, DEC_IN, DP1_IN, DP2_IN :  IN std_logic;
CALL_OUT, RET_OUT, RTI_OUT, OUT_OUT, IN_OUT, INT_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT :  OUT std_logic;
dst1_add_IN, dst2_add_IN : IN std_logic_vector(2 downto 0);
dst1_add_OUT, dst2_add_OUT : OUT std_logic_vector(2 downto 0) 

) ;
end component;

--Memory Stage Component
component Memory_stage_entity IS
	PORT(
		clk,reset,
		reg1_wr_ex,reg2_wr_ex,dst1_add_ex,dst2_add_ex,mem_rd_ex,mem_wr_ex,out_ex,in_ex,
		call_ex,inc_ex,dec_ex,ret_ex,rti_ex,int_ex,
		ALU,dp1,dp2: IN  std_logic;
		address_dst1_ex,data_dst2_ex,dst1_mem,dst2_mem,pc_ex_mem,input_port  : IN  std_logic_vector(31 DOWNTO 0);
		reg1_wr_ex_output,reg2_wr_ex_output,dst1_add_ex_output,dst2_add_ex_output: OUT std_logic;
		dst1_mem_output,dst2_mem_output,out_port_output : OUT std_logic_vector(31 DOWNTO 0)
		);
END Component;

--WriteBack Stage Component
component Mem_WB_entity IS
	PORT(
		reg1_wr_mem,reg2_wr_mem,dst1_add_mem,dst2_add_mem,clk,reset : IN  std_logic;
		dst1_mem_input,dst2_mem_input : IN  std_logic_vector(31 DOWNTO 0);
		reg1_wr_mem_output,reg2_wr_mem_output,dst1_add_mem_output,dst2_add_mem_output : OUT  std_logic;
		dst1_mem_output,dst2_mem_output : OUT std_logic_vector(31 DOWNTO 0)
		);
END component;

-- signals outed from Execute stage to Execute - Memory buffer
signal Predication, Predication_Done, Flush_out :  std_logic; -- BranchPredicator outputs
signal DP1_EX, DP2_EX : std_logic;
signal PC_EX, ADD_DST1_EX, DATA_DST2_EX : std_logic_vector(31 downto 0);
------------------------------------------------------------------------
-- signals outed from Execute buffer to Memory Stage
signal PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT :  std_logic_vector(31 downto 0);
signal reg1_wr_EX_OUT, reg2_wr_EX_OUT, MEM_WR_OUT, MEM_RD_OUT  : std_logic;
signal CALL_EX_OUT, RET_EX_OUT, RTI_EX_OUT, OUT_OUT, IN_OUT, INT_EX_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT : std_logic;
signal dst1_add_EX_OUT, dst2_add_EX_OUT : std_logic_vector(2 downto 0);
------------------------------------------------------------------------
------------------------------------------------------------------------
-- signals outed from Memory Stage to Memory/WriteBack Stage , output port is not related to the writeback stage
signal reg1_mem_out,reg2_mem_out,dst1_add_mem_out,dst2_add_mem_out: std_logic;
signal dst1_mem_out,dst2_mem_out,out_port_out : std_logic_vector(31 DOWNTO 0);

-- signals outed from WriteBack Stage to fetch
signal reg1_wb_out,reg2_wb_out,dst1_add_wb_out,dst2_add_wb_out: std_logic;
signal dst1_wb_out,dst2_wb_out : std_logic_vector(31 DOWNTO 0);
------------------------------------------------------------------------
SIGNAL Notfound : std_logic_vector(31 downto 0):= (others => '0');



begin
  -- connect Execute Stage
execute_component : EX_STAGE port map(CLK, RST, IR_out, INT_out, JZ_out, '0', '0', '0', '0', '0', '0', '0', '0', OUT1_out, OUT2_out, Notfound, Notfound, Notfound, Notfound, PC_IF_EX_out, Notfound, ALU_ENABLE_out, IMM_out, EA_out, Predication,  Predication_Done,  Flush_out, DP1_EX,  DP2_EX, PC_EX, ADD_DST1_EX,  DATA_DST2_EX);

-- Execute Memory Buffer
EX_MEM_Buffer_component : EX_MEM_Buffer port map (CLK, RST, '0', PC_EX, ADD_DST1_EX, DATA_DST2_EX, PC_OUT, ADD_DST1_OUT, DATA_DST2_OUT, REG1_WR_out, REG2_WR_out, reg1_wr_EX_OUT, reg2_wr_EX_OUT, MEM_WR_OUT, MEM_RD_OUT, CALL_out, RET_out, RTI_out, OUT_SIGNAL_out,'0',INT_out,'0','0',DP1_EX, DP2_EX, CALL_EX_OUT, RET_EX_OUT, RTI_EX_OUT, OUT_OUT, IN_OUT, INT_EX_OUT ,INC_OUT, DEC_OUT, DP1_OUT, DP2_OUT,DST1_ADD_out,DST2_ADD_out,dst1_add_EX_OUT,dst2_add_EX_OUT);

-- notes  - all dp loadcase is missing and inc , dec , in signals and Dst1_EX, Dst1_MEM, Dst2_EX, Dst2_MEM,  JMP_INT_PC are also missing

--Memory Stage , NOT ALU signal , dst1_mem,dst2_mem are missing , modify input port i.e. remove it from the inputs
Memory_stage_component : Memory_stage_entity port map(CLK, RST, reg1_wr_EX_OUT, reg2_wr_EX_OUT, dst1_add_EX_OUT, dst2_add_EX_OUT, MEM_RD_OUT, MEM_WR_OUT,OUT_OUT,IN_OUT,
					CALL_OUT,INC_OUT,DEC_OUT,RET_OUT,RTI_OUT,INT_OUT,ALU_ENABLE_out,DP1_OUT,DP2_OUT,ADD_DST1_OUT,DATA_DST2_OUT,Notfound,Notfound,
					PC_OUT,Notfound,
					reg1_mem_out,reg2_mem_out,dst1_add_mem_out,dst2_add_mem_out, -- output signals
					dst1_mem_out,dst2_mem_out,out_port_out);

--WriteBack Stage 
WriteBack_stage_component : Mem_WB_entity port map(reg1_mem_out,reg2_mem_out,dst1_add_mem_out,dst2_add_mem_out,CLK,RST,
					dst1_mem_out,dst2_mem_out,
					reg1_wb_out,reg2_wb_out,dst1_add_wb_out,dst2_add_wb_out, -- output signals
					dst1_wb_out,dst2_wb_out
					);

end decode_buffer_arch;
