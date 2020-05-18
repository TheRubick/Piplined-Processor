Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY RestDataHazard IS
PORT(
Enable, Reset, Two_Operand : IN std_logic;
--IR : IN std_logic_vector(15 downto 0);
DHR2, DHR3 :IN std_logic_vector (11 downto 0);
SrcReg1, SrcReg2 : IN std_logic_vector (2 downto 0); 
DP1, DP2, C1, C2, R1, R2, LOADCASE : OUT std_logic
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

signal DHR2_Result1_S1, DHR2_Result2_S1, DP2_S1 :std_logic;
signal DHR3_Result1_S1, DHR3_Result2_S1, DP3_S1 :std_logic;

signal DHR2_Result1_S2, DHR2_Result2_S2, DP2_S2 :std_logic;
signal DHR3_Result1_S2, DHR3_Result2_S2, DP3_S2 :std_logic;
signal RC_SEL_TEMP1, RC_SEL_TEMP2 : std_logic_vector(3 downto 0);

begin

clear1 <= Not(Enable) OR Reset;
clear2 <= Not(Enable) OR Reset OR Not(Two_Operand) ;


-- for DHR2 and SrcReg1
DHR2_Result1_S1 <= ( DHR2(2) XNOR SrcReg1(0) ) AND  ( DHR2(3) XNOR SrcReg1(1) ) AND ( DHR2(4) XNOR SrcReg1(2) ) AND DHR2(0);
DHR2_Result2_S1 <= ( DHR2(5) XNOR SrcReg1(0) ) AND  ( DHR2(6) XNOR SrcReg1(1) ) AND ( DHR2(7) XNOR SrcReg1(2) ) AND (DHR2(0) AND DHR2(1)) ;
DP2_S1 <= DHR2_Result1_S1 OR DHR2_Result2_S1;

-- for DHR3 and SrcReg1
DHR3_Result1_S1 <= ( DHR3(2) XNOR SrcReg1(0) ) AND  ( DHR3(3) XNOR SrcReg1(1) ) AND ( DHR3(4) XNOR SrcReg1(2) ) AND DHR3(0);
DHR3_Result2_S1 <= ( DHR3(5) XNOR SrcReg1(0) ) AND  ( DHR3(6) XNOR SrcReg1(1) ) AND ( DHR3(7) XNOR SrcReg1(2) ) AND (DHR3(0) AND DHR3(1)) ;
DP3_S1 <= DHR3_Result1_S1 OR DHR3_Result2_S1;

-- select DP1
DP1 <= (DP2_S1 OR DP3_S1) AND Not(clear1);  -- here we out Right DP1
-- select R_C 1
RC3_OR_RC2_Mux_S1 : mux2_generic generic map (INPUT_WIDTH => 4) port map (DHR3(11 downto 8), DHR2(11 downto 8), DP2_S1, RC_SEL_TEMP1);

C1 <= RC_SEL_TEMP1(1) AND Not(clear1);
R1 <= RC_SEL_TEMP1(3) AND Not(clear1);


-- for DHR2 and SrcReg2

DHR2_Result1_S2 <= ( DHR2(2) XNOR SrcReg2(0) ) AND  ( DHR2(3) XNOR SrcReg2(1) ) AND ( DHR2(4) XNOR SrcReg2(2) ) AND DHR2(0);
DHR2_Result2_S2 <= ( DHR2(5) XNOR SrcReg2(0) ) AND  ( DHR2(6) XNOR SrcReg2(1) ) AND ( DHR2(7) XNOR SrcReg2(2) ) AND (DHR2(0) AND DHR2(1)) ;
DP2_S2 <= DHR2_Result1_S2 OR DHR2_Result2_S2;


-- for DHR3 and SrcReg2

DHR3_Result1_S2 <= ( DHR3(2) XNOR SrcReg2(0) ) AND  ( DHR3(3) XNOR SrcReg2(1) ) AND ( DHR3(4) XNOR SrcReg2(2) ) AND DHR3(0);
DHR3_Result2_S2 <= ( DHR3(5) XNOR SrcReg2(0) ) AND  ( DHR3(6) XNOR SrcReg2(1) ) AND ( DHR3(7) XNOR SrcReg2(2) ) AND (DHR3(0) AND DHR3(1)) ;
DP3_S2 <= DHR3_Result1_S2 OR DHR3_Result2_S2;

-- select DP2
DP2 <= (DP2_S2 OR DP3_S2) AND Not(clear2);  -- here we out Right DP2
-- select R_C 1
RC3_OR_RC2_Mux_S2 : mux2_generic generic map (INPUT_WIDTH => 4) port map (DHR3(11 downto 8), DHR2(11 downto 8), DP2_S2, RC_SEL_TEMP2);

C2 <= RC_SEL_TEMP2(1) AND Not(clear2);
R2 <= RC_SEL_TEMP2(3) AND Not(clear2);


LOADCASE <= (DP2_S2 AND DHR2(11) AND Not(clear2)) OR (DP2_S1 AND DHR2(11) AND Not(clear1));

end a_RestDataHazard;

-- things to remember
--1 - na 3aml kolo leeh src 1 w src 2  el EXE_MEM deh na btl3 el C bt3 src1 ao src2 fe kda s7 wla el mfrod atl3 el 2 bit bt3o el c
