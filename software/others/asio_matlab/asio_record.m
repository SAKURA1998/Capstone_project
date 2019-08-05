%This file is modified from example on site
%https://ww2.mathworks.cn/help/audio/ref/audiodevicereader-system-object.html
%For detailed explaination, please refer the site above

deviceReader = audioDeviceReader(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'SamplesPerFrame',512,...
    'NumChannels',4,...
    'SampleRate',48000);
%deviceReader = audioDeviceReader;
asiosettings('ASIO4ALL v2')
setup(deviceReader);


fileWriter = dsp.AudioFileWriter(...
    'mySpeech.wav',...
    'FileFormat','WAV');

totalOverrun = 0;

disp('Speak into microphone now.')
tic;
while toc < 10
    [acquiredAudio,numOverrun] = deviceReader();
    totalOverrun = totalOverrun + numOverrun;
    fileWriter(acquiredAudio);
end
disp('Recording complete.')

release(deviceReader);
release(fileWriter);