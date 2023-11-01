#由TDEFNODE，source输出文件提供的平均slip是mm我们下面化成了m，面积单位是km2我们下面化成了mm2，剪切模量为50Gpa
#，Mo到MW的计算我们遵循1979，Hanks，Mw=2/3log10（Mo）-6
import math

def calculate_result(slip, area):
    Mo = slip * 0.001 * (area * 1e6) * 50e9
    result = (2/3) * math.log10(Mo) - 6
    return Mo, result

slip_values = [75.3, 103, 91.5]#平均滑移
area_values = [31100, 24400, 20000]#面积

results = []

for slip, area in zip(slip_values, area_values):
    Mo, result = calculate_result(slip, area)
    results.append((Mo, result))

for i, (slip, area) in enumerate(zip(slip_values, area_values)):
    Mo, result = results[i]
    print(f"当 slip = {slip} 且 area = {area} 时，Mo = {Mo}，结果为: {result}")
