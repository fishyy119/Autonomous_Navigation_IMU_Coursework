% 绘制原始数据
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
data = importdata('1.txt').data;
% static_index = 1700; % 静止数据对应的终止序号，用于修正

% 计算静止时漂移特征量
% data_static = data(1:static_index, :);
% acc_error_world = cal_static_error(data_static, USE_EULER, G)

% 读取测量数据
measured_ax = data(:, 1);
measured_ay = data(:, 2);
measured_az = data(:, 3);
measured_omega_x = data(:, 4);
measured_omega_y = data(:, 5);
measured_omega_z = data(:, 6);
measured_roll = data(:, 7); % 滚转角 (roll)
measured_pitch = data(:, 8); % 俯仰角 (pitch)
measured_yaw = data(:, 9); % 偏航角 (yaw)

%%
% 创建第一个 figure，展示三轴加速度
figure(1);
subplot(3, 1, 1);  % 第一部分绘制 x 轴加速度
plot((1:length(measured_ax)) * dt, measured_ax, 'r');
quick_set_font('X轴加速度', '时间 (s)', '加速度 (g)');

subplot(3, 1, 2);  % 第二部分绘制 y 轴加速度
plot((1:length(measured_ay)) * dt, measured_ay, 'g');
quick_set_font('Y轴加速度', '时间 (s)', '加速度 (g)');

subplot(3, 1, 3);  % 第三部分绘制 z 轴加速度
plot((1:length(measured_az)) * dt, measured_az, 'b');
quick_set_font('Z轴加速度', '时间 (s)', '加速度 (g)');

% 创建第二个 figure，展示三轴角速度
figure(2);
subplot(3, 1, 1);  % 第一部分绘制 x 轴角速度
plot((1:length(measured_omega_x)) * dt, measured_omega_x, 'r');
quick_set_font('X轴角速度', '时间 (s)', '角速度 (°/s)');

subplot(3, 1, 2);  % 第二部分绘制 y 轴角速度
plot((1:length(measured_omega_y)) * dt, measured_omega_y, 'g');
quick_set_font('Y轴角速度', '时间 (s)', '角速度 (°/s)');

subplot(3, 1, 3);  % 第三部分绘制 z 轴角速度
plot((1:length(measured_omega_z)) * dt, measured_omega_z, 'b');
quick_set_font('Z轴角速度', '时间 (s)', '角速度 (°/s)');

% 创建第三个 figure，展示三轴姿态角
figure(3);
subplot(3, 1, 1);  % 第一部分绘制滚转角
plot((1:length(measured_roll)) * dt, measured_roll, 'r');
quick_set_font('滚转角 (Roll)', '时间 (s)', '角度 (°)');

subplot(3, 1, 2);  % 第二部分绘制俯仰角
plot((1:length(measured_pitch)) * dt, measured_pitch, 'g');
quick_set_font('俯仰角 (Pitch)', '时间 (s)', '角度 (°)');

subplot(3, 1, 3);  % 第三部分绘制偏航角
plot((1:length(measured_yaw)) * dt, measured_yaw, 'b');
quick_set_font('偏航角 (Yaw)', '时间 (s)', '角度 (°)');


% 快速设置字体
function quick_set_font(titleStr, xlabelStr, ylabelStr)
    % 字体大小设定
    titleFontSize = 18;
    labelFontSize = 16;
    tickFontSize = 14;
    lineWidth = 2;

    % 设置标题、坐标轴标签和刻度字体大小的函数
    title(titleStr, 'FontSize', titleFontSize);
    xlabel(xlabelStr, 'FontSize', labelFontSize);
    ylabel(ylabelStr, 'FontSize', labelFontSize);
    set(gca, 'FontSize', tickFontSize);
    grid on;

    % 设置线宽
    lines = findobj(gca, 'Type', 'Line');  % 获取当前图的所有线条对象
    set(lines, 'LineWidth', lineWidth);
end
