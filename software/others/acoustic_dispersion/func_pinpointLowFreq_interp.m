function [arrivals] = func_pinpointLowFreq_interp(data, high, fParams, isDebug)
%use interpolation to find more accurate peak
    nData = size(data, 2);
    nFreq = size(fParams.b, 1);
    arrivals = zeros(1, nFreq);
    
    window = hanning(high * 2)';
    data = [data(1:high) .* window(1:high), data(high + 1:end)];  
    
    cur = zeros(nFreq, nData);
    for cnt = 1:nFreq
        cur(cnt, :) = filter(fParams.b(cnt, :), fParams.a(cnt, :), data);
        
        if cnt == 1
            [~, pts] = min(cur(cnt, :));
            if(pts<nData)
                [pts,~,~] = crit_interp_g(cur(cnt,pts-1:pts+1),pts-1:pts+1);
            end
        else
            %change here!!!!!!!!!!!!!!!!!!!!!!!!
%             start = max(3, min(arrivals(cnt - 1), nData));
            start = max(3, min(ceil(arrivals(cnt - 1))+1, nData));
            for cnt2 = start - 1:-1:2                
                if (cur(cnt, cnt2) < cur(cnt, cnt2 - 1) && cur(cnt, cnt2) <= cur(cnt, cnt2 + 1)) || (cur(cnt, cnt2) <= cur(cnt, cnt2 - 1) && cur(cnt, cnt2) < cur(cnt, cnt2 + 1))
                    pts = cnt2;
                    [pts,~,~] = crit_interp_g(cur(cnt,pts-1:pts+1),pts-1:pts+1);
                    break;
                end
            end
                        
%             [~, pts] = min(cur(cnt, 1:max(1, arrivals(cnt - 1) - 1)));
%             [~, pts] = findpeaks(-cur(cnt, 1:max(3, min(arrivals(cnt - 1), nData)))); 
            
            if isempty(pts)
                pts = arrivals(cnt - 1);
            else
                pts = pts(end);
            end
        end
                
        if ~isempty(pts)                
            arrivals(cnt) = pts(end);
        else
            arrivals(cnt) = arrivals(cnt - 1);
        end
    end
    
    
    if nargin > 3            
        [b, a] = butter(6, 1000/48000 * 2, 'low');
        base = func_normalize(filtfilt(b, a, data));
        [~, baseIdx] = min(base);
        
        subplot(nFreq + 1, 2, 2)
        hold on
        plot(func_normalize(data))                
        plot(base)        
        title(baseIdx)
        
        xlim([1 nData])
        
        

        for cnt = 1:nFreq
            subplot (nFreq + 1, 2, 2 * (cnt + 1))
            hold on
            if cnt <= 2
                plot(func_normalize(cur(cnt, :)))
            elseif fParams.freq(cnt) >= 1000
                plot(func_normalize(cur(cnt, 1:baseIdx)))
            else
                plot(func_normalize(cur(cnt, 1:ceil(arrivals(cnt - 1)))))
%                 plot(func_normalize(cur(cnt, :)))
            end
            title([num2str(fParams.freq(cnt)), ': ', num2str(arrivals(cnt))])
            xlim([1 nData])
        end
    end
    
end

