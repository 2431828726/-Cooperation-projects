function write_seasonal_file(filename, seasonal)
%function write_seasonal_file(filename, seasonal)
%
%  Write the seasonal data structure seasonal to the file filename
%

nbins = length(seasonal.bintime);
output = zeros(nbins,5);
for i = 1:nbins,
    output(i,:) = [ seasonal.bintime(i)-seasonal.binsize/2, seasonal.bintime(i)+seasonal.binsize/2, ...
              seasonal.east.smooth(i), seasonal.north.smooth(i), seasonal.height.smooth(i) ];
end
save(filename, '-ascii', 'output');

return