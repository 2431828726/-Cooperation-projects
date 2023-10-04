function seasonal = read_seasonal_file(filename)
%function write_seasonal_file(filename, seasonal)
%
%  Read the seasonal data structure seasonal from the file filename
%
dummy = struct('binval', [], 'smooth', []);

seasonal = struct( 'bintime', [], 'binsize', [], 'east', dummy, 'north', dummy, 'height', dummy);

input = load(filename, '-ascii');

nbins = size(input,1);

seasonal.binsize = input(1,2) - input(1,1);
seasonal.bintime = (input(:,2) + input(:,1))/2;

seasonal.east.smooth    = input(:,3);
seasonal.north.smooth   = input(:,4);
seasonal.height.smooth  = input(:,5);

seasonal.east.binval    = input(:,3);
seasonal.north.binval   = input(:,4);
seasonal.height.binval  = input(:,5);

return