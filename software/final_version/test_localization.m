%% =================================
% Algorithm Configuation Parameters for M-SRP
% =================================

conf.wlen     = 3072;                           % Window length [samples]
conf.timestep = 3072;                           % Time step (hop size) [samples]    
conf.c        = 345;                            % Speed of sound [m/s]
conf.xyz      = [0, 0.53, 0, 0.30, -0.01, 0.01];         % xyz search space limits [m]: [xmin,xmax,ymin,ymax,zmin,zmax]
conf.cres     = 0.005;                           % Spatial grid resolution [m]
conf.fs       = 48000;                          % Sampling frequency [Hz]
conf.RImethod = 'exact';                        % Region of Influence compuation method:
                                                % 'exact':    Exact limits
                                                % 'gradient': Gradient-based limits                                                
conf.disp     = 1;                              % 1 to plot SRP-PHAT map. 0 to avoid plotting.
                                                % Inserts a pause of 0.01 s between iterations
                                                
% Microphone locations [m]                                             

conf.micpos   = [0, 0, 0.53, 0.53;
                0.01, 0.29, 0.29, 0.01;
                0, 0, 0, 0];                 

%% =================================
% Algorithm Initialization
% =================================
inistruct = msrpini(conf); 

simulated_pos = [0.1, 0.2, 0.3 ,0.4, 0.45;
				0.1, 0.1, 0.1 ,0.1, 0.1];

simulated_sound_orig = zeros(conf.wlen,4);
simulated_sound_orig(conf.wlen/4:conf.wlen*3/4,:) = 1;
for point_num = 1:size(simulated_pos, 2)
	simulated_sound = simulated_sound_orig;
	for mic_num = 2:4
		dis_diff = norm((simulated_pos(1,point_num)-conf.micpos(1,mic_num))^2 + (simulated_pos(2,point_num)-conf.micpos(2,mic_num))^2)...
				- norm((simulated_pos(1,point_num)-conf.micpos(1,1))^2 + (simulated_pos(2,point_num)-conf.micpos(2,1))^2) ;
		simulated_sound(:,mic_num) = circshift(simulated_sound(:,1),round(dis_diff/340*48000));
	end
	pos = msrploc_capstone(simulated_sound,conf,inistruct)
end