clear all; close all; clc;
[rawTotal, Fs] = audioread('../audio_files/wood16times.wav');
load('stylus_global_params.mat', 'globalParams');
load('stylus_test_data.mat');
% load('stylus_calib_params.mat');
%47 * 24
% testLocation = [];
% for i = 1:8
%     temp = [2.5 + 5*i, 3 + 26 - 3*i;2.5 + 5*i, 3 + 26 - 3*i;2.5 + 5*i, 3 + 26 - 3*i ];
%     testLocation = [testLocation; temp];
% end
% for i = 1:8
%     temp = [2.5 + 5*i, 3 + 3*i - 1; 2.5 + 5*i, 3+ 3*i - 1; 2.5 + 5*i,  3 + 3*i - 1 ];
%     testLocation = [testLocation; temp];
% end
% save('testLocation.mat','testLocation')
load('testLocation.mat');

sz = 14;
% sz=size(testLocation, 1);%一共敲击多少次
% cnt = 1;%第一个麦克风

%% Declare Parameter
% test_raw = test_raw(200000:550000,1);
test_raw=zeros(globalParams.mic.num,length(rawTotal(:,1)),1);
test_raw(1,:,:)=transpose(rawTotal(:,1));
% test_raw(2,:,:)=transpose(rawTotal(:,2));
% test_raw(3,:,:)=transpose(rawTotal(:,3));
% test_raw(4,:,:)=transpose(rawTotal(:,4));

touchsound = zeros(sz, globalParams.mic.num, globalParams.detect.win.size);
distanceTotal = zeros(sz,globalParams.mic.num);
arrivals.high = zeros(sz, globalParams.mic.num, 1);
arrivals.low = zeros(sz, globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoATotal = zeros(sz, globalParams.mic.num, size(arrivals.high, 3) * size(arrivals.low, 3));
for cnt=1:globalParams.mic.num
    mIdx = char(globalParams.mic.idx(cnt));
    touchsound(:,cnt,:)=func_separateCalibSamp(sz,test_raw(cnt,:,:), globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size); %将每次敲击的几段音频选取出来,return size=240
    % plot(squeeze(touchsound(11,1,:)),'LineWidth',3);
    % axis([0 240 -1 1]);
    % xlabel('Time (ms)');
    % ylabel('Amplitude');
    % title('Distance = 30 cm');
%     for i=1:sz
    for i=1:sz
        
        %% TDoA
        
        distanceTotal(sz,cnt) = sqrt((globalParams.mic.pos(cnt,1)-testLocation(i,1))^2+(globalParams.mic.pos(cnt,2)-testLocation(i,2))^2);
        arrivals.high(i,cnt, :) = func_pinpointHighFreq(transpose(squeeze(touchsound(i,cnt, :))), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD,1);
        arrivals.low(i,cnt, :) = func_pinpointLowFreq(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter,1);
        % arrivals.low(i,cnt, :) = func_pinpointLowFreq_interp(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter, 1);
%         arrivals.low(i,cnt, :) = func_pinpointLowFreqReversed(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter,1);
        TDoATotal(i,cnt, :) = func_calcTDoA(squeeze(arrivals.low(i,cnt, :)), squeeze(arrivals.high(i,cnt, :)));
    end
    distance = distanceTotal(:,cnt);
    TDoA = squeeze(TDoATotal(:,cnt,:));
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
%     figure
%     scatter(distance, TDoA(:,5), 150,'x','k');
%     hold on
%     plot(distance,distance*slope(1,5)+error(1,5),'-');
%     xlabel('Propagation distance of a touchsound (cm)');
%     ylabel('Time difference of arrival (samples)');
%     title('Relationship between the propagation distance of touchsounds and the TDoA between high-frequency and low-frequency (500hz) waves');
%     axis([0 40 0 60])
    calibration.slope.(char(mIdx))=slope;
    calibration.error.(char(mIdx))=error;
    % save('stylus_calib_params.mat','calibration')
    
end

% diff_low = squeeze(arrivals.low(:,3,:) - arrivals.low(:,1,:));
diff_low = squeeze(arrivals.low(:,1,:));
for i = 1:size(globalParams.pinpoint.low.filter.freq,2)
    plot(diff_low(:,i),'-o');
    hold on
end