% 这个是针对两个原始数据，如果两个数据的部分都是以蓝色表示，不相同部分一个是绿色一个是红色（前排的是绿色）
clear all;
clc;
close all;

% 1. 读取 Excel 文件中的数据
[num_data, ~, raw_data] = xlsread('E:\研究生阶段文件\test\test.xls');

% 2. 读取 CSV 文件中的数据
data = csvread('E:\研究生阶段文件\test\test.csv');

% 3. 初始化循环变量
start_row = 1;
end_row = find(data(:,1)==9999, 1) - 1;
row_count = 1;

% 4. 创建新的图表
figure('Name', sprintf('Figure %d', row_count));

% 设置图像保存路径
save_path = 'E:\研究生阶段文件\test\文件';

while ~isempty(end_row)
    % 5. 循环绘制子图
    subplot_idx = [2 4 6 3 5 7];
    for i = 1:length(subplot_idx)
        % 6. 计算当前子图所需的数据
        col_idxs = [subplot_idx(i) subplot_idx(i)+6]; % 数据列的索引
        x_data = data(start_row:end_row,1); % X 轴数据
        y_data = data(start_row:end_row,col_idxs); % Y 轴数据
        
        % 7. 创建子图并绘制数据
        subplot(3,3,i);
        hold on;
        
        % 判断一列数据中哪些值是相同的
        is_same = y_data(:,1) == y_data(:,2);
        
        % 绘制部分相同的数据（蓝色）
        plot(x_data(is_same), y_data(is_same,1), 'o', 'MarkerEdgeColor', 'b', 'MarkerSize', 2);
        
        % 绘制不相同的数据（绿色和红色）
        plot(x_data(~is_same), y_data(~is_same,2), 'o', 'MarkerEdgeColor', 'r', 'MarkerSize', 2);
        plot(x_data(~is_same), y_data(~is_same,1), 'o', 'MarkerEdgeColor', 'g', 'MarkerSize', 2);
        
        % 8. 添加标题
        title(raw_data{row_count,1});
    end
    
    % 9. 在第一行子图左边标上P
    annotation('textbox', [0.03 0.75 0.05 0.05], 'String', 'P', 'LineStyle', 'none', 'FontSize', 20);
    % 在第二行子图左边标上S
    annotation('textbox', [0.03 0.45 0.05 0.05], 'String', 'S', 'LineStyle', 'none', 'FontSize', 20);
    % 在第一列子图下面标上E
    annotation('textbox', [0.25 0.09 0.05 0.05], 'String', 'E', 'LineStyle', 'none', 'FontSize', 20);
    % 在第二列子图下面标上N
    annotation('textbox', [0.53 0.09 0.05 0.05], 'String', 'N', 'LineStyle', 'none', 'FontSize', 20);
    % 在第三列子图下面标上U
    annotation('textbox', [0.81 0.09 0.05 0.05], 'String', 'U', 'LineStyle', 'none', 'FontSize', 20);
    
    % 9. 添加总标题
    sgtitle(sprintf('Subplots for Rows %d-%d', start_row, end_row));
    
    % 10. 保存图表
    file_name = sprintf('Figure%d.png', row_count);
    file_path = fullfile(save_path, file_name); % 生成文件完整路径
    saveas(gcf, file_path);
    
    % 11. 更新循环变量
    row_count = row_count + 1;
    start_row = end_row + 2;
    end_row = find(data(start_row:end,1)==9999, 1) + start_row - 2;
    
    % 11. 创建新的图表
    if ~isempty(end_row)
        figure('Name', sprintf('Figure %d', row_count));
        
        % 在第二行子图左边标上S
        annotation('textbox', [0.055 0.375 0.05 0.05], 'String', 'S', 'LineStyle', 'none', 'FontSize', 10);
    end
end
