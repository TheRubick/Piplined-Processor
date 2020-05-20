Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY RestDataHazard IS
PORT(
--clk : IN std_logic;
stall_enable ,Enable, Reset, Two_Operand : IN std_logic;
DHR2, DHR3 :IN std_logic_vector (11 downto 0);
SrcReg1, SrcReg2 : IN std_logic_vector (2 downto 0);
DP1, DP2, C1, C2, R1, R2, LOADCASE,S1_1_2,S2_1_2 : OUT std_logic
);
END RestDataHazard ;

architecture a_RestDataHazard of RestDataHazard is

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

--signal result : std_logic_vector(3 downto 0);
signal clear1, clear2 : std_logic;

signal DHR2_Result1_S1, DHR2_Result2_S1, DP2_S1, DST2_1_2_S1 :std_logic;
signal DHR3_Result1_S1, DHR3_Result2_S1, DP3_S1, DST3_1_2_S1 :std_logic;
signal src1_1_2, src2_1_2 : std_logic;
signal DHR2_Result1_S2, DHR2_Result2_S2, DP2_S2, DST2_1_2_S2 :std_logic;
signal DHR3_Result1_S2, DHR3_Result2_S2, DP3_S2, DST3_1_2_S2 :std_logic;
signal RC_SEL_TEMP1, RC_SEL_TEMP2 : std_logic_vector(3 downto 0);

begin

clear1 <= (Not(Enable) OR Reset) AND (Not(stall_enable)) ;
clear2 <= (Not(Enable) OR Reset OR Not(Two_Operand)) AND (Not(stall_enable)) ;


-- for DHR2 and SrcReg1
DHR2_Result1_S1 <= ( DHR2(2) XNOR SrcReg1(0) ) AND  ( DHR2(3) XNOR SrcReg1(1) ) AND ( DHR2(4) XNOR SrcReg1(2) ) AND DHR2(0);
DHR2_Result2_S1 <= ( DHR2(5) XNOR SrcReg1(0) ) AND  ( DHR2(6) XNOR SrcReg1(1) ) AND ( DHR2(7) XNOR SrcReg1(2) ) AND (DHR2(0) AND DHR2(1)) ;
DP2_S1 <= (DHR2_Result1_S1 OR DHR2_Result2_S1)  AND stall_enable;
DST2_1_2_Mux_S1: mux2_1bit  port map ('0', '1', DHR2_Result2_S1, DST2_1_2_S1);

-- for DHR3 and SrcReg1
DHR3_Result1_S1 <= ( DHR3(2) XNOR SrcReg1(0) ) AND  ( DHR3(3) XNOR SrcReg1(1) ) AND ( DHR3(4) XNOR SrcReg1(2) ) AND DHR3(0);
DHR3_Result2_S1 <= ( DHR3(5) XNOR SrcReg1(0) ) AND  ( DHR3(6) XNOR SrcReg1(1) ) AND ( DHR3(7) XNOR SrcReg1(2) ) AND (DHR3(0) AND DHR3(1)) ;
DP3_S1 <= DHR3_Result1_S1 OR DHR3_Result2_S1;
DST3_1_2_Mux_S1: mux2_1bit  port map ('0', '1', DHR3_Result2_S1, DST3_1_2_S1);

-- select DP1
DP1 <= (DP2_S1 OR DP3_S1) AND Not(clear1);  -- here we out Right DP1
-- select R_C 1
RC3_OR_RC2_Mux_S1 : mux2_generic generic map (INPUT_WIDTH => 4) port map (DHR3(11 downto 8), DHR2(11 downto 8), DP2_S1, RC_SEL_TEMP1);

C1 <= RC_SEL_TEMP1(1) AND Not(clear1);
R1 <= RC_SEL_TEMP1(3) AND Not(clear1);

-- select 1_2_S1

src1_1_2_Mux: mux2_1bit  port map (DST3_1_2_S1, DST2_1_2_S1, DP2_S1, src1_1_2);
S1_1_2 <= src1_1_2 AND Not(clear1);

-- for DHR2 and SrcReg2

DHR2_Result1_S2 <= ( DHR2(2) XNOR SrcReg2(0) ) AND  ( DHR2(3) XNOR SrcReg2(1) ) AND ( DHR2(4) XNOR SrcReg2(2) ) AND DHR2(0);
DHR2_Result2_S2 <= ( DHR2(5) XNOR SrcReg2(0) ) AND  ( DHR2(6) XNOR SrcReg2(1) ) AND ( DHR2(7) XNOR SrcReg2(2) ) AND (DHR2(0) AND DHR2(1)) ;
DP2_S2 <= (DHR2_Result1_S2 OR DHR2_Result2_S2) AND stall_enable;
DST2_1_2_Mux_S2: mux2_1bit  port map ('0', '1', DHR2_Result2_S2, DST2_1_2_S2);

-- for DHR3 and SrcReg2

DHR3_Result1_S2 <= ( DHR3(2) XNOR SrcReg2(0) ) AND  ( DHR3(3) XNOR SrcReg2(1) ) AND ( DHR3(4) XNOR SrcReg2(2) ) AND DHR3(0);
DHR3_Result2_S2 <= ( DHR3(5) XNOR SrcReg2(0) ) AND  ( DHR3(6) XNOR SrcReg2(1) ) AND ( DHR3(7) XNOR SrcReg2(2) ) AND (DHR3(0) AND DHR3(1)) ;
DP3_S2 <= DHR3_Result1_S2 OR DHR3_Result2_S2 ;
DST3_1_2_Mux_S2: mux2_1bit  port map ('0', '1', DHR3_Result2_S2, DST3_1_2_S2);

-- select DP2
DP2 <= (DP2_S2 OR DP3_S2) AND Not(clear2);  -- here we out Right DP2
-- select R_C 1
RC3_OR_RC2_Mux_S2 : mux2_generic generic map (INPUT_WIDTH => 4) port map (DHR3(11 downto 8), DHR2(11 downto 8), DP2_S2, RC_SEL_TEMP2);

C2 <= RC_SEL_TEMP2(1) AND Not(clear2);
R2 <= RC_SEL_TEMP2(3) AND Not(clear2);

-- select 1_2_S2
src2_1_2_Mux: mux2_1bit  port map (DST3_1_2_S2, DST2_1_2_S2, DP2_S2, src2_1_2);

S2_1_2 <= src2_1_2 AND Not(clear2);
--
-- EX_VAR : process (clk)
--   variable Temp : std_logic := '0';
-- begin
--   if falling_edge(clk) AND clk = '0' then
--
--     Temp := ( (DP2_S2 AND DHR2(11) AND Not(clear2)) OR (DP2_S1 AND DHR2(11) AND Not(clear1))) ;
--     report "Temp value is" & std_logic'image(Temp);
--     LOADCASE <= Temp;
--
--   end if;
-- end process EX_VAR;


LOADCASE <= (( (DP2_S2 AND DHR2(11) AND Not(clear2)) OR (DP2_S1 AND DHR2(11) AND Not(clear1))) AND stall_enable) and '0';


end a_RestDataHazard;

-- things to remember
--1 - na 3aml kolo leeh src 1 w src 2  el EXE_MEM deh na btl3 el C bt3 src1 ao src2 fe kda s7 wla el mfrod atl3 el 2 bit bt3o el c
