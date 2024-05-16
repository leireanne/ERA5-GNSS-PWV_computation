% Load ERA5 data and compute weighted mean temperature and Precipitable
% Water Vapor.
% Leire Anne Retegui Schiettekatte. AAU Geodesy, 2023.
%_____________________________________________________________________

%% Input data: filenames.
% Insert filenames of source data.
input_fn.dir                = 'Data_input/01_ERA5_z_temp_humid/';
input_fn.Geopotential       = 'ERA5_Geopotential_hourly_2015_2015_Lat_35.00_40.50_Lon_-7.50_-0.75_Lev_600_1000.mat';
input_fn.Specific_humidity  = 'ERA5_Specific_humidity_hourly_2015_2015_Lat_35.00_40.50_Lon_-7.50_-0.75_Lev_600_1000.mat';
input_fn.Temperature        = 'ERA5_Temperature_hourly_2015_2015_Lat_35.00_40.50_Lon_-7.50_-0.75_Lev_600_1000.mat';
% Insert filenames for output data.
output_fn.dir = 'Data_Output/01_ERA5_interpolated_integrated_variables/';
output_fn.Pressure  = 'STATIONS_ERA5_Pressure_hourly_2015_2015.mat';
output_fn.Tm        = 'STATIONS_ERA5_Tm_hourly_2015_2015.mat';
output_fn.PWV       = 'STATIONS_ERA5_PWV_hourly_2015_2015.mat';

% Other.
load('Data_Input\01_GNSS_station_info/geodetic_data.mat')
load('Data_Input\01_GNSS_station_info/geoid_undulation_EGM08_REDNAP.mat')

% Omit Tiou and EPCU because out of our ERA5 data coverage.
geod_list(41,:) = []; %TIOU
sta_list_geod(41,:) = [];
geod_list(16,:) = []; %EPCU
sta_list_geod(16,:) = [];

%% Computations
% Add all functions and old scripts to available directories
addpath(genpath('Functions'));
addpath(genpath('Original_scripts_writen_in_2022'));

for i=1:size(geod_list,1)
    fprintf('Starting with station number %d. \n',i)
    lat(i) = rad2deg(geod_list(i,1));
    lon(i) = rad2deg(geod_list(i,2));
    h_orto(i) = ERA_LEVEL.elips2ortometricHeight(lat(i),lon(i),geod_list(i,3));
    [p(:,i),PWV(:,i),Tm(:,i)] = FUNC_interpolate_integrate_atmosphere(lat(i),lon(i),h_orto(i),input_fn);
end

plot(h_orto,mean(PWV,1),'o'); title('PWV vs. altitude');
xlabel('Ortometric altitude (m)'); ylabel('Mean PWV(mm)');
ylim([-5 25])

figure;
plot(h_orto,mean(Tm,1)-273.15,'o'); title ('Mean temperature vs. altitude');
xlabel('Ortometric altitude (m)'); ylabel('Mean atmospheric colum temperature T_m (K)');

%% Save results.
load([input_fn.dir input_fn.Geopotential]);
time = d4_time;
save([output_fn.dir output_fn.Pressure],'geod_list','sta_list_geod','time','p');
save([output_fn.dir output_fn.Tm],'geod_list','sta_list_geod','time','Tm')
save([output_fn.dir output_fn.PWV],'geod_list','sta_list_geod','time','PWV')


