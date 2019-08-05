%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

% close all;
clear all; clc;
inputFile = '../audio_files/matlab_asio_recorded_20k.wav';
% inputFile = '../audio_files/audio_barker_20k.wav';
f_carrier = 20000;
samplesPerFrame = 1024;
total_mic = 2;

%Initialize asio
fileReader = dsp.AudioFileReader(inputFile, ...
    'SamplesPerFrame',samplesPerFrame);
fileInfo = audioinfo(inputFile);
fs = fileReader.SampleRate;


%Initialize filter and compare sequence
%get lowpass filter
global digital_filter;
[~, digital_filter] = lowpass(zeros(samplesPerFrame,1),2000, fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);
%generate b_upsampled
global b_upsampled;
b_upsampled = func_generate_barker_sequence(samplesPerFrame);

for i=1:4 * 48000/ samplesPerFrame
    acquiredAudio = fileReader();
%     if(total_mic+2>3)
%         acquiredAudio(:,3) = [];
%         acquiredAudio(:,3) = [];
%     end
end

b_upsample_shifted = func_sync(acquiredAudio, fs, f_carrier, b_upsampled, digital_filter);



detect_range = 48 * 3;
total_frame = 1000;
downsample_rate = 12;
ir_matrix = zeros(total_frame, detect_range+1, total_mic);
phase_diff_of_frames = zeros(total_frame, detect_range/downsample_rate + 1, total_mic);
tau_diff_of_frames = zeros(total_frame, total_mic);
delay_of_frames = zeros(total_frame, total_mic);
h_diff_of_frames = zeros(total_frame, detect_range+1, total_mic);
abs_distance = zeros(total_frame, total_mic);
relative_distance = zeros(total_frame, total_mic);
combined_distance = zeros(total_frame, total_mic);
frame_num = 0;
distance_diff = zeros(1, total_mic);
position_set = zeros(1,total_mic);
static_frame = zeros(1,total_mic);
phase_acu = zeros(2,total_mic);
threhold_h = [0.00, 0.00 0];

% h = animatedline('Marker','h','MarkerSize',12);
%this is the temporarily screen size
% axis([0 25 0 20])

disp('Can move now.')
tic
while (frame_num < total_frame)
    frame_num = frame_num + 1;
    acquiredAudio = fileReader();

    %%calculate frame difference
    for mic_num = 1:total_mic
        if(mic_num > 2)
            baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num + 2), fs, f_carrier, digital_filter);
        else
            baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier, digital_filter);
        end
        [c, ~] = xcorr(baseband_signal, b_upsample_shifted(:, mic_num), detect_range);
        c = c(detect_range + 1:end, 1);
        ir_matrix(frame_num,:, mic_num) = c;
        
        if(frame_num > 1)
            sub = c - transpose(ir_matrix(frame_num - 1,:, mic_num));
            h_diff_of_frames(frame_num, :, mic_num) = transpose(sub);
            for tap_num = 0:detect_range/downsample_rate
                phase_diff_of_frames(frame_num, tap_num + 1, mic_num) = -(mod(((angle(h_diff_of_frames(frame_num, tap_num*downsample_rate + 1,mic_num))...
                    - angle(h_diff_of_frames(frame_num - 1, tap_num*downsample_rate + 1,mic_num)))+pi),2*pi)-pi);
            end
        end
    end
    
    %%compute distance
    if(frame_num > 3)
        for mic_num = 1:total_mic
            %logic here is doubtful
            if(max(abs(h_diff_of_frames(frame_num,:,mic_num)))>threhold_h(1,mic_num))
                %relative_distance
                phase_change_diff = zeros(1, detect_range/downsample_rate + 1);
                for tap_num = 0:detect_range/downsample_rate
                    if(abs(ir_matrix(frame_num,tap_num*downsample_rate+1, mic_num) ...
                            - ir_matrix(frame_num - 1,tap_num*downsample_rate+1, mic_num))...
                            >0.05 * abs(ir_matrix(frame_num,tap_num*downsample_rate+1, mic_num)))
                        phase_change_diff(1, tap_num+1) = max(abs(phase_diff_of_frames(frame_num,tap_num+1, mic_num)...
                            -phase_diff_of_frames(frame_num - 1,tap_num+1, mic_num)),...
                            abs(phase_diff_of_frames(frame_num -1,tap_num+1, mic_num)...
                            -phase_diff_of_frames(frame_num - 2,tap_num+1, mic_num)));
                    else
                        phase_change_diff(tap_num+1) = inf;
                    end
                end
                [~, I] = min(phase_change_diff);
                reflect_delay = downsample_rate * (I - 1);
                delay_of_frames(frame_num, mic_num) = reflect_delay;
                
                %throw away the outliers
                tau_diff_of_frames(frame_num, mic_num) = phase_diff_of_frames(frame_num, I, mic_num)/20000/2/pi;
                if(abs(tau_diff_of_frames(frame_num, mic_num)...
                        -tau_diff_of_frames(frame_num -1, mic_num))>1/20000/2/pi)
                    tau_diff_of_frames(frame_num, mic_num) = 0;
                end
                distance_diff(1, mic_num) = distance_diff(1, mic_num) + 34000 * tau_diff_of_frames(frame_num, mic_num);
                relative_distance(frame_num, mic_num) = distance_diff(1, mic_num);
                
                %abs_distance
                phase_acu(1,mic_num) = phase_acu(1,mic_num) + tau_diff_of_frames(frame_num, mic_num)*20000*2*pi;
                phase_acu(2,mic_num) = phase_acu(2,mic_num) + 1;
                if(abs(phase_acu(1,mic_num))>pi/4)
                    [pks, locs] = findpeaks(abs(ir_matrix(frame_num,:,mic_num)-ir_matrix(frame_num - phase_acu(2,mic_num),:,mic_num)));
                    %%%%%%%%quesitonable here ~position_set(1, mic_num)
                    if(1)
                        [~, max_loc] = max(pks);
                        I = locs(max_loc);
                    else
                        I_last_frame = abs_distance(frame_num - 1, mic_num) * 48/34 + 1;
                        %Try to add the amplitude of the peaks into
                        %consideration
                        [pks, locs] = findpeaks(abs(h_diff_of_frames(frame_num, I_last_frame - 6:I_last_frame + 6, mic_num)));
                        [~, max_loc] = max(pks);
                        I = locs(max_loc) + I_last_frame - 6 - 1;
                    end
                    
                    if(I>0)
                        abs_distance(frame_num, mic_num) = (I - 1) * 34/48;
                    else
                        abs_distance(frame_num, mic_num) = abs_distance(frame_num - 1, mic_num);
                    end
                    phase_acu(1,mic_num) = 0;
                    phase_acu(2,mic_num) = 0;
                else
                    abs_distance(frame_num, mic_num) = abs_distance(frame_num - 1, mic_num);
                end
                
                %combined_distance
                if(abs(abs_distance(frame_num, mic_num) - abs_distance(frame_num - 1, mic_num))<3)
                    beta = 0.002;
                else
                    beta = 0;
                end
                combined_distance(frame_num, mic_num) = (1 - beta) ...
                        *(combined_distance(frame_num-1, mic_num) + 34000 * tau_diff_of_frames(frame_num, mic_num)) ...
                        + beta *abs_distance(frame_num, mic_num);
                
                %compensation
                if(mod(frame_num, 2000) == 0)
                    position_set(1, mic_num) = 0;
                end
                
                if(~position_set(1, mic_num))
                    span = 12;
                    if( (frame_num - static_frame(1,mic_num)) > span)
                        if((var(abs_distance(frame_num - span + 1:frame_num,mic_num)...
                                - relative_distance(frame_num - span + 1:frame_num,mic_num))<0.2))
%                             relative_distance(frame_num, mic_num) = abs_distance(frame_num, mic_num);
%                             distance_diff(1, mic_num) = abs_distance(frame_num, mic_num);
                            combined_distance(frame_num, mic_num) = abs_distance(frame_num, mic_num);
                            %clear useless data
%                             if(~track_flag(1,mic_num))
%                                 combined_distance(1:frame_num -1, mic_num) = zeros(frame_num -1 ,1);
%                             end
                            disp('adjust')
                            position_set(1, mic_num) = 1;
                        end
                    end
                end
            else
                static_frame(1, mic_num) = frame_num;
                relative_distance(frame_num, mic_num) = distance_diff(1, mic_num);
                abs_distance(frame_num, mic_num) = abs_distance(frame_num - 1, mic_num);
                combined_distance(frame_num, mic_num) = combined_distance(frame_num - 1, mic_num);
            end
        end

%         if(position_set(1,1)&&position_set(1,2))
%             track = func_2dLocalization(combined_distance(frame_num, :));
%             clearpoints(h);
%             addpoints(h,track(1,1),track(1,2));
%             drawnow limitrate
%         end
    end
end
toc
% drawnow
disp('Stop it!')

var_matrix = zeros(total_frame, 2);
span = 4;
for mic_num = 1: total_mic
    for frame_num = span:total_frame
        var_matrix(frame_num, mic_num) = var(abs_distance(frame_num - span + 1:frame_num,mic_num)...
                                - relative_distance(frame_num - span + 1:frame_num,mic_num));
    end
end

figure
% plot(relative_distance(:,1));
% hold on
% plot(relative_distance(:,2));
% hold on
% plot(abs_distance(:,1));
% hold on
% plot(abs_distance(:,2));
% hold on
% plot(combined_distance(:,1));
% hold on
% plot(combined_distance(:,2));
% hold on 
% plot(var_matrix(:,1));
% hold on 
% plot(var_matrix(:,2));

figure
imagesc(abs(transpose(h_diff_of_frames(:,:,1))));

peaks_locs = zeros(total_frame, detect_range+1, 1);
peaks_diff = zeros(total_frame, 1);
for i = 2:total_frame
    [pks,locs] = findpeaks(abs(h_diff_of_frames(i,:,2)));
    for j = 1:size(locs,2)
        peaks_locs(i,locs(j),1) = 1 * pks(j);
    end
    [~, I] = max(pks);
    peaks_locs(i,locs(I),1) = pks(I);
    peaks_diff(i, 1) = pks(I);
    pks(I) = 0;
    [~,I] = max(pks);
    peaks_locs(i,locs(I),1) = pks(I);
end

hold on
imagesc(abs(transpose(peaks_locs(:,:,1))));



smoothed_dis = zeros(total_frame, mic_num);
track = zeros(total_frame, 2);
smoothed_dis(:,1) = smooth(combined_distance(:,1),10);
smoothed_dis(:,2) = smooth(combined_distance(:,2),10);

tic;
for frame_num = 200:total_frame
    track(frame_num, :) = func_2dLocalization(combined_distance(frame_num,:));
end
toc;
figure
plot(track(:,1),track(:,2));
axis([0 30 0 20])

% figure
% plot(abs(h_diff_of_frames(50,:,1)),'LineWidth',3);
% % axis([0 240 -1 1]);
% xlabel('Samples');
% ylabel('Amplitude');
% title('Estimated CIR change');
cir_matrix = zeros(145,2,10);
for i = 1:10
   cir_matrix(:,:,i) =  squeeze(ir_matrix(500+i,:,:));
end

release(fileReader);