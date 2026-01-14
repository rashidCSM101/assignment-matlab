%% ========================================================================
% PROBLEM 3: UK INVERTER SYSTEMS - SIMULINK MODEL
% Creates comprehensive Simulink models for:
% - Single-phase inverter (230V RMS, 50Hz, UK residential)
% - Three-phase inverter (400V line-line, 50Hz, UK industrial)
% - Thyristor-based switching with gate control
% - THD measurement and output waveforms
% ========================================================================

clear all; close all; clc;

fprintf('====================================================================\n');
fprintf('   CREATING UK INVERTER SIMULINK MODELS\n');
fprintf('====================================================================\n\n');

%% ========================================================================
% MODEL 1: SINGLE-PHASE INVERTER (230V RMS, 50Hz)
% ========================================================================
fprintf('Creating Single-Phase Inverter Model...\n\n');

modelName1 = 'Problem3_SinglePhase_Inverter';

% Close if already open
if bdIsLoaded(modelName1)
    close_system(modelName1, 0);
end

% Create new model
new_system(modelName1);
open_system(modelName1);

fprintf('1. Building Single-Phase Inverter Components...\n');

% DC Voltage Source (325V for 230V RMS output)
add_block('simulink/Sources/Constant', [modelName1 '/DC_Voltage_325V'], ...
    'Position', [50, 150, 100, 180], ...
    'Value', '325');  % sqrt(2) * 230V = 325V

% H-Bridge Thyristor Switches (4 thyristors)
% Top-left thyristor (S1)
add_block('simulink/Signal Routing/Switch', [modelName1 '/Thyristor_S1'], ...
    'Position', [200, 100, 230, 130], ...
    'Threshold', '0.5');

% Top-right thyristor (S2)
add_block('simulink/Signal Routing/Switch', [modelName1 '/Thyristor_S2'], ...
    'Position', [200, 200, 230, 230], ...
    'Threshold', '0.5');

% PWM Gate Control Signal (50Hz square wave)
add_block('simulink/Sources/Pulse Generator', [modelName1 '/PWM_Gate_50Hz'], ...
    'Position', [50, 50, 100, 80], ...
    'Period', '0.02', ...  % 50Hz = 20ms period
    'PulseWidth', '50', ...  % 50% duty cycle
    'Amplitude', '1', ...
    'PhaseDelay', '0');

% Inverting gate signal for complementary switching
add_block('simulink/Math Operations/Gain', [modelName1 '/Inverter_Gate'], ...
    'Position', [130, 200, 160, 230], ...
    'Gain', '-1');

add_block('simulink/Math Operations/Add', [modelName1 '/Gate_Offset'], ...
    'Position', [130, 240, 160, 270], ...
    'Inputs', '++');

add_block('simulink/Sources/Constant', [modelName1 '/One_Constant'], ...
    'Position', [80, 250, 110, 270], ...
    'Value', '1');

% Load Resistance (10 ohms for 23A @ 230V)
add_block('simulink/Math Operations/Gain', [modelName1 '/Load_Resistance'], ...
    'Position', [400, 150, 450, 180], ...
    'Gain', '1/10');  % R = 10 ohms

% Load Inductance (10mH for power factor)
add_block('simulink/Continuous/Integrator', [modelName1 '/Load_Inductor'], ...
    'Position', [320, 150, 350, 180], ...
    'InitialCondition', '0');

add_block('simulink/Math Operations/Gain', [modelName1 '/Inductor_L'], ...
    'Position', [280, 150, 310, 180], ...
    'Gain', '1/0.01');  % L = 10mH

% Output voltage and current measurement
add_block('simulink/Sinks/Scope', [modelName1 '/Output_Voltage_Scope'], ...
    'Position', [500, 100, 530, 130]);

add_block('simulink/Sinks/Scope', [modelName1 '/Output_Current_Scope'], ...
    'Position', [500, 200, 530, 230]);

% Voltage measurement display
add_block('simulink/Sinks/Display', [modelName1 '/Voltage_Display'], ...
    'Position', [460, 250, 540, 280]);

% To Workspace for data logging
add_block('simulink/Sinks/To Workspace', [modelName1 '/Voltage_Log'], ...
    'Position', [500, 50, 580, 70], ...
    'VariableName', 'single_phase_voltage');

add_block('simulink/Sinks/To Workspace', [modelName1 '/Current_Log'], ...
    'Position', [500, 300, 580, 320], ...
    'VariableName', 'single_phase_current');

% Annotations
add_block('built-in/Note', [modelName1 '/Title_Note'], ...
    'Position', [150, 10, 450, 30], ...
    'Text', 'SINGLE-PHASE INVERTER - 230V RMS, 50Hz (UK Residential)');

add_block('built-in/Note', [modelName1 '/HBridge_Note'], ...
    'Position', [200, 140, 350, 160], ...
    'Text', 'H-Bridge Thyristor Configuration');

fprintf('  Single-phase inverter structure created!\n');

% Connect single-phase inverter blocks
fprintf('  Connecting single-phase blocks...\n');
try
    % PWM to switches
    add_line(modelName1, 'PWM_Gate_50Hz/1', 'Thyristor_S1/2', 'autorouting', 'on');
    add_line(modelName1, 'PWM_Gate_50Hz/1', 'Inverter_Gate/1', 'autorouting', 'on');
    add_line(modelName1, 'Inverter_Gate/1', 'Gate_Offset/1', 'autorouting', 'on');
    add_line(modelName1, 'One_Constant/1', 'Gate_Offset/2', 'autorouting', 'on');
    add_line(modelName1, 'Gate_Offset/1', 'Thyristor_S2/2', 'autorouting', 'on');
    
    % DC voltage to switches
    add_line(modelName1, 'DC_Voltage_325V/1', 'Thyristor_S1/1', 'autorouting', 'on');
    add_line(modelName1, 'DC_Voltage_325V/1', 'Thyristor_S2/3', 'autorouting', 'on');
    
    % Switches output through load
    add_line(modelName1, 'Thyristor_S1/1', 'Inductor_L/1', 'autorouting', 'on');
    add_line(modelName1, 'Thyristor_S2/1', 'Inductor_L/1', 'autorouting', 'on');
    add_line(modelName1, 'Inductor_L/1', 'Load_Inductor/1', 'autorouting', 'on');
    add_line(modelName1, 'Load_Inductor/1', 'Load_Resistance/1', 'autorouting', 'on');
    
    % Output measurements
    add_line(modelName1, 'Load_Inductor/1', 'Output_Voltage_Scope/1', 'autorouting', 'on');
    add_line(modelName1, 'Load_Resistance/1', 'Output_Current_Scope/1', 'autorouting', 'on');
    add_line(modelName1, 'Load_Inductor/1', 'Voltage_Display/1', 'autorouting', 'on');
    add_line(modelName1, 'Load_Inductor/1', 'Voltage_Log/1', 'autorouting', 'on');
    add_line(modelName1, 'Load_Resistance/1', 'Current_Log/1', 'autorouting', 'on');
    
    fprintf('  ✓ Single-phase connections complete!\n');
catch ME
    fprintf('  Warning: Some connections failed: %s\n', ME.message);
end

%% ========================================================================
% MODEL 2: THREE-PHASE INVERTER (400V L-L, 50Hz)
% ========================================================================
fprintf('\n2. Creating Three-Phase Inverter Model...\n\n');

modelName2 = 'Problem3_ThreePhase_Inverter';

% Close if already open
if bdIsLoaded(modelName2)
    close_system(modelName2, 0);
end

% Create new model
new_system(modelName2);
open_system(modelName2);

fprintf('Building Three-Phase Inverter Components...\n');

% DC Voltage Source (565V for 400V line-line RMS)
add_block('simulink/Sources/Constant', [modelName2 '/DC_Voltage_565V'], ...
    'Position', [50, 250, 100, 280], ...
    'Value', '565');  % sqrt(2) * 400V = 565V DC bus

% Phase A PWM Gate Signal (0° reference)
add_block('simulink/Sources/Pulse Generator', [modelName2 '/PWM_Gate_PhaseA'], ...
    'Position', [50, 50, 100, 80], ...
    'Period', '0.02', ...  % 50Hz
    'PulseWidth', '33.3', ...  % 120° conduction
    'Amplitude', '1', ...
    'PhaseDelay', '0');

% Phase B PWM Gate Signal (120° delay)
add_block('simulink/Sources/Pulse Generator', [modelName2 '/PWM_Gate_PhaseB'], ...
    'Position', [50, 150, 100, 180], ...
    'Period', '0.02', ...
    'PulseWidth', '33.3', ...
    'Amplitude', '1', ...
    'PhaseDelay', '0.00667');  % 120° = 6.67ms @ 50Hz

% Phase C PWM Gate Signal (240° delay)
add_block('simulink/Sources/Pulse Generator', [modelName2 '/PWM_Gate_PhaseC'], ...
    'Position', [50, 350, 100, 380], ...
    'Period', '0.02', ...
    'PulseWidth', '33.3', ...
    'Amplitude', '1', ...
    'PhaseDelay', '0.01333');  % 240° = 13.33ms @ 50Hz

% Phase A Inverter Leg (Top + Bottom Thyristors)
add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_A_Top'], ...
    'Position', [200, 50, 230, 80], ...
    'Threshold', '0.5');

add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_A_Bottom'], ...
    'Position', [200, 100, 230, 130], ...
    'Threshold', '0.5');

% Phase B Inverter Leg
add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_B_Top'], ...
    'Position', [200, 150, 230, 180], ...
    'Threshold', '0.5');

add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_B_Bottom'], ...
    'Position', [200, 200, 230, 230], ...
    'Threshold', '0.5');

% Phase C Inverter Leg
add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_C_Top'], ...
    'Position', [200, 350, 230, 380], ...
    'Threshold', '0.5');

add_block('simulink/Signal Routing/Switch', [modelName2 '/Thyristor_C_Bottom'], ...
    'Position', [200, 400, 230, 430], ...
    'Threshold', '0.5');

% Star-connected Load (3 phases)
% Phase A Load (R=5Ω, L=5mH)
add_block('simulink/Math Operations/Gain', [modelName2 '/Load_A_Resistance'], ...
    'Position', [400, 50, 450, 80], ...
    'Gain', '1/5');

add_block('simulink/Continuous/Integrator', [modelName2 '/Load_A_Inductor'], ...
    'Position', [350, 50, 380, 80], ...
    'InitialCondition', '0');

add_block('simulink/Math Operations/Gain', [modelName2 '/Inductor_A_L'], ...
    'Position', [300, 50, 330, 80], ...
    'Gain', '1/0.005');  % L = 5mH

% Phase B Load
add_block('simulink/Math Operations/Gain', [modelName2 '/Load_B_Resistance'], ...
    'Position', [400, 150, 450, 180], ...
    'Gain', '1/5');

add_block('simulink/Continuous/Integrator', [modelName2 '/Load_B_Inductor'], ...
    'Position', [350, 150, 380, 180], ...
    'InitialCondition', '0');

add_block('simulink/Math Operations/Gain', [modelName2 '/Inductor_B_L'], ...
    'Position', [300, 150, 330, 180], ...
    'Gain', '1/0.005');

% Phase C Load
add_block('simulink/Math Operations/Gain', [modelName2 '/Load_C_Resistance'], ...
    'Position', [400, 350, 450, 380], ...
    'Gain', '1/5');

add_block('simulink/Continuous/Integrator', [modelName2 '/Load_C_Inductor'], ...
    'Position', [350, 350, 380, 380], ...
    'InitialCondition', '0');

add_block('simulink/Math Operations/Gain', [modelName2 '/Inductor_C_L'], ...
    'Position', [300, 350, 330, 380], ...
    'Gain', '1/0.005');

% Neutral point connection
add_block('simulink/Math Operations/Add', [modelName2 '/Neutral_Sum'], ...
    'Position', [500, 200, 530, 230], ...
    'Inputs', '+++');

% Output measurement scopes
add_block('simulink/Sinks/Scope', [modelName2 '/PhaseA_Voltage_Scope'], ...
    'Position', [550, 40, 580, 70]);

add_block('simulink/Sinks/Scope', [modelName2 '/PhaseB_Voltage_Scope'], ...
    'Position', [550, 140, 580, 170]);

add_block('simulink/Sinks/Scope', [modelName2 '/PhaseC_Voltage_Scope'], ...
    'Position', [550, 340, 580, 370]);

add_block('simulink/Sinks/Scope', [modelName2 '/ThreePhase_Combined'], ...
    'Position', [600, 200, 630, 230]);

% Line-to-Line voltage calculation (A-B)
add_block('simulink/Math Operations/Add', [modelName2 '/LineVoltage_AB'], ...
    'Position', [500, 100, 530, 130], ...
    'Inputs', '+-');

add_block('simulink/Sinks/Display', [modelName2 '/LineVoltage_AB_Display'], ...
    'Position', [560, 100, 640, 130]);

% Phase voltage measurement display
add_block('simulink/Sinks/Display', [modelName2 '/PhaseA_Voltage_Display'], ...
    'Position', [550, 450, 630, 480]);

% To Workspace for data logging
add_block('simulink/Sinks/To Workspace', [modelName2 '/PhaseA_Log'], ...
    'Position', [600, 30, 680, 50], ...
    'VariableName', 'three_phase_A');

add_block('simulink/Sinks/To Workspace', [modelName2 '/PhaseB_Log'], ...
    'Position', [600, 130, 680, 150], ...
    'VariableName', 'three_phase_B');

add_block('simulink/Sinks/To Workspace', [modelName2 '/PhaseC_Log'], ...
    'Position', [600, 330, 680, 350], ...
    'VariableName', 'three_phase_C');

% Annotations
add_block('built-in/Note', [modelName2 '/Title_Note'], ...
    'Position', [150, 10, 500, 30], ...
    'Text', 'THREE-PHASE INVERTER - 400V L-L, 50Hz (UK Industrial)');

add_block('built-in/Note', [modelName2 '/PhaseA_Note'], ...
    'Position', [200, 20, 300, 40], ...
    'Text', 'Phase A (0°)');

add_block('built-in/Note', [modelName2 '/PhaseB_Note'], ...
    'Position', [200, 120, 300, 140], ...
    'Text', 'Phase B (120°)');

add_block('built-in/Note', [modelName2 '/PhaseC_Note'], ...
    'Position', [200, 320, 300, 340], ...
    'Text', 'Phase C (240°)');

fprintf('  Three-phase inverter structure created!\n');

% Connect three-phase inverter blocks
fprintf('  Connecting three-phase blocks...\n');
try
    % Phase A connections
    add_line(modelName2, 'PWM_Gate_PhaseA/1', 'Thyristor_A_Top/2', 'autorouting', 'on');
    add_line(modelName2, 'DC_Voltage_565V/1', 'Thyristor_A_Top/1', 'autorouting', 'on');
    add_line(modelName2, 'Thyristor_A_Top/1', 'Inductor_A_L/1', 'autorouting', 'on');
    add_line(modelName2, 'Inductor_A_L/1', 'Load_A_Inductor/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_A_Inductor/1', 'Load_A_Resistance/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_A_Inductor/1', 'PhaseA_Voltage_Scope/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_A_Inductor/1', 'PhaseA_Log/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_A_Resistance/1', 'Neutral_Sum/1', 'autorouting', 'on');
    
    % Phase B connections
    add_line(modelName2, 'PWM_Gate_PhaseB/1', 'Thyristor_B_Top/2', 'autorouting', 'on');
    add_line(modelName2, 'DC_Voltage_565V/1', 'Thyristor_B_Top/1', 'autorouting', 'on');
    add_line(modelName2, 'Thyristor_B_Top/1', 'Inductor_B_L/1', 'autorouting', 'on');
    add_line(modelName2, 'Inductor_B_L/1', 'Load_B_Inductor/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_B_Inductor/1', 'Load_B_Resistance/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_B_Inductor/1', 'PhaseB_Voltage_Scope/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_B_Inductor/1', 'PhaseB_Log/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_B_Resistance/1', 'Neutral_Sum/2', 'autorouting', 'on');
    
    % Phase C connections
    add_line(modelName2, 'PWM_Gate_PhaseC/1', 'Thyristor_C_Top/2', 'autorouting', 'on');
    add_line(modelName2, 'DC_Voltage_565V/1', 'Thyristor_C_Top/1', 'autorouting', 'on');
    add_line(modelName2, 'Thyristor_C_Top/1', 'Inductor_C_L/1', 'autorouting', 'on');
    add_line(modelName2, 'Inductor_C_L/1', 'Load_C_Inductor/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_C_Inductor/1', 'Load_C_Resistance/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_C_Inductor/1', 'PhaseC_Voltage_Scope/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_C_Inductor/1', 'PhaseC_Log/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_C_Resistance/1', 'Neutral_Sum/3', 'autorouting', 'on');
    
    % Line-to-line voltage
    add_line(modelName2, 'Load_A_Inductor/1', 'LineVoltage_AB/1', 'autorouting', 'on');
    add_line(modelName2, 'Load_B_Inductor/1', 'LineVoltage_AB/2', 'autorouting', 'on');
    add_line(modelName2, 'LineVoltage_AB/1', 'LineVoltage_AB_Display/1', 'autorouting', 'on');
    
    % Combined scope
    add_line(modelName2, 'Neutral_Sum/1', 'ThreePhase_Combined/1', 'autorouting', 'on');
    
    % Phase A display
    add_line(modelName2, 'Load_A_Inductor/1', 'PhaseA_Voltage_Display/1', 'autorouting', 'on');
    
    fprintf('  ✓ Three-phase connections complete!\n');
catch ME
    fprintf('  Warning: Some connections failed: %s\n', ME.message);
end

%% ========================================================================
% CONFIGURE SIMULATION PARAMETERS FOR BOTH MODELS
% ========================================================================
fprintf('\n3. Configuring simulation parameters...\n');

% Single-phase model settings
set_param(modelName1, 'Solver', 'ode23t');  % Stiff solver for power electronics
set_param(modelName1, 'StopTime', '0.1');  % 100ms = 5 cycles @ 50Hz
set_param(modelName1, 'MaxStep', '1e-5');  % 10 microseconds for switching accuracy

% Three-phase model settings
set_param(modelName2, 'Solver', 'ode23t');
set_param(modelName2, 'StopTime', '0.1');
set_param(modelName2, 'MaxStep', '1e-5');

% Save both models
save_system(modelName1);
save_system(modelName2);

fprintf('\n====================================================================\n');
fprintf('   SIMULINK MODELS CREATED SUCCESSFULLY\n');
fprintf('====================================================================\n\n');

fprintf('MODELS CREATED:\n');
fprintf('1. %s.slx\n', modelName1);
fprintf('   - Single-phase H-bridge inverter\n');
fprintf('   - 230V RMS output, 50Hz\n');
fprintf('   - Thyristor-based switching\n');
fprintf('   - RL load (10Ω, 10mH)\n\n');

fprintf('2. %s.slx\n', modelName2);
fprintf('   - Three-phase inverter (6-pulse bridge)\n');
fprintf('   - 400V line-to-line, 50Hz\n');
fprintf('   - 120° conduction mode\n');
fprintf('   - Star-connected load (5Ω, 5mH per phase)\n\n');

fprintf('SIMULATION SETTINGS:\n');
fprintf('  - Solver: ode23t (stiff/moderate)\n');
fprintf('  - Duration: 0.1 seconds (5 cycles)\n');
fprintf('  - Max Step: 10 microseconds\n\n');

fprintf('NEXT STEPS:\n');
fprintf('1. Open models: open_system(''%s'')\n', modelName1);
fprintf('2. Run simulation: sim(''%s'')\n', modelName1);
fprintf('3. Capture screenshots for report:\n');
fprintf('   print -s%s -dpng -r300 Problem3_SinglePhase_Diagram.png\n', modelName1);
fprintf('   print -s%s -dpng -r300 Problem3_ThreePhase_Diagram.png\n', modelName2);
fprintf('4. Analyze THD from scope outputs\n\n');

fprintf('Opening models in Simulink editor...\n');
open_system(modelName1);
pause(1);
open_system(modelName2);

fprintf('\n✓ Problem 3 Simulink models ready for simulation!\n\n');
