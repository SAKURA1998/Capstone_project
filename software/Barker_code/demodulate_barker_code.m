%Error of one sample point: 340 m/s * 1 / 48 kHz = 0.7cm


clear, clc, close all
% load an audio file
[a, Fs] = audioread('../audio_files/matlab_asio_recorded_20k.wav');

sample_per_frame = 1024;
f_carrier = 20000;

%The first four frames are abandoned here, cause they are inaccraute
%Some random delays, remaning to be figure out
%waiting for the system to be stable
a  = a(34000:end,:);

subplot(3,1,1);
plot(a(:,1))
% subplot(3,1,2);
% plot(a(:,2))


%get lowpass filter
global digital_filter;
[~, digital_filter] = lowpass(a(1:1024, 1),2000, Fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);


%get frame start
baseband_signal = func_get_baseband_signal(a(1:sample_per_frame, 1), Fs, f_carrier);

frame_begin = func_get_frame_begin(baseband_signal);
frame_forward = min(5, frame_begin - 1);
total_frame = floor(size(a,1)/sample_per_frame) - 2; %Each frame contains 600 sample points

path_length_two_mic = zeros(total_frame, 2);

%generate b_upsampled
b_upsampled = func_generate_barker_sequence(sample_per_frame);


tic

for mic_num = 1:1    %size(path_length_two_mic, 2)
    %do sync
    shift = func_sync(a(12 * (frame_begin - frame_forward):12 * (frame_begin - frame_forward) + sample_per_frame, mic_num)  ...
    , Fs, f_carrier, b_upsampled);
    detect_range = 100;
    b_upsampled = circshift(b_upsampled, shift);
    func_sync(a(12 * (frame_begin - frame_forward):12 * (frame_begin - frame_forward) + sample_per_frame, mic_num)  ...
    , Fs, f_carrier, b_upsampled);
    ir_matrix = zeros(detect_range+1, 1);
    for frame_num = 1:total_frame
        %compare two frames each time
        current_frame_start = 12 * (frame_begin - frame_forward) + (frame_num - 1) * 1024;
        current_frame_end   = 12 * (frame_begin - frame_forward) + (frame_num - 1) * 1024 - 1 + sample_per_frame;
        passband_signal = a(current_frame_start: current_frame_end, mic_num);
        baseband_signal = func_get_baseband_signal(passband_signal, Fs, f_carrier);
        [c, ~] = xcorr(baseband_signal, b_upsampled, detect_range);
        if(frame_num > total_frame - 5)
            figure
            plot(abs(c));
        end

        if(frame_num > 1)
            sub = c - ir_matrix;
            if(frame_num > total_frame - 5)
            figure
            plot(abs(sub));
            end
            [~, I] = max(abs(sub));
            reflect_delay = I - detect_range - 1;
            path_length_two_mic(frame_num, 2) = reflect_delay;
            path_length_two_mic(frame_num, mic_num) = sub(I, 1);
        end
        
        ir_matrix = c;
    end
end

toc
figure;
plot(angle(path_length_two_mic(:,1)));

path_length_two_mic(:,1) = angle(path_length_two_mic(:,1));

%calculate the relative distance
for frame_num = 1: size(path_length_two_mic,1) - 1
    path_length_two_mic(frame_num, 1) =34000/20000/2/pi*(mod(((path_length_two_mic(frame_num + 1, 1) - path_length_two_mic(frame_num, 1))+pi),2*pi)-pi);
end

for frame_num = 2: size(path_length_two_mic,1)
    path_length_two_mic(frame_num, 1) =path_length_two_mic(frame_num - 1, 1) + path_length_two_mic(frame_num, 1);
end

figure;
plot(path_length_two_mic(:,1));

figure;
plot(path_length_two_mic(:,2));



track = func_generate_track(path_length_two_mic);

    