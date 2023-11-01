import math

def calculate_direction(U, V):
    # 计算方向角度
    theta = math.atan2(V, U)
    
    # 将弧度转换为度
    theta_degrees = math.degrees(theta)
    
    # 确保角度在0到360度之间
    theta_degrees = (theta_degrees + 360) % 360
    
    return theta_degrees

# 第一组数据
U1, V1 = 60, -4
theta1 = calculate_direction(U1, V1)

# 第二组数据
U2, V2 = -50, 0
theta2 = calculate_direction(U2, V2)

# 第三组数据
U3, V3 = 0, -15
theta3 = calculate_direction(U3, V3)

# 第四组数据
U4, V4 = -16, 4
theta4 = calculate_direction(U4, V4)

print(f"第一组数据的方向角度: {theta1} 度")
print(f"第二组数据的方向角度: {theta2} 度")
print(f"第三组数据的方向角度: {theta3} 度")
print(f"第四组数据的方向角度: {theta4} 度")
