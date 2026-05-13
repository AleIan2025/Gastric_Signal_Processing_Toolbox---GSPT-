function TC = total_corr_general(signals, a)
% TOTAL_CORR_GENERAL  Compute total correlation for arbitrary number of channels.
% Accepts either:
%   - signals: cell array {chan1, chan2, ...} where each is vector [N x 1] or [1 x N]
%   - signals: matrix [N x nCh] where columns are channels
% a is the Rényi parameter (commonly 2)
%
% Returns scalar TC.
% Comments and vectorized computations optimized for efficiency.

% Normalize inputs: convert matrix -> cell array of column vectors
if ~iscell(signals)
    if ndims(signals) > 2
        error('total_corr_general: unsupported signal array dimensions.');
    end
    % assume signals is [N x nCh]
    signals = num2cell(signals, 1); % 1 x nCh cell, each cell [N x 1]
else
    % ensure each cell is a column vector
    for k = 1:numel(signals)
        x = signals{k};
        if isrow(x)
            signals{k} = x(:);
        end
    end
end

nCh = numel(signals);
if nCh < 2
    error('total_corr_general: need at least 2 channels.');
end
nSamp = length(signals{1});

% Preallocate
A = cell(1, nCh);

% Build normalized kernel matrices (vectorized)
for i = 1:nCh
    x = signals{i}(:);            % ensure column
    if length(x) ~= nSamp
        error('total_corr_general: all signals must have the same length.');
    end

    % Silverman bandwidth (use std; guard against zero std)
    s = 1.06 * std(x);
    if s == 0
        s = eps;
    end

    % Gaussian Gram matrix
    % compute squared distance using bsxfun-like vectorization
    % use (x - x')^2
    dist_sq = (x - x').^2;        % MATLAB broadcasts columns -> row implicitly (OK for column vectors)
    G = exp(-dist_sq / (2 * s));

    % Normalized kernel matrix A_i = G_ij / sqrt(G_ii * G_jj)
    diagG = diag(G);
    A{i} = bsxfun(@rdivide, G, sqrt(diagG * diagG')); % result [N x N]

    % Normalize by number of samples
    A{i} = A{i} / nSamp;
end

% Compute TC
if a == 2
    % Efficient computation for a==2
    % compute flattened inner products tAi = <A_i, A_i>
    tAi = zeros(1, nCh);
    for i = 1:nCh
        Ai = A{i};
        tAi(i) = Ai(:)' * Ai(:);
    end

    % compute full product P_all = A1*A2*...*An
    P_all = A{1};
    for i = 2:nCh
        P_all = P_all * A{i};
    end
    tAll = P_all(:)' * P_all(:);

    % compute pair product P_half1 and P_half2 to mimic original formula (avoid bias)
    mid = ceil(nCh/2);
    P1 = A{1};
    for i = 2:mid
        P1 = P1 * A{i};
    end
    if mid+1 <= nCh
        P2 = A{mid+1};
        for i = mid+2:nCh
            P2 = P2 * A{i};
        end
        t12 = P1(:)' * P2(:);
    else
        % odd number and mid==nCh -> set t12 = trace(P1*P1) as fallback
        t12 = P1(:)' * P1(:);
    end

    % compute TC using same formula shape as original
    TC = sum((1/(1-a)) * log2(tAi)) - (1/(1-a)) * log2(tAll / (t12^2));
else
    % General Rényi exponent a
    traces = zeros(1, nCh);
    for i = 1:nCh
        traces(i) = trace(A{i}^a);
    end

    P = A{1};
    for i = 2:nCh
        P = P * A{i};
    end
    P = P / trace(P);

    TC = sum((1/(1-a)) * log2(traces)) - (1/(1-a)) * log2(trace(P^a));
end

end

