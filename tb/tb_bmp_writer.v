//20260111 生成BMP文件
`timescale 1ns/1ns
module tb_bmp_writer
#(
	parameter FILENAME = "../temp/out1.bmp",
	parameter [31:0] FILESIZE 	= 512*512*3 + 54,
	parameter [31:0] WIDTH		= 32'd512,
	parameter [31:0] HEIGHT		= 32'd512
)
(
	input clk,
	input rst_n,
	input [23:0]pixel, //{R,G,B}
	input valid
);

parameter [31:0] IMAGE_SIZE = FILESIZE - 54;


reg [23:0] pix_data [0:HEIGHT-1][0:WIDTH-1];//pix_data[row][col]
reg [9:0]cnt_raw,cnt_col;	//0 ~ 1023
reg picture_done;

initial begin
	wait (picture_done);
	$display("write bmp start");
	write_bmp_file();
	$display("write_bmp done!");
	$finish;
end

//生成行列计数信号
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_col <= 0;
	else begin
		if(cnt_col==WIDTH-1 && valid)
			cnt_col <= 0;
		else begin
			if(valid)
				cnt_col <= cnt_col + 1;
			else
				cnt_col <= cnt_col;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_raw <= 0;
	else begin
		if(cnt_raw==HEIGHT-1 && cnt_col==WIDTH-1 && valid)
			cnt_raw <= 0;
		else begin
			if(cnt_col==WIDTH-1 && valid)
				cnt_raw <= cnt_raw + 1;
			else
				cnt_raw <= cnt_raw;
		end
	end
end

//每cycle 将pixel 写入buffer
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		init_pix_buffer();	//初始化二维数组buffer
	else begin
		if(valid)
			pix_data[cnt_raw][cnt_col] <= pixel;
	end
end

//生成picture_done ， 用于触发task：write_bmp_file
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		picture_done <= 0;
	else
		if(cnt_raw==HEIGHT-1 && cnt_col==WIDTH-1 && valid)
			picture_done <= 1;
		else
			picture_done <= 0;
end




task write_bmp_file;
	integer fd_out;
	integer i, j, k;
	reg [23:0] temp_pix;
	
	begin
	//1、打开文件（必须 wb：写二进制，截断。即每次写文件都是全新的文件）
		fd_out = $fopen(FILENAME, "wb");
		if (fd_out == 0) begin
			$display("ERROR: cannot open output bmp");
			$finish;
		end
		
	//2、写 BMP File Header（14 字节）
		// Signature 'BM'
		$fwrite(fd_out, "%c", 8'h42);
		$fwrite(fd_out, "%c", 8'h4D);

		// File size (little-endian)
		$fwrite(fd_out, "%c", FILESIZE[7:0]		);
		$fwrite(fd_out, "%c", FILESIZE[15:8]	);
		$fwrite(fd_out, "%c", FILESIZE[23:16]	);
		$fwrite(fd_out, "%c", FILESIZE[31:24]	);
		// Reserved (4 bytes)
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		// Pixel data offset = 14 + 40 = 54
		$fwrite(fd_out, "%c", 8'd54	);
		$fwrite(fd_out, "%c", 8'd0	);
		$fwrite(fd_out, "%c", 8'd0	);
		$fwrite(fd_out, "%c", 8'd0	);
		
	//3、写 DIB Header（BITMAPINFOHEADER，40 字节）
		// DIB header size = 40
		$fwrite(fd_out, "%c", 8'd40	);
		$fwrite(fd_out, "%c", 8'd0	);
		$fwrite(fd_out, "%c", 8'd0	);
		$fwrite(fd_out, "%c", 8'd0	);
		// Width
		$fwrite(fd_out, "%c", WIDTH[7:0]	);
		$fwrite(fd_out, "%c", WIDTH[15:8]	);
		$fwrite(fd_out, "%c", WIDTH[23:16]	);
		$fwrite(fd_out, "%c", WIDTH[31:24]	);
		// Height
		$fwrite(fd_out, "%c", HEIGHT[7:0]	);
		$fwrite(fd_out, "%c", HEIGHT[15:8]	);
		$fwrite(fd_out, "%c", HEIGHT[23:16]	);
		$fwrite(fd_out, "%c", HEIGHT[31:24]	);
		// Planes = 1
		$fwrite(fd_out, "%c", 8'd1);
		$fwrite(fd_out, "%c", 8'd0);
		// Bit count = 24
		$fwrite(fd_out, "%c", 8'd24);
		$fwrite(fd_out, "%c", 8'd0);
		// Compression = 0 (BI_RGB)
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		// Image size
		$fwrite(fd_out, "%c", IMAGE_SIZE[7:0]	);
		$fwrite(fd_out, "%c", IMAGE_SIZE[15:8]	);
		$fwrite(fd_out, "%c", IMAGE_SIZE[23:16]	);
		$fwrite(fd_out, "%c", IMAGE_SIZE[31:24]	);
		// X ppm (dummy)
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		// Y ppm (dummy)
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		// Colors used
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		// Important colors
		repeat (4) $fwrite(fd_out, "%c", 8'd0);
		
	//4、写像素数据
		for (i = 0; i < HEIGHT; i = i + 1) begin
			for (j = 0; j < WIDTH; j = j + 1) begin
				temp_pix = pix_data[HEIGHT-1-i][j];//pix_data[row][col] = {R,G,B}
				// BMP: B G R
				$fwrite(fd_out, "%c", temp_pix[7:0]);    // B
				$fwrite(fd_out, "%c", temp_pix[15:8]);   // G
				$fwrite(fd_out, "%c", temp_pix[23:16]);  // R			
			end
			// padding
			// for (k = 0; k < padding; k = k + 1)
				// $fputc(8'd0, fd_out);
		end
		
	//5、关闭文件
        $fclose(fd_out);
		
	end
endtask


task init_pix_buffer;
    integer i, j;
    begin
        for (i = 0; i < HEIGHT; i = i + 1)
            for (j = 0; j < WIDTH; j = j + 1)
                pix_data[i][j] = 24'h0;
    end
endtask


endmodule 