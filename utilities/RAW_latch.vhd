LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


entity RAW_latch is
  port (
    d: in std_logic;
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic

  ) ;
end RAW_latch;

architecture RAW_latch_arch of RAW_latch is
begin
    process( d,clk,clear )
    begin
        if (clear = '1') then
            q <= '0';
        elsif (falling_edge(clk) and enable='1') then
            q <= d;
        end if;
     end process ;


end RAW_latch_arch ;
