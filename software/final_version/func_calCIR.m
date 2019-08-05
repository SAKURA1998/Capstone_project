function [cir] = func_calCIR(acquiredAudio, fs, f_carrier, digital_filter, b_upsample_shifted)
%input: acquiredAudio: audio of a single frame

%output: cir is the estimated Channel impulse response

total_mic = size(acquiredAudio,2);
detect_range = 48 * 2;
downsample_rate = 12;
cir = zeros(detect_range/downsample_rate+1, total_mic);


for mic_num = 1:total_mic
    baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier, digital_filter);
    [c, ~] = xcorr(baseband_signal, b_upsample_shifted(:, mic_num), detect_range);
    c = c(detect_range + 1:end, 1);
    cir(:,mic_num) = downsample(c, downsample_rate);
end