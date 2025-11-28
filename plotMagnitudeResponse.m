function plotMagnitudeResponse(num, den, Fs)
    % Ensure row vectors
    num = num(:).';
    den = den(:).';

    % Calculate frequency response
    N_fft = 8192;
    [H, w] = freqz(num, den, N_fft, Fs);
    f_plot = w;
    % Calculate magnitude in dB
    mag_dB = 20*log10(abs(H));

    % Create figure
    figure;
    % Plot magnitude response
    plot(f_plot, mag_dB, 'b', 'LineWidth', 2);
    % Format plot
    title('Magnitude Response');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    xlim([0, Fs/2]);
end


