clc;
clear;
%% 单位转换
DEG2RAD = pi / 180;
G = 9.8;
%% 导入静止漂移数据
drift_data = importdata('s.txt').data;
drift_ax = drift_data(:, 1) .* G; % 第一列为漂移 a_x
drift_ay = drift_data(:, 2) .* G; % 第二列为漂移 a_y
drift_omega_z = drift_data(:, 6) .* DEG2RAD; % 第六列为漂移 omega_z

% 计算测量噪声的方差
var_ax = var(drift_ax);
var_ay = var(drift_ay);
var_omega_z = var(drift_omega_z);

%% 导入数据
data = importdata('2.txt').data;

% 假设 data 的列为 a_x, a_y, 和 omega_z
measured_ax = data(:, 1) .* G; % 第一列为 a_x
measured_ay = data(:, 2) .* G; % 第二列为 a_y
measured_omega_z = data(:, 6) .* DEG2RAD; % 第六列为 omega_z

% 设置采样频率（根据现实数据的采样频率）
fs = 100; % 采样频率 (Hz) - 根据实际情况修改
dt = 1/fs; % 时间间隔 (s)
num_samples = length(measured_ax);
t = (0:num_samples-1) * dt; % 时间向量

% 初始化卡尔曼滤波参数
F = eye(3); % 状态转移矩阵
H = eye(3); % 测量矩阵
Q = 1e-6 * eye(3); % 过程噪声协方差 (可以根据实际情况调整)
R = diag([var_ax, var_ay, var_omega_z]); % 根据漂移数据的方差设置测量噪声协方差矩阵
x_hat = zeros(3, num_samples); % 状态估计
P = eye(3); % 误差协方差矩阵

% 卡尔曼滤波
for k = 1:num_samples
    % 预测步骤
    if k > 1
        x_hat(:, k) = F * x_hat(:, k-1); % 预测状态
        P = F * P * F' + Q; % 预测误差协方差
    end

    % 更新步骤
    z = [measured_ax(k); measured_ay(k); measured_omega_z(k)]; % 观测值
    K = P * H' / (H * P * H' + R); % 卡尔曼增益
    x_hat(:, k) = x_hat(:, k) + K * (z - H * x_hat(:, k)); % 更新状态估计
    P = (eye(3) - K * H) * P; % 更新误差协方差

    % 计算 R 值
    a_x_filtered = x_hat(1, k); % 滤波后的 a_x
    a_y_filtered = x_hat(2, k); % 滤波后的 a_y
    omega_z_filtered = x_hat(3, k); % 滤波后的 omega_z
    if omega_z_filtered ~= 0
        R_values(k) = sqrt(a_x_filtered^2 + a_y_filtered^2) / omega_z_filtered^2;
    else
        R_values(k) = NaN; % 避免除以零
    end
end

%% 绘制三个状态的图
figure;

subplot(3,1,1);
plot(t, measured_ax, 'r.', 'DisplayName', 'Measured a_x');
hold on;
plot(t, x_hat(1, :), 'b-', 'DisplayName', 'Estimated a_x');
xlabel('Time (s)');
ylabel('a_x');
title('Kalman Filter Estimation for a_x');
legend;
grid on;

subplot(3,1,2);
plot(t, measured_ay, 'g.', 'DisplayName', 'Measured a_y');
hold on;
plot(t, x_hat(2, :), 'm-', 'DisplayName', 'Estimated a_y');
xlabel('Time (s)');
ylabel('a_y');
title('Kalman Filter Estimation for a_y');
legend;
grid on;

subplot(3,1,3);
plot(t, measured_omega_z, 'k.', 'DisplayName', 'Measured \omega_z');
hold on;
plot(t, x_hat(3, :), 'c-', 'DisplayName', 'Estimated \omega_z');
xlabel('Time (s)');
ylabel('\omega_z');
title('Kalman Filter Estimation for \omega_z');
legend;
grid on;

% 绘制 R 值变化图
figure(2);
plot(t, R_values, 'b-', 'DisplayName', 'R');
xlabel('Time (s)');
ylabel('R');
title('Radius R over Time');
legend;
grid on;