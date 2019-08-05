clear all; close all; clc;
[test_raw, Fs] = audioread('../audio_files/wood16times.wav');
load('stylus_global_params.mat', 'globalParams');
load('stylus_calib_params.mat')

% distance = 15 * ones(15,1);
sz=11;%一共敲击多少次
cnt = 1;%第一个麦克风

%% Declare Parameter
% test_raw = test_raw(200000:550000,1);
test_raw=transpose(test_raw(:,1));
touchsound = zeros(sz, globalParams.mic.num, globalParams.detect.win.size);
arrivals.high = zeros(sz, globalParams.mic.num, 1);
arrivals.low = zeros(sz, globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoA = zeros(sz, globalParams.mic.num, size(arrivals.high, 3) * size(arrivals.low, 3));

distance = zeros(sz,globalParams.mic.num, 1);
mIdx = char(globalParams.mic.idx(cnt));

touchsound(:,1,:)=func_separateCalibSamp(sz,test_raw, globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size); %将每次敲击的几段音频选取出来,return size=240
for i=1:sz

%% TDoA
arrivals.high(i,cnt, :) = func_pinpointHighFreq(transpose(squeeze(touchsound(i,cnt, :))), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD, 1);    
arrivals.low(i,cnt, :) = func_pinpointLowFreq(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter, 1);
% arrivals.low(i,cnt, :) = func_pinpointLowFreq_interp(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter, 1);
TDoA(i,cnt, :) = func_calcTDoA(squeeze(arrivals.low(i,cnt, :)), squeeze(arrivals.high(i,cnt, :)));

distance(i,cnt,1) = func_computeDistance(squeeze(TDoA(i,cnt, :)), calibration.slope.(mIdx), calibration.error.(mIdx));
end
