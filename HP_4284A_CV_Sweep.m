%% HP4284A LCR Meter SourceMeter.
%INPUT: One of the following Frequency values:  0.5  kHz
%                                                1   kHz
%                                               10   kHz
%                                               100  kHz
%                                               500 kHz
%
% Output: CV Characteristic Curve
%
%% Author:      M. Becherer
%% Mod.:        A.Materla
% Technische Universität München (TUM)
%---------------------------------------------------------------
clear all                   % clear workspace
close all                   % close all figures
clc                         % clear command window

v_start = -5; % in V
v_stop = -1; % in V
nr_points = 10;

Frequenzvektor = [500e3 100e3 10e3 1e3 500]; % in Hz


leg = cell(1,length(Frequenzvektor));
for i = 1:length(Frequenzvektor)
    leg{i} = strcat(num2str(Frequenzvektor(i)*1e-3), ' kHz');
end
%%
sweeps_per_freq = fix(nr_points/10);

if mod(nr_points,10) ~= 0
    sweeps_per_freq =+ 1;
end

%%
V= linspace(v_start, v_stop, nr_points);
Cp = zeros(length(V), length(Frequenzvektor));
%% Generiere den Sweep Vektor für Spannungen, unbedingt 10 Werte für die Liste!!!! Sonst Fehlermeldung

%V= fliplr(V)

test = reshape(V,10,[]).';

M = cell(height(test),1);
for j = 1:height(test)
    M{j} = 'LIST:BIAS:VOLT';
    for i = test(j,:)
        M{j} = strcat(M{j}, {' '}, compose("%d", i),'V,');
    end
end

%%   Create and Connect to the GPIB object.
%obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 17, 'Tag', '');
% Create the GPIB object if it does not exist
% otherwise use the object that was found.
% geht irgendwie nicht mehr. 

obj1 = gpib('ADLINK', 0, 22); % Funktioniert gerade

% Connect to instrument object, obj1.
fopen(obj1);
fprintf(obj1,'*RST'); % IMPORTANT
fprintf(obj1,'*CLS'); % Clear status command

%% For Schleife für die ausgewählten 5 Frequenzen


for j = 1:length(Frequenzvektor)
    disp(leg{j})
    %% Geräte ansteuern mit fprintf Befehlen über den GPIB-Bus
    % Min and Max voltage page 254 in Handbook
    i=1;
    while i <= height(M)
        volt_sweep = M{i};
        % fprintf(obj1,'*RST'); % IMPORTANT
        fprintf(obj1,'MEM:CLE DBUF');
        fprintf(obj1,'*CLS'); % Clear status command
        %fprintf(obj1,'OUTP:HPOW ON'); % High Power ON
        fprintf(obj1,'BIAS:STAT ON'); % IMPORTANT
    
        fprintf(obj1,strcat('FREQ ', num2str(Frequenzvektor(j)), 'HZ')); % 
    
        fprintf(obj1,'APER LONG');
        %fprintf(obj1,'DISP:PAGE MSETUP'); % check if option 001 in ON (HI-pw: ON)
        %fprintf(obj1,'FORM ASCII');
        fprintf(obj1,'TRIG:SOUR BUS'); % IMPORTANT
        %fprintf(obj1,'TRIG:DEL MIN'); % Delay
        %fprintf(obj1,'LIST:MODE SEQ');
        fprintf(obj1,volt_sweep(:));%Max 10 sweep points (page 273) !!
        fprintf(obj1,'DISP:PAGE LIST');
        %fprintf(obj1,'INIT:CONT ON');
        fprintf(obj1,'MEM:FILL DBUF'); % Enable data buffer memory to store data
        fprintf(obj1,'TRIGGER:IMMEDIATE');
        fprintf(obj1,'MEM:READ? DBUF'); % Place the data in the data buffer memory  intothe output buffer.
        pause(2)

        result = fscanf(obj1); % 4 times  "<Data A> <Data B> <Status> <BIN No.>"
        result=str2num(result);
        
        for m = 1:length(test(i,:))
            status(m) = result((4*m-1));
        end
        
        if sum(status) == 0
            disp('No error')
            for m = 1:length(test(i,:))
                Cp(m+10*(i-1),j)=result(4*m-3) * 1e12;
                % D(:,j) = [];
            end
            i = i+ 1;
        else
            disp('Redo Measurement')
            i = i-1;
            break
        end

    end
    figure()
    plot(V,Cp(:,j))
    title(leg(j))
    xlabel('Gate Voltage (V)')
    ylabel('Capacitance (pF)')
    grid on;
    fprintf(obj1,'BIAS:STAT 0'); % High Power OFF
end

figure(100)
plot(V,Cp);
xlabel('Gate Voltage / V')
ylabel('Capacitance / pF')
legend(leg)
grid on;

M = [0, Frequenzvektor; V', Cp];
writematrix(M, 'D5_10p_Kapazität.csv');

fprintf(obj1,'BIAS:STAT 0'); % High Power OFF
fprintf(obj1,'*RST'); % IMPORTANT
fprintf(obj1,'*CLS'); % Clear status command
% Disconnect from instrument object, obj1.
fclose(obj1);
% Clean up all objects.
delete(obj1);
