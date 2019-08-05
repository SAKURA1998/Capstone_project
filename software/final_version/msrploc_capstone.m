function s_est = msrploc_capstone(sound,conf,inistruct)
%MSRPLOC Estimates the location of an acoustic source by using the Modified
%SRP-PHAT algorithm.
% Inputs:
%      SOUND:       Input multichannel audio matrix.
%      CONF:       Configuration structure containing
%       CONF.wlen           Window length [samples]
%       CONF.timestep       Time step (hop size) [samples]    
%       CONF.c              Speed of sound [m/s]
%       CONF.xyz            1x6 array indicating XYZ search space limits [m]
%                           Example: CONF.xyz = [0 4 0 6 0.5 0.5] indicates
%                           a search space at plane z=0.5, from x=0 to x=4
%                           and from y=0 to y=6.                          
%       CONF.cres           Coarse spatial resolution [m]
%       CONF.fs             Sampling frequency
%       CONF.RImethod       Region of Influence compuation method:
%                            'exact':    Exact limits
%                            'gradient': Gradient-based limits   
%       CONF.disp           1 to plot SRP-PHAT map. 0 to avoid plotting.
%       CONF.micpos         3xN matrix indicating microphone locations.
%                           Each column specifies the (x,y,z) location of a sensor.
%     INISTRUCT:    Initialized structure needed for GETMSRP containing
%      INISTRUCT.cgridx    x locations of search grid
%      INISTRUCT.cgridy    y locations of search grid
%      INISTRUCT.pairs     NPx2 matrix, where each row specifies the
%                          indices of the NP microphone pairs.
%      INISTRUCT.cTDM      TDOA matrix
%      INISTRUCT.RI        Region of influence of each grid point 
%
%
% Outputs:
%      S_EST:   Estimated source location at each time frame.
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


    %-------------------------------------------------
    % Read audio file
    %-------------------------------------------------
    x = sound;       

    %-------------------------------------------------
    % Check configuration
    %-------------------------------------------------
    Nm = size(x,2); 
    if Nm~=size(conf.micpos,2)
        error('Number of audio channels does not match number of mic positions');
    end

    fs = conf.fs;
%     if fs~=conf.fs
%         error('Sampling frequency of audio file does not match configuration');
%     end

    %-------------------------------------------------
    % Get coarse grid locations
    %-------------------------------------------------
    Ny = inistruct.shape(1);
    Nx = inistruct.shape(2);
    xp = inistruct.cgridx(1:Ny:end);
    yp = inistruct.cgridy(1:Ny);
    
    
    T = length(x);                                          % Time-length
    nframes = ceil((T-conf.wlen+1)/conf.timestep);          % Number of frames
    awin = repmat(hanning(conf.wlen),1,Nm);                 % Window  
    s_est = zeros(nframes,2);                               % Memory allocation for output
                   
    
    %-------------------------------------------------
    % Frame by frame processing
    %-------------------------------------------------   
    for ni = 1:nframes
        
        fprintf('.')        
        sind = ((ni-1)*conf.timestep)+1;                    % Start window index
        %add a judgement here
        xn = x(sind:(sind+conf.wlen-1),:).*awin;            % Get frame of input data
        
        %-------------------------------------------------
        % Update GCCs and SRP
        %-------------------------------------------------
        GCCmat = msrpgcc(xn,inistruct.pairs,fs);
        SRPt   = getmsrp(GCCmat,conf,inistruct);
        
        if conf.disp == 1                                   % Display
            if ni==1
                fh = imagesc(xp,yp,reshape(SRPt,Ny,Nx));  colorbar; axis equal;
                set(gca,'YDir','normal');
                hold on, plot(conf.micpos(1,:),conf.micpos(2,:),'oy','linewidth',2);
                xlabel('x [m]'); ylabel('y [m]');
                axis(conf.xyz(1:4));
            else
                set(fh,'CData',reshape(SRPt,Ny,Nx));
            end
            drawnow;
        end
        
        %-------------------------------------------------
        % Get maximum value as estimated source location
        %-------------------------------------------------
        [~,maxp] = max(SRPt);
        
        s_est(ni,:) = [inistruct.cgridx(maxp) inistruct.cgridy(maxp)];
    end
    
end

