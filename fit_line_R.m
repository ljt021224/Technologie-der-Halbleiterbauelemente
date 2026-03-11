%% D4: Determination of ideality factor m and saturation current Is
% Fit in the exponential forward region: 0.40 V <= U <= 0.70 V

clear; clc;

% ===== 1) Read data =====
M = readmatrix('D9_Kennlinie.csv');   % For semicolon CSV: readmatrix('D4_Kennlinie.csv','Delimiter',';')
U = M(:,1);   % Voltage [V]
I = M(:,2);   % Current [A]

% ===== 2) Unify current direction (make forward current I > 0) =====
if mean(I(U>0)) < 0
    I = -I;
end

% ===== 3) Select exponential region (avoid reverse bias, avoid log(<=0)) =====
Umin = 0.40;
Umax = 0.70;
idx = (U>=Umin) & (U<=Umax) & (I>0);

Uf = U(idx);          % Fit-U [V]
If = I(idx);          % Fit-I [A]
y  = log(If);         % y = ln(I / 1A) (numerically: ln(I))

if numel(Uf) < 3
    error('Too few fit points: please check Umin/Umax or the sign of the forward current in the data.');
end

% ===== 4) Linear fit: ln(I) = a*U + b =====
p = polyfit(Uf, y, 1);
a = p(1);     % slope
b = p(2);     % intercept

% ===== 5) Compute m and Is from slope/intercept =====
UT = 0.0259;          % Thermal voltage at ~300 K [V]
m  = 1/(a*UT);
Is = exp(b);          % [A]

% ===== 6) Plot (report style) =====
figure(1); clf; hold on; grid on; box on;

% Data points (lnI vs U)
plot(Uf, y, 'o', 'DisplayName', 'Measured data: $\ln(I)$', ...
    'LineWidth', 1.2, 'MarkerSize', 6);

% Fit line
Uline = linspace(min(Uf), max(Uf), 200);
plot(Uline, polyval(p, Uline), '-', 'DisplayName', ...
    sprintf('Linear fit (%.2f--%.2f V)', Umin, Umax), ...
    'LineWidth', 1.6);

% Axes labels and title (with units)
xlabel('Forward voltage $U$ (V)', 'Interpreter','latex');
ylabel('$\ln(I / 1\,\mathrm{A})$ (-)', 'Interpreter','latex');
title('Diode D4: Determination of $m$ and $I_s$ from $\ln(I)$-$U$ fit', 'Interpreter','latex');

legend('Location','best');

% Annotate results on the plot
txt = sprintf('slope a = %.4f 1/V\nm = %.3f\nI_s = %.3e A', a, m, Is);
text(0.05, 0.85, txt, 'Units','normalized');

% ===== 7) Command window output (for copying into the report table) =====
fprintf('D4 Fit (U=%.2f..%.2f V):\n', Umin, Umax);
fprintf('  slope a = %.6f 1/V\n', a);
fprintf('  intercept b = %.6f\n', b);
fprintf('  m = %.6f\n', m);
fprintf('  Is = %.6e A\n', Is);

% ===== Optional: open Curve Fitting Tool for the same data (only if available) =====
cftool(Uf, y);
