% 假设传感器数据为以下格式：
% data(:, 1:3) 为三轴加速度
% data(:, 4:6) 为三轴角速度
% data(:, 7:10) 为四元数（w, x, y, z）或欧拉角（按ZYX顺序）
clc;
clear;
%%
% 各种参数
fs = 100; % 采样频率Hz
dt = 1 / fs;
DEG2RAD = pi / 180;
G = 9.8015; % 重力加速度 (m/s^2)
USE_EULER = 1; % 开关变量：0表示使用四元数，1表示使用欧拉角

% 数据导入
% 最后用来出图的数据：
% 1.  sd_1, 700, 疑似撞大运
% 2.  eu_2 和两个 union 的数据效果好， 
% ! eu_1 和 ed_1 的数据不行，大胆假设是传感器设置问题而不是我程序的问题
data = importdata(['eu_2.txt']).data;
static_index =300; % 静止数据对应的终止序号，用于修正，需要手调

% 计算静止时漂移特征量
data_static = data(1:static_index, :);
acc_error_world = cal_static_error(data_static, USE_EULER, G)
% acc_error_world = [-0.0673   -0.0982   -0.0171]; % 尝试手调让初始段平直

% 需要进行正式计算的数据
data_move = data;
acc_world_combi = cal_acc_world(data_move, USE_EULER, G);
acc_world_combi_correct = acc_world_combi - acc_error_world;

num_samples = size(data_move, 1);
position = zeros(num_samples, 3); % 初始化位置
velocity = zeros(num_samples, 3); % 初始化速度
position_correct = zeros(num_samples, 3); % 初始化位置
velocity_correct = zeros(num_samples, 3); % 初始化速度


%% 主循环
for i = 2:num_samples
    % 梯形法则
    acc_world_last = acc_world_combi(i - 1, :);
    acc_world = acc_world_combi(i, :);
    acc_world_mean = (acc_world + acc_world_last) / 2;
    % 更新速度和位置
    velocity(i, :) = velocity(i-1, :) + acc_world_mean .* dt; % 更新速度
    position(i, :) = position(i-1, :) + ((velocity(i, :) + velocity(i-1, :))/2) .* dt; % 更新位置

    acc_world_correct = acc_world_combi_correct(i, :);
    acc_world_correct_last = acc_world_combi_correct(i-1, :);
    acc_world_correct_mean = (acc_world_correct_last + acc_world_correct)/2;
    velocity_correct(i, :) = velocity_correct(i-1, :) + acc_world_correct_mean .* dt; % 更新速度
    position_correct(i, :) = position_correct(i-1, :) + ...
        ((velocity_correct(i, :) + velocity_correct(i-1, :))/2) .* dt; % 更新位置
end

%% 绘制轨迹
% 三维轨迹绘制与对比图
% 
% % Figure 1: 绘制 position 的三维轨迹
% figure(1);
% plot3(position(:, 1), position(:, 2), position(:, 3), 'b', 'LineWidth', 1.5);
% title('Position 轨迹', 'FontSize', 14);
% xlabel('X 位置 (m)', 'FontSize', 12);
% ylabel('Y 位置 (m)', 'FontSize', 12);
% zlabel('Z 位置 (m)', 'FontSize', 12);
% grid on;
% % axis equal; % 保持各轴缩放比例相同
% 
% % Figure 2: 绘制 position_correct 的三维轨迹
% figure(2);
% plot3(position_correct(:, 1), position_correct(:, 2), position_correct(:, 3), 'r', 'LineWidth', 1.5);
% title('Corrected Position 轨迹', 'FontSize', 14);
% xlabel('X 位置 (m)', 'FontSize', 12);
% ylabel('Y 位置 (m)', 'FontSize', 12);
% zlabel('Z 位置 (m)', 'FontSize', 12);
% grid on;
% % axis equal; % 保持各轴缩放比例相同
% 
% % Figure 3: 比较 position 与 position_correct 的各分量
% figure(3);
% subplot(3, 1, 1);
% plot((1:num_samples) * dt, position(:, 1), 'b');
% hold on;
% plot((1:num_samples) * dt, position_correct(:, 1), 'r');
% quick_set_font('X 轴位置对比', '时间 (s)', 'X 位置 (m)');
% legend({'修正前', '修正后'}, 'FontSize', 14);
% hold off;
% 
% subplot(3, 1, 2);
% plot((1:num_samples) * dt, position(:, 2), 'b');
% hold on;
% plot((1:num_samples) * dt, position_correct(:, 2), 'r');
% quick_set_font('Y 轴位置对比', '时间 (s)', 'Y 位置 (m)');
% legend({'修正前', '修正后'}, 'FontSize', 14);
% hold off;
% 
% subplot(3, 1, 3);
% plot((1:num_samples) * dt, position(:, 3), 'b');
% hold on;
% plot((1:num_samples) * dt, position_correct(:, 3), 'r');
% quick_set_font('Z 轴位置对比', '时间 (s)', 'Z 位置 (m)');
% legend({'修正前', '修正后'}, 'FontSize', 14);
% hold off;

% 
figure(4);
plot((1:num_samples) * dt, position_correct(:, 3), 'r');
quick_set_font('Z 轴位置对比', '时间 (s)', 'Z 位置 (m)');


% 快速设置字体
function quick_set_font(titleStr, xlabelStr, ylabelStr)
    % 字体大小设定
    titleFontSize = 20;
    labelFontSize = 15;
    tickFontSize = 14;
    lineWidth = 2;

    % 设置标题、坐标轴标签和刻度字体大小的函数
    % title(titleStr, 'FontSize', titleFontSize);
    xlabel(xlabelStr, 'FontSize', labelFontSize);
    ylabel(ylabelStr, 'FontSize', labelFontSize);
    set(gca, 'FontSize', tickFontSize);
    grid on;

    % 设置线宽
    lines = findobj(gca, 'Type', 'Line');  % 获取当前图的所有线条对象
    set(lines, 'LineWidth', lineWidth);
end

