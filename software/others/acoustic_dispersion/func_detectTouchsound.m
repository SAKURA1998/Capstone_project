function [ data ] = func_detectTouchsound( record, minPeakH, minPeakD, lWidth, rWidth )
tWidth = lWidth + rWidth;
[~, locs] = findpeaks(abs(record), 'MinPeakHeight', minPeakH, 'MinPeakDistance', minPeakD);
    
data.raw = zeros(length(locs), tWidth);
data.baseIdx = zeros(1, length(locs));

for cnt = 1:length(locs)
    data.raw(cnt, :) = record(locs(cnt) - lWidth + (1:tWidth));
    data.baseIdx(cnt) = locs(cnt);
end

end

