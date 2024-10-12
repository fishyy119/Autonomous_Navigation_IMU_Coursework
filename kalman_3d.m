% 考虑转台倾斜，在三维空间动力学建模
% 不考虑角加速度，无改善
clc;
clear;

%% 计算静止时漂移特征量
drift_data = importdata('s.txt').data;
mean_drift = mean(drift_data);
mean_drift = [mean_drift(1: 2), zeros([1, 10])];  % 只用到a_x与a_y的漂移

% 计算漂移数据的方差，用作测量噪声协方差
var_drift = var(drift_data, 0, 1);
R_noise = diag(var_drift(1:6)); % 测量噪声协方差阵，仅取加速度和角速度的方差
% 还需要乘G和DEG2RAD


%% 测量数据
data = importdata('2.txt').data - mean_drift;

% 定义常量
DEG2RAD = pi / 180;
G = 9.8; % 重力加速度

% 读取测量数据
measured_ax = data(:, 1) .* G;
measured_ay = data(:, 2) .* G;
measured_az = data(:, 3) .* G;
measured_omega_x = data(:, 4) .* DEG2RAD;
measured_omega_y = data(:, 5) .* DEG2RAD;
measured_omega_z = data(:, 6) .* DEG2RAD;
measured_roll = data(:, 7) .* DEG2RAD; % 滚转角 (roll)
measured_pitch = data(:, 8) .* DEG2RAD; % 俯仰角 (pitch)
measured_yaw = data(:, 9) .* DEG2RAD; % 偏航角 (yaw)



% 初始化卡尔曼滤波参数
num_samples = length(measured_ax);
x_hat = zeros(6, num_samples); % 状态估计 [a_x, a_y, a_z, \omega_x, \omega_y, \omega_z]
P = 100 * eye(6); % 误差协方差矩阵
Q = 1e-2 * eye(6); % 过程噪声协方差 (可以根据实际情况调整)

% 卡尔曼滤波
for k = 1:num_samples
    % 预测步骤
    if k > 1
        x_hat(:, k) = x_hat(:, k-1); % 预测状态
        P = P + Q; % 预测误差协方差
    end

    % 获取欧拉角并转换为弧度
    roll = measured_roll(k) * DEG2RAD;
    pitch = measured_pitch(k) * DEG2RAD;
    yaw = measured_yaw(k) * DEG2RAD;
    
    % 计算旋转矩阵 R_321 (roll-pitch-yaw 内旋)
    % 有问题
    % R_321 = [
    %     cos(pitch)*cos(yaw),  cos(pitch)*sin(yaw), -sin(pitch);
    %     sin(roll)*sin(pitch)*cos(yaw) - cos(roll)*sin(yaw), sin(roll)*sin(pitch)*sin(yaw) + cos(roll)*cos(yaw), sin(roll)*cos(pitch);
    %     cos(roll)*sin(pitch)*cos(yaw) + sin(roll)*sin(yaw), cos(roll)*sin(pitch)*sin(yaw) - sin(roll)*cos(yaw), cos(roll)*cos(pitch)
    % ];

    R_321 = [cos(pitch)*cos(yaw), cos(yaw)*sin(pitch)*sin(roll) - cos(roll)*sin(yaw), sin(roll)*sin(yaw) + cos(roll)*cos(yaw)*sin(pitch);
cos(pitch)*sin(yaw), cos(roll)*cos(yaw) + sin(pitch)*sin(roll)*sin(yaw), cos(roll)*sin(pitch)*sin(yaw) - cos(yaw)*sin(roll);
        -sin(pitch),                               cos(pitch)*sin(roll),                               cos(pitch)*cos(roll)];
 

    % 将加速度转换到世界坐标系
    accel_world = R_321 * [measured_ax(k); measured_ay(k); measured_az(k)];

    % 手动加上重力加速度 -g
    accel_world(3) = accel_world(3) - G;


    % 更新步骤
    z = [accel_world; measured_omega_x(k); measured_omega_y(k); measured_omega_z(k)]; % 观测值
    K = P / (P + R_noise); % 卡尔曼增益
    x_hat(:, k) = x_hat(:, k) + K * (z - x_hat(:, k)); % 更新状态估计
    P = (eye(6) - K) * P; % 更新误差协方差

    % 计算目标值
    accel_norm(k) = norm(accel_world);
    omega_norm(k) = norm(x_hat(4:6, k));
    R_values(k) = accel_norm(k) / omega_norm(k) ^ 2;
end

%% 绘图
figure(1);
subplot(3, 1, 1);
plot(x_hat(1, :), 'r-', 'DisplayName', 'Estimated a_x');
hold on;
plot(x_hat(2, :), 'g-', 'DisplayName', 'Estimated a_y');
plot(x_hat(3, :), 'b-', 'DisplayName', 'Estimated a_z');
xlabel('Samples');
ylabel('Acceleration (m/s^2)');
title('Estimated Accelerations');
legend;
grid on;

subplot(3, 1, 2);
plot(x_hat(4, :), 'r-', 'DisplayName', 'Estimated \omega_x');
hold on;
plot(x_hat(5, :), 'm-', 'DisplayName', 'Estimated \omega_y');
plot(x_hat(6, :), 'c-', 'DisplayName', 'Estimated \omega_z');
xlabel('Samples');
ylabel('Angular Velocity (rad/s)');
title('Estimated Angular Velocities');
legend;
grid on;

subplot(3, 1, 3);
plot(measured_roll, 'r-', 'DisplayName', 'Measured Roll');
hold on;
plot(measured_pitch, 'g-', 'DisplayName', 'Measured Pitch');
plot(measured_yaw, 'b-', 'DisplayName', 'Measured Yaw');
xlabel('Samples');
ylabel('Angle (degrees)');
title('Measured Angles');
legend;
grid on;

% 新建图形绘制 R 值和模长
figure(2);
subplot(3, 1, 1);
plot(R_values, 'b-', 'DisplayName', 'R Values');
xlabel('Samples');
ylabel('R Value');
title('R Value Calculation');
legend;
grid on;

subplot(3, 1, 2);
plot(accel_norm, 'r-', 'DisplayName', 'Acceleration Magnitude');
xlabel('Samples');
ylabel('Magnitude');
title('Magnitude Comparison');
legend;
grid on;

subplot(3, 1, 3);
plot(omega_norm, 'g-', 'DisplayName', 'Angular Velocity Magnitude');
xlabel('Samples');
ylabel('Magnitude (m/s^2)');
title('World Coordinate Acceleration Magnitude');
legend;
grid on;

% 原数据与滤波对比
figure(3);
plot(measured_ax, 'r.', 'DisplayName', 'Measured a_x');
hold on;
plot(x_hat(1, :), 'b-', 'DisplayName', 'Estimated a_x');
xlabel('Time (s)');
ylabel('a_x(m/s^2)');
title('Kalman Filter Estimation for a_x');
legend;
grid on;

% 原数据与滤波对比
figure(4);
plot(measured_ay, 'r.', 'DisplayName', 'Measured a_y');
hold on;
plot(x_hat(2, :), 'b-', 'DisplayName', 'Estimated a_y');
xlabel('Time (s)');
ylabel('a_y(m/s^2)');
title('Kalman Filter Estimation for a_y');
legend;
grid on;