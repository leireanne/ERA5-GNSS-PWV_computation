% Compute SPCI from PWV and precipitation data for GNSS stations positions.
% Leire Retegui Schiettekatte. AAU Geodesy 2023.
%_________________________________________________________

addpath(genpath('.'));

%% (A) SPCI USING GNSS PWV.

% Load data.
load('STATIONS_GNSS_PWV.mat') % Output from script A02.
load('STATIONS_IPE_PREC_monthly_2007_2021.mat');

% Omit Ceuta and Melilla from GNSS PWV because they are not included in precipitation
% data (only Iberian Peninsula, IP).
ind_not_IP = [find(strcmp(string(sta_list_geod),'CEU1')), find(strcmp(string(sta_list_geod),'MELI'))];
PWV(:,ind_not_IP) = []; % Omit Ceuta and Melilla
geod_list(ind_not_IP,:) = [];% Omit Ceuta and Melilla
sta_list_geod(ind_not_IP,:) = [];% Omit Ceuta and Melilla

% Compute SPCI for different timescales.
[spci01,spci03,spci06,spci09,spci12,spci24] = FUNC_compute_SPCI_NOT_EFFICIENT(PWV,Pr);

% Save results.
save('./Data_Output/03_Drought_indices/STATIONS_GNSS_SPCI_2007_2021.mat','time','sta_list_geod','geod_list','spci01','spci03','spci06','spci09','spci12','spci24')

%% (B) SPCI USING ERA5 PWV, 2007-2022.

% Load data.
load('STATIONS_ERA5_PWV.mat') % Output from script A02.
time_ERA = time;
load('STATIONS_IPE_PREC_monthly_2007_2021.mat');

% Limit ERA5 data to timespan covered by the precipitation data.
ia = ismember(time_ERA,time);
PWV = PWV(ia,:);

% Omit Ceuta and Melilla from GNSS PWV because they are not included in precipitation
% data (only Iberian Peninsula, IP).
ind_not_IP = [find(strcmp(string(sta_list_geod),'CEU1')), find(strcmp(string(sta_list_geod),'MELI'))];
PWV(:,ind_not_IP) = []; % Omit Ceuta and Melilla
geod_list(ind_not_IP,:) = [];% Omit Ceuta and Melilla
sta_list_geod(ind_not_IP,:) = [];% Omit Ceuta and Melilla

% Compute SPCI for different timescales.
[spci01,spci03,spci06,spci09,spci12,spci24] = FUNC_compute_SPCI_NOT_EFFICIENT(PWV,Pr);

% Save results.
save('./Data_Output/03_Drought_indices/STATIONS_ERA_SPCI_2007_2021.mat','time','sta_list_geod','geod_list','spci01','spci03','spci06','spci09','spci12','spci24')

%% (C) SPCI USING ERA5 PWV, 1960-2022.

% Load data.
load('STATIONS_ERA5_PWV_monthly_1960_2022.mat') % Output from script A02.
time_ERA = time;
load('STATIONS_IPE_PREC_monthly_1961_2021.mat');

% Limit ERA5 data to timespan covered by the precipitation data.
ia = ismember(time_ERA,time);
PWV = PWV(ia,:);

% Omit Ceuta and Melilla from GNSS PWV because they are not included in precipitation
% data (only Iberian Peninsula, IP).
ind_not_IP = [find(strcmp(string(sta_list_geod),'CEU1')), find(strcmp(string(sta_list_geod),'MELI'))];
PWV(:,ind_not_IP) = []; % Omit Ceuta and Melilla
geod_list(ind_not_IP,:) = [];% Omit Ceuta and Melilla
sta_list_geod(ind_not_IP,:) = [];% Omit Ceuta and Melilla

% Compute SPCI for different timescales.
[spci01,spci03,spci06,spci09,spci12,spci24] = FUNC_compute_SPCI_NOT_EFFICIENT_1961_2022(PWV,Pr);

% Save results.
save('./Data_Output/03_Drought_indices/STATIONS_ERA_SPCI_1961_2021.mat','time','sta_list_geod','geod_list','spci01','spci03','spci06','spci09','spci12','spci24')

%% (D) SPCI USING original GNSS PWV, 2007-2022.

% Load data.
load('STATIONS_GNSS_PWV_monthly_2007_2021_originals.mat') % Original PWV from first version of paper.
load('STATIONS_IPE_PREC_monthly_2007_2021.mat');

% Omit Ceuta and Melilla from GNSS PWV because they are not included in precipitation
% data (only Iberian Peninsula, IP).
PWV(:,ind_not_IP) = []; % Omit Ceuta and Melilla

% Compute SPCI for different timescales.
[spci01,spci03,spci06,spci09,spci12,spci24] = FUNC_compute_SPCI_NOT_EFFICIENT(PWV,Pr);

% Save results.
save('./Data_Output/STATIONS_GNSS_SPCI_2007_2021_originals.mat','time','sta_list_geod','geod_list','spci01','spci03','spci06','spci09','spci12','spci24')



