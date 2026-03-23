module matrix_gen
#(
	parameter DW = 8,
	parameter COL_NUM = 512,
	parameter ROW_NUM = 512,
	localparam N_COL = $clog2(COL_NUM),
	localparam N_ROW = $clog2(ROW_NUM)	
)
(
	input 	wire			clk,
	input 	wire			rst_n,
	
	input 	wire[DW-1:0]	pixel_data_i,
	input	wire			valid_i,

	output	reg	[DW-1:0]	m_p11, m_p12, m_p13,	//3X3 Matrix output
	output	reg	[DW-1:0]	m_p21, m_p22, m_p23,
	output	reg	[DW-1:0]	m_p31, m_p32, m_p33,
	output 	wire [N_COL+N_ROW-1:0]pos_px_o,			//{pos_x_o,pos_y_o};以当前3*3算子的中点作为像素坐标；坐标计数从0开始;
	output  reg 			valid_o
);


//Generate 3*3 matrix 
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
reg		[DW-1:0]	p11, p12, p13;
reg		[DW-1:0]	p21, p22, p23;
reg		[DW-1:0]	p31, p32, p33;

wire	[DW-1:0]row1_data;	//frame data of the 1th row
wire	[DW-1:0]row2_data;	//frame data of the 2th row
wire 	[DW-1:0]row3_data;	//frame data of the 3th row
reg		[N_COL-1:0]pos_x_o;
reg		[N_ROW-1:0]pos_y_o;

assign pos_px_o = {pos_x_o,pos_y_o};
assign row3_data = pixel_data_i;


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
			{p11, p12, p13} <= 'b0;
			{p21, p22, p23} <= 'b0;
			{p31, p32, p33} <= 'b0;
	end
	else 
		if(valid_i)begin
			{p11, p12, p13} <= {p12, p13, row1_data};	//1th shift input
			{p21, p22, p23} <= {p22, p23, row2_data};	//2th shift input
			{p31, p32, p33} <= {p32, p33, row3_data};	//3th shift input
		end
end


//-------------边缘像素padding---构造padding矩阵---------//
always@(*)begin
	//默认赋值，不会综合出latch
	{m_p11, m_p12, m_p13} = {p11, p12, p13};
	{m_p21, m_p22, m_p23} = {p21, p22, p23};
	{m_p31, m_p32, m_p33} = {p31, p32, p33};
	
	//左边界
	if(pos_x_o==0)begin
		m_p11 = p12;
		m_p21 = p22;
		m_p31 = p32;
	end
	//右边界
	else if(pos_x_o==COL_NUM-1)begin
		m_p13 = p12;
		m_p23 = p22;
		m_p33 = p32;
	end


	//上边界
	if(pos_y_o==0)begin
		{m_p11, m_p12, m_p13} = {p21, p22, p23};	
	end
	//下边界
	else if(pos_y_o==ROW_NUM-1)begin
		{m_p31, m_p32, m_p33} = {p21, p22, p23};	
	end


	//四个角的特殊情况
	if(pos_x_o==0 && pos_y_o==0)
		m_p11 = p22;
	else if(pos_x_o==COL_NUM-1 && pos_y_o==0)
		m_p13 = p22;
	else if(pos_x_o==0 && pos_y_o==ROW_NUM-1)
		m_p31 = p22;
	else if(pos_x_o==COL_NUM-1 && pos_y_o==ROW_NUM-1)
		m_p33 = p22;
		
end



//构造输出有效信号valid_o ,对valid_i 延迟 1行 + 2个像素
reg [N_COL:0]cnt_valid_i;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_valid_i <= 0;
	else
		if(valid_i)
			cnt_valid_i <= cnt_valid_i + 1;
end

reg ready;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		ready <= 0;
	else
		if(valid_i)
			if(cnt_valid_i == COL_NUM+2 - 1)
				ready <= 1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		valid_o <= 0;
	else
		if(ready)
			valid_o <= valid_i;
		else	
			if(valid_i && cnt_valid_i == COL_NUM+2 - 1)
				valid_o <= valid_i;
end


//构造输出坐标 pos_px_o
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pos_x_o <= 0;
	else
		if(valid_o)
			if(pos_x_o == COL_NUM-1)
				pos_x_o <= 0;
			else
				pos_x_o <= pos_x_o + 1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pos_y_o <= 0;
	else
		if(valid_o)
			if(pos_y_o == ROW_NUM-1 && pos_x_o == COL_NUM-1)
				pos_y_o <= 0;
			else if(pos_x_o == COL_NUM-1)
				pos_y_o <= pos_y_o + 1;
end



//20260112:第二行已经比第三行晚一拍放入了
//==================   缓存两行   ====================//	
	RAM_shift 
	#(
		.DW(DW),
		.DATA_DEPTH(COL_NUM)
	)
	RAM_shift1
	(
		.clk(clk),
		.rst_n(rst_n),
		.din(row3_data),
		.en(valid_i),
		.Q(row2_data)			//较新的数据
	);

	RAM_shift 
	#(
		.DW(DW),
		.DATA_DEPTH(COL_NUM)
	)
	RAM_shift2
	(
		.clk(clk),
		.rst_n(rst_n),
		.din(row2_data),
		.en(valid_i),
		.Q(row1_data)			//较早期的数据
	);


endmodule
