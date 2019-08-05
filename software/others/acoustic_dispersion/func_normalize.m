function [ result ] = func_normalize( data, type )

if nargin < 2
    type = 'abs';
end

result = zeros(size(data));
for cnt = 1:size(data, 1)
    cur = data(cnt, :);
    switch type
        case 'abs'
            result(cnt, :) = cur / max(abs(cur));
            
        case 'plus'
            if sum(cur > 0) > 0
                result(cnt, :) = cur / max(cur);
            else
                result(cnt, :) = cur / -min(cur);
            end
            
        case 'minus'
            result(cnt, :) = cur / -min(cur);
    end
end


end

