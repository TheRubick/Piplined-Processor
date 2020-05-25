Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY BranchPredicator IS
PORT(
RST , CLK     :  IN std_logic;
ZeroFlag, JMPZ   :  IN std_logic;
Predication, Predication_Done, Flush :  OUT std_logic
);
END BranchPredicator ;

architecture a_BranchPredicator of BranchPredicator is

component FSM is
port ( input: in std_logic;
clk,rst,enable: in std_logic;
output: out std_logic);
end component;


  signal result,compare : std_logic;

begin
  compare <= ZeroFlag Xnor result when CLK = '1' else
            compare ;
  Predication <= '1';
  Flush <= '1' when rst = '0' and JMPZ = '1' and compare = '0' else
           '0';
  Predication_Done <= '1' when rst = '0' and JMPZ = '1' else
                      '0' ;
  -- process (CLK ,JMPZ, ZeroFlag )
  --     begin
  --         if rst = '1' then
  --             Flush <= '0';
  --             Predication_Done <= '0';
  --       elsif CLK = '1' and JMPZ = '1' then
  --           if  compare = '1' then
  --               Flush <= '0';
  --           else
  --             report "I entered here " ;
  --             Flush <= '1';
  --           end if;
  --         Predication_Done <= '1';
  --       elsif JMPZ = '0' then
  --         Flush <= '0';
  --         Predication_Done <= '0';
  --       end if;
  --     end process;


FSM_Predicator : FSM port map (ZeroFlag, CLK, RST, '0', result);

end a_BranchPredicator;
