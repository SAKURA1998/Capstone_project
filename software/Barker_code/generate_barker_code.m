%This file generates the 13-bit barker training sequence for channel estimation and convert it into wav file
%Details are the same as described in Strata: Fine-Grained Acoustic-based Device-Free Tracking

%13 bit barker code: 	[+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]
%http://drmoazzam.com/matlab-code-bpsk-modulation-and-demodulation-with-explanation/
clear all;
close all;

%Some predefined value
bandwidth_lowpass = 4000;   %Hz
sample_rate = 48000;		%Hz
frame_time = 1024/48000;				%s
total_frame = 160;
f_carrier=20000;			%%Frequency of the carrier fc in Hz

%Nb is the number of bits to be transmitted
T=1;%Bit rate is assumed to be 1 bit/s;
%bits to be transmitted
b=[1 1 1 1 1 0 0 1 1 0 1 0 1];
%Rb is the bit rate in bits/second
 
%% Convert the sequence to baseband signal
NRZ_out=[];
RZ_out=[];
Manchester_out=[];
  
%Vp is the peak voltage +v of the NRZ waveform
Vp=2;
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
NRZ_out = upsample(NRZ_out,12);          %TODO upsample or interplot??

%Padding with zero to form a single not 12.5ms frame, but 1024 sample point
%per frame to speed up
NRZ_out = [zeros(1,12*(50-13-18) + 1024 - 600) NRZ_out  zeros(1,12* 18)];




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
%Perform bandpass filtering
Passband_signal = bandpass(Modulated,[f_carrier - bandwidth_lowpass/2, f_carrier + bandwidth_lowpass/2], sample_rate);
%Repeat for two seconds
Passband_signal = repmat(Passband_signal,1,total_frame);

figure;
plot(Passband_signal);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('BPSK Modulated signal');
%Write into a wav file
audiowrite('../audio_files/audio_barker_20k.wav', Passband_signal, sample_rate, 'BitsPerSample', 16);


%%Demodulate
y=[];
%We begin demodulation by multiplying the received signal again with 
%the carrier (basis function)

% signal_real   = sqrt(2)*cos(2 * pi * f_carrier * t);
% signal_img    = sqrt(2)*sin(2 * pi * f_carrier * t);
% result_real   = Passband_signal .* signal_real;
% baseband_real = lowpass(result_real, 2000, sample_rate);
% result_img    = Passband_signal .* signal_img;
% baseband_img  = lowpass(result_img, 2000, sample_rate);
% baseband_real = resample(baseband_real, 1, 12, 5, 10);
% baseband_img = resample(baseband_img, 1, 12, 5, 10);
% 
% baseband_signal = baseband_real - 1i*baseband_img;
% 
% plot(baseband_signal, 'o');
% %Here we perform the integration over time period T using trapz 
% %Integrator is an important part of correlator receiver used here
% for i=1:12:size(demodulated,2)
%  y=[y trapz(t(i:i+11),demodulated(i:i+11))];
% end
% received=y>0;
% figure;
% plot(y)
% title('Impulses of Received bits');
% xlabel('Time (seconds)-->');
% ylabel('Amplitude (volts)')
 