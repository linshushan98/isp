`timescale 1ns/1ps
module tb_rgb2hsv();

reg clk;
reg rst_n;
reg [23:0]	RGB_888;
reg valid_i;
	
wire [23:0]	HSV_888;
wire valid_o;

initial begin
	clk=0;
	rst_n=0;
	RGB_888=0;
	valid_i=0;
	#3;rst_n=1;
end

always begin
	#1;clk=!clk;
end

initial begin
// 黑色
send_pixel(8'd0  ,8'd0  ,8'd0  ); // HSV ≈ (0  , 0  , 0  )
send_pixel(8'd255,8'd255,8'd255); // HSV ≈ (0  , 0  , 255)
send_pixel(8'd255,8'd0  ,8'd0  ); // HSV ≈ (0  , 255, 255)
send_pixel(8'd0  ,8'd255,8'd0  ); // HSV ≈ (85 , 255, 255)
send_pixel(8'd0  ,8'd0  ,8'd255); // HSV ≈ (170, 255, 255)
send_pixel(8'd255,8'd255,8'd0  ); // HSV ≈ (42 , 255, 255)
send_pixel(8'd0  ,8'd255,8'd255); // HSV ≈ (128, 255, 255)
send_pixel(8'd255,8'd0  ,8'd255); // HSV ≈ (212, 255, 255)
send_pixel(8'd128,8'd128,8'd128); // HSV ≈ (0  , 0  , 128)
send_pixel(8'd100,8'd150,8'd200); // HSV ≈ (149, 127, 200)
send_pixel(8'd50 ,8'd200,8'd100); // HSV ≈ (102, 191, 200)
send_pixel(8'd200,8'd80 ,8'd60 ); // HSV ≈ (6  , 178, 200)
send_pixel(8'd34 ,8'd87 ,8'd123); // HSV ≈ (147, 185, 123)
send_pixel(8'd210,8'd45 ,8'd90 ); // HSV ≈ (244, 200, 210)
send_pixel(8'd12 ,8'd200,8'd180); // HSV ≈ (123, 240, 200)
send_pixel(8'd180,8'd160,8'd20 ); // HSV ≈ (38 , 227, 180)
send_pixel(8'd90 ,8'd30 ,8'd220); // HSV ≈ (183, 220, 220)
send_pixel(8'd255,8'd120,8'd10 ); // HSV ≈ (18 , 245, 255)
send_pixel(8'd15 ,8'd60 ,8'd45 ); // HSV ≈ (113, 191, 60)
send_pixel(8'd75 ,8'd180,8'd255); // HSV ≈ (146, 180, 255)
send_pixel(8'd140,8'd10 ,8'd200); // HSV ≈ (199, 242, 200)
send_pixel(8'd220,8'd220,8'd50 ); // HSV ≈ (42 , 197, 220)


send_pixel(8'd9 ,8'd197 ,8'd77 ); // HSV ≈ (100, 243, 197)
send_pixel(8'd7 ,8'd196,8'd73); // HSV ≈ (100, 246, 196)
send_pixel(8'd6,8'd195 ,8'd63); // HSV ≈ (98, 247, 195)
send_pixel(8'd5,8'd195,8'd53 ); // HSV ≈ (96, 248, 195)

end


rgb2hsv rgb2hsv_DUT
(
	.pclk      (clk      ),
	.rst_n     (rst_n     ),
                
	.RGB_888   (RGB_888   ),
	.valid_i   (valid_i   ),
                
	.HSV_888   (HSV_888   ),
	.valid_o   (valid_o   )
);

task send_pixel;
	input [7:0]r;
	input [7:0]g;
	input [7:0]b;
	
	begin
		@(negedge clk);
		@(negedge clk);
		RGB_888 = {r,g,b};
		valid_i = 1;
		@(negedge clk);
		valid_i = 0;
	end

endtask

endmodule