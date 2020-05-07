
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity decoder42 is
  port ( d_input: in std_logic_vector (1 downto 0);
  d_enable: in std_logic;
  d_output: out std_logic_vector (3 downto 0)
  ) ;
end decoder42;

architecture decoder42_arch of decoder42 is
begin
    d_output(0) <= d_enable and ((not d_input(0)) and (not d_input(1)));
    d_output(1) <= d_enable and ( d_input(0) and (not d_input(1)));
    d_output(2) <= d_enable and ((not d_input(0)) and  d_input(1));
    d_output(3) <= d_enable and ( d_input(0) and  d_input(1));


end decoder42_arch ; 