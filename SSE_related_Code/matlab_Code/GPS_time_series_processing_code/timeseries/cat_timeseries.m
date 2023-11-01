function outser = cat_timeseries(ser1, ser2);
%function outser = cat_timeseries(ser1, ser2)
% Concatenates two time series. At the moment it makes no checks for
% consistency, overlaps, etc.

outser = struct('time', [], 'sitename', [], 'refllh', [], 'refxyz', [], 'llh', [], ...
    'east', [], 'esig', [], 'north', [], 'nsig', [], 'height', [], 'hsig', ...
    [], 'enu', [], 'enucov', []);

outser.sitename = ser1.sitename;
outser.refllh   = ser1.refllh;
outser.refxyz   = ser1.refxyz;

outser.time     = [ser1.time;   ser2.time];
outser.llh      = [ser1.llh;    ser2.llh];
outser.east     = [ser1.east;   ser2.east];
outser.esig     = [ser1.esig;   ser2.esig];
outser.north    = [ser1.north;  ser2.north];
outser.nsig     = [ser1.nsig;   ser2.nsig];
outser.height   = [ser1.height; ser2.height];
outser.hsig     = [ser1.hsig;   ser2.hsig];
outser.enu      = [ser1.enu;    ser2.enu];
outser.enucov   = [ser1.enucov; ser2.enucov];