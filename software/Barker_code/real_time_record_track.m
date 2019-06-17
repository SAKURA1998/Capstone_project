%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

clear all; clc;
inputFile = '../audio_files/audio_barker_20k.wav';
f_carrier = 20000;
samplesPerFrame = 1024;

%Initialize asio
fileReader = dsp.AudioFileReader(inputFile, ...
    'SamplesPerFrame',samplesPerFrame);
fileInfo = audioinfo(inputFile);
fs = fileReader.SampleRate;

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

% totalOverrun = 0;
% totalUnderrun = 0;

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
for i=1:8 * 48000/ 1024
    deviceWriter(input);
    acquiredAudio = deviceReader();
end

%get frame start
baseband_signal = func_get_baseband_signal(acquiredAudio(:, 1), fs, f_carrier);

shift = func_sync(acquiredAudio(:, 1), fs, f_carrier, b_upsampled);
detect_range = 100;
b_upsampled = circshift(b_upsampled, shift);
func_sync(acquiredAudio(:, 1), fs, f_carrier, b_upsampled);

ir_matrix = zeros(detect_range+1, 1);
phase_of_frames = [];
delay_of_frames = [];
distance_of_frames = [0];
frame_num = 0;

h = animatedline;
axis([0 1000 -20 20])

disp('Can move now.')
while (frame_num < 1000)
    frame_num = frame_num + 1;
    numUnderrun = deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();

    baseband_signal = func_get_baseband_signal(acquiredAudio(:, 1), fs, f_carrier);
    [c, ~] = xcorr(baseband_signal, b_upsampled, detect_range);
    
    if(frame_num > 1)
        sub = c - ir_matrix;
        [~, I] = max(abs(sub));
        reflect_delay = I - detect_range - 1;
        delay_of_frames = [delay_of_frames reflect_delay];
        phase_of_frames = [phase_of_frames angle(sub(I, 1))];
    end
    
    if(frame_num > 5)
        phase_of_frames(1, frame_num - 2) =34000/20000/2/2/pi*(mod(((phase_of_frames(1,frame_num - 1) - phase_of_frames(1, frame_num - 2))+pi),2*pi)-pi);
        distance_of_frames = [distance_of_frames (distance_of_frames(1, frame_num - 2) + phase_of_frames(1, frame_num - 2))];
        addpoints(h, frame_num - 2, distance_of_frames(1, frame_num - 2));
        drawnow
    end
    
    ir_matrix = c;
%    totalOverrun = totalOverrun + numOverrun;
%    totalUnderrun = totalUnderrun + numUnderrun;
end
disp('Stop it!')

% figure;
% plot(phase_of_frames);
% 
% phase_of_frames = transpose(phase_of_frames);

% for frame_num = 1: size(phase_of_frames, 1) - 1
%     phase_of_frames(frame_num, 1) =34000/20000/2/2/pi*(mod(((phase_of_frames(frame_num + 1, 1) - phase_of_frames(frame_num, 1))+pi),2*pi)-pi);
% end
% 
% for frame_num = 2: size(phase_of_frames, 1)
%     phase_of_frames(frame_num, 1) =phase_of_frames(frame_num - 1, 1) + phase_of_frames(frame_num, 1);
% end

% figure;
% plot(phase_of_frames);

% figure;
% plot(delay_of_frames);

release(deviceWriter);
release(deviceReader);
release(fileReader);