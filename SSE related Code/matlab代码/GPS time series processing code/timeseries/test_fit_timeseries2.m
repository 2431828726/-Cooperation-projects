
pdir = '/gps/data/alaska2.5_timeseries/';

colors = ['b' 'g' 'r' 'c' 'm' 'y'];
ncolors = length(colors);

site = 'GRNR';
file = strcat(pdir, site, '.pfiles')

sigtol = [7; 7; 12];

data = read_timeseries(file, sigtol);

periodics    = [];
%periodics    = [1 2 365/13.7];

%periodics    = [1 2];
disp         = [2002.843];
%disp         = [];
logs         = [2002.843; 0.05];
exponentials = [2002.843; 3.0];

[predict, resids, model] = fit_timeseries(data, periodics, disp, logs, exponentials);

%a    = reshape(predict, [], 3);
%emod = a(:,1);
%nmod = a(:,2);
%hmod = a(:,3);
%h    = tsplot_1station(data, data.time, emod, nmod, hmod, [], [], model.disp);

[model.parlist(1,:) ':  ' num2str(1000*model.parval(1)) ' +/- ' num2str(1000*sqrt(model.parcov(1,1))) ' mm']
[model.parlist(2,:) ':  ' num2str(1000*model.parval(2)) ' +/- ' num2str(1000*sqrt(model.parcov(2,2)))  ' mm/yr']

%if  ( model.np > 3 )
%    for i = 3:model.np
%        [model.parlist(i,:) ':  ' num2str(1000*model.parval(i)) ' +/- ' num2str(1000*sqrt(model.parcov(i,i)))  ' mm']
%    end
%end

mint = min(data.time);
maxt = max(data.time);

modeltimes = [linspace(mint, 2002.842, 100) linspace(2002.844, maxt, 100)]';
modelval = fit_timeseries(modeltimes, model);

a   = reshape(modelval, [], 3);
emod = a(:,1);
nmod = a(:,2);
hmod = a(:,3);

h = tsplot_1station(data, modeltimes, emod, nmod, hmod, [], [], model.disp);

%   Then plot de-trended data

np = model.np;
velo = [ model.parval(2)*modeltimes ; model.parval(np+2)*modeltimes ; model.parval(2*np+2)*modeltimes ];

data_detrend = data;

data_detrend.east   = data_detrend.east   - model.parval(2)*data.time;
data_detrend.north  = data_detrend.north  - model.parval(np+2)*data.time;
data_detrend.height = data_detrend.height - model.parval(2*np+2)*data.time;

a   = reshape(modelval-velo, [], 3);
emod = a(:,1);
nmod = a(:,2);
hmod = a(:,3);


h = tsplot_1station(data_detrend, modeltimes, emod, nmod, hmod, [], [], model.disp);

