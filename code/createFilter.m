%createFilter.m
function [filter] = createFilter(sigma) 
% Code to generate reasonable laplacian filter with given sigma value

    % gaussianScales = [1 2 4 8 sqrt(2)*8];
    % logScales      = [1 2 4 8 sqrt(2)*8];
    logScale      = sigma;
    % dxScales       = [1 2 4 8 sqrt(2)*8];
    % dyScales       = [1 2 4 8 sqrt(2)*8];

    % filterBank = cell(numel(gaussianScales) + numel(logScales) + numel(dxScales) + numel(dyScales),1);
    filterBank = cell(numel(logScale),1);

    idx = 0;

    % for scale = gaussianScales
    %     idx = idx + 1;
    %     filterBank{idx} = fspecial('gaussian', 2*ceil(scale*2.5)+1, scale);
    % end

    for scale = logScale
        idx = idx + 1;
        filter{idx} = sigma^2*fspecial('log', 2*ceil(scale*2.5)+1, scale);%matrix size is odd
    end

    % for scale = dxScales
    %     idx = idx + 1;
    %     f = fspecial('gaussian', 2*ceil(scale*2.5) + 1, scale);
    %     f = imfilter(f, [-1 0 1], 'same');
    %     filterBank{idx} = f;
    % end

    % for scale = dyScales
    %     idx = idx + 1;
    %     f = fspecial('gaussian', 2*ceil(scale*2.5) + 1, scale);
    %     f = imfilter(f, [-1 0 1]', 'same');
    %     filterBank{idx} = f;
    % end

end
