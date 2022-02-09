function pose_eval(cams)
init;
calib_cfg;


base = fullfile('/media/mvs/calib/intr/21012022');

% Data: Boards
dsc_path = fullfile(base, 'cube11x11_new.dsc');
tp_path = fullfile(base, 'cube11x11_changed.tp');
board_idxs = [];

% cams = {'cam_0' 'cam_1' 'cam_2'};

for i=1:length(cams)
    cam = cams{i};

    nowstr=num2str(yyyymmdd(datetime(floor(now),'ConvertFrom','datenum')));
    train_model = load(fullfile('/media/mvs/calib/intr/18012022', cam, strcat(cam,'_calib_', '20220120', '.mat')));
    
    %train_model = load(fullfile(base, cam, strcat(cam,'_calib_', '20220118', '.mat')));
    
    % Data: Corners
    pose.orpc = glob(fullfile(base, cam, 'pose'), {'*.orpc'});
    pose.img = cellfun(@(x) [x(1:end-4) 'png'], pose.orpc, 'UniformOutput',0);
    
    
    [pose.corners, pose.boards, pose.imgsize, pose.img] = import_ODT(...
                                        pose.orpc, dsc_path, tp_path,...
                                        'img_paths', pose.img,...
                                        'board_idxs', board_idxs);
    
    
    % Evaluation (camera pose estimation)
    pose_model = get_poses(train_model.model, pose.corners, pose.boards,...
                           pose.imgsize, cfg{:},...
                           'img_paths', pose.img, 'board_idxs', board_idxs,...
                           'save_results', fullfile(base, cam, 'pose'));
    
    
    rt = mean(pose_model.Rt, 3);
    
    camera_output = struct("camera_matrix", pose_model.K, ...
        "distortion_coeff", pose_model.proj_params, ...
        "t_param", rt(:,4), ...
        "r_param", rotm2eul(rt(:,1:3)), ...
        "rotation_matrix", rt(:,1:3), ...
        "projection_matrix", pose_model.K * rt);
    
    
    output_dir = fullfile(base, cam);
    
    JSONFILE_name = strcat(output_dir, '/camera.json');
    fid=fopen(JSONFILE_name,'w');
    encodeJSON = jsonencode(camera_output, PrettyPrint=true);
    fprintf(fid, encodeJSON);
    fclose('all');

end
    fprintf("\n\n---------------------------- \n")
    fprintf("calibrated %d cameras", length(cams))
    fprintf("\n---------------------------- \n\n")
end