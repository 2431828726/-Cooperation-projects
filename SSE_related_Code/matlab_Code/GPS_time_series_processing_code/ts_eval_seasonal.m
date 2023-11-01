function  seasonal_modval = ts_eval_seasonal(date, seasonal, component)
%function  seasonal_modval = ts_eval_seasonal(date, seasonal, component)
% Evaluate a seasonal model at times given by array date.
%
% Interpolate model. Input is the struct seasonal with fields
%    bintime    should have values ranging between 0 and 1, with repeated
%             values less than zero and more than 1. For example,
%             [-0.025, 0.025, 0.075, ... , 0.925, 0.975, 1.025]
%    east, north, height  are corresponding bin values
%
% If component is specified, it should be either 'east', 'north', or 'height'.
%    In that case, seasonal_modval computes that component only.

if (nargin < 3 )
    component = [];
end

nbins = length(seasonal.bintime);
bin_t  = [ seasonal.bintime(nbins)-1 ; seasonal.bintime(:) ; 1+seasonal.bintime(1) ];
binsize = seasonal.binsize;

tdate = date - fix(date);

if ( isempty(component) )

    % Figure out which bin interval each point lies in
    %    The most efficient way to do it is to loop over the bins and do all
    %    points within that bin. The number of bins should be small relative
    %    to the number of dates.

    east   = [ seasonal.east.smooth(nbins) ; seasonal.east.smooth(:) ; seasonal.east.smooth(1) ];
    north  = [ seasonal.north.smooth(nbins) ; seasonal.north.smooth(:) ; seasonal.north.smooth(1) ];
    height = [ seasonal.height.smooth(nbins) ; seasonal.height.smooth(:) ; seasonal.height.smooth(1) ];

    seasonal_modval = zeros(3,size(tdate,1));

    for i = 1:nbins+1,
        inbin = ( (tdate > bin_t(i)) & (tdate <= bin_t(i+1)) );
        indices = find(inbin);
        dt = ( tdate(indices) - bin_t(i) )';
%        dt = ( tdate(indices) - (bin_t(i)-binsize/2)*ones(size(tdate(indices))) )';

        seasonal_modval(:,indices) = [ east(i)   + (east(i+1)   - east(i)  )*(dt/binsize); ...
                                       north(i)  + (north(i+1)  - north(i) )*(dt/binsize); ...
                                       height(i) + (height(i+1) - height(i))*(dt/binsize) ];
    end

    seasonal_modval = seasonal_modval';

else
    
    % Figure out which bin interval each point lies in
    %    The most efficient way to do it is to loop over the bins and do all
    %    points within that bin. The number of bins should be small relative
    %    to the number of dates.
    
    val    = [ seasonal.(component).smooth(nbins) ; seasonal.(component).smooth(:) ; seasonal.(component).smooth(1) ];
    seasonal_modval = zeros(1,size(tdate,1));

    for i = 1:nbins+1,
        inbin = ( (tdate > bin_t(i)) & (tdate <= bin_t(i+1)) );
        indices = find(inbin);
        dt = ( tdate(indices) - bin_t(i) )';
%        dt = ( tdate(indices) - bin_t(i)*ones(size(tdate(indices))) )';

        seasonal_modval(indices) = [ val(i) + (val(i+1) - val(i))*(dt/binsize)];
    end

    seasonal_modval = seasonal_modval';

end
