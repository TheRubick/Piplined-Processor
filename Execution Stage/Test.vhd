LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


entity Special_latch is
  port (
    d: in std_logic;
    clk: in std_logic;
    clear: in std_logic;
enable: in std_logic;
    q: out std_logic

  ) ;
end Special_latch;


architecture Special_latch_arch of Special_latch is

  component WAR_latch is
  port (
    d: in std_logic;
    clk: in std_logic;
    clear: in std_logic;
  enable: in std_logic;
    q: out std_logic

  ) ;
  end component;


  signal tempout,reset,tempin : std_logic;


begin

  reset <= not(tempin) or clear;
  tempin <= d ;

  call_latch  : WAR_latch port map(tempin, CLK, reset , '1', tempout);

    process( d,clk,clear )
    begin
        if (clear = '1') then
            q <= '0';
        elsif (rising_edge(clk) and enable='1') then
      		if ( tempin = '1' and tempout =  '0' ) then
                  q <= '1' ;
          end if;
          if ( tempout = '1' ) then
                  q <= '0' ;
          end if ;

          end if;
        end process ;


end Special_latch_arch ;
--
-- begin
--
--   EX_VAR : process (i_clk)
--     variable Temp : std_logic := '0';
--   begin
--     if falling_edge(i_clk) then
--
--       Temp := '1';
--       o_done <= Temp;
--     elsif rising_edge(i_clk) then
--       Temp := '0';
--       o_done <= Temp;
--
--     end if;
--   end process EX_VAR;
--
--
-- end rtl;
