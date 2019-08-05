function [pos, distance] = func_touch_localization(raw)

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

%% Per-device measurement
for cnt = 1:globalParams.mic.num
    mIdx = char(globalParams.mic.idx(cnt));
    
    %% Touchsound detection
    touchsound(cnt, :) = func_detectEarlyPart(raw(cnt, :), globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size);                
    
    %% Arrival time / TDoA estimation
    arrivals.high(cnt, :) = func_pinpointHighFreq(touchsound(cnt, :), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD);    
    arrivals.low(cnt, :) = func_pinpointLowFreq(touchsound(cnt, :), arrivals.high(cnt, end), globalParams.pinpoint.low.filter);
    TDoA(cnt, :) = func_calcTDoA(arrivals.low(cnt, :), arrivals.high(cnt, :));
    
    %% Distance calculation
    distance(cnt) = func_computeDistance(TDoA(cnt, :), calibration.slope.(mIdx), calibration.error.(mIdx));
end

%% 2D localization with 2,500 candidates
pos = func_2dLocalization(globalParams.localization.range, globalParams.mic, distance);

%% Nested 2D localization
range.w = pos(1) + globalParams.localization.second.range.w;
range.h = pos(2) + globalParams.localization.second.range.h;
pos = func_2dLocalization(range, globalParams.mic, distance);    

end

