clear all;close all; clc;
addpath('../acoustic_dispersion', '../control_interface');
inputFile = '../audio_files/audio_barker_20k.wav';
outputFile = '../audio_files/matlab_asio_recorded_20k.wav';
f_carrier = 20000;
samplesPerFrame = 1024;
total_mic = 4;

%% Initialize arduino
s1=serial('COM7','BaudRate',115200);
s1.InputBufferSize = 1024;
fopen(s1);

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
    'NumChannels',total_mic+2,...
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
[~, digital_filter] = lowpass(zeros(samplesPerFrame,1),2000, fs, ...
    'ImpulseResponse', 'fir', ...
    'Steepness', 0.85);
digital_filter_20khz = designfilt('bandpassiir','FilterOrder',2, ...
    'HalfPowerFrequency1',18000,'HalfPowerFrequency2',22000, ...
    'DesignMethod','butter','SampleRate',fs);
digital_filter_5khz = designfilt('bandstopiir','FilterOrder',2, ...
    'HalfPowerFrequency1',1,'HalfPowerFrequency2',5000, ...
    'DesignMethod','butter','SampleRate',fs);
%generate b_upsampled
b_upsampled = func_generate_barker_sequence(samplesPerFrame, digital_filter);

for i=1:20
    input = fileReader()*2;
end

%waiting for the system to be stable
for i=1:100
    %deviceWriter(input);
    acquiredAudio = deviceReader();
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
%     fileWriter(acquiredAudio);
end
%align the sequence to be cross correlated
% b_upsample_shifted = func_sync(acquiredAudio, fs, f_carrier, b_upsampled, digital_filter);
sound_buffer = zeros(3, samplesPerFrame, total_mic);

% figure('Renderer', 'painters', 'Position', [1920/6 1080/6 1200 800])
% h = animatedline('Marker','h','MarkerSize',12);
% %this is the temporarily screen size
% axis([0 30 0 20])

%% =================================
% Algorithm Configuation Parameters for M-SRP
% =================================

conf.wlen     = 3072;                           % Window length [samples]
conf.timestep = 3072;                           % Time step (hop size) [samples]    
conf.c        = 345;                            % Speed of sound [m/s]
conf.xyz      = [0, 0.53, 0, 0.30, -0.01, 0.01];         % xyz search space limits [m]: [xmin,xmax,ymin,ymax,zmin,zmax]
conf.cres     = 0.005;                           % Spatial grid resolution [m]
conf.fs       = 48000;                          % Sampling frequency [Hz]
conf.RImethod = 'exact';                        % Region of Influence compuation method:
                                                % 'exact':    Exact limits
                                                % 'gradient': Gradient-based limits                                                
conf.disp     = 1;                              % 1 to plot SRP-PHAT map. 0 to avoid plotting.
                                                % Inserts a pause of 0.01 s between iterations
                                                
% Microphone locations [m]                                             

conf.micpos   = [0, 0, 0.53, 0.53;
                0.01, 0.29, 0.29, 0.01;
                0, 0, 0, 0];                 

%% =================================
% Algorithm Initialization
% =================================
inistruct = msrpini(conf); 



if(s1.BytesAvailable > 0)
    fread(s1,s1.BytesAvailable);
end
arduino_out = [];
val = 0;
frame_num = 0;
last_strike_frame = 0;

disp('Can move now.')
tic
while (1)
    %here, if vibration detected, send to the func_touch_localization part to get the location of strike
    %if the user did not move in the following three frames, then process as a single strike
    %if the user move in the following three frames, then process as a slide
    frame_num = frame_num + 1;
    %deviceWriter(input);
    [acquiredAudio,numOverrun] = deviceReader();
    totalOverrun = totalOverrun + numOverrun;
    %delete the zeros
    if(total_mic+2>3)
        acquiredAudio(:,3) = [];
        acquiredAudio(:,3) = [];
    end
    fileWriter(acquiredAudio);
    %put into sound buffer
    sound_buffer(1,:,:) = sound_buffer(2,:,:);
    sound_buffer(2,:,:) = acquiredAudio(:,:);

%     while(s1.BytesAvailable > 0)
%         temp = fscanf(s1,'%f');
%         vector = upsample(temp,64);
%         arduino_out= [arduino_out;vector];
%     end
    if(s1.BytesAvailable > 0)
        temp = fread(s1,s1.BytesAvailable);
        str = char(temp)';
        val = str2num(str);
%         vector = upsample(val,64);
        arduino_out= [arduino_out val];
    end
    
    
    
    %if touchsound detected (should use vibration and sound to determine)
    
%     if(max(abs(filtfilt(digital_filter_5khz, acquiredAudio(:,1)))) > 0.2)
     %if(max(val)>10&&frame_num - last_strike_frame > 10)
     %testing out the point function with the phone in hand
     if(max(abs(sound_buffer(2,:,1)))>0.2&&frame_num - last_strike_frame > 10)
        %Calculate the movement distance in the following 10 frames
        %the number 10 is still in consideration
        disp('Strike detected')
        last_strike_frame = frame_num;
        %This term added because the vibration sensor has some delay
        %deviceWriter(input);
        [acquiredAudio,numOverrun] = deviceReader();
        if(total_mic+2>3)
            acquiredAudio(:,3) = [];
            acquiredAudio(:,3) = [];
        end
        sound_buffer(3,:,:) = acquiredAudio(:,:);
%         figure
%         for i = 1 :3
%             subplot(3,1,i)
%             plot(sound_buffer(i,:,1))
%         end
%         drawnow;
        detect_frame_num = 10;
        ir_matrix = [];
        
%         for i = 1:detect_frame_num
%             numUnderrun = deviceWriter(input);
%             [acquiredAudio,numOverrun] = deviceReader();
%             if(total_mic+2>3)
%                 acquiredAudio(:,3) = [];
%                 acquiredAudio(:,3) = [];
%             end
%             fileWriter(acquiredAudio);
%             totalOverrun = totalOverrun + numOverrun;
%             totalUnderrun = totalUnderrun + numUnderrun;
%             cir = func_calCIR(acquiredAudio, fs, f_carrier, digital_filter, b_upsample_shifted);
%             %put all the cir inteo a single matrix
%             ir_matrix = cat(3, ir_matrix, cir);
%         end
%         %Use the last several frames or not?
%         [motion_flag, distance_change] = func_calDisChange(ir_matrix(:,:,2:end));
%         if(max(abs(motion_flag)) == 0)
        if(1)
            disp('point');
            strike_sound = cat(1,squeeze(sound_buffer(1,:,:)),squeeze(sound_buffer(2,:,:)),squeeze(sound_buffer(3,:,:)));
            sound_buffer(2,:,:) = 0;
           %% =================================
            % Estimate Locations
            % =================================
            strike_sound = filtfilt(digital_filter_20khz,strike_sound);
            pos = msrploc_capstone(strike_sound,conf,inistruct)
            %             pos = func_soundLocalization(strike_sound, fs, digital_filter_20khz,digital_filter_5khz)
            write_click(round((pos(1)*100)/53*1920), round((30-pos(2)*100)/30*1080));
            %             pos_dispersion = func_soundLocalization(squeeze(sound_buffer(2,:,:))');
        else
            disp('slide');
            direction = zeros(2,1); %up/down left/right
            direction = direction + [motion_flag(1);-motion_flag(1)]...
                +[motion_flag(2);-motion_flag(2)]...
                +[motion_flag(3);motion_flag(3)]...
                +[motion_flag(4);motion_flag(4)]
%             break;
        end
    else
        %align the sequence to be cross correlated
%         b_upsample_shifted = func_sync(acquiredAudio, fs, f_carrier, b_upsampled, digital_filter);
    end

    %calculate the pos here

    

    %cal distance change
    %if(frame_num>2)
    %    [dis_change, peak_pos] = func_calRelativeDis(sound_buffer, fs, f_carrier, digital_filter, b_upsample_shifted)
    %end
end
toc
disp('Stop it!')



release(deviceReader);
release(deviceWriter);
release(fileReader);
release(fileWriter);

%%close arduino
fclose(s1);
delete(s1);
clear s1;
if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end

figure
 [a, fs] = audioread('../audio_files/matlab_asio_recorded_20k.wav');
 subplot(2,1,1)
 plot(a(:,1)*40)
subplot(2,1,2)
 plot(arduino_out)
 
