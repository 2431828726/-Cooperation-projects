function [val sig] = ts_parval(model, comp, varargin)
%function [val sig] = ts_parval(model, comp, type, num1, num2)
%
%Extracts a parameter value and its sigma from an estimated model
% Generates parameter names for tsfit. Comp specificis component (e, n, u).
% Arguments num1 and num2 are optional and depend on the type.
% Defined types with their additional arguments are:
%      bias
%      rate
%      cos cycles/year
%      sin cycles/year
%      disp date
%      deltav date
%      log date tau
%      exp date tau
%      tanh center_date tau
if ( length(varargin) == 1 )
   idx = ts_parindex(model.parlist, comp, varargin{1});
elseif ( length(varargin) == 2 )
   idx = ts_parindex(model.parlist, comp, varargin{1}, varargin{2});
elseif ( length(varargin) == 3 )
   idx = ts_parindex(model.parlist, comp, varargin{1}, varargin{2}, varargin{3});
else
    idx = [];
end    

if ( ~isempty(idx) )
    val = model.parval(idx);
    sig = sqrt(model.parcov(idx,idx));
else
    val = [];
    sig = [];
end