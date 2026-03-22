//用于H分量计算的除法器IP wrapper包装
//重包这一层，用于定点结果数据拼凑。主要是而为了rgb2hsv.v的代码整洁。

module div_ip_h_wrapper
(
	input clk,
	input [8:0]dividend_i,	//9bit
	input [8:0]divisor_i,	//9bit
	input valid_i,

	output [16:0]quotient_Q9_8,	//有符号定点数输出 signed Q9.8
	output valid_o
);

wire [23:0]m_axis_dout_tdata; //有padding
wire [8:0]quotient_ip;
wire [8:0]fractional_ip;
wire flag_div0;

//latency 22
div_ip_h div_ip_h (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(valid_i),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata({7'b0,divisor_i}),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(valid_i),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata({7'b0,dividend_i}),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(valid_o),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tuser(flag_div0),            // output wire [0 : 0] m_axis_dout_tuser
  .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [23 : 0] m_axis_dout_tdata
);                                                                                              	

assign quotient_ip = m_axis_dout_tdata[17:9];
assign fractional_ip = m_axis_dout_tdata[8:0];

assign quotient_Q9_8 = !flag_div0 ? {quotient_ip,8'b0} + {{8{fractional_ip[8]}},fractional_ip} : 0;
//注意根据IP doc，理解数据格式并正确拼凑最终定点数结果。


endmodule