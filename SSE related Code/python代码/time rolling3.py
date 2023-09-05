import csv
import os

# 指定输入和输出文件名
input_folder = 'E:/研究生阶段文件/新建文件夹/210'
output_file = 'E:/研究生阶段文件/新建文件夹/210/file.csv'

# 获取文件列表并按文件名排序
file_list = os.listdir(input_folder)
file_list = sorted(file_list, key=lambda x: int(x.split('_')[1].split('.')[0]))

# 将第一个文件加入到文件列表中
file_list.insert(0, 'rolled_1.csv')

# 合并数据到输出文件
with open(output_file, 'w', newline='') as f_out:
    writer = csv.writer(f_out)
    header_written = False  # 标记是否已写入列标签
    for filename in file_list:
        # 打开CSV文件并读取数据
        with open(os.path.join(input_folder, filename), 'r') as f_in:
            reader = csv.reader(f_in)
            rows = [row for row in reader]

        # 写入数据到输出文件
        if not header_written:
            # 第一个文件只写入列标签
            writer.writerow(['time'] + rows[0]) # 加上time列标签
            header_written = True
        else:
            # 从第二个文件开始写入数据，空两行
            writer.writerow([])
            writer.writerow([])
            writer.writerows(rows[1:])

print('合并完成！')
