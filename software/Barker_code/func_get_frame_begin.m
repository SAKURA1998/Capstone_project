function [frame_begin] = func_get_frame_begin(baseband_signal, threhold)

baseband_signal_downsampled = resample(baseband_signal, 1, 12 ,10);
frame_begin =1;
for i = 1:size(baseband_signal_downsampled,1)
    %Look at the magnitude of 3 consecutive sample
    if (abs(baseband_signal_downsampled(i,1))>threhold)...
    	&&(abs(baseband_signal_downsampled(i+1,1))>threhold)...
    	&&(abs(baseband_signal_downsampled(i+2,1))>threhold)
        frame_begin = i;
        break;
    end
end