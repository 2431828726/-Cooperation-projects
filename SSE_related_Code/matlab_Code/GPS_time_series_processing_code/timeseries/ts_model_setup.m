%%
%

function model = ts_model_setup(in, type)
%
%  argument type can be 'displacement', 'velocity', 'acceleration'
%
%  Does the model setup steps:
%      Fill in values of counter variables and time and timescale variables
%      Construct the parameter list. Set up a list with component 'X', and
%      then replace X with 'e', 'n', and 'u'

    if ( nargin < 2 )
        type = 'displacement';
    end

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
            G0(:, ip+i) = heavisidejf(times, model.t.td(i));
        end

        ip  = ip + model.n.ndisp;

    end



    %  Delta-v terms: H(t - td)*t
    %    The times of delta-v events are passed to the function

    if ( model.n.ndeltav > 0 )
        
        %   Should be able to remove this for loop:
        for i = 1:model.n.ndeltav
            G0(:, ip+i) = (times - model.t.tdeltav(i)).*heavisidejf(times, model.t.tdeltav(i));
        end

        ip  = ip + model.n.ndisp;

    end


    %  Logarithmic terms: H(t - tl)*log(1 + (t-tl)/ltau)
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nlogs > 0 )

        %   May be able to remove this for loop
        for i = 1:model.n.nlogs
            heav        = heavisidejf(times, model.t.tl(i));
            G0(:, ip+i) = heav.*log( 1 + (times-model.t.tl(i))/model.tau.ltau(i) );
        end

        ip  = ip + model.n.nlogs;

    end



    %  Exponential terms: H(t - te)*(1 - exp(-(t-te)/etau))
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nexp > 0 )

        %   May be able to remove this for loop
        for i = 1:model.n.nexp
            heav        = heavisidejf(times, model.t.te(i));
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
