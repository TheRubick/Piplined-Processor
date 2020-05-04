LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity mux4_generic is
GENERIC(
   INPUT_WIDTH : INTEGER := 16);
  port (
    inp0: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
	 inp1: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
 inp2: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
 inp3: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
    sel: in std_logic_vector (1 downto 0);
    mux_output: out std_logic_vector(INPUT_WIDTH - 1 downto 0)
  ) ;
end mux4_generic ;

architecture mux4_generic_arch  of mux4_generic  is
component mux2_generic is
GENERIC(
   INPUT_WIDTH : INTEGER := 1);
  port (
    in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
sel: in std_logic;
    mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
    );
end component;
  signal s1,s2 :std_logic_vector(INPUT_WIDTH - 1 downto 0);

begin
    l0: mux2_generic GENERIC MAP (INPUT_WIDTH => INPUT_WIDTH) port map(inp0,inp1,sel(0),s1);
    l1: mux2_generic GENERIC MAP (INPUT_WIDTH => INPUT_WIDTH) port map(inp2,inp3,sel(0),s2);
    l2: mux2_generic GENERIC MAP (INPUT_WIDTH => INPUT_WIDTH) port map(s1,s2,sel(1),mux_output);

end mux4_generic_arch;
