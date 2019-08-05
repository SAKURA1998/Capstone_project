function [path_length] = func_get_path_length(a, Fs, f_carrier, b_upsampled, detect_range, sample_per_frame)
%%Input
%a: mono sound audio matrix
%Fs: sample frequency
%f_carrier: carrier frequency
%%Output
%path_length: calculated path_length of a single frame


for i=1:2
    passband_signal = a(1 + (i-1) * sample_per_frame: i*sample_per_frame);
    baseband_signal = func_get_baseband_signal(passband_signal, Fs, f_carrier);
    [c, ~] = xcorr(baseband_signal, b_upsampled, detect_range/2);
    figure
    plot(abs(c));
    ir_matrix = c - ir_matrix;
end

[~, I] = max(abs(ir_matrix));
reflect_delay = I - 1;

path_length = ir_matrix(I, 1);


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

% speed_of_sound = 34000; %cm/s


%divide by two to get the path length
% path_length = speed_of_sound / Fs * ...
%        (peak_index_phase(2, 1) - peak_index_phase(1, 1));
% path_length = peak_index_phase(1,1);
% for i = 1: size(peak_index_phase, 2)
%     subplot(4, 2, i);
%     plot(peak_index_phase(:, i, 2))
% end
%plot(baseband_signal, 'o');