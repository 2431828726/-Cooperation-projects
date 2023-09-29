# 填充ts数据
"""
Created on Sun Apr  2 18:05:50 2023

@author: 徐兵
"""
import pandas as pd

# 读取第一个CSV文件
df1 = pd.read_csv('E:/研究生阶段文件/新建文件夹/270/270.csv', header=None)

# 读取第二个CSV文件
df2 = pd.read_csv('E:/研究生阶段文件/新建文件夹/210/站点所以.csv', header=None)

# 逐行检查第一列是否为空白
for i, row in df1.iterrows():
    if pd.isnull(row[0]):
        # 如果第二个CSV文件中还有数据，则用它填充第一个文件中的空白行
        if not df2.empty:
            # 将第二个CSV文件的数据按顺序插入到第一个CSV文件中的空白行中
            df1.iloc[i, 0] = df2.iloc[0, 0]
            # 将已经使用的第二个CSV文件中的数据删除
            df2 = df2.iloc[1:]
        else:
            break

# 将填充好的第一个CSV文件保存到一个新的文件中
df1.to_csv('E:/研究生阶段文件/新建文件夹/210/270file1_filled.csv', index=False, header=False)



