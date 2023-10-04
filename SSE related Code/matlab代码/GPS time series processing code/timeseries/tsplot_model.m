function h = tsplot_1station(plotdata, dd, emod, nmod, hmod, td, d, tlines);
%h = function tsplot_1station(plotdata, dd, emod, nmod, hmod, td, d, tlines);
% Plots a single station time series and returns a handle to the figure
%  by Jeff Freymueller, December 22, 2007
%  modified and comments updated December 2, 2009
%
% plotdata (structure)  Timeseries data to be plotted
% dd                    Times array for model values
% emod, nmod, hmod      Model values to plot along with data
% td                    Time of displacement offset
% d                     Magnitude of displacement offset
% tlines                Draw vertical lines at these times


% Check input values

if ( ~isempty(tlines) )
    [n m] = size(tlines);
    if ( n>1 && m> 1)
        disp('Error in specifying tlines, array is two-dimensional');
        exit
    end

    tlines = tlines(:);
    tlines_arr = [tlines tlines];
end

if (isempty(td) || isempty(d))
   plot_disps = 0;
else
    plot_disps = 1;
end


% Define an array of colors for plotting the components

colors = ['b' 'g' 'r'];

t_text = max(max(plotdata.time)) + 0.2;

%   Figure out the optimal separations for the component plots

sepint = -0.075;
esep = 0;
nsep = sepint;
hsep = 2*sepint;

[p1, s1, mu1] = polyfit(plotdata.time, plotdata.east, 1);
[p2, s2, mu2] = polyfit(plotdata.time, plotdata.north, 1);
nsep = nsep - max(polyval(p2,dd, [], mu2) - polyval(p1,dd, [], mu1));
hsep = hsep - max(polyval(p2,dd, [], mu2) - polyval(p1,dd, [], mu1));

[p1, s1, mu1] = polyfit(plotdata.time, plotdata.north, 1);
[p2, s2, mu2] = polyfit(plotdata.time, plotdata.height, 1);
hsep = hsep - max(polyval(p2,dd, [], mu2) - polyval(p1,dd, [], mu1));


%  Make the Plot

h = figure;
hold on
set(gca, 'Box', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'YTick', linspace(-2,2, 41));

pbaspect([1.33 1 1]);
orient portrait;
title(plotdata.sitename, 'FontSize', 18)
xlabel('Year', 'FontSize', 14)
ylabel('Displacement (meters)', 'FontSize', 14)


% For each component, plot data with error bars, then model (black
% line, white border), then the displacements at t1 and t2, then text

icol = 1;
errorbar(plotdata.time, plotdata.east+esep, plotdata.esig, 'ko', 'MarkerFaceColor', colors(icol), 'LineWidth', 0.5);
plot(dd, emod+esep, 'w-', 'LineWidth', 3);
plot(dd, emod+esep, 'k-', 'LineWidth', 1);

if ( plot_disps )
    for i = 1:length(td),
        plot(td(i), d(1,i)+esep, 'mo', 'Linewidth', 4, 'MarkerSize', 12);
    end
end

text(t_text, plotdata.east(length(plotdata.east))+esep, 'EAST')


icol = 2;
errorbar(plotdata.time, plotdata.north+nsep, plotdata.nsig, 'ko', 'MarkerFaceColor', colors(icol), 'LineWidth', 0.5);
plot(dd, nmod+nsep, 'w-', 'LineWidth', 3);
plot(dd, nmod+nsep, 'k-', 'LineWidth', 1);

if ( plot_disps )
    for i = 1:length(td),
        plot(td(i), d(2,i)+nsep, 'mo', 'Linewidth', 4, 'MarkerSize', 12);
    end
end

text(t_text, plotdata.north(length(plotdata.north))+nsep, 'NORTH')


icol = 3;
errorbar(plotdata.time, plotdata.height+hsep, plotdata.hsig, 'ko', 'MarkerFaceColor', colors(icol), 'LineWidth', 0.5);
plot(dd, hmod+hsep, 'w-', 'LineWidth', 3);
plot(dd, hmod+hsep, 'k-', 'LineWidth', 1);

if ( plot_disps )
    for i = 1:length(td),
        plot(td(i), d(3,i)+hsep, 'mo', 'Linewidth', 4, 'MarkerSize', 12);
    end
end

text(t_text, plotdata.height(length(plotdata.height))+hsep, 'HEIGHT')


if ( ~isempty(tlines) )
    % Plot vertical lines at times given by tlines (stored in tlines_arr)

    plot(tlines_arr, get(gca,'YLim'), 'r-');

end