close all; clc; clear all;
[recorded_sound, fs] = audioread('../audio_files/recorded_strike_calib_48.wav');
%these two columns are zeros
% recorded_sound(:,3:4) = [];
% [~, digital_filter] = bandstop(zeros(size(recorded_sound,1),1),[1 200], fs, ...
%     'Steepness', 0.7);
outputFile = '../audio_files/extracted_sound.wav';
fileWriter = dsp.AudioFileWriter(...
    outputFile,...
    'FileFormat','WAV',...
    'SampleRate',fs);
for i = 1: 4
%     recorded_sound(:,i) = filtfilt(digital_filter_5khz, recorded_sound(:,i));
    subplot(4, 1 ,i)
    plot(recorded_sound(:,i))
end

% start = 424000;
% sound = zeros(4096,4);
% sound(:,1) = recorded_sound(start:start+4096-1,1);
% sound(:,2) = recorded_sound(start:start+4096-1,2);
% sound(:,3) = recorded_sound(start:start+4096-1,5);
% sound(:,4) = recorded_sound(start:start+4096-1,6);


mic_loc =  [0, 0,0;
    0,0.24,0;
    0.47, 0.24,0;
    0.47, 0 ,0];
lsb = [0 0 -0.01];
usb = [0.47 0.24 0.01];

figure;
sample_cnt = 0;
cnt = 0;
while(sample_cnt<size(recorded_sound, 1)-4096)
    sample_cnt = sample_cnt + 1;
    if(abs(recorded_sound(sample_cnt,1))>0.3)
        cnt = cnt + 1;
        start = sample_cnt - 500;
        sound = zeros(2048,4);
        for i = 1:4
            sound(:,i) = recorded_sound(start:start+2048-1,i);
        end
        fileWriter(sound);
        tic
        [finalpos,finalsrp,finalfe]=srplems(sound, mic_loc, fs, lsb, usb)
        toc
        plot(100*finalpos(1,1),100*finalpos(1,2), '-o','MarkerSize', 4);
        xlabel('horizental','fontweight','bold','fontsize',16);
        ylabel('vertical','fontweight','bold','fontsize',16);
        title('virtual screen panel, 44.5cm x 25.5 cm','fontweight','bold','fontsize',16);
        hold on
        grid on
        axis([0 53 0 30])
%         tic
%         [finalpos,finalsrp]=srpphat(sound, mic_loc, fs, lsb, usb);
%         toc
%         room = zeros(1000*usb(1),1000*usb(2));
%         for k=1:numel(finalsrp),
%             room(round(1000*finalpos(k,1)),round(1000*finalpos(k,2)))=max(room(round(1000*finalpos(k,1)),round(1000*finalpos(k,2))),finalsrp(k));
%         end;
%         figure;  imagesc(room');axis xy;
%         finalpos(1,1)
%         finalpos(1,2)
        sample_cnt = sample_cnt + 4096 - 1000;
    end
end

release(fileWriter);