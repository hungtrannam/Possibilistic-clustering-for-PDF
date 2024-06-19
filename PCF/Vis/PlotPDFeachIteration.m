function [h] = PlotPDFeachIteration(data, labels, x)
    % PlotPDFeachIteration - Plot probability density functions (PDFs) from data matrix
    % 
    % Syntax:
    %   h = PlotPDFeachIteration(data, labels, x)
    %
    % Inputs:
    %   data   - A matrix containing PDF data. Each column represents a PDF.
    %   labels - A vector containing the labels for each PDF.
    %   x      - (Optional) A vector of x-axis values. If not provided, a default vector is created.
    %
    % Outputs:
    %   h      - Handle to the created figure.

    % Check if x is provided, if not, create a default vector
    if nargin < 3
        x = linspace(-0.5, 1.5, 500);
    end

    % Check input dimensions
    if size(data, 2) ~= numel(labels)
        error('The number of columns in data must match the number of elements in labels.');
    end

    % Settings
    unique_labels = unique(labels);
    num_labels = numel(unique_labels);
    colors = jet(num_labels);
    color_map = containers.Map(unique_labels, mat2cell(colors, ones(size(colors, 1), 1), size(colors, 2)));

    % Plotting
    h = figure;

    for i = 1:numel(labels)
        color = color_map(labels(i));
        plot(x, data(:, i), 'Color', color, 'LineWidth', 1.5);
        hold on;
    end

    % Create title
    title(sprintf('The %d Probability Density Functions Data', numel(labels)), 'FontSize', 12);

    % Create legend based on color using graphics objects
    legend_entries = cell(1, num_labels);
    legend_objects = gobjects(1, num_labels);
    for j = 1:num_labels
        legend_entries{j} = sprintf('Cluster %d', unique_labels(j));
        legend_objects(j) = plot(NaN, NaN, 'Color', color_map(unique_labels(j)), 'DisplayName', legend_entries{j});
    end
    legend(legend_objects, legend_entries, 'Location', 'southoutside', 'Box', 'off', 'NumColumns', 2);

    % Label the axes
    xlabel('X-axis');
    ylabel('Probability Density');
    grid on;

    % Enhance figure aesthetics
    set(gca, 'FontSize', 10, 'LineWidth', 1);
    set(h, 'Color', 'w');
end
