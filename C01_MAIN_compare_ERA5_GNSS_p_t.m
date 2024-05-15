% Compare ERA5 and GNSS PWV estimations.
% Leire Retegui Schiettekatte.
%_______________________________________________
load('STATIONS_ERA5_Pressure.mat')
load('STATIONS_ERA5_Tm.mat')
time_ERA = time; p_ERA = p; Tm_ERA = Tm;
load('STATIONS_ERA5_meteo_monthly_2007_2021_originals.mat')
% Retime original data.
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
    