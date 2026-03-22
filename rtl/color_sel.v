module color_sel
(
	input clk,
	input rst_n,
	
	input [23:0]HSV_888,
	input valid_i,
	
	output reg[0:0]dout,
	output reg valid_o
);

wire [7:0]H,S,V;
assign H = HSV_888[23:16];
assign S = HSV_888[15:8];
assign V = HSV_888[7:0];

always@(posedge clk or negedge rst_n)begin         
    if(!rst_n)
         dout <= 0;                                  
    else begin
        if((H>45 && H<101 && S>20 && V>30)) //绿                                             
            dout <= 1;   
        else 
            dout <= 0;  
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
		valid_o <= 0;    
	else
		valid_o <= valid_i;
end


endmodule