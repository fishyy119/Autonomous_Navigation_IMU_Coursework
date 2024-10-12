% 考虑转台非匀速导致的角速度波动
% 计算公式额外加上角加速度项
% 考虑3d情形，不考虑本体坐标系到世界坐标系的转换
clc;
clear;

%% 相关参数
fs = 100; % 采样频率Hz
group_size = 5; % 平均化分组大小
fc = 10; % 截止频率（用于滤波器）
dt = 1 / fs;
DEG2RAD = pi / 180;
G = 9.8015; % 重力加速度 (m/s^2)

% 计算静止时漂移特征量
% 可能存在的问题：静止状态偏离0是否会是桌面倾斜导致的
% 在大概0.5°的桌面倾角下，沿桌面摩擦力会产生约0.009g的加速度
% 传感器静止状态下的加速度读数很可能是桌面倾斜导致的
drift_data = importdata('s.txt').data;
mean_drift = mean(drift_data);
mean_drift = [mean_drift(1: 2), zeros([1, 10])];  % 只用到a_x与a_y的漂移

% 测量数据
% data = importdata('2.txt').data - mean_drift;
data = importdata('o_3.txt');
data = str2double(data.textdata(2:end, 3:12));

% 读取测量数据
measured_ax = data(:, 1) .* G;
measured_ay = data(:, 2) .* G;
measured_az = (data(:, 3) - 1) .* G; % 不考虑本体z轴偏离重力方向
measured_omega_x = data(:, 4) .* DEG2RAD;
measured_omega_y = data(:, 5) .* DEG2RAD;
measured_omega_z = data(:, 6) .* DEG2RAD;

% 低通滤波器滤波
% 表现不佳
[b, a] = butter(2, fc/(fs/2));  % 二阶Butterworth滤波器
filtered_omega_z = filtfilt(b, a, measured_omega_z);  % 双向滤波以消除相位延迟

% 以十个为一组平均化处理
% 表现不佳
averaged_ax = average_sampling(measured_ax, group_size);
averaged_ay = average_sampling(measured_ay, group_size);
averaged_omega_z = average_sampling(measured_omega_z, group_size);


%% 计算 
% 角加速度，平面情形
alpha_z = diff(measured_omega_z) / dt; % 角加速度，注意差分后长度减一
alpha_z = [alpha_z(1); alpha_z];  % 保持与原始数据长度一致，不管第一项
% 使用中央差分法计算角加速度
alpha_z_central = central_diffence_2(measured_omega_z, dt);
alpha_z_central_4 = central_diffence_4(measured_omega_z, dt);
alpha_z_central_8 = central_diffence_8(measured_omega_z, dt);
alpha_z_central_f = central_diffence_2(filtered_omega_z, dt);
alpha_z_central_a = central_diffence_4(averaged_omega_z, dt * group_size);

% 角加速度，三维情形
measured_omega_3d_square = measured_omega_x .^2 + measured_omega_y .^2 + measured_omega_z .^2;
measured_omega_3d = sqrt(measured_omega_3d_square);
alpha_3d = central_diffence_4(measured_omega_3d, dt);

% 加速度，平面情形
measured_acc_total = sqrt(measured_ax.^2 + measured_ay.^2);
averaged_acc_total = sqrt(averaged_ax.^2 + averaged_ay.^2);

% 加速度，三位情形
measured_acc_3d = sqrt(measured_ax.^2 + measured_ay.^2 + measured_az.^2);

% 半径估算 (不考虑角加速度)
R_1 = measured_acc_total ./ (measured_omega_z .^ 2);

% 半径估算 (考虑角加速度，前向差分)
R_2 = measured_acc_total ./ (measured_omega_z .^ 2 + abs(alpha_z));

% 半径估算（中心差分法求角加速度）
% R_4表现最好
% R_5阶数增高反倒更差
R_3 = measured_acc_total ./ (measured_omega_z .^ 2 + abs(alpha_z_central));
R_4 = measured_acc_total ./ (measured_omega_z .^ 2 + abs(alpha_z_central_4));
R_5 = measured_acc_total ./ (measured_omega_z .^ 2 + abs(alpha_z_central_8));
R_3d = measured_acc_3d ./ (measured_omega_3d_square + abs(alpha_3d));

% 使用平均化的数据，考虑角加速度
R_6 = averaged_acc_total ./ (averaged_omega_z .^ 2 + abs(alpha_z_central_a));

% 半径估算（角速度滤波）
% R_5 = measured_acc_total ./ (filtered_omega_z .^ 2 + abs(alpha_z_central_f));

%% 绘制
% T = (1:length(measured_omega_z)) * dt;
% 
% % figure(1);
% % subplot(3, 1, 1);  % 创建一个3行1列的图，第一部分绘制角速度
% % plot(T, measured_omega_z, 'b');
% % title('角速度变化');
% % xlabel('时间 (s)');
% % ylabel('\omega_z (rad/s)');
% % grid on;
% % 
% 
% 
% % 绘制半径估算对比
% figure(1);  % 绘制R_1和R_2的对比
% plot(T, R_1, 'g', 'DisplayName', 'R_1 不考虑角加速度');
% hold on;
% plot(T, R_2, 'm', 'DisplayName', 'R_2 考虑角加速度');
% hold off;
% title('半径估算对比');
% xlabel('时间 (s)');
% ylabel('半径估算 (m)');
% legend('show');
% grid on;
% 
% % 半径估算对比
% figure(2);
% plot(T, R_3, 'g', 'DisplayName', 'R_3 2阶差分');
% hold on;
% plot(T, R_4, 'm', 'DisplayName', 'R_4 4阶差分');
% % plot(T, R_5, 'b', 'DisplayName', 'R_5 8阶差分'); 
% hold off;
% title('半径估算对比');
% xlabel('时间 (s)');
% ylabel('半径估算 (m)');
% legend('show');
% grid on;
% 
% % 绘制角加速度变化
% figure(3);
% plot(T, alpha_z_central, 'g', 'DisplayName',  '2阶差分');
% hold on;
% plot(T, alpha_z_central_4, 'm', 'DisplayName', '4阶差分');
% hold off;
% title('角加速度变化');
% xlabel('时间 (s)');
% ylabel('\alpha_z (rad/s^2)');
% legend('show');
% grid on;
% 
% % 角速度滤波对比
% % figure(10);
% % plot(T, measured_omega_z, 'g', 'DisplayName', '原始测量');
% % hold on;
% % plot(T, filtered_omega_z, 'm', 'DisplayName', '低通滤波');
% % hold off;
% % title('滤波对比');
% % xlabel('时间 (s)');
% % ylabel('角速度 (rad/s)');
% % legend('show');
% % grid on;


%% 数值微分
% 二阶中心差分
function ds = central_diffence_2(s, h)
    ds = (s(3:end) - s(1:end-2)) / (2 * h);
    ds = [ds(1); ds; ds(end)];  % 保持数据长度一致
end

% 四阶中心差分
function ds = central_diffence_4(s, h)
    ds = zeros(length(s), 1);
    for k = 3:length(s)-2
        ds(k) = (-s(k-2) + 8*s(k-1) - 8*s(k+1) + s(k+2)) / (12 * h);
    end
    % 处理边界点（可用较低阶数值微分或其他方法处理）
    ds(1:2) = (s(2:3) - s(1:2)) / h;  % 用一阶差分代替
    ds(end-1:end) = (s(end-1:end) - s(end-2:end-1)) / h;
end

% 八阶中心差分
function ds = central_diffence_8(s, h)
    % 初始化导数数组
    ds = zeros(length(s), 1);

    % 八阶中心差分计算
    for k = 5:length(s)-4
        ds(k) = (-s(k-4) + 4*s(k-3) - 5*s(k-2) + 10*s(k-1) - 10*s(k+1) + 5*s(k+2) - 4*s(k+3) + s(k+4)) / (280 * h);
    end

    % 边界处理（使用低阶差分来处理边界点）
    % 前四个点使用一阶前向差分
    ds(1:4) = (s(2:5) - s(1:4)) / h;
    
    % 最后四个点使用一阶后向差分
    ds(end-3:end) = (s(end-3:end) - s(end-4:end-1)) / h;
end

%% 平均化
function averaged_data = average_sampling(data, group_size)
    % 输入参数:
    % data: 原始采样数据
    % group_size: 每组数据的大小，100Hz采样下，每组10个数据点

    % 舍去多余的样本
    n = floor(length(data) / group_size) * group_size;
    truncated_data = data(1:n);

    % 将数据重塑为 group_size 行
    reshaped_data = reshape(truncated_data, group_size, []);

    % 计算每组的平均值
    averaged_data = mean(reshaped_data, 1);
    averaged_data = averaged_data';
end
