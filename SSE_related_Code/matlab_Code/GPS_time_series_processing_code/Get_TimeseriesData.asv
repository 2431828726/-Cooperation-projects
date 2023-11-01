clear all;
close all;
clc;

% update 2/11/2018, Shanshan Li

%section = 1; % generate specific file for TDEFNODE program by using stations we used in the velocity paper Li et al. 2016

% section = 2; % generate input data file for TDEFNODE program by using stations we used in the velocity paper which has already remove 1964 postseismic effect

%section = 3; % generate time series data file for NIF program, used in
%"data_reader.m" in directory "NIF", we decide to modify it directly in
%"data_reader.m" file in NIF program.

%section = 4; % based on section = 2, we need to remove the seasonal signal

% 12/25/2018 Christmas day make sure time series data is relative to NOAM,
% 3/22/2019

section = 5; % get hint from velocity script, based on section = 4

% 5/24/2018 and real do at 
%section  = 6; % based on section  = 5, we need to remove the 2002 Denali coseismic signal based on Hugh's codes

%section  = 7; % based on section = 6, we need to remove the 2002 Denali postseismic signal based on Jeff and Yan's latest postseismic model



if(section == 5) % get time series data for relative to NOAM 
    % 3/22/2019 for time series inversion
    
        %% Codes for generate specific file for TDEFNODE program running time series inversion, which is original time series, remove postseismic effect in this section
    
    % step 1: we need to generate file include postseismic velocity for each
    % component for each station we need to use (original source should be in /home/shanshan/2016_2017/TimeSeriesInversionCookInlet/CK_Daily/Time_Series_File/4_20_16/Main_function_time_series.m)
    
    % The sites we need to use and from the first paper, Format: name, lon, lat
    CampaignSites  = 'campaign_paper.txt';
    ContinuousSites = 'continuous_paper.txt';
    
    % Sites being affected by the 1964 earthquake deformation, Format: name,
    % lon, lat, vele, veln,velu, we need to get a new file based on all grd
    % files and use the command: awk '{print $2,$3}'
    % sites_all_name_lat_lon_only.vec | grdtrack -GSuito_east_15m.grd |
    % grdtrack -GSuito_north_15m.grd | grdtrack -GSuito_vert_15m.grd | sed
    % 's/\t/ /g' > sites_all_lat_lon_up.vec
    % paste sites_all_name_lat_lon_only.vec sites_all_lat_lon_up.vec | awk
    % '{print $1,$2,$3,$8,$9,$10}' > sites_all_name_lat_lon_Up.vec
    postseis = 'sites_all_name_lat_lon_Up.vec';
    
    % Output the file including all the original sites, and extra three columns
    % "vele,veln,velu",for sites affected, they are non-zero; for sites
    % non-affected, they are all zero.
    %Format: name, lon, lat, vele, veln,velu
    Camp_postOrg = 'campaign_paper_post_org.txt';
    Cont_postOrg = 'continuous_paper_post_org.txt';
    
    
    % Through the function "Get_postseis.m" we can get the files
    % "Camp_postaffect" and "Cont_postaffect";
    % [nameCamp,lonCamp,latCamp] = Get_postseis(CampaignSites,postseis,Camp_postaffect);
    % [nameCont,lonCont,latCont] = Get_postseis(ContinuousSites,postseis,Cont_postaffect);
    
    [nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
    [nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
    
    % step 2: we need to generate a new time series data input file with
    % postseismic effect removed.
    
    %pdir = '../../Shumagin/Alaska3.0_timeseries/'; % modfied 3/22/2019
    
    pdir = 'E:/研究生阶段文件/series time code/Alaska4.0_timeseries-manualAdd'; 
    
    %sdir   = '/usr/local/matlab/GRACE+Loading/seasonal/'; % modified because I download from UAF server to my own computer
    
    sdir   = '../GRACE+loading/seasonal/';
    
    stype = 'as';
    
    %read the all station file
    stationfile = 'allsites_alaska_ssl_v1.0.vec';
    %test if station file exists
    fid=fopen(stationfile);
    
   if(fid>0)
    fclose(fid);
    disp(strcat(stationfile, ' being read in'))
else
    error(strcat('无法打开文件: ', stationfile)); % 如果无法打开文件，抛出一个错误
end

  

    [lon,lat,Ve, Vn, Se, Sn, Rho, Site]...
        =textread(stationfile, '%f %f %f %f %f %f %f %s');
    
    numallsites = length(lon(:));
    
    % create the final output file for TDEFNODE3d
    timeseriesfile = 'TSgpsall_seasonal_postremoved_NOAM.ts';
    write_sample = (~isempty(timeseriesfile));
    if(write_sample)
        fid = fopen(timeseriesfile,'w');
        
        
        % read campagin sites
        campsitefile = 'campaign_paper.txt';
        [campsitename,loncamp,latcamp] = textread(campsitefile,'%s %f %f');
        
        numcamp = length(loncamp(:));
        
        for i = 1:numcamp % loop through the campaign sites that we want
            
            % generate the header line
            
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(campsitename{i});
                
                
                if(isequal(campsitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries" and remove the postseismic
            % effect for each epoch
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
            
            numpostcamp = length(lonCamp);
            
            for q = 1:numpostcamp
                if(isequal(nameCamp{q},campsitename{i})==1)
                    postve = veleCamp(q);
                    postvn = velnCamp(q);
                    postvu = veluCamp(q);
                end
            end
            
            staname = campsitename{i};
            datafile = [ pdir '/' staname '.pfiles' ];

            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat1] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat1.east);
            %datyear = zeros(numpos,1);
            
            dat2 = dat1;
            dat2_NOAM = dat2;
            for p = 1:numpos % loop for all the points for each station
                
                % store the data structure to new variable dat2
               
                
                % remove the postseismic signal
                dat2.time(p) = dat1.time(p);
                
                dat2.east(p) = dat1.east(p)*1000 - postve*(dat1.time(p)- dat1.time(1)); % mm
                dat2.east(p) = dat2.east(p)/1000; % meter
                dat2.esig(p) = dat1.esig(p); % meter
                
                dat2.north(p) = dat1.north(p)*1000-postvn*(dat1.time(p)-dat1.time(1)); % mm
                dat2.north(p) = dat2.north(p)/1000; % meter
                dat2.nsig(p) = dat1.nsig(p); %meter
                
                dat2.height(p) = dat1.height(p)*1000 - postvu*(dat1.time(p) - dat1.time(1)); % mm
                dat2.height(p) = dat2.height(p)/1000; % meter
                dat2.hsig( p )= dat1.hsig(p); % meter
                
                
                % convert data points from 
                % convert time series data to NOAM relative position
                % we will save them to a new data structure dat4
                
                %the most important problem is that how to only input positions
                %of sites for our stations
                % clue: function "read_timeseries.m" is very useful to
                % understand how to get refxyz for specific site relative to a
                % reference point
                
                %
                
                [vrel_plate,~, vRPcov] = calc_geodvel('NOAM',dat2.refxyz);
                
                % the units for dat2. east, north, height are now meter. 
                
                % vrel_plate is meters/year.
                
                dat2_NOAM.east(p) = dat2.east(p) - vrel_plate(1)*(dat1.time(p)- dat1.time(1)); % meter

                dat2_NOAM.esig(p) = sqrt( dat2.esig(p)^2 + vRPcov(1,1)* ( (dat1.time(p)- dat1.time(1)) ^2 )  ); % meter, due to error propagation law
                
                dat2_NOAM.north(p) = dat2.north(p)-vrel_plate(2) * (dat1.time(p)- dat1.time(1)); % meter
                
                 dat2_NOAM.nsig(p) = sqrt( dat2.nsig(p)^2 + vRPcov(2,2)* ( (dat1.time(p)- dat1.time(1)) ^2 )  ); % meter, due to error propagation law
               
                 dat2_NOAM.height(p) = dat2.height(p)-vrel_plate(3) * (dat1.time(p)- dat1.time(1)); % meter
                
                 dat2_NOAM.hsig(p) = sqrt( dat2.hsig(p)^2 + vRPcov(3,3)* ( (dat1.time(p)- dat1.time(1)) ^2 )  ); % meter, due to error propagation law
                
                % function calc_geodvel is use x, y, z position of each site as
                % input,
                
                
                %                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat1.time(p),dat1.east(p)*1000 - postve*(dat1.time(p)-dat1.time(1)),...
                %                     dat1.esig(p)*1000,dat1.north(p)*1000- postvn*(dat1.time(p)-dat1.time(1)),dat1.nsig(p)*1000,...
                %                     dat1.height(p)*1000 - postvu*(dat1.time(p)-dat1.time(1)),dat1.hsig(p)*1000);
                %                 % format is mm now.
            end % search through stations
            
            % remove the seasonal signal
            %   Read and subtract the seasonal model in the .season file if it exists.
            %   We do this at this step because the covariance needs to be the same
            %   as for the regular model.
            
            
            if ( exist( [ sdir staname '_' stype '.seasonal' ]) > 0 )
                
                disp('Removing seasonal from observed time series');
                seasonal = read_seasonal_file( [ sdir staname '_' stype '.seasonal' ] );
                seasonal_modval = ts_eval_seasonal(dat2_NOAM.time, seasonal);
                
                % subtract seasonal modval from data
                dat2_season_removed = dat2_NOAM;
                dat2_season_removed.east   = dat2_NOAM.east   - seasonal_modval(:,1);
                dat2_season_removed.north  = dat2_NOAM.north  - seasonal_modval(:,2);
                dat2_season_removed.height = dat2_NOAM.height - seasonal_modval(:,3);
                dat2_season_removed.enu    = dat2_NOAM.enu    - seasonal_modval';
            else
                dat2_season_removed = [];
            end
            
            dat3 = dat2_season_removed; % now still meters
            
            % at this stage, dat3 is the time series data after removing
            % 1964 postseismic deformation, 

            % final lines for time series data in the input file
            numpos2 = length(dat3.east);
            
            for q = 1:numpos2
                
                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat3.time(q),dat3.east(q)*1000 ,...
                                    dat3.esig(q)*1000,dat3.north(q)*1000, dat3.nsig(q)*1000,...
                                    dat3.height(q)*1000, dat3.hsig(q)*1000);
                                % format is mm now.
                
            end
            
            endsign = 9999.0;
            
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcamp % end of dealing with campaign sites
        
        
        % read continuous sites
        consitefile = 'continuous_paper.txt';
        [consitename,loncon,latcon] = textread(consitefile,'%s %f %f');
        
        numcon = length(loncon(:));
        
        for i = 1:numcon % loop through the campaign sites that we want
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(consitename{i});
                
                
                if(isequal(consitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries"
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
            
            numpostcon = length(lonCont);
            
            for q = 1:numpostcon
                if(isequal(nameCont(q),consitename{i})==1)
                    postve = veleCont(q);
                    postvn = velnCont(q);
                    postvu = veluCont(q);
                end
            end
            
            
            staname = consitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat2] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat2.east);
            
            % store the data structure to new variable dat2
            dat4 = dat2;
            
            dat4_NOAM= dat2;
            
            for p = 1:numpos

                % remove the postseismic signal
                dat4.time(p) = dat2.time(p);
                dat4.east(p) = dat2.east(p)*1000 - postve*(dat2.time(p)- dat2.time(1)); % mm
                dat4.east(p) = dat4.east(p)/1000; % meter
                dat4.esig(p) = dat4.esig(p); % meter
                dat4.north(p) = dat2.north(p)*1000-postvn*(dat2.time(p)-dat2.time(1)); % mm
                dat4.north(p) = dat4.north(p)/1000; % meter
                dat4.nsig(p) = dat4.nsig(p); %meter
                dat4.height(p) = dat2.height(p)*1000 - postvu*(dat2.time(p) - dat2.time(1)); % mm
                dat4.height(p) = dat4.height(p)/1000; % meter
                dat4.hsig( p )= dat4.hsig(p); % meter
                
                
                %  convert time series data from ITRF to NOAM
                 % convert data points from ITRF to NOAM
                % convert time series data to NOAM relative position
                % we will save them to a new data structure dat4
                
                %the most important problem is that how to only input positions
                %of sites for our stations
                % clue: function "read_timeseries.m" is very useful to
                % understand how to get refxyz for specific site relative to a
                % reference point
                
                %
                
                [vrel_plate,~, vRPcov] = calc_geodvel('NOAM',dat4.refxyz);
                
                % the units for dat2. east, north, height are now meter. 
                
                % vrel_plate is meters/year.
                
                dat4_NOAM.east(p) = dat4.east(p) - vrel_plate(1)*(dat2.time(p)- dat2.time(1)); % meter

                dat4_NOAM.esig(p) = sqrt( dat4.esig(p)^2 + vRPcov(1,1)* ( (dat2.time(p)- dat2.time(1)) ^2 )  ); % meter, due to error propagation law
                
                dat4_NOAM.north(p) = dat4.north(p)-vrel_plate(2) * (dat2.time(p)- dat2.time(1)); % meter
                
                 dat4_NOAM.nsig(p) = sqrt( dat4.nsig(p)^2 + vRPcov(2,2)* ( (dat2.time(p)- dat2.time(1)) ^2 )  ); % meter, due to error propagation law
               
                 dat4_NOAM.height(p) = dat4.height(p)-vrel_plate(3) * (dat2.time(p)- dat2.time(1)); % meter
                
                 dat4_NOAM.hsig(p) = sqrt( dat4.hsig(p)^2 + vRPcov(3,3)* ( (dat2.time(p)- dat2.time(1)) ^2 )  ); % meter, due to error propagation law
                               
                

            end % search through stations
            
            
            
            % remove the seasonal signal
            %   Read and subtract the seasonal model in the .season file if it exists.
            %   We do this at this step because the covariance needs to be the same
            %   as for the regular model.
            
            if ( exist( [ sdir staname '_' stype '.seasonal' ]) > 0 )
                
                disp('Removing seasonal from observed time series');
                seasonal = read_seasonal_file( [ sdir staname '_' stype '.seasonal' ] );
                seasonal_modval = ts_eval_seasonal(dat4_NOAM.time, seasonal);
                
                % subtract seasonal modval from data
                dat4_season_removed = dat4_NOAM;
                dat4_season_removed.east   = dat4_NOAM.east   - seasonal_modval(:,1);
                dat4_season_removed.north  = dat4_NOAM.north  - seasonal_modval(:,2);
                dat4_season_removed.height = dat4_NOAM.height - seasonal_modval(:,3);
                dat4_season_removed.enu    = dat4_NOAM.enu    - seasonal_modval';
            else
                dat4_season_removed = [];
            end
            
            dat5 = dat4_season_removed; % now still meters
            
            numpos2 = length(dat5.east);
            
            for q = 1:numpos2
                
                % contents included in the timeseries file (tdfn input)
                
                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat5.time(q),dat5.east(q)*1000 ,...
                                    dat5.esig(q)*1000,dat5.north(q)*1000, dat5.nsig(q)*1000,...
                                    dat5.height(q)*1000, dat5.hsig(q)*1000);
                                % format is mm now.
                
            end
            
            
%             for p = 1:numpos
%                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat2.time(p),dat2.east(p)*1000-postve*(dat2.time(p)-dat2.time(1)),...
%                     dat2.esig(p)*1000,dat2.north(p)*1000- postvn*(dat2.time(p)-dat2.time(1)),dat2.nsig(p)*1000,...
%                     dat2.height(p)*1000 - postvu*(dat2.time(p)-dat2.time(1)),dat2.hsig(p)*1000);
%                 % format is mm now.
%             end
            
            endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcon
        
        
    end % end of writing into output file
    
    
    
    
  % end of section 5 
%%
elseif(section == 1)
    
    %% Codes for generate specific file for TDEFNODE program running time series inversion, which is original time series, not remove postseismic effect yet.
    
    pdir = '../../Shumagin/Alaska3.0_timeseries/';
    
    %read the all station file
    stationfile = 'allsites_alaska_ssl_v1.0.vec';
    %test if station file exists
    fid=fopen(stationfile);
    
    if(fid>0)
        fclose(fid);
        disp(strcat(stationfile, ' being read in'))
    end
    
    [lon,lat,Ve, Vn, Se, Sn, Rho, Site]...
        =textread(stationfile, '%f %f %f %f %f %f %f %s');
    
    numallsites = length(lon(:));
    
    % create the final output file for TDEFNODE3d
    timeseriesfile = '../TimeSeriesFile/TSgpsall.ts';
    write_sample = (~isempty(timeseriesfile));
    if(write_sample)
        fid = fopen(timeseriesfile,'w');
        
        
        % read campagin sites
        campsitefile = 'campaign_paper.txt';
        [campsitename,loncamp,latcamp] = textread(campsitefile,'%s %f %f');
        
        numcamp = length(loncamp(:));
        
        for i = 1:numcamp % loop through the campaign sites that we want
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(campsitename{i});
                
                
                if(isequal(campsitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries"
            
            staname = campsitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat1] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat1.east);
            for p = 1:numpos
                fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat1.time(p),dat1.east(p)*1000,dat1.esig(p)*1000,dat1.north(p)*1000,dat1.nsig(p)*1000,dat1.height(p)*1000,dat1.hsig(p)*1000);
                % format is mm now.
            end
            endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcamp
        
        
        % read continuous sites
        consitefile = 'continuous_paper.txt';
        [consitename,loncon,latcon] = textread(consitefile,'%s %f %f');
        
        numcon = length(loncon(:));
        
        for i = 1:numcon % loop through the campaign sites that we want
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(consitename{i});
                
                
                if(isequal(consitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
%             endsign = 9999.0;
%             fprintf(fid,'%4.1f\n',endsign);
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries"
            
            staname = consitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat2] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat2.east);
            for p = 1:numpos
                fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat2.time(p),dat2.east(p)*1000,dat2.esig(p)*1000,dat2.north(p)*1000,dat2.nsig(p)*1000,dat2.height(p)*1000,dat2.hsig(p)*1000);
                % format is mm now.
            end
            
                        endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcon
        
        
    end % end of writing into output file
    
    
elseif(section == 2)
    
    %% Codes for generate specific file for TDEFNODE program running time series inversion, which is original time series, remove postseismic effect in this section
    
    % step 1: we need to generate file include postseismic velocity for each
    % component for each station we need to use (original source should be in /home/shanshan/2016_2017/TimeSeriesInversionCookInlet/CK_Daily/Time_Series_File/4_20_16/Main_function_time_series.m)
    
    % The sites we need to use and from the first paper, Format: name, lon, lat
    CampaignSites  = 'campaign_paper.txt';
    ContinuousSites = 'continuous_paper.txt';
    
    % Sites being affected by the 1964 earthquake deformation, Format: name,
    % lon, lat, vele, veln,velu, we need to get a new file based on all grd
    % files and use the command: awk '{print $2,$3}'
    % sites_all_name_lat_lon_only.vec | grdtrack -GSuito_east_15m.grd |
    % grdtrack -GSuito_north_15m.grd | grdtrack -GSuito_vert_15m.grd | sed
    % 's/\t/ /g' > sites_all_lat_lon_up.vec
    % paste sites_all_name_lat_lon_only.vec sites_all_lat_lon_up.vec | awk
    % '{print $1,$2,$3,$8,$9,$10}' > sites_all_name_lat_lon_Up.vec
    postseis = 'sites_all_name_lat_lon_Up.vec';
    
    % Output the file including all the original sites, and extra three columns
    % "vele,veln,velu",for sites affected, they are non-zero; for sites
    % non-affected, they are all zero.
    %Format: name, lon, lat, vele, veln,velu
    Camp_postOrg = 'campaign_paper_post_org.txt';
    Cont_postOrg = 'continuous_paper_post_org.txt';
    
    
    % Through the function "Get_postseis.m" we can get the files
    % "Camp_postaffect" and "Cont_postaffect";
    % [nameCamp,lonCamp,latCamp] = Get_postseis(CampaignSites,postseis,Camp_postaffect);
    % [nameCont,lonCont,latCont] = Get_postseis(ContinuousSites,postseis,Cont_postaffect);
    
    [nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
    [nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
    
    % step 2: we need to generate a new time series data input file with
    % postseismic effect removed. 
    
    pdir = '../../Shumagin/Alaska3.0_timeseries/';
    
    %read the all station file
    stationfile = 'allsites_alaska_ssl_v1.0.vec';
    %test if station file exists
    fid=fopen(stationfile);
    
    if(fid>0)
        fclose(fid);
        disp(strcat(stationfile, ' being read in'))
    end
    
    [lon,lat,Ve, Vn, Se, Sn, Rho, Site]...
        =textread(stationfile, '%f %f %f %f %f %f %f %s');
    
    numallsites = length(lon(:));
    
    % create the final output file for TDEFNODE3d
    timeseriesfile = '../TimeSeriesFile/TSgpsall_postremoved.ts';
    write_sample = (~isempty(timeseriesfile));
    if(write_sample)
        fid = fopen(timeseriesfile,'w');
        
        
        % read campagin sites
        campsitefile = 'campaign_paper.txt';
        [campsitename,loncamp,latcamp] = textread(campsitefile,'%s %f %f');
        
        numcamp = length(loncamp(:));
        
        for i = 1:numcamp % loop through the campaign sites that we want
            
            % generate the header line
            
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(campsitename{i});
                
                
                if(isequal(campsitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries" and remove the postseismic
            % effect for each epoch
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
            
            numpostcamp = length(lonCamp);
            
            for q = 1:numpostcamp
               if(isequal(nameCamp{q},campsitename{i})==1)
                   postve = veleCamp(q);
                   postvn = velnCamp(q);
                   postvu = veluCamp(q);
               end
            end
            
            staname = campsitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat1] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat1.east);
            for p = 1:numpos
                fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat1.time(p),dat1.east(p)*1000 - postve*(dat1.time(p)-dat1.time(1)),...
                    dat1.esig(p)*1000,dat1.north(p)*1000- postvn*(dat1.time(p)-dat1.time(1)),dat1.nsig(p)*1000,...
                    dat1.height(p)*1000 - postvu*(dat1.time(p)-dat1.time(1)),dat1.hsig(p)*1000);
                % format is mm now.
            end
            
            endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcamp
        
        
        % read continuous sites
        consitefile = 'continuous_paper.txt';
        [consitename,loncon,latcon] = textread(consitefile,'%s %f %f');
        
        numcon = length(loncon(:));
        
        for i = 1:numcon % loop through the campaign sites that we want
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(consitename{i});
                
                
                if(isequal(consitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries"
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
            
            numpostcon = length(lonCont);
            
            for q = 1:numpostcon
               if(isequal(nameCont(q),consitename{i})==1)
                   postve = veleCont(q);
                   postvn = velnCont(q);
                   postvu = veluCont(q);
               end
            end
            
            
            staname = consitename{i};
            datafile = [ pdir staname '.pfiles' ]; % relative to ITRF, ITRF relative to NOAM is Southward 
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat2] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat2.east);
            for p = 1:numpos
                fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat2.time(p),dat2.east(p)*1000-postve*(dat2.time(p)-dat2.time(1)),...
                    dat2.esig(p)*1000,dat2.north(p)*1000- postvn*(dat2.time(p)-dat2.time(1)),dat2.nsig(p)*1000,...
                    dat2.height(p)*1000 - postvu*(dat2.time(p)-dat2.time(1)),dat2.hsig(p)*1000);
                % format is mm now.
            end
            
            % remove the 
            endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcon
        
        
    end % end of writing into output file
    
    
elseif(section == 4) % remove the seasonal signal also based on section  = 2
    
    %% Codes for generate specific file for TDEFNODE program running time series inversion, which is original time series, remove postseismic effect in this section
    
    % step 1: we need to generate file include postseismic velocity for each
    % component for each station we need to use (original source should be in /home/shanshan/2016_2017/TimeSeriesInversionCookInlet/CK_Daily/Time_Series_File/4_20_16/Main_function_time_series.m)
    
    % The sites we need to use and from the first paper, Format: name, lon, lat
    CampaignSites  = 'campaign_paper.txt';
    ContinuousSites = 'continuous_paper.txt';
    
    % Sites being affected by the 1964 earthquake deformation, Format: name,
    % lon, lat, vele, veln,velu, we need to get a new file based on all grd
    % files and use the command: awk '{print $2,$3}'
    % sites_all_name_lat_lon_only.vec | grdtrack -GSuito_east_15m.grd |
    % grdtrack -GSuito_north_15m.grd | grdtrack -GSuito_vert_15m.grd | sed
    % 's/\t/ /g' > sites_all_lat_lon_up.vec
    % paste sites_all_name_lat_lon_only.vec sites_all_lat_lon_up.vec | awk
    % '{print $1,$2,$3,$8,$9,$10}' > sites_all_name_lat_lon_Up.vec
    postseis = 'sites_all_name_lat_lon_Up.vec';
    
    % Output the file including all the original sites, and extra three columns
    % "vele,veln,velu",for sites affected, they are non-zero; for sites
    % non-affected, they are all zero.
    %Format: name, lon, lat, vele, veln,velu
    Camp_postOrg = 'campaign_paper_post_org.txt';
    Cont_postOrg = 'continuous_paper_post_org.txt';
    
    
    % Through the function "Get_postseis.m" we can get the files
    % "Camp_postaffect" and "Cont_postaffect";
    % [nameCamp,lonCamp,latCamp] = Get_postseis(CampaignSites,postseis,Camp_postaffect);
    % [nameCont,lonCont,latCont] = Get_postseis(ContinuousSites,postseis,Cont_postaffect);
    
    [nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
    [nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
    
    % step 2: we need to generate a new time series data input file with
    % postseismic effect removed.
    
    pdir = '../../Shumagin/Alaska3.0_timeseries/';
    
    sdir   = '/usr/local/matlab/GRACE+Loading/seasonal/';
    
    stype = 'as';
    
    %read the all station file
    stationfile = 'allsites_alaska_ssl_v1.0.vec';
    %test if station file exists
    fid=fopen(stationfile);
    
    if(fid>0)
        fclose(fid);
        disp(strcat(stationfile, ' being read in'))
    end
    
    [lon,lat,Ve, Vn, Se, Sn, Rho, Site]...
        =textread(stationfile, '%f %f %f %f %f %f %f %s');
    
    numallsites = length(lon(:));
    
    % create the final output file for TDEFNODE3d
    timeseriesfile = '../TimeSeriesFile/TSgpsall_seasonal_postremoved.ts';
    write_sample = (~isempty(timeseriesfile));
    if(write_sample)
        fid = fopen(timeseriesfile,'w');
        
        
        % read campagin sites
        campsitefile = 'campaign_paper.txt';
        [campsitename,loncamp,latcamp] = textread(campsitefile,'%s %f %f');
        
        numcamp = length(loncamp(:));
        
        for i = 1:numcamp % loop through the campaign sites that we want
            
            % generate the header line
            
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(campsitename{i});
                
                
                if(isequal(campsitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries" and remove the postseismic
            % effect for each epoch
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCamp,lonCamp,latCamp,veleCamp,velnCamp,veluCamp] = Get_postseis(CampaignSites,postseis,Camp_postOrg);
            
            numpostcamp = length(lonCamp);
            
            for q = 1:numpostcamp
                if(isequal(nameCamp{q},campsitename{i})==1)
                    postve = veleCamp(q);
                    postvn = velnCamp(q);
                    postvu = veluCamp(q);
                end
            end
            
            staname = campsitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat1] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat1.east);
            %datyear = zeros(numpos,1);
            
            dat2 = dat1;
            for p = 1:numpos
                
                % store the data structure to new variable dat2
               
                
                % remove the postseismic signal
                dat2.time(p) = dat1.time(p);
                dat2.east(p) = dat1.east(p)*1000 - postve*(dat1.time(p)- dat1.time(1)); % mm
                dat2.east(p) = dat2.east(p)/1000; % meter
                dat2.esig(p) = dat1.esig(p); % meter
                dat2.north(p) = dat1.north(p)*1000-postvn*(dat1.time(p)-dat1.time(1)); % mm
                dat2.north(p) = dat2.north(p)/1000; % meter
                dat2.nsig(p) = dat1.nsig(p); %meter
                dat2.height(p) = dat1.height(p)*1000 - postvu*(dat1.time(p) - dat1.time(1)); % mm
                dat2.height(p) = dat2.height(p)/1000; % meter
                dat2.hsig( p )= dat1.hsig(p); % meter
                
                
                %                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat1.time(p),dat1.east(p)*1000 - postve*(dat1.time(p)-dat1.time(1)),...
                %                     dat1.esig(p)*1000,dat1.north(p)*1000- postvn*(dat1.time(p)-dat1.time(1)),dat1.nsig(p)*1000,...
                %                     dat1.height(p)*1000 - postvu*(dat1.time(p)-dat1.time(1)),dat1.hsig(p)*1000);
                %                 % format is mm now.
            end % search through stations
            
            % remove the seasonal signal
            %   Read and subtract the seasonal model in the .season file if it exists.
            %   We do this at this step because the covariance needs to be the same
            %   as for the regular model.
            
            if ( exist( [ sdir staname '_' stype '.seasonal' ]) > 0 )
                
                disp('Removing seasonal from observed time series');
                seasonal = read_seasonal_file( [ sdir staname '_' stype '.seasonal' ] );
                seasonal_modval = ts_eval_seasonal(dat2.time, seasonal);
                
                % subtract seasonal modval from data
                dat2_season_removed = dat2;
                dat2_season_removed.east   = dat2.east   - seasonal_modval(:,1);
                dat2_season_removed.north  = dat2.north  - seasonal_modval(:,2);
                dat2_season_removed.height = dat2.height - seasonal_modval(:,3);
                dat2_season_removed.enu    = dat2.enu    - seasonal_modval';
            else
                dat2_season_removed = [];
            end
            
            dat3 = dat2_season_removed; % now still meters
            
            numpos2 = length(dat3.east);
            
            for q = 1:numpos2
                
                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat3.time(q),dat3.east(q)*1000 ,...
                                    dat3.esig(q)*1000,dat3.north(q)*1000, dat3.nsig(q)*1000,...
                                    dat3.height(q)*1000, dat3.hsig(q)*1000);
                                % format is mm now.
                
            end
            
            endsign = 9999.0;
            
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcamp % end of dealing with campaign sites
        
        
        % read continuous sites
        consitefile = 'continuous_paper.txt';
        [consitename,loncon,latcon] = textread(consitefile,'%s %f %f');
        
        numcon = length(loncon(:));
        
        for i = 1:numcon % loop through the campaign sites that we want
            count = 0;
            for j = 1:numallsites %% loop through the allsites.vec to get that line of previously estimated velocity for specific station.
                
                charstationname = length(consitename{i});
                
                
                if(isequal(consitename{i},Site{j})==1)
                    count = count + 1;
                    if(count == 1)
                        disp(Site{j});
                        
                        if(charstationname == 3)
                            newsite = strcat('_',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        elseif(charstationname == 2)
                            newsite = strcat('__',Site{j});
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),newsite );
                            
                        else
                            fprintf(fid,'%3.2f %3.2f %3.3f %3.3f %3.3f %3.3f %3.3f %s\n',lon(j),lat(j), Ve(j), Vn(j), Se(j), Sn(j),Rho(j),Site{j} );
                            
                        end
                        
                    end
                end
                
            end % for j = 1:numallsites
            
            % get the time series data for each station from ".pfiles" in
            % folder "Alaska3.0_timeseries"
            
            % each epoch (measurement) is in the form: Yr Pe Se Pn Sn Pu
            % Su, Pe Pn Pu are east, north, up positions in mm, usually
            % relative to the first measurement. So for the first
            % measurement, the Pe Pn Pu are still zero since this one is
            % the reference measurement, then for the later measurements,
            % we need to remove the postseismic effect starting from the
            % time which we have the first measurement, not 1964, so we
            % need to subtract (currentdate-date1)*postvelocity
            
            % get the postve, postvn, postvu for current staname
            %[nameCont,lonCont,latCont,veleCont,velnCont,veluCont] = Get_postseis(ContinuousSites,postseis,Cont_postOrg);
            
            numpostcon = length(lonCont);
            
            for q = 1:numpostcon
                if(isequal(nameCont(q),consitename{i})==1)
                    postve = veleCont(q);
                    postvn = velnCont(q);
                    postvu = veluCont(q);
                end
            end
            
            
            staname = consitename{i};
            datafile = [ pdir staname '.pfiles' ];
            % format in datafile is mm.
            sigtol = [12; 12; 25];
            [dat2] = read_timeseries(datafile, sigtol);
            % format for data in dat1 is meter, so we need to convert back to
            % mm
            numpos = length(dat2.east);
            
            % store the data structure to new variable dat2
            dat4 = dat2;
            
            for p = 1:numpos
                

                
                % remove the postseismic signal
                dat4.time(p) = dat2.time(p);
                dat4.east(p) = dat2.east(p)*1000 - postve*(dat2.time(p)- dat2.time(1)); % mm
                dat4.east(p) = dat4.east(p)/1000; % meter
                dat4.esig(p) = dat4.esig(p); % meter
                dat4.north(p) = dat2.north(p)*1000-postvn*(dat2.time(p)-dat2.time(1)); % mm
                dat4.north(p) = dat4.north(p)/1000; % meter
                dat4.nsig(p) = dat4.nsig(p); %meter
                dat4.height(p) = dat2.height(p)*1000 - postvu*(dat2.time(p) - dat2.time(1)); % mm
                dat4.height(p) = dat4.height(p)/1000; % meter
                dat4.hsig( p )= dat4.hsig(p); % meter
                

            end % search through stations
            
            % remove the seasonal signal
            %   Read and subtract the seasonal model in the .season file if it exists.
            %   We do this at this step because the covariance needs to be the same
            %   as for the regular model.
            
            if ( exist( [ sdir staname '_' stype '.seasonal' ]) > 0 )
                
                disp('Removing seasonal from observed time series');
                seasonal = read_seasonal_file( [ sdir staname '_' stype '.seasonal' ] );
                seasonal_modval = ts_eval_seasonal(dat2.time, seasonal);
                
                % subtract seasonal modval from data
                dat4_season_removed = dat4;
                dat4_season_removed.east   = dat4.east   - seasonal_modval(:,1);
                dat4_season_removed.north  = dat4.north  - seasonal_modval(:,2);
                dat4_season_removed.height = dat4.height - seasonal_modval(:,3);
                dat4_season_removed.enu    = dat4.enu    - seasonal_modval';
            else
                dat4_season_removed = [];
            end
            
            dat5 = dat4_season_removed; % now still meters
            
            numpos2 = length(dat5.east);
            
            for q = 1:numpos2
                
                % contents included in the timeseries file (tdfn input)
                
                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat5.time(q),dat5.east(q)*1000 ,...
                                    dat5.esig(q)*1000,dat5.north(q)*1000, dat5.nsig(q)*1000,...
                                    dat5.height(q)*1000, dat5.hsig(q)*1000);
                                % format is mm now.
                
            end
            
            
%             for p = 1:numpos
%                 fprintf(fid,'%4.4f %3.4f %3.4f %3.4f %3.4f %3.4f %3.4f\n',dat2.time(p),dat2.east(p)*1000-postve*(dat2.time(p)-dat2.time(1)),...
%                     dat2.esig(p)*1000,dat2.north(p)*1000- postvn*(dat2.time(p)-dat2.time(1)),dat2.nsig(p)*1000,...
%                     dat2.height(p)*1000 - postvu*(dat2.time(p)-dat2.time(1)),dat2.hsig(p)*1000);
%                 % format is mm now.
%             end
            
            endsign = 9999.0;
            fprintf(fid,'%4.1f\n',endsign);
            
        end % for i = 1:numcon
        
        
    end % end of writing into output file
    
    
    
    
  % end of section 4  
  
  

    
end