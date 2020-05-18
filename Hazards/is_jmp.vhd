LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity is_jmp is
  port (
	not_stall : in std_logic;
    IR : in std_logic_vector(15 downto 0);
	RTI,RET,CALL,JMP,JZ : out std_logic;
	Src_Reg_out : out std_logic_vector(2 downto 0)
  ) ;
end is_jmp;

architecture is_jmp_arch of is_jmp is

signal x,call_wire : std_logic;
begin
	Src_Reg_out <= IR(8) & IR(7) & IR(6);
	--Src_Reg : generic_WAR_reg GENERIC MAP(REG_WIDTH => 3) port map(src,clk,reset,not_stall,Src_Reg_out);
	
	x <= IR(14) and IR(13) and not_stall;
	RTI <= x and IR(12) and IR(11) and IR(9) and not_stall;
	RET <= x and IR(12) and IR(11) and not(IR(10)) and not(IR(9)) and not_stall;
	call_wire <= x and IR(10) and not(IR(12)) and not(IR(11)) and not(IR(9)) and not_stall;
	CALL <= call_wire and not_stall;
	JMP <= (call_wire or (x and IR(9) and not(IR(12)) and not(IR(11)) and not(IR(10)))) and not_stall;
	JZ <= x and not(IR(12)) and not(IR(11)) and not(IR(10)) and not(IR(9)) and not_stall;
end is_jmp_arch;