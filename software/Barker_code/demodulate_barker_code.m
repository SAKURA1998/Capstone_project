%Error of one sample point: 340 m/s * 1 / 48 kHz = 0.7cm


clear, clc, close all
% load an audio file
[a, Fs] = audioread('audio_barker_20k.wav');
f_carrier = 20000;
subplot(3,1,1);
plot(a(:,1))
% subplot(3,1,2);
% plot(a(:,2))

%The first four frames are abandoned here, cause they are inaccraute
%Some random delays, remaning to be figure out
a  = a(600:end,:);

%get frame start
baseband_signal = func_get_baseband_signal(a(1:600, 1), Fs, f_carrier);

frame_begin = func_get_frame_begin(baseband_signal, 0.00003);

frame_forward = min(5, frame_begin - 1);

total_frame = floor(size(a,1)/600) - 1; %Each frame contains 600 sample points

path_length_two_mic = zeros(total_frame, 2);

for mic_num = 1:size(path_length_two_mic, 2)
    %%%Remember to change 1 to mic_num!!!!!!!!!!
    for frame_num = 1:total_frame
        current_frame_start = 12 * (frame_begin - frame_forward + (frame_num - 1) * 12.5 * 4);
        current_frame_end   = 12 * (frame_begin - frame_forward + 50 + (frame_num - 1) * 12.5 * 4) - 1;
        path_length_two_mic(frame_num, mic_num) = func_get_path_length(...
            a(current_frame_start: current_frame_end, mic_num), ...
            Fs, f_carrier);
    end
end



track = func_generate_track(path_length_two_mic);

    