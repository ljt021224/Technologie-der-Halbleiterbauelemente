%% Aufgabe 2: U_th und I_sp aus 4 I-V Kennlinien bestimmen und plotten
%  - U_th = U bei I = 1 mA (Vorwärtszweig, I>0, U>0) per Interpolation
%  - I_sp = I bei U = -1 V (Sperrbetrieb, U<0) per Interpolation
%  - Plot als Messpunkte (ohne Linien), "report style"

clear; clc;

% ========= 1) Dateien einstellen =========
files  = {'D4_Kennlinie.csv','D5_Kennlinie.csv','D8_Kennlinie.csv','D9_Kennlinie.csv'};
names  = {'D4','D5','D8','D9'};

% Falls deine CSV mit Semikolon getrennt ist: delimiter = ';' sonst ','
delimiter = ',';   % ggf. auf ';' ändern

I_target = 1e-3;   % 1 mA
U_target = -1;     % -1 V

Uth = NaN(1,numel(files));
Isp = NaN(1,numel(files));

% ========= 2) Auswertung =========
for k = 1:numel(files)
    % --- Daten einlesen ---
    M = readmatrix(files{k}, 'Delimiter', delimiter);
    U = M(:,1);
    I = M(:,2);

    % --- U_th bestimmen: U bei I = 1 mA (Vorwärtszweig) ---
    idxF = (U > 0) & (I > 0);
    Uf = U(idxF);
    If = I(idxF);

    if numel(Uf) < 2
        warning('%s: zu wenige Vorwärts-Punkte für U_th.', names{k});
        Uth(k) = NaN;
    else
        % sortiere nach Strom
        [Ifs, ord] = sort(If);
        Ufs = Uf(ord);

        % interp1 braucht eindeutige X-Werte -> Duplikate entfernen
        [Ifu, ia] = unique(Ifs, 'stable');
        Ufu = Ufs(ia);

        % nur interpolieren, wenn I_target im Bereich liegt
        if I_target < min(Ifu) || I_target > max(Ifu)
            warning('%s: I_target=1mA liegt außerhalb des Messbereichs.', names{k});
            Uth(k) = NaN;
        else
            Uth(k) = interp1(Ifu, Ufu, I_target, 'linear');
        end
    end

    % --- I_sp bestimmen: I bei U = -1 V (Sperrbetrieb) ---
    idxR = (U < 0);
    Ur = U(idxR);
    Ir = I(idxR);

    if numel(Ur) < 2
        warning('%s: zu wenige Sperr-Punkte für I_sp.', names{k});
        Isp(k) = NaN;
    else
        % sortiere nach Spannung
        [Urs, ord2] = sort(Ur);
        Irs = Ir(ord2);

        % Duplikate entfernen (zur Sicherheit)
        [Uru, ia2] = unique(Urs, 'stable');
        Iru = Irs(ia2);

        Isp(k) = interp1(Uru, Iru, U_target, 'linear', 'extrap');
    end
end

% ========= 3) Tabelle ausgeben =========
T = table(names(:), Uth(:), Isp(:), abs(Isp(:)), ...
    'VariableNames', {'Diode','Uth_V','Isp_A','absIsp_A'});
disp(T);

% ========= 4) Plot-Style Einstellungen =========
x = 1:numel(names);
colors = lines(numel(names));
ms = 10;     % marker size
lw = 1.6;    % marker edge width

% ========= 5) Plot 1: U_th (linear) =========
figure(1); clf;
hold on; box on; grid on;
set(gca, 'GridAlpha',0.25, 'FontSize',12, 'LineWidth',1.0);
for k = 1:numel(names)
    plot(x(k), Uth(k), 'o', ...
        'MarkerSize', ms, ...
        'LineWidth', lw, ...
        'MarkerEdgeColor', colors(k,:), ...
        'MarkerFaceColor', 'none');
end
xlim([0.5, numel(names)+0.5]);
xticks(x); xticklabels(names);
xlabel('Diode');
ylabel('Schwellenspannung $U_{th}$ in V', 'Interpreter','latex');

% y-range mit Rand
yr = max(Uth(~isnan(Uth))) - min(Uth(~isnan(Uth)));
if isempty(yr) || yr==0, yr = 1e-3; end
ymin = min(Uth(~isnan(Uth))) - 0.15*yr;
ymax = max(Uth(~isnan(Uth))) + 0.15*yr;
ylim([ymin ymax]);

% ========= 6) Plot 2: I_sp (LOG y-Achse, wie dein Screenshot) =========
figure(2); clf;
hold on; box on; grid on; grid minor;
set(gca, 'YScale','log', 'GridAlpha',0.25, 'FontSize',12, 'LineWidth',1.0);

Iabs = abs(Isp);
for k = 1:numel(names)
    plot(x(k), Iabs(k), 'o', ...
        'MarkerSize', ms, ...
        'LineWidth', lw, ...
        'MarkerEdgeColor', colors(k,:), ...
        'MarkerFaceColor', 'none');
end

xlim([0.5, numel(names)+0.5]);
xticks(x); xticklabels(names);
xlabel('Diode');
ylabel('Sperrstrom $|I_{sp}|$ in A', 'Interpreter','latex');

% y-limits wie Screenshot (du kannst anpassen)
ylim([1e-9 1e-4]);
