function fit_ts = timeseries_fit(times, obs_ts, obs_sig, disps)
% fit deformation timeseries with a linear, seasonal functions (plus a possible disps term).
% d = a + b*t + c*cos(2*pi*t) + d*sin(2*pi*t) + e*cos(4*pi*t) +
% f*sin(4*pi*t) (+ g )
% "disps" determine if g exist or not.
%
% Usage:
% timeseries_fit(data_GPS.time, data_GPS.height, data_GPS,hsig, offset);
% where offset can be:
% offset = []; % no offset to estimate
% or
% offset = [2002.8411]; % one offset at time of 2002.8411
% or
% offset = [2002.8411 2010.1]; % estimate 2 (or more) offsets at 2002.8411 and 2010.1 
% or 
% timeseries_fit(data_GPS.time, data_GPS.height, data_GPS,hsig); % No offset to estimat
%
% Yuning Fu, 2012

if ( nargin < 4 )
    disps = [];
end

% assign some parameters
fit_ts = struct('parval', [], 'parcov', [], 'predict', [], 'resids', [], ...
    'chi2', [], 'dof', [], 'chi2dof', [], 'model_pre', [], 'model_time', [], ...
    'wrms', [], 'reduced_chi2', []);

nt = length(times);

obs_SIG2 = [ obs_sig ].^2;
obs_W    = sparse(1:nt, 1:nt, 1./obs_SIG2);

if ( isnan(disps) )
    
    np = 6;

    % deal with multiple 
    
    % fit timeseries
    G         = zeros(nt, np);
    G(:, 1:2) = [ ones(size(times)) times ];
    G(:, 3:4) = [ cos(2*pi*times) sin(2*pi*times) ];
    G(:, 5:6) = [ cos(4*pi*times) sin(4*pi*times) ];
    
else 
        
    np = 6 + length(disps);
    
    G         = zeros(nt, np);
    G(:, 1:2) = [ ones(size(times)) times ];
    G(:, 3:4) = [ cos(2*pi*times) sin(2*pi*times) ];
    G(:, 5:6) = [ cos(4*pi*times) sin(4*pi*times) ];

    for i = 1:length(disps)
       G(:, 6+i) = [ heaviside(times - disps(i) - 0.000001) ];
    end
    
end

fit_ts.parval = inv(G'*obs_W*G)*G'*obs_W*obs_ts;
fit_ts.parcov = inv(G'*obs_W*G);

fit_ts.predict = G*fit_ts.parval;
fit_ts.resids  = obs_ts - fit_ts.predict;
fit_ts.chi2    = fit_ts.resids'*obs_W*fit_ts.resids;
fit_ts.dof     = length(obs_ts) - size(G,2);
fit_ts.chi2dof = fit_ts.chi2/fit_ts.dof;

fit_ts.wrms         = sqrt(fit_ts.chi2/sum(obs_W(:)));
fit_ts.reduced_chi2 = fit_ts.chi2dof;

fit_ts.parcov  = fit_ts.parcov*fit_ts.chi2dof;

% calculate predicted timeseries
t1         = times(1) - 1 ;
t2         = times(end) + 1;
sam_num    = 365*(t2-t1);
modeltimes = [ linspace(t1, t2, sam_num) ]';
nt_model   = length(modeltimes);

G_m         = zeros(nt_model, np);

if ( isnan(disps) )
    G_m(:, 1:2) = [ ones(size(modeltimes)) modeltimes ];
    G_m(:, 3:4) = [ cos(2*pi*modeltimes) sin(2*pi*modeltimes) ];
    G_m(:, 5:6) = [ cos(4*pi*modeltimes) sin(4*pi*modeltimes) ];
else
    G_m(:, 1:2) = [ ones(size(modeltimes)) modeltimes ];
    G_m(:, 3:4) = [ cos(2*pi*modeltimes) sin(2*pi*modeltimes) ];
    G_m(:, 5:6) = [ cos(4*pi*modeltimes) sin(4*pi*modeltimes) ];
    for i = 1:length(disps)
       G_m(:, 6+i) = [ heaviside(modeltimes - disps(i)) ];
    end
end

fit_ts.model_pre  = G_m*fit_ts.parval;
fit_ts.model_time = modeltimes;