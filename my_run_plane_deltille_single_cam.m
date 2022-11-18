init;
calib_cfg;

base = fullfile('/home/zang/dev/steven_cam_calib');

% Data: Boards
dsc_path = fullfile(base, 'data', 'plane.dsc');
tp_path = fullfile(base, 'data', 'plane.tp');
board_idxs = [];

% Data: Corners
train.orpc = glob(fullfile(base, 'data','normal'), '*.orpc');
train.img = cellfun(@(x) [x(1:end-4) 'bmp'], train.orpc, 'UniformOutput',0);
 

[train.corners, train.boards, train.imgsize, train.img] = import_ODT(...
                                    train.orpc, dsc_path, tp_path,...
                                    'img_paths', train.img,...
                                    'board_idxs', board_idxs);


% Calibration
train_model = calibrate(train.corners, train.boards, train.imgsize, cfg{:},...
                        'img_paths', train.img, 'board_idxs', board_idxs,...
                        'save_results', fullfile(base, 'normal'));

camera_output = struct("camera_matrix", train_model.K, ...
"distortion_coeff", train_model.proj_params);


output_dir = fullfile(base, 'src');

JSONFILE_name = strcat(output_dir, '/', 'normal_','20221012','.json');
fid=fopen(JSONFILE_name,'w');
encodeJSON = jsonencode(camera_output, PrettyPrint=true);
fprintf(fid, encodeJSON);
fclose('all');




