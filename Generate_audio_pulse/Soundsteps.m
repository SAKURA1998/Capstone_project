%P=1
%t(P,1)=[90:0.01:450]'
clc
clear all
fs=input('Sampling frequency of sound? (khz)\n note;should be between 5-44 \n')*1000 ; %fs is the sampling frequency of the output sound in datapoint-per-second.default is 8192 Hz, or 8192 datapoint of sound in every second.(5k-44k)
ipseconds=input('Initial pause before sound sequence?(seconds)\n'); %initial pause in seconds
p0=1+(ipseconds*fs);  %p0 is the initial pause, has to be a minimum of 1(almost zero)
z0{1,1}(p0,1)=0;  %creating the column of zeros in the z0 cell
soundseconds=input('Length of sound step?(seconds)\n'); %the length of the sound pulse in seconds
dp=soundseconds*fs; %number of data points.
t(1:dp,1)=1 ; %this is the length of the signal step, in "data points"
A=input('What is the amplitude of the sound pulse?(should be between -1 to 1) \n'); %this is the amplitude
W={A*t};
pseconds=input('Pause after each sound step?(seconds) \n') ; %pause after each sound pulse in seconds
p=1+(pseconds*fs);  %this is the pause after each wave, has to be a minimum of 1(almost zero)
z{1,1}(p,1)=0;  %creating the column of zeros in the z cell.
T(1,1)={z0{1,1}};  %first cell in T is the zeros of z0
times=input('Repetition times of sound sequence?\n (sound sequence is step and pause after, not initial pause) \n');  %how many times the signal repeats
for i=1:2:(2*times)
    T(1+i,1)={W{1,1}}; %adding a row of W values
    T(2+i,1)={z{1,1}} ; %adding a row of zeros from z.
end
m=cell2mat(T);   %converting the rows of numbers(and zeros) in the cells above each other into a single column matrix, or vector.
plot(m)
input('Your sound wave has been compiled and graphed, hit enter to produce it','s');
%sound(m,fs);
audiowrite('audio_pulse.wav', m, fs);
%wavwrite(m,fs,'fs 20k-length 110s-2.5k dps')  %writes the sound into a .wav file in your default matlab folder. the last entry is the name of the file, change it to reflect the variables.
