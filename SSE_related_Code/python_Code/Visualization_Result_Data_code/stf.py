# -*- coding: utf-8 -*-
"""
2023.10.30
vs tdefnode ".stf" slip history
@author: xubing
"""
#X-time，y-slip history
import os
import matplotlib.pyplot as plt

# Define a function to read stf files
def read_stf(file_path):
    x = []
    y = []
    with open(file_path, 'r') as file:
        for line in file:
            columns = line.strip().split()
            x.append(float(columns[2]))  # Use the third column as x-axis
            y.append(float(columns[4]))  # Use the fifth column as y-axis
    return x, y

# Get all stf files in the specified directory
directory = r'E:\研究生阶段文件\test\2022.9.29\52'
stf_files = [f for f in os.listdir(directory) if f.endswith('.stf')]

# Iterate through each stf file and plot the data
for stf_file in stf_files:
    file_path = os.path.join(directory, stf_file)
    x, y = read_stf(file_path)
    plt.plot(x, y, label=f'{os.path.splitext(stf_file)[0]}')

# Add labels and title
plt.xlabel('time')
plt.ylabel('slip/mm')
plt.title('52SSE time/slip')
plt.legend()
plt.show()


