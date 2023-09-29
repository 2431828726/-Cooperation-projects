clf;
clear;

% 设置文件夹路径和文件名
folderPath = 'E:\研究生阶段文件\test\2023.8.11\54'; % 文件夹路径
fileNames = {'1.txt', '2.txt', '3.txt', '4.txt', '5.txt', '6.txt', '7.txt', '8.txt'}; % 文件名

% 设置每个文件夹对应的颜色
folderColors = {'b', 'r'};

% 绘制图形
hold on;

legendLabels = {}; % 图例标签

for fileIndex = 1:numel(fileNames)
    currentFileName = fileNames{fileIndex};

    % 构建完整的文件路径
    filePath = fullfile(folderPath, currentFileName);

    % 读取txt文件中的数据
    try
        fileData = readmatrix(filePath);

        % 获取第一列数据
        x = fileData(:, 1);

        % 获取第二列数据
        y1 = fileData(:, 2);

        % 获取第三列数据
        y2 = fileData(:, 3);

        % 计算y轴偏移量
        offset = (fileIndex - 1) * 50;

        % 绘制第一列与第二列的散点，使用蓝色表示
        scatter(x, y1 + offset, 3, folderColors{1}, 'filled');

        % 绘制第一列与第三列的散点，使用红色表示
        scatter(x, y2 + offset, 3, folderColors{2}, 'filled');

    catch
        continue; % 忽略读取失败的文件
    end
end

% 设置图形标题和轴标签
title('Data Plot');
xlabel('X');
ylabel('Y');


% 显示图形
hold off;