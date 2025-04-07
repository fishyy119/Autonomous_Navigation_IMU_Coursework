% 考虑转台非匀速导致的角速度波动
% 使用kalman滤波估计角速度与角加速度
%%% 无法估计角加速度
% 计算公式额外加上角加速度项
% 仅考虑平面情形
clc;
clear;

%% 参数设定
f = 100; % 采样频率Hz
dt = 1 / f;
DEG2RAD = pi / 180;
G = 9.8; % 重力加速度

% 读取测量数据
data = importdata('2.txt').data;
measured_ax = data(:, 1) .* G;
measured_ay = data(:, 2) .* G;
measured_omega_z = data(:, 6) .* DEG2RAD;

% 状态向量初始化 [omega_z; alpha_z]
X_k = [measured_omega_z(1); 0];  % 初始角速度和角加速度
num_samples = length(measured_omega_z);

% 状态转移矩阵 A
A = [1 dt; 0 1];

% 观测矩阵 H
H = [1 0];

% 过程噪声协方差矩阵 Q
Q = diag([0, 1e-3]);  % 这里的噪声值可根据实际调整

% 测量噪声协方差矩阵 R
R = 0;  % 这里的噪声值可根据实际调整

% 状态协方差矩阵 P
P = eye(2);

% 保存卡尔曼滤波结果
omega_kalman = zeros(num_samples, 1);
alpha_kalman = zeros(num_samples, 1);

%% 卡尔曼滤波循环
for k = 1:num_samples
    % 预测步骤
    X_k_pred = A * X_k;  % 预测的状态
    P_pred = A * P * A' + Q;  % 预测的状态协方差矩阵

    % 测量更新步骤
    Z_k = measured_omega_z(k);  % 当前时刻的测量值
    K_k = P_pred * H' / (H * P_pred * H' + R);  % 卡尔曼增益

    X_k = X_k_pred + K_k * (Z_k - H * X_k_pred);  % 更新的状态估计
    P = (eye(2) - K_k * H) * P_pred;  % 更新的协方差矩阵

    % 保存估计值
    omega_kalman(k) = X_k(1);  % 更新后的角速度
    alpha_kalman(k) = X_k(2);  % 更新后的角加速度
end

%% 绘图
figure;

% 绘制卡尔曼滤波估计的角速度
subplot(2, 1, 1);
plot((1:num_samples) * dt, measured_omega_z, 'b', 'DisplayName', 'Measured \omega_z');
hold on;
plot((1:num_samples) * dt, omega_kalman, 'r', 'DisplayName', 'Estimated \omega_z (Kalman)');
title('角速度估计');
xlabel('时间 (s)');
ylabel('\omega_z (rad/s)');
legend('show');
grid on;

% 绘制卡尔曼滤波估计的角加速度
subplot(2, 1, 2);
plot((1:num_samples) * dt, alpha_kalman, 'r', 'DisplayName', '\alpha_z (Kalman)');
title('角加速度估计');
xlabel('时间 (s)');
ylabel('\alpha_z (rad/s^2)');
legend('show');
grid on;
