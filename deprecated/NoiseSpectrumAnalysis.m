% NoiseSpectrumAnalysis.m
% 该脚本用于导入噪声数据并进行谱分析
% 使用 importdata 函数导入 's.txt' 文件中的数据
% 计算信号的功率谱并绘制频谱图

% 导入噪声数据
data = importdata('s.txt').data;

% 假设数据是一个列向量
signal = data(:, 1);  % 确保数据为列向量

% 中心化信号
signal = signal - mean(signal);

% 采样频率（根据你的数据设置）
fs = 1000;  % 例如 1000 Hz

% 快速傅里叶变换
N = length(signal);
fft_result = fft(signal);
frequencies = (0:N-1)*(fs/N);  % 频率向量
power_spectrum = abs(fft_result).^2 / N;  % 功率谱

% 绘制频谱图（只绘制正频率部分）
figure;
plot(frequencies(1:N/2), power_spectrum(1:N/2));
title('Power Spectrum');
xlabel('Frequency (Hz)');
ylabel('Power');
grid on;
