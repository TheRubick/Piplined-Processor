LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity mux2_1bit is
  port (
    in1,in2: in std_logic;
sel: in std_logic;
    mux_out: out std_logic
    );
end entity mux2_1bit ;

architecture mux2_1bit_arch  of mux2_1bit  is
begin
    mux_out <= in1 when sel='0'
		else in2;

end mux2_1bit_arch ;
