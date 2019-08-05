function [b_upsample_shifted] = func_sync(acquiredAudio, fs, f_carrier, b_upsampled, digital_filter)

b_upsample_shifted = zeros(size(acquiredAudio,1), size(acquiredAudio,2));
for mic_num = 1:size(acquiredAudio,2)
    %get frame start
    baseband_signal = func_get_baseband_signal(acquiredAudio(:,mic_num), fs, f_carrier, digital_filter);
	[c, lags] = xcorr(baseband_signal, b_upsampled, size(acquiredAudio,1));
	[~, I] = max(abs(c));
	shift = lags(1,I);
    %shift
    b_upsample_shifted(:, mic_num) = circshift(b_upsampled, shift);
end

