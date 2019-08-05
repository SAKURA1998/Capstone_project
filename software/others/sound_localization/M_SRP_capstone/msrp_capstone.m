clear all;

%=========================================================================
% MODIFIED SRP-PHAT
% Script Example
% Copyright "Maximo Cobos"
%
% Reference:
% M. Cobos, A. Marti and J. J. Lopez, "A Modified SRP-PHAT Functional for
% Robust Real-Time Sound Source Localization with Scalable Spatial
% Sampling," in IEEE Signal Process. Letters, vol.18, no.1, pp.71-74, 2011.
% =========================================================================

%% =================================
% Algorithm Configuation Parameters
% =================================

conf.wlen     = 2048;                           % Window length [samples]
conf.timestep = 2048;                           % Time step (hop size) [samples]    
conf.c        = 345;                            % Speed of sound [m/s]
conf.xyz      = [0, 0.47, 0, 0.24, -0.01, 0.01];         % xyz search space limits [m]: [xmin,xmax,ymin,ymax,zmin,zmax]
conf.cres     = 0.005;                           % Spatial grid resolution [m]
conf.fs       = 48000;                          % Sampling frequency [Hz]
conf.RImethod = 'exact';                        % Region of Influence compuation method:
                                                % 'exact':    Exact limits
                                                % 'gradient': Gradient-based limits                                                
conf.disp     = 1;                              % 1 to plot SRP-PHAT map. 0 to avoid plotting.
                                                % Inserts a pause of 0.01 s between iterations
                                                
% Microphone locations [m]                                             

conf.micpos   = [0, 0, 0.47, 0.47;
                0, 0.24, 0.24, 0;
                0, 0, 0, 0];

% conf.micpos   = [0.03, 0.265, 0.5, 0.265;
%                 0.15, 0.27, 0.15, 0.03;
%                 0, 0, 0, 0];


% Exampe audio file: true source location at x = 1.4 y = 2.5 z = 0.5;
file = '../../audio_files/extracted_sound.wav';                     

%% =================================
% Algorithm Initialization
% =================================
inistruct = msrpini(conf); 


%% =================================
% Estimate Locations
% =================================
s_est = msrploc(file,conf,inistruct);
plot(s_est(:,1),s_est(:,2) ,'-o','MarkerSize', 4)