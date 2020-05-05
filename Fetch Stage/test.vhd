Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity jimmy_test is
  port (
    in1: std_logic_vector (1 downto 0);
    out1: out std_logic_vector (1 downto 0)
  ) ;
end jimmy_test;

architecture jimmy_test_arch of jimmy_test is
    
    
begin

   out1 <= in1 + 1;
    

end jimmy_test_arch ; -- arch