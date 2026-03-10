files  = {'D8_Kennlinie.csv','D8.1_Kennlinie.csv','D8.2_Kennlinie.csv','D8.3_Kennlinie.csv'};
labels = {'D8 Messung 1','D8 Messung 2','D8 Messung 3','D8 Messung4'};

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
