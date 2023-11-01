function outseries = ts_flag_outliers_absval(inseries, resids, abstol)
%function outseries = ts_strip_absval(inseries, resids, abstol);
%  Flag outliers based on a residual test. Any point with a 3D residual
%  larger than abstol will be flagged.

%  Create a new timeseries struct and copy over the fields that do not
%   depend on the number of time records in the timeseries.

outseries = inseries;

if ( isempty(outseries.outlier) )
    outseries.outlier = zeros(size(outseries.time));
end

%%
%  Compute the normalized residuals.
%    First rescale by sigmas. Then compute the norm of the scaled resid
%    vector for each site.

sigmas = [ inseries.esig , inseries.nsig , inseries.hsig ]';


resid3d = reshape(resids, [], 3);
resid3d = resid3d.*resid3d;

r3d = sqrt( sum(resid3d,1) );

idx = find( r3d > abstol );
outseries.outlier(idx) = 1;

