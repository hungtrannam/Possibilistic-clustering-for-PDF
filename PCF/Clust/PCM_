function results = PCM_(Data, param, varargin)
% PCM_ - Performs Possibilistic C-Means clustering on the given data.
% 
% Syntax: results = PCM_(Data, param, varargin)
% 
% Inputs:
%    Data - A matrix where each column represents a data point.
%    param - A struct containing the following fields:
%        kClust - Number of clusters.
%        maxIter - Maximum number of iterations.
%        mFuzzy - Fuzziness parameter.
%        epsilon - Convergence threshold.
%        alphaCut - Threshold for noise identification.
%        K - Scaling factor for eta calculation.
%        x (optional) - Support points for the PDFs.
%    varargin - Optional parameters for visualization:
%        'Visualize' - Can be 'None', 'CDF', or 'CDE'.
%
% Outputs:
%    results - A struct containing clustering results.

% Check if the number of clusters is valid
if param.kClust <= 1
    error('The number of clusters (kClust) must be greater than 1 for clustering to be performed.');
end

% Parse optional input arguments
p = inputParser;
addParameter(p, 'Visualize', 'None');
parse(p, varargin{:});
Visualize = p.Results.Visualize;

% Initialize settings and parameters
f = Data;
iter = 0;
max_iter = param.maxIter;
fm = param.mFuzzy;
epsilon = param.epsilon;
numSample = size(f, 2);
numCluster = param.kClust;
alpha = param.alphaCut;
if isfield(param, 'x')
    x = param.x;
end
K = param.K;
abnormal = [];

% Clustering

% Initialize the partition matrix with Fuzzy C-Means (FCM)
options = fcmOptions(...
    NumClusters = numCluster, ...
    Exponent = fm, ...
    MaxNumIteration = max_iter, ...
    DistanceMetric = 'euclidean', ...
    Verbose = false);

[fv, U] = fcm(f', options);
fv = fv';

% Calculate the distance between cluster centers and data points
Wf = zeros(numCluster, numSample);
for j = 1:numSample
    for i = 1:numCluster
        Wf(i, j) = trapz(x, abs(fv(:, i) - f(:, j))).^2;
    end
end

% Estimate eta using FCM results
eta = zeros(1, numCluster);
for i = 1:numCluster
    eta(i) = K * sum((U(i, :).^fm) .* Wf(i, :)) / sum(U(i, :).^fm);
end

% Repeat the PCM algorithm until convergence or max iterations
while iter < max_iter
    iter = iter + 1;

    % Calculate the distance between cluster centers and data points
    Wp = zeros(numCluster, numSample);
    for j = 1:numSample
        for i = 1:numCluster
            Wp(i, j) = trapz(x, abs(fv(:, i) - f(:, j))).^2;
        end
    end

    % Update the partition matrix
    Upcm = zeros(numCluster, numSample);
    for j = 1:numSample
        m = 0;
        for k = 1:numCluster
            if Wp(k, j) == 0
                m = m + 1;
            end
        end
        if m == 0
            Upcm = 1 ./ (1 + (Wp ./ eta').^(1 / (fm - 1)));
        else
            for l = 1:numCluster
                if Wp(l, j) == 0
                    Upcm(l, j) = 1 / m;
                else
                    Upcm(l, j) = 0;
                end
            end
        end
    end

    % Calculate objective function (Krishnapuram 1993)
    ObjFun = sum(sum(Upcm.^fm .* Wp)) + sum(eta) * sum((1 - Upcm).^fm, 'all');

    % Update the representative PDFs
    fv = (f * (Upcm.^fm)') ./ sum(Upcm.^fm, 2)';

    % Visualization
    if strcmp(Visualize, 'CDF')
        labels = zeros(1, numSample);
        for i = 1:numSample
            if all(Upcm(:, i) > alpha)
                [~, labels(i)] = max(Upcm(:, i));
            end
        end
        h = PlotPDFeachIteration(f, labels, x);
        hold on;
        plot(x, fv, "LineWidth", 2, "DisplayName", "representative PDFs");
        fig_filename = fullfile('Figure_Output/CDF_cont/', sprintf('CDF_Plot(%03d).fig', iter));
        saveas(h, fig_filename);
        pause(0.2); close;
    elseif strcmp(Visualize, 'CDE')
        [~, labels] = max(Upcm);
        h = PlotCDEseachIteration(f, fv', labels, param);
        fig_filename = fullfile('Figure_Output/CDE_cont/', sprintf('CDE_Plot(%03d).fig', iter));
        saveas(h, fig_filename);
        pause(0.2); close;
    end

    % Check for convergence
    Cond = norm(Upcm - U, 1);
    fprintf('Iteration count = %d, obj. pcm = %f\n', iter, ObjFun);

    if Cond < epsilon
        break;
    end
    U = Upcm;
end

% Prepare results
[~, IDX] = max(U);
for i = 1:numSample
    if all(U(:, i) < alpha) == 1
        IDX(i) = 0;
        abnormal = [abnormal i];
    end
end

results.Cluster.U = U;
results.Data.fv = fv;
results.iter = iter;
results.ObjFun = ObjFun;
results.Data.Data = f;
results.Cluster.IDX = IDX;
results.Dist.D = Wf;
results.isnoise = abnormal;

end
