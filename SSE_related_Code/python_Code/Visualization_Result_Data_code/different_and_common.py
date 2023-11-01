# -*- coding: utf-8 -*-
"""
Created on Tue Oct 10 14:44:19 2023

@author: 徐兵
"""
import pandas as pd

# 读取第一个文件
file1 = pd.read_excel('E:\\研究生阶段文件\\vs\\Alaska_alltime_sites_campaign-newFromJeff.xls', header=None)

# 读取第二个文件
file2 = pd.read_excel('E:\\研究生阶段文件\\vs\\old-Alaska_alltime_sites_campaign.xls', header=None)

# 找出相同的行
common_rows = file1[file1[0].isin(file2[0])]

# 找出文件1中不同的行
different_rows_file1 = file1[~file1[0].isin(file2[0])]

# 找出文件2中不同的行
different_rows_file2 = file2[~file2[0].isin(file1[0])]

# 保存相同的行到相应的文件
common_rows.to_excel('E:\\研究生阶段文件\\vs\\材料5.xlsx', index=False, header=False, sheet_name='Sheet1')
common_rows.to_excel('E:\\研究生阶段文件\\vs\\材料6.xlsx', index=False, header=False, sheet_name='Sheet1')

# 保存不同的行到相应的文件
#different_rows_file1.to_excel('E:\\研究生阶段文件\\vs\\Alaska_alltime_sites_continuous-newFromJeff_different1.xlsx', index=False, header=False, sheet_name='Sheet1')
#different_rows_file2.to_excel('E:\\研究生阶段文件\\vs\\old-Alaska_alltime_sites_continuous_different2.xlsx', index=False, header=False, sheet_name='Sheet1')


