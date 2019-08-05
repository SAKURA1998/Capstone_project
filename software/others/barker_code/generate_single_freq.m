amp=1;
fs=48000; % sampling frequency
duration=1;
freq=20000;
values=0:1/fs:duration;
a=amp*sin(2*pi*freq*values);
audiowrite('../audio_files/audio_single_freq_20k.wav', a, fs, 'BitsPerSample', 16);

inputFile = '../audio_files/audio_single_freq_20k.wav';
outputFile = '../audio_files/single_20k_recorded.wav';
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

input = fileReader();
%waiting for the system to be stable
for i=1:4 * 48000/ samplesPerFrame
    deviceWriter(input);
    acquiredAudio = deviceReader();
    fileWriter(acquiredAudio);
end

release(deviceReader);
release(fileReader);
release(fileWriter);