function [pdf, x] = ExtractGaussian(imds, varargin)
% ExtractGaussian: Computes Gaussian density estimate (pdf) for images in ImageDatastore.
%
% Syntax:
%   [pdf, x] = ExtractGaussian(imds)
%   [pdf, x] = ExtractGaussian(imds, Name, Value)
%
% Description:
%   ExtractGaussian computes the Gaussian density estimate (pdf) for grayscale images
%   in the ImageDatastore `imds`. It filters images by specified extensions, converts them
%   to grayscale if necessary, computes the mean and standard deviation for each image, 
%   and returns pdf values and corresponding x values.
%
% Input Arguments:
%   imds - A matlab.io.datastore.ImageDatastore object containing images.
%
% Optional Name-Value Pair Arguments:
%   'numPoints'  - Number of points for Gaussian density estimation (default: 1000).
%   'extensions' - File extensions of images in ImageDatastore (default: {'.png'}).
%
% Output Arguments:
%   pdf - Gaussian density estimate values for each image.
%   x   - Points at which the Gaussian density estimate is evaluated.
%
% Example:
%   imds = imageDatastore('path_to_images');
%   [pdf, x] = ExtractGaussian(imds, 'numPoints', 500);
%
% See also:
%   normpdf, imageDatastore

% Set default values for optional parameters
defaultX = 1000;
defaultExtensions = {'.png'};

% Parse the input arguments
p = inputParser;
addRequired(p, 'imds', @(x) isa(x, 'matlab.io.datastore.ImageDatastore'));
addParameter(p, 'numPoints', defaultX, @isnumeric);
addParameter(p, 'extensions', defaultExtensions, @iscellstr);
parse(p, imds, varargin{:});

% Get parameter values
imgExtensions = p.Results.extensions;

pdf = [];

% Find all images in the ImageDatastore
imgFiles = imds.Files;

% Check if any images were found
if isempty(imgFiles)
    error('No images found in the ImageDatastore with extension %s', imgExtensions{1});
end

% Process each image in the ImageDatastore
for i = 1:length(imgFiles)
    fullName = imgFiles{i};
    img = imread(fullName);

    % Check if the file extension matches the specified extensions
    [~, ~, ext] = fileparts(fullName);
    if ~ismember(ext, imgExtensions)
        continue;
    end

    % Convert image to grayscale if it is RGB
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
    img_gray = double(img_gray);

    % Compute mean and standard deviation of the image
    mu_img = mean(img_gray(:));
    sig_img = std(img_gray(:));

    % Compute Gaussian density estimate
    x = linspace(-3, 2, p.Results.numPoints);
    pdf_img = normpdf(x, mu_img, sig_img);
    pdf(:, i) = pdf_img';
    
    % Display progress (optional function textwaitbar used here)
    textwaitbar(i, length(imgFiles));

end

end
