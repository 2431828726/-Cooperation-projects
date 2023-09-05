import matplotlib.pyplot as plt

# 读取sitep.txt文件数据
sitep_data = {}
with open(r'E:\研究生阶段文件\test\out.txt', 'r') as file:
    for line in file:
        parts = line.strip().split()
        sitep_data[parts[0]] = float(parts[2])

# 读取site.txt文件数据并进行匹配
matched_data = {}
with open(r'E:\研究生阶段文件\test\site.txt', 'r') as file:
    for line in file:
        parts = line.strip().split()
        if parts[0] in sitep_data:
            matched_data[parts[0]] = float(parts[2])

# 提取站点名字和对应的y轴数据，仅选择两个文件中都存在的站点
common_names = [name for name in sitep_data if name in matched_data]
sitep_values = [sitep_data[name] for name in common_names]
matched_values = [matched_data[name] for name in common_names]

# 设置中文字体（微软雅黑）作为字体
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# 绘制图表
fig, ax = plt.subplots(figsize=(10, 6))

for i, name in enumerate(common_names):
    sitep_y = sitep_values[i]
    matched_y = matched_values[i]
    ax.scatter([i] * 1, sitep_y, color='blue', label='反演出' if i == 0 else "")
    ax.scatter([i] * 1, matched_y, color='red', label='地震数据' if i == 0 else "")

ax.set_xticks(list(range(len(common_names))))
ax.set_xticklabels(common_names, rotation=45)
ax.set_xlabel('站点名')
ax.set_ylabel('Y轴数据')
ax.set_title('站点数据对比')
ax.legend()

plt.tight_layout()
plt.show()
