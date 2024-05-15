% Plot vertical profile of some variable to check its linearity.
% Leire Anne Retegui Schiettekatte. AAU Geodesy 2023.

%% Load specific humidity
load('ERA5_Specific_humidity_monthly_2007_2022.mat')
q = squeeze(q(1,1,:,1));

%% Plot specific humidity profile
plot(d3_lev,q,'o-'); hold on;
d3_lev_hr = 1:1000; % Vertical level vector with higher resolution (1hPa).
q_hr = interp1(d3_lev,q,d3_lev_hr,'spline');
plot(d3_lev_hr,q_hr);
legend({'ERA5 profile','Spline interpolated profile'}); xlabel('Pressure level (hPa)')

%% Compute e (vapor pressure) and plot profile
p = d3_lev; % Pressure
e = FUNC_vapor_pressure(q,p);
plot(d3_lev,e,'o-');

%% Test some integration.
figure;
x = 4:0.1:15; y=-1./x.^2;
for j=1:length(x)
    x2 = x(j);
    i_1(j) = FUNC_integrate_linear(x,y,4,x2);
end
plot(x,i_1,'o-'); hold on;
plot(x,(1./x - 1/min(x)),'k');





