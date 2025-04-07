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