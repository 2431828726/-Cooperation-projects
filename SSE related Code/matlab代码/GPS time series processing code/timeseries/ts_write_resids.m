function ts_write_resids(outfilename, model)
%function ts_write_resids(model)
%  Write the residuals to a file for use with the HECTOR program
%  HECTOR expects time in decimal year, all other values in millimeters
%
% input is
%      outfilename  name of output file
%      model        structure created within velocity_fit


% re-scale nmbers so that all units are millimeters

model.resids    = model.resids*1000;
model.data.esig = model.data.esig*1000;
model.data.nsig = model.data.nsig*1000;
model.data.hsig = model.data.hsig*1000;

%%
% create an array where each column is one row of ouptut

% Reshape the resids array to separate east, north, up
enuresids = reshape(model.resids, [], 3);

A = [ model.data.time' ; ...
      enuresids(:,2)' ; enuresids(:,1)' ; enuresids(:,3)' ; ...
      model.data.nsig' ; model.data.esig' ; model.data.hsig' ];

%%
%  open the file and write it

fid = fopen(outfilename, 'w');
format = '%10.5f %9.2f %9.2f %9.2f %5.1f %5.1f %5.1f\n';
fprintf(fid, format, A);
fclose(fid);

return
