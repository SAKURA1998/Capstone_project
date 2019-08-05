function [ result ] = func_calcEnergy( data, winSize )
numWin = size(data, 2);
result = zeros(size(data, 1), numWin);

squared = data.^2;

for cnt = winSize:numWin
    if cnt == winSize
        result(cnt) = sum(squared(1:winSize));
    else
        result(cnt) = result(cnt - 1) - squared(cnt - winSize) + squared(cnt);
    end  
end

end

