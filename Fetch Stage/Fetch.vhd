Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Fetch is
  port (
    clk,reset_sg,interrupt_sg:in std_logic;
    stall,RET_Ex_MEM, RTI_Ex_MEM,CALL_Ex_Mem,Predict,flush, Prediction_Done: in std_logic;
    Jmp_PC, Mem_data, PC_ID_EX: in std_logic_vector (31 downto 0);
    RTI_Buff, RET_Buff, CALL_Buff, INT_module_out, reset_module_out: out std_logic;
    IR_Buff: out std_logic_vector (15 downto 0);
    PPC: out std_logic_vector (31 downto 0);
    jump_reg_add: out std_logic_vector (2 downto 0);
    Jmp_Int_PC: out std_logic_vector (31 downto 0);
    DHR1, DHR2, DHR3: in std_logic_vector (11 downto 0);
    one_two_out, exe_mem_out, dp_out: out std_logic
  ) ;
end Fetch;

architecture Fetch_arch of Fetch is

    component WAR_latch is
        port (
          d: in std_logic;
          clk: in std_logic;
          clear: in std_logic;
      enable: in std_logic;
          q: out std_logic
      
        ) ;
    end component;


    component instructionMemory IS
      PORT(
          clk : IN std_logic;
          we  : IN std_logic;
          PCaddress : IN  std_logic_vector(31 DOWNTO 0);
          datain : IN std_logic_vector(15 DOWNTO 0 );
          instruction : OUT std_logic_vector(15 DOWNTO 0));
    END component;

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
            INPUT_WIDTH : INTEGER := 16);
            port (
            inp0: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
                inp1: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
            inp2: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
            inp3: IN std_logic_vector (INPUT_WIDTH - 1 downto 0);
            sel: in std_logic_vector (1 downto 0);
            mux_output: out std_logic_vector(INPUT_WIDTH - 1 downto 0)
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
     component Interrupt is
      port (
        clk: in std_logic;
        interrupt_sg: in std_logic;
        reset_sg: in std_logic;
        JMP: in std_logic;
        RET: in std_logic;
        RTI: in std_logic;
        JMPZ: in std_logic;
        IR: in std_logic_vector (15 downto 0);
        RTI_MEM: in std_logic;
        RET_MEM: in std_logic;
        JMP_Ready: in std_logic;
        Prediction_Done: in std_logic;
        reset: out std_logic;
        reset1: out std_logic;
        INT: out std_logic;
        INT2: out std_logic;
        INT3: out std_logic;
        INTZF: out std_logic;
        IntZ_notF: out std_logic;
        Jmpz2: out std_logic;
        ISR_PC: out std_logic_vector (31 downto 0);
        one_stall_int: out std_logic
      ) ;
    end component;

    component is_jmp is
      port (
      not_stall : in std_logic;
        IR : in std_logic_vector(15 downto 0);
      RTI,RET,CALL,JMP,JZ : out std_logic;
      Src_Reg_out : out std_logic_vector(2 downto 0)
      ) ;
    end component;

    component JmpDataHazard IS
    PORT(
    DHR1 , DHR2, DHR3 :IN std_logic_vector (11 downto 0);
    Enable , Reset : IN std_logic;
    SrcReg : IN std_logic_vector (2 downto 0);
    DP, F_1_2, EXE_MEM : OUT std_logic;
    Cycles : OUT std_logic_vector (1 downto 0)
    );
    END component ;
    

   -- interrrupt temp signals 
    signal reset,reset1,INT,INT2,INT3,INTZF,IntZ_notF,Jmpz2,one_stall_int:  std_logic;
    signal ISR_PC: std_logic_vector (31 downto 0);
    --is jump signals 
    signal JMP,JMPZ,CALL,RET,RTI, isJumpEnable: std_logic;
    signal src_reg: std_logic_vector (2 downto 0);
    -- jmp data hazard signals
    signal dp,one_over_2,exe_mem,c1,c2, JmpDataHazard_en: std_logic;
    signal cycles: std_logic_vector (1 downto 0);
    --internal signals
    signal Jmp_Ready,CALL_out,RET_out,RTI_out,IR_MUX_Selector: std_logic;
    signal ret_Latch_input,rti_latch_input,call_latch_input,mux2_selector: std_logic;
    signal others_pc_mux_selector,PC_reg_enable,PPC_Mux3_selector: std_logic;

    

    signal big_mux_1_selector,big_mux_2_selector,PCMux_selector: std_logic_vector(1 downto 0);
    signal IR,NOP,IR_Buff_Buffer: std_logic_vector (15 downto 0);
    signal mem0, mem1,PC,muxTOMem,PC_plus_one,mux1_out,mux2_out,New_PC,PC_Input: std_logic_vector (31 downto 0);
    signal big_mux_1_out,big_mux_2_out ,mem2,mem3,PCMux_out: std_logic_vector (31 downto 0);
    signal PPC_mux1_out,PPC_mux2_out,PPC_mux3_out,Other_PC,PPC_Buffer: std_logic_vector (31 downto 0);

begin

  --


  -- interrupt 
  interrupt_module: Interrupt port map(clk,interrupt_sg,reset_sg,JMP,RET,RTI,JMPZ,IR,RTI_Ex_MEM,RET_Ex_MEM,
                      Jmp_Ready,Prediction_Done,
                      reset,reset1,INT,INT2,INT3,INTZF,IntZ_notF,Jmpz2,ISR_PC,one_stall_int);
    jump_reg_add <= src_reg;
    --temp signasl of interrupt
    --reset <= reset_sg;
    --reset1 <= '0';
    --INT <= '0';
    --INT2 <= '0';
    --INT3 <= '0';
    --INTZF <= '0';
    --IntZ_notF <= '0';
    --Jmpz2 <= '0';
    --ISR_PC <= (others =>'0');
    --one_stall_int <= '0';
    --is Jump
    isJumpEnable <= (not (stall or INT2 or INT3 or flush or one_stall_int));
    isJump: is_jmp port map(isJumpEnable,IR,RTI,RET,CALL,JMP,JMPZ,src_reg);
    --JMP <= '0';
    --JMPZ <= '0';
    --CALL <= '0';
    --RET <= '0';
    --RTI <= '0';
    --jump data hazard
    JmpDataHazard_en <= (not (stall or flush)) and (RTI or RET or CALL or JMP or JMPZ);
    jmpDataHazard_circuit: JmpDataHazard port map(DHR1, DHR2, DHR3, JmpDataHazard_en, reset,src_reg,
    dp,one_over_2,exe_mem,cycles);
    one_two_out <= one_over_2;
    exe_mem_out <= exe_mem; 
    dp_out <= dp;
    --dp <= '0';
    --one_over_2 <= '0';
    --exe_mem <= '0';
    c1 <= cycles(0);
    c2 <= cycles(1);
    -- 
    --jmp ready
    Jmp_Ready <= ((( (c1 or c2) and dp ) or stall )) or RET or RTI;

    --latches
    --ret_Latch_input <= (RET_Ex_MEM xor RET);
    --ret_latch: WAR_latch port map(ret_Latch_input , clk, reset, RET, RET_out );
    --RET_Buff <= not RET_out;
    --RET_module_out <= RET;
    RET_Buff <= RET;

    --rti_latch_input <= (RTI_Ex_MEM xor RTI);
    --rti_latch: WAR_latch port map( rti_latch_input, clk, reset, RTI, RTI_out );
    --RTI_Buff <= not RTI_out;
    --RTI_module_out <= RTI;
    RTI_Buff <= RTI;

    --call_latch_input <= (CALL_Ex_Mem xor CALL);
    --call_latch: WAR_latch port map( call_latch_input, clk, reset, CALL, CALL_out );
    --CALL_Buff <= not CALL_out;
    --CALL_module_out <= CALL;
    CALL_Buff <= CALL;
    ----------changed interrrupt
    --INT_module_out<= INT;
    INT_module_out<= INT2;

    reset_module_out <= reset;
    --memory part
    mem0 <= "00000000000000000000000000000000";
    mem1 <= "00000000000000000000000000000001";
    NOP <= "0000000000000000";
    before_mem_mux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC, mem0,reset_sg,muxTOMem);
    memory: instructionMemory port map(clk,'0',muxTOMem,"0000000000000000",IR);


    IR_MUX_Selector <= (flush or JMP or one_stall_int or (JMPZ and dp) or INT2 or INT3 or stall or reset or RTI or RET);

    IRmux: mux2_generic GENERIC MAP (INPUT_WIDTH => 16) port map (IR, NOP,IR_MUX_Selector,IR_Buff_Buffer);
    IR_Buff <= IR_Buff_Buffer;

    --calculating pc input
    mux1: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one, Jmp_PC,Predict,mux1_out);
    
    big_mux_1_selector <= ( (JMPZ or Jmp_Ready) & (JMP or Jmp_Ready) );
    bigMux1: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_plus_one,Jmp_PC,mux1_out,PC,big_mux_1_selector,big_mux_1_out);

    mux2_selector <= (RTI_Ex_MEM or RET_Ex_MEM);
    mux2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (big_mux_1_out, Mem_data, mux2_selector,mux2_out);

    mux3: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (mux2_out, PC_ID_EX, flush,New_PC);

    JmpIntPcReg: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(New_PC,clk,reset,INTZF,Jmp_Int_PC);

    big_mux_2_selector <= ( INT & INT2 );
    mem2 <= "00000000000000000000000000000010";
    mem3 <= "00000000000000000000000000000011";
    bigMux2: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(New_PC,mem3,mem2,mem3,big_mux_2_selector,big_mux_2_out);

    mux4: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (big_mux_2_out, ISR_PC, INT3,PC_Input);
    --other pc
    others_pc_mux_selector <= (not Predict);
    OtherPCMux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_plus_one,Jmp_PC,others_pc_mux_selector,Other_PC);
    
    --Pc register and PC buffer input 
    PCMux_selector <= (reset_sg & reset1);
    PCMux: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_Input,ISR_PC,mem1,ISR_PC,PCMux_selector,PCMux_out);

    PC_reg_enable <= (not one_stall_int);
    PCReg: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(PCMux_out,clk,'0',PC_reg_enable,PC);

    PC_plus_one <= PC + 1;
    
    PPCmux1: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one,Other_PC,JMPZ,PPC_mux1_out);

    PPCmux2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one,PC_ID_EX,flush,PPC_mux2_out);
    
    PPC_Mux3_selector <= (INT xor INTZF);
    PPCmux3: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PPC_mux1_out,New_PC,PPC_Mux3_selector,PPC_mux3_out);

    PPCmux4: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PPC_mux3_out,PPC_mux2_out,IntZ_notF,PPC_Buffer);
    PPC <= PPC_Buffer;
    
end Fetch_arch ; -- arch