from PIL import Image
import struct

def jpg_to_bmp_v3(input_path, output_path):
    # 读取图像
    img = Image.open(input_path).convert("RGB")

    # 强制尺寸
    if img.size != (512, 512):
        raise ValueError("Image must be 512x512")

    width, height = img.size

    # BMP是BGR + bottom-up
    pixels = img.load()

    # 每行字节数（无padding）
    row_bytes = width * 3

    # 数据大小
    pixel_data_size = row_bytes * height

    # 文件大小
    file_size = 14 + 40 + pixel_data_size

    with open(output_path, "wb") as f:
        # ===== FILE HEADER (14 bytes) =====
        f.write(b'BM')                          # bfType
        f.write(struct.pack('<I', file_size))   # bfSize
        f.write(struct.pack('<H', 0))           # bfReserved1
        f.write(struct.pack('<H', 0))           # bfReserved2
        f.write(struct.pack('<I', 54))          # bfOffBits

        # ===== INFO HEADER (40 bytes) =====
        f.write(struct.pack('<I', 40))          # biSize
        f.write(struct.pack('<i', width))       # biWidth
        f.write(struct.pack('<i', height))      # biHeight
        f.write(struct.pack('<H', 1))           # biPlanes
        f.write(struct.pack('<H', 24))          # biBitCount
        f.write(struct.pack('<I', 0))           # biCompression
        f.write(struct.pack('<I', pixel_data_size))  # biSizeImage
        f.write(struct.pack('<i', 0))           # biXPelsPerMeter
        f.write(struct.pack('<i', 0))           # biYPelsPerMeter
        f.write(struct.pack('<I', 0))           # biClrUsed
        f.write(struct.pack('<I', 0))           # biClrImportant

        # ===== PIXEL DATA =====
        # BMP是从底往上存
        for y in range(height - 1, -1, -1):
            for x in range(width):
                r, g, b = pixels[x, y]
                f.write(struct.pack('BBB', b, g, r))  # BGR

    print("转换完成:", output_path)


# 示例
jpg_to_bmp_v3(r"../temp/demo2.jpg", r"../temp/demo2.bmp")