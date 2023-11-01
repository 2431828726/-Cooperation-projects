function subtracted = ts_subtract_model(data, model)
%function subtracted = ts_subtract_model(data, model)
%
%  Subtracts the model with parameters in 'model' from the timeseries
%  'data'. The model is subtracted from the timeseries values stored in the
%  elements 'east', 'north', 'height', from the copy stored in 'enu', and if
%  the element 'x123axes' is not empty, from the transformed version stored
%  in 'x123'.


% Copy over the data in the structure. We will replace the elements as
% needed.

subtracted = data;

% Evaluate the model at the times of the data

modelval = tsfit(data.time, model);
modelenu = reshape(modelval, [], 3)';


% Subtract the model predictions from the data values in 'east', 'north',
% 'height'

subtracted.east   = data.east   - modelenu(1,:)';
subtracted.north  = data.north  - modelenu(2,:)';
subtracted.height = data.height - modelenu(3,:)';


% Subtract the model from the data values in 'enu'

subtracted.enu    = data.enu - modelenu;

% Convert the model to xyz and store revised xyz and llh values
%   enu2xyz assumes input is vector stored

xyzmod = repmat(data.refxyz, length(data.time), 1) + enu2xyz(data.refllh, subtracted.enu(:));
subtracted.llh = xyz2llh(reshape(xyzmod, 3, []));


% If there is a transformed version in 'x123', subtract model from that as
% well (after rotation)

if ( ~isempty( data.x123axes ) )
   subtracted.x123 = data.x123 - x123axes'*modelenu; 
end