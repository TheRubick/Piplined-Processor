Library ieee;
use ieee.std_logic_1164.all;

ENTITY FSM is
port ( input: in std_logic;
clk,rst,enable: in std_logic;
output: out std_logic);
end entity;

    Architecture mooreFSM of FSM is

            type states is (Strongly_Taken,Weakly_Taken,Weakly_Not_Taken,Strongly_Not_Taken);
            signal current_state : states := Strongly_Taken;

        begin 
            process (clk,rst)
                begin
                    if rst = '1' then
                        current_state <= Strongly_Taken;
                  elsif falling_edge(clk) and enable = '1' then
                    case current_state is
                        when Strongly_Taken =>
                           if input = '1' then current_state <= Strongly_Taken; else current_state <= Weakly_Taken; end if;
                        when Weakly_Taken =>
                            if input = '1' then current_state <= Strongly_Taken; else current_state <= Weakly_Not_Taken; end if;
                        when Weakly_Not_Taken =>
                            if input = '1' then current_state <= Weakly_Taken; else current_state <= Strongly_Not_Taken; end if;
                        when Strongly_Not_Taken =>
                            if input = '1' then current_state <= Weakly_Not_Taken; else current_state <= Strongly_Not_Taken; end if;
                    end case;
                  end if;
                end process;

            process (current_state)
            begin
                case current_state is
                    when Strongly_Taken | Weakly_Taken   =>
                        output <= '1';
                    when Strongly_Not_Taken | Weakly_Not_Taken =>
                        output <= '0';
                end case;
            end process;

        end Architecture;
