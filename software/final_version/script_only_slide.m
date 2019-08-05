%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

% close all;
clear all; clc;
addpath( '../control_interface');
inputFile = '../audio_files/audio_barker_20k_640samplesPerFrame.wav';
outputFile = '../audio_files/matlab_asio_recorded_20k.wav';
% inputFile = '../audio_files/audio_barker_20k.wav';
f_carrier = 20000;
samplesPerFrame = 640;
total_mic = 4;

%%Initialize asio
fileReader = dsp.AudioFileReader(inputFile, ...
    'SamplesPerFrame',samplesPerFrame);
fileInfo = audioinfo(inputFile);
fs = fileReader.SampleRate;

fileWriter = dsp.AudioFileWriter(...
    outputFile,...
    'FileFormat','WAV',...
    'SampleRate',fs);

deviceReader = audioDeviceReader(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'SamplesPerFrame',samplesPerFrame,...
    'NumChannels',total_mic+2,...
    'SampleRate',fs);

deviceWriter = audioDeviceWriter(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'BufferSize',samplesPerFrame,...
    'SampleRate',fs);

asiosettings('ASIO4ALL v2')
setup(deviceReader);
setup(deviceWriter, ...
    zeros(fileReader.SamplesPerFrame,fileInfo.NumChannels));
totalOverrun = 0;
totalUnderrun = 0;


%Initialize filter and compare sequence
%get lowpass filter
[~, digital_filter] = lowpass(zeros(samplesPerFrame,1),2000, fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);
%generate b_upsampled
b_upsampled = func_generate_barker_sequence(samplesPerFrame, digital_filter);

for i=1:20
    input = fileReader()*2;
end

%waiting for the system to be stable
soundbuffer = zeros(samplesPerFrame*2, total_mic);
for i=1:100
    deviceWriter(input);
    acquiredAudio = deviceReader();
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    soundbuffer(1:samplesPerFrame,:) = soundbuffer(samplesPerFrame+1:end,:);
    soundbuffer(samplesPerFrame+1:end,:) = acquiredAudio(:,:);
    %     fileWriter(acquiredAudio);
end
%align the sequence to be cross correlated
b_upsample_shifted = func_sync(soundbuffer, fs, f_carrier, b_upsampled, digital_filter);

detect_offset = 50;%50frames
detect_range = 48 * 2;
downsample_rate = 12;
ir_matrix.current = zeros(detect_range+1, total_mic);
ir_matrix.past = zeros(detect_range+1, total_mic);
h_diff_of_frames.current = zeros(detect_range+1, total_mic);
h_diff_of_frames.past = zeros(detect_range+1, total_mic);
phase_diff_of_frames = zeros(3, detect_range/downsample_rate + 1, total_mic);
tau_diff_of_frames = zeros(1,total_mic);
relative_distance = zeros(detect_offset + 1, total_mic);
frame_num = 0;
distance_diff = zeros(1, total_mic);

% h = animatedline;
% %this is the temporarily screen size
% axis([0 total_frame -60 60])

last_slide_frame = 0; 


disp('Can move now.')
tic
while (1)
    frame_num = frame_num + 1;
    deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();
    totalOverrun = totalOverrun + numOverrun;
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    fileWriter(acquiredAudio);
    soundbuffer(1:samplesPerFrame,:) = soundbuffer(samplesPerFrame+1:end,:);
    soundbuffer(samplesPerFrame+1:end,:) = acquiredAudio(:,:);
    %%calculate frame difference
    for mic_num = 1:total_mic
        baseband_signal = func_get_baseband_signal(soundbuffer(:, mic_num), fs, f_carrier, digital_filter);
        [c, ~] = xcorr(baseband_signal, b_upsample_shifted(:, mic_num), detect_range);
        c = c(detect_range + 1:end, 1);
        ir_matrix.past(:, mic_num) = ir_matrix.current(:, mic_num);
        ir_matrix.current(:, mic_num) = c;
        
        if(frame_num > 1)
            h_diff_of_frames.past(:, mic_num) = h_diff_of_frames.current(:, mic_num);
            h_diff_of_frames.current(:, mic_num) = ir_matrix.current(:, mic_num) - ir_matrix.past(:, mic_num);
            phase_diff_of_frames(1:2,:,mic_num) = phase_diff_of_frames(2:3,:,mic_num);
            for tap_num = 0:detect_range/downsample_rate
                phase_diff_of_frames(3, tap_num + 1, mic_num) = -(mod(((angle(h_diff_of_frames.current(tap_num*downsample_rate + 1,mic_num))...
                    - angle(h_diff_of_frames.past(tap_num*downsample_rate + 1,mic_num)))+pi),2*pi)-pi);
            end
        end
    end
    
    %%compute distance
    if(frame_num > 3)
        for mic_num = 1:total_mic
            if(max(abs(h_diff_of_frames.current(:,mic_num)))>0.01)
                %relative_distance
                phase_change_diff = zeros(1, detect_range/downsample_rate + 1);
                for tap_num = 0:detect_range/downsample_rate
                    if(abs(ir_matrix.current(tap_num*downsample_rate+1, mic_num) ...
                            - ir_matrix.past(tap_num*downsample_rate+1, mic_num))...
                            >0.05 * abs(ir_matrix.current(tap_num*downsample_rate+1, mic_num)))
                        phase_change_diff(1, tap_num+1) = max(abs(phase_diff_of_frames(3,tap_num+1, mic_num)...
                            -phase_diff_of_frames(2,tap_num+1, mic_num)),...
                            abs(phase_diff_of_frames(2,tap_num+1, mic_num)...
                            -phase_diff_of_frames(1,tap_num+1, mic_num)));
                    else
                        phase_change_diff(tap_num+1) = inf;
                    end
                end
                [~, I] = min(phase_change_diff);
                
                %             %throw away the outliers
                tau_diff_of_frames(1, mic_num) = phase_diff_of_frames(3, I, mic_num)/20000/2/pi;
%                 if(abs(tau_diff_of_frames(frame_num, mic_num)...
%                         -tau_diff_of_frames(frame_num -1, mic_num))>1/20000/2/pi)
%                     tau_diff_of_frames(frame_num, mic_num) = 0;
%                 end
                distance_diff(1, mic_num) = distance_diff(1, mic_num) + 34000 * tau_diff_of_frames(1, mic_num);
                relative_distance(1:end-1,mic_num) = relative_distance(2:end,mic_num);
                relative_distance(end, mic_num) = distance_diff(1, mic_num);
            else
                relative_distance(1:end-1,mic_num) = relative_distance(2:end,mic_num);
                relative_distance(end, mic_num) = relative_distance(end -1, mic_num);
            end
        end
%         addpoints(h, frame_num, relative_distance(end -1, 1));
%         drawnow limitrate
    end
    %decide the movement direction
    if(frame_num - last_slide_frame>detect_offset)
        max_change = zeros(total_mic,1);
        slide_flag = 1;
        %compute distance change
        for i = 1:total_mic
            [max_val,I_max] =  max(relative_distance(:, i));
            [min_val,I_min] =  min(relative_distance(:, i));
            if(I_max > I_min)
                max_change(i) = max_val - min_val;
            else
                max_change(i) = min_val - max_val;
            end
        end
        %compute the slide direction
        if(max_change(1)>15&&max_change(4)>15)
            disp('up');
            write_slide("up");
        elseif(max_change(1)<-15&&max_change(4)<-15)
            disp('down');
            write_slide("down");
        elseif(max_change(1)>10&&max_change(4)<-10)
            disp('right');
            write_slide("right");
        elseif(max_change(1)<-10&&max_change(4)>10)
            disp('left');
            write_slide("left");
        else
            slide_flag = 0;
        end
        %set the slide frame index
        if(slide_flag)
            last_slide_frame = frame_num + detect_offset;
        end
    end
end
toc
% drawnow
disp('Stop it!')
    
    
figure
plot(relative_distance(:,1));
hold on
plot(relative_distance(:,4));
hold on