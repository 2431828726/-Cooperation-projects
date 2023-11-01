%
%
% Main function for running the time series inversion related
%
% First working version by Shanshan Li 3/21/2016
%
% update 3/9/2018,
% update 4/24/2018

close all;
clear all;
clc;

% Options p to run which part below, p = 1 will run the comparison between
% observation and estimated time series points, p = 2 will show the
% synthetic time series
p =1;

if(p == 1)
    
    %% 3/21/2016 Main Function 1:  display the time series after TDEFNODE "SSSS_BSPN_ml.out"
    % file "SSSS_BSPN_ml.out" is removing the first header line from the file
    % "SSSS_BSPN.out"
    
   % sites = {'SELD','AC37','AC47','AC03','NINI','HOMA','AC06','AC35'};
   % sites = {'SELD','2201','AC47','AC03','NINI','HOMA','AC06','AC35'};
   %sites = {'SPCG','SPCR','TBON','TSEA'};
   
   %pdir = '../TDEFNODE_research/TDEFNODE_research3/bspn2_12_18_1/';
   
   %pdir = '../TDEFNODE_research/TDEFNODE_research7/bspn2_20_18_1/';
   
   
   %pdir = '../TDEFNODE_research/TDEFNODE_research3/bspn2_16_18_1/';
   
   % 3/9/2018
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research5/bspn3_7_18_3/';
   
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research11/bspn3_18_18_1/';
   
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research11/bspn3_19_18_1/';
   
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research5/bspn3_22_18_4/';
   
   % pdir = '../2017versionTDEFNODE_research/TDEFNODE_research6/bspn3_24_18_1/';
   
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research11/bspn3_30_18_1/';
   
  % pdir = '../2017versionTDEFNODE_research/TDEFNODE_research15/bspn3_30_18_5/';
   
   %pdir = '../2017versionTDEFNODE_research/TDEFNODE_research10/bspn4_24_18_1/';
   
   pdir = '../2017versionTDEFNODE_research/TDEFNODE_research10/bspn4_24_18_2/';
   
   % read site name from file 
   
   % go to the folder, in the terminal, run "awk '{print $1}' bspn_ts_data.out > bspn.sites"
   %system('awk "{print $1}" bspn_ts_data.out > bspn.sites');
   sitesfile = [pdir 'bspn.sites'];
   
   scanstring   = '%s';
   
   gpsfid = fopen(sitesfile);
   if ( gpsfid == -1 )
       error( strcat('Could not read file ', sitesfile) );
   end
   
   %       read the data. Textscan will leave zeros in any fields that are
   %       blank, so we don't have to worry about whether the correlations are
   %       there or not.
   
   C = textscan(gpsfid, scanstring,'headerlines',1);
   fclose(gpsfid);
   
   sites = C{1};
  
   
    num = length(sites);
    
    for i = 1:num
        %site = 'SELD';
        %testfile = './bspn/ts/AC02_BSPN_ml.out';
        testfile = [pdir,'ts/',sites{i},'_BSPN.out']; % time series output (observed and calculated)
        
        %testfile = ['../CK_Daily/TDEFNODE_timeseries2/bspn4_18_16_1/ts/',sites{i},'_BSPN.out'];
        %testfile = '../TDEFNODE_timeSeries1/bspn/ts/SELD_BSPN_ml.out';
        
        
        scanstring   = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s';
        
        gpsfid = fopen(testfile);
        if ( gpsfid == -1 )
            error( strcat('Could not read file ', testfile) );
        end
        
        %       read the data. Textscan will leave zeros in any fields that are
        %       blank, so we don't have to worry about whether the correlations are
        %       there or not.
        
        C = textscan(gpsfid, scanstring, 'CommentStyle', '#','headerlines',1);
        fclose(gpsfid);
        
        time = C{1};
        obs_detrE = C{2};
        cal_detrE = C{3};
        obs_detrN = C{6};
        cal_detrN = C{7};
        obs_detrU = C{10};
        cal_detrU = C{11};
        
        obs_nondetrE = C{14};
        obs_nondetrN = C{15};
        obs_nondetrU = C{16};
        
        cal_nondetrE = C{17};
        cal_nondetrN = C{18};
        cal_nondetrU = C{19};
        
        seasonalE = C{20};
        seasonalN = C{21};
        seasonalU = C{22};
        
        site = C{23};
        GPSnet = C{24};
        
        
        % % Plot non-detrended time series
        % subplot(num,3,1);
        % plot(time,obs_nondetrE,'ko');
        % hold on;
        % plot(time,cal_nondetrE ,'ro');
        % title([site,'East NonDetrended']);
        % xlabel('Date');
        % ylabel('East(mm)');
        % grid on
        % legend('observation','calculated');
        %
        % subplot(num,3,2);
        % plot(time, obs_nondetrN,'ko');
        % hold on;
        % plot(time, cal_nondetrN,'ro');
        %
        % title([site,'North NonDetrended']);
        % xlabel('Date');
        % ylabel('North(mm)');
        % grid on
        % legend('observation','calculated');
        %
        % subplot(num,3,3)
        % plot(time, obs_nondetrU,'ko');
        % hold on;
        % plot(time, cal_nondetrU,'ro');
        %
        % title([site,'Up NonDetrended']);
        % xlabel('Date');
        % ylabel('Up(mm)');
        % grid on
        % legend('observation','calculated');
        
        % Plot detrended time series
        hfig = figure;
            subplot(3,1,1);
            plot(time,obs_detrE,'ko');
            %plot(time, obs_nondetrE,'ko');
            hold on;
            %plot(time, cal_nondetrE,'ro');
            %plot(time2, E_nondet,'bo');
            %plot(time2,E_det,'bo');
            plot(time,cal_detrE,'ro');
            title([sites{i},'East Detrended']);
            xlabel('Date');
            ylabel('East(mm)');
            grid on
            %plot(time,seasonalE,'b');
            % xlim([1992 2009]);
            legend('observation','calculated');
            set(gca,'FontSize',25);
        
       subplot(3,1,2);
       %figure;
        plot(time,obs_detrN,'ko');
        hold on;
        plot(time,cal_detrN,'ro');
        %plot(time2,N_det,'bo');
        % plot(time, obs_nondetrN,'ko');
        % hold on;
        % plot(time, cal_nondetrN,'ro');
        % plot(time2,N_nondet,'bo');
        
        %plot(time,seasonalN,'b');
        title([sites{i},'North Detrended']);
        xlabel('Date');
        ylabel('North(mm)');
        grid on
        %xlim([1992 2009]);
        legend('observation','calculated');
         set(gca,'FontSize',25);
        
        subplot(3,1,3)
        plot(time,obs_detrU,'ko');
        hold on;
        plot(time,cal_detrU,'ro');
        %plot(time2,U_det,'bo');
        % plot(time, obs_nondetrU,'ko');
        % hold on;
        % plot(time, cal_nondetrU,'ro');
        % plot(time2,U_nondet,'bo');
        
        %plot(time,seasonalU,'b');
        title([sites{i},'Up Detrended']);
        xlabel('Date');
        ylabel('Up(mm)');
        grid on
        % xlim([1992 2009]);
        legend('observation','calculated');
         set(gca,'FontSize',25);
        
%         set(gca,'FontSize',20);
        
        x_width=15 ;
        y_width=20;
        set(hfig, 'PaperPosition', [0 0 x_width y_width]);
        saveas(hfig,[pdir, num2str(sites{i}),'_Detrended.jpg']);
        
        close(hfig);
    end
    %title([site{i},'North Detrended']);
%     xlabel('Date');
%     ylabel('North(mm)');
%     grid on
%     legend('observation','calculated');
end

if(p == 2)
    %% 3/22/2016 Main Function 2: Try to plot synthetic time series
    %
    % file "SSSS_BSPN_ml.out" is removing the first header line from the file
    % "SSSS_BSPN.out"
    
   % sites = {'SELD','AC37','AC47','AC03','NINI','HOMA','AC06','AC35'};
    sites = {'SELD'};
    num = length(sites);
    
    %testfile = './bspn/ts/AC02_BSPN_ml.out';
    %testfile = './bspn/ts/SELD_BSPN.syn';
    
    figure;
    for i = 1:num
    testfile = ['./bspn4_18_16_1/ts/',sites{i},'_BSPN.syn'];
    
    scanstring   = '%f %f %f %f %f %f %f %f %f %f %s %s';
    
    gpsfid = fopen(testfile);
    if ( gpsfid == -1 )
        error( strcat('Could not read file ', testfile) );
    end
    
    %       read the data. Textscan will leave zeros in any fields that are
    %       blank, so we don't have to worry about whether the correlations are
    %       there or not.
    
    C = textscan(gpsfid, scanstring, 'CommentStyle', '#');
    fclose(gpsfid);
    
    time = C{1};
    E_det = C{2};
    N_det = C{3};
    U_det = C{4};
    E_nondet = C{5};
    N_nondet = C{6};
    U_nondet = C{7};
    
    E_seas = C{8};
    N_seas = C{9};
    U_seas = C{10};
    
    site = C{11};
    GPSnet = C{12};
    
    %figure;
%     plot(time,E_det,'k');
%     hold on;
%    % plot(time,E_nondet,'r');
%     title([site{i},'East']);
%     xlabel('Date');
%     ylabel('East(mm)');
%     grid on
%     %plot(time,seasonalE,'b');
%     
%     figure;
    plot(time,N_det,'k');
    hold on;
    %plot(time,N_nondet,'r');
    %plot(time,seasonalN,'b');
    title([site{i},'North']);
    xlabel('Date');
    ylabel('North(mm)');
    grid on
%     
%     figure;
%     plot(time,U_det,'k');
%     hold on;
%     %plot(time,U_nondet,'r');
%     %plot(time,seasonalU,'b');
%     title([site{i},'Up']);
%     xlabel('Date');
%     ylabel('Up(mm)');
%     grid on
    end   
end