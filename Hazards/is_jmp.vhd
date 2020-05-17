LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity is_jmp is
  port (
	clk,reset,not_stall : in std_logic;
    IR : in std_logic_vector(15 downto 0);
	RTI,RET,CALL,JMP,JZ : out std_logic;
	Src_Reg_out : out std_logic_vector(2 downto 0)
  ) ;
end is_jmp;

architecture is_jmp_arch of is_jmp is

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

signal src : std_logic_vector(2 downto 0);
signal x,call_wire : std_logic;
begin
	src <= IR(8) & IR(7) & IR(6);
	Src_Reg : generic_WAR_reg GENERIC MAP(REG_WIDTH => 3) port map(src,clk,reset,not_stall,Src_Reg_out);
	
	x <= IR(14) and IR(13);
	RTI <= x and IR(12) and IR(11) and IR(9);
	RET <= x and IR(12) and IR(11) and not(IR(10)) and not(IR(9));
	call_wire <= x and IR(10) and not(IR(12)) and not(IR(11)) and not(IR(9));
	CALL <= call_wire;
	JMP <= call_wire or (x and IR(9) and not(IR(12)) and not(IR(11)) and not(IR(10)));
	JZ <= x and (((IR(12) nor IR(11)) nor IR(10)) nor IR(9));
end is_jmp_arch;