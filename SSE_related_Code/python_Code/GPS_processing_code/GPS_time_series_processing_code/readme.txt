""
Python code related to time series, modified from Li's MATLAB code.
2023.10.22-2023.10.31 Completed
(1) Main function Get_TimeseriesData, sub-functions postseis, xyz2enu, read_timeseries, llh2xyz
(2) Verified with Matlab, parameter values are all equal. The code section that removes the effects of the 1964 earthquake is correct.

Completed from October 31, 2023, to November 6, 2023:
(1) Framework transformation from ITRF to NOAM: modifications to the geodvel function and xyzllh.
(2) Modified some content in the xyz2enu function. Details can be found in this function.

Completed from November 6, 2023, to November 13, 2023:
(1) Removed seasonal effects.
(2) Integrated all data.
All processing steps have been completed as of now.

Introduction to the Code Usage Operation

Data Preparation:
(1) campaign and continuous stations are placed separately in the paper.txt file.
(2) Data affected by the 1964 earthquake (sites_all_name_lat_lon_Up.vec).
(3) Seasonal files and original time series files.
(4) Velocity of all sites in Alaska (allsites_alaska_ssl_v1.0.vec).

Notes:
(1) Before the experiment, it is necessary to modify the locations of corresponding files, such as the original time series, seasonal files, and the location for the final results (Get_TimeseriesData.py).

Operation Steps:
(1) Prepare the data.
(2) Modify the data locations in the code.
(3) Run Get_TimeseriesData.py.
""
关于时间序列的python代码，修改于Li matlab代码
2023.10.22-2023.10.31 完成
（1）主函数Get_TimeseriesData，子函数postseis，xyz2enu，read_timeseries，llh2xyz
（2）与matlab进行验证，参数值都相等，在去除1964年大地震震后影响这一部分的代码是对的

2023.10.31-2023.11.6完成
（1）框架转为ITRF to NOAM：geodvel函数以及xyzllh
（2）修改了xyz2enu函数中的部分内容，具体见此函数

2023.11.6-2023.11.13完成
（1）去除季节性影响
（2）整合所有数据

目前所有处理步骤已经全部完成

下面具体介绍代码使用操作
需要准备的数据
（1）流动站点以及持续站点，我们把它们分别放在paper.txt文件中
（2）1964年大地震影响的数据（sites_all_name_lat_lon_Up.vec）
（3）季节性文件以及原始时间序列文件
（4）阿拉斯加所有站点的速度（allsites_alaska_ssl_v1.0.vec）
注意点
（1）在实验前时我们必须修改对应文件的位置比如原始时间序列，季节性文件，最后结果的位置（Get_TimeseriesData.py）
（2）我们把geodvel.py中的omegacov的数据放在了本地，我们以名为omegacov.xls存放它所以你需要下载他，然后在geodvel.py中对应位置要修改他的路径
操作过程
（1）准备数据
（2）在代码中修改数据位置
（3）运行Get_TimeseriesData.py
