function SRPt = getmsrp(GCCmat,conf,inistruct)
%GETMSRP Computes the Modified SRP-PHAT matrix from the GCCMAT matrix and
%the initialization structure INISTRUCT.
% Inputs:
%      GCCMAT:     NxNP matrix, where each column contains the GCC of the
%                  corresponding microphone pair.
%      CONF:       Configuration structure as used by MSRPINI.
%      INISTRUCT:  Initialized structure as computed by MSRPINI.
%
% Outputs:
%      SRPT:       Modified SRP-PHAT matrix.
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


    [N, Np] = size(GCCmat);
    Ny = inistruct.shape(1);
    Nx = inistruct.shape(2);

    %----------------------------------------------------------------------
    % Mean-Based Modified SRP-PHAT  
    %----------------------------------------------------------------------

    SRPt = zeros(Ny*Nx,1);
    len = zeros(Ny*Nx,Np);
    for p=1:Np
        Cp =GCCmat(:,p);  
        SRPp = zeros(Ny*Nx,1);
        for n = 1:Ny*Nx
            switch conf.RImethod
                case 'gradient'
                    lim1 = inistruct.cTDM(n,p)-inistruct.RI(n,p)+round(N/2) + 1;
                    lim2 = inistruct.cTDM(n,p)+inistruct.RI(n,p)+round(N/2) + 1;
                    chunk = Cp(lim1:lim2);            
                case 'exact'
                    lim1 = inistruct.RI(n,p,1)+round(N/2) + 1;
                    lim2 = inistruct.RI(n,p,2)+round(N/2) + 1;
                    chunk = Cp(lim1:lim2);
                case 'conventional'
                    chunk = Cp(inistruct.cTDM(n,p) + round(N/2) + 1);
            end
            SRPp(n)  = sum(chunk);
            len(n,p) = length(chunk);
        end
        SRPt = SRPt + SRPp;
    end
    SRPt = SRPt./mean(len,2);
       
end