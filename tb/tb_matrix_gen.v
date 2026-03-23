`timescale 1ns/1ns
module tb_matrix_gen();

parameter DW = 8;
parameter COL_NUM = 32;
parameter ROW_NUM = 32;
localparam N_COL = $clog2(COL_NUM);
localparam N_ROW = $clog2(ROW_NUM);

reg						clk                  ;
reg						rst_n		         ;
reg[DW-1:0]				pixel_data_i         ;
reg						valid_i              ;
											 
wire[DW-1:0]			m_p11, m_p12, m_p13  ;
wire[DW-1:0]			m_p21, m_p22, m_p23  ;
wire[DW-1:0]			m_p31, m_p32, m_p33  ;
wire [N_COL+N_ROW-1:0]	pos_px_o		     ;
wire 					valid_o              ;


initial begin
	clk           =0;
	rst_n		  =0;
	pixel_data_i  =0;
	valid_i       =0;
	#33;rst_n = 1;
end

always begin
	#5; clk=!clk;
end

initial begin
	wait(rst_n);// 等待复位释放 
	forever begin
		send_pixel();
	end
end

task send_pixel();
	begin
		@(negedge clk);
		pixel_data_i = pixel_data_i + 1;
		valid_i = 1;
		// @(negedge clk);
		// valid_i = 0;
		// @(negedge clk);
		// @(negedge clk);
	end
endtask

wire [DW-1:0]	pixel_data_i_final;
assign pixel_data_i_final = valid_i ? pixel_data_i : 'dx;


matrix_gen
#(
	.DW        (DW),
	.COL_NUM   (COL_NUM),
	.ROW_NUM   (ROW_NUM)
)
matrix_gen
(
	.clk           (clk),
	.rst_n         (rst_n),
				   
	.pixel_data_i  (pixel_data_i_final),
	.valid_i       (valid_i),

	.m_p11(m_p11),	.m_p12(m_p12), 	.m_p13(m_p13),
	.m_p21(m_p21), 	.m_p22(m_p22), 	.m_p23(m_p23),
	.m_p31(m_p31), 	.m_p32(m_p32), 	.m_p33(m_p33),
	.pos_px_o(pos_px_o),
	.valid_o (valid_o)
);

endmodule 
