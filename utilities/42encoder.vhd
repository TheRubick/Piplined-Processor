LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity encoder42 is
  port (
      en_input: in std_logic_vector (3 downto 0);
      en_out: out std_logic_vector (1 downto 0)
  ) ;
end encoder42;


architecture encoder42_arch of encoder42 is

    
begin

en_out(0)<= en_input(1) or en_input(3);
    en_out(1)<= (not en_input(1)) and (not en_input(0));


end encoder42_arch ; -- arch