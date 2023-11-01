%%
%
function G = ts_make_g(times, model, type)
%
%  argument type can be 'displacement', 'velocity', 'acceleration'
%
%  Construct the Greens function matrix to compute the model. We use the
%  same matrix whether we are going to estimate the model parameters or
%  apply them. We'll do this in parts for each parameter group, and
%  concatenate them as we go. First we make the matrix appropriate for a
%  single component, and then ue that to make the matrix for all 3 comps.


    if ( nargin < 3 )
        type = 'displacement';
    end

    nt = length(times);

    G0 = zeros(nt, model.np);

    %  Linear terms: a + b*t

    switch ( type )
        case 'displacement'
            G0(:, 1:2) = [ones(size(times)) times ];
        case 'velocity'
            G0(:, 1:2) = [zeros(size(times)) ones(size(times)) ];
        case 'acceleration'
            G0(:, 1:2) = [zeros(size(times)) zeros(size(times)) ];
    end
    ip         = 2;


    %  Periodic terms: sin(2*pi*t/per) + cos(2*pi*t/per)
    %    The frequency in cycles per year is passed to the function

    if ( model.n.nper > 0 )

        arguments = 2*pi*times*model.periodics;

        %   Cosine terms come first, then sine terms
        switch ( type )
            case 'displacement'
                G0(:, ip+1:ip+2*model.n.nper) = [ cos(arguments) sin(arguments) ];
            case 'velocity'
                for i = 1:model.n.nper
                   G0(:, ip+2*(i-1)+1:ip+2*(i-1)+2) = (2*pi*model.periodics(i))*[ -sin(arguments(:,i)) cos(arguments(:,i)) ];
                end
            case 'acceleration'
                for i = 1:model.n.nper
                   G0(:, ip+2*(i-1)+1:ip+2*(i-1)+2) = (2*pi*model.periodics(i))^2*[ -cos(arguments(:,i)) -sin(arguments(:,i)) ];
                end
        end
       ip  = ip + 2*model.n.nper;

    end



    %  Displacement terms: H(t - td)
    %    The times of displacement events are passed to the function

    if ( model.n.ndisp > 0 )

        switch ( type )
            case 'displacement'
            %   Should be able to remove this for loop:
                for i = 1:model.n.ndisp
                    G0(:, ip+i) = heavisidejf(times, model.t.td(i));
                end
            case 'velocity'
            %   Should be able to remove this for loop:
                for i = 1:model.n.ndisp
                    G0(:, ip+i) = zeros(size(times));
                end
            case 'acceleration'
            %   Should be able to remove this for loop:
                for i = 1:model.n.ndisp
                    G0(:, ip+i) = zeros(size(times));
                end
        end

        ip  = ip + model.n.ndisp;

    end



    %  Delta-v terms: H(t - td)*deltav*t
    %    The times of delta-v events are passed to the function

    if ( model.n.ndeltav > 0 )
        
      switch ( type )
        case 'displacement'
          %   Should be able to remove this for loop:
            for i = 1:model.n.ndeltav
                G0(:, ip+i) = (times - model.t.tdeltav(i)).*heavisidejf(times, model.t.tdeltav(i));
            end
        case 'velocity'
          %   Should be able to remove this for loop:
            for i = 1:model.n.ndeltav
                G0(:, ip+i) = (ones(size(times))).*heavisidejf(times, model.t.tdeltav(i));
            end
        case 'acceleration'
          %   Should be able to remove this for loop:
            for i = 1:model.n.ndeltav
                G0(:, ip+i) = zeros(size(times));
            end
      end

        ip  = ip + model.n.ndisp;

    end


    %  Logarithmic terms: H(t - tl)*log(1 + (t-tl)/ltau)
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nlogs > 0 )

        switch ( type )
            case 'displacement'
              %   May be able to remove this for loop
                for i = 1:model.n.nlogs
                    heav        = heavisidejf(times, model.t.tl(i));
                    G0(:, ip+i) = heav.*log( 1 + (times-model.t.tl(i))/model.tau.ltau(i) );
                end
            case 'velocity'
              %   May be able to remove this for loop
                for i = 1:model.n.nlogs
                    heav        = heavisidejf(times, model.t.tl(i));
                    G0(:, ip+i) = heav.*(1/model.tau.ltau(i))./( 1 + (times-model.t.tl(i))/model.tau.ltau(i) );
                end
            case 'acceleration'
              %   May be able to remove this for loop
                for i = 1:model.n.nlogs
                    heav        = heavisidejf(times, model.t.tl(i));
                    G0(:, ip+i) = -1*heav.*(1/model.tau.ltau(i)^2)./( 1 + (times-model.t.tl(i))/model.tau.ltau(i) ).^2;
                end
        end

        ip  = ip + model.n.nlogs;

    end



    %  Exponential terms: H(t - te)*(1 - exp(-(t-te)/etau))
    %    The start time and the relaxation time are passed to the function

    if ( model.n.nexp > 0 )

        switch ( type )
            case 'displacement'
              %   May be able to remove this for loop
                for i = 1:model.n.nexp
                    heav        = heavisidejf(times, model.t.te(i));
                    G0(:, ip+i) = heav.*(1 - exp(-(times-model.t.te(i))/model.tau.etau(i)));
                end
            case 'velocity'
              %   May be able to remove this for loop
                for i = 1:model.n.nexp
                    heav        = heavisidejf(times, model.t.te(i));
                    G0(:, ip+i) = (1/model.tau.etau(i))*heav.*exp(-(times-model.t.te(i))/model.tau.etau(i));
                end
            case 'acceleration'
              %   May be able to remove this for loop
                for i = 1:model.n.nexp
                    heav        = heavisidejf(times, model.t.te(i));
                    G0(:, ip+i) = -1*(1/model.tau.etau(i)^2)*heav.*exp(-(times-model.t.te(i))/model.tau.etau(i));
                end
        end

        ip  = ip + model.n.nlogs;

    end

    %  Hyperbolic tangent terms: 0.5*( 1 + tanh( (t-tth)/thtau ) )
    %    The start time and the characteristic time are passed to the function

    if ( model.n.ntanhs > 0 )

        switch ( type )
            case 'displacement'
               %   May be able to remove this for loop
                for i = 1:model.n.ntanhs
                    G0(:, ip+i) = 0.5*( 1 + tanh( (times-model.t.tth(i))/model.tau.thtau(i) ) );
                end
            case 'velocity'
               %   May be able to remove this for loop
                for i = 1:model.n.ntanhs
                    G0(:, ip+i) = (1/model.tau.thtau(i))*0.5*( 1 - tanh( (times-model.t.tth(i))/model.tau.thtau(i) ).^2 );
                end
            case 'acceleration'
               %   May be able to remove this for loop
                for i = 1:model.n.ntanhs
                    G0(:, ip+i) = -1*(1/model.tau.thtau(i)^2)*tanh( (times-model.t.tth(i))/model.tau.thtau(i) ).*( 1 - tanh( (times-model.t.tth(i))/model.tau.thtau(i) ).^2 );
                end
        end

        ip  = ip + model.n.ntanhs;

    end


    %
    %   Set up the full matrix
    %

    o0 = zeros(size(G0));
    G       = [G0 o0 o0 ; o0 G0 o0; o0 o0 G0];

return

function hv = heavisidejf(ts, t)
%function hv = heavisidejf(ts, t);
% Returns 0 if ts <= t, 1 otherwise
% If t is a vector, then hv will be a matrix. The times within the matrix
% will be either on the rows or columns, depending on whether ts is a row
% or column vector, but in any case will match ts.

%  Get the size of the input array. It is an error if both n and m are >1

[n m] = size(ts);

if ( n > 1 && m > 1 )
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