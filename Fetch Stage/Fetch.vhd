entity Fetch is
  port (
    clk,reset_sg,interrupt_sg:in std_logic;
    stall,RET_Ex_MEM, RTI_Ex_MEM,CALL_Ex_Mem,Predict,flush, Prediction_Done: in std_logic;
    Jmp_PC, Mem_data, PC_ID_EX: in std_logic_vector (31 downto 0);
    RTI_Buff, RET_Buff, CALL_Buff,RET_, RTI_, CALL_, INT_, reset_: out std_logic;
    IR_Buff: out std_logic_vector (15 downto 0);
    PPC: out std_logic_vector (31 downto 0)    
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
		address : IN  std_logic_vector(15 DOWNTO 0);
		datain  : IN  std_logic_vector(15 DOWNTO 0);
		dataout : OUT std_logic_vector(15 DOWNTO 0));
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

   -- interrrupt temp signals 
    signal reset,reset1,INT,INT2,INT3,INTZF,IntZ_notF,Jmpz2,ISR_PC,one_stall_int:  std_logic;
    --is jump signals 
    signal JMP,JMPZ,CALL,RET,RTI;
    -- jmp data hazard signals
    signal dp,one_over_2,exe_mem,c1,c2;
    --internal signals
    signal Jmp_Ready,CALL_out,RET_out,RTI_out,IR_MUX_Selector,

    signal big_mux_1_selector,big_mux_2_selector,PCMux_selector: std_logic_vector(1 downto 0);
    signal IR,NOP,IR_Buff_Buffer: std_logic_vector (15 downto 0);
    signal mem0, mem1,PC,muxTOMem,PC_plus_one,mux1_out,mux2_out,New_PC,PC_Input: std_logic_vector (31 downto 0);
    signal big_mux_1_out,big_mux_2_out, Jmp_Int_PC,mem2,mem3,PCMux_out: std_logic_vector (31 downto 0);
    signal PPC_mux1_out,PPC_mux2_out,PPC_mux3_out,Other_PC,PPC_Buffer: std_logic_vector (31 downto 0);

begin
    --temp signasl of interrupt
    reset <= reset_sg;
    reset1 <= '0';
    INT <= '0';
    INT2 <= '0';
    INT3 <= '0';
    INTZF <= '0';
    IntZ_notF <= '0';
    Jmpz2 <= '0';
    ISR_PC <= (others =>'0');
    one_stall_int <= '0'
    --is Jump
    JMP <= '0';
    JMPZ <= '0';
    CALL <= '0';
    RET <= '0';
    RTI <= '0';
    --jump data hazard
    dp <= '0';
    one_over_2 <= '0';
    exe_mem <= '0';
    c1 <= '0';
    c2 <= '0';
    -- 
    --jmp ready
    Jmp_Ready <= (( (c1 or c2) and dp ) or stall );

    --latches
    ret_latch: WAR_latch port map( (RET_Ex_MEM xor RET), clk, reset, RET, RET_out );
    RET_Buff <= not RET_out;
    RET_ <= RET;

    rti_latch: WAR_latch port map( (RTI_Ex_MEM xor RTI), clk, reset, RTI, RTI_out );
    RTI_Buff <= not RTI_out;
    RTI_ <= RTI;
    call_latch: WAR_latch port map( (CALL_Ex_Mem xor CALL), clk, reset, CALL, CALL_out );
    CALL_Buff <= not CALL_out;
    CALL_ <= CALL;

    INT_<= INT;
    reset_ <= reset;
    --memory part
    mem0 <= "00000000000000000000000000000000";
    mem1 <= "00000000000000000000000000000001";
    NOP <= "0000000000000000";
    before_mem_mux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (mem0, PC,reset_sg,muxTOMem);
    memory: instructionMemory port map(clk,'0',muxTOMem,"0000000000000000",IR);


    IR_MUX_Selector <= (flush or JMP or one_stall_int or JMPZ or INT2 or INT3 or stall or reset or RTI or RET);

    IRmux: mux2_generic GENERIC MAP (INPUT_WIDTH => 16) port map (IR, NOP,IR_MUX_Selector,IR_Buff_Buffer);
    IR_Buff <= IR_Buff_Buffer;

    --calculating pc input
    mux1: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one, Jmp_PC,Predict,mux1_out);
    
    big_mux_1_selector <= ( (JMPZ or Jmp_Ready) & (JMP or Jmp_Ready) );
    bigMux1: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_plus_one,Jmp_PC,mux1_out,PC,big_mux_1_selector,big_mux_1_out);

    mux2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (big_mux_1_out, Mem_data,(RTI_Ex_MEM or RET_Ex_MEM),mux2_out);

    mux3: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (mux2_out, PC_ID_EX, flush,New_PC);

    JmpIntPcReg: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(New_PC,clk,reset,INTZF,Jmp_Int_PC);

    big_mux_2_selector <= ( INT & INT2 );
    mem2 <= "00000000000000000000000000000010";
    mem3 <= "00000000000000000000000000000011";
    bigMux2: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(New_PC,mem3,mem2,mem3,big_mux_2_selector,big_mux_2_out);

    mux4: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (big_mux_2_out, ISR_PC, INT3,PC_Input);
    --other pc
    OtherPCMux: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_plus_one,Jmp_PC,(not Predict),Other_PC);
    
    --Pc register and PC buffer input 
    PCMux_selector <= (reset_sg & reset1);
    PCMux: mux4_generic GENERIC MAP (INPUT_WIDTH => 32) port map(PC_Input,ISR_PC,mem1,ISR_PC,PCMux_selector,PCMux_out);

    PCReg: generic_WAR_reg GENERIC MAP (REG_WIDTH => 32) port map(PCMux_out,clk,reset,(not one_stall_int),PC);

    --TO DO add the adder
    PPCmux1: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one,Other_PC,JMPZ,PPC_mux1_out);

    PPCmux2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PC_plus_one,PC_ID_EX,flush,PPC_mux2_out);
    
    PPCmux3: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PPC_mux1_out,New_PC,(INT xor INTZF),PPC_mux3_out);

    PPCmux2: mux2_generic GENERIC MAP (INPUT_WIDTH => 32) port map (PPC_mux3_out,PPC_mux2_out,IntZ_notF,PPC_Buffer);
    PPC <= PPC_Buffer;
    
end Fetch_arch ; -- arch