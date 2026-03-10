files  = {'D8.3_Kennlinie.csv','D8_flip_sweep_Kennlinie.csv'};
labels = {'D8 normaler Sweep','D8 umgekehrter Sweep'};

figure(2); clf;
hold on; grid on; grid minor; box on;

for k = 1:numel(files)
    M = readmatrix(files{k});
    V = M(:,1);
    I = M(:,2);

    Y = abs(I);
    Y(Y<=0) = 1e-12;              % avoid log(0)

    semilogy(V, Y, 'o');          % 
end

set(gca,'YScale','log');          % non-linear
xlim([-1 1]);
ylim([1e-10 1e-1]);               % 

xlabel('Voltage in V');
ylabel('Current in A');
legend(labels,'Location','northwest');