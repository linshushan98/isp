//20260319  加入xilinx 除法器IP
//Latency23
module rgb2hsv
(
	input pclk,
	input rst_n,
	
	input [23:0]	RGB_888,
	input valid_i,
	
	output [23:0]	HSV_888,
	output valid_o
);

wire [7:0]R,G,B;
wire [7:0]rgb_max,rgb_min;
wire [7:0]delta;
wire [7:0]H,S,V;
wire [7:0]H_sync,S_sync,V_sync;
wire valid_h,valid_s,valid_v;
wire valid_h_sync,valid_s_sync,valid_v_sync;

assign R = RGB_888[23:16];
assign G = RGB_888[15:8];
assign B = RGB_888[7:0];
assign rgb_max = (R>G) ? ((R>B)?R:B) : ((G>B)?G:B);
assign rgb_min = (R<G) ? ((R<B)?R:B) : ((G<B)?G:B);
assign delta= rgb_max - rgb_min;

//====================== V 计算 =======================//
assign V = rgb_max;
assign valid_v = valid_i;
//---------------------sync V-------------------------//
reg_delay #(8,22,0) reg_delay_v (.clk(pclk), .rst_n(rst_n), .din(V), .en(1'b1), .dout(V_sync));
reg_delay #(1,22,0) reg_delay_v_valid (.clk(pclk), .rst_n(rst_n), .din(valid_v), .en(1'b1), .dout(valid_v_sync));



//====================== S 计算 =======================//
wire [15:0]S_Q8_8;//Q8.8 范围为0~1
wire [23:0]S_scale;//Q16.8

//无符号除法器, 除0得0
//latency 18
div_ip_s_wrapper div_ip_s_wrapper
(
	.clk            (pclk			),
	.dividend_i		(delta			),		//8bit
	.divisor_i		(rgb_max		),		//8bit
	.valid_i        (valid_i		),

	.quotient_Q8_8	(S_Q8_8			),		//无符号定点数输出 unsigned Q8.8
	.valid_o        (valid_s		)
);

assign S_scale = S_Q8_8 * 255;//缩放S范围到0~255
assign S = S_scale[15:8];//这是Q16.8 → 8bit整数
//---------------------sync S-------------------------//
reg_delay #(8,4,0) reg_delay_s (.clk(pclk), .rst_n(rst_n), .din(S), .en(1'b1), .dout(S_sync));
reg_delay #(1,4,0) reg_delay_s_valid (.clk(pclk), .rst_n(rst_n), .din(valid_s), .en(1'b1), .dout(valid_s_sync));




//====================== H 计算 =======================//
wire signed[16:0]ratio;	//ratio Q9.8 有符号
reg signed [8:0]sub_temp;
always@(*)begin
	if(rgb_max == R)
		sub_temp = $signed({1'b0,G}) - $signed({1'b0,B});
	else if(rgb_max == G)
		sub_temp = $signed({1'b0,B}) - $signed({1'b0,R});
	else //rgb_max == B
		sub_temp = $signed({1'b0,R}) - $signed({1'b0,G});
end

//有符号除法器, 除0得0
//latency 22
div_ip_h_wrapper div_ip_h_wrapper
(
	.clk            (pclk			),
	.dividend_i		(sub_temp		),		//9bit
	.divisor_i		({1'b0,delta}	),		//9bit
	.valid_i        (valid_i		),

	.quotient_Q9_8	(ratio			),		//有符号定点数输出 signed Q9.8
	.valid_o        (valid_h		)
);

reg signed[24:0]H_temp;	//经过下列右移运算已经是整数域
// always@(*)begin
	// if(delta == 0)
		// H_temp = 0;
	// else if(rgb_max == R)
		// H_temp = ((ratio * 60)>>>8		) * 255/360;
	// else if(rgb_max == G)   
		// H_temp = ((ratio * 60)>>>8 + 120	) * 255/360;
	// else if(rgb_max == R)   
		// H_temp = ((ratio * 60)>>>8 + 240	) * 255/360;
	// else
		// H_temp = 0;
// end	
//这段注释是为了解释下面的那些数是怎么来的
//（为了把H的范围从0~360缩放到0~255）


wire [7:0] R_sync, G_sync,B_sync,delta_sync;

reg_delay #(8,22) delay_r (.clk(pclk), .rst_n(rst_n), .din(R), .en(1'b1), .dout(R_sync));
reg_delay #(8,22) delay_g (.clk(pclk), .rst_n(rst_n), .din(G), .en(1'b1), .dout(G_sync));
reg_delay #(8,22) delay_b (.clk(pclk), .rst_n(rst_n), .din(B), .en(1'b1), .dout(B_sync));
reg_delay #(8,22) delay_delta (.clk(pclk), .rst_n(rst_n), .din(delta), .en(1'b1), .dout(delta_sync));

//V_sync = Latency22 (rgb_max_sync)
always@(*)begin
	if(delta_sync==0)
		H_temp = 0;
	else if(V_sync == R_sync)
		H_temp = (ratio * 25'sd43)>>>8				;
	else if(V_sync == G_sync)
		H_temp = ((ratio * 25'sd43)>>>8) + 25'sd85	;
	else if(V_sync == B_sync)
		H_temp = ((ratio * 25'sd43)>>>8) + 25'sd170	;
	else
		H_temp = 0;
end



wire signed[24:0]H_temp_pos;
assign H_temp_pos = (H_temp<0) ? (H_temp + 25'sd256) : 
					((H_temp>= 25'sd256) ? (H_temp - 25'sd256) : H_temp);


//统一截断
assign H = 	H_temp_pos[7:0];				
assign H_sync = H;
//-------------------------------------------------------------//


//----最后给输出再统一打一拍，主要是为了给H通道加一级reg输出----//
wire [23:0]HSV_888_noreg;
wire valid_o_noreg;

assign HSV_888_noreg = {H_sync, S_sync, V_sync};
assign valid_o_noreg = valid_h;

reg_delay #(24,1,0) output_HSV_888 (.clk(pclk), .rst_n(rst_n), .din(HSV_888_noreg), .en(1'b1), .dout(HSV_888));
reg_delay #(1,1,0) output_valid_o (.clk(pclk), .rst_n(rst_n), .din(valid_o_noreg), .en(1'b1), .dout(valid_o));


endmodule
