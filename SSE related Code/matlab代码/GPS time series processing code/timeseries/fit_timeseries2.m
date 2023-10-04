function [varargout] = fit_timeseries2(varargin)
%function [predict, resids, chi2dof, model] = fit_timeseries2(data, periodics, disp, logs, exponentials, tanhs);
%
%or
%
%function [predict, resids] = fit_timeseries2(time, model);

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
    model    = new_model_struct;
    
    data          = varargin{1};
    model.t_ep    = round(mean(data.time));
    times         = data.time - model.t_ep;
        
%   Parse the input arguments

%   Periodics

    if ( nargin > 1 )
        model.periodics = varargin{2};
    end
    
%   Displacement terms

    if ( nargin > 2 )
        model.disp = varargin{3};
    end
    
%   Logarithmic terms

    if ( nargin > 3 )
        model.logs = varargin{4};
    end
        
%   Exponential terms

    if ( nargin > 4 )
        model.exponentials = varargin{5};
    end

   %   Hyperbolic tangent terms

    if ( nargin > 5 )
        model.tanhs = varargin{6};
    end
        
else
    
    % fit_timeseries(time, model, periodics, disp, logs, exponentials);
    % We are given an array of times and previously computed model, and
    % need to use the model to predict the model at the provided times.
    
    fitmodel = 0;
    
    model = varargin{2};
    times = varargin{1} - model.t_ep;
    times = times(:);

end

model = model_setup(model);


%  Construct the Greens function matrix to compute the model. 

G = make_g(times, model);


%%
%   Estimate the model (if modelfit is true), and return values.
%

if ( fitmodel )
    d = [data.east ; data.north ; data.height ];
    sigs = [ data.esig ; data.nsig ; data.hsig ].^2;

    n = size(sigs);
    W = sparse(1:n, 1:n, 1./sigs);
    invmat = inv(G'*W*G);
    
    model.parval = invmat*G'*W*d;
    a            = invmat*G'*W;
    model.parcov = a*sparse(1:n, 1:n, sigs)*a';
    
    disp('model.parval = ')
    disp(model.parval)

    predict = G*model.parval;
    resids  = d - predict;
    chi2    = resids'*W*resids;
    dof     = length(d) - size(G,2);
    chi2dof = chi2/dof
    
    model.parval  = model.parval';
    model.parcov  = model.parcov*chi2dof;
                
    varargout = cell(4,1);
    varargout{1} = predict;
    varargout{2} = resids;
    varargout{3} = chi2dof;
    varargout{4} = model;

else
    
    predict = G*model.parval;

    varargout    = cell(1,1);
    varargout{1} = G*model.parval(:);
    
end

return

%%
%

function string = padstr(instr)

string = sprintf('%20s', instr);

return

%%
%  Return a new model structure

function model = new_model_struct

n     = struct( 'nper', 0, 'ndisp', 0, 'nlogs', 0, 'nexp', 0, 'ntanhs', 0);

t     = struct( 'td', [], 'tl', [], 'te', [], 'tth', []);

tau   = struct( 'ltau', [], 'etau', [], 'thtau', []);

model = struct( 'periodics', [], 'disp', [], 'logs', [], ...
                'exponentials', [], 'tanhs', [], ...
                'np', [], 't_ep', []', 'n', n, 't', t, 'tau', tau, ...
                'parlist', [], 'parval', [], 'parcov', []);
                
return

%%
%
function model = model_setup(in)

%  Does the model setup steps:
%      Fill in values of counter variables and time and timescale variables
%      Construct the parameter list

    model = model_copy(in);
    
    %   Bias and rate terms assumed
    
    parlist = [ padstr('bias'); padstr('rate') ];
    np      = 2;

    %   Periodic terms

    model.n.nper = length(model.periodics);
    for i = 1:model.n.nper
        parlist(np+i,:) = padstr( sprintf('cos_%7.2f/yr', model.periodics(i)) );
    end
    np = np + model.n.nper;

    for i = 1:model.n.nper
        parlist(np+i,:) = padstr( sprintf('sin_%7.2f/yr', model.periodics(i)) );        
    end
    np = np + model.n.nper;


    %   Displacement terms

    model.n.ndisp = length(model.disp);
    if ( model.n.ndisp > 0 )
        model.t.td = model.disp(:) - model.t_ep;

        for i = 1:model.n.ndisp
            parlist(np+i,:) = padstr( sprintf('disp_%8.3f', model.disp(i)) );
        end
        np = np + model.n.ndisp;
    end

    %   Logarithmic terms

    model.n.nlogs = size(model.logs,2);
    if ( model.n.nlogs > 0 )
        model.t.tl    = model.logs(1,:) - model.t_ep;
        model.tau.ltau  = model.logs(2,:);

        for i = 1:model.n.nlogs
            parlist(np+i,:) = padstr( sprintf('log %8.3f %6.3f', model.logs(1,i), model.tau.ltau(i)) );
        end
        np = np + model.n.nlogs;
    end

    %   Exponential terms

    model.n.nexp = size(model.exponentials,2);
    if ( model.n.nexp > 0 )
        model.t.te     = model.exponentials(1,:) - model.t_ep;
        model.tau.etau = model.exponentials(2,:);

        for i = 1:model.n.nexp
            parlist(np+i,:)   = padstr( sprintf('exp %8.3f %6.3f', model.exponentials(1,i), model.tau.etau(i)) );
        end
        np = np + model.n.nexp;
    end


    %   Hyperbolic tangent terms

    model.n.ntanhs = size(model.tanhs,2); 
    if ( model.n.ntanhs > 0 )
        model.t.tth    = model.tanhs(1,:) - model.t_ep;
        model.tau.thtau  = model.tanhs(2,:);

        for i = 1:model.n.ntanhs
            parlist(np+i,:)   = padstr( sprintf('tanh %8.3f %6.3f', model.tanhs(1,i), model.tau.thtau(i)) );
        end
        np = np + model.n.ntanhs;
    end

    % Make the final list of parameters

    pref      = repmat('e_', np, 1);
    parlist_e = [ pref parlist ];
    pref      = repmat('n_', np, 1);
    parlist_n = [ pref parlist ];
    pref      = repmat('u_', np, 1);
    parlist_u = [ pref parlist ];

    model.parlist   = [parlist_e; parlist_n; parlist_u];
    model.np = np;
    
return

%%
%

function out = model_copy(in);

    out   = new_model_struct;
    names = fieldnames(out);
    n_nam = length(names);

    hasfield = isfield(in, names);

    for i = 1:n_nam,
        if ( hasfield(i) )
           out.(names{i}) = in.(names{i});
        end
    end

return

%%
%
function G = make_g(times, model)

%  Construct the Greens function matrix to compute the model. We use the
%  same matrix whether we are going to estimate the model parameters or
%  apply them. We'll do this in parts for each parameter group, and
%  concatenate them as we go. First we make the matrix appropriate for a
%  single component, and then ue that to make the matrix for all 3 comps.

    nt = length(times);

    G0 = zeros(nt, model.np);

    %  Linear terms: a + b*t

    G0(:, 1:2) = [ones(size(times)) times ];
    ip         = 2;


    %  Periodic terms: sin(2*pi*t/per) + cos(2*pi*t/per)
    %    The frequency in cycles per year is passed to the function

    if ( model.n.nper > 0 )

        arguments = 2*pi*times*model.periodics;

        %   Cosine terms come first, then sine terms

        G0(:, ip+1:ip+2*model.n.nper) = [ cos(arguments) sin(arguments) ];
        ip  = ip + 2*model.n.nper;

    end



    %  Displacement terms: H(t - td)
    %    The times of displacement events are passed to the function

    if ( model.n.ndisp > 0 )

        %   Should be able to remove this for loop:
        for i = 1:model.n.ndisp
            G0(:, ip+i) = heaviside(times, model.t.td(i));
        end

        ip  = ip + model.n.ndisp;

    end


    %  Logarithmic terms: H(t - tl)*log(1 + (t-tl)/ltau)
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nlogs > 0 )

        %   May be able to remove this for loop
        for i = 1:model.n.nlogs
            heav        = heaviside(times, model.t.tl(i));
            G0(:, ip+i) = heav.*log( 1 + (times-model.t.tl(i))/model.tau.ltau(i) );
        end

        ip  = ip + model.n.nlogs;

    end



    %  Exponential terms: H(t - te)*(1 - exp(-(t-te)/etau))
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nexp > 0 )

        %   May be able to remove this for loop
        for i = 1:model.n.nexp
            heav        = heaviside(times, model.t.te(i));
            G0(:, ip+i) = heav.*(1 - exp(-(times-model.t.te(i))/model.tau.etau(i)));
        end

        ip  = ip + model.n.nlogs;

    end

    %  Hyperbolic tangent terms: 0.5*( 1 + tanh( (t-tth)/thtau ) )
    %    The start time and the characteristic time are passed to the function

    if ( model.n.ntanhs > 0 )

        %   May be able to remove this for loop
        for i = 1:model.n.ntanhs
            G0(:, ip+i) = 0.5*( 1 + tanh( (times-model.t.tth(i))/model.tau.thtau(i) ) );
        end

        ip  = ip + model.n.ntanhs;

    end


    %
    %   Set up the full matrix
    %

    o0 = zeros(size(G0));
    G       = [G0 o0 o0 ; o0 G0 o0; o0 o0 G0];

return
