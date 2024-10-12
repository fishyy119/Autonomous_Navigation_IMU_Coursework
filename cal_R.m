R = R_2; % 其他脚本计算得出，根据不同时刻的测量数据计算得出
R = R(10: end-10); % 舍弃首尾

mean_R = mean(R);
std_R = std(R);

% 去除极端值
z_scores = (R - mean_R) / std_R;
R_cut = R(abs(z_scores) < 3);  % 去除 z-score 大于 3 的值

mean_cut = mean(R_cut);
median_cut = median(R_cut);

%% 创建直方图（另一种方法，寻找众数）
bin_width = 0.02; % 区间宽度
edges = 0:bin_width:3;
[counts, edges] = histcounts(R, edges, 'Normalization', 'probability');  % 计算归一化后的概率（频率）

% 找到直方图的峰顶位置
[~, peakIndex] = max(counts);  % 获取频率最高的bin索引

% 初始化区间，从峰顶开始扩展
cumulative_counts = cumsum(counts);  % 计算累积频率
target_cumulative = 0.2;  % 设定目标累积频率（0.3 或 0.5）
leftIndex = peakIndex;  % 左边界从峰顶开始
rightIndex = peakIndex;  % 右边界从峰顶开始

% 扩展区间，直到累积频率达到目标值，同时保持两侧尽量对称
while cumulative_counts(rightIndex) - cumulative_counts(leftIndex-1) < target_cumulative
    % 向两侧扩展
    if leftIndex > 1
        leftIndex = leftIndex - 1;  % 向左扩展
    end
    if rightIndex < length(counts)
        rightIndex = rightIndex + 1;  % 向右扩展
    end
end

% 计算最终选定的区间
mode_interval = edges(leftIndex:rightIndex+1);

% 绘制直方图
figure;
histogram(R, edges, 'Normalization', 'probability');
title('半径数据直方图');
xlabel('半径 (m)');
ylabel('频率');
xlim([0, 1.5]);
grid on;

% 标注选定的区间
hold on;
y_limits = ylim; % 获取 y 轴的上下限
plot([mode_interval(1), mode_interval(1)], y_limits, 'r--', 'DisplayName', '目标累积频率区间');
plot([mode_interval(end), mode_interval(end)], y_limits, 'r--');
legend('show');
hold off;