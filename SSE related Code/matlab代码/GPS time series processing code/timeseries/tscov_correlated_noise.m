function C = tscov_correlated_noise(t, time_unit, sig_white, sig_flicker)
%function cov = tscov_correlated_noise(t, time_unit, sig_white, sig_flicker)
%
% Return an N by N (sparse) covariance matrix for white + flicker noise
% based on equations from Zhang et al. (1997) and Mao et al. (1999).
%
% t is time in days, weeks or years.
% time_unit may be 'day', 'week', or 'year' (default)
%
% whitenoise can be length N, or length 1
%    N: each measurement has a different sigma
%    1: all measurements have the same sigma
% flickernoise has length 1

if ( nargin < 4 )
    sig_flicker = 0;
end
if ( nargin < 3 )
    sig_white = 0;
end

n = length(t);
t = t(:);

% White noise component

if ( length(sig_white) == 1 )
    sig_white = sig_white*ones(size(t));
end
Cwhite = sparse(1:n, 1:n, sig_white.^2);

% Flicker noise component

if ( sig_flicker == 0 )
    Cflicker = zeros(size(Cwhite));
else
    Cflicker = (sig_flicker.^2)*tscov_flicker(t, time_unit);
end

% Sum

C = Cwhite + Cflicker;

return