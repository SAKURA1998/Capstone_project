function [ CSD, cRx ] = func_calcCSD( cur, alphaTau, alphaTime)
%% func_calcCSD
%% Input
% cur: data to be analyzed (row vector)
% alphaTau: parameter for deciding the size of frequency smoothing window
% alphaTime: parameter for derciding the size of time smoothing window

%% Output
% CSD: Cone-shaped distribution of cur
% cRx: auto-correlation matrix for computing CSD
% WVD: Wigner-Ville distribution of cur
% Rx: auto-correlation matrix for computing WVD

N = size(cur, 2);
mid = round(N/2);

tau = -(mid - 1):(mid - 1);
Rx = zeros(N, N); % row (y-axis): t, col (x-axis): tau
for cnt = 1:N
    curTau = tau(cnt + tau >= 1 & cnt + tau <= N & cnt - tau >= 1 & cnt - tau <= N);    
    Rx(cnt, rem(curTau + N, N) + 1) = cur(cnt + curTau) .* conj(cur(cnt - curTau));
end

if nargin == 1 || (alphaTau == 0 && alphaTime == 0)
    CSD = real(fft(Rx'));
    cRx = Rx;
else
    tau = [0:mid, (mid + 1:N - 1) - N];
    Kx = zeros(N, N);

    Ltau = floor(N / alphaTau);
    Ltau = Ltau + 1 - rem(Ltau, 2);
    Wtau = hanning(Ltau)'; %% Frequency smoothing window


    Ltime = floor(N / alphaTime);
    Ltime = Ltime + 1 - rem(Ltime, 2);
    Wtime = hanning(Ltime)'; %% Time smoothing window

    Wtau = [Wtau(floor(Ltau / 2) + 1:end), zeros(1, N - Ltau), Wtau(1:floor(Ltau / 2))];

    cRx = zeros(N, N);
    for cnt = 1:N
        if Wtau(cnt) > 0
            cRx(:, cnt) = Rx(:, cnt) * Wtau(cnt);
        end
    end

    for cnt = 1:N
        width = min(abs(tau(cnt)), floor(Ltime / 2));    
        curWin = Wtime(floor(Ltime / 2) + 1 + (-width:width));

        tmp = conv(cRx(:, cnt), curWin);
        cRx(:, cnt) = tmp((1:N) + width);
    end

    CSD = real(fft(cRx'));
end

end

