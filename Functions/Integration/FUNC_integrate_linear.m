function i = FUNC_integrate_linear(x,y,x1,x2)
% Integrate a function y(x) with respect to x (trapezoidal approximation of integration segments).
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.
%___________________________________________________________________
% See more about the trapezoidal rule:
% https://en.wikipedia.org/wiki/Trapezoidal_rule
% __________________________________________________________________
% Important: this function performs the numerical integration by keeping
% the intervals of the input vector x as a basis for discretization of the
% function.
% For a finer discretization, first perform a spline interpolation of the
% input samples (x,y) and then call this function.
%___________________________________________________________________
% Input: (column vectors!)
%   x           Independent variable.
%   y           Dependent variable to integrate.
%   x1 [opt]    Lower limit of the integration (must be in the range defined by x).
%   x2 [opt]    Upper limit of the integration (must be in the range defined by x).
% *If x1, x2 are not provided, the integration will be performed over the
% whole range defined by the vector x. If only x1 is provided, x2 will be
% taken as the highes value of vector x.
% Output
%   i           Result of the integration.
%____________________________________________________________________
% Usage:
%   i = FUNC_integrate_linear(x,y)          Integrate from min(x) to max(x)
%   i = FUNC_integrate_linear(x,y,x1)       Integrate from x1 to max(x)
%       * In this case, make sure array x has the correct direction (min to
%       max).
%   i = FUNC_integrate_linear(x,y,x1,x2)    Integrate from x1 to x2.
%____________________________________________________________________
%% (0) Check if integration limits are provided
sign=1;
if nargin==2 % If no x1, x2, perform integration over whole range x
    x1 = x(1);
    x2 = x(end);
elseif nargin==3 % take x1 as lower bound and integrate until last x value.
    x2 = x(end);
    if or(x1<min(x),x1>max(x))
        error('Error! The provided lower bound x1 is out of the range defined by x.')
    end
elseif nargin==4
    if x1>x2 % If low bound is higher than high bound, compute the inverse integral and invert the sign at the end.
        [x1,x2] = [x2,x1];
        sign = -1;
    end
    if or(x1<min(x),x2>max(x))
        error('Error! The provided lower bound or higher bound is out of the range defined by x.')
    end
elseif or(nargin<2,nargin>4)
    error('Error! Incorrect number of arguments! See function header for more details.')
end

%% (1) Interpolate function values for lower and upper bounds and create array to interpolate.
y1 = interp1(x,y,x1);
y2 = interp1(x,y,x2);

ind_mid = and(x>x1,x<x2); % Find x points that in the interpolation range.
x_interp = [x1; x(ind_mid); x2];
y_interp = [y1; y(ind_mid); y2];

%% (2) Perform integration.
% Compute mean value of each segment (linear assumption)
y_segm = (y_interp(1:end-1) + y_interp(2:end))/2;
% Compute dx of each segment.
dx_segm = x_interp(2:end) - x_interp(1:end-1);
% Compute result of integral.
i = y_segm'*dx_segm;

%% (3) Apply negative sign if the integral was inverse.
i = i*sign;

end
            
    




