function [varargout] = fit_timeseries(varargin)
%function [predict, resids, chi2dof, model] = fit_timeseries(data, periodics, disp, logs, exponentials, tanhs);
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
 

if ( isstruct( varargin{1}) )
    
    % fit_timeseries(data, periodics, disp, logs, exponentials);
    % We are given a data structure and need to fit the data.
    % Contstruct the parameters list and do other one-time-only
    % bookkeeping.
    
    fitmodel = 1;
    
    data   = varargin{1};
    t_ep   = round(mean(data.time));
    times  = data.time - t_ep;
    
    parlist    = [ padstr('bias'); padstr('rate') ];
    np = 2;
    
%   Periodic terms

    if ( nargin > 1 )
        periodics = varargin{2};
        nper      = length(periodics);
        
        for i = 1:nper
            parlist(np+i,:)   = padstr( sprintf('cos_%7.2f/yr', periodics(i)) );
        end
        np = np + nper;

        for i = 1:nper
            parlist(np+i,:) = padstr( sprintf('sin_%7.2f/yr', periodics(i)) );        
        end
        np  = np + nper;
    else
        periodics = [];
        nper      = 0;
    end
    
    
%   Displacement terms

    if ( nargin > 2 )
        disp  = varargin{3};
        ndisp = length(disp);
        if ( ndisp > 0 )
            td    = disp(:) - t_ep;

            for i = 1:ndisp
                parlist(np+i,:)   = padstr( sprintf('disp_%8.3f', disp(i)) );
            end
            np = np + ndisp;
        end
    else
        disp  = [];
        ndisp = 0;
    end
    
%   Logarithmic terms

    if ( nargin > 3 )
        logs  = varargin{4};
        nlogs = size(logs,2);
        if ( nlogs > 0 )
            tl    = logs(1,:) - t_ep;
            ltau  = logs(2,:);

            for i = 1:nlogs
                parlist(np+i,:)   = padstr( sprintf('log %8.3f %6.3f', logs(1,i), ltau(i)) );
            end
            np = np + nlogs;
        end
    else
        logs  = [];
        nlogs = 0;
    end
        
%   Exponential terms

    if ( nargin > 4 )
        exponentials = varargin{5};
        nexp         = size(exponentials,2);
        if ( nexp > 0 )
            te           = exponentials(1,:) - t_ep;
            etau         = exponentials(2,:);

            for i = 1:nexp
                parlist(np+i,:)   = padstr( sprintf('exp %8.3f %6.3f', exponentials(1,i), etau(i)) );
            end

            np = np + nexp;
        end
    else
        exponentials = [];
        nexp         = 0;
    end
 
%   nper  = length(periodics);
%    ndisp = length(disp);
%    nlogs = size(logs,2);
%    nexp = size(exponentials,2);
    
    %   Hyperbolic tangent terms

    if ( nargin > 5 )
        tanhs  = varargin{6};
        ntanhs = size(tanhs,2); 
        if ( ntanhs > 0 )
            tth    = tanhs(1,:) - t_ep;
            thtau  = tanhs(2,:);

            for i = 1:ntanhs
                parlist(np+i,:)   = padstr( sprintf('tanh %8.3f %6.3f', tanhs(1,i), thtau(i)) );
            end
            np = np + ntanhs;
        end
    else
        tanhs  = [];
        ntanhs = 0;
    end
        
    % Make up the list of parameters
    
    pref      = repmat('e_', np, 1);
    parlist_e = [ pref parlist ];
    pref      = repmat('n_', np, 1);
    parlist_n = [ pref parlist ];
    pref      = repmat('u_', np, 1);
    parlist_u = [ pref parlist ];

    parlist   = [parlist_e; parlist_n; parlist_u];


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
    nper  = length(periodics);

    disp         = model.disp;
    ndisp = length(disp);
    td    = disp(:) - t_ep;


    logs         = model.logs;
    nlogs = size(logs,2);
    if ( nlogs > 0 )
        tl    = logs(1,:) - t_ep;
        ltau  = logs(2,:);
    end

    exponentials = model.exponentials;
    nexp         = size(exponentials,2);
    if ( nexp > 0 )
        te           = exponentials(1,:) - t_ep;
        etau         = exponentials(2,:);
    end

    tanhs         = model.tanhs;
    ntanhs = size(tanhs,2);
    if ( ntanhs > 0 )
        tth    = tanhs(1,:) - t_ep;
        thtau  = tanhs(2,:);
    end

    np      = model.np;
    parlist = model.parlist;
    parval  = model.parval(:);
          
end

nt = length(times);

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
ip         = 2;


%  Periodic terms: sin(2*pi*t/per) + cos(2*pi*t/per)
%    The frequency in cycles per year is passed to the function

if ( nper > 0 )
   
    arguments = 2*pi*times*periodics;
        
    %   Cosine terms come first, then sine terms
    
    G0(:, ip+1:ip+2*nper) = [ cos(arguments) sin(arguments) ];
    ip  = ip + 2*nper;
    
end



%  Displacement terms: H(t - td)
%    The times of displacement events are passed to the function

if ( ndisp > 0 )
       
    %   Should be able to remove this for loop:
    for i = 1:ndisp
        G0(:, ip+i) = heaviside(times, td(i));
    end
    
    ip  = ip + ndisp;
    
end


%  Logarithmic terms: H(t - tl)*log(1 + (t-tl)/ltau)
%    The start time and the relaxation time are passed to the function

if ( nlogs > 0 )
        
    %   May be able to remove this for loop
    for i = 1:nlogs
        heav        = heaviside(times, tl(i));
        G0(:, ip+i) = heav.*log( 1 + (times-tl(i))/ltau(i) );
    end
    
    ip  = ip + nlogs;
    
end



%  Exponential terms: H(t - te)*(1 - exp(-(t-te)/etau))
%    The start time and the relaxation time are passed to the function

if ( nexp > 0 )
        
    %   May be able to remove this for loop
    for i = 1:nexp
        heav        = heaviside(times, te(i));
        G0(:, ip+i) = heav.*(1 - exp(-(times-te(i))/etau(i)));
    end
    
    ip  = ip + nlogs;
    
end

%  Hyperbolic tangent terms: 0.5*( 1 + tanh( (t-tth)/thtau ) )
%    The start time and the characteristic time are passed to the function

if ( ntanhs > 0 )
        
    %   May be able to remove this for loop
    for i = 1:ntanhs
        G0(:, ip+i) = 0.5*( 1 + tanh( (times-tth(i))/thtau(i) ) );
    end
    
    ip  = ip + ntanhs;
    
end



%
%   Set up the full matrix
%

o0 = zeros(size(G0));
G       = [G0 o0 o0 ; o0 G0 o0; o0 o0 G0];


%%
%   Estimate the model (if modelfit is true), and return values.
%

if ( fitmodel )
    d = [data.east ; data.north ; data.height ];
    sigs = [ data.esig ; data.nsig ; data.hsig ].^2;

    n = size(sigs);
    W = sparse(1:n, 1:n, 1./sigs);
    %    W = diag(1./sigs, 0);
    invmat = inv(G'*W*G);
    parval = invmat*G'*W*d
    a = invmat*G'*W;
    parcov = a*sparse(1:n, 1:n, sigs)*a';

    predict = G*parval;
    resids  = d - predict;
    chi2    = resids'*W*resids;
    dof     = length(d) - size(G,2);
    chi2dof = chi2/dof
    
    parcov  = parcov*chi2dof;

    model = struct( 'periodics', periodics, 'disp', disp, 'logs', logs, ...
                    'exponentials', exponentials, 'tanhs', tanhs, ...
                    'np', np, 't_ep', t_ep', ...
                    'parlist', parlist, 'parval', parval', 'parcov', parcov);
                
    varargout = cell(4,1);
    varargout{1} = predict;
    varargout{2} = resids;
    varargout{3} = chi2dof;
    varargout{4} = model;

else
    
    predict = G*parval;

    varargout    = cell(1,1);
    varargout{1} = G*model.parval(:);
    
end

return


function string = padstr(instr)

string = sprintf('%20s', instr);

return
