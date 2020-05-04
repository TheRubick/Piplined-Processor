LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity mux4_1bit is
  port (
    inp0: IN std_logic;
	 inp1: IN std_logic;
 inp2: IN std_logic;
 inp3: IN std_logic;
    sel: in std_logic_vector (1 downto 0);
    mux_output: out std_logic
  ) ;
end mux4_1bit ;

architecture mux4_1bit_arch  of mux4_1bit  is
    component mux2_1bit is
        port (
          in1,in2: in std_logic;
      sel: in std_logic;
          mux_out: out std_logic
          );
      end component ;
  signal s1,s2 :std_logic;

begin
    l0: mux2_1bit  port map(inp0,inp1,sel(0),s1);
    l1: mux2_1bit   port map(inp2,inp3,sel(0),s2);
    l2: mux2_1bit   port map(s1,s2,sel(1),mux_output);

end mux4_1bit_arch;
