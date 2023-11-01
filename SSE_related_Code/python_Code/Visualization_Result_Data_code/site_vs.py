# -*- coding: utf-8 -*-
"""
Created on Tue Oct 10 09:50:35 2023

@author: 徐兵
"""

with open('E:\\研究生阶段文件\\vs\\old-Alaska_alltime_sites_continuous.txt', 'r') as file_in, open('E:\\研究生阶段文件\\vs\\new_old-Alaska_alltime_sites_continuous.txt', 'w') as file_out:
    for line in file_in:
        if '#' not in line and '%' not in line:
            file_out.write(line)
