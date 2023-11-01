function [varargout] = fit_timeseries(varargin)
%function [predict, resids, model] = fit_timeseries(data, periodics, disp, logs, exponentials);
%
%or
%
%function [predict, resids] = fit_timeseries(time, model);

%%
% Parse out the input arguments
%

if ( nargin == 0 )
   
    error('fit_timeseries: Not enough input arguments');
    
end

%
%    Figure out which version of the input arguments we have. The first
%    argument must be either a timeseries data structure, or an array of
%    times. While doing so, keep track of the number of model parameters.
%
   
np = 2;

if ( isstruct( varargin{1}) )
    
    % fit_timeseries(data, periodics, disp, logs, exponentials);
    % We are given a data structure and need to fit the data.
    
    fitmodel = 1;
    
    data  = varargin{1};
    t_ep  = mean(data.time);
    times = data.time - t_ep;
    
    if ( nargin > 1 )
        periodics = varargin{2};
        np = np + 2*length(periodics);
    else
        periodics = [];
    end
    
    if ( nargin > 2 )
        disp = varargin{3};
        np = np + length(disp);
    else
        disp = [];
    end
    
    if ( nargin > 3 )
        logs = varargin{4};
        np = np + size(logs, 2);
    else
        logs = [];
    end
        
    if ( nargin > 4 )
        exponentials = varargin{5};
        np = np + size(exponentials,2);
    else
        exponentials = [];
    end
    
else
    
    % fit_timeseries(time, model, periodics, disp, logs, exponentials);
    % We are given an array of times and previously computed model, and
    % need to use the model to predict the model at the provided times.
    
    fitmodel = 0;
    
    model = varargin{2};
    times = varargin{1} - model.t_ep;
    times = times(:);
    t_ep  = model.t_ep;
    
    periodics    = model.periodics;
    disp         = model.disp;
    logs         = model.logs;
    exponentials = model.exponentials;

    np           = model.np;
          
end

nt = length(times);

%  Figure out how many total parameters will be in the model, based on the
%  passed arguments. If we are using a pre-existing model to calculate
%  predictions, it is also necessary here to check the length of the model
%  vector against the rest of the arguments.

G0 = zeros(nt, np);



%%
%  Construct the Greens function matrix to compute the model. We use the
%  same matrix whether we are going to estimate the model parameters or
%  apply them. We'll do this in parts for each parameter group, and
%  concatenate them as we go. First we make the matrix appropriate for a
%  single component, and then ue that to make the matrix for all 3 comps.
%

%  Linear terms: a + b*t

G0(:, 1:2) = [ones(size(times)) times ];
parlist    = [ padstr('bias'); padstr('rate') ];
ip         = 2;


%  Periodic terms: sin(2*pi*t/per) + cos(2*pi*t/per)
%    The frequency in cycles per year is passed to the function

if ( ~ isempty(periodics) )
   
    nper = length(periodics);
    
    %   Cosine terms come first, then sine terms
    
    arguments = 2*pi*times*periodics;
        
    G0(:, ip+1:ip+2*nper) = [ cos(arguments) sin(arguments) ];
    
    for i = 1:nper
        parlist(ip+i,:)   = padstr( sprintf('cos_%7.2f/yr', periodics(i)) );
    end
    
    ip = ip + nper;
    
    for i = 1:nper
        parlist(ip+i,:) = padstr( sprintf('sin_%7.2f/yr', periodics(i)) );        
    end
    
    ip  = ip + nper;
    
end



%  Displacement terms: H(t - td)
%    The times of displacement events are passed to the function

if ( ~ isempty(disp) )
   
    ndisp = length(disp);
    td    = disp(:) - t_ep;
    
    %   Should be able to remove this for loop:
    
    for i = 1:ndisp
        
        G0(:, ip+i) = [ heaviside(times, td(i)) ];
        parlist(ip+i,:)   = padstr( sprintf('disp_%f8.3', disp(i)) );
        
    end
    
    ip  = ip + ndisp;
    
end



%  Logarithmic terms: H(t - tl)*log(1 + (t-tl)/ltau)
%    The start time and the relaxation time are passed to the function

if ( ~ isempty(logs) )
    
    tl   = logs(1,:) - t_ep;
    ltau = logs(2,:);
   
    nlogs = length(tl);
    
    %   May be able to remove this for loop
    
    for i = 1:nlogs
        
        heav        = heaviside(times, tl(i));
        G0(:, ip+i) = [ heav.*log( 1 + (times-tl)/ltau(i) ) ];
        parlist(ip+i,:)   = padstr( sprintf('log %8.3f %6.3f', logs(1,i), ltau(i)) );
        
    end
    
    ip  = ip + nlogs;
    
end



%  Exponential terms: H(t - te)*(1 - exp(-(t-te)/etau))
%    The start time and the relaxation time are passed to the function

if ( ~ isempty(exponentials) )
    
    te   = exponentials(1,:) - t_ep;
    etau = exponentials(2,:);
   
    nexp = length(te);
    
    %   May be able to remove this for loop
    
    for i = 1:nexp
        
        heav        = heaviside(times, te(i));
        G0(:, ip+i) = [ heav.*(1 - exp(-(times-te)/etau)) ];
        parlist(ip+i,:)   = padstr( sprintf('exp %8.3f %6.3f', exponentials(1,i), etau(i)) );
        
    end
    
    ip  = ip + nlogs;
    
end



%%
%   Set up the full matrix
%

o0 = zeros(size(G0));
G       = [G0 o0 o0 ; o0 G0 o0; o0 o0 G0];

if ( fitmodel )
    
    pref      = repmat('e_', np, 1);
    
    size(pref)
    parlist
    
    parlist_e = [ pref parlist ];
    pref      = repmat('n_', np, 1);
    parlist_n = [ pref parlist ];
    pref      = repmat('u_', np, 1);
    parlist_u = [ pref parlist ];

    parlist   = [parlist_e; parlist_n; parlist_u];

end

%%
%   Estimate the model (if modelfit is true), and return values.
%

if ( fitmodel )
    d = [data.east ; data.north ; data.height ];
    sigs = [ data.esig ; data.nsig ; data.hsig ].^2;

    n = size(sigs);
    W = sparse(1:n, 1:n, 1./sigs);
    %    W = diag(1./sigs, 0);
    parval = inv(G'*W*G)*G'*W*d
    parcov = inv(G'*W*G);

    predict = G*parval;
    resids  = d - predict;
    chi2    = resids'*W*resids;
    dof     = length(d) - size(G,2);
    chi2dof = chi2/dof
    
    parcov  = parcov*chi2dof;

    model = struct( 'periodics', periodics, 'disp', disp, 'logs', logs, ...
                    'exponentials', exponentials, 'np', np, 't_ep', t_ep', ...
                    'parlist', parlist, 'parval', parval', 'parcov', parcov);
                
    varargout = cell(3,1);
    varargout{1} = predict;
    varargout{2} = resids;
    varargout{3} = model;

else

    varargout    = cell(1,1);
    varargout{1} = G*model.parval(:);
    
end

return


function string = padstr(instr)

string = sprintf('%20s', instr);

return
