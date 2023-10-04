function [seasonal, seasonal_removed_timeseries, detrended_timeseries] = ts_seasonal_avg(timeseries, nbins, porder)
%function [seasonal, seasonal_removed_timeseries, detrended_timeseries] = ts_seasonal_avg(timeseries, nbins, porder)
% 
% if porder <= 0, then no polynomial is removed from the data

switch ( nargin )
    
    case 1
        nbins = 40;
        porder = 2;
        
    case 2
        porder = 2;
        
    case 3
end

%%
%  Set up structure to return results

binsize = 1/nbins;
bintime = binsize*linspace(0, nbins+1, nbins+2) - binsize/2;

east   = struct( 'binval', [], 'smooth', [] );
north  = east;
height = east;

seasonal = struct( 'bintime', [], 'binsize', binsize, 'east', east, 'north', north, 'height', height );

%%
%  Extract the timeseries data and detrend 

tlat     = timeseries.north;
tlon     = timeseries.east;
theight  = timeseries.height;
tdate    = timeseries.time;
fracdate = tdate - fix(tdate);

% Detrend each component

if ( porder > 0 )
    [plat,~,mu] = polyfit(tdate, tlat, porder);
    tlat = tlat - polyval(plat, tdate, [], mu);

    [plon,~,mu] = polyfit(tdate, tlon, porder);
    tlon = tlon - polyval(plon, tdate, [], mu);

    [pht,~,mu] = polyfit(tdate, theight, porder);
    theight = theight - polyval(pht, tdate, [], mu);
end

detrended_timeseries        = timeseries;
detrended_timeseries.east   = tlon;
detrended_timeseries.north  = tlat;
detrended_timeseries.height = theight;

%%
%  Stack the residuals for each bin and smooth

binfrac = [0, linspace(binsize, 1, nbins)];
binavg_lat = zeros(1,nbins);
binavg_lon = zeros(1,nbins);
binavg_ht  = zeros(1,nbins);

for i = 1:nbins,  
    inbin = (fracdate > binfrac(i) & fracdate <= binfrac(i+1));
    indices = find(inbin);
    
    binavg_lat(i) = mean(tlat(indices));
    binavg_lon(i) = mean(tlon(indices));
    binavg_ht(i)  = mean(theight(indices));
end

%bin_val_lat = [binavg_lat(nbins), binavg_lat, binavg_lat(1)];
%smooth_val_lat = smooth([bin_val_lat(2:nbins), bin_val_lat(2:nbins)], 5, 4);

%  Compute the smoothed version (5 point smoother)

%smooth_val_lat = smooth([binavg_lat(2:nbins), binavg_lat(2:nbins)], 5, 4);
%smooth_val_lon = smooth([binavg_lon(2:nbins), binavg_lon(2:nbins)], 5, 4);
%smooth_val_ht  = smooth([binavg_ht(2:nbins),  binavg_ht(2:nbins) ],  5, 4);

%
%  Fill the output structure seasonal
%  Compute the smoothed version (5 point smoother)
%    5/1/2013 updated code below to work with the current implementation of
%    'smooth'

seasonal.bintime = bintime(2:nbins+1);

seasonal.north.binval = binavg_lat';
sm = smooth([binavg_lat(nbins-2:nbins-1), binavg_lat, binavg_lat(1:2)], 5)';
seasonal.north.smooth = sm(3:nbins+2);
%seasonal.north.smooth = smooth([binavg_lat(nbins-3:nbins-1), binavg_lat, binavg_lat(1:3)], 5, 4);

seasonal.east.binval = binavg_lon';
sm = smooth([binavg_lon(nbins-2:nbins-1), binavg_lon, binavg_lon(1:2)], 5);
seasonal.east.smooth = sm(3:nbins+2);
%seasonal.east.smooth = smooth([binavg_lon(nbins-3:nbins-1), binavg_lon, binavg_lon(1:3)], 5, 4);

seasonal.height.binval = binavg_ht';
sm = smooth([binavg_ht(nbins-2:nbins-1),  binavg_ht,  binavg_ht(1:2)], 5);
seasonal.height.smooth = sm(3:nbins+2);
%seasonal.height.smooth = smooth([binavg_ht(nbins-3:nbins-1),  binavg_ht,  binavg_ht(1:3)], 5, 4);


%%
%   Compute the timeseries with seasonals removed

seasonal_removed_timeseries = timeseries;
seasonal_modval = ts_eval_seasonal(timeseries.time, seasonal);

seasonal_removed_timeseries.east   = seasonal_removed_timeseries.east   - seasonal_modval(:,1);
seasonal_removed_timeseries.north  = seasonal_removed_timeseries.north  - seasonal_modval(:,2);
seasonal_removed_timeseries.height = seasonal_removed_timeseries.height - seasonal_modval(:,3);

seasonal_removed_timeseries.enu    = seasonal_removed_timeseries.enu    - seasonal_modval';

%   Compute the timeseries with seasonals removed, in llh

xyzmod = repmat(timeseries.refxyz, length(timeseries.time), 1) + enu2xyz(timeseries.refllh, seasonal_modval(:));
subtracted.llh = xyz2llh(reshape(xyzmod, 3, []));


% If there is a transformed version in 'x123', subtract model from that as
% well (after rotation)

if ( ~isempty( timeseries.x123axes ) )
   seasonal_removed_timeseries.x123 = timeseries.x123 - x123axes'*seasonal_modval; 
end


