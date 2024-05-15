function [pwv] = FUNC_compute_PWV(ztd,p,Tm, lat, h_orto)
% Compute PWV following classical formula.
% Leire Retegui Schiettekatte. Grupo de Microgeodesia, UJAEN, 2022.
%_______________________________________________
% Input:
%   ztd         ZTD (m);
%   p           Pressure (hPa)
%   Tm          Water vapor weighted mean temperature (K)
%   lat         Latitude (in degrees!!!)
%   h_orto      Orthometric height (m).
%_______________________________________________
% Output:
%   PWV         Precipitable Water Vapor (mm).
%_______________________________________________

lat = deg2rad(lat);

% Computation:
zhd = 0.0022768 * p ./ (1 - 0.00266 * cos(2*lat) - 0.00000028 * h_orto); % lat in rad! original goGPS in deg
zwd = (ztd - zhd)*100; %cm
% Askne and Nordius formula (from Bevis et al., 1994)
Q = (4.61524e-3*((3.739e5./Tm) + 22.1));
% precipitable Water Vapor
pwv = zwd ./ Q *10; %mm
