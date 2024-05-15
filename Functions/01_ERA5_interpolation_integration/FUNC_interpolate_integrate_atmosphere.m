function [p,PWV,Tm] = FUNC_interpolate_integrate_atmosphere(lat_s,lon_s,h_s,fn)
% Compute ERA5 integrations (PWV and Tm) for a given GNSS station.
% Leire Anne Retegui Schiettekatte. AAU Geodesy, 2023.
%_________________________________________________________________
% Input:
%   lat_s   Latitude of the GNSS station (degree).
%   lon_s   Longitude of the GNSS station (degree).
%   h_s     Orthometric height of the GNSS station.
% Output:
%   p       Pressure [hPa].
%   PWV     Precipitable Water Vapor (mm).
%   Tm      Weighted mean temperature (K).
%_________________________________________________________________

%% Input:
% % Station coordinates:
% lat_s = 37.7866; % jaen
% lon_s = -3.7815; % jaen
% h_s = 577.5075; % jaen altitud ortometrica
% % Station coordinates:
% lat_s = 37.1899; % granada
% lon_s = -3.5964; % granada
% h_s = 0; %873.7090; % granada altitud ortometrica 
%    

% ERA5 data.
load(fn.Geopotential);
load(fn.Specific_humidity);
load(fn.Temperature);
lat = d2_lat; lon = d1_lon;

%% (2) Find indices for the four nearest grid points.
[id_lat,id_lon] = FUNC_find_horizontal_id(lat,lon,lat_s,lon_s);

%% (3) Find pressure time series for the four grid points.
p11 = FUNC_compute_pressure(id_lat  , id_lon  , h_s,lat,d3_lev,z);
p12 = FUNC_compute_pressure(id_lat  , id_lon+1, h_s,lat,d3_lev,z);
p21 = FUNC_compute_pressure(id_lat+1, id_lon  , h_s,lat,d3_lev,z);
p22 = FUNC_compute_pressure(id_lat+1, id_lon+1, h_s,lat,d3_lev,z);

%% (4) Compute integrals for the four grid points.

%%%%%%%%%%%%% IMPLEMENT LINEAR EXTRAPOLATION FOR LOWEST LEVELS.
p=p11;
for T = 1:length(p)
    lat_gp = deg2rad(lat(id_lat)); % Latitude of the gridpoint.
    g = 9.780325*sqrt((1+0.00193185*sin(lat_gp).^2)/(1-0.00669435*sin(lat_gp).^2));
    q_t = squeeze(q(id_lon,id_lat,:,T));
    h_t = squeeze(z(id_lon,id_lat,:,T))/g;
    t_t = squeeze(t(id_lon,id_lat,:,T));
    PWV_11(T) = FUNC_levels_integrate_PWV(d3_lev,lat_s,q_t,p(T));
    Tm_11(T) = FUNC_levels_integrate_weighted_mean_temp(h_t,q_t,t_t,d3_lev,h_s);
    q_t = squeeze(q(id_lon+1,id_lat,:,T));
    h_t = squeeze(z(id_lon+1,id_lat,:,T))/g;
    t_t = squeeze(t(id_lon+1,id_lat,:,T));
    PWV_12(T) = FUNC_levels_integrate_PWV(d3_lev,lat_s,q_t,p(T));
    Tm_12(T) = FUNC_levels_integrate_weighted_mean_temp(h_t,q_t,t_t,d3_lev,h_s);
    q_t = squeeze(q(id_lon,id_lat+1,:,T));
    h_t = squeeze(z(id_lon,id_lat+1,:,T))/g;
    t_t = squeeze(t(id_lon,id_lat+1,:,T));
    PWV_21(T) = FUNC_levels_integrate_PWV(d3_lev,lat_s,q_t,p(T));
    Tm_21(T) = FUNC_levels_integrate_weighted_mean_temp(h_t,q_t,t_t,d3_lev,h_s);
    q_t = squeeze(q(id_lon+1,id_lat+1,:,T));
    h_t = squeeze(z(id_lon+1,id_lat+1,:,T))/g;
    t_t = squeeze(t(id_lon+1,id_lat+1,:,T));
    PWV_22(T) = FUNC_levels_integrate_PWV(d3_lev,lat_s,q_t,p(T));
    Tm_22(T) = FUNC_levels_integrate_weighted_mean_temp(h_t,q_t,t_t,d3_lev,h_s);
end


%% (5) Interpolate variables among four grid points.
p = FUNC_interpolate_horizontal_id(lat,lon,id_lat,id_lon,lat_s,lon_s,p11,p12,p21,p22);
PWV = FUNC_interpolate_horizontal_id(lat,lon,id_lat,id_lon,lat_s,lon_s,PWV_11',PWV_12',PWV_21',PWV_22');
Tm = FUNC_interpolate_horizontal_id(lat,lon,id_lat,id_lon,lat_s,lon_s,Tm_11',Tm_12',Tm_21',Tm_22');





