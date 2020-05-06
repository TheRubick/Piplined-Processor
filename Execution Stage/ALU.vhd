Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY ALU IS
PORT(

INPUTA ,INPUTB :  IN std_logic_vector(31 downto 0);
ALU_Enable     :  IN std_logic;
ALUOUT         :  OUT std_logic_vector(31 downto 0);
IR  	         :  IN std_logic_vector(15 downto 0);
REGFLAGIN      :  IN std_logic_vector(3 downto 0);   --  - zero - negative - carry
REGFLAGOUT     :  OUT std_logic_vector(3 downto 0)
);
END ALU ;

ARCHITECTURE a_ALU of ALU is

  -- Signals used to store result values
 
SIGNAL INC, DEC, SUB, ADD, IN1, IN2 : std_logic_vector(32 downto 0):= (others => '0');

SIGNAL OUTPUT : std_logic_vector (31 downto 0) := (others => '0');
SIGNAL SHIFT  : std_logic_vector (31 downto 0) := (others => '0');
SIGNAL ShiftValue : integer := 0;
SIGNAL ShiftTemp  : integer := 0;


BEGIN

IN1 <= '0' & INPUTA;
IN2 <= '0' & INPUTB;

ADD <= IN1 + In2 ;
SUB <= IN1 - IN2 ;
DEC <= IN1 - 1 ;
INC <= In1 + 1 ;

ShiftTemp <= to_integer(signed(INPUTB));

ShiftValue <= 32 when ShiftTemp > 32 OR ShiftTemp < 0 else
             ShiftTemp ;

          -- 2 OPERAND INSTRUCTIONS
OUTPUT <= INPUTA AND INPUTB   WHEN IR(14 downto 9 ) = "010010" ELSE  -- AND
          INPUTA OR  INPUTB   WHEN IR(14 downto 9 ) = "010011" ELSE  -- OR
          ADD(31 downto 0)    WHEN IR(14 downto 9 ) = "010000" ELSE  -- ADD
          ADD(31 downto 0)    WHEN IR(14 downto 9 ) = "011110" ELSE  -- ADI
          SUB(31 downto 0)    WHEN IR(14 downto 9 ) = "010001" ELSE  -- SUB
          INPUTB              WHEN IR(14 downto 9 ) = "010100" ELSE  -- SWAP
          INPUTA ((31 - ShiftValue) downto 0) & SHIFT(31 downto (32 - ShiftValue)) WHEN IR(14 downto 9 ) = "011100" AND ShiftValue /= 0 ELSE  -- LSL
          INPUTA              WHEN IR(14 downto 9 ) = "011100" AND ShiftValue = 0 ELSE  -- LSL at zero shift case
          SHIFT(31 downto (32 - ShiftValue)) & INPUTA (31 downto ShiftValue) WHEN IR(14 downto 9 ) = "011101" AND ShiftValue /= 0 ELSE  -- LSR
          INPUTA              WHEN IR(14 downto 9 ) = "011101" AND ShiftValue = 0 ELSE  -- LSL at zero shift case
          -- ONE OPERAND INSTRUCTIONS
          NOT INPUTA          WHEN IR(14 downto 9 ) = "000100" ELSE  -- NOT
          INC(31 downto 0)    WHEN IR(14 downto 9 ) = "001001" ELSE  -- INC
          DEC(31 downto 0)    WHEN IR(14 downto 9 ) = "001000" ELSE  -- DEC
          "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";



ALUOUT <= OUTPUT WHEN  OUTPUT /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" AND ALU_Enable = '1'  ELSE
	        --INPUTA WHEN (OUTPUT /= "ZZZZZZZZZZZZZZZZ" OR INPUTA /= "ZZZZZZZZZZZZZZZZ") AND  S = "01011" ELSE
           "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";   -- SET ALU_OUTPUT

          --UPDATE CARRY FLAG

REGFLAGOUT(1)   <= SUB(32) WHEN IR(14 downto 9 ) = "010001" AND ALU_Enable = '1' ELSE  -- SUB
                   ADD(32) WHEN IR(14 downto 9 ) = "010000" AND ALU_Enable = '1' ELSE  -- ADD
                   ADD(32) WHEN IR(14 downto 9 ) = "011110" AND ALU_Enable = '1' ELSE  -- ADI
                   INC(32) WHEN IR(14 downto 9 ) = "001001" AND ALU_Enable = '1' ELSE  -- INC
                   DEC(32) WHEN IR(14 downto 9 ) = "001000" AND ALU_Enable = '1' ELSE  -- DEC
                   INPUTA(31) WHEN IR(14 downto 9 ) = "011100" AND ALU_Enable = '1' AND ShiftValue /= 0 ELSE  -- LSL
                   INPUTA(0)  WHEN IR(14 downto 9 ) = "011101" AND ALU_Enable = '1' AND ShiftValue /= 0 ELSE  -- LSR
                   REGFLAGIN(1);  -- If not arthimtic or shift keep carry FLAG as it is

          --UPDATE negative FLAG

REGFLAGOUT(2)   <= '1' WHEN OUTPUT(31) = '1' AND ALU_Enable = '1' AND IR(14 downto 9 ) /= "010100"  ELSE
                   '0' WHEN OUTPUT(31) = '0' AND ALU_Enable = '1' AND IR(14 downto 9 ) /= "010100" ELSE
                   REGFLAGIN(2);

          --UPDATE ZERO FLAG

REGFLAGOUT(3)   <= '1' WHEN OUTPUT  = "00000000000000000000000000000000" AND ALU_Enable = '1' AND IR(14 downto 9 ) /= "010100"  ELSE
                   '0' WHEN OUTPUT /= "00000000000000000000000000000000" AND ALU_Enable = '1' AND IR(14 downto 9 ) /= "010100"  ELSE
                   REGFLAGIN(3);

REGFLAGOUT(0)   <= '0';
END a_ALU ;

 -- NOTES :

 -- 1- --- Shift right w left a3tbrto logicl msh arthimtic wla el mfrod yb2a arthimtic ?
 -- 2- ---  hoa a7na 2olna el swap hy7sl bel alu
 -- 3- ---  carry fel shift hyt3ml azy y3ny ?
