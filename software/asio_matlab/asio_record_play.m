%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

inputFile = '../audio_files/audio_barker_10k.wav';
outputFile = '../audio_files/matlab_asio_recorded_10k.wav';

fileReader = dsp.AudioFileReader(inputFile, ...
    'SamplesPerFrame',512);
fileInfo = audioinfo(inputFile);
fs = fileReader.SampleRate;

fileWriter = dsp.AudioFileWriter(...
    outputFile,...
    'FileFormat','WAV',...
    'SampleRate',fs);

deviceReader = audioDeviceReader(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'SamplesPerFrame',512,...
    'NumChannels',4,...
    'SampleRate',fs);

deviceWriter = audioDeviceWriter(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'BufferSize',512,...
    'SampleRate',fs);

asiosettings('ASIO4ALL v2')
setup(deviceReader);
setup(deviceWriter, ...
    zeros(fileReader.SamplesPerFrame,fileInfo.NumChannels));



totalOverrun = 0;
totalUnderrun = 0;

disp('Speak into microphone now.')
while ~isDone(fileReader)
    input = fileReader();
    numUnderrun = deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();
    fileWriter(acquiredAudio);
    totalOverrun = totalOverrun + numOverrun;
    totalUnderrun = totalUnderrun + numUnderrun;
end
disp('Recording complete.')

release(deviceWriter);
release(deviceReader);
release(fileWriter);
release(fileReader);

[a, Fs] = audioread(outputFile);
subplot(3,1,1);
plot(a(:,1))
subplot(3,1,2);
plot(a(:,2))
% subplot(3,1,3);
% plot(a(:,5))