h = 21500; % km
Re = 6378; % km
T = 86280; % s 
f = 1575.42; % MHz
c = 299792; % km/s

%% 地心仰角
theta = 0: 0.001: pi;
vs = 2 * pi / T * (h + Re);
rs = sqrt(Re^2 + (h+Re)^2 - 2*Re*(h+Re)*sin(theta));
vd = vs * Re * cos(theta) ./ rs;
fd = vd / c * f;
theta_plot = theta * 180 / pi;
fd = fd * 1e6;

%% 地平仰角
beta = asin(Re .* cos(theta) ./ rs);
phi = theta - beta;
% phi = acos(cos(theta) .* rs / (Re + h)); 
phi_plot = phi * 180 / pi;

%% 绘图
figure(1);
subplot(2, 1, 1);
plot(theta_plot, fd);
grid on;
xlabel('地心仰角(deg)');
ylabel('多普勒频移(Hz)');

subplot(2, 1, 2);
plot(phi_plot, fd);
grid on;
xlim([0, 180]);
xlabel('地平仰角(deg)');
ylabel('多普勒频移(Hz)');

