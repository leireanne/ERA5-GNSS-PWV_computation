function [id_lev,z_0,z_1]=FUNC_find_pressure_level_NOT_EFFICIENT(z,z_s)
% Find the pressure level corresponding to a station height.
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.
%___________________________________________________________
% Input
%   z_s     Geopotential of station.
%   z       Geopotential vector (for different pressure levels). (TIME DEPENDENT)
%               Rows    : time
%               Columns : geopotential height of pressure level.
% Output:
%   id_lev          Index of the lower presure level.
%   dist_up_lev     Distance to higher level.
%   dist_down_lev   Distance to lower level.
%___________________________________________________________

% z must have geopotential heights from smalles to highes in columns
% and time in rows.

for t=1:size(z,1)
if all(z_s<z(t,:)) % If the station is under all level pressures.
    id_lev(t) = 0;
    z_0(t) = NaN;
    z_1(t) = z_s - min(z(t,:));
elseif all(z_s>z(t,:)) % If the station is over all level pressures.
    id_lev(t) = size(z,2);
    z_0(t) = z_s - max(z(t,:));
    z_1(t) = NaN;
else
    z_diff = z_s-z(t,:);
    z_pos = z_diff(z_diff>0);
    z_0(t) = min(z_pos);
    z_neg = z_diff(z_diff<0);
    z_1(t) = max(z_neg);
    id_lev(t) = find(z_diff==z_0(t));
end
end
id_lev = id_lev';
z_0 = z_0';
z_1 = z_1';
end



