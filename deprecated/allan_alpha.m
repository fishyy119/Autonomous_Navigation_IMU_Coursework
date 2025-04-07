% 使用Allan方差辨识角加速度噪声参数

%% 参数设定
f = 100; % 采样频率Hz
dt = 1 / f;
DEG2RAD = pi / 180;
G = 9.8; % 重力加速度

% 假设 alpha_z 是差分计算得到的角加速度
alpha_z = load('alpha.mat').alpha_z;
alpha_z_central = load('alpha.mat').alpha_z_central;

% 使用 Allan 方差进行噪声分析
[avar, tau] = allanvar(alpha_z, 1:1000, f);

% 绘制 Allan 方差曲线
figure;
loglog(tau, sqrt(avar));  % Allan 方差的平方根
title('角加速度 Allan 方差');
xlabel('时间间隔 \tau (s)');
ylabel('Allan 方差 \sigma(\tau)');
grid on;
