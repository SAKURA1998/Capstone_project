function [slope, error] = func_computeSlope(TDoA, distance)
nData = size(TDoA, 1);
nTDoA = size(TDoA, 2);

slope = zeros(1, nTDoA);
error = zeros(1, nTDoA);

for cnt = 1:nTDoA
    mSlope = 0;
    mError = 0;
    nValid = 0;
    
    for cnt2 = 1:nData
        for cnt3 = cnt2 + 1:nData
            tmp = TDoA(cnt3, cnt) - TDoA(cnt2, cnt);
            tmp = tmp / (distance(cnt3) - distance(cnt2));                    

            if ~isnan(tmp) && tmp < inf && tmp > -inf
                mSlope = mSlope + tmp;
                mError = mError + TDoA(cnt2, cnt) - tmp * distance(cnt2);
                nValid = nValid + 1;
            end
        end
    end

    slope(cnt) = mSlope / nValid;
    error(cnt) = mError / nValid;
end

end

