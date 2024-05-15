function PWV = FUNC_levels_integrate_PWV(p,lat,q,p1,p2)
% Compute water-vapor weighted mean atmospheric temperature.
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.
% ______________________________________________________________
% Input:
%   p           Pressure levels vector [hPa].
%   q           Specific humidity vector [kg.kg-1].
%   lat         Latitude [degrees].
%   p1 [opt]    Lower integration bound (must be in the range of p).
%   p2 [opt]    Higher integration bound (must be in the range of p).
% Output
%   PWV         Precipitable water vapor [mm].
%_______________________________________________________________
% The numerical integration of the PWV in this paper is performed following the 
% trapezoidal rule, similar to that described in, for example, :
%
% Zhang, Y., Cai, C., Chen, B., & Dai, W. (2019). 
% Consistency evaluation of precipitable water vapor derived 
% from ERA5, ERA-Interim, GNSS, and radiosondes over China. 
% Radio Science, 54, 561– 571. https://doi.org/10.1029/2018RS006789
%
% (see equation 1 of the paper).
%
% If the minimum pressure level is under the lowest pressure level of ERA5,
% the PWV will be extrapolated using a gradient computed with the three
% last pressure levels.
%_______________________________________________________________
% Usage
%   FUNC_levels_integrate_PWV(p,lat,q)        Compute integral for the whole range of z.
%   FUNC_levels_integrate_PWV(p,lat,q,p1)     Compute integral from z1 to maximum boundary determined by z.
%   FUNC_levels_integrate_PWV(p,lat,q,p1,p2)  Compute integral between z1 and z2.
%_______________________________________________________________

%% (1) Define parameters
pw = 1; % Density of water, kg.m-3
lat_r = deg2rad(lat);
g = 9.780325*sqrt((1+0.00193185*sin(lat_r).^2)/(1-0.00669435*sin(lat_r).^2));

p = -flip(p); % A trick so that the upwards integral integrates to lower pressure value.
q = flip(q);
p1=-p1;
%% (2) Compute PWV
s_extrap = 0;
if nargin==5
    warning('Warning! Extrapolation is not implemented for this option.')
    PWV = FUNC_integrate_linear(p,1/(pw*g)*q,p1,p2);
    if or(all(p1<p),all(p2<p)) % If one of the stations is under lowest pressure level
        s_extrap = 1; % Switch on extrapolation
    end
elseif nargin==4
    if all(p1<p) % If one of the stations is under lowest pressure level
        id_min_p = find(p==min(p));
        PWV = FUNC_integrate_linear(p,1/(pw*g)*q,p(id_min_p));
        y1 = interp1([p(id_min_p) p(id_min_p+1)],1/(pw*g)*[q(id_min_p) q(id_min_p+1)],p1,'linear','extrap');
        PWV_extrap = (y1 + 1/(pw*g)*q(id_min_p))/2*(p(id_min_p) - p1);
        PWV = PWV + PWV_extrap;
    else
        PWV = FUNC_integrate_linear(p,1/(pw*g)*q,p1);
    end
elseif nargin==3
    PWV = FUNC_integrate_linear(p,1/(pw*g)*q);
end

%% Add extrapolated integration of PWV for stations under the lowest pressure level.


%% Correct unit
% As the pressure was inputed in hPa, the computed PWV will be in dm.
% Change to mm
PWV = PWV*100; % Minus to undo the initial trick (see line 39)

end








