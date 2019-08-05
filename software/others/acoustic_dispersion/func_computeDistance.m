function [ distance] = func_computeDistance( TDoA, slope, error )
nTDoA = size(TDoA, 2);

offset = 10;
distance = zeros(1, nTDoA - offset);
for cnt = offset + 1:nTDoA
    distance(cnt - offset) = (TDoA(cnt) - error(cnt)) / slope(cnt);  
end

limit = 10;
distance = distance(~isnan(distance));
distance = distance(distance > -inf & distance < inf);
distance = distance(distance <= prctile(distance, 100 - limit) & distance >= prctile(distance, limit));
distance = mean(distance);

end

