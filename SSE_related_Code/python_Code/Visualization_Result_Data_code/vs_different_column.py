import pandas as pd
import matplotlib.pyplot as plt

# 读取Excel文件
file_path = r'E:\研究生阶段文件\区域子网地震目录 (1).xls'
df = pd.read_excel(file_path)

# 获取第四列数据并将类型转换为大写
data = df.iloc[:, 4].str.upper()

# 统计每个类型的数量
type_counts = data.value_counts()

# 设置颜色映射
colors = ['red', 'blue']

# 创建饼状图
plt.figure(figsize=(8, 8))
plt.pie(type_counts, labels=type_counts.index, autopct='%1.1f%%', colors=colors, startangle=140)

# 创建自定义图例
legend_labels = [f'{label} ({count})' for label, count in zip(type_counts.index, type_counts)]
plt.legend(legend_labels, loc='center left', bbox_to_anchor=(1, 0.5))

plt.title('标度类型占比')
plt.show()
