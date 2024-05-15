function [id_lat,id_lon] = FUNC_find_horizontal_id(lat,lon,lat_s,lon_s)
% Find horizontal ERA5 previous gridpoint index for a GNSS station.
% Leire Anne Retegui Schiettekatte. AAU Geodesy, 2023.
% ________________________________________________________
% Input:
%   lat_s   Latitude of the station (degree).
%   lon_s   Longitude of the station (degree).
%   lat     Latitude of ERA5 grid (degree).
%   lon     Longitude of ERA5 grid (degree).
% *lat_s and lon_s can be vectors to compute the index of many stations
% simultaneously.
% Output:
% 
%_________________________________________________________
id_lon = interp1(lon,1:length(lon),lon_s,'previous');
id_lat = interp1(lat,1:length(lat),lat_s,'previous');
end



