function [motion_flag, distance_change] = func_calDisChange(ir_matrix)
%input: calculated cir response of several frames

%output: motion_flag 0 represent the finger did not move, this is a point operation. Otherwise it's a slide operation
%dis_change represent the distance change from begin to end of these frames

h_diff = zeros(size(ir_matrix,1),size(ir_matrix,2),size(ir_matrix,3)-1);
phase_diff = zeros(size(ir_matrix,2),size(ir_matrix,3)-2);
motion_flag = ones(size(ir_matrix,2),1);

for i = 1:size(h_diff, 3)
    h_diff(:,:,i) = ir_matrix(:,:,i+1) - ir_matrix(:,:,i);
end

for mic_num = 1:size(phase_diff,1)
    for frame_num = 1:size(phase_diff, 2)
        [~, I] = max(abs(h_diff(:,mic_num,frame_num+1)));
        phase_diff(mic_num,frame_num) = -(mod(((angle(h_diff(I,mic_num,frame_num+1))- angle(h_diff(I,mic_num,frame_num)))+pi),2*pi)-pi);
        %find the outliers. If the motion is continous, no outlier should be observed.
        if(frame_num>2)
            if(abs(phase_diff(mic_num,frame_num)-phase_diff(mic_num,frame_num-1))>1)
                %actually, we can seen this as no motion in this case
                phase_diff(mic_num,frame_num) = 0;
                motion_flag(mic_num) = 0;
            end
        end
    end
end

dis_diff = phase_diff(:,:)/20000/2/pi*34000;
distance_change = sum(dis_diff, 2);
for i = 1:4
    if(motion_flag(i)&&distance_change(i)<0)
        motion_flag(i) = -1;
    end
end