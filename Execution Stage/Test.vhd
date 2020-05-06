Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY TEST IS
PORT(

 CLK , Write_enable     :  IN std_logic;
 Address_Read : IN  std_logic_vector(31 DOWNTO 0);
 data_write  : IN  std_logic_vector(31 DOWNTO 0);
 data_read : OUT std_logic_vector(31 DOWNTO 0)
);
END TEST ;

architecture a_TEST of TEST is
  component dataMemory IS
  	PORT(
  		clk : IN std_logic;
  		we  : IN std_logic;
  		address : IN  std_logic_vector(31 DOWNTO 0);
  		datain  : IN  std_logic_vector(31 DOWNTO 0);
  		dataout : OUT std_logic_vector(31 DOWNTO 0));
  END component dataMemory;





  signal result : std_logic_vector(3 downto 0);
  signal sel1 : std_logic_vector(1 downto 0);


begin

RAM : dataMemory port map (CLK , Write_enable , Address_Read , data_write , data_read);

end a_TEST;
