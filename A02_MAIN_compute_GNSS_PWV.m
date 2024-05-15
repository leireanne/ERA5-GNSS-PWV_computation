% Compute PWV values for the GNSS stations.
% Leire Retegui Schiettekatte.
%__________________________________________________
load('STATIONS_ERA5_Pressure.mat');
load('STATIONS_ERA5_Tm.mat');
time_ERA = time;
load('STATIONS_GNSS_ZTD_monthly_2007_2021_originals.mat');

ia = ismember(time_ERA,time);
lat = rad2deg(geod_list(:,1));
lon = rad2deg(geod_list(:,2));
h_orto = ERA_LEVEL.elips2ortometricHeight(lat,lon,geod_list(:,3));

PWV = FUNC_compute_PWV(ZTD,p(ia,:),Tm(ia,:),lat',h_orto');

save('STATIONS_GNSS_PWV.mat','time','PWV','geod_list','sta_list_geod');

