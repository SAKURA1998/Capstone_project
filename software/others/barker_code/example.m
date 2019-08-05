clear, clc, close all
% load an audio file
[a, fs] = audioread('../audio_files/matlab_asio_recorded_20k.wav');
x             = a(:,1);
len           = size(a, 1);
%im = 1:149184;                      %simulation for the doppler effect
%im = transpose(im);
%x(1:50000,1) = 0.01*sin(2*pi*17000*im(1:50000,1)/44100)+0.01*sin(2*pi*17050*im(1:50000,1)/44100);
%x(51000:end,1) = sin(2*pi*17050*im(51000:end,1)/44100);
% define analysis parameters
wlen = 4096*16;                        % window length (recomended to be power of 2)
hop = wlen/4;                       % hop size (recomended to be power of 2)
nfft = 4096*16;                        % number of fft points (recomended to be power of 2)
% perform STFT
win = hanning(wlen);
%win(win~=1)=1;
[S, f, t] = stft(x, win, hop, nfft, fs);
% calculate the coherent amplification of the window
C = sum(win)/wlen;
% take the amplitude of fft(x) and scale it, so not to be a
% function of the length of the window and its coherent amplification
S = abs(S)/wlen/C;
% correction of the DC & Nyquist component
if rem(nfft, 2)                     % odd nfft excludes Nyquist point
    S(2:end, :) = S(2:end, :).*2;
else                                % even nfft includes Nyquist point
    S(2:end-1, :) = S(2:end-1, :).*2;
end
% convert amplitude spectrum to dB (min = -120 dB)
S = 20*log10(S + 1e-6);

%S(S<-70)=-120;
% plot the spectrogram
M = S;
max_value = max(max(M));
[rol,col] = find(max_value==M);
figure(1)
surf(t, f, S)
shading interp
axis tight
view(0, 90)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Frequency, Hz')
title('Amplitude spectrogram of the signal')
hcol = colorbar;
set(hcol, 'FontName', 'Times New Roman', 'FontSize', 14)
ylabel(hcol, 'Magnitude, dB')