init;
calib_cfg;

base = fullfile('/media/mvs/calib/intr/18012022');

%cams = {'cam_0' 'cam_1' 'cam_2'};
cams = {'cam_3'};

for i=1:length(cams)
    cam = cams{i};
    
    
    % Data: Boards
    dsc_path = fullfile(base, 'cube11x11_new.dsc');
    tp_path = fullfile(base, 'cube11x11_changed.tp');
    board_idxs = [];
    
    % Data: Corners
    train.orpc = glob(fullfile(base , cam, 'train'), {'*.orpc'});
    train.img = cellfun(@(x) [x(1:end-4) 'png'], train.orpc, 'UniformOutput',0);
     
    test.orpc = glob(fullfile(base, cam, 'test'), {'*.orpc'});
    test.img = cellfun(@(x) [x(1:end-4) 'png'], test.orpc, 'UniformOutput',0);
    
    % pose.orpc = glob(fullfile(base, 'corners','pose_0_4'), {'*.orpc'});
    % pose.img = cellfun(@(x) [x(1:end-4) 'png'], pose.orpc, 'UniformOutput',0);
    
    [train.corners, train.boards, train.imgsize, train.img] = import_ODT(...
                                        train.orpc, dsc_path, tp_path,...
                                        'img_paths', train.img,...
                                        'board_idxs', board_idxs);
    
    
    % Calibration
    train_model = calibrate(train.corners, train.boards, train.imgsize, cfg{:},...
                            'img_paths', train.img, 'board_idxs', board_idxs,...
                            'save_results', fullfile(base, cam, cam));


end

