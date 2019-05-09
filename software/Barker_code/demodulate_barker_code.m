clear, clc, close all
% load an audio file
[a, Fs] = audioread('recording.m4a');
subplot(2,1,1);
plot(a(:,1))
subplot(2,1,2);
plot(a(:,2))
a             = a(:,1);
len           = size(a, 1);
t             = 1 / Fs : 1/Fs : len/Fs ;  % time in seconds
f_carrier     = 10000;
signal_real   = sqrt(2)*cos(2 * pi * f_carrier * t);
signal_img    = sqrt(2)*sin(2 * pi * f_carrier * t);
result_real   = a .* signal_real.';
baseband_real = lowpass(result_real, 2000, Fs);
result_img    = a .* signal_img.';
baseband_img  = lowpass(result_img, 2000, Fs);
plot(baseband_real);
baseband_real_downsampled = resample(baseband_real, 1, 12, 10);
baseband_img_downsampled  = resample(baseband_img, 1, 12, 10);





baseband_signal = baseband_real - 1i*baseband_img;
baseband_signal_downsampled = baseband_real_downsampled- 1i*baseband_img_downsampled;

theta = 0.003;                      %Threshold for coarse frame detection
frame_begin = 1;
for i = 1:size(baseband_signal_downsampled,1)
    %Look at the magnitude of 3 consecutive sample
    if (abs(baseband_signal_downsampled(i,1))>0.003)&&(abs(baseband_signal_downsampled(i+1,1))>0.003)&&(abs(baseband_signal_downsampled(i+2,1))>0.003)
        frame_begin = i;
        break;
    end
end

b = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
b = [zeros(1, 22) b  zeros(1, 15)];
b_upsampled = interp(b,12);

peak_index_phase   = zeros(2000/12.5, 8, 2);  %last bit 1 for index, 2 for phase

frame_forward = 5;

for frame_num = 1:size(peak_index_phase, 1)
    current_frame_start = 12 * (frame_begin - frame_forward + (frame_num - 1) * 12.5 * 4);
    current_frame_end   = 12 * (frame_begin - frame_forward + size(b ,2) - 1 + (frame_num - 1) * 12.5 * 4);
    %[c, lags] = xcorr(baseband_signal_downsampled(current_frame_start : current_frame_end, 1), b);
    %[~, I] = max(abs(c));
    %frame_begin_coarse = current_frame_start + lags(1,I);
    %stem(lags,abs(c));                 %We can observe that the calculated starting point is 45, as expected. Cheer!
    %TODO  use the raw sampled data to do fine grained estimation
    [c, lags] = xcorr(baseband_signal(current_frame_start : current_frame_end, 1), b_upsampled);
    if mod(frame_num, 10)==0
        plot(lags(1, 300:end), abs(c(300:end, 1)));                 %fine grained estimate
    end
    [pks,locs] = findpeaks(abs(c));
    [~, I] = max(pks);
    theta = angle(c);
    for tap_num = 1:size(peak_index_phase, 2)
        peak_index_phase(frame_num, tap_num, 1) = current_frame_start + lags(1, locs(I + tap_num -1, 1));
        peak_index_phase(frame_num, tap_num, 2) = theta(locs(I + tap_num -1, 1), 1);
    end
end

initial_frame_start = peak_index_phase(1, 1, 1);

for frame_num = 1: size(peak_index_phase, 1)
    for tap_num = 1: size(peak_index_phase, 2)
        peak_index_phase(frame_num, tap_num, 1) = peak_index_phase(frame_num, tap_num, 1) - initial_frame_start - (frame_num - 1) * 600;
    end
end

for i = 1: size(peak_index_phase, 2)
    subplot(4, 2, i);
    plot(peak_index_phase(:, i, 2))
end
%plot(baseband_signal, 'o');