function outmodel = ts_add_model_element(inmodel, field, values)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

outmodel = inmodel;

if ( isempty(outmodel.(field)) )
    outmodel.(field) = values;
else
   [~, m] = size(outmodel.(field));
   outmodel.(field)(:,m+1) = values;
end
    
return

