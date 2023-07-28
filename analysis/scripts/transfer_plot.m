%% Clean up
clear; clc; close all;

%% Plot
% Read the .csv
raw_data1 = readtable("../exp_data/5_4b_high_res.csv", 'VariableNamingRule', 'preserve');
% call the functions that handle the plots
analyze_transfer_function(raw_data1);

%% Function declaration
% Característica de transferência experimental vO(vI)
function analyze_transfer_function(data) 
    figure; grid on, grid minor;
    set(gcf, 'Position',  [100, 100, 660, 340]);

    x = data{:,2}; % vI
    y = data{:,3}; % vO

    sorted_y = sort(y);
    n = round(0.25 * length(y)); % calculate the top/bottom 25%
    VOH = mean(sorted_y(end-n+1:end));
    VOL = mean(sorted_y(1:n));

    % plot the function
    hold on;
    line([0 5], [VOL VOL], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25);
    line([0 5], [VOH VOH], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25);
    plot(x, y, '.', 'Color', [0.0 0.24 0.33], 'LineWidth', 1.75);

    % split the data into two halves based on x values
    half_x_value = 2.5;
    indices_below_half  = find(x(1:end-1) < half_x_value); % first half of the data
    indices_above_half  = find(x(1:end-1) > half_x_value); % second half of the data

    % calculate the function slopes
    slopes = diff(y) ./ diff(x);

    % find the index where the slope is closest to -1 for each half
    [~, index1] = min(abs(slopes(indices_below_half) + 1)); % min value in the first half
    [~, index2] = min(abs(slopes(indices_above_half) + 1)); % min value in the second half
    
    % correct indexes
    index1 = indices_below_half(index1);
    index2 = indices_above_half(index2);

    % plot lines where the slope is -1 and mark the VIL, VIH points
    for i = [index1, index2]
        xVal = x(i); yVal = y(i);
        plot([xVal-10, xVal+10], [yVal+10, yVal-10], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
        plot([xVal-0.2, xVal+0.2], [yVal+0.2, yVal-0.2], 'r-', 'LineWidth', 2);
        plot(xVal, yVal, 'o', 'MarkerSize', 4, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', 'none');
    end
    hold off;

    % customise axis labels
    ax = gca; xlim([0 5]); ylim([-1 6]);
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    set_axis_labels(ax.YAxis, 'V');
    set_axis_labels(ax.XAxis, 'V');

    % add annotations (current axis, name, value, unit, offsetX, offsetY)
    add_annotation(ax, '$V_{OL}$', VOL, 'V', +0.580, -0.090);
    add_annotation(ax, '$V_{OH}$', VOH, 'V', -0.680, -0.025);
    add_annotation(ax, '$V_{IL}$', x(index1), 'V', -0.115, +0.215);
    add_annotation(ax, '$V_{IH}$', x(index2), 'V', +0.015, -0.335);

    % add a legend to the plot
    hiddenLine1 = line(nan(1,3), nan(1,3), 'Color', [0.0 0.24 0.33], 'LineWidth', 1.75, 'LineStyle', ':');
    hiddenLine2 = line(nan(1,3), nan(1,3), 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'LineStyle', '--');
    legend([hiddenLine1, hiddenLine2], {'$v_{O}(v_{I})$', 'lines with $dy/dx = -1$'}, 'FontSize', 10, ...
        'Interpreter', 'latex', 'Location', 'southwest', 'Orientation', 'horizontal');
end

% Adds a symbol to the y-axis tick labels
function set_axis_labels(axis, unit)
    axis.Exponent = 0;  % disable scientific notation
    tick_values = get(axis, 'TickValues');
    tick_labels = arrayfun(@(x)[num2str(x), unit], tick_values, 'UniformOutput', false);
    set(axis, 'TickLabels', tick_labels);
end

function add_annotation(ax, name, value, unit, offX, offY)
    % get axes position in normalized units
    axPos = ax.Position;

    % get the axis limits
    ax_xlim = xlim(ax);
    ax_ylim = ylim(ax);

    % convert the data point location to normalized figure coordinates
    normX = (value - ax_xlim(1)) / (ax_xlim(2) - ax_xlim(1));
    normY = (value - ax_ylim(1)) / (ax_ylim(2) - ax_ylim(1));

    % define text string with term and value
    textStr = sprintf('%s = %.3f%s', name, value, unit);

    % ensure normalized coordinates are within [0, 1]
    normX = min(max(normX, 0), 1);
    normY = min(max(normY, 0), 1);

    % create annotation
    a = annotation('textbox', [axPos(1)+normX*axPos(3)+offX, axPos(2)+normY*axPos(4)+offY, 0.1, 0.1],...
        'String', textStr,...
        'FitBoxToText', 'on',...
        'BackgroundColor', 'none',...
        'EdgeColor', 'none',...
        'FontSize', 10,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Interpreter', 'latex');
end