classdef ERA_EUREF
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant,Access=public)
        
    stations = upper({'ALME','CARG','CEU1','COBA','HUEL','MALA','MELI','MOFR','TALR',...
                    'VICA','ZFRA','SFER','algc','almr','arac','caal','cabr','caza',...
                    'crdb','hulv','huov','lebr','mlga','osun','palc',...
                    'pozo','ujae','viar',...
                    'GRA3','UCA3','SEV3','RON3','MOT3','AND3',...
                    'ALJI', 'AREZ', 'CAST', 'EPCU', 'LIJA', 'LOJA', 'NEVA',...
                    'PALM', 'PILA', 'RUBI', 'TGIL', 'TIOU'}');
                
    comp_stations = {'ALGC','AREZ','CAAL','CABR','CAST','CEU1','COBA','CRDB',...
            'HUEL','LIJA','MALA','MOT3','NEVA','OSUN','PALC',...
            'POZO','SEV3','TALR','UCA3','UJAE','VIAR','ZFRA'}; %Stations with available rediam data.
        
    selec_stations = {'CABR','CEU1','CRDB',...
            'HUEL','MOT3','OSUN',...
            'POZO','UJAE','VIAR'}; %Stations with a visually good and continuous climate data
    end
    
    properties (Constant,Access=public)
        stations_EUREF = {'ALME','CARG','CEU1','COBA','HUEL','MALA','MELI','SFER'};%,'TAR0'};
        stations_EUREF_repro2 = {'ALME','CEU1','COBA','HUEL','MALA','MELI','SFER'};
        stations_IGS = {'SFER','MELI','ROAG'};
    end
   %% ERA5
   
   % PROCESSING FLUX FOR ERA5 DATA
   %
   % 1- Download from https://cds.climate.copernicus.eu/#!/search?text=era5
   %    (hourly single level data)
   % 2- Use DeGRIB from NOAA for extracting CSV files
   %    Example: degrib\bin\degrib "filename.grib" -C -msg all -nMet -Csv -nameStyle 3 -namePath "C:\ndfd\degrib\data\ERA5"
   % 3- ERA_EUREF.extractERAPressureData
   %    To extract data from csv to synced hourly data.
   %    The data for the exact point is calculated by bilinear interpolation.
   % 4- ERA_EUREF.resampleERADataTemperaturePressure('daily');
   %    To resample data using daily means.
   
    methods(Static, Access = public)
        
        function extractERADataPWV()
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PWV/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PWV/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/geodetic_data.mat');
            lat = rad2deg(geod_list(:,1)); lon = rad2deg(geod_list(:,2));
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;
            
            
            n_sta = size(sta_list_geod,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,size(sta_list_geod,1));
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,5:14),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/PWV/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(sta_list_geod,1)
                disp(sta_list_geod(i,:));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv' ,'-append');
            end
        end
        
        function extractERATemperatureData()
            % After DeGRIB, extract pressure data from resulting csv files.
            % mode for bilinear interpolation inside de ERA5 grid is
            % activated.
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/TEMP/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/TEMP/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/geodetic_data.mat');
            lat = rad2deg(geod_list(:,1)); lon = rad2deg(geod_list(:,2));
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;
            
            
            n_sta = size(sta_list_geod,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,size(sta_list_geod,1));
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,4:13),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/TEMP/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(sta_list_geod,1)
                disp(sta_list_geod(i,:));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                temp = pwv; % Because this function is for temperature
                load(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv');
                save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv','temp');
            end
        end
        
        function extractERAPressureData()
            % After DeGRIB, extract pressure data from resulting csv files.
            % mode for bilinear interpolation inside de ERA5 grid is
            % activated.
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PRES/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PRES/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/geodetic_data.mat');
            lat = rad2deg(geod_list(:,1)); lon = rad2deg(geod_list(:,2));
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;
            
            
            n_sta = size(sta_list_geod,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,size(sta_list_geod,1));
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,4:13),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/PRES/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(sta_list_geod,1)
                disp(sta_list_geod(i,:));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                pres = pwv; % Because this function is for pressure
                save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pres','-append');
            end
        end
        
        function resampleERADataTemperature(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\ERA_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                load(['synced_mat_data\ERA_hourly\' list(f,:)]);
                tt = timetable(t,pwv,temp);
                tt = retime(tt,sampling,'mean');
                t = tt.t; pwv = tt.pwv; temp = tt.temp;
                save(['synced_mat_data\ERA_' sampling '\' list(f,:)],'t','pwv','temp');
            end
        end
        
        function resampleERADataTemperaturePressure(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\ERA_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                load(['synced_mat_data\ERA_hourly\' list(f,:)]);
                tt = timetable(t,pwv,temp,pres);
                tt = retime(tt,sampling,'mean');
                t = tt.t; pwv = tt.pwv; temp = tt.temp; pres = tt.pres;
                save(['synced_mat_data\ERA_' sampling '\' list(f,:)],'t','pwv','temp','pres');
            end
        end
        
    end
    
    %% Data extraction for comparison in meteorological sites.
    methods (Static, Access = public)
        
        function extractERAPrecipitationDataMETEO()
            % WARNING!! Input data of RESIAM stations has been manually converted to have
            % geografic coordinates.
            % After DeGRIB, extract pressure data from resulting csv files.
            % mode for bilinear interpolation inside de ERA5 grid is
            % activated.
            % Interpolated to meteo stations' location!!
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PREC/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PREC/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/REDIAM_data_table_latlon.mat');
            % Pasar de coordenadas locales huso 30 a latlong
            
            lat = tab{:,6}; lon = tab{:,5};
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;

            n_sta = size(tab,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,n_sta);
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,4:13),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/PREC/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(tab,1)
                disp(tab(i,1));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                prec = pwv; % Because this function is for pressure
                save(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','prec');%,'-append');
            end
        end
        
        function resampleERADataPrecipitationMETEO(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\METEO_ERA_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                disp(f);
                load(['synced_mat_data\METEO_ERA_hourly\' list(f,:)]);
                tt = timetable(t,prec);
                tt = retime(tt,sampling,'mean');
                t = tt.t; prec = tt.prec;
                save(['synced_mat_data\METEO_ERA_' sampling '\' list(f,:)],'t','prec');
            end
        end
        
        function extractERASingleTemperatureDataMETEO()
            % WARNING!! Input data of RESIAM stations has been manually converted to have
            % geografic coordinates.
            % After DeGRIB, extract pressure data from resulting csv files.
            % mode for bilinear interpolation inside de ERA5 grid is
            % activated.
            % Interpolated to meteo stations' location!!
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/TEMP/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/TEMP/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/REDIAM_data_table_latlon.mat');
            % Pasar de coordenadas locales huso 30 a latlong
            
            lat = tab{:,6}; lon = tab{:,5};
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;

            n_sta = size(tab,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,n_sta);
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,4:13),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/TEMP/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(tab,1)
                disp(tab(i,1));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                sin_temp = pwv - 273.15; % Because this function is for temperature, and in Degree
                if isfile(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'])
                    save(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','sin_temp','-append');%,'-append');
                else
                    save(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','sin_temp');
                end
            end
        end
        
        function extractERASinglePressureDataMETEO()
            % WARNING!! Input data of RESIAM stations has been manually converted to have
            % geografic coordinates.
            % After DeGRIB, extract pressure data from resulting csv files.
            % mode for bilinear interpolation inside de ERA5 grid is
            % activated.
            % Interpolated to meteo stations' location!!
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PRES/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PRES/' list(1,:)],',',1,2);
            lat_ERA = data(1:26:end,1)';
            lon_ERA = data(1:26,2)';
            load('matlab_extracted_data/REDIAM_data_table_latlon.mat');
            % Pasar de coordenadas locales huso 30 a latlong
            
            lat = tab{:,6}; lon = tab{:,5};
            % For nearest value (desactivated)
%             ind_lat = abs(lat-lat_ERA); ind_lon = abs(lon-lon_ERA);
%             [~,ind_lat] = min(ind_lat,[],2); [~,ind_lon] = min(ind_lon,[],2);
%             ind = (ind_lat-1)*26 + ind_lon;

            n_sta = size(tab,1);
            t_ERA = NaT(n_files,1);
            pwv_ERA = NaN(n_files,n_sta);
            textprogressbar('Loading and transforming data from ERA5 files:     ')
            for j=1:n_files
                textprogressbar(j/n_files*100);
                t_ERA(j) = datetime(list(j,4:13),'InputFormat','yyyyMMddHH');
                data = dlmread(['DATOS_ERA5/PRES/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_sync,t_ERA);
            t = t_sync;
            for i=1:size(tab,1)
                disp(tab(i,1));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                sin_pres = pwv*1e-2; % Because this function is for pressure and convert to hPa
                if isfile(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'])
                    save(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','sin_pres','-append');%,'-append');
                else
                    save(['synced_mat_data/METEO_ERA_hourly/SYNC_ERA_' char(tab{i,1}) '_2007_2021.mat'],'t','sin_pres');
                end
            end
        end
        
        function resampleERADataAllSingleMETEO(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\METEO_ERA_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                disp(f);
                load(['synced_mat_data\METEO_ERA_hourly\' list(f,:)]);
                tt = timetable(t,prec,sin_pres,sin_temp);
                tt = retime(tt,sampling,'mean');
                t = tt.t; prec = tt.prec; sin_pres = tt.sin_pres; sin_temp = tt.sin_temp;
                save(['synced_mat_data\METEO_ERA_' sampling '\' list(f,:)],'t','prec','sin_pres','sin_temp');
            end
        end
        
    end
    %%
    
    methods(Static, Access = public)
        
        function compareERATemperatureData()
            
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\CLI_daily\SYNC_CLI_',sta{:},'_2007_2021.mat']);
                temp_CLI = temp;
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
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
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\CLI_daily\SYNC_CLI_',sta{:},'_2007_2021.mat']);
                pres_CLI = pres;
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
                pres_ERA = pres*1e-2; %Pa to hPa
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pres_CLI,'k-');
                plot(t,pres_ERA,'r-');
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(pres_ERA-pres_CLI,'omitnan'),std(pres_ERA-pres_CLI,'omitnan')]);
            end
        end
        
        function computeERATemperaturePressurePWV
            % GPS ERA5 PWV
            sta_list = REDIAM.GNSS;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            load('matlab_extracted_data/geodetic_data.mat');
            
            for sta = sta_list
                load(['synced_mat_data\TRO_daily\SYNC_TRO_',sta{:},'_2007_2021.mat']);
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
                ind = strcmp(sta,string(sta_list_geod));
                
                temp = temp - 273.15;
                pres = pres*1e-2;
                
                % Computation:
                P = pres;
                lat = geod_list(ind,1);
                h = geod_list(ind,3);
                zhd = 0.0022768 * P(:) ./ (1 - 0.00266 * cos(2*lat(:)) - 0.00000028 * h(:)); % lat in rad! original goGPS in deg
                
                zwd_eramet = (ztd - zhd)*100; %cm
                pwv_eramet = PROC.PWV(zwd_eramet,temp)*10; %mm
                
                save(['synced_mat_data\DER_daily\SYNC_DER_' sta{:} '_2007_2021.mat'],'t','zwd_eramet','pwv_eramet','-append');
            end
        end
        
        function compareERAPWVData()
            % GPS ERA PWV vs. ERA PWV
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\DER_daily\SYNC_DER_',sta{:},'_2007_2021.mat']);
                pwv_DER = pwv_eramet; %mm
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
                pwv_ERA = pwv; %mm
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pwv_DER,'k-');
                plot(t,pwv_ERA,'r-');
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(pwv_ERA-pwv_DER,'omitnan'),std(pwv_ERA-pwv_DER,'omitnan')]);
            end
        end
        
        function compareMETEOPWVData()
            % GPS METEO PWV vs. GPS ERA PWV
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\DER_daily\SYNC_DER_',sta{:},'_2007_2021.mat']);
                pwv_DER = pwv_eramet; %mm
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
        
        function compareMETEOERAPWVData()
            % GPS METEO PSV vs. GPS ERA PWV
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
                pwv_ERA = pwv; %mm
                load(['synced_mat_data\DER_daily\SYNC_DER_',sta{:},'_2007_2021.mat']);
                %pwv_DER = pwv_eramet; %mm
                pwv_MET = pwv; %mm
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pwv_ERA,'k-');
                plot(t,pwv_MET,'r-');
                
                %Stats
                disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                disp([mean(pwv_ERA-pwv_MET,'omitnan'),std(pwv_ERA-pwv_MET,'omitnan')]);
            end
        end
        
        function compareALLPWVData()
            % Compare the three PWV data sets
            sta_list = ERA_EUREF.stations;
            sta_list = {'ALME','ALMR','GRA3','UJAE','CRDB','COBA','SEV3','MALA','MLGA','UCA3','SFER'}; % No Huelva
            i=0;
            bias_ = []; std_ = [];
            
            for sta = sta_list
                load(['synced_mat_data\DER_daily\SYNC_DER_',sta{:},'_2007_2021.mat']);
                pwv_DER = pwv_eramet; %mm
                pwv_MET = pwv; %mm
                load(['synced_mat_data\ERA_daily\SYNC_ERA_',sta{:},'_2007_2021.mat']);
                pwv_ERA = pwv; %mm
                
                
                %Plots
                figure(10 + i); hold on; i = i+1; title(sta{:});
                plot(t,pwv_MET,'r-');
                plot(t,pwv_DER,'k-');
                plot(t,pwv_ERA,'g-'); legend({'GPS MET PWV','GPS ERA PWV','ERA PWV'});
                
                %Stats
                %disp(sta{:});
                %disp([' Bias:    ',num2str(mean(temp_ERA-temp_CLI,'omitnan'))]);
                %disp([' STD:     ',num2str(std(temp_ERA - temp_CLI,'omitnan'))]);
                %disp([mean(pwv_DER-pwv_MET,'omitnan'),std(pwv_DER-pwv_MET,'omitnan')]);
            end
        end
        
    end
    
    %% EUREF - IGS
    
    methods(Static, Access = public)
        
        function extractEUREFTropoData()
            list = struct2cell(dir('DATOS_EUREF/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            all_time = {[],[],[],[],[],[],[],[],[]};
            all_ztd = {[],[],[],[],[],[],[],[],[]};
            
            textprogressbar('Loading and transforming data from EUREF Troposphere files:     ')
            
            for j=1:n_files
                textprogressbar(j/n_files*100);
                fid = fopen(['DATOS_EUREF/', list(j,:)]);
                line_char=fgetl(fid);
                i = 1;
                while(~strcmp(line_char,'+TROP/SOLUTION'))
                    i = i+1;
                    line_char=fgetl(fid);
                end
                line_char=fgetl(fid);
                line_char=fgetl(fid);
                while(~strcmp(line_char,'-TROP/SOLUTION'))
                    if strcmp(line_char,'*')
                        line_char=fgetl(fid); %Sometimes by error there is two * lines
                    end
                    site_name = line_char(2:5);
                    if any(strcmp(site_name,ERA_EUREF.stations_EUREF)) % If site is in stations list
                        time = [];
                        ztd = [];
                        while(~strcmp(line_char,'*'))
                            time = [time; datetime(2000 + str2num(line_char(7:8)),1,str2num(line_char(10:12)),0,0,str2num(line_char(14:18))) - minutes(30)];
                            ztd = [ztd; str2num(line_char(20:25))]; %mm
                            line_char=fgetl(fid);
                        end
                        site_ind = find(strcmp(site_name,ERA_EUREF.stations_EUREF));
                        all_time{site_ind} = [all_time{site_ind}; time];
                        all_ztd{site_ind} = [all_ztd{site_ind}; ztd];
                    else
                        while(~strcmp(line_char,'*'))
                            line_char=fgetl(fid); % Go on until next station
                        end
                    end
                    line_char=fgetl(fid);
                end
                fclose(fid);
            end
            textprogressbar('    Done.');
            
            %Synchronization of data.
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            for sta =1:9
                disp(ERA_EUREF.stations_EUREF{sta});
                t_EUR = all_time{sta};
                ztd_EUR = all_ztd{sta};
                [i_a,i_b] = ismember(t_sync,t_EUR);
                t = t_sync;
                ztd = NaN(size(t,1),1);
                ztd(i_a) = ztd_EUR(i_b(i_a))*1e-3; %m
                save(['synced_mat_data/EUR_hourly/SYNC_EUR_' ERA_EUREF.stations_EUREF{sta} '_2007_2021.mat'],'t','ztd');
            end
            
        end
        
        function compareEUREFTropoData()
            for sta = 1:size(ERA_EUREF.stations_EUREF,2)
                sta_name = ERA_EUREF.stations_EUREF{sta}
                load(['synced_mat_data\EUR_hourly\SYNC_EUR_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                bias = mean(ztd_TRO - ztd_EUR, 'omitnan')*1e3 %mm
                rms_ = rms(ztd_TRO - ztd_EUR - bias*1e-3,'omitnan')*1e3 %mm
            end
        end
        
        function plotEUREFReferenceData()
            n_sta = size(ERA_EUREF.stations_EUREF,2);
            for sta = 1:size(ERA_EUREF.stations_EUREF,2)
                sta_name = ERA_EUREF.stations_EUREF{sta}
                load(['synced_mat_data\EUR_hourly\SYNC_EUR_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                figure(10 + sta);
                plot(t_EUR,ztd_EUR); title(sta_name); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
                hold on; plot(t_TRO,ztd_TRO); xlabel('Tiempo'); ylabel('ZTD (m)'); legend({'Euref','goGPS'})
                %plot(t_TRO,(ztd_TRO - ztd_EUR).^2*1e3);
                

            end
        end
        
    end % EUREF
    
    methods(Static, Access = public)
        
        function extractEUREFR2TropoData()
            list = struct2cell(dir('DATOS_EUREF/repro2/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            all_time = {[],[],[],[],[],[],[],[],[]};
            all_ztd = {[],[],[],[],[],[],[],[],[]};
            
            textprogressbar('Loading and transforming data from EUREF Troposphere files:     ')
            
            for j=1:n_files
                textprogressbar(j/n_files*100);
                fid = fopen(['DATOS_EUREF/repro2/', list(j,:)]);
                line_char=fgetl(fid);
                i = 1;
                while(~strcmp(line_char,'+TROP/SOLUTION'))
                    i = i+1;
                    line_char=fgetl(fid);
                end
                line_char=fgetl(fid);
                line_char=fgetl(fid);
                while(~strcmp(line_char,'-TROP/SOLUTION'))
                    if strcmp(line_char,'*')
                        line_char=fgetl(fid); %Sometimes by error there is two * lines
                    end
                    site_name = line_char(2:5);
                    if any(strcmp(site_name,ERA_EUREF.stations_EUREF_repro2)) % If site is in stations list
                        time = [];
                        ztd = [];
                        while(~strcmp(line_char,'*'))
                            time = [time; datetime(2000 + str2num(line_char(7:8)),1,str2num(line_char(10:12)),0,0,str2num(line_char(14:18))) - minutes(30)];
                            ztd = [ztd; str2num(line_char(20:25))]; %mm
                            line_char=fgetl(fid);
                        end
                        site_ind = find(strcmp(site_name,ERA_EUREF.stations_EUREF_repro2));
                        all_time{site_ind} = [all_time{site_ind}; time];
                        all_ztd{site_ind} = [all_ztd{site_ind}; ztd];
                    else
                        while(~strcmp(line_char,'*'))
                            line_char=fgetl(fid); % Go on until next station
                        end
                    end
                    line_char=fgetl(fid);
                end
                fclose(fid);
            end
            textprogressbar('    Done.');
            
            %Synchronization of data.
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            for sta =1:7
                disp(ERA_EUREF.stations_EUREF_repro2{sta});
                t_EUR = all_time{sta};
                ztd_EUR = all_ztd{sta};
                [i_a,i_b] = ismember(t_sync,t_EUR);
                t = t_sync;
                ztd = NaN(size(t,1),1);
                ztd(i_a) = ztd_EUR(i_b(i_a))*1e-3; %m
                save(['synced_mat_data/EU2_hourly/SYNC_EU2_' ERA_EUREF.stations_EUREF_repro2{sta} '_2007_2021.mat'],'t','ztd');
            end
            
        end
        
        function compareEUREFR2TropoData()
            for sta = 1:size(ERA_EUREF.stations_EUREF_repro2,2)
                sta_name = ERA_EUREF.stations_EUREF_repro2{sta}
                load(['synced_mat_data\EU2_hourly\SYNC_EU2_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                bias = mean(ztd_TRO - ztd_EUR, 'omitnan')*1e3 %mm
                rms_ = rms(ztd_TRO - ztd_EUR - bias*1e-3,'omitnan')*1e3 %mm
            end
        end
        
        function plotEUREFR2ReferenceData()
            n_sta = size(ERA_EUREF.stations_EUREF_repro2,2);
            for sta = 1:size(ERA_EUREF.stations_EUREF_repro2,2)
                sta_name = ERA_EUREF.stations_EUREF_repro2{sta}
                load(['synced_mat_data\EU2_hourly\SYNC_EU2_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                figure(10 + sta);
                plot(t_EUR,ztd_EUR); title(sta_name); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
                hold on; plot(t_TRO,ztd_TRO); xlabel('Tiempo'); ylabel('ZTD (m)'); legend({'Euref','goGPS'})
                %plot(t_TRO,(ztd_TRO - ztd_EUR).^2*1e3);
                

            end
        end
        
    end % EUREF REPRO 2
    
    methods(Static,Access = public)
        
        function extractIGSTropoData
            list = struct2cell(dir('DATOS_IGS/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Sort files so that they are chronologically sorted (for IGS)
            tab = sortrows(table(list(:,10:11),list));
            list = tab.list;
            
            all_time = {[],[],[],[],[],[],[],[],[]};
            all_ztd = {[],[],[],[],[],[],[],[],[]};
            %a = [];
            
            textprogressbar('Loading and transforming data from EUREF Troposphere files:     ')
            
            for j=1:n_files
                textprogressbar(j/n_files*100);
                fid = fopen(['DATOS_IGS/', list(j,:)]);
                line_char=fgetl(fid);
                i = 1;
                while(~strcmp(line_char,'+TROP/SOLUTION'))
                    i = i+1;
                    line_char=fgetl(fid);
                end
                line_char=fgetl(fid);
                line_char=fgetl(fid);
                while(~strcmp(line_char,'%=ENDTRO'))
                    if strcmp(line_char,'*')
                        line_char=fgetl(fid); %Sometimes by error there is two * lines
                    end
                    site_name = line_char(2:5);
                    if any(strcmp(site_name,ERA_EUREF.stations_IGS)) % If site is in stations list
                        time = [];
                        ztd = [];
                        while(~strcmp(line_char,'-TROP/SOLUTION'))
                            time = [time; datetime(2000 + str2num(line_char(7:8)),1,str2num(line_char(10:12)),0,0,str2num(line_char(14:18)))];
                            ztd = [ztd; str2num(line_char(20:25))]; %mm
                            %a = [a; size(time),size(ztd)];
                            line_char=fgetl(fid);
                        end
                        site_ind = find(strcmp(site_name,ERA_EUREF.stations_IGS));
                        all_time{site_ind} = [all_time{site_ind}; time];
                        all_ztd{site_ind} = [all_ztd{site_ind}; ztd];
                    end
                    line_char=fgetl(fid);
                end
                fclose(fid);
            end
            textprogressbar('    Done.');
            
            %Synchronization of data.
            t_sync = [datetime(2007,01,01,00,00,00):hours(1):datetime(2021,12,31,24,00,00)]'; %hourly reference time array
            for sta =1:3
                disp(ERA_EUREF.stations_IGS{sta});
                t_EUR = all_time{sta};
                ztd_EUR = all_ztd{sta};
                [i_a,i_b] = ismember(t_sync,t_EUR);
                t = t_sync;
                ztd = NaN(size(t,1),1);
                ztd(i_a) = ztd_EUR(i_b(i_a))*1e-3; %m
                save(['synced_mat_data/IGS_hourly/SYNC_IGS_' ERA_EUREF.stations_IGS{sta} '_2007_2021.mat'],'t','ztd');
            end
            
        end
        
        function compareIGSTropoData()
            for sta = 1:size(ERA_EUREF.stations_IGS,2)
                sta_name = ERA_EUREF.stations_IGS{sta}
                load(['synced_mat_data\IGS_hourly\SYNC_IGS_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                bias = mean(ztd_TRO - ztd_EUR, 'omitnan')*1e3 %mm
                rms_ = rms(ztd_TRO - ztd_EUR - bias*1e-3,'omitnan')*1e3 %mm
            end
        end
        
        function plotIGSReferenceData()
            n_sta = size(ERA_EUREF.stations_IGS,2);
            for sta = 1:size(ERA_EUREF.stations_IGS,2)
                sta_name = ERA_EUREF.stations_IGS{sta}
                load(['synced_mat_data\IGS_hourly\SYNC_IGS_' sta_name '_2007_2021.mat'], 't','ztd');
                t_EUR = t; ztd_EUR = ztd;
                load(['synced_mat_data\TRO_hourly\SYNC_TRO_' sta_name '_2007_2021.mat'], 't','ztd');
                t_TRO = t; ztd_TRO = ztd;
                figure(10 + sta);
                plot(t_EUR,ztd_EUR); title(sta_name); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
                hold on; plot(t_TRO,ztd_TRO);
                %plot(t_TRO,(ztd_TRO - ztd_EUR).^2*1e3);
            end
        end
        
    end % IGS
    
    methods(Static, Access = public)
        % Pruebas SFER y MELI IGS/Euref
        
        function tropoSFER
            load('synced_mat_data\TRO_hourly\SYNC_TRO_SFER_2007_2021.mat');
            ztd_goGPS = ztd;
            load('synced_mat_data\IGS_hourly\SYNC_IGS_SFER_2007_2021.mat');
            ztd_IGS = ztd;
            load('synced_mat_data\EUR_hourly\SYNC_EUR_SFER_2007_2021.mat');
            ztd_EUR = ztd;
            figure(); hold on; plot(t,(ztd_IGS - ztd_goGPS)*1e3); plot(t,(ztd_EUR - ztd_goGPS)*1e3);
            xlabel('Time'); ylabel('ZTD difference (mm)');
            legend({'ZTD_{IGS} - ZTD_{goGPS}','ZTD_{EUREF} - ZTD_{goGPS}'});
            
            std(ztd_goGPS - ztd_IGS,'omitnan')*1e3; %13.46mm
            ind_t = or(t<datetime(2011,5,1),t>datetime(2013,5,1));
            std(ztd_goGPS(ind_t) - ztd_IGS(ind_t),'omitnan')*1e3; %5.84
            mean(ztd_goGPS(ind_t) - ztd_IGS(ind_t),'omitnan')*1e3; %0.44
        end
        
        function posSFER
            load('synced_mat_data\POS_daily\SYNC_POS_SFER_2007_2021.mat');
            enu_goGPS = [e,n,u];
            figure();
            x_lims = [datetime(2007,1,1), datetime(2022,1,1)];
            subplot(4,1,1); plot(t,enu_goGPS(:,1)*1e3,'k'); title ('SFER position and ZTD time series'); ylabel('East (mm)');xlim(x_lims);
            subplot(4,1,2); plot(t,enu_goGPS(:,2)*1e3,'k'); ylabel('North (mm)');xlim(x_lims);
            subplot(4,1,3); plot(t,enu_goGPS(:,3)*1e3,'k'); ylabel('Up (mm)');xlim(x_lims);
            load('synced_mat_data\TRO_hourly\SYNC_TRO_SFER_2007_2021.mat'); 
            ztd_goGPS = ztd;
            subplot(4,1,4); plot(t,ztd_goGPS); xlabel('Time'); ylabel('ZTD (m)');xlim(x_lims);
            
        end
        
        function posUCAD
            load('synced_mat_data\POS_daily\SYNC_POS_UCAD_2007_2021.mat');
            enu_goGPS = [e,n,u];
            figure();
           x_lims = [datetime(2007,1,1), datetime(2022,1,1)];
            subplot(4,1,1); plot(t,enu_goGPS(:,1)*1e3,'k'); title ('UCAD position and ZTD time series'); ylabel('East (mm)');xlim(x_lims);
            subplot(4,1,2); plot(t,enu_goGPS(:,2)*1e3,'k'); ylabel('North (mm)');xlim(x_lims);
            subplot(4,1,3); plot(t,enu_goGPS(:,3)*1e3,'k'); ylabel('Up (mm)');xlim(x_lims);
            load('synced_mat_data\TRO_hourly\SYNC_TRO_UCAD_2007_2021.mat'); 
            ztd_goGPS = ztd;
            subplot(4,1,4); plot(t,ztd_goGPS); xlabel('Time'); ylabel('ZTD (m)');xlim(x_lims);
        end
        
        function posUJAE
            load('synced_mat_data\POS_daily\SYNC_POS_UJAE_2007_2021.mat');
            enu_goGPS = [e,n,u];
            figure();
           x_lims = [datetime(2007,1,1), datetime(2022,1,1)];
            subplot(4,1,1); plot(t,enu_goGPS(:,1)*1e3,'k'); title ('UAJE position and ZTD time series'); ylabel('East (mm)');xlim(x_lims);
            subplot(4,1,2); plot(t,enu_goGPS(:,2)*1e3,'k'); ylabel('North (mm)');xlim(x_lims);
            subplot(4,1,3); plot(t,enu_goGPS(:,3)*1e3,'k'); ylabel('Up (mm)');xlim(x_lims);
            load('synced_mat_data\TRO_hourly\SYNC_TRO_UJAE_2007_2021.mat'); 
            ztd_goGPS = ztd;
            subplot(4,1,4); plot(t,ztd_goGPS); xlabel('Time'); ylabel('ZTD (m)');xlim(x_lims);
        end
        
        function posARAC
            load('synced_mat_data\POS_daily\SYNC_POS_ARAC_2007_2021.mat');
            enu_goGPS = [e,n,u];
            figure();
           x_lims = [datetime(2007,1,1), datetime(2022,1,1)];
            subplot(4,1,1); plot(t,enu_goGPS(:,1)*1e3,'k'); title ('ARAC position and ZTD time series'); ylabel('East (mm)');xlim(x_lims);
            subplot(4,1,2); plot(t,enu_goGPS(:,2)*1e3,'k'); ylabel('North (mm)');xlim(x_lims);
            subplot(4,1,3); plot(t,enu_goGPS(:,3)*1e3,'k'); ylabel('Up (mm)');xlim(x_lims);
            load('synced_mat_data\TRO_hourly\SYNC_TRO_ARAC_2007_2021.mat'); 
            ztd_goGPS = ztd;
            subplot(4,1,4); plot(t,ztd_goGPS); xlabel('Time'); ylabel('ZTD (m)');xlim(x_lims);
        end
        
        
        function tropoMELI
            load('synced_mat_data\TRO_hourly\SYNC_TRO_MELI_2007_2021.mat');
            ztd_goGPS = ztd;
            load('synced_mat_data\IGS_hourly\SYNC_IGS_MELI_2007_2021.mat');
            ztd_IGS = ztd;
            load('synced_mat_data\EUR_hourly\SYNC_EUR_MELI_2007_2021.mat');
            ztd_EUR = ztd;
            figure(); hold on; plot(t,(ztd_IGS - ztd_goGPS)*1e3); plot(t,(ztd_EUR - ztd_goGPS)*1e3);
            xlabel('Time'); ylabel('ZTD difference (mm)');
            legend({'ZTD_{IGS} - ZTD_{goGPS}','ZTD_{EUREF} - ZTD_{goGPS}'});
            
            std(ztd_goGPS - ztd_IGS,'omitnan')*1e3; %13.46mm
            mean(ztd_goGPS - ztd_EUR,'omitnan')*1e3;
            ind_t = t<datetime(2014,1,1);
            std(ztd_goGPS(ind_t) - ztd_EUR(ind_t),'omitnan')*1e3; %5.84
            mean(ztd_goGPS(~ind_t) - ztd_EUR(~ind_t),'omitnan')*1e3; %0.44
        end
    end % PRUEBAS SFER MELI
    
    %% Precipitation Vicente Serrano
    
    methods(Static, Access = public)
        
        function extractPrecSPEIData
            
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list = cellstr(sta_list_geod);
            sta_list([13,25,41],:) = []; % Omitt CEU1, MELI and TIOU since we don't have data for these coordinates
            n_sta = size(sta_list,1);
            
            data = readmatrix('DATOS_PRECIP_SPEI\precipitacion.csv'); 
            data(:,1) = []; % Now each column corresponds to one station in sta_list (43), Each row is a quarter of month since 1961
            data_monthly = data(1:4:end,:) + data(2:4:end,:) + data(3:4:end,:) + data(4:4:end,:);
            n_months = size(data_monthly,1);
            time_monthly = [datetime(1961,1:n_months,1)]';
            
            data_monthly = data_monthly(time_monthly >= datetime(2007,01,01),:); % Only starting from 2007
            data_monthly = [data_monthly; NaN(1,n_sta)];
            t = [datetime(2007,1:181,1)]';
            
            m_days = ERA_EUREF.monthDays(t);
            data_monthly = data_monthly ./ m_days; % From accumulated monthly data to mean daily data
            figure(); hold on;
            for i=1:n_sta
                prec = data_monthly(:,i);
                save(['synced_mat_data/GRI_monthly/SYNC_GRI_' sta_list{i} '_2007_2021.mat'],'t','prec');
                plot(t,prec);
            end
            
        end
        
        function d = monthDays(datet)
            next_month = datetime(year(datet),month(datet)+1,day(datet));
            d = days(next_month - datet);
        end
        
    end
end

