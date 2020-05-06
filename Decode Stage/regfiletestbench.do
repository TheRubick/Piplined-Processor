vsim -gui work.reg_file
add wave -position insertpoint sim:/reg_file/*
force -freeze sim:/reg_file/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/reg_file/reset 0 0
force -freeze sim:/reg_file/dst1_add 000 0
force -freeze sim:/reg_file/dst2_add 001 0
force -freeze sim:/reg_file/dst1_data 00000000000000000000000000000011 0
force -freeze sim:/reg_file/dst2_data 00000000000000000000000000000001 0
force -freeze sim:/reg_file/dst1_write_enable 1 0
force -freeze sim:/reg_file/dst2_write_enable 1 0
force -freeze sim:/reg_file/src1_add 000 0
force -freeze sim:/reg_file/src2_add 001 0
force -freeze sim:/reg_file/jump_reg_add 001 0
run
force -freeze sim:/reg_file/dst1_write_enable 0 0
force -freeze sim:/reg_file/dst2_write_enable 0 0
run