% 计算世界坐标系下三轴加速度
% 需要用到姿态旋转
% 假设传感器数据为以下格式：
% data(:, 1:3) 为三轴加速度
% data(:, 4:6) 为三轴角速度
% data(:, 7:10) 为四元数（w,x,y,z）
% data(:, 7:9) 为欧拉角（ZYX内旋）（x,y,z）

function acc_world_combi = cal_acc_world(sample, USE_EULER, G)
    DEG2RAD = pi / 180;
    num_samples = size(sample, 1);
    acc_world_combi = zeros(num_samples, 3);
    for i = 1:num_samples
        if USE_EULER
            % 读取欧拉角（ZYX）
            euler_angles = sample(i, 7:9); % 假设ZYX顺序
            euler_angles = [euler_angles(3), euler_angles(2), euler_angles(1)]; % 调整顺序
            q = quaternion(euler_angles, 'eulerd', 'ZYX', 'frame'); % 转换为四元数
            
            yaw = euler_angles(1) * DEG2RAD;
            pitch = euler_angles(2) * DEG2RAD;
            roll = euler_angles(3) * DEG2RAD;
            R_321 = rot(yaw, pitch, roll);
        else
            % 读取四元数
            q = quaternion(sample(i, 7:10)); % 第i行四元数
        end
    
        % 将加速度转换到世界坐标系
        acc_body = (sample(i, 1:3) .* G)'; % 当前测量的加速度
        acc_world = rotateframe(conj(q), acc_body')'; % 使用四元数旋转加速度
        % acc_world = acc_body;
    
        % 欧拉角，与四元数运算结果一致，可做验证
        % acc_body = (data(i, 1:3) .* G)';
        % acc_world = R_321 * acc_body;
    
        % 手动减去重力加速度
        acc_world(3) = acc_world(3) - G;
        acc_world_combi(i, :) = acc_world';
    end
end

%% 321转序 yaw-pitch-roll
function R_321 = rot(yaw, pitch, roll)
    R3 = rotZ(yaw);
    R2 = rotY(pitch);
    R1 = rotX(roll);
    R_321 = R3 * R2 * R1;
    % 基本旋转
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
end