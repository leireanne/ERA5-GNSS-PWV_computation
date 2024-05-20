% Compare ERA5 and GNSS PWV estimations.
% Leire Retegui Schiettekatte.
%_______________________________________________
%% Input data: filenames.
% Insert filenames of ERA5 PWV.
input_fn_ERA5.dir   = 'Data_Output/01_ERA5_interpolated_integrated_variables/';
input_fn_ERA5.PWV   = 'STATIONS_ERA5_PWV_hourly_2015_2015.mat';
% Insert filenames of GNSS PWV.
input_fn_GNSS.dir   = 'Data_Output/02_GNSS_PWV/';
input_fn_GNSS.PWV   = 'STATIONS_GNSS_PWV_hourly_2015_2015.mat';

%% Load files
load([input_fn_ERA5.dir '/' input_fn_ERA5.PWV])
time_ERA = time; PWV_ERA = PWV;
load([input_fn_GNSS.dir '/' input_fn_GNSS.PWV])

ia = ismember(time_ERA,time);

figure; t = tiledlayout('flow','TileSpacing','tight');
for i=1:size(PWV,2) % For each station
    nexttile;
    plot(time,PWV(:,i)); hold on;
    plot(time_ERA(ia),PWV_ERA(ia,i));
    title(sta_list_geod(i,:)); ylabel('PWV (mm)');
end

legend({'GNSS','ERA5'});

bias = mean(PWV - PWV_ERA(ia,:),1,'omitnan')';
std_ = std(PWV - PWV_ERA(ia,:),[],1,'omitnan')';
    
    