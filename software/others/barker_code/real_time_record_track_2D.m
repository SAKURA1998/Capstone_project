close all; clc;
inputFile = '../audio_files/audio_barker_20k.wav';
outputFile = '../audio_files/matlab_asio_recorded_20k.wav';
f_carrier = 20000;
samplesPerFrame = 1024;
total_mic = 2;

%%Initialize asio
fileReader = dsp.AudioFileReader(inputFile, ...
    'SamplesPerFrame',samplesPerFrame);
fileInfo = audioinfo(inputFile);
fs = fileReader.SampleRate;

fileWriter = dsp.AudioFileWriter(...
    outputFile,...
    'FileFormat','WAV',...
    'SampleRate',fs);

deviceReader = audioDeviceReader(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'SamplesPerFrame',samplesPerFrame,...
    'NumChannels',2,...
    'SampleRate',fs);

deviceWriter = audioDeviceWriter(...
    'Device','ASIO4ALL v2',...
    'Driver','ASIO',...
    'BufferSize',samplesPerFrame,...
    'SampleRate',fs);

asiosettings('ASIO4ALL v2')
setup(deviceReader);
setup(deviceWriter, ...
    zeros(fileReader.SamplesPerFrame,fileInfo.NumChannels));
totalOverrun = 0;
totalUnderrun = 0;

%Initialize filter and compare sequence
%get lowpass filter
global digital_filter;
[~, digital_filter] = lowpass(zeros(samplesPerFrame,1),2000, fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);
%generate b_upsampled
global b_upsampled;
b_upsampled = func_generate_barker_sequence(samplesPerFrame);

for i=1:20
    input = fileReader();
end

%waiting for the system to be stable
for i=1:4 * 48000/ samplesPerFrame
    deviceWriter(input);
    acquiredAudio = deviceReader();
    fileWriter(acquiredAudio);
end

b_upsample_shifted = zeros(samplesPerFrame, total_mic);
for mic_num = 1:total_mic
    %get frame start
    baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier);
    shift = func_sync(acquiredAudio(:, mic_num), fs, f_carrier, b_upsampled);
    b_upsample_shifted(:, mic_num) = circshift(b_upsampled, shift);
end

detect_range = 48 * 2;
total_frame = 1000;
downsample_rate = 12;
ir_matrix = zeros(detect_range+1, total_mic);
phase_of_frames = zeros(total_frame, total_mic);
tau_diff_of_frames = zeros(total_frame, total_mic);
delay_of_frames = zeros(total_frame, total_mic);
h_diff_of_frames = zeros(total_frame, detect_range+1, total_mic);
abs_distance = zeros(total_frame, total_mic);
relative_distance = zeros(total_frame, total_mic);
combined_distance = zeros(total_frame, total_mic);
frame_num = 0;
distance_diff = zeros(1, total_mic);
position_set = zeros(1,total_mic);

figure('Renderer', 'painters', 'Position', [1920/6 1080/6 1200 800])
h = animatedline('Marker','h','MarkerSize',12);
%this is the temporarily screen size
axis([0 30 0 20])

disp('Can move now.')
tic
while (frame_num < total_frame)
    frame_num = frame_num + 1;
    numUnderrun = deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();
    fileWriter(acquiredAudio);

    for mic_num = 1:total_mic
        if(mic_num > 2)
            baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num + 2), fs, f_carrier);
        else
            baseband_signal = func_get_baseband_signal(acquiredAudio(:, mic_num), fs, f_carrier);
        end
        [c, ~] = xcorr(baseband_signal, b_upsample_shifted(:, mic_num), detect_range);
        c = c(detect_range + 1:end, 1);

        if(frame_num > 1)
            sub = c - ir_matrix(:, mic_num);
            h_diff_of_frames(frame_num, :, mic_num) = transpose(sub);
            sub = downsample(sub, downsample_rate);
            [pks, locs] = findpeaks(abs(sub));
            [~, max_loc] = max(pks);
            I = locs(max_loc);
            if(size(I,1) ==0)
                I = 1;
            end
            reflect_delay = downsample_rate * (I - 1);
            delay_of_frames(frame_num, mic_num) = reflect_delay;
            %here, questionable
            phase_of_frames(frame_num, mic_num) = angle(sub(I, 1));
            tau_diff_of_frames(frame_num, mic_num) = -(mod(((phase_of_frames(frame_num, mic_num)...
                    - phase_of_frames(frame_num - 1, mic_num))+pi),2*pi)-pi)/20000/2/pi;
        end
        ir_matrix(:, mic_num) = c;
    end
    
    if(frame_num > 4)
        for mic_num = 1:total_mic
            variance = var(delay_of_frames(frame_num - 3: frame_num, mic_num));
            %logic here is doubtful
            if(variance<49)
                %relative_distance
                distance_diff(1, mic_num) = distance_diff(1, mic_num) + 34000 * tau_diff_of_frames(frame_num, mic_num);
                relative_distance(frame_num, mic_num) = distance_diff(1, mic_num);
                
                %abs_distance
                [pks, locs] = findpeaks(abs(h_diff_of_frames(frame_num, :, mic_num)));
                if(~position_set(1, mic_num))
                    [~, max_loc] = max(pks);
                    I = locs(max_loc);
                else
                    range = 15;
                    I_last_frame = abs_distance(frame_num - 1, mic_num) * 48/34 + 1;
                    %Try to add the amplitude of the peaks into
                    %consideration
                    [~, closest_loc] = min(abs(locs - I_last_frame));
                    if(locs(closest_loc)> I_last_frame&&pks(closest_loc)<pks(max(closest_loc - 1,1)))
                        I = locs(closest_loc - 1);
                    elseif(locs(closest_loc) < I_last_frame&&pks(closest_loc)<pks(min(closest_loc + 1,size(pks,2))))
                        I = locs(closest_loc + 1);
                    else
                        I = locs(closest_loc);
                    end
                end
                
                if(I>0)
                        abs_distance(frame_num, mic_num) = (I - 1) * 34/48;
                else
                        abs_distance(frame_num, mic_num) = abs_distance(frame_num - 1, mic_num);
                end
                
                %combined_distance
                if(abs_distance(frame_num, mic_num) - abs_distance(frame_num - 1, mic_num)<3)
                    beta = 0.02;
                else
                    beta = 0;
                end
                combined_distance(frame_num, mic_num) = (1 - beta) ...
                        *(combined_distance(frame_num-1, mic_num) + 34000 * tau_diff_of_frames(frame_num, mic_num)) ...
                        + beta *abs_distance(frame_num, mic_num);
                
                %compensation
                if(mod(frame_num, 1000) == 0)
                    position_set(1, mic_num) = 0;
                end
                
                if(~position_set(1, mic_num))
                    span = 12;
                    if(frame_num > span)
                        if((var(abs_distance(frame_num - span + 1:frame_num,mic_num)...
                                - relative_distance(frame_num - span + 1:frame_num,mic_num))<0.2) ...
                            &&(mean(abs_distance(frame_num - span + 1:frame_num,mic_num))>1))
                            combined_distance(frame_num, mic_num) = abs_distance(frame_num, mic_num);
                            disp('adjust')
                            position_set(1, mic_num) = 1;
                        end
                    end
                end
            else
                relative_distance(frame_num, mic_num) = distance_diff(1, mic_num);
                abs_distance(frame_num, mic_num) = abs_distance(frame_num - 1, mic_num);
                combined_distance(frame_num, mic_num) = combined_distance(frame_num - 1, mic_num);
            end
        end

        if(position_set(1,1)&&position_set(1,2))
            track = func_2dLocalization(combined_distance(frame_num, :));
            clearpoints(h);
            addpoints(h,track(1,1),track(1,2));
            drawnow limitrate
        end
    end
    totalOverrun = totalOverrun + numOverrun;
    totalUnderrun = totalUnderrun + numUnderrun;
end
toc
disp('Stop it!')



release(deviceReader);
release(fileReader);
release(fileWriter);