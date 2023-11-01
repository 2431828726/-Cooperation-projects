import pandas as pd

# 读取第一个文件
file1 = pd.read_excel('E:\\研究生阶段文件\\vs\\jf vs mod\\Alaska_alltime_sites_continuous-modNewPaper_common1.xlsx', header=None)

# 读取第二个文件
file2 = pd.read_excel('E:\\研究生阶段文件\\vs\\jf vs mod\\Alaska_alltime_sites_continuous-newFromJeff_common2.xlsx', header=None)

# 用set来存储不同的行
different_rows_file1 = set()
different_rows_file2 = set()

# 找出第一个文件中不同的行
for index, row1 in file1.iterrows():
    match_row2 = file2[file2[0] == row1[0]]
    
    if not match_row2.empty:
        if not (row1[1:].equals(match_row2.iloc[0, 1:])):
            different_rows_file1.add(tuple(row1))

# 找出第二个文件中不同的行
for index, row2 in file2.iterrows():
    match_row1 = file1[file1[0] == row2[0]]
    
    if not match_row1.empty:
        if not (row2[1:].equals(match_row1.iloc[0, 1:])):
            different_rows_file2.add(tuple(row2))

# 将不同的行转化为DataFrame
df_diff_file1 = pd.DataFrame(list(different_rows_file1))
df_diff_file2 = pd.DataFrame(list(different_rows_file2))

# 保存到新的Excel文件中
df_diff_file1.to_excel('E:\\研究生阶段文件\\vs\\jf vs mod\\different1.xlsx', index=False, header=False)
df_diff_file2.to_excel('E:\\研究生阶段文件\\vs\\jf vs mod\\different2.xlsx', index=False, header=False)
