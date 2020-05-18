LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity decode_stage is
  port(
    clk: in std_logic;
    reset: in std_logic;
    flush: in std_logic;
    IR: in std_logic_vector (15 downto 0);
    PC_IF_EX:in std_logic_vector (31 downto 0);
    RET: in std_logic;
    INT : in std_logic;
    CALL: in std_logic;
    RTI: in std_logic;
    TWO_INST: in std_logic;
    jump_reg_add: in std_logic_vector (2 downto 0);
    dst1_add: in std_logic_vector (2 downto 0);
    dst2_add: in std_logic_vector (2 downto 0);
    dst1_data: in std_logic_vector (31 downto 0);
    dst2_data: in std_logic_vector (31 downto 0);
    dst1_write_enable: in std_logic;
    dst2_write_enable: in std_logic;
    dst_exec1: in std_logic_vector (31 downto 0);
    dst_exec2: in std_logic_vector (31 downto 0);
    exec_mem: in std_logic;
    one_or_two: in std_logic;
    DP: in std_logic;

    call_out:out std_logic;
    RET_out:out std_logic;
    PC_IF_EX_out:out std_logic_vector (31 downto 0);
    INT_out:out std_logic;
    RTI_out:out std_logic;

    reg_write1:out std_logic;
    reg_write2:out std_logic;
    memory_read:out std_logic;
    memory_write:out std_logic;
    alu_src2:out std_logic;
    alu_enable:out std_logic;
    out_signal:out std_logic;
    in_signal:out std_logic;
    jz:out std_logic;
    jmp:out std_logic;
    two_instruction_input: out std_logic;
    STALL: out std_logic;
    IR_out:out std_logic_vector (15 downto 0);
    EA:out std_logic_vector (31 downto 0);
    IMM:out std_logic_vector (31 downto 0);
    decreament_sp: out std_logic;
    increament_sp: out std_logic;
    TEMP_OUT:out std_logic_vector(4 downto 0);
    jump_reg_data: out std_logic_vector (31 downto 0);
    out1_data: out std_logic_vector (31 downto 0);
    out2_data: out std_logic_vector (31 downto 0);
    dst1_add_out:out std_logic_vector(2 downto 0);
    dst2_add_out:out std_logic_vector(2 downto 0);

    DHR1_decode_out: out std_logic_vector (11 downto 0);
    DHR2_decode_out: out std_logic_vector (11 downto 0);
    DHR3_decode_out: out std_logic_vector (11 downto 0);
    R1_out:out std_logic;
    R2_out:out std_logic;
    C1_out:out std_logic;
    C2_out:out std_logic;
    DP1_out:out std_logic;
    DP2_out:out std_logic;
    LOADCASE_out:out std_logic;
    JMP_PC: out std_logic_vector (31 downto 0)

  );
end decode_stage;

architecture  decode_stage_arch of decode_stage is

    component reg_file is
      port(
        src1_add: in std_logic_vector (2 downto 0);
        src2_add: in std_logic_vector (2 downto 0);
        dst1_add: in std_logic_vector (2 downto 0);
        dst2_add: in std_logic_vector (2 downto 0);
        jump_reg_add: in std_logic_vector (2 downto 0);
        dst1_data: in std_logic_vector (31 downto 0);
        dst2_data: in std_logic_vector (31 downto 0);
        dst1_write_enable: in std_logic;
        dst2_write_enable: in std_logic;
        out1_data: out std_logic_vector (31 downto 0);
        out2_data: out std_logic_vector (31 downto 0);
        jump_reg_data: out std_logic_vector (31 downto 0);
        clk: in std_logic;
        reset: in std_logic
      );
    end component;

    component control_unit is
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
        increament_sp: out std_logic;
        one_operand_out: out std_logic;
        two_operand_out: out std_logic;
        memory_out: out std_logic;
        reg_write2_out: out std_logic
      );
      end component;

      component RestDataHazard IS
      PORT(
      clk : IN std_logic;
      Enable, Reset, Two_Operand : IN std_logic;
      DHR2, DHR3 :IN std_logic_vector (11 downto 0);
      SrcReg1, SrcReg2 : IN std_logic_vector (2 downto 0);
      DP1, DP2, C1, C2, R1, R2, LOADCASE : OUT std_logic
      );
      END component ;

      component DHR is
        port (
          clk,reset, flush, stall, one_op, two_op, mem, IR11, IR12, reg2_wr: in std_logic;
          IR_20,I: in std_logic_vector(2 downto 0);
          DHR1_out,DHR2_out,DHR3_out: out std_logic_vector (11 downto 0)

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

    component mux4_generic is
    GENERIC(
       INPUT_WIDTH : INTEGER := 32);
      port (
        inp0: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
    	 inp1: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
     inp2: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
     inp3: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
        sel: in std_logic_vector (1 downto 0);
        mux_output: out std_logic_vector(INPUT_WIDTH - 1 downto 0)
      ) ;
    end component;

    component mux2_1bit is
      port (
        in1,in2: in std_logic;
    sel: in std_logic;
        mux_out: out std_logic
        );
    end component;

    signal src2_add: std_logic_vector(2 downto 0);

    signal IR_8_6: std_logic_vector(2 downto 0);
    signal IR_2_0: std_logic_vector (2 downto 0);
    signal mux2_out: std_logic_vector (2 downto 0);
    signal mux4_out: std_logic_vector (31 downto 0);
    signal memory: std_logic;
    signal IR_out_signal: std_logic_vector (15 downto 0);
    signal one_operand: std_logic;
    signal two_operand: std_logic;
    signal reg_write2_signal: std_logic;

    signal R1: std_logic;
    signal R2: std_logic;
    signal C1: std_logic;
    signal C2: std_logic;
    signal DP1: std_logic;
    signal DP2: std_logic;
    signal LOADCASE: std_logic;
    signal DHR1: std_logic_vector (11 downto 0);
    signal DHR2: std_logic_vector (11 downto 0);
    signal DHR3: std_logic_vector (11 downto 0);
    signal mux4_select: std_logic_vector(1 downto 0);
    signal and1_out: std_logic;
    signal and2_out: std_logic;
    signal stall_signal: std_logic;
    signal alu_enable_signal: std_logic;
    signal jump_reg_data_signal: std_logic_vector (31 downto 0);

    BEGIN

    IR_out <= IR_out_signal;
    IR_8_6 <= IR_out_signal(8 downto 6);
    IR_2_0 <= IR_out_signal(2 downto 0);
    src2_add <= IR_out_signal(5 downto 3);
    dst1_add_out <= IR_2_0;
    dst2_add_out <= mux2_out;
    stall_signal <= alu_enable_signal and LOADCASE;
    STALL <= stall_signal;
    call_out <= (CALL and (not (flush or reset)));
    RET_out <=  (RET and (not (flush or reset)));
    PC_IF_EX_out <=  PC_IF_EX;
    INT_out <=  INT;
    RTI_out <= (RTI and (not (flush or reset)));

    TEMP_OUT <= IR_out_signal(13 downto 9);
    DHR1_decode_out <= DHR1;
    DHR2_decode_out <= DHR2;
    DHR3_decode_out <= DHR3;
    C1_out <= C1;
    C2_out <= C2;
    DP1_out <= DP1;
    DP2_out <= DP2;
    LOADCASE_out <= LOADCASE;
    mux4_select <= exec_mem & one_or_two;
    and1_out <= C1 and stall_signal;
    and2_out <= C2 and stall_signal;
    alu_enable <= alu_enable_signal;
    jump_reg_data <= jump_reg_data_signal;

    mux2_R1: mux2_1bit PORT MAP(R1, '0', and2_out, R1_out);
    mux2_R2: mux2_1bit PORT MAP(R2, '0', and1_out, R2_out);
    mux2:mux2_generic GENERIC MAP (INPUT_WIDTH => 3) PORT MAP(IR_8_6, IR_2_0,memory, mux2_out);

    mux2_jmp_pc:mux2_generic GENERIC MAP (INPUT_WIDTH => 32) PORT MAP(jump_reg_data_signal, mux4_out, DP, JMP_PC);
    mux4:mux4_generic GENERIC MAP (INPUT_WIDTH => 32) PORT MAP(dst_exec1, dst_exec2, dst1_data, dst2_data, mux4_select, mux4_out);
    reg_file1:reg_file PORT MAP (mux2_out, src2_add, dst1_add, dst2_add, jump_reg_add, dst1_data, dst2_data, dst1_write_enable,
                                  dst2_write_enable, out1_data, out2_data, jump_reg_data_signal, clk, reset);

    control_unit1:control_unit PORT MAP (clk, reset, flush, IR, CALL, RTI, INT, TWO_INST, reg_write1, reg_write2, memory_read, memory_write,
                                          alu_src2, out_signal, in_signal, alu_enable_signal, jz, jmp,memory, two_instruction_input, IR_out_signal,EA, IMM,
                                          decreament_sp, increament_sp, one_operand, two_operand, memory, reg_write2_signal);

    dhr_regs:DHR PORT MAP (clk, reset, flush, stall_signal, one_operand, two_operand, memory, IR_out_signal(11)
                  , IR_out_signal(12), reg_write2_signal, IR_2_0, mux2_out, DHR1, DHR2, DHR3);

    data_hazard1:RestDataHazard PORT MAP (clk,'1', reset, two_operand, DHR2, DHR3, mux2_out, src2_add, DP1, DP2, C1, C2, R1, R2, LOADCASE);


end decode_stage_arch;
