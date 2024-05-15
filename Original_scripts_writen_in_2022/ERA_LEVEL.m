classdef ERA_LEVEL
    % Class to manage information sent by REDIAM
    % For dealing with pressure level models
    
    properties(Constant, Access = public)
        g0 = 9.80665;
        R = 6371e3; %m
        
        %latlon grid
        lat_grid = 35.0:0.25:39.75;
        lon_grid = -7.5:0.25:-1.25;
        
        X_pt = repmat([1:26]',20,1);
        Y_pt = sort(repmat([1:20]',26,1));
        
        x_max = length(ERA_LEVEL.lon_grid);
        y_max = length(ERA_LEVEL.lat_grid);
        
        % CAAL, NEVA
        lat_grid_alt = 37.0:0.25:37.25;
        lon_grid_alt = -3.5:0.25:-2.5;
        
        X_pt_alt = repmat([17:21]',2,1);
        Y_pt_alt = sort(repmat([9:10]',5,1));
        
        x_max_alt = length(ERA_LEVEL.lon_grid_alt);
        y_max_alt = length(ERA_LEVEL.lat_grid_alt);
        
        %CARG
        lat_grid_carg = 35.0:0.25:39.75;
        lon_grid_carg = -1.25:0.25:-0.75;
        
        X_pt_carg = repmat([26:28]',20,1);
        Y_pt_carg = sort(repmat([1:20]',3,1));
        
        x_max_carg = length(ERA_LEVEL.lon_grid_carg);
        y_max_carg = length(ERA_LEVEL.lat_grid_carg);
        
        lat_grid_tot = 35.0:0.25:39.75;
        lon_grid_tot = -7.5:0.25:-0.75;
        
    end
    
    properties(Constant, Access = public)
        sta_list_area = {'ALGC';'ALJI';'ALME';'ALMR';'ANDU';'ARAC';'AREZ';'CAAL';'CABR';'CARG';'CAST';'CAZA';'CEU1';'COBA';'CRDB';'EPCU';'GRA1';'HUEL';'HULV';'HUOV';'LEBR';'LIJA';'LOJA';'MALA';'MELI';'MLGA';'MOFR';'MOTR';'NEVA';'OSUN';'PALC';'PALM';'PILA';'POZO';'ROND';'RUBI';'SEVI';'SFER';'TALR';'TGIL';'TIOU';'UCAD';'UJAE';'VIAR';'VICA';'ZFRA'};
        area =           [   2;    2;    3   ;   3   ; 1   ;   1  ;   3 ;   2   ;  2   ;  3   ;  1   ;   1  ;  0   ;  1   ;   1  ;   0  ;   2  ;   1  ;   1  ;   3  ;   1  ;   2  ;   2  ;   2  ;   0  ;   2  ;   2  ;   2  ;   2  ;   2  ;   2  ;   2  ;   3  ;   1  ;   2  ;   1  ;   1  ;   1  ;   1  ;    2 ;   0  ;   1  ;   2  ;   2  ;   2  ;   1  ];
        area_colors = [.6 .6 1; .6 1 .6; 1 .6 .6];
    end % Properties for spatial histogram correlation representation
    
    
    methods(Static, Access = public) % Conversion from csv to mat files.
        
        function reorganizationProcessingFlow
            % Basic reorganization
            ERA_LEVEL.reorganizeERA5PressureLevelData1000;
            ERA_LEVEL.reorganizeERA5PressureLevelData975;
            ERA_LEVEL.reorganizeERA5PressureLevelData950;
            ERA_LEVEL.reorganizeERA5PressureLevelData925;
            ERA_LEVEL.reorganizeERA5PressureLevelData900;
            ERA_LEVEL.reorganizeERA5PressureLevelData875;
            ERA_LEVEL.reorganizeERA5PressureLevelData850;
            ERA_LEVEL.reorganizeERA5PressureLevelData825;
            % Reorganization for NEVA and CAAL
            ERA_LEVEL.reorganizeERA5PressureLevelData600
            ERA_LEVEL.reorganizeERA5PressureLevelData650
            ERA_LEVEL.reorganizeERA5PressureLevelData700
            ERA_LEVEL.reorganizeERA5PressureLevelData750
            ERA_LEVEL.reorganizeERA5PressureLevelData775
            ERA_LEVEL.reorganizeERA5PressureLevelData800
            % Reorganization for CARG (because initially a too small grid
            % was selected
            ERA_LEVEL.reorganizeERA5PressureLevelData1000CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData975CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData950CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData925CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData900CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData875CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData850CARG;
            ERA_LEVEL.reorganizeERA5PressureLevelData825CARG;
        end
        % PROCESSING FLOW
        % 1) Process 1000hPa pressure level data to create files
        % 2) Process the other pressure levels to append this data
        % variables.
        
        function reorganizeERA5PressureLevelData1000
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 1 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_1000 = zpot_ERA(:,i);
                temp_1000 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'t_ERA','zpot_1000','temp_1000');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData975
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 2 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ');
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_975 = zpot_ERA(:,i);
                temp_975 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_975','temp_975','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData950
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 3 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_950 = zpot_ERA(:,i);
                temp_950 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_950','temp_950','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData925
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 4 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_925 = zpot_ERA(:,i);
                temp_925 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_925','temp_925','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData900
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 5 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_900 = zpot_ERA(:,i);
                temp_900 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_900','temp_900','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData875
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 6 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_875 = zpot_ERA(:,i);
                temp_875 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_875','temp_875','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData850
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875','850','825'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 7 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_850 = zpot_ERA(:,i);
                temp_850 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_850','temp_850','-append');
            end
            textprogressbar('done');
       
        end

        function reorganizeERA5PressureLevelData825
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'1000','975','950','925','900','875','850','825'};
            y_max = ERA_LEVEL.y_max; x_max = ERA_LEVEL.x_max;
            n_point = y_max * x_max;
            
            for i = 8 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_825 = zpot_ERA(:,i);
                temp_825 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt(i)) '.mat'],'zpot_825','temp_825','-append');
            end
            textprogressbar('done');
       
        end
        
        % Data for CAAL and NEVA (pressure levels 800 to 600hPa)
        
        function reorganizeERA5PressureLevelData600
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 1 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_600 = zpot_ERA(:,i);
                temp_600 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_600','temp_600','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData650
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 2 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_650 = zpot_ERA(:,i);
                temp_650 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_650','temp_650','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData700
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 3 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_700 = zpot_ERA(:,i);
                temp_700 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_700','temp_700','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData750
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 4 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_750 = zpot_ERA(:,i);
                temp_750 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_750','temp_750','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData775
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 5 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_775 = zpot_ERA(:,i);
                temp_775 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_775','temp_775','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData800
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level.
            % Other pressure levels are added in next functions
            
            pressure_levels = {'600','650','700','750','775','800'};
            y_max = ERA_LEVEL.y_max_alt; x_max = ERA_LEVEL.x_max_alt;
            n_point = y_max * x_max;
            
            for i = 6 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_800 = zpot_ERA(:,i);
                temp_800 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_alt(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_alt(i)) '.mat'],'zpot_800','temp_800','-append');
            end
            textprogressbar('done');
       
        end
        
        % Data for CARG (longitudes -0.12 to -0.75, later downloaded)
        
        function reorganizeERA5PressureLevelData1000CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 1 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_1000 = zpot_ERA(:,i);
                temp_1000 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_1000','temp_1000');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData975CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 2 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_975 = zpot_ERA(:,i);
                temp_975 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_975','temp_975','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData950CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 3 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_950 = zpot_ERA(:,i);
                temp_950 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_950','temp_950','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData925CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 4 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_925 = zpot_ERA(:,i);
                temp_925 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_925','temp_925','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData900CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 5 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_900 = zpot_ERA(:,i);
                temp_900 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_900','temp_900','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData875CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 6 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_875 = zpot_ERA(:,i);
                temp_875 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_875','temp_875','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData850CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875','850','825'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 7 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_850 = zpot_ERA(:,i);
                temp_850 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_850','temp_850','-append');
            end
            textprogressbar('done');
       
        end
        
        function reorganizeERA5PressureLevelData825CARG
            % Reorganize csv data so that there is one file for each grid
            % point for 1000hPa pressure level for CARG area.
            
            pressure_levels = {'1000','975','950','925','900','875','850','825'};
            y_max = ERA_LEVEL.y_max_carg; x_max = ERA_LEVEL.x_max_carg;
            n_point = y_max * x_max;
            
            for i = 8 %:length(pressure_levels)
                pres_lev = pressure_levels{i};
                
                list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev]));
                list = char(list(1,3:end));
                % Only one list element for Z and T
                list = unique(list(:,3:end),'rows');
                n_files = size(list,1);

                t_ERA = NaT(n_files,1);
                zpot_ERA = NaN(n_files,n_point);
                temp_ERA = NaN(n_files,n_point);
                textprogressbar('Loading and transforming data from ERA5 files:     ')
                for j=1:n_files
                    textprogressbar(j/n_files*100);
                    t_ERA(j) = datetime(list(j,1:10),'InputFormat','yyyyMMddHH');
                    
                    % Geopotential
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/Z_' list(j,:)],',',1,4);
                    zpot_ERA(j,:) = data';  
                    % Temperature
                    data = dlmread(['DATOS_ERA5/LEV_DATA_CARG/' pres_lev '/T_' list(j,:)],',',1,4);
                    temp_ERA(j,:) = data';
                end
            end
            textprogressbar('done');
            textprogressbar('Saving new structure for ERA5 data:     ')
            for i=1:n_point % For each grid point
                textprogressbar(i/n_point*100);
                zpot_825 = zpot_ERA(:,i);
                temp_825 = temp_ERA(:,i);
                save(['DATOS_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d', ERA_LEVEL.X_pt_carg(i)) '_Y' sprintf('%02d', ERA_LEVEL.Y_pt_carg(i)) '.mat'],'t_ERA','zpot_825','temp_825','-append');
            end
            textprogressbar('done');
       
        end
        

    end
    
    methods(Static, Access = public) % Main vertical Interpolation Scripts
         
        % ERA_LEVEL.interpolateERA5PressureLevels825;ERA_LEVEL.interpolateERA5PressureLevels825('daily'); ERA_LEVEL.interpolateERA5PressureLevels825('monthly'); ERA_LEVEL.interpolateERA5PressureLevels825('yearly'); 
        
        function interpolateERA5PressureLevels825
            % Pressure interpolation with 6 levels (1000 to 875).
            % As seen in function findHighestLevelLimit875, the lowest
            % height for pressure level 875 is 912.16m, so all stations
            % above 912m are ommited in this first processing.
            
            load('C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\matlab_extracted_data\REDIAM_data_table_latlon.mat');
            
            tab = tab(tab{:,7}<1394,:); % Ommit stations above 1394m (pressure level 825)
            lat_lon_list = tab{:,6:-1:5};
            h_list = tab{:,7};
            
            [x,y] = ERA_LEVEL.findGridPosition(lat_lon_list(:,1),lat_lon_list(:,2));
            
            textprogressbar('Interpolating ERA5 pressure data (limit 825hPa):     ')
            for i = 1:size(tab,1) % For REDIAM station
                textprogressbar(i/size(tab,1)*100);
                
                % Vertical interpolation
                [P_0_0,T_0_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i),h_list(i));
                [P_1_0,T_1_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i),h_list(i));
                [P_0_1,T_0_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i)+1,h_list(i));
                [P_1_1,T_1_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i)+1,h_list(i));
                
                % Horizontal interpolation
                lat_rad = deg2rad(lat_lon_list(i,1)); lon_rad = deg2rad(lat_lon_list(i,2));
                P = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),P_0_0,P_1_0,P_0_1,P_1_1,lat_rad,lon_rad);
                T = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),T_0_0,T_1_0,T_0_1,T_1_1,lat_rad,lon_rad);
                
                % Results saving
                t = [datetime(2007,1,1):hours(1):datetime(2022,1,1)]';
                pres = [P;NaN];
                temp = [T;NaN];
                save(['synced_mat_data/METEO_LEV_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','pres','temp');
               
            end
            textprogressbar('done');
        
        end
        
        function resampleERADataAllPressLevelMETEO(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\METEO_LEV_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                disp(f);
                load(['synced_mat_data\METEO_LEV_hourly\' list(f,:)]);
                tt = timetable(t,pres,temp);
                tt = retime(tt,sampling,'mean');
                t = tt.t; pres = tt.pres; temp = tt.temp;
                save(['synced_mat_data\METEO_LEV_' sampling '\' list(f,:)],'t','pres','temp');
            end
        end   
        
        function pruebaResultadosERA5PressureLevels
            load('synced_mat_data/METEO_LEV_hourly/SYNC_ERA_0451_2007_2021.mat');
            load('synced_mat_data/METEO_ERA_hourly/SYNC_ERA_0451_2007_2021.mat');
            pres_dif = pres - sin_pres;
            bias = mean(pres_dif,'omitnan');
            std_ = std(pres_dif,'omitnan');
            figure(); plot(pres); hold on; plot(sin_pres);
        end
        
        function max_h = findHighestLevelLimit825
            % Find the lowest point at which pressure level 825 arrives.
            % In the first processing with 8 pressure levels, all stations
            % above this height will be ommited.
            % RESULT: 1394m
            % So all stations above 1394m will be ommited.
            list = struct2cell(dir(['DATOS_ERA5/LEV_DATA_GRID/']));
            list = char(list(1,3:end));
            n_files = size(list,1);
            min_abs = 1e5;
            
            for i=1:n_files
                load(['DATOS_ERA5/LEV_DATA_GRID/' list(i,:)],'zpot_825');
                min_loc = min(zpot_825);
                min_abs = min([min_loc, min_abs]);
            end
            
            max_h = min_abs/ERA_LEVEL.g0;
        end
    end
    
    methods(Static, Access = public) % Functions for vertical interpolation.
        % Functions for vertical and horizontal grid point finding and
        % variable interpolation.
        
        function [x,y,dist_x_0,dist_x_1,dist_y_0,dist_y_1] = findGridPosition(lat,lon)
            % For a given lat and long or array, finds just previous x, just
            % previous y and distance to this knot in m
            % WARNING! lat,lon in degrees!
            
            % Previous grid point calculation (to get four grid points,
            % x+1, y+1.
            lon_distance = lon - ERA_LEVEL.lon_grid_tot;
            lon_distance(lon_distance<0) = 1000;
            [~,x] = min(lon_distance,[],2);
            lat_distance = lat - ERA_LEVEL.lat_grid_tot;
            lat_distance(lat_distance<0) = 1000;
            [~,y] = min(lat_distance,[],2);
            
            % Grid point distance calculation
            [e_meteo,n_meteo] = REDIAM.geod2plan_andal(deg2rad(lat),deg2rad(lon));
            [e_grid_0 ,n_grid_0 ] = REDIAM.geod2plan_andal(deg2rad(ERA_LEVEL.lat_grid_tot(y)'),deg2rad(ERA_LEVEL.lon_grid_tot(x)'));
            [e_grid_1 ,n_grid_1 ] = REDIAM.geod2plan_andal(deg2rad(ERA_LEVEL.lat_grid_tot(y+1)'),deg2rad(ERA_LEVEL.lon_grid_tot(x+1)')); % approximation, considering that the x distance is the same in the upside and downside of the grid cell
            dist_x_0 = e_meteo - e_grid_0;
            dist_x_1 = e_meteo - e_grid_1;
            dist_y_0 = n_meteo - n_grid_0;
            dist_y_1 = n_meteo - n_grid_1;
            
        end
        
        function [h,dist_h_0,dist_h_1,under_lev,over_lev] = findHeightLevelPosition(hpot,h_meteo)
            % Calculate pressure level parameters necesary to compute
            % variable values in meteo station heights.
            % INPUT:
            % hpot    = stacked geopotential height values for pressure levels
            %           in a grid point.
            % h_meteo = ortometric height of meteorological station
            %
            % OUTPUT: (all of them have dimension of time array, size 1 in hpot)
            % h         = number of pressure level under the meteo height
            %           (0=none, 1=1000hPa, 2=975hPa ...)
            % dist_h_0  = distance to lower level (NaN for under_lev cases)
            % dist_h_1  = distance to higher level (NaN for over_lev cases)
            % under_lev = logical, true when station is under lowest
            %             pressure level
            % over_lev  = logical, true when station is over highest
            %             pressure level
            
            
            % Previous level calculation
            h_dist = h_meteo - hpot; % distance of the meteo stations to pressure height levels
            under_lev = h_dist(:,1)<0; % FLAG: moments where the station is under the lowest pressure level
            over_lev = h_dist(:,end)>0; % FLAG: moments where the station is over the highest pressure level
            h_dist(under_lev,:) = []; % Must be ommited, otherwise the whole line will be 1000 and problems with h indexing
            h_dist(h_dist<0) = 10000;
            [~,h(~under_lev)] = min(h_dist,[],2);
            min_ind = find(~(h_dist - min(h_dist,[],2))');
            min_ind(over_lev) = 1; % To avoid problems. in the end will be subsituted by other value
            h(under_lev) = 0;
            h(over_lev) = size(h_dist,2)-1; 
            
            % Level distance calculation
            hpot_tras = hpot(~under_lev,:)'; % transposed h_pot
            dist_h_0(~under_lev) = h_meteo - hpot_tras(logical(min_ind)); % under_lev cases will be set to 0
            dist_h_0(under_lev) = NaN;
            dist_h_0(over_lev) = h_meteo - hpot(over_lev,end);
            dist_h_1(~under_lev) = h_meteo - hpot_tras(logical(min_ind + 1)); % over_lev cases will be compared with next first level. under_lev cases will be set to 0 (correct in next lines).
            dist_h_1(under_lev) = h_meteo - hpot(under_lev,1); % distance in the under level cases: first pressure level
            dist_h_1(over_lev) = NaN;
            
            dist_h_0 = dist_h_0';
            dist_h_1 = dist_h_1';
            h = h';
        end
        
        function P = findPressure(h,dist_h_0,dist_h_1,under_lev,over_lev)
            % Find pressure value in meteo stations starting from
            % findHeightLevelPosition functino results.
            % For stations below lowest levels, pressure extrapolating
            % using pressure reduction formula.
            
            p_list_down = [1025 1000 975 950 925 900 875 850 825 800 775 750 700 650 600];
            p_list_up = [1000 975 950 925 900 875 850 825 800 775 750 700 650 600 550];
            
            P_down = p_list_down(h+1)'; % Pressure in the lower level
            P_up = p_list_up(h+1)'; % Pressure in the higher level
            P_i_down = P_down.*(1+(8.419e-5*(-dist_h_0))./P_down.^0.1902884).^5.255303;
            P_i_up = P_up.*(1+(8.419e-5*(-dist_h_1))./P_up.^0.1902884).^5.255303;
            w_i_down = 1./(dist_h_0).^2;
            w_i_up = 1./(dist_h_1).^2;
            
            P = (w_i_down .* P_i_down + w_i_up .* P_i_up) ./ (w_i_down + w_i_up);
            P(under_lev) = P_i_up(under_lev); % Don't extrapolate because P_i_up is already an extrapolation!
            P(over_lev) = P_i_down(over_lev); % Don't extrapolate because P_i_up is already an extrapolation!
            
        end
        
        function T = findTemperature(h,dist_h_0,dist_h_1,under_lev,over_lev,temp)
            % Find pressure value in meteo stations starting from
            % findHeightLevelPosition functino results.
            % For stations below lowest levels, temperature extrapolated
            % with 6.5ºC/km gradient
            
            temp_tras = temp';
            if h(1)==0 % To avoid problems when first moment is in level 0
                h(1) = 1;
            end
            %disp(h + [0:length(h)-1]'*size(temp_tras,1));
            T_down = temp_tras(h + [0:length(h)-1]'*size(temp_tras,1));
            T_down(under_lev) = NaN;
            if h(end)==size(temp_tras,1) % To avoid problems when last moment is in level 8 (max)
                h(end) = size(temp_tras,1)-1;
            end
            T_up = temp_tras(h + 1 + [0:length(h)-1]'*size(temp_tras,1));
            T_up(over_lev) = NaN;
            
            T = T_down + (T_up - T_down)./(- dist_h_1 + dist_h_0) .* dist_h_0;
            T(under_lev) = T_up(under_lev) - 6.5e-3*dist_h_1(under_lev); % dist_h_0 is positive and dist_h_1 is negative
            T(over_lev) = T_down(over_lev) - 6.5e-3*dist_h_0(over_lev);
            
        end
        
        function [P,T] = performVerticalInterpolationGridPoint(x,y,h_meteo)
            % Perform vertical interpolation loading data for a given grid
            % point and using findHeightLevelPosition and findPressure
            % functions.
            
            load(['datos_ERA5/LEV_DATA_GRID/ERA5_LEV_X' sprintf('%02d',x) '_Y' sprintf('%02d',y) '.mat']); %load first grid point
            if exist('zpot_600')==1
                hpot = [zpot_1000 zpot_975 zpot_950 zpot_925 zpot_900 zpot_875 zpot_850 zpot_825 zpot_800 zpot_775 zpot_750 zpot_700 zpot_650 zpot_600]/ERA_LEVEL.g0;
                temp = [temp_1000 temp_975 temp_950 temp_925 temp_900 temp_875 temp_850 temp_825 temp_800 temp_775 temp_750 temp_700 temp_650 temp_600];
            else
                hpot = [zpot_1000 zpot_975 zpot_950 zpot_925 zpot_900 zpot_875 zpot_850 zpot_825]/ERA_LEVEL.g0;
                temp = [temp_1000 temp_975 temp_950 temp_925 temp_900 temp_875 temp_850 temp_825];
            end
            % Vertical interpolation
            [h,dist_h_0,dist_h_1,under_lev,over_lev] = ERA_LEVEL.findHeightLevelPosition(hpot,h_meteo);
            P = ERA_LEVEL.findPressure(h,dist_h_0,dist_h_1,under_lev,over_lev);
            T = ERA_LEVEL.findTemperature(h,dist_h_0,dist_h_1,under_lev,over_lev,temp);
        end
        
        function P = performHorizontalInterpolation(x,y,P_0_0,P_1_0,P_0_1,P_1_1,lat,lon)
            % Perform horizontal interpolation, following Jade et al. 2008
            % WARNING! Introduce lat/lon in radians!
            C = 2; % Weighting power
            phi = deg2rad([ERA_LEVEL.lat_grid_tot(y);
                           ERA_LEVEL.lat_grid_tot(y);
                           ERA_LEVEL.lat_grid_tot(y+1);
                           ERA_LEVEL.lat_grid_tot(y+1)]); % Grid points latitude
            lambda = deg2rad([ERA_LEVEL.lon_grid_tot(x);
                              ERA_LEVEL.lon_grid_tot(x+1);
                              ERA_LEVEL.lon_grid_tot(x);
                              ERA_LEVEL.lon_grid_tot(x+1)]); % Grid points longitude
            psi = acos(sin(phi).*sin(lat) + cos(phi).*cos(lat).*cos(lambda - lon)); % Angular distance
            w_prima = (ERA_LEVEL.R .*psi).^-C; % Weight
            w = w_prima ./ (sum(w_prima)); % Normalized weight
            P = [P_0_0, P_1_0, P_0_1, P_1_1] * w; % Interpolated pressure
        end
        
    end
    
    methods(Static, Access = public) % Comparison ERA5 REDIAM
        % Comparison between ERA5 pressure level and REDIAM data
        
        function rms_temp = REDIAMPressureLevelRMSCalculation825
            load('C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\matlab_extracted_data\REDIAM_data_table_latlon.mat','tab');
            tab = tab(tab{:,7}<1394,:); % Ommit stations above 912m
            sta_list_temp = tab{tab{:,16} == true,1};
            rms_pres = NaN(size(sta_list_temp,1),1);
            rms_temp = NaN(size(sta_list_temp,1),1);
            bias_temp = NaN(size(sta_list_temp,1),1);
            std_temp = NaN(size(sta_list_temp,1),1);
            for i = 1:size(sta_list_temp)
                sta = char(sta_list_temp(i,:))
                load(['synced_mat_data\METEO_LEV_daily\SYNC_ERA_' sta '_2007_2021.mat'],'temp','pres');
                pres_ERA = pres; temp_ERA = temp - 273.15;
                clear pres temp
                load(['synced_mat_data\METEO_CLI_daily\SYNC_CLI_' sta '_2007_2021.mat']);
                if exist('pres')==1
                    pres_CLI = pres;
                    rms_pres(i) = rms(pres_CLI - pres_ERA,'omitnan');
                    bias_pres(i) = mean(pres_CLI - pres_ERA,'omitnan');
                    std_pres(i) = std(pres_CLI - pres_ERA, 'omitnan');
                    f = figure(); plot(t,pres_ERA); hold on; plot(t,pres_CLI); title([sta newline 'RMS:' num2str(rms_pres(i))]);
                    saveas(f,['plots/' sta '.jpg']);
                    close all
                end
                if exist('temp')==1
                    temp_CLI = temp;
                    rms_temp(i) = rms(temp_CLI - temp_ERA,'omitnan');
                    bias_temp(i) = mean(temp_CLI - temp_ERA,'omitnan');
                    std_temp(i) = std(temp_CLI - temp_ERA, 'omitnan');
                end
                
                %Filter |CLI - ERA| > 10ºC
                %pres_CLI(abs(pres_CLI-pres_ERA)>10) = NaN;
                %rms_pres(i) = rms(pres_CLI - pres_ERA,'omitnan');
                %figure(); plot(t,temp_ERA); hold on; plot(t,temp_CLI); title([sta newline 'Bias +- STD:' num2str(bias_temp(i)) ' +- ' num2str(std_temp(i))]);
                
%                 load(['synced_mat_data\METEO_CLI_yearly\SYNC_CLI_' sta '_2007_2021.mat'],'t','pres');
%                 pres_CLI = pres;
%                 load(['synced_mat_data\METEO_LEV_yearly\SYNC_ERA_' sta '_2007_2021.mat'],'pres');
%                 pres_ERA = pres;
                %plot(t,pres_ERA); hold on; plot(t,pres_CLI); title(sta);
                %std_pres(i) = std(pres_CLI - pres_ERA,'omitnan');
            end
%             %rms_pres = rms_pres(std_pres<10);
            
%             RMS_PRES_LEVEL = NaN(size(tab,1),1);
%             RMS_PRES_LEVEL(tab{:,15} == true,1) = rms_pres;
%             RMS_PRES_LEVEL = table(RMS_PRES_LEVEL);
%             tab = [tab RMS_PRES_LEVEL];

            % HISTOGRAM
            edges = [0 1 2 5 161];
            h_pres = histcounts(rms_pres(isfinite(rms_pres)),edges);
            h_temp = histcounts(rms_temp(isfinite(rms_temp)),edges);
            
            h_pres = h_pres/sum(h_pres)*100;
            h_temp = h_temp/sum(h_temp)*100;
            
            h_list = [h_pres;h_temp];
            figure(); b = bar(h_list');
            set(gca, 'XTick', [1:4]);
            set(gca, 'XTickLabel', {'0-1','1-2','2-5','5-160'});
            %b(1).FaceColor = '#4DFF59';
            legend({'Pressure','Temperature'});
            title(['Root Mean Square Error of ERA5 - LOCAL meteo data']);
            xlabel('RMSE (hPa/ºC)'); ylabel('Percent of stations (%)');
            
            
            save('C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\matlab_extracted_data\REDIAM_data_table_latlon_825.mat','tab');
        end
        
        function REDIAMPressureLevelRMSHistograms825
            
            load('C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\matlab_extracted_data\REDIAM_data_table_latlon_825.mat','tab');
            
            tab(~isfinite(tab{:,21}),:) = []; % Ommit cases with no pressure value or NaN RMS.
            
            network_list = unique(tab.RED);
            edges = [0 1 2 5 161]; % max value has been seen to be 89
            h_list = [];
            for i = 1:size(network_list)
                net = network_list(i);
                ind = strcmp(string(tab{:,13}),string(net));
                durations = tab{ind,20};
                [h] = histcounts(durations,edges);
                h_list = [h_list, h'];
            end
            
%             figure(); b = barh(h_list','stacked');
%             set(gca, 'YTick',[1:size(network_list,1)]);
%             set(gca, 'YTickLabel', network_list);
%             b(1).FaceColor = '#4DFF59'; b(2).FaceColor = '#C1FFC6'; b(3).FaceColor = '#FFC1C1'; b(4).FaceColor = '#FF7F7F';
%             legend({'STD 0hPa to 1hPa','STD 1hPa to 2hPa','STD 2hPa to 5hPa','STD 5hPa to 15hPa'},'Location','Northeast');
%             title(['Root Mean Square of REDIAM vs. ERA5 pressure data' newline 'Classed by network.']);
%             xlabel('Number of stations'); ylabel('Network');
%             %legend(network_list,'Location','NorthEast');
            
            h_list = sum(h_list,2);
            figure(); b = bar(h_list');
            set(gca, 'XTick', [1:size(h_list)]);
            set(gca, 'XTickLabel', {'0hPa-1hPa','1hPa-2hPa','2hPa-5hPa','5hPa-160hPa'});
            %b(1).FaceColor = '#4DFF59';
            %legend({'STD 0hPa to 1hPa','STD 1hPa to 2hPa','STD 2hPa to 5hPa','STD 5hPa to 160hPa'},'Location','Northeast');
            title(['Root Mean Square of ERA5 - REDIAM pressure data']);
            xlabel('RMS'); ylabel('Number of stations');
            
        end
        
        
    end
    
    methods(Static, Access = public) % Extra functions.
        
        function getGeoidUndulationEGM08REDNAP
            d = dlmread('C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\DATOS_GEOIDE\malla_geoide.txt');
            d = d(2:end,:);
            d_2 = reshape(d',850,541)';
            d_2 = d_2(:,1:end-9);
            lat = 44 - ([1:541]'-1)/60;
            lon = -10 + ([1:841]'-1)/60;
            undu = d_2;
            [LON,LAT] = meshgrid(lon,lat);
            save('matlab_extracted_data/geoid_undulation_EGM08_REDNAP.mat','undu','LAT','LON');
        end
        
        function h_orto = elips2ortometricHeight(lat_sta,lon_sta,h_elips)
            % Convert from elipsoidal to otrometric height using
            % EGM08_REDNAP
            % REDNAP geoid undulations.
            % WARNING! Introduce lat long in deg!
            
            load('matlab_extracted_data/geoid_undulation_EGM08_REDNAP.mat');
            undu_sta = interp2(LON,LAT,undu,lon_sta,lat_sta);
            h_orto = h_elips - undu_sta;
        end 
        
        function interpolateERA5PressureLevels825GNSS
            % Pressure interpolation with 6 levels (1000 to 875).
            % As seen in function findHighestLevelLimit875, the lowest
            % height for pressure level 875 is 912.16m, so all stations
            % above 912m are ommited in this first processing.
            
            load('matlab_extracted_data\geodetic_data.mat');
            geod_list(41,:) = []; %Ommit TIOU
            sta_list_geod(41,:) = []; %Ommit TIOU
            % Temporarily ommit stations that are out of the ERA5 data grid
            % lon: -7.5 to -0.75
            % lat: 35 to 39.75
            ind_1 = and(rad2deg(geod_list(:,1))>35,rad2deg(geod_list(:,1))<39.75);
            ind_2 = and(rad2deg(geod_list(:,2))>-7.5,rad2deg(geod_list(:,2))<-0.75);
            ind = and(ind_1,ind_2); %Omitt TIOU, EPCU and ARAC
            
            geod_list = geod_list(ind,:); sta_list_geod = sta_list_geod(ind,:);
            
            h_list = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(:,1)),rad2deg(geod_list(:,2)),geod_list(:,3));
            
            [x,y] = ERA_LEVEL.findGridPosition(rad2deg(geod_list(:,1)),rad2deg(geod_list(:,2)));
            
            textprogressbar('Interpolating ERA5 pressure data (limit 825hPa):     ')
            for i = 1:size(geod_list,1) % For REDIAM station
                textprogressbar(i/size(geod_list,1)*100);
                disp([x(i),y(i)]);
                % Vertical interpolation
                [P_0_0,T_0_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i),h_list(i));
                [P_1_0,T_1_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i),h_list(i));
                [P_0_1,T_0_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i)+1,h_list(i));
                [P_1_1,T_1_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i)+1,h_list(i));
                
                % Horizontal interpolation
                lat_rad = geod_list(i,1); lon_rad = geod_list(i,2);
                P = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),P_0_0,P_1_0,P_0_1,P_1_1,lat_rad,lon_rad);
                T = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),T_0_0,T_1_0,T_0_1,T_1_1,lat_rad,lon_rad);
                
                % Results saving
                t = [datetime(2007,1,1):hours(1):datetime(2022,1,1)]';
                pres = [P;NaN];
                temp = [T;NaN];
                save(['synced_mat_data/LEV_hourly/SYNC_LEV_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pres','temp');
               
            end
            textprogressbar('done');
        
        end
        
        function interpolateERA5PressureLevelsAltGNSS
            % Pressure interpolation with 6 levels (1000 to 875).
            % Interpolation for CAAL and NEVA with pressure levels up to
            % 600hPa
            
            load('matlab_extracted_data\geodetic_data.mat');
            geod_list = geod_list([8,29],:); sta_list_geod = sta_list_geod([8,29],:);
                        
            h_list = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(:,1)),rad2deg(geod_list(:,2)),geod_list(:,3));
            
            [x,y] = ERA_LEVEL.findGridPosition(rad2deg(geod_list(:,1)),rad2deg(geod_list(:,2)));
            
            textprogressbar('Interpolating ERA5 pressure data (limit 825hPa):     ')
            for i = 1:size(geod_list,1) % For REDIAM station
                textprogressbar(i/size(geod_list,1)*100);
                
                % Vertical interpolation
                [P_0_0,T_0_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i),h_list(i));
                [P_1_0,T_1_0] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i),h_list(i));
                [P_0_1,T_0_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i),y(i)+1,h_list(i));
                [P_1_1,T_1_1] = ERA_LEVEL.performVerticalInterpolationGridPoint(x(i)+1,y(i)+1,h_list(i));
                
                % Horizontal interpolation
                lat_rad = geod_list(i,1); lon_rad = geod_list(i,2);
                P = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),P_0_0,P_1_0,P_0_1,P_1_1,lat_rad,lon_rad);
                T = ERA_LEVEL.performHorizontalInterpolation(x(i),y(i),T_0_0,T_1_0,T_0_1,T_1_1,lat_rad,lon_rad);
                
                % Results saving
                t = [datetime(2007,1,1):hours(1):datetime(2022,1,1)]';
                pres = [P;NaN];
                temp = [T;NaN];
                save(['synced_mat_data/LEV_hourly/SYNC_LEV_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pres','temp');
               
            end
            textprogressbar('done');
        
        end
        
        function resampleERADataAllPressLevelGNSS(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\LEV_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                disp(f);
                load(['synced_mat_data\LEV_hourly\' list(f,:)]);
                tt = timetable(t,pres,temp);
                tt = retime(tt,sampling,'mean');
                t = tt.t; pres = tt.pres; temp = tt.temp;
                save(['synced_mat_data\LEV_' sampling '\' list(f,:)],'t','pres','temp');
            end
        end   
        
        function computeERALevelTemperaturePressurePWV
            
            load('matlab_extracted_data/geodetic_data.mat');
            
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            sta_list = cellstr(sta_list_geod);
            
            for i = 1:length(sta_list)
                sta = sta_list(i);
                load(['synced_mat_data\TRO_daily\SYNC_TRO_',sta{:},'_2007_2021.mat']);
                load(['synced_mat_data\LEV_daily\SYNC_LEV_',sta{:},'_2007_2021.mat']);
                ind = strcmp(sta,string(sta_list_geod));
                
                temp = temp - 273.15;
                pres = pres*1e-2;
                
                % Computation:
                P = pres*1e2;
                lat = geod_list(ind,1);
                h = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)),rad2deg(geod_list(i,2)),geod_list(i,3));
                
                zhd = 0.0022768 * P(:) ./ (1 - 0.00266 * cos(2*lat(:)) - 0.00000028 * h(:)); % lat in rad! original goGPS in deg
                
                zwd_levera = (ztd - zhd)*100; %cm
                pwv_levera = PROC.PWV(zwd_levera,temp)*10; %mm
                
                if isfile(['synced_mat_data\DER_daily\SYNC_DER_' sta{:} '_2007_2021.mat'])
                    save(['synced_mat_data\DER_daily\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_levera','pwv_levera','-append');
                else
                    save(['synced_mat_data\DER_daily\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_levera','pwv_levera');
                end
            end
        end
        
        function computeERALevelTemperaturePressurePWVHourly
            % Funcion de datos de PWV horarios para enviar a Álvaro Zabala
            % de REDIAM
            
            load('matlab_extracted_data/geodetic_data.mat');
            
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            sta_list = cellstr(sta_list_geod);
            
            for i = 1:length(sta_list)
                sta = sta_list(i);
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_',sta{:},'_2007_2021.mat']);
                load(['synced_mat_data\LEV_hourly\SYNC_LEV_',sta{:},'_2007_2021.mat']);
                ind = strcmp(sta,string(sta_list_geod));
                
                temp = temp - 273.15;
                pres = pres*1e-2;
                
                % Computation:
                P = pres*1e2;
                lat = geod_list(ind,1);
                h = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)),rad2deg(geod_list(i,2)),geod_list(i,3));
                
                zhd = 0.0022768 * P(:) ./ (1 - 0.00266 * cos(2*lat(:)) - 0.00000028 * h(:)); % lat in rad! original goGPS in deg
                
                zwd_levera = (ztd - zhd)*100; %cm
                pwv_levera = PROC.PWV(zwd_levera,temp)*10; %mm
                
                if isfile(['synced_mat_data\DER_hourly\SYNC_DER_' sta{:} '_2007_2021.mat'])
                    save(['synced_mat_data\DER_hourly\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_levera','pwv_levera','-append');
                else
                    save(['synced_mat_data\DER_hourly\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_levera','pwv_levera');
                end
            end
        end
        
        function resampleERALevelTemperaturePressurePWV(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\DER_daily\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                disp(f);
                load(['synced_mat_data\DER_daily\' list(f,:)]);
                if exist('zwd_rediam')
                    tt = timetable(t,zwd_rediam,pwv_rediam,zwd_levera,pwv_levera);
                else
                    tt = timetable(t,zwd_levera,pwv_levera);
                end
                tt = retime(tt,sampling,'mean');
                t = tt.t; zwd_levera = tt.zwd_levera; pwv_levera = tt.pwv_levera;
                save(['synced_mat_data\DER_' sampling '\' list(f,:)],'t','pwv_levera','zwd_levera');
                if exist('zwd_rediam')
                    zwd_rediam = tt.zwd_rediam; pwv_rediam = tt.pwv_rediam;
                    save(['synced_mat_data\DER_' sampling '\' list(f,:)],'t','pwv_rediam','zwd_rediam','-append');
                end
                clear zwd_rediam
            end
        end   
        
        function computeERAPE
            % Compute precipitation effectiveness using LEVERA pwv and GRID
            % precipitation data (Vicente-Serrano et al. 2017)
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data\GRI_monthly\SYNC_GRI_' sta '_2007_2021.mat'],'t','prec');
                load(['synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat'],'t','pwv_levera');
                pef_levera = prec./pwv_levera*100; % in percentage
                save(['synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat'],'t','pef_levera','-append');
            end
        end
        
        function compareMETEOLevelPWVData()
            % GPS METEO PWV vs. GPS ERA Level PWV
            % The results are not good but many reasons can exist. For
            % example, the heights of METEO PWV calculations were wrong
            % (ortometric for meteo while elipsoidal for GNSS), but are
            % right with ERA5, which can explain the bias.
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\DER_daily\SYNC_DER_',sta{:},'_2007_2021.mat']);
                pwv_DER = pwv_levmet; %mm
                pwv_MET = pwv; %mm
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pwv_DER,'k-');
                plot(t,pwv_MET,'r-');
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(pwv_DER-pwv_MET,'omitnan'),std(pwv_DER-pwv_MET,'omitnan')]);
            end
        end
        
    end
    
    methods (Static, Access = public) % Índices calculados con levera (Pressure Level ERA5)
        
        function computePCIMultiscaleLEVERA(sta_list)
            % Compute SPCI 1, 3, 6, 9, 12.
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                load(['synced_mat_data\GRI_monthly\SYNC_GRI_' sta '_2007_2021.mat']);
                prec = [NaN(25,1); prec]; pwv = [NaN(25,1); pwv_levera]; % Add NaN so that pci is not computed for first 2 years
                n_sync = size(t,1);
                pci01_levera = NaN(n_sync,1); pci03_levera = NaN(n_sync,1); pci06_levera = NaN(n_sync,1); pci09_levera = NaN(n_sync,1); pci12_levera = NaN(n_sync,1); pci24_levera = NaN(n_sync,1);
                mond = [NaN(1,25) PROC.mond]; % number of days in each month, starting january 2007
                for m = 1:n_sync
                    n = m+25; % to skip first 24 NaNs
                    % WARNING! When SPEI was extracted, nearest value to
                    % the 1st of January of each month was selected as
                    % monthly value. That is, the value of each month
                    % actually corresponds to the accumulation of previous
                    % months. That's why, in the following calculations,
                    % sumations starts at n-1.
                    pci01_levera(m) = prec(n-1)/pwv(n-1)*100;  
                    pci03_levera(m) = sum(prec(n-1:-1:n-3).*mond(n-1:-1:n-3))/sum(pwv(n-1:-1:n-3).*mond(n-1:-1:n-3))*100;
                    pci06_levera(m) = sum(prec(n-1:-1:n-6).*mond(n-1:-1:n-6))/sum(pwv(n-1:-1:n-6).*mond(n-1:-1:n-6))*100;
                    pci09_levera(m) = sum(prec(n-1:-1:n-9).*mond(n-1:-1:n-9))/sum(pwv(n-1:-1:n-9).*mond(n-1:-1:n-9))*100;
                    pci12_levera(m) = sum(prec(n-1:-1:n-12).*mond(n-1:-1:n-12))/sum(pwv(n-1:-1:n-12).*mond(n-1:-1:n-12))*100;
                    pci24_levera(m) = sum(prec(n-1:-1:n-24).*mond(n-1:-1:n-24))/sum(pwv(n-1:-1:n-24).*mond(n-1:-1:n-24))*100;
                end
                spci01_levera = ERA_LEVEL.standardize(pci01_levera);
                spci03_levera = ERA_LEVEL.standardize(pci03_levera);
                spci06_levera = ERA_LEVEL.standardize(pci06_levera);
                spci09_levera = ERA_LEVEL.standardize(pci09_levera);
                spci12_levera = ERA_LEVEL.standardize(pci12_levera);
                spci24_levera = ERA_LEVEL.standardize(pci24_levera);
                save(['synced_mat_data\PCI_monthly\SYNC_PCI_' sta '_2007_2021.mat'],'t','pci01_levera','pci03_levera','pci06_levera','pci09_levera','pci12_levera','pci24_levera','spci01_levera','spci03_levera','spci06_levera','spci09_levera','spci12_levera','spci24_levera');
            end
        end
        
        function [tab_SPEI,tab_SPI] = plotIndexDataLEVERA(sta_list)
            % Plot SPI SPEI and PCI idexes and correlation %
            % Must be applied to stations that have monthly PWV and
            % precipitaion data already calculated.
            % PROC.plotIndexData(PROC.comp_stations);
            % PROC.plotIndexData(PROC.selec_stations);
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            tab_SPI = table(); tab_SPEI = table();
            tab_p_SPI = table(); tab_p_SPEI = table();
            for i=1:length(sta_list)
                figure();
                set(gcf,'Position',[1000,600,500,700]);
                tcl = tiledlayout(8,1);
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                pwv = pwv_levera; % Level ERA
                
                nexttile(tcl);
                plot(t,pwv,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('pwv')); ylim(PROC.ylims_('pwv')); title(sta);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\GRI_monthly\SYNC_GRI_' sta '_2007_2021.mat']); % Vicente-Serrano Grid precipitation
                hold on; plot(datetime(2023,1,1),[-1],'b'); plot(datetime(2023,1,1),[-1],'r'); plot(datetime(2023,1,1),[-1],'g');
                lg = legend({'PWV/Prec.','SPCI-GNSS','SPI','SPEI'},'Location','Northoutside','Orientation','horizontal');
                lg.Layout.Tile = 'South';
                
                nexttile(tcl);
                plot(t,prec,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('prec')); ylim(PROC.ylims_('prec'));
                % PE ALREADY LOADED FORM DER_monthly
                load(['synced_mat_data\PCI_monthly\SYNC_PCI_' sta '_2007_2021.mat']);
                pci01 = spci01_levera;
                pci03 = spci03_levera;
                pci06 = spci06_levera;
                pci09 = spci09_levera;
                pci12 = spci12_levera;
                pci24 = spci24_levera;
                load(['synced_mat_data\SPI_monthly\SYNC_SPI_' sta '_2007_2021.mat']);
                hold on; plot(datetime(2023,1,1),[-1],'b'); plot(datetime(2023,1,1),[-1],'r'); plot(datetime(2023,1,1),[-1],'g');
%                 lg = legend({'PWV/Prec.','SPCI-GNSS','SPI','SPEI'},'Location','Northoutside');%,'Orientation','horizontal');
%                 lg.Layout.Tile = 'East';set(lg.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.5;.5;.5;0]));  % [.5,.5,.5] is light gray; 0.8 means 20% transparent
%                 set(lg,'HandleVisibility','off');

                nexttile(tcl); plot(t,pci01,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI01'); %ylim([0,100]);
                hold on; plot(t,spi01,'color','r'); plot(t,spei01,'color','g');
                ind = isfinite(pci01);
                [cc_spi,p_spi] = corrcoef(pci01(ind),spi01(ind)); [cc_spei,p_spei] = corrcoef(pci01(ind),spei01(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'01'} = cc_spi(1,2); tab_SPEI{sta,'01'} = cc_spei(1,2); 
                tab_p_SPI{sta,'01'} = p_spi(1,2); tab_p_SPEI{sta,'01'} = p_spei(1,2);
                
                nexttile(tcl); plot(t,pci03,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI03'); %ylim([0,100]);
                hold on; plot(t,spi03,'color','r'); plot(t,spei03,'color','g');
                ind = isfinite(pci03);
                cc_spi = corrcoef(pci03(ind),spi03(ind)); [cc_spei,p_spei] = corrcoef(pci03(ind),spei03(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'03'} = cc_spi(1,2); tab_SPEI{sta,'03'} = cc_spei(1,2); 
                tab_p_SPI{sta,'03'} = p_spi(1,2); tab_p_SPEI{sta,'03'} = p_spei(1,2);
                
                nexttile(tcl); plot(t,pci06,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI06'); %ylim([0,100]);
                hold on; plot(t,spi06,'color','r'); plot(t,spei06,'color','g');
                ind = isfinite(pci06);
                [cc_spi,p_spi] = corrcoef(pci06(ind),spi06(ind)); [cc_spei,p_spei] = corrcoef(pci06(ind),spei06(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'06'} = cc_spi(1,2); tab_SPEI{sta,'06'} = cc_spei(1,2); 
                tab_p_SPI{sta,'06'} = p_spi(1,2); tab_p_SPEI{sta,'06'} = p_spei(1,2);
                
                nexttile(tcl); plot(t,pci09,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI09'); %ylim([0,100]);
                hold on; plot(t,spi09,'color','r'); plot(t,spei09,'color','g');   
                ind = isfinite(pci09);
                [cc_spi,p_spi] = corrcoef(pci09(ind),spi09(ind)); [cc_spei,p_spei] = corrcoef(pci09(ind),spei09(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'09'} = cc_spi(1,2); tab_SPEI{sta,'09'} = cc_spei(1,2); 
                tab_p_SPI{sta,'09'} = p_spi(1,2); tab_p_SPEI{sta,'09'} = p_spei(1,2);
                
                %spi12 = ERA_LEVEL.standardize(spi12); 
                %spei12 = ERA_LEVEL.standardize(spei12);
                nexttile(tcl); plot(t,pci12,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI12'); %ylim([0,100]);
                hold on; plot(t,spi12,'color','r'); plot(t,spei12,'color','g');
                ind = isfinite(pci12);
                [cc_spi,p_spi] = corrcoef(pci12(ind),spi12(ind)); [cc_spei,p_spei] = corrcoef(pci12(ind),spei12(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'12'} = cc_spi(1,2); tab_SPEI{sta,'12'} = cc_spei(1,2); 
                tab_p_SPI{sta,'12'} = p_spi(1,2); tab_p_SPEI{sta,'12'} = p_spei(1,2);
                
                nexttile(tcl); plot(t,pci24,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI24'); %ylim([0,100]);
                hold on; plot(t,spi24,'color','r'); plot(t,spei24,'color','g');
                ind = isfinite(pci24);
                [cc_spi,p_spi] = corrcoef(pci24(ind),spi24(ind)); [cc_spei,p_spei] = corrcoef(pci24(ind),spei24(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'24'} = cc_spi(1,2); tab_SPEI{sta,'24'} = cc_spei(1,2); 
                tab_p_SPI{sta,'24'} = p_spi(1,2); tab_p_SPEI{sta,'24'} = p_spei(1,2);
            end
        end
        
        function var_s = standardize(var_)
            % Standardize variable
            % INPUT: t (time, has to be with monthly frequency), var (variable values)
            % OUTPUT: var_s (standardized variable)
            % 
            % Standardization: compute mean yearly cycle and standard
            % deviation. var_s: number of times variable is deviated from
            % mean cycle.
            
            t = datetime(0001,1:length(var_),1);
            n_years = ceil(length(var_)/12);
            
            seas = var_;
            seas_folded = NaN(12,n_years);
            ind_stat_month = month(t);
            ind_stat_year = year(t);
            for i=1:length(seas)
                seas_folded(ind_stat_month(i),ind_stat_year(i)) = seas(i);
            end
            seas_lim = mean(seas_folded,2,'omitnan');
            %seas_lim = seas_lim-mean(seas_lim,'omitnan'); % mean = 0
            seas_std = std(seas_folded,0,2,'omitnan');
            seas_trend = repmat(seas_lim,n_years,1); % number of complete years
            seas_trend = seas_trend(1:length(var_),1); % Cut for days of last year
            std_ = repmat(seas_std,n_years,1);
            std_ = std_(1:length(var_),1);
            var_dev = seas - seas_trend; % deviation of variable from mean
            var_s = var_dev./std_; % deviation in number of std
            
        end
        
        function [mean_pwv, sta_list] = PWVHistograms(sta_list)
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            
            geod_list(:,3) = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(:,1)),rad2deg(geod_list(:,2)),geod_list(:,3));
            
            figure(1); title('PWV vs. height');
            m_pwv = [];
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                pwv = pwv_levera; % Level ERA
                pwv_month = reshape(pwv(1:end-1),[12 15]);
                pwv_mean = mean(pwv_month,2,'omitnan'); 
                
                % WARNING! ONLY COMPLETE YEARS ARE TAKEN FOR MEAN PWV
                % COMPUTATION, NOT TO ACCOUNT FOR DIFFERENCES BECAUSE OF
                % SEASONALITY
                
                m_pwv = [m_pwv; mean(mean(pwv_month,1),'omitnan')]; %Only omitnan in yearly mean not to account for incomplete years
                
                figure(); 
                bar(pwv_mean); title(sta);ylabel('PWV (mm)'); xlabel('Month of the year');
                
            end
            
            % PWV vs. Height
            figure(1); plot(geod_list(:,3),m_pwv,'ob'); hold on; %text(geod_list(i,3),mean(pwv,'omitnan'),sta);
            figure(1); plot(geod_list([8,26],3),m_pwv([8,26]),'or'); hold on; 
            title('Mean PWV vs. height'); ylabel('Mean PWV (mm)'); xlabel('Height (m)');
            %Linear regression
            h = geod_list(:,3); h([8,26]) = []; %Ommit NEVA and CAAL
            mean_pwv = m_pwv;
            m_pwv([8,26]) = [];
            lr = fitlm(h,m_pwv);
            ic = lr.Coefficients{1,1}; m = lr.Coefficients{2,1};
            R2 = lr.Rsquared.Ordinary;
            plot([1,3000],ic + m*[1,3000],'k-','LineWidth',2); text(1500,15,[sprintf('PWV = %0.3f %0.4fh',ic,m) newline sprintf('R^2 = %0.3f', R2)]);
        end
        
        function PEHistograms(sta_list)
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            figure(1); title('PWV vs. height');
            m_pef = [];
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                pef = pef_levera; % Level ERA
                pef_month = reshape(pef(1:end-1),[12 15]);
                pef_mean = mean(pef_month,2,'omitnan');
                m_pef = [m_pef; mean(pef_mean,'omitnan')];
                
                figure(); 
                bar(pef_mean); title(sta);ylabel('PE (%)'); xlabel('Month of the year');
                
            end
            
            % PWV vs. Height
            figure(1); plot(geod_list(:,3),m_pef,'ob'); hold on; %text(geod_list(:,3),m_pef,sta_list);
            title('Mean PE vs. height'); ylabel('Mean PE (mm)'); xlabel('Height(m)');
            %Linear regression
            h = geod_list(:,3); %h([8,25]) = []; %Ommit NEVA and CAAL
            %m_pef([8,25]) = [];
            lr = fitlm(h,m_pef);
            ic = lr.Coefficients{1,1}; m = lr.Coefficients{2,1};
            R2 = lr.Rsquared.Ordinary;
            plot([1,3000],ic + m*[1,3000],'k-','LineWidth',2); text(1500,15,[sprintf('PE = %0.3f + %0.3fh',ic,m) newline sprintf('R^2 = %0.3f', R2)]);
        end
        
        function [means,stds,h_diff] = ERA5MonthlyPWVValidation(sta_list)
            % Comparison of PWV computed using ERA5 P and T vs. ERA5 monthly PWV
            switch nargin
                case 0
                    load('matlab_extracted_data/geodetic_data.mat');
            
                    geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
                    geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
                    sta_list = cellstr(sta_list_geod);
            end
            
            % Extract height in ERA5 model
            data = dlmread(['DATOS_ERA5/GRID_GEOPOTENTIAL/Z_2021010100.csv'],',',1,0);
            y_max = max(data(:,2)); x_max = max(data(:,1));
            lat_ERA = data(1:x_max:end,3)';
            lon_ERA = data(1:x_max,4)';
            lat = rad2deg(geod_list(:,1)); lon = rad2deg(geod_list(:,2));
            % Mode interp2
            lat_g = reshape(data(:,3),x_max,y_max)';
            lon_g = reshape(data(:,4),x_max,y_max)';
            val_g = reshape(data(:,5),x_max,y_max)'/ERA_LEVEL.g0;
            h_ERA = interp2(lon_g,lat_g,val_g,lon,lat);
            h_GNSS = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(:,1)), rad2deg(geod_list(:,2)),geod_list(:,3));

            
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                t_sync = t;
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\COM_monthly\COM_ERA_' sta '_1961_2021.mat']);
                pwv_era = pwv(t>=datetime(2007,1,1));
                %figure();plot(t_sync,pwv_levera); hold on; plot(t_sync,pwv_era);
                disp(sta);
                disp(['Mean:  ' num2str(mean(pwv_era - pwv_levera,'omitnan'))]);
                means(i) = mean(pwv_era - pwv_levera,'omitnan');
                disp(['STD:   ' num2str(std(pwv_era - pwv_levera,'omitnan'))]);
                stds(i) = std(pwv_era - pwv_levera,'omitnan');
                m = corrcoef(pwv_era(isfinite(pwv_levera)),pwv_levera(isfinite(pwv_levera)));
                disp(['Corr:  ' num2str(m(1,2))]);
                disp(h_ERA(i) - h_GNSS(i));
            end
            
            h_diff = h_ERA - h_GNSS;
            figure(); plot(h_ERA - h_GNSS,stds,'o');  title('PWV_{ERA5} - PWV_{GNSS} standard deviation depending on height'); ylabel('std(PWV_{ERA5} - PWV_{GNSS} (mm))'); xlabel('h_{ERA5} - h_{GNSS} (m)');
            figure(); plot(h_ERA - h_GNSS,means,'o');
            hold on; plot(h_ERA([8,26]) - h_GNSS([8,26]),means([8,26]),'ro');
            
            h_GNSS([8,26]) = [];h_ERA([8,26]) = [];means_ = means; means_([8,26]) = []; %Ommit NEVA and CAAL
            lr = fitlm(h_ERA - h_GNSS,means_);
            ic = lr.Coefficients{1,1}; m = lr.Coefficients{2,1};
            R2 = lr.Rsquared.Ordinary;
            
             
            hold on; plot([-1200,500],[-1200,500]*m + ic,'k-');
            text(-1700,0,[sprintf('Mean difference = %0.3f %0.4fh',ic,m) newline sprintf('R^2 = %0.3f', R2)]);
            title('PWV_{ERA5} - PWV_{GNSS} mean difference depending on height'); ylabel('PWV_{ERA5} - PWV_{GNSS} (mm)'); xlabel('h_{ERA5} - h_{GNSS} (m)');
            
            
        end
        
    end
    
    methods (Static, Access = public) % Estudio espacial de correlaciones de variables PWV, precip, Tª, SPCI, SPI, SPEI
        
        function plotSpatialCorrelDifferential(sta_list,var,phas)
            switch nargin
                case 2
                    phas = 0; % variable to add phases to plot.
            end
            
            var = (var - mean(var))*10;
            
            f = figure();
            set(f,'Position',[819.6667 445.6667 1.6613e+03 800.7]);

            % Plot Andalucia map:
            subplot(1,4,1:3);
            I = imread('Mapa_fisico_Andalucia.jpg'); 
            hold on;
            [xmin,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-7.5));
            [xmax,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-1.6));
            [~,ymin] = GF.geod2plan_andal(deg2rad(36),deg2rad(-4.5));
            [~,ymax] = GF.geod2plan_andal(deg2rad(38.7),deg2rad(-4.5));
            h = image([xmin,xmax],flip([ymin,ymax]),I);
            hold off;
            uistack(h,'bottom');
            alpha(h,.4); hold on;

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i)*10;
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                if val>0
                    color = 'g';
                else
                    color = 'r';
                end
                p = scatter(x,y,12*abs(val).^2,color,'filled','MarkerEdgeColor','k'); hold on;
                p.MarkerFaceAlpha = .5;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)+366/4-226);
                    quiver(x,y,cos(ang)*1e5/5,sin(ang)*1e5/5,'k','LineWidth',3);
                end
                
                subplot(1,4,4);
                p_2 = scatter(h*1e-3,val/100,color,'filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(val/100),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of deviation from mean correlation']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'g','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,4*1e6,'          0.1 correlation deviation');
            
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Correlation coefficient'); title(['Altimetric distribution of deviation from mean correlation']);

        end
        
        function plotSpatialCorrel(sta_list,var,phas)
            switch nargin
                case 2
                    phas = 0; % variable to add phases to plot.
            end
            
            f = figure();
            set(f,'Position',[819.6667 445.6667 1.6613e+03 800.7]);

            % Plot Andalucia map:
            subplot(1,4,1:3);
            I = imread('Mapa_fisico_Andalucia.jpg'); 
            hold on;
            [xmin,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-7.5));
            [xmax,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-1.6));
            [~,ymin] = GF.geod2plan_andal(deg2rad(36),deg2rad(-4.5));
            [~,ymax] = GF.geod2plan_andal(deg2rad(38.7),deg2rad(-4.5));
            h = image([xmin,xmax],flip([ymin,ymax]),I);
            hold off;
            uistack(h,'bottom');
            alpha(h,.4); hold on;

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i)*10;
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                
                p = scatter(x,y,12*abs(val).^2,'m','filled','MarkerEdgeColor','k'); hold on;
                p.MarkerFaceAlpha = .5;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)+366/4-226);
                    quiver(x,y,cos(ang)*1e5/5,sin(ang)*1e5/5,'k','LineWidth',3);
                end
                
                subplot(1,4,4);
                p_2 = scatter(h*1e-3,val/10,'m','filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(val/10),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of correlation']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'m','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,4*1e6,'          100% correlation');
            
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Correlation coefficient'); title(['Altimetric distribution of correlation']);

        end
        
        function plotSpatialCorrelMixed(sta_list,var,phas)
            switch nargin
                case 2
                    phas = 0; % variable to add phases to plot.
            end
            
            var_dev = var - mean(var);
            
            f = figure();
            set(f,'Position',[819.6667 445.6667 1.6613e+03 800.7]);

            % Plot Andalucia map:
            subplot(1,4,1:3);
            I = imread('Mapa_fisico_Andalucia.jpg'); 
            hold on;
            [xmin,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-7.5));
            [xmax,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-1.6));
            [~,ymin] = GF.geod2plan_andal(deg2rad(36),deg2rad(-4.5));
            [~,ymax] = GF.geod2plan_andal(deg2rad(38.7),deg2rad(-4.5));
            h = image([xmin,xmax],flip([ymin,ymax]),I);
            hold off;
            uistack(h,'bottom');
            alpha(h,.4); hold on;

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i)*10;
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                
                p = scatter(x,y,12*abs(val).^2,'b','filled','MarkerEdgeColor','k'); hold on;
                p.MarkerFaceAlpha = .3;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)+366/4-226);
                    quiver(x,y,cos(ang)*1e5/5,sin(ang)*1e5/5,'k','LineWidth',3);
                end
                % Difference bar
                if var_dev(i)>0
                    color = 'g';
                else
                    color = 'r';
                end
                plot([x,x],[y,y+var_dev(i)*2e5],color,'linewidth',5);
                subplot(1,4,4);
                p_2 = scatter(h*1e-3,val/10,'b','filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(val/10),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of correlation']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'b','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .3;
            text(5*1e5,4*1e6,'          100% correlation');
            
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Correlation coefficient'); title(['Altimetric distribution of correlation']);

        end
        
        function plotSpatialCorrelGradient(sta_list,var,phas)
            switch nargin
                case 2
                    phas = 0; % variable to add phases to plot.
            end
                        
            f = figure();
            set(f,'Position',[819.6667 445.6667 1.6613e+03 800.7]);

            % Plot Andalucia map:
            subplot(1,4,1:3);
            I = imread('Mapa_fisico_Andalucia.jpg'); 
            hold on;
            [xmin,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-7.5));
            [xmax,~] = GF.geod2plan_andal(deg2rad(37.5),deg2rad(-1.6));
            [~,ymin] = GF.geod2plan_andal(deg2rad(36),deg2rad(-4.5));
            [~,ymax] = GF.geod2plan_andal(deg2rad(38.7),deg2rad(-4.5));
            h = image([xmin,xmax],flip([ymin,ymax]),I);
            hold off;
            uistack(h,'bottom');
            alpha(h,.4); hold on;

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i);
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                
                p = scatter(x,y,24^2,'b','filled','MarkerEdgeColor','k'); hold on;
                disp(sta);
                disp((var(i)-0.75)/0.25);
                p.MarkerFaceAlpha = (var(i)-0.75)/0.25;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)+366/4-226);
                    quiver(x,y,cos(ang)*1e5/5,sin(ang)*1e5/5,'k','LineWidth',3);
                end
%                 % Difference bar
%                 if var_dev(i)>0
%                     color = 'g';
%                 else
%                     color = 'r';
%                 end
%                 plot([x,x],[y,y+var_dev(i)*2e5],color,'linewidth',5);
%                 subplot(1,4,4);
%                 p_2 = scatter(h*1e-3,val/10,'b','filled','MarkerEdgeColor','k'); hold on;
%                 text(double(h*1e-3),double(val/10),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of correlation']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'b','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .3;
            text(5*1e5,4*1e6,'          100% correlation');
            
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Correlation coefficient'); title(['Altimetric distribution of correlation']);

        end
        
        
        function plotHistoCorrel(sta_list,var,y_lim)
            
            load('matlab_extracted_data/geodetic_data.mat');
            var_area = {[],[],[]}; %Empty arrays that will contain values to plot in histogram by areas
            names_area = {{},{},{}}; %Empty cell arrays that will contain names to plot in histogram by areas
            color_area = {[],[],[]};
            
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i);
                
                i_area = ERA_LEVEL.area(find(ismember(ERA_LEVEL.sta_list_area,sta)));
                var_area{i_area} = [var_area{i_area}; val];
                names_area{i_area} = [names_area{i_area},{sta}];
                color_area{i_area} = [color_area{i_area};ERA_LEVEL.area_colors(i_area,:)];
            end
            var_area = [var_area{1};var_area{2};var_area{3} ];
            names_area = [names_area{1} names_area{2} names_area{3} ];
            names_area_cat = categorical(names_area);
            names_area_cat = reordercats(names_area_cat,names_area);
            color_area = [color_area{1};color_area{2};color_area{3} ];
            
            %figure(); 
            b = bar(names_area_cat,var_area); ylim(y_lim);
            b.FaceColor = 'flat'; b.CData(:,:) = color_area;
            
%             ylabel('SPCI-SPEI correlation coefficient'); xlabel('Station name');
        end
        
        
        function correlPWVTempDaily
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/DER_daily/SYNC_DER_' sta_list{i} '_2007_2021.mat'], 't', 'pwv_levera');
                load(['synced_mat_data/LEV_daily/SYNC_LEV_' sta_list{i} '_2007_2021.mat'], 't', 'temp');
                pwv = pwv_levera;
                
                ind = isfinite(pwv);
                cc = corrcoef(pwv(ind),temp(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrel(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlPWVTempMonthly
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/DER_monthly/SYNC_DER_' sta_list{i} '_2007_2021.mat'], 't', 'pwv_levera');
                load(['synced_mat_data/LEV_monthly/SYNC_LEV_' sta_list{i} '_2007_2021.mat'], 't', 'temp');
                pwv = pwv_levera;
                
                ind = isfinite(pwv);
                cc = corrcoef(pwv(ind),temp(ind));
                list_cc(i) = cc(1,2);
            end
            disp(list_cc);

%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        
        function correlPWVPrecMonthly
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit CARG, EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_pval = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/DER_monthly/SYNC_DER_' sta_list{i} '_2007_2021.mat'], 't', 'pwv_levera');
                load(['synced_mat_data/GRI_monthly/SYNC_GRI_' sta_list{i} '_2007_2021.mat'], 't', 'prec');
                pwv = pwv_levera;
                
                ind = isfinite(pwv);
                [cc,pval] = corrcoef(pwv(ind),prec(ind));
                list_cc(i) = cc(1,2);
                list_pval(i) = pval(1,2);
            end
            
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[-0.4 0]);
            hold on; yyaxis right; bar(sta_list,list_pval);
            disp(list_cc);
        end
        
        function correlPWVSPEIMonthly
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/DER_monthly/SYNC_DER_' sta_list{i} '_2007_2021.mat'], 't', 'pwv_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei01');
                pwv = pwv_levera;
                
                ind = isfinite(pwv);
                cc = corrcoef(pwv(ind),spei01(ind));
                list_cc(i) = cc(1,2);
            end
            ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
            ERA_LEVEL.plotSpatialCorrel(sta_list,list_cc);
        end
        
        
        function correlSPCISPEI12
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci12_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei12');
                spci12 = spci12_levera;
                
                ind = isfinite(spci12);
                cc = corrcoef(spci12(ind),spei12(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPI12
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci12_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spi12');
                spci12 = spci12_levera;
                
                ind = isfinite(spci12);
                cc = corrcoef(spci12(ind),spi12(ind));
                list_cc(i) = cc(1,2);
            end
            ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
            ERA_LEVEL.plotSpatialCorrel(sta_list,list_cc);
        end
        
        function correlSPISPEI
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci12_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spi12','spei12');
                spci12 = spci12_levera;
                
                ind = isfinite(spci12);
                cc_spi = corrcoef(spci12(ind),spi12(ind));
                cc_spei = corrcoef(spci12(ind),spei12(ind));
                list_cc(i) = cc_spei(1,2) - cc_spi(1,2);
            end
            ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
            ERA_LEVEL.plotSpatialCorrel(sta_list,list_cc);
        end
        
        function correlSPCISPEI03
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci03_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei03');
                spci03 = spci03_levera;
                
                ind = isfinite(spci03);
                cc = corrcoef(spci03(ind),spei03(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI06
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci06_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei06');
                spci06 = spci06_levera;
                
                ind = isfinite(spci06);
                cc = corrcoef(spci06(ind),spei06(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI09
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci09_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei09');
                spci09 = spci09_levera;
                
                ind = isfinite(spci09);
                cc = corrcoef(spci09(ind),spei09(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI24
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci24_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei24');
                spci24 = spci24_levera;
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function pruebaVICAVIAR
            
            figure();
            
            load('synced_mat_data\DER_monthly\SYNC_DER_VIAR_2007_2021.mat');
            subplot(2,1,1); plot(t,pwv_levera); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
            
            load('synced_mat_data\DER_monthly\SYNC_DER_VICA_2007_2021.mat');
            subplot(2,1,2); plot(t,pwv_levera); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
            
            
            
            figure();
            
            load('synced_mat_data\PCI_monthly\SYNC_PCI_VIAR_2007_2021.mat');
            load('synced_mat_data\SPI_monthly\SYNC_SPI_VIAR_2007_2021.mat');
            ind_VIAR = isfinite(spci12_levera);
            cc_VIAR = corrcoef(spei12(ind_VIAR),spci12_levera(ind_VIAR)); 
            subplot(2,1,1); plot(t,spci12_levera); xlim([datetime(2007,1,1) datetime(2022,1,1)]); ylim([-2,3]);
            
            load('synced_mat_data\PCI_monthly\SYNC_PCI_VICA_2007_2021.mat');
            load('synced_mat_data\SPI_monthly\SYNC_SPI_VICA_2007_2021.mat');
            ind_VICA = isfinite(spci12_levera);
            cc_VICA = corrcoef(spei12(ind_VICA),spci12_levera(ind_VICA));
            subplot(2,1,2); plot(t,spci12_levera); xlim([datetime(2007,1,1) datetime(2022,1,1)]); ylim([-2,3]);
            
            disp(cc_VIAR(1,2)); 
            disp(cc_VICA(1,2)); 
            
            
            ind_CONJ = and(ind_VICA,ind_VIAR);
            cc_VIAR = corrcoef(spei12(ind_CONJ),spci12_levera(ind_CONJ));
            
            disp(cc_VIAR(1,2)); 
            disp(cc_VICA(1,2)); 
            
            
        end
        
        
        function correlMETEOGeneral
            
            figure(); tiledlayout(1,2,'TileSpacing','tight');
            nexttile();ERA_LEVEL.correlPWVTempMonthly; title('PWV/Temperature'); xlabel('Station name'); ylabel('Correlation coefficient');
            nexttile();ERA_LEVEL.correlPWVPrecMonthly; title('PWV/Precipitation');xlabel('Station name');
            
        end
        
        function correlSPCISPEIGeneral
            
            figure(); tiledlayout(1,3,'TileSpacing','tight');
            nexttile();ERA_LEVEL.correlSPCISPEI06; title('GNSS-SPCI, 6-months'); xlabel('Station name'); ylabel('SPEI-SPCI correlation coefficient');
            nexttile();ERA_LEVEL.correlSPCISPEI12; title('GNSS-SPCI, 12-months');xlabel('Station name');
            nexttile();ERA_LEVEL.correlSPCISPEI24; title('GNSS-SPCI, 24-months');xlabel('Station name');
            
        end
        
        
        function correlSPCIvsSPI12
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci12_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei12','spi12');
                spci12 = spci12_levera;
                
                ind = isfinite(spci12);
                cc = corrcoef(spci12(ind),spei12(ind));
                list_cc(i,1) = cc(1,2);
                list_rms(i,1) = rms(spci12(ind)-spei12(ind));
                cc = corrcoef(spi12(ind),spei12(ind));
                list_cc(i,2) = cc(1,2);
                list_rms(i,2) = rms(spi12(ind)-spei12(ind));
                
                disp(sta_list{i});
                disp(list_cc(i,:));
                disp(list_rms(i,:));
            end
            disp(sum(list_cc(:,1)>list_cc(:,2)));
            disp(sum(list_rms(:,1)<list_rms(:,2)));
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
%             ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCIvsSPI06
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci06_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei06','spi06');
                spci06 = spci06_levera;
                
                ind = isfinite(spci06);
                cc = corrcoef(spci06(ind),spei06(ind));
                list_cc(i,1) = cc(1,2);
                list_rms(i,1) = rms(spci06(ind)-spei06(ind));
                cc = corrcoef(spi06(ind),spei06(ind));
                list_cc(i,2) = cc(1,2);
                list_rms(i,2) = rms(spi06(ind)-spei06(ind));
                
                disp(sta_list{i});
                disp(list_cc(i,:));
                disp(list_rms(i,:));
            end
            disp(sum(list_cc(:,1)>list_cc(:,2)));
            disp(sum(list_rms(:,1)<list_rms(:,2)));
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
%             ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCIvsSPI24
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci24_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei24','spi24');
                spci24 = spci24_levera;
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i,1) = cc(1,2);
                list_rms(i,1) = rms(spci24(ind)-spei24(ind));
                cc = corrcoef(spi24(ind),spei24(ind));
                list_cc(i,2) = cc(1,2);
                list_rms(i,2) = rms(spi24(ind)-spei24(ind));
                
                disp(sta_list{i});
                disp(list_cc(i,:));
                disp(list_rms(i,:));
            end
            
            disp(sum(list_cc(:,1)>list_cc(:,2)));
            disp(sum(list_rms(:,1)<list_rms(:,2)));
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
%             ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        
    end
    
    
    methods (Static, Access = public) % Capital cities stations' 
        
        % FLUJO DE PROCESADO SERIES MEDIANAS
        % 1- REDIAM.findRadiusMeteoStation (Pressure/Temperature)
        %     Find meteo stations below defined radius set
        % 2- ERA_LEVEL.computeMeanMeteoHeightCapitals (Pressure/Temperature)
        %     Compute median time series with height reduction
        % 3- ERA_LEVEL.plotMeanMeteoHeightCapitals (Pressure/Temperature)
        %     Plot individual and median time series with heigh reduction
        %     for quality check
        % 4- ERA_LEVEL.computeRMSTableCapitals (Pressure/Temperature)
        
        % Updated with respect to the functions in class REDIAM because
        % GNSS ellipsoidal height is converted to orthometric height!
        
        function computeMeanMeteoHeightCapitalsTemperature
            % Compute mean (median) meteo values for selected datasets
            % Including height reduction to GNSS receiver level!
            % In facts it computes for all the GNSS stations, all with
            % radius 10km.
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_temperature.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_temperature.mat');
            temp_sta_meteo_rad = sta_meteo_rad;
            radius_table = table();
            for i=1:size(sta_list_geod,1)
                %figure();
                r = 2; %r = 10km
                if isnan(r)
                    continue;
                end
                data = [];
                del_ind_temp = []; % deletion index
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                        del_ind_temp = [del_ind_temp; j];
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat']);
                        if all(all(isnan(temp)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                            del_ind_temp = [del_ind_temp; j];
                        else
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)), rad2deg(geod_list(i,2)), geod_list(i,3)); % Ellipsoidal to orthometric height!
                            delta_h =  h_gnss - h_met;
                            data = [data, temp-6.5*delta_h*1e-3];
                        end
                    end
                end
%                 temp_sta_meteo_rad{r,i}(del_ind_temp,:) = [];
%                 legend(temp_sta_meteo_rad{r,i});
                
                median_data = median(data,2,'omitnan');
                %subplot(2,1,2); plot(t,median_data);ylim([-10,40]); ylabel('Temperature (ºC)');
                temp = median_data;
                save(['synced_mat_data/CLI_daily/SYNC_CLI_' sta_list_geod(i,:) '_2007_2021.mat'],'t','temp','-append');
            end
        end
        
        function computeMeanMeteoHeightCapitalsPressure
            % Compute mean (median) meteo values for selected datasets
            % Including height reduction to GNSS receiver level!
            % In facts it computes for all the GNSS stations, all with
            % radius 10km.
            % Height reduction by barometric formula with isotermic
            % atmosphere.
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_pressure.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_pressure.mat');
            temp_sta_meteo_rad = sta_meteo_rad;
            radius_table = table();
            for i=1:size(sta_list_geod,1)
                %figure();
                r = 2; %r = 10km
                if isnan(r)
                    continue;
                end
                data = [];
                del_ind_temp = []; % deletion index
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                        del_ind_temp = [del_ind_temp; j];
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat']);
                        if all(all(isnan(pres)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                            del_ind_temp = [del_ind_temp; j];
                        elseif any(strcmp({met_sta},{'PART001','EARM35','PART008','SIVA55'}))
                            % Not take into account these problematic
                            % stations.
                            continue
                        else
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)), rad2deg(geod_list(i,2)), geod_list(i,3)); % Ellipsoidal to orthometric height!
                            delta_h =  h_gnss - h_met;
                            data = [data, REDIAM.pressureReduction(pres,0,-delta_h)];
                        end
                    end
                end
%                 temp_sta_meteo_rad{r,i}(del_ind_temp,:) = [];
%                 legend(temp_sta_meteo_rad{r,i});
                
                median_data = median(data,2,'omitnan');
                %subplot(2,1,2); plot(t,median_data);ylim([-10,40]); ylabel('Temperature (ºC)');
                pres = median_data;
                save(['synced_mat_data/CLI_daily/SYNC_CLI_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pres','-append');
            end
        end
        
        function plotMeanMeteoHeightCapitalsTemperature
            % Plots computed median signal for capital cities excepting Huelva.
            capitals = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            capital_ind = [3,4,17,43,15,14,37,24,26,42,38,19,18];
            % For adding the individual stations' plots
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_temperature.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_temperature.mat');
            r=2; %10km
            
            for i=capital_ind
                figure(10+i); hold on;
                load(['synced_mat_data\CLI_daily\SYNC_CLI_' sta_list_geod(i,:) '_2007_2021.mat']);
                plot(t,temp,'k','LineWidth',4); title(sta_list_geod(i,:));
                
                % Add the individual stations' plot over the main plot
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat']);
                        if all(all(isnan(temp)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                        else
                            mean(temp);
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)), rad2deg(geod_list(i,2)), geod_list(i,3)); % Ellipsoidal to orthometric height!
                            delta_h =  h_gnss - h_met;
                            plot(temp-6.5*delta_h*1e-3);
                        end
                    end
                end
            end
            
        end
        
        function plotMeanMeteoHeightCapitalsPressure
            % Plots computed median signal for capital cities excepting Huelva.
            % Height reduction by barometric formula with isotermic
            % atmosphere.
            capitals = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            capital_ind = [3,4,17,43,15,14,37,24,26,42,38,19,18];
            % For adding the individual stations' plots
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_pressure.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_pressure.mat');
            r=2;
            
            for i=capital_ind
                figure(10+i); hold on;
                load(['synced_mat_data\CLI_daily\SYNC_CLI_' sta_list_geod(i,:) '_2007_2021.mat']);
                plot(t,pres,'k','LineWidth',4); title(sta_list_geod(i,:));
                
                % Add the individual stations' plot over the main plot
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat']);
                        if all(all(isnan(pres)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                        elseif any(strcmp({met_sta},{'PART001','EARM35','PART008','SIVA55'}))
                            % Not take into account these problematic
                            % stations.
                            continue
                        else
                            mean(pres);
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = ERA_LEVEL.elips2ortometricHeight(rad2deg(geod_list(i,1)), rad2deg(geod_list(i,2)), geod_list(i,3)); % Ellipsoidal to orthometric height!
                            delta_h =  h_gnss - h_met;
                            pres = REDIAM.pressureReduction(pres,0,-delta_h);
                            plot(pres);
                        end
                    end
                end
                sta_meteo_list = sta_meteo_rad{r,i};
                sta_meteo_list(2:end+1) = sta_meteo_list;
                sta_meteo_list(1) = {'Median'};
                %legend(sta_meteo_list);
            end
            
        end
        
        function computeRMSTableCapitalsTemperature
            % Compute mean (median) meteo values for selected datasets
            % Including height reduction to GNSS receiver level!
            % In facts it computes for all the GNSS stations, all with
            % radius 10km.
            
            capitals = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            capital_ind = [3,4,17,43,15,14,37,24,26,42,38,19,18];
            
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_temperature.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_temperature.mat');
            temp_sta_meteo_rad = sta_meteo_rad;
            radius_table = table();
            for i=capital_ind
                disp(sta_list_geod(i,:));
                %figure();
                r = 2; %r = 10km
                if isnan(r)
                    continue;
                end
                data = [];
                del_ind_temp = []; % deletion index
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                        del_ind_temp = [del_ind_temp; j];
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_TEMP.mat']);
                        if all(all(isnan(temp)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                            del_ind_temp = [del_ind_temp; j];
                        else
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = geod_list(i,3);
                            delta_h =  h_gnss - h_met;
                            data = [data, temp-6.5*delta_h*1e-3];
                        end
                    end
%                 temp_sta_meteo_rad{r,i}(del_ind_temp,:) = [];
%                 legend(temp_sta_meteo_rad{r,i});
                end
                med = median(data,2,'omitnan');
                resid = data-med;
                resid(~isfinite(resid)) = NaN;
                threshold = 20; %Threshold of 20ºC of deviation of median to consider as outlier
                resid(resid.^2>threshold.^2) = NaN;
                bias_ = rms(mean(resid,1,'omitnan'));
                std_ = rms(std(resid,1,'omitnan')); %rms for all stations
                cover = sum(isfinite(med))/length(med)*100; %Coverage of the time period in %
                sta_number = size(data,2);
                data_total = [sta_number,cover,bias_,std_];
                disp(data_total);
                %radius_table(string(sta_list_geod(i,:)),:) = data_total; % RMS in degrees
            end
            %disp(radius_table);
            
        end
        
        function computeRMSTableCapitalsPressure
            % Compute mean (median) meteo values for selected datasets
            % Including height reduction to GNSS receiver level!
            % In facts it computes for all the GNSS stations, all with
            % radius 10km.
            
            capitals = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            capital_ind = [3,4,17,43,15,14,37,24,26,42,38,19,18];
            
            load('matlab_extracted_data/geodetic_data.mat');
            load('matlab_extracted_data/radius_meteo_stations_pressure.mat');
            load('DATOS_CLIMA/Datos_estaciones_CLIMA_pressure.mat');
            temp_sta_meteo_rad = sta_meteo_rad;
            radius_table = table();
            for i=capital_ind
                disp(sta_list_geod(i,:));
                %figure();
                r = 2; %r = 10km
                if isnan(r)
                    continue;
                end
                data = [];
                del_ind_temp = []; % deletion index
                for j=1:sum(num_rad(1:r,i))
                    met_sta = sta_meteo_rad{r,i}{j};
                    if ~isfile(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat'])
                        disp(['File ' met_sta ' (temp) does not exist.']);
                        del_ind_temp = [del_ind_temp; j];
                    else
                        load(['DATOS_CLIMA/synced_clima_data/SYNCED_CLIMA_' met_sta '_PRES.mat']);
                        if all(all(isnan(pres)))
                            disp(['File ' met_sta ' (temp) contains no data.']);
                            del_ind_temp = [del_ind_temp; j];
                        elseif any(strcmp({met_sta},{'PART001','EARM35','PART008','SIVA55'}))
                            % Not take into account these problematic
                            % stations.
                            continue
                        else
                            h_met = h(string(id)==string(met_sta));
                            h_gnss = geod_list(i,3);
                            delta_h =  h_gnss - h_met;
                            data = [data, REDIAM.pressureReduction(pres,0,-delta_h)];
                        end
                    end
%                 temp_sta_meteo_rad{r,i}(del_ind_temp,:) = [];
%                 legend(temp_sta_meteo_rad{r,i});
                end
                med = median(data,2,'omitnan');
                resid = data-med;
                resid(~isfinite(resid)) = NaN;
                threshold = 20; %Threshold of 20ºC of deviation of median to consider as outlier
                resid(resid.^2>threshold.^2) = NaN;
                bias_ = rms(mean(resid,1,'omitnan'));
                std_ = rms(std(resid,1,'omitnan')); %rms for all stations
                cover = sum(isfinite(med))/length(med)*100; %Coverage of the time period in %
                sta_number = size(data,2);
                data_total = [sta_number,cover,bias_,std_];
                disp(data_total);
                %radius_table(string(sta_list_geod(i,:)),:) = data_total; % RMS in degrees
            end
            %disp(radius_table);
            
        end
        
        function computeMETEOTemperaturePressurePWV
            % GPS METEO PWV
            sta_list = REDIAM.GNSS;
            sta_list = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            i=0;
            load('matlab_extracted_data/geodetic_data.mat');
            
            for sta = sta_list
                load(['synced_mat_data\CLI_daily\SYNC_CLI_',sta{:},'_2007_2021.mat']);
                load(['synced_mat_data\TRO_daily\SYNC_TRO_',sta{:},'_2007_2021.mat']);
                ind = strcmp(sta,string(sta_list_geod));
                
                % Computation:
                P = pres;
                lat = geod_list(ind,1);
                h = geod_list(ind,3);
                zhd = 0.0022768 * P(:) .* (1 + 0.00266 * cos(2*lat(:)) + 0.00000028 * h(:)); % lat in rad! original goGPS in deg
                
                zwd_rediam = (ztd - zhd)*100; %cm
                pwv_rediam = PROC.PWV(zwd_rediam,temp)*10; %mm
                
                save(['synced_mat_data\DER_daily\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_rediam','pwv_rediam');
            end
        end
        
        % Funciones de comparación ERA5 vs. Meteo 
        function compareERATemperatureData()
            
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\CLI_daily\SYNC_CLI_',sta{:},'_2007_2021.mat']);
                temp_CLI = temp;
                load(['synced_mat_data\LEV_daily\SYNC_LEV_',sta{:},'_2007_2021.mat']);
                temp_ERA = temp - 273.15; %ºC
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,temp_CLI,'k-');
                plot(t,temp_ERA,'r-');
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(temp_ERA-temp_CLI,'omitnan'),std(temp_ERA-temp_CLI,'omitnan')]);
            end
        end
        
        function compareERAPressureData()
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA1','UJAE','CRDB','COBA','SEVI','MALA','MLGA','UCAD','SFER','HULV','HUEL'};
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\CLI_daily\SYNC_CLI_',sta{:},'_2007_2021.mat']);
                pres_CLI = pres;
                load(['synced_mat_data\LEV_daily\SYNC_LEV_',sta{:},'_2007_2021.mat']);
                pres_ERA = pres; %*1e-2; %Pa to hPa
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pres_ERA,'r-');
                plot(t,pres_CLI,'k-');
                 legend({'REDIAM','ERA5'});
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(pres_ERA-pres_CLI,'omitnan'),std(pres_ERA-pres_CLI,'omitnan')]);
            end
        end
    end
end

