%See site below
%https://ww2.mathworks.cn/help/audio/ref/audioplayerrecorder-system-object.html

fileReader = dsp.AudioFileReader('audio_barker_18k.wav', ...
    'SamplesPerFrame',512);
fileInfo = audioinfo('audio_barker_18k.wav');
fs = fileReader.SampleRate;

fileWriter = dsp.AudioFileWriter(...
    'matlab_asio_recorded_18k.wav',...
    'FileFormat','WAV',...
    'SampleRate',fs);

deviceReader = audioDeviceReader(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'SamplesPerFrame',512,...
    'NumChannels',1,...
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