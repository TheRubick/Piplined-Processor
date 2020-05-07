
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity decoder38 is
  port ( d_input: in std_logic_vector (2 downto 0);
  d_enable: in std_logic;
  d_output: out std_logic_vector (7 downto 0)
  ) ;
end decoder38;

architecture decoder38_arch of decoder38 is
begin
    d_output(0) <= d_enable and ((not d_input(2)) and (not d_input(1)) and (not d_input(0)));
    d_output(1) <= d_enable and ( (not d_input(2)) and (not d_input(1)) and d_input(0));
    d_output(2) <= d_enable and ((not d_input(2)) and  d_input(1) and (not d_input(0)));
    d_output(3) <= d_enable and ((not d_input(2)) and (d_input(1)) and (d_input(0)));
    d_output(4) <= d_enable and ((d_input(2)) and (not d_input(1)) and (not d_input(0)));
    d_output(5) <= d_enable and ((d_input(2)) and (not d_input(1)) and (d_input(0)));
    d_output(6) <= d_enable and ((d_input(2)) and (d_input(1)) and (not d_input(0)));
    d_output(7) <= d_enable and ((d_input(2)) and (d_input(1)) and (d_input(0)));

end decoder38_arch ; 