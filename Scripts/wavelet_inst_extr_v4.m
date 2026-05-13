function [efreq, eamp, ephi, tfrtype, amp_curve, ph_curve, if_curve, anom_new] = ...
    wavelet_inst_extr_v4(x1, t, anom_intervals, plots, fs)
% WAVELET_INST_EXTR_V4_FIX
% Extracts the (normogastric) instantaneous frequency, amplitude, and phase 
% of a signal via ridge method using both the Wavelet Transform (WT) and the 
% Windowed Fourier Transform (WFT), selecting the most appropriate
% time-frequency representation based on a statistical criterion.
%
% INPUTS:
%   x1              - input signal vector
%   t               - time vector (same length as x1)
%   anom_intervals  - vector of anomaly index boundaries [start1, end1, start2, end2, ...]
%   plots           - 'on' or 'off' to enable/disable plotting
%   fs              - sampling frequency (in Hz)
%
% OUTPUTS:
%   efreq           - extracted instantaneous frequency (dominant component)
%   eamp            - extracted instantaneous amplitude
%   ephi            - extracted instantaneous phase
%   tfrtype         - selected time-frequency representation ('WT' or 'WFT')
%   amp_curve       - full amplitude curve over time
%   ph_curve        - full phase curve over time
%   if_curve        - full instantaneous frequency curve over time
%   anom_new        - unchanged anomaly intervals (placeholder for future use)

% Parameters for transforms
f_0_wft = 50;
f_0_wt = f_0_wft / 20;

% Initialize output time series
if_curve = nan(1, length(t));
amp_curve = nan(1, length(t));
ph_curve = nan(1, length(t));

% Compute both WT and WFT
[WT, freq, wopt] = wt(x1, fs, 'fmin', 0.033, 'fmax', 0.067, 'f0', f_0_wt, 'Display', 'off');
[WFT, freq_wft, wopt_wft] = wft(x1, fs, 'fmin', 0.033, 'fmax', 0.067, 'f0', f_0_wft, 'Display', 'off');

anom_new = anom_intervals;

% Process segments according to anomaly intervals
if ~isempty(anom_intervals)

    % Before first anomaly
    if anom_intervals(1) > 1
        idx = 1:anom_intervals(1);
        [eamp, ephi, efreq, tfrtype] = process_segment(WT, freq, wopt, WFT, freq_wft, wopt_wft, fs, idx);
        if_curve(idx) = efreq;
        amp_curve(idx) = eamp;
        ph_curve(idx) = ephi;
    end

    % Between anomalies
    for i = 2:2:length(anom_intervals) - 1
        idx = anom_intervals(i):anom_intervals(i+1);
        [eamp, ephi, efreq, tfrtype] = process_segment(WT, freq, wopt, WFT, freq_wft, wopt_wft, fs, idx);
        if_curve(idx) = efreq;
        amp_curve(idx) = eamp;
        ph_curve(idx) = ephi;
    end

    % After last anomaly
    if anom_intervals(end) < length(t)
        idx = anom_intervals(end):length(t);
        [eamp, ephi, efreq, tfrtype] = process_segment(WT, freq, wopt, WFT, freq_wft, wopt_wft, fs, idx);
        if_curve(idx) = efreq;
        amp_curve(idx) = eamp;
        ph_curve(idx) = ephi;
    end

else
    % Full signal (no anomalies)
    [tfsupp] = ecurve(WT, freq, fs, 'Display', 'off');
    [eamp, ephi, efreq] = bestest(tfsupp, WT, freq, wopt, 'Display', 'off');
    tfrtype = checktype(fs, eamp, efreq, 'off');
    if strcmpi(tfrtype, 'WFT')
        [tfsupp] = ecurve(WFT, freq_wft, fs, 'Display', 'off');
        [eamp, ephi, efreq] = bestest(tfsupp, WFT, freq_wft, wopt_wft, 'Display', 'off');
    end
    if_curve = efreq;
    amp_curve = eamp;
    ph_curve = ephi;
end

% -------------------- Plotting --------------------
if strcmp(plots, 'on')
    % Create figure and set size for better visibility
    figure;
    set(gcf, 'Position', [100, 100, 1000, 700])  % [left bottom width height]

    % Define anomaly patch color and alpha
    anomaly_color = [1 0 0];  % red
    anomaly_alpha = 0.15;

    % Colors: pastel tones
    color_signal = [0.0 0.45 0.74];      % deep blue
    color_amp = [0.85 0.33 0.1];         % red-orange
    color_phase = [0.2 0.7 0.4];         % emerald green
    color_freq = [0.85 0.65 0.13];       % goldenrod yellow

    % --- Subplot 1: Reconstructed Signal and Amplitude Envelope ---
    subplot(3,1,1)
    plot(t, amp_curve .* cos(ph_curve), 'Color', color_signal, 'DisplayName', 'Reconstructed Signal', 'LineWidth', 1.5)
    xlim([t(1), t(end)])
    hold on
    plot(t, amp_curve, 'Color', color_amp, 'DisplayName', 'Amplitude Envelope', 'LineWidth', 1.5)
    drawnow
    ylimits = ylim;  % Get updated y-limits after plotting

    % Add anomaly patches and vertical dashed lines
    if ~isempty(anom_intervals)
        for i = 1:2:length(anom_intervals)
            xstart = t(anom_intervals(i));
            xend = t(anom_intervals(i+1));

            patch([xstart xend xend xstart], [ylimits(1) ylimits(1) ylimits(2) ylimits(2)], ...
                anomaly_color, 'FaceAlpha', anomaly_alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');

            xline(xstart, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
            xline(xend, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
        end
    end

    grid on
    ylabel('Amplitude (\muV)', 'FontSize', 12)
    title('Reconstructed Signal and Amplitude Envelope', 'FontSize', 14)
    legend('Location', 'best')
    hold off

    % --- Subplot 2: Instantaneous Phase ---
    subplot(3,1,2)
    plot(t, wrapToPi(ph_curve), 'Color', color_phase, 'DisplayName', 'Phase', 'LineWidth', 1.5)
    xlim([t(1), t(end)])
    hold on
    drawnow
    ylimits = ylim;

    if ~isempty(anom_intervals)
        for i = 1:2:length(anom_intervals)
            xstart = t(anom_intervals(i));
            xend = t(anom_intervals(i+1));

            patch([xstart xend xend xstart], [ylimits(1) ylimits(1) ylimits(2) ylimits(2)], ...
                anomaly_color, 'FaceAlpha', anomaly_alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');

            xline(xstart, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
            xline(xend, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
        end
    end

    grid on
    yticks([-pi, -pi/2, 0, pi/2, pi])
    yticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'})
    ylabel('Phase (rad)', 'FontSize', 12)
    title('Instantaneous Phase', 'FontSize', 14)
    hold off

    % --- Subplot 3: Instantaneous Frequency ---
    subplot(3,1,3)
    plot(t, if_curve, 'Color', color_freq, 'DisplayName', 'Instantaneous Frequency', 'LineWidth', 1.5)
    xlim([t(1), t(end)])
    hold on
    drawnow
    ylimits = ylim;

    if ~isempty(anom_intervals)
        for i = 1:2:length(anom_intervals)
            xstart = t(anom_intervals(i));
            xend = t(anom_intervals(i+1));

            patch([xstart xend xend xstart], [ylimits(1) ylimits(1) ylimits(2) ylimits(2)], ...
                anomaly_color, 'FaceAlpha', anomaly_alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');

            xline(xstart, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
            xline(xend, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
        end
    end

    grid on
    ylabel('Frequency (Hz)', 'FontSize', 12)
    xlabel('Time (s)', 'FontSize', 12)
    title('Instantaneous Frequency', 'FontSize', 14)
    hold off
end



end

% -------------------- Helper function: segment processing --------------------
function [eamp, ephi, efreq, tfrtype] = process_segment(WT, freq, wopt, WFT, freq_wft, wopt_wft, fs, idx)
    [tfsupp] = ecurve(WT(:, idx), freq, [fs,1], 'Display', 'off', 'Method', 1);
    [eamp, ephi, efreq] = rectfr(tfsupp, WT(:, idx), freq, wopt, 'ridge');
    tfrtype = checktype(fs, eamp, efreq, 'off');
    if strcmpi(tfrtype, 'WFT')
        [tfsupp] = ecurve(WFT(:, idx), freq_wft, fs, 'Display', 'off');
        [eamp, ephi, efreq] = rectfr(tfsupp, WFT(:, idx), freq_wft, wopt_wft, 'ridge');
    end
end

% -------------------- Helper function: determine optimal TFR type --------------------
function tfrtype = checktype(fs, iamp, ifreq, DispMode)

    Perc = 0.75;
    DLev = 1.1;
    L = length(iamp);
    i1 = round((0.5 - Perc/2) * L);
    i2 = round((0.5 + Perc/2) * L);

    % Estimate time-derivatives of amplitude and frequency
    tamp = (iamp(1:end-2) + iamp(2:end-1) + iamp(3:end)) / 3;
    dtamp = fs * (iamp(3:end) - iamp(1:end-2)) / 2;
    tfreq = (ifreq(1:end-2) + ifreq(2:end-1) + ifreq(3:end)) / 3;
    dtfreq = fs * (ifreq(3:end) - ifreq(1:end-2)) / 2;

    gamp1 = sort(abs(hilbert(dtamp./tfreq - mean(dtamp./tfreq))));
    gamp2 = sort(abs(hilbert((dtamp - mean(dtamp)) / mean(tfreq))));
    gfreq1 = sort(abs(hilbert(dtfreq./tfreq - mean(dtfreq./tfreq))));
    gfreq2 = sort(abs(hilbert((dtfreq - mean(dtfreq)) / mean(tfreq))));

    Vamp = (gamp1(i2) - gamp1(i1)) / (gamp2(i2) - gamp2(i1));
    Vfreq = (gfreq1(i2) - gfreq1(i1)) / (gfreq2(i2) - gfreq2(i1));

    if isnan(Vamp), Vamp = 1; end
    if isnan(Vfreq), Vfreq = 1; end

    U = 1 / (1 + Vamp) + 1 / (1 + Vfreq);

    % Decide TFR type
    if U < DLev
        tfrtype = 'WFT'; cstr = '<';
    else
        tfrtype = 'WT';  cstr = '>';
    end

    if ~strcmpi(DispMode, 'off')
        fprintf(['Optimal TFR type was determined to be ', tfrtype, ' (']);
        fprintf('Va=%0.3f, Vf=%0.3f, 1/(1+Va)+1/(1+Vf)=%0.3f', Vamp, Vfreq, U);
        fprintf([cstr, num2str(DLev), ')\n']);
    end
end
