//20260110	模拟每个cycle 输出一个pixel(24bit)
`timescale 1ns/1ns
module tb_bmp_reader
#(
	parameter FILENAME = "../temp/demo.bmp"
)
(
	input clk,
	input rst_n,
	output reg [23:0]pixel_out,
	output reg valid

);

//相关变量声明
reg [31:0]pic_width;
reg [31:0]pic_height;
reg [15:0]bit_depth; 
reg[7:0] bmp_head [0:255];	//保存bmp文件的前256个字节
//pixel_data[row][col]
reg[23:0] pixel_data[0:511][0:511]; //pixel_data 的高到低位分别是8bit 的R G B
reg [23:0] temp_data;
 

initial begin	//读取demo.bmp 至buffer
	$display("read_bmp_file  start");
    read_bmp_file();
	
	$display("read_bmp_file  end");
    //$finish;
end

integer i, j;
initial begin	//将buffer 中数据以逐cycle 输出	
	valid = 0;
    wait (rst_n == 1'b1);// 等待复位释放 
    for (i = 0; i < pic_height; i = i + 1) begin
        for (j = 0; j < pic_width; j = j + 1) begin
            @(negedge clk);           			
			//while (!rst_n) @(posedge clk);// 如果中途被 reset，暂停，等再次释放			
			pixel_out = pixel_data[i][j];
			valid = 1;	//这个地方卡了一会，根据仿真波形debug 完成
        end
    end
end

task read_bmp_file;
	integer fd;
	integer addr_rawdata;			//像素数据起始位置
	integer i,j,c;
	integer byte_num;
	
	begin
		//打开文件
		fd = $fopen(FILENAME,"rb"); //"rb",只读二进制
		if(!fd)begin
			$display("ERROR! 无法打开文件");
			$finish;
		end 
		 
		//读取bmp文件的前256个字节
		for (i = 0; i < 256; i = i + 1) begin
			c = $fgetc(fd);
			if (c == -1) begin
				$display("EOF at bmp_head[%0d]", i);
				bmp_head[i] = 8'h00;
			end else begin
				bmp_head[i] = c[7:0];
			end
		end
		
		//小端模式 拼接
		pic_width = {bmp_head[21],bmp_head[20],bmp_head[19],bmp_head[18]};//宽度（列数）
		pic_height = {bmp_head[25],bmp_head[24],bmp_head[23],bmp_head[22]};//高度（行数）
		bit_depth = {bmp_head[29], bmp_head[28]};
		addr_rawdata = {bmp_head[13],bmp_head[12],bmp_head[11],bmp_head[10]};
		
		//将文件指针移到实际像素数据处
		$display("file pos before seek = %0d", $ftell(fd));
		byte_num = $fseek(fd,addr_rawdata,0);
		$display("file pos after  seek = %0d", $ftell(fd));
		
		//开始逐字节搬运RGB数据到pixel_data 大缓存中，pixel_data 中的数据存储顺序是正常的。
		//BMP的数据，最先读出的是最后一行的第一个数据
		for(i=0;i<512;i=i+1)begin//从第一行开始
			for(j=0;j<512;j=j+1)begin//从第一列开始
				temp_data[7:0] = $fgetc(fd);
				temp_data[15:8] = $fgetc(fd);
				temp_data[23:16] = $fgetc(fd);
				pixel_data[512-1-i][j] = temp_data;//BMP的数据从最后一行的第一个像素开始
			end
		end
		
		// 关闭文件
        $fclose(fd);
	end
endtask


endmodule
