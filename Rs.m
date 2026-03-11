clear; clc;

files = {'D4_Kennlinie.csv','D5_Kennlinie.csv','D8_Kennlinie.csv','D9_Kennlinie.csv'};
names = {'D4','D5','D8','D9'};

Ucut = 0.70;   % Threshold for strong forward-bias region
Rs   = NaN(1,numel(files));
slope= NaN(1,numel(files));

for k = 1:numel(files)
    M = readmatrix(files{k});   % For semicolon CSV: readmatrix(files{k},'Delimiter',';')
    U = M(:,1);
    I = M(:,2);

    % Unify current direction: make forward current I > 0
    if mean(I(U>0)) < 0
        I = -I;
    end

    % Select strong forward-bias region
    idx = (U > Ucut) & (I > 0);
    Uf = U(idx);
    If = I(idx);

    if numel(Uf) < 3
        warning('%s: Too few points for U>0.7 V, cannot fit Rs', names{k});
        continue;
    end

    % Linear fit: I = a*U + b
    p = polyfit(Uf, If, 1);
    a = p(1);
    b = p(2);

    slope(k) = a;
    Rs(k) = 1/a;

    % Plot: one figure per diode (high-current I-U + fit line)
    figure(k); clf; hold on; grid on; box on;
    plot(U, I, '.', 'DisplayName','Measured data');
    plot(Uf, If, 'o', 'DisplayName',sprintf('U > %.2f V', Ucut));
    Uline = linspace(min(Uf), max(Uf), 200);
    plot(Uline, polyval(p,Uline), '-', 'LineWidth',1.6, 'DisplayName','Linear fit');

    xlabel('U (V)');
    ylabel('I (A)');
    title(sprintf('%s: I-U in strong forward bias (R_s \\approx %.2f \\Omega)', names{k}, Rs(k)));
    legend('Location','best');
end

% Output results table
T = table(names(:), slope(:), Rs(:), 'VariableNames', {'Diode','dI_dU_A_per_V','Rs_Ohm'});
disp(T);
