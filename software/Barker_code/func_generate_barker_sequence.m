function [b_upsampled] = func_generate_barker_sequence(sample_per_frame)

global digital_filter;
b = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
b = [zeros(1, 22) b  zeros(1, 15)];
%which one is better?
% b_upsampled = interp(b,12);
b_upsampled = upsample(b,12);
b_upsampled = [b_upsampled zeros(1, sample_per_frame - 600)];
% b_upsampled = lowpass(b_upsampled, 2000, Fs);
b_upsampled = filtfilt(digital_filter, b_upsampled);