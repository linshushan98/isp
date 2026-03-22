module RAM_shift
#(
	parameter DW = 8,
	parameter DATA_DEPTH = 512
)
(
	input wire			clk,
	input wire			rst_n,
	input wire[DW-1:0]	din,
	input wire			en,
	
	output wire [DW-1:0] Q		
	// output reg [DW-1:0]	taps0x,	//Last row data
	// output reg [DW-1:0]	taps1x,	//Up a row data
);

	reg [DW-1:0] memory [DATA_DEPTH-1:0];
	
	
	
//==================   ÒÆÎ»ram   ====================//		
	integer i;
	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)
			for(i=0;i<DATA_DEPTH;i=i+1)
				memory[i] <= 'b0;
		else begin
			if(en)begin
				memory[0] <= din;
				for(i=1;i<DATA_DEPTH;i=i+1)
					memory[DATA_DEPTH - i] <= memory[DATA_DEPTH - i - 1];
			end
		end
	end


//==================   output Q   ====================//	
// assign Q = memory[DATA_DEPTH - 1];
assign Q = memory[DATA_DEPTH - 1 ];//20260112 onenote±Ê¼Ç

endmodule