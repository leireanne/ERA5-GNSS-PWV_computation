function e = FUNC_vapor_pressure(q,p)
% Compute vapor pressure (e) from specific humidity (q) and pressure (p)
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.
% ______________________________________________________________________
% Input:
%   q   Specific humidity   [kg.kg-1]
%   p   Pressure
% Output:
%   e   Vapor pressure      [same unit as input pressure]
%_______________________________________________________________________
% Find some explanations of the mathematical computation, for example, here:
% https://cran.r-project.org/web/packages/humidity/vignettes/humidity-measures.html
%_______________________________________________________________________

% Constants:
Md = 28.9634; % Dry air molar mass
Mw = 18.01528; % Water molar mass
eps = Mw/Md; % Epsilon

% Computation:
e = q.*p ./ (eps + (1-eps)*q); % Vapor pressure
end