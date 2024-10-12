% 使用AR(1)建模过程噪声
% 不好
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
alpha_z_central = load('alpha.mat').alpha_z_central;


% 假设已知 AR(1) 模型参数
a1 = 0.3679;  % 从 Allan 方差中提取
sigma_w = 1.6487;  % 角加速度噪声方差
sigma_omega = 1e-2; % 假设角速度噪声方差

% 卡尔曼滤波参数
Q = diag([sigma_omega, sigma_w, 0]);  % 过程噪声协方差
R = 0;  % 测量噪声协方差

% 初始化状态
x_hat(:, 1) = [0; alpha_z_central(1:2)];  % 初始状态 [角速度, 当前角加速度, 上一时刻角加速度]
P = eye(3);  % 初始协方差矩阵

% 状态转移矩阵
F = [1, 0, 0; 0, 0, a1; 0, 1, 0];  % 状态转移矩阵
H = [1, 0, 0];  % 测量矩阵

% 卡尔曼滤波循环
for k = 2:length(measured_omega_z)
    % 预测步骤
    x_hat(:, k) = F * x_hat(:, k-1);  % 状态预测
    P = F * P * F' + Q;  % 协方差预测

    % 更新步骤
    K = P * H' / (H * P * H' + R);  % 卡尔曼增益
    x_hat(:, k) = x_hat(:, k) + K * (measured_omega_z(k) - H * x_hat(:, k));  % 更新状态
    P = (eye(size(K, 1)) - K * H) * P;  % 更新协方差
end
