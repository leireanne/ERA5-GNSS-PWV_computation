function P = FUNC_compute_pressure(id_lat,id_lon,h_s,lat,d3_lev,z)
% Interpolate pressure values for grid point at height h_s.
% Leire Anne Retegui Schiettekatte. Grupo de Microgeodesia, UJAEN, 2022.
%_____________________________________________________________________
% Input:
%   h_s         Orthometric (geopotential) height of the station.
%   id_lat      Index of slatitude of gridpoint.
%   id_lon      Index of longitude of gridpoint.
%   lat         Latitude of ERA5 grid (necessary for computing gravity value.)
%   d3_lev      Pressure levels of ERA5 grid.
%   z           Geopotential of pressure levels.
% Output:
%   P           Pressure time series.
%_____________________________________________________________________

%% (1) Compute parameters
lat_gp = deg2rad(lat(id_lat)); % Latitude of the gridpoint.
g = 9.780325*sqrt((1+0.00193185*sin(lat_gp).^2)/(1-0.00669435*sin(lat_gp).^2));

z_adapted = flip(squeeze(z(id_lon,id_lat,:,:))',2); % Shape is adapted to function input requirements.
d3_lev = flip(d3_lev);

%% (2) Compute vertical index and distances.
z_s = h_s*g; % Geopotential!
[id_lev,z_0,z_1] = FUNC_find_pressure_level_NOT_EFFICIENT(z_adapted,z_s); % Ouput is geopotential!

%% (3) Interpolate pressure.
h_0 = z_0/g; h_1 = z_1/g; % Comme back to geopotential height.
P = FUNC_interpolate_pressure(id_lev,h_0,h_1,d3_lev);

