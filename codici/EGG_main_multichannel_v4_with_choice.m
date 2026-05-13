%% ----------------------------------------------------------------------%%
%                   EGG Signal Processing Pipeline                        %
%%-----------------------------------------------------------------------%%

%% 0. PIPELINE SELECTION
% Create a custom modal dialog for better layout and font size control
fig = uifigure('Name', 'Pipeline Selection', ...
               'Position', [100, 100, 600, 320], ...
               'WindowStyle', 'modal');
movegui(fig, 'center');

% Initialize UserData (the script will pause until this changes)
fig.UserData = 'WAITING';

% Define the message with cleaner formatting and manual indentation
dialog_msg = {
    'Select the artifact processing mode for the GSPT:',
    '',
    ' [1] Conditional (RP Control)',
    '      Runs a Monte Carlo test on instantaneous energy. Artifact localization',
    '      only triggers if Tsallis entropy is lower than surrogates.',
    '',
    ' [2] Forced (Always Localize)',
    '      Skips the Monte Carlo check and ALWAYS runs the artifact',
    '      localization and removal algorithm.'
};

% Add the text label
uilabel(fig, 'Text', dialog_msg, ...
             'Position', [30, 80, 540, 210], ...
             'FontSize', 14, ...
             'FontName', 'Helvetica', ...
             'VerticalAlignment', 'top');

% Add the buttons
uibutton(fig, 'Position', [40, 25, 240, 40], ...
              'Text', 'Conditional (RP Control)', ...
              'FontSize', 13, ...
              'FontWeight', 'bold', ...
              'ButtonPushedFcn', @(src, event) set(fig, 'UserData', 'Conditional (RP Control)'));

uibutton(fig, 'Position', [320, 25, 240, 40], ...
              'Text', 'Forced (Always Localize)', ...
              'FontSize', 13, ...
              'FontWeight', 'bold', ...
              'ButtonPushedFcn', @(src, event) set(fig, 'UserData', 'Forced (Always Localize)'));

% Pause the script until a button is clicked OR the window is closed
waitfor(fig, 'UserData');

% Retrieve the user's choice
if isvalid(fig)
    % User clicked one of the buttons
    choice = fig.UserData;
    delete(fig); % Close the window
else
    % User closed the window using the 'X' button
    choice = ''; 
end

% Handle the case where the user cancels the selection
if isempty(choice) || strcmp(choice, 'WAITING')
    error('Selection canceled. The script has been aborted.');
end

% Assign the appropriate function handle based on the user's choice
if strcmp(choice, 'Conditional (RP Control)')
    pipeline_func = @pipeline_single_channel_v11;
    disp('Selected: pipeline_single_channel_v11 (Conditional RP Control)');
else
    pipeline_func = @pipeline_single_channel_v11_no_RP_control;
    disp('Selected: pipeline_single_channel_v11_no_RP_control (Forced Localization)');
end

%% 1. SETUP
% Output folder
% ⚠️ The pipeline will generate three Excel files with the results. 
% Please change the folder path as desired.
output_folder = 'C:\Users\aless\Documents\MATLAB\Prova_stampa_pipeline';
% ⚠️ Update the path below to match your local FieldTrip installation.
addpath("C:\Users\aless\Documents\fieldtrip-20251023\fieldtrip-20251023")
ft_defaults;
% ⚠️ Update the path below to match your local data path
cfg = [];
%cfg.dataset='C:\Users\aless\Documents\MATLAB\taVNS\Sub_07\V2\Sub_07_baseline_Pre_V2.eeg';
%cfg.dataset='C:\Users\aless\Documents\MATLAB\taVNS\Sub_40\V1\Sub_40_carte_1_Act_V1.eeg';
%cfg.dataset='C:\Users\aless\Documents\noise_EGG_prove\Chiara_clean_1.eeg';
%clean
%cfg.dataset='C:\Users\aless\Documents\noise_EGG_prove\Chiara_Mov_2.eeg';
% super clean
%cfg.dataset='C:\Users\aless\Documents\noise_EGG_prove\Chiara_Mov_3.eeg';
cfg.dataset='C:\Users\aless\Downloads\Clean_example.eeg';
%cfg.dataset='C:\Users\aless\Documents\noise_EGG_prove\Chiara_Mov_4.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\MATLAB\dati_chiara_andrea\p08_Raw Data.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\Example_Bad_Quality.eeg';
%cfg.dataset = 'C:\Users\aless\Downloads\'
%cfg.dataset = 'C:\Users\aless\Documents\file_email_ingegneri\Maria_clean_2.eeg';
%cfg.dataset='C:\Users\aless\Documents\file_email_ingegneri\Sub_07\V2\Sub_07_baseline_Pre_V2.eeg';
%cfg.dataset='C:\Users\aless\Documents\MATLAB\Sub_08_baseline_Pre_V1.eeg';
%cfg.dataset='C:\Users\aless\Documents\MATLAB\Sub_17_baseline_Sha_V1.eeg';
%cfg.dataset='C:\Users\aless\Documents\MATLAB\chiara_baseline_02_05_24.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\Gabo_Mov_2.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\Maria_Mov_3.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\Chiara_Mov_5.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\Gianluca_prove_rumore.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\P_04_rumore_01.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\P_04_rumore_2.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\P_05_prove_rumore.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\P_04_rumore_3.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\noise_EGG_prove\P_06_prove_rumore.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\MATLAB\prova_rita_1_10min.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\MATLAB\prova_franz_1_baseline.eeg';
%cfg.dataset='C:\Users\aless\Downloads\Example_Clean.eeg';
%cfg.dataset ='C:\Users\aless\Documents\MATLAB\noise_EGG_prove\Chiara_Mov_1.eeg';
%cfg.dataset ='C:\Users\aless\Documents\noise_EGG_prove\Gabo_Mov_3.eeg';
%cfg.dataset = 'C:\Users\aless\Documents\MATLAB\noise_EGG_prove\P_06_prove_rumore.eeg';
% ⚠️ Channel selection can be done in several ways.
% By default, all available channels are selected.
% Choose the option that best suits your data.
%----------------------------------------------
% manual channel selection
cfg.channel = {'egg1', 'egg2', 'egg3', 'egg4'}; 
%-----------------------------------------------
%select all channels
%hdr = ft_read_header(cfg.dataset);
%all_channels = hdr.label;
%cfg.channel = all_channels; 
%----------------------------------------------
% Select all channels whose names contain a common identifier (e.g., 'egg')
%egg_channels = all_channels(contains(lower(all_channels), 'egg'));
%cfg.channel = egg_channels; 
%----------------------------------------------
% Extract channel names for subsequent use during data export
channel_names = cfg.channel;
% load the datas
%EGG_raw = ft_preprocessing(cfg);
nCh = numel(cfg.channel); % number of channels
dataset_name = cfg.dataset;
% Numero di canali
%fprintf('%d EGG channels loaded: %s\n', nCh, strjoin(cfg.channel, ', '));


script_p = 'C:\Users\aless\Downloads';
file_name   = 'EGG_raw_example2_reb.mat';
load(strcat([script_p filesep file_name]));
nCh=numel(EGG_raw.label);
%cfg.channel = {'EGG1', 'EGG2', 'EGG3', 'EGG4'}; 
channel_names=EGG_raw.label;
%% 2. REMOVE HIGH-FREQUENCY SPIKES
disp('Removing high-frequency spikes...')
for ch = 1:nCh
    [index, cleaned_signal] = find_nyquist_spike_v4(EGG_raw.trial{1}(ch,:), EGG_raw.time{1}, 1000, 100);
    EGG_raw.trial{1}(ch,:) = cleaned_signal;
    if ~isempty(index)
        sgtitle(['Channel ' num2str(ch)]);
    end
end
%% 3. RESAMPLE TO 10 Hz
disp('Resampling...')
cfg = [];
cfg.detrend = 'no';
cfg.demean  = 'yes';
cfg.resamplefs = 10;
EGG_downsampled = ft_resampledata(cfg, EGG_raw);
fs = cfg.resamplefs;
%% 4. REMOVE EDGE EFFECTS
disp('Removing filter edge effects...')
t = EGG_downsampled.time{1}(4:end-4);
x = EGG_downsampled.trial{1}(:, 4:end-4); % matrix [nCh x nTime]
%% 5. RUN PIPELINE ON EACH CHANNEL
disp('Running pipeline on individual channels...')
freq_range = 0.016:0.0001:0.16;
% Preallocation
norm_pow = cell(1, nCh);
parameters = cell(1, nCh);
efreq = cell(1, nCh);
eamp = cell(1, nCh);
ephi = cell(1, nCh);
r = cell(1, nCh);
tp = cell(1, nCh);
ief = cell(1, nCh);
amp_curve = cell(1, nCh);
ph_curve = cell(1, nCh);
if_curve = cell(1, nCh);
fill_s = cell(1, nCh);
ridge_curve = cell(1, nCh);
parameters_results = cell(1, nCh);
for ch = 1:nCh
    fprintf('Processing channel %d...\n', ch);
    % Use the selected function handle assigned in step 0
    [~, norm_pow{ch}, parameters{ch}, efreq{ch}, eamp{ch}, ephi{ch}, ...
     r{ch}, tp{ch}, ief{ch}, amp_curve{ch}, ph_curve{ch}, if_curve{ch}, ...
     fill_s{ch}, ridge_curve{ch}, parameters_results{ch}] = ...
     pipeline_func(x(ch,:), t, fs, freq_range, ch); 
end
%% 6. PLOT POWER SPECTRA
figure; hold on;
colors = lines(nCh); % Automatically generates a distinct color map
spectra = norm_pow;
labels = arrayfun(@(ch) sprintf('Channel %d', ch), 1:nCh, 'UniformOutput', false);

% --- NEW: Estrazione preliminare per calcolo CV ---
dom_freqs = zeros(1, nCh);
for ch = 1:nCh
    [~, peak_idx] = max(spectra{ch});
    dom_freqs(ch) = freq_range(peak_idx);
end
initial_cv = std(dom_freqs) / abs(mean(dom_freqs));
% -------------------------------------------------

for ch = 1:nCh
    plot(freq_range, spectra{ch}, 'Color', colors(ch,:), 'LineWidth', 2);
end
drawnow;
yl = ylim; y_bottom = yl(1); y_top = yl(2);
for ch = 1:nCh
    [peak_val, peak_idx] = max(spectra{ch});
    dom_freq = freq_range(peak_idx);
    plot(dom_freq, peak_val, 'o', 'Color', colors(ch,:), ...
        'MarkerFaceColor', colors(ch,:), 'MarkerSize', 6, 'HandleVisibility', 'off');
    y_offset = 0.02 * y_top;
    x_shift = 0.001 * (-1)^ch;
    text(dom_freq + x_shift, peak_val + y_offset, sprintf('%.4f Hz', dom_freq), ...
        'Color', colors(ch,:), 'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
end

% Highlights the normogastric band
[~, inf_norm] = min(abs(freq_range - 0.033));
[~, sup_norm] = min(abs(freq_range - 0.067));
fill([freq_range(inf_norm) freq_range(sup_norm) freq_range(sup_norm) freq_range(inf_norm)], ...
     [y_bottom y_bottom y_top y_top], [0.7 0.7 0.7], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
xline(freq_range(inf_norm), '--k', 'LineWidth', 1.5);
xline(freq_range(sup_norm), '--k', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('Power', 'FontSize', 14);
title('Power Spectrum Density Across Channels', 'FontSize', 16);

% --- DF CV info  ---
subtitle(sprintf('Initial Dominant Frequency CV: %.4f', initial_cv), 'FontSize', 13);
% ------------------------

legend(labels, 'Location', 'northeast', 'FontSize', 12);
grid on; set(gca, 'FontSize', 12);
%% 7. RIDGE CURVE CORRELATIONS
disp('Computing ridge curve correlations...');
ridge_mat = cell2mat(cellfun(@(x) x(:), ridge_curve, 'UniformOutput', false));
ridge_cor = corr(ridge_mat, 'Rows','complete');
figure;
h = heatmap(ridge_cor);
h.XDisplayLabels = labels;
h.YDisplayLabels = labels;
title('Pairwise correlations between TFR ridge curves');
%% 9. TOTAL CORRELATION CALCULATIONS
if nCh>1
% Determine which timepoints are reliable across all channels
len_sig = length(fill_s{1});   % reference signal length
nCh = numel(r);                % number of channels
% Build reliability matrix r_mat robustly
r_mat = false(nCh, len_sig);
for ch = 1:nCh
    ri = r{ch}(:)';  % ensure row
    if length(ri) >= len_sig
        r_mat(ch, :) = ri(1:len_sig);
    else
        r_mat(ch, 1:length(ri)) = ri;
        % pad remainder with false
    end
end
% A timepoint is unreliable if any channel flags it
r_tot = any(r_mat, 1);
% Align r_tot length with the processed signals
if length(r_tot) > len_sig
    r_tot = r_tot(1:len_sig);
elseif length(r_tot) < len_sig
    r_tot = [r_tot, false(1, len_sig - length(r_tot))];
end
% Run only if valid data points remain
if any(~r_tot)
    disp('Computing total correlations...');
    % Safe decimation with mask and NaN handling
    decim = @(x) conditional_decimate(x, r_tot);
    % Helper to build matrix of decimated signals across channels
    build_matrix = @(C) cell2mat(cellfun(@(v) decim(v(:)), C, 'UniformOutput', false));
    % --- Total correlations across features ---
    try TC_ch    = total_corr_general(build_matrix(fill_s),    2); catch, TC_ch = NaN; end
    try TC_en    = total_corr_general(build_matrix(tp),        2); catch, TC_en = NaN; end
    try TC_ief   = total_corr_general(build_matrix(ief),       2); catch, TC_ief = NaN; end
    try TC_eamp  = total_corr_general(build_matrix(amp_curve), 2); catch, TC_eamp = NaN; end
    try TC_efreq = total_corr_general(build_matrix(if_curve),  2); catch, TC_efreq = NaN; end
    try TC_ephi  = total_corr_general(build_matrix(ph_curve),  2); catch, TC_ephi = NaN; end
    try TC_ridge = total_corr_general(build_matrix(ridge_curve), 2); catch, TC_ridge = NaN; end
    % --- Phase space reconstruction parameters per channel ---
    eLag = zeros(1, nCh);
    eDim = zeros(1, nCh);
    for ch = 1:nCh
        try
            sig = fill_s{ch}(:);
            sig = sig(1:len_sig);
            sig_valid = sig(~r_tot);
            if numel(sig_valid) >= 20
                [~, eLag(ch), eDim(ch)] = phaseSpaceReconstruction(sig_valid, ...
                    'MaxDim', 9, 'MaxLag', 100);
            else
                eLag(ch) = 1; eDim(ch) = 2;
            end
        catch
            eLag(ch) = 1; eDim(ch) = 2;
        end
    end
    % --- Multivariate data matrix ---  
    data_matrix = cell2mat(cellfun(@(v) v(:), fill_s, 'UniformOutput', false));
    min_len = min(cellfun(@length, fill_s));
    data_matrix = data_matrix(1:min_len, :);
    % --- Multivariate entropy measures ---
    try [MPerm, ~] = MvPermEn(data_matrix, 'm', eDim, 'tau', eLag);
    catch, MPerm = NaN; end
    try [MDisp, ~] = MvDispEn(data_matrix, 'm', eDim, 'tau', eLag);
    catch, MDisp = NaN; end
    % --- Collect all total correlation and multivariate entropy parameters ---
    tot_cor_parf = [TC_ch, TC_en, TC_ief, TC_eamp, TC_efreq, TC_ephi, TC_ridge, MPerm, MDisp];
  %% 10. PLOT FINAL RESULTS (SPIDER PLOT)
    all_reliable = false(1, nCh);
    for ch = 1:nCh
        try
            [is_globally_significant, ~] = calculate_simes_test([parameters_results{ch}.spec_skewness.p_value_right, ...
                parameters_results{ch}.spec_sparsity.p_value_right], 0.05);
            all_reliable(ch) = is_globally_significant;
        catch
            all_reliable(ch) = false;
        end
    end
    
    % Good-quality criterion
    good_quality = all(all_reliable) && mean(r_tot) < 0.6;
    
    % --- Color Settings (v11 Style) ---
    if good_quality
        theme_color = [0 0.5 0];      % Dark Green
        data_color  = [0 0.6 0];      % Data Green
        subtitle_str = 'Signal Quality: Reliable (Green)';
    else
        theme_color = [0.7 0 0];      % Dark Red
        data_color  = [0.8 0 0];      % Data Red
        subtitle_str = 'Signal Quality: Unreliable/Noisy (Red)';
    end
    precision_linear = repmat(2,1,7);
    precision_entropy = repmat(3,1,2);
    
    % Plot labels (slightly shortened for aesthetics)
    labels_spider = {'Raw filtered data TC', 'Time energy TC', 'Time spectral entropy TC', ...
                     'IA TC', 'IF TC', 'IP TC', 'TFR ridge TC', ...
                     'Mv Permutation entropy', 'Mv Dispersion entropy'};
    
    num_params_tc = length(labels_spider);
    dummy_labels = repmat({''}, 1, num_params_tc);
    edge_col = repmat('w', 1, num_params_tc); 
    lbl_offset = 0.25; 
    
    f = figure('Color', 'w');
    f.Position(3:4) = [950, 750]; 
    
    % Axes plot scale
    my_scaling = {'linear', 'linear', 'log', 'log', 'log', 'log', 'log', 'linear', 'linear'};
    % Minimum values
    min_limits = [0, 0, 1e-4, 1e-4, 1e-4, 1e-4, 1e-4, 0, 0];
    % Maximum values
    max_limits = [50, 50, 5, 50, 5, 50, 5, 20, 10];
    
    % Main Plot
    spider_plot(tot_cor_parf, ...
        'AxesLabels', dummy_labels, ...
        'AxesLimits', [min_limits; max_limits], ...
        'AxesScaling', my_scaling, ...
        'AxesPrecision', [precision_linear, precision_entropy], ...
        'AxesLabelsEdge', edge_col, ...
        'AxesLabelsOffset', lbl_offset, ... 
        'AxesFontSize', 8, ...
        'AxesFontColor', [0.2 0.2 0.2], ... 
        'AxesDisplay', 'none', ...          
        'AxesInterval', 6, ...      
        'FillOption', {'on'}, ...
        'FillTransparency', 0.15, ...       
        'Color', data_color, ...            
        'AxesColor', [0.7 0.7 0.7], ...
        'LineStyle', {'-'}, ...
        'LineWidth', 2, ...                 
        'Marker', {'o'}, ...
        'MarkerSize', 5);
    title(sprintf('Total correlation across %d channels', nCh), 'FontSize', 14);
    full_subtitle = sprintf('%s | Fraction of excluded signal: %.2f', subtitle_str, mean(r_tot));
    subtitle(full_subtitle, 'Color', theme_color, 'FontWeight', 'bold');
    
    % Manual Drawing of Labels and Guides
    hold on;
    theta = linspace(pi/2, pi/2 - 2*pi, num_params_tc + 1);
    theta(end) = []; 
    
    r_start = 1.02; 
    r_end = 1 + lbl_offset - 0.02; 
    
    for i = 1:num_params_tc
        % 1. Draw Guide Line
        [x_guide, y_guide] = pol2cart(theta(i), [r_start, r_end]);
        plot(x_guide, y_guide, ':', 'Color', theme_color, 'LineWidth', 0.8);
        
        % 2. Draw Text (Manually)
        [x_txt, y_txt] = pol2cart(theta(i), r_end + 0.05);
        
        if x_txt > 0.1
            h_align = 'left';  
        elseif x_txt < -0.1
            h_align = 'right'; 
        else
            h_align = 'center'; 
        end
        
        text(x_txt, y_txt, labels_spider{i}, ...
            'Color', theme_color, ...       
            'FontName', 'Helvetica', ...
            'FontSize', 10, ...              
            'FontWeight', 'bold', ...
            'HorizontalAlignment', h_align, ...
            'VerticalAlignment', 'middle', ...
            'Interpreter', 'none');
    end
    hold off;
    
    % Display computed values in the Command Window
    disp('Total correlations (TCs) and multivariate entropy values:')
    total_correlations = struct( ...
        'Raw_filtered_data_TC', TC_ch, ...
        'Time_energy_TC', TC_en, ...
        'Time_spectral_entropy_TC', TC_ief, ...
        'Instantaneous_amplitude_TC', TC_eamp, ...
        'Instantaneous_frequency_TC', TC_efreq, ...
        'Instantaneous_phase_TC', TC_ephi, ...
        'TFR_ridge_frequencies_TC', TC_ridge, ...
        'Multivariate_permutation_entropy', MPerm, ...
        'Multivariate_dispersion_entropy', MDisp);
    disp(total_correlations);
else
    disp('Total correlation not computed: one or more channels lack reliable TFR representation.');
end
else
    disp('Total correlation not computed: only one channel in the data');
end
toc
% ********************************************************************
%% 11. EXPORT PARAMETERS TO EXCEL
% ********************************************************************
disp('=== EXPORTING PARAMETERS_RESULTS TO EXCEL ===');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
excel_filename = fullfile(output_folder, 'Single_channel_parameters.xlsx');

% Extract field names from the first struct in parameters
first_struct = parameters{1};
if isstruct(first_struct)
    field_names = fieldnames(first_struct);
else
    error('parameters{1} is not a struct. Check your pipeline.');
end
n_fields = numel(field_names);
n_rows   = nCh;

% --- NEW: Esecuzione Selezione Greedy ai 3 Threshold ---
% Assicuriamo che dom_freqs esista, altrimenti lo ricalcoliamo
if ~exist('dom_freqs', 'var')
    dom_freqs = zeros(1, nCh);
    for ch = 1:nCh
        [~, peak_idx] = max(norm_pow{ch});
        dom_freqs(ch) = freq_range(peak_idx);
    end
end

% I threshold CPM convertiti in Hz
keep_low_05    = evaluate_channels_cv(dom_freqs, 0.5 / 60);
keep_medium_10 = evaluate_channels_cv(dom_freqs, 1.0 / 60);
keep_high_20   = evaluate_channels_cv(dom_freqs, 2.0 / 60);
% -------------------------------------------------------

% Aggiungiamo 2 colonne pre-esistenti + 3 per la nuova classificazione
table_cell = cell(n_rows+1, n_fields+5);

% Header
table_cell{1,1} = 'Channel';
for f = 1:n_fields
    table_cell{1,1+f} = field_names{f};
end
table_cell{1,n_fields+2} = 'Fraction_of_contaminated_signal'; 
table_cell{1,n_fields+3} = 'is_noise'; 
table_cell{1,n_fields+4} = 'CV_Selection_Low_0.5CPM'; 
table_cell{1,n_fields+5} = 'CV_Selection_Medium_1CPM'; 
table_cell{1,n_fields+6} = 'CV_Selection_High_2CPM'; 

% Fill each row
for ch = 1:nCh
    
    % Channel name
    table_cell{ch+1,1} = channel_names{ch};
    
    % Fill parameter values
    for f = 1:n_fields
        val = parameters{ch}.(field_names{f});
        if isnumeric(val)
            if isscalar(val)
                table_cell{ch+1,1+f} = val;
            else
                table_cell{ch+1,1+f} = mat2str(val);
            end
        elseif ischar(val) || isstring(val)
            table_cell{ch+1,1+f} = char(val);
        elseif isstruct(val)
            try
                table_cell{ch+1,1+f} = jsonencode(val);
            catch
                table_cell{ch+1,1+f} = '[struct]';
            end
        elseif iscell(val)
            try
                table_cell{ch+1,1+f} = jsonencode(val);
            catch
                table_cell{ch+1,1+f} = '[cell]';
            end
        else
            table_cell{ch+1,1+f} = '[unknown type]';
        end
    end
    
    % ============================
    % Calcolo frazione di segnale contaminato (sum(r) / length(r))
    % ============================
    if ~isempty(r{ch})
        frac_contaminate = sum(r{ch}) / length(r{ch});
    else
        frac_contaminate = NaN;
    end
    table_cell{ch+1, n_fields+2} = frac_contaminate;
    
    % ============================
    % noise classification
    % ============================
    if isfield(parameters_results{ch}, 'spec_skewness') && isfield(parameters_results{ch}, 'spec_sparsity')
        [is_globally_significant, ~] = calculate_simes_test([parameters_results{ch}.spec_skewness.p_value_right, ...
            parameters_results{ch}.spec_sparsity.p_value_right], 0.05);
        if is_globally_significant
            table_cell{ch+1,n_fields+3} = 'no'; % not noise
        else
            table_cell{ch+1,n_fields+3} = 'yes'; % noisy
        end
    else
        table_cell{ch+1,n_fields+3} = 'unknown';
    end
    
    % ============================
    % CV Selection Results
    % ============================
    if keep_low_05(ch), table_cell{ch+1,n_fields+4} = 'good'; else, table_cell{ch+1,n_fields+4} = 'bad'; end
    if keep_medium_10(ch), table_cell{ch+1,n_fields+5} = 'good'; else, table_cell{ch+1,n_fields+5} = 'bad'; end
    if keep_high_20(ch), table_cell{ch+1,n_fields+6} = 'good'; else, table_cell{ch+1,n_fields+6} = 'bad'; end
    % ============================
end

% Write Excel file
try
    writecell(table_cell, excel_filename);
    disp(['✔ parameters exported to: ', excel_filename])
catch ME
    warning(['❌ Error writing Excel file: ', ME.message]);
end

% ********************************************************************
%% 12. EXPORT TOTAL CORRELATIONS AND MULTIVARIATE ENTROPIES 
% ********************************************************************
disp('=== EXPORTING TOTAL CORRELATIONS AND MULTIVARIATE ENTROPIES ===');
excel_filename2 = fullfile(output_folder, 'Total_correlations_and_multivariate_entropies.xlsx');

labels_TC = { ...
    'Raw_filtered_data_total_corr', ...
    'Time_energy_total_corr', ...
    'Time_spectral_entropy_total_corr', ...
    'IA_total_corr', ...
    'IF_total_corr', ...
    'IP_total_corr', ...
    'TFR_ridge_total_corr', ...
    'Multivariate_permutation_entropy', ...
    'Multivariate_dispersion_entropy' ...
};
n_measures = length(labels_TC);

% Create cell array: 1st row = headers, 2nd row = values
% Aggiungiamo 2 colonne extra per frazione contaminata globale e is_noise
table_TC = cell(2, n_measures + 2);

% Fill headers and values
for k = 1:n_measures
    table_TC{1, k} = labels_TC{k};
    table_TC{2, k} = tot_cor_parf(k);
end

% Fraction of signal considered for 
table_TC{1, end-1} = 'Fraction_of_excluded_signal';
if exist('r_tot', 'var') && ~isempty(r_tot)
    table_TC{2, end-1} = mean(r_tot); 
else
    table_TC{2, end-1} = NaN;
end

% Add is_noise as last column
table_TC{1, end} = 'is_noise';
if good_quality
    table_TC{2, end} = 'no';
else
    table_TC{2, end} = 'yes';
end

try
    writecell(table_TC, excel_filename2);
    disp(['✔ Total correlations + quality exported to: ', excel_filename2])
catch ME
    warning(['❌ Error writing Excel file: ', ME.message]);
end
% ********************************************************************
%% 13. EXPORT INSTANTANEOUS AMPLITUDE, PHASE, AND FREQUENCY CURVES 
% ********************************************************************
disp('=== EXPORTING INSTANTANEOUS CURVES ===');
excel_filename3 = fullfile(output_folder, 'Instantaneous_curves.xlsx');
time_vec = t(:);
nT = length(time_vec);
total_columns = 1 + 3*nCh;
table_curves = cell(nT+1, total_columns);
table_curves{1,1} = 'Time';
col_index = 2;
% Amplitude headers
for ch = 1:nCh
    table_curves{1, col_index} = sprintf('Amplitude_ch%d', ch);
    col_index = col_index + 1;
end
% Phase headers
for ch = 1:nCh
    table_curves{1, col_index} = sprintf('Phase_ch%d', ch);
    col_index = col_index + 1;
end
% Frequency headers
for ch = 1:nCh
    table_curves{1, col_index} = sprintf('Frequency_ch%d', ch);
    col_index = col_index + 1;
end
table_curves(2:end,1) = num2cell(time_vec);
col_index = 2;
% Insert amplitude data
for ch = 1:nCh
    amp = amp_curve{ch}(:);
    if length(amp) < nT
        amp = [amp; NaN(nT - length(amp),1)];
    end
    table_curves(2:end, col_index) = num2cell(amp);
    col_index = col_index + 1;
end
% Insert phase data
for ch = 1:nCh
    ph = ph_curve{ch}(:);
    if length(ph) < nT
        ph = [ph; NaN(nT - length(ph),1)];
    end
    table_curves(2:end, col_index) = num2cell(ph);
    col_index = col_index + 1;
end
% Insert frequency data
for ch = 1:nCh
    freq = if_curve{ch}(:);
    if length(freq) < nT
        freq = [freq; NaN(nT - length(freq),1)];
    end
    table_curves(2:end, col_index) = num2cell(freq);
    col_index = col_index + 1;
end
% === Build the reliability summary table (per channel) ===
summary_block = cell(nCh+2, 2);
summary_block{1,1} = 'Channel Reliability Summary';
summary_block{2,1} = 'Channel';
summary_block{2,2} = 'Status';
for ch = 1:nCh
     [is_globally_significant, p_simes] = calculate_simes_test([parameters_results{ch}.spec_skewness.p_value_right, ...
        parameters_results{ch}.spec_sparsity.p_value_right], 0.05);
     if is_globally_significant
        summary_block{2+ch, 2} = 'Reliable';
    else
        summary_block{2+ch, 2} = ...
            'Unreliable: Estimated curves may be unreliable due to high noise or weak normogastric spectral evidence';
    end
end
% === Pad summary_block to match total_columns ===
[n_summary_rows, n_summary_cols] = size(summary_block);
if n_summary_cols < total_columns
    summary_block(:, n_summary_cols+1 : total_columns) = {''};
end
% === Combine summary + curves into a single cell array ===
% Leave one empty row between summary and curves
combined_table = [summary_block; cell(1,total_columns); table_curves];
% === Write to Excel ===
try
    writecell(combined_table, excel_filename3);
    disp(['✔ Instantaneous curves + reliability summary exported to: ', excel_filename3]);
catch ME
    warning(['❌ Error writing Excel file: ', ME.message]);
end
%% Local helper: safe decimation
function y = conditional_decimate(x, mask)
    % conditional_decimate safely decimates x excluding masked points
    x = x(:);
    n = min(length(x), length(mask));
    valid = ~mask(1:n);
    x = x(1:n);
    x_valid = x(valid);
    x_valid(~isfinite(x_valid)) = NaN;
    if all(isnan(x_valid))
        y = [];
        return;
    end
    x_valid = fillmissing(x_valid, 'linear', 'EndValues','nearest');
    if numel(x_valid) > 50
        try
            y = decimate(x_valid, 2);
        catch
            y = downsample(x_valid, 2);
        end
    else
        y = downsample(x_valid, 2);
    end
end
function [is_globally_significant, p_simes] = calculate_simes_test(p_values, alpha)
% CALCULATE_SIMES_TEST Global hypothesis testing using Simes' procedure.
% (Invariato rispetto all'originale)
    if nargin < 2 || isempty(alpha)
        alpha = 0.05;
    end
    % Remove any potential NaN values
    p_values = p_values(~isnan(p_values));
    m = length(p_values);
    
    if m == 0
        is_globally_significant = false;
        p_simes = NaN;
        return;
    end
    % Sort p-values in ascending order
    p_sorted = sort(p_values(:));
    
    % Compute the Simes threshold for each ordered p-value: (j * alpha) / m
    j_indices = (1:m)';
    thresholds = (j_indices .* alpha) / m;
    
    % Check if any p-value meets the Simes criterion
    rejection_vector = p_sorted <= thresholds;
    is_globally_significant = any(rejection_vector);
    
    % Optional: Calculate the adjusted Simes p-value for reporting
    p_simes = min((m .* p_sorted) ./ j_indices);
    
    % Ensure the p-value is bounded between 0 and 1
    p_simes = min(1, max(0, p_simes));
end


function keep = evaluate_channels_cv(freqs, tol_hz)
    % Traduzione del motore iterativo (Greedy Dropping) dallo script R
    mu_sana = 0.05;
    min_fraction = 0.50;
    
    n_start = length(freqs);
    keep = true(1, n_start);
    keep(isnan(freqs)) = false;
    
    % Calcolo C4 stabilizzato numericamente tramite gammaln
    c4 = @(N) sqrt(2 / (N - 1)) * exp(gammaln(N / 2) - gammaln((N - 1) / 2));
    
    % Funzione soglia
    calc_soglia = @(N) (tol_hz / 3.92) * c4(N) / mu_sana;
    
    canali_validi_iniziali = sum(keep);
    min_canali_dinamico = max(3, ceil(canali_validi_iniziali * min_fraction));
    
    while sum(keep) > min_canali_dinamico
        current_freqs = freqs(keep);
        n_current = length(current_freqs);
        cv_current = std(current_freqs) / abs(mean(current_freqs));
        soglia_attuale = calc_soglia(n_current);
        
        if cv_current <= soglia_attuale
            break;
        end
        
        active_indices = find(keep);
        best_cv_without_i = Inf;
        worst_idx = NaN;
        
        for i = 1:length(active_indices)
            idx = active_indices(i);
            test_mask = keep;
            test_mask(idx) = false;
            test_freqs = freqs(test_mask);
            
            if length(test_freqs) < 2
                continue;
            end
            
            test_cv = std(test_freqs) / abs(mean(test_freqs));
            if test_cv < best_cv_without_i
                best_cv_without_i = test_cv;
                worst_idx = idx;
            end
        end
        
        % Se il prossimo taglio manda sotto quorum, ci fermiamo
        if (sum(keep) - 1) < min_canali_dinamico
            break;
        end
        
        keep(worst_idx) = false;
    end
    
    % Valutazione finale
    final_n = sum(keep);
    if final_n >= min_canali_dinamico
        current_freqs = freqs(keep);
        final_cv = std(current_freqs) / abs(mean(current_freqs));
        if final_cv > calc_soglia(final_n)
            keep(:) = false; % Registrazione Irrecuperabile
        end
    else
        keep(:) = false; % Registrazione Irrecuperabile
    end
end