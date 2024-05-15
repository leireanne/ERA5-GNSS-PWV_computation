classdef SPI
    % Class with functions to deal with SPI-SPEI database data.
    
    methods (Static, Access = public)
        
        function extractData
            % Extract data from SPI Database csv files and
            % save it in synced time series for each station
            
            load('matlab_extracted_data/geodetic_data.mat');
            
            t_spi = [datetime(1961,1,1):days(1):datetime(2022,05,23)]';
            t_spi = t_spi(or(or(or(day(t_spi)==1,day(t_spi)==9),day(t_spi)==16),day(t_spi)==23)); % datetime array corresponding to spei data (until may 2022).
            t_sync = [datetime(2007,01,01,00,00,00):hours(24):datetime(2021,12,31,24,00,00)]';
            t = t_sync;
            [i_a,i_b] = ismember(t_sync,t_spi);
            n_sync = size(t_sync,1);
            spi01 = NaN(n_sync,1);spi03 = NaN(n_sync,1);spi06 = NaN(n_sync,1);spi09 = NaN(n_sync,1);spi12 = NaN(n_sync,1);spi24 = NaN(n_sync,1);
            spei01 = NaN(n_sync,1);spei03 = NaN(n_sync,1);spei06 = NaN(n_sync,1);spei09 = NaN(n_sync,1);spei12 = NaN(n_sync,1);spei24 = NaN(n_sync,1);
            for i=1:size(sta_list_geod,1)
                lat = rad2deg(geod_list(i,1)); lon = rad2deg(geod_list(i,2));
                file_name = sprintf('DATOS_SPI/DATA_%.2f_%5.2f.csv',lat,lon);
                if isfile(file_name)
                    data = dlmread(file_name,',',[1,1,2948,12]); %DATA,spei_1,spei_3,spei_6,spei_9,spei_12,spei_24,spi_1,spi_3,spi_6,spi_9,spi_12,spi_24...
                    spi01(i_a) = data(i_b(i_a),1);spi03(i_a) = data(i_b(i_a),2);spi06(i_a) = data(i_b(i_a),3);spi09(i_a) = data(i_b(i_a),4);spi12(i_a) = data(i_b(i_a),5);spi24(i_a) = data(i_b(i_a),6);
                    spei01(i_a) = data(i_b(i_a),7);spei03(i_a) = data(i_b(i_a),8);spei06(i_a) = data(i_b(i_a),9);spei09(i_a) = data(i_b(i_a),10);spei12(i_a) = data(i_b(i_a),11);spei24(i_a) = data(i_b(i_a),12);
                else
                    disp(['No SPI file for ' sta_list_geod(i,:)]);
                    %disp(file_name);
                end
                save(['synced_mat_data/SPI_interm/SYNC_SPI_' sta_list_geod(i,:) '_2007_2021.mat'],'t','spi01','spi03','spi06','spi09','spi12','spi24','spei01','spei03','spei06','spei09','spei12','spei24');
            end
        end
        
        function resampleDataMonthly
            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list_geod,1)
                load(['synced_mat_data/SPI_interm/SYNC_SPI_' sta_list_geod(i,:) '_2007_2021.mat']);
                tt = timetable(t,spi01,spi03,spi06,spi09,spi12,spi24,spei01,spei03,spei06,spei09,spei12,spei24);
                tt = retime(tt,'monthly','nearest');
                % WARNING! this will resample with data for the first day
                % of each month, meaning that SPI-01 for instance
                % corresponds to previous months data and no data of the actual month is being taken into account.
                spi01 = tt.spi01; spi03 = tt.spi03; spi06 = tt.spi06; spi09 = tt.spi09; spi12 = tt.spi12; spi24 = tt.spi24; 
                spei01 = tt.spei01; spei03 = tt.spei03; spei06 = tt.spei06; spei09 = tt.spei09; spei12 = tt.spei12; spei24 = tt.spei24; 
                t = tt.t;
                save(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list_geod(i,:) '_2007_2021.mat'],'t','spi01','spi03','spi06','spi09','spi12','spi24','spei01','spei03','spei06','spei09','spei12','spei24');
            end
        end
    end
    
    properties
        ERA5_gen_grid_lat = [30.5:0.25:40.0];
        ERA5_gen_grid_lon = [-7.5:0.25:-1.25];
    end
    
    methods (Static, Access=public) % Method for extracting data corresponding to all ERA5 grid points.
        
        function extractDataGen
            % Extract data from SPI Database csv files and
            % save it in synced time series for each ERA5 grid point
            
            load('matlab_extracted_data/geodetic_data.mat');
            
            t_spi = [datetime(1961,1,1):days(1):datetime(2022,05,23)]';
            t_spi = t_spi(or(or(or(day(t_spi)==1,day(t_spi)==9),day(t_spi)==16),day(t_spi)==23)); % datetime array corresponding to spei data (until may 2022).
            t_sync = [datetime(2007,01,01,00,00,00):hours(24):datetime(2021,12,31,24,00,00)]';
            t = t_sync;
            [i_a,i_b] = ismember(t_sync,t_spi);
            n_sync = size(t_sync,1);
            spi01 = NaN(n_sync,1);spi03 = NaN(n_sync,1);spi06 = NaN(n_sync,1);spi09 = NaN(n_sync,1);spi12 = NaN(n_sync,1);spi24 = NaN(n_sync,1);
            spei01 = NaN(n_sync,1);spei03 = NaN(n_sync,1);spei06 = NaN(n_sync,1);spei09 = NaN(n_sync,1);spei12 = NaN(n_sync,1);spei24 = NaN(n_sync,1);
            for i=1:size(sta_list_geod,1)
                lat = rad2deg(geod_list(i,1)); lon = rad2deg(geod_list(i,2));
                file_name = sprintf('DATOS_SPI/DATA_%.2f_%5.2f.csv',lat,lon);
                if isfile(file_name)
                    data = dlmread(file_name,',',[1,1,2948,12]); %DATA,spei_1,spei_3,spei_6,spei_9,spei_12,spei_24,spi_1,spi_3,spi_6,spi_9,spi_12,spi_24...
                    spi01(i_a) = data(i_b(i_a),1);spi03(i_a) = data(i_b(i_a),2);spi06(i_a) = data(i_b(i_a),3);spi09(i_a) = data(i_b(i_a),4);spi12(i_a) = data(i_b(i_a),5);spi24(i_a) = data(i_b(i_a),6);
                    spei01(i_a) = data(i_b(i_a),7);spei03(i_a) = data(i_b(i_a),8);spei06(i_a) = data(i_b(i_a),9);spei09(i_a) = data(i_b(i_a),10);spei12(i_a) = data(i_b(i_a),11);spei24(i_a) = data(i_b(i_a),12);
                else
                    disp(['No SPI file for ' sta_list_geod(i,:)]);
                    %disp(file_name);
                end
                save(['synced_mat_data/SPI_interm/SYNC_SPI_' sta_list_geod(i,:) '_2007_2021.mat'],'t','spi01','spi03','spi06','spi09','spi12','spi24','spei01','spei03','spei06','spei09','spei12','spei24');
            end
        end
        
    end
end

