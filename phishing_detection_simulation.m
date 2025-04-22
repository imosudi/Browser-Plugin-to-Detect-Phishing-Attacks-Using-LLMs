clear all;
close all;
clc;


% --- Parameters ---
filename = 'phishing_dataset.csv'; % Name of your CSV file (must be in the same directory or provide full path)
plot_results = true;               % Set to true to generate visualizations
confidence_level = 0.98;           % Detection threshold confidence (e.g., 0.98 = flag points outside 98% probability ellipse of good data)
                                   % Adjust this (0.95, 0.99, etc.) to see impact on Precision/Recall

% --- Feature Selection ---
% Choose which features to USE for the detection model by their index number (see function below)
% To enable the 2D scatter plot, select exactly TWO indices here (e.g., [1, 2]).
feature_indices_to_use = [1, 2, 3, 5, 9, 12]; % Example: Using 6 features (Length, '.', '/', digits, 'paypal', '@')
%feature_indices_to_use = [1, 5]; % Example for 2D Plot: Using Length and Digit Count


disp("--- Parameters Set ---");
fprintf("Dataset file: %s\n", filename);
fprintf("Plotting enabled: %d\n", plot_results);
fprintf("Confidence level for threshold: %.2f\n", confidence_level);
fprintf("Features selected for model (indices): %s\n", mat2str(feature_indices_to_use));



function features = extract_features_from_url(url)
    if isempty(url) || ~ischar(url)
        % Handle empty or non-string input gracefully
        features = nan(1, 12); % Return NaNs if URL is invalid
        return;
    end
    url_lower = lower(url); % Work with lowercase for keyword checking

    % Define features:
    feat1 = length(url);                         % 1: URL Length
    feat2 = sum(url == '.');                     % 2: Number of dots
    feat3 = sum(url == '/');                     % 3: Number of slashes
    feat4 = sum(url == '-');                     % 4: Number of hyphens
    feat5 = sum(isstrprop(url, 'digit'));        % 5: Count of Digits
    % --- Use !isempty(strfind(...)) ---
    feat6 = !isempty(strfind(url_lower, 'login'));  % 6: Contains 'login' (returns 1 if true, 0 if false)
    feat7 = !isempty(strfind(url_lower, 'secure')); % 7: Contains 'secure'
    feat8 = !isempty(strfind(url_lower, '.php'));   % 8: Contains '.php'
    feat9 = !isempty(strfind(url_lower, 'paypal')); % 9: Contains 'paypal'
    % ---------------------------------------
    feat10 = sum(url == '?');                    % 10: Count of '?' (query params indicator)
    feat11 = sum(url == '=');                    % 11: Count of '=' (query params indicator)
    feat12 = sum(url == '@');                    % 12: Count of '@' (often suspicious in URLs)

    features = double([feat1, feat2, feat3, feat4, feat5, feat6, feat7, feat8, feat9, feat10, feat11, feat12]); % Ensure output is double
end




% --- 1. Load Data ---
fprintf('Loading data from %s...\n', filename);
try
    disp("   Attempting to open file...");
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s. Make sure it is in the correct Octave path.', filename);
    end
    disp("   File opened successfully.");

    % Read header line and ignore it
    fgetl(fid);
    disp("   Skipped header row.");

    % Read the rest of the data into cell arrays
    % Using '%q' handles potential quotes around URLs or labels if they exist
    data_cell = textscan(fid, '%q %q', 'Delimiter', ',', 'HeaderLines', 0, 'CollectOutput', true);
    fclose(fid);
    data_cell = data_cell{1}; % textscan wraps output in another cell

    if isempty(data_cell) || size(data_cell, 1) == 0
         error('No data read from file after header. Check file format and content.')
    end
    disp("   Data read into cell array.");

    urls = data_cell(:, 1);       % First column: URLs (as cell strings)
    labels_raw = data_cell(:, 2); % Second column: Labels (as cell strings)

    num_samples = length(urls);
    fprintf('Loaded %d samples initially.\n', num_samples);
    disp("--- Data Loading Complete ---");

catch ME
    if exist('fid','var') && fid ~= -1, fclose(fid); end % Ensure file is closed on error
    error('Failed during data loading or initial parsing: %s\nFile: %s', ME.message, filename);
end


% --- 2. Apply Feature Extraction & Handle Errors ---
fprintf('Extracting features from %d URLs...\n', num_samples);
all_features_list = extract_features_from_url('http://example.com'); % Get dimensions
num_all_features = length(all_features_list);
feature_matrix_all = nan(num_samples, num_all_features); % Initialize with NaN
valid_extraction = true(num_samples, 1); % Track successful extractions

for i = 1:num_samples
    try
        features_extracted = extract_features_from_url(urls{i});
        if any(isnan(features_extracted))
             warning('Feature extraction returned NaN for sample %d (URL: "%s"). Skipping.', i, urls{i});
             valid_extraction(i) = false;
        else
            feature_matrix_all(i, :) = features_extracted;
        end
    catch FE_ME
        warning('Error during feature extraction for sample %d (URL: "%s"): %s. Skipping.', i, urls{i}, FE_ME.message);
        valid_extraction(i) = false; % Mark as invalid
    end
end

% Filter out samples where feature extraction failed
feature_matrix_all = feature_matrix_all(valid_extraction, :);
urls = urls(valid_extraction);
labels_raw = labels_raw(valid_extraction);
num_samples = size(feature_matrix_all, 1); % Update number of samples

if num_samples == 0
    error('Feature extraction failed for all samples or no valid samples remained.');
end
fprintf('Successfully extracted features for %d valid samples.\n', num_samples);


% --- 3. Select Features & Separate Data ---
% Select only the desired features for the detection model
if any(feature_indices_to_use > num_all_features) || any(feature_indices_to_use < 1)
    error('Invalid feature index found in `feature_indices_to_use`. Check parameter settings.');
end
feature_matrix = feature_matrix_all(:, feature_indices_to_use);
num_features = length(feature_indices_to_use);
fprintf('Using %d selected features for detection.\n', num_features);

% Identify indices for 'good' and 'bad' labels
good_indices = find(strcmp(labels_raw, 'good'));
bad_indices = find(strcmp(labels_raw, 'bad'));

num_good = length(good_indices);
num_bad = length(bad_indices);

if isempty(good_indices)
   error('No samples labeled "good" found in the dataset after filtering. Cannot create detection baseline.');
end
if isempty(bad_indices)
   warning('No samples labeled "bad" found in the dataset after filtering. Evaluation might be trivial.');
end
fprintf('Found %d "good" (normal) samples and %d "bad" (threat) samples.\n', num_good, num_bad);

% Separate feature data
normal_data_features = feature_matrix(good_indices, :);
threat_data_features = feature_matrix(bad_indices, :);

% Create numerical ground truth vector: 0 for normal (good), 1 for threat (bad)
ground_truth = zeros(num_samples, 1);
ground_truth(bad_indices) = 1;

disp("--- Data Separation and Ground Truth Creation Complete ---");


% --- 4. Anomaly Detection Baseline (Simulated LLM Training on Normal Data) ---
fprintf('Calculating baseline statistics from "good" data...\n');
pkg load statistics; % Ensure statistics package is loaded

% Calculate mean and covariance of the 'good' data features
mu_baseline = mean(normal_data_features);
sigma_baseline = cov(normal_data_features);

% Check and handle potential singularity/ill-conditioning of covariance matrix
matrix_condition = rcond(sigma_baseline);
if matrix_condition < eps % Check reciprocal condition number (eps is machine epsilon)
  warning('Covariance matrix is ill-conditioned or singular (rcond=%.2e). Adding small regularization (identity matrix * 1e-6). Results might be affected.', matrix_condition);
  sigma_baseline = sigma_baseline + eye(num_features) * 1e-6;
end

% Calculate the inverse covariance matrix needed for Mahalanobis distance
try
  inv_sigma_baseline = inv(sigma_baseline);
catch ME
  error('Could not invert the covariance matrix of "good" data features. Check data variance or selected features. Error: %s', ME.message);
end
disp("   Baseline mean and inverse covariance calculated.");

% Calculate detection threshold using Chi-squared distribution
threshold = chi2inv(confidence_level, num_features);
fprintf('Calculated Mahalanobis distance squared threshold: %.4f (based on %.2f%% confidence)\n', threshold, confidence_level*100);
disp("--- Anomaly Detection Baseline Ready ---");


% --- 5. Detection Phase (Simulated Real-time Classification) ---
fprintf('Applying detection model to all %d samples...\n', num_samples);
mahal_distances_sq = zeros(num_samples, 1);
predictions = zeros(num_samples, 1); % 0 = predicted normal (good), 1 = predicted threat (bad)

for i = 1:num_samples
  point_features = feature_matrix(i, :);
  delta = point_features - mu_baseline; % Difference from the mean of 'good' data

  % Calculate Mahalanobis distance squared (scalar value)
  mahal_distances_sq(i) = delta * inv_sigma_baseline * delta';

  % Classify: If distance is greater than threshold, predict as threat ('bad')
  if mahal_distances_sq(i) > threshold
    predictions(i) = 1; % Predicted as 'bad'
  else
    predictions(i) = 0; % Predicted as 'good'
  end
end
disp("--- Detection Phase Complete ---");


% --- 6. Evaluation ---
fprintf('Evaluating prediction performance...\n');
TP = sum(predictions == 1 & ground_truth == 1); % True Positives: Correctly predicted 'bad'
FP = sum(predictions == 1 & ground_truth == 0); % False Positives: Incorrectly predicted 'bad' (good mistaken for bad)
TN = sum(predictions == 0 & ground_truth == 0); % True Negatives: Correctly predicted 'good'
FN = sum(predictions == 0 & ground_truth == 1); % False Negatives: Incorrectly predicted 'good' (bad mistaken for good)

total_points = num_samples;
Accuracy = (TP + TN) / total_points;

% Calculate Precision, Recall, F1-Score, handling potential division by zero
if (TP + FP) > 0
  Precision = TP / (TP + FP);
else
  Precision = NaN; % Define as NaN if denominator is zero
  warning('Precision cannot be calculated (no positive predictions).');
end
if (TP + FN) > 0
  Recall = TP / (TP + FN); % Also called Sensitivity or True Positive Rate
else
  Recall = NaN; % Define as NaN if denominator is zero
   warning('Recall cannot be calculated (no actual positive samples).');
end
if ~isnan(Precision) && ~isnan(Recall) && (Precision + Recall) > 0
    F1_Score = 2 * (Precision * Recall) / (Precision + Recall);
else
    F1_Score = NaN;
end

disp("--- Evaluation Complete ---");

% --- 7. Display Outputs ---
fprintf('\n-------------------- Simulation Outputs --------------------\n');
fprintf('Total Valid Samples Processed: %d (Good: %d, Bad: %d)\n', total_points, num_good, num_bad);
fprintf('Number of Features Used in Model: %d\n', num_features);
fprintf('Mahalanobis Distance Threshold Used: %.4f\n', threshold);
fprintf('\n');
fprintf('Confusion Matrix:\n');
fprintf('                     Predicted Good | Predicted Bad\n');
fprintf('---------------------|----------------|--------------\n');
fprintf('Actual Good (TN, FP) |    TN = %-5d |    FP = %-5d\n', TN, FP);
fprintf('Actual Bad  (FN, TP) |    FN = %-5d |    TP = %-5d\n', FN, TP);
fprintf('\n');
fprintf('Performance Metrics:\n');
fprintf('  Accuracy:  %.4f (%.2f%%)\n', Accuracy, Accuracy*100);
fprintf('  Precision: %.4f (Fraction of predicted bad that were actually bad)\n', Precision);
fprintf('  Recall:    %.4f (Fraction of actual bad that were correctly detected)\n', Recall);
fprintf('  F1 Score:  %.4f (Harmonic mean of Precision and Recall)\n', F1_Score);
fprintf('-----------------------------------------------------------\n');


% --- 8. Generate Visualizations ---
if plot_results
    fprintf('Generating visualizations...\n');

    % --- Plot 1: Mahalanobis Distances for All Samples ---
    try
        figure; % Create new figure window
        plot(find(ground_truth==0), mahal_distances_sq(ground_truth==0), 'bo', 'DisplayName', 'Good Samples');
        hold on;
        plot(find(ground_truth==1), mahal_distances_sq(ground_truth==1), 'rx', 'DisplayName', 'Bad Samples');
        plot([1 total_points], [threshold threshold], 'g--', 'LineWidth', 1.5, 'DisplayName', 'Detection Threshold');
        hold off;
        title('Anomaly Score (Mahalanobis Distance^2) for Each Sample');
        xlabel('Sample Index');
        ylabel('Distance Squared');
        legend('show', 'Location', 'best');
        grid on;
        % Use log scale if distances vary greatly, makes threshold more visible
        if ~isempty(mahal_distances_sq) && min(mahal_distances_sq(mahal_distances_sq>0)) > 0 && max(mahal_distances_sq) / min(mahal_distances_sq(mahal_distances_sq>0)) > 1000
            set(gca, 'YScale', 'log');
            ylabel('Distance Squared (Log Scale)');
        end
        disp("   Generated Mahalanobis distance plot.");
    catch Plot_ME_1
        warning("Could not generate Mahalanobis distance plot: %s", Plot_ME_1.message);
    end

    % --- Plot 2: 2D Scatter Plot (ONLY if exactly 2 features were selected) ---
    if num_features == 2
        try
            figure; % Create new figure window
            hold on;

            % Plot actual good and bad points
            plot(feature_matrix(good_indices, 1), feature_matrix(good_indices, 2), 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'Good (Actual)');
            plot(feature_matrix(bad_indices, 1), feature_matrix(bad_indices, 2), 'rx', 'MarkerSize', 7, 'DisplayName', 'Bad (Actual)');

            % Mark the points *predicted* as threats (Bad) with black stars
            predicted_bad_indices = find(predictions == 1);
            plot(feature_matrix(predicted_bad_indices, 1), feature_matrix(predicted_bad_indices, 2), ...
                 'k*', 'MarkerSize', 10, 'LineWidth', 1, 'DisplayName', 'Predicted as Bad');

            % Plot the decision boundary ellipse
            angles = linspace(0, 2*pi, 100);
            ellipse_pts_unit_circle = [cos(angles); sin(angles)]; % Points on unit circle
            try
                % Use Cholesky decomposition of covariance scaled by threshold to transform unit circle
                [R, chol_flag] = chol(sigma_baseline * threshold);
                if chol_flag == 0 % Check if Cholesky decomposition was successful (matrix was positive definite)
                    ellipse_pts = (R' * ellipse_pts_unit_circle)' + repmat(mu_baseline, 100, 1); % Transform and shift
                    plot(ellipse_pts(:, 1), ellipse_pts(:, 2), 'g--', 'LineWidth', 1.5, 'DisplayName', 'Detection Boundary');
                else
                    warning('Covariance matrix (scaled by threshold) not positive definite. Cannot plot decision boundary ellipse.');
                end
            catch Chol_ME
                 warning('Cholesky decomposition failed during plotting: %s. Cannot plot decision boundary ellipse.', Chol_ME.message);
            end

            feature_name_1 = sprintf("Feature %d", feature_indices_to_use(1));
            feature_name_2 = sprintf("Feature %d", feature_indices_to_use(2));
            title(sprintf('Phishing Detection Simulation (%s vs %s)', feature_name_1, feature_name_2));
            xlabel(feature_name_1);
            ylabel(feature_name_2);
            legend('show', 'Location', 'best');
            grid on;
            % Consider axis equal if scales are similar, otherwise let Octave decide
            % axis equal;
            hold off;
            disp("   Generated 2D scatter plot.");

        catch Plot_ME_2
            warning("Could not generate 2D scatter plot: %s", Plot_ME_2.message);
        end
    elseif num_features ~= 2
       fprintf('\n   Skipping 2D scatter plot visualization because %d features were selected (requires exactly 2).\n', num_features);
    end
    fprintf('Visualizations generated (if enabled and possible).\n');
else
    fprintf('Plotting is disabled.\n');
end

disp("--- Phishing Detection Simulation Script Finished ---");
