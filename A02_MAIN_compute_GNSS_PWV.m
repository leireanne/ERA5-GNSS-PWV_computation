% Compute PWV values for the GNSS stations.
% Leire Retegui Schiettekatte.
%__________________________________________________
%% Input data: filenames.
% Insert filenames of meteorological data.
input_fn_ERA5.dir      = 'Data_Output/01_ERA5_interpolated_integrated_variables/';
input_fn_ERA5.Pressure = 'STATIONS_ERA5_Pressure_hourly_2015_2015.mat';
input_fn_ERA5.Tm       = 'STATIONS_ERA5_Tm_hourly_2015_2015.mat';
% Insert filenames of GNSS ZTD data.
input_fn_GNSS.dir       = 'Data_Input/02_GNSS_ZTD/';
input_fn_GNSS.ZTD       = 'STATIONS_GNSS_ERA5_ZTD_hourly_2015_01_01.mat';
% Insert filenames for output data.
output_fn.dir       = 'Data_Output/02_GNSS_PWV/';
output_fn.PWV       = 'STATIONS_GNSS_PWV_hourly_2015_2015.mat';
% Insert filenames of GNSS coordinates + geoid model
fn_geoid_model      = 'Data_Input/01_GNSS_station_info/geoid_undulation_EGM08_REDNAP.mat';   

%% Load data
load([input_fn_ERA5.dir '/' input_fn_ERA5.Pressure]);
load([input_fn_ERA5.dir '/' input_fn_ERA5.Tm]);
time_ERA = time;
load([input_fn_GNSS.dir '/' input_fn_GNSS.ZTD]);

ia = ismember(time_ERA,time);
lat = rad2deg(geod_list(:,1));
lon = rad2deg(geod_list(:,2));
h_orto = ERA_LEVEL.elips2ortometricHeight(lat,lon,geod_list(:,3),fn_geoid_model);

PWV = FUNC_compute_PWV(ZTD,p(ia,:),Tm(ia,:),lat',h_orto');

save([output_fn.dir '/' output_fn.PWV],'time','PWV','geod_list','sta_list_geod');

