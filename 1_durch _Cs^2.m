clear; clc;

fname = 'D5_10p_Kapazität.csv';   % 或 .csv
M = readmatrix(fname);

% 
freq = M(1,2:6);                % [Hz]  500000,100000,...

% 
U = M(2:end,1);                 %  [V]
C_pF = M(2:end,2:6);            %  [pF]

labels = arrayfun(@(f) sprintf('%.1f kHz', f/1e3), freq, 'UniformOutput', false);

figure(1); clf; hold on; grid on; box on;

for k = 1:size(C_pF,2)
    C_s = C_pF(:,k) * 1e-12;     % pF -> F
    Y  = 1 ./ (C_s.^2);          % 1/Cs^2

    plot(U, Y, 'o-', 'LineWidth', 1.2, 'MarkerSize', 5, ...
        'DisplayName', labels{k});
end

xlabel('U (V)');
ylabel('1/C_s^2 (1/F^2)');
title('D5: 1/C_s^2--U (alle Frequenzen)');
legend('Location','best');
