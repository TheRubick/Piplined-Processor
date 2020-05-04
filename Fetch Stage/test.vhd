LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity jimmy_test is
  port (
    in1,in2: in std_logic_vector (0 downto 0);
    sel: in std_logic;
    out1: out std_logic_vector (0 downto 0)
  ) ;
end jimmy_test;

architecture jimmy_test_arch of jimmy_test is
    component mux2_generic is
        GENERIC(
           INPUT_WIDTH : INTEGER := 1);
          port (
            in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
        sel: in std_logic;
            mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
            );
    end component;
    signal muxout: std_logic_vector (0 downto 0); 

begin

    muxx: mux2_generic GENERIC MAP (INPUT_WIDTH => 1) port map(in1,in2,sel,muxout);
    out1 <= muxout;

end jimmy_test_arch ; -- arch