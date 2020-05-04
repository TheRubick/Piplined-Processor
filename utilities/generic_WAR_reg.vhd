LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


entity generic_WAR_reg is
GENERIC(
   REG_WIDTH : INTEGER := 16);
  port (
    d: in std_logic_vector (REG_WIDTH - 1 downto 0);
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic_vector (REG_WIDTH - 1 downto 0)

  ) ;
end generic_WAR_reg;

architecture generic_reg_arch of generic_WAR_reg is
begin
    process( d,clk,clear )
    begin
        if (clear = '1') then
            q <= (others =>'0');
        elsif (rising_edge(clk) and enable='1') then
            q <= d;
        end if;
     end process ;


end generic_reg_arch ;
