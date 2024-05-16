function [sta_list_geod,geod_list,xyz] = readGNSSStationCSV(fn)
% This function reads a CSV file with GNSS station coordinates and creates
% variables adapted to the structure expected by
% ERA5_interpolation_integration scripts.
% LRS 16-05-2024.

t = readtable(fn,'NumHeaderLines',1);
sta_list_geod = char(t.Var1);
geod_list = [t.Var2,t.Var3,t.Var4];
xyz = [t.Var5,t.Var6,t.Var7];
end

