function [parameters_results] = MC_test_IAAWFT_v9_new(signal, t, fs, nSurrogates, anomalies, channel_id)
% MC_TEST_WIAAFT_V10 Statistical validation of EGG signals using WIAAFT surrogates.
%
% This function assesses signal quality by comparing three key spectral metrics
% of the original signal against a distribution of Wavelet ased Iterative Amplitude Adjusted 
% Fourier Transform (IAAWFT) surrogates.
%
% METRICS COMPUTED:
%   1. Spectral Skewness: Measures the asymmetry of the power spectrum.
%   2. Spectral Sparsity (Hoyer): Quantifies energy concentration in the frequency domain.
%   3. Relative Dominant Band Power: Ratio of power within the main EGG peak band (DF +- 0.015 Hz) and total power (0.016-0.16 Hz).
%
% USAGE:
%   [parameters_results] = MC_test_IAAWFT_v9(signal, t, fs, nSurrogates, anomalies)

    fprintf('--- Starting Signal Quality Validation (IAAWFT & Spectral Metrics) ---\n');
    tic;
    
    %% --- Step 1: Initial Preprocessing (10 Hz Decimation) ---
    target_fs_1 = 10;
    factor_1 = floor(fs / target_fs_1);
    
    if factor_1 > 1
        signal_10Hz = decimate(signal, factor_1);
        t_10Hz = downsample(t, factor_1);
        fs_10Hz = fs / factor_1;
        
        if ~isempty(anomalies)
            anomalies = ceil(anomalies / factor_1);
            anomalies = unique(max(1, min(length(signal_10Hz), anomalies)));
        end
    else
        signal_10Hz = signal; t_10Hz = t; fs_10Hz = fs;
    end
    
    %% --- Step 2: Band-pass Filtering (0.016 - 0.16 Hz) ---

        signal_filt = cheb_EGG_filt(signal_10Hz, fs_10Hz);

        % Transient removal (border effect mitigation)
    border = 20;
    if length(signal_filt) > 2*border
        % Trim the signal and the time vector
        signal_filt = signal_filt(border+1:end-border);
        t_10Hz = t_10Hz(border+1:end-border);
        
        % Safe handling and update of the anomalies vector
        if ~isempty(anomalies)
            % Shift all indices to account for the removed left border
            anomalies = anomalies - border;
            
            if mod(length(anomalies), 2) == 0
                % Process anomalies as pairs: [start1, end1, start2, end2, ...]
                valid_anomalies = [];
                for k = 1:2:length(anomalies)-1
                    s_idx = anomalies(k);
                    e_idx = anomalies(k+1);
                    
                    % Discard the anomaly if it falls entirely within the removed borders
                    if e_idx < 1 || s_idx > length(signal_filt)
                        continue; 
                    end
                    
                    % Constrain start and end indices to the new signal boundaries
                    s_adj = max(1, s_idx);
                    e_adj = min(length(signal_filt), e_idx);
                    
                    % Append the adjusted valid pair
                    valid_anomalies = [valid_anomalies, s_adj, e_adj];
                end
                % Overwrite the anomalies vector for downstream use
                anomalies = valid_anomalies;
            else
                % Fallback for single-index arrays
                anomalies = anomalies(anomalies > 0 & anomalies <= length(signal_filt));
            end
        end
    end

    
    %% --- Step 3: Artifact Masking & Reconstruction ---
    mask_10Hz = false(size(signal_filt));
    if ~isempty(anomalies)
        if mod(length(anomalies), 2) == 0
            for k = 1:2:length(anomalies)-1
                s_idx = max(1, anomalies(k));
                e_idx = min(length(signal_filt), anomalies(k+1));
                mask_10Hz(s_idx:e_idx) = true;
            end
        else
            mask_10Hz(anomalies) = true;
        end
    end
    
    % Fill gaps in the signal for surrogate generation
    signal_with_nans = signal_filt;
    signal_with_nans(mask_10Hz) = NaN;
    try
        signal_filled_10Hz = fillgaps(signal_with_nans, 900, 4);
    catch
        signal_filled_10Hz = fillmissing(signal_with_nans, 'linear');
    end
    
    %% --- Step 4: Final Resampling & Normalization ---
    target_fs_2 = 4; 
    factor_2 = floor(fs_10Hz / target_fs_2);
    
    if factor_2 > 1
        signal_final = decimate(signal_filled_10Hz, factor_2);
        fs_final = fs_10Hz / factor_2;
        mask_final = downsample(mask_10Hz, factor_2);
    else
        signal_final = signal_filled_10Hz; mask_final = mask_10Hz; fs_final = fs_10Hz;
    end
    
    signal_final = (signal_final - mean(signal_final)) / std(signal_final);
    
    %% --- Step 5: Original Signal Metrics ---
    metrics_orig = compute_egg_metrics(signal_final, fs_final, mask_final);
    
    %% --- Step 6: Surrogate Generation (WIAAFT) ---
    if ~exist('iaaws_dualtree_v2', 'file')
        error('iaaws_dualtree_v2.m not found in path.');
    end
    %[surrogates_t, ~] = iaaws_dualtree_R_replica(signal_final, nSurrogates, 1000);
    tic
    [surrogates_t, ~] = iaaws_dualtree_v2(signal_final, nSurrogates, 1000, channel_id);
    toc
    surrogates = surrogates_t'; 
    
    %% --- Step 7: Surrogate Metrics Computation ---
    metric_names = fieldnames(metrics_orig);
    for k = 1:numel(metric_names)
        surr_dist.(metric_names{k}) = zeros(1, nSurrogates);
    end
    
    for i = 1:nSurrogates
        if mod(i, 50) == 0 || i == 1
            fprintf('Processing IAAWFT Surrogate %d / %d...\n', i, nSurrogates);
        end
        m_curr = compute_egg_metrics(surrogates(i, :), fs_final, mask_final);
        for k = 1:numel(metric_names)
            fn = metric_names{k};
            surr_dist.(fn)(i) = m_curr.(fn);
        end
    end
    
    %% --- Step 8: Statistical Analysis & Results ---
    parameters_results = struct();
    for k = 1:numel(metric_names)
        fn = metric_names{k};
        obs = metrics_orig.(fn);
        dist = surr_dist.(fn);
        
        parameters_results.(fn).original_value = obs;
        parameters_results.(fn).p_value_right = (sum(dist >= obs) + 1) / (nSurrogates + 1);
        parameters_results.(fn).p_value_left  = (sum(dist <= obs) + 1) / (nSurrogates + 1);
        parameters_results.(fn).conf_interval = prctile(dist, [2.5 97.5]);
    end
    
    plot_quality_metrics(parameters_results, surr_dist);
    fprintf('Analysis completed in %.2f seconds.\n', toc);
end

%% --- Helper: Spectral Metrics Computation ---
function m = compute_egg_metrics(x, fs, bad_mask)
    % Time-Frequency windowing
    win_sec = 100; 
    win_len = min(round(win_sec * fs), length(x));
    if mod(win_len, 2) == 0, win_len = win_len + 1; end
    nfft = 4096;
    overlap = round(win_len * 0.80);
    
    [S, f, t_spec] = spectrogram(x, kaiser(win_len, 7), overlap, nfft, fs);
    
    % Spectral Masking
    valid_cols = true(size(t_spec));
    if nargin > 2 && ~isempty(bad_mask) && any(bad_mask)
        t_orig = (0:length(x)-1)/fs;
        mask_spec = interp1(t_orig, double(bad_mask), t_spec, 'nearest');
        valid_cols = mask_spec == 0; 
    end
    
    % ROI Extraction (EGG range)
    idx_roi = f >= 0.016 & f <= 0.16;
    f_roi = f(idx_roi);             
    P_roi = abs(S(idx_roi, valid_cols)).^2; 
    P_mean = mean(P_roi, 2); 
    
    if isempty(P_mean)
        m = struct('spec_skewness',0, 'spec_sparsity',0, 'dom_pow_rel',0);
        return;
    end
    
    % 1. Spectral Skewness
    m.spec_skewness = spectralSkewness(P_roi, f_roi); % Audio Toolbox
    m.spec_skewness = mean(m.spec_skewness);
    
    % 2. Spectral Sparsity (Hoyer Measure)
    N = length(P_mean);
    L1 = sum(P_mean); L2 = sqrt(sum(P_mean.^2));
    m.spec_sparsity = (sqrt(N) - (L1/L2)) / (sqrt(N) - 1);
    
    % 3. Dominant Power Ratio
    [~, idx_peak] = max(P_mean);
    peak_f = f_roi(idx_peak);
    bw = 0.015;
    idx_dom = f_roi >= (peak_f - bw) & f_roi <= (peak_f + bw);
    m.dom_pow_rel = sum(P_mean(idx_dom)) / (sum(P_mean) + eps);
end

%% --- Helper: Plotting ---
%% --- Helper: Plotting ---
function plot_quality_metrics(res, surr_data)
    fields = fieldnames(res);
    n_metrics = numel(fields);
    
    % Create figure with a white background
    fig = figure('Color', 'w', 'Name', 'IAAWFT Validation Results', 'Position', [100 100 1200 450]);
    
    % Define the golden-yellow color
    gold_color = [0.8 0.6 0];
    
    % Initialize modern tiled layout (robust against resizing and legend placement)
    tlo = tiledlayout(1, n_metrics, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    for i = 1:n_metrics
        fn = fields{i};
        dist = surr_data.(fn);
        obs = res.(fn).original_value;
        pval = res.(fn).p_value_right; % Metrics where Higher is Better
        
        % Advance to the next tile instead of using subplot
        ax(i) = nexttile(tlo);
        
        % Histogram of surrogate distribution
        h_surr = histogram(dist, 25, 'FaceColor', gold_color, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
        hold on;
        
        % Vertical line for original signal
        h_obs = xline(obs, 'r', 'LineWidth', 2.5);
        
        % Title and Labels formatting
        clean_title = upper(strrep(fn, '_', ' '));
        title_color = 'k'; 
        if pval < 0.05
            title_color = [0 0.5 0]; % Dark green for significance
            status_str = '*';
        else
            status_str = 'ns';
        end
        
        title({clean_title, sprintf('p = %.3f %s', pval, status_str)}, ...
              'Color', title_color, 'FontWeight', 'bold', 'FontSize', 11);
        
        xlabel('Metric Value');
        if i == 1
            ylabel('Count'); 
        end 
        
        grid on; 
        set(gca, 'GridAlpha', 0.2);
        
        % Dynamic X-axis margins to ensure visibility of the empirical observation
        all_vals = [dist(:); obs];
        range_vals = max(all_vals) - min(all_vals);
        xlim([min(all_vals) - 0.1*range_vals, max(all_vals) + 0.1*range_vals]);
    end
    
    % --- Fixed Global Legend via TiledLayout ---
    % Create a single legend attached to the layout, not to a specific axis
    lgd = legend(ax(n_metrics), [h_surr, h_obs], {'WIAAFT Surrogates', 'Original Signal'}, ...
        'Orientation', 'horizontal', ...
        'FontSize', 10);
    
    % Assign the legend to the shared south tile of the entire layout
    lgd.Layout.Tile = 'south'; 
end