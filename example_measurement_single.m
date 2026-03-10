%% Example for performing a single measurement
% Author:   Nico Riedmann
% Email:    nico.riedmann@tum.de
% Date:     17.07.2020
% Corrections and update through Felix Fehlauer, 06.10.2025
% Adapted for USB and R2025a use 26.11.2025 Max Hofschen

% MAKE SURE TO CLEAR BEFORE STARTING

% Change only the following variables to set up different measurements
current_limit   = 10e-3;  % Current limit in A

% Here we choose the voltage vector (for the case of using a voltage
% source), containing all points where we would like to measure the current
% To measure at several points, the variable can also be a vector.
source          = -1:0.01:1;     % Voltage value in V of the source
                 % (if we use a voltage source)

% Create a element of the SOURCEMETER class choosing the KEITHLEY_2450
% subclass. The Keithley 2450 is connected via USB to the computer.
% Find the correct resource string by calling 'visadevlist'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu = keithley_2450("USB0::0x05E6::0x2450::04443848::0::INSTR");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Opening the connection to the instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.openConnection;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Before starting a measurement, some configurations have to be done

% Measurement terminals (front or real)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setTerminal( false ); % front terminals (4 mm connectors)
%smu.setTerminal( true ); % rear terminals (TRIAX connectors)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Measurement type (2- or 4-wire measurement for source voltage or source current)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% smu.setRemoteSensing( 'VOLTAGE', false ) % 2-wire, sense voltage
% smu.setRemoteSensing( 'VOLTAGE', true )  % 4-wire, sense voltage
 smu.setRemoteSensing( 'CURRENT', false ) % 2-wire, sense current
% smu.setRemoteSensing( 'CURRENT', true ) % 4-wire, sense current 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Source type (voltage or current source)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setSourceType( 'VOLTAGE' ); % voltage source
% smu.setSourceType( 'CURRENT' ); % current source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Source limit (for a voltage source the current can be limited and vice
% versa for the current source)
% If a measurement range is set, the limits must be more than 0.1 % of its
% value. The limit is an absolute value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setCurrentLimit( current_limit ); % current limit of 10 mA ( 1 nA ... 1.05 A )
%smu.setVoltageLimit( 10 ); % voltage limit of 10 V ( 20 mV ... 210 V )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Automatic source range (for a voltage source a automatic voltage source
% range is needed, for a current source a automatic current source range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setVoltageSourceAutoRange( true );
% smu.setCurrentSourceAutoRange( true );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Value of the source (voltage or current, depending on the source type)
% first value of the voltage vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setVoltageSource( source(1) ) % output voltage of 1.8 V ( -210 V ... 210 V )
% smu.setCurrentSource( source(1) ) % output current of 20 mA ( -1.05 A ... 1.05 A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switching the output on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setOutputState( true );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% performing a measurement (with repeating this command, multiple single
% measurements can be done)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nPoints = numel(source); % total number of source steps
sense = NaN(1, nPoints); % pre‑allocate variable for the measured values

for i = 1 : nPoints
    smu.setVoltageSource( source( i ) ) % sweeping through all elements of the source vector
    sense( i ) = smu.measureCurrent; % current is measured and returned
    % smu.setCurrentSource( source( i ) )
    % sense( i ) = smu.measureVoltage; % voltage is measured and returned
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switching the output off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.setOutputState( false );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% closing the connection to the instrument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smu.closeConnection;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% deleting the class element
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear smu;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The following code plots a very simple V-I-diagram
% You can modify the following lines.
figure(1);
plot(source, sense, 'o');
xlabel('Voltage in V');
ylabel('Current in A'); grid on; hold on;

figure(2);
semilogy(source, abs(sense), 'o');
xlabel('Voltage in V');
ylabel('Current in A'); grid on; hold on;


M = [source',sense'];
writematrix(M, 'N+_2P_Kennlinie.csv');
