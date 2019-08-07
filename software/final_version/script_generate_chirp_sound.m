clear all;
close all;

%Some predefined value
samplePerFrame = 1024;
bandwidth_lowpass = 4000;   %Hz
sample_rate = 48000;		%Hz
frame_time = samplePerFrame/48000;				%s
total_frame = 8000;
f_carrier=20000;			%%Frequency of the carrier fc in Hz

%Nb is the number of bits to be transmitted
T=1;%Bit rate is assumed to be 1 bit/s;
%bits to be transmitted
b=[1 1 1 1 1];
%Rb is the bit rate in bits/second
 
%% Convert the sequence to baseband signal
NRZ_out=[];
RZ_out=[];
Manchester_out=[];
  
%Vp is the peak voltage +v of the NRZ waveform
Vp=4;
%Here we encode input bitstream as Bipolar NRZ-L waveform
for index=1:size(b,2)
 if b(index)==1
 NRZ_out=[NRZ_out ones(1,1)*Vp];
 elseif b(index)==0
 NRZ_out=[NRZ_out ones(1,1)*(-Vp)];
 end
end

%Do zero padding to upsample the sequence in baseband
%fs = 48 kHz, Bandwidth = 4 kHz (18 kHz - 22 kHz), fs/B = 12
%NRZ_out = upsample(NRZ_out,12);          %TODO upsample or interplot??
NRZ_out = ones(1,size(b,2)*12);

%Padding with zero to form a single not 12.5ms frame, but 1024 sample point
%per frame to speed up
NRZ_out = [zeros(1,3*12) NRZ_out  zeros(1,samplePerFrame - 12*(3+size(b,2)))];




%Perform low pass filtering
Baseband_signal = lowpass(NRZ_out, bandwidth_lowpass/2, sample_rate);
%baseband_signal_downsample = resample(baseband_real, 1, 12, 10);
%baseband_signal_downsample_single_frame = baseband_signal_downsample(1:50,1);

 
%Generated bit stream impulses
figure(1);
stem(b);
xlabel('Time (seconds)-->')
ylabel('Amplitude (volts)-->')
title('Impulses of bits to be transmitted');
figure(2);
plot(Baseband_signal);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('Generated NRZ signal');

%% Convert the baseband signal into passband signal
t=frame_time/size(Baseband_signal,2):frame_time/size(Baseband_signal,2):frame_time;


%Here we generate the modulated signal by multiplying it with 
%carrier (basis function)
Modulated=Baseband_signal.*(sqrt(2)*cos(2*pi*f_carrier*t));
plot(Modulated);
Modulated = repmat(Modulated,1,total_frame);
%Perform bandpass filtering
Passband_signal = bandpass(Modulated,[f_carrier - bandwidth_lowpass/2, f_carrier + bandwidth_lowpass/2], sample_rate);
%Repeat for two seconds


figure;
plot(Passband_signal);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('BPSK Modulated signal');
%Write into a wav file
audiowrite('../audio_files/audio_20k_1024samplesPerFrame_1min.wav', Passband_signal, sample_rate, 'BitsPerSample', 16);

 