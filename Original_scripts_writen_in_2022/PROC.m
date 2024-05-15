classdef PROC
    % Class to jointly process positioning, troposphere and meteo data
    
    properties (Constant,Access=public)
        
    stations = upper({'ALME','CARG','CEU1','COBA','HUEL','MALA','MELI','MOFR','TALR',...
                    'VICA','ZFRA','SFER','algc','almr','arac','caal','cabr','caza',...
                    'crdb','hulv','huov','lebr','mlga','osun','palc',...
                    'pozo','ujae','viar',...
                    'GRA3','UCA3','SEV3','RON3','MOT3','AND3',...
                    'ALJI', 'AREZ', 'CAST', 'EPCU', 'LIJA', 'LOJA', 'NEVA',...
                    'PALM', 'PILA', 'RUBI', 'TGIL', 'TIOU'}');
    stations_w_meteo = upper({'ALME','CEU1','COBA','HUEL','MALA','MOFR','TALR',...
                    'VICA','ZFRA','SFER','algc','almr','arac','caal','cabr','caza',...
                    'crdb','hulv','huov','lebr','mlga','osun','palc',...
                    'pozo','ujae','viar',...
                    'GRA3','UCA3','SEV3','RON3','MOT3','AND3',...
                    'ALJI', 'AREZ', 'CAST', 'LIJA', 'LOJA', 'NEVA',...
                    'PALM', 'TGIL'}');
                
   stations_10_years = upper({'ALME','COBA','HUEL','MALA',...
                    'SFER','arac','caza',...
                    'crdb','hulv','huov','mlga','osun',...
                    'ujae',...
                    'GRA3','UCA3','SEV3','RON3','MOT3','AND3',...
                    'LOJA', 'NEVA',...
                    'PALM'}');
   ind_10_years = [1; 3; 4; 5; 10; 13; 16; 17; 18; 19; 21; 22; 25; 27; 28; 29; 30; 31; 32; 37; 38; 39];
    
    comp_stations = {'ALGC','AREZ','CAAL','CABR','CAST','CEU1','COBA','CRDB',...
            'HUEL','LIJA','MALA','MOT3','NEVA','OSUN','PALC',...
            'POZO','SEV3','TALR','UCA3','UJAE','VIAR','ZFRA'}; %Stations with available rediam data.
        
    selec_stations = {'CABR','CEU1','CRDB',...
            'HUEL','MOT3','OSUN',...
            'POZO','UJAE','VIAR'}; %Stations with a visually good and continuous climate data
    end
    
    properties (Constant, Access=public)
        %% Limits and labels for variables (new system)
        
        info_u = struct(...
                'name','u',...
                'y_lim',[-0.1,0.1],...
                'y_label',['Up' newline '(m)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\POS_daily\SYNC_POS_');
            
        info_ztd = struct(...
                'name','ztd',...
                'y_lim',[1.7,2.5],...
                'y_label',['ZTD' newline '(m)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_');
            
        info_zwd = struct(...
                'name','zwd',...
                'y_lim',[0.0,0.25],...
                'y_label',['ZWD' newline '(m)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_');
            
        info_pwv = struct(...
                'name','pwv',...
                'y_lim',[0.0,0.05]*1e3,...
                'y_label',['GNSS PWV' newline '(mm)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_');
            
        info_pwv_era = struct(...
                'name','pwv',...
                'y_lim',[0.0,0.05]*1e3,...
                'y_label',['ERA PWV' newline '(mm)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_daily\SYNC_ERA_');
            
        info_pwv_met_era = struct(...
                'name','pwv_met_era',...
                'y_lim',[0.0,0.05]*1e3,...
                'y_label',['GNSS meteo ERA PWV' newline '(mm)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_');
            
        info_pef = struct(...
                'name','pef',...
                'y_lim',[0,100],...
                'y_label',['PE' newline '(%)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_');
            
        info_temp = struct(...
                'name','temp',...
                'y_lim',[-10,40],...
                'y_label',['Temperature' newline '(ºC)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_daily\SYNC_CLI_');
        info_prec = struct(...
                'name','prec',...
                'y_lim',[0,20],...
                'y_label',['Precipitation' newline '(mm)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_daily\SYNC_CLI_');
            
        info_temp_era = struct(...
                'name','temp_era',...
                'y_lim',[-10,40],...
                'y_label',['ERA5 Temperature' newline '(ºC)'],...
                'dir_root','C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_daily\SYNC_ERA_');
        
        vars_ = {'u','ztd','zwd',...
                'pwv','pwv_era','pwv_met_era',...
                'pef',...
                'temp','prec','temp_era'};
            
        infos = {PROC.info_u,PROC.info_ztd,PROC.info_zwd,...
                PROC.info_pwv,PROC.info_pwv_era,PROC.info_pwv_met_era,...
                PROC.info_pef,...
                PROC.info_temp,PROC.info_prec,PROC.info_temp_era};
            
        INFO = containers.Map(PROC.vars_,PROC.infos);

        info_lim = [datetime(2007,1,1) datetime(2021,12,31)];
        
        %% Old system
        vars = {'u','ztd','zwd','pwv','pef','temp','prec'};
        y_lims = {[-0.1,0.1],[1.7,2.5],[0.0,0.25],[0.0,0.05]*1e3,[0,100],[-10,40],[0,20]};
        y_labels = {['Up' newline '(m)'],['ZTD' newline '(m)'],['ZWD' newline '(m)'],['PWV' newline '(mm)'],['PE' newline '(%)'],['Temperature' newline '(ºC)'],['Precipitation' newline '(mm)']};
        dir_root = {'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\POS_daily\SYNC_POS_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_daily\SYNC_CLI_',
                    'C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_daily\SYNC_CLI_'};
                
        ylims_ = containers.Map(PROC.vars,PROC.y_lims);
        ylabels_ = containers.Map(PROC.vars,PROC.y_labels);
        dir_root_ = containers.Map(PROC.vars,PROC.dir_root);
    end
    
    properties (Constant,Access = public)
        mond = [eomday(2007,1:12),eomday(2008,1:12),eomday(2009,1:12),eomday(2010,1:12),eomday(2011,1:12),eomday(2012,1:12),eomday(2013,1:12),eomday(2014,1:12),...
                eomday(2015,1:12),eomday(2016,1:12),eomday(2017,1:12),eomday(2018,1:12),eomday(2019,1:12),eomday(2020,1:12),eomday(2021,1:12),eomday(2022,1)];
    end
       
    methods (Static, Access = public)
        %% Plotting
        
        function plotData(sta_list)
            % PROC.plotData(PROC.comp_stations);
            % PROC.plotData(PROC.selec_stations);
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                figure();
                sta = sta_list{i};
                info = PROC.INFO('u'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,1); plot(t,u,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('ztd'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,2); plot(t,ztd,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('zwd'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,3); plot(t,zwd,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('temp'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,4); plot(t,temp,'color','#77AC30'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('prec'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,5); plot(t,prec,'color','#77AC30'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('pwv'); 
                load([info.dir_root sta '_2007_2021.mat']);
                subplot(6,1,6); plot(t,pwv,'color','#0072BD'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
            end
        end
        
        function plotERACompData(sta_list)
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                figure();
                sta = sta_list{i};
                
                info = PROC.INFO('pwv'); 
                l = load([info.dir_root sta '_2007_2021.mat']); t = l.t; 
                if isfield(l,info.name)
                    var = l.(info.name);
                else
                    var = NaN(size(t));
                end
                subplot(3,1,1); plot(t,var,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('pwv_era'); 
                l = load([info.dir_root sta '_2007_2021.mat']); t = l.t; var = l.(info.name);
                subplot(3,1,2); plot(t,var,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
                info = PROC.INFO('pwv_met_era'); 
                l = load([info.dir_root sta '_2007_2021.mat']); t = l.t; var = l.(info.name);
                subplot(3,1,3); plot(t,var,'k'); xlim(PROC.info_lim); ylabel(info.y_label); ylim(info.y_lim); title(sta);
            end
        end
        
        function plotIndexData(sta_list)
            % Plot SPI SPEI and PCI idexes and correlation %
            % Must be applied to stations that have monthly PWV and
            % precipitaion data already calculated.
            % PROC.plotIndexData(PROC.comp_stations);
            % PROC.plotIndexData(PROC.selec_stations);
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                figure();
                set(gcf,'Position',[1000,600,500,700]);
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                
                subplot(8,1,1); plot(t,pwv,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('pwv')); ylim(PROC.ylims_('pwv')); title(sta);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_monthly\SYNC_CLI_' sta '_2007_2021.mat']);
                subplot(8,1,2); plot(t,prec,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('prec')); ylim(PROC.ylims_('prec'));
                % PE ALREADY LOADED FORM DER_monthly
                load(['synced_mat_data\PCI_monthly\SYNC_PCI_' sta '_2007_2021.mat']);
                load(['synced_mat_data\SPI_monthly\SYNC_SPI_' sta '_2007_2021.mat']);
                
                subplot(8,1,3); plot(t,pci01,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI01'); ylim([0,100]);
                hold on; plot(t,spi01*10+50,'color','r'); plot(t,spei01*10+50,'color','g');
                ind = isfinite(pci01);
                cc_spi = corrcoef(pci01(ind),spi01(ind)); cc_spei = corrcoef(pci01(ind),spei01(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
                legend({'PCI-GNSS','SPI','SPEI'},'Location','Northwest');
                
                subplot(8,1,4); plot(t,pci03,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI03'); ylim([0,100]);
                hold on; plot(t,spi03*10+50,'color','r'); plot(t,spei03*10+50,'color','g');
                ind = isfinite(pci03);
                cc_spi = corrcoef(pci03(ind),spi03(ind)); cc_spei = corrcoef(pci03(ind),spei03(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
                
                subplot(8,1,5); plot(t,pci06,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI06'); ylim([0,100]);
                hold on; plot(t,spi06*10+50,'color','r'); plot(t,spei06*10+50,'color','g');
                ind = isfinite(pci06);
                cc_spi = corrcoef(pci06(ind),spi06(ind)); cc_spei = corrcoef(pci06(ind),spei06(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
                
                subplot(8,1,6); plot(t,pci09,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI09'); ylim([0,100]);
                hold on; plot(t,spi09*10+50,'color','r'); plot(t,spei09*10+50,'color','g');   
                ind = isfinite(pci09);
                cc_spi = corrcoef(pci09(ind),spi09(ind)); cc_spei = corrcoef(pci09(ind),spei09(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
                
                subplot(8,1,7); plot(t,pci12,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI12'); ylim([0,100]);
                hold on; plot(t,spi12*10+50,'color','r'); plot(t,spei12*10+50,'color','g');
                ind = isfinite(pci12);
                cc_spi = corrcoef(pci12(ind),spi12(ind)); cc_spei = corrcoef(pci12(ind),spei12(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
                
                subplot(8,1,8); plot(t,pci24,'color','#0072BD'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel('PCI24'); ylim([0,100]);
                hold on; plot(t,spi24*10+50,'color','r'); plot(t,spei24*10+50,'color','g');
                ind = isfinite(pci24);
                cc_spi = corrcoef(pci24(ind),spi24(ind)); cc_spei = corrcoef(pci24(ind),spei24(ind)); 
                tx = ['Correlations:' newline sprintf('SPI:   %.2f',cc_spi(1,2)) newline sprintf('SPEI   %.2f',cc_spei(1,2))];
                text(datetime(2019,1,1),50,tx,'FontSize',10);
            end
        end
        
        function plotSingleData(var,n_col,sta_list)
            switch nargin
                case 1
                    sta_list = PROC.stations;
                    n_col = 1;
                case 2
                    sta_list = PROC.stations;
            end
            figure();
            n_sta = length(sta_list);
            for i=1:n_sta
                sta = sta_list{i};
                data = load([PROC.dir_root_(var) sta '_2007_2021.mat']);
                var_data = data.(var);
                t = data.('t');
                subplot(ceil(n_sta/n_col),n_col,i); plot(t,var_data,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); 
                title(sta); ylabel(PROC.ylabels_(var)); ylim(PROC.ylims_(var)); grid on;
                if contains(var,'pwv')
                    data = load(['synced_mat_data/ERA_daily/SYNC_ERA_' sta '_2007_2021.mat']);
                    var_data_2 = data.(var);
                    t = data.('t');
                    subplot(ceil(n_sta/n_col),n_col,i); hold on; plot(t,var_data_2,'r'); hold off; plot(t,var_data - var_data_2+20,'b');
                end
            end
        end
        
        function plotSpatial(sta_list,var,phas)
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
                p = scatter(x,y,12*abs(val).^2,'m','filled','MarkerEdgeColor','k'); hold on;
                p.MarkerFaceAlpha = .5;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)+366/4-226);
                    quiver(x,y,cos(ang)*1e5/5,sin(ang)*1e5/5,'k','LineWidth',3);
                end
                
                subplot(1,4,4);
                p_2 = scatter(h*1e-3,val,'m','filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(val),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of noise RMS']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'m','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,4*1e6,'          10mm');
            
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Value (mm)'); title(['Altimetric distribution of noise RMS']);

        end
        
        function plotSpatialPhase(sta_list,var,phas)
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
            
            subplot(1,4,4);
            p = get(gca, 'Position');
            delete(gca);
            h2 = axes('Parent', gcf, 'Position', [0.7484 0.1100 0.1566 0.35]);
            h1 = axes('Parent', gcf, 'Position', [0.7484 0.5500 0.1566 0.35]);
            

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i);
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                if x>3.5*1e5
                    color = 'r';
                else
                    color = 'c';
                end
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                p = scatter(x,y,12*abs(val).^2,color,'filled','MarkerEdgeColor','k'); hold on;
                p.MarkerFaceAlpha = .5;
                text(x,y,sta);
                if phas~=0
                    ang = 2*pi/366*(phas(i)-226);
                    quiver(x,y,sin(ang)*1e5/5,cos(ang)*1e5/5,'k','LineWidth',3);
                end
                
                axes(h1);
                p_2 = scatter(h*1e-3,val, color,'filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(val),sta);
                axes(h2);
                p_2 = scatter(h*1e-3,phas(i)-226,color,'filled','MarkerEdgeColor','k'); hold on;
                text(double(h*1e-3),double(phas(i)-226),sta);
            end
            
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title(['Planimetric distribution of seasonal signal amplitude and phase']);
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'r','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,4*1e6,'          10mm (Eastern stations)');
            p = scatter(5*1e5,(4.03)*1e6,12*abs(10).^2,'c','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,(4.03)*1e6,'          10mm (Western stations)');
            
            axes(h1); xlabel('Height (km)');ylabel('Amplitude (mm)'); title(['Altimetric distribution of seasonal signal amplitude']);
            axes(h2); xlabel('Height (km)');ylabel('Phase difference from mean (days)'); title(['Altimetric distribution of seasonal signal phase']);

        end
        
        function plotSpatialTrend(sta_list,var)
            var = var*10;
            f = figure();
            set(f,'Position',[819.6667 445.6667 1.6613e+03 730.6666]);

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
            alpha(h,.2); hold on;

            load('matlab_extracted_data/geodetic_data.mat');
            for i=1:size(sta_list,1)
                sta = sta_list{i};
                val = var(i);
                % x,y,h coordinates
                geod_coord = geod_list(strcmp(sta,string(sta_list_geod)),1:2);
                [x,y] = GF.geod2plan_andal(geod_coord(1),geod_coord(2)); % Coordenadas en huso 30
                h = geod_list(strcmp(sta,string(sta_list_geod)),3);
                
                subplot(1,4,1:3);
                if sta=="SFER"
                    p = scatter(x,y,12*abs(val).^2,'r','filled','MarkerEdgeColor','k'); hold on;
                else
                    p = scatter(x,y,12*abs(val).^2,'g','filled','MarkerEdgeColor','k'); hold on;
                end
                p.MarkerFaceAlpha = .5;
                text(x,y,sta);
                
                subplot(1,4,4);
                if sta=="SFER"
                    p_2 = scatter(h*1e-3,val*1e-1,'r','filled','MarkerEdgeColor','k'); hold on;
                else
                    p_2 = scatter(h*1e-3,val*1e-1,'g','filled','MarkerEdgeColor','k'); hold on;
                end
                text(double(h*1e-3),double(val*1e-1),sta);
            end
            subplot(1,4,1:3);
            axis equal; xlabel('X UTM (m) (huso 30)');ylabel('Y UTM (m) (huso 30)'); title('Planimetric distribution of trend');
            p = scatter(5*1e5,4*1e6,12*abs(10).^2,'g','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,4*1e6,'          1mm/decade');
            p = scatter(5*1e5,(4.03)*1e6,12*abs(10).^2,'r','filled','MarkerEdgeColor','k'); hold on;
            p.MarkerFaceAlpha = .5;
            text(5*1e5,(4.03)*1e6,'         -1mm/decade');
            subplot(1,4,4);
            a = gca; a.Position = [0.7484 0.3100 0.2 0.4];
            xlabel('Height (km)');ylabel('Value'); title('Altimetric distribution of trend');

        end
        
        function plotCorrelation(data,sta_list)
            c_p = corrcoef(data,'Rows','Pairwise');
            n_sta = length(sta_list);
            c_p(1:n_sta+1:n_sta*n_sta) = NaN; %Omit diagonal values that have correlation one
            figure();
            imagesc(c_p);
            yticks([1:n_sta]);yticklabels(cellstr(sta_list));
            xticks([1:n_sta]);xticklabels(cellstr(sta_list));
            colorbar;
        end
        
        %% Comparisons and analyses
        
        function comparePWVERA(sta_list)
            % PROC.comparePWVERA(PROC.comp_stations)
            switch nargin
                case 0
                    sta_list = PROC.stations_w_meteo;
            end
            bias = [];
            std_ = [];
            for i=1:length(sta_list)
                figure();
                sta = sta_list{i};
                subplot(4,1,1);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_daily\SYNC_ERA_' sta '_2007_2021.mat']);
                plot(t,pwv,'r-'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('pwv')); ylim(PROC.ylims_('pwv')); title(['ERA vs GNSS' newline sta]); hold on;
                pwv_ERA = pwv;
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                plot(t,pwv,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); 
                delta = pwv-pwv_ERA; plot(t,delta,'b'); yline(mean(delta,'omitnan'),'k--'); legend({'ERA5','GNSS','GNSS-ERA5','Bias'}); ylim([-0.01 0.05]*1e3);
                text(datetime(2008,1,1),40,['Bias:    ' sprintf('%+5.2f mm',mean(delta,'omitnan')) newline 'STD:    ' sprintf('%4.2f mm',std(delta,'omitnan'))]);
                bias(i) = mean(delta,'omitnan'); std_(i) = std(delta,'omitnan');
                
                subplot(4,1,3:4);
                scatter(pwv_ERA,pwv); xlabel('PWV ERA5'); ylabel('PWV GNSS');
                
                %Monthly data
%                 subplot(4,1,2);
%                 load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_monthly\SYNC_ERA_' sta '_2007_2021.mat']);
%                 plot(t,pwv,'r-'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); ylabel(PROC.ylabels_('pwv')); ylim(PROC.ylims_('pwv')); hold on;
%                 pwv_ERA = pwv;
%                 load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
%                 plot(t,pwv,'k'); xlim([datetime(2007,1,1) datetime(2021,12,12)]); 
%                 delta = pwv-pwv_ERA; plot(t,delta,'b'); yline(mean(delta,'omitnan'),'k--'); legend({'ERA5','GNSS','GNSS-ERA5','Bias'}); ylim([-0.01 0.05]*1e3);
%                 text(datetime(2008,1,1),40,['Bias:    ' sprintf('%+5.2f mm',mean(delta,'omitnan')) newline 'STD:    ' sprintf('%4.2f mm',std(delta,'omitnan'))]);

            end
            sta_list = sta_list'; bias = bias'; std_ = std_';
            save('matlab_extracted_data\ERA_comparison_results.mat','sta_list','bias','std_');
        end
        
        function ERAbiasVsHeight
            load('matlab_extracted_data/ERA_comparison_results.mat');
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list_geod = cellstr(sta_list_geod);
            h = []; b = [];
            for i=1:length(sta_list)
                ind = strcmp(sta_list(i),sta_list_geod);
                h(i) = geod_list(ind,3)/1e3; %km
                b(i) = bias(i);
            end
            lin = [ones(size(h')),h']\b';
            figure(); scatter(h,b); hold on; plot([-0.1:0.01:3],[-0.1:0.01:3]*lin(2) + lin(1),'b');
            text(h,b,sta_list);
            xlabel('Height(km)'); ylabel('Bias (mm)'); title('GNSS-ERA PWV Bias vs. Height');
        end
        
        function meanPWVVsHeight(sta_list)
            % PROC.meanPWVVsHeight(PROC.comp_stations)
            switch nargin
                case 0
                    sta_list = PROC.stations_w_meteo;
            end
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list_geod = cellstr(sta_list_geod);
            h = []; pwv_ERA = []; pwv_GNSS = [];
            for i=1:length(sta_list)
                sta = sta_list{i};
                ind = strcmp(sta_list(i),sta_list_geod);
                h(i) = geod_list(ind,3)/1e3; %km
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_daily\SYNC_ERA_' sta '_2007_2021.mat']);
                pwv_ERA(i) = mean(pwv,'omitnan');
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                pwv_GNSS(i) = mean(pwv,'omitnan');
            end
            %lin = [ones(size(h')),h']\b';
            figure(); %scatter(h,b_ERA,'r'); hold on; 
            lin = [ones(size(h')),h']\pwv_GNSS';
            scatter(h,pwv_GNSS,'b'); hold on; plot([-0.1:0.01:3],[-0.1:0.01:3]*lin(2) + lin(1),'b');
            text(2,16,['Slope: ' num2str(lin(2)) newline 'Intercept: ' num2str(lin(1))]);
            xlabel('Height(km)'); ylabel('Mean PWV (mm)'); title('Mean PWV vs. Height'); %legend({'ERA5','GNSS'});
        end

        %% Decomposition of signal
        
        function analyseDecomposedData(sta_list)
            switch nargin
                case 0
                    sta_list = PROC.stations_w_meteo;
            end
            n_sta = length(sta_list);
            
            total_data = [];
            for j=1:length(sta_list)
                sta = sta_list{j};
                disp(sta);
                load(['synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                mean_trend(j,1) = mean(trend,'omitnan');
                mean_trend_red(j,1) = mean(trend_red,'omitnan');
                std_trend(j,1) = std(trend,'omitnan');
                max_min_dev_trend(j,:) = [max(trend-mean(trend,'omitnan')),min(trend-mean(trend,'omitnan'))];
                
                % TREND ESTIMATION:
                [tr,un] = PROC.linearRegression(t,trend_red); lr_trend_red(j,1:2) = [tr,un]; % delta is not necessarily equivalent to uncertainty
                ts_trend_red(j,1) = PROC.fastTheilSen(t,trend_red);
%                 [tr,un] = PROC.MIDASAnalysis(t,trend_red); md_trend_red(j,1:2) = [tr,un];
                
                % SIN FITTING:
                days = [1:366]';
                [ampl,phas] = LSsin(days(isfinite(seas_lim)),seas_lim(isfinite(seas_lim))); fit_seas_lim(j,1:2) = [ampl,phas];
                
                % NOISE
                rms_noise(j,:) = rms(noise,'omitnan');

                total_trend_red(:,j) = trend_red;
                total_seas_lim(:,j) = seas_lim;
                total_noise(:,j) = noise;
            end
            
            sta_list_10 = sta_list(PROC.ind_10_years,:);
            lr_trend_red_10 = lr_trend_red(PROC.ind_10_years,:);
            ts_trend_red_10 = ts_trend_red(PROC.ind_10_years,:);
            %md_trend_red_10 = md_trend_red(PROC.ind_10_years,:);
            fit_seas_lim_10 = fit_seas_lim(PROC.ind_10_years,:);
            
            mean_total_trend_red = mean(total_trend_red,2,'omitnan');
            mean_total_seas_lim =  mean(total_seas_lim,2,'omitnan');
            mean_total_noise =  mean(total_noise,2,'omitnan');
            save('matlab_extracted_data/decomp_data.mat','sta_list','mean_trend','mean_trend_red','std_trend','max_min_dev_trend','rms_noise',...
                'mean_total_trend_red','mean_total_seas_lim','mean_total_noise',...
                'sta_list_10','lr_trend_red','lr_trend_red_10','ts_trend_red','ts_trend_red_10','fit_seas_lim','fit_seas_lim_10',...%,'md_trend_red','md_trend_red_10');
                'total_trend_red','total_seas_lim','total_noise');
        end
        
        function plotDecomposedData(sta_list_)
            switch nargin
                case 0
                    sta_list_ = PROC.stations_w_meteo;
            end
            load('matlab_extracted_data/decomp_data.mat');
            sta_list = sta_list_;
            n_sta = length(sta_list);
            for j=1:length(sta_list)
                sta = sta_list{j};
                load(['synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                figure()
                subplot(4,1,1); plot(t,trend); xlim([datetime(2007,7,1) datetime(2021,7,1)]);title(sta); ylabel(['Trend' newline 'PWV(mm)']);
                subplot(4,1,2); plot(t,seas); xlim([datetime(2007,7,1) datetime(2021,7,1)]); ylabel(['Seasonal component' newline 'PWV(mm)']);
                subplot(4,1,3); plot(t,noise,'.'); xlim([datetime(2007,7,1) datetime(2021,7,1)]); ylabel(['Noise' newline 'PWV(mm)']);
                subplot(4,1,4); plot(t,pwv); xlim([datetime(2007,7,1) datetime(2021,7,1)]); ylabel(['Total' newline 'PWV(mm)']);
                figure(2); hold on; plot(t,trend_red,'color','#BDBDBD'); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
                figure(3); hold on; plot(t,trend); xlim([datetime(2007,1,1) datetime(2022,1,1)]);
                figure(4); hold on; plot(1:366,seas_lim,'color','#BDBDBD');
                figure(5); hold on; plot(t,noise,'.','color','#BDBDBD'); xlim([datetime(2007,7,1) datetime(2021,7,1)]);
            end
            figure(2); plot(t,mean_total_trend_red,'k--','LineWidth',3); grid on; yline(mean(mean_total_trend_red,'omitnan'),'k');
            ylabel('Height reduced PWV(mm)'); xlabel('Year'); title('PWV trend');
            figure(4); plot([1:366],mean_total_seas_lim,'k--','LineWidth',2); grid on; yline(mean(mean_total_seas_lim,'omitnan'),'k');
            plot([1:366],5.446849*sin(2*pi/366*[1:366] + -2.310865),'k-','LineWidth',2); grid on;
            ylabel('Seasonal component of PWV(mm)'); xlabel('DOY'); title('PWV seasonal component');
            figure(5);  plot(t,mean_total_noise,'k.'); grid on;
            ylabel('Residual noise of PWV(mm)'); xlabel('Year'); title('PWV residual noise');
        end
        
        function decomposePWVData(sta_list)
            switch nargin
                case 0
                    sta_list = PROC.stations_w_meteo;
            end
            %figure();
            
            n_sta = length(sta_list);
            trend_mat = [];
            ref_trend = [];
            load('matlab_extracted_data/geodetic_data.mat');
            sta_list_geod = cellstr(sta_list_geod);
            for j=1:length(sta_list)
                sta = sta_list{j};
                l = load(['synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                var = l.('pwv'); t = l.('t'); mask = l.('mask');
                
                % First trend calculation 
                n = length(var);
                mat = NaN(n,364);
                for i=1:182 % Not exactly 365.25 days but will work
                    mat(1:n+1-i,183-i) = var(i:end);
                    mat(i:end,182+i) = var(1:n+1-i);
                end
                trend = mean(mat,2,'omitnan');
                trend = trend.*mask;
                
                % Seasonal part calculation
                seas = var - trend;
                seas_folded = NaN(366,16);
                ind_stat_doy = day(t,'dayofyear');
                ind_stat_year = year(t)-2006;
                for i=1:length(var)
                    seas_folded(ind_stat_doy(i),ind_stat_year(i)) = seas(i);
                end
                seas_lim = mean(seas_folded,2,'omitnan');
                seas_lim = seas_lim-mean(seas_lim,'omitnan'); % mean = 0
                seas = [seas_lim(1:365);seas_lim(1:366);seas_lim(1:365);seas_lim(1:365);seas_lim(1:365);seas_lim(1:366);...
                    seas_lim(1:365);seas_lim(1:365);seas_lim(1:365);seas_lim(1:366);seas_lim(1:365);seas_lim(1:365);...
                    seas_lim(1:365);seas_lim(1:366);seas_lim(1:366)];
                seas = seas.*mask;
                
                % New trend calculation.
                trend = var-seas;
                n = length(var);
                mat = NaN(n,364);
                for i=1:182 % Not exactly 365.25 days but will work
                    mat(1:n+1-i,183-i) = var(i:end);
                    mat(i:end,182+i) = var(1:n+1-i);
                end
                trend = mean(mat,2,'omitnan');
                trend = trend.*mask;
                
                % Height reduced trend calculation
                ind = strcmp(sta_list(j),sta_list_geod);
                h = geod_list(ind,3)/1e3; %km
                r = -4.9671;
                trend_red = trend - r*h;
                
                % Noise calculation
                noise = var - trend - seas;
                
                pwv = var;
                save(['synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat'],'t','pwv','mask','trend','trend_red','seas','seas_lim','noise');
            end
        end
        
        %% Calculations
        
        function computePCIMultiscale(sta_list)
            % Compute SPCI 1, 3, 6, 9, 12.
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat']);
                load(['synced_mat_data\CLI_monthly\SYNC_CLI_' sta '_2007_2021.mat']);
                prec = [NaN(24,1); prec]; pwv = [NaN(24,1); pwv]; % Add NaN so that pci is not computed for first months
                n_sync = size(t,1);
                pci01 = NaN(n_sync,1); pci03 = NaN(n_sync,1); pci06 = NaN(n_sync,1); pci09 = NaN(n_sync,1); pci12 = NaN(n_sync,1);
                mond = [NaN(1,24) PROC.mond]; % number of days in each month, starting january 2007
                for m = 1:n_sync
                    n = m+24; % to skip first 12 NaNs
                    pci01(m) = prec(n)/pwv(n)*100;
                    pci03(m) = sum(prec(n:-1:n-3).*mond(n:-1:n-3))/sum(pwv(n:-1:n-3).*mond(n:-1:n-3))*100;
                    pci06(m) = sum(prec(n:-1:n-6).*mond(n:-1:n-6))/sum(pwv(n:-1:n-6).*mond(n:-1:n-6))*100;
                    pci09(m) = sum(prec(n:-1:n-9).*mond(n:-1:n-9))/sum(pwv(n:-1:n-9).*mond(n:-1:n-9))*100;
                    pci12(m) = sum(prec(n:-1:n-12).*mond(n:-1:n-12))/sum(pwv(n:-1:n-12).*mond(n:-1:n-12))*100;
                    pci24(m) = sum(prec(n:-1:n-24).*mond(n:-1:n-24))/sum(pwv(n:-1:n-24).*mond(n:-1:n-24))*100;
                end
                save(['synced_mat_data\PCI_monthly\SYNC_PCI_' sta '_2007_2021.mat'],'t','pci01','pci03','pci06','pci09','pci12','pci24');
            end
        end
        
        function computeMonthlyMeansPE(sta_list)
            % Compute monthly means for variables prec and PWV for further
            % index analyses, and compute PE.
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['synced_mat_data\CLI_daily\SYNC_CLI_' sta '_2007_2021.mat']);
                tt = timetable(t,prec,temp);
                tt = retime(tt,'monthly','mean');
                t = tt.t; prec = tt.prec; temp = tt.temp;
                save(['synced_mat_data\CLI_monthly\SYNC_CLI_' sta '_2007_2021.mat'],'t','prec','temp');
                load(['synced_mat_data\DER_daily\SYNC_DER_' sta '_2007_2021.mat']);
                tt = timetable(t,pwv);
                tt = retime(tt,'monthly','mean');
                t = tt.t; pwv = tt.pwv;
                pef = prec./pwv*100; % in percentage
                save(['synced_mat_data\DER_monthly\SYNC_DER_' sta '_2007_2021.mat'],'t','pwv','pef');
            end
        end
        
        function computePWVData(sta_list)
            % Computes PWC data from synced ZWD and Temp. and saves it in
            % DER (derived) folder of synced data.
            %PROC.computePWVData(PROC.comp_stations)
            switch nargin
                case 0
                    sta_list = PROC.stations_w_meteo;
            end
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_' sta '_2007_2021.mat']);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\CLI_daily\SYNC_CLI_' sta '_2007_2021.mat']);
                pwv = PROC.PWV(zwd,temp)*1e3; %mm
                
%                 % interpolate data
%                 i_beg = find(~isnan(pwv),1);
%                 i_end = find(~isnan(flip(pwv)),1);
%                 tt = timetable(t(i_beg:i_end),pwv(i_beg:i_end));
%                 tt = retime(tt,'daily','spline');
%                 pwv_spline = pwv;
%                 pwv_spline(i_beg:i_end) = tt.Var1;

                % NaN mask for more than 1 month NaN parts
                % Serves to omit years where more than one consecutive
                % month of data is missing. This is important because if
                % not ommited these periods can cause high peaks in trend
                % computation.
                n = length(pwv);
                mat = NaN(n,30);
                for i=1:15 
                    mat(1:n+1-i,16-i) = pwv(i:end);
                    mat(i:end,15+i) = pwv(1:n+1-i);
                end
                month_nan = ~all(isnan(mat),2);
                month_nan_2 = month_nan;
                for i=1:197 % 365 + 30 days
                    month_nan_2(1:n+1-i) = month_nan_2(1:n+1-i).*month_nan(i:end);
                    month_nan_2(i:end) = month_nan_2(i:end).*month_nan(1:n+1-i);
                end
                mask = ones(size(pwv));
                mask(~month_nan_2) = NaN;
                mask(1:182) = NaN; % Ommit first and last part half years
                mask(end-182:end) = NaN;
                
                save(['synced_mat_data/DER_daily/SYNC_DER_' sta '_2007_2021.mat'],'t','pwv','mask');
            end
        end
        
        function computeERAMeteoPWVData(sta_list)
            % Computes PWC data from synced ZWD and Temp. and saves it in
            % DER (derived) folder of synced data.
            %PROC.computePWVData(PROC.comp_stations)
            switch nargin
                case 0
                    sta_list = PROC.stations;
            end
            for i=1:length(sta_list)
                sta = sta_list{i};
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\TRO_daily\SYNC_TRO_' sta '_2007_2021.mat']);
                load(['C:\Users\Usuario\Desktop\LEIRE\__PROCESADO_SERIES_TEMPORALES\CLASES_ANALISIS_TSER\synced_mat_data\ERA_daily\SYNC_ERA_' sta '_2007_2021.mat']);
                if isfile(['synced_mat_data/DER_daily/SYNC_DER_' sta '_2007_2021.mat'])
                    load(['synced_mat_data/DER_daily/SYNC_DER_' sta '_2007_2021.mat']);
                    pwv_met_era = PROC.PWV(zwd,temp-273.15)*1e3; %mm
                    save(['synced_mat_data/DER_daily/SYNC_DER_' sta '_2007_2021.mat'],'t','pwv','pwv_met_era');
                else
                    pwv_met_era = PROC.PWV(zwd,temp-273.15)*1e3; %mm
                    save(['synced_mat_data/DER_daily/SYNC_DER_' sta '_2007_2021.mat'],'t','pwv_met_era');
                end
            end
        end
        
        function pwv = PWV(zwd,t)
            % Function from goGPS code.
            degCtoK = 273.15;
            Tall = t;
            % weighted mean temperature of the atmosphere over Alaska (Bevis et al., 1994)
            Tm = (Tall + degCtoK)*0.72 + 70.2;
            % Askne and Nordius formula (from Bevis et al., 1994)
            Q = (4.61524e-3*((3.739e5./Tm) + 22.1));
            % precipitable Water Vapor
            pwv = zwd ./ Q;
        end
        
        function trend = fastTheilSen(t,var)
            t = datenum(t);
            pairs = [];
            mat = tril(var - var',-1); % matrix containing all diferences in its lower part
            t_mat = tril(t - t',-1);
            trend = median(mat(~(mat==0))./t_mat(~(mat==0)),'all','omitnan');
            trend = trend*365.25*10; % from mm/datenum to mm/decade
        end
        
        function [trend,uncert] = MIDASAnalysis(t,var)
            t = t(isfinite(var));
            var = var(isfinite(var));
            sta = 'PRUE';
            
            % Generate file
            tenv_date = string(upper(datestr(t,'yymmmdd')));
            [~,mjd] = date2jd([year(t),month(t),day(t),hour(t),minute(t),second(t)]);
            [week,~,dow] = date2gps([year(t),month(t),day(t),hour(t),minute(t),second(t)]);
            last_rows = '  0.0000 0.000001 0.000001 0.000001  0.000000 0.000000 0.000000';
            fich = fopen(['MIDAS_files/MIDAS.tenv'],'w');
            fprintf(fich,'%s %s %s %s %s %s  %s %s\n',[string(repmat(sta,size(t,1),1)),tenv_date,string(reshape(sprintf('%0.4f',GF.decyr(tenv_date)),9,[])'),string(round(mjd)),string(week),string(dow),string(reshape(sprintf('%+7.5f %+7.5f %+7.5f',[var var var]'),29,[])'),string(repmat(last_rows,size(t,1),1))]');
            fclose(fich);
            
            % Execute analysis
            output_file = 'MIDAS_daily.VEL';
            cd 'MIDAS_files';
            system(['midas_leire.e > ' output_file],'-echo');
            cd '..';
            
            % Read result
            fich = fopen(['MIDAS_files/' output_file]);
            res = char(fscanf(fich,'%c'));
            fclose(fich);
            trend = str2num(res(58:66))*10; %decade
            uncert = str2num(res(98:105))*10; %decade
        end
        
        function [trend,uncert] = linearRegression(t,var)
            t_dec = datenum(t)/365.25/10; % t in decades
%           lin = [ones(size(t_dec(~isnan(trend_red)))),t_dec(~isnan(trend_red))]\trend_red(~isnan(trend_red));
%           lr_trend_red(j,1:2) = lin;
            [p,S] = polyfit(t_dec(isfinite(var)),var(isfinite(var)),1);
            [y,delta] = polyval(p,t_dec,S);
            trend = p(1);
            uncert = mean(y-delta); % delta is not necessarily equivalent to uncertainty
        end
        
        
    end
end

