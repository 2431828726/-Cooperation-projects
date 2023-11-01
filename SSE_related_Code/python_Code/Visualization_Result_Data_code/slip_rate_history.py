import os
import matplotlib.pyplot as plt

folder_path = r'E:\研究生阶段文件\test'
files = ["80.txt", "100.txt", "120.txt", "140.txt",  "180.txt"]
colors = ['b', 'g', 'r', 'c', 'y']  # Different colors for different files

for i, file in enumerate(files):
    file_path = os.path.join(folder_path, file)
    
    x = []  # Years (x-axis)
    y = []  # Values (y-axis)
    
    with open(file_path, 'r') as f:
        for line in f:
            data = line.split()
            if len(data) >= 4:
                x.append(float(data[2]))  # Assuming the year is in the third column
                y.append(float(data[3]))  # Assuming the value is in the fourth column
    
    plt.plot(x, y, color=colors[i], label=file)

plt.xlabel("Year")
plt.ylabel("slip rate history")
plt.title("Data from Different Files")
plt.legend()
plt.grid(True)
plt.show()


