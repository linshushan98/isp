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

	wire m_p11, m_p12, m_p13;	//3X3 Matrix output
	wire m_p21, m_p22, m_p23;
	wire m_p31, m_p32, m_p33;



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
		post_img_Bit1 <= m_p11 | m_p12 | m_p13;
		post_img_Bit2 <= m_p21 | m_p22 | m_p23;
		post_img_Bit3 <= m_p31 | m_p32 | m_p33;
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






matrix_gen
#(
	. DW(1),
	. ROW_DEPTH(ROW_DEPTH)
)
matrix_gen
(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_data_i(din),
	.m_p11(m_p11),	.m_p12(m_p12), 	.m_p13(m_p13),	//3X3 Matrix output
	.m_p21(m_p21), 	.m_p22(m_p22), 	.m_p23(m_p23),
	.m_p31(m_p31), 	.m_p32(m_p32), 	.m_p33(m_p33)
);









endmodule