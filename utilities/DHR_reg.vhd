LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity generic_DHR_reg is
GENERIC(
   REG_WIDTH : INTEGER := 16);
  port (
    d: in std_logic_vector (REG_WIDTH - 1 downto 0);
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic_vector (REG_WIDTH - 1 downto 0);
    flag : out std_logic

  ) ;
end generic_DHR_reg;

architecture generic_DHR_arch of generic_DHR_reg is
begin
    process( d,clk,clear )
      variable Temp : std_logic := '0';
    begin
        if (clear = '1') then
            q <= (others =>'0');
        elsif (falling_edge(clk) and enable='1') then
            q <= d;
            Temp := '1';
            flag <= Temp;
          elsif rising_edge(clk) then
            Temp := '0';
          flag <= Temp;
        end if;
     end process ;


end generic_DHR_arch ;
