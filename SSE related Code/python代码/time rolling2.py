#首先时间必须是年月日时分秒
#时间平滑数据处理第一步
#2023.4.2切割文件以9999为界限
#取只修改时间的原始文件
import csv

# 读取原始CSV文件
with open('E:/研究生阶段文件/新建文件夹/210/数据.csv') as f:
    reader = csv.reader(f)
    rows = [row for row in reader]

# 找到所有9999，处理前去除所有空白
split_row = 9999
split_row_indices = [i for i, row in enumerate(rows) if row[0] == '9999']

# 循环切割数据并保存到不同的CSV文件中
for i, index in enumerate(split_row_indices):
    # 获取当前切割的行数范围
    if i == 0:
        start = 0 if index == split_row else 1
    else:
        start = split_row_indices[i-1] + 1
    end = index

    # 生成新的文件名
    filename = f'E:/研究生阶段文件/新建文件夹/210/{i+1}.csv'

    # 将当前行数范围内的数据写入到新的CSV文件中
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        if start != 0:
            writer.writerow(rows[0])  # 写入列名
        for row in rows[start:end]:
            writer.writerow(row)

