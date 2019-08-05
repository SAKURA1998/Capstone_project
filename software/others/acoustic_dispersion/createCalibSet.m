clear all; close all; clc;
[test_raw, Fs] = audioread('../audio_files/glass15times.wav');
load('stylus_global_params.mat', 'globalParams');
load('stylus_test_data.mat');
load('stylus_calib_params.mat')
load('distance.mat');

% distance = distance(:,2); %求距离
distance = zeros(16,1);
for i = 1:16
    distance(i,1) = 2.5+2.5*i;
end
sz=15;%一共敲击多少次
cnt = 1;%第一个麦克风

%% Declare Parameter
% test_raw = test_raw(200000:550000,1);
test_raw=transpose(test_raw(:,1));
touchsound = zeros(sz, globalParams.mic.num, globalParams.detect.win.size);
arrivals.high = zeros(sz, globalParams.mic.num, 1);
arrivals.low = zeros(sz, globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoA = zeros(sz, globalParams.mic.num, size(arrivals.high, 3) * size(arrivals.low, 3));
mIdx = char(globalParams.mic.idx(cnt));

touchsound(:,1,:)=func_separateCalibSamp(sz,test_raw, globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size); %将每次敲击的几段音频选取出来,return size=240

% plot(squeeze(touchsound(11,1,:)),'LineWidth',3);
% axis([0 240 -1 1]);
% xlabel('Time (ms)');
% ylabel('Amplitude');
% title('Distance = 30 cm');
for i=1:sz

%% TDoA
arrivals.high(i,cnt, :) = func_pinpointHighFreq(transpose(squeeze(touchsound(i,cnt, :))), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD, 1);    
arrivals.low(i,cnt, :) = func_pinpointLowFreq(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter,1);
% arrivals.low(i,cnt, :) = func_pinpointLowFreq_interp(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter, 1);
TDoA(i,cnt, :) = func_calcTDoA(squeeze(arrivals.low(i,cnt, :)), squeeze(arrivals.high(i,cnt, :)));
end

TDoA = squeeze(TDoA(:,1,:));
% figure
% temp =zeros(3,20);
% for i = 1:3
%     for j = 1:10
%         temp(i,:) = temp(i,:) + TDoA(10*i-10+j,:);
%     end
% end
% for i = 1:size(globalParams.pinpoint.low.filter.freq,2)
%     plot(temp(:,i)/10,'-o');
%     hold on
% end
figure
for i = 1:size(globalParams.pinpoint.low.filter.freq,2)
    plot(TDoA(:,i),'-o');
    hold on
end
slope = zeros(size(TDoA,3),1);
error = zeros(size(TDoA,3),1);
distance=transpose(distance);
[slope, error] = func_computeSlope(TDoA, distance);
% figure
% scatter(distance, TDoA(:,5), 150,'x','k');
% hold on
% plot(distance,distance*slope(1,5)+error(1,5),'-');
% xlabel('Propagation distance of a touchsound (cm)');
% ylabel('Time difference of arrival (samples)');
% title('Relationship between the propagation distance of touchsounds and the TDoA between high-frequency and low-frequency (500hz) waves');
% axis([0 40 0 60])
% calibration.slope.bl=slope;
% calibration.error.bl=error;
% save('stylus_calib_params.mat','calibration')
