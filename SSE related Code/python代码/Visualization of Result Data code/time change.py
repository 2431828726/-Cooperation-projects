#提取ts数据

import csv
from datetime import datetime, timedelta

def decimal_time_to_date(decimal_time):
    # 判断是否为空或9999
    if not decimal_time or decimal_time == '9999':
        return decimal_time
    
    # 计算年份和一年中的天数
    year = int(decimal_time)
    days = int((decimal_time - year) * 365.25)

    # 转换为日期格式
    date = datetime(year, 1, 1) + timedelta(days=days - 1)
    return date.strftime('%Y-%m-%d')

# 指定输入和输出文件名
input_file = 'E:/研究生阶段文件/新建文件夹/time.csv'
output_file = 'E:/研究生阶段文件/新建文件夹/output.csv'
time_column = 0

# 读取CSV文件并转换时间数据
with open(input_file, 'r') as f_in, open(output_file, 'w', newline='') as f_out:
    reader = csv.DictReader(f_in)
    fieldnames = reader.fieldnames + ['date']
    writer = csv.DictWriter(f_out, fieldnames=fieldnames)
    writer.writeheader()

    for row in reader:
        row['date'] = decimal_time_to_date(float(row[reader.fieldnames[time_column]]))
        writer.writerow(row)

print('转换完成！')

