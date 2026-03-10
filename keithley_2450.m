% Author:   Nico Riedmann
% Email:    nico.riedmann@tum.de
% Date:     17.07.2020
% Corrections and update through Felix Fehlauer, 06.10.2025
% Adapted for USB and R2025a use 26.11.2025 Max Hofschen

classdef keithley_2450
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        range
        connection
        transferStatus
        rangeVoltage
        rangeCurrent
    end
    properties ( SetAccess = protected )
        channels = 1;
    end
    
    methods ( Access = public )
        function obj = keithley_2450( visaAddr )
            obj.connection = visadev( visaAddr );
            set( obj.connection, 'Timeout', 2 );% set timeout in s
        end
        
        function [] = openConnection( obj )
            messageParser( obj, '*IDN?' );
            messageParser( obj, '*RST' );
        end
        
        function [] = closeConnection( obj )
            delete( obj.connection );
        end
        
        function [] = setSourceReadBack( obj, type, state )
            % SET SOURCE READ BACK
            %   This function configurates the source read back with
            %   respect to the regarding source (voltage or current). If
            %   the read back is enabled, the applied source value can be
            %   read back via reading the buffer "readBuffer".
            %
            %   inputarguments
            %   name        datatype            description
            %   type        char array          VOLTAGE
            %                                   CURRENT
            %   state       boolean             0 (readback disabled)
            %                                   1 (readback enabled)
            
            if ~islogical( state )
                error( 'Parameter for source read back is not from datatype boolean' );
            end
            validType = {'VOLTAGE', 'CURRENT'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid source type' );
            end
            messageParser( obj, [ 'SOURCE:', type, ':READ:BACK ', num2str( state ) ] );
        end
        
        function [ state ] = getSourceReadBack( obj, type )
            % SET SOURCE READ BACK
            %   This function configurates the source read back with
            %   respect to the regarding source (voltage or current). If
            %   the read back is enabled, the applied source value can be
            %   read back via reading the buffer "readBuffer".
            %
            %   inputargument
            %   name        datatype            description
            %   type        char array          VOLTAGE
            %                                   CURRENT
            %
            %   outputargument
            %   name        datatype            description
            %   state       boolean             0 (readback disabled)
            %                                   1 (readback enabled)
            
            validType = {'VOLTAGE', 'CURRENT'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid source type' );
            end
            rx_message = messageParser( obj, [ 'SOURCE:', type, ':READ:BACK?' ] );
            state = str2double( rx_message );
        end
        
        function [] = performVoltageSweep( obj, start, stop, points, ...
                sweepcycles, abortlimit, dualsweep )
            % PERFORM VOLTAGE SWEEP
            %   This function performs a linear voltage sweep, characterized by
            %   start value and stop value of the voltage and the number of
            %   steps. With the parameter abortlimit, the sweep can be
            %   aborted with reaching the chosen limit. With dualsweep a
            %   sweep from start to stop and back to the start value can be
            %   performed.
            %
            %   inputarguments
            %   name        datatype            description
            %   start       double              start value of the voltage
            %                                       source
            %   stop        double              stop value of the voltage
            %                                       source
            %   point       integer             2 ... 1e6 (number of sweep
            %                                       points between start
            %                                       and stop value)
            %   sweepcycles integer             0 ... 268435455 (number of
            %                                       sweep cylces between 1
            %                                       ... 268435455 - 0
            %                                       equals infinite cylces)
            %   abortlimit  boolean             0 (performing a complete
            %                                       sweep)
            %                                   1 (abort sweep if limit is
            %                                       reached)
            %   dualsweep   boolean             0 (start -> stop)
            %                                   1 (start -> stop -> start)
            
            if ~isnumeric( start )
                error( 'Start value is not numeric' );
            elseif ( abs( start ) > 210 )
                error( 'Start value is out of range' )
            end
            if ~isnumeric( stop )
                error( 'Stop value is not numeric' );
            elseif ( abs( stop ) > 210 )
                error( 'Stop value is out of range' );
            end
            if ~isnumeric( points )
                error( 'Number of points is not numeric' );
            elseif ( points < 2 ) && ( points > 1e6 )
                error( 'Number of points is not within the specified range (2 ... 1e6)' );
            end
            if ~isnumeric( sweepcycles )
                error( 'Number of sweepcylces is not numeric' );
            elseif ( sweepcycles ~= abs( round( sweepcycles ) ) )
                error( 'Parameter for sweepcylces is no positive integer' );
            end
            if ~islogical( abortlimit )
                error( 'Parameter for abort on limit is not logical' );
            end
            if ~islogical( dualsweep )
                error( 'Parameter for the dualsweep is not logical' );
            end
            messageParser( obj, '*CLS' );
            messageParser( obj, [ ':SOURCE:SWEEP:VOLTAGE:LINEAR ', ...
                num2str( start ), ', ', num2str( stop ), ', ', ...
                num2str( points ), ', -1, ', num2str( sweepcycles ), ...
                ', AUTO, ', num2str( abortlimit ), ', ', ...
                num2str( dualsweep ), ', "defbuffer1"' ] );
            messageParser( obj, 'INIT' );
            messageParser( obj, '*OPC' );
            statusESR = 0;
            
            while ( mod( statusESR, 2 ) == 0 )
                statusESR = messageParser( obj, '*ESR?' );
                statusESR = str2double( statusESR );
            end
        end
        
        function [] = performCurrentSweep( obj, start, stop, points, ...
                sweepcycles, abortlimit, dualsweep )
            % PERFORM CURRENT SWEEP
            %   This function performs a linear current sweep, characterized by
            %   start value and stop value of the current and the number of
            %   steps. With the parameter abortlimit, the sweep can be
            %   aborted with reaching the chosen limit. With dualsweep a
            %   sweep from start to stop and back to the start value can be
            %   performed.
            %
            %   inputarguments
            %   name        datatype            description
            %   start       double              start value of the current
            %                                       source
            %   stop        double              stop value of the current
            %                                       source
            %   point       integer             2 ... 1e6 (number of sweep
            %                                       points between start
            %                                       and stop value)
            %   sweepcycles integer             0 ... 268435455 (number of
            %                                       sweep cylces between 1
            %                                       ... 268435455 - 0
            %                                       equals infinite cylces)
            %   abortlimit  boolean             0 (performing a complete
            %                                       sweep)
            %                                   1 (abort sweep if limit is
            %                                       reached)
            %   dualsweep   boolean             0 (start -> stop)
            %                                   1 (start -> stop -> start)
            
            if ~isnumeric( start )
                error( 'Start value is not numeric' );
            elseif ( abs( start ) > 1.05 )
                error( 'Start value is out of range' )
            end
            if ~isnumeric( stop )
                error( 'Stop value is not numeric' );
            elseif ( abs( stop ) > 1.05 )
                error( 'Stop value is out of range' );
            end
            if ~isnumeric( points )
                error( 'Number of points is not numeric' );
            elseif ( points < 2 ) && ( points > 1e6 )
                error( 'Number of points is not within the specified range (2 ... 1e6)' );
            end
            if ~isnumeric( sweepcycles )
                error( 'Number of sweepcylces is not numeric' );
            elseif ( sweepcycles ~= abs( round( sweepcycles ) ) )
                error( 'Parameter for sweepcylces is no positive integer' );
            end
            if ~islogical( abortlimit )
                error( 'Parameter for abort on limit is not logical' );
            end
            if ~islogical( dualsweep )
                error( 'Parameter for the dualsweep is not logical' );
            end
            
            messageParser( obj, '*CLS' );
            messageParser( obj, [ ':SOURCE:SWEEP:CURRENT:LINEAR ', ...
                num2str( start ), ', ', num2str( stop ), ', ', ...
                num2str( points ), ', -1, ', num2str( sweepcycles ), ...
                ', AUTO, ', num2str( abortlimit ), ', ', ...
                num2str( dualsweep ), ', "defbuffer1"' ] );
            messageParser( obj, 'INIT' );
            messageParser( obj, '*OPC' );
            statusESR = 0;
            
            while ( mod( statusESR, 2 ) == 0 )
                statusESR = messageParser( obj, '*ESR?' );
                statusESR = str2double( statusESR );
            end
        end
        
        function [] = setCurrentSenseAuto( obj, autoenable )
            % SET CURRENT SENSE AUTO
            %   This function
            %
            %   inputarguments
            %   name        datatype            description
            %   autoenable  boolean             0 (manual range)
            %                                   1 (automatic range)
            if ~islogical( autoenable )
                error( 'No boolean parameter for enabling automatic sense range' );
            end
            messageParser( obj, [ 'SENSE:CURRENT:RANGE:AUTO ', ...
                        num2str( autoenable ) ] );
        end
        
        function [] = setVoltageSenseAuto( obj, autoenable )
            % SET VOLTAGE SENSE AUTO
            %   This function
            %
            %   inputarguments
            %   name        datatype            description
            %   autoenable  boolean             0 (manual range)
            %                                   1 (automatic range)
            if ~islogical( autoenable )
                error( 'No boolean parameter for enabling automatic sense range' );
            end
            messageParser( obj, [ 'SENSE:VOLTAGE:RANGE:AUTO ', ...
                        num2str( autoenable ) ] );
        end
        
        function [] = setCurrentSenseRange( obj, autoenable, range)
            % SET CURRENT SENSE RANGE
            %   This function
            %
            %   inputarguments
            %   name        datatype            description
            %   autoenable  boolean             0 (manual range)
            %                                   1 (automatic range)
            %   range       double              positive value within
            %                                        10e-9 ... 1
            %                                       (10 nA ... 1 A)
            %                                       only for manual range
            %   range       double (2 elements) upper limit within
            %                                        10e-9 ... 1
            %                                       (10 nA ... 1 A)
            %                                   lower limit within
            %                                        10e-9 ... 1
            %                                       (10 nA ... 1 A)
            %                                       only for automatic
            %                                       range
            
            if ~islogical( autoenable )
                error( 'No boolean parameter for enabling automatic sense range' );
            end
            messageParser( obj, [ 'SENSE:CURRENT:RANGE:AUTO ', ...
                        num2str( autoenable ) ] );
            if ~autoenable
                if ~( ( length( range ) == 1 ) && isnumeric( range ) )
                    error( 'Manual range is not numeric or not a single element');
                else
                    messageParser( obj, [ 'SENSE:CURRENT:RANGE ', ...
                        num2str( range ) ] );
                end
            else
                if ~( ( length( range ) == 2 ) && isnumeric( range ) )
                    error( 'Manual range is not numeric or not a vector with two elements');
                else
                    messageParser( obj, [ 'SENSE:CURRENT:RANGE:AUTO:LLIM ', ...
                        num2str( range(1) ) ] );
                    messageParser( obj, [ 'SENSE:CURRENT:RANGE:AUTO:ULIM ', ...
                        num2str( range(2) ) ] );
                end
            end
        end
        
        function [] = setVoltageSenseRange(obj, autoenable, range)
            % SET VOLTAGE SENSE RANGE
            %   This function
            %
            %   inputarguments
            %   name        datatype            description
            %   autoenable  boolean             0 (manual range)
            %                                   1 (automatic range)
            % varagin
            %   range       double              positive value within
            %                                        20e-3 ... 200
            %                                       (20 mV ... 200 V)
            %                                       only for manual range
            %   range       double (2 elements) upper limit within
            %                                        20e-3 ... 200
            %                                       (20 mA ... 200 V)
            %                                   lower limit within
            %                                        20e-3 ... 200
            %                                       (20 mV ... 200 V)
            %                                       only for automatic
            %                                       range
            
            if ~islogical( autoenable )
                error( 'No boolean parameter for enabling automatic sense range' );
            end
            messageParser( obj, [ 'SENSE:VOLTAGE:RANGE:AUTO ', ...
                        num2str( autoenable ) ] );
            if ~autoenable
                if ~( ( length( range ) == 1 ) && isnumeric( range ) )
                    error( 'Manual range is not numeric or not a single element');
                else
                    messageParser( obj, [ 'SENSE:VOLTAGE:RANGE ', ...
                        num2str( range ) ] );
                end
            else
                if ~( ( length( range ) == 2 ) && isnumeric( range ) )
                    error( 'Manual range is not numeric or not a vector with two elements');
                else
                    messageParser( obj, [ 'SENSE:VOLTAGE:RANGE:AUTO:LLIM ', ...
                        num2str( range(1) ) ] );
                    messageParser( obj, [ 'SENSE:VOLTAGE:RANGE:AUTO:ULIM ', ...
                        num2str( range(2) ) ] );
                end
            end
        end
        
        function [] = setVoltageSourceRange( obj, range )
            %   input arguments:
            %   obj         object
            %   range       double              positive value within
            %                                        20e-3 ... 200
            %                                       (20 mV ... 200 V)

            valirange = [20e-3, 200e-3, 2, 20, 200];
            if ~ismember(range, valirange)
                error('The given input argument range is not valid.');
            end

            messageParser( obj, [ 'SOURCE:VOLTAGE:RANGE ', num2str( range ) ] );
            obj.rangeVoltage = range;
            clear valirange
        end

        function [] = setCurrentSourceRange( obj, range )
            %   input arguments:
            %   obj         object
            %   range       double              positive value within
            %                                        10e-9 ... 1
            %                                       (10 nA ... 1 A)

            valirange = [10e-9, 100e-9, 1e-6, 10e-6, 100e-6, 1e-3, 10e-3, 100e-3, 1];
            if ~ismember(range, valirange)
                error('The given input argument range is not valid.');
            end

            messageParser( obj, [ 'SOURCE:CURRENT:RANGE ', num2str( range ) ] );
            obj.rangeCurrent = range;
            clear valirange
        end
        
        function [] = setCurrentLimit( obj, limit )
            % SET CURRENT LIMIT
            %   This function sets the maximum current limit in a
            %   measurement, which can be reached. The current limit can be
            %   read for the case of using the voltage source option.
            %
            %   inputarguments
            %   name        datatype            description
            %   limit       double              current limit can be chosen
            %                                     in the range between
            %                                     1e-9 and 1.05
            %                                     positive and negative
            %
            %   comment
            %   The current limit is valid in the range from 1 nA to 1.05 A.
            %   By further settings, like measurement range and overvoltage
            %   protection, this value can be limited in both directions.
            
            if ~isnumeric( limit )
                error( ['The parameter for the current limit is not ', ...
                    'a numeric datatype'] );
            end
            
            if ( abs( limit ) < 1e-9 ) || ( abs( limit ) > 1.05 )
                error( ['The parameter for the current limit is not ', ...
                    'within a valid range'] );
            end
            
            messageParser( obj, [ ':SOURCE:VOLTAGE:ILIMIT ', num2str( limit ) ] );
        end
        
        function [ limit ] = getCurrentLimit( obj )
            % GET CURRENT LIMIT
            %   This function reads the current limit of the voltage
            %   source.
            %
            %   ouputarguments
            %   name        datatype            description
            %   limit       double              current limit in A
            
            rx_message = messageParser( obj, ':SOURCE:VOLTAGE:ILIMIT?' );
            limit = str2double( rx_message );
        end
        
        function setVoltageLimit( obj, limit )
            % SET VOLTAGE LIMIT
            %   This function sets the maximum voltage limit in a
            %   measurement, which can be reached. The voltage limit can be
            %   read for the case of using the current source option.
            %
            %   inputarguments
            %   name        datatype            description
            %   limit       double              voltage limit can be chosen
            %                                     in the range between
            %                                     20e-3 and 210
            %                                     positive and negative
            %
            %   comment
            %   The current limit is valid in the range from 20 mV to 210 V.
            %   By further settings, like measurement range and overvoltage
            %   protection, this value can be limited in both directions.
            
            if ~isnumeric( limit )
                error( ['The parameter for the voltage limit is not ', ...
                    'a numeric datatype'] );
            end
            
            if ( abs( limit ) < 20e-3 ) || ( abs( limit ) > 210 )
                error( ['The parameter for the voltage limit is not ', ...
                    'within a valid range'] );
            end
            
            messageParser( obj, [ ':SOURCE:CURRENT:VLIMIT ', num2str( limit ) ] );
        end
        
        function [ limit ] = getVoltageLimit( obj )
            % GET VOLTAGE LIMIT
            %   This function reads the voltage limit of the current
            %   source.
            %
            %   ouputarguments
            %   name        datatype            description
            %   limit       double              voltage limit in V
            
            rx_message = messageParser( obj, ':SOURCE:CURRENT:VLIMIT?' );
            limit = str2double( rx_message );
        end
        
        function setVoltageSourceAutoRange( obj, state )
            % SET VOLTAGE SOURCE AUTO RANGE
            %   This function enables or disables the automatic voltage source
            %   range, depending on the input arguement.
            %
            %   inputargument
            %   name        datatype            description
            %   state       boolean             0 / false (manual range)
            %                                   1 / true  (automatic range)
            %
            %   comment
            %   The instrument supports also the manual selection of a
            %   specific voltage source range. This feature is not
            %   implemented so far.
            
            if ~islogical( state )
                error( 'The state variable is not a boolean datatype' )
            end
            messageParser( obj, [ ':SOURCE:VOLTAGE:RANGE:AUTO ', num2str( state ) ] );
        end
        
        function [ state ] = getVoltageSourceAutoRange( obj )
            % GET VOLTAGE SOURCE AUTO RANGE
            %   This function reads the state of the automatic voltage
            %   source range.
            %
            %   outputargument
            %   name        datatype            description
            %   state       boolean             0 / false (manual range)
            %                                   1 / true  (automatic range)
            
            rx_message = messageParser( obj, ':SOURCE:VOLTAGE:RANGE:AUTO?' );
            state = str2double( rx_message );
        end
        
        function setCurrentSourceAutoRange( obj, state )
            % SET CURRENT SOURCE AUTO RANGE
            %   This function enables or disables the automatic current source
            %   range, depending on the input arguement.
            %
            %   inputargument
            %   name        datatype            description
            %   state       boolean             0 / false (manual range)
            %                                   1 / true  (automatic range)
            %
            %   comment
            %   The instrument supports also the manual selection of a
            %   specific current source range. This feature is not
            %   implemented so far.
            
            if ~islogical( state )
                error( 'The state variable is not a boolean datatype' )
            end
            messageParser( obj, [ ':SOURCE:CURRENT:RANGE:AUTO ', num2str( state ) ] );
        end
        
        function [ state ] = getCurrentSourceAutoRange( obj )
            % GET CURRENT SOURCE AUTO RANGE
            %   This function reads the state of the automatic current
            %   source range.
            %
            %   outputargument
            %   name        datatype            description
            %   state       boolean             0 / false (manual range)
            %                                   1 / true  (automatic range)
            
            rx_message = messageParser( obj, ':SOURCE:CURRENT:RANGE:AUTO?' );
            state = str2double( rx_message );
        end
        
        function setSenseType( obj, type )
            % SET SENSE TYPE
            %   With this function, the sense can be configurated as
            %   ampere-, ohm- or voltmeter.
            %
            %   inputargument
            %   name        datatype            description
            %   type        string              'VOLTAGE' (voltmeter)
            %                                   'CURRENT' (amperemeter)
            %                                   'RESISTANCE' (ohmmeter)
            
            validType = {'VOLTAGE', 'CURRENT', 'RESISTANCE'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid measurement type' );
            end
            messageParser( obj, [ ':SENSE:FUNCTION "', type, '"'] );
        end
        
        function [ type ] = getSenseType( obj )
            % GET SENSE TYPE
            %   With this function, the configurated sense type can be read.
            %
            %   outputargument
            %   name        datatype            description
            %   type        string              'VOLT:DC' (voltmeter)
            %                                   'CURR:DC' (amperemeter)
            %                                   'RES' (ohmmeter)
            
            rx_message = messageParser( obj, ':SENSE:FUNCTION?' );
            type = str2double( rx_message );
            type = type( 2 : end - 1 );
        end
        
        function setSourceType( obj, type )
            % SET SOURCE TYPE
            %   With this function, the source can be configurated as
            %   voltage or current source.
            %
            %   inputargument
            %   name        datatype            description
            %   type        string              'VOLTAGE' (voltage source)
            %                                   'CURRENT' (current source)
            
            validType = {'VOLTAGE', 'CURRENT'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid measurement type' );
            end
            messageParser( obj, [ ':SOURCE:FUNCTION ', type ] );
        end
        
        function [ type ] = getSourceType( obj )
            % GET SOURCE TYPE
            %   With this function, the configurated source type can be read.
            %
            %   outputargument
            %   name        datatype            description
            %   type        string              'VOLT' (voltage source)
            %                                   'CURR' (current source)
            
            rx_message = messageParser( obj, ':SOURCE:FUNCTION?' );
            type = str2double( rx_message );
        end
        
        function [] = setVoltageSource( obj, voltage )
            % SET VOLTAGE SOURCE
            %   This function configurates the source meter as voltage
            %   source and sets the outputvoltage to the desired value.
            %
            %   inputargument
            %   name        datatype            description
            %   voltage     double              outputvoltage in V
            
            if ~isnumeric( voltage )
                error( ['The parameter for the outputvoltage is not ', ...
                    'a numeric datatype'] );
            end
            
            messageParser( obj, [':SOURCE:VOLTAGE ', num2str( voltage )] );
        end
        
        function [ voltage ] = getVoltageSource( obj )
            % GET VOLTAGE SOURCE
            %   This function reads the configuratede output voltage.
            %
            %   outputargument
            %   name        datatype            description
            %   voltage     double              outputvoltage in V
            
            rx_message = messageParser( obj, ':SOURCE:VOLTAGE?' );
            voltage = str2double( rx_message );
        end
        
        function [] = setCurrentSource( obj, current )
            % SET CURRENT SOURCE
            %   This function configurates the source meter as current
            %   source and sets the outputcurrent to the desired value.
            %
            %   inputargument
            %   name        datatype            description
            %   current     double              outputcurrent in A
            
            if ~isnumeric( current )
                error( ['The parameter for the outputcurrent is not ', ...
                    'a numeric datatype'] );
            end
            
            messageParser( obj, [':SOURCE:CURRENT ', num2str( current )] );
        end
        
        function [ current ] = getCurrentSource( obj )
            % GET CURRENT SOURCE
            %   This function reads the configuratede output current.
            %
            %   outputargument
            %   name        datatype            description
            %   current     double              outputcurrent in A
            
            rx_message = messageParser( obj, ':SOURCE:CURRENT?' );
            current = str2double( rx_message );
        end
        
        function [current] = measureCurrent( obj )
            % MEASURE CURRENT
            %   This function enforces a single current measurement and
            %   reads the desired data from the instrument.
            %
            %   outputarguments
            %   name            datatype            description
            %   current         double              measured current in A
            %
            %   comment
            %   The Keithley 2450 SourceMeter provides two DataBuffer, which
            %   are used for storing the measurement data. The readout
            %   provides currently only reading of the active buffer.
            %   It is also possible to read further information about the
            %   measurement (data and time stamp, source information, units,
            %   ...), which are not implemented so far.
            
            current = messageParser( obj, 'MEAS:CURR?' );
            current = str2double( current );
        end
        
        function [voltage] = measureVoltage( obj )
            % MEASURE VOLTAGE
            %   This function enforces a single voltage measurement and
            %   reads the desired data from the instrument.
            %
            %   outputarguments
            %   name            datatype            description
            %   voltage         double              measured voltage in V
            %
            %   comment
            %   The Keithley 2450 SourceMeter provides two DataBuffer, which
            %   are used for storing the measurement data. The readout
            %   provides currently only reading of the active buffer.
            %   It is also possible to read further information about the
            %   measurement (data and time stamp, source information, units,
            %   ...), which are not implemented so far.
            
            voltage = messageParser( obj, 'MEAS:VOLT?' );
            voltage = str2double( voltage );
        end
        
        function [] = clearBuffer( obj )
            messageParser( obj, 'TRAC:CLEAR "defbuffer1"' );
        end
        
        function [ sense, source ] = readBuffer( obj )
            nReadings = messageParser( obj, ':TRACE:ACTUAL? "defbuffer1"' );
            nReadings = round( str2double( nReadings ) );
            if ~(nReadings > 0 )
                error( 'No readings in buffer' );
            end
            rx_message = messageParser( obj, [ 'TRAC:DATA? 1, ', ...
                num2str( nReadings ), ', "defbuffer1", READ, SOURCE' ] );
            rx_message = reshape( str2double( rx_message ), 2, [])';
            sense  = rx_message( :, 1 );
            source = rx_message( :, 2 );
        end
        
        function [] = setOutputState( obj, outputstate )
            % SET OUTPUT STATE
            %   This function controls the output state of the Keysight 2450.
            %
            %   inputarguments
            %   name            datatype            description
            %   outputstate     boolean             contains the output state
            %                                       0   output OFF
            %                                       1   output ON

            if ~islogical(outputstate)
                error( 'Not valid state variable' );
            end

            messageParser( obj, [':OUTP:STAT ', num2str( outputstate )] );
        end
        
        function [ outputstate ] = getOutputState( obj )
            % GET OUTPUT STATE
            %   This function returns the output state of the Keysight 2450.
            %
            %   outputarguments
            %   name            datatype            description
            %   outputstate     boolean             contains the output state
            %                                       0   output OFF
            %                                       1   output ON

            message_rx = messageParser( obj, ':OUTP:STAT?' );
            if ( str2double( message_rx ) == 1 ) % || contains( cellstr( message_rx ), 'ON' )
                outputstate = true;
            elseif ( str2double( message_rx ) == 0 ) % || contains( message_rx, 'OFF' )
                outputstate = false;
            end
        end

        function [ ] = setTerminal( obj, terminal )
            % SET TERMINALS
            %   This function configurates the input and output
            %   terminals of the Keysight 2450.
            %
            %   inputarguments
            %   name          datatype            description
            %   terminal      boolean             contains the input and output terminals
            %                                       0   front terminals
            %                                       1   rear terminals

            if ~islogical( terminal )
                error( 'Not valid terminal specification' );
            end

            if terminal == false
                message_tx = 'FRONT';
            else
                message_tx = 'REAR';
            end

            messageParser( obj, [':ROUT:TERM ', message_tx] );
        end

        function [ terminal ] = getTerminal( obj )
            % GET TERMINALS
            %   This function returns the configured input and output
            %   terminals of the Keysight 2450.
            %
            %   outputarguments
            %   name            datatype            description
            %   terminal        boolean             contains the input and output terminals
            %                                       0   front terminals
            %                                       1   rear terminals
            
            message_rx = messageParser( obj, ':ROUT:TERM?' );

            if contains( message_rx, 'FRON' )
                terminal = false;
            elseif contains( message_rx, 'REAR' )
                terminal = true;
            end
        end
        
        function setRemoteSensing( obj, type, state )
            % SET REMOTE SENSING
            %   This function selects a 2-wire or a 4-wire measurement with
            %   respect to the sense type.
            %
            %   inputarguments
            %   name        datatype            description
            %   type        char array          sense type
            %                                       VOLTAGE (voltmeter)
            %                                       CURRENT (amperemeter)
            %                                       RESISTANCE (ohmmeter)
            %   state       boolean             0 (2-wire measurement)
            %                                   1 (4-wire measurement)
            validType = {'VOLTAGE', 'CURRENT', 'RESISTANCE'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid measurement type' );
            end
            if ~islogical( state )
                error( 'Not valid sense state' );
            end
            messageParser( obj, ['SENSE:', type, ':RSENSE ', num2str(state)] );
        end
        
        function [state] = getRemoteSensing( obj, type )
            % GET REMOTE SENSING
            %   This function read the sensing type (2- or a 4-wire
            %   measurement) with respect to the sense type.
            %
            %   inputarguments
            %   name        datatype            description
            %   type        char array          sense type
            %                                       VOLTAGE (voltmeter)
            %                                       CURRENT (amperemeter)
            %                                       RESISTANCE (ohmmeter)
            %
            %   outputarguments
            %   name        datatype            description
            %   state       boolean             0 (2-wire measurement)
            %                                   1 (4-wire measurement)
            
            validType = {'VOLTAGE', 'CURRENT', 'RESISTANCE'};
            if sum( strcmp( type, validType ) ) < 1
                error( 'Not valid measurement type' );
            end
            state = messageParser( obj, ['SENSE:', type, ':RSENSE?'] );
        end
        
        function [ message_rx ] = messageParser( obj, message_tx )
            %MESSAGE PARSER
            %   This function handles the communication with the 
            %   measurement unit via SCPI commands. If the transmitted
            %   message contains a query, a readback follows.
            %
            %   inputarguments
            %   name            datatype            description
            %   message_tx      character array     contains the message to
            %                                           transmit
            %
            %   outputarguments
            %   name            datatype            description
            %   message_rx      character array     contains the received
            %                                           message
            
            if contains( message_tx, '?' )
                message_rx = obj.connection.writeread( message_tx );
            else
                obj.connection.write( message_tx );
            end
        end
        
        function [ interlock ] = getInterlock( obj )
            % GET STATUS OF INTERLOCK
            %   outputarguments
            %   name            datatype            description
            %   interlock       boolean             0   interlock signal is not asserted
            %                                           (voltage range is limited to +- 42 V)
            %                                       1   interlock signal is asserted
            %                                           (full voltage range)
            %                                       
            interlock = logical( str2double( messageParser( obj, ':OUTP:INT:TRIP?' ) ) );
        end

%        function delete( obj )
%            closeConnection( obj );
%       end
    end
end

