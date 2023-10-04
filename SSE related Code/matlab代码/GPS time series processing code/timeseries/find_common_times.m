function [tcom, idxcom1, idxcom2] = find_common_times(t1, t2)
%
%function [tcom, idxcom1, idxcom2] = find_common_times(t1, t2)
%
%Find the common times from two arrays t1 and t2. The returned values are:
%   tcom     array of common times
%   idxcom1  array of indices for array t1 for each common time
%   idxcom2  array of indices for array t2 for each common time
%

%Pre-allocate arrays for efficiency; we will shrink to size later. The
%maximum size is the size of the smaller of the two arrays

if (length(t1) < length(t2))
    tcom    = zeros(size(t1));
    idxcom1 = zeros(size(t1));
    idxcom2 = zeros(size(t1));
else
    tcom    = zeros(size(t2));
    idxcom1 = zeros(size(t2));
    idxcom2 = zeros(size(t2));
end

j = 0;
for i = 1:length(t1)
   
    idx = find( (t1(i) == t2) );
    if ( ~isempty(idx) )
        j = j + 1;
        tcom(j) = t1(i);
        idxcom1(j) = i;
        idxcom2(j) = idx(1);  % workaround to deal with duplicate times
    end 
    
end

% Re-size the arrays to actual size

if ( j == 0 )
    tcom    = [];
    idxcom1 = [];
    idxcom2 = [];
else 
    tcom    = tcom(1:j);
    idxcom1 = idxcom1(1:j);
    idxcom2 = idxcom2(1:j);
end

return
