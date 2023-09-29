% 清除之前的图形和变量
clf;
clear;

% 设置文件夹路径和文件名
folderPath = {'E:\研究生阶段文件\test\7.26\一段', 'E:\研究生阶段文件\test\7.26\二段', 'E:\研究生阶段文件\test\7.26\三段'};

fileNames = {'1.txt', '2.txt', '3.txt', '4.txt', '5.txt', '6.txt', '7.txt', '8.txt'};

% 设置每个文件夹对应的颜色
folderColors = {'r', 'g', 'b'};
% 绘制图形
hold on;

legendLabels = {}; % 图例标签

for folderIndex = 1:numel(folderPath)
    currentFolderPath = folderPath{folderIndex};
    currentColor = folderColors{folderIndex};

    for fileIndex = 1:numel(fileNames)
        % 构建完整的文件路径
        filePath = fullfile(currentFolderPath, fileNames{fileIndex});

        % 读取txt文件中的数据
        try
            fileData = readmatrix(filePath);

            % 计算y轴偏移量
            offset = (fileIndex - 1) * 30;

            % 绘制数据点，加上偏移量和设置点的大小为3
            scatter(fileData(:, 1), fileData(:, 7) + offset, 3, currentColor, 'filled');
        catch
            continue; % 忽略读取失败的文件
        end
    end
    
    % 为当前文件夹添加图例标签
    legendLabels{end+1} = currentFolderPath;
end

% 设置图形标题和轴标签
title('Data Plot');
xlabel('X');
ylabel('Y');

% 添加图例
%legend(legendLabels);

% 显示图形
hold off;
