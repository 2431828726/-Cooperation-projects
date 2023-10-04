function outseries = ts_flag_outliers(inseries, resids, sigtol, abstol)
%function outseries = ts_strip_outliers(inseries, resids, sigtol);
%  Flag outliers based on a residual test. Any point with a 3D residual
%  larger than sigtol sigma, or greater than abstol will be flagged.

% mak

switch ( nargin )
    case 1
        disp('error in ts_flag_outliers')
    case 2
        sigtol = [];
        abstol = [];
    case 3
        abstol = [];
end

%  Create a new timeseries struct and copy over the fields that do not
%   depend on the number of time records in the timeseries.

outseries = inseries;
if ( isempty(outseries.outlier) )
    outseries.outlier = zeros(size(outseries.time));
end

%%
% First the sigma test

if ( ~isempty(sigtol) )
    sigmas = [ inseries.esig , inseries.nsig , inseries.hsig ]';


    resid3d = reshape(resids, [], 3)'./sigmas;
    resid3d = resid3d.*resid3d;

    r3d = sqrt( sum(resid3d,1) );

    idx = find( r3d > sigtol );
    outseries.outlier(idx) = 1;

end

%%
% Now the absolute value test

if ( ~isempty(abstol) )
    resid3d = reshape(resids, [], 3)';
    resid3d = resid3d.*resid3d;

    r3d = sqrt( sum(resid3d,1) );

    idx = find( r3d > abstol );
    outseries.outlier(idx) = 1;

end