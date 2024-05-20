% Compare ERA5 and GNSS PWV estimations.
% Leire Retegui Schiettekatte.
%_______________________________________________
%% Input data: filenames.
% Insert filenames of ERA5 meteo variables.
input_fn_ERA5.dir      = 'Data_Output/01_ERA5_interpolated_integrated_variables/';
input_fn_ERA5.Pressure = 'STATIONS_ERA5_Pressure_hourly_2015_2015.mat';
input_fn_ERA5.Tm       = 'STATIONS_ERA5_Tm_hourly_2015_2015.mat';
% Insert filenames of in-situ meteo variables
input_fn_insitu.dir       = '';
input_fn_insitu.meteo     = 'STATIONS_ERA5_meteo_monthly_2007_2021_originals.mat';

%% Load files
load([input_fn_ERA5.dir '/' input_fn_ERA5.Pressure])
load([input_fn_ERA5.dir '/' input_fn_ERA5.Tm])
time_ERA = time; p_ERA = p; Tm_ERA = Tm;
load([input_fn_insitu.dir '/' input_fn_insitu.meteo])
% Rename original data and compute mean temp with Bevis relationship.
p = P; Tm = T*0.72+70.2;

ia = ismember(time_ERA,time);

% PRESSURE
for i=1:size(p,2) % For each station
    figure;
    plot(time,p(:,i)); hold on;
    plot(time_ERA(ia),p_ERA(ia,i));
    legend({'GNSS','ERA5'})
    title(sta_list_geod(i,:))
end

% MEAN TEMPERATURE
for i=1:size(p,2) % For each station
    figure;
    plot(time,Tm(:,i)); hold on;
    plot(time_ERA(ia),Tm_ERA(ia,i));
    legend({'GNSS','ERA5'})
    title(sta_list_geod(i,:))
end

% bias = mean(PWV - PWV_ERA(ia,:),1,'omitnan');
% std_ = std(PWV - PWV_ERA(ia,:),[],1,'omitnan');
    