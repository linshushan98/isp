//20260111
`timescale 1ns/1ns

module tb_isp();
reg 		clk;
reg 		rst_n;

initial begin
	clk      = 0;
	rst_n    = 0;
	#3;rst_n = 1;
end

always begin
	#1;clk = !clk;
end

//=================		BMP图片路径  	======================//
//输入图片
parameter FILE_BMP_IN = "C:/Users/22144/Desktop/isp/temp/demo2.bmp";
//输出图片
parameter FILE_BMP_OUT = "C:/Users/22144/Desktop/isp/temp/fushi.bmp";

//=================		读取BMP文件  	======================//
wire [23:0]	pix_bmp_o;
wire 		pix_bmp_o_valid;
tb_bmp_reader 
#(
	.FILENAME(FILE_BMP_IN)
)
tb_bmp_reader
(
	.clk			(clk),
	.rst_n			(rst_n),
	.pixel_out		(pix_bmp_o),
	.valid			(pix_bmp_o_valid)
);

//=================		RGB转HSV  	======================//
//此模块为纯组合逻辑
//写像素时：R = G = B = gray ,出来即为灰度图
wire [23:0]HSV_888;
wire HSV_888_valid;

rgb2hsv rgb2hsv
(
	.pclk    (clk),
	.rst_n   (rst_n),
	
	.RGB_888 (pix_bmp_o),
	.valid_i (pix_bmp_o_valid),
	
	.HSV_888 (HSV_888),
	.valid_o (HSV_888_valid)
);

wire color_sel_dout;
wire color_sel_dout_valid;
color_sel color_sel
(
	.clk    	(clk),
	.rst_n  	(rst_n),
	
	.HSV_888	(HSV_888),
	.valid_i	(HSV_888_valid),
	
	.dout   	(color_sel_dout),	//1bit
	.valid_o	(color_sel_dout_valid)
);


//=================		RGB转灰度  	======================//
//此模块为纯组合逻辑
//写像素时：R = G = B = gray ,出来即为灰度图
// wire [7:0]pixel_gary_o;
// rgb2gray rgb2gray1(
	// .pic_r              (pix_bmp_o[23:16]),
	// .pic_g              (pix_bmp_o[15:8]),
	// .pic_b              (pix_bmp_o[7:0]),
	// .pixel_gary_o       (pixel_gary_o)
// );

//=================		灰度 二值化  	==================//
//此模块为纯组合逻辑
// wire [7:0]two_value_o;
// two_value_gen
// #(
	// .DW_i (8),
	// .DW_o (8)
// )
// two_value_gen
// (
	// .din	(pixel_gary_o),
	// .th     (8'd128),			
	// .dout	(two_value_o)	//8bit
// );




// =================		腐蚀  	==================//
wire Erosion_bin_dout;
wire Erosion_bin_dout_valid;
Erosion_bin
#(
	.ROW_DEPTH	(512)
)
Erosion_bin
(
	.clk       (clk),
	.rst_n     (rst_n),
			  
	.din       (color_sel_dout),		//1bit
	.valid_i   (color_sel_dout_valid),
	.dout      (Erosion_bin_dout),	//1bit
	.valid_o   (Erosion_bin_dout_valid)
);





//=================		输出BMP文件  	======================//
tb_bmp_writer 
#(
	.FILENAME	(FILE_BMP_OUT),
	.FILESIZE 	(512*512*3 + 54 ),
	.WIDTH		(32'd512        ),
	.HEIGHT		(32'd512        )
)
tb_bmp_writer
(
	.clk	(clk  ),
	.rst_n	(rst_n),
	// .pixel	(pix_bmp_o),
	// .valid	(pix_bmp_o_valid)
	 .pixel	({24{Erosion_bin_dout}}),
	 .valid	(Erosion_bin_dout_valid)
);



endmodule