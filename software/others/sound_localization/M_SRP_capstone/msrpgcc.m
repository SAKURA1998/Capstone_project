function [GCCmat] = msrpgcc(xn,pairs,fs)
%MSRPGCC Computes the Generalized-Cross Correlation for the input signals
% XN taking into account the specified signal pairs in PAIRS. The GCC
% filters the input signals to avoid undesired frequency components out of
% the usual speech range 80 Hz - 5000 Hz.
% Inputs:
%      XN:       NxM signal matrix, where N is the windowed signal length
%                and M the number of microphones.
%      PAIRS:    NPx2 matrix, where each row specifies the indices of the
%                microphones to be considered at each of the NP pairs.
%      FS:       Sampling frequency.
%
% Outputs:
%      GCCMAT:   NxNP matrix, where each column contains the GCC of the
%                corresponding microphone pair.
%
%
% References:
%     - M. Cobos, A. Marti and J.J. Lopez, "A Modified SRP-PHAT Functional
%       for Robust Real-Time Sound Source Localization with Scalable
%       Spatial Sampling", in IEEE Signal Processing Letters, vol.18, no.1,
%       pp.71-74, 2011.
%
%
% Version:          1.1.20141027
%
% History:
%     1.1.20141027  Initial Version
%
% Copyright (C) 2014 Maximo Cobos


    N = length(xn);  
    Np = size(pairs,1);                     % Microphone pairs

  
    %--------------------------------------------------------------------------
    % Rough Speech-band filtering
    %--------------------------------------------------------------------------
    fc_l = 0;                               % low frequency limit (in Hz)
    fc_h = 20000;                           % high frequency limit (in Hz)
    fc_li = round((N*fc_l/fs)) + 1;         % index in fft
    fc_hi = round((N*fc_h/fs)) + 1;         % index in fft
    Mask = zeros(N,1);                      % Mask applied over input signals
    Lm = length(fc_li:fc_hi);   
    %Mask(fc_li:fc_hi)=1;
    %Mask(N-fc_hi:N-fc_li)=1;
    Mask(fc_li:fc_hi)=hamming(Lm);
    Mask(N-fc_hi:N-fc_li)=hamming(Lm);
    
    %--------------------------------------------------------------------------
    % GCC-PHAT 
    %--------------------------------------------------------------------------
    tf = fft(xn);                                   % DFT of input signals    
    GCCmat = zeros(N,Np);
    for p=1:Np
        m=pairs(p,1);
        n=pairs(p,2);
        GCC = tf(:,m).*conj(tf(:,n));               % Cross-power Spectral Density
        GCC = exp(1i*angle(GCC));                   % Normalize magnitude (PHAT)
        GCC = GCC.*Mask;                            % Eliminate undesired frequency components
        GCC = fftshift(real(ifft(GCC)));        
        GCCmat(:,p) = GCC;
    end        
%     plot(GCCmat)
%     pause
     GCCmat = (GCCmat.*(GCCmat>0));                  % Consider only positive peaks
end