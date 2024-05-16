% Easy fast script for netcdf data extraction.
% Leire Retegui-Schiettekatte, 2023.


% INPUT FILE:
fn = 'adaptor.mars.internal-1715702764.9048486-20913-13-c757e7c8-3f2e-4d71-8381-89a5bebc12a7.nc'; % Define filename

% Assuming variables are:
%     {'longitude'}
%     {'latitude' }
%     {'level'    }
%     {'time'     }
%     {'z'        }
%     {'q'        }
%     {'t'        }
% (CHECK LATER IN THE CODE, VARIABLES WILL BE PRINTED.)


% Load NetCDF data
ncid = netcdf.open(fn);
% Load NetCDF metadata
md = ncinfo(fn);

% Print variables stored in netcdf files and check.
disp({md.Variables.Name}')

% Retrieve variables
% 1) One dimensional arrays (no scale factor and offset)
d1_lon = double(netcdf.getVar(ncid,0));
d2_lat = double(netcdf.getVar(ncid,1));
d3_lev = double(netcdf.getVar(ncid,2));
time_g = netcdf.getVar(ncid,3); % Gregorian time (hours since 1900)
d4_time = datetime(1900,1,1) + hours(time_g); % Datetime.

% 2) Multidimensional variable matrix (come with scale factor and offset).
%       2.1 Retrieve all variable data.

for var_n = 4:6 % For each variable...
    n = var_n+1; % From python [0...] to Matlab [1...] indexing
    v_v = double(netcdf.getVar(ncid,var_n)); % Original value from netcdf
    v_s = md.Variables(n).Attributes(1).Value; %Scale_factor
    v_o = md.Variables(n).Attributes(2).Value; %Add_offset
    v_f{n} = v_v * v_s + v_o; % Final value.
end

%       2.2 Save for each variable.

% Generate filename based on timing and geographical area
delta_t = median(d4_time(2:end)-d4_time(1:end-1)); % Compute temporal frequency of data.
if delta_t<days(1)
    freq = "hourly";
else
    freq = "monthly";
end

fn_key = sprintf("%s_%d_%d_Lat_%0.2f_%0.2f_Lon_%0.2f_%0.2f_Lev_%d_%d",freq,year(min(d4_time)),year(max(d4_time)),min(d2_lat),max(d2_lat),min(d1_lon),max(d1_lon),min(d3_lev),max(d3_lev));

% Geopotential
z = v_f{5};
save(sprintf('ERA5_Geopotential_%s.mat',fn_key),'d2_lat','d1_lon','d3_lev','d4_time','z');

% Specific humidity
q = v_f{6};
save(sprintf('ERA5_Specific_humidity_%s.mat',fn_key),'d2_lat','d1_lon','d3_lev','d4_time','q');

% Temperature
t = v_f{7};
save(sprintf('ERA5_Temperature_%s.mat',fn_key),'d2_lat','d1_lon','d3_lev','d4_time','t');











