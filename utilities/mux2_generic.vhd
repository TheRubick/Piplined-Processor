LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity mux2_generic is
GENERIC(
   INPUT_WIDTH : INTEGER := 1);
  port (
    in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
sel: in std_logic;
    mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
    );
end entity mux2_generic ;

architecture mux2_generic_arch  of mux2_generic  is
begin
    mux_out <= in1 when sel='0'
		else in2;

end mux2_generic_arch ;
