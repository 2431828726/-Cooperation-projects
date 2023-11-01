% 读取第一个CSV文件
data1 = csvread('E:\研究生阶段文件\原始处理数据\时间平滑\30D.csv');

% 读取第二个CSV文件
data2 = csvread('E:\研究生阶段文件\原始处理数据\时间平滑\站点所有.csv');

% 初始化循环变量
row_count1 = 1;
row_count2 = 1;

% 遍历第一个CSV文件的行
while row_count1 <= size(data1,1)
    % 如果当前行是空白行
    if all(isnan(data1(row_count1,:)))
        % 将第二个CSV文件的行填充到当前空白行
        if row_count2 <= size(data2,1)
            data1(row_count1,:) = data2(row_count2,:);
            row_count2 = row_count2 + 1;
        else
            % 如果第二个CSV文件的行已经用完，退出循环
            break;
        end
    end
    row_count1 = row_count1 + 1;
end

% 保存结果到新的CSV文件
csvwrite('E:\研究生阶段文件\原始处理数据\时间平滑\30result.csv', data1);
