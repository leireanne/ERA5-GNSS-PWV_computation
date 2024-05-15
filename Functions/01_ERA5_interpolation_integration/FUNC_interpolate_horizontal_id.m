function [P] = FUNC_interpolate_horizontal_id(lat,lon,id_lat,id_lon,lat_s,lon_s,P11,P12,P21,P22)
% Perform horizontal interpolation, following Jade et Vijayan 2008
% WARNING! Introduce lat/lon in radians!

% Define parameters
C = 2; % Weighting power
R = 6371e3; % Radius of Earth (m)

% Grid points latitude and longitude
phi = deg2rad([lat(id_lat);
               lat(id_lat);
               lat(id_lat+1);
               lat(id_lat+1)]); 
lambda = deg2rad([lon(id_lon);
                  lon(id_lon+1);
                  lon(id_lon);
                  lon(id_lon+1)]);

% Angular distance from station to grid point.
psi = acos(sin(phi).*sin(lat_s) + cos(phi).*cos(lat_s).*cos(lambda - lon_s)); % Angular distance

% Weight depending on angular distance
w_prima = (R .*psi).^-C;
w = w_prima ./ (sum(w_prima)); % Normalized weight

% Interpolated pressure:
P = [P11, P12, P21, P22] * w;

end
