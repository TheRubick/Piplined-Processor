LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity control_unit is
port(
  clk: in std_logic;
  reset: in std_logic;
  flush: in std_logic;
  IR_in: in std_logic_vector (15 downto 0);
  call: in std_logic;
  RTI: in std_logic;
  interrupt: in std_logic;
  two_instruction: in std_logic;
  reg_write1: out std_logic;
  reg_write2: out std_logic;
  memory_read: out std_logic;
  memory_write: out std_logic;
  alu_src2: out std_logic;
  out_signal: out std_logic;
  in_signal: out std_logic;
  alu_enable: out std_logic;
  jz: out std_logic;
  jmp: out std_logic;
  mem_out: out std_logic;
  two_instruction_input: out std_logic;
  IR_out:out std_logic_vector (15 downto 0);
  EA: out std_logic_vector (31 downto 0);
  IMM: out std_logic_vector (31 downto 0);
  decreament_sp: out std_logic;
  increament_sp: out std_logic
);
end control_unit;

architecture control_unit_arch of control_unit is

    signal decoderOut: std_logic_vector (3 downto 0);
    signal one_operand: std_logic;
    signal two_operand: std_logic;
    signal memory: std_logic;
    signal branch: std_logic;
    signal reset_flush: std_logic;
    signal decoderIn: std_logic_vector (1 downto 0);
    signal mux1_out: std_logic;
    signal mux2_out: std_logic_vector (15 downto 0);
    signal mux3_out: std_logic_vector (15 downto 0);
    signal X: std_logic:= '0';
    signal nop: std_logic_vector (15 downto 0);
    signal IR_temp_out: std_logic_vector (15 downto 0);
    signal decreament_sp_signal: std_logic;
    signal increament_sp_signal: std_logic;
    signal return_signal: std_logic;
    signal reg_write1_signal: std_logic;
    signal reg_write2_signal: std_logic;
    signal memory_read_signal: std_logic;
    signal memory_write_signal: std_logic;
    signal alu_src2_signal: std_logic;
    signal out_signal_signal: std_logic;
    signal in_signal_signal: std_logic;
    signal alu_enable_signal: std_logic;
    signal jz_signal: std_logic;
    signal jmp_signal: std_logic;
    signal stall_out: std_logic;
    signal IR: std_logic_vector (15 downto 0);
    signal two_instruction_mux_out: std_logic;

    component decoder42 is
      port ( d_input: in std_logic_vector (1 downto 0);
      d_enable: in std_logic;
      d_output: out std_logic_vector (3 downto 0)
      ) ;
    end component;

    component mux2_generic is
    GENERIC(
       INPUT_WIDTH : INTEGER := 1);
      port (
        in1,in2: in std_logic_vector (INPUT_WIDTH - 1 downto 0);
        sel: in std_logic;
        mux_out: out std_logic_vector (INPUT_WIDTH - 1 downto 0)
        );
    end component;

    component mux2_1bit is
      port (
        in1,in2: in std_logic;
    sel: in std_logic;
        mux_out: out std_logic
        );
    end component;

    component WAR_latch is
      port (
        d: in std_logic;
        clk: in std_logic;
        clear: in std_logic;
    enable: in std_logic;
        q: out std_logic

      ) ;
    end component;

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
    nop <= "0000000000000000";

    decoderIn <= IR(14) & IR(13);
    decoder:decoder42 PORT MAP(decoderIn, '1', decoderOut);
    X <= (IR_in(15) and (not two_instruction) );
    mux2:mux2_generic GENERIC MAP (INPUT_WIDTH => 16) PORT MAP(IR_in, nop, X, mux2_out);

    IR_temp:generic_WAR_reg GENERIC MAP (REG_WIDTH => 16) PORT MAP (IR_in, clk, reset, X, IR_temp_out);
    mux3:mux2_generic GENERIC MAP (INPUT_WIDTH => 16) PORT MAP(mux2_out, IR_temp_out, two_instruction, mux3_out);
    mux4:mux2_generic GENERIC MAP (INPUT_WIDTH => 16) PORT MAP(mux3_out, nop, flush, IR);

    two_inst_mux: mux2_1bit PORT MAP('0', '1', X, two_instruction_mux_out);

    two_instruction_input <= ( (not flush) and two_instruction_mux_out );
    IR_out <= IR;
    EA <=  (31 downto 20 => IR_temp_out(6)) & IR_temp_out(6) & IR_temp_out(5) & IR_temp_out(4) & IR_temp_out(3) & IR_in;
    IMM <= (31 downto 16 => IR_in(15)) & IR_in;

    one_operand <= decoderOut(0);
    two_operand <= decoderOut(1);
    memory <= decoderOut(2);
    mem_out <= memory;
    branch <= decoderOut(3);


    reset_flush <= reset OR flush;
    reg_write1_signal <= (not reset_flush) AND (((IR(11) OR IR(12)) AND one_operand) OR two_operand OR (memory AND (not IR(11))));
    reg_write1 <= reg_write1_signal;
    reg_write2_signal <= (not reset_flush) AND (two_operand AND (IR(11) AND (not IR(12))));
    reg_write2 <= reg_write2_signal;
    decreament_sp_signal <= (not reset_flush) AND ((not IR(12)) AND (not IR(11)) AND memory);
    increament_sp_signal <= (not reset_flush) AND ((not IR(12)) AND IR(11) AND memory);
    decreament_sp <= decreament_sp_signal;
    increament_sp <= increament_sp_signal;
    return_signal <= (not reset_flush) AND (branch AND IR(12) AND (not IR(9)));
    memory_read_signal <= (not reset_flush) AND (increament_sp_signal OR return_signal OR RTI OR (IR(10) AND IR(9) AND memory));
    memory_read <= memory_read_signal;
    memory_write_signal <= (not reset_flush) AND (decreament_sp_signal OR call OR interrupt OR (IR(11) AND IR(12) AND memory));
    memory_write <= memory_write_signal;
    alu_src2_signal <= (not reset_flush) AND (IR(11) AND IR(12));
    alu_src2 <= alu_src2_signal;
    out_signal_signal <=  (not reset_flush) AND (IR(9) AND IR(10) AND (not IR(11)) AND (not IR(12)) AND one_operand);
    out_signal <= out_signal_signal;
    in_signal_signal <=  (not reset_flush) AND (IR(9) AND (not IR(10)) AND IR(11) AND IR(12) AND one_operand);
    in_signal <= in_signal_signal;
    alu_enable_signal <=  (not reset_flush) AND (not (((not IR(12)) AND (not IR(11)) AND (not IR(13))) OR (IR(11) AND IR(12) AND (not IR(13))) OR IR(14)));
    alu_enable <= alu_enable_signal;
    jz_signal <=  (not reset_flush) AND (IR(13) AND (not IR(12)) AND (not IR(9)));
    jz <= jz_signal;
    jmp_signal <= (not reset_flush) AND (IR(13) AND (not IR(12)) AND IR(9));
    jmp <= jmp_signal;




end control_unit_arch;
