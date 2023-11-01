function [hdm, hr] = tsplot_3panel(data, model, tlines, units, visible, shadedErrors)
%[hdm, hres] = function tsplot_3panel(data, model, tlines, units, visible, shadedErrors);
% Plots two versions of a single station time series in 3 panels and returns
% a handle to each figure
%  by Jeff Freymueller, August 2, 2014
%
% Input arguments (only data argument is required)
%   data (structure)      Timeseries data to be plotted
%   model (structure)     Times array for model values
%   tlines                Draw vertical lines at these times
%   units                 Display units ('mm', 'cm' (default), 'm'
%   visible               1 = show plot on screen (default), 0 = do not show
%   shadedErrors          1 = show model errors as shaded regions, 0 = do not show (default)
%
% Output arguments
%   hdm                   handle to Data + model figure
%   hres                  handle to Residual figure (only if a model is given)

%%
%    Initialization

hdm = [];
hr = [];

visible      = 1;
shadedErrors = 0;
plot_model   = 1;

% Check input values and do basic setup

if ( nargin < 6 )
    shadedErrors = 0;
end
if ( nargin < 5 )
    visible = 1;
end
if ( ~( visible == 0 || visible == 1) )
    visible = 1;
end

if ( nargin < 4 )
    units = 'cm';
end

if ( nargin < 3 )
    tlines = [];
end

if ( nargin < 2 )
    model = [];
    plot_model = 0;
end

% Setup

if ( isempty(model) )
    plot_model = 0;
end

if ( ~isempty(tlines) )
    [n m] = size(tlines);
    if ( n>1 && m> 1)
        disp('Error in specifying tlines, array is two-dimensional');
        exit
    end
    tlines = tlines(:);
    tlines_arr = [tlines tlines]';
end

switch ( units )
    case 'mm'
        unitscale = 1000;
    case 'cm'
        unitscale = 100;
    case 'm'
        unitscale  =1;
    otherwise
        unitscale = 100;
end


% Define an array of colors for plotting the components

colors = ['b' 'g' 'r'];

ytxt{1} = ['EAST (' units ')'];
ytxt{2} = ['NORTH (' units ')'];
ytxt{3} = ['HEIGHT (' units ')'];


%%
%    Set up time window for plot. Set to 120% of data span, and then the
%    final window will be adjusted to floor(mint) to ceil(maxt)
    
mint = min(data.time);
maxt = max(data.time);
Tspan = maxt - mint;

%mint = mint - Tspan/10;
%maxt = maxt + Tspan/10;


%%
%  Evaluate the model and residuals

if ( plot_model )

    % First, compute the residuals to the model
    
    residuals = ts_subtract_model(data, model);
    
    % Now, compute a set of model values for plotting
    %    The complexities here are to deal with offsets so that they look
    %    vertical, and to make sure there are an appropriate number of
    %    points so that seasonal or other time dependent elements look right.

    if ( isempty(model.disp) )
        npts = ceil(Tspan*50);
        modeltimes = [ linspace(floor(mint), ceil(maxt), npts) ]';
        
    else
        % Divide the total time span into N+1 segments, where N is the
        % number of displacements. The segments will start or end
        % immediately before or after each displacement.
        
        linlim = [floor(mint), model.disp(1)-0.0001 ];
        if ( length(model.disp) > 1)
            for j = 1:(length(model.disp) - 1)
                linlim = [linlim, model.disp(j)+0.0001, model.disp(j+1)-0.0001];
            end
        end
        linlim = [ linlim, model.disp( length(model.disp) )+0.0001, ceil(maxt) ];
        
        % Construct the array of model times for each segment, and
        % concatenate together.

        modeltimes = [];
        for j = 1:(length(linlim) - 1);
           npts = ceil( (linlim(j+1) - linlim(j))*50 );
           modeltimes = [ modeltimes, linspace(linlim(j), linlim(j+1), npts)];
        end
        modeltimes = modeltimes';
    end

    % Now evaluate the model and extract the east, north, vertical positions

    [modelval, modelsigs] = tsfit(modeltimes, model);
    modelvec    = reshape(modelval, [], 3);
    modelsigvec = reshape(modelsigs, [], 3);
end



%%
%  Define figure and set basic properties for Data + Model Plot

if ( visible )
   hdm = figure;
else
   hdm = figure('Visible', 'off');
end
orient landscape;

vals{1} = unitscale*data.east;
vals{2} = unitscale*data.north;
vals{3} = unitscale*data.height;

sigs{1} = unitscale*data.esig;
sigs{2} = unitscale*data.nsig;
sigs{3} = unitscale*data.hsig;


% Plot values component by component

for icol = 1:3
    subplot(3,1,icol)
    if ( plot_model )
        if ( shadedErrors )
            shadedErrorBar(modeltimes, unitscale*modelvec(:,icol), ...
                           unitscale*modelsigvec(:,icol), 'r');
            hold on;
        end
        plot_component_shaded(data.time, vals{icol}, modeltimes, ...
                   unitscale*modelvec(:,icol), ...
                   colors(icol), ytxt{icol}, tlines);
    else
        plot_component(data.time, vals{icol}, sigs{icol}, [], [], ...
                   colors(icol), ytxt{icol}, tlines);
            hold on;
    end
    
    % Annotation

    switch ( icol )
        case 1
            title(data.sitename, 'FontSize', 18, 'Interpreter', 'none');
        case 3
            xlabel('Year', 'FontSize', 14);
    end
          
end


%%
%  Define figure and set basic properties for Residual Plot

if ( ~isempty(model) )
    
    if ( visible )
       hr = figure;
    else
       hr = figure('Visible', 'off');
    end
    orient landscape;
    
    % First, compute the residuals to the model
    
    residuals = ts_subtract_model(data, model);
    vals{1} = unitscale*residuals.enu(1,:)';
    vals{2} = unitscale*residuals.enu(2,:)';
    vals{3} = unitscale*residuals.enu(3,:)';

    % Plot values component by component

    for icol = 1:3
        subplot(3,1,icol)
        if ( shadedErrors )
            shadedErrorBar(modeltimes, zeros(size(modeltimes)), ...
                           unitscale*modelsigvec(:,icol), 'r');
            hold on;
            plot_component_shaded(data.time, vals{icol}, [], [], ...
                       colors(icol), ytxt{icol}, tlines);
        else
            plot_component(data.time, vals{icol}, sigs{icol}, [], [], ...
                       colors(icol), ytxt{icol}, tlines);
            hold on;
        end
        
        % Annotation
        
        switch ( icol )
            case 1
                title(data.sitename, 'FontSize', 18, 'Interpreter', 'none');
            case 3
                xlabel('Year', 'FontSize', 14);
        end
           
            
    end


return

end

%%
%    Internal function to plot one component

function plot_component(times, vals, sigs, modeltimes, modelvals, color, ytxt, tlines)
        
errorbar(times, vals, sigs, 'ko', 'MarkerFaceColor', color, 'LineWidth', 0.5);
hold on

if ( ~ isempty(modeltimes) )
    plot(modeltimes, modelvals, 'w-', 'LineWidth', 3);
    plot(modeltimes, modelvals, 'k-', 'LineWidth', 1);
end

set(gca, 'Box', 'on');
set(gca, 'YGrid', 'on');
ylabel(ytxt, 'FontSize', 14)

% Plot vertical lines
if ( ~isempty(tlines) )
    tlines = tlines(:);
    tlines_arr = [tlines tlines]';
    plot(tlines_arr, get(gca,'YLim'), 'r-');
end

return

%%
%    Internal function to plot one component for shaded error bars

function plot_component_shaded(times, vals, modeltimes, modelvals, color, ytxt, tlines)
        
plot(times, vals, 'ko', 'MarkerFaceColor', color, 'LineWidth', 0.25);
hold on

if ( ~ isempty(modeltimes) )
    plot(modeltimes, modelvals, 'w-', 'LineWidth', 3);
    plot(modeltimes, modelvals, 'k-', 'LineWidth', 1);
end

set(gca, 'Box', 'on');
set(gca, 'YGrid', 'on');
ylabel(ytxt, 'FontSize', 14)

% Plot vertical lines
if ( ~isempty(tlines) )
    tlines = tlines(:);
    tlines_arr = [tlines tlines]';
    plot(tlines_arr, get(gca,'YLim'), 'r-');
end

return


