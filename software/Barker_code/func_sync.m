function [shift] = func_sync(a, Fs, f_carrier, b_upsampled)
%%Input
%a: mono sound audio matrix
%Fs: sample frequency
%f_carrier: carrier frequency
%max_lag: range of correlation
%%Output
%ir_matrix: calculated correlation matrix of a single frame
baseband_signal = func_get_baseband_signal(a, Fs, f_carrier);
[c, lags] = xcorr(baseband_signal, b_upsampled, 512);
[~, I] = max(abs(c));
shift = lags(1,I);

figure
plot(lags(1, 1:end), abs(c(1:end, 1))); 

