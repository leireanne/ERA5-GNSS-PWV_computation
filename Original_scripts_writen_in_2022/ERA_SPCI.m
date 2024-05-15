classdef ERA_SPCI
    %Class to analysde ERA5 data for SPCI computation
    

    
    methods (Static, Access = public) % 2007-2021. Results with ERA5 single level PWV for individual GNSS stations (2007-2022)
        
        function extractERADataPWV() % inspired in function with the same name in class ERA_EUREF
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
                if isfile(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'])
                    save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv' ,'-append');
                else
                    save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv');
                end
            end
        end
               
        function resampleERADataPWV(sampling)
            % ERA.resampleERAData('daily');
            
            list = struct2cell(dir('synced_mat_data\ERA_hourly\'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            for f=1:n_files
                load(['synced_mat_data\ERA_hourly\' list(f,:)]);
                tt = timetable(t,pwv);
                tt = retime(tt,sampling,'mean');
                t = tt.t; pwv = tt.pwv;
                save(['synced_mat_data\ERA_' sampling '\' list(f,:)],'t','pwv');
            end
        end
        
        function extractERADataPWVCARG() % inspired in function with the same name in class ERA_EUREF
            load('synced_mat_data/COM_monthly/COM_ERA_CARG_1961_2021.mat');
            pwv_sinera = pwv(t>=datetime(2007,1,1)); t = t(t>=datetime(2007,1,1));
            save(['synced_mat_data/ERA_monthly/SYNC_ERA_CARG_2007_2021.mat'],'t','pwv_sinera');
        end
        
        
        
        function singleERASPCI
            % Function to compute ERA SPCI time series using single level ERA data (single level 2007-2021).
            load('matlab_extracted_data/geodetic_data.mat');
            
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data/ERA_monthly/SYNC_ERA_' sta '_2007_2021.mat']);
                load(['synced_mat_data/GRI_monthly/SYNC_GRI_' sta '_2007_2021.mat']);
                prec = [NaN(25,1); prec]; pwv = [NaN(25,1); pwv]; % Add NaN so that pci is not computed for first 2 years
                n_sync = size(t,1);
                pci01_sinera = NaN(n_sync,1); pci03_sinera = NaN(n_sync,1); pci06_sinera = NaN(n_sync,1); pci09_sinera = NaN(n_sync,1); pci12_sinera = NaN(n_sync,1); pci24_sinera = NaN(n_sync,1);
                mond = [NaN(1,25) PROC.mond]; % number of days in each month, starting january 2007
                for m = 1:n_sync
                    n = m+25; % to skip first 24 NaNs
                    % WARNING! When SPEI was extracted, nearest value to
                    % the 1st of January of each month was selected as
                    % monthly value. That is, the value of each month
                    % actually corresponds to the accumulation of previous
                    % months. That's why, in the following calculations,
                    % sumations starts at n-1.
                    pci01_sinera(m) = prec(n-1)/pwv(n-1)*100;  
                    pci03_sinera(m) = sum(prec(n-1:-1:n-3).*mond(n-1:-1:n-3))/sum(pwv(n-1:-1:n-3).*mond(n-1:-1:n-3))*100;
                    pci06_sinera(m) = sum(prec(n-1:-1:n-6).*mond(n-1:-1:n-6))/sum(pwv(n-1:-1:n-6).*mond(n-1:-1:n-6))*100;
                    pci09_sinera(m) = sum(prec(n-1:-1:n-9).*mond(n-1:-1:n-9))/sum(pwv(n-1:-1:n-9).*mond(n-1:-1:n-9))*100;
                    pci12_sinera(m) = sum(prec(n-1:-1:n-12).*mond(n-1:-1:n-12))/sum(pwv(n-1:-1:n-12).*mond(n-1:-1:n-12))*100;
                    pci24_sinera(m) = sum(prec(n-1:-1:n-24).*mond(n-1:-1:n-24))/sum(pwv(n-1:-1:n-24).*mond(n-1:-1:n-24))*100;
                end
                spci01_sinera = ERA_LEVEL.standardize(pci01_sinera);
                spci03_sinera = ERA_LEVEL.standardize(pci03_sinera);
                spci06_sinera = ERA_LEVEL.standardize(pci06_sinera);
                spci09_sinera = ERA_LEVEL.standardize(pci09_sinera);
                spci12_sinera = ERA_LEVEL.standardize(pci12_sinera);
                spci24_sinera = ERA_LEVEL.standardize(pci24_sinera);
                save(['synced_mat_data\PCI_monthly\SYNC_PCI_' sta '_2007_2021.mat'],'t','pci01_sinera','pci03_sinera','pci06_sinera','pci09_sinera','pci12_sinera','pci24_sinera','spci01_sinera','spci03_sinera','spci06_sinera','spci09_sinera','spci12_sinera','spci24_sinera','-append');
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
                pci01 = spci01_sinera;
                pci03 = spci03_sinera;
                pci06 = spci06_sinera;
                pci09 = spci09_sinera;
                pci12 = spci12_sinera;
                pci24 = spci24_sinera;
                load(['synced_mat_data\SPI_monthly\SYNC_SPI_' sta '_2007_2021.mat']);
                hold on; plot(datetime(2023,1,1),[-1],'b'); plot(datetime(2023,1,1),[-1],'r'); plot(datetime(2023,1,1),[-1],'g');
%                 lg = legend({'PWV/Prec.','SPCI-GNSS','SPI','SPEI'},'Location','Northoutside');%,'Orientation','horizontal');
%                 lg.Layout.Tile = 'East';set(lg.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.5;.5;.5;0]));  % [.5,.5,.5] is light gray; 0.8 means 20% transparent
%                 set(lg,'HandleVisibility','off');

                nexttile(tcl); plot(t,pci01,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI01'); %ylim([0,100]);
                hold on; plot(t,spi01,'color','r'); plot(t,spei01,'color','g');
                ind = isfinite(pci01);
                cc_spi = corrcoef(pci01(ind),spi01(ind)); cc_spei = corrcoef(pci01(ind),spei01(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'01'} = cc_spi(1,2); tab_SPEI{sta,'01'} = cc_spei(1,2); 
                
                nexttile(tcl); plot(t,pci03,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI03'); %ylim([0,100]);
                hold on; plot(t,spi03,'color','r'); plot(t,spei03,'color','g');
                ind = isfinite(pci03);
                cc_spi = corrcoef(pci03(ind),spi03(ind)); cc_spei = corrcoef(pci03(ind),spei03(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'03'} = cc_spi(1,2); tab_SPEI{sta,'03'} = cc_spei(1,2); 
                
                nexttile(tcl); plot(t,pci06,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI06'); %ylim([0,100]);
                hold on; plot(t,spi06,'color','r'); plot(t,spei06,'color','g');
                ind = isfinite(pci06);
                cc_spi = corrcoef(pci06(ind),spi06(ind)); cc_spei = corrcoef(pci06(ind),spei06(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'06'} = cc_spi(1,2); tab_SPEI{sta,'06'} = cc_spei(1,2); 
                
                nexttile(tcl); plot(t,pci09,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI09'); %ylim([0,100]);
                hold on; plot(t,spi09,'color','r'); plot(t,spei09,'color','g');   
                ind = isfinite(pci09);
                cc_spi = corrcoef(pci09(ind),spi09(ind)); cc_spei = corrcoef(pci09(ind),spei09(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'09'} = cc_spi(1,2); tab_SPEI{sta,'09'} = cc_spei(1,2); 
                
                %spi12 = ERA_LEVEL.standardize(spi12); 
                %spei12 = ERA_LEVEL.standardize(spei12);
                nexttile(tcl); plot(t,pci12,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI12'); %ylim([0,100]);
                hold on; plot(t,spi12,'color','r'); plot(t,spei12,'color','g');
                ind = isfinite(pci12);
                cc_spi = corrcoef(pci12(ind),spi12(ind)); cc_spei = corrcoef(pci12(ind),spei12(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'12'} = cc_spi(1,2); tab_SPEI{sta,'12'} = cc_spei(1,2); 
                
                nexttile(tcl); plot(t,pci24,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('SPCI24'); %ylim([0,100]);
                hold on; plot(t,spi24,'color','r'); plot(t,spei24,'color','g');
                ind = isfinite(pci24);
                cc_spi = corrcoef(pci24(ind),spi24(ind)); cc_spei = corrcoef(pci24(ind),spei24(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'24'} = cc_spi(1,2); tab_SPEI{sta,'24'} = cc_spei(1,2); 
            end
        end
        
        function correlSPCISPEI12
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci12_sinera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei12');
                spci12 = spci12_sinera;
                
                ind = isfinite(spci12);
                cc = corrcoef(spci12(ind),spei12(ind));
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
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci06_sinera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei06');
                spci06 = spci06_sinera;
                
                ind = isfinite(spci06);
                cc = corrcoef(spci06(ind),spei06(ind));
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
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci24_sinera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei24');
                spci24 = spci24_sinera;
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI24Interm
            % ERA5 data is used but the same temporal extent of the GNSS
            % time series is considered, with limited stations' temporal
            % extention and data gaps.
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/PCI_monthly/SYNC_PCI_' sta_list{i} '_2007_2021.mat'], 't', 'spci24_sinera','spci24_levera');
                load(['synced_mat_data/SPI_monthly/SYNC_SPI_' sta_list{i} '_2007_2021.mat'], 't', 'spei24');
                spci24 = spci24_sinera;
                spci24(~isfinite(spci24_levera)) = NaN; %%%%%% IMITATE TIME SPAN AND DATA GAPS OF GNSS
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end


    end
    
    methods (Static, Access = public) % 1961-2021. Results with ERA5 single level PWV for individual GNSS stations (1961-2022)
        
        function extractERADataPWVCOM() % inspired in function with the same name in class ERA_EUREF
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PWV_monthly/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PWV_monthly/' list(1,:)],',',1,2);
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
                data = dlmread(['DATOS_ERA5/PWV_monthly/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_com = [datetime(1961,01:733,01,00,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_com,t_ERA);
            t = t_com;
            for i=1:size(sta_list_geod,1)
                disp(sta_list_geod(i,:));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                if isfile(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'])
                    save(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'],'t','pwv' ,'-append');
                else
                    save(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'],'t','pwv');
                end
            end
        end
        
        function extractERADataPWVCOMCARG() % inspired in function with the same name in class ERA_EUREF
            % ERA.extractERAData()
            list = struct2cell(dir('DATOS_ERA5/PWV_monthly_CARG/'));
            list = char(list(1,3:end));
            n_files = size(list,1);
            
            % Retrieve indexes for each station
            data = dlmread(['DATOS_ERA5/PWV_monthly_CARG/' list(1,:)],',',1,2);
            lat_ERA = data(1:3:end,1)';
            lon_ERA = data(1:3,2)';
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list_geod = sta_list_geod(10,:); geod_list = geod_list(10,:); %% ONLY CARG!!
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
                data = dlmread(['DATOS_ERA5/PWV_monthly_CARG/' list(j,:)],',',1,0);
                % Mode interp2
                y_max = max(data(:,2)); x_max = max(data(:,1));
                lat_g = reshape(data(:,3),x_max,y_max)';
                lon_g = reshape(data(:,4),x_max,y_max)';
                val_g = reshape(data(:,5),x_max,y_max)';
                pwv_ERA(j,:) = interp2(lon_g,lat_g,val_g,lon,lat); %Extract pwv data in this matrix.
            end
            textprogressbar('    Done.');
            t_com = [datetime(1961,01:733,01,00,00,00)]'; %hourly reference time array
            [i_a,i_b] = ismember(t_com,t_ERA);
            t = t_com;
            for i=1:size(sta_list_geod,1)
                disp(sta_list_geod(i,:));
                pwv = NaN(size(t,1),1);
                pwv(i_a) = pwv_ERA(i_b(i_a),i);
                if isfile(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'])
                    save(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'],'t','pwv' ,'-append');
                else
                    save(['synced_mat_data/COM_monthly/COM_ERA_' sta_list_geod(i,:) '_1961_2021.mat'],'t','pwv');
                end
            end
        end
        
        
        function extractGRIDataPrecCOM() % inspired in function ERA_EUREF.extractPrecSPEIData
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list = cellstr(sta_list_geod);
            sta_list([13,25,41],:) = []; % Omitt CEU1, MELI and TIOU since we don't have data for these coordinates
            n_sta = size(sta_list,1);
            
            data = readmatrix('DATOS_PRECIP_SPEI\precipitacion.csv'); 
            data(:,1) = []; % Now each column corresponds to one station in sta_list (43), Each row is a quarter of month since 1961
            data_monthly = data(1:4:end,:) + data(2:4:end,:) + data(3:4:end,:) + data(4:4:end,:);
            n_months = size(data_monthly,1);
            time_monthly = [datetime(1961,1:n_months,1)]';
            
            data_monthly = data_monthly(time_monthly >= datetime(1961,01,01),:); % Only starting from 2007
            data_monthly = [data_monthly; NaN(1,n_sta)];
            t = [datetime(1961,1:733,1)]';
            
            m_days = ERA_EUREF.monthDays(t);
            data_monthly = data_monthly ./ m_days; % From accumulated monthly data to mean daily data
            figure(); hold on;
            for i=1:n_sta
                prec = data_monthly(:,i);
                save(['synced_mat_data/COM_monthly/COM_GRI_' sta_list{i} '_1961_2021.mat'],'t','prec');
                plot(t,prec);
            end
        end
        
        function singleERASPCICOM
            % Function to compute ERA SPCI time series using single level ERA data (single level 2007-2021).
            load('matlab_extracted_data/geodetic_data.mat');
            
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            sta_list = cellstr(sta_list_geod);
            
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data/COM_monthly/COM_ERA_' sta '_1961_2021.mat']);
                load(['synced_mat_data/COM_monthly/COM_GRI_' sta '_1961_2021.mat']);
                prec = [NaN(25,1); prec]; pwv = [NaN(25,1); pwv]; % Add NaN so that pci is not computed for first 2 years
                n_sync = size(t,1);
                pci01_sinera = NaN(n_sync,1); pci03_sinera = NaN(n_sync,1); pci06_sinera = NaN(n_sync,1); pci09_sinera = NaN(n_sync,1); pci12_sinera = NaN(n_sync,1); pci24_sinera = NaN(n_sync,1);
                
                mond = [NaN(1,25) ERA_EUREF.monthDays(t)']; % number of days in each month, starting january 1961
                for m = 1:n_sync
                    n = m+25; % to skip first 24 NaNs
                    % WARNING! When spei was extracted, nearest value to
                    % the 1st of January of each month was selected as
                    % monthly value. That is, the value of each month
                    % actually corresponds to the accumulation of previous
                    % months. That's why, in the following calculations,
                    % sumations starts at n-1.
                    pci01_sinera(m) = prec(n-1)/pwv(n-1)*100;  
                    pci03_sinera(m) = sum(prec(n-1:-1:n-3).*mond(n-1:-1:n-3))/sum(pwv(n-1:-1:n-3).*mond(n-1:-1:n-3))*100;
                    pci06_sinera(m) = sum(prec(n-1:-1:n-6).*mond(n-1:-1:n-6))/sum(pwv(n-1:-1:n-6).*mond(n-1:-1:n-6))*100;
                    pci09_sinera(m) = sum(prec(n-1:-1:n-9).*mond(n-1:-1:n-9))/sum(pwv(n-1:-1:n-9).*mond(n-1:-1:n-9))*100;
                    pci12_sinera(m) = sum(prec(n-1:-1:n-12).*mond(n-1:-1:n-12))/sum(pwv(n-1:-1:n-12).*mond(n-1:-1:n-12))*100;
                    pci24_sinera(m) = sum(prec(n-1:-1:n-24).*mond(n-1:-1:n-24))/sum(pwv(n-1:-1:n-24).*mond(n-1:-1:n-24))*100;
                end
                spci01_sinera = ERA_LEVEL.standardize(pci01_sinera);
                spci03_sinera = ERA_LEVEL.standardize(pci03_sinera);
                spci06_sinera = ERA_LEVEL.standardize(pci06_sinera);
                spci09_sinera = ERA_LEVEL.standardize(pci09_sinera);
                spci12_sinera = ERA_LEVEL.standardize(pci12_sinera);
                spci24_sinera = ERA_LEVEL.standardize(pci24_sinera);
                save(['synced_mat_data\COM_monthly\COM_PCI_' sta '_1961_2021.mat'],'t','pci01_sinera','pci03_sinera','pci06_sinera','pci09_sinera','pci12_sinera','pci24_sinera','spci01_sinera','spci03_sinera','spci06_sinera','spci09_sinera','spci12_sinera','spci24_sinera');
            end
        end % inspired in function ERA_LEVEL.computePCIMultiscaleLEVERA
        
        % Extraction of SPEI and SPI since 1961
        function extractSPEIDataMonthly
            % Extract data from SPI Database csv files and
            % save it in synced time series for each station
            
            load('matlab_extracted_data/geodetic_data.mat');
            
            t_spi = [datetime(1961,1,1):days(1):datetime(2022,05,23)]';
            t_spi = t_spi(or(or(or(day(t_spi)==1,day(t_spi)==9),day(t_spi)==16),day(t_spi)==23)); % datetime array corresponding to spei data (until may 2022).
            t_sync = [datetime(1961,1:733,01,00,00,00)]';
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
                %RESAMPLE TO MONTHLY
                tt = timetable(t,spi01,spi03,spi06,spi09,spi12,spi24,spei01,spei03,spei06,spei09,spei12,spei24);
                tt = retime(tt,'monthly','nearest');
                % WARNING! this will resample with data for the first day
                % of each month, meaning that SPI-01 for instance
                % corresponds to previous months data and no data of the actual month is being taken into account.
                spi01 = tt.spi01; spi03 = tt.spi03; spi06 = tt.spi06; spi09 = tt.spi09; spi12 = tt.spi12; spi24 = tt.spi24; 
                spei01 = tt.spei01; spei03 = tt.spei03; spei06 = tt.spei06; spei09 = tt.spei09; spei12 = tt.spei12; spei24 = tt.spei24; 
                t = tt.t;
                save(['synced_mat_data/COM_monthly/COM_SPI_' sta_list_geod(i,:) '_1961_2021.mat'],'t','spi01','spi03','spi06','spi09','spi12','spi24','spei01','spei03','spei06','spei09','spei12','spei24');
            end
        end % inspired in function SPI.extractData and SPI.resampleDataMonthly (2 in 1)
        
        
        function [tab_SPEI,tab_SPI, tab_p_SPI, tab_p_SPEI] = plotIndexDataLEVERACOM(sta_list)
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
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\COM_monthly\COM_ERA_' sta '_1961_2021.mat']);
                
                nexttile(tcl);
                plot(t,pwv,'k'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('pwv')); ylim(PROC.ylims_('pwv')); title(sta);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\COM_monthly\COM_GRI_' sta '_1961_2021.mat']); % Vicente-Serrano Grid precipitation
                hold on; plot(datetime(2023,1,1),[-1],'b'); plot(datetime(2023,1,1),[-1],'r'); plot(datetime(2023,1,1),[-1],'g');
                lg = legend({'PWV/Prec.','SPCI-GNSS','SPI','SPEI'},'Location','Northoutside','Orientation','horizontal');
                lg.Layout.Tile = 'South';
                
                nexttile(tcl);
                plot(t,prec,'k'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('prec')); ylim(PROC.ylims_('prec'));
                % PE ALREADY LOADED FORM DER_monthly
                load(['synced_mat_data\COM_monthly\COM_PCI_' sta '_1961_2021.mat']);
                pci01 = spci01_sinera;
                pci03 = spci03_sinera;
                pci06 = spci06_sinera;
                pci09 = spci09_sinera;
                pci12 = spci12_sinera;
                pci24 = spci24_sinera;
                load(['synced_mat_data\COM_monthly\COM_SPI_' sta '_1961_2021.mat']);
                hold on; plot(datetime(2023,1,1),[-1],'b'); plot(datetime(2023,1,1),[-1],'r'); plot(datetime(2023,1,1),[-1],'g');
%                 lg = legend({'PWV/Prec.','SPCI-GNSS','SPI','SPEI'},'Location','Northoutside');%,'Orientation','horizontal');
%                 lg.Layout.Tile = 'East';set(lg.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.5;.5;.5;0]));  % [.5,.5,.5] is light gray; 0.8 means 20% transparent
%                 set(lg,'HandleVisibility','off');

                nexttile(tcl); plot(t,pci01,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI01'); %ylim([0,100]);
                hold on; plot(t,spi01,'color','r'); plot(t,spei01,'color','g');
                ind = isfinite(pci01);
                [cc_spi,p_spi] = corrcoef(pci01(ind),spi01(ind)); [cc_spei,p_spei] = corrcoef(pci01(ind),spei01(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'01'} = cc_spi(1,2); tab_SPEI{sta,'01'} = cc_spei(1,2); 
                tab_p_SPI{sta,'01'} = p_spi(1,2); tab_p_SPEI{sta,'01'} = p_spei(1,2); 
                
                nexttile(tcl); plot(t,pci03,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI03'); %ylim([0,100]);
                hold on; plot(t,spi03,'color','r'); plot(t,spei03,'color','g');
                ind = isfinite(pci03);
                [cc_spi,p_spi] = corrcoef(pci03(ind),spi03(ind)); [cc_spei,p_spei] = corrcoef(pci03(ind),spei03(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'03'} = cc_spi(1,2); tab_SPEI{sta,'03'} = cc_spei(1,2);
                tab_p_SPI{sta,'03'} = p_spi(1,2); tab_p_SPEI{sta,'03'} = p_spei(1,2); 
                
                nexttile(tcl); plot(t,pci06,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI06'); %ylim([0,100]);
                hold on; plot(t,spi06,'color','r'); plot(t,spei06,'color','g');
                ind = isfinite(pci06);
                [cc_spi,p_spi] = corrcoef(pci06(ind),spi06(ind)); [cc_spei,p_spei] = corrcoef(pci06(ind),spei06(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'06'} = cc_spi(1,2); tab_SPEI{sta,'06'} = cc_spei(1,2); 
                tab_p_SPI{sta,'06'} = p_spi(1,2); tab_p_SPEI{sta,'06'} = p_spei(1,2); 
                
                nexttile(tcl); plot(t,pci09,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI09'); %ylim([0,100]);
                hold on; plot(t,spi09,'color','r'); plot(t,spei09,'color','g');   
                ind = isfinite(pci09);
                [cc_spi,p_spi] = corrcoef(pci09(ind),spi09(ind)); [cc_spei,p_spei] = corrcoef(pci09(ind),spei09(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'09'} = cc_spi(1,2); tab_SPEI{sta,'09'} = cc_spei(1,2); 
                tab_p_SPI{sta,'09'} = p_spi(1,2); tab_p_SPEI{sta,'09'} = p_spei(1,2); 
                
                %spi12 = ERA_LEVEL.standardize(spi12); 
                %spei12 = ERA_LEVEL.standardize(spei12);
                nexttile(tcl); plot(t,pci12,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI12'); %ylim([0,100]);
                hold on; plot(t,spi12,'color','r'); plot(t,spei12,'color','g');
                ind = isfinite(pci12);
                [cc_spi,p_spi] = corrcoef(pci12(ind),spi12(ind)); [cc_spei,p_spei] = corrcoef(pci12(ind),spei12(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'12'} = cc_spi(1,2); tab_SPEI{sta,'12'} = cc_spei(1,2); 
                tab_p_SPI{sta,'12'} = p_spi(1,2); tab_p_SPEI{sta,'12'} = p_spei(1,2); 
                
                nexttile(tcl); plot(t,pci24,'color','#0072BD'); xlim([datetime(1961,1,1) datetime(2021,12,12)]); ylabel('SPCI24'); %ylim([0,100]);
                hold on; plot(t,spi24,'color','r'); plot(t,spei24,'color','g');
                ind = isfinite(pci24);
                [cc_spi,p_spi] = corrcoef(pci24(ind),spi24(ind)); [cc_spei,p_spei] = corrcoef(pci24(ind),spei24(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),0,tx,'FontSize',10);
                tab_SPI{sta,'24'} = cc_spi(1,2); tab_SPEI{sta,'24'} = cc_spei(1,2); 
                tab_p_SPI{sta,'24'} = p_spi(1,2); tab_p_SPEI{sta,'24'} = p_spei(1,2); 
            end
        end
        
        function correlSPCISPEI12COM
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci12_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei12');
                spci12 = spci12_sinera;
                
                ind = isfinite(spci12);
                cc = corrcoef(spci12(ind),spei12(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI06COM
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci06_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei06');
                spci06 = spci06_sinera;
                
                ind = isfinite(spci06);
                cc = corrcoef(spci06(ind),spei06(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEI24COM
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci24_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei24');
                spci24 = spci24_sinera;
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i) = cc(1,2);
            end
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
            ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function correlSPCISPEITimespan
            
            figure(); tiledlayout(1,3,'TileSpacing','tight');
            nexttile();ERA_LEVEL.correlSPCISPEI24; title('GNSS-SPCI, 15-years timespan, 24-months'); xlabel('Station name'); ylabel('SPEI-SPCI correlation coefficient');
            nexttile();ERA_SPCI.correlSPCISPEI24; title('ERA5-SPCI, 15-years timespan, 24-months');xlabel('Station name');
            nexttile();ERA_SPCI.correlSPCISPEI24COM; title('ERA5-SPCI, 61-years timespan, 24-months');xlabel('Station name');
            
        end
        
        
        function [list_cc, list_rms] = correlSPCIvsSPI24
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci24_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei24','spi24');
                spci24 = spci24_sinera;
                
                ind = isfinite(spci24);
                cc = corrcoef(spci24(ind),spei24(ind));
                list_cc(i,1) = cc(1,2);
                list_rms(i,1) = rms(spci24(ind)-spei24(ind));
                cc = corrcoef(spi24(ind),spei24(ind));
                list_cc(i,2) = cc(1,2);
                list_rms(i,2) = rms(spi24(ind)-spei24(ind));
                if list_rms(i,1)<list_rms(i,2)
                    disp(sta_list{i});
                    disp(list_cc(i,:));
                    disp(list_rms(i,:));
                end
            end
            
            disp(sum(list_cc(:,1)>list_cc(:,2)));
            disp(sum(list_rms(:,1)<list_rms(:,2)));
%             ERA_LEVEL.plotSpatialCorrelDifferential(sta_list,list_cc);
%             ERA_LEVEL.plotSpatialCorrelMixed(sta_list,list_cc);
%             ERA_LEVEL.plotHistoCorrel(sta_list,list_cc,[0.6 1]);
        end
        
        function [list_cc, list_rms] = correlSPCIvsSPI12
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci12_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei12','spi12');
                spci12 = spci12_sinera;
                
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
        
        function [list_cc, list_rms] = correlSPCIvsSPI06
            
            load('matlab_extracted_data/geodetic_data.mat');
            geod_list([16,41],:) = []; sta_list_geod([16,41],:) = []; % temporarily ommit EPCU and TIOU as out of ERA5 level grid boundary
            geod_list([13,24],:) = []; sta_list_geod([13,24],:) = []; % temporarily ommit CEU1 and MELI as out of Vicente Serrano grid boundary
            %geod_list(17,:) = []; sta_list_geod(17,:) = []; % Ommit Huércal-Overa because of irregular results
            %geod_list([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:) = []; sta_list_geod([22,34,39,40,1,4,8,9,17,26,29,38,2,7,10,18,35],:)=[]; % Ommit stations with less than 10 years.
            sta_list = cellstr(sta_list_geod);
            
            list_cc = NaN(length(sta_list),1);
            list_rms = NaN(length(sta_list),1);
            for i=1:length(sta_list)
                load(['synced_mat_data/COM_monthly/COM_PCI_' sta_list{i} '_1961_2021.mat'], 't', 'spci06_sinera');
                load(['synced_mat_data/COM_monthly/COM_SPI_' sta_list{i} '_1961_2021.mat'], 't', 'spei06','spi06');
                spci06 = spci06_sinera;
                
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
        
        


    end
    
    
    methods (Static, Access = public) % General SPCI results for the whole territory
        
        function extractERADataPWVGeneral() % inspired in function with the same name in class ERA_EUREF
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
                if isfile(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'])
                    save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv' ,'-append');
                else
                    save(['synced_mat_data/ERA_hourly/SYNC_ERA_' sta_list_geod(i,:) '_2007_2021.mat'],'t','pwv');
                end
            end
        end
            
    end
end

