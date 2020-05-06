LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity reg_file is
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
end reg_file;

architecture  reg_file_arch of reg_file is
    component decoder38 is
      port ( d_input: in std_logic_vector (2 downto 0);
      d_enable: in std_logic;
      d_output: out std_logic_vector (7 downto 0)
      ) ;
    end component decoder38;

    component generic_RAW_reg is
      GENERIC(REG_WIDTH : INTEGER := 16);
      port (
        d: in std_logic_vector (REG_WIDTH - 1 downto 0);
        clk: in std_logic;
        clear: in std_logic;
        enable: in std_logic;
        q: out std_logic_vector (REG_WIDTH - 1 downto 0)
      ) ;
    end component;

    component tristateBuffer is
      port (
        tsb_input: in std_logic_vector (31 downto 0);
        enable: in std_logic;
        tsb_output: out std_logic_vector (31 downto 0)
      ) ;
    end component;
    signal data1: std_logic_vector (31 downto 0);
    signal data2: std_logic_vector (31 downto 0);
    signal dataBus1: std_logic_vector (31 downto 0);
    signal dataBus2: std_logic_vector (31 downto 0);
    signal out1: std_logic_vector (31 downto 0);
    signal out2: std_logic_vector (31 downto 0);
    signal out3: std_logic_vector (31 downto 0);
    signal dst1DecoderOut: std_logic_vector (7 downto 0);
    signal dst2DecoderOut: std_logic_vector (7 downto 0);
    signal src1DecoderOut: std_logic_vector (7 downto 0);
    signal src2DecoderOut: std_logic_vector (7 downto 0);
    signal jmpDecoderOut: std_logic_vector (7 downto 0);
    signal regInEnable: std_logic_vector (7 downto 0);

    type data is array (0 to 7) of std_logic_vector (31 downto 0);
    signal dataOut: data;
    signal reg_in: data;
BEGIN
    loop1: FOR i IN 0 TO 7 GENERATE
        regs: generic_RAW_reg GENERIC MAP (REG_WIDTH => 32) PORT MAP(reg_in(i) , clk ,reset, regInEnable(i), dataOut(i));
        tristateInBuffers1: tristateBuffer PORT MAP(data1 ,dst1DecoderOut(i) ,dataBus1);
        tristateInBuffers2: tristateBuffer PORT MAP(data2 ,dst2DecoderOut(i) ,dataBus2);
        tristateOutBuffers1: tristateBuffer PORT MAP(dataOut(i) ,src1DecoderOut(i) ,out1);
        tristateOutBuffers2: tristateBuffer PORT MAP(dataOut(i) ,src2DecoderOut(i) ,out2);
        tristateOutBuffers3: tristateBuffer PORT MAP(dataOut(i) ,jmpDecoderOut(i) ,out3);
        regInEnable(i) <= dst1DecoderOut(i) OR dst2DecoderOut(i);
        reg_in(i) <= dataBus1 when dst1DecoderOut(i) = '1' else dataBus2;
    END GENERATE loop1;
    data1 <= dst1_data;
    data2 <= dst2_data;
    out1_data <= out1;
    out2_data <= out2;
    jump_reg_data <= out3;
    dst1Decoder:decoder38 PORT MAP(dst1_add ,dst1_write_enable ,dst1DecoderOut);
    dst2Decoder:decoder38 PORT MAP(dst2_add ,dst2_write_enable ,dst2DecoderOut);
    src1Decoder:decoder38 PORT MAP(src1_add, '1', src1DecoderOut);
    src2Decoder:decoder38 PORT MAP(src2_add, '1', src2DecoderOut);
    jmpDecoder:decoder38 PORT MAP(jump_reg_add, '1', jmpDecoderOut);
end reg_file_arch;
