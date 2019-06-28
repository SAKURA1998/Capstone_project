function [] = func_demodulate_frame(acquiredAudio)
%Error of one sample point: 340 m/s * 1 / 48 kHz = 0.7cm

%The first four frames are abandoned here, cause they are inaccraute
%Some random delays, remaning to be figure out
%waiting for the system to be stable


%get lowpass filter
global digital_filter;
%generate b_upsampled
global b_upsampled;

    baseband_signal = func_get_baseband_signal(acquiredAudio, fs, f_carrier);
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

    