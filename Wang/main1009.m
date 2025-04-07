clear 
clc
%
data=importdata('.\resources\20241009173715.txt');
% data=importdata('.\resources\20241009170852.txt');
Size = size(data.data,1);
dt = 0.001;
% dt = zeros(Size,1);
% WithoutDateAndHour = repmat("0",Size,1);
% WithoutMinute = repmat("0",Size,1);
% WithoutSecond = repmat("0",Size,1);
% for i = 2:Size
%     WithoutDateAndHour(i-1) = extractAfter(data.textdata{i, 1},':');
%     WithoutMinute(i-1) = extractAfter(WithoutDateAndHour(i-1),':');
%     WithoutSecond(i-1) = extractAfter(WithoutMinute(i-1),':');
%     dt(i-1) = (str2double(WithoutSecond(i))-str2double(WithoutSecond(i-1)))/1000;
%     if dt(i)<0
%         dt(i) = dt(i)+1000;
%     end
% end
ax = data.data(:,1).*9.8;
ay = data.data(:,2).*9.8;
az = (data.data(:,3)-1).*9.8;
vx = zeros(Size,1);
vy = zeros(Size,1);
vz = zeros(Size,1);
x = zeros(Size,1);
y = zeros(Size,1);
z = zeros(Size,1);
omegax = data.data(:,4).*(pi/180);
omegay = data.data(:,5).*(pi/180);
omegaz = data.data(:,6).*(pi/180);
anglex = data.data(:,7).*(pi/180);
angley = data.data(:,8).*(pi/180);
anglez = data.data(:,9).*(pi/180);
alpha = zeros(Size,1);
a_square = ax.^2+ay.^2+az.^2;
omega_square = omegax.^2+omegay.^2+omegaz.^2;
omega = sqrt(omega_square);
for i = 2:Size
    alpha(i) = (omega(i)-omega(i-1))/dt;
end
% r = sqrt(a_square./(omega_square.^2+alpha.^2));
r = sqrt(a_square) ./ (omega_square + abs(alpha));
r_average = mean(r);
plot(r)
% for i = 2:Size
%     vx(i) = vx(i-1)+dt(i-1)*ax(i-1);
%     vy(i) = vy(i-1)+dt(i-1)*ay(i-1);
%     vz(i) = vz(i-1)+dt(i-1)*az(i-1);
%     x(i) = x(i-1)+dt(i-1)*vx(i-1);
%     y(i) = y(i-1)+dt(i-1)*vy(i-1);
%     z(i) = z(i-1)+dt(i-1)*vz(i-1);
% end

    