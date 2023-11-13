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