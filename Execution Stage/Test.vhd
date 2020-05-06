Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY TEST IS
PORT(
--INPUTA ,INPUTB :  IN std_logic_vector(3 downto 0);
RST , CLK     :  IN std_logic;
in1,in2,in3,in4      :  IN std_logic_vector(3 downto 0);   --  - zero - negative - carry
--REGFLAGOUT     :  OUT std_logic_vector(3 downto 0);
--ALU_Enable     :  IN std_logic;
 DP1, C1 :  IN std_logic
);
END TEST ;

architecture a_TEST of TEST is

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




  signal result : std_logic_vector(3 downto 0);
  signal sel1 : std_logic_vector(1 downto 0);
  

begin
sel1 <= dp1 & c1;
INPUT1_Mux : mux4_generic generic map (INPUT_WIDTH => 4) port map (in1, in2, in3, in4,sel1 ,result);

end a_TEST;
