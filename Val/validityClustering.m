function results = validityClustering(results, param)
% validation of the clustering
N = size(results.Data.Data, 2);

if param.val == 1 || param.val == 3
    m = param.mFuzzy;

    % partition coefficient (PC)
    fm = (results.Cluster.U).^m;
    PC = 1/N * sum(sum(fm));
    % classification entropy (CE)
    fm = (results.Cluster.U) .* log(results.Cluster.U);
    CE = -1/N * sum(sum(fm));

    % Xie and Beni's index (XB)
    XB = sum((sum(results.Dist.D .* results.Cluster.U.^2)) ./ (N * min(results.Dist.D)));

    % Silhouette Coefficient
    silhouetteVals = silhouette(results.Data.Data', results.Cluster.IDX);
    SC = mean(silhouetteVals);

   

    results.validity.SC = SC;
    results.validity.XB = XB;
    results.validity.PC = PC;
    results.validity.CE = CE;
end

if param.val == 2 || param.val == 3
    labels1 = param.truelabels;
    labels2 = results.Cluster.IDX;
    N = numel(labels1);

    TP = 0; FN = 0; FP = 0; TN = 0;

    % Calculate TP, FN, FP and TN
    for i = 1:N-1
        for j = i+1:N
            if (labels1(i) == labels1(j)) && (labels2(i) == labels2(j))
                TP = TP + 1;
            elseif (labels1(i) == labels1(j)) && (labels2(i) ~= labels2(j))
                FN = FN + 1;
            elseif (labels1(i) ~= labels1(j)) && (labels2(i) == labels2(j))
                FP = FP + 1;
            else
                TN = TN + 1;
            end
        end
    end

    % Calculate Rand Index (RI)
    RI = (TP + TN) / (TP + FP + FN + TN);

    % Calculate Adjusted Rand Index (ARI)
    try
        C = confusionmat(labels1, labels2);  % Use built-in function to generate confusion matrix
    catch
        groups = unique([g1;g2]);  % Get the unique groups in g1 and g2
        C = zeros(length(groups));  % Initialize the confusion matrix with zeros
        % Calculate the confusion matrix
        for i = 1:length(groups)
            for j = 1:length(groups)
                C(i,j) = sum(g1 == groups(i) & g2 == groups(j));  % Count the number of samples that belong to group i in g1 and group j in g2
            end
        end
    end

    % Compute necessary quantities for ARI calculation
    sum_C = sum(C(:));
    sum_C2 = sum_C * (sum_C - 1);
    sum_rows = sum(C, 2);
    sum_rows2 = sum(sum_rows .* (sum_rows - 1));
    sum_cols = sum(C, 1);
    sum_cols2 = sum(sum_cols .* (sum_cols - 1));
    sum_Cij2 = sum(sum(C .* (C - 1)));

    % Compute ARI
    ARI = 2 * (sum_Cij2 - sum_rows2 * sum_cols2 / sum_C2) / ...
        ((sum_rows2 + sum_cols2) - 2 * sum_rows2 * sum_cols2 / sum_C2);

    % Calculate G-mean
    sensitivity = TP / (TP + FN); 
    specificity = TN / (TN + FP);
    Gmean = sqrt(sensitivity * specificity);

    results.validity.Gmean = Gmean;
    results.validity.ARI = ARI;
    results.validity.RI = RI;
end


end

