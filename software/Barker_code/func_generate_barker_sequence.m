function [b_upsampled] = func_generate_barker_sequence(Fs)

b = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
b = [zeros(1, 22) b  zeros(1, 15)];
b_upsampled = interp(b,12);
b_upsampled = lowpass(b_upsampled, 2000, Fs);