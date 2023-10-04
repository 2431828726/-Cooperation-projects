function outser = ts_rotate(inser, x123axes, x123names);
%function outser = ts_rotate(inser, x123axes, x123names)
% Rotates a timeseries from (east, north, up) to another arbitrary
% system defined by the column vectors of x123axes. Each column of x123
% axes should be a unit vector defining the coordinate axes *x1, x2, x3),
% with the definition being in the enu system. The vectors of x123 do not
% need to be normalized as the code will do this automaticaly.
%
% If the argument x123names is passed, it should be a 3 element cell array
% with the names of the coordinate axes, for example: {'radial',
% 'transverse', vertical'};
%

if ( nargin < 3 )
    x123names = { [], [], []};
end

outser = inser;

for i = 1:3
   x123axes(:,i) =  x123axes(:,i)/norm( x123axes(:,i) );
end

outser.x123axes  = x123axes;
outser.x123      = zeros( size(inser.enu) );
outser.x123cov   = cell( 1, length(inser.enucov) );
outser.x123names = x123names;

% The computation is quite simple. The transpose of x123axes is exactly the
% transformation matrix needed to rotate enu to the new system, if we take
% the vectors one at a time. We need to do this for speed anyway, as the
% number of points in the timeseries may become quite large

outser.x123 = x123axes'*inser.enu;

n = size(outser.enu, 2);
if ( ~isempty(inser.enucov) )
    for i = 1:n
        cov = inser.enucov{i};
        outser.x123cov{i} = x123axes'*cov*x123axes;
    end
end