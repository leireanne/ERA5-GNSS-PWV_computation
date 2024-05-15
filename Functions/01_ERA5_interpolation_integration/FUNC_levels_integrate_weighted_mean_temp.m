function Tm = FUNC_levels_integrate_weighted_mean_temp(z,q,T,p,z1,z2)
% Compute water-vapor weighted mean atmospheric temperature.
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.
% ______________________________________________________________
% Input:
%   z           Geopotential vector (for each pressure level).
%   q           Specific humidity vector [kg.kg-1].
%   T           Absolute temperature vector [K].
%   p           Pressure levels vector.
%   z1 [opt]    Lower integration bound (must be in the range of z).
%   z2 [opt]    Higher integration bound (must be in the range of z).
% Output
%   Tm          Weighted mean temperature [K].
%_______________________________________________________________
% The numerical integration of the Tm in this paper is performed following the 
% trapezoidal rule, similar to that described in, for example, :
%
% F. Yang, J. Guo, X. Meng, J. Shi, Y. Xu and D. Zhang, 
% "Determination of Weighted Mean Temperature (Tm) Lapse Rate and 
% Assessment of Its Impact on Tm Calculation," 
% in IEEE Access, vol. 7, pp. 155028-155037, 2019, 
% doi: 10.1109/ACCESS.2019.2946916.
%
% (see equation 4 of the paper).
%_______________________________________________________________
% Usage
%   FUNC_compute_weighted_mean_temp(z,q,T,p)        Compute integral for the whole range of z.
%   FUNC_compute_weighted_mean_temp(z,q,T,p,z1)     Compute integral from z1 to maximum boundary determined by z.
%   FUNC_compute_weighted_mean_temp(z,q,T,p,z1,z2)  Compute integral between z1 and z2.
%_______________________________________________________________

%% (1) Compute vapor pressure (e) from specific humidity (q) and pressure (p)
e = FUNC_vapor_pressure(q,p);

% Flip all variables so that height values go from lowest to highest.
z = flip(z); e=flip(e); T=flip(T);

%% (2) Compute Tm
% Even if the integral should be performed over the geopotential height, we
% can also perform it over the geopotential, as the factor g will cancel
% when dividing Tm_1 and Tm_2.
if nargin==6
    warning('Warning! Extrapolation is not implemented for this option.')
    Tm_1 = FUNC_integrate_linear(z,e./T,z1,z2);         % Integrate e/T (numerator)
    Tm_2 = FUNC_integrate_linear(z,e./(T.^2),z1,z2);    % Integrate e/T^2 (nominator)
elseif nargin==5
    if all(z1<z) % If one of the stations is under lowest pressure level
        id_min = find(z==min(z));
        Tm_1 = FUNC_integrate_linear(z,e./T,z(id_min));         % Integrate e/T (numerator)
        Tm_2 = FUNC_integrate_linear(z,e./(T.^2),z(id_min));    % Integrate e/T^2 (nominator)
        y1_1 = interp1([z(id_min) z(id_min+1)],[e(id_min) e(id_min+1)]./[T(id_min) T(id_min+1)],z1,'linear','extrap');
        y1_2 = interp1([z(id_min) z(id_min+1)],[e(id_min) e(id_min+1)]./[T(id_min) T(id_min+1)].^2,z1,'linear','extrap');
        Tm_extrap_1 = (y1_1 + e(id_min)./T(id_min))/2*(z(id_min) - z1);
        Tm_extrap_2 = (y1_2 + e(id_min)./T(id_min).^2)/2*(z(id_min) - z1);
        Tm_1 = Tm_1 + Tm_extrap_1;
        Tm_2 = Tm_2 + Tm_extrap_2;
    else
        Tm_1 = FUNC_integrate_linear(z,e./T,z1);         % Integrate e/T (numerator)
        Tm_2 = FUNC_integrate_linear(z,e./(T.^2),z1);    % Integrate e/T^2 (nominator)
    end
    elseif nargin==4
    Tm_1 = FUNC_integrate_linear(z,e./T);         % Integrate e/T (numerator)
    Tm_2 = FUNC_integrate_linear(z,e./(T.^2));    % Integrate e/T^2 (nominator)
end
Tm = Tm_1./Tm_2;

end








