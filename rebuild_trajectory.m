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
data = importdata('s.txt').data;
static_index = 1700; % 静止数据对应的终止序号，用于修正

% 计算静止时漂移特征量
data_static = data(1:static_index, :);
acc_error_world = cal_static_error(data_static, USE_EULER, G)

% 需要进行正式计算的数据
data_move = data;
acc_world_combi = cal_acc_world(data_move, USE_EULER, G);
% acc_world_combi = acc_world_combi - acc_error_world;

num_samples = size(data_move, 1);
position = zeros(num_samples, 3); % 初始化位置
velocity = zeros(num_samples, 3); % 初始化速度


%% 主循环
for i = 2:num_samples
    acc_world = acc_world_combi(i, :);
    % 更新速度和位置
    velocity(i, :) = velocity(i-1, :) + acc_world .* dt; % 更新速度
    position(i, :) = position(i-1, :) + velocity(i, :) .* dt; % 更新位置
end

%% 绘制轨迹
figure;
plot3(position(:, 1), position(:, 2), position(:, 3));
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Trajectory');
grid on;






