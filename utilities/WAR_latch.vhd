LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


entity WAR_latch is
  port (
    d: in std_logic;
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic

  ) ;
end WAR_latch;

architecture WAR_latch_arch of WAR_latch is
begin
    process( d,clk,clear )
    begin
        if (clear = '1') then
            q <= '0';
        elsif (rising_edge(clk) and enable='1') then
            q <= d;
        end if;
     end process ;


end WAR_latch_arch ;
