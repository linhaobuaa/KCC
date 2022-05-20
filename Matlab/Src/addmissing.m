function newIDX = addmissing(IDX, percent)
%==========================================================================
% FUNCTION: newIDX = addmissing(IDX,percent)
% DESCRIPTION: This function randomly removes some labels from complete basic partitions
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions
%           percent = missing rate, ranges in [0, 1]
%
% OUTPUT:   newIDX = incomplete basic partition matrix
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    [n, m] = size(IDX);
    if percent <= 1
        num = ceil(n * percent);
        for i = 1 : m
            IDX(randsample(n, num), i) = 0; 
        end
        newIDX = IDX;
    else
        error('Percent should NOT be more than 1.');
    end
end