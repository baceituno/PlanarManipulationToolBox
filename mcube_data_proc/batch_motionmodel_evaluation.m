%clear all;

numsamples_perfile = 20;

folder_name = '~/pushing_data';
vels = [10, 20, 50, 100, 500];
surface_types = {'abs', 'plywood'};
shape_ids = {'rect1', 'rect2', 'rect3', 'tri1', 'tri2', 'tri3', 'ellip1', 'ellip2', 'ellip3', 'hex', 'butter'};
ls_types = {'poly4', 'quadratic'};
mu = 0.25;
for ind_vel = 1:1:length(vels)
    for ind_surface = 1:1:length(surface_types)
        for ind_shape = 1:1:length(shape_ids)
            for ind_ls_type = 1:1:length(ls_types)
                
                surface_type = surface_types{ind_surface}
                shape_id = shape_ids{ind_shape}
                vel = vels(ind_vel)
                ls_type = ls_types{ind_ls_type}
                
                [record_all] = EvaluatePositionOffsetMCubeData(folder_name, surface_type, shape_id, vel, ...
                ls_type, mu, num_samples_perfile);
                N = length(record_all);
                diff_trans = zeros(2, N);
                angle_gt = zeros(N,1);
                angle_sim = zeros(N,1);
                tip_trans = zeros(2, N);
                for i = 1:1:N
                    diff_trans(:,i) = record_all{i}.final_pose_gt(1:2) - record_all{i}.final_pose_sim(1:2);
                    angle_gt(i) = mod(record_all{i}.final_pose_gt(3) + 2*pi, 2*pi);
                    angle_sim(i) = mod(record_all{i}.final_pose_sim(3) + 2*pi, 2*pi);
                    tip_trans(:, i) = record_all{i}.final_tip_pt - record_all{i}.init_tip_pt;
                end
                file_save = strcat('~/Pushing/mcube_data_proc/motion_model_eval_logs/', ...
                    surface_type, '_', shape_id, '_', ls_type, '_v', num2str(vel))
                avg_tip_trans = mean(sqrt(sum(tip_trans.^2, 1))) 
                avg_diff_disp = mean(sqrt(sum(diff_trans.^2, 1)))
                angle_diff = compute_angle_diff(angle_sim, angle_gt);
                avg_diff_angle = mean(abs(angle_diff))
                
                save(file_save, 'record_all', 'diff_trans', 'tip_trans', 'angle_diff', 'angle_gt', 'angle_sim', ...
                      'avg_tip_trans', 'avg_diff_disp', 'avg_diff_angle' ,...
                      'surface_type', 'shape_id', 'vel', 'ls_type', 'mu');

            end
        end
    end
end