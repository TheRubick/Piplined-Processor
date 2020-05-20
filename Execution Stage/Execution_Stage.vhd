Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY EX_STAGE IS
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
PC_EX, ADD_DST1_EX, DATA_DST2_EX : OUT std_logic_vector(31 downto 0);
flag_from_mem : in std_logic_vector(3 downto 0);
flag_to_mem : out std_logic_vector(3 downto 0);
S1_1_2_out_ID_EX, S2_1_2_out_ID_EX : in std_logic
);
END EX_STAGE ;


architecture a_EX_STAGE of EX_STAGE is

component generic_RAW_reg is
GENERIC( REG_WIDTH : INTEGER );
port (
d: in std_logic_vector (REG_WIDTH - 1 downto 0);
clk: in std_logic;
clear: in std_logic;
enable: in std_logic;
q: out std_logic_vector (REG_WIDTH - 1 downto 0)
) ;
end component generic_RAW_reg;


component ALU IS
PORT(
INPUTA ,INPUTB :  IN std_logic_vector(31 downto 0);
ALU_Enable     :  IN std_logic;
ALUOUT         :  OUT std_logic_vector(31 downto 0);
IR  	         :  IN std_logic_vector(15 downto 0);
REGFLAGIN      :  IN std_logic_vector(3 downto 0);   --  - zero - negative - carry
REGFLAGOUT     :  OUT std_logic_vector(3 downto 0);
JMPZ :  IN std_logic
);
END component ALU ;


component mux4_generic is
GENERIC(INPUT_WIDTH : INTEGER );
port (
inp0: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
inp1: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
inp2: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
inp3: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
sel: in std_logic_vector (1 downto 0);
mux_output: out std_logic_vector(INPUT_WIDTH - 1 downto 0)
) ;
end component mux4_generic ;


component mux4_1bit is
port (
inp0: IN std_logic;
inp1: IN std_logic;
inp2: IN std_logic;
inp3: IN std_logic;
sel: in std_logic_vector (1 downto 0);
mux_output: out std_logic
) ;
end component mux4_1bit ;


component mux2_generic is
GENERIC( INPUT_WIDTH : INTEGER );
port (
in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
sel: in std_logic;
mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
);
end component mux2_generic ;

component mux2_1bit is
port (
in1,in2: in std_logic;
sel: in std_logic;
mux_out: out std_logic
);
end component mux2_1bit ;

component BranchPredicator IS
PORT(
RST , CLK     :  IN std_logic;
ZeroFlag, JMPZ   :  IN std_logic;
Predication, Predication_Done, Flush :  OUT std_logic
);
END component ;


--signal result : std_logic_vector(3 downto 0);
signal firstinput , secondinput_temp, secondinput ,ALUOUT, IMM_OR_EA, ALU_OR_MEM, Swap_operand , SwapDP_operand1,SwapDP_operand2,SwapDP_EXE2 ,SwapDP_EXE1 : std_logic_vector(31 downto 0);
signal flagin , flagout : std_logic_vector(3 downto 0);
signal Sel_1, Sel_2 : std_logic_vector(1 downto 0);
signal Sel, DP_Sel, INT_Sel, Swap : std_logic;
signal Flush,PR_Done :std_logic;
signal swap_dp1 , swap_dp2, swap_dp2_exe1,swap_dp2_exe2 : std_logic;

begin

swap_dp1 <= DP1 AND R1 AND S1_1_2_out_ID_EX;
swap_dp2 <= DP2 AND R2 AND S2_1_2_out_ID_EX;
swap_dp2_exe1 <= DP1 AND Not(R1) AND S1_1_2_out_ID_EX;
swap_dp2_exe2 <= DP2 AND Not(R2) AND S2_1_2_out_ID_EX;


Swap_DP1_Mux :  mux2_generic generic map (INPUT_WIDTH => 32) port map (Dst1_MEM, Dst2_MEM, swap_dp1, SwapDP_operand1);
Swap_DP2_Mux :  mux2_generic generic map (INPUT_WIDTH => 32) port map (Dst1_MEM, Dst2_MEM, swap_dp2, SwapDP_operand2);
swap_dp2_exe_mux1 : mux2_generic generic map (INPUT_WIDTH => 32) port map (Dst1_EX, Dst2_EX, swap_dp2_exe1, SwapDP_EXE1);
swap_dp2_exe_mux2 : mux2_generic generic map (INPUT_WIDTH => 32) port map (Dst1_EX, Dst2_EX, swap_dp2_exe2, SwapDP_EXE2);

flagout <= flag_from_mem;
flag_to_mem <= flagin;
ALU_COMP : ALU port map (firstinput, secondinput, ALU_Enable, ALUOUT, IR, flagout, flagin,JMPZ);   -- ALU module
--FlagRegister : generic_RAW_reg generic map (REG_WIDTH => 4) port map (flagin, CLK, RST, ALU_Enable, flagout); -- Flag register

-- 2 muxes to choose firstinput and secondinput
Sel_1 <= dp1 & R1;  -- selector INPUT1_Mux
Sel_2 <= dp2 & R2;  -- selector INPUT2_Temp_Mux
Sel <= IR(12) AND IR(11); -- selector INPUT2_Mux

INPUT1_Mux : mux4_generic generic map (INPUT_WIDTH => 32) port map (OUT1, OUT1, SwapDP_EXE1, SwapDP_operand1, Sel_1 ,firstinput);
INPUT2_Temp_Mux : mux4_generic generic map (INPUT_WIDTH => 32) port map (OUT2, OUT2, SwapDP_EXE2, SwapDP_operand2, Sel_2 ,secondinput_temp);--
INPUT2_Mux : mux2_generic generic map (INPUT_WIDTH => 32) port map (secondinput_temp, IMM, Sel, secondinput);


Swap <= '1' WHEN IR(14 downto 9 ) = "010100" Else
        '0' ;

Swap_EX_Mux :  mux2_generic generic map (INPUT_WIDTH => 32) port map (firstinput, secondinput, Swap, Swap_operand);
DATA_DST2_EX_Mux :  mux2_generic generic map (INPUT_WIDTH => 32) port map (Swap_operand, Dst2_MEM, Stall, DATA_DST2_EX);

--- muxes for ADD_DST1_EX
Imm_or_EA_Mux : mux2_generic generic map (INPUT_WIDTH => 32) port map (IMM, EA, IR(10), IMM_OR_EA);
ALU_OR_MEM_Mux : mux2_generic generic map (INPUT_WIDTH => 32) port map (IMM_OR_EA, ALUOUT, ALU_Enable, ALU_OR_MEM);
ADD_DST1_EX_Mux : mux2_generic generic map (INPUT_WIDTH => 32) port map (ALU_OR_MEM, Dst1_MEM, Stall, ADD_DST1_EX);

--- DP1_EX and DP2_EX
DP_Sel <= LOADCASE AND (NOT(ALU_Enable));
DP1_EX_Mux : mux2_1bit port map ('0', DP1, DP_Sel, DP1_EX);
DP2_EX_Mux : mux2_1bit port map ('0', DP2, DP_Sel, DP2_EX);

--INT Mux
INT_Sel <= INT AND JMPZ AND PR_Done AND (NOT('0'));
INT_Sel_Mux : mux2_generic generic map (INPUT_WIDTH => 32) port map (PC_ID, JMP_INT_PC, INT_Sel, PC_EX);

-- BranchPredicator
Flush_out <= Flush;
Predication_Done <= PR_Done;
BranchPredicator_Map : BranchPredicator port map (RST, CLK, flagout(3), JMPZ, Predication, PR_Done, Flush);


end a_EX_STAGE;
