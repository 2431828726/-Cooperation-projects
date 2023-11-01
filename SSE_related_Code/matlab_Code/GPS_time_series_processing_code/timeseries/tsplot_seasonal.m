function [hfig1, hfig2] = tsplot_seasonal(timeseries, seasonal, component, plot_limit)
%

comp = lower(component);

fracdate = timeseries.time - fix(timeseries.time);
tval     = getfield(timeseries, comp)*1000;

bin_t   = seasonal.bintime;
nbin    = length(bin_t);

temp = getfield(seasonal, comp);
bin_val = temp.binval*1000;
bin_sm  = temp.smooth*1000;

hfig1 = figure;
plot(fracdate, tval, 'b.');
hold on;
plot([bin_t(nbin)-1, bin_t, bin_t(1)+1], [bin_sm(nbin), bin_sm', bin_sm(1)], 'r-', 'LineWidth', 4);
plot([bin_t(nbin)-1, bin_t, bin_t(1)+1], [bin_val(nbin), bin_val', bin_val(1)], 'k-', 'LineWidth', 2);
axis([0.0 1.00 -plot_limit plot_limit]);
set(gca, 'FontSize', 12)
xlabel('Year', 'FontSize', 14, 'FontWeight', 'Bold');
ylabel(strcat(component, ' (mm)'), 'FontSize', 14, 'FontWeight', 'Bold');
title( [timeseries.sitename ' Seasonal average resid'], 'FontSize', 14, 'FontWeight', 'Bold');

% Now subtract the average correction from the original data

modval = ts_eval_seasonal(timeseries.time, seasonal, comp)*1000;

%   updated to current syntax for smooth, 5/1/2013
weekly = smooth(tval, 7);
weekly_corr = smooth(tval-modval, 7);
weekly_t = smooth(timeseries.time, 7);

hfig2 = figure;

% top panel: data and model

h = subplot(2,1,1);
plot(timeseries.time, tval, 'b.', 'MarkerSize', 10);
hold on
plot(weekly_t, weekly, 'r.', 'MarkerSize', 20);
plot(timeseries.time, modval, 'k-', 'LineWidth', 3);
title( [timeseries.sitename ' ' component], 'FontSize', 14, 'FontWeight', 'Bold');
axis([floor(min(timeseries.time)) ceil(max(timeseries.time)) -plot_limit plot_limit]);
set(gca, 'FontSize', 12)
xlabel('Year', 'FontSize', 14);
ylabel('De-trended (mm)', 'FontSize', 14);

% bottom panel: data minus model

h = subplot(2,1,2);
plot(timeseries.time, tval-modval, 'b.', 'MarkerSize', 10);
hold on
plot(weekly_t, weekly_corr, 'r.', 'MarkerSize', 20);
axis([floor(min(timeseries.time)) ceil(max(timeseries.time)) -plot_limit plot_limit]);
set(gca, 'FontSize', 12)
xlabel('Year', 'FontSize', 14);
ylabel('Residual (mm)', 'FontSize', 14);

return
