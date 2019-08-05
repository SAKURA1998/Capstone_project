function [pos] = func_soundLocalization(acquiredAudio, fs, digital_filter_20khz,digital_filter_5khz)
%input acquiredAudio: a piece of audio with the strike sound
%output pos: 2-D location located by cross correlation

% digital_filter_50hz = designfilt('bandstopiir','FilterOrder',2, ...
%     'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
%     'DesignMethod','butter','SampleRate',fs);
% digital_filter_150hz = designfilt('bandstopiir','FilterOrder',2, ...
%     'HalfPowerFrequency1',149,'HalfPowerFrequency2',151, ...
%     'DesignMethod','butter','SampleRate',fs);
% digital_filter_20khz = designfilt('bandstopiir','FilterOrder',2, ...
%     'HalfPowerFrequency1',18000,'HalfPowerFrequency2',22000, ...
%     'DesignMethod','butter','SampleRate',fs);
% digital_filter_5khz = designfilt('bandstopiir','FilterOrder',2, ...
%     'HalfPowerFrequency1',1,'HalfPowerFrequency2',5000, ...
%     'DesignMethod','butter','SampleRate',fs);
for i = 1: size(acquiredAudio,2)
%     acquiredAudio(:,i) = filtfilt(digital_filter_50hz, acquiredAudio(:,i));
%     acquiredAudio(:,i) = filtfilt(digital_filter_150hz, acquiredAudio(:,i));
    acquiredAudio(:,i) = filtfilt(digital_filter_20khz, acquiredAudio(:,i));
    acquiredAudio(:,i) = filtfilt(digital_filter_5khz, acquiredAudio(:,i));
    subplot(4, 1 ,i)
    plot(acquiredAudio(:,i))
end

mic_loc =  [0,0,0;
    0,0.22,0;
    0.47, 0.22,0;
    0.47, 0 ,0];
lsb = [-0.02 -0.02 -0.01];
usb = [0.49 0.22 0.01];
pos=srplems(acquiredAudio, mic_loc, fs, lsb, usb);