LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

ENTITY Mem_WB_entity IS
	PORT(
		reg1_wr_mem,reg2_wr_mem,clk,reset : IN  std_logic;
		dst1_add_mem,dst2_add_mem : IN std_logic_vector(2 downto 0);
		dst1_mem_input,dst2_mem_input : IN  std_logic_vector(31 DOWNTO 0);
		reg1_wr_mem_output,reg2_wr_mem_output : OUT std_logic;
		dst1_add_mem_output,dst2_add_mem_output : OUT std_logic_vector(2 downto 0);
		dst1_mem_output,dst2_mem_output : OUT std_logic_vector(31 DOWNTO 0)
		);
END ENTITY Mem_WB_entity;

ARCHITECTURE Mem_WB_arch OF Mem_WB_entity IS
	--Latch component
	component WAR_latch is
	  port (
		d: in std_logic;
		clk: in std_logic;
		clear: in std_logic;
	enable: in std_logic;
		q: out std_logic

	  ) ;
	 end component;

	--generic latch component
	component generic_WAR_reg is
	GENERIC(
	   REG_WIDTH : INTEGER := 16);
	  port (
		d: in std_logic_vector (REG_WIDTH - 1 downto 0);
		clk: in std_logic;
		clear: in std_logic;
	enable: in std_logic;
		q: out std_logic_vector (REG_WIDTH - 1 downto 0)

	  ) ;
	end component; 
BEGIN

	--Latches 
		dst1MemLatch : generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(dst1_mem_input,clk,reset,'1',dst1_mem_output);
		dst2MemLatch : generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(dst2_mem_input,clk,reset,'1',dst2_mem_output);
		
		reg1WrMemLatch : WAR_latch port map(reg1_wr_mem,clk,reset,'1',reg1_wr_mem_output);
		reg2WrMemLatch : WAR_latch port map(reg2_wr_mem,clk,reset,'1',reg2_wr_mem_output);
		
		dst1AddMemLatch : generic_WAR_reg GENERIC MAP (REG_WIDTH => 3) port map(dst1_add_mem,clk,reset,'1',dst1_add_mem_output);
		dst2AddMemLatch : generic_WAR_reg GENERIC MAP (REG_WIDTH => 3) port map(dst2_add_mem,clk,reset,'1',dst2_add_mem_output);
END Mem_WB_arch;