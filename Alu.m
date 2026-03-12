%% ALU Kelvin configuration: I-V (x=U, y=I), all points + 3 fits only for |U|<=0.02 V
% Output slopes a = dI/dU for: 2P, 4P, and (2P+4P)
clear; clc; close all;

%% ===== Parameters =====
stem2p = "ALU_2P_Kennlinie";
stem4p = "ALU_4P_Kennlinie";

U_fit_lim = 0.02;           % Fit range: |U|<=0.02 V
markerSize = 6;
lineWidth  = 3.0;

U_full_xlim = [-0.2 0.2];   % Full U range for plot (similar to your classmate's figure); set [] if not needed

%% ===== Find files and read data =====
file2p = find_file(stem2p);
file4p = find_file(stem4p);

[I2, U2] = read_IV(file2p);
[I4, U4] = read_IV(file4p);

%% ===== Select fit points (use only |U|<=0.02 V) =====
m2 = abs(U2) <= U_fit_lim;
m4 = abs(U4) <= U_fit_lim;

U2_fit = U2(m2); I2_fit = I2(m2);
U4_fit = U4(m4); I4_fit = I4(m4);

Uall_fit = [U2_fit; U4_fit];
Iall_fit = [I2_fit; I4_fit];

%% ===== Perform separate fits: I = a*U + b =====
[p2, st2]     = fit_line(U2_fit, I2_fit);
[p4, st4]     = fit_line(U4_fit, I4_fit);
[pall, stall] = fit_line(Uall_fit, Iall_fit);

a2 = p2(1); b2 = p2(2);   R2 = 1/a2;
a4 = p4(1); b4 = p4(2);   R4 = 1/a4;
aAll = pall(1); bAll = pall(2);  RAll = 1/aAll;

%% ===== Print the three slopes =====
fprintf("\n==== Fits only for |U|<=%.3f V ====\n", U_fit_lim);

fprintf("2P:  a2 = dI/dU = %.6g 1/Ohm,  b2 = %.6g A,  R2 = %.6g Ohm,  R^2 = %.6f\n", ...
    a2, b2, R2, st2.R2);

fprintf("4P:  a4 = dI/dU = %.6g 1/Ohm,  b4 = %.6g A,  R4 = %.6g Ohm,  R^2 = %.6f\n", ...
    a4, b4, R4, st4.R2);

fprintf("ALL: a  = dI/dU = %.6g 1/Ohm,  b  = %.6g A,  R  = %.6g Ohm,  R^2 = %.6f\n", ...
    aAll, bAll, RAll, stall.R2);

%% ===== Plot: all points + three fit lines (draw only in the central ±0.02 V range) =====
figure; hold on; grid on;

% All points (full range)
plot(U2, I2, 'o', 'MarkerSize', markerSize, 'DisplayName', 'Two-point measurement (2P)');
plot(U4, I4, 's', 'MarkerSize', markerSize, 'DisplayName', 'Four-point measurement (4P)');

% Fit lines drawn only for |U|<=0.02
Uline = linspace(-U_fit_lim, U_fit_lim, 300);

plot(Uline, a2*Uline + b2, '-', 'LineWidth', lineWidth, ...
    'DisplayName', sprintf('Fit 2P (|U|<=%.2f V): a = %.3g 1/\\Omega', U_fit_lim, a2));



plot(Uline, a4*Uline + b4, '-', 'LineWidth', lineWidth, ...
    'DisplayName', sprintf('Fit 4P (|U|<=%.2f V): a = %.3g 1/\\Omega', U_fit_lim, a4));

plot(Uline, aAll*Uline + bAll, '-', 'LineWidth', lineWidth, ...
    'DisplayName', sprintf('Combined fit: a = %.3g 1/\\Omega', aAll));

xlabel('Voltage in V');
ylabel('Current in A');
title('ALU I-V characteristic: all points + fits in the linear region |U|\le 0.02 V');
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

if ~isempty(U_full_xlim)
    xlim(U_full_xlim);
end

legend('Location', 'best');

%% ========================= Functions =========================
function fname = find_file(stem)
    exts = [".xlsx", ".xls", ".csv", ".txt"];
    for e = exts
        d = dir(stem + "*" + e);
        if ~isempty(d)
            fname = d(1).name;
            return;
        end
    end
    error("File not found: %s*.xlsx/csv/txt", stem);
end

function [I, U] = read_IV(fname)
    try
        T = readtable(fname);
    catch
        opts = detectImportOptions(fname);
        try, opts.Delimiter = ';'; end
        T = readtable(fname, opts);
    end

    X = table2array(T);
    if size(X,2) < 2
        error("File %s must contain at least two numeric columns (U and I)", fname);
    end

    names = lower(string(T.Properties.VariableNames));
    colI = find(contains(names, "i"), 1);
    colU = find(contains(names, ["u", "v"]), 1);

    if ~isempty(colI) && ~isempty(colU) && colI ~= colU
        I = X(:, colI);
        U = X(:, colU);
    else
        U = X(:,1);
        I = X(:,2);
    end

    m = ~(isnan(I) | isnan(U));
    I = I(m); 
    U = U(m);
end

function [p, stats] = fit_line(x, y)
    p = polyfit(x, y, 1);      % y = p1*x + p2
    yfit = polyval(p, x);
    SSres = sum((y - yfit).^2);
    SStot = sum((y - mean(y)).^2);  %#ok<*NOPTS>
    stats.R2 = 1 - SSres/SStot;
end
