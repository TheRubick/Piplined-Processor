Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity DHR is
  port (
    clk,reset, flush, stall, one_op, two_op, mem, IR11, IR12, reg2_wr: in std_logic;
    IR_20,I: in std_logic_vector(2 downto 0);
    DHR1_out,DHR2_out,DHR3_out: out std_logic_vector (11 downto 0)

  ) ;
end DHR;

architecture DHR_arch of DHR is

    component generic_RAW_reg is
        GENERIC(
        REG_WIDTH : INTEGER := 16);
        port (
            d: in std_logic_vector (REG_WIDTH - 1 downto 0);
            clk: in std_logic;
            clear: in std_logic;
            enable: in std_logic;
            q: out std_logic_vector (REG_WIDTH - 1 downto 0)

        );
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

    signal if_1, mem_part, mux_selector, main_and: std_logic;
    signal reg1_rst,reg2_rst,reg3_rst, reg2_en, reg1_0: std_logic;
    signal mux_out, zero_one, one_zero, zero_zero: std_logic_vector (1 downto 0);
    signal reg1_out, reg2_out , reg3_out : std_logic_vector (11 downto 0);
    signal reg1_in, reg2_in , reg3_in : std_logic_vector (11 downto 0);

begin
    zero_one <= "01";
    one_zero <= "10";
    zero_zero <= "00";


    if_1 <= (IR11 or IR12) and one_op;
    mem_part <= (not (IR11 xor IR12) ) and mem;

    main_and <= if_1 or mem_part or two_op;
    reg1_0 <= (not flush) and main_and;
    reg1_rst <= ((not reg1_0) or reset);

    -- MUX part
    mux_selector <= ( (IR11 and IR12) and one_op) or mem_part;

    mux: mux2_generic GENERIC MAP (INPUT_WIDTH => 2) port map (zero_one,one_zero,mux_selector,mux_out);

    -- 1st register
    reg1_in <= ( mux_out & zero_zero & I & IR_20 & reg2_wr & reg1_0);
    DHR1: generic_RAW_reg GENERIC MAP (REG_WIDTH => 12) port map(reg1_in ,clk,reg1_rst,'1',reg1_out);
    DHR1_out <= reg1_out;

    -- 2nd regsiter
    reg2_rst <= (not reg1_out(0)) or reset;
    reg2_en <= not stall;
    reg2_in <= ( reg1_out (11 downto 10) & zero_one & reg1_out(7 downto 0));
    DHR2: generic_RAW_reg GENERIC MAP (REG_WIDTH => 12) port map(reg2_in ,clk,reg2_rst,reg2_en,reg2_out);
    DHR2_out <= reg2_out;

    -- 3rd register
    reg3_rst <= ((not reg2_out(0)) or stall) or reset;
    reg3_in <= ( one_zero & one_zero & reg2_out( 7 downto 0));
    DHR3: generic_RAW_reg GENERIC MAP (REG_WIDTH => 12) port map(reg3_in ,clk,reg3_rst,'1',reg3_out);
    DHR3_out <= reg3_out;

end DHR_arch ; -- arch
