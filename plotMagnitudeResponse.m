function plotMagnitudeResponse(num, den, Fs)
    %% Magnitude and Phase response in frequency domain

    % Ensure row vectors
    num = num(:).';
    den = den(:).';
    
    N_num = length(num);
    N_den = length(den);
    
    % Calculate frequency response
    N_fft = max(4096, 2^nextpow2(4*max(N_num, N_den)));
    [H, f_plot] = freqz(num, den, N_fft, Fs, 'whole');
    
    % Shift to center around DC (-Fs/2 to Fs/2)
    H_shifted = fftshift(H);
    f_shifted = f_plot - Fs/2;
    
    % Calculate magnitude in dB
    mag_dB = 20*log10(abs(H_shifted));
    phase_rad = angle(H_shifted);  % Phase in radians (-π to π)
    phase_deg = rad2deg(phase_rad); % Phase in degrees
    
    % Create single figure with 3x2 subplots
    figure('Position', [100 100 1200 900], 'Name', 'Filter Analysis Dashboard');
    
    %% Subplot 1: Magnitude Response (top-left)
    subplot(3, 2, 1);
    plot(f_shifted, mag_dB, 'b', 'LineWidth', 1.5);
    title('Magnitude Response');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    xlim([-Fs/2, Fs/2]);
    y_min = max(min(mag_dB), -120);
    y_max = max(mag_dB) + 5;
    ylim([y_min, y_max]);
    
    %% Subplot 2: Phase Response (top-right)
    subplot(3, 2, 2);
    plot(f_shifted, phase_deg, 'r', 'LineWidth', 1.5);
    title('Phase Response (Wrapped)');
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    grid on;
    xlim([-Fs/2, Fs/2]);
    ylim([-185, 185]);  % Slightly beyond ±180 for visibility
    
    %% Subplot 3: Pole-Zero Plot (middle-left)
    subplot(3, 2, 3);
    hold on;
    
    % Get poles and zeros
    zeros_vec = roots(num);
    poles_vec = roots(den);
    
    % Plot unit circle
    theta = linspace(0, 2*pi, 200);
    plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1);
    
    % Plot zeros (roots of numerator)
    if ~isempty(zeros_vec)
        real_zeros = real(zeros_vec);
        imag_zeros = imag(zeros_vec);
        plot(real_zeros, imag_zeros, 'bo', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'b', 'LineWidth', 1);
    end
    
    % Plot poles (roots of denominator)
    if ~isempty(poles_vec)
        real_poles = real(poles_vec);
        imag_poles = imag(poles_vec);
        plot(real_poles, imag_poles, 'rx', 'MarkerSize', 8, ...
             'LineWidth', 1.5);
    end
    
    % Formatting
    title('Pole-Zero Plot in Z-domain');
    xlabel('Real Part');
    ylabel('Imaginary Part');
    grid on;
    axis equal;
    xlim([-1.2, 1.2]);
    ylim([-1.2, 1.2]);
    
    % Add origin lines
    plot([-1.2 1.2], [0 0], 'k:', 'LineWidth', 0.5);
    plot([0 0], [-1.2 1.2], 'k:', 'LineWidth', 0.5);
    
    % Add a legend
    legend_items = {'Unit Circle'};
    if ~isempty(zeros_vec), legend_items{end+1} = 'Zeros (o)'; end
    if ~isempty(poles_vec), legend_items{end+1} = 'Poles (x)'; end
    legend(legend_items, 'Location', 'best', 'FontSize', 8);
    
    % Add text information
    % text(0.7, 1.0, sprintf('Zeros: %d', length(zeros_vec)), ...
    %      'FontSize', 8, 'BackgroundColor', 'w', 'Color', 'k');
    % text(0.7, 0.9, sprintf('Poles: %d', length(poles_vec)), ...
    %      'FontSize', 8, 'BackgroundColor', 'w', 'Color', 'k');
    
    hold off;
    
    %% Subplot 4: Group Delay (middle-right)
    subplot(3, 2, 4);
    
    % Calculate group delay
    [gd, w] = grpdelay(num, den, N_fft, 'whole');
    
    % Shift to center around DC
    gd_shifted = fftshift(gd);
    w_shifted = fftshift(w) - pi;  % Shift to (-π, π]
    
    % Normalize frequency axis by π
    w_normalized = w_shifted / pi;
    
    % Plot group delay
    h1 = plot(w_normalized, gd_shifted, 'g', 'LineWidth', 1.5);
    hold on;
    title('Group Delay Response');
    xlabel('Normalized Frequency (×π rad/sample)');
    ylabel('Group Delay (samples)');
    grid on;
    xlim([-1, 1]);
    
    % Add average line
    avg_gd = mean(gd);
    h2 = plot([-1, 1], [avg_gd avg_gd], 'r--', 'LineWidth', 1);
    
    hold off;
    
    % Add legend and statistics
    legend([h1, h2], {'Group Delay', sprintf('Average = %.1f', avg_gd)}, ...
           'Location', 'best', 'FontSize', 8);
    
    %% Subplot 5: Impulse Response (bottom-left, spanning 2 columns)
    subplot(3, 2, [5, 6]);  % Span two columns
    
    % Generate impulse response
    impulse_length = max(2 * max(length(num), length(den)));
    [h_impulse, n_impulse] = impz(num, den, impulse_length);
    
    % Convert sample indices to time in seconds
    t_impulse = n_impulse / Fs;
    
    % Plot impulse response
    stem(t_impulse, h_impulse, 'filled', 'b', 'MarkerSize', 4, 'LineWidth', 1);
    title('Impulse Response');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;
    
    % Set appropriate x-axis limits
    xlim([-0.5/Fs, (length(n_impulse)+0.5)/Fs]);
    
    % Add statistics
    max_amp = max(abs(h_impulse));
    energy = sum(h_impulse.^2);
    duration_seconds = (length(h_impulse)-1) / Fs;
    
    stats_text = {sprintf('Duration: %.3f s', duration_seconds), ...
                  sprintf('Samples: %d', length(h_impulse)), ...
                  sprintf('Max Amplitude: %.4f', max_amp), ...
                  sprintf('Energy: %.4f', energy)};
    
    % Add text at top right corner of the graph
    text(0.98, 0.98, stats_text, ...
         'Units', 'normalized', 'FontSize', 8, ...
         'BackgroundColor', 'w', 'Color', 'k', ...
         'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    
    % Add tight layout for better spacing
    sgtitle('Filter Response Analysis', 'FontSize', 12, 'FontWeight', 'bold');
    
end