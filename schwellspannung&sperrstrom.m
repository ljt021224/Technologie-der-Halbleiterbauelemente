% ===== Uth & Isp scatter plots (like your Abbildung 2.5 / 2.6) =====
clear; clc;

names = {'D4','D5','D8','D9'};
x = 1:numel(names);


Uth = [0.66, 0.66, 0.66, 0.66];                 % [V]
Isp = [4.58e-8, 1.26e-7, 6.55e-8, 1.75e-7];      % [A]  (用绝对值)

% ===== 图1：Schwellenspannung Uth =====
figure(1); clf; hold on; grid on; box on;
for k = 1:numel(x)
    plot(x(k), Uth(k), 'o', 'MarkerSize', 9, 'LineWidth', 1.5);
end
xlim([0.5 numel(x)+0.5]);
set(gca, 'XTick', x, 'XTickLabel', names);
xlabel('Diode');
ylabel('Schwellenspannung U_{th} in V');
title('Schwellenspannung der Dioden D4, D5, D8, D9');
set(gca,'FontSize',14)
axis padded
lgd.FontSize = 14;   % increase size

grid on
grid minor

ax = gca;

ax.YScale = 'linear';

ax.YMinorTick = 'on';
ax.YMinorGrid = 'on';

ax.GridLineStyle = '-';        
ax.MinorGridLineStyle = ':';   

ax.GridAlpha = 0.4;            
ax.MinorGridAlpha = 0.2;


% ===== 图2：Sperrstrom Isp（半对数）=====
figure(2); clf; hold on; grid on; grid minor; box on;
for k = 1:numel(x)
    semilogy(x(k), abs(Isp(k)), 'o', 'MarkerSize', 9, 'LineWidth', 1.5);
end
xlim([0.5 numel(x)+0.5]);
set(gca, 'XTick', x, 'XTickLabel', names);
xlabel('Diode');
ylabel('Sperrstrom |I_{sp}| in A');
title('Sperrstrom der Dioden D4, D5, D8, D9');

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
