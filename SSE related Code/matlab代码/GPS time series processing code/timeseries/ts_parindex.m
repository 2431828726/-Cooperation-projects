function paridx = ts_parindex(varargin)
%function paridx = ts_paramname(parlist, comp, type, num1, num2)
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


%  Sort out the inoput arguments

parlist = varargin{1};
comp    = varargin{2}; 
type    = varargin{3}; 

if ( length(varargin) == 3 )
    num1 = 0;
    num2 = 0;
elseif ( length(varargin) == 4 )
    num1 = varargin{4}; 
    num2 = 0;
else
    num1 = varargin{4}; 
    num2 = varargin{5};
end

% Start out with just underscores

switch ( type )
    
    case {'bias', 'rate'}
        parname = padstr([comp '_' type]);
        
    case {'cos', 'sin'}
        parname = padstr( sprintf('%s_%7.2f/yr', [comp '_' type], num1) );
        
    case {'disp', 'deltav'}
        parname = padstr( sprintf('%s %8.3f', [comp '_' type], num1) );
        
    case {'log', 'exp', 'tanh'}
        parname = padstr( sprintf('%s_%8.3f_%6.3f', [comp '_' type], num1, num2) );

end

paridx = strmatch(parname, parlist);

return

%%
%  Internal function

function string = padstr(instr)

s      = sprintf('%-24s', instr);
string = regexprep(s, ' ', '_');

return
