% Compare ERA5 and GNSS PWV estimations.
% Leire Retegui Schiettekatte.
%_______________________________________________
load('STATIONS_ERA5_PWV.mat')
time_ERA = time; PWV_ERA = PWV;
load('STATIONS_GNSS_PWV.mat')

ia = ismember(time_ERA,time);

for i=1:size(PWV,2) % For each station
    figure;
    plot(time,PWV(:,i)); hold on;
    plot(time_ERA(ia),PWV_ERA(ia,i));
    legend({'GNSS','ERA5'})
    title(sta_list_geod(i,:))
end

bias = mean(PWV - PWV_ERA(ia,:),1,'omitnan')';
std_ = std(PWV - PWV_ERA(ia,:),[],1,'omitnan')';
    