function [nofileo, no_velo, no_seasonal] = velocity_fit(fit_control)
%function no_velo = velocity_fit(fit_control)
%
% General velocity estimation function
%
% Computes and outputs multiple versions of the velocity field:
%   -- with and without seasonal corrections applied
%   -- in ITRF and in a plate-fixed frame
%
% It also computes displacements at specified times, and outputs these to a
% file.
%
% The fit_control structure is defined by the function default_fit_control():
%  fit_control.outprefix
%  fit_control.pdir
%  fit_control.sdir
%  fit_control.stype
%  fit_control.outdir
%  fit_contol.auto_outlier_rejection
%  fit_control.removedays
%  fit_control.plate
%  fit_control.t1_default
%  fit_control.t2_default
%  fit_control.min_Tspan
%  fit_control.sigtol
%  fit_control.batch
%  fit_control.sitefile
%  fit_control.station_specific_models
%  fit_control.noisemodel.varscale
%  fit_control.noisemodel.horz_addsig_time
%  fit_control.noisemodel.vert_addsig_time
%  fit_control.noisemodel.colored.time_unit
%  fit_control.noisemodel.colored.sig_white
%  fit_control.noisemodel.colored.sig_flicker
%  fit_control.noisemodel.colored.sig_rwalk


%
% slightly modify based on my previous velocity estimation function
% 2/9/2017
%

% Process directory names

pdir   = fit_control.pdir;
sdir   = fit_control.sdir;
if ( ~isempty(fit_control.stype) )
    stype  = fit_control.stype;
else
    stype = 'as';
end
outdir = fit_control.outdir;
plate  = fit_control.plate;

% Time window to use

t1_default = fit_control.t1_default;
t2_default = fit_control.t2_default;

if ( ~isempty(fit_control.min_Tspan) )
    min_Tspan = fit_control.min_Tspan;
else
    min_Tspan = 1.5;
end

colors = ['b' 'g' 'r' 'c' 'm' 'y'];
ncolors = length(colors);

if ( ~isempty(fit_control.remove_days) )
    remove_days = fit_control.remove_days;
else
    remove_days = [];
end


% Station-specific models

if ( ~isempty(fit_control.station_specific_models) )
    station_specific_models = fit_control.station_specific_models;
    num_specific_models = length(station_specific_models);
    for jmod = 1:num_specific_models
        disp(['Station-specific model # ' num2str(jmod) ' for stations: ']);
        disp(station_specific_models{jmod}.stations(:)');
    end
else
    station_specific_models = {};
    num_specific_models = 0;
end

% (Formal) sigma tolerance -- skip points with larger sigmas

if ( ~isempty(fit_control.sigtol) )
    sigtol = fit_control.sigtol;
else
    sigtol = [12; 12; 25];
end

% Variance scaling to apply a priori and additive sigma

if ( ~isempty(fit_control.noisemodel.varscale) )
    varscale = fit_control.noisemodel.varscale;
else
    varscale = 1.0;
end
sigscale = sqrt(varscale);

if ( ~isempty(fit_control.noisemodel.horz_addsig_time) )
    horz_addsig_num = fit_control.noisemodel.horz_addsig_time;
else
    horz_addsig_num = 0.001;
end
if ( ~isempty(fit_control.noisemodel.vert_addsig_time) )
    vert_addsig_num = fit_control.noisemodel.vert_addsig_time;
else
    vert_addsig_num = 0.003;
end

disp('Scaling final uncertainties so that reduced chi-square is 1.0');

% Batch number if sites are 

if ( ~isempty(fit_control.batch) )
    batch = fit_control.batch;
else
    batch = 1;
end

% Uncomment this for CONTINUOUS sites
file = fit_control.sitefile;


fid = fopen(file);
%
C         = textscan(fid, '%s %s %s %f %s', 'CommentStyle', '#');
sites     = C{1};
starttime = C{2};
endtime   = C{3};
seasflag  = C{4};
disps1    = C{5};
fclose(fid);

%      Replace 
disps = cell(size(disps1));
for i = 1:length(disps)
   s = char(disps1{i});
   idx = strfind(s, ',');
   if (length(idx) > 0 )
      s(idx) = ' ';
      disps1{i} = s;
   end
   disps{i} = sscanf(disps1{i}, '%f');
end

fpref = fit_control.outprefix;

outfid1  = fopen([outdir fpref '-ITRF_' num2str(batch) '.gmtvec'], 'w');
outfidv1 = fopen([outdir fpref '-ITRF-vert_' num2str(batch) '.gmtvec'], 'w');
outf3d1  = fopen([outdir fpref '-ITRF_' num2str(batch) '.gps3d'], 'w');
outfid2  = fopen([outdir fpref '-' plate '_' num2str(batch) '.gmtvec'], 'w');
outfidv2 = fopen([outdir fpref '-' plate '-vert_' num2str(batch) '.gmtvec'], 'w');
outf3d2  = fopen([outdir fpref '-' plate '_' num2str(batch) '.gps3d'], 'w');
sumfid   = fopen([outdir fpref '_summary_' num2str(batch)], 'w');
dispfid  = fopen([outdir fpref '_displacements_' num2str(batch) '.txt'], 'w');

outfid1s  = fopen([outdir fpref '-seasonal-ITRF_' num2str(batch) '.gmtvec'], 'w');
outfidvs1 = fopen([outdir fpref '-seasonal-ITRF-vert_' num2str(batch) '.gmtvec'], 'w');
outf3d1s  = fopen([outdir fpref '-seasonal-ITRF_' num2str(batch) '.gps3d'], 'w');
outfid2s  = fopen([outdir fpref '-seasonal-' plate '_' num2str(batch) '.gmtvec'], 'w');
outfidvs2 = fopen([outdir fpref '-seasonal-' plate '_-vert_' num2str(batch) '.gmtvec'], 'w');
outf3d2s  = fopen([outdir fpref '-seasonal-' plate '__' num2str(batch) '.gps3d'], 'w');
sumfids   = fopen([outdir fpref '_summary-seasonal_' num2str(batch)], 'w');
dispfids  = fopen([outdir fpref '_displacements-seasonal_' num2str(batch) '.txt'], 'w');


fprintf(dispfid, '##UNITS: cm\n');
fprintf(dispfids, '##UNITS: cm\n');


nsites = length(sites);
no_velo = { };
n_novelo = 0;
nofileo = { };
n_nofileo = 0;
%output the sites that does not have seasonal file
no_seasonal = { };
n_nosea = 0;

for i = 1:nsites,
    
    apriori = [];
    
    % Set the start and end times for this site. Default is the global
    % start and end time. 
    
    t1 = t1_default;
    t2 = t2_default;

    % Read the data file and rescale the uncertainties by a typical
    %   short-term scatter.
    
    staname = char(sites(i));
    datafile = [ pdir staname '.pfiles' ];
    [nofile,dat1] = read_timeseries(datafile, sigtol);
    if(nofile==1)
        n_nofileo = n_nofileo + 1;
        nofileo{n_nofileo}=char(sites(i));
        system(['cp /gps/data/Alaska3.0_timeseries/',staname,'.pfiles ',pdir]);
        datafile = [ pdir staname '.pfiles' ];
        [nofile,dat1] = read_timeseries(datafile, sigtol);
        nofileo{n_nofileo} = { };
    end
    
    
    % from here modified by shanshan
    % get the real start and end time for each site based on their time
    % series information
    realstart = min(dat1.time);
    realend = max(dat1.time);
    
    %if the real start and end time for this specific site is empty,just throw this site out.    
    if ( isempty(realstart) || isempty(realend))
        n_novelo = n_novelo+1;
        no_velo{n_novelo} = char(sites(i));
        continue;
    end
    
    
  % Check for particular starttime/endtime specifications, make sure the
    % data range in specific time period
    % if so, then use them
    
    if  (strcmp(starttime{i},'-') ~= 1)
        temptstart = date_conversion(starttime{i});
        if ((temptstart>realstart) && (temptstart < realend))
            
            realstart = temptstart;
        end
    end
    
    if strcmp(endtime{i},'-') ~= 1     % for the endtime t2, if endtime in txt is not '-' but real number
        temptend = date_conversion(endtime{i});
        if ((temptend>realstart) && (temptend < realend))
            
            realend = temptend;
        end
    end
   
   if (realstart > t2) % if the starttime in txt for this site is bigger than end time of timeperiod, just throw this site this time , actually this part works best for small time window
       n_novelo = n_novelo+1;
       no_velo{n_novelo} = char(sites(i));
       continue;
   elseif  ((realstart<t2) && (realstart>t1)) % if the real start time for this site is located within required time range [t1, t2], then use real start time as t1
       t1 = realstart;
   else
       t1 = t1_default; % if the real start time for this site is earlier than t1, then keep t1 as t1
   end
   
    if (realend < t1) % if the real end time for this specific site is earlier than the required start time of the time period, just throw this site
        n_novelo = n_novelo+1;
        no_velo{n_novelo} = char(sites(i));
        continue;
        
    elseif ((realend<t2) && (realend>t1)) % if the real end time is later than t1 but earlier than t2, use real end time as t2
        t2 = realend;
    else    % if the real end time is later than t2, then just keep t2 as t2.
        t2 = t2_default;
    end
    
    % modified from shanshan till here
    
    dat1.esig   = dat1.esig*sigscale;
    dat1.nsig   = dat1.nsig*sigscale;
    dat1.hsig   = dat1.hsig*sigscale;
    
    for j = 1:length(dat1.enucov)
       dat1.enucov{j} = dat1.enucov{j}*varscale;
    end
    
    % Remove any daily solutions defined by 'remove_days'
    
    if ( ~ isempty(remove_days) )
       %  Not implemented yet
       %dat1 = ts_remove_days(dat1, remove_days)
       disp('Removal of daily solutions through remove_days not implemented\n')
    end
    
    % Window based on master window and determine data span
    
    % make sure include the t1 and t2 in data,
    t1 = t1 - 0.0001;
    t2 = t2 + 0.0001;
    data = window_timeseries(dat1, t1, t2);
    data_save = data;
    
    mint = min(data.time);
    maxt = max(data.time);
    
        % if the offset event time is in range [mint,maxt], keep it. If it is
    % not, just throw out the offset here.
   % if ((isempty(disps{i}) ~=1))
         if ((isempty(disps{i}) ~=1) && (isempty(mint) ~=1) && (isempty(maxt) ~=1))
        idxt = find((disps{i} > mint) & (disps{i} < maxt));
        disps{i} = disps{i}(idxt);
%         if((disps{i} < mint) || (disps{i} > maxt))
%             disps{i}=[];
%         end
        
         end
    
    
    if ( isempty(mint) )
        mint = 0;
        maxt = 0;
    end
    
    Tspan = maxt - mint;
    
    % Skip this site if there are less than 1.5 years of data
    
    if ( Tspan < min_Tspan )
        n_novelo = n_novelo + 1;
        no_velo{n_novelo} = char(sites(i));
        continue
        %    break out of the loop here
    end
    
    horz_addsig = horz_addsig_num/Tspan;
    vert_addsig = vert_addsig_num/Tspan;
    disp( ['Time span of measurements: ' num2str(Tspan) ' years'] );
    disp( ['Horizontal additive sigma is ' num2str(1000*horz_addsig) ' mm/yr'] );
    disp( ['Vertical additive sigma is ' num2str(1000*vert_addsig) ' mm/yr'] );
    
    
    
    %  ORIGINAL TIME SERIES
    %  Set up the model for the estimation
    
    define_model = new_tsmodel;    
    
    if ( seasflag(i) )
        define_model.periodics = [1 2];
    else
        define_model.periodics    = [ ];
    end
   
    % Set up the model for offsets
    % First, throw out offsets that are outside of the range [mint,maxt]
    
    if ( ~isempty(disps{i})  && ~isempty(mint) && ~isempty(maxt) )
        idxt = find((disps{i} > mint) & (disps{i} < maxt)); 
        disps{i} = disps{i}(idxt);    
    end
    
    if ( ~ isempty(disps{i}) )
        define_model.disp = disps{i};
        linlim = [floor(mint), define_model.disp(1)-0.0001 ];
        if ( length(define_model.disp) > 1)
            for j = 1:(length(define_model.disp) - 1)
                linlim = [linlim, define_model.disp(j)+0.0001, define_model.disp(j+1)-0.0001];
            end
        end
        linlim = [ linlim, define_model.disp( length(define_model.disp) )+0.0001, ceil(maxt) ];
        modeltimes = [];
        for j = 1:(length(linlim) - 1);
           modeltimes = [ modeltimes, linspace(linlim(j), linlim(j+1), 100)];
        end
        modeltimes = modeltimes';
        
        % Set up a priori values/sigmas for Sumatra vertical
        
        %disp('Applying a priori uncertainty of 1 cm for Sumatra vertical displacement.')
        %for j = 1:length(define_model.disp)
        %    if ( define_model.disp(j) == 2004.99 )
        %        apriori = struct('apname', [], 'apval', [], 'apsig', []);
        %        parname = ts_paramname('u', 'disp', 2004.99);
        %        apriori.apname{1} = parname;
        %        apriori.apval(1) = 0;
        %        apriori.apsig(1) = 0.01;
        %    else
        %        apriori = [];
        %    end
        %end

        
    else
        define_model.disp = [];
        modeltimes = [ linspace(floor(mint), ceil(maxt), 200) ]';
    end

    % Add station-specific elements to the model
    %   Several special models might have been defined. Check each one to
    %   see if this station needs to have its model augmented.
    
    if ( ~isempty(station_specific_models) )
        for jmod = 1:num_specific_models
            if ( strmatch(staname, station_specific_models{jmod}.stations) > 0 )
                if ( isfield(station_specific_models{jmod}, 'logs') )
                    define_model = ts_add_model_element(define_model, 'logs', station_specific_models{jmod}.logs);
                end
                if ( isfield(station_specific_models{jmod}, 'exponentials') )
                    define_model = ts_add_model_element(define_model, 'exponentials', station_specific_models{jmod}.exponentials);
                end
                if ( isfield(station_specific_models{jmod}, 'tanhs') )
                    define_model = ts_add_model_element(define_model, 'tanhs', station_specific_models{jmod}.tanhs);
                end
            end
        end
    end

    % Outlier rejection
    
    if ( fit_control.auto_outlier_rejection )
        %  Estimate a  model to find gross outliers, then strip them out
        %  Uses a simple white noise assumption.

        [predict, resids1, chi2dof, model] = tsfit(data, define_model, apriori);
        data_orig = data;
        data_flags = ts_flag_outliers(data, resids1, 15, 0.04);
        data = ts_strip_outliers(data_flags);
    
    end
    
    % Set up the data covariance if we use colored noise
    %  For the case of colored noise, construct the full data covariance
    %  matrix. Otherwise, leave this matrix empty.
    %  This needs to be done after outlier rejection, because the
    %  covariance depends on the exact data used.
    
    data.Cd = [];
    data.W  = [];
    
    if ( ~isempty(fit_control.noisemodel.colored.sig_flicker) )
        
        time_unit   = fit_control.noisemodel.colored.time_unit;
        
        % White noise sigma in fit_control is ignored for now.
        % if ( ~isempty(fit_control.noisemodel.colored.sig_white) )
        %     sig_white   = fit_control.noisemodel.colored.sig_white;
        % else
        %     sig_white = 0;
        % end
        
        % If user did not give three components for sig_flicker, then use
        % the same value for all components.
        
        sig_flicker = fit_control.noisemodel.colored.sig_flicker;
        if ( length(sig_flicker) == 1 )
           sig_flicker = sig_flicker*[1; 1; 1]; 
        end
        
        disp( ['Flicker noise sigma is [' num2str(1000*sig_flicker') ...
               '] mm, with time  unit ' time_unit] );

        % Construct the covariances and weight matrices for the 3
        % components individually, and then make the block diagonal full
        % matrices.
        
        % East
        
        Ce = sparse(tscov_correlated_noise(data.time, time_unit, data.esig, sig_flicker(1)));
        We = inv(Ce);
        
        % North
        
        Cn = sparse(tscov_correlated_noise(data.time, time_unit, data.nsig, sig_flicker(2)));
        Wn = inv(Cn);
        
        % height
        
        Ch = sparse(tscov_correlated_noise(data.time, time_unit, data.hsig, sig_flicker(3)));
        Wh = inv(Ch);
        
        data.Cd = blkdiag(Ce, Cn, Ch);
        data.W  = blkdiag(We, Wn, Wh);
    end
    
    %   output the sites that does not have seasonal file
    if( exist( [ sdir staname '_' stype '.seasonal' ]) == 0 )
        
        n_nosea = n_nosea + 1;
        no_seasonal{n_nosea} = staname;
        
    end
    
    %   Read and subtract the seasonal model in the .season file if it exists.
    %   We do this at this step because the covariance needs to be the same
    %   as for the regular model.
    
    if ( exist( [ sdir staname '_' stype '.seasonal' ]) > 0 )
        
        disp('Removing seasonal from observed time series');
        seasonal = read_seasonal_file( [ sdir staname '_' stype '.seasonal' ] );
        seasonal_modval = ts_eval_seasonal(data.time, seasonal);
        
        % subtract seasonal modval from data
        data_season_removed = data;
        data_season_removed.east   = data.east   - seasonal_modval(:,1);
        data_season_removed.north  = data.north  - seasonal_modval(:,2);
        data_season_removed.height = data.height - seasonal_modval(:,3);
        data_season_removed.enu    = data.enu    - seasonal_modval';
    else
        data_season_removed = [];
    end
    
    % Estimate the model
    
    [predict, resids, chi2dof, model] = tsfit(data, define_model, apriori);
    
    disp( ['Reduced chi-square: ' num2str(chi2dof) ] );

    % Save some additional information about the residuals to the model
    % structure
    
    model.resids  = resids;
    model.chi2dof = chi2dof;
    residmat    = reshape(resids, [], 3);
    model.eWRSS = sum( (residmat(:,1)./data.esig).^2 );
    model.nWRSS = sum( (residmat(:,2)./data.nsig).^2 );
    model.hWRSS = sum( (residmat(:,3)./data.hsig).^2 );
    model.nobs  = 3*length(data.time);
    model.data  = data;
    model.data.Cd = [];    % remove this gigantic matrix
    model.data.W  = [];    % remove this gigantic matrix
    model.predict = predict;
    model.apriori = apriori;
    model.define_model = define_model;

    j   = ts_parindex(model.parlist, 'e', 'rate');
    evel = model.parval(j)
    esig = sqrt(model.parcov(j,j) + horz_addsig^2 );
    
    j   = ts_parindex(model.parlist, 'n', 'rate');
    nvel = model.parval(j)
    nsig = sqrt(model.parcov(j,j) + horz_addsig^2 );
    
    j   = ts_parindex(model.parlist, 'u', 'rate');
    hvel = model.parval(j)
    hsig = sqrt(model.parcov(j,j) + vert_addsig^2 );
   
    fprintf(outfid1, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 100*evel, 100*nvel, ...
        100*esig, 100*nsig 0.0], staname);
    fprintf(outfidv1, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 0, 100*hvel, ...
        0, 100*hsig 0.0], staname);
    fprintf(outf3d1, '%s %f %f %f %f %f %f %f %f %f\n', staname, [data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
        100*esig, 100*nsig, 100*hsig] );
    
    [vrel_plate, ~, vRPcov] = calc_geodvel(plate, data.refxyz);
    disp( sprintf( 'Subtracting %4.2f mm/yr from vertical velocity for frame correction\n', 1000*vrel_plate(3) ));
    evel  = evel - vrel_plate(1);
    nvel  = nvel - vrel_plate(2);
    hvel  = hvel - vrel_plate(3);

    esig  = sqrt( esig.^2 + vRPcov(1,1) );
    nsig  = sqrt( nsig.^2 + vRPcov(2,2) );
    hsig  = sqrt( hsig.^2 + vRPcov(3,3) );
    
    fprintf(outfid2, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 100*evel, 100*nvel, ...
        100*esig, 100*nsig 0.0], staname);
    fprintf(outfidv2, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 0, 100*hvel, ...
        0, 100*hsig 0.0], staname);
    fprintf(outf3d2, '%s %f %f %f %f %f %f %f %f %f\n', staname, [data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
        100*esig, 100*nsig, 100*hsig] );
   
    
%    Write out displacements

    if ( ~isempty(define_model.disp) )
        
        for k = 1:length(define_model.disp)
            
            j   = ts_parindex(model.parlist, 'e', 'disp', define_model.disp(k));
            edval = model.parval(j);
            edsig = sqrt(model.parcov(j,j));
            
            j   = ts_parindex(model.parlist, 'n', 'disp', define_model.disp(k));
            ndval = model.parval(j);
            ndsig = sqrt(model.parcov(j,j));
            
            j   = ts_parindex(model.parlist, 'u', 'disp', define_model.disp(k));
            udval = model.parval(j);
            udsig = sqrt(model.parcov(j,j));
            
            fprintf(dispfid, '%s %f %f disp_%8.3f %f %f %f %f %f %f\n', ...
                 staname, [data.refllh(2), data.refllh(1), define_model.disp(k), ...
                 100*edval, 100*ndval, 100*udval, 100*edsig, 100*ndsig, 100*udsig] );
        end
        
    end

%    Write out a summary

    season = zeros(1,12);
    
    if ( seasflag(i) )
        %  Annual terms
        season( 1) = model.parval( ts_parindex(model.parlist, 'e', 'cos', 1.0) );
        season( 2) = model.parval( ts_parindex(model.parlist, 'e', 'sin', 1.0) );
        season( 3) = model.parval( ts_parindex(model.parlist, 'n', 'cos', 1.0) );
        season( 4) = model.parval( ts_parindex(model.parlist, 'n', 'sin', 1.0) );
        season( 5) = model.parval( ts_parindex(model.parlist, 'u', 'cos', 1.0) );
        season( 6) = model.parval( ts_parindex(model.parlist, 'u', 'sin', 1.0) );
        
        %  Semi-annual terms
        season( 7) = model.parval( ts_parindex(model.parlist, 'e', 'cos', 2.0) );
        season( 8) = model.parval( ts_parindex(model.parlist, 'e', 'sin', 2.0) );
        season( 9) = model.parval( ts_parindex(model.parlist, 'n', 'cos', 2.0) );
        season(10) = model.parval( ts_parindex(model.parlist, 'n', 'sin', 2.0) );
        season(11) = model.parval( ts_parindex(model.parlist, 'u', 'cos', 2.0) );
        season(12) = model.parval( ts_parindex(model.parlist, 'u', 'sin', 2.0) );
    end
    

    fprintf(sumfid, '%s (%5.2f) [%5.2f] %7.2f %6.2f %7.2f %6.2f %6.3f %6.3f %6.3f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\n', ...
        staname, [chi2dof, Tspan, data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
        100*esig, 100*nsig 100*hsig, 100*season] );


    modelval = tsfit(modeltimes, model);

    a    = reshape(modelval, [], 3);
    emod = a(:,1);
    nmod = a(:,2);
    hmod = a(:,3);
    

    h = tsplot_1station(data, modeltimes, emod, nmod, hmod, [], [], model.disp);
    filename = [outdir staname]; 
    hgsave(h, filename);
    saveas(h, [filename '.png'], 'png');
    close(h);
    clear h;

%   Then plot de-trended data
%    Only horizontals are de-trended

    e0    = model.parval( ts_parindex(model.parlist, 'e', 'bias') );
    evelo = model.parval( ts_parindex(model.parlist, 'e', 'rate') );

    n0    = model.parval( ts_parindex(model.parlist, 'n', 'bias') );
    nvelo = model.parval( ts_parindex(model.parlist, 'n', 'rate') );

    u0    = model.parval( ts_parindex(model.parlist, 'u', 'bias') );
    uvelo = model.parval( ts_parindex(model.parlist, 'u', 'rate') );
    
    data_detrend = data;

    t                   = data.time - model.t_ep;
    data_detrend.east   = data_detrend.east   - e0 - evelo*t;
    data_detrend.north  = data_detrend.north  - n0 - nvelo*t;
%    data_detrend.height = data_detrend.height - u0 - uvelo*t;
    data_detrend.height = data_detrend.height - u0;

    t    = modeltimes - model.t_ep;
    emod = a(:,1) - e0 - evelo*t;
    nmod = a(:,2) - n0 - nvelo*t;
%    hmod = a(:,3) - u0 - uvelo*t;
    hmod = a(:,3) - u0;


    h = tsplot_1station(data_detrend, modeltimes, emod, nmod, hmod, [], [], model.disp);
    title([staname ' (horizontal detrended)'], 'FontSize', 18);
    filename = [outdir staname '_detrend']; 
    hgsave(h, filename);
    saveas(h, [filename '.png'], 'png');
    close(h);
    clear h;

    % Plot 3 panel plots with data+model and residual time series 
    
    [hdm, hdr] = tsplot_3panel(data, model, model.disp, 'mm', 1, 0);
    figure(hdm);
    subplot(3,1,1);
    title(staname, 'FontSize', 18);
    filename = [outdir staname '_3']; 
    hgsave(hdm, filename);
    saveas(hdm, [filename '.png'], 'png');
    close(hdm);
    clear hdm;

    figure(hdr);
    subplot(3,1,1);
    title([staname ' residuals'], 'FontSize', 18);
    filename = [outdir staname '_resid_3']; 
    hgsave(hdr, filename);
    saveas(hdr, [filename '.png'], 'png');
    close(hdr);
    clear hdr;

    % Save the model to a .mat file for later re-loading, and the residuals
    %  to a file formatted for the HECTOR program
    
    save([outdir staname '.mat'], 'staname', 'fit_control', 'model', '-v7.3');
    ts_write_resids([outdir staname '.neu'], model);

    %  SEASONAL-REMOVED TIME SERIES
    
    if ( ~isempty(data_season_removed) )
        
        %  It still seems to be better to estimate seasonals
        %define_model.periodics    = [ ];

        % Outlier rejection is done only once, not needed here.
        %if ( fit_control.auto_outlier_rejection )
        %    %  Estimate a  model to find gross outliers, then strip them out
        %    [predict, resids1, chi2dof, model] = tsfit(data, define_model, apriori);
        %    data_orig = data;
        %    data_flags = ts_flag_outliers(data, resids1, 15, 0.04);
        %    data = ts_strip_outliers(data_flags);
        %end
        
        [predict, resids, chi2dof, model] = tsfit(data_season_removed, define_model, apriori);

        % Save some additional information about the residuals to the model
        % structure

        model.resids  = resids;
        model.chi2dof = chi2dof;
        residmat    = reshape(resids, [], 3);
        model.eWRSS = sum( (residmat(:,1)./data.esig).^2 );
        model.nWRSS = sum( (residmat(:,2)./data.nsig).^2 );
        model.hWRSS = sum( (residmat(:,3)./data.hsig).^2 );
        model.nobs  = 3*length(data.time);
        model.data  = data_season_removed;
        model.data.Cd = [];    % remove this gigantic matrix
        model.data.W  = [];    % remove this gigantic matrix
        model.predict = predict;
        model.apriori = apriori;
        model.define_model = define_model;

        j   = ts_parindex(model.parlist, 'e', 'rate');
        evel = model.parval(j)
        esig = sqrt(model.parcov(j,j) + horz_addsig^2 );

        j   = ts_parindex(model.parlist, 'n', 'rate');
        nvel = model.parval(j)
        nsig = sqrt(model.parcov(j,j) + horz_addsig^2 );

        j   = ts_parindex(model.parlist, 'u', 'rate');
        hvel = model.parval(j)
        hsig = sqrt(model.parcov(j,j) + vert_addsig^2 );

        
        fprintf(outfid1s, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 100*evel, 100*nvel, ...
            100*esig, 100*nsig 0.0], staname);
        fprintf(outfidvs1, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 0, 100*hvel, ...
            0, 100*hsig 0.0], staname);
        fprintf(outf3d1s, '%s %f %f %f %f %f %f %f %f %f\n', staname, [data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
            100*esig, 100*nsig, 100*hsig] );

        [vrel_plate, ~, vRPcov] = calc_geodvel('NOAM', data.refxyz);
        disp( sprintf( 'Subtracting %4.2f mm/yr from vertical velocity for frame correction\n', 1000*vrel_plate(3) ));
        evel  = evel - vrel_plate(1);
        nvel  = nvel - vrel_plate(2);
        hvel  = hvel - vrel_plate(3);

        esig  = sqrt( esig.^2 + vRPcov(1,1) );
        nsig  = sqrt( nsig.^2 + vRPcov(2,2) );
        hsig  = sqrt( hsig.^2 + vRPcov(3,3) );

        fprintf(outfid2s, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 100*evel, 100*nvel, ...
            100*esig, 100*nsig 0.0], staname);
        fprintf(outfidvs2, '%f %f %f %f %f %f %f %s\n', [data.refllh(2), data.refllh(1), 0, 100*hvel, ...
            0, 100*hsig 0.0], staname);
        fprintf(outf3d2s, '%s %f %f %f %f %f %f %f %f %f\n', staname, [data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
            100*esig, 100*nsig, 100*hsig] );
    
%       Write out displacements

        if ( ~isempty(define_model.disp) )

            for k = 1:length(define_model.disp)

                j   = ts_parindex(model.parlist, 'e', 'disp', define_model.disp(k));
                edval = model.parval(j);
                edsig = sqrt(model.parcov(j,j));

                j   = ts_parindex(model.parlist, 'n', 'disp', define_model.disp(k));
                ndval = model.parval(j);
                ndsig = sqrt(model.parcov(j,j));

                j   = ts_parindex(model.parlist, 'u', 'disp', define_model.disp(k));
                udval = model.parval(j);
                udsig = sqrt(model.parcov(j,j));

                fprintf(dispfids, '%s %f %f disp_%8.3f %f %f %f %f %f %f\n', staname, ...
                     [data.refllh(2), data.refllh(1), define_model.disp(k), ...
                     100*edval, 100*ndval, 100*udval, 100*edsig, 100*ndsig, 100*udsig] );

            end

        end

    %    Write out a summary

 
        fprintf(sumfids, '%s (%5.2f) [%5.2f] %7.2f %6.2f %7.2f %6.3f %6.3f %6.3f %5.2f %5.2f %5.2f\n', ...
            staname, [chi2dof, Tspan, data.refllh(2), data.refllh(1), data.refllh(3), 100*evel, 100*nvel, 100*hvel, ...
            100*esig, 100*nsig 100*hsig] );


        modelval = tsfit(modeltimes, model);

        a    = reshape(modelval, [], 3);
        emod = a(:,1);
        nmod = a(:,2);
        hmod = a(:,3);


        h = tsplot_1station(data_season_removed, modeltimes, emod, nmod, hmod, [], [], model.disp);
        title([staname '-seasonal'], 'FontSize', 18);
        filename = [outdir staname '-seasonal']; 
        hgsave(h, filename);
        saveas(h, [filename '.png'], 'png');
        close(h);
        clear h;

    %   Then plot de-trended data
    %    Only horizontals are de-trended

        e0    = model.parval( ts_parindex(model.parlist, 'e', 'bias') );
        evelo = model.parval( ts_parindex(model.parlist, 'e', 'rate') );

        n0    = model.parval( ts_parindex(model.parlist, 'n', 'bias') );
        nvelo = model.parval( ts_parindex(model.parlist, 'n', 'rate') );

        u0    = model.parval( ts_parindex(model.parlist, 'u', 'bias') );
        uvelo = model.parval( ts_parindex(model.parlist, 'u', 'rate') );

        data_detrend = data_season_removed;

        t                   = data_detrend.time - model.t_ep;
        data_detrend.east   = data_detrend.east   - e0 - evelo*t;
        data_detrend.north  = data_detrend.north  - n0 - nvelo*t;
%        data_detrend.height = data_detrend.height - u0 - uvelo*t;
        data_detrend.height = data_detrend.height - u0;

        t    = modeltimes - model.t_ep;
        emod = a(:,1) - e0 - evelo*t;
        nmod = a(:,2) - n0 - nvelo*t;
%        hmod = a(:,3) - u0 - uvelo*t;
        hmod = a(:,3) - u0;

        h = tsplot_1station(data_detrend, modeltimes, emod, nmod, hmod, [], [], model.disp);
        title([staname '-seasonal (horizontal detrended)'], 'FontSize', 18);
        filename = [outdir staname '-seasonal_detrend']; 
        hgsave(h, filename);
        saveas(h, [filename '.png'], 'png');
        close(h);
        clear h;

        % Plot 3 panel plots with data+model and residual time series 

        [hdm, hdr] = tsplot_3panel(data_season_removed, model, model.disp, 'mm', 1, 0);
        figure(hdm);
        subplot(3,1,1);
        title([staname '-seasonal'], 'FontSize', 18);
        filename = [outdir staname '-seasonal_3']; 
        hgsave(hdm, filename);
        saveas(hdm, [filename '.png'], 'png');
        close(hdm);
        clear hdm;
        
        figure(hdr);
        subplot(3,1,1);
        title([staname '-seasonal residuals'], 'FontSize', 18);
        filename = [outdir staname '-seasonal_resid_3']; 
        hgsave(hdr, filename);
        saveas(hdr, [filename '.png'], 'png');
        close(hdr);
        clear hdr;

    end

    % Save the model to a .mat file for later re-loading, and the residuals
    %  to a file formatted for the HECTOR program
    
    save([outdir staname '-seasonal.mat'], 'staname', 'fit_control', 'model', '-v7.3');
    ts_write_resids([outdir staname '-seasonal.neu'], model);

end

fclose(outfid1);
fclose(outfid2);
fclose(outf3d1);
fclose(outfidv1);
fclose(outfidv2);
fclose(outf3d2);
fclose(sumfid);
fclose(dispfid);

fclose(outfid1s);
fclose(outfid2s);
fclose(outf3d1s);
fclose(outfidvs1);
fclose(outfidvs2);
fclose(outf3d2s);
fclose(sumfids);
fclose(dispfids);

return
end

