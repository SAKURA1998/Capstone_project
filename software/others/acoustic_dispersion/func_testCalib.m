clear all; close all; clc;
%% Load parameters
load(['stylus_global_params.mat'], 'globalParams');
load(['stylus_test_data.mat']);
% globalParams.pinpoint.high.WVD.threshold = .5;
test_raw = test.raw.bl;
distance = sqrt(test.pos.bl(:,1).^2+test.pos.bl(:,2).^2);
%% Declare data
sz = size(distance, 1);
cnt = 1;
interval=3;
touchsound = zeros(sz, globalParams.mic.num, globalParams.detect.win.size);
arrivals.high = zeros(sz, globalParams.mic.num, 1);
arrivals.low = zeros(sz, globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoA = zeros(sz, globalParams.mic.num, size(arrivals.high, 3) * size(arrivals.low, 3));

mIdx = char(globalParams.mic.idx(cnt));

%% Touchsound detection

for i=1:sz
touchsound(i,cnt, :) = func_detectEarlyPart(transpose(test_raw(i,:)), globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size);                
% plot(touchsound(i,cnt, :));

%% TDoA
arrivals.high(i,cnt, :) = func_pinpointHighFreq(transpose(squeeze(touchsound(i,cnt, :))), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD);    
arrivals.low(i,cnt, :) = func_pinpointLowFreq(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter);
TDoA(i,cnt, :) = func_calcTDoA(squeeze(arrivals.low(i,cnt, :)), squeeze(arrivals.high(i,cnt, :)));
end

TDoA = squeeze(TDoA(:,1,:));
slope = zeros(size(TDoA,3),1);
error = zeros(size(TDoA,3),1);
distance=transpose(distance);
[slope, error] = func_computeSlope(TDoA, distance);

% TDoA_new=zeros(size(TDoA,1)/interval,size(TDoA,3));
% distance_new=zeros(size(distance,1)/interval,size(distance,2));
% for i=1:size(TDoA,3)
%     for j = 1:interval:size(TDoA,1)
%         TDoA_new(ceil(j/interval), i) = (TDoA(j,:,i) + TDoA(j+1,:,i) + TDoA(j+2, :, i))/interval;
%         distance_new(ceil(j/interval),size(distance,2))=distance(j,size(distance,2));
%     end
% end
% for i = 1:size(TDoA_new,2)
%     [slope(i), error(i)] = func_computeSlope(TDoA_new(:,i), distance_new);
% end
% i=1;
% pred = (TDoA_new(:, i) - error(i)) / slope(i);
% plot(pred, 'o'); hold on;
% plot(distance, 'x');
% slope = zeros(size(TDoA,3),1);
% error = zeros(size(TDoA,3),1);
% for i = 1:size(TDoA,3)
% ans = fitlm(distance,TDoA(:,:,i));
% error(i) = ans.Coefficients.Estimate(1);

% slope(i) = ans.Coefficients.Estimate(2);
% end