vsim work.alu
# vsim work.alu
# Start time: 00:40:40 on May 05,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading ieee.std_logic_arith(body)
# Loading ieee.std_logic_unsigned(body)
# Loading work.alu(a_alu)
add wave -position end  sim:/alu/ALU_Enable
add wave -position end  sim:/alu/IR
add wave -position end  sim:/alu/INPUTA
add wave -position end  sim:/alu/INPUTB
add wave -position end  sim:/alu/ALUOUT
add wave -position end  sim:/alu/REGFLAGIN
add wave -position end  sim:/alu/REGFLAGOUT
add wave -position end  sim:/alu/SHIFT
add wave -position end  sim:/alu/ShiftTemp
add wave -position end  sim:/alu/ShiftValue
add wave -position end  sim:/alu/OUTPUT

# Initliaze
force -freeze sim:/alu/ALU_Enable 0 0
force -freeze sim:/alu/IR 0000000000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000000 0
force -freeze sim:/alu/REGFLAGIN 0000 0
run

force -freeze sim:/alu/ALU_Enable 1 0


# Test Cases

# NOT TEST
force -freeze sim:/alu/IR 0000100000000000 0
# NOT 1 NEG flag = 1
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
run
# NOT all  NEG flag = 0 and zero flag = 1
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
run

# AND TEST
force -freeze sim:/alu/IR 0010010000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 10000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 10000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000010 0
run

# OR TEST
force -freeze sim:/alu/IR 0010011000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 10000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000000000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000000 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000010 0
run


# SHIFT right
force -freeze sim:/alu/IR 0011101000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 10000000000000000000000000000101 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 00000000100000000000000000000101 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000100 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000000 0
run


# SHIFT Left
force -freeze sim:/alu/IR 0011100000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 10000000000000000000000000000101 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000100000 0
force -freeze sim:/alu/INPUTB 00000000100000000000000000000101 0
run
force -freeze sim:/alu/INPUTA 11000000000000000000000000000000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 11000000000000000000000000000000 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000000 0
run



# Test arthimtic operation

# INC
force -freeze sim:/alu/IR 0001001000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
run
force -freeze sim:/alu/INPUTA 01111111111111111111111111111111 0
run

# DEC
force -freeze sim:/alu/IR 0001000000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000000000 0
run

# ADD
force -freeze sim:/alu/IR 0010000000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 10000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 01111111111111111111111111111111 0
run

# SUB
force -freeze sim:/alu/IR 0010001000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 10000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
force -freeze sim:/alu/INPUTB 11111111111111111111111111111111 0
run
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run

# ADI
force -freeze sim:/alu/IR 0011110000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 10000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
force -freeze sim:/alu/INPUTA 01111111111111111111111111111111 0
run


# SWAP
force -freeze sim:/alu/IR 0010100000000000 0
force -freeze sim:/alu/INPUTA 00000000000000000000000000000001 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run
force -freeze sim:/alu/INPUTA 10000000000000000000000000000101 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000011 0
run
force -freeze sim:/alu/INPUTA 11111111111111111111111111111111 0
force -freeze sim:/alu/INPUTB 00000000000000000000000000000001 0
run
