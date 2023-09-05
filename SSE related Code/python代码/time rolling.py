#步骤2，时间平滑自身等于他以及后后天数的均值
import pandas as pd
import os

# 指定文件夹路径
folder_path = "E:/研究生阶段文件/新建文件夹/270"

# 设置rolling的参数值
rolling_window = '270D'

# 循环读取文件夹中的所有csv文件
for filename in os.listdir(folder_path):
    if filename.endswith(".csv"):
        file_path = os.path.join(folder_path, filename)
        # 读取每个csv文件的数据，第一列为时间信息，数据必须是win系统下的utf-8
        df = pd.read_csv(file_path, index_col=0, parse_dates=True)
        # 对经纬度数据实行rolling操作，rolling窗口为90天，保留四位小数
        rolled_df = df[::-1].rolling(rolling_window).mean().round(4)[::-1]
        # 将结果存储到新的csv文件中
        new_file_path = os.path.join(folder_path, f"rolled_{filename}")
        rolled_df.to_csv(new_file_path)
