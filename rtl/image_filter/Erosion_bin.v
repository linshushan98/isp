module Erosion_bin
#(
	parameter COL_NUM = 512,
	parameter ROW_NUM = 512
)
(
	input		clk,  				//cmos video pixel clock
	input		rst_n,				//global reset

	input	wire	din,
	input	wire	valid_i,
	output	wire	dout,
	output 	reg		valid_o
);

//============define  1Bit 3X3 Matrix =================//

wire m_p11, m_p12, m_p13;	//3X3 Matrix output
wire m_p21, m_p22, m_p23;
wire m_p31, m_p32, m_p33;


//生成3x3的图像，用于算法计算

wire matrix_gen_valid_o;
matrix_gen
#(
	.DW        (1),
	.COL_NUM   (COL_NUM),
	.ROW_NUM   (ROW_NUM)
)
matrix_gen
(
	.clk           (clk),
	.rst_n         (rst_n),
				   
	.pixel_data_i  (din),
	.valid_i       (valid_i),

	.m_p11(m_p11),	.m_p12(m_p12), 	.m_p13(m_p13),
	.m_p21(m_p21), 	.m_p22(m_p22), 	.m_p23(m_p23),
	.m_p31(m_p31), 	.m_p32(m_p32), 	.m_p33(m_p33),
	.pos_px_o(),
	.valid_o (matrix_gen_valid_o)
);



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
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		begin
			post_img_Bit1 <= 1'b0;
			post_img_Bit2 <= 1'b0;
			post_img_Bit3 <= 1'b0;
		end
	else
		begin
			post_img_Bit1 <= m_p11 & m_p12 & m_p13;
			post_img_Bit2 <= m_p21 & m_p22 & m_p23;
			post_img_Bit3 <= m_p31 & m_p32 & m_p33;
		end
end

//Step 2
wire post_img_Bit4;
assign post_img_Bit4 = post_img_Bit1 & post_img_Bit2 & post_img_Bit3;
assign dout = post_img_Bit4;


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		valid_o <= 0;
	else 
		valid_o <= matrix_gen_valid_o;
	
end















endmodule