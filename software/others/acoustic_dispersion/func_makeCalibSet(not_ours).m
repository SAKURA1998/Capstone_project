function [distance, TDoA, slope, error] = func_makeCalibSet(arrivals, layout, cur, total, type)
range = cur.range(1):cur.interval:cur.range(2);
if size(range, 2) < cur.nPoint
    range(end + 1) = cur.range(2);
end

nData = cur.nPoint * cur.nTapTime;

distance = zeros(1, nData);
for cnt = 1:cur.nPoint
    width = layout.left + (range(cnt) - 1) * layout.unit(1);
    height = layout.bot + (range(cnt) - 1) * layout.unit(2);
        
    distance((cnt - 1) * cur.nTapTime + (1:cur.nTapTime)) = ones(1, cur.nTapTime) * norm([width, height]);
end

if strcmp(type, 'tl') || strcmp(type, 'tr')
    range = total.nPoint - range + 1;
end

if strcmp(type, 'br') || strcmp(type, 'tl')
    range = range + total.nPoint;
end


TDoA = zeros(nData, size(arrivals.low, 2) * size(arrivals.high, 2));
for cnt = 1:cur.nPoint 
    for cnt2 = 1:cur.nTapTime
        low = arrivals.low((range(cnt) - 1) * total.nTapTime + cnt2, :);
        high = arrivals.high((range(cnt) - 1) * total.nTapTime + cnt2, :);
        
        TDoA((cnt - 1) * cur.nTapTime + cnt2, :) = func_calcTDoA(low, high);
    end
end

[slope, error] = func_computeSlope(TDoA, distnace);

% nTDoA = size(TDoA, 2);
% slope = zeros(1, nTDoA);
% error = zeros(1, nTDoA);
% 
% for cnt = 1:nTDoA
%     mSlope = 0;
%     mError = 0;
%     nValid = 0;
%     for cnt2 = 1:nData
%         for cnt3 = cnt2 + 1:nData
%             tmp = TDoA(cnt3, cnt) - TDoA(cnt2, cnt);
%             tmp = tmp / (distance(cnt3) - distance(cnt2));                    
% 
%             if ~isnan(tmp) && tmp < inf && tmp > -inf
%                 mSlope = mSlope + tmp;
%                 mError = mError + TDoA(cnt2, cnt) - tmp * distance(cnt2);
%                 nValid = nValid + 1;
%             end
%         end
%     end
% 
%     slope(cnt) = mSlope / nValid;
%     error(cnt) = mError / nValid;
% end

end

