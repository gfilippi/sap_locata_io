% function [r]=data_processing(p_idx, p_arr_idx, p_recordings, p_array_names, p_results_task_dir)
%     disp(p_idx)
%     pause(3)
% %     this_array = p_array_names{p_idx}{p_arr_idx{p_idx}}
% %    array_dir = [rec_dir filesep array_names{arr_idx}];
%     r=1;
% end

function [r]=data_processing(p_idx, p_task_idx, p_tasks, p_task_dir, p_rec_dir, p_arr_idx, p_rec_idx, p_recordings, p_array_names, p_results_task_dir, is_dev, my_alg_name, opts)

    task_idx = p_task_idx{p_idx};
    tasks = p_tasks{p_idx};


    task_dir = p_task_dir{p_idx};
    rec_dir = p_rec_dir{p_idx};
    arr_idx = p_arr_idx{p_idx};
    rec_idx = p_rec_idx{p_idx};
    recordings = p_recordings{p_idx};
    array_names = p_array_names{p_idx};
    results_task_dir = p_results_task_dir{p_idx};

    this_task = tasks(task_idx);
    
    this_recording = recordings(rec_idx);

    this_array = array_names{arr_idx};

    array_dir = [rec_dir filesep array_names{arr_idx}];


    task_list = { "single-speaker-static_single-array-static",
                  "multiple-speaker-static_single-array-static",
                  "single-speaker-moving_single-array-static",
                  "multiple-speaker-moving_single-array_static",
                  "single-speaker-moving_single-array-moving",
                  "multiple-speaker-moving_single-array-moving"};

    fprintf('[%03d] Processing task %d (%s), recording %d, array %s...\n', p_idx, this_task, task_list{this_task}, this_recording, this_array);

    %% Load data

    % Load data from csv / wav files in database:
    fprintf('[%03d] Loading data for task %d, recording %d... \n', p_idx, this_task, this_recording)
    if is_dev
        [audio_array, audio_source, position_array, position_source, required_time] = load_data(array_dir, is_dev, p_idx);
    else
        [audio_array, position_array, required_time] = load_data(array_dir, is_dev, p_idx);
    end
    fprintf('[%03d] Load Data Complete!\n',p_idx)
    
    % Create directory for this array in results directory:
    this_save_dir = [results_task_dir, filesep, 'recording', num2str(this_recording), filesep, this_array, filesep];

    if ~exist(this_save_dir, 'dir')
        mkdir(this_save_dir)
    end

    %% Load signal

    % Get number of mics and mic array geometry:
    in_localization.numMics = size(position_array.data.(this_array).mic,3);

    % Signal and sampling frequency:
    in_localization.y = audio_array.data.(this_array)';      % signal
    in_localization.fs = audio_array.fs;                     % sampling freq

    %% Users must provide estimates for each time stamp in in.timestamps

    % Time stamps required for evaluation
    in_localization.timestamps = elapsed_time(required_time.time);
    in_localization.timestamps = in_localization.timestamps(find(required_time.valid_flag));
    in_localization.time = required_time.time(:,find(required_time.valid_flag));

    %% Extract ground truth
    %
    % position_array stores all optitrack measurements.
    % Extract valid measurements only (specified by required_time.valid_flag).

    if is_dev
        truth = get_truth(this_array, position_array, position_source, required_time, is_dev);
    else
        truth = get_truth(this_array, position_array, [], required_time, is_dev);
    end

    %% Separate ground truth into positions of arrays (used for localization) and source position (used fo metrics)

    in_localization.array = truth.array;
    in_localization.array_name = this_array;
    in_localization.mic_geom = truth.array.mic;

    fprintf('[%03d] Running localization using %s... \n', p_idx, my_alg_name)
    tic;
    results = feval( my_alg_name, p_idx, in_localization, opts);
    results.telapsed = toc;
    fprintf('[%03d] Localization Complete!\n')

    %% Check results structure is provided in correct format

    check_results(results, in_localization, opts);

    %% Plots & Save results to file

    fprintf('[%03d] Saving results to file... \n',p_idx)

    % Directory to save figures to:
    in_plots = in_localization;
    in_plots.results_dir = [this_save_dir, filesep, my_alg_name];
    if ~exist(in_plots.results_dir, 'dir')
        mkdir(in_plots.results_dir)
    end
    in_plots.plot_title = ['Task ', num2str(tasks(task_idx)), ', recording ', num2str(recordings(rec_idx)), ', array: ', this_array];
    plot_results( in_plots, results, opts, truth, is_dev);

    in_save.struct = results;
    in_save.save_dir = in_plots.results_dir;

    results2csv(in_save, opts, p_idx, p_task_idx, p_rec_idx);

    fprintf('[%03d] Saving Complete!\n',p_idx)


    clear largeArray largeStruct;
    close all;

    r=1;


    fprintf('[%03d] Data Processing Complete!\n',p_idx)


end
