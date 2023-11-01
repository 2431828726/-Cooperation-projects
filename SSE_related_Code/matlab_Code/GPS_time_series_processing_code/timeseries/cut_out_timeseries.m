function outser = cut_out_timeseries(inser, t1, t2);
%function outser = cut_out_timeseries(inser, t1, t2)
% cuts out the part of the timeseries inser that satisfies the equations:
%   inser.time > t1
%   inser.time < t2
% The remainder of the timeseries is returned

outser1 = segment_timeseries_before(inser, t1);
outser2 = segment_timeseries_after(inser, t2);

outser = cat_timeseries(outser1, outser2);