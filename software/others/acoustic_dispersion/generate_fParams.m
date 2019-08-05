%generate the band pass butter filter bank under 48000 kHz, with the order
%of 3

load('stylus_global_params.mat', 'globalParams');
%Change the pinoutlow fParams
fParams = globalParams.pinpoint.low.filter;
fs = globalParams.mic.rate;
a_low = zeros(size(fParams.freq, 2),7);
b_low = zeros(size(fParams.freq, 2),7);

for cnt = 1:size(fParams.freq, 2)
    fnorm1 = [(fParams.freq(1,cnt) - 50) (fParams.freq(1,cnt) + 50)]/fs*2;
    [b,a] = butter(3,fnorm1);
    a_low(cnt,:) = a;
    b_low(cnt,:) = b;
end

globalParams.pinpoint.low.filter.a = a_low;
globalParams.pinpoint.low.filter.b = b_low;

%Change the detect fParams
[b, a] = butter(6, 5000/fs * 2, 'high');
globalParams.detect.filter.a = a;
globalParams.detect.filter.b = b;

%Change the pinouthigh window func
globalParams.pinpoint.high.win = hanning(globalParams.pinpoint.high.size)';

save('stylus_global_params.mat', 'globalParams')