close all; clc; clear all;
outputFile = '../audio_files/recorded_strike_acry_10_10.wav';
samplesPerFrame = 1024;
total_mic = 4;
fs = 48000;

%%Initialize asio
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

asiosettings('ASIO4ALL v2')
setup(deviceReader);
totalOverrun = 0;
total_frame = 100;
frame_num = 0;

disp('Can move now.')
tic
while (frame_num < total_frame)
    frame_num = frame_num + 1;
    [acquiredAudio,numOverrun] = deviceReader();
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    fileWriter(acquiredAudio);
    totalOverrun = totalOverrun + numOverrun;
end
toc
disp('Stop it!')

[recorded_sound, Fs] = audioread('../audio_files/recorded_strike_acry_10_10.wav');
% mic1:(5,20) mic2(30,15) mic3(10,20) mic4(19,20)
figure
subplot(4, 1 ,1)
plot(recorded_sound(:,1))
subplot(4, 1 ,2)
plot(recorded_sound(:,2))
subplot(4, 1 ,3)
plot(recorded_sound(:,3))
subplot(4, 1 ,4)
plot(recorded_sound(:,4))


release(deviceReader);
release(fileWriter);