function tsplot_panel(tval, value, sig, tmod, model, td, d, tlines, color, symsize)
%h = tsplot_panel(tval, value, sig, tmod, model, td, d, tlines, color, symsize);
% Plots a single component time series in a panel (the current panel).
% Optionally plots a model curve, value picks at epochs td, and lines at times of breaks.
% 
%  by Jeff Freymueller, January 7, 2008
%


% Check input values

if ( length(sig) ~= 0 )
    plot_errorbars = 1;
else
    disp('No error bars specified');
    plot_errorbars = 0;
end

if ( length(tmod) ~= 0 )
    plot_model = 1;
else
    disp('No model specified');
    plot_model = 0;
end

if ( length(tlines) ~= 0 )
    plot_lines = 1;
    [n m] = size(tlines);
    if ( n>1 && m> 1)
        disp('Error in specifying tlines, array is two-dimensional');
        exit
    end
    if (n > m)
        tlines = tlines';
    end
    tlines_arr = [tlines; tlines]
else
    disp('No lines specified');
    plot_lines = 0;
end


if (length(td) == 0 || length(d) == 0)
    disp('No picks specified');
    plot_picks = 0;
else
    plot_picks = 1;
end

if ( nargin < 9 )
    color = 'k';
end

if ( nargin < 10 )
    symsize = 6;
end

%  Make the Plot

hold on
set(gca, 'Box', 'on');
set(gca, 'YGrid', 'on');
orient landscape;

%set(gca, 'YTick', linspace(-2,2, 41));
%pbaspect([1 1.33 1]);
%xlabel('Year', 'FontSize', 14)
%ylabel('Displacement (meters)', 'FontSize', 14)

if ( plot_errorbars == 1 )
    he = errorbar(tval, value, sig, 'ko');
    set(he, 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color, 'LineWidth', 0.5, 'MarkerSize', symsize);
else
    plot(tval, value, 'ko', 'MarkerFaceColor', color, 'LineWidth', 0.5, 'MarkerSize', symsize);
end

if ( plot_model == 1 )
    plot(tmod, model, 'w-', 'LineWidth', 3);
    plot(tmod, model, 'k-', 'LineWidth', 1);
end

if ( plot_picks == 1 )
    for i = 1:length(td),
        plot(td(i), d(1,i), 'mo', 'Linewidth', 4, 'MarkerSize', 12);
    end
end

if ( plot_lines == 1 )
    for i = 1:size(tlines_arr,2)
        plot(tlines_arr(:,i), get(gca,'YLim'), 'r-');
    end
end
