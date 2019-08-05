%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

close all; clc;
inputFile = '../audio_files/audio_barker_20k.wav';
outputFile = '../audio_files/matlab_asio_recorded_20k.wav';
f_carrier = 20000;
samplesPerFrame = 576;

%Initialize asio
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
    'NumChannels',2,...
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
global digital_filter;
[~, digital_filter] = lowpass(zeros(1024,1),2000, fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);
%generate b_upsampled
global b_upsampled;
b_upsampled = func_generate_barker_sequence(samplesPerFrame);

input = fileReader();
%waiting for the system to be stable
for i=1:4 * 48000/ samplesPerFrame
    deviceWriter(input);
    acquiredAudio = deviceReader();
    fileWriter(acquiredAudio);
end

b_upsample_shifted = zeros(samplesPerFrame, 2);
for mic_num = 1:1
    %get frame start
    baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier);
    shift = func_sync(acquiredAudio(:, mic_num), fs, f_carrier, b_upsampled);
    b_upsample_shifted(:, mic_num) = circshift(b_upsampled, shift);
end

detect_range = 48;
total_frame = 400;
downsample_rate = 12;
ir_matrix = zeros(2 * detect_range+1, 2);
phase_of_frames = zeros(total_frame, 2);
delay_of_frames = zeros(total_frame, 2);
tau_diff_of_frames = zeros(total_frame, 2);
h_diff_of_frames = zeros(total_frame, 97);
distance_of_frame = zeros(1, 2);
frame_num = 0;


h = animatedline;
%this is the temporarily screen size
axis([0 total_frame -20 20])

disp('Can move now.')
tic
while (frame_num < total_frame)
    frame_num = frame_num + 1;
    numUnderrun = deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();
    fileWriter(acquiredAudio);
    
    for mic_num = 1:1
        baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier);
        [c, ~] = xcorr(baseband_signal, b_upsample_shifted(:, mic_num), detect_range);

        if(frame_num > 1)
            sub = c - ir_matrix(:, mic_num);
            h_diff_of_frames(frame_num, :) = transpose(sub);
            sub = downsample(sub, downsample_rate);
            [~, I] = max(abs(sub));
            reflect_delay = 1 + downsample_rate * (I - 1) - detect_range - 1;
            delay_of_frames(frame_num, mic_num) = reflect_delay;
            phase_of_frames(frame_num, mic_num) = angle(sub(I, 1));
            tau_diff_of_frames(frame_num, mic_num) = -(mod(((phase_of_frames(frame_num, mic_num)...
                    - phase_of_frames(frame_num - 1, mic_num))+pi),2*pi)-pi)/20000/2/pi;
        end
        ir_matrix(:, mic_num) = c;
    end
    
    if(frame_num > 4)
%         variance = var(delay_of_frames(frame_num - 4: frame_num - 1, 1))...
%                     + var(delay_of_frames(frame_num - 4: frame_num - 1, 2));
        for mic_num = 1:1
            variance = var(delay_of_frames(frame_num - 3: frame_num, mic_num));
            if(variance < 49)
                %Here do not need to divide by 2, as there is no
                %double-path here
                distance_diff = 34000 * tau_diff_of_frames(frame_num, mic_num);
                distance_of_frame(1, mic_num) = distance_of_frame(1, mic_num) + distance_diff;
                
                %absolute distance here
%                 [~, I] = max(h_diff_of_frames(frame_num, :));
%                 addpoints(h, frame_num, (I- 49) * 0.7/2);
            end
        end
        %the initial position is assumed to be on the center of the
        %20x20 screen
        point = func_calculate_intersection(distance_of_frame(1, 1) + 20,...
                distance_of_frame(1, 2) + 20, 20, 20);
        addpoints(h, frame_num, distance_of_frame(1, 1));
%         if(size(point, 2)>0)
%             addpoints(h, point(1,1), point(1,2));
%         end
        drawnow limitrate
    end
   totalOverrun = totalOverrun + numOverrun;
   totalUnderrun = totalUnderrun + numUnderrun;
end
toc
drawnow
disp('Stop it!')
% figure;
% plot(phase_of_frames(:, 1));
% figure;
% plot(phase_of_frames(:, 2));

release(deviceReader);
release(fileReader);
release(fileWriter);