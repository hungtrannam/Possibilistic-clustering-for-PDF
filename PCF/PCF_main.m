clear; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading

addpath Data Figure_Output Package/Clust Package/Vis/ Package/Val/ Package/ToolBox/
% Add necessary paths for data, figure outputs, clustering packages, visualization, validation, and toolbox utilities.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting

% Data generation with simulated abnormal parameters

abnormal_params = {
    {[0.15, 4.5], sqrt([.5, .5])}
    {[0.3, 4.2], sqrt([.5, .5])}
    };

% Simulate data using SimPDFAbnormal function
[Data, param.x, param.truelabels] = SimPDFAbnormal( ...
    { ...
    linspace(0, 0.5, 5*100), ...  % Varying parameter 1
    linspace(4, 4.5, 5), ...     % Varying parameter 2
    linspace(6, 6.5, 5*5), ...   % Varying parameter 3
    }, ...
    sqrt([.5, .5, .5]));         % Standard deviation of each parameter

% Fuzzy C-Means (FCM) clustering parameters
param.maxIter = 1000;           % Maximum number of iterations
param.mFuzzy = 2;               % Fuzziness parameter
param.epsilon = 1e-10;          % Convergence criterion
param.kClust = 3;               % Number of clusters
param.K = 1;                    % Parameter K for validation
param.val = 2;                  % Validation type
param.alphaCut = .1;            % Alpha-cut value for fuzziness

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clustering via algorithm

% Perform clustering using PCM_2 algorithm (assuming PCM_2 is defined elsewhere)
results = PCM_2(Data, param);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

% Plot heatmap of cluster memberships
figure;
imagesc(results.Cluster.U);
colorbar;

% Plot PDF of each iteration overlaid with representative PDF
h = PlotPDFeachIteration(Data, results.Cluster.IDX, param.x);  % Plot PDF for each iteration
hold on;
plot(param.x, results.Data.fv, ...
    "LineWidth", 3, ...
    "DisplayName", "Representative PDF");  % Overlay representative PDF
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validation

% Perform clustering validation
results = validityClustering(results, param);

% End of script
