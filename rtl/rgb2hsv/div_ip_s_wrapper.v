//用于S分量计算的除法器IP wrapper包装
//重包这一层，用于定点结果数据拼凑。主要是而为了rgb2hsv.v的代码整洁。

module div_ip_s_wrapper
(
	input clk,
	input [7:0]dividend_i,	//8bit
	input [7:0]divisor_i,	//8bit
	input valid_i,

	output [15:0]quotient_Q8_8,	//无符号定点数输出 unsigned Q8.8
	//output flag_div0,				//除0标志位
	output valid_o
);

wire [15:0]m_axis_dout_tdata;
wire [7:0]quotient_ip;
wire [7:0]fractional_ip;
wire flag_div0;

//latency 18
div_ip_s div_ip_s (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid	(valid_i),    			// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(divisor_i),      		// input wire [7 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(valid_i),  			// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(dividend_i),    		// input wire [7 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(valid_o), 				// output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(flag_div0),			// output wire [0 : 0] m_axis_dout_tuser
  .m_axis_dout_tdata		(m_axis_dout_tdata)		// output wire [15 : 0] m_axis_dout_tdata	//quotient[15:8] (uint8) , //fractional[7:0] (Q0.8)
);                                                                                              	

assign quotient_ip = m_axis_dout_tdata[15:8];
assign fractional_ip = m_axis_dout_tdata[7:0];

assign quotient_Q8_8 = !flag_div0 ? {quotient_ip,8'b0} + {8'b0,fractional_ip} : 0;
//注意根据IP doc，理解数据格式并正确拼凑最终定点数结果。


endmodule