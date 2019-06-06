function [path_length] = func_get_path_length(a, Fs, f_carrier)
%%Input
%a: mono sound audio matrix
%Fs: sample frequency
%f_carrier: carrier frequency
%%Output
%path_length: calculated path_length of a single frame

baseband_signal = func_get_baseband_signal(a, Fs, f_carrier);


b_upsampled = func_generate_barker_sequence(Fs);

% [c, lags] = xcorr(b_upsampled, b_upsampled);
% figure;
% plot(lags(1, 300:end), abs(c(1, 300:end)));     %fine grained estimate
% 
% [c, lags] = xcorr(baseband_signal, b_upsampled);
% figure;
% plot(lags(1, 300:end), abs(c(300:end, 1)));     %fine grained estimate


peak_index_phase   = zeros(8, 2);  %last bit 1 for index, 2 for phase

%[c, lags] = xcorr(baseband_signal_downsampled(current_frame_start : current_frame_end, 1), b);
%[~, I] = max(abs(c));
%frame_begin_coarse = current_frame_start + lags(1,I);
%stem(lags,abs(c));                 
%TODO  use the raw sampled data to do fine grained estimation
[c, lags] = xcorr(baseband_signal, b_upsampled);
plot(lags(1, 1:end), abs(c(1:end, 1)));               %fine grained estimate
[pks,locs] = findpeaks(abs(c));
[~, I] = max(pks);
theta = angle(c);
for tap_num = 1:size(peak_index_phase, 1)
    peak_index_phase(tap_num, 1) = lags(1, locs(I + tap_num -1, 1));
    peak_index_phase(tap_num, 2) = theta(locs(I + tap_num -1, 1), 1);
end

% initial_frame_start = peak_index_phase(1, 1, 1);
% 
% for frame_num = 1: size(peak_index_phase, 1)
%     for tap_num = 1: size(peak_index_phase, 2)
%         peak_index_phase(frame_num, tap_num, 1) = peak_index_phase(frame_num, tap_num, 1) - initial_frame_start - (frame_num - 1) * 600;
%     end
% end

%Let's suppose that we have a 21 inch 16:9 screen, which is 47.6cm x 26.8cm
%Then suppose that we have following microphone and speaker setting:
%               Speaker--------------------Mic
%               ------------------------------
%               ------------------------------
%               ------------------------------
%               Mic---------------------------
%Then we calculate the 2D location based on above settings
%The calculation is based on the assumption that the second peak of correlation
%is the signal reflected by the finger/hand.

speed_of_sound = 34000; %cm/s


%divide by two to get the path length
path_length = speed_of_sound / Fs * ...
       (peak_index_phase(2, 1)) / 2;

% for i = 1: size(peak_index_phase, 2)
%     subplot(4, 2, i);
%     plot(peak_index_phase(:, i, 2))
% end
%plot(baseband_signal, 'o');