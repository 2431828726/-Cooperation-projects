function npoints = plot_ts(sta1, sta2, baselen, reverse, file);
%

a = load(file);
date = a(:,2);
e = a(:,3)*10;
esig = a(:,4)*10;
n = a(:,5)*10;
nsig = a(:,6)*10;
u = a(:,7)*10;
usig = a(:,8)*10;

if ( reverse < 0 )
  e = -e;
  n = -n;
  u = -u;
  temp = sta1;
  sta1 = sta2;
  sta2 = temp;
end

% Find limits

xmax = fix(8*max(date)+1.5)/8;
xmin = fix(8*min(date)-1)/8;

emax = fix(4*max(e+esig)+2.5)/4;
emin = fix(4*min(e-esig)-2.5)/4;

nmax = fix(4*max(n+nsig)+2.5)/4;
nmin = fix(4*min(n-nsig)-2.5)/4;

umax = fix(4*max(u+usig)+2.5)/4;
umin = fix(4*min(u-usig)-2.5)/4;

ep = polyfit(date, e, 1);
np = polyfit(date, n, 1);
up = polyfit(date, u, 1);

%

figure
orient tall;

title_str = sprintf('%s relative to %s (%.2f km)', sta2, sta1, baselen);

%   EAST component

subplot(311), 
axscale = [xmin xmax emin emax];
errorbar(date, e, esig, 'kd');
title(title_str);
axis(axscale);
hold on, line(axscale(1:2), polyval(ep, axscale(1:2)), 'Color', 'k', 'LineStyle', '--');
ylabel('East (mm)');


%   NORTH component

subplot(312), 
axscale = [xmin xmax nmin nmax];
errorbar(date, n, nsig, 'kd');
axis(axscale);
hold on, line(axscale(1:2), polyval(np, axscale(1:2)), 'Color', 'k', 'LineStyle', '--');
ylabel('North (mm)');



%   UP component

subplot(313), 
axscale = [xmin xmax umin umax];
errorbar(date, u, usig, 'kd');
axis(axscale);
hold on, line(axscale(1:2), polyval(up, axscale(1:2)), 'Color', 'k', 'LineStyle', '--');
ylabel('Up (mm)');
xlabel('Date (years)');

%line(axscale(1:2), [11.5,11.5], 'Color', 'k', 'LineStyle', '--');

npoints = length(date);
