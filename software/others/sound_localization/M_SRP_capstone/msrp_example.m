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

conf.wlen     = 4096;                           % Window length [samples]
conf.timestep = 2048;                           % Time step (hop size) [samples]    
conf.c        = 345;                            % Speed of sound [m/s]
conf.xyz      = [0, 4, 0, 6, 0.5, 0.5];         % xyz search space limits [m]: [xmin,xmax,ymin,ymax,zmin,zmax]
conf.cres     = 0.15;                           % Spatial grid resolution [m]
conf.fs       = 44100;                          % Sampling frequency [Hz]
conf.RImethod = 'exact';                        % Region of Influence compuation method:
                                                % 'exact':    Exact limits
                                                % 'gradient': Gradient-based limits                                                
conf.disp     = 1;                              % 1 to plot SRP-PHAT map. 0 to avoid plotting.
                                                % Inserts a pause of 0.01 s between iterations
                                                
% Microphone locations [m]                                             

conf.micpos   = [0.01, 0.01, 0.01, 3.99, 3.99, 3.99;
                 0.01, 3.00, 5.99, 0.01, 3.00, 5.99;
                 0.50, 0.50, 0.50, 0.50, 0.50, 0.50];

% Exampe audio file: true source location at x = 1.4 y = 2.5 z = 0.5;
file = 'locexample2.wav';                     

%% =================================
% Algorithm Initialization
% =================================
inistruct = msrpini(conf); 


%% =================================
% Estimate Locations
% =================================
s_est = msrploc(file,conf,inistruct);