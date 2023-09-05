clear all;
clc;
close all;
smooth = [10,50,1e2,1e3,5e4,2e5,5e5,2e6,1e7,1e8,1e13];
smooth_xaxis = log10(smooth);
% period 1
DOF1 = ones(1,11)*74121;
Data_Chi21=[3.8862e+00;3.8862e+00;3.8862e+00;3.8861e+00;3.8922e+00;3.8973e+00;3.9057e+00;3.9156e+00;3.9224e+00;3.9281e+00;3.9666e+00]';
data_chi21 = DOF1.*Data_Chi21;
penalty1=[1.3457e-04;1.6751e-04;2.0609e-04;6.5079e-04;1.7661e-02;5.9158e-02;1.4781e-01;7.6499e-01;3.8130e+00;3.8346e+01;1.9745e+06]';
rn = 41*14;
smoothvalue1 = (penalty1.*rn)./(smooth);
figure (1);
% 绘制散点图，并添加标签
scatter(smoothvalue1, data_chi21, 50, 'filled', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'DisplayName', 'Data Point');
hold on;
% 在每个散点旁边添加文字标签和平滑值
for i = 1:numel(smooth)
    % 计算标签的位置
    x_pos = smoothvalue1(i);
    y_pos = data_chi21(i);
    % 使用 sprintf 函数将平滑值格式化为字符串并添加在标签文本中
    label = sprintf('%.1e\n', smooth(i));
    text(x_pos, y_pos, label, 'Color', 'b', 'FontSize', 9, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end
% 添加图例和轴标签
legend('Location', 'none', 'FontSize',9, 'Position', [0.65, 0.65, 0.1, 0.1]); % 将图例放置在图像右侧 75% 处，高度的 25% 处
ylabel('Chi-square', 'FontSize', 9);
xlabel('Roughness', 'FontSize', 9);
title('Roughness vs Chi-square', 'FontSize', 9, 'FontWeight', 'Bold');
