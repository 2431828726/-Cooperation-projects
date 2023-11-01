function outser = window_timeseries(inser, t1, t2);
%function outser = window_timeseries(inser, t1, t2)
% selects the part of the timeseries inser that satisfies the equations:
%   inser.time > t1
%   inser.time < t2

outser = segment_timeseries_after(inser, t1);
outser = segment_timeseries_before(outser, t2);