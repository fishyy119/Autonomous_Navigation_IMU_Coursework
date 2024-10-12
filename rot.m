% 321转序 yaw-pitch-roll
syms yaw pitch roll

R3 = [cos(yaw), -sin(yaw), 0;
    sin(yaw), cos(yaw), 0;
    0, 0, 1];

R2 = [cos(pitch), 0, sin(pitch);
    0, 1, 0;
    -sin(pitch), 0, cos(pitch)];

R1 = [1, 0, 0;
    0, cos(roll), -sin(roll);
    0, sin(roll), cos(roll)];

R3 * R2 * R1