clear; clc; close all;

M = readmatrix(['C18_10V_Kapazität.csv']);

frequencies = M(1, 2:end);
V = M(2:end, 1);
Cp = M(2:end, 2:end);
leg = cell(1, length(frequencies));
for i = 1:length(frequencies)
    leg{i} = sprintf('%g kHz', frequencies(i)*1e-3);
end

figure;
plot(V, Cp, 'LineWidth', 1.5);
xlabel('Gate Voltage (V)');
ylabel('Capacitance (pF)');
title('C-V Kennlinien');
legend(leg, 'Location', 'best');
grid on;
