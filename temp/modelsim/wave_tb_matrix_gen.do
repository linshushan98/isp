onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/DW
add wave -noupdate /tb_matrix_gen/matrix_gen/COL_NUM
add wave -noupdate /tb_matrix_gen/matrix_gen/ROW_NUM
add wave -noupdate /tb_matrix_gen/matrix_gen/N_COL
add wave -noupdate /tb_matrix_gen/matrix_gen/N_ROW
add wave -noupdate /tb_matrix_gen/matrix_gen/clk
add wave -noupdate /tb_matrix_gen/matrix_gen/rst_n
add wave -noupdate -radix unsigned -radixshowbase 0 /tb_matrix_gen/matrix_gen/pixel_data_i
add wave -noupdate /tb_matrix_gen/matrix_gen/valid_i
add wave -noupdate -color {Violet Red} /tb_matrix_gen/matrix_gen/valid_o
add wave -noupdate -color Yellow -radix unsigned /tb_matrix_gen/matrix_gen/pos_x_o
add wave -noupdate -color Yellow -radix unsigned /tb_matrix_gen/matrix_gen/pos_y_o
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p11
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p12
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p13
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p21
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p22
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p23
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p31
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p32
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/m_p33
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p11
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p12
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p13
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p21
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p22
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p23
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p31
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p32
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/p33
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/row1_data
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/row2_data
add wave -noupdate -radix unsigned /tb_matrix_gen/matrix_gen/row3_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {205 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 245
configure wave -valuecolwidth 51
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {327 ns} {818 ns}
