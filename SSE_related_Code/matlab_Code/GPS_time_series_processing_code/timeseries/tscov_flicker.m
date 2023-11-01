function Cflick = tscov_flicker(t, time_unit)
%function Cflick = tscov_flicker(t, time_unit)
%
% Return an N by N covariance matrix for flicker noise
% base on equations from Zhang et al. (1997) and Mao et al. (1999).
%
% t is time in days, weeks or years.
% time_unit may be 'day', 'week', or 'year' (default)

if ( nargin < 2 )
    time_unit = 'year';
end

switch ( time_unit )
    case 'day'
        scale = 1.0;
    case 'week'
        scale = 7.0;
    case 'year'
        scale = 365.25;
    otherwise
        scale = 365.25;
end
t = t(:)*scale;
n = length(t);

% The equation below works for the off-diagonal components, and is fast in
% MATLAB. Equations from Zhang et al. (1997) and Mao et al. (1999).

ti = repmat(t, 1, n);
tj = repmat(t', n, 1);
Cflick = (9/16)*(2 - (log(abs(ti - tj))/log(2) + 2)/12);

% The diagonal components are all equal to 9/8

nine_eighths = 9/8;
for i = 1:n
    Cflick(i,i) = nine_eighths;
end

% Work-around for duplicate times. If there are any times that have two
% separate solutions with the same time (leap year issues), then the
% Infinity value that results will be replaced with the value for a time
% lag of 1 day.

idx = isinf(Cflick);
if ( ~isempty(idx) )
    Cflick(idx) = (9/16)*(2 - (log(1)/log(2) + 2)/12);
end

return