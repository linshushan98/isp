module Matrix_gen
#(
	parameter DW = 8,
	parameter ROW_DEPTH = 9
)
(
	input 	wire				clk,
	input 	wire				rst_n,
	
	input 	wire	[DW-1:0]	pixel_data_i,
	input	wire				valid,

	output	reg		[DW-1:0]	matrix_p11, matrix_p12, matrix_p13,	//3X3 Matrix output
	output	reg		[DW-1:0]	matrix_p21, matrix_p22, matrix_p23,
	output	reg		[DW-1:0]	matrix_p31, matrix_p32, matrix_p33
);

//Generate 3*3 matrix 
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//sync row3_data with per_frame_clken & row1_data & raw2_data
	wire	[DW-1:0]row1_data;	//frame data of the 1th row
	wire	[DW-1:0]row2_data;	//frame data of the 2th row
	wire 	[DW-1:0]row3_data;	//frame data of the 3th row
	
	// always@(posedge clk or negedge rst_n)begin
		// if(~rst_n)
			// row3_data <= 'b0;
		// else
			// row3_data <= pixel_data_i;	//20260112:第二行比第三行晚一拍放入
	// end
	assign row3_data = pixel_data_i;

	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
				{matrix_p11, matrix_p12, matrix_p13} <= 'b0;
				{matrix_p21, matrix_p22, matrix_p23} <= 'b0;
				{matrix_p31, matrix_p32, matrix_p33} <= 'b0;
		end
		else begin
			if(valid)begin
					{matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_data};	//1th shift input
					{matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_data};	//2th shift input
					{matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_data};	//3th shift input
			end
		end
	end

//20260112:第二行已经比第三行晚一拍放入了
//==================   缓存两行   ====================//	
	RAM_shift 
	#(
		.DW(DW),
		.DATA_DEPTH(ROW_DEPTH)
	)
	RAM_shift1
	(
		.clk(clk),
		.rst_n(rst_n),
		.din(row3_data),
		.en(valid),
		.Q(row2_data)			//较新的数据
	);

	RAM_shift 
	#(
		.DW(DW),
		.DATA_DEPTH(ROW_DEPTH)
	)
	RAM_shift2
	(
		.clk(clk),
		.rst_n(rst_n),
		.din(row2_data),
		.en(valid),
		.Q(row1_data)			//较早期的数据
	);


endmodule
