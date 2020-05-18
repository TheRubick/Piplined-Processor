library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity variable_ex is
  port (
    i_clk   : in std_logic;
    o_done  : out std_logic
    );
end variable_ex;

architecture rtl of variable_ex is


begin

  EX_VAR : process (i_clk)
    variable Temp : std_logic := '0';
  begin
    if falling_edge(i_clk) then

      Temp := not(Temp);
      o_done <= Temp;

    end if;
  end process EX_VAR;



end rtl;
