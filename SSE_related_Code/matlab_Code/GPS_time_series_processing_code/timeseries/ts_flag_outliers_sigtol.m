function outseries = ts_flag_outliers_sigtol(inseries, sigtol)
%function outseries = flag_outliers_sigtol(inseries, sigtol);
%  Sets outlier flags based on sigma tolerance. Any points with sigmas
%  larger than sigtol are flagged as outliers.
%
%sigtol  3x1 array with MAXIMUM tolerance for ENU sigmas, in mm
%            defaults to [10; 10; 30] mm


if ( nargin < 2 )
    sigtol = [10; 10; 30];
end

outseries = inseries;

%  Find the points that fail the sigtol test and mark them.

idx = find( (inseries.esig>sigtol(1) & inseries.esig>sigtol(2) & inseries.esig>sigtol(3)) );
outseries.outlier(idx) = ( outseries.outlier(idx) | 1 );