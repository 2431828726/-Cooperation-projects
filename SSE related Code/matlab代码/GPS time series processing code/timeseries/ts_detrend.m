function subtracted = ts_detrend(varargin)
%function subtracted = ts_detrend(data)
%function subtracted = ts_detrend(data, model)
%
%  Detrend a timeseries. If a model struct is specified, then the model
%  parameters as defined in that model will be used. Otherwise, a
%  linear-only model will be used

switch nargin
    case 1
        data  = varargin{1};
        model = new_tsmodel;
        
    case 2
        data  = varargin{1};
        model = varargin{2};
end

[predict, resids, chi2dof, estmod] = tsfit(data, model);

% Set all estimated parameters to zero except the bias and rate

idx = [1, 2, estmod.np+1, estmod.np+2, 2*estmod.np+1, 2*estmod.np+2];
temp = zeros( size(estmod.parval) );
temp(idx) = estmod.parval(idx);
estmod.parval = temp;

subtracted = ts_subtract_model(data, estmod);

%j  = ts_parindex(estmod.parlist, 'e', 'bias');
%temp(j) = estmod.parval(j);
%j  = ts_parindex(estmod.parlist, 'n', 'bias');
%temp(j) = estmod.parval(j);
%j  = ts_parindex(estmod.parlist, 'u', 'bias');
%temp(j) = estmod.parval(j);
%j  = ts_parindex(estmod.parlist, 'e', 'rate');
%temp(j) = estmod.parval(j);
%j  = ts_parindex(estmod.parlist, 'n', 'rate');
%temp(j) = estmod.parval(j);
%j  = ts_parindex(estmod.parlist, 'u', 'rate');
%temp(j) = estmod.parval(j);
