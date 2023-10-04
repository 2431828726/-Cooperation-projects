function timeseries = new_timeseries
%function timeseries = new_timeseries
% Returns a new timeseries structure. All fields have empty values.
%
% The timeseries struct has the following elements:
%    timeseries.time        N by 1 vector of dates (decimal year)
%    timeseries.sitename    1-4 character string with site name
%    timeseries.comment     Comment(s), string or cell array
%    timeseries.refllh      Reference lat-long-height (3 by 1)
%    timeseries.refxyz      Reference XYZ (3 by 1)
%    timeseries.llh         series of Lat-long-height values
%    timeseries.east        series of east values
%    timeseries.esig        series of east sigmas
%    timeseries.north       series of east values
%    timeseries.nsig        series of east sigmas
%    timeseries.height      series of east values
%    timeseries.hsig        series of east sigmas
%    timeseries.enu         array-stored enu values (3 by N)
%    timeseries.enucov      array of cells, each with 3x3 covariance
%    timeseries.outlier     array of outlier flags, 0=ok, 1=outlier
%    timeseries.x123axes    3x3 column vectors of coordinate axes x1,x2,x3
%    timeseries.x123names   cell array of names for coordinate axes x1,x2,x3
%    timeseries.x123        array-stored (x1,x2,x3) values (3 by N)
%    timeseries.x123cov     array of cells, each with 3x3 covariance

timeseries = struct('time', [], 'sitename', [], 'comment', [], ...
    'refllh', [], 'refxyz', [], 'llh', [], ...
    'east', [], 'esig', [], 'north', [], 'nsig', [], 'height', [], 'hsig', [], ...
    'enu', [], 'enucov', [], 'outlier', [], ...
    'x123axes', [], 'x123names', [], 'x123', [], 'x123cov', [] );
