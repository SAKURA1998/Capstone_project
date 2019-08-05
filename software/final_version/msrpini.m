function inistruct = msrpini(conf)
%MSRPINI Initializes the Modified SRP-PHAT localization algorithm to be
%used by GETMSRP.
% Inputs:
%     CONF:       Configuration structure containing
%      CONF.wlen           Window length [samples]
%      CONF.timestep       Time step (hop size) [samples]    
%      CONF.c              Speed of sound [m/s]
%      CONF.xyz            1x6 array indicating XYZ search space limits [m]
%                          Example: CONF.xyz = [0 4 0 6 0.5 0.5] indicates
%                          a search space at plane z=0.5, from x=0 to x=4
%                          and from y=0 to y=6.
%                           
%      CONF.cres           Coarse spatial resolution [m]
%      CONF.fs             Sampling frequency
%      CONF.RImethod       Region of Influence compuation method:
%                            'exact':    Exact limits
%                            'gradient': Gradient-based limits    
%      CONF.disp           1 to plot SRP-PHAT map. 0 to avoid plotting.
%      CONF.micpos         3xN matrix indicating microphone locations.
%                          Each column specifies de (x,y,z) location of a sensor.
%
% Outputs:
%     INISTRUCT:    Initialized structure needed for GETMSRP containing
%      INISTRUCT.cgridx    x locations of search grid
%      INISTRUCT.cgridy    y locations of search grid
%      INISTRUCT.pairs     NPx2 matrix, where each row specifies the
%                          indices of the NP microphone pairs.
%      INISTRUCT.cTDM      TDOA matrix
%      INISTRUCT.RI        Region of influence of each grid point 
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


    %-------------------------------------------------
    % Microphone pairs
    %-------------------------------------------------

    Nm = size(conf.micpos,2);                           % Number of microphones     
    pairs = nchoosek(1:Nm,2);                           % Microphone pairs
    Np = length(pairs);

    %-------------------------------------------------
    % Create coarse grid
    %-------------------------------------------------
    
    px = conf.xyz(1)+conf.cres/2:conf.cres:conf.xyz(2)-conf.cres/2;              
    py = conf.xyz(3)+conf.cres/2:conf.cres:conf.xyz(4)-conf.cres/2;
    [cgridx,cgridy] = meshgrid(px,py);
    [Ny,Nx] = size(cgridx);
    cgridx = cgridx(:);
    cgridy = cgridy(:);
    Nxy = length(cgridx);
    

    %-------------------------------------------------
    % Distances from each grid point to microphones
    %-------------------------------------------------

    cDM = zeros(Nxy,Nm);
    for m=1:Nm
        cDM(:,m) = sqrt((cgridx-conf.micpos(1,m)).^2 + (cgridy-conf.micpos(2,m)).^2);
    end
    
    %-------------------------------------------------
    % TDOA Matrix
    %-------------------------------------------------
    
    cTDM = zeros(Nxy,Np);                           
    for p=1:Np 
        m = pairs(p,1);
        n = pairs(p,2);
        cTDM(:,p) = round((conf.fs/conf.c)*(cDM(:,m)-cDM(:,n))); 
    end
    
    %-------------------------------------------------
    % Region of Influence Limits
    %-------------------------------------------------

    switch conf.RImethod
    
        case 'gradient'            
        %-------------------------------------------------
        % Compute Gradient-Based Limits
        %-------------------------------------------------
    
        RI = zeros(Nxy,Np);
        for p=1:Np
            m=pairs(p,1);
            n=pairs(p,2);
            Gradx  = conf.fs*(1/conf.c) * ((cgridx - conf.micpos(1,n))./cDM(:,n)  -  (cgridx - conf.micpos(1,m))./cDM(:,m) );
            Grady  = conf.fs*(1/conf.c) * ((cgridy - conf.micpos(2,n))./cDM(:,n)  -  (cgridy - conf.micpos(2,m))./cDM(:,m) );
            Gradphi = atan2(Grady,Gradx);
            Gradphic(:,1) = abs(1./cos(Gradphi));
            Gradphic(:,2) = abs(1./sin(Gradphi));
            Gradphi = min(Gradphic,[],2);
            RI(:,p) = round((conf.cres/2)*sqrt(Gradx.^2 + Grady.^2).*Gradphi);
        end
    
        case 'exact'
        %-------------------------------------------------
        % Fine-grid Based Limits
        %-------------------------------------------------
        RI = cell(1,2);
        RI{1} = zeros(Ny,Nx,Np);
        RI{2} = zeros(Ny,Nx,Np);
        r  = conf.c/conf.fs;
        rpx = conf.xyz(1):r:conf.xyz(2);              
        rpy = conf.xyz(3):r:conf.xyz(4);
        [PX,PY] = meshgrid(rpx,rpy);
        [NY,NX] = size(PX);
        rDM = zeros(NY,NX,Nm);                             
        for m=1:Nm
            rDM(:,:,m) = sqrt((PX-conf.micpos(1,m)).^2 + (PY-conf.micpos(2,m)).^2);
        end
        rTDM = zeros(NY,NX,Np);                           
        for p=1:Np 
            m = pairs(p,1);
            n = pairs(p,2);
            rTDM(:,:,p) = round((conf.fs/conf.c)*(rDM(:,:,m)-rDM(:,:,n))); 
        end    
        for p=1:Np
            for nx=1:Nx
                for ny=1:Ny
                    limx1 = -rpx(1) + px(nx) - conf.cres/2;
                    limx2 = -rpx(1) + px(nx) + conf.cres/2;
                    limy1 = -rpy(1) + py(ny) - conf.cres/2;
                    limy2 = -rpy(1) + py(ny) + conf.cres/2;
                    limx1 = max(round(limx1/r),1);
                    limx2 = min(round(limx2/r),NX);
                    limy1 = max(round(limy1/r),1);
                    limy2 = min(round(limy2/r),NY);
                    chunk = rTDM(limy1:limy2,limx1:limx2,p);
                    RI{1}(ny,nx,p) = min(chunk(:));
                    RI{2}(ny,nx,p) = max(chunk(:));
                end
            end
        end 
        RI1 = reshape(RI{1},Nxy,Np);
        RI2 = reshape(RI{2},Nxy,Np);
        clear RI;
        RI(:,:,1) = RI1;
        RI(:,:,2) = RI2;
 
        
        case 'conventional'
            RI = [];
    end
    
    %-------------------------------------------------
    % Returned Structure
    %-------------------------------------------------
    inistruct.cgridx = cgridx;
    inistruct.cgridy = cgridy;
    inistruct.shape  = [Ny, Nx];
    inistruct.pairs  = pairs;
    inistruct.cTDM   = cTDM;
    inistruct.RI     = RI;
end