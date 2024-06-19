function [pdf, x] = ExtractKernel(imds, varargin)
% ExtractKernel: Computes kernel density estimate (pdf) for images in ImageDatastore.
%
% Syntax:
%   [pdf, x] = ExtractKernel(imds)
%   [pdf, x] = ExtractKernel(imds, Name, Value)
%
% Description:
%   ExtractKernel computes the kernel density estimate (pdf) for grayscale images
%   in the ImageDatastore `imds`. It filters images, computes bandwidth (h) for
%   kernel density estimation, and returns pdf values and corresponding x values.
%
% Input Arguments:
%   imds - A matlab.io.datastore.ImageDatastore object containing images.
%
% Optional Name-Value Pair Arguments:
%   'numPoints'  - Number of points for kernel density estimation (default: 1000).
%   'extensions' - File extensions of images in ImageDatastore (default: {'.png'}).
%
% Output Arguments:
%   pdf - Kernel density estimate values for each image.
%   x   - Points at which the kernel density estimate is evaluated.
%
% Example:
%   imds = imageDatastore('path_to_images');
%   [pdf, x] = ExtractKernel(imds, 'numPoints', 500);
%
% See also:
%   ksdensity, imageDatastore

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

    % Convert image to grayscale if it is RGB
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
    img_gray = double(img_gray);

    % Filter out values and compute kernel bandwidth (h)
    img_filtered = img_gray(img_gray > 10 & img_gray < 255);
    h = (4/3)^(1/5) * length(img_filtered).^(-1/5) * std(img_filtered);

    % Compute kernel density estimate
    [pdf_img, x] = ksdensity(img_filtered, 'Bandwidth', h, 'NumPoints', p.Results.numPoints);
    pdf(:, i) = pdf_img';
    
    % Display progress (optional function textwaitbar used here)
    textwaitbar(i, length(imgFiles));
end

end
