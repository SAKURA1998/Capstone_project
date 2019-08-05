% wavread(filename) 读取一个WAVE文件，并返回采样数据到向量y中，Fs表示采样频率, bits表示采样位数  
clear all; close all; clc;
[test_raw, Fs] = audioread('../audio_files/strike12times.wav');
% test_raw = test_raw(:,2);


%% Load parameters
load(['stylus_calib_params.mat'], 'calibration');
load(['stylus_global_params.mat'], 'globalParams');

% globalParams.pinpoint.high.WVD.threshold = .5;

%% Declare data
touchsound = zeros(globalParams.mic.num, globalParams.detect.win.size);
arrivals.high = zeros(globalParams.mic.num, 1);
arrivals.low = zeros(globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoA = zeros(globalParams.mic.num, size(arrivals.high, 2) * size(arrivals.low, 2));
distance = zeros(globalParams.mic.num, 1);


cnt = 1;

mIdx = char(globalParams.mic.idx(cnt));

%% Touchsound detection
touchsound(cnt, :) = func_detectEarlyPart(transpose(test_raw), globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size);                
subplot 323
plot(touchsound(cnt, :));


%% Arrival time / TDoA estimation
arrivals.high(cnt, :) = func_pinpointHighFreq(touchsound(cnt, :), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD, 1);    
arrivals.low(cnt, :) = func_pinpointLowFreq(touchsound(cnt, :), arrivals.high(cnt, end), globalParams.pinpoint.low.filter, 1);
TDoA(cnt, :) = func_calcTDoA(arrivals.low(cnt, :), arrivals.high(cnt, :));
    
%% Distance calculation
distance(cnt) = func_computeDistance(TDoA(cnt, :), calibration.slope.(mIdx), calibration.error.(mIdx));
