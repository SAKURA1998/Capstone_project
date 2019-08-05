function [result] = func_2dLocalization(abs_distance)
%abs_distance is the total path length of the two mic respectively
%step is the search standard
%result is the 2-D location in x and y

mic_num = size(abs_distance, 2);
minError = Inf;
width = 30; height = 20;
mic1_pos = [30 5];
mic2_pos= [30 15];
speaker_pos = [30 10];
result = zeros(1, 2);
result_temp = zeros(1, 2);

%%First round search
step = 1;
for cnt1 = -1:step:width
    for cnt2 = -1:step:height
        cur = [cnt1, cnt2];
        
        dist = zeros(1, mic_num);
        dist(1, 1) = norm(mic1_pos - cur) + norm(speaker_pos - cur);
        dist(1, 2) = norm(mic2_pos - cur) + norm(speaker_pos - cur);
                
        error = 0;
        for cnt3 = 1:mic_num
            error = error + (abs_distance(1, cnt3) - dist(1, cnt3))^2;
        end    

        if error < minError
            minError = error;
            result_temp = cur;
        end
%         result(cnt1, cnt2) = error;
    end
end

step = 0.1;
minError = Inf;
for cnt1 = result_temp(1, 1) - 2:step:result_temp(1, 1) + 2
    for cnt2 = result_temp(1, 2) - 2:step:result_temp(1, 2) + 2
        cur = [cnt1, cnt2];
        
        dist = zeros(1, mic_num);
        dist(1, 1) = norm(mic1_pos - cur) + norm(speaker_pos - cur);
        dist(1, 2) = norm(mic2_pos - cur) + norm(speaker_pos - cur);
                
        error = 0;
        for cnt3 = 1:mic_num
            error = error + (abs_distance(1, cnt3) - dist(1, cnt3))^2;
        end    

        if error < minError
            minError = error;
            result = cur;
        end
%         result(cnt1, cnt2) = error;
    end
end
% [X,Y] = meshgrid(1:height,1:width);
% surf(X,Y,result)
end