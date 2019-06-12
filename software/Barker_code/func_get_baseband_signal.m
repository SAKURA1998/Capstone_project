function [baseband_signal] = func_get_baseband_signal(a, Fs, f_carrier)
%%Input
%a: mono sound audio matrix, a single frame
%Fs: sample frequency
%f_carrier: carrier frequency
%%Output
%baseband_signal: demodulated baseband signal

len           = size(a, 1);
t             = 1 / Fs : 1/Fs : len/Fs ;  % time in seconds
signal_real   = sqrt(2)*cos(2 * pi * f_carrier * t);
signal_img    = sqrt(2)*sin(2 * pi * f_carrier * t);
result_real   = a .* signal_real.';
baseband_real = lowpass(result_real, 2000, Fs);
result_img    = a .* signal_img.';
baseband_img  = lowpass(result_img, 2000, Fs);
baseband_signal = baseband_real - 1i*baseband_img;

% figure
% plot(abs(baseband_signal));