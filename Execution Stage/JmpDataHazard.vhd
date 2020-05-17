Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY JmpDataHazard IS
PORT(
DHR1 , DHR2, DHR3 :IN std_logic_vector (11 downto 0);
Enable , Reset : IN std_logic;
SrcReg : IN std_logic_vector (2 downto 0);
DP, F_1_2, EXE_MEM : OUT std_logic;
Cycles : OUT std_logic_vector (1 downto 0)
);
END JmpDataHazard ;

architecture a_JmpDataHazard of JmpDataHazard is

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
signal  DP_SEL, clear, DP_Final, Temp_1_2 ,Final_1_2 : std_logic;
signal DHR1_Result1, DHR1_Result2, DP1, DST1_1_2  :std_logic;
signal DHR2_Result1, DHR2_Result2, DP2, DST2_1_2 :std_logic;
signal DHR3_Result1, DHR3_Result2, DP3, DST3_1_2 :std_logic;
signal RC_SEL_TEMP , RC_Final : std_logic_vector (3 downto 0);  -- temps to store RC bits


begin

clear <= Reset OR  Not(Enable);

DHR1_Result1 <= ( DHR1(2) XNOR SrcReg(0) ) AND  ( DHR1(3) XNOR SrcReg(1) ) AND ( DHR1(4) XNOR SrcReg(2) ) AND DHR1(0);
DHR1_Result2 <= ( DHR1(5) XNOR SrcReg(0) ) AND  ( DHR1(6) XNOR SrcReg(1) ) AND ( DHR1(7) XNOR SrcReg(2) ) AND (DHR1(0) AND DHR1(1)) ;
DP1 <= DHR1_Result1 OR DHR1_Result2;
DST1_1_2_Mux: mux2_1bit  port map ('0', '1', DHR1_Result2, DST1_1_2);

-- for DHR2 and SrcReg

DHR2_Result1 <= ( DHR2(2) XNOR SrcReg(0) ) AND  ( DHR2(3) XNOR SrcReg(1) ) AND ( DHR2(4) XNOR SrcReg(2) ) AND DHR2(0);
DHR2_Result2 <= ( DHR2(5) XNOR SrcReg(0) ) AND  ( DHR2(6) XNOR SrcReg(1) ) AND ( DHR2(7) XNOR SrcReg(2) ) AND (DHR2(0) AND DHR2(1)) ;
DP2 <= DHR2_Result1 OR DHR2_Result2;
DST2_1_2_Mux: mux2_1bit  port map ('0', '1', DHR2_Result2, DST2_1_2);

-- for DHR3 and SrcReg

DHR3_Result1 <= ( DHR3(2) XNOR SrcReg(0) ) AND  ( DHR3(3) XNOR SrcReg(1) ) AND ( DHR3(4) XNOR SrcReg(2) ) AND DHR3(0);
DHR3_Result2 <= ( DHR3(5) XNOR SrcReg(0) ) AND  ( DHR3(6) XNOR SrcReg(1) ) AND ( DHR3(7) XNOR SrcReg(2) ) AND (DHR3(0) AND DHR3(1)) ;
DP3 <= DHR3_Result1 OR DHR3_Result2;
DST3_1_2_Mux: mux2_1bit  port map ('0', '1', DHR3_Result2, DST3_1_2);

-- for multiple dependency:

-- select 1_2
DHR3_OR_DHR2_Mux : mux2_1bit  port map (DST3_1_2, DST2_1_2, DP2, Temp_1_2);
DHR2_3_OR_DHR1_Mux : mux2_1bit  port map (Temp_1_2, DST1_1_2, DP1, Final_1_2); -- here we out Right DST 1 or DST 2

F_1_2  <= Final_1_2 WHEN clear = '0' Else -- out signal 1_2
       '0';


-- select DP
DP_Final <= DP1 OR DP2 OR DP3 ;

DP <= DP_Final WHEN clear = '0' Else -- here we out Right DP
      '0';

-- select R_C
RC3_OR_RC2_Mux : mux2_generic generic map (INPUT_WIDTH => 4) port map (DHR3(11 downto 8), DHR2(11 downto 8), DP2, RC_SEL_TEMP);
RC2_3_OR_RC1_Mux : mux2_generic generic map (INPUT_WIDTH => 4) port map (RC_SEL_TEMP, DHR1(11 downto 8), DP1, RC_Final);

Cycles <= RC_Final(3 downto 2) - RC_Final(1 downto 0)  WHEN clear = '0' Else  -- here we calcualte Cycles R - C
          "00";

EXE_MEM <=  RC_Final(3)  WHEN clear = '0' Else  -- out bit number 11 R from neart reg dep when 0 -> data ready at exectue / 1-> data ready at mem
            '0';

end a_JmpDataHazard;

-- things to remember
--1 - rl reg value m7tota 2 3 4 wla 4 3 2  w brdo nfs el klam lel c w r el first bit dy el rqm 11 wla rqm 10
