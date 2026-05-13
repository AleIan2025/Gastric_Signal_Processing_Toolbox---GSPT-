function H = GradEn(img, params)
    % Gradient Entropy (GradEn) per immagini 2D
    % Implementazione basata su https://arxiv.org/pdf/2502.18516
    %
    % Input:
    %   img    : Immagine in scala di grigi (H x W)
    %   params : Struttura con parametri (opzionale)
    %            - delta: Soglia inferiore (default: 25° percentile)
    %            - gamma: Soglia superiore (default: 75° percentile)
    % Output:
    %   H      : Valore di GradEn normalizzato

    % 1. Preprocessing
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = double(img);
    [H, W] = size(img);
    
    % 2. Calcolo gradienti orizzontali, verticali e diagonali
    Gh = img(1:end-1, 2:end)   - img(1:end-1, 1:end-1); % Orizzonte
    Gv = img(2:end, 1:end-1)   - img(1:end-1, 1:end-1); % Verticale
    Gd = img(2:end, 2:end)     - img(1:end-1, 1:end-1); % Diagonale
    
    % 3. Standardizzazione z-score
    G = [Gh(:), Gv(:), Gd(:)];
    mu = mean(G, 1);
    sigma = std(G, 0, 1);
    sigma(sigma == 0) = eps; % Evita divisione per zero
    GS = (G - mu) ./ sigma;
    
    % 4. Calcolo soglie delta e gamma (25° e 75° percentile)
    abs_GS = abs(GS(:));
    if nargin < 2 || ~isfield(params, 'delta')
        delta = prctile(abs_GS, 25);
        gamma = prctile(abs_GS, 75);
    else
        delta = params.delta;
        gamma = params.gamma;
    end

    %{
    disp('TFR size is:')
    size(abs_GS)
    disp('delta size is:')
    size(delta)
    disp('gamma size is:')
    size(gamma)

    disp('abs_GS nulli?')
    any(isnan(abs_GS))

    disp('Max and min for abs_GS')
    max(abs_GS)
    min(abs_GS)

    disp('delta and gamma values are')
    delta
    gamma

    %}

    % Controllo monotonicità
    if delta >= gamma
        delta = gamma - eps; % Assicura monotonicità
    end
    
    % 5. Mappatura simbolica [-2, -1, 0, 1, 2]
    edges = [-Inf, -gamma, -delta, delta, gamma, Inf];
    symbols = [-2, -1, 0, 1, 2];
    symb_map = zeros(size(GS));
    
    for k = 1:3
        symb_map(:,k) = discretize(GS(:,k), edges, symbols);
    end
    
    % 6. Codifica pattern univoci (base-5)
    symb_shift = symb_map + 2; % Trasforma in [0-4]
    patterns = symb_shift(:,1)*25 + symb_shift(:,2)*5 + symb_shift(:,3);
    
    % 7. Calcolo entropia
    [counts, ~] = histcounts(patterns, 0:125);
    prob = counts / sum(counts);
    prob = prob(prob > 0); % Rimuovi zeri
    
    H = -sum(prob .* log(prob)) / log(5); % Normalizza con log(5)
end