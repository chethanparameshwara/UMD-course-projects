%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%> @file settings.m
%>
%> @brief Functions for setting all the parameters in the zero-velocity 
%> aided inertial navigation system framework, as well as loading the IMU
%> data.
%>
%> @authors Isaac Skog, John-Olof Nilsson
%> @copyright Copyright (c) 2011 OpenShoe, ISC License (open source)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% MAIN FUNCTION


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  funtion u=settings() 
%
%> @brief Function that controls all the settings for the zero-velocity 
%> aided inertial navigation system.     
%>
%> @param[out]  u      Matrix with IMU data. Each column corresponds to one
%> sample instant. The data in each column is arranged as x, y, and z axis
%> specfic force components; x, y, and z axis angular rates.
%> 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u t]=settings(filename)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              GENERAL PARAMETERS         %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global simdata;

% Rough altitude [m] 
simdata.altitude=0;

% Rough latitude [degrees]
simdata.latitude=0;

% Magnitude of the local gravity vector [m/s^2]
simdata.g=gravity(simdata.latitude,simdata.altitude);

% Sampling period [s]
simdata.Ts=1/250;

% Path to the folder where the IMU data file that should be processed is
% located.
% simdata.path='Measurement_100521_44\';

% Load the data
[u t]=load_dataset(filename);

% Initial heading [rad]
simdata.init_heading=0*pi/180;

% Initial position (x,y,z)-axis [m] 
simdata.init_pos=[0 0 0]';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           Detector Settings             %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Detector type to be used. You can chose between: 
% GLRT - Generalized likelihood ratio test
% MV -  Accelerometer measurements variance test
% MAG - Accelerometer measurements magnitude test
% ARE - Angular rate measurement energy test 
simdata.detector_type='GLRT';


% Standard deviation of the acceleromter noise [m/s^2]. This is used to 
% control the zero-velocity detectors trust in the accelerometer data.
simdata.sigma_a=0.01; 

% Standard deviation of the gyroscope noise [rad/s]. This is used to 
% control the zero-velocity detectors trust in the gyroscope data.
simdata.sigma_g=0.1*pi/180;     


% Window size of the zero-velocity detector [samples] 
simdata.Window_size=3;

% Threshold used in the zero-velocity detector. If the test statistics are 
% below this value the zero-velocity hypothesis is chosen.  
simdata.gamma=0.3e5; 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%             FILTER PARAMETERS           %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% By defualt the filter uses a 9-state (position perturbation, velocity 
% perturbation, attitude perturbation) state-space model. If sensor biases
% and scale factors should be included in the state-space model. Set the
% follwing control variables to true.

% Variable controlling if the sensor biases should be included as states 
% in the state-space model.  
simdata.biases='on';

% Variable controlling if the sensor scale factor should be included as 
% states in the state-space model.
simdata.scalefactors='on';



% Settings for the process noise, measurement noise, and initial state 
% covariance matrices Q, R, and P. All three matices are assumed to be 
% diagonal matrices, and all settings are defined as standard deviations. 

% Process noise for modeling the accelerometer noise (x,y,z platform 
% coordinate axis) and other accelerometer errors [m/s^2].
simdata.sigma_acc =0.5*[1 1 1]';

% Process noise for modeling the gyroscope noise (x,y,z platform coordinate
% axis) and other gyroscope errors [rad/s].
simdata.sigma_gyro =0.5*[1 1 1]'*pi/180; % [rad/s]

% Process noise for modeling the drift in accelerometer biases (x,y,z 
% platform coordinate axis) [m/s^2].
simdata.acc_bias_driving_noise=0.0000001*ones(3,1); 

% Process noise for modeling the drift in gyroscope biases (x,y,z platform
% coordinate axis) [rad/s].
simdata.gyro_bias_driving_noise=0.0000001*pi/180*ones(3,1); 


% Pseudo zero-velocity update measurement noise covariance (R). The 
% covariance matrix is assumed diagonal.
simdata.sigma_vel=[0.01 0.01 0.01];      %[m/s] 

% Diagonal elements of the initial state covariance matrix (P).    
simdata.sigma_initial_pos=1e-5*ones(3,1);               % Position (x,y,z navigation coordinate axis) [m]
simdata.sigma_initial_vel=1e-5*ones(3,1);               % Velocity (x,y,z navigation coordinate axis) [m/s]
simdata.sigma_initial_att=(pi/180*[0.1 0.1 0.1]');      % Attitude (roll,pitch,heading) [rad]
simdata.sigma_initial_acc_bias=0.3*ones(3,1);           % Accelerometer biases (x,y,z platform coordinate axis)[m/s^2]
simdata.sigma_initial_gyro_bias=0.3*pi/180*ones(3,1);   % Gyroscope biases (x,y,z platform coordinate axis) [rad/s]                               
simdata.sigma_initial_acc_scale=0.0001*ones(3,1);       % Accelerometer scale factors (x,y,z platform coordinate axis)   
simdata.sigma_initial_gyro_scale=0.00001*ones(3,1);     % Gyroscope scale factors (x,y,z platform coordinate axis)    

% Bias instability time constants [seconds]. 
simdata.acc_bias_instability_time_constant_filter=inf;
simdata.gyro_bias_instability_time_constant_filter=inf;

end


%% SUBFUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  funtion g=gravity(lambda,h) 
%
%> @brief Function for calculating the magnitude of the local gravity. 
%>
%> @details Function for calculation of the local gravity vector based 
%> upon the WGS84 gravity model. 
%>
%> @param[out]  g          magnitude of the local gravity vector [m/s^2] 
%> @param[in]   lambda     latitude [degrees] 
%> @param[in]   h          altitude [m]  
%>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function g=gravity(lambda,h)

lambda=pi/180*lambda;
gamma=9.780327*(1+0.0053024*sin(lambda)^2-0.0000058*sin(2*lambda)^2);
g=gamma-((3.0877e-6)-(0.004e-6)*sin(lambda)^2)*h+(0.072e-12)*h^2;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  funtion  u = load_dataset( str_path ) 
%
%> @brief Function that loads the IMU data set stored in the specfied 
%> folder. 
%>
%> @details Function that loads the IMU data set stored in the specfied 
%> folder. The file should be named ''data_inert.txt''. The data is scaled
%> to SI-units. 
%>
%> @param[out]  u          Matrix of IMU data. Each column corresponed to
%> the IMU data sampled at one time instant.    
%>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u t]=load_dataset(filename)


global simdata;

% Load inertial data
% data_inert_file = fopen( 'Measurement_100521_44/data_inert.txt', 'r');
% 
% % Read through the file header
% fscanf(data_inert_file, '%s', [1 32]);
% 
% % Load the data set
% data_inert = fscanf(data_inert_file, '%x  %f %f %f  %f %f %f  %i %x  %i  %f %f %f  %f  %f %f %f', [17 inf])';
% 
% % Close the file
% fclose(data_inert_file); clear data_inert_file;
% 

% Scale the data to SI-units and store the data in a matrix. 
[t,ax,ay,az,temperature,gx,gy,gz,data] = getIMUSamplesDavis(filename,10e7)

imu_scalefactor = 9.80665; %From the Microstrain IMU data sheet
% f_imu         = data_inert(:,2:4)' * imu_scalefactor;
% omega_imu     = data_inert(:,5:7)';
f_imu = [az ay ax]'.* imu_scalefactor;
omega_imu = [gx gy gz]'.*pi/180;
u=[f_imu; omega_imu];

end

