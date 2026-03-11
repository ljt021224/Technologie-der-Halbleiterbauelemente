% ===== MIS-Dioden: Leckstrom-Kennlinien (C16, C18, C19, C21) halblogarithmisch =====

files  = {'C16_Leckstrom_Kennlinie.csv', ...
          'C18_Leckstrom_Kennlinie.csv', ...
          'C19_Leckstrom_Kennlinie.csv', ...
          'C21_Leckstrom_Kennlinie.csv'};

labels = {'C16 Leckstrom', 'C18 Leckstrom', 'C19 Leckstrom', 'C21 Leckstrom'};

figure(1); clf;
hold on; grid on; grid minor; box on;

for k = 1:numel(files)
    M = readmatrix(files{k});   % falls Semikolon-CSV: readmatrix(files{k},'Delimiter',';')
    U = M(:,1);                 % Voltage
    I = M(:,2);                 % Current

    Y = abs(I);
    Y(Y<=0) = 1e-12;            % ключ: avoid log(0)

    semilogy(U, Y, 'o');        % halblogarithmisch (Punkte)
end

set(gca,'YScale','log');        % nochmal erzwingen
xlim([-20 20]);                 % laut Aufgabenstellung
ylim([1e-12 1e-6]);              % bis 1 µA = 1e-6 A (kannst du anpassen)

xlabel('Voltage in V');
ylabel('Leckstrom |I| in A');
legend(labels,'Location','northwest');
title('MIS-Dioden: Leckstrom-Kennlinien (C16, C18, C19, C21)');

% optional: 1 µA Grenzlinie einzeichnen
yline(1e-6,'--','I = 1 \muA','LabelHorizontalAlignment','left');

set(gca,'FontSize',14)
axis padded
lgd.FontSize = 14;   % increase size

grid on
grid minor

ax = gca;

ax.YScale = 'log';

ax.YMinorTick = 'on';
ax.YMinorGrid = 'on';

ax.GridLineStyle = '-';        
ax.MinorGridLineStyle = ':';   

ax.GridAlpha = 0.4;            
ax.MinorGridAlpha = 0.2;
