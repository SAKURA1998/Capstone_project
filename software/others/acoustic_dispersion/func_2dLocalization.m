function [result] = func_2dLocalization(range, mic, measured)
minError = Inf;
nCandidates = size(range.w, 2);

result = zeros(1, 2);
for cnt = 1:nCandidates
    for cnt2 = 1:nCandidates
        cur = [range.w(cnt), range.h(cnt2)];
        
        dist = zeros(1, mic.num);
        for cnt3 = 1:mic.num
            dist(cnt3) = norm(mic.pos(cnt3, :) - cur);
        end
                
        error = 0;
        for cnt3 = 1:mic.num
            error = error + (measured(cnt3) - dist(cnt3))^2;
            for cnt4 = cnt3 + 1:mic.num
                diff = measured(cnt3) - measured(cnt4);
                ref = dist(cnt3) - dist(cnt4);                                
                error = error + (ref - diff).^2;
            end
        end    

        if error < minError
            minError = error;
            result = cur;
        end
    end
end

end

