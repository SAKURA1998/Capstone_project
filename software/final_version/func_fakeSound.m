function simulated_sound = func_fakeSound(strike_sound, b_upsampled, fs, f_carrier, digital_filter)

baseband_signal = func_get_baseband_signal(strike_sound(:,1), fs, f_carrier, digital_filter);
[c, lags] = xcorr(baseband_signal, b_upsampled, 1024);
[~, I] = max(abs(c));
shift = lags(1,I);
b_upsampled_shifted = circshift(b_upsampled, shift);
simulated_sound = zeros(size(strike_sound,1),4);
simulated_sound(size(strike_sound,1)/4:size(strike_sound,1)*3/4,:) = 1;

for mic_num = 2:size(strike_sound,2)
    %get frame start
    baseband_signal = func_get_baseband_signal(strike_sound(:,mic_num), fs, f_carrier, digital_filter);
	[c, lags] = xcorr(baseband_signal, b_upsampled_shifted, 100);
	[~, I] = max(abs(c));
	shift = lags(1,I);
    %shift
    simulated_sound(:,mic_num) = circshift(simulated_sound(:,1),shift);
end