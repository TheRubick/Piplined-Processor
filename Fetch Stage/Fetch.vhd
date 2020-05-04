entity Fetch is
  port (
    clock,reset_sg,interrupt_sg:in std_logic;
    RTI_Buf, RET_Buff, Call_Buf,RET_, RTI_, CALL, INT, reset: out std_logic;
    IR_Buff: out std_logic_vector (15 downto 0);
    PPC: out std_logic_vector (31 downto 0)    
  ) ;
end Fetch;

architecture Fetch_arch of Fetch is

    
    
    signal 

begin

end Fetch_arch ; -- arch