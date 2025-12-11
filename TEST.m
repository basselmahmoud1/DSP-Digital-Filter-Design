clear;
close all;
clc;

[xn,fs] = audioread('sample_audio_file.wav');

% convert from stero to mono 
xn = mean(xn,2);
N_xn = length(xn);

% axis of drawing 
t = linspace(0, N_xn/fs ,N_xn);

% divided by fs or N ? 
xf = abs(fft(xn)) / N_xn;

%xf = xf(1:N/2);
f = linspace(0, fs ,N_xn);

hn = zeros(1,3001);
D = 1000 ;

hn(1) = 1 ; 
hn(1*D + 1) = 0.9 ;
hn(2*D + 1) = 0.8 ;
hn(3*D + 1) = 0.7 ;

% Numerator coefficients (b)
b = hn;  % Length 3001 vector with non-zero values at positions [1, 1001, 2001, 3001]

% Denominator coefficients (a)
a = 1;   % Single value 1 for FIR filter

N_DFT = length(hn) + N_xn;
N_DFT =  2 ^ nextpow2(N_DFT); % 2^22

plotMagnitudeResponse(b, a, N_DFT, D, true, fs);
plotMagnitudeResponse(b, a, N_DFT, D, false, fs);