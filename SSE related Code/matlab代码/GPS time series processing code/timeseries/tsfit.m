function [varargout] = tsfit(varargin)
%function [predict, resids, chi2dof, model, G] = tsfit(data, model, apriori);
%
%or
%
%function [predict, sigmas] = tsfit(time, model);

%% Major changes (starting June 2013)
%
% June 25, 2013, JTF: Internal changes to parameter names, parlist is now a cell array
%
% June 25, 2013, JTF: Add option of a priori information via an apriori struct.
%
% some time in 2015, JTF: Improved handling of sparse vs full covariance
%
% Sept. 1, 2016, JTF: Replace call to make_g with a more general routine
% that makes the G matrix for displacements, velocities or accelerations.

%%
% Parse out the input arguments
%

if ( nargin < 2 )
   
    error('tsfit: Not enough input arguments');
    
end

model = varargin{2};

if ( nargin > 2 )
    apriori = varargin{3};
else
    apriori = [];
end

%
%    Figure out which version of the input arguments we have. The first
%    argument must be either a timeseries data structure, or an array of
%    times. While doing so, keep track of the number of model parameters.
%
 

if ( isstruct( varargin{1}) )
    
    % tsfit(data, model);
    % We are given a data structure and need to fit the data.
    % Contstruct the parameters list and do other one-time-only
    % bookkeeping.
    
    fitmodel = 1;
    
    data = varargin{1};
    
    if ( isempty(model.t_ep) || model.t_ep == 0 )
        model.t_ep = round(mean(data.time));
    end
    times = data.time - model.t_ep;
    
    model = model_setup(model);
    
    % Set up apriori information if there is some
    % apdiag is an approximation of the diagonal of the a priori covariance
    
    dapr = zeros(model.np*3,1);
    Wapr = zeros(model.np*3);

    
    if ( ~isempty(apriori) ) 
        if ( length(apriori.apname) > 0 )
            for i = 1:length(apriori.apname)
                paridx = strmatch(apriori.apname{i}, model.parlist);
                dapr(paridx) = apriori.apval(i);
                Wapr(paridx,paridx) = 1/apriori.apsig(i)^2;
            end
        end
    end
    apdiag = 1./(10^-10 + diag(Wapr));

else
    
    % tsfit(times, model);
    % We are given an array of times and previously computed model, and
    % need to use the model to predict the model at the provided times.

    fitmodel = 0;
    
    times = varargin{1} - model.t_ep;
    times = times(:);

end

%%
%  Construct the Greens function matrix to compute the model. 

G = ts_make_g(times, model);



%%
%   Estimate the model (if modelfit is true), and return values.
%

if ( fitmodel )
    
    d = [data.east ; data.north ; data.height ];
    
    if ( hasfullcov(data) )
        % Use the pre-stored covariance matrix Cd and weight matrix W
        
        Cd = data.Cd;
        W = data.W;

    else
        % Construct the covariance matrix Cd and weight matrix W from the sigmas
        
        % Sparse matrix optimizations for uncorrelated data
        % Cd is data covariance matrix
        % W  is weight matrix, inverse of covariance
        % L  is cholesky decomp of weight matrix
        sigs = [ data.esig ; data.nsig ; data.hsig ];
        n = size(sigs);

        Cd = sparse(1:n, 1:n, sigs.^2);
        W  = sparse(1:n, 1:n, 1./sigs.^2);
        %L = sparse(1:n, 1:n, 1./sigs);
        %Lap = sqrt(Wapr);
        
    end
    
    model.parval = (Wapr + G'*W*G)\(Wapr*dapr + G'*W*d);
    
    % Model covariance without a priori information
    %a = (G'*W*G)\G'*W;
    %model.parcov = a*sparse(1:n, 1:n, sigs.^2)*a';
    
    A = (Wapr + G'*W*G)\[G'*W , Wapr];
 %        model.parcov = A*sparse(1:(n+3*model.np), 1:(n+3*model.np), [sigs.^2; apdiag]')*A';
    model.parcov = A*blkdiag(Cd, diag(apdiag))*A';
    
    predict = G*model.parval;
    resids  = d - predict;
    chi2    = resids'*W*resids;
    dof     = length(d) - size(G,2);
    chi2dof = chi2/dof;
    
    model.parval  = model.parval';
    if ( ~isinf(chi2dof) )
       model.parcov  = model.parcov*chi2dof;
    end
                
    varargout = cell(5,1);
    varargout{1} = predict;
    varargout{2} = resids;
    varargout{3} = chi2dof;
    varargout{4} = model;
    varargout{5} = G;

else
    %  Evaluate the model
    
    %save G
    
    predict = G*model.parval';

    varargout    = cell(1,1);
    varargout{1} = predict(:);
    
    if ( nargout > 1 )
        %  Compute sigmas
        
        covout = G*model.parcov*G';
        varargout{2} = sqrt(diag(covout));
        
    end
    
end

return

%%
%

function model = model_setup(in)

%  Does the model setup steps:
%      Fill in values of counter variables and time and timescale variables
%      Construct the parameter list. Set up a list with component 'X', and
%      then replace X with 'e', 'n', and 'u'

    model = model_copy(in);
    
    %   Bias and rate terms assumed
    
    parlist = { ts_paramname('X', 'bias'); ts_paramname('X', 'rate') };
    np      = 2;

    %   Periodic terms

    model.n.nper = length(model.periodics);
    for i = 1:model.n.nper
        parlist{np+i} = ts_paramname('X', 'cos', model.periodics(i));
    end
    np = np + model.n.nper;

    for i = 1:model.n.nper
        parlist{np+i} = ts_paramname('X', 'sin', model.periodics(i));        
    end
    np = np + model.n.nper;


    %   Displacement terms

    model.n.ndisp = length(model.disp);
    if ( model.n.ndisp > 0 )
        model.t.td = model.disp(:) - model.t_ep;

        for i = 1:model.n.ndisp
            parlist{np+i} = ts_paramname('X', 'disp', model.disp(i));
        end
        np = np + model.n.ndisp;
    end

    
    %   Delta-v terms
    %       change in velocity

    model.n.ndeltav = length(model.deltav);
    if ( model.n.ndeltav > 0 )
        model.t.tdeltav = model.deltav(:) - model.t_ep;

        for i = 1:model.n.ndeltav
            parlist{np+i} = ts_paramname('X', 'deltav', model.deltav(i));
        end
        np = np + model.n.ndeltav;
    end

    %   Logarithmic terms

    model.n.nlogs = size(model.logs,2);
    if ( model.n.nlogs > 0 )
        model.t.tl    = model.logs(1,:) - model.t_ep;
        model.tau.ltau  = model.logs(2,:);

        for i = 1:model.n.nlogs
            parlist{np+i} = ts_paramname('X', 'log', model.logs(1,i), model.tau.ltau(i));
        end
        np = np + model.n.nlogs;
    end

    %   Exponential terms

    model.n.nexp = size(model.exponentials,2);
    if ( model.n.nexp > 0 )
        model.t.te     = model.exponentials(1,:) - model.t_ep;
        model.tau.etau = model.exponentials(2,:);

        for i = 1:model.n.nexp
            parlist{np+i}   = ts_paramname('X', 'exp', model.exponentials(1,i), model.tau.etau(i));
        end
        np = np + model.n.nexp;
    end


    %   Hyperbolic tangent terms

    model.n.ntanhs = size(model.tanhs,2); 
    if ( model.n.ntanhs > 0 )
        model.t.tth    = model.tanhs(1,:) - model.t_ep;
        model.tau.thtau  = model.tanhs(2,:);

        for i = 1:model.n.ntanhs
            parlist{np+i}   = ts_paramname('X', 'tanh', model.tanhs(1,i), model.tau.thtau(i));
        end
        np = np + model.n.ntanhs;
    end

    % Make the final list of parameters

    parlist_e = regexprep(parlist, 'X', 'e');
    parlist_n = regexprep(parlist, 'X', 'n');
    parlist_u = regexprep(parlist, 'X', 'u');

    model.parlist   = [ parlist_e; parlist_n; parlist_u ];
    model.np = np;
    
return

%%
%

function out = model_copy(in)

    out   = new_tsmodel;
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

function hv = heavisidejf(ts, t);
%function hv = heavisidejf(ts, t);
% Returns 0 if ts <= t, 1 otherwise
% If t is a vector, then hv will be a matrix. The times within the matrix
% will be either on the rows or columns, depending on whether ts is a row
% or column vector, but in any case will match ts.

%  Get the size of the input array. It is an error if both n and m are >1

[n m] = size(ts);

if ( n > 1 & m > 1 )
    error('heavisidejf: input times ts must be either a row or column vector');
end

%  To simplify the code, make ts a row vector and t a column. Then allocate
%  the output matrix.

ts = ts(:)';
t = t(:);
nt = length(t);

hv = zeros(nt, length(ts));


for i = 1:nt

   hv(i,:) = (ts >= t(i));

end

%  Finally, transpose the output matrix if ts was given as a column vector

if ( n > m )
    hv = hv';
end

return

function boolean = hasfullcov(data)
%function boolean = hasfullcov(data)
% Determines if the data structure already has a pre-stored full covariance
% matrix and weight matrix

boolean = 0;

if ( isfield(data, 'Cd') && isfield(data, 'W') )
   boolean = ( ~isempty(data.Cd) && ~isempty(data.W) );
end

return


