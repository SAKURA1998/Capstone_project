clear all;close all; clc;
inputFile = '../audio_files/audio_barker_20k.wav';
outputFile = '../audio_files/matlab_asio_recorded_20k.wav';
f_carrier = 20000;
samplesPerFrame = 1024;
total_mic = 2;

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
    input = fileReader()./2;
end

%waiting for the system to be stable
for i=1:100
    deviceWriter(input);
    acquiredAudio = deviceReader();
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    fileWriter(acquiredAudio);
end

%align the sequence to be cross correlated
b_upsample_shifted = func_sync(acquiredAudio, fs, f_carrier, b_upsampled, digital_filter);


total_frame = 1000;
frame_num = 0;
sound_buffer = zeros(2, samplesPerFrame, total_mic);

% figure('Renderer', 'painters', 'Position', [1920/6 1080/6 1200 800])
% h = animatedline('Marker','h','MarkerSize',12);
% %this is the temporarily screen size
% axis([0 30 0 20])

disp('Can move now.')
tic
while (frame_num < total_frame)
    %here, if vibration detected, send to the func_touch_localization part to get the location of strike
    %if the user did not move in the following three frames, then process as a single strike
    %if the user move in the following three frames, then process as a slide

    frame_num = frame_num + 1;
    deviceWriter(input);
    acquiredAudio = deviceReader();
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    fileWriter(acquiredAudio);
    %put into sound buffer
    sound_buffer(1,:,:) = sound_buffer(2,:,:);
    sound_buffer(2,:,:) = acquiredAudio(:,:);

    %if touchsound detected (should use vibration and sound to determine)
    if(max(abs(acquiredAudio(:,1))) > 0.1)
        %Calculate the movement distance in the following 10 frames
        %the number 10 is still in consideration
        disp('Strike detected')
        detect_frame_num = 10;
        ir_matrix = [];
        for i = 1:detect_frame_num
            numUnderrun = deviceWriter(input);
            [acquiredAudio,numOverrun] = deviceReader();
            if(total_mic+2>3)
                acquiredAudio(:,3) = [];
                acquiredAudio(:,3) = [];
            end
            fileWriter(acquiredAudio);
            totalOverrun = totalOverrun + numOverrun;
            totalUnderrun = totalUnderrun + numUnderrun;
            cir = func_calCIR(acquiredAudio, fs, f_carrier, digital_filter, b_upsample_shifted);
            %put all the cir inteo a single matrix
            ir_matrix = cat(3, ir_matrix, cir);
        end
        [motion_flag, distance_change] = func_calDisChange(ir_matrix)
    end

    %calculate the pos here

    

    %cal distance change
    %if(frame_num>2)
    %    [dis_change, peak_pos] = func_calRelativeDis(sound_buffer, fs, f_carrier, digital_filter, b_upsample_shifted)
    %end
    
end
toc
disp('Stop it!')



release(deviceReader);
release(deviceWriter);
release(fileReader);
release(fileWriter);