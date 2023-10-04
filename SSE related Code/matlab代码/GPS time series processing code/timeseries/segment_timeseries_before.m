function outser = segment_timeseries_before(inser, t);
%function outser = segment_timeseries_before(inser, t)
% selects the part of the timeseries inser that satisfies the equation:
%   inser.time < t

outser = new_timeseries;

outser.sitename  = inser.sitename;
outser.refllh    = inser.refllh;
outser.refxyz    = inser.refxyz;
outser.x123xes   = inser.x123axes;
outser.x123names = inser.x123names;


% Find the times that satisfy the equation inser.time < t

i = (inser.time < t);
outser.time      = inser.time(i);

if ( ~isempty(inser.llh) )
    outser.llh      = inser.llh(:,i);
end

outser.east      = inser.east(i);
outser.esig      = inser.esig(i);
outser.north     = inser.north(i);
outser.nsig      = inser.nsig(i);
outser.height    = inser.height(i);
outser.hsig      = inser.hsig(i);

if ( ~isempty(inser.enu) )
    outser.enu      = inser.enu(:,i);
end

if ( ~isempty(inser.enucov) )
    outser.enucov   = inser.enucov(i);
end

if ( ~isempty(inser.outlier) )
    outser.outlier = inser.outlier(i);
end

if ( ~isempty(inser.x123) )
    outser.x123    = inser.x123(:,i);
end

if ( ~isempty(inser.x123cov) )
    outser.x123cov = inser.x123cov(i);
end