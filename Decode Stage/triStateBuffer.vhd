LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity tristateBuffer is
  port (
    tsb_input: in std_logic_vector (31 downto 0);
    enable: in std_logic;
    tsb_output: out std_logic_vector (31 downto 0)
  ) ;
end tristateBuffer;

architecture tristateBuffer_arch of tristateBuffer is
begin

    tsb_output<=tsb_input when enable = '1'
    else (others =>'Z');

end tristateBuffer_arch ;
