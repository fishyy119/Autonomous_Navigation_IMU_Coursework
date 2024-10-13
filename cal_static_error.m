% 根据静止段的测量数据，解算世界坐标系下三轴加速度，将其与0的偏差作为修正量
% 由于有多条静止数据，最后考虑取均值
function acc_error_world = cal_static_error(sample, USE_EULER, G)
    acc_error_world_combi = cal_acc_world(sample, USE_EULER, G);
    acc_error_world = mean(acc_error_world_combi, 1);
end

