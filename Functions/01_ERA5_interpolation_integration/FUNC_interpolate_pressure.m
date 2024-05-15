function [P] = FUNC_interpolate_pressure(id_lev,h_0,h_1,lev)
% Interpolate pressure on GNSS station using ERA5 pressure levels.
% Leire Anne Retegui Schiettekatte. Grupo Microgeodesia, UJAEN. 2022.
%___________________________________________________________________
% Input: [all column vectors!]
%   id_lev  Index of lower pressure level (see array lev.)
%   h_0     Geopotential height difference with lower level (m)(NaN if no lower level).
%   h_1     Geopotential height difference with higher level (m)(NaN if no higher level).
%   lev     List of pressure levels (hPa).
% Output:
%   P       Interpolated pressure (hPa).
%____________________________________________________________________
% The interpolation is preformed following the formulation decribed in:
% Jade, S., and Vijayan, M. S. M. (2008), 
% GPS-based atmospheric precipitable water vapor estimation 
% using meteorological parameters interpolated from NCEP global reanalysis data,
% J. Geophys. Res., 113, D03106, doi:10.1029/2007JD008758.
%_____________________________________________________________________

% Adapt level list to introduce NaN for cases when station is under lowest
% pressure level or over highest pressure level.
p_list_down = [NaN; lev];
p_list_up = [lev; NaN];

% Retrieve lower and higher pressure level.
P_down = p_list_down(id_lev+1); % Pressure in the lower level
P_up = p_list_up(id_lev+1); % Pressure in the higher level

% Compute pressure using the barometric formula, when propagating from
% lower and higher level.
P_i_down = P_down.*(1+(8.419e-5*(-h_0))./P_down.^0.1902884).^5.255303;
P_i_up = P_up.*(1+(8.419e-5*(-h_1))./P_up.^0.1902884).^5.255303;

% Compute weights for lower and higher level based on distance.
w_i_down = 1./(h_0).^2;
w_i_up = 1./(h_1).^2;

% Compute weighted pressure.
P = (w_i_down .* P_i_down + w_i_up .* P_i_up) ./ (w_i_down + w_i_up);

% Assign only pressure computed from higher level for under-lowest levels.
id_under = id_lev==0;
P(id_under) = P_i_up(id_under); % Don't extrapolate because P_i_up is already an extrapolation!
% Assign only pressure computed from higher level for under-lowest levels.
id_over = id_lev==lev(end);
P(id_over) = P_i_down(id_over); % Don't extrapolate because P_i_up is already an extrapolation!

% The final pressure vector should contain no NaN values.

end