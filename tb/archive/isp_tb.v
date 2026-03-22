`timescale 1ns/1ps
module isp_tb
// #(
	// parameter DW = 8,
	// parameter DATA_DEPTH = 512
// )
();
	reg		[7:0]	pic_r;
	reg		[7:0]	pic_g;
	reg		[7:0]	pic_b;
	wire	[7:0]	pixel_gary_tb_o;
	wire			pixel_bin;
	wire			Erosion_bin1_o;
	wire			Dilation_bin1_o;
	wire	[7:0]	sobel_8b_o;
	wire			sobel_1b_o;
	
	reg	[7:0]	pic_memory	[786432-1:0];	//512*512*3 = 786432
	integer 	addr;
	integer 	fid_bin;
	integer 	fid_Erosion_bin1_o;
	integer 	fid_Dilation_bin1_o;
	integer 	fid_sobel_8b_o;
	integer 	fid_sobel_1b_o;

	initial $readmemh("C:/Users/22144/Desktop/pic/matlab/rgb_data.txt",isp_tb.pic_memory);

	initial fid_bin = $fopen("C:/Users/22144/Desktop/pic/matlab/rtl2matlab.txt");
	initial fid_Erosion_bin1_o = $fopen("C:/Users/22144/Desktop/pic/matlab/Erosion_bin1_o.txt");
	initial fid_Dilation_bin1_o = $fopen("C:/Users/22144/Desktop/pic/matlab/Dilation_bin1_o.txt");
	initial fid_sobel_8b_o = $fopen("C:/Users/22144/Desktop/pic/matlab/sobel_8b_o.txt");
	initial fid_sobel_1b_o = $fopen("C:/Users/22144/Desktop/pic/matlab/sobel_1b_o.txt");

	initial
		begin
			addr = 0;
			repeat(512*512)begin
				pic_r = pic_memory[0 + addr];
				pic_g = pic_memory[1 + addr];
				pic_b = pic_memory[2 + addr];
				# 20;
				$fdisplay(fid_bin,"%d",pixel_bin); 		//打印成十进制txt     $fdisplay会自动换行
				$fdisplay(fid_Erosion_bin1_o,"%d",Erosion_bin1_o); 		//打印成十进制txt     $fdisplay会自动换行
				$fdisplay(fid_Dilation_bin1_o,"%d",Dilation_bin1_o); 		//打印成十进制txt     $fdisplay会自动换行
				$fdisplay(fid_sobel_8b_o,"%d",sobel_8b_o); 		//打印成十进制txt     $fdisplay会自动换行
				$fdisplay(fid_sobel_1b_o,"%d",sobel_1b_o); 		//打印成十进制txt     $fdisplay会自动换行
				addr = addr + 3;
			end
			$fclose(fid_bin);
			$fclose(fid_Erosion_bin1_o);
			$fclose(fid_Dilation_bin1_o);
			$fclose(fid_sobel_8b_o);
			$fclose(fid_sobel_1b_o);

			$stop;
		end






	reg clk;
	reg rst_n;
	reg [7:0]DATA_i;
	wire [7:0]DATA_o;

	initial begin
		rst_n = 0;
		# 5;
		rst_n = 1;
	end
	
	initial clk = 0;
		
	always begin
		#10; clk = ~clk;
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)
			DATA_i <= 8'b0;
		else
			DATA_i <= DATA_i + 1'b1;
	end


//=================		RGB转灰度  	======================//
	rgb2gray rgb2gray1(
		.pic_r              (pic_r),
		.pic_g              (pic_g),
		.pic_b              (pic_b),
		.pixel_gary_o       (pixel_gary_tb_o)
	);


//=================		灰度 二值化  	======================//
	two_value_gen
	#(
		.DW_i(8),
		.DW_o(1)
	)
	two_value_gen1
	(
		.din(pixel_gary_tb_o),
		.th(8'd127),
		.dout(pixel_bin)		
	);


	Erosion_bin
	#(
		.ROW_DEPTH(512)
	)
	Erosion_bin1
	(
		.clk(clk),  			
		.rst_n(rst_n),			
		.din(pixel_bin),
		.dout(Erosion_bin1_o)		
	);


	Dilation_bin
	#(
		.ROW_DEPTH(512)
	)
	Dilation_bin1
	(
		.clk(clk),  			
		.rst_n(rst_n),			
		.din(Erosion_bin1_o),
		.dout(Dilation_bin1_o)		
	);


	sobel
	#(
		.ROW_DEPTH(512),
		.th_8b(20)
	)
	sobel1
	(
		.clk(clk),  				//cmos video pixel clock
		.rst_n(rst_n),				//global reset

		.din_8b(pixel_gary_tb_o),
		.dout_8b(sobel_8b_o),
		.dout_bin_1b(sobel_1b_o)
	);

endmodule
