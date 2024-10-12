% 假设传感器数据为以下格式：
% data(:, 1:3) 为三轴加速度
% data(:, 4:6) 为三轴角速度
% data(:, 7:10) 为四元数（w, x, y, z）或欧拉角（按ZYX顺序）
clc;
clear;
%%
% 加载传感器数据
data = importdata('s.txt').data;
data = data(300:end, :);

% 各种参数
fs = 100; % 采样频率Hz
dt = 1 / fs;
DEG2RAD = pi / 180;
G = 9.8015; % 重力加速度 (m/s^2)
USE_EULER = 1; % 开关变量：0表示使用四元数，1表示使用欧拉角


num_samples = size(data, 1);
position = zeros(num_samples, 3); % 初始化位置
velocity = zeros(num_samples, 3); % 初始化速度


%% 主循环
for i = 2:num_samples
    if USE_EULER
        % 读取欧拉角（ZYX）
        euler_angles = data(i, 7:9); % 假设ZYX顺序
        euler_angles = [euler_angles(3), euler_angles(2), euler_angles(1)]; % 调整顺序
        q = quaternion(euler_angles, 'eulerd', 'ZYX', 'frame'); % 转换为四元数
    else
        % 读取四元数
        q = quaternion(data(i, 7:10)); % 第i行四元数
    end

    % 将加速度转换到世界坐标系
    acc_body = (data(i, 1:3) .* G)'; % 当前测量的加速度
    acc_world = rotateframe(conj(q), acc_body')'; % 使用四元数旋转加速度

    % 手动减去重力加速度
    acc_world(3) = acc_world(3) - G;
    acc_world_rec(i, :) = acc_world';

    % 更新速度和位置
    velocity(i, :) = velocity(i-1, :) + acc_world' .* dt; % 更新速度
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


