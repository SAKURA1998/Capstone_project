function [diff] = func_calcTDoA(low, high)

diff = zeros(size(low, 1), size(low, 2) * size(high, 2));

for cnt = 1:size(low, 2)
    for cnt2 = 1:size(high, 2)        
        diff(:, (cnt - 1) * size(high, 2) + cnt2) = low(:, cnt) - high(:, cnt2);
    end
end

end

