#trade off curve
import numpy as np
import matplotlib.pyplot as plt

smooth = np.array([80, 100,120, 140,160, 180, 200,220])
DOF1 = np.ones(8) * 74121
Data_Chi21 = np.array([3.8853, 3.8853, 3.8853, 3.8852, 3.8885, 3.8918, 3.8981, 3.9041])
data_chi21 = DOF1 * Data_Chi21
penalty1 = np.array([1.3840e-04, 1.4698e-04, 1.9427e-04, 6.3093e-04, 1.0886e-02, 3.2373e-02, 6.3861e-02, 1.5045e-01])

smoothvalue1 = (penalty1 ) / smooth

plt.figure(1)
plt.scatter(smoothvalue1, data_chi21, 50, color='b', label='Data Point')
for i in range(len(smooth)):
    x_pos = smoothvalue1[i]
    y_pos = data_chi21[i]
    label = f"{smooth[i]:.1e}\n"
    plt.text(x_pos, y_pos, label, color='b', fontsize=9, ha='left', va='center')

plt.legend(fontsize=9, loc='upper left')
plt.ylabel('Chi-square', fontsize=9)
plt.xlabel('Roughness', fontsize=9)
plt.title('Roughness vs Chi-square', fontsize=9, fontweight='bold')

plt.show()
