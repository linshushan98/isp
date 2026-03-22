
module reg_delay
#(
	parameter DW = 8,
	parameter DELAY_CYCLE = 3,
	parameter [DW-1:0]RST_VALUE = 0
)
(
	input clk,
	input rst_n,
	input [DW-1:0] din,
	input en,
	output[DW-1:0] dout
);

reg [DW-1:0] r [DELAY_CYCLE-1:0];

integer i;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		for(i=0;i<DELAY_CYCLE;i=i+1)
			r[i] <= RST_VALUE;
	else
		if(en)begin
			r[0] <= din;
			for(i=1;i<DELAY_CYCLE;i=i+1)begin
				r[i] <= r[i-1];
			end
		end
end

assign dout = r[DELAY_CYCLE-1];

endmodule