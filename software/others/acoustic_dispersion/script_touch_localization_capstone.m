clear all; close all; clc;
[test_raw, Fs] = audioread('../audio_files/5-2.5-30.wav');

%% Just for test
load('stylus_global_params.mat');
test_raw = test_raw';

sz = 11;
touchsound = zeros(sz, globalParams.mic.num, 3840);
data = zeros(globalParams.mic.num, 3840);
distance = zeros(globalParams.mic.num,sz);

for i = 1:globalParams.mic.num
    touchsound(:,i,:)=func_separateCalibSamp(sz,test_raw(i,:), globalParams.detect.filter, globalParams.detect.energy, 3840);
end

for i = 1:sz
    for j = 1:globalParams.mic.num
        data(j,:) = touchsound(i,j,:);
    end
    [~,distance(:,i)] = func_touch_localization(data);
end
%% Actual localization
% == Input ==
% cur.raw: detected touchsound (double [# of microphones][length of touchsound])
% == Output ==
% result: 2D location of touch inputs
% distance: 1D distance of touch inputs from microphones
