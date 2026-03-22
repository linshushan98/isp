module Dilation_bin
#(
	parameter ROW_DEPTH = 512
)
(
	input		clk,  				//cmos video pixel clock
	input		rst_n,				//global reset

	input wire	din,
	
	output wire dout		
);

//============define  1Bit 3X3 Matrix =================//

	wire matrix_p11, matrix_p12, matrix_p13;	//3X3 Matrix output
	wire matrix_p21, matrix_p22, matrix_p23;
	wire matrix_p31, matrix_p32, matrix_p33;



//Add you arithmetic here
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//-------------------------------------------
//-------------------------------------------
//Eronsion Parameter
//      Original         Dilation			  Pixel
// [   0  0   0  ]   [   1	1   1 ]     [   P1  P2   P3 ]
// [   0  1   0  ]   [   1  1   1 ]     [   P4  P5   P6 ]
// [   0  0   0  ]   [   1  1	1 ]     [   P7  P8   P9 ]
//P = P1 & P2 & P3 & P4 & P5 & P6 & P7 & 8 & 9;
//---------------------------------------
//Eonsion with or operation
//Step1
reg	post_img_Bit1,	post_img_Bit2,	post_img_Bit3;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		post_img_Bit1 <= 1'b0;
		post_img_Bit2 <= 1'b0;
		post_img_Bit3 <= 1'b0;
		end
	else
		begin
		post_img_Bit1 <= matrix_p11 | matrix_p12 | matrix_p13;
		post_img_Bit2 <= matrix_p21 | matrix_p22 | matrix_p23;
		post_img_Bit3 <= matrix_p31 | matrix_p32 | matrix_p33;
		end
end

//Step 2
// reg	post_img_Bit4;
// always@(posedge clk or negedge rst_n)
// begin
	// if(!rst_n)
		// post_img_Bit4 <= 1'b0;
	// else
		// post_img_Bit4 <= post_img_Bit1 & post_img_Bit2 & post_img_Bit3;
// end

	wire post_img_Bit4;

	assign post_img_Bit4 = post_img_Bit1 | post_img_Bit2 | post_img_Bit3;
	assign dout = post_img_Bit4;






	Matrix_gen
	#(
		. DW(1),
		. ROW_DEPTH(ROW_DEPTH)
	)
	Matrix_gen1
	(
		.clk(clk),
		.rst_n(rst_n),
		.pixel_data_i(din),
		.matrix_p11(matrix_p11),	.matrix_p12(matrix_p12), 	.matrix_p13(matrix_p13),	//3X3 Matrix output
		.matrix_p21(matrix_p21), 	.matrix_p22(matrix_p22), 	.matrix_p23(matrix_p23),
		.matrix_p31(matrix_p31), 	.matrix_p32(matrix_p32), 	.matrix_p33(matrix_p33)
	);









endmodule