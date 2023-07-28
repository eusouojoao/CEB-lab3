%% Clean up
clear; clc; close all;

%% Plot
% Read the .csv
raw_data1 = readtable("../sim_data/4_2.csv", 'VariableNamingRule', 'preserve');
raw_data2 = readtable("../sim_data/4_3.csv", 'VariableNamingRule', 'preserve');
raw_data3 = readtable("../sim_data/4_4.csv", 'VariableNamingRule', 'preserve');
% call the functions that handle the plots
plot_4_2(raw_data1);
plot_4_3(raw_data2);
plot_4_4(raw_data3);

%% Function declaration
% Gráfico de iD(vI)
function plot_4_2(data)
    % setup
    figure
    set(gcf, 'Position',  [100, 100, 660, 340]);

    x = data{:,1};
    y = data{:,2} .* 1e6; % convert to uA

    plot(x, y, 'Color', [0.0 0.24 0.33], 'LineWidth', 1.75); hold on;

    [~,I] = max(abs(y)); % find the current's maximum value
    ylim([-20 160]); x(I), y(I)
    line([x(I) x(I)], ylim, 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25); hold on;
    line(xlim, [y(I) y(I)], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25); hold on;
    plot(x(I), y(I), 's', 'MarkerSize', 6, 'MarkerFaceColor', [0.93 0.69 0.13], 'MarkerEdgeColor','none'); 
    hold off;

    grid on, grid minor; 

    % customise axis labels
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    ax.YTick = [-20 0 20 40 60 80 100 120 140 160];
    set_axis_labels(ax.YAxis, 'uA');
    set_axis_labels(ax.XAxis, 'V');
end

% Característica de transferência vO(vI)
function plot_4_3(data)
    % setup
    figure
    set(gcf, 'Position',  [100, 100, 660, 340]);

    x = data{:,1};
    y1 = data{:,2};
    y2 = data{:,3};

    % x-axis
    xlim([0 5])
    % set x-axis tick locations and labels
    set_axis_labels(gca().XAxis, 'V');

    % left side
    yyaxis left; 
    p1 = plot(x, y1, 'Color', [0.0 0.24 0.33], 'LineWidth', 1.75); hold on;
    [~,Idx] = max(y1);
    [~,idx] = min(y1);
    line(xlim, [y1(idx) y1(idx)], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25); hold on;
    line(xlim, [y1(Idx) y1(Idx)], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25); hold off;
    % customise axis labels
    set(gca, 'YColor', [0 0 0])  % change left y-axis color to black
    ylim([-1 6]);
    set_axis_labels(gca().YAxis(1), 'V');

    % right side
    yyaxis right; 
    p2 = plot(x, y2, '-', 'Color', [0.663, 0.125, 0.235], 'LineWidth', 1.75); 
    hold on;
    line(xlim, [-1 -1], 'LineStyle', '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5); 
    hold on;

    % get the indices where the function crosses -1
    crossings = find(diff(sign(y2+1))~=0);
    
    if length(crossings) > 2
        % If there are more than two crossings, let's only keep the first and last
        crossings = [crossings(1), crossings(end)];
    end

    for i = 1:length(crossings)
        % get the two points that straddle -1
        x1_cross = x(crossings(i));
        x2_cross = x(crossings(i)+1);
        y1_cross = y2(crossings(i));
        y2_cross = y2(crossings(i)+1);

        % interpolate to find the exact crossing point
        x_cross = interp1([y1_cross, y2_cross], [x1_cross, x2_cross], -1);

        % plot the crossing point
        plot(x_cross, -1, 'o', 'MarkerSize', 4, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', 'none'); hold on;
    end

    hold off;
    
    % customise axis labels
    set(gca, 'YColor', [0 0 0])  % change left y-axis color to black
    ylim([-4 3]);

    grid on, grid minor;
    % Manual legend for both left and right yyaxis
    legend([p1, p2], {'$v_{O}(v_{I})$', '$dv_{O}/dv_{I}$'}, 'FontSize', 12, 'Interpreter', 'latex', 'Location', 'southwest', 'Orientation', 'vertical');
end

% Determinação dos tempos de atraso de propagação (tpLH, tpHL e tp)
function plot_4_4(data)
    % setup
    figure
    set(gcf, 'Position',  [100, 100, 660, 340]);

    x = data{:,1} .* 1e6; % convert to us
    y1 = data{:,2};
    y2 = data{:,3};

    p1 = plot(x, y1, 'Color', [0.0 0.24 0.33], 'LineWidth', 1.75); hold on;
    p2 = plot(x, y2, 'Color', [0.85 0.33 0.09], 'LineWidth', 1.75); hold on;
    line(xlim, [2.5 2.5], 'LineStyle', '--', 'Color', [0.02 0.02 0.02], 'LineWidth', 1.25); hold on;

    % get the indices where the function crosses 2.5
    crossings = find(diff(sign(y2-2.5))~=0);
    
    if length(crossings) > 2
        % If there are more than two crossings, let's only keep the first and last
        crossings = [crossings(2), crossings(3)];
    end

    for i = 1:length(crossings)
        % get the two points that straddle 2.5
        x1_cross = x(crossings(i));
        x2_cross = x(crossings(i)+1);
        y1_cross = y2(crossings(i));
        y2_cross = y2(crossings(i)+1);

        % interpolate to find the exact crossing point
        x_cross = interp1([y1_cross, y2_cross], [x1_cross, x2_cross], 2.5);

        % plot the crossing point
        plot(x_cross, 2.5, 's', 'MarkerSize', 6, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', 'none'); hold on;
    end

    xlim([0 7.5]), ylim([0 5]);
    grid on, grid minor;

    % setup legends
    legend([p1 p2],'$v_{I}$', '$v_{O}$', 'FontSize', 12, 'Interpreter', 'latex', ...
        'Location', 'southwest', 'Orientation', 'vertical');

    % customise axis labels
    ax = gca;
    ax.FontSize = 11;
    ax.TickLabelInterpreter = 'latex';
    set_axis_labels(ax.YAxis, 'V');
    set_axis_labels(ax.XAxis, 'us');
end

% Adds a symbol to the y-axis tick labels
function set_axis_labels(axis, unit)
    axis.Exponent = 0;  % disable scientific notation
    tick_values = get(axis, 'TickValues');
    tick_labels = arrayfun(@(x)[num2str(x), unit], tick_values, 'UniformOutput', false);
    set(axis, 'TickLabels', tick_labels);
end