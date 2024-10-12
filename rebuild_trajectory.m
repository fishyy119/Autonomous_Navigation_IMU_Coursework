% 假设传感器数据为以下格式：
% data(:, 1:3) 为三轴加速度
% data(:, 4:6) 为三轴角速度
% data(:, 7:10) 为四元数（w, x, y, z）或欧拉角（按ZYX顺序）
clc;
clear;
%%
% 计算静止时漂移特征量
% 可能存在的问题：静止状态偏离0是否会是桌面倾斜导致的
drift_data = importdata('s.txt').data;
mean_drift = mean(drift_data);
mean_drift = [mean_drift(1: 2), zeros([1, 10])];  % 只用到a_x与a_y的漂移

% 加载传感器数据
% data = importdata('s.txt').data - mean_drift;
% 如果减去这个均值，轨迹漂移反而更大，可能不是零漂而是桌面的倾斜
% 在大概0.5°的桌面倾角下，沿桌面摩擦力会产生约0.009g的加速度
% 传感器静止状态下的加速度读数很可能是桌面倾斜导致的
data = importdata('s.txt').data;
data = data(470:end, :); % 此处470是因为数据470行以后的姿态角数据明显更加平稳

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
        
        yaw = euler_angles(1) * DEG2RAD;
        pitch = euler_angles(2) * DEG2RAD;
        roll = euler_angles(3) * DEG2RAD;
        R_321 = rot(yaw, pitch, roll);
    else
        % 读取四元数
        q = quaternion(data(i, 7:10)); % 第i行四元数
    end

    % 将加速度转换到世界坐标系
    acc_body = (data(i, 1:3) .* G)'; % 当前测量的加速度
    acc_world = rotateframe(conj(q), acc_body')'; % 使用四元数旋转加速度
    % acc_world = acc_body;

    % 欧拉角，与四元数运算结果一致，可做验证
    % acc_body = (data(i, 1:3) .* G)';
    % acc_world = R_321 * acc_body;

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



%% 321转序 yaw-pitch-roll
function R = rot(yaw, pitch, roll)
    R3 = rotZ(yaw);
    R2 = rotY(pitch);
    R1 = rotX(roll);
    R = R3 * R2 * R1;
end

function R = rotX(t)
    R = [1, 0, 0;
        0, cos(t), -sin(t);
        0, sin(t), cos(t)];
end

function R = rotY(t)
    R = [cos(t), 0, sin(t);
        0, 1, 0;
        -sin(t), 0, cos(t)];
end

function R = rotZ(t)
    R = [cos(t), -sin(t), 0;
        sin(t), cos(t), 0;
        0, 0, 1];
end

